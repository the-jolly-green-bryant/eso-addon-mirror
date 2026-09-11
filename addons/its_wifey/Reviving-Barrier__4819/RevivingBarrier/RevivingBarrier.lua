local ADDON_NAME = "RevivingBarrier"

local REVIVING_BARRIER_ID = 40237

local reminderControl
local reminderLabel
local savedVars

local trackingActive = false
local readyShown = false

----------------------------------------------------
-- DEFAULTS
----------------------------------------------------

local defaults = {
    enabled = true,
    combatOnly = true,

    ultimateRequired = 240,

    x = 0,
    y = -180,
    unlocked = false,

    reminderText = "REVIVING BARRIER READY!",
    fontSize = 32,

    colorR = 1,
    colorG = 0.85,
    colorB = 0.1,

    soundEnabled = true,
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
-- ULTIMATE CHECK
----------------------------------------------------

local function CheckUltimate()
    if not savedVars.enabled then
        return
    end

    if not trackingActive then
        return
    end

    if savedVars.combatOnly
        and not IsUnitInCombat("player")
    then
        return
    end

    local currentUltimate =
        GetUnitPower(
            "player",
            POWERTYPE_ULTIMATE
        )

    ------------------------------------------------
    -- BELOW REQUIRED ULTIMATE
    ------------------------------------------------

    if currentUltimate < savedVars.ultimateRequired then

        if readyShown then
            readyShown = false
            HideReminder()
        end

        return
    end

    ------------------------------------------------
    -- ULTIMATE IS READY
    ------------------------------------------------

    if not readyShown then
        readyShown = true
        ShowReminder()
    end
end

----------------------------------------------------
-- REVIVING BARRIER CAST
----------------------------------------------------

local function OnAbilityUsed(eventCode, slotNum)
    if not savedVars.enabled then
        return
    end

    local abilityId =
        GetSlotBoundId(slotNum)

    if abilityId == REVIVING_BARRIER_ID then

        trackingActive = true
        readyShown = false

        HideReminder()

        zo_callLater(
            function()
                CheckUltimate()
            end,
            100
        )
    end
end

----------------------------------------------------
-- ULTIMATE POWER CHANGED
----------------------------------------------------

local function OnPowerUpdate(
    eventCode,
    unitTag,
    powerIndex,
    powerType,
    powerValue,
    powerMax,
    powerEffectiveMax
)

    if unitTag ~= "player" then
        return
    end

    if powerType ~= POWERTYPE_ULTIMATE then
        return
    end

    CheckUltimate()
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

        trackingActive = false
        readyShown = false

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
            "RevivingBarrierReminder"
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
            "RevivingBarrierReminderLabel",
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
            "Reviving Barrier: "
            .. "LibAddonMenu-2.0 was not found."
        )
        return
    end

    local panelName =
        "RevivingBarrierSettings"

    local panelData = {
        type = "panel",
        name = "Reviving Barrier",
        displayName = "Reviving Barrier",
        author = "WifeyRytic",
        version = "1.2",
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
            name = "Barrier Tracking",
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
                    trackingActive = false
                    readyShown = false
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

                    trackingActive = false
                    readyShown = false
                    HideReminder()
                end
            end,

            default = defaults.combatOnly,
        },

        {
            type = "slider",

            name = "Ultimate Required",

            tooltip =
                "The amount of Ultimate required "
                .. "before the reminder appears.",

            min = 1,
            max = 500,
            step = 1,

            getFunc = function()
                return savedVars.ultimateRequired
            end,

            setFunc = function(value)
                savedVars.ultimateRequired = value
                CheckUltimate()
            end,

            default = defaults.ultimateRequired,
        },

        {
            type = "header",
            name = "Reminder Appearance",
        },

        {
            type = "editbox",

            name = "Reminder Text",

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
            "RevivingBarrierSavedVariables",
            1,
            nil,
            defaults
        )

    CreateReminder()
    CreateSettingsMenu()

    EVENT_MANAGER:RegisterForEvent(
        ADDON_NAME .. "AbilityUsed",
        EVENT_ACTION_SLOT_ABILITY_USED,
        OnAbilityUsed
    )

    EVENT_MANAGER:RegisterForEvent(
        ADDON_NAME .. "PowerUpdate",
        EVENT_POWER_UPDATE,
        OnPowerUpdate
    )

    EVENT_MANAGER:AddFilterForEvent(
        ADDON_NAME .. "PowerUpdate",
        EVENT_POWER_UPDATE,
        REGISTER_FILTER_UNIT_TAG,
        "player"
    )

    EVENT_MANAGER:RegisterForEvent(
        ADDON_NAME .. "CombatState",
        EVENT_PLAYER_COMBAT_STATE,
        OnCombatStateChanged
    )

    SLASH_COMMANDS["/rbunlock"] =
        UnlockReminder

    SLASH_COMMANDS["/rblock"] =
        LockReminder
end

EVENT_MANAGER:RegisterForEvent(
    ADDON_NAME,
    EVENT_ADD_ON_LOADED,
    OnAddOnLoaded
)