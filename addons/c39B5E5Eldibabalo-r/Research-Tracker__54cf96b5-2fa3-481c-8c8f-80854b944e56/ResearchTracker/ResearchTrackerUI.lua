ResearchTrackerUI = ResearchTrackerUI or {}
local RT_UI = ResearchTrackerUI
local RT = ResearchTracker

RT_UI.initialized = false
RT_UI.visible = false
RT_UI.mainSceneName = "rtMainScene"
RT_UI.detailSceneName = "rtDetailScene"
RT_UI.activeView = "main"
RT_UI.selectedRow = 1
RT_UI.scrollOffset = 0
RT_UI.currentRows = {}
RT_UI.currentCraftIndex = 1
RT_UI.lastJoystickDirection = 0
RT_UI.lastJoystickMoveMs = nil
RT_UI.searchText = ""
RT_UI.baseRows = {}
RT_UI.characterIds = {}
RT_UI.viewedCharacterId = nil
RT_UI.crafterCharacterId = nil
RT_UI.shoppingMode = false
RT_UI.queueOnlyMode = false
RT_UI.pendingCrafterCharacterId = nil
RT_UI.autoCraftSummaryWindow = nil
RT_UI.autoCraftSummaryHideAtMs = 0
RT_UI.initialLoadRetryCount = 0
RT_UI.hubRetryScheduled = false

local MAX_VISIBLE_ROWS = 14
local ROW_HEIGHT = 34

local function GetChild(parent, name)
    if not parent then
        return nil
    end
    return parent:GetNamedChild(name)
end

local function SafeSetText(control, value)
    if control then
        control:SetText(value or "")
    end
end

local function NormalizeSearch(text)
    if type(text) ~= "string" then
        return ""
    end
    return zo_strlower(text:gsub("^%s+", ""):gsub("%s+$", ""))
end

function RT_UI:GetNowMs()
    return (type(GetFrameTimeMilliseconds) == "function" and GetFrameTimeMilliseconds())
        or (type(GetGameTimeMilliseconds) == "function" and GetGameTimeMilliseconds())
        or 0
end

function RT_UI:GetRawLeftStickY()
    local reader = _G["GetGamepadLeftStickY"]
    if type(reader) ~= "function" then
        return nil
    end
    local ok, value = pcall(reader)
    if ok and type(value) == "number" then
        return value
    end
    return nil
end

function RT_UI:PollJoystickNavigation()
    if not self.visible then
        return
    end
    local rawY = self:GetRawLeftStickY()
    local direction = 0
    if type(rawY) == "number" then
        if rawY >= 0.35 then
            direction = -1
        elseif rawY <= -0.35 then
            direction = 1
        end
    end
    if direction == 0 then
        self.lastJoystickDirection = 0
        return
    end
    local nowMs = self:GetNowMs()
    local repeatMs = 100
    local changedDirection = self.lastJoystickDirection ~= direction
    if changedDirection or not self.lastJoystickMoveMs or (nowMs - self.lastJoystickMoveMs) >= repeatMs then
        self:MoveCursor(direction)
        self.lastJoystickMoveMs = nowMs
        self.lastJoystickDirection = direction
    end
end

function RT_UI:GetMainWindow()
    return _G["RT_MainWindow"]
end

function RT_UI:GetDetailWindow()
    return _G["RT_DetailWindow"]
end

function RT_UI:CreateRowsForList(listArea, prefix)
    if not listArea then
        return {}
    end
    local rows = {}
    local width = listArea:GetWidth()
    if width <= 0 then
        width = 1120
    end
    for idx = 1, MAX_VISIBLE_ROWS do
        local row = WINDOW_MANAGER:CreateControl(prefix .. "_Row" .. idx, listArea, CT_CONTROL)
        row:SetDimensions(width, ROW_HEIGHT)
        row:SetAnchor(TOPLEFT, listArea, TOPLEFT, 0, (idx - 1) * ROW_HEIGHT)
        row:SetMouseEnabled(true)

        local bg = WINDOW_MANAGER:CreateControl(nil, row, CT_BACKDROP)
        bg:SetAnchorFill(row)
        bg:SetCenterColor(0.06, 0.06, 0.06, 0.75)
        bg:SetEdgeColor(0.20, 0.20, 0.20, 0.80)
        bg:SetInsets(-1, -1, 1, 1)

        local selected = WINDOW_MANAGER:CreateControl(nil, row, CT_TEXTURE)
        selected:SetAnchorFill(row)
        selected:SetColor(0.91, 0.75, 0.36, 0.22)
        selected:SetHidden(true)

        local title = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
        title:SetAnchor(LEFT, row, LEFT, 10, 0)
        title:SetDimensions(300, ROW_HEIGHT)
        title:SetFont("$(BOLD_FONT)|22|soft-shadow-thick")
        title:SetVerticalAlignment(TEXT_ALIGN_CENTER)

        local detail = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
        detail:SetAnchor(LEFT, title, RIGHT, 8, 0)
        detail:SetDimensions(width - 330, ROW_HEIGHT)
        detail:SetFont("$(MEDIUM_FONT)|20|soft-shadow-thin")
        detail:SetVerticalAlignment(TEXT_ALIGN_CENTER)

        local rowIndex = idx
        row:SetHandler("OnMouseUp", function(_, button)
            if button ~= MOUSE_BUTTON_INDEX_LEFT then
                return
            end
            self.selectedRow = rowIndex
            self:HandlePrimaryAction()
        end)

        rows[idx] = {
            row = row,
            selected = selected,
            title = title,
            detail = detail,
        }
    end
    return rows
end

function RT_UI:GetCurrentDataCount()
    return #self.currentRows
end

function RT_UI:GetVisibleRows()
    local total = self:GetCurrentDataCount()
    return zo_min(MAX_VISIBLE_ROWS, total)
end

function RT_UI:MoveCursor(delta)
    local total = self:GetCurrentDataCount()
    if total <= 0 then
        return
    end
    local currentAbs = self.scrollOffset + self.selectedRow
    local newAbs = zo_clamp(currentAbs + (delta or 0), 1, total)
    local visible = self:GetVisibleRows()
    if visible <= 0 then
        return
    end

    if newAbs < self.scrollOffset + 1 then
        self.scrollOffset = newAbs - 1
    elseif newAbs > self.scrollOffset + visible then
        self.scrollOffset = newAbs - visible
    end
    self.selectedRow = zo_clamp(newAbs - self.scrollOffset, 1, visible)
    self:RefreshActiveList()
end

function RT_UI:ScrollLineUp()
    self:MoveCursor(-1)
end

function RT_UI:ScrollLineDown()
    self:MoveCursor(1)
end

function RT_UI:ScrollPageUp()
    self:MoveCursor(-MAX_VISIBLE_ROWS)
end

function RT_UI:ScrollPageDown()
    self:MoveCursor(MAX_VISIBLE_ROWS)
end

function RT_UI:ApplySearchFilter()
    local search = NormalizeSearch(self.searchText)
    self.currentRows = {}
    if search == "" then
        for i = 1, #self.baseRows do
            self.currentRows[#self.currentRows + 1] = self.baseRows[i]
        end
    else
        for i = 1, #self.baseRows do
            local row = self.baseRows[i]
            local title = NormalizeSearch(row.title or "")
            local detail = NormalizeSearch(row.detail or "")
            if title:find(search, 1, true) or detail:find(search, 1, true) then
                self.currentRows[#self.currentRows + 1] = row
            end
        end
    end
    self.scrollOffset = 0
    self.selectedRow = 1
end

function RT_UI:RefreshCharacterList()
    if not RT then
        return
    end
    self.characterIds = RT:GetKnownCharacterIds() or {}
    local currentId = RT:GetCurrentCharacterIdString()
    local preferred = RT:GetPreferredCrafterId()
    if preferred then
        self.crafterCharacterId = preferred
    elseif not self.crafterCharacterId then
        self.crafterCharacterId = currentId
    end
    local function Contains(list, value)
        for i = 1, #list do
            if list[i] == value then
                return true
            end
        end
        return false
    end
    if not Contains(self.characterIds, self.crafterCharacterId) then
        -- Keep explicit preferred crafter even when that character has no fresh snapshot yet.
        if not preferred then
            self.crafterCharacterId = self.characterIds[1]
        end
    end
    if not Contains(self.characterIds, self.viewedCharacterId) then
        self.viewedCharacterId = currentId
        if not Contains(self.characterIds, self.viewedCharacterId) then
            self.viewedCharacterId = self.characterIds[1]
        end
    end
end

function RT_UI:CycleViewedCharacter(delta)
    self:RefreshCharacterList()
    if not self.viewedCharacterId or #self.characterIds <= 0 then
        return
    end
    local currentIdx = 1
    for i = 1, #self.characterIds do
        if self.characterIds[i] == self.viewedCharacterId then
            currentIdx = i
            break
        end
    end
    local count = #self.characterIds
    local newIdx = ((currentIdx - 1 + (delta or 1)) % count) + 1
    self.viewedCharacterId = self.characterIds[newIdx]

    if self.activeView == "detail" then
        self:OpenDetail(self.currentCraftIndex)
    else
        self:OpenMain()
    end
end

function RT_UI:SetMasterCrafterToViewedCharacter()
    self:RefreshCharacterList()
    if not self.viewedCharacterId then
        return
    end
    if self.crafterCharacterId == self.viewedCharacterId then
        local crafterName = RT:GetCharacterDisplayName(self.crafterCharacterId)
        d(string.format("[ResearchTracker] Master crafter already set: %s", crafterName or "?"))
        return
    end
    if ZO_Dialogs_ShowPlatformDialog then
        self.pendingCrafterCharacterId = self.viewedCharacterId
        ZO_Dialogs_ShowPlatformDialog("RT_CONFIRM_SET_CRAFTER_DIALOG")
        return
    end
    if ZO_Dialogs_ShowDialog then
        self.pendingCrafterCharacterId = self.viewedCharacterId
        ZO_Dialogs_ShowDialog("RT_CONFIRM_SET_CRAFTER_DIALOG")
        return
    end
    self:ConfirmSetMasterCrafter(self.viewedCharacterId)
end

function RT_UI:ConfirmSetMasterCrafter(charId)
    if not charId then
        return
    end
    if RT:SetPreferredCrafterId(charId) then
        self.crafterCharacterId = charId
        local crafterName = RT:GetCharacterDisplayName(self.crafterCharacterId)
        d(string.format("[ResearchTracker] Master crafter set: %s", crafterName or "?"))
        if self.activeView == "detail" then
            self:OpenDetail(self.currentCraftIndex)
        else
            self:OpenMain()
        end
    end
end

function RT_UI:OpenDetail(craftIndex)
    self:RefreshCharacterList()
    local detail = RT:GetDetailForCraft(craftIndex, self.viewedCharacterId)
    if not detail then
        return
    end
    self.currentCraftIndex = craftIndex
    RT:SetLastCraftIndex(craftIndex)

    local detailWindow = self:GetDetailWindow()
    local titleLabel = GetChild(detailWindow, "Title")
    local infoLabel = GetChild(detailWindow, "Info")

    local activeText = string.format("Char: %s  Active %d  Free Slots %d/%d", detail.characterName or "?", detail.researching, detail.freeSlots or 0, detail.maxSlots or 0)
    if self.shoppingMode and self.queueOnlyMode then
        local crafterName = RT:GetCharacterDisplayName(self.crafterCharacterId)
        activeText = string.format("Queue for %s  |  Crafter %s", detail.characterName or "?", crafterName or "?")
    elseif self.shoppingMode then
        local crafterName = RT:GetCharacterDisplayName(self.crafterCharacterId)
        activeText = string.format("Shopping for %s  |  Crafter %s", detail.characterName or "?", crafterName or "?")
    end
    SafeSetText(titleLabel, string.format("%s Research", detail.craftLabel))
    SafeSetText(infoLabel, activeText)

    local detailRows = {}
    if self.shoppingMode and self.queueOnlyMode then
        detailRows = RT:BuildQueuedRows(self.viewedCharacterId, craftIndex, self.crafterCharacterId)
    elseif self.shoppingMode then
        detailRows = RT:BuildShoppingRows(self.viewedCharacterId, craftIndex, self.crafterCharacterId)
    else
        for _, item in ipairs(detail.items or {}) do
            local stateLabel = "Available"
            local detailText = ""
            local statePriority = 2
            if item.state == "completed" then
                stateLabel = "Completed"
                detailText = "Done"
                statePriority = 3
            elseif item.state == "researching" then
                stateLabel = "Researching"
                detailText = RT:FormatSeconds(item.remaining)
                statePriority = 1
            end
            detailRows[#detailRows + 1] = {
                title = string.format("%s - %s", item.lineName or "Line", item.name or "Trait"),
                detail = string.format("%s  %s", stateLabel, detailText),
                state = item.state,
                statePriority = statePriority,
                remaining = item.remaining or 0,
            }
        end

        table.sort(detailRows, function(a, b)
            if (a.statePriority or 9) ~= (b.statePriority or 9) then
                return (a.statePriority or 9) < (b.statePriority or 9)
            end
            if (a.state == "researching") and (b.state == "researching") then
                if (a.remaining or 0) ~= (b.remaining or 0) then
                    return (a.remaining or 0) < (b.remaining or 0)
                end
            end
            return tostring(a.title or "") < tostring(b.title or "")
        end)
    end

    if self.shoppingMode then
        for i = 1, #detailRows do
            local row = detailRows[i]
            local prefix = row.queued and "[x] " or "[ ] "
            row.title = prefix .. tostring(row.title or "")
        end
    end

    self.baseRows = detailRows
    self:ApplySearchFilter()

    self.activeView = "detail"
    if SCENE_MANAGER then
        SCENE_MANAGER:Show(self.detailSceneName)
    end
    self:RefreshActiveList()
    if KEYBIND_STRIP and self.keybindStripDescriptor then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)
    end
end

function RT_UI:OpenMain()
    if RT then
        RT:RefreshCurrentCharacterSnapshot()
    end
    self:RefreshCharacterList()
    local mainRows = RT:GetSummaryRows(self.viewedCharacterId)
    if #mainRows == 0 and #self.characterIds > 0 then
        for i = 1, #self.characterIds do
            local candidateId = self.characterIds[i]
            local candidateRows = RT:GetSummaryRows(candidateId)
            if #candidateRows > 0 then
                self.viewedCharacterId = candidateId
                mainRows = candidateRows
                break
            end
        end
    end
    if #mainRows == 0 then
        self.initialLoadRetryCount = (self.initialLoadRetryCount or 0) + 1
        if (self.initialLoadRetryCount or 0) <= 12 then
            zo_callLater(function()
                if RT then
                    RT:RefreshCurrentCharacterSnapshot()
                end
                if self.visible and self.activeView == "main" then
                    self:OpenMain()
                end
            end, 1000)
        end
        mainRows = {
            {
                craftIndex = nil,
                title = "Loading research data...",
                detail = "First login can take a few seconds. Please wait.",
            },
        }
    else
        self.initialLoadRetryCount = 0
    end
    self.searchText = ""
    local mainWindow = self:GetMainWindow()
    local mainSearchBox = GetChild(mainWindow, "SearchBox")
    local mainEdit = mainSearchBox and GetChild(mainSearchBox, "Edit")
    if mainEdit and type(mainEdit.SetText) == "function" then
        mainEdit:SetText("")
    end
    local detailWindow = self:GetDetailWindow()
    local detailSearchBox = GetChild(detailWindow, "SearchBox")
    local detailEdit = detailSearchBox and GetChild(detailSearchBox, "Edit")
    if detailEdit and type(detailEdit.SetText) == "function" then
        detailEdit:SetText("")
    end
    self.baseRows = {}
    for _, row in ipairs(mainRows) do
        self.baseRows[#self.baseRows + 1] = {
            title = row.title,
            detail = row.detail,
            craftIndex = row.craftIndex,
        }
    end
    local mainWindow = self:GetMainWindow()
    local titleLabel = GetChild(mainWindow, "Title")
    local infoLabel = GetChild(mainWindow, "Info")
    local charName = RT:GetCharacterDisplayName(self.viewedCharacterId)
    local crafterName = RT:GetCharacterDisplayName(self.crafterCharacterId)
    SafeSetText(titleLabel, "Research Tracker")
    SafeSetText(infoLabel, string.format("Character: %s  |  Crafter: %s", charName or "?", crafterName or "?"))
    self:ApplySearchFilter()
    self.activeView = "main"
    self.shoppingMode = false
    self.queueOnlyMode = false
    if SCENE_MANAGER then
        SCENE_MANAGER:Show(self.mainSceneName)
    end
    self:RefreshActiveList()
    if KEYBIND_STRIP and self.keybindStripDescriptor then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)
    end
end

function RT_UI:RefreshMainView(forceRetry)
    if self.activeView ~= "main" then
        self:OpenMain()
        return
    end
    if RT then
        RT:RefreshCurrentCharacterSnapshot()
    end
    self:RefreshCharacterList()
    local mainRows = RT:GetSummaryRows(self.viewedCharacterId)
    if #mainRows == 0 and #self.characterIds > 0 then
        for i = 1, #self.characterIds do
            local candidateId = self.characterIds[i]
            local candidateRows = RT:GetSummaryRows(candidateId)
            if #candidateRows > 0 then
                self.viewedCharacterId = candidateId
                mainRows = candidateRows
                break
            end
        end
    end
    if #mainRows == 0 and forceRetry then
        self.initialLoadRetryCount = 0
        self:OpenMain()
        return
    end

    self.baseRows = {}
    for _, row in ipairs(mainRows) do
        self.baseRows[#self.baseRows + 1] = {
            title = row.title,
            detail = row.detail,
            craftIndex = row.craftIndex,
        }
    end
    self:ApplySearchFilter()
    self:RefreshActiveList()
end

function RT_UI:RefreshActiveList()
    local window, rows
    if self.activeView == "detail" then
        window = self:GetDetailWindow()
        rows = self.detailRows
    else
        window = self:GetMainWindow()
        rows = self.mainRows
    end
    if not window or not rows then
        return
    end

    local total = #self.currentRows
    local maxOffset = zo_max(total - MAX_VISIBLE_ROWS, 0)
    self.scrollOffset = zo_clamp(self.scrollOffset or 0, 0, maxOffset)
    local visible = self:GetVisibleRows()
    if visible <= 0 then
        self.selectedRow = 1
    else
        self.selectedRow = zo_clamp(self.selectedRow or 1, 1, visible)
    end

    local start = self.scrollOffset + 1
    for i = 1, MAX_VISIBLE_ROWS do
        local slot = rows[i]
        local data = self.currentRows[start + i - 1]
        if data then
            slot.row:SetHidden(false)
            slot.selected:SetHidden(i ~= self.selectedRow)
            slot.title:SetText(data.title or "")
            slot.detail:SetText(data.detail or "")
            if data.state == "researching" then
                slot.title:SetColor(0.91, 0.75, 0.36, 1)
                slot.detail:SetColor(0.98, 0.84, 0.45, 1)
            elseif data.state == "craftable" then
                slot.title:SetColor(0.65, 1.0, 0.65, 1)
                slot.detail:SetColor(0.65, 1.0, 0.65, 1)
            elseif data.state == "missing" then
                slot.title:SetColor(1.0, 0.75, 0.75, 1)
                slot.detail:SetColor(1.0, 0.75, 0.75, 1)
            else
                slot.title:SetColor(1, 1, 1, 1)
                slot.detail:SetColor(0.85, 0.85, 0.85, 1)
            end
            if data.queued then
                slot.title:SetColor(0.58, 0.92, 1.0, 1)
            end
        else
            slot.row:SetHidden(true)
            slot.selected:SetHidden(true)
        end
    end

    local footer = GetChild(window, "Footer")
    if footer then
        local absRow = (visible > 0) and (self.scrollOffset + self.selectedRow) or 0
        if self.searchText and self.searchText ~= "" then
            footer:SetText(string.format("Row %d/%d  Filter: %s", absRow, total, self.searchText))
        else
            footer:SetText(string.format("Row %d/%d", absRow, total))
        end
    end
end

function RT_UI:HandlePrimaryAction()
    if self.activeView == "main" then
        local idx = self.scrollOffset + self.selectedRow
        local row = self.currentRows[idx]
        if row and row.craftIndex then
            self:OpenDetail(row.craftIndex)
        end
        return
    end
    if self.activeView == "detail" and self.shoppingMode then
        local idx = self.scrollOffset + self.selectedRow
        local row = self.currentRows[idx]
        if row and row.lineIndex and row.traitIndex then
            local changed, queuedNow = RT:ToggleQueueItem(self.viewedCharacterId, self.currentCraftIndex, row.lineIndex, row.traitIndex)
            if changed then
                local stateText = queuedNow and "Queued" or "Removed from queue"
                d(string.format("[ResearchTracker] %s: %s", stateText, tostring(row.title or "row")))
                if self.queueOnlyMode then
                    local previousAbs = self.scrollOffset + self.selectedRow
                    self:OpenDetail(self.currentCraftIndex)
                    local total = #self.currentRows
                    if total > 0 then
                        local clampedAbs = zo_clamp(previousAbs, 1, total)
                        local maxOffset = zo_max(total - MAX_VISIBLE_ROWS, 0)
                        local preferredRow = zo_max(self.selectedRow or 1, 1)
                        self.scrollOffset = zo_clamp(clampedAbs - preferredRow, 0, maxOffset)
                        local visible = self:GetVisibleRows()
                        self.selectedRow = zo_clamp(clampedAbs - self.scrollOffset, 1, zo_max(visible, 1))
                    end
                    self:RefreshActiveList()
                    return
                end

                local baseTitle = tostring(row.title or "")
                baseTitle = baseTitle:gsub("^%[[x ]%]%s+", "")
                row.queued = queuedNow
                row.title = (queuedNow and "[x] " or "[ ] ") .. baseTitle
                self:RefreshActiveList()
                return
            else
                d("[ResearchTracker] Could not toggle queue for this row.")
            end
        end
    end
end

function RT_UI:HandleBackAction()
    if self.activeView == "detail" then
        self:OpenMain()
    else
        if SCENE_MANAGER and SCENE_MANAGER:IsShowing(self.mainSceneName) then
            SCENE_MANAGER:HideCurrentScene()
        end
    end
end

function RT_UI:BuildKeybindStrip()
    self.keybindStripDescriptor = {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        {
            keybind = "UI_SHORTCUT_NEGATIVE",
            name = GetString(SI_GAMEPAD_BACK_OPTION),
            callback = function() self:HandleBackAction() end,
            sound = SOUNDS.GAMEPAD_MENU_BACK,
        },
        {
            keybind = "UI_SHORTCUT_PRIMARY",
            name = function()
                if self.activeView == "detail" and self.shoppingMode then
                    return "Toggle Queue"
                end
                return "Open"
            end,
            callback = function() self:HandlePrimaryAction() end,
            visible = function() return self.activeView == "main" or (self.activeView == "detail" and self.shoppingMode) end,
        },
        {
            keybind = "UI_SHORTCUT_SECONDARY",
            name = function()
                if self.activeView == "detail" then
                    if not self.shoppingMode then
                        return "Shopping"
                    end
                    if self.queueOnlyMode then
                        return "List"
                    end
                    return "Queue"
                end
                return "Refresh"
            end,
            callback = function()
                if self.activeView == "main" then
                    self:RefreshMainView(true)
                    return
                end
                if self.activeView ~= "detail" then
                    return
                end
                if not self.shoppingMode then
                    self.shoppingMode = true
                    self.queueOnlyMode = false
                elseif not self.queueOnlyMode then
                    self.queueOnlyMode = true
                else
                    self.shoppingMode = false
                    self.queueOnlyMode = false
                end
                self:OpenDetail(self.currentCraftIndex)
            end,
            visible = function() return self.activeView == "main" or self.activeView == "detail" end,
        },
        {
            keybind = "UI_SHORTCUT_LEFT_TRIGGER",
            name = "Up",
            callback = function() self:ScrollLineUp() end,
        },
        {
            keybind = "UI_SHORTCUT_RIGHT_TRIGGER",
            name = "Down",
            callback = function() self:ScrollLineDown() end,
        },
        {
            keybind = "UI_SHORTCUT_LEFT_SHOULDER",
            name = "Next Char",
            callback = function() self:CycleViewedCharacter(1) end,
        },
        {
            keybind = "UI_SHORTCUT_RIGHT_SHOULDER",
            name = "Prev Char",
            callback = function() self:CycleViewedCharacter(-1) end,
        },
        {
            keybind = "UI_SHORTCUT_TERTIARY",
            name = "Search",
            callback = function()
                local window = (self.activeView == "detail") and self:GetDetailWindow() or self:GetMainWindow()
                local searchBox = GetChild(window, "SearchBox")
                local edit = searchBox and GetChild(searchBox, "Edit")
                if edit and type(edit.TakeFocus) == "function" then
                    edit:TakeFocus()
                end
            end,
        },
        {
            keybind = "UI_SHORTCUT_RIGHT_STICK",
            name = function()
                if self.activeView == "main" then
                    return "Set Crafter"
                end
                return "Set Crafter"
            end,
            callback = function()
                if self.activeView == "main" then
                    self:SetMasterCrafterToViewedCharacter()
                    return
                end
                self:SetMasterCrafterToViewedCharacter()
            end,
            visible = function() return self.activeView == "main" end,
        },
    }
end

function RT_UI:RegisterDialogs()
    if not ZO_Dialogs_RegisterCustomDialog then
        return
    end
    ZO_Dialogs_RegisterCustomDialog("RT_CONFIRM_SET_CRAFTER_DIALOG", {
        title = { text = "Set Master Crafter?" },
        mainText = {
            text = function()
                local name = RT:GetCharacterDisplayName(self.pendingCrafterCharacterId)
                return string.format("Change master crafter to %s?", tostring(name or "?"))
            end,
        },
        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS and GAMEPAD_DIALOGS.BASIC,
        },
        buttons = {
            [1] = {
                text = "Confirm",
                callback = function()
                    self:ConfirmSetMasterCrafter(self.pendingCrafterCharacterId)
                    self.pendingCrafterCharacterId = nil
                end,
            },
            [2] = {
                text = "Cancel",
                callback = function()
                    self.pendingCrafterCharacterId = nil
                end,
            },
        },
    })
end

function RT_UI:CreateAutoCraftSummaryWindow()
    if self.autoCraftSummaryWindow then
        return
    end

    local win = WINDOW_MANAGER:CreateTopLevelWindow("RT_AutoCraftSummaryWindow")
    win:SetDimensions(760, 220)
    win:SetAnchor(CENTER, GuiRoot, CENTER, 0, -80)
    win:SetDrawLayer(DL_OVERLAY)
    win:SetMouseEnabled(true)
    win:SetMovable(false)
    win:SetHidden(true)
    win:SetClampedToScreen(true)

    local bg = WINDOW_MANAGER:CreateControl(nil, win, CT_BACKDROP)
    bg:SetAnchorFill(win)
    bg:SetCenterColor(0.03, 0.03, 0.03, 0.92)
    bg:SetEdgeColor(0.91, 0.75, 0.36, 0.95)
    bg:SetEdgeTexture("", 1, 1, 2, 0)
    bg:SetInsets(-2, -2, 2, 2)

    local title = WINDOW_MANAGER:CreateControl("RT_AutoCraftSummaryWindowTitle", win, CT_LABEL)
    title:SetAnchor(TOPLEFT, win, TOPLEFT, 18, 16)
    title:SetFont("$(BOLD_FONT)|26|soft-shadow-thick")
    title:SetColor(0.95, 0.82, 0.42, 1)
    title:SetText("Auto-Craft Summary")

    local summary = WINDOW_MANAGER:CreateControl("RT_AutoCraftSummaryWindowSummary", win, CT_LABEL)
    summary:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 16)
    summary:SetDimensions(724, 42)
    summary:SetFont("$(BOLD_FONT)|24|soft-shadow-thin")
    summary:SetColor(1, 1, 1, 1)

    local details = WINDOW_MANAGER:CreateControl("RT_AutoCraftSummaryWindowDetails", win, CT_LABEL)
    details:SetAnchor(TOPLEFT, summary, BOTTOMLEFT, 0, 10)
    details:SetDimensions(724, 84)
    details:SetFont("$(MEDIUM_FONT)|20|soft-shadow-thin")
    details:SetColor(0.86, 0.86, 0.86, 1)

    local hint = WINDOW_MANAGER:CreateControl(nil, win, CT_LABEL)
    hint:SetAnchor(BOTTOMRIGHT, win, BOTTOMRIGHT, -16, -12)
    hint:SetFont("$(MEDIUM_FONT)|18|soft-shadow-thin")
    hint:SetColor(0.75, 0.75, 0.75, 1)
    hint:SetText("Auto-hide in 12s")

    win:SetHandler("OnMouseUp", function()
        win:SetHidden(true)
    end)

    self.autoCraftSummaryWindow = win
end

function RT_UI:ShowAutoCraftSummary(summaryText, detailText)
    if not self.autoCraftSummaryWindow then
        self:CreateAutoCraftSummaryWindow()
    end
    local win = self.autoCraftSummaryWindow
    if not win then
        return
    end

    local summary = _G["RT_AutoCraftSummaryWindowSummary"]
    local details = _G["RT_AutoCraftSummaryWindowDetails"]
    SafeSetText(summary, summaryText or "Auto-craft finished.")
    SafeSetText(details, detailText or "")
    win:SetHidden(false)
    win:BringWindowToTop()

    self.autoCraftSummaryHideAtMs = self:GetNowMs() + 12000
    EVENT_MANAGER:RegisterForUpdate("RT_AutoCraftSummaryAutoHide", 250, function()
        if not self.autoCraftSummaryWindow or self.autoCraftSummaryWindow:IsHidden() then
            EVENT_MANAGER:UnregisterForUpdate("RT_AutoCraftSummaryAutoHide")
            return
        end
        if self:GetNowMs() >= (self.autoCraftSummaryHideAtMs or 0) then
            self.autoCraftSummaryWindow:SetHidden(true)
            EVENT_MANAGER:UnregisterForUpdate("RT_AutoCraftSummaryAutoHide")
        end
    end)
end

function RT_UI:RegisterInTrackingToolsHub()
    if ELDIBABALO_TRACKING_TOOLS and ELDIBABALO_TRACKING_TOOLS.Register then
        ELDIBABALO_TRACKING_TOOLS:Register(
            "Research Tracker",
            "EsoUI/Art/Crafting/smithing_tabicon_research_up.dds",
            self.mainSceneName
        )
        if ELDIBABALO_TRACKING_TOOLS.RefreshList then
            ELDIBABALO_TRACKING_TOOLS:RefreshList()
        end
        self.hubRetryScheduled = false
        return true
    end
    if not self.hubRetryScheduled then
        self.hubRetryScheduled = true
        zo_callLater(function()
            self.hubRetryScheduled = false
            self:RegisterInTrackingToolsHub()
        end, 1500)
    end
    return false
end

function RT_UI:SetupScenes()
    local mainWindow = self:GetMainWindow()
    local detailWindow = self:GetDetailWindow()
    if not mainWindow or not detailWindow then
        return
    end

    self:BuildKeybindStrip()

    local mainScene = ZO_Scene:New(self.mainSceneName, SCENE_MANAGER)
    mainScene:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
    mainScene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD)
    if GAMEPAD_MENU_SOUND_FRAGMENT then
        mainScene:AddFragment(GAMEPAD_MENU_SOUND_FRAGMENT)
    end
    mainScene:AddFragment(ZO_SimpleSceneFragment:New(mainWindow))

    local detailScene = ZO_Scene:New(self.detailSceneName, SCENE_MANAGER)
    detailScene:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
    detailScene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD)
    if GAMEPAD_MENU_SOUND_FRAGMENT then
        detailScene:AddFragment(GAMEPAD_MENU_SOUND_FRAGMENT)
    end
    detailScene:AddFragment(ZO_SimpleSceneFragment:New(detailWindow))

    local function OnSceneStateChange(_, newState)
        if newState == SCENE_SHOWING then
            self.visible = true
            self:RegisterInTrackingToolsHub()
            KEYBIND_STRIP:AddKeybindButtonGroup(self.keybindStripDescriptor)
            KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)
            EVENT_MANAGER:RegisterForUpdate(self.mainSceneName .. "_Joystick", 100, function()
                self:PollJoystickNavigation()
            end)
            local showingMain = SCENE_MANAGER and SCENE_MANAGER:IsShowing(self.mainSceneName)
            if showingMain then
                self:RefreshMainView(false)
            else
                self:RefreshActiveList()
            end
        elseif newState == SCENE_HIDDEN then
            self.visible = false
            pcall(function()
                KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindStripDescriptor)
            end)
            EVENT_MANAGER:UnregisterForUpdate(self.mainSceneName .. "_Joystick")
        end
    end

    mainScene:RegisterCallback("StateChange", OnSceneStateChange)
    detailScene:RegisterCallback("StateChange", OnSceneStateChange)
end

function RT_UI:Initialize()
    if self.initialized then
        return
    end

    local mainWindow = self:GetMainWindow()
    local detailWindow = self:GetDetailWindow()
    if not mainWindow or not detailWindow then
        return
    end

    local mainList = GetChild(mainWindow, "ListArea")
    local detailList = GetChild(detailWindow, "ListArea")
    self.mainRows = self:CreateRowsForList(mainList, "RT_Main")
    self.detailRows = self:CreateRowsForList(detailList, "RT_Detail")

    local function SetupSearch(window)
        local searchBox = GetChild(window, "SearchBox")
        local edit = searchBox and GetChild(searchBox, "Edit")
        if not edit then
            return
        end
        if type(edit.SetDefaultText) == "function" then
            edit:SetDefaultText("Search...")
        end
        edit:SetHandler("OnTextChanged", function(ctrl)
            self.searchText = ctrl:GetText() or ""
            self:ApplySearchFilter()
            self:RefreshActiveList()
        end)
        edit:SetHandler("OnEscape", function(ctrl)
            ctrl:SetText("")
            self.searchText = ""
            self:ApplySearchFilter()
            self:RefreshActiveList()
            if type(ctrl.LoseFocus) == "function" then
                ctrl:LoseFocus()
            end
        end)
    end

    SetupSearch(mainWindow)
    SetupSearch(detailWindow)

    self:CreateAutoCraftSummaryWindow()
    self:RegisterDialogs()
    self:SetupScenes()
    self:RegisterInTrackingToolsHub()
    zo_callLater(function() self:RegisterInTrackingToolsHub() end, 1200)
    zo_callLater(function() self:RegisterInTrackingToolsHub() end, 3000)
    self.initialized = true
end

function RT_UI:Show()
    if not self.initialized then
        self:Initialize()
    end
    self:RegisterInTrackingToolsHub()
    self:OpenMain()
end

function RT_UI:Toggle()
    if SCENE_MANAGER and SCENE_MANAGER:IsShowing(self.mainSceneName) then
        SCENE_MANAGER:HideCurrentScene()
    elseif SCENE_MANAGER and SCENE_MANAGER:IsShowing(self.detailSceneName) then
        SCENE_MANAGER:HideCurrentScene()
    else
        self:Show()
    end
end

