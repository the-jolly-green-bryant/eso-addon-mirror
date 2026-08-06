--=====================================================================
-- Holodeck_Record.lua — arm / record / sample (v0.0.11)
--
-- Training packs = lean keyframes (boss / mini / elites), not video streams.
-- Dense samples only when capturing self/team (review mode).
-- Reticle + difficulty used to see non-boss elites (OC packs, etc.).
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

-- Returns classKey, holodeckKind, confidence
local function ClassifyEnemy(unitId, info)
    if unitId and H.record.activeBossIds[unitId] then
        return "BOSS", "boss", 1.0
    end
    if not info then return "UNKNOWN", "stack", 0.0 end

    local deadly = (type(MONSTER_DIFFICULTY_DEADLY) == "number") and MONSTER_DIFFICULTY_DEADLY or 3
    local hard = (type(MONSTER_DIFFICULTY_HARD) == "number") and MONSTER_DIFFICULTY_HARD or 2
    local normal = (type(MONSTER_DIFFICULTY_NORMAL) == "number") and MONSTER_DIFFICULTY_NORMAL or 1

    -- Name overrides (expand over time for known encounter minis)
    local nlow = string.lower(tostring(info.name or ""))
    if string.find(nlow, "lieutenant", 1, true) or string.find(nlow, "tormented deadraiser", 1, true) then
        return "MINIBOSS", "mini", 0.9
    end

    if info.difficulty == deadly then
        return "ELITE_OR_MINIBOSS", "mini", 0.75
    elseif info.difficulty == hard then
        return "LT_OR_ELITE", "mini", 0.60
    elseif info.difficulty == normal then
        return "MOB", "stack", 0.85
    end
    return "UNKNOWN", "stack", 0.0
end

local function CaptureReticleTarget()
    local unitTag = "reticleover"
    if not DoesUnitExist or not DoesUnitExist(unitTag) then return end
    if type(IsUnitAttackable) == "function" then
        local ok, att = pcall(IsUnitAttackable, unitTag)
        if ok and not att then return end
    end
    if type(IsUnitPlayer) == "function" and IsUnitPlayer(unitTag) then return end

    local unitId = GetUnitIdSafe(unitTag)
    local name = (GetUnitName and GetUnitName(unitTag)) or "enemy"
    local difficulty = GetUnitDifficultySafe(unitTag)
    local maxHealth = GetUnitMaxHealthSafe(unitTag)

    local keyId = unitId or (SanitizeKey(name) .. "_" .. tostring(difficulty or 0))
    H.record.unitInfoById[keyId] = {
        name = name,
        difficulty = difficulty,
        maxHealth = maxHealth or 0,
        lastSeenMs = GetFrameTimeMilliseconds() or 0,
    }

    local classKey, kind, conf = ClassifyEnemy(unitId, H.record.unitInfoById[keyId])
    H.record.unitInfoById[keyId].classKey = classKey
    H.record.unitInfoById[keyId].kind = kind
    H.record.unitInfoById[keyId].confidence = conf
    H.record.unitInfoById[keyId].unitTag = unitTag -- only valid while reticle on them
end

local function MinEliteTier()
    -- 0 = off, 1 = deadly only, 2 = hard+, 3 = normal+ (not recommended)
    return tonumber(sv().recordEliteTier) or 2
end

local function EliteTierAllowed(classKey)
    local tier = MinEliteTier()
    if tier <= 0 then return false end
    if classKey == "BOSS" or classKey == "MINIBOSS" or classKey == "ELITE_OR_MINIBOSS" then
        return tier >= 1
    end
    if classKey == "LT_OR_ELITE" then return tier >= 2 end
    if classKey == "MOB" then return tier >= 3 end
    return false
end

-- ============================= Sampling ===============================
local function RawToLocal(rx, rz)
    if not H.origin then return nil end
    return (rx - H.origin.x) / 100, (rz - H.origin.z) / 100
end

local function EnsureOriginFromPlayerIfNeeded()
    if H.origin then return true end
    if sv().recordRequirePlant then
        dhd("Record blocked: |cC0E0FF/hd plant|r first (require plant is ON in settings).")
        return false
    end
    local _, x, y, z = GetUnitRawWorldPosition("player")
    if not x then return false end
    H.origin = { x = x, y = y, z = z }
    dhd("Record: no plant — origin at player (relative take). Prefer /hd plant at a landmark.")
    if type(H.EnsureOriginMarker) == "function" then pcall(H.EnsureOriginMarker) end
    return true
end

local function CollectUnitsNow()
    local units = {}
    local function add(tag, kind, nameHint, keyOverride)
        if not DoesUnitExist or not DoesUnitExist(tag) then return end
        local _, x, _, z = GetUnitRawWorldPosition(tag)
        if not x then return end
        local lx, lz = RawToLocal(x, z)
        if not lx then return end
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
        if not H.record.primaryTarget and kind == "boss" then
            H.record.primaryTarget = name
        end
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
    if capBoss then
        for i = 1, 8 do
            add("boss" .. i, "boss", "boss" .. i)
        end
    end

    -- Non-boss elites: only while on reticle (ESO gives no stable tag after look-away)
    if capElite and DoesUnitExist and DoesUnitExist("reticleover") then
        CaptureReticleTarget()
        local unitId = GetUnitIdSafe("reticleover")
        local name = GetUnitName and GetUnitName("reticleover") or "enemy"
        local keyId = unitId or SanitizeKey(name)
        local info = H.record.unitInfoById[keyId]
        if info and EliteTierAllowed(info.classKey or "UNKNOWN") then
            local kind = info.kind or "mini"
            if info.classKey == "BOSS" then kind = "boss" end
            add("reticleover", kind, info.name, "elite_" .. SanitizeKey(info.name) .. "_" .. tostring(keyId))
            if not H.record.primaryTarget then H.record.primaryTarget = info.name end
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
            dhd("Record autosaved as |cC0E0FF" .. name .. "|r")
            dhd("  " .. (data.displayName or "") .. "  →  /hd open " .. name .. "  or  /hd open last")
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
            .. (IsDenseCaptureMode() and " (dense)" or " (lean keyframes)")
            .. ". Look at elites to capture them.")
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
        dhd("|cFF5555Empty take|r — nothing to play. Boss on bar? Reticle elites? Capture toggles?")
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
    if arg == "" or arg == "status" then
        dhd(string.format("Record state=%s frames=%d unitHits=%d startMode=%s dense=%s",
            RecordStateLabel(),
            #(H.record.samples or {}),
            CountUnitsInSamples(H.record.samples),
            tostring(sv().recordStartMode or "boss"),
            tostring(IsDenseCaptureMode())))
        return
    end
    if arg == "start" or arg == "on" then H.RecordStart(false)
    elseif arg == "stop" or arg == "off" then H.RecordStop(false)
    elseif arg == "arm" then H.RecordArm(false)
    elseif arg == "disarm" then H.RecordDisarm(false)
    else dhd("Usage: /hd record start|stop|status  ·  /hd arm | disarm") end
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
