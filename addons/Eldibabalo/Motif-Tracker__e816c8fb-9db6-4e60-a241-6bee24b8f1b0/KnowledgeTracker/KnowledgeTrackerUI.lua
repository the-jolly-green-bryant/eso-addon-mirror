-- =============================================================================
-- Motifs Tracker — UI Logic v2.0.0
-- Single-view motif list with inline 14-chapter visual grid.
-- Known chapters in green, missing chapters greyed out.
-- =============================================================================

KT_UI = {}

-- ---------------------------------------------------------------------------
-- Layout constants
-- ---------------------------------------------------------------------------
local MAX_VISIBLE_ROWS = 21
local ROW_HEIGHT       = 28

-- ---------------------------------------------------------------------------
-- Fonts
-- ---------------------------------------------------------------------------
local FONT_ROW_NAME    = "$(MEDIUM_FONT)|24|soft-shadow-thin"
local FONT_ROW_STATUS  = "$(BOLD_FONT)|24|soft-shadow-thin"
local FONT_DOT         = "$(BOLD_FONT)|20|soft-shadow-thin"
local FONT_SCROLL_BTN  = "$(BOLD_FONT)|28|soft-shadow-thick"
local FONT_SEARCH      = "$(MEDIUM_FONT)|22|soft-shadow-thin"
local FONT_DETAIL_TITLE = "$(BOLD_FONT)|20|soft-shadow-thin"
local FONT_DETAIL_BODY  = "$(MEDIUM_FONT)|20|soft-shadow-thin"

local DOT_START_X = 770
local DOT_SPACING = 26
local NUM_CHAPTERS = 14

-- ---------------------------------------------------------------------------
-- Colours
-- ---------------------------------------------------------------------------
local COL_GREEN  = "|c4CAF50"
local COL_RED    = "|cE53935"
local COL_GRAY   = "|c2A2A2A"
local COL_GOLD   = "|cE8C05C"
local COL_WHITE  = "|cFFFFFF"
local COL_YELLOW = "|cFFD740"
local COL_RESET  = "|r"

-- The 14 motif chapter slots in ESO's fixed order
local SLOT_NAMES = {
    "Axes", "Belts", "Boots", "Bows", "Chests", "Daggers", "Gloves",
    "Helmets", "Legs", "Maces", "Shields", "Shoulders", "Staves", "Swords",
}

-- ---------------------------------------------------------------------------
-- State
-- ---------------------------------------------------------------------------
KT_UI.visible       = false
KT_UI.scrollOffset  = 0
KT_UI.displayList   = {}
KT_UI.rowPool       = {}
KT_UI.initialized   = false
KT_UI.listParent    = nil
KT_UI.sceneName     = "ktScene"
KT_UI.menuAdded     = false
KT_UI.hubRetryScheduled = false
KT_UI.searchText    = ""
KT_UI.searchActive  = false
KT_UI.selectedIndex = 1
KT_UI.showMissingDetails = false
KT_UI.stickRepeatAtMs = 0
KT_UI.currentTab = "motifs"

-- ═══════════════════════════════════════════════════════════════════════════
-- CONTROL LOOKUP
-- ═══════════════════════════════════════════════════════════════════════════

local function GetChild(name)
    if not KT_Window then return nil end
    return KT_Window:GetNamedChild(name)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- ROW POOL
-- ═══════════════════════════════════════════════════════════════════════════

local function MakeLabel(name, parent, font, xOffset, width)
    local label = WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL)
    label:SetFont(font)
    label:SetColor(1, 1, 1, 1)
    label:SetAnchor(LEFT, parent, LEFT, xOffset, 0)
    label:SetDimensions(width, ROW_HEIGHT)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetMouseEnabled(false)
    return label
end

function KT_UI:CreateRowPool()
    self.listParent = GetChild("ListArea")
    if not self.listParent and KT_Window then
        self.listParent = WINDOW_MANAGER:CreateControl(
            "KT_ListAreaFallback", KT_Window, CT_CONTROL)
        self.listParent:SetAnchor(TOPLEFT, KT_Window, TOPLEFT, 20, 122)
        self.listParent:SetDimensions(1160, MAX_VISIBLE_ROWS * ROW_HEIGHT)
    end
    if not self.listParent then return end

    local pw = self.listParent:GetWidth()
    if pw <= 0 then pw = 1160 end
    self.rowPool = {}

    for i = 1, MAX_VISIBLE_ROWS do
        local yOff   = (i - 1) * ROW_HEIGHT
        local prefix = "KT_Slot" .. i
        local row = WINDOW_MANAGER:CreateControl(prefix, self.listParent, CT_CONTROL)
        row:SetDimensions(pw, ROW_HEIGHT)
        row:SetAnchor(TOPLEFT, self.listParent, TOPLEFT, 0, yOff)
        row:SetMouseEnabled(true)
        row:SetHandler("OnMouseUp", function()
            KT_UI.selectedIndex = KT_UI.scrollOffset + i
            KT_UI:RefreshList()
        end)

        local highlight = WINDOW_MANAGER:CreateControl(prefix .. "Sel", row, CT_BACKDROP)
        highlight:SetAnchorFill()
        highlight:SetCenterColor(0.20, 0.26, 0.32, 0.55)
        highlight:SetEdgeColor(0.91, 0.75, 0.36, 0.80)
        highlight:SetEdgeTexture("", 1, 1, 1)
        highlight:SetHidden(true)

        local nameLabel    = MakeLabel(prefix .. "N", row, FONT_ROW_NAME,   8,   650)
        nameLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        local detailLabel  = MakeLabel(prefix .. "D", row, FONT_ROW_STATUS, 660, 100)
        detailLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

        local dots = {}
        for j = 1, NUM_CHAPTERS do
            local dotX = DOT_START_X + (j - 1) * DOT_SPACING
            local dotLbl = WINDOW_MANAGER:CreateControl(prefix .. "Dot" .. j, row, CT_LABEL)
            dotLbl:SetFont(FONT_DOT)
            dotLbl:SetAnchor(LEFT, row, LEFT, dotX, 0)
            dotLbl:SetDimensions(DOT_SPACING, ROW_HEIGHT)
            dotLbl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            dotLbl:SetVerticalAlignment(TEXT_ALIGN_CENTER)
            dotLbl:SetMouseEnabled(false)
            dotLbl:SetText("●")
            dots[j] = dotLbl
        end

        self.rowPool[i] = {
            control     = row,
            highlight   = highlight,
            nameLabel   = nameLabel,
            detailLabel = detailLabel,
            dots        = dots,
        }
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- SEARCH UI
-- ═══════════════════════════════════════════════════════════════════════════

function KT_UI:CreateSearchUI()
    if not KT_Window then return end

    local searchBg = WINDOW_MANAGER:CreateControl("KT_SearchBg", KT_Window, CT_BACKDROP)
    searchBg:SetDimensions(500, 36)
    searchBg:SetAnchor(TOP, KT_Window, TOP, 0, 58)
    searchBg:SetCenterColor(0.08, 0.08, 0.08, 0.95)
    searchBg:SetEdgeColor(0.91, 0.75, 0.36, 0.8)
    searchBg:SetEdgeTexture("", 1, 1, 1)
    searchBg:SetHidden(true)
    self.searchBg = searchBg

    local searchBox = WINDOW_MANAGER:CreateControl("KT_SearchBox", searchBg, CT_EDITBOX)
    searchBox:SetFont(FONT_SEARCH)
    searchBox:SetDimensions(480, 32)
    searchBox:SetAnchor(CENTER, searchBg, CENTER, 0, 0)
    searchBox:SetColor(1, 1, 1, 1)
    searchBox:SetMaxInputChars(50)
    searchBox:SetHandler("OnTextChanged", function(ctrl)
        self.searchText = ctrl:GetText() or ""
        self.scrollOffset = 0
        self.selectedIndex = 1
        self:RefreshList()
    end)
    searchBox:SetHandler("OnFocusLost", function()
        if not self.searchText or self.searchText == "" then
            self:CloseSearch()
        end
    end)
    self.searchBox = searchBox
end

function KT_UI:OpenSearch()
    if not self.searchBg then return end
    self.searchActive = true
    self.searchBg:SetHidden(false)
    self.searchBox:SetHidden(false)
    self.searchBox:SetText(self.searchText or "")
    self.searchBox:TakeFocus()
end

function KT_UI:CloseSearch()
    if not self.searchBg then return end
    self.searchActive = false
    self.searchText   = ""
    self.searchBg:SetHidden(true)
    if self.searchBox then
        self.searchBox:SetText("")
        self.searchBox:LoseFocus()
    end
    self.scrollOffset = 0
    self:RefreshList()
end

function KT_UI:ToggleSearch()
    if self.searchActive then
        self:CloseSearch()
    else
        self:OpenSearch()
    end
end

local function MatchesSearch(text, search)
    if not search or search == "" then return true end
    if not text then return false end
    return text:lower():find(search:lower(), 1, true) ~= nil
end

local function ParseSearchTokens(raw)
    local s = (raw or ""):lower()
    local filter = {
        text = "",
        completeOnly = false,
        incompleteOnly = false,
        motifNumber = nil,
        source = nil,
    }
    if s == "" then
        return filter
    end
    for token in s:gmatch("%S+") do
        if token == "+" then
            filter.completeOnly = true
        elseif token == "-" then
            filter.incompleteOnly = true
        elseif token:find("^motif:%d+$") then
            filter.motifNumber = tonumber(token:match("^motif:(%d+)$"))
        elseif token:find("^source:.+$") then
            filter.source = token:match("^source:(.+)$")
        else
            filter.text = (filter.text == "") and token or (filter.text .. " " .. token)
        end
    end
    return filter
end

-- ═══════════════════════════════════════════════════════════════════════════
-- LEGEND PANEL
-- ═══════════════════════════════════════════════════════════════════════════

local LEGEND_X          = 1190
local LEGEND_Y          = 60

function KT_UI:CreateDetailPanel()
    if not KT_Window then return end

    local titleLbl = WINDOW_MANAGER:CreateControl("KT_DetailTitle", KT_Window, CT_LABEL)
    titleLbl:SetFont(FONT_DETAIL_TITLE)
    titleLbl:SetColor(0.91, 0.75, 0.36, 1)
    titleLbl:SetAnchor(TOPLEFT, KT_Window, TOPLEFT, LEGEND_X, LEGEND_Y)
    titleLbl:SetDimensions(270, 24)
    titleLbl:SetText("MISSING PIECES")
    titleLbl:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    titleLbl:SetMouseEnabled(false)
    self.detailTitle = titleLbl

    local sep = WINDOW_MANAGER:CreateControl("KT_DetailSep", KT_Window, CT_TEXTURE)
    sep:SetColor(0.27, 0.27, 0.27, 1)
    sep:SetAnchor(TOPLEFT, KT_Window, TOPLEFT, LEGEND_X, LEGEND_Y + 26)
    sep:SetDimensions(240, 1)
    sep:SetMouseEnabled(false)
    self.detailSep = sep

    local body = WINDOW_MANAGER:CreateControl("KT_DetailBody", KT_Window, CT_LABEL)
    body:SetFont(FONT_DETAIL_BODY)
    body:SetColor(0.85, 0.85, 0.85, 1)
    body:SetAnchor(TOPLEFT, KT_Window, TOPLEFT, LEGEND_X, LEGEND_Y + 34)
    body:SetDimensions(270, 620)
    body:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    body:SetVerticalAlignment(TEXT_ALIGN_TOP)
    body:SetMouseEnabled(false)
    body:SetText("Select a row and press X.")
    self.detailBody = body
end

-- ═══════════════════════════════════════════════════════════════════════════
-- SCROLL CONTROLS
-- ═══════════════════════════════════════════════════════════════════════════

function KT_UI:SetupScrollControls()
    local listArea = GetChild("ListArea")
    if listArea then
        listArea:SetHandler("OnMouseWheel", function(_, delta)
            if delta > 0 then KT_UI:ScrollLineUp()
            else               KT_UI:ScrollLineDown()
            end
        end)
    end

    local upBtn = GetChild("ScrollUpBtn")
    if upBtn then
        upBtn:SetHandler("OnClicked", function() KT_UI:ScrollLineUp() end)
        local lbl = WINDOW_MANAGER:CreateControl("KT_ScrollUpLabel", upBtn, CT_LABEL)
        lbl:SetFont(FONT_SCROLL_BTN)
        lbl:SetText(COL_GOLD .. "^" .. COL_RESET)
        lbl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        lbl:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        lbl:SetAnchorFill()
        lbl:SetMouseEnabled(false)
    end

    local downBtn = GetChild("ScrollDownBtn")
    if downBtn then
        downBtn:SetHandler("OnClicked", function() KT_UI:ScrollLineDown() end)
        local lbl = WINDOW_MANAGER:CreateControl("KT_ScrollDownLabel", downBtn, CT_LABEL)
        lbl:SetFont(FONT_SCROLL_BTN)
        lbl:SetText(COL_GOLD .. "v" .. COL_RESET)
        lbl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        lbl:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        lbl:SetAnchorFill()
        lbl:SetMouseEnabled(false)
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- COLUMN HEADERS
-- ═══════════════════════════════════════════════════════════════════════════

function KT_UI:RefreshColumnHeaders()
    local colName   = GetChild("ColName")
    local colDetail = GetChild("ColDetail")
    if colName then colName:SetText(KT_Locale.L("COL_NAME")) end
    if colDetail then
        colDetail:SetHidden(false)
        if self.currentTab == "undaunted" then
            colDetail:SetText("PIECES")
        else
            colDetail:SetText(KT_Locale.L("COL_CHAPTERS"))
        end
    end

    if self.dotHeadersCreated then
        for i = 1, NUM_CHAPTERS do
            local dotHeader = _G["KT_DotHead" .. i]
            if dotHeader then dotHeader:SetHidden(true) end
        end
    end
end

local FONT_DOT_HEADER = "$(BOLD_FONT)|14|soft-shadow-thin"

function KT_UI:CreateDotColumnHeaders()
    if not KT_Window then return end
    local listOffsetX = 20
    local headerY = 62

    for i = 1, NUM_CHAPTERS do
        local xOff = listOffsetX + DOT_START_X + (i - 1) * DOT_SPACING
        local lbl = WINDOW_MANAGER:CreateControl("KT_DotHead" .. i, KT_Window, CT_LABEL)
        lbl:SetFont(FONT_DOT_HEADER)
        lbl:SetColor(0.67, 0.67, 0.55, 1)
        lbl:SetAnchor(TOPLEFT, KT_Window, TOPLEFT, xOff, headerY)
        lbl:SetDimensions(DOT_SPACING, 20)
        lbl:SetText(tostring(i))
        lbl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        lbl:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        lbl:SetMouseEnabled(false)
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- KEYBIND STRIP
-- ═══════════════════════════════════════════════════════════════════════════

function KT_UI:BuildKeybindStrip()
    self.keybindStripDescriptor = {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        {
            keybind  = "UI_SHORTCUT_NEGATIVE",
            name     = GetString(SI_GAMEPAD_BACK_OPTION),
            callback = function() SCENE_MANAGER:HideCurrentScene() end,
            sound    = SOUNDS.GAMEPAD_MENU_BACK,
        },
        {
            keybind  = "UI_SHORTCUT_PRIMARY",
            name     = function()
                if KT_UI.showMissingDetails then
                    return "Hide Missing"
                end
                return "Show Missing"
            end,
            callback = function()
                KT_UI.showMissingDetails = not KT_UI.showMissingDetails
                KT_UI:RefreshList()
            end,
        },
        {
            keybind  = "UI_SHORTCUT_TERTIARY",
            name     = function()
                if KT_UI.currentTab == "undaunted" then
                    return "Tab: Undaunted"
                end
                return "Tab: Motifs"
            end,
            callback = function()
                KT_UI:SwitchTab()
            end,
        },
        {
            keybind  = "UI_SHORTCUT_LEFT_TRIGGER",
            name     = KT_Locale.L("KB_SCROLL_UP"),
            callback = function() KT_UI:ScrollPageUp() end,
        },
        {
            keybind  = "UI_SHORTCUT_RIGHT_TRIGGER",
            name     = KT_Locale.L("KB_SCROLL_DOWN"),
            callback = function() KT_UI:ScrollPageDown() end,
        },
        {
            keybind  = "UI_SHORTCUT_SECONDARY",
            name     = KT_Locale.L("KB_SEARCH"),
            callback = function()
                KT_UI:ToggleSearch()
            end,
        },
        {
            keybind  = "UI_SHORTCUT_LEFT_SHOULDER",
            name     = KT_Locale.L("KB_NEXT_CHAR"),
            callback = function()
                KT:CycleViewedCharacter(1)
                KT_UI.scrollOffset = 0
                KT_UI.selectedIndex = 1
                KT_UI.showMissingDetails = false
                KT_UI:RefreshList()
            end,
        },
        {
            keybind  = "UI_SHORTCUT_RIGHT_SHOULDER",
            name     = KT_Locale.L("KB_PREV_CHAR"),
            callback = function()
                KT:CycleViewedCharacter(-1)
                KT_UI.scrollOffset = 0
                KT_UI.selectedIndex = 1
                KT_UI.showMissingDetails = false
                KT_UI:RefreshList()
            end,
        },
    }
end

-- ═══════════════════════════════════════════════════════════════════════════
-- SCENE SETUP
-- ═══════════════════════════════════════════════════════════════════════════

function KT_UI:SetupScene()
    if not KT_Window then return end

    local windowFragment = ZO_SimpleSceneFragment:New(KT_Window)
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
            KT:EnsureViewedCharacter()
            local nowMs = (type(GetFrameTimeMilliseconds) == "function" and GetFrameTimeMilliseconds()) or 0
            local lastScanAtMs = KT.lastScanAtMs or 0
            local shouldRescan = (not KT.scanDone) or (not KT:GetMotifs() or #KT:GetMotifs() == 0) or ((nowMs - lastScanAtMs) >= 5000)
            if shouldRescan then
                KT:ScanAll()
            end

            self.scrollOffset = 0
            self.visible      = true
            self.selectedIndex = 1
            self.showMissingDetails = false
            self.stickRepeatAtMs = 0

            if self.searchActive then self:CloseSearch() end

            KEYBIND_STRIP:AddKeybindButtonGroup(self.keybindStripDescriptor)

            self:RefreshColumnHeaders()
            self:RefreshList()
            self:UpdateWatermark()
            self:RegisterInTrackingToolsHub()
            EVENT_MANAGER:RegisterForUpdate("KT_UI_StickPoll", 30, function()
                KT_UI:HandleLeftStickSelection()
            end)

        elseif newState == SCENE_HIDDEN then
            self.visible = false
            if self.searchActive then self:CloseSearch() end
            KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindStripDescriptor)
            EVENT_MANAGER:UnregisterForUpdate("KT_UI_StickPoll")
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- TRACKING TOOLS HUB INTEGRATION
-- ═══════════════════════════════════════════════════════════════════════════

function KT_UI:RegisterInTrackingToolsHub()
    if ELDIBABALO_TRACKING_TOOLS and ELDIBABALO_TRACKING_TOOLS.Register then
        ELDIBABALO_TRACKING_TOOLS:Register(
            KT_Locale.L("MENU_ENTRY"),
            "EsoUI/Art/Crafting/smithing_tabicon_research_up.dds",
            self.sceneName
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

-- ═══════════════════════════════════════════════════════════════════════════
-- WATERMARK
-- ═══════════════════════════════════════════════════════════════════════════

function KT_UI:UpdateWatermark()
    local playerLabel = GetChild("FooterPlayer")
    if not playerLabel then return end
    local displayName = GetDisplayName and GetDisplayName() or ""
    local ts = GetTimeStamp and GetTimeStamp() or 0
    local secInDay = ts % 86400
    local hours   = math.floor(secInDay / 3600)
    local minutes = math.floor((secInDay % 3600) / 60)
    local days = math.floor(ts / 86400)
    local y = 1970 local m = 1 local d = 1
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
    d = daysLeft + 1
    local dateStr = string.format("%02d/%02d/%04d", d, m, y)
    local timeStr = string.format("%02d:%02d", hours, minutes)
    playerLabel:SetText("|c888888" .. displayName .. "  " .. dateStr .. "  " .. timeStr .. "|r")
end

-- ═══════════════════════════════════════════════════════════════════════════
-- INITIALIZATION
-- ═══════════════════════════════════════════════════════════════════════════

function KT_UI:Initialize()
    if self.initialized then return end

    KT_Locale.Init()

    self:CreateRowPool()
    self:CreateSearchUI()
    self:CreateDetailPanel()
    self:SetupScrollControls()
    self:SetupScene()

    local titleLabel = GetChild("Title")
    if titleLabel then titleLabel:SetText(KT_Locale.L("TITLE")) end

    -- Hide unused tab buttons
    local tab1 = GetChild("TabBtn1")
    local tab2 = GetChild("TabBtn2")
    local tab3 = GetChild("TabBtn3")
    if tab1 then tab1:SetHidden(true) end
    if tab2 then tab2:SetHidden(true) end
    if tab3 then tab3:SetHidden(true) end

    self:UpdateWatermark()
    self.initialized = true
end

function KT_UI:LateInit()
    self:RegisterInTrackingToolsHub()
end

-- ═══════════════════════════════════════════════════════════════════════════
-- SHOW / HIDE / TOGGLE
-- ═══════════════════════════════════════════════════════════════════════════

function KT_UI:Show()
    if not KT_Window then return end
    self:Initialize()
    SCENE_MANAGER:Show(self.sceneName)
end

function KT_UI:Hide()
    if SCENE_MANAGER:IsShowing(self.sceneName) then
        SCENE_MANAGER:HideCurrentScene()
    end
    self.visible = false
end

function KT_UI:Toggle()
    if not KT_Window then return end
    self:Initialize()
    if SCENE_MANAGER:IsShowing(self.sceneName) then
        SCENE_MANAGER:HideCurrentScene()
    else
        SCENE_MANAGER:Show(self.sceneName)
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- DISPLAY LIST BUILDER
-- ═══════════════════════════════════════════════════════════════════════════

function KT_UI:BuildDisplayList()
    self.displayList = {}
    local motifs = (self.currentTab == "undaunted") and (KT:GetUndaunted() or {}) or (KT:GetMotifs() or {})
    local filter = ParseSearchTokens(self.searchText or "")

    if self.currentTab == "undaunted" and #motifs == 0 and KT_Data:IsUndauntedScanRunning() then
        table.insert(self.displayList, {
            name = "Loading Undaunted styles...",
            rawName = "Loading",
            detail = "...",
            complete = false,
            chaptersKnown = 0,
            totalChapters = 0,
            chapters = {},
            source = "",
            motifNumber = 99999,
            isUndaunted = true,
        })
        return
    end

    for _, m in ipairs(motifs) do
        local displayName
        if self.currentTab == "motifs" and m.motifNumber then
            displayName = m.motifNumber .. ". " .. m.name
            if m.source then
                displayName = displayName .. "  |c888888" .. m.source .. "|r"
            end
        else
            displayName = m.name
            if m.source then
                displayName = displayName .. "  |c888888" .. m.source .. "|r"
            end
        end

        local passText =
            MatchesSearch(m.name, filter.text)
            or (m.source and MatchesSearch(m.source, filter.text))
            or (m.motifNumber and MatchesSearch(tostring(m.motifNumber), filter.text))
        local passComplete =
            (not filter.completeOnly or m.complete == true)
            and (not filter.incompleteOnly or m.complete ~= true)
        local passMotif = (self.currentTab ~= "motifs") or (not filter.motifNumber) or (tonumber(m.motifNumber) == filter.motifNumber)
        local passSource = (not filter.source) or (m.source and MatchesSearch(m.source, filter.source))
        if passText and passComplete and passMotif and passSource then
            local detail = m.chaptersKnown .. "/" .. m.totalChapters
            table.insert(self.displayList, {
                name          = displayName,
                rawName       = m.name,
                detail        = detail,
                complete      = m.complete,
                chaptersKnown = m.chaptersKnown,
                totalChapters = m.totalChapters,
                chapters      = m.chapters,
                source        = m.source or "",
                motifNumber   = tonumber(m.motifNumber) or 99999,
                isUndaunted   = m.isUndaunted == true,
            })
        end
    end
end

function KT_UI:SwitchTab()
    if self.currentTab == "motifs" then
        self.currentTab = "undaunted"
        KT:EnsureUndaunted(false, function()
            if KT_UI.visible and KT_UI.currentTab == "undaunted" then
                KT_UI:RefreshList()
            end
        end)
    else
        self.currentTab = "motifs"
    end
    self.scrollOffset = 0
    self.selectedIndex = 1
    self.showMissingDetails = false
    self:RefreshColumnHeaders()
    self:RefreshList()
    if KEYBIND_STRIP and self.keybindStripDescriptor then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)
    end
end

function KT_UI:GetSelectedItem()
    if self.selectedIndex < 1 or self.selectedIndex > #self.displayList then
        return nil
    end
    return self.displayList[self.selectedIndex]
end

function KT_UI:MoveSelection(delta)
    if #self.displayList == 0 then return end
    local idx = self.selectedIndex or 1
    idx = zo_clamp(idx + delta, 1, #self.displayList)
    self.selectedIndex = idx
    if idx <= self.scrollOffset then
        self.scrollOffset = idx - 1
    elseif idx > (self.scrollOffset + MAX_VISIBLE_ROWS) then
        self.scrollOffset = idx - MAX_VISIBLE_ROWS
    end
    self:RefreshList()
end

function KT_UI:HandleLeftStickSelection()
    if not self.visible or self.searchActive then return end
    local y = (GetGamepadLeftStickY and GetGamepadLeftStickY()) or 0
    local threshold = 0.55
    local now = (GetFrameTimeMilliseconds and GetFrameTimeMilliseconds()) or 0
    if math.abs(y) < threshold then
        self.stickRepeatAtMs = 0
        return
    end
    if now < (self.stickRepeatAtMs or 0) then
        return
    end
    if y < 0 then
        self:MoveSelection(1)
    else
        self:MoveSelection(-1)
    end
    self.stickRepeatAtMs = now + 100
end

function KT_UI:UpdateDetailPanel(item)
    if not self.detailBody or not self.detailTitle then return end
    if not item then
        self.detailTitle:SetText("MISSING PIECES")
        self.detailBody:SetText("No motif selected.")
        return
    end
    if item.rawName == "Loading" then
        self.detailTitle:SetText("UNDAUNTED")
        self.detailBody:SetText("Scanning collectibles...\nPlease wait.")
        return
    end
    local motifLabel = item.rawName or item.name or "Entry"
    if item.isUndaunted then
        self.detailTitle:SetText("UNDAUNTED - " .. motifLabel)
    else
        self.detailTitle:SetText("MISSING - " .. motifLabel)
    end
    if not self.showMissingDetails then
        local sourceText = item.source and item.source ~= "" and item.source or "Unknown source"
        self.detailBody:SetText("Press X to show missing pieces.\n\nDrop: " .. sourceText)
        return
    end
    if (item.totalChapters or 0) <= 1 then
        if (item.chaptersKnown or 0) >= 1 then
            self.detailBody:SetText("Complete.")
        else
            self.detailBody:SetText("This entry is currently tracked as a book-level motif in library data.")
        end
        return
    end
    local missing = {}
    for i = 1, (item.totalChapters or 0) do
        local chapter = item.chapters and item.chapters[i]
        if not (chapter and chapter.known) then
            if item.isUndaunted then
                if i == 1 then
                    table.insert(missing, "Head")
                else
                    table.insert(missing, "Shoulders")
                end
            else
                table.insert(missing, SLOT_NAMES[i] or ("Chapter " .. tostring(i)))
            end
        end
    end
    if #missing == 0 then
        local sourceText = item.source and item.source ~= "" and item.source or "Unknown source"
        self.detailBody:SetText("Complete.\n\nDrop: " .. sourceText)
        return
    end
    local sourceText = item.source and item.source ~= "" and item.source or "Unknown source"
    self.detailBody:SetText(table.concat(missing, "\n") .. "\n\nDrop: " .. sourceText)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- REFRESH LIST
-- ═══════════════════════════════════════════════════════════════════════════

function KT_UI:RefreshList()
    self:BuildDisplayList()

    if #self.displayList <= 0 then
        self.selectedIndex = 0
    else
        if self.selectedIndex < 1 then self.selectedIndex = 1 end
        if self.selectedIndex > #self.displayList then self.selectedIndex = #self.displayList end
    end

    local maxOff = self:GetMaxOffset()
    if self.scrollOffset > maxOff then
        self.scrollOffset = maxOff
    end

    for i = 1, MAX_VISIBLE_ROWS do
        local dataIndex = self.scrollOffset + i
        local item = self.displayList[dataIndex]
        local slot = self.rowPool[i]
        if not slot then break end

        if item then
            slot.control:SetHidden(false)
            if slot.highlight then
                slot.highlight:SetHidden(dataIndex ~= self.selectedIndex)
            end

            slot.nameLabel:SetText("  " .. item.name)

            if item.chaptersKnown >= item.totalChapters then
                slot.detailLabel:SetText(COL_GREEN .. item.detail .. COL_RESET)
            elseif item.chaptersKnown > 0 then
                slot.detailLabel:SetText(COL_YELLOW .. item.detail .. COL_RESET)
            else
                slot.detailLabel:SetText(COL_RED .. item.detail .. COL_RESET)
            end

            for j = 1, NUM_CHAPTERS do
                local dot = slot.dots[j]
                if dot then
                    dot:SetHidden(true)
                end
            end
        else
            slot.control:SetHidden(true)
        end
    end

    self:UpdateDetailPanel(self:GetSelectedItem())
    self:UpdateFooter()
end

-- ═══════════════════════════════════════════════════════════════════════════
-- SCROLLING
-- ═══════════════════════════════════════════════════════════════════════════

function KT_UI:GetMaxOffset()
    return math.max(0, #self.displayList - MAX_VISIBLE_ROWS)
end

function KT_UI:ScrollLineUp()
    self:MoveSelection(-1)
end

function KT_UI:ScrollLineDown()
    self:MoveSelection(1)
end

function KT_UI:ScrollPageUp()
    self.scrollOffset = math.max(0, self.scrollOffset - MAX_VISIBLE_ROWS)
    self.selectedIndex = zo_clamp(self.scrollOffset + 1, 1, math.max(1, #self.displayList))
    self:RefreshList()
end

function KT_UI:ScrollPageDown()
    self.scrollOffset = math.min(self:GetMaxOffset(), self.scrollOffset + MAX_VISIBLE_ROWS)
    self.selectedIndex = zo_clamp(self.scrollOffset + 1, 1, math.max(1, #self.displayList))
    self:RefreshList()
end

function KT_UI:KeyScrollUp()   if self.visible then self:ScrollLineUp()   end end
function KT_UI:KeyScrollDown()  if self.visible then self:ScrollLineDown() end end

-- ═══════════════════════════════════════════════════════════════════════════
-- FOOTER
-- ═══════════════════════════════════════════════════════════════════════════

function KT_UI:UpdateFooter()
    local label = GetChild("FooterStats")
    if not label then return end

    local motifs = (self.currentTab == "undaunted") and (KT:GetUndaunted() or {}) or (KT:GetMotifs() or {})
    local complete, total, chapKnown, chapTotal = KT_Data:CountMotifs(motifs)
    local pct = (chapTotal > 0) and math.floor(chapKnown / chapTotal * 100) or 0
    local rightLabel = (self.currentTab == "undaunted") and "PIECES" or KT_Locale.L("COL_CHAPTERS")
    label:SetText(
        KT_Locale.L("FOOTER_COMPLETE") .. ": " ..
        COL_GOLD .. complete .. COL_RESET .. "/" .. total ..
        "   |   " ..
        rightLabel .. ": " ..
        COL_GOLD .. chapKnown .. COL_RESET .. "/" .. chapTotal ..
        " (" .. pct .. "%)" ..
        "   |   Char: " .. (KT.GetViewedCharacterName and KT:GetViewedCharacterName() or "Current") ..
        "   |   Tab: " .. ((self.currentTab == "undaunted") and "Undaunted" or "Motifs")
    )
end
