NQOL = NQOL or {}
NQOL.Features = NQOL.Features or {}

local MapTravelTabs = {}

local EVENT_NAMESPACE = "NQOL_MapTravelTabs"
local TAB_MARKER = "nqolMapTravelType"
local DUNGEON_TAB = "dungeons"
local TRIAL_TAB = "trials"
local USES_RIGHT_SIDE_CONTENT = false

local initialized = false
local worldMapCallbackRegistered = false
local travelEventRegistered = false
local dungeonTab
local trialTab

local TravelTab = ZO_InitializingObject:Subclass()

local function GetTabLabel(mapFilter)
    return GetString("SI_MAPFILTER", mapFilter)
end

local function IsTravelNodeAvailable(nodeIndex)
    local known, _, _, _, _, _, _, _, linkedCollectibleIsLocked = GetFastTravelNodeInfo(nodeIndex)
    local isOutboundOnly = GetFastTravelNodeOutboundOnlyInfo and select(1, GetFastTravelNodeOutboundOnlyInfo(nodeIndex)) or false
    return known == true and linkedCollectibleIsLocked ~= true and isOutboundOnly ~= true
end

local function CanRecall()
    return not (IsInCampaign and IsInCampaign())
        and not (IsUnitDead and IsUnitDead("player"))
        and (not CanLeaveCurrentLocationViaTeleport or CanLeaveCurrentLocationViaTeleport())
end

local function ReleaseTravelDialogs()
    if not ZO_Dialogs_ReleaseDialog then
        return
    end

    ZO_Dialogs_ReleaseDialog("FAST_TRAVEL_CONFIRM")
    ZO_Dialogs_ReleaseDialog("RECALL_CONFIRM")
    ZO_Dialogs_ReleaseDialog("TRAVEL_TO_HOUSE_CONFIRM")
end

local function CompareDestinations(left, right)
    local leftName = NQOL.Util.Lower(left.name)
    local rightName = NQOL.Util.Lower(right.name)
    if leftName == rightName then
        return left.nodeIndex < right.nodeIndex
    end
    return leftName < rightName
end

local function GetDestinationDisplayName(nodeName)
    local prefixEnd = string.find(nodeName, ":", 1, true) or string.find(nodeName, "：", 1, true)
    if prefixEnd then
        nodeName = string.gsub(string.sub(nodeName, prefixEnd + 1), "^%s+", "")
    end
    return ZO_CachedStrFormat(SI_ZONE_NAME, nodeName)
end

function TravelTab:Initialize(control, zoneDisplayType, includeArenaSection)
    self.control = control
    self.zoneDisplayType = zoneDisplayType
    self.includeArenaSection = includeArenaSection == true
    self.fragment = ZO_SimpleSceneFragment:New(control)
    self.list = ZO_GamepadVerticalParametricScrollList:New(control:GetNamedChild("Main"):GetNamedChild("List"))
    self.list:AddDataTemplate(
        "ZO_GamepadMenuEntryTemplateLowercase42",
        ZO_SharedGamepadEntry_OnSetup,
        ZO_GamepadMenuEntryTemplateParametricListFunction
    )
    self.list:AddDataTemplateWithHeader(
        "ZO_GamepadMenuEntryTemplateLowercase42",
        ZO_SharedGamepadEntry_OnSetup,
        ZO_GamepadMenuEntryTemplateParametricListFunction,
        nil,
        "ZO_GamepadMenuEntryHeaderTemplate"
    )
    self.list:SetAlignToScreenCenter(true)
    self.list:SetOnTargetDataChangedCallback(function()
        KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)
    end)

    SCREEN_NARRATION_MANAGER:RegisterParametricList(self.list, {
        canNarrate = function()
            return self.fragment:IsShowing()
        end,
        headerNarrationFunction = function()
            return GAMEPAD_WORLD_MAP_INFO:GetHeaderNarration()
        end,
    })

    self:InitializeKeybindDescriptor()
    self.fragment:RegisterCallback("StateChange", function(_, newState)
        if newState == SCENE_SHOWING then
            self:RefreshList()
            self.list:Activate()
            self.list:RefreshVisible()
            KEYBIND_STRIP:AddKeybindButtonGroup(self.keybindStripDescriptor)
        elseif newState == SCENE_HIDDEN then
            KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindStripDescriptor)
            self.list:Deactivate()
        end
    end)
end

function TravelTab:GetFragment()
    return self.fragment
end

function TravelTab:GetSelectedData()
    return self.list:GetTargetData()
end

function TravelTab:CanTravelToSelected()
    local targetData = self:GetSelectedData()
    if not targetData or not IsTravelNodeAvailable(targetData.nodeIndex) then
        return false
    end

    return (ZO_Map_GetFastTravelNode and ZO_Map_GetFastTravelNode() ~= nil) or CanRecall()
end

function TravelTab:RequestTravel()
    if not self:CanTravelToSelected() or not ZO_Dialogs_ShowPlatformDialog then
        return
    end

    local targetData = self:GetSelectedData()
    local nodeIndex = targetData.nodeIndex
    local _, nodeName = GetFastTravelNodeInfo(nodeIndex)

    ReleaseTravelDialogs()
    if ZO_Map_GetFastTravelNode and ZO_Map_GetFastTravelNode() ~= nil then
        ZO_Dialogs_ShowPlatformDialog("FAST_TRAVEL_CONFIRM", { nodeIndex = nodeIndex }, { mainTextParams = { nodeName } })
        return
    end

    local _, premiumTimeLeft = GetRecallCooldown()
    if premiumTimeLeft == 0 then
        ZO_Dialogs_ShowPlatformDialog("RECALL_CONFIRM", { nodeIndex = nodeIndex }, { mainTextParams = { nodeName } })
    else
        ZO_Alert(
            UI_ALERT_CATEGORY_ERROR,
            SOUNDS.NEGATIVE_CLICK,
            zo_strformat(SI_FAST_TRAVEL_RECALL_COOLDOWN, nodeName, ZO_FormatTimeMilliseconds(premiumTimeLeft, TIME_FORMAT_STYLE_DESCRIPTIVE, TIME_FORMAT_PRECISION_SECONDS))
        )
    end
end

function TravelTab:InitializeKeybindDescriptor()
    self.keybindStripDescriptor = {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        {
            keybind = "UI_SHORTCUT_PRIMARY",
            name = GetString(SI_GAMEPAD_WORLD_MAP_INTERACT_TRAVEL),
            callback = function()
                self:RequestTravel()
            end,
            visible = function()
                return self:GetSelectedData() ~= nil
            end,
            enabled = function()
                return self:CanTravelToSelected()
            end,
        },
    }

    ZO_Gamepad_AddBackNavigationKeybindDescriptors(self.keybindStripDescriptor, GAME_NAVIGATION_TYPE_BUTTON, ZO_WorldMapInfo_OnBackPressed)
    ZO_Gamepad_AddListTriggerKeybindDescriptors(self.keybindStripDescriptor, self.list)
end

function TravelTab:BuildDestination(nodeIndex)
    local known, nodeName, _, _, icon, _, _, _, linkedCollectibleIsLocked = GetFastTravelNodeInfo(nodeIndex)
    if not nodeName or nodeName == "" then
        return nil
    end

    local isOutboundOnly = GetFastTravelNodeOutboundOnlyInfo and select(1, GetFastTravelNodeOutboundOnlyInfo(nodeIndex)) or false
    return {
        name = GetDestinationDisplayName(nodeName),
        nodeIndex = nodeIndex,
        icon = icon,
        available = known == true and linkedCollectibleIsLocked ~= true and isOutboundOnly ~= true,
    }
end

function TravelTab:AddDestinations(destinations, header)
    table.sort(destinations, CompareDestinations)
    for index, destination in ipairs(destinations) do
        local entryData = ZO_GamepadEntryData:New(destination.name, destination.icon)
        entryData.nodeIndex = destination.nodeIndex
        entryData:SetEnabled(destination.available)
        if index == 1 and header then
            entryData:SetHeader(header)
            self.list:AddEntry("ZO_GamepadMenuEntryTemplateLowercase42WithHeader", entryData)
        else
            self.list:AddEntry("ZO_GamepadMenuEntryTemplateLowercase42", entryData)
        end
    end
end

function TravelTab:RefreshList()
    local destinations = {}
    local arenas = {}
    for nodeIndex = 1, GetNumFastTravelNodes() do
        local zoneIndex, poiIndex = GetFastTravelNodePOIIndicies(nodeIndex)
        local mapFilterOverride = GetPOIMapFilterOverride(zoneIndex, poiIndex)
        local zoneDisplayType = GetFastTravelNodeZoneDisplayType(nodeIndex)
        local isInfiniteArchive = zoneDisplayType == ZONE_DISPLAY_TYPE_ENDLESS_DUNGEON
        if self.includeArenaSection and mapFilterOverride == MAP_FILTER_ARENAS and not isInfiniteArchive then
            local destination = self:BuildDestination(nodeIndex)
            if destination then
                arenas[#arenas + 1] = destination
            end
        elseif zoneDisplayType == self.zoneDisplayType or (self.includeArenaSection and isInfiniteArchive) then
            local destination = self:BuildDestination(nodeIndex)
            if destination then
                destinations[#destinations + 1] = destination
            end
        end
    end

    self.list:Clear()
    if self.includeArenaSection then
        self:AddDestinations(destinations, GetTabLabel(MAP_FILTER_DUNGEONS))
        self:AddDestinations(arenas, GetTabLabel(MAP_FILTER_ARENAS))
    else
        self:AddDestinations(destinations)
    end
    self.list:Commit()
end

local function FindLocationsTabIndex(tabBarEntries)
    local locationsLabel = GetString(SI_MAP_INFO_MODE_LOCATIONS)
    for index, tabData in ipairs(tabBarEntries) do
        if tabData.text == locationsLabel then
            return index
        end
    end
    return nil
end

local function HasTab(tabBarEntries, tabType)
    for _, tabData in ipairs(tabBarEntries) do
        if tabData[TAB_MARKER] == tabType then
            return true
        end
    end
    return false
end

local function IsTabVisible(tabData)
    local visible = tabData.visible
    if type(visible) == "function" then
        visible = visible()
    end
    return visible ~= false
end

local function FindVisibleTabIndex(tabBarEntries, tabType)
    local visibleIndex = 0
    local locationsLabel = GetString(SI_MAP_INFO_MODE_LOCATIONS)
    for _, tabData in ipairs(tabBarEntries) do
        if IsTabVisible(tabData) then
            visibleIndex = visibleIndex + 1
            if (tabType and tabData[TAB_MARKER] == tabType) or (not tabType and tabData.text == locationsLabel) then
                return visibleIndex
            end
        end
    end
    return nil
end

local function GetActiveCustomTab(mapInfo)
    if dungeonTab and mapInfo.fragment == dungeonTab:GetFragment() then
        return DUNGEON_TAB
    end
    if trialTab and mapInfo.fragment == trialTab:GetFragment() then
        return TRIAL_TAB
    end
    return nil
end

local function SyncTabs()
    local mapInfo = GAMEPAD_WORLD_MAP_INFO
    if not mapInfo or not mapInfo.tabBarEntries or not mapInfo.header then
        return false
    end

    local showDungeons = NQOL.Features.Map.GetShowDungeons()
    local showTrials = NQOL.Features.Map.GetShowTrials()
    local activeCustomTab = GetActiveCustomTab(mapInfo)
    local changed = false

    for index = #mapInfo.tabBarEntries, 1, -1 do
        local tabType = mapInfo.tabBarEntries[index][TAB_MARKER]
        if (tabType == DUNGEON_TAB and not showDungeons) or (tabType == TRIAL_TAB and not showTrials) then
            table.remove(mapInfo.tabBarEntries, index)
            changed = true
        end
    end

    local locationsIndex = FindLocationsTabIndex(mapInfo.tabBarEntries)
    if (showDungeons or showTrials) and not locationsIndex then
        return false
    end

    if showDungeons and not HasTab(mapInfo.tabBarEntries, DUNGEON_TAB) then
        dungeonTab = dungeonTab or TravelTab:New(NQOLWorldMapDungeons, ZONE_DISPLAY_TYPE_DUNGEON, true)
        table.insert(mapInfo.tabBarEntries, locationsIndex + 1, {
            text = GetTabLabel(MAP_FILTER_DUNGEONS),
            [TAB_MARKER] = DUNGEON_TAB,
            callback = function()
                mapInfo:SwitchToFragment(dungeonTab:GetFragment(), USES_RIGHT_SIDE_CONTENT)
            end,
        })
        changed = true
    end

    if showTrials and not HasTab(mapInfo.tabBarEntries, TRIAL_TAB) then
        trialTab = trialTab or TravelTab:New(NQOLWorldMapTrials, ZONE_DISPLAY_TYPE_RAID)
        local trialIndex = locationsIndex + (showDungeons and 2 or 1)
        table.insert(mapInfo.tabBarEntries, trialIndex, {
            text = GetTabLabel(MAP_FILTER_TRIALS),
            [TAB_MARKER] = TRIAL_TAB,
            callback = function()
                mapInfo:SwitchToFragment(trialTab:GetFragment(), USES_RIGHT_SIDE_CONTENT)
            end,
        })
        changed = true
    end

    if changed then
        ZO_GamepadGenericHeader_Refresh(mapInfo.header, mapInfo.baseHeaderData)
        if activeCustomTab then
            local keepActiveTab = (activeCustomTab == DUNGEON_TAB and showDungeons)
                or (activeCustomTab == TRIAL_TAB and showTrials)
            local activeIndex = FindVisibleTabIndex(mapInfo.tabBarEntries, keepActiveTab and activeCustomTab or nil)
            if activeIndex then
                ZO_GamepadGenericHeader_SetActiveTabIndex(mapInfo.header, activeIndex)
            end
        end
    end

    return true
end

local function OnWorldMapInfoShowing()
    MapTravelTabs.RefreshTabs()
end

local function OnFastTravelNetworkUpdated()
    if dungeonTab and dungeonTab:GetFragment():IsShowing() then
        dungeonTab:RefreshList()
    elseif trialTab and trialTab:GetFragment():IsShowing() then
        trialTab:RefreshList()
    end
end

local function SetRuntimeCallbacksEnabled(enabled)
    if enabled and not worldMapCallbackRegistered then
        CALLBACK_MANAGER:RegisterCallback("WorldMapInfo_Gamepad_Showing", OnWorldMapInfoShowing)
        worldMapCallbackRegistered = true
    elseif not enabled and worldMapCallbackRegistered then
        CALLBACK_MANAGER:UnregisterCallback("WorldMapInfo_Gamepad_Showing", OnWorldMapInfoShowing)
        worldMapCallbackRegistered = false
    end

    if enabled and not travelEventRegistered then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_FAST_TRAVEL_NETWORK_UPDATED, OnFastTravelNetworkUpdated)
        travelEventRegistered = true
    elseif not enabled and travelEventRegistered then
        EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_FAST_TRAVEL_NETWORK_UPDATED)
        travelEventRegistered = false
    end
end

function MapTravelTabs.RefreshTabs()
    if not initialized then
        return
    end

    local enabled = NQOL.Features.Map.GetShowDungeons() or NQOL.Features.Map.GetShowTrials()
    if enabled then
        SetRuntimeCallbacksEnabled(true)
        SyncTabs()
    else
        SyncTabs()
        SetRuntimeCallbacksEnabled(false)
    end
end

function MapTravelTabs.Initialize()
    if initialized then
        return
    end

    initialized = true
    MapTravelTabs.RefreshTabs()
end

NQOL.Features.MapTravelTabs = MapTravelTabs
