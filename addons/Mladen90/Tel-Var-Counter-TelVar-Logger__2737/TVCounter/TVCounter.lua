--[[
	Addon: TVCounter
	Author: Mladen90
	Created by @Mladen90
]]--


TVC = {}
TVC_GLOBAL = {}
TVC_FORMS = {}
TVC_MENU = {}


TVC_TimerStarted = function() return (TVC.SavedVariables.StartTimeStamp ~= nil) end


TVC_CheckIfRestoreIsSkipped = function() return (TVC.SavedVariables.SkipRestoreTvAfterMins <= TVC_GetMinutesFromTimes(GetTimeStamp(), TVC.SavedVariables.LastChangeTimeStamp)) end


TVC_GetSecondsFromTimes = function(greater, lower) return (greater - lower) end


TVC_GetMinutesFromTimes = function(greater, lower) return math.floor(TVC_GetSecondsFromTimes(greater, lower) / 60) end


TVC_PrintLog = function(delayed_message)
	TVC_SystemPrint(TVC_NumberFormat(TVC.SavedVariables.CurrentTV) .. TVC_GetTvText() .. TVC_GetMinutesForDisplay(), nil, delayed_message)
end


TVC_GetMinutesFromTimer = function() return math.floor(TVC_GetSecondsFromTimer() / 60) end


TVC_GetMinutesForDisplay = function() return " (" .. TVC_NumberFormat(TVC_GetMinutesFromTimer()) .. " mins) " end


TVC_GetResourceName = function(resourceId)
	local resourceName = ""

	if resourceId > 0 then
		resourceName = GetKeepName(resourceId)

		if not TVC_IsStringEmpty(resourceName) then resourceName = zo_strformat("<<1>>", resourceName) end
	end

	return resourceName or ""
end


TVC_StartTimer1 = function() TVC_StartTimer2(true) end

TVC_StartTimer2 = function(showRunning)
	if TVC_TimerStarted() then
		if showRunning then TVC_SystemPrint("TVC running" .. TVC_GetMinutesForDisplay()) end
	else
		TVC_TryInitTimer()
		TVC_SystemPrint("TVC started")
	end
end


-- Initializes the timer if not initialized
TVC_TryInitTimer = function()
	if TVC_TimerStarted() == false then TVC.SavedVariables.StartTimeStamp = GetTimeStamp() end
end


TVC_GetSecondsFromTimer = function()
	if TVC_TimerStarted() then return (GetTimeStamp() - TVC.SavedVariables.StartTimeStamp)
	else return 0 end
end


--* EVENT_TELVAR_STONE_UPDATE (*integer* _newTelvarStones_, *integer* _oldTelvarStones_, *[CurrencyChangeReason|#CurrencyChangeReason]* _reason_, *integer* _reasonSupplementaryInfo_)
TVC_Update = function(eventCode, newTelvarStones, oldTelvarStones, reason, reasonSupplementaryInfo)
	--TVC_DebugDisplay("Reason -> " .. reason)
	--TVC_DebugDisplay("OLD -> " .. oldTelvarStones)
	--TVC_DebugDisplay("NEW -> " .. newTelvarStones)
	--TVC_DebugDisplay("INFO -> " .. reasonSupplementaryInfo)

	local difference = newTelvarStones - oldTelvarStones

	-- Nothing to calculate
	if (reason == CURRENCY_CHANGE_REASON_BANK_WITHDRAWAL) then return end
	if (reason == CURRENCY_CHANGE_REASON_BANK_DEPOSIT) then return end
	if (reason == CURRENCY_CHANGE_REASON_VENDOR) then return end

	--TODO MESSAGE
	if (reason == CURRENCY_CHANGE_REASON_PLAYER_INIT) then return end

	--TODO RESET ON BANK???

	-- Addon not fully loaded
	if not TVC.SavedVariables then
		TVC_GLOBAL.TV_OnLoading = (TVC_GLOBAL.TV_OnLoading + difference)
		return
	end

	-- Starts the timer if not started
	TVC_TryInitTimer()

	TVC.SavedVariables.LastChangeTimeStamp = GetTimeStamp()
	TVC_GLOBAL.TVSumLog_TV = (TVC_GLOBAL.TVSumLog_TV + difference)

	local current_TV = TVC.SavedVariables.CurrentTV

	-- Must be earlier to fix TV loss if error later happens
	TVC_UpdateTvVariables(reason, difference)

	TVC_TryLogTelVar(reason, current_TV, difference, current_TV + difference, reasonSupplementaryInfo)
	TVC_TryAnnounce(reason, difference, reasonSupplementaryInfo)

	GetAddOnManager():RequestAddOnSavedVariablesPrioritySave(TVC.AddOnName)
end


TVC_TryLogTelVar = function(reason, orgOldTV, orgDiffTV, orgNewTV, resourceId)
	local _oldTV = orgOldTV
	local _diffTV = orgDiffTV
	local _newTV = orgNewTV

	local status = TVC_GetBaseTvSourceInfoForDisplay(reason)

	if (TVC.SavedVariables.LogTVAmount > 1) then
		if (TVC_GLOBAL.TVSumLog_TV > math.abs(orgDiffTV)) then
			status = TV_STATUS_MULTI_SOURCE
		end

		_oldTV = (orgNewTV - TVC_GLOBAL.TVSumLog_TV)
		_diffTV = TVC_GLOBAL.TVSumLog_TV
	end

	local loggedTV = false

	if (math.abs(TVC_GLOBAL.TVSumLog_TV) >= TVC.SavedVariables.LogTVAmount) then
		TVC_GLOBAL.TVSumLog_TV = 0

		if TVC.SavedVariables.LogEnabled then
			loggedTV = true

			if (TVC.SavedVariables.TvLogFormat == TV_LOG_FORMAT_LONG) then
				TVC_SystemPrint(status .. " -> " .. TVC_NumberFormat(_oldTV) .. TVC_GetTvText() .. " " .. TVC_GetStringSign(_diffTV) .. " " .. TVC_NumberFormat(_diffTV) .. TVC_GetTvText() .. " = " .. TVC_NumberFormat(_newTV) .. TVC_GetTvText() .. TVC_GetMinutesForDisplay())
			elseif (TVC.SavedVariables.TvLogFormat == TV_LOG_FORMAT_NORMAL) then
				TVC_SystemPrint(status .. " " .. TVC_GetStringSign(_diffTV) .. TVC_NumberFormat(_diffTV) .. TVC_GetTvText() .. " -> " .. TVC_NumberFormat(_newTV) .. TVC_GetTvText() .. TVC_GetMinutesForDisplay())
			else
				TVC_SystemPrint(status .. " -> " ..  TVC_NumberFormat(_newTV) .. TVC_GetTvText() .. TVC_GetMinutesForDisplay())
			end
		end
	end
end


TVC_TryAnnounce = function(reason, difference, resourceId)
	if (TVC.SavedVariables.UseScreenMessage and TVC.SavedVariables.ScreenMessageTelVarGain <= difference) then
		TVC_FORMS.Functions.DisplayScreenMessage(nil, difference .. TVC_GetTvText(true))
	end
end


TVC_GetStringSign = function (value) return (((value or 0) < 0) and "") or "+" end


TVC_UpdateTvVariables = function(reason, diffTV)
	TVC.SavedVariables.CurrentTV = (TVC.SavedVariables.CurrentTV + diffTV)

	if (reason == CURRENCY_CHANGE_REASON_LOOT) then TVC.SavedVariables.TVFromKL = TVC.SavedVariables.TVFromKL + diffTV
	elseif (reason == CURRENCY_CHANGE_REASON_LOOT_CURRENCY_CONTAINER) then TVC.SavedVariables.TVFromCO = TVC.SavedVariables.TVFromCO + diffTV
	elseif (reason == CURRENCY_CHANGE_REASON_PVP_KILL_TRANSFER) then TVC.SavedVariables.TVFromPK = TVC.SavedVariables.TVFromPK + diffTV
	elseif (reason == CURRENCY_CHANGE_REASON_DEATH) then TVC.SavedVariables.TVFromDL = TVC.SavedVariables.TVFromDL + diffTV
	else TVC.SavedVariables.TVFromU = TVC.SavedVariables.TVFromU + diffTV end
end


TVC_GetBaseTvSourceInfoForDisplay = function(reason)
	if (reason == CURRENCY_CHANGE_REASON_LOOT) then return "KL"
	elseif (reason == CURRENCY_CHANGE_REASON_LOOT_CURRENCY_CONTAINER) then return "CO"
	elseif (reason == CURRENCY_CHANGE_REASON_PVP_KILL_TRANSFER) then return "PK"
	elseif (reason == CURRENCY_CHANGE_REASON_DEATH) then return "DL"
	else return "U(" .. reason .. ")" end
end


TVC_ResetState = function(skipMessage, delayed_message)
	TVC.SavedVariables.StartTimeStamp = nil
	TVC.SavedVariables.CurrentTV = 0
	TVC.SavedVariables.TVFromKL = 0
	TVC.SavedVariables.TVFromCO = 0
	TVC.SavedVariables.TVFromPK = 0
	TVC.SavedVariables.TVFromDL = 0
	TVC.SavedVariables.TVFromU = 0
	TVC_GLOBAL.TVSumLog_TV = 0
	TVC_GLOBAL.TV_OnLoading = 0
	TVC.SavedVariables.LastChangeTimeStamp = GetTimeStamp()

	if (skipMessage ~= true) then TVC_SystemPrint("TVC reseted", nil, delayed_message) end
end


TVC_PrintCommands = function(delayed_message)
	TVC_SystemPrint("TVC slash commands:", nil, delayed_message)
	TVC_SystemPrint("/tvc_commands /tvc_source_info /tvc_data", nil, delayed_message)
	TVC_SystemPrint("/tvc_start /tvc_reset /tvc_statistic", nil, delayed_message)
end


--* EVENT_ADD_ON_LOADED (*string* _addonName_)
TVC_Load = function(eventCode, addonName)
	-- Prevents running this function if the addonName is not the same as this AddOnName, since load is called for all addons more times
    if addonName ~= TVC.AddOnName then return end

    EVENT_MANAGER:UnregisterForEvent(addonName, eventCode)
	
	TVC.SavedVariables = ZO_SavedVars:New(TVC.SavedVariablesFileName, TVC.Version, nil, TVC.Default)
	
	if (TVC.SavedVariables.ShowAvailableCommandsMessageOnStart) then
		TVC_PrintCommands(true)
	end
	
	TVC_FORMS.Functions.Init(TVC.SavedVariables.MainWindowLeft, TVC.SavedVariables.MainWindowBottom)
	TVC_MENU.Init()

	if (TVC.SavedVariables.RestoreTV) then
		if(TVC.SavedVariables.CurrentTV < 1) then
			TVC_SystemPrint("TVC has nothing to restore", nil, true)
			TVC_ResetState(true, true)
		elseif (TVC_CheckIfRestoreIsSkipped()) then
			TVC_SystemPrint("TVC reseted state, restore time elapsed", nil, true)
			TVC_ResetState(true, true)
		else
			if (TVC_GLOBAL.TV_OnLoading > 0) then
				TVC_UpdateTvVariables(nil, TVC_GLOBAL.TV_OnLoading)
				TVC_GLOBAL.TV_OnLoading = 0
			end

			TVC_SystemPrint("TVC restored state:", nil, true)
			TVC_PrintLog(true)
		end
	else TVC_ResetState(true, true) end
end


TVC_CheckStatistic = function()
	if (TVC.SavedVariables.CurrentTV == 0) then TVC_SystemPrint("No data for statistics")
	elseif (TVC_GetMinutesFromTimer() < 10) then TVC_SystemPrint("Statistics available in " .. (10 - TVC_GetMinutesFromTimer()) .. " mins")
	else
		TVC_SystemPrint(TVC_NumberFormat(math.floor((TVC.SavedVariables.CurrentTV / TVC_GetSecondsFromTimer()) * 60)) .. TVC_GetTvText() .. " / min")
		TVC_SystemPrint(TVC_NumberFormat(math.floor((TVC.SavedVariables.CurrentTV / TVC_GetSecondsFromTimer()) * 3600)) .. TVC_GetTvText() .. " / hour")

		local forSort = {}
		TVC_AddForSort(forSort, TVC.SavedVariables.TVFromKL, "KL")
		TVC_AddForSort(forSort, TVC.SavedVariables.TVFromCO, "CO")
		TVC_AddForSort(forSort, TVC.SavedVariables.TVFromPK, "PK")
		TVC_AddForSort(forSort, TVC.SavedVariables.TVFromDL, "DL")
		TVC_AddForSort(forSort, TVC.SavedVariables.TVFromU, "U ")

		TVC_MySortDescending(forSort)

		for i=1,forSort.Length,1 do
			if forSort[i].Value > 0 then TVC_SystemPrint(TVC_PercentStatisticInfo(forSort[i].Value, forSort[i].Data)) end
		end
	end
end


-- forSort needs to be created with TVC_AddForSort
TVC_MySortDescending = function(forSort)
	local sorted = {}
	for i=1,forSort.Length,1 do table.insert(sorted, forSort[i]) end
	table.sort(sorted, function(a,b) return a.Value > b.Value end)
	for i=1,forSort.Length,1 do forSort[i] = sorted[i] end
end


TVC_AddForSort = function(forSort, value, data)
	if (forSort.Length == nil) then forSort.Length = 0 end

	forSort.Length = forSort.Length + 1
	forSort[forSort.Length] = {}
	forSort[forSort.Length].Value = value
	forSort[forSort.Length].Data = data
end


TVC_PercentStatisticInfo = function(sourceTV, sourceInfo) return sourceInfo .. " -> " .. TVC_NumberFormat(sourceTV) .. TVC_GetTvText() .. " -> " .. TVC_Floor((sourceTV / TVC.SavedVariables.CurrentTV) * 100, 2) .. "%" end


TVC_DisplayInfo = function()
	--TVC_SystemPrint("Tel Var loss from Player kill -> " .. (GetTelvarStonePercentLossOnPvpDeath() * 100) .. "%")
	--TVC_SystemPrint("Tel Var loss from NPC kill -> " .. (GetTelvarStonePercentLossOnNonPvpDeath() * 100) .. "%")
	TVC_SystemPrint("KL -> Kill or chest loot")
	TVC_SystemPrint("CO -> Container")
	TVC_SystemPrint("PK -> Player kill")
	TVC_SystemPrint("DL -> Death loss")
	TVC_SystemPrint("U  -> Unknown")
	TVC_SystemPrint(TV_STATUS_MULTI_SOURCE .. " -> Multi source")
end


TVC_Floor = function(num, numDecimalPlaces) return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num)) end


TVC_SystemPrint = function(line1, line2, delayed_message)
	local text = TVC_GetChatTextColor() .. line1 .. "|r"

	if not TVC_IsStringEmpty(line2) then
		text = text .. " \n" .. TVC_GetChatTextColor() .. line2 .. "|r"
	end

	if delayed_message then zo_callLater(function() d(text) end, 1000)
	else d(text) end
end


TVC_GetChatTextColor = function()
	local color = ZO_ColorDef:New(TVC.SavedVariables.LogColor.Red, TVC.SavedVariables.LogColor.Green, TVC.SavedVariables.LogColor.Blue, 1)
	return "|c" .. color:ToHex()
end


TVC_GetTvText = function(is_display_message)
	local tvText = " TV"

	if TVC.SavedVariables.UseTVIcon then
		if is_display_message then tvText = TVC_TEL_VAR_TEXT_ICON_LARGE
		else tvText = TVC_TEL_VAR_TEXT_ICON_SMALL .. TVC_GetChatTextColor() end
	end

	return tvText
end


TVC_IsStringEmpty = function(sValue) return (sValue == nil or sValue == "") end


TVC_DebugDisplay = function(value1, value2)
	local text = value1 or ""

	if not TVC_IsStringEmpty(value2) then text = text .. " : " .. value2 end

	d(text)
end


--* EVENT_PLAYER_ACTIVATED (*bool* _initial_)
TVC_Player_Activated = function(eventCode, initial)
	if (TVC.SavedVariables.StartCounterInImperialCity and IsInImperialCity()) then
		TVC_StartTimer2(false)
	end
end


-- EVENT_OPEN_BANK (*[Bag|#Bag]* _bankBag_)
TVC_Balance_TV = function(event_code, bank_bag)
	if (bank_bag == BAG_BANK and TVC.SavedVariables.UseBalanceTV) then
		local amount = GetCarriedCurrencyAmount(CURT_TELVAR_STONES)

		local diff = (amount - TVC.SavedVariables.BalanceTV)
		if (diff > 0) then
			DepositCurrencyIntoBank(CURT_TELVAR_STONES, diff)

			if TVC.SavedVariables.LogBalance then
				TVC_SystemPrint("[TVC] BANK +" .. TVC_NumberFormat(diff) .. TVC_GetTvText())
			end
		elseif (diff < 0) then
			diff = -diff

			local bank_amount = GetBankedCurrencyAmount(CURT_TELVAR_STONES)
			if (bank_amount > 0) then
				if bank_amount < diff then
					WithdrawCurrencyFromBank(CURT_TELVAR_STONES, bank_amount)

					if TVC.SavedVariables.LogBalance then
						TVC_SystemPrint("[TVC] BANK -" .. TVC_NumberFormat(bank_amount) .. TVC_GetTvText())
					end
				else
					WithdrawCurrencyFromBank(CURT_TELVAR_STONES, diff)

					if TVC.SavedVariables.LogBalance then
						TVC_SystemPrint("[TVC] BANK -" .. TVC_NumberFormat(diff) ..  TVC_GetTvText())
					end
				end
			end
		end
	end
end


TVC_NumberFormat = function(amount)
	local formatted = amount
	local separator = TVC.SavedVariables.Separator

	if separator == TVC_TOOLTIP_SPACE then separator = " " end

	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1" .. separator .. "%2")
		if (k==0) then break end
	end

	return formatted
end


SLASH_COMMANDS["/tvc_commands"]		= 	TVC_PrintCommands
SLASH_COMMANDS["/tvc_start"]		=	TVC_StartTimer1
SLASH_COMMANDS["/tvc_reset"]		= 	TVC_ResetState
SLASH_COMMANDS["/tvc_data"]      	= 	TVC_PrintLog
SLASH_COMMANDS["/tvc_statistic"]	=	TVC_CheckStatistic
SLASH_COMMANDS["/tvc_info"]			=	TVC_DisplayInfo


EVENT_MANAGER:RegisterForEvent("TVC_Load", EVENT_ADD_ON_LOADED, TVC_Load)
EVENT_MANAGER:RegisterForEvent("TVC_Update", EVENT_TELVAR_STONE_UPDATE, TVC_Update)
EVENT_MANAGER:RegisterForEvent("TVC_Player_Activated", EVENT_PLAYER_ACTIVATED, TVC_Player_Activated)
EVENT_MANAGER:RegisterForEvent("TVC_Balance_TV", EVENT_OPEN_BANK, TVC_Balance_TV)