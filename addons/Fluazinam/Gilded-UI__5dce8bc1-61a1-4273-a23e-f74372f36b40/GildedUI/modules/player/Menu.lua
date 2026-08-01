if not GildedUI then return end

local Addon = GildedUI

function Addon:BuildPlayerMenu(H)
    local controls = {}
    H.Append(controls, Addon:BuildPlayerIndicatorsMenu(H))

    return {
        type = "submenu",
        name = "Player",
        centerSubmenu = false,
        icon = "/esoui/art/menubar/gamepad/gp_playermenu_icon_character.dds",
        controls = controls,
    }
end
