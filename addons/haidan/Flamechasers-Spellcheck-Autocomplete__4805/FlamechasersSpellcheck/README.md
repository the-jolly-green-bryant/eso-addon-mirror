# Flamechasers Spellcheck & Autocomplete v0.7.6

**Spellcheck and predictive text, built directly into ESO chat.**

Type faster, catch typos before you send them, and get suggestions that actually understand Tamriel.

Flamechasers Spellcheck & Autocomplete adds real-time spell checking and smart predictive word suggestions directly to Elder Scrolls Online's normal keyboard chat input. It keeps ESO's native chat box intact rather than replacing it.

**AI-assisted development disclosure:** This addon was developed with AI assistance, then reviewed and tested in game.

**Required libraries:** LibCustomMenu 7.3.0+ and LibAddonMenu-2.0 r43+.

## Why use it?

- **Catch typos while you type.** Misspelled words get subtle wave underlines before you send the message.
- **Fix mistakes without fighting the chat box.** Right-click a marked word for corrections, Add to Dictionary, or Ignore for this session.
- **Get three live word suggestions.** TAB accepts the selected suggestion and CTRL navigates the available choices while chat is open.
- **Use SUPER Suggestions.** The default prediction mode uses more surrounding context, local personalization, recent vocabulary, and optional temporary conversation context.
- **It knows Tamriel.** ESO-specific vocabulary covers classes, skills, item sets, locations, activities, combat terminology, crafting/systems, characters, factions, and lore.
- **Make it yours.** Customize the suggestion bar, floating rounded-box style, fonts, colors, opacity, dividers, underline appearance, and personal dictionary.
- **Keep everything local.** There is no telemetry, advertising, network access, external executable, or cloud prediction service.
- **Safety-aware suggestions.** A lightweight last-mile gate avoids proactively completing clearly risky real-world instruction/transaction contexts, with extra contextual care around self-harm and exploitation involving minors, while leaving normal discussion, ESO vocabulary, and anything you manually type untouched.
- **Use it alongside pChat.** Compatibility is built around the interaction paths used by this addon without replacing ESO's protected message-submission path.

## SUPER Suggestions

**SUPER** is the default prediction mode.

It uses up to the previous three words, learns four-word phrase patterns from messages you actually send, remembers recent vocabulary during the current play session, and can temporarily use recent conversation context to make suggestions more relevant to what your group or guild is talking about.

Your own long-term personalization is stored locally in ESO's SavedVariables. Other players' messages used for optional conversation context are kept only in memory for the current play session and are never written to SavedVariables.

Prefer something lighter? **Normal** provides the lower-processing-cost prediction path while still using dictionaries, word frequency, short context, typo tolerance, personal history, and learned corrections.

## It knows Tamriel

Generic spellcheckers tend to treat half of ESO as a typo. This addon has a dedicated ESO vocabulary system with configurable categories for:

- General ESO terms and classes
- Skills and skill lines
- Item sets and Mythics
- Zones, cities, locations, and wayshrines
- Dungeons, trials, arenas, and other activities
- Combat terminology
- Systems, crafting, Scribing, and Champion Points
- Characters, factions, and lore

The addon can also learn supported names from the currently installed ESO client during the session, allowing its ESO vocabulary to stay useful beyond the curated built-in seed data.

If the predictor feels too eager to suggest obscure ESO names, individual ESO categories can be disabled without affecting your Personal Dictionary or your own learned phrases.

## Features

- Real-time wave underlines for misspelled words without replacing ESO's native chat EditBox.
- Right-click corrections, Add to Dictionary, and Ignore for this session.
- Three live predictive suggestions.
- Default context-aware SUPER mode and more lightweight Normal mode.
- TAB accepts the selected suggestion and CTRL navigates suggestions while chat is open.
- Optional native addon keybinds in addition to the default TAB/CTRL controls.
- Prediction bar and floating rounded-box UI styles.
- Configurable height, fonts, colors, opacity, dividers, and underline appearance.
- Personal Dictionary with an editable saved-word list.
- Independent English and ESO dictionary switches.
- Fine-grained ESO dictionary category switches.
- Runtime ESO vocabulary discovery for supported current-client data.
- Optional local personalization from messages you actually send and accepted suggestions/corrections.
- Optional session-only recent-chat context in SUPER mode.
- pChat compatibility for the interaction paths used by the addon.
- Always-on suggestion safety for autocomplete and correction candidates, combining a very small severe-abuse denylist with contextual checks for risky real-world facilitation, self-harm, and sexual/exploitative contexts involving minors.

## Usage

Open **Settings > Addons > Flamechasers Spellcheck & Autocomplete** or choose **Spellcheck Settings** from the chat cog menu.

Slash commands:

- `/fspell add <word>`
- `/fspell remove <word>`
- `/fspell status`

Custom suggestion keybinds appear under the **Flamechasers** keybind category. TAB and CTRL remain active defaults while the chat input is open even when custom keybinds are assigned.

## Suggestion safety

Autocomplete and right-click correction candidates pass through a small dedicated safety layer before they are shown. The layer is deliberately separate from the English/ESO dictionaries because a legitimate dictionary tells us whether something is a word, not whether proactively offering that completion makes sense in the current context.

Most sensitive vocabulary is **not** globally blacklisted. Instead, the addon uses a bounded local context and a **risk-delta check**: it evaluates the text as typed, then evaluates the hypothetical text with the candidate inserted. A candidate is suppressed only when that completion creates or extends a high-risk state. This keeps neutral words available even inside sensitive discussions instead of blanking the whole prediction bar.

The safety taxonomy separates general illicit facilitation, direct interpersonal threats, self-harm, and sexual/exploitative contexts involving minors. Self-harm and child-safety checks have the highest priority and cannot be bypassed merely because an ESO/game word is nearby. Reporting, prevention, support, news/discussion, and ordinary ESO gameplay remain usable, but protective/game words are not universal exemptions. A very small exact-token denylist is reserved for severe abusive terms the addon should never proactively volunteer.

The safety gate is always on and is intentionally separate from the prediction model. It does not alter learning, candidate scoring, frequency ranking, or typed text. In addition, the prediction bar has a conservative hard denylist for categories the addon should never proactively volunteer (including under-18 identifiers, suicide/self-harm terms, severe slurs, and selected high-specificity criminal/exploitative terms). That hard list applies only to predictive autocomplete: it does not change spell checking or right-click correction candidates. The addon also never submits a chat message automatically: suggestions are optional, the player chooses whether to accept them, and ESO's native Enter/submission path remains in control. No safety system can guarantee that every possible completion is harmless, so users should still review messages before sending them.

## SavedVariables and privacy

Preferences, Personal Dictionary entries, and the personal writing model are intentionally account-wide and shared across megaservers because they are language/preferences data rather than server-specific game state.

The addon has no telemetry, advertising, network access, external executable, or realtime external-service integration. Other-player chat used for optional SUPER context exists only in memory for the current session.

## Compatibility and implementation notes

- The addon keeps ESO's original keyboard chat EditBox and does not replace or hook the Enter/`SubmitTextEntry`/`SendChatMessage` submission path.
- TAB handling uses a pre-hook on ESO's standalone chat-tab helper only when the addon has a usable prediction and native autocomplete is not active.
- The lightweight 16 ms input/caret poller is registered only while keyboard chat input is open. It unregisters completely after the chat closes and wakes through a secure post-hook on ESO's normal `StartTextEntry` path.
- Runtime ESO lexicon APIs use current documented API interfaces directly rather than speculative existence checks or default fallbacks.
- Addon-owned shared state is contained under the single global `FlamechasersSpellcheck` namespace; individual source files use a local `FSC` reference.
- The public-facing rebrand intentionally does not rename the addon folder, namespace, SavedVariables, or slash command, preserving update compatibility for existing installations.

## Credits and licenses

- English dictionary data is derived from SCOWL; its license/credits are included under `Licenses/`.
- Frequency data provenance and license information are included under `Licenses/`.
- Symmetric-delete candidate recall is inspired by Wolf Garbe's SymSpell approach. The implementation here is original Lua adapted to ESO.
- Predictive-text research included AOSP LatinIME, Presage, KenLM, FlorisBoard, and related offline-keyboard approaches. No source from those projects is bundled verbatim; research notes are included under `Licenses/`.
- ESO vocabulary research sources and attribution notes are included under `Licenses/`.

## Changelog

### v0.7.6 — idle-path cleanup and punctuation normalization

- Made the chat-input enhancement layer fully inactive when both spell checking and typing suggestions are disabled: ESO's native EditBox layout is restored and the 16 ms active-input poll is stopped immediately.
- Scoped global mouse callbacks to active keyboard-chat sessions instead of keeping them registered throughout normal gameplay.
- Added transparent support for typographic apostrophes (`’` / `‘`) in English contractions and prediction context. Pasted text such as `don’t`, `I’m`, and `you’re` is normalized internally without changing the user's visible text or byte-index mapping.
- Reused the already-cached misspelling scan for the right-click caret fallback instead of rescanning the same input text.

### v0.7.5 — integration audit and multilingual/performance polish

- Fixed accented/non-ASCII words being partially tokenized as English fragments (for example, `café` being treated as `caf`). Mixed-language words are now left untouched instead of producing partial underlines, partial learned tokens, or polluted SUPER context.
- Bounded the right-click correction-result cache to prevent distinct typo/context combinations from accumulating indefinitely during long sessions.
- Cached dictionary-state signatures between real dictionary/runtime-vocabulary changes, reducing repeated category/revision scans across spellcheck and prediction requests.
- Cached per-candidate contextual safety decisions within each prediction/correction request so the same word arriving from multiple candidate sources is classified only once.
- Reduced redundant autocomplete UI work by avoiding repeated label writes and only bringing the prediction bar to the top when it transitions from hidden to visible.
- Updated implementation notes to reflect the current 16 ms lightweight input poll and cleaned up release-facing AI disclosure wording.

### v0.7.4 — underline rendering polish

- Fixed long runs of spaces before a misspelled word being included in that word's underline. Prefix measurement now preserves trailing whitespace accurately instead of relying on label widths that can omit trailing spaces.
- Added a deletion-only live underline refresh lane so held Backspace/Delete removes and resizes misspelling waves continuously instead of waiting for key repeat to stop. The heavier autocomplete/full-layout refresh remains coalesced, preserving the v0.7.3 typing-path optimizations.
- Capped the live deletion refresh to normal-sized chat input so unusually large pChat copy buffers cannot turn held deletion into a high-frequency full spellcheck scan.

### v0.7.3 — input responsiveness and typing-path optimization

- Split caret/viewport tracking from heavier spellcheck and prediction rendering. The native EditBox now follows typing/caret movement on a lightweight 16 ms input poll while underlines and prediction UI refresh separately.
- Added incremental prefix-width caching for the widened native EditBox. Appending/editing text reuses unchanged character-position measurements instead of repeatedly remeasuring every earlier underline/caret prefix.
- Cached misspelling scans while the text itself is unchanged, avoiding full spellcheck rescans during cursor-only movement and repeated layout refreshes.
- Added bounded dictionary membership/frequency caches, so previously seen words and prediction candidates no longer re-walk every enabled dictionary pack on each keystroke.
- Avoided redundant native EditBox re-anchoring/dimension writes when the calculated scroll geometry has not changed.
- Avoided rebuilding underline tile geometry when an underline's width/position is unchanged.
- Cached the contextual safety layer's pre-completion risk state within each prediction request; safety behavior is unchanged, but sensitive-context candidate checks do less repeated work.

### v0.7.2 — selection viewport polish

- Fixed completed mouse-drag selections in horizontally overflowed chat input snapping the viewport back to the far caret endpoint after mouse release. The viewport now remains where the drag ended while that exact selection is intact, then normal caret-follow scrolling resumes as soon as the user changes the selection, caret, or text.

### v0.7.1 — release-readiness cleanup and public rebrand

- Added an always-on contextual suggestion-safety layer for predictive autocomplete and right-click corrections, then upgraded it to risk-delta evaluation: the addon compares context before/after a proposed completion and suppresses only candidates that create or extend high-risk illicit facilitation, direct threats, self-harm, or sexual/exploitative contexts involving minors. Neutral discussion, supportive/reporting language, and ordinary ESO gameplay remain usable.
- Added a separate prediction-bar-only hard denylist for under-18 identifiers, suicide/self-harm terminology, severe slurs, sexual exploitation terms, and selected high-specificity criminal/cybercrime/drug vocabulary. It does not affect spell checking or right-click corrections.
- Rebranded the public-facing addon name to **Flamechasers Spellcheck & Autocomplete** to better represent both core features while preserving all internal identifiers for update compatibility.
- Updated the manifest description and README around the product's three main strengths: typo correction, predictive text, and ESO-aware vocabulary.
- Made SUPER the default prediction mode for new installs and Reset to Defaults.
- Renamed the user-facing Standard mode to Normal and clarified that it is the more lightweight option.
- Removed permanent idle chat polling; the 30 ms UI poller now exists only while keyboard chat input is open.
- Hardened pChat long-copy compatibility so temporary chat-length overrides preserve ESO's true native limit and always restore correctly across repeated copy actions, shorter replacement text, and chat close.
- Optimized right-click correction generation so runtime ESO vocabulary is indexed while it is learned and correction clicks inspect compact candidate buckets instead of occasionally doing broad setup/scans on the interaction frame.
- Added horizontal edge-scrolling while click-drag selecting overflowed chat input, allowing selection to continue through text that is currently clipped outside the visible input area.
- Kept the convenience space after accepting an autocomplete suggestion, but automatically removes only that generated space when the next typed character is attaching punctuation such as `.`, `,`, `!`, `?`, `;`, or `:`.
- Removed obsolete internal function-existence fallbacks that are guaranteed by the addon's manifest/load order.
- Removed the generic `/fsc` slash alias to avoid unnecessary command namespace collisions; `/fspell` remains.
- Cached the sorted dictionary registry list and invalidate it only when dictionary packs register.
- Preserved prediction/correction results in regression tests against v0.6.4.
- Updated package metadata to v0.7.1 / AddOnVersion 701.

### v0.6.4 — code-quality and ESOUI compliance pass

- Consolidated addon-owned globals into one namespace and removed obsolete LibStub/defensive API-fallback patterns.
- Rechecked the runtime ESO collector against current documented APIs and fixed current-map location harvesting.
- Centralized SavedVariables/settings defaults and reduced redundant runtime work.

### v0.6.3 — ESO dictionary categories

- Added category-level switches for the ESO dictionary and category-aware runtime harvesting/filtering.

### v0.6.2 — expanded ESO vocabulary

- Expanded curated ESO terminology and added memory-only vocabulary discovery from the installed ESO client.

### v0.6.1 — modular dictionaries

- Added independent English/ESO dictionary switches and the central dictionary registry.

### v0.6.0 — SUPER Suggestions

- Added the optional heavier context-aware prediction engine, bounded local four-gram learning, recency context, and session-only recent-chat context.

## ZeniMax disclosure

This Add-on is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its affiliates. The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. All rights reserved.
