if not GildedUI then return end

local Addon = GildedUI

Addon:RegisterMenuSection(function(menu, H)
    menu:AddOptions({
        {
            type = "section",
            name = "System",
            align = "leftIndent",
            options = {
                {
                    type = "submenu",
                    name = "Mount",
                    align = "leftIndent",
                    icon = "/esoui/art/collections/default/collections_default_mount.dds",
                    options = {
                        Addon:BuildStayMountedMenu(H),
                    },
                },
            },
        },
    })
end)
