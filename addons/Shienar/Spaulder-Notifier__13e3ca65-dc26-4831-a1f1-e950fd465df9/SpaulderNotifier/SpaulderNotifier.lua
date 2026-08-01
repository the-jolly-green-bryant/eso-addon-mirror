SN = { name = "SpaulderNotifier" }

local function IsWearingSpaulder()
	--hasSet, setName, numBonuses, numNormal, maxEquipped, setID, numPerfected
	local _, _, _, _, _, setID, _ = GetItemLinkSetInfo(GetItemLink(BAG_WORN, EQUIP_SLOT_SHOULDERS))
	
	if setID == 627 then
		return true
	else
		if SN.savedVariables.activeSpaulder then 
			SN.savedVariables.activeSpaulder = false
		end
		if SpaulderDisplay:IsHidden() == false then
			SpaulderDisplay:SetHidden(true)
		end
		return false
	end
end

function SN.OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, _log, sourceUnitID, targetUnitID, abilityID, overflow)
	if abilityID == 163359 and targetType == COMBAT_UNIT_TYPE_PLAYER and IsWearingSpaulder() then
		if result == ACTION_RESULT_EFFECT_GAINED then
			SN.savedVariables.activeSpaulder = true
			SpaulderDisplay:SetHidden(true)
		elseif result == ACTION_RESULT_EFFECT_FADED then
			SN.savedVariables.activeSpaulder = false
			SpaulderDisplay:SetHidden(false)
		end
	end
end

function SN.onUpdateEquips(code, bagID, slotIndex, isNewItem, soundCategory, updateReason, stackChange)
	if IsWearingSpaulder() then
		SpaulderDisplay:SetHidden(SN.savedVariables.activeSpaulder)
	end
end

function SN.onTravel(code, initial)
	if (SN.firstLogin or initial) and SN.savedVariables.currentZoneID ~= GetUnitRawWorldPosition("player") then
		SN.savedVariables.activeSpaulder = false
		if IsWearingSpaulder() then SpaulderDisplay:SetHidden(false) end
		SN.savedVariables.currentZoneID = GetUnitRawWorldPosition("player")
		SN.firstLogin = false
	end
end

local function temporarilyShowLabel()
    --Hide UI 5 seconds after most recent change.
    SpaulderDisplay:SetHidden(false)
    EVENT_MANAGER:RegisterForUpdate(SN.name.."_editLabel", 5000, function()
        if SCENE_MANAGER:GetScene("hud"):GetState() == SCENE_HIDDEN or SN.savedVariables.isHidden or (IsWearingSpaulder() == false) then
            SpaulderDisplay:SetHidden(true)
        end
        EVENT_MANAGER:UnregisterForUpdate(SN.name.."_editLabel")
    end)
end

function SN.Initialize()
	SN.defaults = {
		activeSpaulder = true,
		currentZoneID = -1,

		selectedFontNumber = "42", --fontsize
		fontWeight = "soft-shadow-thin",
		fontStyle = "GAMEPAD_MEDIUM_FONT",

		color = {
			red = 1,
			green= 0,
			blue = 0,
			alpha = 1,
		},
		offset_x = 0,
		offset_y = -300;
	}

	SN.savedVariables = ZO_SavedVars:New("SNSavedVariables", 1, nil, SN.defaults, GetWorldName())
	SpaulderDisplay:ClearAnchors()
	SpaulderDisplay:SetAnchor(CENTER, GuiRoot, CENTER, SN.savedVariables.offset_x, SN.savedVariables.offset_y)
	SpaulderDisplayLabel:SetColor(SN.savedVariables.color.red, SN.savedVariables.color.green, SN.savedVariables.color.blue)
	SpaulderDisplayLabel:SetAlpha(SN.savedVariables.color.alpha)
	SpaulderDisplayLabel:SetFont(string.format("$(%s)|%s|%s", SN.savedVariables.fontStyle, SN.savedVariables.selectedFontNumber, SN.savedVariables.fontWeight))

	if IsWearingSpaulder() then
		SpaulderDisplay:SetHidden(SN.savedVariables.activeSpaulder)
	end
	
	if LibHarvensAddonSettings then
		--settings
		local settings = LibHarvensAddonSettings:AddAddon("Spaulder Notifier")

		settings:AddSetting({type = LibHarvensAddonSettings.ST_SECTION,label = "Font",})

		settings:AddSetting({
			type = LibHarvensAddonSettings.ST_SLIDER,
			label = "Font Size",
			tooltip = "",
			setFunction = function(value)
				SN.savedVariables.selectedFontNumber = value
				SpaulderDisplayLabel:SetFont(string.format("$(%s)|%s|%s", SN.savedVariables.fontStyle, SN.savedVariables.selectedFontNumber, SN.savedVariables.fontWeight))
				temporarilyShowLabel()
			end,
			getFunction = function()
				return SN.savedVariables.selectedFontNumber
			end,
			default = SN.defaults.selectedFontNumber,
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
			getFunction = function() return SN.savedVariables.fontStyle end,
			setFunction = function(control, itemName, itemData) 
				SN.savedVariables.fontStyle = itemName
				SpaulderDisplayLabel:SetFont(string.format("$(%s)|%s|%s", SN.savedVariables.fontStyle, SN.savedVariables.selectedFontNumber, SN.savedVariables.fontWeight))
				temporarilyShowLabel()
			end,
			default = SN.defaults.fontStyle
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
			getFunction = function() return SN.savedVariables.fontWeight end,
			setFunction = function(control, itemName, itemData) 
				SN.savedVariables.fontWeight = itemName
				SpaulderDisplayLabel:SetFont(string.format("$(%s)|%s|%s", SN.savedVariables.fontStyle, SN.savedVariables.selectedFontNumber, SN.savedVariables.fontWeight))
				temporarilyShowLabel()
			end,
			default = SN.defaults.fontWeight
		})

		settings:AddSetting({
			type = LibHarvensAddonSettings.ST_COLOR,
			label = "Color",
			tooltip = "Change the color of the label.",
			setFunction = function(...) --newR, newG, newB, newA
				SN.savedVariables.color.red, SN.savedVariables.color.green, SN.savedVariables.color.blue, SN.savedVariables.color.alpha = ...
				SpaulderDisplayLabel:SetColor(SN.savedVariables.color.red, SN.savedVariables.color.green, SN.savedVariables.color.blue)
				SpaulderDisplayLabel:SetAlpha(SN.savedVariables.color.alpha)

				temporarilyShowLabel()
			end,
			default = {SN.defaults.color.red, SN.defaults.color.green, SN.defaults.color.blue, SN.defaults.color.alpha},
			getFunction = function()
				return SN.savedVariables.color.red, SN.savedVariables.color.green, SN.savedVariables.color.blue, SN.savedVariables.color.alpha
			end,
		})

		settings:AddSetting({type = LibHarvensAddonSettings.ST_SECTION,label = "Position",})

		SN.currentlyChangingPosition = false
		settings:AddSetting({
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = "Joystick Reposition",
			tooltip = "When enabled, you will be able to freely move around the UI with your right joystick.\n\nSet this to OFF after configuring position.",
			getFunction = function() return SN.currentlyChangingPosition end,
			setFunction = function(value) 
				SN.currentlyChangingPosition = value
				if value == true then
					SpaulderDisplay:SetHidden(false)
					EVENT_MANAGER:RegisterForUpdate(SN.name.."AdjustUI", 10,  function() 
						local posX, posY = GetGamepadRightStickX(true), GetGamepadRightStickY(true)
						if posX ~= 0 or posY ~= 0 then 
							SN.savedVariables.offset_x = SN.savedVariables.offset_x + 10*posX
							SN.savedVariables.offset_y = SN.savedVariables.offset_y - 10*posY

							if SN.savedVariables.offset_x < (-GuiRoot:GetWidth()/2) then SN.savedVariables.offset_x = (-GuiRoot:GetWidth()/2) end
							if SN.savedVariables.offset_y < (-GuiRoot:GetHeight()/2) then SN.savedVariables.offset_y = (-GuiRoot:GetHeight()/2) end
							if SN.savedVariables.offset_x > (GuiRoot:GetWidth()/2) then SN.savedVariables.offset_x = (GuiRoot:GetWidth()/2) end
							if SN.savedVariables.offset_y >(GuiRoot:GetHeight()/2) then SN.savedVariables.offset_y = (GuiRoot:GetHeight()/2) end

							SpaulderDisplay:ClearAnchors()
							SpaulderDisplay:SetAnchor(CENTER, GuiRoot, CENTER, SN.savedVariables.offset_x, SN.savedVariables.offset_y)
						end 
					end)
				else
					EVENT_MANAGER:UnregisterForUpdate(SN.name.."AdjustUI")
					temporarilyShowLabel()
				end
			end,
			default = SN.currentlyChangingPosition
		})

		--x position offset
		settings:AddSetting({
			type = LibHarvensAddonSettings.ST_SLIDER,
			label = "X Offset",
			tooltip = "",
			setFunction = function(value)
				SN.savedVariables.offset_x = value
				
				SpaulderDisplay:ClearAnchors()
				SpaulderDisplay:SetAnchor(CENTER, GuiRoot, CENTER, SN.savedVariables.offset_x, SN.savedVariables.offset_y)
				
				temporarilyShowLabel()
			end,
			getFunction = function()
				return SN.savedVariables.offset_x
			end,
			default = SN.defaults.offset_x,
			min = (-GuiRoot:GetWidth()/2),
			max = (GuiRoot:GetWidth()/2),
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
				SN.savedVariables.offset_y = value

				SpaulderDisplay:ClearAnchors()
				SpaulderDisplay:SetAnchor(CENTER, GuiRoot, CENTER, SN.savedVariables.offset_x, SN.savedVariables.offset_y)
				
				temporarilyShowLabel()
			end,
			getFunction = function()
				return SN.savedVariables.offset_y
			end,
			default = SN.defaults.offset_y,
			min = (-GuiRoot:GetHeight()/2),
			max = (GuiRoot:GetHeight()/2),
			step = 5,
			unit = "", --optional unit
			format = "%d", --value format
		})

		settings:AddSettings({fontSection, spaulder_font, color})
		settings:AddSettings({positionSection, repositionUI, slider_x, slider_y})
	end

	SN.firstLogin = true
	
	EVENT_MANAGER:RegisterForEvent(SN.name, EVENT_COMBAT_EVENT, SN.OnCombatEvent)
	EVENT_MANAGER:RegisterForEvent(SN.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, SN.onUpdateEquips)
	EVENT_MANAGER:RegisterForEvent(SN.name, EVENT_ARMORY_BUILD_RESTORE_RESPONSE, SN.onUpdateEquips)
	EVENT_MANAGER:RegisterForEvent(SN.name, EVENT_PLAYER_ACTIVATED, SN.onTravel)
end

function SN.OnAddOnLoaded(event, addonName)
	if addonName == SN.name then
		SN.Initialize()
		EVENT_MANAGER:UnregisterForEvent(SN.name, EVENT_ADD_ON_LOADED)
	end
end

EVENT_MANAGER:RegisterForEvent(SN.name, EVENT_ADD_ON_LOADED, SN.OnAddOnLoaded)