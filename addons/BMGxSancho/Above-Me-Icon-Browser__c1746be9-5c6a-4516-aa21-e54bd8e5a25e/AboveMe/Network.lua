AboveMe = AboveMe or {}
local AM = AboveMe

local MESSAGE_ID_ICON_SELECTION = 236
local EVENT_PREFIX = "AboveMeNetwork"

AM.remoteSelections = AM.remoteSelections or {}
AM.networkProtocol = nil

local function IsGrouped()
    return IsUnitGrouped("player")
end

local function GetCurrentGroupAccounts()
    local accounts = {}
    if not IsGrouped() then return accounts end

    for i = 1, 12 do
        local unitTag = "group" .. i
        if DoesUnitExist(unitTag) and IsUnitPlayer(unitTag) then
            local displayName = GetUnitDisplayName(unitTag)
            if displayName and displayName ~= "" then
                accounts[displayName] = true
            end
        end
    end

    return accounts
end

function AM:PruneRemoteSelections()
    if not IsGrouped() then
        ZO_ClearTable(self.remoteSelections)
        return
    end

    local currentAccounts = GetCurrentGroupAccounts()
    for displayName in pairs(self.remoteSelections) do
        if not currentAccounts[displayName] then
            self.remoteSelections[displayName] = nil
        end
    end
end

function AM:BroadcastSelection()
    if not self.networkProtocol or not self.saved or not IsGrouped() then return false end

    local iconId = tonumber(self.saved.iconId) or 101
    if not self.ICONS_BY_ID[iconId] then iconId = 101 end

    return self.networkProtocol:Send({ iconId = iconId }) == true
end

function AM:ScheduleSelectionBroadcast(delayMs)
    zo_callLater(function()
        if AM and AM.saved then AM:BroadcastSelection() end
    end, delayMs or 500)
end

local function OnSelectionReceived(unitTag, data)
    if not unitTag or not DoesUnitExist(unitTag) or not IsUnitPlayer(unitTag) then return end
    if AreUnitsEqual("player", unitTag) then return end

    local displayName = GetUnitDisplayName(unitTag)
    if not displayName or displayName == "" then return end

    local iconId = tonumber(data and data.iconId) or 0
    if not AM.ICONS_BY_ID[iconId] then return end

    AM.remoteSelections[displayName] = iconId
end

local function OnGroupChanged()
    AM:PruneRemoteSelections()
    AM:ScheduleSelectionBroadcast(750)
end

function AM:InitializeNetwork()
    if not LibGroupBroadcast then return end

    local handler = LibGroupBroadcast:RegisterHandler("AboveMeIconSelection", self.name)
    if not handler then return end

    handler:SetDisplayName("Above Me")
    handler:SetDescription("Shares each player's selected Above Me icon with group members.")

    local protocol = handler:DeclareProtocol(MESSAGE_ID_ICON_SELECTION, "Icon Selection")
    protocol:AddField(LibGroupBroadcast.CreateNumericField("iconId", {
        minValue = 1,
        maxValue = 1023,
        defaultValue = 101,
        trimValues = true,
    }))
    protocol:OnData(OnSelectionReceived)
    protocol:Finalize({ isRelevantInCombat = true })

    self.networkProtocol = protocol

    EVENT_MANAGER:RegisterForEvent(EVENT_PREFIX, EVENT_PLAYER_ACTIVATED, function()
        AM:PruneRemoteSelections()
        AM:ScheduleSelectionBroadcast(1000)
    end)
    EVENT_MANAGER:RegisterForEvent(EVENT_PREFIX, EVENT_GROUP_MEMBER_JOINED, OnGroupChanged)
    EVENT_MANAGER:RegisterForEvent(EVENT_PREFIX, EVENT_GROUP_MEMBER_LEFT, OnGroupChanged)
    EVENT_MANAGER:RegisterForEvent(EVENT_PREFIX, EVENT_GROUP_MEMBER_CONNECTED_STATUS, OnGroupChanged)

    self:ScheduleSelectionBroadcast(1000)
end
