SetMasterOptions = SetMasterOptions or {}
local This = SetMasterOptions

This.Saved = This.Saved or {}

This.Defaults = This.Defaults or {}

local NoDataColor = "d64022"

local MaxBagNameLength = 14

function This:GetOptions()
	return self.Saved
end

function This:GetBagDisplayName(BagId)
	local HouseBagDisplayNames = self:GetOptions().HouseBagDisplayNames
	local HouseBagCustomName = HouseBagDisplayNames[BagId]
	if HouseBagCustomName ~= nil then
		return HouseBagCustomName
	end
	
	return SetMasterGlobal.Localize("BagName", BagId)
end

local Localize = SetMasterGlobal.Localize

-- Localization cache
local NameLocalized = Localize("Meta", "Name")

local Panel = {
	type = "panel",
	name = NameLocalized,
	displayName = NameLocalized,
	author = "Bolt-Action Balrog",
	version = SetMasterGlobal.Version,
	slashCommand = "/setmaster",
	registerForRefresh = "false",
	registerForDefaults = "false"
}

local OptionIndicies = {
	Colorblind = 1,
	CharacterData = 2,
	AccountData = 3,
}

local Options = {
	[OptionIndicies.Colorblind] = {
		type = "checkbox",
		name = Localize("Options", "Colorblind", "Name"),
		tooltip = Localize("Options", "Colorblind", "Tooltip"),
		getFunc = function()
			return This.Saved.bColorBlind
		end,
		setFunc = function(bValue)
			This.Saved.bColorBlind = bValue
		end,
		width = "full"
	},
	[OptionIndicies.CharacterData] = {
		type = "submenu",
		name = Localize("Options", "CharacterDataSubmenu", "Name"),
		tooltip = Localize("Options", "CharacterDataSubmenu", "Tooltip"),
		controls = {
			-- Populated at runtime
		}
	},
	[OptionIndicies.AccountData] = {
		type = "submenu",
		name = Localize("Options", "AccountDataSubmenu", "Name"),
		tooltip = Localize("Options", "AccountDataSubmenu", "Tooltip"),
		controls = {
			-- Populated at runtime
		}
	},
}

function This:Initialize()
	local Defaults = self.Defaults
	Defaults.bColorBlind = false
	Defaults.bSmartAnchored = true
	Defaults.ItemDatabase = {}
	Defaults.Characters = {}
	Defaults.AccountBagsIgnored = {}
	Defaults.HouseBagDisplayNames = {}
	local HouseBagDisplayNames = self.Defaults.HouseBagDisplayNames
	for BagId in SetMasterGlobal.Range(BAG_HOUSE_BANK_ONE, BAG_HOUSE_BANK_TEN) do
		HouseBagDisplayNames[BagId] = Localize("BagName", BagId)
	end
	
	self.Saved = ZO_SavedVars:NewAccountWide("SetMasterSavedOptions", SetMasterGlobal.SaveDataVersion, nil, self.Defaults)
end

local function GetAccountBagUsed(BagId)
	return PlayerSetDatabase.IsAccountBagIgnored(BagId) == false
end

local function SetAccountBagUsed(BagId, bUseBag)
	if bUseBag == true then
		PlayerSetDatabase.IgnoredAccountBags[BagId] = nil
	else
		PlayerSetDatabase.IgnoredAccountBags[BagId] = true
	end
end

local function GetCharacterBagUsed(CharacterData, BagId)
	return PlayerSetDatabase.IsCharacterBagIgnored(CharacterData, BagId) == false
end

local function SetCharacterBagUsed(CharacterData, BagId, bUseBag)
	if bUseBag == true then
		CharacterData.IgnoredBags[BagId] = nil
	else
		CharacterData.IgnoredBags[BagId] = true
	end
end

local function CreateCharacterMenuEntry(CharacterIndex, CharacterData, MegaserverName, CharacterSubmenuControls)
	table.insert(CharacterSubmenuControls, {
			type = "header",
			name = PlayerSetDatabase.GetCharacterName(CharacterData),
			width = "full",
		})
	table.insert(CharacterSubmenuControls, {
			type = "description",
			title = nil,
			text = (function() 
				local DateScanned = CharacterData.DateScanned
				if DateScanned == nil then
					return "|c" .. NoDataColor .. Localize("Options", "CharacterBags", "NoData") .. "|"
				end
				return Localize("Options", "CharacterBags", "DateScanned") .. " " .. DateScanned
			end)(),
			width = "full",
		})
	table.insert(CharacterSubmenuControls, {
			type = "description",
			title = nil,
			text = (function() 
				local Megaserver = MegaserverName
				if Megaserver == nil then
					return "|c" .. NoDataColor .. Localize("Options", "MegaserverInfo", "NoData") .. "|"
				end
				return Megaserver
			end)(),
			width = "full",
		})
	table.insert(CharacterSubmenuControls, {
		type = "checkbox",
		name = Localize("Options", "ShowEquipped", "Name"),
		tooltip = Localize("Options", "ShowEquipped", "Tooltip"),
		getFunc = function() 
			return GetCharacterBagUsed(CharacterData, BAG_WORN)
		end,
		setFunc = function(Value) 
			SetCharacterBagUsed(CharacterData, BAG_WORN, Value)
		end,
		width = "half",
	})
	table.insert(CharacterSubmenuControls, {
		type = "checkbox",
		name = Localize("Options", "ShowBackpack", "Name"),
		tooltip = Localize("Options", "ShowBackpack", "Tooltip"),
		getFunc = function() 
			return GetCharacterBagUsed(CharacterData, BAG_BACKPACK)
		end,
		setFunc = function(bValue) 
			SetCharacterBagUsed(CharacterData, BAG_BACKPACK, bValue)
		end,
		width = "half",
	})
end

function This:CreateAccountMenuEntries(AccountSubmenuControls)
	table.insert(AccountSubmenuControls, {
		type = "checkbox",
		name = Localize("Options", "BankShow", "Name"),
		tooltip = Localize("Options", "BankShow", "Tooltip"),
		getFunc = function()
			return GetAccountBagUsed(BAG_BANK)
		end,
		setFunc = function(bValue)
			SetAccountBagUsed(BAG_BANK, bValue)
			SetAccountBagUsed(BAG_SUBSCRIBER_BANK, bValue)
		end,
		width = "full"
	})
	
	table.insert(AccountSubmenuControls, {
			type = "header",
			name = Localize("Options", "HouseBagHeader"),
			width = "full",
	})
	
	local HouseBagDisplayNames = self:GetOptions().HouseBagDisplayNames
	
	for HouseBagId in SetMasterGlobal.Range(BAG_HOUSE_BANK_ONE, BAG_HOUSE_BANK_TEN) do
		local HouseBagDefaultName = Localize("BagName", HouseBagId)
		table.insert(AccountSubmenuControls, {
			type = "description",
			title = nil,
			text = HouseBagDefaultName,
			width = "full",
		})
		-- Name house chest
		table.insert(AccountSubmenuControls, {
			type = "editbox",
			name = Localize("Options", "Name"),
			tooltip = Localize("Options", "HouseBagNameTip"),
			default = HouseBagDefaultName,
			getFunc = function() 
				return HouseBagDisplayNames[HouseBagId]
			end,
			setFunc = function(NewValue)
				HouseBagDisplayNames[HouseBagId] = string.sub(NewValue, 1, MaxBagNameLength)
			end,
			width = "half"
		})
		-- Filter house chest
		table.insert(AccountSubmenuControls, {
			type = "checkbox",
			name = Localize("Options", "HouseBagShow", "Name"),
			tooltip = Localize("Options", "HouseBagShow", "Tooltip"),
			getFunc = function() 
				return GetAccountBagUsed(HouseBagId)
			end,
			setFunc = function(Value) 
				SetAccountBagUsed(HouseBagId, Value)
			end,
			width = "half",
		})
	end
end

function This:Finalize()
	local CharacterTable = PlayerSetDatabase.Characters
	
	-- Sort characters by megaserver then character id so there's a deterministic ordering in the menu
	for MegaserverName, ServerCharacters in pairs(CharacterTable) do
		local CharacterIds = {}
		for CharacterId, CharacterData in pairs(ServerCharacters) do
			table.insert(CharacterIds, CharacterId)
		end
		table.sort(CharacterIds, function(a, b) 
			return tonumber(a) < tonumber(b)
		end)
		
		local CharacterDataSubmenu = Options[OptionIndicies.CharacterData]
		for _, CharacterId in ipairs(CharacterIds) do
			local CharacterData = ServerCharacters[CharacterId]
			CreateCharacterMenuEntry(CharacterId, CharacterData, MegaserverName, CharacterDataSubmenu.controls)
		end
	end
	
	local AccountDataSubmenu = Options[OptionIndicies.AccountData]
	self:CreateAccountMenuEntries(AccountDataSubmenu.controls)

	local AddonMenu = LibAddonMenu2
	AddonMenu:RegisterAddonPanel(NameLocalized, Panel)
	AddonMenu:RegisterOptionControls(NameLocalized, Options)
end













