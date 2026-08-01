SustainMonitor = SustainMonitor or {}
local SM = SustainMonitor

SM.name    = "SustainMonitor"
SM.version = "1.5.4"

SM.worldName   = GetWorldName()
SM.displayName = GetDisplayName()

local GetGameTimeMilliseconds = GetGameTimeMilliseconds
local GetUnitPower    = GetUnitPower
local GetPlayerStat   = GetPlayerStat
local GetAbilityName  = GetAbilityName
local mathFloor   = math.floor
local mathAbs     = math.abs
local mathMax     = math.max
local mathMin     = math.min
local stringFormat = string.format

---------------------------------------------------------------------------
local MIN_DELTA_MS  = 50
local DEFAULT_ALPHA = 0.3
local TTE_ALPHA     = 0.15
local BURN_RATE_THRESHOLD = -1
local HISTORY_MAX   = 60

---------------------------------------------------------------------------
local resources = {}
local histories = {}
local inCombat      = false
local playerIsDead  = false

local barCosts = {}
local avgBarCost = {}
local abilityCostMap = {}

local combatCastCounts = {}
local totalCombatCasts = 0

local function CreateResourceData()
    return {
        lastTime       = 0,
        lastValue      = 0,
        burnRate       = 0,
        timeToEmpty    = -1,
        current        = 0,
        max            = 0,
        currentPercent = 100,
        regenRate      = 0,
        castsRemaining = -1,
    }
end

---------------------------------------------------------------------------
local mechanicToPower = {}

local function InitMechanicMap()
    if COMBAT_MECHANIC_FLAGS_MAGICKA then
        mechanicToPower[COMBAT_MECHANIC_FLAGS_MAGICKA] = POWERTYPE_MAGICKA
    end
    if COMBAT_MECHANIC_FLAGS_STAMINA then
        mechanicToPower[COMBAT_MECHANIC_FLAGS_STAMINA] = POWERTYPE_STAMINA
    end
    -- Direct mapping as fallback (they're often the same value)
    mechanicToPower[POWERTYPE_MAGICKA] = POWERTYPE_MAGICKA
    mechanicToPower[POWERTYPE_STAMINA] = POWERTYPE_STAMINA
end

---------------------------------------------------------------------------
function SM.InitCore()
    resources[POWERTYPE_MAGICKA] = CreateResourceData()
    resources[POWERTYPE_STAMINA] = CreateResourceData()
    resources[POWERTYPE_HEALTH]  = CreateResourceData()

    histories[POWERTYPE_MAGICKA] = {}
    histories[POWERTYPE_STAMINA] = {}
    histories[POWERTYPE_HEALTH]  = {}

    InitMechanicMap()
    SM.SnapshotAllResources()
end

function SM.SnapshotAllResources()
    local regenStats = {
        [POWERTYPE_MAGICKA] = STAT_MAGICKA_REGEN_COMBAT,
        [POWERTYPE_STAMINA] = STAT_STAMINA_REGEN_COMBAT,
        [POWERTYPE_HEALTH]  = STAT_HEALTH_REGEN_COMBAT,
    }

    for powerType, res in pairs(resources) do
        local cur, max, effMax = GetUnitPower("player", powerType)
        if cur and effMax then
            res.current = cur
            res.max     = effMax
            res.currentPercent = (effMax > 0) and (cur / effMax * 100) or 100
        end
        local statType = regenStats[powerType]
        if statType and GetPlayerStat then
            res.regenRate = GetPlayerStat(statType) or 0
        end
    end
end

---------------------------------------------------------------------------
function SM.ResetResource(powerType)
    local res = resources[powerType]
    if not res then return end

    res.lastTime    = 0
    res.lastValue   = 0
    res.burnRate    = 0
    res.timeToEmpty = -1

    local cur, max, effMax = GetUnitPower("player", powerType)
    if cur and effMax then
        res.current = cur
        res.max     = effMax
        res.currentPercent = (effMax > 0) and (cur / effMax * 100) or 100
    end

    -- Clear history
    if histories[powerType] then
        histories[powerType] = {}
    end
end

function SM.ResetAllResources()
    for powerType, _ in pairs(resources) do
        SM.ResetResource(powerType)
    end
    SM.SnapshotAllResources()
end

---------------------------------------------------------------------------
local function ScanSingleBar(hotbarCategory)
    local costs = { [POWERTYPE_MAGICKA] = {}, [POWERTYPE_STAMINA] = {} }
    if not hotbarCategory then return costs end
    if not GetSlotBoundId then return costs end

    local sv = SM.savedVars
    local debug = sv and sv.debugMode

    for slotIndex = 3, 7 do  -- slots 3-7 = 5 ability slots (8 = ultimate)
        local ok, abilityId = pcall(GetSlotBoundId, slotIndex, hotbarCategory)
        if ok and abilityId and abilityId > 0 then
            local abilityName = GetAbilityName and GetAbilityName(abilityId) or "?"
            local found = false

            -- Approach 1: GetAbilityCost(id, mechanicType) — per-mechanic query
            for _, pt in ipairs({ POWERTYPE_MAGICKA, POWERTYPE_STAMINA }) do
                local mechFlag = pt  -- try powertype directly as mechanic flag
                if pt == POWERTYPE_MAGICKA and COMBAT_MECHANIC_FLAGS_MAGICKA then
                    mechFlag = COMBAT_MECHANIC_FLAGS_MAGICKA
                elseif pt == POWERTYPE_STAMINA and COMBAT_MECHANIC_FLAGS_STAMINA then
                    mechFlag = COMBAT_MECHANIC_FLAGS_STAMINA
                end
                local ok2, cost = pcall(GetAbilityCost, abilityId, mechFlag)
                if ok2 and cost and cost > 0 then
                    costs[pt][#costs[pt] + 1] = cost
                    abilityCostMap[abilityId] = { cost = cost, powerType = pt }
                    found = true
                    if debug then
                        local ptName = (pt == POWERTYPE_MAGICKA) and "Mag" or "Stam"
                        d(string.format("|c999999[SM Scan]|r Slot%d: %s [%d] = %d %s (2-arg)",
                            slotIndex, abilityName, abilityId, cost, ptName))
                    end
                end
            end

            -- Approach 2: GetAbilityCostPerTick — for channeled abilities (beams, etc.)
            if not found and GetAbilityCostPerTick then
                for _, pt in ipairs({ POWERTYPE_MAGICKA, POWERTYPE_STAMINA }) do
                    local mechFlag = pt
                    if pt == POWERTYPE_MAGICKA and COMBAT_MECHANIC_FLAGS_MAGICKA then
                        mechFlag = COMBAT_MECHANIC_FLAGS_MAGICKA
                    elseif pt == POWERTYPE_STAMINA and COMBAT_MECHANIC_FLAGS_STAMINA then
                        mechFlag = COMBAT_MECHANIC_FLAGS_STAMINA
                    end
                    local ok4, costPerTick = pcall(GetAbilityCostPerTick, abilityId, mechFlag)
                    if ok4 and costPerTick and costPerTick > 0 then
                        costs[pt][#costs[pt] + 1] = costPerTick
                        abilityCostMap[abilityId] = { cost = costPerTick, powerType = pt }
                        found = true
                        if debug then
                            local ptName = (pt == POWERTYPE_MAGICKA) and "Mag" or "Stam"
                            d(string.format("|c999999[SM Scan]|r Slot%d: %s [%d] = %d %s/tick (CostPerTick)",
                                slotIndex, abilityName, abilityId, costPerTick, ptName))
                        end
                        break
                    end
                end
                if not found then
                    for mechFlag = 0, 10 do
                        local ok5, costPerTick = pcall(GetAbilityCostPerTick, abilityId, mechFlag)
                        if ok5 and costPerTick and costPerTick > 0 then
                            local pt = mechanicToPower[mechFlag]
                                    or ((mechFlag >= 4) and POWERTYPE_STAMINA or POWERTYPE_MAGICKA)
                            if costs[pt] then
                                costs[pt][#costs[pt] + 1] = costPerTick
                                abilityCostMap[abilityId] = { cost = costPerTick, powerType = pt }
                                found = true
                                if debug then
                                    local ptName = (pt == POWERTYPE_MAGICKA) and "Mag" or "Stam"
                                    d(string.format("|c999999[SM Scan]|r Slot%d: %s [%d] = %d %s/tick (CostPerTick brute mech=%d)",
                                        slotIndex, abilityName, abilityId, costPerTick, ptName, mechFlag))
                                end
                                break
                            end
                        end
                    end
                end
            end

            -- Approach 3: Brute-force GetAbilityCost with all mechanic flags 0-10
            if not found then
                for mechFlag = 0, 10 do
                    local ok6, cost = pcall(GetAbilityCost, abilityId, mechFlag)
                    if ok6 and cost and cost > 0 then
                        local pt = mechanicToPower[mechFlag]
                                or ((mechFlag >= 4) and POWERTYPE_STAMINA or POWERTYPE_MAGICKA)
                        if costs[pt] then
                            costs[pt][#costs[pt] + 1] = cost
                            abilityCostMap[abilityId] = { cost = cost, powerType = pt }
                            found = true
                            if debug then
                                local ptName = (pt == POWERTYPE_MAGICKA) and "Mag" or "Stam"
                                d(string.format("|c999999[SM Scan]|r Slot%d: %s [%d] = %d %s (brute mech=%d)",
                                    slotIndex, abilityName, abilityId, cost, ptName, mechFlag))
                            end
                            break
                        end
                    end
                end
                if not found and debug then
                    d(string.format("|c999999[SM Scan]|r Slot%d: %s [%d] = NO COST FOUND (all 3 approaches failed, will learn from combat)",
                        slotIndex, abilityName, abilityId))
                end
            end

            -- Log combat log entry for ability scan
            if SM.LogEntry then
                local magCost = 0
                local stamCost = 0
                for _, c in ipairs(costs[POWERTYPE_MAGICKA]) do magCost = magCost + c end
                for _, c in ipairs(costs[POWERTYPE_STAMINA]) do stamCost = stamCost + c end
                SM.LogEntry("ABILITY_SCAN", {
                    slot = slotIndex, id = abilityId, name = abilityName,
                    found = found, bar = hotbarCategory,
                    magCost = magCost, stamCost = stamCost
                })
            end
        end
    end
    return costs
end

local function ComputeAverage(costList)
    if not costList or #costList == 0 then return 0 end
    local sum = 0
    for _, c in ipairs(costList) do sum = sum + c end
    return sum / #costList
end

function SM.ScanAbilityCosts()
    local categories = {}
    if HOTBAR_CATEGORY_PRIMARY then categories[#categories + 1] = HOTBAR_CATEGORY_PRIMARY end
    if HOTBAR_CATEGORY_BACKUP  then categories[#categories + 1] = HOTBAR_CATEGORY_BACKUP  end

    for _, cat in ipairs(categories) do
        barCosts[cat] = ScanSingleBar(cat)
        avgBarCost[cat] = {}
        for _, pt in ipairs({ POWERTYPE_MAGICKA, POWERTYPE_STAMINA }) do
            avgBarCost[cat][pt] = ComputeAverage(barCosts[cat][pt])
        end
    end

    -- Debug output
    local sv = SM.savedVars
    if sv and sv.debugMode then
        for _, cat in ipairs(categories) do
            local barName = (cat == HOTBAR_CATEGORY_PRIMARY) and "Front" or "Back"
            for _, pt in ipairs({ POWERTYPE_MAGICKA, POWERTYPE_STAMINA }) do
                local ptName = (pt == POWERTYPE_MAGICKA) and "Mag" or "Stam"
                local avg = avgBarCost[cat] and avgBarCost[cat][pt] or 0
                local count = barCosts[cat] and barCosts[cat][pt] and #barCosts[cat][pt] or 0
                d(string.format("|c999999[SM Debug]|r %sBar %s: %d skills, avg cost=%.0f",
                    barName, ptName, count, avg))
            end
        end
    end
end

function SM.GetActiveBarAvgCost(powerType)
    local activeBar
    if GetActiveHotbarCategory then
        local ok, cat = pcall(GetActiveHotbarCategory)
        if ok and cat then activeBar = cat end
    end
    -- Fallback to primary bar
    if not activeBar then activeBar = HOTBAR_CATEGORY_PRIMARY end
    if not activeBar then return 0 end

    if avgBarCost[activeBar] and avgBarCost[activeBar][powerType] then
        return avgBarCost[activeBar][powerType]
    end
    return 0
end

local barSwapPending = false
local BAR_SWAP_DEBOUNCE_MS = 250

function SM.OnActionSlotsUpdated()
    if barSwapPending then return end  -- already scheduled
    barSwapPending = true
    zo_callLater(function()
        barSwapPending = false
        if SM.LogEntry then SM.LogEntry("BAR_SWAP", {}) end
        SM.ScanAbilityCosts()
    end, BAR_SWAP_DEBOUNCE_MS)
end

---------------------------------------------------------------------------
local pendingCostLearn = nil
local learnedCosts = {}
local COST_LEARN_DELAY  = 300
local COST_LEARN_ALPHA  = 0.3
local COST_LEARN_MIN    = 100

function SM.ResetCombatUsage()
    combatCastCounts = {}
    totalCombatCasts = 0
    pendingCostLearn = nil
    -- Keep learnedCosts across combats (they stabilize over time)
end

function SM.TrackAbilityUsage(abilityId)
    if not abilityId or abilityId <= 0 then return end
    combatCastCounts[abilityId] = (combatCastCounts[abilityId] or 0) + 1
    totalCombatCasts = totalCombatCasts + 1

    if not abilityCostMap[abilityId] then
        local stamRes = resources[POWERTYPE_STAMINA]
        local magRes  = resources[POWERTYPE_MAGICKA]
        pendingCostLearn = {
            abilityId = abilityId,
            stam = stamRes and stamRes.current or 0,
            mag  = magRes  and magRes.current  or 0,
            time = GetGameTimeMilliseconds(),
        }
        zo_callLater(function()
            SM.ResolveCostLearn()
        end, COST_LEARN_DELAY)
    end
end

function SM.ResolveCostLearn()
    if not pendingCostLearn then return end
    local pending = pendingCostLearn
    pendingCostLearn = nil

    local abilityId = pending.abilityId
    local stamRes = resources[POWERTYPE_STAMINA]
    local magRes  = resources[POWERTYPE_MAGICKA]
    if not stamRes or not magRes then return end

    -- Calculate raw resource drop (positive = resource was spent)
    local stamDrop = pending.stam - stamRes.current
    local magDrop  = pending.mag  - magRes.current

    local elapsed = (GetGameTimeMilliseconds() - pending.time) / 1000
    local stamRegen = stamRes.regenRate * elapsed
    local magRegen  = magRes.regenRate  * elapsed
    local stamCost = stamDrop + stamRegen
    local magCost  = magDrop  + magRegen
    local cost, powerType
    if stamCost > COST_LEARN_MIN and stamCost > magCost then
        cost = stamCost
        powerType = POWERTYPE_STAMINA
    elseif magCost > COST_LEARN_MIN then
        cost = magCost
        powerType = POWERTYPE_MAGICKA
    end

    if not cost or cost <= 0 then return end

    local learned = learnedCosts[abilityId]
    if learned then
        learned.cost = COST_LEARN_ALPHA * cost + (1 - COST_LEARN_ALPHA) * learned.cost
        learned.samples = learned.samples + 1
    else
        learned = { cost = cost, powerType = powerType, samples = 1 }
        learnedCosts[abilityId] = learned
    end

    abilityCostMap[abilityId] = { cost = learned.cost, powerType = learned.powerType }

    local sv = SM.savedVars
    if sv and sv.debugMode then
        local name = GetAbilityName and GetAbilityName(abilityId) or "?"
        local ptName = (powerType == POWERTYPE_MAGICKA) and "Mag" or "Stam"
        d(string.format("|c00FF00[SM Learn]|r %s [%d]: drop=%.0f regen=%.0f -> cost=%.0f %s (EMA=%.0f, n=%d)",
            name, abilityId, (powerType == POWERTYPE_STAMINA) and stamDrop or magDrop,
            (powerType == POWERTYPE_STAMINA) and stamRegen or magRegen,
            cost, ptName, learned.cost, learned.samples))
    end

    -- Log it
    if SM.LogEntry then
        SM.LogEntry("COST_LEARNED", {
            id = abilityId,
            observed = mathFloor(cost),
            emaCost = mathFloor(learned.cost),
            pt = powerType,
            samples = learned.samples,
        })
    end
end

function SM.GetSmartCost(powerType)
    if totalCombatCasts >= 5 then
        local weightedSum = 0
        local weightTotal = 0

        for abilityId, count in pairs(combatCastCounts) do
            local info = abilityCostMap[abilityId]
            if info and info.powerType == powerType and info.cost > 0 then
                weightedSum = weightedSum + info.cost * count
                weightTotal = weightTotal + count
            end
        end

        if weightTotal > 0 then
            local weightedCost = weightedSum / weightTotal

            local sv = SM.savedVars
            if sv and sv.debugMode and totalCombatCasts % 10 == 0 then
                local topId, topCount = 0, 0
                for id, cnt in pairs(combatCastCounts) do
                    local info = abilityCostMap[id]
                    if info and info.powerType == powerType and cnt > topCount then
                        topId, topCount = id, cnt
                    end
                end
                local topName = topId > 0 and GetAbilityName and GetAbilityName(topId) or "?"
                d(string.format("|c999999[SM Smart]|r Weighted cost=%.0f (top: %s x%d, total=%d casts)",
                    weightedCost, topName, topCount, totalCombatCasts))
            end

            return weightedCost
        end
    end

    return SM.GetActiveBarAvgCost(powerType)
end

---------------------------------------------------------------------------
function SM.GetAutoFocusResource()
    local magTotal, stamTotal = 0, 0

    for abilityId, count in pairs(combatCastCounts) do
        local info = abilityCostMap[abilityId]
        if info and info.cost and info.cost > 0 then
            if info.powerType == POWERTYPE_MAGICKA then
                magTotal = magTotal + info.cost * count
            elseif info.powerType == POWERTYPE_STAMINA then
                stamTotal = stamTotal + info.cost * count
            end
        end
    end

    if magTotal == 0 and stamTotal == 0 then
        for _, info in pairs(abilityCostMap) do
            if info.cost and info.cost > 0 then
                if info.powerType == POWERTYPE_MAGICKA then
                    magTotal = magTotal + 1
                elseif info.powerType == POWERTYPE_STAMINA then
                    stamTotal = stamTotal + 1
                end
            end
        end
    end

    if magTotal > stamTotal then return POWERTYPE_MAGICKA
    elseif stamTotal > magTotal then return POWERTYPE_STAMINA
    else return nil end
end

function SM.GetFocusedResource()
    local sv = SM.savedVars
    if not sv then return nil end

    local focus = sv.resourceFocus or "auto"
    if focus == "all" then return nil end
    if focus == "magicka" then return POWERTYPE_MAGICKA end
    if focus == "stamina" then return POWERTYPE_STAMINA end
    if focus == "health" then return POWERTYPE_HEALTH end
    if focus == "auto" then return SM.GetAutoFocusResource() end
    return nil
end

---------------------------------------------------------------------------
function SM.GetResourceData(powerType)
    return resources[powerType]
end

function SM.GetHistory(powerType)
    return histories[powerType]
end

function SM.IsInCombat()
    return inCombat
end

---------------------------------------------------------------------------
function SM.RecordHistory()
    if not inCombat then return end

    for powerType, res in pairs(resources) do
        local history = histories[powerType]
        if history then
            history[#history + 1] = res.currentPercent
            if #history > HISTORY_MAX then
                table.remove(history, 1)
            end
        end
    end

    if SM.LogResourceSnapshot then SM.LogResourceSnapshot() end
end

---------------------------------------------------------------------------
function SM.OnPowerUpdate(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
    local res = resources[powerType]
    if not res then return end

    local sv = SM.savedVars
    if not sv or not sv.enabled then return end

    if powerType == POWERTYPE_MAGICKA and not sv.showMagicka then return end
    if powerType == POWERTYPE_STAMINA and not sv.showStamina then return end
    if powerType == POWERTYPE_HEALTH  and not sv.showHealth  then return end

    local now = GetGameTimeMilliseconds()

    res.current = powerValue
    res.max     = powerEffectiveMax
    res.currentPercent = (powerEffectiveMax > 0) and (powerValue / powerEffectiveMax * 100) or 100

    if res.lastTime > 0 then
        local dtMs = now - res.lastTime
        if dtMs >= MIN_DELTA_MS then
            local dt          = dtMs / 1000
            local delta       = powerValue - res.lastValue
            local instantRate = delta / dt

            local alpha    = sv.smoothingAlpha or DEFAULT_ALPHA
            res.burnRate   = alpha * instantRate + (1 - alpha) * res.burnRate

            if res.burnRate < BURN_RATE_THRESHOLD then
                local rawTTE = powerValue / mathAbs(res.burnRate)
                if res.timeToEmpty >= 0 then
                    res.timeToEmpty = TTE_ALPHA * rawTTE + (1 - TTE_ALPHA) * res.timeToEmpty
                else
                    res.timeToEmpty = rawTTE
                end
            else
                res.timeToEmpty = -1
            end
        end
    end

    res.lastTime  = now
    res.lastValue = powerValue

    local smartCost = SM.GetSmartCost(powerType)
    if smartCost > 0 then
        res.castsRemaining = mathFloor(powerValue / smartCost)
    else
        res.castsRemaining = -1
    end

    if SM.UpdateResourceUI then
        SM.UpdateResourceUI(powerType)
    end

    if SM.CheckWarnings then
        SM.CheckWarnings(powerType)
    end
end

---------------------------------------------------------------------------
function SM.OnCombatState(eventCode, inCombatNow)
    inCombat = inCombatNow

    if inCombatNow then
        SM.ResetAllResources()
        SM.ResetCombatUsage()
        SM.ScanAbilityCosts()
        if SM.ScanPotionType then SM.ScanPotionType() end
        if SM.LogCombatStart then SM.LogCombatStart() end
        if SM.ShowHUD then SM.ShowHUD() end
    else
        if SM.LogCombatEnd then SM.LogCombatEnd() end
        if SM.HideHUDDelayed then SM.HideHUDDelayed() end
    end
end

---------------------------------------------------------------------------
function SM.OnPlayerActivated()
    SM.ResetAllResources()
    inCombat = IsUnitInCombat("player")

    if SM.ScanPotionType then SM.ScanPotionType() end

    if inCombat then
        if SM.ShowHUD then SM.ShowHUD() end
    else
        if SM.HideHUD then SM.HideHUD() end
    end
end

---------------------------------------------------------------------------
function SM.OnPlayerDead()
    playerIsDead = true
    SM.ResetAllResources()
    if SM.HideHUD then SM.HideHUD() end
end

---------------------------------------------------------------------------
function SM.OnPlayerAlive()
    playerIsDead = false
    SM.ResetAllResources()
end

---------------------------------------------------------------------------
function SM.IsPlayerDead()
    return playerIsDead
end

---------------------------------------------------------------------------
function SM.FormatRate(rate, compact)
    local absRate = mathAbs(rate)
    local sign    = rate >= 0 and "+" or "-"

    local formatted
    if compact or absRate >= 10000 then
        formatted = stringFormat("%.1fk", absRate / 1000)
    else
        formatted = stringFormat("%.0f", absRate)
    end

    return sign .. formatted .. "/s"
end

function SM.FormatTime(seconds, castsRemaining)
    local timeStr
    if seconds < 0 then
        timeStr = SM.L and SM.L.INFINITY or "\226\136\158"
    elseif seconds > 99 then
        timeStr = ">99s"
    else
        timeStr = stringFormat("~%.0fs", seconds)
    end

    if castsRemaining and castsRemaining >= 0 then
        timeStr = timeStr .. " [" .. castsRemaining .. "]"
    end

    return timeStr
end
