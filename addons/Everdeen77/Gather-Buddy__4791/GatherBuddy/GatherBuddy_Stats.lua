GatherBuddy = GatherBuddy or {}

local GB = GatherBuddy

------------------------------------------------------------
-- UI REFERENCES
------------------------------------------------------------

local statsWindow
local statsWindowFragment
local statsBackground

local statsSessionTimeValue
local statsTotalValue
local statsUniqueValue
local statsItemsPerHourValue
local statsMostName
local statsMostQuantity

local statsTextControls = {}

local statsUserHidden = true
local USER_HIDDEN_REASON = "GatherBuddyStatsUserHidden"

------------------------------------------------------------
-- FONT HELPERS
------------------------------------------------------------

local function GetStatsFontSize()
    if GB.savedVariables == nil then
        return 13
    end

    local fontSize =
        tonumber(
            GB.savedVariables.statsFontSize
        ) or 13

    return math.max(
        10,
        math.min(
            20,
            math.floor(fontSize + 0.5)
        )
    )
end

local function GetStatsFont()
    return string.format(
        "$(MEDIUM_FONT)|%d|soft-shadow-thin",
        GetStatsFontSize()
    )
end

------------------------------------------------------------
-- APPLY STATS FONT SIZE
------------------------------------------------------------

function GB.ApplyStatsFontSize()
    local font =
        GetStatsFont()

    for _, control in ipairs(
        statsTextControls
    ) do
        if control then
            control:SetFont(font)
        end
    end
end

------------------------------------------------------------
-- CALCULATE SESSION STATS
------------------------------------------------------------

local function CalculateSessionStats()
    local totalQuantity = 0
    local uniqueItems = 0
    local mostGathered = nil

    for itemId, data in pairs(
        GB.sessionItems
    ) do
        totalQuantity =
            totalQuantity
            + data.quantity

        uniqueItems =
            uniqueItems + 1

        if mostGathered == nil
            or data.quantity
                > mostGathered.quantity
            or (
                data.quantity
                    == mostGathered.quantity
                and string.lower(data.name)
                    < string.lower(
                        mostGathered.name
                    )
            ) then

            mostGathered = {
                itemId = itemId,
                name = data.name,
                quantity = data.quantity,
                quality = data.quality
            }
        end
    end

    return
        totalQuantity,
        uniqueItems,
        mostGathered
end

------------------------------------------------------------
-- UPDATE STATS WINDOW
------------------------------------------------------------

function GB.UpdateStatsWindow()
    if GB.savedVariables == nil then
        return
    end

    local elapsedTime =
        GB.GetElapsedSessionTime()

    local totalQuantity,
        uniqueItems,
        mostGathered =
            CalculateSessionStats()

    local itemsPerHour = 0

    if elapsedTime > 0 then
        itemsPerHour =
            math.floor(
                (
                    totalQuantity
                    * 3600
                    / elapsedTime
                ) + 0.5
            )
    end

    if statsSessionTimeValue then
        statsSessionTimeValue:SetText(
            GB.FormatSessionTime(
                elapsedTime
            )
        )
    end

    if statsTotalValue then
        statsTotalValue:SetText(
            tostring(
                totalQuantity
            )
        )
    end

    if statsUniqueValue then
        statsUniqueValue:SetText(
            tostring(
                uniqueItems
            )
        )
    end

    if statsItemsPerHourValue then
        statsItemsPerHourValue:SetText(
            tostring(
                itemsPerHour
            )
        )
    end

    if statsMostName
        and statsMostQuantity then

        if mostGathered then
            local quality =
                mostGathered.quality
                or ITEM_QUALITY_NORMAL

            local qualityColor =
                GetItemQualityColor(
                    quality
                )

            statsMostName:SetText(
                qualityColor:Colorize(
                    mostGathered.name
                )
            )

            statsMostQuantity:SetText(
                "x"
                    .. tostring(
                        mostGathered.quantity
                    )
            )
        else
            statsMostName:SetText("-")
            statsMostQuantity:SetText("")
        end
    end
end

------------------------------------------------------------
-- BACKGROUND TRANSPARENCY
------------------------------------------------------------

function GB.ApplyStatsBackgroundTransparency()
    if statsBackground == nil
        or GB.savedVariables == nil then
        return
    end

    local transparency =
        tonumber(
            GB.savedVariables.backgroundTransparency
        ) or 64

    transparency =
        math.max(
            0,
            math.min(
                255,
                transparency
            )
        )

    local alpha =
        1
        - (
            transparency
            / 255
        )

    statsBackground:SetCenterColor(
        0,
        0,
        0,
        alpha
    )
end

------------------------------------------------------------
-- WINDOW LOCK
------------------------------------------------------------

function GB.ApplyStatsWindowLockState()
    if statsWindow == nil
        or GB.savedVariables == nil then
        return
    end

    local isLocked =
        GB.savedVariables.isLocked
        == true

    statsWindow:SetMovable(
        not isLocked
    )
end

------------------------------------------------------------
-- HUD SCENE INTEGRATION
------------------------------------------------------------

local function SetupStatsWindowSceneFragment()
    if statsWindow == nil
        or statsWindowFragment ~= nil then
        return
    end

    statsWindow:SetHidden(true)

    statsWindowFragment =
        ZO_HUDFadeSceneFragment:New(
            statsWindow
        )

    statsWindowFragment:SetHiddenForReason(
        USER_HIDDEN_REASON,
        statsUserHidden
    )

    local hudScene =
        SCENE_MANAGER:GetScene(
            "hud"
        )

    local hudUiScene =
        SCENE_MANAGER:GetScene(
            "hudui"
        )

    if hudScene then
        hudScene:AddFragment(
            statsWindowFragment
        )
    end

    if hudUiScene then
        hudUiScene:AddFragment(
            statsWindowFragment
        )
    end
end

------------------------------------------------------------
-- STATS WINDOW SHOW / HIDE
------------------------------------------------------------

local function ApplyStatsVisibility()
    if statsWindow == nil then
        return
    end

    if statsWindowFragment then
        statsWindowFragment:
            SetHiddenForReason(
                USER_HIDDEN_REASON,
                statsUserHidden
            )
    else
        statsWindow:SetHidden(
            statsUserHidden
        )
    end
end

function GB.ToggleStatsWindow()
    if statsWindow == nil then
        return
    end

    statsUserHidden =
        not statsUserHidden

    if not statsUserHidden then
        GB.UpdateStatsWindow()
    end

    ApplyStatsVisibility()
end

function GB.HideStatsWindow()
    if statsWindow == nil then
        return
    end

    statsUserHidden = true

    ApplyStatsVisibility()
end

------------------------------------------------------------
-- CREATE STATS WINDOW
------------------------------------------------------------

function GB.CreateStatsWindow()
    statsWindow =
        WINDOW_MANAGER:
            CreateTopLevelWindow(
                "GatherBuddyStatsWindow"
            )

    GB.statsWindow =
        statsWindow

    statsWindow:SetDimensions(
        280,
        190
    )

    statsWindow:SetMovable(true)
    statsWindow:SetMouseEnabled(true)
    statsWindow:SetClampedToScreen(
        true
    )

    --------------------------------------------------------
    -- SAVED POSITION
    --------------------------------------------------------

    if GB.savedVariables.statsLeft
        and GB.savedVariables.statsTop then

        statsWindow:SetAnchor(
            TOPLEFT,
            GuiRoot,
            TOPLEFT,
            GB.savedVariables.statsLeft,
            GB.savedVariables.statsTop
        )
    else
        statsWindow:SetAnchor(
            TOPLEFT,
            GB.mainWindow,
            TOPRIGHT,
            10,
            0
        )
    end

    --------------------------------------------------------
    -- BACKGROUND
    --------------------------------------------------------

    statsBackground =
        WINDOW_MANAGER:CreateControl(
            "GatherBuddyStatsBackground",
            statsWindow,
            CT_BACKDROP
        )

    statsBackground:SetAnchorFill()

    statsBackground:SetCenterColor(
        0,
        0,
        0,
        0.75
    )

    statsBackground:SetEdgeColor(
        0.4,
        0.4,
        0.4,
        1
    )

    statsBackground:SetEdgeTexture(
        "",
        1,
        1,
        1
    )

    --------------------------------------------------------
    -- TITLE BAR
    --------------------------------------------------------

    local titleBar =
        WINDOW_MANAGER:CreateControl(
            "GatherBuddyStatsTitleBar",
            statsWindow,
            CT_CONTROL
        )

    titleBar:SetAnchor(
        TOPLEFT,
        statsWindow,
        TOPLEFT,
        0,
        0
    )

    titleBar:SetDimensions(
        280,
        30
    )

    titleBar:SetMouseEnabled(true)

    titleBar:SetHandler(
        "OnMouseDown",
        function(self, button)
            if button
                == MOUSE_BUTTON_INDEX_LEFT
                and GB.savedVariables.isLocked
                    ~= true then

                statsWindow:
                    StartMoving()
            end
        end
    )

    titleBar:SetHandler(
        "OnMouseUp",
        function(self, button)
            if button
                == MOUSE_BUTTON_INDEX_LEFT then

                statsWindow:
                    StopMovingOrResizing()

                GB.savedVariables.statsLeft =
                    statsWindow:GetLeft()

                GB.savedVariables.statsTop =
                    statsWindow:GetTop()
            end
        end
    )

    --------------------------------------------------------
    -- TITLE
    --------------------------------------------------------

    local title =
        WINDOW_MANAGER:CreateControl(
            "GatherBuddyStatsTitle",
            titleBar,
            CT_LABEL
        )

    title:SetFont(
        "ZoFontWinH4"
    )

    title:SetText(
        "|c66CCFFSESSION STATS|r"
    )

    title:SetAnchor(
        LEFT,
        titleBar,
        LEFT,
        10,
        0
    )

    --------------------------------------------------------
    -- CLOSE BUTTON
    --------------------------------------------------------

    local closeButton =
        WINDOW_MANAGER:CreateControl(
            "GatherBuddyStatsClose",
            statsWindow,
            CT_BUTTON
        )

    closeButton:SetDimensions(
        24,
        24
    )

    closeButton:SetAnchor(
        TOPRIGHT,
        statsWindow,
        TOPRIGHT,
        -7,
        3
    )

    closeButton:SetFont(
        "ZoFontGame"
    )

    closeButton:SetText("X")

    closeButton:SetHandler(
        "OnClicked",
        function()
            GB.HideStatsWindow()
        end
    )

    --------------------------------------------------------
    -- HISTORY BUTTON
    --------------------------------------------------------

    local historyButton =
        WINDOW_MANAGER:CreateControl(
            "GatherBuddyHistoryButton",
            statsWindow,
            CT_BUTTON
        )

    historyButton:SetDimensions(
        62,
        24
    )

    historyButton:SetAnchor(
        TOPRIGHT,
        statsWindow,
        TOPRIGHT,
        -34,
        3
    )

    historyButton:SetFont(
        "ZoFontGameSmall"
    )

    historyButton:SetText(
        "HISTORY"
    )

    historyButton:SetHandler(
        "OnClicked",
        function()
            if GB.ToggleHistoryWindow then
                GB.ToggleHistoryWindow()
            end
        end
    )

    --------------------------------------------------------
    -- STAT ROW HELPER
    --------------------------------------------------------

    local function CreateStatRow(
        name,
        labelText,
        yPosition
    )
        local label =
            WINDOW_MANAGER:CreateControl(
                name .. "Label",
                statsWindow,
                CT_LABEL
            )

        label:SetText(
            labelText
        )

        label:SetAnchor(
            TOPLEFT,
            statsWindow,
            TOPLEFT,
            14,
            yPosition
        )

        table.insert(
            statsTextControls,
            label
        )

        local value =
            WINDOW_MANAGER:CreateControl(
                name .. "Value",
                statsWindow,
                CT_LABEL
            )

        value:SetWidth(100)

        value:SetHorizontalAlignment(
            TEXT_ALIGN_RIGHT
        )

        value:SetAnchor(
            TOPRIGHT,
            statsWindow,
            TOPRIGHT,
            -14,
            yPosition
        )

        table.insert(
            statsTextControls,
            value
        )

        return value
    end

    --------------------------------------------------------
    -- SESSION TIME
    --------------------------------------------------------

    statsSessionTimeValue =
        CreateStatRow(
            "GatherBuddyStatsSessionTime",
            "SESSION TIME:",
            38
        )

    --------------------------------------------------------
    -- TOTAL GATHERED
    --------------------------------------------------------

    statsTotalValue =
        CreateStatRow(
            "GatherBuddyStatsTotal",
            "TOTAL GATHERED:",
            58
        )

    --------------------------------------------------------
    -- UNIQUE ITEMS
    --------------------------------------------------------

    statsUniqueValue =
        CreateStatRow(
            "GatherBuddyStatsUnique",
            "UNIQUE ITEMS:",
            78
        )

    --------------------------------------------------------
    -- ITEMS / HOUR
    --------------------------------------------------------

    statsItemsPerHourValue =
        CreateStatRow(
            "GatherBuddyStatsPerHour",
            "ITEMS / HOUR:",
            98
        )

    --------------------------------------------------------
    -- MOST GATHERED TITLE
    --------------------------------------------------------

    local mostTitle =
        WINDOW_MANAGER:CreateControl(
            "GatherBuddyStatsMostTitle",
            statsWindow,
            CT_LABEL
        )

    mostTitle:SetText(
        "MOST GATHERED"
    )

    mostTitle:SetAnchor(
        TOPLEFT,
        statsWindow,
        TOPLEFT,
        14,
        127
    )

    table.insert(
        statsTextControls,
        mostTitle
    )

    --------------------------------------------------------
    -- MOST GATHERED NAME
    --------------------------------------------------------

    statsMostName =
        WINDOW_MANAGER:CreateControl(
            "GatherBuddyStatsMostName",
            statsWindow,
            CT_LABEL
        )

    statsMostName:SetWidth(
        205
    )

    statsMostName:SetAnchor(
        TOPLEFT,
        statsWindow,
        TOPLEFT,
        14,
        150
    )

    table.insert(
        statsTextControls,
        statsMostName
    )

    --------------------------------------------------------
    -- MOST GATHERED QUANTITY
    --------------------------------------------------------

    statsMostQuantity =
        WINDOW_MANAGER:CreateControl(
            "GatherBuddyStatsMostQuantity",
            statsWindow,
            CT_LABEL
        )

    statsMostQuantity:SetWidth(
        50
    )

    statsMostQuantity:
        SetHorizontalAlignment(
            TEXT_ALIGN_RIGHT
        )

    statsMostQuantity:SetAnchor(
        TOPRIGHT,
        statsWindow,
        TOPRIGHT,
        -14,
        150
    )

    table.insert(
        statsTextControls,
        statsMostQuantity
    )

    --------------------------------------------------------
    -- APPLY SAVED SETTINGS
    --------------------------------------------------------

    GB.ApplyStatsFontSize()
    GB.ApplyStatsBackgroundTransparency()
    GB.ApplyStatsWindowLockState()

    --------------------------------------------------------
    -- INITIAL UPDATE
    --------------------------------------------------------

    GB.UpdateStatsWindow()

    --------------------------------------------------------
    -- HUD SCENE INTEGRATION
    --------------------------------------------------------

    SetupStatsWindowSceneFragment()
end