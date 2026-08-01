-- SPDX-FileCopyrightText: © 2020 @ibex.rc
-- SPDX-License-Identifier: MPL-2.0

LibEventData = {}

-- Cache of the latest current event.
local cachedCurrentEvent = nil

-- Is the given event going on right now?
local function isOngoingEvent(event)
	local now = GetTimeStamp()
	return (GetDiffBetweenTimeStamps(event.beginsAt, now) <= 0) and (GetDiffBetweenTimeStamps(event.endsAt, now) > 0)
end

-- Return the entry for the current event in the events table, or
-- `nil` if no event is currently active.
function LibEventData.CurrentEvent()
	if cachedCurrentEvent == nil or (not isOngoingEvent(cachedCurrentEvent)) then
		-- We need to refresh the cache.
		for _, event in ipairs(LibEventData.events) do
			if isOngoingEvent(event) then
				cachedCurrentEvent = event
				break
			end
		end
	end
	return cachedCurrentEvent
end

-- Return the next event to happen after the given instant, or `nil`
-- if no event exists that matches the constraints.
--
-- For example, to find the next event to happen within 24 hours of
-- now, do:
--
--     nextEvent = LibEventData.UpcomingEvent(GetTimeStamp(), 86400)
function LibEventData.UpcomingEvent(beginningAfter, scanDuration)
	for _, event in ipairs(LibEventData.events) do
		if (event.beginsAt > beginningAfter) and ((event.beginsAt - beginningAfter) <= scanDuration) then
			return event
		end
	end
end
