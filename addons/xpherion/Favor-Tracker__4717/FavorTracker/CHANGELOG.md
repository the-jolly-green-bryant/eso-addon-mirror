# Favor Tracker Changelog

## 1.0.5
- Fixes adding/removing quests in the journal; should properly mark complete in edge cases
- Adjusted cleanup for quest indicies

## 1.0.4
- Overrides fragment show to prevent menus opening the checklist after it's been hidden 

## 1.0.3
- Fixed edge case when quests were not being correctly tracked for completion
- Swapped from scene callbacks to fragments for hiding/showing
- Fixed tracking checklist visibility between sessions and after a daily reset

## 1.0.2
- Fixed folder structure inside ZIP file

## 1.0.1
- Fixed saved vars to use `NewCharacterIdSettings`
- Replaced `RegisterForUpdate` polling
- Made `FavorTracker` table local

## 1.0.0
- Initial release
- Tracks daily Favor quests
- HUD checklist with lock/unlock, drag to reposition
- Auto hides when all favors complete, shows after daily reset
- Slash commands: /favortracker show | hide | toggle | reset | lock | unlock
