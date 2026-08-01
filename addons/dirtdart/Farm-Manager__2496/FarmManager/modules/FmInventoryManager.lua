FmInventoryManager = ZO_Object:Subclass()

local bagCache = {
	[BAG_BANK] = { lastIndex = 0, startIndex = -1 },
    [BAG_SUBSCRIBER_BANK] = {lastIndex = 0, startIndex = -1},
    [BAG_BACKPACK] = {},
    [BAG_GUILDBANK] = {lastIndex = nil, startIndex = nil},
    [BAG_VIRTUAL] = {lastIndex = nil, startIndex = nil}
}

local function IsAtBank(bagId)
    if bagId == BAG_BANK then
        return GetInteractionType() == INTERACTION_BANK
    elseif bagId == BAG_GUILDBANK then
        return GetInteractionType() == INTERACTION_GUILD_BANK
    end
    return false
end

local function GetBag(bagId)
    if bagId == BAG_BACKPACK then
        return "Backpack"
    elseif bagId == BAG_VIRTUAL then
        return "Craft Bag"
    elseif bagId == BAG_BANK then
        return "Bank"
    elseif bagId == BAG_GUILDBANK then
        return "Guild Bank"
    end
    return ""
end

local function FindEmptySlotInBag(targetBag)
    if targetBag == BAG_GUILDBANK then
        bagCache[targetBag].startIndex = GetNextGuildBankSlotId(bagCache[targetBag].startIndex)
    elseif targetBag == BAG_VIRTUAL then
        bagCache[targetBag].startIndex = GetNextVirtualBagSlotId(bagCache[targetBag].startIndex)
    elseif targetBag == BAG_BACKPACK then
        for slotIndex = 0, (GetBagSize(targetBag) - 1) do
            if not SHARED_INVENTORY.bagCache[targetBag][slotIndex] and not bagCache[targetBag][slotIndex] then
                bagCache[targetBag][slotIndex] = true
                return slotIndex
            end
        end
    else
        if bagCache[targetBag].lastIndex == 0 then bagCache[targetBag].lastIndex = GetBagSize(targetBag) - 1 end
        if bagCache[targetBag].startIndex < bagCache[targetBag].lastIndex then 
            bagCache[targetBag].startIndex = bagCache[targetBag].startIndex + 1 
        else
            bagCache[targetBag].startIndex = nil
        end
    end
    return bagCache[targetBag].startIndex
end

local function MoveItem(sourceBag, sourceSlot, targetBag, emptySlot, stackCount)
	if IsProtectedFunction("RequestMoveItem") then
		CallSecureProtected("RequestMoveItem", sourceBag, sourceSlot, targetBag, emptySlot, stackCount)
	else
		RequestMoveItem(sourceBag, sourceSlot, targetBag, emptySlot, stackCount)
    end
end

local function Deposit(srcBag, srcSlot, destBag, count)
    if destBag == BAG_GUILDBANK then
        TransferToGuildBank(srcBag, srcSlot)
        local itemLink = GetItemLink(srcBag, srcSlot)
        d("Moved "..count.." "..itemLink.."  from "..GetBag(srcBag).." to "..GetBag(destBag))
    else
        local destSlot = FindEmptySlotInBag(destBag)

        if not destSlot and IsESOPlusSubscriber() then
            if destBag == BAG_BANK then
                destBag = BAG_SUBSCRIBER_BANK
                destSlot = FindEmptySlotInBag(destBag)
            elseif destBag == BAG_SUBSCRIBER_BANK then
                destBag = BAG_BANK
                destSlot = FindEmptySlotInBag(destBag)
            end
            if destSlot ~= nil then
                MoveItem(srcBag, srcSlot, destBag, destSlot, count)
                local itemLink = GetItemLink(srcBag, srcSlot)
                d("Moved "..count.." "..itemLink.."  from "..GetBag(srcBag).." to "..GetBag(destBag))
            else
                d("No space left in target")
            end
        end
    end
end

function FmInventoryManager:New()
    local manager = ZO_Object.New(self)
    manager:Init()
    return manager
end

function FmInventoryManager:Init()

end

function FmInventoryManager:AddItemToBank(destBag, srcBag, srcSlot, count)
    Deposit(srcBag, srcSlot, destBag, count)
end

function FmInventoryManager:AddItemToBackpack(srcBag, srcSlot, count)
    local destSlot = FindEmptySlotInBag(BAG_BACKPACK)
    if destSlot ~= nil then
        MoveItem(srcBag, srcSlot, BAG_BACKPACK, destSlot, count)
        local itemLink = GetItemLink(srcBag, srcSlot)
        d("Moved "..count.." "..itemLink.."  from "..GetBag(srcBag).." to "..GetBag(BAG_BACKPACK))
    else
        d("No space left in target")
    end
end