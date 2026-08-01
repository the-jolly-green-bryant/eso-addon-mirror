ColorBlindMode = {}
local CBM = ColorBlindMode or {}
CBM.name = "ColorBlindMode"

function CBM.OnAddOnLoaded(eventCode, addonName)
	if addonName ~= CBM.name then return end
	EVENT_MANAGER:UnregisterForEvent(CBM.name, EVENT_ADD_ON_LOADED)
	CBM:Initialise()
end

function CBM:Initialise()
	-- Inventory, Bank
	for k,inv in pairs(PLAYER_INVENTORY.inventories) do
		local listView = inv.listView
		if (listView and listView.dataTypes and listView.dataTypes[1]) then
			ZO_PreHook(listView.dataTypes[1], "setupCallback", function (control, slot)
				local itemLink = GetItemLink(control.dataEntry.data.bagId, control.dataEntry.data.slotIndex, LINK_STYLE_BRACKETS)
				self:AddMarker(control, itemLink)
			end)
		end
	end

	-- Research Dialog
	local dialogList = ZO_ListDialog1List
	if (dialogList and dialogList.dataTypes and dialogList.dataTypes[1]) then
		ZO_PreHook(dialogList.dataTypes[1], "setupCallback", function (control, slot)
			local itemLink = GetItemLink(control.dataEntry.data.bagId, control.dataEntry.data.slotIndex, LINK_STYLE_BRACKETS)
			self:AddMarker(control, itemLink)
		end)
	end

  	ZO_PreHookHandler(PopupTooltip, 'OnUpdate', function() self:AddPopupMarker(PopupTooltip) end)
	

	-- Merchants
	self:InitialiseList(ZO_StoreWindowList)
	self:InitialiseList(ZO_BuyBackList)
	self:InitialiseList(ZO_RepairWindowList)
	-- Deconstruction
	self:InitialiseList(ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack)
	self:InitialiseList(ZO_EnchantingTopLevelInventoryBackpack)
	-- Loot
	self:InitialiseList(ZO_LootAlphaContainerList)

	-- Quickslot Inventory Tab
	self:InitialiseList(ZO_QuickSlotList)

	-- Guild Stores
	-- Delay bc function finishes just slightly before new fields are available?
    	TRADING_HOUSE_SEARCH:RegisterCallback( "OnSearchStateChanged", function(...) zo_callLater(function(...) self:AddGuildStoreMarker(...) end, 5) end)
--	self:InitialiseList(ZO_TradingHousePostedItemsList)
	
	-- Mail Attachments
	ZO_PostHook('GetAttachedItemInfo', function (mailId, slot) self:AddMailMarker(mailId, slot) end)

	-- Trade Window
	local tradeControl = GetControl("ZO_TradeWindow")
	ZO_PostHook(tradeControl, "OnTradeWindowItemAdded", function(...) self:AddTradeMarker(...) end)
	ZO_PreHook(tradeControl, "OnTradeWindowItemRemoved", function(...) self:RemoveTradeMarker(...) end)
	ZO_PreHook(tradeControl, "ResetSlot", function(...) self:ClearTradeMarker(...) end)
	-- OnTradeWindowCanceled
	-- OnTradeFailed
	-- OnTradeSucceeded
end


function CBM:InitialiseList(listView)
	if (listView and listView.dataTypes and listView.dataTypes[1]) then
		ZO_PreHook(listView.dataTypes[1], "setupCallback", function (control, slot)
			local itemLink = GetStoreItemLink(slot.slotIndex)
			self:AddMarker(control, itemLink)
		end)
	end

end

function CBM:AddTradeMarker(obj, eventCode, who, tradeSlot, last)
	local control
	if who == TRADE_THEM then
		control = GetControl("TheirTradeWindowSlot" .. tradeSlot)
	else
		control = GetControl("MyTradeWindowSlot"..tradeSlot)
	end
	if control == nil then return end
    	local itemName, icon, quantity, displayQuality = GetTradeItemInfo(who, tradeSlot)
	
	self:AddIcon(control, displayQuality)
end

function CBM:RemoveTradeMarker(obj, eventCode, who, tradeSlot, last)
	self:ClearTradeMarker(obj, who, tradeSlot)
end

function CBM:ClearTradeMarker(obj, who, tradeSlot)
	local control
	if who == TRADE_THEM then
		control = GetControl("TheirTradeWindowSlot" .. tradeSlot)
	else
		control = GetControl("MyTradeWindowSlot"..tradeSlot)
	end
	if control == nil then return end
	
	local item = control:GetNamedChild(CBM.name)
	if item then 
		item:SetHidden(true)
	end
end
	

function CBM:AddGuildStoreMarker(searchState, searchOutcome)
	for index=1,TRADING_HOUSE_SEARCH:GetNumItemsOnPage() do
		local link = GetTradingHouseSearchResultItemLink(index)
		local quality = GetItemLinkQuality(link)
		local control = ZO_TradingHouseBrowseItemsRightPaneSearchResults:GetNamedChild("1Row" .. index)
		if not control then
			control = ZO_TradingHouseBrowseItemsRightPaneSearchResults:GetNamedChild("3Row" .. index)
		end
		if not control then
			return
		end
		self:AddIcon(control, quality)
	end
end

function CBM:AddMailMarker(mailId, slot)
	if not mailId then return end
	local link = GetAttachedItemLink(mailId, slot,LINK_STYLE_DEFAULT)
	local quality = GetItemLinkQuality(link)
	local control = GetControl("ZO_MailInboxMessageAttachmentsSlot" .. slot)
	self:AddIcon(control, quality)
end


function CBM:AddPopupMarker(popup)
	if not popup then d("ColorBlindMode: No Popup To Update") return end
	local link = popup.lastLink
	local quality = GetItemLinkQuality(link)
	self:AddIcon(popup, quality)
end

function CBM:AddIcon(control, quality)
	local item = control:GetNamedChild(CBM.name)
	if item then 
		item:SetHidden(true)
	else
		item = WINDOW_MANAGER:CreateControl(control:GetName() .. CBM.name, control, CT_TEXTURE)
		item:SetDimensions(12,12)
		item:SetDrawTier(DT_HIGH)
	end
	local anchor = control:GetNamedChild("Button")
	if anchor then
		anchor = anchor:GetNamedChild("Icon")
	else
		anchor = control:GetNamedChild("Icon")
	end
	item:SetTexture('/ColorBlindMode/img/c'..quality..'.dds')
	item:SetColor(1,1,1)
	item:ClearAnchors()
	item:SetAnchor(TOPLEFT, anchor, BOTTOMLEFT, 0, -12)
	item:SetHidden(false)
end


function CBM:AddMarker(control, link)
	if not control or not link then d("ColorBlindMode: No Control/Link") return end

	local quality

	if not control.dataEntry then
		if fromby == 'initEquipment' then
			local iLink = GetItemLink(0, control.slotIndex, LINK_STYLE_BRACKETS)
			quality = GetItemLinkQuality(iLink)
		end
	else
		quality = control.dataEntry.data.quality
		if not quality then
			quality=GetItemLinkQuality(GetItemLink(control.dataEntry.data.bag, control.dataEntry.data.index, LINK_STYLE_BRACKETS))
		end
	end

	self:AddIcon(control, quality)
end


EVENT_MANAGER:RegisterForEvent(CBM.name, EVENT_ADD_ON_LOADED, CBM.OnAddOnLoaded)
