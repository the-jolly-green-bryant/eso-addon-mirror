# Ultivite 1.0.125

* Added one profile backed Overhead Player Info toggle. Group members show Character Name, CP and Level above their world health area. Mouseover players show the same data when available, with a reticle fallback when ESO restricts enemy world position.
* Native enemy, friendly and group player names are kept visible while the option is enabled and restored when disabled.


- Champion Points remain permanently enabled on ESO group frames and Ultivite's normal player target frame.
- Dark Souls enemy Health frames now also show ESO's Champion icon plus effective CP for Champion player targets. Non-Champion player targets show their effective level instead.
- Preferred/Tab-target caching retains the last known CP/level alongside Health while ESO keeps the preferred target but no public unitTag is available.
- Native engine nameplates above enemy players are left untouched because ESO exposes no Lua control handle for injecting CP text into those nameplates.

* Group-frame Champion Points are now permanently enabled for Champion players.
* Player-target Champion Points / level are now permanently enabled.
* Removed the Group Frame CP and Target Frame CP toggles from both the Quick Menu and full settings.
* Older profiles that stored either CP preference as OFF are migrated back to ON automatically.
* CP display is no longer preserved as an independent profile preference, so profile switching cannot disable it.

# 1.0.122

* Added clickable ESOUI dependency links and moved the Quick Menu screenshot and explanation directly beneath Dependencies in the ESOUI description.
* Added a dedicated Target Frame CP toggle for Champion Points / level on player targets.
* Added a dedicated Group Frame CP toggle using ESO's native group-frame Champion Point number and Champion icon.
* Added both CP toggles to the Quick Menu and their respective full settings sections.
* Removed the Quick Menu path that silently forced player-target CP back on during every refresh.
* Made target-frame rollback more obvious with RESTORE VANILLA TARGET FRAMES in the Quick Menu and RESTORE Vanilla / Default Target Frames in the main settings.
* Vanilla target-frame rollback no longer overwrites the user's CP display preference.
* Updated the ESOUI graphics description for the seven-setting PvE/PvP profiles, including Sunlight Rays.

# 1.0.121

* Completed a proactive settings and runtime-logic audit across the consolidated Ultivite, Combat, Frames, Quick Menu, Sound and Fancy Action Bar bridge paths.
* Fixed the global NPC Names setting and the native-mode-only NPC suppression option sharing one SavedVariable. They are now independent, with nil-only migration from existing profile state.
* Hardened ESO setting writes with live readback verification and made native nameplate snapshots one ownership cycle only, while retaining failed snapshots for a safe retry instead of restoring stale values forever.
* Fixed Quick Menu preset restoration so NPC/nameplate ownership is reapplied after a HUD preset switch.
* Fixed the Werewolf resource meter OFF path so a meter hidden by Ultivite can be released again.
* Fixed conditional Quest Tracker visibility so leaving combat/PvP restores the exact ESO setting captured before Ultivite hid it instead of forcing the tracker ON.
* Fixed the Burst/Execute warning mode Quick Menu save path calling a nonexistent combat save function.
* Fixed two stale calls to the removed resource-danger refresh function so preset changes now refresh the current resource danger HUD.
* Synchronized `chatVisibilityMode` with the legacy `autoHideChat` flag in Vanilla and Dark Souls presets and apply the current chat visibility path when presets change.
* Added the requested Vanilla / Default Target Frames action to the main Profiles & Core HUD area as well as the target-frame section and Quick Menu. The rollback now also disables and releases dynamic external-target-frame suppression.
* Improved CC immunity / Immovability drag persistence by saving on both mouse release and move-stop through one position routine.
* Strengthened Fancy Action Bar visibility controls so their specific update is followed by the shared FAB runtime refresh.
* Removed knowingly nonfunctional visible menu entries: the retired Battleground queue checkbox and disabled group-frame position controls. Their legacy SavedVariables remain untouched for compatibility.
* Removed malformed empty LibAddonMenu option records and aligned all internal module version strings to 1.0.121.
* Player bar Number Format, Font and Text Size changes now explicitly request a SavedVariables save after applying.

# 1.0.120

* Fixed NPC NAMES ON/OFF as a deterministic override. ON now forces enemy, friendly and neutral NPC names to Always, while OFF forces all three to Never.
* Added a profile-backed ownership flag so native target-frame refreshes and player activation cannot silently restore stale captured nameplate values over the explicit NPC names choice.
* Added delayed reassertion after the click to survive same-frame ESO or addon nameplate refreshes. Player name settings are not changed.

# 1.0.118

- Renamed the Chat visibility `Off` label to `Auto Hide` in both the Quick Menu and the main Ultivite settings. Behavior is unchanged.

# 1.0.117

- Fixed Bandits minimap OFF handling. Ultivite now mirrors Bandits' native checkbox behavior by applying the saved MiniMap setting and calling the live `BUI.MiniMap.ReInit()` teardown path, so an already-visible minimap actually turns off immediately.
- Kept the working Bandits minimap ON behavior from 1.0.116 unchanged.

# 1.0.116

- PvE graphics profile now enables ESO Sunlight Rays / God Rays; PvP disables them.
- Fixed NPC Names ON so native target mode cannot immediately hide NPC names again; quick-menu writes now persist through reload.
- Added Profiles & Core HUD quick action to restore Vanilla / Default target frames and release Ultivite target-frame suppression.
- Added direct drag and drop positioning for the CC immunity / Immovability icon with a live preview unlock control.
- Reworked the Bandits minimap bridge for extracted minimap settings so it can restore the saved setting even when the live minimap module was not created because Bandits loaded with the minimap disabled.

# Ultivite 1.0.115

- Audited Corrosive Armor and Onslaught warning detection against the public DKcorrosiveAlert implementation notes and the established ESOUI Onslaught warning method.
- Fixed the critical PvP source filter bug: hostile enemy sources were being rejected because Ultivite treated `COMBAT_UNIT_TYPE_PLAYER` as meaning any player. In ESO combat events it identifies the local player/self, so valid enemy Ultimate hits never reached the warning logic.
- Warning registration now follows the original addon's incoming-player path first: `UNIT_TAG player` + individual damage result filters + exact ability-ID filters where available. No hostile-source-type filter is used.
- Onslaught now listens for the documented incoming hit IDs 83229 (single target) and 126497 (AOE), with an incoming-damage metadata fallback for future/internal ID changes.
- Corrosive Armor now keeps the original incoming periodic-damage detection model, with a narrow incoming-damage discovery path so the internal damage event ID can be learned even when it differs from the public skill ID.
- Removed persistent-selected-target icon attachment. Ultivite's only added presentation is now the requested mouseover icon above the detected enemy while that enemy is under the reticle.
- Corrosive and Onslaught Quick Menu toggles remain independent and no other warning settings are changed.

## 1.0.114

- Added Ambient Occlusion to the two one-click graphics profiles.
- PvE now sets Ambient Occlusion to Screen Space GI in addition to the existing Shadows, Screen Space Water Reflections, Distortion, Bloom and Grass/Clutter settings.
- PvP now sets Ambient Occlusion to Off in addition to switching those existing five profile settings Off.
- No other graphics settings are changed.

## 1.0.113

- Replaced the ambiguous two-step Graphics Profile selector with two explicit one-click Quick Menu actions: APPLY PVE GRAPHICS and APPLY PVP GRAPHICS.
- PvE still changes only Shadows, Screen Space Water Reflections, Distortion, Bloom and Grass/Clutter to Ultra/On.
- PvP still changes only those same five settings and sets each one Off. No other graphics setting is touched.

## 1.0.112

- Fixed Quick Menu disappearing while hovering or previewing controls.
- Quick Menu now follows ESO text-entry Open/Close/Minimize session events rather than transient chat-control visibility.
- Added pointer-interaction grace so moving between adjacent Quick Menu rows cannot be interpreted as a chat close.

## 1.0.111

* Replaced the live Damage, Front Resistance, Back Resistance and Damage Shield `StartMoving()` path with explicit cursor-tracked dragging.
* The four number-only live stat widgets are now directly draggable whenever visible and no longer depend on Preview, Resize or the global HUD lock.
* Added a temporary full-screen mouse capture only while one of those four numbers is actively being dragged, so releasing the mouse outside the original hit box still ends and saves the move cleanly.
* Resize remains a separate Preview + Resize mouse-wheel action and is not triggered by normal dragging.
* Preserved all existing live-stat positions and SavedVariables.

## 1.0.110

- Fixed keyboard chat focus after opening or interacting with the Quick Menu. ESO can leave its TextEntry logically open while the EditBox has lost keyboard focus; Ultivite now restores focus directly to the stock ESO chat EditBox without reopening or replacing chat.
- Reasserts chat EditBox focus on the next frame after Enter opens chat, preventing the Quick Menu overlay from leaving typing inactive.
- Quick Menu button clicks now restore the existing chat draft and keyboard focus whether ESO kept TextEntry open or actually closed/reopened it.
- Uses only the same public edit-control TakeFocus behavior used by ESO's own TextEntry implementation.

## 1.0.109

- Removed Azurah and LuiExtended from `OptionalDependsOn`. They are not required to install or run Ultivite.
- Kept passive runtime compatibility checks for Azurah and LuiExtended when either addon happens to be installed.
- Confirmed Bandits User Interface remains an optional runtime integration only and is not declared as a dependency.
- Reworked the ESOUI description header into an explicit Dependencies section listing only LibAddonMenu-2.0 and Fancy Action Bar+ as required.

## 1.0.108

- Completed a full Quick Menu interaction audit. Setting changes now execute on mouse release instead of mouse down so ESO receives a complete UI click before Ultivite changes state.
- Simplified Quick Menu chat restoration and removed delayed close callbacks that could interfere with the next chat entry or gameplay input.
- Removed the retired detached preview implementation entirely. Preview now has only one path: the real HUD controls in their real positions.
- Preview hover is limited to HUD elements that have a real in-world or screen-space preview, preventing unsupported rows from forcing unnecessary refreshes.
- Added Open Quick Menu to the normal Ultivite addon settings. When launched there, the Quick Menu is independent of chat and X returns cleanly to the settings panel.
- Simplified the addon settings page: Quick Access now contains the common profile/save/HUD actions and redundant explanatory description blocks are removed from normal menus.
- Confirmed Bandits User Interface remains optional and is not listed in either DependsOn or OptionalDependsOn.
- Rewrote the ESOUI description with dependencies first and sections matching the Quick Menu organization.

## 1.0.107

- Added selectable PvE/PvP graphics profiles near the bottom of the Quick Menu with a separate Apply button.
- Graphics profiles touch only Shadows, Screen Space Water Reflections, Distortion, Bloom and Grass/Clutter. PvE sets them to Ultra/On; PvP sets them Off.
- Strengthened food detection using long-duration provisioning ability metadata instead of relying on clickable visible auras.
- Strengthened Major Resolve detection using GetAbilityBuffType/BUFF_TYPE_MAJOR_RESOLVE when available, with the existing name/description fallbacks retained.
- Removed the duplicate scene-manager UI-mode exit after chat close; ESO's own chat Close/OnChatInputEnd path now exclusively owns input teardown.
- Bandits remains completely optional and is not listed as a required or optional manifest dependency.

## 1.0.106

- Added independently implemented enemy Corrosive Armor and Onslaught awareness inspired by the public behavior of DKcorrosiveAlert and the ESOUI Onslaught warning discussion without redistributing either addon's source.
- Corrosive Armor detection listens for damage received from an enemy player and tracks each detected source for the current 10 second Corrosive window.
- Onslaught detection uses the documented incoming hit IDs 83229 and 126497 and tracks the source for the current 8 second Onslaught window.
- Added source-aware Corrosive and Onslaught icons with countdowns. When the source is the reticle or persistent selected target, Ultivite attempts to position the icons above the target using ESO world projection, then falls back to the selected target frame or reticle when PvP position data is restricted.
- Added compact global fallback warnings so an active enemy Ultimate remains visible even when ESO does not expose a usable world position for that enemy.
- Added CORROSIVE ARMOR ALERT and ONSLAUGHT ALERT toggles under Quick Menu > Warnings. Both support the real HUD Preview mode.
- Added an Enemy Ultimate alerts submenu in full settings with individual toggles and icon size.
- Event listeners are registered only while their corresponding warning is enabled, with combat-result and player-target filters to avoid unnecessary Lua combat traffic.

## 1.0.105

- Removed Bandits User Interface from the manifest dependency lists entirely. Ultivite loads normally without Bandits and detects the Bandits minimap only at runtime when available.
- Reworked Quick Menu Preview so preview visibility is not reapplied every 50 ms. This removes the hide/show fight that caused the Feet Compass and other previewed HUD elements to flash or strobe.
- Added preview-aware visibility to the Feet Compass, Crown Arrow, combat warnings, CC immunity, debuffs, target debuffs, live damage/resistance stats and shield strength.
- Silenced Quick Menu no-op/action-unavailable chat spam unless diagnostic logging is explicitly enabled.
- Fixed the Quick Menu close/chat handoff so a delayed cleanup cannot close or steal focus from a newly opened chat entry. Chat visibility is released immediately when text entry opens.
- Strengthened No Food detection using active-effect timing, derived-stat/description metadata and a conservative long-duration consumable fallback instead of requiring one fragile can-click-off signature.
- Strengthened Major Resolve detection using the live player effect event plus buff names and ability metadata, while preserving Hurricane, Boundless Storm, Lightning Form, Werewolf and Oakensoul handling.
- Rewrote the ESOUI description with required dependencies at the top and feature sections ordered around the Quick Menu categories.

## 1.0.104

- Confirmed and preserved permanent direct dragging for Weapon/Spell Damage, Front Resistance, Back Resistance and Shield Strength whenever each widget is visible.
- Kept resizing separate from normal dragging. PREVIEW + RESIZE remains the only mouse-wheel resize mode for these stat widgets.
- Fixed live-stat resize input so the mouse wheel works on both the widget root and its transparent drag surface.
- Added `BANDITS MINIMAP` under Quick Menu > Navigation. Ultivite bridges the installed Bandits User Interface minimap rather than creating another minimap.
- Added support for Bandits' published `BUI_MiniMap_Shown` and `BUI_Ready` callbacks so the quick-menu label follows Bandits' real minimap state.
- Added compatibility probing for Bandits minimap show/hide/toggle methods and its minimap enable SavedVariable across Bandits revisions.
- Added BanditsUserInterface as an optional dependency so Ultivite can initialize its minimap bridge after Bandits when both are installed.

## 1.0.103

- Added PVP K/D COUNTER directly to Quick Menu > Combat Information.
- K/D counter is now permanently draggable whenever it is visible; the old temporary Move K/D counter unlock option was removed.
- Added a larger transparent grab surface hover outline so the K/D counter is easy to pick up and reposition.
- K/D resizing is separate from dragging and only activates through Quick Menu PREVIEW + RESIZE using the mouse wheel.
- Added persistent K/D font size while preserving existing K/D position and visibility settings.

## 1.0.102

- Fixed the remaining quick-menu close input bug that could leave left-click light attacks unavailable after closing Ultivite.
- Removed Ultivite's direct `SetGameCameraUIMode(false)` calls from the X close path. ESO's scene manager now owns the complete UI-mode shutdown so its camera and directional-input state are released together.
- X closure now waits until the UI mouse-up event has fully completed, closes chat through ESO's normal text-entry path, then asks the scene manager to exit UI mode safely.
- Hidden quick-menu controls are explicitly made non-mouse-interactive so no invisible menu control can retain mouse focus after closing.

## 1.0.101

- Moved PREVIEW to the absolute top of the Ultivite quick menu.
- Kept RESIZE directly underneath PREVIEW.
- FULL ULTIVITE SETTINGS now follows the two edit controls, with the existing categories below unchanged.

## 1.0.100

- Audited every Quick Menu button from displayed state through its real Ultivite/FAB backend action.
- Added an atomic Quick Menu interaction session so temporary chat focus loss during a button click can no longer close the panel before the setting applies.
- Chat is restored in multiple short passes after a click, including releasing Ultivite chat-hide rules and maximizing the visible chat container when needed. This specifically fixes menus disappearing while `CHAT: OFF`, `Hide in Combat`, or `Hide in PvP` is selected.
- Added post-click state verification for every toggle/cycle button. A backend no-op is now reported to chat/diagnostics instead of failing silently.
- Dark Souls profile selection is now layout-scoped. Cycling Dark Souls no longer resets independent Combat Information, Navigation, Warnings, World UI, or HUD visibility choices.
- `DARK SOULS: OFF` and the top-left layouts no longer call the broad recommended-HUD reset preset.
- FAB-specific Dark Souls states are skipped when unavailable rather than leaving the button apparently stuck.
- CP Progress cycling now includes Hide In Combat because the HUD Visibility presets can legitimately place it in that state.

## 1.0.99

• Fixed Dark Souls quick-menu profiles minimizing chat and closing the quick menu while a profile is being selected.
• Dark Souls profile cycling now preserves the independent Combat HUD and Chat visibility choices.
• Added failure handling so an unavailable Dark Souls action-bar profile does not silently advance as if it applied.
• Reordered the quick menu: Combat Information first, then Navigation, Warnings, World UI, Edit HUD, with Profiles & Core HUD at the bottom.

## 1.0.98

- Fixed the Quick Menu X close path potentially leaving primary/light-attack mouse input unusable after returning to gameplay.
- X now uses a two-phase close: mouse-down only marks the close request, while chat/camera/UI release happens on mouse-up after the physical left-click has completed.
- Quick Menu visibility is held during that short mouse-down to mouse-up window so ESO cannot hide the button before its release handler runs.

## 1.0.97

- Fixed the Quick Menu X button leaving ESO in UI cursor/chat input mode after the panel disappeared.
- X now cancels queued chat reopen operations, closes the real ESO chat text entry, exits Preview/Resize, hides the panel and returns the game camera to normal control.
- X now commits on mouse-down so the cleanup occurs before chat focus can change underneath the button.

## 1.0.96

- Quick Menu now treats a minimized or visually hidden chat entry as closed instead of relying only on TextEntry:IsOpen().
- Added an X close button. Manual close stays closed for the current chat session and resets on the next real chat close/open.
- Reordered the Quick Menu into Edit HUD, Profiles & Core HUD, World UI, Combat Information, Navigation and Warnings categories.
- Moved Full Ultivite Settings to the top of the Quick Menu.
- Removed the separate How Ultivite Is Organized section and trimmed high-level explanatory description blocks from the normal addon settings.

## 1.0.95

- Quick Menu visibility now follows ESO chat input strictly. Closing chat immediately closes the menu even if the mouse is still over it.
- Quick Menu actions execute on mouse-down and reopen the same chat draft on the next UI tick, so buttons remain usable without relying on mouse-hover visibility hacks.
- Retired the detached black Preview panel. Preview now exposes the real Ultivite HUD controls at their actual saved screen positions.
- Preview automatically enables real drag editing for player bars, the target frame, Fancy Action Bar+, Dark Souls enemy/self bars, navigation helpers, live stats, CC/debuff trackers and warning widgets.
- Added RESIZE directly below PREVIEW. Mouse wheel resizing now works on the real previewed HUD controls, including Fancy Action Bar+.
- Added persistent preview positioning and sizing for Food Warning, Major Resolve Warning and Major Breach text size.
- Added a persistent Dark Souls self-bar scale so the bottom Dark Souls stack can be resized in preview mode.
- Closing chat automatically exits Preview and Resize and restores the previous editor lock states.

## 1.0.94

- Made the live Weapon / Spell Damage and front/back Resistance widgets explicitly always unlocked with a larger invisible grab area.
- Added a subtle hover outline to live stat widgets so direct drag-and-drop is easy to discover without leaving an edit overlay visible.
- Live stat positions save immediately on mouse release and remain independent of Ultivite's global HUD unlock state.
- `ENEMY HEALTH BARS: VANILLA` now suppresses Ultivite's persistent custom target frame while Vanilla is active, preventing the duplicate stock + custom health-bar presentation.
- Preview mode now hard-hides all preview child controls when switched off to prevent preview artifacts from remaining on screen.

## 1.0.93

- Added a PREVIEW toggle as the first button in the on-screen Ultivite Quick Menu.
- Preview is runtime-only and does not alter or save any Ultivite settings by itself.
- When Preview is enabled, a dedicated preview panel opens immediately to the left of the Quick Menu so it does not conflict with Bandits on the left edge.
- Hovering or clicking a Quick Menu option automatically switches the preview panel to that option.
- Added representative live previews for Dark Souls profiles, HUD visibility, enemy health, action bar, group frame, CP progress, NPC names, compass, quest/queue/chat controls, mount/werewolf meters, damage/resistance stats, shield modes, debuffs, CC immunity, feet compass, crown arrow and combat warnings.
- The preview panel hides whenever the Quick Menu hides and returns when the menu is reopened if Preview is still enabled for the current UI session.

## 1.0.92

- Expanded the Enter/chat quick menu with enemy Health-bar modes, HUD visibility presets, group-frame visibility, CP progress visibility, NPC names, queue status, chat visibility, mount/werewolf meters, live Damage/Resistance stats, shield modes, debuffs, CC immunity, Feet Compass, Crown Arrow, Burst warning and Execute warning.
- Enemy Health Bars now cycles `VANILLA -> TARGET ONLY -> ALL ENEMIES -> OFF`. VANILLA restores ESO's captured nameplate settings and stock target frame so native PvP alliance and CP presentation is available.
- Player CP/level display is now kept enabled rather than exposed as a toggle.
- Group Frame cycles `ON -> HIDE IN PVP -> OFF` and uses ESO's group-frame hidden reason plus explicit LUI Extended group controls.
- CP Progress Bar cycles `ON -> HIDE IN PVP -> OFF`.
- Queue Status keeps the existing multi-state visibility cycle. Chat now supports `NORMAL -> HIDE IN COMBAT -> HIDE IN PVP -> OFF`.
- Damage + Resistance cycles `OFF -> DAMAGE -> RESISTANCE -> BOTH`.
- Shield cycles `OFF -> STRENGTH -> BROKEN WARNING ONLY -> BOTH`.
- Debuffs cycles `OFF -> ON ME -> TARGET -> BOTH`.
- Feet Compass and Crown Arrow now support `OFF -> ON -> COMBAT ONLY -> PVP ONLY` from the quick menu.
- Burst and Execute warnings now support `OFF -> PVP ONLY -> ALWAYS`.
- HUD Visibility cycles `NORMAL -> COMBAT CLEAN -> PVP CLEAN -> MINIMAL` without changing the separate group/chat/navigation-helper choices.
- Existing profiles and SavedVariables are migrated nil-only; previous positions and choices are preserved.

## 1.0.91

- Rebuilt the CC Immunity tracker around the actual player `EVENT_EFFECT_CHANGED` payload instead of discarding the event and relying only on a delayed buff-list rescan.
- Added the second current generic Crowd Control Immunity ability ID, 38117, alongside 28301.
- Event-provided begin/end times now drive the countdown directly, while the existing buff scan remains as a fallback for Immovable / Unstoppable and player debuff tracking.
- CC immunity diagnostics now show whether the active timer came from the effect event or the fallback buff scan.

## 1.0.90

- Fixed Quick Menu `COMBAT HUD: ALWAYS` not restoring Fancy Action Bar+ after it had been hidden by `COMBAT ONLY`.
- Ultivite now explicitly synchronizes the shared `ZO_ActionBar1` root whenever Combat HUD visibility changes.
- When FAB+ is revealed again, Ultivite asks FAB+ to refresh its bar position, active slots and Ultimate labels immediately.
- Removed the old attempt to mirror a nonexistent whole-action-bar `combatOnly` setting into FAB+ SavedVariables. FAB+ keeps ownership of its own settings while Ultivite owns only the shared visibility rule.

## 1.0.89

- Quick Menu ESO Compass and Quest Tracker buttons now cycle through ON, Hide in Combat, Hide in PvP and OFF instead of only toggling ON/OFF.
- Quick Menu Crosshair now cycles through all supported modes: ON, Combat Only, PvP Only, Hide in Combat, Hide in PvP and OFF.
- Renamed the quick-menu Combat Only HUD row to Combat HUD with clear ALWAYS / COMBAT ONLY states.
- Combat HUD now explicitly keeps the action bar enabled and applies the shared combat-only rule to the action bar and Ultivite player Health/Magicka/Stamina HUD together.
- Existing SavedVariables and profiles are preserved.

## 1.0.88

- Fixed Quick Menu buttons disappearing before their OnClicked handlers could run when clicking caused ESO chat input to lose focus.
- Quick Menu now stays visible while chat is open OR while the mouse is over the menu, then hides once chat is closed and the mouse leaves.
- Added a short interaction hold around mouse-down/click so settings apply reliably before any chat-focus transition.
- Quick Menu callbacks are isolated with pcall so one failed action cannot break the rest of the menu.

## 1.0.87

- Replaced the unreliable invisible right-edge hover hotspot for the Ultivite Quick Menu.
- Quick Menu now follows ESO's actual chat text-entry state: pressing Enter to open chat shows the menu and it remains visible for the entire time chat input is open.
- Closing/submitting chat hides the Quick Menu completely.
- Quick Menu remains on the right side of the screen so it stays clear of Bandits' left-side menu.
- No existing Ultivite profile or SavedVariables values are reset.

## 1.0.86

- Added an in-game Ultivite Quick Menu on the right edge of the HUD, deliberately opposite Bandits-style left-side controls.
- The panel is completely hidden until the mouse enters a narrow invisible right-edge hotspot and automatically disappears after the mouse leaves the panel area.
- Added one single Dark Souls Profile button that cycles through Off, Full, Self Bars, Top Left, Top Left + Self, Action Bar + Enemy and Action Bar + Self.
- Added quick ON/OFF controls for Feet Compass, Crown Arrow, Combat Only HUD, Action Bar, ESO Compass, Quest Tracker, Crosshair, No Food warning, Major Resolve warning, Major Breach dot, CC Immunity and Debuffs on Me.
- Added a Full Ultivite Settings button at the bottom of the quick panel.
- The quick menu changes the existing Ultivite SavedVariables and preset functions directly rather than creating a second configuration system.

## 1.0.85

- Added the diagonal Feet Compass bearings back in: NE, SE, SW and NW.
- Kept the professional 1.0.84 compass proportions while making diagonal labels smaller and slightly more central so the compass stays readable.
- Preserved the longer composite crown arrow with the crown locked into the arrow base.

## 1.0.84

- Rebuilt the Crown Direction marker as a single rotating composite texture so the gold crown is physically attached to the arrow base at every direction.
- Lengthened the crown arrow substantially without relying on a detached crown control.
- Rebalanced the Feet Compass to a taller ground-style oval so it no longer looks crushed or overly flat.
- Removed diagonal NE/SE/SW/NW labels from the feet compass to reduce clutter and improve at-a-glance readability.
- Increased primary N/E/S/W text size and contrast. Compass opacity now mainly fades the ring while keeping direction text readable.
- Existing SavedVariables remain preserved.

## 1.0.83

- Rebuilt the Feet Compass again so it is no longer overly squashed. The ground compass now uses a taller oval with much clearer text placement.
- Main N/E/S/W letters are larger and diagonal bearings sit slightly inward to improve readability.
- Increased the default Feet Compass size, opacity and lower-screen placement again for a more legible Bandits-style result.
- Elongated the Crown Direction Arrow properly and kept the crown seated at the base of the arrow.

## 1.0.82

- Reworked the Feet Compass into a more Bandits-style ground compass with a wider and flatter presentation beneath the character.
- Increased the default Feet Compass size, moved it lower on screen, and increased the default opacity slightly for a cleaner read.
- Added larger primary direction letters and secondary NE/SE/SW/NW labels for a more professional navigation look.
- Feet Compass size slider now supports larger values and scales the text up accordingly.

## 1.0.80

- Refined the feet compass into a cleaner near-circular dial with improved spacing and lower visual noise.
- Added a small gold crown accent above the white crown direction arrow.

## 1.0.79

- Rebuilt the Feet Compass presentation so the cardinal directions are no longer baked into and rotated with a heavily squashed texture.
- Compass ring is now a clean white screen-space ellipse; N/E/S/W are individually positioned from camera heading.
- Increased vertical depth from 36% to 60% of width so the cardinal labels are spread out and readable beneath the character.
- Cardinal anchors are rounded to whole pixels to avoid high-resolution shimmer while moving.
- Feet Compass remains OFF by default and existing SavedVariables are preserved.

# Ultivite Changelog

## 1.0.78

- Moved the Crown Direction Arrow and Feet Compass ON/OFF controls directly into `UI Visibility > Player HUD & Global Visibility` so the two navigation helpers are visible alongside the other global HUD toggles.
- Renamed the separate navigation submenu to `Navigation Helper Appearance & Position`; it now contains only size, opacity and position tuning.
- Both navigation helpers remain OFF by default and existing SavedVariables are preserved.

## 1.0.77

* Added an optional compact white Crown Direction Arrow that points toward the current group leader/crown. It is OFF by default.
* Added crown arrow size, opacity, horizontal position and vertical position controls.
* Added an optional white Feet Compass beneath the character area. It is OFF by default.
* Added feet compass size, opacity, horizontal position and vertical position controls.
* The Feet Compass is screen-space anchored and rotates from camera heading instead of following a moving world-space position, reducing visible locomotion jitter.
* Crown direction samples the leader position separately from camera rotation so camera turns remain responsive while leader-position changes are smoothed.
* Added two original Ultivite DDS assets for the arrow and compass; no Bandits UI or Yet Another Compass source/assets are bundled.
* Existing profiles are preserved. The two new features remain disabled unless the user explicitly enables them.

## 1.0.76

* Added `UI Visibility > Crosshair / Reticle > Crosshair visibility`.
* Crosshair modes: `On / Show`, `Only in combat`, `Only in PvP`, `Hide in combat`, `Hide in PvP`, and `Hide always`.
* The control hides only ESO's center crosshair texture; interaction prompts and reticle text remain available.
* Crosshair defaults to normal ESO behavior (`On / Show`) so updating Ultivite does not unexpectedly remove the reticle for existing players.
* Corrected the Compass menu's displayed default to `Hide in combat`, matching the actual factory default introduced in 1.0.74.

## 1.0.75

- Reduced the Kjalnar stack number from the previous oversized `configured size + 8` rendering to the configured Kjalnar font size itself.
- Removed the Kjalnar number text shadow/outline so the counter is less intrusive.
- Kept the Kjalnar badge background/border fully transparent at every stack level.

## 1.0.74

* Changed the fresh-install/default Compass visibility from `Hide in PvP` to `Hide in Combat`.
* The Default / Vanilla preset now restores Compass to `Hide in Combat` as well.
* Existing users keep their saved Compass visibility setting unchanged.

## 1.0.73

* Changed fresh-install chat behavior to keep chat visible by default. `Always collapse chat` now defaults off.
* Removed all factory sound suppression. New installs start with an empty blocked-sounds list.
* Changed the legacy `Hide group frame` SavedVariable default to off. The retired feature remains inactive.
* Existing users keep their SavedVariables unchanged; these changes affect fresh/default profiles only.
* Retains the 1.0.72 Dark Souls native Health/Magicka/Stamina suppression fix for standalone Fancy Action Bar+.

## 1.0.72

* Promoted the supplied 1.0.71 account-wide Ultivite profile to the fresh-install factory defaults for Frames, Combat and Sound without changing existing users' SavedVariables.
* Default player HUD is no longer Combat Only. Compass, Quest Tracker and Champion Point progress default to Hide in PvP, while Queue/Status remains shown. The Default / Vanilla preset now restores this same visibility baseline instead of carrying Full Dark Souls suppression forward.
* The exported legacy group-frame value is retained but the retired group-frame feature remains inactive; Mount Stamina and Werewolf resource meters are hidden, and the exported player-bar size/positions are the fresh-install defaults.
* Default combat presentation keeps NPC names visible while retaining the exported target-frame, warning, tracker and PvP settings.
* Default sound suppression now includes the three sounds present in the supplied export.
* Fixed Dark Souls Self replacement visibility with standalone Fancy Action Bar+: enabling bottom Health now suppresses native Health, and enabling bottom Magicka/Stamina suppresses their native ESO/FAB-moved bars.
* Dark Souls replacement hiding is enforced per resource bar through ESO visibility requirements, forced-visible references, post-refresh hooks and the layout guardian, so FAB reanchoring cannot resurrect replaced native bars.

## 1.0.71

* Removed the bundled/namespaced Fancy Action Bar+ source completely.
* Fancy Action Bar+ is now a separate required dependency and owns its own runtime, controls and `FancyActionBarSV`.
* Added `UltiviteFABBridge.lua`, a lightweight runtime bridge that talks to the installed FAB+ addon without copying its source.
* Ultivite's Action Bar menu now writes directly to standalone FAB+ settings.
* Safe FAB+ menu sections are mirrored dynamically from the installed addon at runtime, so Ultivite is not carrying a copied FAB menu implementation.
* FAB UI Presets, Actionbar Size & Position and Ability Configuration editors remain in FAB+'s own panel because those editors use internal named controls. Ultivite includes an `Open Full Fancy Action Bar+ Settings` button for them.
* Added a direct mirror for FAB+'s `Accountwide Skill Settings` preference.
* Removed Ultivite's custom Werewolf/Oakensoul back-row enforcement and now leaves weapon-lock row behavior to standalone FAB+.
* Existing Ultivite action-bar profile data is migrated once into standalone FAB+ on upgrade so current scale, position and presentation settings are preserved.
* Removed `FancyActionBarSV` from Ultivite's SavedVariables declaration.
* Required dependencies are now `LibAddonMenu-2.0` and `FancyActionBar+`. Optional compatibility ordering remains only for `Azurah` and `LuiExtended`.

## 1.0.70

* Synced the embedded FAB behavior back toward the current Fancy Action Bar+ 2.19.6 implementation after direct comparison with the clean upstream release.
* Removed Ultivite's redundant full buff/effect rescans on weapon swap. Current FAB already maintains hotbar keyed effect data and remaps it to the correct physical row without rescanning every player buff.
* Removed Ultivite's custom Bound Armaments buff scanning, stack cache and action slot fallback. The current FAB 2.19.6 configuration already maps Bound Armaments to its stack effect and updates stacks through FAB's normal effect pipeline. Ultivite keeps only its stack-only presentation preference by suppressing the duration text for that slot.
* Removed Ultivite's duplicate Crystal Fragments / generic proc glow overlay and related event scanning so ESO/FAB can provide their normal activation animation without a second competing layer.
* Kept Ultivite's strict whole HUD Combat Only option because ESO's native contextual Action Bar mode is not equivalent to strict combat only visibility.
* At this version, Ultivite still retained several integration-specific action-bar behaviors; 1.0.71 removes the bundled FAB runtime entirely and hands FAB-owned behavior back to standalone Fancy Action Bar+.
* SavedVariables and existing profiles are unchanged.

## 1.0.69

* Fixed player Champion Point / level display being suppressed when `Auto hide any other target frame` was enabled.
* ESO's stock `ZO_TargetUnitFramereticleover` frame is now permanently excluded from Ultivite's duplicate target-frame detector.
* If an older Ultivite runtime had already learned the stock target frame as a duplicate, its alpha is restored and the learned reference is discarded automatically.
* Player targets can now use ESO's native target-frame Champion icon and effective CP / level while NPC target-frame hiding remains unchanged.
* SavedVariables and profile data are unchanged.

## 1.0.68

* Consolidated addon runtime modules under the single global `Ultivite` namespace.
* `Frames`, `Combat`, `Sound`, and the then-embedded action bar were consolidated under `Ultivite.Frames`, `Ultivite.Combat`, `Ultivite.Sound`, and `Ultivite.FancyActionBar`.
* Added file-local module aliases and removed the standalone `UltiviteFrames`, `UltiviteCombat`, `UltiviteSound`, and `UltiviteFancyActionBar` globals.
* Converted Ultivite singleton module functions away from implicit `self` method syntax to explicit local module references.
* Removed legacy dependency version comparisons from the addon manifest.
* No SavedVariables keys or profile data were renamed.

## 1.0.67

* Added a new `Vanilla ESO Interface Toggles` submenu at the bottom of `UI Visibility`.
* Added direct mirrors for ESO Interface visibility settings including House Tracker, Quest Tracker, Automatic Quest Tracking, Quest Giver Icons, compass pins, Weapon Indicator, Armor Indicator, Raid Lives, notifications, FPS and latency.
* Added a persistent `Hide all NPC names` master option that captures and restores enemy, friendly and neutral NPC nameplate settings.
* Added direct native nameplate controls for NPC names, player names, group names, overhead Health bars, player titles, guilds and indicators.
* Added native Chat Bubble visibility toggles.
* Native mirrored settings use ESO's public persisted settings API and remain separate from Ultivite's temporary combat/PvP visibility rules.


## 1.0.66

* Promoted UI Visibility into its own main settings section.
* Compass, Quest Tracker, Champion Point progress and Queue/Status now share Show, Hide in combat, Hide in PvP and Hide always modes.
* Added combat-state visibility handling and immediate restore on leaving combat.
* Preserved existing PvP and legacy visibility SavedVariables.

## 1.0.65

* Removed the custom center-screen teammate Champion Point label.
* Added native-style player CP handling through ESO's stock target unit frame.
* New `Show player CP / level in target frame` option allows the stock target frame only for player targets while preserving normal target-frame hiding for NPCs.
* Existing CP progress-bar visibility settings are unchanged.

## 1.0.64

* Removed low resource player bar flashing completely.
* Removed the 100 ms low resource flash update loop and the related settings control.
* Health, Magicka and Stamina bar alpha is no longer modified by a low resource flashing feature.
* Champion Point visibility and teammate CP behavior from 1.0.63 is otherwise unchanged.

## 1.0.63

* Fixed Champion Point `Show always` so the native CP progress bar is attached to both gameplay HUD scenes instead of merely being unhidden.
* Skill and XP progress animations can still temporarily use the native progress bar and it returns to Champion progress afterward.
* Added `Show teammate CP when looking at them`, enabled by default. It displays the actual CP amount for grouped or allied players beside the reticle.
* Kept the teammate CP display separate from ESO's engine-rendered floating nameplates, which do not expose a per-player Lua text control.
* Existing SavedVariables and account-wide profile behavior remain compatible.

## 1.0.62

* Fixed HUD presets incorrectly exposing the Fancy Action Bar drag / mouse-wheel resize overlay.
* Selecting any HUD preset now finishes with player-frame and action-bar editing locked.
* Action-bar scale changes no longer enter edit mode as a geometry refresh hack.
* Manual Unlock controls remain the only way to enter move / resize mode.

## 1.0.61

* Added a dedicated **Hide Mount Stamina meter** visibility toggle, enabled by default.
* Ultivite now wraps ESO's Mount Stamina external visibility requirement so mount-state refreshes cannot bring the meter back while hidden.
* Added direct hard suppression of `ZO_PlayerAttributeMountStamina` as a second visibility guard.
* Added the same setting to both General Visibility and the consolidated UI Visibility hub.
* Added the mount meter preference to account-wide and character profile synchronization.

## 1.0.60

* Added three-state Champion Point progress visibility: Show normally, Hide in PvP only, or Hide always.
* Champion Point progress can now remain available in PvE while being suppressed in Battlegrounds, Cyrodiil and Imperial City.
* Added the same Champion Point visibility control to both General Visibility and the central UI Visibility hub.
* Preserved the legacy Hide Champion Point preference as the Hide always state for existing SavedVariables.

## 1.0.59

* Hides ESO's separate Werewolf resource meter by default so it does not appear beneath Magicka.
* Removes the Werewolf fury value from the Fancy Action Bar Ultimate stack label, leaving the Ultimate slot to display Ultimate information only.
* Expands Player HUD > UI Visibility into a complete visibility control hub with duplicate shortcuts for global HUD, compass, quest tracker, queue/status UI, target frames/nameplates, and action bar visibility.
* Preserves all existing SavedVariables and adds the Werewolf resource meter preference to account-wide and character profile synchronization.

## 1.0.58

* Added an enabled-by-default `Auto hide back bar with Oakensoul / Werewolf` action bar option.
* Oakensoul and Werewolf now force the unavailable inactive action-bar row hidden independently of the broader locked-bar preference.
* The back bar is restored automatically as soon as Oakensoul is removed or Werewolf form ends.
* Kept `Hide other locked Action Bars` as a separate optional rule for other ESO weapon-swap lock states.
* One-bar presentation now consistently drives row visibility, action-bar geometry, quickslot spacing and weapon-swap indicator visibility.

## 1.0.57

* Fixed account-wide Save / Sync using a live module snapshot instead of trusting potentially stale top-level profile table references.
* Save Settings now captures Frames, Combat, Sound and embedded Fancy Action Bar state before requesting a priority save.
* Use This Setup on All Characters now always rewrites the canonical account-wide profile even when account-wide mode is already enabled.
* Account-wide profiles are mirrored into the current character fallback profile to prevent stale character data appearing after a later scope change.
* Added a character-deactivation handoff so the latest live configuration is captured before switching characters.


## 1.0.56

* Fixed LibAddonMenu duplicate-control errors caused by duplicated quick-access Fancy Action Bar settings retaining the same global `reference` control names.
* Quick-access copies now recursively remove LAM control references while preserving their getters, setters, choices and saved settings.
* No SavedVariables keys or profile data were changed.

## 1.0.55

* Fixed the compass disappearing outside PvP when `Hide Compass in PvP` is selected.
* PvP-only compass detection now uses only physical Battleground, Cyrodiil and Imperial City state. The broader AvA-world fallback was removed.
* PvP-only visibility is guarded only while actually inside PvP. Leaving PvP explicitly releases the compass once, then ESO resumes normal scene ownership.
* Stopped changing `Compass Active Quests` as part of compass hiding. That native setting controls quest pins, not the compass frame.
* New profiles default Compass and Quest Tracker visibility to `Hide in PvP`. Existing profiles are not overwritten.
* Promoted the supplied account-wide combat and Fancy Action Bar configuration into the new-profile factory defaults where the exported values represent real user preferences. Runtime K/D/session state and captured native ESO state are intentionally not used as defaults.
* Updated the normal Fancy Action Bar factory layout to keyboard scale 154 at approximately 796.0, 1126.2, matching the supplied active profile.
* Settings export now omits runtime counters and duplicate embedded FAB default snapshots so copied reports remain much smaller and can reach Frames and Sound instead of being cut off inside FAB data.
* Preserved all existing SavedVariables and profile data.

## 1.0.54

* Fixed native Health, Magicka and Stamina bars sometimes reappearing outside combat while Combat HUD Only is enabled.
* Combat Only now physically hides the three primary player bar controls in addition to applying ESO contextual visibility requirements.
* Added native bar refresh hooks so ESO status/contextual updates cannot immediately resurrect a Combat Only bar.
* Fixed the 100 ms low-resource flash updater fighting Combat Only visibility and repeatedly refreshing hidden bars.
* Detects and repairs external visibility requirement drift if ESO or another UI component replaces the callback after Ultivite loads.
* Combat Only no longer takes visibility ownership of mount, siege or other special attribute bars.
* Fixed transient `0  0%` resource text caused by layout refreshes reading nonexistent cached bar values. Resource labels now use live player resource values.

## 1.0.53

* Fixed player Health, Magicka and Stamina bars occasionally reappearing outside combat while Combat Only is enabled.
* The layout guardian now reconciles its cached combat state against ESO's live player combat state.
* Combat Only is reasserted after native attribute visual refreshes and camera/UI scene transitions that can restart ESO's resource-bar timelines.
* Player activation now reapplies combat visibility immediately instead of waiting for another combat-state event.
* Preserved all existing SavedVariables and profile settings.

## 1.0.52

* Fixed PvP-only Quest Tracker restoration when ESO's own Interface > Quest Tracker setting is OFF.
* PvP-only Quest Tracker visibility now controls both the native ESO setting and the HUD control.
* PvP-only Compass visibility now controls the compass frame and ESO's Compass Active Quests setting while the rule is active.
* Native ESO visibility changes are runtime-only and do not overwrite the player's persisted UserSettings values.
* Hide Always uses the same native plus HUD control path, and disabling an Ultivite visibility rule releases the element visibly again.

## 1.0.51

* Added `Show / Copy All Settings` under Advanced & Support > Layout Reset & Support.
* Added `Print All Settings to Chat`.
* Added `/ultivite settings`, `/ultivite export`, `/ultivite copysettings` and `/ultivite printsettings`.
* Export includes the complete active Combat, Frames, Sound and embedded Fancy Action Bar profile, including nested tables, positions, scales, effect configuration and profile scope.
* Export is deterministic and selected automatically for Ctrl+C without using private clipboard APIs.
* Preserved all existing SavedVariables and profile data.

## 1.0.50

* Added a directly visible `Show Wretched Vitality tracker` toggle beside Onslaught and Balorgh in Set & Stack Trackers.
* Kept Wretched Vitality icon size, position and rescan controls in a dedicated settings submenu.
* Preserved the existing `wretchedVitalityTimers` SavedVariable and profile behavior.

## 1.0.49

* Reorganized the complete settings panel around common player tasks.
* Start Here & Quick Setup is now the first settings section.
* Kept Save Settings, Use This Setup on All Characters and Reload UI immediately available.
* Split combat warnings and effects away from trackers, live stats and PvP tools.
* Replaced the single large advanced Fancy Action Bar settings container with clear Bar Appearance & Rows, Timers, Stacks & Ultimate, Skill & Effect Tracking and Other Action Bar Options sections.
* Duplicated the most useful action bar buff and debuff tracking controls under Combat Warnings & Effects while keeping the original controls under Action Bar.
* Cleaned several upstream action bar labels and spelling errors without changing their saved settings.
* Renamed support facing labels such as Copy Positions for GPT to Show Layout Report.
* Added a compact public README, current user guide, ESOUI description and third party credits under the Docs folder.
* Preserved every existing SavedVariables key and profile schema.

## 1.0.48

* Fixed Compass and Quest Tracker PvP only visibility restoration.
* Added separate Hide in PvP and Hide Always controls.
* Removed an overly broad campaign membership fallback from PvP visibility detection.
* Added periodic visibility reconciliation while a hide rule is configured.
* Preserved SavedVariables.

## 1.0.47

* Fixed active back bar buff and timer state being painted against stale front bar layout state after weapon swaps.
* Effect overlays now prefer ESO's live active normal hotbar when routing timers and highlights.
* Weapon swaps rescan slotted buff state and reconcile both action bar rows.
* Preserved SavedVariables.
