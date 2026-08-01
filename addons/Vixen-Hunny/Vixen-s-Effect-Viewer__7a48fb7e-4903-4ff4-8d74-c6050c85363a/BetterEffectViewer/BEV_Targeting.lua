local BEV = BetterEffectViewer

function BEV:RescanReticleBuffs()
    self:ResetEffects()

    local unitTag = self:ResolveReticleUnitTag()
    if not unitTag then
        self:Redraw()
        return
    end

    local now = GetFrameTimeSeconds()
    local index = 1
    while true do
        local name, startTime, endTime, buffSlot, stackCount, iconName,
            buffType, effectType, abilityType, statusEffectType, abilityId = GetUnitBuffInfo(unitTag, index)

        if not name or name == "" then
            break
        end

        local effect = self:BuildEffect(
            name,
            abilityId,
            iconName,
            effectType,
            buffType,
            startTime,
            endTime,
            stackCount,
            statusEffectType,
            nil
        )

        self:UpsertEffect(effect, now)
        index = index + 1
    end

    self:Redraw()
end

function BEV:HandleReticleState()
    local unitTag = self:ResolveReticleUnitTag()

    if unitTag then
        self.lastReticleUnitTag = unitTag
        self.reticleLostTime = 0
        return true
    end

    if self.lastReticleUnitTag then
        if self.reticleLostTime == 0 then
            self.reticleLostTime = GetFrameTimeSeconds()
        end

        if GetFrameTimeSeconds() - self.reticleLostTime < self.reticleHoldDuration then
            return true
        end

        self.lastReticleUnitTag = nil
        self.currentReticleKey = nil
        self:ResetEffects()
        return false
    end

    return false
end

function BEV:OnReticleTargetChanged()
    local unitTag = self:ResolveReticleUnitTag()
    self:UpdateTargetName(unitTag)

    if not unitTag then
        self.currentReticleKey = nil
        self:ResetEffects()
        self.needsRedraw = true
        return
    end

    local unitId = (GetUnitId ~= nil and GetUnitId(unitTag)) or 0
    local reticleKey = unitTag .. ":" .. unitId
    if reticleKey == self.currentReticleKey then
        return
    end

    self.currentReticleKey = reticleKey
    self:RescanReticleBuffs()
end

function BEV:UpdateLockedTarget(now)
    local unitTag = self:ResolveReticleUnitTag()
    if not unitTag then
        return
    end
    if not IsUnitAttackable(unitTag) then
        return
    end

    local name = GetUnitName(unitTag)
    if name ~= self.lockedTargetName then
        if self.pendingTarget ~= name then
            self.pendingTarget = name
            self.pendingTime = now
            return
        end

        if now - self.pendingTime >= self.targetSwitchDelay then
            self.lockedTargetName = name
            self.pendingTarget = nil

            self:ResetEffects()
            self:RescanReticleBuffs()
            self:UpdateTargetName(unitTag)
        end
    end
end

function BEV:IsPvPZone()
    if IsActiveWorldBattleground() then
        return true
    end

    local zoneId = GetZoneId(GetUnitZoneIndex("player"))
    local pvpZones = {
        [584] = true,
        [643] = true,
    }

    return pvpZones[zoneId]
end

function BEV:ApplyCurrentLayout()
    local layout
    if self:IsPvPZone() then
        layout = self.sv.pvpLayout
    else
        layout = self.sv.pveLayout
    end

    self.iconSize = layout.iconSize
    self.maxCols = layout.maxCols
    if self.runtimeMaxColsCap and self.maxCols > self.runtimeMaxColsCap then
        self.maxCols = self.runtimeMaxColsCap
    end

    self.sv.fontSize = layout.fontSize

    self:UpdateSlotLayout()
    self:ApplyFontSettings()
    self:Redraw()
end
