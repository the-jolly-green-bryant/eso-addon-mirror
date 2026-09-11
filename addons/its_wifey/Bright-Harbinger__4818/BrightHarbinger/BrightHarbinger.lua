local ADDON_NAME = "BrightHarbinger"

local reminderControl
local reminderLabel
local savedVars

----------------------------------------------------
-- DAWN'S WRATH SKILLS
----------------------------------------------------

local triggerSkills = {
    ["Sun Fire"] = 21726,
    ["Vampire's Bane"] = 21729,
    ["Reflective Light"] = 21732,

    ["Solar Flare"] = 22057,
    ["Dark Flare"] = 22110,
    ["Solar Barrage"] = 22095,

    ["Backlash"] = 21761,
    ["Power of the Light"] = 21763,
    ["Purifying Light"] = 21765,

    ["Eclipse"] = 21776,
    ["Living Dark"] = 22006,
    ["Unstable Core"] = 22004,

    ["Radiant Destruction"] = 63029,
    ["Radiant Glory"] = 63044,
    ["Radiant Oppression"] = 63046,
}

local triggerChoices = {
    "Sun Fire",
    "Vampire's Bane",
    "Reflective Light",

    "Solar Flare",
    "Dark Flare",
    "Solar Barrage",

    "Backlash",
    "Power of the Light",
    "Purifying Light",

    "Eclipse",
    "Living Dark",
    "Unstable Core",

    "Radiant Destruction",
    "Radiant Glory",
    "Radiant Oppression",
}

----------------------------------------------------
-- DEFAULTS
----------------------------------------------------

local defaults = {
    enabled = true,
    combatOnly = true,

    triggerSkill = "Vampire's Bane",
    reminderSeconds = 18,

    x = 0,
    y = -180,
    unlocked = false,

    reminderText = "VAMPIRE'S BANE!",
    fontSize = 32,

    colorR = 1,
    colorG = 0.2,
    colorB = 0.2,

    soundEnabled = false,
}

----------------------------------------------------
-- APPEARANCE
----------------------------------------------------

local function UpdateReminderAppearance()
    if not reminderLabel then
        return
    end

    reminderLabel:SetText(savedVars.reminderText)

    reminderLabel:SetFont(
        "$(BOLD_FONT)|"
        .. tostring(savedVars.fontSize)
        .. "|soft-shadow-thick"
    )

    reminderLabel:SetColor(
        savedVars.colorR,
        savedVars.colorG,
        savedVars.colorB,
        1
    )
end

----------------------------------------------------
-- POSITION
----------------------------------------------------

local function SavePosition()
    if not reminderControl then
        return
    end

    savedVars.x = reminderControl:GetLeft()
    savedVars.y = reminderControl:GetTop()
end

----------------------------------------------------
-- SHOW / HIDE
----------------------------------------------------

local function HideReminder()
    if reminderControl then
        reminderControl:SetHidden(true)
    end
end

local function ShowReminder()
    if not savedVars.enabled then
        return
    end

    UpdateReminderAppearance()
    reminderControl:SetHidden(false)

    if savedVars.soundEnabled then
        PlaySound("Campaign_Ready_Check")
    end
end

----------------------------------------------------
-- TIMER
----------------------------------------------------

local function StopReminderTimer()
    EVENT_MANAGER:UnregisterForUpdate(
        ADDON_NAME .. "Timer"
    )
end

local function StartReminderTimer()
    StopReminderTimer()

    local delay =
        savedVars.reminderSeconds * 1000

    EVENT_MANAGER:RegisterForUpdate(
        ADDON_NAME .. "Timer",
        delay,

        function()
            StopReminderTimer()

            if not savedVars.enabled then
                return
            end

            if savedVars.combatOnly
                and not IsUnitInCombat("player")
            then
                return
            end

            ShowReminder()
        end
    )
end

----------------------------------------------------
-- ABILITY DETECTION
----------------------------------------------------

local function OnAbilityUsed(eventCode, slotNum)
    if not savedVars.enabled then
        return
    end

    local abilityId =
        GetSlotBoundId(slotNum)

    local selectedId =
        triggerSkills[savedVars.triggerSkill]

    if not selectedId then
        return
    end

    if abilityId == selectedId then
        HideReminder()
        StartReminderTimer()
    end
end

----------------------------------------------------
-- COMBAT
----------------------------------------------------

local function OnCombatStateChanged(
    eventCode,
    inCombat
)
    if savedVars.combatOnly
        and not inCombat
    then
        StopReminderTimer()

        if not savedVars.unlocked then
            HideReminder()
        end
    end
end

----------------------------------------------------
-- POSITION CONTROLS
----------------------------------------------------

local function UnlockReminder()
    savedVars.unlocked = true

    reminderControl:SetMouseEnabled(true)
    reminderControl:SetMovable(true)

    UpdateReminderAppearance()
    reminderControl:SetHidden(false)
end

local function LockReminder()
    savedVars.unlocked = false

    SavePosition()

    reminderControl:SetMouseEnabled(false)
    reminderControl:SetMovable(false)
    reminderControl:SetHidden(true)
end

local function ResetPosition()
    savedVars.x = 0
    savedVars.y = -180

    reminderControl:ClearAnchors()

    reminderControl:SetAnchor(
        CENTER,
        GuiRoot,
        CENTER,
        0,
        -180
    )

    SavePosition()
end

----------------------------------------------------
-- TEST
----------------------------------------------------

local function TestReminder()
    ShowReminder()

    zo_callLater(
        function()
            if not savedVars.unlocked then
                HideReminder()
            end
        end,
        3000
    )
end

----------------------------------------------------
-- CREATE REMINDER
----------------------------------------------------

local function CreateReminder()

    reminderControl =
        WINDOW_MANAGER:CreateTopLevelWindow(
            "BrightHarbingerReminder"
        )

    reminderControl:SetDimensions(900, 150)
    reminderControl:ClearAnchors()

    if savedVars.x ~= 0
        or savedVars.y ~= -180
    then

        reminderControl:SetAnchor(
            TOPLEFT,
            GuiRoot,
            TOPLEFT,
            savedVars.x,
            savedVars.y
        )

    else

        reminderControl:SetAnchor(
            CENTER,
            GuiRoot,
            CENTER,
            0,
            -180
        )

    end

    reminderControl:SetMouseEnabled(
        savedVars.unlocked
    )

    reminderControl:SetMovable(
        savedVars.unlocked
    )

    reminderControl:SetHidden(
        not savedVars.unlocked
    )

    reminderLabel =
        WINDOW_MANAGER:CreateControl(
            "BrightHarbingerReminderLabel",
            reminderControl,
            CT_LABEL
        )

    reminderLabel:SetAnchor(
        CENTER,
        reminderControl,
        CENTER,
        0,
        0
    )

    reminderLabel:SetHorizontalAlignment(
        TEXT_ALIGN_CENTER
    )

    reminderLabel:SetVerticalAlignment(
        TEXT_ALIGN_CENTER
    )

    UpdateReminderAppearance()

    reminderControl:SetHandler(
        "OnMoveStop",

        function()
            SavePosition()
        end
    )
end

----------------------------------------------------
-- SETTINGS
----------------------------------------------------

local function CreateSettingsMenu()

    local LAM = LibAddonMenu2

    if not LAM then
        d(
            "Bright Harbinger: "
            .. "LibAddonMenu-2.0 was not found."
        )
        return
    end

    local panelName =
        "BrightHarbingerSettings"

    local panelData = {
        type = "panel",
        name = "Bright Harbinger",
        displayName = "Bright Harbinger",
        author = "WifeyRytic",
        version = "1.5",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    LAM:RegisterAddonPanel(
        panelName,
        panelData
    )

    local optionsData = {

        {
            type = "header",
            name = "Buff Tracking",
        },

        {
            type = "checkbox",
            name = "Enable Addon",

            getFunc = function()
                return savedVars.enabled
            end,

            setFunc = function(value)
                savedVars.enabled = value

                if not value then
                    StopReminderTimer()
                    HideReminder()
                end
            end,

            default = defaults.enabled,
        },

        {
            type = "checkbox",
            name = "Combat Only",

            getFunc = function()
                return savedVars.combatOnly
            end,

            setFunc = function(value)
                savedVars.combatOnly = value

                if value
                    and not IsUnitInCombat("player")
                then
                    StopReminderTimer()
                    HideReminder()
                end
            end,

            default = defaults.combatOnly,
        },

        {
            type = "header",
            name = "Trigger Skill",
        },

        {
            type = "dropdown",

            name = "Dawn's Wrath Skill",

            tooltip =
                "Choose the Dawn's Wrath ability "
                .. "you use to refresh Bright Harbinger.",

            choices = triggerChoices,

            getFunc = function()
                return savedVars.triggerSkill
            end,

            setFunc = function(value)

                savedVars.triggerSkill = value

                savedVars.reminderText =
                    string.upper(value) .. "!"

                UpdateReminderAppearance()
                StopReminderTimer()
                HideReminder()
            end,

            default = defaults.triggerSkill,
        },

        {
            type = "slider",

            name = "Reminder Time",

            tooltip =
                "Bright Harbinger lasts 20 seconds. "
                .. "18 seconds gives you about "
                .. "2 seconds to refresh it.",

            min = 10,
            max = 19,
            step = 1,

            getFunc = function()
                return savedVars.reminderSeconds
            end,

            setFunc = function(value)
                savedVars.reminderSeconds = value
            end,

            default = defaults.reminderSeconds,
        },

        {
            type = "description",

            text =
                "Using 18 seconds is recommended. "
                .. "Bright Harbinger lasts 20 seconds, "
                .. "so the reminder appears about "
                .. "2 seconds before it expires.",
        },

        {
            type = "header",
            name = "Reminder Appearance",
        },

        {
            type = "editbox",

            name = "Reminder Text",

            tooltip =
                "The text shown when it is time "
                .. "to refresh Bright Harbinger.",

            getFunc = function()
                return savedVars.reminderText
            end,

            setFunc = function(value)
                savedVars.reminderText = value
                UpdateReminderAppearance()
            end,

            default = defaults.reminderText,
        },

        {
            type = "slider",

            name = "Text Size",

            min = 20,
            max = 60,
            step = 1,

            getFunc = function()
                return savedVars.fontSize
            end,

            setFunc = function(value)
                savedVars.fontSize = value
                UpdateReminderAppearance()
            end,

            default = defaults.fontSize,
        },

        {
            type = "colorpicker",

            name = "Text Color",

            getFunc = function()

                return
                    savedVars.colorR,
                    savedVars.colorG,
                    savedVars.colorB,
                    1
            end,

            setFunc = function(r, g, b, a)

                savedVars.colorR = r
                savedVars.colorG = g
                savedVars.colorB = b

                UpdateReminderAppearance()
            end,

            default = {
                defaults.colorR,
                defaults.colorG,
                defaults.colorB,
                1
            },
        },

        {
            type = "checkbox",

            name = "Warning Sound",

            getFunc = function()
                return savedVars.soundEnabled
            end,

            setFunc = function(value)
                savedVars.soundEnabled = value
            end,

            default = defaults.soundEnabled,
        },

        {
            type = "header",
            name = "Reminder Position",
        },

        {
            type = "button",
            name = "Unlock Reminder",

            func = function()
                UnlockReminder()
            end,
        },

        {
            type = "button",
            name = "Lock Reminder",

            func = function()
                LockReminder()
            end,
        },

        {
            type = "button",
            name = "Reset Position",

            func = function()
                ResetPosition()
            end,
        },

        {
            type = "button",
            name = "Test Reminder",

            func = function()
                TestReminder()
            end,
        },
    }

    LAM:RegisterOptionControls(
        panelName,
        optionsData
    )
end

----------------------------------------------------
-- LOAD
----------------------------------------------------

local function OnAddOnLoaded(
    eventCode,
    addonName
)

    if addonName ~= ADDON_NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(
        ADDON_NAME,
        EVENT_ADD_ON_LOADED
    )

    savedVars =
        ZO_SavedVars:NewAccountWide(
            "BrightHarbingerSavedVariables",
            2,
            nil,
            defaults
        )

    ------------------------------------------------
    -- MIGRATE OLD NUMERIC TRIGGER SETTING
    ------------------------------------------------

    if savedVars.triggerAbilityId then

        for skillName, abilityId
            in pairs(triggerSkills)
        do

            if abilityId
                == savedVars.triggerAbilityId
            then

                savedVars.triggerSkill =
                    skillName

                break
            end
        end

        savedVars.triggerAbilityId = nil
    end

    ------------------------------------------------
    -- MAKE SURE SAVED SKILL IS VALID
    ------------------------------------------------

    if not triggerSkills[savedVars.triggerSkill] then
        savedVars.triggerSkill =
            defaults.triggerSkill
    end

    CreateReminder()
    CreateSettingsMenu()

    EVENT_MANAGER:RegisterForEvent(
        ADDON_NAME .. "AbilityUsed",
        EVENT_ACTION_SLOT_ABILITY_USED,
        OnAbilityUsed
    )

    EVENT_MANAGER:RegisterForEvent(
        ADDON_NAME .. "CombatState",
        EVENT_PLAYER_COMBAT_STATE,
        OnCombatStateChanged
    )

    SLASH_COMMANDS["/bhunlock"] =
        UnlockReminder

    SLASH_COMMANDS["/bhlock"] =
        LockReminder
end

EVENT_MANAGER:RegisterForEvent(
    ADDON_NAME,
    EVENT_ADD_ON_LOADED,
    OnAddOnLoaded
)