--=====================================================================
-- Holodeck_Record.lua — arm / record / sample (v0.0.14)
--
-- Training packs = lean keyframes (boss / mini / elites), not video streams.
-- Dense samples only when capturing self/team (review mode).
-- Reticle path uses unit tag "reticleover" = whatever is under the crosshair
-- (soft aim) OR the locked hard-target when one is set. Not a room scan.
--=====================================================================

local H = Holodeck
if not H then return end

H.record = H.record or {
    state = "off",
    startMs = 0,
    samples = {},
    lastSampleMs = 0,
    tickName = "Holodeck_RecordTick",
    tickRunning = false,
    unitInfoById = {},
    activeBossIds = {},
    primaryTarget = nil,
    framesWithUnits = 0,
    lastProbe = nil, -- last reticle diagnostic (for empty-take chat)
}

local function dhd(msg)
    d(string.format("|c69c0ff[%s]|r %s", H.displayName or "Holodeck", tostring(msg)))
end

local function sv()
    return H.savedVars or {}
end

local function RecordStateLabel()
    local st = H.record.state or "off"
    if st == "running" then return "RUNNING" end
    if st == "armed" then return "ARMED" end
    return "OFF"
end
H.RecordStateLabel = RecordStateLabel

local function IsDenseCaptureMode()
    return sv().recordCaptureSelf == true or sv().recordCaptureTeam == true
end

-- ============================= Zone helpers =============================
local function IsGroupInstanceZone()
    if type(IsUnitInDungeon) == "function" then
        local ok, v = pcall(IsUnitInDungeon, "player")
        if ok and v then return true end
    end
    if type(GetMapContentType) == "function" then
        local ok, t = pcall(GetMapContentType)
        if ok and type(MAP_CONTENT_DUNGEON) == "number" and t == MAP_CONTENT_DUNGEON then
            return true
        end
    end
    if type(GetCurrentZoneDungeonDifficulty) == "function" then
        local ok, diff = pcall(GetCurrentZoneDungeonDifficulty)
        if ok and type(diff) == "number" and type(DUNGEON_DIFFICULTY_NONE) == "number" then
            if diff ~= DUNGEON_DIFFICULTY_NONE then return true end
        end
    end
    return false
end
H.IsGroupInstanceZone = IsGroupInstanceZone

local function BossUnitExists()
    for i = 1, 12 do
        local tag = "boss" .. i
        if type(DoesUnitExist) == "function" and DoesUnitExist(tag) then
            return true
        end
    end
    return false
end
H.BossUnitExists = BossUnitExists

local function GetZoneLabel()
    local z
    if type(GetPlayerActiveZoneName) == "function" then
        local ok, n = pcall(GetPlayerActiveZoneName)
        if ok and n and n ~= "" then z = n end
    end
    if (not z or z == "") and type(GetUnitZone) == "function" then
        local ok, n = pcall(GetUnitZone, "player")
        if ok and n and n ~= "" then z = n end
    end
    z = tostring(z or "zone")
    z = z:gsub("%s+", "_"):gsub("[^%w_%-]", ""):sub(1, 24)
    if z == "" then z = "zone" end
    return z
end

local function SanitizeKey(s)
    s = tostring(s or "x"):lower()
    s = s:gsub("%s+", "_"):gsub("[^%w_]", "")
    if s == "" then s = "unit" end
    return s:sub(1, 28)
end

-- ============================= Reticle / elite classification ============
local function GetUnitIdSafe(unitTag)
    if type(GetUnitUniqueId) == "function" then
        local ok, id = pcall(GetUnitUniqueId, unitTag)
        if ok and id and id ~= 0 then return id end
    end
    if type(GetUnitId) == "function" then
        local ok, id = pcall(GetUnitId, unitTag)
        if ok and id and id ~= 0 then return id end
    end
    return nil
end

local function GetUnitDifficultySafe(unitTag)
    if type(GetUnitDifficulty) == "function" then
        local ok, d = pcall(GetUnitDifficulty, unitTag)
        if ok then return d end
    end
    return nil
end

local function GetUnitMaxHealthSafe(unitTag)
    local flags = (type(COMBAT_MECHANIC_FLAGS_HEALTH) == "number") and COMBAT_MECHANIC_FLAGS_HEALTH
        or (type(POWERTYPE_HEALTH) == "number") and POWERTYPE_HEALTH
        or nil
    if flags and type(GetUnitPower) == "function" then
        local ok, cur, maxH = pcall(GetUnitPower, unitTag, flags)
        if ok then return maxH or 0 end
    end
    return 0
end

-- World XYZ for any unit tag. Tries Raw then World; tolerates 3- or 4-return APIs.
local function GetUnitWorldXYZ(unitTag)
    local function unpackPos(a, b, c, d)
        if type(b) == "number" and type(d) == "number" then
            return b, c, d -- zoneIndex, x, y, z
        end
        if type(a) == "number" and type(c) == "number" and d == nil then
            return a, b, c -- x, y, z
        end
        return nil, nil, nil
    end
    if type(GetUnitRawWorldPosition) == "function" then
        local ok, a, b, c, d = pcall(GetUnitRawWorldPosition, unitTag)
        if ok then
            local x, y, z = unpackPos(a, b, c, d)
            if x then return x, y, z end
        end
    end
    if type(GetUnitWorldPosition) == "function" then
        local ok, a, b, c, d = pcall(GetUnitWorldPosition, unitTag)
        if ok then
            local x, y, z = unpackPos(a, b, c, d)
            if x then return x, y, z end
        end
    end
    return nil, nil, nil
end

local function RefreshActiveBossIds()
    H.record.activeBossIds = {}
    for i = 1, 8 do
        local tag = "boss" .. i
        if DoesUnitExist and DoesUnitExist(tag) then
            local id = GetUnitIdSafe(tag)
            if id then H.record.activeBossIds[id] = tag end
            local n = GetUnitName and GetUnitName(tag)
            if n and n ~= "" and not H.record.primaryTarget then
                H.record.primaryTarget = n
            end
        end
    end
end

-- Difficulty rank 0..4 (higher = harder). Uses API constants when present.
local function DifficultyRank(diff)
    if diff == nil then return -1 end
    local order = {
        { (type(MONSTER_DIFFICULTY_NONE) == "number") and MONSTER_DIFFICULTY_NONE or 0, 0 },
        { (type(MONSTER_DIFFICULTY_EASY) == "number") and MONSTER_DIFFICULTY_EASY or 1, 1 },
        { (type(MONSTER_DIFFICULTY_NORMAL) == "number") and MONSTER_DIFFICULTY_NORMAL or 2, 2 },
        { (type(MONSTER_DIFFICULTY_HARD) == "number") and MONSTER_DIFFICULTY_HARD or 3, 3 },
        { (type(MONSTER_DIFFICULTY_DEADLY) == "number") and MONSTER_DIFFICULTY_DEADLY or 4, 4 },
    }
    for _, pair in ipairs(order) do
        if diff == pair[1] then return pair[2] end
    end
    if type(diff) == "number" then
        if diff >= 4 then return 4 end
        if diff >= 0 then return diff end
    end
    return -1
end

-- Returns classKey, holodeckKind, rank (0-4)
local function ClassifyEnemy(unitId, info)
    if unitId and H.record.activeBossIds[unitId] then
        return "BOSS", "boss", 4
    end
    if not info then return "UNKNOWN", "mini", -1 end

    local nlow = string.lower(tostring(info.name or ""))
    -- Named pack officers / captains → mini pin (training)
    if string.find(nlow, "lieutenant", 1, true)
        or string.find(nlow, "captain", 1, true)
        or string.find(nlow, "deadraiser", 1, true)
        or string.find(nlow, "sentinel", 1, true)
        or string.find(nlow, "overseer", 1, true) then
        return "MINIBOSS", "mini", 4
    end

    local rank = DifficultyRank(info.difficulty)
    if rank >= 4 then return "ELITE_OR_MINIBOSS", "mini", rank end
    if rank >= 3 then return "LT_OR_ELITE", "mini", rank end
    if rank >= 2 then return "MOB", "mini", rank end
    if rank >= 0 then return "MOB", "stack", rank end

    if (info.maxHealth or 0) >= 50000 then
        return "ELITE_OR_MINIBOSS", "mini", 3
    end
    return "UNKNOWN", "mini", -1
end

local function IsHostileNpc(unitTag)
    if not DoesUnitExist or not DoesUnitExist(unitTag) then return false end
    if type(IsUnitPlayer) == "function" then
        local ok, p = pcall(IsUnitPlayer, unitTag)
        if ok and p then return false end
    end
    if type(IsUnitDead) == "function" then
        local ok, dead = pcall(IsUnitDead, unitTag)
        if ok and dead then return false end
    end
    if type(IsUnitFriend) == "function" then
        local ok, f = pcall(IsUnitFriend, unitTag)
        if ok and f then return false end
    end
    if type(IsUnitGrouped) == "function" then
        local ok, g = pcall(IsUnitGrouped, unitTag)
        if ok and g then return false end
    end

    -- Strongest signal (same pattern as CrutchAlerts / combat addons)
    if type(GetUnitReaction) == "function" then
        local ok, r = pcall(GetUnitReaction, unitTag)
        if ok and r ~= nil then
            if type(UNIT_REACTION_HOSTILE) == "number" and r == UNIT_REACTION_HOSTILE then
                return true
            end
            if type(UNIT_REACTION_NPC_ENEMY) == "number" and r == UNIT_REACTION_NPC_ENEMY then
                return true
            end
            if type(UNIT_REACTION_NEUTRAL) == "number" and r == UNIT_REACTION_NEUTRAL then
                -- neutrals sometimes become attackable in combat; fall through
            elseif type(UNIT_REACTION_FRIENDLY) == "number" and r == UNIT_REACTION_FRIENDLY then
                return false
            elseif type(UNIT_REACTION_PLAYER_ALLY) == "number" and r == UNIT_REACTION_PLAYER_ALLY then
                return false
            end
        end
    end

    if type(IsUnitAttackable) == "function" then
        local ok, a = pcall(IsUnitAttackable, unitTag)
        if ok and a then return true end
    end
    if type(IsUnitMonster) == "function" then
        local ok, m = pcall(IsUnitMonster, unitTag)
        if ok and m then return true end
    end

    -- Last resort: named non-player under reticle (console APIs can be sparse)
    local n = GetUnitName and GetUnitName(unitTag)
    return (n and n ~= "" and unitTag ~= "player")
end

local function MinEliteTier()
    -- Checkbox "Capture elites" is the on/off. Tier is the filter only.
    -- 1 = deadly, 2 = hard+, 3 = normal+, 4 = any hostile on reticle
    -- Legacy: tier 0 was "off" — if elites checkbox is ON, treat 0 as 4.
    local t = tonumber(sv().recordEliteTier)
    if t == nil then return 4 end
    if t <= 0 then
        if sv().recordCaptureElites ~= false then return 4 end
        return 0
    end
    return t
end

local function EliteAllowedByTier(info)
    local tier = MinEliteTier()
    if tier <= 0 then return false end
    if not info then
        -- No info: only allow when "any hostile" (tier 4)
        return tier >= 4
    end
    if tier >= 4 then return true end -- any hostile on reticle

    local rank = info.rank
    if rank == nil then rank = DifficultyRank(info.difficulty) end
    local hp = tonumber(info.maxHealth) or 0

    -- Unknown difficulty: do NOT treat as Hard+ (was capturing all trash on glance).
    -- Allow only fat HP packs / named mini patterns (ClassifyEnemy sets rank>=3 for those).
    if rank < 0 then
        if hp >= 200000 then return true end          -- ~elite pack HP and up
        if info.classKey == "MINIBOSS" or info.classKey == "ELITE_OR_MINIBOSS" then
            return true
        end
        -- Named captains/LTs already get rank 4 via ClassifyEnemy when name matches
        return false
    end
    if tier == 1 then return rank >= 4 end -- deadly only
    if tier == 2 then return rank >= 3 end -- hard+
    if tier >= 3 then return rank >= 2 end -- normal+
    return false
end

local function CaptureReticleTarget()
    local unitTag = "reticleover"
    if not DoesUnitExist or not DoesUnitExist(unitTag) then return nil end
    if not IsHostileNpc(unitTag) then return nil end

    local unitId = GetUnitIdSafe(unitTag)
    local name = (GetUnitName and GetUnitName(unitTag)) or "enemy"
    local difficulty = GetUnitDifficultySafe(unitTag)
    local maxHealth = GetUnitMaxHealthSafe(unitTag)

    local keyId = unitId or (SanitizeKey(name) .. "_" .. tostring(difficulty or "x"))
    local info = {
        name = name,
        difficulty = difficulty,
        maxHealth = maxHealth or 0,
        lastSeenMs = GetFrameTimeMilliseconds() or 0,
    }
    local classKey, kind, rank = ClassifyEnemy(unitId, info)
    info.classKey = classKey
    info.kind = kind
    info.rank = rank
    info.unitTag = unitTag
    H.record.unitInfoById[keyId] = info
    return keyId, info
end

-- Live diagnostic used by /hd record status and empty-take chat.
local function ProbeReticle()
    local tag = "reticleover"
    local p = {
        exists = false,
        name = nil,
        hostile = false,
        hasPos = false,
        x = nil, z = nil,
        difficulty = nil,
        rank = -1,
        maxHealth = 0,
        unitId = nil,
        capBoss = sv().recordCaptureBosses ~= false,
        capElite = sv().recordCaptureElites ~= false,
        eliteTier = MinEliteTier(),
        bossBar = BossUnitExists(),
        reason = "no reticle unit",
    }
    -- Soft name peek even if DoesUnitExist is flaky (console)
    local softName = (GetUnitName and GetUnitName(tag)) or nil
    if (not DoesUnitExist or not DoesUnitExist(tag)) and (not softName or softName == "") then
        p.reason = "no reticle unit — point crosshair at a hostile (soft aim), then probe again"
        H.record.lastProbe = p
        return p
    end
    p.exists = (DoesUnitExist and DoesUnitExist(tag)) and true or false
    p.name = softName or "?"
    if not p.exists and softName and softName ~= "" then
        -- Name visible but unit tag not "existing" — still try capture path diagnostics
        p.exists = true
        p.reason = "name only (DoesUnitExist false) — will try capture anyway"
    end
    p.hostile = IsHostileNpc(tag)
    p.difficulty = GetUnitDifficultySafe(tag)
    p.rank = DifficultyRank(p.difficulty)
    p.maxHealth = GetUnitMaxHealthSafe(tag) or 0
    p.unitId = GetUnitIdSafe(tag)
    local x, _, z = GetUnitWorldXYZ(tag)
    if x then
        p.hasPos = true
        p.x, p.z = x, z
    end
    local classKey, _, rank2 = ClassifyEnemy(p.unitId, {
        name = p.name, difficulty = p.difficulty, maxHealth = p.maxHealth,
    })
    if rank2 and rank2 >= 0 then p.rank = rank2 end
    local infoLike = {
        difficulty = p.difficulty, rank = p.rank, maxHealth = p.maxHealth,
        classKey = classKey, name = p.name,
    }
    local allowElite = p.capElite and EliteAllowedByTier(infoLike)
    local allowAsBoss = p.capBoss and not p.bossBar
    if not p.hostile then
        p.reason = "reticle not hostile (friend/dead/neutral?) — lock a hostile target"
    elseif not p.hasPos then
        p.reason = "hostile but no world position from API"
    elseif not p.capBoss and not p.capElite then
        p.reason = "capture bosses+elites both OFF in settings"
    elseif allowElite then
        p.reason = string.format("OK — would capture as elite/mini (rank=%s hp=%.0f)",
            tostring(p.rank), p.maxHealth or 0)
    elseif allowAsBoss then
        p.reason = "OK — would capture as boss_reticle (no boss bar)"
    elseif p.capElite and not allowElite then
        p.reason = string.format(
            "tier filter blocked (tier=%s rank=%s hp=%.0f) — raise filter or use Any hostile",
            tostring(p.eliteTier), tostring(p.rank), p.maxHealth or 0)
    elseif p.capBoss and p.bossBar then
        p.reason = "OK — on boss bar (boss1–8 path)"
    else
        p.reason = "blocked — check /hdsettings capture toggles"
    end
    H.record.lastProbe = p
    return p
end
H.ProbeReticle = ProbeReticle

local function DumpProbe(p)
    p = p or ProbeReticle()
    dhd(string.format(
        "Probe reticle: exist=%s name=%s hostile=%s pos=%s tier=%s bossBar=%s capB/E=%s/%s",
        tostring(p.exists), tostring(p.name), tostring(p.hostile), tostring(p.hasPos),
        tostring(p.eliteTier), tostring(p.bossBar), tostring(p.capBoss), tostring(p.capElite)))
    if p.maxHealth and p.maxHealth > 0 then
        dhd(string.format("  hp=%.0f rank=%s", p.maxHealth, tostring(p.rank)))
    end
    dhd("  → " .. tostring(p.reason))
    if not p.exists or p.reason:find("no reticle", 1, true) then
        dhd("  Tip: soft-aim the crosshair onto the mob — hard-target not required.")
    end
end

-- ============================= Sampling ===============================
local function RawToLocal(rx, rz)
    if not H.origin then return nil end
    if rx == nil or rz == nil then return nil end
    return (rx - H.origin.x) / 100, (rz - H.origin.z) / 100
end

local function EnsureOriginFromPlayerIfNeeded()
    if H.origin then return true end
    if sv().recordRequirePlant then
        dhd("Record blocked: |cC0E0FF/hd plant|r first (require plant is ON in settings).")
        return false
    end
    local x, y, z = GetUnitWorldXYZ("player")
    if not x then return false end
    H.origin = { x = x, y = y, z = z }
    dhd("Record: no plant — origin at player (relative take). Prefer /hd plant at a landmark.")
    if type(H.EnsureOriginMarker) == "function" then pcall(H.EnsureOriginMarker) end
    return true
end

local function CollectUnitsNow()
    local units = {}
    local function add(tag, kind, nameHint, keyOverride)
        if not DoesUnitExist or not DoesUnitExist(tag) then return false end
        local x, _, z = GetUnitWorldXYZ(tag)
        if not x then return false end
        local lx, lz = RawToLocal(x, z)
        if not lx then return false end
        local name = nameHint
        if not name or name == "" then
            name = (GetUnitDisplayName and GetUnitDisplayName(tag))
                or (GetUnitName and GetUnitName(tag))
                or tag
        end
        local key = keyOverride or tag
        units[key] = {
            x = math.floor(lx * 100 + 0.5) / 100,
            z = math.floor(lz * 100 + 0.5) / 100,
            name = name,
            kind = kind or "stack",
        }
        if not H.record.primaryTarget and (kind == "boss" or kind == "mini") then
            H.record.primaryTarget = name
        end
        return true
    end

    local capBoss = sv().recordCaptureBosses ~= false
    local capSelf = sv().recordCaptureSelf == true
    local capTeam = sv().recordCaptureTeam == true
    local capElite = sv().recordCaptureElites ~= false

    if capSelf then add("player", "stack", "player") end
    if capTeam and type(GetGroupSize) == "function" then
        local n = GetGroupSize() or 0
        for i = 1, n do
            local tag = GetGroupUnitTagByIndex and GetGroupUnitTagByIndex(i)
            if tag and tag ~= "player" then add(tag, "stack", nil) end
        end
    end

    -- Boss bar units (trials / dungeons that expose boss1–8)
    if capBoss then
        for i = 1, 8 do
            local tag = "boss" .. i
            local n = (GetUnitName and GetUnitName(tag)) or tag
            add(tag, "boss", n, tag)
        end
    end

    -- Reticleover = unit under crosshair (soft) or locked hard-target (sticky when looking away).
    -- Pack elites / delve minis almost never appear as boss1 — this is the main path.
    if (capBoss or capElite) and DoesUnitExist and DoesUnitExist("reticleover") then
        ProbeReticle()
        if IsHostileNpc("reticleover") then
            local keyId, info = CaptureReticleTarget()
            local name = (info and info.name) or (GetUnitName and GetUnitName("reticleover")) or "enemy"
            local unitId = keyId or GetUnitIdSafe("reticleover")
            local onBossBar = unitId and H.record.activeBossIds[unitId]
            if not onBossBar then
                local kind, ekey
                local allowElite = capElite and EliteAllowedByTier(info)
                local allowAsBoss = capBoss and not BossUnitExists()
                if allowElite then
                    kind = (info and info.kind) or "mini"
                    if info and info.classKey == "BOSS" then kind = "boss" end
                    ekey = "elite_" .. SanitizeKey(name) .. "_" .. tostring(unitId or SanitizeKey(name))
                elseif allowAsBoss then
                    -- No boss bar + bosses ON → treat aimed hostile as the training target
                    kind = "boss"
                    ekey = "boss_reticle"
                end
                if kind and ekey then
                    if add("reticleover", kind, name, ekey) then
                        if not H.record.primaryTarget then H.record.primaryTarget = name end
                    end
                end
            end
        end
    end

    return units
end

local function CountUnitsInSamples(samples)
    local n = 0
    for _, frame in ipairs(samples or {}) do
        if frame.units then
            for _ in pairs(frame.units) do n = n + 1 end
        end
    end
    return n
end

local function PushSample()
    if H.record.state ~= "running" then return end
    if not EnsureOriginFromPlayerIfNeeded() then
        H.RecordStop(true)
        H.RecordDisarm(true)
        return
    end
    RefreshActiveBossIds()
    CaptureReticleTarget()

    local now = GetFrameTimeMilliseconds() or 0
    local interval = tonumber(sv().recordIntervalMs) or 400
    if IsDenseCaptureMode() then
        if interval < 150 then interval = 150 end
    else
        -- Lean training mode: slower poll; keyframe collapse matters more than rate
        if interval < 300 then interval = 300 end
    end
    if H.record.lastSampleMs > 0 and (now - H.record.lastSampleMs) < interval then
        return
    end
    H.record.lastSampleMs = now
    local t = (now - (H.record.startMs or now)) / 1000
    if t < 0 then t = 0 end
    local units = CollectUnitsNow()
    local has = false
    for _ in pairs(units) do has = true break end
    if has then H.record.framesWithUnits = (H.record.framesWithUnits or 0) + 1 end
    H.record.samples[#H.record.samples + 1] = { t = t, units = units }
end

local function StopRecordTick()
    if not H.record.tickRunning then return end
    EVENT_MANAGER:UnregisterForUpdate(H.record.tickName)
    H.record.tickRunning = false
end

local function StartRecordTick()
    if H.record.tickRunning then return end
    EVENT_MANAGER:RegisterForUpdate(H.record.tickName, 100, function()
        PushSample()
    end)
    H.record.tickRunning = true
end

-- ============================= Keyframe collapse ========================
-- Lean: keep sparse stops like manual edit (hold / walk / snap).
-- Dense (self/team): keep closer samples for review / screenshare.
local function CollapseTrack(points, dense)
    if not points or #points == 0 then return {} end
    if #points == 1 then
        local p = points[1]
        return { { t = p.t, x = p.x, z = p.z, hold = 0, visible = true, snap = false } }
    end

    local moveThresh = dense and 0.35 or 1.25      -- meters
    local snapDist = dense and 12 or 8             -- meters in one step = snap
    local stillSec = dense and 0.8 or 1.25         -- seconds still → hold

    local out = {}
    local cur = {
        t = points[1].t, x = points[1].x, z = points[1].z,
        hold = 0, visible = true, snap = false,
    }
    out[1] = cur

    for i = 2, #points do
        local p = points[i]
        local prev = out[#out]
        local dx, dz = (p.x or 0) - (prev.x or 0), (p.z or 0) - (prev.z or 0)
        local dist = math.sqrt(dx * dx + dz * dz)
        local dt = (p.t or 0) - (prev.t or 0) - (prev.hold or 0)
        if dt < 0 then dt = 0 end

        if dist < moveThresh then
            -- still (or jitter): extend hold on previous keyframe
            local leave = (prev.t or 0) + (prev.hold or 0)
            if (p.t or 0) > leave then
                prev.hold = math.floor(((p.t or 0) - (prev.t or 0)) * 100 + 0.5) / 100
            end
        else
            local isSnap = dist >= snapDist and dt <= 0.75
            -- close previous hold if we were still before this move
            if not isSnap and dt > stillSec and dist >= moveThresh then
                -- walk after a stand: hold already on prev
            end
            out[#out + 1] = {
                t = p.t,
                x = p.x,
                z = p.z,
                hold = 0,
                visible = true,
                snap = isSnap,
            }
        end
    end
    return out
end

local function ApplyRecordingToSandbox()
    local samples = H.record.samples
    if not samples or #samples == 0 then
        dhd("Record: no samples.")
        return false
    end
    if CountUnitsInSamples(samples) == 0 then
        dhd("Record: |cFF5555no units captured|r (boss not on bar? elites not reticle'd? check /hdsettings capture). Not applying empty take.")
        return false
    end

    local dense = IsDenseCaptureMode()
    -- Gather raw points per key
    local raw = {}
    local kinds = {}
    local names = {}
    for _, frame in ipairs(samples) do
        local t = frame.t or 0
        for key, u in pairs(frame.units or {}) do
            if not raw[key] then raw[key] = {} end
            kinds[key] = u.kind or "stack"
            names[key] = u.name or key
            raw[key][#raw[key] + 1] = { t = t, x = u.x, z = u.z }
        end
    end

    local tracks = {}
    for key, pts in pairs(raw) do
        tracks[key] = CollapseTrack(pts, dense)
    end

    H.stops = tracks
    H.types = kinds
    H.workingName = "sandbox"
    H.clock = samples[#samples].t or 0
    H.playT = 0
    H.playFinished = false
    H.playing = false

    if type(H.PreferPlayFight) == "function" then pcall(H.PreferPlayFight) end
    if type(H.RebuildPathGfx) == "function" then pcall(H.RebuildPathGfx) end
    if type(H.ApplyTimeline) == "function" then pcall(H.ApplyTimeline, 0, false) end
    if type(H.RefreshUI) == "function" then pcall(H.RefreshUI) end

    local entCount = 0
    for _ in pairs(tracks) do entCount = entCount + 1 end
    dhd(string.format("Record applied: %d entities, %s keyframes (%s mode).",
        entCount, dense and "dense" or "lean", dense and "review" or "training"))
    return true
end

local function BuildSaveMeta()
    return {
        zone = GetZoneLabel(),
        target = H.record.primaryTarget or "fight",
        captureBosses = sv().recordCaptureBosses ~= false,
        captureSelf = sv().recordCaptureSelf == true,
        captureTeam = sv().recordCaptureTeam == true,
        captureElites = sv().recordCaptureElites ~= false,
        dense = IsDenseCaptureMode(),
        samples = #(H.record.samples or {}),
        framesWithUnits = H.record.framesWithUnits or 0,
        duration = (H.record.samples and H.record.samples[#H.record.samples] and H.record.samples[#H.record.samples].t) or 0,
        savedAt = GetTimeStamp and GetTimeStamp() or GetFrameTimeMilliseconds(),
    }
end

local function BuildSaveName(meta)
    meta = meta or BuildSaveMeta()
    local zone = SanitizeKey(meta.zone or "zone")
    local target = SanitizeKey(meta.target or "fight")
    local ts = tostring(meta.savedAt or GetFrameTimeMilliseconds())
    -- Human-ish id: zone_target_timestamp
    return string.format("%s_%s_%s", zone, target, ts:sub(-8))
end

local function AutosaveTake()
    if not sv().recordAutoSave then return end
    if CountUnitsInSamples(H.record.samples) == 0 then
        dhd("Record: skip autosave (empty — no units).")
        return
    end
    local meta = BuildSaveMeta()
    local name = BuildSaveName(meta)
    if H.savedVars then
        if not H.savedVars.saves then H.savedVars.saves = {} end
        if type(H.SerializeStops) == "function" then
            local data = H.SerializeStops()
            data.name = name
            data.meta = meta
            data.displayName = string.format("%s · %s · %.0fs · %s",
                meta.zone or "zone",
                meta.target or "fight",
                meta.duration or 0,
                meta.dense and "dense" or "lean")
            H.savedVars.saves[name] = data
            H.savedVars.lastSaveName = name
            H.workingName = name
            dhd("Record autosaved:")
            dhd("  title: " .. (data.displayName or name))
            dhd("  id:    |cC0E0FF" .. name .. "|r")
            dhd("  open:  |cC0E0FF/hd open last|r  or  |cC0E0FF/hd open 1|r  (after /hd saves)")
        end
    end
end

-- ============================= Public commands ==========================
function H.RecordArm(silent)
    H.record.state = "armed"
    if not silent then
        dhd("Record |cC0E0FFARMED|r — start per settings or /hd record start.")
    end
    if type(H.RefreshUI) == "function" then pcall(H.RefreshUI) end
end

function H.RecordDisarm(silent)
    if H.record.state == "running" then
        H.RecordStop(true)
    end
    H.record.state = "off"
    StopRecordTick()
    if not silent then dhd("Record |cAAAAAAOFF|r (disarmed).") end
    if type(H.RefreshUI) == "function" then pcall(H.RefreshUI) end
end

function H.RecordStart(silent)
    if H.record.state == "running" then
        if not silent then dhd("Already recording.") end
        return
    end
    if sv().recordRequirePlant and not H.origin then
        dhd("Plant first: |cC0E0FF/hd plant|r (required in settings).")
        return
    end
    H.record.state = "running"
    H.record.startMs = GetFrameTimeMilliseconds() or 0
    H.record.lastSampleMs = 0
    H.record.samples = {}
    H.record.framesWithUnits = 0
    H.record.primaryTarget = nil
    H.record.unitInfoById = H.record.unitInfoById or {}
    if not EnsureOriginFromPlayerIfNeeded() then
        H.record.state = "armed"
        return
    end
    RefreshActiveBossIds()
    StartRecordTick()
    PushSample()
    if not silent then
        local bits = {}
        if sv().recordCaptureBosses ~= false then bits[#bits + 1] = "bosses" end
        if sv().recordCaptureElites ~= false then bits[#bits + 1] = "elites(reticle)" end
        if sv().recordCaptureSelf then bits[#bits + 1] = "self" end
        if sv().recordCaptureTeam then bits[#bits + 1] = "team" end
        if #bits == 0 then bits[1] = "nothing — enable targets in /hdsettings" end
        dhd("Record |cFF5555RUNNING|r — " .. table.concat(bits, "+")
            .. (IsDenseCaptureMode() and " (dense)" or " (lean keyframes)"))
        dhd("Soft-aim: keep crosshair on the unit to sample it. No hard-target required.")
        local p = ProbeReticle()
        if p.exists then
            dhd(string.format("  reticle now: %s · hostile=%s · pos=%s",
                tostring(p.name), tostring(p.hostile), tostring(p.hasPos)))
        else
            dhd("  reticle now: |cFF5555none|r — point crosshair at a hostile, then /hd record probe")
        end
    end
    if type(H.RefreshUI) == "function" then pcall(H.RefreshUI) end
end

function H.RecordStop(silent)
    if H.record.state ~= "running" then
        if not silent then dhd("Not recording.") end
        return
    end
    StopRecordTick()
    PushSample()
    local n = #(H.record.samples or {})
    local u = CountUnitsInSamples(H.record.samples)
    H.record.state = "armed"
    if not silent then
        dhd(string.format("Record stopped — %d frames, %d unit-hits.", n, u))
    end
    if u == 0 then
        dhd("|cFF5555Empty take|r — nothing to play.")
        dhd("During the take, keep the |cC0E0FFcrosshair on|r the unit(s) you want (soft aim works).")
        DumpProbe(ProbeReticle())
        dhd("Also check: Capture elites ON · filter not over-strict · /hdsettings")
        if type(H.RefreshUI) == "function" then pcall(H.RefreshUI) end
        return
    end
    if ApplyRecordingToSandbox() then
        if sv().recordAutoSave then
            AutosaveTake()
        else
            dhd("In sandbox. /hd play once  ·  /hd save <name>  ·  /hd sheet on")
        end
    end
    if type(H.RefreshUI) == "function" then pcall(H.RefreshUI) end
end

-- ============================= Auto policies ============================
local function MaybeAutoArm()
    if not sv().autoArmInInstances then return end
    if not IsGroupInstanceZone() then return end
    if H.record.state == "off" then
        H.RecordArm(true)
        dhd("Auto-arm: ARMED · start=" .. tostring(sv().recordStartMode or "boss"))
    end
end

local function MaybeAutoDisarmOutside()
    if not sv().autoArmInInstances then return end
    if IsGroupInstanceZone() then return end
    if H.record.state == "running" then H.RecordStop(true) end
    if H.record.state == "armed" then H.RecordDisarm(true) end
end

local function OnCombatState(_, inCombat)
    local mode = sv().recordStartMode or "boss"
    if H.record.state == "running" then
        if not inCombat and sv().recordAutoStop ~= false then
            H.RecordStop(false)
        end
        return
    end
    if H.record.state ~= "armed" then return end
    if not inCombat then return end
    if mode == "manual" then return end
    if mode == "boss" and not BossUnitExists() then return end
    H.RecordStart(false)
end

function H.InitRecordSystem()
    EVENT_MANAGER:RegisterForEvent(H.name .. "_RecCombat", EVENT_PLAYER_COMBAT_STATE, OnCombatState)
    EVENT_MANAGER:RegisterForEvent(H.name .. "_RecReticle", EVENT_RETICLE_TARGET_CHANGED, function()
        CaptureReticleTarget()
    end)
    EVENT_MANAGER:RegisterForEvent(H.name .. "_RecAct", EVENT_PLAYER_ACTIVATED, function()
        zo_callLater(function()
            MaybeAutoDisarmOutside()
            MaybeAutoArm()
            if type(H.RefreshUI) == "function" then pcall(H.RefreshUI) end
        end, 500)
    end)
    zo_callLater(MaybeAutoArm, 1000)
end

function H.CmdArm() H.RecordArm(false) end
function H.CmdDisarm() H.RecordDisarm(false) end
function H.CmdRecord(arg)
    arg = (arg or ""):lower():match("^%s*(%S*)") or ""
    if arg == "" or arg == "status" or arg == "probe" then
        dhd(string.format("Record state=%s frames=%d unitHits=%d startMode=%s dense=%s",
            RecordStateLabel(),
            #(H.record.samples or {}),
            CountUnitsInSamples(H.record.samples),
            tostring(sv().recordStartMode or "boss"),
            tostring(IsDenseCaptureMode())))
        dhd(string.format("  caps: bosses=%s elites=%s self=%s team=%s eliteTier=%s",
            tostring(sv().recordCaptureBosses ~= false),
            tostring(sv().recordCaptureElites ~= false),
            tostring(sv().recordCaptureSelf == true),
            tostring(sv().recordCaptureTeam == true),
            tostring(MinEliteTier())))
        DumpProbe(ProbeReticle())
        return
    end
    if arg == "start" or arg == "on" then H.RecordStart(false)
    elseif arg == "stop" or arg == "off" then H.RecordStop(false)
    elseif arg == "arm" then H.RecordArm(false)
    elseif arg == "disarm" then H.RecordDisarm(false)
    else dhd("Usage: /hd record start|stop|status|probe  ·  /hd arm | disarm") end
end

-- Manual: force-tag current reticle as mini for next samples / stopadd name hint
function H.CmdTag(arg)
    CaptureReticleTarget()
    local tag = "reticleover"
    if not DoesUnitExist or not DoesUnitExist(tag) then
        dhd("Tag: aim at an enemy first.")
        return
    end
    local name = GetUnitName and GetUnitName(tag) or "elite"
    local unitId = GetUnitIdSafe(tag)
    local keyId = unitId or SanitizeKey(name)
    local info = H.record.unitInfoById[keyId]
    local kind = "mini"
    if arg and arg ~= "" then
        local a = arg:lower()
        if a == "boss" or a == "mini" or a == "stack" then kind = a end
    elseif info and info.kind then
        kind = info.kind
    end
    H.editName = "elite_" .. SanitizeKey(name)
    H.types[H.editName] = kind
    dhd(string.format("Tagged |cC0E0FF%s|r as %s (edit name=%s). Record samples it on reticle; or /hd stopadd.",
        name, kind, H.editName))
end
