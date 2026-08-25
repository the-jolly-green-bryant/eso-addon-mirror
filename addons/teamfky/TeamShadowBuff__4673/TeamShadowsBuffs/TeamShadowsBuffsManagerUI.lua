-- =====================================================================
--  Team Shadows Manager - UI custom (1 onglet, tout cablé sur l'addon)
-- ---------------------------------------------------------------------
--  Chaque contrôle pointe sur un vrai champ savedVars / une vraie
--  fonction de l'addon. Pas de stub, pas de champ ignoré.
--
--  Charger : ajouter dans TeamShadowsBuffs.txt
--      TeamShadowsBuffsManagerUI.lua
--  puis /reloadui. Ouvrir : /tsb
-- =====================================================================

TeamShadowsBuffs = TeamShadowsBuffs or {}
local TSB = TeamShadowsBuffs
local WM = WINDOW_MANAGER

local C = {
    panel = { 0.012, 0.018, 0.028, 0.985 }, card = { 0.026, 0.036, 0.050, 0.97 },
    cardEdge = { 0.43, 0.34, 0.20, 1.0 }, gold = { 0.83, 0.68, 0.40, 1.0 },
    cyan = { 0.27, 0.78, 1.0, 1.0 }, blue = { 0.18, 0.50, 0.93, 1.0 },
    text = { 0.91, 0.91, 0.88, 1.0 }, textDim = { 0.64, 0.61, 0.55, 1.0 },
    track = { 0.10, 0.12, 0.15, 1.0 },
}
local FONT_TITLE, FONT_HEADER = "ZoFontWinH2", "ZoFontWinH4"
local FONT_H3 = "ZoFontWinH3"
local FONT_LABEL, FONT_SMALL = "ZoFontGameBold", "ZoFontGameSmall"
local SETTINGS_ICON = "/esoui/art/skillsadvisor/advisor_tabicon_settings_up.dds"
local SETTINGS_ICON_OVER = "/esoui/art/skillsadvisor/advisor_tabicon_settings_over.dds"
local ADDON_ICON = "TeamShadowsBuffs/icons/team_shadows_buffs.dds"
local SEARCH_ICON = "/esoui/art/miscellaneous/search_icon.dds"
local DIVIDER_TEXTURE = "/esoui/art/miscellaneous/horizontaldivider.dds"
local ICON_MISSING = "/esoui/art/icons/icon_missing.dds"

-- Zébrage / survol des lignes de liste (plus de bordure par ligne :
-- la bordure cyan est réservée à la sélection)
local ZEBRA_A = { 0.030, 0.040, 0.054, 1 }
local ZEBRA_B = { 0.020, 0.028, 0.040, 1 }
local HOVER_BG = { 0.055, 0.085, 0.110, 1 }
local HEADER_BG = { 0.012, 0.018, 0.026, 1 }
local ACTIVE_GREEN = { 0.20, 0.82, 0.40, 1 }

TSB.translations = TSB.translations or {}
TSB.translations.launcher = TSB.translations.launcher or {
    fr = { hide = "MASQUER ICÔNE", show = "VOIR ICÔNE" },
    en = { hide = "HIDE ICON", show = "SHOW ICON" },
}

local NAME = "TeamShadowsBuffsManager"
local UI = {}
local M, launcher, currentKey, currentDestination, currentPanel, testMode = nil, nil, nil, nil, nil, false
local RefreshLauncherButton
local activeTab = "library"
local VISIBLE_ROWS, ROW_STEP = 11, 50
-- géométrie de la liste selon l'onglet : large en bibliothèque (lisibilité),
-- étroite dans MES TRACKERS (le formulaire de personnalisation prend la place).
local LIST_X_DEFAULT, LIST_W_DEFAULT = 24, 280
local LIST_X_LIBRARY, LIST_W_LIBRARY = 206, 400

-- Filtres de la bibliothèque : regroupements lisibles côté utilisateur
-- (et non côté technique). L'ordre des cats fixe l'ordre d'affichage.
local LIBRARY_FILTERS = {
    { id = "all", label = "Tous" },
    { id = "buffs", label = "Buffs et débuffs", cats = { "major_buffs", "boss_debuffs", "support_debuffs" } },
    { id = "sets", label = "Sets", cats = { "set_stacks", "set_procs", "monster_sets", "dungeon_proc_sets", "overland_crafted_pvp_procs", "trial_proc_sets", "mythic_stacks" } },
    { id = "skills", label = "Compétences", cats = { "class_masteries", "skill_stacks", "skill_procs" } },
    { id = "status", label = "Effets de statut", cats = { "status_effects" } },
}
local libraryFilter = "all"

-- Couleur d'identité par groupe : sidebar, en-têtes de catégories, fiche.
local GROUP_COLORS = {
    all = { 0.27, 0.78, 1.00, 1 },    -- cyan
    buffs = { 0.30, 0.62, 0.98, 1 },  -- bleu
    sets = { 0.90, 0.72, 0.30, 1 },   -- or
    skills = { 0.64, 0.44, 0.95, 1 }, -- violet
    status = { 0.95, 0.55, 0.22, 1 }, -- orange
}

local LIBRARY_ALL_CATS = {}
local CAT_TO_GROUP = {}
for _, filter in ipairs(LIBRARY_FILTERS) do
    for _, catKey in ipairs(filter.cats or {}) do
        LIBRARY_ALL_CATS[#LIBRARY_ALL_CATS + 1] = catKey
        CAT_TO_GROUP[catKey] = filter.id
    end
end

-- 3 onglets : BIBLIOTHÈQUE = tout ce qui est traquable (activation uniquement),
-- MES TRACKERS = personnalisation des trackers actifs, STATS COMBAT.
local TAB_GROUPS = {
    { id = "library", label = "BIBLIOTHÈQUE", libraryTab = true, cats = LIBRARY_ALL_CATS },
    { id = "actifs", label = "MES TRACKERS", activesOnly = true },
    { id = "stats", label = "STATS DE COMBAT", statsOnly = true },
}

-- ---------------------------------------------------------------------
--  Helpers
-- ---------------------------------------------------------------------
local function unpack4(c) return c[1], c[2], c[3], c[4] end
local function Saved() return TSB.savedVars or {} end
local function clamp(v, lo, hi) if v < lo then return lo elseif v > hi then return hi else return v end end
local EffectSettings

local function OpenContactMail(recipient)
    if not SCENE_MANAGER then return end
    SCENE_MANAGER:Show("mailSend")
    zo_callLater(function()
        if ZO_MailSendToField then ZO_MailSendToField:SetText(recipient or "@TeamFF") end
        if ZO_MailSendSubjectField then ZO_MailSendSubjectField:SetText("Team Shadows Buffs") end
        if ZO_MailSendBodyField then
            ZO_MailSendBodyField:SetText("")
            ZO_MailSendBodyField:TakeFocus()
        end
    end, 200)
end

local PANEL_STYLE_KEYS = {
    "scale", "circleSize", "frameColor", "frameAlpha", "borderEnabled", "borderColor", "borderAlpha",
    "borderThickness", "nameTextColor", "timerTextColor", "acronymTextColor", "badgeAlpha", "barAlpha",
    "textAlpha", "timerTextScale", "showNames", "showTimers", "showAcronyms", "showStacks", "showBar", "unlocked",
    "stackTextColor", "compact", "timerNoDecimals", "compactTimerPosition",
}

local function CopySetting(value)
    if type(value) ~= "table" then return value end
    local copy = {}
    for key, child in pairs(value) do copy[key] = CopySetting(child) end
    return copy
end

local function EnsurePanelAppearance(panelKey)
    local saved = Saved()
    saved.panelSettings = saved.panelSettings or {}
    if not saved.panelSettings[panelKey] then
        local settings = {}
        for _, key in ipairs(PANEL_STYLE_KEYS) do settings[key] = CopySetting(saved[key]) end
        saved.panelSettings[panelKey] = settings
    end
    return saved.panelSettings[panelKey]
end

local function AppearanceSettings()
    if currentPanel then return EnsurePanelAppearance(currentPanel) end
    if currentDestination and currentDestination:match("^panel[1-4]$") then
        return EnsurePanelAppearance(currentDestination)
    end
    if currentDestination == "group" and currentKey then
        local settings = EffectSettings(currentKey)
        if not settings.groupAppearanceInitialized then
            for _, key in ipairs(PANEL_STYLE_KEYS) do
                if settings[key] == nil then settings[key] = CopySetting(Saved()[key]) end
            end
            settings.groupAppearanceInitialized = true
        end
        return settings
    end
    return Saved()
end

local function Apply()
    if TSB.UI and TSB.UI.ApplySettings then
        if TSB.SafeCall then TSB.SafeCall("UI", "ApplySettings", TSB.UI.ApplySettings, TSB.UI)
        else TSB.UI:ApplySettings() end
    end
    local stats = TSB.modules and TSB.modules.CombatStats
    if stats and stats.Refresh then
        if TSB.SafeCall then TSB.SafeCall("CombatStats", "Refresh", stats.Refresh, stats)
        else stats:Refresh() end
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
    btn:SetHandler("OnMouseEnter", function()
        btn.bg:SetCenterColor(0.07, 0.11, 0.14, 1)
        btn.bg:SetEdgeColor(unpack4(C.cyan))
    end)
    btn:SetHandler("OnMouseExit", function()
        btn.bg:SetCenterColor(unpack4(bgColor or C.card))
        btn.bg:SetEdgeColor(unpack4(C.cardEdge))
    end)
    btn:SetHandler("OnMouseUp", function(_, _, upInside) if upInside and onClick then onClick() end end)
    return btn
end

-- ---------------------------------------------------------------------
--  Widgets réutilisables
-- ---------------------------------------------------------------------
local function MakeCard(parent, title)
    local card = WM:CreateControl(nil, parent, CT_CONTROL)
    card.bg = Backdrop(card, C.card, C.cardEdge); card.bg:SetAnchorFill(card)
    card.title = Label(card, FONT_HEADER, C.gold, title, TEXT_ALIGN_CENTER)
    card.title:SetAnchor(TOPLEFT, card, TOPLEFT, 18, 10)
    card.title:SetAnchor(TOPRIGHT, card, TOPRIGHT, -18, 10)
    card.separator = Backdrop(card, C.gold)
    card.separator:SetAnchor(TOPLEFT, card, TOPLEFT, 18, 36)
    card.separator:SetAnchor(TOPRIGHT, card, TOPRIGHT, -18, 36)
    card.separator:SetHeight(1)
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
    tg:SetHandler("OnMouseUp", function(_, _, upInside) if upInside then setFunc(getFunc() ~= true, tg); redraw() end end)
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
            cell.bg:SetCenterColor(active and 0.04 or C.card[1], active and 0.07 or C.card[2], active and 0.09 or C.card[3], 1)
            cell.bg:SetEdgeColor(unpack4(active and C.cyan or C.cardEdge))
            cell.label:SetColor(unpack4(active and C.cyan or C.textDim))
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
        UI:RefreshForm()
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
EffectSettings = function(k) return TSB.GetEffectSettings and TSB.GetEffectSettings(k) or {} end
local function EffectDef(k) return TSB.GetMajorEffectByKey and TSB.GetMajorEffectByKey(k) or {} end
local function EffName(k)
    local s, e = EffectSettings(k), EffectDef(k)
    if s.name and s.name ~= "" and s.name ~= e.fallbackName then return s.name end
    if Saved().catalogLanguage == "en" and e.nameEn and e.nameEn ~= "" then return e.nameEn end
    if Saved().catalogLanguage ~= "en" and e.nameFr and e.nameFr ~= "" then return e.nameFr end
    local names = Saved().catalogNamesByLanguage
    if Saved().catalogLanguage == "en" and names and names.en and names.en[k] then return names.en[k] end
    if Saved().catalogLanguage ~= "en" and e.fallbackName and e.fallbackName ~= "" then return e.fallbackName end
    return e.name or k
end
local function CategoryName(category)
    if Saved().catalogLanguage == "en" and category.nameEn and category.nameEn ~= "" then
        return category.nameEn
    end
    return category.name
end
local function EffShort(k) local s = EffectSettings(k); return (s.shortName and s.shortName ~= "" and s.shortName) or EffectDef(k).shortName or "?" end
local function EffColor(k) local s = EffectSettings(k); return s.color or EffectDef(k).color or { r = 1, g = 1, b = 1, a = 1 } end
-- icône officielle du jeu pour un effet (première trouvée parmi ses ids), mise en cache
local function EffIcon(k)
    local e = EffectDef(k)
    if e._iconResolved ~= nil then
        return e._iconResolved or nil
    end
    local icon = e.icon
    if (not icon or icon == "") and GetAbilityIcon then
        for _, abilityId in ipairs(e.ids or {}) do
            local candidate = GetAbilityIcon(abilityId)
            if candidate and candidate ~= "" and candidate ~= ICON_MISSING then
                icon = candidate
                break
            end
        end
    end
    if icon == "" then icon = nil end
    e._iconResolved = icon or false
    return icon
end
local function GroupColorForCategory(catKey)
    local groupId = catKey and CAT_TO_GROUP[catKey]
    return (groupId and GROUP_COLORS[groupId]) or C.cyan
end
local function EffEnabled(k)
    local s = EffectSettings(k)
    if TSB.AnyTrackerDestinationConfigured and TSB.AnyTrackerDestinationConfigured(k) then
        return TSB.AnyTrackerDestinationEnabled(k)
    end
    if s.enabled ~= nil then return s.enabled end
    if TSB.IsEffectEnabledByKey then return TSB.IsEffectEnabledByKey(k) end
    return false
end

local DESTINATION_ORDER = {
    { key = "panel1", label = "Panel 1 = P1" },
    { key = "panel2", label = "Panel 2 = P2" },
    { key = "panel3", label = "Panel 3 = P3" },
    { key = "panel4", label = "Panel 4 = P4" },
    { key = "free1", label = "Tracker libre 1 = L1" },
    { key = "free2", label = "Tracker libre 2 = L2" },
    { key = "free3", label = "Tracker libre 3 = L3" },
    { key = "free4", label = "Tracker libre 4 = L4" },
    { key = "free5", label = "Tracker libre 5 = L5" },
    { key = "free6", label = "Tracker libre 6 = L6" },
    { key = "free7", label = "Tracker libre 7 = L7" },
    { key = "free8", label = "Tracker libre 8 = L8" },
    { key = "free9", label = "Tracker libre 9 = L9" },
    { key = "free10", label = "Tracker libre 10 = L10" },
    { key = "head", label = "Tracker de tête" },
    { key = "group", label = "Trackers de groupe" },
}
local function ConfiguredDestinations(k, includeDisabled)
    if TSB.GetTrackerDestinations then return TSB.GetTrackerDestinations(k, includeDisabled) end
    local destination = k and EffectSettings(k).destination
    return destination and { destination } or {}
end
local function DestinationConfigured(k, destination)
    if TSB.IsTrackerDestinationConfigured then return TSB.IsTrackerDestinationConfigured(k, destination) end
    return k and EffectSettings(k).destination == destination
end
local function DestinationEnabled(k, destination)
    if TSB.IsTrackerDestinationEnabled then return TSB.IsTrackerDestinationEnabled(k, destination) end
    return DestinationConfigured(k, destination) and EffEnabled(k)
end

local function FirstFreeTrackerDestination(exceptKey)
    local used = {}
    local catalog = TSB.GetEffectCatalog and TSB.GetEffectCatalog()
    if catalog then
        for _, category in ipairs(catalog.categories) do
            for _, effect in ipairs(category.entries) do
                for _, destination in ipairs(ConfiguredDestinations(effect.key, true)) do
                    if destination:match("^free%d+$") then used[destination] = true end
                end
            end
        end
    end
    for i = 1, 10 do
        local destination = "free" .. i
        if not used[destination] then return destination end
    end
    return nil
end

local function ActivateIn(destination)
    if not currentKey then return end
    if TSB.AddTrackerDestination then TSB.AddTrackerDestination(currentKey, destination)
    else
        local settings = EffectSettings(currentKey)
        settings.destination = destination
        settings.enabled = true
    end
    Apply()
    UI:RebuildList()
    UI:RefreshForm()
end

local function ShowActivationMenu(anchor)
    if not currentKey then return end
    ClearMenu()
    for i = 1, 4 do
        local destination = "panel" .. i
        AddCustomMenuItem("Panel " .. i, function() ActivateIn(destination) end)
    end
    AddCustomMenuItem("Tracker unique", function()
        local destination = FirstFreeTrackerDestination(currentKey)
        if destination then
            ActivateIn(destination)
        elseif TSB.Chat then
            TSB.Chat("aucun emplacement de tracker individuel disponible.")
        end
    end)
    AddCustomMenuItem("Tracker tête", function() ActivateIn("head") end)
    AddCustomMenuItem("Tracker de groupe", function() ActivateIn("group") end)
    ShowMenu(anchor)
end

local function MakeActivationButton(parent)
    local button
    button = FlatButton(parent, "ACTIVER", 96, 26, function()
        if not currentKey then return end
        if activeTab == "actifs" and currentDestination then
            local enabled = DestinationEnabled(currentKey, currentDestination)
            if TSB.SetTrackerDestinationEnabled then
                TSB.SetTrackerDestinationEnabled(currentKey, currentDestination, not enabled)
            else
                EffectSettings(currentKey).enabled = not enabled
            end
            Apply()
            UI:RebuildList()
            UI:RefreshForm()
        else
            ShowActivationMenu(button)
        end
    end, { 0.12, 0.30, 0.55, 1 }, C.text)
    button.Redraw = function()
        local configured = currentKey and TSB.AnyTrackerDestinationConfigured and TSB.AnyTrackerDestinationConfigured(currentKey)
        local active = currentKey and currentDestination and DestinationEnabled(currentKey, currentDestination)
        if activeTab == "actifs" and currentDestination then
            button.label:SetText(active and "DÉSACTIVER" or "ACTIVER")
        else
            button.label:SetText(configured and "AJOUTER" or "ACTIVER")
        end
        button.bg:SetCenterColor(active and 0.42 or 0.12, active and 0.12 or 0.30, active and 0.12 or 0.55, 1)
    end
    button:SetHandler("OnMouseExit", function() button.Redraw() end)
    button.Redraw()
    return button
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
local function MatchesSearch(key, categoryName, query)
    query = tostring(query or ""):lower()
    if query == "" then return true end
    local e = EffectDef(key)
    local hay = table.concat({
        tostring(key or ""),
        tostring(categoryName or ""),
        tostring(EffName(key) or ""),
        tostring(e.name or ""),
        tostring(e.nameFr or ""),
        tostring(e.nameEn or ""),
        tostring(e.fallbackName or ""),
        tostring(EffShort(key) or ""),
    }, " "):lower()
    return hay:find(query, 1, true) ~= nil
end

local function AddOrderedKeys(result, seen, wanted, orderText)
    for key in tostring(orderText or ""):gmatch("[^,%s]+") do
        if wanted[key] and not seen[key] then
            result[#result + 1] = key
            seen[key] = true
        end
    end
end

local function OrderedDestinationKeys(destination, catalog, includeDisabled)
    local wanted, fallback = {}, {}
    for _, cat in ipairs((catalog and catalog.categories) or {}) do
        for _, effect in ipairs(cat.entries) do
            local key = effect.key
            if DestinationConfigured(key, destination) and (includeDisabled or DestinationEnabled(key, destination)) then
                wanted[key] = true
                fallback[#fallback + 1] = key
            end
        end
    end

    local result, seen = {}, {}
    local panelStyle = Saved().panelSettings and Saved().panelSettings[destination]
    AddOrderedKeys(result, seen, wanted, panelStyle and panelStyle.order)
    AddOrderedKeys(result, seen, wanted, Saved().playerOrder)
    AddOrderedKeys(result, seen, wanted, Saved().bossOrder)
    for _, key in ipairs(fallback) do
        if not seen[key] then result[#result + 1] = key; seen[key] = true end
    end
    return result
end

local function MovePanelTrackerOrder(key, destination, direction)
    if not key or not destination or not destination:match("^panel[1-4]$") then return false end
    local catalog = TSB.GetEffectCatalog and TSB.GetEffectCatalog()
    local ordered = OrderedDestinationKeys(destination, catalog, true)
    local index
    for i, effectKey in ipairs(ordered) do
        if effectKey == key then index = i break end
    end
    if not index then return false end
    local target = index + direction
    if target < 1 or target > #ordered then return false end
    ordered[index], ordered[target] = ordered[target], ordered[index]
    EnsurePanelAppearance(destination).order = table.concat(ordered, ",")
    return true
end

local function BuildListItems(tabId, query)
    local items = {}
    local catalog = TSB.GetEffectCatalog and TSB.GetEffectCatalog()
    if not catalog then return items end
    local byKey = {}
    for _, cat in ipairs(catalog.categories) do byKey[cat.key] = cat end
    local group
    for _, g in ipairs(TAB_GROUPS) do if g.id == tabId then group = g end end
    if not group then return items end
    if group.statsOnly then return items end

    -- onglet ACTIFS : uniquement les trackers activés, regroupés par catégorie
    if group.activesOnly then
        for _, dest in ipairs(DESTINATION_ORDER) do
            local activeInSlot = {}
            for _, key in ipairs(OrderedDestinationKeys(dest.key, catalog, true)) do
                if MatchesSearch(key, "", query) then
                    activeInSlot[#activeInSlot + 1] = key
                end
            end
            if #activeInSlot > 0 then
                items[#items + 1] = { header = true, name = dest.label, destination = dest.key, count = #activeInSlot }
                for _, k in ipairs(activeInSlot) do items[#items + 1] = { key = k, destination = dest.key } end
            end
        end

        local noSlot = {}
        for _, cat in ipairs(catalog.categories) do
            for _, e in ipairs(cat.entries) do
                if EffEnabled(e.key) and not TSB.AnyTrackerDestinationConfigured(e.key) and MatchesSearch(e.key, CategoryName(cat), query) then
                    noSlot[#noSlot + 1] = e.key
                end
            end
        end
        if #noSlot > 0 then
            items[#items + 1] = { header = true, name = "Sans emplacement", count = #noSlot }
            for _, k in ipairs(noSlot) do items[#items + 1] = { key = k } end
        end
        if #items == 0 then items[#items + 1] = { header = true, name = "Aucun tracker configuré" } end
        return items
    end

    local catKeys = group.cats
    if group.libraryTab and libraryFilter ~= "all" then
        for _, filter in ipairs(LIBRARY_FILTERS) do
            if filter.id == libraryFilter and filter.cats then catKeys = filter.cats end
        end
    end
    for _, catKey in ipairs(catKeys) do
        local cat = byKey[catKey]
        if cat and #cat.entries > 0 then
            local categoryName = CategoryName(cat)
            local matched = {}
            for _, e in ipairs(cat.entries) do
                if MatchesSearch(e.key, categoryName, query) then matched[#matched + 1] = e.key end
            end
            if #matched > 0 then
                items[#items + 1] = { header = true, name = categoryName, count = #matched, catKey = catKey }
                for _, k in ipairs(matched) do items[#items + 1] = { key = k } end
            end
        end
    end
    return items
end

local function FirstEffectKey(items)
    for _, it in ipairs(items or {}) do if it.key then return it.key, it.destination end end
end

local function ShowActiveItemMenu(anchor, key, destination)
    if key then
        currentKey, currentDestination, currentPanel = key, destination, nil
    elseif destination and destination:match("^panel[1-4]$") then
        currentKey, currentDestination, currentPanel = nil, nil, destination
    end
    ClearMenu()
    local function refresh()
        Apply(); UI:RebuildList(); UI:RefreshForm()
    end
    local isPanel = not key and destination and destination:match("^panel[1-4]$")
    if key and destination then
        local enabled = DestinationEnabled(key, destination)
        AddCustomMenuItem(enabled and "Désactiver" or "Activer", function()
            if TSB.SetTrackerDestinationEnabled then TSB.SetTrackerDestinationEnabled(key, destination, not enabled) end
            refresh()
        end)
        if destination:match("^panel[1-4]$") then
            AddCustomMenuItem("Monter", function()
                MovePanelTrackerOrder(key, destination, -1)
                refresh()
            end)
            AddCustomMenuItem("Descendre", function()
                MovePanelTrackerOrder(key, destination, 1)
                refresh()
            end)
        end
        local function moveTo(target)
            if target ~= destination and TSB.MoveTrackerDestination then
                TSB.MoveTrackerDestination(key, destination, target)
                currentDestination = target
            end
            refresh()
        end
        local function moveCallback(target) return function() moveTo(target) end end
        local panelEntries, freeEntries = {}, {}
        for i = 1, 4 do
            local target = "panel" .. tostring(i)
            panelEntries[#panelEntries + 1] = {
                label = (target == destination and "✓ " or "") .. "Panel " .. tostring(i),
                callback = moveCallback(target),
            }
        end
        for i = 1, 10 do
            local target = "free" .. tostring(i)
            freeEntries[#freeEntries + 1] = {
                label = (target == destination and "✓ " or "") .. "Tracker libre " .. tostring(i),
                callback = moveCallback(target),
            }
        end
        AddCustomSubMenuItem("Transférer vers un panel", panelEntries)
        AddCustomSubMenuItem("Transférer en individuel", freeEntries)
        AddCustomMenuItem((destination == "head" and "✓ " or "") .. "Tracker de tête", function() moveTo("head") end)
        AddCustomMenuItem((destination == "group" and "✓ " or "") .. "Tracker de groupe", function() moveTo("group") end)
    elseif isPanel then
        local panelSettings = EnsurePanelAppearance(destination)
        AddCustomMenuItem(panelSettings.enabled == false and "Activer le panel" or "Désactiver le panel", function()
            panelSettings.enabled = panelSettings.enabled == false
            refresh()
        end)
        local function panelMoveCallback(target)
            return function()
                if target ~= destination then
                    for effectKey in pairs(Saved().effectSettings or {}) do
                        if DestinationConfigured(effectKey, destination) and TSB.MoveTrackerDestination then
                            TSB.MoveTrackerDestination(effectKey, destination, target)
                        end
                    end
                    Saved().panelSettings = Saved().panelSettings or {}
                    Saved().panelSettings[target] = CopySetting(panelSettings)
                    Saved().panelSettings[destination] = nil
                    currentPanel = target
                end
                refresh()
            end
        end
        for i = 1, 4 do
            local target = "panel" .. tostring(i)
            AddCustomMenuItem((target == destination and "✓ " or "") .. "Panel " .. i, panelMoveCallback(target))
        end
    end
    AddCustomMenuItem("Supprimer", function()
        if key and destination then
            if TSB.RemoveTrackerDestination then TSB.RemoveTrackerDestination(key, destination) end
            local settings = EffectSettings(key)
            if not TSB.AnyTrackerDestinationConfigured(key) then
                settings.name = nil
                settings.shortName = nil
            end
        elseif destination then
            for effectKey, settings in pairs(Saved().effectSettings or {}) do
                if DestinationConfigured(effectKey, destination) then
                    if TSB.RemoveTrackerDestination then TSB.RemoveTrackerDestination(effectKey, destination) end
                    if not TSB.AnyTrackerDestinationConfigured(effectKey) then
                        settings.name = nil
                        settings.shortName = nil
                    end
                end
            end
            if destination:match("^panel[1-4]$") then
                Saved().panelSettings = Saved().panelSettings or {}
                Saved().panelSettings[destination] = nil
            end
        end
        currentKey, currentDestination, currentPanel = nil, nil, nil
        refresh()
    end)
    local canShare = isPanel or (key and destination and not destination:match("^panel[1-4]$"))
    if canShare then
        AddCustomMenuItem("Import / Export", function() UI:OpenShareScope(key, destination) end)
    end
    ShowMenu(anchor)
end

local function CurrentShareScope()
    if currentPanel then return { destination = currentPanel } end
    if currentDestination and currentDestination:match("^panel[1-4]$") then
        return { destination = currentDestination }
    end
    if currentKey and currentDestination then
        return { key = currentKey, destination = currentDestination }
    end
    return nil
end

local function ShowCompactTimerPositionMenu(anchor, settings)
    if not settings then return end
    ClearMenu()
    local function choose(position)
        settings.compact = true
        settings.compactTimerPosition = position
        Apply()
        UI:RefreshForm()
    end
    AddCustomMenuItem((settings.compactTimerPosition ~= "inside" and "✓ " or "") .. "Au-dessus", function()
        choose("above")
    end)
    AddCustomMenuItem((settings.compactTimerPosition == "inside" and "✓ " or "") .. "Dedans", function()
        choose("inside")
    end)
    ShowMenu(anchor)
end

local function MakeCompactTimerPositionButton(parent, getSettings)
    local button
    button = FlatButton(parent, "AU-DESSUS", 104, 24, function()
        local settings = getSettings and getSettings()
        if settings then ShowCompactTimerPositionMenu(button, settings) end
    end, { 0.05, 0.08, 0.11, 1 }, C.text)
    button.Redraw = function()
        local settings = getSettings and getSettings() or {}
        button.label:SetText(settings.compactTimerPosition == "inside" and "DEDANS" or "AU-DESSUS")
    end
    button:SetHandler("OnMouseExit", function() button.Redraw() end)
    button.Redraw()
    return button
end

-- ---------------------------------------------------------------------
--  Liste paginée (molette), groupée par catégorie
-- ---------------------------------------------------------------------
local function BindRows(list)
    for i = 1, VISIBLE_ROWS do
        local row, item = list.rows[i], list.items[list.offset + i]
        row:ClearAnchors()
        row:SetAnchor(TOPLEFT, list, TOPLEFT, 0, 34 + (i - 1) * (activeTab == "actifs" and 42 or ROW_STEP))
        row.selected, row.baseCenter = false, nil
        if not item then
            row.key = nil; row.destination = nil
            row.gear:SetHidden(true); row.accentBar:SetHidden(true)
            row.iconFrame:SetHidden(true); row.icon:SetHidden(true); row.acr:SetHidden(true)
            row:SetHidden(true)
        elseif item.header then
            -- bandeau d'en-tête : fond sombre + barre d'accent du groupe + compteur
            row.key = nil; row.destination = item.destination; row:SetHidden(false)
            local accent = item.catKey and GroupColorForCategory(item.catKey) or C.cyan
            local panelSelected = currentPanel and item.destination == currentPanel
            if panelSelected then
                row.bg:SetCenterColor(0.04, 0.07, 0.09, 1)
                row.bg:SetEdgeColor(unpack4(C.cyan))
            else
                row.bg:SetCenterColor(unpack4(HEADER_BG))
                row.bg:SetEdgeColor(0, 0, 0, 0)
            end
            row.iconFrame:SetHidden(true); row.icon:SetHidden(true); row.iconAcr:SetText("")
            row.acr:SetHidden(true)
            row.accentBar:SetHidden(false)
            row.accentBar:SetCenterColor(accent[1], accent[2], accent[3], 1)
            local isPanel = item.destination and item.destination:match("^panel[1-4]$")
            local panelEnabled = not isPanel or EnsurePanelAppearance(item.destination).enabled ~= false
            row.name:SetFont(FONT_SMALL)
            row.name:SetColor(panelEnabled and accent[1] or C.textDim[1], panelEnabled and accent[2] or C.textDim[2], panelEnabled and accent[3] or C.textDim[3], 1)
            local headerText = zo_strupper and zo_strupper(item.name or "") or string.upper(item.name or "")
            if item.count then headerText = headerText .. "  —  " .. tostring(item.count) end
            row.name:SetText(headerText)
            row.gear:SetHidden(activeTab ~= "actifs" or not isPanel)
        else
            local key = item.key
            row.key = key; row.destination = item.destination; row:SetHidden(false)
            local c = EffColor(key)
            -- icône réelle du jeu, encadrée de la couleur de l'effet ; acronyme en secours
            local iconPath = EffIcon(key)
            row.iconFrame:SetHidden(false)
            row.iconFrame:SetCenterColor(c.r or 1, c.g or 1, c.b or 1, 1)
            if iconPath then
                row.icon:SetHidden(false)
                row.icon:SetTexture(iconPath)
                row.iconAcr:SetText("")
            else
                row.icon:SetHidden(true)
                row.iconAcr:SetText(EffShort(key))
            end
            local instanceEnabled = item.destination and DestinationEnabled(key, item.destination) or EffEnabled(key)
            if row.icon.SetDesaturation then
                row.icon:SetDesaturation((activeTab == "library" and not instanceEnabled) and 0.45 or 0)
            end
            row.name:SetFont(FONT_LABEL)
            row.name:SetColor(unpack4(instanceEnabled and C.text or C.textDim))
            row.name:SetText(EffName(key))
            -- acronyme discret à droite (bibliothèque : repère de ce qui s'affiche en jeu)
            if activeTab == "library" then
                row.acr:SetHidden(false)
                row.acr:SetText(EffShort(key))
            else
                row.acr:SetHidden(true)
            end
            -- barre verte à gauche = actif (bibliothèque)
            if activeTab == "library" and instanceEnabled then
                row.accentBar:SetHidden(false)
                row.accentBar:SetCenterColor(unpack4(ACTIVE_GREEN))
            else
                row.accentBar:SetHidden(true)
            end
            local sel = key == currentKey and item.destination == currentDestination
            row.selected = sel
            local zebra = ((list.offset + i) % 2 == 0) and ZEBRA_A or ZEBRA_B
            row.baseCenter = sel and { 0.04, 0.07, 0.09, 1 } or zebra
            row.bg:SetCenterColor(unpack4(row.baseCenter))
            row.bg:SetEdgeColor(unpack4(sel and C.cyan or { 0, 0, 0, 0 }))
            row.gear:SetHidden(activeTab ~= "actifs" or not item.destination)
        end
    end
    -- indicateur de défilement (barre fine) + compteur d'effets
    local total = #list.items
    if list.scrollTrack then
        local overflow = total > VISIBLE_ROWS
        list.scrollTrack:SetHidden(not overflow)
        if overflow then
            local trackH = list.scrollTrack:GetHeight() or 0
            if trackH <= 0 then trackH = 520 end
            local thumbH = zo_max(24, trackH * VISIBLE_ROWS / total)
            local maxOffset = zo_max(1, total - VISIBLE_ROWS)
            local y = (trackH - thumbH) * clamp(list.offset / maxOffset, 0, 1)
            list.scrollThumb:SetHeight(thumbH)
            list.scrollThumb:ClearAnchors()
            list.scrollThumb:SetAnchor(TOPLEFT, list.scrollTrack, TOPLEFT, 0, y)
        end
    end
    if list.countLabel then
        local n = 0
        for _, it in ipairs(list.items) do if it.key then n = n + 1 end end
        local noun = (activeTab == "actifs") and "tracker" or "effet"
        list.countLabel:SetText(n > 0 and (tostring(n) .. " " .. noun .. (n > 1 and "s" or "")) or "")
    end
end

local function BuildTrackerList(parent)
    parent.searchText = ""
    parent.searchBg = Backdrop(parent, { 0.04, 0.05, 0.07, 1 }, C.cardEdge)
    parent.searchBg:SetDimensions(280, 28)
    parent.searchBg:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)
    parent.searchIcon = WM:CreateControl(nil, parent.searchBg, CT_TEXTURE)
    parent.searchIcon:SetDimensions(22, 22)
    parent.searchIcon:SetAnchor(LEFT, parent.searchBg, LEFT, 5, 0)
    parent.searchIcon:SetTexture(SEARCH_ICON)
    parent.searchIcon:SetColor(unpack4(C.textDim))
    parent.search = WM:CreateControl(nil, parent, CT_EDITBOX)
    parent.search:SetAnchor(TOPLEFT, parent.searchBg, TOPLEFT, 30, 0)
    parent.search:SetAnchor(BOTTOMRIGHT, parent.searchBg, BOTTOMRIGHT, -8, 0)
    parent.search:SetFont(FONT_LABEL)
    parent.search:SetColor(unpack4(C.text))
    parent.search:SetMaxInputChars(40)
    parent.search:SetMouseEnabled(true)
    parent.search:SetEditEnabled(true)
    if parent.search.SetDefaultText then parent.search:SetDefaultText("Rechercher...") end
    parent.search:SetHandler("OnMouseUp", function(self) self:TakeFocus() end)
    parent.search:SetHandler("OnTextChanged", function(self)
        parent.searchText = self:GetText() or ""
        parent.items = BuildListItems(activeTab, parent.searchText)
        parent.offset = 0
        if not currentKey or not MatchesSearch(currentKey, "", parent.searchText) then
            currentKey, currentDestination = FirstEffectKey(parent.items)
            UI:RefreshForm()
        end
        BindRows(parent)
    end)
    parent.search:SetHandler("OnEnter", function(self) self:LoseFocus() end)
    parent.search:SetHandler("OnEscape", function(self) self:LoseFocus() end)
    parent.items, parent.offset, parent.rows = BuildListItems(activeTab, parent.searchText), 0, {}
    for i = 1, VISIBLE_ROWS do
        local row = WM:CreateControl(nil, parent, CT_CONTROL)
        row:SetDimensions(280, 42); row:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 34 + (i - 1) * ROW_STEP); row:SetMouseEnabled(true)
        row.bg = Backdrop(row, C.card, { 0, 0, 0, 0 }); row.bg:SetAnchorFill(row)
        -- barre d'accent gauche : couleur de groupe (en-têtes) ou vert (tracker actif)
        row.accentBar = Backdrop(row, C.cyan)
        row.accentBar:SetWidth(3)
        row.accentBar:SetAnchor(TOPLEFT, row, TOPLEFT, 0, 0)
        row.accentBar:SetAnchor(BOTTOMLEFT, row, BOTTOMLEFT, 0, 0)
        row.accentBar:SetHidden(true)
        -- icône du jeu, encadrée par la couleur de l'effet (acronyme en secours)
        row.iconFrame = Backdrop(row, { 1, 1, 1, 1 }, { 0, 0, 0, 0.6 })
        row.iconFrame:SetDimensions(34, 34); row.iconFrame:SetAnchor(LEFT, row, LEFT, 12, 0)
        row.icon = WM:CreateControl(nil, row, CT_TEXTURE)
        row.icon:SetDimensions(30, 30); row.icon:SetAnchor(CENTER, row.iconFrame, CENTER, 0, 0)
        row.iconAcr = Label(row, FONT_LABEL, { 1, 1, 1, 1 }, "", TEXT_ALIGN_CENTER)
        row.iconAcr:SetAnchor(CENTER, row.iconFrame, CENTER, 0, 0)
        row.name = Label(row, FONT_LABEL, C.text, "")
        row.name:SetAnchor(LEFT, row.iconFrame, RIGHT, 12, 0)
        row.name:SetAnchor(RIGHT, row, RIGHT, -60, 0)
        row.name:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        if row.name.SetWrapMode and TEXT_WRAP_MODE_ELLIPSIS then row.name:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) end
        row.acr = Label(row, FONT_SMALL, C.textDim, "", TEXT_ALIGN_RIGHT)
        row.acr:SetAnchor(RIGHT, row, RIGHT, -12, 0)
        row.acr:SetHidden(true)
        row.gear = WM:CreateControl(nil, row, CT_BUTTON)
        row.gear:SetDimensions(22, 22); row.gear:SetAnchor(RIGHT, row, RIGHT, -8, 0)
        row.gear:SetNormalTexture(SETTINGS_ICON)
        row.gear:SetMouseOverTexture(SETTINGS_ICON_OVER)
        row.gear:SetPressedTexture(SETTINGS_ICON_OVER)
        row.gear:SetHidden(true)
        row.gear:SetHandler("OnClicked", function(self)
            if row.key then UI:SelectTracker(row.key, row.destination)
            elseif row.destination and row.destination:match("^panel[1-4]$") then UI:SelectPanel(row.destination) end
            ShowActiveItemMenu(self, row.key, row.destination)
        end)
        row:SetHandler("OnMouseUp", function(_, _, upInside)
            if not upInside then return end
            if row.key then
                UI:SelectTracker(row.key, row.destination)
                if activeTab == "actifs" and row.destination then ShowActiveItemMenu(row, row.key, row.destination) end
            elseif row.destination and row.destination:match("^panel[1-4]$") then UI:SelectPanel(row.destination) end
        end)
        row:SetHandler("OnMouseEnter", function()
            if row.key and not row.selected then row.bg:SetCenterColor(unpack4(HOVER_BG)) end
        end)
        row:SetHandler("OnMouseExit", function()
            if row.baseCenter then row.bg:SetCenterColor(unpack4(row.baseCenter)) end
        end)
        row:SetHandler("OnMouseWheel", function(_, d) UI:ScrollList(d) end)
        parent.rows[i] = row
    end
    -- barre de défilement fine (indicateur passif) + compteur d'effets
    parent.scrollTrack = Backdrop(parent, { 0.05, 0.07, 0.09, 0.9 })
    parent.scrollTrack:SetWidth(4)
    parent.scrollTrack:SetAnchor(TOPRIGHT, parent, TOPRIGHT, 8, 34)
    parent.scrollTrack:SetAnchor(BOTTOMRIGHT, parent, BOTTOMRIGHT, 8, -16)
    parent.scrollThumb = Backdrop(parent.scrollTrack, { 0.55, 0.45, 0.28, 1 })
    parent.scrollThumb:SetWidth(4)
    parent.scrollThumb:SetHeight(40)
    parent.scrollThumb:SetAnchor(TOPLEFT, parent.scrollTrack, TOPLEFT, 0, 0)
    parent.scrollTrack:SetHidden(true)
    parent.countLabel = Label(parent, FONT_SMALL, C.textDim, "", TEXT_ALIGN_RIGHT)
    parent.countLabel:SetAnchor(BOTTOMRIGHT, parent, BOTTOMRIGHT, -2, 2)
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
        M.list.items = BuildListItems(activeTab, M.list.searchText)
        M.list.offset = clamp(M.list.offset, 0, zo_max(0, #M.list.items - VISIBLE_ROWS))
        BindRows(M.list)
    end
    self:RefreshFilterCounts()
end

-- ---------------------------------------------------------------------
--  Filtres de la bibliothèque (barre latérale)
-- ---------------------------------------------------------------------
local function LibraryFilterCats(id)
    for _, filter in ipairs(LIBRARY_FILTERS) do
        if filter.id == id then return filter.cats end
    end
end

function UI:RefreshFilterButtons()
    if not M or not M.filterButtons then return end
    for _, button in ipairs(M.filterButtons) do
        local on = (button.id == libraryFilter)
        local accent = GROUP_COLORS[button.id] or C.cyan
        if on then
            button.bg:SetCenterColor(accent[1] * 0.16, accent[2] * 0.16, accent[3] * 0.16, 1)
            button.bg:SetEdgeColor(accent[1], accent[2], accent[3], 1)
            button.label:SetColor(accent[1], accent[2], accent[3], 1)
        else
            button.bg:SetCenterColor(unpack4(C.card))
            button.bg:SetEdgeColor(unpack4(C.cardEdge))
            button.label:SetColor(unpack4(C.text))
        end
        if button.accent then
            button.accent:SetCenterColor(accent[1], accent[2], accent[3], on and 1 or 0.45)
        end
    end
end

-- compteur "actifs / total" par filtre : montre d'un coup d'oeil ce qui est suivi
function UI:RefreshFilterCounts()
    if not M or not M.filterButtons then return end
    local catalog = TSB.GetEffectCatalog and TSB.GetEffectCatalog()
    if not catalog then return end
    local byKey = {}
    for _, cat in ipairs(catalog.categories) do byKey[cat.key] = cat end
    for _, button in ipairs(M.filterButtons) do
        local cats = LibraryFilterCats(button.id) or LIBRARY_ALL_CATS
        local active, total = 0, 0
        for _, catKey in ipairs(cats) do
            local cat = byKey[catKey]
            for _, e in ipairs((cat and cat.entries) or {}) do
                total = total + 1
                if EffEnabled(e.key) then active = active + 1 end
            end
        end
        button.count:SetText(active > 0 and (tostring(active) .. " / " .. tostring(total)) or tostring(total))
        button.count:SetColor(unpack4(active > 0 and C.cyan or C.textDim))
    end
end

function UI:SetLibraryFilter(id)
    libraryFilter = id
    self:RefreshFilterButtons()
    if M and M.list then
        M.list.items = BuildListItems(activeTab, M.list.searchText)
        M.list.offset = 0
        local stillVisible = false
        for _, item in ipairs(M.list.items) do
            if item.key == currentKey then
                stillVisible = true
                break
            end
        end
        if not stillVisible then
            currentKey, currentDestination = FirstEffectKey(M.list.items)
        end
        BindRows(M.list)
    end
    self:RefreshForm()
end

-- ouvre MES TRACKERS directement sur un tracker donné (bouton CONFIGURER de la bibliothèque)
function UI:OpenTrackerConfig(key)
    if not key then return end
    local destinations = ConfiguredDestinations(key, true)
    self:SetTab("actifs")
    if #destinations == 0 then return end
    self:SelectTracker(key, destinations[1])
    if M and M.list then
        for index, item in ipairs(M.list.items) do
            if item.key == key and item.destination == destinations[1] then
                M.list.offset = clamp(zo_max(0, index - 2), 0, zo_max(0, #M.list.items - VISIBLE_ROWS))
                BindRows(M.list)
                break
            end
        end
    end
end

-- décoche TOUT (tous les trackers off)
function UI:ClearAll()
    local catalog = TSB.GetEffectCatalog and TSB.GetEffectCatalog()
    if catalog then
        for _, cat in ipairs(catalog.categories) do
            for _, e in ipairs(cat.entries) do
                local settings = EffectSettings(e.key)
                settings.enabled = false
                for _, destination in ipairs(ConfiguredDestinations(e.key, true)) do
                    if TSB.SetTrackerDestinationEnabled then TSB.SetTrackerDestinationEnabled(e.key, destination, false) end
                end
            end
        end
    end
    Apply()
    self:RebuildList()
    if TSB.Chat then TSB.Chat("tous les trackers ont été désactivés.") end
end

-- EXPORT : produit un code partageable (trackers actifs + couleur + acronyme)
local function EncodeSetting(value)
    if type(value) == "table" then return "#" .. ColorToHex(value) end
    if type(value) == "boolean" then return value and "1" or "0" end
    return SanitizeField(value)
end

local function DecodeSetting(value, template)
    if type(value) ~= "string" then return nil end
    if value:sub(1, 1) == "#" then return HexToColor(value:sub(2)) end
    if type(template) == "boolean" then return value == "1" or value == "true" end
    if type(template) == "number" then return tonumber(value) end
    return value
end

function UI:ExportConfig(scope)
    local catalog = TSB.GetEffectCatalog and TSB.GetEffectCatalog()
    if not catalog then return "" end
    if scope and (scope.key or scope.destination) then
        local destination = scope.destination or currentDestination or (scope.key and EffectSettings(scope.key).destination) or "head"
        local isPanel = destination:match("^panel[1-4]$") ~= nil
        local parts = { "TSB2:" .. SanitizeField(destination) }
        local x, y = Saved()[destination .. "X"], Saved()[destination .. "Y"]
        if tonumber(x) and tonumber(y) then
            parts[#parts + 1] = "P:" .. tostring(zo_round(x)) .. ":" .. tostring(zo_round(y))
        end
        if isPanel then
            local style = EnsurePanelAppearance(destination)
            for _, settingKey in ipairs(PANEL_STYLE_KEYS) do
                parts[#parts + 1] = "S:" .. settingKey .. ":" .. EncodeSetting(style[settingKey])
            end
        end
        -- A panel is always shared as one complete unit.
        local orderedKeys = isPanel and OrderedDestinationKeys(destination, catalog, true)
            or (scope.key and { scope.key } or {})
        if #orderedKeys == 0 then return "" end
        if isPanel then parts[#parts + 1] = "O:" .. table.concat(orderedKeys, ",") end
        for _, key in ipairs(orderedKeys) do
            local settings = EffectSettings(key)
            parts[#parts + 1] = table.concat({
                "E", key, ColorToHex(EffColor(key)), SanitizeField(EffShort(key)),
                settings.showStacks == false and "0" or "1",
                ColorToHex(settings.stackTextColor or Saved().stackTextColor),
                settings.compact == true and "1" or "0",
                settings.timerNoDecimals == true and "1" or "0",
                settings.compactTimerPosition == "inside" and "inside" or "above",
                ColorToHex(settings.cooldownColor or { r = 0.88, g = 0.24, b = 0.08, a = 1 }),
                SanitizeField(settings.name),
            }, ":")
        end
        return table.concat(parts, ";")
    end
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
    local scopedDestination = recs[1] and recs[1]:match("^TSB2:(.+)$")
    if scopedDestination then
        local validDestination = scopedDestination:match("^panel[1-4]$")
            or scopedDestination:match("^free%d+$")
            or scopedDestination == "head"
            or scopedDestination == "group"
        if not validDestination then
            if TSB.Chat then TSB.Chat("import refusé : destination inconnue.") end
            return false
        end
        local validEntries = 0
        for i = 2, #recs do
            local effectKey = recs[i]:match("^E:([^:]+):")
            if effectKey and EffectDef(effectKey) then validEntries = validEntries + 1 end
        end
        if validEntries == 0 then
            if TSB.Chat then TSB.Chat("import refusé : le partage ne contient aucun tracker compatible.") end
            return false
        end
        if scopedDestination:match("^panel[1-4]$") or scopedDestination:match("^free%d+$") then
            for effectKey in pairs(Saved().effectSettings or {}) do
                if DestinationConfigured(effectKey, scopedDestination) and TSB.RemoveTrackerDestination then
                    TSB.RemoveTrackerDestination(effectKey, scopedDestination)
                end
            end
        end
        if scopedDestination:match("^panel[1-4]$") then
            Saved().panelSettings = Saved().panelSettings or {}
            Saved().panelSettings[scopedDestination] = {}
        end
        local n = 0
        for i = 2, #recs do
            local settingKey, encoded = recs[i]:match("^S:([^:]+):(.*)$")
            if settingKey and scopedDestination:match("^panel[1-4]$") then
                local style = EnsurePanelAppearance(scopedDestination)
                local template = Saved()[settingKey]
                if settingKey == "compact" or settingKey == "timerNoDecimals" then template = false end
                style[settingKey] = DecodeSetting(encoded, template)
            else
                local order = recs[i]:match("^O:(.*)$")
                local x, y = recs[i]:match("^P:([^:]+):([^:]+)$")
                if order and scopedDestination:match("^panel[1-4]$") then
                    local style = EnsurePanelAppearance(scopedDestination)
                    style.order = SanitizeField(order):gsub("|", "")
                elseif x and y then
                    Saved()[scopedDestination .. "X"] = tonumber(x) or Saved()[scopedDestination .. "X"]
                    Saved()[scopedDestination .. "Y"] = tonumber(y) or Saved()[scopedDestination .. "Y"]
                else
                local key, hex, short, showStacks, stackHex, compact, timer, timerPosition, cooldownHex, customName = recs[i]:match("^E:([^:]+):([^:]*):([^:]*):([^:]*):([^:]*):([^:]*):([^:]*):([^:]*):([^:]*):([^:]*)$")
                if not key then
                    key, hex, short, showStacks, stackHex, compact, timer, timerPosition, customName = recs[i]:match("^E:([^:]+):([^:]*):([^:]*):([^:]*):([^:]*):([^:]*):([^:]*):([^:]*):([^:]*)$")
                end
                if not key then
                    key, hex, short, showStacks, stackHex, compact, timer, customName = recs[i]:match("^E:([^:]+):([^:]*):([^:]*):([^:]*):([^:]*):([^:]*):([^:]*):([^:]*)$")
                    timerPosition = "above"
                end
                if not key then
                    key, hex, short, showStacks, stackHex, compact, timer = recs[i]:match("^E:([^:]+):([^:]*):([^:]*):([^:]*):([^:]*):([^:]*):([^:]*)$")
                    timerPosition = "above"
                end
                if key and EffectDef(key) then
                    local settings = EffectSettings(key)
                    local added = true
                    if TSB.AddTrackerDestination then added = TSB.AddTrackerDestination(key, scopedDestination)
                    else settings.enabled = true; settings.destination = scopedDestination end
                    local color = HexToColor(hex); if color then settings.color = color end
                    if short ~= "" then settings.shortName = short end
                    settings.showStacks = showStacks ~= "0"
                    local stackColor = HexToColor(stackHex); if stackColor then settings.stackTextColor = stackColor end
                    settings.compact = compact == "1" or nil
                    settings.timerNoDecimals = timer == "1" or nil
                    settings.compactTimerPosition = timerPosition == "inside" and "inside" or "above"
                    local cooldownColor = HexToColor(cooldownHex); if cooldownColor then settings.cooldownColor = cooldownColor end
                    if customName ~= nil then settings.name = customName ~= "" and customName or nil end
                    if added ~= false then n = n + 1 end
                end
                end
            end
        end
        if n == 0 then
            if TSB.Chat then TSB.Chat("import refusé : aucun tracker n'a pu être ajouté.") end
            return false
        end
        Apply(); self:RebuildList(); self:RefreshForm()
        if TSB.Chat then TSB.Chat(string.format("import : %d trackers appliqués.", n)) end
        return true
    end
    if recs[1] ~= "TSB1" then
        if TSB.Chat then TSB.Chat("import : code non reconnu (doit commencer par TSB1).") end
        return false
    end
    local catalog = TSB.GetEffectCatalog and TSB.GetEffectCatalog()
    if catalog then
        for _, cat in ipairs(catalog.categories) do
            for _, e in ipairs(cat.entries) do
                EffectSettings(e.key).enabled = false
                for _, destination in ipairs(ConfiguredDestinations(e.key, true)) do
                    TSB.SetTrackerDestinationEnabled(e.key, destination, false)
                end
            end
        end
    end
    local n = 0
    for i = 2, #recs do
        local k, en, hex, short = string.match(recs[i], "^([^:]+):([^:]*):([^:]*):(.*)$")
        if not k then k, en = string.match(recs[i], "^([^:]+):([^:]*)") end
        if k and k ~= "" then
            local s = EffectSettings(k)
            s.enabled = (en == "1" or en == "true")
            if s.enabled then
                for _, destination in ipairs(ConfiguredDestinations(k, true)) do
                    TSB.SetTrackerDestinationEnabled(k, destination, true)
                end
            end
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
    currentPanel = nil
    currentDestination = nil
    local statsMode = (id == "stats")
    local libraryMode = (id == "library")
    if M and M.share then M.share:SetHidden(true) end -- garde-fou : ferme le partage au changement d'onglet
    if M and M.list then M.list:SetHidden(statsMode) end
    if M and M.filters then M.filters:SetHidden(not libraryMode) end
    if M and M.libForm then M.libForm:SetHidden(not libraryMode) end
    if M and M.form then M.form:SetHidden(statsMode or libraryMode) end
    if M and M.statsForm then M.statsForm:SetHidden(not statsMode) end
    if M and M.btnClear then
        local showClear = libraryMode
        M.btnClear:SetHidden(not showClear)
        if M.btnShare then
            M.btnShare:ClearAnchors()
            M.btnShare:SetAnchor(LEFT, showClear and M.btnClear or M.btnTest, RIGHT, 10, 0)
        end
    end
    if M and M.list and not statsMode then
        -- repositionne / redimensionne la liste selon l'onglet
        local listX = libraryMode and LIST_X_LIBRARY or LIST_X_DEFAULT
        local listW = libraryMode and LIST_W_LIBRARY or LIST_W_DEFAULT
        M.list:ClearAnchors()
        M.list:SetAnchor(TOPLEFT, M, TOPLEFT, listX, 134)
        M.list:SetDimensions(listW, 588)
        if M.list.searchBg then M.list.searchBg:SetWidth(listW) end
        for _, row in ipairs(M.list.rows or {}) do row:SetWidth(listW) end
        M.list.items = BuildListItems(activeTab, M.list.searchText)
        M.list.offset = 0
        currentKey, currentDestination = FirstEffectKey(M.list.items)
        BindRows(M.list)
    end
    if M and M.tabs then
        for _, t in ipairs(M.tabs) do
            local on = (t.id == id)
            t.bg:SetCenterColor(on and 0.04 or C.panel[1], on and 0.07 or C.panel[2], on and 0.09 or C.panel[3], 1)
            t.bg:SetEdgeColor(unpack4(on and C.cyan or C.cardEdge))
            t.label:SetColor(unpack4(on and C.cyan or C.gold))
        end
    end
    self:RefreshFilterButtons()
    self:RefreshFilterCounts()
    self:RefreshForm()
end


-- ---------------------------------------------------------------------
--  Formulaire (tout cablé sur de vrais champs lus par l'addon)
-- ---------------------------------------------------------------------
local function BuildTrackerForm(parent)
    parent.widgets = {}
    local function track(w) table.insert(parent.widgets, w); return w end

    Label(parent, FONT_HEADER, C.cyan, "PERSONNALISATION"):SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)

    -- ---- Carte 1 : tracker sélectionné (per-effet) ----
    local quick = MakeCard(parent, "TRACKER SÉLECTIONNÉ")
    -- [UI] carte agrandie : la ligne 2 ne chevauche plus les champs de saisie et la
    -- La ligne méta (stacks/CD) tient dans la carte sans déborder.
    quick:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 28); quick:SetDimensions(628, 168)
    local q = quick.content
    parent.quickCard = quick

    Label(q, FONT_SMALL, C.textDim, "Nom"):SetAnchor(TOPLEFT, q, TOPLEFT, 0, 0)
    track(MakeEditbox(q, 190, function() return currentKey and EffName(currentKey) or "" end,
        function(v) if currentKey then EffectSettings(currentKey).name = v end end)):SetAnchor(TOPLEFT, q, TOPLEFT, 0, 18)

    Label(q, FONT_SMALL, C.textDim, "Acronyme"):SetAnchor(TOPLEFT, q, TOPLEFT, 210, 0)
    track(MakeEditbox(q, 100, function() return currentKey and EffShort(currentKey) or "" end,
        function(v) if currentKey then EffectSettings(currentKey).shortName = v end end)):SetAnchor(TOPLEFT, q, TOPLEFT, 210, 18)

    Label(q, FONT_SMALL, C.textDim, "État"):SetAnchor(TOPLEFT, q, TOPLEFT, 330, 0)
    track(MakeActivationButton(q)):SetAnchor(TOPLEFT, q, TOPLEFT, 330, 18)

    parent.effectColorLabel = Label(q, FONT_SMALL, C.textDim, "Couleur de l'effet")
    parent.effectColorLabel:SetAnchor(TOPLEFT, q, TOPLEFT, 440, 0)
    track(MakeSwatch(q, function() return currentKey and EffColor(currentKey) end, function(r, g, b, a)
        if not currentKey then return end
        EffectSettings(currentKey).color = { r = r, g = g, b = b, a = a }
        Apply()
    end)):SetAnchor(TOPLEFT, q, TOPLEFT, 440, 18)

    Label(q, FONT_SMALL, C.textDim, "Couleur du cooldown"):SetAnchor(TOPLEFT, q, TOPLEFT, 440, 52)
    track(MakeSwatch(q, function()
        if not currentKey then return Saved().cooldownColor end
        return EffectSettings(currentKey).cooldownColor or Saved().cooldownColor
    end, function(r, g, b, a)
        if currentKey then
            EffectSettings(currentKey).cooldownColor = { r = r, g = g, b = b, a = a }
            Apply()
        end
    end)):SetAnchor(TOPLEFT, q, TOPLEFT, 440, 68)

    -- Ligne de métadonnées (lecture seule) : stacks et cooldown.
    Label(q, FONT_SMALL, C.textDim, "Stacks"):SetAnchor(TOPLEFT, q, TOPLEFT, 0, 52)
    track(MakeToggle(q, function()
        if not currentKey then return false end
        local s = EffectSettings(currentKey)
        if s.showStacks ~= nil then return s.showStacks end
        return Saved().showStacks ~= false
    end, function(v)
        if currentKey then EffectSettings(currentKey).showStacks = v; Apply() end
    end)):SetAnchor(TOPLEFT, q, TOPLEFT, 0, 70)

    Label(q, FONT_SMALL, C.textDim, "Couleur des stacks"):SetAnchor(TOPLEFT, q, TOPLEFT, 90, 52)
    track(MakeSwatch(q, function()
        if not currentKey then return Saved().stackTextColor end
        return EffectSettings(currentKey).stackTextColor or Saved().stackTextColor
    end, function(r, g, b, a)
        if currentKey then EffectSettings(currentKey).stackTextColor = { r = r, g = g, b = b, a = a }; Apply() end
    end)):SetAnchor(TOPLEFT, q, TOPLEFT, 90, 68)

    Label(q, FONT_SMALL, C.textDim, "Compact"):SetAnchor(TOPLEFT, q, TOPLEFT, 200, 52)
    local quickCompactToggle = track(MakeToggle(q, function()
        return currentKey and EffectSettings(currentKey).compact == true
    end, function(v, anchor)
        if not currentKey then return end
        local settings = EffectSettings(currentKey)
        settings.compact = v or nil
        Apply()
        if v then ShowCompactTimerPositionMenu(anchor, settings) end
    end))
    quickCompactToggle:SetAnchor(TOPLEFT, q, TOPLEFT, 200, 70)

    Label(q, FONT_SMALL, C.textDim, "Position du timer"):SetAnchor(TOPLEFT, q, TOPLEFT, 290, 52)
    track(MakeCompactTimerPositionButton(q, function()
        return currentKey and EffectSettings(currentKey) or nil
    end)):SetAnchor(TOPLEFT, q, TOPLEFT, 290, 68)

    parent.metaLabel = Label(q, FONT_SMALL, C.textDim, "")
    parent.metaLabel:SetAnchor(TOPLEFT, q, TOPLEFT, 0, 100)
    parent.metaLabel:SetWidth(580)

    -- ---- Carte 2 : affichage global (tous les champs lus par l'addon) ----
    local disp = MakeCard(parent, "AFFICHAGE")
    disp:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 204); disp:SetDimensions(628, 380)
    parent.displayTitle = disp.title
    local d = disp.content
    parent.displayCard = disp

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
            function() return tonumber(AppearanceSettings()[key]) or minV end,
            function(v) AppearanceSettings()[key] = v; Apply() end, suffix)):SetAnchor(TOPLEFT, d, TOPLEFT, x, y + 18)
    end

    -- Éléments visibles (showNames / showTimers / showBar / showAcronyms)
    subHeader("Éléments", 0)
    toggleAt("Noms", 0, 20, function() return AppearanceSettings().showNames ~= false end, function(v) AppearanceSettings().showNames = v; Apply() end)
    toggleAt("Timers", 150, 20, function() return AppearanceSettings().showTimers ~= false end, function(v) AppearanceSettings().showTimers = v; Apply() end)
    toggleAt("Jauge", 300, 20, function() return AppearanceSettings().showBar ~= false end, function(v) AppearanceSettings().showBar = v; Apply() end)
    toggleAt("Acronyme", 450, 20, function() return AppearanceSettings().showAcronyms ~= false end, function(v) AppearanceSettings().showAcronyms = v; Apply() end)

    -- Fenêtre (unlocked / borderEnabled / layout)
    subHeader("Fenêtre", 56)
    toggleAt("Déverrouiller", 0, 76, function() return AppearanceSettings().unlocked == true end, function(v) AppearanceSettings().unlocked = v; Apply() end)
    toggleAt("Bordure", 200, 76, function() return AppearanceSettings().borderEnabled ~= false end, function(v) AppearanceSettings().borderEnabled = v; Apply() end)
    parent.panelStacksToggle = track(MakeToggle(d,
        function() return AppearanceSettings().showStacks ~= false end,
        function(v) AppearanceSettings().showStacks = v; Apply() end))
    parent.panelStacksToggle:SetAnchor(TOPLEFT, d, TOPLEFT, 290, 76)
    parent.panelStacksLabel = Label(d, FONT_SMALL, C.text, "Stacks")
    parent.panelStacksLabel:SetAnchor(LEFT, parent.panelStacksToggle, RIGHT, 6, 0)

    parent.panelCompactToggle = track(MakeToggle(d,
        function() return AppearanceSettings().compact == true end,
        function(v, anchor)
            local settings = AppearanceSettings()
            settings.compact = v or nil
            Apply()
            if v then ShowCompactTimerPositionMenu(anchor, settings) end
        end))
    parent.panelCompactToggle:SetAnchor(TOPLEFT, d, TOPLEFT, 385, 76)
    parent.panelCompactLabel = Label(d, FONT_SMALL, C.text, "Compact")
    parent.panelCompactLabel:SetAnchor(LEFT, parent.panelCompactToggle, RIGHT, 6, 0)

    parent.panelTimerPositionButton = track(MakeCompactTimerPositionButton(d, function()
        return AppearanceSettings()
    end))
    parent.panelTimerPositionButton:SetAnchor(TOPLEFT, d, TOPLEFT, 480, 75)

    -- Couleurs (texte, timer, acronyme, fenêtre et bordure)
    subHeader("Couleurs", 112)
    swatchAt("Texte", 0, 132, function() return AppearanceSettings().nameTextColor end,
        function(r, g, b, a) AppearanceSettings().nameTextColor = { r = r, g = g, b = b, a = a }; Apply() end)
    swatchAt("Timer", 120, 132, function() return AppearanceSettings().timerTextColor end,
        function(r, g, b, a) AppearanceSettings().timerTextColor = { r = r, g = g, b = b, a = a }; Apply() end)
    swatchAt("Acronyme", 240, 132, function() return AppearanceSettings().acronymTextColor end,
        function(r, g, b, a) AppearanceSettings().acronymTextColor = { r = r, g = g, b = b, a = a }; Apply() end)
    swatchAt("Fond fenêtre", 360, 132, function() return AppearanceSettings().frameColor end,
        function(r, g, b) AppearanceSettings().frameColor = { r = r, g = g, b = b }; Apply() end)
    swatchAt("Bordure", 500, 132, function() local a = AppearanceSettings(); local c = a.borderColor or {}; return { r = c.r, g = c.g, b = c.b, a = a.borderAlpha } end,
        function(r, g, b) AppearanceSettings().borderColor = { r = r, g = g, b = b }; Apply() end)

    -- Réglages chiffrés (borderThickness / circleSize / timerTextScale / scale / *Alpha)
    subHeader("Tailles et transparences", 178)
    sliderAt("Épaisseur de bordure", 0, 198, 185, 2, 6, 1, "borderThickness")
    sliderAt("Taille des cellules", 210, 198, 185, 20, 72, 1, "circleSize")
    sliderAt("Échelle du timer", 420, 198, 172, 0.5, 3, 0.05, "timerTextScale")
    sliderAt("Zoom global", 0, 240, 185, 0.6, 1.8, 0.05, "scale")
    sliderAt("Transp. fond", 210, 240, 185, 0, 1, 0.05, "frameAlpha")
    sliderAt("Transp. texte", 420, 240, 172, 0, 1, 0.05, "textAlpha")
    sliderAt("Transp. carré", 0, 282, 185, 0, 1, 0.05, "badgeAlpha")
    sliderAt("Transp. jauge", 210, 282, 185, 0, 1, 0.05, "barAlpha")
end

-- ---------------------------------------------------------------------
--  Panneau bibliothèque : fiche de l'effet + activation.
--  Volontairement SANS réglages : la personnalisation vit dans MES TRACKERS.
-- ---------------------------------------------------------------------
local function DestinationShortLabel(destination)
    destination = tostring(destination or "")
    local n = destination:match("^panel(%d+)$")
    if n then return "P" .. n end
    n = destination:match("^free(%d+)$")
    if n then return "L" .. n end
    if destination == "head" then return "Tête" end
    if destination == "group" then return "Groupe" end
    return destination
end

local function BuildLibraryForm(parent)
    Label(parent, FONT_HEADER, C.cyan, "BIBLIOTHÈQUE"):SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)

    local card = MakeCard(parent, "EFFET SÉLECTIONNÉ")
    card:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 28)
    card:SetDimensions(334, 320)
    local c = card.content

    -- identité : grande icône du jeu encadrée de la couleur de l'effet
    parent.libFrame = Backdrop(c, { 0.25, 0.25, 0.25, 1 }, { 0, 0, 0, 0.6 })
    parent.libFrame:SetDimensions(58, 58)
    parent.libFrame:SetAnchor(TOPLEFT, c, TOPLEFT, 0, 6)
    parent.libIcon = WM:CreateControl(nil, c, CT_TEXTURE)
    parent.libIcon:SetDimensions(52, 52)
    parent.libIcon:SetAnchor(CENTER, parent.libFrame, CENTER, 0, 0)
    parent.libIconAcr = Label(c, FONT_LABEL, { 1, 1, 1, 1 }, "", TEXT_ALIGN_CENTER)
    parent.libIconAcr:SetAnchor(CENTER, parent.libFrame, CENTER, 0, 0)

    parent.libName = Label(c, FONT_H3, C.text, "")
    parent.libName:SetAnchor(TOPLEFT, c, TOPLEFT, 70, 8)
    parent.libName:SetWidth(228)
    if parent.libName.SetWrapMode and TEXT_WRAP_MODE_ELLIPSIS then parent.libName:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) end
    parent.libCategory = Label(c, FONT_SMALL, C.textDim, "")
    parent.libCategory:SetAnchor(TOPLEFT, c, TOPLEFT, 70, 38)
    parent.libCategory:SetWidth(228)

    -- séparateur en dégradé (asset ESO)
    parent.libDivider = WM:CreateControl(nil, c, CT_TEXTURE)
    parent.libDivider:SetTexture(DIVIDER_TEXTURE)
    parent.libDivider:SetHeight(4)
    parent.libDivider:SetAnchor(TOPLEFT, c, TOPLEFT, -8, 72)
    parent.libDivider:SetAnchor(TOPRIGHT, c, TOPRIGHT, 8, 72)
    parent.libDivider:SetColor(unpack4(C.gold))

    -- métadonnées : paires label / valeur alignées
    parent.libMetaValues = {}
    local metaRows = {
        { key = "target", text = "Cible" },
        { key = "stacks", text = "Stacks maximum" },
        { key = "cd", text = "Cooldown" },
    }
    for idx, def in ipairs(metaRows) do
        local y = 86 + (idx - 1) * 20
        Label(c, FONT_SMALL, C.textDim, def.text):SetAnchor(TOPLEFT, c, TOPLEFT, 0, y)
        local value = Label(c, FONT_SMALL, C.text, "")
        value:SetAnchor(TOPLEFT, c, TOPLEFT, 92, y)
        value:SetWidth(206)
        parent.libMetaValues[def.key] = value
    end
    -- statut en badge (pastille + fond teinté)
    parent.libStatusBg = Backdrop(c, { 0.10, 0.12, 0.15, 1 }, { 0, 0, 0, 0 })
    parent.libStatusBg:SetDimensions(298, 26)
    parent.libStatusBg:SetAnchor(BOTTOMLEFT, c, BOTTOMLEFT, 0, -42)
    parent.libStatusDot = Backdrop(parent.libStatusBg, { 0.45, 0.45, 0.45, 1 })
    parent.libStatusDot:SetDimensions(8, 8)
    parent.libStatusDot:SetAnchor(LEFT, parent.libStatusBg, LEFT, 10, 0)
    parent.libStatus = Label(parent.libStatusBg, FONT_SMALL, C.textDim, "")
    parent.libStatus:SetAnchor(LEFT, parent.libStatusDot, RIGHT, 8, 0)
    parent.libStatus:SetWidth(264)

    parent.libActivate = FlatButton(c, "ACTIVER", 140, 30, function()
        if currentKey then ShowActivationMenu(parent.libActivate) end
    end, { 0.12, 0.30, 0.55, 1 }, C.text)
    parent.libActivate:SetAnchor(BOTTOMLEFT, c, BOTTOMLEFT, 0, 0)

    parent.libConfigure = FlatButton(c, "CONFIGURER", 140, 30, function()
        UI:OpenTrackerConfig(currentKey)
    end)
    parent.libConfigure:SetAnchor(BOTTOMRIGHT, c, BOTTOMRIGHT, 0, 0)

    parent.libNote = Label(parent, FONT_SMALL, C.textDim,
        "Active ici les effets à suivre.\nLe nom, l'acronyme, les couleurs et les panels\nse règlent dans MES TRACKERS.")
    parent.libNote:SetAnchor(TOPLEFT, parent, TOPLEFT, 4, 360)
    parent.libNote:SetWidth(326)
end

function UI:RefreshLibraryForm()
    local f = M and M.libForm
    if not f or not f.libName then return end
    local key = currentKey
    local none = not key
    local e = key and EffectDef(key) or {}
    local color = key and EffColor(key) or { r = 0.25, g = 0.25, b = 0.25 }

    f.libFrame:SetCenterColor(color.r or 1, color.g or 1, color.b or 1, 1)
    local iconPath = key and EffIcon(key) or nil
    f.libIcon:SetHidden(not iconPath)
    if iconPath then f.libIcon:SetTexture(iconPath) end
    f.libIconAcr:SetText((key and not iconPath) and EffShort(key) or "")
    f.libName:SetText(none and "Aucun effet sélectionné" or EffName(key))

    -- catégorie affichée dans la couleur du groupe
    local categoryLabel, accent = "", C.textDim
    if key then
        categoryLabel = e.categoryName or ""
        local catalog = TSB.GetEffectCatalog and TSB.GetEffectCatalog()
        if catalog then
            for _, cat in ipairs(catalog.categories) do
                if cat.key == e.categoryKey then categoryLabel = CategoryName(cat) end
            end
        end
        accent = GroupColorForCategory(e.categoryKey)
    end
    f.libCategory:SetText(categoryLabel)
    f.libCategory:SetColor(accent[1], accent[2], accent[3], 1)

    f.libMetaValues.target:SetText(none and "—" or (e.targetType == "target" and "Cible actuelle" or "Vous"))
    f.libMetaValues.stacks:SetText(e.maxStacks and tostring(e.maxStacks) or "—")
    f.libMetaValues.cd:SetText(e.cooldown and (tostring(e.cooldown) .. " s") or "—")
    -- statut
    local destinations = key and ConfiguredDestinations(key, true) or {}
    local statusText, isActive
    if #destinations > 0 then
        local parts = {}
        for _, destination in ipairs(destinations) do
            local label = DestinationShortLabel(destination)
            if not DestinationEnabled(key, destination) then label = label .. " (désactivé)" end
            parts[#parts + 1] = label
        end
        statusText, isActive = "Actif dans : " .. table.concat(parts, ", "), true
    elseif key and EffEnabled(key) then
        statusText, isActive = "Actif (sans emplacement)", true
    else
        statusText, isActive = "Inactif", false
    end
    f.libStatusBg:SetHidden(none)
    f.libStatus:SetText(statusText)
    if isActive then
        f.libStatusBg:SetCenterColor(0.07, 0.26, 0.14, 1)
        f.libStatusDot:SetCenterColor(0.30, 0.90, 0.45, 1)
        f.libStatus:SetColor(0.62, 0.95, 0.70, 1)
    else
        f.libStatusBg:SetCenterColor(0.10, 0.12, 0.15, 1)
        f.libStatusDot:SetCenterColor(0.45, 0.45, 0.45, 1)
        f.libStatus:SetColor(unpack4(C.textDim))
    end

    f.libActivate:SetHidden(none)
    f.libConfigure:SetHidden(none or #destinations == 0)
    if not none then
        f.libActivate.label:SetText(#destinations > 0 and "AJOUTER" or "ACTIVER")
    end
end

local function StatsSaved()
    local sv = Saved()
    sv.modules = sv.modules or {}
    sv.modules.CombatStats = sv.modules.CombatStats or {}
    return sv.modules.CombatStats
end

local function BuildStatsForm(parent)
    parent.widgets = {}
    local function track(w) table.insert(parent.widgets, w); return w end
    local function S() return StatsSaved() end

    Label(parent, FONT_HEADER, C.cyan, "TRACKER DE STATS DE COMBAT"):SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)

    local general = MakeCard(parent, "GÉNÉRAL ET CAPS")
    general:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 28); general:SetDimensions(932, 160)
    local g = general.content

    local function toggleAt(label, x, y, getF, setF)
        local t = track(MakeToggle(g, getF, setF)); t:SetAnchor(TOPLEFT, g, TOPLEFT, x, y)
        Label(g, FONT_SMALL, C.text, label):SetAnchor(LEFT, t, RIGHT, 6, 0)
    end
    local function sliderAt(label, x, y, w, minV, maxV, step, key, suffix)
        Label(g, FONT_SMALL, C.textDim, label):SetAnchor(TOPLEFT, g, TOPLEFT, x, y)
        track(MakeSlider(g, w, minV, maxV, step,
            function() return tonumber(S()[key]) or minV end,
            function(v) S()[key] = v; Apply() end, suffix)):SetAnchor(TOPLEFT, g, TOPLEFT, x, y + 18)
    end

    toggleAt("Activer", 0, 0, function() return S().enabled ~= false end, function(v) S().enabled = v; Apply() end)
    toggleAt("Déverrouiller", 180, 0, function() return S().unlocked == true end, function(v) S().unlocked = v; Apply() end)
    toggleAt("Afficher les titres", 390, 0, function() return S().showLabels ~= false end, function(v) S().showLabels = v; Apply() end)
    toggleAt("Bordure", 650, 0, function() return S().borderEnabled ~= false end, function(v) S().borderEnabled = v; Apply() end)
    Label(g, FONT_SMALL, C.textDim, "Affichage"):SetAnchor(TOPLEFT, g, TOPLEFT, 760, 0)
    track(MakeSegmented(g, { "Panel", "Barres" },
        function() return (S().displayMode == "cells") and 1 or 2 end,
        function(i) S().displayMode = (i == 1) and "cells" or "bars"; Apply() end)):SetAnchor(TOPLEFT, g, TOPLEFT, 760, 20)
    toggleAt("Stats cible", 760, 58, function() return S().targetEnabled ~= false end, function(v) S().targetEnabled = v; Apply() end)

    sliderAt("Cap pénétration", 0, 48, 300, 0, 30000, 100, "penetrationMax")
    sliderAt("Cap dégâts critiques", 360, 48, 300, 50, 150, 0.5, "criticalMax", "%")

    local appearance = MakeCard(parent, "APPARENCE DU PANEL")
    appearance:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 198); appearance:SetDimensions(932, 346)
    local a = appearance.content
    local function subHeader(text, y) local h = Label(a, FONT_SMALL, C.cyan, text); h:SetAnchor(TOPLEFT, a, TOPLEFT, 0, y) end
    local function swatchAt(label, x, y, key)
        Label(a, FONT_SMALL, C.textDim, label):SetAnchor(TOPLEFT, a, TOPLEFT, x, y)
        track(MakeSwatch(a, function() return S()[key] end, function(r,g,b,alpha) S()[key] = {r=r,g=g,b=b,a=alpha}; Apply() end)):SetAnchor(TOPLEFT, a, TOPLEFT, x, y + 16)
    end
    local function aSlider(label, x, y, w, minV, maxV, step, key, suffix)
        Label(a, FONT_SMALL, C.textDim, label):SetAnchor(TOPLEFT, a, TOPLEFT, x, y)
        track(MakeSlider(a, w, minV, maxV, step,
            function() return tonumber(S()[key]) or minV end,
            function(v) S()[key] = v; Apply() end, suffix)):SetAnchor(TOPLEFT, a, TOPLEFT, x, y + 18)
    end

    subHeader("Couleurs", 0)
    swatchAt("Fond fenêtre", 0, 20, "frameColor")
    swatchAt("Fond cases", 130, 20, "cellColor")
    swatchAt("Bordure", 260, 20, "borderColor")
    swatchAt("Titres", 390, 20, "labelColor")
    swatchAt("Valeur normale", 520, 20, "normalColor")
    swatchAt("Sous le minimum", 650, 20, "lowColor")
    swatchAt("Au-dessus du maximum", 780, 20, "highColor")
    swatchAt("Barres PEN/CRIT", 0, 82, "penBarColor")

    subHeader("Taille proportionnelle", 144)
    aSlider("Échelle de l’ensemble", 0, 164, 260, 0.5, 2.0, 0.05, "scale")
    aSlider("Épaisseur de bordure", 300, 164, 220, 0, 8, 1, "borderThickness")
    aSlider("Actualisation", 560, 164, 240, 100, 1000, 50, "updateMs", " ms")

    subHeader("Transparences", 248)
    aSlider("Fond fenêtre", 0, 268, 190, 0, 1, 0.05, "frameAlpha")
    aSlider("Fond cases", 215, 268, 190, 0, 1, 0.05, "cellAlpha")
    aSlider("Bordure", 430, 268, 190, 0, 1, 0.05, "borderAlpha")
    aSlider("Texte", 645, 268, 190, 0, 1, 0.05, "textAlpha")
end

-- ---------------------------------------------------------------------
--  Refresh / sélection
-- ---------------------------------------------------------------------
function UI:RefreshForm()
    if activeTab == "library" then self:RefreshLibraryForm() end
    local f = M and M.form
    if f and f.widgets then
        for _, w in ipairs(f.widgets) do if w.Redraw then w.Redraw() end end
    end
    local sf = M and M.statsForm
    if sf and sf.widgets then
        for _, w in ipairs(sf.widgets) do if w.Redraw then w.Redraw() end end
    end
    if not f then return end
    local panelSelected = currentPanel ~= nil
    if f.quickCard then f.quickCard:SetHidden(panelSelected) end
    if f.displayCard then
        f.displayCard:ClearAnchors()
        f.displayCard:SetAnchor(TOPLEFT, f, TOPLEFT, 0, panelSelected and 28 or 204)
    end
    if f.panelStacksToggle then f.panelStacksToggle:SetHidden(not panelSelected) end
    if f.panelStacksLabel then f.panelStacksLabel:SetHidden(not panelSelected) end
    if f.panelCompactToggle then f.panelCompactToggle:SetHidden(not panelSelected) end
    if f.panelCompactLabel then f.panelCompactLabel:SetHidden(not panelSelected) end
    if f.panelTimerToggle then f.panelTimerToggle:SetHidden(not panelSelected) end
    if f.panelTimerLabel then f.panelTimerLabel:SetHidden(not panelSelected) end
    if f.panelTimerPositionButton then f.panelTimerPositionButton:SetHidden(not panelSelected) end
    if f.effectColorLabel then f.effectColorLabel:SetText("Couleur de l'effet") end
    if f.displayTitle then
        local dest = currentPanel or currentDestination or (currentKey and EffectSettings(currentKey).destination or nil)
        local title = "RÉGLAGES D'AFFICHAGE"
        local panelNumber = dest and dest:match("^panel(%d+)$")
        local trackerNumber = dest and dest:match("^free(%d+)$")
        if panelNumber then
            title = "RÉGLAGES DU PANEL " .. panelNumber
        elseif trackerNumber then
            title = "RÉGLAGES DU TRACKER " .. trackerNumber
        elseif dest == "head" then
            title = "RÉGLAGES DU TRACKER DE TÊTE"
        elseif dest == "group" then
            title = "RÉGLAGES DU TRACKER DE GROUPE"
        end
        f.displayTitle:SetText(title)
    end
    -- Ligne méta : stacks et cooldown.
    if f.metaLabel then
        if not currentKey then
            f.metaLabel:SetText("")
        else
            local e = EffectDef(currentKey)
            local parts = {}
            if e.maxStacks then parts[#parts + 1] = "Stacks : " .. tostring(e.maxStacks) end
            if e.cooldown then parts[#parts + 1] = "CD : " .. tostring(e.cooldown) .. "s" end
            f.metaLabel:SetText(table.concat(parts, "   •   "))
        end
    end
end

function UI:SelectTracker(key, destination)
    currentPanel = nil
    currentKey = key
    currentDestination = destination
    if M and M.list then BindRows(M.list) end
    self:RefreshForm()
end

function UI:SelectPanel(panelKey)
    if not panelKey or not panelKey:match("^panel[1-4]$") then return end
    currentPanel = panelKey
    currentKey = nil
    currentDestination = nil
    EnsurePanelAppearance(panelKey)
    if M and M.list then BindRows(M.list) end
    self:RefreshForm()
end

-- ---------------------------------------------------------------------
--  Mode test (aperçu de l'addon)
-- ---------------------------------------------------------------------
function UI:UpdateTestButton()
    if not M or not M.btnTest then return end
    M.btnTest.bg:SetCenterColor(testMode and C.blue[1] or C.card[1], testMode and C.blue[2] or C.card[2], testMode and C.blue[3] or C.card[3], 1)
    M.btnTest.bg:SetEdgeColor(unpack4(testMode and C.cyan or C.cardEdge))
end
function UI:SetTest(on)
    testMode = on == true
    TSB.managerTestMode = testMode
    if Saved().previewEnabled == false then Saved().previewEnabled = true end
    TSB.settingsPanelOpen = testMode
    self:UpdateTestButton(); Apply()
end
function UI:ToggleTest() self:SetTest(not testMode) end

-- ---------------------------------------------------------------------
--  Fenêtre
-- ---------------------------------------------------------------------
local BuildShareOverlay -- défini plus bas, utilisé dans BuildWindow
local BuildIncomingShareOverlay

local function LauncherButtonText()
    local language = Saved().catalogLanguage == "en" and "en" or "fr"
    local texts = TSB.translations.launcher[language] or TSB.translations.launcher.fr
    return Saved().launcherVisible == false and texts.show or texts.hide
end

RefreshLauncherButton = function()
    if not M or not M.launcherButton then return end
    local visible = Saved().launcherVisible ~= false
    M.launcherButton.label:SetText(LauncherButtonText())
    M.launcherButton.bg:SetCenterColor(unpack4(C.card))
    M.launcherButton.bg:SetEdgeColor(unpack4(visible and C.cyan or C.cardEdge))
    M.launcherButton.label:SetColor(unpack4(visible and C.cyan or C.gold))
end

local MANAGER_BASE_W, MANAGER_BASE_H = 980, 790
local MANAGER_MIN_SCALE, MANAGER_MAX_SCALE = 0.6, 1.6

local function ApplyManagerScale(scale)
    scale = clamp(tonumber(scale) or 1, MANAGER_MIN_SCALE, MANAGER_MAX_SCALE)
    Saved().managerScale = scale
    if M then M:SetScale(scale) end
    return scale
end

local function BuildWindow()
    if M then return M end
    M = WM:CreateTopLevelWindow(NAME)
    if M.SetDrawTier and DT_MEDIUM then M:SetDrawTier(DT_MEDIUM) end
    M:SetDimensions(MANAGER_BASE_W, MANAGER_BASE_H)
    if tonumber(Saved().managerWindowX) and tonumber(Saved().managerWindowY) then
        M:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, Saved().managerWindowX, Saved().managerWindowY)
    else
        M:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    end
    M:SetMovable(true); M:SetMouseEnabled(true); M:SetClampedToScreen(true); M:SetHidden(true)
    ApplyManagerScale(Saved().managerScale or 1)
    M.bg = Backdrop(M, C.panel, C.gold); M.bg:SetAnchorFill(M)
    M.innerFrame = Backdrop(M, { 0, 0, 0, 0 }, C.cardEdge)
    M.innerFrame:SetAnchor(TOPLEFT, M, TOPLEFT, 3, 3)
    M.innerFrame:SetAnchor(BOTTOMRIGHT, M, BOTTOMRIGHT, -3, -3)

    M.titleBar = WM:CreateControl(nil, M, CT_CONTROL)
    M.titleBar:SetAnchor(TOPLEFT, M, TOPLEFT, 0, 0); M.titleBar:SetAnchor(TOPRIGHT, M, TOPRIGHT, 0, 0); M.titleBar:SetHeight(80); M.titleBar:SetMouseEnabled(true)
    M.titleBar:SetHandler("OnMouseDown", function() M:StartMoving() end)
    M.titleBar:SetHandler("OnMouseUp", function()
        M:StopMovingOrResizing()
        Saved().managerWindowX = zo_round(M:GetLeft() or 0)
        Saved().managerWindowY = zo_round(M:GetTop() or 0)
    end)

    M.addonIcon = WM:CreateControl(nil, M.titleBar, CT_TEXTURE)
    M.addonIcon:SetDimensions(180, 180)
    M.addonIcon:SetAnchor(CENTER, M, TOPLEFT, 0, 0)
    M.addonIcon:SetTexture(ADDON_ICON)
    M.addonIcon:SetTextureCoords(0, 1, 0, 1)

    M.title = Label(M, FONT_TITLE, C.gold, "TEAM SHADOWS BUFFS", TEXT_ALIGN_CENTER)
    M.title:SetAnchor(TOP, M, TOP, 0, 13); M.title:SetWidth(700)
    M.authors = Label(M, FONT_SMALL, C.textDim, "TeamFF - EyrOn", TEXT_ALIGN_CENTER)
    M.authors:SetAnchor(TOP, M.title, BOTTOM, -165, 0); M.authors:SetWidth(160)
    M.contactTeam = Label(M, FONT_SMALL, C.cyan, "CONTACT : @TeamFF", TEXT_ALIGN_CENTER)
    M.contactTeam:SetAnchor(TOP, M.title, BOTTOM, 10, 0); M.contactTeam:SetWidth(140)
    M.contactTeam:SetMouseEnabled(true)
    M.contactTeam:SetHandler("OnMouseUp", function(_, _, upInside) if upInside then OpenContactMail("@TeamFF") end end)
    M.contactTeam:SetHandler("OnMouseEnter", function(control)
        control:SetColor(unpack4(C.gold))
        ZO_Tooltips_ShowTextTooltip(control, BOTTOM, "Ouvrir un courrier pour @TeamFF")
    end)
    M.contactTeam:SetHandler("OnMouseExit", function(control)
        control:SetColor(unpack4(C.cyan))
        ZO_Tooltips_HideTextTooltip()
    end)
    M.contactEyron = Label(M, FONT_SMALL, C.cyan, "@Eyr0n", TEXT_ALIGN_CENTER)
    M.contactEyron:SetAnchor(TOP, M.title, BOTTOM, 120, 0); M.contactEyron:SetWidth(70)
    M.contactEyron:SetMouseEnabled(true)
    M.contactEyron:SetHandler("OnMouseUp", function(_, _, upInside) if upInside then OpenContactMail("@Eyr0n") end end)
    M.contactEyron:SetHandler("OnMouseEnter", function(control)
        control:SetColor(unpack4(C.gold))
        ZO_Tooltips_ShowTextTooltip(control, BOTTOM, "Ouvrir un courrier pour @Eyr0n")
    end)
    M.contactEyron:SetHandler("OnMouseExit", function(control)
        control:SetColor(unpack4(C.cyan))
        ZO_Tooltips_HideTextTooltip()
    end)
    M.headerSeparator = Backdrop(M, C.gold)
    M.headerSeparator:SetAnchor(TOPLEFT, M, TOPLEFT, 92, 75)
    M.headerSeparator:SetAnchor(TOPRIGHT, M, TOPRIGHT, -18, 75)
    M.headerSeparator:SetHeight(1)
    M.lang = MakeSegmented(M, { "FR", "EN" },
        function() return (Saved().catalogLanguage == "en") and 2 or 1 end,
        function(i)
            Saved().catalogLanguage = (i == 2) and "en" or "fr"
            UI:RebuildList()
            UI:RefreshForm()
            RefreshLauncherButton()
            Apply()
        end)
    M.lang:SetAnchor(TOPRIGHT, M, TOPRIGHT, -58, 44)
    M.launcherButton = FlatButton(M, LauncherButtonText(), 132, 26, function()
        Saved().launcherVisible = Saved().launcherVisible == false
        if launcher then launcher:SetHidden(Saved().launcherVisible == false) end
        RefreshLauncherButton()
    end)
    M.launcherButton:SetAnchor(TOPRIGHT, M, TOPRIGHT, -196, 44)
    M.launcherButton:SetHandler("OnMouseEnter", function()
        M.launcherButton.bg:SetCenterColor(0.04, 0.07, 0.09, 1)
        M.launcherButton.bg:SetEdgeColor(unpack4(C.cyan))
    end)
    M.launcherButton:SetHandler("OnMouseExit", RefreshLauncherButton)
    RefreshLauncherButton()
    M.close = FlatButton(M, "X", 30, 30, function() UI:Hide() end, C.panel, C.gold)
    M.close:SetAnchor(TOPRIGHT, M, TOPRIGHT, -14, 10)

    -- Barre d'onglets : la logique et les sections restent inchangées.
    M.tabs = {}
    local tabW = 300
    for i, g in ipairs(TAB_GROUPS) do
        local t = WM:CreateControl(nil, M, CT_CONTROL)
        t:SetDimensions(tabW, 40); t:SetAnchor(TOPLEFT, M, TOPLEFT, 24 + (i - 1) * (tabW + 8), 84); t:SetMouseEnabled(true)
        t.bg = Backdrop(t, C.panel, C.cardEdge); t.bg:SetAnchorFill(t)
        t.label = Label(t, FONT_LABEL, C.gold, g.label, TEXT_ALIGN_CENTER); t.label:SetAnchor(CENTER, t, CENTER, 0, 0)
        t.id = g.id
        t:SetHandler("OnMouseEnter", function()
            if activeTab ~= g.id then t.bg:SetEdgeColor(unpack4(C.gold)) end
        end)
        t:SetHandler("OnMouseExit", function()
            if activeTab ~= g.id then t.bg:SetEdgeColor(unpack4(C.cardEdge)) end
        end)
        t:SetHandler("OnMouseUp", function(_, _, upInside) if upInside then UI:SetTab(g.id) end end)
        M.tabs[i] = t
    end

    -- Barre latérale de filtres (bibliothèque uniquement)
    M.filters = WM:CreateControl(nil, M, CT_CONTROL)
    M.filters:SetAnchor(TOPLEFT, M, TOPLEFT, 24, 134)
    M.filters:SetDimensions(170, 588)
    M.filterButtons = {}
    for i, filter in ipairs(LIBRARY_FILTERS) do
        local button = WM:CreateControl(nil, M.filters, CT_CONTROL)
        button:SetDimensions(170, 34)
        button:SetAnchor(TOPLEFT, M.filters, TOPLEFT, 0, (i - 1) * 40)
        button:SetMouseEnabled(true)
        button.bg = Backdrop(button, C.card, C.cardEdge); button.bg:SetAnchorFill(button)
        -- barre d'accent : couleur d'identité du groupe
        local accent = GROUP_COLORS[filter.id] or C.cyan
        button.accent = Backdrop(button, accent)
        button.accent:SetWidth(4)
        button.accent:SetAnchor(TOPLEFT, button, TOPLEFT, 0, 0)
        button.accent:SetAnchor(BOTTOMLEFT, button, BOTTOMLEFT, 0, 0)
        button.label = Label(button, FONT_SMALL, C.text, filter.label)
        button.label:SetAnchor(LEFT, button, LEFT, 14, 0)
        button.count = Label(button, FONT_SMALL, C.textDim, "", TEXT_ALIGN_RIGHT)
        button.count:SetAnchor(RIGHT, button, RIGHT, -8, 0)
        button.id = filter.id
        button:SetHandler("OnMouseEnter", function()
            if libraryFilter ~= filter.id then button.bg:SetEdgeColor(unpack4(C.gold)) end
        end)
        button:SetHandler("OnMouseExit", function()
            if libraryFilter ~= filter.id then button.bg:SetEdgeColor(unpack4(C.cardEdge)) end
        end)
        button:SetHandler("OnMouseUp", function(_, _, upInside)
            if upInside then UI:SetLibraryFilter(filter.id) end
        end)
        M.filterButtons[i] = button
    end
    M.filters:SetHidden(true)

    M.list = WM:CreateControl(nil, M, CT_CONTROL)
    M.list:SetAnchor(TOPLEFT, M, TOPLEFT, 24, 134); M.list:SetDimensions(280, 588)
    BuildTrackerList(M.list)

    M.form = WM:CreateControl(nil, M, CT_CONTROL)
    M.form:SetAnchor(TOPLEFT, M, TOPLEFT, 328, 134); M.form:SetDimensions(628, 588)
    BuildTrackerForm(M.form)

    M.libForm = WM:CreateControl(nil, M, CT_CONTROL)
    M.libForm:SetAnchor(TOPLEFT, M, TOPLEFT, 622, 134); M.libForm:SetDimensions(334, 588)
    BuildLibraryForm(M.libForm)
    M.libForm:SetHidden(true)

    M.statsForm = WM:CreateControl(nil, M, CT_CONTROL)
    M.statsForm:SetAnchor(TOPLEFT, M, TOPLEFT, 24, 134); M.statsForm:SetDimensions(932, 588)
    BuildStatsForm(M.statsForm)
    M.statsForm:SetHidden(true)

    -- footer : MODE TEST | TOUT DÉCOCHER | IMPORT/EXPORT (gauche), SAUVEGARDER + RESET (droite)
    M.btnTest = FlatButton(M, "MODE TEST", 140, 36, function() UI:ToggleTest() end)
    M.btnTest:SetAnchor(BOTTOMLEFT, M, BOTTOMLEFT, 24, -16)
    M.btnTest:SetHandler("OnMouseExit", function()
        M.btnTest.bg:SetCenterColor(testMode and C.blue[1] or C.card[1], testMode and C.blue[2] or C.card[2], testMode and C.blue[3] or C.card[3], 1)
        M.btnTest.bg:SetEdgeColor(unpack4(testMode and C.cyan or C.cardEdge))
    end)

    M.btnClear = FlatButton(M, "TOUT DÉCOCHER", 160, 36, function() UI:ClearAll() end, { 0.30, 0.12, 0.12, 1 }, C.text)
    M.btnClear:SetAnchor(LEFT, M.btnTest, RIGHT, 10, 0)

    M.btnShare = FlatButton(M, "IMPORT / EXPORT", 150, 36, function()
        UI.shareScope = CurrentShareScope()
        if not UI.shareScope then
            if TSB.Chat then TSB.Chat("sélectionne d'abord un panneau ou un tracker actif.") end
            return
        end
        UI:ToggleShare()
    end)
    M.btnShare:SetAnchor(LEFT, M.btnClear, RIGHT, 10, 0)

    M.btnSave = FlatButton(M, "SAUVEGARDER", 150, 36, function() Apply(); if TSB.Chat then TSB.Chat("Réglages appliqués.") end end, { 0.12, 0.30, 0.55, 1 }, C.text)
    M.btnSave:SetAnchor(BOTTOMRIGHT, M, BOTTOMRIGHT, -160, -16)
    M.btnReset = FlatButton(M, "RÉINITIALISER", 130, 36, function()
        if activeTab == "stats" then
            local defaults = TSB.defaults and TSB.defaults.modules and TSB.defaults.modules.CombatStats or {}
            Saved().modules = Saved().modules or {}
            Saved().modules.CombatStats = ZO_DeepTableCopy and ZO_DeepTableCopy(defaults) or defaults
        elseif currentKey and TSB.ResetEffectSettings then
            TSB.ResetEffectSettings(currentKey)
        elseif currentPanel then
            Saved().panelSettings = Saved().panelSettings or {}
            Saved().panelSettings[currentPanel] = nil
            EnsurePanelAppearance(currentPanel)
        end
        UI:RefreshForm(); Apply()
    end)
    M.btnReset:SetAnchor(LEFT, M.btnSave, RIGHT, 10, 0)

    -- [UI] BORDS ZOOMABLES : attraper le bord gauche, droit, bas ou un coin bas
    -- et tirer — comme un redimensionnement classique, converti en zoom uniforme.
    -- Les bords s'illuminent au survol. Position et zoom mémorisés au relâchement.
    local zoomDragging = false
    local function StartZoomDrag(mode)
        if zoomDragging or not GetUIMousePosition then return end
        zoomDragging = true
        local left0, top0 = M:GetLeft() or 0, M:GetTop() or 0
        local right0 = left0 + MANAGER_BASE_W * (M:GetScale() or 1)
        -- ancrage TOPLEFT stable pendant le drag (le zoom pivote alors en haut-gauche)
        M:ClearAnchors()
        M:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left0, top0)
        EVENT_MANAGER:RegisterForUpdate("TeamShadowsBuffsZoomDrag", 15, function()
            local mx, my = GetUIMousePosition()
            local s
            if mode == "left" then
                s = (right0 - mx) / MANAGER_BASE_W
            elseif mode == "right" then
                s = (mx - left0) / MANAGER_BASE_W
            elseif mode == "bottom" then
                s = (my - top0) / MANAGER_BASE_H
            elseif mode == "bottomleft" then
                s = zo_max((right0 - mx) / MANAGER_BASE_W, (my - top0) / MANAGER_BASE_H)
            else -- bottomright
                s = zo_max((mx - left0) / MANAGER_BASE_W, (my - top0) / MANAGER_BASE_H)
            end
            s = clamp(s, MANAGER_MIN_SCALE, MANAGER_MAX_SCALE)
            M:SetScale(s)
            if mode == "left" or mode == "bottomleft" then
                -- côté gauche : le bord DROIT reste fixe, la fenêtre suit la souris
                M:ClearAnchors()
                M:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, right0 - MANAGER_BASE_W * s, top0)
            end
        end)
    end
    local function StopZoomDrag()
        if not zoomDragging then return end
        zoomDragging = false
        EVENT_MANAGER:UnregisterForUpdate("TeamShadowsBuffsZoomDrag")
        ApplyManagerScale(M:GetScale() or 1)
        Saved().managerWindowX = zo_round(M:GetLeft() or 0)
        Saved().managerWindowY = zo_round(M:GetTop() or 0)
    end
    local function MakeZoomEdge(mode)
        local edge = WM:CreateControl(nil, M, CT_CONTROL)
        edge:SetMouseEnabled(true)
        edge.glow = WM:CreateControl(nil, edge, CT_TEXTURE)
        edge.glow:SetAnchorFill(edge)
        edge.glow:SetColor(0.83, 0.68, 0.40, 0)
        edge:SetHandler("OnMouseEnter", function(c)
            c.glow:SetColor(0.83, 0.68, 0.40, 0.30)
            ZO_Tooltips_ShowTextTooltip(c, TOP, "Tirer pour zoomer la fenêtre")
        end)
        edge:SetHandler("OnMouseExit", function(c)
            c.glow:SetColor(0.83, 0.68, 0.40, 0)
            ZO_Tooltips_HideTextTooltip()
        end)
        edge:SetHandler("OnMouseDown", function() ZO_Tooltips_HideTextTooltip(); StartZoomDrag(mode) end)
        edge:SetHandler("OnMouseUp", StopZoomDrag)
        return edge
    end
    local eL = MakeZoomEdge("left")
    eL:SetWidth(10); eL:SetAnchor(TOPLEFT, M, TOPLEFT, 0, 84); eL:SetAnchor(BOTTOMLEFT, M, BOTTOMLEFT, 0, -28)
    local eR = MakeZoomEdge("right")
    eR:SetWidth(10); eR:SetAnchor(TOPRIGHT, M, TOPRIGHT, 0, 84); eR:SetAnchor(BOTTOMRIGHT, M, BOTTOMRIGHT, 0, -28)
    local eB = MakeZoomEdge("bottom")
    eB:SetHeight(10); eB:SetAnchor(BOTTOMLEFT, M, BOTTOMLEFT, 28, 0); eB:SetAnchor(BOTTOMRIGHT, M, BOTTOMRIGHT, -28, 0)
    local eBL = MakeZoomEdge("bottomleft")
    eBL:SetDimensions(28, 28); eBL:SetAnchor(BOTTOMLEFT, M, BOTTOMLEFT, 0, 0)
    local eBR = MakeZoomEdge("bottomright")
    eBR:SetDimensions(28, 28); eBR:SetAnchor(BOTTOMRIGHT, M, BOTTOMRIGHT, 0, 0)
    -- points du coin bas-droit : affordance visible du zoom
    for _, d in ipairs({ { -4, -4 }, { -11, -4 }, { -4, -11 }, { -18, -4 }, { -11, -11 }, { -4, -18 } }) do
        local px = WM:CreateControl(nil, eBR, CT_TEXTURE)
        px:SetDimensions(4, 4)
        px:SetAnchor(BOTTOMRIGHT, eBR, BOTTOMRIGHT, d[1], d[2])
        px:SetColor(unpack4(C.gold))
    end

    BuildShareOverlay()
    BuildIncomingShareOverlay()

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

    M.shareTitle = Label(s, FONT_HEADER, C.cyan, "IMPORT / EXPORT", TEXT_ALIGN_CENTER)
    M.shareTitle:SetAnchor(TOP, s, TOP, 0, 16)
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
    local bExp = FlatButton(s, "EXPORTER", 120, 34, function()
        edit:SetText(UI:ExportConfig(UI.shareScope)); edit:TakeFocus(); if edit.SelectAll then edit:SelectAll() end
    end, { 0.12, 0.30, 0.55, 1 }, C.text)
    bExp:SetAnchor(BOTTOMLEFT, s, BOTTOMLEFT, 20, -20)

    local bImp = FlatButton(s, "IMPORTER", 120, 34, function()
        UI:ImportConfig(edit:GetText()); UI:RefreshForm()
    end, { 0.12, 0.40, 0.20, 1 }, C.text)
    bImp:SetAnchor(LEFT, bExp, RIGHT, 10, 0)

    local bGroup = FlatButton(s, "ENVOYER AU GROUPE", 190, 34, function()
        local groupScope = UI.shareScope or CurrentShareScope()
        if not groupScope or not (groupScope.key or groupScope.destination) then
            if TSB.Chat then TSB.Chat("choisis un panneau ou un tracker avec sa roue avant l'envoi au groupe.") end
            return
        end
        local code = UI:ExportConfig(groupScope)
        edit:SetText(code)
        if TSB.GroupShare and TSB.GroupShare.Send then TSB.GroupShare:Send(code) end
    end, { 0.12, 0.30, 0.55, 1 }, C.text)
    bGroup:SetAnchor(LEFT, bImp, RIGHT, 10, 0)

    local bClose = FlatButton(s, "FERMER", 110, 34, function() s:SetHidden(true) end)
    bClose:SetAnchor(BOTTOMRIGHT, s, BOTTOMRIGHT, -20, -20)
end

local function IncomingSenderName(unitTag)
    if GetUnitDisplayName then
        local name = GetUnitDisplayName(unitTag)
        if name and name ~= "" then return name end
    end
    if GetUnitName then
        local name = GetUnitName(unitTag)
        if name and name ~= "" then return name end
    end
    return tostring(unitTag or "Joueur")
end

local function IncomingSourceType(code)
    if tostring(code):find("^TSB1") then return "complete", nil end
    local destination = tostring(code):match("^TSB2:([^;]+)")
    if destination and destination:match("^panel[1-4]$") then return "panel", destination end
    if destination == "head" or destination == "group" or (destination and destination:match("^free%d+$")) then return "tracker", destination end
    return nil, destination
end

local function AutomaticPanelDestination(sourceDestination)
    local occupied = {}
    for effectKey in pairs(Saved().effectSettings or {}) do
        for _, destination in ipairs(ConfiguredDestinations(effectKey, true)) do
            if destination:match("^panel[1-4]$") then occupied[destination] = true end
        end
    end
    for i = 1, 4 do
        local destination = "panel" .. i
        if not occupied[destination] then return destination, false end
    end
    if sourceDestination and sourceDestination:match("^panel[1-4]$") then return sourceDestination, true end
    return "panel1", true
end

local function AutomaticTrackerDestination(sourceDestination)
    if sourceDestination == "head" then return "head", false end
    if sourceDestination == "group" then return "group", false end
    local occupied = {}
    for effectKey in pairs(Saved().effectSettings or {}) do
        for _, destination in ipairs(ConfiguredDestinations(effectKey, true)) do
            if destination:match("^free%d+$") then occupied[destination] = true end
        end
    end
    for i = 1, 10 do
        local destination = "free" .. i
        if not occupied[destination] then return destination, false end
    end
    if sourceDestination and sourceDestination:match("^free%d+$") then return sourceDestination, true end
    return "free1", true
end

local function RefreshIncomingShareOverlay()
    if not M or not M.incomingShare or not UI.incomingShare then return end
    local incoming = UI.incomingShare
    M.incomingSender:SetText("Reçue de " .. IncomingSenderName(incoming.unitTag))
    if incoming.kind == "panel" then
        local panelNumber = tostring(incoming.destination):match("(%d+)$") or "1"
        local action = incoming.replacesPanel and "P" .. panelNumber .. " sera remplacé." or "Destination automatique : P" .. panelNumber .. "."
        M.incomingDescription:SetText("Configuration d'un panneau. " .. action)
    elseif incoming.kind == "tracker" then
        local trackerNumber = tostring(incoming.destination):match("^free(%d+)$")
        local label = trackerNumber and ("L" .. trackerNumber)
            or (incoming.destination == "group" and "Tracker de groupe" or "Tracker de tête")
        local action = incoming.replacesTracker and label .. " sera remplacé." or "Destination automatique : " .. label .. "."
        M.incomingDescription:SetText("Configuration d'un tracker. " .. action)
    else
        M.incomingDescription:SetText("Configuration complète. Tous les trackers actuels seront remplacés.")
    end

    for i, button in ipairs(M.incomingPanelButtons or {}) do
        button:SetHidden(true)
        local selected = incoming.destination == ("panel" .. i)
        button.bg:SetCenterColor(unpack4(selected and C.blue or C.card))
    end
    for key, button in pairs(M.incomingTrackerButtons or {}) do
        button:SetHidden(true)
        local selected = incoming.destination == key
        button.bg:SetCenterColor(unpack4(selected and C.blue or C.card))
    end
    M.incomingDestinationLabel:SetHidden(true)
end

local function CloseIncomingShare()
    if M and M.incomingShare then M.incomingShare:SetHidden(true) end
    UI.incomingShare = nil
    if UI.incomingQueue and #UI.incomingQueue > 0 then
        local nextShare = table.remove(UI.incomingQueue, 1)
        zo_callLater(function() UI:ReceiveGroupShare(nextShare.unitTag, nextShare.payload) end, 100)
    end
end

function UI:AcceptIncomingShare()
    local incoming = self.incomingShare
    if not incoming then return end
    if IsUnitInCombat and IsUnitInCombat("player") then
        if TSB.Chat then TSB.Chat("import impossible pendant le combat.") end
        return
    end
    if TSB.GroupShare and TSB.GroupShare.IsLocationAllowed and not TSB.GroupShare:IsLocationAllowed() then
        if TSB.Chat then TSB.Chat("import impossible en Cyrodiil et dans le monde ouvert.") end
        return
    end
    local code = incoming.payload
    if incoming.kind == "panel" then
        code = code:gsub("^TSB2:[^;]+", "TSB2:" .. incoming.destination, 1)
    elseif incoming.kind == "tracker" then
        local destination = incoming.destination
        if destination == "free" then
            destination = FirstFreeTrackerDestination(nil)
            if not destination then
                if TSB.Chat then TSB.Chat("import impossible : aucun tracker libre disponible.") end
                return
            end
        end
        code = code:gsub("^TSB2:[^;]+", "TSB2:" .. destination, 1)
    end
    if self:ImportConfig(code) then CloseIncomingShare() end
end

function UI:ReceiveGroupShare(unitTag, payload)
    local kind, sourceDestination = IncomingSourceType(payload)
    if not kind then return false end
    BuildWindow()
    if self.incomingShare and M.incomingShare and not M.incomingShare:IsHidden() then
        self.incomingQueue = self.incomingQueue or {}
        self.incomingQueue[#self.incomingQueue + 1] = { unitTag = unitTag, payload = payload }
        if TSB.Chat then TSB.Chat("une autre configuration reçue a été mise en attente.") end
        return true
    end
    local automaticDestination, replacesPanel, replacesTracker
    if kind == "panel" then automaticDestination, replacesPanel = AutomaticPanelDestination(sourceDestination) end
    if kind == "tracker" then automaticDestination, replacesTracker = AutomaticTrackerDestination(sourceDestination) end
    self.incomingShare = {
        unitTag = unitTag,
        payload = payload,
        kind = kind,
        destination = (kind == "panel" or kind == "tracker") and automaticDestination or nil,
        replacesPanel = replacesPanel,
        replacesTracker = replacesTracker,
    }
    RefreshIncomingShareOverlay()
    M.incomingShare:SetHidden(false)
    return true
end

BuildIncomingShareOverlay = function()
    local s = WM:CreateTopLevelWindow(NAME .. "IncomingShare")
    s:SetDimensions(660, 270); s:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    s:SetMouseEnabled(true); s:SetHidden(true); s:SetClampedToScreen(true)
    if s.SetDrawTier and DT_HIGH then s:SetDrawTier(DT_HIGH) end
    s.bg = Backdrop(s, C.panel, C.gold); s.bg:SetAnchorFill(s)
    M.incomingShare = s

    local title = Label(s, FONT_HEADER, C.cyan, "CONFIGURATION DE GROUPE", TEXT_ALIGN_CENTER)
    title:SetAnchor(TOP, s, TOP, 0, 18)
    M.incomingSender = Label(s, FONT_LABEL, C.text, "", TEXT_ALIGN_CENTER)
    M.incomingSender:SetAnchor(TOP, s, TOP, 0, 52); M.incomingSender:SetWidth(620)
    M.incomingDescription = Label(s, FONT_SMALL, C.textDim, "", TEXT_ALIGN_CENTER)
    M.incomingDescription:SetAnchor(TOP, s, TOP, 0, 82); M.incomingDescription:SetWidth(620)
    M.incomingDestinationLabel = Label(s, FONT_SMALL, C.cyan, "DESTINATION", TEXT_ALIGN_CENTER)
    M.incomingDestinationLabel:SetAnchor(TOP, s, TOP, 0, 116); M.incomingDestinationLabel:SetWidth(620)

    M.incomingPanelButtons = {}
    for i = 1, 4 do
        local panelIndex = i
        local button = FlatButton(s, "P" .. panelIndex, 80, 32, function()
            if UI.incomingShare then UI.incomingShare.destination = "panel" .. panelIndex; RefreshIncomingShareOverlay() end
        end)
        button:SetAnchor(TOPLEFT, s, TOPLEFT, 145 + ((panelIndex - 1) * 94), 142)
        button:SetHandler("OnMouseExit", RefreshIncomingShareOverlay)
        M.incomingPanelButtons[panelIndex] = button
    end
    M.incomingTrackerButtons = {}
    local free = FlatButton(s, "TRACKER LIBRE", 180, 32, function()
        if UI.incomingShare then UI.incomingShare.destination = "free"; RefreshIncomingShareOverlay() end
    end)
    free:SetAnchor(TOPLEFT, s, TOPLEFT, 140, 142); free:SetHandler("OnMouseExit", RefreshIncomingShareOverlay)
    M.incomingTrackerButtons.free = free
    local head = FlatButton(s, "TRACKER TÊTE", 180, 32, function()
        if UI.incomingShare then UI.incomingShare.destination = "head"; RefreshIncomingShareOverlay() end
    end)
    head:SetAnchor(TOPRIGHT, s, TOPRIGHT, -140, 142); head:SetHandler("OnMouseExit", RefreshIncomingShareOverlay)
    M.incomingTrackerButtons.head = head

    local accept = FlatButton(s, "ACCEPTER", 160, 36, function() UI:AcceptIncomingShare() end, { 0.12, 0.40, 0.20, 1 }, C.text)
    accept:SetAnchor(BOTTOMLEFT, s, BOTTOMLEFT, 150, -22)
    local refuse = FlatButton(s, "REFUSER", 160, 36, CloseIncomingShare, { 0.40, 0.12, 0.12, 1 }, C.text)
    refuse:SetAnchor(BOTTOMRIGHT, s, BOTTOMRIGHT, -150, -22)
end

function UI:ToggleShare()
    if not M or not M.share then return end
    local willShow = M.share:IsHidden()
    M.share:SetHidden(not willShow)
    if willShow and M.shareEdit then
        -- à l'ouverture, on pré-remplit avec la config actuelle (prête à copier)
        local scope = self.shareScope
        M.shareEdit:SetText(self:ExportConfig(scope))
        if M.shareTitle then
            local name = scope and (scope.destination or scope.key)
            local upperName = name and (zo_strupper and zo_strupper(name) or string.upper(name))
            M.shareTitle:SetText(upperName and ("IMPORT / EXPORT - " .. upperName) or "IMPORT / EXPORT")
        end
    end
end

function UI:OpenShareScope(key, destination)
    if destination and destination:match("^panel[1-4]$") then key = nil end
    self.shareScope = { key = key, destination = destination }
    if not M or not M.share then return end
    M.share:SetHidden(true)
    self:ToggleShare()
end

-- ---------------------------------------------------------------------
--  Icône permanente d'ouverture
-- ---------------------------------------------------------------------
function UI:InitializeLauncher()
    if launcher then return launcher end
    local saved = Saved()
    local size = clamp(tonumber(saved.launcherSize) or 64, 40, 120)
    launcher = WM:CreateTopLevelWindow("TeamShadowsBuffsLauncher")
    launcher:SetDimensions(size, size)
    launcher:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, tonumber(saved.launcherX) or 36, tonumber(saved.launcherY) or 300)
    launcher:SetMovable(true)
    launcher:SetMouseEnabled(true)
    launcher:SetClampedToScreen(true)
    launcher:SetHidden(saved.launcherVisible == false)
    if launcher.SetDrawTier and DT_MEDIUM then launcher:SetDrawTier(DT_MEDIUM) end

    launcher.glow = WM:CreateControl(nil, launcher, CT_TEXTURE)
    launcher.glow:SetDimensions(size + 10, size + 10)
    launcher.glow:SetAnchor(CENTER, launcher, CENTER, 0, 0)
    launcher.glow:SetTexture(ADDON_ICON)
    launcher.glow:SetColor(C.cyan[1], C.cyan[2], C.cyan[3], 0.55)
    launcher.glow:SetHidden(true)

    launcher.icon = WM:CreateControl(nil, launcher, CT_TEXTURE)
    launcher.icon:SetAnchorFill(launcher)
    launcher.icon:SetTexture(ADDON_ICON)
    launcher.icon:SetTextureCoords(0, 1, 0, 1)
    launcher.icon:SetMouseEnabled(false)
    launcher.glow:SetMouseEnabled(false)

    launcher:SetHandler("OnMouseEnter", function() launcher.glow:SetHidden(false) end)
    launcher:SetHandler("OnMouseExit", function() launcher.glow:SetHidden(true) end)
    launcher:SetHandler("OnMouseDown", function(self, button)
        if button ~= 1 and button ~= MOUSE_BUTTON_INDEX_LEFT then return end
        local mouseX, mouseY = GetUIMousePosition()
        self.dragStartLeft = self:GetLeft() or 0
        self.dragStartTop = self:GetTop() or 0
        self.dragStartMouseX, self.dragStartMouseY = mouseX, mouseY
        self.dragging = true
    end)
    launcher:SetHandler("OnUpdate", function(self)
        if not self.dragging then return end
        local mouseX, mouseY = GetUIMousePosition()
        local rootWidth, rootHeight = GuiRoot:GetWidth(), GuiRoot:GetHeight()
        local left = clamp((self.dragStartLeft or 0) + mouseX - (self.dragStartMouseX or mouseX), 0, zo_max(0, rootWidth - size))
        local top = clamp((self.dragStartTop or 0) + mouseY - (self.dragStartMouseY or mouseY), 0, zo_max(0, rootHeight - size))
        self:ClearAnchors()
        self:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    end)
    launcher:SetHandler("OnMouseUp", function(self, button, upInside)
        if (button ~= 1 and button ~= MOUSE_BUTTON_INDEX_LEFT) or not self.dragging then return end
        local left, top = self:GetLeft() or 0, self:GetTop() or 0
        local moved = math.abs(left - (self.dragStartLeft or left)) > 4
            or math.abs(top - (self.dragStartTop or top)) > 4
        saved.launcherX = zo_round(left)
        saved.launcherY = zo_round(top)
        self.dragStartLeft, self.dragStartTop = nil, nil
        self.dragStartMouseX, self.dragStartMouseY, self.dragging = nil, nil, nil
        if upInside and not moved then UI:Toggle() end
    end)
    return launcher
end

-- ---------------------------------------------------------------------
--  API publique
-- ---------------------------------------------------------------------
function UI:Show()
    self:InitializeLauncher(); BuildWindow(); M:SetHidden(false)
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
