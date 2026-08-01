NQOL = NQOL or {}
NQOL.Features = NQOL.Features or {}

local CollectionsHousing = {}

local C = {
    SEARCH_DIALOG_NAME = "NQOL_COLLECTIONS_HOUSING_SEARCH",
    DRAW_LEVEL = 240,
    SCALE_MIN = 50,
    SCALE_MAX = 150,
    BACKGROUND_OPACITY_MIN = 0,
    BACKGROUND_OPACITY_MAX = 100,
    SCREEN_MARGIN = 24,
    PADDING = 16,
    HEADER_HEIGHT = 66,
    FOOTER_HEIGHT = 44,
    PANE_HEADER_HEIGHT = 34,
    PANE_GAP = 18,
    PORTRAIT_STATUS_HEIGHT = 42,
    ROW_GAP = 4,
    INPUT_DEADZONE = 0.34,
    INPUT_INITIAL_DELAY_MS = 330,
    INPUT_REPEAT_DELAY_MS = 95,
    MIN_WIDTH = 900,
    MAX_WIDTH = 1420,
    MIN_HEIGHT = 540,
    MAX_HEIGHT = 820,
}

local COLORS = {
    background = { 0.018, 0.028, 0.045 },
    panel = { 0.035, 0.055, 0.085 },
    panelAlt = { 0.055, 0.08, 0.12 },
    selected = { 0.07, 0.31, 0.52 },
    accent = { 0.30, 0.76, 1 },
    complete = { 0.36, 0.92, 0.62 },
    missing = { 0.95, 0.42, 0.34 },
    text = { 0.94, 0.97, 1 },
    textMuted = { 0.63, 0.72, 0.82 },
    divider = { 0.25, 0.48, 0.68 },
}

local TEXTURES = {
    upArrow = "EsoUI/Art/Buttons/Gamepad/gp_upArrow.dds",
    downArrow = "EsoUI/Art/Buttons/Gamepad/gp_downArrow.dds",
}

local FILTERS = {
    { label = NQOL.L("features.collections_housing.all_houses_7c1e4f6") },
    { label = NQOL.L("features.collections_housing.acquired_houses_3726e95") },
    { label = NQOL.L("features.collections_housing.missing_houses_a331f41") },
}
NQOL.Lexicon.RegisterTableField(FILTERS, "label", {
    "features.collections_housing.all_houses_7c1e4f6", "features.collections_housing.acquired_houses_3726e95",
    "features.collections_housing.missing_houses_a331f41",
})

local DEFAULT_FONT_SIZE = 26
local defaults = {
    collections = {
        housing = {
            horizontalPosition = 50,
            verticalPosition = 50,
            font = NQOL.Util.GetDefaultFont(),
            scale = 100,
            backgroundOpacity = 90,
            selectedCollectibleId = 0,
        },
    },
}

local savedVariables
local initialized = false
local settingsPanelVisible = false
local dataReady = false
local hud
local houseRecords = {}
local filteredRecords = {}
local listEntries = {}
local recordEntryIndices = {}
local categoryGroups = {}
local categoryGroupPool = {}
local filterIndex = 1
local selectedIndex = 1
local visibleFirstIndex = 1
local fontStringCache = {}
local searchText = ""
local searchNeedle = ""
local searchDialogOpen = false
local searchDialogRegistered = false
local detailLineBuffer = {}
local detailRecordBuffer = {}
local inputHintCache = { {}, {}, {} }
local BuildHouseDetailText
local hudKeybindGroup
local hudKeybindsActive = false
local hudKeybindState
local Refresh
local ApplyPosition
local RefreshInputActivation
local RefreshHudKeybinds

local Clamp = NQOL.Util.Clamp
local Round = NQOL.Util.Round
local PORTRAIT_TEXTURE_RIGHT = Clamp(tonumber(ZO_GAMEPAD_COLLECTIONS_PANEL_TEXTURE_COORD_RIGHT) or 1, 0.1, 1)

local function ClearTable(values)
    for key in pairs(values) do
        values[key] = nil
    end
end

local function GetSettings()
    local collections = NQOL.Settings.GetSection(savedVariables, defaults, "collections")
    if type(collections.housing) ~= "table" then
        collections.housing = {}
    end

    local settings = collections.housing
    for key, value in pairs(defaults.collections.housing) do
        if settings[key] == nil then
            settings[key] = value
        end
    end

    settings.horizontalPosition = Clamp(tonumber(settings.horizontalPosition) or defaults.collections.housing.horizontalPosition, 0, 100)
    settings.verticalPosition = Clamp(tonumber(settings.verticalPosition) or defaults.collections.housing.verticalPosition, 0, 100)
    settings.scale = Clamp(Round(tonumber(settings.scale) or defaults.collections.housing.scale), C.SCALE_MIN, C.SCALE_MAX)
    settings.backgroundOpacity = Clamp(Round(tonumber(settings.backgroundOpacity) or defaults.collections.housing.backgroundOpacity), C.BACKGROUND_OPACITY_MIN, C.BACKGROUND_OPACITY_MAX)
    settings.selectedCollectibleId = tonumber(settings.selectedCollectibleId) or 0
    if not NQOL.Util.IsFontChoice(settings.font) then
        settings.font = NQOL.Util.GetDefaultFont()
    end
    return settings
end

local function GetFont(offset)
    local settings = GetSettings()
    local size = Clamp(DEFAULT_FONT_SIZE + (offset or 0), 10, 40)
    local key = tostring(settings.font) .. "|" .. tostring(size)
    if not fontStringCache[key] then
        fontStringCache[key] = string.format("%s|%d|soft-shadow-thin", settings.font, size)
    end
    return fontStringCache[key]
end

local function SetColor(control, color, alpha)
    control:SetColor(color[1], color[2], color[3], alpha or 1)
end

local function MoveAbove(control, level)
    if control.SetDrawTier and DT_HIGH then control:SetDrawTier(DT_HIGH) end
    if control.SetDrawLayer and DL_CONTROLS then control:SetDrawLayer(DL_CONTROLS) end
    if control.SetDrawLevel then control:SetDrawLevel(level or C.DRAW_LEVEL) end
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

local function CreateBackdrop(parent, color, edgeColor)
    local backdrop = WINDOW_MANAGER:CreateControl(nil, parent, CT_BACKDROP)
    backdrop:SetCenterColor(color[1], color[2], color[3], color[4] or 1)
    local edge = edgeColor or color
    backdrop:SetEdgeColor(edge[1], edge[2], edge[3], edge[4] or 1)
    MoveAbove(backdrop, C.DRAW_LEVEL + 1)
    return backdrop
end

local function FormatName(name)
    if ZO_CachedStrFormat and SI_COLLECTIBLE_NAME_FORMATTER then
        return ZO_CachedStrFormat(SI_COLLECTIBLE_NAME_FORMATTER, name or "")
    end
    return tostring(name or NQOL.L("features.collections_housing.unknown_house"))
end

local function FormatZoneName(zoneId)
    if not zoneId or zoneId == 0 or not GetZoneNameById then return NQOL.L("features.collections_housing.unknown_location") end
    local name = GetZoneNameById(zoneId)
    if ZO_CachedStrFormat and SI_ZONE_NAME then
        return ZO_CachedStrFormat(SI_ZONE_NAME, name or "")
    end
    return tostring(name or NQOL.L("features.collections_housing.unknown_location"))
end

local function GetHouseTypeName(houseId)
    if not GetHouseCategoryType or not GetString then return NQOL.L("features.collections_housing.house") end
    local categoryType = GetHouseCategoryType(houseId)
    local name = GetString("SI_HOUSECATEGORYTYPE", categoryType)
    return name ~= "" and name or NQOL.L("features.collections_housing.house")
end

local function MaskHasFlag(value, flag)
    if ZO_FlagHelpers and ZO_FlagHelpers.MaskHasFlag then
        return ZO_FlagHelpers.MaskHasFlag(value, flag)
    end
    if BitAnd then
        return BitAnd(value or 0, flag or 0) ~= 0
    end
    return false
end

local function GetPortrait(record)
    return record and record.portraitPath or "", PORTRAIT_TEXTURE_RIGHT
end

local function CompareHouses(left, right)
    if left.categoryType ~= right.categoryType then
        return left.categoryType < right.categoryType
    end
    local leftName = NQOL.Util.Lower(tostring(left.name or ""))
    local rightName = NQOL.Util.Lower(tostring(right.name or ""))
    if leftName ~= rightName then return leftName < rightName end
    return left.collectibleId < right.collectibleId
end

local function BuildHouseRecords()
    ClearTable(houseRecords)
    ClearTable(detailRecordBuffer)
    dataReady = false

    if not ZO_COLLECTIBLE_DATA_MANAGER or not ZO_CollectibleCategoryData or not ZO_CollectibleCategoryData.IsHousingCategory then
        return
    end

    local collectibles = ZO_COLLECTIBLE_DATA_MANAGER:GetAllCollectibleDataObjects({ ZO_CollectibleCategoryData.IsHousingCategory })
    for _, collectibleData in ipairs(collectibles or {}) do
        local houseId = collectibleData:GetReferenceId()
        if houseId and houseId > 0 then
            local collectibleId = collectibleData:GetId()
            local isAcquired = collectibleData:IsUnlocked()
            local houseFlags = collectibleData.GetHouseFlags and collectibleData:GetHouseFlags() or 0
            local nickname = isAcquired and collectibleData:GetNickname() or ""
            local locationId = GetHouseFoundInZoneId and GetHouseFoundInZoneId(houseId) or 0
            local categoryType = GetHouseCategoryType and GetHouseCategoryType(houseId) or 0
            local categoryName = GetHouseTypeName(houseId)
            local location = FormatZoneName(locationId)
            local detailRecord = detailRecordBuffer
            detailRecord.houseId = houseId
            detailRecord.nickname = nickname or ""
            detailRecord.description = collectibleData:GetDescription() or ""
            detailRecord.hint = not isAcquired and collectibleData:GetHint() or ""
            detailRecord.isAcquired = isAcquired
            detailRecord.isPrimary = isAcquired and collectibleData:IsPrimaryResidence() or false
            detailRecord.supportsWeatherControl = HOUSE_FLAGS_SUPPORTS_WEATHER_CONTROL and MaskHasFlag(houseFlags, HOUSE_FLAGS_SUPPORTS_WEATHER_CONTROL) or false
            detailRecord.recommendations = GetNumHouseToursPlayerListingRecommendations and GetNumHouseToursPlayerListingRecommendations(houseId) or 0
            local record = {
                collectibleId = collectibleId,
                houseId = houseId,
                name = FormatName(collectibleData:GetName()),
                isAcquired = isAcquired,
                categoryType = categoryType,
                categoryName = categoryName,
                portraitPath = collectibleData.GetGamepadBackgroundImage and collectibleData:GetGamepadBackgroundImage() or "",
                metaText = categoryName .. "  •  " .. location,
                detailText = BuildHouseDetailText(detailRecord),
            }
            houseRecords[#houseRecords + 1] = record
        end
    end

    ClearTable(detailRecordBuffer)
    table.sort(houseRecords, CompareHouses)
    dataReady = true
end

local function MatchesFilter(record)
    if filterIndex == 2 and not record.isAcquired then return false end
    if filterIndex == 3 and record.isAcquired then return false end
    if searchNeedle ~= "" then
        local name = NQOL.Util.Lower(tostring(record.name or ""))
        if not string.find(name, searchNeedle, 1, true) then return false end
    end
    return true
end

local function GetSelectedRecord()
    return filteredRecords[selectedIndex]
end

local function RebuildFilteredRecords(preferredCollectibleId)
    ClearTable(filteredRecords)
    ClearTable(listEntries)
    ClearTable(recordEntryIndices)
    ClearTable(categoryGroups)

    local previousCategoryType
    for _, record in ipairs(houseRecords) do
        if MatchesFilter(record) then
            if record.categoryType ~= previousCategoryType then
                local groupIndex = #categoryGroups + 1
                local group = categoryGroupPool[groupIndex]
                if not group then
                    group = {}
                    categoryGroupPool[groupIndex] = group
                end
                group.categoryType = record.categoryType
                group.label = record.categoryName
                group.startIndex = #filteredRecords + 1
                categoryGroups[groupIndex] = group
                listEntries[#listEntries + 1] = { isHeader = true, label = record.categoryName }
                group.entryIndex = #listEntries
                previousCategoryType = record.categoryType
            end
            filteredRecords[#filteredRecords + 1] = record
            record.groupIndex = #categoryGroups
            listEntries[#listEntries + 1] = record
            recordEntryIndices[record.collectibleId] = #listEntries
        end
    end

    selectedIndex = 0
    local requestedId = preferredCollectibleId or GetSettings().selectedCollectibleId
    for index, record in ipairs(filteredRecords) do
        if record.collectibleId == requestedId then
            selectedIndex = index
            break
        end
    end
    if selectedIndex == 0 and #filteredRecords > 0 then selectedIndex = 1 end

    local selectedRecord = GetSelectedRecord()
    if selectedRecord then
        GetSettings().selectedCollectibleId = selectedRecord.collectibleId
        visibleFirstIndex = math.max((recordEntryIndices[selectedRecord.collectibleId] or 1) - 2, 1)
    else
        visibleFirstIndex = 1
    end
end

local function GetScreenDimensions()
    local width, height = GuiRoot:GetDimensions()
    return tonumber(width) or 1920, tonumber(height) or 1080
end

local function GetLayout()
    local screenWidth, screenHeight = GetScreenDimensions()
    local settings = GetSettings()
    local scale = settings.scale / 100
    local availableWidth = math.max((screenWidth - (C.SCREEN_MARGIN * 2)) / scale, C.MIN_WIDTH)
    local availableHeight = math.max((screenHeight - (C.SCREEN_MARGIN * 2)) / scale, C.MIN_HEIGHT)
    local width = Clamp(math.floor(availableWidth * 0.86), C.MIN_WIDTH, C.MAX_WIDTH)
    local height = Clamp(math.floor(availableHeight * 0.80), C.MIN_HEIGHT, C.MAX_HEIGHT)
    local innerWidth = width - (C.PADDING * 2)
    local contentTop = C.PADDING + C.HEADER_HEIGHT
    local contentHeight = height - contentTop - C.FOOTER_HEIGHT - C.PADDING
    local leftWidth = math.floor(innerWidth * 0.34)
    local rightWidth = innerWidth - leftWidth - C.PANE_GAP
    local detailWidth = math.floor(rightWidth * 0.37)
    local portraitWidth = rightWidth - detailWidth - C.PANE_GAP
    local viewportHeight = contentHeight - C.PANE_HEADER_HEIGHT
    local rowHeight = Clamp(math.floor(viewportHeight / 11) - C.ROW_GAP, 38, 54)
    local visibleRows = math.max(math.floor((viewportHeight + C.ROW_GAP) / (rowHeight + C.ROW_GAP)), 1)
    return {
        screenWidth = screenWidth,
        screenHeight = screenHeight,
        scale = scale,
        width = width,
        height = height,
        innerWidth = innerWidth,
        contentTop = contentTop,
        contentHeight = contentHeight,
        leftWidth = leftWidth,
        rightWidth = rightWidth,
        detailWidth = detailWidth,
        portraitWidth = portraitWidth,
        viewportHeight = viewportHeight,
        rowHeight = rowHeight,
        visibleRows = visibleRows,
        portraitTop = C.PORTRAIT_STATUS_HEIGHT,
        portraitHeight = viewportHeight - C.PORTRAIT_STATUS_HEIGHT,
    }
end

local function EnsureListRow(index)
    hud.listRows = hud.listRows or {}
    if hud.listRows[index] then return hud.listRows[index] end

    local row = {}
    row.control = WINDOW_MANAGER:CreateControl(nil, hud.leftViewport, CT_CONTROL)
    row.background = CreateBackdrop(row.control, { COLORS.panelAlt[1], COLORS.panelAlt[2], COLORS.panelAlt[3], 0.72 }, { COLORS.divider[1], COLORS.divider[2], COLORS.divider[3], 0.28 })
    row.background:SetAnchorFill(row.control)
    row.accent = WINDOW_MANAGER:CreateControl(nil, row.control, CT_TEXTURE)
    SetColor(row.accent, COLORS.accent)
    MoveAbove(row.accent, C.DRAW_LEVEL + 6)
    row.header = CreateLabel(row.control, -3, COLORS.accent)
    row.name = CreateLabel(row.control, -3, COLORS.text)
    row.status = CreateLabel(row.control, -7, COLORS.textMuted, TEXT_ALIGN_RIGHT)
    hud.listRows[index] = row
    return row
end

local function EnsureHud()
    if hud or not WINDOW_MANAGER or not GuiRoot then return hud end

    hud = { inputDirection = 0, nextInputAt = 0 }
    hud.control = WINDOW_MANAGER:CreateTopLevelWindow("NQOLCollectionsHousing")
    hud.control:SetHidden(true)
    MoveAbove(hud.control, C.DRAW_LEVEL)
    hud.UpdateDirectionalInput = function()
        CollectionsHousing.UpdateDirectionalInput()
    end

    local opacity = GetSettings().backgroundOpacity / 100
    hud.background = CreateBackdrop(hud.control, { COLORS.background[1], COLORS.background[2], COLORS.background[3], opacity }, { COLORS.divider[1], COLORS.divider[2], COLORS.divider[3], math.min(opacity + 0.12, 1) })
    hud.background:SetAnchorFill(hud.control)
    hud.title = CreateLabel(hud.control, 5, COLORS.text)
    hud.summary = CreateLabel(hud.control, -3, COLORS.textMuted, TEXT_ALIGN_RIGHT)
    hud.headerDivider = WINDOW_MANAGER:CreateControl(nil, hud.control, CT_TEXTURE)
    SetColor(hud.headerDivider, COLORS.divider, 0.72)
    MoveAbove(hud.headerDivider, C.DRAW_LEVEL + 3)

    hud.leftHeader = CreateLabel(hud.control, -3, COLORS.accent)
    hud.rightHeader = CreateLabel(hud.control, -3, COLORS.accent)
    hud.leftViewport = WINDOW_MANAGER:CreateControl(nil, hud.control, CT_CONTROL)
    if hud.leftViewport.SetClipsChildren then hud.leftViewport:SetClipsChildren(true) end
    MoveAbove(hud.leftViewport, C.DRAW_LEVEL + 2)
    hud.rightViewport = WINDOW_MANAGER:CreateControl(nil, hud.control, CT_CONTROL)
    if hud.rightViewport.SetClipsChildren then hud.rightViewport:SetClipsChildren(true) end
    MoveAbove(hud.rightViewport, C.DRAW_LEVEL + 2)
    hud.verticalDivider = WINDOW_MANAGER:CreateControl(nil, hud.control, CT_TEXTURE)
    SetColor(hud.verticalDivider, COLORS.divider, 0.55)
    MoveAbove(hud.verticalDivider, C.DRAW_LEVEL + 3)

    hud.upArrow = WINDOW_MANAGER:CreateControl(nil, hud.control, CT_TEXTURE)
    hud.upArrow:SetTexture(TEXTURES.upArrow)
    SetColor(hud.upArrow, COLORS.accent)
    MoveAbove(hud.upArrow, C.DRAW_LEVEL + 6)
    hud.downArrow = WINDOW_MANAGER:CreateControl(nil, hud.control, CT_TEXTURE)
    hud.downArrow:SetTexture(TEXTURES.downArrow)
    SetColor(hud.downArrow, COLORS.accent)
    MoveAbove(hud.downArrow, C.DRAW_LEVEL + 6)

    hud.photoFrame = CreateBackdrop(hud.rightViewport, { 0.01, 0.015, 0.025, 0.98 }, { COLORS.divider[1], COLORS.divider[2], COLORS.divider[3], 0.75 })
    hud.photo = WINDOW_MANAGER:CreateControl(nil, hud.rightViewport, CT_TEXTURE)
    if hud.photo.SetTextureCoords then hud.photo:SetTextureCoords(0, PORTRAIT_TEXTURE_RIGHT, 0, 1) end
    if hud.photo.SetDesaturation then hud.photo:SetDesaturation(0) end
    MoveAbove(hud.photo, C.DRAW_LEVEL + 4)
    hud.photoPlaceholder = CreateLabel(hud.rightViewport, -2, COLORS.textMuted, TEXT_ALIGN_CENTER)
    hud.photoPlaceholder:SetText(NQOL.L("features.collections_housing.no_portrait_is_available_for_this_house_e55108c"))
    NQOL.Util.ConfigureContentTexture(hud.photo, hud.photoPlaceholder, hud.photoFrame)
    hud.portraitDivider = WINDOW_MANAGER:CreateControl(nil, hud.rightViewport, CT_TEXTURE)
    SetColor(hud.portraitDivider, COLORS.divider, 0.38)
    MoveAbove(hud.portraitDivider, C.DRAW_LEVEL + 3)

    hud.houseName = CreateLabel(hud.rightViewport, 2, COLORS.text)
    hud.houseName:SetVerticalAlignment(TEXT_ALIGN_TOP)
    hud.status = CreateLabel(hud.rightViewport, -3, COLORS.complete, TEXT_ALIGN_RIGHT)
    hud.meta = CreateLabel(hud.rightViewport, -4, COLORS.textMuted)
    hud.meta:SetVerticalAlignment(TEXT_ALIGN_TOP)
    hud.details = CreateLabel(hud.rightViewport, -4, COLORS.text)
    hud.details:SetVerticalAlignment(TEXT_ALIGN_TOP)
    if hud.details.SetWrapMode and TEXT_WRAP_MODE_TRUNCATE then hud.details:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE) end

    hud.empty = CreateLabel(hud.leftViewport, -1, COLORS.textMuted, TEXT_ALIGN_CENTER)
    hud.footerDivider = WINDOW_MANAGER:CreateControl(nil, hud.control, CT_TEXTURE)
    SetColor(hud.footerDivider, COLORS.divider, 0.65)
    MoveAbove(hud.footerDivider, C.DRAW_LEVEL + 3)
    hud.hint = CreateLabel(hud.control, -4, COLORS.textMuted, TEXT_ALIGN_RIGHT)
    return hud
end

local function ApplyBackground()
    if not hud then return end
    local opacity = GetSettings().backgroundOpacity / 100
    hud.background:SetCenterColor(COLORS.background[1], COLORS.background[2], COLORS.background[3], opacity)
    hud.background:SetEdgeColor(COLORS.divider[1], COLORS.divider[2], COLORS.divider[3], math.min(opacity + 0.12, 1))
end

local function ApplyFonts()
    if not hud then return end
    hud.title:SetFont(GetFont(5))
    hud.summary:SetFont(GetFont(-3))
    hud.leftHeader:SetFont(GetFont(-3))
    hud.rightHeader:SetFont(GetFont(-3))
    hud.photoPlaceholder:SetFont(GetFont(-2))
    hud.houseName:SetFont(GetFont(2))
    hud.status:SetFont(GetFont(-3))
    hud.meta:SetFont(GetFont(-4))
    hud.details:SetFont(GetFont(-4))
    hud.empty:SetFont(GetFont(-1))
    hud.hint:SetFont(GetFont(-4))
    for _, row in ipairs(hud.listRows or {}) do
        row.header:SetFont(GetFont(-3))
        row.name:SetFont(GetFont(-3))
        row.status:SetFont(GetFont(-7))
    end
end

local function LayoutHud(layout)
    EnsureHud()
    if not hud then return end
    hud.control:SetDimensions(layout.width, layout.height)
    if hud.control.SetScale then hud.control:SetScale(layout.scale) end
    hud.layout = layout

    hud.title:ClearAnchors()
    hud.title:SetDimensions(layout.leftWidth, C.HEADER_HEIGHT - 8)
    hud.title:SetAnchor(TOPLEFT, hud.control, TOPLEFT, C.PADDING, C.PADDING - 2)
    hud.summary:ClearAnchors()
    hud.summary:SetDimensions(layout.rightWidth, C.HEADER_HEIGHT - 8)
    hud.summary:SetAnchor(TOPRIGHT, hud.control, TOPRIGHT, -C.PADDING, C.PADDING - 2)
    hud.headerDivider:ClearAnchors()
    hud.headerDivider:SetDimensions(layout.innerWidth, 1)
    hud.headerDivider:SetAnchor(TOPLEFT, hud.control, TOPLEFT, C.PADDING, C.PADDING + C.HEADER_HEIGHT - 7)

    hud.leftHeader:ClearAnchors()
    hud.leftHeader:SetDimensions(layout.leftWidth, C.PANE_HEADER_HEIGHT)
    hud.leftHeader:SetAnchor(TOPLEFT, hud.control, TOPLEFT, C.PADDING, layout.contentTop)
    hud.rightHeader:ClearAnchors()
    hud.rightHeader:SetDimensions(layout.rightWidth, C.PANE_HEADER_HEIGHT)
    hud.rightHeader:SetAnchor(TOPLEFT, hud.control, TOPLEFT, C.PADDING + layout.leftWidth + C.PANE_GAP, layout.contentTop)
    hud.leftViewport:ClearAnchors()
    hud.leftViewport:SetDimensions(layout.leftWidth, layout.viewportHeight)
    hud.leftViewport:SetAnchor(TOPLEFT, hud.control, TOPLEFT, C.PADDING, layout.contentTop + C.PANE_HEADER_HEIGHT)
    hud.rightViewport:ClearAnchors()
    hud.rightViewport:SetDimensions(layout.rightWidth, layout.viewportHeight)
    hud.rightViewport:SetAnchor(TOPLEFT, hud.control, TOPLEFT, C.PADDING + layout.leftWidth + C.PANE_GAP, layout.contentTop + C.PANE_HEADER_HEIGHT)
    hud.verticalDivider:ClearAnchors()
    hud.verticalDivider:SetDimensions(1, layout.contentHeight)
    hud.verticalDivider:SetAnchor(TOPLEFT, hud.control, TOPLEFT, C.PADDING + layout.leftWidth + math.floor(C.PANE_GAP / 2), layout.contentTop)

    hud.portraitDivider:ClearAnchors()
    hud.portraitDivider:SetDimensions(1, layout.viewportHeight)
    hud.portraitDivider:SetAnchor(TOPLEFT, hud.rightViewport, TOPLEFT, layout.detailWidth + math.floor(C.PANE_GAP / 2), 0)
    hud.photoPlaceholder:ClearAnchors()
    hud.photoPlaceholder:SetDimensions(layout.portraitWidth - 30, 80)
    hud.photoPlaceholder:SetAnchor(CENTER, hud.rightViewport, TOPLEFT, layout.detailWidth + C.PANE_GAP + math.floor(layout.portraitWidth / 2), layout.portraitTop + math.floor(layout.portraitHeight / 2))

    hud.houseName:ClearAnchors()
    hud.houseName:SetDimensions(layout.detailWidth, 40)
    hud.houseName:SetAnchor(TOPLEFT, hud.rightViewport, TOPLEFT, 0, 0)
    hud.status:ClearAnchors()
    hud.status:SetDimensions(layout.portraitWidth - 20, 38)
    hud.status:SetAnchor(TOPRIGHT, hud.rightViewport, TOPRIGHT, -10, 8)
    hud.meta:ClearAnchors()
    hud.meta:SetDimensions(layout.detailWidth, 58)
    hud.meta:SetAnchor(TOPLEFT, hud.rightViewport, TOPLEFT, 0, 38)
    hud.details:ClearAnchors()
    hud.details:SetDimensions(layout.detailWidth, math.max(layout.viewportHeight - 110, 40))
    hud.details:SetAnchor(TOPLEFT, hud.rightViewport, TOPLEFT, 0, 110)

    hud.upArrow:ClearAnchors()
    hud.upArrow:SetDimensions(24, 24)
    hud.upArrow:SetAnchor(RIGHT, hud.leftHeader, RIGHT, -3, 0)
    hud.downArrow:ClearAnchors()
    hud.downArrow:SetDimensions(24, 24)
    hud.downArrow:SetAnchor(BOTTOMRIGHT, hud.leftViewport, BOTTOMRIGHT, -3, -1)
    hud.empty:ClearAnchors()
    hud.empty:SetDimensions(layout.leftWidth - 30, 80)
    hud.empty:SetAnchor(CENTER, hud.leftViewport, CENTER, 0, 0)

    hud.footerDivider:ClearAnchors()
    hud.footerDivider:SetDimensions(layout.innerWidth, 1)
    hud.footerDivider:SetAnchor(BOTTOMLEFT, hud.control, BOTTOMLEFT, C.PADDING, -(C.FOOTER_HEIGHT + 1))
    hud.hint:ClearAnchors()
    hud.hint:SetDimensions(layout.innerWidth, C.FOOTER_HEIGHT)
    hud.hint:SetAnchor(BOTTOMRIGHT, hud.control, BOTTOMRIGHT, -C.PADDING, 0)
end

local function KeepSelectionVisible(layout)
    local previousFirstIndex = visibleFirstIndex
    local selectedRecord = GetSelectedRecord()
    local selectedEntryIndex = selectedRecord and recordEntryIndices[selectedRecord.collectibleId] or 1
    if selectedEntryIndex < visibleFirstIndex then
        visibleFirstIndex = selectedEntryIndex
    elseif selectedEntryIndex >= visibleFirstIndex + layout.visibleRows then
        visibleFirstIndex = selectedEntryIndex - layout.visibleRows + 1
    end
    visibleFirstIndex = Clamp(visibleFirstIndex, 1, math.max(#listEntries - layout.visibleRows + 1, 1))
    return visibleFirstIndex ~= previousFirstIndex
end

local function SetListRowSelected(row, selected)
    row.accent:SetHidden(not selected)
    row.background:SetCenterColor(
        selected and COLORS.selected[1] or COLORS.panelAlt[1],
        selected and COLORS.selected[2] or COLORS.panelAlt[2],
        selected and COLORS.selected[3] or COLORS.panelAlt[3],
        selected and 0.94 or 0.70
    )
end

local function RenderHouseList(layout)
    KeepSelectionVisible(layout)
    local selectedRecord = GetSelectedRecord()
    hud.selectedListRow = nil
    for poolIndex = 1, math.max(layout.visibleRows, #(hud.listRows or {})) do
        local row = EnsureListRow(poolIndex)
        local entryIndex = visibleFirstIndex + poolIndex - 1
        local entry = listEntries[entryIndex]
        local visible = poolIndex <= layout.visibleRows and entry ~= nil
        row.entry = visible and entry or nil
        row.control:SetHidden(not visible)
        if visible then
            row.control:ClearAnchors()
            row.control:SetDimensions(layout.leftWidth - 2, layout.rowHeight)
            row.control:SetAnchor(TOPLEFT, hud.leftViewport, TOPLEFT, 0, (poolIndex - 1) * (layout.rowHeight + C.ROW_GAP))
            if entry.isHeader then
                row.background:SetHidden(true)
                row.accent:SetHidden(true)
                row.name:SetHidden(true)
                row.status:SetHidden(true)
                row.header:SetHidden(false)
                row.header:ClearAnchors()
                row.header:SetDimensions(layout.leftWidth - 20, layout.rowHeight)
                row.header:SetAnchor(LEFT, row.control, LEFT, 10, 0)
                row.header:SetText(NQOL.Util.Upper(entry.label or NQOL.L("collections.housing.title")))
            else
                local selected = selectedRecord == entry
                if selected then hud.selectedListRow = row end
                row.header:SetHidden(true)
                row.background:SetHidden(false)
                SetListRowSelected(row, selected)
                row.accent:ClearAnchors()
                row.accent:SetDimensions(5, layout.rowHeight)
                row.accent:SetAnchor(TOPLEFT, row.control, TOPLEFT, 0, 0)
                row.name:SetHidden(false)
                row.name:ClearAnchors()
                row.name:SetDimensions(layout.leftWidth - 118, layout.rowHeight)
                row.name:SetAnchor(LEFT, row.control, LEFT, 13, 0)
                row.name:SetText(entry.name)
                row.status:SetHidden(false)
                row.status:ClearAnchors()
                row.status:SetDimensions(94, layout.rowHeight)
                row.status:SetAnchor(RIGHT, row.control, RIGHT, -10, 0)
                row.status:SetText(entry.isAcquired and NQOL.L("common.acquired") or NQOL.L("common.missing"))
                SetColor(row.status, entry.isAcquired and COLORS.complete or COLORS.missing)
            end
        end
    end
    hud.upArrow:SetHidden(visibleFirstIndex <= 1)
    hud.downArrow:SetHidden(visibleFirstIndex + layout.visibleRows - 1 >= #listEntries)
    hud.empty:SetHidden(#filteredRecords > 0)
    if #filteredRecords == 0 then
        if searchText ~= "" then
            hud.empty:SetText(NQOL.L("collections.no_search_results", NQOL.Util.Lower(NQOL.L("collections.housing.title")), searchText))
        else
            hud.empty:SetText(NQOL.L("features.collections_housing.no_houses_match_the_selected_filter_22a46f0"))
        end
    end
end

local function RenderHouseListSelection(layout)
    if KeepSelectionVisible(layout) then
        RenderHouseList(layout)
        return
    end

    local selectedRecord = GetSelectedRecord()
    local selectedRow
    for _, row in ipairs(hud.listRows or {}) do
        if row.entry == selectedRecord then
            selectedRow = row
            break
        end
    end
    if hud.selectedListRow and hud.selectedListRow ~= selectedRow then
        SetListRowSelected(hud.selectedListRow, false)
    end
    if selectedRow and hud.selectedListRow ~= selectedRow then
        SetListRowSelected(selectedRow, true)
    end
    hud.selectedListRow = selectedRow
end

local function AddDetailLine(lines, label, value)
    if value and value ~= "" then
        lines[#lines + 1] = string.format("|c72BEEB%s:|r %s", label, tostring(value))
    end
end

local function AddFurnishingLimitLines(lines, record)
    if not record or not GetHouseFurnishingPlacementLimit then return end
    if HOUSING_FURNISHING_LIMIT_TYPE_LOW_IMPACT_ITEM then
        local count = GetHouseFurnishingPlacementLimit(record.houseId, HOUSING_FURNISHING_LIMIT_TYPE_LOW_IMPACT_ITEM) or 0
        if count > 0 then AddDetailLine(lines, NQOL.L("features.collections_housing.furnishing_limit"), count) end
    end
    if HOUSING_FURNISHING_LIMIT_TYPE_LOW_IMPACT_COLLECTIBLE then
        local count = GetHouseFurnishingPlacementLimit(record.houseId, HOUSING_FURNISHING_LIMIT_TYPE_LOW_IMPACT_COLLECTIBLE) or 0
        if count > 0 then AddDetailLine(lines, NQOL.L("features.collections_housing.collectible_limit"), count) end
    end
    if HOUSING_FURNISHING_LIMIT_TYPE_HIGH_IMPACT_ITEM then
        local count = GetHouseFurnishingPlacementLimit(record.houseId, HOUSING_FURNISHING_LIMIT_TYPE_HIGH_IMPACT_ITEM) or 0
        if count > 0 then AddDetailLine(lines, NQOL.L("features.collections_housing.special_furnishing_limit"), count) end
    end
    if HOUSING_FURNISHING_LIMIT_TYPE_HIGH_IMPACT_COLLECTIBLE then
        local count = GetHouseFurnishingPlacementLimit(record.houseId, HOUSING_FURNISHING_LIMIT_TYPE_HIGH_IMPACT_COLLECTIBLE) or 0
        if count > 0 then AddDetailLine(lines, NQOL.L("features.collections_housing.special_collectible_limit"), count) end
    end
end

BuildHouseDetailText = function(record)
    local lines = detailLineBuffer
    ClearTable(lines)
    if record.nickname ~= "" then AddDetailLine(lines, NQOL.L("features.collections_housing.nickname"), record.nickname) end
    if record.isAcquired then AddDetailLine(lines, NQOL.L("features.collections_housing.primary_residence"), record.isPrimary and NQOL.L("common.yes") or NQOL.L("common.no")) end
    AddDetailLine(lines, NQOL.L("features.collections_housing.weather_control"), record.supportsWeatherControl and NQOL.L("common.supported") or NQOL.L("common.not_supported"))
    AddFurnishingLimitLines(lines, record)
    if record.recommendations and record.recommendations > 0 then
        AddDetailLine(lines, NQOL.L("features.collections_housing.home_tour_recommendations"), record.recommendations)
    end
    if record.description ~= "" then lines[#lines + 1] = "\n" .. record.description end
    if not record.isAcquired and record.hint ~= "" then
        lines[#lines + 1] = ""
        AddDetailLine(lines, NQOL.L("collections.detail.how_to_acquire"), record.hint)
    end
    return table.concat(lines, "\n")
end

local function LayoutPortrait(textureRight)
    local layout = hud and hud.layout
    if not layout then return end
    local maxWidth = math.max(layout.portraitWidth - 8, 1)
    local maxHeight = math.max(layout.portraitHeight - 8, 1)
    local aspect = Clamp(tonumber(textureRight) or 1, 0.1, 1)
    if hud.photoLayout == layout and hud.photoAspect == aspect then return end
    hud.photoLayout = layout
    hud.photoAspect = aspect
    local width = maxWidth
    local height = width / aspect
    if height > maxHeight then
        height = maxHeight
        width = height * aspect
    end
    width = math.max(math.floor(width), 1)
    height = math.max(math.floor(height), 1)
    local centerX = layout.detailWidth + C.PANE_GAP + math.floor(layout.portraitWidth / 2)
    local centerY = layout.portraitTop + math.floor(layout.portraitHeight / 2)

    hud.photoFrame:ClearAnchors()
    hud.photoFrame:SetDimensions(width + 4, height + 4)
    hud.photoFrame:SetAnchor(CENTER, hud.rightViewport, TOPLEFT, centerX, centerY)
    hud.status:ClearAnchors()
    hud.status:SetDimensions(math.max(width - 20, 1), 38)
    hud.status:SetAnchor(BOTTOMRIGHT, hud.photoFrame, TOPRIGHT, 0, -4)
    hud.photo:ClearAnchors()
    hud.photo:SetDimensions(width, height)
    hud.photo:SetAnchor(CENTER, hud.photoFrame, CENTER, 0, 0)
end

local function ReleasePhotoTexture()
    if not hud or not hud.photo then return end
    NQOL.Util.ReleaseContentTexture(hud.photo)
    hud.currentPhotoPath = nil
end

local function RenderHouseDetails(record)
    if not record then
        ReleasePhotoTexture()
        hud.photo:SetHidden(true)
        hud.photoFrame:SetHidden(true)
        hud.photoPlaceholder:SetHidden(false)
        hud.houseName:SetText(NQOL.L("features.collections_housing.no_house_selected_38f1c34"))
        hud.status:SetText("")
        hud.meta:SetText("")
        hud.details:SetText("")
        return
    end

    local portraitPath, textureRight = GetPortrait(record)
    local hasImage = portraitPath ~= ""
    if hasImage then
        LayoutPortrait(textureRight)
        if hud.currentPhotoPath == portraitPath then
            if not hud.photo.IsTextureLoaded or hud.photo:IsTextureLoaded() then
                hud.photo:SetHidden(false)
                hud.photoFrame:SetHidden(false)
                hud.photoPlaceholder:SetHidden(true)
            end
        else
            hud.currentPhotoPath = portraitPath
            NQOL.Util.LoadContentTexture(hud.photo, portraitPath)
        end
    else
        ReleasePhotoTexture()
        hud.photo:SetHidden(true)
        hud.photoFrame:SetHidden(true)
        hud.photoPlaceholder:SetText(NQOL.L("features.collections_housing.no_portrait_is_available_for_this_house_e55108c"))
        hud.photoPlaceholder:SetHidden(false)
    end

    hud.houseName:SetText(record.name)
    hud.status:SetText(record.isAcquired and NQOL.L("common.acquired") or NQOL.L("common.not_acquired"))
    SetColor(hud.status, record.isAcquired and COLORS.complete or COLORS.missing)
    hud.meta:SetText(record.metaText)
    hud.details:SetText(record.detailText)
end

local function GetBindingIcon(actionName, fallback)
    if ZO_Keybindings_GetHighestPriorityBindingStringFromAction and KEYBIND_TEXT_OPTIONS_FULL_NAME and KEYBIND_TEXTURE_OPTIONS_EMBED_MARKUP then
        return ZO_Keybindings_GetHighestPriorityBindingStringFromAction(actionName, KEYBIND_TEXT_OPTIONS_FULL_NAME, KEYBIND_TEXTURE_OPTIONS_EMBED_MARKUP, true, false, 100) or fallback
    end
    return fallback
end

local function GetHouseActionLabel(record)
    if not record then return "" end
    local stringId = record.isAcquired and SI_HOUSING_BOOK_ACTION_TRAVEL_TO_HOUSE or SI_HOUSING_BOOK_ACTION_PREVIEW_HOUSE
    if GetString and stringId then return GetString(stringId) end
    return record and record.isAcquired and NQOL.L("features.collections_housing.travel_to_house") or NQOL.L("features.collections_housing.preview_house")
end

local function GetInputHint()
    local record = GetSelectedRecord()
    local stateIndex = not record and 1 or (record.isAcquired and 2 or 3)
    local cachedHint = inputHintCache[filterIndex][stateIndex]
    if cachedHint then return cachedHint end

    local stickIcon = NQOL.L("common.right_stick")
    if GetGamepadRightStickScrollIcon and zo_iconFormat then
        stickIcon = zo_iconFormat(GetGamepadRightStickScrollIcon(), 30, 30)
    end
    local travelHint = ""
    if record then
        travelHint = NQOL.L("collections.action_hint", GetBindingIcon("UI_SHORTCUT_PRIMARY", "X"), record.isAcquired and NQOL.L("common.travel") or NQOL.L("common.preview"))
    end
    cachedHint = NQOL.L(
        "features.collections_housing.input_hint",
        travelHint,
        stickIcon,
        GetBindingIcon("UI_SHORTCUT_LEFT_SHOULDER", "L1"),
        GetBindingIcon("UI_SHORTCUT_RIGHT_SHOULDER", "R1"),
        GetBindingIcon("UI_SHORTCUT_LEFT_STICK", "L3"),
        GetBindingIcon("UI_SHORTCUT_RIGHT_STICK", "R3"),
        FILTERS[filterIndex].label
    )
    inputHintCache[filterIndex][stateIndex] = cachedHint
    return cachedHint
end

local function RenderHud()
    if not EnsureHud() then return end
    if not dataReady then
        BuildHouseRecords()
        RebuildFilteredRecords(GetSettings().selectedCollectibleId)
    end
    local layout = GetLayout()
    LayoutHud(layout)
    ApplyPosition(layout)
    local acquiredCount = 0
    for _, record in ipairs(houseRecords) do
        if record.isAcquired then acquiredCount = acquiredCount + 1 end
    end
    hud.title:SetText(searchText ~= "" and NQOL.L("collections.title_search", NQOL.L("collections.housing.title"), searchText) or NQOL.L("collections.housing.title"))
    hud.summary:SetText(NQOL.L("collections.summary", acquiredCount, #houseRecords, #filteredRecords))
    hud.leftHeader:SetText(NQOL.Util.Upper(FILTERS[filterIndex].label))
    hud.rightHeader:SetText(NQOL.L("features.collections_housing.house_details_4916b1b"))
    hud.hint:SetText(GetInputHint())
    RenderHouseList(layout)
    RenderHouseDetails(GetSelectedRecord())
    hud.control:SetHidden(false)
    RefreshInputActivation()
    RefreshHudKeybinds()
end

local function RenderSelection()
    if not hud or not hud.layout then
        RenderHud()
        return
    end
    RenderHouseListSelection(hud.layout)
    RenderHouseDetails(GetSelectedRecord())
    hud.hint:SetText(GetInputHint())
    RefreshHudKeybinds()
end

local function HideHud()
    if not hud then return end
    ReleasePhotoTexture()
    hud.control:SetHidden(true)
    hud.inputDirection = 0
    hud.nextInputAt = 0
    if DIRECTIONAL_INPUT and DIRECTIONAL_INPUT.IsListening and DIRECTIONAL_INPUT:IsListening(hud) then
        DIRECTIONAL_INPUT:Deactivate(hud)
    end
    RefreshHudKeybinds()
end

ApplyPosition = function(layout)
    if not hud or not hud.control then return end
    layout = layout or GetLayout()
    local settings = GetSettings()
    local maxX = math.max(layout.screenWidth - (layout.width * layout.scale), 0)
    local maxY = math.max(layout.screenHeight - (layout.height * layout.scale), 0)
    hud.control:ClearAnchors()
    hud.control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, maxX * (settings.horizontalPosition / 100), maxY * (settings.verticalPosition / 100))
end

RefreshInputActivation = function()
    if not hud or not DIRECTIONAL_INPUT then return end
    local listening = DIRECTIONAL_INPUT.IsListening and DIRECTIONAL_INPUT:IsListening(hud)
    local shouldListen = not hud.control:IsHidden() and not searchDialogOpen and #filteredRecords > 1
    if shouldListen and not listening then
        DIRECTIONAL_INPUT:Activate(hud, hud.control)
    elseif not shouldListen and listening then
        DIRECTIONAL_INPUT:Deactivate(hud)
    end
end

local function PlayNavigationSound(delta)
    if not PlaySound or not SOUNDS then return end
    local sound = delta > 0 and SOUNDS.GAMEPAD_MENU_DOWN or SOUNDS.GAMEPAD_MENU_UP
    if sound then PlaySound(sound) end
end

local function MoveSelection(delta)
    if #filteredRecords == 0 then return end
    local nextIndex = Clamp(selectedIndex + (delta > 0 and 1 or -1), 1, #filteredRecords)
    if nextIndex == selectedIndex then return end
    selectedIndex = nextIndex
    GetSettings().selectedCollectibleId = filteredRecords[selectedIndex].collectibleId
    RenderSelection()
    PlayNavigationSound(delta)
end

local function JumpCategory(delta)
    local record = GetSelectedRecord()
    if not record or #categoryGroups < 2 then return end
    local currentGroup = record.groupIndex or 1
    local nextGroup = Clamp(currentGroup + delta, 1, #categoryGroups)
    if nextGroup == currentGroup then return end
    selectedIndex = categoryGroups[nextGroup].startIndex
    visibleFirstIndex = categoryGroups[nextGroup].entryIndex
    GetSettings().selectedCollectibleId = filteredRecords[selectedIndex].collectibleId
    RenderSelection()
    PlayNavigationSound(delta)
end

local function CycleFilter()
    local selectedRecord = GetSelectedRecord()
    local preferredId = selectedRecord and selectedRecord.collectibleId or GetSettings().selectedCollectibleId
    filterIndex = (filterIndex % #FILTERS) + 1
    RebuildFilteredRecords(preferredId)
    RenderHud()
    PlayNavigationSound(1)
end

local function TrimSearchText(value)
    local text = tostring(value or "")
    if zo_strtrim then return zo_strtrim(text) end
    return string.match(text, "^%s*(.-)%s*$") or ""
end

local function ApplySearch(value)
    local selectedRecord = GetSelectedRecord()
    local preferredId = selectedRecord and selectedRecord.collectibleId or GetSettings().selectedCollectibleId
    searchText = TrimSearchText(value)
    searchNeedle = NQOL.Util.Lower(searchText)
    RebuildFilteredRecords(preferredId)
    Refresh()
end

local function ReleaseSearchDialog()
    if ZO_Dialogs_ReleaseDialogOnButtonPress then
        ZO_Dialogs_ReleaseDialogOnButtonPress(C.SEARCH_DIALOG_NAME)
    elseif ZO_Dialogs_ReleaseDialog then
        ZO_Dialogs_ReleaseDialog(C.SEARCH_DIALOG_NAME)
    end
end

local function SetupSearchAction(control, data, selected, reselectingDuringRebuild, enabled, active)
    if ZO_SharedGamepadEntry_OnSetup then
        ZO_SharedGamepadEntry_OnSetup(control, data, selected, reselectingDuringRebuild, enabled, active)
    end
end

local function RegisterSearchDialog()
    if searchDialogRegistered or not ZO_Dialogs_RegisterCustomDialog or not GAMEPAD_DIALOGS then return end
    searchDialogRegistered = true
    ZO_Dialogs_RegisterCustomDialog(C.SEARCH_DIALOG_NAME, {
        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
        },
        title = {
            text = function() return NQOL.L("collections.search_title", NQOL.L("collections.housing.title")) end,
        },
        setup = function(dialog)
            dialog.data = dialog.data or {}
            dialog.info.parametricList = {
                {
                    template = "ZO_Gamepad_GenericDialog_Parametric_TextFieldItem",
                    templateData = {
                        nameField = true,
                        textChangedCallback = function(editBox)
                            dialog.data.searchText = editBox:GetText()
                        end,
                        setup = function(control, data, selected)
                            if control.highlight then control.highlight:SetHidden(not selected) end
                            local editBox = control.editBoxControl
                            editBox.textChangedCallback = data.textChangedCallback
                            if editBox.SetMaxInputChars then editBox:SetMaxInputChars(50) end
                            if editBox.SetDefaultText then editBox:SetDefaultText(NQOL.L("collections.search_name_placeholder", NQOL.Util.Lower(NQOL.L("collections.housing.title")))) end
                            editBox:SetText(dialog.data.searchText or "")
                            data.control = control
                        end,
                        callback = function(dialogRef)
                            local targetData = dialogRef.entryList:GetTargetData()
                            local editBox = targetData and targetData.control and targetData.control.editBoxControl
                            if editBox and editBox.TakeFocus then editBox:TakeFocus() end
                        end,
                        narrationText = ZO_GetDefaultParametricListEditBoxNarrationText,
                    },
                },
                {
                    template = "ZO_GamepadTextFieldSubmitItem",
                    templateData = {
                        text = NQOL.L("features.collections_housing.apply_search_96b8b79"),
                        setup = SetupSearchAction,
                        callback = function(dialogRef)
                            ApplySearch(dialogRef.data and dialogRef.data.searchText or "")
                            ReleaseSearchDialog()
                        end,
                    },
                },
                {
                    template = "ZO_GamepadTextFieldSubmitItem",
                    templateData = {
                        text = NQOL.L("features.collections_housing.clear_search_87e328d"),
                        setup = SetupSearchAction,
                        callback = function()
                            ApplySearch("")
                            ReleaseSearchDialog()
                        end,
                    },
                },
            }
            dialog:setupFunc()
        end,
        blockDialogReleaseOnPress = true,
        finishedCallback = function()
            searchDialogOpen = false
            RefreshInputActivation()
            RefreshHudKeybinds()
        end,
        buttons = {
            {
                keybind = "DIALOG_PRIMARY",
                text = SI_GAMEPAD_SELECT_OPTION,
                callback = function(dialog)
                    local targetData = dialog.entryList:GetTargetData()
                    if targetData and targetData.callback then targetData.callback(dialog) end
                end,
            },
            {
                keybind = "DIALOG_NEGATIVE",
                text = SI_DIALOG_CANCEL,
                callback = ReleaseSearchDialog,
            },
        },
    })
end

local function OpenSearchDialog()
    if not ZO_Dialogs_ShowGamepadDialog then return end
    RegisterSearchDialog()
    if not searchDialogRegistered then return end
    searchDialogOpen = true
    RefreshInputActivation()
    RefreshHudKeybinds()
    ZO_Dialogs_ShowGamepadDialog(C.SEARCH_DIALOG_NAME, { searchText = searchText })
end

local function CanVisitSelectedHouse()
    local record = GetSelectedRecord()
    if not record then return false end
    if CanJumpToHouseFromCurrentLocation and not CanJumpToHouseFromCurrentLocation() then
        local stringId = record.isAcquired and SI_COLLECTIONS_CANNOT_JUMP_TO_HOUSE_FROM_LOCATION or SI_COLLECTIONS_CANNOT_PREVIEW_HOUSE_FROM_LOCATION
        local reason = GetString and stringId and GetString(stringId) or (record.isAcquired and NQOL.L("features.collections_housing.cannot_travel_here") or NQOL.L("features.collections_housing.cannot_preview_here"))
        return false, reason
    end
    return true
end

local function VisitSelectedHouse()
    if not CanVisitSelectedHouse() then return end
    local record = GetSelectedRecord()
    if record.isAcquired then
        local collectibleData = ZO_COLLECTIBLE_DATA_MANAGER and ZO_COLLECTIBLE_DATA_MANAGER.GetCollectibleDataById and ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(record.collectibleId) or nil
        if collectibleData and ZO_Dialogs_ShowGamepadDialog then
            ZO_Dialogs_ShowGamepadDialog("GAMEPAD_TRAVEL_TO_HOUSE_OPTIONS_DIALOG", collectibleData)
            return
        end
    end
    if RequestJumpToHouse then
        RequestJumpToHouse(record.houseId)
        if SCENE_MANAGER and SCENE_MANAGER.ShowBaseScene then SCENE_MANAGER:ShowBaseScene() end
    end
end

hudKeybindGroup = {
    {
        name = function()
            return GetHouseActionLabel(GetSelectedRecord())
        end,
        keybind = "UI_SHORTCUT_PRIMARY",
        callback = VisitSelectedHouse,
        visible = function()
            return GetSelectedRecord() ~= nil
        end,
        enabled = CanVisitSelectedHouse,
        sound = SOUNDS and SOUNDS.DEFAULT_CLICK,
    },
    {
        keybind = "UI_SHORTCUT_LEFT_SHOULDER",
        ethereal = true,
        callback = function() JumpCategory(-1) end,
    },
    {
        keybind = "UI_SHORTCUT_RIGHT_SHOULDER",
        ethereal = true,
        callback = function() JumpCategory(1) end,
    },
    {
        keybind = "UI_SHORTCUT_RIGHT_STICK",
        ethereal = true,
        callback = CycleFilter,
    },
    {
        name = function() return NQOL.L("common.search") end,
        keybind = "UI_SHORTCUT_LEFT_STICK",
        ethereal = true,
        callback = OpenSearchDialog,
    },
}

RefreshHudKeybinds = function()
    if not KEYBIND_STRIP then return end
    local shouldBeActive = hud and hud.control and not hud.control:IsHidden() and not searchDialogOpen
    local record = GetSelectedRecord()
    local currentState = not record and 0 or (record.isAcquired and 2 or 1)
    if shouldBeActive and not hudKeybindsActive then
        KEYBIND_STRIP:AddKeybindButtonGroup(hudKeybindGroup)
        hudKeybindsActive = true
        hudKeybindState = currentState
    elseif shouldBeActive and hudKeybindsActive and hudKeybindState ~= currentState and KEYBIND_STRIP.UpdateKeybindButtonGroup then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(hudKeybindGroup)
        hudKeybindState = currentState
    elseif not shouldBeActive and hudKeybindsActive then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(hudKeybindGroup)
        hudKeybindsActive = false
        hudKeybindState = nil
    end
end

function CollectionsHousing.UpdateDirectionalInput()
    if not hud or hud.control:IsHidden() or searchDialogOpen or not DIRECTIONAL_INPUT or not ZO_DI_RIGHT_STICK then return end
    local stickY = DIRECTIONAL_INPUT:GetY(ZO_DI_RIGHT_STICK) or 0
    if math.abs(stickY) <= C.INPUT_DEADZONE then
        hud.inputDirection = 0
        hud.nextInputAt = 0
        return
    end

    local direction = stickY < 0 and 1 or -1
    local now = GetFrameTimeMilliseconds and GetFrameTimeMilliseconds() or 0
    if direction ~= hud.inputDirection then
        hud.inputDirection = direction
        hud.nextInputAt = now + C.INPUT_INITIAL_DELAY_MS
        MoveSelection(direction)
    elseif now >= (hud.nextInputAt or 0) then
        hud.nextInputAt = now + C.INPUT_REPEAT_DELAY_MS
        MoveSelection(direction)
    end
    if DIRECTIONAL_INPUT.Consume then DIRECTIONAL_INPUT:Consume(ZO_DI_RIGHT_STICK) end
end

Refresh = function()
    if not settingsPanelVisible then
        HideHud()
        return
    end
    RenderHud()
end

local function RefreshHousingData()
    if not settingsPanelVisible then return end
    local selectedRecord = GetSelectedRecord()
    local preferredId = selectedRecord and selectedRecord.collectibleId or GetSettings().selectedCollectibleId
    BuildHouseRecords()
    RebuildFilteredRecords(preferredId)
    Refresh()
end

local function ClearHousingData()
    dataReady = false
    ClearTable(houseRecords)
    ClearTable(filteredRecords)
    ClearTable(listEntries)
    ClearTable(recordEntryIndices)
    ClearTable(categoryGroups)
    ClearTable(categoryGroupPool)
    ClearTable(detailLineBuffer)
    ClearTable(detailRecordBuffer)
    selectedIndex = 1
    visibleFirstIndex = 1
    if hud then
        hud.selectedListRow = nil
        for _, row in ipairs(hud.listRows or {}) do
            row.entry = nil
        end
    end
end

function CollectionsHousing.InitializeSavedVariables()
    savedVariables = NQOL.Settings.NewAccountWide(defaults)
    GetSettings()
end

function CollectionsHousing.Initialize()
    if initialized then return end
    initialized = true
end

function CollectionsHousing.SetSettingsPanelVisible(value)
    local showing = value == true
    if showing == settingsPanelVisible then return end
    settingsPanelVisible = showing
    if showing then
        RefreshHousingData()
        return
    end
    if searchDialogOpen then ReleaseSearchDialog() end
    HideHud()
    ClearHousingData()
end

function CollectionsHousing.GetHorizontalPosition() return GetSettings().horizontalPosition end
function CollectionsHousing.SetHorizontalPosition(value) GetSettings().horizontalPosition = Clamp(value, 0, 100); ApplyPosition() end
function CollectionsHousing.GetVerticalPosition() return GetSettings().verticalPosition end
function CollectionsHousing.SetVerticalPosition(value) GetSettings().verticalPosition = Clamp(value, 0, 100); ApplyPosition() end
function CollectionsHousing.GetFontChoices() return NQOL.Util.GetFontChoices() end
function CollectionsHousing.GetFontChoiceNames() return NQOL.Util.GetFontChoiceNames() end
function CollectionsHousing.GetFont() return GetSettings().font end
function CollectionsHousing.SetFont(value) if not NQOL.Util.IsFontChoice(value) then value = NQOL.Util.GetDefaultFont() end; GetSettings().font = value; fontStringCache = {}; ApplyFonts(); Refresh() end
function CollectionsHousing.GetScale() return GetSettings().scale end
function CollectionsHousing.SetScale(value) GetSettings().scale = Clamp(Round(value), C.SCALE_MIN, C.SCALE_MAX); Refresh() end
function CollectionsHousing.GetScaleMin() return C.SCALE_MIN end
function CollectionsHousing.GetScaleMax() return C.SCALE_MAX end
function CollectionsHousing.GetBackgroundOpacity() return GetSettings().backgroundOpacity end
function CollectionsHousing.SetBackgroundOpacity(value) GetSettings().backgroundOpacity = Clamp(Round(value), C.BACKGROUND_OPACITY_MIN, C.BACKGROUND_OPACITY_MAX); ApplyBackground() end
function CollectionsHousing.GetBackgroundOpacityMin() return C.BACKGROUND_OPACITY_MIN end
function CollectionsHousing.GetBackgroundOpacityMax() return C.BACKGROUND_OPACITY_MAX end

function CollectionsHousing.GetHorizontalPositionLabel() return NQOL.L("features.collections_housing.horizontal_position_label") end
function CollectionsHousing.GetHorizontalPositionTooltip() return NQOL.L("features.collections_housing.horizontal_position_tooltip") end
function CollectionsHousing.GetVerticalPositionLabel() return NQOL.L("features.collections_housing.vertical_position_label") end
function CollectionsHousing.GetVerticalPositionTooltip() return NQOL.L("features.collections_housing.vertical_position_tooltip") end
function CollectionsHousing.GetFontLabel() return NQOL.L("features.collections_housing.font_label") end
function CollectionsHousing.GetFontTooltip() return NQOL.L("features.collections_housing.font_tooltip") end
function CollectionsHousing.GetScaleLabel() return NQOL.L("features.collections_housing.scale_label") end
function CollectionsHousing.GetScaleTooltip() return NQOL.L("features.collections_housing.scale_tooltip") end
function CollectionsHousing.GetBackgroundOpacityLabel() return NQOL.L("features.collections_housing.background_opacity_label") end
function CollectionsHousing.GetBackgroundOpacityTooltip() return NQOL.L("features.collections_housing.background_opacity_tooltip") end

NQOL.Features.CollectionsHousing = CollectionsHousing
