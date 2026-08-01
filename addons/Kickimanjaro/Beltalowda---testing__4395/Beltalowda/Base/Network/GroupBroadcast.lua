-- Beltalowda Group Broadcast
-- LibGroupBroadcast integration layer for subscribing to existing libraries
-- Phase 2: Integration with LibGroupCombatStats and LibSetDetection

Beltalowda = Beltalowda or {}
Beltalowda.network = Beltalowda.network or {}

local BeltalowdaNetwork = Beltalowda.network
-- Don't capture libraries as locals - check globals directly to avoid nil capture issues
-- Libraries may load in unpredictable order, so capturing them as locals at file load time
-- can result in nil values even though they're listed as dependencies
-- Note: LibGroupBroadcast must be accessed via LibStub, not as a global
-- local LGB = LibGroupBroadcast
-- local LGCS = LibGroupCombatStats
-- local LSD = LibSetDetection

-- Helper to get LibGroupBroadcast via LibStub
local function GetLibGroupBroadcast()
    if LibStub then
        local lib = LibStub:GetLibrary("LibGroupBroadcast", true)
        if lib then
            return lib
        end
    end
    -- Fallback to global if it exists
    return LibGroupBroadcast or nil
end

-- Create logger instance for Network module
local logger = nil

-- Message IDs (reserved 220-229 for future custom protocols)
BeltalowdaNetwork.MESSAGE_IDS = {
    WELL_PICKUP = 220,                 -- Ayleid Well pickup: wellIndex (4 bits) + elapsed minutes (7 bits) = 11 bits
    MANUAL_ULTIMATE_SELECTION = 221,   -- Player state: ultimate ability ID + combat/volendrung flags (20 bits)
    EQUIPMENT_AND_ROLE = 222,          -- Player's equipment sets and detected role
    REQUEST_COMPOSITION_UPDATE = 223,  -- Request all group members to re-broadcast composition (1-bit flag)
    SYNERGY_BROADCAST = 224,           -- Synergy cooldown tracking (16 bits)
    COMPOSITION = 225,                 -- Combined synergy + buff bitmask (32 bits: synergy 24 + buff 8)
    ALT_BAR_ULTIMATE = 226,            -- Alt-bar ultimate ability ID for upgrade detection (18 bits)
    RESOURCE_UPDATE = 227,             -- Player resources: ult charge + magicka + stamina (23 bits)
    CONSUMABLE_STATE = 228,            -- Consumable buff timers: food + AP + XP (30 bits)
    FIGHT_TOTALS = 229,                -- Fight totals: damage + healing + shielding (63 bits)
}

-- External library message IDs (for reference only - subscriptions handled by libraries)
BeltalowdaNetwork.EXTERNAL_IDS = {
    -- LibGroupCombatStats
    ULTIMATE_TYPE = 20,    -- Ultimate ability ID + cost
    ULTIMATE_VALUE = 21,   -- Current ultimate points (0-500)
    DPS = 22,              -- Current DPS + overall damage
    HPS = 23,              -- Current HPS + overall heal
    
    -- LibSetDetection  
    EQUIPMENT = 40,        -- Equipped set pieces (all 14 slots)
}

-- Group data structure: stores data for all group members
-- Format: groupData[unitTag] = { ultimate = {...}, equipment = {...}, ... }
BeltalowdaNetwork.groupData = {}

-- Previous equipment state for bar swap filtering
-- Stores set IDs and piece counts to detect actual equipment changes
BeltalowdaNetwork.previousEquipmentState = nil

-- Store registered library instances
BeltalowdaNetwork.lgcsInstance = nil
BeltalowdaNetwork.lsdInstance = nil

-- RdK compatibility: when RdK is also loaded, suppress duplicate ultimate broadcasts
-- to avoid doubling LGB traffic. Beltalowda still receives data from other Beltalowda users.
BeltalowdaNetwork.rdkDetected = false

--[[
    Initialize the network layer
    - Subscribe to LibGroupCombatStats broadcasts
    - Subscribe to LibSetDetection broadcasts
    Returns: success (boolean)
]]--
function BeltalowdaNetwork.Initialize()
    -- Initialize logger if not already done
    if not logger and Beltalowda.Logger and Beltalowda.Logger.CreateModuleLogger then
        logger = Beltalowda.Logger.CreateModuleLogger("Network")
    end
    
    -- Check if required libraries are available
    -- Note: These are now required dependencies in manifest, so this check is defensive
    local LGB = GetLibGroupBroadcast()
    if not LGB then
        d("[Beltalowda] ERROR: LibGroupBroadcast not available. Network features disabled.")
        return false
    end
    
    if not LibGroupCombatStats then
        d("[Beltalowda] ERROR: LibGroupCombatStats not available. This should not happen (required dependency).")
        return false
    else
        if logger then
            logger:Info("LibGroupCombatStats found - registering addon")
        end
        BeltalowdaNetwork.SubscribeToUltimateData()
    end
    
    if not LibSetDetection then
        d("[Beltalowda] ERROR: LibSetDetection not available. This should not happen (required dependency).")
        return false
    else
        if logger then
            logger:Info("LibSetDetection found - registering addon")
        end
        
        -- Call with explicit error handling to catch any issues
        local success, err = pcall(BeltalowdaNetwork.SubscribeToEquipmentData)
        if not success then
            d("[Beltalowda] ERROR calling SubscribeToEquipmentData: " .. tostring(err))
            if logger then
                logger:Error("Error calling SubscribeToEquipmentData", tostring(err))
            end
        end
    end
    
    -- Register for group change events to clean up data
    EVENT_MANAGER:RegisterForEvent(
        "BeltalowdaNetwork_GroupUpdate", 
        EVENT_GROUP_MEMBER_LEFT, 
        BeltalowdaNetwork.OnGroupMemberLeft
    )
    
    -- Register for group member joined to trigger initial broadcasts
    EVENT_MANAGER:RegisterForEvent(
        "BeltalowdaNetwork_GroupJoined",
        EVENT_GROUP_MEMBER_JOINED,
        function(eventCode)
            -- When a new member joins, broadcast our equipment to them
            zo_callLater(function()
                if BeltalowdaNetwork.BroadcastEquipmentAndRole then
                    BeltalowdaNetwork.BroadcastEquipmentAndRole(true)  -- force: bypass throttle for group join
                end
            end, 1000)  -- 1 second delay to allow group to stabilize
        end
    )
    
    -- Subscribe to manual ultimate selection broadcasts
    BeltalowdaNetwork.SubscribeToManualUltimateSelection()
    
    -- Subscribe to equipment and synergy broadcasts (must be after manual ultimate subscription)
    zo_callLater(function()
        if BeltalowdaNetwork.lgbHandler then
            BeltalowdaNetwork.SubscribeToEquipmentBroadcasts()
            BeltalowdaNetwork.SubscribeToCompositionRequests()
            BeltalowdaNetwork.SubscribeToSynergyBroadcasts()
            BeltalowdaNetwork.SubscribeToComposition()
            BeltalowdaNetwork.SubscribeToConsumableState()
            BeltalowdaNetwork.SubscribeToFightTotals()
            
            -- Trigger initial equipment broadcast if in a group
            zo_callLater(function()
                if GetGroupSize() > 0 and BeltalowdaNetwork.BroadcastEquipmentAndRole then
                    BeltalowdaNetwork.BroadcastEquipmentAndRole(true)  -- force: initial broadcast on load
                end
            end, 2000)  -- 2 second delay to ensure everything is initialized
        end
    end, 1000)
    
    if logger then
        logger:Info("Network layer initialized")
    end
    
    -- Detect RdK addon for compatibility
    -- RdK's global namespace is RdKGTool (created at file parse time, before events fire)
    if RdKGTool then
        BeltalowdaNetwork.rdkDetected = true
        d("[Beltalowda] RdKGTool detected — RdK owns protocols 105/106, Beltalowda compat layer deferred")
        if logger then
            logger:Info("RdKGTool detected — RdK owns LGB protocols 105/106")
        end
    end

    -- Initialize RdK compatibility layer (declares protocols 105/106 if RdK is not loaded)
    if Beltalowda.network.rdkCompat and Beltalowda.network.rdkCompat.Initialize then
        Beltalowda.network.rdkCompat.Initialize()
    end

    return true
end

--[[
    Subscribe to LibGroupCombatStats ultimate broadcasts
    
    LibGroupCombatStats requires calling RegisterAddon first, then registering for events.
    We track ultimate ("ULT") data for all group members.
]]--
function BeltalowdaNetwork.SubscribeToUltimateData()
    if not LibGroupCombatStats then return end
    
    local success, err = pcall(function()
        -- Register our addon with LibGroupCombatStats
        -- RegisterAddon returns an instance object if successful
        BeltalowdaNetwork.lgcsInstance = LibGroupCombatStats.RegisterAddon("Beltalowda", {"ULT"})
        
        if not BeltalowdaNetwork.lgcsInstance then
            return
        end
        
        -- LibGroupCombatStats callback signature: function(data)
        -- The callback receives only the data table with fields: unitTag, id, cost, value, max
        -- The unitTag is INSIDE the data table, not a separate parameter
        
        -- Register for player ultimate updates
        if BeltalowdaNetwork.lgcsInstance.RegisterForEvent and LibGroupCombatStats.EVENT_PLAYER_ULT_UPDATE then
            BeltalowdaNetwork.lgcsInstance:RegisterForEvent(LibGroupCombatStats.EVENT_PLAYER_ULT_UPDATE, 
                function(unitTag, data)
                    -- Debug: Log what we actually received
                    if logger then
                        logger:Debug("LGCS PLAYER callback received", "unitTag type=" .. type(unitTag), 
                            "unitTag=" .. tostring(unitTag),
                            "data type=" .. type(data))
                    end
                    
                    -- LGCS passes unitTag as first param (string), data as second param (table)
                    if unitTag and data and type(unitTag) == "string" and type(data) == "table" then
                        BeltalowdaNetwork.OnUltimateDataReceived(unitTag, data)
                    elseif logger then
                        logger:Warn("LGCS PLAYER callback received invalid params", 
                            "unitTag type=" .. type(unitTag), "data type=" .. type(data))
                    end
                end)
        end
        
        -- Register for group ultimate updates
        if BeltalowdaNetwork.lgcsInstance.RegisterForEvent and LibGroupCombatStats.EVENT_GROUP_ULT_UPDATE then
            BeltalowdaNetwork.lgcsInstance:RegisterForEvent(LibGroupCombatStats.EVENT_GROUP_ULT_UPDATE, 
                function(unitTag, data)
                    -- Debug: Log what we actually received
                    if logger then
                        logger:Debug("LGCS GROUP callback received", "unitTag type=" .. type(unitTag),
                            "unitTag=" .. tostring(unitTag),
                            "data type=" .. type(data))
                    end
                    
                    -- LGCS passes unitTag as first param (string), data as second param (table)
                    if unitTag and data and type(unitTag) == "string" and type(data) == "table" then
                        BeltalowdaNetwork.OnUltimateDataReceived(unitTag, data)
                    elseif logger then
                        logger:Warn("LGCS GROUP callback received invalid params",
                            "unitTag type=" .. type(unitTag), "data type=" .. type(data))
                    end
                end)
        end
    end)
    
    if not success then
        d("[Beltalowda] Error registering with LibGroupCombatStats: " .. tostring(err))
    end
end

--[[
    Subscribe to LibSetDetection equipment change events
    
    LibSetDetection provides its own event system via LSD.RegisterEvent().
    Event: LSD_EVENT_DATA_UPDATE - fires when set data changes for monitored units
    Callback signature: function(unitTag)
    
    Use LSD.GetUnitSetData(unitTag) to query equipment after events.
]]--
function BeltalowdaNetwork.SubscribeToEquipmentData()
    if not LibSetDetection then 
        d("[Beltalowda] ERROR: LibSetDetection not available - equipment tracking disabled")
        if logger then
            logger:Info("LibSetDetection not available - equipment tracking disabled")
        end
        return 
    end
    
    -- LibSetDetection found - checking API methods (debug output removed)
    if logger then
        logger:Info("LibSetDetection found - registering for LSD_EVENT_DATA_UPDATE")
    end
    
    local success, err = pcall(function()
        -- Register for equipment data update events using LibSetDetection's event system
        if LSD_EVENT_DATA_UPDATE and LibSetDetection.RegisterEvent then
            -- Register for group member equipment changes
            -- LSD_UNIT_TYPE_GROUP monitors all group members including player
            LibSetDetection.RegisterEvent(
                LSD_EVENT_DATA_UPDATE,
                "BeltalowdaNetwork_EquipmentUpdate",
                function(unitTag)
                    if logger then
                        logger:Debug("LSD_EVENT_DATA_UPDATE received", string.format("unitTag=%s", unitTag))
                    end
                    
                    -- Query current equipment data for this unit
                    if LibSetDetection.GetUnitSetData then
                        local setData = LibSetDetection.GetUnitSetData(unitTag)
                        if setData then
                            BeltalowdaNetwork.OnEquipmentDataReceived(unitTag, setData)
                        end
                    end
                end,
                LSD_UNIT_TYPE_GROUP
            )
            
            if logger then
                logger:Info("Successfully registered for LSD_EVENT_DATA_UPDATE (group)")
            end
        else
            if logger then
                logger:Warn("LSD_EVENT_DATA_UPDATE or RegisterEvent not available")
            end
        end
        
        -- Try to get initial equipment data for player
        if LibSetDetection.GetUnitSetData then
            local initialSets = LibSetDetection.GetUnitSetData("player")
            
            if initialSets then
                if logger then
                    logger:Debug("Got initial equipment data from GetUnitSetData", "type=" .. type(initialSets))
                end
                BeltalowdaNetwork.OnEquipmentDataReceived("player", initialSets)
            end
        end
    end)
    
    if not success then
        d("[Beltalowda] ERROR in SubscribeToEquipmentData: " .. tostring(err))
        if logger then
            logger:Error("Error registering with LibSetDetection", tostring(err))
        end
    end
end

--[[
    Handle combined ultimate data (main handler)
    @param unitTag: Unit tag of the player (e.g., "group1", "player")
    @param data: Ultimate data table from LGCS
]]--
function BeltalowdaNetwork.OnUltimateDataReceived(unitTag, data)
    if not data or type(data) ~= "table" then 
        if logger then
            logger:Warn("OnUltimateDataReceived called with invalid data", "unitTag=" .. tostring(unitTag), "dataType=" .. type(data))
        end
        return 
    end
    
    -- Normalize unitTag: LGCS sends "player" but we need group tags for consistency
    -- When in a group, convert "player" to the appropriate group tag
    local normalizedTag = unitTag
    if unitTag == "player" then
        -- Find player's group tag if in a group
        local groupSize = GetGroupSize()
        if groupSize > 0 then
            for i = 1, groupSize do
                local groupTag = GetGroupUnitTagByIndex(i)
                if GetUnitName(groupTag) == GetUnitName("player") then
                    normalizedTag = groupTag
                    break
                end
            end
        end
    end
    
    -- DEBUG: Capture raw data samples to SavedVariables for easier analysis
    -- Keep only the last 10 samples to avoid bloat
    if BeltalowdaVars and BeltalowdaVars.debug then
        BeltalowdaVars.debug.lgcsDataSamples = BeltalowdaVars.debug.lgcsDataSamples or {}
        
        -- Deep copy the data table to SavedVariables
        local dataCopy = {}
        for k, v in pairs(data) do
            dataCopy[k] = v
        end
        
        table.insert(BeltalowdaVars.debug.lgcsDataSamples, {
            timestamp = GetTimeStamp(),
            unitTag = unitTag,
            data = dataCopy
        })
        
        -- Keep only last 10 samples
        while #BeltalowdaVars.debug.lgcsDataSamples > 10 do
            table.remove(BeltalowdaVars.debug.lgcsDataSamples, 1)
        end
    end
    
    -- DEBUG: Dump all fields in the data table to logs
    if logger then
        local fieldList = {}
        for k, v in pairs(data) do
            table.insert(fieldList, k .. "=" .. tostring(v) .. "(" .. type(v) .. ")")
        end
        logger:Debug("LGCS data table fields:", table.concat(fieldList, ", "))
        
        if normalizedTag ~= unitTag then
            logger:Debug("Normalized unitTag", "from=" .. unitTag, "to=" .. normalizedTag)
        end
    end
    
    -- Initialize player data if not exists (use normalized tag)
    BeltalowdaNetwork.groupData[normalizedTag] = BeltalowdaNetwork.groupData[normalizedTag] or {}
    BeltalowdaNetwork.groupData[normalizedTag].ultimate = BeltalowdaNetwork.groupData[normalizedTag].ultimate or {}
    
    -- Store all ultimate data from LGCS (use normalized tag)
    local ult = BeltalowdaNetwork.groupData[normalizedTag].ultimate
    
    -- LGCS actual fields discovered via SavedVariables data capture:
    -- - ult1ID, ult2ID: ability IDs for both bars
    -- - ult1Cost, ult2Cost: ultimate costs for both bars
    -- - ultValue: current ultimate resource value
    -- - ultActivatedSetID: which ultimate is active (0 = bar 1, non-zero = bar 2)
    
    -- Determine which ultimate is active and store its data
    local activeUltId = data.ultActivatedSetID == 0 and data.ult1ID or data.ult2ID
    local activeUltCost = data.ultActivatedSetID == 0 and data.ult1Cost or data.ult2Cost
    
    -- Cryptcannon Vestments special case (#121): Crypt Transfer can be cast at any
    -- ult > 0, so GetAbilityCost returns 0. Override to 500 (max ult pool) so the
    -- bar fills gradually rather than showing instantly ready.
    if activeUltId == 195031 then
        activeUltCost = 500
    end
    
    -- Store original LGCS fields
    ult.ult1ID = data.ult1ID
    ult.ult2ID = data.ult2ID
    ult.ult1Cost = data.ult1Cost
    ult.ult2Cost = data.ult2Cost
    ult.ultValue = data.ultValue
    ult.ultActivatedSetID = data.ultActivatedSetID
    
    -- Normalize to standard fields for display compatibility
    ult.abilityId = activeUltId
    ult.cost = activeUltCost
    ult.current = data.ultValue
    ult.value = data.ultValue -- Alias for compatibility
    ult.max = activeUltCost -- Max is the cost needed to cast
    
    -- Calculate percentage
    if activeUltCost and activeUltCost > 0 and data.ultValue then
        ult.percent = (data.ultValue / activeUltCost) * 100
    else
        ult.percent = 0
    end
    
    if logger then
        logger:Info("Ultimate data received!", "unitTag=" .. tostring(normalizedTag), 
            "abilityId=" .. tostring(activeUltId), 
            "value=" .. tostring(data.ultValue) .. "/" .. tostring(activeUltCost))
        logger:Info("Stored ultimate data", "unitTag=" .. tostring(normalizedTag), 
            "abilityId=" .. tostring(ult.abilityId), 
            "percent=" .. string.format("%.0f%%", ult.percent))
        logger:Verbose("Stored ultimate data under key", normalizedTag)
    end
    
    -- Trigger callback for modules that need this data (use normalized tag)
    BeltalowdaNetwork.OnDataChanged("ultimate", normalizedTag)
end

--[[
    Handle individual set change event from LibSetDetection
    @param setId: The set ID that changed
    @param changeType: LSD_CHANGE_TYPE (activated, deactivated, changed)
    @param unitTag: Unit tag of the player
    @param localPlayer: true if this is the local player
    @param activeType: LSD_ACTIVE_TYPE (frontbar, backbar, dualbar, none)
]]--
function BeltalowdaNetwork.OnEquipmentSetChanged(setId, changeType, unitTag, localPlayer, activeType)
    if logger then
        logger:Debug("Equipment set changed",
            string.format("setId=%d, changeType=%d, unitTag=%s, localPlayer=%s, activeType=%d",
                setId, changeType, unitTag, tostring(localPlayer), activeType))
    end
    
    -- Normalize unitTag (convert "player" to appropriate group tag when in a group)
    local normalizedTag = unitTag
    if unitTag == "player" then
        -- Find player's group tag if in a group
        local groupSize = GetGroupSize()
        if groupSize > 0 then
            for i = 1, groupSize do
                local groupTag = GetGroupUnitTagByIndex(i)
                if GetUnitName(groupTag) == GetUnitName("player") then
                    normalizedTag = groupTag
                    break
                end
            end
        end
    end
    
    -- Capture event to SavedVariables for analysis
    if BeltalowdaVars and BeltalowdaVars.debug then
        BeltalowdaVars.debug.lsdEventSamples = BeltalowdaVars.debug.lsdEventSamples or {}
        table.insert(BeltalowdaVars.debug.lsdEventSamples, {
            timestamp = GetTimeStamp(),
            setId = setId,
            changeType = changeType,
            unitTag = unitTag,
            normalizedTag = normalizedTag,
            localPlayer = localPlayer,
            activeType = activeType
        })
        
        -- Keep only last 20 samples
        while #BeltalowdaVars.debug.lsdEventSamples > 20 do
            table.remove(BeltalowdaVars.debug.lsdEventSamples, 1)
        end
    end
    
    -- Query current equipment using GetSets to get full picture
    if LibSetDetection and LibSetDetection.GetSets then
        local currentSets = LibSetDetection:GetSets(unitTag)
        if currentSets then
            BeltalowdaNetwork.OnEquipmentDataReceived(unitTag, currentSets)
        end
    end
end

--[[
    Handle equipment data from LibSetDetection
    @param unitTag: Unit tag of the player (e.g., "group1", "player")
    @param data: Equipment data table from LSD (result of GetSets call)
]]--
function BeltalowdaNetwork.OnEquipmentDataReceived(unitTag, data)
    if not data or type(data) ~= "table" then
        if logger then
            logger:Warn("OnEquipmentDataReceived called with invalid data", "unitTag=" .. tostring(unitTag), "dataType=" .. type(data))
        end
        return
    end
    
    -- Normalize unitTag (convert "player" to appropriate group tag when in a group)
    local normalizedTag = unitTag
    if IsUnitGrouped("player") and unitTag == "player" then
        local groupIndex = GetGroupIndexByUnitTag("player")
        if groupIndex then
            normalizedTag = GetGroupUnitTagByIndex(groupIndex)
            if not normalizedTag or normalizedTag == "" then
                normalizedTag = unitTag
            end
        end
    end
    
    -- Capture raw data sample to SavedVariables for structure discovery
    if BeltalowdaVars and BeltalowdaVars.debug then
        BeltalowdaVars.debug.lsdDataSamples = BeltalowdaVars.debug.lsdDataSamples or {}
        table.insert(BeltalowdaVars.debug.lsdDataSamples, {
            timestamp = GetTimeStamp(),
            unitTag = unitTag,
            data = data
        })
        
        -- Keep only last 10 samples
        while #BeltalowdaVars.debug.lsdDataSamples > 10 do
            table.remove(BeltalowdaVars.debug.lsdDataSamples, 1)
        end
    end
    
    -- DEBUG: Dump all fields in the data table to logs
    if logger then
        local fieldList = {}
        for k, v in pairs(data) do
            table.insert(fieldList, k .. "=" .. tostring(v) .. "(" .. type(v) .. ")")
        end
        logger:Debug("LSD data table fields:", table.concat(fieldList, ", "))
        
        if normalizedTag ~= unitTag then
            logger:Debug("Normalized unitTag", "from=" .. unitTag, "to=" .. normalizedTag)
        end
    end
    
    -- Initialize player data if not exists (use normalized tag)
    BeltalowdaNetwork.groupData[normalizedTag] = BeltalowdaNetwork.groupData[normalizedTag] or {}
    BeltalowdaNetwork.groupData[normalizedTag].equipment = BeltalowdaNetwork.groupData[normalizedTag].equipment or {}
    
    -- Store equipment data from LSD
    -- Field structure will be discovered via SavedVariables data capture
    -- For now, store the raw data table
    BeltalowdaNetwork.groupData[normalizedTag].equipment.rawData = data
    
    if logger then
        logger:Info("Equipment data received!", "unitTag=" .. tostring(normalizedTag))
        logger:Verbose("Stored equipment data under key", normalizedTag)
    end
    
    -- Broadcast equipment to group if this is the player
    if unitTag == "player" or normalizedTag == GetGroupUnitTagByIndex(GetGroupIndexByUnitTag("player")) then
        -- Delay broadcast slightly to allow data to settle
        zo_callLater(function()
            BeltalowdaNetwork.BroadcastEquipmentAndRole()
        end, 500)
    end
    
    -- Trigger callback for modules that need this data (use normalized tag)
    BeltalowdaNetwork.OnDataChanged("equipment", normalizedTag)
end

--[[
    Callback when data changes - can be extended for UI updates
    @param dataType: Type of data that changed ("ultimateType", "ultimateValue", "equipment")
    @param unitTag: Unit tag of the player whose data changed
]]--
function BeltalowdaNetwork.OnDataChanged(dataType, unitTag)
    -- When equipment data changes, re-evaluate auto-detected ultimate selection
    -- and refresh the role-based tracker display (#66)
    if dataType == "equipment" then
        -- Check if this is the local player's equipment change
        local isLocalPlayer = (unitTag == "player")
        if not isLocalPlayer then
            local playerIndex = GetGroupIndexByUnitTag("player")
            if playerIndex then
                local playerTag = GetGroupUnitTagByIndex(playerIndex)
                isLocalPlayer = (unitTag == playerTag)
            end
        end

        -- Re-evaluate local auto-detect selection when our own gear changes
        if isLocalPlayer then
            local CUS = Beltalowda.UI and Beltalowda.UI.ClientUltimateSelector
            if CUS and CUS.settings and CUS.settings.selectedUltimateId == 0
                and CUS.DetectPlayerUltimates then
                CUS.DetectPlayerUltimates()
            end
        end

        -- Refresh role-based display for any player's equipment change
        -- (remote player may now sort into a different role column)
        local GUDBR = Beltalowda.UI and Beltalowda.UI.GroupUltimateDisplayByRoles
        if GUDBR and GUDBR.RefreshDisplay then
            GUDBR.RefreshDisplay()
        end
    end
end

--[[
    Handle group member leaving
    Clean up their data from our tracking
]]--
function BeltalowdaNetwork.OnGroupMemberLeft(eventCode, characterName, reason, wasLocalPlayer)
    -- Find and remove data for this player
    for unitTag, data in pairs(BeltalowdaNetwork.groupData) do
        if GetUnitName(unitTag) == characterName then
            BeltalowdaNetwork.groupData[unitTag] = nil
            break
        end
    end
    
    -- Clean up synergy composition data for the departed member
    local SC = Beltalowda.Data and Beltalowda.Data.SynergyComposition
    if SC and SC.OnGroupMemberLeft then
        SC.OnGroupMemberLeft(nil, characterName)
    end
end

--[[
    Get group data for a specific player
    @param unitTag: Unit tag of the player (e.g., "group1", "player")
    @return: Data table or nil
]]--
function BeltalowdaNetwork.GetGroupData(unitTag)
    return BeltalowdaNetwork.groupData[unitTag]
end

--[[
    Get ultimate data for a specific player
    @param unitTag: Unit tag of the player
    @return: Ultimate data table or nil
]]--
function BeltalowdaNetwork.GetUltimateData(unitTag)
    local data = BeltalowdaNetwork.groupData[unitTag]
    return data and data.ultimate
end

--[[
    Get equipment data for a specific player
    @param unitTag: Unit tag of the player
    @return: Equipment data table or nil
]]--
function BeltalowdaNetwork.GetEquipmentData(unitTag)
    local data = BeltalowdaNetwork.groupData[unitTag]
    return data and data.equipment
end

--[[
    Get all group data
    @return: Full groupData table
]]--
function BeltalowdaNetwork.GetAllGroupData()
    return BeltalowdaNetwork.groupData
end

--[[
    Helper: Get ability name safely with fallback
    @param abilityId: Ability ID number
    @return: Ability name string or "Unknown"
]]--
local function GetAbilityNameSafe(abilityId)
    if not abilityId then
        return "Unknown"
    end
    
    local abilityName = GetAbilityName(abilityId)
    if abilityName and abilityName ~= "" then
        return abilityName
    end
    
    return "Unknown"
end

--[[
    Helper: Get set name safely with fallback
    @param setId: Set ID (number or other type)
    @return: Set name string
]]--
local function GetSetNameSafe(setId)
    if type(setId) == "number" then
        local setName = GetItemSetName(setId)
        if setName and setName ~= "" then
            return setName
        end
        return "Set #" .. setId
    end
    return tostring(setId)
end

--[[
    Debug: Print group data to chat
]]--
function BeltalowdaNetwork.DebugPrintGroupData()
    d("=== Beltalowda Group Data ===")
    
    local groupSize = GetGroupSize()
    if groupSize == 0 then
        d("Not in a group")
        return
    end
    
    for i = 1, groupSize do
        local unitTag = GetGroupUnitTagByIndex(i)
        local name = GetUnitName(unitTag)
        local data = BeltalowdaNetwork.groupData[unitTag]
        
        d("--- " .. name .. " (" .. unitTag .. ") ---")
        
        if data then
            -- Display ultimate data if available
            if data.ultimate and data.ultimate.abilityId then
                local ult = data.ultimate
                local abilityId = ult.abilityId
                local abilityName = GetAbilityNameSafe(abilityId)
                
                local current = ult.current or ult.value or 0
                local max = ult.max or 0
                local percent = ult.percent or 0
                
                d(string.format("  Ultimate: %s (ID: %s, cost: %d)", 
                    abilityName,
                    tostring(abilityId or "?"), 
                    ult.cost or 0))
                d(string.format("  Value: %d/%d (%.1f%%)", 
                    current, 
                    max, 
                    percent))
            else
                d("  Ultimate: No data yet")
            end
            
            -- Display equipment data if available
            if LibSetDetection then
                local success, sets = pcall(function()
                    return LibSetDetection.GetUnitSetData(unitTag)
                end)
                
                if success and sets and type(sets) == "table" then
                    local hasData = false
                    for setId, setInfo in pairs(sets) do
                        if not hasData then
                            d("  Equipment:")
                            hasData = true
                        end
                        
                        local setName = setInfo.setName or GetSetNameSafe(setId)
                        local bodyCount = (setInfo.numEquip and setInfo.numEquip.body) or 0
                        local frontCount = (setInfo.numEquip and setInfo.numEquip.front) or 0
                        local backCount = (setInfo.numEquip and setInfo.numEquip.back) or 0
                        local totalCount = bodyCount + frontCount + backCount
                        
                        d(string.format("    %s: %d pcs (body:%d front:%d back:%d)", 
                            setName, totalCount, bodyCount, frontCount, backCount))
                    end
                    
                    if not hasData then
                        d("  Equipment: No sets detected")
                    end
                else
                    d("  Equipment: No data yet")
                end
            end
        else
            d("  No data available")
        end
    end
end

--[[
    Debug command: Display group member count and status
]]--
function BeltalowdaNetwork.DebugGroupStatus()
    local groupSize = GetGroupSize()
    
    d("=== Beltalowda Group Status ===")
    d("Group Size: " .. groupSize)
    
    -- Debug: Show all keys in groupData
    d("DEBUG: Keys stored in groupData:")
    local keyCount = 0
    for key, value in pairs(BeltalowdaNetwork.groupData) do
        keyCount = keyCount + 1
        d(string.format("  Key: '%s' (type: %s), hasUltimate: %s", 
            tostring(key), type(key), (value.ultimate ~= nil) and "YES" or "NO"))
    end
    d(string.format("Total keys in groupData: %d", keyCount))
    
    if groupSize == 0 then
        d("Not in a group. Form a group to test network functionality.")
        d("Tip: Both you and group members need LibGroupCombatStats and LibSetDetection installed")
        return
    end
    
    d("Group Members:")
    for i = 1, groupSize do
        local unitTag = GetGroupUnitTagByIndex(i)
        local name = GetUnitName(unitTag)
        local data = BeltalowdaNetwork.groupData[unitTag]
        
        -- Format ultimate status
        local ultStatus = "NO"
        local equipStatus = "NO"
        
        if data then
            if data.ultimate and data.ultimate.abilityId then
                local ult = data.ultimate
                local current = ult.current or ult.value or 0
                local max = ult.max or 0
                local percent = ult.percent or 0
                
                local abilityId = ult.abilityId
                local abilityName = GetAbilityNameSafe(abilityId)
                
                ultStatus = string.format("%s (%.0f%%)", abilityName, percent)
            end
            
            -- Query equipment data from LibSetDetection
            if LibSetDetection then
                local success, sets = pcall(function()
                    return LibSetDetection.GetUnitSetData(unitTag)
                end)
                
                if success and sets and type(sets) == "table" then
                    local setCount = 0
                    for _ in pairs(sets) do
                        setCount = setCount + 1
                    end
                    if setCount > 0 then
                        equipStatus = string.format("%d sets", setCount)
                    end
                end
            end
        end
        
        d(string.format("[%d] %s (%s)", i, name, unitTag))
        d(string.format("    Data: %s  Ultimate: %s  Equipment: %s",
            data and "YES" or "NO",
            ultStatus,
            equipStatus))
    end
    
    d("")
    d("Tip: Use '/btlwdata ults' to see ultimate details")
    d("Tip: Use '/btlwdata equip' to see equipment details")
end

--[[
    Debug command: Display detailed ultimate information
]]--
function BeltalowdaNetwork.DebugUltimateData()
    d("=== Group Ultimate Details ===")
    
    local foundData = false
    
    -- Iterate through all stored data (includes "player" and all group members)
    for unitTag, data in pairs(BeltalowdaNetwork.groupData) do
        -- Check if we have any data at all for this unit
        if data then
            foundData = true
            local name = GetUnitName(unitTag) or "Unknown"
            
            d(string.format("[%s] %s", unitTag, name))
            
            -- Debug: Show what's in data.ultimate (only at DEBUG level or higher)
            if logger and Beltalowda.Logger.GetModuleLevel("Network") >= Beltalowda.Logger.Levels.DEBUG then
                if data.ultimate then
                    logger:Debug("ultimate table exists", "id=" .. tostring(data.ultimate.id), "abilityId=" .. tostring(data.ultimate.abilityId),
                        "value=" .. tostring(data.ultimate.value), "current=" .. tostring(data.ultimate.current),
                        "max=" .. tostring(data.ultimate.max), "cost=" .. tostring(data.ultimate.cost))
                else
                    logger:Debug("data.ultimate is nil")
                end
            end
            
            -- Check if we have ultimate data with actual values
            if data.ultimate and data.ultimate.abilityId then
                local ult = data.ultimate
                
                local abilityId = ult.abilityId
                local abilityName = GetAbilityNameSafe(abilityId)
                
                local current = ult.current or ult.value or 0
                local max = ult.max or 0
                local percent = ult.percent or 0
                
                d(string.format("    Ability: %s (ID: %s)", 
                    abilityName, 
                    tostring(abilityId or "?")))
                d(string.format("    Cost: %d", ult.cost or 0))
                d(string.format("    Current: %d / %d (%.1f%%)", 
                    current, 
                    max, 
                    percent))
                
                -- Show ready status
                if percent >= 100 then
                    d("    Status: READY!")
                elseif percent >= 75 then
                    d("    Status: Almost ready")
                else
                    d("    Status: Building...")
                end
            else
                d("    Ultimate: No data yet (waiting for combat activity)")
            end
        end
    end
    
    if not foundData then
        d("No group members tracked yet")
        d("Note: Requires LibGroupCombatStats installed on all group members")
        d("Try using an ability or waiting for combat to trigger data sync")
    end
end

--[[
    Debug command: Display detailed equipment information
]]--
function BeltalowdaNetwork.DebugEquipmentData()
    d("=== Group Equipment Details ===")
    
    local groupSize = GetGroupSize()
    if groupSize == 0 then
        d("Not in a group")
        return
    end
    
    if not LibSetDetection then
        d("LibSetDetection not available - cannot retrieve equipment data")
        return
    end
    
    local foundData = false
    for i = 1, groupSize do
        local unitTag = GetGroupUnitTagByIndex(i)
        local name = GetUnitName(unitTag)
        
        -- Query equipment data from LibSetDetection with error protection
        local success, sets = pcall(function()
            return LibSetDetection.GetUnitSetData(unitTag)
        end)
        
        if not success then
            d(string.format("[%d] %s - Error retrieving equipment data", i, name))
        elseif sets and type(sets) == "table" then
            local hasData = false
            for k, v in pairs(sets) do
                hasData = true
                break
            end
            
            if hasData then
                foundData = true
                d(string.format("[%d] %s", i, name))
                
                -- Display set data with full details
                for setId, setInfo in pairs(sets) do
                    local setName = setInfo.setName or GetSetNameSafe(setId)
                    local bodyCount = (setInfo.numEquip and setInfo.numEquip.body) or 0
                    local frontCount = (setInfo.numEquip and setInfo.numEquip.front) or 0
                    local backCount = (setInfo.numEquip and setInfo.numEquip.back) or 0
                    local totalCount = bodyCount + frontCount + backCount
                    local maxEquip = setInfo.maxEquip or 5
                    local activeType = setInfo.activeType or 0
                    
                    -- Format active status
                    local activeStr = ""
                    if activeType == 1 then
                        activeStr = " [ACTIVE]"
                    elseif activeType == 2 then
                        activeStr = " [PARTIAL]"
                    end
                    
                    d(string.format("    %s: %d/%d pcs%s", 
                        setName, totalCount, maxEquip, activeStr))
                    d(string.format("      Body: %d  Front: %d  Back: %d", 
                        bodyCount, frontCount, backCount))
                end
            end
        end
    end
    
    if not foundData then
        d("No equipment data received yet")
        d("Note: Requires LibSetDetection installed on all group members")
        d("Try changing equipment to trigger data sync")
    end
end

-- Debug slash commands
SLASH_COMMANDS["/btlwdata"] = function(args)
    -- Wrap in pcall to catch and display any errors
    local success, err = pcall(function()
        -- Parse command and arguments
        local cmd, arg1, arg2 = string.match(args, "^(%S+)%s*(%S*)%s*(%S*)$")
        if not cmd then
            cmd = args
        end
        
        if cmd == "status" then
            BeltalowdaNetwork.DebugGroupStatus()
        elseif cmd == "group" then
            BeltalowdaNetwork.DebugPrintGroupData()
        elseif cmd == "ults" then
            BeltalowdaNetwork.DebugUltimateData()
        elseif cmd == "equip" then
            BeltalowdaNetwork.DebugEquipmentData()
        elseif cmd == "volendrung" or cmd == "vol" then
            -- Test Volendrung detection
            d("=== Volendrung Detection Status ===")
            d("")
            
            if not Beltalowda.BuffMonitor then
                d("BuffMonitor not initialized")
                return
            end
            
            local groupSize = GetGroupSize()
            if groupSize == 0 then
                -- Check local player only
                local hasVol = Beltalowda.BuffMonitor.HasVolendrung("player")
                d("Local Player: " .. (hasVol and "HAS VOLENDRUNG" or "No Volendrung"))
                
                if hasVol then
                    local BM = Beltalowda.BuffMonitor
                    d("  Ruinous Cyclone ID: " .. tostring(BM.RUINOUS_CYCLONE_ID))
                    
                    -- Check if ClientUltimateSelector has the state
                    if Beltalowda.UI and Beltalowda.UI.ClientUltimateSelector then
                        local CUS = Beltalowda.UI.ClientUltimateSelector
                        if CUS.volendrungState then
                            d("  Original Ultimate ID: " .. tostring(CUS.volendrungState.originalUltId))
                            d("  Volendrung Bar: " .. tostring(CUS.volendrungState.volendrungBar))
                        end
                    end
                end
            else
                -- Check all group members
                d("Group Size: " .. groupSize)
                d("")
                
                for i = 1, groupSize do
                    local unitTag = GetGroupUnitTagByIndex(i)
                    local name = GetUnitName(unitTag)
                    local hasVol = Beltalowda.BuffMonitor.HasVolendrung(unitTag)
                    
                    d(string.format("[%d] %s: %s", i, name, hasVol and "HAS VOLENDRUNG" or "No Volendrung"))
                    
                    -- Show ultimate data
                    if Beltalowda.UI and Beltalowda.UI.GroupUltimateDisplay then
                        local playerData = Beltalowda.UI.GroupUltimateDisplay.playerData
                        if playerData[name] then
                            local data = playerData[name]
                            if data.hasVolendrung then
                                d("    State: Active")
                                d("    Current Ultimate: " .. tostring(data.selectedUltimateId))
                                d("    Original Ultimate: " .. tostring(data.originalUltId))
                                d("    Volendrung Bar: " .. tostring(data.volendrungBar))
                            end
                        end
                    end
                end
            end
            d("")
            d("Buff state storage:")
            for unitTag, buffs in pairs(Beltalowda.BuffMonitor.buffStates) do
                d("  " .. unitTag .. ":")
                for buffId, buffData in pairs(buffs) do
                    d(string.format("    Buff %d: active=%s", buffId, tostring(buffData.active)))
                end
            end
    elseif cmd == "buffs" then
        d("=== Buff Composition Debug ===")
        d("")

        local BC = Beltalowda.Data and Beltalowda.Data.BuffComposition
        local BuffDB = Beltalowda.Data and Beltalowda.Data.BuffDatabase

        if not BC then
            d("BuffComposition not initialized")
            return
        end

        d("Local player bitmask: " .. tostring(BC.localBitmask) .. " (" .. BC.BitmaskToString(BC.localBitmask) .. ")")
        d("Group bitmask: " .. tostring(BC.groupBuffBitmask) .. " (" .. BC.BitmaskToString(BC.groupBuffBitmask) .. ")")
        d("")

        -- Test class passive detection
        d("Class passive scan (SKILL_TYPE_CLASS):")
        if BuffDB then
            for buffName, def in pairs(BuffDB.BUFF_DEFINITIONS) do
                if def.classPassiveSources then
                    for _, ps in ipairs(def.classPassiveSources) do
                        local has = BC.HasClassPassive(ps.abilityName)
                        d(string.format("  %s (%s): %s", ps.abilityName, buffName,
                            has and "|c00FF00FOUND|r" or "|cFF0000NOT FOUND|r"))
                    end
                end
            end
        end

        -- Dump all class skill line passives for reference
        d("")
        d("All class passives (purchased):")
        local SKILL_TYPE_CLASS = 1
        local numSkillLines = GetNumSkillLines(SKILL_TYPE_CLASS)
        for slIdx = 1, numSkillLines do
            local slName = GetSkillLineInfo(SKILL_TYPE_CLASS, slIdx)
            local numAbilities = GetNumSkillAbilities(SKILL_TYPE_CLASS, slIdx)
            for abIdx = 1, numAbilities do
                local name, _, _, isPassive, _, isPurchased = GetSkillAbilityInfo(SKILL_TYPE_CLASS, slIdx, abIdx)
                if isPassive and isPurchased then
                    d(string.format("  [%s] %s", slName or "?", name or "?"))
                end
            end
        end

        d("")
        d("Group composition data:")
        for name, bitmask in pairs(BC.compositionData) do
            d(string.format("  %s: %d (%s)", name, bitmask, BC.BitmaskToString(bitmask)))
        end
    elseif cmd == "raw" then
        d("=== Raw Group Data Dump ===")
        d("")
        
        local groupSize = GetGroupSize()
        if groupSize == 0 then
            d("Not in a group")
            return
        end
        
        d("Group Size: " .. groupSize)
        d("")
        
        for i = 1, groupSize do
            local unitTag = GetGroupUnitTagByIndex(i)
            local name = GetUnitName(unitTag)
            local data = BeltalowdaNetwork.groupData[unitTag]
            
            d(string.format("[%d] unitTag=%s, name=%s", i, unitTag, name))
            
            if data then
                d("  Has data entry: YES")
                if data.ultimate then
                    d("  Ultimate data:")
                    for k, v in pairs(data.ultimate) do
                        d(string.format("    %s = %s", tostring(k), tostring(v)))
                    end
                else
                    d("  Ultimate data: NONE")
                end
            else
                d("  Has data entry: NO")
                d("  This means no events have been received for this unit")
            end
            d("")
        end
        
        d("All stored unitTags:")
        for unitTag, _ in pairs(BeltalowdaNetwork.groupData) do
            d("  " .. unitTag)
        end
    elseif args == "debug" then
        d("=== Beltalowda Debug Info ===")
        d("")
        d("Registration Status:")
        d("  LGCS Instance: " .. tostring(BeltalowdaNetwork.lgcsInstance ~= nil))
        d("  LSD Instance: " .. tostring(BeltalowdaNetwork.lsdInstance ~= nil))
        d("")
        
        if LibGroupCombatStats then
            d("LibGroupCombatStats Events:")
            d("  EVENT_GROUP_ULT_UPDATE: " .. tostring(LibGroupCombatStats.EVENT_GROUP_ULT_UPDATE))
            d("  EVENT_PLAYER_ULT_UPDATE: " .. tostring(LibGroupCombatStats.EVENT_PLAYER_ULT_UPDATE))
            d("  RegisterAddon method: " .. tostring(type(LibGroupCombatStats.RegisterAddon) == "function"))
            
            if BeltalowdaNetwork.lgcsInstance then
                d("  Instance type: " .. type(BeltalowdaNetwork.lgcsInstance))
                d("  Instance.RegisterForEvent: " .. tostring(type(BeltalowdaNetwork.lgcsInstance.RegisterForEvent) == "function"))
            end
        end
        d("")
        
        d("Group Data Storage:")
        local count = 0
        for unitTag, data in pairs(BeltalowdaNetwork.groupData) do
            count = count + 1
            d(string.format("  %s: %s", unitTag, data.ultimate and "Has Ultimate Data" or "No Ultimate Data"))
        end
        d("  Total entries: " .. count)
    elseif args == "libapi" then
        d("=== Library API Status ===")
        d("LibGroupBroadcast: " .. tostring(LibGroupBroadcast ~= nil))
        if LibGroupBroadcast then
            d("  Loaded and available")
            -- Try to check for common API methods
            if type(LibGroupBroadcast) == "table" then
                d("  Type: table (object)")
                d("  Has Send method: " .. tostring(type(LibGroupBroadcast.Send) == "function"))
                d("  Has RegisterForMessage method: " .. tostring(type(LibGroupBroadcast.RegisterForMessage) == "function"))
            end
        end
        d("")
        d("LibGroupCombatStats: " .. tostring(LibGroupCombatStats ~= nil))
        if LibGroupCombatStats then
            d("  Has RegisterAddon: " .. tostring(type(LibGroupCombatStats.RegisterAddon) == "function"))
            d("  EVENT_GROUP_ULT_UPDATE: " .. tostring(LibGroupCombatStats.EVENT_GROUP_ULT_UPDATE))
            d("  EVENT_PLAYER_ULT_UPDATE: " .. tostring(LibGroupCombatStats.EVENT_PLAYER_ULT_UPDATE))
            
            -- Check for other possible API methods and events
            if type(LibGroupCombatStats) == "table" then
                d("  Type: table (object)")
                d("  Available methods:")
                for k, v in pairs(LibGroupCombatStats) do
                    if type(v) == "function" then
                        d("    " .. tostring(k))
                    elseif type(k) == "string" and k:match("^EVENT_") then
                        d("    " .. tostring(k) .. " = " .. tostring(v))
                    end
                end
            end
        end
        d("")
        d("LibSetDetection: " .. tostring(LSD ~= nil))
        if LSD then
            d("  Has RegisterAddon: " .. tostring(type(LSD.RegisterAddon) == "function"))
            if type(LSD) == "table" then
                d("  Type: table (object)")
                for k, v in pairs(LSD) do
                    if type(v) == "function" then
                        d("  Has method: " .. tostring(k))
                    end
                end
            end
        end
        d("")
        d("Note: If libraries show 'nil', they are not installed")
        d("Install from ESOUI.com to enable full functionality")
    elseif cmd == "debug" and arg1 ~= "" then
        -- /btlwdata debug <module> <level>
        -- /btlwdata debug all <level>
        if not Beltalowda.Logger then
            return
        end
        
        local moduleName = arg1
        local levelName = arg2
        
        if levelName == "" then
            d("[Beltalowda] Usage: /btlwdata debug <module> <level>")
            d("  Example: /btlwdata debug Network DEBUG")
            d("  Modules: Network, Ultimates, Equipment, General, all")
            d("  Levels: ERROR, WARN, INFO, DEBUG, VERBOSE")
            return
        end
        
        local level = Beltalowda.Logger.ParseLevel(levelName)
        if not level then
            d("  Valid levels: ERROR, WARN, INFO, DEBUG, VERBOSE")
            return
        end
        
        Beltalowda.Logger.SetModuleLevel(moduleName, level)
        if moduleName == "all" then
        else
        end
    elseif cmd == "log" then
        -- /btlwdata log show [module] [count]
        -- /btlwdata log clear
        -- /btlwdata log levels
        -- /btlwdata log export
        if not Beltalowda.Logger then
            return
        end
        
        if arg1 == "show" then
            local moduleName = arg2 ~= "" and arg2 or nil
            local count = 20  -- Default to last 20 entries
            
            local entries = Beltalowda.Logger.GetSessionLog(moduleName, count)
            
            if #entries == 0 then
                return
            end
            
            d("=== Beltalowda Session Log ===")
            if moduleName then
                d("Module: " .. moduleName)
            end
            d(string.format("Showing last %d entries:", #entries))
            d("")
            
            for i = #entries, 1, -1 do
                local entry = entries[i]
                local timestamp = Beltalowda.Logger.FormatTimestamp(entry.timestamp)
                d(string.format("[%s] %s", timestamp, entry.message))
            end
        elseif arg1 == "clear" then
            Beltalowda.Logger.ClearSessionLog()
        elseif arg1 == "levels" then
            d("=== Current Debug Levels ===")
            for module, config in pairs(Beltalowda.Logger.moduleConfig) do
                local levelName = Beltalowda.Logger.LevelNames[config.level] or "UNKNOWN"
                d(string.format("  %s: %s", module, levelName))
            end
            d("")
            d("Max log entries: " .. tostring(Beltalowda.Logger.maxLogEntries))
            d("VERBOSE reset on reload: " .. (Beltalowda.Logger.verboseModeResetOnReload and "ON" or "OFF"))
        elseif arg1 == "export" then
            if Beltalowda.Logger.hasLibDebugLogger then
                d("Logs are stored in LibDebugLogger's own storage")
                d("Use LibDebugLogger's export features to access logs")
            else
                d("Session logs are in-memory only and will be lost on /reloadui")
                d("To persist logs, install LibDebugLogger from ESOUI.com")
            end
            d("")
            d("SavedVariables file location:")
            d("  Windows: Documents\\Elder Scrolls Online\\live\\SavedVariables\\Beltalowda.lua")
            d("  Mac: Documents/Elder Scrolls Online/live/SavedVariables/Beltalowda.lua")
        else
            d("[Beltalowda] Usage:")
            d("  /btlwdata log show [module] [count] - Show last N log entries")
            d("  /btlwdata log clear                 - Clear session log")
            d("  /btlwdata log levels                - Show current debug levels")
            d("  /btlwdata log export                - Show SavedVariables file path")
        end
    elseif args == "help" or args == "" or args == nil then
        d("=== Beltalowda Network Foundation Test Commands ===")
        d("")
        d("Basic Commands:")
        d("  /btlwdata status     - Show group status and data availability")
        d("  /btlwdata group      - Show all group member data (detailed)")
        d("  /btlwdata ults       - Show ultimate data for all group members")
        d("  /btlwdata equip      - Show equipment data for all group members")
        d("  /btlwdata volendrung - Show Volendrung detection status")
        d("  /btlwdata buffs      - Show buff composition and passive detection")
        d("")
        d("Debug Level Commands:")
        d("  /btlwdata debug <module> <level>  - Set debug level for module")
        d("  /btlwdata debug all <level>       - Set all modules to level")
        d("    Modules: Network, Ultimates, Equipment, General, all")
        d("    Levels: ERROR, WARN, INFO, DEBUG, VERBOSE")
        d("")
        d("Log Management:")
        d("  /btlwdata log show [module] [count] - Show last N log entries")
        d("  /btlwdata log clear                 - Clear session log")
        d("  /btlwdata log levels                - Show current debug levels")
        d("  /btlwdata log export                - Show SavedVariables file path")
        d("")
        d("Diagnostic Commands:")
        d("  /btlwdata libapi  - Check library API availability")
        d("  /btlwdata debug   - Show detailed debug info (registration, events, data)")
        d("  /btlwdata raw     - Show raw data dump (for troubleshooting unit tags)")
        d("  /btlwdata help    - Show this help message")
        d("")
        d("Testing Tips:")
        d("  1. Form a group with at least one other player")
        d("  2. Ensure all members have LibGroupCombatStats installed")
        d("  3. Ensure all members have LibSetDetection installed")
        d("  4. Use abilities to trigger ultimate data updates")
        d("  5. Change equipment to trigger equipment data updates")
        d("")
        d("Troubleshooting:")
        d("  - If no data shows: Check '/btlwdata libapi'")
        d("  - If libraries missing: Install from ESOUI.com")
        d("  - If data not syncing: Ensure group members have libraries")
        else
            d("Unknown command: " .. tostring(args))
            d("Type '/btlwdata help' for available commands")
        end
    end)
    
    if not success then
        d("[Beltalowda] ERROR executing command:")
        d(tostring(err))
        d("Please report this error with steps to reproduce")
    end
end

-- LibGroupBroadcast handler and protocol instances
BeltalowdaNetwork.lgbHandler = nil
BeltalowdaNetwork.manualUltimateProtocol = nil
BeltalowdaNetwork.altBarProtocol = nil
BeltalowdaNetwork.synergyProtocol = nil
BeltalowdaNetwork.compositionProtocol = nil
BeltalowdaNetwork.consumableProtocol = nil
BeltalowdaNetwork.fightTotalsProtocol = nil
BeltalowdaNetwork.cachedSynergyBitmask = 0
BeltalowdaNetwork.cachedBuffBitmask = 0
BeltalowdaNetwork.cachedCpSlots = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}

--[[
    Subscribe to manual ultimate selection broadcasts
    This allows group members to see each other's manually selected ultimates
    Uses LibGroupBroadcast protocol-based API (like RdK)
]]--
function BeltalowdaNetwork.SubscribeToManualUltimateSelection()
    
    -- Check if already initialized
    if BeltalowdaNetwork.manualUltimateProtocol then
        return
    end
    
    local LGB = GetLibGroupBroadcast()
    if not LGB then
        d("[Beltalowda] WARNING: LibGroupBroadcast not available for manual ultimate subscription")
        if logger then
            logger:Warn("LibGroupBroadcast not available for manual ultimate subscription")
        end
        
        -- Retry after 2 seconds in case library loads late
        zo_callLater(function()
            local retryLGB = GetLibGroupBroadcast()
            if retryLGB then
                BeltalowdaNetwork.SubscribeToManualUltimateSelection()
            else
            end
        end, 2000)
        return
    end
    
    local success, err = pcall(function()
        -- Register handler with LibGroupBroadcast (protocol-based API like RdK)
        
        BeltalowdaNetwork.lgbHandler = LGB:RegisterHandler("Beltalowda", "BeltalowdaHandler")
        
        BeltalowdaNetwork.lgbHandler:SetDisplayName("Beltalowda")
        BeltalowdaNetwork.lgbHandler:SetDescription("Beltalowda - Group Ultimate Tracker")
        
        -- Declare protocol for manual ultimate selection
        BeltalowdaNetwork.manualUltimateProtocol = BeltalowdaNetwork.lgbHandler:DeclareProtocol(
            BeltalowdaNetwork.MESSAGE_IDS.MANUAL_ULTIMATE_SELECTION,
            "BeltalowdaManualUltimate"
        )
        
        -- Pure player-state protocol: WHAT ult is selected + boolean flags.
        -- Resource values (ult charge, magicka, stamina) live on protocol 227.
        --
        -- Layout (20 bits used):
        --   Bits  0-17: ultId        (18 bits, 0-262143) selected ultimate ability ID
        --   Bit     18: inCombat     ( 1 bit)             combat state
        --   Bit     19: hasVolendrung( 1 bit)             Volendrung active
        BeltalowdaNetwork.manualUltimateProtocol:AddField(
            LGB.CreateNumericField("packed", {minValue = 0, maxValue = 1048575, trimValues = true})
        ) -- 20 bits: ultId + flags
        
        -- Register callback for received data
        BeltalowdaNetwork.manualUltimateProtocol:OnData(function(unitTag, data)
            local success, err = pcall(function()
                if not data or not data.packed then
                    if logger then
                        logger:Warn(string.format("Received malformed ultimate data from %s", tostring(unitTag)))
                    end
                    return
                end
                BeltalowdaNetwork.OnManualUltimateReceived(unitTag, data)
            end)
            if not success then
                if logger then
                    logger:Error(string.format("Error processing ultimate data from %s: %s", tostring(unitTag), tostring(err)))
                end
            end
        end)
        
        -- Finalize protocol
        local finalizeSuccess, finalizeErr = pcall(function()
            BeltalowdaNetwork.manualUltimateProtocol:Finalize({isRelevantInCombat = true, replaceQueuedMessages = true})
        end)
        
        if not finalizeSuccess then
            d("[Beltalowda] ERROR during protocol finalization: " .. tostring(finalizeErr))
            error("Protocol finalization failed: " .. tostring(finalizeErr))
        end
        
        
        if logger then
            logger:Info("Registered for manual ultimate selection broadcasts via protocol API")
        end
    end)
    
    if not success then
        d("[Beltalowda] ERROR subscribing to manual ultimate selection: " .. tostring(err))
        if logger then
            logger:Error("Error subscribing to manual ultimate selection", tostring(err))
        end
    else
    end
    
    -- Subscribe to resource protocol (protocol 227)
    -- All three resource values in one protocol: ultimate charge + magicka + stamina.
    -- Protocol 227: 23 bits packed into one NumericField.
    --   Bits  0-8:  ultPct  (9 bits, 0-500)  ultimate charge percentage
    --   Bits  9-15: magPct  (7 bits, 0-100)  magicka percent
    --   Bits 16-22: stamPct (7 bits, 0-100)  stamina percent
    local resSuccess, resErr = pcall(function()
        local LGB = GetLibGroupBroadcast()
        if not LGB then
            d("[Beltalowda] LibGroupBroadcast not available for resource protocol")
            return
        end
        
        BeltalowdaNetwork.resourceProtocol = BeltalowdaNetwork.lgbHandler:DeclareProtocol(
            BeltalowdaNetwork.MESSAGE_IDS.RESOURCE_UPDATE,
            "BeltalowdaResources"
        )
        
        -- 23 bits: ultPct(9) + magPct(7) + stamPct(7)
        BeltalowdaNetwork.resourceProtocol:AddField(
            LGB.CreateNumericField("packed", {minValue = 0, maxValue = 8388607, trimValues = true})
        ) -- 2^23 - 1
        
        BeltalowdaNetwork.resourceProtocol:OnData(function(unitTag, data)
            local ok, e = pcall(function()
                if not data or not data.packed then return end
                BeltalowdaNetwork.OnResourceReceived(unitTag, data)
            end)
            if not ok and logger then
                logger:Error(string.format("Error processing resource data from %s: %s", tostring(unitTag), tostring(e)))
            end
        end)
        
        BeltalowdaNetwork.resourceProtocol:Finalize({isRelevantInCombat = true, replaceQueuedMessages = true})
        
        if logger then
            logger:Info("Registered for resource update broadcasts (protocol 227)")
        end
    end)
    
    if not resSuccess then
        d("[Beltalowda] ERROR subscribing to resource broadcasts: " .. tostring(resErr))
        if logger then
            logger:Error("Error subscribing to resource broadcasts", tostring(resErr))
        end
    end
    
    -- ----------------------------------------------------------------
    -- Protocol 226 — Alt-Bar Ultimate (18 bits)
    -- Carries the "other bar" ultimate ability ID so remote clients
    -- can run smart-upgrade detection (which needs both bar IDs).
    -- Event-driven via replaceQueuedMessages; also sent every tick
    -- alongside 221+227 for reliability.
    -- ----------------------------------------------------------------
    local altSuccess, altErr = pcall(function()
        BeltalowdaNetwork.altBarProtocol = BeltalowdaNetwork.lgbHandler:DeclareProtocol(
            BeltalowdaNetwork.MESSAGE_IDS.ALT_BAR_ULTIMATE,
            "BeltalowdaAltBarUltimate"
        )
        
        BeltalowdaNetwork.altBarProtocol:AddField(
            LGB.CreateNumericField("altBarUltId", {minValue = 0, maxValue = 262143, trimValues = true})
        ) -- 2^18 - 1
        
        BeltalowdaNetwork.altBarProtocol:OnData(function(unitTag, data)
            local ok, e = pcall(function()
                if not data or not data.altBarUltId then return end
                BeltalowdaNetwork.OnAltBarUltimateReceived(unitTag, data)
            end)
            if not ok and logger then
                logger:Error(string.format("Error processing alt-bar ult from %s: %s", tostring(unitTag), tostring(e)))
            end
        end)
        
        BeltalowdaNetwork.altBarProtocol:Finalize({isRelevantInCombat = true, replaceQueuedMessages = true})
        
        if logger then
            logger:Info("Registered for alt-bar ultimate broadcasts (protocol 226)")
        end
    end)
    
    if not altSuccess then
        d("[Beltalowda] ERROR subscribing to alt-bar ultimate: " .. tostring(altErr))
        if logger then
            logger:Error("Error subscribing to alt-bar ultimate", tostring(altErr))
        end
    end
end

--[[
    Broadcast player state and resources to the group.
    Sends three protocols per tick:
    
    @param ultimateId: Ability ID of the primary selected ultimate
    @param percentReady: Ultimate charge percentage (0-500)
    @param frontbarUltId: Front-bar ultimate ability ID
    @param backbarUltId: Back-bar ultimate ability ID
    @param hasVolendrung: (optional) Boolean flag if Volendrung is active
    @param originalUltId: (deprecated, no longer sent over network)
    
    Protocol 221 - Player State (20 bits):
    - Bits  0-17: ultId        (18 bits, 0-262143) selected ult ability ID
    - Bit     18: inCombat     ( 1 bit)             combat state
    - Bit     19: hasVolendrung( 1 bit)             Volendrung active
    
    Protocol 226 - Alt-Bar Ultimate (18 bits):
    - Bits  0-17: altBarUltId  (18 bits, 0-262143) the other bar's ult ID
    
    Protocol 227 - Resources (23 bits):
    - Bits  0-8:  ultPct       ( 9 bits, 0-500)    ultimate charge percentage
    - Bits  9-15: magPct       ( 7 bits, 0-100)    magicka percent
    - Bits 16-22: stamPct      ( 7 bits, 0-100)    stamina percent
]]--
function BeltalowdaNetwork.BroadcastManualUltimate(ultimateId, percentReady, frontbarUltId, backbarUltId, hasVolendrung, originalUltId)
    local groupSize = GetGroupSize()
    local LGB = GetLibGroupBroadcast()
    
    if not LGB then
        return
    end
    
    -- Only broadcast if in a group
    if groupSize == 0 then
        return
    end
    
    -- Validate input parameters
    if not ultimateId or type(ultimateId) ~= "number" or ultimateId <= 0 then
        return
    end
    
    if not percentReady or type(percentReady) ~= "number" then
        return
    end
    
    -- Ensure ultimateId is an integer (floor it if not)
    local safeUltimateId = math.floor(ultimateId)
    
    -- Sanitize percent value - clamp to reasonable range and handle NaN/infinity
    local safePercent = percentReady
    if safePercent ~= safePercent then  -- NaN check
        safePercent = 0
    elseif safePercent == math.huge or safePercent == -math.huge then
        safePercent = 0
    else
        safePercent = math.max(0, math.min(500, safePercent))  -- Clamp to 0-500% range
    end
    
    local success, err = pcall(function()
        -- Combat and Volendrung flags
        local inCombat = IsUnitInCombat("player") and 1 or 0
        local volFlag = hasVolendrung and 1 or 0
        
        if not BeltalowdaNetwork.manualUltimateProtocol then
            d("[Beltalowda] ERROR - Manual ultimate protocol not initialized!")
            return
        end
        
        -- Protocol 221: Player State (20 bits)
        -- Layout: ultId(18) | inCombat(1) | hasVol(1)
        local statePacked = safeUltimateId               -- bits 0-17
            + inCombat    * 262144                        -- bit 18     (2^18)
            + volFlag     * 524288                        -- bit 19     (2^19)
        
        BeltalowdaNetwork.manualUltimateProtocol:Send({packed = statePacked})
        
        -- Protocol 226: Alt-Bar Ultimate (18 bits)
        -- Lets remote clients know the other bar's ult for upgrade detection.
        if BeltalowdaNetwork.altBarProtocol then
            local altBarId = 0
            if frontbarUltId and frontbarUltId > 0 and frontbarUltId ~= safeUltimateId then
                altBarId = math.floor(frontbarUltId)
            elseif backbarUltId and backbarUltId > 0 and backbarUltId ~= safeUltimateId then
                altBarId = math.floor(backbarUltId)
            end
            BeltalowdaNetwork.altBarProtocol:Send({altBarUltId = altBarId})
        end
        
        -- Protocol 227: Resources (23 bits)
        -- Layout: ultPct(9) | magPct(7) | stamPct(7)
        if BeltalowdaNetwork.resourceProtocol then
            local ultPct = math.max(0, math.min(500, math.floor(safePercent + 0.5)))
            
            local magickaCurrent, magickaMax = GetUnitPower("player", POWERTYPE_MAGICKA)
            local staminaCurrent, staminaMax = GetUnitPower("player", POWERTYPE_STAMINA)
            
            local magPct = magickaMax > 0 and math.max(0, math.min(100, math.floor(magickaCurrent / magickaMax * 100 + 0.5))) or 0
            local stamPct = staminaMax > 0 and math.max(0, math.min(100, math.floor(staminaCurrent / staminaMax * 100 + 0.5))) or 0
            
            -- Pack: ultPct(9, bits 0-8) + magPct(7, bits 9-15) + stamPct(7, bits 16-22)
            local resPacked = ultPct + magPct * 512 + stamPct * 65536
            BeltalowdaNetwork.resourceProtocol:Send({packed = resPacked})
        end
        
        if logger then
            logger:Debug("Broadcast state + resources", 
                string.format("ult=%d, combat=%d, vol=%d", 
                    safeUltimateId, inCombat, volFlag))
        end
    end)
    
    if not success then
        if logger then
            logger:Error("Error broadcasting manual ultimate", tostring(err))
        end
    end

    -- Also send in RdK format for cross-addon compatibility
    local RdKCompat = Beltalowda.network and Beltalowda.network.rdkCompat
    if RdKCompat and RdKCompat.SendHeartbeat then
        RdKCompat.SendHeartbeat(ultimateId, percentReady)
    end
end

--[[
    Handle received player state from group member (protocol 221)
    Unpacks ultimate ID + boolean flags from a 20-bit NumericField.
    
    @param sender: Unit tag of sender ("group1", "group2", etc.)
    @param data: Table with single "packed" field from LGB protocol
    
    Bit layout (20 bits):
    - Bits  0-17: ultId        (18 bits, 0-262143)
    - Bit     18: inCombat     ( 1 bit)
    - Bit     19: hasVolendrung( 1 bit)
]]--
function BeltalowdaNetwork.OnManualUltimateReceived(sender, data)
    local success, err = pcall(function()
        local packed = data.packed
        if not packed or type(packed) ~= "number" then
            if logger then
                logger:Warn("Received non-numeric packed field from " .. tostring(sender))
            end
            return
        end
        
        -- Unpack bits (Lua 5.1: use math.floor + modulo)
        local primaryUltimateId = packed % 262144                                 -- bits 0-17  (2^18)
        local inCombat          = (math.floor(packed / 262144) % 2) == 1          -- bit 18     (2^18)
        local hasVolendrung     = (math.floor(packed / 524288) % 2) == 1          -- bit 19     (2^19)
        
        -- Get sender's display name and character name
        local senderDisplayName = GetUnitDisplayName(sender)
        local senderCharName = GetUnitName(sender)
        
        if logger then
            logger:Info("Received player state",
                string.format("sender=%s (%s), ult=%d, combat=%s, vol=%s", 
                    senderCharName, senderDisplayName, primaryUltimateId,
                    tostring(inCombat), tostring(hasVolendrung)))
        end
        
        -- Update UI if available - store directly in playerData using character name
        if Beltalowda.UI and Beltalowda.UI.GroupUltimateDisplay and senderCharName and senderCharName ~= "" then
            local playerData = Beltalowda.UI.GroupUltimateDisplay.playerData
            
            playerData[senderCharName] = playerData[senderCharName] or {}
            
            -- Store ultimate identity (charge percentage comes from protocol 227)
            playerData[senderCharName].selectedUltimateId = primaryUltimateId
            
            -- Set frontbar to the selected ult from 221.  The backbar
            -- will be populated by protocol 226 (OnAltBarUltimateReceived)
            -- which carries the other bar's ult ID.  Until 226 arrives,
            -- backbar defaults to the same as frontbar (no upgrade scenario).
            -- For the local player, skip: CUS.BroadcastSelection sets the
            -- authoritative separate frontbar/backbar IDs directly.
            local localPlayerName = GetUnitName("player")
            if senderCharName ~= localPlayerName then
                playerData[senderCharName].frontbarUltimateId = primaryUltimateId
                -- Only reset backbar if it hasn't been set yet (first-ever 221)
                if not playerData[senderCharName].backbarUltimateId then
                    playerData[senderCharName].backbarUltimateId = primaryUltimateId
                end
            end
            playerData[senderCharName].inCombat = inCombat
            
            -- Source tracking for RdK compat data priority
            playerData[senderCharName].source = "beltalowda"
            playerData[senderCharName].lastUpdate = GetGameTimeMilliseconds()
            
            -- Enrich with raw ultimate value from LGCS if available
            if BeltalowdaNetwork.groupData then
                local senderUnitTag = nil
                for i = 1, GetGroupSize() do
                    local tag = GetGroupUnitTagByIndex(i)
                    if tag and GetUnitName(tag) == senderCharName then
                        senderUnitTag = tag
                        break
                    end
                end
                if senderUnitTag then
                    local lgcsUlt = BeltalowdaNetwork.groupData[senderUnitTag]
                        and BeltalowdaNetwork.groupData[senderUnitTag].ultimate
                    if lgcsUlt and lgcsUlt.current then
                        playerData[senderCharName].currentUlt = lgcsUlt.current
                    end
                end
            end
            
            -- Store Volendrung state
            playerData[senderCharName].hasVolendrung = hasVolendrung
            if not hasVolendrung then
                playerData[senderCharName].originalUltId = nil
                playerData[senderCharName].volendrungBar = nil
            end
            
            -- Refresh both classic and role-based trackers
            if Beltalowda.UI.GroupUltimateDisplay.RefreshDisplay then
                Beltalowda.UI.GroupUltimateDisplay.RefreshDisplay()
            end
            local GUDBR = Beltalowda.UI.GroupUltimateDisplayByRoles
            if GUDBR and GUDBR.RefreshDisplay then
                GUDBR.RefreshDisplay()
            end
        end
    end)
    
    if not success then
        d("[Beltalowda] ERROR processing player state: " .. tostring(err))
        if logger then
            logger:Error("Error processing player state", tostring(err))
        end
    end
end

--[[
    Handle received alt-bar ultimate from group member (protocol 226)
    Stores the other bar's ult ID so smart-upgrade detection works for
    remote players.  Protocol 221 carries the selected/primary ult,
    and this protocol carries whichever bar is NOT the primary.
    
    @param sender: Unit tag of sender ("group1", "group2", etc.)
    @param data: Table with "altBarUltId" field from LGB protocol
]]--
function BeltalowdaNetwork.OnAltBarUltimateReceived(sender, data)
    local altBarUltId = data.altBarUltId
    if not altBarUltId or type(altBarUltId) ~= "number" then return end
    
    local senderCharName = GetUnitName(sender)
    if not senderCharName or senderCharName == "" then return end
    
    -- Skip for local player (CUS owns the authoritative bar IDs)
    local localPlayerName = GetUnitName("player")
    if senderCharName == localPlayerName then return end
    
    if Beltalowda.UI and Beltalowda.UI.GroupUltimateDisplay then
        local playerData = Beltalowda.UI.GroupUltimateDisplay.playerData
        if playerData[senderCharName] then
            -- altBarUltId == 0 means both bars have the same ult (no alt)
            if altBarUltId > 0 then
                playerData[senderCharName].backbarUltimateId = altBarUltId
            else
                -- Same ult on both bars
                playerData[senderCharName].backbarUltimateId =
                    playerData[senderCharName].selectedUltimateId or 0
            end
        end
    end
end

--[[
    Handle received resource data from group member (protocol 227)
    Unpacks ultimate charge + magicka + stamina from a 23-bit NumericField.
    
    @param sender: Unit tag of sender ("group1", "group2", etc.)
    @param data: Table with single "packed" field from LGB protocol
    
    Bit layout (23 bits):
    - Bits  0-8:  ultPct  (9 bits, 0-500)  ultimate charge percentage
    - Bits  9-15: magPct  (7 bits, 0-100)  magicka percent
    - Bits 16-22: stamPct (7 bits, 0-100)  stamina percent
]]--
BeltalowdaNetwork.lastResourceRefreshTime = 0

function BeltalowdaNetwork.OnResourceReceived(sender, data)
    local packed = data.packed
    if not packed or type(packed) ~= "number" then return end
    
    local ultPct         = packed % 512                       -- bits 0-8
    local magickaPercent = math.floor(packed / 512) % 128     -- bits 9-15
    local staminaPercent = math.floor(packed / 65536) % 128   -- bits 16-22
    
    local senderCharName = GetUnitName(sender)
    if not senderCharName or senderCharName == "" then return end
    
    if Beltalowda.UI and Beltalowda.UI.GroupUltimateDisplay then
        local playerData = Beltalowda.UI.GroupUltimateDisplay.playerData
        playerData[senderCharName] = playerData[senderCharName] or {}
        playerData[senderCharName].ultimatePercent = ultPct
        playerData[senderCharName].magickaPercent = magickaPercent
        playerData[senderCharName].staminaPercent = staminaPercent
        
        -- Throttled refresh: ultimatePercent changes affect upgrade affordability
        -- and resource bar display.  Limit to once per 500 ms to avoid hammering
        -- the UI when many group members' resources arrive in the same frame.
        local now = GetFrameTimeMilliseconds()
        if now - BeltalowdaNetwork.lastResourceRefreshTime >= 500 then
            BeltalowdaNetwork.lastResourceRefreshTime = now
            if Beltalowda.UI.GroupUltimateDisplay.RefreshDisplay then
                Beltalowda.UI.GroupUltimateDisplay.RefreshDisplay()
            end
            local GUDBR = Beltalowda.UI.GroupUltimateDisplayByRoles
            if GUDBR and GUDBR.RefreshDisplay then
                GUDBR.RefreshDisplay()
            end
        end
    end
end

--[[
    Equipment and Role Broadcasting
    
    Protocol ID: 222 (EQUIPMENT_AND_ROLE)
    Broadcasts player's equipped sets and detected role to group
]]--

-- Storage for equipment protocol
BeltalowdaNetwork.equipmentProtocol = nil
BeltalowdaNetwork.lastEquipmentBroadcastTime = 0
BeltalowdaNetwork.EQUIPMENT_BROADCAST_THROTTLE = 2000  -- 2 seconds minimum between broadcasts

--[[
    Subscribe to equipment and role broadcasts
]]--
function BeltalowdaNetwork.SubscribeToEquipmentBroadcasts()
    -- Debug removed: too verbose for production use
    
    -- Check if already initialized
    if BeltalowdaNetwork.equipmentProtocol then
        return
    end
    
    local LGB = GetLibGroupBroadcast()
    if not LGB then
        d("[Beltalowda] WARNING: LibGroupBroadcast not available for equipment subscription")
        if logger then
            logger:Warn("LibGroupBroadcast not available for equipment subscription")
        end
        return
    end
    
    if not BeltalowdaNetwork.lgbHandler then
        d("[Beltalowda] WARNING: LGB handler not registered yet")
        return
    end
    
    local success, err = pcall(function()
        -- Debug removed: too verbose for production use
        
        BeltalowdaNetwork.equipmentProtocol = BeltalowdaNetwork.lgbHandler:DeclareProtocol(
            BeltalowdaNetwork.MESSAGE_IDS.EQUIPMENT_AND_ROLE,
            "BeltalowdaEquipmentRole"
        )
        
        -- Single StringField carries the full payload: "role|set1:pieces:bar,...|buff1,buff2"
        -- Role is parsed from the string; sender is identified via LGB's callback unitTag.
        -- Previous 3-field design (equipmentData + role + senderIndex) overflowed the
        -- StringField 200-bit limit when players had many sets equipped.
        BeltalowdaNetwork.equipmentProtocol:AddField(LGB.CreateStringField("equipmentData"))
        
        -- Register callback for received data
        BeltalowdaNetwork.equipmentProtocol:OnData(function(unitTag, data)
            local success, err = pcall(function()
                if not data or not data.equipmentData then
                    if logger then
                        logger:Warn(string.format("Received malformed equipment data from %s", tostring(unitTag)))
                    end
                    return
                end
                BeltalowdaNetwork.OnEquipmentBroadcastReceived(unitTag, data.equipmentData)
            end)
            if not success then
                if logger then
                    logger:Error(string.format("Error processing equipment data from %s: %s", tostring(unitTag), tostring(err)))
                end
            end
        end)
        
        -- Finalize protocol
        BeltalowdaNetwork.equipmentProtocol:Finalize({isRelevantInCombat = false, replaceQueuedMessages = true})
        
        -- Debug removed: too verbose for production use
        if logger then
            logger:Info("Registered for equipment and role broadcasts via protocol API")
        end
    end)
    
    if not success then
        d("[Beltalowda] ERROR subscribing to equipment broadcasts: " .. tostring(err))
        if logger then
            logger:Error("Error subscribing to equipment broadcasts", tostring(err))
        end
    end
end

--[[
    Request Composition Update Protocol
    
    Protocol ID: 223 (REQUEST_COMPOSITION_UPDATE)
    Requests all group members to broadcast their equipment
]]--

-- Storage for request protocol
BeltalowdaNetwork.requestProtocol = nil
BeltalowdaNetwork.lastCompositionRequestTime = 0
BeltalowdaNetwork.COMPOSITION_REQUEST_THROTTLE = 1000  -- 1 second minimum between processing requests

--[[
    Subscribe to composition update requests
]]--
function BeltalowdaNetwork.SubscribeToCompositionRequests()
    -- Check if already initialized
    if BeltalowdaNetwork.requestProtocol then
        return
    end
    
    local LGB = GetLibGroupBroadcast()
    if not LGB then
        d("[Beltalowda] WARNING: LibGroupBroadcast not available for request subscription")
        if logger then
            logger:Warn("LibGroupBroadcast not available for request subscription")
        end
        return
    end
    
    if not BeltalowdaNetwork.lgbHandler then
        d("[Beltalowda] WARNING: LGB handler not registered yet")
        return
    end
    
    local success, err = pcall(function()
        BeltalowdaNetwork.requestProtocol = BeltalowdaNetwork.lgbHandler:DeclareProtocol(
            BeltalowdaNetwork.MESSAGE_IDS.REQUEST_COMPOSITION_UPDATE,
            "BeltalowdaRequestComposition"
        )
        
        -- Add a timestamp field for tracking request timing
        -- Single-bit flag: the value itself is irrelevant, receipt of the message IS the request
        BeltalowdaNetwork.requestProtocol:AddField(LGB.CreateNumericField("flag", {
            minValue = 0,
            maxValue = 1,
            trimValues = true,
        }))
        
        -- Register callback for received requests
        BeltalowdaNetwork.requestProtocol:OnData(function(unitTag, data)
            local success, err = pcall(function()
                -- Throttle to prevent excessive broadcasts from multiple simultaneous requests
                local currentTime = GetFrameTimeMilliseconds()
                if currentTime - BeltalowdaNetwork.lastCompositionRequestTime < BeltalowdaNetwork.COMPOSITION_REQUEST_THROTTLE then
                    if logger then
                        logger:Debug("Composition request throttled - already processed recently")
                    end
                    return
                end
                BeltalowdaNetwork.lastCompositionRequestTime = currentTime
                
                -- When we receive a request, broadcast our equipment data
                if logger then
                    logger:Debug("Received composition update request from " .. tostring(unitTag))
                end
                
                -- Stagger responses with random jitter (0–2s) to avoid N×2 message
                -- burst in trial groups: without jitter, all 24 members respond
                -- simultaneously to a single composition request.
                local jitterMs = math.random(0, 2000)
                zo_callLater(function()
                    -- Helper function to attempt broadcast with retry on failure
                    -- Note: BroadcastEquipmentAndRole internally checks if LibSetDetection has data
                    -- and returns early if not available, so no invalid data is broadcast
                    local function attemptBroadcast(isRetry)
                        BeltalowdaNetwork.BroadcastEquipmentAndRole(true)  -- force: bypass throttle for composition request
                        
                        -- Check if broadcast succeeded (LibSetDetection has data)
                        if LibSetDetection and LibSetDetection.GetUnitSetData then
                            local setData = LibSetDetection.GetUnitSetData("player")
                            if not setData then
                                if isRetry then
                                    -- Second attempt failed - log warning but don't retry again
                                    if logger then
                                        logger:Warn("LibSetDetection still not ready after retry - broadcast skipped")
                                    end
                                else
                                    -- First attempt failed - schedule retry
                                    if logger then
                                        logger:Debug("LibSetDetection not ready, will retry broadcast in 2 seconds")
                                    end
                                    zo_callLater(function()
                                        attemptBroadcast(true)
                                    end, 2000)
                                end
                            end
                        end
                    end
                    
                    -- Try to broadcast
                    attemptBroadcast(false)
                    
                    -- Also re-broadcast synergy composition bitmask
                    local SC = Beltalowda.Data and Beltalowda.Data.SynergyComposition
                    if SC and SC.ScanLocalPlayer then
                        SC.previousLocalBitmask = -1  -- Force re-broadcast
                        SC.ScanLocalPlayer()
                    end

                    -- Also re-broadcast buff composition bitmask
                    local BC = Beltalowda.Data and Beltalowda.Data.BuffComposition
                    if BC and BC.ScanLocalPlayer then
                        BC.previousLocalBitmask = -1  -- Force re-broadcast
                        BC.ScanLocalPlayer()
                    end

                    -- Also re-broadcast consumable state
                    local ConsT = Beltalowda.Data and Beltalowda.Data.ConsumableTracker
                    if ConsT and ConsT.ScanLocalPlayer and ConsT.BroadcastIfChanged then
                        ConsT.ScanLocalPlayer()
                        ConsT.BroadcastIfChanged(true)
                    end
                end, jitterMs)
            end)
            if not success then
                if logger then
                    logger:Error(string.format("Error processing composition request from %s: %s", tostring(unitTag), tostring(err)))
                end
            end
        end)
        
        -- Finalize protocol (replaceQueuedMessages=true to prevent queue buildup)
        BeltalowdaNetwork.requestProtocol:Finalize({isRelevantInCombat = false, replaceQueuedMessages = true})
        
        if logger then
            logger:Info("Registered for composition update requests via protocol API")
        end
    end)
    
    if not success then
        d("[Beltalowda] ERROR subscribing to composition requests: " .. tostring(err))
        if logger then
            logger:Error("Error subscribing to composition requests", tostring(err))
        end
    end
end

--[[
    Request composition update from all group members
    Called when opening composition panel to ensure fresh data
]]--
function BeltalowdaNetwork.RequestGroupCompositionUpdate()
    local groupSize = GetGroupSize()
    if groupSize == 0 then
        return
    end
    
    -- Don't pre-send our own equipment here. The protocol 223 handler
    -- (which fires for self-sends too) will broadcast our data along
    -- with the jittered response, eliminating a redundant double-send.
    
    -- Send request to all group members to broadcast their equipment
    if BeltalowdaNetwork.requestProtocol then
        local success, err = pcall(function()
            BeltalowdaNetwork.requestProtocol:Send({
                flag = 1
            })
        end)
        
        if success then
            if logger then
                logger:Debug("Sent composition update request to group")
            end
        else
            d("[Beltalowda] ERROR requesting composition update: " .. tostring(err))
            if logger then
                logger:Error("Error requesting composition update", tostring(err))
            end
        end
    else
        d("[Beltalowda] WARNING: Request protocol not initialized, cannot request updates from group")
        if logger then
            logger:Warn("Request protocol not initialized")
        end
    end
end

--[[
    Broadcast equipment and role to group
    Throttled to prevent spam
    @param forceBroadcast: (optional) If true, bypass the time throttle and fingerprint dedup
]]--
function BeltalowdaNetwork.BroadcastEquipmentAndRole(forceBroadcast)
    -- Check throttle (bypassed when forceBroadcast is true)
    local currentTime = GetFrameTimeMilliseconds()
    if not forceBroadcast and currentTime - BeltalowdaNetwork.lastEquipmentBroadcastTime < BeltalowdaNetwork.EQUIPMENT_BROADCAST_THROTTLE then
        if logger then
            logger:Debug("Equipment broadcast throttled")
        end
        return
    end
    
    if not LibSetDetection then
        if logger then
            logger:Warn("Cannot broadcast equipment - LibSetDetection not available")
        end
        return
    end
    
    if not BeltalowdaNetwork.equipmentProtocol then
        if logger then
            logger:Warn("Cannot broadcast equipment - protocol not initialized")
        end
        return
    end
    
    local groupSize = GetGroupSize()
    if groupSize == 0 then
        if logger then
            logger:Debug("Cannot broadcast equipment - not in a group")
        end
        return
    end
    
    -- Get player's current equipment
    local setData = LibSetDetection.GetUnitSetData("player")
    if not setData then
        if logger then
            logger:Debug("Cannot broadcast equipment - no set data available")
        end
        return
    end
    
    -- Extract "useful bits" using SetDatabase
    local usefulBits = {}
    if Beltalowda.SetDatabase and Beltalowda.SetDatabase.ExtractUsefulBits then
        usefulBits = Beltalowda.SetDatabase.ExtractUsefulBits(setData)
    else
        -- Fallback to simple role detection
        usefulBits.role = "damage"
        usefulBits.sets = {}
        usefulBits.buffsProvided = {}
    end
    
    -- Check if equipment actually changed to filter bar swap events
    -- Create a fingerprint of current equipment: setId:pieces:quality for each set
    local currentFingerprint = usefulBits.role or "damage"
    if usefulBits.sets and #usefulBits.sets > 0 then
        local setParts = {}
        for _, set in ipairs(usefulBits.sets) do
            if set.id and set.pieces then
                table.insert(setParts, tostring(set.id) .. ":" .. tostring(set.pieces) .. ":" .. tostring(set.quality or 5))
            end
        end
        table.sort(setParts)  -- Sort for consistent comparison
        currentFingerprint = currentFingerprint .. "|" .. table.concat(setParts, ",")
    end
    
    -- Always store usefulBits locally so composition analysis has data
    -- regardless of whether the broadcast succeeds or fingerprint matches
    local playerUnitTag = GetGroupUnitTagByIndex(GetGroupIndexByUnitTag("player"))
    if playerUnitTag then
        BeltalowdaNetwork.groupData[playerUnitTag] = BeltalowdaNetwork.groupData[playerUnitTag] or {}
        BeltalowdaNetwork.groupData[playerUnitTag].equipment = BeltalowdaNetwork.groupData[playerUnitTag].equipment or {}
        BeltalowdaNetwork.groupData[playerUnitTag].equipment.usefulBits = usefulBits
        BeltalowdaNetwork.groupData[playerUnitTag].equipment.role = usefulBits.role
        
        -- Trigger OnDataChanged so all wrappers (Settings panel refresh, GUD, etc.) run
        -- with the now-correct usefulBits data, not the stale data from the
        -- immediate OnDataChanged that fired before this delayed extraction.
        BeltalowdaNetwork.OnDataChanged("equipment", playerUnitTag)
    end
    
    -- Compare with previous state (bypassed when forceBroadcast is true)
    if not forceBroadcast and BeltalowdaNetwork.previousEquipmentState == currentFingerprint then
        if logger then
            logger:Debug("Equipment unchanged (bar swap detected) - skipping broadcast")
        end
        return  -- Don't broadcast if equipment hasn't changed
    end
    
    -- NOTE: previousEquipmentState is updated AFTER a successful Send() below.
    -- This ensures that if Send() fails, the next attempt won't be blocked
    -- by a stale fingerprint.
    
    -- ── Binary-encode equipment data ──────────────────────────────────────
    -- Format (compact binary, fits within 24-byte StringField limit):
    --   Byte 0: header
    --     bits 0-1: role (0=damage, 1=healer, 2=tank, 3=support)
    --     bits 2-4: number of sets (0-7)
    --     bits 5-7: reserved
    --   Per set (3 bytes each, max 7 sets = 21 bytes):
    --     Bytes 0-1: setId (uint16 little-endian, 0-65535)
    --     Byte 2: bits 0-2 = pieces (0-7), bits 3-4 = bar (0=none,1=F,2=B,3=A),
    --             bits 5-7 = quality (0-5=ESO tiers, 6=mythic)
    -- Total worst case: 1 + 7*3 = 22 bytes — well within 24-byte limit.
    -- Buffs (buffsProvided) are derived from set IDs on the receiver side,
    -- so they don't need to be transmitted.
    
    local ROLE_CODES = { damage = 0, support = 1, pull = 2 }
    -- Note: wire codes 0=damage, 1=support, 2=pull, 3=support (legacy)
    local BAR_CODES = { [""] = 0, [" (Front Bar)"] = 1, [" (Back Bar)"] = 2, [" (Both Bars)"] = 3 }
    
    local roleCode = ROLE_CODES[usefulBits.role] or 0
    local sets = usefulBits.sets or {}
    local numSets = math.min(#sets, 7)  -- Cap at 7
    
    local header = roleCode + numSets * 4  -- bits 0-1 = role, bits 2-4 = numSets
    local bytes = { string.char(header) }
    
    for i = 1, numSets do
        local set = sets[i]
        local setId = set.id or 0
        local pieces = math.min(set.pieces or 5, 7)
        local barCode = BAR_CODES[set.barInfo or ""] or 0
        local quality = math.min(set.quality or 5, 7)  -- bits 5-7 (0-7)
        
        -- uint16 little-endian
        local lo = setId % 256
        local hi = math.floor(setId / 256) % 256
        local info = pieces + barCode * 8 + quality * 32  -- bits 0-2 = pieces, bits 3-4 = bar, bits 5-7 = quality
        
        table.insert(bytes, string.char(lo, hi, info))
    end
    
    local broadcastStr = table.concat(bytes)
    
    -- Require being in a group
    if GetGroupSize() == 0 then
        if logger then
            logger:Debug("Cannot broadcast equipment - not in a group")
        end
        return
    end
    
    local success, err = pcall(function()
        BeltalowdaNetwork.equipmentProtocol:Send({
            equipmentData = broadcastStr
        })
    end)
    
    if success then
        BeltalowdaNetwork.lastEquipmentBroadcastTime = currentTime
        BeltalowdaNetwork.previousEquipmentState = currentFingerprint
        if logger then
            logger:Debug("Equipment broadcast sent", "role=" .. usefulBits.role, "sets=" .. tostring(#usefulBits.sets))
        end
    else
        if logger then
            logger:Error("Error broadcasting equipment", tostring(err))
        end
        d("[Beltalowda] ERROR broadcasting equipment: " .. tostring(err))
    end
end

--[[
    Handle received equipment broadcast
]]--
function BeltalowdaNetwork.OnEquipmentBroadcastReceived(unitTag, equipmentDataStr)
    local success, err = pcall(function()
        -- Use the callback unitTag directly — LGB already tells us who sent it
        local senderUnitTag = unitTag
        local senderCharName = GetUnitName(unitTag) or "Unknown"
        
        if logger then
            logger:Debug("Equipment broadcast received",
                "unitTag=" .. tostring(senderUnitTag),
                "charName=" .. tostring(senderCharName))
        end
        
        -- ── Decode binary equipment data ──────────────────────────────────
        -- Format: header byte + 3 bytes per set (see BroadcastEquipmentAndRole)
        local ROLE_NAMES = { [0] = "damage", [1] = "support", [2] = "pull", [3] = "support" }
        -- Note: codes 1 and 3 both decode to "support" for backward compatibility
        local BAR_NAMES = { [0] = "", [1] = " (Front Bar)", [2] = " (Back Bar)", [3] = " (Both Bars)" }
        
        -- Known set→buff mappings (same logic as SetDatabase.ExtractUsefulBits)
        local SET_BUFFS = {
            [410] = "Major Courage",        -- Olorime
            [140] = "Major Courage",        -- Spell Power Cure
            [305] = "Major Courage",        -- Powerful Assault
            [75]  = "Max Health",           -- Ebon Armory
            [413] = "Major Evasion (Group)",-- Gossamer
            [659] = "Critical Resistance + Weapon/Spell Damage (Group)", -- Rallying Cry
            [519] = "Immunity to Snares and Immobilizations", -- Snow Treaders (resolved to localized label below)
        }
        
        local usefulBits = {
            role = "damage",
            sets = {},
            buffsProvided = {},
            warnings = {}
        }
        
        if equipmentDataStr and #equipmentDataStr >= 1 then
            local headerByte = string.byte(equipmentDataStr, 1)
            local roleCode = headerByte % 4            -- bits 0-1
            local numSets = math.floor(headerByte / 4) % 8  -- bits 2-4
            
            usefulBits.role = ROLE_NAMES[roleCode] or "damage"
            
            for i = 1, numSets do
                local offset = 1 + (i - 1) * 3  -- 1-based, after header
                if offset + 3 > #equipmentDataStr then break end
                
                local lo = string.byte(equipmentDataStr, offset + 1)
                local hi = string.byte(equipmentDataStr, offset + 2)
                local info = string.byte(equipmentDataStr, offset + 3)
                
                local setId = lo + hi * 256
                local pieces = info % 8               -- bits 0-2
                local barCode = math.floor(info / 8) % 4  -- bits 3-4
                local quality = math.floor(info / 32) % 8  -- bits 5-7
                
                -- Look up set name
                local setName = "Unknown Set"
                if Beltalowda.SetDatabase and Beltalowda.SetDatabase.GetSetName then
                    setName = Beltalowda.SetDatabase.GetSetName(setId)
                end
                
                table.insert(usefulBits.sets, {
                    id = setId,
                    name = setName,
                    pieces = pieces,
                    maxPieces = Beltalowda.SetDatabase and Beltalowda.SetDatabase.GetSetMaxPieces
                        and Beltalowda.SetDatabase.GetSetMaxPieces(setId) or 5,
                    barInfo = BAR_NAMES[barCode] or "",
                    quality = quality,
                })
                
                -- Derive buffs from set ID (same as SetDatabase)
                local setMaxPieces = Beltalowda.SetDatabase and Beltalowda.SetDatabase.GetSetMaxPieces
                    and Beltalowda.SetDatabase.GetSetMaxPieces(setId) or 5
                if pieces >= setMaxPieces and SET_BUFFS[setId] then
                    -- Use localized source-aware label for buffs with displayPrefix
                    local BuffDB = Beltalowda.Data and Beltalowda.Data.BuffDatabase
                    local buffLabel = SET_BUFFS[setId]
                    if BuffDB then
                        local def = BuffDB.BUFF_DEFINITIONS[buffLabel]
                        if def and def.displayPrefix then
                            buffLabel = string.format("%s from %s", def.displayPrefix, setName)
                        end
                    end
                    table.insert(usefulBits.buffsProvided, buffLabel)
                end
            end
        end
        
        -- Store in groupData
        -- Safety check: verify the unitTag exists
        if not senderUnitTag then
            if logger then
                logger:Warn("Could not resolve sender unitTag")
            end
            return
        end
        
        BeltalowdaNetwork.groupData[senderUnitTag] = BeltalowdaNetwork.groupData[senderUnitTag] or {}
        BeltalowdaNetwork.groupData[senderUnitTag].equipment = BeltalowdaNetwork.groupData[senderUnitTag].equipment or {}
        BeltalowdaNetwork.groupData[senderUnitTag].equipment.usefulBits = usefulBits
        BeltalowdaNetwork.groupData[senderUnitTag].equipment.role = usefulBits.role
        
        -- Trigger UI update and composition analysis
        BeltalowdaNetwork.OnDataChanged("equipment", senderUnitTag)
        
        -- Trigger composition analysis
        if Beltalowda.Composition and Beltalowda.Composition.AnalyzeComposition then
            Beltalowda.Composition.AnalyzeComposition()
        end
    end)
    
    if not success then
        d("[Beltalowda] ERROR processing equipment broadcast: " .. tostring(err))
        if logger then
            logger:Error("Error processing equipment broadcast", tostring(err))
        end
    end
end

-- ============================================================================
-- Synergy Broadcast Protocol (ID 224)
-- Each client detects when the LOCAL player takes a synergy and broadcasts it.
-- Other clients receive the broadcast and update their trackers.
-- Message: 2 bytes — synergyId (1 byte) + delay in 100ms units (1 byte)
-- ============================================================================

function BeltalowdaNetwork.SubscribeToSynergyBroadcasts()
    if BeltalowdaNetwork.synergyProtocol then
        return
    end

    local LGB = GetLibGroupBroadcast()
    if not LGB then
        d("[Beltalowda] WARNING: LibGroupBroadcast not available for synergy subscription")
        return
    end

    if not BeltalowdaNetwork.lgbHandler then
        d("[Beltalowda] WARNING: LGB handler not registered yet for synergy subscription")
        return
    end

    local success, err = pcall(function()
        BeltalowdaNetwork.synergyProtocol = BeltalowdaNetwork.lgbHandler:DeclareProtocol(
            BeltalowdaNetwork.MESSAGE_IDS.SYNERGY_BROADCAST,
            "BeltalowdaSynergy"
        )

        -- Use a NumericField (matching RdK's proven pattern)
        -- Pack 2 bytes into one number: synergyId * 256 + delay(100ms units)
        -- Max value: 255 * 256 + 255 = 65535
        BeltalowdaNetwork.synergyProtocol:AddField(LGB.CreateNumericField("numeric", {
            minValue = 0,
            maxValue = 65535,
        }))

        BeltalowdaNetwork.synergyProtocol:OnData(function(unitTag, data)
            local ok, innerErr = pcall(function()
                if not data or not data.numeric then
                    if logger then
                        logger:Warn(string.format("Received malformed synergy data from %s", tostring(unitTag)))
                    end
                    return
                end
                BeltalowdaNetwork.OnSynergyReceived(unitTag, data.numeric)
            end)
            if not ok then
                if logger then
                    logger:Error(string.format("Error processing synergy data from %s: %s", tostring(unitTag), tostring(innerErr)))
                end
            end
        end)

        BeltalowdaNetwork.synergyProtocol:Finalize({isRelevantInCombat = true, replaceQueuedMessages = false})

        if logger then
            logger:Info("Registered for synergy broadcasts via protocol 224")
        end
    end)

    if not success then
        d("[Beltalowda] ERROR subscribing to synergy broadcasts: " .. tostring(err))
        if logger then
            logger:Error("Error subscribing to synergy broadcasts", tostring(err))
        end
    end
end

--[[
    Broadcast a synergy event to the group.
    Called by SynergyTracker when the local player takes a synergy.
    @param synergyId: Synergy ID (1-255)
    @param delay100ms: Delay since detection in 100ms units (0-255)
]]
function BeltalowdaNetwork.BroadcastSynergy(synergyId, delay100ms)
    if not BeltalowdaNetwork.synergyProtocol then return end

    local groupSize = GetGroupSize()
    if groupSize == 0 then return end

    local safeSynergyId = math.max(0, math.min(255, math.floor(synergyId or 0)))
    local safeDelay = math.max(0, math.min(255, math.floor(delay100ms or 0)))

    -- Pack into a single numeric: synergyId * 256 + delay (matching RdK's byte-packing approach)
    local numericVal = safeSynergyId * 256 + safeDelay

    local success, err = pcall(function()
        BeltalowdaNetwork.synergyProtocol:Send({numeric = numericVal})
    end)

    if success then
        if logger then
            logger:Debug("Synergy broadcast sent", string.format("id=%d, delay=%d, numeric=%d", safeSynergyId, safeDelay, numericVal))
        end
    else
        if logger then
            logger:Error("Error broadcasting synergy", tostring(err))
        end
    end

    -- Also send in RdK format for cross-addon compatibility
    local RdKCompat = Beltalowda.network and Beltalowda.network.rdkCompat
    if RdKCompat and RdKCompat.SendSynergy then
        RdKCompat.SendSynergy(safeSynergyId, safeDelay)
    end
end

--[[
    Handle received synergy data from a group member.
    @param unitTag: Sender's unit tag
    @param numericVal: Packed numeric value (synergyId * 256 + delay)
]]
function BeltalowdaNetwork.OnSynergyReceived(unitTag, numericVal)
    -- Unpack: synergyId is high byte, delay is low byte
    local synergyId = math.floor(numericVal / 256)
    local delay100ms = numericVal % 256
    local delayMs = delay100ms * 100

    local charName = GetUnitName(unitTag)
    if not charName or charName == "" then return end

    -- Record in SynergyTracker data layer
    local ST = Beltalowda.Data and Beltalowda.Data.SynergyTracker
    if ST and ST.RecordSynergy then
        ST.RecordSynergy(charName, synergyId, delayMs)
    end

    if logger then
        logger:Debug("Synergy received",
            string.format("from=%s, synergy=%d, delay=%dms", charName, synergyId, delayMs))
    end
end

-- ============================================================================
-- Composition Protocol (ID 225)
-- Two fields:
--   1. compositionBitmask (32-bit NumericField): synergy (24 bits) + buff (8 bits)
--      Packing:   compositeValue = synergyBitmask + buffBitmask * 16777216
--      Unpacking: synergyBitmask = compositeValue % 16777216
--                 buffBitmask    = math.floor(compositeValue / 16777216)
--   2. cpSlots (ArrayField of 12 NumericFields): champion skill IDs per bar slot
--      Fixed 12-element array, 10 bits per element (maxValue 1023).
--      Value 0 = empty slot. Ordered by bar slot index (grouped by discipline).
-- Low frequency: only sent on skill swap, gear change, CP change, or group join.
-- ============================================================================

function BeltalowdaNetwork.SubscribeToComposition()
    if BeltalowdaNetwork.compositionProtocol then
        return
    end

    local LGB = GetLibGroupBroadcast()
    if not LGB then
        d("[Beltalowda] WARNING: LibGroupBroadcast not available for composition")
        return
    end

    if not BeltalowdaNetwork.lgbHandler then
        d("[Beltalowda] WARNING: LGB handler not registered yet for composition")
        return
    end

    local success, err = pcall(function()
        BeltalowdaNetwork.compositionProtocol = BeltalowdaNetwork.lgbHandler:DeclareProtocol(
            BeltalowdaNetwork.MESSAGE_IDS.COMPOSITION,
            "BeltalowdaComposition"
        )

        -- Field 1: 32-bit NumericField — synergy (24 bits) + buff (8 bits)
        BeltalowdaNetwork.compositionProtocol:AddField(LGB.CreateNumericField("compositionBitmask", {
            minValue = 0,
            maxValue = 4294967295,  -- 2^32 - 1
        }))

        -- Field 2: Array of champion skill IDs (10 bits each, up to 12 elements)
        -- Ordered by bar slot index: slots 1-4 = discipline A, 5-8 = B, 9-12 = C
        -- Value 0 = empty slot; valid champion skill IDs fit within 0-1023
        -- Note: minLength must be < maxLength — LGB's internal count field is a
        -- NumericField(min, max), and NumericField requires range > 0.
        BeltalowdaNetwork.compositionProtocol:AddField(LGB.CreateArrayField(
            LGB.CreateNumericField("cpSlots", { minValue = 0, maxValue = 1023 }),
            { minLength = 0, maxLength = 12 }
        ))

        BeltalowdaNetwork.compositionProtocol:OnData(function(unitTag, data)
            local ok, innerErr = pcall(function()
                if not data or data.compositionBitmask == nil then
                    if logger then
                        logger:Warn(string.format("Received malformed composition from %s", tostring(unitTag)))
                    end
                    return
                end

                local composite = data.compositionBitmask
                local synergyBitmask = composite % 16777216         -- bits 0-23
                local buffBitmask = math.floor(composite / 16777216) -- bits 24-31

                -- Forward synergy data to SynergyComposition module
                local SC = Beltalowda.Data and Beltalowda.Data.SynergyComposition
                if SC and SC.OnSynergyCompositionReceived then
                    SC.OnSynergyCompositionReceived(unitTag, synergyBitmask)
                end

                -- Forward buff data to BuffComposition module
                local BC = Beltalowda.Data and Beltalowda.Data.BuffComposition
                if BC and BC.OnBuffCompositionReceived then
                    BC.OnBuffCompositionReceived(unitTag, buffBitmask)
                end

                -- Forward champion point data to ChampionPointComposition module
                if data.cpSlots then
                    local CPC = Beltalowda.Data and Beltalowda.Data.ChampionPointComposition
                    if CPC and CPC.OnChampionDataReceived then
                        CPC.OnChampionDataReceived(unitTag, data.cpSlots)
                    end
                end
            end)
            if not ok then
                if logger then
                    logger:Error(string.format("Error processing composition from %s: %s",
                        tostring(unitTag), tostring(innerErr)))
                end
            end
        end)

        -- Low frequency, latest value supersedes previous
        local finalized = BeltalowdaNetwork.compositionProtocol:Finalize({
            isRelevantInCombat = false,
            replaceQueuedMessages = true,
        })

        if not finalized then
            error("Composition protocol 225 failed to finalize (check field warnings)")
        end

        if logger then
            logger:Info("Registered for composition broadcasts via protocol 225")
        end
    end)

    if not success then
        d("[Beltalowda] ERROR subscribing to composition: " .. tostring(err))
        if logger then
            logger:Error("Error subscribing to composition", tostring(err))
        end
    end
end

--[[
    Internal: send the merged composition bitmask.
    Called by BroadcastSynergyComposition / BroadcastBuffComposition after
    updating their respective cached values.
]]
local function SendComposition()
    if not BeltalowdaNetwork.compositionProtocol then return end

    local groupSize = GetGroupSize()
    if groupSize == 0 then return end

    local compositeValue = BeltalowdaNetwork.cachedSynergyBitmask
                         + BeltalowdaNetwork.cachedBuffBitmask * 16777216

    local success, err = pcall(function()
        BeltalowdaNetwork.compositionProtocol:Send({
            compositionBitmask = compositeValue,
            cpSlots = BeltalowdaNetwork.cachedCpSlots,
        })
    end)

    if success then
        if logger then
            logger:Debug("Composition broadcast sent",
                string.format("synergy=%d buff=%d composite=%d cpSlots=%d values",
                    BeltalowdaNetwork.cachedSynergyBitmask,
                    BeltalowdaNetwork.cachedBuffBitmask,
                    compositeValue,
                    #BeltalowdaNetwork.cachedCpSlots))
        end
    else
        if logger then
            logger:Error("Error broadcasting composition", tostring(err))
        end
    end
end

--[[
    Broadcast synergy composition bitmask to the group.
    Called by SynergyComposition when local bitmask changes.
    Internally caches the value and sends a merged synergy+buff packet on protocol 225.
    @param bitmask: 24-bit synergy bitmask (0 to 2^24-1)
]]
function BeltalowdaNetwork.BroadcastSynergyComposition(bitmask)
    BeltalowdaNetwork.cachedSynergyBitmask = math.max(0, math.min(16777215, math.floor(bitmask or 0)))
    SendComposition()
end

--[[
    Broadcast buff composition bitmask to the group.
    Called by BuffComposition when local bitmask changes.
    Internally caches the value and sends a merged synergy+buff packet on protocol 225.
    @param bitmask: Buff bitmask (0 to 255)
]]
function BeltalowdaNetwork.BroadcastBuffComposition(bitmask)
    BeltalowdaNetwork.cachedBuffBitmask = math.max(0, math.min(255, math.floor(bitmask or 0)))
    SendComposition()
end

--[[
    Broadcast champion point composition to the group.
    Called by ChampionPointComposition when local CP bar changes.
    Internally caches the flat slot array and sends a merged composition packet on protocol 225.
    @param flatSlots: 12-element array of champion skill IDs (0 = empty)
]]
function BeltalowdaNetwork.BroadcastChampionPointComposition(flatSlots)
    if flatSlots and #flatSlots >= 12 then
        BeltalowdaNetwork.cachedCpSlots = {}
        for i = 1, 12 do
            BeltalowdaNetwork.cachedCpSlots[i] = math.max(0, math.min(1023, math.floor(flatSlots[i] or 0)))
        end
    end
    SendComposition()
end

-- ============================================================================
-- Consumable State Protocol (ID 228)
-- Three NumericFields carrying remaining time (in 10s units) for
-- food/drink, AP buff, and XP buff categories. ~30 bits total.
-- isRelevantInCombat = false: consumable timers aren't combat-urgent.
-- replaceQueuedMessages = true: latest values supersede previous.
-- Potions excluded — fully handled by LibGroupPotionCooldowns (protocol 26).
-- ============================================================================

function BeltalowdaNetwork.SubscribeToConsumableState()
    if BeltalowdaNetwork.consumableProtocol then
        return
    end

    local LGB = GetLibGroupBroadcast()
    if not LGB then
        d("[Beltalowda] WARNING: LibGroupBroadcast not available for consumable subscription")
        return
    end

    if not BeltalowdaNetwork.lgbHandler then
        d("[Beltalowda] WARNING: LGB handler not registered yet for consumable subscription")
        return
    end

    local success, err = pcall(function()
        BeltalowdaNetwork.consumableProtocol = BeltalowdaNetwork.lgbHandler:DeclareProtocol(
            BeltalowdaNetwork.MESSAGE_IDS.CONSUMABLE_STATE,
            "BeltalowdaConsumableState"
        )

        -- Three numeric fields, each carrying remaining time in 10s units.
        -- Max value 1440 = 14400s / 10s precision = 4 hours.
        -- Each field needs ceil(log2(1441)) = 11 bits → 33 bits total.
        BeltalowdaNetwork.consumableProtocol:AddField(
            LGB.CreateNumericField("foodRemain", {minValue = 0, maxValue = 1440, trimValues = true})
        )
        BeltalowdaNetwork.consumableProtocol:AddField(
            LGB.CreateNumericField("apRemain", {minValue = 0, maxValue = 1440, trimValues = true})
        )
        BeltalowdaNetwork.consumableProtocol:AddField(
            LGB.CreateNumericField("xpRemain", {minValue = 0, maxValue = 1440, trimValues = true})
        )

        BeltalowdaNetwork.consumableProtocol:OnData(function(unitTag, data)
            local ok, innerErr = pcall(function()
                if not data then
                    if logger then
                        logger:Warn(string.format("Received malformed consumable data from %s", tostring(unitTag)))
                    end
                    return
                end

                local CT = Beltalowda.Data and Beltalowda.Data.ConsumableTracker
                if CT and CT.OnConsumableDataReceived then
                    CT.OnConsumableDataReceived(
                        unitTag,
                        data.foodRemain or 0,
                        data.apRemain or 0,
                        data.xpRemain or 0
                    )
                end
            end)
            if not ok then
                if logger then
                    logger:Error(string.format("Error processing consumable data from %s: %s",
                        tostring(unitTag), tostring(innerErr)))
                end
            end
        end)

        BeltalowdaNetwork.consumableProtocol:Finalize({
            isRelevantInCombat = false,
            replaceQueuedMessages = true,
        })

        if logger then
            logger:Info("Registered for consumable state broadcasts via protocol 228")
        end
    end)

    if not success then
        d("[Beltalowda] ERROR subscribing to consumable state: " .. tostring(err))
        if logger then
            logger:Error("Error subscribing to consumable state", tostring(err))
        end
    end
end

--[[
    Broadcast consumable state to the group.
    Called by ConsumableTracker when local state changes or periodically.
    @param foodRemain: Food/drink remaining in 10s units (0-1440)
    @param apRemain: AP buff remaining in 10s units (0-1440)
    @param xpRemain: XP buff remaining in 10s units (0-1440)
]]
function BeltalowdaNetwork.BroadcastConsumableState(foodRemain, apRemain, xpRemain)
    if not BeltalowdaNetwork.consumableProtocol then return end

    local groupSize = GetGroupSize()
    if groupSize == 0 then return end

    local safeFood = math.max(0, math.min(1440, math.floor(foodRemain or 0)))
    local safeAP = math.max(0, math.min(1440, math.floor(apRemain or 0)))
    local safeXP = math.max(0, math.min(1440, math.floor(xpRemain or 0)))

    local success, err = pcall(function()
        BeltalowdaNetwork.consumableProtocol:Send({
            foodRemain = safeFood,
            apRemain = safeAP,
            xpRemain = safeXP,
        })
    end)

    if success then
        if logger then
            logger:Debug("Consumable state broadcast sent",
                string.format("food=%d ap=%d xp=%d", safeFood, safeAP, safeXP))
        end
    else
        if logger then
            logger:Error("Error broadcasting consumable state", tostring(err))
        end
    end
end

-- ============================================================================
-- Fight Totals Protocol (ID 229)
-- Three NumericFields carrying accumulated fight totals (in kilo-units)
-- for damage, healing, and shield output.
-- isRelevantInCombat = true: fight totals update during combat.
-- replaceQueuedMessages = true: latest values supersede previous.
-- ============================================================================

function BeltalowdaNetwork.SubscribeToFightTotals()
    if BeltalowdaNetwork.fightTotalsProtocol then
        return
    end

    local LGB = GetLibGroupBroadcast()
    if not LGB then
        d("[Beltalowda] WARNING: LibGroupBroadcast not available for fight totals")
        return
    end

    if not BeltalowdaNetwork.lgbHandler then
        d("[Beltalowda] WARNING: LGB handler not registered yet for fight totals")
        return
    end

    local success, err = pcall(function()
        BeltalowdaNetwork.fightTotalsProtocol = BeltalowdaNetwork.lgbHandler:DeclareProtocol(
            BeltalowdaNetwork.MESSAGE_IDS.FIGHT_TOTALS,
            "BeltalowdaFightTotals"
        )

        -- Three numeric fields, each carrying accumulated total / 1000.
        -- maxValue 2097151 (2^21 - 1) supports ~2.1 billion raw damage/healing
        -- which far exceeds any realistic PvP fight total.
        BeltalowdaNetwork.fightTotalsProtocol:AddField(
            LGB.CreateNumericField("damage", {minValue = 0, maxValue = 2097151, trimValues = true})
        )
        BeltalowdaNetwork.fightTotalsProtocol:AddField(
            LGB.CreateNumericField("healing", {minValue = 0, maxValue = 2097151, trimValues = true})
        )
        BeltalowdaNetwork.fightTotalsProtocol:AddField(
            LGB.CreateNumericField("shielding", {minValue = 0, maxValue = 2097151, trimValues = true})
        )

        BeltalowdaNetwork.fightTotalsProtocol:OnData(function(unitTag, data)
            local ok, innerErr = pcall(function()
                if not data then
                    if logger then
                        logger:Warn(string.format("Received malformed fight totals from %s", tostring(unitTag)))
                    end
                    return
                end

                BeltalowdaNetwork.OnFightTotalsReceived(unitTag, data)
            end)
            if not ok then
                if logger then
                    logger:Error(string.format("Error processing fight totals from %s: %s",
                        tostring(unitTag), tostring(innerErr)))
                end
            end
        end)

        BeltalowdaNetwork.fightTotalsProtocol:Finalize({
            isRelevantInCombat = true,
            replaceQueuedMessages = true,
        })

        if logger then
            logger:Info("Registered for fight totals broadcasts via protocol 229")
        end
    end)

    if not success then
        d("[Beltalowda] ERROR subscribing to fight totals: " .. tostring(err))
        if logger then
            logger:Error("Error subscribing to fight totals", tostring(err))
        end
    end
end

--[[
    Handle received fight totals from a group member.
    Stores data in groupData and notifies UI modules.
    Values are in kilo-units (raw / 1000).
    @param unitTag  string  ESO unit tag
    @param data     table   { damage, healing, shielding } in kilo-units
]]
function BeltalowdaNetwork.OnFightTotalsReceived(unitTag, data)
    if not unitTag or not data then return end

    -- Normalize unitTag: convert "player" to group tag for consistency
    local tag = unitTag
    if unitTag == "player" then
        local groupSize = GetGroupSize()
        if groupSize > 0 then
            for i = 1, groupSize do
                local groupTag = GetGroupUnitTagByIndex(i)
                if GetUnitName(groupTag) == GetUnitName("player") then
                    tag = groupTag
                    break
                end
            end
        end
    end

    BeltalowdaNetwork.groupData[tag] = BeltalowdaNetwork.groupData[tag] or {}
    BeltalowdaNetwork.groupData[tag].fightTotals = {
        damage = (data.damage or 0) * 1000,
        healing = (data.healing or 0) * 1000,
        shielding = (data.shielding or 0) * 1000,
    }

    -- Notify UI modules
    local GFTM = Beltalowda.UI and Beltalowda.UI.GroupFightTotalsMeter
    if GFTM and GFTM.OnFightTotalsChanged then
        GFTM.OnFightTotalsChanged(tag)
    end
end

--[[
    Broadcast fight totals to the group.
    Called by FightTotals data module's broadcast loop.
    @param damage    number  Total damage / 1000
    @param healing   number  Total healing / 1000
    @param shielding number  Total shielding / 1000
]]
function BeltalowdaNetwork.BroadcastFightTotals(damage, healing, shielding)
    if not BeltalowdaNetwork.fightTotalsProtocol then return end

    local groupSize = GetGroupSize()
    if groupSize == 0 then return end

    local safeDmg = math.max(0, math.min(2097151, math.floor(damage or 0)))
    local safeHeal = math.max(0, math.min(2097151, math.floor(healing or 0)))
    local safeShield = math.max(0, math.min(2097151, math.floor(shielding or 0)))

    local success, err = pcall(function()
        BeltalowdaNetwork.fightTotalsProtocol:Send({
            damage = safeDmg,
            healing = safeHeal,
            shielding = safeShield,
        })
    end)

    if success then
        if logger then
            logger:Debug("Fight totals broadcast sent",
                string.format("dmg=%d heal=%d shield=%d", safeDmg, safeHeal, safeShield))
        end
    else
        if logger then
            logger:Error("Error broadcasting fight totals", tostring(err))
        end
    end
end

