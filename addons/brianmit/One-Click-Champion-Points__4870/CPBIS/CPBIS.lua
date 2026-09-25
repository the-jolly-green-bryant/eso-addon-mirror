-- CPBIS.lua : CP BIS Guide + one-click Champion Point profile apply.
-- Open with the "Champion points" button (top-left) or /cpbis

local ADDON_NAME = "CPBIS"
CPBIS = CPBIS or {}
local C = CPBIS

local defaults = { x = 300, y = 120, mode = "PVE", role = nil, classId = nil, docked = true, launcherX = 16, launcherY = 14, launcherHidden = false }

local COLOR = {
    warfare = "7FB2E5",
    fitness = "FF6B5A",
    craft   = "8FD17F",
    active  = "FF9A4D",
    idle    = "8F7D76",
    title   = "F2E6DE",
    text    = "E6D8D0",
    edge    = "59606B",
    panel   = "17191F",
}

-- Dropdown order, A to Z: Arcanist, Dragonknight, Necromancer, Nightblade, Sorcerer, Templar, Warden
local CLASS_ORDER = { 117, 1, 5, 3, 2, 6, 4 }
local CLASS_NAME = {
    [1] = "Dragonknight", [2] = "Sorcerer", [3] = "Nightblade", [4] = "Warden",
    [5] = "Necromancer", [6] = "Templar", [117] = "Arcanist",
}

local ROLE_NAME = { MAG = "Magicka", STAM = "Stamina", HEAL = "Healer", TANK = "Tank" }
local PVE_ONLY_ROLE = { HEAL = true, TANK = true }

-- ESO's own group-finder role icons.
local ROLE_ICON = {
    DD   = "EsoUI/Art/LFG/LFG_icon_dps.dds",
    TANK = "EsoUI/Art/LFG/LFG_icon_tank.dds",
    HEAL = "EsoUI/Art/LFG/LFG_icon_healer.dds",
}
local ROLE_ICON_SIZE = 22
local MAGICKA_COLOR, STAMINA_COLOR = "5AA9FF", "6FD36F"

local WIN_W, WIN_H = 700, 736
local ICON_W, ICON_H = 84, 42   -- tree logo above each column (cosmetic)
local COL_W, COL_GAP = 210, 16
local ui = {}

-- Passives block layout
local PASSIVE_TREES = { "warfare", "fitness", "craft" }
local PASSIVE_NAME_W = 84      -- width of the "Warfare / Fitness / Craft" column
local PASSIVE_ROW_GAP = 8      -- extra space between the three tree rows
local PASSIVE_WRAP_CHARS = 72  -- wrap long lists between entries, never inside one

local function DetectRole()
    if GetPlayerStat(STAT_STAMINA_MAX) > GetPlayerStat(STAT_MAGICKA_MAX) then return "STAM" end
    return "MAG"
end

local function GetBuild(classId, mode, role)
    local base = C.Data[mode] and C.Data[mode][role]
    if not base then return nil end
    local ov = C.ClassOverrides and C.ClassOverrides[classId]
    ov = ov and ov[mode] and ov[mode][role]
    if not ov then return base end
    local merged = {}
    for k, v in pairs(base) do merged[k] = v end
    for k, v in pairs(ov) do merged[k] = v end
    merged.classSpecific = true
    return merged
end

local function SlotText(list, color)
    local lines = {}
    for i, s in ipairs(list or {}) do
        lines[#lines + 1] = string.format("|c%s%d.|r  %s", color, i, s)
    end
    return table.concat(lines, "\n")
end

local function HexToRGB(hex)
    return tonumber(hex:sub(1, 2), 16) / 255, tonumber(hex:sub(3, 4), 16) / 255, tonumber(hex:sub(5, 6), 16) / 255
end

local function MakeLabel(name, parent, font, width, height)
    local l = WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL)
    l:SetFont(font)
    l:SetDimensions(width, height)
    local r, g, b = HexToRGB(COLOR.text)
    l:SetColor(r, g, b, 1)
    return l
end

local function MakeLine(name, parent, width, height, hex, alpha)
    local t = WINDOW_MANAGER:CreateControl(name, parent, CT_TEXTURE)
    local r, g, b = HexToRGB(hex)
    t:SetColor(r, g, b, alpha or 1)
    t:SetDimensions(width, height)
    return t
end

local function MakeTab(name, parent, text, onClick, width)
    width = width or 70
    local l = MakeLabel(name, parent, "ZoFontGameBold", width, 24)
    l:SetText(text)
    l:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    l:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    l:SetMouseEnabled(true)
    l:SetHandler("OnMouseUp", function(_, button, upInside)
        if upInside and button == MOUSE_BUTTON_INDEX_LEFT then onClick() end
    end)
    local u = MakeLine(name .. "U", l, width, 2, COLOR.active)
    u:SetAnchor(BOTTOMLEFT, l, BOTTOMLEFT, 0, 3)
    l.underline = u
    return l
end

-- Small role icon above a tab; clicking it does the same as clicking the tab.
local function AddTabIcon(tab, name, texture)
    local icon = WINDOW_MANAGER:CreateControl(name, tab, CT_TEXTURE)
    icon:SetTexture(texture)
    icon:SetDimensions(ROLE_ICON_SIZE, ROLE_ICON_SIZE)
    icon:SetAnchor(BOTTOM, tab, TOP, 0, -1)
    icon:SetMouseEnabled(true)
    icon:SetHandler("OnMouseUp", tab:GetHandler("OnMouseUp"))
    tab.icon = icon
end

-- Tabs with their own color (Magicka / Stamina) stay in that color and dim when
-- inactive; the others use the orange active / grey idle colors.
local function SetTabState(tab, active)
    local r, g, b, a
    if tab.color then
        r, g, b = HexToRGB(tab.color)
        a = active and 1 or 0.5
    else
        r, g, b = HexToRGB(active and COLOR.active or COLOR.idle)
        a = 1
    end
    tab:SetColor(r, g, b, a)
    tab.underline:SetColor(r, g, b, 1)
    tab.underline:SetHidden(not active)
    if tab.icon then tab.icon:SetColor(1, 1, 1, active and 1 or 0.45) end
end

local function SetApplyButtonState(enabled)
    if not ui.applyButton then return end
    ui.applyButton:SetEnabled(enabled)
    ui.applyButtonEnabled = enabled
    local color = enabled and COLOR.active or COLOR.idle
    local r, g, b = HexToRGB(color)
    ui.applyButton:SetNormalFontColor(r, g, b, enabled and 1 or 0.55)
    ui.applyButton:SetMouseOverFontColor(r, g, b, 1)
    ui.applyButton:SetPressedFontColor(r, g, b, 1)
    ui.applyButton:SetDisabledFontColor(r, g, b, 0.55)
    if ui.applyButton.bg then
        ui.applyButton.bg:SetCenterColor(0.07, 0.08, 0.10, enabled and 0.94 or 0.60)
        ui.applyButton.bg:SetEdgeColor(r, g, b, enabled and 0.85 or 0.35)
    end
end

function C.SetApplyStatus(text, good, buttonEnabled)
    if not ui.applyStatus then return end
    ui.applyStatus:SetText(text or "")
    local color = good and COLOR.craft or COLOR.fitness
    local r, g, b = HexToRGB(color)
    ui.applyStatus:SetColor(r, g, b, 1)
    SetApplyButtonState(buttonEnabled == true)
end

local function WrapPassiveLine(text, maxChars)
    if type(text) ~= "string" or text == "" then return "-" end
    maxChars = maxChars or 82
    local tokens = {}
    for token in string.gmatch(text, "[^,]+") do
        token = token:gsub("^%s+", ""):gsub("%s+$", "")
        if token ~= "" then tokens[#tokens + 1] = token end
    end
    local lines, current = {}, ""
    for _, token in ipairs(tokens) do
        local candidate = current == "" and token or (current .. ", " .. token)
        if current ~= "" and #candidate > maxChars then
            lines[#lines + 1] = current .. ","
            current = token
        else
            current = candidate
        end
    end
    if current ~= "" then lines[#lines + 1] = current end
    return table.concat(lines, "\n")
end

local function FormatNumber(n)
    n = tonumber(n) or 0
    return ZO_CommaDelimitNumber(math.floor(n))
end

function C.RefreshPointPools()
    if not C.Apply or not ui.cpPools then return end
    local pools = C.Apply.GetTreePointPools()
    local total = C.Apply.GetTotalCP()
    ui.cpPools:SetText(string.format(
        "|c%sTOTAL CP: %s|r   |c%sWARFARE %s (avail %s)|r   |c%sFITNESS %s (avail %s)|r   |c%sCRAFT %s (avail %s)|r",
        COLOR.active, FormatNumber(total),
        COLOR.warfare, FormatNumber(pools.warfare.total), FormatNumber(pools.warfare.available),
        COLOR.fitness, FormatNumber(pools.fitness.total), FormatNumber(pools.fitness.available),
        COLOR.craft, FormatNumber(pools.craft.total), FormatNumber(pools.craft.available)))
end

function C.RefreshApplyState()
    if not ui.applyStatus or not C.Apply then return end
    local ready, status, buttonClickable = C.Apply.GetState(C.sv and C.sv.classId)
    C.SetApplyStatus(status, ready, buttonClickable)
    C.RefreshPointPools()
end

-- Grow the window when the (wrapped) passive lists push the footer past WIN_H.
-- Label heights only settle after ESO's next layout pass, so measure then
-- (and undo the open animation's scale so the numbers are in window units).
local FOOTER_BOTTOM_PAD = 18

local function MeasureAndFit()
    if not ui.win or not ui.footer then return end
    local top, footTop = ui.win:GetTop(), ui.footer:GetTop()
    if not top or not footTop or footTop <= top then return end
    local scale = ui.win:GetScale()
    if not scale or scale <= 0 then scale = 1 end
    local needed = (footTop - top) / scale + ui.footer:GetTextHeight() + FOOTER_BOTTOM_PAD
    ui.win:SetHeight(zo_max(WIN_H, zo_ceil(needed)))
end

local function FitWindowHeight()
    MeasureAndFit()
    zo_callLater(MeasureAndFit, 0)
end

function C.Refresh()
    local sv = C.sv
    if not sv or not sv.classId or not sv.mode or not sv.role then return end

    -- Healer / Tank have no PvP setups; fall back to the character's damage role there.
    if sv.mode == "PVP" and PVE_ONLY_ROLE[sv.role] then sv.role = DetectRole() end

    local build = GetBuild(sv.classId, sv.mode, sv.role)
    if not build then return end

    SetTabState(ui.tabPvE, sv.mode == "PVE")
    SetTabState(ui.tabPvP, sv.mode == "PVP")
    local isDD = not PVE_ONLY_ROLE[sv.role]
    SetTabState(ui.tabDD, isDD)
    SetTabState(ui.tabTank, sv.role == "TANK")
    SetTabState(ui.tabHeal, sv.role == "HEAL")
    -- Magicka / Stamina only belong to DD.
    ui.tabMag:SetHidden(not isDD)
    ui.tabStam:SetHidden(not isDD)
    SetTabState(ui.tabMag, sv.role == "MAG")
    SetTabState(ui.tabStam, sv.role == "STAM")

    ui.warfareBody:SetText(SlotText(build.warfare, COLOR.warfare))
    ui.fitnessBody:SetText(SlotText(build.fitness, COLOR.fitness))
    ui.craftBody:SetText(SlotText(build.craft, COLOR.craft))

    -- Passives: one row per tree, label on the left, points wrapped in their own column.
    local p = build.passives or {}
    for _, tree in ipairs(PASSIVE_TREES) do
        local text = type(p[tree]) == "string" and WrapPassiveLine(p[tree], PASSIVE_WRAP_CHARS) or "-"
        ui.passiveRows[tree]:SetText(text)
    end

    local roleName = ROLE_NAME[sv.role] or sv.role
    local foot = "Source: " .. (build.source or "?")
    if build.verified == false then foot = "|cFF8844[!] Unverified|r  " .. foot end
    if build.note and build.note ~= "" then
        foot = foot .. "\n" .. build.note
    end
    ui.footer:SetText(foot)
    FitWindowHeight()

    local selected = CLASS_NAME[sv.classId] .. " " .. roleName .. " " .. (sv.mode == "PVE" and "PvE" or "PvP")
    if sv.classId ~= ui.myClassId then
        selected = selected .. "  |cFF9A4D[VIEW ONLY]|r"
    end
    ui.selectedBuildName:SetText(selected)
    C.RefreshApplyState()
end

local function Column(prefix, parent, title, color, iconFile)
    local line = MakeLine(prefix .. "Line", parent, COL_W, 2, color)
    if iconFile then
        local icon = WINDOW_MANAGER:CreateControl(prefix .. "Icon", parent, CT_TEXTURE)
        icon:SetTexture("CPBIS/Textures/" .. iconFile)
        icon:SetDimensions(ICON_W, ICON_H)
        icon:SetAnchor(BOTTOMLEFT, line, TOPLEFT, 0, -3)
        icon:SetMouseEnabled(false)
    end
    local header = MakeLabel(prefix .. "Head", parent, "ZoFontGameBold", COL_W, 22)
    header:SetText(string.format("|c%s%s|r", color, title))
    header:SetAnchor(TOPLEFT, line, BOTTOMLEFT, 2, 4)
    local body = MakeLabel(prefix .. "Body", parent, "ZoFontGame", COL_W - 4, 96)
    body:SetAnchor(TOPLEFT, header, BOTTOMLEFT, 0, 2)
    return line, body
end

local function CreateClassDropdown(win, anchorTo)
    local dd = WINDOW_MANAGER:CreateControlFromVirtual("CPBIS_ClassDD", win, "ZO_ComboBox")
    dd:SetDimensions(200, 28)
    dd:SetAnchor(TOPLEFT, anchorTo, BOTTOMLEFT, 0, 12)

    local combo = ZO_ComboBox_ObjectFromContainer(dd)
    combo:SetSortsItems(false)
    combo:SetFont("ZoFontGameBold")

    local selectedIndex = 1
    for i, id in ipairs(CLASS_ORDER) do
        local label = CLASS_NAME[id] .. ((id == ui.myClassId) and "  (you)" or "")
        local entry = combo:CreateItemEntry(label, function()
            C.sv.classId = id
            C.Refresh()
        end)
        combo:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
        if id == C.sv.classId then selectedIndex = i end
    end
    combo:UpdateItems()
    combo:SelectItemByIndex(selectedIndex, true)

    ui.dd, ui.combo = dd, combo
    return dd
end

local function CreateApplyButton(win)
    local button = WINDOW_MANAGER:CreateControl("CPBIS_ApplyButton", win, CT_BUTTON)
    button:SetDimensions(160, 34)
    button:SetFont("ZoFontGameBold")
    button:SetText("APPLY")
    button:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    button:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    button:SetMouseEnabled(true)
    button:SetDrawLevel(50)

    local bg = WINDOW_MANAGER:CreateControl("CPBIS_ApplyBG", button, CT_BACKDROP)
    bg:SetAnchorFill(button)
    bg:SetCenterColor(0.07, 0.08, 0.10, 0.94)
    bg:SetEdgeColor(0.4, 0.25, 0.18, 0.85)
    bg:SetEdgeTexture("EsoUI/Art/ChatWindow/chatMinMax.dds", 8, 1, 1)
    bg:SetMouseEnabled(false)
    bg:SetDrawLevel(-1)

    button:SetHandler("OnMouseEnter", function(self)
        if ui.applyButtonEnabled then self:SetScale(1.03) end
    end)
    button:SetHandler("OnMouseExit", function(self) self:SetScale(1.0) end)
    button:SetHandler("OnMouseUp", function(self, mouseButton, upInside)
        if mouseButton ~= MOUSE_BUTTON_INDEX_LEFT or not upInside then return end

        local selectedClassId = C.sv and C.sv.classId
        local ready, stateText = C.Apply.GetState(selectedClassId)
        if not ready then
            C.SetApplyStatus(stateText, false, stateText:find("VIEW ONLY", 1, true) == nil)
            return
        end

        local sv = C.sv
        local build = GetBuild(sv.classId, sv.mode, sv.role)
        local roleName = ROLE_NAME[sv.role] or sv.role
        local modeName = sv.mode == "PVE" and "PvE" or "PvP"
        C.Apply.ApplyBuild(build, CLASS_NAME[sv.classId] .. " " .. roleName .. " " .. modeName)
    end)

    button.bg = bg
    ui.applyButton = button
    return button
end


-- ---------------------------------------------------------------------------
-- Launcher button (top-left) + open/close animation. Cosmetic only.
-- ---------------------------------------------------------------------------
local LAUNCHER_TEXT_NORMAL = "C5C29E"   -- ESO's default beige UI text
local LAUNCHER_TEXT_HOVER  = "FFFFFF"   -- ESO's highlight text
local LAUNCHER_BG_ALPHA, LAUNCHER_BG_ALPHA_HOVER = 0.62, 0.90

local function SetLauncherTextColor(hovered)
    if not ui.launcherText then return end
    local hex = ui.isOpen and COLOR.active or (hovered and LAUNCHER_TEXT_HOVER or LAUNCHER_TEXT_NORMAL)
    local r, g, b = HexToRGB(hex)
    ui.launcherText:SetColor(r, g, b, 1)
end

local function CreateLauncher()
    local launcher = WINDOW_MANAGER:CreateTopLevelWindow("CPBIS_Launcher")
    launcher:SetDimensions(190, 32)
    launcher:ClearAnchors()
    launcher:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, C.sv.launcherX or 16, C.sv.launcherY or 14)
    launcher:SetClampedToScreen(true)
    launcher:SetMouseEnabled(true)
    launcher:SetMovable(true)

    -- ESO's own tooltip-style backdrop, made semi-transparent (the text stays solid).
    local ok, bg = pcall(WINDOW_MANAGER.CreateControlFromVirtual, WINDOW_MANAGER, "CPBIS_LauncherBG", launcher, "ZO_DefaultBackdrop")
    if not ok or not bg then
        bg = WINDOW_MANAGER:CreateControl("CPBIS_LauncherBG", launcher, CT_BACKDROP)
        bg:SetCenterColor(0, 0, 0, 1)
        bg:SetEdgeColor(0.45, 0.42, 0.36, 1)
        bg:SetEdgeTexture("", 1, 1, 1)
    end
    bg:ClearAnchors()
    bg:SetAnchorFill(launcher)
    bg:SetAlpha(LAUNCHER_BG_ALPHA)
    bg:SetMouseEnabled(false)

    local text = WINDOW_MANAGER:CreateControl("CPBIS_LauncherText", launcher, CT_LABEL)
    text:SetFont("$(BOLD_FONT)|16|soft-shadow-thick")
    text:SetText("Champion points")
    text:SetAnchorFill(launcher)
    text:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    text:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    text:SetDrawLevel(5)
    text:SetMouseEnabled(false)
    ui.launcherText = text

    launcher:SetHandler("OnMouseEnter", function(self)
        bg:SetAlpha(LAUNCHER_BG_ALPHA_HOVER)
        SetLauncherTextColor(true)
        InitializeTooltip(InformationTooltip, self, TOPLEFT, 0, 4, BOTTOMLEFT)
        SetTooltipText(InformationTooltip, "Left-click: open / collapse")
    end)
    launcher:SetHandler("OnMouseExit", function()
        bg:SetAlpha(LAUNCHER_BG_ALPHA)
        SetLauncherTextColor(false)
        ClearTooltip(InformationTooltip)
    end)
    -- Drag to move; a short click (no movement) opens / collapses.
    launcher:SetHandler("OnMouseDown", function(self, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            ui.pressX, ui.pressY = self:GetLeft(), self:GetTop()
        end
    end)
    launcher:SetHandler("OnMoveStart", function()
        ClearTooltip(InformationTooltip)
    end)
    launcher:SetHandler("OnMoveStop", function(self)
        C.sv.launcherX, C.sv.launcherY = self:GetLeft(), self:GetTop()
        self:ClearAnchors()
        self:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, C.sv.launcherX, C.sv.launcherY)
        -- moving the button brings the window along under it
        C.sv.docked = true
        if C.PlaceWindow then C.PlaceWindow() end
    end)
    launcher:SetHandler("OnMouseUp", function(self, button, upInside)
        if button ~= MOUSE_BUTTON_INDEX_LEFT then return end
        local moved = ui.pressX and (math.abs(self:GetLeft() - ui.pressX) > 3 or math.abs(self:GetTop() - ui.pressY) > 3)
        ui.pressX, ui.pressY = nil, nil
        if upInside and not moved then C.Toggle() end
    end)

    -- Small "x" in the top-right corner: hides the button (bring it back with /cpbis button).
    local close = MakeLabel("CPBIS_LauncherClose", launcher, "$(BOLD_FONT)|14|soft-shadow-thin", 16, 16)
    close:SetText("x")
    close:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    close:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    close:SetAnchor(TOPRIGHT, launcher, TOPRIGHT, -3, 1)
    close:SetDrawLevel(6)
    close:SetMouseEnabled(true)
    local cr, cg, cb = HexToRGB(COLOR.idle)
    close:SetColor(cr, cg, cb, 1)
    close:SetHandler("OnMouseEnter", function(self)
        local r, g, b = HexToRGB(COLOR.active)
        self:SetColor(r, g, b, 1)
        InitializeTooltip(InformationTooltip, self, TOPLEFT, 0, 4, BOTTOMLEFT)
        SetTooltipText(InformationTooltip, "Hide this button\nType /cpbis to show it again")
    end)
    close:SetHandler("OnMouseExit", function(self)
        self:SetColor(cr, cg, cb, 1)
        ClearTooltip(InformationTooltip)
    end)
    close:SetHandler("OnMouseUp", function(_, button, upInside)
        if upInside and button == MOUSE_BUTTON_INDEX_LEFT then
            ClearTooltip(InformationTooltip)
            C.SetLauncherShown(false)
            d("|cFF9A4DCPBIS:|r button hidden. Type |cFFFFFF/cpbis|r to show it again.")
        end
    end)

    -- Show the launcher on the normal HUD (and HUD with cursor), hide it in menus like ESO's own HUD elements.
    if ZO_HUDFadeSceneFragment and HUD_SCENE and HUD_UI_SCENE then
        ui.launcherFragment = ZO_HUDFadeSceneFragment:New(launcher)
        ui.launcherAttached = false
    end

    ui.launcher = launcher
    SetLauncherTextColor(false)
    C.SetLauncherShown(not C.sv.launcherHidden)
end

-- Show or hide the launcher button and remember the choice.
function C.SetLauncherShown(show)
    local launcher, fragment = ui.launcher, ui.launcherFragment
    if not launcher then return end
    C.sv.launcherHidden = not show
    if fragment and ui.launcherAttached ~= show then
        -- The HUD fragment controls visibility while it is attached, so attach/detach it.
        ui.launcherAttached = show
        if show then
            HUD_SCENE:AddFragment(fragment)
            HUD_UI_SCENE:AddFragment(fragment)
        else
            HUD_SCENE:RemoveFragment(fragment)
            HUD_UI_SCENE:RemoveFragment(fragment)
        end
    end
    launcher:SetHidden(not show or (fragment ~= nil and not (HUD_SCENE:IsShowing() or HUD_UI_SCENE:IsShowing())))
end

-- Window sits right under the launcher unless the player dragged it somewhere else.
function C.PlaceWindow()
    local win, sv = ui.win, C.sv
    if not win or not sv then return end
    win:ClearAnchors()
    if sv.docked ~= false and ui.launcher then
        win:SetAnchor(TOPLEFT, ui.launcher, BOTTOMLEFT, 0, 6)
    else
        win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.x, sv.y)
    end
end

local function CreateOpenAnimation(win)
    if not ANIMATION_MANAGER then return end
    local timeline = ANIMATION_MANAGER:CreateTimeline()

    local fade = timeline:InsertAnimation(ANIMATION_ALPHA, win)
    fade:SetAlphaValues(0, 1)
    fade:SetDuration(180)

    local grow = timeline:InsertAnimation(ANIMATION_SCALE, win)
    grow:SetScaleValues(0.92, 1)
    grow:SetDuration(220)

    if ZO_EaseOutCubic then
        fade:SetEasingFunction(ZO_EaseOutCubic)
        grow:SetEasingFunction(ZO_EaseOutCubic)
    end

    timeline:SetHandler("OnStop", function()
        if not ui.isOpen then win:SetHidden(true) end
    end)
    ui.openAnim = timeline
end

local function CreateUI()
    local sv = C.sv
    ui.myClassId = GetUnitClassId("player")

    local win = WINDOW_MANAGER:CreateTopLevelWindow("CPBIS_Window")
    win:SetDimensions(WIN_W, WIN_H)
    win:SetClampedToScreen(true)
    win:SetMovable(true)
    win:SetMouseEnabled(true)
    win:SetHidden(true)
    win:SetHandler("OnMoveStop", function()
        sv.x, sv.y = win:GetLeft(), win:GetTop()
        sv.docked = false
    end)
    ui.win = win

    CreateLauncher()
    C.PlaceWindow()
    CreateOpenAnimation(win)

    local bg = WINDOW_MANAGER:CreateControl("CPBIS_BG", win, CT_BACKDROP)
    bg:SetAnchorFill(win)
    bg:SetCenterColor(0.05, 0.055, 0.07, 0.72)
    bg:SetEdgeColor(0.20, 0.22, 0.26, 0.55)
    bg:SetEdgeTexture("", 1, 1, 1)

    local title = MakeLabel("CPBIS_Title", win, "ZoFontWinH2", 500, 30)
    title:SetText("BIS CHAMPION POINTS")
    local tr, tg, tb = HexToRGB(COLOR.title)
    title:SetColor(tr, tg, tb, 1)
    title:SetAnchor(TOPLEFT, win, TOPLEFT, 20, 14)

    local minimize = MakeLabel("CPBIS_Minimize", win, "$(BOLD_FONT)|28|soft-shadow-thin", 30, 30)
    minimize:SetText("-")
    minimize:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    minimize:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    minimize:SetAnchor(TOPRIGHT, win, TOPRIGHT, -12, 10)
    minimize:SetMouseEnabled(true)
    local ir, ig, ib = HexToRGB(COLOR.idle)
    minimize:SetColor(ir, ig, ib, 1)
    minimize:SetHandler("OnMouseEnter", function(self)
        local r, g, b = HexToRGB(COLOR.active)
        self:SetColor(r, g, b, 1)
        InitializeTooltip(InformationTooltip, self, BOTTOM, 0, -4, TOP)
        SetTooltipText(InformationTooltip, "Minimize")
    end)
    minimize:SetHandler("OnMouseExit", function(self)
        self:SetColor(ir, ig, ib, 1)
        ClearTooltip(InformationTooltip)
    end)
    minimize:SetHandler("OnMouseUp", function(_, button, upInside)
        if upInside and button == MOUSE_BUTTON_INDEX_LEFT then C.Toggle(false) end
    end)

    local titleLine = MakeLine("CPBIS_TitleLine", win, WIN_W - 40, 1, COLOR.edge, 0.65)
    titleLine:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 8)

    local dd = CreateClassDropdown(win, titleLine)

    -- Role categories with icons, left to right: DD, Tank, Healer (right-aligned).
    -- Healer / Tank are PvE-only, so picking one also switches to PvE.
    local function PickPvERole(role) sv.role = role; sv.mode = "PVE"; C.Refresh() end
    local function PickDDRole(role) sv.role = role; sv.ddRole = role; C.Refresh() end

    local catY = 14 + ROLE_ICON_SIZE + 2
    ui.tabHeal = MakeTab("CPBIS_TabHeal", win, "Healer", function() PickPvERole("HEAL") end, 70)
    ui.tabHeal:SetAnchor(TOPRIGHT, titleLine, BOTTOMRIGHT, 0, catY)
    AddTabIcon(ui.tabHeal, "CPBIS_TabHealIcon", ROLE_ICON.HEAL)
    ui.tabTank = MakeTab("CPBIS_TabTank", win, "Tank", function() PickPvERole("TANK") end, 70)
    ui.tabTank:SetAnchor(RIGHT, ui.tabHeal, LEFT, -6, 0)
    AddTabIcon(ui.tabTank, "CPBIS_TabTankIcon", ROLE_ICON.TANK)
    ui.tabDD = MakeTab("CPBIS_TabDD", win, "DD", function()
        if PVE_ONLY_ROLE[sv.role] then PickDDRole(sv.ddRole or DetectRole()) end
    end, 70)
    ui.tabDD:SetAnchor(RIGHT, ui.tabTank, LEFT, -6, 0)
    AddTabIcon(ui.tabDD, "CPBIS_TabDDIcon", ROLE_ICON.DD)

    -- Magicka / Stamina sit centered under DD and only show while DD is picked.
    ui.tabMag = MakeTab("CPBIS_TabMag", win, "Magicka", function() PickDDRole("MAG") end, 80)
    ui.tabMag.color = MAGICKA_COLOR
    ui.tabMag:SetAnchor(TOPRIGHT, ui.tabDD, BOTTOM, -3, 8)
    ui.tabStam = MakeTab("CPBIS_TabStam", win, "Stamina", function() PickDDRole("STAM") end, 80)
    ui.tabStam.color = STAMINA_COLOR
    ui.tabStam:SetAnchor(TOPLEFT, ui.tabDD, BOTTOM, 3, 8)

    ui.tabPvE = MakeTab("CPBIS_TabPvE", win, "PvE", function() sv.mode = "PVE"; C.Refresh() end, 64)
    ui.tabPvE:SetAnchor(TOPLEFT, dd, BOTTOMLEFT, 0, 12)
    ui.tabPvP = MakeTab("CPBIS_TabPvP", win, "PvP", function() sv.mode = "PVP"; C.Refresh() end, 64)
    ui.tabPvP:SetAnchor(LEFT, ui.tabPvE, RIGHT, 6, 0)

    CreateApplyButton(win)
    ui.applyButton:SetAnchor(TOPRIGHT, titleLine, BOTTOMRIGHT, 0, 100)

    ui.selectedBuildName = MakeLabel("CPBIS_SelectedBuild", win, "ZoFontGameBold", 390, 22)
    ui.selectedBuildName:SetAnchor(TOPLEFT, ui.tabPvE, BOTTOMLEFT, 0, 8)
    local ar, ag, ab = HexToRGB(COLOR.title)
    ui.selectedBuildName:SetColor(ar, ag, ab, 1)

    ui.cpPools = MakeLabel("CPBIS_CPPools", win, "ZoFontGameSmall", WIN_W - 40, 28)
    ui.cpPools:SetAnchor(TOPLEFT, ui.selectedBuildName, BOTTOMLEFT, 0, 2)

    ui.applyStatus = MakeLabel("CPBIS_ApplyStatus", win, "ZoFontGameSmall", 430, 22)
    ui.applyStatus:SetAnchor(TOPLEFT, ui.cpPools, BOTTOMLEFT, 0, 0)

    local divider = MakeLine("CPBIS_Div", win, WIN_W - 40, 1, COLOR.edge, 0.5)
    divider:SetAnchor(TOPLEFT, ui.applyStatus, BOTTOMLEFT, 0, 7)

    local wLine, wBody = Column("CPBIS_W", win, "WARFARE", COLOR.warfare, "warfare.dds")
    wLine:SetAnchor(TOPLEFT, divider, BOTTOMLEFT, 0, 12 + ICON_H + 3)
    local fLine, fBody = Column("CPBIS_F", win, "FITNESS", COLOR.fitness, "fitness.dds")
    fLine:SetAnchor(TOPLEFT, wLine, TOPRIGHT, COL_GAP, 0)
    local cLine, cBody = Column("CPBIS_C", win, "CRAFT", COLOR.craft, "craft.dds")
    cLine:SetAnchor(TOPLEFT, fLine, TOPRIGHT, COL_GAP, 0)
    ui.warfareBody, ui.fitnessBody, ui.craftBody = wBody, fBody, cBody

    -- Passives block: header, then a row per tree with a fixed-width name column
    -- so wrapped lines stay indented under their own tree.
    local passHeader = MakeLabel("CPBIS_PassHeader", win, "ZoFontGameBold", WIN_W - 40, 24)
    passHeader:SetText(string.format("|c%sPassives (suggested points)|r", COLOR.active))
    passHeader:SetAnchor(TOPLEFT, wBody, BOTTOMLEFT, -2, 14)

    ui.passiveRows = {}
    local prevBody
    for i, tree in ipairs(PASSIVE_TREES) do
        local key = tree:sub(1, 1):upper() .. tree:sub(2)
        local name = MakeLabel("CPBIS_PassName" .. key, win, "ZoFontGame", PASSIVE_NAME_W, 24)
        name:SetText(string.format("|c%s%s|r", COLOR[tree], key))
        if prevBody then
            -- start under the previous row's (possibly wrapped) text, back in the name column
            name:SetAnchor(TOPLEFT, prevBody, BOTTOMLEFT, -PASSIVE_NAME_W, PASSIVE_ROW_GAP)
        else
            name:SetAnchor(TOPLEFT, passHeader, BOTTOMLEFT, 0, 4)
        end

        local body = WINDOW_MANAGER:CreateControl("CPBIS_PassBody" .. key, win, CT_LABEL)
        body:SetFont("ZoFontGame")
        body:SetWidth(WIN_W - 40 - PASSIVE_NAME_W)   -- width only: height grows with the text
        local r, g, b = HexToRGB(COLOR.text)
        body:SetColor(r, g, b, 1)
        body:SetAnchor(TOPLEFT, name, TOPRIGHT, 0, 0)

        ui.passiveRows[tree] = body
        prevBody = body
    end

    ui.footer = MakeLabel("CPBIS_Foot", win, "ZoFontGameSmall", WIN_W - 40, 86)
    ui.footer:SetAnchor(TOPLEFT, prevBody, BOTTOMLEFT, -PASSIVE_NAME_W, 16)
    local mr, mg, mb = HexToRGB(COLOR.idle)
    ui.footer:SetColor(mr, mg, mb, 1)

    SetApplyButtonState(false)
end

function C.Toggle(show)
    if not ui.win then return end
    if show == nil then show = not ui.isOpen end
    if show == (ui.isOpen == true) then return end
    ui.isOpen = show
    SetLauncherTextColor(false)

    if show then
        C.PlaceWindow()
        ui.win:SetHidden(false)
        C.Refresh()
        EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "ApplyState", 500, function()
            if ui.win:IsHidden() then return end
            C.RefreshApplyState()
        end)
        SetGameCameraUIMode(true)
        if ui.openAnim then
            if ui.openAnim:IsPlaying() then ui.openAnim:PlayForward() else ui.openAnim:PlayFromStart() end
        else
            ui.win:SetAlpha(1)
        end
    else
        EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "ApplyState")
        if ui.combo and ui.combo.HideDropdown then ui.combo:HideDropdown() end
        if ui.openAnim then
            if ui.openAnim:IsPlaying() then ui.openAnim:PlayBackward() else ui.openAnim:PlayFromEnd() end
        else
            ui.win:SetHidden(true)
        end
    end
end

-- /cpbis   brings the "Champion points" button back if it was hidden with its x;
--          otherwise opens / collapses the window.
SLASH_COMMANDS["/cpbis"] = function()
    if C.sv and C.sv.launcherHidden then
        C.SetLauncherShown(true)
        d("|cFF9A4DCPBIS:|r button shown.")
    else
        C.Toggle()
    end
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    C.sv = ZO_SavedVars:NewAccountWide("CPBIS_SV", 1, nil, defaults)
    C.sv.classId = C.sv.classId or GetUnitClassId("player")
    C.sv.role = C.sv.role or DetectRole()
    C.sv.mode = C.sv.mode or "PVE"

    C.Apply.Initialize()
    CreateUI()
    C.Refresh()
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
