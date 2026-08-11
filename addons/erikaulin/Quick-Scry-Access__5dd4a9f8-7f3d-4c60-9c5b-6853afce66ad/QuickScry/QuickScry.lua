QuickScry = QuickScry or {}

local ADDON_NAME = "QuickScry"
local DEBUG_ENABLED = true

local MAPTYPE_ZONE_VALUE = MAPTYPE_ZONE
local MAPTYPE_SUBZONE_VALUE = MAPTYPE_SUBZONE
local MAPTYPE_WORLD_VALUE = MAPTYPE_WORLD
local MAPTYPE_COSMIC_VALUE = MAPTYPE_COSMIC

local SUCCESS = ANTIQUITY_SCRYING_RESULT_SUCCESS

local function IsSupportedMapType(mapType)
    return mapType == MAPTYPE_ZONE_VALUE or mapType == MAPTYPE_SUBZONE_VALUE
end

local function GetMapTypeReason(mapType)
    if mapType == MAPTYPE_WORLD_VALUE or mapType == MAPTYPE_COSMIC_VALUE then
        return "Select a zone map"
    end

    return "Unsupported map type"
end

function QuickScry:CreateDebugControl()
    if not DEBUG_ENABLED or self.debugControl or not WINDOW_MANAGER or not GuiRoot then
        return
    end

    local control = WINDOW_MANAGER:CreateControl("QuickScryDebug", GuiRoot, CT_LABEL)
    control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 80, 80)
    control:SetDimensions(900, 50)
    control:SetFont("ZoFontGamepad34")
    control:SetColor(1, 1, 1, 1)
    control:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    control:SetVerticalAlignment(TEXT_ALIGN_TOP)
    control:SetHidden(true)

    self.debugControl = control
end

function QuickScry:UpdateDebugControl()
    if not self.debugControl or not self.state then
        return
    end

    local state = self.state
    local mapName = state.zoneName ~= "" and state.zoneName or "none"
    local status = state.enabled and "enabled" or "disabled"
    local count = tostring(#state.antiquityIds)

    self.debugControl:SetText("Quick Scry | Map: " .. mapName .. " | Matches: " .. count .. " | " .. status .. " | " .. state.reason)
end

function QuickScry:GetMapOptionText()
    if self.state and not self.state.enabled then
        return "Scry Current Map (disabled)"
    end

    return "Scry Current Map"
end

function QuickScry:SetDebugVisible(visible)
    if self.debugControl then
        self.debugControl:SetHidden(not visible)
    end
end

function QuickScry:EvaluateDisplayedMap()
    local state =
    {
        zoneIndex = 0,
        zoneId = 0,
        zoneName = "",
        antiquityIds = {},
        enabled = false,
        reason = "Not evaluated",
    }

    if type(GetCurrentMapZoneIndex) ~= "function" or type(GetMapType) ~= "function" then
        state.reason = "Map API unavailable"
        return state
    end

    local mapType = GetMapType()
    if not IsSupportedMapType(mapType) then
        state.reason = GetMapTypeReason(mapType)
        return state
    end

    local zoneIndex = GetCurrentMapZoneIndex()
    if not zoneIndex or zoneIndex <= 0 or type(GetZoneId) ~= "function" then
        state.reason = "No displayed zone"
        return state
    end

    local zoneId = GetZoneId(zoneIndex)
    if not zoneId or zoneId <= 0 then
        state.reason = "No displayed zone"
        return state
    end

    state.zoneIndex = zoneIndex
    state.zoneId = zoneId

    if type(GetZoneNameByIndex) == "function" then
        state.zoneName = GetZoneNameByIndex(zoneIndex) or ""
    end

    if type(GetMapFloorInfo) == "function" then
        local _, numFloors = GetMapFloorInfo()
        if numFloors and numFloors > 0 then
            state.reason = "Unsupported map level"
            return state
        end
    end

    if type(GetNextAntiquityId) ~= "function" or type(MeetsAntiquityRequirementsForScrying) ~= "function" or not SUCCESS then
        state.reason = "Antiquity API unavailable"
        return state
    end

    local antiquityId = GetNextAntiquityId()
    while antiquityId do
        local scryingResult = MeetsAntiquityRequirementsForScrying(antiquityId, zoneId)
        if scryingResult == SUCCESS then
            table.insert(state.antiquityIds, antiquityId)
        end

        antiquityId = GetNextAntiquityId(antiquityId)
    end

    state.enabled = #state.antiquityIds > 0
    if state.enabled then
        state.reason = "Ready"
    else
        state.reason = "No scryable antiquities"
    end

    return state
end

function QuickScry:RefreshState()
    self.state = self:EvaluateDisplayedMap()
    self:UpdateDebugControl()

    self:RefreshMapOptionsHeader()
end

function QuickScry:RefreshMapOptionsHeader()
    local mapInfo = GAMEPAD_WORLD_MAP_INFO
    if not mapInfo or not mapInfo.header or not mapInfo.baseHeaderData or not ZO_GamepadGenericHeader_Refresh then
        return
    end

    if GAMEPAD_WORLD_MAP_INFO_FRAGMENT and not GAMEPAD_WORLD_MAP_INFO_FRAGMENT:IsShowing() then
        return
    end

    -- Refresh without replaying the currently selected tab callback.
    ZO_GamepadGenericHeader_Refresh(mapInfo.header, mapInfo.baseHeaderData, true)
end

function QuickScry:InstallMapOption()
    if self.optionEntry then
        return
    end

    local mapInfo = GAMEPAD_WORLD_MAP_INFO
    if not mapInfo or not mapInfo.tabBarEntries then
        return
    end

    self.optionEntry =
    {
        text = function()
            return QuickScry:GetMapOptionText()
        end,
        -- The native tab bar has no selectable-but-disabled state. Keep this
        -- entry focusable so the POC can expose its disabled reason in the
        -- debug label instead of silently hiding the action.
        canSelect = true,
        visible = function()
            return true
        end,
        callback = function()
            if QuickScry.state and QuickScry.state.enabled then
                QuickScry:OpenNativeAntiquitiesList()
            end
        end,
    }

    table.insert(mapInfo.tabBarEntries, self.optionEntry)
end

function QuickScry:OpenNativeAntiquitiesList()
    -- Re-evaluate without rebuilding the header from inside its tab callback.
    self.state = self:EvaluateDisplayedMap()
    self:UpdateDebugControl()
    if not self.state.enabled then
        return
    end

    local mapInfo = GAMEPAD_WORLD_MAP_INFO
    local mapAntiquities = WORLD_MAP_ANTIQUITIES_GAMEPAD
    if not mapInfo or not mapInfo.SwitchToFragment or not mapAntiquities or not mapAntiquities.GetFragment then
        self.state.enabled = false
        self.state.reason = "Native map Antiquities list unavailable"
        if self.optionEntry then
            self.optionEntry.text = function()
                return QuickScry:GetMapOptionText()
            end
        end
        self:UpdateDebugControl()
        return
    end

    -- The native map Antiquities fragment already filters against the map's
    -- displayed zone and owns the standard gamepad list and Scry action.
    mapInfo:SwitchToFragment(mapAntiquities:GetFragment(), false)
end

function QuickScry:OnMapOptionsShowing()
    self:InstallMapOption()
    self:RefreshState()
    self:SetDebugVisible(true)
end

function QuickScry:OnMapOptionsHidden()
    self:SetDebugVisible(false)
end

function QuickScry:RegisterRefreshEvents()
    CALLBACK_MANAGER:RegisterCallback("WorldMapInfo_Gamepad_Showing", function()
        QuickScry:OnMapOptionsShowing()
    end)

    CALLBACK_MANAGER:RegisterCallback("WorldMapInfo_Gamepad_Hidden", function()
        QuickScry:OnMapOptionsHidden()
    end)

    CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", function()
        QuickScry:RefreshState()
    end)

    if EVENT_PLAYER_ACTIVATED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_PlayerActivated", EVENT_PLAYER_ACTIVATED, function()
            QuickScry:RefreshState()
        end)
    end

    local antiquityEvents =
    {
        EVENT_ANTIQUITIES_UPDATED,
        EVENT_ANTIQUITY_UPDATED,
        EVENT_ANTIQUITY_LEAD_ACQUIRED,
        EVENT_ANTIQUITY_DIG_SITES_UPDATED,
    }

    for index, eventCode in ipairs(antiquityEvents) do
        if eventCode then
            EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_Antiquity_" .. tostring(index), eventCode, function()
                QuickScry:RefreshState()
            end)
        end
    end
end

function QuickScry:Initialize()
    self:CreateDebugControl()
    self:RegisterRefreshEvents()
    self:RefreshState()
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    QuickScry:Initialize()
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
