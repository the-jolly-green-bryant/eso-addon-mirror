-----------------------------------------------------------
-- Author: SpringPeace2575 | Version: 1.6.2
-- Inspired by original RandoMote add-on for PC only from: Scorp
-- Completely reworked, improved and extended, by default for consoles
-----------------------------------------------------------

RandoMoteInner = RandoMoteInner or {}
local RM = RandoMoteInner
local RMEmotes = RandoMoteEmotesInner
local RMPlayer = RandoMotePlayerInner
local RMSettings = RandoMoteSettingsInner

RM.name             = "RandoMoteDev"
RM.displayName      = "RandoMote (Dev)"
RM.savedVarsName    = "RandoMoteDevSavedVars"
RM.savedVarsVersion = 1
RM.version          = "1.6.2"
RM.settingsPanelId  = "RandoMoteDevPanel"
-- RM.playerName       = GetDisplayName()

RM.defaults = {
    enable = true,
    debug = false,
    useStandard = true,
    useCollectible = true,
    useFavouriteOnly = false,
    selectedPreset = "None",
    showLocked = false,
    showSlash = false,
    chatOutput = false,
    idleMax = 15,
    minTime = 10,
    maxTime = 30,
    useEmote = {},
    useCategory = {},
    favEmote = {},
    presetEmote = {
        None = {},
        Dancer = {},
        Musician = {},
        Goofball = {},
        Custom1 = {},
        Custom2 = {},
        Custom3 = {},
    },
}

RM.sv = {
    enable = RM.defaults.enable,
    debug = RM.defaults.debug,
    useStandard = RM.defaults.useStandard,
    useCollectible = RM.defaults.useCollectible,
    useFavouriteOnly = RM.defaults.useFavouriteOnly,
    selectedPreset = RM.defaults.selectedPreset,
    showLocked = RM.defaults.showLocked,
    showSlash = RM.defaults.showSlash,
    chatOutput = RM.defaults.chatOutput,
    idleMax = RM.defaults.idleMax,
    minTime = RM.defaults.minTime,
    maxTime = RM.defaults.maxTime,
    useEmote = RM.defaults.useEmote,
    useCategory = RM.defaults.useCategory,
    favEmote = RM.defaults.favEmote,
    presetEmote = RM.defaults.presetEmote,
}

RM.state = {
    rebuildLists = false,
    idleCount = 0,
    delayCount = 0,
    delayMax = 0,
    emoteData = {},
    cats = {},
    catIds = {},
    normalEmoteList = {},
    favEmoteList = {},
    presetEmoteList = {
        None = {},
        Dancer = {},
        Musician = {},
        Goofball = {},
        Custom1 = {},
        Custom2 = {},
        Custom3 = {},
    },
}

RM.slashCommand = {
	emote = "/rm",
	settings = "/randomote",
	-- list = "/randomotelist",
}

function RM.ExtensionInitialize() end

function RM.Initialize()
    RM.sv = ZO_SavedVars:NewAccountWide(RM.savedVarsName, RM.savedVarsVersion, nil, RM.defaults, GetWorldName())

    RMEmotes.Initialize(RM.sv, RM.state, RMSettings.RefreshSettings)
	RMPlayer.Initialize(RM.sv, RM.state)
    RMSettings.Initialize(RM.sv, RM.defaults, RM.name)
    RM.SeedRandom()

    RM.CreateSettingsWindow()
	RM.RegisterEvents()

	RM.ExtensionInitialize()
end

function RM.SeedRandom()
	-- Seed once (better randomness, less CPU)
	if not RM._rngSeeded then
		local t = GetFrameTimeMilliseconds and GetFrameTimeMilliseconds() or os.time()
		math.randomseed(t)
		RM._rngSeeded = true
	end
end

function RM.CreateSettingsWindow()
	local panelData = {
		type = "panel",
		name = RM.name,
		displayName = RM.displayName,
		author = "SpringPeace2575",
		version = RM.version,
		slashCommand = RM.slashCommand.settings,
		registerForRefresh = true,
		registerForDefaults = true,
		-- website = "https://www.esoui.com/downloads/info3461",
	}

	RMSettings.RegisterSettings(panelData, RM.settingsPanelId)
end

function RM.RegisterEvents()
    EVENT_MANAGER:RegisterForEvent(RM.name .. "_Main", EVENT_COLLECTIBLES_UNLOCK_STATE_CHANGED, function(_, ...)
        RMEmotes.OnCollectiblesUnlockStateChanged(...)
    end)
end

-----------------------------------------------------------
-- Event wiring
-----------------------------------------------------------
function RM.ExtensionOnLoaded() end

local function OnAddOnLoaded(eventCode, addonName)
    if addonName ~= RM.name then return end

    EVENT_MANAGER:UnregisterForEvent(RM.name, EVENT_ADD_ON_LOADED)

    RM.Initialize()

    EVENT_MANAGER:RegisterForEvent(RM.name, EVENT_PLAYER_ACTIVATED, function()
        RMPlayer.Loop()
        EVENT_MANAGER:UnregisterForEvent(RM.name, EVENT_PLAYER_ACTIVATED)
    end)

    EVENT_MANAGER:RegisterForEvent(RM.name, EVENT_ZONE_CHANGED, function() RMPlayer.ResetTimer() end)
    EVENT_MANAGER:RegisterForEvent(RM.name, EVENT_START_FAST_TRAVEL_INTERACTION, function() RMPlayer.ResetTimer() end)

    SLASH_COMMANDS[RM.slashCommand.emote] = function()
        RMPlayer.PlayRandomEmoteNow()
    end
    --SLASH_COMMANDS[RM.slashCommand.list] = function() RM.DisplayEmoteInfo() end
	RM.ExtensionOnLoaded()
end

EVENT_MANAGER:RegisterForEvent(RM.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
