-- Beltalowda Buff Monitor
-- Monitors player and group member buffs for special states
-- Volendrung detection uses multiple known ability IDs

Beltalowda = Beltalowda or {}
Beltalowda.BuffMonitor = {}

local BM = Beltalowda.BuffMonitor

-- Constants
BM.VOLENDRUNG_BUFF_ID = 118500        -- Original known Volendrung buff seen in Cheesemonger's
BM.VOLENDRUNG_BUFF_ID_ALT = 116598    -- Actual known Volendrung buff seen when picking up the hammer in Cyrodiil
BM.RUINOUS_CYCLONE_ID = 116096        -- Volendrung's ultimate ability (Ruinous Cyclone)

-- Lookup table for all known Volendrung buff IDs
BM.VOLENDRUNG_IDS = {
    [BM.VOLENDRUNG_BUFF_ID] = true,
    [BM.VOLENDRUNG_BUFF_ID_ALT] = true,
}

--[[
    Check whether an ability ID is any known Volendrung buff
    @param abilityId number
    @return boolean
]]--
function BM.IsVolendrungId(abilityId)
    return BM.VOLENDRUNG_IDS[abilityId] == true
end

-- Buff state storage: [unitTag] = { buffId = buffData }
BM.buffStates = {}

-- Volendrung state callbacks
BM.volendrungCallbacks = {}

--[[
    Initialize the Buff Monitor
]]--
function BM.Initialize()
    BM.RegisterForEvents()
    
    -- Set up periodic scanning as a failsafe (every 2 seconds)
    -- This ensures we catch Volendrung even if events are missed
    EVENT_MANAGER:RegisterForUpdate("BeltalowdaBuffMonitorScan", 2000, function()
        BM.ScanPlayerBuffs()
    end)
    
    return true
end

--[[
    Register for buff-related events
]]--
function BM.RegisterForEvents()
    -- Monitor effect changes for player and group members
    EVENT_MANAGER:RegisterForEvent("BeltalowdaBuffMonitor", EVENT_EFFECT_CHANGED, function(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
        BM.OnEffectChanged(changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    end)
    
    -- Don't add unitTag filter - we want to monitor all units (player and group members)
    -- The handler will check if events are relevant
    
    -- Force immediate rescan on zone change (EVENT_PLAYER_ACTIVATED fires after every loading screen)
    -- Critical for Volendrung: when leaving a zone where the player had the hammer,
    -- EVENT_EFFECT_CHANGED FADED may not fire — the buff silently disappears on zone.
    -- Without this, stale Volendrung state persists until the 2s periodic scan catches it.
    EVENT_MANAGER:RegisterForEvent("BeltalowdaBuffMonitor", EVENT_PLAYER_ACTIVATED, function()
        -- Clear ALL buff states first — any data from the previous zone is stale.
        -- ScanPlayerBuffs alone is not enough because BM.HasVolendrung() returns
        -- true from stale buffStates before the scan finishes clearing them.
        BM.buffStates = {}
        BM.ScanPlayerBuffs()
    end)

    -- Monitor group changes to trigger rescans
    EVENT_MANAGER:RegisterForEvent("BeltalowdaBuffMonitor", EVENT_GROUP_MEMBER_JOINED, function(eventCode, memberCharacterName)
        BM.UpdateGroupFilters()
    end)
    
    EVENT_MANAGER:RegisterForEvent("BeltalowdaBuffMonitor", EVENT_GROUP_MEMBER_LEFT, function(eventCode, memberCharacterName, reason, isLocalPlayer, isLeader, memberDisplayName, actionRequiredVote)
        BM.UpdateGroupFilters()
        -- Clear buff state for departed member
        BM.ClearBuffStateForCharacter(memberCharacterName)
    end)
    
    -- Initial scan of player buffs
    zo_callLater(function()
        BM.ScanPlayerBuffs()
    end, 1000)  -- Delay to ensure everything is loaded
end

--[[
    Update event filters for all group members
]]--
function BM.UpdateGroupFilters()
    -- Note: EVENT_EFFECT_CHANGED doesn't support multiple filters efficiently
    -- We'll use unitTag checking in the handler instead
    -- This is called to trigger a rescan when group changes
    zo_callLater(function()
        BM.ScanAllGroupBuffs()
    end, 500)
end

--[[
    Handle effect changed event
]]--
-- TEMP DEBUG: log all effect gains/losses on the player to chat
-- Toggle with /bmdebug  (or /script Beltalowda.BuffMonitor.debugEffects = true/false)
-- Dump all current buffs with /bmscan
BM.debugEffects = false

-- Register debug slash commands
SLASH_COMMANDS["/bmdebug"] = function()
    BM.debugEffects = not BM.debugEffects
    d("|cFFAA00[BM DEBUG]|r Effect change logging " .. (BM.debugEffects and "|c00FF00ON|r" or "|cFF0000OFF|r"))
end

SLASH_COMMANDS["/bmscan"] = function()
    d("|cFFAA00[BM DEBUG]|r === Full buff scan on player ===")
    local numBuffs = GetNumBuffs("player")
    d("|cFFAA00[BM DEBUG]|r Total effects: " .. tostring(numBuffs))
    for i = 1, numBuffs do
        local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename,
              buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff,
              castByPlayer = GetUnitBuffInfo("player", i)
        d(string.format("  [%d] id=%d  name=\"%s\"  buffType=%s  effectType=%s  abilityType=%s  stacks=%d  icon=%s",
            i, abilityId, buffName or "?",
            tostring(buffType), tostring(effectType), tostring(abilityType),
            stackCount or 0, tostring(iconFilename)))
    end
    d("|cFFAA00[BM DEBUG]|r === End scan ===")
end

-- DEBUG: Scan active effects for Mundus Stones (Boon buffs) and dump their ability IDs
-- Usage: /bmundus [unitTag]  (defaults to "player", or use e.g. /bmundus group1)
SLASH_COMMANDS["/bmundus"] = function(args)
    local unitTag = (args and args ~= "") and args or "player"
    d("|cFFAA00[MUNDUS DEBUG]|r Scanning " .. unitTag .. " for Mundus Stones...")
    local numBuffs = GetNumBuffs(unitTag)
    local found = 0
    for i = 1, numBuffs do
        local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename,
              buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff,
              castByPlayer = GetUnitBuffInfo(unitTag, i)
        if buffName and (string.find(buffName, "Boon") or string.find(buffName, "boon")
                      or string.find(buffName, "Segen") or string.find(buffName, "diction")) then
            found = found + 1
            d(string.format("|c00FF00  MUNDUS #%d|r  abilityId=|cFFFF00%d|r  name=\"%s\"  icon=%s",
                found, abilityId, buffName, tostring(iconFilename)))
        end
    end
    if found == 0 then
        d("|cFFAA00[MUNDUS DEBUG]|r No Mundus Stones found. Dumping ALL " .. numBuffs .. " effects:")
        for i = 1, numBuffs do
            local buffName, _, _, _, _, iconFilename, buffType, effectType, abilityType,
                  statusEffectType, abilityId = GetUnitBuffInfo(unitTag, i)
            d(string.format("  [%d] id=%d  name=\"%s\"  icon=%s", i, abilityId, buffName or "?", tostring(iconFilename)))
        end
    end
    d("|cFFAA00[MUNDUS DEBUG]|r Done. Found " .. found .. " Mundus Stone(s).")
end

-- TEMP DEBUG: Scan action bars and dump ability + scribing info
-- Usage: /bbscan
SLASH_COMMANDS["/bbscan"] = function()
    local barNames = {
        [HOTBAR_CATEGORY_PRIMARY]   = "Front Bar",
        [HOTBAR_CATEGORY_BACKUP]    = "Back Bar",
    }

    -- Helper: safely call a global function and return results or nil
    local function tryCall(funcName, ...)
        local fn = _G[funcName]
        if fn then
            local ok, r1, r2, r3, r4, r5 = pcall(fn, ...)
            if ok then return r1, r2, r3, r4, r5 end
        end
        return nil
    end

    for _, hotbarCategory in ipairs({HOTBAR_CATEGORY_PRIMARY, HOTBAR_CATEGORY_BACKUP}) do
        local barLabel = barNames[hotbarCategory] or ("Bar " .. tostring(hotbarCategory))
        d("|cFFAA00[BB DEBUG]|r === " .. barLabel .. " ===")

        for slotIndex = ACTION_BAR_FIRST_NORMAL_SLOT_INDEX, ACTION_BAR_ULTIMATE_SLOT_INDEX do
            local slotNum = slotIndex - ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + 1
            local abilityId = GetSlotBoundId(slotIndex, hotbarCategory)
            if abilityId and abilityId > 0 then
                local name = GetAbilityName(abilityId) or "?"
                local icon = GetSlotTexture(slotIndex, hotbarCategory) or "?"
                local isUlt = (slotIndex == ACTION_BAR_ULTIMATE_SLOT_INDEX) and " |cFF8800(ULT)|r" or ""
                local slotName = GetSlotName(slotIndex, hotbarCategory) or "?"

                d(string.format("  [%d]%s id=%d  name=\"%s\"  slotName=\"%s\"",
                    slotNum, isUlt, abilityId, name, slotName))
                d(string.format("        icon=%s", tostring(icon)))

                -- Probe all crafted/scribed ability APIs with this ID
                local isCrafted1 = tryCall("IsAbilityCraftedAbility", abilityId)
                local isCrafted2 = tryCall("IsCraftedAbilityId", abilityId)
                d(string.format("        IsAbilityCraftedAbility(%d)=%s  IsCraftedAbilityId(%d)=%s",
                    abilityId, tostring(isCrafted1), abilityId, tostring(isCrafted2)))

                -- Try getting crafted ability ID from the ability, and vice versa
                local craftedFromAbility = tryCall("GetAbilityCraftedAbilityId", abilityId)
                local abilityFromCrafted = tryCall("GetAbilityIdForCraftedAbilityId", abilityId)
                d(string.format("        GetAbilityCraftedAbilityId(%d)=%s  GetAbilityIdForCraftedAbilityId(%d)=%s",
                    abilityId, tostring(craftedFromAbility), abilityId, tostring(abilityFromCrafted)))

                -- Try getting script IDs using the raw ID
                local f1, s1, a1 = tryCall("GetCraftedAbilityActiveScriptIds", abilityId)
                d(string.format("        GetCraftedAbilityActiveScriptIds(%d) => focus=%s sig=%s affix=%s",
                    abilityId, tostring(f1), tostring(s1), tostring(a1)))

                -- If we got a different craftedId, try scripts with that too
                if craftedFromAbility and craftedFromAbility ~= abilityId and craftedFromAbility > 0 then
                    local f2, s2, a2 = tryCall("GetCraftedAbilityActiveScriptIds", craftedFromAbility)
                    d(string.format("        GetCraftedAbilityActiveScriptIds(%d) => focus=%s sig=%s affix=%s",
                        craftedFromAbility, tostring(f2), tostring(s2), tostring(a2)))
                end
                if abilityFromCrafted and abilityFromCrafted ~= abilityId and abilityFromCrafted > 0 then
                    local f3, s3, a3 = tryCall("GetCraftedAbilityActiveScriptIds", abilityFromCrafted)
                    d(string.format("        GetCraftedAbilityActiveScriptIds(%d) => focus=%s sig=%s affix=%s",
                        abilityFromCrafted, tostring(f3), tostring(s3), tostring(a3)))
                end

                -- Also try slot-specific queries
                local slotCraftedId = tryCall("GetSlotCraftedAbilityId", slotIndex, hotbarCategory)
                d(string.format("        GetSlotCraftedAbilityId(slot)=%s", tostring(slotCraftedId)))
                if slotCraftedId and slotCraftedId > 0 then
                    local f4, s4, a4 = tryCall("GetCraftedAbilityActiveScriptIds", slotCraftedId)
                    d(string.format("        GetCraftedAbilityActiveScriptIds(%d) => focus=%s sig=%s affix=%s",
                        slotCraftedId, tostring(f4), tostring(s4), tostring(a4)))
                    -- Try to get script names
                    for label, sid in pairs({Focus = f4, Sig = s4, Affix = a4}) do
                        if sid and sid > 0 then
                            local sname = tryCall("GetCraftedAbilityScriptDisplayName", sid)
                                       or tryCall("GetScriptDisplayName", sid)
                            d(string.format("          %s script id=%d name=\"%s\"", label, sid, tostring(sname)))
                        end
                    end
                end

                -- Print script names for any IDs we found directly
                if f1 and f1 > 0 then
                    local fname = tryCall("GetCraftedAbilityScriptDisplayName", f1)
                               or tryCall("GetScriptDisplayName", f1)
                    d(string.format("        Focus script id=%d name=\"%s\"", f1, tostring(fname)))
                end
                if s1 and s1 > 0 then
                    local sname = tryCall("GetCraftedAbilityScriptDisplayName", s1)
                               or tryCall("GetScriptDisplayName", s1)
                    d(string.format("        Sig script id=%d name=\"%s\"", s1, tostring(sname)))
                end
                if a1 and a1 > 0 then
                    local aname = tryCall("GetCraftedAbilityScriptDisplayName", a1)
                               or tryCall("GetScriptDisplayName", a1)
                    d(string.format("        Affix script id=%d name=\"%s\"", a1, tostring(aname)))
                end
            else
                d(string.format("  [%d] (empty)", slotNum))
            end
        end
    end
    d("|cFFAA00[BB DEBUG]|r === End action bar scan ===")
end

function BM.OnEffectChanged(changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    -- TEMP DEBUG: print effect data to chat for the player unit
    if BM.debugEffects and unitTag == "player" then
        local action = "??"
        if changeType == EFFECT_RESULT_GAINED then action = "|c00FF00GAINED|r"
        elseif changeType == EFFECT_RESULT_FADED then action = "|cFF0000FADED|r"
        elseif changeType == EFFECT_RESULT_UPDATED then action = "|cFFFF00UPDATED|r"
        end
        d(string.format("[BM DEBUG] %s  id=%d  name=\"%s\"  buffType=%s  effectType=%s  abilityType=%s  icon=%s",
            action, abilityId, effectName or "?",
            tostring(buffType), tostring(effectType), tostring(abilityType), tostring(iconName)))
    end

    -- Check if this is Volendrung buff (check BEFORE buffType filter —
    -- Volendrung may not always be classified as BUFF_EFFECT_TYPE_BUFF)
    if BM.IsVolendrungId(abilityId) then
        if changeType == EFFECT_RESULT_GAINED then
            BM.OnVolendrungGained(unitTag, beginTime, endTime)
        elseif changeType == EFFECT_RESULT_FADED then
            BM.OnVolendrungLost(unitTag)
        end
    end
end

--[[
    Handle Volendrung buff gained
]]--
function BM.OnVolendrungGained(unitTag, beginTime, endTime)
    
    -- Store buff state
    BM.buffStates[unitTag] = BM.buffStates[unitTag] or {}
    BM.buffStates[unitTag][BM.VOLENDRUNG_BUFF_ID] = {
        active = true,
        beginTime = beginTime,
        endTime = endTime,
        timestamp = GetTimeStamp()
    }
    
    -- Notify callbacks
    BM.NotifyVolendrungChanged(unitTag, true)
end

--[[
    Handle Volendrung buff lost
]]--
function BM.OnVolendrungLost(unitTag)
    
    -- Clear buff state
    if BM.buffStates[unitTag] and BM.buffStates[unitTag][BM.VOLENDRUNG_BUFF_ID] then
        BM.buffStates[unitTag][BM.VOLENDRUNG_BUFF_ID] = nil
    end
    
    -- Notify callbacks
    BM.NotifyVolendrungChanged(unitTag, false)
end

--[[
    Scan player's current buffs for Volendrung
    Uses GetUnitBuffInfo iteration pattern
]]--
function BM.ScanPlayerBuffs()
    local unitTag = "player"
    local hasVolendrung = false
    
    -- Iterate through all buffs on the player
    local i = 1
    while true do
        local buffName, startTime, endTime, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer = GetUnitBuffInfo(unitTag, i)
        
        if not buffName or buffName == "" then
            break  -- No more buffs
        end
        
        -- Check if this is Volendrung
        if BM.IsVolendrungId(abilityId) then
            hasVolendrung = true
            -- Ensure state is recorded
            if not BM.buffStates[unitTag] or not BM.buffStates[unitTag][BM.VOLENDRUNG_BUFF_ID] or not BM.buffStates[unitTag][BM.VOLENDRUNG_BUFF_ID].active then
                BM.OnVolendrungGained(unitTag, startTime, endTime)
            end
            break
        end
        
        i = i + 1
    end
    
    -- If we didn't find Volendrung but state says it's active, clear it
    if not hasVolendrung and BM.buffStates[unitTag] and BM.buffStates[unitTag][BM.VOLENDRUNG_BUFF_ID] and BM.buffStates[unitTag][BM.VOLENDRUNG_BUFF_ID].active then
        BM.OnVolendrungLost(unitTag)
    end
end

--[[
    Scan all group members for buffs
]]--
function BM.ScanAllGroupBuffs()
    local groupSize = GetGroupSize()
    if groupSize == 0 then
        -- Not in a group, just scan player
        BM.ScanPlayerBuffs()
        return
    end
    
    -- Scan each group member
    for i = 1, groupSize do
        local unitTag = GetGroupUnitTagByIndex(i)
        if unitTag then
            BM.ScanUnitBuffs(unitTag)
        end
    end
end

--[[
    Scan a specific unit's buffs
]]--
function BM.ScanUnitBuffs(unitTag)
    local hasVolendrung = false
    
    -- Iterate through all buffs on the unit
    local i = 1
    while true do
        local buffName, startTime, endTime, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer = GetUnitBuffInfo(unitTag, i)
        
        if not buffName or buffName == "" then
            break  -- No more buffs
        end
        
        -- Check if this is Volendrung
        if BM.IsVolendrungId(abilityId) then
            hasVolendrung = true
            -- Ensure state is recorded
            if not BM.buffStates[unitTag] or not BM.buffStates[unitTag][BM.VOLENDRUNG_BUFF_ID] or not BM.buffStates[unitTag][BM.VOLENDRUNG_BUFF_ID].active then
                BM.OnVolendrungGained(unitTag, startTime, endTime)
            end
            break
        end
        
        i = i + 1
    end
    
    -- If we didn't find Volendrung but state says it's active, clear it
    if not hasVolendrung and BM.buffStates[unitTag] and BM.buffStates[unitTag][BM.VOLENDRUNG_BUFF_ID] and BM.buffStates[unitTag][BM.VOLENDRUNG_BUFF_ID].active then
        BM.OnVolendrungLost(unitTag)
    end
end

--[[
    Check if a unit has Volendrung buff active
    @param unitTag string - Unit to check (can be "player" or "group1", etc.)
    @return boolean - True if Volendrung is active
]]--
function BM.HasVolendrung(unitTag)
    if not unitTag then
        return false
    end
    
    -- First try direct lookup
    if BM.buffStates[unitTag] 
        and BM.buffStates[unitTag][BM.VOLENDRUNG_BUFF_ID] 
        and BM.buffStates[unitTag][BM.VOLENDRUNG_BUFF_ID].active then
        return true
    end
    
    -- If unitTag is "player" and not found, check if player is in a group
    -- and search by character name instead
    if unitTag == "player" then
        local playerName = GetUnitName("player")
        for storedTag, buffs in pairs(BM.buffStates) do
            if GetUnitName(storedTag) == playerName then
                if buffs[BM.VOLENDRUNG_BUFF_ID] and buffs[BM.VOLENDRUNG_BUFF_ID].active then
                    return true
                end
            end
        end
    end
    
    return false
end

--[[
    Clear buff state for a character (when they leave group)
]]--
function BM.ClearBuffStateForCharacter(characterName)
    -- Find and clear buff state by character name
    for unitTag, buffs in pairs(BM.buffStates) do
        if GetUnitName(unitTag) == characterName then
            BM.buffStates[unitTag] = nil
            break
        end
    end
end

--[[
    Register a callback for Volendrung state changes
    @param callbackName string - Unique identifier for this callback
    @param callback function - Function to call when state changes (unitTag, hasVolendrung)
]]--
function BM.RegisterVolendrungCallback(callbackName, callback)
    BM.volendrungCallbacks[callbackName] = callback
end

--[[
    Unregister a Volendrung callback
]]--
function BM.UnregisterVolendrungCallback(callbackName)
    BM.volendrungCallbacks[callbackName] = nil
end

--[[
    Notify all registered callbacks of Volendrung state change
]]--
function BM.NotifyVolendrungChanged(unitTag, hasVolendrung)
    for name, callback in pairs(BM.volendrungCallbacks) do
        local success, err = pcall(callback, unitTag, hasVolendrung)
        if not success then
            d(string.format("[Beltalowda] Error in Volendrung callback '%s': %s", name, tostring(err)))
        end
    end
end

return BM
