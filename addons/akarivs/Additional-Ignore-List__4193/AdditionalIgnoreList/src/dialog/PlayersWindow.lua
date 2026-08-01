--------------------------------------------------
-- Initialize addon variables
--------------------------------------------------
AIList_PlayersList = {}
AIList_PlayersList.name = "AIList_PlayersList"

-- ************************************************************
-- ***** Main Function
-- ************************************************************

--------------------------------------------------
-- Main Program Function: Initialize settings, load saved variables and register event triggers.
--------------------------------------------------
function AIList_PlayersList:init(blockedPlayers, notedPlayers)
	AIList_PlayersList.CreateMainWindowControl() 	-- Step 1
	AIList_PlayersList.CreateScrollListControl() 	-- Step 2
	AIList_PlayersList.CreateScrollListDataType() 	-- Step 3
	self:updateData()
	self:ShowBlocked()
end

function AIList_PlayersList:updateData()
	local blockedPlayers = {} 
	local notedPlayers = {} 
		 
	for playerID, playerData in pairs(AIList.settings.AffectedPlayers) do
		if playerData.blocked then
			table.insert(blockedPlayers, {id = playerID, note=playerData.note})  
		else
			if playerData.note and playerData.note:match("%S") then
				table.insert(notedPlayers, {id = playerID, note=playerData.note})  
			end
		end
	end

	local blocked = AIList_PlayersList.Populate(blockedPlayers)		-- Step 4
	local typeId = 1 -- We defined this when we created the data type.  Don't really need to decare it here, but did so for this example.
	AIList_PlayersList.UpdateScrollList(AIList_PlayersList.controlScrollList, blocked, typeId) -- Step 5

	local noted = AIList_PlayersList.Populate(notedPlayers)		-- Step 4
	local typeId = 1 -- We defined this when we created the data type.  Don't really need to decare it here, but did so for this example.
	AIList_PlayersList.UpdateScrollList(AIList_PlayersList.controlScrollListNoted, noted, typeId) -- Step 5


	AIList_PlayersList.blocked:SetText("BLOCKED PLAYERS ("..#blockedPlayers..")")
	AIList_PlayersList.noted:SetText("NOTED PLAYES ("..#notedPlayers..")")


end

function AIList_PlayersList:ShowBlocked()
	AIList_PlayersList.controlScrollList:SetHidden(false)
	AIList_PlayersList.controlScrollListNoted:SetHidden(true)

	AIList_PlayersList.heading:SetText("List of blocked players")
	AIList_PlayersList.blocked:SetEnabled(false)
	AIList_PlayersList.noted:SetEnabled(true)
end

function AIList_PlayersList:ShowNoted()
	AIList_PlayersList.controlScrollList:SetHidden(true)
	AIList_PlayersList.controlScrollListNoted:SetHidden(false)
	AIList_PlayersList.heading:SetText("List of player notes")
	AIList_PlayersList.blocked:SetEnabled(true)
	AIList_PlayersList.noted:SetEnabled(false)
end


function AIList_PlayersList:toggle()
 local visible = not AIList_PlayersList.controlMainWindow:IsHidden()
 if visible then
	AIList_PlayersList.controlMainWindow:SetHidden(true)
	SetGameCameraUIMode(false)
 else
	AIList_PlayersList.controlMainWindow:SetHidden(false)
	--ZO_SceneManager_ToggleUIModeBinding()
	SetGameCameraUIMode(true)
 end

end

-- ************************************************************
-- ***** Scroll List Functions
-- ************************************************************--------------------------------------------------
-- Step 1: Make a window with background to display our scroll list.  This could also be done with xml.
--------------------------------------------------
function AIList_PlayersList.CreateMainWindowControl()
	AIList_PlayersList.controlMainWindow = AIList_PlayersListMainWindow --WINDOW_MANAGER:CreateTopLevelWindow("AIList_PlayersListWindow")
	AIList_PlayersList.controlMainWindow:SetHidden(true)
	
	AIList_PlayersList.controlMainWindowBackground = WINDOW_MANAGER:CreateControlFromVirtual("AIList_PlayersListWindowBg", AIList_PlayersList.controlMainWindow, "ZO_DefaultBackdrop")
	AIList_PlayersList.controlMainWindowBackground:SetAnchorFill(AIList_PlayersList.controlMainWindow)
end

--------------------------------------------------
-- Step 2: Make a control in our main window to display our scroll list.  This could also be done with xml.
--------------------------------------------------
function AIList_PlayersList.CreateScrollListControl()
	AIList_PlayersList.controlScrollList =   GetControl(AIList_PlayersList.controlMainWindow, "List")	 	
	AIList_PlayersList.controlScrollListNoted =   GetControl(AIList_PlayersList.controlMainWindow, "ListNoted")	 	

	AIList_PlayersList.heading = GetControl(AIList_PlayersList.controlMainWindow, "Heading")	 	
	AIList_PlayersList.buttons = GetControl(AIList_PlayersList.controlMainWindow, "Buttons")	 	
	AIList_PlayersList.blocked = GetControl(AIList_PlayersList.buttons, "BlockedSelect")	 	
	AIList_PlayersList.noted = GetControl(AIList_PlayersList.buttons, "NotedSelect")	 	
end


--------------------------------------------------
-- Step 3: Make the scroll list data type
--------------------------------------------------
function AIList_PlayersList.CreateScrollListDataType()
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
	local control = AIList_PlayersList.controlScrollList
	local typeId = 1
	local templateName = "ZO_SelectableLabel"
	local height = 25 -- height of the row, not the window
	local setupFunction = AIList_PlayersList.LayoutRow
	local hideCallback = nil
	local dataTypeSelectSound = nil
	local resetControlCallback = nil
	local selectTemplate = "ZO_ThinListHighlight"
	local selectCallback = AIList_PlayersList.OnRowSelect
	
	ZO_ScrollList_AddDataType(control, typeId, templateName, height, setupFunction, hideCallback, dataTypeSelectSound, resetControlCallback)
	ZO_ScrollList_EnableSelection(control, selectTemplate, selectCallback)
	ZO_ScrollList_EnableHighlight(control, "ZO_ThinListHighlight")

	local control = AIList_PlayersList.controlScrollListNoted
	local typeId = 1
	local templateName = "ZO_SelectableLabel"
	local height = 25 -- height of the row, not the window
	local setupFunction = AIList_PlayersList.LayoutRow
	local hideCallback = nil
	local dataTypeSelectSound = nil
	local resetControlCallback = nil
	local selectTemplate = "ZO_ThinListHighlight"
	local selectCallback = AIList_PlayersList.OnRowSelect
	
	ZO_ScrollList_AddDataType(control, typeId, templateName, height, setupFunction, hideCallback, dataTypeSelectSound, resetControlCallback)
	ZO_ScrollList_EnableSelection(control, selectTemplate, selectCallback)
	ZO_ScrollList_EnableHighlight(control, "ZO_ThinListHighlight")
end

--------------------------------------------------
-- Step 4: Populate the unlocked pets list to make our scroll list
--------------------------------------------------
function AIList_PlayersList.Populate(blockedPlayers)
	local pets = {}
	local petcounter = 0
	local unlockedpets = GetTotalUnlockedCollectiblesByCategoryType(AIList_PlayersList.typePets)

	for i, entry in ipairs(blockedPlayers) do
		petcounter = petcounter + 1
		pets[petcounter] = {
			index = index,
			name = entry.id,
			description = entry.note,
			texture = ""
		}
	end
	return pets	
end


--------------------------------------------------
-- Step 5: Update any changes to a scroll list data table then commit those changes to the screen
-- Repeat this step as needed if you have a data table that will have changing data (like an inventory).
--------------------------------------------------
function AIList_PlayersList.UpdateScrollList(control, data, rowType)
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
function AIList_PlayersList.LayoutRow(rowControl, data, scrollList)
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


	--Create columns
	if not rowControl.idLabel then
        -- ID column
        local idLabel = WINDOW_MANAGER:CreateControl(rowControl:GetName() .. "IDLabel", rowControl, CT_LABEL)
        idLabel:SetFont("ZoFontWinH4")
        idLabel:SetAnchor(LEFT, rowControl, LEFT, 0, 0)
        idLabel:SetWidth(200)      		
		idLabel:SetHeight(30)
		idLabel:SetMaxLineCount(1)                  -- fixed width for column 1
        idLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        rowControl.idLabel = idLabel

        -- Note column
        local noteLabel = WINDOW_MANAGER:CreateControl(rowControl:GetName() .. "NoteLabel", rowControl, CT_LABEL)
        noteLabel:SetFont("ZoFontWinH4")
        noteLabel:SetAnchor(LEFT, idLabel, RIGHT, 0, 0)        		
		noteLabel:SetDimensions(rowControl:GetWidth()-200, 30)
		noteLabel:SetMaxLineCount(1)                  -- fixed width for column 1
        noteLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        noteLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)  -- or WORD_WRAP if you want multi‑line
        rowControl.noteLabel = noteLabel

        -- make sure our row is tall enough for two lines of text, if needed
        rowControl:SetHeight(30)
    end

    -- now just set the texts
    rowControl.idLabel:SetText(tostring(data.name))
    rowControl.noteLabel:SetText(data.description or "")

	rowControl.noteLabel:SetDimensions(rowControl:GetWidth()-200, 30)


	rowControl:SetFont("ZoFontWinH4")
	rowControl:SetMaxLineCount(1) -- Forces the text to only use one row.  If it goes longer, the extra will not display.
	--rowControl:SetText(data.name .. "\n" .. data.description)
	
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
	table.insert(concatToolTip, data.name)	
	table.insert(concatToolTip, "\n")
	table.insert(concatToolTip, data.description)
	local tooltip = table.concat(concatToolTip, "")
	
	rowControl:SetHandler("OnMouseEnter", function(rowControl) ZO_ScrollList_MouseEnter(scrollList,rowControl) ZO_Tooltips_ShowTextTooltip(rowControl, LEFT, tooltip) end)
	rowControl:SetHandler("OnMouseExit", function(rowControl) ZO_ScrollList_MouseExit(scrollList,rowControl) ZO_Tooltips_HideTextTooltip() end )
end


--------------------------------------------------
-- Step 7: Process the selection.
-- If the user has selected a pet, summon that pet
--------------------------------------------------
function AIList_PlayersList.OnRowSelect(previouslySelectedData, selectedData, reselectingDuringRebuild)
	if (selectedData) then
		ClearMenu()
		AIList.AddCustomMenuItem(selectedData.name, nil, true)	
		ShowMenu()
	end
end


-- ************************************************************
-- ***** Process EVENT_ADD_ON_LOADED
-- ************************************************************


--------------------------------------------------
-- Check to see if this addon is the one loaded
--------------------------------------------------




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