local ADDON_NAME = "SprintWeaponSensitivityFix"
local UPDATE_NAME = ADDON_NAME .. "_Update"
local SAVED_VARS_NAME = ADDON_NAME .. "SavedVars"
local SAVED_VARS_VERSION = 4

-- This is not a preference "speed boost"; it is the inverse compensation for
-- ESO's built-in weapon-out sprint camera slowdown so sprinting keeps the same
-- feel as normal gameplay.
local ESO_WEAPON_SPRINT_LOOK_SCALE = 5 / 9
local SPRINT_COMPENSATION_MULTIPLIER = 1 / ESO_WEAPON_SPRINT_LOOK_SCALE
local FORCE_EQUAL_SPRINT_SENSITIVITY_DEFAULT = false
local LOCK_DYNAMIC_FOV_DEFAULT = true
local UPDATE_MS = 50
local DODGE_SUPPRESSION_MS = 750
local MIN_SENSITIVITY = 0.01
local MAX_SENSITIVITY = 3.00
local EPSILON = 0.00001
local DYNAMIC_FOV_CVAR = "FOVChangesAllowed"
local ROLL_DODGE_ABILITY_ID = 28549
local ROLL_DODGE_IMMUNITY_EFFECT_NAME = "Immobilize Immunity"

local boosted = false
local baseFirstPerson = nil
local baseThirdPerson = nil
local baseCVars = {}
local savedVars = nil
local dodgeSuppressedUntil = 0
local Restore = nil

local DEFAULT_SAVED_VARS = {
    forceEqualSprintSensitivity = FORCE_EQUAL_SPRINT_SENSITIVITY_DEFAULT,
    lockDynamicFov = LOCK_DYNAMIC_FOV_DEFAULT,
    lastNormal = {
        cvars = {},
    },
    recovery = {
        active = false,
        cvars = {},
    },
}

local AXIS_CVARS = {
    "MouseSensitivityFirstPerson",
    "MouseSensitivityFirstPersonX",
    "MouseSensitivityFirstPersonY",
    "MouseSensitivityThirdPerson",
    "MouseSensitivityThirdPersonX",
    "MouseSensitivityThirdPersonY",
}

local function EnsureSavedVars()
    if not savedVars then
        savedVars = DEFAULT_SAVED_VARS
    end

    if savedVars.forceEqualSprintSensitivity == nil then
        savedVars.forceEqualSprintSensitivity = FORCE_EQUAL_SPRINT_SENSITIVITY_DEFAULT
    end

    if savedVars.lockDynamicFov == nil then
        savedVars.lockDynamicFov = LOCK_DYNAMIC_FOV_DEFAULT
    end

    savedVars.lastNormal = savedVars.lastNormal or {}
    savedVars.lastNormal.cvars = savedVars.lastNormal.cvars or {}
    savedVars.recovery = savedVars.recovery or {}
    savedVars.recovery.cvars = savedVars.recovery.cvars or {}
end

local function IsForceEqualSprintSensitivityEnabled()
    EnsureSavedVars()
    return savedVars.forceEqualSprintSensitivity ~= false
end

local function IsDynamicFovLockEnabled()
    EnsureSavedVars()
    return savedVars.lockDynamicFov ~= false
end

local function IsCameraControlActive()
    if IsGameCameraUIModeActive then
        return not IsGameCameraUIModeActive()
    end

    if SCENE_MANAGER and SCENE_MANAGER.IsInUIMode then
        return not SCENE_MANAGER:IsInUIMode()
    end

    return true
end

local function AreWeaponsOut()
    if ArePlayerWeaponsSheathed then
        return not ArePlayerWeaponsSheathed()
    end

    return true
end

local function IsPlayerAbleToSprint()
    if IsUnitDeadOrReincarnating and IsUnitDeadOrReincarnating("player") then
        return false
    end

    if IsUnitSwimming and IsUnitSwimming("player") then
        return false
    end

    if IsUnitFalling and IsUnitFalling("player") then
        return false
    end

    if IsMounted and IsMounted() then
        return false
    end

    if GetUnitPower and POWERTYPE_STAMINA then
        local stamina = GetUnitPower("player", POWERTYPE_STAMINA)

        if stamina and stamina <= 0 then
            return false
        end
    end

    return true
end

local function IsPlayerTryingToSprint()
    if not IsShiftKeyDown() then
        return false
    end

    if IsPlayerTryingToMove then
        return IsPlayerTryingToMove()
    end

    if IsPlayerMoving then
        return IsPlayerMoving()
    end

    return true
end

local function GetNowMs()
    if GetGameTimeMilliseconds then
        return GetGameTimeMilliseconds()
    end

    return 0
end

local function SuppressForDodge()
    dodgeSuppressedUntil = GetNowMs() + DODGE_SUPPRESSION_MS

    if boosted and Restore then
        Restore()
    end
end

local function IsDodgeSuppressed()
    if GetNowMs() < dodgeSuppressedUntil then
        return true
    end

    if GetAllyUnitBlockState and GetAllyUnitBlockState("player") == 4 then
        SuppressForDodge()
        return true
    end

    return false
end

local function ShouldCompensateSprint()
    if not IsCameraControlActive() then
        return false
    end

    if IsDodgeSuppressed() then
        return false
    end

    if not AreWeaponsOut() then
        return false
    end

    if not IsPlayerAbleToSprint() then
        return false
    end

    return IsPlayerTryingToSprint()
end

local function Clamp(value, minimum, maximum)
    if value < minimum then
        return minimum
    end

    if value > maximum then
        return maximum
    end

    return value
end

local function FormatNumber(value)
    local numeric = tonumber(value)

    if not numeric then
        return value
    end

    return string.format("%.8f", numeric)
end

local function ValuesMatch(left, right)
    local leftNumber = tonumber(left)
    local rightNumber = tonumber(right)

    if leftNumber and rightNumber then
        return math.abs(leftNumber - rightNumber) <= EPSILON
    end

    return tostring(left) == tostring(right)
end

local function CompensateValue(value)
    local numeric = tonumber(value)

    if not numeric then
        return value
    end

    return FormatNumber(Clamp(numeric * SPRINT_COMPENSATION_MULTIPLIER, MIN_SENSITIVITY, MAX_SENSITIVITY))
end

local function ReadCameraSetting(settingId)
    return GetSetting(SETTING_TYPE_CAMERA, settingId)
end

local function WriteCameraSetting(settingId, value)
    if value ~= nil and not ValuesMatch(ReadCameraSetting(settingId), value) then
        SetSetting(SETTING_TYPE_CAMERA, settingId, tostring(value))
    end
end

local function SafeGetCVar(name)
    if not GetCVar then
        return nil
    end

    local ok, value = pcall(GetCVar, name)

    if not ok or value == nil or value == "" then
        return nil
    end

    return value
end

local function SafeSetCVar(name, value)
    if not SetCVar or value == nil then
        return
    end

    if ValuesMatch(SafeGetCVar(name), value) then
        return
    end

    pcall(SetCVar, name, tostring(value))
end

local function ApplyDynamicFovLock()
    if not IsDynamicFovLockEnabled() then
        return
    end

    EnsureSavedVars()

    if savedVars.dynamicFovBeforeLock == nil then
        savedVars.dynamicFovBeforeLock = SafeGetCVar(DYNAMIC_FOV_CVAR) or "1"
    end

    SafeSetCVar(DYNAMIC_FOV_CVAR, "0")
end

local function RestoreDynamicFov()
    EnsureSavedVars()
    SafeSetCVar(DYNAMIC_FOV_CVAR, savedVars.dynamicFovBeforeLock or "1")
    savedVars.dynamicFovBeforeLock = nil
end

local function CopyCVars(source)
    local copy = {}

    if source then
        for _, cvarName in ipairs(AXIS_CVARS) do
            copy[cvarName] = source[cvarName]
        end
    end

    return copy
end

local function SnapshotCurrentValues()
    local snapshot = {
        firstPerson = ReadCameraSetting(CAMERA_SETTING_SENSITIVITY_FIRST_PERSON),
        thirdPerson = ReadCameraSetting(CAMERA_SETTING_SENSITIVITY_THIRD_PERSON),
        cvars = {},
    }

    for _, cvarName in ipairs(AXIS_CVARS) do
        snapshot.cvars[cvarName] = SafeGetCVar(cvarName)
    end

    return snapshot
end

local function CaptureBaseValues()
    local snapshot = SnapshotCurrentValues()

    baseFirstPerson = snapshot.firstPerson
    baseThirdPerson = snapshot.thirdPerson
    baseCVars = CopyCVars(snapshot.cvars)
end

local function GetAxisFallback(cvarName, snapshot)
    if string.find(cvarName, "FirstPerson") then
        return snapshot.firstPerson
    end

    return snapshot.thirdPerson
end

local function GetEqualCameraBase(snapshot)
    return snapshot.thirdPerson or snapshot.firstPerson
end

local function GetEqualMouseBase(snapshot)
    local cvars = snapshot.cvars or {}

    return cvars.MouseSensitivityThirdPerson
        or cvars.MouseSensitivityFirstPerson
        or cvars.MouseSensitivityThirdPersonX
        or cvars.MouseSensitivityThirdPersonY
        or cvars.MouseSensitivityFirstPersonX
        or cvars.MouseSensitivityFirstPersonY
        or snapshot.thirdPerson
        or snapshot.firstPerson
end

local function GetCompensatedCameraValue(snapshot, settingId)
    if IsForceEqualSprintSensitivityEnabled() then
        return CompensateValue(GetEqualCameraBase(snapshot))
    end

    if settingId == CAMERA_SETTING_SENSITIVITY_FIRST_PERSON then
        return CompensateValue(snapshot.firstPerson)
    end

    return CompensateValue(snapshot.thirdPerson)
end

local function GetCompensatedCVarValue(snapshot, cvarName)
    if IsForceEqualSprintSensitivityEnabled() then
        return CompensateValue(GetEqualMouseBase(snapshot))
    end

    return CompensateValue((snapshot.cvars or {})[cvarName] or GetAxisFallback(cvarName, snapshot))
end

local function BuildBaseSnapshot()
    return {
        firstPerson = baseFirstPerson,
        thirdPerson = baseThirdPerson,
        cvars = CopyCVars(baseCVars),
    }
end

local function RememberLastNormalValues()
    EnsureSavedVars()
    savedVars.lastNormal.firstPerson = baseFirstPerson
    savedVars.lastNormal.thirdPerson = baseThirdPerson
    savedVars.lastNormal.cvars = CopyCVars(baseCVars)
end

local function MarkRecoveryActive()
    EnsureSavedVars()
    savedVars.recovery.active = true
    savedVars.recovery.firstPerson = baseFirstPerson
    savedVars.recovery.thirdPerson = baseThirdPerson
    savedVars.recovery.cvars = CopyCVars(baseCVars)
    RememberLastNormalValues()
end

local function ClearRecovery()
    EnsureSavedVars()
    savedVars.recovery.active = false
    savedVars.recovery.firstPerson = nil
    savedVars.recovery.thirdPerson = nil
    savedVars.recovery.cvars = {}
end

local function RestoreSnapshot(snapshot)
    if not snapshot then
        return
    end

    if snapshot.firstPerson then
        WriteCameraSetting(CAMERA_SETTING_SENSITIVITY_FIRST_PERSON, snapshot.firstPerson)
    end

    if snapshot.thirdPerson then
        WriteCameraSetting(CAMERA_SETTING_SENSITIVITY_THIRD_PERSON, snapshot.thirdPerson)
    end

    for _, cvarName in ipairs(AXIS_CVARS) do
        local baseValue = (snapshot.cvars or {})[cvarName]

        if baseValue then
            SafeSetCVar(cvarName, baseValue)
        else
            SafeSetCVar(cvarName, FormatNumber(GetAxisFallback(cvarName, snapshot)))
        end
    end
end

local function SnapshotLooksCompensated(currentSnapshot, normalSnapshot)
    if not normalSnapshot or not normalSnapshot.firstPerson or not normalSnapshot.thirdPerson then
        return false
    end

    if not ValuesMatch(
        currentSnapshot.firstPerson,
        GetCompensatedCameraValue(normalSnapshot, CAMERA_SETTING_SENSITIVITY_FIRST_PERSON)
    ) then
        return false
    end

    if not ValuesMatch(
        currentSnapshot.thirdPerson,
        GetCompensatedCameraValue(normalSnapshot, CAMERA_SETTING_SENSITIVITY_THIRD_PERSON)
    ) then
        return false
    end

    for _, cvarName in ipairs(AXIS_CVARS) do
        local currentValue = (currentSnapshot.cvars or {})[cvarName]
        local expectedValue = GetCompensatedCVarValue(normalSnapshot, cvarName)

        if currentValue and expectedValue and not ValuesMatch(currentValue, expectedValue) then
            return false
        end
    end

    return true
end

local function ApplyCompensatedValues()
    local snapshot = BuildBaseSnapshot()

    WriteCameraSetting(
        CAMERA_SETTING_SENSITIVITY_FIRST_PERSON,
        GetCompensatedCameraValue(snapshot, CAMERA_SETTING_SENSITIVITY_FIRST_PERSON)
    )
    WriteCameraSetting(
        CAMERA_SETTING_SENSITIVITY_THIRD_PERSON,
        GetCompensatedCameraValue(snapshot, CAMERA_SETTING_SENSITIVITY_THIRD_PERSON)
    )

    for _, cvarName in ipairs(AXIS_CVARS) do
        SafeSetCVar(cvarName, GetCompensatedCVarValue(snapshot, cvarName))
    end
end

local function ApplySprintCompensation()
    if not boosted then
        CaptureBaseValues()
        MarkRecoveryActive()
        boosted = true
    end

    ApplyCompensatedValues()
end

function Restore()
    if not boosted then
        return
    end

    RestoreSnapshot(BuildBaseSnapshot())

    baseFirstPerson = nil
    baseThirdPerson = nil
    baseCVars = {}
    boosted = false
    ClearRecovery()
end

local function RefreshNormalBaseline()
    if boosted or not IsCameraControlActive() then
        return
    end

    CaptureBaseValues()
    RememberLastNormalValues()
end

local function RecoverPersistedSensitivity()
    EnsureSavedVars()

    if savedVars.recovery.active then
        RestoreSnapshot(savedVars.recovery)
        ClearRecovery()
        RefreshNormalBaseline()
        return
    end

    if SnapshotLooksCompensated(SnapshotCurrentValues(), savedVars.lastNormal) then
        RestoreSnapshot(savedVars.lastNormal)
        RefreshNormalBaseline()
    end
end

local function OnUpdate()
    ApplyDynamicFovLock()

    if ShouldCompensateSprint() then
        ApplySprintCompensation()
    else
        Restore()
        RefreshNormalBaseline()
    end
end

local function OnImmediateStateChanged()
    OnUpdate()
end

local function OnRollDodgeCombatEvent(...)
    local targetName = select(9, ...)
    local abilityId = select(17, ...)

    if abilityId ~= ROLL_DODGE_ABILITY_ID then
        return
    end

    if GetRawUnitName and targetName ~= GetRawUnitName("player") then
        return
    end

    SuppressForDodge()
end

local function OnRollDodgeEffect(_, _, _, effectName, unitTag, beginTime)
    if unitTag ~= "player" or effectName ~= ROLL_DODGE_IMMUNITY_EFFECT_NAME or beginTime == 0 then
        return
    end

    SuppressForDodge()
end

local function RegisterEventIfExists(eventCode, callback)
    if eventCode then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME, eventCode, callback)
    end
end

local function AddFilterIfExists(eventCode, filterType, filterValue)
    if eventCode and filterType then
        EVENT_MANAGER:AddFilterForEvent(ADDON_NAME, eventCode, filterType, filterValue)
    end
end

local function PrintStatus(message)
    if d then
        d("|cAF4FFFSprint Weapon Sensitivity Fix:|r " .. message)
    end
end

local function RegisterSlashCommands()
    if not SLASH_COMMANDS then
        return
    end

    SLASH_COMMANDS["/swsequal"] = function(argument)
        local value = string.lower(argument or "")

        EnsureSavedVars()

        if value == "on" or value == "1" or value == "true" then
            savedVars.forceEqualSprintSensitivity = true
            PrintStatus("force-equal sprint sensitivity is on.")
        elseif value == "off" or value == "0" or value == "false" then
            savedVars.forceEqualSprintSensitivity = false
            PrintStatus("force-equal sprint sensitivity is off.")
        else
            local state = IsForceEqualSprintSensitivityEnabled() and "on" or "off"
            PrintStatus("force-equal sprint sensitivity is " .. state .. ". Use /swsequal on or /swsequal off.")
            return
        end

        if boosted then
            Restore()
        end

        OnUpdate()
    end

    SLASH_COMMANDS["/swsfov"] = function(argument)
        local value = string.lower(argument or "")

        EnsureSavedVars()

        if value == "on" or value == "1" or value == "true" then
            savedVars.lockDynamicFov = true
            ApplyDynamicFovLock()
            PrintStatus("dynamic FOV lock is on.")
        elseif value == "off" or value == "0" or value == "false" then
            savedVars.lockDynamicFov = false
            RestoreDynamicFov()
            PrintStatus("dynamic FOV lock is off.")
        else
            local state = IsDynamicFovLockEnabled() and "on" or "off"
            PrintStatus("dynamic FOV lock is " .. state .. ". Use /swsfov on or /swsfov off.")
        end
    end
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end

    if ZO_SavedVars then
        savedVars = ZO_SavedVars:NewAccountWide(SAVED_VARS_NAME, SAVED_VARS_VERSION, nil, DEFAULT_SAVED_VARS)
    end

    EnsureSavedVars()
    RecoverPersistedSensitivity()
    RegisterSlashCommands()
    ApplyDynamicFovLock()

    EVENT_MANAGER:RegisterForUpdate(UPDATE_NAME, UPDATE_MS, OnUpdate)

    RegisterEventIfExists(EVENT_PLAYER_DEACTIVATED, Restore)
    RegisterEventIfExists(EVENT_PLAYER_DEAD, Restore)
    RegisterEventIfExists(EVENT_MOUNTED_STATE_CHANGED, OnImmediateStateChanged)
    RegisterEventIfExists(EVENT_PLAYER_SWIMMING, OnImmediateStateChanged)
    RegisterEventIfExists(EVENT_PLAYER_NOT_SWIMMING, OnImmediateStateChanged)
    RegisterEventIfExists(EVENT_RETICLE_HIDDEN_UPDATE, OnImmediateStateChanged)
    RegisterEventIfExists(EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, OnImmediateStateChanged)
    RegisterEventIfExists(EVENT_COMBAT_EVENT, OnRollDodgeCombatEvent)
    RegisterEventIfExists(EVENT_EFFECT_CHANGED, OnRollDodgeEffect)

    AddFilterIfExists(EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, ROLL_DODGE_ABILITY_ID)
    AddFilterIfExists(EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
