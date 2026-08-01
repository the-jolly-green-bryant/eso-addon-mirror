-- Beltalowda Consumable Overview (DEPRECATED)
-- The standalone consumable overview UI has been merged into the
-- Composition Warnings button (CompositionWarnings.lua).
-- This file is kept only for backward compatibility with saved variables
-- and manifest references. It defines legacy stubs so existing calls
-- (Initialize, SetMenuHidden, GetSettingsControls) do not error.

Beltalowda = Beltalowda or {}
Beltalowda.UI = Beltalowda.UI or {}
Beltalowda.UI.ConsumableOverview = Beltalowda.UI.ConsumableOverview or {}

local CO = Beltalowda.UI.ConsumableOverview

-- ============================================================================
-- Stubs — called from Beltalowda.lua / Settings; must be harmless no-ops
-- ============================================================================

function CO.Initialize() end
function CO.SetMenuHidden(_) end
function CO.SetEnabled(_) end
function CO.SetControlVisibility() end

function CO.GetDefaults()
    return {
        enabled = false,
        preventMovement = false,
        coupleToWarnings = false,
        location = nil,
        iconSize = 24,
        showFood = true,
        showAP = true,
        showXP = true,
    }
end

function CO.GetSettingsControls()
    return {}  -- no settings; merged into CompositionWarnings
end
