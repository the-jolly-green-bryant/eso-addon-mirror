--[[
  * Wykkyd [ Macros ]
  * Sponsored & Supported by: The Prydonian Elders
  * Author: Ravalox Darkshire (support@ecgroup.us) & Calia1120
  * Embedded: LibStub & libAddonMenu by Seerah.
  * Special Thanks To: Zenimax Online Studios & Bethesda for The Elder Scrolls Online
]]--

local _addon = {}
_addon._v = {}
_addon._v.major		= 2
_addon._v.monthly 	= 4
_addon._v.daily 	= 0
_addon._v.minor 	= 0
_addon.Version 	= _addon._v.major
	..".".._addon._v.monthly
	..".".._addon._v.daily
	..".".._addon._v.minor
_addon.Name			= "wykkydsMacros"
_addon.MAJOR 		= _addon.Name..".".._addon._v.major
_addon.MINOR 		= string.format(".%02d%02d%03d", _addon._v.monthly, _addon._v.daily, _addon._v.minor)
_addon.DisplayName  = "Wykkyd Macros"
_addon.SavedVariableVersion = 3
_addon.Player = "" -- will be set on load by LibWykkkydFactory
_addon.Settings = {} -- will be set on load by LibWykkkydFactory, if you pass in the final parameter: your global saved variable as a string
_addon.GlobalSettings = {} -- will be set on load by LibWykkkydFactory, if you pass in the final parameter: your global saved variable as a string
_addon.wykkydPreferred = nil

_addon.LoadSavedVariables = function( self )
	if not _addon.Settings.KEYBIND then _addon.Settings.KEYBIND = {} end
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
			text = "This addon has only 1 configurable option. However, this section can be used as a set of instructions!",
		},
		[2] = self:MakeStandardOption( self.Settings, "Macro-Window Keyboard Intercept", "keyboard_intercept", false, "checkbox", { tooltip = "Causes the macro window to intercept all keys while open, allowing for more advanced keybinding options.", default=false, } ),
		[3] = {
			type = "submenu",
			name = "|cCAB222".."Simple Macro Execution".."|r",
			controls = {
				[1] = {
					type = "description",
					text = "You can use the CONTROLS>Keybinds section of the game settings menu to assign keybinds to both the Macro Window and each individual macro button. You can use these to either open up the Macro Window and click on a macro to execute it, or to use the direct keybind of a given macro to execute that macro directly.",
				},
			},
		},
		[4] = {
			type = "submenu",
			name = "|cCAB222".."Advanced Macro Execution".."|r",
			controls = {
				[1] = {
					type = "description",
					text = "You can use the CONTROLS>Keybinds section of the game settings menu to assign keybinds to the Macro Window. Enable the 'Macro-Window Keyboard Intercept' option. Open the macro window. With the window open, hold CONTROL on your keyboard. Then MOUSE OVER the MACRO BUTTON or TAB that you wish to keybind and, while still holding CONTROL and still MOUSING OVER that button, press the keyboard key you want assigned. After that, execution of the macro itself is simple: tap your Macro Window keybind, then tap the newly set keybind, and the Macro Window will execute the macro and close, or switch to the keybound tab. The purpose of this feature is to provide a NEW layer of keybinds exclusive of what the default game is set to. You can, for example, set Macro 1 to the button W on your keyboard without disrupting the usage of W to make you run forward, because W will only execute Macro 1 when the Macro Window is actually open.",
				},
			},
		},
		[5] = {
			type = "submenu",
			name = "|cCAB222".."Setting & Managing Macros".."|r",
			controls = {
				[1] = {
					type = "description",
					text = "Open the macro window and right click on the button you wish to set. Follow the popups menus and windows to complete your management.",
				},
			},
		},
	}
	optionsTable = self:InjectAdvancedSettings( optionsTable, 1 )
	self.LAM:RegisterAddonPanel(_addon.Name.."_LAM", panelData)
	self.LAM:RegisterOptionControls(_addon.Name.."_LAM", optionsTable)
end

_addon.Initialize = function( self )
	_addon:RegisterEvent( EVENT_PLAYER_ACTIVATED, function()
		_addon:UnregisterEvent( EVENT_PLAYER_ACTIVATED )
		_addon.MacroFrame(false)
	end, true )
end

if wykkydsMacrosGlobal == nil then wykkydsMacrosGlobal = {} end
LWF4.REGISTER_FACTORY(
	_addon, false, true,
	function( self ) _addon:LoadSavedVariables( self ) end,
	function( self ) _addon:LoadSettingsMenu( self ) end,
	function( self ) _addon:Initialize( self ) end,
	"wykkydsMacrosGlobal", true
)

WYK_Macros = _addon
