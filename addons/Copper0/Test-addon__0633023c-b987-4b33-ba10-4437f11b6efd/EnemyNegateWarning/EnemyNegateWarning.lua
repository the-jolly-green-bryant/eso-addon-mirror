local ADDON_NAME = "EnemyNegateWarning"

local WARNING_DURATION_MS = 3000

local ENEMY_NEGATE_REGISTRATIONS = {
    [29824] = ADDON_NAME .. "_NegateMagic",
    [47160] = ADDON_NAME .. "_SuppressionField",
    [47168] = ADDON_NAME .. "_AbsorptionField",
    [51894] = ADDON_NAME .. "_NegateMagicGuard",
}

local RESET_UPDATE_NAME =
    ADDON_NAME .. "_ResetCheck"

local REARM_DELAY_MS = 750
local RESET_CHECK_INTERVAL_MS = 100

local warningLabel
local insideEnemyNegate = false
local lastNegateEventTime = 0
local warningSequence = 0


local function HideWarning()
    warningLabel:SetHidden(true)
end


local function ShowWarning()
    warningSequence = warningSequence + 1

    local thisWarningSequence =
        warningSequence

    warningLabel:SetHidden(false)

    zo_callLater(
        function()
            if thisWarningSequence
                == warningSequence then
                HideWarning()
            end
        end,
        WARNING_DURATION_MS
    )
end


local function CreateWarning()
    local warningWindow =
        WINDOW_MANAGER:CreateTopLevelWindow(
            "EnemyNegateWarningWindow"
        )

    warningWindow:SetDimensions(1200, 200)

    warningWindow:SetAnchor(
        CENTER,
        GuiRoot,
        CENTER,
        0,
        -180
    )

    warningWindow:SetMouseEnabled(false)
    warningWindow:SetHidden(false)

    warningLabel =
        WINDOW_MANAGER:CreateControl(
            "EnemyNegateWarningLabel",
            warningWindow,
            CT_LABEL
        )

    warningLabel:SetDimensions(1200, 200)

    warningLabel:SetAnchor(
        CENTER,
        warningWindow,
        CENTER,
        0,
        0
    )

    warningLabel:SetFont(
        "ZoFontGamepad42"
    )

    warningLabel:SetScale(1.2)
    
    warningLabel:SetColor(
        1,
        0,
        0,
        1
    )

    warningLabel:SetHorizontalAlignment(
        TEXT_ALIGN_CENTER
    )

    warningLabel:SetVerticalAlignment(
        TEXT_ALIGN_CENTER
    )

    warningLabel:SetText(
        "ENEMY NEGATE"
    )

    warningLabel:SetHidden(true)
end


local function CheckForNegateExit()
    local timeSinceLastEvent =
        GetFrameTimeMilliseconds()
        - lastNegateEventTime

    if timeSinceLastEvent
        < REARM_DELAY_MS then
        return
    end

    insideEnemyNegate = false

    EVENT_MANAGER:UnregisterForUpdate(
        RESET_UPDATE_NAME
    )
end


local function OnEnemyNegate(
    eventCode,
    result,
    isError
)
    if isError then
        return
    end

    if result ~= ACTION_RESULT_EFFECT_GAINED
        and result
            ~= ACTION_RESULT_EFFECT_GAINED_DURATION
        and result
            ~= ACTION_RESULT_SILENCED then
        return
    end

    lastNegateEventTime =
        GetFrameTimeMilliseconds()

    if insideEnemyNegate then
        return
    end

    insideEnemyNegate = true

    ShowWarning()

    EVENT_MANAGER:RegisterForUpdate(
        RESET_UPDATE_NAME,
        RESET_CHECK_INTERVAL_MS,
        CheckForNegateExit
    )
end


local function OnPlayerActivated(eventCode)
    EVENT_MANAGER:UnregisterForEvent(
        ADDON_NAME,
        EVENT_PLAYER_ACTIVATED
    )

    CreateWarning()

    SLASH_COMMANDS["/negatetest"] =
        ShowWarning

    for abilityId, registrationName
        in pairs(ENEMY_NEGATE_REGISTRATIONS) do

        EVENT_MANAGER:RegisterForEvent(
            registrationName,
            EVENT_COMBAT_EVENT,
            OnEnemyNegate
        )

        EVENT_MANAGER:AddFilterForEvent(
            registrationName,
            EVENT_COMBAT_EVENT,
            REGISTER_FILTER_ABILITY_ID,
            abilityId
        )

        EVENT_MANAGER:AddFilterForEvent(
            registrationName,
            EVENT_COMBAT_EVENT,
            REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE,
            COMBAT_UNIT_TYPE_PLAYER
        )
    end
end


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

    EVENT_MANAGER:RegisterForEvent(
        ADDON_NAME,
        EVENT_PLAYER_ACTIVATED,
        OnPlayerActivated
    )
end


EVENT_MANAGER:RegisterForEvent(
    ADDON_NAME,
    EVENT_ADD_ON_LOADED,
    OnAddOnLoaded
)