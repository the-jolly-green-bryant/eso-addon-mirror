BGMeter = BGMeter or {}
local BGMeter = BGMeter

local Storage = {}

local BASE_DEPTH = 5
local INDENT = 4
local FLOAT_CHARS = 22
local HEAVY_KEYS = { "timeline", "killfeed", "objectives", "relics" }

local function key_chars(k)
    if type(k) == "number" then return #tostring(k) + 2 end
    return #tostring(k) + 4
end

local function scalar_chars(v)
    local t = type(v)
    if t == "number" then
        if v == math.floor(v) then return #tostring(v) end
        return FLOAT_CHARS
    elseif t == "string" then
        local extra = 0
        for _ in v:gmatch('[\\"\n]') do extra = extra + 1 end
        return #v + 2 + extra
    elseif t == "boolean" then
        return v and 4 or 5
    end
    return 3
end

local function walk(value, depth, omit)
    local pad = depth * INDENT
    local total = 0
    for k, v in pairs(value) do
        if not (omit and omit[k]) then
            if type(v) == "table" then
                total = total + pad + key_chars(k) + 3 + pad + 2 + walk(v, depth + 1) + pad + 3
            else
                total = total + pad + key_chars(k) + 3 + scalar_chars(v) + 2
            end
        end
    end
    return total
end

function Storage.estimate(value, omit)
    if type(value) ~= "table" then return scalar_chars(value) end
    local pad = BASE_DEPTH * INDENT
    return pad + 2 + walk(value, BASE_DEPTH + 1, omit) + pad + 2
end

local function count(t)
    local n = 0
    for _ in pairs(t or {}) do n = n + 1 end
    return n
end

local HEAVY_OMIT = {}
for _, k in ipairs(HEAVY_KEYS) do HEAVY_OMIT[k] = true end

local cache = { key = nil, report = nil }

local function cache_key(data)
    local matches = data.matches or {}
    local first = matches[1]
    local prefs = data.prefs or {}
    return table.concat({
        tostring(#matches), tostring(first and first.capturedAt or 0), tostring(prefs.max_history or 0),
        tostring(BGMeter.History.pinned_count()),
        tostring(count(data.faces)), tostring(data.ledger and data.ledger.streak or 0),
    }, "|")
end

function Storage.report()
    local data = BGMeter.zenimax.savedvars.get()
    if not data then return nil end
    local key = cache_key(data)
    if cache.key == key and cache.report then return cache.report end

    local History, Faces = BGMeter.History, BGMeter.Faces
    local matches = data.matches or {}
    local n = #matches
    local heavyKeep = History.HEAVY_KEEP or 10
    local cap = (data.prefs and data.prefs.max_history) or 50

    local pinCap = History.PIN_CAP or 10
    local heavySum, heavyN, lightSum, lightN, strippedSum, pinnedN = 0, 0, 0, 0, 0, 0
    local geoSum, geoN = 0, 0
    for i = 1, n do
        local m = matches[i]
        local bytes = Storage.estimate(m)
        if m.pinned then pinnedN = pinnedN + 1 end
        local tl = m.timeline
        if tl and tl.pt then
            geoSum = geoSum + Storage.estimate({ pt = tl.pt, pos = tl.pos, pin = tl.pin, mt = tl.mt, mx = tl.mx, my = tl.my })
                + (m.map and Storage.estimate(m.map) or 0)
            geoN = geoN + 1
        end
        if m.timeline then
            heavySum, heavyN = heavySum + bytes, heavyN + 1
            strippedSum = strippedSum + Storage.estimate(m, HEAVY_OMIT)
        else
            lightSum, lightN = lightSum + bytes, lightN + 1
        end
    end
    local usedMatches = heavySum + lightSum
    local heavyAvg = (heavyN > 0) and (heavySum / heavyN) or 0
    local lightAvg
    if lightN > 0 then lightAvg = lightSum / lightN
    elseif heavyN > 0 then lightAvg = strippedSum / heavyN
    else lightAvg = 0 end
    if heavyAvg == 0 then heavyAvg = lightAvg end
    local heavySlots = math.min(cap, heavyKeep)
    local projectedMatches = heavyAvg * (heavySlots + pinCap) + lightAvg * math.max(0, cap - heavySlots)
    if projectedMatches < usedMatches then projectedMatches = usedMatches end

    local faces = data.faces or {}
    local facesN = count(faces)
    local facesCap = Faces.CAP or 1500
    local usedFaces = (facesN > 0) and Storage.estimate(faces) or 0
    local projectedFaces = (facesN > 0) and (usedFaces / facesN * facesCap) or 0
    if projectedFaces < usedFaces then projectedFaces = usedFaces end

    local usedLedger = data.ledger and Storage.estimate(data.ledger) or 0
    local geoAvg = (geoN > 0) and (geoSum / geoN) or 0
    local projectedGeo = geoAvg * (heavyKeep + pinCap)
    if projectedGeo < geoSum then projectedGeo = geoSum end

    local report = {
        matches = { used = usedMatches, cap = projectedMatches, count = n, capCount = cap,
                    heavy = heavyN, heavyAvg = heavyAvg, lightAvg = lightAvg, pinned = pinnedN, pinCap = pinCap },
        faces   = { used = usedFaces, cap = projectedFaces, count = facesN, capCount = facesCap },
        ledger  = { used = usedLedger },
        map     = { used = geoSum, cap = projectedGeo, count = geoN },
        total   = Storage.estimate(data),
    }
    cache.key, cache.report = key, report
    return report
end

function Storage.invalidate()
    cache.key, cache.report = nil, nil
end

BGMeter.Storage = Storage
