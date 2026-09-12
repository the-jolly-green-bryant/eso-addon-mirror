MCAT_Settings = {}

--#region[purple] Modules and locals
local MECHANIC_ORDER = { "GrimFocus", "BoundArmaments", "SeethingFury", "Crux" }

-- Spacing slider display range/offset per mechanic. Stored/used spacing (SavedVariables,
-- Interface.lua's formula) never changes -- only GrimFocus's shown numbers are translated,
-- so its old default of 20 now reads as 0 with the same underlying effect.
local SPACING_UI = {
    GrimFocus = { min = -20, max = 20, offset = 20 },
    BoundArmaments = { min = -20, max = 20, offset = 0 },
    Crux = { min = -20, max = 20, offset = -10 },
    SeethingFury = { min = -20, max = 20, offset = -40 },
}
local DEFAULT_SPACING_UI = { min = 0, max = 50, offset = 0 }

-- color defaults to each mechanic's factory hex from Abilities.lua, so a fresh install
-- looks the same as before this became user-adjustable.
local defaults = {
    debug = false,
    mechanics = {
        GrimFocus = { enabled = true, scale = 1.0, spacing = 20, color = MCAT_Definitions.GrimFocus.color },
        BoundArmaments = { enabled = true, scale = 1.0, spacing = 0, color = MCAT_Definitions.BoundArmaments.color },
        SeethingFury = { enabled = true, scale = 1.0, spacing = -40, color = MCAT_Definitions.SeethingFury.color },
        Crux = { enabled = true, scale = 1.0, spacing = -10, color = MCAT_Definitions.Crux.color },
    },
}

local META_DEFAULTS = { useCharacterSettings = false }

local savedVars
local metaVars -- always account-wide: holds the storage-mode choice itself, read before
                -- knowing which profile (account-wide or per-character) to load into savedVars.
--#endregion

--#region[teal] Accessors
function MCAT_Settings.IsDebugEnabled()
    return savedVars.debug
end

function MCAT_Settings.IsEnabled(mechanicKey)
    return savedVars.mechanics[mechanicKey].enabled
end

function MCAT_Settings.GetScale(mechanicKey)
    return savedVars.mechanics[mechanicKey].scale
end

function MCAT_Settings.GetSpacing(mechanicKey)
    return savedVars.mechanics[mechanicKey].spacing
end

function MCAT_Settings.GetColor(mechanicKey)
    return savedVars.mechanics[mechanicKey].color
end

function MCAT_Settings.IsUsingCharacterSettings()
    return metaVars.useCharacterSettings
end
--#endregion

--#region[orange] Reset
local function CopyMechanicData(from, to)
    to.debug = from.debug
    for mechanicKey, mechanicData in pairs(from.mechanics) do
        to.mechanics[mechanicKey].enabled = mechanicData.enabled
        to.mechanics[mechanicKey].scale = mechanicData.scale
        to.mechanics[mechanicKey].spacing = mechanicData.spacing
        to.mechanics[mechanicKey].color = mechanicData.color
    end
end

local function LoadMainSavedVars(useCharacterSettings)
    if useCharacterSettings then
        return ZO_SavedVars:New("MCAT_SavedVars", 1, nil, defaults)
    end
    return ZO_SavedVars:NewAccountWide("MCAT_SavedVars", 1, nil, defaults)
end

local function SetUseCharacterSettings(value)
    if value == metaVars.useCharacterSettings then return end
    local oldSavedVars = savedVars
    metaVars.useCharacterSettings = value
    savedVars = LoadMainSavedVars(value)
    CopyMechanicData(oldSavedVars, savedVars)
    MCAT.ActionBarUpdated()
end

local function ResetToDefaults()
    savedVars.debug = defaults.debug
    for mechanicKey, mechanicDefaults in pairs(defaults.mechanics) do
        savedVars.mechanics[mechanicKey].enabled = mechanicDefaults.enabled
        savedVars.mechanics[mechanicKey].scale = mechanicDefaults.scale
        savedVars.mechanics[mechanicKey].spacing = mechanicDefaults.spacing
        savedVars.mechanics[mechanicKey].color = mechanicDefaults.color
    end
    MCAT.ActionBarUpdated()
end
--#endregion

--#region[yellow] Panel
local function BuildOptionsTable()
    local optionsTable = {
        {
            type = "button",
            name = "Reset to Default",
            tooltip = "Resets all Multi-Class Ability Tracker settings below to their default values.",
            warning = "This cannot be undone.",
            func = ResetToDefaults,
        },
        {
            type = "checkbox",
            name = "Use Per-Character Settings",
            tooltip = "When enabled, this character keeps its own settings instead of sharing one account-wide configuration. Current settings carry over when you change this.",
            getFunc = MCAT_Settings.IsUsingCharacterSettings,
            setFunc = SetUseCharacterSettings,
            default = META_DEFAULTS.useCharacterSettings,
        },
        {
            type = "header",
            name = "Debug",
        },
        {
            type = "checkbox",
            name = "Debug Mode",
            tooltip = "Shows counters out of combat and prints debug messages to chat.",
            getFunc = MCAT_Settings.IsDebugEnabled,
            setFunc = function(value)
                savedVars.debug = value
                MCAT.ActionBarUpdated()
            end,
            default = defaults.debug,
        },
    }

    for _, mechanicKey in ipairs(MECHANIC_ORDER) do
        local def = MCAT_Definitions[mechanicKey]
        local mechanicDefaults = defaults.mechanics[mechanicKey]

        table.insert(optionsTable, { type = "header", name = def.label })
        table.insert(optionsTable, {
            type = "checkbox",
            name = "Enabled",
            getFunc = function() return MCAT_Settings.IsEnabled(mechanicKey) end,
            setFunc = function(value)
                savedVars.mechanics[mechanicKey].enabled = value
                MCAT.ActionBarUpdated()
            end,
            default = mechanicDefaults.enabled,
        })
        table.insert(optionsTable, {
            type = "colorpicker",
            name = "Color",
            getFunc = function() return MCAT_Utils.HexToRGB(MCAT_Settings.GetColor(mechanicKey)) end,
            setFunc = function(r, g, b)
                savedVars.mechanics[mechanicKey].color = MCAT_Utils.RGBToHex(r, g, b)
                MCAT_Interface.Update()
            end,
            default = (function()
                local r, g, b = MCAT_Utils.HexToRGB(mechanicDefaults.color)
                return { r = r, g = g, b = b }
            end)(),
        })
        table.insert(optionsTable, {
            type = "slider",
            name = "Size",
            min = 0.4, max = 2.0, step = 0.05, decimals = 2,
            getFunc = function() return MCAT_Settings.GetScale(mechanicKey) end,
            setFunc = function(value)
                savedVars.mechanics[mechanicKey].scale = value
                MCAT_Interface.Update()
            end,
            default = mechanicDefaults.scale,
        })
        local spacingUI = SPACING_UI[mechanicKey] or DEFAULT_SPACING_UI
        table.insert(optionsTable, {
            type = "slider",
            name = "Spacing",
            min = spacingUI.min, max = spacingUI.max, step = 1,
            getFunc = function() return MCAT_Settings.GetSpacing(mechanicKey) - spacingUI.offset end,
            setFunc = function(value)
                savedVars.mechanics[mechanicKey].spacing = value + spacingUI.offset
                MCAT_Interface.Update()
            end,
            default = mechanicDefaults.spacing - spacingUI.offset,
        })
    end

    return optionsTable
end

local function CreatePanel()
    local panelData = {
        type = "panel",
        name = "Multi-Class Ability Tracker",
        displayName = "Multi-Class Ability Tracker",
        author = "CerbinTalYalas",
        version = MCAT.version,
        registerForRefresh = true,
    }
    LibAddonMenu2:RegisterAddonPanel(MCAT.name, panelData)
    LibAddonMenu2:RegisterOptionControls(MCAT.name, BuildOptionsTable())
end
--#endregion

--#region[green] Init
function MCAT_Settings.Initialize()
    metaVars = ZO_SavedVars:NewAccountWide("MCAT_SavedVars", 1, "Meta", META_DEFAULTS)
    savedVars = LoadMainSavedVars(metaVars.useCharacterSettings)
    CreatePanel()
end
--#endregion
