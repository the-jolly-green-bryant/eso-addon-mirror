local BB = BetterBuffs
BB.Runtime = BB.Runtime or {}
local Runtime = BB.Runtime
local EVENT_NAME = "BetterBuffsEffectRuntime"
local UPDATE_NAME = "BetterBuffsActiveEffects"
local PLAYER_EVENT_NAME = "BetterBuffsPlayerEffectSync"

-- ESO effect begin/end timestamps use the frame-time clock. All effect lifetime,
-- coverage expiration, missing-window, and uptime calculations must use this same
-- clock domain so records expire correctly after combat and across zone activity.
local function EffectNow()
    return GetFrameTimeSeconds()
end

function Runtime:Initialize()
    self.enabled = false
    self.active = {}
    self.missingVisibleUntil = {}
    self.encounter = nil
    for key in pairs(BB.Registry.byKey) do self.active[key] = {} end
end

function Runtime:SetEnabled(value)
    value = value == true
    if value == self.enabled then return end
    self.enabled = value
    if value then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAME, EVENT_EFFECT_CHANGED, function(_, ...)
            Runtime:OnEffectChanged(...)
        end)
        EVENT_MANAGER:RegisterForEvent(PLAYER_EVENT_NAME, EVENT_PLAYER_ACTIVATED, function()
            zo_callLater(function()
                if Runtime.enabled then Runtime:SynchronizePlayerEffects() end
            end, 250)
        end)
        zo_callLater(function()
            if Runtime.enabled then Runtime:SynchronizePlayerEffects() end
        end, 250)
        if BB.Context and BB.Context.inCombat then self:StartEncounter() end
    else
        EVENT_MANAGER:UnregisterForEvent(EVENT_NAME, EVENT_EFFECT_CHANGED)
        EVENT_MANAGER:UnregisterForEvent(PLAYER_EVENT_NAME, EVENT_PLAYER_ACTIVATED)
        self:StopUpdate()
        self.encounter = nil
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
    if not BB:IsEffectEnabled(key) then self:ClearEffect(key) end
end

function Runtime:OnGroupChanged()
    local now=EffectNow()
    for key,definition in pairs(BB.Registry.byKey) do
        if definition.effectType == "BUFF" then
            local targets=self.active[key] or {}
            for targetKey,data in pairs(targets) do
                if data.account and data.account ~= "" and not BB.Context.groupAccounts[data.account] then targets[targetKey]=nil end
            end
            self:RefreshEffect(key,now)
            self:UpdateUptimeState(key,now)
        end
    end
end

function Runtime:RemoveHostileTarget(unitId,unitName)
    local idKey=unitId and unitId~=0 and ("unit:"..tostring(unitId)) or nil
    local nameKey=BB:NormalizeText(unitName)~="" and ("name:"..BB:NormalizeText(unitName)) or nil
    local now=EffectNow()
    for key,definition in pairs(BB.Registry.byKey) do
        if definition.effectType == "DEBUFF" then
            local targets=self.active[key] or {}
            if idKey then targets[idKey]=nil end
            if nameKey then targets[nameKey]=nil end
            self:RefreshEffect(key,now)
            self:UpdateUptimeState(key,now)
        end
    end
end

function Runtime:OnCombatStateChanged(inCombat)
    if inCombat then
        self:StartEncounter()
    else
        self:EndEncounter()
        local now = EffectNow()
        -- Combat state controls whether new hostile effects may be accepted.
        -- Existing timed records remain authoritative until their real expiration.
        for key in pairs(BB.Registry.byKey) do
            self:RefreshEffect(key, now)
            self:UpdateUptimeState(key, now)
        end
        if self:NeedsUpdate() then self:StartUpdate() else self:StopUpdate() end
    end
end

function Runtime:ClearEffect(key)
    local now=EffectNow()
    self.active[key] = {}
    self.missingVisibleUntil[key] = nil
    self:UpdateUptimeState(key,now)
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
            if (self.missingVisibleUntil[key] or 0) > now then return true end
        end
    end
    return false
end

function Runtime:IsEffectActive(key,now)
    if not BB:IsEffectEnabled(key) then return false end
    now=now or EffectNow()
    for _,data in pairs(self.active[key] or {}) do
        if data.endTime and data.endTime > now then return true end
    end
    return false
end

function Runtime:StartEncounter()
    if not self.enabled or self.encounter then return end
    local now=EffectNow()
    self.encounter={startTime=now, totals={}, open={}}
    for key in pairs(BB.Registry.byKey) do
        if self:IsEffectActive(key,now) then self.encounter.open[key]=now end
    end
end

function Runtime:UpdateUptimeState(key,now)
    local encounter=self.encounter
    if not encounter then return end
    now=now or EffectNow()
    local active=self:IsEffectActive(key,now)
    local opened=encounter.open[key]
    if active and not opened then
        encounter.open[key]=now
    elseif not active and opened then
        encounter.totals[key]=(encounter.totals[key] or 0)+math.max(0,now-opened)
        encounter.open[key]=nil
    end
end

function Runtime:PrintUptimeReport(encounter,endTime)
    if not BB.saved.uptime or BB.saved.uptime.enabled==false then return end
    local duration=math.max(0,endTime-(encounter.startTime or endTime))
    local minimum=tonumber(BB.saved.uptime.minimumCombatSeconds) or 5
    if duration < minimum then return end

    local rows={}
    for _,definition in ipairs(BB.Registry.definitions) do
        local activeTime=tonumber(encounter.totals[definition.key]) or 0
        if activeTime > 0 and BB:IsEffectEnabled(definition.key) then
            rows[#rows+1]={name=definition.name,percent=zo_clamp((activeTime/duration)*100,0,100)}
        end
    end
    if #rows==0 then return end

    d(string.format("|cFFD447Better Buffs Uptime|r |cFFFFFF%.1fs|r",duration))
    for _,row in ipairs(rows) do
        d(string.format("|cD9D9D9%s|r  |cFFFFFF%.0f%%|r",row.name,row.percent))
    end
end

function Runtime:EndEncounter()
    local encounter=self.encounter
    if not encounter then return end
    local now=EffectNow()
    for key,opened in pairs(encounter.open) do
        encounter.totals[key]=(encounter.totals[key] or 0)+math.max(0,now-opened)
    end
    self.encounter=nil
    self:PrintUptimeReport(encounter,now)
end

function Runtime:UpsertEffect(definition, targetKey, displayTarget, unitTag, unitName, unitId,
        beginTime, endTime, stackCount, abilityId, now)
    now = now or EffectNow()
    local targets = self.active[definition.key] or {}
    self.active[definition.key] = targets

    local hadAny = false
    for _,data in pairs(targets) do
        if data.endTime and data.endTime > now then hadAny = true break end
    end

    local prior = targets[targetKey]
    local storedEndTime = tonumber(endTime) or 0
    if storedEndTime <= now and definition.activeUntilFade then
        storedEndTime = math.huge
    end
    if storedEndTime <= now then
        targets[targetKey] = nil
        return false
    end

    local numericBeginTime = tonumber(beginTime) or now
    local duration = storedEndTime == math.huge and 0 or math.max(0, storedEndTime - numericBeginTime)
    if duration <= 0 and prior then duration = tonumber(prior.duration) or 0 end
    if duration <= 0 and storedEndTime ~= math.huge then duration = math.max(0, storedEndTime - now) end

    targets[targetKey] = {
        beginTime=numericBeginTime, endTime=storedEndTime,
        duration=duration, unitTag=unitTag, unitName=displayTarget or unitName,
        account=BB.Context:ResolveAccount(unitTag,unitName), unitId=unitId,
        abilityId=abilityId, stackCount=stackCount,
    }
    if definition.showMissingPlayers and not hadAny then
        self.missingVisibleUntil[definition.key] = now + definition.missingWindow
    end
    return true
end

function Runtime:SynchronizePlayerEffects()
    if not self.enabled or not GetNumBuffs or not GetUnitBuffInfo then return end
    local now = EffectNow()
    local playerId = GetUnitId and GetUnitId("player") or nil
    local playerName = GetUnitName("player") or ""
    local targetKey, displayTarget = BB.Context:GetTargetKey("player", playerId, playerName, "BUFF")
    if not targetKey then return end

    -- Reconcile only the local player's records. Group-member state remains event-driven.
    for key,definition in pairs(BB.Registry.byKey) do
        if definition.effectType == "BUFF" and self.active[key] then
            self.active[key][targetKey] = nil
        end
    end

    local count = tonumber(GetNumBuffs("player")) or 0
    for index = 1, count do
        local effectName, beginTime, endTime, _, stackCount, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", index)
        local definition = BB.Registry:Resolve(effectName, abilityId)
        if definition and definition.effectType == "BUFF" and BB:IsEffectEnabled(definition.key) then
            local allowed = BB.Context:CanTrackEffect(definition, "player", playerId, playerName)
            if allowed then
                self:UpsertEffect(definition, targetKey, displayTarget, "player", playerName, playerId,
                    beginTime, endTime, stackCount, abilityId, now)
            end
        end
    end

    for key,definition in pairs(BB.Registry.byKey) do
        if definition.effectType == "BUFF" then
            self:RefreshEffect(key, now)
            self:UpdateUptimeState(key, now)
        end
    end
    if self:NeedsUpdate() then self:StartUpdate() else self:StopUpdate() end
end

function Runtime:OnEffectChanged(changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount,
        iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    if not self.enabled then return end
    local definition = BB.Registry:Resolve(effectName,abilityId)
    if not definition or not BB:IsEffectEnabled(definition.key) then return end
    local allowed = BB.Context:CanTrackEffect(definition,unitTag,unitId,unitName)
    if not allowed and changeType ~= EFFECT_RESULT_FADED then return end
    local targetKey,displayTarget = BB.Context:GetTargetKey(unitTag,unitId,unitName,definition.effectType)
    if not targetKey then return end
    local now = EffectNow()
    local targets = self.active[definition.key] or {}
    self.active[definition.key] = targets

    if changeType == EFFECT_RESULT_FADED then
        targets[targetKey] = nil
    elseif allowed then
        self:UpsertEffect(definition, targetKey, displayTarget, unitTag, unitName, unitId,
            beginTime, endTime, stackCount, abilityId, now)
    end

    self:RefreshEffect(definition.key,now)
    self:UpdateUptimeState(definition.key,now)
    if self:NeedsUpdate() then self:StartUpdate() else self:StopUpdate() end
end

function Runtime:GetSnapshot(key,now)
    now = now or EffectNow()
    local definition = BB.Registry.byKey[key]
    local targets = self.active[key] or {}
    local covered,maxEnd,maxDuration,targetName = 0,0,0,nil
    local coveredAccounts = {}
    for targetKey,data in pairs(targets) do
        if not data.endTime or data.endTime <= now then
            targets[targetKey]=nil
        else
            if definition.effectType == "BUFF" then
                covered=covered+1
                if data.account and data.account ~= "" then coveredAccounts[data.account]=true end
            end
            if data.endTime > maxEnd then
                maxEnd=data.endTime
                maxDuration=tonumber(data.duration) or 0
                targetName=data.unitName
            end
        end
    end
    local remaining=maxEnd==math.huge and 0 or math.max(0,maxEnd-now)
    local isActive=maxEnd>now
    local percent=0
    if isActive then percent=maxDuration>0 and zo_clamp((remaining/maxDuration)*100,0,100) or 100 end
    local target=0
    if definition.effectType=="BUFF" then
        target=BB:GetGroupTargetCount()
        if definition.coverageCap then target=math.min(target,definition.coverageCap) end
        covered=math.min(covered,target)
    end
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
    return {active=isActive,remaining=remaining,percent=percent,covered=covered,target=target,targetName=targetName,missingPlayers=missing}
end

function Runtime:RefreshEffect(key,now)
    local definition=BB.Registry.byKey[key]
    if not definition then return end
    if not BB:IsEffectEnabled(key) then self:ClearEffect(key); return end
    BB.UI:UpdateEffect(definition,self:GetSnapshot(key,now))
end

function Runtime:Update()
    if not self.enabled then self:StopUpdate(); return end
    local now=EffectNow()
    for key in pairs(self.active) do
        if BB:IsEffectEnabled(key) then
            self:RefreshEffect(key,now)
            self:UpdateUptimeState(key,now)
        end
    end
    BB.UI:RefreshAll(false)
    if not self:NeedsUpdate() then self:StopUpdate() end
end
