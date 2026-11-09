# Rulebook

The tabletop rulebook is four shared documents. Edit and comment there; this folder only records
where they are and what each holds.

| Document | Where | Holds |
| --- | --- | --- |
| [Player's Guide](https://docs.google.com/document/d/1IJHlpCCz_T-9L6Z7k2ux4K3wROiuft49nsZz6LCm01M/edit) | Google Docs, folder [No Haven on Earth rulebook](https://drive.google.com/drive/folders/1WIApERf1fvwqp844R9hmJnBT_7x8gbCX) | Discord play, core roll and task checks, pilot creation and advancement, the full d10 combat rules, withdrawal, ejection and injury, downtime, worked examples |
| [GM's Guide](https://docs.google.com/document/d/1DqaFQos1aCRWHzvH7wA33z5-6HcIQCQinnzR1Kt0pQw/edit) | Same folder | Bot and GM responsibilities, running a session, building a fight, the Gen 1 playtest squads, support units and aircraft, enemy pilots, rulings, pay and lethality, playtest checklist and open questions |
| [Frames and Weapons](https://docs.google.com/spreadsheets/d/1-5qpooUhSsjcMrzQWp6DiSxTNM7Y1OZav0AaZKeT00E/edit) | Google Sheets, same folder | Every frame, weapon and Protocol number, with the IDs, Protocol lists and tags the bot reads (exported by `tabletop/sheet_export.py`). A Budgets tab holds the point weights, generation bounds, Brace table and frame roles; the Frames and Weapons tabs cost each item with live formulas and flag anything over budget, off-role or past its generation's limits |
| [Roleplaying Setting](https://claude.ai/artifact/HB7KWRg65YqgNZuMqdv6sT) | Claude Docs | The setting book (powers, organisations, machines, supers, characters, places, running the game) and the Frames tab's stat blocks for every frame |

Frame and weapon numbers are kept out of the docs. Since 30 October they come from the Frames and
Weapons sheet, which was built from generation budgets and roles rather than from the game's data;
`standard.json` and the setting's Frames tab still hold the older numbers. The
[Combat Sandbox](https://claude.ai/artifact/JgqktsdJAv71A8j6XkpviL) was brought up to the sheet's
numbers and the current rules on 9 November, except for secret orders and the Declare step.
[tabletop-d10-system.md](../tabletop-d10-system.md) is the rules draft the Player's Guide was
written from; new rules go into the Google Docs first.

Rules marked **Proposed** in the guides were added on 30 October and have not been played yet:
pilot grades, advancement, help and long tasks, withdrawal, ejection and injury, repair costs and
contract pay.
