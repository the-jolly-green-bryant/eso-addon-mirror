--=====================================================================
-- Holodeck_Record.lua — arm / record / sample (v0.0.10)
-- Preferences live in LAM (Holodeck_Settings). Slash = session actions.
-- States: off → armed → running → (auto) save take
--=====================================================================

local H = Holodeck
if not H then return end

H.record = H.record or {
    state = "off",       -- "off" | "armed" | "running"
    startMs = 0,
    samples = {},        -- array of { t, units = { [key] = {x,z,name,kind} } }
    lastSampleMs = 0,
    tickName = "Holodeck_RecordTick",
    tickRunning = false,
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
    -- Difficulty present is a weak signal for instanced content
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

-- ============================= Sampling ===============================
local function RawToLocal(rx, rz)
    if not H.origin then return nil end
    return (rx - H.origin.x) / 100, (rz - H.origin.z) / 100
end

local function EnsureOriginFromPlayerIfNeeded()
    if H.origin then return true end
    local _, x, y, z = GetUnitRawWorldPosition("player")
    if not x then return false end
    H.origin = { x = x, y = y, z = z }
    dhd("Record: no plant — origin set at player (relative take). Prefer /hd plant at a landmark.")
    if type(H.EnsureOriginMarker) == "function" then
        pcall(H.EnsureOriginMarker)
    end
    return true
end

local function CollectUnitsNow()
    local units = {}
    local function add(tag, kind, nameHint)
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
        local key = tag
        if tag == "player" then key = "player" end
        units[key] = {
            x = math.floor(lx * 100 + 0.5) / 100,
            z = math.floor(lz * 100 + 0.5) / 100,
            name = name,
            kind = kind or "stack",
        }
    end

    -- Training default: bosses only. Team walks the holodeck themselves (not a ghost replay).
    local capBoss = sv().recordCaptureBosses ~= false
    local capSelf = sv().recordCaptureSelf == true
    local capTeam = sv().recordCaptureTeam == true

    if capSelf then
        add("player", "stack", "player")
    end
    if capTeam and type(GetGroupSize) == "function" then
        local n = GetGroupSize() or 0
        for i = 1, n do
            local tag = GetGroupUnitTagByIndex and GetGroupUnitTagByIndex(i)
            if tag and tag ~= "player" then
                add(tag, "stack", nil)
            end
        end
    end
    if capBoss then
        for i = 1, 8 do
            add("boss" .. i, "boss", "boss" .. i)
        end
    end
    return units
end

local function PushSample()
    if H.record.state ~= "running" then return end
    if not EnsureOriginFromPlayerIfNeeded() then return end
    local now = GetFrameTimeMilliseconds() or 0
    local interval = tonumber(sv().recordIntervalMs) or 400
    if interval < 150 then interval = 150 end
    if H.record.lastSampleMs > 0 and (now - H.record.lastSampleMs) < interval then
        return
    end
    H.record.lastSampleMs = now
    local t = (now - (H.record.startMs or now)) / 1000
    if t < 0 then t = 0 end
    local units = CollectUnitsNow()
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

-- Convert samples → Holodeck.stops for house playback
local function ApplyRecordingToSandbox()
    local samples = H.record.samples
    if not samples or #samples == 0 then
        dhd("Record: no samples to apply.")
        return false
    end

    -- Build per-unit tracks
    local tracks = {}
    local kinds = {}
    for _, frame in ipairs(samples) do
        local t = frame.t or 0
        for key, u in pairs(frame.units or {}) do
            if not tracks[key] then tracks[key] = {} end
            kinds[key] = u.kind or "stack"
            local list = tracks[key]
            local last = list[#list]
            -- skip duplicates within 0.15m
            if last and last.x and u.x then
                local dx, dz = (u.x - last.x), (u.z - last.z)
                if (dx * dx + dz * dz) < 0.02 and math.abs((last.t or 0) - t) < 0.35 then
                    last.t = t -- extend time only
                else
                    list[#list + 1] = { t = t, x = u.x, z = u.z, hold = 0, visible = true }
                end
            else
                list[#list + 1] = { t = t, x = u.x, z = u.z, hold = 0, visible = true }
            end
        end
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
    return true
end

local function AutosaveTake()
    if not sv().recordAutoSave then return end
    if not H.record.samples or #H.record.samples == 0 then return end
    -- Assume caller already applied samples to sandbox when needed
    local stamp = GetTimeStamp and GetTimeStamp() or GetFrameTimeMilliseconds()
    local name = string.format("rec_%s", tostring(stamp))
    if H.savedVars then
        if not H.savedVars.saves then H.savedVars.saves = {} end
        if type(H.SerializeStops) == "function" then
            local data = H.SerializeStops()
            data.name = name
            H.savedVars.saves[name] = data
            H.workingName = name
            dhd("Record autosaved as |cC0E0FF" .. name .. "|r  ·  /hd open " .. name)
        else
            dhd("Record in sandbox — /hd save <name> to keep (SerializeStops missing).")
        end
    end
end

-- ============================= Public commands ==========================
function H.RecordArm(silent)
    H.record.state = "armed"
    if not silent then
        dhd("Record |cC0E0FFARMED|r — will start per settings (manual / combat / boss). /hd record start to force.")
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
    if H.record.state ~= "armed" and H.record.state ~= "off" then
        H.record.state = "armed"
    end
    -- Allow start from off (manual force)
    H.record.state = "running"
    H.record.startMs = GetFrameTimeMilliseconds() or 0
    H.record.lastSampleMs = 0
    H.record.samples = {}
    EnsureOriginFromPlayerIfNeeded()
    StartRecordTick()
    PushSample()
    if not silent then
        local bits = {}
        if sv().recordCaptureBosses ~= false then bits[#bits + 1] = "bosses" end
        if sv().recordCaptureSelf then bits[#bits + 1] = "self" end
        if sv().recordCaptureTeam then bits[#bits + 1] = "team" end
        if #bits == 0 then bits[1] = "nothing (enable capture targets in /hdsettings)" end
        dhd("Record |cFF5555RUNNING|r — sampling: " .. table.concat(bits, "+") .. ". /hd record stop to finish.")
    end
    if type(H.RefreshUI) == "function" then pcall(H.RefreshUI) end
end

function H.RecordStop(silent)
    if H.record.state ~= "running" then
        if not silent then dhd("Not recording.") end
        return
    end
    StopRecordTick()
    PushSample() -- final
    local n = #(H.record.samples or {})
    H.record.state = "armed" -- stay armed for next pull if still in trial
    if not silent then
        dhd(string.format("Record stopped — %d samples.", n))
    end
    if n > 0 then
        ApplyRecordingToSandbox()
        if sv().recordAutoSave then
            AutosaveTake()
        else
            dhd("Path loaded into sandbox. /hd play once  ·  /hd save <name> to keep.")
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
        dhd("Auto-arm: record ARMED in instance. Start: " .. tostring(sv().recordStartMode or "boss"))
    end
end

local function MaybeAutoDisarmOutside()
    if not sv().autoArmInInstances then return end
    if IsGroupInstanceZone() then return end
    if H.record.state == "running" then
        H.RecordStop(true)
    end
    if H.record.state == "armed" then
        H.RecordDisarm(true)
    end
end

local function OnCombatState(_, inCombat)
    local mode = sv().recordStartMode or "boss" -- manual | combat | boss
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
    EVENT_MANAGER:RegisterForEvent(H.name .. "_RecAct", EVENT_PLAYER_ACTIVATED, function()
        zo_callLater(function()
            MaybeAutoDisarmOutside()
            MaybeAutoArm()
            if type(H.RefreshUI) == "function" then pcall(H.RefreshUI) end
        end, 500)
    end)
    -- Initial arm check
    zo_callLater(function()
        MaybeAutoArm()
    end, 1000)
end

-- Slash helpers used from main map
function H.CmdArm() H.RecordArm(false) end
function H.CmdDisarm() H.RecordDisarm(false) end
function H.CmdRecord(arg)
    arg = (arg or ""):lower():match("^%s*(%S*)") or ""
    if arg == "" or arg == "status" then
        dhd(string.format("Record state=%s  samples=%d  startMode=%s  autoArm=%s",
            RecordStateLabel(),
            #(H.record.samples or {}),
            tostring(sv().recordStartMode or "boss"),
            tostring(sv().autoArmInInstances == true)))
        return
    end
    if arg == "start" or arg == "on" then
        H.RecordStart(false)
    elseif arg == "stop" or arg == "off" then
        H.RecordStop(false)
    elseif arg == "arm" then
        H.RecordArm(false)
    elseif arg == "disarm" then
        H.RecordDisarm(false)
    else
        dhd("Usage: /hd record start|stop|status   or  /hd arm | /hd disarm")
    end
end
