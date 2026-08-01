-- =============================================================================
-- Trial & Arena Tracker — UI Logic v1.2.2
-- 2 tabs: Trials, Arenas.
-- Uses ZO_Scene with FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW for native
-- console gamepad input (keybind strip, virtual cursor, action layer).
-- Integrates into the Journal submenu in the gamepad main menu.
-- =============================================================================

TAT_UI = {}

-- ---------------------------------------------------------------------------
-- Layout constants
-- ---------------------------------------------------------------------------
local MAX_VISIBLE_ROWS = 28
local ROW_HEIGHT       = 24

-- ---------------------------------------------------------------------------
-- Custom fonts with explicit pixel sizes for TV readability
-- ---------------------------------------------------------------------------
local FONT_ROW_NAME    = "$(MEDIUM_FONT)|24|soft-shadow-thin"
local FONT_ROW_STATUS  = "$(BOLD_FONT)|24|soft-shadow-thin"
local FONT_ROW_HEADER  = "$(BOLD_FONT)|24|soft-shadow-thin"
local FONT_SCROLL_BTN  = "$(BOLD_FONT)|28|soft-shadow-thick"

-- ---------------------------------------------------------------------------
-- Colour helpers
-- ---------------------------------------------------------------------------
local COL_GREEN  = "|c4CAF50"
local COL_RED    = "|cE53935"
local COL_GRAY   = "|c555555"
local COL_GOLD   = "|cE8C05C"
local COL_RESET  = "|r"

-- ---------------------------------------------------------------------------
-- Status symbols
-- ---------------------------------------------------------------------------
local STATUS_COMPLETE   = COL_GREEN .. "●"  .. COL_RESET
local STATUS_INCOMPLETE = COL_RED   .. "●"  .. COL_RESET
local STATUS_NA         = COL_GRAY  .. "—"  .. COL_RESET

-- ---------------------------------------------------------------------------
-- State
-- ---------------------------------------------------------------------------
TAT_UI.visible       = false
TAT_UI.activeTab     = "trials"
TAT_UI.scrollOffset  = 0
TAT_UI.displayList   = {}
TAT_UI.displayListDirty = true
TAT_UI.rowPool       = {}
TAT_UI.initialized   = false
TAT_UI.listParent    = nil
TAT_UI.sceneName     = "tatScene"
TAT_UI.menuAdded     = false
TAT_UI.perf          = { enabled = false, counters = {}, max = {} }

-- ═══════════════════════════════════════════════════════════════════════════
-- CONTROL LOOKUP
-- ═══════════════════════════════════════════════════════════════════════════

local function GetChild(name)
    if not TAT_Window then return nil end
    return TAT_Window:GetNamedChild(name)
end

function TAT_UI:PerfCount(key, delta)
    if not self.perf or not self.perf.enabled then return end
    self.perf.counters[key] = (self.perf.counters[key] or 0) + (delta or 1)
end

function TAT_UI:PerfMax(key, value)
    if not self.perf or not self.perf.enabled then return end
    local current = self.perf.max[key]
    if current == nil or value > current then
        self.perf.max[key] = value
    end
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

function TAT_UI:CreateRowPool()
    self.listParent = GetChild("ListArea")
    if not self.listParent and TAT_Window then
        self.listParent = WINDOW_MANAGER:CreateControl(
            "TAT_ListAreaFallback", TAT_Window, CT_CONTROL)
        self.listParent:SetAnchor(TOPLEFT, TAT_Window, TOPLEFT, 20, 108)
        self.listParent:SetDimensions(1160, MAX_VISIBLE_ROWS * ROW_HEIGHT)
    end
    if not self.listParent then return end

    local pw = self.listParent:GetWidth()
    if pw <= 0 then pw = 1160 end
    self.rowPool = {}

    for i = 1, MAX_VISIBLE_ROWS do
        local yOff   = (i - 1) * ROW_HEIGHT
        local prefix = "TAT_Slot" .. i
        local row = WINDOW_MANAGER:CreateControl(prefix, self.listParent, CT_CONTROL)
        row:SetDimensions(pw, ROW_HEIGHT)
        row:SetAnchor(TOPLEFT, self.listParent, TOPLEFT, 0, yOff)
        row:SetMouseEnabled(false)

        local nameLabel = MakeLabel(prefix .. "N", row, FONT_ROW_NAME, 8, 470)
        nameLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        local vetLabel = MakeLabel(prefix .. "V", row, FONT_ROW_STATUS, 490, 120)
        local hmLabel  = MakeLabel(prefix .. "H", row, FONT_ROW_STATUS, 610, 110)
        local spdLabel = MakeLabel(prefix .. "S", row, FONT_ROW_STATUS, 720, 110)
        local ndLabel  = MakeLabel(prefix .. "D", row, FONT_ROW_STATUS, 830, 110)
        local triLabel = MakeLabel(prefix .. "T", row, FONT_ROW_STATUS, 940, 110)
        vetLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        hmLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        spdLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        ndLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        triLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

        self.rowPool[i] = {
            control   = row,
            nameLabel = nameLabel,
            vetLabel  = vetLabel,
            hmLabel   = hmLabel,
            spdLabel  = spdLabel,
            ndLabel   = ndLabel,
            triLabel  = triLabel,
        }
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- SCROLL CONTROLS
-- ═══════════════════════════════════════════════════════════════════════════

function TAT_UI:SetupScrollControls()
    local listArea = GetChild("ListArea")
    if listArea then
        listArea:SetHandler("OnMouseWheel", function(_, delta)
            if delta > 0 then
                TAT_UI:ScrollLineUp()
            else
                TAT_UI:ScrollLineDown()
            end
        end)
    end

    local upBtn = GetChild("ScrollUpBtn")
    if upBtn then
        upBtn:SetHandler("OnClicked", function() TAT_UI:ScrollLineUp() end)
        local upLabel = WINDOW_MANAGER:CreateControl("TAT_ScrollUpLabel", upBtn, CT_LABEL)
        upLabel:SetFont(FONT_SCROLL_BTN)
        upLabel:SetText(COL_GOLD .. "^" .. COL_RESET)
        upLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        upLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        upLabel:SetAnchorFill()
        upLabel:SetMouseEnabled(false)
    end

    local downBtn = GetChild("ScrollDownBtn")
    if downBtn then
        downBtn:SetHandler("OnClicked", function() TAT_UI:ScrollLineDown() end)
        local downLabel = WINDOW_MANAGER:CreateControl("TAT_ScrollDownLabel", downBtn, CT_LABEL)
        downLabel:SetFont(FONT_SCROLL_BTN)
        downLabel:SetText(COL_GOLD .. "v" .. COL_RESET)
        downLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        downLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        downLabel:SetAnchorFill()
        downLabel:SetMouseEnabled(false)
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- TAB BUTTONS
-- ═══════════════════════════════════════════════════════════════════════════

TAT_UI.tabButtons = {}

function TAT_UI:SetupTabButtons()
    local tabDefs = {
        { btn = "TabBtn1", tab = "trials", label = TAT_Locale.L("TAB_TRIALS") },
        { btn = "TabBtn2", tab = "arenas", label = TAT_Locale.L("TAB_ARENAS") },
    }

    for _, def in ipairs(tabDefs) do
        local btn = GetChild(def.btn)
        if btn then
            local tabId = def.tab
            btn:SetHandler("OnClicked", function()
                TAT_UI:SetActiveTab(tabId)
            end)

            local lbl = WINDOW_MANAGER:CreateControl(
                "TAT_" .. def.btn .. "Label", btn, CT_LABEL)
            lbl:SetFont("$(BOLD_FONT)|22|soft-shadow-thick")
            lbl:SetText(def.label)
            lbl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            lbl:SetVerticalAlignment(TEXT_ALIGN_CENTER)
            lbl:SetAnchorFill()
            lbl:SetMouseEnabled(false)

            self.tabButtons[tabId] = { button = btn, label = lbl, text = def.label }
        end
    end
end

function TAT_UI:RefreshTabButtons()
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
-- KEYBIND STRIP
-- ═══════════════════════════════════════════════════════════════════════════

function TAT_UI:BuildKeybindStrip()
    self.keybindStripDescriptor = {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        {
            keybind  = "UI_SHORTCUT_NEGATIVE",
            name     = GetString(SI_GAMEPAD_BACK_OPTION),
            callback = function()
                SCENE_MANAGER:HideCurrentScene()
            end,
            sound = SOUNDS.GAMEPAD_MENU_BACK,
        },
        {
            keybind  = "UI_SHORTCUT_LEFT_SHOULDER",
            name     = TAT_Locale.L("KB_PREV_TAB"),
            callback = function()
                TAT_UI:PrevTab()
            end,
        },
        {
            keybind  = "UI_SHORTCUT_RIGHT_SHOULDER",
            name     = TAT_Locale.L("KB_NEXT_TAB"),
            callback = function()
                TAT_UI:NextTab()
            end,
        },
        {
            keybind  = "UI_SHORTCUT_LEFT_TRIGGER",
            name     = TAT_Locale.L("KB_SCROLL_UP"),
            callback = function()
                TAT_UI:ScrollPageUp()
            end,
        },
        {
            keybind  = "UI_SHORTCUT_RIGHT_TRIGGER",
            name     = TAT_Locale.L("KB_SCROLL_DOWN"),
            callback = function()
                TAT_UI:ScrollPageDown()
            end,
        },
    }
end

-- ═══════════════════════════════════════════════════════════════════════════
-- SCENE SETUP
-- ═══════════════════════════════════════════════════════════════════════════

function TAT_UI:SetupScene()
    if not TAT_Window then return end

    local windowFragment = ZO_SimpleSceneFragment:New(TAT_Window)
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
            -- Rebuild localized name map (needs achievement data from after player load)
            TAT_Locale.RebuildNameMap()

            -- Re-scan achievements every time the tracker opens (ensures fresh data)
            TAT:ScanAchievements()

            local savedTab = TAT.savedVars and TAT.savedVars.activeTab
            local validTabs = { trials = true, arenas = true }
            if not savedTab or not validTabs[savedTab] then
                savedTab = "trials"
            end
            self.activeTab    = savedTab
            self.scrollOffset = 0
            self.visible      = true
            self.displayListDirty = true

            KEYBIND_STRIP:AddKeybindButtonGroup(self.keybindStripDescriptor)

            self:UpdateColumnHeaders()
            self:RefreshTabs()
            self:RefreshList()
            self:UpdateWatermark()

        elseif newState == SCENE_HIDDEN then
            self.visible = false
            KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindStripDescriptor)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- COLUMN HEADERS (all columns always visible)
-- ═══════════════════════════════════════════════════════════════════════════

function TAT_UI:UpdateColumnHeaders()
    -- All columns visible for both tabs (trials have SR/ND too)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- TRACKING TOOLS HUB (shared across Eldibabalo addons, created once)
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
            hl:SetColor(0.91, 0.75, 0.36, 0.08)
            hl:SetAnchorFill()
            hl:SetHidden(true)

            local selHL = WINDOW_MANAGER:CreateControl(pf .. "SHL", row, CT_TEXTURE)
            selHL:SetColor(0.91, 0.75, 0.36, 0.22)
            selHL:SetAnchorFill()
            selHL:SetHidden(true)

            row:SetHandler("OnMouseEnter", function() hl:SetHidden(false) end)
            row:SetHandler("OnMouseExit", function() hl:SetHidden(true) end)
            local idx = i
            row:SetHandler("OnMouseUp", function(_, button)
                if button == MOUSE_BUTTON_INDEX_LEFT then
                    TT.selectedRow = idx
                    TT:OpenSelected()
                end
            end)

            local ic = WINDOW_MANAGER:CreateControl(pf .. "IC", row, CT_TEXTURE)
            ic:SetDimensions(40, 40)
            ic:SetAnchor(LEFT, row, LEFT, 20, 0)

            local lb = WINDOW_MANAGER:CreateControl(pf .. "LB", row, CT_LABEL)
            lb:SetFont("$(BOLD_FONT)|28|soft-shadow-thin")
            lb:SetColor(1, 1, 1, 1)
            lb:SetAnchor(LEFT, ic, RIGHT, 16, 0)
            lb:SetDimensions(900, ROW_H)
            lb:SetVerticalAlignment(TEXT_ALIGN_CENTER)

            TT.rows[i] = { control = row, highlight = hl, selectHL = selHL, icon = ic, label = lb }
        end

        function TT:Register(name, iconPath, scene)
            for _, e in ipairs(self.entries) do
                if e.scene == scene then return end
            end
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
                    slot.control:SetHidden(true)
                    slot.selectHL:SetHidden(true)
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
                    local okRead, value = pcall(reader)
                    if okRead and type(value) == "number" then
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
                TT.selectedRow = 1
                TT:RefreshList()
                KEYBIND_STRIP:AddKeybindButtonGroup(kb)
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
        hubEntry.id = 950

        local function PlaceHubEntry()
            if not ZO_MENU_ENTRIES then return end
            for i = #ZO_MENU_ENTRIES, 1, -1 do
                local e = ZO_MENU_ENTRIES[i]
                local scene = e and e.data and e.data.scene
                if (e and e.id == 950) or scene == TT.sceneName then
                    table.remove(ZO_MENU_ENTRIES, i)
                end
            end

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
        end

        PlaceHubEntry()
        zo_callLater(PlaceHubEntry, 2500)
        if MAIN_MENU_GAMEPAD then
            MAIN_MENU_GAMEPAD:RefreshLists()
            MAIN_MENU_GAMEPAD:UpdateEntryEnabledStates()
        end

        ELDIBABALO_TRACKING_TOOLS = TT
    end)

    return ok and ELDIBABALO_TRACKING_TOOLS ~= nil
end

-- ═══════════════════════════════════════════════════════════════════════════
-- MENU INTEGRATION (Tracking Tools hub, fallback to Journal submenu)
-- ═══════════════════════════════════════════════════════════════════════════

function TAT_UI:AddToMainMenu()
    if self.menuAdded then return end
    if not ZO_MENU_ENTRIES or not ZO_MENU_MAIN_ENTRIES then return end

    local hubOk = EnsureTrackingToolsHub()
    if hubOk and ELDIBABALO_TRACKING_TOOLS then
        ELDIBABALO_TRACKING_TOOLS:Register(TAT_Locale.L("MENU_ENTRY"),
            "EsoUI/Art/TreeIcons/Gamepad/gp_tutorial_idexIcon_combat.dds", self.sceneName)
        self.menuAdded = true
        return
    end

    local menuData = {
        name  = TAT_Locale.L("MENU_ENTRY"),
        icon  = "EsoUI/Art/TreeIcons/Gamepad/gp_tutorial_idexIcon_combat.dds",
        scene = self.sceneName,
    }

    local entry = ZO_GamepadEntryData:New(menuData.name, menuData.icon)
    entry:SetIconTintOnSelection(true)
    entry:SetIconDisabledTintOnSelection(true)
    entry.data = menuData
    entry.id   = 996

    local journalEntry = nil
    for _, v in ipairs(ZO_MENU_ENTRIES) do
        if v.id == ZO_MENU_MAIN_ENTRIES.JOURNAL then
            journalEntry = v
            break
        end
    end

    if journalEntry and journalEntry.subMenu then
        table.insert(journalEntry.subMenu, entry)
    else
        table.insert(ZO_MENU_ENTRIES, entry)
    end

    if MAIN_MENU_GAMEPAD then
        MAIN_MENU_GAMEPAD:RefreshLists()
        MAIN_MENU_GAMEPAD:UpdateEntryEnabledStates()
    end

    self.menuAdded = true
end

-- ═══════════════════════════════════════════════════════════════════════════
-- WATERMARK (player name + date/time)
-- ═══════════════════════════════════════════════════════════════════════════

function TAT_UI:UpdateWatermark()
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

function TAT_UI:Initialize()
    if self.initialized then return end

    TAT_Locale.Init()

    self:CreateRowPool()
    self:SetupScrollControls()
    self:SetupTabButtons()
    self:SetupScene()

    -- Override XML title with localized string
    local titleLabel = GetChild("Title")
    if titleLabel then titleLabel:SetText(TAT_Locale.L("TITLE")) end

    -- Player name watermark (updated each time scene shows)
    self:UpdateWatermark()

    self.initialized = true
end

function TAT_UI:LateInit()
    self:AddToMainMenu()
end

-- ═══════════════════════════════════════════════════════════════════════════
-- SHOW / HIDE
-- ═══════════════════════════════════════════════════════════════════════════

function TAT_UI:Show()
    if not TAT_Window then return end
    self:Initialize()
    SCENE_MANAGER:Show(self.sceneName)
end

function TAT_UI:Hide()
    if SCENE_MANAGER:IsShowing(self.sceneName) then
        SCENE_MANAGER:HideCurrentScene()
    end
    self.visible = false
end

function TAT_UI:Toggle()
    if not TAT_Window then return end
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

local TAB_ORDER = { "trials", "arenas" }

function TAT_UI:SetActiveTab(tab)
    self.activeTab    = tab
    self.scrollOffset = 0
    self.displayListDirty = true
    if TAT.savedVars then TAT.savedVars.activeTab = tab end
    self:UpdateColumnHeaders()
    self:RefreshTabs()
    self:RefreshList()
end

function TAT_UI:NextTab()
    for i, t in ipairs(TAB_ORDER) do
        if t == self.activeTab then
            local next = TAB_ORDER[(i % #TAB_ORDER) + 1]
            self:SetActiveTab(next)
            return
        end
    end
end

function TAT_UI:PrevTab()
    for i, t in ipairs(TAB_ORDER) do
        if t == self.activeTab then
            local prev = TAB_ORDER[((i - 2) % #TAB_ORDER) + 1]
            self:SetActiveTab(prev)
            return
        end
    end
end

function TAT_UI:RefreshTabs()
    self:RefreshTabButtons()
end

function TAT_UI:KeyNextTab() self:NextTab() end
function TAT_UI:KeyPrevTab() self:PrevTab() end

-- ═══════════════════════════════════════════════════════════════════════════
-- DISPLAY LIST
-- ═══════════════════════════════════════════════════════════════════════════

function TAT_UI:BuildDisplayList()
    self:PerfCount("display_list_rebuilds", 1)
    self.displayList = {}

    local contentType, groupOrder

    if self.activeTab == "trials" then
        contentType = TAT_Data.CONTENT_TRIAL
        groupOrder  = TAT_Data.TrialGroupOrder
    else
        contentType = TAT_Data.CONTENT_ARENA
        groupOrder  = TAT_Data.ArenaGroupOrder
    end

    local contentList = TAT:GetContentList(contentType)
    local grouped = {}
    for _, entry in ipairs(contentList) do
        if not grouped[entry.group] then grouped[entry.group] = {} end
        table.insert(grouped[entry.group], entry)
    end

    for _, groupName in ipairs(groupOrder) do
        local items = grouped[groupName]
        if items and #items > 0 then
            local localizedGroup = TAT_Locale.GetLocalizedGroup(groupName)
            table.insert(self.displayList, { type = "header", text = localizedGroup })
            for _, entry in ipairs(items) do
                table.insert(self.displayList, { type = "content", data = entry })
            end
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- STATUS TEXT
-- ═══════════════════════════════════════════════════════════════════════════

function TAT_UI:GetStatusText(contentKey, achType, hasTrifecta)
    if achType == TAT_Data.ACH_TRIFECTA and not hasTrifecta then
        return STATUS_NA
    end
    local result = TAT:IsAchievementComplete(contentKey, achType)
    if result == true then return STATUS_COMPLETE
    elseif result == false then return STATUS_INCOMPLETE
    else return STATUS_NA end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- REFRESH LIST
-- ═══════════════════════════════════════════════════════════════════════════

function TAT_UI:RefreshList()
    if self.displayListDirty or not self.displayList then
        self:BuildDisplayList()
        self.displayListDirty = false
    end
    self:PerfCount("refresh_list_calls", 1)
    self:PerfMax("display_list_size", #self.displayList)

    for i = 1, MAX_VISIBLE_ROWS do
        local dataIndex = self.scrollOffset + i
        local item = self.displayList[dataIndex]
        local slot = self.rowPool[i]
        if not slot then break end

        if item then
            slot.control:SetHidden(false)
            if item.type == "header" then
                slot.nameLabel:SetText(COL_GOLD .. item.text .. COL_RESET)
                slot.nameLabel:SetFont(FONT_ROW_HEADER)
                slot.vetLabel:SetText("")
                slot.hmLabel:SetText("")
                slot.spdLabel:SetText("")
                slot.ndLabel:SetText("")
                slot.triLabel:SetText("")
            else
                local entry = item.data
                slot.nameLabel:SetText("  " .. TAT_Locale.GetLocalizedName(entry))
                slot.nameLabel:SetFont(FONT_ROW_NAME)
                slot.vetLabel:SetText(self:GetStatusText(entry.key, TAT_Data.ACH_VETERAN, entry.hasTrifecta))
                slot.hmLabel:SetText(self:GetStatusText(entry.key, TAT_Data.ACH_HARD_MODE, entry.hasTrifecta))
                slot.spdLabel:SetText(self:GetStatusText(entry.key, TAT_Data.ACH_SPEED_RUN, entry.hasTrifecta))
                slot.ndLabel:SetText(self:GetStatusText(entry.key, TAT_Data.ACH_NO_DEATH, entry.hasTrifecta))
                slot.triLabel:SetText(self:GetStatusText(entry.key, TAT_Data.ACH_TRIFECTA, entry.hasTrifecta))
            end
        else
            slot.control:SetHidden(true)
        end
    end
    self:UpdateFooter()
end

-- ═══════════════════════════════════════════════════════════════════════════
-- SCROLLING
-- ═══════════════════════════════════════════════════════════════════════════

function TAT_UI:GetMaxOffset()
    return math.max(0, #self.displayList - MAX_VISIBLE_ROWS)
end

function TAT_UI:ScrollLineUp()
    if self.scrollOffset > 0 then
        self.scrollOffset = self.scrollOffset - 1
        self:RefreshList()
    end
end

function TAT_UI:ScrollLineDown()
    local maxOff = self:GetMaxOffset()
    if self.scrollOffset < maxOff then
        self.scrollOffset = self.scrollOffset + 1
        self:RefreshList()
    end
end

function TAT_UI:ScrollPageUp()
    self.scrollOffset = math.max(0, self.scrollOffset - MAX_VISIBLE_ROWS)
    self:RefreshList()
end

function TAT_UI:ScrollPageDown()
    self.scrollOffset = math.min(self:GetMaxOffset(), self.scrollOffset + MAX_VISIBLE_ROWS)
    self:RefreshList()
end

function TAT_UI:KeyScrollUp()  if self.visible then self:ScrollLineUp()   end end
function TAT_UI:KeyScrollDown() if self.visible then self:ScrollLineDown() end end

-- ═══════════════════════════════════════════════════════════════════════════
-- FOOTER
-- ═══════════════════════════════════════════════════════════════════════════

function TAT_UI:UpdateFooter()
    local label = GetChild("FooterStats")
    if not label then return end

    local contentType
    if self.activeTab == "trials" then
        contentType = TAT_Data.CONTENT_TRIAL
    else
        contentType = TAT_Data.CONTENT_ARENA
    end

    local types = {
        { key = TAT_Data.ACH_VETERAN,   label = "VET" },
        { key = TAT_Data.ACH_HARD_MODE, label = "HM" },
        { key = TAT_Data.ACH_SPEED_RUN, label = "SPD" },
        { key = TAT_Data.ACH_NO_DEATH,  label = "ND"  },
        { key = TAT_Data.ACH_TRIFECTA,  label = "TRI" },
    }

    local counts = {}
    for _, t in ipairs(types) do
        local done, total = 0, 0
        for key, content in pairs(TAT.contentRegistry) do
            if content.contentType == contentType then
                local idForType
                if     t.key == TAT_Data.ACH_VETERAN   then idForType = content.vetId
                elseif t.key == TAT_Data.ACH_HARD_MODE then idForType = content.hmId
                elseif t.key == TAT_Data.ACH_SPEED_RUN then idForType = content.srId
                elseif t.key == TAT_Data.ACH_NO_DEATH  then idForType = content.ndId
                elseif t.key == TAT_Data.ACH_TRIFECTA  then idForType = content.triId
                end

                if idForType then
                    total = total + 1
                    local achs = TAT.trackedAchievements[key]
                    if achs and achs[t.key] and achs[t.key].completed then
                        done = done + 1
                    end
                end
            end
        end
        table.insert(counts, COL_GOLD .. done .. COL_RESET .. "/" .. total .. " " .. t.label)
    end
    label:SetText(table.concat(counts, "   "))
end

