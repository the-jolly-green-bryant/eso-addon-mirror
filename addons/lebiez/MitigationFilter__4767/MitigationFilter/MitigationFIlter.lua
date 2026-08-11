MitigationFilter = {}

MitigationFilter.name = "MitigationFilter"
MitigationFilter.version = "1.0"

-- =========================================================
-- DEFAULT SETTINGS
-- =========================================================

MitigationFilter.defaults = {

    calibration = {

        -- Resource guard reference resistance
        guardResistance = 33000,

        -- PvP damage factor
        pvpDamageFactor = 0.50,

        -- Ability ID used for calibration and measurement
        calibrationAbilityId = 16037,

        normalGuardAverage = 0,
        criticalGuardAverage = 0,

        normalPlayerReference = 0,
        criticalPlayerReference = 0,

        normalCount = 0,
        criticalCount = 0,

        isCalibrated = false,
    },

    ui = {
        offsetX = 0,
        offsetY = 250,
        hidden = false,
        unlocked = false,
    },

    debug = {
        spellIds = false,
    },
}

-- =========================================================
-- RUNTIME STATE
-- =========================================================

MitigationFilter.state = {

    calibrationPending = false,

    calibrationNormalHits = {},
    calibrationCriticalHits = {},

    lastRatio = 1.0,

    estimatedResistance = 0,
    estimatedMitigation = 0,

    lastHit = 0,
    lastAbilityId = 0,
    lastWasCritical = false,
}

-- =========================================================
-- UTILITIES
-- =========================================================

local function SafeRound(value)
    return zo_round(value or 0)
end

local function Average(values)

    if not values or #values == 0 then
        return 0
    end

    local total = 0

    for i = 1, #values do
        total = total + values[i]
    end

    return total / #values
end

local function ResistanceToMitigation(resistance)

    resistance = resistance or 0

    -- Theoretical model:
    -- 33,000 resistance = 50%
    -- 660 resistance = ~1%

    local mitigation = resistance / 660

    if mitigation < 0 then
        mitigation = 0
    end

    return mitigation
end

local function FormatMitigation(mitigation)

    mitigation = mitigation or 0

    return string.format(
        "%.1f%%",
        mitigation
    )
end

-- =========================================================
-- CHAT
-- =========================================================

function MitigationFilter:Print(message)

    d(
        "|c88CCFF[MitigationFilter]|r "
        .. tostring(message)
    )
end

-- =========================================================
-- UI
-- =========================================================

function MitigationFilter:CreateUI()

    local wm = WINDOW_MANAGER

    local window =
        wm:CreateTopLevelWindow(
            "MitigationFilterWindow"
        )

    window:SetDimensions(
        220,
        70
    )

    window:SetAnchor(
        CENTER,
        GuiRoot,
        CENTER,
        self.savedVars.ui.offsetX,
        self.savedVars.ui.offsetY
    )

    window:SetClampedToScreen(true)

    window:SetMovable(
        self.savedVars.ui.unlocked
    )

    window:SetMouseEnabled(
        self.savedVars.ui.unlocked
    )

    local label =
        wm:CreateControl(
            nil,
            window,
            CT_LABEL
        )

    label:SetAnchor(
        CENTER,
        window,
        CENTER,
        0,
        0
    )

    label:SetDimensions(
        220,
        60
    )

    label:SetFont(
        "ZoFontGameLargeBold"
    )

    label:SetHorizontalAlignment(
        TEXT_ALIGN_CENTER
    )

    label:SetVerticalAlignment(
        TEXT_ALIGN_CENTER
    )

    label:SetText("")

    window:SetHandler(
        "OnMoveStop",
        function()

            local _, _, _, x, y =
                window:GetAnchor()

            self.savedVars.ui.offsetX =
                x or 0

            self.savedVars.ui.offsetY =
                y or 250
        end
    )

    self.window = window
    self.mitigationLabel = label

    self:RefreshWindow()
end

-- =========================================================
-- WINDOW STATE
-- =========================================================

function MitigationFilter:RefreshWindow()

    if not self.window then
        return
    end

    self.window:SetMovable(
        self.savedVars.ui.unlocked
    )

    self.window:SetMouseEnabled(
        self.savedVars.ui.unlocked
    )

    local shouldHide =
        self.savedVars.ui.hidden
        or not self.savedVars.calibration.isCalibrated

    self.window:SetHidden(
        shouldHide
    )
end

-- =========================================================
-- DISPLAY MITIGATION
-- =========================================================

function MitigationFilter:DisplayMitigationFromResistance(resistance)

    if not self.mitigationLabel then
        return
    end

    resistance =
        resistance or 0

    self.state.estimatedResistance =
        resistance

    local mitigation =
        ResistanceToMitigation(
            resistance
        )

    self.state.estimatedMitigation =
        mitigation

    self.mitigationLabel:SetText(
        FormatMitigation(
            mitigation
        )
    )

    self:RefreshWindow()
end

-- =========================================================
-- DAMAGE RESULT TYPES
-- =========================================================

function MitigationFilter:IsCriticalResult(result)

    return
        result == ACTION_RESULT_CRITICAL_DAMAGE
        or result == ACTION_RESULT_CRITICAL_DAMAGE_SHIELDED
end

function MitigationFilter:IsNormalResult(result)

    return
        result == ACTION_RESULT_DAMAGE
        or result == ACTION_RESULT_DAMAGE_SHIELDED
        or result == ACTION_RESULT_BLOCKED_DAMAGE
end

function MitigationFilter:IsDamageResult(result)

    return
        self:IsNormalResult(result)
        or self:IsCriticalResult(result)
end

-- =========================================================
-- CALIBRATION ABILITY
-- =========================================================

function MitigationFilter:IsCalibrationAttack(abilityId)

    local configuredId =
        tonumber(
            self.savedVars.calibration.calibrationAbilityId
        )

    if not configuredId then
        return false
    end

    return abilityId == configuredId
end

-- =========================================================
-- REFERENCES
-- =========================================================

function MitigationFilter:GetReference(isCritical)

    local calibration =
        self.savedVars.calibration

    if isCritical then
        return
            calibration.criticalPlayerReference
            or 0
    end

    return
        calibration.normalPlayerReference
        or 0
end

-- =========================================================
-- RESISTANCE ESTIMATION
-- =========================================================

function MitigationFilter:CalculateEstimatedResistance(ratio)

    if not ratio
        or ratio <= 0 then

        return 0
    end

    -- Theoretical effective resistance model:
    --
    -- Ratio 1.00 ~= 33,000 effective resistance
    -- Ratio 2.00 ~= 0 effective resistance
    -- Ratio below 1.00 can represent >33,000 equivalent
    -- mitigation due to armor + passives + other reduction.

    local resistance =
        66000
        * (
            1
            - (ratio / 2)
        )

    if resistance < 0 then
        resistance = 0
    end

    return SafeRound(
        resistance
    )
end

-- =========================================================
-- START CALIBRATION
-- =========================================================

function MitigationFilter:StartCalibration()

    local abilityId =
        tonumber(
            self.savedVars.calibration.calibrationAbilityId
        )

    if not abilityId
        or abilityId <= 0 then

        self:Print(
            "Invalid calibration Ability ID."
        )

        return
    end

    self.state.calibrationPending =
        true

    self.state.calibrationNormalHits =
        {}

    self.state.calibrationCriticalHits =
        {}

    if self.window then
        self.window:SetHidden(true)
    end

    if self.mitigationLabel then
        self.mitigationLabel:SetText("")
    end

    self:Print(
        "Calibration started."
    )

    self:Print(
        string.format(
            "Calibration Ability ID: %d",
            abilityId
        )
    )

    self:Print(
        "Light attack a Cyrodiil resource guard until both a normal and critical hit are recorded."
    )
end

-- =========================================================
-- RESET CALIBRATION
-- =========================================================

function MitigationFilter:ResetCalibration()

    local calibration =
        self.savedVars.calibration

    calibration.normalGuardAverage =
        0

    calibration.criticalGuardAverage =
        0

    calibration.normalPlayerReference =
        0

    calibration.criticalPlayerReference =
        0

    calibration.normalCount =
        0

    calibration.criticalCount =
        0

    calibration.isCalibrated =
        false

    self.state.calibrationPending =
        false

    self.state.calibrationNormalHits =
        {}

    self.state.calibrationCriticalHits =
        {}

    self.state.lastRatio =
        1.0

    self.state.estimatedResistance =
        0

    self.state.estimatedMitigation =
        0

    self.state.lastHit =
        0

    self.state.lastAbilityId =
        0

    self.state.lastWasCritical =
        false

    if self.mitigationLabel then
        self.mitigationLabel:SetText("")
    end

    self:RefreshWindow()

    self:Print(
        "Calibration reset."
    )
end

-- =========================================================
-- CALIBRATION PROGRESS
-- =========================================================

function MitigationFilter:PrintCalibrationProgress()

    local normalCount =
        #self.state.calibrationNormalHits

    local criticalCount =
        #self.state.calibrationCriticalHits

    self:Print(
        string.format(
            "Calibration | Normal: %d | Critical: %d",
            normalCount,
            criticalCount
        )
    )

    if normalCount == 0 then

        self:Print(
            "Waiting for a normal hit..."
        )

    elseif criticalCount == 0 then

        self:Print(
            "Waiting for a critical hit..."
        )
    end
end

-- =========================================================
-- FINISH CALIBRATION
-- =========================================================

function MitigationFilter:FinishCalibration()

    local calibration =
        self.savedVars.calibration

    local normalAverage =
        Average(
            self.state.calibrationNormalHits
        )

    local criticalAverage =
        Average(
            self.state.calibrationCriticalHits
        )

    calibration.normalGuardAverage =
        SafeRound(
            normalAverage
        )

    calibration.criticalGuardAverage =
        SafeRound(
            criticalAverage
        )

    calibration.normalPlayerReference =
        SafeRound(
            normalAverage
            * calibration.pvpDamageFactor
        )

    calibration.criticalPlayerReference =
        SafeRound(
            criticalAverage
            * calibration.pvpDamageFactor
        )

    calibration.normalCount =
        #self.state.calibrationNormalHits

    calibration.criticalCount =
        #self.state.calibrationCriticalHits

    calibration.isCalibrated =
        true

    self.state.calibrationPending =
        false

    self.state.lastRatio =
        1.0

    local initialResistance =
        self:CalculateEstimatedResistance(
            1.0
        )

    self.state.estimatedResistance =
        initialResistance

    self.state.estimatedMitigation =
        ResistanceToMitigation(
            initialResistance
        )

    self:Print(
        "Calibration complete."
    )

    self:Print(
        string.format(
            "Normal reference: %d | Critical reference: %d",
            calibration.normalPlayerReference,
            calibration.criticalPlayerReference
        )
    )

    self:DisplayMitigationFromResistance(
        initialResistance
    )
end

-- =========================================================
-- HANDLE CALIBRATION HIT
-- =========================================================

function MitigationFilter:HandleCalibrationHit(
    hitValue,
    isCritical
)

    if isCritical then

        table.insert(
            self.state.calibrationCriticalHits,
            hitValue
        )

        self:Print(
            string.format(
                "Critical calibration hit: %d",
                hitValue
            )
        )

    else

        table.insert(
            self.state.calibrationNormalHits,
            hitValue
        )

        self:Print(
            string.format(
                "Normal calibration hit: %d",
                hitValue
            )
        )
    end

    self:PrintCalibrationProgress()

    if #self.state.calibrationNormalHits >= 1
        and #self.state.calibrationCriticalHits >= 1 then

        self:FinishCalibration()
    end
end

-- =========================================================
-- SPELL ID DEBUG
-- =========================================================

function MitigationFilter:DebugCombatAbility(
    abilityId,
    abilityName,
    hitValue,
    result
)

    if not self.savedVars.debug.spellIds then
        return
    end

    if not abilityId
        or abilityId <= 0 then

        return
    end

    local hitType =
        self:IsCriticalResult(result)
        and "CRIT"
        or "NORMAL"

    self:Print(
        string.format(
            "ID: %d | %s | Hit: %d | %s",
            abilityId,
            tostring(abilityName),
            hitValue or 0,
            hitType
        )
    )
end

-- =========================================================
-- COMBAT EVENT
-- =========================================================

function MitigationFilter:OnCombatEvent(
    eventCode,
    result,
    isError,
    abilityName,
    abilityGraphic,
    abilityActionSlotType,
    sourceName,
    sourceType,
    targetName,
    targetType,
    hitValue,
    powerType,
    damageType,
    log,
    sourceUnitId,
    targetUnitId,
    abilityId,
    overflow
)

    if isError then
        return
    end

    if sourceType ~= COMBAT_UNIT_TYPE_PLAYER then
        return
    end

    if not abilityId
        or abilityId <= 0 then
        return
    end

    if not hitValue
        or hitValue <= 0 then
        return
    end

    if not self:IsDamageResult(
        result
    ) then
        return
    end

    -- Debug all player damage abilities

    self:DebugCombatAbility(
        abilityId,
        abilityName,
        hitValue,
        result
    )

    -- Only selected calibration / measurement ability

    if not self:IsCalibrationAttack(
        abilityId
    ) then
        return
    end

    local isCritical =
        self:IsCriticalResult(
            result
        )

    self.state.lastHit =
        hitValue

    self.state.lastAbilityId =
        abilityId

    self.state.lastWasCritical =
        isCritical

    -- Calibration mode

    if self.state.calibrationPending then

        self:HandleCalibrationHit(
            hitValue,
            isCritical
        )

        return
    end

    if not self.savedVars.calibration.isCalibrated then
        return
    end

    -- Select matching normal/crit reference

    local reference =
        self:GetReference(
            isCritical
        )

    if not reference
        or reference <= 0 then
        return
    end

    -- Observed ratio

    local ratio =
        hitValue
        / reference

    self.state.lastRatio =
        ratio

    -- Effective theoretical resistance

    local resistance =
        self:CalculateEstimatedResistance(
            ratio
        )

    -- Convert to theoretical mitigation %

    self:DisplayMitigationFromResistance(
        resistance
    )
end

-- =========================================================
-- LIBADDONMENU
-- =========================================================

function MitigationFilter:RegisterSettingsMenu()

    local LAM =
        LibAddonMenu2

    if not LAM then

        self:Print(
            "LibAddonMenu-2.0 not found."
        )

        return
    end

    local panelData = {

        type = "panel",

        name =
            "MitigationFilter",

        displayName =
            "MitigationFilter",

        author =
            "OpenAI",

        version =
            self.version,

        registerForRefresh =
            true,

        registerForDefaults =
            true,

        slashCommand =
            "/mitigationfilter",
    }

    local options = {

        -- =================================================
        -- CALIBRATION
        -- =================================================

        {
            type = "header",

            name =
                "Calibration",

            width =
                "full",
        },

        {
            type = "description",

            text =
                "1. Enable Spell ID Debug to find the Ability ID of the attack you want to use.\n\n"
                .. "2. Enter that Ability ID below.\n\n"
                .. "3. Press Start Calibration.\n\n"
                .. "4. Hit a Cyrodiil resource guard until both a normal and critical hit are recorded.",

            width =
                "full",
        },

        {
            type = "editbox",

            name =
                "Calibration Ability ID",

            tooltip =
                "Ability ID used for calibration and mitigation measurement.",

            getFunc =
                function()

                    return tostring(
                        self.savedVars.calibration.calibrationAbilityId
                        or 0
                    )
                end,

            setFunc =
                function(value)

                    local abilityId =
                        tonumber(value)

                    if abilityId
                        and abilityId > 0 then

                        self.savedVars.calibration.calibrationAbilityId =
                            SafeRound(abilityId)

                        self:Print(
                            string.format(
                                "Calibration Ability ID set to %d.",
                                SafeRound(abilityId)
                            )
                        )

                    else

                        self:Print(
                            "Invalid Ability ID."
                        )
                    end
                end,

            isMultiline =
                false,

            width =
                "full",
        },

        {
            type = "button",

            name =
                "Start Calibration",

            tooltip =
                "Start calibration with the selected Ability ID.",

            func =
                function()
                    self:StartCalibration()
                end,

            width =
                "half",
        },

        {
            type = "button",

            name =
                "Reset Calibration",

            tooltip =
                "Delete the current calibration.",

            func =
                function()
                    self:ResetCalibration()
                end,

            width =
                "half",
        },

        {
            type = "description",

            text =
                function()

                    if self.savedVars.calibration.isCalibrated then

                        return
                            "|c55FF55Calibration READY|r"

                    elseif self.state.calibrationPending then

                        return
                            "|cFFFF55Calibration IN PROGRESS|r"
                    end

                    return
                        "|cFF5555Calibration NOT READY|r"
                end,

            width =
                "full",
        },

        -- =================================================
        -- DISPLAY
        -- =================================================

        {
            type = "header",

            name =
                "Display",

            width =
                "full",
        },

        {
            type = "checkbox",

            name =
                "Show Mitigation",

            getFunc =
                function()

                    return
                        not self.savedVars.ui.hidden
                end,

            setFunc =
                function(value)

                    self.savedVars.ui.hidden =
                        not value

                    self:RefreshWindow()
                end,

            width =
                "half",
        },

        {
            type = "checkbox",

            name =
                "Unlock Position",

            tooltip =
                "Allows moving the mitigation percentage on screen.",

            getFunc =
                function()

                    return
                        self.savedVars.ui.unlocked
                end,

            setFunc =
                function(value)

                    self.savedVars.ui.unlocked =
                        value

                    self:RefreshWindow()
                end,

            width =
                "half",
        },

        -- =================================================
        -- DEBUG
        -- =================================================

        {
            type = "header",

            name =
                "Spell ID Debug",

            width =
                "full",
        },

        {
            type = "description",

            text =
                "Enable this option and use attacks or abilities. Their Ability ID, name, damage and hit type will be printed in chat.",

            width =
                "full",
        },

        {
            type = "checkbox",

            name =
                "Show Spell IDs in Chat",

            tooltip =
                "Print your damaging Ability IDs in chat.",

            getFunc =
                function()

                    return
                        self.savedVars.debug.spellIds
                end,

            setFunc =
                function(value)

                    self.savedVars.debug.spellIds =
                        value

                    self:Print(
                        value
                        and "Spell ID Debug enabled."
                        or "Spell ID Debug disabled."
                    )
                end,

            width =
                "full",
        },
    }

    LAM:RegisterAddonPanel(
        "MitigationFilterOptions",
        panelData
    )

    LAM:RegisterOptionControls(
        "MitigationFilterOptions",
        options
    )
end

-- =========================================================
-- INITIALIZATION
-- =========================================================

function MitigationFilter:Initialize()

    self.savedVars =
        ZO_SavedVars:NewAccountWide(
            "MitigationFilterSavedVars",
            1,
            nil,
            self.defaults
        )

    self:CreateUI()

    self:RegisterSettingsMenu()

    if self.savedVars.calibration.isCalibrated then

        local initialResistance =
            self:CalculateEstimatedResistance(
                1.0
            )

        self:DisplayMitigationFromResistance(
            initialResistance
        )

    else

        self:RefreshWindow()
    end

    EVENT_MANAGER:RegisterForEvent(
        self.name,
        EVENT_COMBAT_EVENT,
        function(...)
            self:OnCombatEvent(...)
        end
    )

    SLASH_COMMANDS["/mitcal"] =
        function()
            self:StartCalibration()
        end

    SLASH_COMMANDS["/mitreset"] =
        function()
            self:ResetCalibration()
        end

    SLASH_COMMANDS["/mitdebug"] =
        function()

            self.savedVars.debug.spellIds =
                not self.savedVars.debug.spellIds

            self:Print(
                self.savedVars.debug.spellIds
                and "Spell ID Debug enabled."
                or "Spell ID Debug disabled."
            )
        end

    self:Print(
        "Addon loaded."
    )
end

-- =========================================================
-- ADDON LOADED
-- =========================================================

local function OnAddonLoaded(
    eventCode,
    addonName
)

    if addonName ~= MitigationFilter.name then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(
        MitigationFilter.name,
        EVENT_ADD_ON_LOADED
    )

    MitigationFilter:Initialize()
end

EVENT_MANAGER:RegisterForEvent(
    MitigationFilter.name,
    EVENT_ADD_ON_LOADED,
    OnAddonLoaded
)