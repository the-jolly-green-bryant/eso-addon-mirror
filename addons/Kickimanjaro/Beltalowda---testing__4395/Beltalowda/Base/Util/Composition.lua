-- Beltalowda Group Composition Analyzer
-- Analyzes group composition and provides warnings

Beltalowda = Beltalowda or {}
Beltalowda.Composition = {}

local Composition = Beltalowda.Composition

-- Composition data for each group member
Composition.groupComposition = {}

-- Composition warnings
Composition.warnings = {}

-- ============================================================================
-- Food Buff Expiry Notifications
-- Tracks per-player food buff state to detect active → expired transitions
-- and prints batched chat notifications via CHAT_ROUTER.
-- ============================================================================

-- Previous food buff state per player: [displayName] = boolean (true = had food)
Composition.previousFoodState = {}

-- Pending expiry notifications batched over a short window
-- Each entry: { displayName = string }
Composition.pendingFoodExpiryNotifications = {}

-- Whether the batch flush timer is currently running
Composition.foodExpiryBatchTimerActive = false

-- Batch window in milliseconds (group notifications within this window)
Composition.FOOD_EXPIRY_BATCH_WINDOW = 2000

-- Chat message color (orange/warning)
Composition.CHAT_COLOR = "|cFFAA00"
Composition.CHAT_PREFIX = "|cFFAA00[Beltalowda]|r "

--[[
    Queue a food buff expiry notification for batching.
    Notifications are collected over FOOD_EXPIRY_BATCH_WINDOW ms and then
    flushed as a single (potentially grouped) chat message.
    
    @param displayName: The player's display name
    @param isSelf: Whether this is the local player
]]
function Composition.QueueFoodExpiryNotification(displayName, isSelf)
    table.insert(Composition.pendingFoodExpiryNotifications, {
        displayName = displayName,
        isSelf = isSelf,
    })

    -- Start the batch timer if not already running
    if not Composition.foodExpiryBatchTimerActive then
        Composition.foodExpiryBatchTimerActive = true
        zo_callLater(function()
            Composition.FlushFoodExpiryNotifications()
        end, Composition.FOOD_EXPIRY_BATCH_WINDOW)
    end
end

--[[
    Flush all pending food expiry notifications as a single chat message.
    If multiple players lost food within the batch window, combine them.
]]
function Composition.FlushFoodExpiryNotifications()
    Composition.foodExpiryBatchTimerActive = false

    local pending = Composition.pendingFoodExpiryNotifications
    Composition.pendingFoodExpiryNotifications = {}

    if #pending == 0 then return end

    local notifyGroup = BeltalowdaVars and BeltalowdaVars.notifications
        and BeltalowdaVars.notifications.foodExpiry
    local notifySelf = BeltalowdaVars and BeltalowdaVars.notifications
        and BeltalowdaVars.notifications.foodExpirySelf

    -- Separate self vs others
    local selfEntries = {}
    local otherEntries = {}
    for _, entry in ipairs(pending) do
        if entry.isSelf then
            table.insert(selfEntries, entry)
        else
            table.insert(otherEntries, entry)
        end
    end

    -- Notify about self
    if notifySelf and #selfEntries > 0 then
        local msg = Composition.CHAT_PREFIX
            .. Composition.CHAT_COLOR
            .. "Your food buff has expired!"
            .. "|r"
        if CHAT_ROUTER then
            CHAT_ROUTER:AddSystemMessage(msg)
        end
    end

    -- Notify about group members
    if notifyGroup and #otherEntries > 0 then
        local msg
        if #otherEntries == 1 then
            msg = Composition.CHAT_PREFIX
                .. Composition.CHAT_COLOR
                .. otherEntries[1].displayName
                .. " lost their food buff"
                .. "|r"
        else
            local names = {}
            for _, entry in ipairs(otherEntries) do
                table.insert(names, entry.displayName)
            end
            msg = Composition.CHAT_PREFIX
                .. Composition.CHAT_COLOR
                .. #otherEntries .. " players lost their food buff: "
                .. table.concat(names, ", ")
                .. "|r"
        end
        if CHAT_ROUTER then
            CHAT_ROUTER:AddSystemMessage(msg)
        end
    end
end

--[[
    Check for food buff state transitions (active → expired) across all
    group members and queue notifications for any detected expirations.
    Called from AnalyzeComposition after consumable data is evaluated.
]]
function Composition.CheckFoodExpiryTransitions()
    -- Skip if neither notification is enabled
    local notifyGroup = BeltalowdaVars and BeltalowdaVars.notifications
        and BeltalowdaVars.notifications.foodExpiry
    local notifySelf = BeltalowdaVars and BeltalowdaVars.notifications
        and BeltalowdaVars.notifications.foodExpirySelf
    if not notifyGroup and not notifySelf then return end

    local groupSize = GetGroupSize()
    if groupSize == 0 then
        Composition.previousFoodState = {}
        return
    end

    local ConsT = Beltalowda.Data and Beltalowda.Data.ConsumableTracker
    if not ConsT or not ConsT.GetPlayerConsumableData then return end

    local localPlayerName = GetUnitName("player")
    local currentState = {}

    for i = 1, groupSize do
        local unitTag = GetGroupUnitTagByIndex(i)
        local charName = GetUnitName(unitTag)
        local displayName = Beltalowda.GetDisplayName(unitTag)
        local cData = ConsT.GetPlayerConsumableData(charName)

        if cData then
            local hasFood = cData.foodRemain > 0
            currentState[displayName] = hasFood

            -- Check for active → expired transition
            local previouslyHadFood = Composition.previousFoodState[displayName]
            if previouslyHadFood == true and not hasFood then
                local isSelf = (charName == localPlayerName)
                Composition.QueueFoodExpiryNotification(displayName, isSelf)
            end
        end
    end

    Composition.previousFoodState = currentState
end

--[[
    Analyze group composition
    Called when equipment data changes
]]--
function Composition.AnalyzeComposition()
    if not Beltalowda.network then
        return
    end
    
    Composition.warnings = {}
    local groupSize = GetGroupSize()
    
    if groupSize == 0 then
        return
    end
    
    -- Collect all sets present in the group AT FULL BONUS
    -- Only count sets that have the full set bonus active (5/5, 2/2, 1/1 depending on set type)
    -- Special case: If player has Volendrung, only count the bar that has Volendrung active
    -- [setId] = number of players wearing the set at full bonus
    local setsPresent = {}
    -- Track which sets each player has at full bonus (for per-player counting)
    local playerSetMap = {}  -- [playerName][setId] = true
    
    for i = 1, groupSize do
        local unitTag = GetGroupUnitTagByIndex(i)
        local equipData = Beltalowda.network.GetEquipmentData(unitTag)
        
        -- Check if this player has Volendrung active
        local playerName = GetUnitName(unitTag)
        local hasVolendrung = false
        local volendrungBar = nil
        
        if Beltalowda.UI and Beltalowda.UI.GroupUltimateDisplay then
            local playerData = Beltalowda.UI.GroupUltimateDisplay.playerData
            if playerData[playerName] and playerData[playerName].hasVolendrung then
                hasVolendrung = true
                volendrungBar = playerData[playerName].volendrungBar or 0
            end
        end
        
        playerSetMap[playerName] = {}
        
        if equipData and equipData.usefulBits and equipData.usefulBits.sets then
            for _, set in ipairs(equipData.usefulBits.sets) do
                -- Only count set as "present" if it has full bonus
                -- Determine required pieces based on set type
                local requiredPieces = set.maxPieces or 5
                
                -- For required/prohibited checks, only count COMPLETED sets (full bonus active)
                if set.pieces >= requiredPieces then
                    -- Special handling for Volendrung: only count sets from the Volendrung bar
                    -- When Volendrung is active, player CANNOT bar swap, so only the Volendrung bar matters
                    if hasVolendrung then
                        -- Only count this set if it's on the Volendrung bar
                        -- set.barInfo contains bar information like " (front only)" or " (back only)"
                        local shouldCount = false
                        
                        if volendrungBar == 0 then
                            -- Main bar (front) has Volendrung - ONLY count sets that are NOT back-only
                            -- Exclude anything marked as " (back only)"
                            if set.barInfo and set.barInfo:find("back only") then
                                -- This is a back bar set, don't count it
                                shouldCount = false
                            else
                                -- This is a front bar or dual bar set, count it
                                shouldCount = true
                            end
                        else
                            -- Backup bar (back) has Volendrung - ONLY count sets that are NOT front-only
                            -- Exclude anything marked as " (front only)"
                            if set.barInfo and set.barInfo:find("front only") then
                                -- This is a front bar set, don't count it
                                shouldCount = false
                            else
                                -- This is a back bar or dual bar set, count it
                                shouldCount = true
                            end
                        end
                        
                        if shouldCount then
                            if not playerSetMap[playerName][set.id] then
                                playerSetMap[playerName][set.id] = true
                                setsPresent[set.id] = (setsPresent[set.id] or 0) + 1
                            end
                        end
                    else
                        -- Normal case: no Volendrung, count all completed sets
                        if not playerSetMap[playerName][set.id] then
                            playerSetMap[playerName][set.id] = true
                            setsPresent[set.id] = (setsPresent[set.id] or 0) + 1
                        end
                    end
                end
            end
        end
    end
    
    -- Check set preferences
    if BeltalowdaVars and BeltalowdaVars.composition and BeltalowdaVars.composition.preferences then
        for setIdKey, preference in pairs(BeltalowdaVars.composition.preferences) do
            -- Ensure setId is a number for comparison with setsPresent
            local setId = tonumber(setIdKey)
            if not setId then
                setId = setIdKey  -- Fallback to original if conversion fails
            end
            
            local setName = Beltalowda.SetDatabase and Beltalowda.SetDatabase.GetSetName(setId) or ("Set #" .. tostring(setId))
            
            local count = setsPresent[setId] or 0
            
            if preference == "required" then
                -- Required set missing - warning
                if count < 1 then
                    table.insert(Composition.warnings, {
                        severity = "high",
                        category = "sets",
                        message = string.format("Required set missing: %s", setName)
                    })
                end
            elseif preference == "prohibited" then
                -- Prohibited set present - warning
                if count > 0 then
                    table.insert(Composition.warnings, {
                        severity = "high",
                        category = "sets",
                        message = string.format("Prohibited set detected: %s", setName)
                    })
                end
            elseif preference == "unique" or preference == "required_unique" then
                -- Required (warn on duplicate): warn if missing AND if duplicated
                if count < 1 then
                    table.insert(Composition.warnings, {
                        severity = "high",
                        category = "sets",
                        message = string.format("Required set missing: %s", setName)
                    })
                elseif count > 1 then
                    table.insert(Composition.warnings, {
                        severity = "medium",
                        category = "sets",
                        message = string.format("Duplicate set detected: %s (%d players)", setName, count)
                    })
                end
            end
            -- "optional" - no warnings needed
        end
    end
    
    -- Check synergy preferences
    if BeltalowdaVars and BeltalowdaVars.composition and BeltalowdaVars.composition.synergyPreferences then
        local SC = Beltalowda.Data and Beltalowda.Data.SynergyComposition
        local ST = Beltalowda.Data and Beltalowda.Data.SynergyTracker
        if SC then
            -- Migrate old synergy preference values to new simplified options
            for synIdKey, pref in pairs(BeltalowdaVars.composition.synergyPreferences) do
                if pref == "required3" or pref == "required4" or pref == "prohibited" then
                    BeltalowdaVars.composition.synergyPreferences[synIdKey] = "optional"
                end
            end
            
            -- Migrate old set preference values ("unique" → "required_unique")
            if BeltalowdaVars.composition.preferences then
                for setIdKey, pref in pairs(BeltalowdaVars.composition.preferences) do
                    if pref == "unique" then
                        BeltalowdaVars.composition.preferences[setIdKey] = "required_unique"
                    end
                end
            end
            
            -- Count synergy providers per player.
            -- Each player can provide a synergy via their SynergyComposition bitmask
            -- (skills and sets detected locally) OR via equipment data (set-based synergies
            -- visible from LGB equipment broadcasts). We merge both sources per-player
            -- to avoid double-counting.
            local synergyProviderCount = {}  -- [synergyId] = number of players providing it
            
            for i = 1, groupSize do
                local unitTag = GetGroupUnitTagByIndex(i)
                local pName = GetUnitName(unitTag)
                
                -- Bitmask from SynergyComposition (if available for this player)
                local playerBitmask = SC.compositionData and SC.compositionData[pName] or 0
                
                -- Set-based synergies from equipment data (for this specific player)
                local playerSetSynergies = {}
                if ST and ST.SET_SYNERGY_PROVIDERS and playerSetMap[pName] then
                    for setId, _ in pairs(playerSetMap[pName]) do
                        local synId = ST.SET_SYNERGY_PROVIDERS[setId]
                        if synId then
                            playerSetSynergies[synId] = true
                        end
                    end
                end
                
                -- Check each synergy: does this player provide it from either source?
                for synId = 1, SC.MAX_SYNERGY_BITS do
                    if SC.TestBit(playerBitmask, synId) or playerSetSynergies[synId] then
                        synergyProviderCount[synId] = (synergyProviderCount[synId] or 0) + 1
                    end
                end
            end

            for synergyIdKey, preference in pairs(BeltalowdaVars.composition.synergyPreferences) do
                local synergyId = tonumber(synergyIdKey)
                if not synergyId then
                    synergyId = synergyIdKey
                end
                
                local synergyName = ST and ST.SYNERGIES[synergyId] and ST.SYNERGIES[synergyId].name or ("Synergy #" .. tostring(synergyId))
                local providerCount = synergyProviderCount[synergyId] or 0
                
                -- Determine required count from preference value
                -- "required" = 1+, "required2" = 2+
                local requiredCount = 0
                if preference == "required" then
                    requiredCount = 1
                elseif preference == "required2" then
                    requiredCount = 2
                end
                
                if requiredCount > 0 and providerCount < requiredCount then
                    if requiredCount == 1 then
                        table.insert(Composition.warnings, {
                            severity = "high",
                            category = "synergies",
                            message = string.format("Required synergy missing: %s", synergyName),
                        })
                    else
                        table.insert(Composition.warnings, {
                            severity = "high",
                            category = "synergies",
                            message = string.format("Required synergy: %s (%d/%d providers)", synergyName, providerCount, requiredCount),
                        })
                    end
                end
                -- "optional" - no warnings needed
            end
        end
    end
    
    -- Phase 4: Check buff preferences
    -- Gather providers from two sources: set data (LSD) and ability data (BuffComposition bitmask)
    if BeltalowdaVars and BeltalowdaVars.composition and BeltalowdaVars.composition.buffPreferences then
        local BuffDB = Beltalowda.Data and Beltalowda.Data.BuffDatabase
        local BC = Beltalowda.Data and Beltalowda.Data.BuffComposition
        
        if BuffDB then
            local missingGroupBuffs = {}  -- collect missing group buff names
            
            for buffName, preference in pairs(BeltalowdaVars.composition.buffPreferences) do
                if preference ~= "optional" then
                    local def = BuffDB.BUFF_DEFINITIONS[buffName]
                    if def then
                        -- Count providers from both set and ability sources, per player
                        local buffProviderCount = 0
                        local buffProviderNames = {}  -- { {name=playerName, source=sourceName}, ... }
                        
                        for i = 1, groupSize do
                            local unitTag = GetGroupUnitTagByIndex(i)
                            local pName = GetUnitName(unitTag)
                            local providesViaSets = false
                            local setSourceName = nil
                            
                            -- Check set-based sources (from LSD equipment data)
                            if playerSetMap[pName] then
                                for setId, setName in pairs(def.groupSetSources) do
                                    if playerSetMap[pName][setId] then
                                        providesViaSets = true
                                        setSourceName = setName
                                        break
                                    end
                                end
                            end
                            
                            -- Check ability-based sources (from BuffComposition bitmask)
                            local providesViaAbility = false
                            if BC and BC.compositionData and BC.compositionData[pName] then
                                providesViaAbility = BC.TestBit(BC.compositionData[pName], def.buffId)
                            end
                            
                            if providesViaSets or providesViaAbility then
                                buffProviderCount = buffProviderCount + 1
                                local source = setSourceName or "ability"
                                table.insert(buffProviderNames, { name = pName, source = source })
                            end
                        end
                        
                        if preference == "required" and def.perPlayer then
                            -- Per-player check: every player must have this individually.
                            local missing = {}
                            for i = 1, groupSize do
                                local unitTag = GetGroupUnitTagByIndex(i)
                                local pName = GetUnitName(unitTag)
                                local hasIt = false
                                -- Check set-based sources
                                if playerSetMap[pName] then
                                    for setId, _ in pairs(def.groupSetSources) do
                                        if playerSetMap[pName][setId] then
                                            hasIt = true
                                            break
                                        end
                                    end
                                end
                                -- Check ability/scribing sources (from BuffComposition bitmask)
                                if not hasIt and BC and BC.compositionData and BC.compositionData[pName] then
                                    hasIt = BC.TestBit(BC.compositionData[pName], def.buffId)
                                end
                                if not hasIt then
                                    table.insert(missing, pName)
                                end
                            end
                            if #missing > 0 then
                                local label = def.displayPrefix or buffName
                                local prefix
                                if #missing >= groupSize then
                                    prefix = "Group"
                                elseif #missing == 1 then
                                    prefix = "Player"
                                else
                                    prefix = "Players"
                                end
                                table.insert(Composition.warnings, {
                                    severity = "medium",
                                    category = "buffs",
                                    message = string.format("%s missing %s", prefix, label),
                                    children = missing,
                                })
                            end
                        elseif preference == "required" and def.individualBuffId then
                            -- Per-player buff check (e.g., Major Evasion).
                            -- Each player needs this buff from either:
                            --   1. A group-wide source (e.g., Gossamer) — covers everyone
                            --   2. An individual ability (e.g., Shuffle/Elude)
                            if buffProviderCount > 0 then
                                -- Group source present — everyone is covered.
                                -- Warn about players who ALSO slot individual source (redundant).
                                local redundant = {}
                                for i = 1, groupSize do
                                    local unitTag = GetGroupUnitTagByIndex(i)
                                    local pName = GetUnitName(unitTag)
                                    local hasIndividual = false
                                    if BC and BC.compositionData and BC.compositionData[pName] then
                                        hasIndividual = BC.TestBit(BC.compositionData[pName], def.individualBuffId)
                                    end
                                    if hasIndividual then
                                        table.insert(redundant, pName)
                                    end
                                end
                                if #redundant > 0 then
                                    -- Build group source provider description
                                    local providerDescs = {}
                                    for _, p in ipairs(buffProviderNames) do
                                        table.insert(providerDescs, string.format("%s (%s)", p.name, p.source))
                                    end
                                    table.insert(Composition.warnings, {
                                        severity = "low",
                                        category = "buffs",
                                        message = string.format("%s from %s — can free up a slot",
                                            buffName, table.concat(providerDescs, ", ")),
                                        children = redundant,
                                    })
                                end
                            else
                                -- No group source. Check each player individually.
                                local missing = {}
                                for i = 1, groupSize do
                                    local unitTag = GetGroupUnitTagByIndex(i)
                                    local pName = GetUnitName(unitTag)
                                    local hasIndividual = false
                                    if BC and BC.compositionData and BC.compositionData[pName] then
                                        hasIndividual = BC.TestBit(BC.compositionData[pName], def.individualBuffId)
                                    end
                                    if not hasIndividual then
                                        table.insert(missing, pName)
                                    end
                                end
                                if #missing > 0 then
                                    local prefix
                                    if #missing >= groupSize then
                                        prefix = "Group"
                                    elseif #missing == 1 then
                                        prefix = "Player"
                                    else
                                        prefix = "Players"
                                    end
                                    table.insert(Composition.warnings, {
                                        severity = "medium",
                                        category = "buffs",
                                        message = string.format("%s missing %s", prefix, buffName),
                                        children = missing,
                                    })
                                end
                            end
                        elseif preference == "required" then
                            if buffProviderCount < 1 then
                                table.insert(missingGroupBuffs, buffName)
                            elseif buffProviderCount > 1 then
                                local providerDescs = {}
                                for _, p in ipairs(buffProviderNames) do
                                    table.insert(providerDescs, string.format("%s (%s)", p.name, p.source))
                                end
                                table.insert(Composition.warnings, {
                                    severity = "medium",
                                    category = "buffs",
                                    message = string.format("Duplicate %s source: %s",
                                        buffName, table.concat(providerDescs, " + ")),
                                })
                            end
                        end
                    end
                end
            end
            
            -- Each missing group buff gets its own warning (icon + name shown in panel)
            for _, buffName in ipairs(missingGroupBuffs) do
                table.insert(Composition.warnings, {
                    severity = "high",
                    category = "buffs",
                    message = buffName,
                })
            end
        end
    end

    -- Phase 5: Check mundus stone preferences
    if BeltalowdaVars and BeltalowdaVars.composition and BeltalowdaVars.composition.mundusWarning then
        local MC = Beltalowda.Data and Beltalowda.Data.MundusComposition
        local MundusData = Beltalowda.Data and Beltalowda.Data.MundusData
        if MC and MundusData then
            local missing = MC.GetPlayersWithoutMundus()
            if #missing > 0 then
                local prefix
                if #missing >= groupSize then
                    prefix = "Group"
                elseif #missing == 1 then
                    prefix = "Player"
                else
                    prefix = "Players"
                end
                table.insert(Composition.warnings, {
                    severity = "medium",
                    category = "buffs",
                    message = string.format("%s missing Mundus Stone", prefix),
                    children = missing,
                })
            end
        end
    end

    -- ── Consumable Warnings ────────────────────────────────────────────
    local ConsT = Beltalowda.Data and Beltalowda.Data.ConsumableTracker
    if ConsT and ConsT.GetPlayerConsumableData then
        local noFood = {}
        local foodExpiring = {}
        local warnThreshold = 300  -- 5 minutes

        for i = 1, groupSize do
            local unitTag = GetGroupUnitTagByIndex(i)
            local name = GetUnitName(unitTag)
            local displayName = Beltalowda.GetDisplayName(unitTag)
            local cData = ConsT.GetPlayerConsumableData(name)

            if cData then
                if cData.foodRemain <= 0 then
                    table.insert(noFood, displayName)
                elseif cData.foodRemain <= warnThreshold then
                    table.insert(foodExpiring, displayName)
                end
            end
        end

        if #noFood > 0 then
            table.insert(Composition.warnings, {
                severity = "high",
                category = "consumables",
                message = string.format("%d player(s) have no food buff", #noFood),
                children = noFood,
            })
        end

        if #foodExpiring > 0 then
            table.insert(Composition.warnings, {
                severity = "medium",
                category = "consumables",
                message = string.format("%d player(s) food buff expiring soon", #foodExpiring),
                children = foodExpiring,
            })
        end
    end

    -- Check for food buff expiry transitions and queue chat notifications
    Composition.CheckFoodExpiryTransitions()

    -- Sort warnings by severity: high → medium → low
    local severityOrder = { high = 1, medium = 2, low = 3 }
    table.sort(Composition.warnings, function(a, b)
        return (severityOrder[a.severity] or 99) < (severityOrder[b.severity] or 99)
    end)
end

--[[
    Check if there are any warnings
    @return: boolean, number of warnings
]]--
function Composition.HasWarnings()
    return #Composition.warnings > 0, #Composition.warnings
end

--[[
    Get highest severity warning
    @return: "high", "medium", "low", or nil
]]--
function Composition.GetHighestSeverity()
    if #Composition.warnings == 0 then
        return nil
    end
    
    for _, warning in ipairs(Composition.warnings) do
        if warning.severity == "high" then
            return "high"
        end
    end
    
    for _, warning in ipairs(Composition.warnings) do
        if warning.severity == "medium" then
            return "medium"
        end
    end
    
    return "low"
end

--[[
    Get all warnings
    @return: Table of warnings
]]--
function Composition.GetWarnings()
    return Composition.warnings
end

--[[
    Get formatted group composition summary
    @return: String with composition details
]]--
function Composition.GetSummary()
    local groupSize = GetGroupSize()
    
    if groupSize == 0 then
        return "Not in a group"
    end
    
    local lines = {}
    table.insert(lines, string.format("Group Size: %d", groupSize))
    table.insert(lines, "")
    
    -- Add member details
    for i = 1, groupSize do
        local unitTag = GetGroupUnitTagByIndex(i)
        local name = GetUnitName(unitTag)
        local equipData = Beltalowda.network and Beltalowda.network.GetEquipmentData(unitTag)
        
        -- Check if this player has Volendrung active
        local hasVolendrung = false
        local volendrungBar = nil
        if Beltalowda.UI and Beltalowda.UI.GroupUltimateDisplay then
            local playerData = Beltalowda.UI.GroupUltimateDisplay.playerData
            if playerData[name] and playerData[name].hasVolendrung then
                hasVolendrung = true
                volendrungBar = playerData[name].volendrungBar or 0
            end
        end
        
        if equipData and equipData.usefulBits then
            local data = equipData.usefulBits
            local roleDisplay = Beltalowda.SetDatabase and Beltalowda.SetDatabase.GetRoleDisplayName(data.role) or data.role
            
            -- Player status line (no Volendrung here)
            table.insert(lines, string.format("[%d] %s - %s", i, name, roleDisplay))
            
            -- Add Volendrung as first set if active
            if hasVolendrung then
                local volendrungBarName = (volendrungBar == 0) and "Front Bar" or "Back Bar"
                table.insert(lines, string.format("    Volendrung (%s)", volendrungBarName))
            end
            
            -- Add sets
            if data.sets and #data.sets > 0 then
                for _, set in ipairs(data.sets) do
                    local maxPieces = set.maxPieces or 5
                    local displayPieces = set.pieces
                    local adjustedBarInfo = set.barInfo or ""
                    
                    -- Adjust for Volendrung
                    if hasVolendrung then
                        -- If set is on Both Bars, show only the Volendrung bar
                        if set.barInfo == " (Both Bars)" then
                            if volendrungBar == 0 then
                                adjustedBarInfo = " (Front Bar)"
                            else
                                adjustedBarInfo = " (Back Bar)"
                            end
                        -- If set is on the OPPOSITE bar from Volendrung, subtract weapon pieces (2)
                        elseif (volendrungBar == 0 and set.barInfo and set.barInfo:find("Back Bar")) or
                               (volendrungBar == 1 and set.barInfo and set.barInfo:find("Front Bar")) then
                            -- This set is on the inaccessible bar - subtract 2 for weapons if present
                            if displayPieces >= 2 then
                                displayPieces = displayPieces - 2
                            end
                        end
                    end
                    
                    local setDisplay = string.format("    %s Set: %d/%d", set.name, displayPieces, maxPieces)
                    if adjustedBarInfo ~= "" then
                        setDisplay = setDisplay .. adjustedBarInfo
                    end
                    -- Optional: show set ID for debugging
                    if BeltalowdaVars and BeltalowdaVars.composition and BeltalowdaVars.composition.showSetIds then
                        setDisplay = setDisplay .. string.format(" [ID:%s]", tostring(set.id))
                    end
                    table.insert(lines, setDisplay)
                end
            end
            
            -- Add buffs provided (from sets and abilities)
            local allBuffs = {}
            local seenBuffs = {}
            if data.buffsProvided then
                for _, b in ipairs(data.buffsProvided) do
                    if not seenBuffs[b] then
                        seenBuffs[b] = true
                        table.insert(allBuffs, b)
                    end
                end
            end
            -- Merge in ability-based buffs from BuffComposition bitmask
            local BC = Beltalowda.Data and Beltalowda.Data.BuffComposition
            local BuffDB = Beltalowda.Data and Beltalowda.Data.BuffDatabase
            if BC and BuffDB and BC.compositionData then
                local playerName = GetUnitDisplayName(unitTag)
                local bitmask = BC.compositionData[playerName]
                if bitmask and bitmask > 0 then
                    for buffName, def in pairs(BuffDB.BUFF_DEFINITIONS) do
                        -- Group-wide ability source
                        if BC.TestBit(bitmask, def.buffId) then
                            local buffLabel
                            if def.displayPrefix and def.scribingSources then
                                -- Use localized scribing source label
                                local sourceName = def.scribingSources[1].description or "ability"
                                if def.scribingSources[1].resolvedAbilityId then
                                    local resolved = GetAbilityName(def.scribingSources[1].resolvedAbilityId)
                                    if resolved and resolved ~= "" then
                                        sourceName = resolved
                                    end
                                end
                                buffLabel = string.format("%s from %s", def.displayPrefix, sourceName)
                            else
                                buffLabel = buffName .. " (ability)"
                            end
                            if not seenBuffs[buffName] and not seenBuffs[buffLabel] then
                                seenBuffs[buffLabel] = true
                                table.insert(allBuffs, buffLabel)
                            end
                        end
                        -- Individual (self-only) ability source
                        if def.individualBuffId and BC.TestBit(bitmask, def.individualBuffId) then
                            local buffLabel = buffName .. " (self)"
                            if not seenBuffs[buffName] and not seenBuffs[buffLabel] then
                                seenBuffs[buffLabel] = true
                                table.insert(allBuffs, buffLabel)
                            end
                        end
                    end
                end
            end
            if #allBuffs > 0 then
                table.insert(lines, "    Provides: " .. table.concat(allBuffs, ", "))
            end
            
            -- Add synergies provided (from SynergyComposition bitmask + set-based synergies)
            local SC = Beltalowda.Data and Beltalowda.Data.SynergyComposition
            local ST = Beltalowda.Data and Beltalowda.Data.SynergyTracker
            if SC and SC.GetPlayerSynergies then
                local synergies = SC.GetPlayerSynergies(unitTag)
                local synergySet = {}
                local synergyNames = {}
                
                -- Add synergies from bitmask (skills + locally-detected sets)
                for _, synergyId in ipairs(synergies) do
                    local synergy = ST and ST.SYNERGIES[synergyId]
                    if synergy then
                        synergySet[synergyId] = true
                        table.insert(synergyNames, synergy.name)
                    end
                end
                
                -- Also add set-based synergies from equipment data (cross-reference)
                -- This catches cases where the bitmask is from a remote player who
                -- may not have detected their own set synergies
                if ST and ST.SET_SYNERGY_PROVIDERS and data.sets then
                    for _, set in ipairs(data.sets) do
                        local maxPieces = set.maxPieces or 5
                        if set.pieces >= maxPieces then
                            local synId = ST.SET_SYNERGY_PROVIDERS[set.id]
                            if synId and not synergySet[synId] then
                                local synergy = ST.SYNERGIES[synId]
                                if synergy then
                                    synergySet[synId] = true
                                    table.insert(synergyNames, synergy.name)
                                end
                            end
                        end
                    end
                end
                
                if #synergyNames > 0 then
                    table.insert(lines, "    Synergies: " .. table.concat(synergyNames, ", "))
                end
            end
            
            -- Add mundus stone(s)
            local MundusComp = Beltalowda.Data and Beltalowda.Data.MundusComposition
            local MundusData = Beltalowda.Data and Beltalowda.Data.MundusData
            if MundusComp and MundusData then
                local mundusAbilities = MundusComp.GetPlayerMundus(name)
                if mundusAbilities and #mundusAbilities > 0 then
                    local mundusNames = {}
                    for _, abilityId in ipairs(mundusAbilities) do
                        table.insert(mundusNames, MundusData.GetMundusName(abilityId))
                    end
                    table.insert(lines, "    Mundus: " .. table.concat(mundusNames, " + "))
                else
                    table.insert(lines, "    Mundus: (none detected)")
                end
            end
        else
            table.insert(lines, string.format("[%d] %s - Waiting for data...", i, name))
        end
        
        table.insert(lines, "")
    end
    
    return table.concat(lines, "\n")
end
