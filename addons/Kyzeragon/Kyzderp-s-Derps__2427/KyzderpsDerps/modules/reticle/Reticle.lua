KyzderpsDerps = KyzderpsDerps or {}
KyzderpsDerps.Reticle = KyzderpsDerps.Reticle or {}
local Reticle = KyzderpsDerps.Reticle
Reticle.name = KyzderpsDerps.name .. "Reticle"

---------------------------------------------------------------------
-- Change reticle color
---------------------------------------------------------------------
local function SetReticleColor(color)
    ZO_ReticleContainerReticle:SetColor(unpack(color))
    ZO_ReticleContainerStealthIconStealthEye:SetColor(unpack(color))
end

local function OnCombatStateChanged(_, inCombat)
    if (KyzderpsDerps.savedOptions.misc.combatReticle) then
        if (inCombat) then
            SetReticleColor({1,0,0,1})
        else
            SetReticleColor({1,1,1,1})
        end
    end
end

---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
function Reticle.Initialize()
    EVENT_MANAGER:RegisterForEvent(Reticle.name .. "CombatState", EVENT_PLAYER_COMBAT_STATE, OnCombatStateChanged)

    -- Prevent the color animation
    ZO_PreHook(ZO_Reticle, "OnImpactfulHit", function()
        return KyzderpsDerps.savedOptions.misc.combatReticle
    end)
end
