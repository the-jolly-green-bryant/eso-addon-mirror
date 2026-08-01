-- Create namespace
DsRGuildPersonalMouseMenu = {}
local DsRGuildPersonalMouseMenu = DsRGuildPersonalMouseMenu or {}

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPersonalMouseMenu.AddCustomMenuItems(itemLink, button, bagId, slotIndex)
	if not (itemLink and button == MOUSE_BUTTON_INDEX_RIGHT) then return end

	local linkType = GetLinkType(itemLink)
	if linkType == LINK_TYPE_ACHIEVEMENT then return end

	local entriesJunk = {}

	entriesJunk[1] = 
	{
		label    = GetString(DsRGuildPersonal_JunkManuSetPermJunk),
		callback = function(...) DsRGuildPersonalMouseMenu.MarkManuPermaJunk(itemLink, bagId, slotIndex) end,
		itemType = MENU_ADD_OPTION_LABEL,
	}
	entriesJunk[2] = 
	{
		label    = GetString(DsRGuildPersonal_JunkManuRemPermJunk),
		callback = function(...) DsRGuildPersonalMouseMenu.UnMarkManuPermaJunk(itemLink, bagId, slotIndex) end,
		itemType = MENU_ADD_OPTION_LABEL,
	}

	local stringColor = DsRGuildPrice_GetStringColorFromColor(DsRGuildPrice.SavedVariables.ContextMenuColor)
	AddCustomSubMenuItem(stringColor .. "[DsR-Junk]", entriesJunk)

	local entriesConsum = {}

	entriesConsum[1] = 
	{
		label    = GetString(DsRGuildPersonal_ConsumeSetFood),
		callback = function(...) DsRGuildPersonalMouseMenu.ConsumeSetFood(itemLink, bagId, slotIndex) end,
		itemType = MENU_ADD_OPTION_LABEL,
	}
	entriesConsum[2] = 
	{
		label    = GetString(DsRGuildPersonal_ConsumeSetXP),
		callback = function(...) DsRGuildPersonalMouseMenu.ConsumeSetXP(itemLink, bagId, slotIndex) end,
		itemType = MENU_ADD_OPTION_LABEL,
	}
	entriesConsum[3] = 
	{
		label    = GetString(DsRGuildPersonal_ConsumeSetAP),
		callback = function(...) DsRGuildPersonalMouseMenu.ConsumeSetAP(itemLink, bagId, slotIndex) end,
		itemType = MENU_ADD_OPTION_LABEL,
	}
	entriesConsum[4] = 
	{
		label    = "---------",
		callback = function(...) return end,
		itemType = MENU_ADD_OPTION_LABEL,
	}
	entriesConsum[5] = 
	{
		label    = GetString(DsRGuildPersonal_ConsumeRemFood),
		callback = function(...) DsRGuildPersonalMouseMenu.ConsumeRemFood(itemLink, bagId, slotIndex) end,
		itemType = MENU_ADD_OPTION_LABEL,
	}
	entriesConsum[6] = 
	{
		label    = GetString(DsRGuildPersonal_ConsumeRemXP),
		callback = function(...) DsRGuildPersonalMouseMenu.ConsumeRemXP(itemLink, bagId, slotIndex) end,
		itemType = MENU_ADD_OPTION_LABEL,
	}
	entriesConsum[7] = 
	{
		label    = GetString(DsRGuildPersonal_ConsumeRemAP),
		callback = function(...) DsRGuildPersonalMouseMenu.ConsumeRemAP(itemLink, bagId, slotIndex) end,
		itemType = MENU_ADD_OPTION_LABEL,
	}

	local stringColor = DsRGuildPrice_GetStringColorFromColor(DsRGuildPrice.SavedVariables.ContextMenuColor)
	AddCustomSubMenuItem(stringColor .. "[DsR-Consumer]", entriesConsum)

	ShowMenu()
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPersonalMouseMenu.LinkHandlerExtension()
	local base = ZO_LinkHandler_OnLinkMouseUp
	ZO_LinkHandler_OnLinkMouseUp = function(link, button, control)
		base(link, button, control)
		DsRGuildPersonalMouseMenu.AddCustomMenuItems(link, button)
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPersonalMouseMenu.ShowContextMenuExtension(inventorySlot)
	local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
	if not (bagId and slotIndex) then return end

	local itemLink = GetItemLink(bagId, slotIndex)
	if not itemLink then return end

	DsRGuildPersonalMouseMenu.AddCustomMenuItems(itemLink, MOUSE_BUTTON_INDEX_RIGHT, bagId, slotIndex)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPersonalMouseMenu.MarkManuPermaJunk(itemLink, bagId, slotIndex)
    local itemId   = GetItemId(bagId, slotIndex)
	
    DsRGuildPersonal.ACCconfig.JunkMarkManu[itemId] = { itemLink = itemLink, MarkJunk = true, }
	SetItemIsJunk(bagId, slotIndex, true)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPersonalMouseMenu.UnMarkManuPermaJunk(itemLink, bagId, slotIndex)
    local itemId   = GetItemId(bagId, slotIndex)

    DsRGuildPersonal.ACCconfig.JunkMarkManu[itemId] = { itemLink = itemLink, MarkJunk = false, }
	SetItemIsJunk(bagId, slotIndex, false)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPersonalMouseMenu.ConsumeSetFood(itemLink, bagId, slotIndex)
	local itemType = GetItemType(bagId, slotIndex)
	if DsRGuildPersonalConsumer.IsAPbuff(bagId, slotIndex) then 
		d(" |c9fb6cd[DsR-Consumer]|r " .. itemLink ..  GetString(DsRGuildPersonal_ConsumeFailTyp))
		return
	end
	if DsRGuildPersonalConsumer.IsXPbuff(bagId, slotIndex) then
		d(" |c9fb6cd[DsR-Consumer]|r " .. itemLink ..  GetString(DsRGuildPersonal_ConsumeFailTyp))
		return
	end
	if not (itemType == ITEMTYPE_DRINK or itemType == ITEMTYPE_FOOD) then
		d(" |c9fb6cd[DsR-Consumer]|r " .. itemLink ..  GetString(DsRGuildPersonal_ConsumeFailTyp))
		return
	end
	DsRGuildPersonal.GetSettings()["DeconJunk"]["ConsumeAutoEatTyp"] = itemLink
	DsRGuildPersonal.GetSettings()["DeconJunk"]["ConsumeAutoEatTime"] = "5"
	d(" |c9fb6cd[DsR-Consumer]|r " .. itemLink ..  GetString(DsRGuildPersonal_ConsumeSetAutoTyp))
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPersonalMouseMenu.ConsumeRemFood(itemLink, bagId, slotIndex)
	DsRGuildPersonal.GetSettings()["DeconJunk"]["ConsumeAutoEatTyp"] = nil
	DsRGuildPersonal.GetSettings()["DeconJunk"]["ConsumeAutoEatTime"] = "0"
	d(" |c9fb6cd[DsR-Consumer]|r " .. itemLink ..  GetString(DsRGuildPersonal_ConsumeRemAutoTyp))
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPersonalMouseMenu.ConsumeSetAP(itemLink, bagId, slotIndex)
	if not DsRGuildPersonalConsumer.IsAPbuff(bagId, slotIndex) then
		d(" |c9fb6cd[DsR-Consumer]|r " .. itemLink ..  GetString(DsRGuildPersonal_ConsumeFailAP))
		return
	end
	DsRGuildPersonal.GetSettings()["DeconJunk"]["ConsumeAutoEatAP"] = itemLink
	DsRGuildPersonal.GetSettings()["DeconJunk"]["ConsumeAutoAPOnOff"] = true
	d(" |c9fb6cd[DsR-Consumer]|r " .. itemLink ..  GetString(DsRGuildPersonal_ConsumeSetAutoXPAp))
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPersonalMouseMenu.ConsumeRemAP(itemLink, bagId, slotIndex)
	DsRGuildPersonal.GetSettings()["DeconJunk"]["ConsumeAutoEatAP"] = nil
	DsRGuildPersonal.GetSettings()["DeconJunk"]["ConsumeAutoAPOnOff"] = false
	d(" |c9fb6cd[DsR-Consumer]|r " .. itemLink ..  GetString(DsRGuildPersonal_ConsumeRemAutoXPAP))
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPersonalMouseMenu.ConsumeSetXP(itemLink, bagId, slotIndex)
	if not DsRGuildPersonalConsumer.IsXPbuff(bagId, slotIndex) then
		d(" |c9fb6cd[DsR-Consumer]|r " .. itemLink ..  GetString(DsRGuildPersonal_ConsumeFailXP))
		return
	end
	DsRGuildPersonal.GetSettings()["DeconJunk"]["ConsumeAutoEatXP"] = itemLink
	DsRGuildPersonal.GetSettings()["DeconJunk"]["ConsumeAutoXPOnOff"] = true
	d(" |c9fb6cd[DsR-Consumer]|r " .. itemLink ..  GetString(DsRGuildPersonal_ConsumeSetAutoXPAp))
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPersonalMouseMenu.ConsumeRemXP(itemLink, bagId, slotIndex)
	DsRGuildPersonal.GetSettings()["DeconJunk"]["ConsumeAutoEatXP"] = nil
	DsRGuildPersonal.GetSettings()["DeconJunk"]["ConsumeAutoXPOnOff"] = false
	if not itemLink then return end
	d(" |c9fb6cd[DsR-Consumer]|r " .. itemLink ..  GetString(DsRGuildPersonal_ConsumeRemAutoXPAP))
end
