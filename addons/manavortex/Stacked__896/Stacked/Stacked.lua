local addonName, addon, _ = 'Stacked', {}
_G[addonName] = addon

-- GLOBALS: _G, LibStub, ZO_SavedVars, SLASH_COMMANDS, LINK_STYLE_DEFAULT, ITEM_LINK_TYPE, BAG_WORN, BAG_BACKPACK, BAG_BANK, BAG_GUILDBANK, BAG_BUYBACK, BAG_TRANSFER, SI_TOOLTIP_ITEM_NAME
-- GLOBALS: EVENT_TRADE_SUCCEEDED, EVENT_OPEN_BANK, EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS, EVENT_CLOSE_GUILD_BANK, EVENT_GUILD_BANK_ITEMS_READY, EVENT_GUILD_BANK_ITEM_ADDED, EVENT_GUILD_BANK_ITEM_REMOVED
-- GLOBALS: GetSlotStackSize, GetItemLink, CallSecureProtected, ClearCursor, GetMaxBags, GetBagInfo, LocalizeString, GetString, ZO_LinkHandler_CreateLink, ZO_LinkHandler_ParseLink, TransferToGuildBank, TransferFromGuildBank, GetSelectedGuildBankId, DoesPlayerHaveGuildPermission, CheckInventorySpaceSilently, GetNextGuildBankSlotId, SplitString, IsItemConsumable
-- GLOBALS: string, math, pairs, select, tostring, type, table, tonumber, ipairs, zo_strformat, zo_strtrim, d, info

function addon.Find(tab, value)
	for k, v in pairs(tab) do
		if v == value then
			return true
		end
	end
end

function addon.Print(format, ...)
	local text
	if type(info) == 'function' then
		info(format, ...)
		return
	elseif type(format) == 'string' and format:find('%%[1234567890]*[sd]') then
		text = format:format(...)
	else
		text = zo_strjoin(', ', format, ...)
	end
	-- CHAT_SYSTEM:AddMessage('|cFFFFFFStacked|r '..text)
	if text then CHAT_SYSTEM:AddMessage(text) end
end

addon.L = setmetatable({}, {
	__index = function(self, key)
		local text = rawget(self, key)
		return text or key -- and LocalizeString('<<1>>', text)
	end,
	__call = function(self, key, ...)
		local text = self[key]
		return LocalizeString(tostring(text), ...)
	end,
})
local L = addon.L

ZO_CreateStringId('SI_BINDING_NAME_STACKED_STACK', L'Stack')

-- --------------------------------------------------------
--  Setup
-- --------------------------------------------------------
local function Initialize(eventCode, arg1, ...)
	if arg1 ~= addonName then return end
	EVENT_MANAGER:UnregisterForEvent(addonName, EVENT_ADD_ON_LOADED)

	-- TODO: split settings & pull from their modules
	addon.db = ZO_SavedVars:New(addonName..'DB', 3, nil, {
		-- default settings
		showMessages = true,
		showSlot = false,
		showGBStackDetail = false,
		exclude = {
			[30357] = true, -- lockpicks
		},
		excludeItemSaver = false,

		-- containers
		['stackContainer'..BAG_BACKPACK] = true,
		['stackContainer'..BAG_BANK] = true,
		['stackContainer'..BAG_GUILDBANK..'1'] = false,
		['stackContainer'..BAG_GUILDBANK..'2'] = false,
		['stackContainer'..BAG_GUILDBANK..'3'] = false,
		['stackContainer'..BAG_GUILDBANK..'4'] = false,
		['stackContainer'..BAG_GUILDBANK..'5'] = false,

		-- move stacks
		moveTarget = L'none',
		moveTargetGB = L'none',

		-- events
		trade = true,
		mail = true,
		bank = true,
		guildbank = false,
	})

	-- fix items being indexed by strings instead of numbers
	for itemID, value in pairs(addon.db.exclude) do
		if type(itemID) ~= 'number' then
			addon.db.exclude[ tonumber(itemID) ] = value
			addon.db.exclude[itemID] = nil
		end
	end

	addon.CreateSlashCommands()
	addon.CreateSettings()
end
GetEventManager():RegisterForEvent(addonName, EVENT_ADD_ON_LOADED, Initialize)
