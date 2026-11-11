# Atlas style guide

How text in the No Haven on Earth Atlas should read: tree cards, line-end notes, ace cards, Timeline beats, Successors cards and art captions. Read this before you write or edit any atlas text.

It is based on the user's own writing (Drive folder "Blog": https://drive.google.com/drive/folders/1d82jTpqmpP-I0j6_bMg4y2Pd-_Pi_xnb) and their review of the cards on 2026-11-11. Their verdict was that the cards read as overwrought. Too many short introductory cards ended on a "profound revelation", and making things concise had become a goal in itself.

## 1. Base voice

Everything in the atlas starts from the user's voice. The faction tones in section 4 adjust it; they don't replace it.

The user writes plain, considered British prose:

- **Context first.** Say where and when, then what happened. Don't hold a fact back to reveal it at the end.
- **Sentences that build.** Clauses accumulate when the thought needs them. A long sentence is fine if it reads cleanly aloud.
- **Varied density.** Some cards are loose and chatty, some are short and dry. Next to each other, two cards shouldn't sound like the same machine wrote them.
- **The occasional aside.** A spaced hyphen ( - ) now and then, at most once per card and in a minority of cards. Never use an em dash; the apply script rejects them.
- **Honest hedging.** "Probably", "for the most part", "it isn't clear that", where a real chronicler would be unsure.
- **Light British idiom.** "Take a crack at", "the hard yards", "rather more interested". British spelling.
- **Warm turns, when there is a turn.** The user's blog builds to a refrain ("That is something, that is real"). It earns that line; it doesn't snap shut on an ironic one-liner.

## 2. What to avoid

These are the habits that make the atlas read as machine-written. Each is fine once in a while; the trouble comes from repeating them card after card.

| Habit | Before | After |
|---|---|---|
| Kicker ending | …posted to every Union colony and ship. The movement breaks. The grievance doesn't. | …posted to every Union colony and ship. The movement breaks up, though support for it in the border towns never really goes away. |
| Withheld reveal | Ascension's report blamed a solar flare. There was no flare. | Ascension's report blamed a solar flare, although no observatory recorded one that week. |
| Balanced inversion | Washington called it a procedural matter. Strasbourg sent a delegation the same week. | Washington described it as a procedural matter; Strasbourg, rather more interested, had a delegation in Ottawa within the week. |
| "They call it X. We call it Y." | The old guard call it a retreat. She calls it the next phase. | The old guard call it a retreat, and she has spent years in committee arguing that it is the next phase of the Union rather than the end of one. |
| Absolutes for drama | Nobody flies a reactor over Earth again. | …and no one tries flying a reactor over Earth again. |
| Poignant non-sequitur | His American cousins never write. | Within a few years of leaving he has lost touch with his relatives on Earth. |
| Fragment as sentence | Six weeks to train a pilot. | (Fold it into a sentence, or leave it if the card is a dry spec card.) |
| Aphorism closer | …and so did the habit: Beijing builds, the Syndicate flies. | (Cut it. The card has already shown this.) |
| Echoed kicker | Two Silla cards both ending "…who do not write" / "…never write" | Never reuse a closing beat across cards. |

**When the turn is the content, keep it.** Some cards exist for their ending: wE10 ("Moscow's is that Beijing kept asking"), the Darkhan Kurultai ("Each half says the other sold the horse"), the Weapons Resolution ("They are still working them out"), py3 Kiprotich ("he lived to see strength win, and let it"). Test it by deleting the last sentence: if the card loses its point, the turn stays.

## 3. Ending mix

Across a tab, aim for roughly:

| Code | Ending | Share |
|---|---|---|
| P | Ends on a plain fact | 3 in 8 |
| L | Runs long and ends where the account ends | 2 in 8 |
| O | Ends open, on a detail or consequence, without comment | 1 in 8 |
| K | Keeps or adds a turn, if the turn is the content | 2 in 8 |

`tools/voice-tags.js` assigns each card a code from a hash of its id, so the mix is stable between sessions. The code is a nudge, not a rule.

## 4. Faction tones

A card's tone comes from its faction tags, the same tags the faction views use: the entry's `fx` list, else its maker's factions (`FACTION_VIEWS.makers`), else the most common set in its family. If a card has several tags, the id hash picks one. Cards from before the war take the tone of the faction they lead to, so a 2170 Union card reads like the TAU and a League card like the Commonwealth. Untagged cards use the archivist tone.

Keep the tone light. It should colour the card, not turn it into pastiche. Someone reading the Union tab should feel committee rooms without the text turning into minutes.

### United States of the Americas (usa)
- **Tone:** confident and institutional: procurement, after-action reports, plants and production runs, the Army and the Navy. Sometimes homestead plain-speaking.
- **Rhythm:** medium sentences, numbers welcome, little hedging.
- **Turns:** dry, about money or bureaucracy ("the two companies' lobbyists wrote most of its renewals").
- **Example:** "His reports are frank about that staff, and he reckons he can trust about half of them."

### Transatlantic Union (tau)
- **Tone:** committees, conditions, councils and leases. Careful, a little dry about its own process. Lists cities across the Union (Lisbon, Warsaw, Montreal).
- **Rhythm:** the longest sentences in the atlas, with subordinate clauses and qualifications.
- **Turns:** rare; when they come, they're about process ("which has never agreed on anything quickly, agreed in nine days").
- **Example:** "Washington described it as a procedural matter; Strasbourg, rather more interested, had a delegation in Ottawa within the week."

### China (chn)
- **Tone:** measured and scheduled. Things happen when they were planned. Tianshu is described precisely, as a system, never as a villain. The depot floor is practical.
- **Rhythm:** even and orderly, with few asides.
- **Turns:** understatement ("which is unusual on a frigate of its class").
- **Example:** "None of the earlier builds has been deleted, and the councils have never given a reason for keeping them."

### Eurasian Ascendancy (eas)
- **Tone:** hard, people-first pragmatism. Says what a choice cost and who paid for it. Plain about uncomfortable things.
- **Rhythm:** blunt, with medium-length sentences.
- **Turns:** a cost stated flatly ("The rest are too many to move, and Luna is inclined to protect its own").
- **Example:** "He has cousins in the Ashva Compact, and his orders are not to contact them."

### African Commonwealth (afc)
- **Tone:** communal and oral. "People like to point out", "they say". Migrations, assemblies, lists of peoples and towns. Warm.
- **Rhythm:** sentences that gather people and places as they go.
- **Turns:** told as something people repeat, not as an authorial verdict.
- **Example:** "People on Eros like to point out that her frigate's hospital bay has treated more Union sailors than Commonwealth ones."

### United Nations of Earth and Luna (unl)
- **Tone:** recorded and legal: dates, logs, registers, exact wording, witness language. Neutral, even about itself.
- **Rhythm:** precise, with some passive voice ("is recorded", "goes into a register").
- **Turns:** rarely; the record speaks. A dry procedural joke is allowed ("Every year he is told the matter is under review").
- **Example:** "…she asks anyway and logs whatever answer she gets."

### Colony One (co1)
- **Tone:** frontier. Survival, repair, rationing, grudges. The one tone where terseness comes naturally.
- **Rhythm:** short, practical sentences. Fragments are acceptable here.
- **Turns:** stated as necessity ("Colony One needs port engineers").
- **Example:** "Washington has had a file open on him for years without getting much further than his name."

### Constitutionalists (cst)
- **Tone:** civic and earnest. Charter language, clauses, rulings, a belief in process and in law covering everyone.
- **Rhythm:** long and deliberate, like an argument made in good faith.
- **Turns:** hopeful rather than ironic.
- **Example:** "She is an altered American citizen, and the charter is the first law that has ever covered her."

### Martian Research Directorate (mrd)
- **Tone:** scientific and curious. Careful hedges, data, preservation, panels and conditions.
- **Rhythm:** measured, with qualifications where a scientist would put them.
- **Turns:** quiet and factual ("though no one has ever actually signed anything that draws it").
- **Example:** "Ana has always thought him slow, though the fleet's engineers are generally glad that he is."

### Celestial Prosperity Syndicate (cps)
- **Tone:** mercantile: ledgers, prices, contracts, termination clauses. Wry, but about money, never about fate.
- **Rhythm:** brisk and transactional.
- **Turns:** a trader's joke ("like any sensible trader they read the termination clauses first").
- **Example:** "The houses are making so much money that they've started to think they don't need Beijing, which has quietly made sure it can still see what they're doing."

### Umoja (umj)
- **Tone:** kin and care. Bodies as something tended, grown and kept. Collective, never clinical. The keepers' words ("care", "what is grown is cared for") carry weight.
- **Rhythm:** organic and generous, but not sentimental.
- **Turns:** allowed, especially where the keepers' language returns.
- **Example:** "The Ashva watch every landing, and Baraka, who sees no reason to be unfriendly about it, waves at them."

### Ashva Compact (ash)
- **Tone:** oaths, sworn pairs, rides and akharas. The heroic register, and the tone most allowed refrains and epic turns.
- **Rhythm:** narrative, like a story retold in the veche.
- **Turns:** the most of any faction, but still not on every card. Open questions suit them ("the akharas still argue about it").
- **Example:** "Both sides still tell the story, each as proof of what it already believed."

### Communion (com)
- **Tone:** devotional and patient. Cold, dark, light and watches. Liturgical cadence.
- **Rhythm:** slow, with long sentences and repetition that feels like ritual.
- **Turns:** reverent rather than clever.
- **Example:** "His grandmother is still on watch somewhere further out in the dark, and in all the long years of her watch she has been woken only four times."

### Untagged (archivist)
- **Tone:** neutral and explanatory, the atlas speaking as itself.

## 5. Field notes

- **`t` taglines:** short sentence-case phrases, no full stop ("Licensed Garrison, lightened for air drops"). Keep them literal.
- **`z` line-end notes:** "When · what happens" ("War's end · the Lunar Mandate bans reactor-lifted ships from Earth's sky"). They are notes, so no kickers.
- **`x` text:** the main card. Everything above applies.
- **Mysteries:** end on a real question. That question is the one place a deliberate closing beat always belongs. Keep them unanswered.
- **Redacted cards:** never change, move or add █ bars in a voice pass (the apply script checks this). Text around the bars may be rewritten.
- **People:** fictional characters keep their established pronouns. Never kill or change a 2312 player character.
- **ACES notes, CHRONO beats, Successors seeds, SCENES captions:** same rules. Captions stay short.

## 6. What a voice pass never changes

Facts, names, dates, ids, links, numbers or redaction bars. If a rewrite seems to need a new fact, leave the line as it is and raise it with the user.

## 7. Doing a voice pass

Scripts are in `docs/atlas/tools/`:

1. `node tools/voice-tags.js atlas-data.json [tab] [out.json]` tags every card with a faction tone and an ending code.
2. `node tools/voice-show.js atlas-data.json <tab> [from] [count] [cards.json]` prints cards with their codes for review.
3. Write the rewrites as `{"<id>": {"x": "…", "z": "…"}}` and run `node tools/voice-apply.js atlas-data.json edits.json`. It edits each node's own line in place, keeping the hand-kept layout, and refuses to write if a bar changed or an em dash appeared.
4. Run `node tools/check.js mech-lineage-atlas.html`, diff against the live artifact, publish, commit.

Work tab by tab. Status:

| Tab | Done |
|---|---|
| Persons of Interest | v125 |
| Conflicts | v125 |
| Organisations | v126 |
| Mysteries, Frames, Weapons, Power, Doctrine, Vehicles, Fleets & Carriers, Supers | not yet |
| ACES, CHRONO, POWERS/SPACE/UNEL, TIMELINE, SCENES/PLATES captions, MINOR | not yet |
