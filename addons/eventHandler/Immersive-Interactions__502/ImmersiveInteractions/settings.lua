-- ==================================================================================================== --
-- # Immersive Interactions
-- # 
-- # It's an addon for ESO. I'm not going to put a fancy license or disclaimer. Go crazy with it.
-- #
-- # All settings are now managed here, and access is gained through proxy functions.
-- #
-- #	public functions:
-- #		GetSetting(key)			returns the "value" at the paired [key] element of current settings table
-- #		SetSetting(key, value)	returns false on success, true on failure; attempts to assign passed "value" to element [key] in current settings table
-- #		RestoreDefaults()		returns nothing; modifies all current settings (player or account-wide) to the default values stored in local table savedVariables
-- #
-- #	ui functions -- invariant mapping to specific elements in settings table, pre-determined by key:
-- #		GetAccessor(key)		returns function(); grants access to retrieve "value" from mapped element [key] in settings table; used by gui.lua
-- #		GetSetter(key)			returns function(var); single parameter var is required when calling the function returned by GetSetter(key); used by gui.lua
-- #
-- #	local tables:
-- #		account{}	-- contains account-wide settings
-- #		character{}	-- contains settings specific to the current character
-- ==================================================================================================== --

do
	local account	= {}
	local player	= {}
	local settings	= {}

	--[[
		While lua is not strictly typed, this addon employs naming uniformity for conceptual data organization.

		Naming Conventions:
			bVar = state			(boolean)
			sVar = text				(string)
			iVar = integer			(int)
			fVar = floating point	(float)
	--]]
	local savedVariables	= {
		["bEnabled"]			= true,
		["bUseAcct"]			= false,
		["bHideUI"]				= false,
		["bHideTitle"]			= false,
		["bHideBodyText"]		= true,
		["bHideOptions"]		= true,
		["bHideWindow"]			= false,
		-- use case
		["bAlwaysHide"]			= false,
		["bSkipDaily"]			= true,
		["bAlwaysShowServices"]	= true,
		["bAlwaysShowPvP"]		= true,
		-- hide backgrounds
		["bHideTopBG"]			= true,		["bHideBottomBG"]				= true,
		["bHideDialogBG"]		= true,		["bHideVS"]						= true,
		-- hide reward sections
		["bHideReward"]			= true,
		-- hide chat
		["bHideChat"]			= true,		["bHideChatShop"]				= false,
		["bHideMini"]			= true,		["bHideMiniShop"]				= false,
		-- other
		["bTrimDashes"]			= true,
		["bAddNums"]			= true,
		["szDivider"]			= ")",
		["iOffsetMS"]			= 50,
		["bHighlight"]			= true,
		["bPrintDialog"]		= false,
		-- alternate title
		["bAltTitle"]			= false,
		["AltTitle_posx"]		= 128,		["AltTitle_posy"]				= 128,
		["AltTitle_point"]		= TOPLEFT,	["AltTitle_relativePoint"]		= 0,
		--
		["bToggleButton"]		= false,
		["ToggleButton_posx"]	= 128,		["ToggleButton_posy"]			= 128,
		["ToggleButton_point"]	= TOPLEFT,	["ToggleButton_relativePoint"]	= 0,
		--
		["bMsgWindow"]			= false,
		["MsgWindow_posx"]		= 128,		["MsgWindow_posy"]				= 128,
		["MsgWindow_point"]		= TOPLEFT,	["MsgWindow_relativePoint"]		= 0,
		["MsgWindow_sizex"]		= 350,		["MsgWindow_sizey"]				= 400,
		--
		["szMsgWindowHandle"]	= "MsgWindowOutput",
		["szMsgWindowLabel"]	= "Transcripts",
		["iFadeDelay"]			= 0,
		["iFadeDuration"]		= 0,
		-- colors
		["desR"]	= 0.3333333433,		["desG"]	= 0.6705882549,		["desB"] = 0.5058823529,	["desA"] = 1,
		["altR"]	= 0.3333333433,		["altG"]	= 0.6705882549,		["altB"] = 0.5058823529,	["altA"] = 1,
		["tatR"]	= 0.3333333433,		["tatG"]	= 0.6705882549,		["tatB"] = 0.5058823529,	["tatA"] = 1,
		["tabR"]	= 0.3333333433,		["tabG"]	= 0.6705882549,		["tabB"] = 0.5058823529,	["tabA"] = 1,
		["optR"]	= 0.3333333433,		["optG"]	= 0.6705882549,		["optB"] = 0.5058823529,	["optA"] = 1,
		["opnR"]	= 0.3333333433,		["opnG"]	= 0.6705882549,		["opnB"] = 0.5058823529,	["opnA"] = 1,
		["oppR"]	= 0.3333333433,		["oppG"]	= 0.6705882549,		["oppB"] = 0.5058823529,	["oppA"] = 1,
		["spcR"]	= 0,				["spcG"]	= 0.6196078658,		["spcB"] = 0.0784313753,	["spcA"] = 1,
		-- fonts
		fontFace = {
			["tat"]		= "Skyrim Handwritten",
			["tab"]		= "ProseAntique",
			["opt"]		= "ProseAntique",
			["alt"]		= "Skyrim Handwritten",
		},
		fontStyle = {
			["tat"]		= "soft-shadow-thick",
			["tab"]		= "soft-shadow-thick",
			["opt"]		= "soft-shadow-thick",
			["alt"]		= "soft-shadow-thick",
		},
		fontSize = {
			["tat"]		= 26,
			["tab"]		= 24,
			["opt"]		= 22,
			["alt"]		= 28,
		},
		transcripts			= {
			["Mysterious Stranger"]		= { "Example of a Dialog", },
		},
	}

	local validate	= {}

	-- ==================================================================================================== --

	-- ==================================================================================================== --

	function ImmersiveFunctions.LoadSavedVariables()
		local name		= ImmersiveData.addonInfo.name
		local version	= ImmersiveData.addonInfo.s_version -- check s_version, so settings don't become invalid when they don't need to be
		player			= ZO_SavedVars:New(name, version, "Settings", savedVariables)
		account			= ZO_SavedVars:NewAccountWide(name, version, "Settings", savedVariables)

		if player.bUseAcct then
			settings = account
		else
			settings = player
		end

		for key, val in pairs(savedVariables) do
			validate[key] = true
			if ImmersiveFunctions.Debug("validate") then
				df("validating::: "..tostring(key))
			end
		end
	end

	function ImmersiveFunctions.RestoreDefault()
		for k, v in pairs(savedVariables) do
			settings[k] = v
		end
	end

	function ImmersiveFunctions.GetSetting(key)
		--if not validate[key] then df("ERROR- INVALID SETTING ACCESSED::: "..tostring(key)) end
		return settings[key]
	end

	function ImmersiveFunctions.SetSetting(key, value)
		if settings[key] ~= nil then settings[key] = value; return false end -- don't create new settings, only modify existing ones

		-- error state
		return true
	end

	-- ==================================================================================================== --

	-- ==================================================================================================== --

	-- 
	function ImmersiveFunctions.GetWidth(field, length)
		-- if this field has a known font size, use it, otherwise use 24
		local FONT_SIZE = function(var) local size = settings.fontSize[var]; if not size then size = 24 end; return size end

		-- make the padding get smaller relative to size, so there is less bloated extra on the ends
		local FONT_PADDING = function(var) if var == 1 then return 1 end; return math.floor(((var)/(1-var))^2) end

		-- the width required for this text field is (font size) X (padding for this many characters) X (the number of characters) X (co-efficient)
		local width = FONT_SIZE(field)*FONT_PADDING(length)*length*(2/3)

		return width
	end

	function ImmersiveFunctions.GetFont(key)
		local LMP = LibMediaProvider

		return ("%s|%s|%s"):format(LMP:Fetch('font', settings.fontFace[key]), settings.fontSize[key], settings.fontStyle[key])
	end

	function ImmersiveFunctions.GetFontFace(key)		return settings.fontFace[key]	end
	function ImmersiveFunctions.SetFontFace(key, val)	settings.fontFace[key]	= val	end

	function ImmersiveFunctions.GetFontSize(key)		return settings.fontSize[key]	end
	function ImmersiveFunctions.SetFontSize(key, val)	settings.fontSize[key]	= val	end

	function ImmersiveFunctions.GetFontStyle(key)		return settings.fontStyle[key]	end
	function ImmersiveFunctions.SetFontStyle(key, val)	settings.fontStyle[key]	= val	end

	-- ==================================================================================================== --

	local access = {
		["bEnabled"]					= function() return settings.bEnabled end,
		["bUseAcct"]					= function() return player.bUseAcct end,
		--
		["bHideUI"]						= function() return settings.bHideUI end,
		["bHideTitle"]					= function() return settings.bHideTitle end,
		["bHideBodyText"]				= function() return settings.bHideBodyText end,
		["bHideOptions"]				= function() return settings.bHideOptions end,
		["bHideWindow"]					= function() return settings.bHideWindow end,
		--
		["bHideTopBG"]					= function() return settings.bHideTopBG end,
		["bHideBottomBG"]				= function() return settings.bHideBottomBG end,
		["bHideDialogBG"]				= function() return settings.bHideDialogBG end,
		["bHideVS"]						= function() return settings.bHideVS end,
		--
		["bHideReward"]					= function() return settings.bHideRewardA end,
		--
		["bHideChat"]					= function() return settings.bHideChat end,
		["bHideChatShop"]				= function() return settings.bHideChatShop end,
		["bHideMini"]					= function() return settings.bHideMini end,
		["bHideMiniShop"]				= function() return settings.bHideMiniShop end,
		--
		["bTrimDashes"]					= function() return settings.bTrimDashes end,
		["bAddNums"]					= function() return settings.bAddNums end,
		["szDivider"]					= function() return settings.szDivider end,
		["iOffsetMS"]					= function() return settings.iOffsetMS end,
		["bHighlight"]					= function() return settings.bHighlight end,
		["bPrintDialog"]				= function() return settings.bPrintDialog end,
		--
		["bAltTitle"]					= function() return settings.bAltTitle end,
		["AltTitle_posx"]				= function() return settings.AltTitle_posx end,
		["AltTitle_posy"]				= function() return settings.AltTitle_posy end,
		["AltTitle_point"]				= function() return settings.AltTitle_point end,
		["AltTitle_relativePoint"]		= function() return settings.AltTitle_relativePoint end,
		--
		["bToggleButton"]				= function() return settings.bToggleButton end,
		["ToggleButton_posx"]			= function() return settings.ToggleButton_posx end,
		["ToggleButton_posy"]			= function() return settings.ToggleButton_posy end,
		["ToggleButton_point"]			= function() return settings.ToggleButton_point end,
		["ToggleButton_relativePoint"]	= function() return settings.ToggleButton_relativePoint end,
		--
		["bMsgWindow"]					= function() return settings.bMsgWindow end,
		["MsgWindow_posx"]				= function() return settings.MsgWindow_posx end,
		["MsgWindow_posy"]				= function() return settings.MsgWindow_posy end,
		["MsgWindow_point"]				= function() return settings.MsgWindow_point end,
		["MsgWindow_relativePoint"]		= function() return settings.MsgWindow_relativePoint end,
		--
		["bAlwaysHide"]					= function() return settings.bAlwaysHide end,
		["bSkipDaily"]					= function() return settings.bSkipDaily end,
		["bAlwaysShowServices"]			= function() return settings.bAlwaysShowServices end,
		["bAlwaysShowPvP"]				= function() return settings.bAlwaysShowPvP end,
		--
		["szMsgWindowHandle"]			= function() return settings.szMsgWindowHandle end,
		["szMsgWindowLabel"]			= function() return settings.szMsgWindowLabel end,
		["iFadeDelay"]					= function() return settings.iFadeDelay end,
		["iFadeDuration"]				= function() return settings.iFadeDuration end,
		--
		["bCustomNames"]				= function() return "Not Yet Implemented" end,
		--
		["tatRGBA"]						= function() return settings.tatR, settings.tatG, settings.tatB, settings.tatA end,
		["altRGBA"]						= function() return settings.altR, settings.altG, settings.altB, settings.altA end,
		["tabRGBA"]						= function() return settings.tabR, settings.tabG, settings.tabB, settings.tabA end,
		["optRGBA"]						= function() return settings.optR, settings.optG, settings.optB, settings.optA end,
		["opnRGBA"]						= function() return settings.opnR, settings.opnG, settings.opnB, settings.opnA end,
		["oppRGBA"]						= function() return settings.oppR, settings.oppG, settings.oppB, settings.oppA end,
		["spcRGBA"]						= function() return settings.spcR, settings.spcG, settings.spcB, settings.spcA end,
		--
		["fontFaceTat"]					= function() return ImmersiveFunctions.GetFontFace("tat") end,
		["fontFaceAlt"]					= function() return ImmersiveFunctions.GetFontFace("alt") end,
		["fontFaceTab"]					= function() return ImmersiveFunctions.GetFontFace("tab") end,
		["fontFaceOpt"]					= function() return ImmersiveFunctions.GetFontFace("opt") end,

		["fontStyleTat"]				= function() return ImmersiveFunctions.GetFontStyle("tat") end,
		["fontStyleAlt"]				= function() return ImmersiveFunctions.GetFontStyle("alt") end,
		["fontStyleTab"]				= function() return ImmersiveFunctions.GetFontStyle("tab") end,
		["fontStyleOpt"]				= function() return ImmersiveFunctions.GetFontStyle("opt") end,

		["fontSizeTat"]					= function() return ImmersiveFunctions.GetFontSize("tat") end,
		["fontSizeAlt"]					= function() return ImmersiveFunctions.GetFontSize("alt") end,
		["fontSizeTab"]					= function() return ImmersiveFunctions.GetFontSize("tab") end,
		["fontSizeOpt"]					= function() return ImmersiveFunctions.GetFontSize("opt") end,
	}

	-- helper used in the following array,
	-- ensure toggling enabled status in settings triggers the appropriate setup/cleanup
	local function ToggleAddon(var)
		if var then
			ImmersiveFunctions.AddonEnable()
		else
			ImmersiveFunctions.AddonDisable()
		end
	end

	local assign = {
		["bEnabled"]					= function(var) settings.bEnabled = var; ToggleAddon(var) end,
		["bUseAcct"]					= function(var) player.bUseAcct = var; if var then settings = account else settings = player end end,
		--
		["bHideUI"]						= function(var) settings.bHideUI = var end,
		["bHideTitle"]					= function(var) settings.bHideTitle = var end,
		["bHideBodyText"]				= function(var) settings.bHideBodyText = var end,
		["bHideOptions"]				= function(var) settings.bHideOptions = var end,
		["bHideWindow"]					= function(var) settings.bHideWindow = var end,
		--
		["bHideTopBG"]					= function(var) settings.bHideTopBG = var end,
		["bHideBottomBG"]				= function(var) settings.bHideBottomBG = var end,
		["bHideDialogBG"]				= function(var) settings.bHideDialogBG, settings.bHideTopBG, settings.bHideBottomBG = var, var, var end,
		["bHideVS"]						= function(var) settings.bHideVS = var end,
		--
		["bHideReward"]					= function(var) settings.bHideRewardA = var end,
		--
		["bHideChat"]					= function(var) settings.bHideChat = var; if not var then settings.bHideChatShop = var end end,
		["bHideChatShop"]				= function(var) settings.bHideChatShop = var; if var then settings.bHideChat = var end end,
		["bHideMini"]					= function(var) settings.bHideMini = var; if not var then settings.bHideMiniShop = var end end,
		["bHideMiniShop"]				= function(var) settings.bHideMiniShop = var; if var then settings.bHideMini = var end end,
		--
		["bTrimDashes"]					= function(var) settings.bTrimDashes = var; ImmersiveFunctions.RefreshTitle() end,
		["bAddNums"]					= function(var) settings.bAddNums = var end,
		["szDivider"]					= function(var) settings.szDivider = var end,
		["iOffsetMS"]					= function(var) settings.iOffsetMS = var end,
		["bHighlight"]					= function(var) settings.bHighlight = var end,
		["bPrintDialog"]				= function(var) settings.bPrintDialog = var end,
		--
		["bAlwaysHide"]					= function(var) settings.bAlwaysHide = var end,
		["bSkipDaily"]					= function(var) settings.bSkipDaily = var end,
		["bAlwaysShowServices"]			= function(var) settings.bAlwaysShowServices = var end,
		["bAlwaysShowPvP"]				= function(var) settings.bAlwaysShowPvP = var end,
		--
		["bAltTitle"]					= function(var) settings.bAltTitle = var end,
		["AltTitle_posx"]				= function(var) settings.AltTitle_posx = var end,
		["AltTitle_posy"]				= function(var) settings.AltTitle_posy = var end,
		["AltTitle_point"]				= function(var) settings.AltTitle_point = var end,
		["AltTitle_relativePoint"]		= function(var) settings.AltTitle_relativePoint = var end,
		--
		["bToggleButton"]				= function(var) settings.bToggleButton = var end,
		["ToggleButton_posx"]			= function(var) settings.ToggleButton_posx = var end,
		["ToggleButton_posy"]			= function(var) settings.ToggleButton_posy = var end,
		["ToggleButton_point"]			= function(var) settings.ToggleButton_point = var end,
		["ToggleButton_relativePoint"]	= function(var) settings.ToggleButton_relativePoint = var end,
		--
		["bMsgWindow"]					= function(var) settings.bMsgWindow = var end,
		["MsgWindow_posx"]				= function(var) settings.MsgWindow_posx = var end,
		["MsgWindow_posy"]				= function(var) settings.MsgWindow_posy = var end,
		["MsgWindow_point"]				= function(var) settings.MsgWindow_point = var end,
		["MsgWindow_relativePoint"]		= function(var) settings.MsgWindow_relativePoint = var end,
		--
		["szMsgWindowHandle"]			= function(var) settings.szMsgWindowHandle = var end,
		["szMsgWindowLabel"]			= function(var) settings.szMsgWindowLabel = var end,
		["iFadeDelay"]					= function(var) settings.iFadeDelay = var end,
		["iFadeDuration"]				= function(var) settings.iFadeDuration = var end,
		--
		["bCustomNames"]				= function(var) end,
		-- color
		["tatRGBA"] 					= function(r, g, b, a) settings.tatR, settings.tatG, settings.tatB, settings.tatA = r, g, b, a end,
		["altRGBA"]						= function(r, g, b, a) settings.altR, settings.altG, settings.altB, settings.altA = r, g, b, a end,
		["tabRGBA"]						= function(r, g, b, a) settings.tabR, settings.tabG, settings.tabB, settings.tabA = r, g, b, a end,
		["optRGBA"]						= function(r, g, b, a) settings.optR, settings.optG, settings.optB, settings.optA = r, g, b, a end,
		["opnRGBA"]						= function(r, g, b, a) settings.opnR, settings.opnG, settings.opnB, settings.opnA = r, g, b, a end,
		["oppRGBA"]						= function(r, g, b, a) settings.oppR, settings.oppG, settings.oppB, settings.oppA = r, g, b, a end,
		["spcRGBA"]						= function(r, g, b, a) settings.spcR, settings.spcG, settings.spcB, settings.spcA = r, g, b, a end,
		-- font
		["fontFaceTat"]					= function(var) ImmersiveFunctions.SetFontFace("tat", var) end,
		["fontFaceAlt"]					= function(var) ImmersiveFunctions.SetFontFace("alt", var) end,
		["fontFaceTab"]					= function(var) ImmersiveFunctions.SetFontFace("tab", var) end,
		["fontFaceOpt"]					= function(var) ImmersiveFunctions.SetFontFace("opt", var) end,

		["fontStyleTat"]				= function(var) ImmersiveFunctions.SetFontStyle("tat", var) end,
		["fontStyleAlt"]				= function(var) ImmersiveFunctions.SetFontStyle("alt", var) end,
		["fontStyleTab"]				= function(var) ImmersiveFunctions.SetFontStyle("tab", var) end,
		["fontStyleOpt"]				= function(var) ImmersiveFunctions.SetFontStyle("opt", var) end,

		["fontSizeTat"]					= function(var) ImmersiveFunctions.SetFontSize("tat", var) end,
		["fontSizeAlt"]					= function(var) ImmersiveFunctions.SetFontSize("alt", var) end,
		["fontSizeTab"]					= function(var) ImmersiveFunctions.SetFontSize("tab", var) end,
		["fontSizeOpt"]					= function(var) ImmersiveFunctions.SetFontSize("opt", var) end,
	}

	function ImmersiveFunctions.GetAccessor(key)	return access[key]	end
	function ImmersiveFunctions.GetSetter(key)		return assign[key]	end
end
