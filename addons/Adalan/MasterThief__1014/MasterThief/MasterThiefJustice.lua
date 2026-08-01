--[[
MasterThief - Justice System Module
Handles fence interactions, bounty tracking, and stolen goods management
--]]

----------------------------------------
-- Initialize Module Table
----------------------------------------
if not MasterThief then
	MasterThief = {}
end

-- Local references for performance
local MT = MasterThief

-- Module-level state
local bShowFenceSellLimitAgain = false
local bShowFenceTransferLimitAgain = false
local bFenceValuesUpdated = false
local hadBountyBeforeDeath = false
local bountyIncreaseTime = 0
local bFenceIsOpen = false  -- True while fence window is open; gates launder gold tracking

----------------------------------------
-- Fence Events
----------------------------------------
function MT.FenceOpened(_EventCode)
	if MT:CompanionOnFenceOpened() then return end  -- blocked; window already closing
	-- Called when fence window opens
	bFenceIsOpen = true
	EVENT_MANAGER:RegisterForEvent(MT.name, EVENT_SELL_RECEIPT, function(...) MT.ItemSold(...) end)
	EVENT_MANAGER:RegisterForEvent(MT.name, EVENT_CLOSE_STORE, function(...) MT.FenceClosed(...) end)
end

function MT.FenceClosed(eventCode)
	-- Called when fence window closes
	bFenceIsOpen = false
	EVENT_MANAGER:UnregisterForEvent(MT.name, EVENT_SELL_RECEIPT)
	EVENT_MANAGER:UnregisterForEvent(MT.name, EVENT_CLOSE_STORE)
	
	-- Show fence limit warnings if needed
	if bShowFenceSellLimitAgain then
		d(GetString(MT_MISC_SELL_MAXIMUM_REACHED))
		bShowFenceSellLimitAgain = false
	end
	
	if bShowFenceTransferLimitAgain then
		d(GetString(MT_MISC_TRANSFER_MAXIMUM_REACHED))
		bShowFenceTransferLimitAgain = false
	end
	
	-- Update saved variables if gold changed
	if bFenceValuesUpdated then
		MT:UpdateSavedVarsGold(stolenTotal)
		bFenceValuesUpdated = false
	end
end

----------------------------------------
-- Gold & Item Tracking
----------------------------------------
function MT.ItemSold(eventCode, itemName, itemQuantity, money)
	-- Called when item is sold to fence
	if not money or money <= 0 then return end
	
	stolenTotal = stolenTotal + money
	bFenceValuesUpdated = true
	
	-- Track in statistics
	MT:TrackFencedGold(money)
	
	-- Show message if enabled
	if MT.SavedVarsOptions.AnnounceSellsTransfers then
		local itemLink = itemName -- May be item link
		MT:ShowMessage(itemQuantity .. " x " .. MT:FixLinkName(itemLink) .. 
		               GetString(MT_MISC_SOLD_FOR) .. money .. "g", 1)
	end
end

function MT.JusticeGoldRemoved(eventCode, goldAmount)

	bShowFenceTransferLimitAgain = false
	if MT.SavedVarsOptions.AnnounceSellsTransfers then
		MT:ShowMessage(GetString(MT_MISC_FOUND_ALOT_GOLD_TEXT) .. goldAmount .. " gold", 1)
	end
end

function MT.JusticeStolenItemsRemoved(eventCode)
	-- Called when stolen items are removed (confiscated by guards)
	MT:ShowMessage(GetString(MT_MISC_ALL_STOLEN_ITEMS_REMOVED), 1)
end

function MT.OnMoneyUpdate(eventCode, newMoney, oldMoney, reason, reasonSupplementaryInfo)
	-- Called when player's gold changes
	local iMoney = newMoney - oldMoney
	
	-- Track launder gold via reason code
	if reason == CURRENCY_CHANGE_REASON_VENDOR_LAUNDER and iMoney < 0 then
		MT:TrackLaunderedGold(math.abs(iMoney))
		return
	end

end

----------------------------------------
-- Bounty Tracking
----------------------------------------
function MT.BountyPayoff(eventCode, oldBounty, newBounty)
	-- Called when bounty changes
	if newBounty < oldBounty then
		-- Bounty decreased (paid or decayed)
		local amountPaid = oldBounty - newBounty
		
		if newBounty == 0 and oldBounty > 0 then
			-- Bounty fully paid - track using oldBounty as the amount
			MT:UpdatePaidBounty(oldBounty)
			MT:ShowMessage(GetString(MT_MISC_BOUNTY_REMOVED_FROM_BODY), 1)
		elseif amountPaid > 10 then
			-- Partially paid
			MT:ShowMessage(GetString(MT_MISC_BOUNTY_IS) .. newBounty .. " gold", 1)
		end
	elseif newBounty > oldBounty then
		-- Bounty increased (new crime)
		hadBountyBeforeDeath = true
		bountyIncreaseTime = GetGameTimeMilliseconds()
		
		-- Track highest bounty
		MT:BountyChanged(newBounty, oldBounty)
		
		-- Companion rapport warning
		MT:CompanionOnBountyGain(newBounty, oldBounty)
	end
end

----------------------------------------
-- Fence Limit Checking
----------------------------------------
-- Predictive warning: Check if items in bag + already fenced will exceed limit
-- This warns you WHILE LOOTING so you don't pick up items you can't fence
function MasterThief:CheckMaxFenceLimit()
	if (MasterThief.SavedVarsOptions.AnnounceMaxFencerLimits == false) then return end
	
	local totalSells, sellsUsed = GetFenceSellTransactionInfo()
	local totalLaunders, laundersUsed = GetFenceLaunderTransactionInfo()
	
	-- Count items currently in bag that would be fenced/laundered
	local iStolenItems = MasterThief:CountStolenItems(1)  -- Regular stolen items
	local iStolenSpecials = MasterThief:CountStolenItems(2)  -- Special items (launderable)
	
	-- Calculate how close we are to limits
	local slotsLeftToFence = totalSells - sellsUsed
	local slotsLeftToLaunder = totalLaunders - laundersUsed
	
	-- Warn if carrying more items than remaining fence slots
	-- This means: "You have too many items, you won't be able to fence them all today"
	if (iStolenItems > slotsLeftToFence and totalSells > 0 and bShowFenceSellLimitAgain == false) then 
	   MasterThief:ShowMessage("MT: "..GetString(MT_MISC_SELL_MAXIMUM_REACHED).." ("..sellsUsed.." / "..totalSells.." fenced, carrying "..iStolenItems..")" ,1)
	   bShowFenceSellLimitAgain = true
	end
	
	-- Warn if carrying more special items than remaining launder slots
	if (iStolenSpecials > slotsLeftToLaunder and totalLaunders > 0 and bShowFenceTransferLimitAgain == false) then
																							 
	   MasterThief:ShowMessage("MT: "..GetString(MT_MISC_TRANSFER_MAXIMUM_REACHED).." ("..laundersUsed.." / "..totalLaunders.." laundered, carrying "..iStolenSpecials..")" ,1)
	   bShowFenceTransferLimitAgain = true
	end	
end

----------------------------------------
-- SavedVariables Updates
----------------------------------------
function MasterThief:UpdateSavedVarsGold(iNewGold)
	MasterThief.SavedVarsValues.stolenValuesTotal = MasterThief.SavedVarsValues.stolenValuesTotal + iNewGold
end


function MasterThief:UpdatePaidBounty(iMoney)
	if not MasterThief.SavedVarsLifetimeStats then
		d("[MT] UpdatePaidBounty: SavedVarsLifetimeStats is nil!")
		return
	end
	MasterThief.SavedVarsLifetimeStats.paidBountyTotal = (MasterThief.SavedVarsLifetimeStats.paidBountyTotal or 0) + iMoney
	d("[MT] UpdatePaidBounty: tracked " .. tostring(iMoney) .. "g, total=" .. tostring(MasterThief.SavedVarsLifetimeStats.paidBountyTotal))
	if MasterThief.lootlistWindow and not MasterThief.lootlistWindow:IsHidden() then
		MasterThief:UpdateLifetimeStatsDisplay()
	end
end

----------------------------------------
-- Death Detection (for guard deaths)
----------------------------------------
function MT:PlayerDied()
	-- Called when player dies
	-- Check if death was by guards (based on recent bounty increase)
	local currentBounty = GetBounty()
	
	if hadBountyBeforeDeath then
		local timeSinceBountyIncrease = GetGameTimeMilliseconds() - bountyIncreaseTime
		
		-- Guard combat can last up to 60 seconds
		if timeSinceBountyIncrease < 60000 then
			MT:TrackDeathByGuards()
		end
	end
	
	-- Reset flag
	hadBountyBeforeDeath = false
end

----------------------------------------
-- Module State Access
----------------------------------------
-- Allow other modules to check bounty-related state
function MT:GetBountyState()
	return {
		hadBountyBeforeDeath = hadBountyBeforeDeath,
		bountyIncreaseTime = bountyIncreaseTime,
	}
end

function MT:GetFenceState()
	return {
		showSellLimitAgain = bShowFenceSellLimitAgain,
		showTransferLimitAgain = bShowFenceTransferLimitAgain,
		valuesUpdated = bFenceValuesUpdated,
	}
end