local TTK = TimeToKill

---------------------------------------------------------------------------
-- RETURN PERCENTAGE COLOR
---------------------------------------------------------------------------
function TTK.GetPercentageColor(percentage, color100, color50, color0)
    color100 = color100 or {0, 1, 0}
    color50 = color50 or {1, 1, 0}
    color0 = color0 or {1, 0, 0}

    local p = math.max(0, math.min(100, percentage))
    local r, g, b
    local a = 1

    if p > 0.5 then
        -- 100 TO 50
        local localP = (p - 0.5) * 2
        r = color100[1] * localP + color50[1] * (1 - localP)
        g = color100[2] * localP + color50[2] * (1 - localP)
        b = color100[3] * localP + color50[3] * (1 - localP)
    else
        -- 50 TO 0
        local localP = p * 2
        r = color50[1] * localP + color0[1] * (1 - localP)
        g = color50[2] * localP + color0[2] * (1 - localP)
        b = color50[3] * localP + color0[3] * (1 - localP)
    end

    return r, g, b, a
end

---------------------------------------------------------------------------
-- FORMAT DPS: 816k, 1.2M
---------------------------------------------------------------------------
function TTK.FormatDPS(dps)
    if dps >= 1000000 then
        return string.format("%.1fM", dps / 1000000) -- 1.0M to 999.9M
    elseif dps >= 1000 then
        return string.format("%.0fk", dps / 1000) -- 1k - 999k
    else
        return "0k"
    end
end

---------------------------------------------------------------------------
-- FORMAT TTK
---------------------------------------------------------------------------
function TTK.FormatTTK(ttk, threshold)
    if ttk < 0 or ttk > 599 or (threshold > 0 and ttk > threshold) then
        return "∞"
    elseif ttk < 60 then
        return string.format("%.0fs", ttk)
    else
        local minutes = math.floor(ttk / 60)
        local seconds = math.floor(ttk % 60)
        return string.format("%d:%02d", minutes, seconds)
    end
end

---------------------------------------------------------------------------
-- VALID TARGET CHECK
---------------------------------------------------------------------------
function TTK.GetValidTarget()
    -- CURRENT TARGET?
    if DoesUnitExist("reticleover") then
        for i = 1, 6 do
            local bossTag = "boss" .. i
            if DoesUnitExist(bossTag) and AreUnitsEqual("reticleover", bossTag) then
                TTK.lastTargetTag = bossTag
                return bossTag
            end
        end

        -- DUMMY?
        local currentHealth, maxHealth = GetUnitPower("reticleover", POWERTYPE_HEALTH)
        if maxHealth and maxHealth >= 20500000 and maxHealth <= 21500000 then
            TTK.lastTargetTag = "reticleover"
            return "reticleover"
        end
    end

    -- FALLBACK WHEN LOOKING AWAY
    if TTK.lastTargetTag and TTK.lastTargetTag ~= "reticleover" and DoesUnitExist(TTK.lastTargetTag) then
        return TTK.lastTargetTag
    end

    -- FALLBACK WHEN NO BOSS
    if not TTK.lastTargetTag then
        for i = 1, 6 do
            local bossTag = "boss" .. i
            if DoesUnitExist(bossTag) then
                TTK.lastTargetTag = bossTag
                return bossTag
            end
        end
    end

    return nil
end

---------------------------------------------------------------------------
-- RESET AND NIL VARIABLES
---------------------------------------------------------------------------
function TTK.ResetFightData()
    TTK.currentTargetTag = nil
    TTK.lastTargetTag = nil
    TTK.healthHistory = {}
    TTK.smoothedDPS = 0
    TTK.smoothedTTK = -1
    TTK.hasTriggered = false
    TTK.UpdateVisuals(-1, 0, 0, 1)
    TTK.UpdateVisibility()
end

---------------------------------------------------------------------------
-- UPDATE LOOP
---------------------------------------------------------------------------
function TTK.OnUpdateHandler()
    if not TTK.SV.isEnabledAddon then return end

    local currentTime = GetGameTimeMilliseconds()
    local unitTag = TTK.GetValidTarget()

    if not unitTag then
        if TTK.currentTargetTag then TTK.ResetFightData() end
        return
    end

    if not IsUnitAttackable(unitTag) or IsUnitDead(unitTag) then
        if IsUnitDead(unitTag) then TTK.UpdateVisuals(0, 0, 0, 1) end
        return
    end

    local currentHealth, maxHealth = GetUnitPower(unitTag, POWERTYPE_HEALTH)

    -- RESET ON TARGET CHANGE
    if TTK.currentTargetTag ~= unitTag then
        TTK.currentTargetTag = unitTag
        TTK.healthHistory = {}
        TTK.smoothedDPS = 0
        TTK.smoothedTTK = -1
        TTK.hasTriggered = false
        TTK.UpdateVisibility()
    end

    table.insert(TTK.healthHistory, {time = currentTime, hp = currentHealth})

    local averageTime = TTK.SV.averageTimeSec * 1000

    while #TTK.healthHistory > 1 and TTK.healthHistory[1].time < (currentTime - averageTime) do
        table.remove(TTK.healthHistory, 1)
    end

    local deltaTimeSec = (currentTime - TTK.healthHistory[1].time) / 1000
    if deltaTimeSec < 1.0 then return end

    local deltaHealth = TTK.healthHistory[1].hp - currentHealth
    local rawDPS = math.max(0, deltaHealth / deltaTimeSec)

    local healthPercent = currentHealth / maxHealth
    local executeMod = 1.0 + (TTK.SV.factorExecute - 1.0) * (1.0 - healthPercent)
    local initialMod = 1.0 + (TTK.SV.factorInitial - 1.0) * healthPercent

    local projectedDPS = (rawDPS / initialMod) * executeMod
    local currentTTK = (projectedDPS > 0) and (currentHealth / projectedDPS) or -1

    -- SMOOTHENING DPS
    local alpha = TTK.SV.smoothingMultiplier
    if TTK.smoothedDPS == 0 then
        TTK.smoothedDPS = rawDPS
    else
        TTK.smoothedDPS = (rawDPS * alpha) + (TTK.smoothedDPS * (1 - alpha))
    end

    -- SMOOTHENING TTK
    if currentTTK > 0 then
        if TTK.smoothedTTK <= 0 then
            TTK.smoothedTTK = currentTTK
        else
            TTK.smoothedTTK = (currentTTK * alpha) + (TTK.smoothedTTK * (1 - alpha))
        end
    else
        TTK.smoothedTTK = -1
    end

    TTK.UpdateVisuals(TTK.smoothedTTK, TTK.smoothedDPS, currentHealth, maxHealth)
end

---------------------------------------------------------------------------
-- COMBAT STATE HANDLER
---------------------------------------------------------------------------
function TTK.OnCombatState()
    TTK.isCombat = IsUnitInCombat("player")
    TTK.UpdateVisibility()
end