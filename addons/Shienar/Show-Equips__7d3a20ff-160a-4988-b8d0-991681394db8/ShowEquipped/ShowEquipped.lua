SE = { name = "ShowEquipped" }

SE.trackedSets = {}

--returns -1 or index k
local function containsVal_SetItem(list, val)
	for k, v in pairs(list) do
		if v.name == val.name then return k end
	end
	return -1
end

local function comparator_Sets(arg1, arg2)
	if arg1.count > arg2.count then 
		return true 
	elseif arg1.count == arg2.count and arg1.maxCount > arg2.maxCount then
		return true
	else
		return false
	end
end

function SE.onUpdateEquips(code, bagID, slotIndex, isNewItem, soundCategory, updateReason, stackChange)
	if bagID == BAG_WORN then

		local equips = {
			EQUIP_SLOT_HEAD,
			EQUIP_SLOT_CHEST,
			EQUIP_SLOT_SHOULDERS,
			EQUIP_SLOT_HAND,
			EQUIP_SLOT_WAIST,
			EQUIP_SLOT_LEGS,
			EQUIP_SLOT_FEET,
			EQUIP_SLOT_MAIN_HAND,
			EQUIP_SLOT_OFF_HAND,
			EQUIP_SLOT_BACKUP_MAIN,
			EQUIP_SLOT_BACKUP_OFF,
			EQUIP_SLOT_NECK,
			EQUIP_SLOT_RING1,
			EQUIP_SLOT_RING2,
		}
		
		SE.trackedSets = {}
		
		for k, equip in pairs(equips) do
			
			local itemLink = GetItemLink(BAG_WORN, equip)
			--Doesn't track equipped on other bar, which I'd like to do.
			local hasSet, setName, numBonuses, numNormal, maxEquipped, setID, numPerfected = GetItemLinkSetInfo(itemLink)
			
			if setName ~= "" then
				
				local item = {
					name = zo_strformat(SI_ITEM_SET_NAME_FORMATTER, setName),
					count = 1,
					maxCount = maxEquipped,
				}
				
				local wType = GetItemLinkWeaponType(itemLink)
				if wType ~= nil and 
					(wType == WEAPONTYPE_FROST_STAFF or
					wType == WEAPONTYPE_HEALING_STAFF or
					wType == WEAPONTYPE_LIGHTNING_STAFF or
					wType == WEAPONTYPE_FIRE_STAFF or
					wType == WEAPONTYPE_TWO_HANDED_AXE or
					wType == WEAPONTYPE_TWO_HANDED_HAMMER or
					wType == WEAPONTYPE_TWO_HANDED_SWORD or
					wType == WEAPONTYPE_BOW)then
					
						item.count = item.count + 1
				end
					
				local index = containsVal_SetItem(SE.trackedSets, item)
				if index == -1 then 
					SE.trackedSets[#SE.trackedSets+1] = item 
				else
					SE.trackedSets[index].count = SE.trackedSets[index].count + item.count
				end
				
			end
		end
		
		--Descending order
		table.sort(SE.trackedSets, comparator_Sets)
		
		--clear text
		for k, v in pairs(SE.rows) do
			v:SetText("")
		end
		
		
		for k, v in pairs(SE.trackedSets) do
			--refill text
			SE.rows[k]:SetText("("..v.count.."/"..v.maxCount..") "..v.name)
			
			--update color
			if v.count ~= nil and v.maxCount ~= nil and v.count ~= v.maxCount and ((v.count > v.maxCount and SE.savedVariables.allowOverflow) == false) then
				SE.rows[k]:SetColor(SE.savedVariables.colorR_Incomplete, SE.savedVariables.colorG_Incomplete, SE.savedVariables.colorB_Incomplete)
				SE.rows[k]:SetAlpha(SE.savedVariables.colorA_Incomplete)
			else
				SE.rows[k]:SetColor(SE.savedVariables.colorR_Complete, SE.savedVariables.colorG_Complete, SE.savedVariables.colorB_Complete)
				SE.rows[k]:SetAlpha(SE.savedVariables.colorA_Complete)
			end
		end
		
	end
end

function SE.applyValues()
	--toggle
	ShowEquippedName:SetHidden(SE.savedVariables.hideTitle)
	ShowEquipped:SetHidden(SE.savedVariables.isHidden)
	
	--Color
	ShowEquippedName:SetColor(SE.savedVariables.colorR_Title, SE.savedVariables.colorG_Title, SE.savedVariables.colorB_Title)
	ShowEquippedName:SetAlpha(SE.savedVariables.colorA_Title)
	for k, v in pairs(SE.trackedSets) do
		if v.count ~= nil and v.maxCount ~= nil and v.count ~= v.maxCount and ((v.count > v.maxCount and SE.savedVariables.allowOverflow) == false) then
			SE.rows[k]:SetColor(SE.savedVariables.colorR_Incomplete, SE.savedVariables.colorG_Incomplete, SE.savedVariables.colorB_Incomplete)
			SE.rows[k]:SetAlpha(SE.savedVariables.colorA_Incomplete)
		else
			SE.rows[k]:SetColor(SE.savedVariables.colorR_Complete, SE.savedVariables.colorG_Complete, SE.savedVariables.colorB_Complete)
			SE.rows[k]:SetAlpha(SE.savedVariables.colorA_Complete)
		end
	end
	
	--Text Size
	ShowEquippedName:SetFont(string.format("$(%s)|%s|%s", SE.savedVariables.titleFontStyle, SE.savedVariables.selectedText_font_Title, SE.savedVariables.titleFontWeight))
	ShowEquippedName:SetHeight(ShowEquippedName:GetTextHeight())
	for k, v in pairs(SE.rows) do
		v:SetFont(string.format("$(%s)|%s|%s", SE.savedVariables.fontStyle, SE.savedVariables.selectedText_font, SE.savedVariables.fontWeight))
		v:SetHeight(v:GetTextHeight())
	end
	
	--Position
	ShowEquipped:ClearAnchors()
	ShowEquipped:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SE.savedVariables.offset_x, SE.savedVariables.offset_y)
end

local function fragmentChange(oldState, newState)
	if newState == SCENE_FRAGMENT_SHOWN then
		ShowEquipped:SetHidden(SE.savedVariables.isHidden)
	elseif newState == SCENE_FRAGMENT_HIDDEN then
		ShowEquipped:SetHidden(true)
	end
end

local function temporarilyShowText()
    --Hide UI 5 seconds after most recent change.
    ShowEquipped:SetHidden(false)
    EVENT_MANAGER:RegisterForUpdate(SE.name.."_edit", 5000, function()
        if SCENE_MANAGER:GetScene("hud"):GetState() == SCENE_HIDDEN or SE.savedVariables.isHidden then
            ShowEquipped:SetHidden(true)
        end
        EVENT_MANAGER:UnregisterForUpdate(SE.name.."_edit")
    end)
end

function SE.Initialize()

	SE.defaults = {
		isHidden = false,
		hideTitle = false,
		allowOverflow = true,
		
		colorR_Title = 1.0,
		colorG_Title = 1.0,
		colorB_Title = 1.0,
		colorA_Title = 1.0,
		
		colorR_Complete = 1.0,
		colorG_Complete = 1.0,
		colorB_Complete = 1.0,
		colorA_Complete = 1.0,
		
		colorR_Incomplete = 1.0,
		colorG_Incomplete = 1.0,
		colorB_Incomplete = 1.0,
		colorA_Incomplete = 1.0,
			
		selectedText_font_Title = "22", --fontsize. Legacy setting name kept to not mess up with user's UI on update.
		titleFontStyle = "GAMEPAD_MEDIUM_FONT",
		titleFontWeight = "soft-shadow-thick",

		selectedText_font = "22", --fontsize. Legacy setting name kept to not mess up with user's UI on update.
		fontStyle = "GAMEPAD_MEDIUM_FONT",
		fontWeight = "soft-shadow-thick",
			
		offset_x = 0,
		offset_y = 0,
	}

	SE.savedVariables = ZO_SavedVars:NewAccountWide("SESavedVariables", 1, nil, SE.defaults, GetWorldName())
	
	--UI
	SE.rows = {}
	for i = 1, 14 do
		SE.rows[i] = ShowEquipped:GetNamedChild("Row"..i)
	end
	SE.applyValues()
	HUD_FRAGMENT:RegisterCallback("StateChange", fragmentChange)
	
	if LibHarvensAddonSettings then
		--settings
		local settings = LibHarvensAddonSettings:AddAddon("Show Equipped")
		
		settings:AddSetting( {type = LibHarvensAddonSettings.ST_SECTION,label = "General",})
		
		settings:AddSetting({
			type = LibHarvensAddonSettings.ST_BUTTON,
			label = "Reset Defaults",
			tooltip = "",
			buttonText = "RESET",
			clickHandler = function(control, button)
				--Reset values
				SE.savedVariables.colorR_Title = SE.defaults.colorR_Title
				SE.savedVariables.colorG_Title = SE.defaults.colorG_Title
				SE.savedVariables.colorB_Title = SE.defaults.colorB_Title
				SE.savedVariables.colorA_Title = SE.defaults.colorA_Title
				
				SE.savedVariables.colorR_Complete = SE.defaults.colorR_Complete
				SE.savedVariables.colorG_Complete = SE.defaults.colorG_Complete
				SE.savedVariables.colorB_Complete = SE.defaults.colorB_Complete
				SE.savedVariables.colorA_Complete = SE.defaults.colorA_Complete
				
				SE.savedVariables.colorR_Incomplete = SE.defaults.colorR_Incomplete
				SE.savedVariables.colorG_Incomplete = SE.defaults.colorG_Incomplete
				SE.savedVariables.colorB_Incomplete = SE.defaults.colorB_Incomplete
				SE.savedVariables.colorA_Incomplete = SE.defaults.colorA_Incomplete
					
				SE.savedVariables.selectedText_font_Title = SE.defaults.selectedText_font_Title
				SE.savedVariables.titleFontStyle = SE.defaults.titleFontStyle
				SE.savedVariables.titleFontWeight = SE.defaults.titleFontWeight
				
				SE.savedVariables.selectedText_font = SE.defaults.selectedText_font
				SE.savedVariables.fontStyle = SE.defaults.fontStyle
				SE.savedVariables.fontWeight = SE.defaults.fontWeight
					
				SE.savedVariables.isHidden = SE.defaults.isHidden
				SE.savedVariables.offset_x = SE.defaults.offset_x
				SE.savedVariables.offset_y = SE.defaults.offset_y
				
				SE.applyValues()
				
				temporarilyShowText()
			end,
		})
		
		settings:AddSetting({
			type = LibHarvensAddonSettings.ST_CHECKBOX, --setting type
			label = "Hide Display?", 
			tooltip = "Disables the display when set to \"On\"",
			default = SE.defaults.isHidden,
			setFunction = function(state) 
				SE.savedVariables.isHidden = state
				ShowEquipped:SetHidden(state)
				
				if state == false then
					temporarilyShowText()
				end
			end,
			getFunction = function() 
				return SE.savedVariables.isHidden
			end,
		})
		
		settings:AddSetting({
			type = LibHarvensAddonSettings.ST_CHECKBOX, --setting type
			label = "Hide Title?", 
			tooltip = "Disables the Title Row when set to \"On\"",
			default = SE.defaults.hideTitle,
			setFunction = function(state) 
				SE.savedVariables.hideTitle = state
				ShowEquippedName:SetHidden(state)

				temporarilyShowText()
			end,
			getFunction = function() 
				return SE.savedVariables.hideTitle
			end,
		})
		
		settings:AddSetting({
			type = LibHarvensAddonSettings.ST_CHECKBOX, --setting type
			label = "Allow Extra Pieces", 
			tooltip = "Sets that exceed the requirements for a completed set bonus will be colored as completed if this option as enabled.\n\n"..
						"Example: A 7/5 set would recieve the \"Complete\" color if this option is enabled.",
			default = SE.defaults.allowOverflow,
			setFunction = function(state) 
				SE.savedVariables.allowOverflow = state
				SE.applyValues()
				
				temporarilyShowText()
			end,
			getFunction = function() 
				return SE.savedVariables.allowOverflow
			end,
		})
		
		
		settings:AddSetting( {type = LibHarvensAddonSettings.ST_SECTION,label = "Color",})

		settings:AddSetting({
			type = LibHarvensAddonSettings.ST_COLOR,
			label = "Title Color",
			tooltip = "Change the text color of the display's title.",
			setFunction = function(...) --newR, newG, newB, newA
				SE.savedVariables.colorR_Title, SE.savedVariables.colorG_Title, SE.savedVariables.colorB_Title, SE.savedVariables.colorA_Title = ...
				ShowEquippedName:SetColor(SE.savedVariables.colorR_Title, SE.savedVariables.colorG_Title, SE.savedVariables.colorB_Title)
				ShowEquippedName:SetAlpha(SE.savedVariables.colorA_Title)
				
				temporarilyShowText()
			end,
			default = {SE.defaults.colorR_Title, SE.defaults.colorG_Title, SE.defaults.colorB_Title, SE.defaults.colorA_Title},
			getFunction = function()
				return SE.savedVariables.colorR_Title, SE.savedVariables.colorG_Title, SE.savedVariables.colorB_Title, SE.savedVariables.colorA_Title
			end,
		})
		
		settings:AddSetting({
			type = LibHarvensAddonSettings.ST_COLOR,
			label = "Complete Color",
			tooltip = "Change the text color of completed item sets (e.g. 2/2 or 5/5)",
			setFunction = function(...) --newR, newG, newB, newA
				SE.savedVariables.colorR_Complete, SE.savedVariables.colorG_Complete, SE.savedVariables.colorB_Complete, SE.savedVariables.colorA_Complete = ...
				
				for k, v in pairs(SE.trackedSets) do
					if v.count ~= nil and v.maxCount ~= nil and v.count ~= v.maxCount and ((v.count > v.maxCount and SE.savedVariables.allowOverflow) == false) then
						SE.rows[k]:SetColor(SE.savedVariables.colorR_Incomplete, SE.savedVariables.colorG_Incomplete, SE.savedVariables.colorB_Incomplete)
						SE.rows[k]:SetAlpha(SE.savedVariables.colorA_Incomplete)
					else
						SE.rows[k]:SetColor(SE.savedVariables.colorR_Complete, SE.savedVariables.colorG_Complete, SE.savedVariables.colorB_Complete)
						SE.rows[k]:SetAlpha(SE.savedVariables.colorA_Complete)
					end
				end
				
				temporarilyShowText()
			end,
			default = {SE.defaults.colorR_Complete, SE.defaults.colorG_Complete, SE.defaults.colorB_Complete, SE.defaults.colorA_Complete},
			getFunction = function()
				return SE.savedVariables.colorR_Complete, SE.savedVariables.colorG_Complete, SE.savedVariables.colorB_Complete, SE.savedVariables.colorA_Complete
			end,
		})
		
		settings:AddSetting({
			type = LibHarvensAddonSettings.ST_COLOR,
			label = "Incomplete Color",
			tooltip = "Change the text color of incomplete item sets.",
			setFunction = function(...) --newR, newG, newB, newA
				SE.savedVariables.colorR_Incomplete, SE.savedVariables.colorG_Incomplete, SE.savedVariables.colorB_Incomplete, SE.savedVariables.colorA_Incomplete = ...
				
				for k, v in pairs(SE.trackedSets) do
					if v.count ~= nil and v.maxCount ~= nil and v.count ~= v.maxCount and ((v.count > v.maxCount and SE.savedVariables.allowOverflow) == false) then
						SE.rows[k]:SetColor(SE.savedVariables.colorR_Incomplete, SE.savedVariables.colorG_Incomplete, SE.savedVariables.colorB_Incomplete)
						SE.rows[k]:SetAlpha(SE.savedVariables.colorA_Incomplete)
					else
						SE.rows[k]:SetColor(SE.savedVariables.colorR_Complete, SE.savedVariables.colorG_Complete, SE.savedVariables.colorB_Complete)
						SE.rows[k]:SetAlpha(SE.savedVariables.colorA_Complete)
					end
				end
				
				temporarilyShowText()
			end,
			default = {SE.defaults.colorR_Incomplete, SE.defaults.colorG_Incomplete, SE.defaults.colorB_Incomplete, SE.defaults.colorA_Incomplete},
			getFunction = function()
				return SE.savedVariables.colorR_Incomplete, SE.savedVariables.colorG_Incomplete, SE.savedVariables.colorB_Incomplete, SE.savedVariables.colorA_Incomplete
			end,
		})

		settings:AddSetting( {type = LibHarvensAddonSettings.ST_SECTION,label = "Title Font",})

		settings:AddSetting({
			type = LibHarvensAddonSettings.ST_SLIDER,
			label = "Font Size",
			tooltip = "",
			setFunction = function(value)
				SE.savedVariables.selectedText_font_Title = value
				ShowEquippedName:SetFont(string.format("$(%s)|%s|%s", SE.savedVariables.titleFontStyle, SE.savedVariables.selectedText_font_Title, SE.savedVariables.titleFontWeight))
				ShowEquippedName:SetHeight(ShowEquippedName:GetTextHeight())
				temporarilyShowText()
			end,
			getFunction = function()
				return SE.savedVariables.selectedText_font_Title
			end,
			default = SE.defaults.selectedText_font_Title,
			min = 18,
			max = 61,
			step = 1,
			unit = "", --optional unit
			format = "%d", --value format
		})

		settings:AddSetting({
			type = LibHarvensAddonSettings.ST_DROPDOWN,
			label = "Font Style",
			tooltip = "",
			items = {
				{name = "GAMEPAD_MEDIUM_FONT", data = 1},
				{name = "GAMEPAD_LIGHT_FONT", data = 2},
				{name = "GAMEPAD_BOLD_FONT", data = 3},
				{name = "MEDIUM_FONT", data = 4},
				{name = "BOLD_FONT", data = 5},
			},
			getFunction = function() return SE.savedVariables.titleFontStyle end,
			setFunction = function(control, itemName, itemData) 
				SE.savedVariables.titleFontStyle = itemName
				ShowEquippedName:SetFont(string.format("$(%s)|%s|%s", SE.savedVariables.titleFontStyle, SE.savedVariables.selectedText_font_Title, SE.savedVariables.titleFontWeight))
				ShowEquippedName:SetHeight(ShowEquippedName:GetTextHeight())
				temporarilyShowText()
			end,
			default = SE.defaults.titleFontStyle
		})

		settings:AddSetting({
			type = LibHarvensAddonSettings.ST_DROPDOWN,
			label = "Font Weight",
			tooltip = "",
			items = {
				{name = "soft-shadow-thick", data = 1},
				{name = "soft-shadow-thin", data = 2},
				{name = "thick-outline", data = 3},
			},
			getFunction = function() return SE.savedVariables.titleFontWeight end,
			setFunction = function(control, itemName, itemData) 
				SE.savedVariables.titleFontWeight = itemName
				ShowEquippedName:SetFont(string.format("$(%s)|%s|%s", SE.savedVariables.titleFontStyle, SE.savedVariables.selectedText_font_Title, SE.savedVariables.titleFontWeight))
				ShowEquippedName:SetHeight(ShowEquippedName:GetTextHeight())
				temporarilyShowText()
			end,
			default = SE.defaults.titleFontWeight
		})

		
		settings:AddSetting( {type = LibHarvensAddonSettings.ST_SECTION,label = "General Font",})

		settings:AddSetting({
			type = LibHarvensAddonSettings.ST_SLIDER,
			label = "Font Size",
			tooltip = "",
			setFunction = function(value)
				SE.savedVariables.selectedText_font = value
				for k, v in pairs(SE.rows) do
					v:SetFont(string.format("$(%s)|%s|%s", SE.savedVariables.fontStyle, SE.savedVariables.selectedText_font, SE.savedVariables.fontWeight))
					v:SetHeight(v:GetTextHeight())
				end
				temporarilyShowText()
			end,
			getFunction = function()
				return SE.savedVariables.selectedText_font
			end,
			default = SE.defaults.selectedText_font,
			min = 18,
			max = 61,
			step = 1,
			unit = "", --optional unit
			format = "%d", --value format
		})

		settings:AddSetting({
			type = LibHarvensAddonSettings.ST_DROPDOWN,
			label = "Font Style",
			tooltip = "",
			items = {
				{name = "GAMEPAD_MEDIUM_FONT", data = 1},
				{name = "GAMEPAD_LIGHT_FONT", data = 2},
				{name = "GAMEPAD_BOLD_FONT", data = 3},
				{name = "MEDIUM_FONT", data = 4},
				{name = "BOLD_FONT", data = 5},
			},
			getFunction = function() return SE.savedVariables.fontStyle end,
			setFunction = function(control, itemName, itemData) 
				SE.savedVariables.fontStyle = itemName
				for k, v in pairs(SE.rows) do
					v:SetFont(string.format("$(%s)|%s|%s", SE.savedVariables.fontStyle, SE.savedVariables.selectedText_font, SE.savedVariables.fontWeight))
					v:SetHeight(v:GetTextHeight())
				end
				temporarilyShowText()
			end,
			default = SE.defaults.fontStyle
		})

		settings:AddSetting({
			type = LibHarvensAddonSettings.ST_DROPDOWN,
			label = "Font Weight",
			tooltip = "",
			items = {
				{name = "soft-shadow-thick", data = 1},
				{name = "soft-shadow-thin", data = 2},
				{name = "thick-outline", data = 3},
			},
			getFunction = function() return SE.savedVariables.fontWeight end,
			setFunction = function(control, itemName, itemData) 
				SE.savedVariables.fontWeight = itemName
				for k, v in pairs(SE.rows) do
					v:SetFont(string.format("$(%s)|%s|%s", SE.savedVariables.fontStyle, SE.savedVariables.selectedText_font, SE.savedVariables.fontWeight))
					v:SetHeight(v:GetTextHeight())
				end
				temporarilyShowText()
			end,
			default = SE.defaults.fontWeight
		})
		
		settings:AddSetting( {type = LibHarvensAddonSettings.ST_SECTION,label = "Position",})
		
		SE.currentlyChangingPosition = false
		settings:AddSetting({
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = "Joystick Reposition",
			tooltip = "When enabled, you will be able to freely move around the UI with your right joystick.\n\nSet this to OFF after configuring position.",
			getFunction = function() return SE.currentlyChangingPosition end,
			setFunction = function(value) 
				SE.currentlyChangingPosition = value
				if value == true then
					ShowEquipped:SetHidden(false)
					EVENT_MANAGER:RegisterForUpdate(SE.name.."AdjustUI", 10,  function() 
						local posX, posY = GetGamepadRightStickX(true), GetGamepadRightStickY(true)
						if posX ~= 0 or posY ~= 0 then 
							SE.savedVariables.offset_x = SE.savedVariables.offset_x + 10*posX
							SE.savedVariables.offset_y = SE.savedVariables.offset_y - 10*posY

							if SE.savedVariables.offset_x < 0 then SE.savedVariables.offset_x = 0 end
							if SE.savedVariables.offset_y < 0 then SE.savedVariables.offset_y = 0 end
							if SE.savedVariables.offset_x > (GuiRoot:GetWidth() - 20) then SE.savedVariables.offset_x = (GuiRoot:GetWidth() - 20) end
							if SE.savedVariables.offset_y >(GuiRoot:GetHeight() - 20) then SE.savedVariables.offset_y = (GuiRoot:GetHeight() - 20) end

							ShowEquipped:ClearAnchors()
							ShowEquipped:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SE.savedVariables.offset_x, SE.savedVariables.offset_y)
						end 
					end)
				else
					EVENT_MANAGER:UnregisterForUpdate(SE.name.."AdjustUI")
					temporarilyShowText()
				end
			end,
			default = SE.currentlyChangingPosition
		})

		--x position offset
		settings:AddSetting({
			type = LibHarvensAddonSettings.ST_SLIDER,
			label = "X Offset",
			tooltip = "",
			setFunction = function(value)
				SE.savedVariables.offset_x = value
				
				ShowEquipped:ClearAnchors()
				ShowEquipped:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SE.savedVariables.offset_x, SE.savedVariables.offset_y)
				
				temporarilyShowText()
			end,
			getFunction = function()
				return SE.savedVariables.offset_x
			end,
			default = 0,
			min = 0,
			max = GuiRoot:GetWidth(),
			step = 5,
			unit = "", --optional unit
			format = "%d", --value format
		})
		
		--y position offset
		settings:AddSetting({
			type = LibHarvensAddonSettings.ST_SLIDER,
			label = "Y Offset",
			tooltip = "",
			setFunction = function(value)
				SE.savedVariables.offset_y = value
				
				ShowEquipped:ClearAnchors()
				ShowEquipped:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SE.savedVariables.offset_x, SE.savedVariables.offset_y)
				
				temporarilyShowText()
			end,
			getFunction = function()
				return SE.savedVariables.offset_y
			end,
			default = 0,
			min = 0,
			max = GuiRoot:GetHeight(),
			step = 5,
			unit = "", --optional unit
			format = "%d", --value format
		})
	end
	EVENT_MANAGER:RegisterForEvent(SE.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, SE.onUpdateEquips)
	EVENT_MANAGER:RegisterForEvent(SE.name, EVENT_ARMORY_BUILD_RESTORE_RESPONSE, SE.onUpdateEquips)

	SE.onUpdateEquips(_, BAG_WORN, _, _, _, _, _)
end
	
function SE.OnAddOnLoaded(event, addonName)
	if addonName == SE.name then
		SE.Initialize()
		EVENT_MANAGER:UnregisterForEvent(SE.name, EVENT_ADD_ON_LOADED)
	end
end

EVENT_MANAGER:RegisterForEvent(SE.name, EVENT_ADD_ON_LOADED, SE.OnAddOnLoaded)