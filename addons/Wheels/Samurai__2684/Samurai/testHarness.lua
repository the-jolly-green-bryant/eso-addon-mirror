-------------------------------------------------------------------------------
-- Contains various tests that can be run to experiment with UI or simulate
-- different combat situations to make sure the addon functions as expected
-------------------------------------------------------------------------------

SAMURAI = SAMURAI or { }
TEST_HARNESS = TEST_HARNESS or { }
local sam = SAMURAI
local th = TEST_HARNESS
local EM = GetEventManager()

function th.registerNotiTest()
	d("creating...")
	th.noti1 = sam.TimerNotification:New("test1", "FFCC00", "Test 1", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {999999}, true)
	th.noti2 = sam.TimerNotification:New("test2", "00FF00", "Test 2", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {1000000}, true)
	th.noti3 = sam.TimerNotification:New("test3", "0000FF", "Test 3", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {1000001}, false)

	th.a = sam.ActiveNotification:New(nil, nil, "testA", "FFCB00", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {100000000000}, "Test Alert A", 3000, true)
	th.b = sam.ActiveNotification:New(nil, nil, "testB", "FFCB00", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {100000000001}, "Test Alert B", 5000, true)
	th.c = sam.ActiveNotification:New(nil, nil, "testC", "FFCB00", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {100000000002}, "Test Alert C", 3000, true)

	d("registering...")
	th.noti1:Register()
	th.noti2:Register()
	th.noti3:Register()

	th.a:Register()
	th.b:Register()
	th.c:Register()
end

function th.unregisterNotiTest()
	th.noti1:Unregister()
	th.noti2:Unregister()
	th.noti3:Unregister()

	th.a:Unregister()
	th.b:Unregister()
	th.c:Unregister()
end

function th.timedNotiTest()


	d("running...")
	th.noti1:Handler(nil, ACTION_RESULT_BEGIN, nil, nil, nil, nil, nil, nil, nil, COMBAT_UNIT_TYPE_PLAYER, 12200, nil, nil, nil, nil, nil, 999999)
	--th.noti1:Handler(nil, ACTION_RESULT_BEGIN, nil, nil, nil, nil, nil, nil, nil, COMBAT_UNIT_TYPE_PLAYER, 13900, nil, nil, nil, nil, nil, 999999)
	--th.noti1:Handler(nil, ACTION_RESULT_BEGIN, nil, nil, nil, nil, nil, nil, nil, COMBAT_UNIT_TYPE_PLAYER, 12300, nil, nil, nil, nil, nil, 999999)
	th.noti2:Handler(nil, ACTION_RESULT_BEGIN, nil, nil, nil, nil, nil, nil, nil, COMBAT_UNIT_TYPE_PLAYER, 8200, nil, nil, nil, nil, nil, 1000000)
	--th.noti2:Handler(nil, ACTION_RESULT_BEGIN, nil, nil, nil, nil, nil, nil, nil, COMBAT_UNIT_TYPE_PLAYER, 21900, nil, nil, nil, nil, nil, 1000000)
	--th.noti2:Handler(nil, ACTION_RESULT_BEGIN, nil, nil, nil, nil, nil, nil, nil, COMBAT_UNIT_TYPE_PLAYER, 9200, nil, nil, nil, nil, nil, 1000000)
	th.noti3:Handler(nil, ACTION_RESULT_BEGIN, nil, nil, nil, nil, nil, nil, nil, nil, 15400, nil, nil, nil, nil, nil, 1000001)
	--th.noti3:Handler(nil, ACTION_RESULT_BEGIN, nil, nil, nil, nil, nil, nil, nil, COMBAT_UNIT_TYPE_PLAYER, 11800, nil, nil, nil, nil, nil, 1000001)
	--th.noti3:Handler(nil, ACTION_RESULT_BEGIN, nil, nil, nil, nil, nil, nil, nil, COMBAT_UNIT_TYPE_PLAYER, 22500, nil, nil, nil, nil, nil, 1000001)

	--d("unregistering...")
	--th.noti1:Unregister()
	--th.noti2:Unregister()
	--th.noti3:Unregister()

	th.a:Handler(nil, ACTION_RESULT_BEGIN, nil, nil, nil, nil, nil, nil, nil, COMBAT_UNIT_TYPE_PLAYER, 12200, nil, nil, nil, nil, nil, 999999)
	th.b:Handler(nil, ACTION_RESULT_BEGIN, nil, nil, nil, nil, nil, nil, nil, COMBAT_UNIT_TYPE_PLAYER, 12200, nil, nil, nil, nil, nil, 999999)
	zo_callLater(function() th.c:Handler(nil, ACTION_RESULT_BEGIN, nil, nil, nil, nil, nil, nil, nil, COMBAT_UNIT_TYPE_PLAYER, 12200, nil, nil, nil, nil, nil, 999999) end, 3400)

	d("done")
end

local function combatHandler(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
	sam.debug("source: %s %d, target: %s %d, result: %d", tostring(sourceName), sourceUnitId, tostring(targetName), targetUnitId, result)
end

function th.registerCombatHandler(state)
	sam.debug("fired")
	if state == "true" then
		sam.debug("registering")
		EM:RegisterForEvent("TestHarnessCombatHandler", EVENT_COMBAT_EVENT, combatHandler)
	else
		sam.debug("unregistering")
		EM:UnregisterForEvent("TestHarnessCombatHandler", EVENT_COMBAT_EVENT)
	end
end

function sam.setupTestHarness()
	SLASH_COMMANDS["/registertimedtest"] = th.registerNotiTest
	SLASH_COMMANDS["/unregistertimedtest"] = th.unregisterNotiTest
	SLASH_COMMANDS["/testtimedalerts"] = th.timedNotiTest
	SLASH_COMMANDS["/thcombatevents"] = th.registerCombatHandler
end
