-- Thief Addon File
-- @author    : Homeo
-- @lastModif : 23/09/2017


function ConvertTime(Timer)
	local timeinsec = Timer /1000
	local heure = math.floor(timeinsec/3600)
	local reste = timeinsec - (heure*3600)
	local minute = math.floor(reste/60)
	local seconde = reste -(minute*60)

	return string.format("%02d:%02d:%02d", heure, minute, seconde)	
end

function StableInfo()
	local inventory, _, stamina, _, speed, _ = GetRidingStats()

	local time = GetTimeUntilCanBeTrained()  

	local icon2 = ""


	if(time > 0) then
		icon2 = SAK.IconMountFull
	else
		icon2 = SAK.IconMountEmpty
	end

	return icon2, ConvertTime(time), inventory, stamina, speed
end

function DisplayMountTrainingInfo()

	local heat = GetInfoBounty()

	if(SAK.settings.DISPLAY_MOUNT == true)then
		local icon2, timerTrain, inventory, stamina, speed = StableInfo()

		if(timerTrain == "00:00:00")then
			if(heat == 0) then
				SwissArmyKnifeContainerTrainTimer:SetText(string.format("     %s%s%s", SAK.IconSpeed, SAK.IconStamina, SAK.IconCapacity))
				SwissArmyKnifeContainerTrainTimer:SetAlpha(0.5)
				SwissArmyKnifeContainerTrainText1:SetAlpha(1)
				SwissArmyKnifeContainerTrainText2:SetAlpha(1)
				SwissArmyKnifeContainerTrainText3:SetAlpha(1)
				if(speed == 60) then
					SwissArmyKnifeContainerTrainText1:SetText(string.format("|cF53D00%s|r", speed))
				else
					if(speed < 10) then
						SwissArmyKnifeContainerTrainText1:SetText(string.format(" |c4DFF00%s|r", speed))
					else
						SwissArmyKnifeContainerTrainText1:SetText(string.format("|c4DFF00%s|r", speed))
					end
				end 

				if(stamina == 60) then
					SwissArmyKnifeContainerTrainText2:SetText(string.format("|cF53D00%s|r", stamina))
				else
					if(stamina < 10) then
						SwissArmyKnifeContainerTrainText2:SetText(string.format(" |c4DFF00%s|r", stamina))
					else
						SwissArmyKnifeContainerTrainText2:SetText(string.format("|c4DFF00%s|r", stamina))
					end
				end
				if(inventory == 60) then
					SwissArmyKnifeContainerTrainText3:SetText(string.format("|cF53D00%s|r", inventory))
				else
					if(inventory < 10) then
						SwissArmyKnifeContainerTrainText3:SetText(string.format(" |c4DFF00%s|r", inventory))
					else
						SwissArmyKnifeContainerTrainText3:SetText(string.format("|c4DFF00%s|r", inventory))
					end
				end
			else
				SwissArmyKnifeContainerTrainText1:SetAlpha(0)
				SwissArmyKnifeContainerTrainText2:SetAlpha(0)
				SwissArmyKnifeContainerTrainText3:SetAlpha(0)
				SwissArmyKnifeContainerTrainTimer:SetAlpha(0)
			end
		else
			if(heat == 0) then
				SwissArmyKnifeContainerTrainTimer:SetAlpha(1)
				SwissArmyKnifeContainerTrainTimer:SetText(string.format(" %s%s", icon2, timerTrain))
				SwissArmyKnifeContainerTrainText1:SetAlpha(0)
				SwissArmyKnifeContainerTrainText2:SetAlpha(0)
				SwissArmyKnifeContainerTrainText3:SetAlpha(0)
			else
				SwissArmyKnifeContainerTrainText1:SetAlpha(0)
				SwissArmyKnifeContainerTrainText2:SetAlpha(0)
				SwissArmyKnifeContainerTrainText3:SetAlpha(0)
				SwissArmyKnifeContainerTrainTimer:SetAlpha(0)
			end
		end
	else
		SwissArmyKnifeContainerTrainText1:SetAlpha(0)
		SwissArmyKnifeContainerTrainText2:SetAlpha(0)
		SwissArmyKnifeContainerTrainText3:SetAlpha(0)
		SwissArmyKnifeContainerTrainTimer:SetAlpha(0)
	end
end