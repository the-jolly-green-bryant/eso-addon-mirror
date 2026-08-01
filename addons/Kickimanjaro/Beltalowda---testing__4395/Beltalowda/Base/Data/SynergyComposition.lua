-- Beltalowda Synergy Composition
-- Scans local player's skill bars and gear for synergy-providing abilities,
-- broadcasts a compact bitmask via LGB protocol 225, and aggregates group-wide
-- detected synergies. Used by dynamic synergy tracking mode.

Beltalowda = Beltalowda or {}
Beltalowda.Data = Beltalowda.Data or {}
Beltalowda.Data.SynergyComposition = Beltalowda.Data.SynergyComposition or {}

local SC = Beltalowda.Data.SynergyComposition
local ST = Beltalowda.Data.SynergyTracker

-- ============================================================================
-- Constants
-- ============================================================================

-- Maximum number of synergy bits in the bitmask (24 bits = 3 bytes)
SC.MAX_SYNERGY_BITS = 24
SC.MAX_BITMASK_VALUE = 16777215  -- 2^24 - 1

-- ============================================================================
-- State
-- ============================================================================

SC.initialized = false
SC.logger = nil

-- Local player's synergy bitmask (what synergies we provide)
SC.localBitmask = 0
SC.previousLocalBitmask = -1  -- Force initial broadcast

-- Group composition data: compositionData[displayName] = bitmask
-- Keyed by display name (not unit tag) so data survives unit tag reshuffles
-- when group members join or leave.
SC.compositionData = {}

-- Aggregated group synergy bitmask (bitwise OR of all members)
SC.groupSynergyBitmask = 0

-- Local player's Combustion/Shards sub-type tracking (synergy ID 1)
-- Tracks which variant(s) the local player has slotted
SC.localSynergy1Variants = { orb = false, shards = false }
-- Cached icon paths for each variant (populated at scan time)
SC.synergy1IconCache = { orb = nil, shards = nil }

-- Callback name for change notifications
SC.CALLBACK_NAME = "BeltalowdaSynergyCompositionChanged"

-- ============================================================================
-- Bitmask Helpers
-- ============================================================================

--[[
    Set a bit in the bitmask for a given synergy ID.
    Synergy IDs map to bit positions (1-based).
    @param bitmask: Current bitmask
    @param synergyId: Synergy ID (1-24)
    @return: Updated bitmask
]]--
function SC.SetBit(bitmask, synergyId)
    if synergyId < 1 or synergyId > SC.MAX_SYNERGY_BITS then return bitmask end
    local bitPosition = synergyId - 1  -- 0-based bit position
    local bitValue = 2 ^ bitPosition
    -- Set the bit using bitwise OR via arithmetic
    if SC.TestBit(bitmask, synergyId) then
        return bitmask  -- Already set
    end
    return bitmask + bitValue
end

--[[
    Test if a bit is set in the bitmask for a given synergy ID.
    @param bitmask: Bitmask to test
    @param synergyId: Synergy ID (1-24)
    @return: boolean
]]--
function SC.TestBit(bitmask, synergyId)
    if synergyId < 1 or synergyId > SC.MAX_SYNERGY_BITS then return false end
    local bitPosition = synergyId - 1
    local bitValue = 2 ^ bitPosition
    return math.floor(bitmask / bitValue) % 2 == 1
end

-- ============================================================================
-- Local Player Scanning
-- ============================================================================

--[[
    Scan the local player's skill bars and gear to build a synergy bitmask.
    Checks action bar slots 3-8 on both bars (hotbar 0 and 1) for slotted abilities
    that provide synergies, and scans equipped sets via LibSetDetection.
    
    If the bitmask changed, broadcasts via protocol 225.
]]--
function SC.ScanLocalPlayer()
    local newBitmask = 0
    
    -- Reset synergy 1 variant tracking
    SC.localSynergy1Variants = { orb = false, shards = false }

    -- Scan action bars: slots 3-8 on both hotbar 0 (front) and hotbar 1 (back)
    -- Slot indices: 3-8 are the ability slots (1-2 are weapons, ultimates are separate)
    for hotbar = 0, 1 do
        for slot = 3, 8 do
            local abilityId = GetSlotBoundId(slot, hotbar)
            if abilityId and abilityId > 0 then
                -- Fast path: direct ID lookup
                local synergyId = ST.SYNERGY_PROVIDERS[abilityId]

                -- Fallback: name-based lookup (handles rank-specific IDs and ID drift)
                if not synergyId then
                    local abilityName = GetAbilityName(abilityId)
                    if abilityName and abilityName ~= "" then
                        synergyId = ST.SYNERGY_PROVIDER_NAMES[abilityName]
                        if synergyId then
                            -- Cache for future lookups so we don't call GetAbilityName again
                            ST.SYNERGY_PROVIDERS[abilityId] = synergyId
                            if SC.logger then
                                SC.logger:Debug("Name fallback matched",
                                    string.format("abilityId=%d name=%s synergyId=%d", abilityId, abilityName, synergyId))
                            end
                        end
                    end
                end

                if synergyId then
                    newBitmask = SC.SetBit(newBitmask, synergyId)
                    
                    -- Track Combustion/Shards sub-type for synergy 1
                    if synergyId == 1 then
                        local subtype = ST.SYNERGY1_PROVIDER_SUBTYPE[abilityId]
                        if not subtype then
                            -- Fallback: name-based sub-type lookup
                            local name = GetAbilityName(abilityId)
                            if name then
                                subtype = ST.SYNERGY1_PROVIDER_NAME_SUBTYPE[name]
                            end
                        end
                        if subtype then
                            SC.localSynergy1Variants[subtype] = true
                            -- Cache the icon path for this variant
                            local baseAbilityId = ST.SYNERGY1_BASE_ABILITY[subtype]
                            if baseAbilityId then
                                SC.synergy1IconCache[subtype] = GetAbilityIcon(baseAbilityId)
                            end
                        end
                    end
                end
            end
        end
    end

    -- Scan equipped sets via LibSetDetection
    if LibSetDetection and LibSetDetection.GetUnitSetData then
        local setData = LibSetDetection.GetUnitSetData("player")
        if setData then
            -- setData is keyed by setId: {[setId] = {numEquip={body,front,back}, maxEquip=n, ...}}
            for setId, setEntry in pairs(setData) do
                if type(setId) == "number" and ST.SET_SYNERGY_PROVIDERS[setId] then
                    -- Compute effective piece count: body + max(front, back)
                    local numEquip = setEntry.numEquip
                    if numEquip then
                        local bodyCount = numEquip.body or 0
                        local frontCount = numEquip.front or 0
                        local backCount = numEquip.back or 0
                        local pieces = bodyCount + math.max(frontCount, backCount)
                        local required = setEntry.maxEquip or 5
                        if pieces >= required then
                            newBitmask = SC.SetBit(newBitmask, ST.SET_SYNERGY_PROVIDERS[setId])
                        end
                    end
                end
            end
        end
    end

    -- Check if bitmask changed
    if newBitmask ~= SC.previousLocalBitmask then
        SC.localBitmask = newBitmask
        SC.previousLocalBitmask = newBitmask

        if SC.logger then
            SC.logger:Debug("Local synergy bitmask changed",
                string.format("bitmask=%d, synergies=%s", newBitmask, SC.BitmaskToString(newBitmask)))
        end

        -- Store our own data in the composition table (keyed by display name)
        local playerName = GetUnitName("player")
        if playerName and playerName ~= "" then
            SC.compositionData[playerName] = newBitmask
        end

        -- Broadcast to group
        local BeltalowdaNetwork = Beltalowda.network
        if BeltalowdaNetwork and BeltalowdaNetwork.BroadcastSynergyComposition then
            BeltalowdaNetwork.BroadcastSynergyComposition(newBitmask)
        end

        -- Re-aggregate and fire change event
        SC.AggregateGroupBitmask()
    end
end

-- ============================================================================
-- Group Aggregation
-- ============================================================================

--[[
    Aggregate all group members' bitmasks into a single group bitmask.
    Fires GROUP_SYNERGY_COMPOSITION_CHANGED callback if the result changed.
]]--
function SC.AggregateGroupBitmask()
    local newGroupBitmask = 0

    for _, bitmask in pairs(SC.compositionData) do
        -- Bitwise OR via arithmetic: for each bit position, set it if either has it
        for synergyId = 1, SC.MAX_SYNERGY_BITS do
            if SC.TestBit(bitmask, synergyId) and not SC.TestBit(newGroupBitmask, synergyId) then
                newGroupBitmask = SC.SetBit(newGroupBitmask, synergyId)
            end
        end
    end

    if newGroupBitmask ~= SC.groupSynergyBitmask then
        local oldBitmask = SC.groupSynergyBitmask
        SC.groupSynergyBitmask = newGroupBitmask

        if SC.logger then
            SC.logger:Info("Group synergy bitmask changed",
                string.format("old=%d, new=%d, synergies=%s", oldBitmask, newGroupBitmask, SC.BitmaskToString(newGroupBitmask)))
        end

        -- Fire change callback
        SC.FireChangeEvent()
    end
end

--[[
    Fire the GROUP_SYNERGY_COMPOSITION_CHANGED callback.
    UI modules and Composition listen for this to update displays.
]]--
function SC.FireChangeEvent()
    if CALLBACK_MANAGER then
        CALLBACK_MANAGER:FireCallbacks(SC.CALLBACK_NAME, SC.groupSynergyBitmask)
    end
end

-- ============================================================================
-- Network Receive Handler
-- ============================================================================

--[[
    Called when we receive a synergy composition bitmask from a group member.
    @param unitTag: Sender's unit tag
    @param bitmask: Their synergy bitmask (0 to 2^24 - 1)
]]--
function SC.OnSynergyCompositionReceived(unitTag, bitmask)
    if not unitTag or not bitmask then return end

    -- Key by display name so data survives unit tag reshuffles
    local name = GetUnitName(unitTag)
    if not name or name == "" then return end

    SC.compositionData[name] = bitmask

    if SC.logger then
        SC.logger:Debug("Synergy composition received",
            string.format("from=%s (%s), bitmask=%d, synergies=%s",
                name, unitTag, bitmask, SC.BitmaskToString(bitmask)))
    end

    -- Re-aggregate
    SC.AggregateGroupBitmask()
end

-- ============================================================================
-- Group Membership Cleanup
-- ============================================================================

--[[
    Remove a departing member's synergy composition data and re-aggregate.
    @param unitTag: Unit tag of the departed member (may already be invalid)
    @param characterName: Character name of the departed member
]]--
function SC.OnGroupMemberLeft(unitTag, characterName)
    local removed = false

    -- compositionData is keyed by display name.
    -- Strip any ^Mx gender suffix from the event's characterName.
    if characterName then
        local cleanName = zo_strformat("<<1>>", characterName)
        if SC.compositionData[cleanName] then
            SC.compositionData[cleanName] = nil
            removed = true
        end
        -- Also try the raw characterName in case it was stored without formatting
        if SC.compositionData[characterName] then
            SC.compositionData[characterName] = nil
            removed = true
        end
    end

    -- Fallback: remove any entries whose names are no longer in the group.
    -- This catches edge cases where the name format didn't match.
    if not removed then
        local groupNames = {}
        local groupSize = GetGroupSize()
        for i = 1, groupSize do
            local tag = GetGroupUnitTagByIndex(i)
            if tag then
                local name = GetUnitName(tag)
                if name and name ~= "" then
                    groupNames[name] = true
                end
            end
        end
        -- Also keep our own name (in case we're solo after last member left)
        local myName = GetUnitName("player")
        if myName and myName ~= "" then
            groupNames[myName] = true
        end

        for name, _ in pairs(SC.compositionData) do
            if not groupNames[name] then
                SC.compositionData[name] = nil
                removed = true
            end
        end
    end

    if removed then
        if SC.logger then
            SC.logger:Debug("Removed synergy composition data for departed member",
                tostring(characterName or unitTag))
        end
        SC.AggregateGroupBitmask()
    end
end

-- ============================================================================
-- Public API
-- ============================================================================

--[[
    Check if a specific synergy is present in the group composition.
    @param synergyId: Synergy ID (1-24)
    @return: boolean
]]--
function SC.IsGroupSynergyPresent(synergyId)
    return SC.TestBit(SC.groupSynergyBitmask, synergyId)
end

--[[
    Get list of all synergy IDs present in the group.
    @return: Array of synergy IDs
]]--
function SC.GetGroupSynergyList()
    local result = {}
    for synergyId = 1, SC.MAX_SYNERGY_BITS do
        if SC.TestBit(SC.groupSynergyBitmask, synergyId) then
            -- Only include if it's a defined synergy
            if ST.SYNERGIES[synergyId] then
                table.insert(result, synergyId)
            end
        end
    end
    return result
end

--[[
    Get list of synergy IDs that a specific player provides.
    @param unitTag: Player's unit tag
    @return: Array of synergy IDs
]]--
function SC.GetPlayerSynergies(unitTag)
    -- compositionData is keyed by display name, not unit tag
    local name = GetUnitName(unitTag)
    local bitmask = name and SC.compositionData[name]
    if not bitmask then return {} end

    local result = {}
    for synergyId = 1, SC.MAX_SYNERGY_BITS do
        if SC.TestBit(bitmask, synergyId) then
            if ST.SYNERGIES[synergyId] then
                table.insert(result, synergyId)
            end
        end
    end
    return result
end

--[[
    Get list of player names that provide a specific synergy.
    @param synergyId: Synergy ID (1-24)
    @return: Array of player display names (sorted alphabetically)
]]--
function SC.GetProvidersForSynergy(synergyId)
    local providers = {}
    for name, bitmask in pairs(SC.compositionData) do
        if SC.TestBit(bitmask, synergyId) then
            table.insert(providers, name)
        end
    end
    table.sort(providers)
    return providers
end

--[[
    Get the group synergy bitmask.
    @return: Integer bitmask
]]--
function SC.GetGroupBitmask()
    return SC.groupSynergyBitmask
end

--[[
    Get the local player's synergy bitmask.
    @return: Integer bitmask
]]--
function SC.GetLocalBitmask()
    return SC.localBitmask
end

-- ============================================================================
-- Utility
-- ============================================================================

--[[
    Convert a bitmask to a human-readable string of synergy names.
    @param bitmask: Integer bitmask
    @return: Comma-separated string of synergy names
]]--
function SC.BitmaskToString(bitmask)
    local names = {}
    for synergyId = 1, SC.MAX_SYNERGY_BITS do
        if SC.TestBit(bitmask, synergyId) then
            local synergy = ST.SYNERGIES[synergyId]
            if synergy then
                table.insert(names, synergy.name)
            else
                table.insert(names, "#" .. synergyId)
            end
        end
    end
    if #names == 0 then return "(none)" end
    return table.concat(names, ", ")
end

--[[
    Get the local player's group unit tag.
    @return: Unit tag string or nil
]]--
function SC.GetPlayerGroupTag()
    local groupSize = GetGroupSize()
    if groupSize == 0 then return "player" end

    for i = 1, groupSize do
        local tag = GetGroupUnitTagByIndex(i)
        if tag and GetUnitName(tag) == GetUnitName("player") then
            return tag
        end
    end
    return "player"
end

-- ============================================================================
-- Event Handlers
-- ============================================================================

--[[
    Handle action bar slot changes (skill swaps).
]]--
function SC.OnActionSlotUpdated(eventCode, slotIndex)
    -- Debounce: delay scan to batch multiple slot updates
    EVENT_MANAGER:UnregisterForUpdate("BeltalowdaSynergyCompositionScan")
    EVENT_MANAGER:RegisterForUpdate("BeltalowdaSynergyCompositionScan", 500, function()
        EVENT_MANAGER:UnregisterForUpdate("BeltalowdaSynergyCompositionScan")
        SC.ScanLocalPlayer()
    end)
end

--[[
    Handle full action bar update.
]]--
function SC.OnActionSlotsFullUpdate(eventCode)
    -- Debounce: delay scan
    EVENT_MANAGER:UnregisterForUpdate("BeltalowdaSynergyCompositionScan")
    EVENT_MANAGER:RegisterForUpdate("BeltalowdaSynergyCompositionScan", 500, function()
        EVENT_MANAGER:UnregisterForUpdate("BeltalowdaSynergyCompositionScan")
        SC.ScanLocalPlayer()
    end)
end

-- ============================================================================
-- Debug Commands
-- ============================================================================

--[[
    Dump all ability IDs and names on the player's action bars (slots 3-8).
    Used to verify what IDs GetSlotBoundId() actually returns in-game.
]]--
function SC.DebugBars()
    d("=== Beltalowda: Action Bar Ability IDs ===")
    local barNames = {[0] = "Front Bar", [1] = "Back Bar"}
    for hotbar = 0, 1 do
        d("|cFFFF00" .. barNames[hotbar] .. "|r")
        for slot = 3, 8 do
            local abilityId = GetSlotBoundId(slot, hotbar)
            if abilityId and abilityId > 0 then
                local name = GetAbilityName(abilityId) or "???"
                local provider = ST.SYNERGY_PROVIDERS[abilityId]
                local nameFallback = ST.SYNERGY_PROVIDER_NAMES[name]
                local status = ""
                if provider then
                    local synergy = ST.SYNERGIES[provider]
                    status = string.format(" |c00FF00→ %s (ID lookup)|r", synergy and synergy.name or tostring(provider))
                elseif nameFallback then
                    local synergy = ST.SYNERGIES[nameFallback]
                    status = string.format(" |cFFAA00→ %s (name fallback)|r", synergy and synergy.name or tostring(nameFallback))
                end
                d(string.format("  Slot %d: [%d] %s%s", slot, abilityId, name, status))
            else
                d(string.format("  Slot %d: (empty)", slot))
            end
        end
    end
end

--[[
    Validate all entries in SYNERGY_PROVIDERS by checking if GetAbilityName()
    returns a valid name for each ID. Flags entries that may be stale.
]]--
function SC.DebugProviders()
    d("=== Beltalowda: Synergy Provider ID Validation ===")
    local valid, invalid = 0, 0
    for abilityId, synergyId in pairs(ST.SYNERGY_PROVIDERS) do
        local name = GetAbilityName(abilityId)
        local synergy = ST.SYNERGIES[synergyId]
        local synergyName = synergy and synergy.name or tostring(synergyId)
        if name and name ~= "" then
            d(string.format("  |c00FF00OK|r [%d] %s → %s", abilityId, name, synergyName))
            valid = valid + 1
        else
            d(string.format("  |cFF0000BAD|r [%d] ??? → %s (name not found, ID may be wrong)", abilityId, synergyName))
            invalid = invalid + 1
        end
    end
    d(string.format("Summary: %d valid, %d invalid out of %d entries", valid, invalid, valid + invalid))
end

--[[
    Show the current local synergy composition bitmask and aggregated group data.
]]--
function SC.DebugComposition()
    d("=== Beltalowda: Synergy Composition ===")
    d(string.format("Local bitmask: %d (%s)", SC.localBitmask or 0, SC.BitmaskToString(SC.localBitmask or 0)))
    d(string.format("Group bitmask: %d (%s)", SC.groupSynergyBitmask or 0, SC.BitmaskToString(SC.groupSynergyBitmask or 0)))
    d("")
    d("Per-member data:")
    local memberCount = 0
    for name, bitmask in pairs(SC.compositionData) do
        d(string.format("  %s: %d (%s)", name, bitmask, SC.BitmaskToString(bitmask)))
        memberCount = memberCount + 1
    end
    if memberCount == 0 then
        d("  (no data)")
    end
end

-- ============================================================================
-- Initialization
-- ============================================================================

--[[
    Initialize synergy composition tracking.
    Registers for skill bar and gear change events.
    Runs initial scan with a delay to let game data settle.
]]--
function SC.Initialize()
    if SC.initialized then return end

    -- Create logger
    if Beltalowda.Logger and Beltalowda.Logger.CreateModuleLogger then
        SC.logger = Beltalowda.Logger.CreateModuleLogger("SynergyComp")
    end

    -- Register for action bar changes
    EVENT_MANAGER:RegisterForEvent(
        "BeltalowdaSynergyComp_SlotUpdate",
        EVENT_ACTION_SLOT_UPDATED,
        SC.OnActionSlotUpdated
    )
    EVENT_MANAGER:RegisterForEvent(
        "BeltalowdaSynergyComp_SlotsFullUpdate",
        EVENT_ACTION_SLOTS_FULL_UPDATE,
        SC.OnActionSlotsFullUpdate
    )

    -- Register for LibSetDetection gear changes (for set synergies)
    if LibSetDetection and LibSetDetection.RegisterEvent and LSD_EVENT_DATA_UPDATE then
        LibSetDetection.RegisterEvent(
            LSD_EVENT_DATA_UPDATE,
            "BeltalowdaSynergyComp_GearUpdate",
            function(unitTag)
                -- Only rescan if it's the local player's gear that changed
                if unitTag == "player" or GetUnitName(unitTag) == GetUnitName("player") then
                    -- Debounce
                    EVENT_MANAGER:UnregisterForUpdate("BeltalowdaSynergyCompositionScan")
                    EVENT_MANAGER:RegisterForUpdate("BeltalowdaSynergyCompositionScan", 500, function()
                        EVENT_MANAGER:UnregisterForUpdate("BeltalowdaSynergyCompositionScan")
                        SC.ScanLocalPlayer()
                    end)
                end
            end,
            LSD_UNIT_TYPE_PLAYER
        )
    end

    -- Register for group membership changes
    EVENT_MANAGER:RegisterForEvent(
        "BeltalowdaSynergyComp_GroupJoined",
        EVENT_GROUP_MEMBER_JOINED,
        function(eventCode)
            -- New member joined - rescan and broadcast so they get our data
            zo_callLater(function()
                SC.previousLocalBitmask = -1  -- Force re-broadcast
                SC.ScanLocalPlayer()
            end, 1500)
        end
    )

    EVENT_MANAGER:RegisterForEvent(
        "BeltalowdaSynergyComp_GroupLeft",
        EVENT_GROUP_MEMBER_LEFT,
        function(eventCode, characterName, reason, wasLocalPlayer)
            if wasLocalPlayer then
                -- We left the group, clear all composition data
                SC.compositionData = {}
                SC.groupSynergyBitmask = 0
                SC.FireChangeEvent()
            else
                SC.OnGroupMemberLeft(nil, characterName)
            end
        end
    )

    -- Register debug slash command
    SLASH_COMMANDS["/btlwdebug"] = function(args)
        local cmd = string.match(args or "", "^(%S+)")
        if cmd == "bars" then
            SC.DebugBars()
        elseif cmd == "providers" then
            SC.DebugProviders()
        elseif cmd == "composition" or cmd == "comp" then
            SC.DebugComposition()
        else
            d("|cFFFF00/btlwdebug bars|r - Dump action bar ability IDs and names")
            d("|cFFFF00/btlwdebug providers|r - Validate SYNERGY_PROVIDERS IDs")
            d("|cFFFF00/btlwdebug comp|r - Show synergy composition data")
        end
    end

    -- Initial scan with delay to let game data settle
    zo_callLater(function()
        SC.ScanLocalPlayer()
    end, 2000)

    -- Validate provider IDs at init (log warnings for stale entries)
    zo_callLater(function()
        local invalid = 0
        for abilityId, synergyId in pairs(ST.SYNERGY_PROVIDERS) do
            local name = GetAbilityName(abilityId)
            if not name or name == "" then
                invalid = invalid + 1
                if SC.logger then
                    local synergy = ST.SYNERGIES[synergyId]
                    SC.logger:Debug("Invalid provider ID",
                        string.format("abilityId=%d synergyId=%d (%s) - GetAbilityName returned empty",
                            abilityId, synergyId, synergy and synergy.name or "?"))
                end
            end
        end
        if invalid > 0 and SC.logger then
            SC.logger:Debug("Provider validation complete",
                string.format("%d entries have invalid ability IDs (name fallback will handle them)", invalid))
        end
    end, 3000)

    SC.initialized = true
end
