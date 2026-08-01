  ---------------------------------------
  -- Advanced Nameplates
  -- Tierney11290 (Stratejacket) - 2017
  ---------------------------------------

ANP = ANP or {}


local FontList = {
	"Adventure",
	"Arialn",
	"Consolas",
	"ESO Cartographer",
	"Fitzgerald",
	"Futura Condensed",
	"Futura Condensed Medium",
	"Gentium",
	"Hooked Up",
	"ProseAntique",
	"Skurri",
	"Skyrim Handwritten",
	"Trajan Pro",
	"Univers 55",
	"Univers 57",
	"Univers 67",
}

local StyleList = {
    "none",
    "outline",
    "thin-outline",
    "thick-outline",
    "shadow",
    "soft-shadow-thin",
    "soft-shadow-thick",
}

local ANPpanel = {
	    type = "panel",
	    name = "Advanced Nameplates",
	    displayName = ZO_HIGHLIGHT_TEXT:Colorize("Advanced Nameplates"),
	    author = "Tierney11290 (Stratejacket), |c66ccffErian Kalil|r",
	    version = "1.3",
	    slashCommand = "/anp",
		registerForRefresh = true,
        registerForDefaults = true,
}

local LAM = LibStub( 'LibAddonMenu-2.0', true )
	if ( not LAM ) then return end

local ANPoptions = { 
	{
	    type = "header",
		name = "Keyboard Nameplates",
		registerForRefresh = true,
        registerForDefaults = true,
	},
	{
		type = "dropdown",
		name = "Font",
		tooltip = "Changes the look of the text in Keyboard Mode.",
		choices = FontList,
		default = "Univers 57",
		getFunc = function() return ANP.SV.FontsKB end,
		setFunc = function(val) 
			ANP.SV.FontsKB = val 
			ANP.Fonts(val)
		end,
	},
	{
		type = "dropdown",
		name = "Style",
		tooltip = "This does not work yet. Changes the style of the text in Keyboard Mode.",
		choices = StyleList,
		getFunc = function() return ANP.SV.StylesKB end,
		setFunc = function(val) ANP.SV.StylesKB = val end,
	},
	{
	 	type = "slider",
		name = "Size",
		tooltip = "This does not work yet. Move the slider to change the text size",
		min = 1,
		max = 100,
		step = 1,
		getFunc = function() return ANP.SV.SizeKB end,
		setFunc = function(val) 
			ANP.SV.SizeKB = val
            ANP.SizeKB(val)
        end,
	},	
	{
	    type = "header",
		name = "Gamepad Nameplates",
		registerForRefresh = true,
        registerForDefaults = true,
	},
	{
		type = "dropdown",
		name = "Font",
		tooltip = "Changes the look of the text in Gamepad Mode.",
		choices = FontList,
		defaults = "Futura Condensed",
		getFunc = function() return ANP.SV.FontsGP end,
		setFunc = function(val) ANP.SV.FontsGP = val 
		  ANP.Fonts(val)
		end,
	},
	{
		type = "dropdown",
		name = "Style",
		tooltip = "This does not work yet. Changes the style of the text in Gamepad Mode.",
		choices = StyleList,
		getFunc = function() return ANP.SV.StylesGP end,
		setFunc = function(val) ANP.SV.StylesGP = val end,
	},
	{
	 	type = "slider",
		name = "Size",
		tooltip = "This does not work yet. Move the slider to change the text size",
		min = 1,
		max = 100,
		step = 1,
		getFunc = function() return ANP.SV.SizeKB end,
		setFunc = function(val) 
			ANP.SV.SizeGP = val
            ANP.SizeGP(val)
        end,
	},
	}

function ANP:initLAM()
	LAM:RegisterAddonPanel("Advanced Nameplates", ANPpanel)
	LAM:RegisterOptionControls("Advanced Nameplates", ANPoptions)
end