local C = Conductor
local SRC = SupportRotationCallouts
C.LiveSession = C.LiveSession or {}
local Live = C.LiveSession

local function NowMs()
    return GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
end

local function Normalize(name)
    return SRC.NormalizeAccountName and SRC:NormalizeAccountName(name or "") or tostring(name or "")
end

local function AddRosterUnit(roster, unitTag)
    if not unitTag or not DoesUnitExist(unitTag) then return end
    local account = Normalize(GetUnitDisplayName(unitTag))
    if account == "" or account == "@" then return end
    roster[account] = unitTag
end

function Live:BuildRoster()
    local roster = {}
    AddRosterUnit(roster, "player")
    local size = GetGroupSize and tonumber(GetGroupSize()) or 0
    for index = 1, size do AddRosterUnit(roster, GetGroupUnitTagByIndex(index)) end
    return roster
end

function Live:BuildFingerprint(roster)
    local accounts = {}
    for account in pairs(roster or {}) do accounts[#accounts + 1] = account end
    table.sort(accounts)
    return table.concat(accounts, "|")
end

function Live:IsAccountPresent(accountName)
    local account = Normalize(accountName)
    return account ~= "" and account ~= "@" and self.roster and self.roster[account] ~= nil
end

function Live:GetUnitTag(accountName)
    local account = Normalize(accountName)
    local tag = self.roster and self.roster[account]
    if tag and DoesUnitExist(tag) then return tag end
    return nil
end

function Live:GetGeneration() return tonumber(self.generation) or 0 end
function Live:GetFingerprint() return tostring(self.fingerprint or "") end

function Live:IsContextCurrent(generation, fingerprint)
    return tonumber(generation) == self:GetGeneration()
        and tostring(fingerprint or "") == self:GetFingerprint()
end

function Live:ResolveAccount(accountName, responsibilityKey)
    local account = Normalize(accountName)
    if account == "" or account == "@" then return nil, "UNASSIGNED" end
    if not self:IsAccountPresent(account) then
        self.invalidAssignments = self.invalidAssignments or {}
        local key = account .. "|" .. tostring(responsibilityKey or "") .. "|" .. tostring(self:GetGeneration())
        if not self.invalidAssignments[key] then
            self.invalidAssignments[key] = true
            if SRC.Diagnostics then
                SRC.Diagnostics:AddFields("LIVE_SESSION", "Assignment invalidated", {
                    account = account, responsibility = tostring(responsibilityKey or ""),
                    reason = "PLAYER_NOT_IN_CURRENT_GROUP", generation = self:GetGeneration(),
                })
            end
            if C.EventBus then C.EventBus:Publish("RUNTIME_ASSIGNMENT_INVALID", { account=account, responsibility=responsibilityKey, generation=self:GetGeneration() }) end
        end
        return nil, "PLAYER_NOT_IN_CURRENT_GROUP"
    end
    return account, nil
end

function Live:CancelRuntime(reason)
    reason = tostring(reason or "live session invalidated")
    if C.TimelineEngine then C.TimelineEngine:Clear(reason) end
    if SRC.TrashRotation and SRC.TrashRotation.ResetRuntime then SRC.TrashRotation:ResetRuntime(reason) end

    local modules = {
        SRC.ColossusRotation, SRC.WarhornRotation, SRC.BarrierRotation,
        SRC.NazarayModule, SRC.PillagerModule, SRC.MajorSlayerModule,
    }
    for _, module in ipairs(modules) do
        if module and module.HardReset then module:HardReset(reason) end
    end

    if SRC.EncounterSequenceEngine and SRC.EncounterSequenceEngine.Reset then
        SRC.EncounterSequenceEngine:Reset(reason)
    end
    if SRC.EncounterExecutionRuntime and SRC.EncounterExecutionRuntime.Reset then
        SRC.EncounterExecutionRuntime:Reset(reason)
    end
end

function Live:Refresh(reason, force)
    local roster = self:BuildRoster()
    local fingerprint = self:BuildFingerprint(roster)
    local changed = force == true or fingerprint ~= tostring(self.fingerprint or "")
    self.roster = roster
    if not changed then return false end
    self.invalidAssignments = {}
    if SRC.RemoveAssignmentsNotInRoster then SRC:RemoveAssignmentsNotInRoster(roster, reason or "live roster changed") end

    local previous = tostring(self.fingerprint or "")
    self.fingerprint = fingerprint
    self.generation = (tonumber(self.generation) or 0) + 1
    self.updatedAtMs = NowMs()
    self:CancelRuntime("group context changed: " .. tostring(reason or "unknown"))

    if C.Network and C.Network.ResetForLiveSession then
        C.Network:ResetForLiveSession(self.generation, self.fingerprint, reason)
    end
    if SRC.Diagnostics then
        SRC.Diagnostics:AddFields("LIVE_SESSION", "Live group rebuilt", {
            reason = tostring(reason or "unknown"),
            generation = self.generation,
            previousFingerprint = previous,
            fingerprint = fingerprint,
        })
    end
    if C.EventBus then
        C.EventBus:Publish("LIVE_SESSION_CHANGED", {
            reason = reason,
            generation = self.generation,
            fingerprint = self.fingerprint,
            roster = self.roster,
        })
    end
    return true
end

function Live:Initialize()
    self.generation = 0
    self.roster = {}
    self.fingerprint = ""
    self:Refresh("initialize", true)

    local eventName = (SRC.name or "Conductor") .. "LiveSession"
    EVENT_MANAGER:RegisterForEvent(eventName, EVENT_GROUP_UPDATE, function()
        zo_callLater(function() self:Refresh("group update") end, 150)
    end)
    EVENT_MANAGER:RegisterForEvent(eventName .. "Joined", EVENT_GROUP_MEMBER_JOINED, function()
        zo_callLater(function() self:Refresh("member joined") end, 150)
    end)
    EVENT_MANAGER:RegisterForEvent(eventName .. "Left", EVENT_GROUP_MEMBER_LEFT, function()
        zo_callLater(function() self:Refresh("member left") end, 150)
    end)
    EVENT_MANAGER:RegisterForEvent(eventName .. "Activated", EVENT_PLAYER_ACTIVATED, function()
        zo_callLater(function() self:Refresh("player activated") end, 250)
    end)
    self.initialized = true
end
