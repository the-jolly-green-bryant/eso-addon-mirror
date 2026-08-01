local GS = GetString

local myAccentColor = "9e0911"
local myTextColor = "1d6dad"

local cllD = CarosLootList.cllD
local cllPost = CarosLootList.cllPost
local getSetItemInfo = CarosLootList.getSetItemInfo

local alreadyOffered = {}

function CarosLootList.tradeOffer(doMoney)
	cllD("Trying to trade")
	if TRADE_WINDOW.state ~= TRADE_STATE_TRADING then return end
	local myTarget = TRADE_WINDOW.target
	--local meFirst = true
	--if UndecorateDisplayName(myTarget) < UndecorateDisplayName(GetUnitDisplayName("player")) then meFirst = false end
	cllD(myTarget) 
	local doingMoney = false
	local finishedThem = false
	local finishedMe = false
	local readyThem = false
	local readyMe = false
	local myTurnReceiving = false
	local theyReceiveFirst = myTarget > GetUnitDisplayName("player")
	
	alreadyOffered[myTarget] = alreadyOffered[myTarget] or {}
	local needFromPartner = {false, false, false, false, false}
	
	-- check items my partner offers so I don't offer the same stuff to them
	-- also see which items I need if he already offered something
	-- will be called again everytime the partner changes his status to offer complete
	local function checkPartnerOffer()
		local partnerOfferEmpty = true
		needFromPartner = {false, false, false, false, false}
		for tradeSlot=1, TRADE_NUM_SLOTS do
			local myLink = GetTradeItemLink(TRADE_THEM, tradeSlot)
			if myLink then
				partnerOfferEmpty = false
				local hasSet, setId, mySetPiece, setName = getSetItemInfo(myLink)
				if hasSet then
					alreadyOffered[myTarget][setId] = alreadyOffered[myTarget][setId] or {}
					alreadyOffered[myTarget][setId][mySetPiece] = true
				end
				if IsItemLinkSetCollectionPiece(myLink) and not IsItemSetCollectionPieceUnlocked(GetItemLinkItemId(myLink)) then 
					needFromPartner[tradeSlot] = true
				end
			end
		end
		return(partnerOfferEmpty)
	end
	-- here the function is called just to make sure I don't offer anything my partner already offered too
	checkPartnerOffer()
	
	cllD("Already offered:",2) 
	cllD(alreadyOffered,2) 
	
	local offeredAnything = false
	local bagId = BAG_BACKPACK
	local usedSlots = {}
	local offerNow = {}
	local offerComplete = false
	-- This function only fills the internal table with items. It doesn't actually DO anything.
	-- Still need to add the first item in this table to activate the event listener.
	local function startOffering()
		if cllDebug then  d("(re-)starting offering") end
		offerComplete = false
		offeredAnything = false
		for slotIndex=0, GetBagSize(bagId) do
			local isTradeLocked = FCOIS and FCOIS.IsTradeLocked(bagId, slotIndex)
			if not IsItemBound(bagId, slotIndex) and not IsItemPlayerLocked(bagId, slotIndex) and not isTradeLocked then
				local myLink = GetItemLink(bagId, slotIndex)
				if IsItemLinkSetCollectionPiece(myLink) and IsItemSetCollectionPieceUnlocked(GetItemLinkItemId(myLink)) and GetItemBoPTimeRemainingSeconds(bagId, slotIndex) > 0 then
					if IsDisplayNameInItemBoPAccountTable(bagId, slotIndex, UndecorateDisplayName(myTarget)) then
						cllD("Checking setdata for: "..myLink,2) 
						local hasSet, setId, mySetPiece, setName = getSetItemInfo(myLink)
						if hasSet then
							cllD("has set")
							alreadyOffered[myTarget][setId] = alreadyOffered[myTarget][setId] or {}
							if not alreadyOffered[myTarget][setId][mySetPiece] then
								cllD("not yet offered")
								local myTradeSlot = false
								cllD("Looking for a slot..",2) 
								for tradeSlot = 1, TRADE_NUM_SLOTS do
									if GetTradeItemLink(TRADE_ME, tradeSlot) == "" and not usedSlots[tradeSlot] then myTradeSlot = tradeSlot break end
								end
								cllD(myTradeSlot,2) 
								if not myTradeSlot then break end
								usedSlots[myTradeSlot] = true
								cllD("Adding the item",2) 
								table.insert(offerNow, {bagId=bagId, slotIndex=slotIndex, tradeSlot=myTradeSlot})
								alreadyOffered[myTarget][setId][mySetPiece] = true
								offeredAnything = true
							end
						end
					end
				end
			end	
		end
		return offeredAnything
	end
	
	if not startOffering() then
		-- if initial offer is empty I'm finished.
		offerComplete = true 
	end
	
	cllD("The table:",2) 
	cllD(offerNow,2) 
	
	local slotsToRemove = {}
	
	-- Codes for the money field:
	-- 0 = need everything
	-- abcd = need postion abcd
	-- 111/777 = need nothing
	-- 222 = my offer is complete (first filling of the slots or after items got removed)
	-- 333 = got your wishes, starting again (won't be registered by the partner. only needed to register the next value as a change)
	-- 444 = your turn
	-- 555 = doing Money (start signal)

	local function endTurn()
		if myTurnReceiving then 
			cllD("My turn ended...")
			finishedThem = true
			if theyReceiveFirst then
				cllD("...both turns ended.")
				TradeSetMoney(0)
				cllPost(GS(CLL_AutoTradeFinished))
			else
				cllD("..their turn now.")
				myTurnReceiving = false
				-- old value for offered... will be set new, but what if the list is already is full and nothing new is offered...
				if offeredAnything then
					local myOffer = offerNow[1]
					zo_callLater(function() TradeAddItem(myOffer.bagId, myOffer.slotIndex, myOffer.tradeSlot) end, 800)
				else
					offerComplete = true
					zo_callLater(endTurn, 1000)
				end
			end
		else
			cllD("Their turn ended....")
			finishedMe = true
			if theyReceiveFirst then
				cllD("... my turn now.")
				myTurnReceiving = true
				TradeSetMoney(444)				
			else
				cllD("... both turns ended.")
				TradeSetMoney(0)
				cllPost(GS(CLL_AutoTradeFinished))
			end
		end	
	end
	
	local function removeFromOffer(_, TradeParticipant, tradeIndex)
		if not doingMoney then return end
		if TradeParticipant == TRADE_ME and #slotsToRemove == 0 then cllD("Nothing to remove") return end
		if TradeParticipant == TRADE_THEM then 
			needFromPartner[tradeIndex] = false
			return 
		end 
		if TradeParticipant == TRADE_ME then
			if tradeIndex then usedSlots[tradeIndex] = false end
			cllD("Remove next") 
			if tradeIndex and slotsToRemove[tradeIndex] then slotsToRemove[tradeIndex] = false end
			local anythingToRemove = false
			for i, v in pairs(slotsToRemove) do
				if v == true then
					if GetTradeItemLink(TRADE_ME, i) ~= "" then 
						TradeRemoveItem(i) 
						return 
					end
				end
			end	
			TradeSetMoney(333)
		end
	end
		
	local function startTheAutoTrade()
		cllD("Both are ready") 
		if not theyReceiveFirst then myTurnReceiving = true end
		doingMoney = true  
		if not myTurnReceiving then  
			if offerComplete then 
				zo_callLater(endTurn, 1000)
			else 
				local myOffer = offerNow[1]
				TradeAddItem(myOffer.bagId, myOffer.slotIndex, myOffer.tradeSlot)  
			end
		end
	end
	
	local function offerNextRound()
		if startOffering() then
			local myOffer = offerNow[1]
			TradeAddItem(myOffer.bagId, myOffer.slotIndex, myOffer.tradeSlot)  
		else
			endTurn()
		end
	end
	
	local function moneyChanged(_, TradeParticipant, money)
		local concerns = TradeParticipant == TRADE_ME and "me" or "them"
		cllD(string.format("Money changed (%s): %s", concerns, money))
		-- If not in the right mode do nothing
		if not doMoney then return end
		
		if TradeParticipant == TRADE_ME then 
			-- my own moneyChange only is registered for restarting the trade after removing items
			-- 333 is only used between two offers, each being signaled by 222. need to wait for it to apply to start the offer again
			if doingMoney and money == 333 and not myTurnReceiving then 
				zo_callLater(offerNextRound, 800)
			end
			
			-- waiting for my own start signal to fire and check if my partner is ready too
			if money == 555 then 
				readyMe = true
				cllD("I'm ready")
				if readyThem then startTheAutoTrade() end	
			end
			return 
		end
		
		--- --- Them nothing from here should be called if it's me who changed money --- ---
		
		-- their start signal
		if money == 555 then 
			readyThem = true
			cllD("They`re ready!")
			if readyMe then startTheAutoTrade()	end	
			return
		end
		-- always return if no start signal has been given
		if not doingMoney then return end
		
		-- only check for zero if already in the process
		if money == 0 and not myTurnReceiving and not finishedMe then 
			money = "12345"
		end
		
		if money == 222 and myTurnReceiving then 	-- 222 means offer complete
			local partnerOfferEmpty = checkPartnerOffer()
			local myNeedingNumber = ""
			for i, v in pairs(needFromPartner) do
				if v then myNeedingNumber = myNeedingNumber..i end
			end
			myNeedingNumber = tonumber(myNeedingNumber)
			if not myNeedingNumber then 
				if GetTradeMoneyOffer(TRADE_ME) == 111 then myNeedingNumber = 777 else 	myNeedingNumber = 111 end
			end
			
			if myNeedingNumber == 12345 or partnerOfferEmpty then 
				myNeedingNumber = 0 
				finishedThem = true
				if finishedMe then cllPost(GS(CLL_AutoTradeFinished)) end
			end
			TradeSetMoney(myNeedingNumber)
			return
		end
		
		if (money == 444 or money == 0) and myTurnReceiving then endTurn() return end
		
		if myTurnReceiving then return end
		
		if money == 111 or money == 777 then money = 0 end -- use 111/777 alternating to say: nothing needed
		slotsToRemove = {}
		local function emptyRemoveSlots()
			for tradeSlot=1, TRADE_NUM_SLOTS do
				slotsToRemove[tradeSlot] = true
			end
		end
		emptyRemoveSlots()
		
		for i=string.len(money), 1, -1 do
			local thisOne = tonumber(string.sub(money, i, i))
			if slotsToRemove[thisOne] then 
				slotsToRemove[thisOne] = false 
			elseif slotsToRemove[thisOne] == false then
				emptyRemoveSlots()
				cllD("Dupclicate number in "..money)
				return
			end
		end
		
		cllD(slotsToRemove)
		
		removeFromOffer(nil, TRADE_ME, false)
	end
	
	local function stopTheTradeHook()
		cllD("Stopped the trade hook")
		offerNow = {}
		EVENT_MANAGER:UnregisterForEvent(CarosLootList.name.."EventTradeItemAdded", EVENT_TRADE_ITEM_ADDED)
		EVENT_MANAGER:UnregisterForEvent(CarosLootList.name.."EventTradeItemRemoved", EVENT_TRADE_ITEM_REMOVED)
		EVENT_MANAGER:UnregisterForEvent(CarosLootList.name.."EventTradeSuccess", EVENT_TRADE_SUCCEEDED)
		EVENT_MANAGER:UnregisterForEvent(CarosLootList.name.."EventTradeFail", EVENT_TRADE_FAILED)
		EVENT_MANAGER:UnregisterForEvent(CarosLootList.name.."EventTradeCancel", EVENT_TRADE_CANCELED)
		EVENT_MANAGER:UnregisterForEvent(CarosLootList.name.."EventTradeMoneyChanged", EVENT_TRADE_MONEY_CHANGED)
		
	end
	
	local function addToOffer(_, tradeParticipant, tradeIndex)
		if #offerNow == 0 then return end
		if tradeParticipant ~= TRADE_ME then return end
		
		local myOfferIndex = false
		for i,v in pairs(offerNow) do
			if tradeIndex == v.tradeSlot then myOfferIndex = i break end
		end
		if not myOfferIndex then return end
		
		local myOffer = offerNow[myOfferIndex]
		local thisBag, thisSlot = GetTradeItemBagAndSlot(TRADE_ME, myOffer.tradeSlot)
		if thisBag ~= myOffer.bagId or thisSlot ~= myOffer.slotIndex then offerNow = {} return end
		table.remove(offerNow, myOfferIndex)
		if #offerNow == 0 then
			if doingMoney then TradeSetMoney(222) end
			offerComplete = true
			return
		end
		myOffer = offerNow[1]
		zo_callLater(function() TradeAddItem(myOffer.bagId, myOffer.slotIndex, myOffer.tradeSlot) end, 300)
	end
	
	if offeredAnything or doMoney then 
		cllD("Set the trade hook")
		EVENT_MANAGER:RegisterForEvent(CarosLootList.name.."EventTradeItemAdded", EVENT_TRADE_ITEM_ADDED, addToOffer) 
		EVENT_MANAGER:RegisterForEvent(CarosLootList.name.."EventTradeSuccess", EVENT_TRADE_SUCCEEDED, stopTheTradeHook)
		EVENT_MANAGER:RegisterForEvent(CarosLootList.name.."EventTradeFail", EVENT_TRADE_FAILED, stopTheTradeHook)
		EVENT_MANAGER:RegisterForEvent(CarosLootList.name.."EventTradeCancel", EVENT_TRADE_CANCELED, stopTheTradeHook)
		EVENT_MANAGER:RegisterForEvent(CarosLootList.name.."EventTradeMoneyChanged", EVENT_TRADE_MONEY_CHANGED, moneyChanged)
		EVENT_MANAGER:RegisterForEvent(CarosLootList.name.."EventTradeItemRemoved", EVENT_TRADE_ITEM_REMOVED, removeFromOffer)
		if offeredAnything and not doMoney then 
			local myOffer = offerNow[1]
			TradeAddItem(myOffer.bagId, myOffer.slotIndex, myOffer.tradeSlot) 
			return
		end
		
		if GetTradeMoneyOffer(TRADE_THEM) == 555 and doMoney then 
			readyThem = true
		end
		if doMoney then 
			TradeSetMoney(555) 
		end
		return true 
	end
end
	 	