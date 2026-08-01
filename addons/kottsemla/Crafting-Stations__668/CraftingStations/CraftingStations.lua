-------------------------------------------------------------------------------
-- Crafting Stations
-------------------------------------------------------------------------------
local ADDON_NAME = "CraftingStations"
CraftingStations = {}

--Libraries--------------------------------------------------------------------
local LMP = LibMapPins
local LGPS = LibGPS3
local logger = LibDebugLogger(ADDON_NAME)

--Local constants -------------------------------------------------------------
local PINTYPE_NAME = "Crafting_Station_Pin"
local TAMRIEL_MAP_INDEX = 1
local LOCATION_DATA_OUTPUT = "{ %.6f, %.6f, %d, %d, %d, %s }, -- \"%s\""
local SET_DATA_OUTPUT = "[%d] = { %d, %d }, --\"%s\""
local GAMEPAD_TRAITS_STYLE = {fontSize = 27, fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_3}
local GAMEPAD_SET_INFO_STYLE = {fontSize = 27, fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_3, width = 325}
local KEYBOARD_TOOLTIP_STYLES = { -- TODO: translate, requires changes to LAM dropdown control
    "Full",
    "Full (Divider)",
    "Compact",
    "Minimal"
}
local KEYBOARD_TOOLTIP_STYLE_FULL, KEYBOARD_TOOLTIP_STYLE_FULL_DIVIDER,
    KEYBOARD_TOOLTIP_STYLE_COMPACT, KEYBOARD_TOOLTIP_STYLE_MINIMAL = unpack(KEYBOARD_TOOLTIP_STYLES)

CraftingStations.PINTYPE_NAME = PINTYPE_NAME
CraftingStations.KEYBOARD_TOOLTIP_STYLES = KEYBOARD_TOOLTIP_STYLES

local INFORMATION_TOOLTIP

--Local variables -------------------------------------------------------------
local savedVariables

-- Creates Tool Tip
local pinTooltipCreator = {}
pinTooltipCreator.tooltip = 1

local function GetSetInfoFromPin(pin)
    local _, pinTag = pin:GetPinTypeAndTag()
    return CraftingStations.ItemSets[pinTag[3]]
end

local function CreateGamepadTooltip(setInfo)
    local tooltip = INFORMATION_TOOLTIP.tooltip
    INFORMATION_TOOLTIP:LayoutIconStringLine(tooltip, nil, zo_strformat(setInfo.name), tooltip:GetStyle("mapTitle"))
    INFORMATION_TOOLTIP:LayoutIconStringLine(tooltip, nil, zo_strformat(setInfo.traits), GAMEPAD_TRAITS_STYLE)
    INFORMATION_TOOLTIP:LayoutIconStringLine(tooltip, nil, zo_strformat(table.concat(setInfo.info, "\n")), GAMEPAD_SET_INFO_STYLE)
end

local KEYBOARD_TOOLTIP_CREATOR = {
    [KEYBOARD_TOOLTIP_STYLE_FULL] = function(setInfo)
        ZO_Tooltip_AddDivider(INFORMATION_TOOLTIP)
        INFORMATION_TOOLTIP:AddVerticalPadding(savedVariables.linePadding)
        INFORMATION_TOOLTIP:AddLine(setInfo.name, "ZoFontGameOutline", ZO_SELECTED_TEXT:UnpackRGB())
        INFORMATION_TOOLTIP:AddVerticalPadding(savedVariables.linePadding)
        INFORMATION_TOOLTIP:AddLine(setInfo.traits, "ZoFontGame", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
        INFORMATION_TOOLTIP:AddVerticalPadding(savedVariables.linePadding)
        ZO_Tooltip_AddDivider(INFORMATION_TOOLTIP)
        INFORMATION_TOOLTIP:AddVerticalPadding(savedVariables.linePadding)
        if (savedVariables.altAlign == true) then
            for _, bonus in ipairs(setInfo.info) do
                INFORMATION_TOOLTIP:AddLine(bonus, "ZoFontGame", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
                INFORMATION_TOOLTIP:AddVerticalPadding(savedVariables.linePadding)
            end
        else
            INFORMATION_TOOLTIP:AddLine(table.concat(setInfo.info, "\n"), "ZoFontGame", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
            INFORMATION_TOOLTIP:AddVerticalPadding(savedVariables.linePadding)
        end
        ZO_Tooltip_AddDivider(INFORMATION_TOOLTIP)
    end,
    [KEYBOARD_TOOLTIP_STYLE_FULL_DIVIDER] = function(setInfo)
        INFORMATION_TOOLTIP:AddLine("Crafting Station", "ZoFontGameOutline", ZO_SELECTED_TEXT:UnpackRGB())
        INFORMATION_TOOLTIP:AddVerticalPadding(savedVariables.linePadding)
        INFORMATION_TOOLTIP:AddLine(setInfo.traits, "ZoFontGame", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
        ZO_Tooltip_AddDivider(INFORMATION_TOOLTIP)
        INFORMATION_TOOLTIP:AddVerticalPadding(savedVariables.linePadding)
        INFORMATION_TOOLTIP:AddLine(setInfo.name, "ZoFontGameOutline", ZO_SELECTED_TEXT:UnpackRGB())
        INFORMATION_TOOLTIP:AddVerticalPadding(savedVariables.linePadding)
        if (savedVariables.altAlign == true) then
            for _, bonus in ipairs(setInfo.info) do
                INFORMATION_TOOLTIP:AddLine(bonus, "ZoFontGame", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
                INFORMATION_TOOLTIP:AddVerticalPadding(savedVariables.linePadding)
            end
        else
            INFORMATION_TOOLTIP:AddLine(table.concat(setInfo.info, "\n"), "ZoFontGame", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
            INFORMATION_TOOLTIP:AddVerticalPadding(savedVariables.linePadding)
        end
    end,
    [KEYBOARD_TOOLTIP_STYLE_COMPACT] = function(setInfo)
        INFORMATION_TOOLTIP:AddLine(setInfo.name, "ZoFontGameOutline", ZO_SELECTED_TEXT:UnpackRGB())
        INFORMATION_TOOLTIP:AddVerticalPadding(savedVariables.linePadding)
        if (savedVariables.altAlign == true) then
            for _, bonus in ipairs(setInfo.info) do
                INFORMATION_TOOLTIP:AddLine(bonus, "ZoFontGame", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
                INFORMATION_TOOLTIP:AddVerticalPadding(savedVariables.linePadding)
            end
        else
            INFORMATION_TOOLTIP:AddLine(table.concat(setInfo.info, "\n"), "ZoFontGame", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
            INFORMATION_TOOLTIP:AddVerticalPadding(savedVariables.linePadding)
        end
    end,
    [KEYBOARD_TOOLTIP_STYLE_MINIMAL] = function(setInfo)
        INFORMATION_TOOLTIP:AddLine(setInfo.name, "ZoFontGameOutline", ZO_SELECTED_TEXT:UnpackRGB())
        INFORMATION_TOOLTIP:AddVerticalPadding(savedVariables.linePadding)
        INFORMATION_TOOLTIP:AddLine(setInfo.traits, "ZoFontGame", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
    end,
}

pinTooltipCreator.creator = function(pin)
    local setInfo = GetSetInfoFromPin(pin)

    if IsInGamepadPreferredMode() then
        CreateGamepadTooltip(setInfo)
    else
        local CreateKeyboardTooltip = KEYBOARD_TOOLTIP_CREATOR[savedVariables.tooltipStyle]
        if(not CreateKeyboardTooltip) then
            df("[CraftingStations] Invalid tooltip style '%s' selected. Change it in the addon settings and if this message still appears, report it in the addon's comment section on esoui.com", tostring(savedVariables.tooltipStyle))
            INFORMATION_TOOLTIP:AddLine("Invalid style for CraftingStations Tooltip", "", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
            return
        end
        CreateKeyboardTooltip(setInfo)
    end
end

pinTooltipCreator.hasTooltip = function()
    return savedVariables.tooltipEnabled
end

local function IsPinVisible(x, y, setIndex, zoneIndex, poiIndex, achievementId)
    --    if(setIndex >= 33 and GetAPIVersion() < 100015) then return false end
    if(not x or not y or x <= 0 or x >= 1 or y <= 0 or y >= 1) then return false end
    if(savedVariables.showOnlyDiscovered) then
        if(achievementId) then
            if(not IsAchievementComplete(achievementId)) then return false end
        else
            local _, _, poiType = GetPOIMapInfo(zoneIndex, poiIndex)
            if(poiType ~= MAP_PIN_TYPE_POI_COMPLETE) then return false end
        end
    end
    return true
end

-- Callback to Create pins
local function CreatePins()
    local isCosmic = (GetMapType() == MAPTYPE_COSMIC)
    logger:Verbose("CreatePins", isCosmic, savedVariables.showCraftingStations)
    if isCosmic or not savedVariables.showCraftingStations then return end

    local isTamrielMap = (GetCurrentMapIndex() == TAMRIEL_MAP_INDEX)
    if(isTamrielMap and not savedVariables.showTamrielStations) then return end

    local measurement = LGPS:GetCurrentMapMeasurement() -- TODO: LGPS:GetCurrentZoneMapIndex()
    if(measurement) then
        local currentZoneMapIndex = measurement:GetMapIndex()
        for index, data in ipairs(CraftingStations.Data) do
            local x, y, setIndex, zoneMapIndex, zoneId, poiIndex, hideOnWorldmap, achievementId = unpack(data)
            local zoneIndex = GetZoneIndex(zoneId)
            logger:Verbose("Check preconditions for pin: %d", index)
            if((not isTamrielMap and zoneMapIndex == currentZoneMapIndex) or (isTamrielMap and not hideOnWorldmap)) then
                x, y = LGPS:GlobalToLocal(x, y)
                if(IsPinVisible(x, y, setIndex, zoneIndex, poiIndex, achievementId)) then
                    logger:Verbose("Create pin")
                    LMP:CreatePin(PINTYPE_NAME, data, x, y)
                end
            end
        end
    else
        logger:Debug("CreatePins - LibGPS has no measurement for the current map")
    end
end

-- Gamepad Switch -------------------------------------------------------------
local function OnGamepadPreferredModeChanged()
    if IsInGamepadPreferredMode() then
        INFORMATION_TOOLTIP = ZO_MapLocationTooltip_Gamepad
    else
        INFORMATION_TOOLTIP = InformationTooltip
    end
end

-- Initialize --------------------------------------------------------------
local function OnLoad(eventCode, addOnName)
    if(addOnName == ADDON_NAME) then
        -- Create addon menu
        savedVariables = CraftingStations.CreateSettingsMenu(savedVariables)

        -- Get pin layout from saved variables
        local pinLayout = {
            level = savedVariables.pinTexture.level,
            texture = savedVariables.pinTexture.path,
            size = savedVariables.pinTexture.size,
            tint = ZO_ColorDef:New(unpack(savedVariables.pinColor))
        }

        -- Initialize map pins (LibMapPins)
        LMP:AddPinType(PINTYPE_NAME, CreatePins, nil, pinLayout, pinTooltipCreator)

        -- Add filter check boxes
        LMP:AddPinFilter(PINTYPE_NAME, "Crafting Stations", nil, savedVariables.filters)

        -- Add handler for Left Click
        LMP:SetClickHandlers(PINTYPE_NAME, {
            [1] = {
                name = "Set waypoint to crafting station",
                show = function(pin) return true end,
                duplicates = function(pin1, pin2) return (pin1.m_PinTag[3] == pin2.m_PinTag[3]) end,
                callback = function(pin) PingMap(MAP_PIN_TYPE_PLAYER_WAYPOINT, MAP_TYPE_LOCATION_CENTERED, pin.normalizedX, pin.normalizedY) end,
            }
        })

        -- Set which tooltip must be used
        OnGamepadPreferredModeChanged()
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, OnGamepadPreferredModeChanged)

        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    end
end

-- Init CraftingStations
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnLoad)

-- Functions for finding new sets
local function GetSetIndexByName(setName)
    local itemSets = CraftingStations.ItemSets
    for i, data in ipairs(itemSets) do
        if(data.name == setName) then
            return i, true
        end
    end
    return #itemSets + 1, false
end

local function PrintItemSetData(_, craftSkill, sameStation)
    if(not CanSmithingSetPatternsBeCraftedHere()) then return end

    local lastPatternIndex = GetNumSmithingPatterns()
    local FIRST_MATERIAL = 9
    local FIRST_MATERIAL_COUNT = 7
    local FIRST_STYLE = 2
    local NO_TRAIT = 1
    local link = GetSmithingPatternResultLink(lastPatternIndex, FIRST_MATERIAL, FIRST_MATERIAL_COUNT, FIRST_STYLE, NO_TRAIT)
    local hasSet, setName = GetItemLinkSetInfo(link)
    if(hasSet) then
        -- switch to zone map
        if(not GetMapTileTexture():find("earthforge") and not GetMapTileTexture():find("brassfortress") and not IsInImperialCity()) then
            while not(GetMapType() == MAPTYPE_ZONE and GetMapContentType() ~= MAP_CONTENT_DUNGEON) do
                if (MapZoomOut() ~= SET_MAP_RESULT_MAP_CHANGED) then break end
            end
        end

        --get closest crafting station map pin
        local x, y = GetMapPlayerPosition("player")
        local minDist = 1
        local closestPOI
        local zoneIndex = GetCurrentMapZoneIndex()
        local zoneId = GetZoneId(zoneIndex)
        for i=1, GetNumPOIs(zoneIndex) do
            local nX, nY, type, icon = GetPOIMapInfo(zoneIndex, i)
            if(icon:find("poi_crafting_")) then
                local dist = (nX - x) * (nX - x) + (nY - y) * (nY - y)
                if(dist < minDist) then
                    closestPOI = i
                    minDist = dist
                end
            end
        end

        if(not closestPOI) then
            for i=1, GetNumMapLocations() do
                local icon, nX, nY = GetMapLocationIcon(i)
                if(icon:find("_smithy")) then
                    local dist = (nX - x) * (nX - x) + (nY - y) * (nY - y)
                    if(dist < minDist) then
                        closestPOI = -i
                        minDist = dist
                    end
                end
            end
        end

        local nX, nY, _
        if(closestPOI) then
            if(closestPOI > 0) then
                nX, nY = GetPOIMapInfo(zoneIndex, closestPOI)
            else
                _, nX, nY = GetMapLocationIcon(-closestPOI)
            end
        else
            d("[CraftingStations] Warning: No POI found, using player position instead")
            nX, nY = x, y
            closestPOI = nil
        end
        local measurement = LGPS:GetCurrentMapMeasurement()
        if(measurement) then
            local gX, gY = measurement:ToGlobal(nX, nY)
            local zoneMapIndex = measurement:GetMapIndex()
            local _, _, _, _, traits = GetSmithingPatternInfo(lastPatternIndex)
            local itemId = select(3, zo_strsplit(":", link))
            local itemSetIndex, alreadyExists = GetSetIndexByName(setName)
            local output = LOCATION_DATA_OUTPUT:format(gX, gY, itemSetIndex, zoneMapIndex, zoneId, tostring(closestPOI), setName)
            if(not alreadyExists) then
                output = output .. "\13" .. SET_DATA_OUTPUT:format(itemSetIndex, itemId, traits, setName)
            end
            StartChatInput(output)
            CraftingStations.Data[#CraftingStations.Data  + 1] = {gX, gY, itemSetIndex, zoneId, closestPOI}
        else
            d("[CraftingStations] Error: Could not convert coordinates to global")
        end
    end
end

SLASH_COMMANDS["/csinfo"] = function(command)
    if(command == "off") then
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_CRAFTING_STATION_INTERACT)
        d("[CraftingStations] Stop printing crafting station data to chat input on visit")
    else
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_CRAFTING_STATION_INTERACT, PrintItemSetData)
        d("[CraftingStations] Start printing crafting station data to chat input on visit")
    end
end
