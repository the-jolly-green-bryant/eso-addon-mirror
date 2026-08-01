
local Settings = {}
Harvest:RegisterModule("settings", Settings)

function Settings:LoadSavedVars()
	self.savedVars = {}
	
	HarvestC_SavedVars = HarvestC_SavedVars or {}
	-- global settings that are computer wide (eg node/data settings)
	HarvestC_SavedVars.global = HarvestC_SavedVars.global or self.defaultGlobalSettings
	self.savedVars.global = HarvestC_SavedVars.global
	-- fix for settings transfer addon
	-- currently it thinks the keys of the accountwide settings are characters
	-- remove the @ for the keys so this doesn't happen anymore
	if HarvestC_SavedVars.account then
		for accountName, settings in pairs(HarvestC_SavedVars.account) do
			if accountName:sub(1,1) == "@" then
				HarvestC_SavedVars.account[accountName:sub(2,-1)] = settings
				HarvestC_SavedVars.account[accountName] = nil
			end
		end
	end
	
	-- account wide settings
	local accountName = GetDisplayName():sub(2,-1)
	HarvestC_SavedVars.account = HarvestC_SavedVars.account or {}
	HarvestC_SavedVars.account[accountName] = HarvestC_SavedVars.account[accountName] or {}
	self.savedVars.account = HarvestC_SavedVars.account[accountName]
	
	-- character wide settings
	local characterId = GetCurrentCharacterId()
	HarvestC_SavedVars.character = HarvestC_SavedVars.character or {}
	HarvestC_SavedVars.character[characterId] = HarvestC_SavedVars.character[characterId] or {}
	self.savedVars.character = HarvestC_SavedVars.character[characterId]
	
	-- add default settings
	Harvest.CopyMissingDefaultValues(self.savedVars.character, self.defaultSettings)
	Harvest.CopyMissingDefaultValues(self.savedVars.account, self.defaultAccountSettings)
	
	-- depending on the account wide setting, the settings may not be saved per character
	if self.savedVars.account.accountWideSettings then
		self.savedVars.settings = self.savedVars.account
	else
		self.savedVars.settings = self.savedVars.character
	end
	
end

function Settings:FixPinLayout()
	for i, pinTypeId in pairs(Harvest.PINTYPES) do
		pinLayout = self.savedVars.settings.pinLayouts[pinTypeId]
		-- tints cannot be saved (only as rgba table) so restore these tables to tint objects
		pinLayout.tint = ZO_ColorDef:New(pinLayout.tint)
		if pinTypeId == Harvest.TOUR then
			pinLayout.level = 55
		else
			pinLayout.level = 20
		end
	end
end

function Settings:Initialize()
	self:LoadSavedVars()
	self:FixPinLayout()
	self:InitializeLAM()
end