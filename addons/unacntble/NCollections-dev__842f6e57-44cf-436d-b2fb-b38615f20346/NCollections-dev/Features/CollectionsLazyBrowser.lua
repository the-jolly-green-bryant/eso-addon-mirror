NCollections = NCollections or {}
NCollections.Features = NCollections.Features or {}

local LazyBrowser = {}
local Hud = NCollections.Features.CollectionsHud

function LazyBrowser.Create(config)
    local Feature = {}
    local K = {
        scaleMin = 50, scaleMax = 150, opacityMin = 0, opacityMax = 100,
        margin = 24, padding = 16, header = 66, footer = 44, paneGap = 18,
        minWidth = 900, maxWidth = 1420, minHeight = tonumber(config.minHeight) or 540,
        maxHeight = tonumber(config.maxHeight) or 820, heightRatio = tonumber(config.heightRatio) or 0.80,
        deadzone = 0.34, initialDelay = 330, repeatDelay = 95,
    }
    local singular = config.singularKey and NCollections.L(config.singularKey) or config.singular
    local plural = config.pluralKey and NCollections.L(config.pluralKey) or config.plural
    local singularLower = NCollections.Util.Lower(singular)
    local pluralLower = NCollections.Util.Lower(plural)
    local pluralUpper = NCollections.Util.Upper(plural)
    local categoryTypes = {}
    if config.categoryType then categoryTypes[config.categoryType] = true end
    for _, categoryType in ipairs(config.categoryTypes or {}) do categoryTypes[categoryType] = true end
    local filters = {
        NCollections.L("collections.filter_all", pluralLower),
        NCollections.L("collections.filter_acquired", pluralLower),
        NCollections.L("collections.filter_missing", pluralLower),
    }
    NCollections.Lexicon.RegisterRefreshCallback(function()
        singular = config.singularKey and NCollections.L(config.singularKey) or config.singular
        plural = config.pluralKey and NCollections.L(config.pluralKey) or config.plural
        singularLower = NCollections.Util.Lower(singular)
        pluralLower = NCollections.Util.Lower(plural)
        pluralUpper = NCollections.Util.Upper(plural)
        filters[1] = NCollections.L("collections.filter_all", pluralLower)
        filters[2] = NCollections.L("collections.filter_acquired", pluralLower)
        filters[3] = NCollections.L("collections.filter_missing", pluralLower)
        if config.dismissLabelKey then config.dismissLabel = NCollections.L(config.dismissLabelKey) end
        if config.useLabelKey then config.useLabel = NCollections.L(config.useLabelKey) end
    end)

    local defaults = { collections = { [config.settingsKey] = {
        horizontalPosition = 50, verticalPosition = 50, font = NCollections.Util.GetDefaultFont(),
        scale = 100, backgroundOpacity = 90, selectedCollectibleId = 0,
    } } }
    for key, value in pairs(config.extraDefaults or {}) do defaults.collections[config.settingsKey][key] = value end

    local savedVariables
    local visible = false
    local ready = false
    local hud
    local owner = {}
    local sourceKeys = {}
    local filteredKeys = {}
    local window = {}
    local windowFirst = 0
    local windowLast = -1
    local loadingFirst = 0
    local loadingLast = -1
    local selectedRecord
    local selectedRecordKey
    local loadingSelectedKey
    local selectedIndex = 1
    local visibleFirst = 1
    local filterIndex = 1
    local searchText = ""
    local searchNeedle = ""
    local searchOpen = false
    local searchRegistered = false
    local hudRows = {}
    local inputHints = { {}, {}, {} }
    local detailLines = {}
    local tagBuffer = {}
    local keybindsActive = false
    local keybindState
    local keybindGroup
    local Refresh
    local ClearData
    local taskName = "NCollections_LazyCollection_" .. tostring(config.settingsKey) .. "_" .. tostring(config.searchDialogName or config.pluralKey or "catalog")
    local windowTaskName = taskName .. "_Window"
    local selectedTaskName = taskName .. "_Selected"

    local function GetSettings()
        local collections = NCollections.Settings.GetSection(savedVariables, defaults, "collections")
        local settings = collections[config.settingsKey]
        if type(settings) ~= "table" then settings = {}; collections[config.settingsKey] = settings end
        for key, value in pairs(defaults.collections[config.settingsKey]) do
            if settings[key] == nil then settings[key] = value end
        end
        settings.horizontalPosition = NCollections.Util.Clamp(tonumber(settings.horizontalPosition) or 50, 0, 100)
        settings.verticalPosition = NCollections.Util.Clamp(tonumber(settings.verticalPosition) or 50, 0, 100)
        settings.scale = NCollections.Util.Clamp(NCollections.Util.Round(tonumber(settings.scale) or 100), K.scaleMin, K.scaleMax)
        settings.backgroundOpacity = NCollections.Util.Clamp(NCollections.Util.Round(tonumber(settings.backgroundOpacity) or 90), K.opacityMin, K.opacityMax)
        settings.selectedCollectibleId = tonumber(settings.selectedCollectibleId) or 0
        if not NCollections.Util.IsFontChoice(settings.font) then settings.font = NCollections.Util.GetDefaultFont() end
        return settings
    end

    local function FormatName(value)
        if zo_strformat and SI_COLLECTIBLE_NAME_FORMATTER then return zo_strformat(SI_COLLECTIBLE_NAME_FORMATTER, value or "") end
        return tostring(value or NCollections.L("collections.unknown", singularLower))
    end

    local function IsBrowsable(data)
        if not data or not data.GetCategoryType or not categoryTypes[data:GetCategoryType()] then return false end
        if config.collectibleFilter and not config.collectibleFilter(data) then return false end
        if GetCollectibleHideMode and COLLECTIBLE_HIDE_MODE_ALWAYS then
            return GetCollectibleHideMode(data:GetId()) ~= COLLECTIBLE_HIDE_MODE_ALWAYS
        end
        return true
    end

    local function GetData(key)
        if not ZO_COLLECTIBLE_DATA_MANAGER or not ZO_COLLECTIBLE_DATA_MANAGER.GetCollectibleDataById then return nil end
        return ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(key)
    end

    local function GetTags(collectibleId)
        if not GetNumCollectibleTags or not GetCollectibleTagInfo then return "" end
        for index = #tagBuffer, 1, -1 do tagBuffer[index] = nil end
        for tagIndex = 1, GetNumCollectibleTags(collectibleId) do
            local description, _, hidden = GetCollectibleTagInfo(collectibleId, tagIndex)
            if not hidden and description and description ~= "" then tagBuffer[#tagBuffer + 1] = description end
        end
        local value = table.concat(tagBuffer, ", ")
        for index = #tagBuffer, 1, -1 do tagBuffer[index] = nil end
        return value
    end

    local function GetBlockReason(collectibleId)
        if not GetCollectibleBlockReason then return "" end
        local reason = GetCollectibleBlockReason(collectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
        if not reason or reason == COLLECTIBLE_USAGE_BLOCK_REASON_NOT_BLOCKED then return "" end
        return GetString and GetString("SI_COLLECTIBLEUSAGEBLOCKREASON", reason) or tostring(reason)
    end

    local function AddDetail(label, value)
        if value and value ~= "" then detailLines[#detailLines + 1] = string.format("|c72BEEB%s:|r %s", label, tostring(value)) end
    end

    local function BuildDetails(record)
        for index = #detailLines, 1, -1 do detailLines[index] = nil end
        if record.isNew then AddDetail(NCollections.L("collections.detail.new"), NCollections.L("common.yes")) end
        if config.showQuestState and record.questState ~= nil then
            local state = NCollections.L("common.available")
            if COLLECTIBLE_ASSOCIATED_QUEST_STATE_ACCEPTED and record.questState == COLLECTIBLE_ASSOCIATED_QUEST_STATE_ACCEPTED then state = NCollections.L("common.in_progress") end
            if COLLECTIBLE_ASSOCIATED_QUEST_STATE_COMPLETED and record.questState == COLLECTIBLE_ASSOCIATED_QUEST_STATE_COMPLETED then state = NCollections.L("common.completed") end
            AddDetail(NCollections.L("collections.detail.introduction_quest"), record.questName ~= "" and string.format("%s (%s)", record.questName, state) or state)
        end
        if config.appendDetailLines then config.appendDetailLines(record, detailLines, function(lines, label, value)
            if value and value ~= "" then lines[#lines + 1] = string.format("|c72BEEB%s:|r %s", label, tostring(value)) end
        end) end
        for _, detail in ipairs(record.extraDetails or {}) do AddDetail(detail.label, detail.value) end
        if not record.isAcquired and config.showPurchasable ~= false then AddDetail(NCollections.L("collections.detail.directly_purchasable"), record.isPurchasable and NCollections.L("common.yes") or NCollections.L("common.no")) end
        if record.isValidForPlayer == false then AddDetail(NCollections.L("collections.detail.available_to_character"), NCollections.L("common.no")) end
        if record.blockReason ~= "" then AddDetail(NCollections.L("collections.detail.use_restriction"), record.blockReason) end
        if record.tags ~= "" then AddDetail(NCollections.L("collections.detail.tags"), record.tags) end
        if record.description ~= "" then detailLines[#detailLines + 1] = "\n" .. record.description end
        if not record.isAcquired and record.hint ~= "" then AddDetail(NCollections.L("collections.detail.how_to_acquire"), record.hint) end
        return table.concat(detailLines, "\n")
    end

    local function BuildBuiltInRecord(key, details)
        local data = GetData(key)
        if not data then return nil end
        local acquired = data:IsUnlocked()
        local rawCategory = data.GetCategoryName and data:GetCategoryName() or plural
        local category = FormatName(rawCategory)
        if config.getCategoryName then category = config.getCategoryName(data, category) or category end
        local name = FormatName(data:GetName())
        local record = { collectibleId = key, name = name, categoryName = category, isAcquired = acquired }
        if not details then return record end
        local selected = config.supportsActive ~= false and data:IsActive(GAMEPLAY_ACTOR_CATEGORY_PLAYER) or false
        local suppressed = selected and data.ShouldSuppressActiveState and data:ShouldSuppressActiveState(GAMEPLAY_ACTOR_CATEGORY_PLAYER) or false
        local interactionId = data.GetPrimaryInteractionStringId and data:GetPrimaryInteractionStringId(GAMEPLAY_ACTOR_CATEGORY_PLAYER) or nil
        local nickname = config.showNickname and acquired and data.GetNickname and data:GetNickname() or ""
        record.displayName = nickname ~= "" and string.format("%s (%s)", name, nickname) or name
        record.description = data:GetDescription() or ""
        record.hint = not acquired and data:GetHint() or ""
        record.tags = GetTags(key)
        record.blockReason = GetBlockReason(key)
        record.isActive = selected and not suppressed
        record.isSuppressed = suppressed
        record.isNew = data.IsNew and data:IsNew() or false
        record.isPurchasable = data.IsPurchasable and data:IsPurchasable() or false
        record.isUsable = data.IsUsable and data:IsUsable(GAMEPLAY_ACTOR_CATEGORY_PLAYER) or false
        record.isBlocked = data.IsBlocked and data:IsBlocked(GAMEPLAY_ACTOR_CATEGORY_PLAYER) or false
        record.isValidForPlayer = not data.IsValidForPlayer or data:IsValidForPlayer()
        record.questState = config.showQuestState and data.GetCollectibleAssociatedQuestState and data:GetCollectibleAssociatedQuestState() or nil
        record.questName = config.showQuestState and data.GetQuestName and data:GetQuestName() or ""
        record.interactionStringId = interactionId
        record.hasAction = config.supportsActions ~= false and (acquired or config.allowUnacquiredUse) and record.isUsable and interactionId ~= nil or false
        record.actionLabel = interactionId and GetString and GetString(interactionId) or (record.isActive and (config.dismissLabel or NCollections.L("common.dismiss")) or (config.useLabel or NCollections.L("common.use")))
        if config.decorateRecord then config.decorateRecord(data, record, true) end
        if config.hasAction then record.hasAction = config.hasAction(record, data) == true end
        if config.getActionLabel then record.actionLabel = config.getActionLabel(record, data) or record.actionLabel end
        return record
    end

    local function NormalizeRecord(record, details, forSearch)
        if not record then return nil end
        record.collectibleId = record.collectibleId or 0
        record.name = tostring(record.name or NCollections.L("collections.unknown", singularLower))
        record.categoryName = tostring(record.categoryName or plural)
        record.displayName = record.displayName or record.name
        record.isAcquired = record.isAcquired == true
        if not details then
            if forSearch then
                record.searchText = record.searchText or NCollections.Util.Lower(table.concat({ record.name, record.categoryName, record.searchExtra or "" }, " "))
            end
            return record
        end
        record.isActive = record.isActive == true
        record.isSuppressed = record.isSuppressed == true
        record.isUsable = record.isUsable == true
        record.isBlocked = record.isBlocked == true
        record.hasAction = record.hasAction == true
        record.actionLabel = record.actionLabel or ""
        record.description = record.description or ""
        record.hint = record.hint or ""
        record.tags = record.tags or ""
        record.blockReason = record.blockReason or ""
        record.questName = record.questName or ""
        record.detailText = record.detailText or BuildDetails(record)
        return record
    end

    local function BuildRecord(key, details, forSearch)
        local record = config.buildRecord and config.buildRecord(key, details == true, forSearch == true) or BuildBuiltInRecord(key, details)
        return NormalizeRecord(record, details, forSearch)
    end

    local function IsAcquired(key)
        if config.isAcquiredKey then return config.isAcquiredKey(key) == true end
        if config.buildRecord then local record = config.buildRecord(key, false); return record and record.isAcquired == true or false end
        local data = GetData(key)
        return data and data:IsUnlocked() or false
    end

    local function BuildIndex()
        sourceKeys = {}
        if config.enumerateKeys then
            sourceKeys = config.enumerateKeys() or {}
        elseif ZO_COLLECTIBLE_DATA_MANAGER and next(categoryTypes) then
            NCollections.Util.ForEachCollectibleDataObject(ZO_COLLECTIBLE_DATA_MANAGER, nil, { IsBrowsable }, function(data)
                sourceKeys[#sourceKeys + 1] = data:GetId()
            end, 1)
        end
        return true
    end

    local function Matches(key)
        local acquired = IsAcquired(key)
        if filterIndex == 2 and not acquired then return false end
        if filterIndex == 3 and acquired then return false end
        if searchNeedle ~= "" then
            local record = BuildRecord(key, false, true)
            if not record or not string.find(record.searchText, searchNeedle, 1, true) then return false end
        end
        return true
    end

    local function Refilter(preferredKey)
        NCollections.Util.CancelFrameTask(selectedTaskName)
        window = {}; windowFirst = 0; windowLast = -1
        selectedRecord = nil; selectedRecordKey = nil; loadingSelectedKey = nil
        if filterIndex == 1 and searchNeedle == "" then
            filteredKeys = sourceKeys
        else
            filteredKeys = {}
            for index, key in ipairs(sourceKeys) do
                if Matches(key) then filteredKeys[#filteredKeys + 1] = key end
                NCollections.Util.FrameTaskCheckpoint(index, 25)
            end
        end
        selectedIndex = 0
        local wanted = preferredKey or GetSettings().selectedCollectibleId
        for index, key in ipairs(filteredKeys) do if key == wanted then selectedIndex = index; break end end
        if selectedIndex == 0 and #filteredKeys > 0 then selectedIndex = 1 end
        if filteredKeys[selectedIndex] then GetSettings().selectedCollectibleId = filteredKeys[selectedIndex] end
        visibleFirst = math.max(selectedIndex - 2, 1)
    end

    local function GetLayout()
        local screenWidth, screenHeight = GuiRoot:GetDimensions()
        screenWidth, screenHeight = tonumber(screenWidth) or 1920, tonumber(screenHeight) or 1080
        local settings = GetSettings()
        local scale = settings.scale / 100
        local width = NCollections.Util.Clamp(math.floor(math.max((screenWidth - K.margin * 2) / scale, K.minWidth) * 0.86), K.minWidth, K.maxWidth)
        local height = NCollections.Util.Clamp(math.floor(math.max((screenHeight - K.margin * 2) / scale, K.minHeight) * K.heightRatio), K.minHeight, K.maxHeight)
        local viewportHeight = height - K.padding - K.header - K.footer
        local rowHeight = NCollections.Util.Clamp(math.floor(viewportHeight / 11) - 4, 38, 54)
        return { screenWidth = screenWidth, screenHeight = screenHeight, scale = scale, width = width, height = height,
            visibleRows = math.max(math.floor(viewportHeight / (rowHeight + 4)), 1) }
    end

    local function KeepVisible(layout)
        if selectedIndex < visibleFirst or selectedIndex >= visibleFirst + layout.visibleRows then
            visibleFirst = math.floor(math.max(selectedIndex - 1, 0) / layout.visibleRows) * layout.visibleRows + 1
        end
        visibleFirst = NCollections.Util.Clamp(visibleFirst, 1, math.max(#filteredKeys, 1))
    end

    local function LoadWindow(first, count)
        local last = math.min(first + count - 1, #filteredKeys)
        if first == windowFirst and last == windowLast then return true end
        if first == loadingFirst and last == loadingLast then return false end
        NCollections.Util.CancelFrameTask(windowTaskName)
        NCollections.Util.CancelFrameTask(selectedTaskName)
        window = {}; windowFirst = 0; windowLast = -1
        selectedRecord = nil; selectedRecordKey = nil; loadingSelectedKey = nil
        loadingFirst = first; loadingLast = last
        local nextWindow = {}
        if NCollections.Util.RequestGarbageCollection then NCollections.Util.RequestGarbageCollection() end
        local starting = true
        local completedSynchronously = false
        NCollections.Util.StartFrameTask(windowTaskName, function()
            for index = first, last do
                nextWindow[index] = BuildRecord(filteredKeys[index], false, false)
                NCollections.Util.FrameTaskCheckpoint(index - first + 1, 1)
            end
        end, function()
            if loadingFirst ~= first or loadingLast ~= last then return end
            window = nextWindow; windowFirst = first; windowLast = last
            loadingFirst = 0; loadingLast = -1
            if starting then completedSynchronously = true
            elseif visible then Refresh() end
        end)
        starting = false
        return completedSynchronously or (windowFirst == first and windowLast == last)
    end

    local function LoadSelectedRecord()
        local key = filteredKeys[selectedIndex]
        if not key then
            selectedRecord = nil; selectedRecordKey = nil; loadingSelectedKey = nil
            return true
        end
        if selectedRecordKey == key and loadingSelectedKey == nil then return true end
        if loadingSelectedKey == key then return false end
        NCollections.Util.CancelFrameTask(selectedTaskName)
        selectedRecord = nil; selectedRecordKey = nil; loadingSelectedKey = key
        if NCollections.Util.RequestGarbageCollection then NCollections.Util.RequestGarbageCollection() end
        local nextRecord
        local starting = true
        local completedSynchronously = false
        NCollections.Util.StartFrameTask(selectedTaskName, function()
            nextRecord = BuildRecord(key, true, false)
            NCollections.Util.FrameTaskCheckpoint(1, 1)
        end, function()
            if loadingSelectedKey ~= key then return end
            selectedRecord = nextRecord; selectedRecordKey = key; loadingSelectedKey = nil
            if starting then completedSynchronously = true
            elseif visible then Refresh() end
        end)
        starting = false
        return completedSynchronously or (selectedRecordKey == key and loadingSelectedKey == nil)
    end

    local function GetSelected()
        if selectedRecordKey ~= filteredKeys[selectedIndex] then return nil end
        return selectedRecord
    end

    local function GetBinding(action, fallback)
        if ZO_Keybindings_GetHighestPriorityBindingStringFromAction and KEYBIND_TEXT_OPTIONS_FULL_NAME and KEYBIND_TEXTURE_OPTIONS_EMBED_MARKUP then
            return ZO_Keybindings_GetHighestPriorityBindingStringFromAction(action, KEYBIND_TEXT_OPTIONS_FULL_NAME, KEYBIND_TEXTURE_OPTIONS_EMBED_MARKUP, true, false, 100) or fallback
        end
        return fallback
    end

    local function GetHint()
        local record = GetSelected()
        local state = not record and 1 or (record.hasAction and (record.isActive and 4 or 3) or 2)
        if inputHints[filterIndex][state] then return inputHints[filterIndex][state] end
        local stick = NCollections.L("common.right_stick")
        if GetGamepadRightStickScrollIcon and zo_iconFormat then stick = zo_iconFormat(GetGamepadRightStickScrollIcon(), 30, 30) end
        local action = record and record.hasAction and NCollections.L("collections.action_hint", GetBinding("UI_SHORTCUT_PRIMARY", "X"), record.actionLabel) or ""
        local hint = NCollections.L("collections.input_hint_flat", action, stick, GetBinding("UI_SHORTCUT_LEFT_STICK", "L3"), GetBinding("UI_SHORTCUT_RIGHT_STICK", "R3"), filters[filterIndex])
        inputHints[filterIndex][state] = hint
        return hint
    end

    local function UpdateInputActivation()
        if not hud or not DIRECTIONAL_INPUT then return end
        local listening = DIRECTIONAL_INPUT.IsListening and DIRECTIONAL_INPUT:IsListening(hud)
        local shouldListen = visible and not searchOpen and hud.control and not hud.control:IsHidden() and #filteredKeys > 1
        if shouldListen and not listening then DIRECTIONAL_INPUT:Activate(hud, hud.control)
        elseif not shouldListen and listening then DIRECTIONAL_INPUT:Deactivate(hud) end
    end

    local function Render()
        hud = Hud.Acquire(owner, owner.release, function() Feature.UpdateDirectionalInput() end)
        if not hud then return end
        local layout = GetLayout()
        local settings = GetSettings()
        local rowCount = 0
        local details = NCollections.L("collections.preparing")
        if ready then
            KeepVisible(layout)
            if LoadWindow(visibleFirst, layout.visibleRows) then
                local selectedSummary = window[selectedIndex]
                for rowIndex = 1, layout.visibleRows do
                    local index = visibleFirst + rowIndex - 1
                    local record = window[index]
                    if not record then break end
                    rowCount = rowCount + 1
                    local row = hudRows[rowCount] or {}
                    hudRows[rowCount] = row
                    row.entry = record; row.header = false; row.selected = index == selectedIndex
                    local status = config.showActiveStatus ~= false and record.isActive and NCollections.L("common.active")
                        or config.showActiveStatus ~= false and record.isSuppressed and NCollections.L("common.selected")
                        or record.isAcquired and NCollections.L("common.acquired") or NCollections.L("common.missing")
                    row.text = record.name .. "  |cA1B8D1· " .. status .. "|r"
                end
                local selected = LoadSelectedRecord() and GetSelected() or nil
                if selected then
                    local status = config.showActiveStatus ~= false and selected.isActive and NCollections.L("common.active")
                        or config.showActiveStatus ~= false and selected.isSuppressed and NCollections.L("common.selected")
                        or selected.isAcquired and NCollections.L("common.acquired") or NCollections.L("common.not_acquired")
                    details = selected.displayName .. "\n|cA1B8D1" .. status .. " · " .. selected.categoryName .. "|r"
                        .. (selected.detailText ~= "" and "\n\n" .. selected.detailText or "")
                    if config.buildDetailColumns then
                        local columns = config.buildDetailColumns(selected)
                        for _, column in ipairs({ columns and columns.left, columns and columns.right }) do
                            if column and column.text and column.text ~= "" then details = details .. "\n\n" .. tostring(column.heading or "") .. "\n" .. column.text end
                        end
                    end
                end
                if not selectedSummary then
                    if searchText ~= "" then details = NCollections.L("collections.no_search_results", pluralLower, searchText)
                    else details = NCollections.L("collections.no_filter_results", pluralLower) end
                end
            end
        end
        for index = rowCount + 1, #hudRows do hudRows[index] = nil end
        Hud.Render(owner, { layout = layout, font = settings.font, backgroundOpacity = settings.backgroundOpacity,
            horizontalPosition = settings.horizontalPosition, verticalPosition = settings.verticalPosition,
            title = searchText ~= "" and NCollections.L("collections.title_search", pluralUpper, searchText) or pluralUpper,
            summary = ready and NCollections.L("collections.summary_indexed", #sourceKeys, #filteredKeys) or NCollections.L("collections.preparing"),
            leftHeader = ready and NCollections.Util.Upper(filters[filterIndex]) or "",
            rightHeader = ready and NCollections.L("collections.details", NCollections.Util.Upper(singular)) or "",
            rows = hudRows, details = details, hint = ready and GetHint() or "" })
        UpdateInputActivation()
    end

    local function CanUse()
        local record = GetSelected()
        if not record then return false end
        if config.canUseRecord then return config.canUseRecord(record) end
        if not record.isAcquired and not config.allowUnacquiredUse then return false, NCollections.L("collections.not_acquired", singularLower) end
        if not record.interactionStringId then return false end
        if record.isBlocked then return false, record.blockReason ~= "" and record.blockReason or NCollections.L("collections.cannot_use_now", singularLower) end
        if not record.isUsable then return false, NCollections.L("collections.cannot_use_now", singularLower) end
        return true
    end

    local function UseSelected()
        if not CanUse() then return end
        local record = GetSelected()
        if config.useRecord then config.useRecord(record)
        else
            local data = GetData(record.collectibleId)
            if data and data.Use then data:Use(GAMEPLAY_ACTOR_CATEGORY_PLAYER)
            elseif UseCollectible then UseCollectible(record.collectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER) end
        end
        if zo_callLater then zo_callLater(function() if visible then Feature.RefreshData() end end, 100)
        elseif visible then Feature.RefreshData() end
    end

    local function MoveSelection(delta)
        if #filteredKeys == 0 then return end
        local nextIndex = NCollections.Util.Clamp(selectedIndex + (delta > 0 and 1 or -1), 1, #filteredKeys)
        if nextIndex == selectedIndex then return end
        selectedIndex = nextIndex
        NCollections.Util.CancelFrameTask(selectedTaskName)
        selectedRecord = nil; selectedRecordKey = nil; loadingSelectedKey = nil
        GetSettings().selectedCollectibleId = filteredKeys[selectedIndex]
        Render()
        if PlaySound and SOUNDS then PlaySound(delta > 0 and SOUNDS.GAMEPAD_MENU_DOWN or SOUNDS.GAMEPAD_MENU_UP) end
    end

    local function CycleFilter()
        local preferred = filteredKeys[selectedIndex] or GetSettings().selectedCollectibleId
        filterIndex = filterIndex % 3 + 1
        Refilter(preferred)
        Render()
    end

    local function ReleaseSearch()
        if ZO_Dialogs_ReleaseDialogOnButtonPress then ZO_Dialogs_ReleaseDialogOnButtonPress(config.searchDialogName)
        elseif ZO_Dialogs_ReleaseDialog then ZO_Dialogs_ReleaseDialog(config.searchDialogName) end
    end

    local function ApplySearch(value)
        local preferred = filteredKeys[selectedIndex] or GetSettings().selectedCollectibleId
        searchText = tostring(value or "")
        if zo_strtrim then searchText = zo_strtrim(searchText) else searchText = string.match(searchText, "^%s*(.-)%s*$") or "" end
        searchNeedle = NCollections.Util.Lower(searchText)
        Refilter(preferred)
        Render()
    end

    local function RegisterSearch()
        if searchRegistered or not config.searchDialogName or not ZO_Dialogs_RegisterCustomDialog or not GAMEPAD_DIALOGS then return end
        searchRegistered = true
        ZO_Dialogs_RegisterCustomDialog(config.searchDialogName, {
            gamepadInfo = { dialogType = GAMEPAD_DIALOGS.PARAMETRIC },
            title = { text = function() return NCollections.L("collections.search_title", plural) end },
            setup = function(dialog)
                dialog.data = dialog.data or {}
                dialog.info.parametricList = {{
                    template = "ZO_Gamepad_GenericDialog_Parametric_TextFieldItem",
                    templateData = { nameField = true,
                        textChangedCallback = function(editBox) dialog.data.searchText = editBox:GetText() end,
                        setup = function(control, data, selected)
                            if control.highlight then control.highlight:SetHidden(not selected) end
                            local edit = control.editBoxControl; edit.textChangedCallback = data.textChangedCallback
                            if edit.SetMaxInputChars then edit:SetMaxInputChars(50) end
                            if edit.SetDefaultText then edit:SetDefaultText(NCollections.L("collections.search_name_placeholder", singular)) end
                            edit:SetText(dialog.data.searchText or ""); data.control = control
                        end,
                        callback = function(ref) local data = ref.entryList:GetTargetData(); if data and data.control then data.control.editBoxControl:TakeFocus() end end,
                        narrationText = ZO_GetDefaultParametricListEditBoxNarrationText,
                    },
                }, {
                    template = "ZO_GamepadTextFieldSubmitItem",
                    templateData = { text = NCollections.L("features.collections_collectible_browser.apply_search_96b8b79"), callback = function(ref) ApplySearch(ref.data and ref.data.searchText or ""); ReleaseSearch() end },
                }, {
                    template = "ZO_GamepadTextFieldSubmitItem",
                    templateData = { text = NCollections.L("features.collections_collectible_browser.clear_search_87e328d"), callback = function() ApplySearch(""); ReleaseSearch() end },
                }}
                dialog:setupFunc()
            end,
            blockDialogReleaseOnPress = true,
            finishedCallback = function() searchOpen = false; UpdateInputActivation() end,
            buttons = {{ keybind = "DIALOG_PRIMARY", text = SI_GAMEPAD_SELECT_OPTION, callback = function(dialog) local data = dialog.entryList:GetTargetData(); if data and data.callback then data.callback(dialog) end end },
                { keybind = "DIALOG_NEGATIVE", text = SI_DIALOG_CANCEL, callback = ReleaseSearch }},
        })
    end

    local function OpenSearch()
        if not ZO_Dialogs_ShowGamepadDialog then return end
        RegisterSearch()
        if not searchRegistered then return end
        searchOpen = true
        UpdateInputActivation()
        ZO_Dialogs_ShowGamepadDialog(config.searchDialogName, { searchText = searchText })
    end

    keybindGroup = {
        { name = function() local record = GetSelected(); return record and record.actionLabel or "" end,
            keybind = "UI_SHORTCUT_PRIMARY", callback = UseSelected,
            visible = function() local record = GetSelected(); return record and record.hasAction or false end,
            enabled = CanUse, sound = SOUNDS and SOUNDS.DEFAULT_CLICK },
        { keybind = "UI_SHORTCUT_RIGHT_STICK", ethereal = true, callback = CycleFilter },
        { name = function() return NCollections.L("common.search") end, keybind = "UI_SHORTCUT_LEFT_STICK", ethereal = true, callback = OpenSearch },
    }

    local function RefreshKeybinds()
        if not KEYBIND_STRIP then return end
        local active = hud and hud.control and not hud.control:IsHidden() and not searchOpen
        local record = GetSelected()
        local state = record and record.hasAction and record.actionLabel or ""
        if active and not keybindsActive then KEYBIND_STRIP:AddKeybindButtonGroup(keybindGroup); keybindsActive = true; keybindState = state
        elseif active and keybindsActive and keybindState ~= state and KEYBIND_STRIP.UpdateKeybindButtonGroup then KEYBIND_STRIP:UpdateKeybindButtonGroup(keybindGroup); keybindState = state
        elseif not active and keybindsActive then KEYBIND_STRIP:RemoveKeybindButtonGroup(keybindGroup); keybindsActive = false; keybindState = nil end
    end

    Refresh = function()
        if not visible then
            Hud.Hide(owner)
            RefreshKeybinds()
            return
        end
        Render()
        RefreshKeybinds()
    end

    ClearData = function()
        NCollections.Util.CancelFrameTask(taskName)
        NCollections.Util.CancelFrameTask(windowTaskName)
        NCollections.Util.CancelFrameTask(selectedTaskName)
        if hud and DIRECTIONAL_INPUT and DIRECTIONAL_INPUT.IsListening and DIRECTIONAL_INPUT:IsListening(hud) then
            DIRECTIONAL_INPUT:Deactivate(hud)
        end
        ready = false
        sourceKeys = {}; filteredKeys = {}; window = {}; hudRows = {}; inputHints = { {}, {}, {} }; tagBuffer = {}; detailLines = {}
        selectedRecord = nil; selectedRecordKey = nil; loadingSelectedKey = nil
        windowFirst = 0; windowLast = -1; loadingFirst = 0; loadingLast = -1
        selectedIndex = 1; visibleFirst = 1
        searchText = ""; searchNeedle = ""; searchOpen = false; keybindState = nil
        if config.releaseData then config.releaseData() end
        if NCollections.Util.RequestGarbageCollection then NCollections.Util.RequestGarbageCollection(true) end
    end

    owner.release = function()
        visible = false
        ClearData()
        hud = nil
    end

    function Feature.RefreshData()
        if not visible then return end
        local preferred = filteredKeys[selectedIndex] or GetSettings().selectedCollectibleId
        ready = false
        NCollections.Util.StartFrameTask(taskName, function()
            BuildIndex()
            Refilter(preferred)
            ready = true
        end, function() if visible then Refresh() end end)
        Refresh()
    end

    function Feature.UpdateDirectionalInput()
        if not hud or hud.control:IsHidden() or searchOpen or not DIRECTIONAL_INPUT or not ZO_DI_RIGHT_STICK then return end
        local y = DIRECTIONAL_INPUT:GetY(ZO_DI_RIGHT_STICK) or 0
        if math.abs(y) <= K.deadzone then hud.inputDirection = 0; hud.nextInputAt = 0; return end
        local direction = y < 0 and 1 or -1
        local now = GetFrameTimeMilliseconds and GetFrameTimeMilliseconds() or 0
        if direction ~= hud.inputDirection then hud.inputDirection = direction; hud.nextInputAt = now + K.initialDelay; MoveSelection(direction)
        elseif now >= (hud.nextInputAt or 0) then hud.nextInputAt = now + K.repeatDelay; MoveSelection(direction) end
        if DIRECTIONAL_INPUT.Consume then DIRECTIONAL_INPUT:Consume(ZO_DI_RIGHT_STICK) end
    end

    function Feature.InitializeSavedVariables() savedVariables = NCollections.Settings.NewAccountWide(defaults); GetSettings() end
    function Feature.Initialize() end
    function Feature.SetSettingsPanelVisible(value)
        local showing = value == true
        if showing == visible then return end
        visible = showing
        if showing then Feature.RefreshData(); return end
        if searchOpen then ReleaseSearch() end
        Hud.Hide(owner); ClearData(); Hud.Release(owner); hud = nil; RefreshKeybinds()
    end

    function Feature.GetHorizontalPosition() return GetSettings().horizontalPosition end
    function Feature.SetHorizontalPosition(value) GetSettings().horizontalPosition = NCollections.Util.Clamp(value, 0, 100); Refresh() end
    function Feature.GetVerticalPosition() return GetSettings().verticalPosition end
    function Feature.SetVerticalPosition(value) GetSettings().verticalPosition = NCollections.Util.Clamp(value, 0, 100); Refresh() end
    function Feature.GetFontChoices() return NCollections.Util.GetFontChoices() end
    function Feature.GetFontChoiceNames() return NCollections.Util.GetFontChoiceNames() end
    function Feature.GetFont() return GetSettings().font end
    function Feature.SetFont(value) if not NCollections.Util.IsFontChoice(value) then value = NCollections.Util.GetDefaultFont() end; GetSettings().font = value; Refresh() end
    function Feature.GetScale() return GetSettings().scale end
    function Feature.SetScale(value) GetSettings().scale = NCollections.Util.Clamp(NCollections.Util.Round(value), K.scaleMin, K.scaleMax); Refresh() end
    function Feature.GetScaleMin() return K.scaleMin end
    function Feature.GetScaleMax() return K.scaleMax end
    function Feature.GetBackgroundOpacity() return GetSettings().backgroundOpacity end
    function Feature.SetBackgroundOpacity(value) GetSettings().backgroundOpacity = NCollections.Util.Clamp(NCollections.Util.Round(value), K.opacityMin, K.opacityMax); Refresh() end
    function Feature.GetBackgroundOpacityMin() return K.opacityMin end
    function Feature.GetBackgroundOpacityMax() return K.opacityMax end
    function Feature.GetHorizontalPositionLabel() return NCollections.L("features.collections_collectible_browser.horizontal_position_label") end
    function Feature.GetHorizontalPositionTooltip() return NCollections.L("collections.horizontal_tooltip", plural) end
    function Feature.GetVerticalPositionLabel() return NCollections.L("features.collections_collectible_browser.vertical_position_label") end
    function Feature.GetVerticalPositionTooltip() return NCollections.L("collections.vertical_tooltip", plural) end
    function Feature.GetFontLabel() return NCollections.L("features.collections_collectible_browser.font_label") end
    function Feature.GetFontTooltip() return NCollections.L("collections.font_tooltip", plural) end
    function Feature.GetScaleLabel() return NCollections.L("features.collections_collectible_browser.scale_label") end
    function Feature.GetScaleTooltip() return NCollections.L("collections.scale_tooltip", plural) end
    function Feature.GetBackgroundOpacityLabel() return NCollections.L("features.collections_collectible_browser.background_opacity_label") end
    function Feature.GetBackgroundOpacityTooltip() return NCollections.L("collections.opacity_tooltip", plural) end
    function Feature.GetLoadedRecordCount() local count = 0; for _, record in pairs(window) do if record then count = count + 1 end end; return count end
    function Feature.GetLoadedDetailedRecordCount() return selectedRecord and 1 or 0 end
    function Feature.GetExtraSetting(key) return GetSettings()[key] end
    function Feature.SetExtraSetting(key, value) GetSettings()[key] = value; Refresh() end

    return Feature
end

NCollections.Features.CollectionsLazyBrowser = LazyBrowser
NCollections.Features.CollectionsCollectibleBrowser = LazyBrowser
