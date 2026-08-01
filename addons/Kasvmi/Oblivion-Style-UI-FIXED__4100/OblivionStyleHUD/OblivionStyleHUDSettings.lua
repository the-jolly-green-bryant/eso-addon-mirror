local LAM = LibAddonMenu2

local ADDON_VERSION = "1.82"

local iconTexturesList = {
	[1] = "Vanilla UI",
	[2] = "Oblivion Style UI",
}

local panelData = {
	    type = "panel",
	    name = "Oblivion Style UI",
	    displayName = ZO_HIGHLIGHT_TEXT:Colorize("Oblivion Style UI"),
	    author = "Half-Dead",
		registerForDefaults = true,
	    version = ADDON_VERSION,
	 
   slashCommand = "/osi",
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
		default = "Oblivion Style UI",
		warning = "You must reload the UI twice for all the textures to change over properly!",
        getFunc = function() return osi.SV.Icon end,
        setFunc = function(val) osi.SV.Icon = val end,
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

function osi:initLAM()
	LAM:RegisterOptionControls("OblivionStyleHUDOptions", optionsData)
	LAM:RegisterAddonPanel("OblivionStyleHUDOptions", panelData)
end