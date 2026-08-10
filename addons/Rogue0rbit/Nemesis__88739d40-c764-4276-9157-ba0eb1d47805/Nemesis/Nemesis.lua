--[[
    Nemesis - Core
    Remembers every player who kills you (and who you kill) in PvP.
    Console-safe: no keybinds, filtered events, capped SavedVariables.
]]

Nemesis = Nemesis or {}
local N = Nemesis

N.name = "Nemesis"
N.version = "1.0.0"

local EM = EVENT_MANAGER
local SV

-- Tuning ---------------------------------------------------------------------

local MAX_PLAYERS = 400        -- max tracked players in SavedVariables
local MAX_ABILITIES = 24       -- max remembered abilities per player
local DEDUPE_MS = 5000         -- window to ignore duplicate kill/death reports
local SPOTTED_COOLDOWN_MS = 300000 -- per-player cooldown for "nemesis spotted"

N.TIER_NONE, N.TIER_RIVAL, N.TIER_NEMESIS, N.TIER_ARCH = 0, 1, 2, 3
N.TIER_NAMES = { [0] = "", [1] = "RIVAL", [2] = "NEMESIS", [3] = "ARCH-NEMESIS" }
N.TIER_COLORS = {
    [0] = { 0.75, 0.75, 0.75 },
    [1] = { 1.00, 0.82, 0.20 },
    [2] = { 1.00, 0.45, 0.10 },
    [3] = { 1.00, 0.15, 0.15 },
}
N.ALLIANCE_COLORS = {
    [ALLIANCE_ALDMERI_DOMINION]   = { 1.00, 0.85, 0.30 },
    [ALLIANCE_DAGGERFALL_COVENANT] = { 0.30, 0.60, 1.00 },
    [ALLIANCE_EBONHEART_PACT]     = { 0.90, 0.25, 0.25 },
}

local defaults = {
    showDossier = true,
    banners = true,
    sounds = true,
    scrim = true,
    -- dossier UI
    dossierX = 230,
    dossierY = 20,
    dossierScale = 1.0,
    showDossierInfo = true,
    showDossierHP = true,
    showDossierKD = true,
    showDossierWin = true,
    showDossierMoves = true,
    showDossierSets = true,
    showDossierFooter = true,
    players = {},       -- key (@account or char name) -> record
    charToAccount = {}, -- character name -> @account
    totals = { kills = 0, deaths = 0 },
}

-- Runtime state --------------------------------------------------------------

local recentKill, recentDeath, spottedAt = {}, {}, {}
local lastPlayerDeath = 0
local setNameToId = nil
N.session = { kills = 0, deaths = 0 }

-- Helpers --------------------------------------------------------------------

local function Clean(s)
    if not s or s == "" then return "" end
    return zo_strformat("<<1>>", s)
end

function N.Now()
    return GetTimeStamp()
end

function N.InPvP()
    return IsPlayerInAvAWorld() or IsInImperialCity() or IsActiveWorldBattleground()
end

function N.IsDueling()
    local duelState = GetDuelInfo()
    return duelState == DUEL_STATE_DUELING
end

function N.InPvPOrDuel()
    return N.InPvP() or N.IsDueling()
end

function N.Msg(text)
    if CHAT_ROUTER then
        CHAT_ROUTER:AddSystemMessage("|cFF4040Nemesis|r " .. text)
    end
end

-- Identity -------------------------------------------------------------------

-- Resolve a player to a stable key, preferring @account name.
function N.KeyFor(displayName, charName)
    displayName, charName = Clean(displayName), Clean(charName)
    if displayName ~= "" and displayName ~= "@" then
        if charName ~= "" then
            SV.charToAccount[charName] = displayName
        end
        return displayName
    end
    if charName ~= "" then
        return SV.charToAccount[charName] or charName
    end
    return nil
end

local function MergeRecord(rec, old)
    if not old or rec == old then return end
    rec.k = (rec.k or 0) + (old.k or 0)
    rec.d = (rec.d or 0) + (old.d or 0)
    rec.dw = (rec.dw or 0) + (old.dw or 0)
    rec.dl = (rec.dl or 0) + (old.dl or 0)
    rec.streak = math.max(rec.streak or 0, old.streak or 0)
    rec.maxStreak = math.max(rec.maxStreak or 0, old.maxStreak or 0)
    rec.first = math.min(rec.first or old.first or 0, old.first or rec.first or 0)
    rec.last = math.max(rec.last or 0, old.last or 0)
    for id, c in pairs(old.ab or {}) do
        rec.ab[id] = (rec.ab[id] or 0) + c
    end
    for id, ts in pairs(old.sets or {}) do
        if not rec.sets[id] or ts > rec.sets[id] then rec.sets[id] = ts end
    end
    for ch, _ in pairs(old.chars or {}) do
        rec.chars[ch] = true
    end
    if old.cp and old.cp > 0 and (not rec.cp or old.cp > rec.cp) then rec.cp = old.cp end
    if old.class and old.class ~= "" then rec.class = old.class end
    if old.race and old.race ~= "" then rec.race = old.race end
    if old.alli and old.alli ~= 0 then rec.alli = old.alli end
    if old.level and old.level > 0 and (not rec.level or old.level > rec.level) then rec.level = old.level end
    if old.rank and old.rank > 0 and (not rec.rank or old.rank > rec.rank) then rec.rank = old.rank end
    if old.loc and old.loc ~= "" then rec.loc = old.loc end
end

-- Get or create a record for a key.
function N.Touch(key, charName)
    local rec = SV.players[key]
    local old
    if charName and charName ~= "" and key ~= charName then
        old = SV.players[charName]
    end
    if not rec and not old then
        rec = { k = 0, d = 0, dw = 0, dl = 0, streak = 0, maxStreak = 0,
                first = N.Now(), ab = {}, sets = {}, chars = {} }
        SV.players[key] = rec
    elseif not rec then
        rec = old
        SV.players[charName] = nil
        SV.players[key] = rec
    else
        if old then
            MergeRecord(rec, old)
            SV.players[charName] = nil
        end
    end
    rec.last = N.Now()
    if charName and charName ~= "" then
        rec.chars[Clean(charName)] = true
    end
    return rec
end

function N.Get(key)
    return key and SV.players[key] or nil
end

-- Capture live unit info into a record (reticleover etc).
function N.EnrichFromUnit(rec, unitTag)
    local cp = GetUnitChampionPoints(unitTag)
    if cp and cp > 0 then rec.cp = cp end
    local class = Clean(GetUnitClass(unitTag))
    if class ~= "" then rec.class = class end
    local race = Clean(GetUnitRace(unitTag))
    if race ~= "" then rec.race = race end
    local alli = GetUnitAlliance(unitTag)
    if alli and alli ~= 0 then rec.alli = alli end
    local level = GetUnitLevel(unitTag)
    if level and level > 0 then rec.level = level end
end

-- Tiers ----------------------------------------------------------------------

function N.GetTier(rec)
    if not rec then return N.TIER_NONE end
    local d, k = rec.d or 0, rec.k or 0
    if d >= 10 and d >= 2 * k then return N.TIER_ARCH end
    if d >= 5 then return N.TIER_NEMESIS end
    if d >= 2 then return N.TIER_RIVAL end
    return N.TIER_NONE
end

-- Win chance heuristic (a fun estimate, not science) -------------------------

function N.WinChance(rec)
    local k, d = rec.k or 0, rec.d or 0
    local base = (k + 1) / (k + d + 2)
    local myCP = GetUnitChampionPoints("player") or 0
    local theirCP = rec.cp or myCP
    local cpAdj = zo_clamp((myCP - theirCP) * 0.0002, -0.10, 0.10)
    local streakAdj = -0.03 * zo_min(rec.streak or 0, 3)
    return zo_clamp(base + cpAdj + streakAdj, 0.05, 0.95)
end

-- Set inference: proc ability names that match item set names ----------------

local function EnsureSetLookup()
    if setNameToId then return end
    setNameToId = {}
    for setId = 1, 5000 do
        local setName = GetItemSetName(setId)
        if setName and setName ~= "" then
            setNameToId[zo_strlower(Clean(setName))] = setId
        end
    end
end

local function TryInferSet(rec, abilityId)
    EnsureSetLookup()
    local abilityName = zo_strlower(Clean(GetAbilityName(abilityId)))
    local setId = setNameToId[abilityName]
    if setId then
        rec.sets[setId] = N.Now()
    end
end

-- Ability learning -----------------------------------------------------------

local function CapAbilities(rec)
    local count = 0
    for _ in pairs(rec.ab) do count = count + 1 end
    if count <= MAX_ABILITIES then return end
    -- evict the least-seen ability
    local minId, minCount
    for id, c in pairs(rec.ab) do
        if not minCount or c < minCount then minId, minCount = id, c end
    end
    if minId then rec.ab[minId] = nil end
end

function N.LearnAbility(rec, abilityId)
    if not abilityId or abilityId == 0 then return end
    rec.ab[abilityId] = (rec.ab[abilityId] or 0) + 1
    CapAbilities(rec)
    TryInferSet(rec, abilityId)
end

-- Kill / death recording ------------------------------------------------------

function N.RecordKill(key, charName, location)
    local now = GetGameTimeMilliseconds()
    if recentKill[key] and now - recentKill[key] < DEDUPE_MS then return end
    recentKill[key] = now

    local rec = N.Touch(key, charName)
    local tierBefore = N.GetTier(rec)
    rec.k = (rec.k or 0) + 1
    rec.streak = 0
    if location and location ~= "" then rec.loc = Clean(location) end
    SV.totals.kills = SV.totals.kills + 1
    N.session.kills = N.session.kills + 1

    if tierBefore >= N.TIER_NEMESIS then
        N.UI.ShowVengeance(key, rec, tierBefore)
    end
    N.UI.RefreshIfShowing(key)
end

function N.RecordDeath(key, charName, location)
    local now = GetGameTimeMilliseconds()
    if recentDeath[key] and now - recentDeath[key] < DEDUPE_MS then return end
    recentDeath[key] = now

    local rec = N.Touch(key, charName)
    local tierBefore = N.GetTier(rec)
    rec.d = (rec.d or 0) + 1
    rec.streak = (rec.streak or 0) + 1
    if rec.streak > (rec.maxStreak or 0) then rec.maxStreak = rec.streak end
    if location and location ~= "" then rec.loc = Clean(location) end
    SV.totals.deaths = SV.totals.deaths + 1
    N.session.deaths = N.session.deaths + 1

    local tierAfter = N.GetTier(rec)
    if tierAfter > tierBefore then
        N.UI.ShowPromotion(key, rec, tierAfter)
    else
        N.UI.ShowDeathNote(key, rec)
    end
end

-- Event handlers ---------------------------------------------------------------

local function OnKillFeed(_, killLocation, killerDisp, killerChar, killerAlliance, killerRank,
                          victimDisp, victimChar, victimAlliance, victimRank, isKillLocation)
    local me = GetDisplayName()
    killerDisp, victimDisp = Clean(killerDisp), Clean(victimDisp)
    if killerDisp == me and victimDisp ~= "" and victimDisp ~= me then
        local key = N.KeyFor(victimDisp, victimChar)
        if key then
            local rec = N.Touch(key, victimChar)
            if victimAlliance and victimAlliance ~= 0 then rec.alli = victimAlliance end
            if victimRank and victimRank > 0 then rec.rank = victimRank end
            N.RecordKill(key, victimChar, killLocation)
        end
    elseif victimDisp == me and killerDisp ~= "" and killerDisp ~= me then
        lastPlayerDeath = GetGameTimeMilliseconds()
        local key = N.KeyFor(killerDisp, killerChar)
        if key then
            local rec = N.Touch(key, killerChar)
            if killerAlliance and killerAlliance ~= 0 then rec.alli = killerAlliance end
            if killerRank and killerRank > 0 then rec.rank = killerRank end
            N.RecordDeath(key, killerChar, killLocation)
        end
    end
end

-- Read the death recap: learn who killed us and with what.
-- The PvP kill feed is authoritative for AvA, so skip if it already handled this death.
local function ReadDeathRecap()
    if not N.InPvPOrDuel() then return end
    if GetGameTimeMilliseconds() - lastPlayerDeath < 5000 then return end
    local numAttacks = GetNumKillingAttacks()
    if not numAttacks or numAttacks == 0 then return end

    local killingBlowKey, killingBlowChar
    for i = 1, numAttacks do
        if DoesKillingAttackHaveAttacker(i) then
            local rawName, cp, level, avaRank, isPlayer, isBoss, alliance, minionName, displayName = GetKillingAttackerInfo(i)
            if isPlayer then
                local charName = Clean(rawName)
                local key = N.KeyFor(displayName, charName)
                if key then
                    local rec = N.Touch(key, charName)
                    if cp and cp > 0 then rec.cp = cp end
                    if avaRank and avaRank > 0 then rec.rank = avaRank end
                    if alliance and alliance ~= 0 then rec.alli = alliance end
                    local _, _, _, wasKillingBlow = GetKillingAttackInfo(i)
                    if wasKillingBlow then
                        killingBlowKey, killingBlowChar = key, charName
                    end
                    if not killingBlowKey then
                        killingBlowKey, killingBlowChar = key, charName
                    end
                end
            end
        end
    end
    if killingBlowKey then
        N.RecordDeath(killingBlowKey, killingBlowChar, GetUnitZone("player"))
    end
end

local function OnPlayerDead()
    -- recap data may populate slightly after death
    zo_callLater(ReadDeathRecap, 400)
end

-- Enemy abilities used against us.
local function OnCombatIn(_, result, isError, abilityName, abilityGraphic, abilityActionSlotType,
                          sourceName, sourceType, targetName, targetType, hitValue,
                          powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    if isError or sourceType ~= COMBAT_UNIT_TYPE_OTHER then return end
    if not abilityId or abilityId == 0 then return end
    if not N.InPvPOrDuel() then return end

    local charName = Clean(sourceName)
    if charName == "" then return end

    local key = SV.charToAccount[charName]
    local rec = key and SV.players[key] or nil
    if not rec then
        -- unknown attacker: identify them only if we are currently looking at them
        if IsUnitPlayer("reticleover") and Clean(GetUnitName("reticleover")) == charName then
            key = N.KeyFor(GetUnitDisplayName("reticleover"), charName)
            if key then
                rec = N.Touch(key, charName)
                N.EnrichFromUnit(rec, "reticleover")
            end
        end
    end
    if rec then
        rec.last = N.Now()
        N.LearnAbility(rec, abilityId)
    end
end

-- Our killing blows (covers battlegrounds and duels; kill feed covers AvA).
local function OnKillingBlowOut(_, result, isError, abilityName, abilityGraphic, abilityActionSlotType,
                                sourceName, sourceType, targetName, targetType, hitValue,
                                powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    if isError then return end
    if not N.InPvPOrDuel() then return end
    local charName = Clean(targetName)
    if charName == "" then return end
    local key = SV.charToAccount[charName]
    if not key and IsUnitPlayer("reticleover") and Clean(GetUnitName("reticleover")) == charName then
        key = N.KeyFor(GetUnitDisplayName("reticleover"), charName)
    end
    if key then
        N.RecordKill(key, charName, GetUnitZone("player"))
    end
end

local function OnDuelFinished(_, duelResult, wasLocalPlayersResult, opponentCharacterName,
                              opponentDisplayName, opponentAlliance, opponentGender,
                              opponentClassId, opponentRaceId)
    if duelResult == DUEL_RESULT_FORFEIT then return end
    local key = N.KeyFor(opponentDisplayName, opponentCharacterName)
    if not key then return end
    local rec = N.Touch(key, opponentCharacterName)
    if opponentClassId and opponentClassId > 0 then
        rec.class = Clean(GetClassName(GENDER_MALE, opponentClassId))
    end
    local iWon = (duelResult == DUEL_RESULT_WON and wasLocalPlayersResult)
    if iWon then
        rec.dw = (rec.dw or 0) + 1
    else
        rec.dl = (rec.dl or 0) + 1
    end
end

-- Spotted check: called by UI when the reticle lands on a known player.
function N.CheckSpotted(key, rec)
    local tier = N.GetTier(rec)
    if tier < N.TIER_NEMESIS then return end
    local now = GetGameTimeMilliseconds()
    if spottedAt[key] and now - spottedAt[key] < SPOTTED_COOLDOWN_MS then return end
    spottedAt[key] = now
    N.UI.ShowSpotted(key, rec, tier)
end

-- Pruning ----------------------------------------------------------------------

local function PrunePlayers()
    local keys = {}
    for key in pairs(SV.players) do keys[#keys + 1] = key end
    if #keys <= MAX_PLAYERS then return end
    -- evict least recently seen, lowest-tier players first
    table.sort(keys, function(a, b)
        local ra, rb = SV.players[a], SV.players[b]
        local ta, tb = N.GetTier(ra), N.GetTier(rb)
        if ta ~= tb then return ta < tb end
        return (ra.last or 0) < (rb.last or 0)
    end)
    for i = 1, #keys - MAX_PLAYERS do
        SV.players[keys[i]] = nil
    end
end

-- Top rivals list ---------------------------------------------------------------

function N.GetTopRivals(count)
    local list = {}
    for key, rec in pairs(SV.players) do
        if (rec.d or 0) + (rec.k or 0) > 0 then
            list[#list + 1] = { key = key, rec = rec }
        end
    end
    table.sort(list, function(a, b)
        if (a.rec.d or 0) ~= (b.rec.d or 0) then return (a.rec.d or 0) > (b.rec.d or 0) end
        return (a.rec.last or 0) > (b.rec.last or 0)
    end)
    local out = {}
    for i = 1, zo_min(count or 5, #list) do out[i] = list[i] end
    return out
end

-- Slash commands ----------------------------------------------------------------

local function OnSlashCommand(args)
    args = zo_strlower(args or "")
    if args == "top" then
        local top = N.GetTopRivals(5)
        if #top == 0 then
            N.Msg("No rivals recorded yet. Go fight someone!")
            return
        end
        N.Msg("Your top rivals:")
        for i, entry in ipairs(top) do
            local tier = N.TIER_NAMES[N.GetTier(entry.rec)]
            local tag = tier ~= "" and (" [" .. tier .. "]") or ""
            N.Msg(string.format("%d. %s%s - killed you %dx, you killed them %dx",
                i, entry.key, tag, entry.rec.d or 0, entry.rec.k or 0))
        end
    elseif args == "dossier" then
        SV.showDossier = not SV.showDossier
        if not SV.showDossier and N.UI and N.UI.HideDossier then
            N.UI.HideDossier()
        end
        N.Msg("Dossier popup " .. (SV.showDossier and "enabled" or "disabled") .. ".")
    elseif args == "banners" then
        SV.banners = not SV.banners
        N.Msg("Banners " .. (SV.banners and "enabled" or "disabled") .. ".")
    elseif args == "sounds" then
        SV.sounds = not SV.sounds
        N.Msg("Sounds " .. (SV.sounds and "enabled" or "disabled") .. ".")
    else
        local tracked = 0
        for _ in pairs(SV.players) do tracked = tracked + 1 end
        N.Msg(string.format("v%s - tracking %d players. Lifetime PvP: %d kills / %d deaths. Session: %d/%d.",
            N.version, tracked, SV.totals.kills, SV.totals.deaths, N.session.kills, N.session.deaths))
        N.Msg("Commands: /nemesis top, dossier, banners, sounds")
    end
end

-- Init ---------------------------------------------------------------------------

function N.GetSV()
    return SV
end

local function OnAddOnLoaded(_, addOnName)
    if addOnName ~= N.name then return end
    EM:UnregisterForEvent(N.name .. "Loaded", EVENT_ADD_ON_LOADED)

    SV = ZO_SavedVars:NewAccountWide("NemesisSV", 1, nil, defaults)
    PrunePlayers()

    -- kill feed: authoritative for AvA kills/deaths
    EM:RegisterForEvent(N.name .. "KillFeed", EVENT_PVP_KILL_FEED_DEATH, OnKillFeed)

    -- death recap: who killed us + what with
    EM:RegisterForEvent(N.name .. "Dead", EVENT_PLAYER_DEAD, OnPlayerDead)

    -- incoming hits: learn enemy abilities (filtered: only events targeting us)
    EM:RegisterForEvent(N.name .. "CombatIn", EVENT_COMBAT_EVENT, OnCombatIn)
    EM:AddFilterForEvent(N.name .. "CombatIn", EVENT_COMBAT_EVENT,
        REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER,
        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_OTHER,
        REGISTER_FILTER_IS_ERROR, false)

    -- our killing blows (fallback coverage outside the kill feed)
    EM:RegisterForEvent(N.name .. "KillOut", EVENT_COMBAT_EVENT, OnKillingBlowOut)
    EM:AddFilterForEvent(N.name .. "KillOut", EVENT_COMBAT_EVENT,
        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER,
        REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_KILLING_BLOW)
    EM:RegisterForEvent(N.name .. "KillOutPet", EVENT_COMBAT_EVENT, OnKillingBlowOut)
    EM:AddFilterForEvent(N.name .. "KillOutPet", EVENT_COMBAT_EVENT,
        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER_PET,
        REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_KILLING_BLOW)

    -- duels
    EM:RegisterForEvent(N.name .. "Duel", EVENT_DUEL_FINISHED, OnDuelFinished)

    SLASH_COMMANDS["/nemesis"] = OnSlashCommand

    N.UI.Init(SV)
    N.Scrim.Init(SV)
    N.Settings.Init(SV)
end

EM:RegisterForEvent(N.name .. "Loaded", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
