-------------------------------------------------------------------------------
-- Pit's Zenkosh Tracker - Kern: Debuff-Tracking, Zielmarker, Timer-Daten
--
-- Autor der Idee und des Namens: @petethepower. Danke fuers Ausprobieren!
--
-- Zwei Anzeigen:
--   1. Zielmarker auf Gegnern, solange dein Alkosh (Line-Breaker, 76667) laeuft.
--   2. Timer-Fenster (PitsZenkoshTrackerUI.lua) mit Alkosh UND Touch of Z'en (126597)
--      je Gegner, inkl. Z'en-Stacks.
--
-- Grenze der ESO-API: Marker koennen NUR auf das Ziel unterm Fadenkreuz gesetzt
-- oder entfernt werden (AssignTargetMarkerToReticleTarget). Das Timer-Fenster
-- hat diese Grenze nicht, es speist sich rein aus Events.
--
-- Wichtig fuers Verstaendnis: beim Erneuern eines Debuffs schickt ESO erst
-- EFFECT_RESULT_FADED und kurz darauf GAINED. Wuerden wir auf FADED sofort
-- reagieren, flackerte alles bei jedem Recast. Deshalb ignoriert das Tracking
-- FADED voellig und laesst Eintraege ueber ihre Ablaufzeit auslaufen. Das
-- entfernt Flackern, Fehl-Warnungen und den "AUS"-Spam im Log in einem.
-------------------------------------------------------------------------------

PitsZenkoshTracker = PitsZenkoshTracker or {}
local A = PitsZenkoshTracker

A.name    = "PitsZenkoshTracker"
A.version = "1.0.0"

A.ALKOSH_LINEBREAKER = 76667   -- Roar of Alkosh / Line-Breaker
A.ZEN_TOUCH          = 126597  -- Touch of Z'en (Z'en's Redress)
A.ZEN_MAX_STACKS     = 5

-- Fallback-Dauern, falls ein GAINED-Event keine sinnvolle Endzeit liefert (ms)
local ALKOSH_FALLBACK_MS = 6000
local ZEN_FALLBACK_MS    = 20000

local UPDATE_INTERVAL = 100    -- Fadenkreuz-Ziel pruefen (ms)
local ASSIGN_COOLDOWN = 400    -- Mindestabstand zwischen Marker-Befehlen (ms)
local REMOVE_GRACE    = 300    -- so lange muss "kein Alkosh" gelten, bevor der Marker faellt (ms)
local EXPIRY_KEEP_MS  = 5000   -- so lange bleibt eine Ablauf-Meldung fuer die Warnung abrufbar (ms)

local MAX_BOSSES = 6

-- Ab so vielen max. Lebenspunkten gilt ein Ziel als "wichtig" (Warnung), auch
-- ohne Bossleiste/toedliche Schwierigkeit: Trainingspuppen (Trial-Atronach hat
-- 3-21 Mio) und dicke Trial-Adds. Normales Trash liegt weit darunter.
local BIG_HEALTH = 3000000

local em = EVENT_MANAGER
local sv

A.defaults = {
    enabled       = true,
    pool          = { TARGET_MARKER_TYPE_SEVEN, TARGET_MARKER_TYPE_SIX },
    useSecond     = true,   -- zweites Markersymbol nutzen (Boss + Mini gleichzeitig)
    markAdds      = true,   -- false = nur Bosse markieren
    onlyInstances = true,   -- nur Dungeons/Trials
    includeGroup  = true,   -- auch Alkosh von Gruppenmitgliedern
    debug         = false,

    ui = {
        show          = true,
        locked        = false,
        scale         = 1.0,
        maxRows       = 6,
        bossOnly      = false,
        showZen       = true,   -- Touch of Z'en mit anzeigen
        expiryWarning = true,   -- rote Warnung, wenn Alkosh auf Boss/toedlichem Ziel ablaeuft
        x             = nil,
        y             = nil,
    },
}

A.MARKER_NAMES = {
    [TARGET_MARKER_TYPE_NONE]  = "kein Marker",
    [TARGET_MARKER_TYPE_ONE]   = "1 blaues Quadrat",
    [TARGET_MARKER_TYPE_TWO]   = "2 goldener Stern",
    [TARGET_MARKER_TYPE_THREE] = "3 gruener Kreis",
    [TARGET_MARKER_TYPE_FOUR]  = "4 oranges Dreieck",
    [TARGET_MARKER_TYPE_FIVE]  = "5 pinke Monde",
    [TARGET_MARKER_TYPE_SIX]   = "6 lila Oblivion",
    [TARGET_MARKER_TYPE_SEVEN] = "7 rote gekreuzte Waffen",
    [TARGET_MARKER_TYPE_EIGHT] = "8 weisser Totenkopf",
}

-------------------------------------------------------------------------------
-- Zustand
-------------------------------------------------------------------------------

-- Per Gegner:
--   targets[unitId] = {
--     name, isBoss, firstSeenMs,
--     alkoshBeginMs, alkoshUntilMs, alkoshExpiryDone,
--     zenBeginMs,    zenUntilMs,
--     libStacks,     -- Z'en-Stacks aus LibCombat, oder nil
--     dots = { [key] = endMs },  -- Fallback-Zaehlung eigener DoTs
--   }
local targets = {}

-- Marker-Rueckfallebene fuers Fadenkreuz: dort gibt die API keine unitId her,
-- nur den Namen.  activeByName[name] = alkoshUntilMs
local activeByName = {}

-- Namen der Gegner in der Bossleiste (boss1..boss6)
local bossNames = {}

-- Namen, die als "wichtig" gelten und damit eine Ablauf-Warnung verdienen:
-- Bossleiste ODER toedliche Schwierigkeit (wie beim Marker). Events liefern
-- keine Schwierigkeit, deshalb wird das beim Anvisieren nachgetragen.
local deadlyNames = {}

-- Kuerzlich abgelaufene Alkosh wichtiger Ziele, damit das UI die rote Warnung
-- zeigen kann.  recentExpiry[unitId] = { name, important, expiredMs }
local recentExpiry = {}

-- Marker-Buchhaltung:  markerOwner[markerType] = { name, untilMs, difficulty }
local markerOwner = {}

local removeTries    = 0
local lastAssign     = 0
local noAlkoshSince  = nil
local libCombatOn    = false
local dotFirehoseOn  = false
local inCombat       = false   -- fuer die Boss-Dauerzeile (siehe IsPersistentBoss)

A.zenStackSource = "keine"   -- fuer /zenkosh status

-------------------------------------------------------------------------------
-- Helfer
-------------------------------------------------------------------------------

function A.Msg(fmt, ...)
    d("|c88CCFF[Alkosh]|r " .. string.format(fmt, ...))
end
local function Msg(...) A.Msg(...) end

local function Dbg(fmt, ...)
    if sv and sv.debug then Msg(fmt, ...) end
end
A.Dbg = Dbg

local function CleanName(name)
    return zo_strformat("<<1>>", name or "")
end
A.CleanName = CleanName

-------------------------------------------------------------------------------
-- Bosse erkennen
-------------------------------------------------------------------------------

local function RefreshBossNames()
    bossNames = {}
    for i = 1, MAX_BOSSES do
        local tag = "boss" .. i
        if DoesUnitExist(tag) then
            local name = CleanName(GetUnitName(tag))
            if name ~= "" then bossNames[name] = true end
        end
    end
    -- bereits verfolgte Gegner nachtraeglich als Boss markieren
    for _, t in pairs(targets) do
        if bossNames[t.name] then t.isBoss = true; t.important = true end
    end
end

local function IsBossName(name)
    return bossNames[name] == true
end
A.IsBossName = IsBossName

local function IsReticleBoss()
    if IsBossName(CleanName(GetUnitName("reticleover"))) then return true end
    return GetUnitDifficulty("reticleover") >= MONSTER_DIFFICULTY_DEADLY
end

-- "Wichtig" fuer die Ablauf-Warnung: Bossleiste oder als toedlich erkannt.
local function IsImportantName(name)
    return IsBossName(name) or deadlyNames[name] == true
end
A.IsImportantName = IsImportantName

-- Verdient das anvisierte Ziel eine Ablauf-Warnung? Boss/toedlich (wie der
-- Marker) ODER sehr viele Lebenspunkte (Trainingspuppe, dicker Trial-Add).
local function IsReticleImportant()
    if IsReticleBoss() then return true end
    local _, maxHp = GetUnitPower("reticleover", POWERTYPE_HEALTH)
    return (maxHp or 0) >= BIG_HEALTH
end
A.IsReticleImportant = IsReticleImportant

-------------------------------------------------------------------------------
-- Ziel-Store
-------------------------------------------------------------------------------

local function GetTarget(unitId, name)
    local t = targets[unitId]
    if not t then
        t = {
            name        = name,
            isBoss      = IsBossName(name),
            important   = IsImportantName(name),
            firstSeenMs = GetGameTimeMilliseconds(),
            dots        = {},
        }
        targets[unitId] = t
    elseif name and name ~= "" then
        t.name = name
        if IsBossName(name) then t.isBoss = true end
        if IsImportantName(name) then t.important = true end
    end
    return t
end

-- Anzahl aktiver eigener DoTs auf dem Ziel (Fallback fuer Z'en-Stacks)
local function CountDots(t, nowMs)
    local n = 0
    for key, endMs in pairs(t.dots) do
        if endMs > nowMs then
            n = n + 1
        else
            t.dots[key] = nil
        end
    end
    return math.min(A.ZEN_MAX_STACKS, n)
end

local function ZenStacks(t, nowMs)
    if libCombatOn and t.libStacks ~= nil then
        return math.max(0, math.min(A.ZEN_MAX_STACKS, t.libStacks))
    end
    return CountDots(t, nowMs)
end

-- Der Boss bleibt die ganze Kampfdauer im Fenster (und oben), sobald er im
-- Kampf einmal Alkosh hatte - auch wenn Alkosh zwischendurch abfaellt (Phase,
-- kurzer Aussetzer). Er lebt ja bis zum Kampfende. Grosse Adds sind bewusst
-- NICHT dauerhaft; sie sterben im Kampf ohnehin schnell und duerfen verschwinden.
local function IsPersistentBoss(t)
    return t.isBoss and t.sawAlkosh and inCombat
end
A.IsPersistentBoss = IsPersistentBoss

-- Laeuft alles ab; abgelaufene Alkosh wichtiger Ziele in recentExpiry vermerken,
-- vollstaendig leere Ziele wegwerfen (den Boss aber halten, s.o.).
local function Prune(nowMs)
    for unitId, t in pairs(targets) do
        if t.alkoshUntilMs and t.alkoshUntilMs <= nowMs then
            if not t.alkoshExpiryDone then
                t.alkoshExpiryDone = true
                recentExpiry[unitId] = { name = t.name, important = t.important, expiredMs = t.alkoshUntilMs }
                Dbg("Alkosh abgelaufen auf %s", t.name)
            end
            t.alkoshBeginMs, t.alkoshUntilMs = nil, nil
        end
        if t.zenUntilMs and t.zenUntilMs <= nowMs then
            t.zenBeginMs, t.zenUntilMs, t.libStacks = nil, nil, nil
        end

        local hasDots = next(t.dots) ~= nil
        if not t.alkoshUntilMs and not t.zenUntilMs and not hasDots and not IsPersistentBoss(t) then
            targets[unitId] = nil
        end
    end

    for name, untilMs in pairs(activeByName) do
        if untilMs <= nowMs then activeByName[name] = nil end
    end
    for unitId, e in pairs(recentExpiry) do
        if nowMs - e.expiredMs > EXPIRY_KEEP_MS then recentExpiry[unitId] = nil end
    end
end
A.Prune = Prune

-- Fuer das Timer-Fenster. Stabile Reihenfolge: Boss zuerst, dann nach
-- Erst-Sichtung (firstSeenMs) - damit die Zeilen innerhalb eines Kampfes
-- nicht springen. Liefert je Gegner Alkosh- und Z'en-Teildaten.
function A.GetTimerTargets(nowMs, bossOnly, limit)
    nowMs = nowMs or GetGameTimeMilliseconds()
    Prune(nowMs)

    local list = {}
    for unitId, t in pairs(targets) do
        local alkoshOn = t.alkoshUntilMs and t.alkoshUntilMs > nowMs
        local zenOn    = t.zenUntilMs and t.zenUntilMs > nowMs
        -- Der Boss bleibt sichtbar (mit leerer Alkosh-Leiste), auch wenn gerade
        -- nichts laeuft. Adds nur, solange Alkosh oder Z'en aktiv ist.
        if (alkoshOn or zenOn or IsPersistentBoss(t)) and (not bossOnly or t.isBoss) then
            local entry = {
                key         = unitId,
                name        = t.name,
                isBoss      = t.isBoss,
                firstSeenMs = t.firstSeenMs,
            }
            if alkoshOn then
                local total = t.alkoshUntilMs - (t.alkoshBeginMs or (t.alkoshUntilMs - ALKOSH_FALLBACK_MS))
                entry.alkosh = {
                    remaining = (t.alkoshUntilMs - nowMs) / 1000,
                    fraction  = math.max(0, math.min(1, (t.alkoshUntilMs - nowMs) / math.max(1, total))),
                }
            end
            if zenOn then
                local total = t.zenUntilMs - (t.zenBeginMs or (t.zenUntilMs - ZEN_FALLBACK_MS))
                entry.zen = {
                    remaining = (t.zenUntilMs - nowMs) / 1000,
                    fraction  = math.max(0, math.min(1, (t.zenUntilMs - nowMs) / math.max(1, total))),
                    stacks    = ZenStacks(t, nowMs),
                }
            end
            table.insert(list, entry)
        end
    end

    table.sort(list, function(a, b)
        if a.isBoss ~= b.isBoss then return a.isBoss end
        if a.firstSeenMs ~= b.firstSeenMs then return a.firstSeenMs < b.firstSeenMs end
        return a.name < b.name
    end)

    if limit and #list > limit then
        for i = #list, limit + 1, -1 do table.remove(list, i) end
    end
    return list
end

-- Alkosh wichtiger Ziele (Boss/toedlich), die in den letzten EXPIRY_KEEP_MS
-- abgelaufen sind (fuer die Warnung)
function A.GetRecentExpiries(nowMs)
    nowMs = nowMs or GetGameTimeMilliseconds()
    Prune(nowMs)
    local list = {}
    for unitId, e in pairs(recentExpiry) do
        if e.important then
            table.insert(list, {
                key      = unitId,
                name     = e.name,
                sinceMs  = nowMs - e.expiredMs,
            })
        end
    end
    return list
end

-------------------------------------------------------------------------------
-- Debuff-Tracking (Events)
-------------------------------------------------------------------------------

-- EVENT_EFFECT_CHANGED (eventCode, changeType, effectSlot, effectName, unitTag,
--   beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType,
--   statusEffectType, unitName, unitId, abilityId, sourceType)
local function OnAlkoshChanged(_, changeType, _, _, _, beginTime, endTime, _, _, _, _, _, _, unitName, unitId)
    if changeType == EFFECT_RESULT_FADED then return end  -- bewusst ignoriert, siehe Kopf
    local name    = CleanName(unitName)
    local nowMs   = GetGameTimeMilliseconds()
    local untilMs = endTime * 1000
    if untilMs <= nowMs then untilMs = nowMs + ALKOSH_FALLBACK_MS end

    if unitId and unitId ~= 0 then
        local t = GetTarget(unitId, name)
        t.alkoshBeginMs    = (beginTime or 0) * 1000
        t.alkoshUntilMs    = untilMs
        t.alkoshExpiryDone = false
        t.sawAlkosh        = true   -- ab jetzt haelt ein Boss seine Zeile (bis Kampfende)
    end
    if name ~= "" then activeByName[name] = untilMs end

    Dbg("Alkosh AN auf %s (id %s, noch %.1fs)", name, tostring(unitId), (untilMs - nowMs) / 1000)
end

local function OnZenTouchChanged(_, changeType, _, _, _, beginTime, endTime, _, _, _, _, _, _, unitName, unitId)
    if changeType == EFFECT_RESULT_FADED then return end
    if not unitId or unitId == 0 then return end
    local nowMs   = GetGameTimeMilliseconds()
    local untilMs = endTime * 1000
    if untilMs <= nowMs then untilMs = nowMs + ZEN_FALLBACK_MS end

    local t = GetTarget(unitId, CleanName(unitName))
    t.zenBeginMs = (beginTime or 0) * 1000
    t.zenUntilMs = untilMs
    Dbg("Z'en AN auf %s (noch %.1fs)", t.name, (untilMs - nowMs) / 1000)
end

-- Fallback-Zaehlung eigener DoTs (nur ohne LibCombat). Jeder eigene
-- Schadens-Debuff auf einem Gegner zaehlt als ein Stack, gedeckelt auf 5.
local function OnDotChanged(_, changeType, effectSlot, _, _, _, endTime, _, _, _, effectType, abilityType, _, unitName, unitId, abilityId)
    if not unitId or unitId == 0 then return end
    if abilityId == A.ZEN_TOUCH then return end
    if effectType ~= BUFF_EFFECT_TYPE_DEBUFF then return end
    if abilityType ~= ABILITY_TYPE_DAMAGE then return end

    local t   = GetTarget(unitId, CleanName(unitName))
    local key = tostring(effectSlot) .. ":" .. tostring(abilityId)
    if changeType == EFFECT_RESULT_FADED then
        t.dots[key] = nil
    else
        local endMs = (endTime or 0) * 1000
        if endMs > GetGameTimeMilliseconds() then t.dots[key] = endMs end
    end
end

-- LibCombat liefert die echten Z'en-Stacks. Signatur wie in EZOMetter:
--   (_, timeMs, unitId, abilityId, changeType, effectType, stacks, sourceType, effectSlot)
local function OnLibCombatEffectsOut(_, _timeMs, unitId, abilityId, _changeType, _effectType, stacks)
    abilityId = tonumber(abilityId) or 0
    if abilityId ~= A.ZEN_TOUCH then return end
    if not unitId or unitId == 0 then return end
    -- Name kennt LibCombat hier nicht; ein evtl. schon vorhandener Eintrag
    -- behaelt seinen Namen, ein neuer bekommt ihn spaeter aus EVENT_EFFECT_CHANGED.
    local t = GetTarget(unitId, "")
    t.libStacks = math.max(0, math.min(A.ZEN_MAX_STACKS, tonumber(stacks) or 0))
end

-------------------------------------------------------------------------------
-- Event-Registrierung
-------------------------------------------------------------------------------

local function RegisterDotFirehose(enable)
    if enable and not dotFirehoseOn then
        em:RegisterForEvent(A.name .. "_dots", EVENT_EFFECT_CHANGED, OnDotChanged)
        em:AddFilterForEvent(A.name .. "_dots", EVENT_EFFECT_CHANGED,
            REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
        dotFirehoseOn = true
    elseif not enable and dotFirehoseOn then
        em:UnregisterForEvent(A.name .. "_dots", EVENT_EFFECT_CHANGED)
        dotFirehoseOn = false
    end
end

local function TryRegisterLibCombat()
    if libCombatOn then return end
    if LibCombat and type(LibCombat.RegisterCallbackType) == "function" and LIBCOMBAT_EVENT_EFFECTS_OUT then
        LibCombat:RegisterCallbackType(LIBCOMBAT_EVENT_EFFECTS_OUT, OnLibCombatEffectsOut, A.name .. "_zenLib")
        libCombatOn = true
        A.zenStackSource = "LibCombat"
        Dbg("LibCombat fuer Z'en-Stacks registriert")
    end
end

function A.RegisterEffectEvents()
    em:UnregisterForEvent(A.name .. "_self",  EVENT_EFFECT_CHANGED)
    em:UnregisterForEvent(A.name .. "_group", EVENT_EFFECT_CHANGED)
    em:UnregisterForEvent(A.name .. "_zen",   EVENT_EFFECT_CHANGED)

    -- Eigenes Alkosh
    em:RegisterForEvent(A.name .. "_self", EVENT_EFFECT_CHANGED, OnAlkoshChanged)
    em:AddFilterForEvent(A.name .. "_self", EVENT_EFFECT_CHANGED,
        REGISTER_FILTER_ABILITY_ID, A.ALKOSH_LINEBREAKER,
        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

    -- Alkosh von Mitspielern (Source-Filter GROUP noetig, sonst kommt es nicht)
    if sv.includeGroup then
        em:RegisterForEvent(A.name .. "_group", EVENT_EFFECT_CHANGED, OnAlkoshChanged)
        em:AddFilterForEvent(A.name .. "_group", EVENT_EFFECT_CHANGED,
            REGISTER_FILTER_ABILITY_ID, A.ALKOSH_LINEBREAKER,
            REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_GROUP)
    end

    -- Touch of Z'en (eigenes)
    if sv.ui.showZen then
        em:RegisterForEvent(A.name .. "_zen", EVENT_EFFECT_CHANGED, OnZenTouchChanged)
        em:AddFilterForEvent(A.name .. "_zen", EVENT_EFFECT_CHANGED,
            REGISTER_FILTER_ABILITY_ID, A.ZEN_TOUCH,
            REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

        TryRegisterLibCombat()
        A.zenStackSource = libCombatOn and "LibCombat" or "DoT-Zaehlung"
        RegisterDotFirehose(not libCombatOn)   -- nur ohne LibCombat noetig
    else
        RegisterDotFirehose(false)
        A.zenStackSource = "aus"
    end
end

-------------------------------------------------------------------------------
-- Marker setzen / entfernen  (Alkosh-only, unveraendert im Verhalten)
-------------------------------------------------------------------------------

local function CanAssign()
    return (GetGameTimeMilliseconds() - lastAssign) >= ASSIGN_COOLDOWN
end

local function Assign(markerType)
    lastAssign = GetGameTimeMilliseconds()
    AssignTargetMarkerToReticleTarget(markerType)
end

local function ActivePool()
    if sv.useSecond then return sv.pool end
    return { sv.pool[1] }   -- nur das erste Symbol
end

local function IsPoolMarker(markerType)
    if markerType == TARGET_MARKER_TYPE_NONE then return false end
    for _, m in ipairs(ActivePool()) do
        if m == markerType then return true end
    end
    return false
end

local function Reconcile(name, current)
    for _, m in ipairs(ActivePool()) do
        local o = markerOwner[m]
        if o and o.name == name and current ~= m then
            markerOwner[m] = nil
        end
    end
end

local function PickFreeMarker(nowMs)
    for _, m in ipairs(ActivePool()) do
        local o = markerOwner[m]
        if not o or not o.untilMs or o.untilMs <= nowMs then return m end
    end
    return nil
end

local function PickStealableMarker(myDifficulty)
    local best, bestDifficulty
    for _, m in ipairs(ActivePool()) do
        local o = markerOwner[m]
        local dd = o and (o.difficulty or MONSTER_DIFFICULTY_NONE)
        if dd and dd < myDifficulty and (bestDifficulty == nil or dd < bestDifficulty) then
            best, bestDifficulty = m, dd
        end
    end
    return best
end

-- Liegt Alkosh auf dem Ziel unterm Fadenkreuz?
local function IsAlkoshOnReticle()
    local nowMs = GetGameTimeMilliseconds()
    for i = 1, GetNumBuffs("reticleover") do
        local _, _, timeEnding, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo("reticleover", i)
        if abilityId == A.ALKOSH_LINEBREAKER and timeEnding * 1000 > nowMs then
            return true, timeEnding * 1000, "Debuff-Liste"
        end
    end
    local untilMs = activeByName[CleanName(GetUnitName("reticleover"))]
    if untilMs and untilMs > nowMs then
        return true, untilMs, "Event"
    end
    return false, nil, nil
end
A.IsAlkoshOnReticle = IsAlkoshOnReticle

-- Anvisiertes Ziel als "wichtig" merken (Bossleiste, toedliche Schwierigkeit
-- oder sehr viel Leben). So erscheint die Ablauf-Warnung auch fuer Trainings-
-- puppen (Trial-Atronach) und Weltbosse ohne Bossleiste - nur normales Trash
-- bleibt aussen vor. Laeuft ungeachtet der Dungeon-Grenze, weil das Timer-
-- Fenster das auch tut.
local function NoteReticleImportance()
    if not DoesUnitExist("reticleover") then return end
    if GetUnitReaction("reticleover") ~= UNIT_REACTION_HOSTILE then return end
    local name = CleanName(GetUnitName("reticleover"))
    if name == "" or deadlyNames[name] then return end
    if IsReticleImportant() then
        deadlyNames[name] = true
        for _, t in pairs(targets) do
            if t.name == name then t.important = true end
        end
        Dbg("%s als wichtig erkannt (Warnung aktiv)", name)
    end
end

local function Update()
    if not sv.enabled then return end
    NoteReticleImportance()
    if not CanAssign() then return end

    if not DoesUnitExist("reticleover") or IsUnitDead("reticleover") then return end
    if GetUnitReaction("reticleover") ~= UNIT_REACTION_HOSTILE then return end
    if sv.onlyInstances and GetMapContentType() ~= MAP_CONTENT_DUNGEON then return end

    local difficulty = GetUnitDifficulty("reticleover")
    local name       = CleanName(GetUnitName("reticleover"))
    local current    = GetUnitTargetMarkerType("reticleover")
    local nowMs      = GetGameTimeMilliseconds()
    local wanted, untilMs, source = IsAlkoshOnReticle()

    Reconcile(name, current)

    if wanted then
        removeTries   = 0
        noAlkoshSince = nil

        if not sv.markAdds and not IsReticleBoss() then return end

        if IsPoolMarker(current) then
            markerOwner[current] = { name = name, untilMs = untilMs, difficulty = difficulty }
            return
        end
        if current ~= TARGET_MARKER_TYPE_NONE then return end

        local m = PickFreeMarker(nowMs) or PickStealableMarker(difficulty)
        if not m then
            Dbg("%s hat Alkosh, aber alle Pool-Marker sind an wichtigeren Zielen", name)
            return
        end
        Assign(m)
        markerOwner[m] = { name = name, untilMs = untilMs, difficulty = difficulty }
        Dbg("Marker %d gesetzt auf %s (Quelle: %s)", m, name, source)

    elseif IsPoolMarker(current) then
        noAlkoshSince = noAlkoshSince or nowMs
        if nowMs - noAlkoshSince < REMOVE_GRACE then return end

        if removeTries == 0 then
            Assign(current)
            removeTries = 1
            markerOwner[current] = nil
            Dbg("Marker %d entfernen, Versuch 1 (Toggle)", current)
        elseif removeTries == 1 then
            Assign(TARGET_MARKER_TYPE_NONE)
            removeTries = 2
            markerOwner[current] = nil
            Dbg("Marker %d entfernen, Versuch 2 (NONE)", current)
        elseif removeTries == 2 then
            removeTries = 3
            Msg("Marker liess sich nicht entfernen - bitte melden, dann bau ich es um.")
        end
    else
        removeTries   = 0
        noAlkoshSince = nil
    end
end

local function OnReticleTargetChanged()
    removeTries   = 0
    noAlkoshSince = nil
    Update()
end

-------------------------------------------------------------------------------
-- Diagnose-Zugriffe fuer die Optionen
-------------------------------------------------------------------------------

function A.GetMarkerOwners() return markerOwner end
function A.GetBossNames()    return bossNames end
function A.ActivePool()      return ActivePool() end

function A.ResetMarkerOwners()
    markerOwner   = {}
    removeTries   = 0
    noAlkoshSince = nil
end

-------------------------------------------------------------------------------
-- Initialisierung
-------------------------------------------------------------------------------

-- Fehlende (auch verschachtelte) Standardwerte nachfuellen, ohne die
-- gespeicherte Fensterposition zu verlieren.
local function FillDefaults(target, defaults)
    for k, v in pairs(defaults) do
        if type(v) == "table" then
            if type(target[k]) ~= "table" then target[k] = {} end
            FillDefaults(target[k], v)
        elseif target[k] == nil then
            target[k] = v
        end
    end
end

-- Kampfende raeumt die Boss-Dauerzeile auf: IsPersistentBoss wird dann falsch,
-- also entfernt der naechste Prune den (leeren) Boss von selbst.
local function OnCombatState(_, inCombatNow)
    inCombat = inCombatNow
end

local function OnPlayerActivated()
    targets      = {}
    activeByName = {}
    recentExpiry = {}
    deadlyNames  = {}
    markerOwner   = {}
    removeTries   = 0
    noAlkoshSince = nil
    inCombat      = false
    RefreshBossNames()
end

local function Initialize()
    sv = ZO_SavedVars:NewAccountWide("PitsZenkoshTrackerVars", 3, nil, A.defaults)
    FillDefaults(sv, A.defaults)
    A.sv = sv

    A.RegisterEffectEvents()

    em:RegisterForEvent(A.name .. "_reticle", EVENT_RETICLE_TARGET_CHANGED, OnReticleTargetChanged)
    em:RegisterForEvent(A.name .. "_zone",    EVENT_PLAYER_ACTIVATED,       OnPlayerActivated)
    em:RegisterForEvent(A.name .. "_bosses",  EVENT_BOSSES_CHANGED,         RefreshBossNames)
    em:RegisterForEvent(A.name .. "_combat",  EVENT_PLAYER_COMBAT_STATE,    OnCombatState)
    em:RegisterForUpdate(A.name .. "_tick", UPDATE_INTERVAL, Update)

    if A.InitUI       then A.InitUI()       end
    if A.InitSettings then A.InitSettings() end

    Dbg("geladen (Z'en-Stacks: %s)", A.zenStackSource)
end

em:RegisterForEvent(A.name, EVENT_ADD_ON_LOADED, function(_, addonName)
    if addonName ~= A.name then return end
    em:UnregisterForEvent(A.name, EVENT_ADD_ON_LOADED)
    Initialize()
end)
