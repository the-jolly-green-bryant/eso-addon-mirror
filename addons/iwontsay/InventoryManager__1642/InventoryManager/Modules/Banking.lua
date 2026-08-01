local DEBUG =
-- function() end
d

local function _tr(str)
	return str
end

if not InventoryManager then InventoryManager = {} end
local IM = InventoryManager

local RevCaches = nil
local Empties = nil
local Moves = nil

local function CreateReverseCache(bagType)
	local _revCache = { }
	local _empties = { }
	
	for i = 0, GetBagUseableSize(bagType)-1, 1 do
		local curStack, maxStack = GetSlotStackSize(bagType, i)
		if curStack > 0 then
			local id = GetItemInstanceId(bagType, i)
			if curStack < maxStack then
				if not _revCache[id] then _revCache[id] = { } end
				local entry = _revCache[id]
				entry[i] = { curStack, maxStack }
			end
		else
			_empties[#_empties + 1] = i
		end
	end
	return _revCache, _empties
end

local function CreateReverseCaches()
	RevCaches = { }
	Empties = { }
	RevCaches[BAG_SUBSCRIBER_BANK],	Empties[BAG_SUBSCRIBER_BANK] 	= CreateReverseCache(BAG_SUBSCRIBER_BANK)
	RevCaches[BAG_BACKPACK], 		Empties[BAG_BACKPACK] 			= CreateReverseCache(BAG_BACKPACK)
	RevCaches[BAG_BANK], 			Empties[BAG_BANK] 				= CreateReverseCache(BAG_BANK)
end

local function UpdateCaches(srcBagType, srcSlotId, tgtBagType, tgtSlotId, count)
	local id = GetItemInstanceId(srcBagType, srcSlotId)
	local stack
	
	stack = RevCaches[srcBagType][id] and RevCaches[srcBagType][id][srcSlotId]
	if stack then
		stack[1] = stack[1] - count
		if stack[1] == 0 then
			local newempties = Empties[srcBagType]
			newempties[#newempties + 1] = srcSlotId
			RevCaches[srcBagType][id][srcSlotId] = nil
		end
	else
		local newempties = Empties[srcBagType]
		newempties[#newempties + 1] = srcSlotId
	end
	
	stack = RevCaches[tgtBagType][id] and RevCaches[tgtBagType][id][tgtSlotId]
	if stack then
		stack[1] = stack[1] + count
		if stack[1] == stack[2] then
			RevCaches[tgtBagType][id][tgtSlotId] = nil
		end
	else
		local _, maxStack = GetSlotStackSize(srcBagType, srcSlotId)
		if count < maxStack then
			-- We ended up with a new incomplete stack.
			if not RevCaches[tgtBagType][id] then RevCaches[tgtBagType][id] = { } end
			local newstack = RevCaches[tgtBagType][id]
			newstack[tgtSlotId] = { count, maxStack }
		end	
	end
end

-- Returns tgtSlotId, count
local function FindStackToFill(id, count, tgtBagType)
	local stacks = RevCaches[tgtBagType][id]
	if not stacks then return nil end
	
	local tgtSlotId = nil
	local tgtCount = 0
	
	for slotId, v in pairs(stacks) do
		local missing = v[2] - v[1]
		if missing >= count then return slotId, count end
		if missing > tgtCount then
			tgtSlotId = slotId
			tgtCount = missing
		end
	end
	
	return tgtSlotId, tgtCount
end

-- Returns (empties source?), tgtSlotId, transferCount, tgtBagType
-- We try the subscriber bank before the regular one, to keep the slots of the regular one free in case
-- someone unsubs.
local function FindTargetSlot(srcBagType, srcSlotId, tgtBagType)
	local curStack, _ = GetSlotStackSize(srcBagType, srcSlotId)
	local id = GetItemInstanceId(srcBagType, srcSlotId)

	local tgtSlotId = nil
	local transferCount = nil
	
	-- Try the subscriber bank before the regular one if we target the bank
	if tgtBagType == BAG_BANK then
		tgtSlotId, transferCount = FindStackToFill(id, curStack, BAG_SUBSCRIBER_BANK)
	end
	if tgtSlotId ~= nil then
		tgtBagType = BAG_SUBSCRIBER_BANK
	else
		tgtSlotId, transferCount = FindStackToFill(id, curStack, tgtBagType)
	end
	
	if tgtSlotId ~= nil then
		UpdateCaches(srcBagType, srcSlotId, tgtBagType, tgtSlotId, transferCount)
		return ( transferCount == curStack ), tgtSlotId, transferCount, tgtBagType
	end

	-- All the stacks we might have found are already full, we need to find a free slot
	local empties = { }

	-- Again, try the subscriber bank before the regular one if we target the bank
	if tgtBagType == BAG_BANK then
		empties = Empties[BAG_SUBSCRIBER_BANK]
	end
	
	if #empties ~= 0 then
		tgtBagType = BAG_SUBSCRIBER_BANK
	else
		empties = Empties[tgtBagType]
	end
	
	-- No such luck?
	if #empties == 0 then return false, -1, 0, tgtBagType end
	
	-- It's a complete move, remove the empty slot from the target list
	tgtSlotId = empties[#empties]
	empties[#empties] = nil

	UpdateCaches(srcBagType, srcSlotId, tgtBagType, tgtSlotId, curStack)
	return true, tgtSlotId, curStack, tgtBagType
	
end


local function CollectSingleDirection(action, bagType)
	local _moveSlots = { }
	
	InventoryManager:SetCurrentInventory(bagType)
	
	for i,_ in pairs(InventoryManager.currentInventory) do
		local data = InventoryManager:GetItemData(i)
		if action == InventoryManager.currentRuleset:Match(data, action) then
			_moveSlots[#_moveSlots + 1] = i
		end
	end
	return _moveSlots
end

local function CalculateSingleMove(srcBagType, tgtBagType)
	
	local srcSlotRepo = Moves[srcBagType]
	
	-- If we draw from the pending moves from the regular bank and there are none,
	-- try the subscriber bank.
	if #srcSlotRepo == 0 and srcBagType == BAG_BANK then
		srcBagType = BAG_SUBSCRIBER_BANK
		srcSlotRepo = Moves[srcBagType]
	end
	
	if #srcSlotRepo == 0 then return "src_empty" end

	local srcSlotId = srcSlotRepo[#srcSlotRepo]
	
	-- if we target the bank, FindTargetSlot returns the subscriber bank first, if possible
	local empties, tgtSlotId, count
	empties, tgtSlotId, count, tgtBagType = FindTargetSlot(srcBagType, srcSlotId, tgtBagType) 
	
	if count == 0 then return "tgt_full" end
	
	if empties then srcSlotRepo[#srcSlotRepo] = nil end
	
	return "ok", { 
		["srcbag"] = srcBagType,
		["srcslot"] = srcSlotId,
		["tgtbag"] = tgtBagType,
		["tgtslot"] = tgtSlotId,
		["count"] = count
	}
end

local function CalculateMoves()
	-- Prepare an overview of the inventories and the pending transfers in both directions
	CreateReverseCaches()
	local continue = true
	local _moveStack = { }

	InventoryManager.currentRuleset:ResetCounters()
	
  Moves = {
		[BAG_BACKPACK]        = CollectSingleDirection(IM.ACTION_STASH, BAG_BACKPACK),
		[BAG_BANK]            = CollectSingleDirection(IM.ACTION_RETRIEVE, BAG_BANK),
		[BAG_SUBSCRIBER_BANK] = CollectSingleDirection(IM.ACTION_RETRIEVE, BAG_SUBSCRIBER_BANK),
  }
	
	-- We alternate between stashing and retrieving to minimize the chance of one
	-- of the inventories running full.
	while continue do
		local leftres, leftentry = CalculateSingleMove(BAG_BACKPACK, BAG_BANK)
		local rightres, rightentry = CalculateSingleMove(BAG_BANK, BAG_BACKPACK)
		
		-- ZOS Spam limitation
		if #_moveStack > 95 then
			return "limited", _moveStack
		end
		
		-- Both inventories full, can't move anything
		if leftres == "tgt_full" and rightres == "tgt_full" then
			return "deadlock", _moveStack
		end
		
		-- We completed all we were set out to do
		if leftres == "src_empty" and rightres == "src_empty" then
			return "ok", _moveStack
		end
		
		-- We filled up one side, but we can't empty it out
		if leftres ~= "ok" and rightres ~= "ok" then
			return "partial", _moveStack
		end
		
		if leftres == "ok" then
			_moveStack[#_moveStack + 1] = leftentry
		end
		
		if rightres == "ok" then
			_moveStack[#_moveStack + 1] = rightentry
		end
	end
	-- NOTREACHED
end

InventoryManager.moveStatus = nil

local function ProcessMove(move)	
	local bagIdFrom = move["srcbag"]
	local slotIdFrom = move["srcslot"]
	local bagIdTo = move["tgtbag"]
	local slotIdTo = move["tgtslot"]
	local qtyToMove = move["count"]
	local action = (bagIdFrom == BAG_BACKPACK and InventoryManager.ACTION_STASH) or InventoryManager.ACTION_RETRIEVE
	
	InventoryManager.currentBagType = bagIdFrom
	local data = InventoryManager:GetItemData(slotIdFrom, SHARED_INVENTORY:GetOrCreateBagCache(bagIdFrom))
	InventoryManager:ReportAction(data, false, action, "", "")
	
	if IsProtectedFunction("RequestMoveItem") then
		CallSecureProtected("RequestMoveItem", bagIdFrom, slotIdFrom, bagIdTo, slotIdTo, qtyToMove)
	else
		RequestMoveItem(bagIdFrom, slotIdFrom, bagIdTo, slotIdTo, qtyToMove)
	end
end

function InventoryManager:FinishMoves()
	local result
	if self.moveStatus == "limited" then
		result = GetString(IM_BANK_LIMITED)
	elseif self.moveStatus == "deadlock" then
		result = GetString(IM_BANK_DEADLOCK)
	elseif self.moveStatus == "partial" then
		result = GetString(IM_BANK_PARTIAL)
	elseif self.moveStatus == "ok" then
		result = GetString(IM_BANK_OK)
	end
	
	if result ~= "" then
		CHAT_SYSTEM:AddMessage(result)
	end
end

function InventoryManager:BalanceCurrency(currencyType, minCur, maxCur, bankCur)
	local carried
	local banked

	if bankCur then
		carried 	= GetBankedCurrencyAmount(currencyType)
		banked 		= GetCarriedCurrencyAmount(currencyType)
	else
		carried 	= GetCarriedCurrencyAmount(currencyType)
		banked 		= GetBankedCurrencyAmount(currencyType)
	end
	
	if minCur < 0 then minCur = 0 end
	
	if maxCur < 0 then maxCur = 0 end
	
	local move = 0
	if(carried < minCur) then
		move = carried - minCur
	elseif(carried > maxCur) then
		move = carried - maxCur
	end
	
	if bankCur then
		move = -move
	end

  carried 	= GetCarriedCurrencyAmount(currencyType)
  banked 		= GetBankedCurrencyAmount(currencyType)
  
	if move == 0 then
		return
	elseif move > 0 then
    if move > carried then move = carried end
		CHAT_SYSTEM:AddMessage(
			zo_strformat(GetString(IM_CUR_DEPOSIT), ZO_Currency_FormatPlatform(currencyType, move, ZO_CURRENCY_FORMAT_AMOUNT_ICON)))
		DepositCurrencyIntoBank(currencyType, move)
	else
		move = -move
		if move > banked then move = banked end
		if move == 0 then return end
		CHAT_SYSTEM:AddMessage(
			zo_strformat(GetString(IM_CUR_WITHDRAW), ZO_Currency_FormatPlatform(currencyType, move, ZO_CURRENCY_FORMAT_AMOUNT_ICON)))
		WithdrawCurrencyFromBank(currencyType, move)
	end
end

local function event_filter_fn(eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange) 
	-- Bank moves fire two events, react only if we got the receiver side.
	if not stackCountChange or stackCountChange > 0 then
		return true
	end
	return false
end

function InventoryManager:OnBankOpened()
	local moves
	self.moveStatus, moves = CalculateMoves()
	
	-- Flip the list. The processors start from the end, and the sequence is important here.
	for i = 1, #moves / 2, 1 do
		local tmp = moves[i]
		moves[i] = moves[(#moves+1) - i]
		moves[(#moves+1) - i] = tmp
	end

	self:BalanceCurrency(CURT_MONEY, self.settings.minGold, self.settings.maxGold, self.settings.bankGold)
	self:BalanceCurrency(CURT_TELVAR_STONES, self.settings.minTV, self.settings.maxTV, self.settings.bankTV)
	self:BalanceCurrency(CURT_ALLIANCE_POINTS, self.settings.minAP, self.settings.maxAP, self.settings.bankAP)
	self:BalanceCurrency(CURT_WRIT_VOUCHERS, self.settings.minVW, self.settings.maxVW, self.settings.bankVW)
	
	zo_callLater(
		function()
			IM:DoEventProcessing(moves, 
				ProcessMove,
				function() IM:FinishMoves() end,
				EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
				EVENT_CLOSE_BANK,
				InventoryManager.settings.bankMoveDelay,
				event_filter_fn)
		end,
		InventoryManager.settings.bankInitDelay)
end

EVENT_MANAGER:RegisterForEvent(InventoryManager.name, EVENT_OPEN_BANK, function() InventoryManager:OnBankOpened() end)
