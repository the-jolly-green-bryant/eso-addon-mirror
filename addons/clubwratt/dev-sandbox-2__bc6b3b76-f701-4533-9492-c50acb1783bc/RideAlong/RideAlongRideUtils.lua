-- RideAlongRideUtils.lua: Pure checks for whether the reticle target is a
-- group member whose multi-rider mount we can join right now.

local RideAlongRideUtils = {}

---Resolve the reticle target to a ridable group mount owner.
---Mirrors the criteria the base game uses for the player-to-player
---"Ride Mount" wheel option (playertoplayer.lua), plus a free-seat check
---since we only ever mount (never dismount) from the reticle prompt.
---@return string|nil rawCharacterName Decorated character name suitable for UseMountAsPassenger, or nil if there is nothing to ride
function RideAlongRideUtils.GetRideTargetName()
    if IsMounted() then
        return nil
    end
    if not IsUnitPlayer("reticleover") or IsUnitDead("reticleover") then
        return nil
    end

    local rawName = GetRawUnitName("reticleover")
    if rawName == "" then
        return nil
    end
    -- Riding is only possible within a group; without this the prompt would
    -- show for strangers and the server would just reject the request.
    if not IsPlayerInGroup(rawName) then
        return nil
    end

    local mountedState, isRidingGroupMount, hasFreePassengerSlot = GetTargetMountedStateInfo(rawName)
    if not isRidingGroupMount or not hasFreePassengerSlot then
        return nil
    end
    if mountedState ~= MOUNTED_STATE_MOUNT_RIDER and mountedState ~= MOUNTED_STATE_MOUNT_PASSENGER then
        return nil
    end

    return rawName
end

---Whether the HUD reticle is in a state where an extra interact prompt may be
---shown (game camera active, no menu, no ongoing interaction, not ground targeting).
---@return boolean
function RideAlongRideUtils.CanShowRidePrompt()
    if not IsGameCameraActive() or IsGameCameraUIModeActive() then
        return false
    end
    if GetInteractionType() ~= INTERACTION_NONE then
        return false
    end
    if IsPlayerGroundTargeting() then
        return false
    end
    return true
end

RideAlong.RideUtils = RideAlongRideUtils
