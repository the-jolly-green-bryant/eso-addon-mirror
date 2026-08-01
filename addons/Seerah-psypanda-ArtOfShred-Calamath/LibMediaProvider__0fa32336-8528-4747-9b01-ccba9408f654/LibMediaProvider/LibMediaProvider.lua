--LibMediaProvider is inspired by and borrows from LibSharedMedia-3.0 for World of Warcraft by Elkano
--LibSharedMedia-3.0 and LibMediaProvider are under the LGPL-2.1 license

if LibMediaProvider then d("Warning : 'LibMediaProvider' has always been loaded.") return end
local cm = CALLBACK_MANAGER

-- Since version 1.0 release 21, the default ui media for fonts depends on the language mode.
local predefinedFont = {
--In official language modes where no unique font presets are defined, use ["default"].
--In unofficial language modes where custom backup fonts are defined, use ["default"].
	["default"] = {
		["ProseAntique"]			= "$(PROSE_ANTIQUE_FONT)", 
		["Consolas"]				= "$(CONSOLAS_FONT)", 
		["Futura Condensed"]		= "$(FTN57_FONT)", 
		["Futura Condensed Bold"]	= "$(FTN87_FONT)", 
		["Futura Condensed Light"]	= "$(FTN47_FONT)", 
		["Skyrim Handwritten"]		= "$(HANDWRITTEN_BOLD_FONT)", 
		["Trajan Pro"]				= "$(TRAJAN_PRO_R_FONT)", 
		["Univers 55"]				= "$(UNIVERS55_FONT)", 
		["Univers 57"]				= "$(UNIVERS57_FONT)", 
		["Univers 67"]				= "$(UNIVERS67_FONT)", 
	}, 
--In unofficial language modes where no unique font presets are defined, use ["vanilla"].
	["vanilla"] = {
		["ProseAntique"]			= "EsoUI/Common/Fonts/ProseAntiquePSMT.slug", 
		["Consolas"]				= "EsoUI/Common/Fonts/Consola.slug", 
		["Futura Condensed"]		= "EsoUI/Common/Fonts/FTN57.slug", 
		["Futura Condensed Bold"]	= "EsoUI/Common/Fonts/FTN87.slug", 
		["Futura Condensed Light"]	= "EsoUI/Common/Fonts/FTN47.slug", 
		["Skyrim Handwritten"]		= "EsoUI/Common/Fonts/Handwritten_Bold.slug", 
		["Trajan Pro"]				= "EsoUI/Common/Fonts/TrajanPro-Regular.slug", 
		["Univers 55"]				= "EsoUI/Common/Fonts/Univers55.slug", 
		["Univers 57"]				= "EsoUI/Common/Fonts/Univers57.slug", 
		["Univers 67"]				= "EsoUI/Common/Fonts/Univers67.slug", 
	}, 
}
--If you prefer to use a dedicated font preset for an unofficial language mode, describe a unique preset table here.
--However, glyphs specific to these predefined western fonts should be consistent regardless of language mode.
--If possible, please try to make up for missing glyphs in backup font definitions.  backupfont_$(language).xml
local lang = GetCVar("Language.2")
if lang == "kr" or lang == "kb" then
	predefinedFont[lang] = {	-- for EsoKR (Korean)
		["ProseAntique"]			= "EsoKR/fonts/ProseAntiquePSMT.slug", 
		["Consolas"]				= "$(CONSOLAS_FONT)", 
		["Futura Condensed"]		= "EsoKR/fonts/FTN57.slug", 
		["Futura Condensed Bold"]	= "EsoKR/fonts/FTN87.slug", 
		["Futura Condensed Light"]	= "EsoKR/fonts/FTN47.slug", 
		["Skyrim Handwritten"]		= "$(HANDWRITTEN_BOLD_FONT)", 
		["Trajan Pro"]				= "$(TRAJAN_PRO_R_FONT)", 
		["Univers 55"]				= "EsoKR/fonts/univers55.slug", 
		["Univers 57"]				= "EsoKR/fonts/univers57.slug", 
		["Univers 67"]				= "EsoKR/fonts/univers47.slug", 	-- Not a typo
	}
elseif lang == "pl" then
	predefinedFont[lang] = {	-- for EsoPL (Polish)
		["ProseAntique"]			= "fonts/ProseAntiquePSMT.slug", 
		["Consolas"]				= "$(CONSOLAS_FONT)", 
		["Futura Condensed"]		= "fonts/FTN57.slug", 
		["Futura Condensed Bold"]	= "fonts/FTN87.slug", 
		["Futura Condensed Light"]	= "fonts/FTN47.slug", 
		["Skyrim Handwritten"]		= "fonts/Handwritten_Bold.slug", 
		["Trajan Pro"]				= "fonts/TrajanPro-Regular.slug", 
		["Univers 55"]				= "fonts/univers55.slug", 
		["Univers 57"]				= "fonts/univers57.slug", 
		["Univers 67"]				= "fonts/univers67.slug", 
	}
elseif lang == "th" then
	predefinedFont[lang] = predefinedFont["default"]	-- for EsoTH (Thai)
end

-- ---------------------------------------------------------------------------------------
-- LibMediaProvider Class
-- ---------------------------------------------------------------------------------------
local LMP = ZO_InitializingObject:Subclass()
function LMP:Initialize()
	self.name = "LibMediaProvider"
	self.lang = GetCVar("Language.2")
	self.external = {}
	self.defaultMedia = {}
	self.mediaList = {}
	self.mediaTable = {}
	self.sharedMediaTable = {}		-- duplicated mediaTable for sharing
	self.mediaType = {
		BACKGROUND = "background",	-- background textures
		BORDER = "border",			-- border textures
		FONT = "font",				-- fonts
		STATUSBAR = "statusbar",	-- statusbar textures
		SOUND = "sound",			-- sound files
	}
	self.blacklistedFont = {}		-- blacklisted fonts on consoles

--DEFAULT UI MEDIA--
-- BACKGROUND
	self.mediaTable.background = {
--		["None"]				= "", --commented out because it still leaves a white texture behind - addons can use alpha to hide the background
		["ESO Black"]			= "EsoUI/Art/Miscellaneous/borderedInset_center.dds", 
		["ESO Chat"]			= "EsoUI/Art/ChatWindow/chat_BG_center.dds", 
		["ESO Gray"]			= "EsoUI/Art/ItemToolTip/simpleProgbarBG_center.dds", 
		["Solid"]				= "", 
	}
	self.defaultMedia.background = "Solid"

-- BORDER
	self.mediaTable.border = {
--		["None"]				= "", --commented out because it still leaves a white texture behind - addons can use alpha to hide the border
		["ESO Gold"]			= "EsoUI/Art/Miscellaneous/borderedInsetTransparent_edgeFile.dds", 
		["ESO Chat"]			= "EsoUI/Art/ChatWindow/chat_BG_edge.dds", 
		["ESO Rounded"]			= "EsoUI/Art/Miscellaneous/interactKeyFrame_edge.dds", 
		["ESO Blue Highlight"]	= "EsoUI/Art/Miscellaneous/textEntry_highlight_edge.dds", 
		["ESO Blue Glow"]		= "EsoUI/Art/Crafting/crafting_toolTip_glow_edge_blue64.dds", 
		["ESO Red Glow"]		= "EsoUI/Art/Crafting/crafting_toolTip_glow_edge_red64.dds", 
		["ESO Red Overlay"]		= "EsoUI/Art/UICombatOverlay/UICombatOverlayEdge.dds", 
	}
	self.defaultMedia.border = "ESO Gold"

-- FONT
	self.mediaTable.font = ZoGetOfficialGameLanguageDescriptor() == self.lang and predefinedFont["default"] or predefinedFont[self.lang] or predefinedFont["vanilla"]
	self.mediaTable.font["JP-StdFont"]		= "$(LMP_FONT_PATH)ESO_FWNTLGUDC70-DB.slug"
	self.mediaTable.font["JP-ChatFont"]		= "$(LMP_FONT_PATH)ESO_FWUDC_70-M.slug"
	self.mediaTable.font["JP-KafuPenji"]	= "$(LMP_FONT_PATH)ESO_KafuPenji-M.slug"
	self.mediaTable.font["ZH-StdFont"]		= "$(LMP_FONT_PATH)MYingHeiPRC-W5.slug"
	self.mediaTable.font["ZH-MYoyoPRC"]		= "$(LMP_FONT_PATH)MYoyoPRC-Medium.slug"
	self.defaultMedia.font = "Univers 57"

	-- [Console Add-on]: For some built-in CJK fonts, we intentionally added as a blacklisted font to avoid memory overflow.
	--                   These will be replaced with the fallback font when fetching. You can use the HashTable method to find the true registered font filename.
	if IsConsoleUI() then
		self.blacklistedFont["JP-KafuPenji"] = true
		self.blacklistedFont["ZH-MYoyoPRC"] = true
	end

-- STATUSBAR
	self.mediaTable.statusbar = {
--	self.mediaTable.statusbar["ESO Basic"]			= "EsoUI/Art/miscellaneous/progressbar_genericfill_tall.dds"
		["ESO Basic"]			= "", 
	}
	self.defaultMedia.statusbar = "ESO Basic"

-- SOUND
	self.mediaTable.sound = {
		["None"]					= "", 
		["AvA Gate Open"]			= SOUNDS.AVA_GATE_OPENED, 
		["AvA Gate Close"]			= SOUNDS.AVA_GATE_CLOSED, 
		["Emperor Coronated"]		= SOUNDS.EMPEROR_CORONATED_DAGGERFALL, 
		["Level Up"]				= SOUNDS.LEVEL_UP, 
		["Skill Gained"]			= SOUNDS.SKILL_GAINED, 
		["Ability Purchased"]		= SOUNDS.ABILITY_SKILL_PURCHASED, 
		["Book Acquired"]			= SOUNDS.BOOK_ACQUIRED, 
		["Unlock"]					= SOUNDS.LOCKPICKING_UNLOCKED, 
		["Enchanting Extract"]		= SOUNDS.ENCHANTING_EXTRACT_START_ANIM, 
		["Enchanting Create"]		= SOUNDS.ENCHANTING_CREATE_TOOLTIP_GLOW, 
		["Blacksmith Improve"]		= SOUNDS.BLACKSMITH_IMPROVE_TOOLTIP_GLOW_SUCCESS, 
	}
	self.defaultMedia.sound = "None"

	-- We do the duplication as the last step in initialization.
	ZO_DeepTableCopy(self.mediaTable, self.sharedMediaTable)
	self:InitializeAPI()
end

function LMP:RebuildMediaList(mediatype)
	if not self.mediaTable[mediatype] then return end
	self.mediaList[mediatype] = self.mediaList[mediatype] or {}
	local mlist = self.mediaList[mediatype]
	-- list can only get larger, so simply overwrite it
	local i = 0
	for k in pairs(self.mediaTable[mediatype]) do
		i = i + 1
		mlist[i] = k
	end
	table.sort(mlist)
end

function LMP:Validate(mediatype, key)
	local mtt = self.mediaTable[mediatype]
	local smtt = self.sharedMediaTable[mediatype]
	if mtt and not smtt then
		ZO_ShallowTableCopy(mtt, smtt)
	else
		if mtt[key] ~= smtt[key] then
			smtt[key] = mtt[key]
		end
	end
end

function LMP:Register(mediatype, key, data)
	if type(mediatype) ~= "string" then
		error(self.name .. ":Register(mediatype, key, data) - mediatype must be string, got " .. type(mediatype))
	end
	if type(key) ~= "string" then
		error(self.name .. ":Register(mediatype, key, data) - key must be string, got " .. type(key))
	end
	mediatype = mediatype:lower()
	self.mediaTable[mediatype] = self.mediaTable[mediatype] or {}
	self.sharedMediaTable[mediatype] = self.sharedMediaTable[mediatype] or {}

	if self.mediaTable[mediatype][key] then
		return false	--  we do not allow overwriting of registered media.
	end
	self.mediaTable[mediatype][key] = data
	self.sharedMediaTable[mediatype][key] = data
	self:RebuildMediaList(mediatype)
	cm:FireCallbacks("LibMediaProvider_Registered", mediatype, key)
	return true
end

function LMP:Fetch(mediatype, key)
	local mtt = self.mediaTable[mediatype]
	if IsConsoleUI() and mediatype == self.mediaType.FONT and self.blacklistedFont[key] then
		return "$(MEDIUM_FONT)"		-- On consoles, blacklisted fonts should be replaced with the fallback font.
	end
	local result = (mtt and mtt[key]) or (self.defaultMedia[mediatype] and mtt[self.defaultMedia[mediatype]])
	return result ~= "" and result or nil
end

function LMP:IsValid(mediatype, key)
	if IsConsoleUI() and mediatype == self.mediaType.FONT and self.blacklistedFont[key] then
		return false	-- On consoles, blacklisted fonts should be false.
	end
	return self.mediaTable[mediatype] and (not key or self.mediaTable[mediatype][key]) and true or false
end

function LMP:HashTable(mediatype)
	return self.sharedMediaTable[mediatype]
end

function LMP:List(mediatype)
	if not self.mediaTable[mediatype] then
		return nil
	end
	if not self.mediaList[mediatype] then
		self:RebuildMediaList(mediatype)
	end
	return self.mediaList[mediatype]
end

function LMP:GetDefault(mediatype)
	return self.defaultMedia[mediatype]
end

function LMP:SetDefault(mediatype, key)
	if self.mediaTable[mediatype] and self.mediaTable[mediatype][key] and not self.defaultMedia[mediatype] then
		self.defaultMedia[mediatype] = key
		return true
	else
		return false
	end
end

function LMP:InitializeAPI()
--
-- ---- LibMediaProvider API
--
	self.external.Register = function(_, mediatype, key, data)
		return self:Register(mediatype, key, data)
	end
	self.external.Fetch = function(_, mediatype, key)
		return self:Fetch(mediatype, key)
	end
	self.external.IsValid = function(_, mediatype, key)
		return self:IsValid(mediatype, key)
	end
	self.external.HashTable = function(_, mediatype)
		return self:HashTable(mediatype)
	end
	self.external.List = function(_, mediatype)
		return self:List(mediatype)
	end
	self.external.GetDefault = function(_, mediatype)
		return self:GetDefault(mediatype)
	end
	self.external.SetDefault = function(_, mediatype, key)
		return self:SetDefault(mediatype, key)
	end
	self.external.MediaType = self.mediaType
	self.external.MediaTable = {}	-- Stub for backward compatibility
	for _, mediaType in pairs(self.mediaType) do
		self.external.MediaTable[mediaType] = {}	-- No longer used
	end
	assert(not _G[self.name], self.name .. " is already loaded.")
	_G[self.name] = self.external
end

-- -----------------------------------------------------------------------------------------------------------
-- LibMediaProvider Add-on
-- -----------------------------------------------------------------------------------------------------------
local LibMediaProviderNamespace = LMP:New()
