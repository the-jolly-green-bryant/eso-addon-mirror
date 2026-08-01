--[[
This Add-on is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its affiliates. 
The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. 
All rights reserved

You can read the full terms at https://account.elderscrollsonline.com/add-on-terms]]

-- Initialized the addon names
RemindMe = {}
RemindMe.name = "RemindMe"
RemindMe.version = 12.0

RemindMe.reminders = {}
RemindMe.playerAlliance = nil
RemindMe.playerZoneId = nil

RemindMe.keeps = {
    [3] = "Fort Warden",
    [4] = "Fort Rayles",
    [5] = "Fort Glademist",
    [6] = "Fort Ash",
    [7] = "Fort Aleswell",
    [8] = "Fort Dragonclaw",
    [9] = "Chalman Keep",
    [10] = "Arrius Keep",
    [11] = "Kingscrest Keep",
    [12] = "Farragut Keep",
    [13] = "Blue Road Keep",
    [14] = "Drakelowe Keep",
    [15] = "Castle Alessia",
    [16] = "Castle Faregyl",
    [17] = "Castle Roebeck",
    [18] = "Castle Brindle",
    [19] = "Castle Black Boot",
    [20] = "Castle Bloodmayne",
    [22] = "Castle Bloodmayne Farm",
    [23] = "Castle Bloodmayne Mine",
    [24] = "Castle Bloodmayne Lumbermill",
    [34] = "Castle Black Boot Lumbermill",
    [35] = "Castle Black Boot Mine",
    [36] = "Castle Black Boot Farm",
    [37] = "Farragut Keep Lumbermill",
    [38] = "Farragut Keep Mine",
    [39] = "Farragut Keep Farm",
    [40] = "Fort Warden Farm",
    [41] = "Fort Warden Lumbermill",
    [42] = "Fort Warden Mine",
    [43] = "Castle Faregyl Farm",
    [44] = "Castle Faregyl Lumbermill",
    [45] = "Castle Faregyl Mine",
    [46] = "Arrius Keep Farm",
    [47] = "Arrius Keep Lumbermill",
    [48] = "Arrius Keep Mine",
    [49] = "Fort Glademist Farm",
    [50] = "Fort Glademist Lumbermill",
    [51] = "Fort Glademist Mine",
    [52] = "Kingscrest Keep Farm",
    [53] = "Kingscrest Keep Lumbermill",
    [54] = "Kingscrest Keep Mine",
    [55] = "Fort Rayles Farm",
    [56] = "Fort Rayles Lumbermill",
    [57] = "Fort Rayles Mine",
    [61] = "Fort Ash Farm",
    [62] = "Fort Ash Lumbermill",
    [63] = "Fort Ash Mine",
    [64] = "Fort Aleswell Mine",
    [65] = "Fort Aleswell Lumbermill",
    [66] = "Fort Aleswell Farm",
    [67] = "Fort Dragonclaw Mine",
    [68] = "Fort Dragonclaw Lumbermill",
    [69] = "Fort Dragonclaw Farm",
    [70] = "Chalman Keep Mine",
    [71] = "Chalman Keep Lumbermill",
    [72] = "Chalman Keep Farm",
    [73] = "Blue Road Keep Mine",
    [74] = "Blue Road Keep Lumbermill",
    [75] = "Blue Road Keep Farm",
    [76] = "Drakelowe Keep Mine",
    [77] = "Drakelowe Keep Lumbermill",
    [78] = "Drakelowe Keep Farm",
    [79] = "Castle Alessia Mine",
    [80] = "Castle Alessia Lumbermill",
    [81] = "Castle Alessia Farm",
    [82] = "Castle Roebeck Mine",
    [83] = "Castle Roebeck Lumbermill",
    [84] = "Castle Roebeck Farm",
    [85] = "Castle Brindle Mine",
    [86] = "Castle Brindle Lumbermill",
    [87] = "Castle Brindle Farm",
    [132] = "Nikel Outpost",
    [133] = "Sejanus Outpost",
    [134] = "Bleaker's Outpost",
    [149] = "Vlastarus",
    [151] = "Bruma",
    [152] = "Cropsford",
	[163] = "Winter's Peak Outpost",
	[164] = 'Carmala Outpost',
	[165] = "Harlun's Outpost"
}

-- Saved beyond session variables
RemindMe.defaults={
	recurringReminders = {},
	nextTimeOnlineReminder = ''
}

function RemindMe:Initialize()
	RemindMe.playerAlliance = GetUnitAlliance('player')

	EVENT_MANAGER:RegisterForUpdate(RemindMe.name, 1000, RemindMe.checkForReminders)
	EVENT_MANAGER:RegisterForEvent(RemindMe.name, EVENT_KEEP_ALLIANCE_OWNER_CHANGED, RemindMe.keepAllianceOwnerChanged)
	EVENT_MANAGER:RegisterForEvent(RemindMe.name, EVENT_ZONE_CHANGED, RemindMe.onZoneUpdate)
	EVENT_MANAGER:RegisterForEvent(RemindMe.name, EVENT_PLAYER_ACTIVATED, RemindMe.OnPlayerActivated)
end

-- Loads the addon; only hit once
function RemindMe.OnAddOnLoaded(event, addonName)
	-- The event fires each time *any* addon loads; but we only care about when our own addon loads.
	if addonName ~= RemindMe.name then
		return
	end

	RemindMe.SV = ZO_SavedVars:New("RemindMeTrackerSettings", 1.0, "Settings", RemindMe.defaults)

	EVENT_MANAGER:UnregisterForEvent(RemindMe.name, EVENT_ADD_ON_LOADED)

	RemindMe:Initialize()
	RemindMe:SetUpCommands()
	RemindMe.checkForClearing()
end

function RemindMe.OnPlayerActivated(eventCode, initial)
	if RemindMe.SV.nextTimeOnlineReminder ~= '' then
		RemindMe.showReminder(RemindMe.SV.nextTimeOnlineReminder)
		RemindMe.SV.nextTimeOnlineReminder = ''
	end
end

function RemindMe.ScreenNotification(message)
	local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.NONE)
	messageParams:SetText(message)
	messageParams:SetLifespanMS(3000)
	CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
end

function RemindMe:SetUpCommands()
	SLASH_COMMANDS["/remindme"] = function (extra)
		local pieces = RemindMe.string_split(extra)

		if #pieces <= 1 then
			d("RemindMe: Need to set first when to remind yourself, then the message, then optionally if this should be recurring.")
			return
		end

		local timing = string.lower(pieces[1])
		local recurring = pieces[#pieces]

		local message = string.sub(extra, string.len(timing)+2)

		if recurring == 'recurring' then
			message = string.sub(extra, string.len(timing)+2, (string.len(extra)-string.len(recurring)))
		else
			recurring = 'single'
		end

		--[[d(timing)
		d(message)
		d(recurring)]]

		local timingMatch = string.match(timing, '%d+m')

		if timingMatch == nil then
			timingMatch = string.match(timing, '%d+s')

			if timingMatch ~= nil then
				timingMatch = tonumber(string.sub(timingMatch, 0, string.len(timingMatch)-1))
			end
		else
			timingMatch = tonumber(string.sub(timingMatch, 0, string.len(timingMatch)-1)) * 60
		end

		if timing == 'capture' then
			timingMatch = timing
		end

		if timing == 'login' then
			timingMatch = timing
		end

		if timingMatch == nil then
			d("RemindMe Error: Unable to figure out when to remind you.")
			return
		end

		if recurring == 'single' then
			RemindMe.addSingleReminder(timingMatch, message)
		elseif recurring == 'recurring' then
			RemindMe.addRecurringReminder(timingMatch, message)
		end
	end

	SLASH_COMMANDS["/remindmeremove"] = function (extra)
		if next(RemindMe.SV.recurringReminders) == nil then
			d("RemindMe: No recurring reminders have been set-up!")
			return
		end

		local pieces = RemindMe.string_split(extra)

		if #pieces < 1 then
			d("RemindMe: Need the index of the reminder you are removing. If you'd like to remove all of them, write 'all'.")
			return
		end

		if string.lower(extra) == 'all' then
			RemindMe.SV.recurringReminders = {}
		else
			for index, remindInfo in pairs(RemindMe.SV.recurringReminders) do
				if tostring(index) == tostring(extra) then
					if remindInfo.used == false then
						d("RemindMe: Successfully removed recurring reminder.")
						remindInfo.used = true
					end

					break
				end
			end
		end
	end
	
	SLASH_COMMANDS["/remindmelist"] = function (extra)
		if next(RemindMe.SV.recurringReminders) == nil then
			d("RemindMe: No recurring reminders have been set-up!")
			return
		end

		d("RemindMe: The following is a list of recurring reminders you have set-up:")

		for index, remindInfo in pairs(RemindMe.SV.recurringReminders) do
			if remindInfo.used == false then
				d(index .. ": " .. remindInfo.message .. " ("..remindInfo.timing..")")
			end
		end
	end

	SLASH_COMMANDS["/remindmehelp"] = function (extra)
		d("Do '/remindme' to begin. Then how long to wait between reminders; for example, 10m for 10 minutes, 20s for 20 seconds, capture for a keep / resource capture (PVP), or login for the next time you log in (or reloadui). Then the message itself. Then, optionally, whether to make the reminder recurring (does not work on capture or login reminders). Some example commands include: '/remindme 10m go to the bank', '/remindme 30m go capture a resource recurring', '/remindme capture go pick up some siege', '/remindme login Transmute healing gear'.")
	end
end

function RemindMe.string_split(string, pattern)
	pattern = pattern or "%S+"
	local array = {}

	for i in string.gmatch(string, pattern) do
		table.insert(array, i)
	end

	return array
end

function RemindMe.checkForClearing()
	if next(RemindMe.reminders) == nil and next(RemindMe.SV.recurringReminders) == nil then
		return
	end

	local allClear = true

	for index, remindInfo in pairs(RemindMe.reminders) do
		if remindInfo.used == false then
			allClear = false
			break
		end
	end

	if allClear == true then
		RemindMe.reminders = {}
	end

	allClear = true

	for index, remindInfo in pairs(RemindMe.SV.recurringReminders) do
		if remindInfo.used == false then
			allClear = false
			break
		end
	end

	if allClear == true then
		RemindMe.SV.recurringReminders = {}
	end
end

function RemindMe.addSingleReminder(timing, message)
	d("RemindMe: A reminder has been added!")

	if timing == 'login' then
		RemindMe.SV.nextTimeOnlineReminder = message
		return
	end

	local defaultArray = {}

	defaultArray.timing = timing
	defaultArray.message = message
	defaultArray.startTime = os.time()
	defaultArray.used = false

	RemindMe.reminders[#RemindMe.reminders + 1] = defaultArray
end

function RemindMe.addRecurringReminder(timing, message)
	local defaultArray = {}

	defaultArray.timing = timing
	defaultArray.message = message
	defaultArray.startTime = os.time()
	defaultArray.used = false

	local index = #RemindMe.SV.recurringReminders + 1

	RemindMe.SV.recurringReminders[index] = defaultArray

	d("RemindMe: A recurring reminder has been added! To remove it, do '/remindmeremove " .. index .. "'.")
end

function RemindMe.checkForReminders()
	if next(RemindMe.reminders) == nil and next(RemindMe.SV.recurringReminders) == nil then
		return
	end

	for index, remindInfo in pairs(RemindMe.reminders) do
		if remindInfo.used == false then
			local timingMatch = string.match(remindInfo.timing, '%d+')

			if timingMatch ~= nil then
				local difference = -(os.difftime(remindInfo.startTime, os.time()))

				if tonumber(difference) >= tonumber(timingMatch) then
					remindInfo.used = true
					RemindMe.showReminder(remindInfo.message)
				end
			end
		end
	end

	for index, remindInfo in pairs(RemindMe.SV.recurringReminders) do
		if remindInfo.used == false then
			local timingMatch = string.match(remindInfo.timing, '%d+')

			if timingMatch ~= nil then
				local difference = -(os.difftime(remindInfo.startTime, os.time()))

				if tonumber(difference) >= tonumber(timingMatch) then
					remindInfo.startTime = os.time()
					RemindMe.showReminder(remindInfo.message)
				end
			end
		end
	end
end

function RemindMe.keepAllianceOwnerChanged(eventCode, keepId, battlegroundContext, owningAlliance, oldOwningAlliance)
--d("Inside keepAllianceOwnerChanged: "..tostring(keepId).." "..tostring(owningAlliance).." "..tostring(RemindMe.playerZoneId))
	if owningAlliance ~= RemindMe.playerAlliance or keepId ~= RemindMe.playerZoneId then
		return
	end

	if next(RemindMe.reminders) == nil and next(RemindMe.SV.recurringReminders) == nil then
		return
	end

	for index, remindInfo in pairs(RemindMe.reminders) do
		if remindInfo.used == false and remindInfo.timing == 'capture' then
			remindInfo.used = true
			RemindMe.showReminder(remindInfo.message)
		end
	end

	for index, remindInfo in pairs(RemindMe.SV.recurringReminders) do
		if remindInfo.used == false and remindInfo.timing == 'capture' then
			RemindMe.showReminder(remindInfo.message)
		end
	end
end

function RemindMe.getKeepId(lookingKeepName)
	for keepId, keepName in pairs(RemindMe.keeps) do
		if keepName == lookingKeepName then
			return keepId
		end
	end

	return nil
end

function RemindMe.onZoneUpdate(eventCode, zoneName, subZoneName, newSubzone, zoneId, subZoneId)
	RemindMe.playerZoneId = RemindMe.getKeepId(subZoneName)
end

function RemindMe.showReminder(message)
	RemindMe.ScreenNotification(message)
	d("RemindMe: " .. message)
	RemindMe.checkForClearing()
end

-- so that ESO can register the addon
EVENT_MANAGER:RegisterForEvent(RemindMe.name, EVENT_ADD_ON_LOADED, RemindMe.OnAddOnLoaded)