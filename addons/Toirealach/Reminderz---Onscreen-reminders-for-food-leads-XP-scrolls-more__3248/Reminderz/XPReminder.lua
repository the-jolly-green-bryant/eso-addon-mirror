XPReminder = {
	textColor = Colorz.lightBlue,
	reminder = TBO_Reminder:New(Reminderz.name),
	dontRemindInHouses = false
}

-- List of abilityIDs of known XP scrolls & potions

local xpBuffs = {
	[1] = 63570, -- Unknown - Increased Experience
	[2] = 64210, -- Unknown - Increased Experience
	[3] = 66776, -- Crown Experience Scroll
	[4] = 85501, -- Gold Coast Experience Scroll
	[5] = 85502, -- Major Gold Coast Experience Scroll
	[6] = 85503, -- Grand Gold Coast Experience Scroll
	[7] = 88445, -- Mythic Aetherial Ambrosia
	[8] = 89683, -- Aetherial Ambrosia
	[9] = 99462, -- Unknown - Increased Experience
	[10] = 99463, -- Unknown - Increased Experience
}

-- Seems all XP scrolls and potions all ahve the same Ability Name, 
-- which is "Increased Experience" in English. So I'm just going to get
-- the name of a known XP abiltiy, the one for Crown Experience Scrolls.
-- So if a new one is introduced, this should catch it.

local xpBuffName = GetAbilityName(xpBuffs[1])

local function XPScrollIndxFor(id)
	for key, value in pairs(xpBuffs) do
        if value == id then return key end
    end
    return 0
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- GetActiveXPBuff(): returns the active XP scroll or ambrosia
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

local function GetActiveXPBuff()

	local buffs = GetBuffs()
	
	for c = 1, #buffs do
	
		local id = buffs[c]["abilityId"] or 0
		local name = buffs[c]["buffName"] or ""

		-- Let's look by name as mentioned above also 

		if XPScrollIndxFor(id) > 0 or name == xpBuffName then
			local timeEnding = buffs[c]["timeEnding"] or 0
			local timeStarted = buffs[c]["timeStarted"] or 0
			return c, name, id, timeEnding
		end
	end
	
	return 0, "", 0, 0
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- reminderPeriodic(): called by the reminder's periodic object
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
--
-- A reminder's periodic function should always first call the reminder's ShouldRemind()
-- function and stop all reminder processing if that function returns false.
-- 
-- If it returns true, the reminder's periodic function should create one or two
-- reminder strings to be announced.
--
-- Then tell the reminder object to do the reminder with the one or two reminder
-- strings that this function has produced.
--
-- It is alocal function rather than a function of the table so only the table
-- can call it from its Start() function. See below.

local function reminderPeriodic()
	
	if XPReminder.reminder:ShouldRemind() == false then 
		return -- Don't remind unless it's time
	elseif XPReminder.dontRemindInHouses == true and GetCurrentZoneHouseId() ~= 0 then return end -- Don't remind while they are in their house

	local currentXPIndex, currentXPName, currentXPID, timeEnding = GetActiveXPBuff()	
			
	local remindStr = nil
	local formatStr = nil
	
	if currentXPID == 0 then 
		formatStr = Reminderz.Localization.NO_XP_SCROLL or "You have no experience scroll active!"
		remindStr = string.format(formatStr, currentXPName)
	else
		local nowSecs = GetGameTimeMilliseconds()/1000
		
		local remainSecs = timeEnding - nowSecs
		if remainSecs > XPReminder.reminder:FirstReminderInSeconds() then return end -- No reminder now, thanks
		
		local timeStr = FormatTimeSeconds(remainSecs, 
											TIME_FORMAT_STYLE_SHOW_LARGEST_UNIT_DESCRIPTIVE, 
											TIME_FORMAT_PRECISION_SECONDS, 
											TIME_FORMAT_DIRECTION_DESCENDING)
	
		local formatStr = Reminderz.Localization.XP_SCROLL_ENDING or "Your experience scroll is ending in %s"
		remindStr = string.format(formatStr, timeStr) 
	end
	
	remindStr = XPReminder.textColor:Colorize(remindStr)

	XPReminder.reminder:Remind(remindStr, nil)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- XPReminder.Start(): Start up XP scroll reminders
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

function XPReminder.Start(inReminderIntervalInSecs, inFirstReminderInMinutes, inColorDef)
	XPReminder.reminder.echoToChat = Reminderz.settings.remindersToChat
	XPReminder.textColor = inColorDef or Colorz.lightBlue
	XPReminder.reminder:Start(reminderPeriodic, inReminderIntervalInSecs, inFirstReminderInMinutes) 
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- XPReminder.Stop(): Stop XP scroll reminders
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

function XPReminder.Stop()
	XPReminder.reminder:Stop()
end

SLASH_COMMANDS["/bufflist"] = function(extra)

	local buffs = GetBuffs()
	for c = 1, #buffs do
		local id = buffs[c]["abilityId"] or 0
		local name = buffs[c]["buffName"] or ""
	    d(string.format("Buff ID %d: %s", id, name))
	end
end