DarwinAward = {}

local ADDON_NAME = "DarwinAward"

DarwinAward.defaults = {
    criminalActs = 0,
    resultingDeaths = 0
}

DarwinAward.variables = {}

local criminalActAbilities = {
        -- [[ Gravelord ]]
        [122174] = true, -- Colossus
        [122395] = true,
        [122388] = true,
        [114860] = true, -- Blastbones
        [117690] = true,
        [117749] = true,
        [114317] = true, -- Skeletal Mage
        [118680] = true,
        [118726] = true,
        -- [[ Bone Tyrant ]]
        [115001] = true, -- Goliath
        [118664] = true,
        [118279] = true,
        -- [[ Living Death ]]
        [115710] = true, -- Spirit Mender
        [118912] = true,
        [118840] = true,
        -- [[ Werewolf ]]
        [32455] = true, -- Werewolf Transformation
        [39075] = true,
        [39076] = true,
        -- [[ Vampire ]]
        [32624] = true, -- Blood Scion
        [38932] = true,
        [38931] = true,

        [132141] = true, -- Blood Frenzy
        [134160] = true,
        [135841] = true,

        [134583] = true, -- Vampiric Drain
        [135905] = true,
        [137259] = true,

        [32986] = true, -- Mist Form
        [38963] = true,
        [38965] = true
}

local function outputToChat()
    if DarwinAward.variables.criminalActs > 0 then
        CHAT_SYSTEM:AddMessage("You have committed " .. DarwinAward.variables.criminalActs .. " criminal act(s) which has resulted in you dying " .. DarwinAward.variables.resultingDeaths .. " time(s)...")
    else 
        CHAT_SYSTEM:AddMessage("No data saved yet, try committing some heinous acts first")
    end
end

local function setNewMessage()
    if DarwinAward.variables.criminalActs > 0 then
        CHAT_SYSTEM.textEntry:SetText("I have committed " .. DarwinAward.variables.criminalActs .. " criminal act(s) which has caused me to die " .. DarwinAward.variables.resultingDeaths .. " time(s)...")
        CHAT_SYSTEM:Maximize() CHAT_SYSTEM.textEntry:Open() CHAT_SYSTEM.primaryContainer:FadeIn()
    else 
        CHAT_SYSTEM:AddMessage("No data saved yet, try committing some heinous acts first")
    end
end

local function handlePlayerDeath()
    -- Died, add a death and unregister
    DarwinAward.variables.resultingDeaths = DarwinAward.variables.resultingDeaths + 1
    outputToChat()
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_PLAYER_COMBAT_STATE)
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_PLAYER_DEAD)
end

local function handleCombatStateChange(_, inCombat)
    -- No longer in combat, got away?
    if not inCombat then
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_PLAYER_COMBAT_STATE)
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_PLAYER_DEAD)
    else
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_DEAD, handlePlayerDeath)
    end
end

local function handleJusticeLevel(_, oldInfamy, newInfamy, oldInfamyLevel, newInfamyLevel)
    -- Infamy level 3 = KOS
    if newInfamyLevel == 3 then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_COMBAT_STATE, handleCombatStateChange)
    else
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_PLAYER_COMBAT_STATE)
    end        
end

local function handleCombatEvent(eventCode,result,isError,abilityName,abilityGraphic,abilityActionSlotType,sourceName,sourceType,targetName,targetType,hitValue,powerType,damageType,_,sourceUnitId,targetUnitId,abilityId)
    if isError or abilityId == nil or abilityName == "" or sourceUnitId == nil or sourceType ~= 1 or hitValue < 5 then return end
    local unitName = GetUnitName("player") .. "^Mx"
    if IsInJusticeEnabledZone() and criminalActAbilities[abilityId] and sourceName == unitName then
        DarwinAward.variables.criminalActs = DarwinAward.variables.criminalActs + 1
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_JUSTICE_INFAMY_UPDATED, handleJusticeLevel)
        -- Set a timeout to unregister if player doesn't end up in combat?
        zo_callLater(function ()
            EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_JUSTICE_INFAMY_UPDATED)
            EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_PLAYER_COMBAT_STATE)
        end, 60000)
    end
end

local function onAddOnLoaded(_, addOnName)
	if addOnName == ADDON_NAME then
		EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
        local vars = ADDON_NAME .. "_SavedVariables"
        DarwinAward.variables = ZO_SavedVars:NewAccountWide(vars, 1, nil, DarwinAward.defaults)
        SLASH_COMMANDS["/darwinaward"] = outputToChat
        SLASH_COMMANDS["/darwinawardtochat"] = setNewMessage
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_COMBAT_EVENT, handleCombatEvent)
    end
end
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, onAddOnLoaded)