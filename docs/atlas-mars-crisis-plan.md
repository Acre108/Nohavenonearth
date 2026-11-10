# Plan: adding the First Martian Crisis to the atlas

**Status, 2026-11-09:** done in atlas version 94, with these differences from the plan below:
- The dates are the recommended ones: the crisis in 2312 and the megagame in 2327.
- No Peace Past Luna has four generations:
  - Gen 1, c. 2190–2311;
  - Gen 2, the crisis;
  - Gen 3, 2313–2326, when the Constitutionalists are founded;
  - Gen 4, 2327.
- The era got its own **NPPL Conflicts** tab (`DATA.nppl`) rather than extra columns on the Conflicts tree.
- The Map tab switches between the world map and a new inner-system map (`SOLAR` in atlas-data.json).
- Ids follow `nE/nL/nM/nB/nO` by family, not `wM`.
- Still open:
  - the NPPL Draft Doc canon note (Phase 1);
  - the Charon-class fleet card and the crisis notes on fleet classes;
  - the new organisations;
  - Aces era 5;
  - a Mars surface map.

Source records:
- [Orders and Updates log](https://docs.google.com/spreadsheets/d/1-D9UWZ00mXYdmAVGMXn9xLHRoa8UPJIpgmoEFhjP81w)
- [Locations and assets sheet](https://docs.google.com/spreadsheets/d/1f7LwmJomOYmoalFeR4XLd-1jhfcaUpUL-BgdMSwxyuY)
- The Christmas Discord game, December 2025.

## What the atlas already says

The atlas's 2327 material already describes Mars *after* this crisis:
- Colony One's Successors card reads "founded by the United States, crushed by it, and now a fleet, a network and a memory". Its home is "the US-held Colony One Bastion".
- The Constitutionalists' card says they were "built from the wreckage of the **First Martian Crisis**", and that they hold a third of Mars beside the Bastion.
- Colony One's 2327 fleet classes (Wayfinder and the rest) are built in hidden docks "if the United States thought the colony had rebuilt a navy, it would come to finish the job".

So the game is the event the atlas's end state grew out of. The work is mostly placing it in time and linking it, not rewriting anything.

## Rulings already made (2026-11-09)

1. The date can move to fit.
2. **The Hegemony** is a faction inside the Eurasian Ascendancy, and a plot point from here on. It holds the Mercury station, the AMX/9 work and the plans for Jupiter. The Ascendancy itself stays "people first".
3. Refugees head outward before the war too, in small numbers, and the earliest go furthest. The Plutonians are the earliest. The Communion's polar exodus comes later and in far larger numbers.
4. The Constitutionalists' seed ("when Colony One breaks with Washington") is the July revolt.
5. Helion vs Helios is left alone for now.
6. Concord → Axiom: done in both sheets (MRD Battlegroups tab, MRD sheet Battlegroups tab).
7. Deng Lixing being both China's spymaster and a Solar Court judge is deliberate.
8. The UNEL keeps its own AI, under a new name. The obvious jokes come out.

## Decisions still needed

**D1. The date model.** Recommended: **the crisis happens in 2312, and 2327 stays the megagame year.**
- Game Control set the megagame about 15 years after the civil war. The atlas's 2327 already shows the post-crisis state, and every NPPL brief is dated 2327, so none of that changes.
- Only the game's own dates move: Turn 0 becomes January 2312, and so on.
- Turn 0's "33 years since the war" becomes "over a century" (the war ends c. 2190).
- This gives three NPPL generations:
  - **First:** the long post-war era, c. 2190–2311 (the atlas's Post-war and Late fleet columns).
  - **Second:** the First Martian Crisis, 2312.
  - **Third:** the Greater Solar Crisis, 2327 (the megagame).

Alternative: keep the crisis in 2327 and move the megagame to c. 2342. That means relabelling the atlas's 26 "2327" references, the NPPL briefs and the Successors text, and the crisis lands in the same year the atlas presents as settled.

**D2. Names awaiting approval.**
- The UNEL AI: **PEARY**, after the lunar town, "one of Luna's coordinating minds".
- The rogue AI site: **the Waikato bunkers** (rogue AI #237), replacing Hobbiton.
- "Han Zolo" needs a new name (CPS fleet ace), for example **Han Zhuo**.
- The Turn titles "Scouring of the Shire" and "That's No Moon" stay out of canon.

**D3. A Mars map: yes or no.** It would show the Line of Control and the colonies. It is the largest single job, so it's optional (Phase 6).

## Phase 1: canon note (no atlas change)

Write one "Canon note" section at the end of the NPPL **Draft Doc** (Drive folder "NPPL"). It covers:
- the date model;
- the renames;
- the eight rulings above;
- the hidden truth of Minangkabau, with three layers:
  1. The Hegemony and Dr Zeresh field-tested an AMX/9 variant aimed at the enhanced, through the Mercury relay.
  2. The MRD's triage let the adults die.
  3. The TAU spoiled the investigation.
- the US Eagle variant held on Phobos.

The game log itself stays as it is. It's a record.

## Phase 2: placing the era in the atlas

The Conflicts tree's columns feed the Timeline lanes (`TL_COLS = [...DATA.conflicts.cols, ["2327", ...]]`). Adding columns there gives every faction lane the new era with no new layout.

- Add two Conflicts columns after "The war": **Post-war** (c. 2190–2311) and **First Martian Crisis** (2312).
- Engineering check first: the column count feeds the map eras and the CHRONO `e` values. Confirm `check.js` and the map still work with 8 columns before writing entries.
- Add a CHRONO era between the war and 2327 for the crisis entries.

## Phase 3: new entries

Ids `wM1` onward, family in brackets. Parents are existing ids. Every name needs approval.

| Id | Entry | Family | Links to |
|---|---|---|---|
| wM0 | **The Far Lift**, pre-war (c. 2170s), small numbers; the earliest leavers go to Pluto. In the Gen 3 column. | orb | wO21 Long Lift, wW17 Northern Lift, xv1 The Choir |
| wM1 | **The Line of Control**, post-war; Mars split between Colony One and the MRD, never a border | orb | wO8 Melas Landing, wO18 Red Roster, wO20 Panel Looks Up |
| wM2 | **The Spire's Vaults**, post-war; the UNEL keeps the last WW3 bioweapons on Luna for countermeasures | orb | og_unel, the Geneva Orbital Draft (wO11) |
| wM3 | **The Breaking of the Andes / Bolivian Annexation** | south | wW11 Open Cities, wS13 Southern Crossing |
| wM4 | **The Tunis Lease and Cyprus** | south | fg0 Maghreb yards, wS13 |
| wM5 | **The Minangkabau Outbreak** (redacted card, `rx:1`) | orb | wM1, wM2, wS16 Monsoon Raids (India's bio programme) |
| wM6 | **The Spire Affair**: Zeresh arrested, Earth First exposed | orb | wM2, wO15 Pressure War, og_eward |
| wM7 | **The Waikato Strike** on rogue AI #237 | pac | wE11 Mong Hsat Operation, og_wf |
| wM8 | **The Solar Court** and the Deng Lixing appointment (plant left unstated in the text; truth in redactions) | west | wW10 Geneva Address, og_un |
| wM9 | **The Plutonian Ship and the Sun Cult** | orb | wM0, xv1 |
| wM10 | **The Great Exchange**: Pallas and Juno taken over, Hygiea moved, VIGOR and the MAC crews | orb | wO23 Juno Concession, wO24 Patron's Lease, og_pga, sfc25 Goldpurse |
| wM11 | **The Eros Silence and the Toronto Torrent** (TAU integration) | west | BOR lane (wW16 Winter War), wW14 |
| wM12 | **The Red Wall and Project Hasta** (MRD) | orb | wM1, wO25 Strasbourg Requisition |
| wM13 | **Colony One's Revolt**, July: the break with Washington | orb | wO18, wO22 River Judges, wW18 Loyal Minority |
| wM14 | **The Martian Civil War**: Phobos, the Trojans, the TAU blockade | orb | wM12, wM13, og_hrd |
| wM15 | **The Elara Rising** (C1 loyalists at Jupiter) | orb | wM13 |
| wM16 | **The Hegemony**: Mercury station, Jupiter plans (redacted card) | east | og_dz Department Zero, xk3 Nashik Oath, wE15 Vladivostok Blessing |

Timeline lane events in the crisis column:
- **HAL:** Bolivia, Phobos, the Eagle variant.
- **VEK:** Cyprus, Tunis, Eros, the blockade.
- **BOR:** Toronto.
- **TSM:** Australia, Cordoba, the watchware.
- **OKB:** the Hegemony.
- **QAC:** Tunis returned, the Eros protest.
- **ASC:** the civil war.
- **LUN:** the Spire Affair.
- **UNO:** Waikato, the Solar Court, the observers.

## Phase 4: edits to existing cards

- **Successors, Eurasian Ascendancy:** add the Hegemony as the faction that keeps Department Zero's logic inside a people-first state.
- **Successors, UNEL:** add the split between Earth First (the Earthward's heirs) and Humanity First, and the coordinating minds (PEARY).
- **Successors, Colony One:** the MRD breaks its fleet in 2312, and the US finishes the job afterwards and holds the First City as the Bastion. The current text already allows this, so it only needs a link to wM13 and wM14.
- **Constitutionalists:** link "First Martian Crisis" to wM14.
- **Communion and xv1:** the Plutonians come first and the polar refugees join them later.
- **CPS:** the Great Exchange and the sun cult made legal. **MRD:** link to the Red Wall.
- **Fleets:**
  - Add a **Charon-class battleship** (Plutonian; one hull, the LL Krillmask, taken into the CPS) in the Late column.
  - Add crisis notes to Redline (sensor troubles, refit), Axiom (the Spigen Halt salvaged), Dustwing (weak in a fight) and Goldpurse (first launched at Ceres during the crisis).
- **Organisations:**
  - the Solar Court;
  - the Lunar Vacuum Research Spire;
  - Voidborne Security;
  - Albedo Industries;
  - the Strategic Security Institute (TAU);
  - the Innovation Bureau (MRD);
  - the I&AD and the Expeditionary Directorate (C1).
- **Redactions** (`atlas-redactions.json`, local only):
  - Minangkabau's three layers;
  - Deng Lixing's two roles;
  - the Mercury relay;
  - the Eagle variant;
  - what the Waikato teams recovered.

## Phase 5: people

Aces are pilots, so the crisis's commanders and spies go into entry texts rather than ace cards: Silas Vane, Torin Calder, Victor Blackhawk, Kalani Stevens, Jay Albedo, Sun Wukong 236/H and Bartholomew Morgan.

Optional: an `ACE_ERAS` era 5, "First Martian Crisis", for the fleet commanders who fought. That would mean Vane, Eric Hart, Kalani Stevens and Morgan.

## Phase 6: Mars map (if D3 is yes)

A Mars panel beside the world map, drawn from the Locations sheet:
- the North, Mid and South Mars colonies;
- the Line of Control;
- Minangkabau, Astraeus Prime, the Hammer of Mars and Helion;
- Phobos and Deimos.

Its entries would open the wM cards.

## Phase 7: checks and publishing

1. Diff the local atlas files against the live artifact first. Other sessions edit it.
2. Insert lines into `atlas-data.json` without reformatting it (`tools/apply.js`). Run `node tools/check.js mech-lineage-atlas.html`.
3. Preview with `tools/serve.js`.
4. Publish with `atlas-data.json` in `files`. Never publish `atlas-redactions.json`.

## Order of work

D1 and D2 → Phase 1 → Phase 2 engineering check → Phase 3 → Phase 4 → Phase 5 → Phase 6 if wanted → Phase 7.
