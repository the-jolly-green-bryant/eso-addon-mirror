TelVarSaver = TelVarSaver or {}
local TVS = TelVarSaver

-- =============================================================================
-- Sigil of Imperial Retreat reminder + auto-purchase
-- =============================================================================
-- The reminder is a temporary center-screen announcement (CSA) shown on each
-- Imperial City load screen when you're low on Sigils - it fades on its own.
TVS.SIGIL_ITEM_ID = 68347

-- Last known icon for the Sigil; resolved from the item id (see GetSigilIcon).
TVS.SigilIconPath = "EsoUI/Art/currency/currency_telvar_32.dds"

-- -----------------------------------------------------------------------------
-- Inventory / icon
-- -----------------------------------------------------------------------------

-- Count Sigils carried in the backpack.
function TVS.CountSigils()
	if TVS.SIGIL_ITEM_ID == 0 then return 0 end
	local bag = BAG_BACKPACK
	local total = 0
	for slot = 0, GetBagSize(bag) - 1 do
		if GetItemId(bag, slot) == TVS.SIGIL_ITEM_ID then total = total + GetSlotStackSize(bag, slot) end
	end
	return total
end

-- Resolve the Sigil's icon directly from its item id (works even when you have
-- none in your bags). A minimal item link is enough for an icon lookup; the
-- engine fills in the unused fields. Falls back to the last cached icon.
function TVS.GetSigilIcon()
	if TVS.SIGIL_ITEM_ID ~= 0 and type(GetItemLinkIcon) == "function" then
		local link = string.format("|H1:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", TVS.SIGIL_ITEM_ID)
		local icon = GetItemLinkIcon(link)
		if icon and icon ~= "" then
			TVS.SigilIconPath = icon
			return icon
		end
	end
	return TVS.SigilIconPath
end

-- -----------------------------------------------------------------------------
-- On-screen reminder (center-screen announcement)
-- -----------------------------------------------------------------------------

-- Sound options offered in the settings dropdown. `key` indexes the global
-- SOUNDS table; `label` is what the user sees.
TVS.SIGIL_SOUND_CHOICES = {
	{ label = "Notification", key = "NEW_TIMED_NOTIFICATION" },
	{ label = "Book acquired", key = "BOOK_ACQUIRED" },
	{ label = "Objective discovered", key = "OBJECTIVE_DISCOVERED" },
	{ label = "Quest complete", key = "QUEST_COMPLETED" },
	{ label = "Achievement", key = "ACHIEVEMENT_AWARDED" },
	{ label = "Group join", key = "GROUP_JOIN" },
	{ label = "Duel start", key = "DUEL_START" },
}

-- Resolve the sound id the reminder should play (SOUNDS.NONE when disabled).
function TVS.GetSigilReminderSound()
	if TVS.SV.SigilReminderSoundEnabled ~= true then return SOUNDS.NONE end
	local sound = TVS.SV.SigilReminderSound and SOUNDS[TVS.SV.SigilReminderSound]
	return sound or SOUNDS.NONE
end

-- The configured reminder colour as a "RRGGBB" hex string for inline text markup.
function TVS.GetSigilReminderColorHex()
	local c = TVS.SV.SigilReminderColor or TVS.defaults.SigilReminderColor
	local r = math.floor((c[1] or 1) * 255 + 0.5)
	local g = math.floor((c[2] or 1) * 255 + 0.5)
	local b = math.floor((c[3] or 1) * 255 + 0.5)
	return string.format("%02x%02x%02x", r, g, b)
end

-- Show the reminder now, if conditions are met. Safe to call anytime.
function TVS.ShowSigilReminder()
	if TVS.SV.SigilReminderEnabled ~= true then return end
	if IsInImperialCity() ~= true then return end
	local isInSafeZone = TVS.InSafeZone() == true
	if (TVS.SV.SigilReminderHideInSafeZone == true) and isInSafeZone then return end
	if (TVS.SV.SigilReminderHideInNonSafeZone == true) and (isInSafeZone == false) then return end
	if CENTER_SCREEN_ANNOUNCE == nil then return end

	local count = TVS.CountSigils()
	if count >= TVS.SV.SigilReminderThreshold then return end

	local icon = TVS.GetSigilIcon()
	local iconText = (icon and icon ~= "") and (zo_iconFormat(icon, 40, 40) .. " ") or ""

	local hex = TVS.GetSigilReminderColorHex()
	local title, subtitle
	if count <= 0 then
		title = iconText .. "|c" .. hex .. "Out of Sigils of Imperial Retreat|r"
		subtitle = "Buy more from an Imperial City district vendor"
	else
		title = iconText .. "|c" .. hex .. "Low on Sigils of Imperial Retreat: " .. tostring(count) .. "|r"
		subtitle = "Restock from an Imperial City district vendor"
	end

	local lifespanMs = (TVS.SV.SigilReminderDurationS or TVS.defaults.SigilReminderDurationS) * 1000

	local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, TVS.GetSigilReminderSound())
	messageParams:SetText(title, subtitle)
	messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_SYSTEM_BROADCAST)
	messageParams:SetLifespanMS(lifespanMs)
	CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
end

-- Shown on each load screen. Delayed slightly so it isn't lost amongst the
-- other announcements that fire right as a zone finishes loading.
function TVS.OnPlayerActivatedSigil() zo_callLater(TVS.ShowSigilReminder, 1000) end

-- -----------------------------------------------------------------------------
-- Auto-purchase at vendor (tops up to the configured target)
-- -----------------------------------------------------------------------------

function TVS.OnSigilStoreOpen()
	if TVS.SV.SigilAutoBuyEnabled ~= true then return end
	if TVS.SIGIL_ITEM_ID == 0 then return end
	if IsInImperialCity() ~= true then return end

	local target = TVS.SV.SigilDesiredAmount
	local current = TVS.CountSigils()
	local needed = target - current
	if needed <= 0 then return end

	local numStore = GetNumStoreItems()
	for i = 1, numStore do
		local link = GetStoreItemLink(i, LINK_STYLE_DEFAULT)
		if link and GetItemLinkItemId(link) == TVS.SIGIL_ITEM_ID then
			local _, _, _, _, _, meetsRequirementsToBuy, _, _, _, currencyType1, currencyQuantity1 = GetStoreEntryInfo(i)

			if meetsRequirementsToBuy == false then
				TVS.dtvs("Can't auto-buy Sigils of Imperial Retreat (requirements or currency not met).", "notifySigil")
				return
			end

			local qty = needed
			local maxBuyable = GetStoreEntryMaxBuyable(i)
			if (type(maxBuyable) == "number") and (maxBuyable >= 0) and (maxBuyable < qty) then qty = maxBuyable end
			if qty <= 0 then return end

			-- Safety caps (only meaningful when the Sigil is bought with Alliance Points).
			local unitCost = currencyQuantity1 or 0
			local totalCost = unitCost * qty
			if currencyType1 == CURT_ALLIANCE_POINTS then
				local currentAP = GetCarriedCurrencyAmount(CURT_ALLIANCE_POINTS)
				local minReserve = TVS.SV.SigilMinAPReserve or 0
				local maxSpend = TVS.SV.SigilMaxSpendAP or 0

				local remainingAP = currentAP - totalCost
				if (minReserve > 0) and (remainingAP < minReserve) then
					TVS.dtvs(
						"Skipped Sigil auto-buy: purchase would leave " .. tostring(remainingAP)
							.. " AP, below your minimum (" .. tostring(minReserve) .. ").",
						"notifySigil"
					)
					return
				end
				if (maxSpend > 0) and (totalCost > maxSpend) then
					TVS.dtvs(
						"Skipped Sigil auto-buy: cost " .. tostring(totalCost) .. " AP exceeds your cap (" .. tostring(maxSpend) .. ").",
						"notifySigil"
					)
					return
				end
				if totalCost > currentAP then
					TVS.dtvs("Skipped Sigil auto-buy: not enough Alliance Points.", "notifySigil")
					return
				end
			end

			BuyStoreItem(i, qty)
			TVS.dtvs(
				"Auto-bought |c8080ff" .. tostring(qty) .. "|r Sigil(s) of Imperial Retreat (now "
					.. tostring(current + qty) .. "/" .. tostring(target) .. ")",
				"notifySigil"
			)
			return
		end
	end
end

-- -----------------------------------------------------------------------------
-- Bank withdraw (tops up carried Sigils to the target on opening the bank)
-- -----------------------------------------------------------------------------

-- Move a stack (or part of one) from a bank bag into the backpack. RequestMoveItem
-- is a protected function, so it must be routed through CallSecureProtected when
-- protected (the approach used by bank addons like Lazy Writ Crafter).
local function MoveSigilStackToBackpack(sourceBag, sourceSlot, destSlot, quantity)
	if IsProtectedFunction("RequestMoveItem") then
		CallSecureProtected("RequestMoveItem", sourceBag, sourceSlot, BAG_BACKPACK, destSlot, quantity)
	else
		RequestMoveItem(sourceBag, sourceSlot, BAG_BACKPACK, destSlot, quantity)
	end
end

function TVS.WithdrawSigilsFromBank()
	if TVS.SV.SigilBankWithdraw ~= true then return end
	if TVS.SIGIL_ITEM_ID == 0 then return end
	if IsInImperialCity() ~= true then return end

	local target = TVS.SV.SigilDesiredAmount
	local needed = target - TVS.CountSigils()
	if needed <= 0 then return end

	-- Pre-collect destination slots so each move targets a known slot
	-- (moves are processed asynchronously, so we can't re-query after each one).
	local destSlots = {}
	for slot = 0, GetBagSize(BAG_BACKPACK) - 1 do
		if GetItemId(BAG_BACKPACK, slot) == TVS.SIGIL_ITEM_ID then
			local stack, maxStack = GetSlotStackSize(BAG_BACKPACK, slot)
			if maxStack and stack and stack < maxStack then destSlots[#destSlots + 1] = { slot = slot, room = maxStack - stack } end
		end
	end
	for slot = 0, GetBagSize(BAG_BACKPACK) - 1 do
		if GetItemName(BAG_BACKPACK, slot) == "" then destSlots[#destSlots + 1] = { slot = slot } end
	end

	local withdrawn = 0
	local bankBags = { BAG_BANK, BAG_SUBSCRIBER_BANK }
	for _, bankBag in ipairs(bankBags) do
		for slot = 0, GetBagSize(bankBag) - 1 do
			if needed <= 0 then break end
			if GetItemId(bankBag, slot) == TVS.SIGIL_ITEM_ID then
				local stack = GetSlotStackSize(bankBag, slot)
				if stack > 0 then
					local dest = destSlots[1]
					if dest == nil then
						TVS.dtvs("Couldn't withdraw all Sigils: backpack is full.", "notifySigil")
						needed = 0
						break
					end
					local moveQty = math.min(stack, needed, dest.room or stack)
					MoveSigilStackToBackpack(bankBag, slot, dest.slot, moveQty)
					needed = needed - moveQty
					withdrawn = withdrawn + moveQty
					if dest.room then
						dest.room = dest.room - moveQty
						if dest.room <= 0 then table.remove(destSlots, 1) end
					else
						table.remove(destSlots, 1)
					end
				end
			end
		end
		if needed <= 0 then break end
	end

	if withdrawn > 0 then
		TVS.dtvs(
			"Withdrew |c8080ff" .. tostring(withdrawn) .. "|r Sigil(s) of Imperial Retreat from the bank.",
			"notifySigil"
		)
	end
end

-- -----------------------------------------------------------------------------
-- Use Sigil of Imperial Retreat (keybind)
-- -----------------------------------------------------------------------------

-- The first backpack slot holding a Sigil, or nil.
function TVS.FindSigilInventorySlot()
	if TVS.SIGIL_ITEM_ID == 0 then return nil end
	local bag = BAG_BACKPACK
	for slot = 0, GetBagSize(bag) - 1 do
		if GetItemId(bag, slot) == TVS.SIGIL_ITEM_ID then return bag, slot end
	end
	return nil
end

-- The quickslot-wheel action slot holding a Sigil, or nil.
function TVS.FindSigilQuickslot()
	if TVS.SIGIL_ITEM_ID == 0 then return nil end
	for slotIndex = 1, 20 do
		local link = GetSlotItemLink(slotIndex, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
		if link and link ~= "" and GetItemLinkItemId(link) == TVS.SIGIL_ITEM_ID then return slotIndex end
	end
	return nil
end

-- Keybind handler: require the Sigil to be on the quickslot wheel, then make it
-- the active quickslot and use it. Addon code is "insecure", so UseItem (a
-- protected function) must be routed through CallSecureProtected - the same
-- approach used for the bank's RequestMoveItem.
function TVS.UseSigilOfRetreat()
	if IsInImperialCity() ~= true then
		TVS.dtvs("Sigils of Imperial Retreat can only be used in Imperial City.", "notifySigil")
		return
	end

	local quickslotIndex = TVS.FindSigilQuickslot()
	if quickslotIndex == nil then
		TVS.dtvs("No Sigil of Imperial Retreat on your quickslot wheel - slot one first.", "notifySigil")
		return
	end

	local bag, slot = TVS.FindSigilInventorySlot()
	if bag == nil then
		TVS.dtvs("No Sigil of Imperial Retreat in your bags.", "notifySigil")
		return
	end

	SetCurrentQuickslot(quickslotIndex)
	if IsProtectedFunction("UseItem") then
		CallSecureProtected("UseItem", bag, slot)
	else
		UseItem(bag, slot)
	end
end

-- Show the reminder on demand (the settings "Preview reminder" button), ignoring
-- the IC / safe-zone / threshold gates so it always appears.
function TVS.TestSigilReminder()
	if CENTER_SCREEN_ANNOUNCE == nil then return end
	local icon = TVS.GetSigilIcon()
	local iconText = (icon and icon ~= "") and (zo_iconFormat(icon, 40, 40) .. " ") or ""
	local hex = TVS.GetSigilReminderColorHex()
	local lifespanMs = (TVS.SV.SigilReminderDurationS or TVS.defaults.SigilReminderDurationS) * 1000
	local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, TVS.GetSigilReminderSound())
	messageParams:SetText(iconText .. "|c" .. hex .. "Sigil reminder preview|r", "You currently carry " .. tostring(TVS.CountSigils()))
	messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_SYSTEM_BROADCAST)
	messageParams:SetLifespanMS(lifespanMs)
	CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
end

-- -----------------------------------------------------------------------------
-- Setup (called from TVS.onLoad)
-- -----------------------------------------------------------------------------
function TVS.SetupSigilReminder()
	-- Remind on each load screen (fires after a zone finishes loading).
	EVENT_MANAGER:RegisterForEvent(TVS.name .. "_SigilReminder", EVENT_PLAYER_ACTIVATED, TVS.OnPlayerActivatedSigil)

	-- Auto-purchase when a vendor selling Sigils is opened.
	EVENT_MANAGER:RegisterForEvent(TVS.name .. "_SigilAutoBuy", EVENT_OPEN_STORE, TVS.OnSigilStoreOpen)

	-- Withdraw Sigils from the bank to reach the target when the bank opens.
	-- (Separate event name so it doesn't clobber the Tel Var bank handler.)
	EVENT_MANAGER:RegisterForEvent(TVS.name .. "_SigilBankWithdraw", EVENT_OPEN_BANK, TVS.WithdrawSigilsFromBank)
end
