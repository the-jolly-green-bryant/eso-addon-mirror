# Changelog

## 0.8.16
- Removed the unused search-icon visibility and color options from the appearance workshop.
- Removed the nonfunctional magnifying-glass control and reclaimed its reserved spacing so search text uses the full field cleanly.
- Preserved every other setting, theme, font option, and mechanics entry unchanged.

## 0.8.15
- Shortened the settings action labels so they remain fully visible across ESO UI scales and resolutions.
- Added five complete dark color presets: Dusk Lilac, Blood Moon, Tidal Teal, Silver Mist, and Sunset Copper.
- Added Chat / Locale and Latin-only Futura Medium font choices plus Thin Outline and regular Outline text effects, using ESO's own current client font aliases.
- Gave every new preset its own coordinated surfaces, text hierarchy, controls, fields, mechanic cards, borders, and artwork tint while retaining readable contrast.
- Preserved all existing themes, settings, mechanics data, notes, and layout behavior unchanged.

## 0.8.14
- Completed a pre-release audit of addon lifecycle, SavedVariables migration, navigation state, notes, scrolling, artwork recovery, settings, manifests, bindings, and all 52 activity datasets.
- Made every non-default preset define all 79 color roles explicitly, removing inherited blue-gray text and status colors from Midnight Violet, Moonlit Sapphire, Ember, and Verdant.
- Rebuilt High Contrast as a fully explicit palette covering every surface and every idle, hover, pressed, selected, focused, and disabled state.
- Kept Rose Velvet's approved neutral-charcoal, blush, dusty-rose, champagne, and sage balance unchanged.
- Added an appearance schema migration that refreshes selected built-in presets with the polished palettes while preserving individually customized colors.
- Made the settings preset selector switch to Custom immediately after any individual color edit.
- Hardened byte-limited chat splitting and label shortening so accented names and multibyte punctuation can never be cut inside a UTF-8 character.
- Updated the keybind label to the activity-neutral Flamechasers Codex name and synchronized all release version metadata.
- Preserved the complete mechanics dataset unchanged.

## 0.8.13
- Rebalanced Rose Velvet around neutral charcoal and restrained plum surfaces so the full window is no longer washed in one pink hue.
- Split the theme into blush major titles, soft mauve section headings, dusty-rose selections and borders, champagne mechanic emphasis, neutral reading text, and muted sage status cues.
- Removed the remaining cool blue tint from Rose Velvet boss metadata, chevrons, and secondary controls.
- Added an independent Section Headings color setting for Activities, Bosses, Personal Notes, Mechanics, and their glyphs.
- Added a safe schema migration that refreshes the revised built-in Rose Velvet palette while preserving individually customized palettes; older custom palettes initially inherit their chosen title color for the new section-heading role.

## 0.8.12
- Rebuilt Midnight Violet as a complete palette: backgrounds, buttons, selectors, fields, rules, mechanic cards, and paste controls now follow the violet theme instead of retaining cyan and gold defaults.
- Added Rose Velvet, a restrained dusty-pink and plum theme without neon tones.
- Added Classic ESO, using warm charcoal, aged parchment, bronze, and gold colors while staying within the existing appearance system.
- Added Moonlit Sapphire, a deep navy, muted blue, and soft silver-lavender theme.
- Expanded Ember and Verdant so their interactive controls, mechanic accents, search/note fields, hint frames, and splash tints now match their palettes throughout.
- Added a safe appearance migration that refreshes shipped presets to their complete v0.8.12 palettes while preserving every individually customized palette.
- Renamed the mechanic color controls so non-gold theme accents are described accurately.

## 0.8.11
- Darkened the default splash artwork one final step for a more subdued header background.
- Default artwork visibility is now approximately 14-34% from left to right.
- Preserved the non-stacking independent shade layer, so repeated activity selection still cannot accumulate darkness.

## 0.8.10
- Darkened the default splash artwork again for a more subdued header image.
- Default artwork visibility is now approximately 22-42% from left to right.
- Preserved the non-stacking independent shade layer, so repeated activity selection still cannot accumulate darkness.

## 0.8.9
- Darkened the default splash artwork another step for stronger readability behind the summary text.
- Default artwork visibility is now approximately 30-50% from left to right.
- Preserved the non-stacking independent shade layer, so repeated activity selection still cannot accumulate darkness.

## 0.8.8
- Darkened the default splash artwork one more step while keeping the image clearly visible.
- Default artwork visibility is now approximately 40-60% from left to right.
- Preserved the non-stacking independent shade layer, so repeated activity selection still cannot accumulate darkness.

## 0.8.7
- Darkened the default splash artwork slightly for better text readability.
- Default artwork visibility is now approximately 45-65% from left to right.
- Preserved the non-stacking independent shade layer, so repeated activity selection cannot progressively darken the image.

## 0.8.6
- Reduced the default splash-art shade from near-black to a balanced readability veil.
- Keeps approximately 48-68% of the image visible across the summary at the default intensity.
- Preserved the independent shade layer so activity changes cannot accumulate darkness on reusable textures.
- Retained live artwork intensity and left/right tint customization with clearer setting descriptions.
- Added shade-strength and repeated-navigation regressions while preserving every mechanics dataset unchanged.

## 0.8.5
- Removed all gradient and tint operations from the reusable activity DDS controls.
- Fixed artwork becoming black after returning to a previously viewed activity, including Bal Sunnar to Bedlam Veil to Bal Sunnar.
- Rebuilt the readability tint as a permanent 32-segment shade layer that never changes during activity navigation.
- Preserved the existing left/right tint, artwork intensity, and panel-color customization through the independent shade layer.
- Added repeated same-row and 20-cycle round-trip regressions that verify activity textures remain neutral and shading is never reapplied.
- Preserved all 52 artwork mappings, texture recovery, settings, notes, and mechanics datasets unchanged.

## 0.8.4
- Fixed splash artwork becoming progressively darker when the selected activity was clicked repeatedly.
- Made artwork shading idempotent so ordinary selections and UI refreshes cannot reapply the same gradient.
- Explicitly clears the previous ESO vertex gradient before applying a genuinely changed tint or intensity setting.
- Added a 40-click regression for the exact reported selected-row reproduction.
- Preserved the resilient texture loader, all 52 artwork mappings, settings, notes, and mechanics datasets unchanged.

## 0.8.3
- Replaced the splash-art control with a resilient two-buffer loader modeled on ESO's own dynamic background handling.
- Fixed selected activity artwork disappearing when its list row was clicked again.
- Made repeated selection a true no-op while the current texture is healthy.
- Detects an evicted or stalled texture and reloads it into the spare buffer instead of trusting stale Lua state.
- Keeps the current artwork available during ordinary texture transitions and never leaves unrelated artwork behind after a stalled request.
- Added bounded recovery attempts for ESO's asynchronous large-texture loader.
- Preserved all 52 verified artwork mappings, settings, notes, and mechanics datasets unchanged.

## 0.8.2
- Fixed activity splash artwork intermittently failing to appear or disappearing after extended browsing.
- Added explicit verified ESO client artwork mappings for all 34 dungeons, 14 trials, and four arenas.
- Removed the current activity catalog's dependency on Activity Finder initialization timing.
- Prevented incomplete Finder lookups and missing artwork from being cached permanently.
- Added explicit release handling for large loading-screen textures when switching activities, hiding artwork, or closing the Codex.
- Kept runtime artwork discovery as a retryable fallback for future dungeon modules.
- Preserved the settings cog, appearance workshop, personal notes, and all mechanics datasets unchanged.

## 0.8.1
- Added a settings cog immediately beside the close button in the Codex header.
- Reused the proven Travel Slots header-action structure: matched transparent hit targets with independently centered icon textures.
- Anchored the cog directly to the close control so both icons remain aligned at every supported UI scale.
- Added a small Codex-owned Settings hover hint that stays above the addon window.
- Safely closes the Codex before opening its LibAddonMenu panel without disrupting cursor ownership or unsaved boss notes.
- Extended live header-icon color customization to the new cog.
- Kept all dungeon, trial, and arena mechanics datasets unchanged.

## 0.8.0
- Added a full LibAddonMenu appearance workshop with live updates and no `/reloadui` requirement.
- Preserved the complete v0.7.2 interface as the exact default Flamechasers theme.
- Added Flamechasers, Midnight Violet, Ember, Verdant, and High Contrast color presets.
- Added individual RGBA controls for every major surface, text tier, list state, button state, selector state, mechanic-card element, field, divider, hint, and splash-art tint.
- Added independent Body, Heading, and Navigation font families using verified ESO client fonts.
- Added safe-range controls for body, list, boss-row, section, activity-title, boss-title, compact-label, and hover-hint sizes.
- Added configurable text effects, window scale, position locking, activity-row height, mechanic-card spacing, splash-art intensity, and optional UI-element visibility.
- Added separate Restore Typography, Restore Layout, Restore Colors, Restore All, and Center Window actions.
- Added `/dmcsettings` and `/dmcs` shortcuts to open the settings panel directly.
- Added automatic migration and validation for appearance SavedVariables while preserving notes, difficulty, and window position.
- Coalesced rapid setting changes into a single frame update to keep sliders and color pickers responsive.
- Added LibAddonMenu-2.0 as the sole required library; it is referenced as an external dependency and is not bundled.
- Kept all 34 dungeon, 14 trial, and four arena mechanics datasets unchanged.

## 0.7.2
- Replaced shared Trial and Arena category backgrounds with the selected instance's own built-in Veteran loading-screen artwork.
- Added explicit client texture mappings for all 14 trials and all four arenas in the Codex.
- Added load-screen-specific cropping so the wide summary banner is filled without stretching the artwork.
- Prevented unsupported future Trials or Arenas from silently showing unrelated category or chapter artwork.
- Kept all mechanics datasets unchanged.

## 0.7.1
- Fixed missing summary artwork for trials and arenas.
- Expanded artwork discovery to ESO's complete live Activity Finder category range.
- Added keyboard, gamepad, and Zone Story artwork fallbacks so valid instances do not render a blank summary panel when one source omits a texture.
- Kept dungeon artwork behavior and all mechanics datasets unchanged.

## 0.7.0
- Added complete Veteran datasets for Dragonstar Arena, Blackrose Prison, Maelstrom Arena, and Vateshran Hollows.
- Added an Arenas collection with automatic zone detection and selection.
- Added capability-aware controls: group arenas keep every role view, solo arenas show Full and Quick only, and arena-only Veteran mode removes the inapplicable Hard Mode selector.
- Added all ten Dragonstar stages, all five Blackrose stages, all nine Maelstrom stages, and all seven main plus three secret Vateshran bosses.
- Replaced shared ESO paste tooltips with a smaller Codex-owned hint that always draws above the addon window.
- Extended the safe compact hint to the Veteran and Hard Mode selectors.
- Expanded Activity Finder splash artwork across the entire activity-summary panel.
- Increased the boss navigation capacity and added a compact five-row layout for ten-encounter activities.
- Preserved Veteran/Hard Mode note separation for dungeons and trials; arena notes use their supported Veteran slot.

## 0.6.3
- Added subtle Activity Finder splash artwork to the selected activity summary without bundling extra image assets.
- Made all five role-view segments genuinely equal-width.
- Added a quiet `PASTE` label to clarify the numbered activity-summary clipboard controls.
- Replaced the generic result count with collection-aware Dungeon, Trial, and search-result counts.
- Refined the search placeholder for name, DLC, and chapter discovery.
- Added capability-aware activity registry groundwork so future arenas can declare only the difficulties and role views they actually support.
- Preserved every dungeon and trial mechanics dataset unchanged.

## 0.6.2
- Audited all 34 Hard Mode DLC dungeon modules against established encounter guides and official achievement records.
- Corrected Bedlam Veil's Crushing Shards guidance to warn that dodge-rolling the heavy enrages the Shattered Champion.
- Corrected Stonekeeper's Hard Mode skeevaton transition to around 55% while preserving the separate regular-Veteran 50% route.
- Added exact Hard Mode thresholds for Domihaus Grovel, Quarrymaster Saldezaar's Wrathful Rupture, and Matriarch Lladi's poison storms.
- Added Domihaus's reduced Hard Mode pillar count and Baron Zaudrus's fire-wall and rock-wave counts.
- Corrected Bar-Sakka's Vile Maw guidance to require blocking the hit and promptly purging its severe bleed.
- Preserved the regular-Veteran overlays, all trial datasets, personal notes, UI behavior, and automatic activity detection.

## 0.6.1
- Audited all 34 regular-Veteran DLC dungeon modules and all 14 Veteran/Hard Mode trial modules against official achievement data and established encounter guides.
- Corrected Balorgh's Veteran shadow-hunt, Dire Wolf, Strangler, and charge-trail difficulty split.
- Separated Dreadsail Reef's brand pairing, dome interrupts, tank debuffs, Hard-Mode spikes, twin kill window, and Taleria wave targeting.
- Corrected Sanity's Edge Ice Cage, Manic Phobia, ritual maze, Poisoned Mind, and Sunburst/Wrack behavior by difficulty.
- Corrected Lucent Citadel Arcane Knot timing, Splintered Passage lockouts, Defense Prisms, and Xoryn mirror-beam targeting.
- Rebuilt the Kyne's Aegis Falgravn entry around its real wall chains, resurrection exile, Sanguine Prisons, Ichor Eruption, prisoner teams, floor transitions, and Apostheosis pressure.
- Corrected Ossein Cage Carrion Shield handling, Titan Heat Rays and Reflective Scales, Kazpian tank mechanics, Biting Blaze, Torturous Chains, and Agonizer bomb isolation.
- Preserved all user notes, UI behavior, and activity detection logic.

## 0.6.0
- Added complete Veteran and Hard Mode datasets for all 14 currently released trials, from Aetherian Archive through Ossein Cage.
- Added 58 trial encounter entries covering main bosses, named minibosses, optional bosses, and assignment-heavy gauntlets.
- Added a saved Dungeon/Trial activity selector and unified search/count presentation.
- Added automatic current-trial detection and selection using the trial zone ID.
- Added ESO's classic trial icon beside selected trial names while preserving the dungeon icon for dungeons.
- Kept personal boss notes independent for Veteran and Hard Mode across both dungeons and trials.
- Prevented a search with no match in the other collection from leaving stale cross-tab activity details visible.
- Preserved the existing 34-dungeon dataset and all v0.5.5 behavior.

## 0.5.5
- Removed the auto-detected dungeon diamond from the dungeon list entirely.
- The auto-detected dungeon is now identified only by its green styling, with the dungeon name made bold for a cleaner, less cluttered look.
- Restored identical left alignment for detected and normal dungeon rows.

## 0.5.4
- Fixed the auto-detected dungeon row marker overlap by moving the diamond back to the original left-gutter position and reserving extra text space only on the detected row.
- Kept the detected dungeon name green exactly as before when it is not the manually selected row.
- Kept the redundant non-clickable detected-dungeon line above the list removed.

## 0.5.3
- Restored the original green current-dungeon styling and diamond marker appearance in the dungeon list.
- Nudged only the current-dungeon diamond position for cleaner alignment without changing the row styling.
- Removed the redundant unclickable auto-detected dungeon name above the list and reclaimed that space for the dungeon list.

## 0.5.2
- Repositioned the current-dungeon auto-detect diamond inside the left dungeon list so it sits properly centered in the row instead of reading too high or too cramped.
- Swapped the marker glyph to a cleaner centered diamond and added a bit more text padding so the current row reads more cleanly.

## 0.5.1
- Separated personal boss notes by difficulty, so Veteran and Hard Mode now keep independent note text for the same boss.
- Migrated existing shared notes into the Hard Mode slot, preserving the pre-VET note data while letting Veteran notes start independently.
- Added the active difficulty to the Personal Notes heading so it is always clear which note is being edited.
- Rebuilt the automatic-dungeon indicator as centered UI elements in both the detection row and dungeon list, fixing the slightly off alignment and keeping the current-dungeon diamond consistently green.

## 0.5.0
- Added a complete Veteran-without-Hard-Mode dataset for all 34 supported DLC dungeons, covering 185 boss entries and 951 source mechanics.
- Added a compact saved `VET / HM` selector to the dungeon-summary header.
- Made dungeon summaries, boss summaries, mechanic cards, role filters, and every paste-to-chat action difficulty-aware.
- Added explicit Veteran rewrites for mechanics with different targets, counts, thresholds, timings, or safe-zone rules.
- Removed 26 Hard-Mode-only mechanic entries from the Veteran view and paste output.
- Preserved the existing Hard Mode data modules unchanged.
- Slightly reduced the classic dungeon icon for cleaner alignment with the title baseline.

## 0.4.4
- Added ESO's classic group-dungeon icon beside the selected dungeon name.
- Rebalanced the dungeon title row around the icon, gave long names more usable width, and prevented title/DLC combinations from entering the paste-action area.
- Synchronized the runtime and README version values with the addon manifest.
- Cached current-dungeon detection during list sorting and rendering, removing redundant zone API calls without changing selection behavior.

## 0.4.3
- Fixed the boss-list layout error caused by attempting to measure text directly from an ESO button control.
- Rebuilt boss column sizing around a hidden label using the actual boss-row font, so the first column now contracts or expands to the names it contains instead of staying fixed at 440 px.
- Integrated the chevron directly into each boss row label, eliminating overlap and guaranteeing a readable muted/cyan color.
- Kept bold boss names, selected-row highlighting, and hover feedback while making the two-column boss table substantially more space-efficient.

## 0.4.2
- Reverted the boss-list selector dots back to the cleaner chevron-style affordance.
- Restored the boss list to a lighter, cleaner navigation feel while keeping bold boss names and hover feedback.
- Reworked the two-column boss list layout so the left column no longer wastes space; it now sizes more tightly to its content and leaves more room for the right column.
- Kept the existing dungeon-summary header cleanup and top-right paste actions from 0.4.1.

## 0.4.1
- Restored bold boss-list typography so boss names scan as primary selectable entries again.
- Replaced the chevron experiment with a compact selector-dot affordance: muted at rest, cyan on hover, and cyan for the selected boss.
- Kept the stronger full-row hover surface so boss entries read as clickable without adding individual button frames.
- Removed HARD MODE READY from completed dungeon headers; dataset-stub status remains available only when relevant.
- Re-aligned dungeon-summary paste icons into one compact top-right row, matching the selected-boss action treatment and leaving the full-width summary area unobstructed.
- Made the dungeon title/DLC width adapt to the paste-action group so long names remain safely separated from the controls.

## 0.4.0
- Moved dungeon-summary paste actions into the top header row, matching the selected-boss summary and freeing the summary text to use the full width below.
- Removed the boss-list chevron experiment and went back to cleaner rows, while keeping the stronger hover treatment so entries still read as interactive.
- Added subtle header iconography and slightly differentiated section typography for Dungeons, Bosses, Personal Notes, and Mechanics to reduce repeated text weight.
- Added a search icon inside the dungeon search box and kept the clipboard icon treatment for paste actions across the UI.
- Refined dungeon title/DLC/status layout so the header adapts around the top-right paste actions more cleanly.

## 0.3.9
- Added a tiny persistent chevron to every boss-list entry so the list reads as selectable navigation without introducing full button frames.
- Indented boss labels around the new affordance while preserving the compact two-column layout.
- Strengthened the boss-row hover response with a brighter label and cyan chevron, while keeping idle rows restrained and the selected-state accent unchanged.

## 0.3.8
- Kept the v0.3.7 structure intact and focused this pass on typography and action density.
- Added a custom clipboard paste icon and replaced repeated PASTE text buttons across dungeon summaries, boss summaries, mechanics, and personal-note chunks.
- Multipart paste actions now show the clipboard icon with a small part number; single-part actions use the icon alone, with hover tooltips for discoverability.
- Softened summary and mechanic body typography with a lighter medium-font treatment and lower-contrast text color.
- Reduced helper-text prominence for counts, VIEW, note status, and other metadata.
- Separated dungeon DLC and selected-boss Main/Final/Secret metadata from the large title font so secondary information no longer competes with the actual names.
- Slightly softened mechanic-title gold and inactive boss-list text while preserving the existing layout, cards, and view selector.

## 0.3.7
- Reverted the experimental v0.3.6 visual redesign back to the v0.3.5 layout.
- Kept only the selected-boss summary paste controls in the new top-row location.
- Removed the old boss-summary paste side rail and returned that width to the summary text.

## 0.3.5
- Kept the current segmented view-mode selector unchanged after in-game review.
- Rebalanced dungeon and boss paste controls so short multipart sets sit naturally instead of clustering at the top of empty action space.
- Narrowed boss and mechanic action rails to return more width to mechanic and boss-summary text.
- Reduced boss metadata emphasis so boss names remain the primary scan target.
- Tightened the gap above Mechanics and reclaimed a little more visible scrolling space.
- Added restrained hover/focus surface feedback to the dungeon search field without adding another heavy border.

## 0.3.4
- Rebuilt the view-mode controls as one compact segmented selector instead of five floating boxes.
- Gave FULL, QUICK, TANK, HEALER, and DPS content-aware widths, tighter right-edge alignment, and a clear selected underline.
- Corrected vertical text centering across all custom buttons.
- Reduced sidebar striping and softened low-priority mechanic/card dividers to make the full window feel lighter.
- Improved disabled action readability and slightly lifted the Personal Notes editor surface.

## 0.3.3
- Rebuilt compact controls with optically centered captions and distinct idle, hover, pressed, selected, and disabled states.
- Standardized the five view filters to equal widths and strengthened their selected state.
- Reorganized overview, boss, mechanic, and personal-note paste controls for clearer multipart actions.
- Replaced heavy nested panel outlines with surface contrast, section bands, gutters, and restrained dividers.
- Simplified mechanic cards with stronger alternating surfaces, a dedicated action column, and quieter boundaries.
- Added clearer hover and selected states to dungeon and boss navigation rows.
- Improved search and personal-note field focus feedback.

## 0.3.2
- Restored the header close control above the branded background.
- Gave role filters and action controls stronger frames, fills, hover feedback, and selected states.
- Redesigned mechanic cards with distinct headers, gold accents, alternating surfaces, clearer borders, and wider spacing.
- Reclaimed boss-title space by compacting its numbered paste controls.
- Kept disabled note actions recognizable while clearly inactive.

## 0.3.1
- Expanded personal boss notes to 900 characters with automatic numbered chat parts.
- Fixed the Personal Notes heading being clipped.
- Refined panel colors, spacing, header bands, and section borders for clearer visual hierarchy.
- Darkened the search and personal-note editors to match the rest of the interface.
- Aligned the full window body with the header and outer signature frame.

## 0.3.0
- Rebuilt the interface around the compact Flamechasers header and signature cyan frame.
- Reorganized dungeon navigation, boss selection, summaries, mechanics, and role views to use the available window space more efficiently.
- Replaced paginated and visual-only scrolling with ESO native scroll containers and draggable scrollbars.
- Automatically selects the detected dungeon whenever the Codex opens inside it.
- Automatically updates the selected dungeon after loading into another supported dungeon while the window is open.
- Added account-wide personal notes for every boss with Save, Revert, and Paste to Chat controls.
- Preserved all dungeon data, role filters, paste-ready mechanics, slash commands, keybinds, and cursor behavior.

## 0.2.58
- Registered the shared Flamechasers keybind category and action labels before
  ESO parses `Bindings.xml`, removing the remaining load-order dependency.
- Kept both binding action identifiers unchanged so existing assigned keys remain valid.

## 0.2.57
- Corrected the README's language-support note so it accurately describes the
  current zone-name matching behavior.
- Removed an unreachable scrollbar-drag branch and its guarded reference to an undocumented mouse helper; mechanics scrolling remains mouse-wheel based as designed.
- Removed two pass-through cursor wrappers and now call ESO's documented cursor APIs directly.
- Removed redundant nil checks from non-nil zone API results while preserving
  the documented nilable `GetUnitZoneIndex()` check.
- Rechecked every remaining API, ESO UI source reference, event, SavedVariables call, keybind, global, and package entry.
- No dungeon data, mechanic wording, view mode, paste, keybind, cursor, or visible UI behavior was changed.

## 0.2.56
- Removed obsolete API-existence checks and protected-call wrappers after verifying the referenced chat, zone, cursor, mouse, SavedVariables, and control APIs against ESO API 101050 documentation and the current ESO UI source.
- Simplified zone-ID lookup to ESO's documented `GetUnitZoneIndex()` to `GetZoneId()` flow.
- Rechecked dataset loading, globals, keybinds, slash commands, lifecycle, SavedVariables, and package structure.
- No dungeon data, mechanic wording, view mode, paste, keybind, cursor, or UI behavior was removed.

## 0.2.55
- Registered keybind string IDs from the addon's verified `EVENT_ADD_ON_LOADED` callback.
- Confirmed the SavedVariables contain only server-independent UI preferences.
- Documented the current English mechanics dataset and language behavior.
- Rechecked global namespace usage, manifest metadata, dependencies, and ESOUI release compliance.
- No dungeon dataset, mechanic wording, or paste behavior changes.

## 0.2.50
- Added auto cursor/UI mode when opening the addon window.
- Closing the addon restores camera mode only if Flamechasers Dungeon Codex enabled cursor mode itself.
- No dataset or paste-text changes.

## 0.2.49
- Adjusted Mechanics card line layout so long Full-mode paste chunks get more vertical room when a card has only 1-2 paste lines.
- This fixes long mechanic text clipping in the UI without changing pasted chat text or dataset wording.

## 0.2.48
- Added subtle visual-only mechanic card numbers to the Mechanics panel so users can track which mechanic snippet they are viewing/pasting after scrolling.
- Mechanic numbers are UI-only and are not included in pasted chat text.
- No dataset text changes.

## 0.2.47
- Added session-only UI memory for selected dungeon, selected boss, and selected mode tab.
- Closing/reopening the window now keeps the current lookup target during the same UI session.
- Selection memory is not written to SavedVariables, so it resets after game close/reload.
- Fixed Core.lua version metadata to match the addon manifest.

## 0.2.46
- Renamed the visible mechanics tab from **All** to **Full** to avoid implying that every role tab is shown together.
- Added/shortened the tab label to **Mode:** before the Full/Quick/Tank/Healer/DPS buttons.
- Updated the empty Quick notice to point users to **Full** for complete explanations.
- No dataset changes; DLC-only scope preserved.

## 0.2.45
- Added manually-written Quick callouts for Depths of Malatar, Moongrave Fane, Lair of Maarselok, Icereach, and Unhallowed Grave.
- Completed the first full Quick callout pass across all DLC dungeon modules currently in the addon.
- Left detailed All/Tank/Healer/DPS mechanics unchanged.
- Preserved DLC-only scope.

## 0.2.44
- Added manually-written Quick callouts for Fang Lair, Scalecaller Peak, Moon Hunter Keep, March of Sacrifices, and Frostvault.
- Left detailed All/Tank/Healer/DPS mechanics unchanged.
- Preserved DLC-only scope.

## 0.2.43
- Added manually-written Quick callouts for Black Drake Villa, Black Gem Foundry, Bloodroot Forge, and Falkreath Hold.
- Left detailed All/Tank/Healer/DPS mechanics unchanged.
- Preserved DLC-only scope.

## 0.2.42
- Added manually-written Quick callouts for Imperial City Prison, White-Gold Tower, Cradle of Shadows, and Ruins of Mazzatun.
- Left detailed All/Tank/Healer/DPS mechanics unchanged.
- Preserved DLC-only scope.

## 0.2.41
- Added manually-written Quick callouts for Stone Garden, Castle Thorn, The Cauldron, and Red Petal Bastion.
- Left detailed All/Tank/Healer/DPS mechanics unchanged.
- Preserved DLC-only scope.

## 0.2.40
- Added manually-written Quick callouts for Coral Aerie, Exiled Redoubt, and Lep Seclusa.
- Kept detailed All/Tank/Healer/DPS text unchanged.
- No dataset scope changes; DLC-only scope preserved.

## 0.2.39
- Added manually-written Quick callouts for Shipwright's Regret, Earthen Root Enclave, Bal Sunnar, Scrivener's Hall, and Naj-Caldeesh.
- Kept detailed All/Tank/Healer/DPS text unchanged.
- No dataset scope changes; DLC-only scope preserved.

## 0.2.38

- Added a new **Quick** mechanics tab between All and Tank.
- Quick mode is group-facing: it uses the normal [!]/[INT]/[ADD] priority tag logic, not role tags.
- Added manually written Quick callouts for The Dread Cellar, Graven Deep, Oathsworn Pit, and Bedlam Veil.
- Quick snippets are shorter than All text but keep key conditions, target priority, timing, and failure cases when needed.
- Unconverted bosses now show a clear “No Quick callouts yet” notice instead of pretending the detailed All text is short.
- No dungeon scope changes; DLC-only hard-mode focus preserved.

## 0.2.37

- Reworked the summary and mechanics scrollbar visuals into flat dark tracks with neutral visible thumbs.
- Removed the ornate tooltip-border styling from narrow scrollbar controls because it rendered as oversized teal bracket lines.
- No dataset changes; DLC-only scope preserved.

## 0.2.36

- Slightly reduced the boss-list button font and tightened row spacing so four-boss columns stay inside the Bosses panel without clipping.
- No dataset changes; DLC-only scope preserved.

## 0.2.35

- Added mouse-wheel paged summary panes for dungeon summaries and boss summaries so long text no longer gets visually clipped.
- Added mini visual scrollbars/page counters to the dungeon and boss summary areas when more than one summary page exists.
- Reworked boss-summary paste buttons so long boss summaries split into Paste 1 / 2 / 3 / 4 buttons using the same chat splitting path as dungeon/mechanic paste.
- Cleared stale selected mechanic text when changing dungeon, boss, or role filter so the keybind does not paste an old mechanic after navigation.

## v0.2.34

- Rebranded visible addon/UI name to Flamechasers Dungeon Codex while keeping the internal folder/namespace stable for compatibility.
- Added/finished ESO Controls keybind support with string IDs for opening/closing the addon window and pasting the selected mechanic.
- Added `/flamecodex` as an extra slash command. Existing `/dmc`, `/dmech`, and `/dungeonmechs` still work.
- Sanity-checked DLC-only scope, manifest load order, Bindings.xml presence, version metadata, and package structure.

## v0.2.33

- Corrected scope: removed the accidental non-DLC module.
- Restored the addon to DLC-only hard-mode/challenge-banner coverage.
- No non-DLC dungeon modules are loaded in this build.

## v0.2.32

- Added full hard-mode-focused Ruins of Mazzatun dataset.
- Included all four required encounters: Zatzu the Spine-Breaker, The Mighty Chudan, Xal-Nur the Slaver, and Tree-Minder Na-Kesh.
- Added final-boss HM notes for alchemical notes activation, Siphoning Totem priority, Stone Shaper/add control, Amber Plasm soaks, Hist Hallucination/statue guidance, Chudan/Xal-Nur spirit phases, and execute pressure.
- Added path-boss mechanics for Zatzu flying rocks, Chudan Bog Rush/Lightning Shield, Xal-Nur Swamp Spice/geyser runs, Wamasu Slavers, trolls/archers, and phase pacing.
- Kept final-boss hard-mode activation and optional achievement routing in summaries, with boss-fight-only behavior in mechanic sections.

## v0.2.31

- Added full hard-mode-focused Cradle of Shadows dataset.
- Included all five required encounters: Sithera, Khephidaen the Spiderkith, Votary of Velidreth, Dranos Velador, and Velidreth the Lady of Lace.
- Added final-boss HM notes for Mephala statue activation, Shadow Sense / Shadow Spine, Atronach's Light torches, split catacombs, HM adds, Orb of Spite, Gout of Bile, and resource-draining spores.
- Added path-boss mechanics for light/brazier control, Khephidaen Extinguish/interrupts, Votary broodlings/Consume/Webspinner's Wrath, and Dranos Fangs of Mephala/shades/statue pressure.
- Kept final-boss hard-mode activation and optional achievement routing in summaries, with boss-fight-only behavior in mechanic sections.

## v0.2.30

- Added full hard-mode-focused White-Gold Tower dataset.
- Included all six required encounters: The Iron-Swathed Glutton, The Adjudicator, Elite Guard, The Scion of Wroth, The Planar Inhibitor, and Molag Kena.
- Added Obelisk Tome final-boss HM context plus path mechanics for cages/flame waves, Elite Guard kill order/heal interrupts, Scion interrupt punishment, Planar Inhibitor Pinion/Heat Stroke/portals/blue flames, and Molag Kena Lightning Aspects, Windtoss, Lightning Wall, Storm Atronach, jump/wave shield phases, and execute wall pressure.
- Kept hard-mode route/unlock notes in summaries and boss-fight-only behavior in mechanic sections.

## v0.2.29

- Added full hard-mode-focused Imperial City Prison dataset.
- Included Overfiend, Ibomez the Flesh Sculptor, Gravelight Sentry, Flesh Abomination, Lord-Warden's Council, and Lord Warden Dusk.
- Added final-boss HM notes for Warden's Tome activation, constant meteors, Portal Feedback, portal teams, Darklight Burst, Shadow Barrage body-blocking, and shade phases.
- Backfilled the earliest Imperial City DLC dungeon while keeping final-boss hard mode context separate from route/unlock info.

## v0.2.28

- Added full hard-mode-focused Naj-Caldeesh dataset.
- Included Vossa-Saxtl Puzzles, Poxito, Voskrona Stonehulk Poxito, and Talen-Lah with Bar-Sakka.
- Added move/cast labels and role-specific notes for Poxito Bone Armor/saw blades/Soul Storm, Stonehulk Fatal Pools/Death Essence/Sentinel Tethers, and final-boss Seeping Viscera/Boulder Roll/Vortex/add phases.
- Kept Vossa-Saxtl puzzle access and buff context in summaries only; mechanics sections remain boss-fight-only.

## v0.2.27

Added complete challenge-focused dataset for Lep Seclusa.

## v0.2.26

Added complete challenge-focused dataset for Exiled Redoubt.
- Included Guard Captain Paratius, Executioner Jerensi, Docent Domitius, Prime Sorcerer Vandorallen, Eliana Albus, and Squall of Retribution.
- Added move/cast labels for Jerensi Execute/Shadow Ward/Death Knell, Vandorallen Iron Charge/Icy Dome/Coruscating Orb, and Squall elemental infusions/atronach orbs/Thunderstrike.
- Kept optional secret-boss buff and route context in summaries while keeping mechanics fight-only.

## v0.2.25

- Added full hard-mode-focused Bedlam Veil dataset.
- Included Fa-Nuit-Hen puzzle charms, Shattered Champion, Darkshard, and The Blind.
- Added move/cast labels for Shattered Champion glass/Glaziers, Darkshard Maelstrom summons, Champion obelisks/spiderlings, Argonian Behemoth poison/Minders, and The Blind Condemn/Gleaming Deluge/Piercing Beam/Glass Remnants.
- Kept optional puzzle solution/route context in summaries while using charm synergies only where they directly affect The Blind mechanics.

## v0.2.24

Added complete challenge-focused dataset for Oathsworn Pit.
- Covered Sluthrug the Bloodied, Packmaster Rethelros & Malthil, Bolg of Wicked Barbs, Anthelmir & Anthelmir's Construct, Grubduthag Many-Fates, and Aradros the Awakened.
- Added move/cast labels, role-specific notes, and paste-ready snippets for Blood Ties, Cinder Shot, Protective Totem, Conquest braziers, Retrieve/Hurl Axe, Heat Blast, Kindlepitch Barrels, Wildfire, Meteor Call, Firestep side room, lieutenants, and optional Smelter setup.
- Kept Trial unlock/path and Blood/Conquest/War buff/totem details in summaries only; mechanics sections remain fight-only.

## v0.2.23

Added complete challenge-focused dataset for Scrivener's Hall.
- Covered Cartoklepts/Vault Keys, Cartoqueen, Riftmaster Naqri, Ozezan the Inferno, and Valinna & Lamikhai.
- Added move/cast labels, role-specific notes, and paste-ready snippets for Hidden Codex, Unstable Literature double soaks, Ozezan lava/Blood Boil/Firestorm/adds, Lamikhai freeze, Immolation Trap, Ensnaring Spider, meteors, and rolling stones.
- Kept Vault/key unlock routing in summaries only; mechanics sections remain fight-only.

## 0.2.22

- Added complete challenge-focused dataset for Bal Sunnar.
- Included Totem-Wheel Puzzle, Kovan Giryon, Urvel Drath, Roksa the Warped, Laser Puzzle, and Matriarch Lladi Telvanni.
- Added HM-focused callouts for Kovan poison circles and clone beams, Roksa Darklight Orb interrupts and triple tank beam, and Lladi Telvanni Choking Pestilence, Freeze Time add burn, skeevers, Infectious Vomit, and Peryite's Glory.
- Kept puzzle unlock/path/buff information in summaries only, with no non-fight puzzle mechanics in the mechanics section.

## 0.2.21

- Added full challenge-focused Graven Deep dataset.
- Covered Mzugru, Security Drone; The Euphotic Gatekeeper; Xzyviian, Defense Crawler; Varzunon; Chralzak, Sphere 9402-A; and Zelvraak the Unbreathing.
- Kept Dwemer secret-boss puzzle/path/buff notes in summaries only, with fight-only mechanics under mechanics.
- Added move/cast labels for Lightning Strikes, Immunity Shield/Pylons, Pangrit Burrows/Poison Synergy, Mirror Image, Fire Cone, Mortar Barrage, Skeletal Sacrifices, Stomp, Pound/Line AOEs, Drowning Waters/Sea Orbs, Terrified, Split/Illusory Specters, Sundered Soul, The Afterlife/Banished, Flesh Abomination, Inferno, and Tombstone skeletons.

## 0.2.20

- Added full challenge-focused Earthen Root Enclave dataset.
- Covered Scalded Roots, Corruption of Stone, Lutea, Corruption of Root, Jodoro, and Archdruid Devyric.
- Kept optional-boss activation and elemental-orb buff notes in summaries only, with fight-only mechanics under mechanics.
- Added move/cast labels for Fireball, Meteors, Ground Slam, Stone Atronachs, Water Jet, Ice Ring, Root Nodes, Summon Distributaries, Root Infection, Mind Blast, Laser Beams, Lightning Pillars, Rock Totems, Fire Wolves, Lightning Breath, and Malicious Mauling.

## 0.2.19

- Added full challenge-focused Shipwright's Regret dataset.
- Covered Lost Maiden, Foreman Bradiggan, Shrouded Axeman, Nazaray, Storm-Cursed Sailor, and Captain Numirril.
- Kept tormented-spirit find/buff notes in summaries only, with fight-only mechanics under mechanics.
- Added move/cast labels for Chilling Howl, Pillar Burst, Outburst, Soul Bash, Paralyzing Fear, Haunting Charge, Inferno, Possession, Soul Bomb, Vanish, Bludgeon, Liquidate, Kindred Spirit, Terrorizing Timber, Overcharge, Thunderstorm, Drown, Spout, Waves, Retch, Bile Pool, and Drowned Hulk.

## 0.2.18

- Added full challenge-focused Coral Aerie dataset.
- Covered Sword Guardian, Maligalig, Staff Guardian, Sarydil, Shield Guardian, Varallion, and Z'Baza.
- Kept covenant/portal/unlock notes in summaries only, with fight-only mechanics under mechanics.
- Added move/cast labels for Cleave Shock, Barbed Lance/Double Strike, Storm Cell, Surging Waters/Building Static, Dagger Throw, Clone Split, Ascendant Stormshapers, Coalescing Shadows, Mind Link, Gryphon Summon, Lightning Storm, Kargaeda, Mind Blast, Mark Orbs, and Tentacles.

## 0.2.17

- Added full challenge-focused The Dread Cellar dataset.
- Covered Purgator, Scorion Broodlord, Undertaker, Cyronin Artellian, Grim Warden, and Magma Incarnate.
- Kept Daedric Flame/brazier/trapdoor/crystal unlock info and Accession buff details in summaries only; mechanics remain boss-fight-only.
- Added move/cast labels such as Agonymium Stone, Excruciating Expectoration, Dread Surge, Soulstorm, Arresting Bolt, Incarnate Outburst, Path of Fire, Tornado Wall, Unstable Blitz, and Dancing Flames.

## 0.2.16

- Added full HM-focused Red Petal Bastion dataset.
- Covered Wraith of Crows, Rogerain the Sly, Spider Daedra / Anya, Artifact Bearers, Grievous Twilight / Nagaia, and Prior Thierric Sarazen.
- Kept secret-boss rune/buff/path notes in summaries; mechanics remain fight-only.
- Added move/cast labels such as Crow Storm, Unspeakable Void, Belly Buster, Chaos Gate, Aftershock, Rockslide Rush, Leki's Backslash, Opalescent Impale, Duplicate Wall, Blade Tempest, and Shadow's Ire.


## 0.2.14

- Added full challenge-run Castle Thorn dataset.
- Covers Dread Tindulra, Blood Twilight, Vaduroth, Talfyg, and Lady Thorn.
- Kept optional achievement context such as Hound Pound, Four by Four, Let Sleeping Gargoyles Lie, Taking Turns, and Guardian Preserved in summaries only.
- Added fight-only mechanics with All/Tank/Healer/DPS text and cast labels such as Fire Breath, Stomp, Stun Jump/Pin, Dark Barrage, Ichor/Blood Pool, The Reaping/Sickle Toss, Virulent Viscera, Annihilate, Blood Guardian, Blood Scavenger, and Moving-Light Execute.


## 0.2.13

- Added full challenge-banner Stone Garden dataset.
- Covers Exarch Kraglen, Stone Behemoth, and Arkasis the Mad Alchemist.
- Includes fight-only mechanics, role-specific notes, paste-ready All/Tank/Healer/DPS text, and cast labels for Blood Rage, Fault Line, Essence Explosion, Fire/Ice Smash, Magicka Drain, Caustic Cannonade, Volatile Gloomspores, Shock Emitters, Murderous Mark/Husk Swap, Lightning AoE/Pin, Conal Lightning, Mage's Wrath, Whirlwind, and Charge.
- Kept alchemy buff/vitalizer/achievement context in summaries only.


## 0.2.12
- Added full challenge-focused Unhallowed Grave dataset.
- Included all main bosses and optional secret bosses: Nabor the Forgotten, Hakgrym the Howler, Keeper of the Kiln, Voria the Heart-Thief, Eternal Aegis, Ondagore the Mad, Voria's Masterpiece, and Kjalnar Tombskald.
- Kept secret unlock/path information in summaries only; mechanics remain boss-fight-only.
- Added cast/move labels such as Chilling Comet, Bone Sunder, Blazing Kiln, Ring of Blades, Escape, Oozing Slam, Grasping Bomb, Runic Spin, Summon Skeletons, and Awakening/Tzirzhalir.

## 0.2.11

- Added complete challenge-focused Icereach dataset.
- Covered Kjarg the Tuskscraper, Sister Skelga, Vearogh the Shambler, Stormborn Revenant, and Mother Ciannait / Icereach Coven.
- Added final challenge notes for wicker totem, active sister/shield rotation, Storm Surge interrupts, sister-specific add packages, and Sundered Sky execute.
- Added UESP-style cast labels such as Frost Slam, Frost Scrape, Flame Swirl, Summon Stranglers, Summon Undead, Thunderous Pursuit, Avalanche Strike, Unending Storm, Storm Surge, and Sundered Sky.

## 0.2.10

- Added complete HM-focused Lair of Maarselok dataset.
- Covered Selene's Claws/Fangs, Azureblight Lurcher, Azureblight Cancroid, Maarselok on the Perch, and Maarselok in the Roost.
- Added final Scourge Seed / Majority Wins, Wicked Bonds, Sweeping Breath / Azure Blaze, Charge / Lunge, Putrid Stalk, and objective-fight notes.

## 0.2.9

- Added full Moongrave Fane challenge-focused dataset.
- Added all 5 Moongrave Fane boss encounters: Risen Ruins, Dro'zakar, Kujo Kethba, Nisaazda + Grundwulf, and Grundwulf.
- Included dungeon-wide Hemo Helot and Sliding Stone/cube guidance in summaries, with fight-only mechanics under each boss.
- Added All/Tank/Healer/DPS text and cast labels such as Boulder Storm, Consume Hemo Helot, Sangiin Shield, Fanning the Flames, Volcanic Geyser, Corpuscle Cannonade, Summon Sangiin's Thirst, Blooded Unrelenting Force, Giant Bat, Summon Shackle, Dying Breath, and Ghastly Wound.

## 0.2.8

- Added complete hard-mode-focused Depths of Malatar dataset.
- Covered The Scavenging Maw, The Weeping Woman, The Dark Orb, King Narilmor, and Symphony of Blades.
- Included Dictate of the Lady of Light challenge context, Dark Orb color-system training, King Narilmor reflection/Tharayya handling, and Symphony colored-orb/Auroran/Colored Rooms mechanics.
- Added move/cast labels such as Hunting Proboscis, Glaciation, Gelid Globe, Aegis of Meridia, Sunburst, Ice Pillar, Purifying Light, Dawnbreaker, Auroran Phalanx, Meridia's Light, Decrepify, and Purification.

## 0.2.7

- Added complete hard-mode-focused Frostvault dataset.
- Covered Icestalker, Warlord Tzogvin, the Vault Protector, Rizzuk Bonechill + Avalanche, and the Stonekeeper.
- Included challenge-run Stonekeeper Veracity Verifier notes, skeevaton role assignments, Searing Rays positioning, Deep Freeze/Shatter spread, and move/cast labels from UESP/guide sources.

## 0.2.6

- Added complete hard-mode-focused March of Sacrifices dataset.
- Covered The Wyrd Sisters, Aghaedh of the Solstice, Dagrund the Bulky, Tarcyr, and Balorgh.
- Added move/cast labels, role-specific notes, and paste-ready snippets matching the UI text.

## 0.2.5

- Added full hard-mode-focused Moon Hunter Keep dataset.
- Added all five encounters: Jailer Melitus, Hedge Maze Guardian, Mylenne Moon-Caller, Archivist Ernarde, and Vykosa the Ascendant.
- Included move/cast labels such as Bloodmoon's Mercy, Moonlit Rage, Bloody Geyser, Bloody Execution, Lurcher Roots, Strangler Snare, Prodding Shock, Resonating Pools, Shock Blast, Symbols of Xarxes, Fear Totem, Pounce, and The Pack.
- Kept unlock/context in summaries and fight-only mechanics in mechanic sections.

## 0.2.4
- Added full hard-mode-focused Scalecaller Peak dataset.
- Included Orzun + Rinaerus, Doylemish Ironheart, Matriarch Aldis, Plague Concocter Mortieu, and Zaan the Scalecaller.
- Added combat-log/guide-style cast labels such as Terrorizing Tremor, Vicious Shard, Stony Gaze, Death's Gaze, Plague Well, Taking Aim, Fire Cage, Winter's Purge, Pestilent Breath, and Spellbreaker.

## 0.2.3

- Added full Fang Lair hard-mode-focused dataset.
- Added all 5 Fang Lair boss encounters: Lizabet Charnis, Cadaverous Menagerie, Caluurion, Ulfnor + Sabina Cedus, and Orryn the Black + Thurvokun.
- Included challenge-banner final-boss flow: Orryn interrupts, poison placement, scarab/shalk control, Animus Crystals, Bone Colossus spawns, ghost walls, Life Ward / Plague Breath, and execute pacing.
- Included move/cast labels such as Death Grip, Belch of Bile, Soul Cage, Soul Rupture, Nature's Clutches, Spectral Chains, Haunting Spectre, Degenerative Acid, Animus Crystal, Wraith Thralls, and Plague Breath.

## 0.2.2

- Added full Falkreath Hold hard-mode-focused dataset.
- Added all 5 Falkreath Hold boss entries: Morrigh Bullblood, Siege Mammoth, Cernunnon, Deathlord Bjarfrud Skjoralmor, and Domihaus the Bloody-Horned.
- Included Domihaus challenge-banner pillar coordination, atronach waves, execute shield/add pressure, and role-specific notes.
- Added cast/ability labels such as Basilisk Powder, Catapult, Charge, Sweeping Tusks, Stomp, Pull of the Underworld, Aspect of Winter, Deathlord's Fury, Fiery Blast, Ring of Fire, Grovel, and Pillars of Nirn.

## 0.2.1

- Added full Bloodroot Forge hard-mode-focused dataset.
- Added all 6 Bloodroot Forge boss entries: Mathgamain, Caillaoife, Stoneheart, Galchobhar, Gherig Bullblood + Attendants, and Earthgore Amalgam.
- Included dungeon-level warnings for Firehide chains, Earthgorer volcano holes, Fire Shalk Lava Balls, Strangler poison, Molten Nirncrux, and final-boss side-synergy limitations.
- Used cast/ability labels such as Lunge, Nature's Preservation, Wave of Earth, Fire Bloom, Mantle Breaker, Scorched Earth, Burnt Offering, Anvil Cracker, Drown in Flame, Groundshaker, Falling Debris, and Summon Clones.

## 0.2.0

- Added full Black Gem Foundry hard-mode-focused dataset.
- Added all 6 Black Gem Foundry bosses: Prospector Lyrakta, Quarrymaster Saldezaar, Gemcarver Hynax, Black Gem Monstrosity, Misura, and High Soulbinder Vykand.
- Included dungeon/boss summaries for optional Superior Daedric Essence and wrist-cuff buff system.
- Added role-specific All/Tank/Healer/DPS text and cast labels for major mechanics such as Rupture, Seismic Splinters, Soul Focus, Soulbinding Slam, Refraction Color Puzzle, and Ominous Vision / Annihilation.

## 0.1.10

- Added `Docs/DATASET_STYLE_GUIDE.md` with the standardized rules for future dungeon/trial/arena datasets.
- Added `Docs/DUNGEON_MODULE_TEMPLATE.lua` as a non-loaded Lua template for new mechanic modules.
- Documented source rules, HM-only mode policy, summary/mechanic separation, tag usage, move-name priority, role text standards, paste-splitting rules, and QA checklist.

## 0.1.9

- Added explicit boss attack / move labels to Black Drake Villa mechanics where the mechanic is tied to a named cast or death-recap-style attack.
- Mechanic titles and paste prefixes now use the same move/cast label helper, so the name you see in the UI is the name pasted to chat.
- Increased mechanic label length support so combined names like Mind Blast / Spectral Indriks are not aggressively truncated.
- Added a reusable `casts` data field for future dungeon modules.

## 0.1.8

- Moved Black Drake Villa secret-boss unlock/path instructions out of the mechanics list and into the relevant boss summaries.
- Removed Secret Unlock mechanics from Avatar of Zeal, Avatar of Vigor, Avatar of Fortitude, and Sentinel Aksalaz.
- Mechanics sections now contain boss-fight behavior only; route/unlock/buff notes stay in dungeon or boss summaries.
- Expanded secret-boss and Sentinel summaries so the removed unlock information is still visible and pasteable from the summary area.

## 0.1.7

- Rebuilt Black Drake Villa as the first polished data module.
- Removed player-chat color codes permanently; paste lines are plain text.
- Changed role wording from Heal to Healer and paste tag from [HEAL] to [HEALER].
- Increased snippet budget so text only splits when it actually needs to.
- When a mechanic splits, only the first line gets the mechanic prefix/tag; continuation lines stay clean.
- Mechanic UI now displays the exact same paste-ready lines used by the paste buttons.
- Mechanics rows are taller with larger text boxes to prevent overlap.
- Scrollbar is now a clean visual indicator; mechanics scrolling is mouse-wheel based.
- Black Drake Villa text now avoids mixed mode wording and is written as a dedicated challenge-banner dataset.

## v0.2.15

- Added complete challenge-focused dataset for The Cauldron.
- Included Oxblood the Depraved, Taskmaster Viccia, Molten Guardian, Lyranth's Prison, and Baron Zaudrus.
- Added move/cast labels for Oxblood globs/cage, Viccia traps/chains/Execute, Molten Guardian channels/fiends, Lyranth catalyst/add waves, and Zaudrus Ash Vents/Cold-Flame rock control.
