NQOL = NQOL or {}
NQOL.Features = NQOL.Features or {}

local Map = {}

local defaults = {
    map = {
        freeport = false,
        freeportFallback = "auto",
        bypassFastTravelConfirmation = false,
    },
}

local FREEPORT_FALLBACK_CHOICES = { "cancel", "confirm", "auto" }
local FREEPORT_FALLBACK_CHOICE_NAMES = NQOL.Lexicon.LocalizedList({ "common.cancel", "common.confirm", "common.auto" })
local FREEPORT_FALLBACK_ALLOWED = {
    cancel = true,
    confirm = true,
    auto = true,
}

local savedVariables
local initialized = false
local fastTravelConfirmationHooked = false

local function GetSettings()
    local settings = NQOL.Settings.GetSection(savedVariables, defaults, "map")
    local defaultSettings = defaults.map

    NQOL.Settings.Default(settings, defaultSettings, "freeport")
    NQOL.Settings.Default(settings, defaultSettings, "freeportFallback")
    NQOL.Settings.Default(settings, defaultSettings, "bypassFastTravelConfirmation")

    settings.freeport = settings.freeport == true
    if not FREEPORT_FALLBACK_ALLOWED[settings.freeportFallback] then
        settings.freeportFallback = defaultSettings.freeportFallback
    end

    settings.bypassFastTravelConfirmation = settings.bypassFastTravelConfirmation == true

    return settings
end

local function ShouldBypassTravelConfirmation(dialogName, data)
    return (dialogName == "FAST_TRAVEL_CONFIRM" or dialogName == "RECALL_CONFIRM")
        and GetSettings().bypassFastTravelConfirmation == true
        and data
        and type(data.nodeIndex) == "number"
        and type(FastTravelToNode) == "function"
end

local function BypassTravelConfirmation(data)
    FastTravelToNode(data.nodeIndex)

    if SCENE_MANAGER and SCENE_MANAGER.ShowBaseScene then
        SCENE_MANAGER:ShowBaseScene()
    end
end

local function InstallFastTravelConfirmationHook()
    if fastTravelConfirmationHooked or type(ZO_PreHook) ~= "function" or type(ZO_Dialogs_ShowPlatformDialog) ~= "function" then
        return
    end

    fastTravelConfirmationHooked = true

    ZO_PreHook("ZO_Dialogs_ShowPlatformDialog", function(dialogName, data)
        if ShouldBypassTravelConfirmation(dialogName, data) then
            BypassTravelConfirmation(data)
            return true
        end
    end)
end

function Map.InitializeSavedVariables()
    savedVariables = NQOL.Settings.NewAccountWide(defaults)
    GetSettings()
end

function Map.Initialize()
    if initialized then
        return
    end

    initialized = true
    InstallFastTravelConfirmationHook()
end

function Map.GetFreeport()
    return GetSettings().freeport
end

function Map.GetFreeportDefault()
    return defaults.map.freeport
end

function Map.SetFreeport(value)
    GetSettings().freeport = value == true

    if NQOL.Features.Freeport and NQOL.Features.Freeport.RefreshAvailabilityEvents then
        NQOL.Features.Freeport.RefreshAvailabilityEvents()
    end

    if NQOL.Features.Freeport and NQOL.Features.Freeport.RefreshKeybinds then
        NQOL.Features.Freeport.RefreshKeybinds()
    end
end

function Map.GetFreeportFallback()
    return GetSettings().freeportFallback
end

function Map.GetFreeportFallbackDefault()
    return defaults.map.freeportFallback
end

function Map.SetFreeportFallback(value)
    if not FREEPORT_FALLBACK_ALLOWED[value] then
        value = defaults.map.freeportFallback
    end

    GetSettings().freeportFallback = value
end

function Map.GetFreeportFallbackChoices()
    return FREEPORT_FALLBACK_CHOICES
end

function Map.GetFreeportFallbackChoiceNames()
    return FREEPORT_FALLBACK_CHOICE_NAMES
end

function Map.GetBypassFastTravelConfirmation()
    return GetSettings().bypassFastTravelConfirmation
end

function Map.SetBypassFastTravelConfirmation(value)
    GetSettings().bypassFastTravelConfirmation = value == true
end

function Map.GetFreeportLabel()
    return NQOL.L("features.map.freeport_label")
end

function Map.GetFreeportTooltip()
    return NQOL.L("features.map.freeport_tooltip")
end

function Map.GetFreeportFallbackLabel()
    return NQOL.L("features.map.freeport_fallback_label")
end

function Map.GetFreeportFallbackTooltip()
    return NQOL.L("features.map.freeport_fallback_tooltip")
end

function Map.GetBypassFastTravelConfirmationLabel()
    return NQOL.L("features.map.bypass_fast_travel_confirmation_label")
end

function Map.GetBypassFastTravelConfirmationTooltip()
    return NQOL.L("features.map.bypass_fast_travel_confirmation_tooltip")
end

NQOL.Features.Map = Map
