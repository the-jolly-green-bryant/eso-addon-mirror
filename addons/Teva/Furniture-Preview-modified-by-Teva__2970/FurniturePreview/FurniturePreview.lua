-----------------
--  LIBRARIES  --
-----------------
local PREVIEW = LibTevaPreview
local LAM = LibAddonMenu2
--local chat = LibChatMessage("|cFFC814Teva's|r|cFF6BF3 Furniture Preview|r", "TevaBTfurniture")	--removed dependency in v2.4.5
-----------------
--  CONSTANTS  --
-----------------
local FurPreview = FurPreview or {
	name = "FurnPreview",
	title = "Furniture Preview by Teva",
	display = "|cFFC814Furniture Preview by Teva|r",
	author = "Teva, based on ItemPreview (discontinued) by Shinni",
	version = "2.58",
	versionSV = 2,
	folder = "FurniturePreview",	--"TevaFurniturePreview",
	defaults = {
		disablePreviewOnClick = false,
		inventory = true,
		bank = true,
		guildBank = true,
		tradinghouse = true,
		mailSend = false,
	},
}
-----------------

-- copied from esoui code:
local function GetInventorySlotComponents(inventorySlot)
	-- Figure out what got passed in...inventorySlot could be a list or button type...
	local buttonPart = inventorySlot
	local listPart
	local multiIconPart
	local controlType = inventorySlot:GetType()
	if controlType == CT_CONTROL and buttonPart.slotControlType and buttonPart.slotControlType == "listSlot" then
		listPart = inventorySlot
		buttonPart = inventorySlot:GetNamedChild("Button")
		multiIconPart = inventorySlot:GetNamedChild("MultiIcon")
	elseif controlType == CT_BUTTON then
		listPart = buttonPart:GetParent()
	end
	return buttonPart, listPart, multiIconPart
end

-------------------------------------------------------------------------------
--  FUNCTION OnLoad  --
-------------------------------------------------------------------------------
local function OnLoadFurniturePreview( eventCode, addonName )
	if addonName ~= FurPreview.folder then return end
	FurPreview.sv = ZO_SavedVars:NewAccountWide("Furniture", FurPreview.versionSV, nil, FurPreview.defaults, nil, "$Machine")
	FurPreview.sv.mailInbox = nil		--to remove possibly selected option that doesn't work after Flames of Ambition
	FurPreview.sv.trade = nil			--to remove possibly selected option that doesn't work after Flames of Ambition
	FurPreview.ZO_InventorySlot_OnSlotClicked = ZO_InventorySlot_OnSlotClicked
	FurPreview:SetPreviewOnClick(not FurPreview.sv.disablePreviewOnClick)
	-- Update the mouse over cursor icon. display a preview cursor when previewing is possible
	ZO_PreHook(ZO_ItemSlotActionsController, "SetInventorySlot", function(self, inventorySlot)
		if(GetCursorContentType() ~= MOUSE_CONTENT_EMPTY) then return end
		local itemLink, slotType = FurPreview:GetInventorySlotItemData(inventorySlot)
		if not inventorySlot then
			WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_DO_NOT_CARE)
			return
		end
		if FurPreview:CanPreviewItem(inventorySlot, itemLink) then
			WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_PREVIEW)
		end
	end)
	-- end preview when switching tabs in the guild store
	ZO_PreHook(TRADING_HOUSE, "HandleTabSwitch", function(_, tabData)
		FurPreview:EndPreview()
	end)--

--TevaNOTE: the following section seems responsible for this reported issue in versions prior to 2.4.6
--[[--If I don't have the skill to fix the stated issue, so must disable this section and hence the right-click "Preview" ability instead...

-- Add the preview option to the right click menu for item links (ie. chat)
	local original_OnLinkMouseUp = ZO_LinkHandler_OnLinkMouseUp
	ZO_LinkHandler_OnLinkMouseUp = function(itemLink, button, control)
		if (type(itemLink) == 'string' and #itemLink > 0) then
			local handled = LINK_HANDLER:FireCallbacks(LINK_HANDLER.LINK_MOUSE_UP_EVENT, itemLink, button, ZO_LinkHandler_ParseLink(itemLink))
			if (not handled) then
--"Since installing this addon, when right-clicking an item in chat, I get "MM Price to Chat" and "Popup Item Data" listed twice in the menu."
--TevaNOTE: the following line seems responsible for this reported issue in version 2.4.5
--				original_OnLinkMouseUp(itemLink, button, control)	--TevaNOTE: maybe commenting out just this line would fix it 
-- Kaida's test shows fixed with above line commented out but another on the forums says it is broken again, so reverting to removing right-click functionality
				if (button == 2 and itemLink ~= '') then
					local inventorySlot = nil
					if FurPreview:CanPreviewItem(inventorySlot, itemLink) then
						AddCustomMenuItem(GetString(SI_CRAFTING_ENTER_PREVIEW_MODE), function()
							FurPreview:Preview(inventorySlot, itemLink)
						end)
						ShowMenu(control)
					end
				end
			end
		end
	end --
	ZO_PreHook("ZO_InventorySlot_ShowContextMenu", function(control)
		zo_callLater(function() 
			if FurPreview:CanPreviewItem(control) then
				AddCustomMenuItem(GetString(SI_CRAFTING_ENTER_PREVIEW_MODE), function()
					FurPreview:Preview(control)
				end)
				ShowMenu(control)
			end
		end, 50)
	end) --
--]]--

	MenuFurniturePreview()
end
--  end FUNCTION OnLoad  --
-------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(FurPreview.name, EVENT_ADD_ON_LOADED, OnLoadFurniturePreview)
-------------------------------------------------------------------------------

function FurPreview:SetPreviewOnClick(previewOnClick)
	disablePreviewOnClick = not previewOnClick
	FurPreview.sv.disablePreviewOnClick = disablePreviewOnClick
	-- Add preview when adding on an item slot (inventory, guild store, trade, mail etc. )
	local BUTTON_LEFT = 1
	ZO_InventorySlot_OnSlotClicked = FurPreview.ZO_InventorySlot_OnSlotClicked
	if not disablePreviewOnClick then
		ZO_PreHook("ZO_InventorySlot_OnSlotClicked", function(inventorySlot, button)
			if(button ~= BUTTON_LEFT) then return end
			if(GetCursorContentType() ~= MOUSE_CONTENT_EMPTY) then return end
			inventorySlot = GetInventorySlotComponents(inventorySlot)
			if FurPreview:CanPreviewItem(inventorySlot) then
				FurPreview:Preview(inventorySlot)
				WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_PREVIEW)
				return true
			end
		end)
	end
end

-- how to get the item link for the specific item slot types
local slotTypeToItemLink = {
	[SLOT_TYPE_TRADING_HOUSE_ITEM_LISTING] = function(inventorySlot) return GetTradingHouseListingItemLink(ZO_Inventory_GetSlotIndex(inventorySlot)) end,

	[SLOT_TYPE_STORE_BUYBACK] = function(inventorySlot) return GetBuybackItemLink(inventorySlot.index) end,

--	[SLOT_TYPE_THEIR_TRADE] = function(inventorySlot) return GetTradeItemLink(TRADE_THEM, inventorySlot.index) end,
--	[SLOT_TYPE_MY_TRADE] = function(inventorySlot) return GetTradeItemLink(TRADE_ME, inventorySlot.index) end,

	[SLOT_TYPE_ITEM] = function(inventorySlot) return GetItemLink(ZO_Inventory_GetBagAndIndex(inventorySlot)) end,
	[SLOT_TYPE_BANK_ITEM] = function(inventorySlot) return GetItemLink(ZO_Inventory_GetBagAndIndex(inventorySlot)) end,
	[SLOT_TYPE_GUILD_BANK_ITEM] = function(inventorySlot) return GetItemLink(ZO_Inventory_GetBagAndIndex(inventorySlot)) end,

	[SLOT_TYPE_MAIL_QUEUED_ATTACHMENT] = function(inventorySlot) return GetItemLink(ZO_Inventory_GetBagAndIndex(inventorySlot)) end,
	--
	[SLOT_TYPE_MAIL_ATTACHMENT] = function(inventorySlot)
		local attachmentIndex = ZO_Inventory_GetSlotIndex(inventorySlot)
		if(attachmentIndex) then
			if not inventorySlot.money then
				if(inventorySlot.stackCount > 0) then
					return GetAttachedItemLink(MAIL_INBOX:GetOpenMailId(), attachmentIndex)
				end
			end
		end
	end,--
}

function FurPreview:GetInventorySlotItemData(inventorySlot)
	if not inventorySlot then return end
	local slotType = ZO_InventorySlot_GetType(inventorySlot)
	local itemLink
	local getItemLink = slotTypeToItemLink[slotType]
	if getItemLink then
		itemLink = getItemLink(inventorySlot)
	end
	return itemLink, slotType
end

function FurPreview:Preview(inventorySlot, itemLink)
	local slotType
	if inventorySlot then
		itemLink, slotType = FurPreview:GetInventorySlotItemData(inventorySlot)
	end
	self.inventorySlot = inventorySlot
	self.itemLink = itemLink
	if inventorySlot ~= nil then
		if slotType == SLOT_TYPE_ITEM or slotType == SLOT_TYPE_BANK_ITEM or slotType == SLOT_TYPE_GUILD_BANK_ITEM then
			PREVIEW:PreviewInventoryItemAsFurniture(ZO_Inventory_GetBagAndIndex(inventorySlot))	--failed change Aug14 
--			PreviewInventoryItem(ZO_Inventory_GetBagAndIndex(inventorySlot))	--game function private so must stay as is
			return
		end
	end
end

function FurPreview:EndPreview()
	self.inventorySlot = nil
	self.itemLink = nil
	DisablePreviewMode()
end

function FurPreview:CanPreviewItem(inventorySlot, itemLink)
	local slotType
	if inventorySlot then
		if not self:IsValidScene() then
			return false
		end
		itemLink, slotType = FurPreview:GetInventorySlotItemData(inventorySlot)	
	end
	if slotType == SLOT_TYPE_ITEM or slotType == SLOT_TYPE_BANK_ITEM or slotType == SLOT_TYPE_GUILD_BANK_ITEM then
		return IsItemPlaceableFurniture(ZO_Inventory_GetBagAndIndex(inventorySlot)) or IsItemLinkPlaceableFurniture(GetItemLinkRecipeResultItemLink(itemLink))
	end
--	if CanItemLinkBePreviewed(itemLink) then return true end	--if PREVIEW:CanPreviewItemLink(itemLink)	--changed Aug14
end

function FurPreview:IsValidScene()
	return FurPreview.sv[SCENE_MANAGER:GetCurrentScene():GetName()]
end

-------------------------------------------------------------------------------
--  SETTINGS MENU  --
function MenuFurniturePreview()
	local panelData = {
		type = "panel",
		name = FurPreview.title,
		displayName = FurPreview.display,
		author = FurPreview.author,
		version = FurPreview.version,
		registerForDefaults = true,
	}
	FurPreview.optionsTable = {--[[
		{
			type = "checkbox",
			name = "Preview on Mouse Click",
			getFunc = function() return not FurPreview.sv.disablePreviewOnClick end,
			setFunc = function(value)
				self:SetPreviewOnClick(value)
			end,
			width = "full",
			default = true,
		},--]]
		{
			type = "header",
			name = "Scenes where Preview is Active",
			width = "full",
		},
	}
	local scenes = {"inventory", "bank", "guildBank", "tradinghouse", "mailSend"}
	local lang = {
		startWithClick = "Preview on mouse click",
		scenes = "Scenes",
		inventory = "Preview items in inventory",
		bank = "Preview items at bank",
		guildBank = "Preview items at guild bank",
		tradinghouse = "Preview items in guild stores",
		mailSend = "Preview items when sending in mail",
		mailInbox = "Preview items in mail inbox",
		trade = "Preview items during trading",
	}
	for _, scene in pairs(scenes) do
		local tag = scene
		table.insert(FurPreview.optionsTable, {
			type = "checkbox",
			name = lang[tag],
			getFunc = function() return FurPreview.sv[tag] end,
			setFunc = function(value) FurPreview.sv[tag] = value end,
			width = "full",	--or "half" (optional)
			default = true,
		})
	end
	table.insert(FurPreview.optionsTable, {
			type = "header",
			name = "CANNOT PREVIEW ITEMS WHEN LINKED WITHIN CHAT"
	})
	table.insert(FurPreview.optionsTable, {
			type = "header",
			name = "(against ZOS Policy to do so)"
	})

	LAM:RegisterAddonPanel("FurniturePreviewOptions", panelData)
	LAM:RegisterOptionControls("FurniturePreviewOptions", FurPreview.optionsTable)
end
--  end SETTINGS MENU  --
-------------------------------------------------------------------------------