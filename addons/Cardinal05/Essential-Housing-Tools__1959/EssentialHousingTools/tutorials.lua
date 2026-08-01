if not EHT then EHT = { } end
if not EHT.Tutorials then EHT.Tutorials = { } end
-- /sc StartChatInput(tostring(GetTimeStamp()))
local content = { }
EHT.Tutorials.Content = content

local contentTitles = { }
EHT.Tutorials.ContentTitles = contentTitles

local newSession = true
local newContent

---[ Operations : Tutorials ]---

function EHT.Tutorials.OnlyShowNewTutorials()
	return EHT.SavedVars.TutorialsDisabled
end

function EHT.Tutorials.GetMostRecentTutorialTimeStamp()
	return EHT.Tutorials.OnlyShowNewTutorials() and ( EHT.SavedVars.MostRecentTutorialTimeStamp or 0 ) or 0
end

function EHT.Tutorials.SetMostRecentTutorialTimeStamp( value )
	EHT.SavedVars.MostRecentTutorialTimeStamp = value
end

function EHT.Tutorials.IncreaseMostRecentTutorialTimeStamp( value )
	if not EHT.SavedVars.MostRecentTutorialTimeStamp or EHT.SavedVars.MostRecentTutorialTimeStamp < value then
		EHT.SavedVars.MostRecentTutorialTimeStamp = value
	end
end

function EHT.Tutorials.DisableTutorials( value )
	EHT.SavedVars.TutorialsDisabled = value
	newSession = false

	if value then
		EHT.Tutorials.SetMostRecentTutorialTimeStamp( GetTimeStamp() )
	else
		EHT.Tutorials.SetMostRecentTutorialTimeStamp( nil )
	end
end

function EHT.Tutorials.ResetTutorials()
	EHT.SavedVars.TutorialsShown = { }
	EHT.SavedVars.TutorialsDisabled = false
	EHT.Tutorials.BuildNewContentIndex()
	newSession = true
end

function EHT.Tutorials.GetShownTutorials()
	local shown = EHT.SavedVars.TutorialsShown
	if nil == shown then shown = { } EHT.SavedVars.TutorialsShown = shown end
	return shown
end

function EHT.Tutorials.GetNextTutorial( includeShown )
	if includeShown then
		EHT.Tutorials.DisableTutorials( false )
	end

	local earliestTimeStamp = EHT.Tutorials.GetMostRecentTutorialTimeStamp()
	local shown = EHT.Tutorials.GetShownTutorials()
	local exists

	if nil == newContent then
		EHT.Tutorials.BuildNewContentIndex()
	end

	if includeShown then
		for index, c in ipairs( content ) do
			if	string.lower( c.Title ) ~= "tutorial tips" and
				earliestTimeStamp <= c.TS and
				shown[ c.Title ] and
				nil ~= c.Condition and
				"function" == type( c.Condition ) and
				nil ~= c.Condition() then

				exists = false

				for _, newIndex in ipairs( newContent ) do
					if newIndex == index then
						exists = true
						break
					end
				end

				if not exists then
					table.insert( newContent, index )
				end
			end
		end
	end

	local anchorControl, title, caption, disableCaption, disableHandler = nil, nil, nil, nil, nil

	for newContentIndex, index in ipairs( newContent ) do
		local c = content[ index ]
		if nil ~= c and earliestTimeStamp <= c.TS and ( not disabled or c.Important ) and nil ~= c.Condition and "function" == type( c.Condition ) then
			anchorControl = c.Condition()
			if anchorControl then
				title, caption, disableCaption, disableHandler = c.Title, c.Caption, c.DisableCaption, c.DisableHandler
				shown[ c.Title ] = true
				EHT.Tutorials.IncreaseMostRecentTutorialTimeStamp( c.TS )
				table.remove( newContent, newContentIndex )
				break
			end
		end
	end

	if nil ~= title and string.lower( title ) ~= "tutorial tips" then
		title = string.format( "Tip:  %s", title )
	end

	if not anchorControl then
		newSession = false
	end

	return anchorControl, title, caption, disableCaption, disableHandler
end

function EHT.Tutorials.BuildNewContentIndex()
	newContent = { }
	EHT.Tutorials.NewContent = newContent

	local shown = EHT.Tutorials.GetShownTutorials()
	local c

	for index = 1, #content do
		c = content[ index ]
		if nil ~= c and not shown[ c.Title ] then
			table.insert( newContent, index )
		end
	end
end

function EHT.Tutorials.CreateTip( conditionFunc, title, caption, important, disableCaption, disableHandler )
	if nil == title or "" == title then return end
	if nil == important then important = false end

	if contentTitles[ title ] then
		zo_callLater( function() df( "ERROR: Duplicate Essential Housing Tools tutorial title specified: %s", title ) end, 10000 )
		return
	end

	local index = #content + 1
	table.insert( content, index, { Condition = conditionFunc, Title = title, Caption = caption, Important = important, DisableCaption = disableCaption, DisableHandler = disableHandler } )

	local thisContent = content[index]
	thisContent.TS = 0
	contentTitles[ title ] = true

	return thisContent
end

local createTip = EHT.Tutorials.CreateTip

---[ Tutorials Tips ]---

local gtt = EHT.UI.GetCurrentToolTab
local gbutton = function() local button = EHT.UI.SetupEHTButton() if nil ~= button and EHT.Housing.IsOwner() then return button.Window end end
local ctrl = "|c00ffff"
local highlight = "|cffff00"

---[ Context Menu ]---

createTip(
	function() return gbutton() end,
	"Join the Housing Community",
	"Host an Open House, add a Guest Journal for visitors to sign-in and even Publish FX " ..
	"with one-click to the entire Player Community|r.\n\n" ..
	"Install our new " .. highlight .. "Essential Housing Community|r app - " ..
	"now available for both Mac and Windows - and join a growing Community of like-minded " ..
	"builders, designers and creators.",
	true,
	"Get the App",
	EHT.UI.ShowCommunityAppDialog
)

createTip(
	function() return gbutton() end,
	"Quick Access Toggles",
	"Place your cursor over the " .. highlight .. "EHT|r button to quickly view and change " .. highlight .. "Grid|r and " .. highlight ..
	"Selection|r toggles:\n\n" ..
	"- Toggle the " .. highlight .. "Selection|r box and check marks on or off.\n\n" ..
	"- Toggle the " .. highlight .. "Grid|r lines and snapping on or off.\n\n" ..
	"- Click the " .. highlight .. zo_iconFormat( "esoui/art/compass/ava_returnpoint_neutral.dds" ) .. " Adjust|r option to " ..
	"pan, scale and rotate the " .. highlight .. "Grid|r."
)

createTip(
	function() return gbutton() end,
	"One-Click Tools",
	"The " .. highlight .. "EHT|r button's pop-up menu also provides quick access to common functions including:\n\n" ..
	"- " .. highlight .. "Copy|r, " .. highlight .. "Cut|r and " .. highlight .. "Paste|r your selected items within the same home or even to a different home.\n\n" ..
	"- " .. highlight .. "Link|r and " .. highlight .. "Unlink|r your selected items to create or break apart groups.\n\n" ..
	"- " .. highlight .. "Lock|r and " .. highlight .. "Unlock|r your selected items to prevent accidental changes to them.\n\n" ..
	"- " .. highlight .. "Undo|r and " .. highlight .. "Redo|r your recent changes.\n\n" ..
	"- Access and restore " .. highlight .. "Backups|r of your entire home that are automatically captured by Essential Housing Tools."
)

createTip(
	function() return gbutton() end,
	"EasySlide(tm)",
	"Now, you can |c00ffffClick and Hold|r items to drag them in a perfectly straight line along any axis.\n\n" ..
	"Note that you may continue to |c00ffffSingle Click|r items to edit them using the game's default editing behavior.\n\n" ..
	"EasySlide(tm) can be toggled ON or OFF directly from the EHT button's Shortcuts & Options menu.",
	true
)

---[ General ]---

createTip(
	function() if gtt() == EHT.CONST.TOOL_TABS.SELECT then return EHT.UI.ToolDialog.HelpButton end end,
	"Tutorial Tips",
	"Want some help? Click the " .. zo_iconFormat( "esoui/art/help/help_tabicon_tutorial_up.dds" ) ..
	" button for relevant tips about the current Tab."
)

createTip(
	function() if gtt() == EHT.CONST.TOOL_TABS.SELECT then return EHT.UI.ToolDialog.VideoGuideButton end end,
	"Watch and Learn",
	"Click the " .. zo_iconFormat( EHT.Textures.ICON_YOUTUBE ) ..
	" button to open the " .. EHT.ADDON_TITLE .. " Video Guide playlist in YouTube which covers:\n\n" ..
	"Getting Started\n" ..
	"Selecting, Editing and Copying Items\n" ..
	"Undoing Changes and Backing Up your Home\n" ..
	"Adding FX\n" ..
	"Animating Items\n" ..
	"Automating Interactive Items\n" ..
	"Building with Items"
)

---[ FX ]---

createTip(
	function() return gbutton() end,
	"Special FX",
	"Add magic to your home - without the need for materials or item slots. " ..
	"Choose from custom lighting, an ominous sky, written text and much more... " ..
	"there are " .. highlight .. "over 1,000 FX|r to choose from.\n\n" ..
	"To get started, just " .. highlight .. "Mouse Over|r the " .. ctrl .. "EHT|r button and click " .. ctrl .. "FX|r.\n\n" ..
	"Browse by category or type a phrase into the search box at the bottom of the window to find FX.\n\n" ..
	highlight .. "Mouse Over|r most FX to see a live preview, then " .. highlight .. "Click|r one to add it to your home."
).TS = 1568941327

createTip(
	function() return gbutton() end,
	"Editing FX",
	"Once you have added any FX to your home, " .. highlight .. "Click|r the " .. ctrl ..
	zo_iconTextFormat( "esoui/art/dye/dyes_toolicon_fill_down.dds", 30, 30, "", true ) .. "|r icon to open the " .. highlight ..
	"FX Editor|r panel.\n\n" ..
	"Use the " .. ctrl .. "Arrows|r to move, rotate and resize and the " .. ctrl .. "Color Wheel|r to recolor any FX.\n\n" ..
	"You can also " .. highlight .. "Click + Hold|r the " .. ctrl ..
	zo_iconTextFormat( "esoui/art/dye/dyes_toolicon_fill_down.dds", 30, 30, "", true ) ..
	"|r icon to drag FX wherever you want.\n\n" ..
	"To edit certain unique FX, such as Sky Overlays, just " .. highlight .. "Click|r their " ..
	"name in the " .. ctrl .. "Global Effects|r list that automatically appears in the corner " ..
	"of your screen when any of global FX are added."
).TS = 1568941327

---[ Selections ]---

createTip(
	function() if gtt() == EHT.CONST.TOOL_TABS.SELECT then return EHT.UI.ToolDialog.SettingsButton end end,
	"Integration with DecoTrack",
	EHT.ADDON_TITLE .. " now has support for DecoTrack - with even more features on their way in future updates.\n\n" ..
	"The Item Placement HUD can display information about items as you are placing them, including:\n" ..
	"- Position and Distance\n" ..
	"- Orientation\n" ..
	"- Relevant Item Limits\n" ..
	"And when you have DecoTrack installed and active, the HUD will also display how many of that item that you have in your:\n" ..
	"- Current House\n" ..
	"- Other Houses\n" ..
	"- Other Characters\n" ..
	"- Storage Chests and Coffers\n" ..
	"- Bank"
)

createTip(
	function() if gtt() == EHT.CONST.TOOL_TABS.SELECT then return EHT.UI.ToolDialog.SelectionTabButton end end,
	"What are Selections?",
	"Selections are the foundation of\n" .. EHT.ADDON_TITLE .. ".\n\n" ..
	"One or more furniture items can be grouped to form a Selection. Once selected, the group of items can then be:\n\n" ..
	"- Moved and rotated\n" ..
	"- Arranged and aligned\n" ..
	"- Saved and later re-selected\n" ..
	"- Restored to their last saved positions\n" ..
	"- Copied and pasted\n" ..
	"- Shaped with a build\n" ..
	"- Animated in a scene\n" ..
	"- Automated by a trigger\n" ..
	"  and more..."
)

createTip(
	function() if gtt() == EHT.CONST.TOOL_TABS.SELECT then return EHT.UI.ToolDialog.SelectionType end end,
	"Selecting Items",
	"Before selecting items, you should first open\n" ..
	ctrl .. "Controls|r, scroll down to\n" ..
	ctrl .. "Housing Editor|r || " .. ctrl .. "Essential Housing Tools|r\n" ..
	"and assign a key for " .. ctrl .. "Select / Deselect|r."
)

createTip(
	function() if gtt() == EHT.CONST.TOOL_TABS.SELECT then return EHT.UI.ToolDialog.SelectionType end end,
	"Target and Select",
	"Once you have assigned a key for\n" .. ctrl .. "Select / Deselect|r, " ..
	"you may begin selecting items.\n\n" ..
	"Enter " .. ctrl .. "Housing Editor|r mode, target an item and press the " .. ctrl .. "Select / Deselect|r key.\n\n" ..
	"The item that you target will be added to the current Selection."
)

createTip(
	function() if gtt() == EHT.CONST.TOOL_TABS.SELECT then return EHT.UI.ToolDialog.SelectionType end end,
	"Selection Mode",
	"The Selection Mode allows you to multi-select groups of items that are near or related to the item that you target.\n\n" ..
	ctrl .. "Single Item|r selects only the targeted item.\n" ..
	ctrl .. "Radius|r includes items surrounding the targeted item.\n" ..
	ctrl .. "Connected Items|r branches out to include any items directly, or indirectly, touching the targeted item.\n" ..
	ctrl .. "All Items|r selects all items.\n\n" ..
	"Note: Modes containing " .. ctrl .. "Same As Target|r only include items that are the same exact item as the targeted item.\n\n" ..
	"For example, selecting a |H1:item:119866:4:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h while using the " .. ctrl .. "Radius (Same As Target)|r mode " ..
	"will only select other |H1:item:119866:4:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h items near the targeted item.",
	true
)

createTip(
	function() if gtt() == EHT.CONST.TOOL_TABS.SELECT then return EHT.UI.ToolDialog.Buffer end end,
	"Selected Item List",
	"The items that you have selected appear " .. highlight .. "here|r.\n\n" ..
	ctrl .. "Left-click|r an item to remove it from the Selection.\n" ..
	ctrl .. "Right-click|r an item to show a visual indicator on the furniture item."
)

createTip(
	function() if gtt() == EHT.CONST.TOOL_TABS.SELECT then return EHT.UI.ToolDialog.SelectionSort end end,
	"Selecting From All Items",
	"If you prefer to select items from a list, rather than " .. highlight .. "Target and Select|r items, " ..
	"you can do so.\n\n " ..
	"Just choose one of the " .. highlight .. "All Items|r options from the " .. ctrl .. "View|r " ..
	"option list. This will list every single item placed in the home, allowing you to " .. highlight ..
	"left-click|r items to select or deselect them.\n\n" ..
	"This method is particularly useful if you are decorating in another player's home."
)

createTip(
	function() if gtt() == EHT.CONST.TOOL_TABS.SELECT then return EHT.UI.ToolDialog.Buffer end end,
	"Reordering Selected Items",
	"Shapes constructed with the " .. highlight .. "Builds|r tab " ..
	"are always built from your selected items.\n\n" ..
	"When building, it can sometimes be helpful to reorder the selected items. " ..
	"To change the order of your selection, switch the " .. ctrl .. "View|r to " ..
	highlight .. "Selected Items Only|r.  Then, drag any item up or down to change " ..
	"its order within the list.",
	true
)

createTip(
	function() if gtt() == EHT.CONST.TOOL_TABS.SELECT then return EHT.UI.ToolDialog.SelectionName end end,
	"Saving and Loading Selections",
	"To save a Selection, enter a name for the Selection and click " .. ctrl .. "SAVE|r.\n\n" ..
	"You can load any Saved Selection simply by choosing it from the drop down list. Doing so will re-select all of the saved Selection's items. " ..
	"Note that any unsaved selections made in the current Selection will be lost.\n\n" ..
	"To revert a Selection's items to their last saved positions and orientations, click\n" ..
	ctrl .. "REVERT TO LAST SAVE|r. This can be used to create backups of groups of furniture or even an entire home."
)

createTip(
	function() if gtt() == EHT.CONST.TOOL_TABS.SELECT then return EHT.UI.ToolDialog.ArrangeDropdown end end,
	"Arranging Selected Items",
	"Choose an arrangement option at any time to quickly arrange your Selection's items, including center, align and level options."
)

createTip(
	function() if gtt() == EHT.CONST.TOOL_TABS.SELECT then return EHT.UI.ToolDialog.ClipboardButton end end,
	"Copy and Paste",
	"Click " .. ctrl .. "Copy & Paste|r to:\n\n" ..
	"- Copy the current Selection's items to the Clipboard.\n" ..
	"- Cut the current Selection's items, removing them from the house and copying them to the Clipboard.\n" ..
	"- Paste a copy of the Clipboard's items into your house.\n" ..
	"- View the Clipboard's items.\n" ..
	"- Import and export Clipboards to share with friends.\n\n" ..
	"Note that pasting the Clipboard into the house requires that " ..
	"you have the items listed on the Clipboard " ..
	"in your Inventory, Bank or House Storage Containers."
)

---[ Scenes ]---

createTip(
	function() if gtt() == EHT.CONST.TOOL_TABS.ANIMATE then return EHT.UI.ToolDialog.AnimateTabButton end end,
	"What are Scenes?",
	"Scenes move or animate your furniture items over a series of Frames. " ..
	"Any items added to a Scene can be animated by adjusting their positions or orientations from Frame to Frame.\n\n" ..
	"Examples of Scenes:\n" ..
	" - A door opening\n" .. 
	" - A bridge that builds itself\n" .. 
	" - A swirling circle of crystals\n" .. 
	" - A simple 1-Frame Scene that rearranges a room or an entire house"
)

createTip(
	function() if gtt() == EHT.CONST.TOOL_TABS.ANIMATE then return EHT.UI.ToolDialog.NewSceneButton end end,
	"Making a Scene",
	"To create a Scene, first use the " .. ctrl .. "SELECT|r tab to select one or more furniture items.\n\n" ..
	"Once you have selected the items to use in the Scene, return to this tab (" .. ctrl .. "SCENES|r) and click " .. ctrl .. "NEW SCENE|r.\n\n" ..
	"While it is best to start a new Scene with all of the items to be animated, you may add more items to the Scene by selecting additional items and clicking\n" ..
	ctrl .. "IMPORT SELECTION|r.\n\n" ..
	"If you want to edit all of the Scene's items as a group or if you forget which items are used in the Scene, you may click\n" ..
	ctrl .. "SELECT SCENE ITEMS|r."
)

createTip(
	function() if gtt() == EHT.CONST.TOOL_TABS.ANIMATE then return EHT.UI.ToolDialog.RecordButton end end,
	"Scene Editing",
	"Click " .. ctrl .. "RECORD|r to automatically capture each change made to the furniture used in your Scene as a new Frame\n\n" ..
	"Or\n\n" ..
	"Make changes to the furniture items, click " .. ctrl .. "SAVE FRAME|r and then click " .. ctrl .. "INSERT >|r to create a new Frame. " ..
	"Repeat this process until you have created all of the animation Frames.\n\n" ..
	"Note that you may also set up the keybinds for " .. ctrl .. "Save Frame|r and " ..
	ctrl .. "Save and Insert New Frame|r under " .. ctrl .. "Controls|r to speed up the frame creation process."
)

createTip(
	function() if gtt() == EHT.CONST.TOOL_TABS.ANIMATE then return EHT.UI.ToolDialog.StopButton end end,
	"Scene Playback",
	"Use the playback controls to play, stop and rewind your current Scene. " ..
	"You can also scrub through or skip forward or backward with the Frame timeline. " ..
	"Check " .. ctrl .. "LOOP|r to automatically repeat the Scene during playback."
)

createTip(
	function() if gtt() == EHT.CONST.TOOL_TABS.ANIMATE then return EHT.UI.ToolDialog.RecordButton end end,
	"Scene Capabilities",
	"When recording a Scene or when manually creating or editing Scene Frames, "..
	"the following changes are now captured per frame:\n\n" ..
	" - Item Position\n" ..
	" - Item Orientation\n" ..
	" - Item State (On, Off, etc.)"
)

createTip(
	function() if gtt() == EHT.CONST.TOOL_TABS.ANIMATE then return EHT.UI.ToolDialog.FrameDurationBackdrop end end,
	"Animation Speed",
	"You can control how long each Frame is displayed by entering a " .. ctrl .. "FRAME DURATION|r in seconds. " ..
	"Note that you may use Frame Durations as low as 0.1 seconds.\n\n" ..
	"Changing the Frame Duration affects the current Frame. To update the Frame Duration of the Frames that follow the current Frame, click\n" ..
	ctrl .. "Update duration of all subsequent frames|r."
)

createTip(
	function() if gtt() == EHT.CONST.TOOL_TABS.ANIMATE then return EHT.UI.ToolDialog.SceneToolsDropdown end end,
	"Scene Tools",
	"There are a variety of tools that you can access to help manage your Scene here, including:\n\n" ..
	" - Repositioning your Scene\n" ..
	" - Copying your Scene\n" ..
	" - Reversing your Scene\n" ..
	" - Merging Scenes\n" ..
	" - Adding items to your Scene\n" ..
	" - Removing items from your Scene\n" ..
	" - Re-selecting your Scenes items"
)

---[ Triggers ]---

createTip(
	function() if gtt() == EHT.CONST.TOOL_TABS.TRIGGERS then return EHT.UI.ToolDialog.TriggerTabButton end end,
	"Trigger Requirements",
	"Triggers can do lots of cool things but here are a few quick things you should know:\n\n" ..
	"- Triggers only work when " .. EHT.ADDON_TITLE .. " is enabled.\n\n" ..
	"- Triggers only work when you are in the home.\n\n" ..
	"- Triggers that you create only work in your own home; however, you can activate item-based Triggers (such as toggling a switch) created by other players in their homes."
)

---[ History ]---

createTip(
	function() if gtt() == EHT.CONST.TOOL_TABS.HISTORY then return EHT.UI.ToolDialog.HistoryBuffer end end,
	"Change History",
	"Changes made to this house are tracked here, including:\n\n" ..
	"- Adding new items.\n" ..
	"- Removing existing items.\n" ..
	"- Moving or rotating items.\n\n" ..
    "The most recent changes are always at the bottom of this list."
)

createTip(
	function() if gtt() == EHT.CONST.TOOL_TABS.HISTORY then return EHT.UI.ToolDialog.UndoButton end end,
	"Undo and Redo Changes",
	"You may click " .. ctrl .. "Undo|r to undo the most recent change.\n\n" ..
	"Similarly, you may click " .. ctrl .. "Redo|r to redo the most recently undone change.\n\n" ..
	"Note that the most recently undone or redone change is denoted with " .. highlight .. "<<<|r."
)

createTip(
	function() if gtt() == EHT.CONST.TOOL_TABS.HISTORY then return EHT.UI.ToolDialog.ShowBackupsButton end end,
	"Automatic Backups",
	"To view a list of automatically saved backups of this home's furniture, click " .. ctrl .. "Automatic Backups|r.\n\n" ..
	"From there, you may choose to " .. ctrl .. "Restore|r a backup, returning all of your furniture to their location and orientation at the time the backup was saved.\n\n" ..
	"You may also choose to manually save a backup by clicking " .. ctrl .. "Create a new backup now|r."
)

EHT.Modules = ( EHT.Modules or { } ) EHT.Modules.Tutorials = true
