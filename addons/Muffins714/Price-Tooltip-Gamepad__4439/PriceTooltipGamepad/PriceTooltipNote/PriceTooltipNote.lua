--[[
	Addon: PriceTooltipNote
	Author: Mladen90 (@Mladen90 EU)
	Created by Mladen90 (@Mladen90 EU)
]]--


PriceTooltipNote = {}
PriceTooltipNote_MENU = {}


PriceTooltipNote_IsLoaded = false


local PriceTooltipNote_LastDivider = nil


PriceTooltipNote_Load = function(eventCode, addonName)
    if addonName ~= PriceTooltipNote.AddOnName then return end

    EVENT_MANAGER:UnregisterForEvent(addonName, eventCode)

	PriceTooltipNote.SavedVariables = ZO_SavedVars:NewAccountWide(PriceTooltipNote.SavedVariablesFileName, PriceTooltipNote.Version, nil, PriceTooltipNote.Default, nil, PriceTooltipNote.AddOnName)

	if (not PriceTooltipNote.SavedVariables.Data) then PriceTooltipNote.SavedVariables.Data = {} end

	PriceTooltipNote_MENU.Init()

	if not PriceTooltip then
		PriceTooltipNote_Extensions()
	end

	-- TODO Loaded is when also PriceTooltip loaded if available
	PriceTooltipNote_IsLoaded = true
end


PriceTooltipNote_Extensions = function()
	PriceTooltipNote_InitTooltips()
	PriceTooltipNote_LinkHandlerExtension()
	ZO_PreHook("ZO_InventorySlot_ShowContextMenu", function(inventorySlot) zo_callLater(function() PriceTooltipNote_ShowContextMenuExtension(inventorySlot) end, 50) end)
	PriceTooltipNote_GamePadActions()
end


PriceTooltipNote_GamePadActions = function()
	local menu = LibCustomMenu
	if menu then
		menu:RegisterKeyStripEnter(function(inventorySlot, slotActions)
			if (IsInGamepadPreferredMode()) then
				local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
				if not (bagId and slotIndex) then return end
				
				local itemLink = GetItemLink(bagId, slotIndex)
				if not itemLink then return end
				
				local linkType = GetLinkType(itemLink)
				if linkType == LINK_TYPE_ACHIEVEMENT then return end

				local stringColor = PriceTooltipNote_GetStringColorFromColor(PriceTooltipNote.SavedVariables.ContextMenuColor)

				ZO_CreateStringId("SI_BINDING_NAME_PRICE_TOOLTIP_NOTE_EDIT_NOTE", stringColor .. "Edit NOTE")
				ZO_CreateStringId("SI_BINDING_NAME_PRICE_TOOLTIP_NOTE_DELETE_NOTE", stringColor .. "Delete NOTE")

				slotActions:AddCustomSlotAction(SI_BINDING_NAME_PRICE_TOOLTIP_NOTE_EDIT_NOTE, function(...) PriceTooltipNote_NoteToChat_Edit(itemLink) end)
				slotActions:AddCustomSlotAction(SI_BINDING_NAME_PRICE_TOOLTIP_NOTE_DELETE_NOTE, function(...) PriceTooltipNote_NoteToChat_Delete(itemLink) end)
			end
		end, menu.CATEGORY_PRIMARY)
	end
end


PriceTooltipNote_AddCustomMenuItems = function(link, button)
	if not (link and button == MOUSE_BUTTON_INDEX_RIGHT) then return end

	local linkType = GetLinkType(link)
	if linkType == LINK_TYPE_ACHIEVEMENT then return end

	local stringColor = PriceTooltipNote_GetStringColorFromColor(PriceTooltipNote.SavedVariables.ContextMenuColor)

	local count = 1
	local entries = {}

	entries[count] =
	{
		label = "Edit NOTE",
		callback = function(...) PriceTooltipNote_NoteToChat_Edit(link) end,
		itemType = MENU_ADD_OPTION_LABEL,
	}
	count = count + 1

	entries[count] =
	{
		label = "Delete NOTE",
		callback = function(...) PriceTooltipNote_NoteToChat_Delete(link) end,
		itemType = MENU_ADD_OPTION_LABEL,
	}
	count = count + 1

	AddCustomSubMenuItem(stringColor .. "PTN MENU", entries)

	ShowMenu()
end


PriceTooltipNote_InitTooltips = function ()
	PriceTooltipNote_InitGamepadTooltips()

	PriceTooltipNote_ToolTipExtension(ItemTooltip, "SetAttachedMailItem", GetAttachedItemLink)
	PriceTooltipNote_ToolTipExtension(ItemTooltip, "SetBagItem", GetItemLink)
	PriceTooltipNote_ToolTipExtension(ItemTooltip, "SetBuybackItem", GetBuybackItemLink)
	PriceTooltipNote_ToolTipExtension(ItemTooltip, "SetLootItem", GetLootItemLink)
	PriceTooltipNote_ToolTipExtension(ItemTooltip, "SetTradeItem", GetTradeItemLink)
	PriceTooltipNote_ToolTipExtension(ItemTooltip, "SetStoreItem", GetStoreItemLink)
	PriceTooltipNote_ToolTipExtension(ItemTooltip, "SetTradingHouseItem", GetTradingHouseSearchResultItemLink)
	PriceTooltipNote_ToolTipExtension(ItemTooltip, "SetTradingHouseListing", GetTradingHouseListingItemLink)
	PriceTooltipNote_ToolTipExtension(ItemTooltip, "SetWornItem", PriceTooltipNote_GetWornItemLink)
	PriceTooltipNote_ToolTipExtension(ItemTooltip, "SetQuestReward", GetQuestRewardItemLink)
	PriceTooltipNote_ToolTipExtension(ItemTooltip, "SetLink", PriceTooltipNote_GetItemLinkFirstParam)
	PriceTooltipNote_ToolTipExtension(PopupTooltip, "SetLink", PriceTooltipNote_GetItemLinkFirstParam)
	
	--[[SetPendingSmithingItem(*luaindex* _patternIndex_, *luaindex* _materialIndex_, *integer* _materialQuantity_, *integer* _itemStyleId_, *luaindex* _traitIndex_)
		GetSmithingPatternResultLink(*luaindex* _patternIndex_, *luaindex* _materialIndex_, *integer* _materialQuantity_, *integer* _itemStyleId_, *luaindex* _traitIndex_,
			*[LinkStyle|#LinkStyle]* _linkStyle_)
		_Returns:_ *string* _link_]]--
	PriceTooltipNote_ToolTipExtension(ZO_SmithingTopLevelCreationPanelResultTooltip, "SetPendingSmithingItem", GetSmithingPatternResultLink)
	
	--[[SetProvisionerResultItem(*luaindex* _recipeListIndex_, *luaindex* _recipeIndex_)
		GetRecipeResultItemLink(*luaindex* _recipeListIndex_, *luaindex* _recipeIndex_, *[LinkStyle|#LinkStyle]* _linkStyle_)
		_Returns:_ *string* _link_ ]]--
	PriceTooltipNote_ToolTipExtension(ZO_ProvisionerTopLevelTooltip, "SetProvisionerResultItem", GetRecipeResultItemLink)
end


PriceTooltipNote_InitGamepadTooltips = function()
	PriceTooltipNote_GamePadToolTipExtension(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP), "LayoutBagItem")
	PriceTooltipNote_GamePadToolTipExtension2(GAMEPAD_INVENTORY, "UpdateCategoryLeftTooltip")
    PriceTooltipNote_GamePadToolTipExtension(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_RIGHT_TOOLTIP), "LayoutBagItem")
    PriceTooltipNote_GamePadToolTipExtension(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_MOVABLE_TOOLTIP), "LayoutBagItem")

	PriceTooltipNote_PostHook(ZO_MailInbox_Gamepad, 'InitializeKeybindDescriptors',
	function(self)
		self.mainKeybindDescriptor[3]["callback"] = function() self:Delete() end
	end)
end


PriceTooltipNote_GamePadToolTipExtension = function(toolTipControl, functionName)
	local base = toolTipControl[functionName]
	toolTipControl[functionName] = function(control, bagId, slotIndex, ...) 
	  local itemLink = GetItemLink(bagId, slotIndex)

	  if itemLink and control then
		  PriceTooltipNote_AddTooltip(control, itemLink, true)
	  end

	  base(control, bagId, slotIndex, ...)
	end
end


PriceTooltipNote_AddTooltip = function(control, itemLink, gamepad)
	if (not control) then return end

	local addedLine = 0

	local divider = nil
	if not gamepad then
		divider = PriceTooltipNote_AddDivider(control)

		if (divider) then
			if (PriceTooltipNote.SavedVariables.FixDoubleTooltip) then
				if (PriceTooltipNote_LastDivider and PriceTooltipNote_LastDivider.PriceTooltipNoteLink == itemLink and PriceTooltipNote_LastDivider:GetName() ~= divider:GetName()) then
					divider:SetHidden(true)
					return
				else
					if (PriceTooltipNote_LastDivider) then PriceTooltipNote_LastDivider.PriceTooltipNoteLink = nil end

					divider.PriceTooltipNoteLink = itemLink
					PriceTooltipNote_LastDivider = divider
				end
			else
				if (PriceTooltipNote_LastDivider) then PriceTooltipNote_LastDivider.PriceTooltipNoteLink = nil end

				divider.PriceTooltipNoteLink = nil
				PriceTooltipNote_LastDivider = nil
			end

			control:AddControl(divider)
			divider:SetAnchor(CENTER)
			divider:SetHidden(false)
		end
	end

	local note = PriceTooltipNote_GetData(itemLink)
	if note then
		local noteColorText = PriceTooltipNote_GetStringColorFromColor(PriceTooltipNote.SavedVariables.TooltipColor)
		addedLine = addedLine + PriceTooltipNote_AddTooltipLine(control, noteColorText .. "NOTE: " .. note, gamepad)
	end

	if divider then divider:SetHidden(addedLine < 1) end

	--Empty line instead of divider for gamepad
	if gamepad then control:AddLine(" ") end
end


PriceTooltipNote_AddDivider = function(tooltipControl) 
    if not tooltipControl.dividerPool then 
        tooltipControl.dividerPool = ZO_ControlPool:New("ZO_BaseTooltipDivider", tooltipControl, "Divider")
    end

	return tooltipControl.dividerPool:AcquireObject() 
end


PriceTooltipNote_AddTooltipLine = function(control, text, gamepad)
	if gamepad then control:AddLine(text, ZO_TOOLTIP_STYLES[PriceTooltipNote.SavedVariables.GamepadFont])
	else
		control:AddVerticalPadding(PriceTooltipNote.SavedVariables.TooltipLineSpacing)
		control:AddLine(text, PriceTooltipNote.SavedVariables.Font, 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_UPPERCASE, LEFT, false)
	end

	return 1
end


PriceTooltipNote_ToolTipExtension = function(toolTipControl, functionName, getItemLinkFunction)
	local base = toolTipControl[functionName]

	toolTipControl[functionName] = function(control, ...)
		base(control, ...)

		if not getItemLinkFunction then return end

		local itemLink = getItemLinkFunction(...)

		if itemLink and control then
			PriceTooltipNote_AddTooltip(control, itemLink, false)
		end
	end
end


PriceTooltipNote_GamePadToolTipExtension2 = function(toolTipControl, functionName)
	local base = toolTipControl[functionName]
	toolTipControl[functionName] = function(selectedData, ...)
		base(selectedData, ...)
		if toolTipControl.selectedEquipSlot then
			GAMEPAD_TOOLTIPS:LayoutBagItem(GAMEPAD_LEFT_TOOLTIP, BAG_WORN, toolTipControl.selectedEquipSlot)
		end
	end
end


PriceTooltipNote_PostHook = function(control, method, fn)
	if control then
		local originalMethod = control[method]
		control[method] = function(self, ...)
			originalMethod(self, ...)
			fn(self, ...)
		end
	end
end


PriceTooltipNote_GetStringColorFromColor = function(color) return PriceTooltipNote_GetStringColor(color.Red, color.Green, color.Blue) end


PriceTooltipNote_GetStringColor = function(red, green, blue)
	local color = ZO_ColorDef:New(red, green, blue, 1)
	return "|c" .. color:ToHex()
end


PriceTooltipNote_LinkHandlerExtension = function()
	local base = ZO_LinkHandler_OnLinkMouseUp
	ZO_LinkHandler_OnLinkMouseUp = function(link, button, control)
		base(link, button, control)
		PriceTooltipNote_AddCustomMenuItems(link, button)
	end
end


PriceTooltipNote_ShowContextMenuExtension = function(inventorySlot)
	local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
	if not (bagId and slotIndex) then return end

	local itemLink = GetItemLink(bagId, slotIndex)
	if not itemLink then return end

	PriceTooltipNote_AddCustomMenuItems(itemLink, MOUSE_BUTTON_INDEX_RIGHT)
end


PriceTooltipNote_GetWornItemLink = function(equipSlot) return GetItemLink(BAG_WORN, equipSlot) end
PriceTooltipNote_GetItemLinkFirstParam = function(itemLink) return itemLink end


PriceTooltipNote_Trim = function(text) return (text or ""):match "^%s*(.-)%s*$" end


PriceTooltipNote_EditNote = function(text)
	local result = PriceTooltipNote_EditNoteInternal(text)
	if (not result) then d("[PTN] Could not resolve link") end
end


function PriceTooltipNote_EditNoteInternal(text)
	text = PriceTooltipNote_Trim(text)
	if (string.len(text) <= 0) then return false end

	local linkText = string.match(PriceTooltipNote_FirstWord(text), "^|H[0-9]:item:.*|h|h$")
	if (not linkText) then return false end

	local linkId = GetItemLinkItemId(linkText)
	if (not linkId) then return false end

	local note = PriceTooltipNote_GetText(text, 1)
	note = PriceTooltipNote_Trim(note)

	if (string.len(note) > 0) then
		PriceTooltipNote.SavedVariables.Data[linkId] = note
		d("[PTN] Updated '" .. linkText .. "' with NOTE '" .. note .. "'")
	else
		PriceTooltipNote.SavedVariables.Data[linkId] = nil
		d("[PTN] Deleted NOTE for '" .. linkText .. "'")
	end

	return true
end


PriceTooltipNote_DeleteNote = function(text)
	local result = PriceTooltipNote_DeleteNoteInternal(text)
	if (not result) then d("[PTN] Could not resolve link") end
end


function PriceTooltipNote_DeleteNoteInternal(text)
	text = PriceTooltipNote_Trim(text)
	if (string.len(text) <= 0) then return false end

	local linkText = string.match(PriceTooltipNote_FirstWord(text), "^|H[0-9]:item:.*|h|h$")
	if (not linkText) then return false end

	local linkId = GetItemLinkItemId(linkText)
	if (not linkId) then return false end

	PriceTooltipNote.SavedVariables.Data[linkId] = nil
	d("[PTN] Deleted NOTE for '" .. linkText .. "'")

	return true
end


PriceTooltipNote_FirstWord = function(text)
	if text then
		for substring in text:gmatch("%S+") do
		   return substring
		end
	end

	return ""
end


PriceTooltipNote_GetText = function(text, skip)
	local result = ""

	if text and skip then
		for substring in text:gmatch("%S+") do
			if skip <= 0 then result = result .. " " .. substring
			else skip = skip - 1 end
		end
	end

	return result or ""
end


PriceTooltipNote_NoteToChat_Edit = function(link)
	if CHAT_SYSTEM and CHAT_SYSTEM.textEntry and CHAT_SYSTEM.textEntry.editControl then
		local chat = CHAT_SYSTEM.textEntry.editControl
		if (not chat:HasFocus()) then StartChatInput() end

		local note = PriceTooltipNote_GetData(link) or "TEXT"

		chat:InsertText("/ptn_edit_note " .. string.gsub(link, '|H0', '|H1') .. " " .. note)
	end
end


PriceTooltipNote_NoteToChat_Delete = function(link)
	if CHAT_SYSTEM and CHAT_SYSTEM.textEntry and CHAT_SYSTEM.textEntry.editControl then
		local chat = CHAT_SYSTEM.textEntry.editControl
		if (not chat:HasFocus()) then StartChatInput() end

		chat:InsertText("/ptn_delete_note " .. string.gsub(link, '|H0', '|H1'))
	end
end


PriceTooltipNote_GetData = function(link)
	if (not link) then return nil end

	local linkId = GetItemLinkItemId(link)
	if (not linkId) then return nil end

	local value = PriceTooltipNote.SavedVariables.Data[linkId]
	if (not value) then return nil end

	return value
end


SLASH_COMMANDS["/ptn_edit_note"] = PriceTooltipNote_EditNote
SLASH_COMMANDS["/ptn_delete_note"] = PriceTooltipNote_DeleteNote


EVENT_MANAGER:RegisterForEvent("PriceTooltipNote_Load", EVENT_ADD_ON_LOADED, PriceTooltipNote_Load)