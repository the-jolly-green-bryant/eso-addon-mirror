-- Stats Addon File
-- @author    : Homeo
-- @lastModif : 23/09/2017


function GetMails()
    local unread_total = CHAT_SYSTEM.numUnreadMails
    local total = 0

    if MAIL_INBOX.masterList == nil then
        for i in ZO_GetNextMailIdIter do
            total = total + 1
        end
        total = total + unread_total
    else
        local read = 0
        local unread = 0

        for k, v in pairs(MAIL_INBOX.masterList) do
            if v.unread == true then
                unread = unread + 1
            else
                read = read + 1
            end
        end

        if unread ~= unread_total then
            total = read + unread_total
        else
            total = read + unread
        end
    end

	if(SAK.settings.DISPLAY_MAIL == true) then
		if(unread_total >= 1) then
			SwissArmyKnifeContainerNumberMails:SetText(string.format("%s|c4DFF00%s|r/%s",SAK.IconMail, unread_total, total))
		else
			SwissArmyKnifeContainerNumberMails:SetText(string.format("%s|cFFFFFF%s|r/%s",SAK.IconMail, unread_total, total))
		end
	end
end

function GoldPerHour()
	local bank = GetBankedMoney()
	local bag = GetCurrentMoney()
	local goldPH = 0
	local goldTotal = bank + bag
	local timePH = 0
	local minrest = 0
	local repair = RepairCost()
	local gainHour = goldTotal - SAK.settings.GOLD_CONNECTED

	local secondPlayed = math.floor(GetDiffBetweenTimeStamps(GetTimeStamp() - SAK.settings.CONNECTED_TIME))
	
	if(SAK.settings.GOLD_CONNECTED ~= 0) then
		goldPH = gainHour	
	end

	if(SAK.settings.REPAIR_COST_DISPLAY == true) then
		goldPH = goldPH - repair
	end
	
	if(secondPlayed > 0) then
		timePH = math.floor((goldPH * 3600) / secondPlayed)
	end

	return timePH, goldPH
end

function TelVarPerHour()
	local bank = GetBankedCurrencyAmount(CURT_TELVAR_STONES)
	local bag = GetCarriedCurrencyAmount(CURT_TELVAR_STONES)
	local goldPH = 0
	local goldTotal = bank + bag
	local timePH = 0
	local minrest = 0
	local gainHour = goldTotal - SAK.settings.TELVAR_CONNECTED

	local secondPlayed = math.floor(GetDiffBetweenTimeStamps(GetTimeStamp() - SAK.settings.CONNECTED_TIME))
	
	if(SAK.settings.TELVAR_CONNECTED ~= 0) then
		goldPH = gainHour	
	end
	
	if(secondPlayed > 0) then
		timePH = math.floor((goldPH * 3600) / secondPlayed)
	end

	return timePH, goldPH
end

function AlliancePerHour()
	local bank = GetBankedCurrencyAmount(CURT_ALLIANCE_POINTS)
	local bag = GetCarriedCurrencyAmount(CURT_ALLIANCE_POINTS)
	local goldPH = 0
	local goldTotal = bank + bag
	local timePH = 0
	local minrest = 0
	local gainHour = goldTotal - SAK.settings.ALLIANCE_CONNECTED

	local secondPlayed = math.floor(GetDiffBetweenTimeStamps(GetTimeStamp() - SAK.settings.CONNECTED_TIME))
	
	if(SAK.settings.ALLIANCE_CONNECTED ~= 0) then
		goldPH = gainHour	
	end

	if(secondPlayed > 0) then
		timePH = math.floor((goldPH * 3600) / secondPlayed)
	end

	return timePH, goldPH
end

function PlayedSession()
	local minrest = 0
	local secrest = 0
	local strToReturn = ""

	local HourText = string.sub(SAK.lang.KF_TIME_PLAYED_4, 2, 2)
	local MinText = string.sub(SAK.lang.KF_TIME_PLAYED_5, 2, 2)
	local SecText = string.sub(SAK.lang.KF_TIME_PLAYED_6, 2, 2)

	local hoursPlayed = math.floor((GetDiffBetweenTimeStamps(GetTimeStamp() - SAK.settings.CONNECTED_TIME) / 3600))
	local minsPlayed = math.floor((GetDiffBetweenTimeStamps(GetTimeStamp() - SAK.settings.CONNECTED_TIME) / 60))
	local secondPlayed = math.floor(GetDiffBetweenTimeStamps(GetTimeStamp() - SAK.settings.CONNECTED_TIME))

	if(minsPlayed >= 60) then
		minrest = minsPlayed - (hoursPlayed*60)
	else
		minrest = minsPlayed
	end

	if(secondPlayed >= 60) then
		secrest = secondPlayed - (minrest*60) - (hoursPlayed*3600)
	else
		secrest = secondPlayed
	end
	
	if(hoursPlayed > 0) then
		strToReturn = hoursPlayed .. HourText .." " .. minrest .. MinText .." " .. secrest .. SecText
	else
		if(minrest > 0) then
			strToReturn = minrest .. MinText .." " .. secrest .. SecText
		else
			strToReturn = secrest .. SecText
		end
	end

	return strToReturn
end

function TimePlayed(dispShort)
	local seconds
	local minutes
	local hours
	local days
	local strplayed

	local JourText = SAK.lang.KF_TIME_PLAYED_3
	local HourText = SAK.lang.KF_TIME_PLAYED_4
	local MinText = SAK.lang.KF_TIME_PLAYED_5
	
	
	hours=0
	seconds=GetSecondsPlayed()
	days=math.floor(seconds / 86400)
	seconds=seconds-days*86400
	hours=math.floor(seconds / 3600)
	seconds=seconds-hours*3600
	minutes=math.floor(seconds/60)
	strplayed=""
	
	if(dispShort == true) then
		JourText = string.sub(JourText, 2, 2)
		HourText = string.sub(HourText, 2, 2)
		MinText = string.sub(MinText, 2, 2)
	end

	if (days > 0) then
		strplayed=strplayed .. tostring(days) .. JourText
		strplayed=strplayed .. " "
	end
	if (hours >= 0) then
		strplayed=strplayed .. tostring(hours) .. HourText
		strplayed=strplayed .. " "
	end
	if (minutes > 0) then
		strplayed=strplayed .. tostring(minutes) .. MinText
	end
	return strplayed
end










