NCollections = NCollections or {}
NCollections.Features = NCollections.Features or {}

local CollectionsHud = {}

local C = {
    DRAW_LEVEL = 240,
    PADDING = 16,
    HEADER_HEIGHT = 76,
    FOOTER_HEIGHT = 44,
    PANE_GAP = 18,
    ROW_GAP = 4,
}

local COLORS = {
    background = { 0.018, 0.028, 0.045 },
    panelAlt = { 0.055, 0.08, 0.12 },
    selected = { 0.07, 0.31, 0.52 },
    accent = { 0.30, 0.76, 1 },
    text = { 0.94, 0.97, 1 },
    textMuted = { 0.63, 0.72, 0.82 },
    divider = { 0.25, 0.48, 0.68 },
}

local ui
local owner
local ownerRelease
local fontCache = {}

local function SetColor(control, color, alpha)
    control:SetColor(color[1], color[2], color[3], alpha or 1)
end

local function MoveAbove(control, level)
    if control.SetDrawTier and DT_HIGH then control:SetDrawTier(DT_HIGH) end
    if control.SetDrawLayer and DL_CONTROLS then control:SetDrawLayer(DL_CONTROLS) end
    if control.SetDrawLevel then control:SetDrawLevel(level or C.DRAW_LEVEL) end
end

local function GetFont(font, size)
    local key = tostring(font) .. "|" .. tostring(size)
    if not fontCache[key] then
        fontCache[key] = string.format("%s|%d|soft-shadow-thin", font, size)
    end
    return fontCache[key]
end

local function CreateLabel(parent, size, color, alignment)
    local label = WINDOW_MANAGER:CreateControl(nil, parent, CT_LABEL)
    label:SetFont(GetFont(NCollections.Util.GetDefaultFont(), size))
    SetColor(label, color or COLORS.text)
    label:SetHorizontalAlignment(alignment or TEXT_ALIGN_LEFT)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    if label.SetWrapMode and TEXT_WRAP_MODE_TRUNCATE then label:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE) end
    MoveAbove(label, C.DRAW_LEVEL + 5)
    return label
end

local function EnsureUi()
    if ui or not WINDOW_MANAGER or not GuiRoot then return ui end
    ui = { listRows = {}, inputDirection = 0, nextInputAt = 0 }
    ui.control = WINDOW_MANAGER:CreateTopLevelWindow("NCollectionsCollectionsHud")
    ui.control:SetHidden(true)
    MoveAbove(ui.control, C.DRAW_LEVEL)

    ui.background = WINDOW_MANAGER:CreateControl(nil, ui.control, CT_BACKDROP)
    ui.background:SetAnchorFill(ui.control)
    MoveAbove(ui.background, C.DRAW_LEVEL + 1)
    ui.title = CreateLabel(ui.control, 26, COLORS.text)
    ui.title:SetVerticalAlignment(TEXT_ALIGN_TOP)
    ui.verticalDivider = WINDOW_MANAGER:CreateControl(nil, ui.control, CT_TEXTURE)
    SetColor(ui.verticalDivider, COLORS.divider, 0.55)
    MoveAbove(ui.verticalDivider, C.DRAW_LEVEL + 3)
    ui.details = CreateLabel(ui.control, 19, COLORS.text)
    ui.details:SetVerticalAlignment(TEXT_ALIGN_TOP)
    ui.hint = CreateLabel(ui.control, 18, COLORS.textMuted, TEXT_ALIGN_RIGHT)
    return ui
end

local function EnsureRow(index)
    local row = ui.listRows[index]
    if row then return row end
    row = {}
    row.control = WINDOW_MANAGER:CreateControl(nil, ui.control, CT_CONTROL)
    row.background = WINDOW_MANAGER:CreateControl(nil, row.control, CT_BACKDROP)
    row.background:SetAnchorFill(row.control)
    MoveAbove(row.background, C.DRAW_LEVEL + 2)
    row.label = CreateLabel(row.control, 21, COLORS.text)
    row.label:SetAnchorFill(row.control)
    ui.listRows[index] = row
    return row
end

local function ResetControls()
    if not ui then return end
    for _, row in ipairs(ui.listRows) do
        row.entry = nil
        row.label:SetText("")
        row.control:SetHidden(true)
    end
    ui.title:SetText("")
    ui.details:SetText("")
    ui.hint:SetText("")
    ui.inputDirection = 0
    ui.nextInputAt = 0
    ui.layout = nil
end

function CollectionsHud.Acquire(ownerToken, releaseCallback, directionalCallback)
    if owner ~= ownerToken then
        local previousRelease = ownerRelease
        owner = nil
        ownerRelease = nil
        if previousRelease then previousRelease() end
        owner = ownerToken
        ownerRelease = releaseCallback
        ResetControls()
    end
    local currentUi = EnsureUi()
    if currentUi then currentUi.UpdateDirectionalInput = directionalCallback end
    return currentUi
end

function CollectionsHud.IsOwner(ownerToken)
    return owner == ownerToken
end

function CollectionsHud.Hide(ownerToken)
    if owner ~= ownerToken or not ui then return end
    ui.control:SetHidden(true)
    ui.inputDirection = 0
    ui.nextInputAt = 0
end

function CollectionsHud.Release(ownerToken)
    if owner ~= ownerToken then return end
    CollectionsHud.Hide(ownerToken)
    ResetControls()
    ui.UpdateDirectionalInput = nil
    owner = nil
    ownerRelease = nil
end

function CollectionsHud.Render(ownerToken, model)
    if owner ~= ownerToken then return nil end
    local currentUi = EnsureUi()
    if not currentUi then return nil end

    local layout = model.layout or {}
    local width = tonumber(layout.width) or 1100
    local height = tonumber(layout.height) or 700
    local scale = tonumber(layout.scale) or 1
    local screenWidth = tonumber(layout.screenWidth) or (GetScreenWidth and GetScreenWidth()) or 1920
    local screenHeight = tonumber(layout.screenHeight) or (GetScreenHeight and GetScreenHeight()) or 1080
    local innerWidth = width - (C.PADDING * 2)
    local leftWidth = math.floor(innerWidth * 0.38)
    local rightWidth = innerWidth - leftWidth - C.PANE_GAP
    local contentTop = C.PADDING + C.HEADER_HEIGHT
    local viewportTop = contentTop
    local viewportHeight = height - viewportTop - C.FOOTER_HEIGHT - C.PADDING
    local font = model.font or NCollections.Util.GetDefaultFont()
    local opacity = NCollections.Util.Clamp(tonumber(model.backgroundOpacity) or 90, 0, 100) / 100

    currentUi.control:SetDimensions(width, height)
    if currentUi.control.SetScale then currentUi.control:SetScale(scale) end
    currentUi.control:ClearAnchors()
    local maxX = math.max(screenWidth - (width * scale), 0)
    local maxY = math.max(screenHeight - (height * scale), 0)
    currentUi.control:SetAnchor(
        TOPLEFT,
        GuiRoot,
        TOPLEFT,
        maxX * (NCollections.Util.Clamp(tonumber(model.horizontalPosition) or 50, 0, 100) / 100),
        maxY * (NCollections.Util.Clamp(tonumber(model.verticalPosition) or 50, 0, 100) / 100)
    )
    currentUi.background:SetCenterColor(COLORS.background[1], COLORS.background[2], COLORS.background[3], opacity)
    currentUi.background:SetEdgeColor(COLORS.divider[1], COLORS.divider[2], COLORS.divider[3], math.min(opacity + 0.12, 1))

    currentUi.title:SetFont(GetFont(font, 26))
    currentUi.title:ClearAnchors()
    currentUi.title:SetDimensions(innerWidth, C.HEADER_HEIGHT - 8)
    currentUi.title:SetAnchor(TOPLEFT, currentUi.control, TOPLEFT, C.PADDING, C.PADDING - 2)
    local title = tostring(model.title or "")
    if model.summary and model.summary ~= "" then title = title .. "  |cA1B8D1· " .. tostring(model.summary) .. "|r" end
    if model.leftHeader and model.leftHeader ~= "" then title = title .. "\n|c4DC2FF" .. tostring(model.leftHeader) .. "|r" end
    currentUi.title:SetText(title)
    currentUi.verticalDivider:ClearAnchors()
    currentUi.verticalDivider:SetDimensions(1, height - contentTop - C.FOOTER_HEIGHT)
    currentUi.verticalDivider:SetAnchor(TOPLEFT, currentUi.control, TOPLEFT, C.PADDING + leftWidth + math.floor(C.PANE_GAP / 2), contentTop)

    local rows = model.rows or {}
    local visibleCount = math.max(#rows, 1)
    local rowHeight = NCollections.Util.Clamp(math.floor((viewportHeight - ((visibleCount - 1) * C.ROW_GAP)) / visibleCount), 34, 54)
    for index = 1, math.max(#rows, #currentUi.listRows) do
        local row = EnsureRow(index)
        local data = rows[index]
        row.entry = data and data.entry or nil
        row.control:SetHidden(not data)
        if data then
            row.control:ClearAnchors()
            row.control:SetDimensions(leftWidth - 2, rowHeight)
            row.control:SetAnchor(TOPLEFT, currentUi.control, TOPLEFT, C.PADDING, viewportTop + ((index - 1) * (rowHeight + C.ROW_GAP)))
            local selected = data.selected == true
            local header = data.header == true
            row.background:SetHidden(header)
            if not header then
                local color = selected and COLORS.selected or COLORS.panelAlt
                row.background:SetCenterColor(color[1], color[2], color[3], selected and 0.94 or 0.70)
                row.background:SetEdgeColor(COLORS.divider[1], COLORS.divider[2], COLORS.divider[3], selected and 0.72 or 0.28)
            end
            row.label:SetFont(GetFont(font, header and 22 or 20))
            row.label:SetColor(
                header and COLORS.accent[1] or COLORS.text[1],
                header and COLORS.accent[2] or COLORS.text[2],
                header and COLORS.accent[3] or COLORS.text[3],
                1
            )
            row.label:SetText(data.text or "")
        end
    end

    local detailsX = C.PADDING + leftWidth + C.PANE_GAP
    local detailsWidth = rightWidth

    currentUi.details:SetFont(GetFont(font, 19))
    currentUi.details:ClearAnchors()
    currentUi.details:SetDimensions(detailsWidth, viewportHeight)
    currentUi.details:SetAnchor(TOPLEFT, currentUi.control, TOPLEFT, detailsX, viewportTop)
    local details = tostring(model.details or "")
    if model.rightHeader and model.rightHeader ~= "" then details = "|c4DC2FF" .. tostring(model.rightHeader) .. "|r\n\n" .. details end
    currentUi.details:SetText(details)
    currentUi.hint:SetFont(GetFont(font, 18))
    currentUi.hint:ClearAnchors()
    currentUi.hint:SetDimensions(innerWidth, C.FOOTER_HEIGHT)
    currentUi.hint:SetAnchor(BOTTOMRIGHT, currentUi.control, BOTTOMRIGHT, -C.PADDING, 0)
    currentUi.hint:SetText(model.hint or "")
    currentUi.layout = layout
    currentUi.control:SetHidden(false)
    return currentUi
end

NCollections.Features.CollectionsHud = CollectionsHud
