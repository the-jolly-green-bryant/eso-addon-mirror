local HST = HeatShockTracker

---------------------------------------------------------------------------
-- CALCULATE UPTIME COLOR (USED FOR CHAT SUMMARY AND TIMER)
---------------------------------------------------------------------------
function HST.GetPercentageColor(percentage)
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

    HST.ColorCache[1] = r
    HST.ColorCache[2] = g
    HST.ColorCache[3] = 0
    HST.ColorCache[4] = 1

    return HST.ColorCache
end

---------------------------------------------------------------------------
-- SEND CHAT SUMMARY AFTER COMBAT
---------------------------------------------------------------------------
function HST.SendChatSummary()
    if not HST.SV.isEnabledChat or not HST.isEquipped then return end
    if HST.timeFightStart == 0 then return end

    local durationFightMs = GetGameTimeMilliseconds() - HST.timeFightStart
    local durationFightSec = durationFightMs / 1000

    if durationFightSec < HST.SV.minFightTime then return end

    local minutes = math.floor(durationFightSec / 60)
    local seconds = math.floor(durationFightSec % 60)
    local formattedTime = string.format("%d:%02dmin", minutes, seconds)

    -- GET COLOR BASED ON 3-STACK UPTIME
    local r, g, b = unpack(HST.GetPercentageColor(HST.Percentages[3]))
    local hexColor = string.format("%02x%02x%02x", r * 255, g * 255, b * 255)

    d(string.format("|cFF7F00[Heat Shock]|r |c%s[3] %.1f%% [2] %.1f%% [1] %.1f%%|r |cFFFFFF- Fight: %s|r", hexColor, HST.Percentages[3], HST.Percentages[2], HST.Percentages[1], formattedTime))
end

---------------------------------------------------------------------------
-- TRIGGERED ON COMBAT STATE CHANGE
---------------------------------------------------------------------------
function HST.OnCombatState()
    HST.isCombat = IsUnitInCombat("player")

    HST.isForceShow = false
    if HST.PARENT then
        HST.PARENT:SetMovable(not HST.SV.isLocked)
        HST.PARENT:SetMouseEnabled(not HST.SV.isLocked)
    end

    if HST.isCombat then
        local currentTime = GetGameTimeMilliseconds()
        HST.timeFightStart, HST.timeFightUpdate = currentTime, currentTime

        for i = 1, HST.MAX_STACKS do
            HST.StackTimes[i] = 0
        end

        EVENT_MANAGER:RegisterForUpdate(HST.NAME .. "Update", HST.TIME_UPDATE, HST.OnUpdateHandler)
    else
        EVENT_MANAGER:UnregisterForUpdate(HST.NAME .. "Update")
        HST.SendChatSummary()

        -- RESET WHEN COMBAT ENDS
        ZO_ClearTable(HST.ActiveDebuffs)
        ZO_ClearTable(HST.TargetEndTimes)
        ZO_ClearTable(HST.BossUnits)

        HST.currentStacks = 0
        HST.counterCasts = 0

        for i = 1, HST.MAX_STACKS do
            HST.StackEndTimes[i] = 0
        end

        HST.UpdateVisuals()
    end

    HST.UpdateIsEquipped()
end

---------------------------------------------------------------------------
-- UPDATE LOOP
---------------------------------------------------------------------------
function HST.OnUpdateHandler()
    local currentTime = GetGameTimeMilliseconds()
    local timeDelta = currentTime - HST.timeFightUpdate
    HST.timeFightUpdate = currentTime

    -- MAX STACK ACROSS ALL TARGETS
    local maxActiveStacks = 0
    for targetId, targetStacks in pairs(HST.ActiveDebuffs) do
        if currentTime > (HST.TargetEndTimes[targetId] or 0) then
            -- CLEANUP FADED EVENT
            HST.ActiveDebuffs[targetId] = nil
            HST.TargetEndTimes[targetId] = nil
        elseif targetStacks > maxActiveStacks then
            maxActiveStacks = targetStacks
        end
    end

    -- TRACK TIMES PER STACK
    for i = 1, HST.MAX_STACKS do
        if i <= maxActiveStacks then
            HST.StackTimes[i] = HST.StackTimes[i] + timeDelta
        end
    end

    -- CALC %
    local duration = currentTime - HST.timeFightStart
    for i = 1, 3 do
        HST.Percentages[i] = (duration > 0) and (HST.StackTimes[i] / duration * 100) or 0
    end

    HST.UpdateVisuals()
end

---------------------------------------------------------------------------
-- CHECK IF UNIT IS BOSS OR DUMMY
---------------------------------------------------------------------------
function HST.IsTargetBossOrDummy(unitTag, unitName)
    -- REAL BOSS HAS BOSS TAG "BOSS1" ETC
    if unitTag and string.sub(unitTag, 1, 4) == "boss" then
        return true, string.upper(unitTag)
    end

    local checkTag = unitTag or "reticleover"
    if DoesUnitExist(checkTag) then
        for i = 1, 6 do
            if DoesUnitExist(HST.BOSS_TAGS[i]) and AreUnitsEqual(checkTag, HST.BOSS_TAGS[i]) then
                return true, string.upper(HST.BOSS_TAGS[i])
            end
        end
    end

    if DoesUnitExist("reticleover") then
        local reticleName = GetUnitName("reticleover")
        local _, maxHealth, _ = GetUnitPower("reticleover", POWERTYPE_HEALTH)
        local cleanEventName = unitName and string.gsub(unitName, "%^.*", "") or ""
        local cleanReticleName = reticleName and string.gsub(reticleName, "%^.*", "") or ""

        if not unitName or cleanReticleName == cleanEventName then
            -- HEALTH DUMMY
            if maxHealth and maxHealth >= 20500000 and maxHealth <= 21500000 then
                return true, "ATRO"
            end
        end
    end

    return false, nil
end

---------------------------------------------------------------------------
-- UPDATE TARGET FROM RETICLE
---------------------------------------------------------------------------
function HST.UpdateReticleTarget()
    if HST.SV.trackingMode ~= 4 then return end

    local foundStacks = 0
    local endTimeMs = 0

    HST.isTrackedBoss = false
    HST.trackedBossLabel = "BOSS"

    if DoesUnitExist("reticleover") then
        -- CHECK IF TARGET IS BOSS OR DUMMY
        local isBoss, bossLabel = HST.IsTargetBossOrDummy("reticleover", nil)
        HST.isTrackedBoss = isBoss
        if isBoss then HST.trackedBossLabel = bossLabel or "BOSS" end

        for i = 1, GetNumBuffs("reticleover") do
            local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer = GetUnitBuffInfo("reticleover", i)

            if abilityId == HST.DEBUFF_ID then
                foundStacks = stackCount
                endTimeMs = timeEnding * 1000
                break
            end
        end
    end

    HST.currentStacks = foundStacks

    -- TIMER SYNC
    for i = 1, HST.MAX_STACKS do
        if i <= foundStacks then
            HST.StackEndTimes[i] = endTimeMs
        else
            HST.StackEndTimes[i] = 0
        end
    end

    HST.UpdateVisuals()
end

---------------------------------------------------------------------------
-- COMBAT EFFECT HANDLER
---------------------------------------------------------------------------
function HST.OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceUnitType)
    if abilityId ~= HST.DEBUFF_ID then return end
    if sourceUnitType ~= COMBAT_UNIT_TYPE_PLAYER and HST.SV.isOnlyTrackPlayer then return end

    if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then

        if HST.SV.isEnabledAnimation then
            HST.PlayAnimation()
        end

        local currentTime = GetGameTimeMilliseconds()
        if currentTime > HST.timeCounterCasts + HST.TIME_UPDATE then
            HST.timeCounterCasts = currentTime
            HST.counterCasts = HST.counterCasts + 1
        end

        HST.ActiveDebuffs[unitId] = stackCount
        HST.TargetEndTimes[unitId] = currentTime + HST.DURATION_MS
        HST.lastTargetUnitId = unitId

        -- BOSS & DUMMY DETECTION VIA HELPER
        local isBoss, bossLabel = HST.IsTargetBossOrDummy(unitTag, unitName)
        if isBoss then
            HST.lastBossUnitId = unitId
            HST.BossUnits[unitId] = bossLabel or "BOSS"
        end

    elseif changeType == EFFECT_RESULT_FADED then
        HST.ActiveDebuffs[unitId] = nil
        HST.TargetEndTimes[unitId] = nil
        HST.BossUnits[unitId] = nil

        -- IF LAST TARGET DIES OR FADES, CLEAR THE REF
        if HST.lastTargetUnitId == unitId then
            HST.lastTargetUnitId = nil
        end
        if HST.lastBossUnitId == unitId then
            HST.lastBossUnitId = nil
        end
    end

    ---------------------------------------------------------------------------
    -- CALCULATING STACKS DEPENDING ON THE CURRENT MODE
    ---------------------------------------------------------------------------
    HST.isTrackedBoss = false
    local visualTargetId = nil

    if HST.SV.trackingMode == 1 then
        -- MODE 1: RECENT TARGET
        if HST.lastTargetUnitId and HST.ActiveDebuffs[HST.lastTargetUnitId] then
            visualTargetId = HST.lastTargetUnitId
            HST.currentStacks = HST.ActiveDebuffs[visualTargetId]
            if HST.BossUnits[visualTargetId] then
                HST.isTrackedBoss = true
                HST.trackedBossLabel = HST.BossUnits[visualTargetId]
            end
        else
            HST.currentStacks = 0
        end

    elseif HST.SV.trackingMode == 2 then
        -- MODE 2: HIGHEST STACKS
        local maxStacks = 0
        for targetId, targetStacks in pairs(HST.ActiveDebuffs) do
            -- PRIORITIZE BOSS IF STACKS EQUAL
            if targetStacks > maxStacks or (targetStacks == maxStacks and HST.BossUnits[targetId]) then
                maxStacks = targetStacks
                visualTargetId = targetId
            end
        end
        HST.currentStacks = maxStacks
        if visualTargetId and HST.BossUnits[visualTargetId] then
            HST.isTrackedBoss = true
            HST.trackedBossLabel = HST.BossUnits[visualTargetId]
        end

    elseif HST.SV.trackingMode == 3 then
        -- MODE 3: BOSS PRIORITY
        if HST.lastBossUnitId and HST.ActiveDebuffs[HST.lastBossUnitId] then
            visualTargetId = HST.lastBossUnitId
            HST.currentStacks = HST.ActiveDebuffs[visualTargetId]
            HST.isTrackedBoss = true
            HST.trackedBossLabel = HST.BossUnits[visualTargetId] or "BOSS"
        elseif HST.lastTargetUnitId and HST.ActiveDebuffs[HST.lastTargetUnitId] then
            visualTargetId = HST.lastTargetUnitId
            HST.currentStacks = HST.ActiveDebuffs[visualTargetId]
            if HST.BossUnits[visualTargetId] then
                HST.isTrackedBoss = true
                HST.trackedBossLabel = HST.BossUnits[visualTargetId]
            end
        else
            HST.currentStacks = 0
        end

    elseif HST.SV.trackingMode == 4 then
        -- MODE 4: CT
        HST.UpdateReticleTarget()
        return
    end

    if visualTargetId and HST.TargetEndTimes[visualTargetId] then
        local endTimeMs = HST.TargetEndTimes[visualTargetId]
        for i = 1, HST.MAX_STACKS do
            HST.StackEndTimes[i] = (i <= HST.currentStacks) and endTimeMs or 0
        end
    else
        for i = 1, HST.MAX_STACKS do
            HST.StackEndTimes[i] = 0
        end
    end

    -- FORCE UPDATE
    HST.UpdateVisuals()
end

---------------------------------------------------------------------------
-- TOGGLE UI LOCK STATE VIA SLASH COMMAND
---------------------------------------------------------------------------
function HST.ToggleLock()
    HST.SV.isLocked = not HST.SV.isLocked

    HST.PARENT:SetMovable(not HST.SV.isLocked)
    HST.PARENT:SetMouseEnabled(not HST.SV.isLocked)

    if HST.SV.isLocked then
        d(string.format("%s |cff0000UI Locked|r", HST.CHAT))
    else
        d(string.format("%s |c00ff00UI Unlocked|r", HST.CHAT))
    end
end

---------------------------------------------------------------------------
-- UPDATE EQUIPMENT STATUS & VISIBILITY
---------------------------------------------------------------------------
function HST.UpdateIsEquipped()
    HST.isEquipped = false
    for i = 3, 7 do
        local slotFront, slotBack = GetSlotBoundId(i, HOTBAR_CATEGORY_PRIMARY), GetSlotBoundId(i, HOTBAR_CATEGORY_BACKUP)
        if slotFront == HST.SLOT_ID or slotBack == HST.SLOT_ID or slotFront == HST.DEBUFF_ID or slotBack == HST.DEBUFF_ID then
            HST.isEquipped = true
            break
        end
    end

    -- PREVIEW
    if HST.isForceShow or HST.isMenuPreview then
        HST.PARENT:SetHidden(false)
        return
    end
    -- CHECK IF HUD IS HIDDEN (MENU?)
    local isHudHidden = not (SCENE_MANAGER:GetScene("hud"):IsShowing() or SCENE_MANAGER:GetScene("hudui"):IsShowing())

    if isHudHidden then
        HST.PARENT:SetHidden(true)
    else
        -- COMBAT/EQUIP
        HST.PARENT:SetHidden(not HST.isEquipped or (HST.SV.isOnlyCombat and not HST.isCombat))
    end
end

---------------------------------------------------------------------------
-- SCENE CHANGE (HIDE ADDON WHEN IN MENU ETC)
---------------------------------------------------------------------------
function HST.OnStateChange(oldState, newState)
    if newState == SCENE_SHOWN then
        HST.UpdateIsEquipped()
    elseif newState == SCENE_HIDING then
        -- HIDE UI IN MENU UNLESS PREVIEW
        if not HST.isForceShow then
            HST.PARENT:SetHidden(true)
        end
    end
end

---------------------------------------------------------------------------
-- TOGGLE RETICLE EVENT REGISTRATION
---------------------------------------------------------------------------
function HST.RegisterReticleEvent()
    if HST.SV.enableAddon and HST.SV.trackingMode == 4 then
        EVENT_MANAGER:RegisterForEvent(HST.NAME, EVENT_RETICLE_TARGET_CHANGED, HST.UpdateReticleTarget)
        HST.UpdateReticleTarget() -- UPDATE WHEN ENABLED
    else
        EVENT_MANAGER:UnregisterForEvent(HST.NAME, EVENT_RETICLE_TARGET_CHANGED)
    end
end

---------------------------------------------------------------------------
-- PLAYER ACTIVATED (RELOAD / ZONE CHANGE)
---------------------------------------------------------------------------
function HST.OnPlayerActivated()
    HST.OnCombatState()
    HST.UpdateIsEquipped()
end

---------------------------------------------------------------------------
-- ENABLE ADDON
---------------------------------------------------------------------------
function HST.Enable()
    SCENE_MANAGER:GetScene("hud"):RegisterCallback("StateChange", HST.OnStateChange)
    SCENE_MANAGER:GetScene("hudui"):RegisterCallback("StateChange", HST.OnStateChange)

    EVENT_MANAGER:RegisterForEvent(HST.NAME, EVENT_PLAYER_ACTIVATED, HST.OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(HST.NAME, EVENT_PLAYER_COMBAT_STATE, HST.OnCombatState)
    EVENT_MANAGER:RegisterForEvent(HST.NAME, EVENT_EFFECT_CHANGED, HST.OnEffectChanged)
    EVENT_MANAGER:AddFilterForEvent(HST.NAME, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, HST.DEBUFF_ID)
    EVENT_MANAGER:RegisterForEvent(HST.NAME, EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, HST.UpdateIsEquipped)
    EVENT_MANAGER:RegisterForEvent(HST.NAME, EVENT_ACTION_SLOT_UPDATED, HST.UpdateIsEquipped)
    HST.RegisterReticleEvent()

    HST.UpdateIsEquipped()
    HST.isLoaded = true
end

---------------------------------------------------------------------------
-- DISABLE ADDON
---------------------------------------------------------------------------
function HST.Disable()
    SCENE_MANAGER:GetScene("hud"):UnregisterCallback("StateChange", HST.OnStateChange)
    SCENE_MANAGER:GetScene("hudui"):UnregisterCallback("StateChange", HST.OnStateChange)

    EVENT_MANAGER:UnregisterForEvent(HST.NAME, EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:UnregisterForEvent(HST.NAME, EVENT_PLAYER_COMBAT_STATE)
    EVENT_MANAGER:UnregisterForEvent(HST.NAME, EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(HST.NAME, EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED)
    EVENT_MANAGER:UnregisterForEvent(HST.NAME, EVENT_ACTION_SLOT_UPDATED)
    EVENT_MANAGER:UnregisterForEvent(HST.NAME, EVENT_RETICLE_TARGET_CHANGED)
    EVENT_MANAGER:UnregisterForUpdate(HST.NAME .. "Update")

    HST.PARENT:SetHidden(true)
    HST.isLoaded = false
end