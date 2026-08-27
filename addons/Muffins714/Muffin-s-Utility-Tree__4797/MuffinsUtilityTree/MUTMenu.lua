-- Create a local shortcut for global
local MUT = MuffinsUtilityTree

-- Dependencies
local LAM = LibAddonMenu2

-- Holds our SavedVariable data
local function GetSettings()
    return MUT.GlobalSavedVars
end

MUT.GetSettings = GetSettings

function MUT.CreateSettingsMenu(defaults)
    local panel = {
        type                = "panel",
        name                = MUT.name,
        author              = MUT.author,
        version             = "" .. MUT.version,
        slashCommand        = "/MUT",
        website             = MUT.website,
        registerForRefresh  = true,
        registerForDefaults = true,
    }
    LAM:RegisterAddonPanel(MUT.name, panel)

    -- Pulled from MUT.UIkeybindButton / MUT.UIkeybindScene in main.lua
    local UIkeybindButton = MUT.UIkeybindButton
    local UIkeybindScene = MUT.UIkeybindScene

    -- Automated lists
    local menuDisplayNames1 = {}
    local internalConstants1 = {}
    local menuDisplayNames2 = {}
    local internalConstants2 = {}

    -- Build UI keybind Button list for dropdown
    for k, v in pairs(UIkeybindButton) do
        table.insert(menuDisplayNames1, k)
        table.insert(internalConstants1, v)
    end

    -- Build UI keybind Scene list for dropdown
    for k, v in pairs(UIkeybindScene) do
        table.insert(menuDisplayNames2, k)
        table.insert(internalConstants2, v)
    end

    ---------------------------------------------------------------------------------------------
    -- Main options table
    ---------------------------------------------------------------------------------------------
    local options = {
        {
            type = "header",
            name = GetString(MUT_HEADER_RELOAD_UI),
        },
        -- Reload UI
        {
            type    = "checkbox",
            name    = GetString(MUT_RELOAD_UI),
            tooltip = GetString(MUT_RELOAD_UI_TOOLTIP),
            getFunc = function() return GetSettings().reloadUIEnabled end,
            setFunc = function(value)
                GetSettings().reloadUIEnabled = value
                MUT.AddReloadUIKeyBind()
            end,
            default = defaults.reloadUIEnabled,
            width   = "full",
        },
        -- Key
        {
            type          = "dropdown",
            name          = GetString(MUT_RELOAD_UI_BIND),
            tooltip       = GetString(MUT_RELOAD_UI_BIND_TOOLTIP),
            choices       = menuDisplayNames1,
            choicesValues = internalConstants1,
            getFunc       = function() return GetSettings().chosenKeybind end,
            setFunc       = function(value)
                GetSettings().chosenKeybind = value -- Internal constant
                MUT.AddReloadUIKeyBind()
            end,
            disabled      = function() return not GetSettings().reloadUIEnabled end,
            width         = "half",
        },
        -- Scene
        {
            type          = "dropdown",
            name          = GetString(MUT_RELOAD_UI_SCENE),
            tooltip       = GetString(MUT_RELOAD_UI_SCENE_TOOLTIP),
            choices       = menuDisplayNames2,
            choicesValues = internalConstants2,
            -- Default to "mainMenuGamepad" if nothing is saved
            getFunc       = function() return GetSettings().visibleScene or "mainMenuGamepad" end,
            setFunc       = function(value)
                GetSettings().visibleScene = value -- Internal constant
                MUT.AddReloadUIKeyBind()
            end,
            disabled      = function() return not GetSettings().reloadUIEnabled end,
            width         = "half",
        },
        ---------------------------------------------------------------------------------------------
        -- Multi Splitter submenu
        ---------------------------------------------------------------------------------------------
        {
            type = "header",
            name = GetString(MUT_HEADER_MULTI_SPLITTER),
        },
        {
            type    = "checkbox",
            name    = GetString(MUT_MULTI_SPLITTER_ENABLED),
            getFunc = function() return GetSettings().splitterEnabled end,
            setFunc = function(state)
                GetSettings().splitterEnabled = state
            end,
            default = defaults.splitterEnabled,
            width   = "full",

        },
        ---------------------------------------------------------------------------------------------
        -- Quality Sorter submenu
        ---------------------------------------------------------------------------------------------
        {
            type = "header",
            name = GetString(MUT_HEADER_QUALITY_SORTER),
        },
        {
            type    = "checkbox",
            name    = GetString(MUT_QUALITY_SORTER_ENABLED),
            tooltip = GetString(MUT_QUALITY_SORTER_ENABLED_TOOLTIP),
            getFunc = function() return GetSettings().qualitySortEnabled end,
            setFunc = function(state)
                GetSettings().qualitySortEnabled = state
                if MUT.SetQualitySortEnabled then
                    MUT.SetQualitySortEnabled(state)
                end
            end,
            default = defaults.qualitySortEnabled,
            width   = "full",
        },
    }

    LAM:RegisterOptionControls(MUT.name, options)
end
