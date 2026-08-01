local ADDON_NAME = "GuildHallList"
GuildHallList = {}

local nextEventHandleIndex = 1

local function RegisterForEvent(event, callback)
    local eventHandleName = ADDON_NAME .. nextEventHandleIndex
    EVENT_MANAGER:RegisterForEvent(eventHandleName, event, callback)
    nextEventHandleIndex = nextEventHandleIndex + 1
    return eventHandleName
end

local function UnregisterForEvent(event, name)
    EVENT_MANAGER:UnregisterForEvent(name, event)
end

local function WrapFunction(object, functionName, wrapper)
    if(type(object) == "string") then
        wrapper = functionName
        functionName = object
        object = _G
    end
    local originalFunction = object[functionName]
    object[functionName] = function(...) return wrapper(originalFunction, ...) end
end

local function OnAddonLoaded(callback)
    local eventHandle = ""
    eventHandle = RegisterForEvent(EVENT_ADD_ON_LOADED, function(event, name)
        if(name ~= ADDON_NAME) then return end
        callback()
        UnregisterForEvent(event, name)
    end)
end

OnAddonLoaded(function()
    local GUILD_HALL_ICON = "EsoUI/Art/Journal/leaderboard_tabicon_home_down.dds"
    local CRAFTING_WORKSHOP_ICON = "EsoUI/Art/Inventory/inventory_tabicon_crafting_down.dds"
    local GUILD_HALL_MARKER_STRING = "<GH"
    local GUILD_HALL_MARKER_PATTERN = "<GH(%d*)"
    local CRAFTING_WORKSHOP_MARKER_STRING = "<CW"
    local CRAFTING_WORKSHOP_MARKER_PATTERN = "<CW(%d*)"
    local GUILD_HALL_DATA = 1
    local CRAFTING_WORKSHOP_DATA = 2

    local guildRosterManager = GUILD_ROSTER_MANAGER
    local ownName = GetDisplayName()
    local guildHalls = {}
    local craftingWorkshops = {}
    GuildHallList.guildHalls = guildHalls
    GuildHallList.craftingWorkshops = craftingWorkshops

    local container = GuildHallListContainer
    container:SetParent(ZO_GuildHome)

    local list = ZO_SortFilterList:New(container)
    list:SetEmptyText("none")
    list.emptyRow:GetNamedChild("BG"):SetHidden(true)

    local function ClearCallLater(id)
        EVENT_MANAGER:UnregisterForUpdate("CallLaterFunction"..id)
    end

    local refreshListHandle
    local function DoRefreshList()
        list:RefreshData()
    end

    local function RefreshList()
        if(refreshListHandle) then
            ClearCallLater(refreshListHandle)
        end
        refreshListHandle = zo_callLater(DoRefreshList, 250)
    end

    local function GetHouseId(note, marker, pattern)
        if(PlainStringFind(note, marker)) then
            -- TODO: check if this performs better than string.find
            local id = string.match(note, pattern)
            id = tonumber(id)
            if(not id) then id = true end -- if no id is specified we use true as indicator for the primary home
            return id
        end
        return nil
    end

    local function GetMarkers(note)
        if(note == "") then return nil, nil end
        local guildHall = GetHouseId(note, GUILD_HALL_MARKER_STRING, GUILD_HALL_MARKER_PATTERN)
        local craftingWorkshop = GetHouseId(note, CRAFTING_WORKSHOP_MARKER_STRING, CRAFTING_WORKSHOP_MARKER_PATTERN)
        return guildHall, craftingWorkshop
    end

    local function UpdateList(list, displayName, houseId)
        if(list[displayName] ~= houseId) then
            list[displayName] = houseId
            return true
        end
        return false
    end

    local function UpdateGuildHallList(displayName, note)
        local guildHall, workshop = GetMarkers(note)
        local guildHallChanged = UpdateList(guildHalls, displayName, guildHall)
        local workshopChanged = UpdateList(craftingWorkshops, displayName, workshop)
        if(guildHallChanged or workshopChanged) then
            RefreshList()
        end
    end

    local lastScannedId
    local function ScanAllNotesForGuildHallMarker()
        local guildId = guildRosterManager.guildId
        if(guildId == lastScannedId) then return end
        ZO_ClearTable(guildHalls)
        ZO_ClearTable(craftingWorkshops)
        for j = 1, GetNumGuildMembers(guildId) do
            local displayName, note = GetGuildMemberInfo(guildId, j)
            UpdateGuildHallList(displayName, note)
        end
        DoRefreshList()
        lastScannedId = guildId
    end

    RegisterForEvent(EVENT_GUILD_MEMBER_NOTE_CHANGED, function(_, guildId, displayName, note)
        UpdateGuildHallList(displayName, note)
    end)

    GUILD_HOME_SCENE:RegisterCallback("StateChange", ScanAllNotesForGuildHallMarker)
    ZO_PreHook(guildRosterManager, "OnGuildIdChanged", ScanAllNotesForGuildHallMarker)

    local function HandleJumpToHouse(data)
        if(data.name == ownName) then
            local houseId = data.houseId
            if(data.houseId == true) then
                houseId = GetHousingPrimaryHouse()
            end

            RequestJumpToHouse(houseId)
            local houseName = GetCollectibleNickname(GetCollectibleIdForHouse(houseId))
            df("[GuildHallList] Requested jump to %s", houseName)
        else
            if(data.houseId == true) then
                JumpToHouse(data.name)
                df("[GuildHallList] Requested jump to the primary home of %s", data.name)
            else
                JumpToSpecificHouse(data.name, data.houseId)
                df("[GuildHallList] Requested jump to the %s of %s", GetZoneNameById(GetHouseZoneId(data.houseId)), data.name)
            end
        end
    end

    local function SetupRow(control, data, texture)
        list:SetupRow(control, data)
        control:SetText(data.name)
        control:GetNamedChild("Button"):SetHandler("OnMouseUp", function(control, button, isInside, ctrl, alt, shift, command)
            if(isInside and button == MOUSE_BUTTON_INDEX_LEFT) then
                HandleJumpToHouse(data)
            end
        end)
        control:GetNamedChild("Icon"):SetTexture(texture)
    end
    ZO_ScrollList_AddDataType(list.list, GUILD_HALL_DATA, "GuildHallListContainerRowTemplate", 30, function(control, data)
        SetupRow(control, data, GUILD_HALL_ICON)
    end)
    ZO_ScrollList_AddDataType(list.list, CRAFTING_WORKSHOP_DATA, "GuildHallListContainerRowTemplate", 30, function(control, data)
        SetupRow(control, data, CRAFTING_WORKSHOP_ICON)
    end)
    ZO_ScrollList_EnableHighlight(list.list, "ZO_ThinListHighlight")

    local function CreateListEntry(type, name, houseId)
        return ZO_ScrollList_CreateDataEntry(type, {
            name = name,
            houseId = houseId
        })
    end

    function list:FilterScrollList()
        local scrollData = ZO_ScrollList_GetDataList(self.list)
        ZO_ClearNumericallyIndexedTable(scrollData)

        for displayName, houseId in pairs(guildHalls) do
            table.insert(scrollData, CreateListEntry(GUILD_HALL_DATA, displayName, houseId))
        end

        for displayName, houseId in pairs(craftingWorkshops) do
            table.insert(scrollData, CreateListEntry(CRAFTING_WORKSHOP_DATA, displayName, houseId))
        end
    end

    local function SortByTypeAndNameAsc(listEntry1, listEntry2)
        if(listEntry1.type == listEntry2.type) then
            return listEntry1.data.name < listEntry2.data.name
        end
        return listEntry1.type < listEntry2.type
    end

    function list:SortScrollList()
        local scrollData = ZO_ScrollList_GetDataList(self.list)
        table.sort(scrollData, SortByTypeAndNameAsc)
    end

    local function CreateMarker(guildIndex, marker)
        local houseId = GetCurrentZoneHouseId()
        if(houseId == 0) then
            df("[GuildHallList] You need to be inside a house in order to mark it")
            return
        end

        guildIndex = tonumber(guildIndex) or 1
        local guildId = GetGuildId(guildIndex)
        local displayName = GetCurrentHouseOwner()
        local memberIndex = GetGuildMemberIndexFromDisplayName(guildId, displayName)

        if(not memberIndex) then
            df("[GuildHallList] Could not find %s in %s", displayName, GetGuildName(guildId))
            return
        end

        local _, note = GetGuildMemberInfo(guildId, memberIndex)

        ZO_Dialogs_ShowDialog("EDIT_NOTE", {
            displayName = displayName,
            note = string.format("%s\n%s%d", note, marker, houseId),
            changedCallback = GUILD_ROSTER_MANAGER:GetNoteEditedFunction()
        })
    end

    SLASH_COMMANDS["/markguildhall"] = function(guildIndex)
        CreateMarker(guildIndex, GUILD_HALL_MARKER_STRING)
    end

    SLASH_COMMANDS["/markworkshop"] = function(guildIndex)
        CreateMarker(guildIndex, CRAFTING_WORKSHOP_MARKER_STRING)
    end
end)
