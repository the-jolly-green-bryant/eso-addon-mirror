local ADDON_NAME = "WifeyRyticMagmaTracker"

local savedVars

local defaults = {
    barWidth = 350,
    barHeight = 32,

    barOffsetX = 0,
    barOffsetY = -150,

    countdownOffsetX = 0,
    countdownOffsetY = -60,

    countdownSize = 72,

    countdownColor = {
        r = 1,
        g = 0.82,
        b = 0,
        a = 1,
    },

    unlocked = false,
}

local magmaActive = false
local magmaEndTime = 0

local tracker
local bar
local barLabel

local countdownTracker
local countdownLabel

local testMode = false
local testEndTime = 0


------------------------------------------------------------
-- POSITION SAVING
------------------------------------------------------------

local function SaveBarPosition()
    if not tracker then
        return
    end

    local centerX, centerY = tracker:GetCenter()
    local rootX, rootY = GuiRoot:GetCenter()

    savedVars.barOffsetX = centerX - rootX
    savedVars.barOffsetY = centerY - rootY
end


local function SaveCountdownPosition()
    if not countdownTracker then
        return
    end

    local centerX, centerY = countdownTracker:GetCenter()
    local rootX, rootY = GuiRoot:GetCenter()

    savedVars.countdownOffsetX = centerX - rootX
    savedVars.countdownOffsetY = centerY - rootY
end


------------------------------------------------------------
-- COUNTDOWN APPEARANCE
------------------------------------------------------------

local function ApplyCountdownSettings()
    if not countdownLabel then
        return
    end

    countdownLabel:SetFont(
        string.format(
            "$(BOLD_FONT)|%d|soft-shadow-thick",
            savedVars.countdownSize
        )
    )

    local color = savedVars.countdownColor

    countdownLabel:SetColor(
        color.r,
        color.g,
        color.b,
        color.a
    )
end


------------------------------------------------------------
-- UNLOCK / LOCK
------------------------------------------------------------

local function SetUnlocked(unlocked)
    savedVars.unlocked = unlocked

    tracker:SetMovable(unlocked)
    tracker:SetMouseEnabled(unlocked)

    bar:SetMouseEnabled(unlocked)
    barLabel:SetMouseEnabled(unlocked)

    countdownTracker:SetMovable(unlocked)
    countdownTracker:SetMouseEnabled(unlocked)
    countdownLabel:SetMouseEnabled(unlocked)

    if unlocked then
        tracker:SetHidden(false)
        countdownTracker:SetHidden(false)

        barLabel:SetText("MAGMA SHELL")

        countdownLabel:SetText("5")

        d("WifeyRytic Magma Tracker unlocked.")
    else
        SaveBarPosition()
        SaveCountdownPosition()

        d("WifeyRytic Magma Tracker locked.")
    end
end


------------------------------------------------------------
-- RESET POSITIONS
------------------------------------------------------------

local function ResetPositions()
    savedVars.barOffsetX = 0
    savedVars.barOffsetY = -150

    savedVars.countdownOffsetX = 0
    savedVars.countdownOffsetY = -60

    tracker:ClearAnchors()

    tracker:SetAnchor(
        CENTER,
        GuiRoot,
        CENTER,
        savedVars.barOffsetX,
        savedVars.barOffsetY
    )

    countdownTracker:ClearAnchors()

    countdownTracker:SetAnchor(
        CENTER,
        GuiRoot,
        CENTER,
        savedVars.countdownOffsetX,
        savedVars.countdownOffsetY
    )
end


------------------------------------------------------------
-- CREATE BAR
------------------------------------------------------------

local function CreateTracker()
    tracker =
        WINDOW_MANAGER:CreateTopLevelWindow(
            "WifeyRyticMagmaTrackerWindow"
        )

    tracker:SetDimensions(
        savedVars.barWidth,
        savedVars.barHeight
    )

    tracker:SetAnchor(
        CENTER,
        GuiRoot,
        CENTER,
        savedVars.barOffsetX,
        savedVars.barOffsetY
    )

    tracker:SetMovable(false)
    tracker:SetMouseEnabled(false)
    tracker:SetClampedToScreen(true)
    tracker:SetHidden(true)

    bar =
        WINDOW_MANAGER:CreateControl(
            "WifeyRyticMagmaTrackerBar",
            tracker,
            CT_STATUSBAR
        )

    bar:SetAnchorFill(tracker)

    bar:SetMinMax(0, 1)
    bar:SetValue(1)

    bar:SetColor(
        0.85,
        0.35,
        0.05,
        0.95
    )

    bar:SetMouseEnabled(false)

    barLabel =
        WINDOW_MANAGER:CreateControl(
            "WifeyRyticMagmaTrackerBarLabel",
            tracker,
            CT_LABEL
        )

    barLabel:SetAnchorFill(tracker)

    barLabel:SetFont(
        "$(BOLD_FONT)|20|soft-shadow-thick"
    )

    barLabel:SetHorizontalAlignment(
        TEXT_ALIGN_CENTER
    )

    barLabel:SetVerticalAlignment(
        TEXT_ALIGN_CENTER
    )

    barLabel:SetText("MAGMA SHELL")

    barLabel:SetMouseEnabled(false)


    --------------------------------------------------------
    -- DRAG BAR
    --------------------------------------------------------

    local function StartBarMove(button)
        if button ~= MOUSE_BUTTON_INDEX_LEFT then
            return
        end

        if not savedVars.unlocked then
            return
        end

        tracker:StartMoving()
    end


    local function StopBarMove(button)
        if button ~= MOUSE_BUTTON_INDEX_LEFT then
            return
        end

        if not savedVars.unlocked then
            return
        end

        tracker:StopMovingOrResizing()

        SaveBarPosition()
    end


    tracker:SetHandler(
        "OnMouseDown",
        function(self, button)
            StartBarMove(button)
        end
    )

    tracker:SetHandler(
        "OnMouseUp",
        function(self, button)
            StopBarMove(button)
        end
    )

    bar:SetHandler(
        "OnMouseDown",
        function(self, button)
            StartBarMove(button)
        end
    )

    bar:SetHandler(
        "OnMouseUp",
        function(self, button)
            StopBarMove(button)
        end
    )

    barLabel:SetHandler(
        "OnMouseDown",
        function(self, button)
            StartBarMove(button)
        end
    )

    barLabel:SetHandler(
        "OnMouseUp",
        function(self, button)
            StopBarMove(button)
        end
    )
end


------------------------------------------------------------
-- CREATE COUNTDOWN
------------------------------------------------------------

local function CreateCountdown()
    countdownTracker =
        WINDOW_MANAGER:CreateTopLevelWindow(
            "WifeyRyticMagmaCountdownWindow"
        )

    countdownTracker:SetDimensions(
        400,
        180
    )

    countdownTracker:SetAnchor(
        CENTER,
        GuiRoot,
        CENTER,
        savedVars.countdownOffsetX,
        savedVars.countdownOffsetY
    )

    countdownTracker:SetMovable(false)
    countdownTracker:SetMouseEnabled(false)
    countdownTracker:SetClampedToScreen(true)
    countdownTracker:SetHidden(true)

    countdownLabel =
        WINDOW_MANAGER:CreateControl(
            "WifeyRyticMagmaCountdownLabel",
            countdownTracker,
            CT_LABEL
        )

    countdownLabel:SetAnchorFill(
        countdownTracker
    )

    countdownLabel:SetHorizontalAlignment(
        TEXT_ALIGN_CENTER
    )

    countdownLabel:SetVerticalAlignment(
        TEXT_ALIGN_CENTER
    )

    countdownLabel:SetMouseEnabled(false)

    ApplyCountdownSettings()


    --------------------------------------------------------
    -- DRAG COUNTDOWN
    --------------------------------------------------------

    local function StartCountdownMove(button)
        if button ~= MOUSE_BUTTON_INDEX_LEFT then
            return
        end

        if not savedVars.unlocked then
            return
        end

        countdownTracker:StartMoving()
    end


    local function StopCountdownMove(button)
        if button ~= MOUSE_BUTTON_INDEX_LEFT then
            return
        end

        if not savedVars.unlocked then
            return
        end

        countdownTracker:StopMovingOrResizing()

        SaveCountdownPosition()
    end


    countdownTracker:SetHandler(
        "OnMouseDown",
        function(self, button)
            StartCountdownMove(button)
        end
    )

    countdownTracker:SetHandler(
        "OnMouseUp",
        function(self, button)
            StopCountdownMove(button)
        end
    )

    countdownLabel:SetHandler(
        "OnMouseDown",
        function(self, button)
            StartCountdownMove(button)
        end
    )

    countdownLabel:SetHandler(
        "OnMouseUp",
        function(self, button)
            StopCountdownMove(button)
        end
    )
end


------------------------------------------------------------
-- MAGMA STATE
------------------------------------------------------------

local function StartMagma(endTime)
    magmaActive = true
    magmaEndTime = endTime

    testMode = false

    tracker:SetHidden(false)
end


local function StopMagma()
    magmaActive = false
    magmaEndTime = 0

    tracker:SetHidden(true)
    countdownTracker:SetHidden(true)
end


------------------------------------------------------------
-- EFFECT EVENT
------------------------------------------------------------

local function OnEffectChanged(
    eventCode,
    changeType,
    effectSlot,
    effectName,
    unitTag,
    beginTime,
    endTime,
    stackCount,
    iconName,
    buffType,
    effectType,
    abilityType,
    statusEffectType,
    unitName,
    unitId,
    abilityId,
    sourceType
)
    if effectName ~= "Magma Shell" then
        return
    end

    if unitTag ~= "player" then
        return
    end

    if changeType == EFFECT_RESULT_GAINED
    or changeType == EFFECT_RESULT_UPDATED then

        StartMagma(endTime)

    elseif changeType == EFFECT_RESULT_FADED then

        StopMagma()
    end
end


------------------------------------------------------------
-- UPDATE DISPLAY
------------------------------------------------------------

local function UpdateTracker()
    local now = GetFrameTimeSeconds()

    local endTime

    if testMode then
        endTime = testEndTime
    elseif magmaActive then
        endTime = magmaEndTime
    else
        if savedVars.unlocked then
            return
        end

        tracker:SetHidden(true)
        countdownTracker:SetHidden(true)

        return
    end


    local remaining = endTime - now

    if remaining <= 0 then
        if testMode then
            testMode = false

            tracker:SetHidden(true)
            countdownTracker:SetHidden(true)

            return
        end

        StopMagma()

        return
    end


    --------------------------------------------------------
    -- BAR
    --------------------------------------------------------

    tracker:SetHidden(false)

    local totalDuration = 15

    local progress =
        remaining / totalDuration

    if progress > 1 then
        progress = 1
    end

    if progress < 0 then
        progress = 0
    end

    bar:SetValue(progress)

    barLabel:SetText(
        string.format(
            "MAGMA SHELL  %.1f",
            remaining
        )
    )


    --------------------------------------------------------
    -- FINAL 5 SECOND COUNTDOWN
    --------------------------------------------------------

    if remaining <= 5 then

        countdownTracker:SetHidden(false)

        local countdown =
            math.ceil(remaining)

        if countdown < 1 then
            countdown = 1
        end

        countdownLabel:SetText(
            tostring(countdown)
        )

    else

        if not savedVars.unlocked then
            countdownTracker:SetHidden(true)
        end
    end
end


------------------------------------------------------------
-- TEST
------------------------------------------------------------

local function TestTracker()
    testMode = true

    testEndTime =
        GetFrameTimeSeconds() + 15

    tracker:SetHidden(false)

    d("Testing Magma Shell tracker.")
end


------------------------------------------------------------
-- SETTINGS
------------------------------------------------------------

local function CreateSettings()
    local LAM = LibAddonMenu2

    local panelData = {
        type = "panel",

        name =
            "WifeyRytic's Magma Shell Tracker",

        displayName =
            "WifeyRytic's Magma Shell Tracker",

        author = "WifeyRytic",

        version = "1.0",

        registerForRefresh = true,
        registerForDefaults = true,
    }

    LAM:RegisterAddonPanel(
        "WifeyRyticMagmaTrackerOptions",
        panelData
    )


    local options = {

        {
            type = "description",

            text =
                "Tracks Magma Shell duration and displays a large 5-4-3-2-1 countdown during the final five seconds.",
        },


        ----------------------------------------------------
        -- POSITION
        ----------------------------------------------------

        {
            type = "header",
            name = "Position",
        },

        {
            type = "button",

            name = "Unlock Tracker",

            func = function()
                SetUnlocked(true)
            end,
        },

        {
            type = "button",

            name = "Lock Tracker",

            func = function()
                SetUnlocked(false)
            end,
        },

        {
            type = "button",

            name = "Reset Positions",

            func = function()
                ResetPositions()
            end,
        },


        ----------------------------------------------------
        -- COUNTDOWN
        ----------------------------------------------------

        {
            type = "header",
            name = "Countdown",
        },

        {
            type = "slider",

            name = "Countdown Size",

            min = 30,
            max = 150,
            step = 2,

            getFunc = function()
                return savedVars.countdownSize
            end,

            setFunc = function(value)
                savedVars.countdownSize = value

                ApplyCountdownSettings()
            end,

            default =
                defaults.countdownSize,
        },

        {
            type = "colorpicker",

            name = "Countdown Color",

            getFunc = function()
                local c =
                    savedVars.countdownColor

                return
                    c.r,
                    c.g,
                    c.b,
                    c.a
            end,

            setFunc =
                function(r, g, b, a)

                    savedVars.countdownColor = {
                        r = r,
                        g = g,
                        b = b,
                        a = a,
                    }

                    ApplyCountdownSettings()
                end,

            default = {
                defaults.countdownColor.r,
                defaults.countdownColor.g,
                defaults.countdownColor.b,
                defaults.countdownColor.a,
            },
        },


        ----------------------------------------------------
        -- TEST
        ----------------------------------------------------

        {
            type = "header",
            name = "Testing",
        },

        {
            type = "button",

            name = "Test Magma Tracker",

            func = function()
                TestTracker()
            end,
        },
    }


    LAM:RegisterOptionControls(
        "WifeyRyticMagmaTrackerOptions",
        options
    )
end


------------------------------------------------------------
-- ADDON LOAD
------------------------------------------------------------

local function OnAddonLoaded(
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
            "WifeyRyticMagmaTrackerSavedVariables",
            1,
            nil,
            defaults
        )


    CreateTracker()
    CreateCountdown()
    CreateSettings()


    EVENT_MANAGER:RegisterForEvent(
        ADDON_NAME .. "MagmaEffect",
        EVENT_EFFECT_CHANGED,
        OnEffectChanged
    )

    EVENT_MANAGER:AddFilterForEvent(
        ADDON_NAME .. "MagmaEffect",
        EVENT_EFFECT_CHANGED,
        REGISTER_FILTER_UNIT_TAG,
        "player"
    )


    EVENT_MANAGER:RegisterForUpdate(
        ADDON_NAME .. "Update",
        50,
        UpdateTracker
    )


    SLASH_COMMANDS["/magmaunlock"] =
        function()
            SetUnlocked(true)
        end

    SLASH_COMMANDS["/magmalock"] =
        function()
            SetUnlocked(false)
        end

    SLASH_COMMANDS["/magmatest"] =
        function()
            TestTracker()
        end
end


EVENT_MANAGER:RegisterForEvent(
    ADDON_NAME,
    EVENT_ADD_ON_LOADED,
    OnAddonLoaded
)