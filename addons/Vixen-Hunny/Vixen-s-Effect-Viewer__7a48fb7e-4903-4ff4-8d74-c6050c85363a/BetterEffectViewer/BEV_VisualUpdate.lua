local BEV = BetterEffectViewer

local function updateVisualSlot(self, slot, now, flashThreshold, flashColor, flashPulse)
    local effect = slot.effect
    if not effect then
        if slot.lastTimerText ~= "" then
            slot.timer:SetText("")
            slot.lastTimerText = ""
        end
        if slot.border then
            slot.border:SetEdgeColor(0, 0, 0, 0)
        end
        slot.wasFlashing = false
        return math.huge
    end

    local remaining = self:TimeRemaining(effect, now)
    local minRemaining = math.huge
    if not effect.isPermanent and remaining > 0 then
        minRemaining = remaining
    end

    local timerText = self:FormatTime(remaining, effect.isPermanent)
    if slot.lastTimerText ~= timerText then
        slot.timer:SetText(timerText)
        slot.lastTimerText = timerText
    end

    local borderBase = slot.baseBorderColor
    local timerBase = slot.baseTimerColor
    if (not borderBase) or (not timerBase) then
        borderBase, timerBase = self:GetColorsForEffect(effect)
        slot.baseBorderColor = borderBase
        slot.baseTimerColor = timerBase
    end

    local br, bg, bb, ba = self:UnpackColor(borderBase)
    local tr, tg, tb, ta = self:UnpackColor(timerBase)

    local shouldFlash = not effect.isPermanent
        and remaining ~= math.huge
        and remaining > 0
        and remaining <= flashThreshold

    if shouldFlash then
        local fr, fg, fb, fa = self:UnpackColor(flashColor)

        br = br + (fr - br) * flashPulse
        bg = bg + (fg - bg) * flashPulse
        bb = bb + (fb - bb) * flashPulse
        ba = ba + (fa - ba) * flashPulse

        tr = tr + (fr - tr) * flashPulse
        tg = tg + (fg - tg) * flashPulse
        tb = tb + (fb - tb) * flashPulse
        ta = ta + (fa - ta) * flashPulse

        slot.wasFlashing = true
    elseif not slot.wasFlashing then
        return minRemaining
    else
        slot.wasFlashing = false
    end

    if slot.border then
        slot.border:SetCenterColor(0, 0, 0, 0)
        slot.border:SetEdgeColor(br, bg, bb, ba)
    end
    slot.timer:SetColor(tr, tg, tb, ta)

    return minRemaining
end

function BEV:OnUpdate()
    if self.needsRedraw then
        self:Redraw()
        self.needsRedraw = false
    end

    local now = GetFrameTimeSeconds()
    local perfProfile = self:GetPerformanceProfile()

    if now >= (self.nextMaintenanceAt or 0) then
        self:UpdateLockedTarget(now)
        self:CleanupExpiredEffects(now)
        self.nextMaintenanceAt = now + perfProfile.maintenance
    end

    local hasReticleContext = self:HandleReticleState()
    if hasReticleContext then
        if self.fadeOut:IsPlaying() then
            self.fadeOut:Stop()
        end
        self.win:SetHidden(false)
        self.win:SetAlpha(1)
    elseif not self.win:IsHidden() and not self.fadeOut:IsPlaying() then
        self.fadeOut:PlayFromStart()
    end

    local rescanInterval = self.runtimeRescanInterval or self.sv.fallbackRescanInterval or self.defaults.fallbackRescanInterval

    if hasReticleContext and now >= (self.nextFallbackRescanAt or 0) then
        -- Fallback sync for effects that may not emit reliable EVENT_EFFECT_CHANGED updates.
        self:RescanReticleBuffs()
        self.nextFallbackRescanAt = now + rescanInterval
    end

    if now < (self.nextVisualUpdateAt or 0) then
        return
    end

    local nowMs = GetFrameTimeMilliseconds()
    local flashThreshold = self.sv.flashThreshold or self.defaults.flashThreshold
    local flashColor = self.sv.flashColor or self.defaults.flashColor
    local flashPulse = 0.5 + 0.5 * math.sin((nowMs / 150) % (2 * math.pi))
    local minTimedRemaining = math.huge

    if self.buffSlots and self.visibleBuffSlotCount then
        for i = 1, self.visibleBuffSlotCount do
            local slotMin = updateVisualSlot(self, self.buffSlots[i], now, flashThreshold, flashColor, flashPulse)
            if slotMin < minTimedRemaining then
                minTimedRemaining = slotMin
            end
        end
    end

    if self.debuffSlots and self.visibleDebuffSlotCount then
        for i = 1, self.visibleDebuffSlotCount do
            local slotMin = updateVisualSlot(self, self.debuffSlots[i], now, flashThreshold, flashColor, flashPulse)
            if slotMin < minTimedRemaining then
                minTimedRemaining = slotMin
            end
        end
    end

    if minTimedRemaining < 10 then
        self.nextVisualUpdateAt = now + perfProfile.visualFast
    elseif minTimedRemaining < math.huge then
        self.nextVisualUpdateAt = now + perfProfile.visualNormal
    else
        self.nextVisualUpdateAt = now + perfProfile.visualIdle
    end
end
