local ACTIVITY_FINDER_PLUS = ACTIVITY_FINDER_PLUS
local LAM = LibAddonMenu2
local PANEL_NAME = "ACTIVITY_FINDER_PLUS_Settings"

local function RefreshCollectionDisplay()
    ACTIVITY_FINDER_PLUS.BuildCollectionCache()
    if ACTIVITY_FINDER_PLUS.showSpecificDung then
        ACTIVITY_FINDER_PLUS.DecorateDungeonRows()
    end
end

local function CheckboxOption(key, nameId, tooltipId, defaultValue, extra)
    local option = {
        type = "checkbox",
        name = GetString(nameId),
        tooltip = GetString(tooltipId),
        default = defaultValue,
        getFunc = function() return ACTIVITY_FINDER_PLUS.GetSetting(key) end,
        setFunc = function(value) ACTIVITY_FINDER_PLUS.SetSetting(key, value) end,
    }

    if extra then
        for optionKey, optionValue in pairs(extra) do
            option[optionKey] = optionValue
        end
    end

    return option
end

function ACTIVITY_FINDER_PLUS.CreateSettingsWindow()
    local panelData = {
        type = "panel",
        name = ACTIVITY_FINDER_PLUS.displayName,
        displayName = ACTIVITY_FINDER_PLUS.displayName,
        author = ACTIVITY_FINDER_PLUS.authorDisplay,
        version = ACTIVITY_FINDER_PLUS.version,
        website = ACTIVITY_FINDER_PLUS.repositoryUrl,
        slashCommand = "/afp",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    LAM:RegisterAddonPanel(PANEL_NAME, panelData)

    local optionsData = {
        { type = "header", name = GetString(SI_ACTIVITY_FINDER_PLUS_HEADER_LFG) },
        CheckboxOption("SoundNotify", SI_ACTIVITY_FINDER_PLUS_SOUND, SI_ACTIVITY_FINDER_PLUS_SOUND_TT, true),
        CheckboxOption("ScreenNotify", SI_ACTIVITY_FINDER_PLUS_SCREEN, SI_ACTIVITY_FINDER_PLUS_SCREEN_TT, true),
        CheckboxOption("AutoAccept", SI_ACTIVITY_FINDER_PLUS_ACCEPT, SI_ACTIVITY_FINDER_PLUS_ACCEPT_TT, false),
        {
            type = "slider",
            name = GetString(SI_ACTIVITY_FINDER_PLUS_DELAY),
            tooltip = GetString(SI_ACTIVITY_FINDER_PLUS_DELAY_TT),
            min = 1,
            max = 5,
            step = 1,
            default = 2,
            disabled = function() return not ACTIVITY_FINDER_PLUS.SoundNotify end,
            getFunc = function() return ACTIVITY_FINDER_PLUS.GetSetting("NotifyDelay") end,
            setFunc = function(value) ACTIVITY_FINDER_PLUS.SetSetting("NotifyDelay", value) end,
        },

        { type = "header", name = GetString(SI_ACTIVITY_FINDER_PLUS_HEADER_FINDER) },
        CheckboxOption("EnhanceGAF", SI_ACTIVITY_FINDER_PLUS_ENHANCE, SI_ACTIVITY_FINDER_PLUS_ENHANCE_TT, true),
        CheckboxOption("ShowSetCollectionProgress", SI_ACTIVITY_FINDER_PLUS_SET_COLLECTION, SI_ACTIVITY_FINDER_PLUS_SET_COLLECTION_TT, true, {
            disabled = function() return not ACTIVITY_FINDER_PLUS.libSetsAvailable end,
            setFunc = function(value)
                ACTIVITY_FINDER_PLUS.SetSetting("ShowSetCollectionProgress", value)
                RefreshCollectionDisplay()
            end,
        }),
        CheckboxOption("KeyboardAchievementSeparateWindow", SI_ACTIVITY_FINDER_PLUS_KEYBOARD_TOOLTIP_MODE, SI_ACTIVITY_FINDER_PLUS_KEYBOARD_TOOLTIP_MODE_TT, false, {
            disabled = function() return not ACTIVITY_FINDER_PLUS.EnhanceGAF end,
        }),

        { type = "header", name = GetString(SI_ACTIVITY_FINDER_PLUS_HEADER_OTHER) },
        CheckboxOption("AutoRelease", SI_ACTIVITY_FINDER_PLUS_RELEASE, SI_ACTIVITY_FINDER_PLUS_RELEASE_TT, false),
        { type = "description", text = GetString(SI_ACTIVITY_FINDER_PLUS_SLASH_TT) },
    }
    LAM:RegisterOptionControls(PANEL_NAME, optionsData)
end
