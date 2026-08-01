-- TraitTimer.UI - HUD Display Manager
-- Handles dynamic creation of research rows, timer label updates, colors, resize
-- Supports two view modes: "timers" (active research) and "missing" (unresearched traits)
-- Scrollable content area via ZO_ScrollContainer

TraitTimer = TraitTimer or {}
TraitTimer.UI = TraitTimer.UI or {}

local TT = TraitTimer
local UI = TT.UI

UI.craftSections = {}
UI.rowPool = {}

local ROW_HEIGHT = 20
local ROW_SPACING = 4
local HEADER_HEIGHT = 22
local SECTION_SPACING = 16
local CONTENT_PADDING = 6
local HEADER_BAR_HEIGHT = 24
local COL_HEADERS_HEIGHT = 20

-- Column layout
local LEFT_PADDING = 24
local RIGHT_PADDING = 12
local COL_GAP = 4

-- Margin around scroll content to keep resize handles accessible
local RESIZE_INSET = 6

---------------------------------------------------------------------------
-- Color constants
---------------------------------------------------------------------------

local COLOR_ITEM         = { 0.8,  0.8,  0.8,  1 }
local COLOR_TRAIT        = { 0.67, 0.67, 0.67, 1 }
local COLOR_TRAIT_OWNED  = { 0.4,  0.8,  1.0,  1 }
local COLOR_TRAIT_MISSING = { 0.7,  0.7,  0.7,  1 }
local COLOR_SLOTS_FULL   = { 0.6,  0.6,  0.6,  1 }
local COLOR_SLOTS_FREE   = { 0.2,  1.0,  0.2,  1 }
local COLOR_MISSING_NONE = { 0.2,  1.0,  0.2,  1 }
local COLOR_MISSING_SOME = { 1.0,  0.8,  0.0,  1 }

local function SetColor(control, color)
    control:SetColor(color[1], color[2], color[3], color[4])
end

---------------------------------------------------------------------------
-- Color thresholds for timer labels
---------------------------------------------------------------------------

local function GetTimerColor(seconds)
    if seconds <= 0 then
        return 0.0, 1.0, 0.0, 1.0
    elseif seconds < 3600 then
        return 0.2, 1.0, 0.2, 1.0
    elseif seconds < 21600 then
        return 0.6, 1.0, 0.2, 1.0
    elseif seconds < 86400 then
        return 1.0, 0.8, 0.0, 1.0
    elseif seconds < 259200 then
        return 1.0, 0.5, 0.2, 1.0
    else
        return 1.0, 0.3, 0.3, 1.0
    end
end

---------------------------------------------------------------------------
-- Color for missing trait counts
---------------------------------------------------------------------------

local function GetMissingColor(missingCount, totalTraits)
    local ratio = missingCount / totalTraits
    if ratio <= 0 then
        return 0.2, 1.0, 0.2, 1.0
    elseif ratio <= 0.25 then
        return 0.6, 1.0, 0.2, 1.0
    elseif ratio <= 0.5 then
        return 1.0, 0.8, 0.0, 1.0
    else
        return 1.0, 0.5, 0.2, 1.0
    end
end

---------------------------------------------------------------------------
-- Scroll Child Access
---------------------------------------------------------------------------

function UI:GetScrollChild()
    local content = TraitTimerHUDContent
    if content then
        return content:GetNamedChild("ScrollChild")
    end
    return nil
end

---------------------------------------------------------------------------
-- Empty Label (created dynamically since Content is a ScrollContainer)
---------------------------------------------------------------------------

function UI:EnsureEmptyLabel()
    if self.emptyLabel then return self.emptyLabel end
    local scrollChild = self:GetScrollChild()
    if not scrollChild then return nil end
    self.emptyLabel = CreateControl("TraitTimerEmptyLabel", scrollChild, CT_LABEL)
    self.emptyLabel:SetFont("ZoFontGameSmall")
    self.emptyLabel:SetColor(0.4, 0.4, 0.4, 1)
    self.emptyLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.emptyLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.emptyLabel:SetDimensions(self:GetContentWidth(), 20)
    self.emptyLabel:SetHidden(true)
    return self.emptyLabel
end

---------------------------------------------------------------------------
-- Widget Width & Column Width Management
---------------------------------------------------------------------------

function UI:GetWidth()
    local sv = TT.sv
    if sv then
        return sv.widgetWidth or 420
    end
    return 420
end

function UI:GetContentWidth()
    return self:GetWidth() - (RESIZE_INSET * 2)
end

-- Returns equal column widths (1/3 each)
function UI:GetColumnWidths()
    local rowWidth = self:GetContentWidth() - 10
    local usable = rowWidth - LEFT_PADDING - RIGHT_PADDING - (COL_GAP * 2)
    local colW = math.floor(usable / 3)
    return colW, colW, colW
end

function UI:ApplyWidth(width)
    local hud = TraitTimerHUD
    if not hud then return end

    -- Enforce minimum width
    local minW = TT.MIN_WIDGET_WIDTH or 270
    if width < minW then width = minW end

    hud:SetWidth(width)

    local header = TraitTimerHUDHeader
    if header then header:SetWidth(width) end

    -- Keep the title clear of the View/Minimize buttons on the right (~52px)
    local title = TraitTimerHUDHeaderTitle
    if title then title:SetWidth(math.max(60, width - 64)) end

    local colHeaders = TraitTimerHUDColHeaders
    if colHeaders then colHeaders:SetWidth(width) end

    local contentWidth = width - (RESIZE_INSET * 2)
    local content = TraitTimerHUDContent
    if content then content:SetWidth(contentWidth) end

    local scrollChild = self:GetScrollChild()
    if scrollChild then scrollChild:SetWidth(contentWidth) end

    local itemW, traitW, timerW = self:GetColumnWidths()

    local colItem = TraitTimerHUDColHeadersColItem
    if colItem then
        colItem:SetWidth(itemW)
        colItem:ClearAnchors()
        colItem:SetAnchor(LEFT, TraitTimerHUDColHeaders, LEFT, RESIZE_INSET + LEFT_PADDING, 0)
        colItem:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    end

    local colTrait = TraitTimerHUDColHeadersColTrait
    if colTrait then
        colTrait:SetWidth(traitW)
        colTrait:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    end

    local colTimer = TraitTimerHUDColHeadersColTimer
    if colTimer and colTrait then
        colTimer:SetWidth(timerW)
        colTimer:ClearAnchors()
        colTimer:SetAnchor(LEFT, colTrait, RIGHT, COL_GAP, 0)
        colTimer:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    end
end

---------------------------------------------------------------------------
-- Row Pool Management
---------------------------------------------------------------------------

local rowCounter = 0

function UI:GetRow(parent)
    for _, row in ipairs(self.rowPool) do
        if row:IsHidden() then
            row:SetParent(parent)
            row:SetHidden(false)
            return row
        end
    end

    rowCounter = rowCounter + 1
    local rowName = "TraitTimerRow" .. rowCounter
    local row = CreateControlFromVirtual(rowName, parent, "TraitTimerResearchRow")
    table.insert(self.rowPool, row)
    return row
end

function UI:ReleaseAllRows()
    for _, row in ipairs(self.rowPool) do
        row:SetHidden(true)
        row:ClearAnchors()
    end
end

---------------------------------------------------------------------------
-- Apply dynamic widths to a row's labels
---------------------------------------------------------------------------

function UI:ApplyRowWidths(row)
    local width = self:GetContentWidth()
    local itemW, traitW, timerW = self:GetColumnWidths()

    row:SetWidth(width - 10)

    local itemLabel = row:GetNamedChild("Item")
    local traitLabel = row:GetNamedChild("Trait")
    local timerLabel = row:GetNamedChild("Timer")

    if itemLabel then itemLabel:SetWidth(itemW) end
    if traitLabel then traitLabel:SetWidth(traitW) end
    if timerLabel then
        timerLabel:SetWidth(timerW)
        timerLabel:ClearAnchors()
        timerLabel:SetAnchor(LEFT, traitLabel, RIGHT, COL_GAP, 0)
        timerLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    end
end

---------------------------------------------------------------------------
-- Craft Section Management
---------------------------------------------------------------------------

function UI:GetOrCreateCraftSection(craftType, parent)
    if self.craftSections[craftType] then
        return self.craftSections[craftType]
    end

    local headerName = "TraitTimerCraftHdr" .. craftType
    local header = CreateControlFromVirtual(headerName, parent, "TraitTimerCraftHeader")

    self.craftSections[craftType] = {
        header = header,
        rows = {},
    }

    return self.craftSections[craftType]
end

---------------------------------------------------------------------------
-- Setup craft section header (shared between timers and missing modes)
---------------------------------------------------------------------------

function UI:SetupCraftHeader(section, craftInfo, scrollChild, width, yOffset, slotText, slotColor)
    local header = section.header
    header:SetWidth(width - 10)

    local iconControl = header:GetNamedChild("Icon")
    local nameControl = header:GetNamedChild("Name")
    local slotsControl = header:GetNamedChild("Slots")

    if iconControl then iconControl:SetTexture(craftInfo.icon) end
    if nameControl then nameControl:SetText(GetString(craftInfo.stringId)) end
    if slotsControl then
        slotsControl:SetText(slotText)
        SetColor(slotsControl, slotColor)
        -- Align with the 3rd column (Time/Missing)
        local _, _, timerW = self:GetColumnWidths()
        local timerX = LEFT_PADDING + (timerW + COL_GAP) * 2
        slotsControl:ClearAnchors()
        slotsControl:SetAnchor(LEFT, header, LEFT, timerX, 0)
        slotsControl:SetWidth(timerW)
        slotsControl:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    end

    header:ClearAnchors()
    header:SetAnchor(TOPLEFT, scrollChild, TOPLEFT, 0, yOffset)
    header:SetHidden(false)
end

---------------------------------------------------------------------------
-- Clear all rows and section headers
---------------------------------------------------------------------------

function UI:ClearContent()
    self:ReleaseAllRows()
    for _, section in pairs(self.craftSections) do
        section.header:SetHidden(true)
        section.header:ClearAnchors()
        section.rows = {}
    end
    if self.emptyLabel then
        self.emptyLabel:SetHidden(true)
    end
end

---------------------------------------------------------------------------
-- Finalize height: set scroll child height + widget/content height
---------------------------------------------------------------------------

function UI:FinalizeHeight(contentHeight)
    local sv = TT.sv
    local content = TraitTimerHUDContent
    local scrollChild = self:GetScrollChild()
    if not content or not scrollChild then return end

    -- Re-anchor content with left inset for resize handles
    local colHeaders = TraitTimerHUDColHeaders
    if colHeaders then
        content:ClearAnchors()
        content:SetAnchor(TOPLEFT, colHeaders, BOTTOMLEFT, RESIZE_INSET, 2)
    end

    -- Scroll child holds the full content; the container viewport may be smaller
    -- (then it scrolls) or larger (then it shows blank space below).
    scrollChild:SetHeight(contentHeight)

    local chromeHeight = HEADER_BAR_HEIGHT + COL_HEADERS_HEIGHT + RESIZE_INSET

    local widgetHeight
    if sv.widgetHeight then
        -- Manual height: keep exactly what the user set. "Reset position & size"
        -- clears widgetHeight to restore auto-fit.
        widgetHeight = sv.widgetHeight
    else
        -- Auto-fit to content, capped so a long list never runs off-screen; past
        -- the cap the content area scrolls instead of the widget growing.
        local maxAutoFit = math.min(TT.MAX_WIDGET_HEIGHT, math.floor(GuiRoot:GetHeight() * 0.9))
        widgetHeight = math.min(chromeHeight + contentHeight, maxAutoFit)
    end

    TraitTimerHUD:SetHeight(widgetHeight)
    content:SetHeight(math.max(20, widgetHeight - chromeHeight))

    -- Reset scroll position and update scrollbar to fix display after resize-while-hidden
    ZO_Scroll_ResetToTop(content)
    ZO_Scroll_UpdateScrollBar(content)
end

---------------------------------------------------------------------------
-- Apply background opacity
---------------------------------------------------------------------------

function UI:ApplyBgAlpha()
    local bg = TraitTimerHUDBG
    local sv = TT.sv
    if bg and sv then
        bg:SetAlpha((sv.bgAlpha or 80) / 100)
    end
end

---------------------------------------------------------------------------
-- Main Rebuild (routes to the right mode)
---------------------------------------------------------------------------

function UI:Rebuild()
    self:ApplyWidth(self:GetWidth())
    self:ApplyBgAlpha()

    -- Disable scroll fade gradient
    local content = TraitTimerHUDContent
    if content and ZO_Scroll_SetMaxFadeDistance then
        ZO_Scroll_SetMaxFadeDistance(content, 0)
    end

    -- Update title based on view mode
    local titleLabel = TraitTimerHUDHeaderTitle
    if titleLabel then
        if TT.viewMode == "missing" then
            titleLabel:SetText("TraitTimer - " .. GetString(TT_MODE_MISSING))
        else
            titleLabel:SetText("TraitTimer")
        end
    end

    -- When minimized: don't create rows, just update summary
    if TT.sv.minimized then
        self:ClearContent()

        local totalActive = 0
        for _, craftInfo in ipairs(TT.RESEARCH_CRAFTS) do
            local data = TT.researchData[craftInfo.type]
            if data then totalActive = totalActive + #data.entries end
        end
        self.totalActive = totalActive
        self:ApplyMinimizedState()
        return
    end

    -- Update column headers based on mode
    local colItem = TraitTimerHUDColHeadersColItem
    local colTrait = TraitTimerHUDColHeadersColTrait
    local colTimer = TraitTimerHUDColHeadersColTimer

    if colItem then colItem:SetText(GetString(TT_COL_ITEM)) end
    if colTrait then colTrait:SetText(GetString(TT_COL_TRAIT)) end
    if colTimer then
        if TT.viewMode == "missing" then
            colTimer:SetText(GetString(TT_COL_MISSING))
        else
            colTimer:SetText(GetString(TT_COL_TIME))
        end
    end

    local colHeaders = TraitTimerHUDColHeaders
    if colHeaders then colHeaders:SetHidden(false) end

    if TT.viewMode == "missing" then
        self:RebuildMissing()
    else
        self:RebuildTimers()
    end
end

---------------------------------------------------------------------------
-- Rebuild: Timers Mode (active research with countdowns)
---------------------------------------------------------------------------

function UI:RebuildTimers()
    local content = TraitTimerHUDContent
    local scrollChild = self:GetScrollChild()
    if not content or not scrollChild then return end

    content:SetHidden(false)
    self:ClearContent()

    local totalActive = 0
    local yOffset = CONTENT_PADDING
    local width = self:GetContentWidth()

    for _, craftInfo in ipairs(TT.RESEARCH_CRAFTS) do
        local craftType = craftInfo.type
        local data = TT.researchData[craftType]

        if data and #data.entries > 0 then
            local section = self:GetOrCreateCraftSection(craftType, scrollChild)

            local slotText = zo_strformat(GetString(TT_STATUS_SLOTS_USED), data.activeCount, data.maxSlots)
            local slotColor = data.activeCount >= data.maxSlots and COLOR_SLOTS_FULL or COLOR_SLOTS_FREE
            self:SetupCraftHeader(section, craftInfo, scrollChild, width, yOffset, slotText, slotColor)
            yOffset = yOffset + HEADER_HEIGHT

            section.rows = {}
            for _, research in ipairs(data.entries) do
                local row = self:GetRow(scrollChild)
                self:ApplyRowWidths(row)

                local itemLabel = row:GetNamedChild("Item")
                local traitLabel = row:GetNamedChild("Trait")
                local timerLabel = row:GetNamedChild("Timer")

                if itemLabel then
                    itemLabel:SetText(research.lineName or "?")
                    SetColor(itemLabel, COLOR_ITEM)
                end
                if traitLabel then
                    traitLabel:SetText(research.traitName or "?")
                    SetColor(traitLabel, COLOR_TRAIT)
                end
                if timerLabel then
                    timerLabel:SetText(TT.FormatTime(research.timeRemaining))
                    timerLabel:SetColor(GetTimerColor(research.timeRemaining))
                end

                row:ClearAnchors()
                row:SetAnchor(TOPLEFT, scrollChild, TOPLEFT, 0, yOffset)
                row:SetHidden(false)
                yOffset = yOffset + ROW_HEIGHT + ROW_SPACING

                table.insert(section.rows, {
                    control = row,
                    research = research,
                    craftType = craftType,
                })

                totalActive = totalActive + 1
            end

            yOffset = yOffset + SECTION_SPACING
        end
    end

    local emptyLabel = self:EnsureEmptyLabel()
    if emptyLabel then
        emptyLabel:SetWidth(self:GetContentWidth())
        if totalActive == 0 then
            emptyLabel:SetText(GetString(TT_STATUS_NO_RESEARCH))
            emptyLabel:ClearAnchors()
            emptyLabel:SetAnchor(TOP, scrollChild, TOP, 0, 4)
            emptyLabel:SetHidden(false)
            yOffset = yOffset + ROW_HEIGHT + CONTENT_PADDING
        else
            emptyLabel:SetHidden(true)
        end
    end

    self:FinalizeHeight(yOffset + CONTENT_PADDING)
    self.totalActive = totalActive

    local summary = TraitTimerHUDHeaderSummary
    if summary then summary:SetHidden(true) end
    local minBtn = TraitTimerHUDHeaderMinBtn
    if minBtn then minBtn:SetText("-") end
end

---------------------------------------------------------------------------
-- Rebuild: Missing Traits Mode
---------------------------------------------------------------------------

function UI:RebuildMissing()
    local content = TraitTimerHUDContent
    local scrollChild = self:GetScrollChild()
    if not content or not scrollChild then return end

    content:SetHidden(false)
    self:ClearContent()

    local totalMissing = 0
    local yOffset = CONTENT_PADDING
    local width = self:GetContentWidth()

    for _, craftInfo in ipairs(TT.RESEARCH_CRAFTS) do
        local craftType = craftInfo.type
        local data = TT.missingData[craftType]

        if data and #data.entries > 0 then
            local section = self:GetOrCreateCraftSection(craftType, scrollChild)

            local slotText = zo_strformat(GetString(TT_MISSING_HEADER), data.totalKnown, data.totalTraits)
            local slotColor = data.totalMissing == 0 and COLOR_MISSING_NONE or COLOR_MISSING_SOME
            self:SetupCraftHeader(section, craftInfo, scrollChild, width, yOffset, slotText, slotColor)
            yOffset = yOffset + HEADER_HEIGHT

            section.rows = {}
            for _, entry in ipairs(data.entries) do
                local missingCount = #entry.missingTraits
                local mr, mg, mb, ma = GetMissingColor(missingCount, entry.totalTraits)

                for t, traitInfo in ipairs(entry.missingTraits) do
                    local row = self:GetRow(scrollChild)
                    self:ApplyRowWidths(row)

                    local itemLabel = row:GetNamedChild("Item")
                    local traitLabel = row:GetNamedChild("Trait")
                    local timerLabel = row:GetNamedChild("Timer")

                    if itemLabel then
                        if t == 1 then
                            itemLabel:SetText(entry.lineName or "?")
                            SetColor(itemLabel, COLOR_ITEM)
                        else
                            itemLabel:SetText("")
                        end
                    end

                    if traitLabel then
                        traitLabel:SetText(traitInfo.name)
                        local isOwned = TT:HasOwnedTrait(craftType, entry.lineIndex, traitInfo.traitType)
                        SetColor(traitLabel, isOwned and COLOR_TRAIT_OWNED or COLOR_TRAIT_MISSING)
                    end

                    if timerLabel then
                        if t == 1 then
                            timerLabel:SetText(zo_strformat(GetString(TT_MISSING_COUNT), missingCount))
                            timerLabel:SetColor(mr, mg, mb, ma)
                        else
                            timerLabel:SetText("")
                        end
                    end

                    row:ClearAnchors()
                    row:SetAnchor(TOPLEFT, scrollChild, TOPLEFT, 0, yOffset)
                    row:SetHidden(false)
                    yOffset = yOffset + ROW_HEIGHT + ROW_SPACING

                    table.insert(section.rows, {
                        control = row,
                        craftType = craftType,
                    })
                end

                totalMissing = totalMissing + missingCount
            end

            yOffset = yOffset + SECTION_SPACING
        end
    end

    local emptyLabel = self:EnsureEmptyLabel()
    if emptyLabel then
        emptyLabel:SetWidth(self:GetContentWidth())
        if totalMissing == 0 then
            emptyLabel:SetText(GetString(TT_MISSING_NONE))
            emptyLabel:ClearAnchors()
            emptyLabel:SetAnchor(TOP, scrollChild, TOP, 0, 4)
            emptyLabel:SetHidden(false)
            yOffset = yOffset + ROW_HEIGHT + CONTENT_PADDING
        else
            emptyLabel:SetHidden(true)
        end
    end

    self:FinalizeHeight(yOffset + CONTENT_PADDING)
    self.totalActive = 0

    local summary = TraitTimerHUDHeaderSummary
    if summary then summary:SetHidden(true) end
    local minBtn = TraitTimerHUDHeaderMinBtn
    if minBtn then minBtn:SetText("-") end
end

---------------------------------------------------------------------------
-- Timer Label Updates (timers mode only)
---------------------------------------------------------------------------

function UI:UpdateTimerLabels()
    if TT.viewMode ~= "timers" then return end

    for _, section in pairs(self.craftSections) do
        for _, rowData in ipairs(section.rows) do
            local row = rowData.control
            if not row:IsHidden() and rowData.research then
                local timerLabel = row:GetNamedChild("Timer")
                if timerLabel then
                    timerLabel:SetText(TT.FormatTime(rowData.research.timeRemaining))
                    timerLabel:SetColor(GetTimerColor(rowData.research.timeRemaining))
                end
            end
        end
    end
end

---------------------------------------------------------------------------
-- Minimized State
---------------------------------------------------------------------------

function UI:ApplyMinimizedState()
    local content = TraitTimerHUDContent
    local summary = TraitTimerHUDHeaderSummary
    local minBtn = TraitTimerHUDHeaderMinBtn

    if not content or not summary then return end

    content:SetHidden(true)

    local colHeaders = TraitTimerHUDColHeaders
    if colHeaders then
        colHeaders:SetHidden(true)
    end

    local parts = {}
    if TT.viewMode == "timers" then
        if (self.totalActive or 0) > 0 then
            table.insert(parts, zo_strformat(GetString(TT_SUMMARY_ACTIVE), self.totalActive))
        end
    else
        table.insert(parts, GetString(TT_MODE_MISSING))
    end
    if #parts == 0 then
        summary:SetText(GetString(TT_STATUS_NO_RESEARCH))
    else
        summary:SetText(table.concat(parts, " | "))
    end
    summary:SetHidden(false)

    TraitTimerHUD:SetHeight(HEADER_BAR_HEIGHT + 4)

    if minBtn then minBtn:SetText("+") end
end
