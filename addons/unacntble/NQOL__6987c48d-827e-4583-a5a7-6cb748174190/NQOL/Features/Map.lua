NQOL = NQOL or {}
NQOL.Features = NQOL.Features or {}

local Map = {}

local defaults = {
    map = {
        freeport = false,
        freeportFallback = "auto",
        bypassFastTravelConfirmation = false,
        showDungeons = false,
        showTrials = false,
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
local wayshrineHandlers
local originalRecallCallback
local originalFastTravelCallback
local bypassCallbacksInstalled = false

local function GetSettings()
    local settings = NQOL.Settings.GetSection(savedVariables, defaults, "map")
    local defaultSettings = defaults.map

    NQOL.Settings.Default(settings, defaultSettings, "freeport")
    NQOL.Settings.Default(settings, defaultSettings, "freeportFallback")
    NQOL.Settings.Default(settings, defaultSettings, "bypassFastTravelConfirmation")
    NQOL.Settings.Default(settings, defaultSettings, "showDungeons")
    NQOL.Settings.Default(settings, defaultSettings, "showTrials")

    settings.freeport = settings.freeport == true
    if not FREEPORT_FALLBACK_ALLOWED[settings.freeportFallback] then
        settings.freeportFallback = defaultSettings.freeportFallback
    end

    settings.bypassFastTravelConfirmation = settings.bypassFastTravelConfirmation == true
    settings.showDungeons = settings.showDungeons == true
    settings.showTrials = settings.showTrials == true

    return settings
end

local function GetWayshrineHandlers()
    local clickHandlers = ZO_MapPin
        and ZO_MapPin.PIN_CLICK_HANDLERS
        and ZO_MapPin.PIN_CLICK_HANDLERS[MOUSE_BUTTON_INDEX_LEFT]
    local handlers = clickHandlers and clickHandlers[MAP_PIN_TYPE_FAST_TRAVEL_WAYSHRINE]
    if type(handlers) ~= "table"
        or type(handlers[1]) ~= "table"
        or type(handlers[2]) ~= "table"
        or type(handlers[1].callback) ~= "function"
        or type(handlers[2].callback) ~= "function"
    then
        return nil
    end

    return handlers
end

local function ReleaseTravelDialogs()
    if type(ZO_Dialogs_ReleaseDialog) ~= "function" then
        return
    end

    ZO_Dialogs_ReleaseDialog("FAST_TRAVEL_CONFIRM")
    ZO_Dialogs_ReleaseDialog("RECALL_CONFIRM")
    ZO_Dialogs_ReleaseDialog("TRAVEL_TO_HOUSE_CONFIRM")
end

local function TravelToNode(nodeIndex)
    if type(nodeIndex) ~= "number" or type(FastTravelToNode) ~= "function" then
        return false
    end

    ReleaseTravelDialogs()

    if type(IsProtectedFunction) == "function"
        and IsProtectedFunction("FastTravelToNode")
        and type(CallSecureProtected) == "function"
    then
        CallSecureProtected("FastTravelToNode", nodeIndex)
    else
        FastTravelToNode(nodeIndex)
    end

    if SCENE_MANAGER and SCENE_MANAGER.ShowBaseScene then
        SCENE_MANAGER:ShowBaseScene()
    end

    return true
end

local function BypassRecall(pin)
    if not pin or not pin.GetFastTravelNodeIndex or not GetRecallCooldown then
        return originalRecallCallback and originalRecallCallback(pin)
    end

    if pin.IsLockedByLinkedCollectible and pin:IsLockedByLinkedCollectible() then
        return originalRecallCallback and originalRecallCallback(pin)
    end

    local _, premiumTimeLeft = GetRecallCooldown()
    if premiumTimeLeft ~= 0 then
        return originalRecallCallback and originalRecallCallback(pin)
    end

    if not TravelToNode(pin:GetFastTravelNodeIndex()) and originalRecallCallback then
        return originalRecallCallback(pin)
    end
end

local function BypassFastTravel(pin)
    if not pin or not pin.GetFastTravelNodeIndex then
        return originalFastTravelCallback and originalFastTravelCallback(pin)
    end

    if pin.IsLockedByLinkedCollectible and pin:IsLockedByLinkedCollectible() then
        return originalFastTravelCallback and originalFastTravelCallback(pin)
    end

    if not TravelToNode(pin:GetFastTravelNodeIndex()) and originalFastTravelCallback then
        return originalFastTravelCallback(pin)
    end
end

local function RestoreWayshrineCallbacks()
    if not bypassCallbacksInstalled or not wayshrineHandlers then
        return
    end

    if wayshrineHandlers[1].callback == BypassRecall then
        wayshrineHandlers[1].callback = originalRecallCallback
    end
    if wayshrineHandlers[2].callback == BypassFastTravel then
        wayshrineHandlers[2].callback = originalFastTravelCallback
    end

    wayshrineHandlers = nil
    originalRecallCallback = nil
    originalFastTravelCallback = nil
    bypassCallbacksInstalled = false
end

local function ApplyFastTravelConfirmationSetting()
    if not GetSettings().bypassFastTravelConfirmation then
        RestoreWayshrineCallbacks()
        return true
    end

    if bypassCallbacksInstalled then
        return true
    end

    local handlers = GetWayshrineHandlers()
    if not handlers then
        return false
    end

    wayshrineHandlers = handlers
    originalRecallCallback = handlers[1].callback
    originalFastTravelCallback = handlers[2].callback
    handlers[1].callback = BypassRecall
    handlers[2].callback = BypassFastTravel
    bypassCallbacksInstalled = true
    return true
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
    ApplyFastTravelConfirmationSetting()
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
    ApplyFastTravelConfirmationSetting()
end

function Map.GetShowDungeons()
    return GetSettings().showDungeons
end

function Map.GetShowDungeonsDefault()
    return defaults.map.showDungeons
end

function Map.SetShowDungeons(value)
    GetSettings().showDungeons = value == true
    if NQOL.Features.MapTravelTabs and NQOL.Features.MapTravelTabs.RefreshTabs then
        NQOL.Features.MapTravelTabs.RefreshTabs()
    end
end

function Map.GetShowTrials()
    return GetSettings().showTrials
end

function Map.GetShowTrialsDefault()
    return defaults.map.showTrials
end

function Map.SetShowTrials(value)
    GetSettings().showTrials = value == true
    if NQOL.Features.MapTravelTabs and NQOL.Features.MapTravelTabs.RefreshTabs then
        NQOL.Features.MapTravelTabs.RefreshTabs()
    end
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

function Map.GetShowDungeonsLabel()
    return NQOL.L("features.map.show_dungeons_label")
end

function Map.GetShowDungeonsTooltip()
    return NQOL.L("features.map.show_dungeons_tooltip")
end

function Map.GetShowTrialsLabel()
    return NQOL.L("features.map.show_trials_label")
end

function Map.GetShowTrialsTooltip()
    return NQOL.L("features.map.show_trials_tooltip")
end

NQOL.Features.Map = Map
