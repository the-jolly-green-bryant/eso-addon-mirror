-- =============================================================================
-- Antiquity Tracker — UI Logic v2.3.0
-- Single flat list with row pool, manual scroll offset, scene-based gamepad UI.
-- Architecture modelled on GuildActivityTracker by Eldibabalo.
-- =============================================================================

AT_UI = {}

-- ---------------------------------------------------------------------------
-- Layout constants
-- ---------------------------------------------------------------------------
local MAX_VISIBLE_ROWS = 20
local ROW_HEIGHT       = 28

-- ---------------------------------------------------------------------------
-- Fonts
-- ---------------------------------------------------------------------------
local FONT_ROW_NAME    = "$(MEDIUM_FONT)|24|soft-shadow-thin"
local FONT_ROW_VALUE   = "$(MEDIUM_FONT)|24|soft-shadow-thin"
local FONT_BTN_LABEL   = "$(BOLD_FONT)|22|soft-shadow-thick"
local FONT_FILTER      = "$(MEDIUM_FONT)|22|soft-shadow-thin"
local FONT_SCROLL_BTN  = "$(BOLD_FONT)|28|soft-shadow-thick"

-- ---------------------------------------------------------------------------
-- Colour helpers
-- ---------------------------------------------------------------------------
local COL_GOLD   = "|cE8C05C"
local COL_GREEN  = "|c2DC50E"
local COL_BLUE   = "|c3A92FF"
local COL_PURPLE = "|cA02EF7"
local COL_YELLOW = "|cEECA2A"
local COL_GRAY   = "|c888888"
local COL_WHITE  = "|cFFFFFF"
local COL_RED    = "|cE53935"
local COL_RESET  = "|r"

-- ---------------------------------------------------------------------------
-- State
-- ---------------------------------------------------------------------------
AT_UI.visible        = false
AT_UI.scrollOffset   = 0
AT_UI.selectedRow    = 1
AT_UI.rowPool        = {}
AT_UI.initialized    = false
AT_UI.listParent     = nil
AT_UI.sceneName      = "atScene"
AT_UI.menuAdded      = false
AT_UI.searchBox      = nil
AT_UI.pageMode       = false
AT_UI.previewVisible = false
AT_UI.previewPanel   = nil
AT_UI.perf           = { enabled = false, counters = {}, max = {} }
AT_UI.lastSearchSignature = nil
AT_UI._listDirty = true

-- ═══════════════════════════════════════════════════════════════════════════
-- CONTROL LOOKUP
-- ═══════════════════════════════════════════════════════════════════════════

local function GetChild(name)
    if not AT_Window then return nil end
    return AT_Window:GetNamedChild(name)
end

function AT_UI:PerfCount(key, delta)
    if not self.perf or not self.perf.enabled then return end
    self.perf.counters[key] = (self.perf.counters[key] or 0) + (delta or 1)
end

function AT_UI:PerfMax(key, value)
    if not self.perf or not self.perf.enabled then return end
    local current = self.perf.max[key]
    if current == nil or value > current then
        self.perf.max[key] = value
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- ROW POOL
-- ═══════════════════════════════════════════════════════════════════════════

local function MakeLabel(name, parent, font, xOffset, width, align)
    local label = WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL)
    label:SetFont(font)
    label:SetColor(1, 1, 1, 1)
    label:SetAnchor(LEFT, parent, LEFT, xOffset, 0)
    label:SetDimensions(width, ROW_HEIGHT)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetHorizontalAlignment(align or TEXT_ALIGN_LEFT)
    label:SetMouseEnabled(false)
    return label
end

function AT_UI:CreateRowPool()
    self.listParent = GetChild("ListArea")
    if not self.listParent and AT_Window then
        self.listParent = WINDOW_MANAGER:CreateControl(
            "AT_ListAreaFallback", AT_Window, CT_CONTROL)
        self.listParent:SetAnchor(TOPLEFT, AT_Window, TOPLEFT, 20, 128)
        self.listParent:SetDimensions(1160, MAX_VISIBLE_ROWS * ROW_HEIGHT)
    end
    if not self.listParent then return end

    local pw = self.listParent:GetWidth()
    if pw <= 0 then pw = 1160 end
    self.rowPool = {}

    for i = 1, MAX_VISIBLE_ROWS do
        local yOff   = (i - 1) * ROW_HEIGHT
        local prefix = "AT_Slot" .. i
        local row = WINDOW_MANAGER:CreateControl(prefix, self.listParent, CT_CONTROL)
        row:SetDimensions(pw, ROW_HEIGHT)
        row:SetAnchor(TOPLEFT, self.listParent, TOPLEFT, 0, yOff)
        row:SetMouseEnabled(true)

        local highlight = WINDOW_MANAGER:CreateControl(prefix .. "HL", row, CT_TEXTURE)
        highlight:SetColor(0.91, 0.75, 0.36, 0.08)
        highlight:SetAnchorFill()
        highlight:SetHidden(true)
        highlight:SetMouseEnabled(false)

        local selectHL = WINDOW_MANAGER:CreateControl(prefix .. "SHL", row, CT_TEXTURE)
        selectHL:SetColor(0.91, 0.75, 0.36, 0.22)
        selectHL:SetAnchorFill()
        selectHL:SetHidden(true)
        selectHL:SetMouseEnabled(false)

        row:SetHandler("OnMouseEnter", function() highlight:SetHidden(false) end)
        row:SetHandler("OnMouseExit",  function() highlight:SetHidden(true) end)

        local rowIndex = i
        row:SetHandler("OnMouseUp", function(_, button)
            if button == MOUSE_BUTTON_INDEX_LEFT then
                AT_UI:OnRowClicked(rowIndex)
            end
        end)

        local iconTex     = WINDOW_MANAGER:CreateControl(prefix .. "IC", row, CT_TEXTURE)
        iconTex:SetDimensions(24, 24)
        iconTex:SetAnchor(LEFT, row, LEFT, 8, 0)
        iconTex:SetMouseEnabled(false)

        local nameLabel   = MakeLabel(prefix .. "N",  row, FONT_ROW_NAME,  40,  220)
        local zoneLabel   = MakeLabel(prefix .. "Z",  row, FONT_ROW_VALUE, 266, 170)
        local diffLabel   = MakeLabel(prefix .. "D",  row, FONT_ROW_VALUE, 442, 50,  TEXT_ALIGN_CENTER)
        local statusLabel = MakeLabel(prefix .. "S",  row, FONT_ROW_VALUE, 498, 124, TEXT_ALIGN_CENTER)
        local timeLabel   = MakeLabel(prefix .. "T",  row, FONT_ROW_VALUE, 628, 100, TEXT_ALIGN_RIGHT)
        local mythicLabel = MakeLabel(prefix .. "M",  row, FONT_ROW_VALUE, 734, 220)

        self.rowPool[i] = {
            control     = row,
            highlight   = highlight,
            selectHL    = selectHL,
            iconTex     = iconTex,
            nameLabel   = nameLabel,
            zoneLabel   = zoneLabel,
            diffLabel   = diffLabel,
            statusLabel = statusLabel,
            timeLabel   = timeLabel,
            mythicLabel = mythicLabel,
        }
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- SCROLL CONTROLS
-- ═══════════════════════════════════════════════════════════════════════════

function AT_UI:SetupScrollControls()
    local listArea = GetChild("ListArea")
    if listArea then
        listArea:SetHandler("OnMouseWheel", function(_, delta)
            if delta > 0 then
                AT_UI:ScrollLineUp()
            else
                AT_UI:ScrollLineDown()
            end
        end)
    end

    local upBtn = GetChild("ScrollUpBtn")
    if upBtn then
        upBtn:SetHandler("OnClicked", function() AT_UI:ScrollLineUp() end)
        local upLabel = WINDOW_MANAGER:CreateControl("AT_ScrollUpLabel", upBtn, CT_LABEL)
        upLabel:SetFont(FONT_SCROLL_BTN)
        upLabel:SetText(COL_GOLD .. "^" .. COL_RESET)
        upLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        upLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        upLabel:SetAnchorFill()
        upLabel:SetMouseEnabled(false)
    end

    local downBtn = GetChild("ScrollDownBtn")
    if downBtn then
        downBtn:SetHandler("OnClicked", function() AT_UI:ScrollLineDown() end)
        local downLabel = WINDOW_MANAGER:CreateControl("AT_ScrollDownLabel", downBtn, CT_LABEL)
        downLabel:SetFont(FONT_SCROLL_BTN)
        downLabel:SetText(COL_GOLD .. "v" .. COL_RESET)
        downLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        downLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        downLabel:SetAnchorFill()
        downLabel:SetMouseEnabled(false)
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- ACTION BUTTONS (Filter)
-- ═══════════════════════════════════════════════════════════════════════════

function AT_UI:SetupActionButtons()
    local filterBtn = GetChild("FilterBtn")
    if filterBtn then
        filterBtn:SetHandler("OnClicked", function()
            AT:CycleFilter()
            self.scrollOffset = 0  self.selectedRow = 1
            self:RefreshAll()
        end)
        self.filterBtnLabel = WINDOW_MANAGER:CreateControl("AT_FilterBtnLabel", filterBtn, CT_LABEL)
        self.filterBtnLabel:SetFont(FONT_FILTER)
        self.filterBtnLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        self.filterBtnLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        self.filterBtnLabel:SetAnchorFill()
        self.filterBtnLabel:SetMouseEnabled(false)
    end
end

function AT_UI:RefreshActionButtons()
    if self.filterBtnLabel then
        self.filterBtnLabel:SetText(COL_WHITE .. AT:GetCurrentFilterLabel() .. COL_RESET)
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- SEARCH BOX
-- ═══════════════════════════════════════════════════════════════════════════

local SEARCH_POLL_NAME = "AntiquityTracker_SearchPoll"

function AT_UI:ApplySearch()
    local signature = table.concat({
        tostring(AT.searchText or ""),
        tostring(AT.filterIndex or 0),
    }, "|")
    if signature == self.lastSearchSignature then
        return
    end
    self.lastSearchSignature = signature
    self:PerfCount("search_apply_calls", 1)

    self.scrollOffset = 0  self.selectedRow = 1
    AT:FilterAndSort()
    self:PerfCount("filter_sort_calls", 1)
    self:PerfMax("filtered_count", #AT.filteredList)
    self._listDirty = true
    self:RefreshList()
    self:UpdateFooter()
end

function AT_UI:StartSearchPoll()
    local pollCount = 0
    EVENT_MANAGER:UnregisterForUpdate(SEARCH_POLL_NAME)
    EVENT_MANAGER:RegisterForUpdate(SEARCH_POLL_NAME, 250, function()
        pollCount = pollCount + 1
        if pollCount > 60 then
            EVENT_MANAGER:UnregisterForUpdate(SEARCH_POLL_NAME)
            return
        end
        if self.searchBox then
            local text = self.searchBox:GetText() or ""
            if text ~= (AT.searchText or "") then
                AT.searchText = text
                self:ApplySearch()
            end
        end
    end)
end

function AT_UI:StopSearchPoll()
    EVENT_MANAGER:UnregisterForUpdate(SEARCH_POLL_NAME)
end

function AT_UI:SetupSearchBox()
    local searchBoxCtrl = GetChild("SearchBox")
    if not searchBoxCtrl then return end

    local editBox = searchBoxCtrl:GetNamedChild("Edit")
    if not editBox then return end

    self.searchBox = editBox
    editBox:SetMouseEnabled(true)
    editBox:SetMaxInputChars(100)
    editBox:SetDefaultText("Search...")

    editBox:SetHandler("OnTextChanged", function(ctrl)
        local text = ctrl:GetText() or ""
        AT.searchText = text
        AT_UI:ApplySearch()
    end)

    editBox:SetHandler("OnEnter", function(ctrl)
        local text = ctrl:GetText() or ""
        AT.searchText = text
        ctrl:LoseFocus()
        AT_UI:ApplySearch()
    end)

    editBox:SetHandler("OnFocusLost", function(ctrl)
        AT_UI:StopSearchPoll()
        local text = ctrl:GetText() or ""
        AT.searchText = text
        AT_UI:ApplySearch()
    end)

    editBox:SetHandler("OnEscape", function(ctrl)
        ctrl:SetText("")
        AT.searchText = ""
        ctrl:LoseFocus()
        AT_UI:ApplySearch()
    end)
end

function AT_UI:ClearSearch()
    if self.searchBox then
        self.searchBox:SetText("")
        self.searchBox:LoseFocus()
    end
    AT.searchText = ""
end

-- ═══════════════════════════════════════════════════════════════════════════
-- PREVIEW PANEL (detail popup for a single antiquity)
-- ═══════════════════════════════════════════════════════════════════════════

function AT_UI:CreatePreviewPanel()
    if not AT_Window then return end

    local panel = WINDOW_MANAGER:CreateControl("AT_PreviewOverlay", AT_Window, CT_CONTROL)
    panel:SetAnchorFill()
    panel:SetHidden(true)
    panel:SetMouseEnabled(true)
    panel:SetDrawLevel(100)

    panel:SetHandler("OnMouseUp", function()
        AT_UI:HidePreview()
    end)

    local bg = WINDOW_MANAGER:CreateControl("AT_PreviewBG", panel, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0, 0, 0, 0.92)
    bg:SetEdgeColor(0, 0, 0, 0)
    bg:SetMouseEnabled(false)

    local box = WINDOW_MANAGER:CreateControl("AT_PreviewBox", panel, CT_CONTROL)
    box:SetDimensions(1000, 380)
    box:SetAnchor(CENTER, panel, CENTER, 0, 0)
    box:SetMouseEnabled(true)

    local boxBg = WINDOW_MANAGER:CreateControl("AT_PreviewBoxBG", box, CT_BACKDROP)
    boxBg:SetAnchorFill()
    boxBg:SetCenterColor(0.08, 0.08, 0.08, 1)
    boxBg:SetEdgeColor(0, 0, 0, 0)
    boxBg:SetMouseEnabled(false)

    local border = WINDOW_MANAGER:CreateControl("AT_PreviewBorder", box, CT_BACKDROP)
    border:SetAnchorFill()
    border:SetCenterColor(0, 0, 0, 0)
    border:SetEdgeColor(0.91, 0.75, 0.36, 1)
    border:SetEdgeTexture("", 2, 2, 2, 0)

    local iconTex = WINDOW_MANAGER:CreateControl("AT_PreviewIcon", box, CT_TEXTURE)
    iconTex:SetDimensions(48, 48)
    iconTex:SetAnchor(TOPLEFT, box, TOPLEFT, 24, 16)
    iconTex:SetMouseEnabled(false)

    local titleLbl = WINDOW_MANAGER:CreateControl("AT_PreviewTitle", box, CT_LABEL)
    titleLbl:SetFont("$(BOLD_FONT)|28|soft-shadow-thick")
    titleLbl:SetAnchor(TOPLEFT, iconTex, TOPRIGHT, 12, 0)
    titleLbl:SetDimensions(880, 32)
    titleLbl:SetColor(1, 1, 1, 1)
    titleLbl:SetMouseEnabled(false)

    local zoneLbl = WINDOW_MANAGER:CreateControl("AT_PreviewZone", box, CT_LABEL)
    zoneLbl:SetFont("$(MEDIUM_FONT)|22|soft-shadow-thin")
    zoneLbl:SetAnchor(BOTTOMLEFT, iconTex, BOTTOMRIGHT, 12, 0)
    zoneLbl:SetDimensions(880, 24)
    zoneLbl:SetColor(0.53, 0.53, 0.53, 1)
    zoneLbl:SetMouseEnabled(false)

    local detailLbl = WINDOW_MANAGER:CreateControl("AT_PreviewDetail", box, CT_LABEL)
    detailLbl:SetFont("$(MEDIUM_FONT)|24|soft-shadow-thin")
    detailLbl:SetAnchor(TOPLEFT, box, TOPLEFT, 24, 80)
    detailLbl:SetDimensions(952, 240)
    detailLbl:SetColor(1, 1, 1, 1)
    detailLbl:SetMouseEnabled(false)

    local hintIcon = WINDOW_MANAGER:CreateControl("AT_PreviewHintIcon", box, CT_TEXTURE)
    hintIcon:SetDimensions(32, 32)
    hintIcon:SetAnchor(BOTTOM, box, BOTTOM, -30, -12)
    hintIcon:SetMouseEnabled(false)
    pcall(function()
        hintIcon:SetTexture("EsoUI/Art/Buttons/Gamepad/gp_circleButton.dds")
    end)

    local hintLbl = WINDOW_MANAGER:CreateControl("AT_PreviewHint", box, CT_LABEL)
    hintLbl:SetFont("$(BOLD_FONT)|22|soft-shadow-thick")
    hintLbl:SetAnchor(LEFT, hintIcon, RIGHT, 6, 0)
    hintLbl:SetDimensions(120, 32)
    hintLbl:SetColor(1, 1, 1, 1)
    hintLbl:SetText("Close")
    hintLbl:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    hintLbl:SetMouseEnabled(false)

    self.previewPanel      = panel
    self.previewIcon       = iconTex
    self.previewTitle      = titleLbl
    self.previewZone       = zoneLbl
    self.previewDetail     = detailLbl
end

function AT_UI:ShowPreview(entry)
    if not self.previewPanel then return end

    local qh = AT.QualityHex(entry.quality)
    self.previewTitle:SetText("|c" .. qh .. entry.name .. COL_RESET)
    self.previewZone:SetText(entry.zoneName or "")

    if entry.icon and entry.icon ~= "" then
        pcall(function() self.previewIcon:SetTexture(entry.icon) end)
        self.previewIcon:SetHidden(false)
    else
        self.previewIcon:SetHidden(true)
    end

    local lines = {}
    table.insert(lines, "Difficulty: " .. (AT.difficultyStars[math.min(entry.difficulty or 1, 5)] or "*"))

    if entry.setName then
        table.insert(lines, COL_YELLOW .. "Set: " .. entry.setName .. COL_RESET)
    end

    if entry.recovered > 0 then
        table.insert(lines, COL_GREEN .. "Recovered: " .. entry.recovered .. " time(s)" .. COL_RESET)
    elseif entry.hasLead then
        local lt = AT.FormatLeadTime(entry.leadTimeS)
        if lt ~= "" then
            table.insert(lines, COL_BLUE .. "Lead Active — " .. COL_RED .. lt .. " remaining" .. COL_RESET)
        else
            table.insert(lines, COL_BLUE .. "Lead Active (no timer)" .. COL_RESET)
        end
    elseif entry.requiresLead then
        table.insert(lines, COL_GRAY .. "No Lead — requires lead to dig" .. COL_RESET)
    else
        table.insert(lines, COL_GRAY .. "Available (no lead required)" .. COL_RESET)
    end

    if entry.numLore and entry.numLore > 0 then
        table.insert(lines, "Lore: " .. (entry.loreDone or 0) .. "/" .. entry.numLore)
    end

    if entry.repeatable then
        table.insert(lines, COL_GOLD .. "Repeatable" .. COL_RESET)
    end

    if entry.leadHint and entry.leadHint ~= "" then
        table.insert(lines, "")
        table.insert(lines, COL_YELLOW .. "Lead Source: " .. COL_WHITE .. entry.leadHint .. COL_RESET)
    end

    self.previewDetail:SetText(table.concat(lines, "\n"))

    for _, slot in ipairs(self.rowPool) do
        slot.control:SetHidden(true)
    end
    if self.listParent then self.listParent:SetHidden(true) end
    self.previewPanel:SetHidden(false)
    self.previewVisible = true
end

function AT_UI:HidePreview()
    if self.previewPanel then
        self.previewPanel:SetHidden(true)
    end
    if self.listParent then self.listParent:SetHidden(false) end
    self.previewVisible = false
    self:RefreshList()
end

-- ═══════════════════════════════════════════════════════════════════════════
-- ROW CLICK
-- ═══════════════════════════════════════════════════════════════════════════

function AT_UI:OnRowClicked(rowIndex)
    if self.previewVisible then
        self:HidePreview()
        return
    end

    local dataIndex = self.scrollOffset + rowIndex
    local entry = AT.filteredList[dataIndex]
    if entry then
        self:ShowPreview(entry)
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- KEYBIND STRIP
-- ═══════════════════════════════════════════════════════════════════════════

function AT_UI:BuildKeybindStrip()
    self.keybindStripDescriptor = {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        {
            keybind  = "UI_SHORTCUT_NEGATIVE",
            name     = GetString(SI_GAMEPAD_BACK_OPTION),
            callback = function()
                if self.previewVisible then
                    self:HidePreview()
                else
                    SCENE_MANAGER:HideCurrentScene()
                end
            end,
            sound = SOUNDS.GAMEPAD_MENU_BACK,
        },
        {
            keybind  = "UI_SHORTCUT_PRIMARY",
            name     = "Select",
            callback = function()
                if self.previewVisible then
                    self:HidePreview()
                    return
                end
                AT_UI:OnRowClicked(self.selectedRow)
            end,
        },
        {
            keybind  = "UI_SHORTCUT_LEFT_TRIGGER",
            name     = function() return self.pageMode and "Page Up" or "Up" end,
            callback = function()
                if self.previewVisible then return end
                if self.pageMode then
                    AT_UI:MoveCursor(-MAX_VISIBLE_ROWS)
                else
                    AT_UI:MoveCursor(-1)
                end
            end,
        },
        {
            keybind  = "UI_SHORTCUT_RIGHT_TRIGGER",
            name     = function() return self.pageMode and "Page Down" or "Down" end,
            callback = function()
                if self.previewVisible then return end
                if self.pageMode then
                    AT_UI:MoveCursor(MAX_VISIBLE_ROWS)
                else
                    AT_UI:MoveCursor(1)
                end
            end,
        },
        {
            keybind  = "UI_SHORTCUT_LEFT_STICK",
            name     = function() return self.pageMode and "Line Mode" or "Page Mode" end,
            callback = function()
                if self.previewVisible then return end
                self.pageMode = not self.pageMode
                self:RefreshKeybindStrip()
            end,
        },
        {
            keybind  = "UI_SHORTCUT_SECONDARY",
            name     = "Refresh",
            callback = function()
                if self.previewVisible then return end
                AT:EnsureDataFresh(true)
                self.scrollOffset = 0  self.selectedRow = 1
                self:RefreshAll()
            end,
        },
        {
            keybind  = "UI_SHORTCUT_TERTIARY",
            name     = "Search",
            callback = function()
                if self.previewVisible then return end
                if self.searchBox then
                    self.searchBox:TakeFocus()
                    self:StartSearchPoll()
                end
            end,
        },
        {
            keybind  = "UI_SHORTCUT_RIGHT_STICK",
            name     = "Next Filter",
            callback = function()
                if self.previewVisible then return end
                if self.searchBox then self.searchBox:SetText("") end
                AT:CycleFilter()
                self.scrollOffset = 0  self.selectedRow = 1
                self:RefreshAll()
            end,
        },
    }
end

function AT_UI:RefreshKeybindStrip()
    if self.visible and self.keybindStripDescriptor then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)
    end
end

function AT_UI:GetNowMs()
    return (type(GetFrameTimeMilliseconds) == "function" and GetFrameTimeMilliseconds())
        or (type(GetGameTimeMilliseconds) == "function" and GetGameTimeMilliseconds())
        or 0
end

function AT_UI:GetRawLeftStickY()
    local readers = {
        _G["GetGamepadLeftStickY"],
        _G["GetGamepadOrKeyboardLeftStickY"],
        _G["GetGamepadLeftStickDeltaY"],
    }
    for _, reader in ipairs(readers) do
        if type(reader) == "function" then
            local ok, value = pcall(reader)
            if ok and type(value) == "number" then
                return value
            end
        end
    end
    return nil
end

function AT_UI:PollJoystickNavigation()
    if not self.visible or self.previewVisible then
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
    local step = self.pageMode and MAX_VISIBLE_ROWS or 1
    local changedDirection = self.lastJoystickDirection ~= direction
    if changedDirection or not self.lastJoystickMoveMs or (nowMs - self.lastJoystickMoveMs) >= repeatMs then
        self:MoveCursor(direction * step)
        self.lastJoystickMoveMs = nowMs
        self.lastJoystickDirection = direction
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- SCENE SETUP
-- ═══════════════════════════════════════════════════════════════════════════

function AT_UI:SetupScene()
    if not AT_Window then return end

    local windowFragment = ZO_SimpleSceneFragment:New(AT_Window)
    local scene = ZO_Scene:New(self.sceneName, SCENE_MANAGER)

    scene:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
    scene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD)

    if GAMEPAD_MENU_SOUND_FRAGMENT then
        scene:AddFragment(GAMEPAD_MENU_SOUND_FRAGMENT)
    end

    scene:AddFragment(windowFragment)

    self:BuildKeybindStrip()

    scene:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_SHOWING then
            self:EnsureUICreated()
            AT:EnsureDataFresh(false)
            self.scrollOffset = 0  self.selectedRow = 1
            self.visible      = true

            KEYBIND_STRIP:AddKeybindButtonGroup(self.keybindStripDescriptor)
            EVENT_MANAGER:RegisterForUpdate("AT_JoystickNavPoll", 100, function()
                self:PollJoystickNavigation()
            end)

            self:RefreshAll()
            self:UpdateWatermark()

        elseif newState == SCENE_HIDDEN then
            self.visible = false
            self:HidePreview()
            self:StopSearchPoll()
            self:ClearSearch()

            if AT.savedVars then
                AT.savedVars.filterIndex = AT.filterIndex
            end

            pcall(function()
                KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindStripDescriptor)
            end)
            EVENT_MANAGER:UnregisterForUpdate("AT_JoystickNavPoll")
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- TRACKING TOOLS HUB (shared across all Eldibabalo addons, created once)
-- ═══════════════════════════════════════════════════════════════════════════

local function EnsureTrackingToolsHub()
    if ELDIBABALO_TRACKING_TOOLS then return true end

    local ok = pcall(function()
        local TT = { entries = {}, sceneName = "eldibabaloTrackingToolsScene", selectedRow = 1, rows = {} }

        local ROW_H, MAX_ROWS = 60, 10
        local win = WINDOW_MANAGER:CreateTopLevelWindow("TT_HubWindow")
        win:SetDimensions(1200, 800)
        win:SetAnchor(CENTER)
        win:SetHidden(true)
        win:SetMouseEnabled(true)
        win:SetMovable(true)
        win:SetClampedToScreen(true)

        local bg = WINDOW_MANAGER:CreateControl("TT_HubBG", win, CT_TEXTURE)
        bg:SetAnchorFill()
        bg:SetColor(0.05, 0.05, 0.05, 0.97)

        local bdr = WINDOW_MANAGER:CreateControl("TT_HubBorder", win, CT_BACKDROP)
        bdr:SetAnchorFill()
        bdr:SetCenterColor(0, 0, 0, 0)
        bdr:SetEdgeColor(0.91, 0.75, 0.36, 1)
        bdr:SetEdgeTexture("", 2, 2, 2, 0)

        local ttl = WINDOW_MANAGER:CreateControl("TT_HubTitle", win, CT_LABEL)
        ttl:SetFont("$(BOLD_FONT)|36|soft-shadow-thick")
        ttl:SetColor(0.91, 0.75, 0.36, 1)
        ttl:SetAnchor(TOP, win, TOP, 0, 30)
        ttl:SetDimensions(800, 40)
        ttl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        ttl:SetText("Tracking Tools")

        local sep = WINDOW_MANAGER:CreateControl("TT_HubSep", win, CT_TEXTURE)
        sep:SetColor(0.91, 0.75, 0.36, 0.4)
        sep:SetAnchor(TOPLEFT, win, TOPLEFT, 20, 80)
        sep:SetDimensions(1160, 1)

        for i = 1, MAX_ROWS do
            local yOff = 100 + (i - 1) * ROW_H
            local pf = "TT_HubRow" .. i
            local row = WINDOW_MANAGER:CreateControl(pf, win, CT_CONTROL)
            row:SetDimensions(1160, ROW_H)
            row:SetAnchor(TOPLEFT, win, TOPLEFT, 20, yOff)
            row:SetMouseEnabled(true)

            local hl = WINDOW_MANAGER:CreateControl(pf .. "HL", row, CT_TEXTURE)
            hl:SetColor(0.91, 0.75, 0.36, 0.08); hl:SetAnchorFill(); hl:SetHidden(true)

            local selHL = WINDOW_MANAGER:CreateControl(pf .. "SHL", row, CT_TEXTURE)
            selHL:SetColor(0.91, 0.75, 0.36, 0.22); selHL:SetAnchorFill(); selHL:SetHidden(true)

            row:SetHandler("OnMouseEnter", function() hl:SetHidden(false) end)
            row:SetHandler("OnMouseExit", function() hl:SetHidden(true) end)
            local idx = i
            row:SetHandler("OnMouseUp", function(_, button)
                if button == MOUSE_BUTTON_INDEX_LEFT then TT.selectedRow = idx; TT:OpenSelected() end
            end)

            local ic = WINDOW_MANAGER:CreateControl(pf .. "IC", row, CT_TEXTURE)
            ic:SetDimensions(40, 40); ic:SetAnchor(LEFT, row, LEFT, 20, 0)

            local lb = WINDOW_MANAGER:CreateControl(pf .. "LB", row, CT_LABEL)
            lb:SetFont("$(BOLD_FONT)|28|soft-shadow-thin"); lb:SetColor(1, 1, 1, 1)
            lb:SetAnchor(LEFT, ic, RIGHT, 16, 0); lb:SetDimensions(900, ROW_H)
            lb:SetVerticalAlignment(TEXT_ALIGN_CENTER)

            TT.rows[i] = { control = row, highlight = hl, selectHL = selHL, icon = ic, label = lb }
        end

        function TT:Register(name, iconPath, scene)
            for _, e in ipairs(self.entries) do if e.scene == scene then return end end
            table.insert(self.entries, { name = name, icon = iconPath, scene = scene })
        end

        function TT:RefreshList()
            for i = 1, MAX_ROWS do
                local slot, entry = self.rows[i], self.entries[i]
                slot.selectHL:SetHidden(i ~= self.selectedRow)
                if entry then
                    slot.control:SetHidden(false)
                    local iconPath = entry.icon
                    if type(iconPath) ~= "string" or iconPath == "" then
                        iconPath = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_settings.dds"
                    end
                    pcall(function() slot.icon:SetTexture(iconPath) end)
                    slot.label:SetText(entry.name)
                else
                    slot.control:SetHidden(true); slot.selectHL:SetHidden(true)
                end
            end
        end

        function TT:OpenSelected()
            local entry = self.entries[self.selectedRow]
            if entry and entry.scene then SCENE_MANAGER:Show(entry.scene) end
        end

        local function TT_GetRawLeftStickY()
            local readers = {
                _G["GetGamepadLeftStickY"],
                _G["GetGamepadOrKeyboardLeftStickY"],
                _G["GetGamepadLeftStickDeltaY"],
            }
            for _, reader in ipairs(readers) do
                if type(reader) == "function" then
                    local ok, value = pcall(reader)
                    if ok and type(value) == "number" then
                        return value
                    end
                end
            end
            return nil
        end

        function TT:PollRawStickNavigation()
            local y = TT_GetRawLeftStickY()
            local direction = 0
            if type(y) == "number" then
                if y >= 0.35 then
                    direction = -1
                elseif y <= -0.35 then
                    direction = 1
                end
            end
            if direction == 0 then
                self.lastStickDirection = 0
                return
            end

            local nowMs = (type(GetFrameTimeMilliseconds) == "function" and GetFrameTimeMilliseconds())
                or (type(GetGameTimeMilliseconds) == "function" and GetGameTimeMilliseconds())
                or 0
            local repeatMs = 100
            local changedDirection = self.lastStickDirection ~= direction
            if changedDirection or not self.lastStickMoveMs or (nowMs - self.lastStickMoveMs) >= repeatMs then
                local newRow = zo_clamp((self.selectedRow or 1) + direction, 1, #self.entries)
                if newRow ~= self.selectedRow then
                    self.selectedRow = newRow
                    self:RefreshList()
                end
                self.lastStickMoveMs = nowMs
                self.lastStickDirection = direction
            end
        end

        local wf = ZO_SimpleSceneFragment:New(win)
        local sc = ZO_Scene:New(TT.sceneName, SCENE_MANAGER)
        sc:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
        sc:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD)
        if GAMEPAD_MENU_SOUND_FRAGMENT then sc:AddFragment(GAMEPAD_MENU_SOUND_FRAGMENT) end
        sc:AddFragment(wf)

        local kb = {
            alignment = KEYBIND_STRIP_ALIGN_LEFT,
            { keybind = "UI_SHORTCUT_NEGATIVE", name = GetString(SI_GAMEPAD_BACK_OPTION),
              callback = function() SCENE_MANAGER:HideCurrentScene() end, sound = SOUNDS.GAMEPAD_MENU_BACK },
            { keybind = "UI_SHORTCUT_PRIMARY", name = "Open",
              callback = function() TT:OpenSelected() end },
            { keybind = "UI_SHORTCUT_LEFT_TRIGGER", name = "Up",
              callback = function() if TT.selectedRow > 1 then TT.selectedRow = TT.selectedRow - 1; TT:RefreshList() end end },
            { keybind = "UI_SHORTCUT_RIGHT_TRIGGER", name = "Down",
              callback = function() if TT.selectedRow < #TT.entries then TT.selectedRow = TT.selectedRow + 1; TT:RefreshList() end end },
        }

        sc:RegisterCallback("StateChange", function(_, newState)
            if newState == SCENE_SHOWING then
                TT.selectedRow = 1; TT:RefreshList(); KEYBIND_STRIP:AddKeybindButtonGroup(kb)
                EVENT_MANAGER:RegisterForUpdate("TT_HubStickNavPoll", 100, function()
                    TT:PollRawStickNavigation()
                end)
            elseif newState == SCENE_HIDDEN then
                pcall(function() KEYBIND_STRIP:RemoveKeybindButtonGroup(kb) end)
                EVENT_MANAGER:UnregisterForUpdate("TT_HubStickNavPoll")
            end
        end)

        local hubData = { name = "Tracking Tools", icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_settings.dds", scene = TT.sceneName }
        local hubEntry = ZO_GamepadEntryData:New(hubData.name, hubData.icon)
        hubEntry:SetIconTintOnSelection(true)
        hubEntry:SetIconDisabledTintOnSelection(true)
        hubEntry.data = hubData
        hubEntry.id   = 950

        local insertPos = nil
        pcall(function()
            if ZO_MENU_MAIN_ENTRIES and ZO_MENU_MAIN_ENTRIES.JOURNAL then
                for ix, v in ipairs(ZO_MENU_ENTRIES) do
                    if v.id == ZO_MENU_MAIN_ENTRIES.JOURNAL then
                        insertPos = ix + 3
                        break
                    end
                end
            end
        end)
        if insertPos and insertPos >= 1 and insertPos <= #ZO_MENU_ENTRIES + 1 then
            table.insert(ZO_MENU_ENTRIES, insertPos, hubEntry)
        else
            table.insert(ZO_MENU_ENTRIES, hubEntry)
        end

        if MAIN_MENU_GAMEPAD then
            MAIN_MENU_GAMEPAD:RefreshLists()
            MAIN_MENU_GAMEPAD:UpdateEntryEnabledStates()
        end

        ELDIBABALO_TRACKING_TOOLS = TT
    end)

    return ok and ELDIBABALO_TRACKING_TOOLS ~= nil
end

-- ═══════════════════════════════════════════════════════════════════════════
-- MENU INTEGRATION (Tracking Tools hub, with fallback)
-- ═══════════════════════════════════════════════════════════════════════════

function AT_UI:AddToMainMenu()
    if self.menuAdded then return end

    local success = pcall(function()
        if not ZO_MENU_ENTRIES then return end

        local hubOk = EnsureTrackingToolsHub()

        if hubOk and ELDIBABALO_TRACKING_TOOLS then
            ELDIBABALO_TRACKING_TOOLS:Register("Antiquity Tracker",
                "EsoUI/Art/TreeIcons/Gamepad/gp_tutorial_idexIcon_guilds.dds", self.sceneName)
            local gatScene = SCENE_MANAGER and SCENE_MANAGER:GetScene("gatScene")
            if gatScene then
                ELDIBABALO_TRACKING_TOOLS:Register("Guild Activity Tracker",
                    "EsoUI/Art/TreeIcons/Gamepad/gp_tutorial_idexIcon_guilds.dds", "gatScene")
            end
        else
            local menuData = { name = "Antiquity Tracker",
                icon = "EsoUI/Art/TreeIcons/Gamepad/gp_tutorial_idexIcon_guilds.dds", scene = self.sceneName }
            local entry = ZO_GamepadEntryData:New(menuData.name, menuData.icon)
            entry:SetIconTintOnSelection(true); entry:SetIconDisabledTintOnSelection(true)
            entry.data = menuData; entry.id = 997
            table.insert(ZO_MENU_ENTRIES, entry)
        end

        if MAIN_MENU_GAMEPAD then
            MAIN_MENU_GAMEPAD:RefreshLists()
            MAIN_MENU_GAMEPAD:UpdateEntryEnabledStates()
        end

        self.menuAdded = true
    end)

    if not success then end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- WATERMARK
-- ═══════════════════════════════════════════════════════════════════════════

function AT_UI:UpdateWatermark()
    local playerLabel = GetChild("FooterPlayer")
    if not playerLabel then return end
    local displayName = GetDisplayName and GetDisplayName() or ""
    local ts = GetTimeStamp and GetTimeStamp() or 0
    local secInDay = ts % 86400
    local hours   = math.floor(secInDay / 3600)
    local minutes = math.floor((secInDay % 3600) / 60)
    local days = math.floor(ts / 86400)
    local y = 1970  local m = 1
    local daysLeft = days
    while true do
        local diy = ((y % 4 == 0 and y % 100 ~= 0) or y % 400 == 0) and 366 or 365
        if daysLeft < diy then break end
        daysLeft = daysLeft - diy
        y = y + 1
    end
    local mdays = {31,28,31,30,31,30,31,31,30,31,30,31}
    if (y % 4 == 0 and y % 100 ~= 0) or y % 400 == 0 then mdays[2] = 29 end
    m = 1
    while m <= 12 and daysLeft >= mdays[m] do
        daysLeft = daysLeft - mdays[m]
        m = m + 1
    end
    local d = daysLeft + 1
    local dateStr = string.format("%02d/%02d/%04d", d, m, y)
    local timeStr = string.format("%02d:%02d", hours, minutes)
    playerLabel:SetText(COL_GRAY .. displayName .. "  " .. dateStr .. "  " .. timeStr .. COL_RESET)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- INITIALIZATION (two-phase: lightweight scene first, heavy UI on first open)
-- ═══════════════════════════════════════════════════════════════════════════

function AT_UI:EnsureUICreated()
    if self.uiCreated then return end
    self:CreateRowPool()
    self:SetupScrollControls()
    self:SetupActionButtons()
    self:SetupSearchBox()
    self:CreatePreviewPanel()
    self:UpdateWatermark()
    self.uiCreated = true
end

function AT_UI:Initialize()
    if self.initialized then return end
    self:SetupScene()
    self.initialized = true
end

function AT_UI:LateInit()
    self:AddToMainMenu()
end

-- ═══════════════════════════════════════════════════════════════════════════
-- SHOW / HIDE / TOGGLE
-- ═══════════════════════════════════════════════════════════════════════════

function AT_UI:Show()
    if not AT_Window then return end
    self:Initialize()
    SCENE_MANAGER:Show(self.sceneName)
end

function AT_UI:Hide()
    if SCENE_MANAGER:IsShowing(self.sceneName) then
        SCENE_MANAGER:HideCurrentScene()
    end
    self.visible = false
end

function AT_UI:Toggle()
    if not AT_Window then return end
    self:Initialize()
    if SCENE_MANAGER:IsShowing(self.sceneName) then
        SCENE_MANAGER:HideCurrentScene()
    else
        SCENE_MANAGER:Show(self.sceneName)
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- REFRESH ALL
-- ═══════════════════════════════════════════════════════════════════════════

function AT_UI:RefreshAll()
    self._listDirty = true
    self:RefreshActionButtons()
    self:RefreshList()
    self:UpdateFooter()
end

-- ═══════════════════════════════════════════════════════════════════════════
-- REFRESH LIST (fill row pool from AT.filteredList)
-- ═══════════════════════════════════════════════════════════════════════════

function AT_UI:RefreshList()
    local count = #AT.filteredList
    if not self._listDirty
        and self._lastListOffset == self.scrollOffset
        and self._lastSelectedRow == self.selectedRow
        and self._lastListCount == count
    then
        return
    end
    self._lastListOffset = self.scrollOffset
    self._lastSelectedRow = self.selectedRow
    self._lastListCount = count
    self._listDirty = false
    self:PerfCount("refresh_list_calls", 1)
    self:PerfMax("list_size", count)

    local dataList = AT.filteredList

    for i = 1, MAX_VISIBLE_ROWS do
        local dataIndex = self.scrollOffset + i
        local entry = dataList[dataIndex]
        local slot  = self.rowPool[i]
        if not slot then break end

        slot.selectHL:SetHidden(i ~= self.selectedRow)

        if entry then
            slot.control:SetHidden(false)

            if entry.icon and entry.icon ~= "" then
                pcall(function() slot.iconTex:SetTexture(entry.icon) end)
                slot.iconTex:SetHidden(false)
            else
                slot.iconTex:SetHidden(true)
            end

            local qh = AT.QualityHex(entry.quality)
            slot.nameLabel:SetText("|c" .. qh .. entry.name .. COL_RESET)

            slot.zoneLabel:SetText(COL_GRAY .. (entry.zoneName or "") .. COL_RESET)

            local stars = AT.difficultyStars[math.min(entry.difficulty or 1, 5)] or "*"
            slot.diffLabel:SetText(COL_GOLD .. stars .. COL_RESET)

            if entry.recovered > 0 then
                slot.statusLabel:SetText(COL_GREEN .. "Found: " .. entry.recovered .. COL_RESET)
            elseif entry.hasLead then
                slot.statusLabel:SetText(COL_BLUE .. "Lead Active" .. COL_RESET)
            elseif entry.requiresLead then
                slot.statusLabel:SetText(COL_GRAY .. "No Lead" .. COL_RESET)
            else
                slot.statusLabel:SetText(COL_GRAY .. "—" .. COL_RESET)
            end

            if entry.hasLead and entry.leadTimeS and entry.leadTimeS > 0 then
                local lt = AT.FormatLeadTime(entry.leadTimeS)
                local timeCol = COL_YELLOW
                if entry.leadTimeS < 86400 then
                    timeCol = COL_RED
                end
                slot.timeLabel:SetText(timeCol .. lt .. COL_RESET)
            else
                slot.timeLabel:SetText("")
            end

            local isMythic = entry.setQuality and entry.setQuality >= ITEM_DISPLAY_QUALITY_LEGENDARY
            if isMythic and entry.setName then
                slot.mythicLabel:SetText(COL_YELLOW .. entry.setName .. COL_RESET)
            else
                slot.mythicLabel:SetText("")
            end
        else
            slot.control:SetHidden(true)
            slot.selectHL:SetHidden(true)
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- SCROLLING
-- ═══════════════════════════════════════════════════════════════════════════

function AT_UI:GetDataCount()
    return #AT.filteredList
end

function AT_UI:GetMaxOffset()
    return math.max(0, self:GetDataCount() - MAX_VISIBLE_ROWS)
end

function AT_UI:ScrollLineUp()
    if self.scrollOffset > 0 then
        self.scrollOffset = self.scrollOffset - 1
        self:RefreshList()
        self:UpdateFooter()
    end
end

function AT_UI:ScrollLineDown()
    local maxOff = self:GetMaxOffset()
    if self.scrollOffset < maxOff then
        self.scrollOffset = self.scrollOffset + 1
        self:RefreshList()
        self:UpdateFooter()
    end
end

function AT_UI:MoveCursor(direction)
    local totalItems = self:GetDataCount()
    if totalItems == 0 then return end

    local absIndex = self.scrollOffset + self.selectedRow
    local newAbs   = absIndex + direction

    if newAbs < 1 then newAbs = 1 end
    if newAbs > totalItems then newAbs = totalItems end

    local visibleRows = math.min(MAX_VISIBLE_ROWS, totalItems)

    if newAbs <= self.scrollOffset then
        self.scrollOffset = newAbs - 1
        self.selectedRow  = 1
    elseif newAbs > self.scrollOffset + visibleRows then
        self.scrollOffset = newAbs - visibleRows
        self.selectedRow  = visibleRows
    else
        self.selectedRow = newAbs - self.scrollOffset
    end

    self:RefreshList()
    self:UpdateFooter()
end

function AT_UI:KeyScrollUp()   if self.visible then self:ScrollLineUp()   end end
function AT_UI:KeyScrollDown() if self.visible then self:ScrollLineDown() end end

-- ═══════════════════════════════════════════════════════════════════════════
-- FOOTER
-- ═══════════════════════════════════════════════════════════════════════════

function AT_UI:UpdateFooter()
    local label = GetChild("FooterStats")
    if not label then return end

    local absRow    = self.scrollOffset + self.selectedRow
    local totalData = self:GetDataCount()
    local posText   = COL_GRAY .. "  [" .. absRow .. "/" .. totalData .. "]" .. COL_RESET

    local total, showing, recovered, leads, mythicComplete, mythicTotal = AT:GetStats()

    label:SetText(
        "Total: " .. total ..
        "   " .. COL_GREEN .. "Recovered: " .. recovered .. COL_RESET ..
        "   " .. COL_BLUE .. "Leads: " .. leads .. COL_RESET ..
        "   " .. COL_YELLOW .. "Mythic: " .. mythicComplete .. "/" .. mythicTotal .. COL_RESET ..
        posText
    )
end
