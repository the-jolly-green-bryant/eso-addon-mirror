if not GildedUI then return end

local Addon = GildedUI

function Addon:BuildSettingsMenu()
    local LCM = LibConsoleMenu
    if not LCM or type(LCM.CreateAddonMenu) ~= "function" then
        error("LibConsoleMenu is not available")
    end

    local menu = LCM:CreateAddonMenu(self.name, {
        title = self.title,
        author = "Fluazinam",
        version = self.version,
        category = "ui_graphics",
        enableDefaults = true,
        enableReset = true,
        centerSubmenus = true,
        resetFunc = function()
            Addon:ResetToDefaults()
        end,
    })

    local H = self:CreateSettingsHelpers()
    local sections = self.menuSections or {}
    for i = 1, #sections do
        sections[i](menu, H)
    end
end
