local BT = BlockingTime


function BT.CombatState()
	local preCombatState = BT.isCombat
	BT.isCombat = IsUnitInCombat("player")

	if BT.isCombat == true and preCombatState == false then
		EVENT_MANAGER:RegisterForUpdate(BT.name.."UpdateBlockTime", 100, function() BT.UpdateBlockTime() end)
		BT.isBlocking = false
		BT.blockedTime = 0
		BT.fightStartTime = GetGameTimeMilliseconds()
		BT.fightUpdateTime = GetGameTimeMilliseconds()
	elseif BT.isCombat == false and preCombatState == true then
		EVENT_MANAGER:UnregisterForUpdate(BT.name.."UpdateBlockTime")
		BT.ReportBlockStats()
	end
end


function BT.UpdateBlockTime()
	local currentTime = GetGameTimeMilliseconds()
	local deltaTime = currentTime - BT.fightUpdateTime
	BT.fightUpdateTime = currentTime

	BT.isBlocking = IsBlockActive()

	if BT.isBlocking then
		BT.blockedTime = BT.blockedTime + deltaTime
		BT.penaltyTime = BT.penaltyTime + deltaTime

		-- PENALTY CLICK
		if BT.penaltyTime >= 2000 and BT.SV.volumePenaltyClick > 0 then
			local oldPenaltyStacks = BT.penaltyStacks
			BT.penaltyStacks = math.floor(BT.penaltyTime / 2000)
			if BT.penaltyStacks > oldPenaltyStacks then
				BT.penaltyQueue = math.min(4, BT.penaltyStacks)
				BT.PlayPenaltySound()
			end
		end
	else
		BT.penaltyTime = 0
		BT.penaltyStacks = 0
		BT.penaltyQueue = 0
	end
end


function BT.PlayPenaltySound()
	if BT.penaltyQueue > 0 then
		local volume = BT.SV.volumePenaltyClick
		for i = 1, volume do
			PlaySound(SOUNDS.POSITIVE_CLICK)
			--Test: /script PlaySound(SOUNDS.NEGATIVE_CLICK)
			--Test: /script PlaySound(SOUNDS.DEFAULT_CLICK)
		end
		BT.penaltyQueue = BT.penaltyQueue - 1
		EVENT_MANAGER:RegisterForUpdate(BT.name.."PlayPenaltySound", 250, function() BT.PlayPenaltySound() end)
	else
		EVENT_MANAGER:UnregisterForUpdate(BT.name.."PlayPenaltySound")
	end
end


function BT.FormatDuration(totalSeconds)
	if totalSeconds >= 60 then
		local totalMinutes = math.floor(totalSeconds / 60)
		local remainingSeconds = totalSeconds % 60
		return string.format("%d min %.0f s", totalMinutes, remainingSeconds)
	else
		return string.format("%.0f s", totalSeconds)
	end
end


function BT.ColorHex(value)
	local r, g, b
	value = math.max(0, math.min(100, value))

	if value >= 75 then
		local segmentValue = value - 75
		local factor = segmentValue / 25
		r = 255
		g = math.floor(127 * (1 - factor))
		b = 0
	elseif value >= 50 then
		local segmentValue = value - 50
		local factor = segmentValue / 25
		r = 255
		g = math.floor(255 - (128 * factor))
		b = 0
	elseif value >= 25 then
		local segmentValue = value - 25
		local factor = segmentValue / 25
		r = math.floor(127 + (128 * factor))
		g = 255
		b = 0
	else
		local segmentValue = value
		local factor = segmentValue / 25
		r = math.floor(127 * factor)
		g = 255
		b = 0
	end

	return string.format("|c%02x%02x%02x", r, g, b)
end


function BT.ReportBlockStats()
	if BT.SV.timeFightMin == 0 then return end

	BT.groupRole = GetGroupMemberSelectedRole("player")

	if BT.SV.enableAddon == false then
		return
	elseif BT.groupRole == 2 and BT.SV.isEnabledTank == false then
		return
	elseif BT.groupRole == 4 and BT.SV.isEnabledHeal == false then
		return
	elseif BT.groupRole == 1 and BT.SV.isEnabledDPS == false then
		return
	elseif BT.groupRole == 0 and BT.SV.isEnabledSolo == false then
		return
	end

	local fightDuration = GetGameTimeMilliseconds() - BT.fightStartTime

	if fightDuration < (BT.SV.timeFightMin * 1000) then
		return
	end

	local blockedPercentage = 0
	if fightDuration > 0 then
		blockedPercentage = (BT.blockedTime / fightDuration) * 100
	end

	local fightDurationSeconds = fightDuration / 1000
	local blockedTimeSeconds = BT.blockedTime / 1000

	local formattedFightDuration = BT.FormatDuration(fightDurationSeconds)
	local formattedBlockedTime = BT.FormatDuration(blockedTimeSeconds)
	local formattedblockedPercentage = string.format("%.1f", blockedPercentage)

	BT.colorGradient = BT.ColorHex(string.format("%.0f", blockedPercentage))
	d(BT.COL.OG .. BT.chat .. BT.COL.END .. BT.COL.WH .. " Fight Duration: " .. formattedFightDuration .. " - Blocked: " .. formattedBlockedTime .. " - " .. BT.COL.END .. BT.colorGradient .. formattedblockedPercentage .. " %" .. BT.COL.END)
end