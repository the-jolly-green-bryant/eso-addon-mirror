ACTIVITY_FINDER_PLUS = {}

ACTIVITY_FINDER_PLUS.name = "ActivityFinderPlus"
ACTIVITY_FINDER_PLUS.version = "1.0.2"
ACTIVITY_FINDER_PLUS.displayName = "Activity Finder Plus"
ACTIVITY_FINDER_PLUS.author = "FirewoodDoge"
ACTIVITY_FINDER_PLUS.authorDisplay = ACTIVITY_FINDER_PLUS.author
ACTIVITY_FINDER_PLUS.repositoryUrl = "https://github.com/sivaDog/ActivityFinderPlus"
ACTIVITY_FINDER_PLUS.variableVersion = 1

ACTIVITY_FINDER_PLUS.savedVariables = nil
ACTIVITY_FINDER_PLUS.eventManager = GetEventManager()
ACTIVITY_FINDER_PLUS.playerName = GetDisplayName()
ACTIVITY_FINDER_PLUS.activityFinderCode = -1
ACTIVITY_FINDER_PLUS.showSpecificDung = false
ACTIVITY_FINDER_PLUS.libSetsAvailable = false

ACTIVITY_FINDER_PLUS.coolDownStatus = {
    [LFG_COOLDOWN_ACTIVITY_STARTED] = false,
    [LFG_COOLDOWN_BATTLEGROUND_DESERTED] = false,
}

ACTIVITY_FINDER_PLUS.checkPledges = { button = nil, state = BSTATE_NORMAL }
ACTIVITY_FINDER_PLUS.checkSets = { button = nil, state = BSTATE_NORMAL }
ACTIVITY_FINDER_PLUS.checkSkillQuests = { button = nil, state = BSTATE_NORMAL }
ACTIVITY_FINDER_PLUS.checkVeteran = { label = nil, checkbox = nil, sessionEnabled = false }

ACTIVITY_FINDER_PLUS.defaults = {
    AutoAccept = false,
    AutoRelease = false,
    EnhanceGAF = true,
    ShowSetCollectionProgress = true,
    NotifyDelay = 2,
    ScreenNotify = true,
    SoundNotify = true,
    gamepadQuickSelectKeybindTouched = false,
    gamepadQuickSelectBinding = nil,
    KeyboardAchievementSeparateWindow = false,
}

ACTIVITY_FINDER_PLUS.runtimeSettingKeys = {
    "SoundNotify",
    "ScreenNotify",
    "AutoRelease",
    "AutoAccept",
    "NotifyDelay",
    "EnhanceGAF",
    "ShowSetCollectionProgress",
    "KeyboardAchievementSeparateWindow",
}

function ACTIVITY_FINDER_PLUS.GetSetting(key)
    local savedVariables = ACTIVITY_FINDER_PLUS.savedVariables
    if not savedVariables then
        return ACTIVITY_FINDER_PLUS.defaults[key]
    end

    local value = savedVariables[key]
    if value == nil then
        return ACTIVITY_FINDER_PLUS.defaults[key]
    end
    return value
end

function ACTIVITY_FINDER_PLUS.SetSetting(key, value)
    ACTIVITY_FINDER_PLUS.savedVariables[key] = value
    ACTIVITY_FINDER_PLUS[key] = value
end

function ACTIVITY_FINDER_PLUS.ApplyRuntimeSettings()
    for _, key in ipairs(ACTIVITY_FINDER_PLUS.runtimeSettingKeys) do
        ACTIVITY_FINDER_PLUS[key] = ACTIVITY_FINDER_PLUS.GetSetting(key)
    end
end
