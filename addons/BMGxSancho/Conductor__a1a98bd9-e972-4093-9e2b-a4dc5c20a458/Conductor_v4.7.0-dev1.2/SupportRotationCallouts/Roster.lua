local SRC = SupportRotationCallouts
SRC.Roster = SRC.Roster or {}
local Roster = SRC.Roster

Roster.REFRESH_COOLDOWN_MS = 1000

local function EnsureStorage(self)
    self.characterToAccount = self.characterToAccount or {}
    self.accountToUnitTag = self.accountToUnitTag or {}
    self.lastRefreshMs = self.lastRefreshMs or 0
end

function Roster:Initialize()
    self.characterToAccount = {}
    self.accountToUnitTag = {}
    self.lastSignature = nil
    self.lastRefreshMs = 0

    EVENT_MANAGER:RegisterForEvent(
        SRC.name .. "GroupUpdate",
        EVENT_GROUP_UPDATE,
        function() self:Refresh(true) end
    )

    EVENT_MANAGER:RegisterForEvent(
        SRC.name .. "GroupMemberJoined",
        EVENT_GROUP_MEMBER_JOINED,
        function() self:Refresh(true) end
    )

    EVENT_MANAGER:RegisterForEvent(
        SRC.name .. "GroupMemberLeft",
        EVENT_GROUP_MEMBER_LEFT,
        function() self:Refresh(true) end
    )
end

local function NormalizeCharacter(name)
    if not name then return "" end
    return zo_strlower(zo_strtrim(zo_strformat("<<1>>", name)))
end

function Roster:AddUnit(unitTag)
    EnsureStorage(self)
    if not unitTag or not DoesUnitExist(unitTag) then return end

    local characterName = GetUnitName(unitTag)
    local displayName = GetUnitDisplayName(unitTag)
    if not characterName or characterName == "" or not displayName or displayName == "" then
        return
    end

    self.characterToAccount[NormalizeCharacter(characterName)] = displayName
    self.accountToUnitTag[SRC:NormalizeAccountName(displayName)] = unitTag
end

function Roster:BuildSignature()
    EnsureStorage(self)
    local parts = {}
    for account, unitTag in pairs(self.accountToUnitTag) do
        parts[#parts + 1] = account .. ":" .. tostring(unitTag)
    end
    table.sort(parts)
    return table.concat(parts, "|")
end

function Roster:Refresh(force)
    EnsureStorage(self)
    local nowMs = GetGameTimeMilliseconds()
    if not force and nowMs - (self.lastRefreshMs or 0) < self.REFRESH_COOLDOWN_MS then
        return false
    end

    self.lastRefreshMs = nowMs
    ZO_ClearTable(self.characterToAccount)
    ZO_ClearTable(self.accountToUnitTag)

    self:AddUnit("player")

    local groupSize = GetGroupSize()
    for index = 1, groupSize do
        self:AddUnit(GetGroupUnitTagByIndex(index))
    end

    local signature = self:BuildSignature()
    if signature ~= self.lastSignature then
        self.lastSignature = signature
        SRC.Diagnostics:AddFields("ROSTER", "Roster changed", {
            groupSlots = groupSize,
            trackedAccounts = (function() local count = 0 for _ in pairs(self.accountToUnitTag) do count = count + 1 end return count end)(),
        })
    end

    return true
end

function Roster:GetAccountFromCharacter(characterName)
    EnsureStorage(self)
    local normalized = NormalizeCharacter(characterName)
    local account = self.characterToAccount[normalized]
    if account then return account end

    self:Refresh(false)
    return self.characterToAccount[normalized]
end

function Roster:GetUnitTagFromAccount(accountName)
    EnsureStorage(self)
    local normalized = SRC:NormalizeAccountName(accountName)
    local unitTag = self.accountToUnitTag[normalized]
    if unitTag and DoesUnitExist(unitTag) then return unitTag end

    self:Refresh(false)
    unitTag = self.accountToUnitTag[normalized]
    if unitTag and DoesUnitExist(unitTag) then return unitTag end
    return nil
end

function Roster:IsLocalAccount(accountName)
    return SRC:NormalizeAccountName(accountName)
        == SRC:NormalizeAccountName(GetDisplayName())
end
