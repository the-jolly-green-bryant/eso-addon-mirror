GatherBuddy = GatherBuddy or {}

local GB = GatherBuddy

------------------------------------------------------------
-- WINDOW SETTINGS
------------------------------------------------------------

local DEFAULT_WIDTH = GB.DEFAULT_WIDTH or 300
local DEFAULT_HEIGHT = GB.DEFAULT_HEIGHT or 300

local MIN_WIDTH = GB.MIN_WIDTH or 300
local MIN_HEIGHT = GB.MIN_HEIGHT or 220

local MAX_WIDTH = GB.MAX_WIDTH or 900
local MAX_HEIGHT = GB.MAX_HEIGHT or 900

local ROW_HEIGHT = 18

------------------------------------------------------------
-- UI REFERENCES
------------------------------------------------------------

local mainWindow
local mainWindowFragment
local scrollContainer
local scrollChild
local emptyText
local totalValueLabel
local sessionTimeValueLabel
local mainBackground
local resizeHint

local rowControls = {}

local USER_HIDDEN_REASON = "GatherBuddyUserHidden"

------------------------------------------------------------
-- MAIN WINDOW SCENE VISIBILITY
------------------------------------------------------------

local function SetupMainWindowSceneFragment()
    if mainWindow == nil
        or mainWindowFragment ~= nil then
        return
    end

    -- Start hidden and let ESO's scene manager decide
    -- when the window belongs on screen.
    mainWindow:SetHidden(true)

    mainWindowFragment =
        ZO_HUDFadeSceneFragment:New(
            mainWindow
        )

    mainWindowFragment:SetHiddenForReason(
        USER_HIDDEN_REASON,
        GB.savedVariables.isHidden == true
    )

    local hudScene =
        SCENE_MANAGER:GetScene("hud")

    local hudUiScene =
        SCENE_MANAGER:GetScene("hudui")

    if hudScene then
        hudScene:AddFragment(
            mainWindowFragment
        )
    end

    if hudUiScene then
        hudUiScene:AddFragment(
            mainWindowFragment
        )
    end
end

function GB.ApplyMainWindowVisibility()
    if mainWindow == nil
        or GB.savedVariables == nil then
        return
    end

    local isUserHidden =
        GB.savedVariables.isHidden == true

    if mainWindowFragment then
        mainWindowFragment:SetHiddenForReason(
            USER_HIDDEN_REASON,
            isUserHidden
        )
    else
        mainWindow:SetHidden(
            isUserHidden
        )
    end
end

------------------------------------------------------------
-- UPDATE SESSION TIMER
------------------------------------------------------------

function GB.UpdateSessionTimer()
    if GB.GetElapsedSessionTime == nil
        or GB.FormatSessionTime == nil then
        return
    end

    local elapsedTime =
        GB.GetElapsedSessionTime()

    if sessionTimeValueLabel then
        sessionTimeValueLabel:SetText(
            GB.FormatSessionTime(elapsedTime)
        )
    end

    if GB.UpdateStatsWindow then
        GB.UpdateStatsWindow()
    end
end

------------------------------------------------------------
-- UPDATE MATERIAL LIST
------------------------------------------------------------

function GB.UpdateMaterialList()
    if GB.sessionItems == nil then
        return
    end

    local sortedItems = {}
    local totalQuantity = 0

    for itemId, data in pairs(GB.sessionItems) do
        table.insert(
            sortedItems,
            {
                itemId = itemId,
                name = data.name,
                quantity = data.quantity,
                quality = data.quality
            }
        )

        totalQuantity =
            totalQuantity + data.quantity
    end

    if totalValueLabel then
        totalValueLabel:SetText(
            tostring(totalQuantity)
        )
    end

    table.sort(
        sortedItems,
        function(a, b)
            return
                string.lower(a.name)
                < string.lower(b.name)
        end
    )

    --------------------------------------------------------
    -- RESPONSIVE LIST SIZE
    --------------------------------------------------------

    local windowWidth = DEFAULT_WIDTH
    local windowHeight = DEFAULT_HEIGHT

    if mainWindow then
        windowWidth = mainWindow:GetWidth()
        windowHeight = mainWindow:GetHeight()
    end

    local childWidth =
        math.max(
            260,
            windowWidth - 40
        )

    local visibleListHeight =
        math.max(
            110,
            windowHeight - 105
        )

    if scrollChild then
        scrollChild:SetWidth(
            childWidth
        )
    end

    --------------------------------------------------------
    -- HIDE OLD ROWS
    --------------------------------------------------------

    for _, row in ipairs(rowControls) do
        row:SetHidden(true)
    end

    --------------------------------------------------------
    -- EMPTY LIST
    --------------------------------------------------------

    if #sortedItems == 0 then
        if emptyText then
            emptyText:SetHidden(false)
        end

        if scrollChild then
            scrollChild:SetHeight(
                visibleListHeight
            )
        end

        if GB.UpdateStatsWindow then
            GB.UpdateStatsWindow()
        end

        return
    end

    if emptyText then
        emptyText:SetHidden(true)
    end

    --------------------------------------------------------
    -- MATERIAL ROWS
    --------------------------------------------------------

    for index, item in ipairs(sortedItems) do
        local row = rowControls[index]

        if row == nil then
            row =
                WINDOW_MANAGER:CreateControl(
                    "GatherBuddyRow"
                        .. tostring(index),
                    scrollChild,
                    CT_CONTROL
                )

            local nameLabel =
                WINDOW_MANAGER:CreateControl(
                    "GatherBuddyRowName"
                        .. tostring(index),
                    row,
                    CT_LABEL
                )

            nameLabel:SetFont(
                "ZoFontGameSmall"
            )

            nameLabel:SetAnchor(
                LEFT,
                row,
                LEFT,
                4,
                0
            )

            local quantityLabel =
                WINDOW_MANAGER:CreateControl(
                    "GatherBuddyRowQuantity"
                        .. tostring(index),
                    row,
                    CT_LABEL
                )

            quantityLabel:SetFont(
                "ZoFontGameSmall"
            )

            quantityLabel:SetAnchor(
                RIGHT,
                row,
                RIGHT,
                -8,
                0
            )

            quantityLabel:SetHorizontalAlignment(
                TEXT_ALIGN_RIGHT
            )

            quantityLabel:SetWidth(45)

            row.nameLabel = nameLabel
            row.quantityLabel = quantityLabel

            rowControls[index] = row
        end

        local rowWidth =
            childWidth - 5

        row:SetDimensions(
            rowWidth,
            ROW_HEIGHT
        )

        row.nameLabel:SetWidth(
            math.max(
                205,
                rowWidth - 60
            )
        )

        row:ClearAnchors()

        row:SetAnchor(
            TOPLEFT,
            scrollChild,
            TOPLEFT,
            0,
            (index - 1) * ROW_HEIGHT
        )

        local quality =
            item.quality or ITEM_QUALITY_NORMAL

        local qualityColor =
            GetItemQualityColor(quality)

        row.nameLabel:SetText(
            qualityColor:Colorize(
                item.name
            )
        )

        row.quantityLabel:SetText(
            "x" .. tostring(
                item.quantity
            )
        )

        row:SetHidden(false)
    end

    --------------------------------------------------------
    -- SCROLL CHILD HEIGHT
    --------------------------------------------------------

    local contentHeight =
        #sortedItems * ROW_HEIGHT

    if contentHeight < visibleListHeight then
        contentHeight =
            visibleListHeight
    end

    if scrollChild then
        scrollChild:SetHeight(
            contentHeight
        )
    end

    if GB.UpdateStatsWindow then
        GB.UpdateStatsWindow()
    end
end

------------------------------------------------------------
-- SAVE MAIN WINDOW SIZE
------------------------------------------------------------

function GB.SaveMainWindowSize()
    if mainWindow == nil
        or GB.savedVariables == nil then
        return
    end

    GB.savedVariables.left =
        mainWindow:GetLeft()

    GB.savedVariables.top =
        mainWindow:GetTop()

    GB.savedVariables.width =
        mainWindow:GetWidth()

    GB.savedVariables.height =
        mainWindow:GetHeight()
end

------------------------------------------------------------
-- BACKGROUND TRANSPARENCY
------------------------------------------------------------

function GB.ApplyBackgroundTransparency()
    if mainBackground == nil
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

    GB.savedVariables.backgroundTransparency =
        math.floor(
            transparency + 0.5
        )

    local alpha =
        1
        - (
            GB.savedVariables.backgroundTransparency
            / 255
        )

    mainBackground:SetCenterColor(
        0,
        0,
        0,
        alpha
    )
end

------------------------------------------------------------
-- MAIN WINDOW LOCK
------------------------------------------------------------

function GB.ApplyWindowLockState()
    if mainWindow == nil
        or GB.savedVariables == nil then
        return
    end

    local isLocked =
        GB.savedVariables.isLocked == true

    mainWindow:SetMovable(
        not isLocked
    )

    if isLocked then
        mainWindow:SetResizeHandleSize(0)
    else
        mainWindow:SetResizeHandleSize(16)
    end

    if resizeHint then
        resizeHint:SetHidden(isLocked)
    end

    -- Apply the same lock state to the Stats window.
    if GB.ApplyStatsWindowLockState then
        GB.ApplyStatsWindowLockState()
    end
end

function GB.UnlockWindow()
    if GB.savedVariables == nil then
        return
    end

    GB.savedVariables.isLocked = false

    GB.ApplyWindowLockState()

    CHAT_SYSTEM:AddMessage(
        "|c66CCFF[Gather Buddy]|r Window unlocked."
    )
end

------------------------------------------------------------
-- MAIN WINDOW SHOW / HIDE
------------------------------------------------------------

function GB.HideWindow()
    if mainWindow == nil
        or GB.savedVariables == nil then
        return
    end

    GB.savedVariables.isHidden = true

    GB.ApplyMainWindowVisibility()

    if GB.HideStatsWindow then
        GB.HideStatsWindow()
    end
end

function GB.ToggleWindow()
    if mainWindow == nil
        or GB.savedVariables == nil then
        return
    end

    GB.savedVariables.isHidden =
        not (
            GB.savedVariables.isHidden
            == true
        )

    GB.ApplyMainWindowVisibility()

    if GB.savedVariables.isHidden
        and GB.HideStatsWindow then

        GB.HideStatsWindow()
    end
end

------------------------------------------------------------
-- CREATE MAIN WINDOW
------------------------------------------------------------

function GB.CreateWindow()
    mainWindow =
        WINDOW_MANAGER:CreateTopLevelWindow(
            "GatherBuddyWindow"
        )

    GB.mainWindow = mainWindow

    --------------------------------------------------------
    -- LOAD SAVED SIZE
    --------------------------------------------------------

    local windowWidth =
        GB.savedVariables.width
        or DEFAULT_WIDTH

    local windowHeight =
        GB.savedVariables.height
        or DEFAULT_HEIGHT

    windowWidth =
        math.max(
            MIN_WIDTH,
            math.min(
                windowWidth,
                MAX_WIDTH
            )
        )

    windowHeight =
        math.max(
            MIN_HEIGHT,
            math.min(
                windowHeight,
                MAX_HEIGHT
            )
        )

    mainWindow:SetDimensions(
        windowWidth,
        windowHeight
    )

    --------------------------------------------------------
    -- RESIZE LIMITS
    --------------------------------------------------------

    mainWindow:SetDimensionConstraints(
        MIN_WIDTH,
        MIN_HEIGHT,
        MAX_WIDTH,
        MAX_HEIGHT
    )

    mainWindow:SetResizeHandleSize(16)

    mainWindow:SetMovable(true)
    mainWindow:SetMouseEnabled(true)
    mainWindow:SetClampedToScreen(true)

    --------------------------------------------------------
    -- SAVED POSITION
    --------------------------------------------------------

    if GB.savedVariables.left
        and GB.savedVariables.top then

        mainWindow:SetAnchor(
            TOPLEFT,
            GuiRoot,
            TOPLEFT,
            GB.savedVariables.left,
            GB.savedVariables.top
        )
    else
        mainWindow:SetAnchor(
            CENTER,
            GuiRoot,
            CENTER,
            0,
            0
        )
    end

    --------------------------------------------------------
    -- RESIZE FINISHED
    --------------------------------------------------------

    mainWindow:SetHandler(
        "OnResizeStop",
        function()
            GB.SaveMainWindowSize()
            GB.UpdateMaterialList()
        end
    )

    --------------------------------------------------------
    -- BACKGROUND
    --------------------------------------------------------

    mainBackground =
        WINDOW_MANAGER:CreateControl(
            "GatherBuddyBackground",
            mainWindow,
            CT_BACKDROP
        )

    mainBackground:SetAnchorFill()

    mainBackground:SetCenterColor(
        0,
        0,
        0,
        0.75
    )

    mainBackground:SetEdgeColor(
        0.4,
        0.4,
        0.4,
        1
    )

    mainBackground:SetEdgeTexture(
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
            "GatherBuddyTitleBar",
            mainWindow,
            CT_CONTROL
        )

    titleBar:SetAnchor(
        TOPLEFT,
        mainWindow,
        TOPLEFT,
        0,
        0
    )

    titleBar:SetAnchor(
        TOPRIGHT,
        mainWindow,
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

                mainWindow:StartMoving()
            end
        end
    )

    titleBar:SetHandler(
        "OnMouseUp",
        function(self, button)
            if button == MOUSE_BUTTON_INDEX_LEFT then
                mainWindow:StopMovingOrResizing()

                GB.savedVariables.left =
                    mainWindow:GetLeft()

                GB.savedVariables.top =
                    mainWindow:GetTop()
            end
        end
    )

    --------------------------------------------------------
    -- TITLE
    --------------------------------------------------------

    local title =
        WINDOW_MANAGER:CreateControl(
            "GatherBuddyTitle",
            titleBar,
            CT_LABEL
        )

    title:SetFont(
        "ZoFontWinH4"
    )

    title:SetText(
        "|c66CCFFGATHER BUDDY v"
            .. (GB.ADDON_VERSION or "1.1")
            .. "|r"
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
            "GatherBuddyCloseButton",
            mainWindow,
            CT_BUTTON
        )

    closeButton:SetDimensions(
        22,
        26
    )

    closeButton:SetAnchor(
        TOPRIGHT,
        mainWindow,
        TOPRIGHT,
        -6,
        3
    )

    closeButton:SetFont(
        "ZoFontGame"
    )

    closeButton:SetText("X")

    closeButton:SetHandler(
        "OnClicked",
        function()
            GB.HideWindow()
        end
    )

    --------------------------------------------------------
    -- CLEAR BUTTON
    --------------------------------------------------------

    local clearButton =
        WINDOW_MANAGER:CreateControl(
            "GatherBuddyClearButton",
            mainWindow,
            CT_BUTTON
        )

    clearButton:SetDimensions(
        46,
        26
    )

    clearButton:SetAnchor(
        TOPRIGHT,
        mainWindow,
        TOPRIGHT,
        -32,
        3
    )

    clearButton:SetFont(
        "ZoFontGameSmall"
    )

    clearButton:SetText(
        "CLEAR"
    )

    clearButton:SetHandler(
        "OnClicked",
        function()
            if GB.ClearSession then
                GB.ClearSession()
            end
        end
    )

    --------------------------------------------------------
    -- STATS BUTTON
    --------------------------------------------------------

    local statsButton =
        WINDOW_MANAGER:CreateControl(
            "GatherBuddyStatsButton",
            mainWindow,
            CT_BUTTON
        )

    statsButton:SetDimensions(
        46,
        26
    )

    statsButton:SetAnchor(
        TOPRIGHT,
        mainWindow,
        TOPRIGHT,
        -82,
        3
    )

    statsButton:SetFont(
        "ZoFontGameSmall"
    )

    statsButton:SetText(
        "STATS"
    )

    statsButton:SetHandler(
        "OnClicked",
        function()
            if GB.ToggleStatsWindow then
                GB.ToggleStatsWindow()
            end
        end
    )

    --------------------------------------------------------
    -- SCROLL AREA
    --------------------------------------------------------

    scrollContainer =
        WINDOW_MANAGER:CreateControlFromVirtual(
            "GatherBuddyScrollContainer",
            mainWindow,
            "ZO_ScrollContainer"
        )

    scrollContainer:SetAnchor(
        TOPLEFT,
        mainWindow,
        TOPLEFT,
        10,
        40
    )

    scrollContainer:SetAnchor(
        BOTTOMRIGHT,
        mainWindow,
        BOTTOMRIGHT,
        -10,
        -62
    )

    scrollChild =
        scrollContainer:GetNamedChild(
            "ScrollChild"
        )

    scrollChild:SetWidth(
        math.max(
            260,
            windowWidth - 40
        )
    )

    scrollChild:SetHeight(
        math.max(
            110,
            windowHeight - 105
        )
    )

    --------------------------------------------------------
    -- EMPTY TEXT
    --------------------------------------------------------

    emptyText =
        WINDOW_MANAGER:CreateControl(
            "GatherBuddyEmptyText",
            scrollChild,
            CT_LABEL
        )

    emptyText:SetFont(
        "ZoFontGameSmall"
    )

    emptyText:SetText(
        "No materials gathered yet."
    )

    emptyText:SetAnchor(
        TOPLEFT,
        scrollChild,
        TOPLEFT,
        4,
        5
    )

    --------------------------------------------------------
    -- TOTAL
    --------------------------------------------------------

    local totalTitleLabel =
        WINDOW_MANAGER:CreateControl(
            "GatherBuddyTotalTitle",
            mainWindow,
            CT_LABEL
        )

    totalTitleLabel:SetFont(
        "ZoFontGameSmall"
    )

    totalTitleLabel:SetText(
        "TOTAL THIS SESSION:"
    )

    totalTitleLabel:SetAnchor(
        BOTTOMLEFT,
        mainWindow,
        BOTTOMLEFT,
        14,
        -30
    )

    totalValueLabel =
        WINDOW_MANAGER:CreateControl(
            "GatherBuddyTotalValue",
            mainWindow,
            CT_LABEL
        )

    totalValueLabel:SetFont(
        "ZoFontGameSmall"
    )

    totalValueLabel:SetText("0")
    totalValueLabel:SetWidth(70)

    totalValueLabel:SetHorizontalAlignment(
        TEXT_ALIGN_RIGHT
    )

    totalValueLabel:SetAnchor(
        BOTTOMRIGHT,
        mainWindow,
        BOTTOMRIGHT,
        -18,
        -30
    )

    --------------------------------------------------------
    -- SESSION TIME
    --------------------------------------------------------

    local sessionTimeTitleLabel =
        WINDOW_MANAGER:CreateControl(
            "GatherBuddySessionTimeTitle",
            mainWindow,
            CT_LABEL
        )

    sessionTimeTitleLabel:SetFont(
        "ZoFontGameSmall"
    )

    sessionTimeTitleLabel:SetText(
        "SESSION TIME:"
    )

    sessionTimeTitleLabel:SetAnchor(
        BOTTOMLEFT,
        mainWindow,
        BOTTOMLEFT,
        14,
        -10
    )

    sessionTimeValueLabel =
        WINDOW_MANAGER:CreateControl(
            "GatherBuddySessionTimeValue",
            mainWindow,
            CT_LABEL
        )

    sessionTimeValueLabel:SetFont(
        "ZoFontGameSmall"
    )

    sessionTimeValueLabel:SetText(
        "00:00:00"
    )

    sessionTimeValueLabel:SetWidth(90)

    sessionTimeValueLabel:SetHorizontalAlignment(
        TEXT_ALIGN_RIGHT
    )

    sessionTimeValueLabel:SetAnchor(
        BOTTOMRIGHT,
        mainWindow,
        BOTTOMRIGHT,
        -18,
        -10
    )

    --------------------------------------------------------
    -- VISUAL RESIZE HINT
    --------------------------------------------------------

    resizeHint =
        WINDOW_MANAGER:CreateControl(
            "GatherBuddyResizeHint",
            mainWindow,
            CT_LABEL
        )

    resizeHint:SetFont(
        "ZoFontGameSmall"
    )

    resizeHint:SetText(
        "|c777777//|r"
    )

    resizeHint:SetAnchor(
        BOTTOMRIGHT,
        mainWindow,
        BOTTOMRIGHT,
        -3,
        -1
    )

    resizeHint:SetMouseEnabled(false)

    --------------------------------------------------------
    -- APPLY SAVED SETTINGS
    --------------------------------------------------------

    GB.ApplyWindowLockState()
    GB.ApplyBackgroundTransparency()

    --------------------------------------------------------
    -- INITIAL UPDATE
    --------------------------------------------------------

    GB.UpdateMaterialList()
    GB.UpdateSessionTimer()

    --------------------------------------------------------
    -- HUD SCENE INTEGRATION
    --------------------------------------------------------

    SetupMainWindowSceneFragment()
end