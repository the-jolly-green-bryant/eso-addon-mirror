--=====================================================================
-- Holodeck.lua — v0.0.3
--
-- Versioning (DM2 suite): human Version = M.m.p
--   AddOnVersion (manifest) = major*10000 + minor*100 + patch
--   0.0.3 → 3
--
-- 0.0.3: author scratch (mark / t / dump); play scratch if marks exist;
--        fight library shell (/hd load|/hd list); house_demo as pack file
-- 0.0.2: multi-entity demo; phases; miniboss spawn/despawn
-- 0.0.1: world-space boss after origin
--
-- Console-first: slash only (no menu yet).
-- Patterns ported from DeadMarker2 world-space helpers.
--=====================================================================

local Holodeck = Holodeck or {}
Holodeck.name        = "DeadMarker_Holodeck"
Holodeck.displayName = "Holodeck"
-- AddOnVersion (manifest only) = major*10000 + minor*100 + patch  →  0.0.3 = 3
Holodeck.version     = "0.0.3"

-- Fight library (packs register via Holodeck.RegisterFight from fights/*.lua)
Holodeck.Fights = Holodeck.Fights or {}

function Holodeck.RegisterFight(fight)
    if type(fight) ~= "table" or not fight.id then return end
    Holodeck.Fights[fight.id] = fight
end

-- ============================= Texture defaults =========================
local TEX_BOSS     = "/esoui/art/icons/poi/poi_groupboss_complete.dds"       -- "castle"/keep silhouette
local TEX_MINIBOSS = "/esoui/art/icons/poi/poi_groupinstance_complete.dds"
local TEX_STACK    = "/esoui/art/icons/poi/poi_areaofinterest_complete.dds" -- POI "eye"/interest
local TEX_ORIGIN   = "/esoui/art/icons/mapkey/mapkey_wayshrine.dds"         -- anchor (was stacking under boss)
local TEX_FALLBACK = "/esoui/art/icons/poi/poi_areaofinterest_complete.dds"

-- Visual-only offset for origin pin so it does not sit under boss at local (0,0).
-- Math origin is still the player's feet when /hd origin was used.
local ORIGIN_PIN_LOCAL_X = -1.5
local ORIGIN_PIN_LOCAL_Z = -1.5

local KIND = {
    boss = {
        texture = TEX_BOSS, sizeM = 1.6,
        color = { 0.90, 0.18, 0.15 }, yOffM = 1.8,  -- red "castle"
    },
    miniboss = {
        texture = TEX_MINIBOSS, sizeM = 1.25,
        color = { 1.00, 0.55, 0.12 }, yOffM = 1.5,  -- amber
    },
    stack = {
        texture = TEX_STACK, sizeM = 1.0,
        color = { 0.40, 0.85, 1.00 }, yOffM = 0.6,  -- cyan POI "eye"
    },
    origin = {
        texture = TEX_ORIGIN, sizeM = 0.85,
        color = { 1.0, 1.0, 0.35 }, yOffM = 0.35,   -- yellow wayshrine = anchor (not boss)
    },
}

local DEFAULTS = {
    bossSizeM     = 1.6,
    minibossSizeM = 1.25,
    originSizeM   = 0.7,
    yOffsetM      = 1.8,
    opacity       = 1.0,
    debug         = false,
    lastDump      = nil,
    authorLabel   = "scratch",
}

-- Known id → kind hints for author marks
local ID_KIND = {
    boss = "boss",
    lieutenant = "miniboss",
    lt = "miniboss",
    mini = "miniboss",
    miniboss = "miniboss",
    stack = "stack",
    stack_main = "stack",
    main_stack = "stack",
}

-- ============================= State ====================================
Holodeck.savedVars    = nil
Holodeck.hudTop       = nil
Holodeck.fragment     = nil
Holodeck.idseq        = 0
Holodeck.wsPins       = {}
Holodeck.entities     = {}

Holodeck.origin       = nil
Holodeck.fight        = nil       -- active playback fight table
Holodeck.fightSource  = nil       -- "library" | "author"
Holodeck.loadedId     = nil       -- library id if any
Holodeck.playing      = false
Holodeck.playT        = 0
Holodeck._lastTickMs  = nil
Holodeck._lastPhaseAnnounced = nil

Holodeck._tickName    = "Holodeck_PinTick"
Holodeck._tickMs      = 50
Holodeck._tickRunning = false

-- Author scratch (NOT a library file — dump to paste offline)
Holodeck.author = {
    label = "scratch",
    t = 0,
    activeId = "boss",
    tracks = {},   -- id -> { {t,x,y,z,visible}, ... }
    kinds  = {},   -- id -> kind
}

-- ============================= Chat =====================================
local function dhd(msg)
    d(string.format("|c69c0ff[%s]|r %s", Holodeck.displayName, tostring(msg)))
end

local function dbug(msg)
    if Holodeck.savedVars and Holodeck.savedVars.debug then
        dhd("dbg: " .. tostring(msg))
    end
end

local function round2(n)
    n = n or 0
    return math.floor(n * 100 + 0.5) / 100
end

-- ============================= Safe UI ==================================
local function _SafeCreateTLW(name)
    if not name then return nil end
    local existing = _G[name]
    if existing then return existing end
    if not WINDOW_MANAGER or not WINDOW_MANAGER.CreateTopLevelWindow then return nil end
    local ok, tlw = pcall(function()
        return WINDOW_MANAGER:CreateTopLevelWindow(name)
    end)
    if ok and tlw then return tlw end
    return _G[name]
end

local function _SafeCreateControl(name, parent, controlType)
    if not name or not parent or not controlType then return nil end
    local existing = _G[name]
    if existing then return existing end
    if not WINDOW_MANAGER or not WINDOW_MANAGER.CreateControl then return nil end
    local ok, ctl = pcall(function()
        return WINDOW_MANAGER:CreateControl(name, parent, controlType)
    end)
    if ok and ctl then return ctl end
    return _G[name]
end

local function uniqueName(prefix)
    Holodeck.idseq = (Holodeck.idseq or 0) + 1
    return string.format("%s_%d_%d", prefix, Holodeck.idseq, GetFrameTimeMilliseconds() or 0)
end

local function _SetTextureSafe(ctrl, path, fallback)
    if not ctrl then return end
    ctrl:SetTexture(path or "")
    local loaded = (ctrl.GetTextureFileName and ctrl:GetTextureFileName()) or ""
    if not loaded or loaded == "" then
        ctrl:SetTexture(fallback or TEX_FALLBACK)
    end
end

-- ============================= HUD host =================================
local function ensureHUDTop()
    local ok, result = pcall(function()
        if Holodeck.hudTop then
            local w, h = GuiRoot:GetDimensions()
            Holodeck.hudTop:ClearAnchors()
            Holodeck.hudTop:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 0, 0)
            if w and h then Holodeck.hudTop:SetDimensions(w, h) end
            Holodeck.hudTop:SetHidden(false)
            return Holodeck.hudTop
        end
        local tlw = _SafeCreateTLW("HolodeckHUDTop")
        if not tlw then return nil end
        tlw:SetMouseEnabled(false)
        tlw:SetMovable(false)
        tlw:SetClampedToScreen(true)
        tlw:SetDrawLayer(DL_OVERLAY)
        tlw:SetDrawTier(DT_HIGH)
        tlw:SetDrawLevel(300000)
        if tlw.SetTopmost then tlw:SetTopmost(true) end
        local w, h = GuiRoot:GetDimensions()
        tlw:ClearAnchors()
        tlw:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 0, 0)
        if w and h then tlw:SetDimensions(w, h) end
        tlw:SetAlpha(1)
        tlw:SetHidden(false)
        Holodeck.hudTop = tlw
        pcall(function()
            if ZO_SimpleSceneFragment and HUD_SCENE and HUD_UI_SCENE then
                Holodeck.fragment = ZO_SimpleSceneFragment:New(tlw)
                HUD_SCENE:AddFragment(Holodeck.fragment)
                HUD_UI_SCENE:AddFragment(Holodeck.fragment)
            end
        end)
        return tlw
    end)
    if ok then return result end
    return Holodeck.hudTop
end

-- ============================= World-space ==============================
local function WS_GetRenderOriginWorld()
    local sx, sy, sz = GuiRender3DPositionToWorldPosition(0, 0, 0)
    if not sx then
        local _, px, py, pz = GetUnitRawWorldPosition("player")
        return px, py, pz
    end
    return sx, sy, sz
end

local function WS_SetAtRaw(ctl, x, y, z)
    if not ctl then return end
    local sx, sy, sz = WS_GetRenderOriginWorld()
    if not sx then
        ctl:ClearAnchors()
        ctl:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
        return
    end
    ctl:SetTransformOffset((x - sx) / 100, (y - sy) / 100, (z - sz) / 100)
    local fx, _, fz = GetCameraForward(SPACE_WORLD)
    if fx and fz then
        ctl:SetTransformRotation(0, -math.atan2(fx, fz), 0)
    end
    ctl:SetHidden(false)
end

local function _Billboard(ctl)
    if not ctl or ctl:IsHidden() then return end
    local fx, fy, fz = GetCameraForward(SPACE_WORLD)
    if not fx or not fz then return end
    ctl:SetTransformRotation(-math.asin(fy or 0), math.atan2(fx, fz) + math.pi, 0)
end

local function WS_CreateTexture(tag, sizeM, texturePath, color)
    local ok, result = pcall(function()
        local name = uniqueName("Holodeck_WS_" .. tostring(tag or "e"))
        local parent = ensureHUDTop()
        if not parent then return nil end
        local ctl = _SafeCreateControl(name, parent, CT_TEXTURE)
        if not ctl then return nil end
        ctl:SetHidden(true)
        if SPACE_WORLD and ctl.SetSpace then ctl:SetSpace(SPACE_WORLD) end
        if ctl.SetTransformNormalizedOriginPoint then
            ctl:SetTransformNormalizedOriginPoint(0.5, 0.5)
        end
        ctl:SetDrawLayer(DL_OVERLAY)
        ctl:SetDrawTier(DT_HIGH)
        ctl:SetDrawLevel(360000)
        _SetTextureSafe(ctl, texturePath or TEX_BOSS, TEX_FALLBACK)
        local r, g, b = 1, 1, 1
        if color then r, g, b = color[1] or 1, color[2] or 1, color[3] or 1 end
        local a = (Holodeck.savedVars and Holodeck.savedVars.opacity) or 1.0
        if ctl.SetDesaturation then ctl:SetDesaturation(0) end
        ctl:SetColor(r, g, b, a)
        ctl:SetAlpha(a)
        if ctl.SetScale then ctl:SetScale(1 / 100) end
        if ctl.SetTransformScale then ctl:SetTransformScale(sizeM or 1.2) end
        ctl:SetDimensions(128, 128)
        Holodeck.wsPins[name] = ctl
        return ctl
    end)
    if ok then return result end
    return nil
end

-- ============================= Place entities ===========================
local function LocalToWorld(lx, ly, lz)
    local o = Holodeck.origin
    if not o then return nil end
    return o.x + (lx or 0) * 100, o.y + (ly or 0) * 100, o.z + (lz or 0) * 100
end

local function PlayerLocalXZ()
    if not Holodeck.origin then return nil end
    local _, px, _, pz = GetUnitRawWorldPosition("player")
    if not px then return nil end
    local lx = (px - Holodeck.origin.x) / 100
    local lz = (pz - Holodeck.origin.z) / 100
    return round2(lx), round2(lz)
end

local function PlaceEntity(ent)
    if not ent or not ent.ctl or not Holodeck.origin then return end
    if ent.visible == false then
        ent.ctl:SetHidden(true)
        return
    end
    local def = KIND[ent.kind] or KIND.boss
    local yOff = ent.yOffM
    if yOff == nil then yOff = def.yOffM or 0 end
    local wx, wy, wz = LocalToWorld(ent.localX or 0, (ent.localY or 0) + yOff, ent.localZ or 0)
    if not wx then return end
    WS_SetAtRaw(ent.ctl, wx, wy, wz)
    _Billboard(ent.ctl)
end

local function SizeForKind(kind)
    local sv = Holodeck.savedVars or DEFAULTS
    local def = KIND[kind] or KIND.boss
    if kind == "boss" and sv.bossSizeM then return sv.bossSizeM end
    if kind == "miniboss" and sv.minibossSizeM then return sv.minibossSizeM end
    if kind == "origin" and sv.originSizeM then return sv.originSizeM end
    return def.sizeM
end

local function EnsureEntity(id, kind)
    local ent = Holodeck.entities[id]
    if ent and ent.ctl then
        if kind and ent.kind ~= kind then
            -- kind change: recolor/retexture
            ent.kind = kind
            local def = KIND[kind] or KIND.boss
            _SetTextureSafe(ent.ctl, def.texture, TEX_FALLBACK)
            local a = (Holodeck.savedVars and Holodeck.savedVars.opacity) or 1.0
            ent.ctl:SetColor(def.color[1], def.color[2], def.color[3], a)
            if ent.ctl.SetTransformScale then ent.ctl:SetTransformScale(SizeForKind(kind)) end
            ent.yOffM = def.yOffM
        end
        return ent
    end
    local def = KIND[kind] or KIND.boss
    local ctl = WS_CreateTexture(id, SizeForKind(kind), def.texture, def.color)
    if not ctl then
        dhd("Failed to create pin for " .. tostring(id))
        return nil
    end
    ent = {
        id = id, kind = kind, ctl = ctl,
        localX = 0, localY = 0, localZ = 0,
        yOffM = def.yOffM, visible = true, label = id,
    }
    Holodeck.entities[id] = ent
    return ent
end

local function DestroyFightPins()
    -- keep nothing except we rebuild; destroy all non-origin first then origin too on clear
    for id, ent in pairs(Holodeck.entities) do
        if ent.ctl then
            ent.ctl:SetHidden(true)
            local n = ent.ctl:GetName()
            if n then Holodeck.wsPins[n] = nil end
        end
        Holodeck.entities[id] = nil
    end
    Holodeck.entities = {}
end

local function EnsureOriginMarker()
    local originEnt = EnsureEntity("origin", "origin")
    if originEnt then
        -- Offset pin so it is not stacked under boss at fight (0,0). True zero = feet at /hd origin.
        originEnt.localX = ORIGIN_PIN_LOCAL_X
        originEnt.localY = 0
        originEnt.localZ = ORIGIN_PIN_LOCAL_Z
        originEnt.visible = true
        PlaceEntity(originEnt)
    end
end

-- ============================= Track sample =============================
local function SampleTrack(track, tSec)
    if not track or #track == 0 then return 0, 0, 0, false end

    local function kfXYZ(k) return k.x or 0, k.y or 0, k.z or 0 end

    local function visibleAt(t)
        local vis = true
        local firstT = track[1].t or 0
        if t < firstT then
            if track[1].visible ~= nil then return track[1].visible and true or false end
            return true
        end
        for i = 1, #track do
            local k = track[i]
            if (k.t or 0) <= t and k.visible ~= nil then
                vis = k.visible and true or false
            end
            if (k.t or 0) > t then break end
        end
        return vis
    end

    local t = tSec
    local vis = visibleAt(t)
    local pos = {}
    for i = 1, #track do
        local k = track[i]
        if k.x ~= nil or k.z ~= nil or k.y ~= nil then
            pos[#pos + 1] = k
        end
    end
    if #pos == 0 then return 0, 0, 0, vis end

    if t <= (pos[1].t or 0) then
        local x, y, z = kfXYZ(pos[1])
        return x, y, z, vis
    end
    if t >= (pos[#pos].t or 0) then
        local x, y, z = kfXYZ(pos[#pos])
        return x, y, z, vis
    end
    for i = 1, #pos - 1 do
        local a, b = pos[i], pos[i + 1]
        local ta, tb = a.t or 0, b.t or 0
        if t >= ta and t <= tb then
            local u = (tb > ta) and ((t - ta) / (tb - ta)) or 0
            local ax, ay, az = kfXYZ(a)
            local bx, by, bz = kfXYZ(b)
            return ax + (bx - ax) * u, ay + (by - ay) * u, az + (bz - az) * u, vis
        end
    end
    local x, y, z = kfXYZ(pos[#pos])
    return x, y, z, vis
end

local function PhaseAtTime(fight, t)
    if not fight or not fight.phases then return nil end
    local best = fight.phases[1]
    for i = 1, #fight.phases do
        local p = fight.phases[i]
        if (p.t or 0) <= t then best = p end
    end
    return best
end

local function ApplyTimeline(tSec, announcePhase)
    local fight = Holodeck.fight
    if not fight or not fight.entities then return end
    for i = 1, #fight.entities do
        local def = fight.entities[i]
        local ent = EnsureEntity(def.id, def.kind or "stack")
        if ent then
            ent.label = def.label or def.id
            local x, y, z, vis = SampleTrack(def.track, tSec)
            ent.localX, ent.localY, ent.localZ = x, y, z
            ent.visible = vis
            PlaceEntity(ent)
        end
    end
    EnsureOriginMarker()
    if announcePhase then
        local ph = PhaseAtTime(fight, tSec)
        if ph and ph.id ~= Holodeck._lastPhaseAnnounced then
            Holodeck._lastPhaseAnnounced = ph.id
            dhd(string.format("Phase %s — %s (t=%.1fs)", tostring(ph.id), tostring(ph.name or ""), tSec))
        end
    end
end

-- ============================= Author helpers ===========================
local function InferKind(id, explicit)
    if explicit and KIND[explicit] then return explicit end
    if ID_KIND[id] then return ID_KIND[id] end
    local low = string.lower(id or "")
    if string.find(low, "boss", 1, true) and not string.find(low, "mini", 1, true) then
        return "boss"
    end
    if string.find(low, "lt", 1, true) or string.find(low, "lieut", 1, true)
        or string.find(low, "mini", 1, true) then
        return "miniboss"
    end
    if string.find(low, "stack", 1, true) then return "stack" end
    return "stack"
end

local function AuthorHasMarks()
    for _, track in pairs(Holodeck.author.tracks) do
        if track and #track > 0 then return true end
    end
    return false
end

local function AuthorMarkCount()
    local n = 0
    for _, track in pairs(Holodeck.author.tracks) do
        n = n + #(track or {})
    end
    return n
end

local function ClearAuthor(quiet)
    Holodeck.author.tracks = {}
    Holodeck.author.kinds = {}
    Holodeck.author.t = 0
    Holodeck.author.activeId = "boss"
    if not quiet then dhd("Author scratch cleared.") end
end

local function AuthorDuration()
    local maxT = 0
    for _, track in pairs(Holodeck.author.tracks) do
        for i = 1, #(track or {}) do
            local tt = track[i].t or 0
            if tt > maxT then maxT = tt end
        end
    end
    if maxT < 1 then maxT = 1 end
    return maxT
end

--- Build a fight table from author scratch (for playback)
local function FightFromAuthor()
    local entities = {}
    for id, track in pairs(Holodeck.author.tracks) do
        if track and #track > 0 then
            local kind = Holodeck.author.kinds[id] or InferKind(id)
            -- deep-ish copy track
            local tr = {}
            for i = 1, #track do
                local k = track[i]
                tr[i] = {
                    t = k.t, x = k.x, y = k.y, z = k.z, visible = k.visible,
                }
            end
            entities[#entities + 1] = {
                id = id,
                kind = kind,
                label = id,
                track = tr,
            }
        end
    end
    table.sort(entities, function(a, b) return a.id < b.id end)
    return {
        id = "author_scratch",
        name = "Author: " .. (Holodeck.author.label or "scratch"),
        durationSec = AuthorDuration(),
        phases = {
            { id = 1, name = "Start", t = 0 },
            { id = 2, name = "Mid", t = AuthorDuration() * 0.5 },
            { id = 3, name = "End", t = AuthorDuration() },
        },
        entities = entities,
        _fromAuthor = true,
    }
end

local function SortTrack(track)
    table.sort(track, function(a, b) return (a.t or 0) < (b.t or 0) end)
end

local function AppendMark(id, kf)
    if not Holodeck.author.tracks[id] then Holodeck.author.tracks[id] = {} end
    local track = Holodeck.author.tracks[id]
    -- replace same t if exists
    local replaced = false
    for i = 1, #track do
        if math.abs((track[i].t or 0) - (kf.t or 0)) < 0.001 then
            track[i] = kf
            replaced = true
            break
        end
    end
    if not replaced then track[#track + 1] = kf end
    SortTrack(track)
end

local function FormatKeyframesLua(id, track, kind)
    local lines = {}
    lines[#lines + 1] = string.format("    -- entity %s (%s)", id, kind or "?")
    lines[#lines + 1] = string.format('    { id = "%s", kind = "%s", label = "%s", track = {', id, kind or "stack", id)
    for i = 1, #track do
        local k = track[i]
        local parts = { string.format("t = %s", tostring(round2(k.t or 0))) }
        if k.visible ~= nil then
            parts[#parts + 1] = "visible = " .. (k.visible and "true" or "false")
        end
        if k.x ~= nil then parts[#parts + 1] = string.format("x = %s", tostring(round2(k.x))) end
        if k.y ~= nil and k.y ~= 0 then parts[#parts + 1] = string.format("y = %s", tostring(round2(k.y))) end
        if k.z ~= nil then parts[#parts + 1] = string.format("z = %s", tostring(round2(k.z))) end
        lines[#lines + 1] = "      { " .. table.concat(parts, ", ") .. " },"
    end
    lines[#lines + 1] = "    } },"
    return lines
end

local function BuildDumpText()
    local label = Holodeck.author.label or "scratch"
    local out = {}
    out[#out + 1] = string.format("-- Holodeck author dump (%s) v%s", label, Holodeck.version)
    out[#out + 1] = "-- Coords: meters relative to origin. Paste into a fights/<name>.lua pack offline."
    out[#out + 1] = string.format("-- durationSec suggestion: %s", tostring(round2(AuthorDuration())))
    out[#out + 1] = "entities = {"
    local ids = {}
    for id in pairs(Holodeck.author.tracks) do ids[#ids + 1] = id end
    table.sort(ids)
    if #ids == 0 then
        out[#out + 1] = "  -- (no marks yet)"
    end
    for _, id in ipairs(ids) do
        local track = Holodeck.author.tracks[id]
        local kind = Holodeck.author.kinds[id] or InferKind(id)
        local lines = FormatKeyframesLua(id, track, kind)
        for i = 1, #lines do out[#out + 1] = lines[i] end
    end
    out[#out + 1] = "}"
    return table.concat(out, "\n")
end

-- ============================= Load fight ===============================
local function HideNonOriginEntities()
    for id, ent in pairs(Holodeck.entities) do
        if id ~= "origin" and ent.ctl then
            ent.ctl:SetHidden(true)
        end
    end
end

local function LoadFightTable(fight, source, resetTime)
    if not fight then return false end
    Holodeck.fight = fight
    Holodeck.fightSource = source or "library"
    Holodeck.loadedId = fight.id
    if resetTime then
        Holodeck.playT = 0
        Holodeck._lastPhaseAnnounced = nil
    end
    -- Drop pins that aren't in this fight (except origin)
    local keep = { origin = true }
    for i = 1, #(fight.entities or {}) do
        keep[fight.entities[i].id] = true
    end
    for id, ent in pairs(Holodeck.entities) do
        if not keep[id] and ent.ctl then
            ent.ctl:SetHidden(true)
        end
    end
    ApplyTimeline(Holodeck.playT or 0, false)
    EnsureOriginMarker()
    return true
end

local function LoadLibrary(id, resetTime)
    local fight = Holodeck.Fights[id]
    if not fight then
        dhd("Unknown pack: " .. tostring(id) .. "  — /hd list")
        return false
    end
    return LoadFightTable(fight, "library", resetTime ~= false)
end

local function UseAuthorForPlay(resetTime)
    if not AuthorHasMarks() then
        dhd("No author marks. /hd mark <id> first, or /hd load house_demo")
        return false
    end
    local fight = FightFromAuthor()
    return LoadFightTable(fight, "author", resetTime ~= false)
end

local function PreferPlaySource()
    -- If author has marks, play scratch; else loaded library / default demo
    if AuthorHasMarks() then
        UseAuthorForPlay(false)
        return "author"
    end
    if Holodeck.fight and not Holodeck.fight._fromAuthor then
        return "library"
    end
    if Holodeck.Fights["house_demo"] then
        LoadLibrary("house_demo", false)
        return "library"
    end
    return nil
end

-- ============================= Tick =====================================
local function _StopTick()
    if not Holodeck._tickRunning then return end
    EVENT_MANAGER:UnregisterForUpdate(Holodeck._tickName)
    Holodeck._tickRunning = false
    Holodeck._lastTickMs = nil
end

local function _StartTick()
    if Holodeck._tickRunning then return end
    Holodeck._lastTickMs = GetFrameTimeMilliseconds()
    EVENT_MANAGER:RegisterForUpdate(Holodeck._tickName, Holodeck._tickMs, function()
        local now = GetFrameTimeMilliseconds()
        local last = Holodeck._lastTickMs or now
        local dt = (now - last) / 1000
        if dt < 0 then dt = 0 end
        if dt > 0.25 then dt = 0.25 end
        Holodeck._lastTickMs = now

        if Holodeck.playing and Holodeck.origin and Holodeck.fight then
            local dur = Holodeck.fight.durationSec or 20
            if dur < 0.5 then dur = 0.5 end
            Holodeck.playT = (Holodeck.playT or 0) + dt
            -- Author clock follows play when playing author
            if Holodeck.fightSource == "author" then
                Holodeck.author.t = Holodeck.playT
            end
            if Holodeck.playT > dur then
                Holodeck.playT = Holodeck.playT - dur
                Holodeck._lastPhaseAnnounced = nil
            end
            ApplyTimeline(Holodeck.playT, true)
        else
            for _, ent in pairs(Holodeck.entities) do
                if ent.visible ~= false and ent.ctl then _Billboard(ent.ctl) end
            end
            if Holodeck.origin then EnsureOriginMarker() end
        end
    end)
    Holodeck._tickRunning = true
end

-- ============================= Commands =================================
local function CmdOrigin()
    local _, x, y, z = GetUnitRawWorldPosition("player")
    if not x then
        dhd("Could not read player position.")
        return
    end

    local hadMarks = AuthorHasMarks()
    Holodeck.origin = { x = x, y = y, z = z }
    Holodeck.playing = false
    Holodeck.playT = 0
    Holodeck._lastPhaseAnnounced = nil

    if hadMarks then
        ClearAuthor(true)
        dhd("New origin — author scratch cleared (old coords invalid).")
    end

    -- Default library pack for playback
    if Holodeck.Fights["house_demo"] then
        LoadLibrary("house_demo", true)
    end
    _StartTick()

    dhd("Origin set. Loaded |cC0E0FFhouse_demo|r (library). Author scratch empty.")
    dhd("|cFFEE55Yellow wayshrine|r = origin anchor (offset so it is not under the boss). True (0,0) = your feet.")
    dhd("|cFF5555Red castle|r = boss · |c66DDFFcyan eye/POI|r nearby = stack · amber later = lieutenant")
    dhd("Playback: /hd play · Author: /hd mark boss · /hd dump")
end

local function CmdPlay()
    if not Holodeck.origin then
        dhd("Set origin first: /hd origin")
        return
    end
    local src = PreferPlaySource()
    if not src then
        dhd("Nothing to play.")
        return
    end
    Holodeck.playing = true
    _StartTick()
    local name = Holodeck.fight and Holodeck.fight.name or "?"
    local dur = Holodeck.fight and Holodeck.fight.durationSec or 0
    dhd(string.format("Playing \"%s\" [source=%s] (%.1fs loop).", name, src, dur))
end

local function CmdPause()
    if not Holodeck.playing then
        dhd("Already paused.")
        return
    end
    Holodeck.playing = false
    dhd(string.format("Paused t=%.1fs. Author clock t=%.1fs", Holodeck.playT or 0, Holodeck.author.t or 0))
end

local function CmdRestart()
    if not Holodeck.origin then
        dhd("Set origin first: /hd origin")
        return
    end
    Holodeck.playT = 0
    Holodeck.author.t = 0
    Holodeck._lastPhaseAnnounced = nil
    if Holodeck.fight then ApplyTimeline(0, true) end
    dhd("Restarted t=0.")
end

local function CmdStop()
    Holodeck.playing = false
    Holodeck.playT = 0
    Holodeck.author.t = 0
    Holodeck._lastPhaseAnnounced = nil
    if Holodeck.fight then ApplyTimeline(0, false) end
    dhd("Stopped t=0.")
end

local function CmdPhase(arg)
    if not Holodeck.origin then
        dhd("Set origin first: /hd origin")
        return
    end
    if not Holodeck.fight then PreferPlaySource() end
    if not Holodeck.fight then return end

    local n = tonumber(arg)
    if not n then
        dhd("Usage: /hd phase <n>")
        for i = 1, #(Holodeck.fight.phases or {}) do
            local p = Holodeck.fight.phases[i]
            d(string.format("  %s — %s (t=%.1fs)", tostring(p.id or i), tostring(p.name), p.t or 0))
        end
        return
    end
    local target = nil
    for i = 1, #(Holodeck.fight.phases or {}) do
        local p = Holodeck.fight.phases[i]
        if p.id == n or i == n then target = p break end
    end
    if not target then
        dhd("Unknown phase " .. tostring(n))
        return
    end
    Holodeck.playT = target.t or 0
    if Holodeck.fightSource == "author" then Holodeck.author.t = Holodeck.playT end
    Holodeck._lastPhaseAnnounced = nil
    ApplyTimeline(Holodeck.playT, true)
end

local function CmdList()
    dhd("Fight library (shipped packs):")
    local ids = {}
    for id in pairs(Holodeck.Fights) do ids[#ids + 1] = id end
    table.sort(ids)
    if #ids == 0 then
        d("  (none registered)")
    end
    for _, id in ipairs(ids) do
        local f = Holodeck.Fights[id]
        local cur = (Holodeck.loadedId == id and Holodeck.fightSource == "library") and "  <- loaded" or ""
        d(string.format("  %s — %s%s", id, f.name or id, cur))
    end
    dhd(string.format("Author scratch: label=%s marks=%d  (not a library file)", Holodeck.author.label or "scratch", AuthorMarkCount()))
end

local function CmdLoad(arg)
    arg = (arg or ""):match("^%s*(.-)%s*$") or ""
    if arg == "" then
        dhd("Usage: /hd load <packId>   e.g. /hd load house_demo")
        CmdList()
        return
    end
    if not Holodeck.origin then
        dhd("Set origin first: /hd origin  (then /hd load " .. arg .. ")")
        return
    end
    Holodeck.playing = false
    if LoadLibrary(arg, true) then
        dhd(string.format("Loaded library pack \"%s\". /hd play to run. (Author scratch unchanged.)", arg))
    end
end

local function CmdDemo()
    if not Holodeck.origin then
        dhd("Set origin first: /hd origin")
        return
    end
    Holodeck.playing = false
    LoadLibrary("house_demo", true)
    dhd("Forced house_demo library pack.")
end

local function CmdMark(arg)
    if not Holodeck.origin then
        dhd("Set origin first: /hd origin")
        return
    end
    -- /hd mark [id] [kind]
    local id, kindArg = arg:match("^(%S+)%s*(%S*)")
    if not id or id == "" then
        id = Holodeck.author.activeId or "boss"
    end
    id = string.lower(id)
    Holodeck.author.activeId = id

    local kind = InferKind(id, (kindArg ~= "" and kindArg) or nil)
    Holodeck.author.kinds[id] = kind

    local lx, lz = PlayerLocalXZ()
    if not lx then
        dhd("Could not read player position.")
        return
    end
    local t = Holodeck.author.t or 0
    local kf = { t = t, x = lx, z = lz, visible = true }
    AppendMark(id, kf)

    local ent = EnsureEntity(id, kind)
    if ent then
        ent.localX, ent.localY, ent.localZ = lx, 0, lz
        ent.visible = true
        PlaceEntity(ent)
    end
    EnsureOriginMarker()
    _StartTick()

    dhd(string.format("Mark |cC0E0FF%s|r (%s) t=%.2f  x=%.2f z=%.2f  [scratch:%s]  marks=%d",
        id, kind, t, lx, lz, Holodeck.author.label or "scratch", AuthorMarkCount()))
    dhd("Scratch only — not written into a library file. /hd dump to export.")
end

local function CmdMarkHide(arg)
    if not Holodeck.origin then
        dhd("Set origin first: /hd origin")
        return
    end
    local id = (arg or ""):match("^(%S+)") or Holodeck.author.activeId or "boss"
    id = string.lower(id)
    Holodeck.author.activeId = id
    if not Holodeck.author.kinds[id] then
        Holodeck.author.kinds[id] = InferKind(id)
    end
    local t = Holodeck.author.t or 0
    AppendMark(id, { t = t, visible = false })
    local ent = Holodeck.entities[id]
    if ent then
        ent.visible = false
        PlaceEntity(ent)
    end
    dhd(string.format("Mark hide |cC0E0FF%s|r t=%.2f visible=false", id, t))
end

local function CmdT(arg)
    local n = tonumber(arg)
    if not n or n < 0 then
        dhd(string.format("Usage: /hd t <sec>   current author t=%.2f", Holodeck.author.t or 0))
        return
    end
    Holodeck.author.t = n
    Holodeck.playT = n
    if Holodeck.fight then
        Holodeck._lastPhaseAnnounced = nil
        ApplyTimeline(n, false)
    end
    dhd(string.format("Author/play t = %.2f", n))
end

local function CmdTPlus(arg)
    local n = tonumber(arg)
    if not n then
        dhd("Usage: /hd t+ <sec>   e.g. /hd t+ 5")
        return
    end
    CmdT(tostring((Holodeck.author.t or 0) + n))
end

local function CmdEnt(arg)
    local id = (arg or ""):match("^(%S+)")
    if not id then
        dhd("Active mark id: " .. tostring(Holodeck.author.activeId))
        dhd("Usage: /hd ent <id>   default id for /hd mark")
        return
    end
    Holodeck.author.activeId = string.lower(id)
    dhd("Active mark id = " .. Holodeck.author.activeId)
end

local function CmdPackName(arg)
    arg = (arg or ""):match("^%s*(.-)%s*$") or ""
    if arg == "" then
        dhd("Author label: " .. tostring(Holodeck.author.label) .. "  (cosmetic; not a file)")
        dhd("Usage: /hd packname my_ka_scratch")
        return
    end
    Holodeck.author.label = arg
    if Holodeck.savedVars then Holodeck.savedVars.authorLabel = arg end
    dhd("Author scratch label = " .. arg)
end

local function CmdDump(arg)
    arg = (arg or ""):lower()
    if not AuthorHasMarks() then
        dhd("No marks to dump. /hd mark <id> first.")
        if Holodeck.savedVars and Holodeck.savedVars.lastDump and arg == "show" then
            dhd("--- last saved dump ---")
            d(Holodeck.savedVars.lastDump)
        end
        return
    end
    local text = BuildDumpText()
    if Holodeck.savedVars then Holodeck.savedVars.lastDump = text end
    dhd("--- author dump (scratch → paste into fights/<name>.lua offline) ---")
    -- Chat has line limits; print line by line
    for line in string.gmatch(text .. "\n", "(.-)\n") do
        d(line)
    end
    dhd("--- end dump ---  also stored in SavedVars ( /hd dump show after reload )")
end

local function CmdDumpShow()
    if Holodeck.savedVars and Holodeck.savedVars.lastDump then
        dhd("--- last dump (SavedVars) ---")
        for line in string.gmatch(Holodeck.savedVars.lastDump .. "\n", "(.-)\n") do
            d(line)
        end
        dhd("--- end ---")
    else
        dhd("No saved dump.")
    end
end

local function CmdMarkList()
    dhd(string.format("Author scratch [%s] t=%.2f active=%s", Holodeck.author.label or "scratch", Holodeck.author.t or 0, Holodeck.author.activeId or "boss"))
    local ids = {}
    for id in pairs(Holodeck.author.tracks) do ids[#ids + 1] = id end
    table.sort(ids)
    if #ids == 0 then
        d("  (empty)")
        return
    end
    for _, id in ipairs(ids) do
        local tr = Holodeck.author.tracks[id]
        local kind = Holodeck.author.kinds[id] or InferKind(id)
        local lastT = (#tr > 0) and (tr[#tr].t or 0) or 0
        d(string.format("  %s (%s)  keys=%d  last t=%.2f", id, kind, #tr, lastT))
    end
end

local function CmdMarkClear()
    ClearAuthor(false)
    -- If we were playing author, fall back to library
    if Holodeck.fightSource == "author" and Holodeck.origin then
        Holodeck.playing = false
        if Holodeck.Fights["house_demo"] then
            LoadLibrary("house_demo", true)
            dhd("Playback back on house_demo.")
        end
    end
end

local function CmdClear()
    Holodeck.playing = false
    Holodeck.playT = 0
    Holodeck.origin = nil
    Holodeck.fight = nil
    Holodeck.fightSource = nil
    Holodeck.loadedId = nil
    Holodeck._lastPhaseAnnounced = nil
    ClearAuthor(true)
    _StopTick()
    DestroyFightPins()
    dhd("Cleared origin, pins, and author scratch.")
end

local function CmdSize(arg)
    local n = tonumber(arg)
    if not n or n < 0.3 or n > 6 then
        dhd("Usage: /hd size <meters>")
        return
    end
    if Holodeck.savedVars then Holodeck.savedVars.bossSizeM = n end
    KIND.boss.sizeM = n
    local boss = Holodeck.entities["boss"]
    if boss and boss.ctl and boss.ctl.SetTransformScale then boss.ctl:SetTransformScale(n) end
    dhd(string.format("Boss size %.2f m", n))
end

local function CmdY(arg)
    local n = tonumber(arg)
    if not n or n < 0 or n > 8 then
        dhd("Usage: /hd y <meters>")
        return
    end
    if Holodeck.savedVars then Holodeck.savedVars.yOffsetM = n end
    KIND.boss.yOffM = n
    local boss = Holodeck.entities["boss"]
    if boss then boss.yOffM = n PlaceEntity(boss) end
    dhd(string.format("Boss y offset %.2f m", n))
end

local function CmdStatus()
    local o = Holodeck.origin and "set" or "none"
    local src = Holodeck.fightSource or "-"
    local fname = Holodeck.fight and Holodeck.fight.name or "none"
    dhd(string.format("v%s origin=%s fight=%s src=%s t=%.1fs playing=%s authorMarks=%d label=%s",
        Holodeck.version, o, fname, src, Holodeck.playT or 0, tostring(Holodeck.playing),
        AuthorMarkCount(), Holodeck.author.label or "scratch"))
end

local function CmdHelp()
    dhd("v" .. Holodeck.version .. " — library playback + author scratch (not the same thing).")
    d("|cAADDFF-- Playback (library) --|r")
    d("|cC0E0FF/hd origin|r     set origin; load house_demo; clears scratch")
    d("|cC0E0FF/hd list|r       shipped packs")
    d("|cC0E0FF/hd load <id>|r  e.g. house_demo")
    d("|cC0E0FF/hd demo|r       force house_demo")
    d("|cC0E0FF/hd play|r       play author scratch if marks exist, else loaded pack")
    d("|cC0E0FF/hd pause|r |cC0E0FFrestart|r |cC0E0FFstop|r |cC0E0FFphase N|r")
    d("|cAADDFF-- Author scratch (export offline into fights/) --|r")
    d("|cC0E0FF/hd mark [id] [kind]|r  keyframe at feet (default id=active/boss)")
    d("|cC0E0FF/hd markhide [id]|r     visible=false at author t")
    d("|cC0E0FF/hd t <sec>|r |cC0E0FF/hd t+ <sec>|r   author clock")
    d("|cC0E0FF/hd ent <id>|r   default mark id")
    d("|cC0E0FF/hd packname X|r label scratch (cosmetic)")
    d("|cC0E0FF/hd dump|r       print Lua-ish entities for paste")
    d("|cC0E0FF/hd dump show|r  last dump from SavedVars")
    d("|cC0E0FF/hd marklist|r |cC0E0FF/hd markclear|r")
    d("|cAADDFF-- Misc --|r")
    d("|cC0E0FF/hd clear|r |cC0E0FF/hd status|r |cC0E0FF/hd size N|r |cC0E0FF/hd y N|r |cC0E0FFdebug|r")
end

local function CmdDebug()
    if not Holodeck.savedVars then return end
    Holodeck.savedVars.debug = not Holodeck.savedVars.debug
    dhd("debug = " .. tostring(Holodeck.savedVars.debug))
end

local function OnSlash(args)
    args = args or ""
    local cmd, rest = args:match("^(%S+)%s*(.-)$")
    cmd = (cmd or ""):lower()
    rest = rest or ""

    if cmd == "" or cmd == "help" or cmd == "?" then
        CmdHelp()
    elseif cmd == "origin" or cmd == "pin" or cmd == "set" then
        CmdOrigin()
    elseif cmd == "play" then
        CmdPlay()
    elseif cmd == "pause" then
        CmdPause()
    elseif cmd == "restart" then
        CmdRestart()
    elseif cmd == "stop" then
        CmdStop()
    elseif cmd == "phase" or cmd == "ph" then
        CmdPhase(rest)
    elseif cmd == "list" or cmd == "packs" then
        CmdList()
    elseif cmd == "load" then
        CmdLoad(rest)
    elseif cmd == "demo" then
        CmdDemo()
    elseif cmd == "mark" or cmd == "m" then
        CmdMark(rest)
    elseif cmd == "markhide" or cmd == "mh" or cmd == "hide" then
        CmdMarkHide(rest)
    elseif cmd == "t" then
        CmdT(rest)
    elseif cmd == "t+" or cmd == "tplus" then
        CmdTPlus(rest)
    elseif cmd == "ent" or cmd == "entity" then
        CmdEnt(rest)
    elseif cmd == "packname" or cmd == "pack" or cmd == "label" then
        CmdPackName(rest)
    elseif cmd == "dump" then
        if rest:lower() == "show" then CmdDumpShow() else CmdDump(rest) end
    elseif cmd == "marklist" or cmd == "ml" then
        CmdMarkList()
    elseif cmd == "markclear" or cmd == "mc" then
        CmdMarkClear()
    elseif cmd == "clear" then
        CmdClear()
    elseif cmd == "size" or cmd == "scale" then
        CmdSize(rest)
    elseif cmd == "y" or cmd == "height" then
        CmdY(rest)
    elseif cmd == "status" or cmd == "st" then
        CmdStatus()
    elseif cmd == "debug" then
        CmdDebug()
    else
        dhd("Unknown: /hd " .. cmd)
        CmdHelp()
    end
end

-- ============================= Lifecycle ================================
local function OnAddOnLoaded(_, addonName)
    if addonName ~= Holodeck.name then return end
    EVENT_MANAGER:UnregisterForEvent(Holodeck.name, EVENT_ADD_ON_LOADED)

    Holodeck.savedVars = ZO_SavedVars:NewAccountWide("HolodeckVars", 1, nil, DEFAULTS)
    if Holodeck.savedVars then
        if Holodeck.savedVars.bossSizeM then KIND.boss.sizeM = Holodeck.savedVars.bossSizeM end
        if Holodeck.savedVars.yOffsetM then KIND.boss.yOffM = Holodeck.savedVars.yOffsetM end
        if Holodeck.savedVars.minibossSizeM then KIND.miniboss.sizeM = Holodeck.savedVars.minibossSizeM end
        if Holodeck.savedVars.authorLabel then Holodeck.author.label = Holodeck.savedVars.authorLabel end
    end

    SLASH_COMMANDS["/hd"] = OnSlash
    SLASH_COMMANDS["/holodeck"] = OnSlash

    local nPacks = 0
    for _ in pairs(Holodeck.Fights) do nPacks = nPacks + 1 end
    dhd(string.format("v%s loaded. library packs=%d. |cC0E0FF/hd origin|r · |cC0E0FF/hd list|r · |cC0E0FF/hd mark|r · |cC0E0FF/hd dump|r", Holodeck.version, nPacks))
end

EVENT_MANAGER:RegisterForEvent(Holodeck.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

Holodeck.CmdOrigin = CmdOrigin
Holodeck.CmdPlay = CmdPlay
Holodeck.CmdClear = CmdClear
Holodeck.CmdMark = CmdMark
Holodeck.CmdDump = CmdDump
_G.Holodeck = Holodeck
