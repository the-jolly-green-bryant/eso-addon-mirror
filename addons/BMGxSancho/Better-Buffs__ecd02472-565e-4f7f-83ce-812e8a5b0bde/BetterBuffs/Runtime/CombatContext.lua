local BB = BetterBuffs
BB.Context = BB.Context or {}
local Context = BB.Context
local EVENT_NAME = "BetterBuffsCombatContext"

local function ValidUnitId(unitId) return unitId ~= nil and unitId ~= 0 and unitId ~= "" end
local function AddName(target, value)
    local normalized = BB:NormalizeText(value)
    if normalized ~= "" then target[normalized] = true end
end

function Context:Initialize()
    self.groupUnitIds, self.groupNames, self.groupAccounts = {}, {}, {}
    self.bossUnitIds, self.bossNames = {}, {}
    self.trashUnitIds, self.trashNames = {}, {}
    self.inCombat = IsUnitInCombat and IsUnitInCombat("player") == true or false
    self.lifecycleGeneration = 0
    self:RefreshGroupActors()
    self:RefreshBossActors()

    local function groupChanged()
        Context:RefreshGroupActors()
        if BB.Runtime then BB.Runtime:OnGroupChanged() end
        if not Context.inCombat then Context:ScheduleEncounterResolution(750) end
    end

    EVENT_MANAGER:RegisterForEvent(EVENT_NAME, EVENT_GROUP_MEMBER_JOINED, groupChanged)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAME, EVENT_GROUP_MEMBER_LEFT, groupChanged)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAME, EVENT_GROUP_UPDATE, groupChanged)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAME, EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
        Context.inCombat = inCombat == true
        Context.lifecycleGeneration = Context.lifecycleGeneration + 1
        Context:RefreshGroupActors()
        Context:RefreshBossActors()
        if BB.Runtime then BB.Runtime:OnCombatStateChanged(Context.inCombat) end
        if not Context.inCombat then Context:ScheduleEncounterResolution(750) end
    end)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAME, EVENT_BOSSES_CHANGED, function()
        Context:RefreshBossActors()
        if not Context.inCombat then Context:ScheduleEncounterResolution(500) end
    end)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAME, EVENT_COMBAT_EVENT, function(_, ...)
        Context:OnCombatEvent(...)
    end)
end

function Context:ClearHostileActors()
    self.bossUnitIds, self.bossNames = {}, {}
    self.trashUnitIds, self.trashNames = {}, {}
end

function Context:RefreshGroupActors()
    self.groupUnitIds, self.groupNames, self.groupAccounts = {}, {}, {}
    local function addUnit(unitTag)
        if not unitTag or unitTag == "" or not DoesUnitExist(unitTag) then return end
        local unitId = GetUnitId and GetUnitId(unitTag) or nil
        if ValidUnitId(unitId) then self.groupUnitIds[tostring(unitId)] = true end
        AddName(self.groupNames, GetUnitName(unitTag))
        AddName(self.groupNames, GetRawUnitName and GetRawUnitName(unitTag) or "")
        local account = BB:NormalizeAccount(GetUnitDisplayName(unitTag) or "")
        if account ~= "" then self.groupAccounts[account] = true; AddName(self.groupNames, account) end
    end
    addUnit("player")
    for index=1,(tonumber(GetGroupSize()) or 0) do addUnit(GetGroupUnitTagByIndex(index)) end
end

function Context:RefreshBossActors()
    self.bossUnitIds, self.bossNames = {}, {}
    for index=1,12 do
        local unitTag = "boss" .. tostring(index)
        if DoesUnitExist(unitTag) and not IsUnitDead(unitTag) then
            local unitId = GetUnitId and GetUnitId(unitTag) or nil
            if ValidUnitId(unitId) then self.bossUnitIds[tostring(unitId)] = true end
            AddName(self.bossNames, GetUnitName(unitTag))
            AddName(self.bossNames, GetRawUnitName and GetRawUnitName(unitTag) or "")
        end
    end
end

function Context:IsLocalPlayer(unitTag, unitId, unitName)
    if unitTag == "player" then return true end
    local playerId = GetUnitId and GetUnitId("player") or nil
    if ValidUnitId(unitId) and ValidUnitId(playerId) and tostring(unitId) == tostring(playerId) then return true end
    return BB:NormalizeText(unitName) ~= "" and BB:NormalizeText(unitName) == BB:NormalizeText(GetUnitName("player") or "")
end

function Context:IsGroupedPlayer(unitTag, unitId, unitName)
    if self:IsLocalPlayer(unitTag, unitId, unitName) then return true end
    if unitTag and unitTag ~= "" and DoesUnitExist(unitTag) then
        local account = BB:NormalizeAccount(GetUnitDisplayName(unitTag) or "")
        if account ~= "" and self.groupAccounts[account] then return true end
        if IsUnitGrouped and IsUnitGrouped(unitTag) then return true end
    end
    if ValidUnitId(unitId) and self.groupUnitIds[tostring(unitId)] then return true end
    return self.groupNames[BB:NormalizeText(unitName)] == true
end

function Context:IsBossActor(unitTag, unitId, unitName)
    if unitTag and string.sub(unitTag,1,4) == "boss" and DoesUnitExist(unitTag) then return true end
    if ValidUnitId(unitId) and self.bossUnitIds[tostring(unitId)] then return true end
    return self.bossNames[BB:NormalizeText(unitName)] == true
end

function Context:IsTrashActor(unitId, unitName)
    if ValidUnitId(unitId) and self.trashUnitIds[tostring(unitId)] then return true end
    return self.trashNames[BB:NormalizeText(unitName)] == true
end

function Context:RegisterTrashActor(unitId, unitName)
    if not self.inCombat then return end
    if ValidUnitId(unitId) then self.trashUnitIds[tostring(unitId)] = true end
    AddName(self.trashNames, unitName)
end

function Context:GetGroupEncounterState()
    local seen, members, alive, active = {}, 0, 0, 0
    local function inspect(unitTag)
        if not unitTag or unitTag == "" or seen[unitTag] or not DoesUnitExist(unitTag) then return end
        seen[unitTag] = true
        members = members + 1
        if not IsUnitDead(unitTag) then
            alive = alive + 1
            if IsUnitInCombat and IsUnitInCombat(unitTag) then active = active + 1 end
        end
    end
    inspect("player")
    for index=1,(tonumber(GetGroupSize()) or 0) do inspect(GetGroupUnitTagByIndex(index)) end
    return {
        members = members,
        alive = alive,
        active = active,
        wiped = members > 0 and alive == 0,
        encounterActive = active > 0,
    }
end

function Context:ScheduleEncounterResolution(delayMs)
    self.lifecycleGeneration = (self.lifecycleGeneration or 0) + 1
    local generation = self.lifecycleGeneration
    zo_callLater(function()
        if generation ~= Context.lifecycleGeneration or Context.inCombat then return end
        local state = Context:GetGroupEncounterState()
        if state.encounterActive then return end
        if BB.Runtime then
            BB.Runtime:OnEncounterEnded(state.wiped and "GROUP_WIPE" or "COMBAT_ENDED")
        end
        Context:ClearHostileActors()
    end, tonumber(delayMs) or 750)
end

function Context:OnCombatEvent(result, isError, abilityName, abilityGraphic, abilityActionSlotType,
        sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log,
        sourceUnitId, targetUnitId, abilityId, overflow)
    if result == ACTION_RESULT_DIED or result == ACTION_RESULT_DIED_XP then
        local targetIsLocal = self:IsLocalPlayer(nil, targetUnitId, targetName)
        local targetIsGroup = self:IsGroupedPlayer(nil, targetUnitId, targetName)
        local targetIsBoss = self:IsBossActor(nil, targetUnitId, targetName)

        if targetIsGroup then
            if BB.Runtime then BB.Runtime:RemoveBuffTarget(targetUnitId, targetName) end
            if targetIsLocal and BB.Runtime then BB.Runtime:OnLocalPlayerDeath() end
            self:ScheduleEncounterResolution(500)
            return
        end

        if BB.Runtime then BB.Runtime:RemoveHostileTarget(targetUnitId, targetName) end
        if targetIsBoss then self:ScheduleEncounterResolution(750) end
        return
    end

    if not self.inCombat then return end
    self:RefreshBossActors()
    local sourceIsGroup = self:IsGroupedPlayer(nil, sourceUnitId, sourceName)
    local targetIsGroup = self:IsGroupedPlayer(nil, targetUnitId, targetName)
    if sourceIsGroup and not targetIsGroup and not self:IsBossActor(nil,targetUnitId,targetName) then
        self:RegisterTrashActor(targetUnitId,targetName)
    elseif targetIsGroup and not sourceIsGroup and not self:IsBossActor(nil,sourceUnitId,sourceName) then
        self:RegisterTrashActor(sourceUnitId,sourceName)
    end
end

function Context:CanTrackEffect(definition, unitTag, unitId, unitName)
    if definition.effectType == "BUFF" then
        local isSelf = self:IsLocalPlayer(unitTag,unitId,unitName)
        if definition.targetType == "SELF" then
            return isSelf, isSelf and "SELF" or "NON_SELF_TARGET"
        end
        if isSelf then return true,"SELF" end
        if self:IsGroupedPlayer(unitTag,unitId,unitName) then return true,"GROUP" end
        return false,"UNGROUPED_PLAYER"
    end
    if not self.inCombat then return false,"OUT_OF_COMBAT" end
    self:RefreshBossActors()
    local hasBoss = next(self.bossUnitIds) ~= nil or next(self.bossNames) ~= nil
    if hasBoss then
        local isBoss = self:IsBossActor(unitTag,unitId,unitName)
        return isBoss, isBoss and "BOSS" or "NON_BOSS_TARGET"
    end
    local isTrash = self:IsTrashActor(unitId,unitName)
    return isTrash, isTrash and "TRASH" or "UNOWNED_TRASH_TARGET"
end

function Context:ResolveAccount(unitTag, unitName)
    if unitTag and unitTag ~= "" and DoesUnitExist(unitTag) then
        return BB:NormalizeAccount(GetUnitDisplayName(unitTag) or "")
    end
    local normalizedName = BB:NormalizeText(unitName)
    if normalizedName == BB:NormalizeText(GetUnitName("player") or "") then return BB:NormalizeAccount(GetDisplayName() or "") end
    for index=1,(tonumber(GetGroupSize()) or 0) do
        local tag = GetGroupUnitTagByIndex(index)
        if DoesUnitExist(tag) and (BB:NormalizeText(GetUnitName(tag)) == normalizedName or BB:NormalizeText(GetRawUnitName and GetRawUnitName(tag) or "") == normalizedName) then
            return BB:NormalizeAccount(GetUnitDisplayName(tag) or "")
        end
    end
    return ""
end

function Context:GetTargetKey(unitTag, unitId, unitName, effectType)
    if effectType == "BUFF" then
        local account = self:ResolveAccount(unitTag,unitName)
        if account ~= "" then return account, account end
    end
    local displayName = BB:FormatUnitName(unitName)
    if ValidUnitId(unitId) then return "unit:"..tostring(unitId), displayName end
    local name = BB:NormalizeText(unitName)
    if name ~= "" then return "name:"..name, displayName end
    return nil,nil
end
