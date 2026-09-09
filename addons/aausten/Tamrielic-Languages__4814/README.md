# Tamrielic Tongues v1.5.0

Tamrielic Tongues is an Elder Scrolls Online role-playing addon that lets players speak nine reconstructed Tamrielic language profiles in ordinary ESO chat. Players without the addon see the constructed-language text. Players with the addon see the original foreign-language line and, when their character understands enough, a deterministic partial Tamrielic/Common translation beneath it.

## Languages included

- Ta'agra — Khajiit
- Jel — Argonian
- Dunmeri — Dunmer
- Altmeris — Altmer
- Bosmeri — Bosmer
- Nordic — Nord
- Orcish — Orc
- Yoku — Redguard
- Bretic — Breton
- Tamrielic/Common — passthrough

## Commands

- `/lang <language>` — choose the language you speak.
- `/lang common` — stop transforming outgoing messages.
- `/lang` — show current language.
- `/tt languages` — list language IDs.
- `/tt translations on|off` — enable/disable incoming local translations.
- `/tt test <language> <message>` — encode and decode locally without sending chat.
- `/tt status` — show current settings.
- `/tt settings` — open the language and proficiency settings panel.
- `/tt help` — command help.

Race names are aliases, so `/lang khajiit`, `/lang argonian`, `/lang dunmer`, etc. also work.

## Character proficiency

Common and the character's native language start at 100%; other languages start at 0%. Understanding depends on persistent vocabulary and grammar knowledge—not random word reveals. Repeating a sentence with unchanged knowledge produces the same gaps. Unsupported grammar keeps its clause in the fictional language rather than creating a misleading gloss.

Varied eligible chat provides small, capped gains. Repeated content and vocabulary share cooldowns across senders and UI reloads. Hiding translations does not stop eligible learning; speaking remains unrestricted. Translation display preferences remain account-wide; speaking language and knowledge are saved separately per character and world. Previously selecting a language does not grant mastery.

Open **Settings → Addons → Tamrielic Tongues**, or use `/tt settings`. The speaking-language dropdown and `/lang` change only this character's selection on the current world. On first use, a missing character selection inherits the legacy account language once (or defaults to Common). Later changes, including explicit Common, survive reloads and renames without affecting other characters. The legacy account value is retained only for characters that have not migrated yet. Each reconstructed language has a **0–100% proficiency slider** and an **Enable progression** checkbox saved for the current character and world. Common remains passthrough and has no editable row; the native language is editable.

Progression is enabled by default. Unchecking it pauses exposure, study, practice, and explicit mastery learning for that language without changing comprehension or erasing cooldowns and daily budgets. Manual slider changes still work while paused: they set vocabulary and grammar to the chosen level and clear explicit mastery overrides, while preserving all learning history. Reenabling progression does not reset anti-spam protections. Controls are disabled while character knowledge is unavailable or its saved version is unsupported.

See [the proficiency architecture, migration policy, APIs, and balancing guide](PROFICIENCY.md). No book/tutor content pack is included. The existing language encoding remains source-preserving and compatible with v1.

## How it works

The addon does **not** encrypt messages. Each language pack supplies:

- a stable phonological profile;
- a compact semantic lexicon for common RP words;
- deterministic fallback encoding for arbitrary ASCII words;
- reversible inflection markers for simple `-s`, `-ed`, and `-ing` forms;
- a permanent numeric language ID carried by a trailing zero-width Unicode marker;
- legacy sentence signatures retained for reading messages from older addon versions.

Unknown ASCII words are transformed using a language-specific reversible digraph codec, so there is no finite vocabulary ceiling. Common RP words use stable generated lexemes, making repeated vocabulary recognizable. New messages contain no spoken signature prefix or color-code identifier: the language identifier is a zero-width suffix.

### Language identification protocol

The suffix contains exactly **24 zero-width Unicode characters**: U+200B (ZERO WIDTH SPACE) represents bit `0`, and U+200C (ZERO WIDTH NON-JOINER) represents bit `1`. Read most-significant bit first, the payload contains an 8-bit `0xD7` protocol identifier, a 4-bit version, and a 12-bit language ID. This retains room for **4,095 assigned languages** plus reserved ID `0`, rather than limiting expansion to six bits.

Version `1` uses the current version-1 language data. For example, Ta'agra's payload is `D71001` in hexadecimal, serialized entirely as zero-width characters—not those visible digits or ESO markup. The suffix works with single-word messages and adds **72 UTF-8 bytes**. The existing conservative byte-based outgoing length check includes all 72 bytes; zero-width does not mean zero cost against message limits. Common remains unmarked passthrough.

| Language | Permanent ID (decimal) | Version-1 payload (hex) |
|---|---:|---|
| Ta'agra | 1 | `D71001` |
| Jel | 2 | `D71002` |
| Dunmeri | 3 | `D71003` |
| Altmeris | 4 | `D71004` |
| Bosmeri | 5 | `D71005` |
| Nordic | 6 | `D71006` |
| Orcish | 7 | `D71007` |
| Yoku | 8 | `D71008` |
| Bretic | 9 | `D71009` |

`Core/LanguageRegistry.lua` owns the authoritative `WireIds` assignments. Each language profile declares its matching `wireId`; registration rejects missing, conflicting, duplicate, or out-of-range IDs before updating the registry. IDs `1..4095` are available; `0` is reserved. Never renumber or reuse an assignment, including retired languages. Display names, locale changes, load order, and future UI colors must not affect these IDs.

To add a language, allocate a new permanent ID centrally and use it in the new profile. For example, decimal ID `10` produces `D7100A` under protocol version 1. Third-party pack authors must coordinate assignments rather than independently choosing IDs. Legacy `signatures` are optional for new packs; existing packs keep theirs for backward decoding.

`Core/Versioning.lua` defines protocol compatibility: `(wire version 1, language ID)` currently selects that language's version-1 data. Do not reuse the same pair with an incompatible codec or vocabulary. Such a change needs an explicit version/decoder migration; simply incrementing a profile's `version` makes it unsupported until compatibility is implemented. UI-only updates do not require a protocol change.

Only the exact trailing 24-character binary marker with the expected protocol identifier is recognized. Truncated, malformed, or nonterminal markers are not normalized or guessed. Detection strips the suffix from the decoding input, not from the original chat event; existing zero-width characters in the body are preserved. Unknown IDs/versions are not decoded, and syntactically valid marked messages are forwarded without re-encoding. The marker is identification, not authentication, and `D7` is not an ESO-reserved namespace.

**Compatibility:** This version still reads original spoken signature-prefixed messages. Color-code marker generation and detection have been removed completely after tags appeared literally in actual addon-sent chat. Older addon versions cannot automatically translate the new zero-width messages; recipients must update. No SavedVariables migration is needed. If another tool strips or changes the suffix, automatic detection can be lost. Although zero-width transmission was reported working in manual testing, the exact U+200B/U+200C sequence still needs end-to-end addon verification across relevant channels, pChat, fonts/narration, and a recipient without this addon.

### Capitalization

The English pronoun `I` is translated with an initial capital at a sentence start, but lowercase within a sentence (including contractions such as `I'll`). Sentence starts are detected at message start and after `.`, `!`, `?`, or a line break; this is a punctuation heuristic, not a full parser for abbreviations or quoted speech. Other words retain the existing case handling so proper names and deliberate uppercase emphasis are not globally lowercased.

Decoding restores the English pronoun to `I`. Consequently, a deliberately lowercase source `i` also decodes as `I`; exact case round-tripping is not preserved for that pronoun.

## Chat integration

Outgoing messages are transformed in ESO's existing chat submit flow immediately before the game's protected chat-send call. The user still presses Enter and ESO performs the protected action normally.

Incoming messages are observed through `EVENT_CHAT_MESSAGE_CHANNEL`. Tamrielic Tongues does not replace the chat message formatter; it adds the decoded translation as a separate system line. This design is intentionally conservative around pChat and other chat-formatting addons.

## Lore / reconstruction policy

The nine profiles are **role-playing reconstructions**, not claims that Bethesda/ZeniMax published nine complete usable grammars. Language data in this release is marked internally as Tamrielic Tongues reconstruction. The architecture keeps lexicon and language behavior in separate language packs so later releases can add verified canonical vocabulary with explicit provenance.

## v1 limitations

- The reversible fallback codec transforms ASCII `A-Z` words. Non-ASCII letters are preserved unchanged.
- v1 intentionally preserves source sentence order. The Grammar layer is versioned and ready for future language-specific transformations, but reliability takes priority over speculative grammar in 1.0.
- Very long source messages can expand beyond ESO's chat input limit. In that case the addon refuses the transformed send and leaves the original input available for shortening.
- ESO item/link markup, valid color tags, resets, and escaped pipes are preserved rather than translated.
- Invisible markers remain present in raw text, copied messages, and logs unless those tools strip them; stripping the marker prevents automatic language detection.

## Installation

Install **LibAddonMenu-2.0** (required, available through Minion or ESOUI), then extract the `TamrielicTongues` folder into your ESO AddOns directory. Enable both addons, reload the UI, and run `/tt settings` or `/tt languages`.

Manifest API versions for this build: **101050 101051**. Confirm compatibility in-game before releasing; these declarations are not a substitute for testing.

## Localization

The addon interface currently ships in **English**. Other client languages fall back to English until translations are contributed. Interface localization does not translate player messages into another real-world language or change the reconstructed-language codecs.

`Locale/Localization.lua` wraps ESO's `ZO_CreateStringId`, `SafeAddString`, `GetString`, and `zo_strformat`. `Locale/en.lua` defines all default strings under the `SI_TAMRIELIC_TONGUES_` prefix. Commands, help, status, errors, startup text, translation labels, and language/race display names use these strings. Developer assertions and internal language data are intentionally not localized.

To add a translation, create a UTF-8 file such as `Locale/de.lua`:

```lua
local TT = TamrielicTongues

TT.Locale:Register("de", {
    COMMON_NAME = "Tamrielisch (Gemeinsprache)",
    NOW_SPEAKING = "Du sprichst jetzt: <<1>>.",
}, 1)
```

List the file explicitly in `TamrielicTongues.txt` immediately after `Locale/en.lua`, before the other addon modules. `Register` checks the client's `GetCVar("language.2")`, so only matching overrides apply. English defaults must load first; omitted translations retain those defaults. Increment the override version when updating translations. Only English defaults create string IDs; translations replace them with `SafeAddString`.

- Use the keys in `Locale/en.lua`; new keys need an English default first.
- Preserve numbered placeholders such as `<<1>>`; reorder them as needed for the target language.
- Do not translate slash commands, subcommands (`common`, `on`, `off`, etc.), internal language IDs, aliases, signatures, or codec/lexicon data. Localized display names are separate from accepted command aliases.
- Keep user-visible text in the locale files rather than concatenating translated sentence fragments.

Run the isolated tests from the addon root with Lua 5.1 or later:

- `lua Tests/WireProtocol.lua` — permanent IDs, marker/legacy detection, markup, round trips, registration validation, and chat size limits.
- `lua Tests/Capitalization.lua` — all-language capitalization and the existing round-trip smoke tests.
- `lua Tests/Localization.lua` — localization fallback and command output.
- `lua Tests/Canonical.lua` — frozen vocabulary, permanent identities, morphology, grammar analysis, and expansion stability.
- `lua Tests/Comprehension.lua` — pure knowledge checks and deterministic grammar-aware rendering.
- `lua Tests/Progression.lua` — canonical cooldowns, caps, bounded history, and study/practice APIs.
- `lua Tests/ProficiencyIntegration.lua` — character migration, persistence, native baselines, and incoming-chat behavior.
- `lua Tests/ProgressionControls.lua` — paused learning, manual levels, migration, and retained cooldowns.
- `lua Tests/Settings.lua` — mocked settings controls, language isolation, readiness, refresh, and panel commands.

The localization tests mock ESO's numbered string formatting and API lifecycle, not the complete ESO client. Verify translated formatting and chat behavior in-game as well.

## Release checklist

See [ESOUI's release rules and best practices](https://www.esoui.com/forums/showthread.php?t=10790).

- LibAddonMenu-2.0 is required for the settings interface and is installed separately, not bundled. pChat is optional; its manifest entry provides load ordering, not a verified compatibility guarantee. If a minimum version becomes necessary, use its tested `AddOnVersion` with `>=` rather than inventing a version requirement.
- Translation display preferences remain account-wide across characters and servers. Speaking language (`Preferences`) and proficiency (`Proficiency`) use separate namespaces scoped by world, account, and stable character ID. Follow the documented migrations; do not reset the SavedVariables wrapper version.
- Exclude hidden files/folders (`.git`, `.lua`, `.luarc.json`, editor settings) and development tests from the release ZIP. Editor declarations must never be included in the addon manifest.
- Check `/script d(GetAPIVersion())` and test both advertised API versions. Test chat submission with and without pChat, command-prefix addons, and filtered chat tabs. Translations are system messages: they do not inherit the original channel's routing, sender label, or addon suppression, and deferred output is not guaranteed to stay adjacent during busy chat.
- Check `/lang` and `/tt` for collisions with other installed addons; registrations currently overwrite existing handlers for those aliases.
- Review ESOUI/ZOS prohibited-functionality rules, credits/licensing, and the final archive before uploading. Put release notes in the site's Changelog tab and configure whether patches are allowed.
- Follow the thread's AI disclosure rule: disclosure at the beginning of the addon description is required for AI-generated code the author cannot personally verify as correct, efficient, maintainable, and safe. This repository's automated checks do not establish in-game safety or replace that review.

## Lua development in Zed

Install/enable Zed's Lua extension and open the `TamrielicTongues` folder as the project root. Lua Language Server (LuaLS) reads the root `.luarc.json`, which selects Lua 5.1 and adds `.lua/eso` to its definition libraries. If the configuration is not picked up immediately, run **editor: restart language server** from Zed's command palette.

`.lua/eso/api.lua` contains editor-only `---@meta` declarations for the ESO globals currently used by this addon. These provide completion, hover information, and type checking without disabling `undefined-global` diagnostics. ESO supplies the real implementations at runtime; **do not add these declaration files to `TamrielicTongues.txt` or load them from tests**.

This is a small, hand-maintained API subset, not a complete ESO SDK. When using additional ESO APIs, extend the declarations using the current ESO API documentation/UI source, or replace the subset with a compatible, maintained LuaLS/EmmyLua definition library. Add that library's local directory to `workspace.library` in `.luarc.json`; avoid loading overlapping definition sets. Raw ESO UI source can also help with navigation, but does not by itself declare every engine-provided global.

No Zed-specific settings or changes to the addon's runtime code are required.
