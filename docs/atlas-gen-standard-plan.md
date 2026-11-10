# Plan: bringing every atlas tab up to the Gen 0–9 standard

Written 2026-11-09, after Power, Frames, Weapons and Doctrine were converted (atlas versions 99–104). Tidied on 2026-11-10: the resolved decisions are folded into the status, the order of work is a single list, and a Restructure section is added.

## Status (2026-11-10, after atlas version 114)

**Decisions**
- **A:** "Projected" is removed from the war; only Gen 9 (2327) keeps it.
- **B:** Fleets keeps its Gen 6 early/late split for now.
- **C:** space factions get their own Factions lanes.
- **E:** Aces cover all ten generations.
- **R1 and R2** (2026-11-10, see Restructure): merge the two Conflicts tabs, and collapse the panels above each tree.
- **Still open: D, giants after the war.** What do the Mandate and the Weapons Resolution say about super robots? It includes Takemikazuchi's fate, which you've left open. Supers waits for it.

**Done**
- **Step 1, largely:**
  - The shared `GENS` scale is in the data.
  - Conflicts, Supers and Organisations are relabelled to the scale.
  - NPPL Conflicts and Mysteries are relabelled to Gen 6–9.
  - Persons of Interest uses "Gen 1–2 … Gen 9".
  - The Timeline tab's war banner is removed.
  - The map's era note is rewritten.
  - The data notes for Aces and the Timeline now say their era fields are Gen numbers (2026-11-10).
  - Still missing: the check.js rule that every tree uses the shared labels and has a post-war entry for each faction it profiles. It's in the final sweep.
- **Step 9, Aces:** 29 new pilots across Gen 5–9, faction filters for all 13 factions, and links to Persons of Interest (Han Zhuo, Rahim Qureshi and Sable Calder) and to Haven ancestors.
- **Step 10's Factions part:** every lane runs Gen 0–9. There are new lanes for Colony One, the MRD, the CPS, the Constitutionalists, Umoja, the Ashva Compact and the Communion, and the "Orbit & Mars" and "Outside the blocs" lanes hand over to them. Faction views treat the new lanes as their own.
- **Step 2, Space Fleets (version 106, 2026-11-10):**
  - **Columns:** Gen 4, Gen 5, Gen 6 · early, Gen 6 · late, Gen 7, Gen 8 and Gen 9. Only Gen 9 is projected.
  - **The old 2327 column is split by when each class first flew, using the 2312 game's battlegroup sheet:**
    - Gen 7: the classes that fought in 2312 (Redline, Vanguard, Axiom, Skyblade, Fortune, Ledger, the first Goldpurse, Arbiter).
    - Gen 8: the first post-crisis hulls (Wayfinder, Liberty, Concordia, Chergui, Strela, Kitezh, Seedshield, Greenwall, Ashva, Bastion, Hearth).
    - Gen 9: the newest classes.
  - **Development is deliberately uneven (revised in version 107 at the user's request):**
    - The US and China keep their late-Gen 6 lines, but build against their colonies after 2312: the Marshal frigate and the air-gapped Independence battleship (US, Gen 8), the Jianwei torch-hunter (China, Gen 8) and the Tianmen fusion-frame carrier (China, Gen 9).
    - The earliest space-built offshoots sit in Gen 6 early: the Lifeline, the radiation cutters, and the MRD's new Deimos survey cutters. The MRD's Axiom moves to Gen 6 late, so its fleet no longer appears all at once in 2312.
    - The Ascendancy, Commonwealth, Umoja and the Ashva Compact build through Gen 6 and 7. The Kitezh, Chergui and Bastion get notes on where they were in 2312.
    - The Syndicate builds nothing after 2312.
  - **New cards:**
    - Defector Rapiers (Colony One, Gen 7, a dead end);
    - Union hulls on Directorate code (MRD, Gen 7);
    - Phobos drop tenders (US, Gen 7);
    - the Charon-class battleship, the Krillmask's class (Gen 6 late);
    - Hanse-class anchorage ships (TAU, Gen 8);
    - Assessor-class cutters (UNEL, Gen 8, which fit the Second Seal).
  - **Crisis notes from the game log:**
    - the Redline's sensor fault and its refit at Vesta;
    - the Spigen Halt, a second Axiom brought online from a salvaged Third World War wreck;
    - Colony One's weak Dustwings;
    - the Goldpurse's first launch at Ceres;
    - the Sovereign and the Resolute Dawn at the Trojans.
  - **Power plants:** every warship class is tied to its plant.
  - **Panel:** "Who flies what in space" has one row per faction.
  - **Pre-crisis tags:** Earth hulls before Gen 7 carry an `fx` tag for the space faction that flew them, so each space faction's view shows the ships it started with:
    - US → Colony One and the Constitutionalists;
    - Union → MRD;
    - Beijing → Syndicate;
    - League/Commonwealth → Umoja;
    - Moscow/Delhi → Ashva;
    - Exodus ships → Communion.
- **Carriers folded into Fleets (2026-11-10, local, not yet published):**
  - **One tab, "Fleets & Carriers"** (key `fleets`). The Carriers tab is gone, and old `#carriers` links and remembered tabs open the merged tab.
  - **Columns:** Gen 0–5, Gen 6 · early, Gen 6 · late, Gen 7, Gen 8 and Gen 9 (11 columns; Gen 9 projected).
  - **Gen 5 is one column.** The carriers' war-years split survives as a note at the end of each card ("Gen 5, the war's first/last years").
  - **Bands:** sea carriers, land carriers, airships and air warships, orbital and space carriers (the old "Orbital carriers" and "Carriers" bands merged), transports, corvettes and frigates, battleships, dreadnoughts.
  - **Three duplicates merged.** Each was on both tabs; the Carriers card was kept and every reference redirected to it:
    - Catapult Cruisers: sfc0 → yo3;
    - Mixed-Wing Carrier(s): sfc1 → yo6;
    - Drop Carrier(s): sfc2 → yo5.
  - **Kept as they were:** the Marlinspike plate, the intro and turning points (rewritten as one set of 9), and the "Who flies what in space" panel.
  - **Two Hakobune cards** (yh51 the Japanese ark, yh64 its flight to Vladivostok) now share the Gen 5 column. That's intended, since they're two stages of one ship.

- **Generation and type filters (versions 109–110, committed 5c4940a):**
  - Trees with more than six columns get a Generations row: All, Before the war, After the war, and a chip per column.
  - Fleets & Carriers and Vehicles also get a Types row.
  - Choices are remembered per tree in the reader's browser.
- **Step 3, Vehicles (version 111, 2026-11-10):**
  - **Columns:** the shared Gen 0–9 scale. Only Gen 9 is projected.
  - **57 new cards.** Earth lines carry on with gaps and offshoots:
    - **War (Gen 5):** the Regulator II on the Liberty Core, the crewless Tiejia-Zhan, the League's Sarab ambulance columns, the Union's relay-killing Herse and Milan-R, the fission Taran-F, Muskeg-W haulers for both sides of the Winter War, and the UN's White Column into the Open Cities.
    - **Peace (Gen 6), on cheap Belt fuel with reactors off Earth's battlefields:**
      - the Provost (US) and the Gardien (TAU);
      - the Tiejia-VI, which goes back to diesel and is still crewless;
      - the Vityaz-D (Ascendancy) and the Kafila-M (Commonwealth);
      - the UNEL's Relay Truck (it can be switched off), the Kansai Rescue Carrier and the Andean warlords' rebuilds;
      - civil airlifters and rescue tiltrotors.
    - **Later:** the Hound-A and Kite VII for Bolivia, China's Lianxin aid convoys, the Commonwealth's Rahma, the Hobby fighter, and the Keystone Hauler in 2327.
  - **New band, "Off-world vehicles":**
    - Colony One: Sealed Drovers, the Burrower and partisan tunnel carts.
    - MRD: Kurier survey cars, the Surveyor, the Hammer Tractor and a fusion-cell field lab.
    - Syndicate: the Belt Tug and the Cargo Walker.
    - Umoja: the Kin Carrier, ammonia-fed and grown.
    - Ashva: the Rath-E and the Hunt Crawler.
    - Communion: the Ice Crawler, descended from the Winter War Muskegs, and the Mirror Sledge.
    - Ascendancy: cloud skiffs at Venus.
    - US: the Dust Ranger and the Bastion Patrol.
    - Constitutionalists: the Charter Carrier.
  - **Panel:** "Who drives what after the war", one row per faction.
  - **Tags:** the Earth vehicles that space factions started from also carry those factions' tags (the Drover II, Kurier, Muskeg-W, Sarab and Ranger).
  - **Bug fix:** a pressed preset chip was unreadable in dark mode.

- **Step 4, carriers after the war (version 112, 2026-11-10):**
  - **16 new cards in the sea, land, air and orbital bands, Gen 6–9.** No reactor lifts anything in Earth's sky after the Mandate.
  - **Sea:**
    - the Lexington, a US supercarrier on fuel, and the Monterrey amphibious ship;
    - the Kizuna Tender II under Beijing's flag, and China's Ciji hospital ships;
    - the Union's Mare Nostrum, and the Narwhal icebreaker carrier (Gen 8), which revives the Polar Carrier line;
    - the Ascendancy's Samudra on the monsoon coast;
    - the Commonwealth's Bahari relief ferries.
  - **Land:**
    - Krepost crawlers stripped into travelling towns (the Gorod);
    - Shifa crawler hospitals descended from the Hospital Safina;
    - China's railway to the Darkhan accelerator.
  - **Air:**
    - the Rookery-F, the last helicarrier, a dead end on fuel;
    - the UNEL's Long Lifter airships;
    - diesel Kaspiy-D ground-effect carriers.
  - **Orbital lift:** the UNEL's licensed lift shuttles, and China's Darkhan accelerator sleds.
  - **Tags:** the seeding ships were already tagged (the Hospital Safina for Umoja, the Hearth for the Communion, the Hakobune for Ashva), and so were the old orbital carriers. Earth-bound carriers stay untagged.
  - **Panel:** renamed "Who flies and carries what". The Earth powers' and the UNEL's rows now cover their carriers on Earth.
- **Offensive off-world carriers (version 113, commit 181b1b9):** nine assault carriers and landers for Mars and the Jovian moons in the orbital and space band, Gen 8–9:
  - the MRD's Gradient entry tender and Colony One's Ghostlight raid landers;
  - China's Pojun and the US Inchon;
  - the Ascendancy's Sadko and Ashva's Antardhara under-ice carrier;
  - Umoja's Mbegu seeding carrier, the TAU's Ostia assault anchorage and the Syndicate's Strongbox.
- **R2, collapsible panels (version 114):** on every tree tab, the turning points and the faction panel are closed sections with a count in the summary ("Turning points · 8", "Who runs what · 13 factions"). The intro and plate stay open.
  - Each viewer's choice is kept per tree in localStorage (`atlas-open-<tree>-turns` / `-profile`).
  - In a faction view the panel opens unless the viewer has closed it.
  - The turning-point count follows the generation picker.
- **Step 6, Organisations (version 114):**
  - **Columns:** Gen 0–9 on the shared scale.
  - **Bands:** two new bands, "Mars" and "The Belt and beyond", and a new "Earth's ministries" band for the post-war offices.
  - **23 new entries:**
    - **Earth's ministries:** the US Department of War (with the Office of Strategic Influence), the TAU's Strategic Security Institute (with the External Commerce Commission), China's Ministry of External Harmony (with the Bureau of Strategic Development), and the Hegemony (tagged for the Ascendancy and Ashva). The pairs come from the NPPL faction briefs.
    - **Africa:** Qadira's export office.
    - **The UNEL:** the Office of Global Stewardship, the Directorate of Unified Security, the Solar Court (Gen 7) and the Lunar Vacuum Research Spire.
    - **Mars:** Colony One's Expeditionary Directorate and Intelligence and Analysis Directorate, Dustline Works, the MRD's Innovation Bureau, Vesta Works, and the Constitutionalists' Corporate Liaison Office and New Philadelphia Arsenal (Gen 8).
    - **The Belt and beyond:** Voidborne Security, Albedo Industries (Gen 7), Skycut Foundry, Umoja's life-systems councils, Ganymede Vatworks, Garuda Works and the Hearthwrights.
  - **Panel:** "Organisations after the war", one row per faction.
  - **Turning points:** three new ones for Gen 6, 7 and 8.
  - **Inner-system map:**
    - Makers and labs off Earth are pinned as hollow squares above their body: the lunar yards, Shackleton Works, the Malapert docks, the Spire, Dustline, Vesta Works, New Philadelphia Arsenal, Skycut, Albedo, the Vatworks, Garuda and the Hearthwrights. They use a new `ORGMAP` field, `sys`.
    - The Organisations list and toggle now show on that map too.
    - Governments and offices stay off the map, as on the world map.
  - **Not done:**
    - No new Gen 9 organisations.
    - Earth makers have no post-war cards of their own; their post-war frames show up through the panel.
    - Boreal West and Boreal East was already in.

**Order of work**
1. **R1: merge Conflicts and NPPL Conflicts**, then Conflicts after the war (Step 7) in the merged tab.
2. Persons of Interest.
3. The final sweep. It includes the leftover "NPPL Gen 1–4" labels in the turning points of the NPPL Conflicts, Persons of Interest and Mysteries tabs.
4. **Supers** (once decision D is made).

One tab per publish, with check.js and a browser test each time.

## The standard (what "done" means for a tab)

1. **One scale.** These columns, with these labels, on every tab that has eras:

   | Gen | Label |
   |---|---|
   | 0 | Pre-mech, before 2161 |
   | 1 | 2161–2171 |
   | 2 | 2171–2178 |
   | 3 | 2178–2184 |
   | 4 | 2185–2186 |
   | 5 | The war, c. 2187–2190 |
   | 6 | c. 2190–2311 |
   | 7 | 2312 |
   | 8 | 2313–2326 |
   | 9 | 2327 |

2. **Every faction of 2327 appears after the war** wherever it plausibly has something: all 13 where it makes sense, and never only the five Earth powers.
3. **Production doesn't stop.**
   - Earth lines carry on after the war, with gaps of a generation or two and an offshoot or two, rather than one straight series.
   - Space factions use adapted Earth kit in Gen 6, start to diverge around the Martian crisis (Gen 7), and have makers of their own from Gen 6.
4. **A "Who … after the war" panel** above the tree: one row per faction, filtered in faction views. Collapsed by default once R2 is in.
5. **Linked both ways.** New entries link to the entries they use, and the reverse lists ("Frames using it", "Persons of interest" and so on) fill in automatically.
6. **Faction views work.** Entries are tagged by maker code or by an explicit `fx` list, so each faction's view shows its own material.
7. **Your rulings hold.**
   - Reactors are kept off Earth's battlefields.
   - Resources are plentiful after the war.
   - The lunar reactor monopoly is real but not total.
   - Beamed power is the UNEL's to give or withhold.
   - Fusion reaches ships long before frames.
   - Nothing supernatural.
   - Player material yields to the atlas.

## Restructure (added 2026-11-10)

Some tabs are getting crowded. These changes move material around rather than adding to it.

### R1. One Conflicts tab, Gen 0–9

Conflicts covers Gen 0–5 and NPPL Conflicts covers Gen 6–9, and Step 7 would have added post-war entries to Conflicts as well. The merge makes them one tab.

- **Columns:** Gen 0–9.
- **Bands by theatre:**
  - Africa & the Middle East;
  - Eurasian frontier;
  - Atlantic & the Americas;
  - Pacific;
  - Luna & the inner planets (absorbing the old "Orbit" band);
  - Mars;
  - the Belt;
  - Beyond the Belt.
- NPPL's "Earth" band splits into the Earth theatres, or stays as "Earth after the war" if that's simpler.
- **Ids stay as they are** (`w…` and `n…`), so no links break.
- **Code that assumes two tabs, all of which needs changing:**
  - **Map:** the world map draws Conflicts, and the inner-system map draws NPPL (`M.set`, `sysNodes`, the era buttons). After the merge it splits by column instead: Gen 0–5 on the world map, Gen 6–9 on the inner-system map. Gen 6–9 entries set on Earth, such as the Andean Collapse, need a decision: pin them on the world map, or list them under it.
  - **Timeline:** it builds its eras as `conflicts.cols + nppl.cols`. Point it at `GENS`.
  - **check.js:**
    - `NCH`;
    - the rule that SOLAR.eras matches the nppl columns;
    - the rule that every SOLAR.at entry is an nppl entry;
    - the rule that an ace's `cf` is in conflicts or nppl.
  - **Tab code:**
    - the Map, Factions and Successors buttons hang off whichever of nppl or conflicts exists;
    - the detail sheet's "Roots in the atlas" heading for nppl cards;
    - `SRC.nppl` ("Seen in No Peace Past Luna");
    - the faction-tag exclusions for conflicts, nppl and mysteries.
  - **Links:** old `#nppl` links go to `#conflicts`, the same way `#carriers` now goes to `#fleets`.
- **Step 7 shrinks.** The tab already has the Andean Collapse, the Line of Control, the Partisan Years, the Bastion, the Hidden Docks and the Greater Solar Crisis. Step 7 now adds only what's missing (see below).

### R2. Collapsible panels above each tree (done, version 114)

Before the tree starts, Frames shows the intro, the plate, 8 turning points and a 13-row "Who runs what" panel, about 4,600 characters in all. Every tab that reaches the standard gains a panel like that.

- **Turning points and the faction panel become collapsible sections, closed by default,** with the count in the summary ("Turning points · 8", "Who runs what · 13 factions").
- **Remember each viewer's open/closed choice** in localStorage, wrapped in try/catch.
- **In a faction view the panel opens by default,** since it's one row there.
- **Later, optional:** a faction view shows that faction's row from every tab on one page, so "what this faction runs" lives in the faction view, not on 9 tabs.

### Candidates still under discussion (not adopted)

- **Successors:** most of it now overlaps the 13 Factions lanes and the landing page's faction cards. It could become a "Factions of 2327" directory, or fold into the faction views.
- **The tab bar:** 18 flat tabs, with Map, Factions and Successors buried after NPPL. It could be grouped as Overview · Machines · Logistics · History · People.
- **Deep bands:** Vehicles and Fleets & Carriers have bands 16–19 rows deep, so split them before adding Gen 5–9 material.

## Remaining steps

### Step 3. Vehicles

- Carry the four bands from Gen 5 to Gen 9: the war's tanks and transports, then the reconstruction's vehicles, which run on cheap fuel from space.
- Add vehicles for the space factions:
  - Martian rovers and crawlers for Colony One and the MRD;
  - Belt tugs and cargo walkers for the Syndicate;
  - ice crawlers for the Communion;
  - grown or ammonia-fed transport for Umoja.
- Earth offshoots: civil and aid vehicles, and the Andean warlords' rebuilt hardware.
- Add a "Who drives what after the war" panel.

### Step 4. Carriers after the war (inside Fleets & Carriers)

The fold and the Gen 5 merge are done (see Status). What's left:
- **Post-war Earth carriers in the sea, land and air bands, Gen 6–9.** After the Mandate, reactor-lifted ships are banned from Earth's sky, so these are:
  - sea carriers;
  - ground-effect and airship frame transports;
  - orbital lift: shuttles and the Mongolian accelerator.
- **Pre-crisis space-faction tags on the old carrier cards, where they fit.** The `fx` rule above (US → co1 and cst, Union/CON → mrd, CHN → cps, EUR → chn, eas, cps and ash, EAS → eas and ash, AFC → umj, Exodus ships → com) was applied only to the old Fleets cards. Most Earth-bound carriers stay untagged. The likely ones are the orbital carriers and the ships that seed a faction: the Hospital Safina (Umoja), the Hearth (Communion) and the Hakobune (Ashva).
- **Extend the panel to cover carriers on Earth,** renamed "Who flies and carries what" or similar, rather than adding a second panel.

### Step 5. Supers

Needs decision D first.

- The war's giants: what happens to Takemikazuchi, Concord, the Jingwei, the Custodian, Roland and the Staya.
- After the war: who still keeps giants and under what rules. Candidates:
  - the Jingwei line under Tianshu;
  - the Custodian at the UNEL's Luna bastion;
  - giants the Ashva Compact hunts;
  - an MRD or Umoja giant of a new kind.
- Add a "Who keeps giants after the war" panel.

### Step 6. Organisations (done, version 114; see Status)

- Extend to Gen 9 with organisations from your game and from the new tabs:
  - the Solar Court;
  - Voidborne Security;
  - Albedo Industries;
  - the Lunar Vacuum Research Spire;
  - the Strategic Security Institute;
  - Colony One's Intelligence and Analysis Directorate;
  - the MRD's Innovation Bureau;
  - the Directorate of Unified Security;
  - the seven space-faction makers;
  - Boreal West and Boreal East;
  - the Hegemony, kept in shadow.
- Put space organisations on the inner-system map as pins, the way Earth organisations sit on the world map.
- Add an "Organisations after the war" panel.

### Step 7. Conflicts after the war (after R1)

These entries already exist, and stay:
- Gen 6: the Andean Collapse, the Spire's Vaults, the Hegemony, the Line of Control, the Syndicate's Belt, Settling the Dark, the Jupiter Settlements.
- Gen 8: the Two Wings, the Partisan Years, the Bastion, New Philadelphia, Two Thirds of Mars, the Hidden Docks.
- Gen 9: the Greater Solar Crisis.

Add only these:
- **Gen 6:**
  - the Mandate's first enforcement;
  - the eleven uses of the relay kill-switch;
  - the seal breaches ("every navy has done it once");
  - the Venus inspections the Ascendancy refused;
  - Saturn closing its door;
  - the pirate wars.
- **Gen 8:** the Weapons Resolution's signing.
- **Gen 9:** the opening positions only if the Greater Solar Crisis card can't carry them.

Place each entry on the map that matches its column.

### Step 8. Persons of Interest

- Extend to Gen 8–9: descendants, successors and the people who'll matter in 2327, about two per faction. Gen 7 already holds 38 of the 98 people, so the new ones should go in Gen 8–9.
- Give Umoja, the Ashva Compact and the Communion people of their own, linked to their new frames, makers and doctrine.

### Step 10. Final sweep

- Header, intros and turning points that still say "to 2186" or "Gen 4 prototypes".
- The leftover "NPPL Gen 1–4" labels.
- The check.js rule left over from Step 1.
- The faction-tag review list in docs/atlas-faction-tags-review.md, updated.
- A browser pass of every tab in every faction view.
- A last publish.
