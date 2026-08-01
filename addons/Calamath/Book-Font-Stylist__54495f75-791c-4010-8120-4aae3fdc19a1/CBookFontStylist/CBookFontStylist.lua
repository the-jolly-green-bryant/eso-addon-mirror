--
-- Calamath's BookFont Stylist [CBFS]
--
-- Copyright (c) 2020 Calamath
--
-- This software is released under the Artistic License 2.0
-- https://opensource.org/licenses/Artistic-2.0
--
-- Note :
-- This addon works that uses the library LibMediaProvider-1.0 by Seerah, released under the LGPL-2.1 license.
-- This addon works that uses the library LibAddonMenu-2.0 by sirinsidiator, Seerah, released under the Artistic License 2.0
-- You will need to obtain the above libraries separately.
--

-- ---------------------------------------------------------------------------------------
-- CT_MinimalAddonFramework: Minimal Add-on Framework Template Class            rel.1.1.12
-- ---------------------------------------------------------------------------------------
local CT_MinimalAddonFramework = ZO_Object:Subclass()
function CT_MinimalAddonFramework:New(...)
	local newObject = setmetatable({}, self)
	newObject:Initialize(...)
	newObject:ConfigDebug()
	newObject:OnInitialized(...)
	return newObject
end
function CT_MinimalAddonFramework:Initialize(name, attributes)
	if type(name) ~= "string" or name == "" then return end
	self._name = name
	self._isInitialized = false
	if type(attributes) == "table" then
		for k, v in pairs(attributes) do
			if self[k] == nil then
				self[k] = v
			end
		end
	end
	self._external = {
		name = self.name or self._name, 
		version = self.version, 
		author = self.author, 
	}
	assert(not _G[name], name .. " is already loaded.")
	_G[name] = self._external
	EVENT_MANAGER:RegisterForEvent(self._name, EVENT_ADD_ON_LOADED, function(event, addonName)
		if addonName ~= self._name then return end
		EVENT_MANAGER:UnregisterForEvent(self._name, EVENT_ADD_ON_LOADED)
		self:OnAddOnLoaded(event, addonName)
		self._isInitialized = true
	end)
end
function CT_MinimalAddonFramework:ConfigDebug()
	local Dummy = function() end
	self.LDL = { Verbose = Dummy, Debug = Dummy, Info = Dummy, Warn = Dummy, Error = Dummy, }
	self._isDebugMode = false
end
function CT_MinimalAddonFramework:OnInitialized(name, attributes)
--  Available when overridden in an inherited class
end
function CT_MinimalAddonFramework:OnAddOnLoaded(event, addonName)
--  Should be Overridden
end

-- ---------------------------------------------------------------------------------------
-- CT_SimpleAddonFramework: Simple Add-on Framework Template Class              rel.1.1.12
-- ---------------------------------------------------------------------------------------
local CT_SimpleAddonFramework = CT_MinimalAddonFramework:Subclass()
function CT_SimpleAddonFramework:Initialize(name, attributes)
	CT_MinimalAddonFramework.Initialize(self, name, attributes)
	if self._external then
		self._class = {}
		self._shared = nil
		self._external.RegisterClassObject = function(_, ...) self:RegisterClassObject(...) end
	end
end
function CT_SimpleAddonFramework:ConfigDebug(auth)
	local debugMode = false
	auth = auth or self.authority
	if type(auth) == "table" then
		local key = HashString(GetDisplayName())
		for _, v in pairs(auth) do
			if key == v then debugMode = true end
		end
	end
	if debugMode then
		if not self._logger then
			if not IsConsoleUI() and LibDebugLogger then
				self._logger = LibDebugLogger(self._name)
			else
				local Printf = function(_, ...) df(...) end
				self._logger = { Verbose = Printf, Debug = Printf, Info = Printf, Warn = Printf, Error = Printf, }
			end
		end
		self.LDL = self._logger
	else
		local Dummy = function() end
		self.LDL = { Verbose = Dummy, Debug = Dummy, Info = Dummy, Warn = Dummy, Error = Dummy, }
	end
	self._isDebugMode = debugMode
end
function CT_SimpleAddonFramework:RegisterClassObject(className, classObject)
	if className and classObject and not self._class[className] then
		self._class[className] = classObject
		return true
	else
		return false
	end
end
function CT_SimpleAddonFramework:HasAvailableClass(className)
	if className then
		return self._class[className] ~= nil
	end
end
function CT_SimpleAddonFramework:CreateClassObject(className, ...)
	if className and self._class[className] then
		return self._class[className]:New(...)
	end
end

-- ---------------------------------------------------------------------------------------
-- CT_AddonFramework: Add-on Framework Template Class for multiple modules      rel.1.1.12
-- ---------------------------------------------------------------------------------------
local CT_AddonFramework = CT_SimpleAddonFramework:Subclass()
function CT_AddonFramework:Initialize(name, attributes)
	CT_SimpleAddonFramework.Initialize(self, name, attributes)
	if not self._external then return end
	self._shared = {
		name = self._name, 
		version = self.version, 
		author = self.author, 
		LDL = self.LDL, 
		HasAvailableClass = function(_, ...) return self:HasAvailableClass(...) end, 
		CreateClassObject = function(_, ...) return self:CreateClassObject(...) end, 
		RegisterGlobalObject = function(_, ...) return self:RegisterGlobalObject(...) end, 
		RegisterSharedObject = function(_, ...) return self:RegisterSharedObject(...) end, 
	}
	self._external.SetSharedEnvironment = function()
		-- This method is intended to be called in the main chunk and should not be called inside functions.
		self:EnableCustomEnvironment(self._env, 3)	-- [Main Chunk]: self._external:SetSharedEnvironment() -> self:EnableCustomEnvironment(t, 3) -> setfenv(3, t)
		return self._shared
	end
	if self._enableCallback then
		self._callbackObject = ZO_CallbackObject:New()
		self.RegisterCallback = function(self, ...) return self._callbackObject:RegisterCallback(...) end
		self.UnregisterCallback = function(self, ...) return self._callbackObject:UnregisterCallback(...) end
		self.FireCallbacks = function(self, ...) return self._callbackObject:FireCallbacks(...) end
		self._shared.RegisterCallback = function(_, ...) return self._callbackObject:RegisterCallback(...) end
		self._shared.UnregisterCallback = function(_, ...) return self._callbackObject:UnregisterCallback(...) end
		self._shared.FireCallbacks = function(_, ...) return self._callbackObject:FireCallbacks(...) end
		self._external.FireCallbacks = function(_, ...) return self._callbackObject:FireCallbacks(...) end
	end
	if self._enableEnvironment then
		self:EnableCustomEnvironment(self._env, 4)	-- [Main Chunk]: self:New() -> self:Initialize() -> EnableCustomEnvironment(t, 4) -> setfenv(4, t)
	end
end
function CT_AddonFramework:ConfigDebug(auth)
	CT_SimpleAddonFramework.ConfigDebug(self, auth)
	if self._shared then
		self._shared.LDL = self.LDL
	end
end
function CT_AddonFramework:CreateCustomEnvironment(t, parent)	-- helper function
-- This method is intended to be called in the main chunk and should not be called inside functions.
	return setmetatable(type(t) == "table" and t or {}, { __index = type(parent) == "table" and parent or getfenv and type(getfenv) == "function" and getfenv(2) or _ENV or _G, })
end
function CT_AddonFramework:EnableCustomEnvironment(t, stackLevel)	-- helper function
	local stackLevel = type(stackLevel) == "number" and stackLevel > 1 and stackLevel or type(ZO_GetCallstackFunctionNames) == "function" and #(ZO_GetCallstackFunctionNames()) + 1 or 2
	local env = type(t) == "table" and t or type(self._env) == "table" and self._env
	if env then
		if setfenv and type(setfenv) == "function" then
			setfenv(stackLevel, env)
		else
			_ENV = env
		end
	end
end
function CT_AddonFramework:RegisterGlobalObject(objectName, globalObject)
	if objectName and globalObject and _G[objectName] == nil then
		_G[objectName] = globalObject
		return true
	else
		return false
	end
end
function CT_AddonFramework:RegisterSharedObject(objectName, sharedObject)
	if objectName and sharedObject and self._env and not self._env[objectName] then
		self._env[objectName] = sharedObject
		return true
	else
		return false
	end
end

-- ---------------------------------------------------------------------------------------
-- CBookFontStylist
-- ---------------------------------------------------------------------------------------
local _SHARED_DEFINITIONS = {
	-- extendedMediumId
	FORMAT_V2					= 2, 
	BOOK_MEDIUM_ANTIQUITY_CODEX = 1001, 

	FORMAT_V1					= 1, -- obsolete
	BMID_ANTIQUITY_CODEX		= 99, -- obsolete

	-- order matters: must be same as the return value index for GetBookMediumFontInfo API
	TITLE_FONT_KEY				= 1, 
	TITLE_FONT_FACE				= 1, 
	TITLE_FONT_SIZE				= 2, 
	TITLE_FONT_STYLE			= 3, 
	BODY_FONT_KEY				= 4, 
	BODY_FONT_FACE				= 4, 
	BODY_FONT_SIZE				= 5, 
	BODY_FONT_STYLE				= 6. 
}

local _ENV = CT_AddonFramework:CreateCustomEnvironment(_SHARED_DEFINITIONS)
local CBFS = CT_AddonFramework:New("CBookFontStylist", {
	name = "CBookFontStylist", 
	version = "5.0.2", 
	author = "Calamath", 
	savedVars = "CBookFontStylistDB", 
	savedVarsVersion = 1, 
	authority = {2973583419,210970542},  
	maxPreset = 1, 
	_env = _ENV, 
	_enableEnvironment = true, 
})
-- ---------------------------------------------------------------------------------------
local CBFS_DB_DEFAULT = {
	config = {
	}, 
}

function CBFS:OnAddOnLoaded()
	self.lang = GetCVar("Language.2")
	self.isGamepad = IsInGamepadPreferredMode()
	self.fontManager = GetFontManager()

	self.isUnofficialLanguage = self.lang ~= ZoGetOfficialGameLanguageDescriptor()
	self.customFontMode = false
	self:OverrideGetBookMediumFontInfoAPI()

	-- CBookFontStylist Config
	self.db = ZO_SavedVars:NewAccountWide(self.savedVars, 1, nil, CBFS_DB_DEFAULT)
	self:ValidateConfigData()	-- NOTE: we create savedata field on first boot in each language mode.

	if IsConsoleUI() or IsGameCoreUI() then
		-- LHAS setting panel
		self.settingPanel = self:CreateClassObject("CBFS_LHASSettingPanel", "Book Font Stylist", self.db, self.db, CBFS_DB_DEFAULT)
	else
		-- LAM setting panel
		self.fontPreviewWindow = self:CreateClassObject("CBFS_FontPreviewWindow", CBFS_UI_PreviewWindow)
		self.settingPanel = self:CreateClassObject("CBFS_LAMSettingPanel", "CBookFontStylist_Options", self.db, self.db, CBFS_DB_DEFAULT)
		self.settingPanel:RegisterFontPreviewWindow(self.fontPreviewWindow)
	end

	-- for lore books
	-- NOTE: We hook LORE_READER to be more inclusive rather than adding callbacks to individual lore reader scenes since future updates may add a new custom lore reader scene.
	ZO_PreHook(LORE_READER, "Show", function()
		self:SetCustomFontMode(true)
	end)
	ZO_PreHook(LORE_READER, "OnHide", function()
		self:SetCustomFontMode(false)
	end)

	-- for antiquity codex
	-- NOTE: We could not access the lore dialog displayed when you discovered an antiquity codex, because its scene belongs in the internal Antiquity Digging mini-game.
	--       Here you can customize the font when reading the codex from the journal scene.
	if ANTIQUITY_LORE_KEYBOARD then
		ZO_PreHook(ANTIQUITY_LORE_KEYBOARD, "Refresh", function()
--			self.LDL:Debug("ANTIQUITY_LORE_KEYBOARD:Refresh :")
			self:CustomizeAntiquityCodexFont()
		end)
	end
	if ANTIQUITY_LORE_KEYBOARD_SCENE then
		ANTIQUITY_LORE_KEYBOARD_SCENE:RegisterCallback("StateChange", function(oldState, newState)
			if newState == SCENE_HIDDEN then
--				self.LDL:Debug("SCENE[antiquityLoreKeyboard] state change : %s to %s", tostring(oldState), tostring(newState))
				self:ResetAntiquityCodexFontToDefault()
			end
		end)
	end
	if ANTIQUITY_LORE_GAMEPAD then
		ZO_PreHook(ANTIQUITY_LORE_GAMEPAD, "RefreshLoreList", function()
--			self.LDL:Debug("ANTIQUITY_LORE_GAMEPAD:RefreshLoreList :")
			self:CustomizeAntiquityCodexFont()
		end)
	end
	if ANTIQUITY_LORE_SCENE_GAMEPAD then
		ANTIQUITY_LORE_SCENE_GAMEPAD:RegisterCallback("StateChange", function(oldState, newState)
			if newState == SCENE_HIDDEN then
--				self.LDL:Debug("SCENE[gamepad_antiquity_lore] state change : %s to %s", tostring(oldState), tostring(newState))
				self:ResetAntiquityCodexFontToDefault()
			end
		end)
	end

	-- For avoidance of layout glitches in the lore reader.
	-- NOTE: Even if the font object is modified, the change is not immediately reflected to a label control, and refresh may be delayed until the next frame or later.
	--       To avoid glitches in the layout of the lore reader due to this nature, the label text should be erased before LayoutText.
	--       This magic code ensures that the label text is always updated in LayoutText to promote immediate label refresh.
	ZO_PreHook(LORE_READER, "LayoutText", function(loreReader)
		if loreReader.title then
			loreReader.title:SetText("")
		end
		if loreReader.firstPage.body then
			loreReader.firstPage.body:SetText("")
		end
		if loreReader.secondPage.body then
			loreReader.secondPage.body:SetText("")
		end
		if loreReader.overrideImageTitle then
			loreReader.overrideImageTitle:SetText("")
		end
	end)

	-- Deferred Initialization
	local DoOnce = true
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, function() self:PerformDeferredInitialization() end, DoOnce)
end

function CBFS:PerformDeferredInitialization()
	-- UI initialization
	self.settingPanel:InitializeSettingPanel()
end

function CBFS:ValidateConfigData()
	if not self.db.config[self.lang] then
		self.db.config[self.lang] = {}
	end
	if not self.db.config[self.lang][FORMAT_V2] then
		self.db.config[self.lang][FORMAT_V2] = {}
	end

	local config = self.db.config[self.lang][FORMAT_V2]
	if self.db.config[self.lang][FORMAT_V1] then
		-- convert savedata V1 --> V2
		local oldConfig = self.db.config[self.lang][FORMAT_V1]
		for mediumId = BOOK_MEDIUM_ITERATION_BEGIN, BOOK_MEDIUM_ITERATION_END do
			if oldConfig[mediumId] then
				config[mediumId] = {
					[TITLE_FONT_KEY] = oldConfig[mediumId].titleStyle, 
					[TITLE_FONT_SIZE] = oldConfig[mediumId].titleSize, 
					[TITLE_FONT_STYLE] = GetFontStyle(oldConfig[mediumId].titleWeight), 
					[BODY_FONT_KEY] = oldConfig[mediumId].bodyStyle, 
					[BODY_FONT_SIZE] = oldConfig[mediumId].bodySize, 
					[BODY_FONT_STYLE] = GetFontStyle(oldConfig[mediumId].bodyWeight), 
				}
			end
		end
		if oldConfig[BMID_ANTIQUITY_CODEX] then
			config[BOOK_MEDIUM_ANTIQUITY_CODEX] = {
				[TITLE_FONT_KEY] = oldConfig[BMID_ANTIQUITY_CODEX].titleStyle, 
				[TITLE_FONT_SIZE] = oldConfig[BMID_ANTIQUITY_CODEX].titleSize, 
				[TITLE_FONT_STYLE] = GetFontStyle(oldConfig[BMID_ANTIQUITY_CODEX].titleWeight), 
				[BODY_FONT_KEY] = oldConfig[BMID_ANTIQUITY_CODEX].bodyStyle, 
				[BODY_FONT_SIZE] = oldConfig[BMID_ANTIQUITY_CODEX].bodySize, 
				[BODY_FONT_STYLE] = GetFontStyle(oldConfig[BMID_ANTIQUITY_CODEX].bodyWeight), 
			}
		end
		self.db.config[self.lang][FORMAT_V1] = nil	-- delete old format data
	end
	for mediumId in ExtendedBookMediumIdIterator() do
		if not config[mediumId] then
			config[mediumId] = {}
		end
		local titleFontFace, titleFontSize, titleFontStyle, bodyFontFace, bodyFontSize, bodyFontStyle = GetExtendedBookMediumFontInfo(mediumId, self.isGamepad)
		if config[mediumId][TITLE_FONT_KEY] == nil		then config[mediumId][TITLE_FONT_KEY]	= self.fontManager:GetFontKeyByFontFace(titleFontFace)	end
		if config[mediumId][TITLE_FONT_SIZE] == nil		then config[mediumId][TITLE_FONT_SIZE]	= titleFontSize											end
		if config[mediumId][TITLE_FONT_STYLE] == nil	then config[mediumId][TITLE_FONT_STYLE]	= titleFontStyle										end
		if config[mediumId][BODY_FONT_KEY] == nil		then config[mediumId][BODY_FONT_KEY]	= self.fontManager:GetFontKeyByFontFace(bodyFontFace)	end
		if config[mediumId][BODY_FONT_SIZE] == nil		then config[mediumId][BODY_FONT_SIZE]	= bodyFontSize											end
		if config[mediumId][BODY_FONT_STYLE] == nil		then config[mediumId][BODY_FONT_STYLE]	= bodyFontStyle											end
	end                                                                      
end

function CBFS:SetCustomFontMode(customFontMode)
	self.customFontMode = customFontMode
end

function CBFS:IsCustomFontMode()
	return self.customFontMode
end

function CBFS:CustomizeAntiquityCodexFont()
	local customFontData = self.db.config[self.lang][FORMAT_V2][BOOK_MEDIUM_ANTIQUITY_CODEX]
	if customFontData then
		local titleFontFace, titleFontSize, titleFontStyle, bodyFontFace, bodyFontSize, bodyFontStyle = self:GetCustomBookFontInfo(BOOK_MEDIUM_ANTIQUITY_CODEX)
		if IsInGamepadPreferredMode() then
			self.fontManager:CustomizeFont("ZoFontGamepadBookScrollTitle", ZO_CreateFontString(titleFontFace, titleFontSize, titleFontStyle))
			self.fontManager:CustomizeFont("ZoFontGamepadBookScroll", ZO_CreateFontString(bodyFontFace, bodyFontSize, bodyFontStyle))
		else
			self.fontManager:CustomizeFont("ZoFontBookScrollTitle", ZO_CreateFontString(titleFontFace, titleFontSize, titleFontStyle))
			self.fontManager:CustomizeFont("ZoFontBookScroll", ZO_CreateFontString(bodyFontFace, bodyFontSize, bodyFontStyle))
		end
	end
end

function CBFS:ResetAntiquityCodexFontToDefault()
	self.fontManager:ResetAllFontsToDefault()
end

function CBFS:GetCustomBookFontInfo(mediumId)
	local customFontData = self.db.config[self.lang][FORMAT_V2][mediumId]
	if customFontData then
		local titleFontFace = self.fontManager:GetFontFaceByLMP(customFontData[TITLE_FONT_KEY])
		local titleFontSize = customFontData[TITLE_FONT_SIZE]
		local titleFontStyle = customFontData[TITLE_FONT_STYLE]
		local bodyFontFace = self.fontManager:GetFontFaceByLMP(customFontData[BODY_FONT_KEY])
		local bodyFontSize = customFontData[BODY_FONT_SIZE]
		local bodyFontStyle = customFontData[BODY_FONT_STYLE]
		return titleFontFace, titleFontSize, titleFontStyle, bodyFontFace, bodyFontSize, bodyFontStyle
	end
end

do
	local FONT_STRING_REPLACER = {
		["$(ANTIQUE_FONT)"] = ZoFontGamepadBookPaper and ZoFontGamepadBookPaper:GetFontInfo(), 
		["$(HANDWRITTEN_FONT)"] = ZoFontGamepadBookLetter and ZoFontGamepadBookLetter:GetFontInfo(), 
		["$(STONE_TABLET_FONT)"] = ZoFontGamepadBookTablet and ZoFontGamepadBookTablet:GetFontInfo(), 
	}
	function CBFS:OverrideGetBookMediumFontInfoAPI()
	--	ZO_LoreReader was refactored in Update 48, and book font management was handed over to the C++ side.
	--	The design for each book medium is now obtained via the GetBookMediumFontInfo API.
	--	But, we will make modifications to address the following two issues.
	--	1)There are no hook points within ZO_LoreReader for modifying font designs.
	--	2)Font face data is replaced with font strings from the font object, causing some unofficial language MODs to mistakenly use English fonts.
	--
		local orgGetBookMediumFontInfo = GetBookMediumFontInfo
		_G["GetBookMediumFontInfo"] = function(mediumId, isGamepad, ...)
			if self.customFontMode then
				local returns = { orgGetBookMediumFontInfo(mediumId, isGamepad, ...) }
				local titleFontFace, titleFontSize, titleFontStyle, bodyFontFace, bodyFontSize, bodyFontStyle = self:GetCustomBookFontInfo(mediumId)
				returns[TITLE_FONT_FACE] = titleFontFace	-- *string* _titleFontName_
				returns[TITLE_FONT_SIZE] = titleFontSize	-- *integer* _titleFontSize_
				returns[TITLE_FONT_STYLE] = titleFontStyle	-- *[FontStyle|#FontStyle]* _titleFontStyle_
				returns[BODY_FONT_FACE] = bodyFontFace		-- *string* _bodyFontName_
				returns[BODY_FONT_SIZE] = bodyFontSize		-- *integer* _bodyFontSize_
				returns[BODY_FONT_STYLE] = bodyFontStyle	-- *[FontStyle|#FontStyle]* _bodyFontStyle_
				return unpack(returns)
			elseif self.isUnofficialLanguage then
				local returns = { orgGetBookMediumFontInfo(mediumId, isGamepad, ...) }
				returns[TITLE_FONT_FACE] = FONT_STRING_REPLACER[returns[TITLE_FONT_FACE]] or returns[TITLE_FONT_FACE]
				returns[BODY_FONT_FACE] = FONT_STRING_REPLACER[returns[BODY_FONT_FACE]] or returns[BODY_FONT_FACE]
				return unpack(returns)
			else
				return orgGetBookMediumFontInfo(mediumId, isGamepad, ...)
			end
		end
	end
end
-- ------------------------------------------------

SLASH_COMMANDS["/cbfs.debug"] = function(arg) if arg ~= "" then CBFS:ConfigDebug({tonumber(arg)}) end end

SLASH_COMMANDS["/cbfs.test"] = function(arg)
	CBFS.LDL:Debug("BOOK_MEDIUM_ITERATION_BEGIN = ", BOOK_MEDIUM_ITERATION_BEGIN)
	CBFS.LDL:Debug("BOOK_MEDIUM_ITERATION_END = ", BOOK_MEDIUM_ITERATION_END)
	
	for mediumId = BOOK_MEDIUM_ITERATION_BEGIN, BOOK_MEDIUM_ITERATION_END do
		local titleFontName, titleFontSize, titleFontStyle, bodyFontName, bodyFontSize, bodyFontStyle, r, g, b, a, styleR, styleG, styleB, styleA = GetBookMediumFontInfo(mediumId, false)
		local titleFontKB = ZO_CreateFontString(titleFontName, titleFontSize, titleFontStyle)
		local bodyFontKB = ZO_CreateFontString(bodyFontName, bodyFontSize, bodyFontStyle)
		titleFontName, titleFontSize, titleFontStyle, bodyFontName, bodyFontSize, bodyFontStyle, r, g, b, a, styleR, styleG, styleB, styleA = GetBookMediumFontInfo(mediumId, true)
		local titleFontGP = ZO_CreateFontString(titleFontName, titleFontSize, titleFontStyle)
		local bodyFontGP = ZO_CreateFontString(bodyFontName, bodyFontSize, bodyFontStyle)
		CBFS.LDL:Debug("KB(%d): %s : %s", mediumId, titleFontKB, bodyFontKB)
		CBFS.LDL:Debug("GP(%d): %s : %s", mediumId, titleFontGP, bodyFontGP)
	end
end
