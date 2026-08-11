if not GildedUI then return end

local Addon = GildedUI

Addon:RegisterMenuSection(function(menu, H)
    menu:AddOptions({
        {
            type = "submenu",
            name = "Layout",
            centerSubmenu = false,
            icon = "/esoui/art/menubar/gamepad/gp_playermenu_icon_settings.dds",
            options = {
                Addon:BuildTrackerColumnMenu(H),
                Addon:BuildAlertTextMenu(H),
            },
        },
    })
end)
