local SRC = SupportRotationCallouts
SRC.CombatContextEngine = SRC.CombatContextEngine or {}
local Context = SRC.CombatContextEngine

local EVENT_NAME = SRC.name .. "CombatContext"
local UPDATE_NAME = SRC.name .. "CombatContextRefresh"

local function Normalize(value)
    return zo_strlower(zo_strtrim(zo_strformat("<<1>>", tostring(value or ""))))
end

local function ValidUnitId(unitId)
    return unitId ~= nil and unitId ~= 0 and unitId ~= ""
end

local function AddName(target, value)
    local normalized = Normalize(value)
    if normalized ~= "" then target[normalized] = true end
end

function Context:Initialize()
    if self.initialized then return end
    self.initialized = true
    self.groupUnitIds = {}
    self.groupNames = {}
    self.groupAccounts = {}
    self.bossUnitIds = {}
    self.bossNames = {}
    self.trashUnitIds = {}
    self.trashNames = {}
    self.lastMode = "INACTIVE"

    self:RefreshGroupActors()
    self:RefreshBossActors()

    EVENT_MANAGER:RegisterForEvent(EVENT_NAME, EVENT_COMBAT_EVENT, function(_, ...)
        Context:OnCombatEvent(...)
    end)
    EVENT_MANAGER:RegisterForUpdate(UPDATE_NAME, 500, function()
        if not SRC.saved or SRC.saved.enabled ~= true then return end
        local grouped = IsUnitGrouped and IsUnitGrouped("player")
        if not grouped and not Context:IsInCombat() and not SRC.bossEncounterActive then return end
        Context:RefreshGroupActors()
        Context:RefreshBossActors()
        Context:ObserveMode()
    end)

    if SRC.EventBus then
        SRC.EventBus:Subscribe("ENCOUNTER_MODE_CHANGED", self, function(payload)
            Context:OnModeChanged(payload and payload.mode or "INACTIVE")
        end)
    end

    if SRC.Diagnostics and SRC.Diagnostics.Add then
        SRC.Diagnostics:Add("COMBAT_CONTEXT", "Encounter-scoped combat context registered")
    end
end

function Context:GetMode()
    if SRC.EncounterEngine then return SRC.EncounterEngine.mode or "INACTIVE" end
    return "INACTIVE"
end

function Context:IsInCombat()
    if SRC.inCombat ~= nil then return SRC.inCombat == true end
    return IsUnitInCombat and IsUnitInCombat("player") == true or false
end

function Context:ObserveMode()
    local mode = self:GetMode()
    if mode ~= self.lastMode then self:OnModeChanged(mode) end
end

function Context:OnModeChanged(mode)
    mode = tostring(mode or "INACTIVE")
    local previous = self.lastMode
    self.lastMode = mode

    if mode ~= "TRASH" then
        self.trashUnitIds = {}
        self.trashNames = {}
    end
    self:RefreshBossActors()

    if SRC.CoverageTracker and SRC.CoverageTracker.OnCombatContextChanged then
        SRC.CoverageTracker:OnCombatContextChanged(previous, mode)
    end
    if SRC.MajorSlayerModule and SRC.MajorSlayerModule.OnCombatContextChanged then
        SRC.MajorSlayerModule:OnCombatContextChanged(previous, mode)
    end
end

function Context:RefreshGroupActors()
    if not SRC.saved or SRC.saved.enabled ~= true then return end
    self.groupUnitIds = {}
    self.groupNames = {}
    self.groupAccounts = {}

    local function addUnit(unitTag)
        if not unitTag or unitTag == "" or not DoesUnitExist(unitTag) then return end
        local unitId = GetUnitId and GetUnitId(unitTag) or nil
        if ValidUnitId(unitId) then self.groupUnitIds[tostring(unitId)] = true end
        AddName(self.groupNames, GetUnitName(unitTag))
        AddName(self.groupNames, GetRawUnitName and GetRawUnitName(unitTag) or "")
        local account = SRC:NormalizeAccountName(GetUnitDisplayName(unitTag) or "")
        if account ~= "" then
            self.groupAccounts[account] = true
            AddName(self.groupNames, account)
        end
    end

    addUnit("player")
    local size = tonumber(GetGroupSize()) or 0
    for index = 1, size do addUnit(GetGroupUnitTagByIndex(index)) end
end

function Context:RefreshBossActors()
    self.bossUnitIds = {}
    self.bossNames = {}
    for index = 1, 12 do
        local unitTag = "boss" .. tostring(index)
        if DoesUnitExist(unitTag) and not IsUnitDead(unitTag) then
            local unitId = GetUnitId and GetUnitId(unitTag) or nil
            if ValidUnitId(unitId) then self.bossUnitIds[tostring(unitId)] = true end
            AddName(self.bossNames, GetUnitName(unitTag))
            AddName(self.bossNames, GetRawUnitName and GetRawUnitName(unitTag) or "")
        end
    end

    if SRC.knownEncounterBossNames then
        for normalizedName in pairs(SRC.knownEncounterBossNames) do
            self.bossNames[normalizedName] = true
        end
    end
end

function Context:IsLocalPlayer(unitTag, unitId, unitName)
    if unitTag == "player" then return true end
    local playerId = GetUnitId and GetUnitId("player") or nil
    if ValidUnitId(unitId) and ValidUnitId(playerId) and tostring(unitId) == tostring(playerId) then return true end
    local account = SRC:NormalizeAccountName(GetDisplayName() or "")
    local targetAccount = ""
    if unitTag and unitTag ~= "" and DoesUnitExist(unitTag) then
        targetAccount = SRC:NormalizeAccountName(GetUnitDisplayName(unitTag) or "")
    end
    if targetAccount ~= "" and targetAccount == account then return true end
    return Normalize(unitName) ~= "" and Normalize(unitName) == Normalize(GetUnitName("player") or "")
end

function Context:IsGroupedPlayer(unitTag, unitId, unitName)
    if self:IsLocalPlayer(unitTag, unitId, unitName) then return true end
    if unitTag and unitTag ~= "" and DoesUnitExist(unitTag) then
        if IsUnitGrouped and IsUnitGrouped(unitTag) then return true end
        local account = SRC:NormalizeAccountName(GetUnitDisplayName(unitTag) or "")
        if account ~= "" and self.groupAccounts[account] then return true end
    end
    if ValidUnitId(unitId) and self.groupUnitIds[tostring(unitId)] then return true end
    return self.groupNames[Normalize(unitName)] == true
end

function Context:IsBossActor(unitTag, unitId, unitName)
    if unitTag and string.sub(unitTag, 1, 4) == "boss" and DoesUnitExist(unitTag) then return true end
    if ValidUnitId(unitId) and self.bossUnitIds[tostring(unitId)] then return true end
    local normalized = Normalize(unitName)
    return normalized ~= "" and self.bossNames[normalized] == true
end

function Context:IsTrashActor(unitTag, unitId, unitName)
    if ValidUnitId(unitId) and self.trashUnitIds[tostring(unitId)] then return true end
    local normalized = Normalize(unitName)
    return normalized ~= "" and self.trashNames[normalized] == true
end

function Context:RegisterTrashActor(unitId, unitName)
    if self:GetMode() ~= "TRASH" then return end
    if ValidUnitId(unitId) then self.trashUnitIds[tostring(unitId)] = true end
    AddName(self.trashNames, unitName)
end

function Context:OnCombatEvent(result, isError, abilityName, abilityGraphic, abilityActionSlotType,
        sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log,
        sourceUnitId, targetUnitId, abilityId, overflow)
    if self:GetMode() ~= "TRASH" or not self:IsInCombat() then return end

    local sourceIsGroup = self:IsGroupedPlayer(nil, sourceUnitId, sourceName)
    local targetIsGroup = self:IsGroupedPlayer(nil, targetUnitId, targetName)
    if sourceIsGroup and not targetIsGroup then
        self:RegisterTrashActor(targetUnitId, targetName)
    elseif targetIsGroup and not sourceIsGroup then
        self:RegisterTrashActor(sourceUnitId, sourceName)
    end
end

function Context:CanTrackPlayerBuff(unitTag, unitId, unitName)
    -- Local buffs remain observable in and out of combat for setup testing.
    if self:IsLocalPlayer(unitTag, unitId, unitName) then return true, "SELF" end
    -- Buff coverage on other players is restricted to the current group.
    if self:IsGroupedPlayer(unitTag, unitId, unitName) then return true, "GROUP" end
    return false, "UNGROUPED_PLAYER"
end

function Context:CanTrackHostileEffect(unitTag, unitId, unitName)
    if not self:IsInCombat() then return false, "OUT_OF_COMBAT" end
    local mode = self:GetMode()
    if mode == "BOSS" then
        if self:IsBossActor(unitTag, unitId, unitName) then return true, "BOSS" end
        return false, "NON_BOSS_TARGET"
    end
    if mode == "TRASH" then
        if self:IsTrashActor(unitTag, unitId, unitName) then return true, "TRASH" end
        return false, "UNOWNED_TRASH_TARGET"
    end
    return false, "NO_HOSTILE_CONTEXT"
end

function Context:CanTrackEffect(definition, unitTag, unitId, unitName)
    if not definition then return false, "NO_DEFINITION" end
    if definition.effectType == "BUFF" then
        return self:CanTrackPlayerBuff(unitTag, unitId, unitName)
    end
    if definition.effectType == "DEBUFF" then
        return self:CanTrackHostileEffect(unitTag, unitId, unitName)
    end
    return false, "UNSUPPORTED_EFFECT_TYPE"
end

function Context:CanTrackGroupCombatSource(sourceName, sourceUnitId)
    return self:IsGroupedPlayer(nil, sourceUnitId, sourceName)
end

function Context:GetSnapshot()
    local function count(values)
        local total = 0
        for _ in pairs(values or {}) do total = total + 1 end
        return total
    end
    return {
        mode = self:GetMode(),
        inCombat = self:IsInCombat(),
        groupActors = count(self.groupUnitIds),
        bossActors = count(self.bossUnitIds),
        trashActors = count(self.trashUnitIds),
    }
end
