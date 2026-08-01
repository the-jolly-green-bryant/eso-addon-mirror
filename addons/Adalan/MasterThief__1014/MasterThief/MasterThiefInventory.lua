--[[
MasterThief - Inventory & Loot List Module
ONLY loot list management and tooltips
NO pickpocket handling (that stays in main file's SetStealMode)
--]]

----------------------------------------
-- Initialize Module Table
----------------------------------------
if not MasterThief then
	MasterThief = {}
end

-- Local references for performance
local MT = MasterThief

----------------------------------------
-- Loot List Management
----------------------------------------
function MT:addToLootList(itemLootLink)
	if not itemLootLink or itemLootLink == "" then 
		d("[MasterThief] Invalid item link")
		return 
	end
	
	-- Check if already on list
	if self:isWorthfulItemOnScrollList(itemLootLink) then
		d(GetString(MT_MISC_ITEM_ALREADY_ON_LOOTLIST))
		return
	end
	
	-- Add to saved vars
	local nEntries = table.getn(MT.SavedVarsLoots.Worthful)
	MT.SavedVarsLoots.Worthful[nEntries + 1] = { itemLootLink }
	
	-- Refresh the window (this updates scrollList AND counter)
	self:RefreshLootlistWindow()
	
	d(itemLootLink .. GetString(MT_MISC_ITEM_ADDED))
end

function MT:removeFromList(itemLinkToCompare)
	if not itemLinkToCompare or itemLinkToCompare == "" then
		return false
	end
	
	for idx, obj in ipairs(MT.SavedVarsLoots.Worthful) do
		local sItemName = obj[1]
		if sItemName == itemLinkToCompare then
			table.remove(MT.SavedVarsLoots.Worthful, idx)
			return true
		end
	end
	
	return false
end

function MT:isWorthfulItemOnScrollList(itemLinkToCompare)
	local worthfulList = MT.SavedVarsLoots and MT.SavedVarsLoots.Worthful
	if not worthfulList then 
		return false
	end
	
	for idx, obj in ipairs(worthfulList) do
		local sItemName = obj[1]
		local rawName_lootItem = GetItemLinkName(itemLinkToCompare)
		local rawName_listItem = GetItemLinkName(sItemName)
		if rawName_lootItem == rawName_listItem then
			return true
		end
	end
	
	return false
end

function MT:countItemsOnLootlist()
	if MT.SavedVarsLoots.Worthful == nil then 
		return 0
	end
	
	local iItems = table.getn(MT.SavedVarsLoots.Worthful)
	return iItems
end

----------------------------------------
-- Inventory Tooltip Integration
----------------------------------------
function MT:InventarTooltip()
	-- Add custom tooltip to inventory showing if item is on loot list
	local originalSetBagItem = ItemTooltip.SetBagItem
	ItemTooltip.SetBagItem = function(control, bagId, slotIndex)
		originalSetBagItem(control, bagId, slotIndex)
		
		local itemLink = GetItemLink(bagId, slotIndex)
		if itemLink and itemLink ~= "" then
			if MT:isWorthfulItemOnScrollList(itemLink) then
				local itemOnLootList = GetString(MT_MISC_ITEM_TOOLTIP)
				control:AddLine("|c0092FF" .. itemOnLootList .. "|r")
			end
		end
	end
end

----------------------------------------
-- Free Slots Warning
----------------------------------------
function MT:CheckFreeSlots()
	-- Check if player is running low on inventory space
	local iMinFreeSlots = MT.SavedVarsOptions.MinFreeSlots
	local iSlotsLeft = GetBagSize(BAG_BACKPACK) - GetNumBagUsedSlots(BAG_BACKPACK)
	
	if iSlotsLeft <= iMinFreeSlots then
		MT:ShowMessage(GetString(MT_MISC_FREE_SLOTS_LEFT) .. iSlotsLeft, 0)
	end
end

----------------------------------------
-- Useless Items Management
----------------------------------------
function MT:DestroyUselessItems(bDestroyIt)
	-- Print or destroy useless items in inventory
	local itemsFound = false
	
	for bagSlot = 0, GetBagSize(BAG_BACKPACK) - 1 do
		if IsItemStolen(BAG_BACKPACK, bagSlot) then
			local itemType = GetItemType(BAG_BACKPACK, bagSlot)
			local _, _, sellPrice = GetItemInfo(BAG_BACKPACK, bagSlot)
			
			if MT:IsStolenItemUseless(itemType, sellPrice) then
				local itemLink = GetItemLink(BAG_BACKPACK, bagSlot)
				itemsFound = true
				
				if bDestroyIt then
					-- Destroy the item
					DestroyItem(BAG_BACKPACK, bagSlot)
					d("[MasterThief] Destroyed: " .. GetItemLinkName(itemLink))
				else
					-- Just list it
					d(GetItemLinkName(itemLink))
				end
			end
		end
	end
	
	if not itemsFound then
		d("[MasterThief] No useless items found")
	end
end

----------------------------------------
-- Loot Window Context Menu
----------------------------------------
function MT.CreateContextMenuEntry(rowControl)
	-- Only for loot window, not inventory
	if not rowControl then return end
	if not rowControl.GetOwningWindow then return end
	
	local owningWindow = rowControl:GetOwningWindow()
	if not owningWindow then return end
	
	local windowName = owningWindow:GetName()
	
	-- ONLY process loot window
	if windowName ~= "ZO_Loot" then return end
	if owningWindow == ZO_TradingHouse then return end
	
	-- Don't process character window
	if rowControl:GetParent() == ZO_Character then return end
	
	zo_callLater(function() 
		MT:addContextMenuEntry(rowControl:GetParent()) 
	end, 100)
end

function MT:addContextMenuEntry(rowControl)
	if not rowControl or not rowControl.dataEntry or not rowControl.dataEntry.data then return end
	local itemLootLink = GetLootItemLink(rowControl.dataEntry.data.lootId, LINK_STYLE_DEFAULT)
	if not itemLootLink or itemLootLink == "" then return end
	
	AddMenuItem(GetString(MT_CONTEXTMENU_LOOT_MARK), function() 
		MT:addToLootList(itemLootLink) 
	end, MENU_ADD_OPTION_LABEL)
	ShowMenu()
end