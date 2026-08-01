if not GildedUI then return end

local Addon = GildedUI

function Addon:BuildLayoutMenu(H)
    return {
        type = "submenu",
        name = "Layout",
        centerSubmenu = false,
        icon = "/esoui/art/menubar/gamepad/gp_playermenu_icon_settings.dds",
		controls = {
			Addon:BuildTrackerColumnMenu(H),
			Addon:BuildAlertTextMenu(H),
		},
    }
end
