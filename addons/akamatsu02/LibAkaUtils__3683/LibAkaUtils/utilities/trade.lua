LibAkaUtils = LibAkaUtils or {}
LibAkaUtils.tradelistening = nil
LibAkaUtils.autoAcceptTrade = false
LibAkaUtils.tradeData = {
	target = nil,
	moneyThey = 0,
	moneyMe = 0
}

local TRADE_EVENT = "EVENT_TRADE"
local TRADE_EVENT_START = "EVENT_TRADE_START"

function LibAkaUtils.ResetTrade()
	LibAkaUtils.tradeData = {
		target = nil,
		moneyThey = 0,
		moneyMe = 0
	}
end

function LibAkaUtils.HandleInviteTrade(_, _, inviterDisplayName)
	if LibAkaUtils.autoAcceptTrade == true then
		TradeInviteAccept()
	end
	LibAkaUtils.ResetTrade()
	LibAkaUtils.tradeData.target = inviterDisplayName
end

function LibAkaUtils.HandleMoneyChanged(_, who, money)
	if LibAkaUtils.tradeData.target == nil then return end
	if who == TRADE_THEM then
		LibAkaUtils.tradeData.moneyThey = money
	else
		LibAkaUtils.tradeData.moneyMe = money
	end
end

function LibAkaUtils.HandleTradeSuccess()
	if LibAkaUtils.tradeData.target == nil then return end
	LibAkaUtils.FireEvent(TRADE_EVENT, LibAkaUtils.tradeData.target, LibAkaUtils.tradeData.moneyThey, LibAkaUtils.tradeData.moneyMe)
	LibAkaUtils.HandleTradeCanceled()
end

function LibAkaUtils.HandleTradeCanceled()
	LibAkaUtils.ResetTrade()
end

function LibAkaUtils.HandleConfirmationChange(_, who)
	if LibAkaUtils.autoAcceptTrade == false then return end
	if who == TRADE_ME then
		if LibAkaUtils.tradeData.moneyThey > 0 and LibAkaUtils.tradeData.moneyMe == 0 then
			TradeAccept()
		end
	end
end

function LibAkaUtils.HandleTradeStart()
	if LibAkaUtils.tradeData.target == nil then return end
	LibAkaUtils.FireEvent(TRADE_EVENT_START, LibAkaUtils.tradeData.target)
end

function LibAkaUtils.SetupTradeListener()
	if LibAkaUtils.tradelistening == true then return end
	LibAkaUtils.tradelistening = true
	
	EVENT_MANAGER:RegisterForEvent(LibAkaUtils.name.."_EVENT_TRADE_MONEY_CHANGED", EVENT_TRADE_MONEY_CHANGED, LibAkaUtils.HandleMoneyChanged)
	
	EVENT_MANAGER:RegisterForEvent(LibAkaUtils.name.."_EVENT_TRADE_SUCCEEDED", EVENT_TRADE_SUCCEEDED, LibAkaUtils.HandleTradeSuccess)
	EVENT_MANAGER:RegisterForEvent(LibAkaUtils.name.."_EVENT_TRADE_FAILED", EVENT_TRADE_FAILED, LibAkaUtils.HandleTradeCanceled)
	EVENT_MANAGER:RegisterForEvent(LibAkaUtils.name.."_EVENT_TRADE_CANCELED", EVENT_TRADE_CANCELED, LibAkaUtils.HandleTradeCanceled)
	
	EVENT_MANAGER:RegisterForEvent(LibAkaUtils.name.."_EVENT_TRADE_INVITE_ACCEPTED", EVENT_TRADE_INVITE_ACCEPTED, LibAkaUtils.HandleTradeStart)
	
	EVENT_MANAGER:RegisterForEvent(LibAkaUtils.name.."_EVENT_TRADE_INVITE_CANCELED", EVENT_TRADE_INVITE_CANCELED, LibAkaUtils.HandleTradeCanceled)
	EVENT_MANAGER:RegisterForEvent(LibAkaUtils.name.."_EVENT_TRADE_INVITE_DECLINED", EVENT_TRADE_INVITE_DECLINED, LibAkaUtils.HandleTradeCanceled)
	
	EVENT_MANAGER:RegisterForEvent(LibAkaUtils.name.."_EVENT_TRADE_INVITE_WAITING", EVENT_TRADE_INVITE_WAITING, LibAkaUtils.HandleInviteTrade)
	EVENT_MANAGER:RegisterForEvent(LibAkaUtils.name.."_EVENT_TRADE_INVITE_CONSIDERING", EVENT_TRADE_INVITE_CONSIDERING, LibAkaUtils.HandleInviteTrade)
	
	EVENT_MANAGER:RegisterForEvent(LibAkaUtils.name.."_EVENT_TRADE_CONFIRMATION_CHANGED", EVENT_TRADE_CONFIRMATION_CHANGED, LibAkaUtils.HandleConfirmationChange)
end

function LibAkaUtils.AddTradeListener(name, func, func2, autoAccept)
	LibAkaUtils.AddListener(TRADE_EVENT, name, func)
	LibAkaUtils.AddListener(TRADE_EVENT_START, name, func2)
	LibAkaUtils.SetupTradeListener()
	if LibAkaUtils.autoAcceptTrade == false then
		LibAkaUtils.autoAcceptTrade = autoAccept
	end
end

function LibAkaUtils.RemoveTradeListener(name)
	LibAkaUtils.RemoveListener(TRADE_EVENT, name)
	LibAkaUtils.RemoveListener(TRADE_EVENT_START, name)
end