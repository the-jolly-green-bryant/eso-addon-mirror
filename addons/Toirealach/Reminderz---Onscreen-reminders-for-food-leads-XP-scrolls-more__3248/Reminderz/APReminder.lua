APReminder = {
	textColor = Colorz.gold,
	reminder = TBO_Reminder:New(Reminderz.name),
	dontRemindInHouses = false
}

-- List of abilityIDs of known AP scrolls & potions

local APBuffs = {
	[1] = 137733, -- Unknown, 'Alliance Skill Gain, Major'
	[2] = 147466, -- Alliance War Skill Line Scroll aka 'Alliance Skill Gain'
	[3] = 147467, -- -- Unknown, 'Alliance Skill Gain, Grand'
	[4] = 147687, -- Colovian War Torte aka 'Alliance Skill Gain 50% Boost'
	[5] = 147733, -- Molten War Torte? aka 'Alliance Skill Gain 100% Boost'
	[6] = 147734, -- White-Gold War Torte? aka 'Alliance Skill Gain 150% Boost'
	[7] = 147797, -- Unknown, 'Alliance Skill Gain 150% Boost'
}

-- Seems all AP scrolls and potions all have the same prefix to their Ability Name, 
-- which is "Alliance Skill Gain" in English.

local APBuffNamePrefix = GetAbilityName(147466) -- "Alliance Skill Gain"

local function APTorteIndxFor(id)
	for key, value in pairs(APBuffs) do
        if value == id then return key end
    end
    return 0
end

local function GetActiveAPBuff()

	local buffs = GetBuffs()
	
	for c = 1, #buffs do
	
		local id = buffs[c]["abilityId"] or 0
		local name = buffs[c]["buffName"] or ""
		local prefix = string.find(name, APBuffNamePrefix)

		-- Let's look by name as mentioned above also 

		if APTorteIndxFor(id) > 0 or prefix then
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
	
	if APReminder.reminder:ShouldRemind() == false then return end -- Don't remind unless it's time
	if APReminder.reminder:ShouldRemind() == false then 
		return -- Don't remind unless it's time
	elseif APReminder.dontRemindInHouses == true and GetCurrentZoneHouseId() ~= 0 then return end -- Don't remind while they are in their house

	local currentAPIndex, currentAPName, currentAPID, timeEnding = GetActiveAPBuff()	
			
	local remindStr = nil
	local formatStr = nil
	
	if currentAPID == 0 then 
		local formatStr = Reminderz.Localization.WAR_TORTES_MISSING or "You have no war torte active!"
		remindStr = string.format(formatStr, currentAPName)
	else
		local nowSecs = GetGameTimeMilliseconds()/1000
		
		local remainSecs = timeEnding - nowSecs
		if remainSecs > APReminder.reminder:FirstReminderInSeconds() then return end -- no reminder yet
		
		local timeStr = FormatTimeSeconds(remainSecs, 
											TIME_FORMAT_STYLE_SHOW_LARGEST_UNIT_DESCRIPTIVE, 
											TIME_FORMAT_PRECISION_SECONDS, 
											TIME_FORMAT_DIRECTION_DESCENDING)
	
		local formatStr = Reminderz.Localization.WAR_TORTES_RUNNING_OUT or "Your war torte is ending in %s"
		remindStr = string.format(formatStr, timeStr) 
	end
	
	remindStr = APReminder.textColor:Colorize(remindStr)

	APReminder.reminder:Remind(remindStr, nil)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- APReminder.Start(): Start up XP scroll reminders
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

function APReminder.Start(inReminderIntervalInSecs, inFirstReminderInMinutes, inColorDef)
	APReminder.reminder:SetPrefix(Reminderz.name)	
	APReminder.reminder:EchoToChat(Reminderz.settings.remindersToChat)
	APReminder.textColor = inColorDef or Colorz.lightOrange
	APReminder.reminder:Start(reminderPeriodic, inReminderIntervalInSecs, inFirstReminderInMinutes) 
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- APReminder.Stop(): Stop XP scroll reminders
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

function APReminder.Stop()
	APReminder.reminder:Stop()
end
