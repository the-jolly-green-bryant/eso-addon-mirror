-- Initialize file
ZDAT              = ZDAT or {}
ZDAT.UI           = ZDAT.UI or {}
ZDAT.UI.Constants = {
	-- fonts
	defaultFont     = "$(MEDIUM_FONT)|$(KB_18)|soft-shadow-thin",
	boldFont        = 'ZoFontGameBold',
	smallFont       = "ZoFontGameSmall",
	fixedWidthFont  = "$(EsoUI/Common/Fonts/consola.ttf)|$(KB_15)|soft-shadow-thin",

	-- rgb colors
	rgbClear		= {1,1,1,0},
	rgbWhite        = {1,1,1,.9},
	rgbGray         = {1,1,1,.35},
	rgbBlue   		= {128/255, 128/255, 1, 1},
	rgbGold			= {230/225, 230/225, 180/225, 1},
	rgbGreen        = {0.2, 1, 0.2, 1},

	-- hex colors
	hexBlue         = 'c8080ff',
	hexGold			= 'cc5c29e',
	
	-- alpha
	whiteAlpha      = 1,
	grayAlpha       =.45,

	-- sizes
	labelHeight     = 23,
	iconSize        = 23,
	spacer          = 5,
	navIconSize     = 35,

	-- textures
	texture = {
		CHECKOFF  = 'esoui/art/cadwell/checkboxicon_unchecked.dds',
		CHECKON   = 'esoui/art/cadwell/checkboxicon_checked.dds',
		CHECK     = "esoui/art/buttons/accept_down.dds", 
		BOX       = "esoui/art/buttons/swatchframe_down.dds",
		X         = "esoui/art/buttons/decline_up.dds",
	  },
}
