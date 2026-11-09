"""Reference rules engine for No Haven on Earth, written from the Player's Guide (playtest edition,
9 November 2026). It is the readable statement of the dice rules that the test vectors are built
from and that the Discord bot and the combat sandbox are checked against.

Everything is exact: chances are Fractions, never simulations. Standard library only.

Dice order, for scripted rolls (the bot and the sandbox must use the same order):
  1. the lock roll, if the attack rolls for a lock;
  2. one die per shot, in order;
  3. lock and I Can See It rerolls: each replaces one clean miss, earliest first, and a die is
     rerolled at most once this way;
  4. the full-Move reroll: the first die that is a hit after step 3 is rolled again;
  5. a crit die for each hit, in shot order, only if the crit target is 1 or more;
  6. a Brace die for each hit or glance that deals damage, in shot order, only if the target is
     bracing and its Brace target is 1 or more.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from fractions import Fraction

SIZE_ADJUSTMENT = {"Small": -1, "Medium": 0, "Large": 1, "Super heavy": 2}
CHARGE_BONUS = 2
PLANTED_BONUS = 1
PUSH_BONUS = 2
BRACE_REFLEX_PENALTY = 2
LOCK_REROLLS = 1
SEE_IT_REROLLS = 2
GLANCE_WINDOW = 2
DIFFICULTY = {"Easy": 2, "Standard": 0, "Hard": -2, "Very hard": -4, "Exceptional": -6}
TENTH = Fraction(1, 10)


class IllegalAttack(ValueError):
    """The attack cannot be made (for example a kneel-only weapon fired without kneeling)."""


def limit(target: int) -> int:
    """Ordinary targets are limited to 1-9: a 1 always succeeds and a 10 always fails."""
    return min(max(target, 1), 9)


def unlimited(target: int) -> int:
    """Crit and Brace targets are not limited: 0 or less never succeeds. A 10 still never does."""
    return min(max(target, 0), 9)


# ---------------------------------------------------------------- stats

def resolve_stat(pilot: int, whole: int, fractions: Fraction | float | str, frame_limit: int) -> int:
    """Total = pilot + whole bonuses + fractions counted in whole points toward zero, held to 1..limit."""
    frac = Fraction(fractions)
    counted = int(frac)  # int() truncates toward zero, as the guide asks
    return min(max(pilot + whole + counted, 1), frame_limit)


# ---------------------------------------------------------------- lock and Protocols

def lock_targets(systems: int, countermeasures: int) -> tuple[int, int]:
    """(lock target, countered up to). COUNTERED: the roll would have locked against CM 5."""
    return limit(5 + systems - countermeasures), limit(systems)


def lock_result(roll: int, systems: int, countermeasures: int) -> str:
    t, countered = lock_targets(systems, countermeasures)
    if roll <= t and roll != 10:
        return "LOCK"
    if roll <= countered and roll != 10:
        return "COUNTERED"
    return "NO LOCK"


def protocol_targets(systems: int, modifier: int, hostile: bool, target_cm: int | None = None,
                     push: bool = False) -> tuple[int, int | None]:
    """(success target, countered up to). Countered only exists for hostile Protocols: the roll
    would have succeeded against Countermeasures 5 with every other modifier the same."""
    bonus = modifier + (PUSH_BONUS if push else 0)
    if not hostile:
        return limit(systems + bonus), None
    if target_cm is None:
        raise ValueError("a hostile Protocol needs the target's Countermeasures")
    return limit(5 + systems - target_cm + bonus), limit(systems + bonus)


def protocol_result(roll: int, success: int, countered: int | None) -> str:
    if roll <= success and roll != 10:
        return "SUCCESS"
    if countered is not None and roll <= countered and roll != 10:
        return "COUNTERED"
    return "FIZZLED"


def purge_target(countermeasures: int, strength: int, modifier: int = 0, push: bool = False) -> int:
    """Purge: 5 + your Countermeasures - effect strength + difficulty. Success or failure only."""
    return limit(5 + countermeasures - strength + modifier + (PUSH_BONUS if push else 0))


def task_target(stat: int, modifier: int, push: bool = False, help_bonus: int = 0) -> int:
    return limit(stat + modifier + (PUSH_BONUS if push else 0) + help_bonus)


# ---------------------------------------------------------------- attacks

@dataclass
class Attack:
    # attacker totals
    attack: int                 # Gunnery for ranged weapons, Melee for melee weapons
    precision: int
    systems: int
    # weapon
    shots: int
    damage: int
    ap: int = 0
    aim: int = 0
    heavy: bool = False
    melee: bool = False
    damage_type: str = "Ballistic"
    on_hit: str | None = None
    ignore_cover: int = 0
    kneel_only: bool = False
    # defender
    reflex: int = 5
    countermeasures: int = 5
    armour: int = 0
    armour_type: str = "None"
    size: str = "Medium"
    brace: int = 5
    structure: int = 50
    stance: str = "evade"       # "evade" or "brace"
    full_move: bool = False     # evading and moved its full Move by Ground Move or Cruise (or an aircraft)
    # situation
    cover: int = 0
    lock: str = "roll"          # "roll", "locked" (given) or "none" (jammed, out of range or no sight)
    push: bool = False
    see_it: bool = False        # attacker has I Can See It and the Will for it
    planted: bool = False       # attacker braced and did not move or break off
    charged: bool = False       # attacker charged this target this round
    modifier: int = 0           # any other modifier, such as +2 for a parting strike or Tag
    notes: list = field(default_factory=list)

    @classmethod
    def from_case(cls, case: dict) -> "Attack":
        a, w, d, s = case["attacker"], case["weapon"], case["defender"], case["situation"]
        return cls(
            attack=a["attack"], precision=a["precision"], systems=a["systems"],
            shots=w["shots"], damage=w["damage"], ap=w.get("ap", 0), aim=w.get("aim", 0),
            heavy=w.get("heavy", False), melee=w.get("melee", False),
            damage_type=w.get("damage_type", "Ballistic"), on_hit=w.get("on_hit"),
            ignore_cover=w.get("ignore_cover", 0), kneel_only=w.get("kneel_only", False),
            reflex=d["reflex"], countermeasures=d["countermeasures"], armour=d["armour"],
            armour_type=d.get("armour_type", "None"), size=d.get("size", "Medium"),
            brace=d.get("brace", 5), structure=d["structure"], stance=d.get("stance", "evade"),
            full_move=d.get("full_move", False),
            cover=s.get("cover", 0), lock=s.get("lock", "roll"), push=s.get("push", False),
            see_it=s.get("see_it", False), planted=s.get("planted", False),
            charged=s.get("charged", False), modifier=s.get("modifier", 0),
        )

    # -- targets

    def check_legal(self) -> None:
        if self.kneel_only and not self.planted:
            raise IllegalAttack("kneel_only: fires only if the unit braced and did not move")
        if self.stance not in ("evade", "brace"):
            raise ValueError(f"unknown stance {self.stance!r}")
        if self.lock not in ("roll", "locked", "none"):
            raise ValueError(f"unknown lock {self.lock!r}")

    @property
    def bracing(self) -> bool:
        return self.stance == "brace"

    def hit_raw(self) -> int:
        reflex = self.reflex - (BRACE_REFLEX_PENALTY if self.bracing else 0)
        cover = max(0, self.cover - self.ignore_cover)
        return (5 + self.attack - reflex - cover + self.aim + SIZE_ADJUSTMENT[self.size]
                + (CHARGE_BONUS if self.charged and self.melee else 0)
                + (PLANTED_BONUS if self.planted else 0)
                + (PUSH_BONUS if self.push else 0) + self.modifier)

    def hit_target(self) -> int:
        return limit(self.hit_raw())

    def glance_to(self) -> int | None:
        return min(10, self.hit_target() + GLANCE_WINDOW) if self.heavy else None

    def crit_target(self) -> int:
        return self.precision - 5

    def brace_target(self) -> int | None:
        return self.brace - 2 if self.bracing else None

    def full_move_reroll(self) -> bool:
        return self.full_move and not self.bracing

    def effective_armour(self) -> int:
        matched = 2 if self.armour_type == self.damage_type else 0
        return max(0, self.armour + matched - self.ap)

    def damages(self) -> tuple[int, int, int]:
        ea = self.effective_armour()
        return max(0, self.damage - ea), self.damage, max(0, self.damage // 2 - ea)

    def classify(self, roll: int) -> str:
        t = self.hit_target()
        if roll <= t and roll != 10:
            return "hit"
        g = self.glance_to()
        if g is not None and roll <= g:
            return "glance"
        return "miss"

    # -- exact forecast

    def _outcome_chances(self) -> dict[str, Fraction]:
        t = self.hit_target()
        p_hit = Fraction(t, 10)
        p_glance = Fraction(self.glance_to() - t, 10) if self.heavy else Fraction(0)
        return {"hit": p_hit, "glance": p_glance, "miss": 1 - p_hit - p_glance}

    def _settle(self, outcome: str) -> list[tuple[Fraction, int]]:
        """Damage of one die's final outcome, with crit and Brace rolls folded in."""
        if outcome == "miss":
            return [(Fraction(1), 0)]
        dh, dc, dg = self.damages()
        if outcome == "hit":
            p_crit = Fraction(unlimited(self.crit_target()), 10)
            parts = [(1 - p_crit, dh), (p_crit, dc)]
        else:
            parts = [(Fraction(1), dg)]
        bt = self.brace_target()
        p_half = Fraction(unlimited(bt), 10) if bt is not None else Fraction(0)
        out = []
        for p, dmg in parts:
            if p == 0:
                continue
            if dmg > 0 and p_half > 0:
                out.append((p * (1 - p_half), dmg))
                out.append((p * p_half, dmg // 2))
            else:
                out.append((p, dmg))
        return out

    def distribution(self, lock_rerolls: int, extra: int) -> dict[tuple[int, bool, bool], Fraction]:
        """Exact joint distribution of (total damage, any shot hit, I Can See It used), given the
        lock's rerolls and I Can See It's. I Can See It costs Will only if a miss is left for it."""
        chances = self._outcome_chances()
        settle = {o: self._settle(o) for o in chances}
        rerolls = lock_rerolls + extra
        # state: (rerolls left, full-Move reroll pending, rerolls used, damage, any hit) -> chance
        states: dict[tuple[int, bool, int, int, bool], Fraction] = {
            (rerolls, self.full_move_reroll(), 0, 0, False): Fraction(1)}
        for _ in range(self.shots):
            nxt: dict = {}
            for (left, fm, used, dmg, hit_any), p in states.items():
                for first, q in chances.items():
                    if q == 0:
                        continue
                    branches = [(first, q, left, used)]
                    if first == "miss" and left > 0:
                        branches = [(o, q * q2, left - 1, used + 1) for o, q2 in chances.items() if q2]
                    for outcome, q1, left1, used1 in branches:
                        finals = [(outcome, q1, fm)]
                        if outcome == "hit" and fm:
                            finals = [(o, q1 * q2, False) for o, q2 in chances.items() if q2]
                        for final, q2, fm2 in finals:
                            for q3, d in settle[final]:
                                key = (left1, fm2, used1, dmg + d, hit_any or final == "hit")
                                nxt[key] = nxt.get(key, 0) + p * q2 * q3
            states = nxt
        out: dict[tuple[int, bool, bool], Fraction] = {}
        for (left, fm, used, dmg, hit_any), p in states.items():
            key = (dmg, hit_any, used > lock_rerolls)
            out[key] = out.get(key, 0) + p
        return out

    def forecast(self) -> dict:
        self.check_legal()
        extra = SEE_IT_REROLLS if self.see_it else 0
        locked = self.distribution(LOCK_REROLLS, extra)
        unlocked = self.distribution(0, extra)
        if self.lock == "roll":
            t, countered = lock_targets(self.systems, self.countermeasures)
            p_lock = Fraction(t, 10)
        else:
            t = countered = None
            p_lock = Fraction(1) if self.lock == "locked" else Fraction(0)
        mixed: dict = {}
        for dist, w in ((locked, p_lock), (unlocked, 1 - p_lock)):
            if w:
                for k, p in dist.items():
                    mixed[k] = mixed.get(k, 0) + p * w

        def expectation(dist):
            return sum(p * k[0] for k, p in dist.items())

        dh, dc, dg = self.damages()
        result = {
            "hit_target": self.hit_target(),
            "glance_to": self.glance_to(),
            "crit_target": self.crit_target(),
            "brace_target": self.brace_target(),
            "full_move_reroll": self.full_move_reroll(),
            "lock_target": t,
            "lock_countered_to": countered,
            "effective_armour": self.effective_armour(),
            "hit_damage": dh,
            "crit_damage": dc,
            "glance_damage": dg,
            "p_lock": p_lock,
            "expected_damage": expectation(mixed),
            "expected_damage_locked": expectation(locked),
            "expected_damage_unlocked": expectation(unlocked),
            "p_damage": sum(p for k, p in mixed.items() if k[0] > 0),
            "p_destroy": sum(p for k, p in mixed.items() if k[0] >= self.structure),
            "p_on_hit": sum(p for k, p in mixed.items() if k[1]) if self.on_hit else None,
            "p_will_see_it": sum(p for k, p in mixed.items() if k[2]) if self.see_it else None,
        }
        return result

    # -- scripted resolution

    def resolve(self, dice: list[int]) -> dict:
        """Resolve the attack with these d10 rolls, in the order in the module docstring.
        Every die must be used: too few or too many is an error."""
        self.check_legal()
        rolls = list(dice)
        used = 0

        def d10() -> int:
            nonlocal used
            if used >= len(rolls):
                raise ValueError("ran out of dice")
            r = rolls[used]
            used += 1
            if not 1 <= r <= 10:
                raise ValueError(f"bad die {r}")
            return r

        lock = "LOCKED" if self.lock == "locked" else "NO ROLL"
        if self.lock == "roll":
            lock = lock_result(d10(), self.systems, self.countermeasures)
        rerolls = LOCK_REROLLS if lock in ("LOCK", "LOCKED") else 0
        shots = [{"roll": d10()} for _ in range(self.shots)]
        for s in shots:
            s["result"] = self.classify(s["roll"])
        misses = sum(1 for s in shots if s["result"] == "miss")
        will = 0
        if self.see_it and misses > rerolls:
            will = 1
            rerolls += SEE_IT_REROLLS
        for s in shots:
            if rerolls <= 0:
                break
            if s["result"] == "miss":
                s["first"] = s["roll"]
                s["roll"] = d10()
                s["result"] = self.classify(s["roll"])
                rerolls -= 1
        if self.full_move_reroll():
            for s in shots:
                if s["result"] == "hit":
                    s["full_move_first"] = s["roll"]
                    s["roll"] = d10()
                    s["result"] = self.classify(s["roll"])
                    break
        ct = self.crit_target()
        if ct >= 1:
            for s in shots:
                if s["result"] == "hit":
                    s["crit_roll"] = d10()
                    if s["crit_roll"] <= ct and s["crit_roll"] != 10:
                        s["result"] = "crit"
        dh, dc, dg = self.damages()
        bt = self.brace_target()
        total = 0
        for s in shots:
            s["damage"] = {"hit": dh, "crit": dc, "glance": dg}.get(s["result"], 0)
            if bt is not None and bt >= 1 and s["damage"] > 0:
                s["brace_roll"] = d10()
                if s["brace_roll"] <= bt and s["brace_roll"] != 10:
                    s["damage"] //= 2
            total += s["damage"]
        if used != len(rolls):
            raise ValueError(f"{len(rolls) - used} dice left over")
        return {
            "lock": lock,
            "shots": shots,
            "total": total,
            "will_see_it": will,
            "on_hit": bool(self.on_hit) and any(s["result"] in ("hit", "crit") for s in shots),
            "destroyed": total >= self.structure,
        }
