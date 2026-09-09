# Changelog

## 1.5.0

- Made the spoken language character/world-specific in a separate `Preferences` SavedVariables namespace. Each missing selection inherits the legacy account language once (otherwise Common); explicit Common, reloads, and character renames retain the selection. The legacy value remains available for other characters to migrate.
- Translation display preferences remain account-wide. The speaking-language migration preserves proficiency data and its namespace/schema; the SavedVariables wrapper version remains unchanged.
- Added speaking-language isolation/migration regression coverage and updated settings scope labels and documentation.

- Added a LibAddonMenu-2.0 settings panel (`/tt settings`) with a speaking-language dropdown and character-specific proficiency sliders and progression checkboxes; LibAddonMenu-2.0 is now required.
- Added persistent per-language learning toggles covering exposure, study, practice, XP grants, and mastery. Missing flags default to enabled without resetting saved data.
- Manual proficiency adjustments set both knowledge axes and clear explicit mastery overrides while retaining learning cooldowns, budgets, and the progression toggle.
- Added progression-control and mocked settings-panel regression tests.

- Added permanent canonical vocabulary identities, supported lemma/inflection analysis, and fixed vocabulary/grammar requirements.
- Froze all 2,070 released vocabulary mappings without changing v1 wire messages.
- Added deterministic partial comprehension with conservative clause-level grammar gating and separate vocabulary/grammar knowledge.
- Added character/world-specific progression with Common/native mastery, additive migration, and preserved account preferences.
- Added bounded canonical exposure cooldowns, daily caps, clock-rollback protection, and curated study/practice APIs.
- Integrated pre-award comprehension into incoming chat; hidden translations can still earn eligible exposure, and outgoing speaking remains unrestricted.
- Added canonical, comprehension, progression, and persistence/chat integration regression suites; documented API and balancing limits in `PROFICIENCY.md`.

## 1.1.0

- Replaced outgoing spoken language signatures with versioned 24-character zero-width Unicode markers, using permanent language IDs 1–9 and allowing future assignments through 4095.
- Removed the unsuccessful color-code marker implementation entirely; trailing pipes no longer prevent sending.
- Retained legacy signature decoding; older clients must update to decode the new suffix-only messages.
- Added marker/ID validation, unsupported-version forwarding protection, color-markup preservation, and wire-protocol regression tests.

- Fixed single-letter capitals such as `I` and `A` producing all-uppercase lexicon words in all nine languages; intentional multi-letter uppercase emphasis is preserved.
- Made translated `I` sentence-aware: lowercase within sentences, title case at sentence starts, with English `I` restored on decoding.

- Added ESO string-ID localization with English defaults, client-language overrides, and reorderable placeholders.
- Centralized player-facing text and expanded command help; localized display names remain separate from chat encoding and command IDs.
- Added localization regression tests, translator instructions, and an ESOUI release checklist.

## 1.0.0

- Initial release.
- Added nine playable-race language profiles: Ta'agra, Jel, Dunmeri, Altmeris, Bosmeri, Nordic, Orcish, Yoku, and Bretic.
- Added deterministic unlimited fallback vocabulary for ASCII words.
- Added shared RP lexicon generation and language-specific reconstructed overrides.
- Added reversible plural, past, and progressive morphology for known roots.
- Added natural-looking per-language/version message signatures.
- Added outgoing ESO chat transformation without directly invoking protected `SendChatMessage`.
- Added incoming translation through `EVENT_CHAT_MESSAGE_CHANNEL` without replacing the chat formatter.
- Added account-wide SavedVariables and slash commands.
- Added local round-trip test command.
