BGMeter = BGMeter or {}
local BGMeter = BGMeter

local Geo = {}

local SAMPLE_NAME = "BGMeterGeoSample"
local SAMPLE_MS = 2000
local MAX_SAMPLES = 900
local MAX_EVENTS = 400
local MAX_OBJ = 8
local MAX_GROUP = 8

local API_NAMES = {
    "GetMapPlayerPosition", "GetUnitWorldPosition", "GetUnitRawWorldPosition",
    "GetObjectivePinInfo", "GetObjectiveSpawnPinInfo", "GetObjectiveAuraPinInfo",
    "GetMapNumTiles", "GetMapTileTexture", "GetMapNumTilesForMapId", "GetMapTileTextureForMapId",
    "GetCurrentMapId", "GetCurrentMapIndex", "GetCurrentMapZoneIndex", "GetMapName", "GetMapType", "GetMapContentType",
    "SetMapToPlayerLocation", "DoesCurrentMapMatchMapForPlayerLocation", "GetMapCustomMaxZoom",
    "GetPlayerActiveZoneId", "GetUnitZoneIndex", "GetZoneNameByIndex", "GetMapInfoById",
    "GetGroupSize", "GetGroupUnitTagByIndex", "IsUnitOnline", "IsUnitInGroupSupportRange",
    "ZO_WorldMap_IsWorldMapShowing", "WorldPositionToGuiRender3DPosition", "GetPlayerCameraHeading",
    "GetNumObjectives", "GetObjectiveIdsForIndex", "IsBattlegroundObjective", "GetObjectiveInfo",
}

local function g(name) return _G[name] end

local function safe(name, ...)
    local fn = g(name)
    if type(fn) ~= "function" then return nil end
    local ok, a, b, c, d, e = pcall(fn, ...)
    if not ok then return nil end
    return a, b, c, d, e
end

local function f3(v)
    if type(v) ~= "number" then return tostring(v) end
    return string.format("%.4f", v)
end

local function clean(s)
    if type(s) ~= "string" or s == "" then return nil end
    return (s:gsub("%^.*$", ""))
end

local function sv()
    local data = BGMeter.zenimax.savedvars.get()
    if not data then return nil end
    data.geo = data.geo or { on = false, samples = {}, events = {}, probes = {} }
    return data.geo
end

function Geo.enabled()
    local d = sv()
    return d ~= nil and d.on == true
end

function Geo.set_enabled(on)
    local d = sv()
    if not d then return end
    d.on = on and true or false
end

local function group_tags()
    local out = {}
    local n = safe("GetGroupSize") or 0
    for i = 1, math.min(n, MAX_GROUP) do
        local tag = safe("GetGroupUnitTagByIndex", i)
        if tag then out[#out + 1] = tag end
    end
    return out
end

local function objectives()
    local out = {}
    local n = safe("GetNumObjectives") or 0
    for i = 1, math.min(n, MAX_OBJ) do
        local keepId, objectiveId, ctx = safe("GetObjectiveIdsForIndex", i)
        if keepId and objectiveId then
            out[#out + 1] = { keepId = keepId, objectiveId = objectiveId, ctx = ctx }
        end
    end
    return out
end

function Geo.probe_lines(reason)
    local A = BGMeter.zenimax.api
    local L = {}
    local function add(fmt, ...)
        if select("#", ...) > 0 then L[#L + 1] = string.format(fmt, ...) else L[#L + 1] = fmt end
    end
    add("=== geo probe (%s)  ·  bgmeter %s  ·  api %s  ·  t=%s ===",
        tostring(reason or "manual"), BGMeter.Constants.VERSION, tostring(safe("GetAPIVersion")), tostring(safe("GetTimeStamp")))
    add("--- api presence ---")
    local present, missing = {}, {}
    for _, name in ipairs(API_NAMES) do
        if type(g(name)) == "function" then present[#present + 1] = name else missing[#missing + 1] = name end
    end
    add("present: %s", table.concat(present, " "))
    add("MISSING: %s", (#missing > 0) and table.concat(missing, " ") or "(none)")

    add("--- where ---")
    add("bg active=%s state=%s bgId=%s name=%s", tostring(safe("IsActiveWorldBattleground")), tostring(safe("GetCurrentBattlegroundState")),
        tostring(safe("GetCurrentBattlegroundId")), tostring(clean(safe("GetBattlegroundName", safe("GetCurrentBattlegroundId") or 0))))
    add("zone: activeZoneId=%s unitZone=%s zoneIndex=%s", tostring(safe("GetPlayerActiveZoneId")), tostring(clean(safe("GetUnitZone", "player"))), tostring(safe("GetUnitZoneIndex", "player")))
    add("world map showing=%s", tostring(safe("ZO_WorldMap_IsWorldMapShowing")))

    add("--- current map (before SetMapToPlayerLocation) ---")
    local function map_block()
        add("mapId=%s mapIndex=%s zoneIndex=%s name=%s type=%s content=%s matchesPlayer=%s",
            tostring(safe("GetCurrentMapId")), tostring(safe("GetCurrentMapIndex")), tostring(safe("GetCurrentMapZoneIndex")),
            tostring(clean(safe("GetMapName"))), tostring(safe("GetMapType")), tostring(safe("GetMapContentType")),
            tostring(safe("DoesCurrentMapMatchMapForPlayerLocation")))
        local nx, ny = safe("GetMapNumTiles")
        add("tiles: %s x %s  customMaxZoom=%s", tostring(nx), tostring(ny), tostring(safe("GetMapCustomMaxZoom")))
        local total = (tonumber(nx) or 0) * (tonumber(ny) or 0)
        for i = 1, math.min(total, 16) do
            add("  tile %d = %s", i, tostring(safe("GetMapTileTexture", i)))
        end
        local mapId = safe("GetCurrentMapId")
        if mapId then
            local mx, my = safe("GetMapNumTilesForMapId", mapId)
            add("byId: tiles %s x %s  tile1=%s", tostring(mx), tostring(my), tostring(safe("GetMapTileTextureForMapId", mapId, 1)))
        end
        local x, y, heading, inMap, symbolic = safe("GetMapPlayerPosition", "player")
        add("player map pos: x=%s y=%s heading=%s inCurrentMap=%s symbolic=%s", f3(x), f3(y), f3(heading), tostring(inMap), tostring(symbolic))
        local zoneId, wx, wy, wz = safe("GetUnitWorldPosition", "player")
        add("player world pos: zone=%s x=%s y=%s z=%s", tostring(zoneId), tostring(wx), tostring(wy), tostring(wz))
        local rz, rx, ry, rzz = safe("GetUnitRawWorldPosition", "player")
        add("player raw world pos: zone=%s x=%s y=%s z=%s", tostring(rz), tostring(rx), tostring(ry), tostring(rzz))
        add("camera heading=%s", f3(safe("GetPlayerCameraHeading")))
    end
    map_block()

    add("--- SetMapToPlayerLocation ---")
    local res = safe("SetMapToPlayerLocation")
    add("result=%s (MAP_CHANGED=%s FAILED=%s CURRENT_MAP_UNCHANGED=%s)", tostring(res),
        tostring(SET_MAP_RESULT_MAP_CHANGED), tostring(SET_MAP_RESULT_FAILED), tostring(SET_MAP_RESULT_CURRENT_MAP_UNCHANGED))
    add("--- current map (after) ---")
    map_block()

    add("--- group ---")
    local tags = group_tags()
    add("group size=%s tags=%d", tostring(safe("GetGroupSize")), #tags)
    for _, tag in ipairs(tags) do
        local x, y, heading, inMap = safe("GetMapPlayerPosition", tag)
        local zoneId, wx, wy, wz = safe("GetUnitWorldPosition", tag)
        add("  %s %s online=%s range=%s team=%s map=%s,%s inMap=%s world=%s,%s,%s (zone %s)",
            tag, tostring(clean(safe("GetUnitName", tag))), tostring(safe("IsUnitOnline", tag)), tostring(safe("IsUnitInGroupSupportRange", tag)),
            tostring(safe("GetUnitBattlegroundTeam", tag)), f3(x), f3(y), tostring(inMap), tostring(wx), tostring(wy), tostring(wz), tostring(zoneId))
    end

    add("--- objectives ---")
    local objs = objectives()
    add("numObjectives=%s (listed %d)", tostring(safe("GetNumObjectives")), #objs)
    for i, o in ipairs(objs) do
        local name, otype = safe("GetObjectiveInfo", o.keepId, o.objectiveId, o.ctx)
        local pinType, px, py, cont = safe("GetObjectivePinInfo", o.keepId, o.objectiveId, o.ctx)
        local sType, sx, sy = safe("GetObjectiveSpawnPinInfo", o.keepId, o.objectiveId, o.ctx)
        add("  [%d] %s type=%s bg=%s ids=%s:%s ctx=%s pin=%s at %s,%s continuous=%s spawnPin=%s at %s,%s",
            i, tostring(clean(name)), tostring(otype), tostring(safe("IsBattlegroundObjective", o.keepId, o.objectiveId, o.ctx)),
            tostring(o.keepId), tostring(o.objectiveId), tostring(o.ctx), tostring(pinType), f3(px), f3(py), tostring(cont),
            tostring(sType), f3(sx), f3(sy))
    end
    add("=== end probe ===")
    return L
end

local function q(v)
    if type(v) ~= "number" then return "-" end
    return tostring(math.floor(v * 10000 + 0.5))
end

local function sample_now()
    local d = sv()
    if not d or #d.samples >= MAX_SAMPLES then return end
    local A = BGMeter.zenimax.api
    local now = (type(A.now_ms) == "function") and A.now_ms() or 0
    local parts = {}
    parts[#parts + 1] = "t=" .. tostring(now)
    parts[#parts + 1] = "bg=" .. tostring(safe("GetCurrentBattlegroundState"))
    parts[#parts + 1] = "map=" .. tostring(safe("GetCurrentMapId")) .. "/" .. tostring(safe("DoesCurrentMapMatchMapForPlayerLocation"))
    parts[#parts + 1] = "wm=" .. tostring(safe("ZO_WorldMap_IsWorldMapShowing"))
    local x, y, h, inMap = safe("GetMapPlayerPosition", "player")
    parts[#parts + 1] = "p=" .. q(x) .. "," .. q(y) .. "," .. f3(h) .. "," .. tostring(inMap)
    local zoneId, wx, wy, wz = safe("GetUnitWorldPosition", "player")
    parts[#parts + 1] = "w=" .. tostring(wx) .. "," .. tostring(wy) .. "," .. tostring(wz)
    for i, tag in ipairs(group_tags()) do
        local gx, gy, _, gin = safe("GetMapPlayerPosition", tag)
        parts[#parts + 1] = string.format("g%d=%s:%s,%s,%s", i, tostring(clean(safe("GetUnitName", tag))), q(gx), q(gy), tostring(gin))
    end
    for i, o in ipairs(objectives()) do
        local pinType, px, py, cont = safe("GetObjectivePinInfo", o.keepId, o.objectiveId, o.ctx)
        parts[#parts + 1] = string.format("o%d=%s:%s,%s,%s", i, tostring(pinType), q(px), q(py), tostring(cont))
    end
    d.samples[#d.samples + 1] = table.concat(parts, " ")
end

function Geo.event(kind, detail)
    local d = sv()
    if not d or not d.on or #d.events >= MAX_EVENTS then return end
    local A = BGMeter.zenimax.api
    local now = (type(A.now_ms) == "function") and A.now_ms() or 0
    local x, y = safe("GetMapPlayerPosition", "player")
    d.events[#d.events + 1] = string.format("t=%d %s p=%s,%s %s", now, kind, q(x), q(y), tostring(detail or ""))
end

local running = false

function Geo.start(reason)
    local d = sv()
    if not d or not d.on or running then return end
    running = true
    local res = safe("SetMapToPlayerLocation")
    Geo.event("start", string.format("reason=%s setMap=%s", tostring(reason), tostring(res)))
    for _, l in ipairs(Geo.probe_lines("auto:" .. tostring(reason))) do d.probes[#d.probes + 1] = l end
    BGMeter.zenimax.events.register_update(SAMPLE_NAME, SAMPLE_MS, sample_now)
    sample_now()
end

function Geo.stop(reason)
    if not running then return end
    running = false
    BGMeter.zenimax.events.unregister_update(SAMPLE_NAME)
    Geo.event("stop", "reason=" .. tostring(reason))
end

function Geo.running() return running end

function Geo.clear()
    local d = sv()
    if not d then return end
    d.samples, d.events, d.probes = {}, {}, {}
end

local PAGE_CHARS = 24000

function Geo.dump_page(page)
    local all = Geo.dump_lines()
    local pages, cur, size = {}, {}, 0
    for _, l in ipairs(all) do
        if size + #l + 1 > PAGE_CHARS and #cur > 0 then
            pages[#pages + 1] = cur
            cur, size = {}, 0
        end
        cur[#cur + 1] = l
        size = size + #l + 1
    end
    if #cur > 0 then pages[#pages + 1] = cur end
    page = math.max(1, math.min(#pages, tonumber(page) or 1))
    local out = { string.format("=== geo dump page %d of %d  ·  next: /bgmeter geo dump %d ===", page, #pages, math.min(#pages, page + 1)) }
    for _, l in ipairs(pages[page] or {}) do out[#out + 1] = l end
    return out, #pages
end

function Geo.dump_lines()
    local d = sv()
    local L = {}
    if not d then return { "no saved variables" } end
    L[#L + 1] = string.format("=== geo trace  ·  on=%s running=%s  ·  %d probes lines, %d events, %d samples (%d ms apart) ===",
        tostring(d.on), tostring(running), #d.probes, #d.events, #d.samples, SAMPLE_MS)
    L[#L + 1] = "format: p=x,y,heading,inMap (x,y in 1/10000 of the map)  w=world x,y,z  gN=name:x,y,inMap  oN=pinType:x,y,continuous"
    L[#L + 1] = "--- probes ---"
    for _, l in ipairs(d.probes) do L[#L + 1] = l end
    L[#L + 1] = "--- events ---"
    for _, l in ipairs(d.events) do L[#L + 1] = l end
    L[#L + 1] = "--- samples ---"
    for _, l in ipairs(d.samples) do L[#L + 1] = l end
    L[#L + 1] = "=== end trace ==="
    return L
end

function Geo.on_kill(_, killedChar, killedDisp, killedTeam, killerChar, killerDisp, killerTeam, killType)
    if not running then return end
    Geo.event("kill", string.format("killer=%s(t%s) killed=%s(t%s) type=%s",
        tostring(clean(killerDisp or killerChar)), tostring(killerTeam), tostring(clean(killedDisp or killedChar)), tostring(killedTeam), tostring(killType)))
end

function Geo.on_bg_state(_, prev, cur)
    if not Geo.enabled() then return end
    local C = BGMeter.zenimax.constants
    Geo.event("bgstate", tostring(prev) .. "->" .. tostring(cur))
    if cur == C.BATTLEGROUND_STATE_FINISHED then
        Geo.stop("finished")
    elseif not running and cur ~= C.BATTLEGROUND_STATE_NONE then
        Geo.start("state " .. tostring(cur))
    end
end

function Geo.on_activated()
    if not Geo.enabled() then return end
    if safe("IsActiveWorldBattleground") then
        Geo.start("activated")
    else
        Geo.stop("left")
    end
end

function Geo.on_map_changed()
    if not running then return end
    Geo.event("mapchanged", string.format("mapId=%s matches=%s wm=%s", tostring(safe("GetCurrentMapId")),
        tostring(safe("DoesCurrentMapMatchMapForPlayerLocation")), tostring(safe("ZO_WorldMap_IsWorldMapShowing"))))
end

function Geo.init()
    if not BGMeter.Constants.dev_tools() then return end
    local E = BGMeter.zenimax.events
    local C = BGMeter.zenimax.constants
    E.register("BGMeterGeoState", C.EVENT_BATTLEGROUND_STATE_CHANGED, Geo.on_bg_state)
    E.register("BGMeterGeoAct", C.EVENT_PLAYER_ACTIVATED, Geo.on_activated)
    E.register("BGMeterGeoKill", C.EVENT_BATTLEGROUND_KILL, Geo.on_kill)
    if CALLBACK_MANAGER and type(CALLBACK_MANAGER.RegisterCallback) == "function" then
        pcall(function() CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", Geo.on_map_changed) end)
    end
    Geo.on_activated()
end

function Geo.command(arg)
    local Log = BGMeter.Log
    local E = BGMeter.UI.export
    arg = (arg or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if arg == "" then
        E.show_text(table.concat(Geo.probe_lines("manual"), "\n"))
    elseif arg == "on" then
        Geo.set_enabled(true)
        Log.say("geo recording ON: it starts by itself when a battleground begins (or now, if you are in one)")
        Geo.on_activated()
    elseif arg == "off" then
        Geo.set_enabled(false)
        Geo.stop("off")
        Log.say("geo recording OFF")
    elseif arg == "dump" or arg:find("^dump%s+%d+") then
        local lines = Geo.dump_page(tonumber(arg:match("(%d+)")) or 1)
        E.show_text(table.concat(lines, "\n"))
    elseif arg == "clear" then
        Geo.clear()
        Log.say("geo trace cleared")
    elseif arg == "mark" then
        Geo.event("mark", "manual")
        Log.say("geo mark noted at your position")
    else
        Log.say("geo: (probe now)  on  off  dump [page]  clear  mark")
    end
end

BGMeter.Geo = Geo
