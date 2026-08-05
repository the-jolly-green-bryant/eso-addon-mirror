local ADDON_NAME = "BossBeacon"
local ADDON_TITLE = "Boss Beacon"
local ADDON_VERSION = "1.0.1"
local SAVED_VARIABLES_NAME = "BossBeaconSavedVariables"

local VERIFY_UPDATE_NAME = ADDON_NAME .. "Verify"
local RESET_UPDATE_NAME = ADDON_NAME .. "Reset"
local LOCK_UPDATE_NAME = ADDON_NAME .. "Lock"

local MAX_BOSS_TAGS = 6
local MAX_GROUP_MEMBERS = 24
local VERIFY_DELAY_MS = 100
local LOCK_CHECK_MS = 100
local ENCOUNTER_END_GRACE_MS = 3000
local SKULL_MARKER = TARGET_MARKER_TYPE_EIGHT

local STATE_IDLE = 1
local STATE_VERIFYING = 2
local STATE_LOCKED = 3
local STATE_WAIT_FOR_LEAVE = 4

local defaults = {
    enabled = true,
}

local settings
local state = STATE_IDLE
local trackedBossTag
local trackedBossName

local function Print(message)
    d(string.format("|c66CCFFBoss Beacon|r %s", tostring(message)))
end

local function CancelTimers()
    EVENT_MANAGER:UnregisterForUpdate(VERIFY_UPDATE_NAME)
    EVENT_MANAGER:UnregisterForUpdate(RESET_UPDATE_NAME)
    EVENT_MANAGER:UnregisterForUpdate(LOCK_UPDATE_NAME)
end

local function ResetState()
    CancelTimers()
    state = STATE_IDLE
    trackedBossTag = nil
    trackedBossName = nil
end

ZO_CreateStringId("SI_BINDING_NAME_BOSSBEACON_CATEGORY", "Boss Beacon")
ZO_CreateStringId("SI_BINDING_NAME_BOSSBEACON_RESET_LOCK", "Reset BossBeacon lock")

local function IsSameTrackedBoss(unitTag)
    return trackedBossName ~= nil
        and DoesUnitExist(unitTag)
        and GetUnitName(unitTag) == trackedBossName
end

local function FindLiveTrackedBossTag()
    for index = 1, MAX_BOSS_TAGS do
        local bossTag = "boss" .. index
        if IsSameTrackedBoss(bossTag) and not IsUnitDead(bossTag) then
            return bossTag
        end
    end

    return nil
end

local function IsReticleGroupMemberOrPet()
    for index = 1, MAX_GROUP_MEMBERS do
        local groupTag = "group" .. index
        if DoesUnitExist(groupTag) and AreUnitsEqual("reticleover", groupTag) then
            return true
        end

        local petTag = groupTag .. "pet"
        if DoesUnitExist(petTag) and AreUnitsEqual("reticleover", petTag) then
            return true
        end
    end

    return false
end

local function IsReticleEligible()
    return DoesUnitExist("reticleover")
        and not IsUnitDead("reticleover")
        and not IsUnitPlayer("reticleover")
        and not AreUnitsEqual("reticleover", "player")
        and IsUnitAttackable("reticleover")
end

local function FindReticleBoss()
    if not IsReticleEligible() then
        return nil
    end

    for index = 1, MAX_BOSS_TAGS do
        local bossTag = "boss" .. index
        if DoesUnitExist(bossTag)
            and not IsUnitDead(bossTag)
            and AreUnitsEqual("reticleover", bossTag) then
            if IsReticleGroupMemberOrPet() then
                return nil
            end

            return bossTag
        end
    end

    return nil
end

local function IsTrackedBossUnderReticle()
    return trackedBossTag ~= nil
        and trackedBossName ~= nil
        and IsReticleEligible()
        and DoesUnitExist(trackedBossTag)
        and not IsUnitDead(trackedBossTag)
        and GetUnitName("reticleover") == trackedBossName
        and GetUnitName(trackedBossTag) == trackedBossName
        and AreUnitsEqual("reticleover", trackedBossTag)
        and not IsReticleGroupMemberOrPet()
end

local function HasTargetMarker(unitTag)
    return (GetUnitTargetMarkerType(unitTag) or TARGET_MARKER_TYPE_NONE) ~= TARGET_MARKER_TYPE_NONE
end

local OnReticleTargetChanged

local function ReleaseLock()
    ResetState()
    OnReticleTargetChanged()
end

local function MonitorLockedBoss()
    if not settings.enabled or state ~= STATE_LOCKED then
        EVENT_MANAGER:UnregisterForUpdate(LOCK_UPDATE_NAME)
        return
    end

    if IsSameTrackedBoss(trackedBossTag) then
        if IsUnitDead(trackedBossTag) then
            ReleaseLock()
            return
        end

        return
    end

    local liveBossTag = FindLiveTrackedBossTag()
    if liveBossTag then
        trackedBossTag = liveBossTag
    end
end

local function EnterLockedState()
    state = STATE_LOCKED
    EVENT_MANAGER:RegisterForUpdate(LOCK_UPDATE_NAME, LOCK_CHECK_MS, MonitorLockedBoss)
end

local function VerifyMarkerOwnership()
    EVENT_MANAGER:UnregisterForUpdate(VERIFY_UPDATE_NAME)

    if not settings.enabled or state ~= STATE_VERIFYING then
        return
    end

    if DoesUnitExist(trackedBossTag)
        and GetUnitName(trackedBossTag) == trackedBossName
        and GetUnitTargetMarkerType(trackedBossTag) == SKULL_MARKER then
        EnterLockedState()
        return
    end

    state = STATE_WAIT_FOR_LEAVE
end

local function TryMarkBoss(bossTag)
    trackedBossTag = bossTag
    trackedBossName = GetUnitName(bossTag)

    if not IsTrackedBossUnderReticle() then
        ResetState()
        return
    end

    if HasTargetMarker(trackedBossTag) then
        EnterLockedState()
        return
    end

    local callSucceeded, callError = pcall(AssignTargetMarkerToReticleTarget, SKULL_MARKER)
    if not callSucceeded then
        ResetState()
        Print(string.format("Could not place the boss marker: %s", tostring(callError)))
        return
    end

    state = STATE_VERIFYING
    EVENT_MANAGER:RegisterForUpdate(VERIFY_UPDATE_NAME, VERIFY_DELAY_MS, VerifyMarkerOwnership)
end

OnReticleTargetChanged = function()
    if not settings.enabled or state == STATE_LOCKED or state == STATE_VERIFYING then
        return
    end

    if state == STATE_WAIT_FOR_LEAVE then
        if IsTrackedBossUnderReticle() then
            return
        end

        state = STATE_IDLE
        trackedBossTag = nil
        trackedBossName = nil
    end

    state = STATE_IDLE
    trackedBossTag = nil
    trackedBossName = nil

    local bossTag = FindReticleBoss()
    if bossTag and not HasTargetMarker(bossTag) then
        TryMarkBoss(bossTag)
    end
end

local function ResetBossLock(showConfirmation)
    ResetState()
    OnReticleTargetChanged()

    if showConfirmation then
        Print("BossBeacon lock reset.")
    end
end

function BossBeacon_ResetLock()
    ResetBossLock(true)
end

local function IsTrackedBossConfirmedDead()
    return state == STATE_LOCKED
        and DoesUnitExist(trackedBossTag)
        and GetUnitName(trackedBossTag) == trackedBossName
        and IsUnitDead(trackedBossTag)
end

local function OnBossesChanged()
    if IsTrackedBossConfirmedDead() then
        ReleaseLock()
        return
    end

    if state == STATE_LOCKED then
        MonitorLockedBoss()
    end
end

local function ResetAfterEncounter()
    EVENT_MANAGER:UnregisterForUpdate(RESET_UPDATE_NAME)

    if state == STATE_LOCKED and not IsUnitInCombat("player") then
        ResetState()
    end
end

local function OnPlayerCombatState(_, inCombat)
    EVENT_MANAGER:UnregisterForUpdate(RESET_UPDATE_NAME)

    if state == STATE_LOCKED and not inCombat then
        EVENT_MANAGER:RegisterForUpdate(RESET_UPDATE_NAME, ENCOUNTER_END_GRACE_MS, ResetAfterEncounter)
    end
end

local function CreateSettingsPanel()
    local panelName = ADDON_NAME .. "Options"
    local panelData = {
        type = "panel",
        name = ADDON_TITLE,
        displayName = ADDON_TITLE,
        author = "@NPViral",
        version = ADDON_VERSION,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsData = {
        {
            type = "checkbox",
            name = "Enable automatic marking",
            tooltip = "Attempt to place the white skull on a detected active boss.",
            getFunc = function()
                return settings.enabled
            end,
            setFunc = function(value)
                settings.enabled = value
                ResetState()
                OnReticleTargetChanged()
            end,
            default = defaults.enabled,
            width = "full",
        },
        {
            type = "description",
            text = "Due to ESO's limitations, BossBeacon may occasionally mark a nearby player or pet.",
            width = "full",
        },
        {
            type = "button",
            name = "Reset boss lock",
            tooltip = "Resume detection if a boss encounter did not reset correctly.",
            func = function()
                ResetBossLock(false)
            end,
            width = "full",
        },
        {
            type = "button",
            name = "Feeling generous?",
            tooltip = "Donations keep the skooma flowing.",
            func = function()
                local opened = pcall(function()
                    MAIN_MENU_KEYBOARD:ShowScene("mailSend")
                    ZO_MailSendToField:SetText("@NPViral")
                    ZO_MailSendSubjectField:SetText("Skooma Fund")
                    ZO_MailSendBodyField:SetText("Thanks for Boss Beacon!")
                end)

                if not opened then
                    Print("Could not open mail automatically. Send gold manually to @NPViral.")
                end
            end,
            width = "full",
        },
    }

    LibAddonMenu2:RegisterAddonPanel(panelName, panelData)
    LibAddonMenu2:RegisterOptionControls(panelName, optionsData)
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    settings = ZO_SavedVars:NewAccountWide(SAVED_VARIABLES_NAME, 1, nil, defaults)
    CreateSettingsPanel()
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_RETICLE_TARGET_CHANGED, OnReticleTargetChanged)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_BOSSES_CHANGED, OnBossesChanged)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_COMBAT_STATE, OnPlayerCombatState)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, ResetState)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
