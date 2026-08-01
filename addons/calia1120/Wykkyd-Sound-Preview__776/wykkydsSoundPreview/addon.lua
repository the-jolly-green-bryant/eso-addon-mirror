--[[
  * Wykkyd [ Sound Preview ]
  * Sponsored & Supported by: The Prydonian Elders
  * Author: Ravalox Darkshire (support@ecgroup.us)
  * Embedded: LibStub & libAddonMenu by Seerah.
  * Special Thanks To: Zenimax Online Studios & Bethesda for The Elder Scrolls Online
]]--

local _addon = {}
_addon._v = {}
_addon._v.major		= 2
_addon._v.monthly 	= 3
_addon._v.daily 	= 3
_addon._v.minor 	= 9
_addon.Version 	= _addon._v.major
	..".".._addon._v.monthly
	..".".._addon._v.daily
	..".".._addon._v.minor
_addon.Name			= "wykkydsSoundPreview"
_addon.MAJOR 		= _addon.Name..".".._addon._v.major
_addon.MINOR 		= string.format(".%02d%02d%03d", _addon._v.monthly, _addon._v.daily, _addon._v.minor)
_addon.DisplayName  = "Wykkyd Sound Preview"
_addon.SavedVariableVersion = 3
_addon.Player = "" -- will be set on load by LibWykkkydFactory
_addon.Settings = {} -- will be set on load by LibWykkkydFactory, if you pass in the final parameter: your global saved variable as a string
_addon.GlobalSettings = {} -- will be set on load by LibWykkkydFactory, if you pass in the final parameter: your global saved variable as a string
_addon.wykkydPreferred = nil
_addon.__uiKey = _addon.Name.."UI"
_addon.ui = {}

_addon.LoadSavedVariables = function( self )
	return
end

_addon.LoadSettingsMenu = function( self )
	local panelData = {
		type = "panel",
		name = _addon.DisplayName,
		displayName = "|cFF2222".._addon.DisplayName.."|r",
		author = "Exodus Code Group",
		version = self.Version,
		registerForRefresh = true,
		registerForDefaults = true,
	}
	local optionsTable = {
		[1] = {
			type = "description",
			text = "This addon has no configurable options. To use this addon, issue the chat command |cFF2222/sndprv|r or |cFF2222/sounds|r and a window will appear. Scroll over portions of the window to find out what they do. Copy the sound path or command you desire out of the provided edit box.",
		},
	}
	self.LAM:RegisterAddonPanel(_addon.Name.."_LAM", panelData)
	self.LAM:RegisterOptionControls(_addon.Name.."_LAM", optionsTable)
end

_addon.Initialize = function( self )
	self:SlashCommand( "sndprv", function() self.ui:Toggle() end )
	self:SlashCommand( "sounds", function() self.ui:Toggle() end )
end

LWF4.REGISTER_FACTORY(
	_addon, false, true,
	function( self ) _addon:LoadSavedVariables( self ) end,
	function( self ) _addon:LoadSettingsMenu( self ) end,
	function( self ) _addon:Initialize( self ) end
)

WYK_SoundPreview = _addon
