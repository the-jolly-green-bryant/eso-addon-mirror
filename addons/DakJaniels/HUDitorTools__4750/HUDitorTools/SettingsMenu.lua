-- -----------------------------------------------------------------------------
-- HUDitorTools
-- LibAddonMenu-2.0 settings menu
-- -----------------------------------------------------------------------------

-- Global table
local HT = HUDitorTools

function HT.buildSettingsMenu()
    local LAM = LibAddonMenu2
    local defaults = HT.Defaults
    local settings = HT.SV

    local panelData =
    {
        type                = "panel",
        name                = HT.name,
        displayName         = HT.displayName,
        author              = HT.author,
        version             = tostring(HT.version),
        registerForRefresh  = true,
        registerForDefaults = true,
        slashCommand        = "/hudis",
        website             = HT.addonWebsite,
        feedback            = HT.addonFeedback,
        donation            = HT.addonDonation,
    }
    local lamSettingsPanelName = HT.eventName .. "_LAM"
    HT.LAMSettingsPanel = LAM:RegisterAddonPanel(lamSettingsPanelName, panelData)

    local optionsTable =
    {
        -- ==============================================================================
        {
            type = "header",
            name = "HUD Editor Info Box",
        },
        {
            type = "checkbox",
            name = "Settings button at HUD Editor InfoBox",
            tooltip = "Enable a right click context-menu settings button top-left at the InfoBox of the HUD Editor.\If this is enabled the \'Grid\' settings will move from the InfoBox to this context menu!",
            getFunc = function () return settings.HUDEditorShowInfoBoxSettingsButton end,
            setFunc = function (value)
                settings.HUDEditorShowInfoBoxSettingsButton = value
                HT.HUDUIStuff()
            end,
            default = defaults.HUDEditorShowInfoBoxSettingsButton,
            -- requiresReload = true,
            width = "full",
        },
        {
            type = "header",
            name = "HUD Editor",
        },
        {
            type = "checkbox",
            name = "Enable context-menu at HUD controls",
            tooltip = "Enable a right click context-menu at movable HUD controls, where you can e.g. hide/show the HUD elements at the current HUD editor (for a better overview).\nHidden HUD elements can also be enabled from the Info Box dropdown list again (enties in red color are user-hidden HUD elements).",
            getFunc = function () return settings.HUDEditContextMenu end,
            setFunc = function (value)
                settings.HUDEditContextMenu = value
                HT.HUDUIStuff()
            end,
            default = defaults.HUDEditContextMenu,
            -- requiresReload = true,
            width = "full",
        },
        {
            type = "colorpicker",
            name = "Hidden HUD element\'s border color",
            tooltip = "Change the border color of hidden HUD elements, so you can see them which ones are hidden at your HUD, without having to check each element\'s InfoBox",
            getFunc = function ()
                local HUDEditHiddenBorderColor = settings.HUDEditHiddenBorderColor
                return HUDEditHiddenBorderColor.r, HUDEditHiddenBorderColor.g, HUDEditHiddenBorderColor.b, HUDEditHiddenBorderColor.a
            end,
            setFunc = function (r, g, b, a)
                settings.HUDEditHiddenBorderColor = { r = r, g = g, b = b, a = a }
                HT.HUDUI_UpdateColor("HUDEditHiddenBorderColor")
            end,
            default = function ()
                HT.HUDUI_UpdateColor("HUDEditHiddenBorderColor", true)
                local defaultEdgeColor = ZO_HUD_EDITOR_ELEMENT_COLORS_KEYBOARD.selectedHidden.edge
                return defaultEdgeColor:UnpackRGBA()
            end,
            width = "full",
        },
        {
            type = "header",
            name = "Grid",
        },
        {
            type = "checkbox",
            name = "Show grid overlay",
            tooltip = "Enable a grid below the HUD editor elements, where you can visually align the elements to (or use the snap-to-grid feature below).",
            getFunc = function () return settings.showGrid end,
            setFunc = function (value)
                settings.showGrid = value
                HT.HUDUIStuff()
            end,
            default = defaults.showGrid,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Enable snap-to-grid",
            tooltip = "Enable the snap-to-grid feature at the grid overlay: Elements moved will be automatically aligned to the grid.",
            getFunc = function () return settings.gridSnap end,
            setFunc = function (value)
                settings.gridSnap = value
                HT.HUDUIStuff()
            end,
            default = defaults.gridSnap,
            width = "full",
            disabled = function () return not settings.showGrid end
        },
        {
            type = "slider",
            name = "Grid size",
            tooltip = "The grid\'s size",
            min = 2,
            max = 100,
            step = 1,
            clampInput = true,
            decimals = 0,
            autoSelect = true,
            getFunc = function () return settings.gridSize end,
            setFunc = function (value)
                settings.gridSize = value
                -- HT.RefreshGridOverlay() Editor never shows if the LAM menu is used
            end,
            default = defaults.gridSize,
            width = "full",
            disabled = function () return not settings.showGrid end
        },
        {
            type = "colorpicker",
            name = "Grid line color",
            tooltip = "Change the grid line color and alpha level",
            getFunc = function ()
                local HUDEditGridColor = settings.gridColor
                return HUDEditGridColor.r, HUDEditGridColor.g, HUDEditGridColor.b, HUDEditGridColor.a
            end,
            setFunc = function (r, g, b, a)
                settings.gridColor = { r = r, g = g, b = b, a = a }
                HT.HUDUI_UpdateColor("gridColor")
            end,
            default = function ()
                local defaultGridColor = defaults.gridColor
                return defaultGridColor.r, defaultGridColor.g, defaultGridColor.b, defaultGridColor.a
            end,
            width = "full",
        },
    }

    LAM:RegisterOptionControls(lamSettingsPanelName, optionsTable)
end
