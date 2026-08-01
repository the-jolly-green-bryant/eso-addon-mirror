-- SPDX-FileCopyrightText: © 2020 @ibex.rc
-- SPDX-License-Identifier: MPL-2.0

local AddOn = EventTicketNotifier

-- Shorthand to retrieve the amount of tickets currently held by the
-- player.
function AddOn.CountAccountTickets()
	return GetCurrencyAmount(CURT_EVENT_TICKETS, CURRENCY_LOCATION_ACCOUNT)
end

-- Return whether the given amount of tickets fills the event ticket bag.
local function IsTicketBagFull(amount)
	return amount >= AddOn.limits.maxTickets
end

-- Do modular event ticket addition and return true if the result
-- overflows.
local function WillTicketsOverflow(currentAmount, lootedAmount)
	return (AddOn.limits.maxTickets - currentAmount) < lootedAmount
end

-- Notify the user to spend their tickets if their storage is full
-- after receiving some.
function AddOn.CheckSpendableTicketsAfterLoot(oldAmount, newAmount)
	local currentEvent = LibEventData.CurrentEvent()
	if currentEvent == nil then
		-- No event, so tickets can be spent at the moment.
		AddOn.log:Warn("no ongoing event, how did we loot event tickets?")
		return
	end

	-- If the player managed to loot tickets then an event should be
	-- active, and we don't need to check IsImpresarioActive before
	-- sending out a notification.
	local wasFull, isFull = IsTicketBagFull(oldAmount), IsTicketBagFull(newAmount)
	local wouldOverflow = WillTicketsOverflow(oldAmount, currentEvent.maxTicketsPerLoot)
	local willOverflow = WillTicketsOverflow(newAmount, currentEvent.maxTicketsPerLoot)
	if not wasFull and isFull then
		AddOn.log:Info("looted enough event tickets to fill bag, notifying player")
		AddOn.DisplayNotification(ETN_NOTIFICATION_LOOTED_FULL_HEADING, ETN_NOTIFICATION_LOOTED_FULL_MESSAGE)
	elseif not wasFull and willOverflow then
		AddOn.log:Info("looted enough event tickets to reach threshold, notifying player")
		AddOn.DisplayNotification(ETN_NOTIFICATION_LOOTED_NEXT_HEADING, ETN_NOTIFICATION_LOOTED_NEXT_MESSAGE)
	elseif wouldOverflow and not willOverflow then
		AddOn.log:Info("spent enough event tickets to clear for next loot, clearing notification")
		AddOn.ClearNotifications()
	end
end

-- Notify the user to spend their tickets if an event is ongoing and
-- their storage is full or may overflow the next time they receive
-- them.
function AddOn.CheckNowSpendableTickets(currentAmount)
	local currentEvent = LibEventData.CurrentEvent()
	if currentEvent == nil then
		-- No event, so tickets can be spent at the moment.
		AddOn.log:Info("no ongoing event to spend tickets on, bailing out")
		return
	end

	if IsTicketBagFull(currentAmount) then
		AddOn.log:Info("event ticket bag is full, notifying player")
		AddOn.DisplayNotification(ETN_NOTIFICATION_FULL_HEADING, ETN_NOTIFICATION_FULL_MESSAGE)
	elseif WillTicketsOverflow(currentAmount, currentEvent.maxTicketsPerLoot) then
		AddOn.log:Info("event ticket bag will overflow with next loot, notifying player")
		AddOn.DisplayNotification(ETN_NOTIFICATION_NEXT_HEADING, ETN_NOTIFICATION_NEXT_MESSAGE)
	end
end

-- Notify the user to spend their tickets if an event will start soon
-- and their storage is full or may overflow the next time they receive
-- them.
function AddOn.CheckSoonSpendableTickets(currentAmount)
	if LibEventData.CurrentEvent() ~= nil then
		-- There is an event going on right now, that is handled
		-- elsewhere.
		AddOn.log:Info("there is an event going on, ignore future events, bailing out")
		return
	end
	local nextEvent = LibEventData.UpcomingEvent(GetTimeStamp(), AddOn.EVENT_LOOKAHEAD_DURATION)
	if nextEvent == nil then
		-- No event happening in the recent future, so no reason to
		-- bother the player.
		AddOn.log:Info("no upcoming event to spend tickets on, bailing out")
		return
	elseif AddOn.upcomingEventNotified then
		-- There is an event about to start, but we already told the
		-- player about it.
		AddOn.log:Info("player already notified about upcoming event, bailing out")
		return
	end
	AddOn.upcomingEventNotified = true

	if IsTicketBagFull(currentAmount) then
		AddOn.log:Info("event ticket bag is full, notifying player")
		AddOn.DisplayNotification(ETN_NOTIFICATION_UPCOMING_FULL_HEADING, ETN_NOTIFICATION_UPCOMING_FULL_MESSAGE)
	elseif WillTicketsOverflow(currentAmount, nextEvent.maxTicketsPerLoot) then
		AddOn.log:Info("event ticket bag will overflow with next loot, notifying player")
		AddOn.DisplayNotification(ETN_NOTIFICATION_UPCOMING_NEXT_HEADING, ETN_NOTIFICATION_UPCOMING_NEXT_MESSAGE)
	end
end
