MechanicMentor = MechanicMentor or {}
local DM = MechanicMentor

-- v0.8.1: Craglorn trial mechanics data injected. No chat/share controls.
-- X/O are select/back. L2/R2 switch Base Game/DLC dungeon tabs.
-- L1/R1 navigate rows or select mechanics. No boss-summary linking or favourites.

local TOP = 52
-- Native console menu content well: do not draw over the left ESO menu column
-- or the native footer. The guide lives between the two vertical UI rails.
local LEFT = 610
local RIGHT = 110
-- Stop content at the native gold divider above the controller button bar.
local BOTTOM = 226
local HEADER_H = 108
local ROW_H = 66
local MECH_ROW_H = 104
local ROW_GAP = 8
local CARD_PAD = 0
local ROW_TEXT_X = 44
local ROW_ICON_X = 0
local ROW_MARKER_X = 0
local LIST_FRAME_X = 0
local LIST_TEXT_X = 0
-- Single OCD-safe vertical guide: title, breadcrumb, page title, tabs, dungeon rows, boss rows, and mechanic text all start here.
local HEADER_TEXT_X = LEFT
local SHARED_CONTENT_X = 0
-- List rows require their own visible-page inset to match the mechanics page
-- visual start on console. This keeps dungeon/boss names aligned under
-- Select Dungeon / Select Boss rather than drifting into the left rail.
local LIST_PAGE_TEXT_X = 0

local function SafeFont(font, fallback)
    return font or fallback or "ZoFontGamepad34"
end

local function Label(parent, font, r, g, b, a)
    local c = CreateControl(nil, parent, CT_LABEL)
    c:SetFont(SafeFont(font, "ZoFontGamepad34"))
    c:SetColor(r or 1, g or 1, b or 1, a or 1)
    c:SetWrapMode(TEXT_WRAP_MODE_WORD)
    c:SetMaxLineCount(0)
    return c
end

local function Backdrop(parent, alpha)
    local bg = CreateControl(nil, parent, CT_BACKDROP)
    bg:SetAnchorFill(parent)
    bg:SetCenterColor(0.015, 0.015, 0.015, alpha or 0.88)
    bg:SetEdgeColor(0.62, 0.54, 0.36, 0.72)
    bg:SetEdgeTexture("EsoUI/Art/Miscellaneous/edgebox_edge.dds", 128, 16)
    return bg
end

local HideSimpleRows

local function HidePool(pool)
    if not pool then return end
    for _, control in ipairs(pool) do
        if control then control:SetHidden(true) end
    end
end

local function ResetPools()
    HidePool(DM.dungeonRows)
    HidePool(DM.bossRows)
    HidePool(DM.mechanicRows)
    if DM.mechanicCard then DM.mechanicCard:SetHidden(true) end
    HideSimpleRows()
end

local function CleanSentence(text)
    text = DM.Plain(text or "")
    if text == "" then return "" end
    text = text:gsub("%s+([,%.%!%?%;:])", "%1")
    text = text:gsub("([,%;:])([^%s])", "%1 %2")
    text = text:gsub("%.%.+", ".")
    text = text:gsub("^%l", string.upper)
    if not text:match("[%.%!%?%)%]]$") then text = text .. "." end
    return text
end

local function TwoLineText(text, maxChars, maxLines, minLines)
    -- Adaptive mechanic description wrapping.
    -- Default visual height is 2 lines; longer descriptions can expand up to 4.
    text = tostring(text or ""):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
    maxChars = maxChars or 120
    maxLines = maxLines or 4
    minLines = minLines or 2

    local lines = {}
    while text ~= "" and #lines < maxLines do
        if #text <= maxChars then
            table.insert(lines, text)
            text = ""
        else
            local breakAt = maxChars
            for i = maxChars, math.max(1, maxChars - 24), -1 do
                local ch = text:sub(i, i)
                if ch == " " or ch == "," or ch == ";" then
                    breakAt = i
                    break
                end
            end
            table.insert(lines, (text:sub(1, breakAt):gsub("[,;%s]+$", "")))
            text = text:sub(breakAt + 1):gsub("^%s+", "")
        end
    end

    if text ~= "" and #lines > 0 then
        lines[#lines] = lines[#lines]:gsub("%s+%S*$", "") .. "..."
    end

    local visualLineCount = zo_clamp(math.max(#lines, minLines), minLines, maxLines)
    return table.concat(lines, "\n"), visualLineCount
end

local function GetMechanicRowHeight(lineCount)
    lineCount = zo_clamp(lineCount or 2, 2, 4)
    -- title line + controlled description block + breathing space
    return 44 + (lineCount * 24) + 16
end

local function TitleCaseMechanic(text)
    text = DM.Plain(text or "Mechanic")
    if text == "" then return "Mechanic" end
    text = text:gsub("_", " ")
    text = text:gsub("%s+", " ")
    text = text:gsub("^%l", string.upper)
    return text
end


local function RowPoolGet(poolName, parent, slot, rowHeight)
    DM[poolName] = DM[poolName] or {}
    local pool = DM[poolName]
    local row = pool[slot]
    if not row then
        row = CreateControl(nil, parent, CT_CONTROL)
        row.bg = CreateControl(nil, row, CT_BACKDROP)
        row.bg:SetAnchorFill(row)
        -- Subtle row tint only; avoids the heavy addon-looking black panel.
        row.bg:SetCenterColor(0, 0, 0, 0.34)
        row.bg:SetEdgeColor(0, 0, 0, 0)
        row.highlight = CreateControl(nil, row, CT_TEXTURE)
        row.highlight:SetAnchorFill(row)
        row.highlight:SetTexture("EsoUI/Art/Miscellaneous/listItem_highlight.dds")
        -- Do not use ESO's blue/cyan highlight. Selection is shown with a
        -- gold row edge, brighter title, and a small diamond marker.
        row.highlight:SetHidden(true)
        row.marker = Label(row, "ZoFontGamepad34", 0.98, 0.82, 0.38, 1)
        row.marker:SetText("◆")
        row.icon = CreateControl(nil, row, CT_TEXTURE)
        row.title = Label(row, "ZoFontGamepad34", 1, 1, 1, 1)
        row.subtitle = Label(row, "ZoFontGamepad22", 0.82, 0.76, 0.62, 1)
        row.arrow = Label(row, "ZoFontGamepad34", 0.86, 0.80, 0.62, 1)
        pool[slot] = row
    end
    rowHeight = rowHeight or ROW_H
    row.rowHeight = rowHeight
    row:SetParent(parent)
    row:ClearAnchors()
    row:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, (slot - 1) * (rowHeight + ROW_GAP))
    row:SetAnchor(TOPRIGHT, parent, TOPRIGHT, 0, (slot - 1) * (rowHeight + ROW_GAP))
    row:SetHeight(rowHeight)
    row:SetHidden(false)
    return row
end

local function SetupRow(row, selected, title, subtitle, icon, showArrow)
    local rowHeight = row.rowHeight or ROW_H
    -- Keep every visual element inside the native content frame.
    -- Blue highlight is intentionally disabled; selected rows use gold accents.
    row.highlight:SetHidden(true)
    row.bg:SetCenterColor(0, 0, 0, selected and 0.48 or 0.28)
    row.bg:SetEdgeColor(selected and 0.92 or 0, selected and 0.76 or 0, selected and 0.38 or 0, selected and 0.95 or 0)
    row.marker:ClearAnchors()
    row.marker:SetAnchor(LEFT, row, LEFT, ROW_MARKER_X, 0)
    row.marker:SetDimensions(42, rowHeight)
    row.marker:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    row.marker:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    row.marker:SetHidden(true) -- v0.4.0: no diamond selector; selection uses gold outline only

    row.icon:SetHidden(icon == nil)
    local x = ROW_TEXT_X
    if icon then
        row.icon:ClearAnchors()
        row.icon:SetAnchor(LEFT, row, LEFT, ROW_ICON_X, 0)
        row.icon:SetDimensions(42, 42)
        row.icon:SetTexture(icon)
        x = ROW_TEXT_X + 42
    end

    row.title:ClearAnchors()
    row.title:SetFont(selected and "ZoFontGamepad34" or "ZoFontGamepad27")
    row.title:SetColor(selected and 0.98 or 1, selected and 0.86 or 1, selected and 0.52 or 1, 1)
    row.title:SetText(title or "")
    row.title:SetMaxLineCount(1)
    row.title:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    row.title:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    row.title:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    row.subtitle:ClearAnchors()
    row.subtitle:SetText(subtitle or "")
    row.subtitle:SetMaxLineCount(2)
    row.subtitle:SetWrapMode(TEXT_WRAP_MODE_WORD)
    row.subtitle:SetHorizontalAlignment(TEXT_ALIGN_LEFT)

    if subtitle and subtitle ~= "" then
        row.title:SetAnchor(TOPLEFT, row, TOPLEFT, x, 7)
        row.title:SetAnchor(TOPRIGHT, row, TOPRIGHT, -72, 7)
        row.title:SetHeight(34)
        row.subtitle:SetAnchor(TOPLEFT, row, TOPLEFT, x + 24, 42)
        row.subtitle:SetAnchor(TOPRIGHT, row, TOPRIGHT, -72, 42)
        row.subtitle:SetHeight(rowHeight - 44)
        row.subtitle:SetHidden(false)
    else
        row.title:SetAnchor(LEFT, row, LEFT, x, 0)
        row.title:SetAnchor(RIGHT, row, RIGHT, -72, 0)
        row.title:SetHeight(rowHeight)
        row.subtitle:SetHidden(true)
    end

    row.arrow:ClearAnchors()
    row.arrow:SetText("")
    row.arrow:SetHidden(true)
end

local function SetupListRow(row, selected, title)
    local rowHeight = row.rowHeight or ROW_H
    row.highlight:SetHidden(true)
    row.marker:SetHidden(true)
    row.icon:SetHidden(true)
    row.subtitle:SetHidden(true)
    row.arrow:SetHidden(true)

    -- v0.4.5: remove the gold selection frame entirely. The selected row is
    -- indicated by yellow text only, matching the cleaner native menu feel.
    -- Text is aligned directly with the "Select Dungeon/Boss" page title.
    row.bg:ClearAnchors()
    row.bg:SetAnchorFill(row)
    row.bg:SetCenterColor(0, 0, 0, 0)
    row.bg:SetEdgeColor(0, 0, 0, 0)

    row.title:ClearAnchors()
    row.title:SetFont(selected and "ZoFontGamepad34" or "ZoFontGamepad27")
    row.title:SetColor(selected and 0.98 or 1, selected and 0.86 or 1, selected and 0.52 or 1, 1)
    row.title:SetText(title or "")
    row.title:SetMaxLineCount(1)
    row.title:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    row.title:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    row.title:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    -- v0.5.0: dungeon/boss rows use the same visible inset as the
    -- mechanics page content so list pages visually match the polished
    -- mechanics page rather than sitting against the left rail.
    row.title:SetAnchor(LEFT, row, LEFT, LIST_PAGE_TEXT_X, 0)
    row.title:SetAnchor(RIGHT, row, RIGHT, -74, 0)
    row.title:SetHeight(rowHeight)
end


-- v0.5.1: dedicated simple list rows. These do not use the older row pool
-- offsets at all; they anchor directly to DM.content, the same content well used
-- by pageTitle/tabs/mechanics. This prevents dungeon/boss rows drifting into
-- the left rail.
HideSimpleRows = function()
    if not DM.simpleRows then return end
    for _, row in ipairs(DM.simpleRows) do
        row:SetHidden(true)
    end
end

local function SimpleRowGet(slot)
    DM.simpleRows = DM.simpleRows or {}
    local row = DM.simpleRows[slot]
    if not row then
        row = CreateControl(nil, DM.content, CT_CONTROL)
        row.label = Label(row, "ZoFontGamepad34", 1, 1, 1, 1)
        row.label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        row.label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        row.label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
        DM.simpleRows[slot] = row
    end
    row:SetParent(DM.content)
    row:ClearAnchors()
    row:SetAnchor(TOPLEFT, DM.content, TOPLEFT, 0, (slot - 1) * (ROW_H + ROW_GAP))
    row:SetAnchor(TOPRIGHT, DM.content, TOPRIGHT, 0, (slot - 1) * (ROW_H + ROW_GAP))
    row:SetHeight(ROW_H)
    row:SetHidden(false)
    row.label:ClearAnchors()
    row.label:SetAnchorFill(row)
    return row
end

local function SetupSimpleRow(row, selected, title)
    row.label:SetText(title or "")
    row.label:SetFont(selected and "ZoFontGamepad34" or "ZoFontGamepad27")
    row.label:SetColor(selected and 0.98 or 1, selected and 0.86 or 1, selected and 0.52 or 1, 1)
    row.label:SetMaxLineCount(1)
end

function DM.CreateKeybinds()
    -- Use ESO native gamepad shortcut actions. These are already bound by the
    -- console UI, so the keybind strip should show real buttons instead of
    -- "Not Bound". No custom Bindings.xml actions are required.
    DM.keybindStripDescriptor = {
        alignment = KEYBIND_STRIP_ALIGN_RIGHT,
        { name = "Select", keybind = "UI_SHORTCUT_PRIMARY", callback = function() DM.Select() end, visible = function() return true end },
        { name = "Back", keybind = "UI_SHORTCUT_NEGATIVE", callback = function() DM.Back() end, visible = function() return true end },
        { name = "Previous", keybind = "UI_SHORTCUT_LEFT_SHOULDER", callback = function() DM.Move(-1) end, visible = function() return true end },
        { name = "Next", keybind = "UI_SHORTCUT_RIGHT_SHOULDER", callback = function() DM.Move(1) end, visible = function() return true end },
        { name = "Base Game", keybind = "UI_SHORTCUT_LEFT_TRIGGER", callback = function() DM.SetDungeonCategory("base") end, visible = function() return (DM.level or 1) == 1 and (DM.contentMode or "dungeon") == "dungeon" end },
        { name = "DLC", keybind = "UI_SHORTCUT_RIGHT_TRIGGER", callback = function() DM.SetDungeonCategory("dlc") end, visible = function() return (DM.level or 1) == 1 and (DM.contentMode or "dungeon") == "dungeon" end },
    }
end

function DM.AddKeybinds()
    DM.CreateKeybinds()
    if KEYBIND_STRIP and DM.keybindStripDescriptor then
        if DM.keybindsAdded and KEYBIND_STRIP.UpdateKeybindButtonGroup then
            KEYBIND_STRIP:UpdateKeybindButtonGroup(DM.keybindStripDescriptor)
        elseif not DM.keybindsAdded then
            KEYBIND_STRIP:AddKeybindButtonGroup(DM.keybindStripDescriptor)
            DM.keybindsAdded = true
        end
    end
end

function DM.RemoveKeybinds()
    if KEYBIND_STRIP and DM.keybindStripDescriptor and DM.keybindsAdded then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(DM.keybindStripDescriptor)
        DM.keybindsAdded = false
    end
end

function DM.RefreshKeybinds()
    if KEYBIND_STRIP and DM.keybindStripDescriptor and DM.keybindsAdded and KEYBIND_STRIP.UpdateKeybindButtonGroup then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(DM.keybindStripDescriptor)
    end
end

function DM.OnSceneShowing()
    if DM.root then DM.root:SetHidden(false) end
    DM.AddKeybinds()
    DM.RefreshUI()
end

function DM.OnSceneHiding()
    DM.RemoveKeybinds()
    if DM.root then DM.root:SetHidden(true) end
end

function DM.Move(delta)
    if DM.contentMode == "trialLocked" then return end
    delta = delta or 0
    if DM.level == 1 then
        if DM.contentMode == "trial" then
            if not DM.trials then DM.trials = DM.GetAllTrials() end
            local count = #(DM.trials or {})
            if count > 0 then
                DM.selectedTrialIndex = zo_clamp((DM.selectedTrialIndex or 1) + delta, 1, count)
            end
        else
            local count = #(DM.dungeons or {})
            if count > 0 then
                DM.selectedDungeonIndex = zo_clamp((DM.selectedDungeonIndex or 1) + delta, 1, count)
                local dng = DM.dungeons[DM.selectedDungeonIndex]
                if dng then
                    DM.selectedDungeonId = dng.zoneId
                    if DM.savedVars then DM.savedVars.lastDungeonId = dng.zoneId end
                end
            end
        end
    elseif DM.level == 2 then
        local content = DM.contentMode == "trial" and DM.GetSelectedTrialData() or DM.GetSelectedDungeonData()
        local count = content and content.bosses and #content.bosses or 1
        DM.selectedBossIndex = zo_clamp((DM.selectedBossIndex or 1) + delta, 1, count)
        DM.selectedMechanicIndex = 1
    else
        local boss = DM.GetSelectedBoss()
        local count = boss and boss.mechanics and #boss.mechanics or 1
        if count > 0 then
            local selected = zo_clamp((DM.selectedMechanicIndex or DM.mechanicScrollIndex or 1) + delta, 1, count)
            DM.selectedMechanicIndex = selected
            local startIndex = DM.mechanicScrollIndex or 1
            local lastVisible = DM.lastMechanicVisibleEnd or startIndex
            if selected < startIndex then
                DM.mechanicScrollIndex = selected
            elseif selected > lastVisible then
                DM.mechanicScrollIndex = selected
            end
        end
    end
    DM.RefreshUI()
end

function DM.Select()
    if DM.contentMode == "trialLocked" then return end
    if DM.level == 1 then
        DM.level = 2
        DM.selectedBossIndex = 1
        DM.selectedMechanicIndex = 1
    elseif DM.level == 2 then
        DM.level = 3
        DM.selectedMechanicIndex = 1
        DM.mechanicScrollIndex = 1
    elseif DM.level == 3 then
        return
    end
    DM.RefreshUI()
end

function DM.Back()
    if (DM.level or 1) > 1 then
        DM.level = DM.level - 1
        DM.RefreshUI()
    else
        DM.Close()
    end
end

function DM.CreateUI()
    if DM.root then return end

    local root = CreateTopLevelWindow("MechanicMentorGuideRoot")
    root:SetAnchorFill(GuiRoot)
    root:SetHidden(true)
    root:SetMouseEnabled(false)
    root:SetMovable(false)
    DM.root = root

    -- No full-screen/addon backdrop. The native ESO gamepad menu already
    -- provides the darkened content well and footer rails.

    DM.title = Label(root, "ZoFontGamepad42", 1, 1, 1, 1)
    DM.title:SetAnchor(TOPLEFT, root, TOPLEFT, HEADER_TEXT_X, TOP)
    DM.title:SetAnchor(TOPRIGHT, root, TOPRIGHT, -RIGHT, TOP)
    DM.title:SetHeight(44)
    DM.title:SetText("MECHANIC MENTOR")

    DM.breadcrumb = Label(root, "ZoFontGamepad27", 0.78, 0.72, 0.58, 1)
    DM.breadcrumb:SetAnchor(TOPLEFT, root, TOPLEFT, HEADER_TEXT_X, TOP + 52)
    DM.breadcrumb:SetAnchor(TOPRIGHT, root, TOPRIGHT, -RIGHT, TOP + 52)
    DM.breadcrumb:SetHeight(32)

    DM.mainPanel = CreateControl(nil, root, CT_CONTROL)
    DM.mainPanel:SetAnchor(TOPLEFT, root, TOPLEFT, LEFT, TOP + HEADER_H)
    DM.mainPanel:SetAnchor(BOTTOMRIGHT, root, BOTTOMRIGHT, -RIGHT, -BOTTOM)
    -- Keep the main content control transparent so it nests inside the native UI.

    DM.pageTitle = Label(DM.mainPanel, "ZoFontGamepad34", 0.98, 0.82, 0.38, 1)
    DM.pageTitle:SetAnchor(TOPLEFT, DM.mainPanel, TOPLEFT, CARD_PAD, 24)
    DM.pageTitle:SetAnchor(TOPRIGHT, DM.mainPanel, TOPRIGHT, -CARD_PAD, 24)
    DM.pageTitle:SetHeight(42)

    DM.pageCounter = Label(DM.mainPanel, "ZoFontGamepad22", 0.72, 0.70, 0.62, 1)
    DM.pageCounter:SetAnchor(TOPRIGHT, DM.mainPanel, TOPRIGHT, -CARD_PAD, 66)
    DM.pageCounter:SetDimensions(220, 28)
    DM.pageCounter:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

    -- Clean compact header. No long instruction text; controls live top-right.
    DM.pageHint = Label(DM.mainPanel, "ZoFontGamepad22", 0.76, 0.72, 0.62, 1)
    DM.pageHint:SetAnchor(TOPLEFT, DM.mainPanel, TOPLEFT, CARD_PAD, 68)
    DM.pageHint:SetAnchor(TOPRIGHT, DM.mainPanel, TOPRIGHT, -CARD_PAD, 68)
    DM.pageHint:SetHeight(28)

    DM.tabs = CreateControl(nil, DM.mainPanel, CT_CONTROL)
    DM.tabs:SetAnchor(TOPLEFT, DM.mainPanel, TOPLEFT, CARD_PAD, 64)
    DM.tabs:SetDimensions(560, 40)
    DM.tabBase = Label(DM.tabs, "ZoFontGamepad27", 0.9, 0.82, 0.56, 1)
    DM.tabBase:SetAnchor(LEFT, DM.tabs, LEFT, 0, 0)
    DM.tabBase:SetDimensions(250, 36)
    DM.tabDlc = Label(DM.tabs, "ZoFontGamepad27", 0.9, 0.82, 0.56, 1)
    DM.tabDlc:SetAnchor(LEFT, DM.tabs, LEFT, 260, 0)
    DM.tabDlc:SetDimensions(250, 36)

    DM.controlsTop = Label(DM.mainPanel, "ZoFontGamepad22", 0.82, 0.78, 0.64, 1)
    DM.controlsTop:SetAnchor(TOPRIGHT, DM.mainPanel, TOPRIGHT, -CARD_PAD, 30)
    DM.controlsTop:SetDimensions(760, 30)
    DM.controlsTop:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    DM.controlsTop:SetHidden(true)

    DM.content = CreateControl(nil, DM.mainPanel, CT_CONTROL)
    DM.content:SetAnchor(TOPLEFT, DM.mainPanel, TOPLEFT, CARD_PAD, 112)
    DM.content:SetAnchor(BOTTOMRIGHT, DM.mainPanel, BOTTOMRIGHT, -CARD_PAD, -CARD_PAD)

    -- Single mechanic card; avoids the cluttered stacked-mechanic list.
    local card = CreateControl(nil, DM.content, CT_CONTROL)
    card:SetAnchorFill(DM.content)
    card:SetHidden(true)
    DM.mechanicCard = card

    card.icon = CreateControl(nil, card, CT_TEXTURE)
    card.type = Label(card, "ZoFontGamepad34", 0.98, 0.82, 0.38, 1)
    card.name = Label(card, "ZoFontGamepad27", 1, 1, 1, 1)
    card.body = Label(card, "ZoFontGamepad27", 0.90, 0.88, 0.80, 1)

    card.icon:SetAnchor(TOPLEFT, card, TOPLEFT, 28, 28)
    card.icon:SetDimensions(68, 68)
    card.type:SetAnchor(TOPLEFT, card, TOPLEFT, 132, 24)
    card.type:SetAnchor(TOPRIGHT, card, TOPRIGHT, -32, 24)
    card.type:SetHeight(42)
    card.name:SetAnchor(TOPLEFT, card, TOPLEFT, 132, 68)
    card.name:SetAnchor(TOPRIGHT, card, TOPRIGHT, -32, 68)
    card.name:SetHeight(42)
    card.body:SetAnchor(TOPLEFT, card, TOPLEFT, 36, 138)
    card.body:SetAnchor(BOTTOMRIGHT, card, BOTTOMRIGHT, -42, -48)

    DM.footerLeft = Label(root, "ZoFontGamepad27", 0.95, 0.95, 0.95, 1)
    DM.footerLeft:SetAnchor(BOTTOMLEFT, root, BOTTOMLEFT, LEFT, -46)
    DM.footerLeft:SetDimensions(1260, 36)
    DM.footerLeft:SetHidden(true)

    DM.footerRight = Label(root, "ZoFontGamepad22", 0.72, 0.72, 0.72, 1)
    DM.footerRight:SetAnchor(BOTTOMRIGHT, root, BOTTOMRIGHT, -RIGHT, -72)
    DM.footerRight:SetDimensions(420, 28)
    DM.footerRight:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    DM.footerRight:SetText("")
    DM.footerRight:SetHidden(true)

    -- Direct gamepad button handler. This is guarded by the scene action layer
    -- and gives D-pad routing a second path beyond keybind-strip shortcuts.
    root:SetHandler("OnGamepadButtonDown", function(_, button)
        if not DM.root or DM.root:IsHidden() then return end
        if (button == GAMEPAD_LEFT_TRIGGER or button == GAMEPAD_BUTTON_LEFT_TRIGGER) and (DM.level or 1) == 1 and (DM.contentMode or "dungeon") == "dungeon" then DM.SetDungeonCategory("base"); return true end
        if (button == GAMEPAD_RIGHT_TRIGGER or button == GAMEPAD_BUTTON_RIGHT_TRIGGER) and (DM.level or 1) == 1 and (DM.contentMode or "dungeon") == "dungeon" then DM.SetDungeonCategory("dlc"); return true end
        if button == GAMEPAD_LEFT_SHOULDER or button == GAMEPAD_BUTTON_LEFT_SHOULDER then DM.Move(-1); return true end
        if button == GAMEPAD_RIGHT_SHOULDER or button == GAMEPAD_BUTTON_RIGHT_SHOULDER then DM.Move(1); return true end
        if button == GAMEPAD_BUTTON_1 then DM.Select(); return true end
        if button == GAMEPAD_BUTTON_2 then DM.Back(); return true end
    end)
end

function DM.GetVisibleRowCount()
    if not DM.content then return 7 end
    local h = DM.content:GetHeight() or 500
    return math.max(3, math.floor(h / (ROW_H + ROW_GAP)))
end

function DM.GetVisibleMechanicCount(count)
    count = count or 0
    if count <= 0 then return 0 end
    if not DM.content then return math.min(2, count) end
    local h = DM.content:GetHeight() or 300
    local rows = math.floor(h / (MECH_ROW_H + ROW_GAP))
    rows = math.max(1, rows)
    return math.min(count, rows)
end

function DM.GetWindowStart(selectedIndex, count, visible)
    selectedIndex = selectedIndex or 1
    if count <= visible then return 1 end
    return zo_clamp(selectedIndex - math.floor(visible / 2), 1, count - visible + 1)
end


function DM.RefreshTrialsComingSoon()
    ResetPools()
    DM.pageTitle:SetText("Trials List")
    DM.pageHint:SetText("")
    if DM.tabs then DM.tabs:SetHidden(true) end
    DM.breadcrumb:SetText("Add-Ons  >  Mechanic Mentor  >  Trials")
    DM.footerLeft:SetText("")
    DM.controlsTop:SetText("")
    DM.pageCounter:SetText("")
    HideSimpleRows()

    local row = SimpleRowGet(1)
    SetupSimpleRow(row, true, DM.trialLockedMessage or "Trial content coming in a future update!")
    row.label:SetFont("ZoFontGamepad34")
    row.label:SetColor(0.70, 0.70, 0.70, 1)

    local row2 = SimpleRowGet(2)
    SetupSimpleRow(row2, false, "Dungeon content is available for public testing now.")
    row2.label:SetColor(0.62, 0.62, 0.62, 1)
end

function DM.RefreshTrials()
    ResetPools()
    DM.pageTitle:SetText("Select Trial")
    DM.pageHint:SetText("")
    if DM.tabs then DM.tabs:SetHidden(true) end
    DM.breadcrumb:SetText("Add-Ons  >  Mechanic Mentor  >  Trials")
    DM.footerLeft:SetText("")
    DM.controlsTop:SetText("")
    if not DM.trials then DM.trials = DM.GetAllTrials() end
    local count = #(DM.trials or {})
    DM.pageCounter:SetText(string.format("%d / %d", DM.selectedTrialIndex or 1, count))
    local visible = DM.GetVisibleRowCount()
    local start = DM.GetWindowStart(DM.selectedTrialIndex or 1, count, visible)
    HideSimpleRows()
    local slot = 1
    for i = start, math.min(count, start + visible - 1) do
        local trial = DM.trials[i]
        local row = SimpleRowGet(slot)
        SetupSimpleRow(row, i == DM.selectedTrialIndex, trial.name)
        slot = slot + 1
    end
end

function DM.RefreshTrialBosses()
    ResetPools()
    local trial = DM.GetSelectedTrialData()
    local tname = trial and DM.Plain(trial.name) or "Trial"
    DM.pageTitle:SetText("Select Trial Boss")
    DM.pageHint:SetText("")
    if DM.tabs then DM.tabs:SetHidden(true) end
    DM.breadcrumb:SetText("Add-Ons  >  Mechanic Mentor  >  Trials  >  " .. tname)
    DM.footerLeft:SetText("")
    DM.controlsTop:SetText("")
    if not trial or not trial.bosses then return end
    local count = #trial.bosses
    DM.pageCounter:SetText(string.format("%d / %d", DM.selectedBossIndex or 1, count))
    local visible = DM.GetVisibleRowCount()
    local start = DM.GetWindowStart(DM.selectedBossIndex or 1, count, visible)
    HideSimpleRows()
    local slot = 1
    for i = start, math.min(count, start + visible - 1) do
        local boss = trial.bosses[i]
        local row = SimpleRowGet(slot)
        local bossName = (DM.CleanBossName and DM.CleanBossName(boss.name or ("Boss " .. i))) or DM.Plain(boss.name or ("Boss " .. i))
        SetupSimpleRow(row, i == DM.selectedBossIndex, bossName)
        slot = slot + 1
    end
end

function DM.RefreshDungeons()
    ResetPools()
    local category = DM.dungeonCategory or "base"
    local tabText = category == "base" and "BASE GAME DUNGEONS" or "DLC DUNGEONS"
    DM.pageTitle:SetText("Select Dungeon")
    DM.pageHint:SetText("")
    if DM.tabs then DM.tabs:SetHidden(false) end
    if DM.tabBase then DM.tabBase:SetText(category == "base" and "|cEAD38C► BASE GAME|r" or "|c7F7F7F  BASE GAME|r") end
    if DM.tabDlc then DM.tabDlc:SetText(category == "dlc" and "|cEAD38C► DLC DUNGEONS|r" or "|c7F7F7F  DLC DUNGEONS|r") end
    DM.breadcrumb:SetText("Add-Ons  >  Mechanic Mentor")
    DM.footerLeft:SetText("")
    DM.controlsTop:SetText("")
    if not DM.dungeons then DM.dungeons = DM.GetFilteredDungeons(category) end
    local count = #(DM.dungeons or {})
    DM.pageCounter:SetText(string.format("%d / %d", DM.selectedDungeonIndex or 1, count))
    local visible = DM.GetVisibleRowCount()
    local start = DM.GetWindowStart(DM.selectedDungeonIndex or 1, count, visible)
    HideSimpleRows()
    local slot = 1
    for i = start, math.min(count, start + visible - 1) do
        local dng = DM.dungeons[i]
        local row = SimpleRowGet(slot)
        SetupSimpleRow(row, i == DM.selectedDungeonIndex, dng.name)
        slot = slot + 1
    end
end

function DM.RefreshBosses()
    ResetPools()
    local dungeon = DM.GetSelectedDungeonData()
    local dname = dungeon and DM.Plain(dungeon.name) or "Dungeon"
    DM.pageTitle:SetText("Select Boss")
    DM.pageHint:SetText("")
    if DM.tabs then DM.tabs:SetHidden(true) end
    DM.breadcrumb:SetText("Add-Ons  >  Mechanic Mentor  >  " .. dname)
    DM.footerLeft:SetText("")
    DM.controlsTop:SetText("")
    if not dungeon or not dungeon.bosses then return end
    local count = #dungeon.bosses
    DM.pageCounter:SetText(string.format("%d / %d", DM.selectedBossIndex or 1, count))
    local visible = DM.GetVisibleRowCount()
    local start = DM.GetWindowStart(DM.selectedBossIndex or 1, count, visible)
    HideSimpleRows()
    local slot = 1
    for i = start, math.min(count, start + visible - 1) do
        local boss = dungeon.bosses[i]
        local row = SimpleRowGet(slot)
        local bossName = (DM.CleanBossName and DM.CleanBossName(boss.name or ("Boss " .. i))) or DM.Plain(boss.name or ("Boss " .. i))
        SetupSimpleRow(row, i == DM.selectedBossIndex, bossName)
        slot = slot + 1
    end
end

function DM.RefreshMechanics()
    ResetPools()
    local content = DM.contentMode == "trial" and DM.GetSelectedTrialData() or DM.GetSelectedDungeonData()
    local boss = DM.GetSelectedBoss()
    local dname = content and DM.Plain(content.name) or (DM.contentMode == "trial" and "Trial" or "Dungeon")
    local bname = boss and DM.Plain(boss.name) or "Boss"
    DM.pageTitle:SetText(bname .. " - Mechanics")
    DM.pageHint:SetText("")
    if DM.tabs then DM.tabs:SetHidden(true) end
    if DM.contentMode == "trial" then
        DM.breadcrumb:SetText("Add-Ons  >  Mechanic Mentor  >  Trials  >  " .. dname .. "  >  " .. bname)
    else
        DM.breadcrumb:SetText("Add-Ons  >  Mechanic Mentor  >  " .. dname .. "  >  " .. bname)
    end
    DM.footerLeft:SetText("")
    DM.controlsTop:SetText("")
    if not boss or not boss.mechanics then
        DM.pageCounter:SetText("0 / 0")
        return
    end

    local count = #boss.mechanics
    if count <= 0 then
        DM.pageCounter:SetText("0 / 0")
        return
    end

    local contentHeight = DM.content and (DM.content:GetHeight() or 360) or 360
    DM.selectedMechanicIndex = zo_clamp(DM.selectedMechanicIndex or DM.mechanicScrollIndex or 1, 1, count)
    local startIndex = zo_clamp(DM.mechanicScrollIndex or DM.selectedMechanicIndex or 1, 1, count)
    if DM.selectedMechanicIndex < startIndex then startIndex = DM.selectedMechanicIndex end
    DM.mechanicScrollIndex = startIndex

    local y = 0
    local slot = 1
    local lastVisible = startIndex - 1

    for i = startIndex, count do
        local raw = boss.mechanics[i]
        local display = DM.GetMechanicDisplay and DM.GetMechanicDisplay(raw) or nil
        local mtype = display and display.mechanicType or DM.GetMechanicType(raw)
        local name = TitleCaseMechanic(display and display.name or DM.DeriveMechanicName(raw))
        local typeLabel = display and display.type or string.upper(mtype.label or "MECHANIC")
        if DM.IsHardModeMechanic and DM.IsHardModeMechanic(raw, display) and not typeLabel:find("%(HM%)") then
            typeLabel = typeLabel .. " (HM)"
        end
        local role = DM.GetMechanicRole and DM.GetMechanicRole(raw, display) or "all"
        local selectedRole = DM.GetSelectedRoleHighlight and DM.GetSelectedRoleHighlight() or "all"
        local bodyRaw = CleanSentence(display and display.description or raw)
        local body, lineCount = TwoLineText(bodyRaw, 120, 4, 2)
        local rowHeight = GetMechanicRowHeight(lineCount)

        if slot > 1 and (y + rowHeight) > contentHeight then
            break
        end

        local row = RowPoolGet("mechanicRows", DM.content, slot, rowHeight)
        row:ClearAnchors()
        row:SetAnchor(TOPLEFT, DM.content, TOPLEFT, 0, y)
        row:SetAnchor(TOPRIGHT, DM.content, TOPRIGHT, 0, y)
        row:SetHeight(rowHeight)

        local isSelectedMechanic = (i == (DM.selectedMechanicIndex or 1))
        row.highlight:SetHidden(true)
        row.marker:SetHidden(true)
        row.icon:SetHidden(true)
        row.arrow:SetHidden(true)
        row.bg:SetCenterColor(0, 0, 0, isSelectedMechanic and 0.36 or 0.22)
        if isSelectedMechanic then
            row.bg:SetEdgeColor(0.92, 0.76, 0.38, 0.85)
        else
            row.bg:SetEdgeColor(0, 0, 0, 0)
        end

        row.title:ClearAnchors()
        row.title:SetFont("ZoFontGamepad27")
        if selectedRole ~= "all" and role == selectedRole and DM.GetRoleColor then
            local rr, gg, bb = DM.GetRoleColor(role)
            row.title:SetColor(rr, gg, bb, 1)
        elseif isSelectedMechanic then
            row.title:SetColor(1.0, 0.90, 0.56, 1)
        else
            row.title:SetColor(0.98, 0.82, 0.38, 1)
        end
        row.title:SetText(string.upper(typeLabel or mtype.label or "MECHANIC") .. ": " .. name)
        row.title:SetMaxLineCount(1)
        row.title:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
        row.title:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        row.title:SetVerticalAlignment(TEXT_ALIGN_TOP)
        row.title:SetAnchor(TOPLEFT, row, TOPLEFT, SHARED_CONTENT_X, 8)
        row.title:SetAnchor(TOPRIGHT, row, TOPRIGHT, -24, 8)
        row.title:SetHeight(30)

        row.subtitle:SetHidden(false)
        row.subtitle:ClearAnchors()
        row.subtitle:SetColor(0.92, 0.90, 0.82, 1)
        row.subtitle:SetFont("ZoFontGamepad22")
        row.subtitle:SetText(body)
        row.subtitle:SetMaxLineCount(lineCount)
        row.subtitle:SetWrapMode(TEXT_WRAP_MODE_WORD)
        row.subtitle:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        row.subtitle:SetAnchor(TOPLEFT, row, TOPLEFT, SHARED_CONTENT_X, 42)
        row.subtitle:SetAnchor(TOPRIGHT, row, TOPRIGHT, -24, 42)
        row.subtitle:SetHeight(lineCount * 24 + 10)

        y = y + rowHeight + ROW_GAP
        lastVisible = i
        slot = slot + 1
    end

    if lastVisible < startIndex then
        lastVisible = startIndex
    end

    DM.lastMechanicVisibleEnd = lastVisible
    DM.lastMechanicVisibleCount = math.max(1, lastVisible - startIndex + 1)
    DM.pageCounter:SetText(string.format("Selected %d  |  %d-%d / %d", DM.selectedMechanicIndex or startIndex, startIndex, lastVisible, count))
end

function DM.RefreshUI()
    if not DM.root then return end
    if DM.contentMode == "trialLocked" then
        DM.RefreshTrialsComingSoon()
    elseif DM.contentMode == "trial" then
        if DM.level == 1 then
            DM.RefreshTrials()
        elseif DM.level == 2 then
            DM.RefreshTrialBosses()
        else
            DM.RefreshMechanics()
        end
    else
        if DM.level == 1 then
            DM.RefreshDungeons()
        elseif DM.level == 2 then
            DM.RefreshBosses()
        else
            DM.RefreshMechanics()
        end
    end
    if DM.RefreshKeybinds then DM.RefreshKeybinds() end
end


function MechanicMentor_MoveUp() DM.Move(-1) end
function MechanicMentor_MoveDown() DM.Move(1) end
function MechanicMentor_MovePrevious() DM.Move(-1) end
function MechanicMentor_MoveNext() DM.Move(1) end
function MechanicMentor_TabPrevious() DM.SwitchDungeonCategory(-1) end
function MechanicMentor_TabNext() DM.SwitchDungeonCategory(1) end
function MechanicMentor_Select() DM.Select() end
function MechanicMentor_Back() DM.Back() end
function MechanicMentor_LinkMechanic() end
function MechanicMentor_LinkBoss() end


function DM.CreateQuickSummaryUI()
    if DM.quickRoot then return end
    local root = CreateTopLevelWindow("MechanicMentorQuickSummaryRoot")
    root:SetDimensions(560, 120)
    -- Left-side gameplay panel, intended to sit under the boss name/health area.
    root:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -92, 138)
    root:SetHidden(true)
    root:SetMouseEnabled(false)
    if root.SetDrawLayer then root:SetDrawLayer(DL_OVERLAY) end
    if root.SetDrawTier then root:SetDrawTier(DT_HIGH) end
    if root.SetDrawLevel then root:SetDrawLevel(2000) end
    DM.quickRoot = root

    root.bg = Backdrop(root, 0.64)
    root.bg:SetEdgeColor(0.62, 0.54, 0.36, 0.62)

    root.title = Label(root, "ZoFontGamepad27", 0.98, 0.82, 0.38, 1)
    root.title:SetAnchor(TOPLEFT, root, TOPLEFT, 18, 12)
    root.title:SetAnchor(TOPRIGHT, root, TOPRIGHT, -18, 12)
    root.title:SetHeight(30)
    root.title:SetMaxLineCount(1)
    root.title:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)

    root.lines = {}
end

local function EstimateQuickLineCount(text, maxChars, minLines, maxLines)
    text = tostring(text or "")
    local estimate = math.ceil(math.max(1, #text) / maxChars)
    return zo_clamp(math.max(minLines, estimate), minLines, maxLines)
end

function DM.SetQuickSummaryPanel(bossName, bullets, fullMode)
    if not DM.quickRoot then DM.CreateQuickSummaryUI() end
    if not DM.quickRoot then return end
    bullets = bullets or {}
    if not bossName or #bullets == 0 then
        DM.quickRoot:SetHidden(true)
        return
    end

    local count = #bullets
    local font = fullMode and "ZoFontGamepad18" or "ZoFontGamepad20"
    local lineHeight = fullMode and 19 or 20
    local maxHeight = fullMode and 610 or 540
    local maxChars = fullMode and 62 or 70
    local minLines = fullMode and 2 or 1
    local maxLines = fullMode and 4 or 2

    local rowData = {}
    local totalRowsHeight = 0
    for i = 1, count do
        local lines = EstimateQuickLineCount(bullets[i], maxChars, minLines, maxLines)
        local rowH = (lines * lineHeight) + 8
        rowData[i] = { lines = lines, height = rowH }
        totalRowsHeight = totalRowsHeight + rowH
    end

    local h = 58 + totalRowsHeight + 14
    if h > maxHeight then
        -- Tighten once. Still preserve wrapping; avoid hard single-line clipping.
        font = "ZoFontGamepad18"
        lineHeight = 18
        maxChars = fullMode and 72 or 78
        totalRowsHeight = 0
        for i = 1, count do
            local lines = EstimateQuickLineCount(bullets[i], maxChars, minLines, maxLines)
            local rowH = (lines * lineHeight) + 6
            rowData[i] = { lines = lines, height = rowH }
            totalRowsHeight = totalRowsHeight + rowH
        end
        h = 58 + totalRowsHeight + 14
    end

    local scale = (DM.savedVars and DM.savedVars.quickPanelScale) or 1.0
    local opacity = ((DM.savedVars and DM.savedVars.quickPanelOpacity) or 64) / 100
    if DM.quickRoot.SetScale then DM.quickRoot:SetScale(scale) end
    if DM.quickRoot.bg then
        DM.quickRoot.bg:SetCenterColor(0.015, 0.015, 0.015, opacity)
        DM.quickRoot.bg:SetEdgeColor(0.62, 0.54, 0.36, math.min(1, opacity + 0.08))
    end
    DM.quickRoot:SetHeight(math.min(h, maxHeight))
    DM.quickRoot.title:SetText(string.upper(DM.Plain(bossName)))

    local y = 48
    for i = 1, count do
        local line = DM.quickRoot.lines[i]
        if not line then
            line = Label(DM.quickRoot, font, 0.93, 0.91, 0.82, 1)
            line:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
            DM.quickRoot.lines[i] = line
        end
        local data = rowData[i]
        line:ClearAnchors()
        line:SetAnchor(TOPLEFT, DM.quickRoot, TOPLEFT, 22, y)
        line:SetAnchor(TOPRIGHT, DM.quickRoot, TOPRIGHT, -18, y)
        line:SetHeight(data.height)
        line:SetFont(font)
        line:SetMaxLineCount(data.lines)
        line:SetWrapMode(TEXT_WRAP_MODE_WORD)
        line:SetText("• " .. tostring(bullets[i] or ""))
        line:SetHidden(false)
        y = y + data.height
    end

    for i = count + 1, #DM.quickRoot.lines do
        DM.quickRoot.lines[i]:SetHidden(true)
    end

    DM.quickRoot:SetHidden(false)
end

function DM.HideQuickSummaryPanel()
    if DM.quickRoot then DM.quickRoot:SetHidden(true) end
end
