NumbersOnDummyOnly = {}
NumbersOnDummyOnly.name = "NumbersOnDummyOnly"

function NumbersOnDummyOnly.go()
	local settingStatus = GetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_SCROLLING_COMBAT_TEXT_ENABLED)

	if NumbersOnDummyOnly.inHouse then
		-- Only turn it on if it's currently off AND we're not already the one
		-- managing it. This avoids stomping on a value the player set on their
		-- own before hitting the dummy.
		if not NumbersOnDummyOnly.numbersEnabled and settingStatus == "0" then
			SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_SCROLLING_COMBAT_TEXT_ENABLED, "1")
			NumbersOnDummyOnly.numbersEnabled = true
		end
	else
		-- Only turn it back off if WE were the one who turned it on. If the
		-- player has Combat Text enabled as their own general preference,
		-- leaving a house (or any other zone change) must not disable it.
		if NumbersOnDummyOnly.numbersEnabled and settingStatus == "1" then
			SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_SCROLLING_COMBAT_TEXT_ENABLED, "0")
			NumbersOnDummyOnly.numbersEnabled = false
		end
	end
end

-- Named handler (instead of an inline closure) so it's cheap to register/unregister
-- and easy to reason about/debug. Only fires for events that already passed the
-- engine-side dummy filter registered below, so no per-event Lua-side filtering.
function NumbersOnDummyOnly.onDummyCombatEvent()
	if not NumbersOnDummyOnly.numbersEnabled then
		NumbersOnDummyOnly.go()
	end
end

function NumbersOnDummyOnly.inHouseState()
	if GetCurrentZoneHouseId() > 0 then
		NumbersOnDummyOnly.inHouse = true

		EVENT_MANAGER:RegisterForEvent(NumbersOnDummyOnly.name, EVENT_COMBAT_EVENT, NumbersOnDummyOnly.onDummyCombatEvent)
		-- Push the "is this a target dummy?" check down to the client's C-side
		-- event dispatcher instead of doing it in Lua on every combat event.
		-- EVENT_COMBAT_EVENT can fire many times per second in active combat,
		-- so filtering here (rather than inside the callback) avoids invoking
		-- Lua and unpacking event args for every non-dummy hit.
		EVENT_MANAGER:AddFilterForEvent(NumbersOnDummyOnly.name, EVENT_COMBAT_EVENT,
			REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_TARGET_DUMMY)
	else
		NumbersOnDummyOnly.inHouse = false
		NumbersOnDummyOnly.go()
		EVENT_MANAGER:UnregisterForEvent(NumbersOnDummyOnly.name, EVENT_COMBAT_EVENT)
	end
end

EVENT_MANAGER:RegisterForEvent(NumbersOnDummyOnly.name, EVENT_PLAYER_ACTIVATED, function()
	zo_callLater(NumbersOnDummyOnly.inHouseState, 10000)
end)
