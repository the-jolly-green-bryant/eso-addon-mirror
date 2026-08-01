local Addon = {}
Addon.Name = "kyoRuneboxTT"
Addon.DisplayName = "|cFF5FF5Kyoma's|r Runebox Tooltip"
Addon.Author = "|cFF5FF5Kyoma|r"
Addon.Version = "2.0"

Addon.Settings = {}
Addon.Defaults = 
{

}

local linkHelpers =
{
    [SLOT_TYPE_ITEM] =                          function(inventorySlot) return GetItemLink(ZO_Inventory_GetBagAndIndex(inventorySlot)) end,
    [SLOT_TYPE_BANK_ITEM] =                     function(inventorySlot) return GetItemLink(ZO_Inventory_GetBagAndIndex(inventorySlot)) end,
    [SLOT_TYPE_GUILD_BANK_ITEM] =               function(inventorySlot) return GetItemLink(ZO_Inventory_GetBagAndIndex(inventorySlot)) end,
    [SLOT_TYPE_MAIL_ATTACHMENT] =               function(inventorySlot) return GetAttachedItemLink(MAIL_INBOX:GetOpenMailId(), ZO_Inventory_GetSlotIndex(inventorySlot)) end,

	[SLOT_TYPE_TRADING_HOUSE_ITEM_RESULT] =     function(inventorySlot) return GetTradingHouseSearchResultItemLink(ZO_Inventory_GetSlotIndex(inventorySlot)) end,
	[SLOT_TYPE_TRADING_HOUSE_ITEM_LISTING] =    function(inventorySlot) return GetTradingHouseListingItemLink(ZO_Inventory_GetSlotIndex(inventorySlot)) end,
}

local function GetInventorySlotItemLink(inventorySlot)
    local slotType = ZO_InventorySlot_GetType(inventorySlot)
	if linkHelpers[slotType] then
		return linkHelpers[slotType](inventorySlot)
	end
end

local RUNEBOX_ITEM_LINK  = "|H1:item:%d:124:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
local FRAGMENT_ITEM_LINK = "|H1:item:%d:5:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"

function Addon:Initialize()

	--self.Settings = ZO_SavedVars:New("kyoRuneboxTTGlobal", 1, nil, self.Defaults)
	
	ZO_CreateStringId("SI_KYO_RUNEBOX_SHOW_INFO", "Show Runebox Info", 1)
	
	local LRB = LibRunebox

    local function ReturnItemLink(itemLink)
        return itemLink
    end

	local madeSpaceForHeaderRow = false

	local function PreTooltip(tooltipControl, itemLink)
		--if GetItemLinkItemType(itemLink) == ITEMTYPE_CONTAINER then
			local itemId = GetItemLinkItemId(itemLink)
			local collectibleId = LRB:GetRuneboxCollectibleId(itemId)
			if collectibleId then
				if not madeSpaceForHeaderRow then 
					madeSpaceForHeaderRow = true
					tooltipControl:SetMinHeaderRows(1)
				end
				return collectibleId
			end
		--end
	end

	local function PostTooltip(tooltipControl, itemLink, collectibleId)
		local stringId = IsCollectibleUnlocked(collectibleId) and SI_COLLECTIBLEUNLOCKSTATE2 or SI_COLLECTIBLEUNLOCKSTATE0
		tooltipControl:AddHeaderLine(ZO_CachedStrFormat("(<<1>>)", GetString(stringId)), "ZoFontWinT2", 1, TOOLTIP_HEADER_SIDE_LEFT, ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
		madeSpaceForHeaderRow = false
	end

    local function TooltipHook(tooltipControl, method, linkFunc)
        local origMethod = tooltipControl[method]
        tooltipControl[method] = function(self, ...)
            local itemLink = linkFunc(...)
            local collectibleId = PreTooltip(tooltipControl, itemLink)
            origMethod(self, ...)
			if collectibleId then 
				PostTooltip(tooltipControl, itemLink, collectibleId)
			end
        end
    end

    TooltipHook(ItemTooltip, "SetBagItem", GetItemLink)
    TooltipHook(ItemTooltip, "SetTradeItem", GetTradeItemLink)
    TooltipHook(ItemTooltip, "SetBuybackItem", GetBuybackItemLink)
    TooltipHook(ItemTooltip, "SetStoreItem", GetStoreItemLink)
    TooltipHook(ItemTooltip, "SetAttachedMailItem", GetAttachedItemLink)
    TooltipHook(ItemTooltip, "SetLootItem", GetLootItemLink)
    TooltipHook(ItemTooltip, "SetTradingHouseItem", GetTradingHouseSearchResultItemLink)
    TooltipHook(ItemTooltip, "SetTradingHouseListing", GetTradingHouseListingItemLink)
    TooltipHook(ItemTooltip, "SetAction", GetSlotItemLink)
    TooltipHook(ItemTooltip, "SetLink", ReturnItemLink)
	TooltipHook(PopupTooltip, "SetLink", ReturnItemLink)

	local function MakeLink(linkFormat, ...)
		return linkFormat:format(...)
	end
	
	local function ShowRuneboxInfoInChat(runeboxId, runeboxFragments)
		--d("Showing runebox info...")
		if runeboxId then
			d(MakeLink(RUNEBOX_ITEM_LINK, runeboxId))
			if not runeboxFragments then 
				runeboxFragments = LRB:GetRuneboxFragments(runeboxId)
			end
		end
		if runeboxFragments then
			--d(" Fragments: ")
			for _, fragmentItemId in ipairs(runeboxFragments) do
				d(MakeLink(FRAGMENT_ITEM_LINK, fragmentItemId))
			end
		end
	end
	
	local function AddItem(inventorySlot, slotActions)
		local itemLink = GetInventorySlotItemLink(inventorySlot)
		if not itemLink then return end
		local itemId = GetItemLinkItemId(itemLink)

		local runeboxItemId = LRB:GetRuneboxForFragment(itemId)
		local runeboxFragments = LRB:GetRuneboxFragments(runeboxItemId or itemId)
		if runeboxItemId or runeboxFragments then
			slotActions:AddCustomSlotAction(SI_KYO_RUNEBOX_SHOW_INFO, function() ShowRuneboxInfoInChat(runeboxItemId or itemId, runeboxFragments) end)
		end

	end 
	local LCM = LibStub("LibCustomMenu") 
	LCM:RegisterContextMenu(AddItem, LCM.CATEGORY_SECONDARY)
	
	-- Hook collection book tiles for collectibles that have runeboxes (only the ones with fragments for now)
	local collectibleRuneboxes = {}
	for runeboxId, _ in pairs(LRB.RuneboxToFragments) do
		local collectibleId = LRB:GetRuneboxCollectibleId(runeboxId)
		if collectibleId then
			collectibleRuneboxes[collectibleId] = runeboxId
		end
	end

	local function Collectible_ShowMenu(self)
		local collectibleData = self.collectibleData
		if collectibleData then
			local collectibleId = collectibleData:GetId()
			if collectibleId then
				local runeboxId = collectibleRuneboxes[collectibleId]
				if not runeboxId then return end
				zo_callLater(function() 
								AddCustomMenuItem(GetString(SI_KYO_RUNEBOX_SHOW_INFO), function() ShowRuneboxInfoInChat(runeboxId) end)
								ShowMenu()
							end, MENU_ADD_OPTION_LABEL)
			end
		end
	end
	ZO_PreHook(ZO_CollectibleTile_Keyboard, "ShowMenu", Collectible_ShowMenu)

	-- Add support for rightclicking item links
	local function LinkContextRightClick(link, button, _, _, linkType, ...)
		if button == MOUSE_BUTTON_INDEX_RIGHT and linkType == ITEM_LINK_TYPE then
			local itemId = GetItemLinkItemId(link)

			local runeboxItemId = LRB:GetRuneboxForFragment(itemId)
			local runeboxFragments = LRB:GetRuneboxFragments(runeboxItemId or itemId)
			if runeboxItemId or runeboxFragments then
				zo_callLater(function()
						AddCustomMenuItem(GetString(SI_KYO_RUNEBOX_SHOW_INFO), function() ShowRuneboxInfoInChat(runeboxItemId or itemId, runeboxFragments) end)
						ShowMenu()
					end, MENU_ADD_OPTION_LABEL)
			end
		end
	end
    LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, LinkContextRightClick)

end

local function OnAddonLoaded(_, addonName)
    if addonName ~= Addon.Name then return end
    EVENT_MANAGER:UnregisterForEvent(Addon.Name, EVENT_ADD_ON_LOADED)
	Addon:Initialize()
end
EVENT_MANAGER:RegisterForEvent(Addon.Name, EVENT_ADD_ON_LOADED, OnAddonLoaded)

KYO_RUNEBOX_TT = Addon


--[[
	
local function strippedName(name)
	name = name:gsub("'s ", "")
	name = name:gsub("' ", "")
	name = name:gsub(" ", "")
	name = name:gsub("Abner", "Abnur") -- because ESO isn't sure which is correct?
	name = string.lower(name)
	return name
end

--local items = {<insert item ids of runeboxes here (use an item finder)>}
local items =
{

}

function test()

	local collectiblesByName = {}
	for id = 1, 9000 do
		collectiblesByName[strippedName(GetCollectibleName(id))] = id
	end
	
	local LRB = LibRunebox
	for _, itemId in ipairs(items) do
		local link = string.format("|H1:item:%d:124:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", itemId)
		local name = GetItemLinkName(link)
		local strips = {"Runebox: ", "Bound Style Page: ", "Event Style Page: ", "Style Page: ", " Costume", " Pet", " Emote"}
		for _, str in ipairs(strips) do
			name = name:gsub(str, "")
		end
		name = strippedName(name)
		local collectibleId = collectiblesByName[name]
		if name ~= "" and collectibleId then
			df("ItemId #%d = CollectibleId #%d %s", itemId, collectibleId, link)
		else
			collectibleId = LRB:GetRuneboxCollectibleId(itemId)
			--if collectibleId then
			--	df("ItemId #%d = CollectibleId #04%d %s", itemId, collectibleId, link)
			--else
				df("ItemId #%d = CollectibleId #NULL %s", itemId, link)
			--end
		end
	end
end
--]]