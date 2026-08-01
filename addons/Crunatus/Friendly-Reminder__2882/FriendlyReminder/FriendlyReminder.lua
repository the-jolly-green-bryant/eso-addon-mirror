local addon = {
	name = "FriendlyReminder",
	displayName = "Friendly Reminder",
	savedVars = {
		showonce = false,
		showinchat = true,
		showonscreen = false,
		sendnotification = false,
		starttime = 0,
		timeStamp = 0,
		text = {
			week = {},
			month ={},
		},
	},
}

local RINGING_BELL_TEXTURE = "FriendlyReminder/ringing-bell.dds"

local DAYS_PER_MONTH_REGULAR_YEAR = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
local DAYS_PER_MONTH_LEAP_YEAR = {31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}

function addon.IsLeapYear(year)
	return year % 4 == 0 and (year % 100 ~= 0 or year % 400 == 0)
end

function addon.LoadSettings()
	local LAM = LibAddonMenu2
	local year = tonumber(os.date("%Y"))		-- 2020
	
	 local panelData = {
		type = "panel",
		name = addon.displayName,
		author = "@Crunatus",
		version = "1.3",
		slashCommand = "/reminder",
		registerForRefresh = true,
		registerForDefaults = true,
	 }
	
	local optionsTable = {}

	-- For each day of the week, Monday till Sunday		
	optionsTable[#optionsTable+1] = {
		type = "submenu",
		name = GetString(SI_QUESTREPEATABLETYPE2),		-- "Daily"
		controls = {},
	}

	for day = 1, 7 do
		optionsTable[#optionsTable].controls[day] = {
			type = "editbox",
			name = GetString("SI_FRIENDLYREMINDER_WEEKDAY", day),		-- "Monday"
			getFunc = function() return addon.savedVars.text.week[day] end,
			setFunc = function(text) addon.savedVars.text.week[day] = text end,
			isMultiline = false,
			default = "",
		}
	end
	
	-- Delete ALL daily reminders
	optionsTable[#optionsTable].controls[8] = {
		type = "button",
		name = GetString(SI_MAIL_SEND_CLEAR),		-- "Clear"
		func = function() addon.savedVars.text.week = {} end,
		isDangerous = true,
		warning = GetString(SI_FRIENDLYREMINDER_DELETE_DAILY),
	}

	-- For each month, January till December
	for month = 1, 12 do
		optionsTable[#optionsTable+1] = {
			type = "submenu",
			name = GetString("SI_FRIENDLYREMINDER_MONTH", month),		-- "January"
			controls = {},
		}
		
		local daysPerMonth = addon.IsLeapYear(year) and DAYS_PER_MONTH_LEAP_YEAR[month] or DAYS_PER_MONTH_REGULAR_YEAR[month]
		
		for day = 1, daysPerMonth do
			local timeStamp = os.time({year = year, month = month, day = day})
			local datetime = os.date("*t", timeStamp)
			local wday = datetime.wday == 1 and 7 or datetime.wday - 1
		
			optionsTable[#optionsTable].controls[day] = {
				type = "editbox",
				name = string.format("%s. %s", day, GetString("SI_FRIENDLYREMINDER_WEEKDAY", wday)),
				getFunc = function() 
					if addon.savedVars.text.month[month] then
						return addon.savedVars.text.month[month][day] or ""
					end
				end,
				setFunc = function(text)
					addon.savedVars.text.month[month] = addon.savedVars.text.month[month] or {}
					addon.savedVars.text.month[month][day] = text
				end,
				isMultiline = false,
				default = "",
			}
		end
		
		-- Delete ALL reminders for month
		optionsTable[#optionsTable].controls[daysPerMonth + 1] = {
			type = "button",
			name = GetString(SI_MAIL_SEND_CLEAR),		-- "Clear"
			func = function() addon.savedVars.text.month[month] = {} end,
			isDangerous = true,
			warning = string.format(GetString(SI_FRIENDLYREMINDER_DELETE_MONTH), GetString("SI_FRIENDLYREMINDER_MONTH", month))
		}
	end

	-- Show reminder only once a day
	optionsTable[#optionsTable+1] = {
		type = "checkbox",
		name = GetString(SI_FRIENDLYREMINDER_SHOW_ONCE),
		tooltip = GetString(SI_FRIENDLYREMINDER_SHOW_ONCE_DESC),
		getFunc = function() return addon.savedVars.showonce end,
		setFunc = function(value) addon.savedVars.showonce = value end,
		default = false,
	}

	-- Show a message in the chat window
	optionsTable[#optionsTable+1] = {
		type = "checkbox",
		name = GetString(SI_FRIENDLYREMINDER_SHOW_CHAT),
		tooltip = GetString(SI_FRIENDLYREMINDER_SHOW_CHAT_DESC),
		getFunc = function() return addon.savedVars.showinchat end,
		setFunc = function(value) addon.savedVars.showinchat = value end,
		default = true,
	}
	
	-- Show announcement on the screen
	optionsTable[#optionsTable+1] = {
		type = "checkbox",
		name = GetString(SI_FRIENDLYREMINDER_SHOW_ANNOUNCEMENT),
		tooltip = GetString(SI_FRIENDLYREMINDER_SHOW_ANNOUNCEMENT_DESC),
		getFunc = function() return addon.savedVars.showonscreen end,
		setFunc = function(value) addon.savedVars.showonscreen = value end,
		default = false,
	}

	-- Send notification message
	optionsTable[#optionsTable+1] = {
		type = "checkbox",
		name = GetString(SI_FRIENDLYREMINDER_SEND_NOTIFICATION),
		tooltip = GetString(SI_FRIENDLYREMINDER_SEND_NOTIFICATION_DESC),
		getFunc = function() return addon.savedVars.sendnotification end,
		setFunc = function(value) addon.savedVars.sendnotification = value end,
		default = false,
		disabled = function() return LibNotification == nil end
	}
	
	-- Start of the day
	optionsTable[#optionsTable+1] = {
		type = "slider",
		name = GetString(SI_FRIENDLYREMINDER_START_TIME),
		getFunc = function() return addon.savedVars.starttime end,
		setFunc = function(value) addon.savedVars.starttime = value end,
		min = 0,
		max = 23,
		step = 1,
		readOnly = true,
		default = 0,
	}

	LAM:RegisterAddonPanel("FriendlyReminder_LAM", panelData)
	LAM:RegisterOptionControls("FriendlyReminder_LAM", optionsTable)
end

function addon.SendNotification(provider, messageText, noteText)
	local notificationData = {
		dataType = NOTIFICATIONS_ALERT_DATA,
		secsSinceRequest = ZO_NormalizeSecondsSince(0),
		note = noteText,
		message = messageText,
		heading = addon.displayName,
		shortDisplayText = addon.displayName,
		texture = RINGING_BELL_TEXTURE,
		controlsOwnSounds = false,
		keyboardDeclineCallback = function()
			for i = #provider.notifications, 1, -1 do
				if provider.notifications[i].message == messageText then
					table.remove(provider.notifications, i)
					provider:UpdateNotifications()
					break
				end
			end
		end,
		gamepadDeclineCallback =  function()
			for i = #provider.notifications, 1, -1 do
				if provider.notifications[i].message == messageText then
					table.remove(provider.notifications, i)
					provider:UpdateNotifications()
					break
				end
			end
		end,
	}

	table.insert(provider.notifications, notificationData)
end

function addon.ShowAnnouncement(text)
	local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.CHAMPION_POINTS_COMMITTED)
	messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT)
	messageParams:SetText(text)
	CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
end

-- Show a reminder after loading a character
function addon.OnActivated(event)
	EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_PLAYER_ACTIVATED)

	local timeStamp = os.time()
	local datetime = os.date("*t", timeStamp)
	local month = datetime.month
	local day = datetime.day
	local wday = datetime.wday == 1 and 7 or datetime.wday - 1
	
	local dailyMessage = addon.savedVars.text.week[wday] or ""
	local monthlyMessage = addon.savedVars.text.month[month] and addon.savedVars.text.month[month][day] or ""

	if addon.savedVars.showonce then
		if os.date("%x", timeStamp) == os.date("%x", addon.savedVars.timeStamp) then return end
	end

	if (dailyMessage == "" and monthlyMessage == "") or (datetime.hour < addon.savedVars.starttime) then
		return
	end

	if dailyMessage ~= "" then
		if addon.savedVars.showinchat then
			local text = string.format("%s %s: %s", 
				zo_iconFormat(RINGING_BELL_TEXTURE, 24, 24),	-- ringing-bell.dds
				ZO_NORMAL_TEXT:Colorize(GetString("SI_FRIENDLYREMINDER_WEEKDAY", wday)),	-- "Monday:"
				ZO_WHITE:Colorize(dailyMessage))
			d(text)
		end
		
		if addon.savedVars.showonscreen then
			local text = string.format("%s %s: %s", 
				zo_iconFormat(RINGING_BELL_TEXTURE, 48, 48),	-- ringing-bell.dds
				ZO_NORMAL_TEXT:Colorize(GetString("SI_FRIENDLYREMINDER_WEEKDAY", wday)),	-- "Monday:"
				ZO_WHITE:Colorize(dailyMessage))
			addon.ShowAnnouncement(text)
		end
	end

	if monthlyMessage ~= "" then
		if addon.savedVars.showinchat then
			local text = string.format("%s %s: %s", 
				zo_iconFormat(RINGING_BELL_TEXTURE, 24, 24),	-- ringing-bell.dds
				ZO_NORMAL_TEXT:Colorize(os.date("%d.%m.%Y")),		-- "09.05.2020:"
				ZO_WHITE:Colorize(monthlyMessage))
			d(text)
		end
		
		if addon.savedVars.showonscreen then
			local text = string.format("%s %s: %s", 
				zo_iconFormat(RINGING_BELL_TEXTURE, 48, 48),	-- ringing-bell.dds
				ZO_NORMAL_TEXT:Colorize(os.date("%d.%m.%Y")),		-- "09.05.2020:"
				ZO_WHITE:Colorize(monthlyMessage))
			addon.ShowAnnouncement(text)
		end
	end
	
	-- Send custom notification message. Circonians LibNotifications required.
	if LibNotification and addon.savedVars.sendnotification then
		local libNotification = LibNotification
		local provider = libNotification:CreateProvider()

		if dailyMessage ~= "" then
			addon.SendNotification(provider,
				string.format("%s: %s",
					ZO_NORMAL_TEXT:Colorize(GetString("SI_FRIENDLYREMINDER_WEEKDAY", wday)), dailyMessage),
					dailyMessage)
		end
			
		if monthlyMessage ~= "" then
			addon.SendNotification(provider,
				string.format("%s: %s",
					ZO_NORMAL_TEXT:Colorize(os.date("%d.%m.%Y")), monthlyMessage),
					monthlyMessage)
		end
		
		-- It fires off ALL of the BuildNotificationList functions for every notification provider.
		provider:UpdateNotifications()
	end

	addon.savedVars.timeStamp = timeStamp
end

-- When player is ready, after everything has been loaded.
EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_PLAYER_ACTIVATED, addon.OnActivated)

function addon.OnLoaded(event, addonName)
	if addonName ~= addon.name then return end
	EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)

	-- Load saved variables
	addon.savedVars = ZO_SavedVars:NewAccountWide("FriendlyReminderSavedVariables", 1, nil, addon.savedVars)

	-- Load settings menu
	addon.LoadSettings()
end

-- When any addon is loaded
EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, addon.OnLoaded)
