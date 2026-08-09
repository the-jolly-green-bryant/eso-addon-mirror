-- RideAlongState.lua: Pure data initialization
-- Creates the initial state structure (defaults).

local RideAlongState = {}

function RideAlongState.Create()
    ---@type RideAlongState
    return {
        savedVars = {
            enabled = true,
        },
        ridePromptTargetName = nil,
    }
end

RideAlong.State = RideAlongState
