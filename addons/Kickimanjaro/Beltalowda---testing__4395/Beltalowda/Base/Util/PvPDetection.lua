-- Beltalowda PvP Zone Detection
-- Detects whether the player is in a PvP zone (Cyrodiil, Imperial City, Battlegrounds)
--
-- Uses four ESO API functions that ZOS actively maintains in their own UI code:
--   IsPlayerInAvAWorld()     — broadest check: player is on an AvA server/campaign
--   IsInCyrodiil()           — Cyrodiil overland, delves, Cheesemonger's Hollow
--   IsInImperialCity()       — IC districts and sewers
--   IsActiveWorldBattleground() — all Battleground instances
--
-- Note: IsInAvAZone() is intentionally omitted. ZOS documents it but never uses
-- it in their own UI code, suggesting it may have a stale or incomplete definition
-- of which zones qualify as "AvA". The four functions above cover all known PvP
-- zones reliably as of 2026.

Beltalowda = Beltalowda or {}
Beltalowda.Util = Beltalowda.Util or {}
Beltalowda.Util.PvPDetection = Beltalowda.Util.PvPDetection or {}

local PvP = Beltalowda.Util.PvPDetection

-- Cached state: updated on every zone transition (EVENT_PLAYER_ACTIVATED)
PvP.isInPvPZone = false

--[[
    Check if the player is currently in any PvP zone.
    Returns true for Cyrodiil (all campaigns, delves, Cheesemonger's),
    Imperial City (all campaigns, sewers), and Battlegrounds.

    @return boolean
]]--
function PvP.IsInPvPZone()
    if IsPlayerInAvAWorld() == true then
        return true
    end
    if IsInCyrodiil() == true then
        return true
    end
    if IsInImperialCity() == true then
        return true
    end
    if IsActiveWorldBattleground() == true then
        return true
    end
    return false
end

--[[
    Update the cached PvP zone state.
    Called on EVENT_PLAYER_ACTIVATED (zone transitions).
]]--
function PvP.Update()
    PvP.isInPvPZone = PvP.IsInPvPZone()
end

--[[
    Get the cached PvP zone state.
    This is the fast path — use this in visibility checks and update loops.

    @return boolean
]]--
function PvP.GetCachedState()
    return PvP.isInPvPZone
end
