-- =====================================================================
--  BurstSync
--  Author : Eyr0n
--  Aligne ton burst : tu coches tes sorts, l'addon connait le delai
--  clic -> impact de chacun, en deduit l'ordre et te dit QUAND cliquer
--  pour que tout atterrisse au meme instant T.
-- =====================================================================

local ADDON_NAME = "BurstSync"
local EM = EVENT_MANAGER
local WM = WINDOW_MANAGER
local GCD = 1.0
local BURST_COLOR = { 1.0, 0.90, 0.20 }

local BT = {}
BT.name = ADDON_NAME
_G[ADDON_NAME] = BT

-- ---------------------------------------------------------------------
-- Localisation (FR / EN, fallback EN)
-- ---------------------------------------------------------------------
local STR = {
    en = {
        DESC        = "Tick the spells YOU have in your kit. The addon knows each spell's cast-to-impact delay, works out the order and tells you when to press so everything lands together. The ticked spell with the longest impact is your trigger (it must be on your bar). Re-pressing the trigger restarts the sequence.",
        TEST        = "Test (demo)",
        H_DISPLAY   = "Display",
        ENABLE      = "Enabled",
        SHOW_LABEL  = "Show spell name",
        SHOW_BURST  = "BURST marker at impact",
        HIDE_BAR    = "Hide bar (keep the timer running)",
        LOCK_POS    = "Lock position",
        WIDTH       = "Width",
        HEIGHT      = "Height",
        H_SPELLS    = "My spells (tick the ones in your kit)",
        SPELLS_HINT = "Tick your spells, grouped by class. Each spell has its own bar colour, editable below it.",
        IMPACT_FMT  = "%s -- impact %gs",
        VAR_LABEL   = "    impact (s)",
        COLOR_LBL   = "    colour",
        MOVE_ME     = "Move me",
        M_LOCKED    = "locked.",
        M_UNLOCKED  = "unlocked. Move it, then /burstsync lock.",
        M_DEMO      = "demo.",
        M_BURST_AT  = "BURST at T = %gs",
        M_LINE      = "   press %.1fs -> %s (impact %gs)",
        M_NONE      = "no spell ticked.",
        M_RECENTER  = "position re-centered.",
        M_ON        = "enabled.",
        M_OFF       = "disabled.",
        M_SCAN      = "current bar (slot : id  name):",
        HELP = {
            "BurstSync:",
            "  /burstsync test    -> visual demo",
            "  /burstsync list    -> show computed order/timings",
            "  /burstsync scan    -> print abilityId of each slotted skill",
            "  /burstsync unlock  -> move the bar    /burstsync lock",
            "  /burstsync reset   -> re-center",
            "  /burstsync on/off  -> enable / disable",
        },
    },
    fr = {
        DESC        = "Coche les sorts que TU as dans ton kit. L'addon connait le delai clic->impact de chacun, en deduit l'ordre et te dit quand cliquer pour que tout atterrisse ensemble. Le sort coche au plus long impact est ton declencheur (il doit etre dans ta barre). Re-cliquer le declencheur relance la sequence.",
        TEST        = "Tester (demo)",
        H_DISPLAY   = "Affichage",
        ENABLE      = "Active",
        SHOW_LABEL  = "Afficher le nom du sort",
        SHOW_BURST  = "Marqueur BURST a l'impact",
        HIDE_BAR    = "Masquer la barre (garder le timer actif)",
        LOCK_POS    = "Verrouiller la position",
        WIDTH       = "Largeur",
        HEIGHT      = "Hauteur",
        H_SPELLS    = "Mes sorts (coche ceux de ton kit)",
        SPELLS_HINT = "Coche tes sorts, regroupes par classe. Chaque sort a sa propre couleur de barre, modifiable en dessous.",
        IMPACT_FMT  = "%s -- impact %gs",
        VAR_LABEL   = "    impact (s)",
        COLOR_LBL   = "    couleur",
        MOVE_ME     = "Deplace-moi",
        M_LOCKED    = "verrouillee.",
        M_UNLOCKED  = "deverrouillee. Deplace-la puis /burstsync lock.",
        M_DEMO      = "demo.",
        M_BURST_AT  = "BURST a T = %gs",
        M_LINE      = "   clic %.1fs -> %s (impact %gs)",
        M_NONE      = "aucun sort coche.",
        M_RECENTER  = "position recentree.",
        M_ON        = "active.",
        M_OFF       = "desactive.",
        M_SCAN      = "barre actuelle (slot : id  nom):",
        HELP = {
            "BurstSync :",
            "  /burstsync test    -> demo visuelle",
            "  /burstsync list    -> affiche l'ordre/timings calcules",
            "  /burstsync scan    -> affiche l'abilityId de chaque sort en barre",
            "  /burstsync unlock  -> deplacer la barre    /burstsync lock",
            "  /burstsync reset   -> recentrer",
            "  /burstsync on/off  -> activer / desactiver",
        },
    },
}
local L

local function msg(s) d("BurstSync : " .. s) end

-- ---------------------------------------------------------------------
-- MASTER LIST
-- ---------------------------------------------------------------------
-- Trois types d'impact possibles par entree :
--   * impact = N            -> impact fixe
--   * variants = {a, b, ..} -> l'utilisateur choisit la valeur (dropdown)
--   * slider = {min, max, step} -> l'utilisateur regle une valeur (slider)
-- variants/slider utilisent `default` comme valeur initiale.
--
-- `id`  = id canonique (cle des SavedVars : checked / variant / slider).
-- `ids` = liste optionnelle de tous les ids acceptes a la detection
--         (morphs freres) ; si absent, seul `id` est accepte.
--
-- CODE COULEUR PAR CLASSE (la couleur = la classe ; chaque sort est une
-- NUANCE distincte du ton de sa classe, le nom sur la barre dit lequel) :
--   Dragonknight  orange         ~{ 0.95, 0.45, 0.10 }
--   Templar       jaune          ~{ 1.00, 0.80, 0.12 }
--   Arcanist      vert flashy    ~{ 0.30, 0.95, 0.35 }
--   Warden        vert fonce     ~{ 0.13, 0.52, 0.22 }
--   Necromancer   violet         ~{ 0.60, 0.25, 0.85 }
--   Sorcerer      bleu-mauve     ~{ 0.48, 0.45, 0.96 }
--   Nightblade    rouge          ~{ 0.90, 0.20, 0.22 }   (aucun sort pour l'instant)
--   Scribing      argent/pale    ~{ 0.86, 0.88, 0.94 }   (neutre, hors classe)
--   Misc          cyan           ~{ 0.20, 0.80, 0.88 }   (hors classe)
-- ---------------------------------------------------------------------
local MASTER = {
    { id = 86015,  name = "Deep Fissure",               class = "Warden",       variants = { 3, 9 },          default = 9,   color = { 0.10, 0.42, 0.18 } }, -- Warden vert fonce
    { id = 86019,  name = "Subterranean Assault",       class = "Warden",       variants = { 3, 6 },          default = 6,   color = { 0.20, 0.64, 0.32 } }, -- Warden vert fonce (clair)
    { id = 61500,  name = "Proximity Detonation",       class = "Misc",          impact = 8,                                  color = { 0.12, 0.66, 0.80 } }, -- Misc cyan (fonce)
    { id = 61491,  name = "Inevitable Detonation",      class = "Misc",          impact = 4,                                  color = { 0.45, 0.90, 0.95 } }, -- Misc cyan (clair)
    { id = 21763,  name = "Power of the Light / Purifying Light", class = "Templar", ids = { 21763, 21765 }, impact = 6,       color = { 1.00, 0.80, 0.12 } }, -- Templar jaune -- 2 morphs
    { id = 182988, name = "Fulminating Rune",           class = "Arcanist",     impact = 6,                                  color = { 0.20, 0.82, 0.28 } }, -- Arcanist vert flashy (fonce)
    { id = 32853,  name = "Incinerate",                 class = "Dragonknight", variants = { 5, 10, 15 },     default = 5,   color = { 0.88, 0.36, 0.04 } }, -- DK orange (fonce)
    { id = 32792,  name = "Soul of Flame / Heart of Flame", class = "Dragonknight", ids = { 32792, 32785 }, impact = 4.5,     color = { 1.00, 0.58, 0.22 } }, -- DK orange (clair) -- 2 morphs
    { id = 117960, name = "Blast Bones",                class = "Necromancer",  slider = { min = 2, max = 8, step = 1 }, default = 4, color = { 0.60, 0.25, 0.85 } }, -- Necro violet
    { id = 24330,  name = "Haunting Curse",             class = "Sorcerer",     variants = { 3.5, 12 },       default = 3.5, color = { 0.58, 0.36, 0.96 } }, -- Sorc bleu-mauve (mauve)
    { id = 24328,  name = "Daedric Prey",               class = "Sorcerer",     impact = 6,                                  color = { 0.70, 0.50, 1.00 } }, -- Sorc bleu-mauve (mauve clair)
    { id = 217979, name = "Detonating Attraction",      class = "Scribing",     impact = 2,                                  color = { 0.95, 0.96, 0.99 } }, -- Scribing argent (blanc)
    { id = 217228, name = "Elemental Explosion",        class = "Scribing",     impact = 2,                                  color = { 0.80, 0.82, 0.90 } }, -- Scribing argent (moyen)
    { id = 24165,  name = "Bound Armaments",            class = "Sorcerer",     variants = { 0.3, 0.6, 0.9, 1.2 }, default = 1.2, color = { 0.32, 0.42, 1.00 } }, -- Sorc bleu-mauve (bleu)
    { id = 46331,  name = "Crystal Weapon",             class = "Sorcerer",     slider = { min = 1, max = 6, step = 1 }, default = 3, color = { 0.55, 0.70, 1.00 } }, -- Sorc bleu-mauve (bleu clair)
    { id = 19123,  name = "Mage's / Endless Fury",      class = "Sorcerer",     ids = { 19123, 19109 }, impact = 2,          color = { 0.42, 0.34, 0.86 } }, -- Sorc bleu-mauve (fonce) -- 2 morphs
    { id = 222678, name = "Ulfsild's Contingency",      class = "Scribing",     impact = 1,                                  color = { 0.64, 0.68, 0.80 } }, -- Scribing argent (fonce)
    { id = 183267, name = "Rune of the Colorless Pool", class = "Arcanist",     impact = 1,                                  color = { 0.55, 1.00, 0.55 } }, -- Arcanist vert flashy (clair)
}

local defaults = {
    enabled = true, locked = true, showLabel = true, showBurst = true, hideBar = false,
    left = nil, top = nil, width = 320, height = 26,
    checked = {},
    variant = {},   -- [id] = valeur choisie pour les sorts a variantes
    slider  = {},   -- [id] = valeur reglee pour les sorts a slider
    color   = {},   -- [id] = couleur de barre personnalisee {r,g,b}
}

local sv
local ui  = {}
local seq = { active = false }

local function SpellName(e)
    local n = GetAbilityName(e.id)
    if n and n ~= "" then return n end
    return e.name
end

-- impact effectif d'une entree selon son type / le choix du joueur
local function EffectiveImpact(e)
    if e.variants then
        return sv.variant[e.id] or e.default or e.variants[1]
    elseif e.slider then
        return sv.slider[e.id] or e.default or e.slider.min
    end
    return e.impact
end

-- couleur effective : surcharge utilisateur sinon couleur par defaut
local function EffectiveColor(e)
    local c = sv.color[e.id]
    if c then return c end
    return e.color
end

-- =====================================================================
-- UI : barre
-- =====================================================================
local function ApplyDims()
    if not ui.tlw then return end
    ui.tlw:SetDimensions(sv.width, sv.height)
    ui.fill:SetHeight(sv.height - 4)
    ui.fill:SetWidth(sv.width - 4)
end

local function BuildUI()
    local tlw = WM:CreateTopLevelWindow(ADDON_NAME .. "_TLW")
    tlw:SetDimensions(sv.width, sv.height)
    tlw:SetClampedToScreen(true)
    tlw:SetMovable(not sv.locked)
    tlw:SetMouseEnabled(not sv.locked)
    tlw:SetHidden(true)
    if sv.left and sv.top then
        tlw:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.left, sv.top)
    else
        tlw:SetAnchor(CENTER, GuiRoot, CENTER, 0, -150)
    end
    tlw:SetHandler("OnMoveStop", function() sv.left, sv.top = tlw:GetLeft(), tlw:GetTop() end)

    local bg = WM:CreateControl(ADDON_NAME .. "_BG", tlw, CT_BACKDROP)
    bg:SetAnchorFill(tlw)
    bg:SetCenterColor(0, 0, 0, 0.6)
    bg:SetEdgeColor(0, 0, 0, 0.9)

    local fill = WM:CreateControl(ADDON_NAME .. "_FILL", tlw, CT_BACKDROP)
    fill:SetAnchor(CENTER, tlw, CENTER, 0, 0)
    fill:SetDimensions(sv.width - 4, sv.height - 4)
    fill:SetCenterColor(1, 1, 1, 0.9)
    fill:SetEdgeColor(0, 0, 0, 0)

    local label = WM:CreateControl(ADDON_NAME .. "_LABEL", tlw, CT_LABEL)
    label:SetFont("ZoFontWinH2")
    label:SetAnchor(CENTER, tlw, CENTER, 0, 0)
    label:SetColor(1, 1, 1, 1)
    label:SetText("")
    label:SetDrawLayer(2)

    ui.tlw, ui.bg, ui.fill, ui.label = tlw, bg, fill, label
end

local function SetBarColor(c) ui.fill:SetCenterColor(c[1], c[2], c[3], 0.9) end

-- =====================================================================
-- Scheduler des sorts
-- =====================================================================
local function BuildActiveCues()
    local cues = {}
    for _, e in ipairs(MASTER) do
        if sv.checked[e.id] then
            cues[#cues + 1] = { id = e.id, impact = EffectiveImpact(e), color = EffectiveColor(e), name = SpellName(e) }
        end
    end
    table.sort(cues, function(a, b) return a.impact > b.impact end)
    local T = (cues[1] and cues[1].impact) or 0
    for _, c in ipairs(cues) do c.castTime = T - c.impact end
    -- garde-fou GCD : si deux cues tombent sur le meme cue, ecarter d'1 s
    for i = 2, #cues do
        if cues[i].castTime < cues[i - 1].castTime + GCD then
            cues[i].castTime = cues[i - 1].castTime + GCD
        end
    end
    return cues, T
end

local function BuildSchedule(cues, T)
    local segs, n = {}, #cues
    for i = 1, n do
        local startT, nextC = cues[i].castTime, cues[i + 1]
        if nextC then
            segs[#segs + 1] = { startT = startT, endT = nextC.castTime, color = nextC.color, label = nextC.name }
        else
            segs[#segs + 1] = { startT = startT, endT = T, color = BURST_COLOR, label = "BURST", burst = true }
        end
    end
    if not sv.showBurst and #segs > 1 then segs[#segs] = nil end
    return segs
end

-- =====================================================================
-- Moteur
-- =====================================================================
local function OnUpdate()
    if not seq.active then return end
    local elapsed = (GetGameTimeMilliseconds() - seq.t0) / 1000
    local segs = seq.segs
    if elapsed >= seq.endTime then BT:Burst(); return end

    local cur, curIdx
    for i = 1, #segs do
        if elapsed < segs[i].endT then cur, curIdx = segs[i], i; break end
    end
    if not cur then BT:Stop(); return end

    if seq.curIdx ~= curIdx then
        seq.curIdx = curIdx
        SetBarColor(cur.color)
        ui.label:SetText(sv.showLabel and cur.label or "")
    end
    local dur  = cur.endT - cur.startT
    local frac = (dur > 0) and (cur.endT - elapsed) / dur or 0
    ui.fill:SetWidth(zo_max(2, frac * (sv.width - 4)))
end

local function Run(segs, endTime, T)
    EM:UnregisterForUpdate(ADDON_NAME .. "_Upd")
    seq.runId   = (seq.runId or 0) + 1
    seq.active  = true
    seq.t0      = GetGameTimeMilliseconds()
    seq.segs    = segs
    seq.endTime = endTime
    seq.curIdx  = 0
    ui.tlw:SetHidden(sv.hideBar)
    SetBarColor(segs[1].color)
    ui.label:SetText(sv.showLabel and segs[1].label or "")
    EM:RegisterForUpdate(ADDON_NAME .. "_Upd", 16, OnUpdate)
end

function BT:StartFromConfig()
    if not sv.enabled then return end
    local cues, T = BuildActiveCues()
    if #cues < 1 then return end
    local segs = BuildSchedule(cues, T)
    Run(segs, segs[#segs].endT, T)
end

function BT:Burst()
    EM:UnregisterForUpdate(ADDON_NAME .. "_Upd")
    if sv.showBurst then
        SetBarColor(BURST_COLOR)
        ui.fill:SetWidth(sv.width - 4)
        ui.label:SetText(sv.showLabel and "BURST" or "")
        seq.active = false
        local rid = seq.runId
        zo_callLater(function() if seq.runId == rid then BT:Stop() end end, 400)
    else
        BT:Stop()
    end
end

function BT:Stop()
    seq.active = false
    EM:UnregisterForUpdate(ADDON_NAME .. "_Upd")
    if sv.locked or sv.hideBar then ui.tlw:SetHidden(true) end
end

function BT:Demo()
    local cues = {
        { id = 0, impact = 4, color = { 0.20, 0.85, 0.90 }, name = "Trigger", castTime = 0 },
        { id = 0, impact = 3, color = { 0.72, 0.52, 0.88 }, name = "Sort 2",  castTime = 1 },
        { id = 0, impact = 1, color = { 1.00, 0.55, 0.10 }, name = "Sort 3",  castTime = 3 },
    }
    local segs = BuildSchedule(cues, 4)
    Run(segs, segs[#segs].endT, 4)
end

-- =====================================================================
-- Detection du trigger (re-clic = restart)
-- =====================================================================
local function AcceptedIds(e)
    return e.ids or { e.id }
end

local function CurrentTriggerEntry()
    local best, bestImp
    for _, e in ipairs(MASTER) do
        if sv.checked[e.id] then
            local imp = EffectiveImpact(e)
            if not bestImp or imp > bestImp then
                best, bestImp = e, imp
            end
        end
    end
    return best
end

local function OnAbilityUsed(_, slotNum)
    if not sv.enabled then return end
    local trig = CurrentTriggerEntry()
    if not trig then return end
    local hb = GetActiveHotbarCategory and GetActiveHotbarCategory() or nil
    local id = hb and GetSlotBoundId(slotNum, hb) or GetSlotBoundId(slotNum)
    if not id then return end
    for _, tid in ipairs(AcceptedIds(trig)) do
        if id == tid then BT:StartFromConfig(); return end
    end
end

-- =====================================================================
-- Commandes /burstsync
-- =====================================================================
local function SlashHandler(arg)
    arg = (arg or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
    if arg == "lock" then
        sv.locked = true
        ui.tlw:SetMovable(false); ui.tlw:SetMouseEnabled(false)
        if not seq.active then ui.tlw:SetHidden(true) end
        msg(L.M_LOCKED)
    elseif arg == "unlock" then
        sv.locked = false
        ui.tlw:SetMovable(true); ui.tlw:SetMouseEnabled(true)
        ui.tlw:SetHidden(false)
        ui.fill:SetWidth(sv.width - 4)
        SetBarColor({ 0.5, 0.5, 0.5 })
        ui.label:SetText(L.MOVE_ME)
        msg(L.M_UNLOCKED)
    elseif arg == "test" then
        msg(L.M_DEMO); BT:Demo()
    elseif arg == "list" then
        local cues, T = BuildActiveCues()
        if #cues == 0 then msg(L.M_NONE); return end
        msg(string.format(L.M_BURST_AT, T))
        for _, c in ipairs(cues) do
            d(string.format(L.M_LINE, c.castTime, c.name, c.impact))
        end
    elseif arg == "scan" then
        msg(L.M_SCAN)
        local hb = GetActiveHotbarCategory and GetActiveHotbarCategory() or nil
        for slot = 3, 8 do
            local id = hb and GetSlotBoundId(slot, hb) or GetSlotBoundId(slot)
            if id and id ~= 0 then
                d(string.format("   %d : %d  %s", slot, id, GetAbilityName(id)))
            end
        end
    elseif arg == "reset" then
        sv.left, sv.top = nil, nil
        ui.tlw:ClearAnchors(); ui.tlw:SetAnchor(CENTER, GuiRoot, CENTER, 0, -150)
        msg(L.M_RECENTER)
    elseif arg == "on" then
        sv.enabled = true; msg(L.M_ON)
    elseif arg == "off" then
        sv.enabled = false; BT:Stop(); msg(L.M_OFF)
    else
        for _, line in ipairs(L.HELP) do d(line) end
    end
end

-- =====================================================================
-- Reglages (LibAddonMenu-2.0)
-- =====================================================================
local function BuildSettings()
    local LAM = LibAddonMenu2
    if not LAM then return end
    LAM:RegisterAddonPanel(ADDON_NAME .. "_LAM", {
        type = "panel", name = "BurstSync",
        author = "Eyr0n", version = "beta 1.0.0",
        registerForRefresh = true, registerForDefaults = true,
    })

    local options = {
        { type = "description", text = L.DESC },
        { type = "button", name = L.TEST, width = "half", func = function() BT:Demo() end },

        { type = "header", name = L.H_DISPLAY },
        { type = "checkbox", name = L.ENABLE,
          getFunc = function() return sv.enabled end, setFunc = function(v) sv.enabled = v end },
        { type = "checkbox", name = L.SHOW_LABEL,
          getFunc = function() return sv.showLabel end, setFunc = function(v) sv.showLabel = v end },
        { type = "checkbox", name = L.SHOW_BURST,
          getFunc = function() return sv.showBurst end, setFunc = function(v) sv.showBurst = v end },
        { type = "checkbox", name = L.HIDE_BAR,
          getFunc = function() return sv.hideBar end, setFunc = function(v) sv.hideBar = v end },
        { type = "checkbox", name = L.LOCK_POS,
          getFunc = function() return sv.locked end,
          setFunc = function(v)
              sv.locked = v
              ui.tlw:SetMovable(not v); ui.tlw:SetMouseEnabled(not v)
              if v and not seq.active then
                  ui.tlw:SetHidden(true)
              else
                  ui.tlw:SetHidden(false)
                  if not seq.active then
                      ui.fill:SetWidth(sv.width - 4)
                      SetBarColor({ 0.5, 0.5, 0.5 })
                  end
                  ui.label:SetText(L.MOVE_ME)
              end
          end },
        { type = "slider", name = L.WIDTH, min = 120, max = 600, step = 10,
          getFunc = function() return sv.width end, setFunc = function(v) sv.width = v; ApplyDims() end },
        { type = "slider", name = L.HEIGHT, min = 14, max = 60, step = 2,
          getFunc = function() return sv.height end, setFunc = function(v) sv.height = v; ApplyDims() end },

        { type = "header", name = L.H_SPELLS },
        { type = "description", text = L.SPELLS_HINT },
    }

    -- construit les controles d'un sort : case + reglage d'impact + couleur
    local function SpellControls(entry)
        local controls = {}
        if entry.variants or entry.slider then
            controls[#controls + 1] = {
                type = "checkbox", name = SpellName(entry),
                getFunc = function() return sv.checked[entry.id] == true end,
                setFunc = function(v) sv.checked[entry.id] = v end,
            }
        else
            controls[#controls + 1] = {
                type = "checkbox",
                name = string.format(L.IMPACT_FMT, SpellName(entry), entry.impact),
                getFunc = function() return sv.checked[entry.id] == true end,
                setFunc = function(v) sv.checked[entry.id] = v end,
            }
        end

        if entry.variants then
            local choices, values = {}, {}
            for _, val in ipairs(entry.variants) do
                choices[#choices + 1] = string.format("%g", val)
                values[#values + 1]  = val
            end
            controls[#controls + 1] = {
                type = "dropdown", name = L.VAR_LABEL, width = "half",
                choices = choices, choicesValues = values,
                disabled = function() return sv.checked[entry.id] ~= true end,
                getFunc = function() return sv.variant[entry.id] or entry.default or entry.variants[1] end,
                setFunc = function(v) sv.variant[entry.id] = v end,
            }
        elseif entry.slider then
            controls[#controls + 1] = {
                type = "slider", name = L.VAR_LABEL, width = "half",
                min = entry.slider.min, max = entry.slider.max, step = entry.slider.step,
                disabled = function() return sv.checked[entry.id] ~= true end,
                getFunc = function() return sv.slider[entry.id] or entry.default or entry.slider.min end,
                setFunc = function(v) sv.slider[entry.id] = v end,
            }
        else
            -- pas de reglage d'impact : cale a gauche pour que la couleur reste a droite
            controls[#controls + 1] = { type = "description", text = "", width = "half" }
        end

        controls[#controls + 1] = {
            type = "colorpicker", name = L.COLOR_LBL, width = "half",
            disabled = function() return sv.checked[entry.id] ~= true end,
            getFunc = function() local c = EffectiveColor(entry) return c[1], c[2], c[3], 1 end,
            setFunc = function(r, g, b) sv.color[entry.id] = { r, g, b } end,
        }
        return controls
    end

    -- ordre d'affichage des classes ; toute classe absente est ajoutee a la fin
    local CLASS_ORDER = { "Dragonknight", "Sorcerer", "Nightblade", "Templar", "Warden", "Necromancer", "Arcanist", "Scribing", "Misc" }
    local present, seen, ordered = {}, {}, {}
    for _, e in ipairs(MASTER) do present[e.class] = true end
    for _, cn in ipairs(CLASS_ORDER) do
        if present[cn] then ordered[#ordered + 1] = cn; seen[cn] = true end
    end
    for _, e in ipairs(MASTER) do
        if not seen[e.class] then seen[e.class] = true; ordered[#ordered + 1] = e.class end
    end

    -- un sous-menu repliable par classe
    for _, className in ipairs(ordered) do
        local sub = {}
        for _, e in ipairs(MASTER) do
            if e.class == className then
                for _, ctrl in ipairs(SpellControls(e)) do sub[#sub + 1] = ctrl end
            end
        end
        options[#options + 1] = { type = "submenu", name = className, controls = sub }
    end

    LAM:RegisterOptionControls(ADDON_NAME .. "_LAM", options)
end

-- =====================================================================
-- Init
-- =====================================================================
local function OnAddonLoaded(_, name)
    if name ~= ADDON_NAME then return end
    EM:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    local lang = GetCVar and GetCVar("language.2") or "en"
    L = STR[lang] or STR.en

    sv = ZO_SavedVars:NewAccountWide("BurstSyncSavedVars", 1, nil, defaults)
    sv.checked = sv.checked or {}
    sv.variant = sv.variant or {}
    sv.slider  = sv.slider  or {}
    sv.color   = sv.color   or {}

    BuildUI()
    ApplyDims()
    BuildSettings()

    EM:RegisterForEvent(ADDON_NAME, EVENT_ACTION_SLOT_ABILITY_USED, OnAbilityUsed)
    SLASH_COMMANDS["/burstsync"] = SlashHandler
    SLASH_COMMANDS["/bsync"]     = SlashHandler
end

EM:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
