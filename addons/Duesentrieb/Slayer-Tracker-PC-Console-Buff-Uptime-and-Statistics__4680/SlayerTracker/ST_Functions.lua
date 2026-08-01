local ST = SlayerTracker

---------------------------------------------------------------------------
-- GET LINEAR GRADIENT
---------------------------------------------------------------------------
function ST.GetLinearColor(factor, ColorStart, ColorEnd)
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
function ST.GetPercentageColor(percentage)
    local p = math.max(0, math.min(100, percentage)) / 100
    local r, g = 0, 0

    if p >= 0.75 then
        r = (1 - p) / 0.25 * 0.5
        g = 1.0
    elseif p >= 0.50 then
        r = 0.5 + (0.75 - p) / 0.25 * 0.5
        g = 1.0
    elseif p >= 0.25 then
        r = 1.0
        g = 0.5 + (p - 0.25) / 0.25 * 0.5
    else
        r = 1.0
        g = p / 0.25 * 0.5
    end

    return {r, g, 0, 1}
end

---------------------------------------------------------------------------
-- SEND CHAT SUMMARY AFTER COMBAT
---------------------------------------------------------------------------
function ST.SendChatSummary()
    if not ST.SV.isEnabledChat then return end
    if ST.timeFightStart == 0 then return end

    local durationFightMs = GetGameTimeMilliseconds() - ST.timeFightStart
    local durationFightSec = durationFightMs / 1000

    if durationFightSec < ST.SV.minFightTime then return end
    local minutes = math.floor(durationFightSec / 60)
    local seconds = math.floor(durationFightSec % 60)
    local formattedTime = string.format("%d:%02dmin", minutes, seconds)

    local r, g, b = unpack(ST.GetPercentageColor(ST.uptimePercentage))
    local hexColor = string.format("%02x%02x%02x", r * 255, g * 255, b * 255)

    d(string.format("|cFF7F00[Major Slayer]|r |cFFFFFFUptime:|r |c%s%.1f%%|r |cFFFFFF- Fight: %s|r", hexColor, ST.uptimePercentage, formattedTime))
end

---------------------------------------------------------------------------
-- SCENE CHANGE
---------------------------------------------------------------------------
function ST.OnStateChange(oldState, newState)
    if newState == SCENE_SHOWN then
        -- ST.isPreview = false
        ST.UpdateVisibility()
    elseif newState == SCENE_HIDING then
        if not ST.isPreview then
            ST.PARENT:SetHidden(true)
        end
    end
end

---------------------------------------------------------------------------
-- MANAGE UPDATE LOOP
---------------------------------------------------------------------------
function ST.ManageUpdateLoop()
    if ST.isActive or ST.isCombat or ST.isPreview then
        EVENT_MANAGER:RegisterForUpdate(ST.NAME .. "Update", ST.TIME_UPDATE, ST.OnUpdateHandler)
    else
        EVENT_MANAGER:UnregisterForUpdate(ST.NAME .. "Update")
    end
end

---------------------------------------------------------------------------
-- GET CURRENT BUFFS
---------------------------------------------------------------------------
function ST.CheckCurrentBuffs()
    local found = false
    local endTime = 0
    local newReference = 0
    local currentTime = GetGameTimeMilliseconds()

    for i = 1, GetNumBuffs("player") do
        local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId = GetUnitBuffInfo("player", i)
        if abilityId == ST.MAJOR_SLAYER_ID then
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
        ST.isActive = true
        ST.endTime = endTime
        ST.referenceDuration = newReference
        ST.hadBuffBefore = true
    else
        ST.isActive = false
    end

    ST.ManageUpdateLoop()
    ST.UpdateVisuals()
end

---------------------------------------------------------------------------
-- VISIBILITY
---------------------------------------------------------------------------
function ST.UpdateVisibility()
    if ST.isPreview then
        ST.PARENT:SetHidden(false)
        return
    end

    local isHidden = not (SCENE_MANAGER:GetScene("hud"):IsShowing() or SCENE_MANAGER:GetScene("hudui"):IsShowing())
    if isHidden then
        ST.PARENT:SetHidden(true)
        return
    end

    ST.groupRole = GetGroupMemberSelectedRole("player")

    local roleSettings = {
        [0] = ST.SV.isEnabledSolo,
        [1] = ST.SV.isEnabledDPS,
        [2] = ST.SV.isEnabledTank,
        [4] = ST.SV.isEnabledHeal
    }

    local roleEnabled = ST.SV.enableAddon and (roleSettings[ST.groupRole] == true)

    if not roleEnabled then
        ST.PARENT:SetHidden(true)
        return
    end

    local shouldShow = true

    if ST.SV.visibilityMode == 2 then
        -- SHOW IN COMBAT
        if not ST.isCombat and not ST.isActive then
            shouldShow = false
        end
    elseif ST.SV.visibilityMode == 3 then
        -- ONLY SHOW ACTIVE BUFF
        if not ST.isActive then
            shouldShow = false
        end
    end

    ST.PARENT:SetHidden(not shouldShow)
end

---------------------------------------------------------------------------
-- ANIMATION
---------------------------------------------------------------------------
function ST.PlayAnimation()
    if ST.isAnimationActive then return end
    ST.isAnimationActive = true

    local durationGrow = math.floor(ST.SV.animationDuration / 3)
    local durationShrink = ST.SV.animationDuration - durationGrow

    -- CREATE TIMELINE IF MISSING
    if not ST.TIMELINE then
        ST.TIMELINE = ANIMATION_MANAGER:CreateTimeline()

        ST.ANIMATION_SCALEUP = ST.TIMELINE:InsertAnimation(ANIMATION_SCALE, ST.DURATION, 0)
        ST.ANIMATION_SCALEUP:SetEasingFunction(ZO_EaseInQuadratic)

        ST.ANIMATION_SCALEDOWN = ST.TIMELINE:InsertAnimation(ANIMATION_SCALE, ST.DURATION, 0)
        ST.ANIMATION_SCALEDOWN:SetEasingFunction(ZO_EaseOutQuadratic)

        ST.TIMELINE:SetHandler('OnStop', function()
            ST.DURATION:SetScale(1.0)
            ST.isAnimationActive = false
        end)
    end

    if ST.TIMELINE:IsPlaying() then ST.TIMELINE:Stop() end

    ST.ANIMATION_SCALEUP:SetScaleValues(1.0, ST.SV.animationScale / 100)
    ST.ANIMATION_SCALEUP:SetDuration(durationGrow)

    ST.ANIMATION_SCALEDOWN:SetScaleValues(ST.SV.animationScale / 100, 1.0)
    ST.ANIMATION_SCALEDOWN:SetDuration(durationShrink)
    ST.TIMELINE:SetAnimationOffset(ST.ANIMATION_SCALEDOWN, durationGrow)

    ST.TIMELINE:PlayFromStart()
end

---------------------------------------------------------------------------
-- VISUAL UPDATE
---------------------------------------------------------------------------
function ST.UpdateVisuals()
    local currentTime = GetGameTimeMilliseconds()
    local remainingTime = 0

    if ST.isActive then
        remainingTime = math.max(0, (ST.endTime - currentTime) / 1000)
    end

    local ColorBackground = ST.SV.ColorIdle
    local ColorText = ST.SV.isStaticTimer and ST.SV.ColorStaticTimer or ST.SV.ColorIdle

    if ST.isActive and remainingTime > 0 then
        local factor = 1
        if ST.SV.colorThreshold > 0 then
            factor = remainingTime / ST.SV.colorThreshold
        end

        local ColorGradient = ST.GetLinearColor(factor, ST.SV.ColorStart, ST.SV.ColorEnd)
        ColorBackground = ColorGradient

        if not ST.SV.isStaticTimer then
            ColorText = ColorGradient
        end
    else
        if ST.isCombat and ST.hadBuffBefore then
            ColorBackground = ST.SV.ColorEnd
            if not ST.SV.isStaticTimer then
                ColorText = ST.SV.ColorEnd
            end
        end
    end

    -- BACKGROUND
    ST.BG:SetCenterColor(unpack(ColorBackground))

    if ST.SV.edgeThickness == 0 then
        ST.BG:SetEdgeColor(0, 0, 0, 0)
    else
        ST.BG:SetEdgeColor(0, 0, 0, 1)
    end

    -- TEXT
    if ST.isActive and remainingTime > 0 then
        local stringTime = (remainingTime <= ST.SV.thresholdDecimal) and "%.1f" or "%.0f"
        ST.DURATION:SetText(string.format(stringTime, remainingTime))
    else
        ST.DURATION:SetText("0.0")
    end

    -- TEXT COLOR
    local r, g, b, a = unpack(ColorText)
    if not ST.hadBuffBefore and not ST.isPreview then a = 2/3 end
    ST.DURATION:SetColor(r, g, b, a)

    -- UPTIME LABEL
    ST.UPTIME_LABEL:SetHidden(ST.SV.isHideUptime)
    ST.UPTIME_LABEL:SetText(string.format("%.0f%%", ST.uptimePercentage))
    ST.UPTIME_LABEL:SetColor(unpack(ST.SV.textColorUptime))

    -- EXPECTED SECONDS
    local showExpSec = (not ST.SV.isHideExpSec) and (ST.isWearingSlayerSet or ST.isPreview)
    ST.EXPSEC_LABEL:SetHidden(not showExpSec)

    if showExpSec then
        local currentUlt = GetUnitPower("player", POWERTYPE_ULTIMATE)
        local expectedSeconds = math.floor(currentUlt / 10)
        ST.EXPSEC_LABEL:SetText(string.format("%d", expectedSeconds))

        if ST.isActiveSlayerBar or ST.isPreview then
            ST.EXPSEC_LABEL:SetColor(unpack(ST.SV.textColorExpSec))
        else
            ST.EXPSEC_LABEL:SetColor(1, 1, 1, 1)
        end
    end

    ST.BG:SetHidden(not ST.SV.isShowBackground)
    ST.ICON:SetHidden(not ST.SV.isShowBackground)

    -- SCALE DOWN TEXT IF BOTH ACTIVE
    if not ST.SV.isHideUptime and showExpSec then
        ST.UPTIME_LABEL:SetScale(0.90)
        ST.EXPSEC_LABEL:SetScale(0.90)
    else
        ST.UPTIME_LABEL:SetScale(1)
        ST.EXPSEC_LABEL:SetScale(1)
    end

    ST.UpdateVisibility()
end

---------------------------------------------------------------------------
-- LOOP
---------------------------------------------------------------------------
function ST.OnUpdateHandler()
    if ST.isPreview then return end

    local currentTime = GetGameTimeMilliseconds()

    -- UPTIME TRACKING
    if ST.isCombat then
        local delta = currentTime - ST.timeFightUpdate
        ST.timeFightUpdate = currentTime

        if ST.isActive then
            ST.timeActive = ST.timeActive + delta
        end

        local duration = currentTime - ST.timeFightStart
        if duration > 0 then
            ST.uptimePercentage = (ST.timeActive / duration) * 100
        else
            ST.uptimePercentage = 0
        end
    end

    if ST.isActive and currentTime > ST.endTime then
        ST.isActive = false
        ST.endTime = 0
        ST.ManageUpdateLoop()
    end

    ST.UpdateVisuals()
end

---------------------------------------------------------------------------
-- EFFECT CHANGED
---------------------------------------------------------------------------
function ST.OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceUnitType)
    if abilityId ~= ST.MAJOR_SLAYER_ID then return end

    if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
        local currentTime = GetGameTimeMilliseconds()
        local endTimeMs = endTime * 1000
        local beginTimeMs = beginTime * 1000

        if endTime == 0 or endTimeMs > currentTime then
            local shouldAnimate = false
            local oldRemaining = math.max(0, ST.endTime - currentTime)

            if endTime == 0 then
                if currentTime - ST.lastAnimationTime > 5000 then
                    shouldAnimate = true
                end
            else
                local threshold = ST.referenceDuration * 0.5
                if oldRemaining <= threshold then
                    shouldAnimate = true
                end

                ST.referenceDuration = endTimeMs - beginTimeMs
            end

            ST.isActive = true
            ST.endTime = endTimeMs
            ST.hadBuffBefore = true

            if shouldAnimate then
                ST.PlayAnimation()
                ST.lastAnimationTime = currentTime
            end

            ST.ManageUpdateLoop()
            ST.UpdateVisuals()
        end
    elseif changeType == EFFECT_RESULT_FADED then
        ST.isActive = false
        ST.ManageUpdateLoop()
        ST.UpdateVisuals()
    end
end

---------------------------------------------------------------------------
-- COMBAT STATE
---------------------------------------------------------------------------
function ST.OnCombatState()
    ST.isCombat = IsUnitInCombat("player")
    ST.isPreview = false

    if ST.PARENT then
        ST.PARENT:SetMovable(not ST.SV.isLocked)
        ST.PARENT:SetMouseEnabled(not ST.SV.isLocked)
    end

    if ST.isCombat then
        local currentTime = GetGameTimeMilliseconds()
        ST.timeFightStart = currentTime
        ST.timeFightUpdate = currentTime
        ST.timeActive = 0
        ST.uptimePercentage = 0
    else
        ST.SendChatSummary()
        ST.hadBuffBefore = false
    end

    ST.CheckCurrentBuffs()
end

---------------------------------------------------------------------------
-- CHECK PLAYER SETS
---------------------------------------------------------------------------
function ST.CheckPlayerSets()
    local bodySets = {}
    local frontSets = {}
    local backSets = {}

    local oldWearingStatus = ST.isWearingSlayerSet
    local oldActiveBarStatus = ST.isActiveSlayerBar

    ST.isWearingSlayerSet = false
    ST.isActiveSlayerBar = false

    for _, itemSlot in ipairs(ST.ITEM_SLOTS) do
        local itemLink = GetItemLink(BAG_WORN, itemSlot)
        local hasSet, _, _, _, _, setId = GetItemLinkSetInfo(itemLink, false)

        if hasSet and ST.SLAYER_SETS[setId] then
            local weight = 1
            local weaponType = GetItemWeaponType(BAG_WORN, itemSlot) or 0
            if ST.WEAPONTYPE_TWO_HANDED[weaponType] then
                weight = 2
            end

            if itemSlot == EQUIP_SLOT_MAIN_HAND or itemSlot == EQUIP_SLOT_OFF_HAND then
                frontSets[setId] = (frontSets[setId] or 0) + weight
            elseif itemSlot == EQUIP_SLOT_BACKUP_MAIN or itemSlot == EQUIP_SLOT_BACKUP_OFF then
                backSets[setId] = (backSets[setId] or 0) + weight
            else
                bodySets[setId] = (bodySets[setId] or 0) + weight
            end
        end
    end

    local activePair = GetActiveWeaponPairInfo()

    for setId, _ in pairs(ST.SLAYER_SETS) do
        local body = bodySets[setId] or 0
        local front = frontSets[setId] or 0
        local back = backSets[setId] or 0

        local totalFront = body + front
        local totalBack = body + back

        if totalFront >= 5 or totalBack >= 5 then
            ST.isWearingSlayerSet = true
        end

        if (activePair == ACTIVE_WEAPON_PAIR_MAIN and totalFront >= 5) or
           (activePair == ACTIVE_WEAPON_PAIR_BACKUP and totalBack >= 5) then
            ST.isActiveSlayerBar = true
        end
    end

    if ST.isLoaded and (oldWearingStatus ~= ST.isWearingSlayerSet or oldActiveBarStatus ~= ST.isActiveSlayerBar) then
        ST.UpdateTimerPosition()
        ST.UpdateVisuals()
    end
end

---------------------------------------------------------------------------
-- SET ITEM CHANGED
---------------------------------------------------------------------------
function ST.OnInventorySingleSlotUpdate()
    EVENT_MANAGER:UnregisterForUpdate(ST.NAME .. "InventoryUpdateDelay")

    EVENT_MANAGER:RegisterForUpdate(ST.NAME .. "InventoryUpdateDelay", 100, function()
        EVENT_MANAGER:UnregisterForUpdate(ST.NAME .. "InventoryUpdateDelay")
        ST.CheckPlayerSets()
    end)
end

---------------------------------------------------------------------------
-- PLAYER ACTIVATED (RELOAD / ZONE CHANGE)
---------------------------------------------------------------------------
function ST.OnPlayerActivated()
    ST.OnCombatState()
end

---------------------------------------------------------------------------
-- ENABLE
---------------------------------------------------------------------------
function ST.Enable()
    SCENE_MANAGER:GetScene("hud"):RegisterCallback("StateChange", ST.OnStateChange)
    SCENE_MANAGER:GetScene("hudui"):RegisterCallback("StateChange", ST.OnStateChange)

    EVENT_MANAGER:RegisterForEvent(ST.NAME, EVENT_PLAYER_ACTIVATED, ST.OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(ST.NAME, EVENT_PLAYER_COMBAT_STATE, ST.OnCombatState)
    EVENT_MANAGER:RegisterForEvent(ST.NAME, EVENT_EFFECT_CHANGED, ST.OnEffectChanged)
    EVENT_MANAGER:RegisterForEvent(ST.NAME, EVENT_GROUP_MEMBER_ROLE_CHANGED, ST.UpdateVisibility)

    EVENT_MANAGER:AddFilterForEvent(ST.NAME, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
    EVENT_MANAGER:AddFilterForEvent(ST.NAME, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, ST.MAJOR_SLAYER_ID)
    EVENT_MANAGER:RegisterForEvent(ST.NAME, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, ST.OnInventorySingleSlotUpdate)

    EVENT_MANAGER:RegisterForEvent(ST.NAME, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ST.OnInventorySingleSlotUpdate)
    EVENT_MANAGER:AddFilterForEvent(ST.NAME, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)

    ST.CheckPlayerSets()

    ST.OnCombatState()
    ST.isLoaded = true
end

---------------------------------------------------------------------------
-- DISABLE
---------------------------------------------------------------------------
function ST.Disable()
    SCENE_MANAGER:GetScene("hud"):UnregisterCallback("StateChange", ST.OnStateChange)
    SCENE_MANAGER:GetScene("hudui"):UnregisterCallback("StateChange", ST.OnStateChange)

    EVENT_MANAGER:UnregisterForEvent(ST.NAME, EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:UnregisterForEvent(ST.NAME, EVENT_PLAYER_COMBAT_STATE)
    EVENT_MANAGER:UnregisterForEvent(ST.NAME, EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(ST.NAME, EVENT_GROUP_MEMBER_ROLE_CHANGED)
    EVENT_MANAGER:UnregisterForUpdate(ST.NAME .. "Update")

    EVENT_MANAGER:UnregisterForEvent(ST.NAME, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    EVENT_MANAGER:UnregisterForEvent(ST.NAME, EVENT_ACTIVE_WEAPON_PAIR_CHANGED)

    ST.PARENT:SetHidden(true)
    ST.isActive = false
    ST.endTime = 0
    ST.lastAnimationTime = 0
    ST.isLoaded = false
end