if not GildedUI then return end

local Addon = GildedUI

function Addon:CreatePlayerOverlay()
    local wm = WINDOW_MANAGER
    self:CreateCombatStatusOverlay(wm)
end

function Addon:ApplyPlayerDefaults()
    self:ApplyCombatStatusPosition()
    self:ApplyCombatStatusColor()
end
