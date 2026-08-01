DsRGuildPvPcountPlayer = DsRGuildPvPcountPlayer or {}
local PvP = DsRGuildPvPcountPlayer

------------------------------------------------------------
-- Kern-Datenstrukturen
------------------------------------------------------------
PvP                 = PvP or {}
PvP.AllianceCache   = PvP.AllianceCache   or {}
PvP.NPC_NAMES       = PvP.NPC_NAMES       or {}
PvP.STRUCTURE_NAMES = PvP.STRUCTURE_NAMES or {}
PvP.BurstTimeline   = PvP.BurstTimeline   or {}
PvP.BurstInfo       = PvP.BurstInfo       or {}

DsRPlayerDBData_SV.playerDB = DsRPlayerDBData_SV.playerDB or {}

-- SavedVariables Root (nur PlayerDB & UI, keine Ability-Datenbank)
DsRGuildHallPvP_SV = DsRGuildHallPvP_SV or nil
DsRPlayerDBData_SV = DsRPlayerDBData_SV or nil

PvP.TriggerSoftUnitScanSoon = false
PvP.hiddenShortly           = false

-- Dynamische Scan-Frequenz (Miat-Style)
PvP.lastActivity  = 0
PvP.hardBoostEnd  = 0 

-- DebugMode UI
PvP.DebugLog  = PvP.DebugLog or {}
PvP.DEBUG_MAX = 200

------------------------------------------------------------
-- Timings / Settings
------------------------------------------------------------

PvP.CLEANUP_INTERVAL = 2000   -- ms
PvP.SOFT_TIMEOUT     = 15     -- s
PvP.OUTPUT_INTERVAL  = 500    -- ms

local BURST_WINDOW     = 700  -- ms (Miat’s nutzt 700–900)
local BURST_MIN_EVENTS = 2

local ALLIANCE_COLORS = {
    [ALLIANCE_ALDMERI_DOMINION]    = "|cFFD700",
    [ALLIANCE_DAGGERFALL_COVENANT] = "|c4169E1",
    [ALLIANCE_EBONHEART_PACT]      = "|cB22222",
    ["UNK"]                        = "|cBFBFBF",
}

PvP.NPC_PREFIXES = {
    -- Allianz / Fraktionen (DE)
    "aldmeri", "ebenerz", "pakt", "dolchsturz", "dagerfall", "allianz",
    "legion", "legionär", "imperial", "kaiserlich", "bündnis",

    -- Allianz / Fraktionen (EN)
    "aldmeri", "ebonheart", "daggerfall", "covenant",
    "legion", "imperial", "dominion", "pact",

    -- Rollen / generische NPC-Typen (DE)
    "soldat", "magier", "heiler", "wache", "turmwache",
    "belagerungs", "ingenieur", "söldner", "kultist",
    "totenbeschwörer", "nekromant", "beschwörer", "ritualist",
    "wurmkult", "gardist",

    -- Rollen / generische NPC-Typen (EN)
    "soldier", "mage", "healer", "guard", "tower guard",
    "siege", "engineer", "mercenary", "cultist",
    "necromancer", "summoner", "ritualist",
    "worm cult",

    -- Daedra / Xivkyn / Molag Bal (DE)
    "dremora", "xivkyn", "daedra", "daedroth", "clannbann", "clannfear",
    "ogrim", "scamp", "harvester", "lurcher", "gargoyle", "titan",
    "molag", "atronach", "kreatur", "bestie", "abscheulich", "zwielicht",

    -- Daedra / Xivkyn / Molag Bal (EN)
    "dremora", "xivkyn", "daedra", "daedroth", "clannfear",
    "ogrim", "scamp", "harvester", "lurcher", "gargoyle", "titan",
    "molag", "atronach", "creature", "beast", "abomination", "twilight",

    -- Untote / Kult / IC-Mob (DE)
    "fleischatronach", "knochengolem", "zombie", "skelett",
    "geist", "phantom", "schatten",

    -- Untote / Kult / IC-Mob (EN)
    "flesh atronach", "bone golem", "zombie", "skeleton",
    "spirit", "phantom", "shade",

    -- Boss-/Rang-Prefixes (DE)
    "general", "hauptmann", "kommandant", "oberkultist", "charr",

    -- Boss-/Rang-Prefixes (EN)
    "general", "captain", "commander", "high cultist",

    -- diverses
    "offline",
}

------------------------------------------------------------
-- SoftScan-Tags
------------------------------------------------------------

PvP.SOFTSCAN_TAGS = {
    -- Direkte Ziele
    "reticleover",
    "player",

    -- Gruppenmitglieder (falls vorhanden)
    "group1", "group2", "group3", "group4",
    "group5", "group6", "group7", "group8",
    "group9", "group10", "group11", "group12",
    "group13", "group14", "group15", "group16",
    "group17", "group18", "group19", "group20",
    "group21", "group22", "group23", "group24",

    -- Spieler in der Nähe (ESO vergibt diese dynamisch)
    "playerally1", "playerally2", "playerally3", "playerally4",
    "playerally5", "playerally6", "playerally7", "playerally8",
    "playerally9", "playerally10", "playerally11", "playerally12",
    "playerally13", "playerally14", "playerally15", "playerally16",
    "playerally17", "playerally18", "playerally19", "playerally20",
    "playerally21", "playerally22", "playerally23", "playerally24",
    "playerally25", "playerally26", "playerally27", "playerally28",
    "playerally29", "playerally30", "playerally31", "playerally32",
    "playerally33", "playerally34", "playerally35", "playerally36",
    "playerally37", "playerally38", "playerally39", "playerally40",

    -- Bosse / große Einheiten (manchmal Spieler in BGs)
    "boss1", "boss2", "boss3", "boss4", "boss5", "boss6",

    -- Interactables (manchmal Spieler in AVA-Objekten)
    "interact1", "interact2", "interact3", "interact4",
    "interact5", "interact6", "interact7", "interact8",

    -- AVA Capture Points (Spieler in der Nähe von Flaggen)
    "avacapture1", "avacapture2", "avacapture3", "avacapture4",
    "avacapture5", "avacapture6", "avacapture7", "avacapture8",

    -- Companions (werden durch IsRealCombatPlayer gefiltert)
    "companion1", "companion2", "companion3", "companion4",
}

------------------------------------------------------------
-- Helper: Namensnormalisierung
------------------------------------------------------------

local function NormalizeName(name)
    if not name or name == "" then return nil end
    name = zo_strformat("<<1>>", name)
    name = string.lower(name)
    name = string.gsub(name, "%^.+", "")
    return name
end

function PvP.GetBestName(unitTagOrName)
    if type(unitTagOrName) == "string" and DoesUnitExist(unitTagOrName) then
        local acc = GetUnitDisplayName(unitTagOrName)
        if acc and acc ~= "" then
            return NormalizeName(acc)
        end

        local raw = GetUnitName(unitTagOrName)
        if raw and raw ~= "" then
            return NormalizeName(raw)
        end

        return nil
    end

    local name = NormalizeName(unitTagOrName)
    if not name or name == "" then return nil end

    return name
end

function PvP.IsNpcName(name)
    if not name or name == "" then return true end

    local lower = string.lower(name)

    for _, prefix in ipairs(PvP.NPC_PREFIXES) do
        if lower:find(prefix, 1, true) then
            return true
        end
    end
    return false
end

------------------------------------------------------------
-- DEBUG
------------------------------------------------------------

function PvP.GetColoredAlliance(alliance)
    local color = ALLIANCE_COLORS[alliance] or ALLIANCE_COLORS["UNK"]
    local text

    if alliance == ALLIANCE_ALDMERI_DOMINION then
        text = "AD"
    elseif alliance == ALLIANCE_DAGGERFALL_COVENANT then
        text = "DC"
    elseif alliance == ALLIANCE_EBONHEART_PACT then
        text = "EP"
    else
        text = "UNK"
    end

    return string.format("%s%s|r", color, text)
end

function PvP.AddDebug(eventType, name, data)
    local now = GetTimeStamp()

    table.insert(PvP.DebugLog, 1, {
        ts   = now,
        type = eventType,
        name = name or "",
        data = data or "",
    })

    if #PvP.DebugLog > PvP.DEBUG_MAX then
        table.remove(PvP.DebugLog)
    end

    if PvP.UpdateDebugUI then
        PvP.UpdateDebugUI()
    end
end

------------------------------------------------------------
-- BURST
------------------------------------------------------------

local function RecordBurstEvent(name)
    name = NormalizeName(name)
    if not name then return end

    PvP.BurstTimeline[name] = PvP.BurstTimeline[name] or {}

    table.insert(PvP.BurstTimeline[name], {
        ts = GetTimeStamp()
    })

    if #PvP.BurstTimeline[name] > 20 then
        table.remove(PvP.BurstTimeline[name], 1)
    end
end

local function DetectBurst(name)
    local timeline = PvP.BurstTimeline[name]
    if not timeline or #timeline < 2 then return false end

    local now = GetTimeStamp()
    local count = 0

    for i = #timeline, 1, -1 do
        local e = timeline[i]
        if now - e.ts <= BURST_WINDOW then
            count = count + 1
        else
            break
        end
    end

    return count >= BURST_MIN_EVENTS
end

local function MarkBurst(name, reason)
    local now = GetTimeStamp()
    PvP.hardBoostEnd = now + 0.5
    PvP.lastActivity = now

    name = NormalizeName(name)
    if not name then return end

    PvP.BurstInfo[name] = {
        ts = now,
        reason = reason,
    }
end

------------------------------------------------------------
-- PlayerDB (SavedVariables)
------------------------------------------------------------

function PvP.EnsureDB(name)
    name = NormalizeName(name)
    if not name then return end

    -- DsRPlayerDBData_SV.playerDB = DsRPlayerDBData_SV.playerDB or {}
    local db = DsRPlayerDBData_SV.playerDB
    
    db[name] = db[name] or {}
    local entry = db[name]

    entry.name          = entry.name          or name
    entry.displayName   = entry.displayName   or ""
    entry.alliance      = entry.alliance      or ALLIANCE_NONE
    entry.allianceRank  = entry.allianceRank  or 0
    entry.lastSeen      = entry.lastSeen      or 0
end

function PvP.UpdateDB(name, alliance, displayName)
    name = NormalizeName(name)
    if not name then return end

    PvP.EnsureDB(name)

    local db    = DsRPlayerDBData_SV.playerDB
    local entry = db[name]
    if not entry then return end

    local now = GetTimeStamp()

    if displayName and displayName ~= "" then
        entry.displayName             = displayName
    end

    if alliance and alliance ~= ALLIANCE_NONE then
        entry.alliance             = alliance
    end

    entry.lastSeen              = now
end

------------------------------------------------------------
-- Allianz ermitteln & setzen
------------------------------------------------------------

function PvP.GetAlliance(name)
    if not name then
        return ALLIANCE_NONE
    end

    name = NormalizeName(name)
    if not name then return ALLIANCE_NONE end

    local cached = PvP.AllianceCache[name]
    if cached and cached ~= ALLIANCE_NONE then
        return cached
    end

    local unitTags = {
        "reticleover",
        "player",
        "companion",
    }

    for i = 1, 24 do
        unitTags[#unitTags+1] = "group" .. i
    end

    for i = 1, 6 do
        unitTags[#unitTags+1] = "boss" .. i
    end

    for _, tag in ipairs(unitTags) do
        if DoesUnitExist(tag) then
            local raw = GetUnitName(tag)
            if raw and raw ~= "" then
                local n = NormalizeName(raw)
                if n == name then
                    local a = GetUnitAlliance(tag)

                    if a and a ~= ALLIANCE_NONE then
                        PvP.AllianceCache[name] = a
                    end

                    return a
                end
            end
        end
    end

    return ALLIANCE_NONE
end

function PvP.ResolveAlliance(name)
    name = NormalizeName(name)
    if not name then return ALLIANCE_NONE end

    -- Cache zuerst prüfen
    if PvP.AllianceCache[name] and PvP.AllianceCache[name] ~= ALLIANCE_NONE then
        return PvP.AllianceCache[name]
    end

    -- Alle relevanten UnitTags durchgehen
    local tags = {
        "reticleover", "player",
    }

    for i = 1, 24 do tags[#tags+1] = "group" .. i end
    for i = 1, 6  do tags[#tags+1] = "boss" .. i end
    for i = 1, 40 do tags[#tags+1] = "playerally" .. i end

    for _, tag in ipairs(tags) do
        if DoesUnitExist(tag) then
            local raw = GetUnitName(tag)
            if raw and NormalizeName(raw) == name then
                local a = GetUnitAlliance(tag)
                if a and a ~= ALLIANCE_NONE then
                    PvP.AllianceCache[name] = a
                    return a
                end
            end
        end
    end

    return ALLIANCE_NONE
end

function PvP.ApplyFinalAlliance(name, forcedAlliance)
    name = NormalizeName(name)
    if not name then return end

    local entry = DsRPlayerDBData_SV.playerDB[name]
    if not entry then return end

    -- 1. Harte Quelle (Killfeed, Reticle)
    if forcedAlliance and forcedAlliance ~= ALLIANCE_NONE then
        entry.alliance = forcedAlliance
        PvP.AllianceCache[name] = forcedAlliance
        PvP.UpdateDB(name, forcedAlliance, nil)
        if DsRGuildHallPvP_SV.uiUnknown then
            PvP.AddDebug("|cFFBF00AllianceHard|r", name .. " (" .. PvP.GetColoredAlliance(forcedAlliance) .. ")", "A=" .. forcedAlliance)
        end
        return
    end

    -- 2. SoftScan / Resolver
    local resolved = PvP.ResolveAlliance(name)
    if resolved ~= ALLIANCE_NONE and entry.alliance ~= resolved then
        entry.alliance = resolved
        PvP.AllianceCache[name] = resolved
        PvP.UpdateDB(name, resolved, nil)
        if DsRGuildHallPvP_SV.uiUnknown then
            PvP.AddDebug("|cFFBF00AllianceSoft|r", name .. " (" .. PvP.GetColoredAlliance(resolved) .. ")", "A=" .. resolved)
        end
    end
end

------------------------------------------------------------
-- Spieler-Registrierung
------------------------------------------------------------

function PvP.RegisterPlayer(name, unitType, source)
    if not name or name == "" then return end

    name = NormalizeName(name)
    if not name then return end

    -- if not PvP.IsRealCombatPlayer(name, unitType or COMBAT_UNIT_TYPE_PLAYER) then
    --     return
    -- end

    local now   = GetTimeStamp()
    local entry = DsRPlayerDBData_SV.playerDB[name]

    if not entry then
        DsRPlayerDBData_SV.playerDB[name] = {
            name         = name,
            alliance     = ALLIANCE_NONE,
            lastSeen     = now,
            displayName  = "",
            allianceRank = 0,
        }
        PvP.UpdateDB(name, ALLIANCE_NONE, nil)
    end

    if source == "OnKillFeed" then
        return
    elseif entry then
        entry.lastSeen = now
    end
end

------------------------------------------------------------
-- Spieler zählen für UI
------------------------------------------------------------

function PvP.IsNPC(unitTag, name)
    if not name or name == "" then
        return true
    end

    name = NormalizeName(name)

    PvP.STRUCTURE_NAMES = PvP.STRUCTURE_NAMES or {}
    if PvP.STRUCTURE_NAMES[name] then
        return true
    end

    if unitTag and type(unitTag) == "string" and DoesUnitExist(unitTag) then
        local displayName = GetUnitDisplayName(unitTag)

        if displayName and displayName ~= "" then
            return false
        end

        return true
    end

    if string.find(name, " ") then
        return false
    end

    if string.find(name, "-") then
        return true
    end

    return false
end

function PvP.CountPlayers()
    local ad, dc, ep, unk = 0, 0, 0, 0
    local now = GetTimeStamp()

    for _, entry in pairs(DsRPlayerDBData_SV.playerDB) do
        repeat
            if not entry or not entry.name then break end

            local name = entry.name

            if PvP.NPC_NAMES[name] then break end
            if PvP.STRUCTURE_NAMES[name] then break end
            if entry.inactive then break end
            local lastSeen = entry.lastSeen or 0

            if now - lastSeen > PvP.SOFT_TIMEOUT then
                break
            end

            local a = entry.alliance or ALLIANCE_NONE

            if a == ALLIANCE_ALDMERI_DOMINION then
                ad = ad + 1
            elseif a == ALLIANCE_DAGGERFALL_COVENANT then
                dc = dc + 1
            elseif a == ALLIANCE_EBONHEART_PACT then
                ep = ep + 1
            else
                unk = unk + 1
            end
        until true
    end

    return ad, dc, ep, unk
end

------------------------------------------------------------
-- Soft Unit Scan (Miat-Style)
------------------------------------------------------------

function PvP.ScanSoftUnits()
    if not PvP.IsInPvP() then return end

    local myName = NormalizeName(GetUnitName("player"))
    for _, tag in ipairs(PvP.SOFTSCAN_TAGS) do
        repeat
            if not DoesUnitExist(tag) then break end
            if not IsUnitPlayer(tag) then break end
            
            local rawName = GetUnitName(tag)
            if not rawName or rawName == "" then break end
            
            local name = NormalizeName(rawName)
            if not name or name == myName then break end
            
            -- NPC / Struktur / Companion / Pet raus
            local unitType = GetUnitType(tag)
            if not PvP.IsRealCombatPlayer(name, unitType) then break end

            local now = GetTimeStamp()
            -- Spieler registrieren
            PvP.RegisterPlayer(name, unitType, "ScanSoftUnits")
            PvP.lastActivity = now
            
            -- Allianz setzen
            local alliance     = GetUnitAlliance(tag)
            local displayName  = GetUnitDisplayName(tag)
            local allianceRank = GetUnitAvARank(tag)

            if DsRGuildHallPvP_SV.uiUnknown then
                PvP.AddDebug("|cFFBF00SoftScan|r", name .. " (" .. PvP.GetColoredAlliance(alliance) .. ")", "tag=" .. tag)
            end

            if alliance and alliance ~= ALLIANCE_NONE then
                PvP.UpdateDB(name, alliance, displayName)
                DsRPlayerDBData_SV.playerDB[name].alliance     = alliance
                DsRPlayerDBData_SV.playerDB[name].allianceRank = allianceRank
                PvP.AllianceCache[name]                        = alliance
            else
                PvP.UpdateDB(name, nil, displayName)
            end
        until true
    end
end

function PvP.IsRealCombatPlayer(name, unitType)
    if not name or name == "" then return false end

    name = NormalizeName(name)

    -- NPC / Struktur raus
    if PvP.NPC_NAMES and PvP.NPC_NAMES[name] then return false end
    if PvP.STRUCTURE_NAMES and PvP.STRUCTURE_NAMES[name] then return false end

    -- UnitType-Test:
    -- Wir blockieren nur harte NPC-Typen.
    -- SoftScan liefert oft NONE (0), das ist OK.
    if unitType == COMBAT_UNIT_TYPE_NONE
    or unitType == COMBAT_UNIT_TYPE_INTERACTABLE
    or unitType == COMBAT_UNIT_TYPE_OBJECT
    or unitType == COMBAT_UNIT_TYPE_TARGET_DUMMY then
        return false
    end

    return true
end

------------------------------------------------------------
-- EVENT: Killfeed (beste Allianzquelle)
------------------------------------------------------------

function PvP.OnKillFeed(_, killLocation,
    sourceDisplayName, sourceCharacterName, sourceAlliance,
    sourceRank, targetDisplayName, targetCharacterName,
    targetAlliance, targetRank)

    killerName = NormalizeName(sourceCharacterName)
    victimName = NormalizeName(targetCharacterName)

    local now = GetTimeStamp()
    PvP.hardBoostEnd = now + 1
    PvP.lastActivity = now

    local function IsReal(name, alliance)
        if not name or name == "" then return false end
        if alliance == ALLIANCE_NONE then return false end
        if PvP.NPC_NAMES[name] then return false end
        if PvP.STRUCTURE_NAMES[name] then return false end
        return true
    end

    if IsReal(killerName, sourceAlliance) then
        PvP.RegisterPlayer(killerName, COMBAT_UNIT_TYPE_PLAYER, "OnKillFeed")
        local entry = DsRPlayerDBData_SV.playerDB[killerName]
        if entry then
            entry.alliance     = sourceAlliance
            entry.allianceRank = sourceRank
            entry.displayName  = sourceDisplayName
        end
        MarkBurst(killerName, "kill")
        if DsRGuildHallPvP_SV.uiUnknown then
            PvP.AddDebug("|cFFBF00Killfeed|r Killer ", killerName .. " (" .. PvP.GetColoredAlliance(sourceAlliance) .. ")", "Rank=" .. sourceRank)
        end
    end

    if IsReal(victimName, targetAlliance) then
        PvP.RegisterPlayer(victimName, COMBAT_UNIT_TYPE_PLAYER, "OnKillFeed")
        local entry = DsRPlayerDBData_SV.playerDB[victimName]
        if entry then
            entry.alliance     = targetAlliance
            entry.allianceRank = targetRank
            entry.displayName  = targetDisplayName
        end
        if DsRGuildHallPvP_SV.uiUnknown then
            PvP.AddDebug("|cFFBF00Killfeed|r Opfer ", victimName .. " (" .. PvP.GetColoredAlliance(targetAlliance) .. ")", "Rank=" .. targetRank)
        end
    end

    PvP.TriggerSoftUnitScanSoon = true
    PvP.hardBoostEnd = GetTimeStamp() + 0.5
end

------------------------------------------------------------
-- EVENT: Reticle Target (direkte Allianz)
------------------------------------------------------------

function PvP.OnReticleTargetChanged()
    if not PvP.IsInPvP() then return end

    local tag = "reticleover"
    if not DoesUnitExist(tag) then return end
    if not IsUnitPlayer(tag) then return end  -- WICHTIG!

    local rawName = GetUnitName(tag)
    if not rawName or rawName == "" then return end

    local name = NormalizeName(rawName)
    if not name then return end

    local myName = NormalizeName(GetUnitName("player"))
    if name == myName then return end

    local unitType = GetUnitType(tag)
    local now      = GetTimeStamp() 

    PvP.RegisterPlayer(name, unitType, "OnReticleTargetChanged")

    local alliance     = GetUnitAlliance(tag)
    local displayName  = GetUnitDisplayName(tag)
    local allianceRank = GetUnitAvARank(tag)

    if alliance and alliance ~= ALLIANCE_NONE then
        PvP.UpdateDB(name, alliance, displayName)
        DsRPlayerDBData_SV.playerDB[name].alliance     = alliance
        DsRPlayerDBData_SV.playerDB[name].allianceRank = allianceRank
        PvP.AllianceCache[name]                        = alliance
    end
    if DsRGuildHallPvP_SV.uiUnknown then
        PvP.AddDebug("|cFFBF00Reticle|r ", name .. " (" .. PvP.GetColoredAlliance(alliance) .. ")", "")
    end

    PvP.TriggerSoftUnitScanSoon = true
    PvP.hardBoostEnd = now + 0.5
end

------------------------------------------------------------
-- EVENT: Buffs / Debuffs (Heuristik, Weg A)
------------------------------------------------------------

function PvP.OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag,
    beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType,
    statusEffectType, unitName, unitId, abilityId, sourceType)

    if not PvP.IsInPvP() then return end
    if unitName:find("%^[mfnMFN]$") then return end

    -- Name auslesen (immer vorhanden)
    local rawName = unitName
    if not rawName or rawName == "" then return end

    local name = NormalizeName(rawName)
    if not name then return end

    -- eigenen Spieler ignorieren
    local myName = NormalizeName(GetUnitName("player"))
    if name == myName then return end

    -- NPC-Namen filtern und ignorieren
    if PvP.IsNpcName(name) then
        return
    end

    local now      = GetTimeStamp()
    local unitType = unitTag and GetUnitType(unitTag) or COMBAT_UNIT_TYPE_PLAYER

    -- Spieler registrieren
    PvP.RegisterPlayer(name, unitType, "OnEffectChanged")
    local entry = DsRPlayerDBData_SV.playerDB[name]

    local alliance = entry and entry.alliance or ""

    PvP.lastActivity = now
    if DsRGuildHallPvP_SV.uiUnknown then
        PvP.AddDebug("|cFFBF00Effect|r", name .. " (" .. PvP.GetColoredAlliance(alliance) .. ") " .. alliance .. " -> SourceType: " .. sourceType, "")
    end

    -- SoftScan triggern
    PvP.TriggerSoftUnitScanSoon = true
    PvP.hardBoostEnd = now + 0.5
end

------------------------------------------------------------
-- EVENT: Player Activated
------------------------------------------------------------

function PvP.OnPlayerActivated()
    if PvP.IsInPvP() then
        PvP.RegisterPvPEvents()
    else
        PvP.UnregisterPvPEvents()
        PvP.UI.window:SetHidden(true)
    end

    if not PvP.IsInPvP or not PvP.IsInPvP() then PvP.UI.window:SetHidden(true) return end

    local rawName = GetUnitName("player")
    if not rawName or rawName == "" then return end

    local myName = NormalizeName(rawName)
    if not myName then return end

    local myDisplay = GetUnitDisplayName("player")
    local myAlliance = GetUnitAlliance("player")

    PvP.MyName        = myName
    PvP.MyDisplayName = myDisplay

    PvP.UpdateDB(myName, myAlliance, myDisplay)

    -- DsRPlayerDBData_SV.playerDB = DsRPlayerDBData_SV.playerDB or {}

    PvP.TriggerSoftUnitScanSoon = true
end

------------------------------------------------------------
-- Soft Cleanup
------------------------------------------------------------

function PvP.CleanupPlayers()
    if not PvP.IsInPvP or not PvP.IsInPvP() then return end

    local now     = GetTimeStamp()
    local timeout = PvP.SOFT_TIMEOUT

    for _, data in pairs(DsRPlayerDBData_SV.playerDB) do
        if data then
            if data.lastSeen then
                -- Spieler ist aktiv, wenn lastSeen innerhalb des Timeouts liegt
                if now - data.lastSeen > timeout then
                    data.inactive = true
                elseif data.lastSeen <= (now - 31550000) then  -- Wenn Spieler schon seid 1 jahr nicht mehr gesehen, wird dieser komplett entfernt
                    DsRPlayerDBData_SV.playerDB[name] = nil
                else
                    data.inactive = false
                end
            else
                -- Falls lastSeen fehlt → sicherheitshalber inactive
                data.inactive = true
            end
        end
    end
end

------------------------------------------------------------
-- PvP Status Check
------------------------------------------------------------

function PvP.IsInPvP()
    if IsActiveWorldBattleground() then return false end
    if IsPlayerInAvAWorld() then return true end
    return false
end

------------------------------------------------------------
-- UI: Count Display
------------------------------------------------------------

local function CreateCountUI()
    local ui = WINDOW_MANAGER:CreateTopLevelWindow("DsR_CountUI")
    ui:SetDimensions(240, 100)
    ui:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, DsRGuildHallPvP_SV.uiX, DsRGuildHallPvP_SV.uiY)
    ui:SetMovable(true)
    ui:SetMouseEnabled(true)
    ui:SetClampedToScreen(true)
    ui:SetHidden(true)

    ui:SetHandler("OnMoveStop", function(self)
        local x, y = self:GetLeft(), self:GetTop()
        DsRGuildHallPvP_SV.uiX = x
        DsRGuildHallPvP_SV.uiY = y
    end)

    local iconSize = 40
    local spacing  = 40

    local adIcon = WINDOW_MANAGER:CreateControl("$(parent)ADIcon", ui, CT_TEXTURE)
    adIcon:SetDimensions(iconSize, iconSize)
    adIcon:SetAnchor(TOPLEFT, ui, TOPLEFT, 10, 10)
    adIcon:SetTexture("/esoui/art/ava/ava_hud_emblem_aldmeri.dds")

    local dcIcon = WINDOW_MANAGER:CreateControl("$(parent)DCIcon", ui, CT_TEXTURE)
    dcIcon:SetDimensions(iconSize, iconSize)
    dcIcon:SetAnchor(TOPLEFT, adIcon, TOPLEFT, spacing, 0)
    dcIcon:SetTexture("/esoui/art/ava/ava_hud_emblem_daggerfall.dds")

    local epIcon = WINDOW_MANAGER:CreateControl("$(parent)EPIcon", ui, CT_TEXTURE)
    epIcon:SetDimensions(iconSize, iconSize)
    epIcon:SetAnchor(TOPLEFT, dcIcon, TOPLEFT, spacing, 0)
    epIcon:SetTexture("/esoui/art/ava/ava_hud_emblem_ebonheart.dds")

    local unkIcon = WINDOW_MANAGER:CreateControl("$(parent)UNKIcon", ui, CT_TEXTURE)
    unkIcon:SetDimensions(iconSize, iconSize)
    unkIcon:SetAnchor(TOPLEFT, epIcon, TOPLEFT, spacing, 0)
    unkIcon:SetTexture("/esoui/art/menubar/menubar_help_up.dds")
    unkIcon:SetColor(0.75, 0.75, 0.75, 1)

    local adLabel = WINDOW_MANAGER:CreateControl("$(parent)ADLabel", ui, CT_LABEL)
    adLabel:SetAnchor(TOP, adIcon, BOTTOM, 0, -3)
    adLabel:SetFont("$(BOLD_FONT)|35|soft-shadow-thick")
    adLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    local dcLabel = WINDOW_MANAGER:CreateControl("$(parent)DCLabel", ui, CT_LABEL)
    dcLabel:SetAnchor(TOP, dcIcon, BOTTOM, 0, -3)
    dcLabel:SetFont("$(BOLD_FONT)|35|soft-shadow-thick")
    dcLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    local epLabel = WINDOW_MANAGER:CreateControl("$(parent)EPLabel", ui, CT_LABEL)
    epLabel:SetAnchor(TOP, epIcon, BOTTOM, 0, -3)
    epLabel:SetFont("$(BOLD_FONT)|35|soft-shadow-thick")
    epLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    local unkLabel = WINDOW_MANAGER:CreateControl("$(parent)UNKLabel", ui, CT_LABEL)
    unkLabel:SetAnchor(TOP, unkIcon, BOTTOM, 0, -3)
    unkLabel:SetFont("$(BOLD_FONT)|35|soft-shadow-thick")
    unkLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    unkLabel:SetColor(0.75, 0.75, 0.75, 1)

    local adSee = WINDOW_MANAGER:CreateControl("$(parent)adSee", ui, CT_LABEL)
    adSee:SetAnchor(TOP, adLabel, BOTTOM, 0, -3)
    adSee:SetFont("ZoFontGameSmall")
    adSee:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    local dcSee = WINDOW_MANAGER:CreateControl("$(parent)dcSee", ui, CT_LABEL)
    dcSee:SetAnchor(TOP, dcLabel, BOTTOM, 0, -3)
    dcSee:SetFont("ZoFontGameSmall")
    dcSee:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    local epSee = WINDOW_MANAGER:CreateControl("$(parent)epSee", ui, CT_LABEL)
    epSee:SetAnchor(TOP, epLabel, BOTTOM, 0, -3)
    epSee:SetFont("ZoFontGameSmall")
    epSee:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    local unkSee = WINDOW_MANAGER:CreateControl("$(parent)unkSee", ui, CT_LABEL)
    unkSee:SetAnchor(TOP, unkLabel, BOTTOM, 0, -3)
    unkSee:SetFont("ZoFontGameSmall")
    unkSee:SetHorizontalAlignment(TEXT_ALIGN_CENTER)



    PvP.UI = {
        window   = ui,
        adLabel  = adLabel,
        dcLabel  = dcLabel,
        epLabel  = epLabel,
        unkLabel = unkLabel,
        unkIcon  = unkIcon,
        adSee    = adSee,
        dcSee    = dcSee,
        epSee    = epSee,
        unkSee   = unkSee,
    }
end

function PvP.UpdateUI()
    if not PvP.UI then return end

    if not PvP.IsInPvP() or not DsRGuildHallPvP_SV.uiEnabled then
        PvP.UI.window:SetHidden(true)
        return
    end

    local ad, dc, ep, unk = PvP.CountPlayers()

    if PvP.hiddenShortly == false then PvP.UI.window:SetHidden(false) end

    PvP.UI.adLabel:SetText(string.format("|cFFD700%d|r", ad))
    PvP.UI.dcLabel:SetText(string.format("|c4169E1%d|r", dc))
    PvP.UI.epLabel:SetText(string.format("|cB22222%d|r", ep))

    if DsRGuildHallPvP_SV.PlayerStatic then
        local allianceCount = {}

        for playerName, data in pairs(DsRPlayerDBData_SV.playerDB) do
            local a = data.alliance or 0
            allianceCount[a] = (allianceCount[a] or 0) + 1
        end

        PvP.UI.unkSee:SetText(allianceCount[0])
        PvP.UI.adSee:SetText(string.format("|cFFD700%d|r", allianceCount[1]))
        PvP.UI.dcSee:SetText(string.format("|c4169E1%d|r", allianceCount[3]))
        PvP.UI.epSee:SetText(string.format("|cB22222%d|r", allianceCount[2]))

        PvP.UI.adSee:SetHidden(false)
        PvP.UI.dcSee:SetHidden(false)
        PvP.UI.epSee:SetHidden(false)
    else
        PvP.UI.adSee:SetHidden(true)
        PvP.UI.dcSee:SetHidden(true)
        PvP.UI.epSee:SetHidden(true)       
    end

    if DsRGuildHallPvP_SV.UNKPlayer then
        PvP.UI.unkLabel:SetText(string.format("|cBFBFBF%d|r", unk))
        PvP.UI.unkLabel:SetHidden(false)
        PvP.UI.unkIcon:SetHidden(false)
        PvP.UI.unkSee:SetHidden(false)
    else
        PvP.UI.unkLabel:SetHidden(true)
        PvP.UI.unkIcon:SetHidden(true)
        PvP.UI.unkSee:SetHidden(true)
    end
end

------------------------------------------------------------
-- UI automatisch ausblenden, wenn Menüs geöffnet sind
------------------------------------------------------------

local function UpdateUIVisibility(hidden)
    PvP.hiddenShortly = hidden

    if GetInteractionType() == INTERACTION_SIEGE then return end

    if PvP.hiddenShortly then
        if PvP.IsInPvP() and DsRGuildHallPvP_SV.uiEnabled and PvP.UI then
            PvP.UI.window:SetHidden(true)
        end
        if PvP.IsInPvP() and DsRGuildHallPvP_SV.uiUnknown and PvP.UIDebug then
            PvP.UIDebug.window:SetHidden(true)
        end
    else
        if PvP.IsInPvP() and DsRGuildHallPvP_SV.uiEnabled and PvP.UI then
            PvP.UI.window:SetHidden(false)
        end
        if PvP.IsInPvP() and DsRGuildHallPvP_SV.uiUnknown and PvP.UIDebug then
           PvP.UIDebug.window:SetHidden(false)
        end
    end
end

------------------------------------------------------------
-- Debug Overlay
------------------------------------------------------------

local function CreateDebugUI()
    local ui = WINDOW_MANAGER:CreateTopLevelWindow("DsRDebugWindow")
    ui:SetDimensions(600, 800)
    ui:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 50, 50)
    ui:SetMovable(true)
    ui:SetMouseEnabled(true)
    ui:SetHidden(false)

    -- WICHTIG: Fenster global speichern!
    DsR_PvPDebugUI = ui

    local bg = WINDOW_MANAGER:CreateControl(nil, ui, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0, 0, 0, 0.6)
    bg:SetEdgeColor(0.2, 0.2, 0.2, 1)

    local scroll = WINDOW_MANAGER:CreateControlFromVirtual("DsRDebugScroll", ui, "ZO_ScrollContainer")
    scroll:SetAnchorFill()

    local child = scroll:GetNamedChild("ScrollChild")
    local text = WINDOW_MANAGER:CreateControl("DsRDebugText", child, CT_LABEL)
    text:SetFont("ZoFontGame")
    text:SetAnchor(TOPLEFT)
    text:SetWidth(580)

    PvP.DebugUI = text

    PvP.UIDebug = {
        window   = ui,
    }
end

local function FormatAlliance(a)
    if a == ALLIANCE_ALDMERI_DOMINION then return "AD" end
    if a == ALLIANCE_DAGGERFALL_COVENANT then return "DC" end
    if a == ALLIANCE_EBONHEART_PACT then return "EP" end
    return "UNK"
end

function PvP.UpdateDebugUI()
    if not PvP.UIDebug then return end

    if not PvP.IsInPvP() or not DsRGuildHallPvP_SV.uiUnknown then
        PvP.UIDebug.window:SetHidden(true)
        return
    end

    if PvP.hiddenShortly == false then PvP.UIDebug.window:SetHidden(false) end

    local lines = {}

    for _, e in ipairs(PvP.DebugLog) do
        local t = string.format("[%d] %-10s %-20s %s",
            e.ts % 100000,
            e.type,
            e.name,
            e.data
        )
        table.insert(lines, t)
    end

    PvP.DebugUI:SetText(table.concat(lines, "\n"))
end

------------------------------------------------------------
-- Aggressiver SoftUnit-Trigger-Loop + UI-Loop
------------------------------------------------------------

PvP._softUnitBurst    = PvP._softUnitBurst    or 0
PvP._softUnitFallback = PvP._softUnitFallback or 0

EVENT_MANAGER:RegisterForUpdate("DsR_SoftUnitTick", 150, function()
    if not PvP.IsInPvP() then return end

    local now = GetTimeStamp()

    -- HardBoost: 500ms lang 3 Burst-Scans
    if PvP.hardBoostEnd and now < PvP.hardBoostEnd then
        PvP._softUnitBurst = 3
    end

    -- Event-Trigger: SoftScan sofort starten
    if PvP.TriggerSoftUnitScanSoon then
        PvP.TriggerSoftUnitScanSoon = false
        PvP._softUnitBurst = 3
    end

    -- Burst-Scan: 3 schnelle Scans
    if PvP._softUnitBurst and PvP._softUnitBurst > 0 then
        PvP._softUnitBurst = PvP._softUnitBurst - 1
        PvP.ScanSoftUnits()
        return
    end

    -- Fallback-Scan alle 1500ms
    PvP._softUnitFallback = (PvP._softUnitFallback or 0) + 150
    if PvP._softUnitFallback >= 1500 then
        PvP._softUnitFallback = 0
        PvP.ScanSoftUnits()
    end
end)

EVENT_MANAGER:RegisterForUpdate("DsR_PlayerCleanup",    PvP.CLEANUP_INTERVAL, function() if not PvP.IsInPvP() then return end PvP.CleanupPlayers() end)
EVENT_MANAGER:RegisterForUpdate("DsR_UI_CountUpdate",   PvP.OUTPUT_INTERVAL,  function() if not PvP.IsInPvP() then return end PvP.UpdateUI()       end)

------------------------------------------------------------
-- OnAddonLoaded (Init)
------------------------------------------------------------

function PvP.RegisterPvPEvents()
    if PvP.eventsRegistered then return end
    PvP.eventsRegistered = true

    EVENT_MANAGER:RegisterForEvent("DsR_KILL_FEED",    EVENT_PVP_KILL_FEED_DEATH,           PvP.OnKillFeed)
    -- EVENT_MANAGER:RegisterForEvent("DsR_RETICLE",      EVENT_RETICLE_TARGET_PLAYER_CHANGED, PvP.OnReticleTargetChanged)
    EVENT_MANAGER:RegisterForEvent("DsR_RETICLE",      EVENT_RETICLE_TARGET_CHANGED,        PvP.OnReticleTargetChanged)
    EVENT_MANAGER:RegisterForEvent("DsR_EFFECT",       EVENT_EFFECT_CHANGED,                PvP.OnEffectChanged)

    zo_callLater(function()
        d("|c9fb6cd[DsR CountPlayer] |c00FF00aktiviert|r")
    end, 5000)
end

function PvP.UnregisterPvPEvents()
    if not PvP.eventsRegistered then return end
    PvP.eventsRegistered = false

    EVENT_MANAGER:UnregisterForEvent("DsR_KILL_FEED",    EVENT_PVP_KILL_FEED_DEATH)
    -- EVENT_MANAGER:UnregisterForEvent("DsR_RETICLE",      EVENT_RETICLE_TARGET_PLAYER_CHANGED)
    EVENT_MANAGER:UnregisterForEvent("DsR_RETICLE",      EVENT_RETICLE_TARGET_CHANGED)
    EVENT_MANAGER:UnregisterForEvent("DsR_EFFECT",       EVENT_EFFECT_CHANGED)

    d("|c9fb6cd[DsR CountPlayer] |cff0000deaktiviert|r")
end

function PvP.OnAddonLoaded(event, addonName)
    DsRGuildHallPvP_SV = ZO_SavedVars:NewAccountWide("DsRGuildHallPvPcount", 1, nil, {
        uiX          = 50,
        uiY          = 50,
        uiEnabled    = true,
        uiUnknown    = false,
        debugX       = 600,
        debugY       = 200,
        UNKPlayer    = false,
        PlayerStatic = true,
    })

    -- DsRPlayerDBData_SV.playerDB = DsRPlayerDBData_SV.playerDB or {}
    PvP.playerName = NormalizeName(GetUnitName("player"))

    CreateCountUI()
    if DsRGuildHallPvP_SV.uiUnknown then
        CreateDebugUI()
        DsR_PvPDebugUI:ClearAnchors()
        DsR_PvPDebugUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, DsRGuildHallPvP_SV.debugX, DsRGuildHallPvP_SV.debugY)

        EVENT_MANAGER:RegisterForUpdate("DsR_DEBUG_UPDATE", 500, function() if not PvP.IsInPvP() then return end PvP.UpdateDebugUI()  end)
    end

    EVENT_MANAGER:RegisterForEvent("DsR_ACTIVATED", EVENT_PLAYER_ACTIVATED, PvP.OnPlayerActivated)

    ZO_PreHookHandler(ZO_MainMenuCategoryBar, "OnShow", function() UpdateUIVisibility(true) end)
    ZO_PreHookHandler(ZO_InteractWindow,      "OnShow", function() UpdateUIVisibility(true) end)
    ZO_PreHookHandler(ZO_GameMenu_InGame,     "OnShow", function() UpdateUIVisibility(true) end)
    ZO_PreHookHandler(ZO_KeybindStripControl, "OnShow", function() UpdateUIVisibility(true) end)

    ZO_PreHookHandler(ZO_MainMenuCategoryBar, "OnHide", function() UpdateUIVisibility(false) end)
    ZO_PreHookHandler(ZO_InteractWindow,      "OnHide", function() UpdateUIVisibility(false) end)
    ZO_PreHookHandler(ZO_GameMenu_InGame,     "OnHide", function() UpdateUIVisibility(false) end)
    ZO_PreHookHandler(ZO_KeybindStripControl, "OnHide", function() UpdateUIVisibility(false) end)
end
