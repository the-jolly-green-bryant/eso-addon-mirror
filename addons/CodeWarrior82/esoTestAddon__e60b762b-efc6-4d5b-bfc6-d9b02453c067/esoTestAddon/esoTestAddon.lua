local appName = "esoTestAddon"
local isLoaded = false
local inCombat = false
local timeRemaining = 0

local corrosiveID = 17879
local corrosiveIconPath = GetAbilityIcon(corrosiveID)
local maskDebuffID = 252048
local maskDebuffIconPath = GetAbilityIcon(maskDebuffID)
local availableSlot = 0


-- DEBUFF LIST --
-- corrosive
-- warmask

-- feared, stunned, immobilized, charmed
-- status effects
-- off balance 
-- stagger ?? (65 extra damage per hit per stack up to 3)

-- breach (reduces armor by 2974 / 5948)
-- brittle (increases crit damage taken by 10% / 20%)
-- cowardice (reduces weapon and spell damage by 215 / 430)
-- defile (reduces healing received by 6% / 12%)
-- enervation (reduces crit damage by 10% / 20%)
-- hindrance (reduces movement speed by 50%)
-- maim (reduces damage done by 5% / 10%)
-- mangle (reduce max health by 10% / )
-- timidity (drains ultimate  1:1.5 sec / )
-- uncertainty (reduces crit chance by 657 / 1314)
-- vulnerability (increases damage taksen by 5% / 10%) 

esoTestAddon = {}

esoTestAddon.buffType = ""
esoTestAddon.buffName = ""

--debuff availability list
local availableDebuff = {
    debuff0 = false,
    debuff1 = false,
    debuff2 = false,
    debuff3 = false,
    debuff4 = false,
    debuff5 = false,
    debuff6 = false,
    debuff7 = false,
    debuff8 = false,
    debuff9 = false,
    debuff10 = false,
}

-- Major & Minor Effect Identifiers
esoTestAddon.EFFECT_BREACH			= 1
esoTestAddon.EFFECT_BRITTLE			= 2
esoTestAddon.EFFECT_COWARDICE		= 3
esoTestAddon.EFFECT_DEFILE			= 4
esoTestAddon.EFFECT_ENERVATION		= 5
esoTestAddon.EFFECT_HINDRANCE		= 6
esoTestAddon.EFFECT_MAIM			= 7
esoTestAddon.EFFECT_MANGLE			= 8
esoTestAddon.EFFECT_TIMIDITY		= 9
esoTestAddon.EFFECT_UNCERTAINTY		= 10
esoTestAddon.EFFECT_VULNERABILITY	= 11

esoTestAddon.defaults = {
    trackLongTimers = false,
    trackStagger = false,
    trackOffBalance = false,
    trackCCeffects = false,
    trackStatusEffects = false,
    trackWarmask = false,
    trackCorrosive = true,
    trackBreach = true,
    trackBrittle = true,
    trackCowardice = true,
    trackDefile = true,
    trackEnervation = true,
    trackMaim = true,
    trackMangle= true,
    trackTimidity = false,
    trackUncertainty = true,
    trackVulnerability = true,
    yAxisText = 440,
    xAxisText = 400
}

--print message to chat box
local function printMessageTest(msg)
	local chat = LibChatMessage(appName, "MA")
	chat:Print(msg)
end

--clean player names
local function cleanName(str)
    return str:sub(1, -4)
end

--process combat state alerts
local function combatStatusChanged(eventID, isInCombat)
    if isInCombat then
        inCombat = true
    else
        inCombat = false
    end
end

--process available debuff slot
local function whichDebuffSlot()
    if availableDebuff.debuff1 == true then availableSlot = 1
    elseif availableDebuff.debuff2 == true then availableSlot = 2
    elseif availableDebuff.debuff3 == true then availableSlot = 3
    elseif availableDebuff.debuff4 == true then availableSlot = 4
    elseif availableDebuff.debuff5 == true then availableSlot = 5
    elseif availableDebuff.debuff6 == true then availableSlot = 6
    elseif availableDebuff.debuff7 == true then availableSlot = 7
    elseif availableDebuff.debuff8 == true then availableSlot = 8
    elseif availableDebuff.debuff9 == true then availableSlot = 9
    elseif availableDebuff.debuff10 == true then availableSlot = 10
    else return
    end
end

--is debuff major
local function isMajorEffect(abilityID)
	return abilityIdList.majorEffects[abilityID] and true or false
end

--is debuff minor
local function isMinorEffect(abilityID)
	return abilityIdList.minorEffects[abilityID] and true or false
end

--process which debuff has been applied to the player
local function whichDebuff(abilityId)



    if isMajorEffect(abilityId) then
        esoTestAddon.buffType = "Major "
        esoTestAddon.buffName = abilityIdList.EffectTypes[abilityIdList.majorEffects[abilityId]]
        printMessageTest(esoTestAddon.buffType .. esoTestAddon.buffName)
        esoTestAddon.buffType = ""
        esoTestAddon.buffName = ""
    elseif isMinorEffect(abilityId) then
        esoTestAddon.buffType = "Minor "
        esoTestAddon.buffName = abilityIdList.EffectTypes[abilityIdList.minorEffects[abilityId]]
        printMessageTest(esoTestAddon.buffType .. esoTestAddon.buffName)
        esoTestAddon.buffType = ""
        esoTestAddon.buffName = ""
    else 
        esoTestAddon.buffType = "Unknown "
        local text = string.format(" %d", abilityId)

    end


    

end

local function buffActive(debuffID)
    for i = 1, GetNumBuffs("player") do
        local buffName, timeStarted, timeEnding, _, _, _, _, _, iconFilename, _, abilityId, _, _ = GetUnitBuffInfo("player", i)
        
        if abilityId == debuffID then
            timeRemaining = timeEnding - GetFrameTimeSeconds()
            return true
        end
    end
    return false
end

--handle combat alert
local function combatReport(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, 
    sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    
    --if there is an error
    if isError then
        return
    end

    --if not in combat
    --if not inCombat then
    --    return
    --end

    --player applying debuff
    --local nameEnemyTmp = cleanName(sourceName)

    --local player
    --local nameTmp = GetUnitName("player")

    --if debuff is not being applied to local player move on
    --if nameTmp ~= cleanName(targetName) then
    --    return
    --end

    --test
    availableDebuff.debuff10 = true

    --find which debuff slot is free
    whichDebuffSlot()

    local text = string.format(" %d", availableSlot)
    printMessageTest(text)





    --if debuff is applied to player (may need changing to compare targetName)
    --if buffActive(abilityId) then
    
        --if availableDebuff[true] == 9 / availableDebuff[true] == 10 then

            

            whichDebuff(abilityId)

        --end
    --end





    
end

--register for combat notifications
local function registerAlerts()
    EVENT_MANAGER:RegisterForEvent("combatReport", EVENT_COMBAT_EVENT, combatReport)
end

--unregister for combat notifications
local function unRegisterAlerts()
    EVENT_MANAGER:UnregisterForEvent("combatReport", EVENT_COMBAT_EVENT)
end















local function onAddOnLoadedTest(event, name)

    --if add-on loaded was not this add-on quit
    if name ~= appName then
        return
    end

    --unregister for notifications of add-on loaded
    EVENT_MANAGER:UnregisterForEvent(appName, EVENT_ADD_ON_LOADED)

	--notify that add-on has been loaded
	zo_callLater(function() printMessageTest("add-on successfully loaded") end, 500)

    --register for debuff notifications for tracked buffs
    registerAlerts()

    --register for combat state notifications
    EVENT_MANAGER:RegisterForEvent(appName, EVENT_PLAYER_COMBAT_STATE, combatStatusChanged)

    --register for notifications of menu or map opening
    --SCENE_MANAGER:RegisterCallback("SceneStateChanged", onSceneStateChange)

    --setup add on menu options
    --createOptions()

    --set is loaded boolean for use later, to stop scene change hiding tracker icon at first load in
    zo_callLater(function () isLoaded = true end, 2000)

end

--register for notification that an addon has been loaded
EVENT_MANAGER:RegisterForEvent(appName, EVENT_ADD_ON_LOADED, onAddOnLoadedTest)