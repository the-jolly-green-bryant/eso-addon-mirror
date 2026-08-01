-- SPDX-FileCopyrightText: © 2020 @ibex.rc
-- SPDX-License-Identifier: MPL-2.0

local AddOn = EventTicketNotifier

-- Remove a notification off the player's notifications list.
local function RemoveNotification(notification)
	for i, v in ipairs(AddOn.notifier.notifications) do
		if v == notification then
			table.remove(AddOn.notifier.notifications, i)
			AddOn.notifier:UpdateNotifications()
			break
		end
	end
end

-- Display a notification, replacing any notification currently visible.
local function Notify(notification)
	local removeCallback = function () RemoveNotification(notification) end
	notification.keyboardDeclineCallback = removeCallback
	notification.gamepadDeclineCallback = removeCallback
	-- Keep only one notification at a time.
	--table.insert(AddOn.notifier.notifications, notification)
	AddOn.notifier.notifications[1] = notification
	AddOn.notifier:UpdateNotifications()
end

-- Remove all active notifications coming from this addon.
function AddOn.ClearNotifications()
	for k in pairs(AddOn.notifier.notifications) do
		AddOn.notifier.notifications[k] = nil
	end
	AddOn.notifier:UpdateNotifications()
end

-- Display a notification with the given short text (console only) and
-- message.  Both arguments must be translated string constants.
function AddOn.DisplayNotification(heading, text)
	local notification = {
		dataType = NOTIFICATIONS_ALERT_DATA,
		secsSinceRequest = ZO_NormalizeSecondsSince(0),
		heading = GetString(ETN_ADDON_TITLE),
		shortDisplayText = GetString(heading),
		message = GetString(text),
		texture = "/esoui/art/currency/currency_eventticket.dds",
	}
	Notify(notification)
end

local function Initialize()
	AddOn.notifier = LibNotification:CreateProvider()
end

table.insert(AddOn.initializers, Initialize)
