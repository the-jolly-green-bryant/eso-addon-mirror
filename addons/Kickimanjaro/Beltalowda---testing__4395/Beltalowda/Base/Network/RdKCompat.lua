-- Beltalowda RdK Compatibility Layer
-- Bidirectional protocol bridge so Beltalowda and RdK users see each other's
-- ultimate and synergy data even when running different addons.
--
-- When RdK is NOT loaded on this client, Beltalowda claims RdK's protocol IDs
-- (105 = Heartbeat, 106 = Synergy) and both sends and receives in RdK format.
-- When RdK IS loaded, this module is a no-op (RdK owns those protocol IDs).
--
-- LGB constraint: "first declarer wins" — only one addon can DeclareProtocol
-- for a given message ID on a single client.

Beltalowda = Beltalowda or {}
Beltalowda.network = Beltalowda.network or {}
Beltalowda.network.rdkCompat = Beltalowda.network.rdkCompat or {}

local RdKCompat = Beltalowda.network.rdkCompat
local BeltalowdaNetwork = Beltalowda.network

-- Create logger instance for RdKCompat module
local logger = nil

-- Protocol references (nil when RdK is loaded — protocols not declared)
RdKCompat.heartbeatProtocol = nil
RdKCompat.synergyProtocol = nil

-- Whether this module is active (RdK not loaded, protocols declared successfully)
RdKCompat.active = false

-- RdK protocol IDs
local RDK_HEARTBEAT_ID = 105
local RDK_SYNERGY_ID = 106

-- RdK synergy message marker (b0 byte in protocol 106)
local RDK_MESSAGE_ID_SYNERGY = 110

-- Heartbeat interval matching RdK's NetworkLoop (1 second)
local HEARTBEAT_INTERVAL_MS = 1000

-- Staleness threshold: prefer Beltalowda data if updated within this window
local BELTALOWDA_DATA_FRESHNESS_MS = 5000

-- ============================================================================
-- Settings Controls
-- ============================================================================

function RdKCompat.GetSettingsControls()
    return {
        {
            type = "checkbox",
            name = "Enable RdK Network Compatibility",
            tooltip = "When enabled, Beltalowda claims RdK's network protocol IDs so that Beltalowda and RdK users can see each other's ultimate and synergy data. Changes require /reloadui to take effect.",
            getFunc = function()
                return BeltalowdaVars.rdkCompatEnabled
            end,
            setFunc = function(value)
                BeltalowdaVars.rdkCompatEnabled = value
            end,
            width = "full",
            default = false,
            warning = "Changing this setting requires /reloadui to take effect.",
        },
    }
end

-- ============================================================================
-- RdK Ultimate ID Mapping
-- Maps RdK's compact b0 value (the .id field from RdK's Base/Util/Ultimates.lua)
-- to ESO ability IDs.  b0 is NOT the array index — it is the separate .id field
-- that RdK stores per ultimate entry and sends on the wire via protocol 105.
-- Source: RdK Base/Util/Ultimates.lua (authoritative)
-- ============================================================================

-- Forward: RdK b0 (.id field) → ESO ability ID
RdKCompat.RDK_TO_ESO_ULT = {
    -- Sorcerer
    [1]  = 28341,   -- Negate Magic (Dark Magic)
    [2]  = 23634,   -- Summon Storm Atronach (Daedric Summoning)
    [3]  = 24785,   -- Overload (Storm Calling)
    -- Templar
    [4]  = 22138,   -- Radial Sweep (Aedric Spear)
    [5]  = 21752,   -- Nova (Dawn's Wrath)
    [6]  = 22223,   -- Rite of Passage (Restoring Light)
    -- Dragonknight
    [7]  = 32958,   -- Shifting Standard (Ardent Flame)
    [8]  = 29012,   -- Dragon Leap (Draconic Power)
    [9]  = 15957,   -- Magma Armor (Earthen Heart)
    -- Nightblade
    [10] = 33398,   -- Death Stroke (Assassination)
    [11] = 25411,   -- Consuming Darkness (Shadow)
    [12] = 25091,   -- Soul Shred (Siphoning)
    -- Warden
    [13] = 86109,   -- Sleet Storm (Winter's Embrace)
    [14] = 85532,   -- Secluded Grove (Green Balance)
    -- Weapon
    [15] = 83619,   -- Elemental Storm (Destruction Staff)
    [16] = 83552,   -- Panacea (Restoration Staff)
    [17] = 83216,   -- Berserker Strike (Two Handed)
    [18] = 83272,   -- Shield Wall (One Hand and Shield)
    [19] = 83600,   -- Lacerate (Dual Wield)
    [20] = 83465,   -- Rapid Fire (Bow)
    -- Guild / World
    [21] = 39270,   -- Soul Strike (Soul Magic)
    [22] = 32455,   -- Werewolf Transformation
    [23] = 32624,   -- Bat Swarm (Vampire)
    [24] = 16536,   -- Meteor (Mages Guild)
    [25] = 35713,   -- Dawnbreaker (Fighters Guild)
    -- Alliance
    [26] = 38573,   -- Barrier (Alliance Support)
    [27] = 38563,   -- War Horn (Alliance Assault)
    -- Necromancer
    [28] = 115001,  -- Bone Goliath Transformation (Bone Tyrant)
    [29] = 122174,  -- Pestilent Colossus (Grave Lord)
    [30] = 115410,  -- Reanimate (Living Death)
    -- Warden (continued)
    [31] = 85982,   -- Feral Guardian (Animal Companions)
    -- Sorcerer morphs (Negate)
    [32] = 28341,   -- Suppression Field (Negate morph)
    [33] = 28341,   -- Absorption Field (Negate morph)
    -- Psijic Order
    [34] = 103478,  -- Undo (Psijic Order)
    -- Warden morphs
    [35] = 86113,   -- Northern Storm (Sleet Storm morph)
    [36] = 86117,   -- Permafrost (Sleet Storm morph)
    -- Nightblade morphs (Soul Shred)
    [37] = 35508,   -- Soul Siphon (Soul Shred morph)
    [38] = 35460,   -- Soul Tether (Soul Shred morph)
    -- Arcanist
    [39] = 189791,  -- Unblinking Eye (Herald of the Tome)
    [40] = 183676,  -- Gibbering Shield (Apocryphal Soldier)
    [41] = 183709,  -- Vitalizing Glyphic (Curative Runeforms)
}

-- Reverse: ESO ability ID → RdK b0 value
-- Built programmatically from the forward table
RdKCompat.ESO_TO_RDK_ULT = {}

-- Additional ESO→RdK mappings for morph ability IDs not in the forward table.
-- When Beltalowda reads a morph-specific ID via GetSlotBoundId(8), these entries
-- ensure it maps to the correct RdK .id for the base ultimate.
local EXTRA_ESO_TO_RDK = {
    -- Force base Negate to .id=1 (forward table has 28341 at .id=1, 32, 33)
    [28341]  = 1,
    -- Storm Atronach morphs → .id=2
    [23492]  = 2,   -- Greater Storm Atronach
    [23495]  = 2,   -- Summon Charged Atronach
    -- Overload morphs → .id=3
    [24806]  = 3,   -- Power Overload
    [24804]  = 3,   -- Energy Overload
    -- Radial Sweep morphs → .id=4
    [22144]  = 4,   -- Empowering Sweep
    [22139]  = 4,   -- Crescent Sweep
    -- Nova morphs → .id=5
    [21755]  = 5,   -- Solar Prison
    [21758]  = 5,   -- Solar Disturbance
    -- Rite of Passage morphs → .id=6
    [22229]  = 6,   -- Remembrance
    [22226]  = 6,   -- Practiced Incantation
    -- Dragonknight Standard morphs → .id=7
    [28988]  = 7,   -- Dragonknight Standard (base)
    [32947]  = 7,   -- Standard of Might
    -- Dragon Leap morphs → .id=8
    [32715]  = 8,   -- Ferocious Leap
    [32719]  = 8,   -- Take Flight
    -- Magma Armor morphs → .id=9
    [17874]  = 9,   -- Magma Shell
    [17878]  = 9,   -- Corrosive Armor
    -- Death Stroke morphs → .id=10
    [113105] = 10,  -- Incapacitating Strike
    [36514]  = 10,  -- Soul Harvest
    -- Consuming Darkness morphs → .id=11
    [36493]  = 11,  -- Veil of Blades
    [36485]  = 11,  -- Bolstering Darkness
    -- Berserker Strike morphs → .id=17
    [83229]  = 17,  -- Onslaught
    [83238]  = 17,  -- Berserker Rage
    -- Shield Wall morphs → .id=18
    [83292]  = 18,  -- Spell Wall
    [83310]  = 18,  -- Shield Discipline
    -- Dual Wield morphs → .id=19
    [85179]  = 19,  -- Thrive in Chaos
    [85187]  = 19,  -- Rend
    -- Bow morphs → .id=20
    [85257]  = 20,  -- Toxic Barrage
    [85451]  = 20,  -- Ballista
    -- Destruction Staff morphs → .id=15
    [83625]  = 15,  -- Fire Storm
    [83628]  = 15,  -- Ice Storm
    [83630]  = 15,  -- Thunder Storm
    [84434]  = 15,  -- Elemental Rage
    [85126]  = 15,  -- Fiery Rage
    [85128]  = 15,  -- Icy Rage
    [85130]  = 15,  -- Thunderous Rage
    [83642]  = 15,  -- Eye of the Storm
    [83682]  = 15,  -- Eye of Flame
    [83684]  = 15,  -- Eye of Frost
    [83686]  = 15,  -- Eye of Lightning
    -- Restoration Staff morphs → .id=16
    [83589]  = 16,  -- Life Giver
    [83555]  = 16,  -- Light's Champion
    -- Vampire morphs → .id=23
    [38932]  = 23,  -- Devouring Swarm
    [38949]  = 23,  -- Clouding Swarm
    -- Meteor morphs → .id=24
    [40489]  = 24,  -- Ice Comet
    [40493]  = 24,  -- Shooting Star
    -- Dawnbreaker morphs → .id=25
    [40161]  = 25,  -- Flawless Dawnbreaker
    [40158]  = 25,  -- Dawnbreaker of Smiting
    -- Barrier morphs → .id=26
    [40237]  = 26,  -- Reviving Barrier
    [40238]  = 26,  -- Replenishing Barrier
    -- War Horn morphs → .id=27
    [38564]  = 27,  -- Aggressive Horn
    [40223]  = 27,  -- Sturdy Horn
    -- Soul Magic morphs → .id=21
    [40420]  = 21,  -- Shatter Soul
    [40414]  = 21,  -- Soul Assault
    -- Volendrung → Destro Staff (closest approximation per design decision)
    [116096] = 15,  -- Ruinous Cyclone (Volendrung)
    -- Cryptcannon (195031) intentionally NOT mapped — don't send heartbeat
    -- Other morphs (Warden guardian, Necro, Arcanist, Psijic) not mapped here
    -- will gracefully not send via RdK protocol
}

-- Build reverse table
for rdkId, esoId in pairs(RdKCompat.RDK_TO_ESO_ULT) do
    RdKCompat.ESO_TO_RDK_ULT[esoId] = rdkId
end
for esoId, rdkId in pairs(EXTRA_ESO_TO_RDK) do
    RdKCompat.ESO_TO_RDK_ULT[esoId] = rdkId
end

-- ============================================================================
-- RdK Synergy ID Mapping
-- RdK and Beltalowda share IDs 1-23 identically. No translation needed.
-- Beltalowda ID 24 (Recovery Convergence) has no RdK equivalent.
-- ============================================================================

local MAX_RDK_SYNERGY_ID = 23

-- ============================================================================
-- Encoding / Decoding (matches RdK's 4-byte-in-NumericField packing)
-- RdK packs 4 bytes (b0..b3) into a single NumericField via:
--   int24 = b0 * 16777216 + b1 * 65536 + b2 * 256 + b3
-- ============================================================================

function RdKCompat.Encode4Bytes(b0, b1, b2, b3)
    return b0 * 16777216 + b1 * 65536 + b2 * 256 + b3
end

function RdKCompat.Decode4Bytes(packed)
    local b0 = math.floor(packed / 16777216)
    local remainder = packed - b0 * 16777216
    local b1 = math.floor(remainder / 65536)
    remainder = remainder - b1 * 65536
    local b2 = math.floor(remainder / 256)
    local b3 = remainder - b2 * 256
    return b0, b1, b2, b3
end

-- ============================================================================
-- Initialization
-- ============================================================================

--[[
    Initialize the RdK compatibility layer.
    Must be called AFTER BeltalowdaNetwork.lgbHandler is registered.
    
    When RdK is loaded (RdKGTool global exists), this is a no-op.
    When RdK is not loaded, declares protocols 105 and 106 on Beltalowda's handler
    to both send and receive in RdK format.
]]--
function RdKCompat.Initialize()
    -- Initialize logger
    if not logger and Beltalowda.Logger and Beltalowda.Logger.CreateModuleLogger then
        logger = Beltalowda.Logger.CreateModuleLogger("RdKCompat")
    end

    -- Guard: User has disabled RdK compatibility
    if BeltalowdaVars and BeltalowdaVars.rdkCompatEnabled == false then
        if logger then
            logger:Info("RdK Network Compatibility is disabled in settings — skipping protocol declaration")
        end
        return
    end

    -- Guard: RdK is loaded — it owns protocols 105/106
    if BeltalowdaNetwork.rdkDetected then
        if logger then
            logger:Info("RdKGTool detected — skipping RdK protocol declaration (RdK owns 105/106)")
        end
        return
    end

    -- Guard: LGB handler must exist
    if not BeltalowdaNetwork.lgbHandler then
        if logger then
            logger:Error("LGB handler not registered — cannot declare RdK protocols")
        end
        return
    end

    local LGB = nil
    if LibStub then
        LGB = LibStub:GetLibrary("LibGroupBroadcast", true)
    end
    LGB = LGB or LibGroupBroadcast
    if not LGB then
        if logger then
            logger:Error("LibGroupBroadcast not available for RdK compat")
        end
        return
    end

    -- Declare RdK protocols in a pcall — another addon may have claimed them
    local success, err = pcall(function()
        -- ================================================================
        -- Protocol 105: RdK Heartbeat
        -- Single NumericField packing 4 bytes:
        --   b0 = rdkUltId (1-41)
        --   b1 = ultPct (0-100) in low 7 bits, debuff flag in bit 7
        --   b2 = magPct (0-100) in low 7 bits, debuff flag in bit 7
        --   b3 = stamPct (0-100) in low 7 bits, debuff flag in bit 7
        -- ================================================================
        RdKCompat.heartbeatProtocol = BeltalowdaNetwork.lgbHandler:DeclareProtocol(
            RDK_HEARTBEAT_ID,
            "BeltalowdaRdKHeartbeat"
        )

        RdKCompat.heartbeatProtocol:AddField(LGB.CreateNumericField("numeric", {
            minValue = 0,
            maxValue = 4294967295,  -- 2^32 - 1 (4 bytes packed)
        }))

        RdKCompat.heartbeatProtocol:OnData(function(unitTag, data)
            local ok, innerErr = pcall(function()
                if not data or not data.numeric then return end
                RdKCompat.OnRdKHeartbeatReceived(unitTag, data.numeric)
            end)
            if not ok and logger then
                logger:Error("Error in RdK heartbeat receive", tostring(innerErr))
            end
        end)

        RdKCompat.heartbeatProtocol:Finalize({
            isRelevantInCombat = true,
            replaceQueuedMessages = true,
        })

        if logger then
            logger:Info("Declared RdK heartbeat protocol 105")
        end

        -- ================================================================
        -- Protocol 106: RdK Synergy
        -- Single NumericField packing 4 bytes:
        --   b0 = 110 (MESSAGE_ID_SYNERGY marker)
        --   b1 = synergyId (1-23)
        --   b2 = delay in deciseconds
        --   b3 = debuff flags (0-7, ignored by Beltalowda)
        -- ================================================================
        RdKCompat.synergyProtocol = BeltalowdaNetwork.lgbHandler:DeclareProtocol(
            RDK_SYNERGY_ID,
            "BeltalowdaRdKSynergy"
        )

        RdKCompat.synergyProtocol:AddField(LGB.CreateNumericField("numeric", {
            minValue = 0,
            maxValue = 4294967295,
        }))

        RdKCompat.synergyProtocol:OnData(function(unitTag, data)
            local ok, innerErr = pcall(function()
                if not data or not data.numeric then return end
                RdKCompat.OnRdKSynergyReceived(unitTag, data.numeric)
            end)
            if not ok and logger then
                logger:Error("Error in RdK synergy receive", tostring(innerErr))
            end
        end)

        RdKCompat.synergyProtocol:Finalize({
            isRelevantInCombat = true,
            replaceQueuedMessages = false,
        })

        if logger then
            logger:Info("Declared RdK synergy protocol 106")
        end
    end)

    if not success then
        -- Another addon already claimed 105 or 106
        if logger then
            logger:Warn("Could not declare RdK protocols: " .. tostring(err))
        end
        d("[Beltalowda] RdK compat: could not claim protocols 105/106 (another addon may own them)")
        RdKCompat.heartbeatProtocol = nil
        RdKCompat.synergyProtocol = nil
        return
    end

    -- Start heartbeat timer
    EVENT_MANAGER:RegisterForUpdate(
        "BeltalowdaRdKHeartbeat",
        HEARTBEAT_INTERVAL_MS,
        RdKCompat.HeartbeatTick
    )

    RdKCompat.active = true
    if logger then
        logger:Info("RdK compatibility layer active — sending/receiving on protocols 105, 106")
    end
end

-- ============================================================================
-- Receiving: RdK Heartbeat (Protocol 105)
-- ============================================================================

--[[
    Handle a heartbeat received from an RdK user.
    Translates RdK's compact format into Beltalowda's playerData structure.
    
    If we already have recent Beltalowda protocol 221 data for this player,
    we prefer the Beltalowda data (richer: front/back bar, Volendrung, >100% ult).
]]--
function RdKCompat.OnRdKHeartbeatReceived(unitTag, numericVal)
    local b0, b1, b2, b3 = RdKCompat.Decode4Bytes(numericVal)

    -- b0 = RdK ultimate index (1-41)
    local rdkUltId = b0
    local esoUltId = RdKCompat.RDK_TO_ESO_ULT[rdkUltId]
    if not esoUltId then
        if logger then
            logger:Debug("Unknown RdK ult id", string.format("b0=%d from %s", rdkUltId, tostring(unitTag)))
        end
        return
    end

    -- Extract percentages from low 7 bits (bit 7 is debuff flag, ignored)
    local ultPct = b1 % 128
    local magPct = b2 % 128
    local stamPct = b3 % 128

    local charName = GetUnitName(unitTag)
    if not charName or charName == "" then return end

    -- Never overwrite local player data with RdK heartbeats.  The local
    -- client has authoritative ultimate information via CUS.BroadcastSelection
    -- which runs every 1 s.  RdK heartbeats carry only base-morph IDs
    -- (from RDK_TO_ESO_ULT) which would replace the correct morph-specific
    -- IDs that CUS already wrote.
    if charName == GetUnitName("player") then return end

    -- Check data priority: prefer Beltalowda-sourced data if it's fresh
    local GUD = Beltalowda.UI and Beltalowda.UI.GroupUltimateDisplay
    if not GUD then return end

    local playerData = GUD.playerData
    if not playerData then return end

    local existing = playerData[charName]
    if existing and existing.source == "beltalowda" then
        local now = GetGameTimeMilliseconds()
        if existing.lastUpdate and (now - existing.lastUpdate) < BELTALOWDA_DATA_FRESHNESS_MS then
            -- Fresh Beltalowda data exists — skip RdK update
            return
        end
    end

    -- Write RdK data into playerData (same fields the UI expects)
    playerData[charName] = playerData[charName] or {}
    local pd = playerData[charName]
    pd.selectedUltimateId = esoUltId
    pd.ultimatePercent = ultPct
    pd.frontbarUltimateId = esoUltId  -- RdK doesn't distinguish bars
    pd.backbarUltimateId = esoUltId
    pd.magickaPercent = magPct
    pd.staminaPercent = stamPct
    pd.inCombat = false   -- RdK doesn't carry combat state in heartbeat
    pd.hasVolendrung = false
    pd.volendrungBar = nil
    pd.originalUltId = nil
    pd.source = "rdk"
    pd.lastUpdate = GetGameTimeMilliseconds()

    if logger then
        logger:Debug("RdK heartbeat received",
            string.format("from=%s, esoUlt=%d, ult=%d%%, mag=%d%%, stam=%d%%",
                charName, esoUltId, ultPct, magPct, stamPct))
    end

    -- Refresh display
    if GUD.RefreshDisplay then
        GUD.RefreshDisplay()
    end
end

-- ============================================================================
-- Receiving: RdK Synergy (Protocol 106)
-- ============================================================================

--[[
    Handle a synergy broadcast received from an RdK user.
    RdK uses the same synergy IDs 1-23 as Beltalowda.
]]--
function RdKCompat.OnRdKSynergyReceived(unitTag, numericVal)
    local b0, b1, b2, b3 = RdKCompat.Decode4Bytes(numericVal)

    -- b0 must be 110 (MESSAGE_ID_SYNERGY) — other b0 values are different
    -- message types on protocol 106 (e.g., debuff updates)
    if b0 ~= RDK_MESSAGE_ID_SYNERGY then
        return
    end

    local synergyId = b1
    local delayDeciseconds = b2
    local delayMs = delayDeciseconds * 100

    if synergyId < 1 or synergyId > MAX_RDK_SYNERGY_ID then
        if logger then
            logger:Debug("RdK synergy id out of range", string.format("id=%d from %s", synergyId, tostring(unitTag)))
        end
        return
    end

    local charName = GetUnitName(unitTag)
    if not charName or charName == "" then return end

    -- Forward to SynergyTracker — same path as Beltalowda's own synergy handler
    local ST = Beltalowda.Data and Beltalowda.Data.SynergyTracker
    if ST and ST.RecordSynergy then
        ST.RecordSynergy(charName, synergyId, delayMs)
    end

    if logger then
        logger:Debug("RdK synergy received",
            string.format("from=%s, synergy=%d, delay=%dms", charName, synergyId, delayMs))
    end
end

-- ============================================================================
-- Sending: RdK Heartbeat (Protocol 105)
-- ============================================================================

--[[
    Send a heartbeat in RdK format.
    Called from BroadcastManualUltimate in GroupBroadcast.lua alongside the
    Beltalowda protocol 221 send.
    
    @param ultimateId: ESO ability ID of the selected ultimate
    @param percentReady: Ultimate percent (0-500 in Beltalowda, capped to 100 for RdK)
]]--
function RdKCompat.SendHeartbeat(ultimateId, percentReady)
    if not RdKCompat.heartbeatProtocol then return end
    if GetGroupSize() == 0 then return end

    -- Map ESO ability ID to RdK b0 index
    local rdkUltId = RdKCompat.ESO_TO_RDK_ULT[ultimateId]
    if not rdkUltId then
        -- Unknown ESO ult (Cryptcannon, Warden, Necro, Arcanist, etc.)
        -- Don't send heartbeat — RdK can't display it anyway
        return
    end

    -- RdK caps ult% at 100 (7 bits, 0-127 range but semantically 0-100)
    local ultPct = math.min(100, math.max(0, math.floor(percentReady or 0)))

    -- Collect resource percentages (0-100 integer, matching RdK's range)
    local magPct = 0
    local stamPct = 0
    local magCur, magMax = GetUnitPower("player", POWERTYPE_MAGICKA)
    local stamCur, stamMax = GetUnitPower("player", POWERTYPE_STAMINA)
    if magMax > 0 then
        magPct = math.min(100, math.max(0, math.floor(magCur / magMax * 100 + 0.5)))
    end
    if stamMax > 0 then
        stamPct = math.min(100, math.max(0, math.floor(stamCur / stamMax * 100 + 0.5)))
    end

    -- Pack and send (debuff bits = 0, Beltalowda doesn't track debuffs)
    local packed = RdKCompat.Encode4Bytes(rdkUltId, ultPct, magPct, stamPct)

    local ok, err = pcall(function()
        RdKCompat.heartbeatProtocol:Send({numeric = packed})
    end)

    if not ok and logger then
        logger:Error("Error sending RdK heartbeat", tostring(err))
    end
end

-- ============================================================================
-- Sending: RdK Synergy (Protocol 106)
-- ============================================================================

--[[
    Send a synergy broadcast in RdK format.
    Called from BroadcastSynergy in GroupBroadcast.lua alongside the
    Beltalowda protocol 224 send.
    
    @param synergyId: Beltalowda synergy ID (same as RdK for 1-23)
    @param delay100ms: Delay since detection in 100ms units (Beltalowda)
                       RdK uses deciseconds which is the same unit (1 decisecond = 100ms)
]]--
function RdKCompat.SendSynergy(synergyId, delay100ms)
    if not RdKCompat.synergyProtocol then return end
    if GetGroupSize() == 0 then return end

    -- Beltalowda ID 24+ has no RdK equivalent
    if not synergyId or synergyId > MAX_RDK_SYNERGY_ID or synergyId < 1 then
        return
    end

    local safeDelay = math.max(0, math.min(255, math.floor(delay100ms or 0)))

    -- Pack: b0=110 (synergy marker), b1=synergyId, b2=delay, b3=0 (no debuffs)
    local packed = RdKCompat.Encode4Bytes(RDK_MESSAGE_ID_SYNERGY, synergyId, safeDelay, 0)

    local ok, err = pcall(function()
        RdKCompat.synergyProtocol:Send({numeric = packed})
    end)

    if not ok and logger then
        logger:Error("Error sending RdK synergy", tostring(err))
    end
end

-- ============================================================================
-- Periodic Heartbeat Timer
-- ============================================================================

--[[
    Periodic tick to send RdK-format heartbeat.
    Reads current player ultimate data from GUD.playerData (populated by CUS).
    Fires every 1000ms, matching RdK's NetworkLoop cadence.
]]--
function RdKCompat.HeartbeatTick()
    if not RdKCompat.active then return end
    if GetGroupSize() == 0 then return end

    -- Read current player's data from the shared playerData store
    local GUD = Beltalowda.UI and Beltalowda.UI.GroupUltimateDisplay
    if not GUD or not GUD.playerData then return end

    local playerName = GetUnitName("player")
    if not playerName or playerName == "" then return end

    local pd = GUD.playerData[playerName]
    if not pd then return end

    local ultimateId = pd.selectedUltimateId
    if not ultimateId or ultimateId <= 0 then return end

    local percentReady = pd.ultimatePercent or 0

    RdKCompat.SendHeartbeat(ultimateId, percentReady)
end
