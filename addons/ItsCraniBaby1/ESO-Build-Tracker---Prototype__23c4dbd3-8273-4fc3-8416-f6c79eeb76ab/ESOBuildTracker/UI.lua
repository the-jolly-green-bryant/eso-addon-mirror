local A = ESOBuildTracker

local function Label(name, parent, font, x, y, width, height, singleLine)
    local label = WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL)
    label:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    label:SetDimensions(width, height)
    label:SetFont(font)
    label:SetColor(0.91, 0.93, 0.96, 1)
    label:SetVerticalAlignment(TEXT_ALIGN_TOP)
    if singleLine then label:SetMaxLineCount(1) end
    return label
end

-- Paginate using ESO's actual font measurements. Long set descriptions and
-- script names must stay readable at the player's UI scale.
function A.Paginate(section, measure, maxHeight)
    local pages, current = {}, ""
    local function Emit()
        if current ~= "" then
            pages[#pages + 1] = { key = section.key, title = section.title, text = current }
            current = ""
        end
    end
    for line in (section.text .. "\n"):gmatch("(.-)\n") do
        local candidate = current == "" and line or current .. "\n" .. line
        if measure(candidate) <= maxHeight then
            current = candidate
        else
            Emit()
            if measure(line) <= maxHeight then
                current = line
            else
                -- A paragraph can itself span a page. Split at words to keep
                -- UTF-8 names intact. Item descriptions do not use byte cuts.
                for word in line:gmatch("%S+") do
                    candidate = current == "" and word or current .. " " .. word
                    if current ~= "" and measure(candidate) > maxHeight then Emit(); candidate = word end
                    current = candidate
                end
            end
        end
    end
    Emit()
    if #pages == 0 then pages[1] = { key = section.key, title = section.title, text = "" } end
    for i, page in ipairs(pages) do
        page.part = i
        if #pages > 1 then page.title = page.title .. " (" .. i .. "/" .. #pages .. ")" end
    end
    return pages
end

function A.UpdateStatus()
    if not A.ui then return end
    local snapshot, build = A.GetViewedSnapshot(), A.ActiveBuild()
    local source = A.viewIndex == 0 and "LIVE" or snapshot and snapshot.label or "SAVED"
    A.ui.source:SetText(source .. "  |  " .. (snapshot and snapshot.characterName .. "  |  " .. A.CaptureTimeText(snapshot) or "Waiting for character"))
    local text = "No target selected. Create or select one in Builds."
    if build then
        local counts = A.Progress(snapshot, build)
        text = "Target: " .. build.name .. "  |  " .. counts.matched .. " / " .. counts.total .. " gear and skill slots match"
        if counts.unknown > 0 then text = text .. "  |  " .. counts.unknown .. " unknown" end
    end
    A.ui.progress:SetText(text)
    A.ui.status:SetText(A.statusText or "Up/down: select a row. A: options. LB/RB: tabs. Y: refresh live. Builds holds targets and snapshots.")
end

function A.ShowDetail()
    if not A.ui then return end
    local row = A.rows and A.rows[A.selection]
    A.ui.heading:SetText(row and row.title or "No entries")
    local page = A.detailPages and A.detailPages[A.detailPageIndex or 1]
    A.ui.body:SetText(page and page.text or "")
    local total = #(A.detailPages or {})
    A.ui.detailCounter:SetText(total > 1 and ("Detail " .. (A.detailPageIndex or 1) .. "/" .. total .. "  -  LT / RT") or "")
    if A.keybindsActive then KEYBIND_STRIP:UpdateKeybindButtonGroup(A.keybinds) end
end

local statusColors = {
    ["Match"] = { 0.45, 0.86, 0.60, 1 }, ["Missing"] = { 1, 0.54, 0.43, 1 },
    ["Needs changes"] = { 1, 0.79, 0.39, 1 }, ["Below target"] = { 1, 0.79, 0.39, 1 },
    ["Unknown"] = { 1, 0.65, 0.75, 1 },
}

function A.RenderSelection()
    if not A.ui then return end
    local count, visible = #A.rows, #A.ui.rows
    A.selection = math.max(1, math.min(A.selection or 1, math.max(1, count)))
    if A.selection <= A.scrollOffset then A.scrollOffset = A.selection - 1 end
    if A.selection > A.scrollOffset + visible then A.scrollOffset = A.selection - visible end
    A.scrollOffset = math.max(0, math.min(A.scrollOffset, math.max(0, count - visible)))
    for slot, control in ipairs(A.ui.rows) do
        local index = A.scrollOffset + slot
        local row = A.rows[index]
        control.root:SetHidden(row == nil)
        control.dataIndex = row and index or nil
        if row then
            local selected = index == A.selection
            control.background:SetCenterColor(selected and 0.10 or 0.035, selected and 0.22 or 0.06, selected and 0.29 or 0.085, 1)
            control.title:SetText((selected and "> " or "") .. row.title)
            control.subtitle:SetText(row.subtitle)
            control.subtitle:SetColor(unpack(statusColors[row.status] or { 0.67, 0.76, 0.83, 1 }))
        end
    end
    A.ui.listCounter:SetText(count == 0 and "No entries" or (tostring(A.selection) .. " / " .. count .. "  -  Up / down to select"))
    local row = A.rows[A.selection]
    A.detailPages = A.Paginate({ key = row and row.key or "empty", title = row and row.title or "", text = row and row.detail or "" }, function(text)
        A.ui.measure:SetText(text); return A.ui.measure:GetTextHeight()
    end, A.ui.bodyHeight)
    A.detailPageIndex = 1
    A.ShowDetail()
    A.UpdateStatus()
end

-- Retain this entry point for the original capture/snapshot code. It now
-- rebuilds the current list, not a long series of whole-screen report pages.
function A.RebuildPages()
    if not A.ui then return end
    A.rows = A.CurrentRows()
    for index, tab in ipairs(A.ui.tabs) do
        tab.label:SetColor(index == A.tabIndex and 0.54 or 0.68, index == A.tabIndex and 0.88 or 0.74, index == A.tabIndex and 1 or 0.80, 1)
        tab.line:SetHidden(index ~= A.tabIndex)
    end
    local menu = A.menuStack[#A.menuStack]
    A.ui.section:SetText(menu and menu.title or A.tabs[A.tabIndex])
    A.RenderSelection()
end

function A.MoveSelection(delta)
    if not A.rows or #A.rows == 0 then return end
    local nextIndex = math.max(1, math.min(A.selection + delta, #A.rows))
    if nextIndex ~= A.selection then A.selection = nextIndex; A.RenderSelection() end
end

function A.MoveDetail(delta)
    A.detailPageIndex = math.max(1, math.min((A.detailPageIndex or 1) + delta, #(A.detailPages or {})))
    A.ShowDetail()
end

-- The default movement query includes ZO_DI_DPAD, which calls private
-- IsKeyDown. Read analog input through the public stick path and receive
-- digital directions through native keybind down/up callbacks instead.
function A.NavigationMagnitude()
    local stick = DIRECTIONAL_INPUT:GetY(ZO_DI_LEFT_STICK)
    local digital = 0
    if DIRECTIONAL_INPUT:IsAvailable(ZO_DI_DPAD) then
        digital = (A.navigationUp and 1 or 0) - (A.navigationDown and 1 or 0)
    end
    if stick ~= 0 or digital ~= 0 then
        DIRECTIONAL_INPUT:Consume(ZO_DI_LEFT_STICK, ZO_DI_DPAD)
    end
    return stick ~= 0 and stick or digital
end

function A.SuspendControls()
    A.navigationUp, A.navigationDown = false, false
    if A.keybindsActive then KEYBIND_STRIP:RemoveKeybindButtonGroup(A.keybinds); A.keybindsActive = false end
    if A.directionalActive then DIRECTIONAL_INPUT:Deactivate(A.inputController); A.directionalActive = false end
end

function A.ResumeControls()
    if A.inputPromptOpen or not A.scene or not A.scene:IsShowing() then return end
    if not A.keybindsActive then KEYBIND_STRIP:AddKeybindButtonGroup(A.keybinds); A.keybindsActive = true end
    if not A.directionalActive then
        A.navigationUp, A.navigationDown = false, false
        A.movementController:Initialize(MOVEMENT_CONTROLLER_DIRECTION_VERTICAL, nil, A.NavigationMagnitude)
        DIRECTIONAL_INPUT:Activate(A.inputController, A.ui.root)
        A.directionalActive = true
    end
end

function A.BuildUI()
    if A.ui then return end
    local width, height = GuiRoot:GetDimensions()
    local panelWidth, panelHeight = math.min(1440, width - 80), height - 150
    local root = WINDOW_MANAGER:CreateTopLevelWindow("ESOBuildTrackerWindow")
    root:SetAnchor(CENTER, GuiRoot, CENTER, 0, -15)
    root:SetDimensions(panelWidth, panelHeight)
    root:SetHidden(true)
    local backdrop = WINDOW_MANAGER:CreateControl("ESOBuildTrackerBackdrop", root, CT_BACKDROP)
    backdrop:SetAnchorFill(root)
    backdrop:SetCenterColor(0.025, 0.04, 0.065, 0.99)
    backdrop:SetEdgeColor(0.25, 0.55, 0.68, 1)
    backdrop:SetEdgeTexture("", 1, 1, 2, 0)
    local listWidth = math.floor(panelWidth * 0.40)
    local detailX, bodyY = listWidth + 58, 219
    local bodyWidth, bodyHeight = panelWidth - detailX - 30, panelHeight - bodyY - 105
    local listHeight, rowHeight = panelHeight - 312, 58
    A.ui = {
        root = root, rows = {}, tabs = {}, bodyHeight = bodyHeight,
        title = Label("ESOBuildTrackerTitle", root, "ZoFontGamepad34", 28, 16, panelWidth - 56, 43, true),
        source = Label("ESOBuildTrackerSource", root, "ZoFontGamepad22", 28, 64, panelWidth - 56, 29, true),
        progress = Label("ESOBuildTrackerProgress", root, "ZoFontGamepad22", 28, 94, panelWidth - 56, 29, true),
        section = Label("ESOBuildTrackerSection", root, "ZoFontGamepad22", 28, 166, listWidth, 30, true),
        heading = Label("ESOBuildTrackerHeading", root, "ZoFontGamepad27", detailX, 177, bodyWidth, 37, true),
        body = Label("ESOBuildTrackerBody", root, "ZoFontGamepad22", detailX, bodyY, bodyWidth, bodyHeight),
        measure = Label("ESOBuildTrackerMeasure", root, "ZoFontGamepad22", detailX, bodyY, bodyWidth, bodyHeight),
        detailCounter = Label("ESOBuildTrackerDetailCounter", root, "ZoFontGamepad22", detailX, panelHeight - 97, bodyWidth, 29, true),
        listCounter = Label("ESOBuildTrackerListCounter", root, "ZoFontGamepad22", 28, panelHeight - 97, listWidth, 29, true),
        status = Label("ESOBuildTrackerStatus", root, "ZoFontGamepad22", 28, panelHeight - 61, panelWidth - 56, 55),
    }
    A.ui.measure:SetHidden(true)
    A.ui.title:SetText(A.title .. "  |c9caabc" .. A.version .. "|r")
    for index, title in ipairs(A.tabs) do
        local tabIndex = index
        local tab = WINDOW_MANAGER:CreateControl("ESOBuildTrackerTab" .. index, root, CT_CONTROL)
        tab:SetAnchor(TOPLEFT, root, TOPLEFT, 28 + (index - 1) * 180, 127)
        tab:SetDimensions(170, 36)
        tab:SetMouseEnabled(true)
        tab:SetHandler("OnMouseUp", function(_, button, inside) if button == 1 and inside and not A.inputPromptOpen then A.ShowTab(tabIndex) end end)
        local label = Label("ESOBuildTrackerTabLabel" .. index, tab, "ZoFontGamepad27", 0, 0, 168, 33, true)
        label:SetText(title)
        local line = WINDOW_MANAGER:CreateControl("ESOBuildTrackerTabLine" .. index, tab, CT_BACKDROP)
        line:SetAnchor(TOPLEFT, tab, TOPLEFT, 0, 34)
        line:SetDimensions(155, 2)
        line:SetCenterColor(0.54, 0.88, 1, 1)
        A.ui.tabs[index] = { root = tab, label = label, line = line }
    end
    for slot = 1, math.max(3, math.floor(listHeight / rowHeight)) do
        local row = WINDOW_MANAGER:CreateControl("ESOBuildTrackerRow" .. slot, root, CT_CONTROL)
        row:SetAnchor(TOPLEFT, root, TOPLEFT, 28, 202 + (slot - 1) * rowHeight)
        row:SetDimensions(listWidth, rowHeight - 4)
        row:SetMouseEnabled(true)
        local background = WINDOW_MANAGER:CreateControl("ESOBuildTrackerRowBG" .. slot, row, CT_BACKDROP)
        background:SetAnchorFill(row)
        local control = { root = row, background = background,
            title = Label("ESOBuildTrackerRowTitle" .. slot, row, "ZoFontGamepad22", 10, 2, listWidth - 20, 27, true),
            subtitle = Label("ESOBuildTrackerRowSubtitle" .. slot, row, "ZoFontGamepad22", 10, 28, listWidth - 20, 25, true) }
        row:SetHandler("OnMouseUp", function(_, button, inside)
            if button == 1 and inside and control.dataIndex and not A.inputPromptOpen then
                A.selection = control.dataIndex; A.RenderSelection(); A.ActivateRow()
            end
        end)
        row:SetHandler("OnMouseWheel", function(_, delta) if not A.inputPromptOpen then A.MoveSelection(-delta) end end)
        A.ui.rows[slot] = control
    end
    A.scene = ZO_Scene:New(A.sceneName, SCENE_MANAGER)
    A.scene:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
    A.scene:AddFragment(ZO_FadeSceneFragment:New(root))
    A.movementController = ZO_MovementController:New(MOVEMENT_CONTROLLER_DIRECTION_VERTICAL, nil, A.NavigationMagnitude)
    A.inputController = { UpdateDirectionalInput = function()
        if not A.directionalActive or A.inputPromptOpen then return end
        local result = A.movementController:CheckMovement()
        if result == MOVEMENT_CONTROLLER_MOVE_NEXT then A.MoveSelection(1)
        elseif result == MOVEMENT_CONTROLLER_MOVE_PREVIOUS then A.MoveSelection(-1) end
    end }
    local function HasLongDetail() return #(A.detailPages or {}) > 1 end
    A.keybinds = {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        { name = "Previous row", keybind = "UI_SHORTCUT_INPUT_UP", ethereal = true, handlesKeyUp = true,
          callback = function(up) A.navigationUp = not up and A.directionalActive and not A.inputPromptOpen end },
        { name = "Next row", keybind = "UI_SHORTCUT_INPUT_DOWN", ethereal = true, handlesKeyUp = true,
          callback = function(up) A.navigationDown = not up and A.directionalActive and not A.inputPromptOpen end },
        { name = "Previous tab", keybind = "UI_SHORTCUT_LEFT_SHOULDER", callback = function() A.ShowTab(A.tabIndex - 1) end },
        { name = "Next tab", keybind = "UI_SHORTCUT_RIGHT_SHOULDER", callback = function() A.ShowTab(A.tabIndex + 1) end },
        { name = "Select", keybind = "UI_SHORTCUT_PRIMARY", callback = A.ActivateRow },
        { name = "Refresh live", keybind = "UI_SHORTCUT_TERTIARY", callback = A.RefreshLive },
        { name = "Previous detail", keybind = "UI_SHORTCUT_LEFT_TRIGGER", visible = HasLongDetail, callback = function() A.MoveDetail(-1) end },
        { name = "Next detail", keybind = "UI_SHORTCUT_RIGHT_TRIGGER", visible = HasLongDetail, callback = function() A.MoveDetail(1) end },
    }
    ZO_Gamepad_AddBackNavigationKeybindDescriptors(A.keybinds, GAME_NAVIGATION_TYPE_BUTTON, A.Back)
    A.scene:RegisterCallback("StateChange", function(_, state)
        if state == SCENE_SHOWING then
            A.Refresh("opened tracker"); A.RebuildPages(); A.ResumeControls()
        elseif state == SCENE_HIDING then A.SuspendControls() end
    end)
end

function A.InstallMenuEntry()
    if A.menuInstalled then return true end
    if type(ZO_MENU_ENTRIES) ~= "table" or not ZO_GamepadEntryData then return false end
    local entry = ZO_GamepadEntryData:New(A.title, "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_inventory.dds")
    entry:SetIconTintOnSelection(true)
    entry:SetIconDisabledTintOnSelection(true)
    entry.id = "ESOBuildTrackerMenuEntry"
    entry.data = { name = A.title, scene = A.sceneName }
    table.insert(ZO_MENU_ENTRIES, entry)
    A.menuInstalled = true
    return true
end

function A.Open()
    if not A.ready then A.Notify("Wait until your character has loaded."); return end
    if A.uiError then A.Notify("The interface could not initialize. Use /ebt status and report the error."); return end
    if not IsInGamepadPreferredMode() then A.Notify("This tracker uses the controller interface. Enable Gamepad Mode to open it."); return end
    A.BuildUI()
    SCENE_MANAGER:Push(A.sceneName)
end
