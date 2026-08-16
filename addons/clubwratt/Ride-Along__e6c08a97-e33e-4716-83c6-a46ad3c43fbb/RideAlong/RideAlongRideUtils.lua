-- RideAlongRideUtils.lua: Pure checks for whether the reticle target is a
-- group member whose multi-rider mount we can join right now.

local RideAlongRideUtils = {}

---Unit tag the base game uses for player-to-player interactions
---(playertoplayer.lua). It has a more generous hitbox than "reticleover" but
---no meaningful range cutoff, so range is enforced separately below.
local P2P_UNIT_TAG = "reticleoverplayer"

---Max distance (squared, world units = cm) at which the ride prompt shows.
---8m: standing beside a large multi-rider mount, the rider's position can be
---several meters away in 3D (mounts are tall), so this needs some slack over
---the ~5m of a typical world interactable.
local RIDE_RANGE_SQ = 800 * 800

---Cache of the last name-to-group-tag resolution so the steady case (staring
---at the same rider) revalidates with one C call instead of rescanning.
local cachedRawName = nil
local cachedGroupTag = nil

---Find the group unit tag for the unit under the reticle.
---GetUnitWorldPosition only returns real data for "player" and group unit
---tags (reticle tags yield garbage), so the range check below needs the tag.
---Matching uses AreUnitsEqual rather than comparing raw names, which sidesteps
---any name-decoration differences between reticle and group tags.
---@param rawName string Cache key (name currently under the reticle)
---@return string|nil
local function GetGroupUnitTagForName(rawName)
    -- Group reshuffles can reassign tags, so the cache is verified, not trusted.
    if rawName == cachedRawName and cachedGroupTag and AreUnitsEqual(P2P_UNIT_TAG, cachedGroupTag) then
        return cachedGroupTag
    end
    for i = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(i)
        if unitTag and AreUnitsEqual(P2P_UNIT_TAG, unitTag) then
            cachedRawName = rawName
            cachedGroupTag = unitTag
            return unitTag
        end
    end
    return nil
end

---Whether the target group member is close enough to actually mount.
---Squared 3D distance from integer world positions: two C calls and pure
---arithmetic, no allocations.
---@param groupTag string
---@return boolean
local function IsRideTargetInRange(groupTag)
    local playerZoneId, playerX, playerY, playerZ = GetUnitWorldPosition("player")
    local targetZoneId, targetX, targetY, targetZ = GetUnitWorldPosition(groupTag)
    -- If the platform reports no world data for either unit (zone 0), fall back
    -- to the game's own group support range check instead of never showing.
    if playerZoneId == 0 or targetZoneId == 0 then
        return IsUnitInGroupSupportRange(groupTag)
    end
    if playerZoneId ~= targetZoneId then
        return false
    end
    local dx = targetX - playerX
    local dy = targetY - playerY
    local dz = targetZ - playerZ
    return dx * dx + dy * dy + dz * dz <= RIDE_RANGE_SQ
end

---Resolve the reticle target to a ridable group mount owner.
---Mirrors the criteria the base game uses for the player-to-player
---"Ride Mount" wheel option (playertoplayer.lua), plus a free-seat check
---since we only ever mount (never dismount) from the reticle prompt.
---@return string|nil rawCharacterName Decorated character name suitable for UseMountAsPassenger, or nil if there is nothing to ride
function RideAlongRideUtils.GetRideTargetName()
    if IsMounted() then
        return nil
    end
    -- Mounting is blocked in combat, so the prompt would be a lie.
    if IsUnitInCombat("player") then
        return nil
    end
    if not DoesUnitExist(P2P_UNIT_TAG) then
        return nil
    end

    local rawName = GetRawUnitName(P2P_UNIT_TAG)
    if rawName == "" then
        return nil
    end
    -- Riding is only possible within a group; without this the prompt would
    -- show for strangers and the server would just reject the request.
    if not IsPlayerInGroup(rawName) then
        return nil
    end

    local groupTag = GetGroupUnitTagForName(rawName)
    if not groupTag or not IsRideTargetInRange(groupTag) then
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
