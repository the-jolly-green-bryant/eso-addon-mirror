NQOL = NQOL or {}
NQOL.Features = NQOL.Features or {}

local CollectionsCollectibleBrowser = {}

function CollectionsCollectibleBrowser.Create(config)
    local Feature = {}
    local singular = config.singularKey and NQOL.L(config.singularKey) or config.singular
    local plural = config.pluralKey and NQOL.L(config.pluralKey) or config.plural
    local singularLower = NQOL.Util.Lower(singular)
    local pluralLower = NQOL.Util.Lower(plural)
    local singularUpper = NQOL.Util.Upper(singular)
    local pluralUpper = NQOL.Util.Upper(plural)
    local categoryType = config.categoryType
    local useLetterGroups = config.showLetterGroups ~= false and NQOL.Util.UsesCollectionLetterGroups()
    local showActiveStatus = config.showActiveStatus ~= false

    local C = {
        SEARCH_DIALOG_NAME = config.searchDialogName,
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
        PORTRAIT_MAX_SIZE = 112,
        SCROLL_ARROW_GUTTER = 30,
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
        { label = NQOL.L("collections.filter_all", pluralLower) },
        { label = NQOL.L("collections.filter_acquired", pluralLower) },
        { label = NQOL.L("collections.filter_missing", pluralLower) },
    }

    local ALPHABET_GROUPS = {
        { first = "A", last = "D", label = NQOL.L("features.collections_collectible_browser.a_d_cc8033d") },
        { first = "E", last = "H", label = NQOL.L("features.collections_collectible_browser.e_h_26f3d03") },
        { first = "I", last = "L", label = NQOL.L("features.collections_collectible_browser.i_l_00eb52e") },
        { first = "M", last = "P", label = NQOL.L("features.collections_collectible_browser.m_p_94a2986") },
        { first = "Q", last = "T", label = NQOL.L("features.collections_collectible_browser.q_t_bbb7a1f") },
        { first = "U", last = "Z", label = NQOL.L("features.collections_collectible_browser.u_z_d38f1c6") },
    }

    local DEFAULT_FONT_SIZE = 26
    local missingThumbnailText = NQOL.L("collections.missing_thumbnail", singularLower)
    NQOL.Lexicon.RegisterRefreshCallback(function()
        singular = config.singularKey and NQOL.L(config.singularKey) or config.singular
        plural = config.pluralKey and NQOL.L(config.pluralKey) or config.plural
        singularLower = NQOL.Util.Lower(singular)
        pluralLower = NQOL.Util.Lower(plural)
        singularUpper = NQOL.Util.Upper(singular)
        pluralUpper = NQOL.Util.Upper(plural)
        FILTERS[1].label = NQOL.L("collections.filter_all", pluralLower)
        FILTERS[2].label = NQOL.L("collections.filter_acquired", pluralLower)
        FILTERS[3].label = NQOL.L("collections.filter_missing", pluralLower)
        missingThumbnailText = NQOL.L("collections.missing_thumbnail", singularLower)
        if config.dismissLabelKey then config.dismissLabel = NQOL.L(config.dismissLabelKey) end
        if config.useLabelKey then config.useLabel = NQOL.L(config.useLabelKey) end
    end)
    local defaults = {
        collections = {
            [config.settingsKey] = {
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
    local collectibleRecords = {}
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
    local visibleTagBuffer = {}
    local inputHintCache = { {}, {}, {} }
    local BuildCollectibleDetailText
    local hudKeybindGroup
    local hudKeybindsActive = false
    local hudKeybindState
    local Refresh
    local RefreshCollectiblesData
    local ApplyPosition
    local RefreshInputActivation
    local RefreshHudKeybinds

    local Clamp = NQOL.Util.Clamp
    local Round = NQOL.Util.Round

    local function ClearTable(values)
        for key in pairs(values) do
            values[key] = nil
        end
    end

    local function GetSettings()
        local collections = NQOL.Settings.GetSection(savedVariables, defaults, "collections")
        if type(collections[config.settingsKey]) ~= "table" then
            collections[config.settingsKey] = {}
        end

        local settings = collections[config.settingsKey]
        for key, value in pairs(defaults.collections[config.settingsKey]) do
            if settings[key] == nil then
                settings[key] = value
            end
        end

        settings.horizontalPosition = Clamp(tonumber(settings.horizontalPosition) or defaults.collections[config.settingsKey].horizontalPosition, 0, 100)
        settings.verticalPosition = Clamp(tonumber(settings.verticalPosition) or defaults.collections[config.settingsKey].verticalPosition, 0, 100)
        settings.scale = Clamp(Round(tonumber(settings.scale) or defaults.collections[config.settingsKey].scale), C.SCALE_MIN, C.SCALE_MAX)
        settings.backgroundOpacity = Clamp(Round(tonumber(settings.backgroundOpacity) or defaults.collections[config.settingsKey].backgroundOpacity), C.BACKGROUND_OPACITY_MIN, C.BACKGROUND_OPACITY_MAX)
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
        return tostring(name or NQOL.L("collections.unknown", singularLower))
    end

    local function BooleanText(value)
        return value and NQOL.L("common.yes") or NQOL.L("common.no")
    end

    local function GetAlphabetGroup(name)
        return NQOL.Util.GetCollectionLetterGroup(name)
    end

    local function IsBrowsableCollectible(collectibleData)
        if not collectibleData or not collectibleData.GetCategoryType then return false end
        if collectibleData:GetCategoryType() ~= categoryType then return false end
        if GetCollectibleHideMode and collectibleData.GetId and COLLECTIBLE_HIDE_MODE_ALWAYS then
            return GetCollectibleHideMode(collectibleData:GetId()) ~= COLLECTIBLE_HIDE_MODE_ALWAYS
        end
        return true
    end

    local function GetVisibleTags(collectibleId)
        if not GetNumCollectibleTags or not GetCollectibleTagInfo then return "" end
        local tags = visibleTagBuffer
        ClearTable(tags)
        for tagIndex = 1, GetNumCollectibleTags(collectibleId) do
            local description, _, hideInUi = GetCollectibleTagInfo(collectibleId, tagIndex)
            if not hideInUi and description and description ~= "" then
                tags[#tags + 1] = description
            end
        end
        local text = table.concat(tags, ", ")
        ClearTable(tags)
        return text
    end

    local function GetBlockReasonText(collectibleId)
        if not GetCollectibleBlockReason then return "" end
        local reason = GetCollectibleBlockReason(collectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
        if not reason or reason == COLLECTIBLE_USAGE_BLOCK_REASON_NOT_BLOCKED then return "" end
        if GetString then
            return GetString("SI_COLLECTIBLEUSAGEBLOCKREASON", reason) or ""
        end
        return tostring(reason)
    end

    local function GetCollectiblePortrait(collectibleData, collectibleId)
        local portraitPath = collectibleData and collectibleData.GetIcon and collectibleData:GetIcon() or ""
        if portraitPath == "" and GetCollectibleIcon then portraitPath = GetCollectibleIcon(collectibleId) or "" end
        local textureRight = 1
        if portraitPath == "" then
            portraitPath = collectibleData and collectibleData.GetGamepadBackgroundImage and collectibleData:GetGamepadBackgroundImage() or ""
            if portraitPath ~= "" then textureRight = Clamp(tonumber(ZO_GAMEPAD_COLLECTIONS_PANEL_TEXTURE_COORD_RIGHT) or 1, 0.1, 1) end
        end
        return portraitPath, textureRight
    end

    local function GetPortrait(record)
        return record and record.portraitPath or "", record and record.portraitTextureRight or 1
    end

    local function CompareCollectibles(left, right)
        if useLetterGroups and left.groupKey ~= right.groupKey then return left.groupKey < right.groupKey end
        local leftName = NQOL.Util.Lower(left.name)
        local rightName = NQOL.Util.Lower(right.name)
        if leftName ~= rightName then return leftName < rightName end
        return left.collectibleId < right.collectibleId
    end

    local function BuildCollectibleRecords()
        ClearTable(collectibleRecords)
        dataReady = false

        if not ZO_COLLECTIBLE_DATA_MANAGER or not categoryType then
            return
        end

        local collectibles = ZO_COLLECTIBLE_DATA_MANAGER:GetAllCollectibleDataObjects(nil, { IsBrowsableCollectible })
        for _, collectibleData in ipairs(collectibles or {}) do
            local collectibleId = collectibleData:GetId()
            local isAcquired = collectibleData:IsUnlocked()
            local categoryName = collectibleData.GetCategoryFormattedName and collectibleData:GetCategoryFormattedName() or plural
            local name = FormatName(collectibleData:GetName())
            local groupKey, groupName = GetAlphabetGroup(name)
            local isSelected = config.supportsActive ~= false and collectibleData:IsActive(GAMEPLAY_ACTOR_CATEGORY_PLAYER) or false
            local isSuppressed = isSelected and collectibleData.ShouldSuppressActiveState and collectibleData:ShouldSuppressActiveState(GAMEPLAY_ACTOR_CATEGORY_PLAYER) or false
            local isActive = isSelected and not isSuppressed
            local isUsable = collectibleData.IsUsable and collectibleData:IsUsable(GAMEPLAY_ACTOR_CATEGORY_PLAYER) or false
            local portraitPath, portraitTextureRight = GetCollectiblePortrait(collectibleData, collectibleId)
            local interactionStringId = collectibleData.GetPrimaryInteractionStringId and collectibleData:GetPrimaryInteractionStringId(GAMEPLAY_ACTOR_CATEGORY_PLAYER) or nil
            local record = {
                collectibleId = collectibleId,
                categoryName = categoryName ~= "" and categoryName or plural,
                groupKey = groupKey,
                groupName = groupName,
                name = name,
                nickname = config.showNickname and isAcquired and collectibleData.GetNickname and collectibleData:GetNickname() or "",
                description = collectibleData:GetDescription() or "",
                hint = not isAcquired and collectibleData:GetHint() or "",
                tags = GetVisibleTags(collectibleId),
                blockReason = GetBlockReasonText(collectibleId),
                isAcquired = isAcquired,
                isActive = isActive,
                isSuppressed = isSuppressed,
                isNew = collectibleData.IsNew and collectibleData:IsNew() or false,
                isPurchasable = collectibleData.IsPurchasable and collectibleData:IsPurchasable() or false,
                isUsable = isUsable,
                isBlocked = collectibleData.IsBlocked and collectibleData:IsBlocked(GAMEPLAY_ACTOR_CATEGORY_PLAYER) or false,
                isValidForPlayer = not collectibleData.IsValidForPlayer or collectibleData:IsValidForPlayer(),
                questState = config.showQuestState and collectibleData.GetCollectibleAssociatedQuestState and collectibleData:GetCollectibleAssociatedQuestState() or nil,
                questName = config.showQuestState and collectibleData.GetQuestName and collectibleData:GetQuestName() or "",
                portraitPath = portraitPath,
                portraitTextureRight = portraitTextureRight,
                interactionStringId = interactionStringId,
            }
            record.displayName = record.nickname ~= "" and string.format("%s (%s)", record.name, record.nickname) or record.name
            record.hasAction = (record.isAcquired or config.allowUnacquiredUse) and isUsable and interactionStringId ~= nil or false
            record.actionLabel = interactionStringId and GetString and GetString(interactionStringId) or (record.isActive and (config.dismissLabel or NQOL.L("common.dismiss")) or (config.useLabel or NQOL.L("common.use")))
            record.detailText = BuildCollectibleDetailText(record)
            local searchableText = table.concat({ record.name, record.nickname, record.categoryName, record.tags }, " ")
            record.searchText = NQOL.Util.Lower(searchableText)
            record.nickname = nil
            record.description = nil
            record.hint = nil
            record.tags = nil
            record.isNew = nil
            record.isPurchasable = nil
            record.isValidForPlayer = nil
            record.questState = nil
            record.questName = nil
            collectibleRecords[#collectibleRecords + 1] = record
        end

        table.sort(collectibleRecords, CompareCollectibles)
        dataReady = true
    end

    local function MatchesFilter(record)
        if filterIndex == 2 and not record.isAcquired then return false end
        if filterIndex == 3 and record.isAcquired then return false end
        if searchNeedle ~= "" then
            if not string.find(record.searchText, searchNeedle, 1, true) then return false end
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

        local previousGroupKey
        for _, record in ipairs(collectibleRecords) do
            if MatchesFilter(record) then
                if useLetterGroups and record.groupKey ~= previousGroupKey then
                    local groupIndex = #categoryGroups + 1
                    local group = categoryGroupPool[groupIndex]
                    if not group then
                        group = {}
                        categoryGroupPool[groupIndex] = group
                    end
                    group.groupKey = record.groupKey
                    group.label = record.groupName
                    group.startIndex = #filteredRecords + 1
                    categoryGroups[groupIndex] = group
                    listEntries[#listEntries + 1] = { isHeader = true, label = record.groupName }
                    group.entryIndex = #listEntries
                    previousGroupKey = record.groupKey
                end
                filteredRecords[#filteredRecords + 1] = record
                record.groupIndex = useLetterGroups and #categoryGroups or nil
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
        local detailWidth = math.floor(rightWidth * 0.70)
        local portraitWidth = rightWidth - detailWidth - C.PANE_GAP
        local viewportHeight = contentHeight - C.PANE_HEADER_HEIGHT
        local listViewportHeight = math.max(viewportHeight - C.SCROLL_ARROW_GUTTER, 1)
        local rowHeight = Clamp(math.floor(listViewportHeight / 11) - C.ROW_GAP, 38, 54)
        local visibleRows = math.max(math.floor((listViewportHeight + C.ROW_GAP) / (rowHeight + C.ROW_GAP)), 1)
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
            listViewportHeight = listViewportHeight,
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
        hud.control = WINDOW_MANAGER:CreateTopLevelWindow(config.controlName)
        hud.control:SetHidden(true)
        MoveAbove(hud.control, C.DRAW_LEVEL)
        hud.UpdateDirectionalInput = function()
            Feature.UpdateDirectionalInput()
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
        if hud.photo.SetAlpha then hud.photo:SetAlpha(1) end
        if hud.photo.SetColor then hud.photo:SetColor(1, 1, 1, 1) end
        if hud.photo.SetDesaturation then hud.photo:SetDesaturation(0) end
        MoveAbove(hud.photo, C.DRAW_LEVEL + 4)
        hud.photoPlaceholder = CreateLabel(hud.rightViewport, -2, COLORS.textMuted, TEXT_ALIGN_CENTER)
        hud.photoPlaceholder:SetText(missingThumbnailText)
        NQOL.Util.ConfigureContentTexture(hud.photo, hud.photoPlaceholder, hud.photoFrame)
        hud.collectibleName = CreateLabel(hud.rightViewport, 2, COLORS.text)
        hud.collectibleName:SetVerticalAlignment(TEXT_ALIGN_TOP)
        hud.status = CreateLabel(hud.control, -3, COLORS.complete, TEXT_ALIGN_RIGHT)
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
        hud.collectibleName:SetFont(GetFont(2))
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

        hud.photoPlaceholder:ClearAnchors()
        hud.photoPlaceholder:SetDimensions(math.max(layout.portraitWidth - 12, 1), 80)
        hud.photoPlaceholder:SetAnchor(CENTER, hud.rightViewport, TOPLEFT, layout.detailWidth + C.PANE_GAP + math.floor(layout.portraitWidth / 2), layout.portraitTop + math.floor(math.min(layout.portraitHeight, C.PORTRAIT_MAX_SIZE) / 2))

        hud.collectibleName:ClearAnchors()
        hud.collectibleName:SetDimensions(layout.detailWidth, 58)
        hud.collectibleName:SetAnchor(TOPLEFT, hud.rightViewport, TOPLEFT, 0, 0)
        hud.status:ClearAnchors()
        hud.status:SetDimensions(layout.portraitWidth, 38)
        hud.status:SetAnchor(RIGHT, hud.rightHeader, RIGHT, 0, 0)
        hud.meta:ClearAnchors()
        hud.meta:SetDimensions(layout.detailWidth, 40)
        hud.meta:SetAnchor(TOPLEFT, hud.collectibleName, BOTTOMLEFT, 0, 0)
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

    local function RenderCollectibleList(layout)
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
                    row.header:SetText(NQOL.Util.Upper(entry.label or pluralUpper))
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
                    row.status:SetText(showActiveStatus and entry.isActive and NQOL.L("common.active") or showActiveStatus and entry.isSuppressed and NQOL.L("common.selected") or entry.isAcquired and NQOL.L("common.acquired") or NQOL.L("common.missing"))
                    SetColor(row.status, entry.isAcquired and COLORS.complete or COLORS.missing)
                end
            end
        end
        hud.upArrow:SetHidden(visibleFirstIndex <= 1)
        hud.downArrow:SetHidden(visibleFirstIndex + layout.visibleRows - 1 >= #listEntries)
        hud.empty:SetHidden(#filteredRecords > 0)
        if #filteredRecords == 0 then
            if searchText ~= "" then
                hud.empty:SetText(NQOL.L("collections.no_search_results", pluralLower, searchText))
            else
                hud.empty:SetText(NQOL.L("collections.no_filter_results", pluralLower))
            end
        end
    end

    local function RenderCollectibleListSelection(layout)
        if KeepSelectionVisible(layout) then
            RenderCollectibleList(layout)
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
        if hud.selectedListRow and hud.selectedListRow ~= selectedRow then SetListRowSelected(hud.selectedListRow, false) end
        if selectedRow and hud.selectedListRow ~= selectedRow then SetListRowSelected(selectedRow, true) end
        hud.selectedListRow = selectedRow
    end

    local function AddDetailLine(lines, label, value)
        if value and value ~= "" then
            lines[#lines + 1] = string.format("|c72BEEB%s:|r %s", label, tostring(value))
        end
    end

    BuildCollectibleDetailText = function(record)
        local lines = detailLineBuffer
        ClearTable(lines)
        if record.isNew then AddDetailLine(lines, NQOL.L("collections.detail.new"), NQOL.L("common.yes")) end
        if config.showQuestState and record.questState ~= nil and (not COLLECTIBLE_ASSOCIATED_QUEST_STATE_NO_QUEST or record.questState ~= COLLECTIBLE_ASSOCIATED_QUEST_STATE_NO_QUEST) then
            local questStatus = NQOL.L("common.available")
            if COLLECTIBLE_ASSOCIATED_QUEST_STATE_ACCEPTED and record.questState == COLLECTIBLE_ASSOCIATED_QUEST_STATE_ACCEPTED then
                questStatus = NQOL.L("common.in_progress")
            elseif COLLECTIBLE_ASSOCIATED_QUEST_STATE_COMPLETED and record.questState == COLLECTIBLE_ASSOCIATED_QUEST_STATE_COMPLETED then
                questStatus = NQOL.L("common.completed")
            end
            local questText = record.questName ~= "" and string.format("%s (%s)", record.questName, questStatus) or questStatus
            AddDetailLine(lines, NQOL.L("collections.detail.introduction_quest"), questText)
        end
        if config.appendDetailLines then config.appendDetailLines(record, lines, AddDetailLine) end
        if not record.isAcquired then AddDetailLine(lines, NQOL.L("collections.detail.directly_purchasable"), BooleanText(record.isPurchasable)) end
        if not record.isValidForPlayer then AddDetailLine(lines, NQOL.L("collections.detail.available_to_character"), NQOL.L("common.no")) end
        if record.blockReason ~= "" then AddDetailLine(lines, NQOL.L("collections.detail.use_restriction"), record.blockReason) end
        if record.tags ~= "" then AddDetailLine(lines, NQOL.L("collections.detail.tags"), record.tags) end
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
        local maxWidth = math.max(math.min(layout.portraitWidth - 8, C.PORTRAIT_MAX_SIZE), 1)
        local maxHeight = math.max(math.min(layout.portraitHeight - 8, C.PORTRAIT_MAX_SIZE), 1)
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
        local centerY = layout.portraitTop + math.floor(height / 2)

        hud.photoFrame:ClearAnchors()
        hud.photoFrame:SetDimensions(width + 4, height + 4)
        hud.photoFrame:SetAnchor(CENTER, hud.rightViewport, TOPLEFT, centerX, centerY)
        hud.status:ClearAnchors()
        hud.status:SetDimensions(width + 4, C.PANE_HEADER_HEIGHT)
        hud.status:SetAnchor(RIGHT, hud.rightHeader, LEFT, centerX + math.floor((width + 4) / 2), 0)
        hud.photo:ClearAnchors()
        hud.photo:SetDimensions(width, height)
        hud.photo:SetAnchor(CENTER, hud.photoFrame, CENTER, 0, 0)
    end

    local function ReleasePhotoTexture()
        if not hud or not hud.photo then return end
        NQOL.Util.ReleaseContentTexture(hud.photo)
        hud.currentPhotoPath = nil
    end

    local function RenderCollectibleDetails(record)
        if not record then
            ReleasePhotoTexture()
            hud.photo:SetHidden(true)
            hud.photoFrame:SetHidden(true)
            hud.photoPlaceholder:SetHidden(false)
            hud.collectibleName:SetText(NQOL.L("collections.no_selection", singularLower))
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
                if hud.photo.SetTextureCoords and hud.photoTextureRight ~= textureRight then
                    hud.photo:SetTextureCoords(0, textureRight or 1, 0, 1)
                    hud.photoTextureRight = textureRight
                end
                hud.currentPhotoPath = portraitPath
                NQOL.Util.LoadContentTexture(hud.photo, portraitPath)
            end
        else
            ReleasePhotoTexture()
            hud.photo:SetHidden(true)
            hud.photoFrame:SetHidden(true)
            hud.photoPlaceholder:SetText(missingThumbnailText)
            hud.photoPlaceholder:SetHidden(false)
        end

        hud.collectibleName:SetText(record.displayName)
        local collectibleNameHeight = hud.collectibleName.GetTextHeight and math.ceil(hud.collectibleName:GetTextHeight()) or (DEFAULT_FONT_SIZE + 4)
        hud.collectibleName:SetHeight(Clamp(collectibleNameHeight, 1, 58))
        hud.status:SetText(showActiveStatus and record.isActive and NQOL.L("common.active") or showActiveStatus and record.isSuppressed and NQOL.L("common.selected") or record.isAcquired and NQOL.L("common.acquired") or NQOL.L("common.not_acquired"))
        SetColor(hud.status, record.isAcquired and COLORS.complete or COLORS.missing)
        hud.meta:SetText(record.categoryName)

        hud.details:SetText(record.detailText)
    end

    local function GetBindingIcon(actionName, fallback)
        if ZO_Keybindings_GetHighestPriorityBindingStringFromAction and KEYBIND_TEXT_OPTIONS_FULL_NAME and KEYBIND_TEXTURE_OPTIONS_EMBED_MARKUP then
            return ZO_Keybindings_GetHighestPriorityBindingStringFromAction(actionName, KEYBIND_TEXT_OPTIONS_FULL_NAME, KEYBIND_TEXTURE_OPTIONS_EMBED_MARKUP, true, false, 100) or fallback
        end
        return fallback
    end

    local function GetCollectibleData(record)
        if not record or not ZO_COLLECTIBLE_DATA_MANAGER or not ZO_COLLECTIBLE_DATA_MANAGER.GetCollectibleDataById then return nil end
        return ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(record.collectibleId)
    end

    local function GetInteractionStringId(record)
        return record and record.interactionStringId or nil
    end

    local function HasCollectibleAction(record)
        return record and record.hasAction or false
    end

    local function GetCollectibleActionLabel(record)
        return record and record.actionLabel or ""
    end

    local function GetInputHint()
        local record = GetSelectedRecord()
        local stateIndex = not record and 1 or (record.hasAction and (record.isActive and 4 or 3) or 2)
        local cachedHint = inputHintCache[filterIndex][stateIndex]
        if cachedHint then return cachedHint end

        local stickIcon = NQOL.L("common.right_stick")
        if GetGamepadRightStickScrollIcon and zo_iconFormat then
            stickIcon = zo_iconFormat(GetGamepadRightStickScrollIcon(), 30, 30)
        end
        local activateHint = ""
        if HasCollectibleAction(record) then
            activateHint = NQOL.L("collections.action_hint", GetBindingIcon("UI_SHORTCUT_PRIMARY", "X"), GetCollectibleActionLabel(record))
        end
        if useLetterGroups then
            cachedHint = NQOL.L(
                "collections.input_hint_grouped",
                activateHint,
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
        cachedHint = NQOL.L(
            "collections.input_hint_flat",
            activateHint,
            stickIcon,
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
            BuildCollectibleRecords()
            RebuildFilteredRecords(GetSettings().selectedCollectibleId)
        end
        local layout = GetLayout()
        LayoutHud(layout)
        ApplyPosition(layout)
        local acquiredCount = 0
        for _, record in ipairs(collectibleRecords) do
            if record.isAcquired then acquiredCount = acquiredCount + 1 end
        end
        hud.title:SetText(searchText ~= "" and NQOL.L("collections.title_search", pluralUpper, searchText) or pluralUpper)
        hud.summary:SetText(NQOL.L("collections.summary", acquiredCount, #collectibleRecords, #filteredRecords))
        hud.leftHeader:SetText(NQOL.Util.Upper(FILTERS[filterIndex].label))
        hud.rightHeader:SetText(NQOL.L("collections.details", singularUpper))
        hud.hint:SetText(GetInputHint())
        RenderCollectibleList(layout)
        RenderCollectibleDetails(GetSelectedRecord())
        hud.control:SetHidden(false)
        RefreshInputActivation()
        RefreshHudKeybinds()
    end

    local function RenderSelection()
        if not hud or not hud.layout then
            RenderHud()
            return
        end
        RenderCollectibleListSelection(hud.layout)
        RenderCollectibleDetails(GetSelectedRecord())
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
                text = function() return NQOL.L("collections.search_title", plural) end,
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
                                if editBox.SetDefaultText then editBox:SetDefaultText(NQOL.L("collections.search_name_placeholder", singular)) end
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
                            text = NQOL.L("features.collections_collectible_browser.apply_search_96b8b79"),
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
                            text = NQOL.L("features.collections_collectible_browser.clear_search_87e328d"),
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

    local function CanUseSelectedCollectible()
        local record = GetSelectedRecord()
        if not record then return false end
        if not record.isAcquired and not config.allowUnacquiredUse then return false, NQOL.L("collections.not_acquired", singularLower) end
        if GetInteractionStringId(record) == nil then return false end
        if GetCollectibleCooldownAndDuration and not record.isActive then
            local remainingMs = GetCollectibleCooldownAndDuration(record.collectibleId)
            if (tonumber(remainingMs) or 0) > 0 then
                return false, GetString and SI_COLLECTIONS_COOLDOWN_ERROR and GetString(SI_COLLECTIONS_COOLDOWN_ERROR) or NQOL.L("collections.on_cooldown")
            end
        end
        if record.isBlocked then return false, record.blockReason ~= "" and record.blockReason or NQOL.L("collections.cannot_use_now", singularLower) end
        if not record.isUsable then return false, NQOL.L("collections.cannot_use_now", singularLower) end
        return true
    end

    local function UseSelectedCollectible()
        if not CanUseSelectedCollectible() then return end
        local record = GetSelectedRecord()
        local collectibleData = GetCollectibleData(record)
        if collectibleData and collectibleData.Use then
            collectibleData:Use(GAMEPLAY_ACTOR_CATEGORY_PLAYER)
        elseif UseCollectible then
            UseCollectible(record.collectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
        end
        if zo_callLater then
            zo_callLater(RefreshCollectiblesData, 100)
        else
            RefreshCollectiblesData()
        end
    end

    hudKeybindGroup = {
        {
            name = function()
                return GetCollectibleActionLabel(GetSelectedRecord())
            end,
            keybind = "UI_SHORTCUT_PRIMARY",
            callback = UseSelectedCollectible,
            visible = function()
                return HasCollectibleAction(GetSelectedRecord())
            end,
            enabled = CanUseSelectedCollectible,
            sound = SOUNDS and SOUNDS.DEFAULT_CLICK,
        },
        {
            keybind = "UI_SHORTCUT_LEFT_SHOULDER",
            ethereal = true,
            visible = function() return useLetterGroups end,
            callback = function() JumpCategory(-1) end,
        },
        {
            keybind = "UI_SHORTCUT_RIGHT_SHOULDER",
            ethereal = true,
            visible = function() return useLetterGroups end,
            callback = function() JumpCategory(1) end,
        },
        {
            keybind = "UI_SHORTCUT_RIGHT_STICK",
            ethereal = true,
            callback = CycleFilter,
        },
        {
            name = NQOL.L("common.search"),
            keybind = "UI_SHORTCUT_LEFT_STICK",
            ethereal = true,
            callback = OpenSearchDialog,
        },
    }

    RefreshHudKeybinds = function()
        if not KEYBIND_STRIP then return end
        local shouldBeActive = hud and hud.control and not hud.control:IsHidden() and not searchDialogOpen
        local record = GetSelectedRecord()
        local currentState = record and record.hasAction and record.actionLabel or ""
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

    function Feature.UpdateDirectionalInput()
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

    RefreshCollectiblesData = function()
        if not settingsPanelVisible then return end
        local selectedRecord = GetSelectedRecord()
        local preferredId = selectedRecord and selectedRecord.collectibleId or GetSettings().selectedCollectibleId
        BuildCollectibleRecords()
        RebuildFilteredRecords(preferredId)
        Refresh()
    end

    local function ClearCollectiblesData()
        dataReady = false
        ClearTable(collectibleRecords)
        ClearTable(filteredRecords)
        ClearTable(listEntries)
        ClearTable(recordEntryIndices)
        ClearTable(categoryGroups)
        ClearTable(categoryGroupPool)
        ClearTable(detailLineBuffer)
        ClearTable(visibleTagBuffer)
        selectedIndex = 1
        visibleFirstIndex = 1
        if hud then
            hud.selectedListRow = nil
            for _, row in ipairs(hud.listRows or {}) do
                row.entry = nil
            end
        end
    end

    function Feature.InitializeSavedVariables()
        savedVariables = NQOL.Settings.NewAccountWide(defaults)
        GetSettings()
    end

    function Feature.Initialize()
        if initialized then return end
        initialized = true
    end

    function Feature.SetSettingsPanelVisible(value)
        local showing = value == true
        if showing == settingsPanelVisible then return end
        settingsPanelVisible = showing
        if showing then
            RefreshCollectiblesData()
            return
        end
        if searchDialogOpen then ReleaseSearchDialog() end
        HideHud()
        ClearCollectiblesData()
    end

    function Feature.GetHorizontalPosition() return GetSettings().horizontalPosition end
    function Feature.SetHorizontalPosition(value) GetSettings().horizontalPosition = Clamp(value, 0, 100); ApplyPosition() end
    function Feature.GetVerticalPosition() return GetSettings().verticalPosition end
    function Feature.SetVerticalPosition(value) GetSettings().verticalPosition = Clamp(value, 0, 100); ApplyPosition() end
    function Feature.GetFontChoices() return NQOL.Util.GetFontChoices() end
    function Feature.GetFontChoiceNames() return NQOL.Util.GetFontChoiceNames() end
    function Feature.GetFont() return GetSettings().font end
    function Feature.SetFont(value) if not NQOL.Util.IsFontChoice(value) then value = NQOL.Util.GetDefaultFont() end; GetSettings().font = value; fontStringCache = {}; ApplyFonts(); Refresh() end
    function Feature.GetScale() return GetSettings().scale end
    function Feature.SetScale(value) GetSettings().scale = Clamp(Round(value), C.SCALE_MIN, C.SCALE_MAX); Refresh() end
    function Feature.GetScaleMin() return C.SCALE_MIN end
    function Feature.GetScaleMax() return C.SCALE_MAX end
    function Feature.GetBackgroundOpacity() return GetSettings().backgroundOpacity end
    function Feature.SetBackgroundOpacity(value) GetSettings().backgroundOpacity = Clamp(Round(value), C.BACKGROUND_OPACITY_MIN, C.BACKGROUND_OPACITY_MAX); ApplyBackground() end
    function Feature.GetBackgroundOpacityMin() return C.BACKGROUND_OPACITY_MIN end
    function Feature.GetBackgroundOpacityMax() return C.BACKGROUND_OPACITY_MAX end

    function Feature.GetHorizontalPositionLabel() return NQOL.L("features.collections_collectible_browser.horizontal_position_label") end
    function Feature.GetHorizontalPositionTooltip() return NQOL.L("collections.horizontal_tooltip", plural) end
    function Feature.GetVerticalPositionLabel() return NQOL.L("features.collections_collectible_browser.vertical_position_label") end
    function Feature.GetVerticalPositionTooltip() return NQOL.L("collections.vertical_tooltip", plural) end
    function Feature.GetFontLabel() return NQOL.L("features.collections_collectible_browser.font_label") end
    function Feature.GetFontTooltip() return NQOL.L("collections.font_tooltip", plural) end
    function Feature.GetScaleLabel() return NQOL.L("features.collections_collectible_browser.scale_label") end
    function Feature.GetScaleTooltip() return NQOL.L("collections.scale_tooltip", plural) end
    function Feature.GetBackgroundOpacityLabel() return NQOL.L("features.collections_collectible_browser.background_opacity_label") end
    function Feature.GetBackgroundOpacityTooltip() return NQOL.L("collections.opacity_tooltip", plural) end

    return Feature
end

NQOL.Features.CollectionsCollectibleBrowser = CollectionsCollectibleBrowser
