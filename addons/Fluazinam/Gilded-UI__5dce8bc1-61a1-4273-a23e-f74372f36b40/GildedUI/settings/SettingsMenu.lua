if not GildedUI then return end

local Addon = GildedUI

function Addon:BuildSettingsMenu()
    local LCM = LibConsoleMenu
    if not LCM or type(LCM.RegisterAddonPanel) ~= "function" then
        error("LibConsoleMenu is not available")
    end

    local panelName = "GildedUISettingsPanel"
    LCM:RegisterAddonPanel(panelName, {
        type = "panel",
        name = self.displayName,
        author = "Fluazinam",
        version = self.version,
        category = "ui_graphics",
        registerForDefaults = true,
        registerForRefresh = true,
        centerSubmenus = true,
        resetFunc = function()
            Addon:ResetToDefaults()
        end,
    })

    local H = self:CreateSettingsHelpers()
    LCM:RegisterOptionControls(panelName, {
        { type = "header", name = "Interface", align = "left" },
        self:BuildAnalyticsMenu(H),
        self:BuildResourcesMenu(H),
        self:BuildPlayerMenu(H),
        self:BuildLayoutMenu(H),
        { type = "header", name = "System", align = "left" },
        self:BuildSystemMenu(H),
    })
end
