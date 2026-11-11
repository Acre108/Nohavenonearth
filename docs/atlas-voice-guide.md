# Atlas voice guide

How card text in the No Haven on Earth Atlas should read. Written 2026-11-11 from the user's own blog posts (Drive folder "Blog") and their review of the cards.

## Base voice

The user writes plain, considered British prose:

- Open on context, then say what happened. Don't hold a fact back to reveal it at the end.
- Let sentences build up clauses when the thought needs it. Not everything has to be short.
- Use a spaced hyphen ( - ) for an aside now and then. Never use an em dash.
- Hedge where a real person would: "probably", "it's worth saying", "for the most part".
- Use British idiom lightly ("take a crack at", "the hard yards").
- When a card does end on a turn, make it warm or rhetorical, not a sardonic one-liner. The blog's "That is something, that is real" is the model: a refrain the writing has built up to.

Things to avoid:

- **The kicker:** a short, ironic or poignant closing sentence ("The grievance doesn't.", "His cousins never write.").
- Balanced inversions ("Washington set the terms; Ottawa paid them.").
- Absolutes used for drama ("nobody", "never", "every") where the fact doesn't need them.
- Standalone fragments as sentences ("Six weeks to train a pilot.").
- Making every card the same density. Some cards should be loose and chatty, others short and dry.

## Ending mix

Each card gets an ending type from a hash of its id (see `tags.js`, regenerated per session):

| Code | Ending | Share |
|---|---|---|
| P | Ends on a plain fact | 3 in 8 |
| L | Allowed to run long; ends wherever the account ends | 2 in 8 |
| O | Ends open, on a detail or consequence, without comment | 1 in 8 |
| K | Can keep or add a turn, if the turn is the content | 2 in 8 |

The hash is a nudge, not a rule. If the turn is the point of the card (wE10, Tianshu naming Moscow), keep it whatever the code says.

## Faction voices

A card's voice comes from its faction tags, the same tags the faction views use: the entry's `fx` list, else its maker's factions, else the most common set in its family. When a card has several tags, the id hash picks one. Cards from before the war take the voice of the faction they lead to: a 2170 Union card reads like the TAU. Untagged cards use the archivist voice.

| Tag | Voice |
|---|---|
| usa | Procurement and after-action plainness: confident, numbers, plants, the Army. Sometimes homestead plain-spoken. |
| tau | Committee and conditions. Long, careful sentences with subordinate clauses, a little dry about process, lists of cities across the Union. |
| chn | Measured and scheduled. Things happen when planned. Tianshu is described precisely; the depot floor is practical. |
| eas | Hard, people-first pragmatism. Says what a choice cost and who paid. |
| afc | Communal and oral. "They say"; migrations; lists of peoples and towns; warm. |
| unl | Recorded and legal: dates, logs, witness language, exact wording. Rarely ends on a turn. |
| co1 | Frontier. Short, practical sentences about survival. The one voice where terseness is native. |
| cst | Civic and earnest. Charter language, longer sentences, a belief in process. |
| mrd | Scientific and curious. Careful hedges, the data, preservation. |
| cps | Mercantile. Ledgers, prices, deals; wry, but about money rather than fate. |
| umj | Kin and care. Collective, grown and kept things, bodies as something tended. |
| ash | Oaths and pairs; heroic. The voice most allowed refrains and turns. |
| com | Devotional and patient. Slow, long sentences with a liturgical cadence. |
| none | Archivist: neutral and explanatory. |

## Unchanged

A voice pass never changes facts, names, dates, ids, links or redaction bars (█).
