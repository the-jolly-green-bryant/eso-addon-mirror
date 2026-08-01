local OBT = OffBalanceTracker

---------------------------------------------------------------------------
-- UPDATE VISIBILTY
---------------------------------------------------------------------------
function OBT.UpdateVisibility()
    -- PREVIEW
    if OBT.isForceShow then
        OBT.PARENT:SetHidden(false)
        return
    end

    OBT.groupRole = GetGroupMemberSelectedRole("player")

    local roleSettings = {
        [0] = OBT.SV.isEnabledSolo,
        [1] = OBT.SV.isEnabledDPS,
        [2] = OBT.SV.isEnabledTank,
        [4] = OBT.SV.isEnabledHeal
    }

    local roleEnabled = OBT.SV.enableAddon and (roleSettings[OBT.groupRole] == true)
    local isHidden = not (SCENE_MANAGER:GetScene("hud"):IsShowing() or SCENE_MANAGER:GetScene("hudui"):IsShowing())

    if isHidden or not roleEnabled or (OBT.SV.isOnlyCombat and not OBT.isCombat) then
        OBT.PARENT:SetHidden(true)
    elseif OBT.SV.isOnlyBosses and not (OBT.isTrackingBoss or OBT.hasCombatBoss) then
        OBT.PARENT:SetHidden(true)
    else
        OBT.PARENT:SetHidden(false)
    end
end

---------------------------------------------------------------------------
-- ANIMATION)
---------------------------------------------------------------------------
function OBT.PlayAnimation()
    if OBT.isAnimationActive then return end
    OBT.isAnimationActive = true

    local animationDuration = 500
    local durationGrow = math.floor(animationDuration / 3)
    local durationShrink = animationDuration - durationGrow

    -- CREATE TIMELINE AND ANIMATION IF NOT YET CREATED
    if not OBT.TIMELINE then
        OBT.TIMELINE = ANIMATION_MANAGER:CreateTimeline()

        OBT.ANIMATION_SCALEUP = OBT.TIMELINE:InsertAnimation(ANIMATION_SCALE, OBT.DURATION, 0)
        OBT.ANIMATION_SCALEUP:SetEasingFunction(ZO_EaseInQuadratic)

        OBT.ANIMATION_SCALEDOWN = OBT.TIMELINE:InsertAnimation(ANIMATION_SCALE, OBT.DURATION, 0)
        OBT.ANIMATION_SCALEDOWN:SetEasingFunction(ZO_EaseOutQuadratic)

        -- RESET
        OBT.TIMELINE:SetHandler('OnStop', function()
            OBT.DURATION:SetScale(1.0)
            OBT.isAnimationActive = false
        end)
    end

    -- IF ANIMATION RUNS STOP IT.. PREVENTS CRASHES
    if OBT.TIMELINE:IsPlaying() then OBT.TIMELINE:Stop() end

    -- SET NEW VALS
    OBT.ANIMATION_SCALEUP:SetScaleValues(1.0, 2.0)
    OBT.ANIMATION_SCALEUP:SetDuration(durationGrow)

    OBT.ANIMATION_SCALEDOWN:SetScaleValues(2.0, 1.0)
    OBT.ANIMATION_SCALEDOWN:SetDuration(durationShrink)
    OBT.TIMELINE:SetAnimationOffset(OBT.ANIMATION_SCALEDOWN, durationGrow)

    OBT.TIMELINE:PlayFromStart()
end

---------------------------------------------------------------------------
-- TARGET IS BOSS OR DUMMY?
---------------------------------------------------------------------------
function OBT.IsTargetBossOrDummy(unitTag, unitName)
    if unitTag and string.sub(unitTag, 1, 4) == "boss" then return true end

    local checkTag = unitTag or "reticleover"
    if DoesUnitExist(checkTag) then
        for i = 1, 6 do
            if DoesUnitExist(OBT.BOSS_TAGS[i]) and AreUnitsEqual(checkTag, OBT.BOSS_TAGS[i]) then
                return true
            end
        end
    end

    if DoesUnitExist("reticleover") and IsUnitAttackable("reticleover") then
        local reticleName = GetUnitName("reticleover")
        local maxHealth = select(2, GetUnitPower("reticleover", POWERTYPE_HEALTH))
        local cleanEventName = unitName and string.gsub(unitName, "%^.*", "") or ""
        local cleanReticleName = reticleName and string.gsub(reticleName, "%^.*", "") or "" -- MAYBE USE ZOS API LIKE IN TARGET TAUNT.. TODO!

        if not unitName or cleanReticleName == cleanEventName then
            if maxHealth and maxHealth >= 20500000 and maxHealth <= 21500000 then return true end
        end
    end
    return false
end

---------------------------------------------------------------------------
-- EFFECT CHANGED
---------------------------------------------------------------------------
function OBT.OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceUnitType)
    if effectName ~= OBT.debuffName and effectName ~= OBT.cleanDebuffName and effectName ~= OBT.immuneName and effectName ~= OBT.cleanImmuneName then
        return
    end

    local isBossEvent = false
    if OBT.knownBosses[unitId] then
        isBossEvent = true
    elseif OBT.IsTargetBossOrDummy(unitTag, unitName) then
        isBossEvent = true
        OBT.knownBosses[unitId] = true
    end

    if isBossEvent then
        if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
            -- SET STATE
            local state = (effectName == OBT.debuffName or effectName == OBT.cleanDebuffName) and 1 or 2
            if not OBT.bossTimers[unitId] then OBT.bossTimers[unitId] = {} end
            OBT.bossTimers[unitId].state = state
            OBT.bossTimers[unitId].endTime = endTime * 1000
        end
    end
end

---------------------------------------------------------------------------
-- MAIN LOOP
---------------------------------------------------------------------------
function OBT.OnUpdateHandler()
    -- PREVIEW
    if OBT.isForceShow then return end

    local currentTime = GetGameTimeMilliseconds()

    local reticleActive = false
    local reticleState, reticleEndTime, reticleIsBoss = 0, 0, false

    if DoesUnitExist("reticleover") and IsUnitAttackable("reticleover") then
        reticleActive = true
        reticleIsBoss = OBT.IsTargetBossOrDummy("reticleover", nil)

        for i = 1, GetNumBuffs("reticleover") do
            -- GRAB BUFF NAME.. SO NO ID
            local buffName, timeStarted, timeEnding = GetUnitBuffInfo("reticleover", i)

            if buffName == OBT.debuffName or buffName == OBT.cleanDebuffName then
                reticleState = 1; reticleEndTime = timeEnding * 1000; break
            elseif buffName == OBT.immuneName or buffName == OBT.cleanImmuneName then
                reticleState = 2; reticleEndTime = timeEnding * 1000; break
            end
        end
    end

    local memoryIsActiveBoss = (OBT.SV.isBossFocus and OBT.memory.isBoss)

    if reticleActive then
        if memoryIsActiveBoss and not reticleIsBoss then
            if OBT.memory.state == 1 and currentTime >= OBT.memory.endTime then
                OBT.memory.state = 2
                OBT.memory.endTime = OBT.memory.endTime + 15000
            elseif OBT.memory.state == 2 and currentTime >= OBT.memory.endTime then
                OBT.memory.state = 0
            end
        else
            OBT.memory.state = reticleState
            OBT.memory.endTime = reticleEndTime
            OBT.memory.isBoss = reticleIsBoss
        end
    else
        if OBT.memory.state == 1 and currentTime >= OBT.memory.endTime then
            OBT.memory.state = 2
            OBT.memory.endTime = OBT.memory.endTime + 15000
        elseif OBT.memory.state == 2 and currentTime >= OBT.memory.endTime then
            OBT.memory.state = 0
        end
    end

    local activeBossState, activeBossEndTime = 0, 0
    local lockedBossExists = false

    if OBT.SV.isBossFocus then
        for unitId, data in pairs(OBT.bossTimers) do
            lockedBossExists = true

            if currentTime >= data.endTime then
                if data.state == 1 then
                    OBT.bossTimers[unitId].state = 2
                    OBT.bossTimers[unitId].endTime = data.endTime + 15000

                    if activeBossState < 2 then
                        activeBossState = 2
                        activeBossEndTime = OBT.bossTimers[unitId].endTime
                    end
                elseif data.state == 2 then
                    OBT.bossTimers[unitId].state = 0
                end
            else
                if data.state == 1 then
                    activeBossState = 1
                    activeBossEndTime = data.endTime
                elseif data.state == 2 and activeBossState ~= 1 then
                    activeBossState = 2
                    activeBossEndTime = data.endTime
                end
            end
        end
    end

    local dataState, dataEndTime, dataIsBoss = 0, 0, false

    if OBT.SV.isBossFocus then
        if reticleActive and reticleIsBoss then
            dataState = reticleState
            dataEndTime = reticleEndTime
            dataIsBoss = true
        elseif lockedBossExists then
            dataState = activeBossState
            dataEndTime = activeBossEndTime
            dataIsBoss = true
        elseif memoryIsActiveBoss then
            dataState = OBT.memory.state
            dataEndTime = OBT.memory.endTime
            dataIsBoss = true
        else
            dataState = OBT.memory.state
            dataEndTime = OBT.memory.endTime
            dataIsBoss = OBT.memory.isBoss
        end
    else
        dataState = OBT.memory.state
        dataEndTime = OBT.memory.endTime
        dataIsBoss = OBT.memory.isBoss
    end

    if currentTime > dataEndTime then
        dataState = 0
        dataEndTime = 0
    end

    if OBT.SV.isOnlyBosses and not dataIsBoss then
        dataState = 0
        dataEndTime = 0
    end

    local remainingTime = math.max(0, dataEndTime - currentTime)

    if dataIsBoss then
        OBT.hasCombatBoss = true
    end

    if dataState == 1 and remainingTime > 6500 and remainingTime <= 7000 then
        if OBT.lastAnimatedataEndTime ~= dataEndTime then
            OBT.PlayAnimation()
            OBT.lastAnimatedataEndTime = dataEndTime
        end
    end

    OBT.isTrackingBoss = dataIsBoss
    OBT.UpdateVisibility()

    OBT.UpdateVisuals(dataState, remainingTime, dataIsBoss)
end

---------------------------------------------------------------------------
-- COMBAT STATE
---------------------------------------------------------------------------
function OBT.OnCombatState()
    OBT.isCombat = IsUnitInCombat("player")

    if OBT.isCombat then
        OBT.hasCombatBoss = false
        EVENT_MANAGER:RegisterForUpdate(OBT.name .. "Update", OBT.TIME_UPDATE, OBT.OnUpdateHandler)
    else
        EVENT_MANAGER:UnregisterForUpdate(OBT.name .. "Update")
        OBT.bossTimers = {}
        OBT.knownBosses = {}
        OBT.memory = { state = 0, endTime = 0, isBoss = false }
        OBT.isTrackingBoss = false
        OBT.hasCombatBoss = false
        OBT.UpdateVisuals(0, 0, false)
    end

    OBT.UpdateVisibility()
end

---------------------------------------------------------------------------
-- HANDLE SCENE STATE CHANGES (HUD/HUDUI)
---------------------------------------------------------------------------
function OBT.OnStateChange(oldState, newState)
    if newState == SCENE_SHOWN then
        OBT.isForceShow = false
        OBT.UpdateVisibility()
    elseif newState == SCENE_HIDING and not OBT.isForceShow then
        OBT.PARENT:SetHidden(true)
    end
end

---------------------------------------------------------------------------
-- ENABLE
---------------------------------------------------------------------------
function OBT.Enable()
    SCENE_MANAGER:GetScene("hud"):RegisterCallback("StateChange", OBT.OnStateChange)
    SCENE_MANAGER:GetScene("hudui"):RegisterCallback("StateChange", OBT.OnStateChange)

    EVENT_MANAGER:RegisterForEvent(OBT.name, EVENT_PLAYER_COMBAT_STATE, OBT.OnCombatState)
    EVENT_MANAGER:RegisterForEvent(OBT.name, EVENT_EFFECT_CHANGED, OBT.OnEffectChanged)
    EVENT_MANAGER:RegisterForEvent(OBT.name, EVENT_GROUP_MEMBER_ROLE_CHANGED, OBT.UpdateVisibility)

    OBT.OnCombatState()
    OBT.UpdateVisibility()
    OBT.UpdateVisuals(0, 0, false)
    OBT.isLoaded = true
end

---------------------------------------------------------------------------
-- DISABLE
---------------------------------------------------------------------------
function OBT.Disable()
    SCENE_MANAGER:GetScene("hud"):UnregisterCallback("StateChange", OBT.OnStateChange)
    SCENE_MANAGER:GetScene("hudui"):UnregisterCallback("StateChange", OBT.OnStateChange)

    EVENT_MANAGER:UnregisterForEvent(OBT.name, EVENT_PLAYER_COMBAT_STATE)
    EVENT_MANAGER:UnregisterForEvent(OBT.name, EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(OBT.name, EVENT_GROUP_MEMBER_ROLE_CHANGED)
    EVENT_MANAGER:UnregisterForUpdate(OBT.name .. "Update")

    -- NIL VALS
    OBT.PARENT:SetHidden(true)
    OBT.bossTimers = {}
    OBT.knownBosses = {}
    OBT.isLoaded = false
end