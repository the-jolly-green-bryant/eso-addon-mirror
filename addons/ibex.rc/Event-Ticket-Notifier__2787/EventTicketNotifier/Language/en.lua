-- SPDX-FileCopyrightText: © 2020 @ibex.rc
-- SPDX-License-Identifier: MPL-2.0

local strings = {
	ETN_ADDON_TITLE = "Event Ticket Notifier",

	ETN_NOTIFICATION_LOOTED_FULL_HEADING = "Event ticket storage full",
	ETN_NOTIFICATION_LOOTED_FULL_MESSAGE = "You just filled your event ticket bag. Go spend some before collecting more!",

	ETN_NOTIFICATION_LOOTED_NEXT_HEADING = "Event ticket storage almost full",
	ETN_NOTIFICATION_LOOTED_NEXT_MESSAGE = "You will lose tickets if you collect more! Go spend some!",

	ETN_NOTIFICATION_FULL_HEADING = "Event ticket storage full",
	ETN_NOTIFICATION_FULL_MESSAGE = "Your event ticket bag is full as a horker! Go spend them!",

	ETN_NOTIFICATION_NEXT_HEADING = "Event ticket storage almost full",
	ETN_NOTIFICATION_NEXT_MESSAGE = "You will lose tickets if you collect more! Go spend some!",

	ETN_NOTIFICATION_UPCOMING_FULL_HEADING = "Event ticket storage full",
	ETN_NOTIFICATION_UPCOMING_FULL_MESSAGE = "A new event is starting soon, and your event ticket bag is filled to the brim! Go spend some as soon as it begins!",

	ETN_NOTIFICATION_UPCOMING_NEXT_HEADING = "Event ticket storage almost full",
	ETN_NOTIFICATION_UPCOMING_NEXT_MESSAGE = "A new event is starting soon, and your event ticket bag is almost full! Spend some before collecting more!",
}

for key, value in pairs(strings) do
	ZO_CreateStringId(key, value)
	SafeAddVersion(key, 1)
end
