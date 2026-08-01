


if EchoingVigorTracker == nil then EchoingVigorTracker = {} end
local EchoingVigorTracker = EchoingVigorTracker

--local EM		= GetEventManager()
EchoingVigorTracker.name		= "EchoingVigorTracker"
EchoingVigorTracker.version		= "2.0.2"
EchoingVigorTracker.varVersion 	= 3

EchoingVigorTracker.addonLoaded = false


EchoingVigorTracker.manuallyShowUi = false


EchoingVigorTracker.EVT_AT_NAME        = 1
EchoingVigorTracker.EVT_UNIT_ID        = 2
EchoingVigorTracker.EVT_ECHOING_VIGOR_EXPIRES = 3
EchoingVigorTracker.EVT_ROLE = 4
EchoingVigorTracker.EVT_HP_PERCENT = 5
EchoingVigorTracker.EVT_HP_ORDER = 6
EchoingVigorTracker.EVT_VALID_TARGET = 7

EchoingVigorTracker.echoingVigorMembers = {
-- parameter 1 EchoingVigorTracker.EVT_AT_NAME = player's @name
-- parameter 2 EchoingVigorTracker.EVT_UNIT_ID = player's unit id
-- parameter 3 EchoingVigorTracker.EVT_ECHOING_VIGOR_EXPIRES = when echoing vigor expires GetGameTimeMilliseconds()

-- index: player index "group2"
[1]  = {"", 0, 0, 0, 0, 0, false},
[2]  = {"", 0, 0, 0, 0, 0, false},
[3]  = {"", 0, 0, 0, 0, 0, false},
[4]  = {"", 0, 0, 0, 0, 0, false},
[5]  = {"", 0, 0, 0, 0, 0, false},
[6]  = {"", 0, 0, 0, 0, 0, false},
[7]  = {"", 0, 0, 0, 0, 0, false},
[8]  = {"", 0, 0, 0, 0, 0, false},
[9]  = {"", 0, 0, 0, 0, 0, false},
[10] = {"", 0, 0, 0, 0, 0, false},
[11] = {"", 0, 0, 0, 0, 0, false},
[12] = {"", 0, 0, 0, 0, 0, false},

}



EchoingVigorTracker.defaults	= {
	["global"] = true,

	["offsetX"] = 500,
	["offsetY"] = 500,

	["showOnlyInCombat"] = true,
	["enabled"] = true,

	["recommendCastingEnabled"] = true,
	["requiredTargetsToRecommendCastingTrials"] = 2,
	["requiredTargetsToRecommendCastingDungeons"] = 1,
	["includeMissingHpWhenRecommending"]=true,



	["activeEchoingVigorInRangeColor"]=                {0.00,0.69,0.00,0.69,},
	["activeEchoingVigorOutsideRangeColor"]=           {0.00,0.19,0.00,0.50,},
	["inactiveEchoingVigorCanReceieveColor"]=          {0.91,0.22,0.00,0.80,},
	["inactiveEchoingVigorCannotReceieveColor"]=       {0.70,0.45,0.19,0.49,},
	["recommendCastingEchoingVigorBackgroundColor"]=   {0.48,0.00,0.00,0.80,},
	["normalBackgroundColor"]=                         {0.19,0.19,0.19,0.58,},
}



function EchoingVigorTracker.resetVariables()
    for var, value in pairs(EchoingVigorTracker.defaults) do
        if var == "global" then
            -- skip
        elseif var == "offsetX" then
            -- skip
        elseif var == "offsetY" then
            -- skip
        else
            EchoingVigorTracker.savedVars[var]=value
        end
    end
end























function EchoingVigorTracker.EchoingVigorCombatEvent(eventCode,result,isError,abilityName,abilityGraphic,abilityActionSlotType,sourceName,sourceType,targetName,targetType,hitValue,powerType,damageType,combatEventLog,sourceUnitId,targetUnitId,abilityId)
	for i=1, 12 do
		if EchoingVigorTracker.echoingVigorMembers[i][EchoingVigorTracker.EVT_UNIT_ID] ==targetUnitId then
			EchoingVigorTracker.echoingVigorMembers[i][EchoingVigorTracker.EVT_ECHOING_VIGOR_EXPIRES]=GetGameTimeMilliseconds()+hitValue
			return
		end
	end
end







function EchoingVigorTracker.checkIfAddonNeedsToBeLoadedOrUnloaded()
	--d("checkIfAddonNeedsToBeLoadedOrUnloaded")
    if EchoingVigorTracker.isEchoingVigorSkillSlotted() and EchoingVigorTracker.savedVars.enabled then
	    EchoingVigorTracker.LoadAddon()
	else
	    EchoingVigorTracker.UnloadAddon()
	end
end

function EchoingVigorTracker.LoadAddon()
    if EchoingVigorTracker.addonLoaded == false then
        --d("Echoing Vigor Tracker Loaded")

		EVENT_MANAGER:RegisterForEvent(EchoingVigorTracker.name .. "EchoingVigorTracking_61506", EVENT_COMBAT_EVENT, EchoingVigorTracker.EchoingVigorCombatEvent)
        EVENT_MANAGER:AddFilterForEvent(EchoingVigorTracker.name .. "EchoingVigorTracking_61506", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 61506,REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED_DURATION, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

        EVENT_MANAGER:RegisterForEvent(EchoingVigorTracker.name .. "UnitsEffectChanged", EVENT_EFFECT_CHANGED, EchoingVigorTracker.OnEffectChanged)


		EVENT_MANAGER:RegisterForUpdate(EchoingVigorTracker.name.."NewUIUpdate", 100,EchoingVigorTracker.updateUi)
		EVENT_MANAGER:RegisterForUpdate(EchoingVigorTracker.name.."NewUIUpdateNames", 2000,EchoingVigorTracker.updateNamesDuration)
		
		

		EchoingVigorTracker.updatePlayerNames(true)


	    EchoingVigorTracker.addonLoaded=true
	end
end

function EchoingVigorTracker.UnloadAddon()
    if EchoingVigorTracker.addonLoaded == true then
		EVENT_MANAGER:UnregisterForEvent(EchoingVigorTracker.name .. "EchoingVigorTracking_61506", EVENT_COMBAT_EVENT)
        EVENT_MANAGER:UnregisterForEvent(EchoingVigorTracker.name .. "UnitsEffectChanged", EVENT_EFFECT_CHANGED)
		EVENT_MANAGER:UnregisterForUpdate(EchoingVigorTracker.name.."NewUIUpdate")
		EVENT_MANAGER:UnregisterForUpdate(EchoingVigorTracker.name.."NewUIUpdateNames")
	    EchoingVigorTracker.addonLoaded=false
		EchoingVigorTracker.updateUi()
        --d("Echoing Vigor Tracker Unloaded")

	end
end

function EchoingVigorTracker.OnPlayerCombatState(event, inCombat)


    if inCombat ~= EchoingVigorTracker.inCombat then
        EchoingVigorTracker.inCombat = inCombat
    end


    EchoingVigorTracker.checkIfAddonNeedsToBeLoadedOrUnloaded()

	EchoingVigorTracker.updatePlayerNames(true)

	
end






function EchoingVigorTracker.Init(event, addon)

	if addon ~= EchoingVigorTracker.name then return end

	EVENT_MANAGER:UnregisterForEvent(EchoingVigorTracker.name.."Load", EVENT_ADD_ON_LOADED)

    EchoingVigorTracker.savedVars = ZO_SavedVars:NewCharacterIdSettings(EchoingVigorTracker.name.."SavedVars",  EchoingVigorTracker.varVersion, nil, EchoingVigorTracker.defaults)
    if EchoingVigorTracker.savedVars.global then
        EchoingVigorTracker.savedVars = ZO_SavedVars:NewAccountWide(EchoingVigorTracker.name.."SavedVars",  EchoingVigorTracker.varVersion, nil, EchoingVigorTracker.defaults)
        EchoingVigorTracker.savedVars.global = true
    end

	EchoingVigorTracker.setupMenu()

	EchoingVigorTracker.inCombat = IsUnitInCombat("player")

 	--SLASH_COMMANDS["/evt"] = EchoingVigorTracker.slashCommands

	EchoingVigorTracker.adjustFrameLocation()
    EchoingVigorTracker.checkIfAddonNeedsToBeLoadedOrUnloaded()

	EVENT_MANAGER:RegisterForEvent(EchoingVigorTracker.name.."CombatState", EVENT_PLAYER_COMBAT_STATE, EchoingVigorTracker.OnPlayerCombatState)

end




EVENT_MANAGER:RegisterForEvent(EchoingVigorTracker.name.."Load", EVENT_ADD_ON_LOADED, EchoingVigorTracker.Init)
