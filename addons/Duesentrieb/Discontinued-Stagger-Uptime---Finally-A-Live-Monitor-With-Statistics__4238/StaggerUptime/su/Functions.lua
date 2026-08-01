local SU = StaggerUptime

------------------------------------------------------------------------
-- ENABLE EVENT_MANAGER AND ENABLES THE ADDON INCL. SHOWING NOTIFICATION
------------------------------------------------------------------------
function SU.Enable()
	EVENT_MANAGER:RegisterForEvent(SU.name, EVENT_PLAYER_COMBAT_STATE, SU.combatState)
	EVENT_MANAGER:RegisterForEvent(SU.name, EVENT_PLAYER_ACTIVATED, SU.playerActivated)
	EVENT_MANAGER:RegisterForEvent(SU.name, EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, SU.updateIsEquipped)
	EVENT_MANAGER:RegisterForEvent(SU.name, EVENT_ACTION_SLOT_UPDATED, SU.updateIsEquipped)
	SU.updateIsEquipped()
	SU.updateDisplay()
	SU.isLoaded = true
end

-------------------------------------------------------------------------
-- DISABLE EVENT_MANAGER AND DISABLES THE ADDON INCL. HIDING NOTIFICATION
-------------------------------------------------------------------------
function SU.Disable()
	EVENT_MANAGER:UnregisterForEvent(SU.name, EVENT_PLAYER_COMBAT_STATE)
	EVENT_MANAGER:UnregisterForEvent(SU.name, EVENT_PLAYER_ACTIVATED)
	EVENT_MANAGER:UnregisterForEvent(SU.name, EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED)
	EVENT_MANAGER:UnregisterForEvent(SU.name, EVENT_ACTION_SLOT_UPDATED)
	EVENT_MANAGER:UnregisterForUpdate("StaggerUptimeUpdateStaggerTime")
	SU.hideNotification()
	SU.isLoaded = false
end

-----------------------------------------------------------------
-- RETURNS RGBA DEPENDING OF THE INPUT PERCENTAGE;
-- RED -> GREEN "value = 100 - math.max(0, math.min(100, value))"
-- GREEN -> RED "value = math.max(0, math.min(100, value))"
-----------------------------------------------------------------
function SU.percentageToRgba(value)
	local r, g, b
	value = 100 - math.max(0, math.min(100, value))
	if value >= 75 then
		local segmentValue = value - 75
		local factor = segmentValue / 25
		r = 1.0 / 255 * 255
		g = 1.0 / 255 * math.floor(127 * (1 - factor))
		b = 0
	elseif value >= 50 then
		local segmentValue = value - 50
		local factor = segmentValue / 25
		r = 1.0 / 255 * 255
		g = 1.0 / 255 * math.floor(255 - (128 * factor))
		b = 0
	elseif value >= 25 then
		local segmentValue = value - 25
		local factor = segmentValue / 25
		r = 1.0 / 255 * math.floor(127 + (128 * factor))
		g = 1.0 / 255 * 255
		b = 0
	else
		local segmentValue = value
		local factor = segmentValue / 25
		r = 1.0 / 255 * math.floor(127 * factor)
		g = 1.0 / 255 * 255
		b = 0
	end
	return {r, g, b, 1}
end

------------------------------------------------------
-- RETURNS A STRING IN THE FORMAT "20min 10s" or "35s"
------------------------------------------------------
function SU.formatTime(totalSeconds)
	if totalSeconds >= 60 then
		local totalMinutes = math.floor(totalSeconds / 60)
		local remainingSeconds = totalSeconds % 60
		return string.format("%dmin %.0fs", totalMinutes, remainingSeconds)
	else
		return string.format("%.0fs", totalSeconds)
	end
end

-------------------------------------------------------------------------------------
-- EVENT_MANAGER:RegisterForEvent(SU.name, EVENT_PLAYER_COMBAT_STATE, SU.combatState)
-------------------------------------------------------------------------------------
function SU.combatState()
	local preCombat = SU.isCombat
	SU.isCombat = IsUnitInCombat("player")
	if SU.isCombat and not preCombat then
		local currentTime = GetGameTimeMilliseconds()
		SU.fightStartTime = currentTime
		SU.fightUpdateTime = currentTime
		EVENT_MANAGER:RegisterForEvent(SU.name, EVENT_EFFECT_CHANGED, SU.effectChanged)
		EVENT_MANAGER:RegisterForUpdate("StaggerUptimeUpdateStaggerTime", 100, function() SU.updateStaggerTime() end)
	else
		EVENT_MANAGER:UnregisterForEvent(SU.name, EVENT_EFFECT_CHANGED)
		EVENT_MANAGER:UnregisterForUpdate("StaggerUptimeUpdateStaggerTime")
		SU.sendChatNotifications()
	end
	-------------------------------------
	-- EVERY OTHER CHANGE IN COMBAT STATE
	-------------------------------------
	SU.staggerTracer = {}
	SU.staggerCounter = 0
	SU.staggerTime3X = 0
	SU.staggerTime2X = 0
	SU.staggerTime1X = 0
	if SU.fightStartTime == SU.fightUpdateTime then return end
	SU.updateDisplay()
end

--------------------------------------------------
-- Send Chat Notifications WITH STAGGER STATISTICS
--------------------------------------------------
function SU.sendChatNotifications()
	if not SU.isEquipped then return end
	local fightTime = (GetGameTimeMilliseconds() - SU.fightStartTime)
	if SU.sVar.isEnabledChat and (fightTime > (SU.sVar.minFightTime * 1000)) then
		local formatFightDuration = SU.formatTime(fightTime / 1000) or "0min 0s"
		local r, g, b, a = unpack(SU.fontColor)
		r = 255 * r
		g = 255 * g
		b = 255 * b
		local s1 = formatFightDuration
		local s2 = SU.staggerCounter
		local s3 = string.format("%02x%02x%02x", r, g, b)
		local s4 = SU.percentage3X
		local s5 = SU.percentage2X
		local s6 = SU.percentage1X
		d(string.format("|cff7f00[Stagger Uptime]|r |cffffffFight Duration: %s - Casts: %i -|r |c%s[3] %.0f%% [2] %.0f%% [1] %.0f%%|r", s1, s2, s3, s4, s5, s6))
	end
end

--------------------------------------------------------------------------------------------------------
-- EVENT_MANAGER:RegisterForUpdate("StaggerUptimeUpdateDisplay", 200, function() SU.updateDisplay() end)
--------------------------------------------------------------------------------------------------------
function SU.updateDisplay()
	if not SU.isForceShow then
		if SU.sVar.isOnlyCombat and not SU.isCombat then
			SU.hideNotification()
			return
		end
		if not SU.isEquipped then
			SU.hideNotification()
			return
		end
	end
	SU.showNotification()
	local currentTime = GetGameTimeMilliseconds()
	local fightDuration = currentTime - SU.fightStartTime
	local prePercentage1X = SU.percentage1X
	local prePercentage2X = SU.percentage2X
	local prePercentage3X = SU.percentage3X
	if SU.staggerTime3X > 0 then SU.percentage3X = (SU.staggerTime3X / fightDuration) * 100 else SU.percentage3X = 0 end
	if SU.staggerTime2X > 0 then SU.percentage2X = (SU.staggerTime2X / fightDuration) * 100 else SU.percentage2X = 0 end
	if SU.staggerTime1X > 0 then SU.percentage1X = (SU.staggerTime1X / fightDuration) * 100 else SU.percentage1X = 0 end
	local arrow3X = "↓"
	local arrow2X = "↓"
	local arrow1X = "↓"
	if prePercentage3X < SU.percentage3X then arrow3X = "↑" end
	if prePercentage2X < SU.percentage2X then arrow2X = "↑" end
	if prePercentage1X < SU.percentage1X then arrow1X = "↑" end
	SU.displayText = string.format("%s[%i] %.1f%%", arrow3X, SU.staggerStacks, SU.percentage3X)
	SU.fontColor = SU.percentageToRgba(SU.percentage3X)
end

-----------------------------------------------------------------------------------------------------------------
-- EVENT_MANAGER:RegisterForUpdate("StaggerUptimeUpdateStaggerTime", time, function() SU.updateStaggerTime() end)
-----------------------------------------------------------------------------------------------------------------
function SU.updateStaggerTime()
	local currentTime = GetGameTimeMilliseconds()
	local deltaTime = currentTime - SU.fightUpdateTime
	SU.fightUpdateTime = currentTime
	if currentTime < SU.staggerEndTime3X then
		SU.staggerTime3X = SU.staggerTime3X + deltaTime
	end
	if currentTime < SU.staggerEndTime2X then
		SU.staggerTime2X = SU.staggerTime2X + deltaTime
	end
	if currentTime < SU.staggerEndTime1X then
		SU.staggerTime1X = SU.staggerTime1X + deltaTime
	end
	SU.updateDisplay()
end

---------------------------------------------------------------------------------------------------------
-- UPDATES THE SU.staggerStacks VARIABLE WITH THE HIGHEST STACK COUNT IN THE EVENT TABLE SU.staggerTracer
---------------------------------------------------------------------------------------------------------
function SU.updateHighestStack()
	local staggerStacks = 0
	for _, stackCount in pairs(SU.staggerTracer) do
		if stackCount > staggerStacks then
			staggerStacks = stackCount
		end
	end
	SU.staggerStacks = staggerStacks
end

----------------------------------------------------------------------------------
-- EVENT_MANAGER:RegisterForEvent(SU.name, EVENT_EFFECT_CHANGED, SU.effectChanged)
----------------------------------------------------------------------------------
function SU.effectChanged(_, changeType, _, _, _, _, _, stackCount, _, _, _, _, _, _, unitId, abilityId, sourceUnitType)
	if abilityId ~= SU.STONEGIANT_DEBUFF_ID and abilityId ~= SU.STONEGIANT_BUFF_ID then return end
	-------------------------------------------------
	-- TRACKING THE SU.STONEGIANT_BUFF_ID ON "PLAYER"
	-------------------------------------------------
	if abilityId == SU.STONEGIANT_BUFF_ID and sourceUnitType == COMBAT_UNIT_TYPE_PLAYER then
		if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
			if stackCount == 3 then SU.buffEndTime = GetGameTimeMilliseconds() + 12000 - 100 end
			SU.staggerCast = true
		elseif changeType == EFFECT_RESULT_FADED then
			local currentTime = GetGameTimeMilliseconds()
			if SU.buffEndTime > currentTime then
				SU.staggerCast = true
			end
		end
	end
	-------------------------------------------------
	-- TRACKING THE SU.STONEGIANT_DEBUFF_ID ON ENEMYS
	-------------------------------------------------
	if sourceUnitType ~= COMBAT_UNIT_TYPE_PLAYER and SU.sVar.isOnlyTrackPlayer then return end
	if abilityId == SU.STONEGIANT_DEBUFF_ID then
		if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
			if SU.staggerCast then
				SU.staggerCast = false
				SU.staggerCounter = SU.staggerCounter + 1
			end
			SU.staggerTracer[unitId] = stackCount
			SU.updateHighestStack()
			local currentTime = GetGameTimeMilliseconds()
			if stackCount == 3 then
				SU.staggerEndTime3X = currentTime + 6000
				SU.staggerEndTime2X = currentTime + 6000
				SU.staggerEndTime1X = currentTime + 6000
			elseif stackCount == 2 then
				SU.staggerEndTime2X = currentTime + 6000
				SU.staggerEndTime1X = currentTime + 6000
			elseif stackCount == 1 then
				SU.staggerEndTime1X = currentTime + 6000
			end
		elseif changeType == EFFECT_RESULT_FADED then
			SU.staggerTracer[unitId] = nil
			SU.updateHighestStack()
		end
	end
end

-----------------------------------
-- CHECK IF SKILL IS SLOTTET ON BAR
-----------------------------------
function SU.updateIsEquipped()
	for i = 3, 7 do
		local FB = GetSlotBoundId(i, HOTBAR_CATEGORY_PRIMARY)
		local BB = GetSlotBoundId(i, HOTBAR_CATEGORY_BACKUP)
		if SU.SLOT_ID == FB or SU.SLOT_ID == BB or SU.SLOT_ID_PROJ == FB or SU.SLOT_ID_PROJ == BB then
			SU.isEquipped = true
			SU.updateDisplay()
			return
		end
	end
	SU.isEquipped = false
	SU.updateDisplay()
end

--------------------------------------------------------------------------------------
-- EVENT_MANAGER:RegisterForEvent(SU.name, EVENT_PLAYER_ACTIVATED, SU.playerActivated)
--------------------------------------------------------------------------------------
function SU.playerActivated()
	if SU.sVar.isEnabled and not SU.isLoaded then
		SU.Enable()
	elseif not SU.sVar.isEnabled then
		SU.Disable()
	end
	SU.updateIsEquipped()
	SU.updateDisplay()
end