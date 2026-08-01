-- =============================================================================
-- Guild Activity Tracker — UI Logic v1.0.0
-- 2 tabs: Roster, History.
-- Uses ZO_Scene with FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW for native
-- console gamepad input (keybind strip, virtual cursor, action layer).
-- Integrates into the Journal submenu in the gamepad main menu.
-- Architecture based on DungeonTrialTracker / BattleScrolls by Semigroup1329.
-- =============================================================================

GAT_UI = {}

-- ---------------------------------------------------------------------------
-- Layout constants
-- ---------------------------------------------------------------------------
local MAX_VISIBLE_ROWS = 20
local ROW_HEIGHT       = 28

-- ---------------------------------------------------------------------------
-- Custom fonts with explicit pixel sizes for TV readability
-- ---------------------------------------------------------------------------
local FONT_ROW_NAME    = "$(MEDIUM_FONT)|24|soft-shadow-thin"
local FONT_ROW_VALUE   = "$(MEDIUM_FONT)|24|soft-shadow-thin"
local FONT_BTN_LABEL   = "$(BOLD_FONT)|22|soft-shadow-thick"
local FONT_FILTER      = "$(MEDIUM_FONT)|22|soft-shadow-thin"
local FONT_FOOTER      = "$(MEDIUM_FONT)|20|soft-shadow-thin"
local FONT_SCROLL_BTN  = "$(BOLD_FONT)|28|soft-shadow-thick"

-- ---------------------------------------------------------------------------
-- Colour helpers (ESO inline colour codes)
-- ---------------------------------------------------------------------------
local COL_GOLD   = "|cE8C05C"
local COL_GREEN  = "|c4CAF50"
local COL_YELLOW = "|cFFCC4C"
local COL_RED    = "|cE53935"
local COL_GRAY   = "|c888888"
local COL_WHITE  = "|cFFFFFF"
local COL_RESET  = "|r"

-- ---------------------------------------------------------------------------
-- State
-- ---------------------------------------------------------------------------
GAT_UI.visible        = false
GAT_UI.activeTab      = "roster"
GAT_UI.scrollOffset   = 0
GAT_UI.rowPool        = {}
GAT_UI.initialized    = false
GAT_UI.listParent     = nil
GAT_UI.sceneName      = "gatScene"
GAT_UI.menuAdded      = false
GAT_UI.inDetailView   = false
GAT_UI.searchBox      = nil
GAT_UI.previewVisible = false
GAT_UI.previewPanel   = nil
GAT_UI.selectedRow    = 1
GAT_UI.pageMode       = false
GAT_UI.perf           = { enabled = false, counters = {}, max = {} }
GAT_UI.lastSearchState = nil

local ACTION_LAYERS = {
    nil,
    "GamepadUIMode",
    _G["ACTION_LAYER_GAMEPAD"],
    _G["ACTION_LAYER_UI"],
    _G["ACTION_LAYER_USER_INTERFACE"],
    _G["ACTION_LAYER_ALL"],
}

local ACTION_VALUE_READERS = {
    _G["GetActionValue"],
    _G["GetActionRawValue"],
}

local LEFT_STICK_READERS = {
    _G["GetGamepadLeftStickY"],
    _G["GetGamepadOrKeyboardLeftStickY"],
    _G["GetGamepadLeftStickDeltaY"],
}

local JOYSTICK_UP_ACTIONS = {
    "UI_NAVIGATION_UP",
    "UI_MOVE_PREVIOUS",
    "UI_SHORTCUT_LEFT_STICK_UP",
    "UI_UP",
    "UI_MOVE_UP",
    "UI_MENU_UP",
    "GAMEPAD_MOVE_UP",
    "GAMEPAD_NAV_UP",
    "MOVE_FORWARD",
}

local JOYSTICK_DOWN_ACTIONS = {
    "UI_NAVIGATION_DOWN",
    "UI_MOVE_NEXT",
    "UI_SHORTCUT_LEFT_STICK_DOWN",
    "UI_DOWN",
    "UI_MOVE_DOWN",
    "UI_MENU_DOWN",
    "GAMEPAD_MOVE_DOWN",
    "GAMEPAD_NAV_DOWN",
    "MOVE_BACKWARD",
}

local JOYSTICK_AXIS_PROBES = {
    "UI_VERTICAL",
    "UI_MOVE_Y",
    "UI_NAVIGATION_Y",
    "UI_SCROLL_Y",
    "UI_AXIS_Y",
    "UI_MENU_Y",
    "GAMEPAD_LEFT_Y",
    "GAMEPAD_AXIS_LEFT_Y",
    "GAMEPAD_LEFT_STICK_Y",
    "MOVE_Y",
    "MOVE_FORWARD_BACKWARD",
}

-- ═══════════════════════════════════════════════════════════════════════════
-- CONTROL LOOKUP
-- ═══════════════════════════════════════════════════════════════════════════

local function GetChild(name)
    if not GAT_Window then return nil end
    return GAT_Window:GetNamedChild(name)
end

function GAT_UI:PerfCount(key, delta)
    if not self.perf or not self.perf.enabled then return end
    self.perf.counters[key] = (self.perf.counters[key] or 0) + (delta or 1)
end

function GAT_UI:PerfMax(key, value)
    if not self.perf or not self.perf.enabled then return end
    local current = self.perf.max[key]
    if current == nil or value > current then
        self.perf.max[key] = value
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- ROW POOL (manual rows — no ZO_ScrollList)
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

function GAT_UI:CreateRowPool()
    self.listParent = GetChild("ListArea")
    if not self.listParent and GAT_Window then
        self.listParent = WINDOW_MANAGER:CreateControl(
            "GAT_ListAreaFallback", GAT_Window, CT_CONTROL)
        self.listParent:SetAnchor(TOPLEFT, GAT_Window, TOPLEFT, 20, 162)
        self.listParent:SetDimensions(1160, MAX_VISIBLE_ROWS * ROW_HEIGHT)
    end
    if not self.listParent then return end

    local pw = self.listParent:GetWidth()
    if pw <= 0 then pw = 1160 end
    self.rowPool = {}

    for i = 1, MAX_VISIBLE_ROWS do
        local yOff   = (i - 1) * ROW_HEIGHT
        local prefix = "GAT_Slot" .. i
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
                GAT_UI:OnRowClicked(rowIndex)
            end
        end)

        -- Roster labels (5 columns)
        local nameLabel      = MakeLabel(prefix .. "N", row, FONT_ROW_NAME,  8,   300)
        local rankLabel      = MakeLabel(prefix .. "R", row, FONT_ROW_VALUE, 320, 170)
        local statusLabel    = MakeLabel(prefix .. "S", row, FONT_ROW_VALUE, 500, 110, TEXT_ALIGN_CENTER)
        local lastOnLabel    = MakeLabel(prefix .. "L", row, FONT_ROW_VALUE, 620, 240)
        local zoneLabel      = MakeLabel(prefix .. "Z", row, FONT_ROW_VALUE, 870, 260)

        -- History / Detail labels (3 columns, reuse same row)
        local timeLabel      = MakeLabel(prefix .. "HT", row, FONT_ROW_VALUE, 8,   220)
        local catLabel       = MakeLabel(prefix .. "HC", row, FONT_ROW_VALUE, 240, 150)
        local descLabel      = MakeLabel(prefix .. "HD", row, FONT_ROW_NAME,  400, 740)

        self.rowPool[i] = {
            control      = row,
            highlight    = highlight,
            selectHL     = selectHL,
            nameLabel    = nameLabel,
            rankLabel    = rankLabel,
            statusLabel  = statusLabel,
            lastOnLabel  = lastOnLabel,
            zoneLabel    = zoneLabel,
            timeLabel    = timeLabel,
            catLabel     = catLabel,
            descLabel    = descLabel,
        }
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- SCROLL CONTROLS (mouse wheel + tappable buttons)
-- ═══════════════════════════════════════════════════════════════════════════

function GAT_UI:SetupScrollControls()
    local listArea = GetChild("ListArea")
    if listArea then
        listArea:SetHandler("OnMouseWheel", function(_, delta)
            if delta > 0 then
                GAT_UI:ScrollLineUp()
            else
                GAT_UI:ScrollLineDown()
            end
        end)
    end

    local upBtn = GetChild("ScrollUpBtn")
    if upBtn then
        upBtn:SetHandler("OnClicked", function() GAT_UI:ScrollLineUp() end)
        local upLabel = WINDOW_MANAGER:CreateControl("GAT_ScrollUpLabel", upBtn, CT_LABEL)
        upLabel:SetFont(FONT_SCROLL_BTN)
        upLabel:SetText(COL_GOLD .. "^" .. COL_RESET)
        upLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        upLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        upLabel:SetAnchorFill()
        upLabel:SetMouseEnabled(false)
    end

    local downBtn = GetChild("ScrollDownBtn")
    if downBtn then
        downBtn:SetHandler("OnClicked", function() GAT_UI:ScrollLineDown() end)
        local downLabel = WINDOW_MANAGER:CreateControl("GAT_ScrollDownLabel", downBtn, CT_LABEL)
        downLabel:SetFont(FONT_SCROLL_BTN)
        downLabel:SetText(COL_GOLD .. "v" .. COL_RESET)
        downLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        downLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        downLabel:SetAnchorFill()
        downLabel:SetMouseEnabled(false)
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- TAB BUTTONS (Roster / History, tappable with virtual cursor)
-- ═══════════════════════════════════════════════════════════════════════════

GAT_UI.tabButtons = {}

function GAT_UI:SetupTabButtons()
    local tabDefs = {
        { btn = "TabBtn1", tab = "roster",  label = "Roster" },
        { btn = "TabBtn2", tab = "history", label = "History" },
    }

    for _, def in ipairs(tabDefs) do
        local btn = GetChild(def.btn)
        if btn then
            local tabId = def.tab
            btn:SetHandler("OnClicked", function()
                GAT_UI:SetActiveTab(tabId)
            end)

            local lbl = WINDOW_MANAGER:CreateControl(
                "GAT_" .. def.btn .. "Label", btn, CT_LABEL)
            lbl:SetFont(FONT_BTN_LABEL)
            lbl:SetText(def.label)
            lbl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            lbl:SetVerticalAlignment(TEXT_ALIGN_CENTER)
            lbl:SetAnchorFill()
            lbl:SetMouseEnabled(false)

            self.tabButtons[tabId] = { button = btn, label = lbl, text = def.label }
        end
    end
end

function GAT_UI:RefreshTabButtons()
    for tabId, info in pairs(self.tabButtons) do
        if tabId == self.activeTab then
            info.label:SetColor(0.91, 0.75, 0.36, 1)
            info.label:SetText(COL_GOLD .. "[ " .. info.text .. " ]" .. COL_RESET)
        else
            info.label:SetColor(0.6, 0.6, 0.6, 1)
            info.label:SetText(info.text)
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- GUILD / FILTER / SORT BUTTONS (tappable labels that cycle on click)
-- ═══════════════════════════════════════════════════════════════════════════

function GAT_UI:SetupActionButtons()
    -- Guild selector button
    local guildBtn = GetChild("GuildBtn")
    if guildBtn then
        guildBtn:SetHandler("OnClicked", function()
            GAT:CycleGuild()
            if self.activeTab == "history" then
                GAT:LoadGuildHistory()
            end
            self.scrollOffset = 0  self.selectedRow = 1
            self:RefreshAll()
        end)
        self.guildBtnLabel = WINDOW_MANAGER:CreateControl("GAT_GuildBtnLabel", guildBtn, CT_LABEL)
        self.guildBtnLabel:SetFont(FONT_BTN_LABEL)
        self.guildBtnLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        self.guildBtnLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        self.guildBtnLabel:SetAnchorFill()
        self.guildBtnLabel:SetMouseEnabled(false)
    end

    -- Filter button
    local filterBtn = GetChild("FilterBtn")
    if filterBtn then
        filterBtn:SetHandler("OnClicked", function()
            if self.activeTab == "roster" then
                GAT:CycleFilter()
            else
                GAT:CycleHistoryCategory()
            end
            self.scrollOffset = 0  self.selectedRow = 1
            self:RefreshAll()
        end)
        self.filterBtnLabel = WINDOW_MANAGER:CreateControl("GAT_FilterBtnLabel", filterBtn, CT_LABEL)
        self.filterBtnLabel:SetFont(FONT_FILTER)
        self.filterBtnLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        self.filterBtnLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        self.filterBtnLabel:SetAnchorFill()
        self.filterBtnLabel:SetMouseEnabled(false)
    end

    -- Sort button (roster only)
    local sortBtn = GetChild("SortBtn")
    if sortBtn then
        sortBtn:SetHandler("OnClicked", function()
            if self.activeTab == "roster" then
                GAT:CycleSort()
            elseif not self.inDetailView then
                GAT:CycleHistoryMaxDays()
                GAT:LoadGuildHistory()
            end
            self.scrollOffset = 0  self.selectedRow = 1
            self:RefreshAll()
        end)
        self.sortBtnLabel = WINDOW_MANAGER:CreateControl("GAT_SortBtnLabel", sortBtn, CT_LABEL)
        self.sortBtnLabel:SetFont(FONT_FILTER)
        self.sortBtnLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        self.sortBtnLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        self.sortBtnLabel:SetAnchorFill()
        self.sortBtnLabel:SetMouseEnabled(false)
    end
end

function GAT_UI:RefreshActionButtons()
    if self.inDetailView then
        self:RefreshDetailActionButtons()
        return
    end

    if self.guildBtnLabel then
        self.guildBtnLabel:SetText(COL_GOLD .. GAT:GetCurrentGuildLabel() .. COL_RESET)
    end

    if self.filterBtnLabel then
        if self.activeTab == "roster" then
            self.filterBtnLabel:SetText(COL_WHITE .. GAT:GetCurrentFilterLabel() .. COL_RESET)
        else
            self.filterBtnLabel:SetText(COL_WHITE .. GAT:GetCurrentHistoryCatLabel() .. COL_RESET)
        end
    end

    local sortBtn = GetChild("SortBtn")
    if self.sortBtnLabel then
        if self.activeTab == "roster" then
            self.sortBtnLabel:SetText(COL_WHITE .. GAT:GetCurrentSortLabel() .. COL_RESET)
            if sortBtn then sortBtn:SetHidden(false) end
        elseif self.activeTab == "history" and not self.inDetailView then
            self.sortBtnLabel:SetText(COL_WHITE .. GAT:GetHistoryDaysLabel() .. COL_RESET)
            if sortBtn then sortBtn:SetHidden(false) end
        else
            self.sortBtnLabel:SetText("")
            if sortBtn then sortBtn:SetHidden(true) end
        end
    end

    local countLabel = GetChild("MemberCount")
    if countLabel then
        if self.activeTab == "roster" then
            local total = #GAT.memberDataAll
            countLabel:SetText(total .. " members")
        else
            countLabel:SetText("")
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- SEARCH BOX
-- ═══════════════════════════════════════════════════════════════════════════

function GAT_UI:ApplySearch()
    local state = self.lastSearchState
    if state
        and state.activeTab == self.activeTab
        and state.inDetailView == self.inDetailView
        and state.searchText == (GAT.searchText or "")
        and state.filterIndex == (GAT.filterIndex or 0)
        and state.sortIndex == (GAT.sortIndex or 0)
        and state.historyCatIndex == (GAT.historyCatIndex or 0)
        and state.detailCatIndex == (GAT.detailCatIndex or 0)
    then
        return
    end

    if not state then
        state = {}
        self.lastSearchState = state
    end
    state.activeTab = self.activeTab
    state.inDetailView = self.inDetailView
    state.searchText = (GAT.searchText or "")
    state.filterIndex = (GAT.filterIndex or 0)
    state.sortIndex = (GAT.sortIndex or 0)
    state.historyCatIndex = (GAT.historyCatIndex or 0)
    state.detailCatIndex = (GAT.detailCatIndex or 0)
    self:PerfCount("search_apply_calls", 1)

    self.scrollOffset = 0  self.selectedRow = 1
    if self.inDetailView then
        GAT:FilterMemberHistory()
    elseif self.activeTab == "roster" then
        GAT:FilterMembers()
    else
        GAT:FilterHistory()
    end
    self:RefreshList()
    self:UpdateFooter()
end

local SEARCH_POLL_NAME = GAT.name .. "_SearchPoll"

function GAT_UI:StartSearchPoll()
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
            if text ~= (GAT.searchText or "") then
                GAT.searchText = text
                self:ApplySearch()
            end
        end
    end)
end

function GAT_UI:StopSearchPoll()
    EVENT_MANAGER:UnregisterForUpdate(SEARCH_POLL_NAME)
end

function GAT_UI:SetupSearchBox()
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
        GAT.searchText = text
        GAT_UI:ApplySearch()
    end)

    editBox:SetHandler("OnEnter", function(ctrl)
        local text = ctrl:GetText() or ""
        GAT.searchText = text
        ctrl:LoseFocus()
        GAT_UI:ApplySearch()
    end)

    editBox:SetHandler("OnFocusLost", function(ctrl)
        GAT_UI:StopSearchPoll()
        local text = ctrl:GetText() or ""
        GAT.searchText = text
        GAT_UI:ApplySearch()
    end)

    editBox:SetHandler("OnEscape", function(ctrl)
        ctrl:SetText("")
        GAT.searchText = ""
        ctrl:LoseFocus()
        GAT_UI:ApplySearch()
    end)
end

function GAT_UI:ClearSearch()
    if self.searchBox then
        self.searchBox:SetText("")
        self.searchBox:LoseFocus()
    end
    GAT.searchText = ""
end

-- ═══════════════════════════════════════════════════════════════════════════
-- PREVIEW PANEL (full event text popup, triggered by pressing X on a row)
-- ═══════════════════════════════════════════════════════════════════════════

function GAT_UI:CreatePreviewPanel()
    if not GAT_Window then return end

    local panel = WINDOW_MANAGER:CreateControl("GAT_PreviewOverlay", GAT_Window, CT_CONTROL)
    panel:SetAnchorFill()
    panel:SetHidden(true)
    panel:SetMouseEnabled(true)
    panel:SetDrawLevel(100)

    local bg = WINDOW_MANAGER:CreateControl("GAT_PreviewBG", panel, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0, 0, 0, 1)
    bg:SetEdgeColor(0, 0, 0, 0)
    bg:SetMouseEnabled(false)

    local box = WINDOW_MANAGER:CreateControl("GAT_PreviewBox", panel, CT_CONTROL)
    box:SetDimensions(1000, 240)
    box:SetAnchor(CENTER, panel, CENTER, 0, 0)

    local boxBg = WINDOW_MANAGER:CreateControl("GAT_PreviewBoxBG", box, CT_BACKDROP)
    boxBg:SetAnchorFill()
    boxBg:SetCenterColor(0.08, 0.08, 0.08, 1)
    boxBg:SetEdgeColor(0, 0, 0, 0)
    boxBg:SetMouseEnabled(false)

    local border = WINDOW_MANAGER:CreateControl("GAT_PreviewBorder", box, CT_BACKDROP)
    border:SetAnchorFill()
    border:SetCenterColor(0, 0, 0, 0)
    border:SetEdgeColor(0.91, 0.75, 0.36, 1)
    border:SetEdgeTexture("", 2, 2, 2, 0)

    local catLbl = WINDOW_MANAGER:CreateControl("GAT_PreviewCat", box, CT_LABEL)
    catLbl:SetFont("$(BOLD_FONT)|24|soft-shadow-thick")
    catLbl:SetAnchor(TOPLEFT, box, TOPLEFT, 24, 16)
    catLbl:SetDimensions(600, 28)
    catLbl:SetColor(0.91, 0.75, 0.36, 1)
    catLbl:SetMouseEnabled(false)

    local timeLbl = WINDOW_MANAGER:CreateControl("GAT_PreviewTime", box, CT_LABEL)
    timeLbl:SetFont("$(MEDIUM_FONT)|22|soft-shadow-thin")
    timeLbl:SetAnchor(TOPRIGHT, box, TOPRIGHT, -24, 16)
    timeLbl:SetDimensions(300, 28)
    timeLbl:SetColor(0.53, 0.53, 0.53, 1)
    timeLbl:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    timeLbl:SetMouseEnabled(false)

    local descLbl = WINDOW_MANAGER:CreateControl("GAT_PreviewDesc", box, CT_LABEL)
    descLbl:SetFont("$(MEDIUM_FONT)|24|soft-shadow-thin")
    descLbl:SetAnchor(TOPLEFT, box, TOPLEFT, 24, 56)
    descLbl:SetDimensions(952, 120)
    descLbl:SetColor(1, 1, 1, 1)
    descLbl:SetMouseEnabled(false)

    local hintIcon = WINDOW_MANAGER:CreateControl("GAT_PreviewHintIcon", box, CT_TEXTURE)
    hintIcon:SetDimensions(32, 32)
    hintIcon:SetAnchor(BOTTOM, box, BOTTOM, -30, -12)
    hintIcon:SetTexture("EsoUI/Art/Buttons/Gamepad/gp_circleButton.dds")
    hintIcon:SetMouseEnabled(false)

    local hintLbl = WINDOW_MANAGER:CreateControl("GAT_PreviewHint", box, CT_LABEL)
    hintLbl:SetFont("$(BOLD_FONT)|22|soft-shadow-thick")
    hintLbl:SetAnchor(LEFT, hintIcon, RIGHT, 6, 0)
    hintLbl:SetDimensions(120, 32)
    hintLbl:SetColor(1, 1, 1, 1)
    hintLbl:SetText("Close")
    hintLbl:SetMouseEnabled(false)

    self.previewPanel    = panel
    self.previewCatLabel  = catLbl
    self.previewTimeLabel = timeLbl
    self.previewDescLabel = descLbl
end

function GAT_UI:ShowPreview(item)
    if not self.previewPanel then return end
    self.previewCatLabel:SetText(item.category or "")
    self.previewTimeLabel:SetText(item.time or "")
    self.previewDescLabel:SetText(item.description or "")
    for _, slot in ipairs(self.rowPool) do
        slot.control:SetHidden(true)
    end
    if self.listParent then self.listParent:SetHidden(true) end
    self.previewPanel:SetHidden(false)
    self.previewVisible = true
end

function GAT_UI:HidePreview()
    if self.previewPanel then
        self.previewPanel:SetHidden(true)
    end
    if self.listParent then self.listParent:SetHidden(false) end
    self:RefreshList()
    self.previewVisible = false
end

-- ═══════════════════════════════════════════════════════════════════════════
-- ROW CLICK (roster = detail view, history/detail = preview full text)
-- ═══════════════════════════════════════════════════════════════════════════

function GAT_UI:OnRowClicked(rowIndex)
    if self.previewVisible then
        self:HidePreview()
        return
    end

    if self.activeTab == "roster" and not self.inDetailView then
        local dataIndex = self.scrollOffset + rowIndex
        local member = GAT.memberDataFiltered[dataIndex]
        if not member then return end
        GAT:SelectMember(member)
        self:EnterDetailView()
    else
        local dataIndex = self.scrollOffset + rowIndex
        local dataList
        if self.inDetailView then
            dataList = GAT.memberHistoryFiltered
        else
            dataList = GAT.historyDataFiltered
        end
        local item = dataList[dataIndex]
        if item then
            self:ShowPreview(item)
        end
    end
end

function GAT_UI:EnterDetailView()
    self.inDetailView = true
    self.scrollOffset = 0  self.selectedRow = 1

    if self.searchBox then
        self.searchBox:GetParent():SetHidden(true)
    end

    local detailHeader = GetChild("DetailHeader")
    if detailHeader and GAT.selectedMember then
        local name = GAT.selectedMember.displayName or ""
        local rank = GAT.selectedMember.rankName or ""
        detailHeader:SetText(COL_GOLD .. name .. COL_RESET .. "  " .. COL_GRAY .. "(" .. rank .. ")" .. COL_RESET)
        detailHeader:SetHidden(false)
    end

    local filterBtn = GetChild("FilterBtn")
    if filterBtn then filterBtn:SetHidden(true) end
    local sortBtn = GetChild("SortBtn")
    if sortBtn then sortBtn:SetHidden(true) end

    self:RefreshDetailActionButtons()
    self:RefreshDetailColumnHeaders()
    self:RefreshKeybindStrip()
    self:RefreshList()
    self:UpdateFooter()
end

function GAT_UI:ExitDetailView()
    self.inDetailView = false
    self.scrollOffset = 0  self.selectedRow = 1
    GAT:ClearSelectedMember()

    local detailHeader = GetChild("DetailHeader")
    if detailHeader then detailHeader:SetHidden(true) end

    if self.searchBox then
        self.searchBox:GetParent():SetHidden(false)
    end

    local filterBtn = GetChild("FilterBtn")
    if filterBtn then filterBtn:SetHidden(false) end
    local sortBtn = GetChild("SortBtn")
    if sortBtn then sortBtn:SetHidden(false) end

    self:RefreshKeybindStrip()
    self:RefreshAll()
end

function GAT_UI:RefreshDetailActionButtons()
    if self.filterBtnLabel then
        self.filterBtnLabel:SetText(COL_WHITE .. GAT:GetCurrentDetailCatLabel() .. COL_RESET)
    end
end

function GAT_UI:RefreshDetailColumnHeaders()
    local colName      = GetChild("ColName")
    local colRank      = GetChild("ColRank")
    local colStatus    = GetChild("ColStatus")
    local colLastOnline = GetChild("ColLastOnline")
    local colZone      = GetChild("ColZone")

    if colName      then colName:SetText("TIME")      colName:SetHidden(false) end
    if colRank      then colRank:SetText("CATEGORY")   colRank:SetHidden(false) end
    if colStatus    then colStatus:SetText("")          colStatus:SetHidden(true) end
    if colLastOnline then
        colLastOnline:SetText("EVENT DESCRIPTION")
        colLastOnline:SetHidden(false)
        colLastOnline:ClearAnchors()
        colLastOnline:SetAnchor(TOPLEFT, GAT_Window, TOPLEFT, 520, 130)
        colLastOnline:SetDimensions(600, 24)
    end
    if colZone      then colZone:SetText("")            colZone:SetHidden(true) end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- COLUMN HEADERS (swap between roster and history)
-- ═══════════════════════════════════════════════════════════════════════════

function GAT_UI:RefreshColumnHeaders()
    if self.inDetailView then
        self:RefreshDetailColumnHeaders()
        return
    end

    local colName      = GetChild("ColName")
    local colRank      = GetChild("ColRank")
    local colStatus    = GetChild("ColStatus")
    local colLastOnline = GetChild("ColLastOnline")
    local colZone      = GetChild("ColZone")

    if self.activeTab == "roster" then
        if colName      then colName:SetText("NAME")          colName:SetHidden(false) end
        if colRank      then colRank:SetText("RANK")          colRank:SetHidden(false) end
        if colStatus    then colStatus:SetText("STATUS")      colStatus:SetHidden(false) end
        if colLastOnline then colLastOnline:SetText("LAST ONLINE") colLastOnline:SetHidden(false) end
        if colZone      then colZone:SetText("ZONE")          colZone:SetHidden(false) end
    else
        if colName      then colName:SetText("TIME")          colName:SetHidden(false) end
        if colRank      then colRank:SetText("CATEGORY")      colRank:SetHidden(false) end
        if colStatus    then colStatus:SetText("")             colStatus:SetHidden(true) end
        if colLastOnline then colLastOnline:SetText("EVENT")  colLastOnline:SetHidden(false)
            colLastOnline:ClearAnchors()
            colLastOnline:SetAnchor(TOPLEFT, GAT_Window, TOPLEFT, 520, 130)
            colLastOnline:SetDimensions(600, 24)
        end
        if colZone      then colZone:SetText("")               colZone:SetHidden(true) end
    end
end

local function ResetRosterColumnAnchors()
    local colLastOnline = GetChild("ColLastOnline")
    if colLastOnline then
        colLastOnline:ClearAnchors()
        colLastOnline:SetAnchor(TOPLEFT, GAT_Window, TOPLEFT, 640, 130)
        colLastOnline:SetDimensions(240, 24)
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- KEYBIND STRIP (L1/R1 tabs, L2/R2 scroll, Triangle filter, Square guild)
-- ═══════════════════════════════════════════════════════════════════════════

function GAT_UI:BuildKeybindStrip()
    self.keybindStripDescriptor = {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        {
            keybind  = "UI_SHORTCUT_NEGATIVE",
            name     = GetString(SI_GAMEPAD_BACK_OPTION),
            callback = function()
                if self.previewVisible then
                    self:HidePreview()
                elseif self.inDetailView then
                    self:ExitDetailView()
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
                GAT_UI:OnRowClicked(self.selectedRow)
            end,
        },
        {
            keybind  = "UI_SHORTCUT_LEFT_SHOULDER",
            name     = "Prev Tab",
            callback = function()
                if not self.inDetailView and not self.previewVisible then GAT_UI:PrevTab() end
            end,
        },
        {
            keybind  = "UI_SHORTCUT_RIGHT_SHOULDER",
            name     = "Next Tab",
            callback = function()
                if not self.inDetailView and not self.previewVisible then GAT_UI:NextTab() end
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
            name     = function()
                if self.activeTab == "history" and not self.inDetailView then
                    return "Next Range"
                end
                return "Next Guild"
            end,
            callback = function()
                if self.previewVisible then return end
                if self.activeTab == "history" and not self.inDetailView then
                    GAT:CycleHistoryMaxDays()
                    GAT:LoadGuildHistory()
                    self.scrollOffset = 0  self.selectedRow = 1
                    self:RefreshAll()
                    return
                end
                if self.inDetailView then self:ExitDetailView() end
                GAT:CycleGuild()
                if self.activeTab == "history" then
                    GAT:LoadGuildHistory()
                end
                self.scrollOffset = 0  self.selectedRow = 1
                self:RefreshAll()
            end,
        },
        {
            keybind  = "UI_SHORTCUT_TERTIARY",
            name     = "Search",
            callback = function()
                if self.previewVisible then return end
                if not self.inDetailView and self.searchBox then
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
                if self.inDetailView then
                    GAT:CycleDetailCategory()
                    self.scrollOffset = 0  self.selectedRow = 1
                    self:RefreshDetailActionButtons()
                    self:RefreshList()
                    self:UpdateFooter()
                elseif self.activeTab == "roster" then
                    GAT:CycleFilter()
                    self.scrollOffset = 0  self.selectedRow = 1
                    self:RefreshAll()
                else
                    GAT:CycleHistoryCategory()
                    GAT:LoadGuildHistory()
                    self.scrollOffset = 0  self.selectedRow = 1
                    self:RefreshAll()
                end
            end,
        },
    }
end

function GAT_UI:RefreshKeybindStrip()
    if self.visible and self.keybindStripDescriptor then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)
    end
end

function GAT_UI:ResetInputDebugState()
    self.debugInputState = {}
    self.debugPollAnnounced = false
    self.debugLastHeartbeatMs = nil
end

function GAT_UI:DebugInput(msg)
    return
end

function GAT_UI:IsActionPressedSafe(actionName)
    local checker = _G["IsActionPressed"]
    if type(checker) ~= "function" then
        return false
    end

    for _, layer in ipairs(ACTION_LAYERS) do
        local ok, pressed
        if layer == nil then
            ok, pressed = pcall(checker, actionName)
            if ok and pressed then
                return true
            end
        else
            ok, pressed = pcall(checker, layer, actionName)
            if ok and pressed then
                return true
            end
            ok, pressed = pcall(checker, actionName, layer)
            if ok and pressed then
                return true
            end
        end
    end

    return false
end

function GAT_UI:GetActionValueSafe(actionName)
    for _, reader in ipairs(ACTION_VALUE_READERS) do
        if type(reader) == "function" then
            for _, layer in ipairs(ACTION_LAYERS) do
                local ok, value
                if layer == nil then
                    ok, value = pcall(reader, actionName)
                    if ok and type(value) == "number" then
                        return value
                    end
                else
                    ok, value = pcall(reader, layer, actionName)
                    if ok and type(value) == "number" then
                        return value
                    end
                    ok, value = pcall(reader, actionName, layer)
                    if ok and type(value) == "number" then
                        return value
                    end
                end
            end
        end
    end
    return nil
end

function GAT_UI:GetNowMs()
    return (type(GetFrameTimeMilliseconds) == "function" and GetFrameTimeMilliseconds())
        or (type(GetGameTimeMilliseconds) == "function" and GetGameTimeMilliseconds())
        or 0
end

function GAT_UI:GetRawLeftStickY()
    for _, reader in ipairs(LEFT_STICK_READERS) do
        if type(reader) == "function" then
            local ok, value = pcall(reader)
            if ok and type(value) == "number" then
                return value
            end
        end
    end
    return nil
end

function GAT_UI:GetJoystickDirection()
    local rawY = self:GetRawLeftStickY()
    if type(rawY) == "number" then
        -- Positive Y is treated as Up in gamepad UI conventions.
        if rawY >= 0.35 then
            return -1, "RAW_LEFT_STICK_Y"
        elseif rawY <= -0.35 then
            return 1, "RAW_LEFT_STICK_Y"
        end
    end

    for _, actionName in ipairs(JOYSTICK_UP_ACTIONS) do
        if self:IsActionPressedSafe(actionName) then
            return -1, actionName
        end
    end
    for _, actionName in ipairs(JOYSTICK_DOWN_ACTIONS) do
        if self:IsActionPressedSafe(actionName) then
            return 1, actionName
        end
    end

    for _, actionName in ipairs(JOYSTICK_AXIS_PROBES) do
        local value = self:GetActionValueSafe(actionName)
        if type(value) == "number" then
            if value <= -0.35 then
                return -1, actionName
            elseif value >= 0.35 then
                return 1, actionName
            end
        end
    end

    return 0, nil
end

function GAT_UI:PollJoystickNavigation()
    if not self.visible or self.previewVisible then
        return
    end

    local nowMs = self:GetNowMs()
    local direction, source = self:GetJoystickDirection()
    if direction == 0 then
        self.lastJoystickDirection = 0
        return
    end

    local repeatMs = 100
    local step = self.pageMode and MAX_VISIBLE_ROWS or 1
    local changedDirection = self.lastJoystickDirection ~= direction
    if changedDirection or not self.lastJoystickMoveMs or (nowMs - self.lastJoystickMoveMs) >= repeatMs then
        self:MoveCursor(direction * step)
        self.lastJoystickMoveMs = nowMs
        self.lastJoystickDirection = direction
        -- debug output removed in production build
    end
end

function GAT_UI:PollInputDebug()
    return
end

-- ═══════════════════════════════════════════════════════════════════════════
-- SCENE SETUP (proper gamepad scene with GAMEPAD_DRIVEN_UI_WINDOW)
-- ═══════════════════════════════════════════════════════════════════════════

function GAT_UI:SetupScene()
    if not GAT_Window then return end

    local windowFragment = ZO_SimpleSceneFragment:New(GAT_Window)
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
            GAT:RefreshGuildList()
            local savedIdx = GAT.savedVars and GAT.savedVars.lastGuildIndex or 1
            if savedIdx > #GAT.guildList then savedIdx = 1 end
            GAT:SelectGuild(savedIdx)
            GAT:RequestOlderHistory()
            GAT:EnsureRosterFresh(false)

            -- Restore tab
            local savedTab = GAT.savedVars and GAT.savedVars.activeTab
            if savedTab ~= "roster" and savedTab ~= "history" then
                savedTab = "roster"
            end
            self.activeTab    = savedTab
            self.scrollOffset = 0  self.selectedRow = 1
            self.visible      = true
            self:ResetInputDebugState()

            if self.activeTab == "history" then
                GAT:EnsureHistoryFresh(false)
            end

            KEYBIND_STRIP:AddKeybindButtonGroup(self.keybindStripDescriptor)
            EVENT_MANAGER:RegisterForUpdate("GAT_JoystickNavPoll", 100, function()
                self:PollJoystickNavigation()
            end)

            self:RefreshAll()
            self:UpdateWatermark()
            self:RegisterInTrackingToolsHub()

        elseif newState == SCENE_HIDDEN then
            self.visible = false
            self:HidePreview()
            self:StopSearchPoll()
            if self.inDetailView then
                self.inDetailView = false
                GAT:ClearSelectedMember()
            end
            self:ClearSearch()
            KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindStripDescriptor)
            EVENT_MANAGER:UnregisterForUpdate("GAT_JoystickNavPoll")
            self:ResetInputDebugState()
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- JOURNAL MENU INTEGRATION
-- ═══════════════════════════════════════════════════════════════════════════

function GAT_UI:RegisterInTrackingToolsHub()
    if ELDIBABALO_TRACKING_TOOLS and ELDIBABALO_TRACKING_TOOLS.Register then
        ELDIBABALO_TRACKING_TOOLS:Register("Guild Activity Tracker",
            "EsoUI/Art/TreeIcons/Gamepad/gp_tutorial_idexIcon_guilds.dds", self.sceneName)
        if ELDIBABALO_TRACKING_TOOLS.RefreshList then
            ELDIBABALO_TRACKING_TOOLS:RefreshList()
        end
        return true
    end
    return false
end

function GAT_UI:AddToMainMenu()
    -- Disabled: GAT should not appear in Journal.
    -- Also remove any stale Journal submenu entry injected by older builds.
    if ZO_MENU_ENTRIES and ZO_MENU_MAIN_ENTRIES then
        for _, entry in ipairs(ZO_MENU_ENTRIES) do
            if entry.id == ZO_MENU_MAIN_ENTRIES.JOURNAL and entry.subMenu then
                for i = #entry.subMenu, 1, -1 do
                    local sub = entry.subMenu[i]
                    local name = (sub and sub.data and sub.data.name) or sub.name
                    if name == "Guild Activity Tracker" then
                        table.remove(entry.subMenu, i)
                    end
                end
            end
        end
    end
    if MAIN_MENU_GAMEPAD then
        MAIN_MENU_GAMEPAD:RefreshLists()
        MAIN_MENU_GAMEPAD:UpdateEntryEnabledStates()
    end
    -- Register into Tracking Tools hub (when provided by other trackers),
    -- while remaining hidden from Journal main menu.
    self:RegisterInTrackingToolsHub()
    self.menuAdded = true
    return
end

-- ═══════════════════════════════════════════════════════════════════════════
-- WATERMARK
-- ═══════════════════════════════════════════════════════════════════════════

function GAT_UI:UpdateWatermark()
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
-- INITIALIZATION
-- ═══════════════════════════════════════════════════════════════════════════

function GAT_UI:Initialize()
    if self.initialized then return end

    self:CreateRowPool()
    self:SetupScrollControls()
    self:SetupTabButtons()
    self:SetupActionButtons()
    self:SetupSearchBox()
    self:CreatePreviewPanel()
    self:SetupScene()
    self:UpdateWatermark()

    self.initialized = true
end

function GAT_UI:LateInit()
    self:AddToMainMenu()
end

-- ═══════════════════════════════════════════════════════════════════════════
-- SHOW / HIDE (via Scene Manager)
-- ═══════════════════════════════════════════════════════════════════════════

function GAT_UI:Show()
    if not GAT_Window then return end
    self:Initialize()
    self:RegisterInTrackingToolsHub()
    SCENE_MANAGER:Show(self.sceneName)
end

function GAT_UI:Hide()
    if SCENE_MANAGER:IsShowing(self.sceneName) then
        SCENE_MANAGER:HideCurrentScene()
    end
    self.visible = false
end

function GAT_UI:Toggle()
    if not GAT_Window then return end
    self:Initialize()
    if SCENE_MANAGER:IsShowing(self.sceneName) then
        SCENE_MANAGER:HideCurrentScene()
    else
        SCENE_MANAGER:Show(self.sceneName)
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- TABS
-- ═══════════════════════════════════════════════════════════════════════════

local TAB_ORDER = { "roster", "history" }

function GAT_UI:SetActiveTab(tab)
    if self.inDetailView then
        self:ExitDetailView()
    end

    self.activeTab    = tab
    self.scrollOffset = 0  self.selectedRow = 1
    if GAT.savedVars then GAT.savedVars.activeTab = tab end

    if tab == "history" then
        GAT:EnsureHistoryFresh(false)
    end

    self:RefreshAll()
end

function GAT_UI:NextTab()
    for i, t in ipairs(TAB_ORDER) do
        if t == self.activeTab then
            local next = TAB_ORDER[(i % #TAB_ORDER) + 1]
            self:SetActiveTab(next)
            return
        end
    end
end

function GAT_UI:PrevTab()
    for i, t in ipairs(TAB_ORDER) do
        if t == self.activeTab then
            local prev = TAB_ORDER[((i - 2) % #TAB_ORDER) + 1]
            self:SetActiveTab(prev)
            return
        end
    end
end

function GAT_UI:KeyNextTab() self:NextTab() end
function GAT_UI:KeyPrevTab() self:PrevTab() end

-- ═══════════════════════════════════════════════════════════════════════════
-- REFRESH ALL
-- ═══════════════════════════════════════════════════════════════════════════

function GAT_UI:RefreshAll()
    self:PerfCount("refresh_all_calls", 1)
    if self.activeTab == "roster" and not self.inDetailView then
        ResetRosterColumnAnchors()
    end
    self:RefreshKeybindStrip()
    self:RefreshTabButtons()
    self:RefreshActionButtons()
    self:RefreshColumnHeaders()
    self:RefreshList()
    self:UpdateFooter()
end

-- ═══════════════════════════════════════════════════════════════════════════
-- REFRESH LIST (roster or history rows)
-- ═══════════════════════════════════════════════════════════════════════════

function GAT_UI:RefreshList()
    self:PerfCount("refresh_list_calls", 1)
    local isRoster = (self.activeTab == "roster") and not self.inDetailView
    local isDetail = self.inDetailView
    local dataList

    if isDetail then
        dataList = GAT.memberHistoryFiltered
    elseif isRoster then
        dataList = GAT.memberDataFiltered
    else
        dataList = GAT.historyDataFiltered
    end
    self:PerfMax("list_size", #(dataList or {}))

    for i = 1, MAX_VISIBLE_ROWS do
        local dataIndex = self.scrollOffset + i
        local item = dataList[dataIndex]
        local slot = self.rowPool[i]
        if not slot then break end

        slot.selectHL:SetHidden(i ~= self.selectedRow)

        if item then
            slot.control:SetHidden(false)

            if isRoster then
                slot.nameLabel:SetHidden(false)
                slot.rankLabel:SetHidden(false)
                slot.statusLabel:SetHidden(false)
                slot.lastOnLabel:SetHidden(false)
                slot.zoneLabel:SetHidden(false)
                slot.timeLabel:SetHidden(true)
                slot.catLabel:SetHidden(true)
                slot.descLabel:SetHidden(true)

                local nameCol = COL_WHITE
                if item.isOnline then
                    nameCol = COL_GREEN
                elseif item.daysOffline >= 14 then
                    nameCol = COL_RED
                elseif item.daysOffline >= 7 then
                    nameCol = COL_YELLOW
                end
                slot.nameLabel:SetText(nameCol .. (item.displayName or "") .. COL_RESET)

                slot.rankLabel:SetText(item.rankName or "")

                local statusCol = COL_GRAY
                if item.statusKey == "online" then statusCol = COL_GREEN
                elseif item.statusKey == "away" then statusCol = COL_YELLOW
                elseif item.statusKey == "dnd"  then statusCol = "|cFF9800"
                end
                slot.statusLabel:SetText(statusCol .. (item.statusText or "") .. COL_RESET)

                local lastCol = COL_GRAY
                if item.isOnline then lastCol = COL_GREEN
                elseif item.daysOffline >= 14 then lastCol = COL_RED
                elseif item.daysOffline >= 7 then lastCol = COL_YELLOW
                end
                slot.lastOnLabel:SetText(lastCol .. (item.lastOnlineText or "") .. COL_RESET)

                slot.zoneLabel:SetText(COL_GRAY .. (item.zone or "") .. COL_RESET)
            else
                slot.nameLabel:SetHidden(true)
                slot.rankLabel:SetHidden(true)
                slot.statusLabel:SetHidden(true)
                slot.lastOnLabel:SetHidden(true)
                slot.zoneLabel:SetHidden(true)
                slot.timeLabel:SetHidden(false)
                slot.catLabel:SetHidden(false)
                slot.descLabel:SetHidden(false)

                slot.timeLabel:SetText(COL_GRAY .. (item.time or "") .. COL_RESET)
                slot.catLabel:SetText(COL_GOLD .. (item.category or "") .. COL_RESET)
                slot.descLabel:SetText(COL_WHITE .. (item.description or "") .. COL_RESET)
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

function GAT_UI:GetDataCount()
    if self.inDetailView then
        return #GAT.memberHistoryFiltered
    elseif self.activeTab == "roster" then
        return #GAT.memberDataFiltered
    else
        return #GAT.historyDataFiltered
    end
end

function GAT_UI:GetMaxOffset()
    return math.max(0, self:GetDataCount() - MAX_VISIBLE_ROWS)
end

function GAT_UI:ScrollLineUp()
    if self.scrollOffset > 0 then
        self.scrollOffset = self.scrollOffset - 1
        self:RefreshList()
    end
end

function GAT_UI:ScrollLineDown()
    local maxOff = self:GetMaxOffset()
    if self.scrollOffset < maxOff then
        self.scrollOffset = self.scrollOffset + 1
        self:RefreshList()
    end
end

function GAT_UI:MoveCursor(direction)
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

function GAT_UI:ScrollChunk(lines)
    local newOff = self.scrollOffset + lines
    newOff = math.max(0, math.min(self:GetMaxOffset(), newOff))
    if newOff ~= self.scrollOffset then
        self.scrollOffset = newOff
        self:RefreshList()
    end
end

function GAT_UI:ScrollPageUp()
    self.scrollOffset = math.max(0, self.scrollOffset - MAX_VISIBLE_ROWS)
    self:RefreshList()
end

function GAT_UI:ScrollPageDown()
    self.scrollOffset = math.min(self:GetMaxOffset(), self.scrollOffset + MAX_VISIBLE_ROWS)
    self:RefreshList()
end

function GAT_UI:KeyScrollUp()   if self.visible then self:ScrollLineUp()   end end
function GAT_UI:KeyScrollDown() if self.visible then self:ScrollLineDown() end end

-- ═══════════════════════════════════════════════════════════════════════════
-- FOOTER
-- ═══════════════════════════════════════════════════════════════════════════

function GAT_UI:UpdateFooter()
    local label = GetChild("FooterStats")
    if not label then return end

    local absRow = self.scrollOffset + self.selectedRow
    local totalData = self:GetDataCount()
    local posText = COL_GRAY .. "  [" .. absRow .. "/" .. totalData .. "]" .. COL_RESET

    if self.inDetailView then
        local total, goldDeposits, traderSales, bankItems = GAT:GetMemberDetailStats()
        local showing = #GAT.memberHistoryFiltered
        local trunc = (GAT.memberHistoryLoadTruncated and "  |cE8C05C(capped)|r") or ""
        label:SetText(
            "Showing: " .. showing ..
            "   " .. COL_GOLD .. "Gold: " .. goldDeposits .. COL_RESET ..
            "   " .. COL_GREEN .. "Sales: " .. traderSales .. COL_RESET ..
            "   " .. COL_YELLOW .. "Items: " .. bankItems .. COL_RESET ..
            trunc ..
            posText
        )
    elseif self.activeTab == "roster" then
        local total, showing, online, inactive7, inactive30 = GAT:GetRosterStats()
        label:SetText(
            "Total: " .. total ..
            "   " .. COL_GREEN .. "Online: " .. online .. COL_RESET ..
            "   " .. COL_YELLOW .. "7d+: " .. inactive7 .. COL_RESET ..
            "   " .. COL_RED .. "30d+: " .. inactive30 .. COL_RESET ..
            posText
        )
    else
        local count = #GAT.historyDataFiltered
        local trunc = (GAT.historyLoadTruncated and "  |cE8C05C(list capped)|r") or ""
        label:SetText(
            "Showing " .. count .. " events   "
            .. COL_WHITE .. GAT:GetHistoryDaysLabel() .. COL_RESET
            .. trunc
            .. "   " .. COL_GRAY .. "Triangle: Search  Square: Range  R3: Filter  L3: Page/Line" .. COL_RESET
            .. posText
        )
    end
end
