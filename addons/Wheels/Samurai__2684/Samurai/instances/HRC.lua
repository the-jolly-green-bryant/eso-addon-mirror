SAMURAI = SAMURAI or { }
local sam = SAMURAI

-- porting to this addon in progress

local shieldZone = -1
local shieldTime = 0

local function reset()
	shieldZone = -1
	shieldTime = 0
end

local HRC = sam.Instance:New(636, nil, reset)

HRC:AddAlert(sam.ActiveNotification:New(nil, nil, "Cleave", "FF0000", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {48024}, "Cleave!", 2000, false))
HRC:AddAlert(sam.ActiveNotification:New(nil, nil, "Obliterate", "00FFFF", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {47481}, "Obliterate!", 2000, false))

local function shieldThrowTarget(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
	if result == ACTION_RESULT_BEGIN then
		local target = sam.LUNITS.GetDisplayNameForUnitId(targetUnitId)
	 	shieldZone = sam.UI.getAvailableNotificationFrame()
		sam.UI.displayAlert(shieldZone, string.format("|c44FF00Shield Throw Targetting|r: %s", target))
		--zo_callLater(sam.UI.hideAlert(shieldZone
	end
end

--TODO: add throw countdown

