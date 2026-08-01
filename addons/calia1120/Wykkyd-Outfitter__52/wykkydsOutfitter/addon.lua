--[[
  * Wykkyd [ Outfitter ]
  * Sponsored & Supported by: The Prydonian Elders
  * Author: Ravalox Darkshire (support@ecgroup.us)
  * Embedded: LibStub & libAddonMenu by Seerah.
  * Special Thanks To: Zenimax Online Studios & Bethesda for The Elder Scrolls Online
]]--

local _addon = {}
_addon._v = {}
_addon._v.major		= 2
_addon._v.monthly 	= 3
_addon._v.daily 	= 6
_addon._v.minor 	= 4
_addon.Version 		= _addon._v.major
	..".".._addon._v.monthly
	..".".._addon._v.daily
	..".".._addon._v.minor
_addon.Name			= "wykkydsOutfitter"
_addon.MAJOR 		= _addon.Name..".".._addon._v.major
_addon.MINOR 		= string.format(".%02d%02d%03d", _addon._v.monthly, _addon._v.daily, _addon._v.minor)
_addon.DisplayName  	= "Wykkyd Outfitter"
_addon.SavedVariableVersion = 3
_addon.Player = "" -- will be set on load by LibWykkkydFactory
_addon.Settings = {} -- will be set on load by LibWykkkydFactory, if you pass in the final parameter: your global saved variable as a string
_addon.GlobalSettings = {} -- will be set on load by LibWykkkydFactory, if you pass in the final parameter: your global saved variable as a string
_addon.wykkydPreferred = nil

_addon.GC = {}
_addon.ABT = {}

_addon.HandleMigration = function()
	local oldGear = _G["WF_Outfitter_MigratableGear"]
	local oldSkills = _G["WF_Outfitter_MigratableSkills"]
	if (oldGear or oldSkills) and not _addon.Settings.hasMigratedDeprecated then
		local xg = _addon:GetCountOf( oldGear )
		local xs = _addon:GetCountOf( oldSkills )
		if xg > 0 then _addon.Settings.GearSets["sets"] = oldGear; _addon.GC.ReloadSets(); end
		if xs > 0 then _addon.Settings.SkillSets["sets"] = oldSkills; _addon.ABT.ReloadSets(); end
		_addon.Settings.hasMigratedDeprecated = true
		_addon:Print( "Outfitter settings migrated from old system to new..." );
		_addon:ReloadUI()
	end
	if _addon.Settings.hasMigratedDeprecated then _addon:OnUpdateCallback( "wykkydsOutfitterSavedVarMigration", nil ) end
end

_addon.LoadSavedVariables = function( self )
	if not self.Settings.GearSets then self.Settings.GearSets = {} end
	if not self.Settings.GearSets["sets"] then self.Settings.GearSets["sets"] = {} end
	if not self.Settings.SkillSets then self.Settings.SkillSets = {} end
	if not self.Settings.SkillSets["sets"] then self.Settings.SkillSets["sets"] = {} end
end
_addon.LoadSettingsMenu = function( self )
	local panelData = {
		type = "panel",
		name = "Wykkyd Outfitter",
		displayName = "|cFF2222Wykkyd Outfitter|r",
		author = "Exodus Code Group",
		version = self.Version,
		registerForRefresh = true,
		registerForDefaults = true,
	}
	local optionsTable = {
		[1] = {
			type = "description",
			text = "This addon has no configurable settings. All usage of this addon occurs inside of the Skills and Inventory screens, or inside of the Macro Window provided by Framework, if you have that addon installed.",
		},
	}
	self.LAM:RegisterAddonPanel(_addon.Name.."_LAM", panelData)
	self.LAM:RegisterOptionControls(_addon.Name.."_LAM", optionsTable)
end
_addon.Initialize = function( self )
	self:SlashCommand("wo", self.CommandLine)
	self:SlashCommand("saveset", self.GC.SaveCommands)
	self:SlashCommand("loadset", self.GC.LoadCommands)
	self:SlashCommand("clearset", self.GC.ClearCommands)

	self:SlashCommand("stripnaked", self.GC.StripNaked)
	self:SlashCommand("strip", self.GC.StripNaked)
	self:SlashCommand("getdressed", self.GC.GetDressed)
	self:SlashCommand("dress", self.GC.GetDressed)

	self:SlashCommand("savebar", self.ABT.saveSet)
	self:SlashCommand("loadbar", self.ABT.loadSet)
	self:SlashCommand("delbar", self.ABT.clearSet)

	self:SlashCommand("parsebags", self.GC.DumpParseBags)
	self:SlashCommand("parsegear", self.GC.DumpParseGear)

	self:OnUpdateCallback( "ABTActionBarSwapTic", self.ABT.doSwap, .05 )

	self.GC.EquipSlot = _addon.GLOBAL.EquipSlot
	self.GC.EquipSlotBagSlot = _addon.GLOBAL.EquipSlotBagSlot
	self.GC.EquipSlotDescrByBagSlot = _addon.GLOBAL.EquipSlotDescrByBagSlot

	self.GC.Frame.Load()
	self.ABT.Frame.Load()

	self:OnUpdateCallback( "outfitter gear markers", self.AddOutfitIndicators )
    EVENT_MANAGER:RegisterForEvent("wykkydsOutfitter_settingMigrator", EVENT_PLAYER_ACTIVATED, function() self:OnUpdateCallback( "wykkydsOutfitterSavedVarMigration", self.HandleMigration, .05 ) end)
end

if wykkydsOutfitterGlobal == nil then wykkydsOutfitterGlobal = {} end
LWF4.REGISTER_FACTORY(
	_addon, false, true,
	function( self ) self:LoadSavedVariables() end,
	function( self ) self:LoadSettingsMenu() end,
	function( self ) self:Initialize() end ,
	"wykkydsOutfitterGlobal", true
)

WYK_Outfitter = _addon
