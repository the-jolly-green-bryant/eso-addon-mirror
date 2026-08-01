-- Create namespace
DsRGuildBind = {}
local DsRGuildBind = DsRGuildBind or {}

DsRGuildBind.Binding = DsRGuildBind.Binding or {}
DsRGuildBind.Mark 	 = DsRGuildBind.Mark or {}
DsRGuildBind.Chat 	 = DsRGuildBind.Chat or {}
DsRGuildBind.Whisper = DsRGuildBind.Whisper or {}
DsRGuildBind.Post	 = DsRGuildBind.Post or {}

DsRGuildBind.name = "DsRGuildBind"

local postNumbers  = {}
local DsR_lootList = {}

-------------------------------------------------------------------------------------------------------------------------------------------------
-- BINDING
-------------------------------------------------------------------------------------------------------------------------------------------------
	DsRGuildBind.Binding.cumulativeBinding = {}
	-- DsRGuildBind.Binding.disabledBags = {
		-- [BAG_GUILDBANK] = true,
		-- [BAG_BUYBACK]   = true,
		-- [BAG_DELETE]    = true,
		-- [BAG_VIRTUAL]   = true,
	-- }

	local REQUEST_LINK_TYPE = "DsRreq"
	local requestLinks = {}
	local wantedItems  = {}

	-------------------------------------------------------------------------------------------------------------------------------------------------
	-- Bind all unknown
	-------------------------------------------------------------------------------------------------------------------------------------------------
	function DsRGuildBind.Binding.BindAllUnknown(bag)

		-- if bag == nil then bag = GetBankingBag() end
		if bag == nil then bag = BAG_BACKPACK end

		-- filter bags
		-- if DsRGuildBind.Binding.disabledBags[bag] ~= nil then bag = BAG_BACKPACK end

		-- also iterate the eso plus bank
		-- if bag == BAG_BANK and IsESOPlusSubscriber() == true then DsRGuildBind.Binding.BindAllUnknown(BAG_SUBSCRIBER_BANK) end

		local items = {}

		-- scan bag
		for slot = 0, GetBagSize(bag) - 1 do
			local itemLink = GetItemLink(bag, slot, LINK_STYLE_BRACKETS)
			if IsItemLinkSetCollectionPiece(itemLink) == true and IsItemSetCollectionPieceUnlocked(GetItemLinkItemId(itemLink)) == false then
				local itemName = GetItemLinkName(itemLink)
				if items[itemName] == nil then
					items[itemName] = {}
					items[itemName].link = itemLink
					items[itemName].slot = slot
				end
			end
		end

		-- bind items
		for item, info in pairs(items) do
			BindItem(bag, info.slot)
		end
	end

	-------------------------------------------------------------------------------------------------------------------------------------------------
	-- On Inventory Update
	-------------------------------------------------------------------------------------------------------------------------------------------------
	function DsRGuildBind.Binding.OnInventoryUpdate(_, bag, slot, isNew, _, updateReason, _)
		if DsRGuildBind.bind.autoBind == true then
			if DsRGuildBind.Binding.cumulativeBinding[bag] ~= true then
				DsRGuildBind.Binding.cumulativeBinding[bag] = true
				zo_callLater(function()
					DsRGuildBind.Binding.cumulativeBinding[bag] = nil
					DsRGuildBind.Binding.BindAllUnknown(bag)
				end, 2000)
			end
		end
	end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- MARK COLLECTION
-------------------------------------------------------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------------------------------------------------------
	-- OnSetCollectionUpdated
	-------------------------------------------------------------------------------------------------------------------------------------------------
	function DsRGuildBind.Mark.OnSetCollectionUpdated()
		ZO_ScrollList_RefreshVisible(ZO_PlayerInventoryList)
		ZO_ScrollList_RefreshVisible(ZO_PlayerBankBackpack)
		ZO_ScrollList_RefreshVisible(ZO_HouseBankBackpack)
		ZO_ScrollList_RefreshVisible(ZO_GuildBankBackpack)
		ZO_ScrollList_RefreshVisible(ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack)
		ZO_ScrollList_RefreshVisible(ZO_SmithingTopLevelImprovementPanelInventoryBackpack)
	end

	-------------------------------------------------------------------------------------------------------------------------------------------------
	-- ShouldShowIcon
	-------------------------------------------------------------------------------------------------------------------------------------------------
	function DsRGuildBind.Mark.ShouldShowIcon(itemLink)
		if (not IsItemLinkSetCollectionPiece(itemLink)) then
			return false
		end
		if (IsItemSetCollectionPieceUnlocked(GetItemLinkItemId(itemLink))) then
			return false
		end
		return true
	end
	
	-------------------------------------------------------------------------------------------------------------------------------------------------
	-- AddUncollectedIndicator
	-------------------------------------------------------------------------------------------------------------------------------------------------
	local function  DsRGuildBind_Mark_AddUncollectedIndicator(control, bagID, slotIndex, itemLink, show, offset)
		local uncollectedControl = control:GetNamedChild("UncollectedControl")
	
		local function DsRGuildBind_Mark_CreateUncollectedControl(parent)
			local control = WINDOW_MANAGER:CreateControl(parent:GetName() .. "UncollectedControl", parent, CT_TEXTURE)
			control:SetDrawTier(DT_HIGH)
			control:SetTexture("/" .. DsRGuildBind.Mark.iconTexture)
			return control
		end
	
		if (not uncollectedControl) then
			uncollectedControl = DsRGuildBind_Mark_CreateUncollectedControl(control)
		end
	
		if (not show or not DsRGuildBind.Mark.ShouldShowIcon(itemLink)) then
			uncollectedControl:SetHidden(true)
			return
		end
	
		local anchorControl = WINDOW_MANAGER:GetControlByName(control:GetName() .. 'Name')
		if (control.isGrid or (control:GetWidth() - control:GetHeight() < 5)) then
			uncollectedControl:SetAnchor(LEFT, control, BOTTOMLEFT, offset, -36/2)
		else
			local anchorControl = WINDOW_MANAGER:GetControlByName(control:GetName() .. 'Name')
			uncollectedControl:SetAnchor(LEFT, anchorControl, RIGHT, offset)
		end
	
		uncollectedControl:SetDimensions(36, 36)
		uncollectedControl:SetColor(unpack({0.9, 0.5, 0.4}))
		uncollectedControl:SetHidden(false)
	end

	-------------------------------------------------------------------------------------------------------------------------------------------------
	-- SetupBagHooks
	-------------------------------------------------------------------------------------------------------------------------------------------------
	local function DsRGuildBind_Mark_SetupBagHooks()
		for _, inventory in pairs(DsRGuildBind.Mark.inventories) do
			SecurePostHook(ZO_ScrollList_GetDataTypeTable(inventory.list, 1), "setupCallback", function(control, dataEntryData)
				local show = DsRGuildBind.bind.show[inventory.showKey]
				local itemLink = GetItemLink(control.dataEntry.data.bagId, control.dataEntry.data.slotIndex, LINK_STYLE_BRACKETS)
				DsRGuildBind_Mark_AddUncollectedIndicator(control, control.dataEntry.data.bagId, control.dataEntry.data.slotIndex,
					itemLink, show, DsRGuildBind.bind.iconOffset)
			end)
		end
	end
	
	-------------------------------------------------------------------------------------------------------------------------------------------------
	-- OnSetCollectionUpdated
	-------------------------------------------------------------------------------------------------------------------------------------------------
	local function DsRGuildBind_Mark_SetupGuildStoreHooks()
		ZO_PreHook(TRADING_HOUSE.searchResultsList.dataTypes[1], "setupCallback", function(...)
			local show = DsRGuildBind.bind.show["guildstore"]
			local control, data = ...
			if (control.slotControlType and control.slotControlType == 'listSlot' and data.slotIndex) then
				local itemLink = GetTradingHouseSearchResultItemLink(data.slotIndex, LINK_STYLE_BRACKETS)
				DsRGuildBind_Mark_AddUncollectedIndicator(control, nil, nil, itemLink, show,  DsRGuildBind.bind.iconStoreOffset)
			end
		end)
		ZO_PreHook(TRADING_HOUSE.postedItemsList.dataTypes[2], "setupCallback", function(...)
			local show = DsRGuildBind.bind.show["guildstore"]
			local control, data = ...
			if (control.slotControlType and control.slotControlType == 'listSlot' and data.slotIndex) then
				local itemLink = GetTradingHouseListingItemLink(data.slotIndex, LINK_STYLE_BRACKETS)
				DsRGuildBind_Mark_AddUncollectedIndicator(control, nil, nil, itemLink, show,  DsRGuildBind.bind.iconStoreOffset)
			end
		end)
	
		ZO_ScrollList_RefreshVisible(ZO_TradingHouseBrowseItemsRightPaneSearchResults)
	end
	
	-------------------------------------------------------------------------------------------------------------------------------------------------
	-- HookBuyback
	-------------------------------------------------------------------------------------------------------------------------------------------------
	local function DsRGuildBind_Mark_HookBuyback()
		ZO_PreHook(ZO_BuyBackList.dataTypes[1], "setupCallback", function( ... )
			local control, data = ...
			if (control.slotControlType and control.slotControlType == 'listSlot' and data.slotIndex) then
				local itemLink = GetBuybackItemLink(data.slotIndex, LINK_STYLE_BRACKETS)
				local show = DsRGuildBind.bind.show["bag"]
				DsRGuildBind_Mark_AddUncollectedIndicator(control, nil, nil, itemLink, show, DsRGuildBind.bind.iconOffset)
			end
		end)
	end
	
	-------------------------------------------------------------------------------------------------------------------------------------------------
	-- ParseItemLinks
	-------------------------------------------------------------------------------------------------------------------------------------------------
	local function DsRGuildBind_Mark_ParseItemLinks(message, location, fromDisplayName, messageType)
		if (not message) then
			return nil, nil
		end
	
		local itemsString = ""
		local withIcons = {}
		local count = 0
	
		for itemLink in string.gmatch(message, "(|H%d:item:.-|h|h)") do
			if (DsRGuildBind.Mark.ShouldShowIcon(itemLink)) then
				withIcons[itemLink] = DsRGuildBind.Chat.iconString .. itemLink
				itemsString = itemsString .. itemLink
				count = count + 1
			end
		end
	
		if (count == 0) then
			return message, nil
		end
	
		local requestKey
		if (fromDisplayName and fromDisplayName ~= GetUnitDisplayName("player") and messageType ~= CHAT_CHANNEL_WHISPER_SENT) then
			requestKey = #requestLinks + 1
			requestLinks[requestKey] = {name = fromDisplayName, items = itemsString, channel = messageType}
		end
	
		-- return DsRGuildBind.Chat.iconString .. message, requestKey
	
		for link, withIcon in pairs(withIcons) do
			message = string.gsub(message, link, withIcon)
		end
		return message, requestKey
	end
	
	-------------------------------------------------------------------------------------------------------------------------------------------------
	-- OnLinkClicked
	-------------------------------------------------------------------------------------------------------------------------------------------------
	local function DsRGuildBind_Mark_OnLinkClicked(_, _, _, _, linkType, requestKey)
		if (linkType == REQUEST_LINK_TYPE) then
			local requestData = requestLinks[tonumber(requestKey)]
			if (DsRGuildBind.bind.requestInWhisper or requestData.channel == CHAT_CHANNEL_WHISPER) then
				StartChatInput(DsRGuildBind.bind.requestPrefix .. requestData.items, CHAT_CHANNEL_WHISPER, requestData.name)
			else
				StartChatInput(DsRGuildBind.bind.requestPrefix .. requestData.items, requestData.channel)
			end
			return true
		end
	end
	
	-------------------------------------------------------------------------------------------------------------------------------------------------
	-- SetupChatHooks
	-------------------------------------------------------------------------------------------------------------------------------------------------
	local function DsRGuildBind_Mark_SetupChatHooks()
		local function DsRGuildBind_Mark_AddIconToSystem(origMessage)
			if (not DsRGuildBind.bind.chatSystemShow) then
				return origMessage
			end
			return DsRGuildBind_Mark_ParseItemLinks(origMessage, "Beginning")
		end
		local previousFormatter = CHAT_ROUTER:GetRegisteredMessageFormatters()["AddSystemMessage"]
		if (previousFormatter) then
			CHAT_ROUTER:RegisterMessageFormatter("AddSystemMessage", function(...)
				return DsRGuildBind_Mark_AddIconToSystem(previousFormatter(...))
			end)
		else
			CHAT_ROUTER:RegisterMessageFormatter("AddSystemMessage", DsRGuildBind_Mark_AddIconToSystem)
		end
	
		local function DsRGuildBind_Mark_AddIconToMessage(messageType, fromName, text, isFromCustomerService, fromDisplayName)
			local formattedText = text
			if (DsRGuildBind.bind.chatMessageShow) then
				formattedText, requestKey = DsRGuildBind_Mark_ParseItemLinks(text, "Before", fromDisplayName, messageType)
			end
			if (requestKey and DsRGuildBind.bind.showRequestLink) then
				-- Add a [Req] button if there are items we need
				formattedText = string.format("|cb81414|H0:%s:%d|h[Req]|h|r%s", REQUEST_LINK_TYPE, requestKey, formattedText)
			end
	
			local channelInfo = ZO_ChatSystem_GetChannelInfo()[messageType]
			if (not channelInfo or not channelInfo.format) then
				return
			end
	
			return formattedText, channelInfo.saveTarget
		end
		local oldFormatter = CHAT_ROUTER:GetRegisteredMessageFormatters()[EVENT_CHAT_MESSAGE_CHANNEL]
		if (oldFormatter) then
			CHAT_ROUTER:RegisterMessageFormatter(EVENT_CHAT_MESSAGE_CHANNEL, function(messageType, fromName, text, isFromCustomerService, fromDisplayName)
				local oldText = oldFormatter(messageType, fromName, text, isFromCustomerService, fromDisplayName)
				return DsRGuildBind_Mark_AddIconToMessage(messageType, fromName, oldText, isFromCustomerService, fromDisplayName)
			end)
		else
			CHAT_ROUTER:RegisterMessageFormatter(EVENT_CHAT_MESSAGE_CHANNEL, DsRGuildBind_Mark_AddIconToMessage)
		end
		LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, DsRGuildBind_Mark_OnLinkClicked)
	
		EVENT_MANAGER:UnregisterForEvent(DsRGuildBind.name .. "Activated", EVENT_PLAYER_ACTIVATED)
	end

	-------------------------------------------------------------------------------------------------------------------------------------------------
	-- OnPlayerActivated
	-------------------------------------------------------------------------------------------------------------------------------------------------
	function DsRGuildBind.Chat.OnPlayerActivated()
		if (pChat or rChat) then
			EVENT_MANAGER:RegisterForUpdate(DsRGuildBind.name .. "DelayedActivated", 500,
				function()
					EVENT_MANAGER:UnregisterForUpdate(DsRGuildBind.name .. "DelayedActivated")
					DsRGuildBind_Mark_SetupChatHooks()
				end)
		else
			DsRGuildBind_Mark_SetupChatHooks()
		end
	end

	-------------------------------------------------------------------------------------------------------------------------------------------------
	-- GetRecipientWantedItems
	-------------------------------------------------------------------------------------------------------------------------------------------------
	local function DsRGuildBind_Mark_GetRecipientWantedItems(name)
		local data = wantedItems[name]
		if (not data) then return end
	
		local age = GetGameTimeSeconds() - data.timeWhispered
		if (age > 360) then
			wantedItems[name] = nil
			return
		end
	
		local itemCount = 0
		for _, _ in pairs(data.items) do
			return data.items
		end
	
		wantedItems[name] = nil
		return
	end
	
	-------------------------------------------------------------------------------------------------------------------------------------------------
	-- GetMatchingItems
	-------------------------------------------------------------------------------------------------------------------------------------------------
	local function DsRGuildBind_Mark_GetMatchingItems(name, allowBoP)
		local wanted      = DsRGuildBind_Mark_GetRecipientWantedItems(name)
		local resultItems = ""
		if (not wanted) then
			return {}, ""
		end
	
		local matches = {}
		local bagCache = SHARED_INVENTORY:GetOrCreateBagCache(BAG_BACKPACK)
		for _, item in pairs(bagCache) do
			local itemLink = GetItemLink(item.bagId, item.slotIndex, LINK_STYLE_BRACKETS)
			local itemId = GetItemLinkItemId(itemLink)
			if (wanted[itemId]) then
				if (IsItemBound(item.bagId, item.slotIndex)) then
					resultItems = string.format("%s\n%s (Bound)", resultItems, itemLink)
				elseif (IsItemPlayerLocked(item.bagId, item.slotIndex)) then
					resultItems = string.format("%s\n%s (Locked)", resultItems, itemLink)
				elseif (IsItemBoPAndTradeable(item.bagId, item.slotIndex)) then
					if (not allowBoP) then
						resultItems = string.format("%s\n%s (BoP)", resultItems, itemLink)
					else
						if (not IsDisplayNameInItemBoPAccountTable(item.bagId, item.slotIndex, string.gsub(name, "@", ""))) then
							resultItems = string.format("%s\n%s (BoP untradeable)", resultItems, itemLink)
						else
							resultItems = string.format("%s\n%s", resultItems, itemLink)
							table.insert(matches, item.slotIndex)
						end
					end
				else
					resultItems = string.format("%s\n%s", resultItems, itemLink)
					table.insert(matches, item.slotIndex)
				end
			end
		end
		return matches, resultItems
	end

	DsRGuildBind.Whisper.DsRGuildBind_Mark_GetMatchingItems = DsRGuildBind_Mark_GetMatchingItems
	-------------------------------------------------------------------------------------------------------------------------------------------------
	-- OnWhisper
	-------------------------------------------------------------------------------------------------------------------------------------------------
	local function DsRGuildBind_Whisper_OnWhisper(_, channelType, fromName, text, _, fromDisplayName)
		if (channelType ~= CHAT_CHANNEL_WHISPER) then return end
	
		local name
		if (fromDisplayName and not wantedItems[fromName]) then
			name = fromDisplayName
		else
			name = fromName
		end

		local data = wantedItems[name] or {}
		local items = data.items or {}
	
		for itemLink in string.gmatch(text, "(|H%d:item:.-|h|h)") do
			if (IsItemLinkSetCollectionPiece(itemLink)) then
				local id    = GetItemLinkItemId(itemLink)
				local trait = GetItemLinkTraitType(itemLink)
				items[id]   = trait
			end
		end
		data.items = items
		data.timeWhispered = GetGameTimeSeconds()
		wantedItems[name]  = data
	end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- POST UNBOUNTED 
-------------------------------------------------------------------------------------------------------------------------------------------------
	local function DsRGuildBind_Post_GetItemUniqueIdString( ... )
		id = GetItemUniqueId(...)
		if (id) then
			return Id64ToString(id)
		end
		return nil
	end
	
	local function DsRGuildBind_Post_IsInGroupedInstance( )
		return IsUnitGrouped("player") and GetCurrentZoneDungeonDifficulty() ~= DUNGEON_DIFFICULTY_NONE
	end
	
	local function DsRGuildBind_Post_IsItemBoPAndTradeableForCurrentGroup( bagId, slotIndex )
		if (IsItemBoPAndTradeable(bagId, slotIndex)) then
			if (not DsRGuildBind_Post_IsInGroupedInstance()) then return true end
	
			for i = 1, GetGroupSize() do
				local unitTag = GetGroupUnitTagByIndex(i)
				if (not AreUnitsEqual("player", unitTag) and IsUnitOnline(unitTag) and IsDisplayNameInItemBoPAccountTable(bagId, slotIndex, UndecorateDisplayName(GetUnitDisplayName(unitTag)))) then
					return true
				end
			end
		end
	
		return false
	end
	
	local DsRLinkTradeFilters = {
		def = function(item) return DsRGuildBind_Post_IsItemBoPAndTradeableForCurrentGroup(item.bagId, item.slotIndex) or (GetItemBindType(item.bagId, item.slotIndex) == BIND_TYPE_ON_EQUIP) end,
		boe = function(item) return GetItemBindType(item.bagId, item.slotIndex) == BIND_TYPE_ON_EQUIP end,
		bop = function(item) return DsRGuildBind_Post_IsItemBoPAndTradeableForCurrentGroup(item.bagId, item.slotIndex) end,
		wep = function(item) return DsRGuildBind_Post_IsItemBoPAndTradeableForCurrentGroup(item.bagId, item.slotIndex) and GetItemType(item.bagId, item.slotIndex) == ITEMTYPE_WEAPON end,
		all = function(item) return true end,
	}
	
	function DsRGuildBind.Post.PostAllUnbounted( ... )
		local CHAT_MAX_CHARS = 350 - 12

		local filter = DsRLinkTradeFilters.def
	
		local ItemProcessed = { }
		local LastLinked    = { }

		--------
		-- Find and count all tradeable items
		--------

		local items  = { }
		DsR_lootList = {}
		postNumbers  = {}
	
		local bagCache = SHARED_INVENTORY:GetOrCreateBagCache(BAG_BACKPACK)
		for _, item in pairs(bagCache) do
			local itemLink = GetItemLink(item.bagId, item.slotIndex, LINK_STYLE_BRACKETS)
	
			if (not IsItemPlayerLocked(item.bagId, item.slotIndex) and not IsItemStolen(item.bagId, item.slotIndex) and not IsItemLinkBound(itemLink) and filter(item) and IsItemLinkSetCollectionPiece(itemLink)) then
				local setId = select(6, GetItemLinkSetInfo(itemLink))
				local slot  = GetItemLinkItemSetCollectionSlot(itemLink)
				local key   = string.format("%d:%s", setId, Id64ToString(slot))
	
				if (not items[key]) then
					items[key] = {
						link = itemLink,
						count = (IsItemSetCollectionSlotUnlocked(setId, slot)) and 1 or 0,
					}
				else
					items[key].count = items[key].count + 1
				end
	
				local id = DsRGuildBind_Post_GetItemUniqueIdString(item.bagId, item.slotIndex)
				if (id and not ItemProcessed[id]) then
					ItemProcessed[id] = true
					if (LastLinked[key] and LastLinked[key] > 0) then
						LastLinked[key] = 0
						items[key].link = itemLink
					end
				end
			end
		end
	
		--------
		-- Build list of links
		--------
	
		local results = { }
	
		for key, item in pairs(items) do
			if (not LastLinked[key]) then LastLinked[key] = 0 end
	
			if (items[key].count > 0) then
				local result 	= (items[key].count == 1) and items[key].link or string.format("%d×%s", items[key].count, items[key].link)
				table.insert(results, result)
				LastLinked[key] = time
			end
		end
	
		--------
		-- Output
		--------
		if (#results > 0) then
			local CreateString = zo_strformat(results[1]) .. " " .. zo_strformat(results[2]) .. " " .. zo_strformat(results[3]) .. " " .. zo_strformat(results[4])
			-- StartChatInput(CreateString)

			local channel    = string.format("%s", "/party")
			local outputtext = string.format("%s", CreateString)
			CHAT_SYSTEM:Maximize()
			CHAT_SYSTEM.textEntry:InsertLink( channel )
			CHAT_SYSTEM.textEntry:InsertLink( " " .. outputtext )
			CHAT_SYSTEM.textEntry:Open() CHAT_SYSTEM.textEntry:FadeIn()
	
			local function OutputNextLine(eventCode, channelType, fromName, text, isCustomerService, fromDisplayName)
				table.remove(results, 1)
				table.remove(results, 1)
				table.remove(results, 1)
				table.remove(results, 1)

				if #results>0 then
					local CreateString = zo_strformat(results[1]) .. " " .. zo_strformat(results[2]) .. " " .. zo_strformat(results[3]) .. " " .. zo_strformat(results[4])
					-- StartChatInput(CreateString)

					local channel    = string.format("%s", "/party")
					local outputtext = string.format("%s", CreateString)
					CHAT_SYSTEM:Maximize()
					CHAT_SYSTEM.textEntry:InsertLink( channel )
					CHAT_SYSTEM.textEntry:InsertLink( " " .. outputtext )
					CHAT_SYSTEM.textEntry:Open() CHAT_SYSTEM.textEntry:FadeIn()
				else
					EVENT_MANAGER:UnregisterForEvent(DsRGuildBind.name.."_ChatListener", EVENT_CHAT_MESSAGE_CHANNEL)
				end
			end
			EVENT_MANAGER:UnregisterForEvent(DsRGuildBind.name.."_ChatListener", EVENT_CHAT_MESSAGE_CHANNEL)
			EVENT_MANAGER:RegisterForEvent(DsRGuildBind.name.."_ChatListener", EVENT_CHAT_MESSAGE_CHANNEL, OutputNextLine)
		end
	end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- On addon loaded
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildBind.OnAddOnLoaded(event, name)
	-- BINDING
	EVENT_MANAGER:RegisterForEvent(DsRGuildBind.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, DsRGuildBind.Binding.OnInventoryUpdate)
	EVENT_MANAGER:AddFilterForEvent(DsRGuildBind.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_IS_NEW_ITEM, true)
	EVENT_MANAGER:AddFilterForEvent(DsRGuildBind.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK)

	-- MARK COLLECTION
	EVENT_MANAGER:RegisterForEvent(DsRGuildBind.name .. "CollectionUpdate", EVENT_ITEM_SET_COLLECTION_UPDATED, DsRGuildBind.Mark.OnSetCollectionUpdated)
	EVENT_MANAGER:RegisterForEvent(DsRGuildBind.name .. "StoreSearch", EVENT_TRADING_HOUSE_RESPONSE_RECEIVED, DsRGuildBind_Mark_SetupGuildStoreHooks)
	EVENT_MANAGER:RegisterForEvent(DsRGuildBind.name .. "Buyback", EVENT_OPEN_STORE, DsRGuildBind_Mark_HookBuyback)
	
	EVENT_MANAGER:RegisterForEvent(DsRGuildBind.name .. "Whisper", EVENT_CHAT_MESSAGE_CHANNEL, DsRGuildBind_Whisper_OnWhisper)

	DsRGuildBind.Mark.inventories = {
		bag = {
			list = ZO_PlayerInventoryList,
			showKey = "bag",
		},
		bank = {
			list = ZO_PlayerBankBackpack,
			showKey = "bank",
		},
		housebank = {
			list = ZO_HouseBankBackpack,
			showKey = "housebank",
		},
		guild = {
			list = ZO_GuildBankBackpack,
			showKey = "guild",
		},
		deconstruction = {
			list = ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack,
			showKey = "crafting",
		},
		improvement = {
			list = ZO_SmithingTopLevelImprovementPanelInventoryBackpack,
			showKey = "crafting",
		},
		deconassistant = {
			list = ZO_UniversalDeconstructionTopLevel_KeyboardPanelInventoryBackpack,
			showKey = "crafting",
		},
		transmute = {
			list = ZO_RETRAIT_KEYBOARD.inventory.list,
			showKey = "transmute",
		},
	}

	DsRGuildBind.Mark.iconTexture = "/esoui/art/collections/collections_tabicon_itemsets_down.dds"
	DsRGuildBind.Chat.iconString  = string.format("|cb81414|t24:24:%s:inheritcolor|t|r", DsRGuildBind.Mark.iconTexture )

	DsRGuildBind_Mark_SetupBagHooks()

	EVENT_MANAGER:RegisterForEvent(DsRGuildBind.name .. "Activated", EVENT_PLAYER_ACTIVATED, DsRGuildBind.Chat.OnPlayerActivated)
end
