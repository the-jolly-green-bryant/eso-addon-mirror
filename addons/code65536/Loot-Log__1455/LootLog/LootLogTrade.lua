local LCCC = LibCodesCommonCode
local LRM = LibRadialMenu
local LootLog = LootLog
local LootLogMulti = LootLog.modules.multi
local LootLogTrade = LootLog.modules.trade


LootLogTrade.name = "LootLogTrade"

ZO_CreateStringId("SI_BINDING_NAME_LOOTLOG_LINKTRADE", string.format("%s: %s", GetString(SI_LOOTLOG_TITLE), GetString(SI_LOOTLOG_LINKTRADE)))
ZO_CreateStringId("SI_BINDING_NAME_LOOTLOG_BINDUNCOLLECTED", string.format("%s: %s", GetString(SI_LOOTLOG_TITLE), GetString(SI_LOOTLOG_BINDUNCOLLECTED)))

local AutoBinder

LCCC.RunAfterInitialLoadscreen(function( )
	LCCC.RegisterSlashCommands(LootLogTrade.LinkTrade, "/linktrade", "/lt")
	LCCC.RegisterSlashCommands(LootLogTrade.BindUncollected, "/binduncollected", "/bu")

	if (LRM) then
		LRM:RegisterAddon(LootLog.name, LootLog.title)
		LRM:RegisterEntry(LootLog.name, GetString(SI_LOOTLOG_LINKTRADE), "LL_LT", "LootLog/art/uncollected-1.dds", LootLogTrade.LinkTrade, "")
		LRM:RegisterEntry(LootLog.name, GetString(SI_LOOTLOG_BINDUNCOLLECTED), "LL_BU", "LootLog/art/uncollected.dds", LootLogTrade.BindUncollected, "")
	end

	if (LootLog.vars.tradeFlagChat) then
		zo_callLater(LootLogTrade.HookIncomingChat, 750)
	end

	AutoBinder.Refresh()
end)

function LootLogTrade.CheckFlagHooks( )
	if (LootLog.vars.tradeFlagItemLists) then
		LootLogTrade.HookLists()
		LootLogTrade.HookHistory()
		if (LootLog.vars.tradeFlagHideVanilla) then
			LootLogTrade.HookVanillaIndicator()
		end
	end
end


--------------------------------------------------------------------------------
-- Flag uncollected items in item lists (e.g., inventory)
--------------------------------------------------------------------------------

local IndicatorName = "UncollectedIndicator"

local function FlagListItem( link, checkInventory, control, context )
	if (context ~= LootLogMulti.CONTEXT_MAIL_ATTACHMENT) then
		-- We're only interested in the icon button subcontrol, not the inventory slot control
		-- /esoui/ingame/inventory/inventoryslot.xml
		control = control:GetNamedChild("Button")
	end
	if (not control) then return end

	-- Different systems have different ways of passing the item link
	local itemLink
	if (type(link) == "string") then
		-- Trade slots
		itemLink = link
	elseif (type(link) == "table") then
		-- Vendors and loot windows
		itemLink = link[1](context[link[2]])
	else
		-- Bags/banks
		itemLink = GetItemLink(context.bagId, context.slotIndex)
	end

	local isUncollected, uncollectedColor, uncollectedIcon
	if (LootLog.vars.tradeFlagItemLists) then
		isUncollected, uncollectedColor, uncollectedIcon = LootLogMulti.ShouldFlagAsUncollected(itemLink, context, checkInventory)
	end

	-- Get or create our indicator
	local indicator = control:GetNamedChild(IndicatorName)
	if (not indicator) then
		-- Be lazy; don't create an indicator unless we actually need to show it
		if (not isUncollected) then return end

		-- Create and initialize the indicator
		indicator = WINDOW_MANAGER:CreateControl(control:GetName() .. IndicatorName, control, CT_TEXTURE)
		indicator:SetDimensions(22, 22)
		indicator:SetInheritScale(false)
		indicator:SetAnchor(TOPRIGHT)
		indicator:SetDrawTier(DT_HIGH)
	end

	if (isUncollected) then
		indicator:SetTexture(uncollectedIcon)
		indicator:SetColor(LCCC.Int24ToRGBA(uncollectedColor))
		indicator:SetHidden(false)
	else
		indicator:SetHidden(true)
	end
end

local ListsToRefresh = { }
local AreListsHooked = false

function LootLogTrade.HookLists( )
	if (AreListsHooked) then return end
	AreListsHooked = true

	local ProcessListHooks = function( lists )
		for _, list in ipairs(lists) do
			local scrollList = _G[list.name]
			if (scrollList and ZO_ScrollList_GetDataTypeTable(scrollList, 1)) then
				SecurePostHook(ZO_ScrollList_GetDataTypeTable(scrollList, 1), "setupCallback", function(...) FlagListItem(list.link, list.checkInv, ...) end)
				if (not list.noRefresh) then
					table.insert(ListsToRefresh, scrollList)
				end
			end
		end
	end

	--------
	-- Hook regular item lists
	--------

	ProcessListHooks({
		{ name = "ZO_PlayerInventoryList" },
		{ name = "ZO_PlayerBankBackpack" },
		{ name = "ZO_GuildBankBackpack" },
		{ name = "ZO_HouseBankBackpack" },
		{ name = "ZO_SmithingTopLevelImprovementPanelInventoryBackpack" },
		{ name = "ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack" },
		{ name = "ZO_UniversalDeconstructionTopLevel_KeyboardPanelInventoryBackpack" },
		{ name = "ZO_StoreWindowList", link = { GetStoreItemLink, "slotIndex" }, checkInv = true },
		{ name = "ZO_BuyBackList", link = { GetBuybackItemLink, "slotIndex" }, noRefresh = true },
		{ name = "ZO_LootAlphaContainerList", link = { GetLootItemLink, "lootId" }, checkInv = true, noRefresh = true },
	})

	--------
	-- The guild store can't be hooked until it has been opened at least once
	--------

	do
		local hooked = false
		SecurePostHook(TRADING_HOUSE, "OpenTradingHouse", function( )
			if (not hooked) then
				hooked = true
				ProcessListHooks({
					{ name = "ZO_TradingHouseBrowseItemsRightPaneSearchResults", link = { GetTradingHouseSearchResultItemLink, "slotIndex" }, checkInv = true, noRefresh = true },
				})
			end
		end)
	end

	--------
	-- Trade window slots are not technically item lists, but they reuse the same inventory slot control
	-- /esoui/ingame/tradewindow/keyboard/tradewindow_keyboard.lua
	--------

	SecurePostHook(TRADE, "InitializeSlot", function( self, who, index, ... )
		FlagListItem(GetTradeItemLink(who, index), who == TRADE_THEM, self.Columns[who][index].Control, { who = who, tradeIndex = index })
	end)

	SecurePostHook(TRADE, "ResetSlot", function( self, who, index )
		FlagListItem("", false, self.Columns[who][index].Control)
	end)

	--------
	-- Mail attachment slots are not technically item lists, but they reuse the same inventory slot control
	-- /esoui/ingame/mail/keyboard/mail*_keyboard.lua
	--------

	SecurePostHook(MAIL_INBOX, "RefreshAttachmentSlots", function( self )
		local numAttachments = self:GetMailData(self.mailId, self.isMailFromGuild).numAttachments
		for i = 1, numAttachments do
			FlagListItem(GetAttachedItemLink(self.mailId, i), true, self.attachmentSlots[i], LootLogMulti.CONTEXT_MAIL_ATTACHMENT)
		end
	end)

	SecurePostHook(MAIL_SEND, "OnMailAttachmentAdded", function( self, attachSlot )
		FlagListItem(GetMailQueuedAttachmentLink(attachSlot), false, self.attachmentSlots[attachSlot], LootLogMulti.CONTEXT_MAIL_ATTACHMENT)
	end)

	SecurePostHook(MAIL_SEND, "OnMailAttachmentRemoved", function( self, attachSlot )
		FlagListItem("", false, self.attachmentSlots[attachSlot], LootLogMulti.CONTEXT_MAIL_ATTACHMENT)
	end)

	--------
	-- Visually refresh item lists when collections are updated
	--------

	EVENT_MANAGER:RegisterForEvent(LootLogTrade.name, EVENT_ITEM_SET_COLLECTIONS_UPDATED, LootLogTrade.RefreshCollections)
	EVENT_MANAGER:RegisterForEvent(LootLogTrade.name, EVENT_ITEM_SET_COLLECTION_UPDATED, LootLogTrade.RefreshCollections)
	EVENT_MANAGER:RegisterForEvent(LootLogTrade.name, EVENT_COLLECTIBLES_UNLOCK_STATE_CHANGED, LootLogTrade.RefreshCollections)

	if (LibCharacterKnowledge) then
		LibCharacterKnowledge.RegisterForCallback(LootLogTrade.name, LibCharacterKnowledge.EVENT_UPDATE_REFRESH, LootLogTrade.RefreshCollections)
	end
end

function LootLogTrade.RefreshCollections( )
	-- This 0.1s delay allows us to coalesce multiple updates into a single
	-- refresh, in the event multiple items are collected at once
	EVENT_MANAGER:UnregisterForUpdate(LootLogTrade.name)
	EVENT_MANAGER:RegisterForUpdate(
		LootLogTrade.name,
		100,
		function( )
			for _, scrollList in ipairs(ListsToRefresh) do
				ZO_ScrollList_RefreshVisible(scrollList)
			end
		end,
		true
	)
end


--------------------------------------------------------------------------------
-- Flag uncollected items in loot history popup
--------------------------------------------------------------------------------

local IsHistoryHooked = false

function LootLogTrade.HookHistory( )
	if (IsHistoryHooked) then return end
	IsHistoryHooked = true

	ZO_PreHook(ZO_LootHistory_Shared, "CreateLootEntry", function( self, lootData )
		if (LootLog.vars.tradeFlagItemLists and lootData.itemId and not lootData.isCraftBagItem) then
			local bagCache = SHARED_INVENTORY:GetOrCreateBagCache(BAG_BACKPACK)
			for _, data in pairs(bagCache) do
				if (GetItemInstanceId(data.bagId, data.slotIndex) == lootData.itemId) then
					local itemLink = GetItemLink(data.bagId, data.slotIndex)
					local isUncollected, uncollectedColor, uncollectedIcon = LootLogMulti.ShouldFlagAsUncollected(itemLink, true)
					if (isUncollected) then
						lootData.statusIcon = uncollectedIcon
						lootData.statusIconColor = ZO_ColorDef:New(LCCC.Int24ToRGBA(uncollectedColor))
						lootData.highlight = lootData.highlight or self:GetCanLearnHighlight()
					elseif (lootData.statusIcon == self:GetLockedSetPieceIcon() or (LootLogMulti.CanUseLCK() and lootData.statusIcon == self:GetCanLearnIcon() and IsItemLinkConsumable(itemLink))) then
						lootData.statusIcon = nil
						lootData.statusIconColor = nil
						lootData.highlight = nil
					end
					return false
				end
			end
		end
		return false
	end)
end


--------------------------------------------------------------------------------
-- Hiding vanilla indicators
--------------------------------------------------------------------------------

local IsVanillaIndicatorHooked = false

function LootLogTrade.HookVanillaIndicator( )
	if (IsVanillaIndicatorHooked) then return end
	IsVanillaIndicatorHooked = true

	local HookHandler = function( data )
		if (type(data) == "table" and LootLog.vars.tradeFlagItemLists and LootLog.vars.tradeFlagHideVanilla) then
			if (data.canBeUsedToLearn and IsItemLinkConsumable(data.bagId and GetItemLink(data.bagId, data.slotIndex) or GetLootItemLink(data.lootId))) then
				data.canBeUsedToLearn = false
			end
			data.isLockedSetPiece = false
		end
		return false
	end

	-- /esoui/ingame/inventory/sharedinventory.lua
	ZO_PreHook(MasterMerchant and ZO_SharedInventoryManager or SHARED_INVENTORY, "RefreshStatusSortOrder", function(_, slotData) return HookHandler(slotData) end)

	-- /esoui/ingame/zo_loot/loot.lua
	ZO_PreHook(LOOT_WINDOW, "SetUpLootItem", function(_, _, data) return HookHandler(data) end)
end


--------------------------------------------------------------------------------
-- Flag uncollected items in incoming chat messages
--------------------------------------------------------------------------------

local function FlagUncollectedLink( previous, itemLink )
	local isUncollected, uncollectedColor, uncollectedIcon = LootLogMulti.ShouldFlagAsUncollected(itemLink, LootLogMulti.CONTEXT_INCOMING_CHAT, true)
	if (isUncollected) then
		-- Save this link for requests
		if (LootLog.vars.tradeRequestMode > 0) then
			table.insert(LootLogTrade.flagged, itemLink)
		end

		-- Add additional spacing if this link immediately follows another link
		if (previous == "") then previous = "  " end

		return string.format(
			"%s|c%06X%s|r%s",
			previous,
			uncollectedColor,
			zo_iconFormatInheritColor(uncollectedIcon, 22, 22),
			itemLink
		)
	else
		return previous .. itemLink
	end
end

local SavedMessages = { }
local IsChatHooked = false

function LootLogTrade.HookIncomingChat( )
	if (IsChatHooked) then return end
	IsChatHooked = true

	-- The formatter for EVENT_CHAT_MESSAGE_CHANNEL is built-in and should always exist
	local existingFunction = CHAT_ROUTER:GetRegisteredMessageFormatters()[EVENT_CHAT_MESSAGE_CHANNEL]
	if (not existingFunction) then return end

	-- channelType, fromName, text, isCustomerService, fromDisplayName
	CHAT_ROUTER:RegisterMessageFormatter(EVENT_CHAT_MESSAGE_CHANNEL, function( ... )
		local fromDisplayName = select(5, ...) or ""
		if (LootLog.vars.tradeFlagChat and select(1, ...) ~= CHAT_CHANNEL_WHISPER_SENT and fromDisplayName ~= LootLog.self.userId) then
			local results = { existingFunction(...) }

			if (type(results[1]) == "string") then
				LootLogTrade.flagged = { }

				-- Flag uncollected links
				results[1] = string.gsub(results[1], "(.?)(|H%d:item:[%w:]+|h|h)", FlagUncollectedLink)

				-- Append request link if we found any uncollected links in this message
				if (#LootLogTrade.flagged > 0) then
					table.insert(LootLogTrade.flagged, 1, fromDisplayName)
					local key = tostring(HashString(table.concat(LootLogTrade.flagged, "")))
					SavedMessages[key] = LootLogTrade.flagged

					local requestLink = string.format(
						"|c%06X|H0:lltrade:%s|h[%s]|h|r",
						LCCC.RGBToInt24(GetChatCategoryColor(CHAT_CATEGORY_SYSTEM)),
						key,
						(LootLog.vars.tradeRequestMode == 1) and "++" or GetString(SI_LOOTLOG_TRADE_REQUEST)
					)

					if (LootLog.vars.tradeRequestMode == 1) then
						results[1] = string.format("%s %s", requestLink, results[1])
					else
						results[1] = string.format("%s  %s", results[1], requestLink)
					end
				end
			end

			return unpack(results)
		else
			-- Straight passthrough if disabled or for outgoing messages
			return existingFunction(...)
		end
	end)

	-- Register handler for our custom request link
	LCCC.RegisterLinkHandler("lltrade", function( key )
		if (SavedMessages[key]) then
			StartChatInput(string.format("%s %s", LootLog.vars.tradeRequestPrefix, table.concat(SavedMessages[key], "", 2)), CHAT_CHANNEL_WHISPER, SavedMessages[key][1])
		end
	end)
end


--------------------------------------------------------------------------------
-- Link tradeable set items in chat
--------------------------------------------------------------------------------

local CHAT_MAX_CHARS = 350 - 12 -- Number of characters that can be fit into the chat box (plus a small margin)
local RELINK_COOLDOWN = 3600 -- 60 minutes

local ItemProcessed = { }
local LastLinked = { }
local LinkTradeWatcher

local function GetItemUniqueIdString( ... )
	local id = GetItemUniqueId(...)
	return id and Id64ToString(id) or nil
end

local function IsInGroupedInstance( )
	return IsUnitGrouped("player") and LCCC.IsInDungeonTrialArena()
end

local function IsItemBoPAndTradeableForCurrentGroup( bagId, slotIndex )
	if (IsItemBoPAndTradeable(bagId, slotIndex)) then
		-- Bypass the check if the player is not currently grouped inside an instance
		if (not IsInGroupedInstance()) then return true end

		-- Pass if at least one group member is eligible for the item
		for i = 1, GetGroupSize() do
			local unitTag = GetGroupUnitTagByIndex(i)
			if (not AreUnitsEqual("player", unitTag) and IsUnitOnline(unitTag) and IsDisplayNameInItemBoPAccountTable(bagId, slotIndex, UndecorateDisplayName(GetUnitDisplayName(unitTag)))) then
				return true
			end
		end
	end

	return false
end

local LinkTradeFilters = {
	def = function(item) return IsItemBoPAndTradeableForCurrentGroup(item.bagId, item.slotIndex) or (LootLog.vars.tradeIncludeBoE and GetItemBindType(item.bagId, item.slotIndex) == BIND_TYPE_ON_EQUIP) end,
	boe = function(item) return GetItemBindType(item.bagId, item.slotIndex) == BIND_TYPE_ON_EQUIP end,
	bop = function(item) return IsItemBoPAndTradeableForCurrentGroup(item.bagId, item.slotIndex) end,
	wep = function(item) return IsItemBoPAndTradeableForCurrentGroup(item.bagId, item.slotIndex) and GetItemType(item.bagId, item.slotIndex) == ITEMTYPE_WEAPON end,
	all = function(item) return true end,
}
local PreviousFilter = LinkTradeFilters.def
local PreviousIncludeUncollected = false

function LootLogTrade.LinkTrade( ... )
	local params = LCCC.TokenizeSlashCommandParameters(...)
	local isContinuation = false
	local filter = LinkTradeFilters.def
	local includeUncollected = false

	if (params.continue) then
		isContinuation = true
		filter = PreviousFilter
		includeUncollected = PreviousIncludeUncollected
	elseif (params.reset or params.r) then
		ItemProcessed = { }
		LastLinked = { }
		LootLog.Msg(GetString(SI_LOOTLOG_TRADE_LINKRESET))
	end

	if (not isContinuation) then
		LootLog.vars.tradeCommandsCount = LootLog.vars.tradeCommandsCount + 1
	end

	if (params.boe or params.e) then
		filter = LinkTradeFilters.boe
	elseif (params.bop or params.p) then
		filter = LinkTradeFilters.bop
	elseif (params.wep or params.w) then
		filter = LinkTradeFilters.wep
	elseif (params.all or params.a) then
		filter = LinkTradeFilters.all
	end

	if (params.uncollected or params.u) then
		includeUncollected = true
	end

	PreviousFilter = filter
	PreviousIncludeUncollected = includeUncollected

	--------
	-- Find and count all tradeable items
	--------

	local items = { }

	local bagCache = SHARED_INVENTORY:GetOrCreateBagCache(BAG_BACKPACK)
	for _, item in pairs(bagCache) do
		local itemLink = GetItemLink(item.bagId, item.slotIndex, LINK_STYLE_BRACKETS)

		if (not IsItemPlayerLocked(item.bagId, item.slotIndex) and not IsItemStolen(item.bagId, item.slotIndex) and not IsItemLinkBound(itemLink) and filter(item) and IsItemLinkSetCollectionPiece(itemLink)) then
			local setId = select(6, GetItemLinkSetInfo(itemLink))
			local slot = GetItemLinkItemSetCollectionSlot(itemLink)
			local key = string.format("%d:%s", setId, Id64ToString(slot))

			if (not items[key]) then
				items[key] = {
					link = itemLink,
					count = (includeUncollected or IsItemSetCollectionSlotUnlocked(setId, slot)) and 1 or 0,
				}
			else
				items[key].count = items[key].count + 1
			end

			-- If this is a new copy of a previously-linked item, then reset the cooldown and update
			-- the representative link to use the newer item's link
			local id = GetItemUniqueIdString(item.bagId, item.slotIndex)
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

	local time = GetTimeStamp()
	local results = { }
	local remaining = CHAT_MAX_CHARS
	local overflow = 0
	local cooldown = 0

	for key, item in pairs(items) do
		if (not LastLinked[key]) then LastLinked[key] = 0 end

		if (items[key].count > 0) then
			if (time - LastLinked[key] > RELINK_COOLDOWN) then
				local result = (items[key].count == 1) and items[key].link or string.format("%s×%d", items[key].link, items[key].count)
				local resultLen = zo_strlen(result)
				if (resultLen < remaining) then
					table.insert(results, result)
					remaining = remaining - resultLen
					LastLinked[key] = time
				else
					overflow = overflow + 1
				end
			else
				cooldown = cooldown + 1
			end
		end
	end

	--------
	-- Output
	--------

	if (#results > 0) then
		LinkTradeWatcher.message = table.concat(results, "")

		if (not isContinuation and IsInGroupedInstance()) then
			-- Swap to group chat for the initial message if grouped inside an instance
			StartChatInput(LinkTradeWatcher.message, CHAT_CHANNEL_PARTY)
		else
			-- Use the current channel for all other cases
			StartChatInput(LinkTradeWatcher.message)
		end

		if (isContinuation) then
			LootLog.Msg(string.format(GetString(SI_LOOTLOG_TRADE_OVERFLOW), LinkTradeWatcher.overflow))
		end

		LinkTradeWatcher.overflow = overflow
		LinkTradeWatcher.Toggle(overflow > 0)
	elseif (cooldown > 0) then
		LootLog.Msg(string.format(GetString(SI_LOOTLOG_TRADE_NOLINKS_CD), cooldown))
	else
		LootLog.Msg(GetString(SI_LOOTLOG_TRADE_NOLINKS))
	end
end

LinkTradeWatcher = {
	active = false,
	overflow = 0,

	Toggle = function( enable )
		if (enable and not LinkTradeWatcher.active) then
			LinkTradeWatcher.active = true
			EVENT_MANAGER:RegisterForEvent(LootLogTrade.name, EVENT_CHAT_MESSAGE_CHANNEL, LinkTradeWatcher.ChatEvent)
		elseif (not enable and LinkTradeWatcher.active) then
			LinkTradeWatcher.active = false
			EVENT_MANAGER:UnregisterForEvent(LootLogTrade.name, EVENT_CHAT_MESSAGE_CHANNEL)
		end
	end,

	ChatEvent = function( eventCode, channelType, fromName, text, isCustomerService, fromDisplayName )
		if (text == LinkTradeWatcher.message and (channelType == CHAT_CHANNEL_WHISPER_SENT or fromDisplayName == LootLog.self.userId)) then
			LootLogTrade.LinkTrade("continue")
		end
	end,
}


--------------------------------------------------------------------------------
-- Bind uncollected items
--------------------------------------------------------------------------------

local MAX_BIND = 20 -- Limit of number of items to bind in a single batch, to avoid error 318
local MAX_AUTOBIND_DURATION = 999999 -- Maximum autobind duration, in minutes
local ItemsBound = { }
local BindReports = { }

local function BindUncollectedItems( params, autoInvoked )
	local selfPriority = LootLogMulti.GetCurrentAccountPriority()
	local reservations = { }
	local bound = { }
	local pending = { }
	local overflow = 0

	local bagCache = SHARED_INVENTORY:GetOrCreateBagCache(BAG_BACKPACK)
	for _, item in pairs(bagCache) do
		local itemLink = GetItemLink(item.bagId, item.slotIndex, LINK_STYLE_BRACKETS)

		if (not IsItemPlayerLocked(item.bagId, item.slotIndex) and IsItemLinkSetCollectionPiece(itemLink) and not IsItemSetCollectionPieceUnlocked(GetItemLinkItemId(itemLink))) then
			local key = LootLog.GetItemLinkItemSetCollectionKey(itemLink)

			if (not ItemsBound[key]) then
				if (not reservations[key]) then
					-- Number of copies to reserve for higher-priority accounts that are missing the item
					reservations[key] = LootLogMulti.CountUncollectedAccounts(itemLink, item, selfPriority)
				end

				if (reservations[key] > 0) then
					reservations[key] = reservations[key] - 1
				elseif (selfPriority == 0 and GetItemLinkBindType(itemLink) == BIND_TYPE_ON_EQUIP) then
					-- Accounts with no priority should never bind BoE items
				elseif (#bound < MAX_BIND) then
					BindItem(item.bagId, item.slotIndex)
					ItemsBound[key] = true
					table.insert(bound, itemLink)
					if (params.junk or params.j) then
						SetItemIsJunk(item.bagId, item.slotIndex, true)
					end
				elseif (not pending[key]) then
					pending[key] = true
					overflow = overflow + 1
				end
			end
		end
	end

	local reportLink = ""
	if (#bound > 0) then
		local key = tostring(HashString(table.concat(bound, "")))
		BindReports[key] = bound
		reportLink = string.format("  |H0:llbind:%s|h[%s]|h", key, GetString(SI_LOOTLOG_BIND_SHOW))
		LCCC.RegisterLinkHandler("llbind", LootLogTrade.BindReport)
	end

	if (#bound > 0 or not autoInvoked) then
		LootLog.Msg(string.format(GetString(SI_LOOTLOG_BIND_COMPLETED), #bound, reportLink))
	end

	if (overflow > 0) then
		LootLog.Msg(string.format(GetString(SI_LOOTLOG_BIND_OVERFLOW), overflow))
	end
end

function LootLogTrade.BindUncollected( ... )
	local params = LCCC.TokenizeSlashCommandParameters(...)
	LootLog.vars.tradeCommandsCount = LootLog.vars.tradeCommandsCount + 1

	for key in pairs(params) do
		if (string.find(key, "^%d+$")) then
			return AutoBinder.Setup(params, tonumber(key))
		end
	end

	BindUncollectedItems(params)
end

function LootLogTrade.BindReport( key )
	if (BindReports[key]) then
		local setIds = { }
		for _, itemLink in ipairs(BindReports[key]) do
			local setId = select(6, GetItemLinkSetInfo(itemLink))
			if (setIds[setId]) then
				table.insert(setIds[setId], itemLink)
			else
				setIds[setId] = { itemLink }
			end
		end

		local results = { }
		for setId, itemLinks in pairs(setIds) do
			table.insert(results, string.format(
				"%s%s (%d/%d) — %s",
				GetItemReconstructionCurrencyOptionCost(setId, CURT_CHAOTIC_CREATIA) or "—",
				zo_iconFormatInheritColor("/esoui/art/currency/gamepad/gp_seedcrystal_mipmap.dds", 18, 18),
				GetNumItemSetCollectionSlotsUnlocked(setId),
				GetNumItemSetCollectionPieces(setId),
				table.concat(itemLinks, ", ")
			))
		end

		CHAT_ROUTER:AddSystemMessage(table.concat(results, "\n"))
	end
end

AutoBinder = {
	name = "LootLogAutoBinder",
	active = false,

	Setup = function( params, duration )
		if (duration == 0) then
			LootLog.vars.autoBind.stopTime = 0
		else
			if (duration > MAX_AUTOBIND_DURATION) then duration = MAX_AUTOBIND_DURATION end
			LootLog.vars.autoBind.stopTime = duration * 60 + GetTimeStamp() + 10
			if (params.junk or params.j) then
				LootLog.vars.autoBind.junk = true
			else
				LootLog.vars.autoBind.junk = false
			end
		end
		AutoBinder.Refresh(duration > 0)
	end,

	Refresh = function( enablement )
		local remaining = LootLog.vars.autoBind.stopTime - GetTimeStamp()
		local printRemaining = function( )
			LootLog.Msg(string.format(GetString(SI_LOOTLOG_AUTOBIND_ON), remaining / 60))
		end

		if (remaining > 0 and not AutoBinder.active) then
			AutoBinder.active = true
			EVENT_MANAGER:RegisterForEvent(AutoBinder.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, AutoBinder.Event)
			EVENT_MANAGER:AddFilterForEvent(AutoBinder.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK)
			EVENT_MANAGER:AddFilterForEvent(AutoBinder.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_IS_NEW_ITEM, true)
			printRemaining()
			AutoBinder.Event()
		elseif (remaining <= 0 and AutoBinder.active) then
			AutoBinder.active = false
			EVENT_MANAGER:UnregisterForEvent(AutoBinder.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
			LootLog.Msg(GetString(SI_LOOTLOG_AUTOBIND_OFF))
		elseif (enablement) then
			-- We were invoked from an enablement command, in which the user is updating the stop time
			printRemaining()
		end
	end,

	Event = function( eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange, triggeredByCharacterName, triggeredByDisplayName, isLastUpdateForMessage )
		-- Multiple update events should be coalesced
		EVENT_MANAGER:UnregisterForUpdate(AutoBinder.name)
		EVENT_MANAGER:RegisterForUpdate(
			AutoBinder.name,
			1000,
			function( )
				-- Refresh ensures we have not exceeded our stop time
				AutoBinder.Refresh()
				if (AutoBinder.active) then
					BindUncollectedItems(LootLog.vars.autoBind, true)
				end
			end,
			true
		)
	end,
}
