-- Beltalowda Consumable Tracker
-- Scans the local player's active consumable buffs (food/drink, AP, XP)
-- and broadcasts compact time-remaining values via LGB protocol 228.
--
-- Architecture: Each player scans only their own buffs (~30 GetUnitBuffInfo
-- calls) and broadcasts a compact summary. This is far more performant than
-- polling all 24 group members' buffs and provides cross-zone coverage.

Beltalowda = Beltalowda or {}
Beltalowda.Data = Beltalowda.Data or {}
Beltalowda.Data.ConsumableTracker = {}

local CT = Beltalowda.Data.ConsumableTracker

-- ============================================================================
-- Constants
-- ============================================================================

-- Consumable categories
CT.CATEGORY_FOOD = "food"
CT.CATEGORY_AP = "ap"
CT.CATEGORY_XP = "xp"

-- Maximum time value for broadcast (4 hours in seconds)
CT.MAX_TIME = 14400

-- Broadcast precision: 10-second granularity
CT.PRECISION = 10

-- Periodic re-broadcast interval (60 seconds)
CT.REBROADCAST_INTERVAL = 60000

-- Callback name for change notifications
CT.CALLBACK_NAME = "BeltalowdaConsumableTrackerChanged"

-- ============================================================================
-- AP Buff Ability IDs
-- Alliance Point gain consumable buffs (War Tortes, Pelinal's Ferocity, etc.)
-- PLACEHOLDER: These need to be populated from UESP or in-game discovery.
-- LibFoodDrinkBuff explicitly blacklists these, so we maintain our own table.
-- ============================================================================

CT.AP_BUFF_ABILITY_IDS = {
    -- War Torte line (confirmed PTS 2026-02-28)
    [147687] = true,    -- Colovian War Torte (50% AP, 30m)
    [147733] = true,    -- Molten War Torte (100% AP, 30m)
    [147734] = true,    -- White-Gold War Torte (150% AP, 30m)

    -- Crown store AP scrolls (PLACEHOLDER — needs PTS verification)
    [64537] = true,     -- Crown Grand Alliance Point Scroll
    [87837] = true,     -- Crown Alliance Point Scroll (variant)
    [87838] = true,     -- Crown Grand Alliance Point Scroll (variant)
}

-- ============================================================================
-- XP Buff Ability IDs
-- Experience gain consumable buffs (Psijic Ambrosia, Crown Scrolls, etc.)
-- PLACEHOLDER: These need to be populated from UESP or in-game discovery.
-- LibFoodDrinkBuff explicitly blacklists these, so we maintain our own table.
-- ============================================================================

CT.XP_BUFF_ABILITY_IDS = {
    -- Psijic Ambrosia line (confirmed PTS 2026-02-28)
    [64210] = true,     -- Psijic Ambrosia (50% XP, 30m)
    [89683] = true,     -- Aetherial Ambrosia (100% XP)
    [66788] = true,     -- Mythic Aetherial Ambrosia (150% XP) (PLACEHOLDER — needs PTS verification)

    -- Gold Coast Experience Scrolls (confirmed PTS 2026-02-28)
    [85503] = true,     -- Grand Gold Coast Experience Scroll

    -- Crown Experience Scrolls (PLACEHOLDER — needs PTS verification)
    [64208] = true,     -- Crown Experience Scroll (50% XP)
    [64209] = true,     -- Crown Grand Experience Scroll (100% XP)
    [66792] = true,     -- Crown Crate Experience Scroll (50% XP)
    [66793] = true,     -- Crown Crate Grand Experience Scroll (100% XP)
    [87835] = true,     -- Crown Experience Scroll (variant)
    [87836] = true,     -- Crown Grand Experience Scroll (variant)
}

-- ============================================================================
-- State
-- ============================================================================

CT.initialized = false
CT.logger = nil

-- Local player's consumable state
CT.localState = {
    foodRemain = 0,     -- seconds remaining on food/drink buff (at scan time)
    apRemain = 0,       -- seconds remaining on AP buff (at scan time)
    xpRemain = 0,       -- seconds remaining on XP buff (at scan time)
    apAbilityId = nil,  -- active AP buff ability ID (for icon lookup)
    xpAbilityId = nil,  -- active XP buff ability ID (for icon lookup)
    lastScanTime = 0,   -- GetGameTimeMilliseconds() when last scanned
}

-- Previous broadcast values (to detect changes)
CT.previousBroadcast = {
    foodRemain = -1,
    apRemain = -1,
    xpRemain = -1,
}

-- Group consumable data: groupData[characterName] = { foodRemain, apRemain, xpRemain, lastUpdate }
CT.groupData = {}

-- ============================================================================
-- Local Player Scanning
-- ============================================================================

--[[
    Scan the local player's buffs for active consumables.
    Uses LibFoodDrinkBuff for food/drink detection, and custom tables
    for AP and XP buff categories.
    
    Returns true if any value changed from previous state.
]]--
function CT.ScanLocalPlayer()
    local changed = false
    local newFood = 0
    local newAP = 0
    local newXP = 0

    -- Food/Drink via LibFoodDrinkBuff
    local foodAbilityId = nil
    if LibFoodDrinkBuff then
        local isActive, timeLeft, abilityId = LibFoodDrinkBuff:IsFoodBuffActiveAndGetTimeLeft("player")
        if isActive and timeLeft then
            newFood = math.min(CT.MAX_TIME, math.max(0, math.floor(timeLeft)))
            foodAbilityId = abilityId
        end
    end

    -- AP and XP buffs via direct buff scan
    local apAbilityId = nil
    local xpAbilityId = nil
    local numBuffs = GetNumBuffs("player")
    for i = 1, numBuffs do
        local _, timeStarted, timeEnding, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", i)
        if abilityId then
            if CT.AP_BUFF_ABILITY_IDS[abilityId] then
                local remaining = timeEnding - (GetGameTimeMilliseconds() / 1000)
                newAP = math.min(CT.MAX_TIME, math.max(0, math.floor(remaining)))
                apAbilityId = abilityId
            end
            if CT.XP_BUFF_ABILITY_IDS[abilityId] then
                local remaining = timeEnding - (GetGameTimeMilliseconds() / 1000)
                newXP = math.min(CT.MAX_TIME, math.max(0, math.floor(remaining)))
                xpAbilityId = abilityId
            end
        end
    end

    -- Check for changes
    if newFood ~= CT.localState.foodRemain
        or newAP ~= CT.localState.apRemain
        or newXP ~= CT.localState.xpRemain then
        changed = true
    end

    CT.localState.foodRemain = newFood
    CT.localState.apRemain = newAP
    CT.localState.xpRemain = newXP
    CT.localState.foodAbilityId = foodAbilityId
    CT.localState.apAbilityId = apAbilityId
    CT.localState.xpAbilityId = xpAbilityId
    CT.localState.lastScanTime = GetGameTimeMilliseconds()

    return changed
end

--[[
    Broadcast the local player's consumable state if values changed
    or if force is true (periodic re-broadcast).
]]--
function CT.BroadcastIfChanged(force)
    if GetGroupSize() == 0 then return end

    -- Quantize to broadcast precision (10s units)
    local foodQ = math.floor(CT.localState.foodRemain / CT.PRECISION)
    local apQ = math.floor(CT.localState.apRemain / CT.PRECISION)
    local xpQ = math.floor(CT.localState.xpRemain / CT.PRECISION)

    local changed = foodQ ~= CT.previousBroadcast.foodRemain
                 or apQ ~= CT.previousBroadcast.apRemain
                 or xpQ ~= CT.previousBroadcast.xpRemain

    if changed or force then
        CT.previousBroadcast.foodRemain = foodQ
        CT.previousBroadcast.apRemain = apQ
        CT.previousBroadcast.xpRemain = xpQ

        if Beltalowda.network and Beltalowda.network.BroadcastConsumableState then
            Beltalowda.network.BroadcastConsumableState(foodQ, apQ, xpQ)
        end

        if CT.logger then
            CT.logger:Debug("Consumable broadcast",
                string.format("food=%ds ap=%ds xp=%ds",
                    CT.localState.foodRemain, CT.localState.apRemain, CT.localState.xpRemain))
        end
    end
end

-- ============================================================================
-- Event Handlers
-- ============================================================================

--[[
    Handle food/drink buff changes from LibFoodDrinkBuff's filtered event.
    Callback signature matches EVENT_EFFECT_CHANGED filter:
    changeType, effectSlot, effectName, unitTag, beginTime, endTime,
    stackCount, iconName, buffType, effectType, abilityType,
    statusEffectType, unitName, unitId, abilityId, sourceType
]]--
function CT.OnFoodBuffChanged(changeType, effectSlot, effectName, unitTag, ...)
    -- Only care about player
    if unitTag ~= "player" then return end

    CT.ScanLocalPlayer()
    CT.BroadcastIfChanged(false)
    CALLBACK_MANAGER:FireCallbacks(CT.CALLBACK_NAME)
end

--[[
    Handle general buff changes for AP/XP detection.
    We listen for EVENT_EFFECT_CHANGED on the player and check if the
    abilityId matches our AP or XP tables.
]]--
function CT.OnEffectChanged(eventCode, changeType, effectSlot, effectName,
    unitTag, beginTime, endTime, stackCount, iconName, buffType,
    effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)

    if unitTag ~= "player" then return end

    if CT.AP_BUFF_ABILITY_IDS[abilityId] or CT.XP_BUFF_ABILITY_IDS[abilityId] then
        CT.ScanLocalPlayer()
        CT.BroadcastIfChanged(false)
        CALLBACK_MANAGER:FireCallbacks(CT.CALLBACK_NAME)
    end
end

-- ============================================================================
-- Group Data Management
-- ============================================================================

--[[
    Store received consumable data from a group member.
    Called by GroupBroadcast when protocol 228 data arrives.
    
    @param unitTag: Sender's unit tag
    @param foodRemain: Food time remaining in 10s units
    @param apRemain: AP buff time remaining in 10s units
    @param xpRemain: XP buff time remaining in 10s units
]]--
function CT.OnConsumableDataReceived(unitTag, foodRemain, apRemain, xpRemain)
    local charName = GetUnitName(unitTag)
    if not charName or charName == "" then return end

    CT.groupData[charName] = {
        foodRemain = (foodRemain or 0) * CT.PRECISION,  -- Convert back to seconds
        apRemain = (apRemain or 0) * CT.PRECISION,
        xpRemain = (xpRemain or 0) * CT.PRECISION,
        lastUpdate = GetGameTimeMilliseconds(),
    }

    if CT.logger then
        CT.logger:Debug("Consumable data received",
            string.format("from=%s food=%ds ap=%ds xp=%ds",
                charName,
                CT.groupData[charName].foodRemain,
                CT.groupData[charName].apRemain,
                CT.groupData[charName].xpRemain))
    end

    CALLBACK_MANAGER:FireCallbacks(CT.CALLBACK_NAME)
end

--[[
    Get consumable data for a specific player.
    For the local player, returns live-scanned values.
    For remote players, returns last broadcast values with local countdown.
    
    @param charName: Character name
    @return table { foodRemain, apRemain, xpRemain } in seconds, or nil
]]--
function CT.GetPlayerConsumableData(charName)
    local localName = GetUnitName("player")

    if charName == localName then
        -- Return local data with elapsed countdown since last scan
        local elapsed = 0
        if CT.localState.lastScanTime > 0 then
            elapsed = (GetGameTimeMilliseconds() - CT.localState.lastScanTime) / 1000
        end
        return {
            foodRemain = math.max(0, CT.localState.foodRemain - elapsed),
            apRemain = math.max(0, CT.localState.apRemain - elapsed),
            xpRemain = math.max(0, CT.localState.xpRemain - elapsed),
        }
    end

    -- Return remote data with local countdown applied
    local data = CT.groupData[charName]
    if not data then return nil end

    local elapsed = (GetGameTimeMilliseconds() - data.lastUpdate) / 1000
    return {
        foodRemain = math.max(0, data.foodRemain - elapsed),
        apRemain = math.max(0, data.apRemain - elapsed),
        xpRemain = math.max(0, data.xpRemain - elapsed),
    }
end

--[[
    Get local player's food buff icon and name from stored abilityId.
    Uses GetAbilityIcon()/GetAbilityName() for consistency with AP/XP handling.
    Only available for the local player (remote players don't broadcast ability IDs).
    
    @return iconTexture, buffName, abilityId (or nil, nil, nil)
]]--
function CT.GetLocalFoodBuffDetails()
    local abilityId = CT.localState.foodAbilityId
    if not abilityId then return nil, nil, nil end

    local iconTexture = GetAbilityIcon(abilityId)
    local buffName = GetAbilityName(abilityId)
    if buffName and buffName ~= "" then
        buffName = zo_strformat("<<1>>", buffName)
    end

    return iconTexture, buffName, abilityId
end

--[[
    Clean up data for a group member who left.
    @param characterName: Character name to remove
]]--
function CT.OnGroupMemberLeft(characterName)
    if characterName and CT.groupData[characterName] then
        CT.groupData[characterName] = nil
        CALLBACK_MANAGER:FireCallbacks(CT.CALLBACK_NAME)
    end
end

-- ============================================================================
-- Periodic Re-broadcast
-- ============================================================================

--[[
    Periodic callback to re-scan and re-broadcast consumable state.
    Runs every 60 seconds to keep group data loosely synced.
    Primary freshness comes from event-driven sends on buff gain/loss.
]]--
function CT.PeriodicUpdate()
    CT.ScanLocalPlayer()
    CT.BroadcastIfChanged(true)  -- Force re-broadcast
    CALLBACK_MANAGER:FireCallbacks(CT.CALLBACK_NAME)
end

-- ============================================================================
-- Initialization
-- ============================================================================

function CT.Initialize()
    if CT.initialized then return end

    -- Initialize logger
    if Beltalowda.Logger and Beltalowda.Logger.CreateModuleLogger then
        CT.logger = Beltalowda.Logger.CreateModuleLogger("Consumables")
    end

    -- Register with LibFoodDrinkBuff for food/drink buff change events
    if LibFoodDrinkBuff and LibFoodDrinkBuff.RegisterAbilityIdsFilterOnEventEffectChanged then
        LibFoodDrinkBuff:RegisterAbilityIdsFilterOnEventEffectChanged(
            "BeltalowdaConsumableTracker",
            CT.OnFoodBuffChanged,
            REGISTER_FILTER_UNIT_TAG, "player"
        )
    end

    -- Register for EVENT_EFFECT_CHANGED to detect AP/XP buff changes
    EVENT_MANAGER:RegisterForEvent(
        "BeltalowdaConsumableTracker_EffectChanged",
        EVENT_EFFECT_CHANGED,
        CT.OnEffectChanged
    )
    EVENT_MANAGER:AddFilterForEvent(
        "BeltalowdaConsumableTracker_EffectChanged",
        EVENT_EFFECT_CHANGED,
        REGISTER_FILTER_UNIT_TAG, "player"
    )

    -- Register for group member left events
    EVENT_MANAGER:RegisterForEvent(
        "BeltalowdaConsumableTracker_GroupLeft",
        EVENT_GROUP_MEMBER_LEFT,
        function(eventCode, characterName, reason, isLocalPlayer, isLeader, memberDisplayName, actionRequiredVote)
            CT.OnGroupMemberLeft(characterName)
        end
    )

    -- Initial scan with delay (allow game state to stabilize)
    zo_callLater(function()
        CT.ScanLocalPlayer()
        CT.BroadcastIfChanged(true)

        -- Store local player in group data for consistency
        local localName = GetUnitName("player")
        CT.groupData[localName] = {
            foodRemain = CT.localState.foodRemain,
            apRemain = CT.localState.apRemain,
            xpRemain = CT.localState.xpRemain,
            lastUpdate = GetGameTimeMilliseconds(),
        }

        CALLBACK_MANAGER:FireCallbacks(CT.CALLBACK_NAME)
    end, 2000)

    -- Start periodic re-broadcast timer
    EVENT_MANAGER:RegisterForUpdate(
        "BeltalowdaConsumableTracker_Periodic",
        CT.REBROADCAST_INTERVAL,
        CT.PeriodicUpdate
    )

    CT.initialized = true

    if CT.logger then
        CT.logger:Info("ConsumableTracker initialized")
    end

    -- Debug slash command: /beltabuffs
    -- Watches EVENT_EFFECT_CHANGED on the player and prints every new buff
    -- to chat with abilityId, name, icon, duration, and effectType.
    -- Use this to discover AP/XP buff ability IDs when consuming items on PTS.
    -- Run again to stop watching.
    CT._buffWatcherActive = false
    SLASH_COMMANDS["/beltabuffs"] = function()
        if CT._buffWatcherActive then
            EVENT_MANAGER:UnregisterForEvent("BeltaDebugBuffWatcher", EVENT_EFFECT_CHANGED)
            d("[Beltalowda] Buff watcher STOPPED.")
            CT._buffWatcherActive = false
        else
            EVENT_MANAGER:RegisterForEvent(
                "BeltaDebugBuffWatcher",
                EVENT_EFFECT_CHANGED,
                function(_, changeType, effectSlot, effectName, unitTag, beginTime, endTime,
                         stackCount, iconName, buffType, effectType, abilityType, statusEffectType,
                         unitName, unitId, abilityId, sourceType)
                    -- Only log buff gains (EFFECT_RESULT_GAINED = 1)
                    if changeType ~= EFFECT_RESULT_GAINED then return end

                    local duration = endTime - beginTime
                    local durationMin = math.floor(duration / 60)

                    local apiIcon = GetAbilityIcon(abilityId)
                    d(string.format(
                        "|cFFFF00[BuffWatch]|r |cFF8800%s|r  id=|c00FF00%d|r  dur=|c88CCFF%dm|r  effectType=%d  buffType=%s",
                        effectName, abilityId, durationMin, effectType, tostring(buffType)
                    ))
                    d(string.format("  eventIcon = |cCCCCCC%s|r", iconName))
                    d(string.format("  apiIcon   = |c88FF88%s|r", tostring(apiIcon)))
                end
            )
            EVENT_MANAGER:AddFilterForEvent(
                "BeltaDebugBuffWatcher",
                EVENT_EFFECT_CHANGED,
                REGISTER_FILTER_UNIT_TAG, "player"
            )
            d("[Beltalowda] Buff watcher STARTED. Consume an item and watch chat.")
        end
        CT._buffWatcherActive = not CT._buffWatcherActive
    end
end
