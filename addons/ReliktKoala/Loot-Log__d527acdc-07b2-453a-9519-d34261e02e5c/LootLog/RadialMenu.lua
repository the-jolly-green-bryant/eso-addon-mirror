LootLog = LootLog or {}
local LL = LootLog

local RADIAL_ENTRY_ID = "lootlog:open-ui"
local RADIAL_ENTRY_NAME = "Open Loot Log"
local RADIAL_ENTRY_ICON = "/esoui/art/icons/lore_book4_detail2_color1.dds"
local RADIAL_ENTRY_DESCRIPTION = "Open the LootLog browser window."

function LL.RegisterRadialMenu()
    local radialMenu = LibRadialMenu
    if not radialMenu then
        return
    end

    if type(radialMenu.RegisterAddon) ~= "function" or type(radialMenu.RegisterEntry) ~= "function" then
        LL.Print("LibRadialMenu detected, but API did not match expected functions.")
        return
    end

    radialMenu:RegisterAddon(LL.name, "Loot Log")
    radialMenu:RegisterEntry(
        LL.name,
        RADIAL_ENTRY_NAME,
        RADIAL_ENTRY_ID,
        RADIAL_ENTRY_ICON,
        function()
            LL.ShowUI()
        end,
        RADIAL_ENTRY_DESCRIPTION
    )
end
