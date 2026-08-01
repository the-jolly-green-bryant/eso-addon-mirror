local LAM = LibStub( 'LibAddonMenu-2.0')

local ADDON_VERSION = "1.34"

local iconTexturesList = {
	[1] = "Vanilla UI",
	[2] = "Skyrim Style UI",
}

local panelData = {
	    type = "panel",
	    name = "Skyrim Style UI",
	    displayName = ZO_HIGHLIGHT_TEXT:Colorize("Skyrim Style UI"),
	    author = "Half-Dead",
		registerForDefaults = true,
	    version = ADDON_VERSION,
	 
   slashCommand = "/ssi",
}

local optionsData = {  
	 [1] = {
	    type = "header",
		name = "General Options",
	},
	 [2] = {
        type = "dropdown",
        name = "Interface Style",
        tooltip = "Choose your UI Style.",
		choices = iconTexturesList,
		default = "Skyrim Style UI",
		warning = "You must reload the UI twice for all the textures to change over properly!",
        getFunc = function() return ssi.SV.Icon end,
        setFunc = function(val) ssi.SV.Icon = val end,
	 },
	 [3] = {
	 	type = "button",
		name = "Reload UI",
		tooltip = "REMEMBER TO RELOAD THE UI TWICE",
		width = "full",
		func = function() 
	      ReloadUI("ingame")
		end,
	 },
}

function ssi:initLAM()
	LAM:RegisterOptionControls("SkyrimStyleUIOptions", optionsData)
	LAM:RegisterAddonPanel("SkyrimStyleUIOptions", panelData)
end