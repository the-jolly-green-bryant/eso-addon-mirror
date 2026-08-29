local BT = BerserkTracker

---------------------------------------------------------------------------
-- GET LINEAR GRADIENT
---------------------------------------------------------------------------
function BT.GetLinearColor(factor, ColorStart, ColorEnd)
    local f = math.max(0, math.min(1, factor))

    local midR = math.max(ColorStart[1], ColorEnd[1])
    local midG = math.max(ColorStart[2], ColorEnd[2])
    local midB = math.max(ColorStart[3], ColorEnd[3])
    local midA = (ColorStart[4] + ColorEnd[4]) / 2

    local r, g, b, a

    if f >= 0.5 then
        local p = (f - 0.5) * 2
        r = midR + (ColorStart[1] - midR) * p
        g = midG + (ColorStart[2] - midG) * p
        b = midB + (ColorStart[3] - midB) * p
        a = midA + (ColorStart[4] - midA) * p
    else
        local p = f * 2
        r = ColorEnd[1] + (midR - ColorEnd[1]) * p
        g = ColorEnd[2] + (midG - ColorEnd[2]) * p
        b = ColorEnd[3] + (midB - ColorEnd[3]) * p
        a = ColorEnd[4] + (midA - ColorEnd[4]) * p
    end

    return {r or 1, g or 1, b or 1, a or 1}
end

---------------------------------------------------------------------------
-- CALCULATE UPTIME COLOR
---------------------------------------------------------------------------
function BT.GetPercentageColor(percentage)
    local p = math.max(0, math.min(100, percentage)) / 100
    local r, g = 0, 0

    if p >= 0.75 then
        r, g = (1 - p) / 0.25 * 0.5, 1.0
    elseif p >= 0.50 then
        r, g = 0.5 + (0.75 - p) / 0.25 * 0.5, 1.0
    elseif p >= 0.25 then
        r, g = 1.0, 0.5 + (p - 0.25) / 0.25 * 0.5
    else
        r, g = 1.0, p / 0.25 * 0.5
    end

    return { r, g, 0, 1 }
end

---------------------------------------------------------------------------
-- SEND CHAT SUMMARY AFTER COMBAT
---------------------------------------------------------------------------
function BT.SendChatSummary()
    if not BT.SV.isEnabledChat then return end
    if BT.timeFightStart == 0 then return end

    local durationFightMs = GetGameTimeMilliseconds() - BT.timeFightStart
    local durationFightSec = durationFightMs / 1000

    if durationFightSec < BT.SV.minFightTime then return end
    local minutes = math.floor(durationFightSec / 60)
    local seconds = math.floor(durationFightSec % 60)
    local formattedTime = string.format("%d:%02dmin", minutes, seconds)

    local r, g, b = unpack(BT.GetPercentageColor(BT.uptimePercentage))
    local hexColor = string.format("%02x%02x%02x", r * 255, g * 255, b * 255)

    d(string.format("|cFF7F00[Major Berserk]|r |cFFFFFFUptime:|r |c%s%.1f%%|r |cFFFFFF- Fight: %s|r", hexColor, BT.uptimePercentage, formattedTime))
end

---------------------------------------------------------------------------
-- SCENE CHANGE
---------------------------------------------------------------------------
function BT.OnStateChange(oldState, newState)
    if newState == SCENE_SHOWN then
        BT.UpdateVisibility()
    elseif newState == SCENE_HIDING then
        if not BT.isPreview then
            BT.PARENT:SetHidden(true)
        end
    end
end

---------------------------------------------------------------------------
-- MANAGE UPDATE LOOP
---------------------------------------------------------------------------
function BT.ManageUpdateLoop()
    if BT.isActive or BT.isCombat or BT.isPreview then
        EVENT_MANAGER:RegisterForUpdate(BT.NAME .. "OnUpdate", BT.TIME_UPDATE, BT.OnUpdateHandler)
    else
        EVENT_MANAGER:UnregisterForUpdate(BT.NAME .. "OnUpdate")
    end
end

---------------------------------------------------------------------------
-- GET CURRENT BUFFS
---------------------------------------------------------------------------
function BT.CheckCurrentBuffs()
    local found = false
    local endTime = 0
    local newReference = 0
    local currentTime = GetGameTimeMilliseconds()

    for i = 1, GetNumBuffs("player") do
        local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId = GetUnitBuffInfo("player", i)
        if abilityId == BT.MAJOR_BERSERK_ID then
            local endTimeMs = timeEnding * 1000
            if timeEnding == 0 or endTimeMs > currentTime then
                found = true
                endTime = endTimeMs
                newReference = endTimeMs - (timeStarted * 1000)
                break
            end
        end
    end

    if found then
        BT.isActive = true
        BT.endTime = endTime
        BT.referenceDuration = newReference
        BT.hadBuffBefore = true
    else
        BT.isActive = false
    end

    BT.ManageUpdateLoop()
    BT.UpdateVisuals()
end

---------------------------------------------------------------------------
-- VISIBILITY
---------------------------------------------------------------------------
function BT.UpdateVisibility()
    if BT.isPreview then
        BT.PARENT:SetHidden(false)
        return
    end

    local isHidden = not (SCENE_MANAGER:GetScene("hud"):IsShowing() or SCENE_MANAGER:GetScene("hudui"):IsShowing())
    if isHidden then
        BT.PARENT:SetHidden(true)
        return
    end

    BT.groupRole = GetGroupMemberSelectedRole("player")

    local roleSettings = {
        [0] = BT.SV.isEnabledSolo,
        [1] = BT.SV.isEnabledDPS,
        [2] = BT.SV.isEnabledTank,
        [4] = BT.SV.isEnabledHeal
    }

    local roleEnabled = BT.SV.enableAddon and (roleSettings[BT.groupRole] == true)

    if not roleEnabled then
        BT.PARENT:SetHidden(true)
        return
    end

    local shouldShow = true

    if BT.SV.visibilityMode == 2 then
        -- SHOW IN COMBAT
        if not BT.isCombat and not BT.isActive then
            shouldShow = false
        end
    elseif BT.SV.visibilityMode == 3 then
        -- ONLY SHOW ACTIVE BUFF
        if not BT.isActive then
            shouldShow = false
        end
    end

    BT.PARENT:SetHidden(not shouldShow)
end

---------------------------------------------------------------------------
-- ANIMATION
---------------------------------------------------------------------------
function BT.PlayAnimation()
    if BT.isAnimationActive then return end
    BT.isAnimationActive = true

    local durationGrow = math.floor(BT.SV.animationDuration / 3)
    local durationShrink = BT.SV.animationDuration - durationGrow

    -- CREATE TIMELINE IF MISSING
    if not BT.TIMELINE then
        BT.TIMELINE = ANIMATION_MANAGER:CreateTimeline()

        BT.ANIMATION_SCALEUP = BT.TIMELINE:InsertAnimation(ANIMATION_SCALE, BT.DURATION, 0)
        BT.ANIMATION_SCALEUP:SetEasingFunction(ZO_EaseInQuadratic)

        BT.ANIMATION_SCALEDOWN = BT.TIMELINE:InsertAnimation(ANIMATION_SCALE, BT.DURATION, 0)
        BT.ANIMATION_SCALEDOWN:SetEasingFunction(ZO_EaseOutQuadratic)

        BT.TIMELINE:SetHandler('OnStop', function()
            BT.DURATION:SetScale(1.0)
            BT.isAnimationActive = false
        end)
    end

    if BT.TIMELINE:IsPlaying() then BT.TIMELINE:Stop() end

    BT.ANIMATION_SCALEUP:SetScaleValues(1.0, BT.SV.animationScale / 100)
    BT.ANIMATION_SCALEUP:SetDuration(durationGrow)

    BT.ANIMATION_SCALEDOWN:SetScaleValues(BT.SV.animationScale / 100, 1.0)
    BT.ANIMATION_SCALEDOWN:SetDuration(durationShrink)
    BT.TIMELINE:SetAnimationOffset(BT.ANIMATION_SCALEDOWN, durationGrow)

    BT.TIMELINE:PlayFromStart()
end

---------------------------------------------------------------------------
-- VISUAL UPDATE
---------------------------------------------------------------------------
function BT.UpdateVisuals()
    local currentTime = GetGameTimeMilliseconds()
    local remainingTime = 0

    if BT.isActive then
        remainingTime = math.max(0, (BT.endTime - currentTime) / 1000)
    end

    local ColorBackground = BT.SV.ColorIdle
    local ColorText = BT.SV.isStaticTimer and BT.SV.ColorStaticTimer or BT.SV.ColorIdle

    if BT.isActive and remainingTime > 0 then
        local factor = 1
        if BT.SV.colorThreshold > 0 then
            factor = remainingTime / BT.SV.colorThreshold
        end

        local ColorGradient = BT.GetLinearColor(factor, BT.SV.ColorStart, BT.SV.ColorEnd)
        ColorBackground = ColorGradient

        if not BT.SV.isStaticTimer then
            ColorText = ColorGradient
        end
    else
        if BT.isCombat and BT.hadBuffBefore then
            ColorBackground = BT.SV.ColorEnd
            if not BT.SV.isStaticTimer then
                ColorText = BT.SV.ColorEnd
            end
        end
    end

    -- BACKGROUND
    BT.BG:SetCenterColor(unpack(ColorBackground))

    if BT.SV.edgeThickness == 0 then
        BT.BG:SetEdgeColor(0, 0, 0, 0)
    else
        BT.BG:SetEdgeColor(0, 0, 0, 1)
    end

    -- TEXT
    if BT.isActive and remainingTime > 0 then
        local stringTime = (remainingTime <= BT.SV.thresholdDecimal) and "%.1f" or "%.0f"
        BT.DURATION:SetText(string.format(stringTime, remainingTime))
    else
        BT.DURATION:SetText("0.0")
    end

    -- TEXT COLOR
    local r, g, b, a = unpack(ColorText)
    if not BT.hadBuffBefore and not BT.isPreview then a = 2/3 end
    BT.DURATION:SetColor(r, g, b, a)

    -- UPTIME LABEL
    BT.UPTIME_LABEL:SetHidden(BT.SV.isHideUptime)
    BT.UPTIME_LABEL:SetText(string.format("%.0f%%", BT.uptimePercentage))
    BT.UPTIME_LABEL:SetColor(unpack(BT.SV.textColorUptime))
    BT.UPTIME_LABEL:SetScale(1)

    BT.BG:SetHidden(not BT.SV.isShowBackground)
    BT.ICON:SetHidden(not BT.SV.isShowBackground)

    BT.UpdateVisibility()
end

---------------------------------------------------------------------------
-- LOOP
---------------------------------------------------------------------------
function BT.OnUpdateHandler()
    if BT.isPreview then return end

    local currentTime = GetGameTimeMilliseconds()

    -- UPTIME TRACKING
    if BT.isCombat then
        local delta = currentTime - BT.timeFightUpdate
        BT.timeFightUpdate = currentTime

        if BT.isActive then
            BT.timeActive = BT.timeActive + delta
        end

        local duration = currentTime - BT.timeFightStart
        if duration > 0 then
            BT.uptimePercentage = (BT.timeActive / duration) * 100
        else
            BT.uptimePercentage = 0
        end
    end

    if BT.isActive and currentTime > BT.endTime then
        BT.isActive = false
        BT.endTime = 0
        BT.ManageUpdateLoop()
    end

    BT.UpdateVisuals()
end

---------------------------------------------------------------------------
-- EFFECT CHANGED
---------------------------------------------------------------------------
function BT.OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceUnitType)
    if abilityId ~= BT.MAJOR_BERSERK_ID then return end

    if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
        local currentTime = GetGameTimeMilliseconds()
        local endTimeMs = endTime * 1000
        local beginTimeMs = beginTime * 1000

        if endTime == 0 or endTimeMs > currentTime then
            local shouldAnimate = false
            local oldRemaining = math.max(0, BT.endTime - currentTime)

            if endTime == 0 then
                if currentTime - BT.lastAnimationTime > 5000 then
                    shouldAnimate = true
                end
            else
                local threshold = BT.referenceDuration * 0.5
                if oldRemaining <= threshold then
                    shouldAnimate = true
                end

                BT.referenceDuration = endTimeMs - beginTimeMs
            end

            BT.isActive = true
            BT.endTime = endTimeMs
            BT.hadBuffBefore = true

            if shouldAnimate then
                BT.PlayAnimation()
                BT.lastAnimationTime = currentTime
            end

            BT.ManageUpdateLoop()
            BT.UpdateVisuals()
        end
    elseif changeType == EFFECT_RESULT_FADED then
        BT.isActive = false
        BT.ManageUpdateLoop()
        BT.UpdateVisuals()
    end
end

---------------------------------------------------------------------------
-- COMBAT STATE
---------------------------------------------------------------------------
function BT.OnCombatState()
    BT.isCombat = IsUnitInCombat("player")
    BT.isPreview = false

    if BT.PARENT then
        BT.PARENT:SetMovable(not BT.SV.isLocked)
        BT.PARENT:SetMouseEnabled(not BT.SV.isLocked)
    end

    if BT.isCombat then
        local currentTime = GetGameTimeMilliseconds()
        BT.timeFightStart = currentTime
        BT.timeFightUpdate = currentTime
        BT.timeActive = 0
        BT.uptimePercentage = 0
    else
        BT.SendChatSummary()
        BT.hadBuffBefore = false
    end

    BT.CheckCurrentBuffs()
end

---------------------------------------------------------------------------
-- PLAYER ACTIVATED (RELOAD / ZONE CHANGE)
---------------------------------------------------------------------------
function BT.OnPlayerActivated()
    BT.OnCombatState()
end

---------------------------------------------------------------------------
-- ENABLE
---------------------------------------------------------------------------
function BT.Enable()
    SCENE_MANAGER:GetScene("hud"):RegisterCallback("StateChange", BT.OnStateChange)
    SCENE_MANAGER:GetScene("hudui"):RegisterCallback("StateChange", BT.OnStateChange)

    EVENT_MANAGER:RegisterForEvent(BT.NAME, EVENT_PLAYER_ACTIVATED, BT.OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(BT.NAME, EVENT_PLAYER_COMBAT_STATE, BT.OnCombatState)
    EVENT_MANAGER:RegisterForEvent(BT.NAME, EVENT_EFFECT_CHANGED, BT.OnEffectChanged)
    EVENT_MANAGER:RegisterForEvent(BT.NAME, EVENT_GROUP_MEMBER_ROLE_CHANGED, BT.UpdateVisibility)

    EVENT_MANAGER:AddFilterForEvent(BT.NAME, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
    EVENT_MANAGER:AddFilterForEvent(BT.NAME, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, BT.MAJOR_BERSERK_ID)

    BT.OnCombatState()
    BT.isLoaded = true
end

---------------------------------------------------------------------------
-- DISABLE
---------------------------------------------------------------------------
function BT.Disable()
    SCENE_MANAGER:GetScene("hud"):UnregisterCallback("StateChange", BT.OnStateChange)
    SCENE_MANAGER:GetScene("hudui"):UnregisterCallback("StateChange", BT.OnStateChange)

    EVENT_MANAGER:UnregisterForEvent(BT.NAME, EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:UnregisterForEvent(BT.NAME, EVENT_PLAYER_COMBAT_STATE)
    EVENT_MANAGER:UnregisterForEvent(BT.NAME, EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(BT.NAME, EVENT_GROUP_MEMBER_ROLE_CHANGED)
    EVENT_MANAGER:UnregisterForUpdate(BT.NAME .. "OnUpdate")

    BT.PARENT:SetHidden(true)
    BT.isActive = false
    BT.endTime = 0
    BT.lastAnimationTime = 0
    BT.isLoaded = false
end