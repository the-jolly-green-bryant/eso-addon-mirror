local BB = BetterBuffs
BB.Runtime = BB.Runtime or {}
local Runtime = BB.Runtime
local EVENT_NAME = "BetterBuffsEffectRuntime"
local UPDATE_NAME = "BetterBuffsActiveEffects"
local PLAYER_EVENT_NAME = "BetterBuffsPlayerEffectSync"

local function EffectNow() return GetFrameTimeSeconds() end
local function NewIntelligence() return { recipientCooldowns={}, targetCooldowns={} } end

function Runtime:Initialize()
    self.enabled = false
    self.active = {}
    self.intelligence = {}
    self.missingVisibleUntil = {}
    self.lastSnapshots = {}
    for key in pairs(BB.Registry.byKey) do
        self.active[key] = {}
        self.intelligence[key] = NewIntelligence()
    end
end


function Runtime:IsObserved(key)
    if BB:IsEffectEnabled(key) then return true end
    return key == "MAJOR_SLAYER" and BB.saved and BB.saved.ui and BB.saved.ui.slayerMissAlert and BB.saved.ui.slayerMissAlert.enabled == true
end

function Runtime:SetEnabled(value)
    value = value == true
    if value == self.enabled then return end
    self.enabled = value
    if value then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAME, EVENT_EFFECT_CHANGED, function(_, ...) Runtime:OnEffectChanged(...) end)
        EVENT_MANAGER:RegisterForEvent(PLAYER_EVENT_NAME, EVENT_PLAYER_ACTIVATED, function()
            zo_callLater(function() if Runtime.enabled then Runtime:SynchronizePlayerEffects() end end, 250)
        end)
        zo_callLater(function() if Runtime.enabled then Runtime:SynchronizePlayerEffects() end end, 250)
        if BB.Context and BB.Context.inCombat then self:StartEncounter() end
    else
        EVENT_MANAGER:UnregisterForEvent(EVENT_NAME, EVENT_EFFECT_CHANGED)
        EVENT_MANAGER:UnregisterForEvent(PLAYER_EVENT_NAME, EVENT_PLAYER_ACTIVATED)
        self:StopUpdate()
        if BB.Analytics then BB.Analytics.encounter = nil end
        self:ClearAll()
    end
end

function Runtime:StartUpdate()
    if self.updateRunning then return end
    self.updateRunning = true
    EVENT_MANAGER:RegisterForUpdate(UPDATE_NAME, BB.Constants.BAR_UPDATE_MS, function() Runtime:Update() end)
end

function Runtime:StopUpdate()
    if not self.updateRunning then return end
    self.updateRunning = false
    EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME)
end

function Runtime:OnTrackingChanged(key)
    if not self:IsObserved(key) then self:ClearEffect(key) end
end

function Runtime:StartEncounter()
    if not self.enabled then return end
    if BB.Analytics then BB.Analytics:Start() end
end

function Runtime:OnEncounterEnded(reason)
    if BB.Analytics then BB.Analytics:Finish(reason) end
    self:ResetEncounterEffects()
    zo_callLater(function()
        if Runtime.enabled and not IsUnitDead("player") then Runtime:SynchronizePlayerEffects() end
    end, 250)
end

function Runtime:OnCombatStateChanged(inCombat)
    if inCombat then self:StartEncounter(); return end
    local now = EffectNow()
    for key in pairs(BB.Registry.byKey) do self:RefreshEffect(key, now) end
    if self:NeedsUpdate() then self:StartUpdate() else self:StopUpdate() end
end

function Runtime:OnGroupChanged()
    local now=EffectNow()
    for key,definition in pairs(BB.Registry.byKey) do
        if definition.effectType == "BUFF" then
            local targets=self.active[key] or {}
            for targetKey,data in pairs(targets) do
                if data.account and data.account ~= "" and not BB.Context.groupAccounts[data.account] then targets[targetKey]=nil end
            end
            local intel = self.intelligence[key]
            if intel and intel.recipientCooldowns then
                for account in pairs(intel.recipientCooldowns) do
                    if not BB.Context.groupAccounts[account] then intel.recipientCooldowns[account]=nil end
                end
            end
            self:RefreshEffect(key,now)
        end
    end
end

function Runtime:RemoveBuffTarget(unitId, unitName)
    local account = BB.Context:ResolveAccount(nil, unitName, unitId)
    local normalizedName = BB:NormalizeText(unitName)
    local now = EffectNow()
    for key,definition in pairs(BB.Registry.byKey) do
        if definition.effectType == "BUFF" then
            local targets = self.active[key] or {}
            for targetKey,data in pairs(targets) do
                local sameAccount = account ~= "" and (targetKey == account or data.account == account)
                local sameUnitId = unitId and unitId ~= 0 and data.unitId and tostring(data.unitId) == tostring(unitId)
                local sameName = normalizedName ~= "" and BB:NormalizeText(data.unitName) == normalizedName
                if sameAccount or sameUnitId or sameName then targets[targetKey] = nil end
            end
            if account ~= "" and self.intelligence[key] and self.intelligence[key].recipientCooldowns then
                self.intelligence[key].recipientCooldowns[account] = nil
            end
            self:RefreshEffect(key, now)
        end
    end
end

function Runtime:OnLocalPlayerDeath()
    self:RemoveBuffTarget(GetUnitId and GetUnitId("player") or nil, GetUnitName("player") or "")
end

function Runtime:RemoveHostileTarget(unitId,unitName)
    local idKey=unitId and unitId~=0 and ("unit:"..tostring(unitId)) or nil
    local normalizedName=BB:NormalizeText(unitName)
    local nameKey=normalizedName~="" and ("name:"..normalizedName) or nil
    local now=EffectNow()
    for key,definition in pairs(BB.Registry.byKey) do
        if definition.effectType == "DEBUFF" then
            local targets=self.active[key] or {}
            for targetKey,data in pairs(targets) do
                local sameKey = (idKey and (targetKey==idKey or string.find(targetKey, idKey, 1, true)==1)) or (nameKey and (targetKey==nameKey or string.find(targetKey, nameKey, 1, true)==1))
                local sameUnitId = unitId and unitId~=0 and data.unitId and tostring(data.unitId)==tostring(unitId)
                local sameName = normalizedName~="" and BB:NormalizeText(data.unitName)==normalizedName
                if sameKey or sameUnitId or sameName then targets[targetKey]=nil end
            end
            local intel = self.intelligence[key]
            if intel and intel.targetCooldowns then
                for cooldownKey,data in pairs(intel.targetCooldowns) do
                    local sameKey = (idKey and cooldownKey==idKey) or (nameKey and cooldownKey==nameKey)
                    local sameUnitId = unitId and unitId~=0 and data.unitId and tostring(data.unitId)==tostring(unitId)
                    local sameName = normalizedName~="" and BB:NormalizeText(data.unitName)==normalizedName
                    if sameKey or sameUnitId or sameName then intel.targetCooldowns[cooldownKey]=nil end
                end
            end
            self:RefreshEffect(key,now)
        end
    end
    -- A dead marked target can leave a provider cooldown still running. Keep the
    -- existing runtime update alive so that cooldown reaches zero and READY is
    -- rendered instead of freezing on the death-frame value.
    if self:NeedsUpdate() then self:StartUpdate() else self:StopUpdate() end
end

function Runtime:ResetEncounterEffects()
    local now = EffectNow()
    for key,definition in pairs(BB.Registry.byKey) do
        local intel = self.intelligence[key] or NewIntelligence()

        -- Encounter completion invalidates hostile target ownership, but it does
        -- not invalidate real player buffs or recipient/provider cooldowns. Player
        -- buffs continue until ESO fades them; hostile debuffs are target-owned and
        -- are discarded when the encounter context ends.
        if definition.effectType == "DEBUFF" then
            self.active[key] = {}
            intel.targetCooldowns = {}
        end

        if not definition.preserveProviderCooldownOnEncounterEnd then
            intel.providerCooldownUntil = nil
        elseif (intel.providerCooldownUntil or 0) <= now then
            intel.providerCooldownUntil = nil
        end

        if not definition.preserveRecipientCooldownOnEncounterEnd and definition.effectType == "DEBUFF" then
            intel.recipientCooldowns = {}
        end

        self.intelligence[key] = intel
        self.missingVisibleUntil[key] = nil
        if BB:IsEffectEnabled(key) then self:RefreshEffect(key, now) end
    end
    if self:NeedsUpdate() then self:StartUpdate() else self:StopUpdate() end
end

function Runtime:ClearEffect(key)
    self.active[key] = {}
    self.intelligence[key] = NewIntelligence()
    self.missingVisibleUntil[key] = nil
    self.lastSnapshots[key] = nil
    if BB.UI then BB.UI:ClearEffect(key) end
end

function Runtime:ClearAll()
    for key in pairs(self.active) do self:ClearEffect(key) end
end

function Runtime:NeedsUpdate()
    local now = EffectNow()
    for key,targets in pairs(self.active) do
        local definition=BB.Registry.byKey[key]
        if definition and BB:IsEffectEnabled(key) then
            for _,data in pairs(targets) do
                local endTime = tonumber(data.endTime)
                if endTime and endTime ~= math.huge and endTime > now then return true end
            end
            local intel = self.intelligence[key]
            if intel then
                if (intel.providerCooldownUntil or 0) > now then return true end
                for _,untilTime in pairs(intel.recipientCooldowns or {}) do if untilTime > now then return true end end
                for _,cooldown in pairs(intel.targetCooldowns or {}) do if (cooldown.untilTime or 0) > now then return true end end
            end
            if (self.missingVisibleUntil[key] or 0) > now then return true end
        end
    end
    return false
end

function Runtime:UpsertEffect(definition, targetKey, displayTarget, unitTag, unitName, unitId,
        beginTime, endTime, stackCount, abilityId, now, iconName)
    now = now or EffectNow()
    local targets = self.active[definition.key] or {}
    self.active[definition.key] = targets
    local hadAny = false
    for _,data in pairs(targets) do if data.endTime and data.endTime > now then hadAny = true break end end

    local prior = targets[targetKey]
    local storedEndTime = tonumber(endTime) or 0
    if storedEndTime <= now and definition.activeUntilFade then storedEndTime = math.huge end
    if storedEndTime <= now then targets[targetKey] = nil; return false end

    local numericBeginTime = tonumber(beginTime) or now
    local duration = storedEndTime == math.huge and 0 or math.max(0, storedEndTime - numericBeginTime)
    if duration <= 0 and prior then duration = tonumber(prior.duration) or 0 end
    if duration <= 0 and storedEndTime ~= math.huge then duration = math.max(0, storedEndTime - now) end

    local isNewApplication = prior == nil or not prior.endTime or prior.endTime <= now
        or numericBeginTime > ((tonumber(prior and prior.beginTime) or 0) + 0.25)
        or storedEndTime > ((tonumber(prior and prior.endTime) or 0) + 0.25)

    -- Warmask-style marks are semantically single-target. When ESO reports a
    -- genuine new application, retire any previous target record in the same
    -- canonical effect cache instead of allowing stale marks to coexist.
    if definition.singleActiveTarget and isNewApplication then
        for existingKey in pairs(targets) do
            if existingKey ~= targetKey then targets[existingKey] = nil end
        end
    end

    local intel = self.intelligence[definition.key] or NewIntelligence()
    self.intelligence[definition.key] = intel
    if intel.targetCooldowns then
        local cooldownKey = targetKey
        local marker = string.find(cooldownKey, "::child:", 1, true)
        if marker then cooldownKey = string.sub(cooldownKey, 1, marker - 1) end
        intel.targetCooldowns[cooldownKey] = nil
    end

    targets[targetKey] = {
        beginTime=numericBeginTime, endTime=storedEndTime, duration=duration,
        unitTag=unitTag, unitName=displayTarget or unitName,
        account=BB.Context:ResolveAccount(unitTag,unitName,unitId), unitId=unitId,
        abilityId=abilityId, stackCount=tonumber(stackCount) or 0, iconName=iconName or (prior and prior.iconName),
    }
    if definition.providerCooldown and ((definition.cooldownStartsEveryApplication and isNewApplication) or (not definition.cooldownStartsEveryApplication and not hadAny)) then
        intel.providerCooldownUntil = now + definition.providerCooldown
        intel.providerObserved = true
    end
    if definition.showMissingPlayers and not hadAny then self.missingVisibleUntil[definition.key] = now + definition.missingWindow end
    return not hadAny
end

function Runtime:SynchronizePlayerEffects()
    if not self.enabled or not GetNumBuffs or not GetUnitBuffInfo then return end
    local now = EffectNow()
    local playerId = GetUnitId and GetUnitId("player") or nil
    local playerName = GetUnitName("player") or ""
    local targetKey, displayTarget = BB.Context:GetTargetKey("player", playerId, playerName, "BUFF")
    if not targetKey then return end

    for key,definition in pairs(BB.Registry.byKey) do
        if definition.effectType == "BUFF" and self.active[key] then self.active[key][targetKey] = nil end
    end

    local count = tonumber(GetNumBuffs("player")) or 0
    for index = 1, count do
        local effectName, beginTime, endTime, _, stackCount, iconName, _, _, _, _, abilityId = GetUnitBuffInfo("player", index)
        local definition = BB.Registry:Resolve(effectName, abilityId)
        if definition and definition.effectType == "BUFF" and BB:IsEffectEnabled(definition.key) then
            local allowed = BB.Context:CanTrackEffect(definition, "player", playerId, playerName)
            if allowed then self:UpsertEffect(definition, targetKey, displayTarget, "player", playerName, playerId, beginTime, endTime, stackCount, abilityId, now, iconName) end
        end
    end

    for key,definition in pairs(BB.Registry.byKey) do if definition.effectType == "BUFF" then self:RefreshEffect(key, now) end end
    if self:NeedsUpdate() then self:StartUpdate() else self:StopUpdate() end
end

function Runtime:OnEffectChanged(changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount,
        iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    if not self.enabled then return end
    local definition = BB.Registry:Resolve(effectName,abilityId)
    if not definition or not self:IsObserved(definition.key) then return end
    local allowed = BB.Context:CanTrackEffect(definition,unitTag,unitId,unitName)
    if not allowed and changeType ~= EFFECT_RESULT_FADED then return end
    local baseTargetKey,displayTarget = BB.Context:GetTargetKey(unitTag,unitId,unitName,definition.effectType)
    if not baseTargetKey then return end
    local targetKey = baseTargetKey
    local compositeChild = BB.Registry:GetCompositeChild(definition, effectName)
    if compositeChild then targetKey = baseTargetKey .. "::child:" .. tostring(compositeChild) end

    local now = EffectNow()
    local targets = self.active[definition.key] or {}
    self.active[definition.key] = targets
    local application = false

    if changeType == EFFECT_RESULT_FADED then
        local prior = targets[targetKey]
        targets[targetKey] = nil
        if definition.targetCooldownOnFade and definition.targetCooldown and prior then
            local intel = self.intelligence[definition.key] or NewIntelligence()
            self.intelligence[definition.key] = intel
            intel.targetCooldowns = intel.targetCooldowns or {}
            intel.targetCooldowns[baseTargetKey] = {
                untilTime = now + definition.targetCooldown,
                unitId = prior.unitId,
                unitName = prior.unitName,
                unitTag = prior.unitTag,
            }
        end
    elseif allowed then
        application = self:UpsertEffect(definition, targetKey, displayTarget, unitTag, unitName, unitId, beginTime, endTime, stackCount, abilityId, now, iconName)
        local data = targets[targetKey]
        if data then
            data.baseTargetKey = baseTargetKey
            data.compositeChild = compositeChild
        end
    end

    if definition.key == "MAJOR_SLAYER" and changeType ~= EFFECT_RESULT_FADED and BB.Context and BB.Context.inCombat then
        local intel = self.intelligence[definition.key]
        local applicationBegin = tonumber(beginTime) or now
        if not intel.lastSlayerApplicationBegin or math.abs(applicationBegin - intel.lastSlayerApplicationBegin) > 0.25 then
            intel.lastSlayerApplicationBegin = applicationBegin
            self:ScheduleMajorSlayerMissCheck(applicationBegin)
        end
    end

    self:RefreshEffect(definition.key,now,application)
    if self:NeedsUpdate() then self:StartUpdate() else self:StopUpdate() end
end

function Runtime:OnCombatEvent(result, sourceName, targetName, sourceUnitId, targetUnitId, abilityId)
    if not self.enabled then return end
    abilityId = tonumber(abilityId)
    local releaseDefinition = BB.Registry.releaseByAbilityId and BB.Registry.releaseByAbilityId[abilityId]
    if releaseDefinition then
        self.active[releaseDefinition.key] = {}
        self:RefreshEffect(releaseDefinition.key, EffectNow())
    end

    local definition = BB.Registry.byCombatEventId and BB.Registry.byCombatEventId[abilityId]
    if not definition or not BB:IsEffectEnabled(definition.key) then return end
    if definition.intelligenceMode ~= "RECIPIENT_COOLDOWN" then return end
    local groupState = BB.Context:GetGroupEncounterState()
    if not BB.Context.inCombat and not groupState.encounterActive then return end
    if not BB.Context:IsGroupedPlayer(nil, targetUnitId, targetName) then return end

    local account = BB.Context:ResolveAccount(nil, targetName, targetUnitId)
    if account == "" then return end
    local now = EffectNow()
    local intel = self.intelligence[definition.key]
    intel.recipientCooldowns = intel.recipientCooldowns or {}
    intel.providerObserved = true
    local providerAccount = BB.Context:ResolveAccount(nil, sourceName, sourceUnitId)
    if providerAccount ~= "" then intel.providerAccount = providerAccount end
    local current = intel.recipientCooldowns[account] or 0
    if current <= now + 1 then
        intel.recipientCooldowns[account] = now + (definition.recipientCooldown or 45)
        intel.lastApplication = now
        self:RefreshEffect(definition.key, now, true)
        self:StartUpdate()
    end
end

function Runtime:ScheduleMajorSlayerMissCheck(beginTime)
    self.slayerMissGeneration = (self.slayerMissGeneration or 0) + 1
    local generation = self.slayerMissGeneration
    zo_callLater(function()
        if not Runtime.enabled or generation ~= Runtime.slayerMissGeneration then return end
        local alertSaved = BB.saved and BB.saved.ui and BB.saved.ui.slayerMissAlert
        if not alertSaved or alertSaved.enabled ~= true then return end
        if not BB.Context or BB.Context.inCombat ~= true then return end
        local snapshot = Runtime:GetSnapshot("MAJOR_SLAYER", EffectNow())
        if not snapshot then return end
        local localAccount = BB:NormalizeAccount(GetDisplayName() or "")
        if localAccount == "" then return end
        local received = false
        for _,account in ipairs(snapshot.activePlayers or {}) do
            if BB:NormalizeAccount(account) == localAccount then received = true break end
        end
        if not received and BB.UI then BB.UI:ShowSlayerMissAlert() end
    end, 1000)
end

function Runtime:GetCoverageTarget(definition, covered)
    local groupSize = BB:GetGroupTargetCount()
    if definition.observedProviderCapacity and definition.coveragePerProvider then
        local providers = math.max(1, math.ceil(math.max(1,covered) / definition.coveragePerProvider))
        return math.min(groupSize, providers * definition.coveragePerProvider)
    end
    if definition.coverageCap then return math.min(groupSize,definition.coverageCap) end
    return groupSize
end

function Runtime:IsPresentableHostile(definition, data)
    if not definition or definition.effectType ~= "DEBUFF" or definition.bossPriority == false then return true end
    if not BB.Context or not BB.Context:HasActiveBoss() then return true end
    return BB.Context:IsBossActor(data and data.unitTag, data and data.unitId, data and data.unitName)
end

function Runtime:GetCompositeSnapshot(definition, targets, now)
    local groups = {}
    local observedIcon = nil
    for targetKey,data in pairs(targets) do
        if not data.endTime or data.endTime <= now then
            targets[targetKey] = nil
        elseif self:IsPresentableHostile(definition, data) then
            local baseKey = data.baseTargetKey or targetKey
            local group = groups[baseKey]
            if not group then
                group = { children={}, targetName=data.unitName, unitId=data.unitId, unitTag=data.unitTag }
                groups[baseKey] = group
            end
            local child = data.compositeChild or targetKey
            if not group.children[child] then group.children[child] = data end
            observedIcon = observedIcon or data.iconName
        end
    end

    local best, bestCount = nil, -1
    for _,group in pairs(groups) do
        local count = 0
        local earliestEnd, earliestDuration = math.huge, 0
        for _,data in pairs(group.children) do
            count = count + 1
            if data.endTime and data.endTime < earliestEnd then
                earliestEnd = data.endTime
                earliestDuration = tonumber(data.duration) or 0
            end
        end
        group.count, group.earliestEnd, group.earliestDuration = count, earliestEnd, earliestDuration
        if count > bestCount or (count == bestCount and best and earliestEnd > (best.earliestEnd or 0)) then
            best, bestCount = group, count
        elseif not best then
            best, bestCount = group, count
        end
    end

    if not best then
        return {
            key=definition.key, active=false, availability="INACTIVE", remaining=0, percent=0,
            covered=0, target=0, targetName=nil, missingPlayers={}, activePlayers={},
            stackCount=0, locked=0, ready=0, icon=BB.Registry:GetIcon(definition,observedIcon),
        }
    end

    local remaining = best.earliestEnd == math.huge and 0 or math.max(0, best.earliestEnd - now)
    local percent = best.earliestDuration > 0 and zo_clamp((remaining / best.earliestDuration) * 100, 0, 100) or 100
    return {
        key=definition.key, active=true, availability="ACTIVE", remaining=remaining, percent=percent,
        covered=0, target=0, targetName=best.targetName, missingPlayers={}, activePlayers={},
        stackCount=best.count, locked=0, ready=0, icon=BB.Registry:GetIcon(definition,observedIcon),
    }
end

function Runtime:GetSnapshot(key,now)
    now = now or EffectNow()
    local definition = BB.Registry.byKey[key]
    if not definition then return nil end
    local targets = self.active[key] or {}

    if definition.compositeChildren then
        return self:GetCompositeSnapshot(definition, targets, now)
    end

    local covered,maxEnd,maxDuration,targetName,maxStacks,observedIcon = 0,0,0,nil,0,nil
    local coveredAccounts, activePlayers = {}, {}
    for targetKey,data in pairs(targets) do
        if not data.endTime or data.endTime <= now then
            targets[targetKey]=nil
        elseif self:IsPresentableHostile(definition, data) then
            if definition.effectType == "BUFF" then
                local recipientKey = data.account and data.account ~= "" and data.account or targetKey
                if not coveredAccounts[recipientKey] then
                    coveredAccounts[recipientKey] = true
                    if definition.recipientDisplay ~= "ACTIVE" or (data.account and data.account ~= "") then
                        covered = covered + 1
                    end
                    if data.account and data.account ~= "" then activePlayers[#activePlayers+1]=data.account end
                end
            end
            maxStacks = math.max(maxStacks, tonumber(data.stackCount) or 0)
            observedIcon = observedIcon or data.iconName
            if data.endTime > maxEnd then maxEnd=data.endTime; maxDuration=tonumber(data.duration) or 0; targetName=data.unitName end
        end
    end
    table.sort(activePlayers)

    local remaining=maxEnd==math.huge and 0 or math.max(0,maxEnd-now)
    local isActive=maxEnd>now
    local percent=0
    if isActive then percent=maxDuration>0 and zo_clamp((remaining/maxDuration)*100,0,100) or 100 end
    local target=definition.effectType=="BUFF" and self:GetCoverageTarget(definition,covered) or 0
    if definition.effectType=="BUFF" then covered=math.min(covered,math.max(target,covered)) end

    local missing={}
    if definition.effectType=="BUFF" and definition.showMissingPlayers and now <= (self.missingVisibleUntil[key] or 0) then
        local function addAccount(unitTag)
            if not DoesUnitExist(unitTag) then return end
            local account=BB:NormalizeAccount(GetUnitDisplayName(unitTag) or "")
            if account ~= "" and not coveredAccounts[account] then missing[#missing+1]=account end
        end
        addAccount("player")
        for i=1,(tonumber(GetGroupSize()) or 0) do addAccount(GetGroupUnitTagByIndex(i)) end
    end

    local intel = self.intelligence[key] or NewIntelligence()
    self.intelligence[key] = intel
    local locked,ready,maxCooldown = 0,0,0
    if definition.intelligenceMode == "RECIPIENT_COOLDOWN" then
        for account,untilTime in pairs(intel.recipientCooldowns or {}) do
            if untilTime <= now then intel.recipientCooldowns[account]=nil else locked=locked+1; maxCooldown=math.max(maxCooldown,untilTime-now) end
        end
        target = BB:GetGroupTargetCount()
        ready = math.max(0,target-locked)
        covered = locked
        isActive = locked > 0
        remaining = maxCooldown
        percent = definition.recipientCooldown and zo_clamp((remaining/definition.recipientCooldown)*100,0,100) or 0
    end

    local maxTargetCooldown, cooldownTargetName = 0,nil
    for cooldownKey,cooldown in pairs(intel.targetCooldowns or {}) do
        local untilTime = tonumber(cooldown.untilTime) or 0
        if untilTime <= now then
            intel.targetCooldowns[cooldownKey] = nil
        elseif self:IsPresentableHostile(definition, cooldown) then
            local cooldownRemaining = untilTime - now
            if cooldownRemaining > maxTargetCooldown then
                maxTargetCooldown = cooldownRemaining
                cooldownTargetName = cooldown.unitName
            end
        end
    end

    local availability = "INACTIVE"
    local providerCooldownActive = (intel.providerCooldownUntil or 0) > now
    local providerKnown = not definition.readyRequiresObservedProvider or intel.providerObserved == true
    if definition.intelligenceMode == "RECIPIENT_COOLDOWN" then
        if locked == 0 then
            availability = providerKnown and "READY" or "INACTIVE"
            if not providerKnown then target, ready, covered = 0, 0, 0 end
        elseif ready > 0 then
            availability = "PARTIAL"
        else
            availability = "COOLDOWN"
        end
    elseif providerCooldownActive and definition.providerCooldownOverridesActive then
        availability = "COOLDOWN"
        remaining = intel.providerCooldownUntil-now
        percent = definition.providerCooldown and definition.providerCooldown > 0 and zo_clamp((remaining/definition.providerCooldown)*100,0,100) or 0
    elseif isActive then
        availability = "ACTIVE"
    elseif maxTargetCooldown > 0 then
        availability = "COOLDOWN"
        remaining = maxTargetCooldown
        targetName = cooldownTargetName
        percent = definition.targetCooldown and definition.targetCooldown > 0 and zo_clamp((remaining/definition.targetCooldown)*100,0,100) or 0
    elseif providerCooldownActive then
        availability = "COOLDOWN"
        remaining = intel.providerCooldownUntil-now
        percent = definition.providerCooldown and definition.providerCooldown > 0 and zo_clamp((remaining/definition.providerCooldown)*100,0,100) or 0
    elseif definition.showReady then
        availability = (not definition.readyRequiresObservedProvider or intel.providerObserved == true) and "READY" or "INACTIVE"
    end

    return {
        key=key, active=isActive, availability=availability, remaining=remaining, percent=percent,
        covered=covered, target=target, targetName=targetName, missingPlayers=missing, activePlayers=activePlayers,
        stackCount=maxStacks, locked=locked, ready=ready, providerKnown=providerKnown, icon=BB.Registry:GetIcon(definition,observedIcon),
    }
end

function Runtime:OnBossContextChanged()
    if not self.enabled then return end
    local now = EffectNow()
    for key,definition in pairs(BB.Registry.byKey) do
        if definition.effectType == "DEBUFF" and BB:IsEffectEnabled(key) then self:RefreshEffect(key, now) end
    end
    if self:NeedsUpdate() then self:StartUpdate() else self:StopUpdate() end
end

function Runtime:RefreshEffect(key,now,application)
    local definition=BB.Registry.byKey[key]
    if not definition then return end
    if not self:IsObserved(key) then self:ClearEffect(key); return end
    local snapshot = self:GetSnapshot(key,now)
    self.lastSnapshots[key] = snapshot
    if BB:IsEffectEnabled(key) then
        if BB.Analytics then BB.Analytics:Observe(key,snapshot,now,application) end
        if BB.UI then BB.UI:UpdateEffect(definition,snapshot) end
        if BB.API then BB.API:Fire(application and "EFFECT_ACTIVATED" or "EFFECT_CHANGED", key, snapshot) end
    end
end

function Runtime:Update()
    if not self.enabled then self:StopUpdate(); return end
    local now=EffectNow()
    for key in pairs(self.active) do if BB:IsEffectEnabled(key) then self:RefreshEffect(key,now) end end
    BB.UI:RefreshAll(false)
    if not self:NeedsUpdate() then self:StopUpdate() end
end
