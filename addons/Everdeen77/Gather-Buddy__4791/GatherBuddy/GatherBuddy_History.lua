GatherBuddy = GatherBuddy or {}

local GB = GatherBuddy

------------------------------------------------------------
-- HISTORY SETTINGS
------------------------------------------------------------

local MAX_HISTORY = 10

local WINDOW_WIDTH = 660
local WINDOW_HEIGHT = 360

local ROW_HEIGHT = 28

------------------------------------------------------------
-- UI REFERENCES
------------------------------------------------------------

local historyWindow
local historyWindowFragment
local historyBackground

local historyScrollContainer
local historyScrollChild
local historyEmptyText

local historyRows = {}
local historyHeaderControls = {}

------------------------------------------------------------
-- FONT HELPERS
------------------------------------------------------------

local function GetHistoryFontSize()
    if GB.savedVariables == nil then
        return 13
    end

    local fontSize =
        tonumber(
            GB.savedVariables.historyFontSize
        ) or 13

    return math.max(
        10,
        math.min(
            20,
            math.floor(fontSize + 0.5)
        )
    )
end

local function GetHistoryFont()
    return string.format(
        "$(MEDIUM_FONT)|%d|soft-shadow-thin",
        GetHistoryFontSize()
    )
end

------------------------------------------------------------
-- APPLY HISTORY FONT SIZE
------------------------------------------------------------

function GB.ApplyHistoryFontSize()
    local font =
        GetHistoryFont()

    --------------------------------------------------------
    -- COLUMN HEADERS
    --------------------------------------------------------

    for _, control in ipairs(
        historyHeaderControls
    ) do
        if control then
            control:SetFont(font)
        end
    end

    --------------------------------------------------------
    -- EMPTY HISTORY TEXT
    --------------------------------------------------------

    if historyEmptyText then
        historyEmptyText:SetFont(font)
    end

    --------------------------------------------------------
    -- SESSION ROWS
    --------------------------------------------------------

    for _, row in ipairs(
        historyRows
    ) do
        if row.dateLabel then
            row.dateLabel:SetFont(font)
        end

        if row.durationLabel then
            row.durationLabel:SetFont(font)
        end

        if row.totalLabel then
            row.totalLabel:SetFont(font)
        end

        if row.perHourLabel then
            row.perHourLabel:SetFont(font)
        end

        if row.mostLabel then
            row.mostLabel:SetFont(font)
        end
    end
end

------------------------------------------------------------
-- HISTORY WINDOW VISIBILITY
------------------------------------------------------------

local historyUserHidden = true
local USER_HIDDEN_REASON = "GatherBuddyHistoryUserHidden"

local function SetupHistoryWindowSceneFragment()
    if historyWindow == nil
        or historyWindowFragment ~= nil then
        return
    end

    historyWindow:SetHidden(true)

    historyWindowFragment =
        ZO_HUDFadeSceneFragment:New(
            historyWindow
        )

    historyWindowFragment:SetHiddenForReason(
        USER_HIDDEN_REASON,
        historyUserHidden
    )

    local hudScene =
        SCENE_MANAGER:GetScene("hud")

    local hudUiScene =
        SCENE_MANAGER:GetScene("hudui")

    if hudScene then
        hudScene:AddFragment(
            historyWindowFragment
        )
    end

    if hudUiScene then
        hudUiScene:AddFragment(
            historyWindowFragment
        )
    end
end

local function ApplyHistoryWindowVisibility()
    if historyWindow == nil then
        return
    end

    if historyWindowFragment then
        historyWindowFragment:SetHiddenForReason(
            USER_HIDDEN_REASON,
            historyUserHidden
        )
    else
        historyWindow:SetHidden(
            historyUserHidden
        )
    end
end

------------------------------------------------------------
-- HISTORY SAVED VARIABLES
------------------------------------------------------------

local function EnsureHistoryTable()
    if GB.savedVariables == nil then
        return false
    end

    if GB.savedVariables.sessionHistory == nil then
        GB.savedVariables.sessionHistory = {}
    end

    return true
end

function GB.InitializeHistory()
    if not EnsureHistoryTable() then
        return
    end

    if GB.savedVariables.historyLeft == nil then
        GB.savedVariables.historyLeft = nil
    end

    if GB.savedVariables.historyTop == nil then
        GB.savedVariables.historyTop = nil
    end
end

------------------------------------------------------------
-- SESSION CHECKPOINT
------------------------------------------------------------

-- This stores the last moment the session was actively running.
-- It allows us to archive a session after a full logout/login
-- without counting the offline time as part of the session.

function GB.UpdateSessionCheckpoint()
    if GB.savedVariables == nil
        or GB.savedVariables.sessionStartTime == nil then
        return
    end

    local timestamp =
        GetTimeStamp()

    GB.savedVariables.sessionLastSeenTime =
        timestamp

    GB.savedVariables.sessionLastDateText =
        GetDateStringFromTimestamp(
            timestamp
        )

    GB.savedVariables.sessionLastClockText =
        GetTimeString()
end

function GB.ResetSessionCheckpoint()
    if GB.savedVariables == nil then
        return
    end

    GB.UpdateSessionCheckpoint()
end

------------------------------------------------------------
-- BUILD SESSION SNAPSHOT
------------------------------------------------------------

local function BuildSessionSnapshot(
    useSavedCheckpoint
)
    if GB.savedVariables == nil
        or GB.sessionItems == nil then
        return nil
    end

    local totalQuantity = 0
    local uniqueItems = 0

    local mostGathered = nil
    local items = {}

    --------------------------------------------------------
    -- COPY SESSION ITEMS
    --------------------------------------------------------

    for itemId, data in pairs(
        GB.sessionItems
    ) do
        local quantity =
            tonumber(data.quantity)
            or 0

        if quantity > 0 then
            totalQuantity =
                totalQuantity
                + quantity

            uniqueItems =
                uniqueItems + 1

            table.insert(
                items,
                {
                    itemId = itemId,
                    name = data.name,
                    quantity = quantity,
                    quality = data.quality
                }
            )

            if mostGathered == nil
                or quantity > mostGathered.quantity
                or (
                    quantity == mostGathered.quantity
                    and string.lower(data.name)
                        < string.lower(
                            mostGathered.name
                        )
                ) then

                mostGathered = {
                    itemId = itemId,
                    name = data.name,
                    quantity = quantity,
                    quality = data.quality
                }
            end
        end
    end

    --------------------------------------------------------
    -- IGNORE EMPTY SESSIONS
    --------------------------------------------------------

    if totalQuantity <= 0 then
        return nil
    end

    --------------------------------------------------------
    -- SORT SAVED ITEM LIST
    --------------------------------------------------------

    table.sort(
        items,
        function(a, b)
            return
                string.lower(a.name)
                < string.lower(b.name)
        end
    )

    --------------------------------------------------------
    -- SESSION END TIME
    --------------------------------------------------------

    local endTimestamp
    local dateText
    local clockText

    if useSavedCheckpoint then
        endTimestamp =
            tonumber(
                GB.savedVariables
                    .sessionLastSeenTime
            )
            or GetTimeStamp()

        dateText =
            GB.savedVariables
                .sessionLastDateText

        clockText =
            GB.savedVariables
                .sessionLastClockText

        if dateText == nil
            or dateText == "" then

            dateText =
                GetDateStringFromTimestamp(
                    endTimestamp
                )
        end

        if clockText == nil
            or clockText == "" then

            clockText = "--:--:--"
        end
    else
        endTimestamp =
            GetTimeStamp()

        dateText =
            GetDateStringFromTimestamp(
                endTimestamp
            )

        clockText =
            GetTimeString()
    end

    --------------------------------------------------------
    -- SESSION DURATION
    --------------------------------------------------------

    local startTimestamp =
        tonumber(
            GB.savedVariables
                .sessionStartTime
        )
        or endTimestamp

    local duration =
        math.max(
            0,
            endTimestamp
                - startTimestamp
        )

    --------------------------------------------------------
    -- ITEMS PER HOUR
    --------------------------------------------------------

    local itemsPerHour = 0

    if duration > 0 then
        itemsPerHour =
            math.floor(
                (
                    totalQuantity
                    * 3600
                    / duration
                ) + 0.5
            )
    end

    --------------------------------------------------------
    -- SNAPSHOT
    --------------------------------------------------------

    return {
        endedAt = endTimestamp,

        dateText = dateText,
        clockText = clockText,

        duration = duration,

        totalQuantity = totalQuantity,
        uniqueItems = uniqueItems,
        itemsPerHour = itemsPerHour,

        mostGathered = mostGathered,

        items = items,
    }
end

------------------------------------------------------------
-- ARCHIVE SESSION
------------------------------------------------------------

function GB.ArchiveCurrentSession(
    useSavedCheckpoint
)
    if not EnsureHistoryTable() then
        return false
    end

    local snapshot =
        BuildSessionSnapshot(
            useSavedCheckpoint == true
        )

    if snapshot == nil then
        return false
    end

    table.insert(
        GB.savedVariables.sessionHistory,
        1,
        snapshot
    )

    while #GB.savedVariables.sessionHistory
        > MAX_HISTORY do

        table.remove(
            GB.savedVariables.sessionHistory
        )
    end

    if GB.UpdateHistoryWindow then
        GB.UpdateHistoryWindow()
    end

    return true
end

------------------------------------------------------------
-- BACKGROUND TRANSPARENCY
------------------------------------------------------------

function GB.ApplyHistoryBackgroundTransparency()
    if historyBackground == nil
        or GB.savedVariables == nil then
        return
    end

    local transparency =
        tonumber(
            GB.savedVariables
                .backgroundTransparency
        )
        or 64

    transparency =
        math.max(
            0,
            math.min(
                255,
                transparency
            )
        )

    local alpha =
        1 - (transparency / 255)

    historyBackground:SetCenterColor(
        0,
        0,
        0,
        alpha
    )
end

------------------------------------------------------------
-- HISTORY WINDOW LOCK
------------------------------------------------------------

function GB.ApplyHistoryWindowLockState()
    if historyWindow == nil
        or GB.savedVariables == nil then
        return
    end

    local isLocked =
        GB.savedVariables.isLocked
        == true

    historyWindow:SetMovable(
        not isLocked
    )
end

------------------------------------------------------------
-- UPDATE HISTORY WINDOW
------------------------------------------------------------

function GB.UpdateHistoryWindow()
    if historyWindow == nil
        or historyScrollChild == nil
        or GB.savedVariables == nil then
        return
    end

    EnsureHistoryTable()

    local history =
        GB.savedVariables.sessionHistory

    local font =
        GetHistoryFont()

    --------------------------------------------------------
    -- HIDE EXISTING ROWS
    --------------------------------------------------------

    for _, row in ipairs(
        historyRows
    ) do
        row:SetHidden(true)
    end

    --------------------------------------------------------
    -- EMPTY HISTORY
    --------------------------------------------------------

    if #history == 0 then
        historyEmptyText:SetFont(font)
        historyEmptyText:SetHidden(false)

        historyScrollChild:SetHeight(
            255
        )

        return
    end

    historyEmptyText:SetHidden(true)

    --------------------------------------------------------
    -- HISTORY ROWS
    --------------------------------------------------------

    for index, session in ipairs(
        history
    ) do
        local row =
            historyRows[index]

        if row == nil then
            row =
                WINDOW_MANAGER:CreateControl(
                    "GatherBuddyHistoryRow"
                        .. tostring(index),
                    historyScrollChild,
                    CT_CONTROL
                )

            row:SetDimensions(
                620,
                ROW_HEIGHT
            )

            ------------------------------------------------
            -- DATE / TIME
            ------------------------------------------------

            local dateLabel =
                WINDOW_MANAGER:CreateControl(
                    "GatherBuddyHistoryDate"
                        .. tostring(index),
                    row,
                    CT_LABEL
                )

            dateLabel:SetFont(font)

            dateLabel:SetWidth(140)

            dateLabel:SetAnchor(
                LEFT,
                row,
                LEFT,
                5,
                0
            )

            ------------------------------------------------
            -- LENGTH
            ------------------------------------------------

            local durationLabel =
                WINDOW_MANAGER:CreateControl(
                    "GatherBuddyHistoryDuration"
                        .. tostring(index),
                    row,
                    CT_LABEL
                )

            durationLabel:SetFont(font)

            durationLabel:SetWidth(85)

            durationLabel:SetHorizontalAlignment(
                TEXT_ALIGN_RIGHT
            )

            durationLabel:SetAnchor(
                LEFT,
                row,
                LEFT,
                145,
                0
            )

            ------------------------------------------------
            -- TOTAL
            ------------------------------------------------

            local totalLabel =
                WINDOW_MANAGER:CreateControl(
                    "GatherBuddyHistoryTotal"
                        .. tostring(index),
                    row,
                    CT_LABEL
                )

            totalLabel:SetFont(font)

            totalLabel:SetWidth(65)

            totalLabel:SetHorizontalAlignment(
                TEXT_ALIGN_RIGHT
            )

            totalLabel:SetAnchor(
                LEFT,
                row,
                LEFT,
                240,
                0
            )

            ------------------------------------------------
            -- ITEMS / HOUR
            ------------------------------------------------

            local perHourLabel =
                WINDOW_MANAGER:CreateControl(
                    "GatherBuddyHistoryPerHour"
                        .. tostring(index),
                    row,
                    CT_LABEL
                )

            perHourLabel:SetFont(font)

            perHourLabel:SetWidth(75)

            perHourLabel:SetHorizontalAlignment(
                TEXT_ALIGN_RIGHT
            )

            perHourLabel:SetAnchor(
                LEFT,
                row,
                LEFT,
                315,
                0
            )

            ------------------------------------------------
            -- MOST GATHERED
            ------------------------------------------------

            local mostLabel =
                WINDOW_MANAGER:CreateControl(
                    "GatherBuddyHistoryMost"
                        .. tostring(index),
                    row,
                    CT_LABEL
                )

            mostLabel:SetFont(font)

            mostLabel:SetWidth(210)

            mostLabel:SetAnchor(
                LEFT,
                row,
                LEFT,
                405,
                0
            )

            row.dateLabel =
                dateLabel

            row.durationLabel =
                durationLabel

            row.totalLabel =
                totalLabel

            row.perHourLabel =
                perHourLabel

            row.mostLabel =
                mostLabel

            historyRows[index] =
                row
        end

        ----------------------------------------------------
        -- APPLY CURRENT FONT
        ----------------------------------------------------

        row.dateLabel:SetFont(font)
        row.durationLabel:SetFont(font)
        row.totalLabel:SetFont(font)
        row.perHourLabel:SetFont(font)
        row.mostLabel:SetFont(font)

        ----------------------------------------------------
        -- POSITION
        ----------------------------------------------------

        row:ClearAnchors()

        row:SetAnchor(
            TOPLEFT,
            historyScrollChild,
            TOPLEFT,
            0,
            (index - 1)
                * ROW_HEIGHT
        )

        ----------------------------------------------------
        -- DATE / TIME
        ----------------------------------------------------

        local dateText =
            session.dateText
            or "-"

        local clockText =
            session.clockText
            or ""

        row.dateLabel:SetText(
            dateText
                .. " "
                .. clockText
        )

        ----------------------------------------------------
        -- LENGTH
        ----------------------------------------------------

        row.durationLabel:SetText(
            GB.FormatSessionTime(
                session.duration
                or 0
            )
        )

        ----------------------------------------------------
        -- TOTAL
        ----------------------------------------------------

        row.totalLabel:SetText(
            tostring(
                session.totalQuantity
                or 0
            )
        )

        ----------------------------------------------------
        -- ITEMS / HOUR
        ----------------------------------------------------

        row.perHourLabel:SetText(
            tostring(
                session.itemsPerHour
                or 0
            )
        )

        ----------------------------------------------------
        -- MOST GATHERED
        ----------------------------------------------------

        local mostGathered =
            session.mostGathered

        if mostGathered
            and mostGathered.name then

            local quality =
                mostGathered.quality
                or ITEM_QUALITY_NORMAL

            local qualityColor =
                GetItemQualityColor(
                    quality
                )

            row.mostLabel:SetText(
                qualityColor:Colorize(
                    mostGathered.name
                )
                    .. " x"
                    .. tostring(
                        mostGathered.quantity
                        or 0
                    )
            )
        else
            row.mostLabel:SetText("-")
        end

        row:SetHidden(false)
    end

    --------------------------------------------------------
    -- SCROLL CHILD HEIGHT
    --------------------------------------------------------

    local contentHeight =
        #history * ROW_HEIGHT

    historyScrollChild:SetHeight(
        math.max(
            255,
            contentHeight
        )
    )
end

------------------------------------------------------------
-- HISTORY WINDOW SHOW / HIDE
------------------------------------------------------------

function GB.ToggleHistoryWindow()
    if historyWindow == nil then
        return
    end

    historyUserHidden =
        not historyUserHidden

    if not historyUserHidden then
        GB.UpdateHistoryWindow()
    end

    ApplyHistoryWindowVisibility()
end

function GB.HideHistoryWindow()
    if historyWindow == nil then
        return
    end

    historyUserHidden = true

    ApplyHistoryWindowVisibility()
end

------------------------------------------------------------
-- CREATE HISTORY WINDOW
------------------------------------------------------------

function GB.CreateHistoryWindow()
    historyWindow =
        WINDOW_MANAGER:CreateTopLevelWindow(
            "GatherBuddyHistoryWindow"
        )

    GB.historyWindow =
        historyWindow

    historyWindow:SetDimensions(
        WINDOW_WIDTH,
        WINDOW_HEIGHT
    )

    historyWindow:SetMovable(true)
    historyWindow:SetMouseEnabled(true)
    historyWindow:SetClampedToScreen(true)

    --------------------------------------------------------
    -- SAVED POSITION
    --------------------------------------------------------

    if GB.savedVariables.historyLeft
        and GB.savedVariables.historyTop then

        historyWindow:SetAnchor(
            TOPLEFT,
            GuiRoot,
            TOPLEFT,
            GB.savedVariables.historyLeft,
            GB.savedVariables.historyTop
        )

    elseif GB.statsWindow then

        historyWindow:SetAnchor(
            TOPLEFT,
            GB.statsWindow,
            TOPRIGHT,
            10,
            0
        )

    else
        historyWindow:SetAnchor(
            CENTER,
            GuiRoot,
            CENTER,
            0,
            0
        )
    end

    --------------------------------------------------------
    -- BACKGROUND
    --------------------------------------------------------

    historyBackground =
        WINDOW_MANAGER:CreateControl(
            "GatherBuddyHistoryBackground",
            historyWindow,
            CT_BACKDROP
        )

    historyBackground:SetAnchorFill()

    historyBackground:SetCenterColor(
        0,
        0,
        0,
        0.75
    )

    historyBackground:SetEdgeColor(
        0.4,
        0.4,
        0.4,
        1
    )

    historyBackground:SetEdgeTexture(
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
            "GatherBuddyHistoryTitleBar",
            historyWindow,
            CT_CONTROL
        )

    titleBar:SetAnchor(
        TOPLEFT,
        historyWindow,
        TOPLEFT,
        0,
        0
    )

    titleBar:SetAnchor(
        TOPRIGHT,
        historyWindow,
        TOPRIGHT,
        0,
        0
    )

    titleBar:SetHeight(32)
    titleBar:SetMouseEnabled(true)

    titleBar:SetHandler(
        "OnMouseDown",
        function(self, button)
            if button == MOUSE_BUTTON_INDEX_LEFT
                and GB.savedVariables.isLocked ~= true then

                historyWindow:StartMoving()
            end
        end
    )

    titleBar:SetHandler(
        "OnMouseUp",
        function(self, button)
            if button == MOUSE_BUTTON_INDEX_LEFT then

                historyWindow:
                    StopMovingOrResizing()

                GB.savedVariables.historyLeft =
                    historyWindow:GetLeft()

                GB.savedVariables.historyTop =
                    historyWindow:GetTop()
            end
        end
    )

    --------------------------------------------------------
    -- TITLE
    --------------------------------------------------------

    local title =
        WINDOW_MANAGER:CreateControl(
            "GatherBuddyHistoryTitle",
            titleBar,
            CT_LABEL
        )

    title:SetFont(
        "ZoFontWinH4"
    )

    title:SetText(
        "|c66CCFFSESSION HISTORY|r"
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
            "GatherBuddyHistoryClose",
            historyWindow,
            CT_BUTTON
        )

    closeButton:SetDimensions(
        24,
        24
    )

    closeButton:SetAnchor(
        TOPRIGHT,
        historyWindow,
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
            GB.HideHistoryWindow()
        end
    )

    --------------------------------------------------------
    -- COLUMN HEADER HELPER
    --------------------------------------------------------

    local function CreateHeader(
        name,
        text,
        x,
        width,
        alignment
    )
        local label =
            WINDOW_MANAGER:CreateControl(
                name,
                historyWindow,
                CT_LABEL
            )

        label:SetFont(
            GetHistoryFont()
        )

        label:SetText(
            "|cAAAAAA"
                .. text
                .. "|r"
        )

        label:SetWidth(width)

        label:SetHorizontalAlignment(
            alignment
            or TEXT_ALIGN_LEFT
        )

        label:SetAnchor(
            TOPLEFT,
            historyWindow,
            TOPLEFT,
            x,
            40
        )

        table.insert(
            historyHeaderControls,
            label
        )

        return label
    end

    --------------------------------------------------------
    -- COLUMN HEADERS
    --------------------------------------------------------

    CreateHeader(
        "GatherBuddyHistoryHeaderDate",
        "DATE / TIME",
        15,
        140,
        TEXT_ALIGN_LEFT
    )

    CreateHeader(
        "GatherBuddyHistoryHeaderLength",
        "LENGTH",
        155,
        85,
        TEXT_ALIGN_RIGHT
    )

    CreateHeader(
        "GatherBuddyHistoryHeaderTotal",
        "TOTAL",
        250,
        65,
        TEXT_ALIGN_RIGHT
    )

    CreateHeader(
        "GatherBuddyHistoryHeaderPerHour",
        "ITEMS / HR",
        325,
        75,
        TEXT_ALIGN_RIGHT
    )

    CreateHeader(
        "GatherBuddyHistoryHeaderMost",
        "MOST GATHERED",
        415,
        210,
        TEXT_ALIGN_LEFT
    )

    --------------------------------------------------------
    -- SCROLL AREA
    --------------------------------------------------------

    historyScrollContainer =
        WINDOW_MANAGER:CreateControlFromVirtual(
            "GatherBuddyHistoryScrollContainer",
            historyWindow,
            "ZO_ScrollContainer"
        )

    historyScrollContainer:SetAnchor(
        TOPLEFT,
        historyWindow,
        TOPLEFT,
        10,
        62
    )

    historyScrollContainer:SetAnchor(
        BOTTOMRIGHT,
        historyWindow,
        BOTTOMRIGHT,
        -10,
        -12
    )

    historyScrollChild =
        historyScrollContainer:GetNamedChild(
            "ScrollChild"
        )

    historyScrollChild:SetWidth(
        620
    )

    historyScrollChild:SetHeight(
        255
    )

    --------------------------------------------------------
    -- EMPTY TEXT
    --------------------------------------------------------

    historyEmptyText =
        WINDOW_MANAGER:CreateControl(
            "GatherBuddyHistoryEmptyText",
            historyScrollChild,
            CT_LABEL
        )

    historyEmptyText:SetFont(
        GetHistoryFont()
    )

    historyEmptyText:SetText(
        "No completed sessions yet."
    )

    historyEmptyText:SetAnchor(
        TOPLEFT,
        historyScrollChild,
        TOPLEFT,
        5,
        8
    )

    --------------------------------------------------------
    -- APPLY CURRENT SETTINGS
    --------------------------------------------------------

    GB.ApplyHistoryFontSize()
    GB.ApplyHistoryBackgroundTransparency()
    GB.ApplyHistoryWindowLockState()

    --------------------------------------------------------
    -- INITIAL UPDATE
    --------------------------------------------------------

    GB.UpdateHistoryWindow()

    --------------------------------------------------------
    -- HUD SCENE INTEGRATION
    --------------------------------------------------------

    SetupHistoryWindowSceneFragment()
end