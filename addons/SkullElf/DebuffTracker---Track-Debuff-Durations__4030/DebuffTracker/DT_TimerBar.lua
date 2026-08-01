-- DT_TimerBar.lua

DT_TimerBar = ZO_TimerBar:Subclass()

function DT_TimerBar:Initialize(control)
    ZO_TimerBar.Initialize(self, control)

    self.stackText = control:GetNamedChild("Stack")
    self.unitLabel = control:GetNamedChild("Label")
    self.blinkThreshold = 2
    self.useGradient = true
    self.decimalPrecision = 1

    self.control = control
    self.status = control:GetNamedChild("Status")
    self.time = control:GetNamedChild("Time")

    -- Optional: support fade out animation
    self.fadeDuration = 0.25
    self.animation = ZO_AlphaAnimation:New(control)
end

function DT_TimerBar:SetStackCount(stackCount)
    if self.stackText then
        if stackCount > 1 then
            self.stackText:SetText("x" .. stackCount)
        else
            self.stackText:SetText("")
        end
    end
end

function DT_TimerBar:SetUnitName(name)
    if self.unitLabel then
        self.unitLabel:SetText(name)
    end
end

function DT_TimerBar:SetGradientEnabled(enabled)
    self.useGradient = enabled
end

function DT_TimerBar:SetDecimalPrecision(precision)
    self.decimalPrecision = precision or 1
end

function DT_TimerBar:SetAlpha(alpha)
    if self.control then
        self.control:SetAlpha(alpha)
    end
end

function DT_TimerBar:Update(time)
    if time > self.ends then
        self:Stop()
        return
    end

    local totalRemaining = self.ends - time
    local totalElapsed = time - self.starts - (self.pauseElapsed or 0)
    local updateBar = time > (self.nextBarUpdate or 0)
    local updateLabel = self.time and time > (self.nextLabelUpdate or 0)

    if updateBar and self.status then
        self.status:SetMinMax(0, self.ends - self.starts)
        if self.direction == TIMER_BAR_COUNTS_UP then
            self.status:SetValue(totalElapsed)
        else
            self.status:SetValue(totalRemaining)
        end

        -- Gradient color logic
        if self.useGradient then
            local progress = zo_clamp(totalRemaining / (self.ends - self.starts), 0, 1)
            local r = 1 - progress
            local g = progress
            self.status:SetColor(r, g, 0, 1)
        end

        -- Blink effect if near expiration
        if self.control then
            local alpha = 1
            if totalRemaining <= self.blinkThreshold then
                local flicker = math.floor(GetFrameTimeMilliseconds() / 200) % 2
                alpha = (flicker == 0) and 1 or 0
            end
            self.control:SetAlpha(alpha)
        end

        self.nextBarUpdate = time + (self.barUpdateInterval or 0.02)
    end

    if updateLabel and self.time then
        local timeStr = string.format("%." .. self.decimalPrecision .. "f", totalRemaining)
        self.time:SetText(timeStr)
        self.nextLabelUpdate = time + 0.1
    end
end

function DT_TimerBar:Stop()
    if not self:IsStarted() then return end

    self.control:SetHandler("OnUpdate", nil)

    if self.animation then
        self.animation:FadeOut(0, self.fadeDuration, ZO_ALPHA_ANIMATION_OPTION_USE_CURRENT_ALPHA, function()
            self.control:SetAlpha(1)
            self.control:SetHidden(true)
        end)
    else
        self.control:SetHidden(true)
    end

    self.running = false
    self.starts = nil
    self.ends = nil
    self.paused = nil
    self.pauseElapsed = nil
end
