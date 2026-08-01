FoodReminder = {
	textColor = Colorz.yellow,
	reminder = TBO_Reminder:New(Reminderz.name),
	dontRemindInHouses = true
}

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- TestForFoodBuff(): Food buffs all have 17 characteristics in common. If all are true then its a food buff.
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

local selfStr = GetString(SI_TARGETTYPE2)

local function TestForFoodBuff(abilityID)	
	
	if DoesAbilityExist(abilityID) == false then return -1 end -- If the ID isn't an ability then not a food

	-- Food abilities all have a target of "Self"
	local desc = GetAbilityTargetDescription(abilityID)
	if GetAbilityTargetDescription(abilityID) ~= selfStr then return -2 end

	if GetAbilityDuration(abilityID) == 0 then return -3 end -- Food abilities all have a specified duration

	-- Food abilities have no cost
	local cost = GetAbilityCost(abilityID)
	if cost > 0 then return -4 end

	-- Food abilities have no range
	local rMin, rMax = GetAbilityRange(abilityID)
	if rMin > 0 then return -5 end
	if rMax > 0 then return -6 end

	if GetAbilityRadius(abilityID) > 0 then return -7 end -- Food abilities have no radius or angle
	if GetAbilityAngleDistance(abilityID) > 0 then return -8 end -- Food abilities have no angle distance
	
	-- Food abilities have no channel or cast time
	local isChanneled, castTime, chTime = GetAbilityCastInfo(abilityID) -- 
	if isChanneled == true then return -9 end
	if castTime > 0 then return -10 end

	-- Food abilities have a description 
	if GetAbilityDescription(abilityID) == "" then return -11 end

	if IsAbilityPermanent(abilityID) == true then return -12 end -- Food abilities are never permanent
	if IsAbilityPassive(abilityID) == true then return -13 end -- Food abilities are never passive

	-- Food abilities have no effect description
	if GetAbilityEffectDescription(abilityID) ~= "" then return -14 end

	-- Food abilities all seem to have a 6 or 5 second cooldown
	local cooldown = GetAbilityCooldown(abilityID, 'player')
	if cooldown ~= 6000 and cooldown ~= 5000 then return -15 end

	return 0
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- IsFoodBuff(): Returns true or false
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
local debugFoodBuffTest = false

local function IsFoodBuff(abilityID)	
	local err = TestForFoodBuff(abilityID)
	if err ~= 0 and debugFoodBuffTest then
		d(string.format("IsFoodBuff() failed for '%s' with error = %d", GetAbilityName(abilityID), err))
	end
	return (err == 0)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- GetActiveFoodBuff(): Returns the abilityID, name, remainingSecs and remainingTimeStr for the active food buff (or nil)
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

local function GetActiveFoodBuff()

	local buffs = GetBuffs()
		
	for i, b in pairs(buffs) do
		if IsFoodBuff(b["abilityId"]) then 
			local rSecs = b["timeEnding"] - (GetGameTimeMilliseconds() / 1000)
			-- rSecs = math.random(44, 188) -- for testing
			if rSecs > 0 then -- looks like some PvP bonus buffs look like a food buff but have a negative duration
				local rStr = FormatTimeSeconds(rSecs, 
												TIME_FORMAT_STYLE_SHOW_LARGEST_UNIT_DESCRIPTIVE, 
												TIME_FORMAT_PRECISION_SECONDS, 
												TIME_FORMAT_DIRECTION_DESCENDING)
				return b["abilityId"], b["buffName"], rSecs, rStr
			end
		end
	end
	return nil, nil, nil, nil
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
	
	if FoodReminder.reminder:ShouldRemind() == false then 
		return -- Don't remind unless it's time
	elseif FoodReminder.onlyRemindInDungeons == true and GetMapContentType() ~= MAP_CONTENT_DUNGEON then return -- Don't remind if not in a dungeon, trial, delve, etc.
	elseif FoodReminder.dontRemindInHouses == true and GetCurrentZoneHouseId() ~= 0 then return -- Don't remind while they are in their house
	end

	local messageTitle = Reminderz.Localization.NO_FOOD_1
	local messageSubheading = FoodReminder.textColor:Colorize(Reminderz.Localization.NO_FOOD_2)

	local abilityID, name, secsRemain, remainStr = GetActiveFoodBuff()
	
	if secsRemain then
		if secsRemain >= FoodReminder.reminder:FirstReminderInSeconds() then return end -- Food is good
		local formatStr = Reminderz.Localization.FOOD_RUNNING_OUT
		messageTitle = string.format(formatStr, zo_strformat("'<<C:1>>'",name), remainStr)
		messageSubheading = nil
	end

	FoodReminder.reminder:Remind(FoodReminder.textColor:Colorize(messageTitle), messageSubheading)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- FoodReminder.Start(): Start up food reminders
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

function FoodReminder.Start(inReminderIntervalInSecs, inFirstReminderInMinutes, inColorDef)
	FoodReminder.reminder:SetPrefix(Reminderz.name)
	FoodReminder.reminder:EchoToChat(Reminderz.settings.remindersToChat)
	FoodReminder.textColor = inColorDef or Colorz.yellow
	FoodReminder.reminder:Start(reminderPeriodic, inReminderIntervalInSecs, inFirstReminderInMinutes) 
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- FoodReminder.Stop(): Stop food reminders
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

function FoodReminder.Stop()
	FoodReminder.reminder:Stop()
end