Rytic's Raid Manager v1.1
Author: Rytic

PURPOSE
Rytic's Raid Manager builds a smart raid addon profile from installed addons, character class,
selected group role, current trial, user-saved profile entries, and required dependencies.
It can snapshot the current addon state before Raid Mode and restore that exact state later.

COMMANDS
/rrm show
/rrm hide
/rrm save
/rrm raid
/rrm restore
/rrm profile
/rrm addons


v1.1 - TRIAL-ONLY ENTRY / EXIT PROMPTS
- Removed the Auto Prompt toggle; automatic trial checks are always enabled.
- Entering a recognized Trial while in Normal mode prompts to load Raid Mode.
- Leaving a recognized Trial while Raid Mode is active prompts to restore the saved pre-raid addon state.
- Housing, delves, public dungeons, group dungeons, and arenas do not trigger automatic prompts.
- Manual RAID MODE and RESTORE controls remain available.
- Trial state is stored in account-wide, server-separated SavedVariables so ReloadUI preserves entry/exit tracking.

v1.0 - AUTO PROMPT ALWAYS ENABLED
- Removed the Auto Prompt UI toggle and /rrm auto commands.
- Instance entry/exit prompt checks are always enabled.
- This test build otherwise preserves the known-good all-instance detection behavior.

v0.3.1 - ESOUI RELEASE PASS
- Uses an ESO HUD scene fragment for the RRM window.
- Window automatically hides when HUD/HUD UI scenes hide for menus and returns with HUD.
- Manual HIDE state remains independent from scene visibility.
- Added numeric AddOnVersion manifest field.
- Uses current U51 API version 101051.
- Uses account-wide SavedVariables separated by GetWorldName().
- Uses ZO_Dialogs_RegisterCustomDialog for the Raid Mode prompt.
- No bundled libraries, executables, or development files.

v0.2.6
ORPHAN DEPENDENCY SCAN
/rrm addons builds a reverse dependency map across ALL installed addons, including disabled addons.
Each inventory line shows declared dependencies, USED BY, and POSSIBLE ORPHAN for libraries with
no installed addon declaring them as a dependency. Nothing is automatically deleted.

ROLE / PROFILE BEHAVIOR
- Combat Metrics: always in raid profile
- Combat Metronome: DPS only
- Healing Meter: healer
- current-class Mastery
- current-trial helpers
- recursive required dependencies

ESOUI DESCRIPTION NOTE
Development assistance included OpenAI ChatGPT for code review/refactoring and release-compliance
checking. Final addon behavior and release are maintained by Rytic.

v0.3.1 - ESOUI fragment compliance correction
- Defers HUD/scene fragment setup until EVENT_PLAYER_ACTIVATED.
- Uses ZO_HUDFadeSceneFragment:New(window, nil, 0).
- Uses fragment StateChange with SCENE_FRAGMENT_SHOWN / SCENE_FRAGMENT_HIDDEN.
- Attaches the same fragment to HUD_SCENE and HUD_UI_SCENE.
- Manual HIDE removes the fragment from both scenes; SHOW reattaches it.
- Removed SetConditional / SetHiddenForReason visibility handling.
- No menu polling or ad-hoc menu hooks.


TRIAL-ONLY TEST PASS
- Automatic prompt now appears only when entering a recognized Trial.
- No automatic prompt in housing, delves, public dungeons, group dungeons, or arenas.
- Leaving a Trial while Raid Mode is active prompts to restore the saved pre-raid addon state.
- Auto Prompt toggle remains removed.
- Existing RAID MODE / RESTORE behavior is otherwise unchanged.
