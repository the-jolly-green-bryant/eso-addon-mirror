-------------------------------------------------------------------------------
-- Applies (or hides) the enlarged floating leader icon based on user settings
-- with minimal redundant engine calls.
-------------------------------------------------------------------------------

local EVENT_NAME = "CAC_CrownScale"

-- Optional micro-throttle: ignore rapid duplicate calls within same frame.
local _lastApplyFrame

local VALID_SIZES = {
    [64]  = true,
    [128] = true,
}

function CrownAndCrux_ApplyLeaderCrown()
    -- Basic guards
    if not CrownAndCrux or not CrownAndCrux.saved then return end

    -- If sanitation somehow not yet run, fallback safe defaults.
    local sv = CrownAndCrux.saved
    if type(sv.enlargeCrown) ~= "boolean" then sv.enlargeCrown = false end

    if not sv.enlargeCrown then
        -- Hide marker
        if CrownAndCrux._lastLeaderTex or CrownAndCrux._lastLeaderSize then
            SetFloatingMarkerInfo(MAP_PIN_TYPE_GROUP_LEADER, 0, "")
            CrownAndCrux._lastLeaderTex  = nil
            CrownAndCrux._lastLeaderSize = nil
        end
        return
    end

    -- Size validation
    local sizePx = sv.leaderCrownSize
    if type(sizePx) ~= "number" or not VALID_SIZES[sizePx] then
        sizePx = 128
        sv.leaderCrownSize = sizePx
    end

    local tex = CrownAndCrux.GetLeaderIconPath()
    if type(tex) ~= "string" or tex == "" then
        tex = "CrownAndCrux/art/large_crown.dds" -- final fallback
    end

    -- Throttle: avoid duplicate call in same frame
    local currentFrame = GetFrameTimeMilliseconds()
    if _lastApplyFrame and currentFrame == _lastApplyFrame then
        return
    end

    SetFloatingMarkerInfo(MAP_PIN_TYPE_GROUP_LEADER, sizePx, tex)
    CrownAndCrux._lastLeaderTex  = tex
    CrownAndCrux._lastLeaderSize = sizePx


    _lastApplyFrame = currentFrame
end

-------------------------------------------------------------------------------
-- Event Registration (fires after full UI activation)
-------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(EVENT_NAME, EVENT_PLAYER_ACTIVATED, CrownAndCrux_ApplyLeaderCrown)
EVENT_MANAGER:RegisterForEvent(EVENT_NAME, EVENT_GROUP_MEMBER_JOINED, CrownAndCrux_ApplyLeaderCrown)
EVENT_MANAGER:RegisterForEvent(EVENT_NAME, EVENT_GROUP_MEMBER_LEFT,   CrownAndCrux_ApplyLeaderCrown)
EVENT_MANAGER:RegisterForEvent(EVENT_NAME, EVENT_LEADER_UPDATE,       CrownAndCrux_ApplyLeaderCrown)
EVENT_MANAGER:RegisterForEvent(EVENT_NAME, EVENT_GROUP_DISBANDED,     CrownAndCrux_ApplyLeaderCrown)
EVENT_MANAGER:RegisterForEvent(EVENT_NAME, EVENT_GROUP_TYPE_CHANGED, CrownAndCrux_ApplyLeaderCrown)
