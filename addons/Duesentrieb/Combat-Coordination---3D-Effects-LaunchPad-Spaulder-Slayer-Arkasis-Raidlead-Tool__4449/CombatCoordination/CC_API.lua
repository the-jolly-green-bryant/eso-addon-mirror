local CC = CombatCoordination

----------------------------------------------------------------------------------------------------
-- MODULE VARS AND SVARS
----------------------------------------------------------------------------------------------------
CC.API = {
    Default = {},
    ---@type table|any
    SV = {},
}

----------------------------------------------------------------------------------------------------
-- API: PATH TRACKING START
----------------------------------------------------------------------------------------------------
---@param api_identifier string -- groupTag, unitName or unitDisplayName; "group1", "Sktt", "@Duesentrieb"
---@param api_durationMs number -- duration in milliseconds; 0 .. 60000
---@return boolean
function CombatCoordination.API.PathTrackingStart(api_identifier, api_durationMs)
    if not api_identifier then return false end

    local unitTag = CC.GetUnitTagFromIdentifier(api_identifier)
    if not unitTag then return false end

    local durationMs = (type(api_durationMs) == "number" and api_durationMs >= 0) and math.min(600000, api_durationMs) or 5000

    CC.PathTracking:AddTrack(unitTag, durationMs)
    return true
end

----------------------------------------------------------------------------------------------------
-- API: PATH TRACKING STOP
----------------------------------------------------------------------------------------------------
---@param api_identifier string -- groupTag, unitName or unitDisplayName; "group1", "Sktt", "@Duesentrieb"
---@return boolean
function CombatCoordination.API.PathTrackingStop(api_identifier)
    if not api_identifier then return false end

    local unitTag = CC.GetUnitTagFromIdentifier(api_identifier)
    if not unitTag then return false end

    CC.PathTracking.ActiveTracks[unitTag] = nil

    local effectId = "PathTracking_" .. tostring(unitTag)
    CC.DisplayEffect:RemoveTrackedEffect(effectId)

    if ZO_IsTableEmpty(CC.PathTracking.ActiveTracks) then
        CC.PathTracking:StopUpdateLoop()
    end

    return true
end