--[[
  * Wykkyd [ Suite Manager ]
  * Sponsored & Supported by: The Prydonian Elders
  * Author: Ravalox Darkshire (support@ecgroup.us)
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
_addon.Name			= "wykkyd_SuiteManager"
_addon.MAJOR 		= _addon.Name..".".._addon._v.major
_addon.MINOR 		= string.format(".%02d%02d%03d", _addon._v.monthly, _addon._v.daily, _addon._v.minor)
_addon.DisplayName  = "Wykkyd|c888888|r Suite Manager"
_addon.SavedVariableVersion = 1; _addon.Player = ""; _addon.Settings = {}; _addon.GlobalSettings = {}

_addon.LoadSavedVariables = function( self ) return; end
_addon.Initialize = function( self ) return; end

_addon.__addons = {}

_addon.PrepAddons = function()
	if not LWF4.__PlayerActivated then return; end
	_addon:OnUpdateCallback( "loadSuiteManager" )
	_addon:PrepPlayerName()
	for addonKey,_ in pairs( LWF4.mem.Addons ) do
		if string.upper(string.sub(addonKey,1,7)) == "WYKKYDS" then
			local addonTable = LWF4.mem.Addons[addonKey].__base
			if addonTable then
				if addonTable.__settingsVar ~= nil
				and addonTable.__AdvancedSettingsEnabled
				then
					_addon.__addons[addonKey] = {
						name = addonKey,
						base = addonTable,
					}
				end
			end
		end
	end
end

_addon.LoadSettingsMenu = function( self )
	local panelData = self:MakeStandardSettingsPanel( "Exodus Code Group", "|cFF2222" )
	local optionsTable = {
		[1] = {
			type = "description",
			text = "This addon gives you global control of your Wykkyd addons, allowing you to transfer settings between characters and more. See below for extra details.",
		},
		[2] = {
			type = "submenu",
			name = "|cCAB222Global 'Save to Default'|r",
			controls = {
				[1] = {
					type = "description",
					text = "Pressing the button in this section will save a 'snap shot' of the current character's settings for ALL Wykkyd addons as your SYSTEM DEFAULT. All characters without personal settings auto-matically inherit their settings from SYSTEM DEFAULT.",
				},
				[2] = { type="button", name="Save To Default", func=function()
					local setAny = false
					for k,t in pairs( WYK_SuiteManager.__addons ) do
						_G[t.base.__settingsVar][t.base.SavedVariableVersion]["__systemDefault"] = t.base.Settings
						setAny = true
					end
					--if setAny then WYK_SuiteManager:ReloadUI() end
				end, width="full" }
			},
		},
		[3] = {
			type = "submenu",
			name = "|cCAB222Global 'Use System Default'|r",
			controls = {
				[1] = {
					type = "description",
					text = "Pressing the button in this section will set the current character to use SYSTEM DEFAULT for all of their Wykkyd addons' settings.",
				},
				[2] = { type="button", name="Load System Default", func=function()
					local setAny = false
					for k,t in pairs( WYK_SuiteManager.__addons ) do
						t.base.Settings = _G[t.base.__settingsVar][t.base.SavedVariableVersion]["__systemDefault"]
						t.base.Settings["use_system_default"] = true
						setAny = true
					end
					if setAny then WYK_SuiteManager:ReloadUI() end
				end, width="full", warning="Causes the UI to Reload" }
			},
		},
		[4] = {
			type = "submenu",
			name = "|cCAB222Global 'Mimic Character'|r",
			controls = {
				[1] = {
					type = "description",
					text = "Entering a name into the box sets the current character to use the settings of the character name you provide. Note: The box does not load the existing mimic'ed character's name, if there is one, because of the number of addons that this could effect, and the number of mimic values that could result.",
				},
				[2] = {
					name="Mimic another character's settings",
					type="editbox", default=nil,
					warning="Causes the UI to Reload",
					setFunc=function(val)
						local setAny = false
						for k,t in pairs( WYK_SuiteManager.__addons ) do
							t.base.Settings["make_like_character"]=val
							setAny = true
						end
						if setAny then WYK_SuiteManager:ReloadUI() end
					end,
					getFunc=function() return nil; end,
				},
			},
		},
		[5] = {
			type = "submenu",
			name = "|cCAB222Global 'Wykkyd's Preferences'|r",
			controls = {
				[1] = {
					type = "description",
					text = "Pressing the button in this section will set the current character to use Wykkyd's Preferences for all Wykkyd addons currently loaded.",
				},
				[2] = { type="button", name="Set All Like Wykkyd", func=function()
					local setAny = false
					for k,t in pairs( WYK_SuiteManager.__addons ) do
						if t.base.wykkydPreferred ~= nil then
							t.base.GlobalSettings["wykkydsPreferred"] = self.Player
							setAny = true
						end
					end
					if setAny then WYK_SuiteManager:ReloadUI() end
				end, width="full", warning="Causes the UI to Reload" }
			},
		},
	}
	self.LAM:RegisterAddonPanel(_addon.Name.."_LAM", panelData)
	self.LAM:RegisterOptionControls(_addon.Name.."_LAM", optionsTable)
end

LWF4.REGISTER_FACTORY(
	_addon, false, true,
	function( self ) _addon:LoadSavedVariables() end,
	function( self ) _addon:LoadSettingsMenu(); _addon:OnUpdateCallback( "loadSuiteManager", function() WYK_SuiteManager.PrepAddons() end, .1 ); end,
	function( self ) _addon:Initialize() end
)

WYK_SuiteManager = _addon
