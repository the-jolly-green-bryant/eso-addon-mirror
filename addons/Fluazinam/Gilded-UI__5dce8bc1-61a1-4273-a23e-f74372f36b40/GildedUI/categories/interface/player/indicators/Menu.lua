if not GildedUI then return end

local Addon = GildedUI

function Addon:SanitizePlayerIndicators()
    self:SanitizeCombatStatus()
end

function Addon:BuildPlayerIndicatorsMenu(H)
    local sv = self.state.sv

    local combatControls = {
        H.Toggle(
            "Enable Combat Status",
            function() return sv.showCombatStatus end,
            function(v) Addon:SetCombatStatusEnabled(v) end,
            Addon.defaults.showCombatStatus
        ),
        H.ColorPicker(
            "In Combat Color",
            "combatStatusInCombatColor",
            nil,
            true,
            function() Addon:ApplyCombatStatusColor() end
        ),
        H.ColorPicker(
            "Out of Combat Color",
            "combatStatusOutOfCombatColor",
            nil,
            true,
            function() Addon:ApplyCombatStatusColor() end
        ),
    }
    H.Append(combatControls, H.PositionSliders(
        "Combat Status X Position", "Combat Status Y Position",
        "combatStatusPosX", "combatStatusPosY",
        function() Addon:ApplyCombatStatusPosition() end
    ))

    return {
        {
            type = "section",
            name = "Indicators",
            options = {
                {
                    type = "submenu",
                    name = "Combat Status",
                    onEnter = function()
                        Addon:SetCombatStatusMenuPreview(true)
                    end,
                    onExit = function()
                        Addon:SetCombatStatusMenuPreview(false)
                    end,
                    options = combatControls,
                },
            },
        },
    }
end
