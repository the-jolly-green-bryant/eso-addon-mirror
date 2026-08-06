-- LWTPriceInfoHooks.lua
-- Centralized registry of every UI hook registration for LWTPriceInfo.
--
-- Hooks are grouped by UI location. To add a hook for a new screen, write a
-- LWTPriceInfo.Hook* function in the relevant section below, then call it from
-- either LWTPriceInfo.InstallKeyboardHooks() or LWTPriceInfo.InstallGamepadHooks().
-- Hook bodies are kept verbatim from the original modules; only their home moved.

-- Local hook-state flags (gamepad). Declared here because the hook installers
-- that read/write them now live in this file.
local gamepadGuildStoreTooltipHooked = false
local gamepadBrowseHooked = false
local skipGenericTooltipHook = false
local agsColumnRegistered = false
local agsProviderMemo = {}
local agsMemoFingerprint = nil
-- Snapshot of per-row deltas built BEFORE AGS runs table.sort (see
-- AGSBuildSortSnapshot): the comparator reads ONLY this table during a sort,
-- so table.sort sees a pure, transitive comparison function (provider queries
-- and memo writes inside comparisons made the old comparator non-deterministic
-- — S1 — and the guild-specific early-return broke transitivity — S2).
local agsSortSnapshot = {}
local agsSnapshotActive = false
local agsResortPending = false
local agsResortAttempts = 0
local lwtAgsSortWrapped = false
LWTPriceInfo.AGS_NO_DATA = {}
-- One-shot guard for the keyboard mail attachment-slot price labels (see
-- HookMailAttachmentPrices): the post-hook must be registered exactly once.
local lwtMailSlotPricesHooked = false
-- One-shot guard for the keyboard trade-window slot price labels (see
-- HookTradeWindowPrices): both post-hooks must be registered exactly once.
local lwtTradeSlotPricesHooked = false
-- Extra down-shift for the delta tag inside the AGS row layout (SellPrice is
-- repositioned by AGS SearchResultListWrapper AdjustRowLayout, so the tag sits
-- too high there); positive Y moves a control DOWN in ESO screen coords.
-- Adjust if needed.
local AGS_TAG_Y_OFFSET = 14
-- Also exposed on the module table: LWTPriceInfo.lua (loaded before this file)
-- applies the same AGS-only shift in ShowMarker's guild anchor.
LWTPriceInfo.AGS_TAG_Y_OFFSET = AGS_TAG_Y_OFFSET

-- ===========================================================================
-- Shared scroll-list hook helper
-- ===========================================================================

function LWTPriceInfo.HookScrollList(listOwner, getItemLinkFunc)
	if not listOwner then return end

	local list = listOwner.list
	if not list then return end

	local scrollList = list.list or list
	if not scrollList or not scrollList.dataTypes then return end

	for _, dataType in pairs(scrollList.dataTypes) do
		if dataType.setupCallback then
			ZO_PostHook(dataType, "setupCallback", function(control, data)
				LWTPriceInfo.SafeCall(function()
					LWTPriceInfo.ClearAllMarkers(control)
					if not data then return end

					local itemLink = getItemLinkFunc(data)
					if not itemLink or itemLink == "" then return end

					local _, itemPrice = GetItemLinkInfo(itemLink)
					LWTPriceInfo.DisplayPrice(control, itemLink, itemPrice or 0, 0, 0, data.stackCount, false, false)
				end, "ScrollList hook")
			end)
		end
	end
end

-- ===========================================================================
-- Loot
-- ===========================================================================

function LWTPriceInfo.HookLootContainers()
	ZO_PostHook(ZO_ScrollList_GetDataTypeTable(ZO_LootAlphaContainerList, 1), "setupCallback", LWTPriceInfo.InitializeLootContainersUI)
end

-- ===========================================================================
-- Crafting tooltips (keyboard result tooltips)
-- ===========================================================================

function LWTPriceInfo.AddPriceToCraftingTooltip(toolTipControl, functionName, getItemLinkFunction)
	local base = toolTipControl[functionName]

	if (base == nil) then
		return
	end

	toolTipControl[functionName] = function(control, ...)
		base(control, ...)
		local itemLink = getItemLinkFunction(...)

		local tooltip = control
		if (control.resultTooltip ~= nil) then
			tooltip = control.resultTooltip
		elseif (control.tooltip ~= nil) then
			tooltip = control.tooltip
		end

		local info = {}
		info["itemLink"] = itemLink
		info["imitationItem"] = true
		LWTPriceInfo.InitializeLootContainersUI(tooltip, info)
	end
end

function LWTPriceInfo.HookKeyboardAlchemy()
	if not ZO_Alchemy then return end
	local base = ZO_Alchemy.UpdateTooltip
	if not base then return end

	ZO_PostHook(ZO_Alchemy, "UpdateTooltip", function(self)
		local itemLink = LWTPriceInfo.GetAlchemyResultItemLink()
		if not itemLink or itemLink == "" then
			LWTPriceInfo.HideCraftingPriceLabel(self)
			return
		end
		LWTPriceInfo.ShowCraftingPriceLabel(self, self.tooltip, itemLink)
	end)
end

function LWTPriceInfo.HookKeyboardProvisioner()
	if not PROVISIONER then return end
	if not PROVISIONER.RefreshRecipeDetails then return end

	ZO_PostHook(PROVISIONER, "RefreshRecipeDetails", function(self, selectedData)
		if not selectedData and self.recipeTree then
			selectedData = self.recipeTree:GetSelectedData()
		end
		local itemLink = LWTPriceInfo.GetProvisionerResultItemLink(selectedData)
		if not itemLink or itemLink == "" then
			LWTPriceInfo.HideCraftingPriceLabel(self)
			return
		end
		LWTPriceInfo.ShowCraftingPriceLabel(self, self.resultTooltip, itemLink)
	end)
end

-- ===========================================================================
-- Player inventory
-- ===========================================================================

function LWTPriceInfo.InitializePlayerInventory()
	for _, v in pairs(PLAYER_INVENTORY.inventories) do
		local listView = v.listView

		if (listView and listView.dataTypes and listView.dataTypes[1]) then
			ZO_PostHook(listView.dataTypes[1], "setupCallback",
			function(control, data)
				if (LWTPriceInfo.CheckIfCurrency(data)) then
					return
				end

				local itemLink = GetItemLink(data.bagId, data.slotIndex)
				local _, itemPrice = GetItemLinkInfo(itemLink)
				LWTPriceInfo.DisplayPrice(control, itemLink, itemPrice, 0, 0, data.stackCount, false, false)
			end
			)
		end
	end
end

-- ===========================================================================
-- Crafting panels (deconstruction / improvement / refinement / enchanting)
-- ===========================================================================

function LWTPriceInfo.InitializeCraftingUI()
	LWTPriceInfo.HookCraftingPanel(SMITHING, "deconstructionPanel")
	LWTPriceInfo.HookCraftingPanel(SMITHING, "improvementPanel")
	LWTPriceInfo.HookCraftingPanel(SMITHING, "refinementPanel")
	LWTPriceInfo.HookCraftingPanel(ENCHANTING, "inventory")

	LWTPriceInfo.HookCraftingPanel(UNIVERSAL_DECONSTRUCTION, "deconstructionPanel")
end

function LWTPriceInfo.HookCraftingPanel(system, panelName)
    local panel = system[panelName]
    local scrollList = panel and panel.inventory and panel.inventory.list
    local datatype = scrollList and scrollList.dataTypes and scrollList.dataTypes[1]
    if datatype then
		if datatype.setupCallback then
			ZO_PostHook(datatype, "setupCallback", function (control, data)
				LWTPriceInfo.ClearAllMarkers(control)
				LWTPriceInfo.InitializeContainersUI(control, data, false)
			end)
		end
	end
end

-- ===========================================================================
-- Store / Buyback
-- ===========================================================================

function LWTPriceInfo.HookStoreWindow()
	LWTPriceInfo.HookScrollList(STORE_WINDOW, function(data)
		return GetStoreItemLink(data.slotIndex)
	end)

	LWTPriceInfo.HookScrollList(BUY_BACK_WINDOW, function(data)
		return GetBuybackItemLink(data.slotIndex)
	end)
end

-- ===========================================================================
-- Mail
-- ===========================================================================

function LWTPriceInfo.HookMailWindow()
	LWTPriceInfo.HookScrollList(MAIL_INBOX.mailList, function(data)
		if not data or not data.mailId then return nil end
		return GetAttachedItemLink(data.mailId, 1, LINK_STYLE_DEFAULT)
	end)
end

-- Price labels on the keyboard mail open-view attachment slots. Post-hooks
-- RefreshAttachmentSlots (runs after the vanilla slot fill) and, per visible
-- slot, shows the item's market price: odd slots (1,3,5...) anchor the label
-- to the slot BOTTOMRIGHT (bottom of the item), even slots to TOPRIGHT (top).
-- The label is a SINGLE line showing the STACK TOTAL market price: per-unit
-- price x the attachment's actual stack count from GetAttachedItemInfo (a
-- stack of 25 at 100g shows "2,500"). The provider's market-volume count is
-- NOT shown. Labels are get-or-create per slot, so refreshes reuse the child
-- control.
function LWTPriceInfo.HookMailAttachmentPrices()
	if lwtMailSlotPricesHooked then return end
	if not MAIL_INBOX or not MAIL_INBOX.RefreshAttachmentSlots then return end
	lwtMailSlotPricesHooked = true

	ZO_PostHook(MAIL_INBOX, "RefreshAttachmentSlots", function(self)
		LWTPriceInfo.SafeCall(function()
			local slots = self.attachmentSlots
			if not slots then return end

			local function HideSlotPrice(slot)
				local label = slot:GetNamedChild(LWTPriceInfo.name .. "MailSlotPrice")
				if label then label:SetHidden(true) end
			end

			local settings = LWTPriceInfo.GetMarkerSettings()
			if not settings.enabled then
				for i = 1, #slots do
					HideSlotPrice(slots[i])
				end
				return
			end

			for i = 1, #slots do
				local slot = slots[i]
				if slot:IsHidden() then
					HideSlotPrice(slot)
				else
					local itemLink = GetAttachedItemLink(self.mailId, i, LINK_STYLE_DEFAULT)
					if not itemLink or itemLink == "" then
						HideSlotPrice(slot)
					else
						local _, stack = GetAttachedItemInfo(self.mailId, i)
						local price, count = LWTPriceInfo.GetPriceAndCount(settings, itemLink, stack or 1)
						if not price or price == 0 then
							HideSlotPrice(slot)
						else
							local r = LWTPriceInfo.FormatPriceDisplay(price, count, {
								minPrice = settings.minPrice,
								maxPrice = settings.maxPrice,
								colors = settings.colors,
								priceShorten = settings.priceShorten,
								showAmount = settings.showAmount ~= false,
								colorAmount = settings.colorAmount,
								countMin = settings.countMin,
								countMax = settings.countMax,
							})

							local priceText = "|c" .. r.priceHex .. r.priceFormatted .. "|r"

							local label = slot:GetNamedChild(LWTPriceInfo.name .. "MailSlotPrice")
							if not label then
								label = WINDOW_MANAGER:CreateControl(slot:GetName() .. LWTPriceInfo.name .. "MailSlotPrice", slot, CT_LABEL)
							end

							label:SetFont(string.format("$(%s)|$(KB_%s)|soft-shadow-thick", settings.textBold and "BOLD_FONT" or "MEDIUM_FONT", settings.textScale))
							label:SetText(priceText)
							label:ClearAnchors()
							if slot.id and slot.id % 2 == 0 then
								label:SetAnchor(TOPRIGHT, slot, TOPRIGHT, -2, 0)
							else
								label:SetAnchor(BOTTOMRIGHT, slot, BOTTOMRIGHT, -2, 0)
							end
							label:SetHidden(false)
						end
					end
				end
			end
		end, "Mail attachment slot prices")
	end)
end

-- Price labels on the keyboard player-to-player trade window slot rows (both
-- sides: your offered items TRADE_ME and theirs TRADE_THEM). Post-hooks
-- OnTradeWindowItemAdded (the per-item refresh; runs after the vanilla slot
-- fill, so a TRADE_THEM slot is already un-hidden) and ResetSlot (item removed
-- or a new trade starts: PrepareWindowForNewTrade -> ResetAllSlots), showing
-- each offered item's market price on its row.
-- Why TRADE and not TRADE_WINDOW: TRADE_WINDOW is ZO_TradeManager:New()
-- (esoui/ingame/tradewindow/tradewindow.lua:89), a MANAGER with no slot
-- methods; the actual keyboard window instance with OnTradeWindowItemAdded /
-- ResetSlot is TRADE = ZO_TradeWindow:New(control)
-- (esoui/ingame/tradewindow/keyboard/tradewindow_keyboard.lua:339). Post-hooks
-- on TRADE_WINDOW would never fire.
-- Placement facts (tradewindow_keyboard.xml L21-47): each ZO_TradeSlot row is
-- 345x45; the icon Button is 40x40 at the row LEFT (CENTER anchor at offset
-- 30,23 from TOPLEFT -> spans x 10..50, y 3..43); the Name label (230x40) is
-- to the RIGHT of the icon (x 60..290); rows stack TOPLEFT -> BOTTOMLEFT with
-- a 2px gap (pitch 47px). Only ~4px of vertical room exist under the icon
-- (icon bottom 43 -> next row top 47), which cannot hold even one text line
-- without covering the next row's icon, and there is no room for a second
-- line anywhere in the row, so the label is a SINGLE line ("unit / total",
-- right-aligned in the row's empty right margin: name ends at x 290, row ends
-- at x 345) where it overlaps neither the name nor the row below. Anchored
-- TOPRIGHT -> row.Control TOPRIGHT (-2,0), the same corner as the mail
-- even-slot labels ("as everywhere"). The "/ total" suffix (per-unit price x
-- trade stack quantity, same color, no decimals) shows the stack's market
-- value the vanilla row never displays (its icon shows only the quantity
-- count); it is omitted when quantity <= 1 because total == perUnit.
function LWTPriceInfo.HookTradeWindowPrices()
	if lwtTradeSlotPricesHooked then return end
	if not TRADE or not TRADE.OnTradeWindowItemAdded then return end
	lwtTradeSlotPricesHooked = true

	local function HideSlotPrice(row)
		local label = row.SlotControl:GetNamedChild(LWTPriceInfo.name .. "TradeSlotPrice")
		if label then label:SetHidden(true) end
	end

	ZO_PostHook(TRADE, "OnTradeWindowItemAdded", function(self, eventCode, who, tradeSlot)
		LWTPriceInfo.SafeCall(function()
			if who ~= TRADE_ME and who ~= TRADE_THEM then return end
			local columns = self.Columns
			local row = columns and columns[who] and columns[who][tradeSlot]
			if not row then return end
			if row.SlotControl:IsHidden() then
				HideSlotPrice(row)
				return
			end

			local settings = LWTPriceInfo.GetMarkerSettings()
			if not settings.enabled then
				for _, tradeWho in pairs({ TRADE_ME, TRADE_THEM }) do
					local column = columns[tradeWho]
					if column then
						for i = 1, TRADE_NUM_SLOTS do
							if column[i] then HideSlotPrice(column[i]) end
						end
					end
				end
				return
			end

			local itemLink = GetTradeItemLink(who, tradeSlot)
			if not itemLink or itemLink == "" then
				HideSlotPrice(row)
				return
			end

			local price, count = LWTPriceInfo.GetPriceAndCount(settings, itemLink, 1)
			if not price or price == 0 then
				HideSlotPrice(row)
				return
			end

			local r = LWTPriceInfo.FormatPriceDisplay(price, count, {
				minPrice = settings.minPrice,
				maxPrice = settings.maxPrice,
				colors = settings.colors,
				priceShorten = settings.priceShorten,
				showAmount = settings.showAmount ~= false,
				colorAmount = settings.colorAmount,
				countMin = settings.countMin,
				countMax = settings.countMax,
			})

			local _, _, quantity = GetTradeItemInfo(who, tradeSlot)

			local text = "|c" .. r.priceHex .. r.priceFormatted .. "|r"
			if quantity and quantity > 1 then
				text = text .. " / " .. "|c" .. r.priceHex .. LWTPriceInfo.FormatNumber(price * quantity, 0) .. "|r"
			end

			local slotControl = row.SlotControl
			local label = slotControl:GetNamedChild(LWTPriceInfo.name .. "TradeSlotPrice")
			if not label then
				label = WINDOW_MANAGER:CreateControl(slotControl:GetName() .. LWTPriceInfo.name .. "TradeSlotPrice", slotControl, CT_LABEL)
			end

			label:SetFont(string.format("$(%s)|$(KB_%s)|soft-shadow-thick", settings.textBold and "BOLD_FONT" or "MEDIUM_FONT", settings.textScale))
			label:SetText(text)
			label:ClearAnchors()
			label:SetAnchor(TOPRIGHT, row.Control, TOPRIGHT, -2, 0)
			label:SetHidden(false)
		end, "Trade slot prices")
	end)

	ZO_PostHook(TRADE, "ResetSlot", function(self, who, index)
		LWTPriceInfo.SafeCall(function()
			local columns = self.Columns
			local row = columns and columns[who] and columns[who][index]
			if not row then return end
			HideSlotPrice(row)
		end, "Trade slot prices (reset)")
	end)
end

-- ===========================================================================
-- Guild bank
-- ===========================================================================

function LWTPriceInfo.HookGuildBank()
	LWTPriceInfo.HookScrollList(GUILD_BANK, function(data)
		if not data or not data.slotIndex then return nil end
		return GetGuildBankItemLink(data.slotIndex)
	end)
end

-- ===========================================================================
-- Housing storage
-- ===========================================================================

function LWTPriceInfo.HookHousingStorage()
	LWTPriceInfo.HookScrollList(HOUSING_BANK, function(data)
		if not data or not data.slotIndex then return nil end
		return GetHousingBankItemLink(data.slotIndex)
	end)
end

-- ===========================================================================
-- Companion inventory
-- ===========================================================================

function LWTPriceInfo.HookCompanionInventory()
	LWTPriceInfo.HookScrollList(COMPANION_INVENTORY, function(data)
		if not data or not data.bagId or not data.slotIndex then return nil end
		return GetItemLink(data.bagId, data.slotIndex)
	end)
end

-- ===========================================================================
-- Fence (sell / launder)
-- ===========================================================================

function LWTPriceInfo.HookFenceWindow()
	LWTPriceInfo.HookScrollList(FENCE_SELL, function(data)
		if not data or not data.slotIndex then return nil end
		return GetFenceSellItemLink(data.slotIndex)
	end)

	LWTPriceInfo.HookScrollList(FENCE_LAUNDER, function(data)
		if not data or not data.slotIndex then return nil end
		return GetFenceLaunderItemLink(data.slotIndex)
	end)
end

-- ===========================================================================
-- Antiquity leads
-- ===========================================================================

function LWTPriceInfo.HookAntiquityLeads()
	LWTPriceInfo.HookScrollList(ANTIQUITY_JOURNAL, function(data)
		if not data or not data.antiquityId then return nil end
		return GetAntiquityJournalItemLink(data.antiquityId)
	end)
end

-- ===========================================================================
-- Set collection
-- ===========================================================================

function LWTPriceInfo.HookSetCollection()
	LWTPriceInfo.HookScrollList(SET_COLLECTION_BOOK, function(data)
		if not data or not data.setId then return nil end
		return GetSetCollectionItemLink(data.setId)
	end)
end

-- ===========================================================================
-- Guild trader (keyboard browse results)
-- ===========================================================================

function LWTPriceInfo.HookGuildTraderBrowse()
	local hookedFunction = TRADING_HOUSE.searchResultsList.dataTypes[1].setupCallback
	if hookedFunction then
		ZO_PostHook(TRADING_HOUSE.searchResultsList.dataTypes[1], "setupCallback",
		function (control, data)
			LWTPriceInfo.ClearAllMarkers(control)
			-- T5 (guild delta column): render the per-row delta label(s) and suppress
			-- the overlay marker, only while the column is active. Two branches:
			--   * AGS present: ONE combined label ("GuildColumn") anchored to SellPrice
			--     with the AGS down-shift — exactly the pre-F3-r4 behavior.
			--   * Vanilla (no AGS): TWO labels — the per-unit delta directly over the
			--     unit price ("GuildPerUnitDelta" -> SellPricePerUnit) and the stack
			--     total at the old tag position ("GuildColumn" -> SellPrice).
			-- The per-unit label also carries the overlay-style volume count suffix
			-- (" |c<hex>[N]", restored); the stack-total label stays number-only.
			-- Both child names are DISTINCT from the overlay marker child, so they
			-- never collide with it. When inactive the labels are never created
			-- (leftover children from a live toggle are hidden) and the overlay path
			-- stays byte-identical to today.
			local settings = LWTPriceInfo.GetMarkerSettings()
			local columnActive = LWTPriceInfo.GuildColumnActive()
			local columnLabel = control:GetNamedChild(LWTPriceInfo.name .. "GuildColumn")
			if (columnActive and data) then
				local d = LWTPriceInfo.GetGuildSearchDeltaFromResult(data, settings)
				local showTotal = LWTPriceInfo.vars.guildColumn and LWTPriceInfo.vars.guildColumn.showTotal
				local fontStyle = settings.textBold and "BOLD_FONT" or "MEDIUM_FONT"
				local columnFont = string.format("$(%s)|$(KB_%s)|soft-shadow-thick", fontStyle, settings.textScale)
				if (AwesomeGuildStore ~= nil) then
					-- AGS branch: single combined label, unchanged from before.
					local cellText = LWTPriceInfo.BuildGuildColumnText(d, settings, showTotal)
					if (cellText) then
						if (not columnLabel) then
							columnLabel = WINDOW_MANAGER:CreateControl(control:GetName() .. LWTPriceInfo.name .. "GuildColumn", control, CT_LABEL)
						end
						columnLabel:SetFont(columnFont)
						columnLabel:SetText(cellText)
						columnLabel:ClearAnchors()
						local sellPriceControl = control:GetNamedChild("SellPrice")
						if (sellPriceControl) then
							-- AGS re-anchors SellPrice in its own row layout (SearchResultListWrapper
							-- AdjustRowLayout), which sits the tag too high there; nudge it down by
							-- AGS_TAG_Y_OFFSET only while AGS is present.
							columnLabel:SetAnchor(BOTTOMRIGHT, sellPriceControl, TOPRIGHT, settings.xOffsetGuild, settings.yOffsetGuild + (AwesomeGuildStore ~= nil and AGS_TAG_Y_OFFSET or 0))
						end
						columnLabel:SetHidden(false)
					elseif (columnLabel) then
						columnLabel:SetHidden(true)
					end
				else
					-- Vanilla branch: per-unit delta directly OVER the unit price.
					local perUnitLabel = control:GetNamedChild(LWTPriceInfo.name .. "GuildPerUnitDelta")
					local perUnitText = LWTPriceInfo.BuildGuildColumnPerUnitText(d, settings)
					if (perUnitText) then
						if (not perUnitLabel) then
							perUnitLabel = WINDOW_MANAGER:CreateControl(control:GetName() .. LWTPriceInfo.name .. "GuildPerUnitDelta", control, CT_LABEL)
						end
						perUnitLabel:SetFont(columnFont)
						perUnitLabel:SetText(perUnitText .. (LWTPriceInfo.BuildGuildColumnCountText(d, settings) or ""))
						perUnitLabel:ClearAnchors()
						local unitPriceControl = control:GetNamedChild("SellPricePerUnit")
						if (unitPriceControl) then
							perUnitLabel:SetAnchor(BOTTOMRIGHT, unitPriceControl, TOPRIGHT, settings.xOffsetGuild, settings.yOffsetGuild)
						end
						perUnitLabel:SetHidden(false)
					elseif (perUnitLabel) then
						perUnitLabel:SetHidden(true)
					end
					-- Vanilla branch: stack total at the old tag position.
					local totalText = LWTPriceInfo.BuildGuildColumnTotalText(d, settings)
					if (showTotal and totalText) then
						if (not columnLabel) then
							columnLabel = WINDOW_MANAGER:CreateControl(control:GetName() .. LWTPriceInfo.name .. "GuildColumn", control, CT_LABEL)
						end
						columnLabel:SetFont(columnFont)
						columnLabel:SetText(totalText)
						columnLabel:ClearAnchors()
						local sellPriceControl = control:GetNamedChild("SellPrice")
						if (sellPriceControl) then
							columnLabel:SetAnchor(BOTTOMRIGHT, sellPriceControl, TOPRIGHT, settings.xOffsetGuild, settings.yOffsetGuild)
						end
						columnLabel:SetHidden(false)
					elseif (columnLabel) then
						columnLabel:SetHidden(true)
					end
				end
			else
				-- Inactive or no data: hide leftover labels from a live toggle.
				if (columnLabel) then
					columnLabel:SetHidden(true)
				end
				local perUnitLabel = control:GetNamedChild(LWTPriceInfo.name .. "GuildPerUnitDelta")
				if (perUnitLabel) then
					perUnitLabel:SetHidden(true)
				end
			end
			LWTPriceInfo.InitializeContainersUIGuild(control, data)
			-- T5: hide the overlay marker on guild store rows only while the column is active.
			if (columnActive) then
				local marker = control:GetNamedChild(LWTPriceInfo.name .. settings.childName)
				if (marker) then
					marker:SetHidden(true)
				end
			end
		end)
	end
end

-- The separate "Show delta column" toggle is gone (removed as redundant in
-- round A); the delta tags + AGS sort now follow the "Guild delta" master
-- switch directly, still gated on the addon being enabled.
function LWTPriceInfo.GuildColumnActive()
	local settings = LWTPriceInfo.GetMarkerSettings()
	return settings.enabled and settings.guildPriceDelta
end

-- ===========================================================================
-- Gamepad sub-labels
-- ===========================================================================

function LWTPriceInfo.InitializeGamepadSubLabels()
	if not ZO_SharedGamepadEntry_OnSetup then return end

	ZO_PostHook("ZO_SharedGamepadEntry_OnSetup", function(control, data, selected, reselectingDuringRebuild, enabled, active)
		LWTPriceInfo.SafeCall(function()
			local priceLabel = control:GetNamedChild("LWTPrice")
			if priceLabel then
				priceLabel:SetHidden(true)
			end

			if not data then return end

			local displayMode = LWTPriceInfo.vars.gamepad.displayMode
			if displayMode == "tooltip" then return end

			local itemLink
			local stackCount = data.stackCount

			if data.lootId then
				itemLink = GetLootItemLink(data.lootId)
				stackCount = stackCount or data.count
			elseif data.bagId and data.slotIndex then
				itemLink = GetItemLink(data.bagId, data.slotIndex)
			elseif data.itemLink then
				itemLink = data.itemLink
			elseif data.recipeListIndex and data.recipeIndex then
				itemLink = GetRecipeResultItemLink(data.recipeListIndex, data.recipeIndex)
			elseif data.slotIndex then
				itemLink = GetStoreItemLink(data.slotIndex)
				if not itemLink or itemLink == "" then
					itemLink = GetBuybackItemLink(data.slotIndex)
				end
			end

			if not itemLink or itemLink == "" then return end

			local priceText = LWTPriceInfo.GetGamepadPriceText(itemLink, stackCount)
			if not priceText then return end

			local label = control:GetNamedChild("Label")
			if not label then return end

			if not priceLabel then
				priceLabel = CreateControl(control:GetName() .. "LWTPrice", control, CT_LABEL)
			end

			local markerSettings = LWTPriceInfo.GetMarkerSettings()
			local fontStyle = markerSettings.textBold and "BOLD_FONT" or "MEDIUM_FONT"
			local customFont = string.format("$(%s)|$(KB_%s)|soft-shadow-thick", fontStyle, markerSettings.textScale)
			priceLabel:SetFont(customFont)
			priceLabel:ClearAnchors()
			priceLabel:SetAnchor(BOTTOMLEFT, label, TOPLEFT, markerSettings.xOffsetInv, markerSettings.yOffsetInv + 10)
			priceLabel:SetText(priceText)
			priceLabel:SetHidden(false)
		end, "Gamepad sub-label")
	end)
end

-- ===========================================================================
-- Gamepad tooltips (bag / craft bag / item / mail / trade / guild bank / housing)
-- ===========================================================================

function LWTPriceInfo.InitializeGamepadTooltips()
	local function TooltipHook(tooltipControl, method, dataFunc)
		if not tooltipControl or not tooltipControl[method] then return end

		local origMethod = tooltipControl[method]
		tooltipControl[method] = function(self, ...)
			self._lwtPriceAdded = nil
			origMethod(self, ...)

			if skipGenericTooltipHook then return end
			if self._lwtPriceAdded then return end

			local ok, itemLink, stackCount = pcall(dataFunc, ...)
			if ok and itemLink and itemLink ~= "" then
				LWTPriceInfo.SafeCall(function()
					LWTPriceInfo.AddGamepadTooltipPrice(self, itemLink, stackCount)
				end, "Gamepad tooltip price")
				self._lwtPriceAdded = true
			elseif not ok then
				LWTPriceInfo.errorLog = LWTPriceInfo.errorLog .. "Gamepad tooltip dataFunc: " .. tostring(itemLink) .. "\n"
			end
		end
	end

	local tooltipTargets = { GAMEPAD_LEFT_TOOLTIP, GAMEPAD_RIGHT_TOOLTIP, GAMEPAD_MOVABLE_TOOLTIP }
	local hookedTooltips = {}

	for _, tooltipId in ipairs(tooltipTargets) do
		local ok, tooltip = pcall(function() return GAMEPAD_TOOLTIPS:GetTooltip(tooltipId) end)
		if not ok then
			LWTPriceInfo.errorLog = LWTPriceInfo.errorLog .. "Gamepad tooltip lookup: " .. tostring(tooltip) .. "\n"
		end
		if ok and tooltip and not hookedTooltips[tooltip] then
			hookedTooltips[tooltip] = true
			TooltipHook(tooltip, "LayoutBagItem", function(bagId, slotIndex)
				local stackCount = GetSlotStackSize(bagId, slotIndex)
				return GetItemLink(bagId, slotIndex), stackCount
			end)

			TooltipHook(tooltip, "LayoutCraftBagItem", function(bagId, slotIndex)
				local stackCount = GetSlotStackSize(bagId, slotIndex)
				return GetItemLink(bagId, slotIndex), stackCount
			end)

			TooltipHook(tooltip, "LayoutItemWithStackCount", function(itemLink, stackCount)
				return itemLink, stackCount
			end)

			TooltipHook(tooltip, "LayoutMailAttachment", function(mailId, attachIndex)
				local itemLink = GetAttachedItemLink(mailId, attachIndex)
				local stackCount = select(4, GetAttachedItemInfo(mailId, attachIndex))
				return itemLink, stackCount
			end)

			TooltipHook(tooltip, "LayoutTradeItem", function(tradeWho, tradeIndex)
				local itemLink = GetTradeItemLink(tradeWho, tradeIndex)
				local _, _, stackCount = GetTradeItemInfo(tradeWho, tradeIndex)
				return itemLink, stackCount
			end)

			TooltipHook(tooltip, "LayoutGuildBankItem", function(slotIndex)
				local itemLink = GetGuildBankItemLink(slotIndex)
				local stackCount = GetSlotStackSize(BAG_GUILD_BANK, slotIndex)
				return itemLink, stackCount
			end)

			TooltipHook(tooltip, "LayoutHousingBankItem", function(slotIndex)
				local itemLink = GetHousingBankItemLink(slotIndex)
				local stackCount = GetSlotStackSize(BAG_HOUSING_BANK, slotIndex)
				return itemLink, stackCount
			end)
		end
	end
end

-- ===========================================================================
-- Gamepad guild store tooltips
-- ===========================================================================

function LWTPriceInfo.InitializeGamepadGuildStoreTooltips()
	if gamepadGuildStoreTooltipHooked then return end

	local function HookTooltipClass(method, getDataFunc)
		if not ZO_Tooltip or not ZO_Tooltip[method] then return end

		ZO_PreHook(ZO_Tooltip, method, function(self, ...)
			if not IsInGamepadPreferredMode() then return end
			skipGenericTooltipHook = true
		end)

		ZO_PostHook(ZO_Tooltip, method, function(self, index, ...)
			if not IsInGamepadPreferredMode() then return end
			skipGenericTooltipHook = false
			LWTPriceInfo.SafeCall(function()
				local itemLink, stackCount = getDataFunc(index)
				if itemLink and itemLink ~= "" then
					LWTPriceInfo.AddGamepadTooltipPrice(self, itemLink, stackCount)
				end
			end, "Gamepad guild tooltip")
		end)
	end

	HookTooltipClass("LayoutTradingHouseSearchResult", function(resultIndex)
		local _, _, _, stackCount = GetTradingHouseSearchResultItemInfo(resultIndex)
		return GetTradingHouseSearchResultItemLink(resultIndex), stackCount
	end)

	HookTooltipClass("LayoutTradingHouseListing", function(listingIndex)
		local _, _, _, stackCount = GetTradingHouseListingItemInfo(listingIndex)
		return GetTradingHouseListingItemLink(listingIndex), stackCount
	end)

	gamepadGuildStoreTooltipHooked = true
end

-- ===========================================================================
-- Gamepad guild store browse results list
-- ===========================================================================

function LWTPriceInfo.HookGamepadBrowseResultsList()
	if gamepadBrowseHooked then return end

	if not GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS then return end

	local browseResults = GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS
	local dataTypeId = ZO_GAMEPAD_INTERACTIVE_FILTER_LIST_PRIMARY_DATA_TYPE or 1
	local dataType = ZO_ScrollList_GetDataTypeTable(browseResults.list, dataTypeId)
	if not dataType or not dataType.setupCallback then return end

	local GP_PRICE_CHILD = LWTPriceInfo.name .. "_GPPrice"
	local GP_FONT = "$(BOLD_FONT)|$(KB_20)|soft-shadow-thick"

	ZO_PostHook(dataType, "setupCallback", function(rowControl, rowData)
		LWTPriceInfo.SafeCall(function()
			local priceLabel = rowControl:GetNamedChild(GP_PRICE_CHILD)
			local itemLink = rowData and rowData.itemLink

			if not itemLink or itemLink == "" then
				if priceLabel then priceLabel:SetHidden(true) end
				return
			end

			local guildPricePerUnit = nil
			if rowData.purchasePricePerUnit then
				guildPricePerUnit = rowData.purchasePricePerUnit
			end

			local priceText = LWTPriceInfo.GetGamepadPriceText(itemLink, rowData.stackCount, guildPricePerUnit)
			if not priceText or priceText == "" then
				if priceLabel then priceLabel:SetHidden(true) end
				return
			end

			if not priceLabel then
				priceLabel = WINDOW_MANAGER:CreateControl(
					rowControl:GetName() .. GP_PRICE_CHILD, rowControl, CT_LABEL)
				priceLabel:SetFont(GP_FONT)
			end

			priceLabel:ClearAnchors()
			priceLabel:SetAnchor(BOTTOMRIGHT, rowControl.priceLabel, TOPRIGHT, 0, 0)
			priceLabel:SetText(priceText)
			priceLabel:SetHidden(false)
		end, "Gamepad browse row")
	end)

	gamepadBrowseHooked = true
	LWTPriceInfo._gamepadBrowseHooked = true

	LWTPriceInfo.SafeCall(function()
		ZO_ScrollList_RefreshVisible(browseResults.list)
	end, "Gamepad browse refresh")
end

-- ===========================================================================
-- Gamepad crafting tooltips (smithing / enchanting / alchemy / provisioner)
-- ===========================================================================

function LWTPriceInfo.InitializeGamepadCraftingTooltips()
	if SMITHING_GAMEPAD then
		if SMITHING_GAMEPAD.creationPanel then
			ZO_PostHook(SMITHING_GAMEPAD.creationPanel, "SetupResultTooltip",
				function(self, selectedPatternIndex, selectedMaterialIndex, selectedMaterialQuantity, selectedStyleId, selectedTraitIndex)
					LWTPriceInfo.SafeCall(function()
						local itemLink = GetSmithingPatternResultLink(selectedPatternIndex, selectedMaterialIndex, selectedMaterialQuantity, selectedStyleId, selectedTraitIndex)
						if itemLink and itemLink ~= "" then
							LWTPriceInfo.AddGamepadTooltipPrice(self.resultTooltip.tip, itemLink, 1)
						end
					end, "Gamepad smithing creation")
				end)
		end

		if SMITHING_GAMEPAD.improvementPanel then
			ZO_PostHook(SMITHING_GAMEPAD.improvementPanel, "SetupResultTooltip",
				function(self, ...)
					local args = { ... }
					LWTPriceInfo.SafeCall(function()
						local itemLink = GetSmithingImprovedItemLink(unpack(args))
						if itemLink and itemLink ~= "" then
							LWTPriceInfo.AddGamepadTooltipPrice(self.resultTooltip.tip, itemLink, 1)
						end
					end, "Gamepad smithing improvement")
				end)
		end
	end

	if GAMEPAD_ENCHANTING then
		ZO_PostHook(GAMEPAD_ENCHANTING, "UpdateTooltip",
			function(self)
				LWTPriceInfo.SafeCall(function()
					if not self:IsCraftable() then return end
					local itemLink = GetEnchantingResultingItemLink(self:GetAllCraftingBagAndSlots())
					if itemLink and itemLink ~= "" then
						LWTPriceInfo.AddGamepadTooltipPrice(self.resultTooltip.tip, itemLink, 1)
					end
				end, "Gamepad enchanting")
			end)
	end

	if GAMEPAD_ALCHEMY then
		ZO_PostHook(GAMEPAD_ALCHEMY, "UpdateTooltip",
			function(self)
				LWTPriceInfo.SafeCall(function()
					if not self:IsCraftable() then return end
					local itemLink = GetAlchemyResultingItemLink(self:GetAllCraftingBagAndSlots())
					if itemLink and itemLink ~= "" then
						LWTPriceInfo.AddGamepadTooltipPrice(self.tooltip.tip, itemLink, 1)
					end
				end, "Gamepad alchemy")
			end)
	end

	if GAMEPAD_PROVISIONER then
		ZO_PostHook(GAMEPAD_PROVISIONER, "RefreshRecipeDetails",
			function(self, selectedData)
				LWTPriceInfo.SafeCall(function()
					if not selectedData then return end
					local recipeListIndex = selectedData.recipeListIndex
					local recipeIndex = selectedData.recipeIndex
					if not recipeListIndex or not recipeIndex then return end
					local itemLink = GetRecipeResultItemLink(recipeListIndex, recipeIndex)
					if itemLink and itemLink ~= "" then
						LWTPriceInfo.AddGamepadTooltipPrice(self.resultTooltip.tip, itemLink, 1)
					end
			end, "Gamepad provisioner")
		end)
	end
end

-- ===========================================================================
-- Keyboard tooltip hooks (mail attachments / trade items)
-- ===========================================================================

local function HookKeyboardMailTooltip()
	if not ZO_Tooltip or not ZO_Tooltip.LayoutMailAttachment then return end
	ZO_PostHook(ZO_Tooltip, "LayoutMailAttachment", function(self, mailId, attachIndex)
		LWTPriceInfo.SafeCall(function()
			if not mailId or not attachIndex then return end
			local itemLink = GetAttachedItemLink(mailId, attachIndex, LINK_STYLE_DEFAULT)
			if not itemLink or itemLink == "" then return end
			local settings = LWTPriceInfo.vars.gamepad
			local providerPrice = LWTPriceInfo.GetSingleProviderPrice(settings.priceProvider, itemLink)
			if not LWTPriceInfo.IsSellableSingle(providerPrice) then return end
			local _, _, _, stackCount = GetAttachedItemInfo(mailId, attachIndex)
			local multItems = 1
			if settings.stackMultiplier and stackCount and stackCount > 1 then multItems = stackCount end
			local syntheticSettings = { priceProvider = settings.priceProvider, priceType = settings.priceType, stackMultiplier = false }
			local price, count = LWTPriceInfo.GetPriceAndCount(syntheticSettings, itemLink, multItems)
			if not price or price == 0 then return end
			local markerSettings = LWTPriceInfo.GetMarkerSettings()
			local r = LWTPriceInfo.FormatPriceDisplay(price, count, {
				minPrice = markerSettings.minPrice, maxPrice = markerSettings.maxPrice,
				colors = markerSettings.colors, priceShorten = markerSettings.priceShorten,
				showAmount = markerSettings.showAmount, colorAmount = markerSettings.colorAmount,
				countMin = markerSettings.countMin, countMax = markerSettings.countMax,
			})
			local displayText = "|c" .. r.priceHex .. r.priceFormatted .. "|r"
			if r.countDisplay then
				displayText = displayText .. " |c" .. r.countHex .. "[" .. r.countDisplay .. "]|r"
			end
			self:AddLine(displayText, "ZoFontGame", ZO_NORMAL_TEXT)
		end, "Mail tooltip")
	end)
end

local function HookKeyboardTradeTooltip()
	if not ZO_Tooltip or not ZO_Tooltip.LayoutTradeItem then return end
	ZO_PostHook(ZO_Tooltip, "LayoutTradeItem", function(self, tradeWho, tradeIndex)
		LWTPriceInfo.SafeCall(function()
			if not tradeWho or not tradeIndex then return end
			local itemLink = GetTradeItemLink(tradeWho, tradeIndex)
			if not itemLink or itemLink == "" then return end
			local settings = LWTPriceInfo.vars.gamepad
			local providerPrice = LWTPriceInfo.GetSingleProviderPrice(settings.priceProvider, itemLink)
			if not LWTPriceInfo.IsSellableSingle(providerPrice) then return end
			local _, _, stackCount = GetTradeItemInfo(tradeWho, tradeIndex)
			local multItems = 1
			if settings.stackMultiplier and stackCount and stackCount > 1 then multItems = stackCount end
			local syntheticSettings = { priceProvider = settings.priceProvider, priceType = settings.priceType, stackMultiplier = false }
			local price, count = LWTPriceInfo.GetPriceAndCount(syntheticSettings, itemLink, multItems)
			if not price or price == 0 then return end
			local markerSettings = LWTPriceInfo.GetMarkerSettings()
			local r = LWTPriceInfo.FormatPriceDisplay(price, count, {
				minPrice = markerSettings.minPrice, maxPrice = markerSettings.maxPrice,
				colors = markerSettings.colors, priceShorten = markerSettings.priceShorten,
				showAmount = markerSettings.showAmount, colorAmount = markerSettings.colorAmount,
				countMin = markerSettings.countMin, countMax = markerSettings.countMax,
			})
			local displayText = "|c" .. r.priceHex .. r.priceFormatted .. "|r"
			if r.countDisplay then
				displayText = displayText .. " |c" .. r.countHex .. "[" .. r.countDisplay .. "]|r"
			end
			self:AddLine(displayText, "ZoFontGame", ZO_NORMAL_TEXT)
		end, "Trade tooltip")
	end)
end

-- ===========================================================================
-- AwesomeGuildStore: price-delta sort order (plan: guild-store-delta-column T6)
-- ===========================================================================

function LWTPriceInfo.InitializeAGSColumn()
	if agsColumnRegistered or AwesomeGuildStore == nil then return end

	-- SafeCall's first return is the pcall status; its second carries the check
	-- result. The gate must test the result so a v3/missing-API AGS is blocked
	-- (while pcall errors still log and bail via checkOk).
	local checkOk, versionPassed = LWTPriceInfo.SafeCall(function()
		return AwesomeGuildStore.GetAPIVersion() == 4 and AwesomeGuildStore.RegisterSortOrder ~= nil
	end, "AGS version check")
	if not checkOk or not versionPassed then return end

	-- NOT gated on GuildColumnActive(): the sortFunction itself returns 0 when
	-- the column is inactive (correct inert behavior), and gating here would
	-- silently drop the entry if this callback fired before settings existed.
	-- F3 round 5: the single sort order became TWO — "LWT Price (Unit)" (id 101,
	-- per-unit delta, the pre-existing basis) and "LWT Price (Total)" (id 102,
	-- stack-total delta). Both register before the guard flips, so a partially
	-- failed construction retries on the next AFTER_FILTER_SETUP firing.
	AwesomeGuildStore:RegisterCallback(AwesomeGuildStore.callback.AFTER_FILTER_SETUP, function()
		if agsColumnRegistered then return end
		-- F3 round 6 (fix-ags-sort-pipeline): pass a real server sort field for each
		-- order's basis. SortOrderBase defaults (SortOrderBase.lua:35-37) would make
		-- AGS request EVERY page sorted by TIME_LEFT/DOWN (SortFilter.lua:95-97 marks
		-- the sort filter as non-local -> PrepareForSearch/ApplyToSearch ->
		-- SortOrderBase:ApplySortValues SortOrderBase.lua:75-83 -> request:SetSortOrder,
		-- executed in RequestSearchActivity.lua:60-61), i.e. exactly the "server
		-- time-left order" the list visibly kept. AGS's own orders always set a real
		-- serverKey and useLocalDirection=true (SortOrderUnitPrice.lua:26-27).
		local unitOrder = LWTPriceInfo.CreateGuildDeltaSortOrder(101, GetString(LWT_PI_S_GUILD_COLUMN_UNIT), AwesomeGuildStore.class.SortOrderBase.SORT_FIELD_UNIT_PRICE, LWTPriceInfo.AGSDeltaCompareUnit)
		local totalOrder = LWTPriceInfo.CreateGuildDeltaSortOrder(102, GetString(LWT_PI_S_GUILD_COLUMN_TOTAL_ORDER), AwesomeGuildStore.class.SortOrderBase.SORT_FIELD_PURCHASE_PRICE, LWTPriceInfo.AGSDeltaCompareTotal)
		if unitOrder and totalOrder then
			AwesomeGuildStore:RegisterSortOrder(unitOrder)
			AwesomeGuildStore:RegisterSortOrder(totalOrder)
			agsColumnRegistered = true
			-- S1 fix: wrap AGS's sort entry point so every row's delta is
			-- precomputed once BEFORE table.sort runs. The comparator must be a pure
			-- function of its two rows during a sort; provider queries and memo
			-- writes inside comparisons broke strict weak ordering. Only wrapped for
			-- OUR orders (check self.sortOrder.id). One-shot guarded.
			LWTPriceInfo.SafeCall(function()
				local SortFilter = AwesomeGuildStore.class and AwesomeGuildStore.class.SortFilter
				if not SortFilter or not SortFilter.SortLocalResults or lwtAgsSortWrapped then return end
				local origSortLocalResults = SortFilter.SortLocalResults
				SortFilter.SortLocalResults = function(self, items, sortOrderId, direction)
					local active = self.sortOrder and (self.sortOrder.id == 101 or self.sortOrder.id == 102)
					local hadNoData = false
					if active then
						hadNoData = LWTPriceInfo.AGSBuildSortSnapshot(items)
					end
					local ok = LWTPriceInfo.SafeCall(function() return origSortLocalResults(self, items, sortOrderId, direction) end, "AGS sort")
					if not ok then return end
					if active and hadNoData then
						LWTPriceInfo.AGSScheduleResort(self, items)
					end
				end
				lwtAgsSortWrapped = true
			end, "AGS sort wrapper install")
		end
	end)
end

-- Build a per-row delta snapshot for the CURRENT scrollData so the comparator
-- (AGSDeltaCompareBasis) reads only precomputed values during table.sort. One
-- provider query per distinct itemLink via the memo; rows without provider
-- data get the AGS_NO_DATA sentinel (delta 0 IS valid — must be distinguishable
-- from "not priced"). Returns true when any row was unpriced (triggers the
-- bounded self-heal re-sort).
function LWTPriceInfo.AGSBuildSortSnapshot(items)
	agsSortSnapshot = {}
	agsSnapshotActive = true
	local hadNoData = false
	for i = 1, #items do
		local entry = items[i]
		local row = entry and (entry.data or entry)
		if row and not (entry.typeId and entry.typeId > 3) then
			local perUnit = LWTPriceInfo.AGSDeltaForRowSnapshot(row)
			local total = LWTPriceInfo.AGSDeltaForRowTotalSnapshot(row)
			if perUnit == nil and total == nil then
				agsSortSnapshot[row] = LWTPriceInfo.AGS_NO_DATA
				hadNoData = true
			else
				agsSortSnapshot[row] = { perUnit = perUnit, total = total }
			end
		end
	end
	if not hadNoData then
		agsResortAttempts = 0
	end
	return hadNoData
end

-- Debounced, bounded self-heal: when a sort ran with unpriced rows (cold memo),
-- re-run the wrapped sort shortly after so once the provider data is available
-- the delta order actually applies. Capped at 3 attempts per cold streak;
-- reset whenever a fully-priced sort runs.
function LWTPriceInfo.AGSScheduleResort(self, items)
	if agsResortPending then return end
	if agsResortAttempts >= 3 then return end
	if not LWTPriceInfo.GuildColumnActive() then return end
	agsResortPending = true
	zo_callLater(function()
		agsResortPending = false
		agsResortAttempts = agsResortAttempts + 1
		LWTPriceInfo.SafeCall(function()
			AwesomeGuildStore.class.SortFilter.SortLocalResults(self, items)
		end, "AGS delta re-sort")
	end, 300)
end

-- SortOrderBase factory parameterized by (id, label, serverKey, compareFn) so the
-- per-unit and stack-total sort orders share one construction path.
-- F3 round 6: the orders now opt out of the SortOrderBase server defaults
-- (serverKey = SORT_FIELD_TIME_LEFT, useLocalDirection = false, SortOrderBase.lua:35-37)
-- exactly like AGS's own orders do (SortOrderUnitPrice.lua:26-27 sets a real
-- serverKey + useLocalDirection=true; SortOrderTimeLeft.lua:26 sets useLocalDirection=true).
-- Because SortFilter:IsLocal() returns false (SortFilter.lua:95-97), AGS forwards the
-- order's serverKey/direction on every server search (SortFilter.lua:104-108 ->
-- SortOrderBase:ApplySortValues SortOrderBase.lua:75-83 -> FilterRequest.lua:34-36,
-- executed in RequestSearchActivity.lua:60-61); with the base defaults that forced
-- every fetched page into TIME_LEFT/DOWN order, masking the local re-sort.
-- NOTE: the Total label key is LWT_PI_S_GUILD_COLUMN_TOTAL_ORDER, NOT
-- LWT_PI_S_GUILD_COLUMN_TOTAL — that name is taken by the "Show stack total in
-- column" settings checkbox, so re-using it would clobber the settings label.
function LWTPriceInfo.CreateGuildDeltaSortOrder(id, label, serverKey, compareFn)
	local ok, order = LWTPriceInfo.SafeCall(function()
		local SortOrder = AwesomeGuildStore.class.SortOrderBase:Subclass()
		function SortOrder:Initialize()
			AwesomeGuildStore.class.SortOrderBase.Initialize(self, id, label, function(a, b)
				return compareFn(a, b)
			end)
			self.serverKey = serverKey
			self.useLocalDirection = true
		end
		return SortOrder:New()
	end, "AGS sort order construction")
	if not ok then return nil end
	return order
end

-- Pure comparator for AGS (per-unit basis). Sign convention matches AGS's own
-- sort orders (SortOrderTimeLeft.lua / SortOrderUnitPrice.lua:23): return 1
-- when a sorts before b (da < db). AGS applies direction externally (SortFilter
-- SortEntries `result > 0`; GetSortResult swaps the args for DOWN), so both
-- variants share one direction-agnostic core.
function LWTPriceInfo.AGSDeltaCompareUnit(a, b)
	return LWTPriceInfo.AGSDeltaCompareBasis(a, b, LWTPriceInfo.AGSDeltaForRow)
end

-- Pure comparator for AGS (stack-total basis): same structure as the unit
-- variant, but the deltas come from the stack-total row helper.
function LWTPriceInfo.AGSDeltaCompareTotal(a, b)
	return LWTPriceInfo.AGSDeltaCompareBasis(a, b, LWTPriceInfo.AGSDeltaForRowTotal)
end

-- Shared comparator core for both sort bases.
-- F3 round 5 non-monotonic-sort fix: a nil delta no longer returns 0 against an
-- available row. AGS's SortEntries tie-breaks a 0 result by lastSeen (the server
-- time-left order), which interleaved provider-less rows arbitrarily into the
-- delta order and left pairs of nil-delta rows in raw server order — the list
-- looked unsorted ("3096 -> 388 -> 54 -> 2071"). Instead, unavailable rows are
-- pinned after available rows in the ASCENDING (default) order, which is the
-- sign AGS's `result > 0` test needs for "a before b". Note the brief's literal
-- `aAvail and -1 or 1` would pin them FIRST in ascending (verified against
-- SortOrderBase.lua:67-73 + SortFilter.lua:143); it is inverted here. Because
-- AGS applies direction by swapping the args, the unavailable group lands at the
-- START of a descending sort — that is the mathematical limit of a pure pairwise
-- comparator under AGS's arg-swap reversal; the delta run stays monotonic in
-- both directions and unavailable rows are never interleaved with priced rows.
-- F3 round 7 (fix-ags-sort-snapshot): the snapshot (AGSBuildSortSnapshot) makes
-- this function pure during a sort (deltaForRow only reads the snapshot), so
-- table.sort sees a strict weak ordering. Guild-specific rows are treated as
-- unavailable (AGSDeltaRowCore returns nil for them): the old early-return
-- `a.isGuildSpecificItem or b.isGuildSpecificItem -> 0` broke transitivity
-- (cmp(A,G)=0, cmp(G,U)=0, cmp(A,U)=1) — S2.
function LWTPriceInfo.AGSDeltaCompareBasis(a, b, deltaForRow)
	if not LWTPriceInfo.GuildColumnActive() then return 0 end

	local da = deltaForRow(a)
	local db = deltaForRow(b)
	-- Availability differs: available rows sort before unavailable ones.
	local aAvail = da ~= nil
	local bAvail = db ~= nil
	if aAvail ~= bAvail then return aAvail and 1 or -1 end
	-- Both unavailable: tie among themselves (they keep the server time-left
	-- order, which is exactly right for rows we cannot price).
	if not aAvail then return 0 end

	if da < db then return 1 end
	if da > db then return -1 end
	return 0
end

-- Shared per-row core for both sort bases: resolves itemLink + listingPerUnit
-- and returns the memoized provider term. The provider term is shared between
-- the per-unit and stack-total variants (ONE provider query per itemLink, never
-- duplicated); the memo is cleared when the settings fingerprint changes. The
-- listing term is per-row, so duplicate listings NEVER share a delta.
-- Returns itemLink, listingPerUnit, providerTerm; nil when the row has no
-- listing or no provider data.
function LWTPriceInfo.AGSDeltaRowCore(row)
	if not row or row.isGuildSpecificItem then return nil end

	local itemLink = row.itemLink or GetTradingHouseSearchResultItemLink(row.slotIndex)
	local listingPerUnit = row.purchasePricePerUnit or (row.purchasePrice and row.stackCount and row.purchasePrice / row.stackCount)
	if not itemLink or not listingPerUnit then return nil end

	-- Master writs: the memoized provider term is per-voucher (engine divides
	-- by V); the listing side must use the same basis.
	local writVouchers = LWTPriceInfo.GetWritVoucherCount(itemLink)
	if writVouchers then
		listingPerUnit = listingPerUnit / writVouchers
	end

	local fp = LWTPriceInfo.GetGuildDeltaFingerprint(LWTPriceInfo.GetMarkerSettings())
	if fp ~= agsMemoFingerprint then
		agsMemoFingerprint = fp
		agsProviderMemo = {}
	end

	local providerTerm = agsProviderMemo[itemLink]
	if providerTerm == nil then
		local d = LWTPriceInfo.GetGuildSearchDeltaData(itemLink, 0, 1, LWTPriceInfo.GetMarkerSettings())
		-- F3 round 6: store nil (NOT a `false` sentinel) when the provider has no
		-- data. A cached `false` made the FIRST sort's miss permanent for that
		-- itemLink (the memo only cleared on settings-fingerprint change), so every
		-- later sort returned 0 for the row and SortEntries fell back to the
		-- lastSeen tie-breaker (SortFilter.lua:135-142) — the visible list stayed in
		-- server order while the per-row tag (which queries the provider directly at
		-- render time) still displayed deltas. A nil entry is re-queried on the next
		-- sort, so once provider data arrives the delta order actually applies.
		agsProviderMemo[itemLink] = d and d.perUnit
		providerTerm = agsProviderMemo[itemLink]
	end
	if providerTerm == nil then return nil end
	return itemLink, listingPerUnit, providerTerm
end

-- Snapshot reader (per-unit): reads the precomputed snapshot; nil when the row
-- was unpriced or not in the snapshot (fallback below).
function LWTPriceInfo.AGSDeltaForRow(row)
	if agsSnapshotActive then
		local v = agsSortSnapshot[row]
		if v == nil or v == LWTPriceInfo.AGS_NO_DATA then return nil end
		return v.perUnit
	end
	-- Fallback (no wrapper active — e.g. direct calls): old on-the-fly path.
	local itemLink, listingPerUnit, providerTerm = LWTPriceInfo.AGSDeltaRowCore(row)
	if not itemLink then return nil end
	return providerTerm - listingPerUnit
end

-- Snapshot builder (per-unit) used by AGSBuildSortSnapshot.
function LWTPriceInfo.AGSDeltaForRowSnapshot(row)
	local itemLink, listingPerUnit, providerTerm = LWTPriceInfo.AGSDeltaRowCore(row)
	if not itemLink then return nil end
	return providerTerm - listingPerUnit
end

-- Snapshot reader (stack-total).
function LWTPriceInfo.AGSDeltaForRowTotal(row)
	if agsSnapshotActive then
		local v = agsSortSnapshot[row]
		if v == nil or v == LWTPriceInfo.AGS_NO_DATA then return nil end
		return v.total
	end
	local itemLink, listingPerUnit, providerTerm = LWTPriceInfo.AGSDeltaRowCore(row)
	if not itemLink then return nil end
	if not row.stackCount or row.stackCount <= 1 then
		return providerTerm - listingPerUnit
	end
	return (providerTerm - listingPerUnit) * LWTPriceInfo.GetEffectiveStackCount(itemLink, row.stackCount)
end

-- Snapshot builder (stack-total) used by AGSBuildSortSnapshot.
function LWTPriceInfo.AGSDeltaForRowTotalSnapshot(row)
	local itemLink, listingPerUnit, providerTerm = LWTPriceInfo.AGSDeltaRowCore(row)
	if not itemLink then return nil end
	if not row.stackCount or row.stackCount <= 1 then
		return providerTerm - listingPerUnit
	end
	return (providerTerm - listingPerUnit) * LWTPriceInfo.GetEffectiveStackCount(itemLink, row.stackCount)
end

-- ===========================================================================
-- Orchestrators
-- ===========================================================================

function LWTPriceInfo.InstallKeyboardHooks()
	LWTPriceInfo.InitializePlayerInventory()
	LWTPriceInfo.InitializeCraftingUI()

	LWTPriceInfo.HookLootContainers()

	LWTPriceInfo.AddPriceToCraftingTooltip(SMITHING.improvementPanel, 'SetupResultTooltip', GetSmithingImprovedItemLink)
	LWTPriceInfo.AddPriceToCraftingTooltip(SMITHING.creationPanel, 'SetupResultTooltip', GetSmithingPatternResultLink)
	LWTPriceInfo.AddPriceToCraftingTooltip(ZO_Enchanting, 'UpdateTooltip', LWTPriceInfo.GetEnchantResultItemLink)

	LWTPriceInfo.HookKeyboardAlchemy()
	LWTPriceInfo.HookKeyboardProvisioner()

	LWTPriceInfo.HookStoreWindow()
	LWTPriceInfo.HookMailWindow()
	LWTPriceInfo.HookMailAttachmentPrices()
	LWTPriceInfo.HookTradeWindowPrices()
	LWTPriceInfo.HookGuildBank()
	LWTPriceInfo.HookHousingStorage()
	LWTPriceInfo.HookCompanionInventory()
	LWTPriceInfo.HookFenceWindow()
	LWTPriceInfo.HookAntiquityLeads()
	LWTPriceInfo.HookSetCollection()

	HookKeyboardMailTooltip()
	HookKeyboardTradeTooltip()

	LWTPriceInfo.InitializeAGSColumn()
end

function LWTPriceInfo.InstallGamepadHooks()
	LWTPriceInfo.InitializeGamepadSubLabels()
	LWTPriceInfo.InitializeGamepadTooltips()
	LWTPriceInfo.InitializeGamepadCraftingTooltips()
end
