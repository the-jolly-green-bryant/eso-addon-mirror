--=====================================================================
-- Holodeck_Recipes.lua — per-trial overlay (own 200-local chunk).
-- Keep ghosts in fights/*.lua. Furniture, shouts, and HP clocks live here.
--=====================================================================

Holodeck = Holodeck or {}
Holodeck.Recipes = Holodeck.Recipes or {}

local FLY_R_M = 12
local FLY_MIN_SEC = 2.5
local FLY_MERGE_SEC = 4

local function blob(fight)
    return string.lower(tostring(fight.id or "") .. " " .. tostring(fight.boss or "")
        .. " " .. tostring(fight.name or "") .. " " .. tostring(fight.trial or ""))
end

local function findRecipe(fight)
    if type(fight) ~= "table" then return nil end
    local id = fight.id
    if id and Holodeck.Recipes[id] then return Holodeck.Recipes[id] end
    local s = blob(fight)
    for _, rec in pairs(Holodeck.Recipes) do
        if type(rec) == "table" and type(rec.match) == "string" then
            if s:find(rec.match, 1, true) then return rec end
        end
    end
    return nil
end

local function addCentroid(fight)
    local ents = fight.entities
    if type(ents) ~= "table" then return 0, 0 end
    local sx, sz, n = 0, 0, 0
    local i = 1
    while i <= #ents do
        local e = ents[i]
        local lab = string.lower(tostring((e and e.label) or "") .. " " .. tostring((e and e.id) or ""))
        local kind = e and e.kind
        if e and (kind == "trash" or kind == "mini") and not lab:find("atronach", 1, true) then
            local tr = e.track
            if type(tr) == "table" and tr[1] and tr[1].x ~= nil then
                sx = sx + (tr[1].x or 0)
                sz = sz + (tr[1].z or 0)
                n = n + 1
            end
        end
        i = i + 1
    end
    if n < 1 then return 0, 0 end
    return sx / n, sz / n
end

local function bossTrack(fight)
    local ents = fight.entities
    if type(ents) ~= "table" then return nil end
    local i = 1
    while i <= #ents do
        local e = ents[i]
        if e and e.kind == "boss" and type(e.track) == "table" then
            return e.track
        end
        i = i + 1
    end
    return nil
end

-- Boss path far from the add blob = fly / untargetable. HP freezes there.
local function flyWindows(fight)
    local tr = bossTrack(fight)
    if type(tr) ~= "table" or #tr < 2 then return {} end
    local cx, cz = addCentroid(fight)
    local wins, cur = {}, nil
    local i = 1
    while i <= #tr do
        local k = tr[i]
        local flying = false
        if k and k.x ~= nil then
            local r = math.sqrt((k.x - cx) * (k.x - cx) + ((k.z or 0) - cz) * ((k.z or 0) - cz))
            flying = r >= FLY_R_M
        end
        local t = (k and k.t) or 0
        if flying then
            if not cur then
                cur = { t0 = t, t1 = t }
            else
                cur.t1 = t
            end
        elseif cur then
            -- Extend to the landing sample so a single far keyframe still counts.
            cur.t1 = t
            wins[#wins + 1] = cur
            cur = nil
        end
        i = i + 1
    end
    if cur then wins[#wins + 1] = cur end
    local merged = {}
    i = 1
    while i <= #wins do
        local w = wins[i]
        local last = merged[#merged]
        if last and (w.t0 - last.t1) <= FLY_MERGE_SEC then
            last.t1 = w.t1
        else
            merged[#merged + 1] = { t0 = w.t0, t1 = w.t1 }
        end
        i = i + 1
    end
    local out = {}
    i = 1
    while i <= #merged do
        local w = merged[i]
        if (w.t1 - w.t0) >= FLY_MIN_SEC then
            out[#out + 1] = w
        end
        i = i + 1
    end
    return out
end

local function groundPark(fight)
    local tr = bossTrack(fight)
    local cx, cz = addCentroid(fight)
    if type(tr) ~= "table" then return { x = cx, z = cz } end
    local sx, sz, n = 0, 0, 0
    local i = 1
    while i <= #tr do
        local k = tr[i]
        if k and k.x ~= nil then
            local dx = k.x - cx
            local dz = (k.z or 0) - cz
            local r = math.sqrt(dx * dx + dz * dz)
            if r < FLY_R_M then
                sx = sx + k.x
                sz = sz + (k.z or 0)
                n = n + 1
            end
        end
        i = i + 1
    end
    if n < 1 then return { x = cx, z = cz } end
    return { x = sx / n, z = sz / n }
end

-- When the dragon is not in a fly window, pin him on the platform (log XYZ wanders).
function Holodeck.GroundBossAt(fight, tSec)
    if type(fight) ~= "table" then return nil end
    local park = fight._groundPark
    if type(park) ~= "table" then return nil end
    tSec = tonumber(tSec) or 0
    local wins = fight._flyWindows
    if type(wins) == "table" then
        local i = 1
        while i <= #wins do
            local w = wins[i]
            if tSec >= (w.t0 or 0) and tSec < (w.t1 or 0) then
                return nil
            end
            i = i + 1
        end
    end
    return park.x, park.z
end

local function flyBefore(wins, tSec)
    local g = 0
    local i = 1
    while i <= #wins do
        local w = wins[i]
        local a, b = w.t0 or 0, w.t1 or 0
        if b <= tSec then
            g = g + (b - a)
        elseif a < tSec then
            g = g + (tSec - a)
        end
        i = i + 1
    end
    return g
end

function Holodeck.RemainHp(fight, tSec)
    if type(fight) ~= "table" then return nil end
    local wins = fight._flyWindows
    if type(wins) ~= "table" or #wins < 1 then return nil end
    local dur = tonumber(fight.durationSec) or 0
    if dur < 1 then dur = 1 end
    tSec = tonumber(tSec) or 0
    if tSec < 0 then tSec = 0 end
    if tSec > dur then tSec = dur end
    local flyTot = flyBefore(wins, dur)
    local ground = dur - flyTot
    if ground < 1 then ground = 1 end
    local g = tSec - flyBefore(wins, tSec)
    if g < 0 then g = 0 end
    local remain = 100 * (1 - (g / ground))
    if remain < 0 then remain = 0 end
    if remain > 100 then remain = 100 end
    return remain
end

local function timeAtPct(fight, pct)
    local dur = tonumber(fight.durationSec) or 0
    if dur < 1 then return nil end
    local t, prev, step = 0, 100, 0.25
    while t <= dur do
        local r = Holodeck.RemainHp(fight, t)
        if r == nil then
            r = 100 * (1 - (t / dur))
        end
        if r <= pct and prev > pct then return t end
        prev = r
        t = t + step
    end
    return nil
end

local function alkoshWaves(fight)
    local ents = fight.entities
    if type(ents) ~= "table" then return {} end
    local spans = {}
    local i = 1
    while i <= #ents do
        local e = ents[i]
        local lab = string.lower(tostring((e and e.label) or "") .. " " .. tostring((e and e.id) or ""))
        local kind = e and e.kind
        local isAdd = (kind == "trash" or kind == "mini")
            and (lab:find("alkosh", 1, true) or lab:find("fate", 1, true)
                or lab:find("fury", 1, true) or lab:find("ruin", 1, true)
                or lab:find("will", 1, true))
            and not lab:find("atronach", 1, true)
        if isAdd and type(e.track) == "table" then
            local tOn, tOff = nil, nil
            local j = 1
            while j <= #e.track do
                local kf = e.track[j]
                local vis = kf and kf.visible ~= false and not kf.dead and kf.x ~= nil
                if vis then
                    if not tOn then tOn = kf.t or 0 end
                    tOff = kf.t or 0
                elseif tOn then
                    spans[#spans + 1] = { t0 = tOn, t1 = (kf and kf.t) or tOff }
                    tOn = nil
                end
                j = j + 1
            end
            if tOn then spans[#spans + 1] = { t0 = tOn, t1 = (tOff or tOn) + 4 } end
        end
        i = i + 1
    end
    if #spans < 1 then return {} end
    table.sort(spans, function(a, b) return a.t0 < b.t0 end)
    local waves = {}
    i = 1
    while i <= #spans do
        local sp = spans[i]
        local w = waves[#waves]
        if not w or sp.t0 > (w.t1 + 8) then
            waves[#waves + 1] = { t0 = sp.t0, t1 = sp.t1 }
        elseif sp.t1 > w.t1 then
            w.t1 = sp.t1
        end
        i = i + 1
    end
    return waves
end

local function applyNahviintaas(fight, rec)
    fight._flyWindows = flyWindows(fight)
    fight._groundPark = groundPark(fight)
    local cx, cz = addCentroid(fight)
    fight._arena = { x = cx, z = cz }
    local pads = {}
    -- Four vigil statues on a diamond around the add blob (NW matches the hide huddle).
    local statue = {
        { -5.2, 5.2 }, { 5.2, 5.2 }, { 5.2, -5.2 }, { -5.2, -5.2 },
    }
    local i = 1
    while i <= 4 do
        pads[#pads + 1] = {
            id = "_statue_" .. i,
            kind = "safe",
            x = cx + statue[i][1],
            z = cz + statue[i][2],
            slot = 9,
            label = "S" .. i,
        }
        i = i + 1
    end
    -- Three floor breaches, shallow arc on the hide side (+Z).
    local portal = { { -4.0, 3.2 }, { 0, 4.4 }, { 4.0, 3.2 } }
    i = 1
    while i <= 3 do
        pads[#pads + 1] = {
            id = "_breach_" .. i,
            kind = "portal",
            x = cx + portal[i][1],
            z = cz + portal[i][2],
            slot = 1,
            label = tostring(i),
        }
        i = i + 1
    end
    fight._pads = pads

    local cues = {}
    local portalTs = {}
    local hpCues = rec.hpCues or {}
    i = 1
    while i <= #hpCues do
        local hc = hpCues[i]
        local t = timeAtPct(fight, hc.pct)
        if t then
            cues[#cues + 1] = {
                t = t, dur = hc.dur or 8, kind = hc.kind, text = hc.text,
                slot = hc.slot, pct = hc.pct,
            }
            if hc.kind == "portal" then
                portalTs[#portalTs + 1] = t
            end
        end
        i = i + 1
    end

    local wins = fight._flyWindows
    i = 1
    while i <= #wins do
        local w = wins[i]
        local durW = (w.t1 or 0) - (w.t0 or 0)
        -- Opener (100%, in the air) freezes HP but is not a FLY! call.
        -- Short far-keyframe blips freeze HP without a shout.
        local opener = (i == 1 and (w.t0 or 0) < 25)
        if not opener and durW >= 10 then
            cues[#cues + 1] = {
                t = w.t0, dur = 8, kind = "fly", text = "FLY!",
            }
        end
        local tLand = w.t1 or 0
        if tLand > (w.t0 or 0) + 1 then
            cues[#cues + 1] = {
                t = tLand, dur = 4, kind = "land", text = "LAND!",
            }
        end
        i = i + 1
    end

    local waves = alkoshWaves(fight)
    i = 1
    while i <= #waves do
        local tHide = (waves[i].t1 or 0) + 2
        cues[#cues + 1] = {
            t = tHide, dur = 6, kind = "hide", text = "HIDE!", slot = 9,
        }
        i = i + 1
    end

    -- Portal after hide, not on top of it.
    i = 1
    while i <= #cues do
        local c = cues[i]
        if c and c.kind == "portal" then
            local j = 1
            while j <= #cues do
                local h = cues[j]
                if h and h.kind == "hide" then
                    local hideEnd = (h.t or 0) + (h.dur or 6)
                    local pt = c.t or 0
                    if (h.t or 0) <= pt + 1 and hideEnd + 2 > pt then
                        if hideEnd + 3 > pt then
                            c.t = hideEnd + 3
                        end
                    end
                end
                j = j + 1
            end
        end
        i = i + 1
    end
    portalTs = {}
    i = 1
    while i <= #cues do
        if cues[i] and cues[i].kind == "portal" then
            portalTs[#portalTs + 1] = cues[i].t
        end
        i = i + 1
    end

    table.sort(cues, function(a, b) return (a.t or 0) < (b.t or 0) end)
    fight._cues = cues

    -- Boss-only: tag the trainer on each portal window. Player packs: three DPS.
    if type(fight._tags) ~= "table" then fight._tags = {} end
    local dps = {}
    local ents = fight.entities
    if type(ents) == "table" then
        i = 1
        while i <= #ents do
            local e = ents[i]
            if e and (e.kind == "dps") and e.id then
                dps[#dps + 1] = e.id
            end
            i = i + 1
        end
    end
    i = 1
    while i <= #portalTs do
        local t0 = portalTs[i]
        local t1 = t0 + 90
        if #dps >= 1 then
            local ids = {}
            local n = #dps
            if n > 3 then n = 3 end
            local p = 1
            while p <= n do
                ids[#ids + 1] = dps[p]
                p = p + 1
            end
            fight._tags[#fight._tags + 1] = { t0 = t0, t1 = t1, ids = ids }
        else
            fight._tags[#fight._tags + 1] = { t0 = t0, t1 = t1, ids = { "_you" }, you = true }
        end
        i = i + 1
    end
end

Holodeck.Recipes.nahviintaas = {
    match = "nahviintaas",
    hpClock = "grounded-minus-fly",
    hpCues = {
        { pct = 90, kind = "portal", text = "PORTAL DOWN!", dur = 12, slot = 1 },
        { pct = 70, kind = "portal", text = "PORTAL DOWN!", dur = 12, slot = 1 },
        { pct = 50, kind = "portal", text = "PORTAL DOWN!", dur = 12, slot = 1 },
        { pct = 33, kind = "execute", text = "TAKE IT OUT!", dur = 6 },
    },
    apply = applyNahviintaas,
}

function Holodeck.ApplyRecipe(fight)
    if type(fight) ~= "table" then return end
    local rec = findRecipe(fight)
    if not rec then return end
    if type(rec.apply) == "function" then
        rec.apply(fight, rec)
    end
end

-- Same Holodeck pin art as trash/mini; tint + short plate distinguish families.
-- (ESO ability icons stretched blocky on world pins.)
local LOOK_GROUP = {
    fire  = { color = { 1.00, 0.42, 0.10 } },
    frost = { color = { 0.42, 0.82, 1.00 } },
    storm = { color = { 0.55, 0.72, 1.00 } },
}

local function lookOf(group, short, important, sizeM, color)
    local g = LOOK_GROUP[group] or {}
    return {
        color = color or g.color,
        short = short,
        important = important == true,
        sizeM = sizeM,
    }
end

-- Twins "Will of / Rage of" keep lunar/shadow tints; do not steal those names.
function Holodeck.LookupActorLook(label, id, kind)
    local s = string.lower(tostring(label or "") .. " " .. tostring(id or ""))
    if s == " " or s == "" then return nil end
    if s:find("will of", 1, true) or s:find("rage of", 1, true) then return nil end
    if s:find("flame atronach", 1, true) then
        return lookOf("fire", "Atro", true, 0.88)
    end
    if s:find("frost atronach", 1, true) then
        return lookOf("frost", "Atro", true, 0.88)
    end
    if s:find("storm atronach", 1, true) then
        return lookOf("storm", "Atro", true, 0.88)
    end
    if s:find("frost well", 1, true) then
        return lookOf("frost", "Well", true, 0.95)
    end
    if s:find("alkosh's fate", 1, true) or s:find("alkosh_s_fate", 1, true) then
        return {
            color = { 1.00, 0.82, 0.28 },
            short = "Fate",
            important = true,
            sizeM = 1.32,
        }
    end
    if s:find("alkosh's will", 1, true) or s:find("alkosh_s_will", 1, true) then
        return lookOf("storm", "Will", true, 1.22)
    end
    if s:find("ruin of alkosh", 1, true) then
        return lookOf("fire", "Ruin", true, 1.22)
    end
    if s:find("fury of alkosh", 1, true) then
        return lookOf("fire", "Fury", true, 1.22)
    end
    if s:find("eternal servant", 1, true) then
        return { color = { 1.00, 0.55, 0.18 }, short = "Servant", important = true, sizeM = 1.35 }
    end
    if s:find("vigil statue", 1, true) then
        return { color = { 0.72, 0.70, 0.62 }, short = "Statue", important = true, sizeM = 1.10 }
    end
    return nil
end
