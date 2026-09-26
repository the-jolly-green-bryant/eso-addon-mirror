Rytic Combat & Raid Tools 3.0.2-test

AI-assisted development and review. This candidate has passed offline Lua checks,
but has NOT been validated in ESO or reviewed by Super Grok. Do not publish it as
a stable or fully compliant release. See the separate review report for open issues.

CHANGES FROM THE SUPPLIED 3.0.0 ZIP
- Action-bar root visibility is owned by a SimpleSceneFragment in HUD/HUDUI.
  Enabled/dead state is a fragment conditional. Removed competing native-bar
  visibility hooks, manual root alpha changes, and stale death-latch authority.
- Action-bar movement and mouse capture follow the unlock setting.
- Leader assistant revocations are respected and included in outgoing authority.
  Everyone still defaults to assistant before the leader publishes restrictions.
- Group-frame shutdown passes the required event IDs when unregistering listeners.
- PULL! stays visible for 1.2 seconds; an old delayed clear cannot erase a new pull.
- Removed the unused alternate RaidLead source from the package.
- Added an explicit LibGroupBroadcast minimum version (installed AddOnVersion 95).

REQUIRED LIBRARIES (install separately)
LibAddonMenu-2.0 >= 43; LibCombat >= 89; LibGroupBroadcast >= 95.
Optional: LibGroupCombatStats for shared DPS.
Recipients need the compatible add-on and transport to receive Rytic messages.
A leader without the add-on cannot publish Rytic authority restrictions.

INSTALL / TEST
Back up your current RyticTankTools folder and RyticTankSavedVariables.lua first.
With ESO closed, replace the add-on folder using this ZIP. Do not run two copies.
Keep existing SavedVariables. Test menu transitions, death/rez, bar swaps,
transformations, locked/unlocked mode, and leader REMOVE/ASSIST with two clients.
Roll back by restoring the backed-up folder. If needed, restore the SavedVariables
backup while ESO is closed. No files in your installed add-on were changed here.

CREDITS (carried forward from the supplied README)
Hyperioxes - Hyper Tanking Tools: referenced for shield/resource tracking.
Hoft & secretrob - Bandits User Interface: referenced for group frames and
attribute-visualizer behavior. Verify source/texture licenses before publication.
No affiliation with these authors is implied.

ZOS DISCLOSURE
This Add-on is not created by, affiliated with or sponsored by ZeniMax Media Inc.
or its affiliates. The Elder ScrollsÂ® and related logos are registered trademarks
or trademarks of ZeniMax Media Inc. in the United States and/or other countries.
All rights reserved.
https://account.elderscrollsonline.com/add-on-terms
