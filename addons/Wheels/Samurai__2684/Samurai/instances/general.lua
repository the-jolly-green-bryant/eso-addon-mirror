SAMURAI = SAMURAI or { }
local sam = SAMURAI
--local EM = GetEventManager()
local EM = sam.EM

local spawnTimerFrame = nil
local spawnTimerTime = 0

local function spawnCountDown()
	spawnTimerTime = spawnTimerTime - 0.1
	if spawnTimerTime < 0 then
		EM:UnregisterForUpdate(sam.name.."BossSpawn")
		spawnTimerTime = 0
		sam.UI.displayAlert(spawnTimerFrame, string.format("|c18ff08Boss:|r %.1f", spawnTimerTime))
		--zo_callLater(function() sam.UI.hideAlert(spawnTimerFrame) end, 500)
		sam.UI.hideAlert(spawnTimerFrame)
		spawnTimerFrame = nil
	else
		sam.UI.displayAlert(spawnTimerFrame, string.format("|c18ff08Boss:|r %.1f", spawnTimerTime))
	end
end

function sam.spawnTimer(seconds)
	if not sam.savedVars.bossTimers then return end
	if spawnTimerFrame ~= nil then return end
	spawnTimerFrame = sam.UI.getAvailableNotificationFrame()
	spawnTimerTime = seconds
	EM:RegisterForUpdate(sam.name.."BossSpawn", 100, spawnCountDown)
end

local gen = sam.Instance:New(-1, nil, nil)


gen:AddAlert(sam.TimerNotification:New("TakingAim", "ffcb30", "Snipe", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {91736, 70695, 78781, 113146, 111209, 110898}, true))
gen:AddAlert(sam.TimerNotification:New("HeavyAttack", "e7ff30", "HA", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {14096, 40203, 120893, 49606, 111634}, true))
gen:AddAlert(sam.TimerNotification:New("HeavyStrike", "fc8403", "Heavy Strike", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {140230}, true))
gen:AddAlert(sam.TimerNotification:New("Bash", "38afff", "Bash", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {76538, 47466, 133685}, true))
gen:AddAlert(sam.TimerNotification:New("HeavySlash", "ff681c", "Heavy Slash", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {128527, 115928}, true))
gen:AddAlert(sam.TimerNotification:New("UpperCut", "ff681c", "Uppercut", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {29378, 70809, 24648, 47488, 82735, 136961}, true))
gen:AddAlert(sam.TimerNotification:New("AnvilCracker", "ff421c", "Anvil Cracker", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {119817, 86914}, true))
gen:AddAlert(sam.TimerNotification:New("CrushingBlow", "ffd91c", "Crushing Blow", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {27826, 25034}, true))
gen:AddAlert(sam.TimerNotification:New("Boulder", "ff1cd9", "Boulder", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {49311, 115942}, true))
gen:AddAlert(sam.TimerNotification:New("Slam", "bfff1c", "Slam", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {50547}, true))
gen:AddAlert(sam.TimerNotification:New("powerBash", "1cffc2", "Power Bash", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {29400}, true))
gen:AddAlert(sam.TimerNotification:New("LavaWhip", "ff6219", "Whip", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {110814, 111161}, true))
gen:AddAlert(sam.TimerNotification:New("TopplingBlow", "e134eb", "Toppling", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {111163}, true))
gen:AddAlert(sam.TimerNotification:New("ClashofBones", "00e5ff", "Clash", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {92892}, true))
gen:AddAlert(sam.TimerNotification:New("DrainResource", "00FF22", "Drain", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {54608}, true))

gen:AddAlert(sam.ActiveNotification:New(nil, nil, "LavaGeyser", "ff3019", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {112063}, "Geyser, dodge!", 2000, true))
gen:AddAlert(sam.ActiveNotification:New(nil, nil, "Rake", "00FFFF", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {111339}, "Hackwing Rake Inc", 2000, false))

sam.generalAlerts = gen

