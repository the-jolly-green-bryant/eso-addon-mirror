-- SPDX-FileCopyrightText: © 2020 @ibex.rc
-- SPDX-License-Identifier: MPL-2.0

EventTicketNotifier = {
	-- Name used when registering events.
	ID = "EventTicketNotifier",
	-- Duration (in seconds) to look ahead of the current time in
	-- search of upcoming events to notify about.
	EVENT_LOOKAHEAD_DURATION = 86400,

	-- True during player activation after a login or UI reload, like
	-- the `initial` parameter but extended to the later situation.
	firstActivation = true,
	-- True if the player has been notified of an event that is soon
	-- to start.  Used to avoid spamming them every time the character
	-- travels.
	upcomingEventNotified = false,
	limits = {
		-- Number of tickets a player can hold at once.
		maxTickets = GetMaxPossibleCurrency(CURT_EVENT_TICKETS, CURRENCY_LOCATION_ACCOUNT)
	},

	-- LibDebugLogger logger.
	log = nil,
	-- LibNotifier provider.
	notifier = nil,
	-- Module initializers, called on addon load.
	initializers = {},
}
local AddOn = EventTicketNotifier

local function OnCurrencyUpdate(_event, currencyType, _currencyLocation, newAmount, oldAmount, reason)
	AddOn.log:Debug("handling OnCurrencyUpdate event", _event, "with params:", currencyType, _currencyLocation, newAmount, oldAmount, reason)
	if currencyType ~= CURT_EVENT_TICKETS then
		-- Not event tickets.
		return
	end
	if reason == CURRENCY_CHANGE_REASON_PLAYER_INIT then
		-- We're booting up, not a real transaction.
		return
	end
	if newAmount == oldAmount then
		-- Nothing changed?
		return
	end

	AddOn.log:Info("change in event tickets balance (from %d to %d, reason %d)", oldAmount, newAmount, reason)
	AddOn.CheckSpendableTicketsAfterLoot(oldAmount, newAmount)
end

local function OnPlayerActivated(_event, _initial)
	AddOn.log:Debug("handling OnPlayerActivated event", _event, "with params:", _initial)
	local numTickets = AddOn.CountAccountTickets()
	-- Some notifications are only run directly after login or UI reload.
	if AddOn.firstActivation then
		AddOn.firstActivation = false
		AddOn.log:Info("checking whether to spend tickets for current event")
		AddOn.CheckNowSpendableTickets(numTickets)
	end
	-- Others are run whenever the player travels.
	AddOn.log:Info("checking whether to spend tickets for upcoming event")
	AddOn.CheckSoonSpendableTickets(numTickets)
end

local function OnAddOnLoaded(_event, addonName)
	AddOn.log = LibDebugLogger(AddOn.ID)
	AddOn.log:Debug("handling OnAddOnLoaded event", _event, "with params:", addonName)
	if addonName ~= AddOn.ID then return end
	for _, callback in ipairs(AddOn.initializers) do
		callback()
	end
end

local function Initialize()
	EVENT_MANAGER:RegisterForEvent(AddOn.ID, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
	EVENT_MANAGER:RegisterForEvent(AddOn.ID, EVENT_CURRENCY_UPDATE, OnCurrencyUpdate)
end

table.insert(AddOn.initializers, Initialize)
EVENT_MANAGER:RegisterForEvent(AddOn.ID, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
