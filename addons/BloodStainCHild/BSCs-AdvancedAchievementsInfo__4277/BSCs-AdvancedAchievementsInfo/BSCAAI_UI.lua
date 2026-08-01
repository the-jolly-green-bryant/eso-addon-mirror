BSCAAchievemntsInfo = BSCAAchievemntsInfo or {}
local BSCAAI = BSCAAchievemntsInfo

local MAX_TRACKED_PER_SCOPE = 10
local DEFAULT_SCROLLBAR_WIDTH = 16
local EMPTY_TEXT = ""
local DEFAULT_TRACKING_FONT_SIZE = 18
local MIN_TRACKING_FONT_SIZE = 12
local MAX_TRACKING_FONT_SIZE = 54

local function FontCheck(size)
    size = math.floor((tonumber(size) or DEFAULT_TRACKING_FONT_SIZE) + 0.5)

    local new_size = size
    if size > 54 then new_size = 54 end
    if size > 48 and size < 54 then new_size = 48 end
    if size > 40 and size < 48 then new_size = 40 end
    if size > 36 and size < 40 then new_size = 36 end
    if size > 34 and size < 36 then new_size = 34 end
    if size > 32 and size < 34 then new_size = 32 end
    if size > 30 and size < 32 then new_size = 30 end
    if size > 28 and size < 30 then new_size = 28 end
    if size > 26 and size < 28 then new_size = 26 end

    return new_size
end
BSCAAI.FontCheck = FontCheck

local function ClampTrackingFontSize(value)
    value = tonumber(value) or DEFAULT_TRACKING_FONT_SIZE

    if value < MIN_TRACKING_FONT_SIZE then
        return MIN_TRACKING_FONT_SIZE
    elseif value > MAX_TRACKING_FONT_SIZE then
        return MAX_TRACKING_FONT_SIZE
    end

    return math.floor(value + 0.5)
end

local function GetValidTrackingFontSize(value)
    return FontCheck(ClampTrackingFontSize(value))
end

function BSCAAI:GetTrackingUIFontSize()
    if not BSCAAI.SV_CHAR then
        return DEFAULT_TRACKING_FONT_SIZE
    end

    return GetValidTrackingFontSize(BSCAAI.SV_CHAR.UI_FONT_SIZE)
end

local function BuildTrackingFont(sizeOffset, weight)
    local fontFace = select(1, ZoFontGame:GetFontInfo())
    local size = GetValidTrackingFontSize(BSCAAI:GetTrackingUIFontSize() + (sizeOffset or 0))

    return string.format("%s|$(KB_%d)|%s", fontFace, size, weight or "soft-shadow-thin")
end

local function GetTrackingFonts()
    local size = BSCAAI:GetTrackingUIFontSize()

    if BSCAAI._trackingFonts and BSCAAI._trackingFonts.size == size then
        return BSCAAI._trackingFonts
    end

    BSCAAI._trackingFonts = {
        size = size,
        windowTitle = BuildTrackingFont(5, "soft-shadow-thick"),
        header = BuildTrackingFont(4, "soft-shadow-thick"),
        title = BuildTrackingFont(2, "soft-shadow-thin"),
        body = BuildTrackingFont(0, "soft-shadow-thin"),
    }

    return BSCAAI._trackingFonts
end

local function SetFontIfChanged(control, font)
    if control and control._bscaaiFont ~= font then
        control:SetFont(font)
        control._bscaaiFont = font
    end
end

local function QueueFavWidgetUpdate(delay)
    if BSCAAI.QueueFavWidgetUpdate then
        BSCAAI.QueueFavWidgetUpdate(delay or 1)
    else
        BSCAAI.UpdateFavWidget()
    end
end

function BSCAAI:InitTrackingUI()
    BSCAAI.TrackingFragment = ZO_SimpleSceneFragment:New(BSCAAI_FavWidget)
    BSCAAI:RestoreFavWidgetPosition()
    BSCAAI:AdjustTrackingLayout()
    BSCAAI:UpdateSettings()
    QueueFavWidgetUpdate(1)
end

function BSCAAI:UpdateSettings()
    if not BSCAAI.TrackingFragment then return end

    if BSCAAI.SV_CHAR.UI_ENABLE then
        SCENE_MANAGER:GetScene("hud"):AddFragment(BSCAAI.TrackingFragment)
        SCENE_MANAGER:GetScene("hudui"):AddFragment(BSCAAI.TrackingFragment)
        QueueFavWidgetUpdate(1)
    else
        SCENE_MANAGER:GetScene("hud"):RemoveFragment(BSCAAI.TrackingFragment)
        SCENE_MANAGER:GetScene("hudui"):RemoveFragment(BSCAAI.TrackingFragment)
        if BSCAAI_FavWidget then
            BSCAAI_FavWidget:SetHidden(true)
        end
    end
end

function BSCAAI:SetTrackingWindowEnabled(enabled)
    if not BSCAAI.SV_CHAR then return end

    enabled = enabled and true or false
    BSCAAI.SV_CHAR.UI_ENABLE = enabled

    if BSCAAI.AchievementUICheckbox then
        ZO_CheckButton_SetCheckState(BSCAAI.AchievementUICheckbox, enabled)
    end

    BSCAAI:UpdateSettings()

    if enabled then
        QueueFavWidgetUpdate(1)
    elseif BSCAAI_FavWidget then
        BSCAAI_FavWidget:SetHidden(true)
    end
end

function BSCAAI.ToggleTrackingWindow()
    if not BSCAAI.SV_CHAR then return end
    BSCAAI:SetTrackingWindowEnabled(not BSCAAI.SV_CHAR.UI_ENABLE)
end

function BSCAAI.OnFavWidgetMoveStop()
    local left, top = BSCAAI_FavWidget:GetLeft(), BSCAAI_FavWidget:GetTop()
    BSCAAI.SV_CHAR.UI_X = left
    BSCAAI.SV_CHAR.UI_Y = top
end

function BSCAAI.OnFavWidgetResizeStop()
    local width, height = BSCAAI_FavWidget:GetDimensions()
    BSCAAI.SV_CHAR.UI_WIDTH = width
    BSCAAI.SV_CHAR.UI_HEIGHT = height
    BSCAAI:AdjustTrackingLayout()
    QueueFavWidgetUpdate(1)
    BSCAAI.OnFavWidgetMoveStop()
end

function BSCAAI:RestoreFavWidgetPosition()
    local x = BSCAAI.SV_CHAR.UI_X
    local y = BSCAAI.SV_CHAR.UI_Y
    local width = BSCAAI.SV_CHAR.UI_WIDTH or 400
    local height = BSCAAI.SV_CHAR.UI_HEIGHT or 300

    if not x or not y then
        local screenWidth, screenHeight = GuiRoot:GetDimensions()
        local widgetWidth = BSCAAI_FavWidget:GetWidth()
        local widgetHeight = BSCAAI_FavWidget:GetHeight()

        x = screenWidth - widgetWidth
        y = (screenHeight / 2) - (widgetHeight / 2)

        BSCAAI.SV_CHAR.UI_X = x
        BSCAAI.SV_CHAR.UI_Y = y
    end

    BSCAAI_FavWidget:ClearAnchors()
    BSCAAI_FavWidget:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
    BSCAAI_FavWidget:SetDimensions(width, height)
    BSCAAI_FavWidget:SetResizeToFitDescendents(false)
end

function BSCAAI:AdjustTrackingLayout()
    local win = BSCAAI_FavWidget
    if not win then return 0 end

    local list = win:GetNamedChild("List")
    if not list then return 0 end

    local child = list:GetNamedChild("ScrollChild")
    if not child then return 0 end

    local padL, padR = 10, 10
    local avail = math.max(100, win:GetWidth() - (padL + padR))
    local fonts = GetTrackingFonts()

    local title = win:GetNamedChild("Title")
    if title then
        SetFontIfChanged(title, fonts.windowTitle)
        title:ClearAnchors()
        title:SetAnchor(TOPLEFT, win, TOPLEFT, padL, 10)
        title:SetAnchor(TOPRIGHT, win, TOPRIGHT, -padR, 10)
        title:SetWrapMode(TEXT_WRAP_MODE_NORMAL)
        title:SetMaxLineCount(2)
    end

    local titleHeight = title and math.max(30, title:GetTextHeight()) or 30
    list:ClearAnchors()
    list:SetAnchor(TOPLEFT, win, TOPLEFT, padL, 10 + titleHeight + 6)
    list:SetAnchor(BOTTOMRIGHT, win, BOTTOMRIGHT, -padR, -10)

    child:SetWidth(avail)
    return avail
end

local function HideControl(control)
    if control then
        control:SetHidden(true)
        control:ClearAnchors()
    end
end

local function AcquireHeader(parent, index)
    BSCAAI._favHeaderPool = BSCAAI._favHeaderPool or {}
    local header = BSCAAI._favHeaderPool[index]

    if not header then
        header = WINDOW_MANAGER:CreateControl(nil, parent, CT_LABEL)
        header:SetFont("ZoFontWinH3")
        header:SetColor(1, 0.85, 0.2, 1)
        header:SetWrapMode(TEXT_WRAP_MODE_NORMAL)
        header:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        BSCAAI._favHeaderPool[index] = header
    else
        header:SetParent(parent)
    end

    SetFontIfChanged(header, GetTrackingFonts().header)
    header:SetHidden(false)
    header:ClearAnchors()
    return header
end

local function AcquireEntry(parent, index)
    BSCAAI._favEntryPool = BSCAAI._favEntryPool or {}
    local entry = BSCAAI._favEntryPool[index]

    if not entry then
        entry = WINDOW_MANAGER:CreateControl(nil, parent, CT_CONTROL)
        entry.critLines = {}

        entry.head = WINDOW_MANAGER:CreateControl(nil, entry, CT_CONTROL)
        entry.head:SetAnchor(TOPLEFT, entry, TOPLEFT, 0, 0)
        entry.head:SetAnchor(TOPRIGHT, entry, TOPRIGHT, 0, 0)

        entry.icon = WINDOW_MANAGER:CreateControl(nil, entry.head, CT_TEXTURE)
        entry.icon:SetDimensions(24, 24)
        entry.icon:SetAnchor(TOPLEFT, entry.head, TOPLEFT, 0, 0)

        entry.progress = WINDOW_MANAGER:CreateControl(nil, entry.head, CT_LABEL)
        entry.progress:SetFont("ZoFontGame")
        entry.progress:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        entry.progress:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
        entry.progress:SetAnchor(TOPRIGHT, entry.head, TOPRIGHT, 0, 0)

        entry.title = WINDOW_MANAGER:CreateControl(nil, entry.head, CT_LABEL)
        entry.title:SetFont("ZoFontWinH4")
        entry.title:SetWrapMode(TEXT_WRAP_MODE_NORMAL)
        entry.title:SetMaxLineCount(0)
        entry.title:SetHorizontalAlignment(TEXT_ALIGN_LEFT)

        BSCAAI._favEntryPool[index] = entry
    else
        entry:SetParent(parent)
    end

    local fonts = GetTrackingFonts()
    SetFontIfChanged(entry.title, fonts.title)
    SetFontIfChanged(entry.progress, fonts.body)

    entry.parent = parent
    entry:SetHidden(false)
    entry:ClearAnchors()
    return entry
end

local function AcquireCriterionLine(entry, index)
    local line = entry.critLines[index]
    if not line then
        line = WINDOW_MANAGER:CreateControl(nil, entry, CT_LABEL)
        line:SetFont("ZoFontGame")
        line:SetWrapMode(TEXT_WRAP_MODE_NORMAL)
        line:SetMaxLineCount(0)
        line:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        entry.critLines[index] = line
    end

    SetFontIfChanged(line, GetTrackingFonts().body)
    line:SetHidden(false)
    line:ClearAnchors()
    return line
end

local function ResolveVisibleAchievementId(id)
    while IsAchievementComplete(id) do
        local nextId = GetNextAchievementInLine(id)
        if nextId == 0 then return nil end
        id = nextId
    end

    return id
end

local function UpdateEntry(entry, id, yOffset, maxWidth)
    local visibleId = ResolveVisibleAchievementId(id)
    if not visibleId then
        entry:SetHidden(true)
        return 0
    end

    local iconSize = 24
    local gap = 6
    local name, _, _, icon = GetAchievementInfo(visibleId)
    local numCriteria = GetAchievementNumCriteria(visibleId)
    local done, total = 0, 0

    for i = 1, numCriteria do
        local _, d, t = GetAchievementCriterion(visibleId, i)
        done = done + (d or 0)
        total = total + (t or 0)
    end

    entry:SetAnchor(TOPLEFT, entry.parent, TOPLEFT, 0, yOffset)
    entry:SetWidth(maxWidth)

    entry.head:SetHeight(iconSize)
    entry.icon:SetTexture(icon)

    entry.progress:SetText(zo_strformat("<<1>> / <<2>>", done, total))
    local progressWidth = math.max(50, entry.progress:GetTextWidth() + 10)

    local usableWidth = maxWidth - iconSize - progressWidth - (3 * gap)
    if usableWidth < 100 then usableWidth = 100 end

    entry.title:ClearAnchors()
    entry.title:SetWidth(usableWidth)
    entry.title:SetAnchor(TOPLEFT, entry.icon, TOPRIGHT, gap, 0)
    entry.title:SetText(zo_strformat(name) or EMPTY_TEXT)

    local headHeight = math.max(entry.title:GetTextHeight(), iconSize)
    entry.head:SetHeight(headHeight)

    local totalHeight = headHeight
    local previous = entry.head

    local hideCompletedCriteria = BSCAAI.SV_CHAR.UI_HIDE_COMPLETED_CRITERIA ~= false
    local usedCriteriaLines = 0

    for i = 1, numCriteria do
        local critText, numDone, numNeed, isDone = GetAchievementCriterion(visibleId, i)
        local bCompleted = isDone or ((numDone or 0) >= (numNeed or 0))

        if not hideCompletedCriteria or not bCompleted then
            usedCriteriaLines = usedCriteriaLines + 1

            local line = AcquireCriterionLine(entry, usedCriteriaLines)
            line:SetWidth(maxWidth - 10)
            line:SetAnchor(TOPLEFT, previous, BOTTOMLEFT, 0, 4)
            line:SetText(zo_strformat("<<1>> (<<2>>/<<3>>)", critText or EMPTY_TEXT, numDone or 0, numNeed or 0))

            if bCompleted then
                line:SetColor(0, 1, 0, 1)
            else
                line:SetColor(1, 1, 1, 1)
            end

            previous = line
            totalHeight = totalHeight + line:GetTextHeight() + 4
        end
    end

    for i = usedCriteriaLines + 1, #entry.critLines do
        HideControl(entry.critLines[i])
    end

    entry:SetHeight(totalHeight)
    return totalHeight
end

local function HideUnusedPool(usedHeaders, usedEntries)
    if BSCAAI._favHeaderPool then
        for i = usedHeaders + 1, #BSCAAI._favHeaderPool do
            HideControl(BSCAAI._favHeaderPool[i])
        end
    end

    if BSCAAI._favEntryPool then
        for i = usedEntries + 1, #BSCAAI._favEntryPool do
            local entry = BSCAAI._favEntryPool[i]
            HideControl(entry)
            if entry and entry.critLines then
                for _, line in ipairs(entry.critLines) do
                    HideControl(line)
                end
            end
        end
    end
end

function BSCAAI.UpdateFavWidget() -- /script BSCAAchievemntsInfo.UpdateFavWidget()
    if not BSCAAI.SV_CHAR then return end
    if not BSCAAI.SV_CHAR.UI_ENABLE and not BSCAAI._menuPanelOpen then return end

    local window = BSCAAI_FavWidget
    if not window then return end

    BSCAAI:AdjustTrackingLayout()

    local list = window:GetNamedChild("List")
    if not list then return end

    local listContainer = list:GetNamedChild("ScrollChild")
    if not listContainer then return end

    local scrollBar = list:GetNamedChild("ScrollBar")
    local sbWidth = (scrollBar and scrollBar:GetWidth()) or DEFAULT_SCROLLBAR_WIDTH
    local sidePadding = 10

    local availWidth = list:GetWidth() - sbWidth - sidePadding
    if availWidth <= 0 then
        availWidth = window:GetWidth() - sbWidth - 2 * sidePadding
    end
    availWidth = math.max(100, availWidth)

    local accountTrack, charTrack = BSCAAI:GetTrackingSplit()
    if #accountTrack == 0 and #charTrack == 0 then
        listContainer:SetHeight(0)
        HideUnusedPool(0, 0)
        return
    end

    local yOffset = 0
    local usedHeaders = 0
    local usedEntries = 0

    local function AddHeader(text)
        usedHeaders = usedHeaders + 1
        local header = AcquireHeader(listContainer, usedHeaders)
        header:SetAnchor(TOPLEFT, listContainer, TOPLEFT, 0, yOffset)
        header:SetWidth(availWidth)
        header:SetText(text)

        local headerHeight = header:GetTextHeight()
        yOffset = yOffset + headerHeight + 8
    end

    local function AddTrackedList(title, trackList)
        if #trackList == 0 then return end

        AddHeader(title)
        for i = 1, math.min(MAX_TRACKED_PER_SCOPE, #trackList) do
            usedEntries = usedEntries + 1
            local entry = AcquireEntry(listContainer, usedEntries)
            local height = UpdateEntry(entry, trackList[i], yOffset, availWidth)
            if height > 0 then
                yOffset = yOffset + height + 10
            end
        end
    end

    AddTrackedList("Account Tracking", accountTrack)
    AddTrackedList("Character Tracking", charTrack)

    HideUnusedPool(usedHeaders, usedEntries)
    listContainer:SetHeight(yOffset)
end
