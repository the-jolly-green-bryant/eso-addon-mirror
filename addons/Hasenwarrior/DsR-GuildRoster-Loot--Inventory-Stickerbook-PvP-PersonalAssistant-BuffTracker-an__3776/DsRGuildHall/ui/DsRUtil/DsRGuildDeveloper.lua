DsRGuildDeveloper = {}
local DsRGuildDeveloper = DsRGuildDeveloper  or {}

DsRGuildDeveloper.name = "DsRGuildDeveloper"


-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildDeveloper.AddCustomMenuItems(itemLink, button, bagId, slotIndex)
    if not (itemLink and button == MOUSE_BUTTON_INDEX_RIGHT) then return end

	local linkType = GetLinkType(itemLink)
	if linkType == LINK_TYPE_ACHIEVEMENT then return end

    local itemName 	       = GetItemLinkName(itemLink)
    local FullName         = LocalizeString("<<1>>", itemName)
    local itemId           = GetItemLinkItemId(itemLink)
    local itemIcon         = GetItemLinkIcon(itemLink)
    local itemquality      = GetItemLinkQuality(itemLink)
    local itemqualityColor = GetItemQualityColor(itemquality)
    local colorItem        = zo_strformat("|c<<1>>", itemqualityColor:ToHex())
    local itemTyp    	   = GetItemLinkItemType(itemLink)
    local typDescArt       = GetString ( "SI_ITEMTYPE", itemTyp ) or ""
    local itemTrait        = GetItemLinkTraitType(itemLink)
    local traitText        = GetString("SI_ITEMTRAITTYPE", itemTrait) or ""

	local entriesDEV = {}

	entriesDEV[1] = 
	{
		label    = DsR.Localization[DsR.language].DsRGuildMenue_DeveloperID,
		callback = function(...) DsRGuildDeveloper.itemID(FullName, colorItem, itemId) end,
		itemType = MENU_ADD_OPTION_LABEL,
	}
	entriesDEV[2] = 
	{
		label    = DsR.Localization[DsR.language].DsRGuildMenue_DeveloperICON,
		callback = function(...) DsRGuildDeveloper.itemICON(FullName, colorItem, itemIcon) end,
		itemType = MENU_ADD_OPTION_LABEL,
	}
	entriesDEV[3] = 
	{
		label    = DsR.Localization[DsR.language].DsRGuildMenue_DeveloperTYPE,
		callback = function(...) DsRGuildDeveloper.itemTYP(FullName, colorItem, itemTyp, typDescArt) end,
		itemType = MENU_ADD_OPTION_LABEL,
	}
	entriesDEV[4] = 
	{
		label    = DsR.Localization[DsR.language].DsRGuildMenue_DeveloperTRAIT,
		callback = function(...) DsRGuildDeveloper.itemTRAIT(FullName, colorItem, itemTrait, traitText) end,
		itemType = MENU_ADD_OPTION_LABEL,
	}
	entriesDEV[5] = 
	{
		label    = "---------",
		callback = function(...) return end,
		itemType = MENU_ADD_OPTION_LABEL,
	}
	entriesDEV[6] = 
	{
		label    = DsR.Localization[DsR.language].DsRGuildMenue_DeveloperShowAll,
		callback = function(...) DsRGuildDeveloper.itemShowAll(FullName, colorItem, itemId, itemIcon, itemTyp, typDescArt, itemTrait, traitText) end,
		itemType = MENU_ADD_OPTION_LABEL,
	}
	
	local stringColor = DsRGuildPrice_GetStringColorFromColor(DsRGuildPrice.SavedVariables.ContextMenuColor)

	AddCustomSubMenuItem(stringColor .. "[DsR-Developer]", entriesDEV)

    ShowMenu()
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildDeveloper.itemShowAll(FullName, colorItem, itemId, itemIcon, itemTyp, typDescArt, itemTrait, traitText)
    DsRGuildDeveloper.itemID(FullName, colorItem, itemId)
    DsRGuildDeveloper.itemICON(FullName, colorItem, itemIcon)
    DsRGuildDeveloper.itemTYP(FullName, colorItem, itemTyp, typDescArt)
    DsRGuildDeveloper.itemTRAIT(FullName, colorItem, itemTrait, traitText)
    return
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildDeveloper.itemID(FullName, colorItem, itemId)
    CHAT_SYSTEM:Maximize()
    d("|c9fb6cd[DsR-DEV]|r |c00ff00ID:|r " .. colorItem .. FullName .. "|r -> " .. itemId )
    return
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildDeveloper.itemICON(FullName, colorItem, itemIcon)
    CHAT_SYSTEM:Maximize()
    
    d("|c9fb6cd[DsR-DEV]|r |c00ff00ICON:|r " .. colorItem .. FullName .. "|r -> " .. zo_iconTextFormat(itemIcon, 26, 26, " ") .. " " .. itemIcon )
    return
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildDeveloper.itemTYP(FullName, colorItem, itemTyp, typDescArt)
    CHAT_SYSTEM:Maximize()
    d("|c9fb6cd[DsR-DEV]|r |c00ff00TYPE:|r " .. colorItem .. FullName .. "|r -> " .. itemTyp .. " ( " .. typDescArt .. " )" )
    return
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildDeveloper.itemTRAIT(FullName, colorItem, itemTrait, traitText)
    CHAT_SYSTEM:Maximize()
    d("|c9fb6cd[DsR-DEV]|r |c00ff00TRAIT:|r " .. colorItem .. FullName .. "|r -> " .. itemTrait .. " ( " .. traitText .. " )"  )
    return
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildDeveloper.LinkHandlerExtension()
	local base = ZO_LinkHandler_OnLinkMouseUp
	ZO_LinkHandler_OnLinkMouseUp = function(link, button, control)
		base(link, button, control)
		DsRGuildDeveloper.AddCustomMenuItems(link, button)
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildDeveloper.ShowContextMenuExtension(inventorySlot)
	local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
	if not (bagId and slotIndex) then return end

	local itemLink = GetItemLink(bagId, slotIndex)
	if not itemLink then return end

	DsRGuildDeveloper.AddCustomMenuItems(itemLink, MOUSE_BUTTON_INDEX_RIGHT, bagId, slotIndex)
end


-------------------------------------------------------------------------------------------------------------------------------------------------
-- On addon loaded
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildDeveloper.OnAddonLoaded(event, addonName)
    EVENT_MANAGER:UnregisterForEvent(DsRGuildDeveloper.name, EVENT_ADD_ON_LOADED) 

    if DsRAutoINV.cfg.DeveloperMode then
        DsRGuildDeveloper.LinkHandlerExtension()
        ZO_PreHook("ZO_InventorySlot_ShowContextMenu", function(inventorySlot) zo_callLater(function() DsRGuildDeveloper.ShowContextMenuExtension(inventorySlot) end, 50) end)
    end
end

