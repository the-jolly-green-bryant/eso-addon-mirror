-- StowIt
-- Sheaths your weapon after you leave combat.
-- Author: RunningDuck, mainly adaptation to APIversion 100010 (patch 1.5) and later
--         Taken over by Beartram on December 2017 (API 100021) to improve and add features
-- Original author: stjobe, who deserves main cred

if StowIt == nil then StowIt = {} end
local SI = StowIt

SI.addonVars = {}
SI.addonVars.addonVersion = 3.27
SI.addonVars.displayVersion = tostring(SI.addonVars.addonVersion)
SI.addonVars.addonName = "StowIt"
SI.addonVars.addonAuthor = "stjobe, RunningDuck & Baertram"
SI.addonVars.addonWebsite = "http://www.esoui.com/downloads/info862-StowItAuto-Sheather.html"
SI.addonVars.addonSavedVariablesName = "StowIt_Settings"
SI.addonVars.addonSavedVarsVersion = 3.24 -- DO NOT CHANGE OR SAVEDVARS WILL RESET!

SI.settingsVars = {}
SI.settingsVars.settings = {}
SI.settingsVars.defaultSettings = {}
SI.settingsVars.defaultsSettings = {
    saveMode     		  = 2, --Standard: Account wide settings
}
SI.settingsVars.defaultsValues = {
    stowAfterWeaponSwap = false,
}

SI.flagVars = {}
SI.flagVars.bladeOfWoeAttackStarted = false
SI.flagVars.nightbladShadowCloackAttackStarted = false

SI.inCombat = false
SI.DebugMe = false -- Set to false to inhibit trace printout in chat

--Stowthe weapon now
function SI.StowWeapon(delay)
    delay = delay or 1500
    if (SI.DebugMe == true) then d("[SI.StopWeapon] delay: " ..tostring(delay)) end
    zo_callLater(function()
        local flagVars = SI.flagVars
        flagVars.bladeOfWoeAttackStarted = false
        flagVars.nightbladShadowCloackAttackStarted = false
        --Weapons are not unsheathed? Then no need to sheath them "again"
        if ArePlayerWeaponsSheathed() then return end
        TogglePlayerWield() -- Stow the weapon
    end, delay)
end

-- Check once a second whether we're still in combat. If we're not,
-- we wait 1.5 seconds to let animations finish playing, then we
-- toggle TogglePlayerWield to sheath our weapon(s)
function SI.LoopUntilStow(delay)
    delay = delay or 1000
    if IsUnitInCombat("player") == false then
        SI.StowWeapon()
        -- debug
        if (SI.DebugMe == true) then d("[SI.LoopUntilStow] out of combat detected") end
        -- end debug
    else
        zo_callLater(SI.LoopUntilStow, delay)
    end
end

--======================================================================================================================
--      EVENTS
--======================================================================================================================
-- EVENT_PLAYER_COMBAT_STATE sends 'true' once when combat starts
-- and then 'nil' on every update, so we just check for 'true' to
-- start our loop
function SI.Trigger(eventCode, inCombat)
    SI.inCombat = inCombat
    if (SI.DebugMe == true) then d("[SI.Trigger] Combat changed to: " .. tostring(inCombat)) end
    if not inCombat then
        --Got out of combat, so sheath the weapon now 1,5seconds later (as animations ended)
        SI.StowWeapon()
    end
end

-- EVENT_ACTIVE_WEAPON_PAIR_CHANGED (number eventCode, number ActiveWeaponPair activeWeaponPair, boolean locked)
function SI.ActiveWeaponPairChanged(eventCode, activeWeaponPair, locked)
    if SI.DebugMe == true then
        d("[SI.ActiveWeaponPairChanged] activeWeaponPair: " .. tostring(activeWeaponPair) .. ", locked: " .. tostring(locked) .. ", stowAfterSwap: " .. tostring(SI.settingsVars.settings.stowAfterWeaponSwap) .. ", inCombat: " ..tostring(SI.inCombat))
    end
    --Setting to stow weapon after weapon change activated and are we not in combat?
    if SI.settingsVars.settings.stowAfterWeaponSwap == true and not SI.inCombat then
        --Wea are out of combat, so sheath the weapon now (animation canceled)
        SI.StowWeapon(500)
    end
end


--Blade of WOE
--======================================================================================================================
--BLADE OF WOE - Assasins league
--Blade of WOE starting skill: 76325. Will be called once as the attack starts, and again if the attack ends soon
--======================================================================================================================
--[[
Blade of WOE - 20260702
1) [SI.CombatEvent]result: 1,abilityName: Leidensklinge^f, abilityActionSlotType: 0, sourceName: Gammal Björn^Mx, sourceType: 1, targetName: Carlotta Censorinus^F, targetType: 0, hitValue: 25974, powerType: 1, damageType: 5, log: true, sourceUnitId: 52636, targetUnitId: 66249, abilityId: 76325
2) [SI.CombatEvent]result: 2240,abilityName: Leidensklinge^f, abilityActionSlotType: 0, sourceName: Gammal Björn^Mx, sourceType: 1, targetName: Carlotta Censorinus^F, targetType: 0, hitValue: 1, powerType: 0, damageType: 1, log: true, sourceUnitId: 52636, targetUnitId: 66249, abilityId: 77101
3) [SI.CombatEvent]result: 2020,abilityName: Leidensklinge^f, abilityActionSlotType: 0, sourceName: Gammal Björn^Mx, sourceType: 1, targetName: Carlotta Censorinus^F, targetType: 0, hitValue: 0, powerType: 0, damageType: 1, log: true, sourceUnitId: 52636, targetUnitId: 66249, abilityId: 77101
4) [SI.CombatEvent]result: 2245,abilityName: Leidensklinge^f, abilityActionSlotType: 0, sourceName: Gammal Björn^Mx, sourceType: 1, targetName: Belenius Pelius^M, targetType: 0, hitValue: 2000, powerType: 0, damageType: 1, log: true, sourceUnitId: 52636, targetUnitId: 3067, abilityId: 77101
5) [SI.CombatEvent]result: 2262,abilityName: Leidensklinge^f, abilityActionSlotType: 0, sourceName: Gammal Björn^Mx, sourceType: 1, targetName: Belenius Pelius^M, targetType: 0, hitValue: 103, powerType: 0, damageType: 5, log: true, sourceUnitId: 52636, targetUnitId: 3067, abilityId: 76325
]]
local bladeOfWoeStartingSkills = {
    [76325] = true, --Blade of Woe starting skill. Once for the start with result = ACTION_RESULT_DAMAGE and powerType 1 and damageType 5, and later followed by other ability IDs like multiple 77101, and then again 76325 with result = ACTION_RESULT_DIED_XP and powerType 0
}

--Nightblade
local nightBladeShadowCloackAndMorphs = {
    [36367] = true, -- Shadow Cloack
    [25375] = true, -- Shadow Cloak (Rank I)
    [36329] = true, -- Shadow Cloak (Rank II)
    [36333] = true, -- Shadow Cloak (Rank II)
    [36337] = true, -- Shadow Cloak (Rank IV)
    [25380] = true, -- Shadowy Disguise (Rank I)
    [36356] = true, -- Shadowy Disguise (Rank II)
    [36362] = true, -- Shadowy Disguise (Rank III)
    [36368] = true, -- Shadowy Disguise (Rank IV)
    [34698] = true, -- Dark Cloak
    [25377] = true, -- Dark Cloak (Rank I)
    [36341] = true, -- Dark Cloak (Rank II)
    [36346] = true, -- Dark Cloak (Rank III)
    [36351] = true, -- Dark Cloak (Rank IV)
    --------------------------------------------------
    [64244] = true, -- Shadowstrike (Champion Passive)
}


--EVENT_COMBAT_EVENT
function SI.CombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    --Already handled in event_filter at C side of code before the lua code triggers!
    --local playerName = zo_strformat(SI_UNIT_NAME, GetUnitName("player"))
    --local source = zo_strformat("<<t:1>>",sourceName)
    --if sourceType ~= COMBAT_UNIT_TYPE_PLAYER or source ~= playerName then return false end
    if (SI.DebugMe == true) then
        d("[SI.CombatEvent]result: ".. tostring(result) ..",abilityName: " .. tostring(abilityName) .. ", abilityActionSlotType: ".. tostring(abilityActionSlotType) .. ", sourceName: "..  tostring(sourceName) .. ", sourceType: "..  tostring(sourceType) .. ", targetName: "..  tostring(targetName) .. ", targetType: "..  tostring(targetType) .. ", hitValue: "..  tostring(hitValue) .. ", powerType: "..  tostring(powerType) .. ", damageType: "..  tostring(damageType) .. ", log: "..  tostring(log) .. ", sourceUnitId: "..  tostring(sourceUnitId) .. ", targetUnitId: "..  tostring(targetUnitId) .. ", abilityId: "..  tostring(abilityId))
--d("[SI.CombatEvent]result: ".. tostring(result) ..",abilityName: " .. tostring(abilityName) .. ", powerType: "..  tostring(powerType) .. ", abilityId: "..  tostring(abilityId))
    end

    --SKILL & ABILITY IDS
    --Check if a blade of woe or nightblade shadow cloak skill was used
    if abilityId ~= nil then
        local flagVars = SI.flagVars

        --Blade of WOE
        local bladeOfWoeStartingSkill = (bladeOfWoeStartingSkills[abilityId] == true and true) or false

        --Check if nightblade shadow cloack or morph was used
        flagVars.nightbladShadowCloackAttackStarted = false
        if not bladeOfWoeStartingSkill and nightBladeShadowCloackAndMorphs[abilityId] then
            flagVars.nightbladShadowCloackAttackStarted = true
        end

        --New attacked enemy with Blade of WoE
        if bladeOfWoeStartingSkill and powerType == 1 and result == ACTION_RESULT_DAMAGE then
            if (SI.DebugMe == true) then d("[SI.CombatEvent] Blade of Woe detected!") end
            flagVars.bladeOfWoeAttackStarted = true
        --Attacked enemy will die soon, so wait a bit and sheeth the weapon now
        elseif flagVars.bladeOfWoeAttackStarted == true and bladeOfWoeStartingSkill and powerType == 0 and result == ACTION_RESULT_DIED_XP then --attacked NPC died
            if (SI.DebugMe == true) then d("> Blade of Woe enemy nearly dead!") end
            flagVars.bladeOfWoeAttackStarted = false
            --At this point the following lines will be fired as events and then the fight is over
            --Verlangsamung der Leidensklinge^f(77102), sourceName: , sourceType: 0, targetName: Bärtram Bärenfreund^Mx, targetType: 1, sourceUnitId: 0, targetUnitId: 41482, hitValue: 1800, powerType: -1, damageType: 1
            --Leidensklinge^f(77101), sourceName: , sourceType: 0, targetName: , targetType: 0, sourceUnitId: 0, targetUnitId: 67391, hitValue: 2000, powerType: -1, damageType: 1]]
            --
            --So stow the weapon in about 1,5 seconds
            SI.StowWeapon()

    --======================================================================================================================
    --NIGHTBLADE - Shadow cloack, shadow disguise, Dark cloak
    --======================================================================================================================
        elseif flagVars.nightbladShadowCloackAttackStarted and powerType == -1 then
            --So stow the weapon in about 0,5 seconds
            SI.StowWeapon(500)
        end

    end -- if abilityId ~= nil then
end

--======================================================================================================================
--      SETTINGS
--======================================================================================================================
--Load the settings from the SavedVariables
function SI.LoadSettings()
    local addonVars = SI.addonVars
    local defaults = SI.settingsVars.defaultsValues
    --=============================================================================================================
    --	LOAD USER SETTINGS
    --=============================================================================================================
    --Load the user's settings from SavedVariables file -> Account wide of basic version 999 at first
    SI.settingsVars.defaultSettings = ZO_SavedVars:NewAccountWide(addonVars.addonSavedVariablesName, 999, "SettingsForAll", SI.settingsVars.defaultsSettings)

    --Check, by help of basic version 999 settings, if the settings should be loaded for each character or account wide
    --Use the current addon version to read the settings now
    local serverName = GetWorldName()
    if (SI.settingsVars.defaultSettings.saveMode == 1) then
        --ZO_SavedVars:NewCharacterIdSettings(savedVariableTable, version, namespace, defaults, profile)
        SI.settingsVars.settings = ZO_SavedVars:NewCharacterIdSettings(addonVars.addonSavedVariablesName, addonVars.addonSavedVarsVersion , "Settings", defaults, serverName)
    elseif (SI.settingsVars.defaultSettings.saveMode == 2) then
        SI.settingsVars.settings = ZO_SavedVars:NewAccountWide(addonVars.addonSavedVariablesName, addonVars.addonSavedVarsVersion, "Settings", defaults, serverName, nil)
    else
        SI.settingsVars.settings = ZO_SavedVars:NewAccountWide(addonVars.addonSavedVariablesName, addonVars.addonSavedVarsVersion, "Settings", defaults, serverName, nil)
    end
    --=============================================================================================================
end

--======================================================================================================================
--      LOAD ADDON, HOOKS, CALLBACKS and EVENTS
--======================================================================================================================
function SI.Loaded(eventCode, addOnName)
    local addonVars = SI.addonVars
    --Is this addon found?
    if(addOnName ~= addonVars.addonName) then
        return
    end
    --Unregister this event again so it isn't fired again after this addon has beend reckognized
    EVENT_MANAGER:UnregisterForEvent(addonVars.addonName, EVENT_ADD_ON_LOADED)

    local flagVars = SI.flagVars
    flagVars.bladeOfWoeAttackStarted = false
    flagVars.nightbladShadowCloackAttackStarted = false

    SI.inCombat = false

    --Load the settings
    SI.LoadSettings()

    --Register the events for the combat state etc.
    EVENT_MANAGER:RegisterForEvent(addonVars.addonName, EVENT_PLAYER_COMBAT_STATE, SI.Trigger)
    --Register the event for buff changes
    local uniqueBladeOfWoeEventFilterName = addonVars.addonName .. "_COMBAT_EVENT_BLADE_OF_WOE"
    EVENT_MANAGER:RegisterForEvent(uniqueBladeOfWoeEventFilterName, EVENT_COMBAT_EVENT, SI.CombatEvent)
    EVENT_MANAGER:AddFilterForEvent(uniqueBladeOfWoeEventFilterName, EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    --Register the event for weapon pair changed
    EVENT_MANAGER:RegisterForEvent(addonVars.addonName, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, SI.ActiveWeaponPairChanged)

    --Create the settings panel object of libAddonMenu 2.0
    SI.LAM = LibAddonMenu2
    --Build the LAM addon menu for the user defined settings
    SI.BuildAddonMenu()
end

-- Register our event listener as soon as the addon loads
function SI.StowItOnInitialized()
    local addonVars = SI.addonVars
	EVENT_MANAGER:RegisterForEvent(addonVars.addonName, EVENT_ADD_ON_LOADED, SI.Loaded)
	--Register for the zone change/player ready event
	--EVENT_MANAGER:RegisterForEvent(addonVars.addonName, EVENT_PLAYER_ACTIVATED, SI.PlayerActivated)
end
SI.StowItOnInitialized()