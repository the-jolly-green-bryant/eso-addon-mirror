-- ============================================================
--  DebuffTracker.lua
--  Suivi des debuffs sur les cibles taunted.
--  Pills à largeur automatique + retour à la ligne.
--
--  Expose vers TargetTracker.lua :
--    TT.activeDebuffs            [key][abilityId] = true
--    TT.DEBUFF_LIST              liste brute
--    TT.DEBUFF_COLORS            table de couleurs
--    TT.GetPillWidth(short, fs)  largeur d'une pill
--    TT.IsDebuffEnabled(id)      setting activé ?
--    TT.GetActiveDebuffsForKey(key)  liste des configs actives
--    TT.RenderDebuffsForBar(b, key, bw, bh)  rendu pills
--    TT.ComputeDebuffRowCount(key, bw)        nb de lignes pills
-- ============================================================

local TT = TauntTracker

-- ============================================================
--  COULEURS — exposées pour TargetTracker
-- ============================================================

-- Valeurs par défaut (référence immuable)
local COLOR_DEFAULTS = {
    MAJOR = { r=1.00, g=0.20, b=0.20 },
    MINOR = { r=0.30, g=1.00, b=0.35 },
    SET   = { r=1.00, g=0.80, b=0.20 },
    SCRIB = { r=0.65, g=0.30, b=1.00 },
    OTHER = { r=1.00, g=1.00, b=1.00 },
    CLASS = { r=0.25, g=0.75, b=1.00 },
}
TT.DEBUFF_COLORS = {
    MAJOR = { r=1.00, g=0.20, b=0.20 },
    MINOR = { r=0.30, g=1.00, b=0.35 },
    SET   = { r=1.00, g=0.80, b=0.20 },
    SCRIB = { r=0.65, g=0.30, b=1.00 },
    OTHER = { r=1.00, g=1.00, b=1.00 },
    CLASS = { r=0.25, g=0.75, b=1.00 },
}
local COLORS = TT.DEBUFF_COLORS

-- Synchronise COLORS depuis TauntTrackerSettings (appelé à l'init et à chaque changement)
local function RefreshColors()
    local sv = TauntTrackerSettings
    if not sv then return end

    for typeName, def in pairs(COLOR_DEFAULTS) do
        local col = COLORS[typeName]
        if not col then
            col = {}
            COLORS[typeName] = col
        end

        col.r = sv["color_" .. typeName .. "_r"] or def.r
        col.g = sv["color_" .. typeName .. "_g"] or def.g
        col.b = sv["color_" .. typeName .. "_b"] or def.b
    end
end
TT.RefreshColors = RefreshColors

-- ============================================================
--  DEBUFFS TRACKÉS — exposés pour TargetTracker
-- ============================================================

TT.DEBUFF_LIST = {
    { id=61743,  name=GetString(TAUNTTRACKER_MajorBreach),      short="BREACH",   type="MAJOR" },
    { id=61742,  name=GetString(TAUNTTRACKER_MinorBreach),      short="BREACH",   type="MINOR" },
    { id=17906,  name=GetString(TAUNTTRACKER_Crusher),      	short="CRUSH",	  type="OTHER" },
    { id=75753,  name=GetString(TAUNTTRACKER_Alkosh),      		short="ALK",      type="SET"   },
    { id=106754, name=GetString(TAUNTTRACKER_MajorVulne), 		short="VUL",      type="CLASS" },
    { id=79717,  name=GetString(TAUNTTRACKER_MinorVulne), 		short="VUL",      type="MINOR" },
    { id=217358, name=GetString(TAUNTTRACKER_ThrowingKnife1),  	short="KMK",      type="SCRIB" },
    { id=31104,  name=GetString(TAUNTTRACKER_Engul),    		short="FLM",      type="CLASS" },
    { id=159288, name=GetString(TAUNTTRACKER_Crimson), 			short="CRIM",     type="SET"   },
	{ id=217353, name=GetString(TAUNTTRACKER_ThrowingKnife2),   short="KSTATE",   type="SCRIB" },
}
local DEBUFF_LIST = TT.DEBUFF_LIST

local debuffById = {}
for _, d in ipairs(DEBUFF_LIST) do
    debuffById[d.id] = d
end

-- ============================================================
--  MISE EN PAGE PILLS
-- ============================================================

local PILL_PAD = 5
local PILL_GAP = 3

-- Exposé pour TargetTracker
function TT.GetPillWidth(short, fontSize)
    local charW = math.max(5, math.floor(fontSize * 0.60))
    return zo_strlen(short) * charW + PILL_PAD * 2
end
local GetPillWidth = TT.GetPillWidth

-- Cache du texte des pills : évite sv["short_"..id] à chaque rendu.
-- Invalidé via InvalidateShortCache() quand les settings changent.
local shortCache = {}
local function InvalidateShortCache() shortCache = {} end
TT.InvalidateShortCache = InvalidateShortCache

local function GetShort(cfg)
    local cached = shortCache[cfg.id]
    if cached then return cached end
    local sv     = TauntTrackerSettings
    local custom = sv and sv["short_" .. cfg.id]
    local result = (custom and custom ~= "") and custom or (cfg.short or "?")
    shortCache[cfg.id] = result
    return result
end

-- Cache de la chaîne de font pour les pills.
-- Reconstruit seulement quand fontSize change.
local cachedPillFont     = nil
local cachedPillFontSize = nil
local function GetPillFont(fontSize)
    if fontSize ~= cachedPillFontSize then
        cachedPillFont     = "$(BOLD_FONT)|" .. fontSize .. "|outline-soft-shadow-thick"
        cachedPillFontSize = fontSize
    end
    return cachedPillFont
end

-- ============================================================
--  STATE — activeDebuffs exposé pour TargetTracker
--
--  [targetKey][abilityId] = true
--  [targetKey]._lastSeen  = timestamp (nettoyage de sécurité)
--  [targetKey]._name      = nom affiché de la cible
-- ============================================================

TT.activeDebuffs = {}
local activeDebuffs = TT.activeDebuffs

-- pillControls indexé par b.index (entier stable) au lieu de tostring(b.cont).
-- Évite une allocation de string à chaque appel de RenderDebuffsForBar.
local pillControls = {}  -- [barIndex] = { pill, ... }

-- Deux tables réutilisables séparées :
-- activeResult  → utilisée par GetActiveDebuffsForKey (appelée par ComputeDebuffRowCount)
-- renderResult  → utilisée par GetActiveDebuffsForRender (appelée par RenderDebuffsForBar)
local activeResult = {}
local renderResult = {}

-- ============================================================
--  SETTINGS
-- ============================================================

local function GetDebuffDefaults()
    local defaults = {
        showDebuffs    = true,
        debuffFontSize = 14,
        pillHeight     = 20,
    }
	for _, d in ipairs(DEBUFF_LIST) do
		defaults["debuff_" .. d.id] = true
		defaults["short_" .. d.id] = d.short
	end
    -- Couleurs par défaut pour chaque type
    for typeName, col in pairs(COLOR_DEFAULTS) do
        defaults["color_" .. typeName .. "_r"] = col.r
        defaults["color_" .. typeName .. "_g"] = col.g
        defaults["color_" .. typeName .. "_b"] = col.b
    end
    return defaults
end

-- Exposé pour TargetTracker
function TT.IsDebuffEnabled(id)
    local sv  = TauntTrackerSettings
    local key = "debuff_" .. tostring(id)
    if sv[key] == nil then return true end
    return sv[key]
end
local IsDebuffEnabled = TT.IsDebuffEnabled

-- ============================================================
--  HELPER — liste des configs actives pour une cible
--  Exposé pour TargetTracker.
--  Réutilise activeResult pour éviter une allocation par appel.
--  À consommer immédiatement — ne pas stocker la référence.
-- ============================================================

-- Previews statiques (alloués une seule fois)
local PREVIEW_DEBUFFS = nil  -- initialisé au premier appel

local function FillResultTable(t, key)
    local n = #t
    for i = 1, n do t[i] = nil end
    local debuffs = activeDebuffs[key]
    if debuffs then
        for id in pairs(debuffs) do
            if id ~= "_lastSeen" and id ~= "_name" then
                local cfg = debuffById[id]
                if cfg and IsDebuffEnabled(id) then
                    t[#t + 1] = cfg
                end
            end
        end
    end
    return t
end

function TT.GetActiveDebuffsForKey(key)
    if key and key:sub(1, 7) == "preview" then
        if not PREVIEW_DEBUFFS then
            PREVIEW_DEBUFFS = {
                { DEBUFF_LIST[1], DEBUFF_LIST[3], DEBUFF_LIST[5], DEBUFF_LIST[7] },
                { DEBUFF_LIST[2], DEBUFF_LIST[4], DEBUFF_LIST[6] },
                { DEBUFF_LIST[6], DEBUFF_LIST[8], DEBUFF_LIST[1], DEBUFF_LIST[9] },
            }
        end
        local idx = tonumber(key:sub(-1)) or 1
        return PREVIEW_DEBUFFS[idx] or {}
    end
    return FillResultTable(activeResult, key)
end
local GetActiveDebuffsForKey = TT.GetActiveDebuffsForKey

-- Version séparée pour RenderDebuffsForBar — évite la collision avec activeResult
-- utilisé simultanément par ComputeDebuffRowCount dans le même tick.
local function GetActiveDebuffsForRender(key)
    if key and key:sub(1, 7) == "preview" then
        if not PREVIEW_DEBUFFS then return {} end
        local idx = tonumber(key:sub(-1)) or 1
        return PREVIEW_DEBUFFS[idx] or {}
    end
    return FillResultTable(renderResult, key)
end

-- ============================================================
--  CALCUL DU NOMBRE DE LIGNES
-- ============================================================

function TT.ComputeDebuffRowCount(key, bw)
    local sv = TauntTrackerSettings
    if not sv.showDebuffs then return 0 end

    local fontSize = sv.debuffFontSize or 14
    local active   = GetActiveDebuffsForKey(key)
    if #active == 0 then return 0 end

    local availW = bw - 4
    local x      = 0
    local rows   = 1

    for _, cfg in ipairs(active) do
        local pillW = GetPillWidth(GetShort(cfg), fontSize)
        if x > 0 and (x + pillW) > availW then
            rows = 2
            break
        end
        x = x + pillW + PILL_GAP
    end

    return rows
end

-- ============================================================
--  RENDU DES PILLS — exposé pour TargetTracker
--
--  b doit contenir : b.debuffRow, b.cont
-- ============================================================

-- Table réutilisable pour le layout des pills — allouée une seule fois
local _layout = {}

function TT.RenderDebuffsForBar(b, key, bw, bh)
    local sv      = TauntTrackerSettings
    -- Utilise b.index (entier) au lieu de tostring(b.cont) pour éviter l'allocation string
    local barIdx  = b.index
    pillControls[barIdx] = pillControls[barIdx] or {}
    local pills = pillControls[barIdx]

    local function hideAll()
        b.debuffRow:SetHidden(true)
        for _, p in ipairs(pills) do
            if p and p.cont then p.cont:SetHidden(true) end
        end
    end

    if not sv.showDebuffs then hideAll(); return end

    local fontSize = sv.debuffFontSize or 14
    local pillH    = sv.pillHeight or 20
    local active   = GetActiveDebuffsForRender(key)

    local availW = bw - 4

    -- Réutilisation de _layout : vider sans réallouer
    local nl = #_layout
    for i = 1, nl do _layout[i] = nil end
    nl = 0  -- reset après vidage, les nouveaux items partent de l'index 1

    local x, row = 0, 1

    for _, cfg in ipairs(active) do
        local txt   = GetShort(cfg)
        local pillW = GetPillWidth(txt, fontSize)
        if row == 1 and x > 0 and (x + pillW) > availW then
            row = 2; x = 0
        end
        if not (row == 2 and x > 0 and (x + pillW) > availW) then
            nl = nl + 1
            _layout[nl] = { cfg=cfg, text=txt, pillW=pillW, x=x, row=row }
            x = x + pillW + PILL_GAP
        end
    end

    local numRows = (row == 2) and 2 or 1
    local rowsH   = numRows * pillH + (numRows - 1) * PILL_GAP

    b.debuffRow:SetHidden(false)
    b.debuffRow:SetDimensions(availW, rowsH)

    local wm      = WINDOW_MANAGER
    local fontStr = GetPillFont(fontSize)  -- string cachée, pas reconstruite à chaque tick

    for slot = 1, nl do
        local item = _layout[slot]
        local cfg  = item.cfg
        local col  = COLORS[cfg.type]
        if not col or not col.r then col = COLORS.OTHER end
        local yPos = (item.row - 1) * (pillH + PILL_GAP)

        if not pills[slot] then
            local cont = wm:CreateControl(nil, b.debuffRow, CT_CONTROL)
            local bg   = wm:CreateControl(nil, cont, CT_BACKDROP)
            local lbl  = wm:CreateControl(nil, cont, CT_LABEL)
            bg:SetAnchorFill(cont)
            bg:SetEdgeTexture("", 2, 1, 1)
            bg:SetInsets(1, 1, -1, -1)
            lbl:SetAnchorFill(cont)
            lbl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            lbl:SetVerticalAlignment(TEXT_ALIGN_CENTER)
            pills[slot] = {
                cont     = cont,
                bg       = bg,
                lbl      = lbl,
                lastText = nil,
                -- Cache géométrie et couleur
                lastX    = nil,
                lastY    = nil,
                lastW    = nil,
                lastH    = nil,
                lastFont = nil,
                lastCR   = nil,
                lastCG   = nil,
                lastCB   = nil,
            }
        end

        local p = pills[slot]

        -- Font — uniquement si changée
        if p.lastFont ~= fontStr then
            p.lbl:SetFont(fontStr)
            p.lastFont = fontStr
        end

        -- Géométrie — uniquement si changée
        if p.lastX ~= item.x or p.lastY ~= yPos or p.lastW ~= item.pillW or p.lastH ~= pillH then
            p.cont:ClearAnchors()
            p.cont:SetAnchor(TOPLEFT, b.debuffRow, TOPLEFT, item.x, yPos)
            p.cont:SetDimensions(item.pillW, pillH)
            p.lastX = item.x; p.lastY = yPos; p.lastW = item.pillW; p.lastH = pillH
        end

        -- Couleur — uniquement si changée (ne change qu'en cas de RefreshColors)
        if p.lastCR ~= col.r or p.lastCG ~= col.g or p.lastCB ~= col.b then
            p.bg:SetCenterColor(col.r * 0.20, col.g * 0.20, col.b * 0.20, 0.92)
            p.bg:SetEdgeColor(col.r, col.g, col.b, 1.00)
            p.lbl:SetColor(col.r, col.g, col.b, 1)
            p.lastCR = col.r; p.lastCG = col.g; p.lastCB = col.b
        end

        -- Texte
        if p.lastText ~= item.text then
            p.lbl:SetText(item.text or "")
            p.lastText = item.text
        end

        p.cont:SetHidden(false)
    end

    for i = nl + 1, #pills do
        if pills[i] and pills[i].cont then pills[i].cont:SetHidden(true) end
    end
end

-- ============================================================
--  TRACKING VIA EVENT_EFFECT_CHANGED
-- ============================================================

local function OnEffectChanged(_, changeType, _, _, _,
    _, _, _, _, _, _, _, _, unitName, unitId, abilityId)

    local cfg = debuffById[abilityId]
    if not cfg or not unitName or unitName == "" then return end

    local key = TT.MakeKey(unitId, unitName)
    if not key then return end

    if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
        activeDebuffs[key]              = activeDebuffs[key] or {}
        activeDebuffs[key][abilityId]   = true
        activeDebuffs[key]._lastSeen    = GetGameTimeMilliseconds()
        -- Stocke le nom pour que TargetTracker puisse l'afficher sans unitTag
        if not activeDebuffs[key]._name or activeDebuffs[key]._name == "?" then
            -- zo_strformat peut injecter des marqueurs grammaticaux (^f, ^m...)
            -- qui s'affichent comme □ dans TargetTracker — on les supprime ici.
            local formatted = zo_strformat("<<1>>", unitName)
            activeDebuffs[key]._name = formatted:gsub("%^[a-zA-Z]", "")
        end

    elseif changeType == EFFECT_RESULT_FADED then
        if activeDebuffs[key] then
            activeDebuffs[key][abilityId] = nil
            -- Vérifie si au moins un debuff reste
            local any = false
            for id in pairs(activeDebuffs[key]) do
                if id ~= "_lastSeen" and id ~= "_name" then
                    any = true; break
                end
            end
            if not any then
                activeDebuffs[key] = nil
            end
        end
    end
end

-- ============================================================
--  NETTOYAGE — purement time-based, indépendant des taunts
-- ============================================================

local function Cleanup()
    local now = GetGameTimeMilliseconds()
    for key, debuffs in pairs(activeDebuffs) do
        local ls = debuffs._lastSeen or 0
        if (now - ls) > 30000 then
            activeDebuffs[key] = nil
        end
    end
end

-- ============================================================
--  OPTIONS LAM
-- ============================================================

TT.RegisterOptions(function()
    local opts = {
        { type = "divider" },
        { type = "header", name = "|cFF8844"..GetString(TAUNTTRACKER_TITTLE2).."|r" },
        {
            type    = "checkbox",
            name    = GetString(TAUNTTRACKER_DEBUFF),
            tooltip = GetString(TAUNTTRACKER_DEBUFFTOOL),
            getFunc = function() return TauntTrackerSettings.showDebuffs end,
            setFunc = function(v)
                TauntTrackerSettings.showDebuffs = v
                if TT.UpdateUI then TT.UpdateUI() end
            end,
        },
        {
            type    = "slider",
            name    = GetString(TAUNTTRACKER_CELL),
            min=14, max=40, step=1,
            getFunc = function() return TauntTrackerSettings.pillHeight or 20 end,
            setFunc = function(v)
                TauntTrackerSettings.pillHeight = v
                if TT.UpdateUI then TT.UpdateUI() end
            end,
        },
        {
            type    = "slider",
            name    = GetString(TAUNTTRACKER_TEXTCELL),
            tooltip = GetString(TAUNTTRACKER_TEXTCELLTOOL),
            min=10, max=28, step=1,
            getFunc = function() return TauntTrackerSettings.debuffFontSize or 14 end,
            setFunc = function(v)
                TauntTrackerSettings.debuffFontSize = v
                if TT.UpdateUI then TT.UpdateUI() end
            end,
        },
        { type = "divider" },
        { type = "header", name = "|cFFCC44"..GetString(TAUNTTRACKER_TITTLE3).."|r" },
    }

    -- Ordre d'affichage fixe avec labels courts
    local TYPE_ORDER = { "MAJOR", "MINOR", "SET", "SCRIB", "OTHER", "CLASS" }
    local TYPE_LABELS = {
        MAJOR = "Major  (ex: Major Breach)",
        MINOR = "Minor  (ex: Minor Breach)",
        SET   = "Set    (ex: Alkosh)",
        SCRIB = "Scribing (ex: Throwing Knife MK)",
        OTHER = "Autre  (ex: Crusher)",
        CLASS = "Classe (ex: Major Vulnerability)",
    }

    for _, typeName in ipairs(TYPE_ORDER) do
        local tn = typeName
        table.insert(opts, {
            type    = "colorpicker",
            name    = TYPE_LABELS[tn] or tn,
            getFunc = function()
                local sv  = TauntTrackerSettings
                local def = COLOR_DEFAULTS[tn]
                return sv["color_" .. tn .. "_r"] or def.r,
                       sv["color_" .. tn .. "_g"] or def.g,
                       sv["color_" .. tn .. "_b"] or def.b,
                       1
            end,
            setFunc = function(r, g, b, a)
                local sv = TauntTrackerSettings
                sv["color_" .. tn .. "_r"] = r
                sv["color_" .. tn .. "_g"] = g
                sv["color_" .. tn .. "_b"] = b
                RefreshColors()
                if TT.UpdateUI then TT.UpdateUI() end
            end,
        })
    end

    table.insert(opts, {
        type    = "button",
        name    = GetString(TAUNTTRACKER_RESETCOLOR),
        tooltip = GetString(TAUNTTRACKER_RESETCOLORTOOL),
        func    = function()
            local sv = TauntTrackerSettings
            for typeName, col in pairs(COLOR_DEFAULTS) do
                sv["color_" .. typeName .. "_r"] = col.r
                sv["color_" .. typeName .. "_g"] = col.g
                sv["color_" .. typeName .. "_b"] = col.b
            end
            RefreshColors()
            if TT.UpdateUI then TT.UpdateUI() end
        end,
    })

    -- ── LISTE DES DEBUFFS ─────────────────────────────────────
    -- Un sous-bloc par debuff : nom coloré + checkbox + editbox texte pill
    table.insert(opts, { type = "divider" })
    table.insert(opts, { type = "header", name = "|cCCCCCC"..GetString(TAUNTTRACKER_TITTLE4).."|r" })
    table.insert(opts, {
        type  = "description",
        title = "",
        text  = GetString(TAUNTTRACKER_TEXT),
    })

    for _, d in ipairs(DEBUFF_LIST) do
        local id      = d.id
        local colType = d.type or "OTHER"

        -- Couleur de la catégorie au moment de la construction du menu
        local col = COLORS[colType] or COLORS.OTHER
        local hex = string.format("%02X%02X%02X",
            math.floor((col.r or 1) * 255),
            math.floor((col.g or 1) * 255),
            math.floor((col.b or 1) * 255)
        )

        -- Sous-header coloré avec le nom du debuff
        table.insert(opts, {
            type  = "description",
            title = string.format("|c%s● %s|r", hex, d.name),
            text  = "",
        })

        -- Checkbox activer/désactiver
        table.insert(opts, {
            type    = "checkbox",
            name    = GetString(TAUNTTRACKER_ACT),
            tooltip = string.format("%s %s (ID: %d).", GetString(TAUNTTRACKER_ACTTOOL), d.name, id),
            getFunc = function() return IsDebuffEnabled(id) end,
            setFunc = function(v)
                TauntTrackerSettings["debuff_" .. id] = v
                if TT.UpdateUI then TT.UpdateUI() end
            end,
        })

        -- Editbox texte pill
        table.insert(opts, {
            type        = "editbox",
            name        = GetString(TAUNTTRACKER_TEXTPILL),
            tooltip     = GetString(TAUNTTRACKER_TEXTPILLTOOL),
            getFunc     = function()
                return TauntTrackerSettings["short_" .. id] or d.short or ""
            end,
            setFunc     = function(value)
                TauntTrackerSettings["short_" .. id] = (value ~= "") and value or d.short
                InvalidateShortCache()
                if TT.UpdateUI then TT.UpdateUI() end
            end,
            isMultiline = false,
            width       = "full",
        })
    end

    return opts
end)

-- ============================================================
--  INIT
-- ============================================================

local function OnLoaded(_, addonName)
    if addonName ~= TT.name then return end

    local sv       = TauntTrackerSettings
    local defaults = GetDebuffDefaults()
    for k, v in pairs(defaults) do
        if sv[k] == nil then sv[k] = v end
    end

    -- S'assure que COLORS est à jour avec les valeurs sauvegardées
    RefreshColors()

    EVENT_MANAGER:RegisterForEvent(
        TT.name .. "_debuffs",
        EVENT_EFFECT_CHANGED,
        OnEffectChanged
    )

    EVENT_MANAGER:RegisterForUpdate(
        TT.name .. "_debuffs_clean",
        5000,
        Cleanup
    )
end

EVENT_MANAGER:RegisterForEvent(
    TT.name .. "_debuffs_init",
    EVENT_ADD_ON_LOADED,
    OnLoaded
)
