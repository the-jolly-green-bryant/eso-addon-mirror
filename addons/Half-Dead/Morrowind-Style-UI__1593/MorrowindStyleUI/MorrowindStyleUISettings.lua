local LAM = LibStub( 'LibAddonMenu-2.0')

local ADDON_VERSION = "1.14"

local iconTexturesList = {
	[1] = "Vanilla UI",
	[2] = "Morrowind Style UI",
}

local panelData = {
	    type = "panel",
	    name = "Morrowind Style UI",
	    displayName = ZO_HIGHLIGHT_TEXT:Colorize("Morrowind Style UI"),
	    author = "Half-Dead",
		registerForDefaults = true,
	    version = ADDON_VERSION,
	 
   slashCommand = "/msi",
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
		default = "Morrowind Style UI",
		warning = "You must reload the UI twice for all the textures to change over properly!",
        getFunc = function() return msi.SV.Icon end,
        setFunc = function(val) msi.SV.Icon = val end,
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

function msi:initLAM()
	LAM:RegisterOptionControls("MorrowindStyleUIOptions", optionsData)
	LAM:RegisterAddonPanel("MorrowindStyleUIOptions", panelData)
end