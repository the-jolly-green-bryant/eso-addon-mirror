SAMURAI = SAMURAI or { }
local sam = SAMURAI
local EM = GetEventManager()

local divePlayers = { }

local function reset()
	for k,v in pairs(divePlayers) do
		divePlayers[k] = nil
	end
end

local br = sam.Instance:New(1082, nil, reset)

local function dive(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
	sam.debug("handler fired for %s", "dive")
	if hitValue < 100 then return end
	if result == ACTION_RESULT_BEGIN then
		local target = sam.LUNITS.GetDisplayNameForUnitId(targetUnitId)
		if not divePlayers[target] then
			divePlayers[target] = {sam.UI.getAvailableNotificationFrame(), 0}
			local text = string.format("|c00FFFFHackwing Dive Targetting|r |cFFFF00%s|r", target)
			sam.UI.displayAlert(divePlayers[target][1], text)
		end
		divePlayers[target][2] = divePlayers[target][2] + 1
		PlaySound(SOUNDS.CHAMPION_POINTS_COMMITTED)
		zo_callLater(function()
			divePlayers[target][2] = divePlayers[target][2] - 1
			if divePlayers[target][2] <= 0 then
				sam.UI.hideAlert(divePlayers[target][1])
				divePlayers[target] = nil
			end
		end, 2500)
	end
end

local function registerDive()
	EM:RegisterForEvent(sam.name.."Dive85395", EVENT_COMBAT_EVENT, dive)
	EM:AddFilterForEvent(sam.name.."Dive85395", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 85395)
end

local function unregisterDive()
	EM:UnregisterForEvent(sam.name.."Dive85395", EVENT_COMBAT_EVENT)
end

br:AddAlert(sam.ActiveNotification:New(registerDive, unregisterDive, "Dive", nil, nil, nil, nil, "Dive"))

table.insert(sam.instances, br)
