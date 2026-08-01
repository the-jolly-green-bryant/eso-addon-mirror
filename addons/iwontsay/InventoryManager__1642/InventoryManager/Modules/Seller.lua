local DEBUG =
-- function() end
d

local function _tr(str)
	return str
end

if not InventoryManager then InventoryManager = {} end
local IM = InventoryManager

local _Gain = nil

local function do_sell(data, eventCode, itemName, itemQuantity, money) 
	if eventCode ~= nil then
		_Gain = _Gain + money
	end
	IM:ProcessSingleItem(false, data)
end

local function filter_for_sale(fence, data)
	if data.stolen ~= fence then return false end
	
	if IM.FCOISL:IsProtectedAction(
		IM.ACTION_SELL,
		data.bagId,
		data.slotId,
		fence) then return false end
	return true
end

local function filter_for_launder(data)
	if IM.FCOISL:IsProtectedAction(
		IM.ACTION_LAUNDER,
		data.bagId,
		data.slotId) then return false end
	return true
end

function IM:ReportASState(currently)
	local currentlystr
	if(currently) then
		currentlystr = GetString(IM_LOG_ASSTATE_CURRENTLY)
	end
	if(IM.settings.autosell) then
		CHAT_SYSTEM:AddMessage(zo_strformat(GetString(IM_LOG_ASSTATE_ON), currentlystr))
	else
		CHAT_SYSTEM:AddMessage(zo_strformat(GetString(IM_LOG_ASSTATE_OFF), currentlystr))
	end
end

function IM:SellItems(stolen)
	local list = { }
	local end_fn = function(abort, eventCode, itemName, itemQuantity, money)
			if eventCode ~= nil then
				_Gain = _Gain + money
			end
			CHAT_SYSTEM:AddMessage(zo_strformat(GetString(IM_CUR_SOLDJUNK), _Gain))
		end

	local launder_run = function(abort, eventCode, itemName, itemQuantity, money)
		if eventCode ~= nil then
			_Gain = _Gain + money
		end
		IM.currentRuleset:ResetCounters()
		IM:EventProcessBag(BAG_BACKPACK, IM.ACTION_LAUNDER,
			filter_for_launder,
			function(data) IM:ProcessSingleItem(false, data) end,
			function(abort) end_fn(abort) end,
			EVENT_ITEM_LAUNDER_RESULT,
			EVENT_CLOSE_STORE,
			IM.settings.bankMoveDelay)
		end

	_Gain = 0
	IM.currentRuleset:ResetCounters()
	self:EventProcessBag(BAG_BACKPACK, IM.ACTION_SELL,
		function(data) return filter_for_sale(stolen, data) end,
		do_sell,
		((stolen and launder_run) or end_fn),
		EVENT_SELL_RECEIPT,
		EVENT_CLOSE_STORE,
		IM.settings.bankMoveDelay)
		
end

local function OnOpenStore(eventCode)
	if IM.settings.autosell then
		IM:SellItems(false)
	end
end

local function OnOpenFence(eventCode)
	if IM.settings.autosell then
		IM:SellItems(true)
	end
end

EVENT_MANAGER:RegisterForEvent(IM.name, EVENT_OPEN_STORE, OnOpenStore)
EVENT_MANAGER:RegisterForEvent(IM.name, EVENT_OPEN_FENCE, OnOpenFence)
