if not GildedUI then return end

local Addon = GildedUI

function Addon:BuildSystemMenu(H)
    return {
        type = "submenu",
        name = "Mount",
        centerSubmenu = false,
        icon = "/esoui/art/collections/default/collections_default_mount.dds",
        controls = {
            Addon:BuildStayMountedMenu(H),
        },
    }
end
