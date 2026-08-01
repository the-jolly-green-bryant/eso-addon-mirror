-------------------------------------------------------------------------------
-- By The Ancestors
-------------------------------------------------------------------------------
ChronicCollector = {}
local ADDON_NAME = "ChronicCollector"
local ADDON_VERSION = "1.2"

--Libraries--------------------------------------------------------------------
local LAM = LibAddonMenu2
local LMP = LibMapPins

--Local constants -------------------------------------------------------------
local TABLET_ACHIEVEMENT_ID = 2320 
local MIREGAUNTS_ACHIEVEMENT_ID = 2321
local PINS_UNKNOWN = "ChronicCollectorMapPin_unknown"
local PINS_COLLECTED = "ChronicCollectorMapPin_collected"
local PINS_COMPASS = "ChronicCollectorCompassPin_unknown"

local INFORMATION_TOOLTIP

--Local variables -------------------------------------------------------------
local updatePins = {}
local updating = false
local savedVariables
local defaults = {			-- default settings for saved variables
	compassMaxDistance = 0.05,
	pinTexture = {
		type = 1,
		size = 26,
		level = 50,
	},
	filters = {
		[PINS_COMPASS] = true,
		[PINS_UNKNOWN] = true,
		[PINS_COLLECTED] = false,
	},
}
local L

-- Pins -----------------------------------------------------------------------
local pinTextures = {
	unknown   = "/esoui/art/icons/poi/poi_crypt_incomplete.dds",
	collected = "/esoui/art/icons/poi/poi_crypt_complete.dds",
}

-- Creates Tool Tip
local pinTooltipCreator = {}
pinTooltipCreator.tooltip = 1 --TOOLTIP_MODE.INFORMATION
pinTooltipCreator.creator = function(pin)

	local _, pinTag = pin:GetPinTypeAndTag()
	local name = GetAchievementInfo(TABLET_ACHIEVEMENT_ID)
	local description, numCompleted = GetAchievementCriterion(TABLET_ACHIEVEMENT_ID, pinTag[3])

	if IsInGamepadPreferredMode() then
		INFORMATION_TOOLTIP:LayoutIconStringLine(INFORMATION_TOOLTIP.tooltip, nil, description, {fontSize = 27, fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_3})
	else
		INFORMATION_TOOLTIP:AddLine(description, "", ZO_HIGHLIGHT_TEXT:UnpackRGB())
		if pinTag[4] then
			local miregaunt = GetAchievementCriterion(MIREGAUNTS_ACHIEVEMENT_ID, pinTag[4])
			INFORMATION_TOOLTIP:AddLine(zo_strformat("[<<1>> <<2>>]", L.Tooltip_Kill, miregaunt), "", ZO_HIGHLIGHT_TEXT:UnpackRGB())
		end
	end

end

local tablets = {}
local tabletsCount = 0
local tabletLinks = {}
local validTablets = {}
local function ItemIdForTabletIndex(index)
	return 141717 + index -- index starts at 2
end
for i=2, 12 do
	local id = ItemIdForTabletIndex(i)
	local link = ("|H1:item:%d:1:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h"):format(id)
	validTablets[id] = true
	tabletLinks[id] = link
end

local function RecheckTablets()
	tablets = {}
	local count = 0
	for itemId, itemLink in pairs(tabletLinks) do
		if (GetItemLinkStacks(itemLink)) > 0 then
			tablets[itemId] = true
			count = count + 1
		end
	end

	if tabletsCount ~= count then
		LMP:RefreshPins(PINS_UNKNOWN)
		LMP:RefreshPins(PINS_COLLECTED)
		COMPASS_PINS:RefreshPins(PINS_COMPASS)
	end
	tabletsCount = count
end

local function IsTabletCollected(criteriaIndex)
	local _, numCompleted = GetAchievementCriterion(TABLET_ACHIEVEMENT_ID, criteriaIndex)
	local itemId = ItemIdForTabletIndex(criteriaIndex)
	if (numCompleted == 1) then 
		return true, true
	elseif (tablets[itemId]) then 
		return true, false
	elseif (numCompleted == 0) then
		return false, false
	end
	return false
end

-- Callback to Create pins
local function CreatePins()
	
	local zone, subzone = LMP:GetZoneAndSubzone()
	local tablets = ChronicCollector_GetLocalData(zone, subzone)

	if tablets ~= nil then
		for _, pinData in ipairs(tablets) do
			local isCollected, isDelivered = IsTabletCollected(pinData[3])
			if (isCollected and updatePins[PINS_COLLECTED] and LMP:IsEnabled(PINS_COLLECTED)) then
				LMP:CreatePin(PINS_COLLECTED, pinData, pinData[1], pinData[2])
			elseif (not isCollected) then
				if (updatePins[PINS_UNKNOWN] and LMP:IsEnabled(PINS_UNKNOWN)) then
					LMP:CreatePin(PINS_UNKNOWN, pinData, pinData[1], pinData[2])
				end
				if (updatePins[PINS_COMPASS] and savedVariables.filters[PINS_COMPASS]) then
					COMPASS_PINS.pinManager:CreatePin(PINS_COMPASS, pinData, pinData[1], pinData[2])
				end
			end
		end
	end

	updatePins = {}
	updating = false
end

local function QueueCreatePins(pinType)
	updatePins[pinType] = true

	if not updating then
		updating = true
		if IsPlayerActivated() then
			CreatePins() -- Normal way. AUI will fire its refresh after this code has run so it will create duplicates if left "as is".
		else
			EVENT_MANAGER:RegisterForEvent("ChronicCollector_PinUpdate", EVENT_PLAYER_ACTIVATED,
				function(event)
					EVENT_MANAGER:UnregisterForEvent("ChronicCollector_PinUpdate", event)
					CreatePins()
				end)
		end
	end
end

local function MapCallback_unknown()
	if not LMP:IsEnabled(PINS_UNKNOWN) or (GetMapType() > MAPTYPE_ZONE) then return end
	QueueCreatePins(PINS_UNKNOWN)
end

local function MapCallback_collected()
	if not LMP:IsEnabled(PINS_COLLECTED) or (GetMapType() > MAPTYPE_ZONE) then return end
	QueueCreatePins(PINS_COLLECTED)
end

local function CompassCallback()
	if not savedVariables.filters[PINS_COMPASS] or (GetMapType() > MAPTYPE_ZONE) then return end
	QueueCreatePins(PINS_COMPASS)
end


-- Gamepad Switch -------------------------------------------------------------
local function OnGamepadPreferredModeChanged()
    if IsInGamepadPreferredMode() then
        INFORMATION_TOOLTIP = ZO_MapLocationTooltip_Gamepad
    else
        INFORMATION_TOOLTIP = InformationTooltip
    end
end

-- Settings menu --------------------------------------------------------------
local function CreateSettingsMenu()

	L = ChronicCollector:GetLocale()

	local panelData = {
		type = "panel",
		name = "Chronic Collector",
		displayName = "|cD2B87BChronic Collector|r",
		author = "|cFF5FF5Kyoma|r",
		version = ADDON_VERSION,
		registerForRefresh = true,
		registerForDefaults = true,
	}
	LAM:RegisterAddonPanel(ADDON_NAME, panelData)

	local optionsTable = {
		{
			type = "slider",
			name = L.Appearance_PinSize,
			tooltip = L.Appearance_PinSize_Desc,
			min = 20,
			max = 70,
			getFunc = function() return savedVariables.pinTexture.size end,
			setFunc = function(size)
					savedVariables.pinTexture.size = size
					LMP:SetLayoutKey(PINS_UNKNOWN, "size", size)
					LMP:SetLayoutKey(PINS_COLLECTED, "size", size)
					LMP:RefreshPins(PINS_UNKNOWN)
					LMP:RefreshPins(PINS_COLLECTED)
				end,
			disabled = function() return not (savedVariables.filters[PINS_UNKNOWN] or savedVariables.filters[PINS_COLLECTED]) end,
			default = defaults.pinTexture.size
		},
		{
			type = "slider",
			name = L.Appearance_PinLayer,
			tooltip = L.Appearance_PinLayer_Desc,
			min = 10,
			max = 200,
			step = 5,
			getFunc = function() return savedVariables.pinTexture.level end,
			setFunc = function(level)
					savedVariables.pinTexture.level = level
					LMP:SetLayoutKey(PINS_UNKNOWN, "level", level)
					LMP:SetLayoutKey(PINS_COLLECTED, "level", level)
					LMP:RefreshPins(PINS_UNKNOWN)
					LMP:RefreshPins(PINS_COLLECTED)
				end,
			disabled = function() return not (savedVariables.filters[PINS_UNKNOWN] or savedVariables.filters[PINS_COLLECTED]) end,
			default = defaults.pinTexture.level,
		},
		{
			type = "checkbox",
			name = L.Filters_Unknown,
			tooltip = L.Filters_Unknown_Desc,
			getFunc = function() return savedVariables.filters[PINS_UNKNOWN] end,
			setFunc = function(state)
					savedVariables.filters[PINS_UNKNOWN] = state
					LMP:SetEnabled(PINS_UNKNOWN, state)
				end,
			default = defaults.filters[PINS_UNKNOWN],
		},
		{
			type = "checkbox",
			name = L.Filters_Collected,
			tooltip = L.Filters_Collected_Desc,
			getFunc = function() return savedVariables.filters[PINS_COLLECTED] end,
			setFunc = function(state)
					savedVariables.filters[PINS_COLLECTED] = state
					LMP:SetEnabled(PINS_COLLECTED, state)
				end,
			default = defaults.filters[PINS_COLLECTED]
		},
		{
			type = "checkbox",
			name = L.Compass_Unknown,
			tooltip = L.Compass_Unknown_Desc,
			getFunc = function() return savedVariables.filters[PINS_COMPASS] end,
			setFunc = function(state)
					savedVariables.filters[PINS_COMPASS] = state
					COMPASS_PINS:RefreshPins(PINS_COMPASS)
				end,
			default = defaults.filters[PINS_COMPASS],
		},
		{
			type = "slider",
			name = L.Compass_Dist,
			tooltip = L.Compass_Dist_Desc,
			min = 1,
			max = 100,
			getFunc = function() return savedVariables.compassMaxDistance * 1000 end,
			setFunc = function(maxDistance)
					savedVariables.compassMaxDistance = maxDistance / 1000
					COMPASS_PINS.pinLayouts[PINS_COMPASS].maxDistance = maxDistance / 1000
					COMPASS_PINS:RefreshPins(PINS_COMPASS)
				end,
			width = "full",
			disabled = function() return not savedVariables.filters[PINS_COMPASS] end,
			default = defaults.compassMaxDistance * 1000,
		},
	}
	LAM:RegisterOptionControls(ADDON_NAME, optionsTable)

end

-- Event handlers -------------------------------------------------------------
local function OnInventorySlotUpdate(eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)

	local itemId = GetItemId(bagId, slotId)
	if validTablets[itemId] and not tablets[itemId] then
		tablets[itemId] = validTablets[itemId]
		tabletsCount = tabletsCount + 1

		LMP:RefreshPins(PINS_UNKNOWN)
		LMP:RefreshPins(PINS_COLLECTED)
		COMPASS_PINS:RefreshPins(PINS_COMPASS)
	end
end

local function OnAchievementUpdate(eventCode, achievementId)

	if achievementId == TABLET_ACHIEVEMENT_ID then
		RecheckTablets()
		-- refresh pins
		LMP:RefreshPins(PINS_UNKNOWN)
		LMP:RefreshPins(PINS_COLLECTED)
		COMPASS_PINS:RefreshPins(PINS_COMPASS)
		-- unregister once achievement is complete
		if IsAchievementComplete(TABLET_ACHIEVEMENT_ID) then 
			EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ACHIEVEMENT_UPDATED)
			EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_INVENTORY_ITEM_DESTROYED)
			EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
		end
	end
end

-- Initialize --------------------------------------------------------------
local function OnLoad(eventCode, addOnName)
    if(addOnName == ADDON_NAME) then
        -- Create addon menu
		savedVariables = ZO_SavedVars:NewCharacterNameSettings("ChronicCollector_SV", 1, nil, defaults)

		--events (only if achievement is not completed yet)
		if not IsAchievementComplete(TABLET_ACHIEVEMENT_ID) then 
			EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ACHIEVEMENT_UPDATED, OnAchievementUpdate)
			EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_INVENTORY_ITEM_DESTROYED, function() zo_callLater(RecheckTablets, 200) end) --small delay needed
			EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnInventorySlotUpdate)
			EVENT_MANAGER:AddFilterForEvent(ADDON_NAME, EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
														REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT,
														REGISTER_FILTER_IS_NEW_ITEM, true,
														REGISTER_FILTER_BAG_ID, BAG_BACKPACK)
			RecheckTablets()
		end

		--get pin layout from saved variables
		local pinTextureLevel = savedVariables.pinTexture.level
		local pinTextureSize = savedVariables.pinTexture.size
		local compassMaxDistance = savedVariables.compassMaxDistance

		local pinLayout_unknown = { level = pinTextureLevel, texture = pinTextures.unknown, size = pinTextureSize, tint = ZO_SELECTED_TEXT }
		local pinLayout_collected = { level = pinTextureLevel, texture = pinTextures.collected, size = pinTextureSize, tint = ZO_SELECTED_TEXT }
		local pinLayout_compassunknown = {
			maxDistance = compassMaxDistance,
			texture = pinTextures.unknown,
			sizeCallback = function(pin, angle, normalizedAngle, normalizedDistance)
				if zo_abs(normalizedAngle) > 0.25 then
					pin:SetDimensions(54 - 24 * zo_abs(normalizedAngle), 54 - 24 * zo_abs(normalizedAngle))
				else
					pin:SetDimensions(48, 48)
				end
			end,
			additionalLayout = {
				function(pin)
					--
				end,
				function(pin)
					--
				end
			}
		}

		--initialize map pins
		LMP:AddPinType(PINS_UNKNOWN, MapCallback_unknown, nil, pinLayout_unknown, pinTooltipCreator)
		LMP:AddPinType(PINS_COLLECTED, MapCallback_collected, nil, pinLayout_collected, pinTooltipCreator)

		--add filter check boxex
		local L = ChronicCollector:GetLocale()
		LMP:AddPinFilter(PINS_UNKNOWN,   L.MapFilters_Unknown, nil, savedVariables.filters)
		LMP:AddPinFilter(PINS_COLLECTED, L.MapFilters_Collected, nil, savedVariables.filters)

		--add handler for the left click
		local clickHandler = {
			[1] = {
				name = GetString(BTANC_SET_WAYPOINT),
				show = function(pin) return true end,
				duplicates = function(pin1, pin2) return (pin1.m_PinTag[3] == pin2.m_PinTag[3] and pin1.m_PinTag[4] == pin2.m_PinTag[4]) end,
				callback = function(pin) PingMap(MAP_PIN_TYPE_PLAYER_WAYPOINT, MAP_TYPE_LOCATION_CENTERED, pin.normalizedX, pin.normalizedY) end,
			},
		}
		LMP:SetClickHandlers(PINS_UNKNOWN, clickHandler)
		LMP:SetClickHandlers(PINS_COLLECTED, clickHandler)

		--initialize compass pins
		COMPASS_PINS:AddCustomPin(PINS_COMPASS, CompassCallback, pinLayout_compassunknown)
		COMPASS_PINS:RefreshPins(PINS_COMPASS)

		-- addon menu
		CreateSettingsMenu()
		
		-- Set wich tooltip must be used
		OnGamepadPreferredModeChanged()

		EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, OnGamepadPreferredModeChanged)

        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    end
end

-- Init ChronicCollector
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnLoad)