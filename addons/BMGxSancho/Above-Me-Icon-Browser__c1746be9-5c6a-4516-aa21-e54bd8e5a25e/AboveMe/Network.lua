AboveMe = AboveMe or {}
local AM = AboveMe

local MESSAGE_ID_ICON_SELECTION_LEGACY = 236
local MESSAGE_ID_ICON_PROFILE = 237
local EVENT_PREFIX = "AboveMeNetwork"

local OFFSET_MIN = -0.75
local OFFSET_STEP = 0.05
local OFFSET_STEPS_MAX = 25

AM.remoteSelections = AM.remoteSelections or {}
AM.networkProtocol = nil
AM.legacyNetworkProtocol = nil
AM.broadcastGeneration = 0
AM.lastBroadcastSignature = nil

local function IsGrouped()
    return IsUnitGrouped("player")
end

local function EncodeOffset(offset)
    local steps = zo_round(((tonumber(offset) or 0) - OFFSET_MIN) / OFFSET_STEP)
    return zo_clamp(steps, 0, OFFSET_STEPS_MAX)
end

local function DecodeOffset(steps)
    steps = zo_clamp(tonumber(steps) or 15, 0, OFFSET_STEPS_MAX)
    return OFFSET_MIN + (steps * OFFSET_STEP)
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
            if self.renderControls and self.renderControls[displayName] then
                self.renderControls[displayName]:SetHidden(true)
            end
            if self.renderStates then
                self.renderStates[displayName] = nil
            end
        end
    end
end

function AM:BroadcastSelection(force)
    if not self.saved or not IsGrouped() then return false end

    local iconId = tonumber(self.saved.iconId) or 101
    if not self.ICONS_BY_ID[iconId] then iconId = 101 end

    local offsetSteps = EncodeOffset(self:GetPlacementOffset())
    local revision = self.characterSaved and (tonumber(self.characterSaved.placementRevision) or 1) or 1
    local signature = string.format("%d:%d:%d", iconId, offsetSteps, revision)

    if not force and signature == self.lastBroadcastSignature then
        return true
    end

    local sent = false
    if self.networkProtocol then
        sent = self.networkProtocol:Send({
            iconId = iconId,
            offsetSteps = offsetSteps,
            revision = revision,
        }) == true
    end

    -- Keep legacy clients able to see the selected icon during the development
    -- transition. Placement metadata is intentionally available only to clients
    -- using the new compact profile protocol.
    if self.legacyNetworkProtocol then
        self.legacyNetworkProtocol:Send({ iconId = iconId })
    end

    if sent then
        self.lastBroadcastSignature = signature
    end

    return sent
end

function AM:ScheduleSelectionBroadcast(delayMs, force)
    self.broadcastGeneration = (self.broadcastGeneration or 0) + 1
    local generation = self.broadcastGeneration

    zo_callLater(function()
        if not AM or generation ~= AM.broadcastGeneration or not AM.saved then return end
        AM:BroadcastSelection(force == true)
    end, delayMs or 500)
end

local function StoreRemoteSelection(unitTag, iconId, offset, revision)
    if not unitTag or not DoesUnitExist(unitTag) or not IsUnitPlayer(unitTag) then return end
    if AreUnitsEqual("player", unitTag) then return end

    local displayName = GetUnitDisplayName(unitTag)
    if not displayName or displayName == "" then return end

    iconId = tonumber(iconId) or 0
    if not AM.ICONS_BY_ID[iconId] then return end

    local previous = AM.remoteSelections[displayName]
    local incomingRevision = tonumber(revision) or 0
    if type(previous) == "table" and incomingRevision > 0 and tonumber(previous.revision or 0) > incomingRevision then
        return
    end

    AM.remoteSelections[displayName] = {
        iconId = iconId,
        placementOffset = zo_clamp(tonumber(offset) or 0, OFFSET_MIN, 0.50),
        revision = incomingRevision,
        receivedAt = GetGameTimeMilliseconds(),
    }
end

local function OnLegacySelectionReceived(unitTag, data)
    StoreRemoteSelection(unitTag, data and data.iconId, 0, 0)
end

local function OnProfileReceived(unitTag, data)
    StoreRemoteSelection(
        unitTag,
        data and data.iconId,
        DecodeOffset(data and data.offsetSteps),
        data and data.revision
    )
end

local function OnGroupChanged()
    AM:PruneRemoteSelections()
    AM:ScheduleSelectionBroadcast(600, true)
end

function AM:InitializeNetwork()
    if not LibGroupBroadcast then return end

    local handler = LibGroupBroadcast:RegisterHandler("AboveMeIconProfile", self.name)
    if not handler then return end

    handler:SetDisplayName("Above Me")
    handler:SetDescription("Shares each player's selected Above Me icon and calibrated placement with group members.")

    local legacyProtocol = handler:DeclareProtocol(MESSAGE_ID_ICON_SELECTION_LEGACY, "Legacy Icon Selection")
    legacyProtocol:AddField(LibGroupBroadcast.CreateNumericField("iconId", {
        minValue = 1,
        maxValue = 1023,
        defaultValue = 101,
        trimValues = true,
    }))
    legacyProtocol:OnData(OnLegacySelectionReceived)
    legacyProtocol:Finalize({ isRelevantInCombat = true })

    local protocol = handler:DeclareProtocol(MESSAGE_ID_ICON_PROFILE, "Icon Profile")
    protocol:AddField(LibGroupBroadcast.CreateNumericField("iconId", {
        minValue = 1,
        maxValue = 1023,
        defaultValue = 101,
        trimValues = true,
    }))
    protocol:AddField(LibGroupBroadcast.CreateNumericField("offsetSteps", {
        minValue = 0,
        maxValue = OFFSET_STEPS_MAX,
        defaultValue = 15,
        trimValues = true,
    }))
    protocol:AddField(LibGroupBroadcast.CreateNumericField("revision", {
        minValue = 0,
        maxValue = 255,
        defaultValue = 1,
        trimValues = true,
    }))
    protocol:OnData(OnProfileReceived)
    protocol:Finalize({ isRelevantInCombat = true })

    self.legacyNetworkProtocol = legacyProtocol
    self.networkProtocol = protocol

    EVENT_MANAGER:RegisterForEvent(EVENT_PREFIX, EVENT_PLAYER_ACTIVATED, function()
        AM.lastBroadcastSignature = nil
        AM:PruneRemoteSelections()
        AM:ScheduleSelectionBroadcast(900, true)
    end)
    EVENT_MANAGER:RegisterForEvent(EVENT_PREFIX, EVENT_GROUP_MEMBER_JOINED, OnGroupChanged)
    EVENT_MANAGER:RegisterForEvent(EVENT_PREFIX, EVENT_GROUP_MEMBER_LEFT, OnGroupChanged)
    EVENT_MANAGER:RegisterForEvent(EVENT_PREFIX, EVENT_GROUP_MEMBER_CONNECTED_STATUS, OnGroupChanged)

    self:ScheduleSelectionBroadcast(900, true)
end
