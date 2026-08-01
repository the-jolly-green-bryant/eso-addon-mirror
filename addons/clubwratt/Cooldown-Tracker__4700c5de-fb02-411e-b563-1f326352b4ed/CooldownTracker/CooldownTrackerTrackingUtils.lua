-- CooldownTrackerTrackingUtils.lua
-- Pure-ish helpers for tracking (normalization, icon safety, set-name helpers).

local CooldownTracker = _G["CooldownTracker"]

local TrackingUtils = {}
CooldownTracker.TrackingUtils = TrackingUtils

TrackingUtils.FALLBACK_ICON = "/esoui/art/icons/icon_missing.dds"
TrackingUtils.GENERIC_ABILITY_ICON = "/esoui/art/icons/ability_mage_065.dds"
TrackingUtils.EFFECT_UPDATE_TOLERANCE = 0.05
TrackingUtils.PERMANENT_DURATION_SECONDS = 999999

-- Icon modes for user configuration.
TrackingUtils.ICON_MODE = {
    AUTO = "auto",           -- Use ability icon, then set icon
    ABILITY = "ability",     -- Use GetAbilityIcon
    SET_PIECE = "set_piece", -- Use equipped set piece icon
    CUSTOM = "custom",       -- User-specified texture path
}

---@return number
function TrackingUtils.GetNow()
    return GetFrameTimeSeconds()
end

--- Estimate a sensible initial cooldown (in seconds) for a newly added tracker.
--- Uses the game's reported ability duration when available; otherwise falls back.
--- Result is rounded to whole seconds and clamped to the settings slider range.
---@param abilityId number|nil
---@param fallbackSeconds number|nil Value to use when no duration is known (default 10)
---@return number
function TrackingUtils.EstimateInitialCooldownSeconds(abilityId, fallbackSeconds)
    local fallback = tonumber(fallbackSeconds) or 10
    if type(abilityId) ~= "number" or abilityId <= 0 or not GetAbilityDuration then
        return fallback
    end

    local durationMs = GetAbilityDuration(abilityId, nil, "player")
    if type(durationMs) ~= "number" or durationMs <= 0 then
        return fallback
    end

    local seconds = math.floor(durationMs / 1000 + 0.5)
    if seconds < 1 then
        seconds = 1
    elseif seconds > 300 then
        -- Keep within the "Cooldown (seconds)" slider's configurable range.
        seconds = 300
    end
    return seconds
end

---@param sourceName string|nil
---@param sourceType number|nil
---@return boolean
function TrackingUtils.IsPlayerCombatSource(sourceName, sourceType)
    if sourceType == COMBAT_UNIT_TYPE_PLAYER
        or sourceType == COMBAT_UNIT_TYPE_PLAYER_PET
        or sourceType == COMBAT_UNIT_TYPE_PLAYER_COMPANION
    then
        return true
    end

    -- Fall back to name matching when sourceType is unreliable.
    local state = CooldownTracker and CooldownTracker.State
    local playerName = (state and state.playerName) or CooldownTracker.playerName
    if not playerName or playerName == "" or not sourceName or sourceName == "" then
        return false
    end

    local sn = zo_strlower(zo_strformat("<<t:1>>", sourceName))
    local pn = zo_strlower(playerName)
    return sn == pn
end

---@param icon string|nil
---@return boolean
function TrackingUtils.IsMissingIcon(icon)
    return not icon or icon == "" or icon == TrackingUtils.FALLBACK_ICON
end

---@param icon any
---@return boolean
function TrackingUtils.IsGenericAbilityIcon(icon)
    if type(icon) ~= "string" or icon == "" then
        return false
    end
    local lower = zo_strlower(icon)
    return string.find(lower, "ability_mage_065", 1, true) ~= nil
end

---@param icon any
---@return string|nil
function TrackingUtils.NormalizeEventIcon(icon)
    if type(icon) == "string" and icon ~= "" and icon ~= TrackingUtils.FALLBACK_ICON then
        return icon
    end
    return nil
end

---@param abilityId number|nil
---@return string|nil
function TrackingUtils.GetAbilityIconSafe(abilityId)
    if not abilityId or abilityId <= 0 or not GetAbilityIcon then
        return nil
    end
    local icon = GetAbilityIcon(abilityId)
    if TrackingUtils.IsMissingIcon(icon) then
        return nil
    end
    return icon
end

---@param setName string|nil
---@return string|nil
function TrackingUtils.NormalizeSetName(setName)
    if not setName or setName == "" then
        return nil
    end
    return zo_strlower(zo_strformat("<<t:1>>", setName))
end

---@param itemLink string|nil
---@return number
function TrackingUtils.GetSetPieceIconPriority(itemLink)
    if not itemLink or itemLink == "" then
        return 0
    end

    if GetItemLinkWeaponType then
        local weaponType = GetItemLinkWeaponType(itemLink)
        if weaponType and weaponType ~= WEAPONTYPE_NONE then
            if weaponType == WEAPONTYPE_SHIELD then
                return 3
            end
            return 2
        end
    end

    if GetItemLinkEquipType then
        local equipType = GetItemLinkEquipType(itemLink)
        if equipType == EQUIP_TYPE_MAIN_HAND
            or equipType == EQUIP_TYPE_OFF_HAND
            or equipType == EQUIP_TYPE_ONE_HAND
            or equipType == EQUIP_TYPE_TWO_HAND
        then
            return 2
        end
    end

    return 1
end

local setCollectionNameToId = {}
local setCollectionNameMapReady = false

local function EnsureSetCollectionNameMap()
    if setCollectionNameMapReady then
        return
    end
    if not GetNextItemSetCollectionId or not GetItemSetName then
        return
    end

    ZO_ClearTable(setCollectionNameToId)
    local count = 0

    local function GetNextItemSetCollectionIdIter(_, lastItemSetId)
        return GetNextItemSetCollectionId(lastItemSetId)
    end

    for itemSetId in GetNextItemSetCollectionIdIter do
        local name = GetItemSetName(itemSetId)
        local normalized = TrackingUtils.NormalizeSetName(name)
        if normalized then
            setCollectionNameToId[normalized] = itemSetId
            count = count + 1
        end
    end

    if count > 0 then
        setCollectionNameMapReady = true
    end
end

---@param setName string|nil
---@return number|nil
function TrackingUtils.GetSetCollectionIdByName(setName)
    local normalized = TrackingUtils.NormalizeSetName(setName)
    if not normalized then
        return nil
    end
    EnsureSetCollectionNameMap()
    return setCollectionNameToId[normalized]
end

---@param setId number|nil
---@return number|nil
function TrackingUtils.GetCollectionSetIdForSetId(setId)
    if not setId or setId <= 0 then
        return nil
    end
    if GetItemSetUnperfectedSetId then
        local unperfectedSetId = GetItemSetUnperfectedSetId(setId)
        if unperfectedSetId and unperfectedSetId > 0 then
            return unperfectedSetId
        end
    end
    return setId
end

return TrackingUtils

