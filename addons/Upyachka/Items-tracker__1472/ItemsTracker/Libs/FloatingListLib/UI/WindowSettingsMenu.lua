--Register with LibStub
local MAJOR, MINOR = "Up_WindowSettingsMenu", 1
local LIB, _ = LibStub:NewLibrary(MAJOR, MINOR)
if not LIB then return end -- avoid double loading.

--- Settings menu for floating window.

--- LibAddonMenu reference.
local SettingsMenu = LibStub:GetLibrary("Up_FloatingWindowSettingsMenu")

--- Describes menu for fence data provider.
function LIB.createOptionsData(addon)
    return {
        [1] = {
            type = "description",
            text = GetString(CONFIG_WINDOW_BACKDROP_STATE),
        },
        [2] = {
            type = "checkbox",
            name = GetString(CONFIG_ENABLED_STATE_TOGGLE),
            tooltip = GetString(CONFIG_ENABLED_STATE_TOGGLE_TOOLTIP),
            getFunc = function() return addon.Settings.UI.Window.Background.Enabled end,
            setFunc = function(state) addon.Settings.UI.Window.Background.Enabled = state; ReloadUI("ingame") end,
            width = "full", --or "half" (optional)
            disabled = false, --or boolean (optional)
            warning = GetString(CONFIG_UI_RELOAD_REQUIREMENT), --(optional)
            default = addon.Default.Settings.UI.Window.Background.Enabled, --(optional)
            reference = nil --(optional) unique global reference to control
        },
    }
end

--- Creates settings menu for fence data provider.
function LIB.createMenu(addon, name)
    local optionsData = LIB.createOptionsData(addon)
    SettingsMenu.createMenu(addon, optionsData, name)
end
