-- Dungeon Mechs Codex UI
-- Lua-built, no external library dependency. Hard-mode-focused UI with
-- exact visible/pasted snippet rows, scrollable summaries, and flat, readable custom scrollbars.

local DMC = DungeonMechsCodex
local wm = WINDOW_MANAGER
local LEFT_MOUSE_BUTTON = MOUSE_BUTTON_INDEX_LEFT or 1

local UI = {
    dungeonPage = 1,
    dungeonPageSize = 19,
    mechanicScrollIndex = 1,
    mechanicPageSize = 2,
    mechanicLineSlots = 3,
    dungeonSummaryPage = 1,
    bossSummaryPage = 1,
    dungeonSummaryPages = {},
    bossSummaryPages = {},
    selectedDungeonId = nil,
    selectedBossId = nil,
    selectedChatLine = nil,
    searchText = "",
    roleFilter = "all",
    dungeonButtons = {},
    bossButtons = {},
    dungeonPasteButtons = {},
    bossPasteButtons = {},
    mechanicRows = {},
    currentMechanicCount = 0,
    scrollDragging = false,
}
DMC.ui = UI

local C = {
    bg = {0.010, 0.012, 0.016, 0.97},
    panel = {0.020, 0.024, 0.032, 0.94},
    panel2 = {0.030, 0.037, 0.050, 0.95},
    row = {0.040, 0.048, 0.064, 0.94},
    rowEdge = {0.12, 0.30, 0.38, 0.95},
    edge = {0.20, 0.56, 0.66, 1},
    edgeDim = {0.08, 0.20, 0.26, 0.92},
    title = {0.52, 0.92, 1, 1},
    text = {0.92, 0.91, 0.84, 1},
    muted = {0.68, 0.72, 0.74, 1},
    gold = {1.00, 0.83, 0.38, 1},
    ok = {0.58, 1.00, 0.70, 1},
    mechNumber = {0.54, 0.58, 0.60, 0.72},
}


local function getSessionState()
    DMC.sessionState = DMC.sessionState or {}
    if not DMC.sessionState.roleFilter then DMC.sessionState.roleFilter = "all" end
    return DMC.sessionState
end

local function isValidRoleFilter(role)
    return role == "all" or role == "quick" or role == "tank" or role == "healer" or role == "dps"
end

local function clamp(v, lo, hi)
    v = tonumber(v) or lo
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

local function anchorFill(control, parent, inset)
    inset = inset or 0
    control:SetAnchor(TOPLEFT, parent, TOPLEFT, inset, inset)
    control:SetAnchor(BOTTOMRIGHT, parent, BOTTOMRIGHT, -inset, -inset)
end

local function makeBackdrop(parent, name, centerColor, edgeColor, inset)
    local bd = wm:CreateControl(name, parent, CT_BACKDROP)
    anchorFill(bd, parent, inset or 0)
    bd:SetCenterColor(unpack(centerColor or C.panel))
    bd:SetEdgeColor(unpack(edgeColor or C.edge))
    bd:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 128, 16)
    bd:SetInsets(4, 4, -4, -4)
    bd:SetMouseEnabled(false)
    if bd.SetDrawLayer and DL_BACKGROUND then bd:SetDrawLayer(DL_BACKGROUND) end
    return bd
end

local function makePanel(parent, name, x, y, w, h, center, edge)
    local p = wm:CreateControl(name, parent, CT_CONTROL)
    p:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    p:SetDimensions(w, h)
    p:SetMouseEnabled(true)
    p.bg = makeBackdrop(p, name .. "_Backdrop", center or C.panel, edge or C.edgeDim)
    return p
end

local function makeLabel(parent, name, text, font, color, oneLine)
    local c = wm:CreateControl(name, parent, CT_LABEL)
    c:SetFont(font or "ZoFontGame")
    c:SetText(text or "")
    c:SetColor(unpack(color or C.text))
    if oneLine and TEXT_WRAP_MODE_ELLIPSIS then c:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) end
    return c
end

local function makeButton(parent, name, text, callback, font)
    local b = wm:CreateControl(name, parent, CT_BUTTON)
    b:SetFont(font or "ZoFontGame")
    b:SetText(text or "")
    b:SetNormalFontColor(0.84, 0.88, 0.90, 1)
    b:SetMouseOverFontColor(1, 1, 1, 1)
    b:SetPressedFontColor(0.50, 0.92, 1, 1)
    b:SetHandler("OnClicked", callback)
    return b
end

local function makePill(parent, name, text, callback, font)
    local b = makeButton(parent, name, text, callback, font or "ZoFontGameSmall")
    b.bg = wm:CreateControl(name .. "_Bg", b, CT_BACKDROP)
    b.bg:SetCenterColor(0.035, 0.045, 0.060, 0.94)
    b.bg:SetEdgeColor(0.10, 0.26, 0.34, 0.94)
    b.bg:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 128, 16)
    b.bg:SetInsets(3, 3, -3, -3)
    b.bg:SetMouseEnabled(false)
    if b.bg.SetDrawLayer and DL_BACKGROUND then b.bg:SetDrawLayer(DL_BACKGROUND) end
    anchorFill(b.bg, b, 0)
    return b
end

local function setSelectedButton(button, selected)
    if not button then return end
    if selected then
        button:SetNormalFontColor(0.44, 0.92, 1, 1)
        if button.bg then
            button.bg:SetCenterColor(0.04, 0.12, 0.16, 0.96)
            button.bg:SetEdgeColor(0.34, 0.78, 0.92, 1)
        end
    else
        button:SetNormalFontColor(0.84, 0.88, 0.90, 1)
        if button.bg then
            button.bg:SetCenterColor(0.035, 0.045, 0.060, 0.94)
            button.bg:SetEdgeColor(0.10, 0.26, 0.34, 0.94)
        end
    end
end

local function shortFlags(boss)
    if not boss or not boss.flags then return "" end
    local out, seen = {}, {}
    local function add(label)
        if not seen[label] then seen[label] = true; table.insert(out, label) end
    end
    for _, flag in ipairs(boss.flags) do
        local f = DMC.NormalizeText(flag)
        if f == "secret" then add("Secret")
        elseif f == "super secret" then add("Secret+")
        elseif f == "final" then add("Final")
        elseif f == "main" then add("Main")
        end
    end
    if #out == 0 then return "" end
    return "  |c888888" .. table.concat(out, " ") .. "|r"
end

local function getDungeonSummaryText(dungeon)
    if not dungeon or not dungeon.summary then return "" end
    return dungeon.summary.ui or dungeon.summary.full or ""
end

local function getBossSummaryText(boss)
    if not boss then return "" end
    return boss.ui or boss.summary or ""
end

local function setTextSafe(label, text)
    if label then label:SetText(text or "") end
end

local function stripForUI(text)
    return DMC.StripChatFormatting(text or "")
end

local function setPasteButton(button, chatText, label)
    if not button then return end
    button.chatText = chatText
    button:SetHidden(chatText == nil or chatText == "")
    if chatText then button:SetText(label or "Paste") end
end

local function clearAnchorsSafe(control)
    if control and control.ClearAnchors then control:ClearAnchors() end
end

local function layoutMechanicRowLines(row, visibleLineCount)
    if not row then return end
    visibleLineCount = clamp(tonumber(visibleLineCount) or 1, 1, UI.mechanicLineSlots)

    -- Full-mode mechanic snippets can be long. The paste chunks already split safely,
    -- but a chunk may still need 3 UI-wrapped text rows. Give fewer visible paste
    -- chunks more vertical space so text does not clip behind the row/button area.
    local startY = 30
    local gap = 2
    local slotH = 36
    if visibleLineCount == 1 then
        slotH = 108
    elseif visibleLineCount == 2 then
        slotH = 54
    end

    for j = 1, UI.mechanicLineSlots do
        local y = startY + (j - 1) * (slotH + gap)
        local label = row.lineLabels and row.lineLabels[j]
        if label then
            clearAnchorsSafe(label)
            label:SetAnchor(TOPLEFT, row, TOPLEFT, 10, y)
            label:SetDimensions(650, slotH)
        end

        local pb = row.pasteButtons and row.pasteButtons[j]
        if pb then
            clearAnchorsSafe(pb)
            pb:SetAnchor(TOPRIGHT, row, TOPRIGHT, -12, y)
            pb:SetDimensions(80, 24)
        end
    end
end

local function buildSummaryPages(text, maxChars)
    text = tostring(text or "")
    text = text:gsub("\r\n", "\n")
    text = text:gsub("%s+", " ")
    text = zo_strtrim(text)
    if text == "" then return {""} end
    if DMC.SplitLongText then
        local pages = DMC.SplitLongText(text, maxChars or 230)
        if pages and #pages > 0 then return pages end
    end
    return {text}
end

local function updateMiniScrollbar(track, thumb, page, total)
    if not track or not thumb then return end
    total = tonumber(total) or 0
    local show = total > 1
    track:SetHidden(not show)
    thumb:SetHidden(not show)
    if not show then return end

    local trackH = track:GetHeight() or 1
    local trackW = track:GetWidth() or 8
    local thumbH = math.max(12, math.floor(trackH / total))
    if thumbH > trackH then thumbH = trackH end
    local maxOffset = math.max(0, trackH - thumbH)
    local pct = total > 1 and ((page - 1) / (total - 1)) or 0
    local offset = math.floor(maxOffset * pct + 0.5)

    thumb:ClearAnchors()
    thumb:SetAnchor(TOP, track, TOP, 0, offset)
    thumb:SetDimensions(math.max(6, trackW - 3), thumbH)
end

local function refreshSummaryDisplay(kind)
    if kind == "dungeon" then
        local pages = UI.dungeonSummaryPages or {""}
        local total = #pages
        UI.dungeonSummaryPage = clamp(UI.dungeonSummaryPage or 1, 1, math.max(1, total))
        if UI.dungeonSummary then UI.dungeonSummary:SetText(pages[UI.dungeonSummaryPage] or "") end
        if UI.dungeonSummaryHint then UI.dungeonSummaryHint:SetText(total > 1 and (UI.dungeonSummaryPage .. "/" .. total) or "") end
        updateMiniScrollbar(UI.dungeonSummaryTrack, UI.dungeonSummaryThumb, UI.dungeonSummaryPage, total)
    elseif kind == "boss" then
        local pages = UI.bossSummaryPages or {""}
        local total = #pages
        UI.bossSummaryPage = clamp(UI.bossSummaryPage or 1, 1, math.max(1, total))
        if UI.bossSummary then UI.bossSummary:SetText(pages[UI.bossSummaryPage] or "") end
        if UI.bossSummaryHint then UI.bossSummaryHint:SetText(total > 1 and (UI.bossSummaryPage .. "/" .. total) or "") end
        updateMiniScrollbar(UI.bossSummaryTrack, UI.bossSummaryThumb, UI.bossSummaryPage, total)
    end
end

local function setSummaryText(kind, text)
    if kind == "dungeon" then
        UI.dungeonSummaryPages = buildSummaryPages(text, 230)
        UI.dungeonSummaryPage = 1
        refreshSummaryDisplay("dungeon")
    elseif kind == "boss" then
        UI.bossSummaryPages = buildSummaryPages(text, 250)
        UI.bossSummaryPage = 1
        refreshSummaryDisplay("boss")
    end
end

local function scrollSummary(kind, delta)
    local pages = kind == "dungeon" and UI.dungeonSummaryPages or UI.bossSummaryPages
    local total = pages and #pages or 0
    if total <= 1 then return end

    if kind == "dungeon" then
        if delta and delta > 0 then UI.dungeonSummaryPage = UI.dungeonSummaryPage - 1 else UI.dungeonSummaryPage = UI.dungeonSummaryPage + 1 end
        refreshSummaryDisplay("dungeon")
    elseif kind == "boss" then
        if delta and delta > 0 then UI.bossSummaryPage = UI.bossSummaryPage - 1 else UI.bossSummaryPage = UI.bossSummaryPage + 1 end
        refreshSummaryDisplay("boss")
    end
end

local function attachSummaryWheel(control, kind)
    if not control then return end
    control:SetMouseEnabled(true)
    control:SetHandler("OnMouseWheel", function(_, delta) scrollSummary(kind, delta) end)
end

local function styleScrollbarTrack(track)
    if not track then return end
    -- Keep this flat. The ornate ESO tooltip border looks like loose teal bracket lines on very narrow controls.
    track:SetCenterColor(0.012, 0.016, 0.022, 0.92)
    track:SetEdgeColor(0, 0, 0, 0)
    track:SetInsets(0, 0, 0, 0)
    track:SetMouseEnabled(false)
end

local function styleScrollbarThumb(thumb)
    if not thumb then return end
    -- Neutral thumb so it reads as a real scrollbar instead of another cyan panel border.
    thumb:SetCenterColor(0.38, 0.46, 0.50, 0.96)
    thumb:SetEdgeColor(0, 0, 0, 0)
    thumb:SetInsets(0, 0, 0, 0)
    thumb:SetMouseEnabled(false)
end

local function makeMiniScrollbar(parent, name, anchorTo, offsetX, offsetY, height)
    local track = wm:CreateControl(name .. "Track", parent, CT_BACKDROP)
    track:SetAnchor(TOPRIGHT, anchorTo or parent, TOPRIGHT, offsetX or -16, offsetY or 0)
    track:SetDimensions(12, height or 48)
    styleScrollbarTrack(track)

    local thumb = wm:CreateControl(name .. "Thumb", track, CT_BACKDROP)
    styleScrollbarThumb(thumb)

    track:SetHidden(true)
    thumb:SetHidden(true)
    return track, thumb
end

local function getMaxScrollStart(total)
    return math.max(1, (tonumber(total) or 0) - UI.mechanicPageSize + 1)
end

local function setMechanicScrollIndex(value, refresh)
    local maxStart = getMaxScrollStart(UI.currentMechanicCount)
    local newIndex = clamp(math.floor((tonumber(value) or 1) + 0.5), 1, maxStart)
    if newIndex ~= UI.mechanicScrollIndex then
        UI.mechanicScrollIndex = newIndex
        if refresh then DMC.RefreshBossDetails(true) end
    end
end

local function updateScrollFromWheel(delta)
    local old = UI.mechanicScrollIndex or 1
    if delta and delta > 0 then
        setMechanicScrollIndex(old - 1, true)
    else
        setMechanicScrollIndex(old + 1, true)
    end
end

local function attachWheel(control)
    if not control then return end
    control:SetMouseEnabled(true)
    control:SetHandler("OnMouseWheel", function(_, delta) updateScrollFromWheel(delta) end)
end

local function getMouseY()
    if GetUIMousePosition then
        local _, y = GetUIMousePosition()
        return y or 0
    end
    return 0
end

local function updateScrollbarThumb(total)
    if not UI.mechScrollTrack or not UI.mechScrollThumb then return end
    local show = (tonumber(total) or 0) > UI.mechanicPageSize
    UI.mechScrollTrack:SetHidden(not show)
    UI.mechScrollThumb:SetHidden(not show)
    if not show then return end

    local trackH = UI.mechScrollTrack:GetHeight() or 1
    local trackW = UI.mechScrollTrack:GetWidth() or 16
    local maxStart = getMaxScrollStart(total)
    local thumbH = math.max(38, math.floor(trackH * UI.mechanicPageSize / total))
    if thumbH > trackH then thumbH = trackH end
    local maxOffset = math.max(0, trackH - thumbH)
    local pct = maxStart > 1 and ((UI.mechanicScrollIndex - 1) / (maxStart - 1)) or 0
    local offset = math.floor(maxOffset * pct + 0.5)

    UI.mechScrollThumb:ClearAnchors()
    UI.mechScrollThumb:SetAnchor(TOP, UI.mechScrollTrack, TOP, 0, offset)
    UI.mechScrollThumb:SetDimensions(math.max(8, trackW - 4), thumbH)
end

local function setScrollFromMouse(refresh)
    if not UI.mechScrollTrack then return end
    local total = UI.currentMechanicCount or 0
    local maxStart = getMaxScrollStart(total)
    if maxStart <= 1 then return end

    local trackTop = UI.mechScrollTrack:GetTop() or 0
    local trackH = UI.mechScrollTrack:GetHeight() or 1
    local thumbH = UI.mechScrollThumb and UI.mechScrollThumb:GetHeight() or 38
    local usable = math.max(1, trackH - thumbH)
    local rel = getMouseY() - trackTop - (thumbH / 2)
    local pct = clamp(rel / usable, 0, 1)
    local index = 1 + math.floor((maxStart - 1) * pct + 0.5)
    setMechanicScrollIndex(index, refresh)
end

local function beginScrollDrag()
    UI.scrollDragging = true
    setScrollFromMouse(true)
end

local function endScrollDrag()
    UI.scrollDragging = false
end

function DMC.InitializeUI()
    local session = getSessionState()
    UI.roleFilter = isValidRoleFilter(session.roleFilter) and session.roleFilter or "all"
    UI.selectedDungeonId = session.selectedDungeonId
    UI.selectedBossId = session.selectedBossId

    local win = wm:CreateTopLevelWindow("DMC_MainWindow")
    UI.window = win
    win:SetDimensions(1220, 850)
    win:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    win:SetMouseEnabled(true)
    win:SetMovable(true)
    win:SetClampedToScreen(true)
    win:SetHidden(true)
    win:SetHandler("OnMouseUp", endScrollDrag)
    win:SetHandler("OnUpdate", function()
        if UI.scrollDragging then
            if IsMouseButtonPressed and not IsMouseButtonPressed(LEFT_MOUSE_BUTTON) then
                UI.scrollDragging = false
            else
                setScrollFromMouse(true)
            end
        end
    end)

    makeBackdrop(win, "DMC_MainWindow_Backdrop", C.bg, C.edge, 0)

    UI.title = makeLabel(win, "DMC_Title", DMC.displayName or "Flamechasers Dungeon Codex", "ZoFontWinH1", C.title, true)
    UI.title:SetAnchor(TOPLEFT, win, TOPLEFT, 22, 14)
    UI.title:SetDimensions(560, 34)

    UI.subtitle = makeLabel(win, "DMC_Subtitle", "DLC dungeon mechanics • hard-mode dataset • paste-ready PUG notes", "ZoFontGameSmall", C.muted, true)
    UI.subtitle:SetAnchor(TOPLEFT, UI.title, BOTTOMLEFT, 2, -1)
    UI.subtitle:SetDimensions(660, 20)

    UI.modePill = makePill(win, "DMC_ModePill", "Mode: Hard Mode", function() end, "ZoFontGameSmall")
    UI.modePill:SetAnchor(TOPLEFT, UI.subtitle, TOPRIGHT, 20, -2)
    UI.modePill:SetDimensions(128, 24)
    UI.modePill:SetMouseEnabled(false)
    setSelectedButton(UI.modePill, true)

    UI.close = makeButton(win, "DMC_Close", "X", function() DMC.HideWindow() end, "ZoFontGameBold")
    UI.close:SetAnchor(TOPRIGHT, win, TOPRIGHT, -18, 18)
    UI.close:SetDimensions(30, 28)

    -- Left panel: dungeon navigation.
    UI.leftPanel = makePanel(win, "DMC_LeftPanel", 20, 64, 320, 766, C.panel, C.edgeDim)

    UI.searchLabel = makeLabel(UI.leftPanel, "DMC_SearchLabel", "Search DLC dungeons", "ZoFontGameSmall", C.muted, true)
    UI.searchLabel:SetAnchor(TOPLEFT, UI.leftPanel, TOPLEFT, 16, 12)
    UI.searchLabel:SetDimensions(280, 18)

    UI.searchBg = wm:CreateControl("DMC_SearchBox_Backdrop", UI.leftPanel, CT_BACKDROP)
    UI.searchBg:SetAnchor(TOPLEFT, UI.leftPanel, TOPLEFT, 16, 32)
    UI.searchBg:SetDimensions(288, 34)
    UI.searchBg:SetCenterColor(0.015, 0.018, 0.025, 0.96)
    UI.searchBg:SetEdgeColor(0.12, 0.30, 0.40, 0.9)
    UI.searchBg:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 128, 16)
    UI.searchBg:SetInsets(3, 3, -3, -3)
    UI.searchBg:SetMouseEnabled(false)
    if UI.searchBg.SetDrawLayer and DL_BACKGROUND then UI.searchBg:SetDrawLayer(DL_BACKGROUND) end

    UI.search = wm:CreateControl("DMC_SearchBox", UI.leftPanel, CT_EDITBOX)
    UI.search:SetFont("ZoFontGame")
    UI.search:SetDimensions(276, 28)
    UI.search:SetAnchor(TOPLEFT, UI.searchBg, TOPLEFT, 6, 3)
    UI.search:SetText("")
    UI.search:SetMaxInputChars(40)
    UI.search:SetMouseEnabled(true)
    UI.search:SetHandler("OnMouseDown", function(edit) if edit.TakeFocus then edit:TakeFocus() end end)
    UI.search:SetHandler("OnMouseUp", function(edit) if edit.TakeFocus then edit:TakeFocus() end end)
    UI.search:SetHandler("OnTextChanged", function(edit)
        UI.searchText = edit:GetText() or ""
        UI.dungeonPage = 1
        DMC.RefreshDungeonList()
    end)

    UI.currentHint = makeLabel(UI.leftPanel, "DMC_CurrentHint", "Current dungeon is pinned/highlighted when detected", "ZoFontGameSmall", C.muted, true)
    UI.currentHint:SetAnchor(TOPLEFT, UI.searchBg, BOTTOMLEFT, 0, 9)
    UI.currentHint:SetDimensions(288, 18)

    local listY = 96
    for i = 1, UI.dungeonPageSize do
        local btn = makeButton(UI.leftPanel, "DMC_DungeonButton" .. i, "", function(button)
            if button.dungeonId then DMC.SelectDungeon(button.dungeonId) end
        end, "ZoFontGame")
        btn:SetAnchor(TOPLEFT, UI.leftPanel, TOPLEFT, 16, listY + (i-1)*29)
        btn:SetDimensions(288, 28)
        UI.dungeonButtons[i] = btn
    end

    UI.prevPage = makePill(UI.leftPanel, "DMC_PrevPage", "‹ Prev", function()
        UI.dungeonPage = math.max(1, UI.dungeonPage - 1)
        DMC.RefreshDungeonList()
    end)
    UI.prevPage:SetAnchor(BOTTOMLEFT, UI.leftPanel, BOTTOMLEFT, 16, -16)
    UI.prevPage:SetDimensions(92, 28)

    UI.pageLabel = makeLabel(UI.leftPanel, "DMC_PageLabel", "", "ZoFontGameSmall", C.muted, true)
    UI.pageLabel:SetAnchor(LEFT, UI.prevPage, RIGHT, 12, 0)
    UI.pageLabel:SetDimensions(70, 28)

    UI.nextPage = makePill(UI.leftPanel, "DMC_NextPage", "Next ›", function()
        UI.dungeonPage = UI.dungeonPage + 1
        DMC.RefreshDungeonList()
    end)
    UI.nextPage:SetAnchor(BOTTOMRIGHT, UI.leftPanel, BOTTOMRIGHT, -16, -16)
    UI.nextPage:SetDimensions(92, 28)

    -- Right side: content panels.
    UI.rightPanel = makePanel(win, "DMC_RightPanel", 354, 64, 846, 766, C.panel, C.edgeDim)
    attachWheel(UI.rightPanel)

    UI.dungeonPanel = makePanel(UI.rightPanel, "DMC_DungeonPanel", 16, 14, 814, 130, C.panel2, C.edgeDim)
    UI.dungeonTitle = makeLabel(UI.dungeonPanel, "DMC_DungeonTitle", "Select a dungeon", "ZoFontWinH2", C.title, true)
    UI.dungeonTitle:SetAnchor(TOPLEFT, UI.dungeonPanel, TOPLEFT, 14, 10)
    UI.dungeonTitle:SetDimensions(590, 28)

    UI.statusLabel = makeLabel(UI.dungeonPanel, "DMC_StatusLabel", "Hard Mode", "ZoFontGameSmall", C.ok, true)
    UI.statusLabel:SetAnchor(TOPRIGHT, UI.dungeonPanel, TOPRIGHT, -14, 13)
    UI.statusLabel:SetDimensions(180, 20)

    UI.dungeonSummary = makeLabel(UI.dungeonPanel, "DMC_DungeonSummary", "", "ZoFontGameSmall", C.text, false)
    UI.dungeonSummary:SetAnchor(TOPLEFT, UI.dungeonTitle, BOTTOMLEFT, 0, 6)
    UI.dungeonSummary:SetDimensions(760, 48)
    attachSummaryWheel(UI.dungeonSummary, "dungeon")
    UI.dungeonSummaryHint = makeLabel(UI.dungeonPanel, "DMC_DungeonSummaryHint", "", "ZoFontGameSmall", C.muted, true)
    UI.dungeonSummaryHint:SetAnchor(BOTTOMRIGHT, UI.dungeonPanel, BOTTOMRIGHT, -34, -10)
    UI.dungeonSummaryHint:SetDimensions(46, 18)
    UI.dungeonSummaryTrack, UI.dungeonSummaryThumb = makeMiniScrollbar(UI.dungeonPanel, "DMC_DungeonSummary", UI.dungeonPanel, -16, 44, 48)

    for i = 1, 4 do
        local pb = makePill(UI.dungeonPanel, "DMC_DungeonPaste" .. i, i == 1 and "Paste note" or tostring(i), function(button)
            if button.chatText then DMC.PasteToChatInput(button.chatText) end
        end)
        if i == 1 then
            pb:SetAnchor(BOTTOMLEFT, UI.dungeonPanel, BOTTOMLEFT, 14, -8)
            pb:SetDimensions(100, 24)
        else
            pb:SetAnchor(LEFT, UI.dungeonPasteButtons[i-1], RIGHT, 5, 0)
            pb:SetDimensions(30, 24)
        end
        UI.dungeonPasteButtons[i] = pb
    end

    UI.bossListPanel = makePanel(UI.rightPanel, "DMC_BossListPanel", 16, 156, 814, 130, C.panel2, C.edgeDim)
    UI.bossListTitle = makeLabel(UI.bossListPanel, "DMC_BossListTitle", "Bosses", "ZoFontGameBold", C.title, true)
    UI.bossListTitle:SetAnchor(TOPLEFT, UI.bossListPanel, TOPLEFT, 14, 10)
    UI.bossListTitle:SetDimensions(200, 24)

    UI.roleLabel = makeLabel(UI.bossListPanel, "DMC_RoleLabel", "Mode:", "ZoFontGameSmall", C.muted, true)
    UI.roleLabel:SetAnchor(TOPRIGHT, UI.bossListPanel, TOPRIGHT, -432, 12)
    UI.roleLabel:SetDimensions(54, 22)

    UI.roleAll = makePill(UI.bossListPanel, "DMC_RoleAll", "Full", function() DMC.SetRoleFilter("all") end)
    UI.roleAll:SetAnchor(TOPRIGHT, UI.bossListPanel, TOPRIGHT, -370, 10)
    UI.roleAll:SetDimensions(58, 26)
    UI.roleQuick = makePill(UI.bossListPanel, "DMC_RoleQuick", "Quick", function() DMC.SetRoleFilter("quick") end)
    UI.roleQuick:SetAnchor(LEFT, UI.roleAll, RIGHT, 6, 0)
    UI.roleQuick:SetDimensions(66, 26)
    UI.roleTank = makePill(UI.bossListPanel, "DMC_RoleTank", "Tank", function() DMC.SetRoleFilter("tank") end)
    UI.roleTank:SetAnchor(LEFT, UI.roleQuick, RIGHT, 6, 0)
    UI.roleTank:SetDimensions(58, 26)
    UI.roleHealer = makePill(UI.bossListPanel, "DMC_RoleHealer", "Healer", function() DMC.SetRoleFilter("healer") end)
    UI.roleHealer:SetAnchor(LEFT, UI.roleTank, RIGHT, 6, 0)
    UI.roleHealer:SetDimensions(72, 26)
    UI.roleDps = makePill(UI.bossListPanel, "DMC_RoleDps", "DPS", function() DMC.SetRoleFilter("dps") end)
    UI.roleDps:SetAnchor(LEFT, UI.roleHealer, RIGHT, 6, 0)
    UI.roleDps:SetDimensions(52, 26)

    for i = 1, 8 do
        local btn = makeButton(UI.bossListPanel, "DMC_BossButton" .. i, "", function(button)
            if button.bossId then DMC.SelectBoss(button.bossId) end
        end, "ZoFontGameSmall")
        local col = (i <= 4) and 0 or 1
        local row = ((i - 1) % 4)
        btn:SetAnchor(TOPLEFT, UI.bossListPanel, TOPLEFT, 118 + col*360, 40 + row*21)
        btn:SetDimensions(330, 20)
        UI.bossButtons[i] = btn
    end

    UI.bossPanel = makePanel(UI.rightPanel, "DMC_BossPanel", 16, 298, 814, 112, C.panel2, C.edgeDim)
    UI.bossTitle = makeLabel(UI.bossPanel, "DMC_BossTitle", "", "ZoFontWinH3", C.title, true)
    UI.bossTitle:SetAnchor(TOPLEFT, UI.bossPanel, TOPLEFT, 14, 10)
    UI.bossTitle:SetDimensions(620, 28)

    UI.bossSummary = makeLabel(UI.bossPanel, "DMC_BossSummary", "", "ZoFontGameSmall", C.text, false)
    UI.bossSummary:SetAnchor(TOPLEFT, UI.bossTitle, BOTTOMLEFT, 0, 5)
    UI.bossSummary:SetDimensions(620, 58)
    attachSummaryWheel(UI.bossSummary, "boss")
    UI.bossSummaryHint = makeLabel(UI.bossPanel, "DMC_BossSummaryHint", "", "ZoFontGameSmall", C.muted, true)
    UI.bossSummaryHint:SetAnchor(TOPRIGHT, UI.bossPanel, TOPRIGHT, -146, 14)
    UI.bossSummaryHint:SetDimensions(46, 18)
    UI.bossSummaryTrack, UI.bossSummaryThumb = makeMiniScrollbar(UI.bossPanel, "DMC_BossSummary", UI.bossPanel, -134, 44, 58)

    for i = 1, 4 do
        local pb = makePill(UI.bossPanel, "DMC_BossPaste" .. i, i == 1 and "Paste boss" or tostring(i), function(button)
            if button.chatText then DMC.PasteToChatInput(button.chatText) end
        end)
        if i == 1 then
            pb:SetAnchor(TOPRIGHT, UI.bossPanel, TOPRIGHT, -14, 44)
            pb:SetDimensions(110, 24)
            UI.bossPaste = pb
        else
            if i == 2 then
                pb:SetAnchor(TOPLEFT, UI.bossPaste, BOTTOMLEFT, 0, 4)
            else
                pb:SetAnchor(LEFT, UI.bossPasteButtons[i-1], RIGHT, 4, 0)
            end
            pb:SetDimensions(34, 24)
        end
        UI.bossPasteButtons[i] = pb
    end

    UI.mechanicsPanel = makePanel(UI.rightPanel, "DMC_MechanicsPanel", 16, 422, 814, 344, C.panel2, C.edgeDim)
    attachWheel(UI.mechanicsPanel)
    UI.mechanicsTitle = makeLabel(UI.mechanicsPanel, "DMC_MechanicsTitle", "Mechanics", "ZoFontGameBold", C.title, true)
    UI.mechanicsTitle:SetAnchor(TOPLEFT, UI.mechanicsPanel, TOPLEFT, 14, 10)
    UI.mechanicsTitle:SetDimensions(220, 22)

    UI.mechScrollHint = makeLabel(UI.mechanicsPanel, "DMC_MechScrollHint", "", "ZoFontGameSmall", C.muted, true)
    UI.mechScrollHint:SetAnchor(TOPRIGHT, UI.mechanicsPanel, TOPRIGHT, -42, 10)
    UI.mechScrollHint:SetDimensions(96, 22)

    UI.mechScrollTrack = wm:CreateControl("DMC_MechScrollTrack", UI.mechanicsPanel, CT_BACKDROP)
    UI.mechScrollTrack:SetAnchor(TOPRIGHT, UI.mechanicsPanel, TOPRIGHT, -16, 42)
    UI.mechScrollTrack:SetDimensions(12, 286)
    styleScrollbarTrack(UI.mechScrollTrack)
    -- Scrollbar is a visual position indicator; actual scrolling is mouse-wheel based for reliability across ESO UI contexts.

    UI.mechScrollThumb = wm:CreateControl("DMC_MechScrollThumb", UI.mechScrollTrack, CT_BACKDROP)
    styleScrollbarThumb(UI.mechScrollThumb)
    
    for i = 1, UI.mechanicPageSize do
        local row = wm:CreateControl("DMC_MechanicRow" .. i, UI.mechanicsPanel, CT_CONTROL)
        row:SetAnchor(TOPLEFT, UI.mechanicsPanel, TOPLEFT, 14, 40 + (i-1)*150)
        row:SetDimensions(762, 144)
        row.rowWidth = 762
        row:SetMouseEnabled(true)
        row:SetHandler("OnMouseWheel", function(_, delta) updateScrollFromWheel(delta) end)
        row.bg = makeBackdrop(row, "DMC_MechanicRow" .. i .. "_Bg", C.row, C.rowEdge, 0)

        row.title = makeLabel(row, "DMC_MechanicTitle" .. i, "", "ZoFontGameBold", C.gold, true)
        row.title:SetAnchor(TOPLEFT, row, TOPLEFT, 10, 6)
        row.title:SetDimensions(570, 22)

        -- Visual-only mechanic number. It helps users avoid re-pasting the same card after scrolling.
        -- This label is never included in pasted chat text.
        row.numberLabel = makeLabel(row, "DMC_MechanicNumber" .. i, "", "ZoFontWinH3", C.mechNumber, true)
        row.numberLabel:SetAnchor(TOPRIGHT, row, TOPRIGHT, -18, 5)
        row.numberLabel:SetDimensions(72, 26)
        if row.numberLabel.SetHorizontalAlignment and TEXT_ALIGN_RIGHT then row.numberLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT) end

        row.lineLabels = {}
        row.pasteButtons = {}
        for j = 1, UI.mechanicLineSlots do
            local label = makeLabel(row, "DMC_MechanicLine" .. i .. "_" .. j, "", "ZoFontGameSmall", C.text, false)
            label:SetAnchor(TOPLEFT, row, TOPLEFT, 10, 30 + (j-1)*36)
            label:SetDimensions(650, 34)
            row.lineLabels[j] = label

            local pb = makePill(row, "DMC_MechanicPaste" .. i .. "_" .. j, j == 1 and "Paste" or tostring(j), function(button)
                if button.chatText then
                    UI.selectedChatLine = button.chatText
                    DMC.PasteToChatInput(button.chatText)
                end
            end)
            pb:SetAnchor(TOPRIGHT, row, TOPRIGHT, -12, 30 + (j-1)*36)
            pb:SetDimensions(80, 24)
            row.pasteButtons[j] = pb
        end
        layoutMechanicRowLines(row, 1)
        UI.mechanicRows[i] = row
    end

    DMC.SetRoleFilter(UI.roleFilter)
    DMC.RefreshDungeonList()
end

local function isCameraUIModeActive()
    if IsGameCameraUIModeActive then return IsGameCameraUIModeActive() end
    return false
end

local function setGameCameraUIModeSafe(active)
    if SetGameCameraUIMode then SetGameCameraUIMode(active) end
end

local function enterCursorModeForCodex()
    -- Session-only UI helper: opening the codex should put the player in cursor/UI mode
    -- automatically, but closing it should only restore camera mode if this addon enabled it.
    UI.cursorModeWasActiveOnOpen = isCameraUIModeActive()
    UI.cursorModeActivatedByCodex = not UI.cursorModeWasActiveOnOpen
    setGameCameraUIModeSafe(true)

    -- A tiny delayed repeat makes this reliable when the window is opened from a slash command
    -- or keybind immediately after another UI state change.
    if zo_callLater then
        zo_callLater(function()
            if UI.window and not UI.window:IsHidden() then setGameCameraUIModeSafe(true) end
        end, 50)
    end
end

local function restoreCursorModeForCodex()
    local shouldRestore = UI.cursorModeActivatedByCodex
    UI.cursorModeActivatedByCodex = false
    UI.cursorModeWasActiveOnOpen = nil
    if not shouldRestore then return end

    local function restore()
        if UI.window and UI.window:IsHidden() then setGameCameraUIModeSafe(false) end
    end
    if zo_callLater then
        zo_callLater(restore, 50)
    else
        restore()
    end
end

function DMC.ShowWindow()
    if not UI.window then return end
    if not UI.window:IsHidden() then
        enterCursorModeForCodex()
        return
    end

    UI.window:SetHidden(false)
    local session = getSessionState()
    if isValidRoleFilter(session.roleFilter) then UI.roleFilter = session.roleFilter end
    DMC.RefreshDungeonList()
    if not UI.selectedDungeonId then
        local rememberedDungeonId = session.selectedDungeonId
        local rememberedBossId = session.selectedBossId
        if rememberedDungeonId and DMC.GetDungeonById(rememberedDungeonId) then
            DMC.SelectDungeon(rememberedDungeonId, rememberedBossId)
        else
            local dungeons = DMC.GetDungeonsSorted(UI.searchText)
            if dungeons[1] then DMC.SelectDungeon(dungeons[1].id) end
        end
    else
        DMC.RefreshBossDetails()
    end
    enterCursorModeForCodex()
end

function DMC.HideWindow()
    if not UI.window then return end
    UI.window:SetHidden(true)
    restoreCursorModeForCodex()
end

function DMC.ToggleWindow()
    if not UI.window then return end
    if UI.window:IsHidden() then
        DMC.ShowWindow()
    else
        DMC.HideWindow()
    end
end

function DMC.SetRoleFilter(role)
    UI.roleFilter = isValidRoleFilter(role) and role or "all"
    getSessionState().roleFilter = UI.roleFilter
    UI.mechanicScrollIndex = 1
    UI.selectedChatLine = nil
    setSelectedButton(UI.roleAll, UI.roleFilter == "all")
    setSelectedButton(UI.roleQuick, UI.roleFilter == "quick")
    setSelectedButton(UI.roleTank, UI.roleFilter == "tank")
    setSelectedButton(UI.roleHealer, UI.roleFilter == "healer")
    setSelectedButton(UI.roleDps, UI.roleFilter == "dps")
    DMC.RefreshBossDetails()
end

function DMC.RefreshDungeonList()
    local dungeons = DMC.GetDungeonsSorted(UI.searchText)
    local totalPages = math.max(1, math.ceil(#dungeons / UI.dungeonPageSize))
    if UI.dungeonPage > totalPages then UI.dungeonPage = totalPages end
    local startIndex = (UI.dungeonPage - 1) * UI.dungeonPageSize + 1

    for i, btn in ipairs(UI.dungeonButtons) do
        local dungeon = dungeons[startIndex + i - 1]
        if dungeon then
            local current = DMC.IsCurrentDungeon(dungeon)
            local marker = current and "★ " or ""
            local status = dungeon.status == "complete" and "" or " |c777777(stub)|r"
            btn:SetText(marker .. dungeon.name .. status)
            btn.dungeonId = dungeon.id
            btn:SetHidden(false)
            setSelectedButton(btn, dungeon.id == UI.selectedDungeonId or current)
            if current and dungeon.id ~= UI.selectedDungeonId then btn:SetNormalFontColor(0.48, 1.0, 0.72, 1) end
        else
            btn:SetText("")
            btn.dungeonId = nil
            btn:SetHidden(true)
        end
    end
    UI.pageLabel:SetText(UI.dungeonPage .. "/" .. totalPages)
end

function DMC.SelectDungeon(dungeonId, preferredBossId)
    local dungeon = DMC.GetDungeonById(dungeonId)
    if not dungeon then return end
    local previousDungeonId = UI.selectedDungeonId
    local previousBossId = UI.selectedBossId
    local session = getSessionState()
    local rememberedBossId = (session.selectedDungeonId == dungeonId) and session.selectedBossId or nil

    UI.selectedDungeonId = dungeonId
    session.selectedDungeonId = dungeonId
    UI.mechanicScrollIndex = 1
    UI.selectedChatLine = nil

    UI.dungeonTitle:SetText(dungeon.name .. "  |c777777" .. (dungeon.dlc or "DLC") .. "|r")
    UI.statusLabel:SetText(dungeon.status == "complete" and "|c66ff99Hard Mode Ready|r" or "|caaaaaaStub|r")
    local statusText = dungeon.status == "complete" and "" or " |caaaaaaDataset stub: mechanics not written yet.|r"
    setSummaryText("dungeon", getDungeonSummaryText(dungeon) .. statusText)

    local dungeonChatLines = DMC.BuildDungeonChatLines(dungeon)
    for i, pb in ipairs(UI.dungeonPasteButtons) do
        local line = dungeonChatLines[i]
        setPasteButton(pb, line, i == 1 and (#dungeonChatLines > 1 and "Paste 1" or "Paste note") or tostring(i))
    end

    for i, btn in ipairs(UI.bossButtons) do
        local boss = dungeon.bosses and dungeon.bosses[i]
        if boss then
            btn:SetText(boss.name .. shortFlags(boss))
            btn.bossId = boss.id
            btn:SetHidden(false)
        else
            btn:SetText("")
            btn.bossId = nil
            btn:SetHidden(true)
        end
    end

    if dungeon.bosses and dungeon.bosses[1] then
        local targetBossId = preferredBossId
        if not targetBossId and previousDungeonId == dungeonId then targetBossId = previousBossId end
        if not targetBossId then targetBossId = rememberedBossId end
        if targetBossId and DMC.GetBossById(dungeon, targetBossId) then
            DMC.SelectBoss(targetBossId)
        else
            DMC.SelectBoss(dungeon.bosses[1].id)
        end
    else
        UI.selectedBossId = nil
        session.selectedBossId = nil
        DMC.RefreshBossDetails()
    end
    DMC.RefreshDungeonList()
end

function DMC.SelectBoss(bossId)
    UI.selectedBossId = bossId
    getSessionState().selectedBossId = bossId
    UI.mechanicScrollIndex = 1
    UI.selectedChatLine = nil
    DMC.RefreshBossDetails()
end

local function updateMechanicScrollControls(total)
    if total and total > UI.mechanicPageSize then
        local lastVisible = math.min(total, UI.mechanicScrollIndex + UI.mechanicPageSize - 1)
        UI.mechScrollHint:SetText(UI.mechanicScrollIndex .. "-" .. lastVisible .. " / " .. total)
    else
        UI.mechScrollHint:SetText(total and total > 0 and (total .. " / " .. total) or "")
    end
    updateScrollbarThumb(total or 0)
end

function DMC.RefreshBossDetails(fromSlider)
    for _, btn in ipairs(UI.bossButtons) do
        setSelectedButton(btn, btn.bossId and btn.bossId == UI.selectedBossId)
    end
    setSelectedButton(UI.roleAll, UI.roleFilter == "all")
    setSelectedButton(UI.roleQuick, UI.roleFilter == "quick")
    setSelectedButton(UI.roleTank, UI.roleFilter == "tank")
    setSelectedButton(UI.roleHealer, UI.roleFilter == "healer")
    setSelectedButton(UI.roleDps, UI.roleFilter == "dps")

    local dungeon = DMC.GetDungeonById(UI.selectedDungeonId)
    local boss = DMC.GetBossById(dungeon, UI.selectedBossId)
    if not boss then
        setTextSafe(UI.bossTitle, "")
        setSummaryText("boss", "No boss data yet.")
        for _, pb in ipairs(UI.bossPasteButtons) do setPasteButton(pb, nil) end
        UI.mechScrollHint:SetText("")
        updateScrollbarThumb(0)
        for _, row in ipairs(UI.mechanicRows) do row:SetHidden(true) end
        return
    end

    UI.bossTitle:SetText(boss.name .. shortFlags(boss))
    if fromSlider then
        refreshSummaryDisplay("boss")
    else
        setSummaryText("boss", getBossSummaryText(boss))
    end
    local bossLines = DMC.BuildBossChatLines(dungeon, boss)
    for i, pb in ipairs(UI.bossPasteButtons) do
        local line = bossLines[i]
        setPasteButton(pb, line, i == 1 and (#bossLines > 1 and "Paste 1" or "Paste boss") or tostring(i))
    end

    local matching = {}
    for _, mech in ipairs(boss.mechanics or {}) do
        if DMC.MechanicMatchesRole(mech, UI.roleFilter) then table.insert(matching, mech) end
    end

    UI.currentMechanicCount = #matching
    local maxStart = getMaxScrollStart(#matching)
    if UI.mechanicScrollIndex > maxStart then UI.mechanicScrollIndex = maxStart end
    if UI.mechanicScrollIndex < 1 then UI.mechanicScrollIndex = 1 end
    updateMechanicScrollControls(#matching)

    if #matching == 0 then
        for i, row in ipairs(UI.mechanicRows) do
            if i == 1 then
                row:SetHidden(false)
                row.title:SetText(UI.roleFilter == "quick" and "Quick callouts" or "No mechanics")
                layoutMechanicRowLines(row, 1)
                if row.numberLabel then row.numberLabel:SetText(""); row.numberLabel:SetHidden(true) end
                row.lineLabels[1]:SetText(UI.roleFilter == "quick" and "No Quick callouts are written for this boss yet. Use Full for the complete mechanic explanations." or "No mechanics match this view.")
                row.lineLabels[1]:SetHidden(false)
                for j = 2, UI.mechanicLineSlots do
                    row.lineLabels[j]:SetText("")
                    row.lineLabels[j]:SetHidden(true)
                end
                for _, pb in ipairs(row.pasteButtons) do setPasteButton(pb, nil) end
            else
                row:SetHidden(true)
            end
        end
        return
    end

    local startIndex = UI.mechanicScrollIndex
    for i, row in ipairs(UI.mechanicRows) do
        local mech = matching[startIndex + i - 1]
        if mech then
            row:SetHidden(false)
            -- The paste lines below already include the exact [TAG]/role prefix.
            -- Keep the row title clean so the UI does not visually duplicate tags.
            local title = DMC.GetMechanicLabel(mech)
            row.title:SetText(title)
            if row.numberLabel then
                row.numberLabel:SetText(tostring(startIndex + i - 1))
                row.numberLabel:SetHidden(false)
            end

            local chatLines = DMC.BuildMechanicChatLines(dungeon, boss, mech, UI.roleFilter)
            layoutMechanicRowLines(row, math.min(#chatLines, UI.mechanicLineSlots))
            for j = 1, UI.mechanicLineSlots do
                local line = chatLines[j]
                if line then
                    row.lineLabels[j]:SetText(stripForUI(line))
                    row.lineLabels[j]:SetHidden(false)
                    setPasteButton(row.pasteButtons[j], line, j == 1 and (#chatLines > 1 and "Paste 1" or "Paste") or tostring(j))
                else
                    row.lineLabels[j]:SetText("")
                    row.lineLabels[j]:SetHidden(true)
                    setPasteButton(row.pasteButtons[j], nil)
                end
            end
        else
            if row.numberLabel then row.numberLabel:SetText(""); row.numberLabel:SetHidden(true) end
            row:SetHidden(true)
        end
    end
end

function DMC.PasteSelectedChatLine()
    if UI.selectedChatLine then
        DMC.PasteToChatInput(UI.selectedChatLine)
        return
    end
    local dungeon = DMC.GetDungeonById(UI.selectedDungeonId)
    local boss = DMC.GetBossById(dungeon, UI.selectedBossId)
    local lines = DMC.BuildBossChatLines(dungeon, boss)
    if lines[1] then
        DMC.PasteToChatInput(lines[1])
    else
        DMC.Print("No selected mechanic chat line yet.")
    end
end
