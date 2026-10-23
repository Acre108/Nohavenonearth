# Mock battle feedback — 17 October 2026

**Historical report:** these results describe the original 22×16 battlefield and 7–10 Structure mechs, before the longer-battle tuning pass. The current scenario and replay results are documented in [longer-battle-tuning.md](longer-battle-tuning.md).

## Method

Two fresh headless battles ran through the actual Godot TurnManager, movement rules, combat rules, terrain rules, and tactical AI. Seed: **20261017**. No gameplay definitions or balance values were changed.

The baseline uses the existing AI to control both sides. Blue arms I Can See It, but the ace never gets to fire. The second run adds a small diagnostic Blue policy: use Newtype Reflexes only when rotation can turn an otherwise unavailable attack into a legal shot. Both runs preserve hidden movement planning.

These are automated tactical simulations, not a human usability playtest or a statistically meaningful balance study. The extra attack in the replay changes subsequent consumption of the shared random generator, so the outcome difference cannot be attributed entirely to Newtype Reflexes.

## Results

| Observation | Baseline | Newtype-aware replay |
| --- | --- | --- |
| Winner | Red, round 5 | Blue, round 8 |
| Survivors | Bulwark 9/10; Wraith 5/7; Razor 5/5 | Ace 1/7 |
| Attacks resolved | 17 | 20 |
| Hold-fire activations | 5 | 2 |
| Attacks against cover | 6 | 10 |
| Attacks consuming a target lock | 9 | 14 |
| Ace Will spent | 0 | 4: one rotation and three reroll uses |
| Collision fallbacks / withdrawals | 0 / 0 | 0 / 0 |

Both battles reached victory normally. No script errors occurred. Godot emitted its existing certificate-store diagnostic, which does not affect this offline simulation.

## Battle observations

In the baseline opening, both flying mechs landed and both aircraft moved five units. Ace ended at (-1, -3), facing east. Bulwark was 4.6 units away, beyond the Beam Rifle's maximum range of 4. Wraith was 3.6 units away but outside the rifle's front arc. All of Ace's other weapons were out of range. Ace therefore passed its attack despite holding a lock on Wraith.

Wraith then dealt 4 damage to Ace. Bulwark rolled six hits against zero evades with its railgun, producing 12 raw damage against Ace's remaining 3 Structure. Ace was removed in round 1 without firing or spending Will. KITE was destroyed in round 4, followed by ANCHOR in round 5. Blue inflicted only 3 actual Structure damage in total.

In the replay, a **15-degree Newtype rotation** made Wraith a legal Beam Rifle target in the first round. That shot dealt 2 damage through heavy cover. Later, Ace destroyed Bulwark before its round-3 attack and eventually defeated Wraith in round 8, surviving on 1 Structure with no Will remaining.

## Feedback and priorities

1. **The arc / initiative / Will combination is promising.** A small facing adjustment enabled a real attack, and firing first later removed Bulwark's attack opportunity. Make this relationship easy to read: show how many degrees a target lies outside the arc and whether Newtype can bring it inside. Improve the AI's use of this existing power before changing the ace's statistics.

2. **The AI needs more concern for return fire.** It put Ace in a position where Ace could not shoot but two enemies could. Current movement scoring rewards its own range and facing, without scoring incoming threats. A simple penalty for exposure to legal high-damage enemy weapons would be a useful next improvement. Lock selection should also follow the intended weapon/target; several locks were placed on a different unit from the eventual attack target.

3. **Flying-mech identity needs a stronger test.** Both flyers landed immediately in both runs. Ace remained grounded in the replay, and Wraith also spent much of the battle grounded. There was no Energy-costing movement in either run. Ground mobility and cover are attractive, while the AI found little reason to pay for lateral or reverse thrust. First improve altitude/movement evaluation and test an aerial approach scenario; then decide whether the rules need a landing tradeoff.

4. **Energy is present but does not yet create sustained pressure in these battles.** The railgun costs 2 and its frame recharges 2; the Beam Rifle costs 1 and its frame recharges 2. Basic shooting can therefore continue without draining the reserve. Advanced movement is supposed to compete with weapons, but the AI did not use it. Test those combined costs before reducing recharge or increasing weapon costs.

5. **Lethality is very swingy.** The baseline railgun produced 12 raw damage in one shot against a 7-Structure ace. The replay also saw missiles deal 8 raw damage to a 5-Structure aircraft. Cover mattered—sometimes cancelling all hits—but a poor evade roll can erase a unit immediately. If the intended pace is several exchanges per unit, test slightly lower weapon damage or attack pools across more seeds. These two runs alone do not establish which faction needs a balance adjustment.

6. **Systems 3 currently offers a low-value action.** ANCHOR repeatedly acquired locks but could not get rerolls at Systems 3. This follows the current threshold specification, yet the player should see “tracking only; rerolls require Systems 4” before spending an action. Decide later whether a Systems-3 lock should gain another defined benefit.

The next useful iteration is **better facing/target feedback and AI threat awareness**, followed by a scenario that forces advanced movement and Energy decisions. The core simulation already supports a complete battle; these changes would make the intended tactical choices more consistently visible.

## Reproduce

```powershell
& 'C:\Program Files (x86)\Godot\Godot.exe' --headless --path . --script res://tests/mock_battle.gd
& 'C:\Program Files (x86)\Godot\Godot.exe' --headless --path . --script res://tests/mock_battle.gd -- --newtype
```

Detailed states, attack results, legality reasons, and logs are saved to `artifacts/mock-battle.json` and `artifacts/mock-battle-newtype.json`.
