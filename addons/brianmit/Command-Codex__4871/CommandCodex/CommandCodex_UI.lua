-- CommandCodex_UI.lua : floating command window in ESO's menu style, plus a small
-- movable "Command Codex" button that opens / minimizes it (same idea as CPBIS), the
-- favorites on screen, and a small editor for notes.
-- Category tree on the left, command list on the right, actions and aliases at the bottom.
-- All text comes from CommandCodex_Strings.lua via L().

local S = CommandCodex
local L = S.L
local ui = {}

local WIN_W, WIN_H = 770, 580
local PAD = 28
local TREE_W = 260

local DATA_TYPE_CATEGORY, DATA_TYPE_SUBCATEGORY = 1, 2
local DATA_TYPE_COMMAND, DATA_TYPE_HEADER, DATA_TYPE_NOTE = 1, 2, 3

-- ESO's own text colors.
local COLOR = {
    normal   = "C5C29E",
    selected = "FFFFFF",
    header   = "E8DFAF",
    gold     = "C9B77A",
    dim      = "8F8B7A",
    alias    = "7FB2E5",
    note     = "B9D6A8",
    good     = "8FD17F",
    bad      = "FF6B5A",
}
local STAR_ON = { 1, 1, 1, 1 }
local STAR_OFF = { 0.7, 0.7, 0.7, 0.25 }

local TEX_LOCK_CLOSED = "CommandCodex/Textures/lock_closed.dds"
local TEX_LOCK_OPEN = "CommandCodex/Textures/lock_open.dds"
local TEX_ROUNDED = "CommandCodex/Textures/rounded_fill.dds"
local TEX_KEY = "CommandCodex/Textures/key_frame.dds"
local TEX_CIRCLE = "CommandCodex/Textures/circle.dds"
local TEX_RING = "CommandCodex/Textures/circle_ring.dds"

local ARROW_OPEN = "EsoUI/Art/Buttons/tree_open_up.dds"
local ARROW_CLOSED = "EsoUI/Art/Buttons/tree_closed_up.dds"

local OTHER_ADDON = "__other"

local CATEGORIES = {
    { view = "all",       key = "CAT_ALL" },
    { view = "favorites", key = "CAT_FAVORITES" },
    { view = "recent",    key = "CAT_RECENT" },
    { view = "addons",    key = "CAT_ADDONS", expandable = true },
    { view = "aliases",   key = "CAT_ALIASES" },
    { view = "game",      key = "CAT_GAME" },
    { view = "emotes",    key = "CAT_EMOTES" },
}


local function HexToRGB(hex)
    return tonumber(hex:sub(1, 2), 16) / 255, tonumber(hex:sub(3, 4), 16) / 255, tonumber(hex:sub(5, 6), 16) / 255
end

local function SetHexColor(control, hex, alpha)
    local r, g, b = HexToRGB(hex)
    control:SetColor(r, g, b, alpha or 1)
end

local function MakeLabel(name, parent, font, width, height, hex)
    local l = WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL)
    l:SetFont(font)
    l:SetDimensions(width, height)
    l:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    SetHexColor(l, hex or COLOR.normal)
    return l
end

-- Small clickable text (x, -) that lights up on hover, with a tooltip.
local function MakeTextButton(name, parent, text, font, size, tooltip, onClick)
    local b = MakeLabel(name, parent, font, size, size, COLOR.dim)
    b:SetText(text)
    b:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    b:SetMouseEnabled(true)
    b:SetDrawLevel(6)
    b:SetHandler("OnMouseEnter", function(self)
        SetHexColor(self, COLOR.selected)
        if tooltip then
            InitializeTooltip(InformationTooltip, self, BOTTOM, 0, -4, TOP)
            SetTooltipText(InformationTooltip, tooltip)
        end
    end)
    b:SetHandler("OnMouseExit", function(self)
        SetHexColor(self, COLOR.dim)
        ClearTooltip(InformationTooltip)
    end)
    b:SetHandler("OnMouseUp", function(_, button, upInside)
        if upInside and button == MOUSE_BUTTON_INDEX_LEFT then
            ClearTooltip(InformationTooltip)
            onClick()
        end
    end)
    return b
end

-- Dark text field with a thin bronze edge; the edit box inside is ESO's own template.
local function MakeEdit(name, parent, width, hint)
    local box = WINDOW_MANAGER:CreateControl(name .. "BG", parent, CT_BACKDROP)
    box:SetDimensions(width, 28)
    box:SetCenterColor(0, 0, 0, 0.55)
    box:SetEdgeColor(0.36, 0.35, 0.27, 1)
    box:SetEdgeTexture("", 1, 1, 1)
    box:SetMouseEnabled(true)

    local edit = WINDOW_MANAGER:CreateControlFromVirtual(name, box, "ZO_DefaultEditForBackdrop")
    if hint and edit.SetDefaultText then edit:SetDefaultText(hint) end
    box:SetHandler("OnMouseUp", function() edit:TakeFocus() end)
    return box, edit
end

-- ESO buttons react to every mouse button by default; ours only to the left one.
local function LeftClickOnly(button)
    if button.EnableMouseButton then
        button:EnableMouseButton(MOUSE_BUTTON_INDEX_RIGHT, false)
        button:EnableMouseButton(MOUSE_BUTTON_INDEX_MIDDLE, false)
    end
end

-- ESO checkbox with a label; getter/setter read and write the setting.
-- Only a left click (on the box or its label) toggles it.
local function MakeCheck(name, parent, text, getter, setter, tooltip)
    local cb = WINDOW_MANAGER:CreateControlFromVirtual(name, parent, "ZO_CheckButton")
    ZO_CheckButton_SetLabelText(cb, text)
    LeftClickOnly(cb)
    local label = cb.label or GetControl(cb, "Label")
    local labelClick = label and label:GetHandler("OnMouseUp")
    if labelClick then
        label:SetHandler("OnMouseUp", function(self, button, ...)
            if button == MOUSE_BUTTON_INDEX_LEFT then labelClick(self, button, ...) end
        end)
    end
    ZO_CheckButton_SetCheckState(cb, getter())
    ZO_CheckButton_SetToggleFunction(cb, function(_, checked) setter(checked) end)
    if tooltip then
        cb:SetHandler("OnMouseEnter", function(self)
            InitializeTooltip(InformationTooltip, self, BOTTOMLEFT, 0, -6, TOPLEFT)
            SetTooltipText(InformationTooltip, tooltip)
        end)
        cb:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)
    end
    return cb
end

local function MakeButton(name, parent, text, width, onClick)
    local b = WINDOW_MANAGER:CreateControlFromVirtual(name, parent, "ZO_DefaultButton")
    b:SetDimensions(width, 28)
    b:SetText(text)
    LeftClickOnly(b)
    b:SetHandler("OnClicked", onClick)
    return b
end

-- Solid texture whose left or right side fades to transparent.
-- fade: "in" = transparent on the left, "out" = transparent on the right.
local function MakeFadeTexture(name, parent, r, g, b, a, fade)
    local t = WINDOW_MANAGER:CreateControl(name, parent, CT_TEXTURE)
    t:SetColor(r, g, b, a)
    if fade and t.SetVertexColors then
        local clear = fade == "in"
            and (VERTEX_POINTS_TOPLEFT + VERTEX_POINTS_BOTTOMLEFT)
            or (VERTEX_POINTS_TOPRIGHT + VERTEX_POINTS_BOTTOMRIGHT)
        t:SetVertexColors(clear, r, g, b, 0)
    end
    t:SetMouseEnabled(false)
    return t
end

-- ESO menu background: dark in the middle, fading out at the left and right edges.
local function MakeFadePanel(win, prefix, fadeW)
    local FADE_W, ALPHA = fadeW or 70, 0.9
    local left = MakeFadeTexture(prefix .. "BGLeft", win, 0, 0, 0, ALPHA, "in")
    left:SetAnchor(TOPLEFT, win, TOPLEFT, 0, 0)
    left:SetAnchor(BOTTOMLEFT, win, BOTTOMLEFT, 0, 0)
    left:SetWidth(FADE_W)
    local right = MakeFadeTexture(prefix .. "BGRight", win, 0, 0, 0, ALPHA, "out")
    right:SetAnchor(TOPRIGHT, win, TOPRIGHT, 0, 0)
    right:SetAnchor(BOTTOMRIGHT, win, BOTTOMRIGHT, 0, 0)
    right:SetWidth(FADE_W)
    local center = MakeFadeTexture(prefix .. "BGCenter", win, 0, 0, 0, ALPHA)
    center:SetAnchor(TOPLEFT, left, TOPRIGHT, 0, 0)
    center:SetAnchor(BOTTOMRIGHT, right, BOTTOMLEFT, 0, 0)
    for _, t in ipairs({ left, right, center }) do t:SetDrawLayer(DL_BACKGROUND) end
end

-- Gold line that fades out at both ends (ESO's menu divider).
local function MakeDivider(name, parent, width)
    local divider = WINDOW_MANAGER:CreateControl(name, parent, CT_CONTROL)
    divider:SetDimensions(width, 2)
    local r, g, b = HexToRGB(COLOR.gold)
    local left = MakeFadeTexture(name .. "L", divider, r, g, b, 1, "in")
    left:SetAnchor(TOPLEFT, divider, TOPLEFT, 0, 0)
    left:SetDimensions(width / 2, 2)
    local right = MakeFadeTexture(name .. "R", divider, r, g, b, 1, "out")
    right:SetAnchor(TOPRIGHT, divider, TOPRIGHT, 0, 0)
    right:SetDimensions(width / 2, 2)
    return divider
end

-- Rounded dark background: two rounded caps and a plain middle, so the corners
-- stay round at any width.
local function MakeRoundedBackground(name, parent, height)
    local capW = height / 2
    local left = WINDOW_MANAGER:CreateControl(name .. "L", parent, CT_TEXTURE)
    left:SetTexture(TEX_ROUNDED)
    left:SetTextureCoords(0, 0.5, 0, 1)
    left:SetDimensions(capW, height)
    left:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)
    local right = WINDOW_MANAGER:CreateControl(name .. "R", parent, CT_TEXTURE)
    right:SetTexture(TEX_ROUNDED)
    right:SetTextureCoords(0.5, 1, 0, 1)
    right:SetDimensions(capW, height)
    right:SetAnchor(TOPRIGHT, parent, TOPRIGHT, 0, 0)
    local middle = WINDOW_MANAGER:CreateControl(name .. "M", parent, CT_TEXTURE)
    middle:SetAnchor(TOPLEFT, left, TOPRIGHT, 0, 0)
    middle:SetAnchor(BOTTOMRIGHT, right, BOTTOMLEFT, 0, 0)
    local parts = { left, middle, right }
    for _, t in ipairs(parts) do
        t:SetColor(0, 0, 0, 1)
        t:SetMouseEnabled(false)
        t:SetDrawLayer(DL_BACKGROUND)
    end
    return {
        SetAlpha = function(_, alpha)
            for _, t in ipairs(parts) do t:SetAlpha(alpha) end
        end,
    }
end

-- ---------------------------------------------------------------------------
-- Actions on a command (action buttons, double-click and the right-click menu)
-- ---------------------------------------------------------------------------
local function RunCommand(data)
    S.Toggle(false)   -- many commands open their own window
    zo_callLater(function() S.RunAndRecord(data.name) end, 50)
end

local function PutInChat(data)
    S.Toggle(false)
    StartChatInput(data.name .. " ")
end

local function ToggleFavorite(data)
    S.ToggleFavorite(data.name)
    S.RefreshAll()
end

local function DeleteAlias(data)
    if not data.alias then return end
    if data.favorite then S.ToggleFavorite(data.name) end   -- also frees its button slot
    S.RemoveAlias(data.name)
    S.Print(L("ALIAS_DELETED", data.name))
    ui.selected = nil
    S.RefreshAll()
end

-- Action buttons act on the selected command; greyed out when nothing fits.
local function UpdateActionButtons()
    if not ui.actions then return end
    local data = ui.selected
    ui.actions.chat:SetEnabled(data ~= nil)
    ui.actions.favorite:SetEnabled(data ~= nil)
    ui.actions.favorite:SetText((data and data.favorite) and L("BTN_UNFAVORITE") or L("BTN_FAVORITE"))
    ui.actions.delete:SetEnabled(data ~= nil and data.alias ~= nil)
end

-- ---------------------------------------------------------------------------
-- Which commands belong in the current category
-- ---------------------------------------------------------------------------
local function AddonKey(data)
    return data.owner or OTHER_ADDON
end

local function IsAddonCommand(data)
    return not data.isEmote and data.ownerMethod ~= "game" and data.ownerMethod ~= "alias"
end

local function InView(data)
    local view = S.sv.view
    if view == "recent" then return data.recentTime ~= nil end
    if view == "favorites" then return data.favorite end
    if view == "emotes" then return data.isEmote end
    if view == "all" then return true end   -- truly everything, emotes included
    if data.isEmote then return false end
    if view == "aliases" then return data.alias ~= nil end
    if view == "game" then return data.ownerMethod == "game" end
    if view == "addons" then
        return IsAddonCommand(data) and (S.sv.addon == nil or AddonKey(data) == S.sv.addon)
    end
    return true
end

local function Contains(text, search)
    return text ~= nil and zo_strlower(text):find(search, 1, true) ~= nil
end

local function Matches(data, search)
    if search == "" then return true end
    return data.name:find(search, 1, true) ~= nil
        or Contains(data.ownerTitle, search)
        or Contains(data.alias, search)
        or Contains(data.note, search)
end

local function SortCommands(a, b)
    if a.favorite ~= b.favorite then return a.favorite end
    return a.name < b.name
end

local function SortRecent(a, b)
    return a.recentRank < b.recentRank
end

-- Addons present in the command list: { key, title, count }, A-Z, "Other" last.
local function GetAddonGroups(commands)
    local byKey, groups = {}, {}
    for _, data in ipairs(commands) do
        if IsAddonCommand(data) then
            local key = AddonKey(data)
            local group = byKey[key]
            if not group then
                group = { key = key, title = data.ownerTitle or L("OTHER"), count = 0 }
                byKey[key] = group
                groups[#groups + 1] = group
            end
            group.count = group.count + 1
        end
    end
    table.sort(groups, function(a, b)
        if a.key == OTHER_ADDON or b.key == OTHER_ADDON then return b.key == OTHER_ADDON and a.key ~= OTHER_ADDON end
        return zo_strlower(a.title) < zo_strlower(b.title)
    end)
    return groups
end

-- ---------------------------------------------------------------------------
-- Category tree (left)
-- ---------------------------------------------------------------------------
local function IsCategorySelected(data)
    if data.addon then
        return S.sv.view == "addons" and S.sv.addon == data.addon
    end
    return S.sv.view == data.view and (data.view ~= "addons" or S.sv.addon == nil)
end

local function SetupCategory(control, data)
    control.data = data
    local text = control:GetNamedChild("Text")
    text:SetText(data.text or L(data.key))
    SetHexColor(text, IsCategorySelected(data) and COLOR.selected or COLOR.normal)

    local arrow = control:GetNamedChild("Arrow")
    if arrow then
        arrow:SetHidden(not data.expandable)
        arrow:SetTexture(S.sv.addonsOpen and ARROW_OPEN or ARROW_CLOSED)
    end
end

local function RefreshTree(commands)
    ZO_ScrollList_Clear(ui.tree)
    local scrollData = ZO_ScrollList_GetDataList(ui.tree)
    for _, category in ipairs(CATEGORIES) do
        scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(DATA_TYPE_CATEGORY, category)
        if category.expandable and S.sv.addonsOpen then
            for _, group in ipairs(GetAddonGroups(commands)) do
                scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(DATA_TYPE_SUBCATEGORY,
                    { text = group.title, addon = group.key })
            end
        end
    end
    ZO_ScrollList_Commit(ui.tree)
end

function S.Category_OnMouseEnter(control)
    SetHexColor(control:GetNamedChild("Text"), COLOR.selected)
end

function S.Category_OnMouseExit(control)
    if control.data and not IsCategorySelected(control.data) then
        SetHexColor(control:GetNamedChild("Text"), COLOR.normal)
    end
end

function S.Category_OnMouseUp(control, button, upInside)
    if not upInside or button ~= MOUSE_BUTTON_INDEX_LEFT or not control.data then return end
    local data = control.data
    if data.addon then
        S.sv.view, S.sv.addon = "addons", data.addon
    elseif data.expandable then
        -- Addons: first click opens it and shows all addons; clicking it again while shown closes it.
        if S.sv.view == "addons" and S.sv.addon == nil then
            S.sv.addonsOpen = not S.sv.addonsOpen
        else
            S.sv.addonsOpen = true
        end
        S.sv.view, S.sv.addon = "addons", nil
    else
        S.sv.view, S.sv.addon = data.view, nil
    end
    PlaySound(SOUNDS.DEFAULT_CLICK)
    ZO_ScrollList_ResetToTop(ui.list)
    -- A new category starts unfiltered, so it shows everything in it.
    ui.search:SetText("")
    ui.search:LoseFocus()
    S.RefreshAll()
end

-- ---------------------------------------------------------------------------
-- Command list (right)
-- ---------------------------------------------------------------------------
local function SetupRow(row, data)
    -- Favorite: gold star. Not a favorite: grey, faint star.
    local star = row:GetNamedChild("Star")
    star:SetDesaturation(data.favorite and 0 or 1)
    star:SetColor(unpack(data.favorite and STAR_ON or STAR_OFF))

    local name = row:GetNamedChild("Name")
    name:SetText(data.name)
    SetHexColor(name, data.alias and COLOR.alias or COLOR.normal)

    -- Right column: when it was run (Recent), else your note, else what the alias runs, else the addon.
    local info = row:GetNamedChild("Info")
    local text, color = "", COLOR.dim
    if S.sv.view == "recent" and data.recentTime then
        text = S.FormatAgo(data.recentTime)
    elseif data.note then
        text, color = data.note, COLOR.note
    elseif data.alias then
        text = data.alias
    elseif data.isEmote and S.sv.view ~= "emotes" then
        text = L("EMOTE")
    elseif S.sv.view ~= "addons" and data.ownerTitle then
        -- "~" = probably: the game can't tell which addon added a command
        -- (only Command Codex's own commands are certain).
        text = data.ownerMethod == "self" and data.ownerTitle or ("~ " .. data.ownerTitle)
    end
    info:SetText(text)
    SetHexColor(info, color)
end

local function SetupHeader(control, data)
    control:GetNamedChild("Text"):SetText(zo_strupper(data.title))
end

local function SetupNote(control, data)
    control:GetNamedChild("Text"):SetText(data.text)
end

local function ViewTitle()
    if S.sv.view == "addons" and S.sv.addon then
        if S.sv.addon == OTHER_ADDON then return L("OTHER") end
        return S.GetAddonTitles()[S.sv.addon] or S.sv.addon
    end
    for _, category in ipairs(CATEGORIES) do
        if category.view == S.sv.view then return L(category.key) end
    end
    return ""
end

local function RefreshList(commands)
    local search = zo_strlower(zo_strtrim(ui.search:GetText() or ""))
    local rows = {}
    for _, data in ipairs(commands) do
        if InView(data) and Matches(data, search) then rows[#rows + 1] = data end
    end

    ZO_ScrollList_Clear(ui.list)
    local scrollData = ZO_ScrollList_GetDataList(ui.list)

    -- Addons category: say up front that the addon names are a best guess.
    if S.sv.view == "addons" and #rows > 0 then
        scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(DATA_TYPE_NOTE, { text = L("GUESS_BANNER") })
    end

    if S.sv.view == "addons" and S.sv.addon == nil then
        -- All addons: one header per addon, its commands below.
        local byKey = {}
        for _, data in ipairs(rows) do
            local key = AddonKey(data)
            byKey[key] = byKey[key] or {}
            table.insert(byKey[key], data)
        end
        for _, group in ipairs(GetAddonGroups(rows)) do
            local list = byKey[group.key]
            table.sort(list, SortCommands)
            scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(DATA_TYPE_HEADER, { title = group.title })
            for _, data in ipairs(list) do
                scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(DATA_TYPE_COMMAND, data)
            end
        end
    else
        table.sort(rows, S.sv.view == "recent" and SortRecent or SortCommands)
        for _, data in ipairs(rows) do
            scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(DATA_TYPE_COMMAND, data)
        end
    end
    ZO_ScrollList_Commit(ui.list)

    -- Keep the same command selected after a refresh.
    local selectedName = ui.selected and ui.selected.name
    ui.selected = nil
    if selectedName then
        for _, entry in ipairs(scrollData) do
            local data = entry.data
            if data and data.name == selectedName then
                ZO_ScrollList_SelectData(ui.list, data)
                ui.selected = data
                break
            end
        end
    end

    ui.viewTitle:SetText(zo_strupper(ViewTitle()))
    ui.count:SetText(L("COUNT", #rows))
    ui.empty:SetHidden(#rows > 0)
    if S.sv.view == "favorites" and search == "" then
        ui.empty:SetText(L("EMPTY_FAVORITES"))
    elseif S.sv.view == "recent" and search == "" then
        ui.empty:SetText(L("EMPTY_RECENT"))
    elseif S.sv.view == "aliases" and search == "" then
        ui.empty:SetText(L("EMPTY_ALIASES"))
    else
        ui.empty:SetText(L("EMPTY_SEARCH"))
    end
    UpdateActionButtons()
end

function S.RefreshAll()
    if not ui.win or ui.win:IsHidden() then return end
    local commands = S.GetCommands()
    RefreshTree(commands)
    RefreshList(commands)
end
S.RefreshList = S.RefreshAll   -- used by the core file after alias changes

local function OnSelectionChanged(_, selectedData)
    ui.selected = selectedData
    UpdateActionButtons()
end

-- Row handlers (called from CommandCodex.xml)
function S.Row_OnMouseEnter(row)
    ZO_ScrollList_MouseEnter(ui.list, row)
    SetHexColor(row:GetNamedChild("Name"), COLOR.selected)
    row:GetNamedChild("Play"):SetAlpha(1)

    local data = ZO_ScrollList_GetData(row)
    if not data then return end
    InitializeTooltip(InformationTooltip, row, RIGHT, -12, 0, LEFT)
    SetTooltipText(InformationTooltip, data.name)
    if data.note then
        InformationTooltip:AddLine(data.note, "ZoFontGame", HexToRGB(COLOR.note))
    end
    if data.alias then
        InformationTooltip:AddLine(L("TT_ALIAS", data.alias), "ZoFontGameSmall", HexToRGB(COLOR.alias))
    elseif data.ownerTitle then
        if data.ownerMethod == "self" then
            InformationTooltip:AddLine(L("TT_FROM", data.ownerTitle), "ZoFontGameSmall", ZO_NORMAL_TEXT:UnpackRGB())
        else
            -- The game can't tell which addon added a command: say it's a guess.
            InformationTooltip:AddLine(L("TT_PROBABLY_FROM", data.ownerTitle), "ZoFontGameSmall", ZO_NORMAL_TEXT:UnpackRGB())
            InformationTooltip:AddLine(L("TT_GUESS_NOTE"), "ZoFontGameSmall", HexToRGB(COLOR.dim))
        end
    elseif data.ownerMethod == "game" then
        InformationTooltip:AddLine(L("TT_GAME"), "ZoFontGameSmall", ZO_NORMAL_TEXT:UnpackRGB())
    end
    if data.recentTime then
        InformationTooltip:AddLine(L("TT_LAST_RUN", S.FormatAgo(data.recentTime)), "ZoFontGameSmall", HexToRGB(COLOR.dim))
    end
    InformationTooltip:AddLine(L("TT_ROW_HINT"), "ZoFontGameSmall", HexToRGB(COLOR.dim))
end

function S.Row_OnMouseExit(row)
    ZO_ScrollList_MouseExit(ui.list, row)
    row:GetNamedChild("Play"):SetAlpha(0.35)
    local data = ZO_ScrollList_GetData(row)
    if data then SetHexColor(row:GetNamedChild("Name"), data.alias and COLOR.alias or COLOR.normal) end
    ClearTooltip(InformationTooltip)
end

-- Is the mouse over control (with a few pixels of slack for small targets)?
local function IsMouseOver(control, pad)
    pad = pad or 0
    local x, y = GetUIMousePosition()
    return x >= control:GetLeft() - pad and x <= control:GetRight() + pad
        and y >= control:GetTop() - pad and y <= control:GetBottom() + pad
end

function S.Row_OnMouseUp(row, button, upInside)
    if not upInside then return end
    local data = ZO_ScrollList_GetData(row)
    if not data then return end

    if button == MOUSE_BUTTON_INDEX_LEFT then
        if IsMouseOver(row:GetNamedChild("Star"), 5) then
            ToggleFavorite(data)
        elseif IsMouseOver(row:GetNamedChild("Play"), 6) then
            RunCommand(data)
        else
            ZO_ScrollList_MouseClick(ui.list, row)
        end
    elseif button == MOUSE_BUTTON_INDEX_RIGHT then
        ZO_ScrollList_MouseClick(ui.list, row)
        ClearMenu()
        AddMenuItem(L("MENU_RUN"), function() RunCommand(data) end)
        AddMenuItem(L("MENU_CHAT"), function() PutInChat(data) end)
        AddMenuItem(data.favorite and L("BTN_UNFAVORITE") or L("BTN_FAVORITE"), function() ToggleFavorite(data) end)
        if data.favorite then
            for slot, name in ipairs(S.GetFavoriteOrder()) do
                if name == data.name and slot <= 5 then
                    AddMenuItem(L("MENU_BIND"), function() S.OpenKeybindDialog(slot, data.name) end)
                end
            end
        end
        AddMenuItem(data.note and L("MENU_EDIT_NOTE") or L("MENU_ADD_NOTE"), function() S.EditNote(data.name) end)
        if data.alias then
            AddMenuItem(L("MENU_DELETE_ALIAS"), function() DeleteAlias(data) end)
        end
        ShowMenu(row)
    end
end

function S.Row_OnMouseDoubleClick(row, button)
    if button ~= MOUSE_BUTTON_INDEX_LEFT then return end
    local data = ZO_ScrollList_GetData(row)
    if data and not IsMouseOver(row:GetNamedChild("Star"), 5) and not IsMouseOver(row:GetNamedChild("Play"), 6) then
        PutInChat(data)
    end
end

-- ---------------------------------------------------------------------------
-- Alias editor
-- ---------------------------------------------------------------------------
local function SetAliasStatus(text, good)
    ui.aliasStatus:SetText(text or "")
    SetHexColor(ui.aliasStatus, good and COLOR.good or COLOR.bad)
end

local function AddAliasFromEditor()
    local alias, target = ui.aliasName:GetText(), ui.aliasTarget:GetText()
    local ok, reason = S.AddAlias(alias, target)
    if ok then
        SetAliasStatus(L("ALIAS_ADDED", S.NormalizeCommand(alias)), true)
        ui.aliasName:SetText("")
        ui.aliasTarget:SetText("")
        ui.aliasName:LoseFocus()
        ui.aliasTarget:LoseFocus()
        S.RefreshAll()
    else
        SetAliasStatus(reason, false)
    end
end

-- ---------------------------------------------------------------------------
-- Note editor: a small box to write what a command does.
-- ---------------------------------------------------------------------------
local function CloseNoteEditor()
    if not ui.noteEditor then return end
    ui.noteEdit:LoseFocus()
    ui.noteEditor:SetHidden(true)
    ui.noteName = nil
end

local function SaveNote()
    if not ui.noteName then return end
    S.SetNote(ui.noteName, ui.noteEdit:GetText())
    CloseNoteEditor()
    S.RefreshAll()
end

local function CreateNoteEditor()
    local ed = WINDOW_MANAGER:CreateTopLevelWindow("CommandCodex_NoteEditor")
    ed:SetDimensions(460, 130)
    ed:SetAnchor(CENTER, GuiRoot, CENTER, 0, -60)
    ed:SetDrawTier(DT_HIGH)
    ed:SetClampedToScreen(true)
    ed:SetMouseEnabled(true)
    ed:SetMovable(true)
    ed:SetHidden(true)
    MakeFadePanel(ed, "CommandCodex_Note", 40)

    local title = MakeLabel("CommandCodex_NoteTitle", ed, "ZoFontWinH4", 400, 28, COLOR.selected)
    title:SetAnchor(TOPLEFT, ed, TOPLEFT, 30, 10)
    ui.noteTitle = title

    local box, edit = MakeEdit("CommandCodex_NoteEdit", ed, 400, L("NOTE_HINT"))
    box:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 8)
    edit:SetMaxInputChars(120)
    edit:SetHandler("OnEnter", SaveNote)
    edit:SetHandler("OnEscape", CloseNoteEditor)
    ui.noteEdit = edit

    local cancel = MakeButton("CommandCodex_NoteCancel", ed, L("CANCEL"), 120, CloseNoteEditor)
    cancel:SetAnchor(TOPRIGHT, box, BOTTOMRIGHT, 0, 12)
    local save = MakeButton("CommandCodex_NoteSave", ed, L("SAVE"), 120, SaveNote)
    save:SetAnchor(RIGHT, cancel, LEFT, -10, 0)

    ui.noteEditor = ed
end

-- Open the note editor for a command (empty text removes the note).
function S.EditNote(name)
    if not ui.noteEditor then CreateNoteEditor() end
    ui.noteName = name
    ui.noteTitle:SetText(L("NOTE_TITLE", name))
    ui.noteEdit:SetText(S.GetNote(name) or "")
    ui.noteEditor:SetHidden(false)
    ui.noteEdit:TakeFocus()
end

-- ---------------------------------------------------------------------------
-- Launcher button (small, movable, like CPBIS) + open/close animation
-- ---------------------------------------------------------------------------
-- Style: dark rounded button with a small "/" key frame, like ESO's keybind hints.
local LAUNCHER_H = 32
local LAUNCHER_BG_ALPHA, LAUNCHER_BG_ALPHA_HOVER = 0.65, 0.85

-- Beige normally, white on hover or while the window is open.
local function SetLauncherTextColor(hovered)
    if not ui.launcherText then return end
    local bright = hovered or ui.isOpen
    SetHexColor(ui.launcherText, bright and COLOR.selected or COLOR.normal)
    SetHexColor(ui.launcherKey, bright and COLOR.selected or COLOR.dim)
end

-- Window sits right under the launcher unless the player dragged it somewhere else.
local function PlaceWindow()
    local win, sv = ui.win, S.sv
    if not win then return end
    win:ClearAnchors()
    if sv.docked ~= false and ui.launcher and not ui.launcher:IsHidden() then
        win:SetAnchor(TOPLEFT, ui.launcher, BOTTOMLEFT, 0, 6)
    elseif sv.x and sv.y then
        win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.x, sv.y)
    else
        win:SetAnchor(CENTER, GuiRoot, CENTER, 0, -40)
    end
end

-- Right-click on the launcher: favorites on screen, favorite sets, settings.
local function ShowLauncherMenu(launcher)
    ClearTooltip(InformationTooltip)
    ClearMenu()
    AddMenuItem(S.sv.quickBarShown and L("MENU_HIDE_FAVS") or L("MENU_SHOW_FAVS"),
        function() S.ToggleFavoritesOnScreen() end)
    local sets = S.GetSetNames()
    if #sets > 1 then
        local active = S.GetActiveSetName()
        for _, name in ipairs(sets) do
            local text = L("MENU_USE_SET", S.SetDisplayName(name))
            if name == active then text = text .. "  " .. L("MENU_CURRENT") end
            AddMenuItem(text, function() S.UseSetForCharacter(name) end)
        end
    end
    if S.OpenSettings then
        AddMenuItem(L("MENU_SETTINGS"), function() S.OpenSettings() end)
    end
    ShowMenu(launcher)
end

local function CreateLauncher()
    local sv = S.sv
    local launcher = WINDOW_MANAGER:CreateTopLevelWindow("CommandCodex_Launcher")
    launcher:SetHeight(LAUNCHER_H)
    launcher:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.launcherX, sv.launcherY)
    launcher:SetClampedToScreen(true)
    launcher:SetMouseEnabled(true)
    launcher:SetMovable(true)

    local bg = MakeRoundedBackground("CommandCodex_LauncherBG", launcher, LAUNCHER_H)
    bg:SetAlpha(LAUNCHER_BG_ALPHA)

    -- "/" in a small rounded key frame on the left
    local key = WINDOW_MANAGER:CreateControl("CommandCodex_LauncherKey", launcher, CT_TEXTURE)
    key:SetTexture(TEX_KEY)
    key:SetDimensions(22, 22)
    key:SetAnchor(LEFT, launcher, LEFT, 6, 0)
    key:SetMouseEnabled(false)
    ui.launcherKey = key
    local slash = MakeLabel("CommandCodex_LauncherSlash", key, "$(BOLD_FONT)|15|soft-shadow-thin", 22, 22, COLOR.selected)
    slash:SetText("/")
    slash:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    slash:SetAnchor(CENTER, key, CENTER, 0, 0)
    slash:SetMouseEnabled(false)

    local text = WINDOW_MANAGER:CreateControl("CommandCodex_LauncherText", launcher, CT_LABEL)
    text:SetFont("$(BOLD_FONT)|16|soft-shadow-thick")
    text:SetText(L("LAUNCHER"))
    text:SetAnchor(LEFT, key, RIGHT, 8, 0)
    text:SetDrawLevel(5)
    text:SetMouseEnabled(false)
    ui.launcherText = text
    -- Width follows the text, so longer translations still fit.
    launcher:SetWidth(6 + 22 + 8 + zo_max(text:GetTextWidth(), 90) + 16)

    launcher:SetHandler("OnMouseEnter", function(self)
        bg:SetAlpha(LAUNCHER_BG_ALPHA_HOVER)
        SetLauncherTextColor(true)
        InitializeTooltip(InformationTooltip, self, TOPLEFT, 0, 4, BOTTOMLEFT)
        SetTooltipText(InformationTooltip, L("LAUNCHER_TT"))
    end)
    launcher:SetHandler("OnMouseExit", function()
        bg:SetAlpha(LAUNCHER_BG_ALPHA)
        SetLauncherTextColor(false)
        ClearTooltip(InformationTooltip)
    end)
    -- Drag to move; a short click (no movement) opens / minimizes.
    launcher:SetHandler("OnMouseDown", function(self, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then ui.pressX, ui.pressY = self:GetLeft(), self:GetTop() end
    end)
    launcher:SetHandler("OnMoveStart", function() ClearTooltip(InformationTooltip) end)
    launcher:SetHandler("OnMoveStop", function(self)
        sv.launcherX, sv.launcherY = self:GetLeft(), self:GetTop()
        self:ClearAnchors()
        self:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.launcherX, sv.launcherY)
        sv.docked = true   -- moving the button brings the window along under it
        PlaceWindow()
    end)
    launcher:SetHandler("OnMouseUp", function(self, button, upInside)
        if button == MOUSE_BUTTON_INDEX_RIGHT and upInside then
            ShowLauncherMenu(self)
            return
        end
        if button ~= MOUSE_BUTTON_INDEX_LEFT then return end
        local moved = ui.pressX and (math.abs(self:GetLeft() - ui.pressX) > 3 or math.abs(self:GetTop() - ui.pressY) > 3)
        ui.pressX, ui.pressY = nil, nil
        if upInside and not moved then S.Toggle() end
    end)

    -- Small round "x" on the top-right corner: hides the button (type /codex to bring it back).
    local closeBg = WINDOW_MANAGER:CreateControl("CommandCodex_LauncherCloseBG", launcher, CT_TEXTURE)
    closeBg:SetTexture(TEX_CIRCLE)
    closeBg:SetColor(0, 0, 0, 0.85)
    closeBg:SetDimensions(16, 16)
    closeBg:SetAnchor(CENTER, launcher, TOPRIGHT, -2, 2)
    closeBg:SetDrawLevel(7)
    local closeRing = WINDOW_MANAGER:CreateControl("CommandCodex_LauncherCloseRing", closeBg, CT_TEXTURE)
    closeRing:SetTexture(TEX_RING)
    SetHexColor(closeRing, "4A4A44")
    closeRing:SetAnchorFill(closeBg)
    closeRing:SetDrawLevel(8)
    local close = MakeTextButton("CommandCodex_LauncherClose", closeBg, "x", "$(BOLD_FONT)|12|soft-shadow-thin", 16,
        L("LAUNCHER_HIDE_TT"),
        function()
            S.SetLauncherShown(false)
            S.Print(L("LAUNCHER_HIDDEN"))
        end)
    close:SetAnchor(CENTER, closeBg, CENTER, 0, -1)
    close:SetDrawLevel(9)

    -- Like ESO's own HUD: visible on the HUD (with or without cursor), hidden in menus.
    if ZO_HUDFadeSceneFragment and HUD_SCENE and HUD_UI_SCENE then
        ui.launcherFragment = ZO_HUDFadeSceneFragment:New(launcher)
        ui.launcherAttached = false
    end
    ui.launcher = launcher
    SetLauncherTextColor(false)
    S.SetLauncherShown(not sv.launcherHidden)
end

local function AttachToHud(control, fragment, attached, show)
    if fragment and attached ~= show then
        if show then
            HUD_SCENE:AddFragment(fragment)
            HUD_UI_SCENE:AddFragment(fragment)
        else
            HUD_SCENE:RemoveFragment(fragment)
            HUD_UI_SCENE:RemoveFragment(fragment)
        end
    end
    control:SetHidden(not show or (fragment ~= nil and not (HUD_SCENE:IsShowing() or HUD_UI_SCENE:IsShowing())))
    return show
end

function S.SetLauncherShown(show)
    if not ui.launcher then return end
    S.sv.launcherHidden = not show
    ui.launcherAttached = AttachToHud(ui.launcher, ui.launcherFragment, ui.launcherAttached, show)
end

local function CreateOpenAnimation(win)
    if not ANIMATION_MANAGER then return end
    local timeline = ANIMATION_MANAGER:CreateTimeline()
    local fade = timeline:InsertAnimation(ANIMATION_ALPHA, win)
    fade:SetAlphaValues(0, 1)
    fade:SetDuration(180)
    local grow = timeline:InsertAnimation(ANIMATION_SCALE, win)
    grow:SetScaleValues(0.94, 1)
    grow:SetDuration(220)
    if ZO_EaseOutCubic then
        fade:SetEasingFunction(ZO_EaseOutCubic)
        grow:SetEasingFunction(ZO_EaseOutCubic)
    end
    timeline:SetHandler("OnStop", function()
        if not ui.isOpen then ui.win:SetHidden(true) end
    end)
    ui.openAnim = timeline
end

-- ---------------------------------------------------------------------------
-- Window
-- ---------------------------------------------------------------------------
local function CreateWindow()
    local sv = S.sv
    local inner = WIN_W - PAD * 2
    local listW = inner - TREE_W - 20

    local win = WINDOW_MANAGER:CreateTopLevelWindow("CommandCodex_Window")
    win:SetDimensions(WIN_W, WIN_H)
    win:SetClampedToScreen(true)
    win:SetMouseEnabled(true)
    win:SetMovable(true)
    win:SetHidden(true)
    win:SetDrawTier(DT_MEDIUM)   -- above the favorites on screen if they overlap
    win:SetHandler("OnMoveStop", function(self)
        sv.x, sv.y = self:GetLeft(), self:GetTop()
        sv.docked = false
    end)
    ui.win = win

    MakeFadePanel(win, "CommandCodex_")

    -- Title and minimize "-"
    local title = MakeLabel("CommandCodex_Title", win, "ZoFontWinH1", inner - 80, 40, COLOR.selected)
    title:SetText(zo_strupper(L("TITLE")))
    title:SetAnchor(TOPLEFT, win, TOPLEFT, PAD, 12)

    local minimize = MakeTextButton("CommandCodex_Minimize", win, "-", "$(BOLD_FONT)|28|soft-shadow-thin", 28,
        L("MINIMIZE"), function() S.Toggle(false) end)
    minimize:SetAnchor(TOPRIGHT, win, TOPRIGHT, -PAD + 6, 14)

    local divider = MakeDivider("CommandCodex_Divider", win, inner)
    divider:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 2)

    -- Bottom, from the bottom up: status line, alias row, action buttons, divider
    ui.aliasStatus = MakeLabel("CommandCodex_AliasStatus", win, "ZoFontGameSmall", inner, 20, COLOR.good)
    ui.aliasStatus:SetAnchor(BOTTOMLEFT, win, BOTTOMLEFT, PAD, -10)

    local aliasLabel = MakeLabel("CommandCodex_AliasLabel", win, "ZoFontGameBold", 100, 28, COLOR.normal)
    aliasLabel:SetText(L("NEW_ALIAS"))
    aliasLabel:SetAnchor(BOTTOMLEFT, ui.aliasStatus, TOPLEFT, 0, -2)

    local nameBox, nameEdit = MakeEdit("CommandCodex_AliasName", win, 90, "/rl")
    nameBox:SetAnchor(LEFT, aliasLabel, RIGHT, 4, 0)
    ui.aliasName = nameEdit

    local runsLabel = MakeLabel("CommandCodex_RunsLabel", win, "ZoFontGame", 70, 28, COLOR.dim)
    runsLabel:SetText(L("RUNS"))
    runsLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    runsLabel:SetAnchor(LEFT, nameBox, RIGHT, 4, 0)

    local targetBox, targetEdit = MakeEdit("CommandCodex_AliasTarget", win, 300, "/reloadui")
    targetBox:SetAnchor(LEFT, runsLabel, RIGHT, 4, 0)
    -- Tip for running several commands with one alias.
    local function ShowAliasTip(control)
        InitializeTooltip(InformationTooltip, control, BOTTOM, 0, -6, TOP)
        SetTooltipText(InformationTooltip, L("ALIAS_TIP"))
        InformationTooltip:AddLine(L("ALIAS_TIP_CHAIN"), "ZoFontGameSmall", HexToRGB(COLOR.dim))
    end
    targetBox:SetHandler("OnMouseEnter", ShowAliasTip)
    targetBox:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)
    targetEdit:SetHandler("OnMouseEnter", function() ShowAliasTip(targetBox) end)
    targetEdit:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)
    ui.aliasTarget = targetEdit
    nameEdit:SetHandler("OnEnter", function() targetEdit:TakeFocus() end)
    targetEdit:SetHandler("OnEnter", AddAliasFromEditor)

    local add = MakeButton("CommandCodex_AliasAdd", win, L("ADD"), 110, AddAliasFromEditor)
    add:SetAnchor(LEFT, targetBox, RIGHT, 12, 0)

    -- Action buttons for the selected command
    -- (Running is done with the small arrow on each row.)
    ui.actions = {}
    ui.actions.chat = MakeButton("CommandCodex_ActChat", win, L("BTN_CHAT"), 150,
        function() if ui.selected then PutInChat(ui.selected) end end)
    ui.actions.chat:SetAnchor(BOTTOMLEFT, aliasLabel, TOPLEFT, 0, -12)
    ui.actions.favorite = MakeButton("CommandCodex_ActFav", win, L("BTN_FAVORITE"), 150,
        function() if ui.selected then ToggleFavorite(ui.selected) end end)
    ui.actions.favorite:SetAnchor(LEFT, ui.actions.chat, RIGHT, 10, 0)
    ui.actions.delete = MakeButton("CommandCodex_ActDelete", win, L("BTN_DELETE_ALIAS"), 150,
        function() if ui.selected then DeleteAlias(ui.selected) end end)
    ui.actions.delete:SetAnchor(LEFT, ui.actions.favorite, RIGHT, 10, 0)

    local divider2 = MakeDivider("CommandCodex_Divider2", win, inner)
    divider2:SetAnchor(BOTTOMLEFT, ui.actions.chat, TOPLEFT, 0, -10)

    -- Left: search, options, category tree
    local searchBox, search = MakeEdit("CommandCodex_Search", win, TREE_W, L("SEARCH"))
    searchBox:SetAnchor(TOPLEFT, divider, BOTTOMLEFT, 0, 12)
    search:SetHandler("OnTextChanged", function() S.RefreshAll() end)
    ui.search = search

    local quickBar = MakeCheck("CommandCodex_ShowBar", win, L("SHOW_FAVS"),
        function() return S.sv.quickBarShown end,
        function(checked) S.SetQuickBarShown(checked) end,
        L("SHOW_FAVS_TT"))
    quickBar:SetAnchor(TOPLEFT, searchBox, BOTTOMLEFT, 2, 12)
    ui.quickBarCheck = quickBar

    -- Padlock: faint and closed = favorites locked in place; click to open it and drag them around.
    -- A real button (not just an image) drawn above the checkbox label next to it,
    -- which otherwise stretches over it and catches the clicks.
    local lock = WINDOW_MANAGER:CreateControl("CommandCodex_LockIcon", win, CT_BUTTON)
    lock:SetDimensions(18, 18)
    lock:SetAnchor(TOPRIGHT, searchBox, BOTTOMRIGHT, -2, 11)
    lock:SetDrawLevel(20)
    lock:SetMouseEnabled(true)
    LeftClickOnly(lock)
    lock:SetHitInsets(-5, -5, 5, 5)   -- a bit easier to hit than the 18px icon
    lock:SetHandler("OnMouseEnter", function(self)
        self:SetAlpha(1)
        InitializeTooltip(InformationTooltip, self, BOTTOM, 0, -6, TOP)
        SetTooltipText(InformationTooltip, S.sv.quickLocked and L("LOCK_TT_LOCKED") or L("LOCK_TT_UNLOCKED"))
    end)
    lock:SetHandler("OnMouseExit", function()
        S.UpdateLockIcon()
        ClearTooltip(InformationTooltip)
    end)
    lock:SetHandler("OnClicked", function(self)
        ClearTooltip(InformationTooltip)
        PlaySound(SOUNDS.DEFAULT_CLICK)
        S.SetQuickLocked(not S.sv.quickLocked)
        self:SetAlpha(1)   -- mouse is still on it; fades again on mouse exit if locked
    end)
    ui.lockIcon = lock
    S.UpdateLockIcon()

    -- "Reset positions": puts every favorite back where it started (top center of the screen).
    local reset = MakeLabel("CommandCodex_ResetPos", win, "ZoFontGameSmall", 200, 20, COLOR.dim)
    reset:SetText(L("RESET_POS"))
    reset:SetAnchor(TOPLEFT, quickBar, BOTTOMLEFT, 22, 6)
    reset:SetMouseEnabled(true)
    reset:SetHandler("OnMouseEnter", function(self)
        SetHexColor(self, COLOR.selected)
        InitializeTooltip(InformationTooltip, self, BOTTOM, 0, -6, TOP)
        SetTooltipText(InformationTooltip, L("RESET_POS_TT"))
    end)
    reset:SetHandler("OnMouseExit", function(self)
        SetHexColor(self, COLOR.dim)
        ClearTooltip(InformationTooltip)
    end)
    reset:SetHandler("OnMouseUp", function(_, button, upInside)
        if upInside and button == MOUSE_BUTTON_INDEX_LEFT then
            ClearTooltip(InformationTooltip)
            PlaySound(SOUNDS.DEFAULT_CLICK)
            S.ResetFavoritePositions()
            S.Print(L("FAVS_RESET"))
        end
    end)

    local tree = WINDOW_MANAGER:CreateControlFromVirtual("CommandCodex_Tree", win, "ZO_ScrollList")
    tree:SetAnchor(TOPLEFT, searchBox, BOTTOMLEFT, 0, 62)
    tree:SetAnchor(BOTTOMLEFT, divider2, TOPLEFT, 0, -8)
    tree:SetWidth(TREE_W)
    ZO_ScrollList_AddDataType(tree, DATA_TYPE_CATEGORY, "CommandCodex_Category", 30, SetupCategory)
    ZO_ScrollList_AddDataType(tree, DATA_TYPE_SUBCATEGORY, "CommandCodex_SubCategory", 24, SetupCategory)
    ui.tree = tree

    -- Right: category title, count, command list
    ui.viewTitle = MakeLabel("CommandCodex_ViewTitle", win, "ZoFontWinH3", listW - 120, 28, COLOR.header)
    ui.viewTitle:SetAnchor(TOPLEFT, searchBox, TOPRIGHT, 20, 0)

    ui.count = MakeLabel("CommandCodex_Count", win, "ZoFontGameSmall", 120, 28, COLOR.dim)
    ui.count:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    ui.count:SetAnchor(TOPRIGHT, divider, BOTTOMRIGHT, 0, 12)

    local list = WINDOW_MANAGER:CreateControlFromVirtual("CommandCodex_List", win, "ZO_ScrollList")
    list:SetAnchor(TOPLEFT, ui.viewTitle, BOTTOMLEFT, 0, 10)
    list:SetAnchor(BOTTOMRIGHT, divider2, TOPRIGHT, 0, -8)
    ZO_ScrollList_AddDataType(list, DATA_TYPE_COMMAND, "CommandCodex_Row", 28, SetupRow)
    ZO_ScrollList_AddDataType(list, DATA_TYPE_HEADER, "CommandCodex_Header", 34, SetupHeader)
    ZO_ScrollList_AddDataType(list, DATA_TYPE_NOTE, "CommandCodex_Note", 40, SetupNote)
    ZO_ScrollList_EnableHighlight(list, "ZO_ThinListHighlight")
    ZO_ScrollList_EnableSelection(list, "ZO_ThinListHighlight", OnSelectionChanged)
    ui.list = list

    ui.empty = MakeLabel("CommandCodex_Empty", win, "ZoFontGame", listW - 20, 60, COLOR.dim)
    ui.empty:SetAnchor(TOP, list, TOP, 0, 40)
    ui.empty:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    ui.empty:SetHidden(true)

    CreateOpenAnimation(win)
end

-- Game menus (AddOns, inventory, map, ...): hide the open window while one is up,
-- and show it again in the same state when the player is back in the game.
local function IsHudScene(scene)
    return scene == HUD_SCENE or scene == HUD_UI_SCENE
end

local function OnSceneStateChanged(scene, _, newState)
    if not ui.win or not ui.isOpen then return end
    if newState == SCENE_SHOWING and not IsHudScene(scene) and not ui.hiddenByMenu then
        ui.hiddenByMenu = true
        ClearMenu()
        ClearTooltip(InformationTooltip)
        CloseNoteEditor()
        ui.win:SetHidden(true)
    elseif newState == SCENE_SHOWN and IsHudScene(scene) and ui.hiddenByMenu then
        ui.hiddenByMenu = false
        ui.win:SetHidden(false)
    end
end

-- Open (true), minimize (false) or flip (nil).
function S.Toggle(show)
    if not ui.win then return end
    if show == nil then show = not ui.isOpen end
    if show == (ui.isOpen == true) then return end
    ui.isOpen = show
    ui.hiddenByMenu = false
    SetLauncherTextColor(false)

    if show then
        PlaceWindow()
        ui.win:SetHidden(false)
        SetAliasStatus("")
        S.RefreshAll()
        SetGameCameraUIMode(true)   -- mouse cursor, but stay in the game world
        if ui.openAnim then
            if ui.openAnim:IsPlaying() then ui.openAnim:PlayForward() else ui.openAnim:PlayFromStart() end
        else
            ui.win:SetAlpha(1)
        end
    else
        ClearMenu()
        ClearTooltip(InformationTooltip)
        CloseNoteEditor()
        ui.search:LoseFocus()
        ui.aliasName:LoseFocus()
        ui.aliasTarget:LoseFocus()
        if ui.openAnim then
            if ui.openAnim:IsPlaying() then ui.openAnim:PlayBackward() else ui.openAnim:PlayFromEnd() end
        else
            ui.win:SetHidden(true)
        end
    end
end

-- /codex and the keybind: bring the button back if it was hidden, and open / minimize the window.
function S.ToggleWindow()
    if S.sv.launcherHidden then S.SetLauncherShown(true) end
    S.Toggle()
end

-- /codex aui: open the window (All commands) with the search already filled in.
function S.OpenWithSearch(text)
    if S.sv.launcherHidden then S.SetLauncherShown(true) end
    S.sv.view, S.sv.addon = "all", nil
    S.Toggle(true)
    ui.search:SetText(text)   -- OnTextChanged refreshes the list
end

-- ---------------------------------------------------------------------------
-- Favorites on screen: every favorite of the active set is its own small button.
-- Each one can be dragged anywhere (while unlocked) and remembers its spot.
-- The key bound to "Run favorite 1-5" shows in front of the command.
-- ---------------------------------------------------------------------------
local QB_H, QB_MAX = 30, 10

-- Where a button goes the first time: a row along the top center of the screen.
local function DefaultQuickPosition(slot)
    local rowWidth = QB_MAX * 120
    local x = zo_floor(GuiRoot:GetWidth() / 2 - rowWidth / 2 + (slot - 1) * 120)
    return x, 10
end

local function PlaceQuickButton(btn, slot)
    local pos = S.Set().pos[btn.command]
    local x, y
    if pos then
        x, y = pos.x, pos.y
    else
        x, y = DefaultQuickPosition(slot)
    end
    btn:ClearAnchors()
    btn:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

-- Short name of the key bound to "Run favorite <slot>", e.g. "F5" or "Shift+F5"; nil if unbound.
local MODIFIER_NAMES = { Control = "Ctrl", ["Left Control"] = "Ctrl", ["Right Control"] = "Ctrl",
    ["Left Shift"] = "Shift", ["Right Shift"] = "Shift", ["Left Alt"] = "Alt", ["Right Alt"] = "Alt" }

local function GetBoundKeyText(slot)
    if not (GetActionIndicesFromName and GetActionBindingInfo and GetKeyName) then return nil end
    local layer, category, action = GetActionIndicesFromName("COMMANDCODEX_FAV" .. slot)
    if not layer then return nil end
    local maxBindings = GetMaxBindingsPerAction and GetMaxBindingsPerAction() or 4
    for bindingIndex = 1, maxBindings do
        local key, mod1, mod2, mod3, mod4 = GetActionBindingInfo(layer, category, action, bindingIndex)
        if key and key ~= 0 and key ~= KEY_INVALID then
            local parts = {}
            for _, mod in ipairs({ mod1, mod2, mod3, mod4 }) do
                if mod and mod ~= 0 and mod ~= KEY_INVALID then
                    local name = GetKeyName(mod)
                    parts[#parts + 1] = MODIFIER_NAMES[name] or name
                end
            end
            parts[#parts + 1] = GetKeyName(key)
            return table.concat(parts, "+")
        end
    end
    return nil
end

-- Opens ESO's own "press a key" dialog for "Run favorite <slot>", the same one
-- Controls > Keybindings shows, so there's no need to find it in the menu.
function S.OpenKeybindDialog(slot, command)
    if slot > 5 then
        S.Print(L("KEY_ONLY_5"))
        return
    end
    local layer, category, action
    if GetActionIndicesFromName then
        layer, category, action = GetActionIndicesFromName("COMMANDCODEX_FAV" .. slot)
    end
    local ok = layer ~= nil and pcall(ZO_Dialogs_ShowDialog, "BINDINGS", {
        layerIndex = layer,
        categoryIndex = category,
        actionIndex = action,
        bindingIndex = 1,
        localizedActionName = L("KEY_DIALOG_NAME", slot, command),
    })
    if not ok then
        S.Print(L("KEY_DIALOG_FAIL", slot))
    end
end

local function QuickTooltip(btn)
    InitializeTooltip(InformationTooltip, btn, TOP, 0, 6, BOTTOM)
    SetTooltipText(InformationTooltip, btn.command)
    local note = S.GetNote(btn.command)
    if note then
        InformationTooltip:AddLine(note, "ZoFontGame", HexToRGB(COLOR.note))
    end
    local alias = S.sv.aliases[btn.command]
    if alias then
        InformationTooltip:AddLine(L("QT_RUNS", alias), "ZoFontGameSmall", HexToRGB(COLOR.alias))
    end
    local lines = { L("QT_CLICK") }
    if btn.keyText then
        lines[#lines + 1] = L("QT_KEY", btn.keyText)
    elseif btn.slot <= 5 then
        lines[#lines + 1] = L("QT_BIND_HINT")
    end
    if not S.sv.quickLocked then lines[#lines + 1] = L("QT_DRAG") end
    InformationTooltip:AddLine(table.concat(lines, "\n"), "ZoFontGameSmall", HexToRGB(COLOR.dim))
end

local function CreateQuickButton(slot)
    local btn = WINDOW_MANAGER:CreateTopLevelWindow("CommandCodex_Quick" .. slot)
    btn:SetHeight(QB_H)
    btn:SetDrawTier(DT_HIGH)   -- above the chat window etc., so it can always be grabbed
    btn:SetClampedToScreen(true)
    btn:SetMouseEnabled(true)
    btn.slot = slot

    btn.bg = MakeRoundedBackground(btn:GetName() .. "BG", btn, QB_H)
    btn.bg:SetAlpha(0.6)

    -- Dots on the left, only while unlocked: shows the button can be moved.
    local grip = MakeLabel(btn:GetName() .. "Grip", btn, "$(BOLD_FONT)|14|soft-shadow-thin", 10, QB_H, COLOR.dim)
    grip:SetText(":")
    grip:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    grip:SetAnchor(LEFT, btn, LEFT, 6, 0)
    grip:SetMouseEnabled(false)
    btn.grip = grip

    local number = MakeLabel(btn:GetName() .. "Slot", btn, "$(BOLD_FONT)|12|soft-shadow-thin", 10, QB_H, COLOR.dim)
    number:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    number:SetMouseEnabled(false)
    btn.number = number

    local label = WINDOW_MANAGER:CreateControl(btn:GetName() .. "Text", btn, CT_LABEL)
    label:SetFont("$(BOLD_FONT)|15|soft-shadow-thick")
    label:SetAnchor(LEFT, number, RIGHT, 4, 0)
    label:SetMouseEnabled(false)
    SetHexColor(label, COLOR.normal)
    btn.label = label

    btn:SetHandler("OnMouseEnter", function(self)
        SetHexColor(label, COLOR.selected)
        self.bg:SetAlpha(0.85)
        QuickTooltip(self)
    end)
    btn:SetHandler("OnMouseExit", function(self)
        SetHexColor(label, COLOR.normal)
        self.bg:SetAlpha(0.6)
        ClearTooltip(InformationTooltip)
    end)
    -- Drag to move (while unlocked); a click without moving runs the command.
    btn:SetHandler("OnMouseDown", function(self, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then self.pressX, self.pressY = self:GetLeft(), self:GetTop() end
    end)
    btn:SetHandler("OnMoveStart", function() ClearTooltip(InformationTooltip) end)
    btn:SetHandler("OnMoveStop", function(self)
        if not self.command then return end
        S.Set().pos[self.command] = { x = self:GetLeft(), y = self:GetTop() }
        PlaceQuickButton(self, self.slot)
    end)
    btn:SetHandler("OnMouseUp", function(self, button, upInside)
        if not self.command then return end
        local command = self.command
        if button == MOUSE_BUTTON_INDEX_LEFT then
            local moved = self.pressX and (math.abs(self:GetLeft() - self.pressX) > 3 or math.abs(self:GetTop() - self.pressY) > 3)
            self.pressX, self.pressY = nil, nil
            if upInside and not moved then
                ClearTooltip(InformationTooltip)
                S.RunAndRecord(command)
            end
        elseif button == MOUSE_BUTTON_INDEX_RIGHT and upInside then
            ClearMenu()
            AddMenuItem(L("MENU_RUN"), function() S.RunAndRecord(command) end)
            AddMenuItem(L("MENU_CHAT"), function() StartChatInput(command .. " ") end)
            if self.slot <= 5 then
                local slot = self.slot
                AddMenuItem(self.keyText and L("MENU_CHANGE_KEY") or L("MENU_BIND"), function()
                    S.OpenKeybindDialog(slot, command)
                end)
            end
            AddMenuItem(L("MENU_RESET_POS"), function()
                S.Set().pos[command] = nil
                PlaceQuickButton(self, self.slot)
            end)
            AddMenuItem(L("MENU_REMOVE_FAV"), function()
                S.ToggleFavorite(command)
                S.RefreshAll()
            end)
            AddMenuItem(L("MENU_HIDE_FAVS"), function()
                S.SetQuickBarShown(false)
                S.Print(L("FAVS_HIDDEN"))
            end)
            ShowMenu(self)
        end
    end)

    if ZO_HUDFadeSceneFragment and HUD_SCENE and HUD_UI_SCENE then
        btn.fragment = ZO_HUDFadeSceneFragment:New(btn)
        btn.attached = false
    end
    ui.qbButtons[slot] = btn
    return btn
end

-- Size, text and lock state of one button.
local function LayoutQuickButton(btn, slot, command)
    local locked = S.sv.quickLocked
    local left = locked and 8 or 18
    btn.command = command
    btn:SetMovable(not locked)
    btn.grip:SetHidden(locked)

    -- The key bound to "Run favorite <slot>" (e.g. F5) in front of the command; nothing if unbound.
    local keyText = slot <= 5 and GetBoundKeyText(slot) or nil
    btn.keyText = keyText
    btn.number:SetText(keyText or "")
    local keyW = keyText and (btn.number:GetTextWidth() + 2) or 0
    btn.number:SetWidth(keyW)
    btn.number:ClearAnchors()
    btn.number:SetAnchor(LEFT, btn, LEFT, left, 0)

    btn.label:ClearAnchors()
    btn.label:SetAnchor(LEFT, btn.number, RIGHT, keyText and 6 or 0, 0)
    btn.label:SetText(command)
    local width = left + keyW + (keyText and 6 or 0) + zo_max(btn.label:GetTextWidth(), 20) + 12
    btn:SetWidth(width)
end

function S.RefreshQuickBar()
    if not ui.qbButtons then return end
    local order = S.GetFavoriteOrder()
    local show = S.sv.quickBarShown
    for slot = 1, QB_MAX do
        local command = order[slot]
        local btn = ui.qbButtons[slot]
        if command and not btn then btn = CreateQuickButton(slot) end
        if btn then
            if command then
                LayoutQuickButton(btn, slot, command)
                PlaceQuickButton(btn, slot)
            else
                btn.command = nil
            end
            btn.attached = AttachToHud(btn, btn.fragment, btn.attached, show and command ~= nil)
        end
    end
end

-- /codex reset: every favorite of the active set back to its starting spot.
function S.ResetFavoritePositions()
    ZO_ClearTable(S.Set().pos)
    if S.sv.quickBarShown then
        S.RefreshQuickBar()
    else
        S.SetQuickBarShown(true)   -- show them, or the reset would look like it did nothing
    end
end

-- Launcher right-click menu and the "Show/hide favorites on screen" keybind.
function S.ToggleFavoritesOnScreen()
    S.SetQuickBarShown(not S.sv.quickBarShown)
end

function S.SetQuickBarShown(show)
    S.sv.quickBarShown = show
    if ui.quickBarCheck then ZO_CheckButton_SetCheckState(ui.quickBarCheck, show) end
    S.RefreshQuickBar()
end

-- Closed and faint while locked, open and bright while unlocked.
function S.UpdateLockIcon()
    local lock = ui.lockIcon
    if not lock then return end
    local locked = S.sv.quickLocked
    local texture = locked and TEX_LOCK_CLOSED or TEX_LOCK_OPEN
    lock:SetNormalTexture(texture)
    lock:SetMouseOverTexture(texture)
    lock:SetPressedTexture(texture)
    lock:SetAlpha(locked and 0.35 or 1)
end

function S.SetQuickLocked(locked)
    S.sv.quickLocked = locked
    S.UpdateLockIcon()
    S.RefreshQuickBar()
end

local function CreateQuickBar()
    ui.qbButtons = {}
    S.RefreshQuickBar()
    -- Update the key shown on each favorite when the player (re)binds keys.
    local function OnKeybindsChanged() S.RefreshQuickBar() end
    for _, event in ipairs({ EVENT_KEYBINDING_SET, EVENT_KEYBINDING_CLEARED, EVENT_KEYBINDINGS_LOADED }) do
        if event then EVENT_MANAGER:RegisterForEvent("CommandCodex_Keys", event, OnKeybindsChanged) end
    end
end

function S.InitUI()
    CreateWindow()
    CreateLauncher()
    CreateQuickBar()
    PlaceWindow()
    SCENE_MANAGER:RegisterCallback("SceneStateChanged", OnSceneStateChanged)
end
