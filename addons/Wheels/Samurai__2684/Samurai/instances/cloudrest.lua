SAMURAI = SAMURAI or { }
local sam = SAMURAI

local bossSpawned = false
local kills = 0
local creeperFrame = -1
local displayingCT = false

local function spawnAlert(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
	if bossSpawned then return end
	local boss = zo_strformat("<<1>>", GetUnitName('boss1'))
	local cur, max = GetUnitPower("boss1", POWERTYPE_HEALTH)
	if boss == "Z'Maja" and max ~= 0 and cur == max and targetType == 0 then
		sam.debug("unit died, source: %s, target: %s, hitValue: %d", tostring(sourceType), tostring(targetType), hitValue)
		kills = kills + 1
	elseif boss == "Z'Maja" and cur < max then
		bossSpawned = true
		sam.EM:UnregisterForEvent(sam.name.."zmajaSpawnAlert", EVENT_COMBAT_EVENT)
	end
	if kills >= 8 then
		sam.EM:UnregisterForEvent(sam.name.."zmajaSpawnAlert", EVENT_COMBAT_EVENT)
		bossSpawned = true
		sam.spawnTimer(9.1)
	end
end

local function onUnload()
	sam.EM:UnregisterForEvent(sam.name.."zmajaSpawnAlert", EVENT_COMBAT_EVENT)
	bossSpawned = false
	kills = 0
end

local function onLoad()
	sam.EM:RegisterForEvent(sam.name.."zmajaSpawnAlert", EVENT_COMBAT_EVENT, spawnAlert)
	sam.EM:AddFilterForEvent(sam.name.."zmajaSpawnAlert", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_DIED)
end

local function creeperTargetAlert()
	if not sam.savedVars.notis.creeperTarget then return end
	if ACTIVE_COMBAT_TIP_SYSTEM.tipText:GetText() == "Razorthorn tunnels toward you!" then
		if displayingCT then return end
		displayingCT = true
		creeperFrame = sam.UI.getAvailableNotificationFrame()
		sam.UI.displayAlert(creeperFrame, "|ce433ffCreeper Targetting You|r")
		PlaySound(SOUNDS.CHAMPION_POINTS_COMMITTED)
		zo_callLater(function()
			sam.UI.hideAlert(creeperFrame)
			displayingCT = false
			creeperFrame = -1
		end, 2000)
	end
end

local function creeperTarget()
	ACTIVE_COMBAT_TIP_SYSTEM.tipText:SetHandler("OnTextChanged", creeperTargetAlert, "SAMURAI") -- might need to change this to an on shown handler
end

local cr = sam.Instance:New(1051, nil, nil, onLoad, onUnload)

cr:AddAlert(sam.TimerNotification:New("ShockingSmash", "2bcaff", "Smash", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {105780}, false))
cr:AddAlert(sam.TimerNotification:New("DirectCurrent", "00caff", "Current", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {105380}, false))
cr:AddAlert(sam.TimerNotification:New("NocturnalsFavor", "ca4fff", "Favor", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {104535}, true))

cr:AddAlert(sam.ActiveNotification:New(nil, nil, "Creeper", "ff2e85", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {105016}, "Creeper spawning!", 2000, false))
cr:AddAlert(sam.ActiveNotification:New(nil, nil, "IcyTeleport", "19d5ff", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {106682}, "Incoming Teleport", 2000, true))
cr:AddAlert(sam.ActiveNotification:New(creeperTarget, nil, "creeperTarget"))

table.insert(sam.instances, cr)
