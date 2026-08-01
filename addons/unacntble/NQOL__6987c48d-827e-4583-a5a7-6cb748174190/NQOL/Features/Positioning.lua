NQOL = NQOL or {}
NQOL.Features = NQOL.Features or {}

local Positioning = {}

local DEFAULT_MODE = "normal"

local MODE_DEFINITIONS = {
    {
        key = "normal",
        name = NQOL.L("features.positioning.normal"),
        stepSize = 1,
    },
    {
        key = "fine",
        name = NQOL.L("features.positioning.fine"),
        stepSize = 0.5,
    },
    {
        key = "finer",
        name = NQOL.L("features.positioning.finer"),
        stepSize = 0.25,
    },
    {
        key = "finest",
        name = NQOL.L("features.positioning.finest"),
        stepSize = 0.1,
    },
}
NQOL.Lexicon.RegisterRefreshCallback(function()
    MODE_DEFINITIONS[1].name = NQOL.L("features.positioning.normal")
    MODE_DEFINITIONS[2].name = NQOL.L("features.positioning.fine")
    MODE_DEFINITIONS[3].name = NQOL.L("features.positioning.finer")
    MODE_DEFINITIONS[4].name = NQOL.L("features.positioning.finest")
end)

local VALID_MODES = {}
for _, mode in ipairs(MODE_DEFINITIONS) do
    VALID_MODES[mode.key] = mode
end

local defaults = {
    general = {
        positioning = DEFAULT_MODE,
    },
}

local savedVariables

local function GetSettings()
    local settings = NQOL.Settings.GetSection(savedVariables, defaults, "general")
    NQOL.Settings.Choice(settings, defaults.general, "positioning", VALID_MODES)

    return settings
end

local function GetModeDefinition()
    return VALID_MODES[GetSettings().positioning] or VALID_MODES[DEFAULT_MODE]
end

function Positioning.InitializeSavedVariables()
    savedVariables = NQOL.Settings.NewAccountWide(defaults)
    GetSettings()
end

function Positioning.GetMode()
    return GetSettings().positioning
end

function Positioning.SetMode(value)
    if not VALID_MODES[value] then
        value = DEFAULT_MODE
    end

    GetSettings().positioning = value
end

function Positioning.GetModeChoices()
    local choices = {}
    for index, mode in ipairs(MODE_DEFINITIONS) do
        choices[index] = mode.key
    end

    return choices
end

function Positioning.GetModeChoiceNames()
    local names = {}
    for index, mode in ipairs(MODE_DEFINITIONS) do
        names[index] = mode.name
    end

    return names
end

function Positioning.GetSliderStepSize()
    return GetModeDefinition().stepSize
end

function Positioning.GetModeLabel()
    return NQOL.L("features.positioning.mode_label")
end

function Positioning.GetModeTooltip()
    return NQOL.L("features.positioning.mode_tooltip")
end

NQOL.Features.Positioning = Positioning
