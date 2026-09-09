# Language knowledge and progression

## Behavior

Each character starts with Common and their native racial language at 100%; other installed languages start at 0%. Imperial characters start with Common only. Speaking remains unrestricted. Incoming translations depend on persistent listener knowledge, not a random selection of words. When nothing can be understood, the addon does not add a duplicate all-foreign translation line.

The native baseline is recorded once. A later race change does not grant another free native language or erase the original knowledge. Translation display preferences remain account-wide. The legacy selected language is inherited once by each character/world's speaking preference, but does not grant proficiency in it.

The translation display toggle controls presentation only. Eligible exposure can still award experience while translations are hidden. Say, yell, incoming whisper, and party are eligible by default; zone/guild channels are not. Set `TamrielicTongues.ChatOutput.exposureChannels` to an explicit map of ESO channel constants to booleans to override the allowlist. Own-account echoes, customer-service messages, missing sender identities, and unsupported/unrecognized messages award nothing.

## Modules and invariants

| Module | Responsibility |
|---|---|
| `Core/CanonicalCatalog.lua` | Literal permanent concept IDs, English lemma/inflection aliases, fixed vocabulary and grammar requirements |
| `Languages/Shared/FrozenVocabulary.lua` | All 2,070 released authored/generated mappings with provenance |
| `Language/WordGenerator.lua` | Load/validate frozen released vocabulary; prototype generation for custom profiles |
| `Language/Analysis.lua` | Aligned original/decoded tokens, canonical identities, clause grammar, exposure fingerprint |
| `Core/Knowledge.lua` | Skill experience, mastery overrides, normalization, compatibility, snapshots, overall percentage |
| `Language/Comprehension.lua` | Pure deterministic rendering from a document and knowledge snapshot |
| `Core/Progression.lua` | Pure eligibility preview, capped exposure awards, curated study/practice awards |
| `Core/Proficiency.lua` | Character-store migration, native baseline, per-language state access |
| `Core/SavedVariables.lua` | ESO account/character storage wrappers and delayed player-readiness initialization |
| `Chat/Output.lua` | Detect, analyze, render from snapshot, award exposure, then optionally display |

Sender identity, timestamps, and random rolls never enter comprehension. Vocabulary decisions use canonical IDs and published thresholds. Repeated content can become clearer only after knowledge genuinely changes. Original punctuation, case, and markup are retained for display; they do not select different vocabulary thresholds.

Grammar is conservative: if any recognized clause-level construction is unknown, words in that clause stay in the fictional language. This avoids turning a negated or tense-qualified statement into a confident affirmative gloss. Constructions include negation, past/future, plural/progressive, questions, conditionals, conjunctions, contractions, subordination, and supported perfect forms. Both ASCII and typographic apostrophes are recognized for contraction analysis without modifying wire bytes.

This is a compatibility-first analyzer, not an unrestricted semantic parser. Aliases are explicit and context-free; for example, `saw` means `see`, while `left` retains the direction sense. Noun/verb homographs may share a concept. Unsupported morphology is not guessed. Punctuation that genuinely changes a recognized construction (such as a question) can change grammar gating, but never rerolls vocabulary knowledge.

Unknown vocabulary has a stable `oov:en:v1:<normalized spelling>` identity and retains the existing codec. It earns no automatic vocabulary XP. At full vocabulary proficiency it can be decoded; earlier explicit mastery is limited to catalog entries. Links and their labels are opaque to analysis/exposure. The existing ASCII-oriented codec/tokenizer limitations remain: this is not a Unicode lemmatizer.

## Knowledge and percentage

Each language record contains:

- `schemaVersion = 1`, `thresholdVersion = 1`;
- `vocabularyXP` and `grammarXP`, integers in `0..10000`;
- `progressEnabled`, a per-language boolean defaulting to `true`; missing legacy flags migrate to `true`, explicit `false` is preserved, and invalid flags fail closed;
- `masteredVocabulary` and `masteredGrammar`, permanent-ID boolean maps;
- optional `exposure`, the separately versioned persistent accounting state.

One skill level is 100 XP. `Knowledge:GetOverall(state)` derives a single integer percentage, defaulting to 70% vocabulary and 30% grammar. The weights are in `Knowledge.Config`. The percentage does not promise that the same percentage of every sentence is translated, and its denominator is not the number of catalog entries. Adding vocabulary does not reduce it.

Published requirements and IDs must not be reshuffled. Adding/removing catalog entries must not recalculate old thresholds. Balance future content with authored requirements; changing released thresholds requires an explicit threshold-version/migration policy. Explicit mastered IDs are retained even if a pack/catalog entry is temporarily unavailable. Unsupported future knowledge versions fail closed without rewriting the data.

Engine APIs:

- `Proficiency:GetState(languageId)` — live character record, or nil if unavailable/unsupported.
- `Proficiency:GetOverall(languageId)` — derived percentage, or nil.
- `Proficiency:IsSupported(languageId)` — whether character knowledge is available and supported.
- `Proficiency:GetProgressEnabled(languageId)` — boolean, or nil if unavailable.
- `Proficiency:SetProgressEnabled(languageId, enabled)` — requires a boolean; returns success or `false, reason`.
- `Proficiency:SetOverall(languageId, percent)` — requires an integer `0..100`; sets both XP axes to `percent * 100`, clears explicit mastery overrides, and preserves the progression flag and exposure history. Returns success or `false, reason`.
- `Knowledge:Snapshot(state)` — isolated rendering snapshot, intentionally excluding exposure accounting for supported state.
- `Knowledge:MasterVocabulary(state, conceptId)` / `MasterGrammar(state, constructionId)` — trusted explicit-learning hooks for registered identities.
- `Analysis:FromEncoded(profile, body)` — canonical document for the already-detected message body.
- `Comprehension:Render(document, snapshot)` — rendered text and count statistics; no learning side effects.

Do not persist only a rendering snapshot: persist the entire language record, including exposure protections.

## Player controls

The LibAddonMenu-2.0 settings panel (`/tt settings`) offers the account-wide speaking selection and per-character sliders/learning checkboxes for every registered reconstructed language. Common is available in the speaking dropdown but has no editable proficiency row. New registered languages receive controls automatically at initialization.

Disabling `progressEnabled` blocks eligibility preview, exposure, study, practice, direct XP grants, and mastery-learning hooks without mutating XP or exposure accounting. Existing knowledge still controls comprehension. Manual `SetOverall` is an intentional override and remains available while paused. Neither toggling nor manually adjusting proficiency clears cooldowns, daily budgets, or clock history. Lowering a slider clears mastery overrides so they cannot silently defeat the chosen level.

The panel refreshes from getters when opened and checks for changed visible values every 500 ms while open; its update is removed when closed. Unsupported or not-yet-initialized knowledge disables the corresponding controls. Actual ESO/LAM rendering still needs in-game validation.

## Progression and balancing

Defaults in `Progression.Config` are deliberately conservative and should be play-tested:

| Setting | Default |
|---|---:|
| Vocabulary/grammar XP per newly eligible unit | 1 |
| Combined XP per received message | 4 |
| Daily XP cap per axis, per language | 40 |
| Minimum distinct catalog vocabulary units | 2 |
| Per-unit cooldown, shared across senders | 1 hour |
| Canonical-content cooldown | 1 day |
| Active exposure-history capacity | 512 records |
| Maximum stored fingerprint size | 4,096 bytes |
| Study grant cap per registered activity | 20 XP |
| Practice grant cap per registered activity | 10 XP |
| Activity cooldown | 1 day |

Eligible grammar receives a reserved point/slot when possible so vocabulary-heavy sentences do not starve grammar progression. A single repeated word does not qualify as meaningful exposure. Vocabulary and grammar sets deduplicate repeated units. Sender rotation does not reset cooldowns. Conversation currently earns the same varied-content exposure as other eligible chat; there is no bonus merely for alternating speakers.

All learning paths share daily axis budgets. Study/practice additionally enforce activity cooldowns and caps. Expired records can be pruned, but active protections are never evicted to make room for new content. Reaching capacity denies additional untracked awards. Absolute time and a persisted high-water mark prevent reloads or backward clock movement from creating fresh budgets. Malformed/newer exposure data fails closed rather than resetting protections. Lowering history capacity below saved record counts requires a deliberate recovery/migration policy.

These rules make normal repetition inefficient; they cannot authenticate genuine roleplay or prevent local save/clock/code editing. Configure nonnegative integer grants/caps and valid cooldowns as trusted addon policy, not received message data. At the defaults, 100 XP per level and a 40 XP daily axis cap imply deliberately slow learning; tune rates after roleplay testing.

### Curated study and practice integration

No book/tutor/exercise UI or content pack is introduced here. Other trusted modules can register lessons or exercises, then award them only after actual completion. Definitions contain catalog ID maps with their exact requirements and fixed XP grants. They are copied and validated at registration; duplicate IDs and arbitrary unknown units are rejected.

```lua
local TT = TamrielicTongues
local word = TT.CanonicalCatalog:Resolve("guard")
TT.Progression:RegisterLesson("lesson:guard-basics:v1", {
    vocabulary = { [word.id] = word.requirement },
    grammar = { plural = TT.CanonicalCatalog.GrammarRequirements.plural },
    vocabularyXP = 15,
    grammarXP = 5,
})
-- Call only when the lesson is completed, not just on receiving chat text:
-- TT.Proficiency:Study("dunmeri", "lesson:guard-basics:v1", GetTimeStamp())
```

`RegisterExercise` and `Proficiency:Practice` follow the same pattern with the practice cap. Registration must occur again after UI reload; progression/cooldowns remain saved. XP improves the relevant axes; immediate mastery of a particular unit is a separate trusted `Knowledge:Master*` operation, not implied by arbitrary chat or by registration alone.

## Persistence and migration

Translation display preferences retain their existing `NewAccountWide` scope. Speaking language uses `TT.characterPreferences`, created with `ZO_SavedVars:NewCharacterIdSettings` in namespace `Preferences` and `GetWorldName()` as profile. Empty defaults allow a missing `activeLanguage` to inherit `TT.saved.activeLanguage` once, falling back to `DEFAULT_LANGUAGE_ID`/Common. Existing selections (including explicit Common and absent-pack IDs) and unknown fields are preserved. The legacy account value is neither updated nor deleted, so other characters can still migrate; new accounts no longer default that legacy field. Settings and outgoing chat use only character preferences; unavailable preferences read as Common and setters fail safely without writing account data.

Character knowledge uses `ZO_SavedVars:NewCharacterIdSettings` in the **same declared SavedVariables global**, namespace `Proficiency`, with the world name as profile. ESO supplies the account and stable character ID; a character rename does not create new progression or speaking preferences. The separate `Preferences` namespace leaves the `Proficiency` schema, including unsupported future versions, untouched. The existing wrapper version stays at 1 so account settings are not reset.

Migration from an existing installation is additive and idempotent: create the new character store, record the native baseline once, and initialize missing language records. Preserve explicit false preferences, unknown fields, absent-pack records, and existing exposure history. There was no old knowledge data to infer from selected-language preferences. Future store/schema versions are left untouched and disable this client's progression/comprehension for that data. Unsupported individual knowledge records are likewise preserved but unused.

If the player race is not yet available during addon loading, initialization waits for `EVENT_PLAYER_ACTIVATED`. Until knowledge is ready, the original foreign chat line remains visible but no comprehension or learning is attempted.

## Wire compatibility and future language work

The v1 zero-width marker, permanent language IDs, existing codecs, and source-preserving word order are unchanged. `Translator:Encode`/`Decode` remain full codec operations, independent of proficiency; `/tt test` remains a full round-trip diagnostic. Knowledge is local and is not sent in chat.

Frozen mappings are indexed by the existing v1 source forms to preserve their historical bytes. Canonical lemma IDs relate those forms for knowledge/analysis; they do not silently replace v1 inflected spellings with new generated words. Released forms are validated against the frozen data. New canonical recognition can reuse an existing fallback spelling without changing transmission (for example `never`).

Before publishing new target vocabulary or real word-order/grammar transformations, add an explicit version-dispatched decoder and historical fixtures. Changing `profile.version` alone is not a migration. Keep v1 decoding available and never replace a frozen mapping or recycle a concept/language ID. Prototype/custom profiles retain the generator, but their generated vocabulary must be frozen before release if permanent-mapping guarantees are required.

## Tests

From the addon root, using Lua 5.1 or later:

- `lua Tests/Canonical.lua`
- `lua Tests/Comprehension.lua`
- `lua Tests/Progression.lua`
- `lua Tests/ProficiencyIntegration.lua`
- `lua Tests/ProgressionControls.lua`
- `lua Tests/Settings.lua`

Also run the existing wire, capitalization, and localization suites. Tests cover historical mapping fixtures, catalog expansion/reorder stability, inflections, grammar thresholds, repeated content, unknown-word spam, cooldown/cap persistence, backward clocks, character/world isolation, migrations, and pre-award rendering. ESO storage/event APIs are mocked in integration tests; actual in-game timing, storage, chat routing, and transport still require verification.
