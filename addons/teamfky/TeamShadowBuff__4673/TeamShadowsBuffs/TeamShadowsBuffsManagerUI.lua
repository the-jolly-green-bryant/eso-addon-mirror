-- =====================================================================
--  Team Shadows Manager - UI custom (1 onglet, tout cablé sur l'addon)
-- ---------------------------------------------------------------------
--  Chaque contrôle pointe sur un vrai champ savedVars / une vraie
--  fonction de l'addon. Pas de stub, pas de champ ignoré.
--
--  Charger : ajouter dans TeamShadowsBuffs.txt
--      TeamShadowsBuffsManagerUI.lua
--  puis /reloadui. Ouvrir : /tsbui
-- =====================================================================

TeamShadowsBuffs = TeamShadowsBuffs or {}
local TSB = TeamShadowsBuffs
local WM = WINDOW_MANAGER

local C = {
    panel = { 0.05, 0.06, 0.08, 0.97 }, card = { 0.09, 0.10, 0.13, 0.95 },
    cardEdge = { 0.16, 0.18, 0.22, 1.0 }, gold = { 0.79, 0.63, 0.18, 1.0 },
    cyan = { 0.28, 0.68, 0.90, 1.0 }, blue = { 0.18, 0.50, 0.93, 1.0 },
    text = { 0.86, 0.88, 0.92, 1.0 }, textDim = { 0.55, 0.58, 0.64, 1.0 },
    track = { 0.18, 0.20, 0.24, 1.0 },
}
local FONT_TITLE, FONT_HEADER = "ZoFontWinH2", "ZoFontWinH4"
local FONT_LABEL, FONT_SMALL = "ZoFontGameBold", "ZoFontGameSmall"

local NAME = "TeamShadowsManager"
local UI = {}
local M, currentKey, testMode = nil, nil, false
local activeTab = "buffs"
local VISIBLE_ROWS, ROW_STEP = 10, 50

-- 3 onglets. Les 2 premiers regroupent des catégories ; "actifs" n'affiche que
-- les trackers actuellement activés (toutes catégories confondues).
local TAB_GROUPS = {
    { id = "buffs", label = "BUFFS & COMPÉTENCES", cats = { "major_buffs", "boss_debuffs", "support_debuffs", "status_effects", "skill_stacks", "skill_procs" } },
    { id = "procs", label = "SETS & PROCS", cats = { "set_stacks", "set_procs", "monster_sets", "dungeon_proc_sets", "overland_crafted_pvp_procs", "trial_proc_sets", "mythic_stacks" } },
    { id = "actifs", label = "ACTIFS", activesOnly = true },
}

-- ---------------------------------------------------------------------
--  Helpers
-- ---------------------------------------------------------------------
local function unpack4(c) return c[1], c[2], c[3], c[4] end
local function Saved() return TSB.savedVars or {} end
local function clamp(v, lo, hi) if v < lo then return lo elseif v > hi then return hi else return v end end

local function Apply()
    if TSB.UI and TSB.UI.ApplySettings then
        if TSB.SafeCall then TSB.SafeCall("UI", "ApplySettings", TSB.UI.ApplySettings, TSB.UI)
        else TSB.UI:ApplySettings() end
    end
end

local function Backdrop(parent, color, edge)
    local b = WM:CreateControl(nil, parent, CT_BACKDROP)
    b:SetCenterColor(unpack4(color))
    b:SetEdgeColor(edge and edge[1] or 0, edge and edge[2] or 0, edge and edge[3] or 0, edge and edge[4] or 0)
    b:SetEdgeTexture("", 1, 1, 1)
    return b
end

local function Label(parent, font, color, text, align)
    local l = WM:CreateControl(nil, parent, CT_LABEL)
    l:SetFont(font); l:SetColor(unpack4(color))
    if text then l:SetText(text) end
    if align then l:SetHorizontalAlignment(align) end
    return l
end

local function FlatButton(parent, text, w, h, onClick, bgColor, txtColor)
    local btn = WM:CreateControl(nil, parent, CT_CONTROL)
    btn:SetDimensions(w, h); btn:SetMouseEnabled(true)
    btn.bg = Backdrop(btn, bgColor or C.card, C.cardEdge); btn.bg:SetAnchorFill(btn)
    btn.label = Label(btn, FONT_LABEL, txtColor or C.text, text, TEXT_ALIGN_CENTER)
    btn.label:SetAnchor(CENTER, btn, CENTER, 0, 0)
    btn:SetHandler("OnMouseEnter", function() btn.bg:SetCenterColor(unpack4(C.cardEdge)) end)
    btn:SetHandler("OnMouseExit", function() btn.bg:SetCenterColor(unpack4(bgColor or C.card)) end)
    btn:SetHandler("OnMouseUp", function(_, _, upInside) if upInside and onClick then onClick() end end)
    return btn
end

-- ---------------------------------------------------------------------
--  Widgets réutilisables
-- ---------------------------------------------------------------------
local function MakeCard(parent, title)
    local card = WM:CreateControl(nil, parent, CT_CONTROL)
    card.bg = Backdrop(card, C.card, C.cardEdge); card.bg:SetAnchorFill(card)
    card.title = Label(card, FONT_HEADER, C.cyan, title)
    card.title:SetAnchor(TOPLEFT, card, TOPLEFT, 18, 12)
    card.content = WM:CreateControl(nil, card, CT_CONTROL)
    card.content:SetAnchor(TOPLEFT, card, TOPLEFT, 18, 42)
    card.content:SetAnchor(BOTTOMRIGHT, card, BOTTOMRIGHT, -18, -12)
    return card
end

local function MakeToggle(parent, getFunc, setFunc)
    local W, H = 44, 22
    local tg = WM:CreateControl(nil, parent, CT_CONTROL)
    tg:SetDimensions(W, H); tg:SetMouseEnabled(true)
    tg.track = Backdrop(tg, C.track); tg.track:SetAnchorFill(tg)
    tg.knob = Backdrop(tg, { 0.95, 0.96, 0.98, 1 }); tg.knob:SetDimensions(H - 6, H - 6)
    local function redraw()
        local on = getFunc() == true
        tg.track:SetCenterColor(on and C.blue[1] or C.track[1], on and C.blue[2] or C.track[2], on and C.blue[3] or C.track[3], 1)
        tg.knob:ClearAnchors()
        if on then tg.knob:SetAnchor(RIGHT, tg, RIGHT, -3, 0) else tg.knob:SetAnchor(LEFT, tg, LEFT, 3, 0) end
    end
    tg:SetHandler("OnMouseUp", function(_, _, upInside) if upInside then setFunc(getFunc() ~= true); redraw() end end)
    tg.Redraw = redraw; redraw()
    return tg
end

local function MakeSegmented(parent, choices, getFunc, setFunc)
    local seg = WM:CreateControl(nil, parent, CT_CONTROL)
    local segW, segH = 64, 26
    seg:SetDimensions(segW * #choices, segH); seg.cells = {}
    local function redraw()
        local sel = getFunc()
        for i, cell in ipairs(seg.cells) do
            local active = (i == sel)
            cell.bg:SetCenterColor(active and C.blue[1] or C.card[1], active and C.blue[2] or C.card[2], active and C.blue[3] or C.card[3], 1)
            cell.label:SetColor(unpack4(active and C.text or C.textDim))
        end
    end
    for i, choice in ipairs(choices) do
        local cell = WM:CreateControl(nil, seg, CT_CONTROL)
        cell:SetDimensions(segW, segH); cell:SetAnchor(LEFT, seg, LEFT, (i - 1) * segW, 0); cell:SetMouseEnabled(true)
        cell.bg = Backdrop(cell, C.card, C.cardEdge); cell.bg:SetAnchorFill(cell)
        cell.label = Label(cell, FONT_SMALL, C.textDim, choice, TEXT_ALIGN_CENTER)
        cell.label:SetAnchor(CENTER, cell, CENTER, 0, 0)
        cell:SetHandler("OnMouseUp", function(_, _, upInside) if upInside then setFunc(i); redraw() end end)
        seg.cells[i] = cell
    end
    seg.Redraw = redraw; redraw()
    return seg
end

local function MakeSwatch(parent, getFunc, setFunc)
    local sw = WM:CreateControl(nil, parent, CT_CONTROL)
    sw:SetDimensions(48, 26); sw:SetMouseEnabled(true)
    sw.bg = Backdrop(sw, { 1, 1, 1, 1 }, C.cardEdge); sw.bg:SetAnchorFill(sw)
    local function redraw()
        local c = getFunc() or {}
        sw.bg:SetCenterColor(c.r or 1, c.g or 1, c.b or 1, 1)
    end
    sw:SetHandler("OnMouseUp", function(_, _, upInside)
        if not upInside or not COLOR_PICKER then return end
        local c = getFunc() or {}
        COLOR_PICKER:Show(function(r, g, b, a) setFunc(r, g, b, a or 1); redraw() end, c.r or 1, c.g or 1, c.b or 1, c.a or 1, "Couleur")
    end)
    sw.Redraw = redraw; redraw()
    return sw
end

local function MakeSlider(parent, width, minV, maxV, step, getFunc, setFunc, suffix)
    local sl = WM:CreateControl(nil, parent, CT_CONTROL)
    sl:SetDimensions(width, 22)
    sl:SetMouseEnabled(true) -- toute la ligne capte la souris (gros hit area, capte le clic)
    local trackW = width - 44
    -- track/fill/knob = purement visuels (pas de souris -> pas de conflit)
    sl.track = Backdrop(sl, C.track); sl.track:SetDimensions(trackW, 6); sl.track:SetAnchor(LEFT, sl, LEFT, 0, 0)
    sl.fill = Backdrop(sl.track, C.blue); sl.fill:SetAnchor(LEFT, sl.track, LEFT, 0, 0); sl.fill:SetHeight(6)
    sl.knob = Backdrop(sl.track, { 0.95, 0.96, 0.98, 1 }); sl.knob:SetDimensions(13, 13)
    sl.value = Label(sl, FONT_SMALL, C.text, "", TEXT_ALIGN_RIGHT); sl.value:SetAnchor(RIGHT, sl, RIGHT, 0, 0); sl.value:SetDimensions(40, 22)
    local function ratioToVal(r) local v = minV + (maxV - minV) * r; if step and step > 0 then v = zo_round(v / step) * step end; return clamp(v, minV, maxV) end
    local function redraw()
        local v = getFunc() or minV
        local ratio = (maxV > minV) and clamp((v - minV) / (maxV - minV), 0, 1) or 0
        sl.fill:SetWidth(zo_max(1, trackW * ratio))
        sl.knob:ClearAnchors(); sl.knob:SetAnchor(CENTER, sl.track, LEFT, trackW * ratio, 0)
        sl.value:SetText(((step and step < 1) and string.format("%.2f", v) or tostring(zo_round(v))) .. (suffix or ""))
    end
    local function setFromCursor()
        local mx = GetUIMousePosition and GetUIMousePosition() or 0
        local left = sl.track:GetLeft() or 0
        local w = sl.track:GetWidth() or trackW
        if w <= 0 then w = trackW end
        setFunc(ratioToVal(clamp((mx - left) / w, 0, 1))); redraw()
    end
    sl:SetHandler("OnMouseDown", function() sl.dragging = true; setFromCursor() end)
    sl:SetHandler("OnMouseUp", function() sl.dragging = false end)
    sl:SetHandler("OnUpdate", function() if sl.dragging then setFromCursor() end end)
    sl.Redraw = redraw; redraw()
    return sl
end

local function MakeEditbox(parent, width, getFunc, setFunc)
    local box = WM:CreateControl(nil, parent, CT_CONTROL)
    box:SetDimensions(width, 30)
    box:SetMouseEnabled(true)
    box.bg = Backdrop(box, { 0.04, 0.05, 0.07, 1 }, C.cardEdge); box.bg:SetAnchorFill(box)
    box.edit = WM:CreateControl(nil, box, CT_EDITBOX)
    box.edit:SetAnchor(TOPLEFT, box, TOPLEFT, 10, 0); box.edit:SetAnchor(BOTTOMRIGHT, box, BOTTOMRIGHT, -10, 0)
    box.edit:SetFont(FONT_LABEL); box.edit:SetColor(unpack4(C.text))
    box.edit:SetMaxInputChars(40)
    box.edit:SetMouseEnabled(true)
    box.edit:SetEditEnabled(true)
    box.edit:SetText(getFunc() or "")

    -- INDISPENSABLE : un CT_EDITBOX créé en Lua ne prend pas le focus clavier
    -- au clic tout seul. On le force, sinon impossible de taper dedans.
    local function focus() box.edit:TakeFocus() end
    box.edit:SetHandler("OnMouseUp", focus)
    box:SetHandler("OnMouseUp", focus) -- clic dans la marge -> focus aussi

    box.edit:SetHandler("OnTextChanged", function(self) setFunc(self:GetText() or "") end)
    box.edit:SetHandler("OnEnter", function(self) self:LoseFocus() end)
    box.edit:SetHandler("OnEscape", function(self) self:LoseFocus() end)
    box.edit:SetHandler("OnFocusLost", function()
        Apply()
        if UI.RefreshList then UI:RefreshList() end -- maj de l'acronyme/nom dans la liste
    end)

    box.Redraw = function()
        -- ne pas réécrire pendant la frappe (sinon on efface ce qu'on tape)
        if box.edit.HasFocus and box.edit:HasFocus() then return end
        box.edit:SetText(getFunc() or "")
    end
    return box
end

-- ---------------------------------------------------------------------
--  Données effets
-- ---------------------------------------------------------------------
local function EffectSettings(k) return TSB.GetEffectSettings and TSB.GetEffectSettings(k) or {} end
local function EffectDef(k) return TSB.GetMajorEffectByKey and TSB.GetMajorEffectByKey(k) or {} end
local function EffName(k) local s = EffectSettings(k); return (s.name and s.name ~= "" and s.name) or EffectDef(k).name or k end
local function EffShort(k) local s = EffectSettings(k); return (s.shortName and s.shortName ~= "" and s.shortName) or EffectDef(k).shortName or "?" end
local function EffColor(k) local s = EffectSettings(k); return s.color or EffectDef(k).color or { r = 1, g = 1, b = 1, a = 1 } end
local function EffEnabled(k)
    local s = EffectSettings(k)
    if s.enabled ~= nil then return s.enabled end
    if TSB.IsEffectEnabledByKey then return TSB.IsEffectEnabledByKey(k) end
    return false
end

-- helpers couleur <-> hex RRGGBBAA (pour import/export)
local function ColorToHex(c)
    local function b(x) x = math.floor((tonumber(x) or 1) * 255 + 0.5); if x < 0 then x = 0 elseif x > 255 then x = 255 end; return string.format("%02X", x) end
    c = c or {}
    return b(c.r) .. b(c.g) .. b(c.b) .. b(c.a == nil and 1 or c.a)
end
local function HexToColor(h)
    if not h or #h < 6 then return nil end
    local function v(i) return (tonumber(h:sub(i, i + 1), 16) or 255) / 255 end
    return { r = v(1), g = v(3), b = v(5), a = (#h >= 8 and v(7) or 1) }
end
local function SanitizeField(s) return (tostring(s or ""):gsub("[:;|\r\n]", "")) end

-- items de la liste pour un onglet : en-têtes de catégorie + effets
local function BuildListItems(tabId)
    local items = {}
    local catalog = TSB.GetEffectCatalog and TSB.GetEffectCatalog()
    if not catalog then return items end
    local byKey = {}
    for _, cat in ipairs(catalog.categories) do byKey[cat.key] = cat end
    local group
    for _, g in ipairs(TAB_GROUPS) do if g.id == tabId then group = g end end
    if not group then return items end

    -- onglet ACTIFS : uniquement les trackers activés, regroupés par catégorie
    if group.activesOnly then
        for _, cat in ipairs(catalog.categories) do
            local actives = {}
            for _, e in ipairs(cat.entries) do
                if EffEnabled(e.key) then actives[#actives + 1] = e.key end
            end
            if #actives > 0 then
                items[#items + 1] = { header = true, name = cat.name }
                for _, k in ipairs(actives) do items[#items + 1] = { key = k } end
            end
        end
        if #items == 0 then items[#items + 1] = { header = true, name = "Aucun tracker actif" } end
        return items
    end

    for _, catKey in ipairs(group.cats) do
        local cat = byKey[catKey]
        if cat and #cat.entries > 0 then
            items[#items + 1] = { header = true, name = cat.name }
            for _, e in ipairs(cat.entries) do items[#items + 1] = { key = e.key } end
        end
    end
    return items
end

local function FirstEffectKey(items)
    for _, it in ipairs(items or {}) do if it.key then return it.key end end
end

-- ---------------------------------------------------------------------
--  Liste paginée (molette), groupée par catégorie
-- ---------------------------------------------------------------------
local function BindRows(list)
    for i = 1, VISIBLE_ROWS do
        local row, item = list.rows[i], list.items[list.offset + i]
        if not item then
            row.key = nil; row:SetHidden(true)
        elseif item.header then
            -- ligne d'en-tête de catégorie : non sélectionnable
            row.key = nil; row:SetHidden(false)
            row.bg:SetCenterColor(0, 0, 0, 0); row.bg:SetEdgeColor(0, 0, 0, 0)
            row.badge:SetHidden(true); row.badgeText:SetText("")
            row.name:SetFont(FONT_SMALL); row.name:SetColor(unpack4(C.cyan)); row.name:SetText(string.upper(item.name or ""))
        else
            local key = item.key
            row.key = key; row:SetHidden(false)
            row.badge:SetHidden(false)
            local c = EffColor(key)
            row.badge:SetCenterColor(c.r or 1, c.g or 1, c.b or 1, 1)
            row.badgeText:SetText(EffShort(key))
            row.name:SetFont(FONT_LABEL)
            -- gris si désactivé, clair si actif
            row.name:SetColor(unpack4(EffEnabled(key) and C.text or C.textDim))
            row.name:SetText(EffName(key))
            local sel = (key == currentKey)
            row.bg:SetCenterColor(sel and C.cardEdge[1] or C.card[1], sel and C.cardEdge[2] or C.card[2], sel and C.cardEdge[3] or C.card[3], 1)
            row.bg:SetEdgeColor(unpack4(sel and C.gold or C.cardEdge))
        end
    end
end

local function BuildTrackerList(parent)
    Label(parent, FONT_HEADER, C.cyan, "TRACKERS"):SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)
    parent.items, parent.offset, parent.rows = BuildListItems(activeTab), 0, {}
    for i = 1, VISIBLE_ROWS do
        local row = WM:CreateControl(nil, parent, CT_CONTROL)
        row:SetDimensions(280, 42); row:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 34 + (i - 1) * ROW_STEP); row:SetMouseEnabled(true)
        row.bg = Backdrop(row, C.card, C.cardEdge); row.bg:SetAnchorFill(row)
        row.badge = Backdrop(row, { 1, 1, 1, 1 }, C.cardEdge); row.badge:SetDimensions(30, 30); row.badge:SetAnchor(LEFT, row, LEFT, 10, 0)
        row.badgeText = Label(row, FONT_LABEL, { 1, 1, 1, 1 }, "", TEXT_ALIGN_CENTER); row.badgeText:SetAnchor(CENTER, row.badge, CENTER, 0, 0)
        row.name = Label(row, FONT_LABEL, C.text, ""); row.name:SetAnchor(LEFT, row.badge, RIGHT, 12, 0)
        row:SetHandler("OnMouseUp", function(_, _, upInside) if upInside and row.key then UI:SelectTracker(row.key) end end)
        row:SetHandler("OnMouseWheel", function(_, d) UI:ScrollList(d) end)
        parent.rows[i] = row
    end
    parent:SetMouseEnabled(true)
    parent:SetHandler("OnMouseWheel", function(_, d) UI:ScrollList(d) end)
    BindRows(parent)
end

function UI:ScrollList(delta)
    if not M or not M.list then return end
    local list = M.list
    list.offset = clamp(list.offset - (delta or 0), 0, zo_max(0, #list.items - VISIBLE_ROWS))
    BindRows(list)
end

function UI:RefreshList()
    if M and M.list then BindRows(M.list) end
end

-- reconstruit la liste (utile quand le contenu change : onglet ACTIFS, tout décocher, import)
function UI:RebuildList()
    if M and M.list then
        M.list.items = BuildListItems(activeTab)
        M.list.offset = clamp(M.list.offset, 0, zo_max(0, #M.list.items - VISIBLE_ROWS))
        BindRows(M.list)
    end
end

-- décoche TOUT (tous les trackers off)
function UI:ClearAll()
    local catalog = TSB.GetEffectCatalog and TSB.GetEffectCatalog()
    if catalog then
        for _, cat in ipairs(catalog.categories) do
            for _, e in ipairs(cat.entries) do EffectSettings(e.key).enabled = false end
        end
    end
    Apply()
    self:RebuildList()
    if TSB.Chat then TSB.Chat("tous les trackers ont été désactivés.") end
end

-- EXPORT : produit un code partageable (trackers actifs + couleur + acronyme)
function UI:ExportConfig()
    local catalog = TSB.GetEffectCatalog and TSB.GetEffectCatalog()
    if not catalog then return "" end
    local parts = { "TSB1" }
    for _, cat in ipairs(catalog.categories) do
        for _, e in ipairs(cat.entries) do
            local k = e.key
            if EffEnabled(k) then
                parts[#parts + 1] = string.format("%s:1:%s:%s", k, ColorToHex(EffColor(k)), SanitizeField(EffShort(k)))
            end
        end
    end
    return table.concat(parts, ";")
end

-- IMPORT : remet tout à off puis applique le code (enabled + couleur + acronyme)
function UI:ImportConfig(str)
    str = tostring(str or ""):gsub("%s+$", ""):gsub("^%s+", "")
    local recs = {}
    for token in string.gmatch(str, "[^;]+") do recs[#recs + 1] = token end
    if recs[1] ~= "TSB1" then
        if TSB.Chat then TSB.Chat("import : code non reconnu (doit commencer par TSB1).") end
        return false
    end
    local catalog = TSB.GetEffectCatalog and TSB.GetEffectCatalog()
    if catalog then
        for _, cat in ipairs(catalog.categories) do
            for _, e in ipairs(cat.entries) do EffectSettings(e.key).enabled = false end
        end
    end
    local n = 0
    for i = 2, #recs do
        local k, en, hex, short = string.match(recs[i], "^([^:]+):([^:]*):([^:]*):(.*)$")
        if not k then k, en = string.match(recs[i], "^([^:]+):([^:]*)") end
        if k and k ~= "" then
            local s = EffectSettings(k)
            s.enabled = (en == "1" or en == "true")
            if hex and hex ~= "" and hex ~= "-" then local c = HexToColor(hex); if c then s.color = c end end
            if short and short ~= "" and short ~= "-" then s.shortName = short end
            n = n + 1
        end
    end
    Apply()
    self:RebuildList()
    if TSB.Chat then TSB.Chat(string.format("import : %d trackers appliqués.", n)) end
    return true
end

function UI:SetTab(id)
    activeTab = id
    if M and M.share then M.share:SetHidden(true) end -- garde-fou : ferme le partage au changement d'onglet
    if M and M.list then
        M.list.items = BuildListItems(activeTab)
        M.list.offset = 0
        currentKey = FirstEffectKey(M.list.items)
        BindRows(M.list)
    end
    if M and M.tabs then
        for _, t in ipairs(M.tabs) do
            local on = (t.id == id)
            t.bg:SetCenterColor(on and 0.12 or 0.07, on and 0.16 or 0.08, on and 0.20 or 0.10, 1)
            t.bg:SetEdgeColor(unpack4(on and C.cyan or C.cardEdge))
            t.label:SetColor(unpack4(on and C.cyan or C.textDim))
        end
    end
    self:RefreshForm()
end


-- ---------------------------------------------------------------------
--  Formulaire (tout cablé sur de vrais champs lus par l'addon)
-- ---------------------------------------------------------------------
local function BuildTrackerForm(parent)
    parent.widgets = {}
    local function track(w) table.insert(parent.widgets, w); return w end

    Label(parent, FONT_HEADER, C.cyan, "BUFF TRACKER"):SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)

    -- ---- Carte 1 : tracker sélectionné (per-effet) ----
    local quick = MakeCard(parent, "TRACKER SÉLECTIONNÉ")
    quick:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 28); quick:SetDimensions(628, 128)
    local q = quick.content

    Label(q, FONT_SMALL, C.textDim, "Nom"):SetAnchor(TOPLEFT, q, TOPLEFT, 0, 0)
    track(MakeEditbox(q, 190, function() return currentKey and EffName(currentKey) or "" end,
        function(v) if currentKey then EffectSettings(currentKey).name = v end end)):SetAnchor(TOPLEFT, q, TOPLEFT, 0, 18)

    Label(q, FONT_SMALL, C.textDim, "Acronyme"):SetAnchor(TOPLEFT, q, TOPLEFT, 210, 0)
    track(MakeEditbox(q, 100, function() return currentKey and EffShort(currentKey) or "" end,
        function(v) if currentKey then EffectSettings(currentKey).shortName = v end end)):SetAnchor(TOPLEFT, q, TOPLEFT, 210, 18)

    Label(q, FONT_SMALL, C.textDim, "Activer"):SetAnchor(TOPLEFT, q, TOPLEFT, 330, 0)
    track(MakeToggle(q, function() return currentKey and EffEnabled(currentKey) end,
        function(v) if currentKey then EffectSettings(currentKey).enabled = v; Apply(); UI:RebuildList() end end)):SetAnchor(TOPLEFT, q, TOPLEFT, 330, 20)

    Label(q, FONT_SMALL, C.textDim, "Couleur de l'effet"):SetAnchor(TOPLEFT, q, TOPLEFT, 420, 0)
    track(MakeSwatch(q, function() return currentKey and EffColor(currentKey) end,
        function(r, g, b, a) if currentKey then EffectSettings(currentKey).color = { r = r, g = g, b = b, a = a }; Apply() end end)):SetAnchor(TOPLEFT, q, TOPLEFT, 420, 18)

    -- ligne de métadonnées (lecture seule) : cible / source / stacks / cooldown
    parent.metaLabel = Label(q, FONT_SMALL, C.textDim, "")
    parent.metaLabel:SetAnchor(TOPLEFT, q, TOPLEFT, 0, 56)
    parent.metaLabel:SetWidth(590)

    -- ---- Carte 2 : affichage global (tous les champs lus par l'addon) ----
    local disp = MakeCard(parent, "AFFICHAGE")
    disp:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 164); disp:SetDimensions(628, 380)
    local d = disp.content

    -- mini-helpers de placement
    local function subHeader(text, y) local h = Label(d, FONT_SMALL, C.cyan, text); h:SetAnchor(TOPLEFT, d, TOPLEFT, 0, y) end
    local function toggleAt(label, x, y, getF, setF)
        local t = track(MakeToggle(d, getF, setF)); t:SetAnchor(TOPLEFT, d, TOPLEFT, x, y)
        Label(d, FONT_SMALL, C.text, label):SetAnchor(LEFT, t, RIGHT, 6, 0)
    end
    local function swatchAt(label, x, y, getF, setF)
        Label(d, FONT_SMALL, C.textDim, label):SetAnchor(TOPLEFT, d, TOPLEFT, x, y)
        track(MakeSwatch(d, getF, setF)):SetAnchor(TOPLEFT, d, TOPLEFT, x, y + 16)
    end
    local function sliderAt(label, x, y, w, minV, maxV, step, key, suffix)
        Label(d, FONT_SMALL, C.textDim, label):SetAnchor(TOPLEFT, d, TOPLEFT, x, y)
        track(MakeSlider(d, w, minV, maxV, step,
            function() return tonumber(Saved()[key]) or minV end,
            function(v) Saved()[key] = v; Apply() end, suffix)):SetAnchor(TOPLEFT, d, TOPLEFT, x, y + 18)
    end

    -- Éléments visibles (showNames / showTimers / showBar / showAcronyms)
    subHeader("Éléments", 0)
    toggleAt("Noms", 0, 20, function() return Saved().showNames ~= false end, function(v) Saved().showNames = v; Apply() end)
    toggleAt("Timers", 150, 20, function() return Saved().showTimers ~= false end, function(v) Saved().showTimers = v; Apply() end)
    toggleAt("Jauge", 300, 20, function() return Saved().showBar ~= false end, function(v) Saved().showBar = v; Apply() end)
    toggleAt("Acronyme", 450, 20, function() return Saved().showAcronyms ~= false end, function(v) Saved().showAcronyms = v; Apply() end)

    -- Fenêtre (unlocked / borderEnabled / layout)
    subHeader("Fenêtre", 56)
    toggleAt("Déverrouiller", 0, 76, function() return Saved().unlocked == true end, function(v) Saved().unlocked = v; Apply() end)
    toggleAt("Bordure", 200, 76, function() return Saved().borderEnabled ~= false end, function(v) Saved().borderEnabled = v; Apply() end)
    Label(d, FONT_SMALL, C.textDim, "Disposition"):SetAnchor(TOPLEFT, d, TOPLEFT, 380, 56)
    track(MakeSegmented(d, { "Combinée", "Séparée", "Indiv." },
        function()
            local l = TSB.NormalizeLayout and TSB.NormalizeLayout(Saved().layout) or Saved().layout
            return (l == "separate" and 2) or (l == "individual" and 3) or 1
        end,
        function(i) Saved().layout = ({ "combined", "separate", "individual" })[i]; Apply() end)):SetAnchor(TOPLEFT, d, TOPLEFT, 380, 74)

    -- Couleurs (nameTextColor / timerTextColor / acronymTextColor / frameColor / borderColor)
    subHeader("Couleurs", 112)
    swatchAt("Texte", 0, 132, function() return Saved().nameTextColor end,
        function(r, g, b, a) Saved().nameTextColor = { r = r, g = g, b = b, a = a }; Apply() end)
    swatchAt("Timer", 120, 132, function() return Saved().timerTextColor end,
        function(r, g, b, a) Saved().timerTextColor = { r = r, g = g, b = b, a = a }; Apply() end)
    swatchAt("Acronyme", 240, 132, function() return Saved().acronymTextColor end,
        function(r, g, b, a) Saved().acronymTextColor = { r = r, g = g, b = b, a = a }; Apply() end)
    swatchAt("Fond fenêtre", 360, 132, function() return Saved().frameColor end,
        function(r, g, b) Saved().frameColor = { r = r, g = g, b = b }; Apply() end)
    swatchAt("Bordure", 500, 132, function() local c = Saved().borderColor or {}; return { r = c.r, g = c.g, b = c.b, a = Saved().borderAlpha } end,
        function(r, g, b) Saved().borderColor = { r = r, g = g, b = b }; Apply() end)

    -- Réglages chiffrés (borderThickness / circleSize / timerTextScale / scale / *Alpha)
    subHeader("Tailles & transparences", 178)
    sliderAt("Épaisseur bord", 0, 198, 185, 2, 6, 1, "borderThickness")
    sliderAt("Taille cellule", 210, 198, 185, 20, 72, 1, "circleSize")
    sliderAt("Échelle timer", 420, 198, 175, 0.5, 3, 0.05, "timerTextScale")
    sliderAt("Zoom global", 0, 240, 185, 0.6, 1.8, 0.05, "scale")
    sliderAt("Transp. fond", 210, 240, 185, 0, 1, 0.05, "frameAlpha")
    sliderAt("Transp. texte", 420, 240, 175, 0, 1, 0.05, "textAlpha")
    sliderAt("Transp. carré", 0, 282, 185, 0, 1, 0.05, "badgeAlpha")
    sliderAt("Transp. jauge", 210, 282, 185, 0, 1, 0.05, "barAlpha")
end

-- ---------------------------------------------------------------------
--  Refresh / sélection
-- ---------------------------------------------------------------------
function UI:RefreshForm()
    local f = M and M.form
    if not f or not f.widgets then return end
    for _, w in ipairs(f.widgets) do if w.Redraw then w.Redraw() end end
    -- ligne méta : cible / source / stacks / cooldown
    if f.metaLabel then
        if not currentKey then
            f.metaLabel:SetText("")
        else
            local e = EffectDef(currentKey)
            local parts = {}
            parts[#parts + 1] = "Cible : " .. ((e.targetType == "target") and "Cible" or "Soi")
            if e.maxStacks then parts[#parts + 1] = "Stacks : " .. tostring(e.maxStacks) end
            if e.cooldown then parts[#parts + 1] = "CD : " .. tostring(e.cooldown) .. "s" end
            if e.source then parts[#parts + 1] = "Source : " .. tostring(e.source) end
            f.metaLabel:SetText(table.concat(parts, "   •   "))
        end
    end
end

function UI:SelectTracker(key)
    currentKey = key
    if M and M.list then BindRows(M.list) end
    self:RefreshForm()
end

-- ---------------------------------------------------------------------
--  Mode test (aperçu de l'addon)
-- ---------------------------------------------------------------------
function UI:UpdateTestButton()
    if not M or not M.btnTest then return end
    M.btnTest.bg:SetCenterColor(testMode and C.blue[1] or C.card[1], testMode and C.blue[2] or C.card[2], testMode and C.blue[3] or C.card[3], 1)
end
function UI:SetTest(on)
    testMode = on == true
    if Saved().previewEnabled == false then Saved().previewEnabled = true end
    TSB.settingsPanelOpen = testMode
    self:UpdateTestButton(); Apply()
end
function UI:ToggleTest() self:SetTest(not testMode) end

-- ---------------------------------------------------------------------
--  Fenêtre
-- ---------------------------------------------------------------------
local BuildShareOverlay -- défini plus bas, utilisé dans BuildWindow
local function BuildWindow()
    if M then return M end
    M = WM:CreateTopLevelWindow(NAME)
    M:SetDimensions(980, 700); M:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    M:SetMovable(true); M:SetMouseEnabled(true); M:SetClampedToScreen(true); M:SetHidden(true)
    M.bg = Backdrop(M, C.panel, C.gold); M.bg:SetAnchorFill(M)

    M.titleBar = WM:CreateControl(nil, M, CT_CONTROL)
    M.titleBar:SetAnchor(TOPLEFT, M, TOPLEFT, 0, 0); M.titleBar:SetAnchor(TOPRIGHT, M, TOPRIGHT, 0, 0); M.titleBar:SetHeight(50); M.titleBar:SetMouseEnabled(true)
    M.titleBar:SetHandler("OnMouseDown", function() M:StartMoving() end)
    M.titleBar:SetHandler("OnMouseUp", function() M:StopMovingOrResizing() end)

    M.title = Label(M, FONT_TITLE, C.cyan, "TEAM SHADOWS MANAGER", TEXT_ALIGN_CENTER)
    M.title:SetAnchor(TOP, M, TOP, 0, 12); M.title:SetWidth(980)
    M.close = FlatButton(M, "X", 30, 30, function() UI:Hide() end, C.panel, C.gold)
    M.close:SetAnchor(TOPRIGHT, M, TOPRIGHT, -14, 12)

    -- barre d'onglets (3)
    M.tabs = {}
    local tabW = 224
    for i, g in ipairs(TAB_GROUPS) do
        local t = WM:CreateControl(nil, M, CT_CONTROL)
        t:SetDimensions(tabW, 32); t:SetAnchor(TOPLEFT, M, TOPLEFT, 24 + (i - 1) * (tabW + 8), 52); t:SetMouseEnabled(true)
        t.bg = Backdrop(t, { 0.07, 0.08, 0.10, 1 }, C.cardEdge); t.bg:SetAnchorFill(t)
        t.label = Label(t, FONT_LABEL, C.textDim, g.label, TEXT_ALIGN_CENTER); t.label:SetAnchor(CENTER, t, CENTER, 0, 0)
        t.id = g.id
        t:SetHandler("OnMouseUp", function(_, _, upInside) if upInside then UI:SetTab(g.id) end end)
        M.tabs[i] = t
    end

    M.list = WM:CreateControl(nil, M, CT_CONTROL)
    M.list:SetAnchor(TOPLEFT, M, TOPLEFT, 24, 94); M.list:SetDimensions(280, 548)
    BuildTrackerList(M.list)

    M.form = WM:CreateControl(nil, M, CT_CONTROL)
    M.form:SetAnchor(TOPLEFT, M, TOPLEFT, 328, 94); M.form:SetDimensions(628, 548)
    BuildTrackerForm(M.form)

    -- footer : MODE TEST | TOUT DÉCOCHER | PARTAGE (gauche), SAUVEGARDER + RESET (droite)
    M.btnTest = FlatButton(M, "MODE TEST", 140, 36, function() UI:ToggleTest() end)
    M.btnTest:SetAnchor(BOTTOMLEFT, M, BOTTOMLEFT, 24, -16)
    M.btnTest:SetHandler("OnMouseExit", function()
        M.btnTest.bg:SetCenterColor(testMode and C.blue[1] or C.card[1], testMode and C.blue[2] or C.card[2], testMode and C.blue[3] or C.card[3], 1)
    end)

    M.btnClear = FlatButton(M, "TOUT DÉCOCHER", 160, 36, function() UI:ClearAll() end, { 0.30, 0.12, 0.12, 1 }, C.text)
    M.btnClear:SetAnchor(LEFT, M.btnTest, RIGHT, 10, 0)

    M.btnShare = FlatButton(M, "PARTAGE", 120, 36, function() UI:ToggleShare() end)
    M.btnShare:SetAnchor(LEFT, M.btnClear, RIGHT, 10, 0)

    M.btnSave = FlatButton(M, "SAUVEGARDER", 150, 36, function() Apply(); if TSB.Chat then TSB.Chat("Réglages appliqués.") end end, { 0.12, 0.30, 0.55, 1 }, C.text)
    M.btnSave:SetAnchor(BOTTOMRIGHT, M, BOTTOMRIGHT, -160, -16)
    M.btnReset = FlatButton(M, "RESET", 130, 36, function()
        if currentKey and TSB.ResetEffectSettings then TSB.ResetEffectSettings(currentKey) end
        UI:RefreshForm(); Apply()
    end)
    M.btnReset:SetAnchor(LEFT, M.btnSave, RIGHT, 10, 0)

    BuildShareOverlay()

    UI:UpdateTestButton()
    return M
end

-- ---------------------------------------------------------------------
--  Overlay de partage (import / export de config)
-- ---------------------------------------------------------------------
function BuildShareOverlay()
    -- fenêtre indépendante (TLW) : flotte au-dessus du manager et capte les clics,
    -- au lieu d'être un enfant qui se bat avec les contrôles voisins pour l'ordre de dessin.
    local s = WM:CreateTopLevelWindow(NAME .. "Share")
    s:SetDimensions(660, 250); s:SetAnchor(CENTER, M, CENTER, 0, 0)
    s:SetMouseEnabled(true); s:SetHidden(true); s:SetClampedToScreen(true)
    if s.SetDrawTier and DT_HIGH then s:SetDrawTier(DT_HIGH) end
    s.bg = Backdrop(s, C.panel, C.gold); s.bg:SetAnchorFill(s)
    M.share = s

    Label(s, FONT_HEADER, C.cyan, "PARTAGE DE CONFIG", TEXT_ALIGN_CENTER):SetAnchor(TOP, s, TOP, 0, 16)
    local info = Label(s, FONT_SMALL, C.textDim,
        "Exporter : remplit le champ -> clique dedans, Ctrl+A puis Ctrl+C.\nImporter : clique dans le champ, Ctrl+V pour coller un code, puis Importer.")
    info:SetAnchor(TOP, s, TOP, 0, 44); info:SetHorizontalAlignment(TEXT_ALIGN_CENTER); info:SetWidth(620)

    -- champ de texte (le code partagé)
    local box = WM:CreateControl(nil, s, CT_CONTROL)
    box:SetDimensions(620, 70); box:SetAnchor(TOP, s, TOP, 0, 92); box:SetMouseEnabled(true)
    box.bg = Backdrop(box, { 0.04, 0.05, 0.07, 1 }, C.cardEdge); box.bg:SetAnchorFill(box)
    local edit = WM:CreateControl(nil, box, CT_EDITBOX)
    edit:SetAnchor(TOPLEFT, box, TOPLEFT, 8, 6); edit:SetAnchor(BOTTOMRIGHT, box, BOTTOMRIGHT, -8, -6)
    edit:SetFont(FONT_SMALL); edit:SetColor(unpack4(C.text))
    edit:SetMaxInputChars(6000); edit:SetMouseEnabled(true); edit:SetEditEnabled(true)
    if edit.SetMultiLine then edit:SetMultiLine(true) end
    local function focus() edit:TakeFocus() end
    edit:SetHandler("OnMouseUp", focus); box:SetHandler("OnMouseUp", focus)
    edit:SetHandler("OnEscape", function(self) self:LoseFocus() end)
    M.shareEdit = edit

    -- boutons
    local bExp = FlatButton(s, "EXPORTER", 150, 34, function()
        edit:SetText(UI:ExportConfig()); edit:TakeFocus(); if edit.SelectAll then edit:SelectAll() end
    end, { 0.12, 0.30, 0.55, 1 }, C.text)
    bExp:SetAnchor(BOTTOMLEFT, s, BOTTOMLEFT, 30, -20)

    local bImp = FlatButton(s, "IMPORTER", 150, 34, function()
        UI:ImportConfig(edit:GetText()); UI:RefreshForm()
    end, { 0.12, 0.40, 0.20, 1 }, C.text)
    bImp:SetAnchor(LEFT, bExp, RIGHT, 12, 0)

    local bClose = FlatButton(s, "FERMER", 130, 34, function() s:SetHidden(true) end)
    bClose:SetAnchor(BOTTOMRIGHT, s, BOTTOMRIGHT, -30, -20)
end

function UI:ToggleShare()
    if not M or not M.share then return end
    local willShow = M.share:IsHidden()
    M.share:SetHidden(not willShow)
    if willShow and M.shareEdit then
        -- à l'ouverture, on pré-remplit avec la config actuelle (prête à copier)
        M.shareEdit:SetText(self:ExportConfig())
    end
end

-- ---------------------------------------------------------------------
--  API publique
-- ---------------------------------------------------------------------
function UI:Show()
    BuildWindow(); M:SetHidden(false)
    self:SetTab(activeTab)  -- (re)construit la liste de l'onglet + sélectionne le 1er effet
    self:UpdateTestButton(); self:RefreshForm()
end
function UI:Hide()
    if M then M:SetHidden(true) end
    if M and M.share then M.share:SetHidden(true) end
    if testMode then self:SetTest(false) end
end
function UI:Toggle() if M and not M:IsHidden() then self:Hide() else self:Show() end end

TSB.Manager = UI
function TSB.OpenManager() UI:Show() end
SLASH_COMMANDS["/tsbui"] = function() UI:Toggle() end
