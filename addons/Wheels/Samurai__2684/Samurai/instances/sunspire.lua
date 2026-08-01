SAMURAI = SAMURAI or { }
local sam = SAMURAI
--local EM = GetEventManager()
local EM = sam.EM

local ss = sam.Instance:New(1121, nil, nil)

local apocTime = 0
local apocFrame = -1
local apocString = "|cffdd00Wait:|r |cffffff%.1f|r"

local function apocCountdown()
	apocTime = apocTime - 100
	if apocTime < 0 then apocTime = 0 end
	if apocTime < 1000 then apocString:gsub("ffffff", "ff0000") end
	sam.UI.displayAlert(apocFrame, string.format(apocString, apocTime/1000))
	if apocTime == 0 then
		EM:UnregisterForUpdate(sam.name.."transApocCountdown")
		apocTime = 0
		apocString = "|cff0000Wait:|r |cffffff%.1f|r"
		sam.UI.hideAlert(apocFrame)
	end
end

local function transApoc(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
	if not sam.savedVars.notis.transApoc then return end
	if result == ACTION_RESULT_BEGIN and hitValue == 2000 then
		sam.debug("no interrupt")
		apocTime = hitValue
		apocString = "|cff0000Wait:|r |cffffff%.1f|r"
		apocFrame = sam.UI.getAvailableNotificationFrame()
		sam.UI.displayAlert(apocFrame, string.format(apocString, apocTime/1000))
		EM:RegisterForUpdate(sam.name.."transApocCountdown", 100, apocCountdown)
	elseif result == ACTION_RESULT_BEGIN and hitValue == 5000 then
		sam.debug("interrupt")
		EM:UnregisterForUpdate(sam.name.."transApocCountdown")
		apocString = "|c00ff00Interrupt:|r |cffffff%.1f|r"
		apocTime = hitValue
		sam.UI.displayAlert(apocFrame, string.format(apocString, apocTime/1000))
		EM:RegisterForUpdate(sam.name.."transApocCountdown", 100, apocCountdown)
	elseif result == ACTION_RESULT_EFFECT_FADED then
		EM:UnregisterForUpdate(sam.name.."transApocCountdown")
		apocTime = 0
		apocString = "|cffdd00Wait:|r %.1f"
		sam.UI.hideAlert(apocFrame)
	end
end

local function transition(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
	if targetType ~= COMBAT_UNIT_TYPE_PLAYER then return end
	if result == ACTION_RESULT_EFFECT_FADED then
		sam.debug("leaving portal")
		EM:UnregisterForUpdate(sam.name.."transApocCountdown")
		apocTime = 0
		apocString = "|cffdd00Wait:|r %.1f"
		sam.UI.hideAlert(apocFrame)
	end
end

local function registerApoc()
	EM:RegisterForEvent(sam.name.."TransApoc", EVENT_COMBAT_EVENT, transApoc)
	EM:AddFilterForEvent(sam.name.."TransApoc", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 121436)
	EM:RegisterForEvent(sam.name.."Transition", EVENT_COMBAT_EVENT, transition)
	EM:AddFilterForEvent(sam.name.."Transition", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 121216)
end

local function unregisterApoc()
	EM:UnregisterForEvent(sam.name.."TransApoc", EVENT_COMBAT_EVENT)
	EM:UnregisterForEvent(sam.name.."Transition", EVENT_COMBAT_EVENT)
end

ss:AddAlert(sam.ActiveNotification:New(registerApoc, unregisterApoc, "transApoc"))
--ss:AddAlert(sam.TimerNotification:New("TransApoc", "00f2de", "Interrupt", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {121436}, false))
ss:AddAlert(sam.TimerNotification:New("ssNegate", "c60dff", "Negate", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {121411}, true))
ss:AddAlert(sam.TimerNotification:New("ssGale", "ffcb0d", "Gale", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {121422}, true))
ss:AddAlert(sam.TimerNotification:New("ssIce", "0dffe7", "Ice", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {121074}, true))

table.insert(sam.instances, ss)
