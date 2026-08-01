TauntTracker = TauntTracker or {}
local TT = TauntTracker
 
TT.name    = "TauntTracker"
TT.version = "3.0.0"
TT.optionBuilders = {}
TT.optionsBuilt   = false
 
function TT.RegisterOptions(builderFunc)
    table.insert(TT.optionBuilders, builderFunc)
end
 
local function BuildAllOptions()
    local all = {}
    for _, builder in ipairs(TT.optionBuilders) do
        local opts = builder()
        if opts then
            for _, o in ipairs(opts) do table.insert(all, o) end
        end
    end
    return all
end
 
function TT.InitLAM()
    if TT.optionsBuilt then return end
    TT.optionsBuilt = true
    local LAM = LibAddonMenu2
    LAM:RegisterAddonPanel("TT_Panel", {
        type        = "panel",
        name        = "TauntTracker",
        displayName = "|c00FF88Taunt|cFFFF55Tracker|r",
        author      = "Tenshiraito",
        version     = TT.version,
    })
    LAM:RegisterOptionControls("TT_Panel", BuildAllOptions())
end
 
--------------------------------------------------
-- CONFIG
--------------------------------------------------
 
local TAUNT_IDS = {
    [28306] = true, -- Puncture
    [38250] = true, -- Ransack
    [38254] = true, -- Pierce Armor
    [39475] = true, -- Inner Fire
    [42056] = true, -- Inner Rage
    [42060] = true, -- Inner Beast
}
 
local TAUNT_DURATION = 15000
 
local GAIN_RESULTS = {
    [ACTION_RESULT_EFFECT_GAINED]          = true,
    [ACTION_RESULT_EFFECT_GAINED_DURATION] = true,
}
 
local PILL_GAP    = 3
local PILL_MARGIN = 2
 
--------------------------------------------------
-- STATE
--------------------------------------------------
 
local activeTaunts  = {}
local previewActive = false
local lastSend = lastSend or {}
 
TT.activeTaunts = activeTaunts
TT.bars         = {}
local bars = TT.bars
 
local window        = nil
local LTC           = nil
 
-- Table des suppressions différées (re-taunt rapide).
-- [key] = true quand un FADED est en attente de confirmation.
-- Annulé si GAINED arrive dans les 400ms suivantes.
local pendingFades    = {}
local lastBroadcast   = {}  -- [key] = timestamp du dernier BroadcastTaunt envoyé
 
local function CancelPendingFade(key)
    if key == nil then return end   -- ← ajouter cette ligne
    pendingFades[key] = nil
end
TT.CancelPendingFade = CancelPendingFade
local tauntCasterCache = {}
local groupNameCache   = {}
 
--------------------------------------------------
-- SETTINGS
--------------------------------------------------
 
local DEFAULT_SETTINGS = {
    windowX      = 800,
    windowY      = 300,
    locked       = false,
    barWidth     = 300,
    barHeight    = 18,
    fontSize     = 16,
    addonEnabled = true,
    bgAlpha      = 0.75,
    showBorder   = true,
    barGap       = 2,

    -- Couleurs background
    localTauntColorR   = 0.02,
    localTauntColorG   = 0.18,
    localTauntColorB   = 0.08,

    networkTauntColorR = 0.30,
    networkTauntColorG = 0.16,
    networkTauntColorB = 0.02,

    neutralColorR      = 0.05,
    neutralColorG      = 0.05,
    neutralColorB      = 0.05,
}
 
--------------------------------------------------
-- UTILS
--------------------------------------------------
 
local function CleanName(name)
    if not name or name == "" then return "?" end
    local result = zo_strformat("<<1>>", name)
    -- Supprime les marqueurs grammaticaux ESO (^f, ^m, ^M, ^N...) qui
    -- s'affichent comme des carrés (□) dans les labels CT_LABEL.
    -- Pattern greedy (+) : couvre ^M, ^f mais aussi les composés ^fpl, ^Mpl, ^Nb
    -- que le pattern [a-zA-Z] seul manquait, laissant "pl"/"b" visibles en carré.
    result = result:gsub("%^[a-zA-Z]+", "")
    return result
end
-- Exposée pour que NetworkSync et DebuffTracker puissent l'utiliser.
TT.CleanName = CleanName
 
local function TrimName(name, maxLen)
    if not name then return "?" end
    if zo_strlen(name) > maxLen then
        return zo_strsub(name, 1, maxLen) .. "..."
    end
    return name
end
 
-- Compare un nom stocké (potentiellement tronqué par TrimName ou SafeSub)
-- avec un nom complet. Retire le suffixe "..." de TrimName puis compare
-- sur le préfixe commun. Couvre les trois cas :
--   • Nom local court (≤18 chars) : stocké entier  → égalité stricte
--   • Nom local long  (>18 chars) : stocké + "..." → préfixe 18 chars
--   • Nom réseau      (≤10 chars) : stocké sans "..."→ préfixe 10 chars
local function NameMatch(storedName, fullNameLower)
    if not storedName or storedName == "" then return false end
    local s = storedName:lower():gsub("%.%.%.$", "")
    local sLen       = zo_strlen(s)
    local fullLen    = zo_strlen(fullNameLower)
    local minLen     = math.min(sLen, fullLen)
    return minLen > 0 and zo_strsub(s, 1, minLen) == zo_strsub(fullNameLower, 1, minLen)
end
 
-- Nettoie les entrées obsolètes dans activeTaunts avant d'en créer une nouvelle
-- sous `newKey`. Règles :
--   1. Toutes les entrées "n_..." (unitId=0) dont le nom correspond sont
--      supprimées — toujours redondantes face à une clé "i_...".
--   2. Les entrées "i_..." avec fromNetwork=true (unitId de l'allié) sont
--      supprimées si elles sont uniques → migration réseau→local.
--   3. Les entrées "i_..." avec fromNetwork=nil (locales) ne sont jamais
--      supprimées : un unitId local différent = mob physiquement différent.
local function PurgeStaleDuplicates(newKey, nameToFind)
    local netKey   = nil
    local netCount = 0
    for k, v in pairs(activeTaunts) do
        if NameMatch(v.targetName, nameToFind) then
            if k:sub(1, 2) == "n_" then
                -- Clé nom (unitId=0) → toujours redondante, suppression immédiate
                pendingFades[k] = nil
                activeTaunts[k] = nil
            elseif v.fromNetwork and k ~= newKey then
                -- Clé id réseau → stale si unique
                netKey   = k
                netCount = netCount + 1
            end
            -- Clé id locale (fromNetwork=nil) → intact, c'est peut-être un autre mob
        end
    end
    if netCount == 1 then
        return netKey  -- l'appelant récupère le casterName puis supprime
    end
    return nil
end
 
local function MakeKey(unitId, unitName)
    if unitId and unitId ~= 0 then
        return "i_" .. tostring(unitId)
    end
    if unitName and unitName ~= "" then
        return "n_" .. string.lower(zo_strformat("<<1>>", unitName))
    end
    return nil
end
 
TT.MakeKey = MakeKey
 
-- Cherche une entrée existante dans activeTaunts par targetName (insensible
-- à la casse) ou par clé directe. Utilisé par NetworkSync pour éviter les
-- doublons quand les unitId locaux diffèrent entre clients.
local function FindEntryKey(targetName, fallbackKey)
    -- Priorité 1 : fallbackKey (clé LGB de l'émetteur) correspond déjà à une
    -- entrée → mise à jour directe, pas besoin de chercher par nom.
    if fallbackKey and activeTaunts[fallbackKey] then
        return fallbackKey
    end

    -- Priorité 2 : migration d'une entrée RÉSEAU orpheline vers la clé LGB reçue.
    -- On ne regarde QUE les entrées fromNetwork=true.
    -- Raison : dans un trash pack (6 x "Goblin"), chaque mob est une entité
    -- physique différente. Si le joueur local taunt Goblin A (entrée locale,
    -- fromNetwork=nil) et qu'un allié taunt Goblin B, on NE DOIT PAS écraser
    -- l'entrée locale → on laisse fallbackKey créer une nouvelle entrée.
	if targetName and targetName ~= "" then
		local lower   = targetName:lower()
		local matched = nil
		local count   = 0

		for k, v in pairs(activeTaunts) do
			if v.targetName and NameMatch(v.targetName, lower) then
				count = count + 1
				matched = k

				-- plusieurs mobs identiques -> ambigu
				if count > 1 then
					matched = nil
					break
				end
			end
		end

		-- une seule entrée trouvée -> on fusionne
		if matched then
			return matched
		end
	end
end
TT.FindEntryKey = FindEntryKey
 
-- Reconstruit le cache @compte → nomPersonnage.
local function RebuildGroupCache()
    groupNameCache = {}
    local size = GetGroupSize and GetGroupSize() or 0
    for i = 1, size do
        local tag = "group" .. i
        if DoesUnitExist and DoesUnitExist(tag) then
            local dn   = GetUnitDisplayName and GetUnitDisplayName(tag)
            local char = GetUnitName and GetUnitName(tag)
            if dn and dn ~= "" and char and char ~= "" then
                groupNameCache[dn:lower()] = CleanName(char)
            end
        end
    end
end
 
TT.RebuildGroupCache = RebuildGroupCache
 
-- Définie une fois en dehors pour éviter l'allocation d'une closure à chaque appel.
local function SafePlayer()
    local n = GetUnitName and GetUnitName("player")
    return CleanName(n or "?")
end
 
local function ResolveCasterName(sourceName, sourceUnitId)
    if not sourceName or sourceName == "" then
        return SafePlayer()
    end
 
    local cleaned = CleanName(sourceName)
 
    -- Cas simple : nom de personnage déjà lisible (pas de @)
    if cleaned:sub(1, 1) ~= "@" then
        return cleaned
    end
 
    local lower = cleaned:lower()
 
    -- 1) Cache proactif
    if groupNameCache[lower] then
        return groupNameCache[lower]
    end
 
    -- 2) Scan du groupe à la volée (fallback)
    for i = 1, (GetGroupSize and GetGroupSize() or 0) do
        local tag = "group" .. i
        if DoesUnitExist and DoesUnitExist(tag) then
            local dn = GetUnitDisplayName and GetUnitDisplayName(tag)
            if dn and dn:lower() == lower then
                local char = GetUnitName(tag)
                if char and char ~= "" then
                    local resolved = CleanName(char)
                    groupNameCache[lower] = resolved
                    return resolved
                end
            end
        end
    end
 
    -- 3) @compte brut — mieux que "Unknown"
    return cleaned
end
 
-- Tente de trouver quel allié a taunt une unité donnée (unitId de la cible).
-- Stratégie : cherche un membre du groupe qui a cet ennemi comme cible courante.
-- C'est une heuristique — fiable en pratique en donjon/raid.
local function FindAllyWhoTargeted(targetUnitId)
    local size = GetGroupSize and GetGroupSize() or 0
    for i = 1, size do
        local tag = "group" .. i
        if DoesUnitExist and DoesUnitExist(tag) then
            -- Récupère l'unitId de la cible de ce membre
            local targetOfMember = GetUnitTargetUnitId and GetUnitTargetUnitId(tag)
            if targetOfMember and targetOfMember == targetUnitId then
                local char = GetUnitName and GetUnitName(tag)
                if char and char ~= "" then
                    return CleanName(char)
                end
            end
        end
    end
    return nil
end
 
local function ColorForRatio(r)
    if r > 0.55 then return 0.20, 0.85, 0.30, 1
    elseif r > 0.28 then return 0.95, 0.70, 0.10, 1
    else return 0.95, 0.20, 0.20, 1
    end
end
 
--------------------------------------------------
-- ENTRY HEIGHT
--------------------------------------------------
 
local function EntryHeight(bh, key, bw)
    local sv   = TauntTrackerSettings
    local base = 16 + bh
 
    local rows = 0
    if TT.ComputeDebuffRowCount then
        rows = TT.ComputeDebuffRowCount(key, bw)
    end
 
    if rows == 0 then return base end
 
    local pillH   = sv.pillHeight or 20
    local debuffH = rows * pillH + (rows - 1) * PILL_GAP + PILL_MARGIN + 2
    return base + debuffH
end
 
--------------------------------------------------
-- PREVIEW
--------------------------------------------------
 
local function GetPreviewEntries()
    local now = GetGameTimeMilliseconds()
    return {
        { casterName=GetString(TAUNTTRACKER_YOU),  targetName=GetString(TAUNTTRACKER_TARGET), beginTime=now-2000,  endTime=now+13000, key="preview_1" },
        { casterName="Altor", targetName="Olorime",        beginTime=now-8000,  endTime=now+4500,  key="preview_2", fromNetwork=true },
        { casterName="Mira",  targetName="Zhaj'hassa",     beginTime=now-13500, endTime=now+900,   key="preview_3", fromNetwork=true },
    }
end
 
--------------------------------------------------
-- UI
--------------------------------------------------
 
local function GetOrCreateBar(i)
    if bars[i] then return bars[i] end
 
    local wm   = WINDOW_MANAGER
    local cont = wm:CreateControl(nil, window, CT_CONTROL)
 
    -- ── Fond + bordure style gamepad ESO ──────────────────────
    -- Bord principal : or/ambre typique de l'UI gamepad ESO
    local GR, GG, GB = 0.78, 0.64, 0.34  -- or ESO
    local HR, HG, HB = 0.97, 0.87, 0.55  -- highlight coins
    local CL, CW = 8, 1                   -- bras coin : longueur, épaisseur
 
    local bg = wm:CreateControl(nil, cont, CT_BACKDROP)
    bg:SetAnchorFill(cont)
    bg:SetCenterColor(0.05, 0.05, 0.05, 0.75)
    bg:SetEdgeTexture("", 2, 2, 1)
    bg:SetEdgeColor(GR, GG, GB, 0.75)
 
    -- Brackets de coin en L (8 contrôles : 2 par coin)
    -- Ancrés aux coins de `cont` → suivent automatiquement le redim.
    local cornerControls = {}
    for _, pt in ipairs({ TOPLEFT, TOPRIGHT, BOTTOMLEFT, BOTTOMRIGHT }) do
        local hArm = wm:CreateControl(nil, cont, CT_BACKDROP)
        hArm:SetDimensions(CL, CW)
        hArm:SetCenterColor(HR, HG, HB, 0.95)
        hArm:SetEdgeTexture("", 1, 1, 0)
        hArm:SetAnchor(pt, cont, pt, 0, 0)
 
        local vArm = wm:CreateControl(nil, cont, CT_BACKDROP)
        vArm:SetDimensions(CW, CL)
        vArm:SetCenterColor(HR, HG, HB, 0.95)
        vArm:SetEdgeTexture("", 1, 1, 0)
        vArm:SetAnchor(pt, cont, pt, 0, 0)
 
        cornerControls[#cornerControls + 1] = hArm
        cornerControls[#cornerControls + 1] = vArm
    end
 
    local lbl = wm:CreateControl(nil, cont, CT_LABEL)
    lbl:SetFont("ZoFontGameSmall")
    lbl:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
 
    local timer = wm:CreateControl(nil, cont, CT_LABEL)
    timer:SetFont("ZoFontGameSmall")
    timer:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
 
    local bar = wm:CreateControl(nil, cont, CT_STATUSBAR)
    bar:SetMinMax(0, 1)
 
    local debuffRow = wm:CreateControl(nil, cont, CT_CONTROL)
    debuffRow:SetHidden(true)
 
    bars[i] = {
        cont           = cont,
        bg             = bg,
        cornerControls = cornerControls,
        lbl            = lbl,
        timer          = timer,
        bar            = bar,
        debuffRow      = debuffRow,
        index          = i,
        lastLbl        = nil,
        lastTimer      = nil,
        -- Cache géométrie / style — évite les appels moteur redondants
        lastEh         = nil,
        lastBw         = nil,
        lastY          = nil,
        lastNoTaunt    = nil,
        lastFs         = nil,
        lastR          = nil,
        lastG          = nil,
        lastB2         = nil,
        lastBgAlpha    = nil,
        lastShowBorder = nil,
    }
    return bars[i]
end
 
-- Tables réutilisables — allouées une seule fois pour éviter la pression GC
local _taunted     = {}
local _entries     = {}
local _isTauntless = {}
local _entryKeys   = {}
local _yOffsets    = {}
 
local function UpdateUI()
    if not window then return end
 
    local now = GetGameTimeMilliseconds()
    local sv  = TauntTrackerSettings
 
    -- ── TOGGLE ON/OFF ─────────────────────────────────────────
    if not sv.addonEnabled then
        if not window:IsHidden() then window:SetHidden(true) end
        return
    end
 
    -- ── EARLY EXIT ────────────────────────────────────────────
    -- hasExtra est vrai seulement si au moins une cible debuffée
    -- n'est PAS déjà dans activeTaunts (évite un faux positif).
    if not previewActive then
        local hasExtra = false
        if sv.showUntaunted and TT.activeDebuffs then
            for key, debuffs in pairs(TT.activeDebuffs) do
                if not activeTaunts[key] then
                    for id in pairs(debuffs) do
                        if id ~= "_lastSeen" and id ~= "_name" then
                            if not TT.IsDebuffEnabled or TT.IsDebuffEnabled(id) then
                                hasExtra = true
                                break
                            end
                        end
                    end
                end
                if hasExtra then break end
            end
        end
        if next(activeTaunts) == nil and not hasExtra then
            if not window:IsHidden() then window:SetHidden(true) end
            return
        end
    end
 
    -- Remplissage de _taunted (réutilisation de table)
    local nt = 0
    if previewActive then
        local prev = GetPreviewEntries()
        for i = 1, #prev do nt = nt + 1; _taunted[nt] = prev[i] end
    else
        for key, data in pairs(activeTaunts) do
            if data.endTime <= now then
                activeTaunts[key] = nil
            else
                nt = nt + 1; _taunted[nt] = data
            end
        end
    end
    for i = nt + 1, #_taunted do _taunted[i] = nil end
 
    table.sort(_taunted, function(a, b) return a.endTime < b.endTime end)
 
    local extra = {}
    if TT.GetExtraTargetEntries then
        extra = TT.GetExtraTargetEntries(previewActive)
    end
 
    -- Construction de _entries (réutilisation de tables)
    local ne = 0
    for i = 1, nt do
        ne = ne + 1; _entries[ne] = _taunted[i]; _isTauntless[ne] = nil
    end
    for _, e in ipairs(extra) do
        ne = ne + 1; _entries[ne] = e; _isTauntless[ne] = true
    end
    for i = ne + 1, #_entries do _entries[i] = nil; _isTauntless[i] = nil end
 
    local bw = sv.barWidth
    local bh = sv.barHeight
    local fs = sv.fontSize
    local bg = sv.barGap or 2
 
    -- Pré-calcul des clés et offsets (tables réutilisées)
    local totalH = 0
    for i = 1, ne do
        local e       = _entries[i]
        _entryKeys[i] = e.key or MakeKey(e.unitId, e.targetName)
        _yOffsets[i]  = totalH
        local rowBh   = _isTauntless[i] and 0 or bh
        totalH = totalH + EntryHeight(rowBh, _entryKeys[i], bw) + bg
    end
    -- Retire le gap excédentaire après la dernière barre
    if ne > 0 then totalH = totalH - bg end
    for i = ne + 1, #_entryKeys do _entryKeys[i] = nil; _yOffsets[i] = nil end
 
    window:SetDimensions(bw, math.max(1, totalH))
 
    for i = 1, ne do
        local e       = _entries[i]
        local b       = GetOrCreateBar(i)
        local eKey    = _entryKeys[i]
        local noTaunt = _isTauntless[i]
        local rowBh   = noTaunt and 0 or bh
        local eh      = EntryHeight(rowBh, eKey, bw)
        local yOff    = _yOffsets[i]
 
        -- Géométrie du conteneur — uniquement si quelque chose a changé
        if b.lastEh ~= eh or b.lastBw ~= bw or b.lastY ~= yOff
                          or b.lastNoTaunt ~= noTaunt or b.lastFs ~= fs then
            b.cont:ClearAnchors()
            b.cont:SetAnchor(TOPLEFT, window, TOPLEFT, 0, yOff)
            b.cont:SetDimensions(bw, eh)
 
            b.lbl:ClearAnchors()
            b.lbl:SetAnchor(TOPLEFT, b.cont, TOPLEFT, 6, 0)
            b.lbl:SetDimensions(bw - (noTaunt and 4 or 90), 16)
            b.lbl:SetScale(fs / 16)
 
            if noTaunt then
                b.bar:SetHidden(true)
                b.timer:SetHidden(true)
                b.debuffRow:ClearAnchors()
                b.debuffRow:SetAnchor(TOPLEFT, b.cont, TOPLEFT, 2, 16 + PILL_MARGIN)
                b.debuffRow:SetDimensions(bw - 4, math.max(1, eh - 16 - PILL_MARGIN))
            else
                b.bar:SetHidden(false)
                b.timer:SetHidden(false)
                b.timer:ClearAnchors()
                b.timer:SetAnchor(TOPRIGHT, b.cont, TOPRIGHT, -6, 0)
                b.timer:SetDimensions(70, 16)
                b.timer:SetScale(fs / 16)
                b.bar:ClearAnchors()
                b.bar:SetAnchor(TOPLEFT, b.cont, TOPLEFT, 0, 16)
                b.bar:SetDimensions(bw, bh)
                b.debuffRow:ClearAnchors()
                b.debuffRow:SetAnchor(TOPLEFT, b.cont, TOPLEFT, 2, 16 + bh + PILL_MARGIN)
                b.debuffRow:SetDimensions(bw - 4, eh - 16 - bh - PILL_MARGIN)
            end
 
            b.lastEh      = eh
            b.lastBw      = bw
            b.lastY       = yOff
            b.lastNoTaunt = noTaunt
            b.lastFs      = fs
        end
 
        -- =========================================================
        -- BACKGROUND DYNAMIQUE
        -- =========================================================

        local bgAlpha    = sv.bgAlpha or 0.75
        local showBorder = sv.showBorder ~= false

        -- Couleurs configurables
        local localR = sv.localTauntColorR or 0.02
        local localG = sv.localTauntColorG or 0.18
        local localB = sv.localTauntColorB or 0.08

        local networkR = sv.networkTauntColorR or 0.30
        local networkG = sv.networkTauntColorG or 0.16
        local networkB = sv.networkTauntColorB or 0.02

        local neutralR = sv.neutralColorR or 0.05
        local neutralG = sv.neutralColorG or 0.05
        local neutralB = sv.neutralColorB or 0.05

        -- Détermine la couleur du fond
        local bgR, bgG, bgB

        if noTaunt then
            bgR, bgG, bgB = neutralR, neutralG, neutralB

        elseif e.fromNetwork then
            bgR, bgG, bgB = networkR, networkG, networkB

        else
            bgR, bgG, bgB = localR, localG, localB
        end

        -- Mise à jour uniquement si nécessaire
        if b.lastBgAlpha ~= bgAlpha
        or b.lastBgR ~= bgR
        or b.lastBgG ~= bgG
        or b.lastBgB ~= bgB then

            b.bg:SetCenterColor(bgR, bgG, bgB, bgAlpha)

            local borderAlpha = math.max(0.35, bgAlpha * 0.9)

            if showBorder then
                b.bg:SetEdgeColor(0.78, 0.64, 0.34, borderAlpha)
            else
                b.bg:SetEdgeColor(0.20, 0.20, 0.20, 0.5)
            end

            b.lastBgAlpha = bgAlpha
            b.lastBgR     = bgR
            b.lastBgG     = bgG
            b.lastBgB     = bgB
        end

        -- Bordures des coins
        if b.lastShowBorder ~= showBorder then
            for _, arm in ipairs(b.cornerControls) do
                arm:SetHidden(not showBorder)
            end

            b.lastShowBorder = showBorder
        end
 
        if noTaunt then
            local lblText = "|c8899BB" .. TrimName(e.targetName, 28) .. "|r"
            if b.lastLbl ~= lblText then
                b.lbl:SetText(lblText)
                b.lastLbl = lblText
            end
        else
            local remain = (e.endTime - now) / 1000
            local total  = math.max((e.endTime - e.beginTime) / 1000, 0.1)
            local ratio  = math.max(0, math.min(1, remain / total))
 
            local r, g, b2, a = ColorForRatio(ratio)
            b.bar:SetValue(ratio)
            -- SetColor uniquement si la couleur a changé (3 paliers seulement)
            if b.lastR ~= r or b.lastG ~= g or b.lastB2 ~= b2 then
                b.bar:SetColor(r, g, b2, a)
                b.lastR = r; b.lastG = g; b.lastB2 = b2
            end
 
            -- Texte standard (la couleur est maintenant sur le background)
            local lblText = string.format("%s → %s",
                TrimName(e.casterName, 12),
                TrimName(e.targetName, 18))
            if b.lastLbl ~= lblText then
                b.lbl:SetText(lblText)
                b.lastLbl = lblText
            end
 
            local timerText = string.format("%.1fs", remain)
            if b.lastTimer ~= timerText then
                b.timer:SetText(timerText)
                b.lastTimer = timerText
            end
        end
 
        if TT.RenderDebuffsForBar then
            TT.RenderDebuffsForBar(b, eKey, bw, rowBh)
        end
 
        b.cont:SetHidden(false)
    end
 
    for i = ne + 1, #bars do
        if bars[i] then
            bars[i].cont:SetHidden(true)
            bars[i].lastLbl        = nil
            bars[i].lastTimer      = nil
            bars[i].lastEh         = nil
            bars[i].lastBw         = nil
            bars[i].lastY          = nil
            bars[i].lastNoTaunt    = nil
            bars[i].lastFs         = nil
            bars[i].lastR          = nil
            bars[i].lastG          = nil
            bars[i].lastB2         = nil
            bars[i].lastShowBorder = nil
        end
    end
 
    local shouldHide = (ne == 0)
    if window:IsHidden() ~= shouldHide then
        window:SetHidden(shouldHide)
    end
end
 
TT.UpdateUI = UpdateUI
 
local function CreateWindow()
    local wm = WINDOW_MANAGER
    local sv = TauntTrackerSettings
 
    window = wm:CreateTopLevelWindow("TT_Window")
    window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.windowX, sv.windowY)
    window:SetDimensions(sv.barWidth, 200)
    window:SetClampedToScreen(true)
    window:SetHidden(true)
    window:SetMovable(true)
    window:SetMouseEnabled(true)
 
    window:SetHandler("OnMouseDown", function(self)
        if not TauntTrackerSettings.locked then self:StartMoving() end
    end)
    window:SetHandler("OnMouseUp", function(self)
        self:StopMovingOrResizing()
        local left, top = self:GetScreenRect()
        TauntTrackerSettings.windowX = left
        TauntTrackerSettings.windowY = top
    end)
end
 
--------------------------------------------------
-- EVENTS
--------------------------------------------------
 
local debugMode = false
 
local DEATH_RESULTS = {
    [ACTION_RESULT_DIED]          = true,
    [ACTION_RESULT_KILLING_BLOW]  = true,
    [ACTION_RESULT_DIED_XP]       = true,
}
 
local function OnCombatEvent(
    eventCode, result, isError,
    abilityName, abilityGraphic, abilityActionSlotType,
    sourceName, sourceType,
    targetName, targetType,
    hitValue, powerType, damageType, log,
    sourceUnitId, targetUnitId, abilityId
)
    -- Mort de la cible : clé directe + nettoyage des entrées réseau du même mob.
    if DEATH_RESULTS[result] and targetUnitId then
        local cleanDead = CleanName(targetName)
        local key = MakeKey(targetUnitId, cleanDead)
 
        -- Supprimer l'entrée locale directe si elle existe.
        if key then
            pendingFades[key] = nil
            activeTaunts[key] = nil
            -- Nettoyage des debuffs : ESO ne garantit pas l'envoi de EFFECT_RESULT_FADED
            -- sur chaque debuff quand un mob meurt. Sans ce nettoyage, activeDebuffs garde
            -- l'entrée jusqu'à 30s (timeout Cleanup), ce qui maintient l'UI affichée à tort.
            if TT.activeDebuffs then
                TT.activeDebuffs[key] = nil
            end
        end
 
        -- Supprimer aussi les entrées réseau (fromNetwork=true) pour ce mob.
        -- Quand un allié taunte, l'entrée est stockée sous sa clé LGB (unitId de son client),
        -- introuvable via MakeKey local. On les nettoie par correspondance de nom.
        --
        -- NOTE : targetName est potentiellement tronqué (10 chars côté réseau via SafeSub,
        -- 18 chars + "..." côté local via TrimName). On utilise donc un matching par préfixe
        -- plutôt qu'une égalité stricte pour éviter que les entrées réseau restent affichées
        -- après la mort du mob.
        local nameLower = cleanDead:lower()
        for k, v in pairs(activeTaunts) do
            if NameMatch(v.targetName, nameLower) then
                pendingFades[k] = nil
                activeTaunts[k] = nil
            end
        end
        -- Nettoyage des debuffs par correspondance de nom (entrées sans taunt).
        if TT.activeDebuffs then
            for k, debuffs in pairs(TT.activeDebuffs) do
                if NameMatch(debuffs._name, nameLower) then
                    TT.activeDebuffs[k] = nil
                end
            end
        end
    end
 
    if not TAUNT_IDS[abilityId] then return end
    if not targetName or targetName == "" then return end
 
    local cleanTarget = CleanName(targetName)
    local key = MakeKey(targetUnitId, cleanTarget)
    if not key then return end
 
    local caster = ResolveCasterName(sourceName, sourceUnitId)
 
    if debugMode then
        d(string.format("[TT DEBUG COMBAT] sourceName='%s' sourceType=%s sourceUnitId=%s → resolved='%s' | result=%s abilityId=%d",
            tostring(sourceName), tostring(sourceType), tostring(sourceUnitId),
            tostring(caster), tostring(result), abilityId))
    end
 
    local cacheKey = key .. ":" .. tostring(abilityId)
    tauntCasterCache[cacheKey] = caster
 
    if GAIN_RESULTS[result] then
        local now = GetGameTimeMilliseconds()
 
        -- Si pas encore d'entrée locale pour ce mob, chercher une entrée réseau
        -- (fromNetwork=true) à migrer. On ne migre QUE les entrées réseau pour
        -- éviter de fusionner deux mobs différents ayant le même nom.
        if not activeTaunts[key] then
            local staleKey = PurgeStaleDuplicates(key, cleanTarget:lower())
            if staleKey then
                pendingFades[staleKey] = nil
                activeTaunts[staleKey] = nil
            end
        end
 
        -- Annuler un fade en attente (re-taunt rapide)
        pendingFades[key] = nil
 
        activeTaunts[key] = {
            casterName = caster,
            targetName = TrimName(cleanTarget, 18),
            beginTime  = now,
            endTime    = now + TAUNT_DURATION,
            key        = key,
            unitId     = targetUnitId,
        }
 
        if TT.BroadcastTaunt then
            local now2 = GetGameTimeMilliseconds()
            if not lastBroadcast[key] or (now2 - lastBroadcast[key]) > 500 then
                lastBroadcast[key] = now2
                TT.BroadcastTaunt(key, cleanTarget)
            end
        end
    end
end
 
local function OnEffectChanged(_, changeType, effectSlot, effectName, unitTag,
    beginTime, endTime, stackCount, iconName, buffType,
    effectType, abilityType, statusEffectType,
    unitName, unitId, abilityId)
 
    if not TAUNT_IDS[abilityId] then return end
    if not unitName or unitName == "" then return end
 
    local now = GetGameTimeMilliseconds()
    local cleanName = CleanName(unitName)
    local key = MakeKey(unitId, cleanName)
    if not key then return end
 
    local cacheKey = key .. ":" .. tostring(abilityId)
    local caster = tauntCasterCache[cacheKey]
 
    if debugMode then
        d(string.format("[TT DEBUG EFFECT] changeType=%s unitName='%s' abilityId=%d | cacheHit=%s caster='%s'",
            tostring(changeType), tostring(unitName), abilityId,
            tostring(caster ~= nil), tostring(caster)))
    end
 
    -- EVENT_COMBAT_EVENT ne tire que pour le joueur local.
    -- Pour les alliés, on tente de trouver qui a ce mob en cible.
    if not caster then
        caster = FindAllyWhoTargeted(unitId)
        if debugMode and caster then
            d("[TT DEBUG EFFECT] → trouvé via cible du groupe : " .. caster)
        end
    end
 
    caster = caster or "?"
 
    -- =========================================================
    -- GAIN / UPDATE
    -- =========================================================
    if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
 
        local beginMs = (beginTime and beginTime > 0) and beginTime * 1000 or now
        local endMs   = (endTime and endTime > 0) and endTime * 1000 or (now + TAUNT_DURATION)
 
        pendingFades[key] = nil
 
        -- Si pas d'entrée locale directe, chercher une entrée réseau unique à migrer.
        -- On ne migre QUE les entrées fromNetwork pour éviter de fusionner deux mobs
        -- différents portant le même nom.
        if not activeTaunts[key] then
            local staleKey = PurgeStaleDuplicates(key, cleanName:lower())
            if staleKey then
                if (not caster or caster == "?") and activeTaunts[staleKey] and activeTaunts[staleKey].casterName ~= "?" then
                    caster = activeTaunts[staleKey].casterName
                end
                pendingFades[staleKey] = nil
                activeTaunts[staleKey] = nil
            end
        end
 
        local existing = activeTaunts[key]
        if existing then
            -- Sur EFFECT_RESULT_GAINED : un allié vient potentiellement de retaunter.
            -- Mettre à jour le casterName si on a trouvé une source valide.
            -- Sur EFFECT_RESULT_UPDATED : refresh de durée uniquement, ne pas changer le caster.
            if changeType == EFFECT_RESULT_GAINED and caster ~= "?" then
                existing.casterName = caster
            elseif existing.casterName == nil or existing.casterName == "?" then
                if caster ~= "?" then existing.casterName = caster end
            end
            existing.beginTime   = beginMs
            existing.endTime     = endMs
            existing.key         = key
            existing.unitId      = unitId
            existing.fromNetwork = nil
        else
            activeTaunts[key] = {
                casterName = caster,
                targetName = TrimName(cleanName, 18),
                beginTime  = beginMs,
                endTime    = endMs,
                key        = key,
                unitId     = unitId,
            }
        end
 
        if caster == "?" then
            local uid = unitId
            local function TryResolve()
                local entry = activeTaunts[key]
                if entry and (entry.casterName == "?" or entry.casterName == nil) then
                    local found = FindAllyWhoTargeted(uid)
                    if found then entry.casterName = found end
                end
            end
            zo_callLater(TryResolve, 100)
            zo_callLater(TryResolve, 250)
            zo_callLater(TryResolve, 500)
        end
 
    -- =========================================================
    -- FADE
    -- =========================================================
    elseif changeType == EFFECT_RESULT_FADED then
        tauntCasterCache[cacheKey] = nil
        -- Suppression différée de 400ms : EFFECT_RESULT_FADED fire AVANT
        -- EFFECT_RESULT_GAINED lors d'un re-taunt sur la même cible.
        -- Sans délai, la barre disparaît brièvement à chaque re-taunt.
        pendingFades[key] = true
        zo_callLater(function()
            if pendingFades[key] then
                pendingFades[key] = nil
                activeTaunts[key] = nil
            end
        end, 400)
    end
end
 
--------------------------------------------------
-- MENU LAM
--------------------------------------------------
 
TT.RegisterOptions(function()
    return {
        -- ── GÉNÉRAL ──────────────────────────────────────────
        { type = "header", name = "|cAADDFFGénéral|r" },
        {
            type    = "checkbox",
            name    = "|cFFFFFF" ..GetString(TAUNTTRACKER_ADD).."|r",
            tooltip = GetString(TAUNTTRACKER_ADDTOOL),
            getFunc = function() return TauntTrackerSettings.addonEnabled end,
            setFunc = function(v)
                TauntTrackerSettings.addonEnabled = v
                UpdateUI()
                if not v and previewActive then
                    previewActive = false
                end
            end,
        },
        {
            type    = "checkbox",
            name    = GetString(TAUNTTRACKER_PREVIEW),
            tooltip = GetString(TAUNTTRACKER_PRETOOL),
            getFunc = function() return previewActive end,
            setFunc = function(v)
                previewActive = v
                if v then
                    TauntTrackerSettings.addonEnabled = true
                    window:SetHidden(false)
                end
                UpdateUI()
            end,
        },
        {
            type    = "checkbox",
            name    = GetString(TAUNTTRACKER_WINDOW),
            tooltip = GetString(TAUNTTRACKER_WINTOOL),
            getFunc = function() return TauntTrackerSettings.locked end,
            setFunc = function(v) TauntTrackerSettings.locked = v end,
        },
        -- ── APPARENCE ────────────────────────────────────────
        { type = "divider" },
        { type = "header", name = "|cFFDD88"..GetString(TAUNTTRACKER_UI).."|r" },
        {
            type    = "slider",
            name    = GetString(TAUNTTRACKER_X),
            tooltip = GetString(TAUNTTRACKER_XTOOL),
            min=150, max=600, step=10,
            getFunc = function() return TauntTrackerSettings.barWidth end,
            setFunc = function(v) TauntTrackerSettings.barWidth=v; UpdateUI() end,
        },
        {
            type    = "slider",
            name    = GetString(TAUNTTRACKER_Y),
            tooltip = GetString(TAUNTTRACKER_YTOOL),
            min=8, max=40, step=1,
            getFunc = function() return TauntTrackerSettings.barHeight end,
            setFunc = function(v) TauntTrackerSettings.barHeight=v; UpdateUI() end,
        },
        {
            type    = "slider",
            name    = GetString(TAUNTTRACKER_GAP),
            tooltip = GetString(TAUNTTRACKER_GAPTOOL),
            min=0, max=20, step=1,
            getFunc = function() return TauntTrackerSettings.barGap or 2 end,
            setFunc = function(v) TauntTrackerSettings.barGap=v; UpdateUI() end,
        },
        {
            type    = "slider",
            name    = GetString(TAUNTTRACKER_SIZE),
            tooltip = GetString(TAUNTTRACKER_SIZETOOL),
            min=8, max=30, step=1,
            getFunc = function() return TauntTrackerSettings.fontSize end,
            setFunc = function(v) TauntTrackerSettings.fontSize=v; UpdateUI() end,
        },
        {
            type    = "slider",
            name    = GetString(TAUNTTRACKER_BGALPHA),
            tooltip = GetString(TAUNTTRACKER_BGALPHATOOL),
            min=0, max=100, step=5,
            getFunc = function()
                return math.floor((TauntTrackerSettings.bgAlpha or 0.75) * 100)
            end,
            setFunc = function(v)
                TauntTrackerSettings.bgAlpha = v / 100
                -- Invalide le cache alpha de toutes les bars pour forcer la mise à jour
                for _, b in ipairs(TT.bars) do
                    if b then b.lastBgAlpha = nil end
                end
                UpdateUI()
            end,
        },
        {
            type    = "checkbox",
            name    = GetString(TAUNTTRACKER_BORDER),
            tooltip = GetString(TAUNTTRACKER_BORDERTOOL),
            getFunc = function() return TauntTrackerSettings.showBorder ~= false end,
            setFunc = function(v)
                TauntTrackerSettings.showBorder = v
                -- Invalide le cache showBorder de toutes les bars
                for _, b in ipairs(TT.bars) do
                    if b then b.lastShowBorder = nil end
                end
                UpdateUI()
            end,
        },
        {
            type    = "button",
            name    = GetString(TAUNTTRACKER_RESET),
            tooltip = GetString(TAUNTTRACKER_RESETTOOL),
            func    = function()
                TauntTrackerSettings.windowX = DEFAULT_SETTINGS.windowX
                TauntTrackerSettings.windowY = DEFAULT_SETTINGS.windowY
                window:ClearAnchors()
                window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
                    DEFAULT_SETTINGS.windowX, DEFAULT_SETTINGS.windowY)
            end,
        },
		{
			type = "colorpicker",
			name = GetString(TAUNTTRACKER_COLORME),

			getFunc = function()
				return
					TauntTrackerSettings.localTauntColorR,
					TauntTrackerSettings.localTauntColorG,
					TauntTrackerSettings.localTauntColorB
			end,

			setFunc = function(r, g, b)
				TauntTrackerSettings.localTauntColorR = r
				TauntTrackerSettings.localTauntColorG = g
				TauntTrackerSettings.localTauntColorB = b

				for _, bar in ipairs(TT.bars) do
					if bar then
						bar.lastBgR = nil
						bar.lastBgG = nil
						bar.lastBgB = nil
					end
				end

				UpdateUI()
			end,
		},
		{
			type = "colorpicker",
			name = GetString(TAUNTTRACKER_COLORGROUP),

			getFunc = function()
				return
					TauntTrackerSettings.networkTauntColorR,
					TauntTrackerSettings.networkTauntColorG,
					TauntTrackerSettings.networkTauntColorB
			end,

			setFunc = function(r, g, b)
				TauntTrackerSettings.networkTauntColorR = r
				TauntTrackerSettings.networkTauntColorG = g
				TauntTrackerSettings.networkTauntColorB = b

				for _, bar in ipairs(TT.bars) do
					if bar then
						bar.lastBgR = nil
						bar.lastBgG = nil
						bar.lastBgB = nil
					end
				end

				UpdateUI()
			end,
		},
		{
			type = "colorpicker",
			name = GetString(TAUNTTRACKER_COLORWHY),

			getFunc = function()
				return
					TauntTrackerSettings.neutralColorR,
					TauntTrackerSettings.neutralColorG,
					TauntTrackerSettings.neutralColorB
			end,

			setFunc = function(r, g, b)
				TauntTrackerSettings.neutralColorR = r
				TauntTrackerSettings.neutralColorG = g
				TauntTrackerSettings.neutralColorB = b

				for _, bar in ipairs(TT.bars) do
					if bar then
						bar.lastBgR = nil
						bar.lastBgG = nil
						bar.lastBgB = nil
					end
				end

				UpdateUI()
			end,
		},
    }
end)
 
--------------------------------------------------
-- COMMANDES SLASH
--------------------------------------------------
 
local function RegisterSlashCommands()
    SLASH_COMMANDS["/tt"] = function(args)
        args = args and args:lower():gsub("^%s+", "") or ""
 
        if args == "toggle" then
            TauntTrackerSettings.addonEnabled = not TauntTrackerSettings.addonEnabled
            local state = TauntTrackerSettings.addonEnabled
            if not state and previewActive then previewActive = false end
            UpdateUI()
            d("[TauntTracker] " .. (state and "|c00FF00"..GetString(TAUNTTRACKER_ON).."|r" or "|cFF4444"..GetString(TAUNTTRACKER_OFF).."|r"))
 
        elseif args == "preview" then
            previewActive = not previewActive
            if previewActive then window:SetHidden(false) end
            UpdateUI()
            d("[TauntTracker] Preview " .. (previewActive and "ON" or "OFF"))
 
        elseif args == "debug" then
            debugMode = not debugMode
            d("[TauntTracker] Debug " .. (debugMode and "|c00FF00ON|r" or "|cFF4444OFF|r"))
            if debugMode then
                d("[TT] groupNameCache (" .. tostring(GetGroupSize and GetGroupSize() or 0) .. " membres) :")
                local count = 0
                for account, charName in pairs(groupNameCache) do
                    d(string.format("  %s → %s", account, charName))
                    count = count + 1
                end
                if count == 0 then d("  (vide — pas en groupe ou cache non construit)") end
            end
 
        elseif args == "reset" then
            TauntTrackerSettings.windowX = DEFAULT_SETTINGS.windowX
            TauntTrackerSettings.windowY = DEFAULT_SETTINGS.windowY
            window:ClearAnchors()
            window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
                DEFAULT_SETTINGS.windowX, DEFAULT_SETTINGS.windowY)
            d("[TauntTracker] Position réinitialisée.")
 
        elseif args == "net" then
            if TT.NetDiag then TT.NetDiag()
            else d("[TauntTracker] NetworkSync non chargé.") end
 
        else
            d("|c00FF88[TauntTracker]|r commandes :")
            d("  /tt toggle " ..GetString(TAUNTTRACKER_CMD1))
            d("  /tt preview " ..GetString(TAUNTTRACKER_CMD2))
            d("  /tt debug " ..GetString(TAUNTTRACKER_CMD3))
            d("  /tt reset " ..GetString(TAUNTTRACKER_CMD4))
            d("  /tt net " ..GetString(TAUNTTRACKER_CMD5))
        end
    end
end
 
 
local function OnAddonLoaded(_, addonName)
    if addonName ~= TT.name then return end
 
    TauntTrackerSettings = ZO_SavedVars:NewAccountWide(
        "TauntTrackerSV", 1, nil, DEFAULT_SETTINGS
    )
 
    CreateWindow()
    TT.InitLAM()
	if TT.RefreshColors then
		TT.RefreshColors()
	end
    RegisterSlashCommands()
 
    EVENT_MANAGER:RegisterForEvent(TT.name, EVENT_COMBAT_EVENT,   OnCombatEvent)
    EVENT_MANAGER:RegisterForEvent(TT.name, EVENT_EFFECT_CHANGED, OnEffectChanged)
    -- Tick à 200ms : imperceptible pour un CD de 15s, réduit la charge de ~50%
    EVENT_MANAGER:RegisterForUpdate(TT.name, 50, UpdateUI)
 
    -- Construit le cache @compte→perso dès le chargement et le maintient à jour
    RebuildGroupCache()
    EVENT_MANAGER:RegisterForEvent(TT.name, EVENT_GROUP_MEMBER_JOINED, RebuildGroupCache)
    EVENT_MANAGER:RegisterForEvent(TT.name, EVENT_GROUP_MEMBER_LEFT,   RebuildGroupCache)
    EVENT_MANAGER:RegisterForEvent(TT.name, EVENT_PLAYER_ACTIVATED,    RebuildGroupCache)
 
    d("[TauntTracker] v" .. TT.version .. " chargé")
end
 
EVENT_MANAGER:RegisterForEvent(TT.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)