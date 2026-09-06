GatherBuddy = GatherBuddy or {}

local GB = GatherBuddy

------------------------------------------------------------
-- RARE MATERIAL ALERT SETTINGS
------------------------------------------------------------

local ALERT_WIDTH = 360
local ALERT_HEIGHT = 88

local MAX_ALERT_ROWS = 3

local CURRENT_FONT_SIZE = 17
local PREVIOUS_FONT_SIZE = 14

local DEFAULT_ALERT_DURATION = 4
local FADE_DURATION = 0.75

local FADE_UPDATE_NAME =
    "GatherBuddyRareAlertFade"

local USER_HIDDEN_REASON =
    "GatherBuddyRareAlertHidden"

------------------------------------------------------------
-- UI REFERENCES
------------------------------------------------------------

local alertWindow
local alertWindowFragment
local alertBackground

local alertRows = {}

------------------------------------------------------------
-- RUNTIME ALERT DATA
------------------------------------------------------------

local alertEntries = {}

local fadeStartTime = nil
local fadeEndTime = nil

------------------------------------------------------------
-- FONT HELPERS
------------------------------------------------------------

local function GetAlertFont(size)
    return string.format(
        "$(MEDIUM_FONT)|%d|soft-shadow-thin",
        size
    )
end

------------------------------------------------------------
-- ALERT DURATION
------------------------------------------------------------

local function GetAlertDuration()
    if GB.savedVariables == nil then
        return DEFAULT_ALERT_DURATION
    end

    local duration =
        tonumber(
            GB.savedVariables.rareAlertDuration
        )
        or DEFAULT_ALERT_DURATION

    return math.max(
        2,
        math.min(
            10,
            duration
        )
    )
end

------------------------------------------------------------
-- ALERT ENABLED
------------------------------------------------------------

local function IsRareAlertEnabled()
    if GB.savedVariables == nil then
        return true
    end

    if GB.savedVariables.rareAlertEnabled == nil then
        return true
    end

    return
        GB.savedVariables.rareAlertEnabled
        == true
end

------------------------------------------------------------
-- WINDOW VISIBILITY
------------------------------------------------------------

local function ApplyRareAlertVisibility(hidden)
    if alertWindow == nil then
        return
    end

    if alertWindowFragment then
        alertWindowFragment:SetHiddenForReason(
            USER_HIDDEN_REASON,
            hidden
        )
    else
        alertWindow:SetHidden(
            hidden
        )
    end
end

------------------------------------------------------------
-- HUD SCENE INTEGRATION
------------------------------------------------------------

local function SetupRareAlertSceneFragment()
    if alertWindow == nil
        or alertWindowFragment ~= nil then
        return
    end

    alertWindow:SetHidden(true)

    alertWindowFragment =
        ZO_HUDFadeSceneFragment:New(
            alertWindow
        )

    alertWindowFragment:SetHiddenForReason(
        USER_HIDDEN_REASON,
        true
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
            alertWindowFragment
        )
    end

    if hudUiScene then
        hudUiScene:AddFragment(
            alertWindowFragment
        )
    end
end

------------------------------------------------------------
-- BACKGROUND TRANSPARENCY
------------------------------------------------------------

function GB.ApplyRareAlertBackgroundTransparency()
    if alertBackground == nil
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
        1
        - (
            transparency
            / 255
        )

    alertBackground:SetCenterColor(
        0,
        0,
        0,
        alpha
    )
end

------------------------------------------------------------
-- WINDOW LOCK
------------------------------------------------------------

function GB.ApplyRareAlertLockState()
    if alertWindow == nil
        or GB.savedVariables == nil then
        return
    end

    local isLocked =
        GB.savedVariables.isLocked
        == true

    alertWindow:SetMovable(
        not isLocked
    )
end

------------------------------------------------------------
-- DEFAULT POSITION
------------------------------------------------------------

local function ApplyDefaultRareAlertPosition()
    if alertWindow == nil then
        return
    end

    alertWindow:ClearAnchors()

    alertWindow:SetAnchor(
        CENTER,
        GuiRoot,
        CENTER,
        0,
        -220
    )
end

------------------------------------------------------------
-- RESET ALERT POSITION
------------------------------------------------------------

function GB.ResetRareAlertPosition()
    if GB.savedVariables then
        GB.savedVariables.rareAlertLeft = nil
        GB.savedVariables.rareAlertTop = nil
    end

    ApplyDefaultRareAlertPosition()
end

------------------------------------------------------------
-- STOP FADE UPDATE
------------------------------------------------------------

local function StopFadeUpdate()
    EVENT_MANAGER:UnregisterForUpdate(
        FADE_UPDATE_NAME
    )

    fadeStartTime = nil
    fadeEndTime = nil
end

------------------------------------------------------------
-- CLEAR ALERT ROWS
------------------------------------------------------------

local function ClearDisplayedRows()
    for _, row in ipairs(
        alertRows
    ) do
        if row.nameLabel then
            row.nameLabel:SetText("")
        end

        if row.quantityLabel then
            row.quantityLabel:SetText("")
        end

        row.nameLabel:SetHidden(true)
        row.quantityLabel:SetHidden(true)
    end
end

------------------------------------------------------------
-- HIDE ALERT
------------------------------------------------------------

function GB.HideRareAlert()
    StopFadeUpdate()

    if alertWindow then
        alertWindow:SetAlpha(1)
    end

    ApplyRareAlertVisibility(
        true
    )
end

------------------------------------------------------------
-- CLEAR ALERT FEED
------------------------------------------------------------

function GB.ClearRareAlertFeed()
    alertEntries = {}

    ClearDisplayedRows()

    GB.HideRareAlert()
end

------------------------------------------------------------
-- RENDER ALERT ROWS
------------------------------------------------------------

local function RenderAlertEntries(entries)
    if alertWindow == nil then
        return
    end

    for index = 1, MAX_ALERT_ROWS do
        local row =
            alertRows[index]

        local entry =
            entries[index]

        if row and entry then
            local fontSize

            if index == 1 then
                fontSize =
                    CURRENT_FONT_SIZE
            else
                fontSize =
                    PREVIOUS_FONT_SIZE
            end

            local font =
                GetAlertFont(
                    fontSize
                )

            row.nameLabel:SetFont(
                font
            )

            row.quantityLabel:SetFont(
                font
            )

            local quality =
                entry.quality
                or ITEM_QUALITY_LEGENDARY

            local qualityColor =
                GetItemQualityColor(
                    quality
                )

            row.nameLabel:SetText(
                qualityColor:Colorize(
                    entry.name or "-"
                )
            )

            row.quantityLabel:SetText(
                qualityColor:Colorize(
                    "x"
                        .. tostring(
                            entry.quantity
                            or 0
                        )
                )
            )

            row.nameLabel:SetHidden(
                false
            )

            row.quantityLabel:SetHidden(
                false
            )
        elseif row then
            row.nameLabel:SetHidden(
                true
            )

            row.quantityLabel:SetHidden(
                true
            )
        end
    end
end

------------------------------------------------------------
-- START ALERT TIMER
------------------------------------------------------------

local function StartAlertTimer(
    displayDuration
)
    if alertWindow == nil then
        return
    end

    StopFadeUpdate()

    local duration =
        tonumber(
            displayDuration
        )
        or GetAlertDuration()

    local now =
        GetFrameTimeMilliseconds()

    fadeStartTime =
        now
        + (
            duration
            * 1000
        )

    fadeEndTime =
        fadeStartTime
        + (
            FADE_DURATION
            * 1000
        )

    alertWindow:SetAlpha(1)

    EVENT_MANAGER:RegisterForUpdate(
        FADE_UPDATE_NAME,
        50,
        function()
            if alertWindow == nil
                or fadeStartTime == nil
                or fadeEndTime == nil then

                StopFadeUpdate()
                return
            end

            local currentTime =
                GetFrameTimeMilliseconds()

            if currentTime
                < fadeStartTime then
                return
            end

            local fadeLength =
                fadeEndTime
                - fadeStartTime

            local progress =
                (
                    currentTime
                    - fadeStartTime
                )
                / fadeLength

            progress =
                math.max(
                    0,
                    math.min(
                        1,
                        progress
                    )
                )

            alertWindow:SetAlpha(
                1 - progress
            )

            if progress >= 1 then
                StopFadeUpdate()

                alertWindow:SetAlpha(
                    1
                )

                ApplyRareAlertVisibility(
                    true
                )

                ------------------------------------------------
                -- START NEXT ALERT BURST CLEAN
                ------------------------------------------------

                alertEntries = {}

                ClearDisplayedRows()
            end
        end
    )
end

------------------------------------------------------------
-- SHOW RARE MATERIAL ALERT
------------------------------------------------------------

function GB.ShowRareMaterialAlert(
    itemId,
    itemName,
    quantity,
    itemQuality
)
    if alertWindow == nil then
        return
    end

    if not IsRareAlertEnabled() then
        return
    end

    --------------------------------------------------------
    -- ONLY LEGENDARY / GOLD MATERIALS
    --------------------------------------------------------

    if itemQuality
        ~= ITEM_QUALITY_LEGENDARY then
        return
    end

    quantity =
        tonumber(quantity)
        or 0

    if quantity <= 0 then
        return
    end

    --------------------------------------------------------
    -- SAME ITEM ALREADY IN CURRENT FEED
    --------------------------------------------------------

    local existingEntry = nil
    local existingIndex = nil

    for index, entry in ipairs(
        alertEntries
    ) do
        if entry.itemId == itemId then
            existingEntry = entry
            existingIndex = index
            break
        end
    end

    if existingEntry then
        existingEntry.quantity =
            (
                existingEntry.quantity
                or 0
            )
            + quantity

        table.remove(
            alertEntries,
            existingIndex
        )

        table.insert(
            alertEntries,
            1,
            existingEntry
        )
    else
        ----------------------------------------------------
        -- NEW RARE MATERIAL
        ----------------------------------------------------

        table.insert(
            alertEntries,
            1,
            {
                itemId = itemId,
                name = itemName,
                quantity = quantity,
                quality = itemQuality,
            }
        )
    end

    --------------------------------------------------------
    -- KEEP MAXIMUM THREE ROWS
    --------------------------------------------------------

    while #alertEntries
        > MAX_ALERT_ROWS do

        table.remove(
            alertEntries
        )
    end

    --------------------------------------------------------
    -- DISPLAY
    --------------------------------------------------------

    RenderAlertEntries(
        alertEntries
    )

    alertWindow:SetAlpha(
        1
    )

    ApplyRareAlertVisibility(
        false
    )

    --------------------------------------------------------
    -- EVERY NEW RARE RESTARTS TIMER
    --------------------------------------------------------

    StartAlertTimer(
        GetAlertDuration()
    )
end

------------------------------------------------------------
-- POSITION / PREVIEW MODE
------------------------------------------------------------

function GB.PreviewRareAlert()
    if alertWindow == nil then
        return
    end

    local previewEntries = {
        {
            itemId = -1,
            name = "Perfect Roe",
            quantity = 1,
            quality = ITEM_QUALITY_LEGENDARY,
        },
        {
            itemId = -2,
            name = "Kuta",
            quantity = 2,
            quality = ITEM_QUALITY_LEGENDARY,
        },
        {
            itemId = -3,
            name = "Dreugh Wax",
            quantity = 1,
            quality = ITEM_QUALITY_LEGENDARY,
        },
    }

    RenderAlertEntries(
        previewEntries
    )

    alertWindow:SetAlpha(
        1
    )

    ApplyRareAlertVisibility(
        false
    )

    --------------------------------------------------------
    -- PREVIEW STAYS LONGER SO IT CAN BE MOVED
    --------------------------------------------------------

    StartAlertTimer(
        10
    )
end

------------------------------------------------------------
-- CREATE RARE ALERT WINDOW
------------------------------------------------------------

function GB.CreateRareAlertWindow()
    if alertWindow ~= nil then
        return
    end

    alertWindow =
        WINDOW_MANAGER:
            CreateTopLevelWindow(
                "GatherBuddyRareAlertWindow"
            )

    GB.rareAlertWindow =
        alertWindow

    alertWindow:SetDimensions(
        ALERT_WIDTH,
        ALERT_HEIGHT
    )

    alertWindow:SetMovable(
        true
    )

    alertWindow:SetMouseEnabled(
        true
    )

    alertWindow:SetClampedToScreen(
        true
    )

    --------------------------------------------------------
    -- SAVED POSITION
    --------------------------------------------------------

    if GB.savedVariables
        and GB.savedVariables.rareAlertLeft
        and GB.savedVariables.rareAlertTop then

        alertWindow:SetAnchor(
            TOPLEFT,
            GuiRoot,
            TOPLEFT,
            GB.savedVariables.rareAlertLeft,
            GB.savedVariables.rareAlertTop
        )
    else
        ApplyDefaultRareAlertPosition()
    end

    --------------------------------------------------------
    -- MOVE ALERT WINDOW
    --------------------------------------------------------

    alertWindow:SetHandler(
        "OnMouseDown",
        function(self, button)
            if button
                == MOUSE_BUTTON_INDEX_LEFT
                and GB.savedVariables
                and GB.savedVariables.isLocked
                    ~= true then

                alertWindow:
                    StartMoving()
            end
        end
    )

    alertWindow:SetHandler(
        "OnMouseUp",
        function(self, button)
            if button
                == MOUSE_BUTTON_INDEX_LEFT then

                alertWindow:
                    StopMovingOrResizing()

                if GB.savedVariables then
                    GB.savedVariables.rareAlertLeft =
                        alertWindow:GetLeft()

                    GB.savedVariables.rareAlertTop =
                        alertWindow:GetTop()
                end
            end
        end
    )

    --------------------------------------------------------
    -- BACKGROUND
    --------------------------------------------------------

    alertBackground =
        WINDOW_MANAGER:CreateControl(
            "GatherBuddyRareAlertBackground",
            alertWindow,
            CT_BACKDROP
        )

    alertBackground:SetAnchorFill()

    alertBackground:SetCenterColor(
        0,
        0,
        0,
        0.75
    )

    alertBackground:SetEdgeColor(
        0.4,
        0.4,
        0.4,
        1
    )

    alertBackground:SetEdgeTexture(
        "",
        1,
        1,
        1
    )

    --------------------------------------------------------
    -- ALERT ROWS
    --------------------------------------------------------

    local rowYPositions = {
        7,
        37,
        61,
    }

    for index = 1, MAX_ALERT_ROWS do
        local nameLabel =
            WINDOW_MANAGER:CreateControl(
                "GatherBuddyRareAlertName"
                    .. tostring(index),
                alertWindow,
                CT_LABEL
            )

        nameLabel:SetAnchor(
            TOPLEFT,
            alertWindow,
            TOPLEFT,
            12,
            rowYPositions[index]
        )

        nameLabel:SetWidth(
            275
        )

        nameLabel:SetHidden(
            true
        )

        local quantityLabel =
            WINDOW_MANAGER:CreateControl(
                "GatherBuddyRareAlertQuantity"
                    .. tostring(index),
                alertWindow,
                CT_LABEL
            )

        quantityLabel:SetAnchor(
            TOPRIGHT,
            alertWindow,
            TOPRIGHT,
            -12,
            rowYPositions[index]
        )

        quantityLabel:SetWidth(
            55
        )

        quantityLabel:SetHorizontalAlignment(
            TEXT_ALIGN_RIGHT
        )

        quantityLabel:SetHidden(
            true
        )

        alertRows[index] = {
            nameLabel = nameLabel,
            quantityLabel = quantityLabel,
        }
    end

    --------------------------------------------------------
    -- DRAG SURFACE
    --------------------------------------------------------

    local dragSurface =
        WINDOW_MANAGER:CreateControl(
            "GatherBuddyRareAlertDragSurface",
            alertWindow,
            CT_CONTROL
        )

    dragSurface:SetAnchorFill()
    dragSurface:SetMouseEnabled(true)

    dragSurface:SetHandler(
        "OnMouseDown",
        function(self, button)
            if button == MOUSE_BUTTON_INDEX_LEFT
                and GB.savedVariables
                and GB.savedVariables.isLocked ~= true then

                alertWindow:StartMoving()
            end
        end
    )

    dragSurface:SetHandler(
        "OnMouseUp",
        function(self, button)
            if button == MOUSE_BUTTON_INDEX_LEFT then

                alertWindow:StopMovingOrResizing()

                if GB.savedVariables then
                    GB.savedVariables.rareAlertLeft =
                        alertWindow:GetLeft()

                    GB.savedVariables.rareAlertTop =
                        alertWindow:GetTop()
                end
            end
        end
    )

    --------------------------------------------------------
    -- CURRENT SETTINGS
    --------------------------------------------------------

    GB.ApplyRareAlertBackgroundTransparency()
    GB.ApplyRareAlertLockState()

    --------------------------------------------------------
    -- HUD SCENE INTEGRATION
    --------------------------------------------------------

    SetupRareAlertSceneFragment()

    --------------------------------------------------------
    -- START HIDDEN
    --------------------------------------------------------

    ApplyRareAlertVisibility(
        true
    )
end