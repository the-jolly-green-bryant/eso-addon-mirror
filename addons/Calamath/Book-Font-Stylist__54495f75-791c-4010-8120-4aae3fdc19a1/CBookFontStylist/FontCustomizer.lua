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
local LMP = LibMediaProvider

-- ---------------------------------------------------------------------------------------
-- Font Customizer Class                                                         rel.2.0.3
-- ---------------------------------------------------------------------------------------
-- This class provides functionality  to temporarily replace font objects.
--
local CBFS_FontCustomizer_Singleton = ZO_InitializingObject:Subclass()

do
	local lmpPredefinedFontKeys = {
		["Univers 57"] = true, 
		["Univers 67"] = true, 
		["ProseAntique"] = true, 
		["Skyrim Handwritten"] = true, 
		["Trajan Pro"] = true, 
		["Futura Condensed"] = true, 
		["Futura Condensed Bold"] = true, 
		["Futura Condensed Light"] = true, 
		["JP-StdFont"] = true, 
		["JP-ChatFont"] = true, 
		["JP-KafuPenji"] = true, 
		["ZH-StdFont"] = true, 
		["ZH-MYoyoPRC"] = true, 
		["Univers 55"] = true, 
		["Consolas"] = true, 
	}

	--	Antiquity Codex Fonts
	local zosFontNames = {
		"ZoFontGamepadBookScroll", 
		"ZoFontGamepadBookScrollTitle", 
	}
	if IsKeyboardUISupported() then
		zosFontNames[#zosFontNames + 1] = "ZoFontBookScroll"
		zosFontNames[#zosFontNames + 1] = "ZoFontBookScrollTitle"
	end

	function CBFS_FontCustomizer_Singleton:Initialize()
		self.name = "CBFS-FontCustomizerSingleton"
		self.workspaceFont = CreateFont("cbfsWorkspaceUtilityFont", "$(MEDIUM_FONT)|12")
		self.customizedFontList = {}

		self.lmpHashTable = LMP:HashTable("font")

		self.fontKeyReverseLookup = {}	-- We often want to reverse lookup which font key is this font face.
		-- order matters, register predefined fonts first.
		for fontKey in pairs(lmpPredefinedFontKeys) do
			self:InsertFontKeyReverseLookup(fontKey)
		end
		for _, fontKey in ipairs(LMP:List("font")) do
			if not lmpPredefinedFontKeys[fontKey] then
				self:InsertFontKeyReverseLookup(fontKey)
			end
		end
		CALLBACK_MANAGER:RegisterCallback("LibMediaProvider_Registered", function(mediatype, key)
			if mediatype == "font" then
				self:InsertFontKeyReverseLookup(key)
--				CBFS.LDL:Debug("Registered new LMP font: ", key)
			end
		end)

		self.defaultFonts = {}
		for _, fontObjectName in ipairs(zosFontNames) do
		-- for preserve the initial state of the zos fonts,
			local fontObject = _G[fontObjectName]
			if fontObject then
				local fontFace, fontSize, strFontStyle = fontObject:GetFontInfo()
				self.defaultFonts[fontObjectName] = {
					fontFace = fontFace, 
					fontSize = fontSize, 
					fontStyle = GetFontStyle(strFontStyle), 
					fontDescriptor = self:MakeFontDescriptor(fontFace, fontSize, strFontStyle), 
				}
			end
		end
	end
end

function CBFS_FontCustomizer_Singleton:InsertFontKeyReverseLookup(fontKey)
	fontKey = fontKey or ""
	self.workspaceFont:SetFont(self.lmpHashTable[fontKey] or "")
	local fontFace = self.workspaceFont:GetFontInfo()
	if fontFace ~= "" then
		local lowercaseFontFace = zo_strlower(fontFace)
		self.fontKeyReverseLookup[lowercaseFontFace] = self.fontKeyReverseLookup[lowercaseFontFace] or fontKey
	end
end

function CBFS_FontCustomizer_Singleton:GetFontKeyByFontFace(fontDescriptor)
	self.workspaceFont:SetFont(fontDescriptor or "")
	local fontFace = self.workspaceFont:GetFontInfo()
	return self.fontKeyReverseLookup[zo_strlower(fontFace)]
end

function CBFS_FontCustomizer_Singleton:GetFontDescriptorInfo(fontDescriptor)
-- ** _Returns:_ *string* _fontFace_, *integer* _fontSize_, *string* _strFontStyle_
-- Hint: We often want to know the entity value indicated by a font string such as "$(BOLD_FONT)" or "$(KB_18)".
	if type(fontDescriptor) == "string" then
		self.workspaceFont:SetFont(fontDescriptor)
		return self.workspaceFont:GetFontInfo()
	end
end

function CBFS_FontCustomizer_Singleton:MakeFontDescriptor(fontFace, fontSize, fontStyle)
-- 'fontFace' should contain a valid filepath string of the target slug file.
	if type(fontStyle) == "number" then
		fontStyle = GetFontStyleString(fontStyle)
	end
	if fontStyle and fontStyle ~= "" then
		return string.format("%s|%s|%s", fontFace, tostring(fontSize), fontStyle)
	else
		return string.format("%s|%s", fontFace, tostring(fontSize))
	end
end

function CBFS_FontCustomizer_Singleton:GetFontFaceByLMP(fontKey)
	return self.lmpHashTable[fontKey] or LMP:GetDefault("font")
end

function CBFS_FontCustomizer_Singleton:MakeFontDescriptorByLMP(fontKey, fontSize, fontStyle)
	return self:MakeFontDescriptor(self.lmpHashTable[fontKey] or LMP:GetDefault("font"), fontSize, fontStyle)
end

function CBFS_FontCustomizer_Singleton:GetDefaultFontInfo(fontObjectName)
	local defaultFontInfo = self.defaultFonts[fontObjectName]
	if defaultFontInfo then
		return defaultFontInfo.fontFace, defaultFontInfo.fontSize, defaultFontInfo.fontStyle
	end
end

function CBFS_FontCustomizer_Singleton:GetDefaultFontFaceName(fontObjectName)
	return self.defaultFonts[fontObjectName] and self.defaultFonts[fontObjectName].fontFace
end

function CBFS_FontCustomizer_Singleton:GetDefaultFontSize(fontObjectName)
	return self.defaultFonts[fontObjectName] and self.defaultFonts[fontObjectName].fontSize
end

function CBFS_FontCustomizer_Singleton:GetDefaultFontStyle(fontObjectName)
	return self.defaultFonts[fontObjectName] and self.defaultFonts[fontObjectName].fontStyle
end

function CBFS_FontCustomizer_Singleton:GetDefaultFontDescriptor(fontObjectName)
	return self.defaultFonts[fontObjectName] and self.defaultFonts[fontObjectName].fontDescriptor
end

function CBFS_FontCustomizer_Singleton:GetDefaultFontKey(fontObjectName)
	local defaultFontFace = self:GetDefaultFontFaceName(fontObjectName)
	if defaultFontFace then
		return self.fontKeyReverseLookup[zo_strlower(defaultFontFace)]
	end
end

function CBFS_FontCustomizer_Singleton:IsCustomized(fontObjectName)
	return fontObjectName and self.customizedFontList[fontObjectName] or false
end

function CBFS_FontCustomizer_Singleton:CustomizeFont(fontObjectName, fontDescriptor)
	-- We only customize fonts that can be reverted.
	local fontObject = _G[fontObjectName]
	if fontObject and fontObject.SetFont and self.defaultFonts[fontObjectName] then
		fontObject:SetFont(fontDescriptor)
--		CBFS.LDL:Debug("changed: %s -> %s", tostring(fontObjectName), tostring(fontDescriptor))
		self.customizedFontList[fontObjectName] = true
	end
end

function CBFS_FontCustomizer_Singleton:ResetFontToDefault(fontObjectName)
	local fontObject = _G[fontObjectName]
	if fontObject and fontObject.SetFont then
		local fontDescriptor = self:GetDefaultFontDescriptor(fontObjectName)
		if fontDescriptor then
			fontObject:SetFont(fontDescriptor)
--			CBFS.LDL:Debug("reverted: %s -> %s", tostring(fontObjectName), tostring(self.defaultFonts[fontObjectName].fontDescriptor))
			self.customizedFontList[fontObjectName] = nil
		end
	end
end

function CBFS_FontCustomizer_Singleton:ResetAllFontsToDefault()
	for fontObjectName in pairs(self.customizedFontList) do
		_G[fontObjectName]:SetFont(self.defaultFonts[fontObjectName].fontDescriptor)
--		CBFS.LDL:Debug("reverted: %s -> %s", tostring(fontObjectName), tostring(self.defaultFonts[fontObjectName].fontDescriptor))
		self.customizedFontList[fontObjectName] = nil
	end
end

-- ---------------------------------------------------------------------------------------

local CBFS_FONT_MANAGER = CBFS_FontCustomizer_Singleton:New()	-- Never do this more than once!
-- NOTE: The font manager must be prepared prior to EVENT_ADD_ON_LOADED.

-- global API --
local function GetFontManager() return CBFS_FONT_MANAGER end
CBFS:RegisterSharedObject("GetFontManager", GetFontManager)
