VampReminder = {
	textColor = Colorz.red,
	desiredStage = 0, -- Can be 1,2,3 or 4
	reminder = TBO_Reminder:New(Reminderz.name),
	dontRemindInHouses = false
}

-- VampireStageType
NOT_A_VAMPIRE = 0
VAMPIRE_STAGE_1 = 135397
VAMPIRE_STAGE_2 = 135399
VAMPIRE_STAGE_3 = 135400
VAMPIRE_STAGE_4 = 135402

-- * IsVampire()
-- ** *bool* _isVampire_
function IsVampire()
	return (GetVampireStage() ~= NOT_A_VAMPIRE)
end

-- * GetVampireStage()
-- ** _Returns:_ *VampireStageType* _vampireStage_, *number:nilable* _timeEnding_, *string:nilable* _vampireStageName_, *string:nilable* _iconFileName_
function GetVampireStage()

	for n = 0, GetNumBuffs("player") do
		local buffName, timeStarted, timeEnding, _, _, iconFilename, _, _, abilityType, _, abilityId, _, _ = GetUnitBuffInfo("player", n)
		if (abilityId == VAMPIRE_STAGE_1) or (abilityId == VAMPIRE_STAGE_2) or (abilityId == VAMPIRE_STAGE_3) or (abilityId == VAMPIRE_STAGE_4) then
			return abilityId, timeEnding, buffName, iconFilename 
		end
	end

	return NOT_A_VAMPIRE, nil, nil, nil, nil 
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

	if VampReminder.reminder:ShouldRemind() == false then 
		return -- Don't remind unless it's time
	elseif VampReminder.dontRemindInHouses == true and GetCurrentZoneHouseId() ~= 0 then return end -- Don't remind while they are in their house

	local stage, timeEnding, stageName, iconFilename  = GetVampireStage()
	if stage == NOT_A_VAMPIRE then return end -- not a vampire
	
	local remindStr = nil
	local formatStr = nil
	
	if stage < VampReminder.desiredStage then 

		formatStr = Reminderz.Localization.GO_FEED or "You are now %s. GO FEED!"
		remindStr = string.format(formatStr, zo_strformat("<<1>>", stageName))

	elseif stage == VampReminder.desiredStage then
	
		local nowSecs = GetGameTimeMilliseconds()/1000
		local remainSecs = timeEnding - nowSecs
		
		local timeStr = FormatTimeSeconds(remainSecs, 
											TIME_FORMAT_STYLE_SHOW_LARGEST_UNIT_DESCRIPTIVE, 
											TIME_FORMAT_PRECISION_SECONDS, 
											TIME_FORMAT_DIRECTION_DESCENDING)
											
		if remainSecs > VampReminder.reminder:FirstReminderInSeconds() then return end -- No reminder now thanks
	
		formatStr = Reminderz.Localization.IS_ENDING or "%s ending in %s"
		remindStr = string.format(formatStr, zo_strformat("<<1>>", stageName), timeStr) 

	elseif stage > VampReminder.desiredStage then 
		d(Reminderz.Localization.VAMP_TOO_HIGH or "Vampire Reminder: current stage > desired stage") -- Just notify to console
		return nil, nil -- No reminder now thanks
	end

	remindStr = VampReminder.textColor:Colorize(remindStr)

	VampReminder.reminder:Remind(remindStr, nil)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- VampReminder.Start(): Start up vampire stage reminders
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

function VampReminder.Start(inCheckStage, inReminderIntervalInSecs, 
							inFirstReminderInMinutes, inColorDef)
	
	assert((inCheckStage >= VAMPIRE_STAGE_1 and inCheckStage <= VAMPIRE_STAGE_4), "Desired Vamp Stage must be 1,2,3 or 4!")
	VampReminder.desiredStage = inCheckStage
	VampReminder.reminder:SetPrefix(Reminderz.name)	
	VampReminder.reminder:EchoToChat(Reminderz.settings.remindersToChat)
	VampReminder.textColor = inColorDef or Colorz.red
	VampReminder.reminder:Start(reminderPeriodic, inReminderIntervalInSecs, inFirstReminderInMinutes)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- VampReminder.Stop(): Stop vampire stage reminders
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
 function VampReminder.Stop()
	VampReminder.reminder:Stop()
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- VampReminder.GetStageName(): get ability name for vampire stage
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

function VampReminder.GetStageName(stageNumber)	-- 1, 2, 3 ,or 4
	local i = tonumber(stageNumber)
	assert(i ~= nil, "stageNumber must be 1, 2, 3 or 4 only!")

	return ZO_CachedStrFormat(SI_ABILITY_NAME, GetAbilityName(VampStage[i]))
end
