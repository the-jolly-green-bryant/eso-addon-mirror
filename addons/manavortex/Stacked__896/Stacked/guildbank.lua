local addonName, _ = 'Stacked'
local addon = _G[addonName]
local L = addon.L

-- GLOBALS: LINK_STYLE_DEFAULT, BAG_GUILDBANK, BAG_BACKPACK, SI_TOOLTIP_ITEM_NAME, GUILD_PRIVILEGE_BANK_DEPOSIT, KEYBIND_STRIP, ZO_GuildBank
-- GLOBALS: GetItemLink, GetNextGuildBankSlotId, GetSlotStackSize, CheckInventorySpaceSilently, GetBagInfo, ZO_LinkHandler_ParseLink, DoesPlayerHaveGuildPermission, DoesGuildHavePrivilege, TransferToGuildBank, TransferFromGuildBank, GetSelectedGuildBankId, IsItemConsumable, GetItemInstanceId, GetItemInfo
-- GLOBALS: tonumber, table, pairs, ipairs, zo_strformat, type, next

local STATE_IDLE, STATE_PREPARE, STATE_MOVING, STATE_STACKING = 0, 1, 2, 3
local state = STATE_IDLE

local guildPositions, bagPositions = {}, {}
local logs = {
	deposit = {},
	withdraw = {},
}

local numFreedSlots = 0
local currentItemLink, numItemsWithdrawn, numUsedStacks
local dataGuildID, lastGuildID
local emptyTable = {}

local function DoGuildBankStacking() end -- forward declaration

--Helper Functions
---------------------------------------------------------
local function Reset()
	state = STATE_IDLE
	lastGuildID = nil
	dataGuildID = nil

	ZO_ClearTable(bagPositions)
	ZO_ClearTable(guildPositions)
	ZO_ClearTable(logs.withdraw)
	ZO_ClearTable(logs.deposit)
end

local function InitializeProgressFrame(parent)
	local wm = GetWindowManager()
	local progress = wm:CreateControl('$(parent)StackedProgress', parent, CT_CONTROL)
	progress:SetAnchor(CENTER, parent, CENTER, 0, 0)
	progress:SetDimensions(350, 220)
	progress:SetDrawTier(DT_HIGH)

	local bg = wm:CreateControl('$(parent)Bg', progress, CT_TEXTURE)
	bg:SetExcludeFromResizeToFitExtents(true)
	bg:SetAnchorFill(progress)
	bg:SetTexture('EsoUI/Art/Tutorial/tutorial_HUD_windowBG.dds')
	bg:SetTextureCoords(0, 0.83203125, 0, 0.724609375)
	bg:SetHidden(false)

	local action = wm:CreateControl('$(parent)Action', progress, CT_LABEL)
	action:SetAnchor(TOP, progress, TOP, 0, 30)
	action:SetFont('ZoFontKeybindStripDescription')
	action:SetModifyTextType(MODIFY_TEXT_TYPE_UPPERCASE)
	action:SetHidden(false)

	local r, g, b, a = GetInterfaceColor(_G.INTERFACE_COLOR_TYPE_ATTRIBUTE_TOOLTIP)
	action:SetColor(r, g, b, a)

	local icon = wm:CreateControl('$(parent)Icon', progress, CT_TEXTURE)
	icon:SetWidth(64)
	icon:SetHeight(64)
	icon:SetAnchor(TOP, action, BOTTOM, 0, 10)
	-- icon:SetTexture('/esoui/art/icons/icon_missing.dds')
	icon:SetHidden(false)

	local name = wm:CreateControlFromVirtual('$(parent)Name', progress, 'ZO_TooltipIfTruncatedLabel')
	name:SetAnchor(TOP, icon, BOTTOM, 0, 10)
	name:SetFont('ZoFontGame')
	name:SetDimensionConstraints(0, 0, 240, 30)
	name:SetHidden(false)

	return progress
end

local function UpdateProgress(itemLink, template, ...)
	local progress = ZO_GuildBank:GetNamedChild('StackedProgress')
	if not progress then return end

	local icon = itemLink and GetItemLinkInfo(itemLink)
	progress:GetNamedChild('Icon'):SetTexture(icon)
	progress:GetNamedChild('Name'):SetText(L(template, itemLink, ...))

	if addon.GetSetting('showGBStackDetail') then
		addon.Print(L(template, itemLink, ...))
	end
end

local function CanStackGuildBank(guildID)
	local errorMsg
	if state ~= STATE_IDLE then
		errorMsg = L'busy'
	elseif not DoesGuildHavePrivilege(guildID, GUILD_PRIVILEGE_BANK_DEPOSIT) then
		errorMsg = L'not enough members'
	elseif not DoesPlayerHaveGuildPermission(guildID, GUILD_PERMISSION_BANK_DEPOSIT) -- deposit: 15
	  or not DoesPlayerHaveGuildPermission(guildID, GUILD_PERMISSION_BANK_WITHDRAW) then -- withdraw: 16
		errorMsg = L'insufficient permissions'
	elseif not CheckInventorySpaceSilently(2) then
		errorMsg = L'inventory full'
	elseif not dataGuildID or dataGuildID ~= guildID then
		errorMsg = L'not available'
	end
	return not errorMsg, errorMsg
end

local function Pull(slot, itemLink, count)
	TransferFromGuildBank(slot)
	local data = logs.withdraw[slot]
	if data then
		UpdateProgress(data[1], 'withdraw item', data[2])
	elseif itemLink then
		logs.withdraw[slot] = {itemLink, count}
		UpdateProgress(itemLink, 'withdraw item', count)
	end
end
local function Push(bag, slot, key)
	local itemLink = GetItemLink(bag, slot)
	local count = GetSlotStackSize(bag, slot)

	TransferToGuildBank(bag, slot)
	if key then
		logs.deposit[slot] = key
	end
	UpdateProgress(itemLink, 'deposit item', count)
end

--Keybindings
---------------------------------------------------------
local keybind = {
	name = L'Stack',
	keybind = 'STACKED_STACK',
	callback = StackGuildBank,
	enabled = function()
		return CanStackGuildBank(GetSelectedGuildBankId())
	end,
	alignment = KEYBIND_STRIP_ALIGN_LEFT,
}
local function ShowKeybinds() KEYBIND_STRIP:AddKeybindButton(keybind) end
local function HideKeybinds() KEYBIND_STRIP:RemoveKeybindButton(keybind) end

ZO_PreHookHandler(ZO_GuildBank, 'OnShow', ShowKeybinds)
ZO_PreHookHandler(ZO_GuildBank, 'OnHide', HideKeybinds)
--called when a guild bank is selected. used to disable button while waiting for data
local callback = ZO_SelectGuildBankDialogAccept.callback
ZO_SelectGuildBankDialogAccept.callback = function(...)
	callback(...)
	KEYBIND_STRIP:UpdateKeybindButton(keybind)
end

local function SetState(stateConstant, ...)
	state = stateConstant

	-- ZO_StatusBar_SmoothTransition(statusbar, index, total, FORCE_VALUE)
	local progress = ZO_GuildBank:GetNamedChild('StackedProgress') or InitializeProgressFrame(ZO_GuildBank)
	if state == STATE_STACKING then
		progress:SetHidden(false)
		progress:GetNamedChild('Action'):SetText(L'Stacking')
	elseif state == STATE_MOVING then
		progress:SetHidden(false)
		progress:GetNamedChild('Action'):SetText(L'Moving')
	elseif state == STATE_IDLE then
		progress:SetHidden(true)
		addon.Print(L('guild bank state '..stateConstant, ...))
		lastGuildID = nil
	end

	KEYBIND_STRIP:UpdateKeybindButton(keybind)
end

-- Main Logic
-----------------------------------------------------------
local function DepositGuildBankItems(eventID, ...)
	CALLBACK_MANAGER:UnregisterCallback(STACKED_CONTAINER_COMPLETED, DepositGuildBankItems)

	if not currentItemLink then return end
	local moveTarget = addon.GetSetting('moveTargetGB')

	local _, numSlots = GetBagInfo(BAG_BACKPACK)
	for slot = 0, numSlots do
		local itemLink = GetItemLink(BAG_BACKPACK, slot, LINK_STYLE_DEFAULT)
		local key      = GetItemInstanceId(BAG_BACKPACK, slot)

		if itemLink == currentItemLink and not (bagPositions[key] and addon.Find(bagPositions[key], slot)) then
			local _, count, _, _, locked = GetItemInfo(BAG_BACKPACK, slot)
			Push(BAG_BACKPACK, slot, key)

			numUsedStacks = numUsedStacks - 1
			numItemsWithdrawn = numItemsWithdrawn - count

			-- wait for event EVENT_GUILD_BANK_ITEM_ADDED
			return
		end
	end

	numFreedSlots = numFreedSlots + numUsedStacks
	currentItemLink = nil
	DoGuildBankStacking()
end
function DoGuildBankStacking(eventID)
	if state == STATE_IDLE then return end

	-- choose an item to restack
	local slot, newItem
	for key, slots in pairs(guildPositions) do
		if eventID or not CheckInventorySpaceSilently(1) then
			-- find item that was handled before
			for i, gBankSlot in ipairs(slots) do
				if GetSlotStackSize(BAG_GUILDBANK, gBankSlot) == 0 then
					table.remove(guildPositions[key], i)
					if #guildPositions[key] < 1 then
						-- we've taken all stacks of item
						guildPositions[key] = nil

						-- restack in backpack but ignore items we had ourselves
						addon.StackContainer(BAG_BACKPACK, key, true, bagPositions[key])
						CALLBACK_MANAGER:RegisterCallback(STACKED_CONTAINER_COMPLETED, DepositGuildBankItems)

						-- wait for DepositGuildBankItems to call DoGuildBankStacking again
						return
					else
						slot = slots[1]
						break
					end
				end
			end
			-- found next stack for this item
			if slot then break end
		else
			-- first item wins
			slot = slots[1]
			newItem = key
			break
		end
	end

	if slot then
		local itemLink = GetItemLink(BAG_GUILDBANK, slot, LINK_STYLE_DEFAULT)
		local count, stackSize = GetSlotStackSize(BAG_GUILDBANK, slot)
		if newItem then
			local numStacks, totalCount = #guildPositions[newItem], 0
			for i, slotID in ipairs(guildPositions[newItem]) do
				totalCount = totalCount + GetSlotStackSize(BAG_GUILDBANK, slotID)
			end

			if addon.GetSetting('showGBStackDetail') then
				addon.Print(L('stacking guildbank item', itemLink, totalCount, numStacks))
			end

			currentItemLink = itemLink
			numItemsWithdrawn = 0
			numUsedStacks = 0
		end

		if itemLink ~= '' and count > 0 and count < stackSize then
			Pull(slot, itemLink, count)

			-- wait for event EVENT_GUILD_BANK_ITEM_REMOVED
			return
		end
	elseif not currentItemLink then
		SetState(STATE_IDLE, numFreedSlots)
		return
	end
end

local function StackGuildBank(guildID)
	local guildID = type(guildID) == 'number' and guildID or GetSelectedGuildBankId() -- internal id of selected guild
	if lastGuildID == guildID or state ~= STATE_IDLE then return end

	local canStackGuildBank, errorMsg = CanStackGuildBank(guildID)
	if errorMsg then
		addon.Print(errorMsg)
		return
	end

	lastGuildID = guildID
	state = STATE_PREPARE
	numFreedSlots = 0

	-- scan guild bank
	ZO_ClearTable(guildPositions)
	local slot = nil
	while true do
		slot = GetNextGuildBankSlotId(slot)
		if not slot then break end

		local itemLink = GetItemLink(BAG_GUILDBANK, slot, LINK_STYLE_DEFAULT)
		local itemID, key
		if itemLink ~= '' then
			_, _, _, itemID = ZO_LinkHandler_ParseLink(itemLink)
			itemID = itemID and tonumber(itemID)
			key = GetItemInstanceId(BAG_GUILDBANK, slot)
		end

		-- don't touch if slot is empty or item is excluded
		if itemID and not addon.GetExcluded(BAG_GUILDBANK, slot, itemID) then
			local count, stackSize = GetSlotStackSize(BAG_GUILDBANK, slot)
			if count < stackSize then
				-- store location
				if not guildPositions[key] then
					guildPositions[key] = {}
				end
				table.insert(guildPositions[key], slot)
			end
		end
	end

	-- scan inventory
	ZO_ClearTable(bagPositions)
	local _, numSlots = GetBagInfo(BAG_BACKPACK)
	for slot = 0, numSlots do
		local itemLink = GetItemLink(BAG_BACKPACK, slot, LINK_STYLE_DEFAULT)
		local key = GetItemInstanceId(BAG_BACKPACK, slot)
		local itemID
		if itemLink ~= '' then
			_, _, _, itemID = ZO_LinkHandler_ParseLink(itemLink)
			itemID = itemID and tonumber(itemID)
		end

		-- we only need items that are also in our guild bank
		if itemID and guildPositions[key] then
			if not bagPositions[key] then
				bagPositions[key] = {}
			end
			table.insert(bagPositions[key], slot)
		end
	end

	ZO_ClearTable(logs.withdraw)
	ZO_ClearTable(logs.deposit)
	local moveTarget = addon.GetSetting('moveTargetGB')
	for key, slots in pairs(guildPositions) do
		local keepSingleStacks = false

		-- handle merging into backpack/guild bank
		if moveTarget == L'backpack' then
			-- have item in bags, pull from guild bank
			local capacity = 0
			for _, slot in pairs(bagPositions[key] or emptyTable) do
				-- TODO: this will still use up to the same number of stacks if backpack is untidy
				local count, stackSize = GetSlotStackSize(BAG_BACKPACK, slot)
				capacity = capacity + (stackSize - count)
			end

			local itemLink = GetItemLink(BAG_GUILDBANK, slots[1])
			for index, slot in pairs(slots) do
				local count = GetSlotStackSize(BAG_GUILDBANK, slot)
				-- TODO: this is a rather dumb FCFS logic
				if count <= capacity then
					if state == STATE_PREPARE then
						SetState(STATE_MOVING, L'guildbank', L'backpack')
						Pull(slot, itemLink, count)
					else
						logs.withdraw[slot] = {itemLink, count}
					end
					capacity = capacity - count
					-- TODO: how to add withdrawn items to bagPositions (to avoid depositing again after stacking)

					-- we take this item, no need to stack it
					guildPositions[key][index] = nil
				end
			end
		elseif moveTarget == L'guildbank' then
			-- deposit (fitting) bag items to guild bank. they'll be stacked later
			local capacity = 0
			for _, slot in pairs(slots) do
				-- TODO: this will use up to the same number of stacks if guild bank is untidy
				local count, stackSize = GetSlotStackSize(BAG_GUILDBANK, slot)
				capacity = capacity + (stackSize - count)
			end

			for index, slot in pairs(bagPositions[key] or emptyTable) do
				local count = GetSlotStackSize(BAG_BACKPACK, slot)
				-- TODO: this is a rather dumb FCFS logic
				if count <= capacity then
					if state == STATE_PREPARE then
						SetState(STATE_MOVING, L'backpack', L'guildbank')
						Push(BAG_BACKPACK, slot, key)
					else
						logs.deposit[slot] = key
					end
					capacity = capacity - count

					-- pretend we don't own this item any more
					bagPositions[key][index] = nil

					-- needs to be stacked, even if there's only 1 stack in guild bank now
					keepSingleStacks = true
				end
			end
			if bagPositions[key] and #bagPositions[key] < 1 then
				bagPositions[key] = nil
			end
		end

		if #guildPositions[key] < 2 and not keepSingleStacks then
			-- this item no longer needs to be stacked
			ZO_ClearTable(guildPositions[key])
			guildPositions[key] = nil
		end
	end

	if state == STATE_PREPARE then
		-- stack right now!
		SetState(STATE_STACKING)
		DoGuildBankStacking()
	-- else: wait for moving to finish
	end
end

-- Slash Commands
-----------------------------------------------------------
addon.slashCommandHelp = (addon.slashCommandHelp or '') .. '\n' .. L'/stackgb'
SLASH_COMMANDS['/stackgb'] = StackGuildBank

-- Events
-----------------------------------------------------------
local em = GetEventManager()
em:RegisterForEvent(addonName, EVENT_GUILD_BANK_ITEM_ADDED, function(eventID, slot)
	if state == STATE_IDLE then return end

	local count    = GetSlotStackSize(BAG_GUILDBANK, slot)
	local itemLink = GetItemLink(BAG_GUILDBANK, slot)
	local key      = GetItemInstanceId(BAG_GUILDBANK, slot)
	local inventorySlot

	-- item was deposited, compare to logs
	for bagSlot, itemKey in pairs(logs.deposit) do
		if itemKey == key and GetItemLink(BAG_BACKPACK, bagSlot) == '' then
			inventorySlot = bagSlot
			-- remove from logs
			logs.deposit[bagSlot] = nil
			break
		end
	end

	if state == STATE_STACKING then
		--DepositGuildBankItems(eventID)
	elseif state == STATE_MOVING then
		addon.Print( L('moved item', itemLink, count,
			addon.GetSlotText(BAG_BACKPACK, inventorySlot), addon.GetSlotText(BAG_GUILDBANK, slot)) )
		-- add it to guildPositions so we stack it properly
		table.insert(guildPositions[key], slot)

		local k = next(logs.deposit)
		if k then
			-- more deposits to do
			Push(BAG_BACKPACK, k)
		elseif not next(logs.withdraw) then
			-- stack right now!
			SetState(STATE_STACKING)
			DoGuildBankStacking()
		end
	end
end)
em:RegisterForEvent(addonName, EVENT_GUILD_BANK_ITEM_REMOVED, function(eventID, slot)
	if state == STATE_IDLE then return end
	local itemLink, count

	-- item was withdrawn, compare to logs
	local data = logs.withdraw[slot]
	if data then
		itemLink, count = data[1], data[2]
		-- remove from logs
		data[1], data[2] = nil, nil
		logs.withdraw[slot] = nil
	end

	if state == STATE_STACKING then
		if itemLink then
			numItemsWithdrawn = numItemsWithdrawn + (count or 1)
			numUsedStacks = numUsedStacks + 1
		else
			-- let's check if this is an item we had plans for
			local matchedKey = nil
			for key, slots in pairs(guildPositions) do
				for index, gbSlot in pairs(slots) do
					if slot == gbSlot then
						-- nooooo! someone took our item
						matchedKey = key
						guildPositions[key][index] = nil
						break
					end
				end
				if matchedKey then break end
			end
			if matchedKey and #guildPositions[matchedKey] < 2 then
				ZO_ClearTable(guildPositions[matchedKey])
				guildPositions[matchedKey] = nil
			end
		end
		DoGuildBankStacking(eventID)
	elseif state == STATE_MOVING then
		if itemLink then
			addon.Print( L('moved item', itemLink, count or 1,
				addon.GetSlotText(BAG_GUILDBANK, slot), addon.GetSlotText(BAG_BACKPACK)) )
			-- TODO: how to add withdrawn items to bagPositions (to avoid depositing again after stacking)
		end

		local k = next(logs.withdraw)
		if k then
			-- more withdrawals to do
			Pull(k)
		elseif not next(logs.deposit) then
			-- stack right now!
			SetState(STATE_STACKING)
			DoGuildBankStacking()
		end
	end
end)
em:RegisterForEvent(addonName, EVENT_GUILD_BANK_TRANSFER_ERROR, function(evendID, errorMsg)
	if errorMsg then errorMsg = GetString(_G['SI_GLOBALERRORCODE'..errorMsg]) or errorMsg end
	if state == STATE_STACKING then
		addon.Print(L('failed stacking guildbank item', currentItemLink, errorMsg))
		currentItemLink = nil
		DoGuildBankStacking()
	elseif state == STATE_MOVING then
		addon.Print(L'failed moving guildbank item', errorMsg)
		Reset()
		StackGuildBank()
	end
end)
em:RegisterForEvent(addonName, EVENT_GUILD_BANK_ITEMS_READY, function()
	local guildID = GetSelectedGuildBankId() -- internal id of selected guild
	dataGuildID = guildID
	KEYBIND_STRIP:UpdateKeybindButton(keybind)
	if addon.GetSetting('guildbank') and addon.GetSetting('stackContainer'..BAG_GUILDBANK..guildID) then StackGuildBank() end
end)
