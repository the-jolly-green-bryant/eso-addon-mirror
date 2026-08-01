-- ============================================================
--  TargetTracker.lua
--  Injecte des entrées "sans taunt" dans la fenêtre principale.
--  Une entrée sans taunt = nom de la cible + pills de debuffs,
--  sans barre de progression ni timer.
--
--  N'a PAS sa propre fenêtre. Fournit uniquement :
--    TT.GetExtraTargetEntries(isPreview) → table d'entrées
--  appelé depuis TauntTracker.lua > UpdateUI.
-- ============================================================

local TT = TauntTracker

-- ============================================================
--  SETTINGS
-- ============================================================

local function GetTargetDefaults()
    return {
        showUntaunted = true,  -- afficher les cibles avec debuffs mais sans taunt
    }
end

-- ============================================================
--  ENTRÉES EXTRA — appelé par TauntTracker.lua > UpdateUI
--
--  Retourne les cibles qui ont au moins un debuff actif ET
--  qui ne sont PAS déjà dans activeTaunts (pour éviter les doublons).
--
--  Format de chaque entrée :
--    { targetName, key }
--    (pas de casterName / beginTime / endTime — entrée sans taunt)
-- ============================================================

-- Table réutilisable — allouée une seule fois pour éviter la pression GC
local _extraEntries = {}

function TT.GetExtraTargetEntries(isPreview)
    local sv = TauntTrackerSettings
    if not sv.showUntaunted then return {} end
    if not TT.activeDebuffs then return {} end

    -- Mode preview : 1 fausse entrée sans taunt
    if isPreview then
        return {
            { targetName="Skeleton Boss", key="preview_extra" },
        }
    end

    -- Vider sans réallouer
    local n = #_extraEntries
    for i = 1, n do _extraEntries[i] = nil end
    n = 0

    for key, debuffs in pairs(TT.activeDebuffs) do
        -- Ignore les cibles déjà taunted (déjà affichées en haut)
        if not TT.activeTaunts[key] then
            -- Vérifie qu'au moins un debuff est actif et activé
            local hasAny = false
            for id in pairs(debuffs) do
                if id ~= "_lastSeen" and id ~= "_name" then
                    if TT.IsDebuffEnabled and TT.IsDebuffEnabled(id) then
                        hasAny = true; break
                    end
                end
            end

            if hasAny then
                n = n + 1
                _extraEntries[n] = {
                    targetName = debuffs._name or key,
                    key        = key,
                }
            end
        end
    end

    -- Tri alphabétique
    table.sort(_extraEntries, function(a, b) return (a.targetName or "") < (b.targetName or "") end)

    return _extraEntries
end

-- ============================================================
--  OPTIONS LAM
-- ============================================================

TT.RegisterOptions(function()
    return {
        { type = "divider" },
        { type = "header", name = "|c44CCFF"..GetString(TAUNTTRACKER_TITTLE1).."|r" },
        {
            type    = "checkbox",
            name    = GetString(TAUNTTRACKER_TARGET1),
            tooltip = GetString(TAUNTTRACKER_TARGETTOOL),
            getFunc = function() return TauntTrackerSettings.showUntaunted end,
            setFunc = function(v)
                TauntTrackerSettings.showUntaunted = v
                if TT.UpdateUI then TT.UpdateUI() end
            end,
        },
    }
end)

-- ============================================================
--  INIT
-- ============================================================

local function OnLoaded(_, addonName)
    if addonName ~= TT.name then return end

    local sv       = TauntTrackerSettings
    local defaults = GetTargetDefaults()
    for k, v in pairs(defaults) do
        if sv[k] == nil then sv[k] = v end
    end
end

EVENT_MANAGER:RegisterForEvent(
    TT.name .. "_targets_init",
    EVENT_ADD_ON_LOADED,
    OnLoaded
)
