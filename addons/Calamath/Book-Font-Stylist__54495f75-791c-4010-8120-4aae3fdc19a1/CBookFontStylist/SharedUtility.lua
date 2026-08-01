--
-- Calamath's BookFont Stylist [CBFS]
--
-- Copyright (c) 2020 Calamath
--
-- This software is released under the Artistic License 2.0
-- https://opensource.org/licenses/Artistic-2.0
--

if not CBookFontStylist then return end
local CBFS = CBookFontStylist:SetSharedEnvironment()
-- ---------------------------------------------------------------------------------------

-- Font Style Conversion (string ---> enum)
local FONT_STYLE_STRING_MAP = {
	["normal"] = FONT_STYLE_NORMAL, 
}
for fontStyle = FONT_STYLE_ITERATION_BEGIN, FONT_STYLE_ITERATION_END do
	FONT_STYLE_STRING_MAP[GetFontStyleString(fontStyle)] = fontStyle
end
local function GetFontStyle(strFontStyle)
	return FONT_STYLE_STRING_MAP[strFontStyle or ""]
end
CBFS:RegisterSharedObject("GetFontStyle", GetFontStyle)
-- * GetFontStyle(*string* _strFontStyle_)
-- ** _Returns:_ *[FontStyle|#FontStyle]* _fontStyle_


-- Extended Book Medium Font Definitions
local extendedBookMediumFont = {
	[BOOK_MEDIUM_ANTIQUITY_CODEX] = {
		keyboard = {
			body	= "ZoFontBookScroll", 
			title	= "ZoFontBookScrollTitle", 
		}, 
		gamepad = {
			body	= "ZoFontGamepadBookScroll", 
			title	= "ZoFontGamepadBookScrollTitle", 
		}, 
	}, 
}
local extendedBookMediumTexture = {
	[BOOK_MEDIUM_ANTIQUITY_CODEX] 	= "EsoUI/Art/Antiquities/codex_document.dds", 
}

local function GetExtendedBookMediumTexture(extendedMediumId)
	return extendedBookMediumTexture[extendedMediumId] or (GetBookMediumInfo(extendedMediumId))
end
CBFS:RegisterSharedObject("GetExtendedBookMediumTexture", GetExtendedBookMediumTexture)
-- * GetExtendedBookMediumTexture(*integer* _mediumId_)
-- ** _Returns:_ *string* _texture_

local function GetExtendedBookMediumFontInfo(extendedMediumId, isGamepad)
	if extendedBookMediumFont[extendedMediumId or ""] then
		local font = extendedBookMediumFont[extendedMediumId][isGamepad and "gamepad" or "keyboard"]
		if _G[font.title] and _G[font.body] then
			local titleFontFace, titleFontSize, titleFontStyleStr = _G[font.title]:GetFontInfo()
			local bodyFontFace, bodyFontSize, bodyFontStyleStr = _G[font.body]:GetFontInfo()
			return titleFontFace, titleFontSize, GetFontStyle(titleFontStyleStr), bodyFontFace, bodyFontSize, GetFontStyle(bodyFontStyleStr)
		end
	else
		return GetBookMediumFontInfo(extendedMediumId, isGamepad)
	end
end
CBFS:RegisterSharedObject("GetExtendedBookMediumFontInfo", GetExtendedBookMediumFontInfo)
-- * GetExtendedBookMediumFontInfo((*integer* _mediumId_, *bool* _isGamepad_)
-- ** _Returns:_ *string* _titleFontFace_, *integer* _titleFontSize_, *[FontStyle|#FontStyle]* _titleFontStyle_, *string* _bodyFontFace_, *integer* _bodyFontSize_, *[FontStyle|#FontStyle]* _bodyFontStyle_

local function ExtendedBookMediumIdIterator()
	local mediumId = BOOK_MEDIUM_ITERATION_BEGIN - 1
	local nextKey = next(extendedBookMediumFont)
	return function()
		if mediumId < BOOK_MEDIUM_ITERATION_END then
			mediumId = mediumId + 1
			return mediumId
		else
			while nextKey do
				local extendedMediumId = nextKey
				nextKey = next(extendedBookMediumFont, nextKey)
				return extendedMediumId
			end
		end
	end
end
CBFS:RegisterSharedObject("ExtendedBookMediumIdIterator", ExtendedBookMediumIdIterator)
