-- ************************************************************
-- ***** SimpleTooltip 
-- ************************************************************
--[[
	This example is based off my rewrite of ScrollListExample.  Because of that, there are two
	examples that I label.  For quick reference, I list both example steps here.
	I know the tooltip looks ugly, but the different colors clearly indicate each part
	
	Tooltip
		Step A - Create the controls to hold the tooltip
		Step B - Create the object pools to simplify creating texture and label elements
		Step C - Build the tooltip
		Step D - Display the tooltip
		Step E - Hide the tooltip
	
	
	Scroll List
		Step 1 - Create the window with background to hold the scroll list
		Step 2 - Make a control in our main window to hold our scroll list
		Step 3 - Make the scroll list data type
		Step 4 - Populate the scroll list with a list of unlocked pets
		Step 5 - Update any changes to the scroll list data table, sort the table, and commit the changes.  Repeat as needed whenever the data changes.
		Step 6 - Layout the scroll list data in any way we wish
		Step 7 - When the user selects a pet, process the selection.


	The built-in tooltip control type, controls, and functions so it does a lot of pre-formatting for you.  At times, this may lead to unexpedted
	results.  If you do not have need of other tooltip controls, it may be easier to just place your information into a regular control type.
	Then you can directly manipulate positioning and layout of your information.  If you want to add specific information that has a tooltip
	control associated with it, you can use other API functions to get the data, and manually layout how it appears within your regular control.


]]

--------------------------------------------------
-- Initialize addon variables
--------------------------------------------------
local SimpleTooltip = {}
SimpleTooltip.name = "SimpleTooltip"
SimpleTooltip.slashCommand = "/stt"


--------------------------------------------------
-- Link local variables to the in-game Globals
--------------------------------------------------
SimpleTooltip.typePets = COLLECTIBLE_CATEGORY_TYPE_VANITY_PET -- ZOS GLOBAL


--------------------------------------------------
-- Default saved variable settings
-- We are not using any saved variables with is addon.
-- This is just a hold-over from my addon template provided for reference
--------------------------------------------------
SimpleTooltip.accountDefaults = {
}

SimpleTooltip.characterDefaults = {
}


-- ************************************************************
-- ***** Main Function
-- ************************************************************

--------------------------------------------------
-- Main Program Function: Initialize settings, load saved variables and register event triggers.
--------------------------------------------------
function SimpleTooltip.Main()
	--------------------------------------------------
	-- Use CSV for character specific saved variables
	-- Use ASV for account wide saved variables
	-- Again a hold-over from my template provided as an example
	--------------------------------------------------
	-- SimpleTooltip.CSV = ZO_SavedVars:NewCharacterIdSettings("SimpleTooltipSavedVariables", 1, nil, SimpleTooltip.characterDefaults, GetWorldName())
	-- SimpleTooltip.ASV = ZO_SavedVars:NewAccountWide("SimpleTooltipSavedVariables", 1, nil, SimpleTooltip.accountDefaults, GetWorldName())
	
	SLASH_COMMANDS[SimpleTooltip.slashCommand] = SimpleTooltip.ProcessCommand
	
	SimpleTooltip.CreateTooltipControl()		-- Step A
	SimpleTooltip.CreateTooltipPools()			-- Step B
	SimpleTooltip.CreateMainWindowControl() 	-- Step 1
	SimpleTooltip.CreateScrollListControl() 	-- Step 2
	SimpleTooltip.CreateScrollListDataType() 	-- Step 3
	local pets = SimpleTooltip.Populate()		-- Step 4
	local typeId = 1 -- We defined this when we created the data type.  Don't really need to decare it here, but did so for this example.
	SimpleTooltip.UpdateScrollList(SimpleTooltip.controlScrollList, pets, typeId) -- Step 5
end


--------------------------------------------------
-- Process commands sent by using the slash command feature
--------------------------------------------------
function SimpleTooltip.ProcessCommand(cmd)
	if cmd == "hide" then
		SimpleTooltip.controlMainWindow:SetHidden(true)
	elseif cmd == "show" then
		SimpleTooltip.controlMainWindow:SetHidden(false)
	end
end


-- ************************************************************
-- ***** Tooltip Functions
-- ************************************************************


--------------------------------------------------
-- Step A: Create the controls to hold our tooltip
--------------------------------------------------
function SimpleTooltip.CreateTooltipControl()
	-- If you want a simple text tooltip, use the information at https://wiki.esoui.com/How_to_create_a_simple_text_tooltip_at_a_control
	-- This is to show how to manually make a tooltip so we can use custom fonts, textures, borders, and alignments within the tooltip.
	-- Because we are manually making everything, we have to manage everything on our own.
	-- https://github.com/esoui/esoui/blob/ea3a42c9344a610a1a49293f417b7c24db0da546/esoui/publicallingames/tooltip/tooltip.xml#L12
	SimpleTooltip.controlTooltipTop = WINDOW_MANAGER:CreateTopLevelWindow("PetInfoTooltipTopLevel")
	SimpleTooltip.controlTooltipTop:SetDrawTier(DT_HIGH)
	SimpleTooltip.controlTooltipTop:SetTopmost(true)
	
	SimpleTooltip.controlPetTooltip = WINDOW_MANAGER:CreateControl("PetInfoTooltip", SimpleTooltip.controlTooltipTop, CT_TOOLTIP)
	SimpleTooltip.controlPetTooltip:SetHidden(true)
	
	SimpleTooltip.controlPetTooltipBackground = WINDOW_MANAGER:CreateControl("PetInfoTooltipBG", SimpleTooltip.controlPetTooltip, CT_BACKDROP)
	SimpleTooltip.controlPetTooltipBackground:SetAnchorFill(SimpleTooltip.controlPetTooltip)
end


--------------------------------------------------
-- Step B: Create the object pools to dynamically generate the desired textures and labels
--------------------------------------------------
function SimpleTooltip.CreateTooltipPools()
	-- We are going to use an objectPool so we can quickly and safely create extra controls to hold extra
	-- instances of textures or lables.  In most cases this will be overkill, but it also gives a lot of extra
	-- flexibility.
	-- https://github.com/esoui/esoui/blob/ea3a42c9344a610a1a49293f417b7c24db0da546/esoui/libraries/utility/zo_objectpool.lua
	
	SimpleTooltip.poolTexture = ZO_ObjectPool:New(function(objectPool)
		return ZO_ObjectPool_CreateNamedControl("PetInfoTexture", "ZO_TooltipTexture", objectPool, SimpleTooltip.controlTooltipTop)
	end)
	
	SimpleTooltip.poolLabel = ZO_ObjectPool:New(function(objectPool)
		return ZO_ObjectPool_CreateNamedControl("PetInfoLabel", "ZO_TooltipLabel", objectPool, SimpleTooltip.controlTooltipTop)
	end)
end


--------------------------------------------------
-- Step C: Build the tooltip
--------------------------------------------------
function SimpleTooltip.BuildPetTooltip(data, rowControl)
	-- There are a lot of cool things you can link into your custom tooltip https://wiki.esoui.com/Controls#TooltipControl
	
	-- Make some adjustment to the background by adding an edge, changing the edge color, and setting the color of the background
	SimpleTooltip.controlPetTooltipBackground:SetEdgeTexture("/esoui/art/skillsadvisor/gamepad/edgedoubleframegamepadborder.dds", 16, 16)
	SimpleTooltip.controlPetTooltipBackground:SetEdgeColor(.25, .13, .67, 1)
	SimpleTooltip.controlPetTooltipBackground:SetCenterColor(.5, .5, .5, .75)
	
	-- Reset and position our home-made tooltip
	SimpleTooltip.controlPetTooltip:ClearLines()
	-- Needed the scroll list row control so we can position the tooltip in relation to the scroll list row
	SimpleTooltip.controlPetTooltip:SetAnchor(RIGHT, rowControl, BOTTOMLEFT, -10, -15)
	SimpleTooltip.controlPetTooltip:SetWidth(400)
	
	-- Add some space so the ears of the pets will not be sticking up into the edge of the tooltip
	SimpleTooltip.controlPetTooltip:AddVerticalPadding(15)
	
	-- Add in the image of the pet (takes from the data in the scroll list control)
	local petPreview = SimpleTooltip.poolTexture:AcquireObject()
	SimpleTooltip.controlPetTooltip:AddControl(petPreview)
	-- When we call ReleaseAllObjects to close the tooltip, it sets hidden to true
	petPreview:SetHidden(false)
	petPreview:SetTexture(data.texture)
	petPreview:SetAnchor(CENTER, nil, CENTER)
	petPreview:SetDimensions(100, 100)
	
	-- Add in a divider line
	local divider = SimpleTooltip.poolTexture:AcquireObject()
	SimpleTooltip.controlPetTooltip:AddControl(divider)
	divider:SetHidden(false)
	divider:SetAnchor(CENTER)
	divider:SetTexture("EsoUI/Art/Miscellaneous/horizontalDivider.dds")
	divider:SetColor(1, .25, .6, .5)
	divider:SetDimensions(400, 10)
	divider:SetAnchor(CENTER, nil, CENTER, 0, 0)
	
	-- Bump the rest of the tooltip up a bit because the divider adds too much space on the bottom
	-- or may be the label adds too much to the top
	SimpleTooltip.controlPetTooltip:AddVerticalPadding(-15)
	
	-- Add in the pet's name
	local name = SimpleTooltip.poolLabel:AcquireObject()
	SimpleTooltip.controlPetTooltip:AddControl(name)
	name:SetHidden(false)
	name:SetText(data.name)
	name:SetFont("$(HANDWRITTEN_FONT)||$(KB_24)||FONT_STYLE_NORMAL")
	name:SetColor(0, 1, .5, 1)
	name:SetAnchor(CENTER, nil, CENTER)
	
	-- Bump the spacing back up again
	SimpleTooltip.controlPetTooltip:AddVerticalPadding(-10)
	
	-- Add in another divider line (You can not recycle the one above.  Neither will show if you try)
	local divider2 = SimpleTooltip.poolTexture:AcquireObject()
	SimpleTooltip.controlPetTooltip:AddControl(divider2)
	divider2:SetHidden(false)
	divider2:SetAnchor(CENTER)
	divider2:SetTexture("EsoUI/Art/Miscellaneous/horizontalDivider.dds") --EsoUI/Art/Miscellaneous/horizontalDivider.dds
	divider2:SetDimensions(400, 10)
	divider2:SetAnchor(CENTER, nil, CENTER, 0, 0)
	
	-- Bump the spacing up again
	SimpleTooltip.controlPetTooltip:AddVerticalPadding(-15)
	
	-- Make a sample text string that illustrates coloring and in-line textures
	local concatString = {}
	table.insert(concatString, "|cEE6677Sample String|r to demonstrate using ")
	table.insert(concatString, "|c882255Colors|r and in-line textures.  Cost: ")
	table.insert(concatString, "|cFFD700 475|r")
	table.insert(concatString, "|t150%:150%:/esoui/art/icons/housing_gen_inc_coinstack004.dds|t\n") -- the % is the percentage of the font height.  Make it too large and it disappers.
	local str = table.concat(concatString, "")
	
	-- Get the tooltip width because the string could bump the tooltip width to the
	-- size of the string.  So we will manually make sure it will not resize the tooltip
	local width = SimpleTooltip.controlPetTooltip:GetWidth()
	
	-- Add the string to the tooltip
	local sample = SimpleTooltip.poolLabel:AcquireObject()
	SimpleTooltip.controlPetTooltip:AddControl(sample)
	sample:SetHidden(false)
	sample:SetAnchor(CENTER, nil, CENTER)
	sample:SetFont("$(MEDIUM_FONT)||$(KB_20)||FONT_STYLE_NORMAL")
	sample:SetText(str)
	sample:SetWidth(width - 50)
	sample:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	
	-- Just adding padding with SimpleTooltip.controlPetTooltip:AddVerticalPadding(50) will not give us the space we want
	-- on the bottom for some reason.  So we will just add a nil label
	
	-- Add a buffer at the bottom
	local spacer = SimpleTooltip.poolLabel:AcquireObject()
	SimpleTooltip.controlPetTooltip:AddControl(spacer)
	

end


--------------------------------------------------
-- Step D: Display the tooltip
--------------------------------------------------
function SimpleTooltip.ShowTooltip()
	SimpleTooltip.controlPetTooltip:SetHidden(false)
end


--------------------------------------------------
-- Step E: Hide the tooltip
--------------------------------------------------
function SimpleTooltip.HideTooltip()
	SimpleTooltip.poolLabel:ReleaseAllObjects()
	SimpleTooltip.poolTexture:ReleaseAllObjects()
	SimpleTooltip.controlPetTooltip:SetHidden(true)
	SimpleTooltip.controlPetTooltip:ClearLines()	
	-- d("Label Pool Count: "..SimpleTooltip.poolLabel:GetTotalObjectCount())
	-- d("Texture Pool Count:"..SimpleTooltip.poolTexture:GetTotalObjectCount())
end


-- ************************************************************
-- ***** Scroll List Functions
-- ************************************************************


--------------------------------------------------
-- Step 1: Make a window with background to display our scroll list.  This could also be done with xml.
--------------------------------------------------
function SimpleTooltip.CreateMainWindowControl()
	-- Create a top level window.  User can adjust size, placement, and other settings later using the control we store.
	-- See: https://wiki.esoui.com/Controls and https://wiki.esoui.com/UI_XML
	-- See: https://wiki.esoui.com/Controls#WindowManager for more info
	SimpleTooltip.controlMainWindow = WINDOW_MANAGER:CreateTopLevelWindow("SimpleTooltipWindow")
	SimpleTooltip.controlMainWindow:SetAnchor(RIGHT, GuiRoot, RIGHT) 
	SimpleTooltip.controlMainWindow:SetDimensions(550, 400) 
	SimpleTooltip.controlMainWindow:SetHidden(false)
	
	-- Create a background (optional)  -  See https://wiki.esoui.com/Controls#BackdropControl for more info
	SimpleTooltip.controlMainWindowBackground = WINDOW_MANAGER:CreateControlFromVirtual("SimpleTooltipWindowBg", SimpleTooltip.controlMainWindow, "ZO_DefaultBackdrop")
	SimpleTooltip.controlMainWindowBackground:SetAnchorFill(SimpleTooltip.controlMainWindow)
	-- I have found that creating the background from virtual, that I could adjust the alpha, but not the color.
	-- If you would like to be able to change the background color you could also use:
	-- SimpleTooltip.controlMainWindowBackground = WINDOW_MANAGER:CreateControl("SimpleTooltipWindowBg", SimpleTooltip.controlMainWindow, CT_BACKDROP)
end


--------------------------------------------------
-- Step 2: Make a control in our main window to display our scroll list.  This could also be done with xml.
--------------------------------------------------
function SimpleTooltip.CreateScrollListControl()
	SimpleTooltip.controlScrollList = WINDOW_MANAGER:CreateControlFromVirtual("SimpleTooltipList", SimpleTooltip.controlMainWindow, "ZO_ScrollList")
	local width, height = SimpleTooltip.controlMainWindow:GetDimensions()
	SimpleTooltip.controlScrollList:SetDimensions(width, height)
	SimpleTooltip.controlScrollList:SetAnchor(LEFT, SimpleTooltip.controlMainWindow, LEFT)
end


--------------------------------------------------
-- Step 3: Make the scroll list data type
--------------------------------------------------
function SimpleTooltip.CreateScrollListDataType()
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
	local control = SimpleTooltip.controlScrollList
	local typeId = 1
	local templateName = "ZO_SelectableLabel"
	local height = 25 -- height of the row, not the window
	local setupFunction = SimpleTooltip.LayoutRow
	local hideCallback = nil
	local dataTypeSelectSound = nil
	local resetControlCallback = nil
	local selectTemplate = "ZO_ThinListHighlight"
	local selectCallback = SimpleTooltip.OnRowSelect
	
	ZO_ScrollList_AddDataType(control, typeId, templateName, height, setupFunction, hideCallback, dataTypeSelectSound, resetControlCallback)
	ZO_ScrollList_EnableSelection(control, selectTemplate, selectCallback)
end


--------------------------------------------------
-- Step 4: Populate the unlocked pets list to make our scroll list
--------------------------------------------------
function SimpleTooltip.Populate()
	local pets = {}
	local petcounter = 0
	local unlockedpets = GetTotalUnlockedCollectiblesByCategoryType(SimpleTooltip.typePets)
	
	if unlockedpets > 0 then
		for count = 1, GetTotalCollectiblesByCategoryType(SimpleTooltip.typePets) do
			local index = GetCollectibleIdFromType(SimpleTooltip.typePets, count)
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
function SimpleTooltip.UpdateScrollList(control, data, rowType)
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
function SimpleTooltip.LayoutRow(rowControl, data, scrollList)
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
	-- when an row is slected.  We still need to set up a handler to actually register the mouse click which
	-- then triggers the row as "selected".  See https://wiki.esoui.com/UI_XML#OnAddGameData and following
	-- entries for "On" events that can be set as handlers.
	rowControl:SetHandler("OnMouseUp", function() ZO_ScrollList_MouseClick(scrollList, rowControl) end)
	
	rowControl:SetHandler("OnMouseEnter", function(rowControl) SimpleTooltip.BuildPetTooltip(data, rowControl) SimpleTooltip.ShowTooltip() end)
	rowControl:SetHandler("OnMouseExit", function(rowControl)  SimpleTooltip.HideTooltip() end)
end


--------------------------------------------------
-- Step 7: Process the selection.
-- If the user has selected a pet, summon that pet
--------------------------------------------------
function SimpleTooltip.OnRowSelect(previouslySelectedData, selectedData, reselectingDuringRebuild)
    if not selectedData then return end
    UseCollectible(selectedData.index)
end


-- ************************************************************
-- ***** Process EVENT_ADD_ON_LOADED
-- ************************************************************


--------------------------------------------------
-- Check to see if this addon is the one loaded
--------------------------------------------------
function SimpleTooltip.OnAddOnLoaded(event, addonName)
	if addonName == SimpleTooltip.name then
		EVENT_MANAGER:UnregisterForEvent(SimpleTooltip.name, EVENT_ADD_ON_LOADED)
		SimpleTooltip.Main()
	end	
end


EVENT_MANAGER:RegisterForEvent(SimpleTooltip.name, EVENT_ADD_ON_LOADED, SimpleTooltip.OnAddOnLoaded)
