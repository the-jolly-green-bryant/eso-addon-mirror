local LAM = LibAddonMenu2
if (not LAM) then return end

local NAME = "AdvancedGameSettings"
local VERSION = "1.1.0"

local FPS_MIN = 20
local FPS_MAX = 300
local FPS_STEP = 5

EVENT_MANAGER:RegisterForEvent(NAME, EVENT_PLAYER_ACTIVATED, function( eventCode, initial )
	EVENT_MANAGER:UnregisterForEvent(NAME, EVENT_PLAYER_ACTIVATED)

	-- Obtain the current FPS limit state

	local frameTime = GetCVar("MinFrameTime.2")
	if (type(frameTime) == "string") then
		frameTime = tonumber(frameTime)
	else
		frameTime = nil
	end

	local fpsLimitEnabled = false
	local fpsLimit = FPS_MAX
	if (type(frameTime) == "number" and frameTime > 0) then
		fpsLimitEnabled = true
		fpsLimit = zo_round(1 / frameTime)
	end

	-- Shared function for updating FPS limits

	local fpsLimitUpdate = function( )
		local frameTimeNew = 0

		if (fpsLimitEnabled) then
			if (fpsLimit < FPS_MIN) then fpsLimit = FPS_MIN end
			if (fpsLimit > FPS_MAX) then fpsLimit = FPS_MAX end
			frameTimeNew = 1 / fpsLimit
		end

		SetCVar("MinFrameTime.2", string.format("%0.8f", frameTimeNew))
	end

	-- Initialize settings panel

	LAM:RegisterAddonPanel(NAME, {
		type = "panel",
		name = GetString(SI_ADVSET_TITLE),
		version = VERSION,
		author = "@code65536",
		slashCommand = "/advset",
		registerForRefresh = true,
	})

	LAM:RegisterOptionControls(NAME, {
		--------------------------------------------------------------------
		{
			type = "description",
			text = SI_ADVSET_PREAMBLE,
		},

		--------------------------------------------------------------------
		{
			type = "divider",
		},
		--------------------
		{
			type = "checkbox",
			name = SI_ADVSET_FRAMECAP,
			tooltip = SI_ADVSET_FRAMECAP_TT,
			getFunc = function() return fpsLimitEnabled end,
			setFunc = function( enabled )
				fpsLimitEnabled = enabled
				fpsLimitUpdate()
			end,
			disabled = function() return type(frameTime) ~= "number" end
		},
		--------------------
		{
			type = "slider",
			tooltip = SI_ADVSET_FRAMECAP_TT,
			min = FPS_MIN,
			max = FPS_MAX,
			step = FPS_STEP,
			getFunc = function() return fpsLimit end,
			setFunc = function( fps )
				fpsLimit = fps
				fpsLimitUpdate()
			end,
			disabled = function() return not fpsLimitEnabled end
		},

		--------------------------------------------------------------------
		{
			type = "divider",
		},
		--------------------
		{
			type = "checkbox",
			name = SI_ADVSET_SKIPLOGOS,
			tooltip = SI_ADVSET_SKIPLOGOS_TT,
			getFunc = function() return GetCVar("SkipPregameVideos") == "1" end,
			setFunc = function(enabled) SetCVar("SkipPregameVideos", enabled and "1" or "0") end,
		},

		--------------------------------------------------------------------
		{
			type = "divider",
		},
		--------------------
		{
			type = "checkbox",
			name = SI_ADVSET_SUSTAIN,
			getFunc = function() return GetCVar("EnergySustainabilityMeasuresEnabled") == "1" end,
			setFunc = function(enabled) SetCVar("EnergySustainabilityMeasuresEnabled", enabled and "1" or "0") end,
		},

		--------------------------------------------------------------------
		{
			type = "divider",
		},
		--------------------
		{
			type = "checkbox",
			name = SI_ADVSET_DETAILMAP,
			tooltip = SI_ADVSET_DETAILMAP_TT,
			getFunc = function() return GetCVar("DETAIL_MAPS") == "0" end,
			setFunc = function(enabled) SetCVar("DETAIL_MAPS", enabled and "0" or "1") end,
		},

		--------------------------------------------------------------------
		{
			type = "divider",
		},
		--------------------
		{
			type = "dropdown",
			name = SI_ADVSET_LANGUAGE,
			tooltip = SI_ADVSET_LANGUAGE_TT,
			warning = SI_ADVSET_LANGUAGE_WARN,
			choices = {
				"English",
				"Deutsch",
				"Français",
				"русский",
				"Español",
				"中文",
				"日本語 (*)",
				"Italiano (*)",
			},
			choicesValues = {
				"en",
				"de",
				"fr",
				"ru",
				"es",
				"zh",
				"jp",
				"it",
			},
			getFunc = function() return(GetCVar("Language.2")) end,
			setFunc = function(lang) SetCVar("Language.2", lang) end,
		},
	})
end)
