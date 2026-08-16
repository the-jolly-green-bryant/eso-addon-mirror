--=====================================================================
-- Holodeck_Record.lua — arm / record / sample (v0.0.25)
--
-- Bosses = boss1–8 bar only (never reticle-as-boss).
-- Elites = reticle soft-aim → mini/elite tracks.
-- NPC positions: map-relative fallback when Raw world pos is frozen/zero
-- (ESO often only updates world XYZ for player/group; reticle map still moves).
-- Collapse uses path fidelity so continuous reticle samples keep movement.
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

-- ---------------------------------------------------------------------------
-- World XYZ (centimeters)
--
-- Player/group: GetUnitRawWorldPosition is reliable and updates every frame.
-- Boss / reticle / NPCs: ZOS often returns 0, a spawn anchor, or a frozen first
-- pose (QA: elites stuck at origin while player path has many ticks). Map
-- normalized coords (GetMapPlayerPosition) still update for reticle NPCs.
-- Strategy:
--   1) Read Raw (+ World fallback).
--   2) Self-calibrate map→meters from the player's own movement.
--   3) For non-player tags, prefer map-relative world when Raw is missing,
--      equals player, near-zero, or frozen while the map pos is moving.
-- ---------------------------------------------------------------------------
local function UnpackWorldPos(ok, a, b, c, d)
    if not ok then return nil, nil, nil end
    -- Normal: zoneIndex, worldX, worldY, worldZ
    if type(b) == "number" and type(d) == "number" then
        return b, c, d
    end
    -- Rare: x, y, z (no zone)
    if type(a) == "number" and type(c) == "number" and d == nil then
        return a, b, c
    end
    return nil, nil, nil
end

local function ReadRawWorld(unitTag)
    if type(GetUnitRawWorldPosition) == "function" then
        local wx, wy, wz = UnpackWorldPos(pcall(GetUnitRawWorldPosition, unitTag))
        if wx then return wx, wy, wz end
    end
    if type(GetUnitWorldPosition) == "function" then
        local wx, wy, wz = UnpackWorldPos(pcall(GetUnitWorldPosition, unitTag))
        if wx then return wx, wy, wz end
    end
    return nil, nil, nil
end

local function ReadMapXZ(unitTag)
    if type(GetMapPlayerPosition) ~= "function" then return nil, nil end
    local ok, mx, my = pcall(GetMapPlayerPosition, unitTag)
    if not ok then return nil, nil end
    if type(mx) ~= "number" or type(my) ~= "number" then return nil, nil end
    -- (0,0) is almost always "no position" for NPCs on the current map
    if mx == 0 and my == 0 then return nil, nil end
    return mx, my
end

local function Dist2(ax, az, bx, bz)
    local dx, dz = (ax or 0) - (bx or 0), (az or 0) - (bz or 0)
    return dx * dx + dz * dz
end

-- Player walk calibrates meters-per-map-unit (full 0..1 map span).
local function UpdateMapScaleFromPlayer(px, pz)
    local mx, my = ReadMapXZ("player")
    if not mx or not px then return end
    local prev = H.record._mapCal
    if prev and prev.mx and prev.wx then
        local md = math.sqrt(Dist2(mx, my, prev.mx, prev.my))
        local wd = math.sqrt(Dist2(px, pz, prev.wx, prev.wz)) / 100 -- meters
        if md > 0.00005 and wd > 0.4 then
            local s = wd / md
            -- Sanity: dungeon maps ~ 50–800 m across; overland larger
            if s > 20 and s < 20000 then
                local old = H.record.mapScaleM
                if old and old > 0 then
                    H.record.mapScaleM = old * 0.65 + s * 0.35
                else
                    H.record.mapScaleM = s
                end
            end
        end
    end
    H.record._mapCal = { mx = mx, my = my, wx = px, wz = pz }
end

local function MapRelativeWorld(unitTag, px, py, pz)
    local pmx, pmy = ReadMapXZ("player")
    local tmx, tmy = ReadMapXZ(unitTag)
    if not pmx or not tmx or not px then return nil, nil, nil end
    local scale = H.record.mapScaleM
    if not scale or scale <= 0 then
        -- Uncalibrated: dungeon-ish default (~200 m map). Better after player walks.
        scale = 200
    end
    local wx = px + (tmx - pmx) * scale * 100
    local wz = pz + (tmy - pmy) * scale * 100
    return wx, py or 0, wz
end

local function IsPlayerLikeTag(unitTag)
    if unitTag == "player" then return true end
    if type(IsUnitPlayer) == "function" then
        local ok, p = pcall(IsUnitPlayer, unitTag)
        if ok and p then return true end
    end
    if type(IsUnitGrouped) == "function" then
        local ok, g = pcall(IsUnitGrouped, unitTag)
        if ok and g then return true end
    end
    return false
end

local function GetUnitWorldXYZ(unitTag)
    if not unitTag then return nil, nil, nil end

    local rx, ry, rz = ReadRawWorld(unitTag)

    -- Player / group: always trust Raw/World (updates every frame).
    if IsPlayerLikeTag(unitTag) then
        if rx then return rx, ry, rz end
        return nil, nil, nil
    end

    local px, py, pz = ReadRawWorld("player")
    if px then UpdateMapScaleFromPlayer(px, pz) end

    local mapWx, mapWy, mapWz = MapRelativeWorld(unitTag, px, py, pz)

    -- Track raw freeze vs map motion (diagnostics + stuck flag)
    H.record._lastRaw = H.record._lastRaw or {}
    H.record._lastMap = H.record._lastMap or {}
    local tmx, tmy = ReadMapXZ(unitTag)
    local mapMoved = false
    if tmx then
        local prevM = H.record._lastMap[unitTag]
        if prevM and Dist2(tmx, tmy, prevM.mx, prevM.my) > (0.00002 * 0.00002) then
            mapMoved = true
        end
        H.record._lastMap[unitTag] = { mx = tmx, my = tmy }
    end
    local rawStuck = false
    if rx then
        local prevR = H.record._lastRaw[unitTag]
        if prevR and Dist2(rx, rz, prevR.x, prevR.z) < 1 and mapMoved then
            rawStuck = true
            H.record._rawStuckTags = H.record._rawStuckTags or {}
            H.record._rawStuckTags[unitTag] = true
        end
        H.record._lastRaw[unitTag] = { x = rx, z = rz }
    end
    -- Once Raw freezes for a tag this take, keep preferring map for that tag
    if H.record._rawStuckTags and H.record._rawStuckTags[unitTag] then
        rawStuck = true
    end

    -- Raw "looks real"?
    local rawOk = false
    if rx and rz and type(rx) == "number" and type(rz) == "number" then
        local nearZero = (math.abs(rx) < 1 and math.abs(rz) < 1)
        local sameAsPlayer = px and Dist2(rx, rz, px, pz) < (50 * 50) -- <0.5 m
        -- Frozen at record origin while player walked away (classic QA elite@0,0)
        local sameAsOrigin = false
        if H.record.origin and H.record.origin.x then
            sameAsOrigin = Dist2(rx, rz, H.record.origin.x, H.record.origin.z) < (50 * 50)
            if sameAsOrigin and px and Dist2(px, pz, H.record.origin.x, H.record.origin.z) > (200 * 200) then
                sameAsOrigin = true -- player left origin; raw still there → bad
            else
                sameAsOrigin = false
            end
        end
        rawOk = (not nearZero) and (not sameAsPlayer) and (not sameAsOrigin) and (not rawStuck)
    end

    -- Prefer map-relative for NPCs whenever we have a calibrated scale (or Raw is bad).
    -- Map coords update for reticle NPCs; Raw often freezes on spawn/first pose.
    local calibrated = H.record.mapScaleM and H.record.mapScaleM > 0
    if mapWx and (calibrated or not rawOk or rawStuck) then
        return mapWx, mapWy, mapWz
    end
    if rawOk then
        return rx, ry, rz
    end
    if mapWx then
        return mapWx, mapWy, mapWz
    end
    if rx then return rx, ry, rz end
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
    -- Companions / pets (QA: Zerith-var captured as "elite")
    if type(IsUnitCompanion) == "function" then
        local ok, c = pcall(IsUnitCompanion, unitTag)
        if ok and c then return false end
    end
    if type(IsUnitFriendlyFollower) == "function" then
        local ok, c = pcall(IsUnitFriendlyFollower, unitTag)
        if ok and c then return false end
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
    local rawX, _, rawZ = ReadRawWorld(tag)
    local px, _, pz = ReadRawWorld("player")
    if px then UpdateMapScaleFromPlayer(px, pz) end
    local mapX, _, mapZ = MapRelativeWorld(tag, px, nil, pz)
    local x, _, z = GetUnitWorldXYZ(tag)
    if x then
        p.hasPos = true
        p.x, p.z = x, z
    end
    p.rawX, p.rawZ = rawX, rawZ
    p.mapX, p.mapZ = mapX, mapZ
    p.mapScale = H.record.mapScaleM
    if rawX and mapX then
        local d = math.sqrt(Dist2(rawX, rawZ, mapX, mapZ)) / 100
        p.rawMapDeltaM = d
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
    if not p.hostile then
        p.reason = "reticle not hostile (friend/dead/neutral?)"
    elseif not p.hasPos then
        p.reason = "hostile but no world position from API"
    elseif allowElite then
        p.reason = string.format("OK — would capture as elite/mini (rank=%s hp=%.0f)",
            tostring(p.rank), p.maxHealth or 0)
    elseif p.capBoss and p.bossBar then
        p.reason = "OK — boss bar (boss1–8); reticle not used for bosses"
    elseif p.capElite and not allowElite then
        p.reason = string.format(
            "elite tier blocked (tier=%s rank=%s hp=%.0f) — raise filter or Any hostile",
            tostring(p.eliteTier), tostring(p.rank), p.maxHealth or 0)
    elseif not p.capElite then
        p.reason = "elites OFF — reticle ignored (bosses still need boss bar)"
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
    if p.hasPos and p.x then
        local lx, lz = nil, nil
        if H.origin and H.origin.x then
            lx = (p.x - H.origin.x) / 100
            lz = (p.z - H.origin.z) / 100
        end
        dhd(string.format("  world xz=%.0f,%.0f  local=%.1f,%.1f  scale=%s",
            p.x or 0, p.z or 0, lx or 0, lz or 0,
            p.mapScale and string.format("%.0fm", p.mapScale) or "uncalibrated"))
    end
    if p.rawX and p.mapX and p.rawMapDeltaM and p.rawMapDeltaM > 0.5 then
        dhd(string.format("  raw vs map-rel differ by %.1fm (using best for path)", p.rawMapDeltaM))
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

-- Recording origin is ALWAYS the player in the current zone at record start.
-- Never reuse a house plant origin (that produced ~900m garbage coords in QA).
local function BindRecordOriginToPlayer(force)
    H.record = H.record or {}
    if not force and H.record.origin and H.record.origin.x then
        H.origin = H.record.origin
        return true
    end
    if sv().recordRequirePlant and not force and not (H.record.origin and H.record.origin.x) then
        -- require plant only blocks when we have no record origin yet
        if not H.origin then
            dhd("Record blocked: |cC0E0FF/hd plant|r first (require plant is ON in settings).")
            return false
        end
    end
    local x, y, z = GetUnitWorldXYZ("player")
    if not x then return false end
    H.record.origin = { x = x, y = y, z = z }
    H.origin = H.record.origin
    return true
end

local function EnsureOriginFromPlayerIfNeeded()
    return BindRecordOriginToPlayer(false)
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

    -- Boss bar units ONLY (traditional boss1–8). Never reticle-as-boss.
    if capBoss then
        for i = 1, 8 do
            local tag = "boss" .. i
            local n = (GetUnitName and GetUnitName(tag)) or tag
            add(tag, "boss", n, tag)
        end
    end

    -- Reticle elites / pack minis (soft aim). Always mini/elite kind — never boss.
    -- Keep crosshair on the unit to sample movement (no off-reticle follow API).
    if capElite and DoesUnitExist and DoesUnitExist("reticleover") then
        ProbeReticle()
        if IsHostileNpc("reticleover") then
            local keyId, info = CaptureReticleTarget()
            local name = (info and info.name) or (GetUnitName and GetUnitName("reticleover")) or "enemy"
            local unitId = GetUnitIdSafe("reticleover") or keyId
            local onBossBar = unitId and H.record.activeBossIds[unitId]
            -- Name match: unitId APIs often fail on reticle → same boss was dual-tracked
            if not onBossBar and name and name ~= "" and GetUnitName then
                local nlow = string.lower(name)
                for i = 1, 8 do
                    local bn = GetUnitName("boss" .. i)
                    if bn and bn ~= "" and string.lower(bn) == nlow then
                        onBossBar = true
                        break
                    end
                end
            end
            if not onBossBar and info and EliteAllowedByTier(info) then
                local kind = info.kind or "mini"
                if kind == "boss" then kind = "mini" end -- reticle path never "boss"
                local idPart = unitId or SanitizeKey(name)
                local ekey = "elite_" .. SanitizeKey(name) .. "_" .. tostring(idPart)
                if add("reticleover", kind, name, ekey) then
                    if not H.record.primaryTarget then H.record.primaryTarget = name end
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

    -- Always calibrate map scale from player motion (even before any NPC is tagged)
    local px, _, pz = ReadRawWorld("player")
    if px then UpdateMapScaleFromPlayer(px, pz) end

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
-- mode:
--   "dense" = self/team review (tight)
--   "path"  = recorded boss/elite movement (default for record) — keep the path
--   "lean"  = sparse (manual-style); NOT used for live reticle capture anymore
--
-- BUG FIX: old lean thresh 1.25m collapsed continuous walks into 1 start pose + hold.
-- Path mode uses distance from last *keyframe* (not last raw) with a low thresh so
-- slow boss walks survive. Always keep first + last pose.
local function CollapseTrack(points, mode)
    if not points or #points == 0 then return {} end
    if #points == 1 then
        local p = points[1]
        return { { t = p.t, x = p.x, z = p.z, hold = 0, visible = true, snap = false } }
    end

    local dense = (mode == true or mode == "dense")
    local path = (mode == "path") or (not dense and mode ~= "lean")
    -- path (boss/elite): 0.25m — slow tank walks survive
    -- dense: 0.20m  ·  lean: 1.25m (manual packs only)
    local moveThresh = dense and 0.20 or (path and 0.25 or 1.25)
    local snapDist = dense and 12 or (path and 10 or 8)

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
            -- still / jitter: extend hold, stay at prev pose
            local leave = (prev.t or 0) + (prev.hold or 0)
            if (p.t or 0) > leave then
                prev.hold = math.floor(((p.t or 0) - (prev.t or 0)) * 100 + 0.5) / 100
            end
        else
            local isSnap = dist >= snapDist and dt <= 0.75
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

    -- Always keep final sample pose if last keyframe isn't there yet
    local lastIn = points[#points]
    local lastOut = out[#out]
    if lastIn and lastOut then
        local dx = (lastIn.x or 0) - (lastOut.x or 0)
        local dz = (lastIn.z or 0) - (lastOut.z or 0)
        local dist = math.sqrt(dx * dx + dz * dz)
        if dist >= moveThresh * 0.5 or math.abs((lastIn.t or 0) - (lastOut.t or 0) - (lastOut.hold or 0)) > 0.5 then
            if dist >= 0.05 then
                out[#out + 1] = {
                    t = lastIn.t, x = lastIn.x, z = lastIn.z,
                    hold = 0, visible = true, snap = false,
                }
            elseif (lastIn.t or 0) > (lastOut.t or 0) then
                lastOut.hold = math.floor(((lastIn.t or 0) - (lastOut.t or 0)) * 100 + 0.5) / 100
            end
        end
    end
    return out
end

local function RawTrackSpan(pts)
    if not pts or #pts == 0 then return 0, 0, 0 end
    local minX, maxX = pts[1].x or 0, pts[1].x or 0
    local minZ, maxZ = pts[1].z or 0, pts[1].z or 0
    local uniq = 1
    local lastX, lastZ = pts[1].x, pts[1].z
    for i = 2, #pts do
        local x, z = pts[i].x or 0, pts[i].z or 0
        if x < minX then minX = x end
        if x > maxX then maxX = x end
        if z < minZ then minZ = z end
        if z > maxZ then maxZ = z end
        local d = math.sqrt((x - (lastX or 0)) ^ 2 + (z - (lastZ or 0)) ^ 2)
        if d >= 0.15 then
            uniq = uniq + 1
            lastX, lastZ = x, z
        end
    end
    local span = math.sqrt((maxX - minX) ^ 2 + (maxZ - minZ) ^ 2)
    return span, uniq, #pts
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
    -- Boss/elite-only takes: "path" fidelity (not old lean 1.25m collapse)
    local collapseMode = dense and "dense" or "path"
    -- Gather raw points per key
    local raw = {}
    local kinds = {}
    local names = {}
    local rawCounts = {}
    for _, frame in ipairs(samples) do
        local t = frame.t or 0
        for key, u in pairs(frame.units or {}) do
            if not raw[key] then raw[key] = {} end
            kinds[key] = u.kind or "stack"
            names[key] = u.name or key
            raw[key][#raw[key] + 1] = { t = t, x = u.x, z = u.z }
            rawCounts[key] = (rawCounts[key] or 0) + 1
        end
    end

    local tracks = {}
    local kfTotal = 0
    for key, pts in pairs(raw) do
        tracks[key] = CollapseTrack(pts, collapseMode)
        kfTotal = kfTotal + #(tracks[key] or {})
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
    dhd(string.format("Record applied: %d entities · %d keyframes (%s collapse) · %d raw frames",
        entCount, kfTotal, collapseMode, #samples))
    if H.record.mapScaleM then
        dhd(string.format("  map scale ~%.0fm/map (walk to calibrate; used for boss/elite pos)",
            H.record.mapScaleM))
    end
    -- Per-entity raw span: distinguishes stuck API vs truly stationary unit
    for key, pts in pairs(raw) do
        local tr = tracks[key]
        local span, uniq, n = RawTrackSpan(pts)
        local nk = tr and #tr or 0
        dhd(string.format("  %s: raw=%d uniq~%d span=%.1fm → %d keys",
            tostring(names[key] or key), n, uniq, span, nk))
        if n >= 5 and span < 0.5 and (kinds[key] == "boss" or kinds[key] == "mini") then
            dhd("    → almost no movement in samples (unit still, or aim was lost). Walk around while soft-aiming a *moving* mob to test paths.")
        elseif n >= 5 and span >= 1.0 and nk <= 2 then
            dhd("    → span ok but collapse flattened — report this (bug)")
        end
    end
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
            local nFlat = tonumber(data.nFlat) or (data.flat and #data.flat) or 0
            local nEnt = tonumber(data.nEnt) or 0
            dhd("Record autosaved:")
            dhd("  title: " .. (data.displayName or name))
            dhd("  id:    |cC0E0FF" .. name .. "|r")
            dhd(string.format("  data:  %d entities · %d flat keyframes", nEnt, nFlat))
            if nFlat == 0 then
                dhd("|cFF5555WARNING|r save has 0 keyframes — /hd save backup1 manually")
            end
            dhd("  open:  |cC0E0FF/hd open last|r  or  |cC0E0FF/hd open 1|r")
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
    -- Fresh map-scale calibration + stuck-raw trackers each take
    H.record.mapScaleM = nil
    H.record._mapCal = nil
    H.record._lastRaw = {}
    H.record._lastMap = {}
    H.record._rawStuckTags = {}
    -- Critical: origin = player HERE (trial), not leftover house plant
    if not BindRecordOriginToPlayer(true) then
        H.record.state = "armed"
        dhd("Record: could not read player position.")
        return
    end
    dhd("Record origin bound to player (this zone) — house plant ignored for capture.")
    -- Seed map scale from a few steps of player movement once available
    local px, _, pz = ReadRawWorld("player")
    if px then UpdateMapScaleFromPlayer(px, pz) end
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
        dhd("Soft-aim: keep crosshair on a unit to sample its path (look away = no new samples).")
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
