# Points system — draft, 18 October 2026

Stats come from each design's lore. Points check whether a design's stats match what it is meant to
be worth. When a design wins more or less than its points predict, tune the **cost weights** in
`data/catalogues/costs.json`, not the mech. The demo battle stays whatever the lore says; it does not
have to be 50/50.

- Calculator: `data/point_costs.gd` (`PointCosts`)
- Report: `--script res://tests/points_report.gd`
- Matchups: `--script res://tests/matchup_run.gd -- --all --seeds 30 --standard-pilots`
  or `-- --a blue_kestrel --b red_medved,red_tank --seeds 100`

## Budgets

A mech's target cost covers frame, hands and weapons; the pilot is priced separately.

**Target = generation budget × tier multiplier**

| Generation | Budget |
| --- | ---: |
| Gen 1 | 75 |
| Gen 2 | 100 |
| Gen 3 | 130 (placeholder) |

| Tier | Multiplier | Meaning |
| --- | ---: | --- |
| Mass | 0.8 | Built in huge numbers; cheaper and fielded in quantity |
| Line | 1.0 | Standard front-line frame |
| Elite | 1.3 | Signature or specialist frame; fewer, better machines |
| Vehicle | 0.45 | Conventional tanks and aircraft |

## How things are priced

| Item | Cost |
| --- | --- |
| Structure | 0.25 per point |
| Armour | 4 per point, +2 for having an armour type |
| Size class | Small +5, Medium 0, Large −5, Super heavy −10 (hit modifier only; carrying is paid for through weapons) |
| Move | 4 per unit; flying mech +8; aircraft +4; 1 per extra manoeuvre |
| Energy | 1 per capacity, 3 per recharge |
| Frame stat bonus | 5 per Gunnery or Reflex, 3 per Melee or Precision, 2 per Guard or Spirit, 1 per Systems or Countermeasures |
| Weapon | 2 × expected damage per attack against a reference target (Reflex 1, Armour 2, Medium), × range factor (0.6 + 0.1 × max range − 0.05 × min range; melee 0.8) × arc factor (90° 1.0 → 360° 1.2), − 1 per Energy |
| Pilot | 3 per Gunnery or Reflex, 2 per Melee or Precision, 1 per Guard or Spirit, 0.5 per Systems or Countermeasures; Newtype +4, I Can See It +4 |

These are first-pass weights. They are what the matchup runs calibrate.

## Lore sheet (current units)

| Frame | Lore | Tonnage | Gen / tier | Target | Mech cost now |
| --- | --- | ---: | --- | ---: | ---: |
| HX-7 Kestrel | America's signature variable-frame strike fighter | 36 t | 2 elite | 130 | 121 |
| M9 Teamster | Army workhorse fielded in four-mech fire teams | 63 t | 2 line | 100 | 97 |
| Type-09 Tieshan | The most-built mech in the world | 68 t | 2 mass | 80 | 93 |
| OB-12 Medved | Heavy frame with built-in guns | 96 t | 2 line | 100 | 95 |
| Type-99 tank | Conventional support (no atlas entry) | ~55 t | 2 vehicle | 45 | 57 |
| F-12 Peregrine | Conventional support (no atlas entry) | ~20 t | 2 vehicle | 45 | 79 |

### Where current stats disagree with the lore (proposals, not applied)

- **Size by tonnage.** Proposed bands: Small under 45 t, Medium 45–80 t, Large 80–120 t,
  Super heavy over 120 t. That makes:
  - the Kestrel Small (now Medium); its LR-3 and AGM-M become Small weapons
  - the Tieshan Medium (now Large); its Long Cannon becomes a Medium weapon
  - the tank Medium (now Large); its gun becomes a Medium weapon
- **No energy weapons yet.** The briefs say early Gen 2 has "no glowing energy effects". The Vibro
  Knife and the Dao ("carbon blade") should be ballistic. Energy damage arrives in a later generation.
- **Armour types from the briefs:**
  - Teamster: sloped glacis with track links → ballistic
  - Tieshan: cast hull → ballistic
  - Medved: slab armour → ballistic
  - Kestrel: light airframe → none
  - (Later, the M12 Bulwark's reactive bricks and slat cage would make it the first explosive-armoured frame.)
- **Loadouts:**
  - The Teamster also carries an M140 rocket bazooka.
  - The Tieshan's brief lists a Type-03 shoulder rocket rack and a carbon blade, not a drum rifle.
  - The Medved's brief has twin forearm rotary cannons and the Grad-M; the Molot Ram is not in its
    brief, and its forearm guns suggest its fists are its melee weapon.

## First matchup results

One-on-one, 30 seeds per pair, every unit on the same standard pilot, deployment sides swapped every
other seed. "Points share" is A's share of the two sides' points; a well-priced pair should land
near it.

| A vs B | Points share (A) | A wins |
| --- | ---: | ---: |
| Kestrel vs Teamster | 55% | 70% |
| Kestrel vs Medved | 55% | 60% |
| Kestrel vs Tieshan | 56% | 100% |
| Kestrel vs fighter | 60% | 100% |
| Teamster vs Medved | 50% | 33% |
| Teamster vs Tieshan | 51% | 77% |
| Medved vs Tieshan | 50% | 100% |
| Fighter vs tank | 57% | 0% |
| Fighter vs every mech | 46–60% | 0% |
| Every mech vs tank | 57–66% | 100% |

What it says:

1. **Aircraft mobility is priced as a strength but plays as a weakness.** Forced flight paths and
   14 Structure lose every duel, even against the cheaper tank. Aircraft mobility should cost much
   less, or aircraft should be tested in squads, where their speed matters.
2. **The Tieshan underperforms for its cost**, and it is also over its mass-tier target (93 against 80).
3. **The Medved outperforms for its cost**: Structure and Armour are probably underpriced.
4. **Melee is underpriced.** The Vibro Knife costs 16 points but averages about 18 damage per attack
   in battles. The 0.8 melee range factor ignores Charge and the free attacks it creates.

## Next steps

1. Add a damage-exchange score to the matchup report (damage dealt per point, survivors' HP). One-on-one
   wins are all-or-nothing and need many seeds to separate close pairs.
2. Calibrate the weights until equal-points pairs land near 50%: aircraft mobility, Structure and
   Armour, and the melee factor first.
3. Apply the lore proposals above, then re-stat each design to its tier target.
4. Run equal-points squads (e.g. 300 points a side) as the main check, since one-on-one duels
   exaggerate rock-paper-scissors matchups.
