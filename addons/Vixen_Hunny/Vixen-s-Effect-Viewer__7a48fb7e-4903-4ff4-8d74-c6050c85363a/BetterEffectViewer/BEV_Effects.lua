local BEV = BetterEffectViewer

function BEV:AutoDetectImportantEffect(effect)
    if not self.sv.autoWhitelist then
        return
    end
    if self.sv.filterMode ~= "whitelist" then
        return
    end

    local duration = 0
    if effect.endTime and effect.startTime then
        duration = effect.endTime - effect.startTime
    end

    if duration >= self.sv.autoWhitelistDuration then
        self.sv.whitelist[effect.abilityId] = true
    end
end

function BEV:SortEffects(list, now)
    local mode = self.sv.sortMode
    local t = now or GetFrameTimeSeconds()

    if mode == "shortest" then
        table.sort(list, function(a, b)
            return self:TimeRemaining(a, t) < self:TimeRemaining(b, t)
        end)
    elseif mode == "longest" then
        table.sort(list, function(a, b)
            return self:TimeRemaining(a, t) > self:TimeRemaining(b, t)
        end)
    elseif mode == "newest" then
        table.sort(list, function(a, b)
            return a.startTime > b.startTime
        end)
    elseif mode == "oldest" then
        table.sort(list, function(a, b)
            return a.startTime < b.startTime
        end)
    end
end

function BEV:ResetEffects()
    self.effects = {}
    self.effectCount = 0
end

function BEV:CleanupExpiredEffects(now)
    local t = now or GetFrameTimeSeconds()

    for key, effect in pairs(self.effects) do
        if effect.endTime ~= 0 and effect.endTime ~= nil then
            if t > effect.endTime + 0.5 then
                self.effects[key] = nil
                self.effectCount = math.max(0, (self.effectCount or 0) - 1)
            end
        elseif t - effect.lastSeen > 10 then
            self.effects[key] = nil
            self.effectCount = math.max(0, (self.effectCount or 0) - 1)
        end
    end
end

function BEV:IsEffectAllowed(abilityId)
    if self.sv.filterMode == "none" then
        return true
    end

    if self.sv.filterMode == "whitelist" then
        return self.sv.whitelist[abilityId] == true
    end

    if self.sv.filterMode == "blacklist" then
        return not self.sv.blacklist[abilityId]
    end

    return true
end

function BEV:UpsertEffect(effect, now)
    self:AutoDetectImportantEffect(effect)

    if not self:IsEffectAllowed(effect.abilityId) then
        return
    end

    local t = now or GetFrameTimeSeconds()
    local existing = self.effects[effect.key]

    if existing then
        existing.name = effect.name
        existing.abilityId = effect.abilityId
        existing.iconName = effect.iconName
        existing.effectType = effect.effectType
        existing.buffType = effect.buffType
        existing.startTime = effect.startTime
        existing.stackCount = effect.stackCount
        existing.endTime = effect.endTime
        existing.statusEffectType = effect.statusEffectType
        existing.sourceType = effect.sourceType
        existing.isPermanent = effect.isPermanent
        existing.lastSeen = t
        return
    end

    if self.runtimeEffectCap and (self.effectCount or 0) >= self.runtimeEffectCap then
        return
    end

    effect.lastSeen = t
    self.effects[effect.key] = effect
    self.effectCount = (self.effectCount or 0) + 1
end

function BEV:RemoveEffectByKey(key)
    if self.effects[key] ~= nil then
        self.effects[key] = nil
        self.effectCount = math.max(0, (self.effectCount or 0) - 1)
    end
end

function BEV:GetColorsForEffect(effect)
    if self:IsPlayerApplied(effect) then
        return self.sv.playerEffectBorderColor, self.sv.buffTimerColor
    end

    if effect.isPermanent then
        return self.sv.permanentBorderColor, self.sv.permanentTimerColor
    elseif effect.effectType == BUFF_EFFECT_TYPE_BUFF then
        return self.sv.buffBorderColor, self.sv.buffTimerColor
    end

    return self.sv.debuffBorderColor, self.sv.debuffTimerColor
end

function BEV:GetRequiredRows(effectCount)
    local cols = self.maxCols
    local rows = math.ceil(effectCount / cols)

    if rows < self.minRows then
        rows = self.minRows
    end

    return rows
end

function BEV:IsPlayerApplied(effect)
    return effect.sourceType == BUFF_EFFECT_SOURCE_TYPE_PLAYER
end
