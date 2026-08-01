-- ============================================================
--  NetworkSync.lua
--  Synchronise les taunts entre membres du groupe via LibGroupBroadcast.
--
--  Architecture des protocoles :
--    ID 231        — HELLO   : découverte des peers (addon présent/version)
--    IDs 232–239   — TAUNT×8 : envoi round-robin, 1 taunt → 1 slot dédié
--
--  Pourquoi 8 slots TAUNT ?
--    Le budget LGB est de ~224 bits par protocole par frame.
--    Un message TAUNT pèse ~180-200 bits → 1 seul message par slot par frame.
--    Avec 1 seul protocole, un pull de 6 mobs simultanés sature la queue.
--    Avec 8 slots round-robin, 8 taunts simultanés partent chacun sur leur
--    propre canal → 0 contention, 0 saturation.
--
--  Pourquoi HELLO ?
--    LGB diffuse à tout le groupe, même aux joueurs sans l'addon.
--    Le protocole HELLO découvre qui a TauntTracker dans le groupe.
--    BroadcastTaunt skip silencieusement si aucun peer n'est connu,
--    économisant la bande passante LGB dans les groupes sans l'addon.
-- ============================================================

local TT = TauntTracker

-- ── IDs de protocoles ───────────────────────────────────────
local PROTO_HELLO_ID    = 231
local PROTO_TAUNT_BASE  = 232   -- slots 232..239
local PROTO_TAUNT_COUNT = 8

local TAUNT_DURATION    = 15000
local HELLO_VERSION     = 1     -- à incrémenter si le format TAUNT change

-- ── Objets protocoles ───────────────────────────────────────
local protoHello  = nil
local protoTaunts = {}   -- [1..8]

-- ── Peers détectés (nom personnage → true) ──────────────────
local peers      = {}
local peerCount  = 0

-- ── Round-robin TAUNT ────────────────────────────────────────
local nextSlot = 0

-- ── Debug ────────────────────────────────────────────────────
local debugNet = false

-- ── Anti-tempête HELLO ───────────────────────────────────────
local lastHelloSent  = 0
local HELLO_COOLDOWN = 3000   -- ms minimum entre deux HELLO envoyés

-- ============================================================
--  HELPERS
-- ============================================================

-- Tronque par CARACTÈRES (zo_strsub) et non par bytes (string.sub).
-- Indispensable : l'apostrophe typographique ESO = 3 bytes UTF-8.
local function SafeSub(s, maxChars)
    if not s or s == "" then return "" end
    if zo_strlen(s) <= maxChars then return s end
    return zo_strsub(s, 1, maxChars)
end

local function GetCharName(unitTag)
    return TT.CleanName((GetUnitName and GetUnitName(unitTag)) or unitTag or "?")
end

local function GetNextTauntProto()
    nextSlot = (nextSlot % PROTO_TAUNT_COUNT) + 1
    return protoTaunts[nextSlot]
end

-- ============================================================
--  PEER TRACKING
-- ============================================================

local function AddPeer(name)
    if not name or name == "" or name == "?" then return false end
    local isNew = not peers[name]
    if isNew then
        peers[name] = true
        peerCount   = peerCount + 1
        if debugNet then
            d(string.format("[TT Net] Peer detecte : '%s' (%d total)", name, peerCount))
        end
    end
    return isNew
end

local function RemovePeer(name)
    if peers[name] then
        peers[name] = nil
        peerCount   = math.max(0, peerCount - 1)
        if debugNet then
            d(string.format("[TT Net] Peer parti : '%s' (%d restants)", name, peerCount))
        end
    end
end

local function ClearPeers()
    peers     = {}
    peerCount = 0
    if debugNet then d("[TT Net] Peers effaces (changement de groupe)") end
end

-- ============================================================
--  HELLO — envoi
-- ============================================================

local function SendHello()
    if not protoHello or not protoHello:IsEnabled() then return end
    local now = GetGameTimeMilliseconds()
    if (now - lastHelloSent) < HELLO_COOLDOWN then return end
    lastHelloSent = now
    protoHello:Send({ version = HELLO_VERSION })
    if debugNet then d("[TT Net] HELLO envoye") end
end

local function SendHelloDelayed(ms)
    zo_callLater(SendHello, ms or 1000)
end

-- ============================================================
--  HANDLER TAUNT COMMUN (partagé par les 8 slots)
-- ============================================================

local function OnTauntData(unitTag, data)
    if not TT.activeTaunts then return end

    local casterName  = GetCharName(unitTag)
    local localPlayer = GetCharName("player")
    local isSelfEcho  = (casterName == localPlayer)

    if debugNet then
        d(string.format("[TT Net] TAUNT recu <- caster='%s' target='%s' remain=%dms%s",
            casterName, tostring(data.targetName), data.remainMs or 0,
            isSelfEcho and " [self-echo]" or ""))
    end

    local now      = GetGameTimeMilliseconds()
    local remain   = math.max(0, math.min(data.remainMs, TAUNT_DURATION))
    local localKey = TT.FindEntryKey(data.targetName, data.targetKey)

	if not localKey then
		localKey = data.targetKey
				   or (data.targetName and data.targetName:lower():gsub("%s+", "_"))
	end
	if not localKey then return end
	if TT.CancelPendingFade then TT.CancelPendingFade(localKey) end
    local existing = TT.activeTaunts[localKey]
    if existing then
        if isSelfEcho then
            if existing.casterName == nil or existing.casterName == "?" then
                existing.casterName = casterName
            end
        else
            existing.casterName  = casterName
            existing.beginTime   = now - (TAUNT_DURATION - remain)
            existing.endTime     = now + remain
            existing.fromNetwork = true
        end
        return
    end

    TT.activeTaunts[localKey] = {
        casterName  = casterName,
        targetName  = TT.CleanName(data.targetName),
        beginTime   = now - (TAUNT_DURATION - remain),
        endTime     = now + remain,
        key         = localKey,
        fromNetwork = true,
    }
end

-- ============================================================
--  INIT LGB
-- ============================================================

local function InitLGB()
    local LGB = LibGroupBroadcast
    if not LGB then
        d("[TauntTracker] LibGroupBroadcast non trouve - sync reseau desactivee.")
        return
    end

    local handler = LGB:RegisterHandler("TauntTracker")
    if not handler then
        d("[TauntTracker] LGB : echec RegisterHandler.")
        return
    end
    handler:SetDisplayName("TauntTracker")
    handler:SetDescription("Synchronise les taunts actifs entre les membres du groupe.")

    -- ── HELLO (ID 231) ────────────────────────────────────────
    -- Payload minimal : 4 bits version (0-15). Budget << 50 bits.
    protoHello = handler:DeclareProtocol(PROTO_HELLO_ID, "TauntTrackerHello")
    if protoHello then
        protoHello:AddField(LGB.CreateNumericField("version", { minValue = 0, maxValue = 15 }))

        protoHello:OnData(function(unitTag, data)
            local name  = GetCharName(unitTag)
            local isNew = AddPeer(name)
            if debugNet then
                d(string.format("[TT Net] HELLO recu de '%s' (v%d)%s",
                    name, data.version or 0, isNew and " [nouveau]" or ""))
            end
            -- Répondre seulement si c'est un peer inconnu pour qu'il
            -- nous détecte à son tour. Le cooldown HELLO_COOLDOWN empêche
            -- la tempête de réponses si plusieurs peers arrivent en même temps.
            if isNew then
                SendHelloDelayed(200)
            end
        end)

        protoHello:Finalize({
            isRelevantInCombat    = false,
            replaceQueuedMessages = true,   -- inutile d'empiler des HELLO
        })
    else
        d("[TauntTracker] LGB : echec DeclareProtocol HELLO (ID " .. PROTO_HELLO_ID .. ").")
    end

    -- ── 8 slots TAUNT (IDs 232–239) ───────────────────────────
    -- Chaque slot est un protocole LGB indépendant avec son propre budget.
    -- Le round-robin distribue les taunts simultanés :
    --   pull de 6 mobs = slots 1-6, chacun avec 1 message = 0 contention.
    -- Si un slot échoue à Finalize (ID déjà pris par un autre addon),
    -- les slots restants continuent de fonctionner normalement.
    for i = 1, PROTO_TAUNT_COUNT do
        local id    = PROTO_TAUNT_BASE + (i - 1)   -- 232, 233, ..., 239
        local proto = handler:DeclareProtocol(id, "TauntTrackerTaunt" .. i)

        if proto then
            proto:AddField(LGB.CreateStringField ("targetKey",  { maxLength = 10 }))
            proto:AddField(LGB.CreateStringField ("targetName", { maxLength = 30 }))
            proto:AddField(LGB.CreateNumericField("remainMs",   { minValue = 0, maxValue = 15000 }))
            proto:OnData(OnTauntData)

            local ok = proto:Finalize({
                isRelevantInCombat    = true,
                replaceQueuedMessages = false,
            })

            if ok then
                protoTaunts[#protoTaunts + 1] = proto
            else
                d(string.format("[TauntTracker] LGB : Finalize slot %d (ID %d) echoue.", i, id))
            end
        else
            d(string.format("[TauntTracker] LGB : DeclareProtocol slot %d (ID %d) echoue.", i, id))
        end
    end

    if #protoTaunts == 0 then
        d("[TauntTracker] LGB : aucun slot TAUNT disponible - sync desactivee.")
        return
    end

    TT._protoFinalized = true
    d(string.format("[TauntTracker] LGB pret - HELLO(ID %d) + %d slots TAUNT (IDs %d-%d).",
        PROTO_HELLO_ID, #protoTaunts, PROTO_TAUNT_BASE, PROTO_TAUNT_BASE + #protoTaunts - 1))

    -- Annoncer notre présence (délai : le groupe n'est pas chargé à l'init)
    SendHelloDelayed(2000)
end

-- ============================================================
--  EVENTS — gestion du groupe
-- ============================================================

local function OnGroupMemberJoined(_, unitTag)
    -- Un membre arrive : HELLO pour qu'il nous découvre.
    -- S'il a l'addon, il répondra → on l'ajoute à nos peers.
    SendHelloDelayed(600)
end

local function OnGroupMemberLeft(_, unitTag)
    RemovePeer(GetCharName(unitTag))
end

local function OnGroupChanged()
    -- Reformation complète (nouvelle instance, zone) : reconstruire les peers.
    ClearPeers()
    SendHelloDelayed(1500)
end

-- ============================================================
--  API PUBLIQUE
-- ============================================================

-- Envoie un taunt sur le prochain slot round-robin.
-- Skip silencieusement si aucun peer TauntTracker n'est présent.
function TT.BroadcastTaunt(key, targetName)
    if #protoTaunts == 0 then return end

    if peerCount == 0 then
        if debugNet then
            d("[TT Net] BroadcastTaunt skip - aucun peer TauntTracker dans le groupe")
        end
        return
    end

    local proto = GetNextTauntProto()
    if not proto or not proto:IsEnabled() then return end

    local ok = proto:Send({
        targetKey  = SafeSub(key,        10),
        targetName = SafeSub(targetName, 10),
        remainMs   = TAUNT_DURATION,
    })

    if debugNet then
        d(string.format("[TT Net] TAUNT slot %d/%d (ok=%s) -> '%s' | %d peer(s)",
            nextSlot, #protoTaunts, tostring(ok), tostring(targetName), peerCount))
    end
end

-- Retourne la table peers et le compteur (pour l'UI ou le debug externe)
function TT.GetPeers()
    return peers, peerCount
end

-- ============================================================
--  OPTIONS LAM
-- ============================================================

TT.RegisterOptions(function()
    return {
        { type = "divider" },
        { type = "header", name = "|c88FFCC"..GetString(TAUNTTRACKER_TITTLE5).."|r" },
        {
            type  = "description",
            title = "",
            text  = GetString(TAUNTTRACKER_SYNCTEXT),
        },
        {
            type    = "checkbox",
            name    = GetString(TAUNTTRACKER_SYNC1),
            tooltip = GetString(TAUNTTRACKER_SYNC1TOOL),
            getFunc = function() return debugNet end,
            setFunc = function(v) debugNet = v end,
        },
    }
end)

-- ============================================================
--  DIAGNOSTIC /tt net
-- ============================================================

function TT.NetDiag()
    local LGB = LibGroupBroadcast
    d("|c88FFCC[TT Net Diagnostic]|r")
    d("  LGB present        : " .. tostring(LGB ~= nil))
    d("  HELLO (ID 231)     : " .. tostring(protoHello ~= nil))
    d("  slots TAUNT actifs : " .. tostring(#protoTaunts) .. " / " .. PROTO_TAUNT_COUNT)
    d("  proto finalise     : " .. tostring(TT._protoFinalized == true))
    d("  en groupe          : " .. tostring(IsUnitGrouped and IsUnitGrouped("player") or "?"))
    d("  taille groupe      : " .. tostring(GetGroupSize and GetGroupSize() or "?"))
    d("  peers TauntTracker : " .. tostring(peerCount))
    if peerCount > 0 then
        for name, _ in pairs(peers) do d("    - " .. name) end
    end
end

-- ============================================================
--  INIT
-- ============================================================

local function OnLoaded(_, addonName)
    if addonName ~= TT.name then return end
    InitLGB()
    EVENT_MANAGER:RegisterForEvent(
        TT.name .. "_group_join",    EVENT_GROUP_MEMBER_JOINED, OnGroupMemberJoined)
    EVENT_MANAGER:RegisterForEvent(
        TT.name .. "_group_left",    EVENT_GROUP_MEMBER_LEFT,   OnGroupMemberLeft)
    EVENT_MANAGER:RegisterForEvent(
        TT.name .. "_group_changed", EVENT_GROUP_CHANGED,       OnGroupChanged)
end

EVENT_MANAGER:RegisterForEvent(
    TT.name .. "_netsync_init",
    EVENT_ADD_ON_LOADED,
    OnLoaded
)
