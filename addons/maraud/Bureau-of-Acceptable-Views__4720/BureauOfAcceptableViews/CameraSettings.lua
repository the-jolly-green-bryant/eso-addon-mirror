-- ===========================================================================
-- CameraSettings.lua
-- ---------------------------------------------------------------------------
-- Generalized access layer for the engine's camera settings.
--
-- Every camera property the game exposes (zoom distance, field of view,
-- shoulder offsets, head bob, screen shake, ...) is read and written through
-- the same string-based settings API:
--
--     SetSetting(SETTING_TYPE_CAMERA, <settingId>, <stringValue>)
--     GetSetting(SETTING_TYPE_CAMERA, <settingId>)            -> string
--
-- That API has two sharp edges, and ALL knowledge of them is intentionally
-- confined to this module so a future client change only needs one fix:
--   1. SetSetting expects the value pre-formatted to a fixed number of
--      decimals; passing a raw number is silently unreliable.
--   2. GetSetting returns a string the engine may clamp/round, so a write is
--      not guaranteed to apply. We verify by reading back within an epsilon.
--
-- The existing free-zoom logic in BureauOfAcceptableViews.lua is built on this
-- same contract; it now delegates here instead of re-implementing it.
-- ===========================================================================

local addon = BureauOfAcceptableViews
local private = addon.private

addon.CameraSettings = addon.CameraSettings or {}
local CameraSettings = addon.CameraSettings

-- Hot-path globals (mirror the caching style used in the core file)
local GetSetting    = GetSetting
local SetSetting    = SetSetting
local stringformat  = string.format
local mathabs       = math.abs
local tonumber      = tonumber
local pcall         = pcall
local type          = type

-- Logging helpers are generated in the core file and exported on private.
-- They are resolved lazily so load order between files cannot break us.
local function LogWarn(...)
    if private.LogWarn then private.LogWarn(...) end
end

local function LogError(...)
    if private.LogError then private.LogError(...) end
end

local function LogDebug(...)
    if private.LogDebug then private.LogDebug(...) end
end

-- ---------------------------------------------------------------------------
-- Setting descriptors
-- ---------------------------------------------------------------------------
-- A single source of truth describing every camera property we touch. Ranges
-- and defaults mirror the engine's own option panel (optionspanel_camera_shared
-- in esoui) for API 101050/101050. Keys are stable internal names; callers
-- never pass raw CAMERA_SETTING_* constants around.
--
-- Each descriptor holds:
--   settingId : the CAMERA_SETTING_* enum value (resolved lazily; may be nil
--               on unexpected client builds, in which case the property is
--               treated as unavailable rather than crashing).
--   decimals  : precision the settings API expects for this property.
--   min/max   : engine-enforced clamp range, used to sanitize our own writes.
--   isBool    : true for checkbox-style settings stored as 0/1.
local DESCRIPTORS = {
    distance = {
        settingId = CAMERA_SETTING_DISTANCE,
        decimals = 2, min = 0.0, max = 10.0,
    },
    thirdPersonFov = {
        settingId = CAMERA_SETTING_THIRD_PERSON_FIELD_OF_VIEW,
        decimals = 2, min = 35, max = 65,
    },
    firstPersonFov = {
        settingId = CAMERA_SETTING_FIRST_PERSON_FIELD_OF_VIEW,
        decimals = 2, min = 35, max = 65,
    },
    horizontalOffset = {
        settingId = CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_OFFSET,
        decimals = 2, min = -1.0, max = 1.0,
    },
    verticalOffset = {
        settingId = CAMERA_SETTING_THIRD_PERSON_VERTICAL_OFFSET,
        decimals = 2, min = -0.3, max = 0.5,
    },
    shoulder = {
        settingId = CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_POSITION_MULTIPLIER,
        decimals = 2, min = -1.0, max = 1.0,
    },
    headBob = {
        settingId = CAMERA_SETTING_FIRST_PERSON_HEAD_BOB,
        decimals = 2, min = 0.0, max = 1.0,
    },
    screenShake = {
        settingId = CAMERA_SETTING_SCREEN_SHAKE,
        decimals = 2, min = 0.0, max = 1.0,
    },
}

-- Default epsilon used to confirm a written value actually applied. Matches the
-- tolerance the core zoom logic has used successfully.
local VERIFY_EPSILON = 0.05

-- ---------------------------------------------------------------------------
-- Internal helpers
-- ---------------------------------------------------------------------------

-- Clamp a numeric value into the descriptor's engine-enforced range.
local function ClampToRange(descriptor, value)
    if value < descriptor.min then
        return descriptor.min
    end
    if value > descriptor.max then
        return descriptor.max
    end
    return value
end

-- Encode a numeric value into the fixed-decimal string the settings API wants.
-- Returns nil when the value is not numeric.
local function Encode(descriptor, value)
    value = tonumber(value)
    if not value then
        return nil
    end
    return stringformat("%." .. descriptor.decimals .. "f", value)
end

-- Resolve a descriptor by internal key, logging if the key is unknown.
local function GetDescriptor(key)
    local descriptor = DESCRIPTORS[key]
    if not descriptor then
        LogError("CameraSettings: unknown setting key '%s'", tostring(key))
        return nil
    end
    return descriptor
end

-- A property is available only when its CAMERA_SETTING_* constant resolved on
-- this client build. Guards against tainting/crashes on unexpected versions.
local function IsAvailable(descriptor)
    return descriptor ~= nil and descriptor.settingId ~= nil
end

-- ---------------------------------------------------------------------------
-- Public API
-- ---------------------------------------------------------------------------

-- Returns true if the named camera property exists on the current client.
function CameraSettings.IsSupported(key)
    return IsAvailable(DESCRIPTORS[key])
end

-- Read the current numeric value of a camera property.
-- Returns (value, true) on success, or (nil, false) when unavailable or the
-- engine call fails. Never throws.
function CameraSettings.Get(key)
    local descriptor = GetDescriptor(key)
    local settingId = descriptor and descriptor.settingId
    if settingId == nil then
        return nil, false
    end

    local success, rawValue = pcall(GetSetting, SETTING_TYPE_CAMERA, settingId)
    if not success then
        LogWarn("CameraSettings.Get('%s'): GetSetting failed: %s", key, tostring(rawValue))
        return nil, false
    end

    local value = tonumber(rawValue)
    if value == nil then
        return nil, false
    end

    return value, true
end

-- Write a camera property and verify the engine accepted it within epsilon.
-- The requested value is clamped to the engine range first. Returns true only
-- on a verified write; logs and returns false otherwise. Never throws.
function CameraSettings.Set(key, value, epsilon)
    local descriptor = GetDescriptor(key)
    local settingId = descriptor and descriptor.settingId
    if settingId == nil then
        return false
    end

    value = tonumber(value)
    if value == nil then
        LogWarn("CameraSettings.Set('%s'): non-numeric value", key)
        return false
    end

    value = ClampToRange(descriptor, value)
    local encoded = Encode(descriptor, value)

    local callSucceeded, setResult =
        pcall(SetSetting, SETTING_TYPE_CAMERA, settingId, encoded)
    if not callSucceeded then
        LogError("CameraSettings.Set('%s'): SetSetting failed: %s", key, tostring(setResult))
        return false
    end
    if setResult == false then
        LogWarn("CameraSettings.Set('%s'): SetSetting returned false for %s", key, encoded)
        return false
    end

    local appliedValue, hasApplied = CameraSettings.Get(key)
    if not hasApplied then
        LogWarn("CameraSettings.Set('%s'): unable to verify write of %s", key, encoded)
        return false
    end

    if mathabs(value - appliedValue) > (epsilon or VERIFY_EPSILON) then
        LogWarn("CameraSettings.Set('%s'): verify failed (requested=%.2f, applied=%.2f)",
            key, value, appliedValue)
        return false
    end

    LogDebug("CameraSettings.Set('%s'): requested=%.2f, applied=%.2f", key, value, appliedValue)
    return true
end

-- Expose the clamp range so UI/consumers can build sliders without duplicating
-- the engine limits. Returns (min, max, decimals) or nil when unsupported.
function CameraSettings.GetRange(key)
    local descriptor = DESCRIPTORS[key]
    if not IsAvailable(descriptor) then
        return nil
    end
    return descriptor.min, descriptor.max, descriptor.decimals
end
