HideUI = HideUI or {}

---------------------------------------------------------------------
-- Change reticle color by Kyzeragon
---------------------------------------------------------------------
local function SetReticleColor(color)
    ZO_ReticleContainerReticle:SetColor(unpack(color))
    ZO_ReticleContainerStealthIconStealthEye:SetColor(unpack(color))
end

local function OnCombatStateChanged(_, inCombat)
    if (inCombat) then
        -- Set reticle red
        SetReticleColor({1,0,0,1})
    else
        -- Set reticle white
        SetReticleColor({1,1,1,1})
    end
end

---------------------------------------------------------------------
-- Init, called from HideUI.lua
---------------------------------------------------------------------
function HideUI.InitializeReticle()
    EVENT_MANAGER:RegisterForEvent(HideUI.name .. "CombatState", EVENT_PLAYER_COMBAT_STATE, OnCombatStateChanged)

    -- Prevent the color animation
    ZO_PreHook(ZO_Reticle, "OnImpactfulHit", function()
        return true
    end)
end