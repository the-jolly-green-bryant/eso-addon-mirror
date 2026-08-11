if not GildedUI then return end

local Addon = GildedUI

Addon:RegisterDefaults({
    showResourcesInMenu = false,
    hideResourcesInBattlegrounds = true,
})

function Addon:SanitizeResourcesGeneral()
    self:SanitizeSavedBoolean("showResourcesInMenu")
    self:SanitizeSavedBoolean("hideResourcesInBattlegrounds")
end

Addon:RegisterMenuSection(function(menu, H)
    local sv = Addon.state.sv
    local controls = {
        H.Toggle(
            "Show Resources in this menu",
            function() return sv.showResourcesInMenu end,
            function(v)
                sv.showResourcesInMenu = v
                Addon:UpdateVisibility()
            end,
            Addon.defaults.showResourcesInMenu
        ),
        H.Toggle(
            "Hide in Battlegrounds",
            function() return sv.hideResourcesInBattlegrounds end,
            function(v)
                sv.hideResourcesInBattlegrounds = v
                Addon:UpdateVisibility()
            end,
            Addon.defaults.hideResourcesInBattlegrounds
        ),
    }
    H.Append(controls, Addon:BuildIndicatorsMenu(H))
    H.Append(controls, Addon:BuildCurrenciesMenu(H))

    menu:AddOptions({
        {
            type = "submenu",
            name = "Resources",
            centerSubmenu = false,
            icon = "/esoui/art/inventory/gamepad/gp_inventory_icon_currencies.dds",
            options = controls,
        },
    })
end)
