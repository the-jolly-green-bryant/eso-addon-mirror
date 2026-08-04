local ADDON_NAME = "BossBeacon"
local ADDON_TITLE = "Boss Beacon"
local ADDON_VERSION = "1.0.0"
local SAVED_VARIABLES_NAME = "BossBeaconSavedVariables"
local HOVER_UPDATE_NAME = ADDON_NAME .. "BossHover"
local MAX_BOSS_TAGS = 6
local REQUIRED_HOVER_MS = 250

local defaults = {
    enabled = true,
    markerType = 8,
    chatFeedback = false,
}

local markerChoices = {
    "Blue Square",
    "Gold Star",
    "Green Circle",
    "Orange Triangle",
    "Pink Moons",
    "Purple Oblivion",
    "Red Weapons",
    "White Skull",
}

local markerValues = { 1, 2, 3, 4, 5, 6, 7, 8 }
local settings

local function Print(message)
    d(string.format("|c66CCFFBoss Beacon|r %s", tostring(message)))
end

local function Feedback(message)
    if settings.chatFeedback then
        Print(message)
    end
end

local function GetUnitDisplayName(unitTag)
    return zo_strformat(SI_UNIT_NAME, GetUnitName(unitTag) or "")
end

local function FindReticleBoss()
    if not DoesUnitExist("reticleover") or IsUnitDead("reticleover") then
        return nil
    end

    for index = 1, MAX_BOSS_TAGS do
        local bossTag = "boss" .. index
        if DoesUnitExist(bossTag)
            and not IsUnitDead(bossTag)
            and AreUnitsEqual("reticleover", bossTag) then
            return bossTag
        end
    end

    return nil
end

local function StopHoverCheck()
    EVENT_MANAGER:UnregisterForUpdate(HOVER_UPDATE_NAME)
end

local function TryMarkReticleBoss()
    StopHoverCheck()

    if not settings.enabled then
        return
    end

    local bossTag = FindReticleBoss()
    if not bossTag then
        return
    end

    local bossName = GetUnitDisplayName(bossTag)
    local existingMarker = GetUnitTargetMarkerType("reticleover") or 0
    if existingMarker ~= 0 then
        Feedback(string.format("%s already has a marker, so it was left unchanged.", bossName))
        return
    end

    local callSucceeded, callError = pcall(AssignTargetMarkerToReticleTarget, settings.markerType)
    if not callSucceeded then
        Print(string.format("Could not mark %s: %s", bossName, tostring(callError)))
        return
    end

    if GetUnitTargetMarkerType("reticleover") == settings.markerType then
        Feedback(string.format("Marked %s.", bossName))
    else
        Feedback(string.format("Could not mark %s. In a group, only the leader can place markers.", bossName))
    end
end

local function OnReticleTargetChanged()
    StopHoverCheck()

    if settings.enabled and FindReticleBoss() then
        EVENT_MANAGER:RegisterForUpdate(HOVER_UPDATE_NAME, REQUIRED_HOVER_MS, TryMarkReticleBoss)
    end
end

local function ResetMarkerCheck()
    StopHoverCheck()
    OnReticleTargetChanged()
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
            name = "Automatic boss marking",
            tooltip = "Mark an active boss after you look at it briefly.",
            getFunc = function()
                return settings.enabled
            end,
            setFunc = function(value)
                settings.enabled = value
                ResetMarkerCheck()
            end,
            default = defaults.enabled,
            width = "full",
        },
        {
            type = "dropdown",
            name = "Marker",
            tooltip = "Choose the native ESO target marker used for bosses.",
            choices = markerChoices,
            choicesValues = markerValues,
            getFunc = function()
                return settings.markerType
            end,
            setFunc = function(value)
                settings.markerType = value
                ResetMarkerCheck()
            end,
            default = defaults.markerType,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Chat messages",
            tooltip = "Show a short message when a boss is marked or an existing marker is preserved.",
            getFunc = function()
                return settings.chatFeedback
            end,
            setFunc = function(value)
                settings.chatFeedback = value
            end,
            default = defaults.chatFeedback,
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
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
