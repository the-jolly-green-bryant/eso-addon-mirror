--[[
  * Wykkyd [ Enhanced HUD ]
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
_addon.Name			= "wykkydsEnhancedHUD"
_addon.MAJOR 		= _addon.Name..".".._addon._v.major
_addon.MINOR 		= string.format(".%02d%02d%03d", _addon._v.monthly, _addon._v.daily, _addon._v.minor)
_addon.DisplayName  = "Wykkyd Enhanced HUD"
_addon.SavedVariableVersion = 3
_addon.Player = "" -- will be set on load by LibWykkkydFactory
_addon.Settings = {} -- will be set on load by LibWykkkydFactory, if you pass in the final parameter: your global saved variable as a string
_addon.GlobalSettings = {} -- will be set on load by LibWykkkydFactory, if you pass in the final parameter: your global saved variable as a string
_addon.wykkydPreferred = {
	["player_health"] = "Current / Max (%)",
	["always_show"] = false,
	["target_health_color"] =
	{
		["b"] = 0.647059,
		["g"] = 0.552941,
		["a"] = 0.647059,
		["r"] = 0.074510,
	},
	["player_stamina"] = "Current / Max (%)",
	["player_stamina_color"] =
	{
		["b"] = 0.031373,
		["g"] = 0.156863,
		["a"] = 0.647059,
		["r"] = 0.784314,
	},
	["target_health"] = "Current / Max (%)",
	["player_magicka"] = "Current / Max (%)",
	["player_magicka_color"] =
	{
		["b"] = 0.058824,
		["g"] = 0.568627,
		["a"] = 0.647059,
		["r"] = 0.647059,
	},
	["reposition"] = true,
	["player_health_color"] =
	{
		["b"] = 0.647059,
		["g"] = 0.552941,
		["a"] = 0.647059,
		["r"] = 0.074510,
	},
}

_addon.LoadSavedVariables = function( self )	self._fontList = {}
	self._fontList = LWF4.data.Fonts
	self._fonts = {}; local i = 0; for k in pairs(self._fontList) do i = i + 1; self._fonts[i] = k; end table.sort(self._fonts);
	self._fontStyles = {"normal", "outline", "thick-outline", "shadow", "soft-shadow-thick", "soft-shadow-thin"}
	self._overlayFormats = {"Off","Current / Max","Current / Max (%)","Percent","Current"}
end

local colorGetFunc = function( self, key, defaultC )
	local cc = {}
	cc.r = defaultC[1]
	cc.g = defaultC[2]
	cc.b = defaultC[3]
	cc.a = defaultC[4]
	local c = self:GetOrDefault( cc, self.Settings[ key ] )
	if c[r] then
		return c[r], c[g], c[b], c[a]
	else
		if c["r"] then
			self.Settings[ key ]  = {}
			self.Settings[ key ].r = c["r"]
			self.Settings[ key ].g = c["g"]
			self.Settings[ key ].b = c["b"]
			self.Settings[ key ].a = c["a"]
			return c["r"], c["g"], c["b"], c["a"]
		else
			self.Settings[ key ]  = {}
			self.Settings[ key ].r = c[1]
			self.Settings[ key ].g = c[2]
			self.Settings[ key ].b = c[3]
			self.Settings[ key ].a = c[4]
			return c[1], c[2], c[3], c[4]
		end
	end
end
local colorSetFunc = function( self, key, r, g, b, a )
	self.Settings[ key ] = {}
	self.Settings[ key ].r = r
	self.Settings[ key ].g = g
	self.Settings[ key ].b = b
	self.Settings[ key ].a = a
end
local makeColorOption = function( self, key, defaultC, label )
	local target = self:MakeStandardOption( self.Settings, label, key, defaultC, "colorpicker", { default=defaultC, } )
	target.getFunc = function() return colorGetFunc( self, key, defaultC ) end
	target.setFunc = function( r, g, b, a )
		colorSetFunc( self, key, r, g, b, a )
	end
	return target
end
local makeOverlayOptions = function( displayName, prefix, color )
	return {
		type = "submenu",
		name = "|cCAB222" .. displayName .. " Overlay|r",
		controls = {
			[1] = _addon:MakeStandardOption( _addon.Settings, "Display Type", prefix, "Off", "dropdown", { choices=_addon._overlayFormats, default="Off", } ),
			[2] = makeColorOption( _addon, prefix.."_color", color, "Font Color" ),
			[3] = _addon:MakeStandardOption( _addon.Settings, "Font", prefix.."_type", "ESO Cartographer", "dropdown", { choices=_addon._fonts, default="ESO Cartographer", } ),
			[4] = _addon:MakeStandardOption( _addon.Settings, "Font Style", prefix.."_style", "outline", "dropdown", { choices=_addon._fontStyles, default="outline", } ),
			[5] = _addon:MakeStandardOption( _addon.Settings, "Font Size", prefix.."_size", 16, "slider", { min=8, max=22, step=.5, default=16, } ),
		},
	}
end

_addon.LoadSettingsMenu = function( self )
	local panelData = {
		type = "panel",
		name = "Wykkyd Enh. HUD",
		displayName = "|cFF2222Wykkyd's Enh. HUD|r",
		author = "Exodus Code Group",
		version = self.Version,
		registerForRefresh = true,
		registerForDefaults = true,
	}
	local optionsTable = {
		[1] = {
			type = "description",
			text = "If changing overlay settings you must click the provided button below to apply settings or manually |c660000/reloadui|r in order to see your changes.",
		},
		[2] = self:MakeStandardOption( self.Settings, "Always Show my Health, Stamina & Magicka", "always_show", false, "checkbox", { default=false, } ),
		[3] = self:MakeStandardOption( self.Settings, "Center my Health, Stamina & Magicka", "reposition", false, "checkbox", { default=false, } ),
		[4] = makeOverlayOptions( "Player Health", "player_health", {(19/255),(141/255),(165/255),(165/255)} ),
		[5] = makeOverlayOptions( "Player Magicka", "player_magicka", {(165/255),(145/255),(15/255),(165/255)} ),
		[6] = makeOverlayOptions( "Player Stamina", "player_stamina", {(200/255),(40/255),(8/255),(165/255)} ),
		[7] = makeOverlayOptions( "Target Health", "target_health", {(19/255),(141/255),(165/255),(165/255)} ),
		[8] = { type="button", name="Apply Settings", func=function() self:ReloadUI() end, },
	}
	optionsTable[2].setFunc = function( val )
		self.Settings["always_show"] = val
		self.ShowFrames()
	end
	optionsTable = self:InjectAdvancedSettings( optionsTable, 1 )
	self.LAM:RegisterAddonPanel(_addon.Name.."_LAM", panelData)
	self.LAM:RegisterOptionControls(_addon.Name.."_LAM", optionsTable)
end

_addon.Initialize = function( self )
	_addon.PlayerHUD()
	_addon.TargetHUD()
end

if wykkydsEnhancedHUDGlobal == nil then wykkydsEnhancedHUDGlobal = {} end
LWF4.REGISTER_FACTORY(
	_addon, false, true,
	function( self ) _addon:LoadSavedVariables( self ) end,
	function( self ) _addon:LoadSettingsMenu( self ) end,
	function( self ) _addon:Initialize( self ) end,
	"wykkydsEnhancedHUDGlobal", true
)

WYK_EnhancedHUD = _addon
