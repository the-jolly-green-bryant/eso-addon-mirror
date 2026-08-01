--[[
	Addon: CurrencyBalancer
	Author: Mladen90
	Created by @Mladen90
]]--


CurrencyBalancer = {}
CurrencyBalancer_MENU = {}


CurrencyBalancer_IsStringEmpty = function(sValue) return (sValue == nil or sValue == "") end


CurrencyBalancer_SystemPrint = function(line1, line2, r, g, b)
	local text_color = CurrencyBalancer_GetChatTextColor(r, g, b)

	local text = text_color .. line1 .. "|r"
	if not CurrencyBalancer_IsStringEmpty(line2) then
		text = text .. " \n" .. text_color .. line2 .. "|r"
	end

	d(text)
end


CurrencyBalancer_SystemPrint_Log = function(line1, line2)
	CurrencyBalancer_SystemPrint(line1, line2, CurrencyBalancer.SavedVariables.LogColor.Red, CurrencyBalancer.SavedVariables.LogColor.Green, CurrencyBalancer.SavedVariables.LogColor.Blue)
end


CurrencyBalancer_SystemPrint_Warning = function(line1, line2)
	CurrencyBalancer_SystemPrint(line1, line2, CurrencyBalancer.SavedVariables.LogWarningColor.Red, CurrencyBalancer.SavedVariables.LogWarningColor.Green, CurrencyBalancer.SavedVariables.LogWarningColor.Blue)
end


CurrencyBalancer_GetChatTextColor = function(r, g, b)
	local color = ZO_ColorDef:New(r, g, b, 1)
	return "|c" .. color:ToHex()
end


CurrencyBalancer_GetChatTextColor_Log = function()
	return CurrencyBalancer_GetChatTextColor(CurrencyBalancer.SavedVariables.LogColor.Red, CurrencyBalancer.SavedVariables.LogColor.Green, CurrencyBalancer.SavedVariables.LogColor.Blue)
end


CurrencyBalancer_GetChatTextColor_Warning = function()
	return CurrencyBalancer_GetChatTextColor(CurrencyBalancer.SavedVariables.LogWarningColor.Red, CurrencyBalancer.SavedVariables.LogWarningColor.Green, CurrencyBalancer.SavedVariables.LogWarningColor.Blue)
end


CurrencyBalancer_NumberFormat = function(amount)
	local formatted = amount

	local separator = CurrencyBalancer.SavedVariables.Separator
	if separator == CURRENCY_BALANCER_EMPTY then return formatted end
	if separator == CURRENCY_BALANCER_SPACE then separator = " " end

	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1" .. separator .. "%2")
		if (k==0) then break end
	end

	return formatted
end


-- EVENT_ADD_ON_LOADED (*string* _addonName_)
CurrencyBalancer_Load = function(eventCode, addonName)
	-- Prevents running this function if the addonName is not the same as this AddOnName, since load is called for all addons more times
    if addonName ~= CurrencyBalancer.AddOnName then return end
	
    EVENT_MANAGER:UnregisterForEvent(addonName, eventCode)
	
	CurrencyBalancer.SavedVariables = ZO_SavedVars:New(CurrencyBalancer.SavedVariablesFileName, CurrencyBalancer.Version, nil, CurrencyBalancer.Default)

	CurrencyBalancer_MENU.Init()

	zo_callLater(function()
		CurrencyBalancer_TV_Warning()
		CurrencyBalancer_TransmuteCrystal_Warning()
		CurrencyBalancer_EventTicket_Warning()
	end, 5000) -- after 5 sec first time
end


-- EVENT_OPEN_BANK (*[Bag|#Bag]* _bankBag_)
CurrencyBalancer_OnOpenBank = function(event_code, bank_bag)
	if bank_bag == BAG_BANK then
		CurrencyBalancer_Balance_Gold()
		CurrencyBalancer_Balance_AlliancePoint()
		CurrencyBalancer_Balance_TelVar()
		CurrencyBalancer_Balance_WritVoucher()
	end
end


CurrencyBalancer_GetText_Gold_Log = function() return CURRENCY_BALANCER_GOLD_TEXT_ICON .. CurrencyBalancer_GetChatTextColor_Log() end
CurrencyBalancer_GetText_WritVoucher_Log = function() return CURRENCY_BALANCER_WRIT_VOUCHER_TEXT_ICON .. CurrencyBalancer_GetChatTextColor_Log() end
CurrencyBalancer_GetText_AlliancePoint_Log = function() return CURRENCY_BALANCER_ALLIANCE_POINT_TEXT_ICON .. CurrencyBalancer_GetChatTextColor_Log() end
CurrencyBalancer_GetText_TelVar_Log = function() return CURRENCY_BALANCER_TEL_VAR_TEXT_ICON .. CurrencyBalancer_GetChatTextColor_Log() end


CurrencyBalancer_GetText_TelVar_Warning = function() return CURRENCY_BALANCER_TEL_VAR_TEXT_ICON .. CurrencyBalancer_GetChatTextColor_Warning() end
CurrencyBalancer_GetText_EventTicket_Warning = function() return CURRENCY_BALANCER_EVENT_TICKET_TEXT_ICON .. CurrencyBalancer_GetChatTextColor_Warning() end
CurrencyBalancer_GetText_TransmuteCrystal_Warning = function() return CURRENCY_BALANCER_TRANSMUTE_CRYSTAL_TEXT_ICON .. CurrencyBalancer_GetChatTextColor_Warning() end


CurrencyBalancer_Balance_Gold = function()
	if (CurrencyBalancer.SavedVariables.UseBalanceGold) then
		local amount = GetCarriedCurrencyAmount(CURT_MONEY)

		local diff = (amount - CurrencyBalancer.SavedVariables.BalanceGold)
		if (diff > 0) then
			DepositCurrencyIntoBank(CURT_MONEY, diff)

			if CurrencyBalancer.SavedVariables.LogBalanceGold then
				CurrencyBalancer_SystemPrint_Log("[CB] BANK +" .. CurrencyBalancer_NumberFormat(diff) .. CurrencyBalancer_GetText_Gold_Log())
			end
		elseif (diff < 0) then
			diff = -diff

			local bank_amount = GetBankedCurrencyAmount(CURT_MONEY)
			if (bank_amount > 0) then
				if bank_amount < diff then
					WithdrawCurrencyFromBank(CURT_MONEY, bank_amount)

					if CurrencyBalancer.SavedVariables.LogBalanceGold then
						CurrencyBalancer_SystemPrint_Log("[CB] BANK -" .. CurrencyBalancer_NumberFormat(bank_amount) .. CurrencyBalancer_GetText_Gold_Log())
					end
				else
					WithdrawCurrencyFromBank(CURT_MONEY, diff)

					if CurrencyBalancer.SavedVariables.LogBalanceGold then
						CurrencyBalancer_SystemPrint_Log("[CB] BANK -" .. CurrencyBalancer_NumberFormat(diff) ..  CurrencyBalancer_GetText_Gold_Log())
					end
				end
			end
		end
	end
end


CurrencyBalancer_Balance_AlliancePoint = function()
	if (CurrencyBalancer.SavedVariables.UseBalanceAP) then
		if (APC and APC.SavedVariables and APC.SavedVariables.UseBalanceAP) then
			CurrencyBalancer_SystemPrint("[CB] AP Balance conflict with [APC]", nil, 1, 0, 0)
			return
		end

		local amount = GetCarriedCurrencyAmount(CURT_ALLIANCE_POINTS)

		local diff = (amount - CurrencyBalancer.SavedVariables.BalanceAP)
		if (diff > 0) then
			DepositCurrencyIntoBank(CURT_ALLIANCE_POINTS, diff)

			if CurrencyBalancer.SavedVariables.LogBalanceAP then
				CurrencyBalancer_SystemPrint_Log("[CB] BANK +" .. CurrencyBalancer_NumberFormat(diff) .. CurrencyBalancer_GetText_AlliancePoint_Log())
			end
		elseif (diff < 0) then
			diff = -diff

			local bank_amount = GetBankedCurrencyAmount(CURT_ALLIANCE_POINTS)
			if (bank_amount > 0) then
				if bank_amount < diff then
					WithdrawCurrencyFromBank(CURT_ALLIANCE_POINTS, bank_amount)

					if CurrencyBalancer.SavedVariables.LogBalanceAP then
						CurrencyBalancer_SystemPrint_Log("[CB] BANK -" .. CurrencyBalancer_NumberFormat(bank_amount) .. CurrencyBalancer_GetText_AlliancePoint_Log())
					end
				else
					WithdrawCurrencyFromBank(CURT_ALLIANCE_POINTS, diff)

					if CurrencyBalancer.SavedVariables.LogBalanceAP then
						CurrencyBalancer_SystemPrint_Log("[CB] BANK -" .. CurrencyBalancer_NumberFormat(diff) ..  CurrencyBalancer_GetText_AlliancePoint_Log())
					end
				end
			end
		end
	end
end


CurrencyBalancer_Balance_TelVar = function()
	if (CurrencyBalancer.SavedVariables.UseBalanceTV) then
		if (TVC and TVC.SavedVariables and TVC.SavedVariables.UseBalanceTV) then
			CurrencyBalancer_SystemPrint("[CB] TV Balance conflict with [TVC]", nil, 1, 0, 0)
			return
		end

		local amount = GetCarriedCurrencyAmount(CURT_TELVAR_STONES)

		local diff = (amount - CurrencyBalancer.SavedVariables.BalanceTV)
		if (diff > 0) then
			DepositCurrencyIntoBank(CURT_TELVAR_STONES, diff)

			if CurrencyBalancer.SavedVariables.LogBalanceTV then
				CurrencyBalancer_SystemPrint_Log("[CB] BANK +" .. CurrencyBalancer_NumberFormat(diff) .. CurrencyBalancer_GetText_TelVar_Log())
			end
		elseif (diff < 0) then
			diff = -diff

			local bank_amount = GetBankedCurrencyAmount(CURT_TELVAR_STONES)
			if (bank_amount > 0) then
				if bank_amount < diff then
					WithdrawCurrencyFromBank(CURT_TELVAR_STONES, bank_amount)

					if CurrencyBalancer.SavedVariables.LogBalanceTV then
						CurrencyBalancer_SystemPrint_Log("[CB] BANK -" .. CurrencyBalancer_NumberFormat(bank_amount) .. CurrencyBalancer_GetText_TelVar_Log())
					end
				else
					WithdrawCurrencyFromBank(CURT_TELVAR_STONES, diff)

					if CurrencyBalancer.SavedVariables.LogBalanceTV then
						CurrencyBalancer_SystemPrint_Log("[CB] BANK -" .. CurrencyBalancer_NumberFormat(diff) ..  CurrencyBalancer_GetText_TelVar_Log())
					end
				end
			end
		end
	end
end


CurrencyBalancer_Balance_WritVoucher = function()
	if (CurrencyBalancer.SavedVariables.UseBalanceWritVoucher) then
		local amount = GetCarriedCurrencyAmount(CURT_WRIT_VOUCHERS)

		local diff = (amount - CurrencyBalancer.SavedVariables.BalanceWritVoucher)
		if (diff > 0) then
			DepositCurrencyIntoBank(CURT_WRIT_VOUCHERS, diff)

			if CurrencyBalancer.SavedVariables.LogBalanceWritVoucher then
				CurrencyBalancer_SystemPrint_Log("[CB] BANK +" .. CurrencyBalancer_NumberFormat(diff) .. CurrencyBalancer_GetText_WritVoucher_Log())
			end
		elseif (diff < 0) then
			diff = -diff

			local bank_amount = GetBankedCurrencyAmount(CURT_WRIT_VOUCHERS)
			if (bank_amount > 0) then
				if bank_amount < diff then
					WithdrawCurrencyFromBank(CURT_WRIT_VOUCHERS, bank_amount)

					if CurrencyBalancer.SavedVariables.LogBalanceWritVoucher then
						CurrencyBalancer_SystemPrint_Log("[CB] BANK -" .. CurrencyBalancer_NumberFormat(bank_amount) .. CurrencyBalancer_GetText_WritVoucher_Log())
					end
				else
					WithdrawCurrencyFromBank(CURT_WRIT_VOUCHERS, diff)

					if CurrencyBalancer.SavedVariables.LogBalanceWritVoucher then
						CurrencyBalancer_SystemPrint_Log("[CB] BANK -" .. CurrencyBalancer_NumberFormat(diff) ..  CurrencyBalancer_GetText_WritVoucher_Log())
					end
				end
			end
		end
	end
end


local last_tv_repeat = 0
CurrencyBalancer_TV_Warning = function(amount, is_repeat)
	if CurrencyBalancer.SavedVariables.UseWarningTV then
		amount = amount or GetCarriedCurrencyAmount(CURT_TELVAR_STONES)

		if (CurrencyBalancer.SavedVariables.WarningTV <= amount) then
			if last_tv_repeat == 0 or is_repeat then
				if last_tv_repeat < CurrencyBalancer.SavedVariables.Repeat_TV_Warning then
					last_tv_repeat = last_tv_repeat + 1	
					CurrencyBalancer_SystemPrint_Warning("[CB] WARNING " .. CurrencyBalancer_NumberFormat(amount) .. CurrencyBalancer_GetText_TelVar_Warning())
					zo_callLater(function() CurrencyBalancer_TV_Warning(nil, true) end, CurrencyBalancer.SavedVariables.WarningTimer * 1000)
				end
			end
		else
			last_tv_repeat = 0
		end
	else
		last_tv_repeat = 0
	end
end


local last_event_ticket_repeat = 0
CurrencyBalancer_EventTicket_Warning = function(amount, is_repeat)
	if CurrencyBalancer.SavedVariables.UseWarningEventTicket then
		amount = amount or GetCurrencyAmount(CURT_EVENT_TICKETS, CURRENCY_LOCATION_ACCOUNT)

		if (CurrencyBalancer.SavedVariables.WarningEventTicket <= amount) then
			if last_event_ticket_repeat == 0 or is_repeat then
				if last_event_ticket_repeat < CurrencyBalancer.SavedVariables.Repeat_EventTicket_Warning then
					last_event_ticket_repeat = last_event_ticket_repeat + 1
					CurrencyBalancer_SystemPrint_Warning("[CB] WARNING " .. CurrencyBalancer_NumberFormat(amount) .. CurrencyBalancer_GetText_EventTicket_Warning())
					zo_callLater(function() CurrencyBalancer_EventTicket_Warning(nil, true) end, CurrencyBalancer.SavedVariables.WarningTimer * 1000)
				end
			end
		else
			last_event_ticket_repeat = 0
		end
	else
		last_event_ticket_repeat = 0
	end
end


local last_transmute_crystal_repeat = 0
CurrencyBalancer_TransmuteCrystal_Warning = function(amount, is_repeat)
	if CurrencyBalancer.SavedVariables.UseWarningTransmuteCrystal then
		amount = amount or GetCurrencyAmount(CURT_CHAOTIC_CREATIA, CURRENCY_LOCATION_ACCOUNT)

		if (CurrencyBalancer.SavedVariables.WarningTransmuteCrystal <= amount) then
			if last_transmute_crystal_repeat == 0 or is_repeat then
				if last_transmute_crystal_repeat < CurrencyBalancer.SavedVariables.Repeat_TransmuteCrystal_Warning then
					last_transmute_crystal_repeat = last_transmute_crystal_repeat + 1	
					CurrencyBalancer_SystemPrint_Warning("[CB] WARNING " .. CurrencyBalancer_NumberFormat(amount) .. CurrencyBalancer_GetText_TransmuteCrystal_Warning())
					zo_callLater(function() CurrencyBalancer_TransmuteCrystal_Warning(nil, true) end, CurrencyBalancer.SavedVariables.WarningTimer * 1000)
				end
			end
		else
			last_transmute_crystal_repeat = 0
		end
	else
		last_transmute_crystal_repeat = 0
	end
end


-- EVENT_CURRENCY_UPDATE (*[CurrencyType|#CurrencyType]* _currencyType_, *[CurrencyLocation|#CurrencyLocation]* _currencyLocation_, *integer* _newAmount_, *integer* _oldAmount_, *[CurrencyChangeReason|#CurrencyChangeReason]* _reason_, *integer* _reasonSupplementaryInfo_)
CurrencyBalancer_CurrencyUpdate = function (eventCode, currencyType, currencyLocation, newAmount, oldAmount, reason, reasonSupplementaryInfo)
	if currencyLocation == CURRENCY_LOCATION_BANK or currencyLocation == CURRENCY_LOCATION_GUILD_BANK then return end

	-- Warnings
	if currencyLocation == CURRENCY_LOCATION_ACCOUNT or currencyLocation == CURRENCY_LOCATION_CHARACTER then
		if currencyType == CURT_TELVAR_STONES then
			CurrencyBalancer_TV_Warning(newAmount)
			return
		end

		if currencyType == CURT_EVENT_TICKETS then
			CurrencyBalancer_EventTicket_Warning(newAmount)
			return
		end

		if currencyType == CURT_CHAOTIC_CREATIA then
			CurrencyBalancer_TransmuteCrystal_Warning(newAmount)
			return
		end
	end
end


EVENT_MANAGER:RegisterForEvent("CurrencyBalancer_Load", EVENT_ADD_ON_LOADED, CurrencyBalancer_Load)
EVENT_MANAGER:RegisterForEvent("CurrencyBalancer_OnOpenBank", EVENT_OPEN_BANK, CurrencyBalancer_OnOpenBank)
EVENT_MANAGER:RegisterForEvent("CurrencyBalancer_CurrencyUpdate", EVENT_CURRENCY_UPDATE, CurrencyBalancer_CurrencyUpdate)