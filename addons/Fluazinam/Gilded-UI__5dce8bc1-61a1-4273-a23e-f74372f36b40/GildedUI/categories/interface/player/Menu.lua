if not GildedUI then return end

local Addon = GildedUI

Addon:RegisterMenuSection(function(menu, H)
    local controls = {}
    H.Append(controls, Addon:BuildPlayerIndicatorsMenu(H))

    menu:AddOptions({
        {
            type = "submenu",
            name = "Player",
            centerSubmenu = false,
            icon = "/esoui/art/menubar/gamepad/gp_playermenu_icon_character.dds",
            options = controls,
        },
    })
end)
