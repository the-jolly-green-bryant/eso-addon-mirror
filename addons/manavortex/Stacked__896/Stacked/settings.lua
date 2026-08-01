local addonName, _ = 'Stacked'
local addon = _G[addonName]
local L = addon.L

-- GLOBALS: LibStub, SLASH_COMMANDS, BAG_BANK, BAG_BACKPACK, BAG_GUILDBANK, ITEM_LINK_TYPE
-- GLOBALS: ZO_LinkHandler_CreateLink, ZO_LinkHandler_ParseLink, GetString
-- GLOBALS: string, type, pairs, tostring, tonumber, zo_strtrim

local function isNumber(text) return text:match("^(-?%d-%.*%d-)$") end

local function GetLinkFromID(linkID, linkType)
	local stub = string.rep(':0', 19)
	return ZO_LinkHandler_CreateLink(linkID, nil, linkType or ITEM_LINK_TYPE, linkID .. stub)
end

local function GetSetting(setting)
	local value = addon.db and addon.db[setting]
	if value == nil then return end

	if type(value) == 'table' then
		local list = ''
		for k, v in pairs(value) do
			local val = v
			if v == true then
				val = k
			else
				val = string.format('%s: %s', k, tostring(v))
			end
			list = (list ~= '' and list..'\n' or '') .. val
		end
		return list
	else
		return value
	end
end
addon.GetSetting = GetSetting

local function SetSetting(setting, value)

	local old = addon.db and addon.db[setting]
	if old == nil then return end

	if type(old) == 'table' then
		-- remove all entries (will be re-added if needed)
		old = {}

		local lines = '([^\n\r]+)' -- (:%s+)?([^\n\r]*)' -- '([^:\n]+)%s*([^\n]+)'
		for k in value:gmatch(lines) do
			
			local v
			local separator, suffix = k:find(':%s+')
			if separator then
				-- value is supplied
				v = k:sub(suffix+1)
				k = k:sub(0, separator-1)
				v = zo_strtrim(v)
			end

			if not isNumber(k) then
				_, _, _, k = ZO_LinkHandler_ParseLink(k)
			end
			k = tonumber(k)

			if v == nil or v == '' then v = true
			elseif v == 'true' then v = true
			elseif v == 'false' or v == 'nil' then v = false
			elseif isNumber(v) then v = tonumber(v)
			end
			-- store entries
			old[k] = v
			addon.db[setting] = old
		end
	else
		addon.db[setting] = value
	end
end
addon.SetSetting = SetSetting

function addon.IsItemIgnored(item)
	if (not item or item == '') then return end
	local _, _, _, itemID = ZO_LinkHandler_ParseLink(item)
	if not type(itemID) == "Number" then itemID = tonumber(itemID) end
	return addon.db.exclude[itemID] and true or false
end

function addon.IsItemFiltered(item)

end

function addon.CreateSettings()
	local panelData = {
		type = 'panel',
		name = addonName,
		author = 'ckaotik',
		version = '1.3',
		registerForRefresh = true,
		registerForDefaults = true,
	}

	local optionsTable = {
		{
			type = 'description',
			text = 'Stacked allows you to easily and automatically restack your inventory, bank and guild bank to conserve space.',
		},

		{
			type = 'dropdown',
			name = L'merge target',
			tooltip = L'merge target description',
			choices = {L'none', L'backpack', L'bank'},
			getFunc = function() return GetSetting('moveTarget') end,
			setFunc = function(value) SetSetting('moveTarget', value) end,
		},
		{
			type = 'dropdown',
			name = L'merge guildbank target',
			tooltip = L'merge guildbank target description',
			choices = {L'none', --[[L'backpack',--]] L'guildbank'},
			getFunc = function() return GetSetting('moveTargetGB') end,
			setFunc = function(value) SetSetting('moveTargetGB', value) end,
		},
		
		{
			type = 'editbox',
			name = L'ignore items',
			tooltip = L'ignore items description',
			warning = L'ignore items info',
			isMultiline = true,
			width = 'full',
			reference = addonName..'Exclude',
			getFunc = function() return GetSetting('exclude') end,
			setFunc = function(value) SetSetting('exclude', value) end,
		},
		{
			type = 'description',
			text = L'ignore items help',
		},
{
			type = 'checkbox',
			name = "exclude item saver?",
			tooltip = "extra for QuadroToni",
			getFunc = function() return GetSetting('excludeItemSaver') end,
			setFunc = function(value) SetSetting('excludeItemSaver', value) end,
		},
		
		
		{ type = 'header', name = L'Messages', },
		{
			type = 'checkbox',
			name = L'item moved',
			tooltip = L'item moved description',
			getFunc = function() return GetSetting('showMessages') end,
			setFunc = function(value) SetSetting('showMessages', value) end,
		},
		{
			type = 'checkbox',
			name = L'slots',
			tooltip = L'slots description',
			getFunc = function() return GetSetting('showSlot') end,
			setFunc = function(value) SetSetting('showSlot', value) end,
		},
		{
			type = 'checkbox',
			name = L'guild bank details',
			tooltip = L'guild bank details description',
			getFunc = function() return GetSetting('showGBStackDetail') end,
			setFunc = function(value) SetSetting('showGBStackDetail', value) end,
		},

		{
			type = 'submenu',
			name = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString(SI_CAMPAIGNRULESETTYPE3)),
			controls = {
				{
					type = 'description',
					text = L'automatic events',
				},
				{
					type = 'checkbox',
					name = L'tradeSucceeded',
					getFunc = function() return GetSetting('trade') end,
					setFunc = function(value) SetSetting('trade', value) end,
				},
				{
					type = 'checkbox',
					name = L'attachmentsRetrieved',
					getFunc = function() return GetSetting('mail') end,
					setFunc = function(value) SetSetting('mail', value) end,
				},
				{
					type = 'checkbox',
					name = L'bank opened',
					getFunc = function() return GetSetting('bank') end,
					setFunc = function(value) SetSetting('bank', value) end,
				},
				{
					type = 'checkbox',
					name = L'guildbank opened',
					getFunc = function() return GetSetting('guildbank') end,
					setFunc = function(value) SetSetting('guildbank', value) end,
				},
			},
		},
		{
			type = 'submenu',
			name = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString(SI_ITEMTYPE18)),
			controls = {
				{
					type = 'description',
					text = L'automatic containers',
				},
				{
					type = 'checkbox',
					name = L'backpack',
					getFunc = function() return GetSetting('stackContainer'..BAG_BACKPACK) end,
					setFunc = function(value) SetSetting('stackContainer'..BAG_BACKPACK, value) end,
				},
				{
					type = 'checkbox',
					name = L'bank',
					getFunc = function() return GetSetting('stackContainer'..BAG_BANK) end,
					setFunc = function(value) SetSetting('stackContainer'..BAG_BANK, value) end,
				},
				{
					type = 'checkbox',
					name = L'guildbank'..' 1',
					getFunc = function() return GetSetting('stackContainer'..BAG_GUILDBANK..'1') end,
					setFunc = function(value) SetSetting('stackContainer'..BAG_GUILDBANK..'1', value) end,
				},
				{
					type = 'checkbox',
					name = L'guildbank'..' 2',
					getFunc = function() return GetSetting('stackContainer'..BAG_GUILDBANK..'2') end,
					setFunc = function(value) SetSetting('stackContainer'..BAG_GUILDBANK..'2', value) end,
				},
				{
					type = 'checkbox',
					name = L'guildbank'..' 3',
					getFunc = function() return GetSetting('stackContainer'..BAG_GUILDBANK..'3') end,
					setFunc = function(value) SetSetting('stackContainer'..BAG_GUILDBANK..'3', value) end,
				},
				{
					type = 'checkbox',
					name = L'guildbank'..' 4',
					getFunc = function() return GetSetting('stackContainer'..BAG_GUILDBANK..'4') end,
					setFunc = function(value) SetSetting('stackContainer'..BAG_GUILDBANK..'4', value) end,
				},
				{
					type = 'checkbox',
					name = L'guildbank'..' 5',
					getFunc = function() return GetSetting('stackContainer'..BAG_GUILDBANK..'5') end,
					setFunc = function(value) SetSetting('stackContainer'..BAG_GUILDBANK..'5', value) end,
				},
			},
		},
	}

	local LAM = LibStub('LibAddonMenu-2.0')
	LAM:RegisterAddonPanel(addonName, panelData)
	LAM:RegisterOptionControls(addonName, optionsTable)
end

addon.slashCommandHelp = (addon.slashCommandHelp or '')
	..'\n'..L'/stacked list'
	..'\n'..L'/stacked exclude'
	..'\n'..L'/stacked include'

function addon.CreateSlashCommands()
	SLASH_COMMANDS['/stacked'] = function(arg)
		if arg == '' or arg == 'help' then
			addon.Print(L('/help', addonName, addon.slashCommandHelp))
			return
		end

		local option, value = string.match(arg, '([%d%a]+)%s*(.*)')
		local optionType = type(addon.db[option])
		if type(addon.db[option]) == 'boolean' then
			addon.db[option] = (value and value ~= 'false') and true or false
			addon.Print('Stacked option "%s" is now set to %s', option, value)
		elseif option == 'list' or (option == 'exclude' and not value) then
			local list
			for itemID, _ in pairs(addon.db.exclude) do
				list = (list and list..', ' or '') .. GetLinkFromID(itemID)
			end
			addon.Print('Stacked ignores %s', list or 'no items')
		elseif option == 'exclude' then
			local _, _, _, itemID = ZO_LinkHandler_ParseLink(value)
			if itemID then value = itemID end

			if not value or value == '' then return
			elseif isNumber(value) then value = tonumber(value) end
			addon.db.exclude[value] = true

			local element = _G[addonName..'Exclude']
			if element then element.edit:SetText( GetSetting('exclude') ) end

			addon.Print('Stacked now ignores item %s', GetLinkFromID(value))
		elseif option == 'include' then
			local _, _, _, itemID = ZO_LinkHandler_ParseLink(value)
			if itemID then value = itemID end

			if not value or value == '' then return
			elseif isNumber(value) then value = tonumber(value) end
			addon.db.exclude[value] = nil

			local element = _G[addonName..'Exclude']
			if element then element.edit:SetText( GetSetting('exclude') ) end

			addon.Print('Stacked no longer ignores %s', GetLinkFromID(value))
		end
	end

	-- Add item dropdown menu options
	local object, itemLink
	local function MarkItemAsIgnored() SLASH_COMMANDS['/stacked']('exclude '..itemLink) end
	local function MarkItemAsUnignored() SLASH_COMMANDS['/stacked']('include '..itemLink) end
	local menuCallback = function()
		-- menu has been closed already?
		if ZO_Menu_GetNumMenuItems() == 0 then return end

		if ZO_InventorySlot_GetType(object) == SLOT_TYPE_ITEM then
			local bag, slot = ZO_Inventory_GetBagAndIndex(object)
			local _, maxStack = GetSlotStackSize(bag, slot)
			if maxStack > 1 then
				itemLink = GetItemLink(bag, slot)
				if addon.IsItemIgnored(itemLink) then
					pcall(AddMenuItem(L'unignore item', MarkItemAsUnignored))
				else
					pcall(AddMenuItem(L'ignore item', MarkItemAsIgnored))
				end
			end
		end
		if ZO_Menu_GetNumMenuItems() > 0 then ShowMenu(nil, 1) end
	end
	ZO_PreHook('ZO_InventorySlot_ShowContextMenu', function(inventorySlot)
		object = inventorySlot
		zo_callLater(menuCallback, 1)
	end)
end
