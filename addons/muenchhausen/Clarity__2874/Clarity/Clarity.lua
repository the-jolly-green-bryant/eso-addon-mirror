-- created by Simon Poisson (@outbackz)
-- edited by Baertram
-- revived by @muenchhausen
-------------------------------------------------------------------------------

Clarity = {
	name = "Clarity",
	nameString = "|cB39C7AClarity|r",
	versionString = "v1.1.2",
	author = "Muenchhausen, Baertram, outbackz",
	website	= "https://www.esoui.com/downloads/info2874-Clarity.html",
	settings = {},
	Active = false,
}
local ClarityClutter = {GetString(SI_CLUTTERQUALITY0), GetString(SI_CLUTTERQUALITY1), GetString(SI_CLUTTERQUALITY2), GetString(SI_CLUTTERQUALITY3),} --GetString(SI_CLUTTERQUALITY4),},
local ClarityClutterLookup = {[GetString(SI_CLUTTERQUALITY0)] = 0, [GetString(SI_CLUTTERQUALITY1)] = 1, [GetString(SI_CLUTTERQUALITY2)] = 2, [GetString(SI_CLUTTERQUALITY3)] = 3,} --[GetString(SI_CLUTTERQUALITY4)] = 4,},


function Clarity.ON()
	local showGrass = Clarity.mainGrass
	local showLight = Clarity.mainLight
	local showEffects = Clarity.mainEffects
	--if Clarity.settings.HideGrass then showGrass = 0 end -- legacy
	showGrass = Clarity.settings.HideGrass
	if Clarity.settings.HideLight then showLight = 0 end
	if Clarity.settings.HideEffects then showEffects = 0 end
	
	SetSetting(SETTING_TYPE_GRAPHICS, GRAPHICS_SETTING_CLUTTER_2D_QUALITY, showGrass)
	SetSetting(SETTING_TYPE_GRAPHICS, GRAPHICS_SETTING_GOD_RAYS, showLight)
	SetSetting(SETTING_TYPE_GRAPHICS, GRAPHICS_SETTING_SHOW_ADDITIONAL_ALLY_EFFECTS, showEffects)
	
	Clarity.Active = true
end

function Clarity.OFF()
	SetSetting(SETTING_TYPE_GRAPHICS, GRAPHICS_SETTING_CLUTTER_2D_QUALITY, Clarity.mainGrass)
	SetSetting(SETTING_TYPE_GRAPHICS, GRAPHICS_SETTING_GOD_RAYS, Clarity.mainLight)
	SetSetting(SETTING_TYPE_GRAPHICS, GRAPHICS_SETTING_SHOW_ADDITIONAL_ALLY_EFFECTS, Clarity.mainEffects)
	
	Clarity.Active = false
end

function Clarity.CombatStateEvent(eventCode, inCombat)
	if not Clarity.Auto then
		return
	else
		if inCombat then
			Clarity.ON()
		else
			Clarity.OFF()
		end
		RefreshSettings()
		ApplySettings()
	end
end

function Clarity.Toggle()
Clarity.Auto = false
	if Clarity.Active then
		Clarity.OFF()
		d(Clarity.nameString .. GetString(SI_CLARITY_TOGGLE_OFF))
	else
		Clarity.ON()
		d(Clarity.nameString .. GetString(SI_CLARITY_TOGGLE_ON))
	end
end

local function ClaritySlashCommandFunctions(option)
	if option == "auto" then 
		Clarity.Auto = Clarity.settings.Auto
		Clarity.OFF()
	else
		Clarity.Toggle()
	end
end

function Clarity.buildMenu()
	local LAM = LibAddonMenu2
	local panelData = {
		type 				= 'panel',
		name 				= Clarity.name,
		displayName 		= Clarity.name,
		author 				= Clarity.author,
		version 			= Clarity.versionString,
		registerForRefresh 	= true,
		registerForDefaults = true,
		website             = Clarity.website
	}
	Clarity.LAMPanel = LAM:RegisterAddonPanel(Clarity.name .. "_LAM", panelData)
	
	local optionsTable =
	{	
		{	type 	= "checkbox",
			name 	= GetString(SI_CLARITY_LAM_OPTION_AUTO),
			tooltip = GetString(SI_CLARITY_LAM_OPTION_AUTO_TT),
			getFunc = function() return Clarity.settings.Auto end,
			setFunc = function(value) Clarity.settings.Auto = value	end,
			default = Clarity.settings.Auto,
		},
		{	type = "header",
            name = "",
        },
		{	type 	= "dropdown",
			name 	= GetString(SI_CLARITY_LAM_OPTION_FORM_GRASS),
			choices = ClarityClutter,
			getFunc = function() return ClarityClutter[Clarity.settings.HideGrass + 1] end,
			setFunc = function(value) Clarity.settings.HideGrass = ClarityClutterLookup[value] end,
			default = ClarityClutter[Clarity.settings.HideGrass + 1],
		},		
		{	type 	= "checkbox",
			name 	= GetString(SI_CLARITY_LAM_OPTION_HIDE_LIGHT),
			getFunc = function() return Clarity.settings.HideLight end,
			setFunc = function(value) Clarity.settings.HideLight = value end,
			default = Clarity.settings.HideLight,
		},
		{	type 	= "checkbox",
			name 	= GetString(SI_CLARITY_LAM_OPTION_HIDE_EFFECTS),
			getFunc = function() return Clarity.settings.HideEffects end,
			setFunc = function(value) Clarity.settings.HideEffectsInCombat = value	end,
			default = Clarity.settings.HideEffects,
		},
		{	type = "description",
			title = nil,
			text = SI_CLARITY_LAM_OPTION_INFO,
			width = "full",	
		},
	} 
	LAM:RegisterOptionControls(Clarity.name .. "_LAM", optionsTable)
end

function Clarity.Initialize(eventCode, addOnName)
	if (addOnName ~= Clarity.name) then return end
	EVENT_MANAGER:UnregisterForEvent(Clarity.name, EVENT_ADD_ON_LOADED)
	
	Clarity.mainGrass = GetSetting(SETTING_TYPE_GRAPHICS, GRAPHICS_SETTING_CLUTTER_2D_QUALITY)
	Clarity.mainLight = GetSetting(SETTING_TYPE_GRAPHICS, GRAPHICS_SETTING_GOD_RAYS)
	Clarity.mainEffects = GetSetting(SETTING_TYPE_GRAPHICS, GRAPHICS_SETTING_SHOW_ADDITIONAL_ALLY_EFFECTS)

	local defaults =
	{
        Auto = true,
		--HideGrass = true,
		HideGrass = 0,
        HideLight = true,
        HideEffects = true,
	}
    Clarity.settings = ZO_SavedVars:NewAccountWide("Clarity_SavedVariables", 1, "settings", defaults)
	if (Clarity.settings.HideGrass == true) then Clarity.settings.HideGrass = 0 end -- legacy 
	if (Clarity.settings.HideGrass == false) then Clarity.settings.HideGrass = 1 end -- legacy 
	Clarity.Auto = Clarity.settings.Auto
	
    EVENT_MANAGER:RegisterForEvent(Clarity.name, EVENT_PLAYER_COMBAT_STATE, Clarity.CombatStateEvent)
	SLASH_COMMANDS["/clarity"] = ClaritySlashCommandFunctions
	Clarity.buildMenu()
end

EVENT_MANAGER:RegisterForEvent(Clarity.name, EVENT_ADD_ON_LOADED, Clarity.Initialize)
