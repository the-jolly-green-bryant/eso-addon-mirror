-- Create namespace
DsRGuildNeedOne = {}
local DsRGuildNeedOne = DsRGuildNeedOne or {}

DsRGuildNeedOne.name = "DsRGuildNeedOne"

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildNeedOne:ReturnStack(bagId, slotIndex, targetSlot)
    return function(eventCode, _bagId, _slotIndex, isNewItem, itemSoundCategory, updateReason, stackCountChange)
        if not( targetSlot == _slotIndex ) then
           return
        end
        EVENT_MANAGER:UnregisterForEvent(DsRGuildNeedOne.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
        TransferToGuildBank( bagId, slotIndex)
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildNeedOne:SplitToONE(itemId, quantity)
    return function(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, updateReason, stackCountChange)
        local itemLink   = GetItemLink(bagId, slotIndex)
        local _itemId    = GetItemLinkItemId(itemLink)
        local _quantity  = GetSlotStackSize(bagId, slotIndex)
        local targetSlot = FindFirstEmptySlotInBag(BAG_BACKPACK)

        if not( bagId == BAG_BACKPACK ) then
            return
        end
  
        if not( _itemId == itemId ) then
            return
        end
  
        if not( quantity == _quantity ) then
            return
        end
  
        EVENT_MANAGER:UnregisterForEvent(DsRGuildNeedOne.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)

        EVENT_MANAGER:RegisterForEvent(DsRGuildNeedOne.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, DsRGuildNeedOne:ReturnStack(bagId, slotIndex, targetSlot))
        EVENT_MANAGER:AddFilterForEvent(DsRGuildNeedOne.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK)
  
        CallSecureProtected("RequestMoveItem", bagId, slotIndex, BAG_BACKPACK, targetSlot, 1)
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildNeedOne:TakeONE(inventorySlot, _itemId)
	local slotType         = ZO_InventorySlot_GetType(inventorySlot)
	local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
	local itemLink         = GetItemLink(bagId, slotIndex)
	local itemId           = GetItemLinkItemId(itemLink)
    local targetSlot       = FindFirstEmptySlotInBag(BAG_BACKPACK)
	local quantity         = GetSlotStackSize(bagId, slotIndex)

	if not slotIndex then
	    return
	end
	
	if not( _itemId == itemId ) then
	    return
	end
	
	if not targetSlot then
        CHAT_SYSTEM:Maximize()
        d(DsR.Localization[DsR.language].DsRGuildMenue_DsRTakeOneBackFull)
	    PlaySound("Justice_PickpocketFailed")
		return
	end
		
	if slotType == SLOT_TYPE_BANK_ITEM then
  	    CallSecureProtected("RequestMoveItem", bagId, slotIndex, BAG_BACKPACK, targetSlot, 1)
	elseif slotType == SLOT_TYPE_GUILD_BANK_ITEM then
	    EVENT_MANAGER:RegisterForEvent(DsRGuildNeedOne.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, DsRGuildNeedOne:SplitToONE(itemId, quantity))
		EVENT_MANAGER:AddFilterForEvent(DsRGuildNeedOne.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK)
		
		TransferFromGuildBank(slotIndex)
	else
	    return
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildNeedOne:isValid(inventorySlot)
    local slotType         = ZO_InventorySlot_GetType(inventorySlot)
    local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)

    if not( slotType == SLOT_TYPE_BANK_ITEM or slotType == SLOT_TYPE_GUILD_BANK_ITEM ) then
        return false
    end
	if slotType == SLOT_TYPE_GUILD_BANK_ITEM then
        local guildId = GetSelectedGuildBankId()
        
        if not guildId then
            return false
        end
        if not DoesGuildHavePrivilege(guildId, GUILD_PRIVILEGE_BANK_DEPOSIT) then
            return false
        elseif not( DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_BANK_DEPOSIT) and DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_BANK_WITHDRAW) ) then
            return false
        end
    end
    if slotType == SLOT_TYPE_BANK_ITEM and not CheckInventorySpaceSilently(1) then 
	    return false
	elseif slotType == SLOT_TYPE_GUILD_BANK_ITEM and not CheckInventorySpaceSilently(2) then
	    return false
	end
	if not (GetSlotStackSize(bagId, slotIndex) > 1) then
	    return false
	end
	
	return true
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildNeedOne:ShowContextMenu(inventorySlot, slotActions)
	if not DsRGuildNeedOne:isValid(inventorySlot) then
	    return
	end

    local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
    local itemLink         = GetItemLink(bagId, slotIndex)
	local itemId           = GetItemLinkItemId(itemLink)
	
	AddCustomMenuItem(DsR.Localization[DsR.language].DsRGuildMenue_DsRTakeOne, function() DsRGuildNeedOne:TakeONE(inventorySlot, itemId, false) end)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- On addon loaded
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildNeedOne.OnAddonLoaded(event, addonName)
    EVENT_MANAGER:UnregisterForEvent(DsRGuildNeedOne.name, EVENT_ADD_ON_LOADED) 

    if DsRAutoINV.cfg.TakeOneOnOff then
        LibCustomMenu:RegisterContextMenu(function(...) DsRGuildNeedOne:ShowContextMenu(...) end, LibCustomMenu.CATEGORY_LATE)
    end
end
