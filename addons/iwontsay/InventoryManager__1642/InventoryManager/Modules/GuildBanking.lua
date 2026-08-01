local DEBUG =
function() end
-- d

local function _tr(str)
	return str
end

if not InventoryManager then InventoryManager = {} end
local IM = InventoryManager

local current_gn = nil
local sequence_count = nil

local function finish_gb_transfers()
	local result
	result = GetString(IM_BANK_OK)
	
	if result ~= "" then
		CHAT_SYSTEM:AddMessage(result)
	end
end

local function filter_for_gb_retrieve(data)
	if current_gn ~= data.guildbank then
		DEBUG(" -- filter_for_gb_retrieve: Item intended for different bank")
		return false
	end
	
	return true
end

local function finish_gb_stashes()
	IM:EventProcessBag(BAG_GUILDBANK, IM.ACTION_GB_RETRIEVE,
		filter_for_gb_retrieve,
		function(data) IM:ProcessSingleItem(false, data) end,
		finish_gb_transfers,
		EVENT_GUILD_BANK_ITEM_REMOVED,
		EVENT_CLOSE_GUILD_BANK,
		IM.settings.bankMoveDelay)
end

local function filter_for_gb_stash(data)
	if data.stolen then return false end
	
	if current_gn ~= data.guildbank then
		DEBUG(" -- filter_for_gb_stash: Item intended for different bank")
		return false
	end
	
	if IM.FCOISL:IsProtectedAction(
		IM.ACTION_SELL, -- Maybe another action.
		data.bagId,
		data.slotId,
		fence) then return false end
	return true
end

local function doStashGuildBank()
	IM:EventProcessBag(BAG_BACKPACK, IM.ACTION_GB_STASH,
		filter_for_gb_stash,
		function(data) IM:ProcessSingleItem(false, data) end,
		finish_gb_stashes,
		EVENT_GUILD_BANK_ITEM_ADDED,
		EVENT_CLOSE_GUILD_BANK,
		IM.settings.bankMoveDelay)
end

local function trySettleGuildBank(old_sequence_count)
	DEBUG("--- trySettleGuildBank: old_sequence_count=" .. old_sequence_count .. ", sequence_count=" .. sequence_count)
	if old_sequence_count ~= sequence_count then
		zo_callLater(function() trySettleGuildBank(sequence_count) end, 1000)
		return
	end
	
	DEBUG("No new event fired, seems we're good to go.")
	doStashGuildBank()
end

function received_event()
	local gid = GetSelectedGuildBankId()
	local gn = GetGuildName(gid)

	DEBUG(" -- received_event: gn=" .. gn .. ", current_gn = " .. (current_gn or "(nil)"))
	
	if gn ~= current_gn then
		current_gn = gn
		sequence_count = 0
		DEBUG("Starting settle loop...")
		zo_callLater(function() trySettleGuildBank(sequence_count) end, IM.settings.bankInitDelay + 2000)
	else
		sequence_count = sequence_count + 1
	end
end

function IM:OnGuildBankReady()
	received_event()
end

function IM:OnGuildBankOpened()
	current_gn = ""
	sequence_count = 0
	received_event()
end

EVENT_MANAGER:RegisterForEvent(InventoryManager.name, EVENT_GUILD_BANK_ITEMS_READY, function() IM:OnGuildBankReady() end)
EVENT_MANAGER:RegisterForEvent(InventoryManager.name, EVENT_OPEN_GUILD_BANK, function() IM:OnGuildBankOpened() end)
