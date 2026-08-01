local NAME = "MasterWritInventoryMarker"
local TITLE = "Master Writ Inventory Marker"


--------------------------------------------------------------------------------
-- Dependencies
--------------------------------------------------------------------------------

-- Required dependencies; will always be present
local LCCC = LibCodesCommonCode -- included in LCK
local LCK = LibCharacterKnowledge

-- Optional dependencies; presence must be verified
local WW = WritWorthy
local AF = AdvancedFilters


--------------------------------------------------------------------------------
-- Constants
--------------------------------------------------------------------------------

local DEFAULT_COLORS = {
	doable = 0xFFFF00,
	completed = 0x00FF00,
	unknown = 0xDD0000,
}

local MARKERS = {
	doable = "MasterWritInventoryMarker/art/yes.dds",
	completed = "MasterWritInventoryMarker/art/yes.dds",
	unknown = "MasterWritInventoryMarker/art/no.dds",
}

local EQUIPMENT_CHAPTERS = {
	[26] = ITEM_STYLE_CHAPTER_HELMETS, -- Hat
	[28] = ITEM_STYLE_CHAPTER_CHESTS, -- Robe
	[29] = ITEM_STYLE_CHAPTER_SHOULDERS, -- Epaulets
	[30] = ITEM_STYLE_CHAPTER_BELTS, -- Sash
	[31] = ITEM_STYLE_CHAPTER_LEGS, -- Breeches
	[32] = ITEM_STYLE_CHAPTER_BOOTS, -- Shoes
	[34] = ITEM_STYLE_CHAPTER_GLOVES, -- Gloves
	[35] = ITEM_STYLE_CHAPTER_HELMETS, -- Helmet
	[37] = ITEM_STYLE_CHAPTER_CHESTS, -- Jack
	[38] = ITEM_STYLE_CHAPTER_SHOULDERS, -- Arm Cops
	[39] = ITEM_STYLE_CHAPTER_BELTS, -- Belt
	[40] = ITEM_STYLE_CHAPTER_LEGS, -- Guards
	[41] = ITEM_STYLE_CHAPTER_BOOTS, -- Boots
	[43] = ITEM_STYLE_CHAPTER_GLOVES, -- Bracers
	[44] = ITEM_STYLE_CHAPTER_HELMETS, -- Helm
	[46] = ITEM_STYLE_CHAPTER_CHESTS, -- Cuirass
	[47] = ITEM_STYLE_CHAPTER_SHOULDERS, -- Pauldron
	[48] = ITEM_STYLE_CHAPTER_BELTS, -- Girdle
	[49] = ITEM_STYLE_CHAPTER_LEGS, -- Greaves
	[50] = ITEM_STYLE_CHAPTER_BOOTS, -- Sabatons
	[52] = ITEM_STYLE_CHAPTER_GLOVES, -- Gauntlets
	[53] = ITEM_STYLE_CHAPTER_AXES, -- Axe
	[56] = ITEM_STYLE_CHAPTER_MACES, -- Mace
	[59] = ITEM_STYLE_CHAPTER_SWORDS, -- Sword
	[62] = ITEM_STYLE_CHAPTER_DAGGERS, -- Dagger
	[65] = ITEM_STYLE_CHAPTER_SHIELDS, -- Shield
	[67] = ITEM_STYLE_CHAPTER_SWORDS, -- Greatsword
	[68] = ITEM_STYLE_CHAPTER_AXES, -- Battle Axe
	[69] = ITEM_STYLE_CHAPTER_MACES, -- Maul
	[70] = ITEM_STYLE_CHAPTER_BOWS, -- Bow
	[71] = ITEM_STYLE_CHAPTER_STAVES, -- Restoration Staff
	[72] = ITEM_STYLE_CHAPTER_STAVES, -- Inferno Staff
	[73] = ITEM_STYLE_CHAPTER_STAVES, -- Ice Staff
	[74] = ITEM_STYLE_CHAPTER_STAVES, -- Lightning Staff
	[75] = ITEM_STYLE_CHAPTER_CHESTS, -- Jerkin
}


--------------------------------------------------------------------------------
-- Utilities
--------------------------------------------------------------------------------

local SV

local function AreInventoryTweaksEnabled( )
	return SV.inventoryTweaks ~= false
end

local function GetMotifCharId( )
	if (SV.motifChar == "current") then
		return nil
	elseif (type(SV.motifChar) == "string" and zo_strlen(SV.motifChar) == 16) then
		return SV.motifChar
	else
		local char = LCK.GetCharacterList()[1]
		return char and char.id
	end
end

local function GetMarkerColor( key )
	if (type(SV[key]) == "number") then
		return SV[key]
	else
		return DEFAULT_COLORS[key]
	end
end

local function GetMasterWritSetName( data )
	if (type(data) == "table" and GetItemType(data.bagId, data.slotIndex) == ITEMTYPE_MASTER_WRIT) then
		local fields = { zo_strsplit(":", GetItemLink(data.bagId, data.slotIndex)) }
		local setId = fields[12] and tonumber(fields[12])
		local setName = GetItemSetName(setId)
		if (setName ~= "") then
			return setName
		end
	end
	return nil
end

local function GetMasterWritVouchers( data )
	if (type(data) == "table" and GetItemType(data.bagId, data.slotIndex) == ITEMTYPE_MASTER_WRIT) then
		local fields = { zo_strsplit(":", GetItemLink(data.bagId, data.slotIndex)) }
		local value = fields[23] and zo_strsplit("|", fields[23])
		value = value and tonumber(value)
		if (value) then
			return zo_round(value / 10000)
		end
	end
	return nil
end


--------------------------------------------------------------------------------
-- Analysis
--------------------------------------------------------------------------------

local function IsWritCompleted( slot )
	if (not WW) then return false end
	if (slot and slot.bagId and slot.slotIndex) then
		local list = WritWorthyInventoryList and WritWorthyInventoryList.singleton
		if (list) then
			local id = WW.UniqueID(slot.bagId, slot.slotIndex)
			local data = list:UniqueIDToInventoryData(id)
			if (data and data.ui_is_completed) then
				return true
			end
		end
	end
	return false
end

local function IsWritDoable( itemLink )
	if (not WW) then return false end
	local parser = WW.CreateParser(itemLink)
	if (not parser or not parser:ParseItemLink(itemLink) or not parser.ToKnowList) then
		return false
	else
		local knowList = parser:ToKnowList()
		if (knowList) then
			for _, know in ipairs(knowList) do
				if (not know.is_known) then
					return false
				end
			end
		end

		if (SV.requireMats) then
			local matList = parser:ToMatList()
			if (matList) then
				for _, mat in ipairs(matList) do
					if (WW.Util.MatHaveCt(mat.link) < mat.ct) then
						return false
					end
				end
			end
		end

		return true
	end
end

local function IsWritMotifUnknown( itemLink )
	if (SV.motifChar ~= "disabled" and GetItemLinkItemType(itemLink) == ITEMTYPE_MASTER_WRIT) then
		local fields = { zo_strsplit(":", itemLink) }
		local styleId = fields[14] and tonumber(fields[14])
		local chapterId = fields[9] and EQUIPMENT_CHAPTERS[tonumber(fields[9])]

		if (styleId and chapterId and LCK.GetMotifKnowledgeForCharacter(styleId, chapterId, nil, GetMotifCharId()) == LCK.KNOWLEDGE_UNKNOWN) then
			return true
		end
	end
	return false
end


--------------------------------------------------------------------------------
-- Functions to add the markers to the UI
--------------------------------------------------------------------------------

local function FlagListItem( link, control, context )
	if (context ~= "mail") then
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

	if (AreInventoryTweaksEnabled()) then
		local vouchers = GetMasterWritVouchers(context)
		if (vouchers) then
			local row = control:GetParent()
			local valueControl = row:GetNamedChild("SellPriceText") or row:GetNamedChild("SellPrice")
			if (valueControl and valueControl.SetFont) then
				ZO_CurrencyControl_SetSimpleCurrency(valueControl, CURT_WRIT_VOUCHERS, vouchers, ITEM_SLOT_CURRENCY_OPTIONS)
			end
		end
	end

	local state = nil
	if (IsWritCompleted(context)) then
		state = "completed"
	elseif (IsWritDoable(itemLink)) then
		state = "doable"
	elseif (IsWritMotifUnknown(itemLink)) then
		state = "unknown"
	end

	-- Get or create our indicator
	local indicator = control:GetNamedChild(NAME)
	if (not indicator) then
		-- Be lazy; don't create an indicator unless we actually need to show it
		if (not state) then return end

		-- Create and initialize the indicator
		indicator = WINDOW_MANAGER:CreateControl(control:GetName() .. NAME, control, CT_TEXTURE)
		indicator:SetDimensions(22, 22)
		indicator:SetInheritScale(false)
		indicator:SetAnchor(TOPRIGHT)
		indicator:SetDrawTier(DT_HIGH)
	end

	if (state) then
		indicator:SetTexture(MARKERS[state])
		indicator:SetColor(LCCC.Int24ToRGBA(GetMarkerColor(state)))
		indicator:SetHidden(false)
	else
		indicator:SetHidden(true)
	end
end

local function HookLists( )
	local ProcessListHooks = function( lists )
		for _, list in ipairs(lists) do
			local scrollList = _G[list.name]
			if (scrollList and ZO_ScrollList_GetDataTypeTable(scrollList, 1)) then
				SecurePostHook(ZO_ScrollList_GetDataTypeTable(scrollList, 1), "setupCallback", function(...) FlagListItem(list.link, ...) end)
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
		{ name = "ZO_LootAlphaContainerList", link = { GetLootItemLink, "lootId" } },
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
					{ name = "ZO_TradingHouseBrowseItemsRightPaneSearchResults", link = { GetTradingHouseSearchResultItemLink, "slotIndex" } },
				})
			end
		end)
	end

	--------
	-- Trade window slots are not technically item lists, but they reuse the same inventory slot control
	-- /esoui/ingame/tradewindow/keyboard/tradewindow_keyboard.lua
	--------

	SecurePostHook(TRADE, "InitializeSlot", function( self, who, index, ... )
		FlagListItem(GetTradeItemLink(who, index), self.Columns[who][index].Control)
	end)

	SecurePostHook(TRADE, "ResetSlot", function( self, who, index )
		FlagListItem("", self.Columns[who][index].Control)
	end)

	--------
	-- Mail attachment slots are not technically item lists, but they reuse the same inventory slot control
	-- /esoui/ingame/mail/keyboard/mail*_keyboard.lua
	--------

	SecurePostHook(MAIL_INBOX, "RefreshAttachmentSlots", function( self )
		local numAttachments = self:GetMailData(self.mailId, self.isMailFromGuild).numAttachments
		for i = 1, numAttachments do
			FlagListItem(GetAttachedItemLink(self.mailId, i), self.attachmentSlots[i], "mail")
		end
	end)
end


--------------------------------------------------------------------------------
-- Advanced Filters integration
--------------------------------------------------------------------------------

local function RegisterFilters( )
	if (not AF or not WW) then return end
	local util = AdvancedFilters.util

	local filterName = "WritWorthy"

	local filterInformation = {
		submenuName = filterName,

		callbackTable = { },

		enStrings = { [filterName] = filterName },

		filterType = ITEMFILTERTYPE_ALL,
		subfilters = { "Writ" },
		onlyGroups = { "Consumables", "Junk" },
	}

	local getCallback = function( option )
		return function( slot, slotIndex )
			if (util.prepareSlot ~= nil) then
				if (slotIndex ~= nil and type(slot) ~= "table") then
					slot = util.prepareSlot(slot, slotIndex)
				end
			end
			if (option == "Doable") then
				return IsWritDoable(GetItemLink(slot.bagId, slot.slotIndex))
			elseif (option == "Completed") then
				return IsWritCompleted(slot)
			end
		end
	end

	for _, option in ipairs({ "Doable", "Completed" }) do
		table.insert(filterInformation.callbackTable, {
			name = option,
			filterCallback = getCallback(option),
		})
		filterInformation.enStrings[option] = option
	end

	AdvancedFilters_RegisterFilter(filterInformation)
end


--------------------------------------------------------------------------------
-- Inventory tweaks
--------------------------------------------------------------------------------

local INVENTORY_TYPES = {
	[INVENTORY_BACKPACK] = true,
	[INVENTORY_BANK] = true,
	[INVENTORY_HOUSE_BANK] = true,
	[INVENTORY_GUILD_BANK] = true,
}

local SHOW_TRAIT_HIDDEN_COLUMNS = {
	["sellInformationSortOrder"] = true,
}

local InitializedTweaks = false

local function HookInventorySortFunction( inventory )
	if (inventory and not inventory.mwimReplacedSort and inventory.sortFn) then
		-- Make sure we only do this once
		inventory.mwimReplacedSort = true

		-- Hook the sort function
		local origSortFn = inventory.sortFn
		inventory.sortFn = function( a, b )
			if (AreInventoryTweaksEnabled()) then
				local order = inventory.currentSortOrder
				if (inventory.currentSortKey == "traitInformationSortOrder") then
					local aName = GetMasterWritSetName(a.data)
					local bName = GetMasterWritSetName(b.data)

					if (aName and not bName) then
						return order == ZO_SORT_ORDER_UP
					elseif (bName and not aName) then
						return order == ZO_SORT_ORDER_DOWN
					elseif (not aName and not bName) then
						-- Pass through to default
					elseif (aName < bName) then
						return order == ZO_SORT_ORDER_UP
					elseif (bName < aName) then
						return order == ZO_SORT_ORDER_DOWN
					end
				elseif (inventory.currentSortKey == "stackSellPrice") then
					local aValue = GetMasterWritVouchers(a.data) or 99999
					local bValue = GetMasterWritVouchers(b.data) or 99999

					if (aValue < bValue) then
						return order == ZO_SORT_ORDER_UP
					elseif (bValue < aValue) then
						return order == ZO_SORT_ORDER_DOWN
					end
				end
			end

			-- Pass through to the default function for tiebreakers and non-writs
			return origSortFn(a, b)
		end
	end
end

local function InitializeInventoryTweaks( )
	local fnGetTabFilterInfo = PLAYER_INVENTORY and PLAYER_INVENTORY.GetTabFilterInfo
	if (not fnGetTabFilterInfo or InitializedTweaks or not AreInventoryTweaksEnabled()) then return end

	InitializedTweaks = true

	PLAYER_INVENTORY.GetTabFilterInfo = function(...)
		local self, inventoryType = ...

		if (AreInventoryTweaksEnabled() and self.inventories) then
			-- Ensure that our updated sort function is active; we need to check
			-- all types because the game sometimes calls in with the wrong type
			for type in pairs(INVENTORY_TYPES) do
				HookInventorySortFunction(self.inventories[type])
			end

			if (INVENTORY_TYPES[inventoryType]) then
				local results = { fnGetTabFilterInfo(...) }
				if (results[1] == ITEM_TYPE_DISPLAY_CATEGORY_CONSUMABLE) then
					results[3] = SHOW_TRAIT_HIDDEN_COLUMNS
				end
				return unpack(results)
			end
		end

		-- Default fallback: Straight passthrough
		return fnGetTabFilterInfo(...)
	end
end


--------------------------------------------------------------------------------
-- Settings panel
--------------------------------------------------------------------------------

local function RegisterSettingsPanel( )
	local LAM = LCCC.GetLibAddonMenu()
	if (not LAM) then return end

	local panelId = "MWIM_Settings"

	local settingsPanel = LAM:RegisterAddonPanel(panelId, {
		type = "panel",
		name = TITLE,
		version = LCCC.FormatVersion(LCCC.GetAddOnVersion(NAME)),
		author = "@code65536",
		registerForRefresh = true,
	})

	local UnpackRGB = LCCC.Int24ToRGB
	local PackRGB = LCCC.RGBToInt24

	local chars = { "disabled", "default", "current" }
	local charLabels = { "Disabled", "Highest priority character", "Current character" }
	for _, char in ipairs(LCK.GetCharacterList()) do
		table.insert(chars, char.id)
		table.insert(charLabels, char.name)
	end

	LAM:RegisterOptionControls(panelId, {
		--------------------------------------------------------------------
		{
			type = "header",
			name = "Marker Colors",
		},
		--------------------
		{
			type = "colorpicker",
			name = "Doable",
			getFunc = function() return UnpackRGB(GetMarkerColor("doable")) end,
			setFunc = function(...) SV.doable = PackRGB(...) end,
		},
		--------------------
		{
			type = "colorpicker",
			name = "Completed",
			getFunc = function() return UnpackRGB(GetMarkerColor("completed")) end,
			setFunc = function(...) SV.completed = PackRGB(...) end,
		},
		--------------------
		{
			type = "colorpicker",
			name = "Unknown Motif",
			getFunc = function() return UnpackRGB(GetMarkerColor("unknown")) end,
			setFunc = function(...) SV.unknown = PackRGB(...) end,
		},

		--------------------------------------------------------------------
		{
			type = "header",
			name = "Motif Knowledge",
		},
		--------------------
		{
			type = "dropdown",
			name = "Mark items requiring a motif unknown by",
			choices = charLabels,
			choicesValues = chars,
			scrollable = true,
			getFunc = function() return SV.motifChar or "default" end,
			setFunc = function(char) SV.motifChar = char end,
		},

		--------------------------------------------------------------------
		{
			type = "header",
			name = "Miscellaneous",
		},
		--------------------
		{
			type = "checkbox",
			name = "Require sufficient materials for doable writs",
			getFunc = function() return SV.requireMats == true end,
			setFunc = function(enabled) SV.requireMats = enabled end,
		},
		--------------------
		{
			type = "checkbox",
			name = "Enable additional inventory management tweaks",
			getFunc = AreInventoryTweaksEnabled,
			setFunc = function( enabled )
				SV.inventoryTweaks = enabled
				InitializeInventoryTweaks()
			end,
		},
	})
end


--------------------------------------------------------------------------------
-- Bootstrap
--------------------------------------------------------------------------------

LCK.RegisterForCallback(NAME, LCK.EVENT_INITIALIZED, function( )
	-- Initialize saved variables
	local server = LCCC.GetServerName()
	if (not MWIM_SavedVariables) then
		MWIM_SavedVariables = { }
	end
	if (not MWIM_SavedVariables[server]) then
		MWIM_SavedVariables[server] = { }
	end
	SV = MWIM_SavedVariables[server]

	-- Initialize
	HookLists()
	RegisterFilters()
	InitializeInventoryTweaks()
	RegisterSettingsPanel()
end)
