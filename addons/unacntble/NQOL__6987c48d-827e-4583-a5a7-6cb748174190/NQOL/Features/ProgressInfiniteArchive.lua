NQOL = NQOL or {}
NQOL.Features = NQOL.Features or {}

local ProgressInfiniteArchive = {}

local C = {
    EVENT_NAMESPACE = "NQOL_ProgressInfiniteArchive",
    DRAW_LEVEL = 245,
    FONT_SIZE_MIN = 10,
    FONT_SIZE_MAX = 32,
    DEFAULT_FONT_SIZE = 21,
    BACKGROUND_OPACITY_MIN = 0,
    BACKGROUND_OPACITY_MAX = 100,
    SCREEN_MARGIN = 24,
    PADDING = 12,
    MIN_WIDTH = 1000,
    MAX_WIDTH = 2300,
    MIN_HEIGHT = 480,
    MAX_HEIGHT = 980,
    BASIC_HEIGHT_BONUS = 100,
    COLUMN_GAP = 28,
    ROW_GAP = 2,
    RECORD_GAP = 8,
    FOOTER_TOP_GAP = 10,
    FOOTER_LINE_GAP = 2,
    FOOTER_DIVIDER_GAP = 5,
    STATUS_ICON_SIZE = 18,
    SCROLL_DEADZONE = 0.18,
    SCROLL_SPEED = 720,
    WATERMARK_ALPHA = 0.05,
    RECORD_VALUE_COLOR = "FFD64D",
    CHECKMARK_TEXTURE = "EsoUI/Art/Inventory/Gamepad/gp_inventory_icon_equipped.dds",
    CROSS_TEXTURE = "EsoUI/Art/Buttons/decline_up.dds",
    DETAIL_BASIC = "basic",
    DETAIL_DATES = "dates",
    DETAIL_FULL = "full",
    GROUP_SOLO = "solo",
    GROUP_DUO = "duo",
}

local COLORS = {
    accent = { 0.72, 0.86, 1 },
    score = { 1, 0.84, 0.30 },
    recordText = { 1, 1, 1 },
    complete = { 0.20, 0.95, 0.35 },
    incomplete = { 1, 0.22, 0.22 },
    text = { 1, 1, 1, 0.92 },
    textMuted = { 0.72, 0.72, 0.68, 0.90 },
    divider = { 0.72, 0.86, 1 },
}

local DETAIL_LEVELS = {
    { key = C.DETAIL_BASIC, name = NQOL.L("common.detail.basic") },
    { key = C.DETAIL_DATES, name = NQOL.L("common.detail.dates") },
    { key = C.DETAIL_FULL, name = NQOL.L("common.detail.full") },
}
NQOL.Lexicon.RegisterTableField(DETAIL_LEVELS, "name", { "common.detail.basic", "common.detail.dates", "common.detail.full" })

local defaults = {
    progress = {
        infiniteArchive = {
            detailLevel = C.DETAIL_BASIC,
            showWatermark = false,
            horizontalPosition = 50,
            verticalPosition = 18,
            font = NQOL.Util.GetDefaultFont(),
            fontSize = C.DEFAULT_FONT_SIZE,
            backgroundOpacity = 90,
            scrollRatio = 0,
        },
    },
}

local savedVariables
local initialized = false
local displayEventsRegistered = false
local settingsPanelVisible = false
local hud
local achievementEntries = {}
local achievementIds = {}
local achievementRows = {}
local fontStringCache = {}
local Refresh
local ApplyPosition
local RefreshInputActivation
local RegisterDisplayEvents

local Clamp = NQOL.Util.Clamp
local Round = NQOL.Util.Round

local function ClearTable(values)
    for key in pairs(values) do
        values[key] = nil
    end
end

local function GetSettings()
    local progress = NQOL.Settings.GetSection(savedVariables, defaults, "progress")
    if type(progress.infiniteArchive) ~= "table" then
        progress.infiniteArchive = {}
    end

    local settings = progress.infiniteArchive
    local archiveDefaults = defaults.progress.infiniteArchive
    NQOL.Settings.Choice(settings, archiveDefaults, "detailLevel", {
        [C.DETAIL_BASIC] = true,
        [C.DETAIL_DATES] = true,
        [C.DETAIL_FULL] = true,
    })
    NQOL.Settings.Boolean(settings, archiveDefaults, "showWatermark")
    NQOL.Settings.ClampedNumber(settings, archiveDefaults, "horizontalPosition", 0, 100)
    NQOL.Settings.ClampedNumber(settings, archiveDefaults, "verticalPosition", 0, 100)
    NQOL.Settings.ClampedNumber(settings, archiveDefaults, "fontSize", C.FONT_SIZE_MIN, C.FONT_SIZE_MAX, true)
    NQOL.Settings.ClampedNumber(settings, archiveDefaults, "backgroundOpacity", C.BACKGROUND_OPACITY_MIN, C.BACKGROUND_OPACITY_MAX, true)
    settings.scrollRatio = Clamp(tonumber(settings.scrollRatio) or archiveDefaults.scrollRatio, 0, 1)
    if not NQOL.Util.IsFontChoice(settings.font) then
        settings.font = archiveDefaults.font
    end

    return settings
end

local function GetRecord(groupKey)
    local tracking = NQOL.Features.CombatInfiniteArchive
    if not tracking or not tracking.GetRecord then return {} end
    return tracking.GetRecord(groupKey)
end

local function GetFont(offset)
    local settings = GetSettings()
    local size = Clamp(settings.fontSize + (offset or 0), C.FONT_SIZE_MIN, C.FONT_SIZE_MAX + 8)
    local key = tostring(settings.font) .. "|" .. tostring(size)
    if not fontStringCache[key] then
        fontStringCache[key] = NQOL.Util.CreateFontString(settings.font, size, "ZoFontGamepad18")
    end
    return fontStringCache[key]
end

local function MoveAbove(control, level)
    if control.SetDrawTier and DT_HIGH then control:SetDrawTier(DT_HIGH) end
    if control.SetDrawLayer and DL_CONTROLS then control:SetDrawLayer(DL_CONTROLS) end
    if control.SetDrawLevel then control:SetDrawLevel(level or C.DRAW_LEVEL) end
end

local function SetColor(control, color, alpha)
    control:SetColor(color[1], color[2], color[3], alpha or color[4] or 1)
end

local function CreateLabel(parent, fontOffset, color, alignment)
    local label = WINDOW_MANAGER:CreateControl(nil, parent, CT_LABEL)
    label:SetFont(GetFont(fontOffset))
    SetColor(label, color or COLORS.text)
    label:SetHorizontalAlignment(alignment or TEXT_ALIGN_LEFT)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    MoveAbove(label, C.DRAW_LEVEL + 5)
    return label
end

local function NormalizeText(value)
    local text = tostring(value or "")
    if zo_strformat then
        text = zo_strformat("<<1>>", text)
    end
    text = string.gsub(text, "^%s+", "")
    text = string.gsub(text, "%s+$", "")
    if zo_strlower then
        return zo_strlower(text)
    end
    return string.lower(text)
end

local function FormatAchievementName(value)
    if zo_strformat then
        return zo_strformat("<<1>>", value or "")
    end
    return tostring(value or "")
end

local function FormatDate(value)
    if value == nil or value == "" or value == 0 then
        return "-"
    end

    local text = tostring(value)
    local year, month, day = string.match(text, "^(%d%d%d%d)%-(%d%d?)%-(%d%d?)$")
    if year and month and day then
        return string.format("%04d-%02d-%02d", tonumber(year), tonumber(month), tonumber(day))
    end
    month, day, year = string.match(text, "^(%d%d?)/(%d%d?)/(%d%d%d%d)$")
    if year and month and day then
        return string.format("%04d-%02d-%02d", tonumber(year), tonumber(month), tonumber(day))
    end
    return text
end

local function AddAchievementEntry(categoryName, achievementId)
    if not achievementId or achievementId <= 0 or achievementIds[achievementId] then
        return
    end

    local name, description, _, icon, completed, date = GetAchievementInfo(achievementId)
    achievementIds[achievementId] = true
    achievementEntries[#achievementEntries + 1] = {
        achievementId = achievementId,
        categoryName = categoryName,
        name = FormatAchievementName(name),
        description = tostring(description or ""),
        icon = icon,
        completed = completed == true or (IsAchievementComplete and IsAchievementComplete(achievementId) == true),
        date = date,
    }
end

local function AddAchievementGroup(topLevelIndex, subcategoryIndex, categoryName, count)
    if (tonumber(count) or 0) <= 0 then
        return
    end

    achievementEntries[#achievementEntries + 1] = {
        isHeader = true,
        name = categoryName,
    }

    for achievementIndex = 1, count do
        local achievementId = GetAchievementId(topLevelIndex, subcategoryIndex, achievementIndex)
        AddAchievementEntry(categoryName, achievementId)
    end
end

local function BuildAchievementEntries()
    ClearTable(achievementEntries)
    ClearTable(achievementIds)

    if not GetNumAchievementCategories or not GetAchievementCategoryInfo or not GetAchievementId then
        return
    end

    local targetName = GetString and SI_ENDLESS_DUNGEON_HUD_TRACKER_TITLE and GetString(SI_ENDLESS_DUNGEON_HUD_TRACKER_TITLE) or NQOL.L("features.progress_infinite_archive.infinite_archive")
    local normalizedTargetName = NormalizeText(targetName)

    for topLevelIndex = 1, GetNumAchievementCategories() do
        local categoryName, numSubcategories, numAchievements = GetAchievementCategoryInfo(topLevelIndex)
        if NormalizeText(categoryName) == normalizedTargetName then
            local generalName = GetString and SI_JOURNAL_PROGRESS_CATEGORY_GENERAL and GetString(SI_JOURNAL_PROGRESS_CATEGORY_GENERAL) or NQOL.L("common.general")
            AddAchievementGroup(topLevelIndex, nil, generalName, numAchievements)

            for subcategoryIndex = 1, numSubcategories do
                local subcategoryName, subcategoryAchievementCount = GetAchievementSubCategoryInfo(topLevelIndex, subcategoryIndex)
                AddAchievementGroup(topLevelIndex, subcategoryIndex, FormatAchievementName(subcategoryName), subcategoryAchievementCount)
            end
            break
        end
    end
end

local function BuildAchievementRows(columnCount)
    ClearTable(achievementRows)
    local pendingAchievements
    columnCount = math.max(tonumber(columnCount) or 2, 1)

    for _, entry in ipairs(achievementEntries) do
        if entry.isHeader then
            pendingAchievements = nil
            achievementRows[#achievementRows + 1] = entry
        else
            if not pendingAchievements or #pendingAchievements >= columnCount then
                pendingAchievements = {}
                achievementRows[#achievementRows + 1] = { achievements = pendingAchievements }
            end
            pendingAchievements[#pendingAchievements + 1] = entry
        end
    end
end

local function FormatRecordValue(value)
    value = tonumber(value)
    if not value or value <= 0 then
        return "-"
    end
    return tostring(value)
end

local function FormatScore(record)
    local score = tonumber(record and record.score)
    if not score or score <= 0 then
        return "-"
    end
    score = math.floor(score)
    if ZO_CommaDelimitNumber then
        return ZO_CommaDelimitNumber(score)
    end
    return tostring(score)
end

local function FormatRecordProgress(record)
    return NQOL.L(
        "features.progress_infinite_archive.best_progress",
        C.RECORD_VALUE_COLOR,
        FormatRecordValue(record.arc),
        FormatRecordValue(record.cycle),
        FormatRecordValue(record.stage)
    )
end

local function GetScreenDimensions()
    local width = GetScreenWidth and GetScreenWidth() or nil
    local height = GetScreenHeight and GetScreenHeight() or nil
    if (not width or width <= 0) and GuiRoot and GuiRoot.GetDimensions then
        width, height = GuiRoot:GetDimensions()
    end
    return tonumber(width) or 1920, tonumber(height) or 1080
end

local function GetRowHeight(row, detailLevel, fontSize)
    if row.isHeader then
        return fontSize + 10
    end
    if detailLevel == C.DETAIL_FULL then
        return math.max((fontSize * 2) + 18, 60)
    end
    return fontSize + 12
end

local function GetLayout()
    local screenWidth, screenHeight = GetScreenDimensions()
    local settings = GetSettings()
    local safeWidth = math.max(screenWidth - (C.SCREEN_MARGIN * 2), 320)
    local safeHeight = math.max(screenHeight - (C.SCREEN_MARGIN * 2), 240)
    local availableHudWidth = math.min(safeWidth, C.MAX_WIDTH)
    local columns = settings.detailLevel == C.DETAIL_BASIC and 3 or 2
    local totalColumnGaps = C.COLUMN_GAP * (columns - 1)
    local maxColumnWidth = math.max(math.floor((availableHudWidth - (C.PADDING * 2) - totalColumnGaps) / columns), 1)
    local leadingIconWidth = settings.detailLevel == C.DETAIL_BASIC and (C.STATUS_ICON_SIZE + 8) or 0
    local desiredStatusWidth = settings.detailLevel == C.DETAIL_BASIC and 0 or math.max(settings.fontSize * 7, 126)
    local statusWidth = math.min(desiredStatusWidth, math.max(maxColumnWidth - leadingIconWidth - 9, 0))
    local maxNameLength = 0
    for _, entry in ipairs(achievementEntries) do
        if not entry.isHeader then
            maxNameLength = math.max(maxNameLength, string.len(tostring(entry.name or "")))
        end
    end
    local statusGap = statusWidth > 0 and 8 or 0
    local maxNameWidth = math.max(maxColumnWidth - leadingIconWidth - statusGap - statusWidth, 1)
    local desiredNameWidth = math.ceil(maxNameLength * settings.fontSize * 0.54)
    local minimumNameWidth = math.min(math.ceil(settings.fontSize * 10), maxNameWidth)
    local nameWidth = Clamp(desiredNameWidth, minimumNameWidth, maxNameWidth)
    local cellWidth = leadingIconWidth + nameWidth + statusGap + statusWidth
    local contentWidth = (cellWidth * columns) + totalColumnGaps
    local desiredWidth = contentWidth + (C.PADDING * 2)
    local minWidth = settings.detailLevel == C.DETAIL_BASIC and desiredWidth or math.min(C.MIN_WIDTH, safeWidth)
    local maxWidth = math.min(C.MAX_WIDTH, safeWidth)
    local minHeight = math.min(C.MIN_HEIGHT, safeHeight)
    local basicHeightBonus = settings.detailLevel == C.DETAIL_BASIC and C.BASIC_HEIGHT_BONUS or 0
    local maxHeight = math.min(C.MAX_HEIGHT + basicHeightBonus, safeHeight)
    local width = Clamp(desiredWidth, math.min(minWidth, maxWidth), maxWidth)
    local height = Clamp(math.floor(screenHeight * 0.84) + basicHeightBonus, minHeight, maxHeight)
    local innerWidth = width - (C.PADDING * 2)
    local titleHeight = settings.fontSize + 16
    local recordHeight = (settings.fontSize * 2) + 22
    local headerHeight = titleHeight + recordHeight + C.RECORD_GAP
    local footerTextHeight = settings.fontSize + 4
    local footerHeight = C.FOOTER_TOP_GAP + 1 + C.FOOTER_DIVIDER_GAP + (footerTextHeight * 2) + C.FOOTER_LINE_GAP
    local contentTop = C.PADDING + headerHeight + 8
    local viewportHeight = math.max(height - contentTop - footerHeight - C.PADDING, settings.fontSize + 12)
    return {
        screenWidth = screenWidth,
        screenHeight = screenHeight,
        width = width,
        height = height,
        innerWidth = innerWidth,
        contentWidth = contentWidth,
        contentInset = math.max((innerWidth - contentWidth) / 2, 0),
        columns = columns,
        cellWidth = cellWidth,
        nameWidth = nameWidth,
        leadingIconWidth = leadingIconWidth,
        statusWidth = statusWidth,
        titleHeight = titleHeight,
        recordHeight = recordHeight,
        headerHeight = headerHeight,
        footerHeight = footerHeight,
        footerTextHeight = footerTextHeight,
        contentTop = contentTop,
        viewportHeight = viewportHeight,
        detailLevel = settings.detailLevel,
        fontSize = settings.fontSize,
    }
end

local function EnsureAchievementCell(parent)
    local cell = { parent = parent }
    cell.name = CreateLabel(parent, -3, COLORS.text)
    cell.status = CreateLabel(parent, -6, COLORS.textMuted, TEXT_ALIGN_RIGHT)
    cell.description = CreateLabel(parent, -6, COLORS.textMuted)
    cell.description:SetVerticalAlignment(TEXT_ALIGN_TOP)
    MoveAbove(cell.name, C.DRAW_LEVEL + 10)
    MoveAbove(cell.status, C.DRAW_LEVEL + 10)
    MoveAbove(cell.description, C.DRAW_LEVEL + 10)
    cell.icon = WINDOW_MANAGER:CreateControl(nil, parent, CT_TEXTURE)
    cell.icon:SetDimensions(C.STATUS_ICON_SIZE, C.STATUS_ICON_SIZE)
    MoveAbove(cell.icon, C.DRAW_LEVEL + 10)
    return cell
end

local function EnsureRow(index)
    hud.rows = hud.rows or {}
    if hud.rows[index] then return hud.rows[index] end

    local row = { cells = {} }
    row.control = WINDOW_MANAGER:CreateControl(nil, hud.content, CT_CONTROL)
    MoveAbove(row.control, C.DRAW_LEVEL + 9)
    row.header = CreateLabel(row.control, -2, COLORS.accent)
    MoveAbove(row.header, C.DRAW_LEVEL + 10)
    row.headerDivider = WINDOW_MANAGER:CreateControl(nil, row.control, CT_TEXTURE)
    SetColor(row.headerDivider, COLORS.divider, 0.30)
    MoveAbove(row.headerDivider, C.DRAW_LEVEL + 9)
    row.cells[1] = EnsureAchievementCell(row.control)
    row.cells[2] = EnsureAchievementCell(row.control)
    row.cells[3] = EnsureAchievementCell(row.control)
    hud.rows[index] = row
    return row
end

local function CreateRecordDisplay(parent)
    local display = {}
    display.control = WINDOW_MANAGER:CreateControl(nil, parent, CT_CONTROL)
    MoveAbove(display.control, C.DRAW_LEVEL + 8)
    display.mode = CreateLabel(display.control, -1, COLORS.accent)
    display.score = CreateLabel(display.control, 1, COLORS.score)
    display.progress = CreateLabel(display.control, -3, COLORS.recordText)
    MoveAbove(display.mode, C.DRAW_LEVEL + 10)
    MoveAbove(display.score, C.DRAW_LEVEL + 10)
    MoveAbove(display.progress, C.DRAW_LEVEL + 10)
    display.line = WINDOW_MANAGER:CreateControl(nil, display.control, CT_TEXTURE)
    SetColor(display.line, COLORS.score, 0.55)
    MoveAbove(display.line, C.DRAW_LEVEL + 9)
    return display
end

local function EnsureHud()
    if hud or not WINDOW_MANAGER or not GuiRoot then return hud end

    hud = { rows = {}, scrollOffset = 0, maxScrollOffset = 0 }
    hud.control = WINDOW_MANAGER:CreateTopLevelWindow("NQOLProgressInfiniteArchive")
    hud.control:SetHidden(true)
    MoveAbove(hud.control, C.DRAW_LEVEL)
    hud.UpdateDirectionalInput = function(_, elapsedSeconds)
        ProgressInfiniteArchive.UpdateDirectionalInput(elapsedSeconds or 0)
    end

    hud.background = WINDOW_MANAGER:CreateControl(nil, hud.control, CT_BACKDROP)
    hud.background:SetAnchorFill(hud.control)
    MoveAbove(hud.background, C.DRAW_LEVEL)
    hud.headerMask = WINDOW_MANAGER:CreateControl(nil, hud.control, CT_BACKDROP)
    MoveAbove(hud.headerMask, C.DRAW_LEVEL + 7)
    hud.footerMask = WINDOW_MANAGER:CreateControl(nil, hud.control, CT_BACKDROP)
    MoveAbove(hud.footerMask, C.DRAW_LEVEL + 7)

    hud.watermarkClip = WINDOW_MANAGER:CreateControl(nil, hud.control, CT_CONTROL)
    if hud.watermarkClip.SetClipsChildren then hud.watermarkClip:SetClipsChildren(true) end
    MoveAbove(hud.watermarkClip, C.DRAW_LEVEL + 8)
    hud.watermark = CreateLabel(hud.watermarkClip, 8, { 1, 1, 1, C.WATERMARK_ALPHA }, TEXT_ALIGN_CENTER)
    hud.watermark:SetVerticalAlignment(TEXT_ALIGN_TOP)
    MoveAbove(hud.watermark, C.DRAW_LEVEL + 8)

    hud.title = CreateLabel(hud.control, 5, COLORS.accent)
    MoveAbove(hud.title, C.DRAW_LEVEL + 9)
    hud.soloRecord = CreateRecordDisplay(hud.control)
    hud.duoRecord = CreateRecordDisplay(hud.control)

    hud.viewport = WINDOW_MANAGER:CreateControl(nil, hud.control, CT_CONTROL)
    if hud.viewport.SetClipsChildren then hud.viewport:SetClipsChildren(true) end
    MoveAbove(hud.viewport, C.DRAW_LEVEL + 1)
    hud.content = WINDOW_MANAGER:CreateControl(nil, hud.viewport, CT_CONTROL)
    MoveAbove(hud.content, C.DRAW_LEVEL + 1)
    hud.empty = CreateLabel(hud.viewport, -2, COLORS.textMuted, TEXT_ALIGN_CENTER)
    hud.empty:SetText(NQOL.L("features.progress_infinite_archive.no_infinite_archive_achievement_data_is_available_6fa483f"))
    MoveAbove(hud.empty, C.DRAW_LEVEL + 10)

    hud.footerDivider = WINDOW_MANAGER:CreateControl(nil, hud.control, CT_TEXTURE)
    SetColor(hud.footerDivider, COLORS.divider, 0.38)
    MoveAbove(hud.footerDivider, C.DRAW_LEVEL + 9)
    hud.footerSummary = CreateLabel(hud.control, -5, COLORS.text, TEXT_ALIGN_CENTER)
    MoveAbove(hud.footerSummary, C.DRAW_LEVEL + 9)
    hud.footer = CreateLabel(hud.control, -5, COLORS.textMuted, TEXT_ALIGN_CENTER)
    MoveAbove(hud.footer, C.DRAW_LEVEL + 9)
    return hud
end

local function GetHeaderTimestamp()
    if GetTimeStamp and os and os.date then
        local time = os.date("*t", GetTimeStamp())
        if time then
            return string.format("%04d-%02d-%02d %02d:%02d", time.year or 0, time.month or 0, time.day or 0, time.hour or 0, time.min or 0)
        end
    end
    if GetDate and GetTimeString then
        local year, month, day = GetDate()
        local hour, minute = string.match(GetTimeString() or "", "^(%d%d?):(%d%d)")
        return string.format("%04d-%02d-%02d %02d:%02d", tonumber(year) or 0, tonumber(month) or 0, tonumber(day) or 0, tonumber(hour) or 0, tonumber(minute) or 0)
    end
    return "0000-00-00 00:00"
end

local function GetWatermarkText()
    local playerId = GetDisplayName and GetDisplayName() or ""
    if playerId == "" and GetUnitDisplayName then playerId = GetUnitDisplayName("player") or "" end
    if playerId ~= "" and string.sub(playerId, 1, 1) ~= "@" then playerId = "@" .. playerId end
    local platformServer = string.format("%s %s", NQOL.Util.GetConsolePlatform(), NQOL.Util.GetMegaserverName())
    if playerId == "" then return string.format("%s · %s", platformServer, GetHeaderTimestamp()) end
    return string.format("%s · %s · %s", playerId, platformServer, GetHeaderTimestamp())
end

local function RenderWatermark(layout)
    local settings = GetSettings()
    if settings.showWatermark ~= true then
        hud.watermarkClip:SetHidden(true)
        hud.watermark:SetHidden(true)
        return
    end

    local parts = {}
    local segment = GetWatermarkText()
    for index = 1, 160 do parts[index] = segment end
    hud.watermarkClip:ClearAnchors()
    local watermarkHeight = layout.height
    hud.watermarkClip:SetDimensions(layout.width, watermarkHeight)
    hud.watermarkClip:SetAnchor(TOPLEFT, hud.control, TOPLEFT, 0, 0)
    hud.watermarkClip:SetHidden(false)
    hud.watermark:SetFont(GetFont(8))
    hud.watermark:SetColor(1, 1, 1, C.WATERMARK_ALPHA)
    hud.watermark:SetText(table.concat(parts, "   "))
    hud.watermark:ClearAnchors()
    hud.watermark:SetDimensions(layout.width, watermarkHeight)
    hud.watermark:SetAnchor(TOPLEFT, hud.watermarkClip, TOPLEFT, 0, 0)
    hud.watermark:SetHidden(false)
end

local function ApplyCompletionIcon(icon, completed)
    icon:SetTexture(completed and C.CHECKMARK_TEXTURE or C.CROSS_TEXTURE)
    if icon.SetTextureCoords then icon:SetTextureCoords(0, 1, 0, 1) end
    SetColor(icon, completed and COLORS.complete or COLORS.incomplete)
    icon:SetHidden(false)
end

local function HideAchievementCell(cell)
    cell.name:SetHidden(true)
    cell.status:SetHidden(true)
    cell.description:SetHidden(true)
    cell.icon:SetHidden(true)
end

local function LayoutAchievementCell(cell, entry, cellIndex, rowHeight, layout)
    if not entry then HideAchievementCell(cell); return end

    local cellX = (cellIndex - 1) * (layout.cellWidth + C.COLUMN_GAP)
    local primaryHeight = layout.fontSize + 10
    local nameX = cellX + layout.leadingIconWidth
    local statusX = nameX + layout.nameWidth + 8

    cell.name:SetFont(GetFont(-3))
    SetColor(cell.name, COLORS.text)
    cell.name:SetText(entry.name or "")
    cell.name:ClearAnchors()
    cell.name:SetDimensions(layout.nameWidth, primaryHeight)
    cell.name:SetAnchor(TOPLEFT, cell.parent, TOPLEFT, nameX, 0)
    cell.name:SetHidden(false)

    cell.icon:ClearAnchors()
    cell.icon:SetDimensions(C.STATUS_ICON_SIZE, C.STATUS_ICON_SIZE)
    cell.status:ClearAnchors()
    cell.status:SetDimensions(layout.statusWidth, primaryHeight)
    cell.status:SetAnchor(TOPLEFT, cell.parent, TOPLEFT, statusX, 0)

    if layout.detailLevel == C.DETAIL_BASIC then
        cell.status:SetHidden(true)
        cell.icon:SetAnchor(TOPLEFT, cell.parent, TOPLEFT, cellX, (primaryHeight - C.STATUS_ICON_SIZE) / 2)
        ApplyCompletionIcon(cell.icon, entry.completed)
    elseif entry.completed then
        cell.icon:SetHidden(true)
        cell.status:SetFont(GetFont(-6))
        cell.status:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        SetColor(cell.status, COLORS.complete)
        cell.status:SetText(FormatDate(entry.date))
        cell.status:SetHidden(false)
    else
        cell.status:SetHidden(true)
        cell.icon:SetAnchor(TOPLEFT, cell.parent, TOPLEFT, statusX + math.max((layout.statusWidth - C.STATUS_ICON_SIZE) / 2, 0), (primaryHeight - C.STATUS_ICON_SIZE) / 2)
        ApplyCompletionIcon(cell.icon, false)
    end

    if layout.detailLevel == C.DETAIL_FULL then
        local detailText = tostring(entry.description or "")
        cell.description:SetFont(GetFont(-6))
        SetColor(cell.description, COLORS.textMuted)
        cell.description:SetText(detailText)
        cell.description:ClearAnchors()
        cell.description:SetDimensions(layout.cellWidth, math.max(rowHeight - primaryHeight, 1))
        cell.description:SetAnchor(TOPLEFT, cell.parent, TOPLEFT, cellX, primaryHeight)
        cell.description:SetHidden(false)
    else
        cell.description:SetHidden(true)
    end
end

local function LayoutAchievementRow(rowControl, rowData, y, layout)
    local rowHeight = GetRowHeight(rowData, layout.detailLevel, layout.fontSize)
    rowControl.control:ClearAnchors()
    rowControl.control:SetDimensions(layout.contentWidth, rowHeight)
    rowControl.control:SetAnchor(TOPLEFT, hud.content, TOPLEFT, 0, y)
    rowControl.clipTop = y
    rowControl.clipBottom = y + rowHeight
    rowControl.control:SetHidden(false)

    if rowData.isHeader then
        rowControl.header:SetFont(GetFont(-2))
        SetColor(rowControl.header, COLORS.accent)
        rowControl.header:SetText(string.upper(rowData.name or ""))
        rowControl.header:ClearAnchors()
        rowControl.header:SetDimensions(layout.contentWidth, rowHeight)
        rowControl.header:SetAnchor(TOPLEFT, rowControl.control, TOPLEFT, 0, 0)
        rowControl.header:SetHidden(false)
        rowControl.headerDivider:ClearAnchors()
        rowControl.headerDivider:SetDimensions(layout.contentWidth, 1)
        rowControl.headerDivider:SetAnchor(BOTTOMLEFT, rowControl.control, BOTTOMLEFT, 0, 0)
        rowControl.headerDivider:SetHidden(false)
        for _, cell in ipairs(rowControl.cells) do
            HideAchievementCell(cell)
        end
    else
        rowControl.header:SetHidden(true)
        rowControl.headerDivider:SetHidden(true)
        for cellIndex, cell in ipairs(rowControl.cells) do
            LayoutAchievementCell(cell, rowData.achievements[cellIndex], cellIndex, rowHeight, layout)
        end
    end
    return rowHeight
end

local function UpdateRowClipVisibility()
    if not hud then return end
    local scrollTop = tonumber(hud.scrollOffset) or 0
    local scrollBottom = scrollTop + (tonumber(hud.viewportHeight) or 0)
    for _, row in ipairs(hud.rows or {}) do
        if row.clipTop and row.clipBottom then
            row.control:SetHidden(not (row.clipTop >= scrollTop and row.clipBottom <= scrollBottom))
        end
    end
end

local function ApplyScrollOffset()
    if not hud or not hud.content then return end
    hud.content:ClearAnchors()
    hud.content:SetAnchor(TOPLEFT, hud.viewport, TOPLEFT, 0, -(hud.scrollOffset or 0))
    UpdateRowClipVisibility()
end

local function LayoutRecordDisplay(display, mode, record, x, y, width, height, layout)
    local modeHeight = layout.fontSize + 8
    local summaryY = modeHeight - 3
    local summaryHeight = math.max(height - summaryY, 1)

    display.control:ClearAnchors()
    display.control:SetDimensions(width, height)
    display.control:SetAnchor(TOPLEFT, hud.control, TOPLEFT, x, y)

    display.mode:SetFont(GetFont(-1))
    SetColor(display.mode, COLORS.accent)
    display.mode:SetText(mode)
    display.mode:ClearAnchors()
    display.mode:SetDimensions(math.floor(width * 0.50), modeHeight)
    display.mode:SetAnchor(TOPLEFT, display.control, TOPLEFT, 0, 0)

    display.score:SetFont(GetFont(1))
    SetColor(display.score, COLORS.recordText)
    display.score:SetText(NQOL.L("features.progress_infinite_archive.best_score", FormatScore(record)))
    local measuredScoreWidth = display.score.GetTextWidth and display.score:GetTextWidth() or math.floor(width * 0.32)
    local scoreWidth = math.min(math.ceil(measuredScoreWidth) + 2, width)
    local detailX = math.min(scoreWidth + 8, width)
    local detailWidth = math.max(width - detailX, 1)
    display.score:ClearAnchors()
    display.score:SetDimensions(scoreWidth, summaryHeight)
    display.score:SetAnchor(TOPLEFT, display.control, TOPLEFT, 0, summaryY)

    display.progress:SetFont(GetFont(1))
    SetColor(display.progress, COLORS.recordText)
    display.progress:SetText(FormatRecordProgress(record))
    display.progress:ClearAnchors()
    display.progress:SetDimensions(detailWidth, summaryHeight)
    display.progress:SetAnchor(TOPLEFT, display.control, TOPLEFT, detailX, summaryY)

    display.line:ClearAnchors()
    display.line:SetDimensions(width, 1)
    display.line:SetAnchor(BOTTOMLEFT, display.control, BOTTOMLEFT, 0, 0)
end

local function RenderHud()
    if not EnsureHud() then return end
    BuildAchievementEntries()
    local settings = GetSettings()
    BuildAchievementRows(settings.detailLevel == C.DETAIL_BASIC and 3 or 2)
    local layout = GetLayout()
    local completedCount = 0
    local achievementCount = 0

    for _, entry in ipairs(achievementEntries) do
        if not entry.isHeader then
            achievementCount = achievementCount + 1
            if entry.completed then completedCount = completedCount + 1 end
        end
    end

    local opacity = settings.backgroundOpacity / 100
    hud.control:SetDimensions(layout.width, layout.height)
    hud.background:SetCenterColor(0, 0, 0, opacity)
    hud.background:SetEdgeColor(0, 0, 0, 0)
    hud.headerMask:SetCenterColor(0, 0, 0, opacity)
    hud.headerMask:SetEdgeColor(0, 0, 0, 0)
    hud.headerMask:ClearAnchors()
    hud.headerMask:SetDimensions(layout.width, layout.contentTop)
    hud.headerMask:SetAnchor(TOPLEFT, hud.control, TOPLEFT, 0, 0)
    hud.headerMask:SetHidden(false)
    hud.footerMask:SetCenterColor(0, 0, 0, opacity)
    hud.footerMask:SetEdgeColor(0, 0, 0, 0)
    hud.footerMask:ClearAnchors()
    hud.footerMask:SetDimensions(layout.width, C.PADDING + layout.footerHeight)
    hud.footerMask:SetAnchor(BOTTOMLEFT, hud.control, BOTTOMLEFT, 0, 0)
    hud.footerMask:SetHidden(false)
    RenderWatermark(layout)

    hud.title:SetFont(GetFont(5))
    hud.title:SetText(NQOL.L("features.progress_infinite_archive.infinite_archive_52c9059"))
    hud.title:ClearAnchors()
    hud.title:SetDimensions(layout.contentWidth, layout.titleHeight)
    hud.title:SetAnchor(TOPLEFT, hud.control, TOPLEFT, C.PADDING + layout.contentInset, C.PADDING)

    local recordTop = C.PADDING + layout.titleHeight
    local recordWidth = math.floor((layout.contentWidth - C.RECORD_GAP) / 2)
    local recordsLeft = C.PADDING + layout.contentInset
    LayoutRecordDisplay(hud.soloRecord, "SOLO", GetRecord(C.GROUP_SOLO), recordsLeft, recordTop, recordWidth, layout.recordHeight, layout)
    LayoutRecordDisplay(hud.duoRecord, "DUO", GetRecord(C.GROUP_DUO), recordsLeft + recordWidth + C.RECORD_GAP, recordTop, recordWidth, layout.recordHeight, layout)

    hud.viewport:ClearAnchors()
    hud.viewport:SetDimensions(layout.contentWidth, layout.viewportHeight)
    hud.viewport:SetAnchor(TOPLEFT, hud.control, TOPLEFT, C.PADDING + layout.contentInset, layout.contentTop)
    hud.viewportHeight = layout.viewportHeight
    local contentHeight = 0
    for index, rowData in ipairs(achievementRows) do
        local rowControl = EnsureRow(index)
        local rowHeight = LayoutAchievementRow(rowControl, rowData, contentHeight, layout)
        contentHeight = contentHeight + rowHeight + C.ROW_GAP
    end
    for index = #achievementRows + 1, #(hud.rows or {}) do
        hud.rows[index].control:SetHidden(true)
        hud.rows[index].clipTop = nil
        hud.rows[index].clipBottom = nil
    end
    contentHeight = math.max(contentHeight - C.ROW_GAP, 0)
    hud.content:SetDimensions(layout.contentWidth, math.max(contentHeight, layout.viewportHeight))
    hud.maxScrollOffset = math.max(contentHeight - layout.viewportHeight, 0)
    hud.scrollOffset = Clamp(settings.scrollRatio * hud.maxScrollOffset, 0, hud.maxScrollOffset)
    ApplyScrollOffset()

    hud.empty:ClearAnchors()
    hud.empty:SetDimensions(layout.contentWidth, layout.viewportHeight)
    hud.empty:SetAnchor(TOPLEFT, hud.viewport, TOPLEFT, 0, 0)
    hud.empty:SetHidden(achievementCount > 0)

    local footerBottom = C.PADDING
    hud.footer:SetFont(GetFont(-5))
    hud.footer:SetText(string.format("%s · NQOL v%s", GetWatermarkText(), tostring(NQOL.version or 0)))
    hud.footer:ClearAnchors()
    hud.footer:SetDimensions(layout.innerWidth, layout.footerTextHeight)
    hud.footer:SetAnchor(BOTTOMLEFT, hud.control, BOTTOMLEFT, C.PADDING, -footerBottom)
    hud.footerSummary:SetFont(GetFont(-5))
    local footerColor = completedCount >= achievementCount and COLORS.complete or COLORS.incomplete
    SetColor(hud.footerSummary, footerColor)
    hud.footerSummary:SetText(NQOL.L("features.progress_infinite_archive.achievement_summary", completedCount, achievementCount))
    hud.footerSummary:ClearAnchors()
    hud.footerSummary:SetDimensions(layout.innerWidth, layout.footerTextHeight)
    hud.footerSummary:SetAnchor(BOTTOMLEFT, hud.control, BOTTOMLEFT, C.PADDING, -(footerBottom + layout.footerTextHeight + C.FOOTER_LINE_GAP))
    hud.footerDivider:ClearAnchors()
    hud.footerDivider:SetDimensions(layout.innerWidth, 1)
    hud.footerDivider:SetAnchor(BOTTOMLEFT, hud.control, BOTTOMLEFT, C.PADDING, -(footerBottom + (layout.footerTextHeight * 2) + C.FOOTER_LINE_GAP + C.FOOTER_DIVIDER_GAP))

    hud.control:SetHidden(false)
    ApplyPosition(layout)
    RefreshInputActivation()
end

local function HideHud()
    if not hud then return end
    hud.control:SetHidden(true)
    if DIRECTIONAL_INPUT and DIRECTIONAL_INPUT.IsListening and DIRECTIONAL_INPUT:IsListening(hud) then
        DIRECTIONAL_INPUT:Deactivate(hud)
    end
end

ApplyPosition = function(layout)
    if not hud or not hud.control or not GuiRoot then return end
    layout = layout or GetLayout()
    local settings = GetSettings()
    local maxX = math.max(layout.screenWidth - layout.width, 0)
    local maxY = math.max(layout.screenHeight - layout.height, 0)
    hud.control:ClearAnchors()
    hud.control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, maxX * (settings.horizontalPosition / 100), maxY * (settings.verticalPosition / 100))
end

RefreshInputActivation = function()
    if not hud or not DIRECTIONAL_INPUT then return end
    local listening = DIRECTIONAL_INPUT.IsListening and DIRECTIONAL_INPUT:IsListening(hud)
    local shouldListen = not hud.control:IsHidden() and (hud.maxScrollOffset or 0) > 0
    if shouldListen and not listening then
        DIRECTIONAL_INPUT:Activate(hud, hud.control)
    elseif not shouldListen and listening then
        DIRECTIONAL_INPUT:Deactivate(hud)
    end
end

function ProgressInfiniteArchive.UpdateDirectionalInput(elapsedSeconds)
    if not hud or hud.control:IsHidden() or not DIRECTIONAL_INPUT or not ZO_DI_RIGHT_STICK or (hud.maxScrollOffset or 0) <= 0 then
        return
    end

    local stickY = DIRECTIONAL_INPUT:GetY(ZO_DI_RIGHT_STICK) or 0
    if math.abs(stickY) <= C.SCROLL_DEADZONE then
        return
    end

    hud.scrollOffset = Clamp((hud.scrollOffset or 0) - (stickY * C.SCROLL_SPEED * (elapsedSeconds or 0)), 0, hud.maxScrollOffset)
    GetSettings().scrollRatio = hud.maxScrollOffset > 0 and (hud.scrollOffset / hud.maxScrollOffset) or 0
    ApplyScrollOffset()
    if DIRECTIONAL_INPUT.Consume then DIRECTIONAL_INPUT:Consume(ZO_DI_RIGHT_STICK) end
end

Refresh = function()
    if not settingsPanelVisible then
        HideHud()
        return
    end
    RenderHud()
end

local function OnAchievementChanged(_, achievementId)
    if settingsPanelVisible and (not achievementId or achievementIds[achievementId]) then
        Refresh()
    end
end

local function OnAchievementAwarded(_, _, _, achievementId)
    OnAchievementChanged(nil, achievementId)
end

RegisterDisplayEvents = function()
    if not EVENT_MANAGER or displayEventsRegistered then return end
    displayEventsRegistered = true

    if EVENT_ACHIEVEMENT_UPDATED then
        EVENT_MANAGER:RegisterForEvent(C.EVENT_NAMESPACE .. "_AchievementUpdated", EVENT_ACHIEVEMENT_UPDATED, OnAchievementChanged)
    end
    if EVENT_ACHIEVEMENT_AWARDED then
        EVENT_MANAGER:RegisterForEvent(C.EVENT_NAMESPACE .. "_AchievementAwarded", EVENT_ACHIEVEMENT_AWARDED, OnAchievementAwarded)
    end
    if EVENT_ACHIEVEMENTS_UPDATED then
        EVENT_MANAGER:RegisterForEvent(C.EVENT_NAMESPACE .. "_AchievementsUpdated", EVENT_ACHIEVEMENTS_UPDATED, OnAchievementChanged)
    end
    if EVENT_SCREEN_RESIZED then
        EVENT_MANAGER:RegisterForEvent(C.EVENT_NAMESPACE .. "_Screen", EVENT_SCREEN_RESIZED, Refresh)
    end
end

local function UnregisterDisplayEvents()
    if not EVENT_MANAGER or not displayEventsRegistered then return end
    displayEventsRegistered = false

    if EVENT_ACHIEVEMENT_UPDATED then
        EVENT_MANAGER:UnregisterForEvent(C.EVENT_NAMESPACE .. "_AchievementUpdated", EVENT_ACHIEVEMENT_UPDATED)
    end
    if EVENT_ACHIEVEMENT_AWARDED then
        EVENT_MANAGER:UnregisterForEvent(C.EVENT_NAMESPACE .. "_AchievementAwarded", EVENT_ACHIEVEMENT_AWARDED)
    end
    if EVENT_ACHIEVEMENTS_UPDATED then
        EVENT_MANAGER:UnregisterForEvent(C.EVENT_NAMESPACE .. "_AchievementsUpdated", EVENT_ACHIEVEMENTS_UPDATED)
    end
    if EVENT_SCREEN_RESIZED then
        EVENT_MANAGER:UnregisterForEvent(C.EVENT_NAMESPACE .. "_Screen", EVENT_SCREEN_RESIZED)
    end
end

function ProgressInfiniteArchive.InitializeSavedVariables()
    savedVariables = NQOL.Settings.NewAccountWide(defaults)
    GetSettings()
end

function ProgressInfiniteArchive.Initialize()
    if initialized then return end
    initialized = true
end

function ProgressInfiniteArchive.SetSettingsPanelVisible(value)
    local visible = value == true
    if settingsPanelVisible == visible then return end
    settingsPanelVisible = visible
    if visible then
        RegisterDisplayEvents()
        Refresh()
    else
        UnregisterDisplayEvents()
        HideHud()
    end
end

function ProgressInfiniteArchive.GetDetailLevel() return GetSettings().detailLevel end
function ProgressInfiniteArchive.SetDetailLevel(value) GetSettings().detailLevel = value; Refresh() end
function ProgressInfiniteArchive.GetDetailLevelChoices() local values = {}; for index, entry in ipairs(DETAIL_LEVELS) do values[index] = entry.key end return values end
function ProgressInfiniteArchive.GetDetailLevelChoiceNames() local values = {}; for index, entry in ipairs(DETAIL_LEVELS) do values[index] = entry.name end return values end
function ProgressInfiniteArchive.GetShowWatermark() return GetSettings().showWatermark end
function ProgressInfiniteArchive.GetShowWatermarkDefault() return defaults.progress.infiniteArchive.showWatermark end
function ProgressInfiniteArchive.SetShowWatermark(value) GetSettings().showWatermark = value == true; Refresh() end
function ProgressInfiniteArchive.GetHorizontalPosition() return GetSettings().horizontalPosition end
function ProgressInfiniteArchive.SetHorizontalPosition(value) GetSettings().horizontalPosition = Clamp(value, 0, 100); ApplyPosition() end
function ProgressInfiniteArchive.GetVerticalPosition() return GetSettings().verticalPosition end
function ProgressInfiniteArchive.SetVerticalPosition(value) GetSettings().verticalPosition = Clamp(value, 0, 100); ApplyPosition() end
function ProgressInfiniteArchive.GetFontChoices() return NQOL.Util.GetFontChoices() end
function ProgressInfiniteArchive.GetFontChoiceNames() return NQOL.Util.GetFontChoiceNames() end
function ProgressInfiniteArchive.GetFont() return GetSettings().font end
function ProgressInfiniteArchive.SetFont(value) if not NQOL.Util.IsFontChoice(value) then value = NQOL.Util.GetDefaultFont() end; GetSettings().font = value; fontStringCache = {}; Refresh() end
function ProgressInfiniteArchive.GetFontSize() return GetSettings().fontSize end
function ProgressInfiniteArchive.SetFontSize(value) GetSettings().fontSize = Clamp(Round(value), C.FONT_SIZE_MIN, C.FONT_SIZE_MAX); fontStringCache = {}; Refresh() end
function ProgressInfiniteArchive.GetFontSizeMin() return C.FONT_SIZE_MIN end
function ProgressInfiniteArchive.GetFontSizeMax() return C.FONT_SIZE_MAX end
function ProgressInfiniteArchive.GetBackgroundOpacity() return GetSettings().backgroundOpacity end
function ProgressInfiniteArchive.GetBackgroundOpacityDefault() return defaults.progress.infiniteArchive.backgroundOpacity end
function ProgressInfiniteArchive.SetBackgroundOpacity(value) GetSettings().backgroundOpacity = Clamp(Round(value), C.BACKGROUND_OPACITY_MIN, C.BACKGROUND_OPACITY_MAX); Refresh() end
function ProgressInfiniteArchive.GetBackgroundOpacityMin() return C.BACKGROUND_OPACITY_MIN end
function ProgressInfiniteArchive.GetBackgroundOpacityMax() return C.BACKGROUND_OPACITY_MAX end

function ProgressInfiniteArchive.GetDetailLevelLabel() return NQOL.L("features.progress_infinite_archive.detail_level_label") end
function ProgressInfiniteArchive.GetDetailLevelTooltip() return NQOL.L("features.progress_infinite_archive.detail_level_tooltip") end
function ProgressInfiniteArchive.GetShowWatermarkLabel() return NQOL.L("features.progress_infinite_archive.show_watermark_label") end
function ProgressInfiniteArchive.GetShowWatermarkTooltip() return NQOL.L("features.progress_infinite_archive.show_watermark_tooltip") end
function ProgressInfiniteArchive.GetHorizontalPositionLabel() return NQOL.L("features.progress_infinite_archive.horizontal_position_label") end
function ProgressInfiniteArchive.GetHorizontalPositionTooltip() return NQOL.L("features.progress_infinite_archive.horizontal_position_tooltip") end
function ProgressInfiniteArchive.GetVerticalPositionLabel() return NQOL.L("features.progress_infinite_archive.vertical_position_label") end
function ProgressInfiniteArchive.GetVerticalPositionTooltip() return NQOL.L("features.progress_infinite_archive.vertical_position_tooltip") end
function ProgressInfiniteArchive.GetFontLabel() return NQOL.L("features.progress_infinite_archive.font_label") end
function ProgressInfiniteArchive.GetFontTooltip() return NQOL.L("features.progress_infinite_archive.font_tooltip") end
function ProgressInfiniteArchive.GetFontSizeLabel() return NQOL.L("features.progress_infinite_archive.font_size_label") end
function ProgressInfiniteArchive.GetFontSizeTooltip() return NQOL.L("features.progress_infinite_archive.font_size_tooltip") end
function ProgressInfiniteArchive.GetBackgroundOpacityLabel() return NQOL.L("features.progress_infinite_archive.background_opacity_label") end
function ProgressInfiniteArchive.GetBackgroundOpacityTooltip() return NQOL.L("features.progress_infinite_archive.background_opacity_tooltip") end

NQOL.Features.ProgressInfiniteArchive = ProgressInfiniteArchive
