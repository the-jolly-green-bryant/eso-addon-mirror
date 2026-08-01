-----------------------------------------------------------------------------------
-- Addon Name: Stack Traceback
-- Creator: Dolgubon (Joseph Heinzle)
-- Addon Ideal: Stack both the main bank and the subscriber bank
-- Addon Creation Date: October 29, 2017
-- Publication Date: October 29, 2017
--
-- File Name: StackTraceback.lua
-- File Description: The main lua file.
-- Load Order Requirements: None
-- 
-----------------------------------------------------------------------------------


-- The global variable is differnt because StackTraceback isn't really a very unique name
DolgubonStackTraceback = {}


DolgubonStackTraceback.name = "StackTraceback"

-- Holds all the stacks which might be able to be added to

local incompleteStacks = 
{

}

-- Checks if the the position is either full or empty

local function removeFromTable(t,dest, source, indexes)
	local newStack, max = GetSlotStackSize(t[source][1],t[source][2])
	if newStack == 0 then
		indexes[source] = nil
	end
	newStack, max = GetSlotStackSize(t[dest][1],t[dest][2])
	if newStack == max then
		indexes[dest] = nil
		
	end
end

-- Actually move the item
local function combineStacks(t, dest, source, indexes)
	CallSecureProtected("RequestMoveItem", t[dest][1],t[dest][2],t[source][1],t[source][2], t[source][4]) -- move the max amount from the second position to the first.
	-- Check to see if slot 1 is full
	
	removeFromTable(t, dest, source, indexes)
end

-- Caches the table indexes we'll concern ourselves with
local function range(start, e)
	local newTable = {}
	for i = start, e do
		newTable[i] = true
	end
	return newTable
end

-- Overarching combiner function
-- This function will combine all the slots in the table passed to it
local function combine(v)
	local i = 1
	local indexes = range(1, #v)
	
	for i = 1, #indexes do
		for j = i + 1, #indexes do
			if indexes[i] and indexes[j] then
				
				combineStacks(v, i, j, indexes)
			end
		end
	end

end

-- This function checks to see if maybe the item in the slot could be combined with something else
-- Checks multiple things: Is it stackable? What is the total amount in the bank, and is that more than the amount in the slot?
-- And finally, is the amount in the slot less than the maximum possible amount
-- Saves the info under the name of the item.
function isUnstacked(bag, slot)
	local linkOne = GetItemLink(bag, slot)
	if IsItemLinkStackable(linkOne) and linkOne ~="" then
		local _, bankStackSize = GetItemLinkStacks(linkOne)
		local singleStackSize, maxStackSize = GetSlotStackSize(bag, slot)
		if bankStackSize > singleStackSize and singleStackSize < maxStackSize then
			local name = GetItemName(bag, slot)
			incompleteStacks[name] = incompleteStacks[name] or {}
			incompleteStacks[name][#incompleteStacks[name] + 1] = {bag, slot, singleStackSize,maxStackSize}
		end
	end
end

local originalStack = StackBag

-- Main stacker function
local function stackTwoBags()
	-- stack the bags with the game's own functions first. Let's not make ourselves to extra work

	-- Iterate over the bags to see what could be stacked
	for i = 0, GetBagSize(BAG_BANK) do
		isUnstacked(BAG_BANK, i)
		isUnstacked(BAG_SUBSCRIBER_BANK,i)

	end
	
	-- now we have all the slots that could be stacked more
	for k, v in pairs(incompleteStacks) do
		if #v == 1 then -- We know it can't be stacked more. Must be a full stack + partial stack.
			incompleteStacks[k] = {}
		else
			combine(v)
		end
	end

	incompleteStacks = {}
end


StackBag = function(bag)

	if not IsESOPlusSubscriber() then
		originalStack(bag)
		d("You don't have ESO+, so this addon (Bank Stacker) is useless.") -- Why the hell did you even install this?
		return
	end
	if bag == BAG_BANK or bag == BAG_SUBSCRIBER_BANK then -- They called stack bag in the bank!! Or some other addon did it by calling subscriber bank
		stackTwoBags()
		return
	end
	-- None of the above were pertinent, so just call the original function. They probably want to stack their inventory. Boring.

	return originalStack(bag)
end