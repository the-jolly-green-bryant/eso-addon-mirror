GatherBuddy = GatherBuddy or {}

local GB = GatherBuddy

------------------------------------------------------------
-- HISTORY SETTINGS
------------------------------------------------------------

local MAX_HISTORY = 10

local WINDOW_WIDTH = 660
local WINDOW_HEIGHT = 360

local ROW_HEIGHT = 54

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

local selectedHistorySessionIndex = nil
local historyBackButton

local historyDetailControls = {}

local historyDetailTitle
local historyDetailLength
local historyDetailTotal
local historyDetailPerHour
local historyDetailMost

local historyDetailItemRows = {}

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
-- HISTORY SESSION LABEL
------------------------------------------------------------

local MONTH_NAMES = {
    [1] = "January",
    [2] = "February",
    [3] = "March",
    [4] = "April",
    [5] = "May",
    [6] = "June",
    [7] = "July",
    [8] = "August",
    [9] = "September",
    [10] = "October",
    [11] = "November",
    [12] = "December",
}

local function FormatHistorySessionLabel(session)
    if session == nil then
        return "SESSION"
    end

    local dateText = session.dateText or "-"
    local timestamp = tonumber(session.endedAt)

    if timestamp then
        local year, month, day =
            GetDateElementsFromTimestamp(timestamp)

        local monthName =
            MONTH_NAMES[tonumber(month)]

        if year and monthName and day then
            dateText = string.format(
                "%d %s, %d",
                day,
                monthName,
                year
            )
        end
    end

    local clockText =
        tostring(session.clockText or "")

    local hour, minute =
        string.match(
            clockText,
            "^(%d+):(%d+)"
        )

    if hour and minute then
        clockText =
            hour .. ":" .. minute
    end

    if clockText ~= "" then
        return string.format(
            "SESSION — %s — %s",
            dateText,
            clockText
        )
    end

    return string.format(
        "SESSION — %s",
        dateText
    )
end

local function SetHistoryHeadersHidden(hidden)
    for _, control in ipairs(historyHeaderControls) do
        if control then
            control:SetHidden(hidden)
        end
    end
end

local function HideHistoryDetailControls()
    for _, control in ipairs(historyDetailControls) do
        if control then
            control:SetHidden(true)
        end
    end
end

------------------------------------------------------------
-- HISTORY MATERIAL CATEGORIES
------------------------------------------------------------

local HISTORY_CATEGORY_ORDER = {
    "BLACKSMITHING",
    "CLOTHING",
    "WOODWORKING",
    "JEWELRY",
    "ALCHEMY",
    "ENCHANTING",
    "PROVISIONING",
    "FISHING",
    "FURNISHING",
    "OTHER",
}

local HISTORY_ITEM_TYPE_CATEGORIES = {
    [ITEMTYPE_BLACKSMITHING_RAW_MATERIAL] = "BLACKSMITHING",

    [ITEMTYPE_CLOTHIER_RAW_MATERIAL] = "CLOTHING",

    [ITEMTYPE_WOODWORKING_RAW_MATERIAL] = "WOODWORKING",

    [ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL] = "JEWELRY",
    [ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER] = "JEWELRY",
    [ITEMTYPE_JEWELRY_RAW_TRAIT] = "JEWELRY",

    [ITEMTYPE_REAGENT] = "ALCHEMY",
    [ITEMTYPE_POTION_BASE] = "ALCHEMY",
    [ITEMTYPE_POISON_BASE] = "ALCHEMY",

    [ITEMTYPE_ENCHANTING_RUNE_ASPECT] = "ENCHANTING",
    [ITEMTYPE_ENCHANTING_RUNE_ESSENCE] = "ENCHANTING",
    [ITEMTYPE_ENCHANTING_RUNE_POTENCY] = "ENCHANTING",

    [ITEMTYPE_INGREDIENT] = "PROVISIONING",
    [ITEMTYPE_FLAVORING] = "PROVISIONING",
    [ITEMTYPE_SPICE] = "PROVISIONING",

    [ITEMTYPE_FISH] = "FISHING",

    [ITEMTYPE_FURNISHING_MATERIAL] = "FURNISHING",
}

local HISTORY_FISHING_FURNISHING_ITEM_IDS = {
    [118337] = true, -- Fish, Trout
    [118338] = true, -- Fish, Bass
    [118339] = true, -- Fish, Salmon
    [118357] = true, -- Fish, Small
    [118358] = true, -- Fish, Medium
    [118359] = true, -- Fish, Large
}

local function GetHistoryItemCategory(item)
    if item == nil then
        return "OTHER"
    end

    local itemId =
        tonumber(item.itemId)

    if itemId == nil then
        return "OTHER"
    end

    --------------------------------------------------------
    -- SPECIAL FISHING FURNISHINGS
    --------------------------------------------------------

    if HISTORY_FISHING_FURNISHING_ITEM_IDS[itemId] then
        return "FISHING"
    end

    --------------------------------------------------------
    -- BUILD ITEM LINK FROM SAVED ITEM ID
    --------------------------------------------------------

    local itemLink =
        string.format(
            "|H0:item:%d:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
            itemId
        )

    local itemType, specializedItemType =
        GetItemLinkItemType(
            itemLink
        )

    --------------------------------------------------------
    -- RARE ACHIEVEMENT FISH
    --------------------------------------------------------

    if itemType == ITEMTYPE_COLLECTIBLE
        and specializedItemType
            == SPECIALIZED_ITEMTYPE_COLLECTIBLE_RARE_FISH then

        return "FISHING"
    end

    --------------------------------------------------------
    -- STANDARD MATERIAL TYPES
    --------------------------------------------------------

    return
        HISTORY_ITEM_TYPE_CATEGORIES[itemType]
        or "OTHER"
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

    --------------------------------------------------------
    -- SESSION DETAILS SUMMARY
    --------------------------------------------------------

    if historyDetailLength then
        historyDetailLength:SetFont(font)
    end

    if historyDetailTotal then
        historyDetailTotal:SetFont(font)
    end

    if historyDetailPerHour then
        historyDetailPerHour:SetFont(font)
    end

    if historyDetailMost then
        historyDetailMost:SetFont(font)
    end

    --------------------------------------------------------
    -- DETAIL ITEM ROWS
    --------------------------------------------------------

    for _, row in ipairs(
        historyDetailItemRows
    ) do
        if row.nameLabel then
            row.nameLabel:SetFont(font)
        end

        if row.quantityLabel then
            row.quantityLabel:SetFont(font)
        end
    end

    --------------------------------------------------------
    -- CATEGORY HEADERS
    --------------------------------------------------------

    if historyScrollChild
        and historyScrollChild.historyCategoryHeaders then

        for _, header in pairs(
            historyScrollChild.historyCategoryHeaders
        ) do
            if header then
                header:SetFont(font)
            end
        end
    end

    --------------------------------------------------------
    -- REBUILD CURRENT VIEW
    --------------------------------------------------------

    if historyWindow
        and GB.UpdateHistoryWindow then

        GB.UpdateHistoryWindow()
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

    selectedHistorySessionIndex = nil

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
    -- RESET SCROLL POSITION
    --------------------------------------------------------

    if historyScrollContainer
        and ZO_Scroll_ResetToTop then

        ZO_Scroll_ResetToTop(
            historyScrollContainer
        )
    end
	
    --------------------------------------------------------
    -- HIDE EXISTING ROWS
    --------------------------------------------------------

    for _, row in ipairs(
        historyRows
    ) do
        row:SetHidden(true)
    end

    --------------------------------------------------------
    -- HIDE EXISTING DETAIL ITEM ROWS
    --------------------------------------------------------

    for _, row in ipairs(
        historyDetailItemRows
    ) do
        if row then
            row:SetHidden(true)
        end
    end

    --------------------------------------------------------
    -- HIDE EXISTING CATEGORY HEADERS
    --------------------------------------------------------

    if historyScrollChild
        and historyScrollChild.historyCategoryHeaders then

        for _, header in pairs(
            historyScrollChild.historyCategoryHeaders
        ) do
            if header then
                header:SetHidden(true)
            end
        end
    end
	
    --------------------------------------------------------
    -- RESET VIEW STATE
    --------------------------------------------------------

    HideHistoryDetailControls()
    SetHistoryHeadersHidden(false)

    if historyBackButton then
        historyBackButton:SetHidden(true)
    end

    --------------------------------------------------------
    -- SESSION DETAILS
    --------------------------------------------------------

    if selectedHistorySessionIndex ~= nil then
        local session =
            history[selectedHistorySessionIndex]

        if session ~= nil then
            SetHistoryHeadersHidden(true)

            historyEmptyText:SetHidden(true)

            if historyBackButton then
                historyBackButton:SetHidden(false)
            end

            ------------------------------------------------
            -- SESSION TITLE
            ------------------------------------------------

            historyDetailTitle:SetText(
                "|c66CCFF"
                    .. FormatHistorySessionLabel(session)
                    .. "|r"
            )

            historyDetailTitle:SetHidden(false)

            ------------------------------------------------
            -- LENGTH
            ------------------------------------------------

            historyDetailLength:SetFont(font)

            historyDetailLength:SetText(
                "|cAAAAAALENGTH:|r "
                    .. GB.FormatSessionTime(
                        session.duration or 0
                    )
            )

            historyDetailLength:SetHidden(false)

            ------------------------------------------------
            -- TOTAL
            ------------------------------------------------

            historyDetailTotal:SetFont(font)

            historyDetailTotal:SetText(
                "|cAAAAAATOTAL:|r "
                    .. tostring(
                        session.totalQuantity or 0
                    )
            )

            historyDetailTotal:SetHidden(false)

            ------------------------------------------------
            -- ITEMS / HOUR
            ------------------------------------------------

            historyDetailPerHour:SetFont(font)

            historyDetailPerHour:SetText(
                "|cAAAAAAITEMS / HR:|r "
                    .. tostring(
                        session.itemsPerHour or 0
                    )
            )

            historyDetailPerHour:SetHidden(false)

            ------------------------------------------------
            -- MOST GATHERED
            ------------------------------------------------

            local mostText = "-"

            if session.mostGathered
                and session.mostGathered.name then

                local quality =
                    session.mostGathered.quality
                    or ITEM_QUALITY_NORMAL

                local qualityColor =
                    GetItemQualityColor(
                        quality
                    )

                mostText =
                    qualityColor:Colorize(
                        session.mostGathered.name
                    )
                        .. " x"
                        .. tostring(
                            session.mostGathered.quantity
                            or 0
                        )
            end

            historyDetailMost:SetFont(font)

            historyDetailMost:SetText(
                "|cAAAAAAMOST GATHERED:|r "
                    .. mostText
            )

            historyDetailMost:SetHidden(false)

            ------------------------------------------------
            -- CATEGORIZED SESSION ITEM LIST
            ------------------------------------------------

            local items =
                session.items or {}

            local categorizedItems = {}

            for _, categoryName in ipairs(
                HISTORY_CATEGORY_ORDER
            ) do
                categorizedItems[categoryName] = {}
            end

            ------------------------------------------------
            -- GROUP ITEMS BY CATEGORY
            ------------------------------------------------

            for _, item in ipairs(items) do
                local categoryName =
                    GetHistoryItemCategory(item)

                if categorizedItems[categoryName] == nil then
                    categorizedItems[categoryName] = {}
                end

                table.insert(
                    categorizedItems[categoryName],
                    item
                )
            end

            ------------------------------------------------
            -- CATEGORY HEADER STORAGE
            ------------------------------------------------

            historyScrollChild.historyCategoryHeaders =
                historyScrollChild.historyCategoryHeaders
                or {}

            local categoryHeaders =
                historyScrollChild.historyCategoryHeaders

            ------------------------------------------------
            -- ROW SIZES
            ------------------------------------------------

            local detailRowHeight =
                math.max(
                    22,
                    GetHistoryFontSize() + 8
                )

            local categoryHeaderHeight = 26
            local currentY = 155
            local displayItemIndex = 0
            local visibleCategoryCount = 0

            ------------------------------------------------
            -- BUILD CATEGORIES
            ------------------------------------------------

            for _, categoryName in ipairs(
                HISTORY_CATEGORY_ORDER
            ) do
                local categoryItems =
                    categorizedItems[categoryName]

                if categoryItems
                    and #categoryItems > 0 then

                    if visibleCategoryCount > 0 then
                        currentY =
                            currentY + 8
                    end

                    visibleCategoryCount =
                        visibleCategoryCount + 1

                    ----------------------------------------
                    -- CATEGORY HEADER
                    ----------------------------------------

                    local categoryHeader =
                        categoryHeaders[categoryName]

                    if categoryHeader == nil then
                        categoryHeader =
                            WINDOW_MANAGER:CreateControl(
                                "GatherBuddyHistoryCategory"
                                    .. categoryName,
                                historyScrollChild,
                                CT_LABEL
                            )

                        categoryHeader:SetWidth(
                            600
                        )

                        categoryHeaders[categoryName] =
                            categoryHeader

                        table.insert(
                            historyDetailControls,
                            categoryHeader
                        )
                    end

                    categoryHeader:SetFont(
                        GetHistoryFont()
                    )

                    categoryHeader:SetText(
                        "|c66CCFF"
                            .. categoryName
                            .. "|r"
                    )

                    categoryHeader:ClearAnchors()

                    categoryHeader:SetAnchor(
                        TOPLEFT,
                        historyScrollChild,
                        TOPLEFT,
                        5,
                        currentY
                    )

                    categoryHeader:SetHidden(
                        false
                    )

                    currentY =
                        currentY
                        + categoryHeaderHeight

                    ----------------------------------------
                    -- ITEMS IN CATEGORY
                    ----------------------------------------

                    for _, item in ipairs(
                        categoryItems
                    ) do
                        displayItemIndex =
                            displayItemIndex + 1

                        local row =
                            historyDetailItemRows[
                                displayItemIndex
                            ]

                        if row == nil then
                            row =
                                WINDOW_MANAGER:CreateControl(
                                    "GatherBuddyHistoryDetailItem"
                                        .. tostring(
                                            displayItemIndex
                                        ),
                                    historyScrollChild,
                                    CT_CONTROL
                                )

                            row:SetWidth(
                                600
                            )

                            local nameLabel =
                                WINDOW_MANAGER:CreateControl(
                                    "GatherBuddyHistoryDetailItemName"
                                        .. tostring(
                                            displayItemIndex
                                        ),
                                    row,
                                    CT_LABEL
                                )

                            nameLabel:SetAnchor(
                                LEFT,
                                row,
                                LEFT,
                                15,
                                0
                            )

                            nameLabel:SetWidth(
                                490
                            )

                            local quantityLabel =
                                WINDOW_MANAGER:CreateControl(
                                    "GatherBuddyHistoryDetailItemQuantity"
                                        .. tostring(
                                            displayItemIndex
                                        ),
                                    row,
                                    CT_LABEL
                                )

                            quantityLabel:SetAnchor(
                                RIGHT,
                                row,
                                RIGHT,
                                -5,
                                0
                            )

                            quantityLabel:SetWidth(
                                70
                            )

                            quantityLabel:SetHorizontalAlignment(
                                TEXT_ALIGN_RIGHT
                            )

                            row.nameLabel =
                                nameLabel

                            row.quantityLabel =
                                quantityLabel

                            historyDetailItemRows[
                                displayItemIndex
                            ] = row

                            table.insert(
                                historyDetailControls,
                                row
                            )
                        end

                        row:SetHeight(
                            detailRowHeight
                        )

                        row:ClearAnchors()

                        row:SetAnchor(
                            TOPLEFT,
                            historyScrollChild,
                            TOPLEFT,
                            0,
                            currentY
                        )

                        row.nameLabel:SetFont(
                            font
                        )

                        row.quantityLabel:SetFont(
                            font
                        )

                        local quality =
                            item.quality
                            or ITEM_QUALITY_NORMAL

                        local qualityColor =
                            GetItemQualityColor(
                                quality
                            )

                        row.nameLabel:SetText(
                            qualityColor:Colorize(
                                item.name or "-"
                            )
                        )

                        row.quantityLabel:SetText(
                            "x"
                                .. tostring(
                                    item.quantity or 0
                                )
                        )

                        row:SetHidden(
                            false
                        )

                        currentY =
                            currentY
                            + detailRowHeight
                    end
                end
            end

            ------------------------------------------------
            -- DETAIL SCROLL HEIGHT
            ------------------------------------------------

            historyScrollChild:SetHeight(
                math.max(
                    255,
                    currentY + 15
                )
            )

            return
        else
            selectedHistorySessionIndex = nil
        end
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

            row:SetMouseEnabled(true)

            row:SetHandler(
                "OnMouseUp",
                function(self, button, upInside)
                    if button == MOUSE_BUTTON_INDEX_LEFT
                        and upInside then

                        selectedHistorySessionIndex =
                            self.historyIndex

                        GB.UpdateHistoryWindow()
                    end
                end
            )

            ------------------------------------------------
            -- SESSION TITLE
            ------------------------------------------------

            local dateLabel =
                WINDOW_MANAGER:CreateControl(
                    "GatherBuddyHistoryDate"
                        .. tostring(index),
                    row,
                    CT_LABEL
                )

            dateLabel:SetFont(font)

            dateLabel:SetWidth(600)

            dateLabel:SetAnchor(
                TOPLEFT,
                row,
                TOPLEFT,
                5,
                3
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

            durationLabel:SetWidth(110)

            durationLabel:SetHorizontalAlignment(
                TEXT_ALIGN_RIGHT
            )

            durationLabel:SetAnchor(
                TOPLEFT,
                row,
                TOPLEFT,
                5,
                27
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

            totalLabel:SetWidth(90)

            totalLabel:SetHorizontalAlignment(
                TEXT_ALIGN_RIGHT
            )

            totalLabel:SetAnchor(
                TOPLEFT,
                row,
                TOPLEFT,
                125,
                27
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

            perHourLabel:SetWidth(110)

            perHourLabel:SetHorizontalAlignment(
                TEXT_ALIGN_RIGHT
            )

            perHourLabel:SetAnchor(
                TOPLEFT,
                row,
                TOPLEFT,
                235,
                27
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

            mostLabel:SetWidth(250)

            mostLabel:SetAnchor(
                TOPLEFT,
                row,
                TOPLEFT,
                365,
                27
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

        row.historyIndex = index
		
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
        -- SESSION TITLE
        ----------------------------------------------------

        row.dateLabel:SetText(
            "|c66CCFF"
                .. FormatHistorySessionLabel(
                    session
                )
                .. "|r"
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

    if historyUserHidden then
        selectedHistorySessionIndex = nil
    else
        GB.UpdateHistoryWindow()
    end

    ApplyHistoryWindowVisibility()
end

function GB.HideHistoryWindow()
    if historyWindow == nil then
        return
    end

    historyUserHidden = true
    selectedHistorySessionIndex = nil

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
    -- BACK BUTTON
    --------------------------------------------------------

    historyBackButton =
        WINDOW_MANAGER:CreateControl(
            "GatherBuddyHistoryBack",
            historyWindow,
            CT_BUTTON
        )

    historyBackButton:SetDimensions(
        70,
        24
    )

    historyBackButton:SetAnchor(
        TOPRIGHT,
        historyWindow,
        TOPRIGHT,
        -42,
        3
    )

    historyBackButton:SetFont(
        "ZoFontGame"
    )

    historyBackButton:SetText(
        "BACK"
    )

    historyBackButton:SetHidden(
        true
    )

    historyBackButton:SetHandler(
        "OnClicked",
        function()
            selectedHistorySessionIndex = nil

            GB.UpdateHistoryWindow()
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
        "GatherBuddyHistoryHeaderLength",
        "LENGTH",
        15,
        100,
        TEXT_ALIGN_RIGHT
    )

    CreateHeader(
        "GatherBuddyHistoryHeaderTotal",
        "TOTAL",
        135,
        80,
        TEXT_ALIGN_RIGHT
    )

    CreateHeader(
        "GatherBuddyHistoryHeaderPerHour",
        "ITEMS / HR",
        245,
        100,
        TEXT_ALIGN_RIGHT
    )

    CreateHeader(
        "GatherBuddyHistoryHeaderMost",
        "MOST GATHERED",
        375,
        240,
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
    -- SESSION DETAILS SUMMARY
    --------------------------------------------------------

    historyDetailTitle =
        WINDOW_MANAGER:CreateControl(
            "GatherBuddyHistoryDetailTitle",
            historyScrollChild,
            CT_LABEL
        )

    historyDetailTitle:SetFont(
        "ZoFontWinH4"
    )

    historyDetailTitle:SetAnchor(
        TOPLEFT,
        historyScrollChild,
        TOPLEFT,
        5,
        5
    )

    historyDetailTitle:SetWidth(
        600
    )

    historyDetailTitle:SetHidden(
        true
    )

    table.insert(
        historyDetailControls,
        historyDetailTitle
    )

    --------------------------------------------------------
    -- LENGTH
    --------------------------------------------------------

    historyDetailLength =
        WINDOW_MANAGER:CreateControl(
            "GatherBuddyHistoryDetailLength",
            historyScrollChild,
            CT_LABEL
        )

    historyDetailLength:SetFont(
        GetHistoryFont()
    )

    historyDetailLength:SetAnchor(
        TOPLEFT,
        historyScrollChild,
        TOPLEFT,
        5,
        40
    )

    historyDetailLength:SetHidden(
        true
    )

    table.insert(
        historyDetailControls,
        historyDetailLength
    )

    --------------------------------------------------------
    -- TOTAL
    --------------------------------------------------------

    historyDetailTotal =
        WINDOW_MANAGER:CreateControl(
            "GatherBuddyHistoryDetailTotal",
            historyScrollChild,
            CT_LABEL
        )

    historyDetailTotal:SetFont(
        GetHistoryFont()
    )

    historyDetailTotal:SetAnchor(
        TOPLEFT,
        historyScrollChild,
        TOPLEFT,
        5,
        65
    )

    historyDetailTotal:SetHidden(
        true
    )

    table.insert(
        historyDetailControls,
        historyDetailTotal
    )

    --------------------------------------------------------
    -- ITEMS / HOUR
    --------------------------------------------------------

    historyDetailPerHour =
        WINDOW_MANAGER:CreateControl(
            "GatherBuddyHistoryDetailPerHour",
            historyScrollChild,
            CT_LABEL
        )

    historyDetailPerHour:SetFont(
        GetHistoryFont()
    )

    historyDetailPerHour:SetAnchor(
        TOPLEFT,
        historyScrollChild,
        TOPLEFT,
        5,
        90
    )

    historyDetailPerHour:SetHidden(
        true
    )

    table.insert(
        historyDetailControls,
        historyDetailPerHour
    )

    --------------------------------------------------------
    -- MOST GATHERED
    --------------------------------------------------------

    historyDetailMost =
        WINDOW_MANAGER:CreateControl(
            "GatherBuddyHistoryDetailMost",
            historyScrollChild,
            CT_LABEL
        )

    historyDetailMost:SetFont(
        GetHistoryFont()
    )

    historyDetailMost:SetAnchor(
        TOPLEFT,
        historyScrollChild,
        TOPLEFT,
        5,
        115
    )

    historyDetailMost:SetWidth(
        600
    )

    historyDetailMost:SetHidden(
        true
    )

    table.insert(
        historyDetailControls,
        historyDetailMost
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