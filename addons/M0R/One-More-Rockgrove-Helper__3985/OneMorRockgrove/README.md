# `One M0R Rockgrove Helper`

This is a rockgrove addon designed to assist groups primarily in Oax and Hardmode Bahsei. The majority of features are disabled by default, and should be configured in the addon settings before use.
As this is my first trial specific addon, I have tried to optimize it so that nothing is running when it doesnt need to be, but if you experience your game slowing down while using this addon let me know.

## `Oax`

### Oax Safe Zone Borders
- The addon is able to display the outline of the Oax poison safe zone for both the exit pools, and the entrance left pool.
- Oax's Poison selection behaviour was experiementally derived by @zbzszzzt123 to select 2 random people outside of a safe zone to gain poison. If there are not enough people outside of a safe zone, then oax will choose a random person inside the safe zone. Zeebs experimentally mapped out the exit left safe zone in elms markers. This addon uses their work in addition to my own experimental testing to derive the entrance left safe zone with @Chrissy-T, @jowoll, @Jess182, and @PyroFD3S. In addition, I have mapped out the exit right oax safe zone with @livelifesimply, @RinBC, @Jess182, @Sandman2055, @Trent-Alexios. 
- This is normally only visible in combat, but there are buttons in the settings menu to show and hide the borders regardless of if the player is in combat. In addition, the player can use /showoaxborders or /hideoaxborders to show and hide the borders regardless of combat state.
- By default, this feature is enabled.

### Oax Safe Zone Indicator
- If enabled, the user's screen will tint red if they are outside of a safe zone.
- There is also a setting to swap the behaviour so that the screen will tint if the player is inside of a safe zone, intended for kite healers to know when they enter a safe zone.
- By default, this feature is disabled.


### Oax Safe Zone Line Borders
- This feature will connect lines between each of the markers for the oax safe zones, making it easier to see. There are 2 options for this feature, one using a prerendered image, and one using proper coordinates via Breadcrumbs
- The prerendered image may be more preformance efficient, but will use up more memory and potentially have more bugs/desync than the Breadcrumbs option
- If Breadcrumbs is installed, the addon will draw the lines directly in the field to ensure that the points are accurate. This will use up less memory and be more accurate, but require the addon Breadcrumbs to be installed and use a bit more resources.

## `Bahsei (Hardmode)`

### Good Cone Prediction
- The addon will predict and notify you if it believes that the cone that just spawned is a good or bad cone.
- When the addon determines if the spawned cone is good or bad, it will play a notification at the top center of your screen. In addition it will play a unique audio cue and tint your screen slightly green or red for a few seconds.
- This is identified by if the tank holding bahsei would have to run back across the group to move away from the cone. As such, if the group is very scattered when a cone is spawning, the addon may not correctly identify if a cone is good or bad when it spawns.
- By default, this feature is enabled.

### Initial Cone Movement
- After the first cone spawns, a notification will be played telling the player which corner to go to depending on if the cone is going clockwise or counterclockwise. In addition, a unique audio cue will play.
- As different groups start the fight at different locations, the initial location for a clockwise cone and counterclockwise cone should be configured in the settings. By default, the settings assume that the group is holding Bahsei where she spawns.
- This feature assumes that when the first cone spawns, it will spawn where the group is currently standing.
- By default, this feature is disabled. The initial corners for CW and CCW cones should be configured to your group's playstyle before use.

### Initial Cone Path Guide
- After first cone spawns, this feature will create a line of markers on the ground leading you towards the corner specifed by the Initial Cone Movement feature above.
- This path guide will not function if the feature above is not enabled, and if the initial CW and CCW positions are not properly configured then it will not function properly.
- This feature is experimental, and may not work properly since I have not yet had time to rigorously test it.
- By default, this feature is disabled.

### Initial Cone Movement Line [Requires Breadcrumbs]
- If Breadcrumbs is installed, this feature will create a line between you and the corner you should go to for first cone.

### Group Location while Beaming
- The group's position will be indicated with an icon while you are beaming.
- There is an experimental option to use Breadcrumbs to also make a line that goes to the marker from where you are standing.


### Experimental: Bahsei Portal Segments [Requires Breadcrumbs]
- Will display the split portal area in bahsei portal with lines.
- Labels the sections 1 as entrance, 2 as boring corner, and 3 as portal.




### `Coming Soon:`
- Markers that rotate around the edges of Bahsei's arena to indicate cone direction
- Rockgrove Mechanics Guide
- Oax current charge target [Potentially, will need to look into it more.]
- Bahsei daily bomb endevour [will be disabled by default]

If you have any sugesstions of features or have found any bugs, please let me know either in the comments or via discord: @m0r

### `Requirements:`
- LibAddonMenu2, LibCombatAlerts (included in Codes Combat Alerts)
### `Optional Requirements:`
- Breadcrumbs [Needed for features that place lines]