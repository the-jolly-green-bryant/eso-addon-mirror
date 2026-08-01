--[[
	Addon: APCounter
	Author: Mladen90
	Created by @Mladen90
]]--


APC = {}
APC_GLOBAL = {}
APC_FORMS = {}
APC_MENU = {}


APC_TimerStarted = function() return (APC.SavedVariables.StartTimeStamp ~= nil) end


APC_CheckIfRestoreIsSkipped = function() return (APC.SavedVariables.SkipRestoreApAfterMins <= APC_GetMinutesFromTimes(GetTimeStamp(), APC.SavedVariables.LastGainTimeStamp)) end


APC_GetSecondsFromTimes = function(greater, lower) return (greater - lower) end


APC_GetMinutesFromTimes = function(greater, lower) return math.floor(APC_GetSecondsFromTimes(greater, lower) / 60) end


APC_PrintLog = function(delayed_message)
	APC_SystemPrint(APC_NumberFormat(APC.SavedVariables.CurrentAP) .. APC_GetApText() .. APC_GetMinutesForDisplay(), nil, delayed_message)
end


APC_GetMinutesFromTimer = function() return math.floor(APC_GetSecondsFromTimer() / 60) end


APC_GetMinutesForDisplay = function() return " (" .. APC_NumberFormat(APC_GetMinutesFromTimer()) .. " mins) " end


APC_GetResourceName = function(resourceId)
	local resourceName = ""

	if resourceId > 0 then
		resourceName = GetKeepName(resourceId)

		if not APC_IsStringEmpty(resourceName) then resourceName = zo_strformat("<<1>>", resourceName) end
	end

	return resourceName or ""
end


APC_StartTimer1 = function() APC_StartTimer2(true) end


APC_StartTimer2 = function(showRunning)
	if APC_TimerStarted() then
		if showRunning then APC_SystemPrint("APC running" .. APC_GetMinutesForDisplay()) end
	else
		APC_TryInitTimer()
		APC_SystemPrint("APC started")
	end
end


-- Initializes the timer if not initialized
APC_TryInitTimer = function()
	if APC_TimerStarted() == false then APC.SavedVariables.StartTimeStamp = GetTimeStamp() end
end


APC_GetSecondsFromTimer = function()
	if APC_TimerStarted() then return (GetTimeStamp() - APC.SavedVariables.StartTimeStamp)
	else return 0 end
end


--* EVENT_ALLIANCE_POINT_UPDATE (*integer* _alliancePoints_, *bool* _playSound_, *integer* _difference_, *[CurrencyChangeReason|#CurrencyChangeReason]* _reason_, *integer* _reasonSupplementaryInfo_)
APC_Update = function(eventCode, alliancePoints, playSound, difference, reason, reasonSupplementaryInfo)
	-- Nothing to calculate
	if (reason == CURRENCY_CHANGE_REASON_BANK_WITHDRAWAL or difference < 1) then return end

	-- Addon not fully loaded
	if not APC.SavedVariables then
		APC_GLOBAL.APOnLoading = (APC_GLOBAL.APOnLoading + difference)
		return
	end

	-- Starts the timer if not started
	APC_TryInitTimer()
	
	APC.SavedVariables.LastGainTimeStamp = GetTimeStamp()
	APC_GLOBAL.SumLogAP = (APC_GLOBAL.SumLogAP + difference)

	local currentAP = APC.SavedVariables.CurrentAP

	-- Must be earlier to fix AP loss if error later happens
	APC_UpdateApVariables(reason, difference)

	APC_TryLogAlliancePoints(reason, currentAP, difference, currentAP + difference, reasonSupplementaryInfo)
	APC_TryAnnounce(reason, difference, reasonSupplementaryInfo)

	GetAddOnManager():RequestAddOnSavedVariablesPrioritySave(APC.AddOnName)
end


APC_TryLogAlliancePoints = function(reason, orgOldAP, orgDiffAP, orgNewAP, resourceId)
	local _oldAP = orgOldAP
	local _diffAP = orgDiffAP
	local _newAP = orgNewAP

	local resourceName = ""

	if APC.SavedVariables.LogTickResourceName and APC_IsTick(reason) then resourceName = APC_GetResourceName(resourceId) end

	local status = APC_GetBaseApSourceInfoForDisplay(reason)

	if (APC.SavedVariables.LogAPAmount > 1) then
		if (APC_GLOBAL.SumLogAP > orgDiffAP) then
			status = AP_STATUS_MULTI_SOURCE
			resourceName = ""
		end

		_oldAP = (orgNewAP - APC_GLOBAL.SumLogAP)
		_diffAP = APC_GLOBAL.SumLogAP
	end

	local loggedAP = false

	if (APC_GLOBAL.SumLogAP >= APC.SavedVariables.LogAPAmount) then
		APC_GLOBAL.SumLogAP = 0

		if APC.SavedVariables.LogEnabled then
			loggedAP = true

			if (APC.SavedVariables.ApLogFormat == AP_LOG_FORMAT_LONG) then
				APC_SystemPrint(status .. " -> " .. APC_NumberFormat(_oldAP) .. APC_GetApText() .. " + " .. APC_NumberFormat(_diffAP) .. APC_GetApText() .. " = " .. APC_NumberFormat(_newAP) .. APC_GetApText() .. APC_GetMinutesForDisplay(), resourceName)
			elseif (APC.SavedVariables.ApLogFormat == AP_LOG_FORMAT_NORMAL) then
				APC_SystemPrint(status .. " +" .. APC_NumberFormat(_diffAP) .. APC_GetApText() .. " -> " .. APC_NumberFormat(_newAP) .. APC_GetApText() .. APC_GetMinutesForDisplay(), resourceName)
			else
				APC_SystemPrint(status .. " -> " ..  APC_NumberFormat(_newAP) .. APC_GetApText() .. APC_GetMinutesForDisplay(), resourceName)
			end
		end
	end

	if (APC.SavedVariables.LogEveryTickEnabled) or (APC.SavedVariables.LogEnabled and APC.SavedVariables.LogAPAmount > 1) then
		if (status == AP_STATUS_MULTI_SOURCE) then APC_TryLogTick(reason, resourceId, orgDiffAP)
		elseif (not loggedAP) then APC_TryLogTick(reason, resourceId, orgDiffAP) end
	end
end


APC_TryLogTick = function (reason, resourceId, orgDiffAP)
	if APC_IsTick(reason) then
		local resourceName = ""
		if APC.SavedVariables.LogTickResourceName then resourceName = APC_GetResourceName(resourceId) end
		APC_SystemPrint(APC_GetBaseApSourceInfoForDisplay(reason) .. " -> ".. APC_NumberFormat(orgDiffAP) .. APC_GetApText(), resourceName)
	end
end


APC_TryAnnounce = function(reason, difference, resourceId)
	if (APC.SavedVariables.UseScreenMessage and APC.SavedVariables.TickAPAmount <= difference) then
		local resourceName = ""

		if APC.SavedVariables.DisplayTickResourceName then resourceName = APC_GetResourceName(resourceId) end

		if (reason == CURRENCY_CHANGE_REASON_DEFENSIVE_KEEP_REWARD) then APC_FORMS.Functions.DisplayTick(resourceName, "DTICK " .. difference .. APC_GetApText(true))
		elseif(reason == CURRENCY_CHANGE_REASON_OFFENSIVE_KEEP_REWARD) then APC_FORMS.Functions.DisplayTick(resourceName, "OTICK " .. difference .. APC_GetApText(true)) end
	end
end


APC_UpdateApVariables = function(reason, diffAP)
	APC.SavedVariables.CurrentAP = (APC.SavedVariables.CurrentAP + diffAP)

	if (reason == CURRENCY_CHANGE_REASON_QUESTREWARD) then APC.SavedVariables.APFromQ = APC.SavedVariables.APFromQ + diffAP
	elseif (reason == CURRENCY_CHANGE_REASON_KILL) then APC.SavedVariables.APFromKH = APC.SavedVariables.APFromKH + diffAP
	elseif (reason == CURRENCY_CHANGE_REASON_DEFENSIVE_KEEP_REWARD) then APC.SavedVariables.APFromDT = APC.SavedVariables.APFromDT + diffAP
	elseif (reason == CURRENCY_CHANGE_REASON_OFFENSIVE_KEEP_REWARD) then APC.SavedVariables.APFromOT = APC.SavedVariables.APFromOT + diffAP
	elseif (reason == CURRENCY_CHANGE_REASON_KEEP_REPAIR) then APC.SavedVariables.APFromWD = APC.SavedVariables.APFromWD + diffAP
	elseif (reason == CURRENCY_CHANGE_REASON_PVP_RESURRECT) then APC.SavedVariables.APFromRA = APC.SavedVariables.APFromRA + diffAP
	elseif (reason == CURRENCY_CHANGE_REASON_REWARD) then APC.SavedVariables.APFromRE = APC.SavedVariables.APFromRE + diffAP
	elseif (reason == CURRENCY_CHANGE_REASON_BATTLEGROUND or reason == CURRENCY_CHANGE_REASON_MEDAL) then APC.SavedVariables.APFromBG = APC.SavedVariables.APFromBG + diffAP
	else APC.SavedVariables.APFromU = APC.SavedVariables.APFromU + diffAP end
end


APC_GetBaseApSourceInfoForDisplay = function(reason)
	if (reason == CURRENCY_CHANGE_REASON_QUESTREWARD) then return "Q "
	elseif (reason == CURRENCY_CHANGE_REASON_KILL) then return "KH"
	elseif (reason == CURRENCY_CHANGE_REASON_DEFENSIVE_KEEP_REWARD) then return "DT"
	elseif (reason == CURRENCY_CHANGE_REASON_OFFENSIVE_KEEP_REWARD) then return "OT"
	elseif (reason == CURRENCY_CHANGE_REASON_KEEP_REPAIR) then return "WD"
	elseif (reason == CURRENCY_CHANGE_REASON_PVP_RESURRECT) then return "RA"
	elseif (reason == CURRENCY_CHANGE_REASON_REWARD) then return "RE"
	elseif (reason == CURRENCY_CHANGE_REASON_BATTLEGROUND or reason == CURRENCY_CHANGE_REASON_MEDAL) then return "BG"
	else return "U(" .. reason .. ")" end
end


APC_ResetApcState = function(skipMessage, delayed_message)
	APC.SavedVariables.StartTimeStamp = nil
	APC.SavedVariables.CurrentAP = 0
	APC.SavedVariables.APFromQ = 0
	APC.SavedVariables.APFromKH = 0
	APC.SavedVariables.APFromDT = 0
	APC.SavedVariables.APFromOT = 0
	APC.SavedVariables.APFromWD = 0
	APC.SavedVariables.APFromRA = 0
	APC.SavedVariables.APFromRE = 0
	APC.SavedVariables.APFromBG = 0
	APC.SavedVariables.APFromU = 0
	APC_GLOBAL.SumLogAP = 0
	APC_GLOBAL.APOnLoading = 0
	APC.SavedVariables.LastGainTimeStamp = GetTimeStamp()

	if (skipMessage ~= true) then APC_SystemPrint("APC reseted", nil, delayed_message) end
end


APC_PrintCommands = function(delayed_message)
	APC_SystemPrint("APC slash commands:", nil, delayed_message)
	APC_SystemPrint("/apc_commands /apc_source_info /apc_data", nil, delayed_message)
	APC_SystemPrint("/apc_start /apc_reset /apc_statistic", nil, delayed_message)
end


--* EVENT_ADD_ON_LOADED (*string* _addonName_)
APC_Load = function(eventCode, addonName)
	-- Prevents running this function if the addonName is not the same as this AddOnName, since load is called for all addons more times
    if addonName ~= APC.AddOnName then return end

    EVENT_MANAGER:UnregisterForEvent(addonName, eventCode)
	
	APC.SavedVariables = ZO_SavedVars:New(APC.SavedVariablesFileName, APC.Version, nil, APC.Default)
	
	if (APC.SavedVariables.ShowAvailableCommandsMessageOnStart) then
		APC_PrintCommands(true)
	end
	
	APC_FORMS.Functions.Init(APC.SavedVariables.MainWindowLeft, APC.SavedVariables.MainWindowBottom)
	APC_MENU.Init()

	if (APC.SavedVariables.RestoreAP) then
		if(APC.SavedVariables.CurrentAP < 1) then
			APC_SystemPrint("APC has nothing to restore", nil, true)
			APC_ResetApcState(true, true)
		elseif (APC_CheckIfRestoreIsSkipped()) then
			APC_SystemPrint("APC reseted state, restore time elapsed", nil, true)
			APC_ResetApcState(true, true)
		else
			if (APC_GLOBAL.APOnLoading > 0) then
				APC_UpdateApVariables(nil, APC_GLOBAL.APOnLoading)
				APC_GLOBAL.APOnLoading = 0
			end

			APC_SystemPrint("APC restored state:", nil, true)
			APC_PrintLog(true)
		end
	else APC_ResetApcState(true, true) end
end


APC_CheckStatistic = function()
	if (APC.SavedVariables.CurrentAP == 0) then APC_SystemPrint("No data for statistics")
	elseif (APC_GetMinutesFromTimer() < 10) then APC_SystemPrint("Statistics available in " .. (10 - APC_GetMinutesFromTimer()) .. " mins")
	else
		APC_SystemPrint(APC_NumberFormat(math.floor((APC.SavedVariables.CurrentAP / APC_GetSecondsFromTimer()) * 60)) .. APC_GetApText() .. " / min")
		APC_SystemPrint(APC_NumberFormat(math.floor((APC.SavedVariables.CurrentAP / APC_GetSecondsFromTimer()) * 3600)) .. APC_GetApText() .. " / hour")

		local forSort = {}
		APC_AddForSort(forSort, APC.SavedVariables.APFromQ, "Q ")
		APC_AddForSort(forSort, APC.SavedVariables.APFromKH, "KH")
		APC_AddForSort(forSort, APC.SavedVariables.APFromDT, "DT")
		APC_AddForSort(forSort, APC.SavedVariables.APFromOT, "OT")
		APC_AddForSort(forSort, APC.SavedVariables.APFromWD, "WD")
		APC_AddForSort(forSort, APC.SavedVariables.APFromRA, "RA")
		APC_AddForSort(forSort, APC.SavedVariables.APFromRE, "RE")
		APC_AddForSort(forSort, APC.SavedVariables.APFromBG, "BG")
		APC_AddForSort(forSort, APC.SavedVariables.APFromU, "U ")
		
		APC_MySortDescending(forSort)
		
		for i=1,forSort.Length,1 do
			if forSort[i].Value > 0 then APC_SystemPrint(APC_PercentStatisticInfo(forSort[i].Value, forSort[i].Data)) end
		end
	end
end


-- forSort needs to be created with APC_AddForSort
APC_MySortDescending = function(forSort)
	local sorted = {}
	for i=1,forSort.Length,1 do table.insert(sorted, forSort[i]) end
	table.sort(sorted, function(a,b) return a.Value > b.Value end)
	for i=1,forSort.Length,1 do forSort[i] = sorted[i] end
end


APC_AddForSort = function(forSort, value, data)
	if (forSort.Length == nil) then forSort.Length = 0 end
	
	forSort.Length = forSort.Length + 1
	forSort[forSort.Length] = {}
	forSort[forSort.Length].Value = value
	forSort[forSort.Length].Data = data
end


APC_PercentStatisticInfo = function(sourceAP, sourceInfo)
	return sourceInfo .. " -> " .. APC_NumberFormat(sourceAP) .. APC_GetApText() .. " -> " .. APC_Floor((sourceAP / APC.SavedVariables.CurrentAP) * 100, 2) .. "%"
end


APC_DisplaySourceInfo = function()
	APC_SystemPrint("Q  -> Quest")
	APC_SystemPrint("KH -> Kill or Heal")
	APC_SystemPrint("DT -> Defending Tick")
	APC_SystemPrint("OT -> Offensive Tick")
	APC_SystemPrint("WD -> Wall or Door repair")
	APC_SystemPrint("RA -> Ressurect Ally")
	APC_SystemPrint("RE -> Daily login reward")
	APC_SystemPrint("BG -> Battleground")
	APC_SystemPrint("U  -> Unknown")
	APC_SystemPrint(AP_STATUS_MULTI_SOURCE .. " -> Multi source")
end


APC_Floor = function(num, numDecimalPlaces) return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num)) end


APC_SystemPrint = function(line1, line2, delayed_message)
	local text = APC_GetChatTextColor() .. line1 .. "|r"
	
	if not APC_IsStringEmpty(line2) then
		text = text .. " \n" .. APC_GetChatTextColor() .. line2 .. "|r"
	end

	if delayed_message then zo_callLater(function() d(text) end, 1000)
	else d(text) end
end


APC_GetChatTextColor = function()
	local color = ZO_ColorDef:New(APC.SavedVariables.LogColor.Red, APC.SavedVariables.LogColor.Green, APC.SavedVariables.LogColor.Blue, 1)
	return "|c" .. color:ToHex()
end


APC_GetApText = function(isTick)
	local apText = " AP"

	if APC.SavedVariables.UseAPIcon then
		if isTick then apText = APC_ALLIANCE_POINT_TEXT_ICON_LARGE
		else apText = APC_ALLIANCE_POINT_TEXT_ICON_SMALL .. APC_GetChatTextColor() end
	end

	return apText
end


APC_IsTick = function(reason) return (reason == CURRENCY_CHANGE_REASON_DEFENSIVE_KEEP_REWARD or reason == CURRENCY_CHANGE_REASON_OFFENSIVE_KEEP_REWARD) end


APC_IsStringEmpty = function(sValue) return (sValue == nil or sValue == "") end


APC_DebugDisplay = function(value1, value2)
	local text = value1 or ""

	if not APC_IsStringEmpty(value2) then text = text .. " : " .. value2 end

	d(text)
end


--* EVENT_PLAYER_ACTIVATED (*bool* _initial_)
APC_Player_Activated = function(eventCode, initial)
	if (APC.SavedVariables.StartCounterInCyrodiil and IsInCyrodiil()) then APC_StartTimer2(false)
	elseif (APC.SavedVariables.StartCounterInImperialCity and IsInImperialCity()) then APC_StartTimer2(false)
	end
end


-- EVENT_OPEN_BANK (*[Bag|#Bag]* _bankBag_)
APC_Balance_AP = function(event_code, bank_bag)
	if (bank_bag == BAG_BANK and APC.SavedVariables.UseBalanceAP) then
		local amount = GetCarriedCurrencyAmount(CURT_ALLIANCE_POINTS)

		local diff = (amount - APC.SavedVariables.BalanceAP)
		if (diff > 0) then
			DepositCurrencyIntoBank(CURT_ALLIANCE_POINTS, diff)

			if APC.SavedVariables.LogBalance then
				APC_SystemPrint("[APC] BANK +" .. APC_NumberFormat(diff) .. APC_GetApText())
			end
		elseif (diff < 0) then
			diff = -diff

			local bank_amount = GetBankedCurrencyAmount(CURT_ALLIANCE_POINTS)
			if (bank_amount > 0) then
				if bank_amount < diff then
					WithdrawCurrencyFromBank(CURT_ALLIANCE_POINTS, bank_amount)

					if APC.SavedVariables.LogBalance then
						APC_SystemPrint("[APC] BANK -" .. APC_NumberFormat(bank_amount) .. APC_GetApText())
					end
				else
					WithdrawCurrencyFromBank(CURT_ALLIANCE_POINTS, diff)

					if APC.SavedVariables.LogBalance then
						APC_SystemPrint("[APC] BANK -" .. APC_NumberFormat(diff) ..  APC_GetApText())
					end
				end
			end
		end
	end
end


APC_NumberFormat = function(amount)
	local formatted = amount
	local separator = APC.SavedVariables.Separator

	if separator == APC_TOOLTIP_SPACE then separator = " " end

	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1" .. separator .. "%2")
		if (k==0) then break end
	end

	return formatted
end


SLASH_COMMANDS["/apc_commands"]		= 	APC_PrintCommands
SLASH_COMMANDS["/apc_start"]		=	APC_StartTimer1
SLASH_COMMANDS["/apc_reset"]		= 	APC_ResetApcState
SLASH_COMMANDS["/apc_data"]      	= 	APC_PrintLog
SLASH_COMMANDS["/apc_statistic"]	=	APC_CheckStatistic
SLASH_COMMANDS["/apc_source_info"]	=	APC_DisplaySourceInfo


EVENT_MANAGER:RegisterForEvent("APC_Load", EVENT_ADD_ON_LOADED, APC_Load)
EVENT_MANAGER:RegisterForEvent("APC_Update", EVENT_ALLIANCE_POINT_UPDATE, APC_Update)
EVENT_MANAGER:RegisterForEvent("APC_Player_Activated", EVENT_PLAYER_ACTIVATED, APC_Player_Activated)
EVENT_MANAGER:RegisterForEvent("APC_Balance_AP", EVENT_OPEN_BANK, APC_Balance_AP)