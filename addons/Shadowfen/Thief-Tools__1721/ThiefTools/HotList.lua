ThiefTools_HotItem = {}
local HotItem = ThiefTools_HotItem

local SF = LibSFUtils
local color = SF.hex

local TTHImsg = SF.addonChatter:New("ThiefTools")
local debugmode=false
--TTHImsg:enableDebug()

local function dbg(...)	-- mostly because I hate to type
	TTHImsg:debugMsg(...)
end

function HotItem:New(bagId, slotIndex)
	local o = setmetatable({}, self)
    local mt = getmetatable(o)
	o.__index = self

	local icon, stackCount, sellPrice, meetsUsageRequirement, locked, equipType,
			itemStyle, quality = GetItemInfo(bagId, slotIndex)

    o.bagId = bagId
    o.slotIndex = slotIndex
    o.rawName = GetItemName(bagId, slotIndex) or "unknown"
	o.name = zo_strformat(SI_TOOLTIP_ITEM_NAME, o.rawName)
    o.itemInstanceId = GetItemInstanceId(bagId, slotIndex) or nil
	o.stackCount = stackCount
	o.itemType, o.specializedItemType = GetItemType(bagId, slotIndex)
	o.equipType = equipType
	o.uniqueId = GetItemUniqueId(bagId, slotIndex)

	o.baseSellPrice = sellPrice
    o.sellPrice = GetItemSellValueWithBonuses(bagId, slotIndex)
    o.launderPrice = GetItemLaunderPrice(bagId, slotIndex)
    o.stackSellPrice = stackCount * o.sellPrice
    o.stackLaunderPrice = stackCount * o.launderPrice

    o.locked = locked	-- locked for equipping because it is already equipped
    o.isPlayerLocked = IsItemPlayerLocked(bagId, slotIndex)

    o.quality = quality
    o.stolen = IsItemStolen(bagId, slotIndex)
    o.isJunk = IsItemJunk(bagId, slotIndex)
    o.isPlaceableFurniture = IsItemPlaceableFurniture(bagId, slotIndex)
--[[
	o.requiredLevel = GetItemRequiredLevel(bagId, slotIndex)
	o.itemStyle = itemStyle
    o.meetsUsageRequirement = meetsUsageRequirement or (bagId == BAG_WORN) --Items flagged equipped unique can only have one equipped, which means once they are
    o.isBoPTradeable = IsItemBoPAndTradeable(bagId, slotIndex)
    o.statValue = GetItemStatValue(bagId, slotIndex) or 0
    o.iconFile = icon
    o.filterData = { GetItemFilterTypeInfo(bagId, slotIndex) }
    o.condition = GetItemCondition(bagId, slotIndex)
    o.isFromCrownCrate = IsItemFromCrownCrate(bagId, slotIndex)
    o.isFromCrownStore = IsItemFromCrownStore(bagId, slotIndex)
	--]]
	return o
end

function HotItem:Display()
	TTHImsg:debugMsg("name=HotItem")
	TTHImsg:debugMsg("name=",self.name)
	TTHImsg:debugMsg("   (id: ",self.uniqueId,")")
	TTHImsg:debugMsg("    stolen=",SF.bool2str(self.stolen))
	TTHImsg:debugMsg("    itemtype=",self.itemType,"  specializedItemType=",self.specializedItemType)
	TTHImsg:debugMsg("    equipType=",self.equipType)
	TTHImsg:debugMsg("    quality=",self.quality)
	TTHImsg:debugMsg("    stackCount=",self.stackCount,
		"    sellprice=",self.sellPrice)
	--TTmsg:d("    launderPrice="..self.launderPrice)
	--TTmsg:d("    locked="..SF.bool2str(self.locked))
	--TTmsg:d("    isPlayerLocked="..bool2str(self.isPlayerLocked))
    --TTmsg:d("    isPlaceableFurniture="..bool2str(self.isPlaceableFurniture))
end

------------------------------------------------------------------------------
--[[
	HotList is a sparse array with entries keyed off of the slotIndex of the
	BAG_BACKPACK. This means you cannot use the #list or ipairs on this list!
]]
ThiefTools_HotList = {}
local HotList = ThiefTools_HotList

function HotList:New(bagId)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.itemList = {}
	o.init = false
	o.bagId = bagId or BAG_BACKPACK
	o.itemCount = 0
	return o
end

function HotList:getItem(slotIndex)
	return self.itemList[slotIndex]
end

function HotList:removeItem(slotIndex)
	if( self.itemList[slotIndex] ) then
		self.itemList[slotIndex] = nil
		self.itemCount = self.itemCount - 1
	end
end

function HotList:addItem(hotItem)
	if( not self.itemList[hotItem.slotIndex] ) then
		self.itemCount = self.itemCount + 1
	end
	self.itemList[hotItem.slotIndex] = hotItem
	--if( hotItem ~= nil ) then
	--	hotItem:Display()
	--end
	return self.itemList[hotItem.slotIndex]
end

function HotList:empty()
	self.itemList = {}
	self.itemCount = 0
end

function HotList:size()
	return self.itemCount
end
