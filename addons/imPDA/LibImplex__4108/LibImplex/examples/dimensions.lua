-- Go to Summerset, Alinor Wayshrine

local PI = math.pi
local ZONE_ID = 1011

local function placeMarkers()
    if GetZoneId(GetUnitZoneIndex('player')) ~= ZONE_ID then return end

    LibImplex.Objects._3DStatic()
        :SetPosition(163365, 18355, 332300)
        :SetOrientation(PI * -0.5, PI * -0.3, 0)
        :SetDimensions(15, 1)
        :SetColor(173 / 255, 216 / 255, 230 / 255)  -- #add8e6
        :AddSystem(LibImplex.Systems.DepthBuffer)
end

do
    EVENT_MANAGER:RegisterForEvent('LIB_IMPLEX_EXAMPLES_DIMENSIONS', EVENT_PLAYER_ACTIVATED, placeMarkers)
end
