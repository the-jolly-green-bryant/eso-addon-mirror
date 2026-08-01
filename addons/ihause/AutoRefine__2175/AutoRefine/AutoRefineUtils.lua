AutoRefine = {}
AutoRefine.name = "AutoRefine"
AutoRefine.saveVersion = 2

function AutoRefine:GetItemId(link)
	return tonumber(string.match(link, '|H.-:item:(.-):'))
end

function AutoRefine:IsName(notFormatedName, name)   
	return string.lower(string.gsub(notFormatedName,"-"," ")) == string.lower(name) 
end

function AutoRefine:GetItemLinkInBag(bagId, itemName)

	for index, data in pairs(SHARED_INVENTORY.bagCache[bagId])do 
		if data ~= nil then
			if self:IsName(itemName, GetItemName(bagId, data.slotIndex)) then
				return GetItemLink(bagId, data.slotIndex, LINK_STYLE_DEFAULT)
			end
		end
	end

	return nil
end 

function AutoRefine:GetItemLink(itemName)	
	
	local link = self:GetItemLinkInBag(BAG_BACKPACK, itemName)
	if link ~= nil then return link end
	
	local link = self:GetItemLinkInBag(BAG_BANK, itemName)
	if link ~= nil then return link end
	
	local link = self:GetItemLinkInBag(BAG_SUBSCRIBER_BANK, itemName)
	if link ~= nil then return link end	
	
	local link = self:GetItemLinkInBag(BAG_VIRTUAL, itemName)
	if link ~= nil then return link end	

	return nil
end 

local function getItemTotalCountById(id, bagId)
    local totalCount = 0
	for index, data in pairs(SHARED_INVENTORY.bagCache[bagId]) do 
		if data ~= nil then
			local link = GetItemLink(bagId, data.slotIndex, LINK_STYLE_DEFAULT)
			if link ~= "" and id == AutoRefine:GetItemId(link) then
				local slotSize, maxSlotSize = GetSlotStackSize(bagId, data.slotIndex)
				if 0 < slotSize then
					totalCount = totalCount + slotSize
				end
			end
		end
	end
	return totalCount
end

function AutoRefine:GetItemTotalCountById(id)
    return  
		getItemTotalCountById(id, BAG_BANK) 
	 + getItemTotalCountById(id, BAG_BACKPACK)	
	 + getItemTotalCountById(id, BAG_VIRTUAL)
	 + getItemTotalCountById(id, BAG_SUBSCRIBER_BANK)
end


function AutoRefine:GetItemTotalCount(itemLink)
	return self:GetItemTotalCountById(self:GetItemId(itemLink))
end


local function findNextTask(bagId, searchedItemType)
	
	for index, data in pairs(SHARED_INVENTORY.bagCache[bagId])do 
		if data ~= nil then
			local link = GetItemLink(bagId, data.slotIndex, LINK_STYLE_DEFAULT)
			if link ~= "" then
				local itemType, specializedItemType = GetItemType(bagId, data.slotIndex)
				if searchedItemType == itemType then
					--local slotSize, maxSlotSize = GetSlotStackSize(bagId, data.slotIndex)
					local doAmount = math.floor(AutoRefine:GetItemTotalCount(link) / 10)
					--local doAmount = math.floor(slotSize / 10)
					if doAmount > 0 then
						return data.slotIndex, doAmount
					end
				end
			end
		end
	end
	
	return -1, 0
end

local function findNextTaskInRest(bagId, searchedItemType)
	
	for index, data in pairs(SHARED_INVENTORY.bagCache[bagId])do 
		if data ~= nil then
			local link = GetItemLink(bagId, data.slotIndex, LINK_STYLE_DEFAULT)
			if link ~= "" then
				local itemType, specializedItemType = GetItemType(bagId, data.slotIndex)
				if searchedItemType == itemType then
					--local slotSize, maxSlotSize = GetSlotStackSize(bagId, data.slotIndex)
					local doAmount = math.floor(AutoRefine:GetItemTotalCount(link) / 10)
					if doAmount > 0 then
						return data.slotIndex, doAmount
					end
				end
			end
		end
	end
	
	return -1, 0
end

function AutoRefine:FindNextTaskByType(searchedItemType)

	local slotIndex, amount = findNextTask(BAG_BACKPACK, searchedItemType)	
	if (slotIndex ~= -1) then return slotIndex, BAG_BACKPACK, amount end
	
	slotIndex, amount = findNextTask(BAG_BANK, searchedItemType)	
	if (slotIndex ~= -1) then return slotIndex, BAG_BANK, amount end
	
	slotIndex, amount = findNextTask(BAG_SUBSCRIBER_BANK, searchedItemType)
	if (slotIndex ~= -1) then return slotIndex, BAG_SUBSCRIBER_BANK, amount end
	
	slotIndex, amount = findNextTask(BAG_VIRTUAL, searchedItemType)
	if (slotIndex ~= -1) then return slotIndex, BAG_VIRTUAL, amount end
	
	slotIndex, amount = findNextTaskInRest(BAG_BACKPACK, searchedItemType)	
	if (slotIndex ~= -1) then return slotIndex, BAG_BACKPACK, amount end
	
	slotIndex, amount = findNextTaskInRest(BAG_BANK, searchedItemType)	
	if (slotIndex ~= -1) then return slotIndex, BAG_BANK, amount end
	
	slotIndex, amount = findNextTaskInRest(BAG_SUBSCRIBER_BANK, searchedItemType)
	if (slotIndex ~= -1) then return slotIndex, BAG_SUBSCRIBER_BANK, amount end
	 
	return -1, BAG_BACKPACK, 0
end


