-- ************************************************************
-- ***** ScrollListExample 
-- ************************************************************

--[[
Title: ScrollListExample
Description: Example of ScrollList implementation
Author: pills
Date: 2014-06-06

@NOTES
>>> Taken From MailR which took it from Librarian


>>> Entirely rewritten by ShadowMau to update for current API, a different use application, and added 
>>> documentation plus some current recommended practices.  The originals are included for those are are curious.
 
Much has changed in the 7 years since this was originally written so I decided to entirely rewrite this example.
I tried to stay true to what I surmise was the original intent of the author, which was to provide a simple
example that demonstrates the major elements of scroll lists.  From the example, a person should learn enough
to be able to apply the concepts to more complex applications.  There is no error checking in this example.  Error
checking should be added by the programmer given their specific application.  I learned much of this from LibScroll
(https://www.esoui.com/downloads/info1151-LibScroll.html) and many of the ideas here are derived from it.

I also added in a lot of documentation and a few examples on a couple ways to accomplish the same results.
I am in no way an expert in Lua, XML, or scroll lists so someone more experienced may look at this and wonder
why I did something a certain way when there may be a better way to do it.  Thank you for your understanding.

]]


-- ************************************************************
-- ***** Initialize data and settings
-- ************************************************************


--------------------------------------------------
-- Create a local table to contain all of our stuff so we don't pollute the global name space
-- and so we don't have to worry about what order we define or call our functions.
-- Creating a table and placing it into the global name space is how people can make
-- things like libraries of reusable code (like LibAddonMenu2).
-- There are some other things we could do using local variables and functions, but
-- for this example we will just place our functions and most variables into our table.
-- I tend to use the addon's name as the name of the table so I don't accidentally conflict.
--------------------------------------------------


--------------------------------------------------
-- Initialize addon variables
--------------------------------------------------
local ScrollListExample = {}
ScrollListExample.name = "ScrollListExample"
ScrollListExample.slashCommand = "/sle"


--------------------------------------------------
-- Link local variables to the in-game Globals
--------------------------------------------------
ScrollListExample.typePets = COLLECTIBLE_CATEGORY_TYPE_VANITY_PET -- ZOS GLOBAL


--------------------------------------------------
-- Default saved variable settings
-- We are not using any saved variables with is addon.
-- This is just a hold-over from my addon template provided for reference
--------------------------------------------------
ScrollListExample.accountDefaults = {
}

ScrollListExample.characterDefaults = {
}


-- ************************************************************
-- ***** Main Function
-- ************************************************************

--------------------------------------------------
-- Main Program Function: Initialize settings, load saved variables and register event triggers.
--------------------------------------------------
function ScrollListExample.Main()
	--------------------------------------------------
	-- Use CSV for character specific saved variables
	-- Use ASV for account wide saved variables
	-- Again a hold-over from my template provided as an example
	--------------------------------------------------
	-- ScrollListExample.CSV = ZO_SavedVars:NewCharacterIdSettings("ScrollListExampleSavedVariables", 1, nil, ScrollListExample.characterDefaults, GetWorldName())
	-- ScrollListExample.ASV = ZO_SavedVars:NewAccountWide("ScrollListExampleSavedVariables", 1, nil, ScrollListExample.accountDefaults, GetWorldName())
	
	SLASH_COMMANDS[ScrollListExample.slashCommand] = ScrollListExample.ProcessSlashCommand
	
	ScrollListExample.CreateMainWindowControl() 	-- Step 1
	ScrollListExample.CreateScrollListControl() 	-- Step 2
	ScrollListExample.CreateScrollListDataType() 	-- Step 3
	local pets = ScrollListExample.Populate()		-- Step 4
	local typeId = 1 -- We defined this when we created the data type.  Don't really need to decare it here, but did so for this example.
	d("PETS")
	d(pets)
	ScrollListExample.UpdateScrollList(ScrollListExample.controlScrollList, pets, typeId) -- Step 5
end


--------------------------------------------------
-- Process commands sent by using the slash command feature
--------------------------------------------------
function ScrollListExample.ProcessSlashCommand(cmd)
	if cmd == "hide" then
		ScrollListExample.controlMainWindow:SetHidden(true)
	elseif cmd == "show" then
		ScrollListExample.controlMainWindow:SetHidden(false)
	end
end


-- ************************************************************
-- ***** Scroll List Functions
-- ************************************************************


--------------------------------------------------
-- Step 1: Make a window with background to display our scroll list.  This could also be done with xml.
--------------------------------------------------
function ScrollListExample.CreateMainWindowControl()
	-- Create a top level window.  User can adjust size, placement, and other settings later using the control we store.
	-- See: https://wiki.esoui.com/Controls and https://wiki.esoui.com/UI_XML
	-- See: https://wiki.esoui.com/Controls#WindowManager for more info
	ScrollListExample.controlMainWindow = WINDOW_MANAGER:CreateTopLevelWindow("ScrollListExampleWindow")
	ScrollListExample.controlMainWindow:SetAnchor(RIGHT, GuiRoot, RIGHT) 
	ScrollListExample.controlMainWindow:SetDimensions(550, 400) 
	ScrollListExample.controlMainWindow:SetHidden(false)
	
	-- Create a background (optional)  -  See https://wiki.esoui.com/Controls#BackdropControl for more info
	ScrollListExample.controlMainWindowBackground = WINDOW_MANAGER:CreateControlFromVirtual("ScrollListExampleWindowBg", ScrollListExample.controlMainWindow, "ZO_DefaultBackdrop")
	ScrollListExample.controlMainWindowBackground:SetAnchorFill(ScrollListExample.controlMainWindow)
	-- I have found that creating the background from virtual, that I could adjust the alpha, but not the color.
	-- If you would like to be able to change the background color you could also use:
	-- ScrollListExample.controlMainWindowBackground = WINDOW_MANAGER:CreateControl("ScrollListExampleWindowBg", ScrollListExample.controlMainWindow, CT_BACKDROP)
end


--------------------------------------------------
-- Step 2: Make a control in our main window to display our scroll list.  This could also be done with xml.
--------------------------------------------------
function ScrollListExample.CreateScrollListControl()
	ScrollListExample.controlScrollList = WINDOW_MANAGER:CreateControlFromVirtual("ScrollListExampleList", ScrollListExample.controlMainWindow, "ZO_ScrollList")
	local width, height = ScrollListExample.controlMainWindow:GetDimensions()
	ScrollListExample.controlScrollList:SetDimensions(width, height)
	ScrollListExample.controlScrollList:SetAnchor(LEFT, ScrollListExample.controlMainWindow, LEFT)
end


--------------------------------------------------
-- Step 3: Make the scroll list data type
--------------------------------------------------
function ScrollListExample.CreateScrollListDataType()
	--[[
		https://github.com/esoui/esoui/blob/e554eb0d0a24ad9b49c0a775a1e18babf8ef54d4/esoui/libraries/zo_templates/scrolltemplates.lua#L789
		ZO_ScrollList_AddDataType(control self, number typeId, string templateName, number height, function setupCallback, function hideCallback, dataTypeSelectSound, function:nilable resetControlCallback)
		This function registers a data type for the list to display.
		The typeId must be unique to this data type. It's okay if data types in completely different scroll lists have the same identifiers.
		The templateName is the name of the virtual control that will be used to create list item controls for this data type.
		The setupFunction is a function that will be used to set up a list item control. It will be passed two arguments: the list item control, and the list item data.
		The dataTypeSelectSound will be played when a row of this type is selected.
		The resetControlCallback will be called when a list item control goes out of use.
	]]
	local control = ScrollListExample.controlScrollList
	local typeId = 1
	local templateName = "ZO_SelectableLabel"
	local height = 25 -- height of the row, not the window
	local setupFunction = ScrollListExample.LayoutRow
	local hideCallback = nil
	local dataTypeSelectSound = nil
	local resetControlCallback = nil
	local selectTemplate = "ZO_ThinListHighlight"
	local selectCallback = ScrollListExample.OnRowSelect
	
	ZO_ScrollList_AddDataType(control, typeId, templateName, height, setupFunction, hideCallback, dataTypeSelectSound, resetControlCallback)
	ZO_ScrollList_EnableSelection(control, selectTemplate, selectCallback)
end


--------------------------------------------------
-- Step 4: Populate the unlocked pets list to make our scroll list
--------------------------------------------------
function ScrollListExample.Populate()
	local pets = {}
	local petcounter = 0
	local unlockedpets = GetTotalUnlockedCollectiblesByCategoryType(ScrollListExample.typePets)
	
	if unlockedpets > 0 then
		for count = 1, GetTotalCollectiblesByCategoryType(ScrollListExample.typePets) do
			local index = GetCollectibleIdFromType(ScrollListExample.typePets, count)
			local p1, p2, p3, p4, p5, p6, p7, p8, p9 = GetCollectibleInfo(index)
			if p5 then
				petcounter = petcounter + 1
				local petNameClean = ZO_CachedStrFormat(SI_UNIT_NAME, p1)
				pets[petcounter] = {
					index = index,
					name = petNameClean,
					description = p2,
					texture = p3
				}
			end
		end
		-- table.sort(pets, function(a,b) return a[2] < b[2] end)
	end
	return pets
	--[[ 
		GetCollectibleInfo() returns
		p1 = name(string)
		p2 = description(string)
		p3 = path to the item's texture if unlocked
		p4 = path to the item's texture if locked
		p5 = unlocked(boolean)
		p6 = purchasable(boolean)
		p7 = isActive(boolean)
		p8 = Collectible Category Type (number matches the constant used in pre-initialize)
		p9 = hint text for finding the item
	]]--
end


--------------------------------------------------
-- Step 5: Update any changes to a scroll list data table then commit those changes to the screen
-- Repeat this step as needed if you have a data table that will have changing data (like an inventory).
--------------------------------------------------
function ScrollListExample.UpdateScrollList(control, data, rowType)
	--[[ 	Adds data to the datalist already stored in the control  rowtype is the typeId we assigned in CreateScrollListDataType.
		
			From LIbScroll:
			"Must use ZO_DeepTableCopy or it WILL crash if the user passes in a dataTable that is stored in saved variables.
			This is because ZO_ScrollList_CreateDataEntry creates a recursive reference to the data.
			Although this is only necessary for data saved in saved vars, I'm doing it to protect users against themselves"
	--]]
	local dataCopy = ZO_DeepTableCopy(data)
	local dataList = ZO_ScrollList_GetDataList(control)
	
	-- Clears out the scroll list.  Dont' worry, we made a copy called dataList.
	ZO_ScrollList_Clear(control)
	
	-- Create the data entries for the scroll list from the copy of the new data table.
	for key, value in ipairs(dataCopy) do
		local entry = ZO_ScrollList_CreateDataEntry(rowType, value)
		table.insert(dataList, entry) -- By using table.insert, we add to whatever data may already be there.
	end
	
	-- Sort if needed.  In our case we want to sort by pet name
	table.sort(dataList, function(a,b) return a.data.name < b.data.name end)
	 
	-- Redraw the scroll list.
	ZO_ScrollList_Commit(control)
end


--------------------------------------------------
-- Step 6: Layout the scroll list data however we like.
-- This is automatically called when the line of the scroll list becomes visible on the screen.
--------------------------------------------------
function ScrollListExample.LayoutRow(rowControl, data, scrollList)
	-- The rowControl, data, and scrollListControl are all supplied by the internal callback trigger
	-- What is contained in data is determined by the structure of the table of data items you used
	--[[ Copied here from where we created the data so we can easily reference the data structure
	pets[petcounter] = {
		index = index,
		name = petNameClean,
		description = p2
		texture = p3
	}
	]]
	rowControl:SetFont("ZoFontWinH4")
	rowControl:SetMaxLineCount(1) -- Forces the text to only use one row.  If it goes longer, the extra will not display.
	rowControl:SetText(data.name)
	
	-- When we added the data type earlier we also enabled being able to select an item and which function to run
	-- when an row is slected.  We still need to set up a handler to actuall register the mouse click which
	-- then triggers the row as "selected".  See https://wiki.esoui.com/UI_XML#OnAddGameData and following
	-- entries for "On" events that can be set as handlers.
	rowControl:SetHandler("OnMouseUp", function() ZO_ScrollList_MouseClick(scrollList, rowControl) end)
	
	-- Just for fun!!
	-- Put together a tooltip string to display when the user positions mouse over the scroll list row.
	-- https://wiki.esoui.com/How_to_format_strings_with_zo_strformat#Concatenating_lists
	-- Using \n inserts a newline to bump the image down a bit.  There may be a better way to do this,
	-- but I find \n frequently used in the source code so the developers use it too.
	-- Added in a spacer |u to move the texture over a bit so it was not tight against the left side.
	-- https://wiki.esoui.com/Text_Formatting  |u40:0:: |u
	local concatToolTip = {}
	table.insert(concatToolTip, "\n")
	table.insert(concatToolTip, data.name)
	table.insert(concatToolTip, "\n\n\n\n|u40:0:: |u|t600%:600%:")
	table.insert(concatToolTip, data.texture)
	table.insert(concatToolTip, "|t\n\n\n\n")
	table.insert(concatToolTip, "|t1150%:100%:EsoUI/Art/Miscellaneous/horizontalDivider.dds|t\n") -- the % is the percentage of the font height.  Make it too large and it disappers.
	table.insert(concatToolTip, data.description)
	local tooltip = table.concat(concatToolTip, "")
	
	rowControl:SetHandler("OnMouseEnter", function(rowControl) ZO_Tooltips_ShowTextTooltip(rowControl, LEFT, tooltip) end)
	rowControl:SetHandler("OnMouseExit", function(rowControl) ZO_Tooltips_HideTextTooltip() end )
end


--------------------------------------------------
-- Step 7: Process the selection.
-- If the user has selected a pet, summon that pet
--------------------------------------------------
function ScrollListExample.OnRowSelect(previouslySelectedData, selectedData, reselectingDuringRebuild)
    if not selectedData then return end
    UseCollectible(selectedData.index, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
end


-- ************************************************************
-- ***** Process EVENT_ADD_ON_LOADED
-- ************************************************************


--------------------------------------------------
-- Check to see if this addon is the one loaded
--------------------------------------------------
function ScrollListExample.OnAddOnLoaded(event, addonName)
	if addonName == ScrollListExample.name then
		EVENT_MANAGER:UnregisterForEvent(ScrollListExample.name, EVENT_ADD_ON_LOADED)
		ScrollListExample.Main()
	end	
end


EVENT_MANAGER:RegisterForEvent(ScrollListExample.name, EVENT_ADD_ON_LOADED, ScrollListExample.OnAddOnLoaded)



--[[
-- ************************************************************
-- ***** ESO Globals, Functions, and API Calls Used
-- ***** Listing them here makes it easier to check with a glance if an api update will impact this addon.
-- ************************************************************

COLLECTIBLE_CATEGORY_TYPE_VANITY_PET
SLASH_COMMANDS
WINDOW_MANAGER:CreateTopLevelWindow
SetAnchor
SetDimensions
SetHidden
WINDOW_MANAGER:CreateControlFromVirtual
ZO_DefaultBackdrop
SetAnchorFill
GetDimensions
ZO_SelectableLabel
ZO_ThinListHighlight
ZO_ScrollList_AddDataType
ZO_ScrollList_EnableSelection
GetTotalUnlockedCollectiblesByCategoryType
GetTotalCollectiblesByCategoryType
GetCollectibleIdFromType
ZO_CachedStrFormat(SI_UNIT_NAME, p1)
ZO_DeepTableCopy
ZO_ScrollList_GetDataList
ZO_ScrollList_Clear
ZO_ScrollList_CreateDataEntry
ZO_ScrollList_Commit
SetFont
SetMaxLineCount
SetText
SetHandler
OnMouseUp
ZO_ScrollList_MouseClick
ZO_Tooltips_ShowTextTooltip
ZO_Tooltips_HideTextTooltip
UseCollectible
EVENT_MANAGER:UnregisterForEvent
EVENT_MANAGER:RegisterForEvent
]]