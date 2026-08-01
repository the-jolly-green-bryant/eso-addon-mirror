
--Register LAM with LibStub
local MAJOR, MINOR = "LibFonts", 1
local libfonts, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not libfonts then return end	--the same or newer version of this lib is already loaded into memory 

LIBFONTS_BOLD 			= 1
LIBFONTS_MEDIUM 		= 2
LIBFONTS_CHAT			= 3
LIBFONTS_ANTIQUE		= 4
LIBFONTS_HANDWRITTEN	= 5
LIBFONTS_STONE_TABLET	= 6
LIBFONTS_GAMEPAD_BOLD	= 7
LIBFONTS_GAMEPAD_MEDIUM	= 8

LIBFONTS_OUTLINE_NONE	= 1
LIBFONTS_OUTLINE_SHADOW	= 2
LIBFONTS_OUTLINE_SHADOW_THIN	= 3
LIBFONTS_OUTLINE_SHDAOW_THICK	= 4

local fonts = {
	[LIBFONTS_BOLD] 			= {name = "Bold", 			font = "BOLD_FONT"},
	[LIBFONTS_MEDIUM] 			= {name = "Medium", 		font = "MEDIUM_FONT"},
	[LIBFONTS_CHAT] 			= {name = "Chat", 			font = "CHAT_FONT"},
	[LIBFONTS_ANTIQUE] 			= {name = "Antique", 		font = "ANTIQUE_FONT"},
	[LIBFONTS_HANDWRITTEN] 		= {name = "Handwritten", 	font = "HANDWRITTEN_FONT"},
	[LIBFONTS_STONE_TABLET] 	= {name = "Stone Tablet", 	font = "STONE_TABLET_FONT"},
	[LIBFONTS_GAMEPAD_BOLD] 	= {name = "Gamepad Bold", 	font = "GAMEPAD_BOLD_FONT"},
	[LIBFONTS_GAMEPAD_MEDIUM] 	= {name = "Gamepad Medium", font = "GAMEPAD_MEDIUM_FONT"},
}

local fontOutlines = {
	[LIBFONTS_OUTLINE_NONE] 		= {name = "None"},
	[LIBFONTS_OUTLINE_SHADOW] 		= {name = "Shadow", 			outline = "shadow"},
	[LIBFONTS_OUTLINE_SHADOW_THIN] 	= {name = "Soft Thin Shadow", 	outline = "soft-shadow-thin"},
	[LIBFONTS_OUTLINE_SHDAOW_THICK]	= {name = "Soft Thick Shadow", 	outline = "soft-shadow-thick"},
}

--*****************************************--
-- FONT FUNCTIONS
--*****************************************--
function libfonts:GetFontChoices()
	local choices = {}
	
	for libFontType, fontData in ipairs(fonts) do
		choices[libFontType] = fontData.name
	end
	return choices
end
function libfonts:GetFontNameByLibFontType(libFontType)
	return fonts[libFontType].name
end

function libfonts:GetLibFontTypeByName(name)
	for libFontType, fontData in ipairs(fonts) do
		if fontData.name == name then
			return libFontType
		end
	end
	-- fallback in case I do something stupid & change the font names users wont get an error
	-- due to not being able to find the font name, it will probably change the font on them,
	-- but thats better than an error.
	return LIBFONTS_BOLD
end
function libfonts:GetFontByName(name)
	for libFontType, fontData in ipairs(fonts) do
		if fontData.name == name then
			return fontData.font
		end
	end
	-- fallback in case I do something stupid & change the font names users wont get an error
	-- due to not being able to find the font name, it will probably change the font on them,
	-- but thats better than an error.
	return fonts[LIBFONTS_BOLD].font
end
function libfonts:GetFontByLibFontType(libFontType)
	return fonts[libFontType].font
end

--*****************************************--
-- FONT OUTLINE FUNCTIONS
--*****************************************--
function libfonts:GetFontOutlineChoices()
	local choices = {}

	for libFontOutlineType, outlineData in ipairs(fontOutlines) do
		choices[libFontOutlineType] = outlineData.name
	end
	return choices
end
function libfonts:GetFontOutlineByName(name)
	for libFontOutlineType, outlineData in ipairs(fontOutlines) do
		if outlineData.name == name then
			return outlineData.outline
		end
	end
	-- return nil, same as no outline
	--return fontOutlines[LIBFONTS_OUTLINE_NONE].outline
end

--*****************************************--
-- FONT STRING FUNCTIONS 
--*****************************************--
-- font string layout example: "$(BOLD_FONT)|30|soft-shadow-thick"
function libfonts:GetFontStringByLibFontType(libFontType, size, outline)
	local font = fonts[libFontType].font
	
	if outline then
		return zo_strformat("$(<<1>>)|<<2>>|<<3>>", font, size, outline)
	end
	
	return zo_strformat("$(<<1>>)|<<2>>", font, size)
end

function libfonts:BuildFontString(font, size, outline)
	if outline then
		return zo_strformat("$(<<1>>)|<<2>>|<<3>>", font, size, outline)
	end
	
	return zo_strformat("$(<<1>>)|<<2>>", font, size)
end


