--=====================================================================
-- Holodeck.lua — v0.0.16
--
-- Versioning (DM2 suite): human Version = M.m.p
--   AddOnVersion (manifest) = major*10000 + minor*100 + patch
--   0.0.16 → 16
--
-- 0.0.16: Open last/saves UX; plant no longer forces house_demo; tier filter
-- 0.0.15: Texture palette + role/spot kinds (tank/healer/dps, soak/safe/…)
-- 0.0.14: Reticle/elite capture harden + probe; clean saves list names
-- 0.0.13: Permissive reticle elites, boss_reticle, saves panel
-- 0.0.8: Stock ESO textures; snap playback flag
--
-- plant = coordinate ZERO (room anchor), NOT automatic boss spawn.
-- Slash = actions; /hdsettings = preferences.
--=====================================================================

local Holodeck = Holodeck or {}
Holodeck.name        = "DeadMarker_Holodeck"
Holodeck.displayName = "Holodeck"
Holodeck.version     = "0.0.16"

Holodeck.Fights = Holodeck.Fights or {}
function Holodeck.RegisterFight(fight)
    if type(fight) == "table" and fight.id then
        Holodeck.Fights[fight.id] = fight
    end
end

-- ============================= Textures / kinds ========================
-- SPACE_WORLD lessons:
--   • Stock ESO POI icons are reliable in world space.
--   • Early custom Holodeck DDS (hd_boss etc.) rendered as white blocks — do not prefer them.
--   • DeadMarker2 role DDS (copied as hd_tank/healer/dps) work in world space — prefer for roles.
-- Pack path is relative to AddOns root (same pattern as DeadMarker2).
local PACK = "DeadMarker_Holodeck/textures/"

local TEX_BOSS     = "/esoui/art/icons/poi/poi_groupboss_complete.dds"
local TEX_MINIBOSS = "/esoui/art/icons/poi/poi_groupinstance_complete.dds"
local TEX_TRASH    = "/esoui/art/icons/poi/poi_delve_complete.dds"
local TEX_STACK    = "/esoui/art/icons/poi/poi_areaofinterest_complete.dds"
local TEX_SOAK     = "/esoui/art/icons/poi/poi_publicdungeon_complete.dds"
local TEX_SAFE     = "/esoui/art/icons/poi/poi_wayshrine_complete.dds"
local TEX_PORTAL   = "/esoui/art/icons/poi/poi_portal_complete.dds"
local TEX_ORIGIN   = "/esoui/art/icons/mapkey/mapkey_wayshrine.dds"
local TEX_RING     = "/esoui/art/icons/poi/poi_areaofinterest_incomplete.dds"
local TEX_DOT      = "/esoui/art/buttons/radiobuttonup.dds"
local TEX_FALLBACK = "/esoui/art/icons/poi/poi_areaofinterest_complete.dds"

-- ESO fallbacks for roles (if packaged DM2-style icons fail to load)
local TEX_TANK_ESO   = "/esoui/art/icons/poi/poi_groupboss_complete.dds"
local TEX_HEALER_ESO = "/esoui/art/icons/poi/poi_wayshrine_complete.dds"
local TEX_DPS_ESO    = "/esoui/art/icons/quest_book_001.dds"

local ORIGIN_PIN_LOCAL_X = -1.5
local ORIGIN_PIN_LOCAL_Z = -1.5
local MIN_TRAVEL_SEC     = 0.35
local PATH_SPEED_M_S     = 5.0
local PATH_Y_M           = 0.12
local PATH_DOT_SPACING   = 1.1
local SNAP_TRAVEL_EPS    = 0.05

-- Public kind set for markers / fight packs / future team roles.
-- group: enemy | role | spot | system
-- texture = preferred path; fallback = ESO stock if preferred fails
local KIND = {
    -- Enemies (recording + packs)
    boss = {
        label = "Boss", group = "enemy",
        texture = TEX_BOSS, fallback = TEX_FALLBACK,
        sizeM = 1.7, color = { 0.92, 0.18, 0.14 }, yOffM = 1.9,
    },
    mini = {
        label = "Mini / LT", group = "enemy",
        texture = TEX_MINIBOSS, fallback = TEX_FALLBACK,
        sizeM = 1.35, color = { 1.00, 0.55, 0.12 }, yOffM = 1.55,
    },
    trash = {
        label = "Trash / add", group = "enemy",
        texture = TEX_TRASH, fallback = TEX_FALLBACK,
        sizeM = 0.95, color = { 0.75, 0.55, 0.35 }, yOffM = 1.0,
    },
    -- Roles (manual mark now; team record / demo ghosts later — same as DM2)
    tank = {
        label = "Tank", group = "role",
        texture = PACK .. "hd_tank.dds", fallback = TEX_TANK_ESO,
        sizeM = 1.15, color = { 0.35, 0.55, 1.00 }, yOffM = 1.35,
    },
    healer = {
        label = "Healer", group = "role",
        texture = PACK .. "hd_healer.dds", fallback = TEX_HEALER_ESO,
        sizeM = 1.10, color = { 0.35, 0.95, 0.45 }, yOffM = 1.30,
    },
    dps = {
        label = "DPS", group = "role",
        texture = PACK .. "hd_dps.dds", fallback = TEX_DPS_ESO,
        sizeM = 1.05, color = { 0.95, 0.35, 0.55 }, yOffM = 1.25,
    },
    -- Spots (author drops for team walkthrough)
    stack = {
        label = "Stack", group = "spot",
        texture = TEX_STACK, fallback = TEX_FALLBACK,
        sizeM = 1.05, color = { 0.40, 0.85, 1.00 }, yOffM = 0.55,
    },
    soak = {
        label = "Soak", group = "spot",
        texture = TEX_SOAK, fallback = TEX_FALLBACK,
        sizeM = 1.10, color = { 0.85, 0.35, 0.95 }, yOffM = 0.60,
    },
    safe = {
        label = "Safe / out", group = "spot",
        texture = TEX_SAFE, fallback = TEX_FALLBACK,
        sizeM = 1.00, color = { 0.55, 1.00, 0.70 }, yOffM = 0.50,
    },
    portal = {
        label = "Portal / door", group = "spot",
        texture = TEX_PORTAL, fallback = TEX_STACK,
        sizeM = 1.15, color = { 0.70, 0.50, 1.00 }, yOffM = 0.85,
    },
    -- System
    origin = {
        label = "Origin (plant)", group = "system",
        texture = TEX_ORIGIN, fallback = TEX_FALLBACK,
        sizeM = 0.85, color = { 1.0, 1.0, 0.35 }, yOffM = 0.35,
    },
}
-- Alias only (not listed separately in palette UI)
KIND.miniboss = KIND.mini

-- Exact-name → kind (before substring heuristics)
local NAME_TYPE = {
    boss = "boss", lieutenant = "mini", lt = "mini", mini = "mini", miniboss = "mini",
    trash = "trash", add = "trash", adds = "trash",
    tank = "tank", mt = "tank", ot = "tank", tank1 = "tank", tank2 = "tank",
    healer = "healer", heal = "healer", heals = "healer", h1 = "healer", h2 = "healer",
    dps = "dps", dd = "dps", dps1 = "dps",
    stack = "stack", stack_main = "stack", main_stack = "stack",
    soak = "soak", safe = "safe", out = "safe", portal = "portal", door = "portal",
    origin = "origin",
}

local KIND_ORDER = {
    "boss", "mini", "trash",
    "tank", "healer", "dps",
    "stack", "soak", "safe", "portal",
    "origin",
}

local function NormalizeKind(typ)
    if not typ then return nil end
    typ = string.lower(tostring(typ))
    if typ == "miniboss" or typ == "lt" or typ == "lieutenant" then return "mini" end
    if typ == "heal" or typ == "heals" then return "healer" end
    if typ == "mt" or typ == "ot" or typ == "tanks" then return "tank" end
    if typ == "dd" or typ == "dps_player" then return "dps" end
    if typ == "add" or typ == "adds" or typ == "mob" then return "trash" end
    if typ == "out" or typ == "kited" then return "safe" end
    if typ == "door" or typ == "gate" then return "portal" end
    if KIND[typ] then return typ end
    return nil
end

-- Map LFG / DM2 role labels → Holodeck kind (team capture / demo later)
local function RoleToKind(role)
    if type(role) == "number" then
        if type(LFG_ROLE_TANK) == "number" and role == LFG_ROLE_TANK then return "tank" end
        if type(LFG_ROLE_HEAL) == "number" and role == LFG_ROLE_HEAL then return "healer" end
        if type(LFG_ROLE_DPS) == "number" and role == LFG_ROLE_DPS then return "dps" end
        return "dps"
    end
    local r = string.lower(tostring(role or "dps"))
    if r == "heal" or r == "healer" then return "healer" end
    if r == "tank" then return "tank" end
    return "dps"
end
Holodeck.RoleToKind = RoleToKind
Holodeck.NormalizeKind = NormalizeKind
Holodeck.KIND = KIND
Holodeck.KIND_ORDER = KIND_ORDER

local DEFAULTS = {
    bossSizeM = 1.6, minibossSizeM = 1.25, originSizeM = 0.7, roleSizeM = 1.1,
    yOffsetM = 1.8, opacity = 1.0, debug = false,
    legendOn = true, sheetOn = false, pathOn = true,
    playMode = "once", -- once | loop
    saves = {},        -- name -> fight table
    lastExport = nil,
    sheetX = 40, sheetY = 120,
    -- Recorder policy (LAM)
    autoArmInInstances = true,
    recordStartMode = "boss",  -- manual | combat | boss
    recordAutoStop = true,
    recordAutoSave = false,
    recordIntervalMs = 400,
    -- What to sample (training default: bosses only — team walks themselves in house)
    recordCaptureBosses = true,
    recordCaptureSelf = false,
    recordCaptureTeam = false,
    recordCaptureElites = true,   -- reticle Hard/Deadly
    recordEliteTier = 4,          -- 0 off .. 4 any hostile on reticle
    recordRequirePlant = false,
    shareReceiveEnabled = true,
    lastSaveName = nil,
}

-- ============================= State ====================================
Holodeck.savedVars = nil
Holodeck.hudTop = nil
Holodeck.fragment = nil
Holodeck.idseq = 0
Holodeck.wsPins = {}
Holodeck.actors = {}      -- name -> actor pin
Holodeck.pathGfx = {}     -- list of ring/line controls
Holodeck.origin = nil
Holodeck.fight = nil
Holodeck.fightSource = nil  -- "sandbox" | "save" | "library"
Holodeck.loadedId = nil
Holodeck.workingName = "sandbox" -- display: sandbox or save name
Holodeck.playing = false
Holodeck.playFinished = false   -- once mode ended at last pose
Holodeck.playT = 0
Holodeck.playMode = "once"
Holodeck._lastTickMs = nil
Holodeck._lastPhaseAnnounced = nil
Holodeck._tickName = "Holodeck_PinTick"
Holodeck._tickMs = 50
Holodeck._tickRunning = false

-- Author workspace
Holodeck.editName = "boss"
Holodeck.clock = 0
Holodeck._lastStopAddMs = nil
Holodeck.stops = {}  -- name -> array of { t, x, z, hold, visible }
Holodeck.types = {}  -- name -> kind

-- UI
Holodeck.legendTLW = nil
Holodeck.legendLabel = nil
Holodeck.legendHint = nil
Holodeck.sheetTLW = nil
Holodeck.sheetLabel = nil

-- ============================= Utils ====================================
local function dhd(msg)
    d(string.format("|c69c0ff[%s]|r %s", Holodeck.displayName, tostring(msg)))
end

local function dbug(msg)
    if Holodeck.savedVars and Holodeck.savedVars.debug then dhd("dbg: " .. tostring(msg)) end
end

local function round2(n)
    return math.floor(((n or 0) * 100) + 0.5) / 100
end

local function sv()
    return Holodeck.savedVars or DEFAULTS
end

local function InferType(name, explicit)
    local nk = NormalizeKind(explicit)
    if nk then return nk end
    local key = string.lower(tostring(name or ""))
    if NAME_TYPE[key] then return NAME_TYPE[key] end
    -- Substring heuristics (entity ids like tank_mt, elite_captain_…, healer_1)
    if key:find("tank", 1, true) or key:find("_mt", 1, true) or key:match("^mt_") or key:match("^ot_") then
        return "tank"
    end
    if key:find("heal", 1, true) then return "healer" end
    if key:find("dps", 1, true) or key:find("_dd", 1, true) then return "dps" end
    if key:find("soak", 1, true) then return "soak" end
    if key:find("safe", 1, true) or key:find("kite", 1, true) then return "safe" end
    if key:find("portal", 1, true) or key:find("door", 1, true) then return "portal" end
    if key:find("trash", 1, true) or key:find("add", 1, true) then return "trash" end
    if key:find("stack", 1, true) then return "stack" end
    if key:find("boss", 1, true) and not key:find("mini", 1, true) then return "boss" end
    if key:find("lt", 1, true) or key:find("lieut", 1, true) or key:find("mini", 1, true)
        or key:find("elite_", 1, true) or key:find("captain", 1, true) then
        return "mini"
    end
    if key:find("player", 1, true) or key:find("group", 1, true) then return "dps" end
    return "stack"
end

-- ============================= Safe UI ==================================
local function _SafeCreateTLW(name)
    if not name then return nil end
    if _G[name] then return _G[name] end
    if not WINDOW_MANAGER or not WINDOW_MANAGER.CreateTopLevelWindow then return nil end
    local ok, tlw = pcall(function() return WINDOW_MANAGER:CreateTopLevelWindow(name) end)
    if ok and tlw then return tlw end
    return _G[name]
end

local function _SafeCreateControl(name, parent, controlType)
    if not name or not parent or not controlType then return nil end
    if _G[name] then return _G[name] end
    if not WINDOW_MANAGER or not WINDOW_MANAGER.CreateControl then return nil end
    local ok, ctl = pcall(function() return WINDOW_MANAGER:CreateControl(name, parent, controlType) end)
    if ok and ctl then return ctl end
    return _G[name]
end

local function uniqueName(prefix)
    Holodeck.idseq = (Holodeck.idseq or 0) + 1
    return string.format("%s_%d_%d", prefix, Holodeck.idseq, GetFrameTimeMilliseconds() or 0)
end

-- Prefer path; if control reports empty load, try fallback (DM2 pattern).
local function _SetTextureSafe(ctrl, path, fallback)
    if not ctrl then return end
    local try = path or fallback or TEX_FALLBACK
    ctrl:SetTexture(try)
    local loaded = (ctrl.GetTextureFileName and ctrl:GetTextureFileName()) or ""
    local ok = loaded and loaded ~= ""
    if ok and try ~= "" then
        -- Some clients return a resolved path that only partially matches; accept non-empty
        ok = true
    end
    if not ok or loaded == "" then
        local fb = fallback or TEX_FALLBACK
        if fb ~= try then
            ctrl:SetTexture(fb)
            return fb
        end
        ctrl:SetTexture(TEX_FALLBACK)
        return TEX_FALLBACK
    end
    return loaded
end

local function TextureForKind(kind)
    local def = KIND[kind] or KIND.stack
    return def.texture, def.fallback or TEX_FALLBACK
end

-- ============================= HUD host =================================
local function ensureHUDTop()
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

local function WS_SetAtRaw(ctl, x, y, z, pitch, yaw, roll)
    if not ctl then return end
    local sx, sy, sz = WS_GetRenderOriginWorld()
    if not sx then return end
    ctl:SetTransformOffset((x - sx) / 100, (y - sy) / 100, (z - sz) / 100)
    ctl:SetTransformRotation(pitch or 0, yaw or 0, roll or 0)
    ctl:SetHidden(false)
end

local function BillboardYawPitch()
    local fx, fy, fz = GetCameraForward(SPACE_WORLD)
    if not fx or not fz then return 0, 0 end
    return math.atan2(fx, fz) + math.pi, -math.asin(fy or 0)
end

local function WS_CreateTexture(tag, sizeM, texturePath, color, dims, fallback)
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
        _SetTextureSafe(ctl, texturePath or TEX_BOSS, fallback or TEX_FALLBACK)
        local r, g, b = 1, 1, 1
        if color then r, g, b = color[1] or 1, color[2] or 1, color[3] or 1 end
        local a = sv().opacity or 1
        if ctl.SetDesaturation then ctl:SetDesaturation(0) end
        ctl:SetColor(r, g, b, a)
        ctl:SetAlpha(a)
        if ctl.SetScale then ctl:SetScale(1 / 100) end
        if ctl.SetTransformScale then ctl:SetTransformScale(sizeM or 1.2) end
        local dw, dh = 128, 128
        if dims then dw, dh = dims[1] or 128, dims[2] or 128 end
        ctl:SetDimensions(dw, dh)
        Holodeck.wsPins[name] = ctl
        return ctl
    end)
    if ok then return result end
    return nil
end

local function LocalToWorld(lx, ly, lz)
    local o = Holodeck.origin
    if not o then return nil end
    return o.x + (lx or 0) * 100, o.y + (ly or 0) * 100, o.z + (lz or 0) * 100
end

local function PlayerLocalXZ()
    if not Holodeck.origin then return nil end
    local _, px, _, pz = GetUnitRawWorldPosition("player")
    if not px then return nil end
    return round2((px - Holodeck.origin.x) / 100), round2((pz - Holodeck.origin.z) / 100)
end

-- ============================= Actor pins ===============================
local function SizeFor(kind)
    local s = sv()
    kind = NormalizeKind(kind) or kind
    if kind == "boss" then return s.bossSizeM or (KIND.boss.sizeM or 1.6) end
    if kind == "mini" then return s.minibossSizeM or (KIND.mini.sizeM or 1.25) end
    if kind == "origin" then return s.originSizeM or (KIND.origin.sizeM or 0.7) end
    if kind == "tank" or kind == "healer" or kind == "dps" then
        return s.roleSizeM or (KIND[kind] and KIND[kind].sizeM) or 1.1
    end
    return (KIND[kind] and KIND[kind].sizeM) or 1.0
end

local function EnsureActor(name, kind)
    kind = NormalizeKind(kind) or InferType(name)
    local act = Holodeck.actors[name]
    local def = KIND[kind] or KIND.stack
    local tex, fb = def.texture, def.fallback or TEX_FALLBACK
    if act and act.ctl then
        if act.kind ~= kind then
            act.kind = kind
            _SetTextureSafe(act.ctl, tex, fb)
            act.ctl:SetColor(def.color[1], def.color[2], def.color[3], sv().opacity or 1)
            if act.ctl.SetTransformScale then act.ctl:SetTransformScale(SizeFor(kind)) end
            act.yOffM = def.yOffM
        end
        return act
    end
    local ctl = WS_CreateTexture(name, SizeFor(kind), tex, def.color, nil, fb)
    if not ctl then return nil end
    act = { name = name, kind = kind, ctl = ctl, x = 0, z = 0, yOffM = def.yOffM, visible = true }
    Holodeck.actors[name] = act
    return act
end

local function PlaceActor(act)
    if not act or not act.ctl or not Holodeck.origin then return end
    if act.visible == false then
        act.ctl:SetHidden(true)
        return
    end
    local yOff = act.yOffM or 1
    local wx, wy, wz = LocalToWorld(act.x or 0, yOff, act.z or 0)
    if not wx then return end
    local yaw, pitch = BillboardYawPitch()
    WS_SetAtRaw(act.ctl, wx, wy, wz, pitch, yaw, 0)
end

local function EnsureOriginMarker()
    local act = EnsureActor("origin", "origin")
    if not act then return end
    act.x, act.z = ORIGIN_PIN_LOCAL_X, ORIGIN_PIN_LOCAL_Z
    act.visible = true
    PlaceActor(act)
end

local function DestroyAllActors()
    for _, act in pairs(Holodeck.actors) do
        if act.ctl then
            act.ctl:SetHidden(true)
            local n = act.ctl:GetName()
            if n then Holodeck.wsPins[n] = nil end
        end
    end
    Holodeck.actors = {}
end

-- ============================= Path graphics ============================
local function ClearPathGfx()
    for i = 1, #Holodeck.pathGfx do
        local c = Holodeck.pathGfx[i]
        if c then
            c:SetHidden(true)
            local n = c.GetName and c:GetName()
            if n then Holodeck.wsPins[n] = nil end
        end
    end
    Holodeck.pathGfx = {}
end

local function AddPathControl(ctl)
    if ctl then Holodeck.pathGfx[#Holodeck.pathGfx + 1] = ctl end
    return ctl
end

local function PlaceFlatMarker(tag, lx, lz, texture, col, sizeM, alpha, dims)
    local ctl = WS_CreateTexture(tag, sizeM or 0.55, texture, col, dims or { 96, 96 })
    if not ctl then return nil end
    ctl:SetAlpha(alpha or 0.85)
    local wx, wy, wz = LocalToWorld(lx, PATH_Y_M, lz)
    if wx then
        -- Flat on ground (same as stop rings — reliable)
        WS_SetAtRaw(ctl, wx, wy, wz, math.pi / 2, 0, 0)
    end
    return AddPathControl(ctl)
end

local function RebuildPathGfx()
    ClearPathGfx()
    if not Holodeck.origin then return end
    if not sv().pathOn then return end

    for name, list in pairs(Holodeck.stops) do
        if list and #list > 0 then
            local typ = Holodeck.types[name] or InferType(name)
            local def = KIND[typ] or KIND.stack
            local col = def.color or { 1, 1, 1 }
            -- stop rings
            for i = 1, #list do
                local s = list[i]
                if s.visible ~= false and s.x ~= nil then
                    PlaceFlatMarker("ring_" .. name .. "_" .. i, s.x, s.z, TEX_RING, col, 1.15, 0.6, { 200, 200 })
                end
            end
            -- path "lines" = dots every ~1.1m (stretched UI textures often fail in SPACE_WORLD)
            local prev = nil
            for i = 1, #list do
                local s = list[i]
                if s.visible ~= false and s.x ~= nil then
                    if prev and prev.x ~= nil then
                        local x1, z1, x2, z2 = prev.x, prev.z, s.x, s.z
                        local dx, dz = x2 - x1, z2 - z1
                        local len = math.sqrt(dx * dx + dz * dz)
                        if len > 0.15 then
                            local steps = math.max(1, math.floor(len / PATH_DOT_SPACING))
                            for step = 1, steps do
                                local u = step / (steps + 1)
                                local px = x1 + dx * u
                                local pz = z1 + dz * u
                                PlaceFlatMarker(
                                    "dot_" .. name .. "_" .. i .. "_" .. step,
                                    px, pz, TEX_DOT, col, 0.35, 0.9, { 64, 64 })
                            end
                        end
                    end
                    prev = s
                elseif s.visible == false then
                    prev = nil
                end
            end
        end
    end
end

-- ============================= Stops model ==============================
local function SortStops(list)
    table.sort(list, function(a, b) return (a.t or 0) < (b.t or 0) end)
end

local function HasSandboxStops()
    for _, list in pairs(Holodeck.stops) do
        if list and #list > 0 then return true end
    end
    return false
end

local function CountStops()
    local n = 0
    for _, list in pairs(Holodeck.stops) do n = n + #(list or {}) end
    return n
end

local function ClearStops(quiet)
    Holodeck.stops = {}
    Holodeck.types = {}
    Holodeck.clock = 0
    Holodeck._lastStopAddMs = nil
    ClearPathGfx()
    if not quiet then dhd("Sandbox path cleared.") end
end

local function LastStop(name)
    local list = Holodeck.stops[name]
    if not list or #list == 0 then return nil end
    return list[#list]
end

local function PathEndTime()
    local maxT = 0
    for _, list in pairs(Holodeck.stops) do
        for i = 1, #(list or {}) do
            local s = list[i]
            local endT = (s.t or 0) + (s.hold or 0)
            if endT > maxT then maxT = endT end
        end
    end
    return maxT
end

--- Position of one actor at timeline t. Returns x,z,visible
local function SampleStopsAt(list, t)
    if not list or #list == 0 then return 0, 0, false end

    -- Each stop i: arrive t_i, hold until tLeave, then travel (or SNAP) until t_{i+1}
    local first = list[1]
    if t < (first.t or 0) then
        local vis = first.visible
        if vis == nil then vis = true end
        return first.x or 0, first.z or 0, vis
    end

    for i = 1, #list do
        local s = list[i]
        local tArr = s.t or 0
        local hold = s.hold or 0
        local tLeave = tArr + hold
        local vis = s.visible
        if vis == nil then vis = true end

        local nxt = list[i + 1]
        if not nxt then
            if t >= tArr then
                return s.x or 0, s.z or 0, vis
            end
        else
            local tNext = nxt.t or tLeave
            if tNext < tLeave then tNext = tLeave end

            if t < tArr then
                return s.x or 0, s.z or 0, vis
            end
            -- Inclusive hold: stay on this stop through tLeave
            if t <= tLeave + 1e-6 then
                return s.x or 0, s.z or 0, vis
            end

            local span = tNext - tLeave
            local isSnap = (nxt.snap == true) or (span <= SNAP_TRAVEL_EPS)

            if isSnap then
                -- Instant travel: do NOT return nxt forever — that stuck playback on stop 2.
                -- After leave, fall through so the next loop iteration owns the pose
                -- (hold on stop 2, then walk/snap to stop 3, etc.).
                -- (no return here)
            elseif t < tNext then
                if s.visible == false then
                    return nxt.x or 0, nxt.z or 0, nxt.visible ~= false
                end
                if nxt.visible == false then
                    return s.x or 0, s.z or 0, true
                end
                local u = (span > 1e-6) and ((t - tLeave) / span) or 1
                if u < 0 then u = 0 end
                if u > 1 then u = 1 end
                local x1, z1 = s.x or 0, s.z or 0
                local x2, z2 = nxt.x or 0, nxt.z or 0
                return x1 + (x2 - x1) * u, z1 + (z2 - z1) * u, true
            end
            -- else t >= tNext: continue to next stop in list
        end
    end
    local last = list[#list]
    return last.x or 0, last.z or 0, last.visible ~= false
end

local function FightFromSandbox()
    local entities = {}
    for name, list in pairs(Holodeck.stops) do
        if list and #list > 0 then
            local track = {}
            for i = 1, #list do
                local s = list[i]
                track[#track + 1] = {
                    t = s.t, x = s.x, z = s.z, hold = s.hold,
                    visible = s.visible, snap = s.snap,
                }
            end
            entities[#entities + 1] = {
                id = name,
                kind = Holodeck.types[name] or InferType(name),
                label = name,
                track = track,
                _stops = list,
            }
        end
    end
    table.sort(entities, function(a, b) return a.id < b.id end)
    local dur = PathEndTime()
    if dur < 0.5 then dur = 0.5 end
    return {
        id = Holodeck.workingName or "sandbox",
        name = "Path: " .. (Holodeck.workingName or "sandbox"),
        durationSec = dur,
        entities = entities,
        _fromSandbox = true,
        phases = {
            { id = 1, name = "Start", t = 0 },
            { id = 2, name = "Mid", t = dur * 0.5 },
            { id = 3, name = "End", t = dur },
        },
    }
end

--- Convert library-style track (no hold) into sample via old keyframe lerp for library packs
local function SampleLibraryTrack(track, tSec)
    if not track or #track == 0 then return 0, 0, false end
    local function visAt(t)
        local vis = true
        for i = 1, #track do
            local k = track[i]
            if (k.t or 0) <= t and k.visible ~= nil then vis = k.visible and true or false end
            if (k.t or 0) > t then break end
        end
        return vis
    end
    local pos = {}
    for i = 1, #track do
        local k = track[i]
        if k.x ~= nil or k.z ~= nil then pos[#pos + 1] = k end
    end
    local vis = visAt(tSec)
    if #pos == 0 then return 0, 0, vis end
    if tSec <= (pos[1].t or 0) then return pos[1].x or 0, pos[1].z or 0, vis end
    if tSec >= (pos[#pos].t or 0) then return pos[#pos].x or 0, pos[#pos].z or 0, vis end
    for i = 1, #pos - 1 do
        local a, b = pos[i], pos[i + 1]
        local ta, tb = a.t or 0, b.t or 0
        if tSec >= ta and tSec <= tb then
            local u = (tb > ta) and ((tSec - ta) / (tb - ta)) or 0
            return (a.x or 0) + ((b.x or 0) - (a.x or 0)) * u,
                   (a.z or 0) + ((b.z or 0) - (a.z or 0)) * u, vis
        end
    end
    return pos[#pos].x or 0, pos[#pos].z or 0, vis
end

local function ApplyTimeline(tSec, announce)
    local fight = Holodeck.fight
    if not fight then return end

    if fight._fromSandbox then
        for name, list in pairs(Holodeck.stops) do
            local typ = Holodeck.types[name] or InferType(name)
            local act = EnsureActor(name, typ)
            if act then
                local x, z, vis = SampleStopsAt(list, tSec)
                act.x, act.z, act.visible = x, z, vis
                PlaceActor(act)
            end
        end
    else
        for i = 1, #(fight.entities or {}) do
            local def = fight.entities[i]
            local kind = NormalizeKind(def.kind) or InferType(def.id, def.kind) or "stack"
            local act = EnsureActor(def.id, kind)
            if act then
                local x, z, vis = SampleLibraryTrack(def.track, tSec)
                act.x, act.z, act.visible = x, z, vis
                PlaceActor(act)
            end
        end
    end
    EnsureOriginMarker()

    if announce and fight.phases then
        local best = fight.phases[1]
        for i = 1, #fight.phases do
            if (fight.phases[i].t or 0) <= tSec then best = fight.phases[i] end
        end
        if best and best.id ~= Holodeck._lastPhaseAnnounced then
            Holodeck._lastPhaseAnnounced = best.id
            dhd(string.format("Phase %s — %s (t=%.1fs)", tostring(best.id), tostring(best.name), tSec))
        end
    end
end

-- ============================= Legend / Sheet ===========================
local function LegendText()
    local work = Holodeck.workingName or "sandbox"
    local src = (work == "sandbox") and "SANDBOX" or ("save:" .. work)
    local mode = Holodeck.playMode or "once"
    local o = Holodeck.origin and "SET" or "no"
    local sheetState = sv().sheetOn and "ON" or "off"
    local pathState = sv().pathOn and "ON" or "off"
    local rec = (Holodeck.RecordStateLabel and Holodeck.RecordStateLabel()) or "OFF"
    local startMode = sv().recordStartMode or "boss"
    local lines = {
        string.format("Holodeck v%s | %s | plant:%s | rec:%s (start=%s) | clock:%.1fs | edit:%s | stops:%d | play:%s%s",
            Holodeck.version, src, o, rec, startMode, Holodeck.clock or 0, Holodeck.editName or "boss",
            CountStops(), mode, Holodeck.playing and " RUN" or (Holodeck.playFinished and " END" or "")),
        "RECORD  /hd arm | disarm   /hd record start|stop|probe   prefs: /hdsettings",
        "MANUAL  /hd plant  →  edit  →  type  →  stopadd | snap  →  hold  →  save",
        string.format("PLAY  play once|loop  |  sheet %s  path %s  |  textures  |  load house_demo", sheetState, pathState),
        "KEEP  save / open <id>|last / saves / export / share offer / new  |  /hdsettings",
    }
    return table.concat(lines, "\n")
end

local function EnsureLegend()
    if Holodeck.legendTLW and Holodeck.legendLabel then return end
    local tlw = _SafeCreateTLW("HolodeckLegend")
    if not tlw then return end
    tlw:SetMouseEnabled(false)
    tlw:SetMovable(false)
    tlw:SetClampedToScreen(true)
    tlw:SetDrawLayer(DL_OVERLAY)
    tlw:SetDrawTier(DT_HIGH)
    tlw:SetDrawLevel(320000)
    local w = select(1, GuiRoot:GetDimensions()) or 1920
    tlw:SetDimensions(math.min(w - 20, 1500), 128)
    tlw:ClearAnchors()
    tlw:SetAnchor(BOTTOM, GuiRoot, BOTTOM, 0, -8)

    local back = _SafeCreateControl("HolodeckLegendBack", tlw, CT_BACKDROP)
    if back then
        back:SetAnchorFill()
        back:SetCenterColor(0, 0, 0, 0.62)
        back:SetEdgeColor(0.4, 0.7, 1, 0.5)
        if back.SetEdgeTexture then pcall(function() back:SetEdgeTexture(nil, 1, 1, 2) end) end
    end

    local lbl = _SafeCreateControl("HolodeckLegendLabel", tlw, CT_LABEL)
    if lbl then
        lbl:ClearAnchors()
        lbl:SetAnchor(TOPLEFT, tlw, TOPLEFT, 10, 6)
        lbl:SetAnchor(BOTTOMRIGHT, tlw, BOTTOMRIGHT, -10, -6)
        lbl:SetFont("EsoUI/Common/Fonts/univers57.otf|15|soft-shadow-thin")
        lbl:SetColor(0.92, 0.95, 1, 1)
        if TEXT_ALIGN_LEFT then lbl:SetHorizontalAlignment(TEXT_ALIGN_LEFT) end
        if TEXT_ALIGN_TOP then lbl:SetVerticalAlignment(TEXT_ALIGN_TOP) end
        lbl:SetText("")
    end
    Holodeck.legendTLW = tlw
    Holodeck.legendLabel = lbl

    -- tiny hint when legend off (also NOT on a scene fragment)
    local hint = _SafeCreateTLW("HolodeckLegendHint")
    if hint then
        hint:SetMouseEnabled(false)
        hint:SetDimensions(280, 22)
        hint:ClearAnchors()
        hint:SetAnchor(BOTTOMLEFT, GuiRoot, BOTTOMLEFT, 12, -6)
        hint:SetDrawLayer(DL_OVERLAY)
        hint:SetDrawTier(DT_HIGH)
        hint:SetDrawLevel(319000)
        local hl = _SafeCreateControl("HolodeckLegendHintLbl", hint, CT_LABEL)
        if hl then
            hl:SetAnchorFill()
            hl:SetFont("EsoUI/Common/Fonts/univers57.otf|14|soft-shadow-thin")
            hl:SetColor(0.7, 0.85, 1, 0.85)
            hl:SetText("|c88AACCHolodeck|r  /hd legend on")
        end
        Holodeck.legendHint = hint
    end
    -- No ZO_SimpleSceneFragment: it re-shows the bar after /hd legend off (same bug as sheet).
end

local function IsLegendOn()
    if Holodeck.savedVars and Holodeck.savedVars.legendOn ~= nil then
        return Holodeck.savedVars.legendOn == true
    end
    return true
end

local function ApplyLegendVisibility()
    local on = IsLegendOn()
    if Holodeck.legendTLW then
        Holodeck.legendTLW:SetHidden(not on)
        Holodeck.legendTLW:SetAlpha(on and 1 or 0)
    end
    if Holodeck.legendHint then
        Holodeck.legendHint:SetHidden(on)
    end
    -- Re-assert after chat/layers (console) so off stays off
    zo_callLater(function()
        if not Holodeck.legendTLW then return end
        local still = IsLegendOn()
        Holodeck.legendTLW:SetHidden(not still)
        if Holodeck.legendHint then Holodeck.legendHint:SetHidden(still) end
    end, 50)
    zo_callLater(function()
        if not Holodeck.legendTLW then return end
        local still = IsLegendOn()
        Holodeck.legendTLW:SetHidden(not still)
        if Holodeck.legendHint then Holodeck.legendHint:SetHidden(still) end
    end, 250)
end

local function UpdateLegend()
    EnsureLegend()
    ApplyLegendVisibility()
    if IsLegendOn() and Holodeck.legendLabel then
        Holodeck.legendLabel:SetText(LegendText())
    end
end

local function SheetText()
    -- Avoid exotic format flags; ESO labels are happier with simple lines.
    local lines = {}
    lines[#lines + 1] = "PATH SHEET  |  " .. tostring(Holodeck.workingName or "sandbox")
        .. "  |  clock " .. string.format("%.1f", Holodeck.clock or 0)
        .. "s  |  edit " .. tostring(Holodeck.editName or "boss")
        .. "  |  stops " .. tostring(CountStops())
    lines[#lines + 1] = "Toggle: /hd sheet on   or   /hd sheet off"
    lines[#lines + 1] = "#  name   arrive  hold  x  z  state"
    local names = {}
    for n in pairs(Holodeck.stops) do names[#names + 1] = n end
    table.sort(names)
    if #names == 0 then
        lines[#lines + 1] = "(no stops yet — stand at a spot and /hd stopadd)"
    end
    for _, name in ipairs(names) do
        local list = Holodeck.stops[name]
        for i = 1, #(list or {}) do
            local s = list[i]
            local state = (s.visible == false) and "HIDE" or "show"
            lines[#lines + 1] = string.format(
                "%d  %s  t=%.1f  hold=%.1f  x=%.1f  z=%.1f  %s",
                i, tostring(name), s.t or 0, s.hold or 0, s.x or 0, s.z or 0, state)
        end
    end
    lines[#lines + 1] = "Drag title bar area to move panel · /hd export for chat dump"
    return table.concat(lines, "\n")
end

local function EnsureSheet()
    if Holodeck.sheetTLW and Holodeck.sheetLabel then return end
    local tlw = _SafeCreateTLW("HolodeckSheet")
    if not tlw then return end
    tlw:SetMouseEnabled(true)
    tlw:SetMovable(true)
    tlw:SetClampedToScreen(true)
    tlw:SetDrawLayer(DL_OVERLAY)
    tlw:SetDrawTier(DT_HIGH)
    tlw:SetDrawLevel(400000)
    if tlw.SetTopmost then pcall(function() tlw:SetTopmost(true) end) end
    tlw:SetDimensions(560, 300)
    local x, y = sv().sheetX or 40, sv().sheetY or 120
    tlw:ClearAnchors()
    tlw:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)

    local back = _SafeCreateControl("HolodeckSheetBack", tlw, CT_BACKDROP)
    if back then
        back:SetAnchorFill()
        back:SetCenterColor(0, 0, 0, 0.85)
        back:SetEdgeColor(0.5, 0.85, 1, 0.85)
        if back.SetEdgeTexture then pcall(function() back:SetEdgeTexture(nil, 1, 1, 2) end) end
        back:SetDrawLevel(0)
    end

    -- Single body label (title is included in SheetText) so we never leave an empty panel
    local lbl = _SafeCreateControl("HolodeckSheetLabel", tlw, CT_LABEL)
    if lbl then
        lbl:ClearAnchors()
        lbl:SetAnchor(TOPLEFT, tlw, TOPLEFT, 12, 10)
        lbl:SetDimensions(536, 280)
        lbl:SetFont("EsoUI/Common/Fonts/univers57.otf|16|soft-shadow-thin")
        lbl:SetColor(1, 1, 1, 1)
        if TEXT_ALIGN_LEFT then lbl:SetHorizontalAlignment(TEXT_ALIGN_LEFT) end
        if TEXT_ALIGN_TOP then lbl:SetVerticalAlignment(TEXT_ALIGN_TOP) end
        if lbl.SetWrapMode and TEXT_WRAP_MODE_ELLIPSIS then
            pcall(function() lbl:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) end)
        end
        lbl:SetDrawLevel(10)
        lbl:SetMouseEnabled(false)
        lbl:SetText("…")
    end
    Holodeck.sheetTLW = tlw
    Holodeck.sheetLabel = lbl
    -- IMPORTANT: do NOT attach ZO_SimpleSceneFragment here.
    -- Fragments fight SetHidden when chat/command layers open (console), which
    -- made the sheet vanish after /hd stopadd until a full scene change (LAM).
    -- Visibility is owned solely by sv().sheetOn via ApplySheetVisibility().
end

local function ApplySheetVisibility()
    local tlw = Holodeck.sheetTLW
    if not tlw then return end
    local on = (Holodeck.savedVars and Holodeck.savedVars.sheetOn) == true
    -- Explicit show/hide; re-assert after every command so chat layers cannot leave us stuck
    tlw:SetHidden(not on)
    tlw:SetAlpha(1)
    if tlw.SetHidden then
        -- second assert next frame after chat/action-layer settles (console)
        zo_callLater(function()
            if not Holodeck.sheetTLW then return end
            local stillOn = (Holodeck.savedVars and Holodeck.savedVars.sheetOn) == true
            Holodeck.sheetTLW:SetHidden(not stillOn)
            if stillOn then Holodeck.sheetTLW:SetAlpha(1) end
        end, 50)
        zo_callLater(function()
            if not Holodeck.sheetTLW then return end
            local stillOn = (Holodeck.savedVars and Holodeck.savedVars.sheetOn) == true
            Holodeck.sheetTLW:SetHidden(not stillOn)
        end, 200)
    end
end

local function UpdateSheet()
    EnsureSheet()
    ApplySheetVisibility()
    if Holodeck.sheetLabel then
        Holodeck.sheetLabel:SetHidden(false)
        Holodeck.sheetLabel:SetText(SheetText())
        Holodeck.sheetLabel:SetDimensions(536, 280)
    end
end

local function RefreshUI()
    UpdateLegend()
    UpdateSheet()
end

-- ============================= Load fight ===============================
local function LoadFightTable(fight, source, resetTime)
    if not fight then return false end
    Holodeck.fight = fight
    Holodeck.fightSource = source
    Holodeck.loadedId = fight.id
    if resetTime then
        Holodeck.playT = 0
        Holodeck.playFinished = false
        Holodeck._lastPhaseAnnounced = nil
    end
    ApplyTimeline(Holodeck.playT or 0, false)
    EnsureOriginMarker()
    return true
end

local function PreferPlayFight()
    -- Sandbox / opened save always wins when it has stops.
    if HasSandboxStops() then
        local f = FightFromSandbox()
        local src = (Holodeck.workingName == "sandbox") and "sandbox" or "save"
        LoadFightTable(f, src, false)
        return true
    end
    -- Keep an explicitly loaded library pack (via /hd load), but NEVER
    -- auto-fallback to house_demo here — that made /hd open look broken.
    if Holodeck.fight and Holodeck.fightSource == "library" and not Holodeck.fight._fromSandbox then
        return true
    end
    return false
end

-- ============================= Tick =====================================
local function _StopTick()
    if not Holodeck._tickRunning then return end
    EVENT_MANAGER:UnregisterForUpdate(Holodeck._tickName)
    Holodeck._tickRunning = false
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

        if Holodeck.playing and Holodeck.origin and Holodeck.fight and not Holodeck.playFinished then
            local dur = Holodeck.fight.durationSec or PathEndTime()
            if dur < 0.5 then dur = 0.5 end
            Holodeck.playT = (Holodeck.playT or 0) + dt
            if Holodeck.fightSource == "sandbox" or Holodeck.fightSource == "save" then
                Holodeck.clock = Holodeck.playT
            end

            local mode = Holodeck.playMode or "once"
            if Holodeck.playT >= dur then
                if mode == "loop" then
                    Holodeck.playT = Holodeck.playT - dur
                    Holodeck._lastPhaseAnnounced = nil
                else
                    -- once: park at end
                    Holodeck.playT = dur
                    Holodeck.playing = false
                    Holodeck.playFinished = true
                    dhd("Play once finished — actors stay at end. /hd play once|loop to restart from start.")
                end
            end
            ApplyTimeline(Holodeck.playT, true)
        else
            for _, act in pairs(Holodeck.actors) do
                if act.visible ~= false then PlaceActor(act) end
            end
            if Holodeck.origin then EnsureOriginMarker() end
        end
        -- light legend refresh while playing (never force-show if user turned it off)
        if (Holodeck.playing or Holodeck.playFinished) and IsLegendOn() and Holodeck.legendLabel then
            Holodeck.legendLabel:SetText(LegendText())
        end
    end)
    Holodeck._tickRunning = true
end

-- ============================= Commands =================================
local function CmdPlant()
    local _, x, y, z = GetUnitRawWorldPosition("player")
    if not x then dhd("Could not read position.") return end
    local had = HasSandboxStops()
    Holodeck.origin = { x = x, y = y, z = z }
    Holodeck.playing = false
    Holodeck.playFinished = false
    Holodeck.playT = 0
    if had then
        -- Stops are relative to origin — a new plant invalidates them.
        ClearStops(true)
        Holodeck.workingName = "sandbox"
        Holodeck.fight = nil
        Holodeck.fightSource = nil
        Holodeck.loadedId = nil
        dhd("New plant — sandbox path cleared (old stops were relative to previous zero).")
        dhd("  Re-open: |cC0E0FF/hd open last|r  or  |cC0E0FF/hd open 1|r  ·  /hd saves")
    else
        -- Do NOT auto-load house_demo on plant (that made "open last" look like the demo).
        -- Explicit demo: /hd load house_demo  ·  /hd demo  ·  /hd new
        if Holodeck.fightSource == "library" then
            -- keep library pack so plant-then-play still works for /hd load
        else
            Holodeck.fight = nil
            Holodeck.fightSource = nil
        end
    end
    EnsureOriginMarker()
    _StartTick()
    RebuildPathGfx()
    RefreshUI()
    dhd("Planted |cFFEE55origin / coord ZERO|r at your feet.")
    dhd("Open a save: /hd open last | /hd open 1  ·  Demo: /hd load house_demo  ·  Author: /hd edit · stopadd")
end

local function CmdEdit(arg)
    local name = (arg or ""):match("^(%S+)")
    if not name then
        dhd("Editing: " .. tostring(Holodeck.editName) .. "  — /hd edit <name>  e.g. boss, lieutenant, stack_main")
        return
    end
    Holodeck.editName = string.lower(name)
    Holodeck.types[Holodeck.editName] = Holodeck.types[Holodeck.editName] or InferType(Holodeck.editName)
    dhd("Now editing path for |cC0E0FF" .. Holodeck.editName .. "|r (type " .. Holodeck.types[Holodeck.editName] .. ")")
    RefreshUI()
end

local function CmdClock(arg)
    local n = tonumber(arg)
    if not n or n < 0 then
        dhd(string.format("Clock is %.2fs.  /hd clock <sec> sets absolute time.  /hd clock+ <sec> adds.", Holodeck.clock or 0))
        return
    end
    Holodeck.clock = n
    Holodeck.playT = n
    Holodeck.playFinished = false
    if Holodeck.fight then ApplyTimeline(n, false) end
    dhd(string.format("Clock set to %.2fs (absolute).", n))
    RefreshUI()
end

local function CmdClockPlus(arg)
    local n = tonumber(arg)
    if not n then
        dhd("Usage: /hd clock+ <sec>  e.g. /hd clock+ 10  (add to current clock)")
        return
    end
    CmdClock(tostring((Holodeck.clock or 0) + n))
end

-- mode: nil/"walk" = distance travel; "snap" = true 0s travel (teleport/leap)
local function CmdStopAdd(arg, mode)
    if not Holodeck.origin then dhd("Plant origin first: /hd plant") return end
    mode = mode or "walk"
    local name = (arg or ""):match("^(%S+)") or Holodeck.editName or "boss"
    name = string.lower(name)
    Holodeck.editName = name
    local typ = Holodeck.types[name] or InferType(name)
    Holodeck.types[name] = typ

    local lx, lz = PlayerLocalXZ()
    if not lx then dhd("No player position.") return end

    local nowMs = GetFrameTimeMilliseconds() or 0
    local list = Holodeck.stops[name]
    if not list then list = {} Holodeck.stops[name] = list end

    local t
    local prev = LastStop(name)
    local travelSec = 0
    if mode == "snap" then
        -- True 0s teleport: next arrive = previous leave (or epsilon if hold was 0 so we don't replace)
        local leave = 0
        if prev then
            leave = (prev.t or 0) + (prev.hold or 0)
            t = leave
            -- Same t as previous stop would replace it — keep a new stop with 0-span snap
            if math.abs(t - (prev.t or 0)) < 0.0001 then
                t = (prev.t or 0) + 0.001
            end
        else
            t = Holodeck.clock or 0
        end
        -- Delayed snap only if clock is clearly later (user set clock intentionally)
        if (Holodeck.clock or 0) > leave + 0.05 then
            t = Holodeck.clock
            travelSec = 0  -- still snap: no walk lerp even if clock delayed
        else
            Holodeck.clock = t
            travelSec = 0
        end
    else
        -- Hybrid: default travel = distance / PATH_SPEED
        travelSec = MIN_TRAVEL_SEC
        if prev and prev.x ~= nil then
            local dx = lx - (prev.x or 0)
            local dz = lz - (prev.z or 0)
            local dist = math.sqrt(dx * dx + dz * dz)
            travelSec = math.max(MIN_TRAVEL_SEC, dist / PATH_SPEED_M_S)
        end
        if prev then
            local minNext = (prev.t or 0) + (prev.hold or 0) + MIN_TRAVEL_SEC
            local autoT = (prev.t or 0) + (prev.hold or 0) + travelSec
            if (Holodeck.clock or 0) > minNext + 0.05 then
                t = Holodeck.clock
                travelSec = math.max(0, t - ((prev.t or 0) + (prev.hold or 0)))
            else
                t = autoT
                Holodeck.clock = t
            end
            if t < minNext then t = minNext Holodeck.clock = t end
        else
            t = Holodeck.clock or 0
            travelSec = 0
        end
    end

    local stop = { t = round2(t), x = lx, z = lz, hold = 0, visible = true, snap = (mode == "snap") }
    local replaced = false
    -- Only replace same-t if same mode intent and very close position (re-mark), not snap over walk
    for i = 1, #list do
        local old = list[i]
        if math.abs((old.t or 0) - stop.t) < 0.0005 then
            local odx = (old.x or 0) - lx
            local odz = (old.z or 0) - lz
            if (odx * odx + odz * odz) < 0.25 or mode ~= "snap" then
                list[i] = stop
                replaced = true
                break
            else
                stop.t = round2((stop.t or 0) + 0.001)
            end
        end
    end
    if not replaced then list[#list + 1] = stop end
    SortStops(list)
    Holodeck._lastStopAddMs = nowMs
    Holodeck.workingName = Holodeck.workingName or "sandbox"
    if Holodeck.workingName ~= "sandbox" and Holodeck.fightSource == "library" then
        Holodeck.workingName = "sandbox"
    end

    local act = EnsureActor(name, typ)
    if act then act.x, act.z, act.visible = lx, lz, true PlaceActor(act) end
    EnsureOriginMarker()
    RebuildPathGfx()
    PreferPlayFight()
    ApplyTimeline(Holodeck.clock or t, false)
    _StartTick()
    if mode == "snap" then
        dhd(string.format(
            "SNAP |cC0E0FF%s|r #%d  t=%.2f  x=%.2f z=%.2f  travel=0s (teleport)  hold=0",
            name, #list, stop.t, lx, lz))
    else
        dhd(string.format(
            "Stop |cC0E0FF%s|r #%d  t=%.2f  x=%.2f z=%.2f  travel~%.1fs  hold=0  (/hd hold <sec> · /hd snap · /hd undo)",
            name, #list, stop.t, lx, lz, travelSec))
    end
    RefreshUI()
end

local function CmdSnap(arg)
    CmdStopAdd(arg, "snap")
end

local function CmdUndo(arg)
    if not HasSandboxStops() then
        dhd("Nothing to undo.")
        return
    end
    local name = (arg or ""):match("^(%S+)")
    if name then
        name = string.lower(name)
    else
        name = Holodeck.editName or "boss"
    end
    local list = Holodeck.stops[name]
    if not list or #list == 0 then
        -- fall back: undo last stop of any actor (most recent by t)
        local bestName, bestI, bestT = nil, nil, -1
        for n, lst in pairs(Holodeck.stops) do
            if lst and #lst > 0 then
                local s = lst[#lst]
                if (s.t or 0) >= bestT then
                    bestT = s.t or 0
                    bestName = n
                    bestI = #lst
                end
            end
        end
        if not bestName then dhd("Nothing to undo.") return end
        name = bestName
        list = Holodeck.stops[name]
    end
    local removed = table.remove(list)
    if #list == 0 then Holodeck.stops[name] = nil end
    if removed then
        Holodeck.clock = removed.t or Holodeck.clock
        dhd(string.format("Undo |cC0E0FF%s|r stop at t=%.2f (x=%.1f z=%.1f). stops left=%d",
            name, removed.t or 0, removed.x or 0, removed.z or 0, list and #list or 0))
    end
    -- hide actor if no stops left for them
    if not Holodeck.stops[name] and Holodeck.actors[name] then
        Holodeck.actors[name].visible = false
        PlaceActor(Holodeck.actors[name])
    end
    RebuildPathGfx()
    PreferPlayFight()
    ApplyTimeline(Holodeck.clock or 0, false)
    RefreshUI()
end

local function CmdHold(arg)
    local n = tonumber(arg)
    if not n or n < 0 then
        dhd("Usage: /hd hold <sec>  — pause at last stop of current edit name")
        return
    end
    local name = Holodeck.editName or "boss"
    local s = LastStop(name)
    if not s then
        dhd("No stop yet for " .. name .. " — /hd stopadd first")
        return
    end
    s.hold = round2(n)
    -- advance clock to end of this hold for next stop convenience
    Holodeck.clock = (s.t or 0) + s.hold
    PreferPlayFight()
    RebuildPathGfx()
    dhd(string.format("Hold %.2fs at %s t=%.2f (clock now %.2fs for next stop)", s.hold, name, s.t or 0, Holodeck.clock))
    RefreshUI()
end

local function CmdStopHide(arg)
    if not Holodeck.origin then dhd("Plant first: /hd plant") return end
    local name = (arg or ""):match("^(%S+)") or Holodeck.editName or "boss"
    name = string.lower(name)
    Holodeck.editName = name
    Holodeck.types[name] = Holodeck.types[name] or InferType(name)
    if not Holodeck.stops[name] then Holodeck.stops[name] = {} end
    local t = Holodeck.clock or 0
    local list = Holodeck.stops[name]
    local stop = { t = round2(t), visible = false, hold = 0 }
    list[#list + 1] = stop
    SortStops(list)
    PreferPlayFight()
    RebuildPathGfx()
    dhd(string.format("Hide |cC0E0FF%s|r at t=%.2f", name, t))
    RefreshUI()
end

local function CmdType(arg)
    local name, typ = arg:match("^(%S+)%s+(%S+)")
    if not name or not typ then
        dhd("Usage: /hd type <name> <kind>")
        dhd("  enemies: boss mini trash")
        dhd("  roles:   tank healer dps")
        dhd("  spots:   stack soak safe portal")
        dhd("  palette: /hd textures")
        return
    end
    name = string.lower(name)
    typ = NormalizeKind(typ)
    if not typ or not KIND[typ] then
        dhd("Unknown kind. /hd textures for the full palette.")
        return
    end
    Holodeck.types[name] = typ
    EnsureActor(name, typ)
    local def = KIND[typ]
    dhd(string.format("%s type = |cC0E0FF%s|r (%s)", name, typ, def.label or typ))
    RebuildPathGfx()
    RefreshUI()
end

local function CmdPlay(arg)
    if not Holodeck.origin then dhd("Plant first: /hd plant") return end
    arg = (arg or ""):lower():match("^%s*(%S*)") or ""
    if arg == "once" or arg == "loop" then
        Holodeck.playMode = arg
        if Holodeck.savedVars then Holodeck.savedVars.playMode = arg end
    end
    if not PreferPlayFight() then dhd("Nothing to play.") return end

    -- Restart from beginning when starting play
    Holodeck.playT = 0
    Holodeck.playFinished = false
    Holodeck._lastPhaseAnnounced = nil
    Holodeck.playing = true
    ApplyTimeline(0, true)
    _StartTick()
    local mode = Holodeck.playMode or "once"
    dhd(string.format("Playing \"%s\" [%s] mode=%s. Once parks at end; loop repeats.",
        Holodeck.fight.name or "?", Holodeck.fightSource or "?", mode))
    RefreshUI()
end

local function CmdMode(arg)
    arg = (arg or ""):lower():match("^(%S+)")
    if arg ~= "once" and arg ~= "loop" then
        dhd("Play mode: " .. tostring(Holodeck.playMode) .. "  — /hd mode once|loop")
        return
    end
    Holodeck.playMode = arg
    if Holodeck.savedVars then Holodeck.savedVars.playMode = arg end
    dhd("Play mode = " .. arg)
    RefreshUI()
end

local function CmdPause()
    if not Holodeck.playing then dhd("Not playing.") return end
    Holodeck.playing = false
    dhd(string.format("Paused t=%.1fs", Holodeck.playT or 0))
    RefreshUI()
end

local function CmdReplay()
    if not Holodeck.origin then dhd("Plant first.") return end
    Holodeck.playT = 0
    Holodeck.playFinished = false
    Holodeck._lastPhaseAnnounced = nil
    if PreferPlayFight() then ApplyTimeline(0, true) end
    dhd("Replay position t=0 (start). /hd play to run.")
    RefreshUI()
end

local function CmdHalt()
    Holodeck.playing = false
    -- keep current positions (do not jump home)
    dhd(string.format("Halted at t=%.1fs (poses stay). /hd replay then /hd play to restart from start.", Holodeck.playT or 0))
    RefreshUI()
end

local function CmdPath(arg)
    arg = (arg or ""):lower()
    if arg == "on" then sv().pathOn = true
    elseif arg == "off" then sv().pathOn = false
    else sv().pathOn = not sv().pathOn end
    if Holodeck.savedVars then Holodeck.savedVars.pathOn = sv().pathOn end
    RebuildPathGfx()
    dhd("Path rings/lines: " .. (sv().pathOn and "ON" or "OFF"))
end

local function CmdSheet(arg)
    arg = (arg or ""):lower():match("^%s*(%S*)") or ""
    if arg == "on" then
        if Holodeck.savedVars then Holodeck.savedVars.sheetOn = true end
    elseif arg == "off" then
        if Holodeck.savedVars then Holodeck.savedVars.sheetOn = false end
    else
        -- toggle
        local cur = sv().sheetOn == true
        if Holodeck.savedVars then Holodeck.savedVars.sheetOn = not cur end
    end
    UpdateSheet()
    UpdateLegend()
    dhd("Path sheet panel: |cC0E0FF" .. ((sv().sheetOn and "ON") or "OFF") .. "|r  — /hd sheet on|off")
end

local function CmdLegend(arg)
    arg = (arg or ""):lower():match("^%s*(%S*)") or ""
    if not Holodeck.savedVars then return end
    if arg == "on" then
        Holodeck.savedVars.legendOn = true
    elseif arg == "off" then
        Holodeck.savedVars.legendOn = false
    else
        Holodeck.savedVars.legendOn = not IsLegendOn()
    end
    UpdateLegend()
    dhd("Legend: |cC0E0FF" .. (IsLegendOn() and "ON" or "OFF") .. "|r  (hint stays: /hd legend on)")
end

local function CmdNew()
    ClearStops(false)
    Holodeck.workingName = "sandbox"
    Holodeck.playing = false
    Holodeck.playFinished = false
    Holodeck.playT = 0
    Holodeck.clock = 0
    if Holodeck.origin and Holodeck.Fights["house_demo"] then
        LoadFightTable(Holodeck.Fights["house_demo"], "library", true)
    end
    RebuildPathGfx()
    dhd("New SANDBOX path. Not a saved fight until /hd save <name>.")
    RefreshUI()
end

local function SerializeStops()
    local copy = { stops = {}, types = {}, name = Holodeck.workingName, version = Holodeck.version }
    for name, list in pairs(Holodeck.stops) do
        copy.stops[name] = {}
        for i = 1, #list do
            local s = list[i]
            copy.stops[name][i] = { t = s.t, x = s.x, z = s.z, hold = s.hold, visible = s.visible, snap = s.snap }
        end
    end
    for n, t in pairs(Holodeck.types) do copy.types[n] = t end
    -- Preserve meta if already set on a re-save
    return copy
end

local function LoadSerialized(data, name)
    Holodeck.stops = {}
    Holodeck.types = {}
    if not data or not data.stops then return end
    for n, list in pairs(data.stops) do
        Holodeck.stops[n] = {}
        for i = 1, #list do
            local s = list[i]
            Holodeck.stops[n][i] = { t = s.t, x = s.x, z = s.z, hold = s.hold or 0, visible = s.visible, snap = s.snap }
        end
        SortStops(Holodeck.stops[n])
    end
    if data.types then
        for n, t in pairs(data.types) do Holodeck.types[n] = t end
    end
    Holodeck.workingName = name or data.name or "sandbox"
    Holodeck.clock = 0
    Holodeck.playT = 0
    Holodeck.playFinished = false
    PreferPlayFight()
    RebuildPathGfx()
    ApplyTimeline(0, false)
end

local function CmdSave(arg)
    local name = (arg or ""):match("^(%S+)")
    if not name then
        dhd("Usage: /hd save <name>  — keep current path in SavedVars")
        return
    end
    if not HasSandboxStops() then dhd("No stops to save.") return end
    name = string.lower(name)
    if not Holodeck.savedVars.saves then Holodeck.savedVars.saves = {} end
    local data = SerializeStops()
    data.name = name
    -- Prefer a readable label (panel shows displayName, not raw id)
    if not data.displayName or data.displayName == name then
        local nEnt = 0
        for _ in pairs(Holodeck.stops or {}) do nEnt = nEnt + 1 end
        data.displayName = string.format("%s · %d tracks · %.0fs",
            name, nEnt, tonumber(Holodeck.clock) or 0)
    end
    Holodeck.savedVars.saves[name] = data
    Holodeck.savedVars.lastSaveName = name
    Holodeck.workingName = name
    dhd("Saved |cC0E0FF" .. name .. "|r  ·  " .. tostring(data.displayName))
    dhd("  /hd open " .. name .. "  ·  /hd open last  ·  /hd saves")
    RefreshUI()
end

local function BuildSavesArray()
    local s = Holodeck.savedVars and Holodeck.savedVars.saves or {}
    local arr = {}
    for name, data in pairs(s) do
        local meta = type(data) == "table" and data.meta
        local dn = type(data) == "table" and data.displayName
        arr[#arr + 1] = {
            name = name,
            display = dn,
            sort = (meta and meta.savedAt) or 0,
            dur = meta and meta.duration,
            zone = meta and meta.zone,
            target = meta and meta.target,
            dense = meta and meta.dense,
        }
    end
    table.sort(arr, function(a, b) return (a.sort or 0) > (b.sort or 0) end)
    return arr
end

-- Always refresh numbered list so /hd open 1 works without panel first.
local function RefreshSavesList()
    local arr = BuildSavesArray()
    Holodeck.savesList = {}
    for i = 1, #arr do
        Holodeck.savesList[i] = arr[i].name
    end
    return arr
end

local function ResolveSaveName(query)
    query = tostring(query or ""):lower():match("^%s*(.-)%s*$") or ""
    if query == "" then return nil, "empty" end

    local saves = Holodeck.savedVars and Holodeck.savedVars.saves or {}
    local arr = RefreshSavesList()

    if query == "last" then
        local last = Holodeck.savedVars and Holodeck.savedVars.lastSaveName
        if last and saves[last] then return last end
        if last and saves[string.lower(last)] then return string.lower(last) end
        -- Fallback: newest by savedAt
        if arr[1] then return arr[1].name end
        return nil, "no last save"
    end

    -- Exact key
    if saves[query] then return query end

    -- Index: /hd open 1
    local idx = tonumber(query)
    if idx and Holodeck.savesList[idx] then
        return Holodeck.savesList[idx]
    end

    -- Fuzzy: displayName / zone / target / partial id
    local hits = {}
    for _, e in ipairs(arr) do
        local id = string.lower(tostring(e.name or ""))
        local dn = string.lower(tostring(e.display or ""))
        local zone = string.lower(tostring(e.zone or ""))
        local tgt = string.lower(tostring(e.target or ""))
        if id == query or dn == query then
            return e.name
        end
        if id:find(query, 1, true) or dn:find(query, 1, true)
            or zone:find(query, 1, true) or tgt:find(query, 1, true) then
            hits[#hits + 1] = e
        end
    end
    if #hits == 1 then return hits[1].name end
    if #hits > 1 then
        dhd("Multiple saves match |cC0E0FF" .. query .. "|r — use number:")
        for i = 1, math.min(8, #hits) do
            local e = hits[i]
            -- find index in full list
            local n = 0
            for j = 1, #arr do if arr[j].name == e.name then n = j break end end
            d(string.format("  %d  %s", n > 0 and n or i, e.display or e.name))
        end
        return nil, "ambiguous"
    end
    return nil, "not found"
end

local function CmdOpen(arg)
    local raw = (arg or ""):match("^(%S+)")
    if not raw then
        dhd("Usage: /hd open <#>|last|<id>  — YOUR saves (not library). /hd saves")
        dhd("  Example: /hd open 1   ·  /hd open last   ·  /hd open ossair")
        return
    end
    local name, err = ResolveSaveName(raw)
    if not name then
        if err == "ambiguous" then return end
        dhd("No save for |cC0E0FF" .. tostring(raw) .. "|r  ·  /hd saves  (use the number on the left)")
        return
    end
    local data = Holodeck.savedVars.saves[name]
    if not data then dhd("Save missing data for " .. name) return end
    if not Holodeck.origin then
        dhd("Plant origin first: |cC0E0FF/hd plant|r  then  |cC0E0FF/hd open " .. name .. "|r")
        return
    end
    -- Drop library demo so playback uses the opened save
    Holodeck.fight = nil
    Holodeck.fightSource = nil
    Holodeck.loadedId = nil
    LoadSerialized(data, name)
    if Holodeck.savedVars then Holodeck.savedVars.lastSaveName = name end
    Holodeck.workingName = name
    local dn = data.displayName or name
    dhd("Opened |cC0E0FF#" .. tostring(raw) .. "|r → " .. name)
    d("  " .. tostring(dn))
    if not HasSandboxStops() then
        dhd("|cFF5555Save has no stops|r — recording may have been empty.")
    else
        dhd("/hd play once  ·  /hd sheet on  ·  stops=" .. tostring(CountStops()))
    end
    RefreshUI()
end

Holodeck.savesList = Holodeck.savesList or {} -- ordered ids for /hd open 1..n
Holodeck.savesPanel = nil
Holodeck.savesPanelLabel = nil

local function PrettySaveTitle(e, maxLen)
    maxLen = maxLen or 56
    if e.display and e.display ~= "" and e.display ~= e.name then
        local t = tostring(e.display)
        if #t > maxLen then t = t:sub(1, maxLen - 2) .. ".." end
        return t
    end
    if e.zone and e.zone ~= "" and e.zone ~= "?" then
        local tgt = (e.target and e.target ~= "" and e.target ~= "fight") and e.target or "fight"
        local dur = e.dur and string.format("%.0fs", tonumber(e.dur) or 0) or nil
        local t = string.format("%s · %s", e.zone, tgt)
        if dur then t = t .. " · " .. dur end
        if #t > maxLen then t = t:sub(1, maxLen - 2) .. ".." end
        return t
    end
    local n = tostring(e.name or "save")
    if #n > maxLen then n = n:sub(1, maxLen - 2) .. ".." end
    return n
end

-- Two lines per save: human title + how to open (number is the primary key).
local function SavesPanelText()
    local arr = RefreshSavesList()
    local lines = {
        "SAVED FIGHTS  (newest first)",
        "Open by NUMBER:  /hd open 1",
        "Also: /hd open last   ·  close: /hd saves off",
        "------------------------------",
    }
    if #arr == 0 then
        lines[#lines + 1] = "(none yet — record + autosave, or /hd save name)"
    else
        for i = 1, math.min(10, #arr) do
            local e = arr[i]
            local title = PrettySaveTitle(e, 52)
            local mode = e.dense and "dense" or "lean"
            lines[#lines + 1] = string.format("%2d) %s", i, title)
            -- Short id so console users can paste if needed; number is preferred
            local id = tostring(e.name or "")
            if #id > 42 then id = id:sub(1, 40) .. ".." end
            lines[#lines + 1] = string.format("    /hd open %d   [%s]", i, mode)
            lines[#lines + 1] = string.format("    id: %s", id)
        end
        if #arr > 10 then
            lines[#lines + 1] = string.format("... +%d more  (/hd saves chat)", #arr - 10)
        end
    end
    lines[#lines + 1] = "------------------------------"
    lines[#lines + 1] = "Library (not a save): /hd load house_demo"
    return table.concat(lines, "\n")
end

local function EnsureSavesPanel()
    if Holodeck.savesPanel and Holodeck.savesPanelLabel then return end
    local tlw = _SafeCreateTLW("HolodeckSavesPanel")
    if not tlw then return end
    tlw:SetMouseEnabled(true)
    tlw:SetMovable(true)
    tlw:SetClampedToScreen(true)
    tlw:SetDrawLayer(DL_OVERLAY)
    tlw:SetDrawTier(DT_HIGH)
    tlw:SetDrawLevel(410000)
    if tlw.SetTopmost then pcall(function() tlw:SetTopmost(true) end) end
    -- Wider + taller: 3 lines per save (title, open cmd, id)
    tlw:SetDimensions(560, 480)
    tlw:ClearAnchors()
    tlw:SetAnchor(CENTER, GuiRoot, CENTER, 0, -40)

    local back = _SafeCreateControl("HolodeckSavesPanelBack", tlw, CT_BACKDROP)
    if back then
        back:SetAnchorFill()
        back:SetCenterColor(0, 0, 0, 0.94)
        back:SetEdgeColor(0.45, 0.75, 1, 0.95)
        if back.SetEdgeTexture then pcall(function() back:SetEdgeTexture(nil, 1, 1, 2) end) end
    end

    local lbl = _SafeCreateControl("HolodeckSavesPanelLabel", tlw, CT_LABEL)
    if lbl then
        lbl:ClearAnchors()
        lbl:SetAnchor(TOPLEFT, tlw, TOPLEFT, 16, 12)
        lbl:SetDimensions(528, 452)
        lbl:SetFont("EsoUI/Common/Fonts/univers57.otf|14|soft-shadow-thin")
        lbl:SetColor(0.95, 0.97, 1, 1)
        if TEXT_ALIGN_LEFT then lbl:SetHorizontalAlignment(TEXT_ALIGN_LEFT) end
        if TEXT_ALIGN_TOP then lbl:SetVerticalAlignment(TEXT_ALIGN_TOP) end
        if lbl.SetWrapMode and TEXT_WRAP_MODE_ELLIPSIS then
            pcall(function() lbl:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) end)
        end
        lbl:SetMouseEnabled(false)
    end
    Holodeck.savesPanel = tlw
    Holodeck.savesPanelLabel = lbl
    tlw:SetHidden(true)
end

local function ShowSavesPanel(show)
    EnsureSavesPanel()
    if not Holodeck.savesPanel then return end
    if show then
        if Holodeck.savesPanelLabel then
            Holodeck.savesPanelLabel:SetText(SavesPanelText())
            Holodeck.savesPanelLabel:SetDimensions(528, 452)
        end
        Holodeck.savesPanel:SetHidden(false)
        Holodeck.savesPanel:SetAlpha(1)
        zo_callLater(function()
            if Holodeck.savesPanel and not Holodeck.savesPanel:IsHidden() then
                Holodeck.savesPanel:SetHidden(false)
            end
        end, 50)
    else
        Holodeck.savesPanel:SetHidden(true)
    end
end

Holodeck.ShowSavesPanel = ShowSavesPanel

local function CmdSaves(arg)
    arg = (arg or ""):lower():match("^%s*(%S*)") or ""
    if arg == "off" or arg == "close" or arg == "hide" then
        ShowSavesPanel(false)
        dhd("Saves panel closed.")
        return
    end
    if arg == "chat" then
        local arr = BuildSavesArray()
        dhd("Saves (chat) — /hd open 1 | last | <id>")
        for i = 1, math.min(14, #arr) do
            d(string.format("  %d. %s", i, PrettySaveTitle(arr[i])))
            d(string.format("     id=%s", arr[i].name))
        end
        return
    end
    -- default: popup panel
    ShowSavesPanel(true)
    dhd("Saves panel open — /hd open 1 .. n  or  /hd open last  ·  /hd saves off to close")
end

-- ============================= Texture palette panel ====================
Holodeck.texPanel = nil
Holodeck.texPanelLabel = nil

local function TexturesPanelText()
    local lines = {
        "HOLODECK TEXTURE PALETTE  v" .. Holodeck.version,
        "World pins use these kinds. Set with /hd type <name> <kind>",
        "Name hints also work: tank_mt, healer_1, soak_A, …",
        "--------------------------------",
        "ENEMIES (record / packs)",
    }
    local groups = {
        { key = "enemy", title = nil }, -- header already printed
        { key = "role", title = "ROLES (manual now · team/demo later)" },
        { key = "spot", title = "SPOTS (walkthrough markers)" },
        { key = "system", title = "SYSTEM" },
    }
    for _, g in ipairs(groups) do
        if g.title then
            lines[#lines + 1] = "--------------------------------"
            lines[#lines + 1] = g.title
        end
        for _, k in ipairs(KIND_ORDER) do
            local def = KIND[k]
            if def and def.group == g.key then
                local c = def.color or { 1, 1, 1 }
                local col = string.format("|c%02X%02X%02X",
                    math.floor((c[1] or 1) * 255),
                    math.floor((c[2] or 1) * 255),
                    math.floor((c[3] or 1) * 255))
                lines[#lines + 1] = string.format("  %s●|r %-8s  %s", col, k, def.label or k)
            end
        end
    end
    lines[#lines + 1] = "--------------------------------"
    lines[#lines + 1] = "Workflow example (raid lead demo):"
    lines[#lines + 1] = "  /hd load house_demo   (boss + LT + roles)"
    lines[#lines + 1] = "  /hd edit tank_mt"
    lines[#lines + 1] = "  /hd type tank_mt tank"
    lines[#lines + 1] = "  walk path → /hd stopadd  ·  /hd hold 3"
    lines[#lines + 1] = "  /hd edit healer_1 · type healer · stopadd…"
    lines[#lines + 1] = "  /hd play once"
    lines[#lines + 1] = "--------------------------------"
    lines[#lines + 1] = "Roles use DM2-style pack icons (hd_tank/healer/dps)."
    lines[#lines + 1] = "Enemies/spots use stock ESO POI (SPACE_WORLD safe)."
    lines[#lines + 1] = "Close: /hd textures off"
    return table.concat(lines, "\n")
end

local function EnsureTexturesPanel()
    if Holodeck.texPanel and Holodeck.texPanelLabel then return end
    local tlw = _SafeCreateTLW("HolodeckTexturesPanel")
    if not tlw then return end
    tlw:SetMouseEnabled(true)
    tlw:SetMovable(true)
    tlw:SetClampedToScreen(true)
    tlw:SetDrawLayer(DL_OVERLAY)
    tlw:SetDrawTier(DT_HIGH)
    tlw:SetDrawLevel(411000)
    if tlw.SetTopmost then pcall(function() tlw:SetTopmost(true) end) end
    tlw:SetDimensions(520, 460)
    tlw:ClearAnchors()
    tlw:SetAnchor(CENTER, GuiRoot, CENTER, 40, -30)

    local back = _SafeCreateControl("HolodeckTexturesPanelBack", tlw, CT_BACKDROP)
    if back then
        back:SetAnchorFill()
        back:SetCenterColor(0, 0, 0, 0.94)
        back:SetEdgeColor(0.95, 0.65, 0.25, 0.95)
        if back.SetEdgeTexture then pcall(function() back:SetEdgeTexture(nil, 1, 1, 2) end) end
    end

    local lbl = _SafeCreateControl("HolodeckTexturesPanelLabel", tlw, CT_LABEL)
    if lbl then
        lbl:ClearAnchors()
        lbl:SetAnchor(TOPLEFT, tlw, TOPLEFT, 16, 14)
        lbl:SetDimensions(488, 430)
        lbl:SetFont("EsoUI/Common/Fonts/univers57.otf|15|soft-shadow-thin")
        lbl:SetColor(0.95, 0.97, 1, 1)
        if TEXT_ALIGN_LEFT then lbl:SetHorizontalAlignment(TEXT_ALIGN_LEFT) end
        if TEXT_ALIGN_TOP then lbl:SetVerticalAlignment(TEXT_ALIGN_TOP) end
        lbl:SetMouseEnabled(false)
    end
    Holodeck.texPanel = tlw
    Holodeck.texPanelLabel = lbl
    tlw:SetHidden(true)
end

local function ShowTexturesPanel(show)
    EnsureTexturesPanel()
    if not Holodeck.texPanel then return end
    if show then
        if Holodeck.texPanelLabel then
            Holodeck.texPanelLabel:SetText(TexturesPanelText())
        end
        Holodeck.texPanel:SetHidden(false)
        Holodeck.texPanel:SetAlpha(1)
    else
        Holodeck.texPanel:SetHidden(true)
    end
end
Holodeck.ShowTexturesPanel = ShowTexturesPanel

local function CmdTextures(arg)
    arg = (arg or ""):lower():match("^%s*(%S*)") or ""
    if arg == "off" or arg == "close" or arg == "hide" then
        ShowTexturesPanel(false)
        dhd("Texture palette closed.")
        return
    end
    if arg == "chat" then
        dhd("Kinds:")
        for _, k in ipairs(KIND_ORDER) do
            local def = KIND[k]
            if def then
                d(string.format("  %-8s  %-10s  %s", k, def.group or "?", def.label or k))
            end
        end
        return
    end
    ShowTexturesPanel(true)
    dhd("Texture palette open — /hd textures off to close · /hd type name kind")
end

local function CmdExport()
    if not HasSandboxStops() then
        dhd("No stops. Build with /hd stopadd first.")
        return
    end
    local lines = {
        string.format("-- Holodeck export '%s' v%s", Holodeck.workingName or "sandbox", Holodeck.version),
        "-- Paste into fights/<name>.lua offline. Holds are authoring hints; convert to keyframes as needed.",
        "entities = {",
    }
    local names = {}
    for n in pairs(Holodeck.stops) do names[#names + 1] = n end
    table.sort(names)
    for _, name in ipairs(names) do
        local typ = Holodeck.types[name] or InferType(name)
        typ = NormalizeKind(typ) or typ
        -- Prefer canonical kinds (mini not miniboss); packs still accept miniboss alias
        local kindOut = typ
        lines[#lines + 1] = string.format('  { id = "%s", kind = "%s", label = "%s", track = {', name, kindOut, name)
        local list = Holodeck.stops[name]
        for i = 1, #list do
            local s = list[i]
            if s.visible == false then
                lines[#lines + 1] = string.format("    { t = %s, visible = false },", tostring(round2(s.t)))
            else
                lines[#lines + 1] = string.format(
                    "    { t = %s, x = %s, z = %s, hold = %s, visible = true },",
                    tostring(round2(s.t)), tostring(round2(s.x)), tostring(round2(s.z)), tostring(round2(s.hold or 0)))
            end
            -- emit leave keyframe for hold (so library packs without hold still pause-ish)
            if (s.hold or 0) > 0 and s.visible ~= false then
                lines[#lines + 1] = string.format(
                    "    { t = %s, x = %s, z = %s, visible = true },  -- end hold",
                    tostring(round2((s.t or 0) + (s.hold or 0))), tostring(round2(s.x)), tostring(round2(s.z)))
            end
        end
        lines[#lines + 1] = "  } },"
    end
    lines[#lines + 1] = "}"
    local text = table.concat(lines, "\n")
    if Holodeck.savedVars then Holodeck.savedVars.lastExport = text end
    dhd("--- export (also in SavedVars) ---")
    for line in string.gmatch(text .. "\n", "(.-)\n") do d(line) end
    dhd("--- end export ---")
end

local function CmdList()
    dhd("Library packs (shipped):")
    for id, f in pairs(Holodeck.Fights) do
        d(string.format("  %s — %s", id, f.name or id))
    end
    dhd("Working: " .. tostring(Holodeck.workingName) .. " | Your saves: /hd saves")
end

local function CmdLoad(arg)
    local id = (arg or ""):match("^(%S+)")
    if not id then dhd("Usage: /hd load <pack>  — library only. Your saves: /hd open <name>") return end
    if not Holodeck.origin then dhd("Plant first: /hd plant") return end
    local f = Holodeck.Fights[id]
    if not f then dhd("Unknown library pack. /hd list") return end
    Holodeck.playing = false
    LoadFightTable(f, "library", true)
    -- path gfx from library? skip for now
    ClearPathGfx()
    dhd("Loaded library |cC0E0FF" .. id .. "|r (does not change your sandbox saves).")
    RefreshUI()
end

local function CmdClear()
    Holodeck.playing = false
    Holodeck.playFinished = false
    Holodeck.origin = nil
    Holodeck.fight = nil
    Holodeck.workingName = "sandbox"
    ClearStops(true)
    ClearPathGfx()
    DestroyAllActors()
    _StopTick()
    dhd("Full clear.")
    RefreshUI()
end

local function CmdStatus()
    dhd(string.format("v%s work=%s origin=%s clock=%.1f edit=%s stops=%d playMode=%s playing=%s t=%.1f",
        Holodeck.version, Holodeck.workingName, Holodeck.origin and "yes" or "no",
        Holodeck.clock or 0, Holodeck.editName, CountStops(), Holodeck.playMode,
        tostring(Holodeck.playing), Holodeck.playT or 0))
end

local function CmdHelp()
    dhd("v" .. Holodeck.version .. " — actions in chat; prefs in /hdsettings (LAM).")
    d("|cAADDFFRECORD|r  arm · disarm · record start|stop|probe · tag (reticle elite)")
    d("|cAADDFFMANUAL|r  plant · edit · type · stopadd · snap · hold · undo · clock · save")
    d("|cAADDFFPLAY|r    play once|loop · open last · load house_demo · sheet · path")
    d("|cAADDFFLOOK|r    textures (palette) · saves · sheet · legend")
    d("|cAADDFFSHARE|r   share offer · consumers plant+open+play")
    d("|cAADDFFPREFS|r   /hdsettings")
    d("Kinds: boss mini trash | tank healer dps | stack soak safe portal  — /hd textures")
    d("open = your saves · load = library packs · plant = coord ZERO")
end

local function OnSlash(args)
    args = args or ""
    local cmd, rest = args:match("^(%S+)%s*(.-)$")
    cmd = (cmd or ""):lower()
    rest = rest or ""

    local map = {
        help = CmdHelp, ["?"] = CmdHelp,
        plant = CmdPlant, origin = CmdPlant, pin = CmdPlant, set = CmdPlant,
        edit = function() CmdEdit(rest) end, ent = function() CmdEdit(rest) end,
        clock = function() CmdClock(rest) end, t = function() CmdClock(rest) end,
        ["clock+"] = function() CmdClockPlus(rest) end, ["t+"] = function() CmdClockPlus(rest) end,
        tplus = function() CmdClockPlus(rest) end,
        stopadd = function() CmdStopAdd(rest, "walk") end, mark = function() CmdStopAdd(rest, "walk") end, m = function() CmdStopAdd(rest, "walk") end,
        sample = function() CmdStopAdd(rest, "walk") end,
        snap = function() CmdSnap(rest) end, teleport = function() CmdSnap(rest) end, tp = function() CmdSnap(rest) end,
        undo = function() CmdUndo(rest) end, back = function() CmdUndo(rest) end,
        hold = function() CmdHold(rest) end,
        stophide = function() CmdStopHide(rest) end, markhide = function() CmdStopHide(rest) end, hide = function() CmdStopHide(rest) end,
        type = function() CmdType(rest) end,
        kind = function() CmdType(rest) end,
        play = function() CmdPlay(rest) end,
        mode = function() CmdMode(rest) end,
        pause = CmdPause,
        replay = CmdReplay, restart = CmdReplay,
        halt = CmdHalt, stop = CmdHalt,
        path = function() CmdPath(rest) end,
        sheet = function() CmdSheet(rest) end,
        legend = function() CmdLegend(rest) end,
        textures = function() CmdTextures(rest) end,
        texture = function() CmdTextures(rest) end,
        palette = function() CmdTextures(rest) end,
        kinds = function() CmdTextures(rest) end,
        new = CmdNew,
        save = function() CmdSave(rest) end,
        open = function() CmdOpen(rest) end,
        saves = function() CmdSaves(rest) end,
        fights = function() CmdSaves(rest) end,
        export = CmdExport, dump = CmdExport,
        list = CmdList, packs = CmdList,
        load = function() CmdLoad(rest) end,
        demo = function() CmdLoad("house_demo") end,
        clear = CmdClear,
        wipe = function() ClearStops(false) RebuildPathGfx() RefreshUI() end,
        markclear = function() ClearStops(false) RebuildPathGfx() RefreshUI() end,
        status = CmdStatus, st = CmdStatus,
        arm = function() if Holodeck.CmdArm then Holodeck.CmdArm() end end,
        disarm = function() if Holodeck.CmdDisarm then Holodeck.CmdDisarm() end end,
        record = function() if Holodeck.CmdRecord then Holodeck.CmdRecord(rest) end end,
        rec = function() if Holodeck.CmdRecord then Holodeck.CmdRecord(rest) end end,
        tag = function() if Holodeck.CmdTag then Holodeck.CmdTag(rest) end end,
        share = function() if Holodeck.CmdShare then Holodeck.CmdShare(rest) end end,
        settings = function()
            dhd("Open settings: |cC0E0FF/hdsettings|r  (or Esc → Addons → DeadMarker Holodeck)")
            -- LAM opens via its own slash; try common open patterns
            pcall(function()
                if LibAddonMenu2 and LibAddonMenu2.OpenToPanel then
                    LibAddonMenu2:OpenToPanel("HolodeckSettingsPanel")
                end
            end)
        end,
        debug = function()
            if Holodeck.savedVars then
                Holodeck.savedVars.debug = not Holodeck.savedVars.debug
                dhd("debug=" .. tostring(Holodeck.savedVars.debug))
            end
        end,
    }

    if cmd == "" then CmdHelp() return end
    local fn = map[cmd]
    if fn then fn() else dhd("Unknown: /hd " .. cmd) CmdHelp() end
end

-- ============================= Lifecycle ================================
local function OnAddOnLoaded(_, addonName)
    if addonName ~= Holodeck.name then return end
    EVENT_MANAGER:UnregisterForEvent(Holodeck.name, EVENT_ADD_ON_LOADED)

    Holodeck.savedVars = ZO_SavedVars:NewAccountWide("HolodeckVars", 3, nil, DEFAULTS)
    local s = Holodeck.savedVars
    if s.playMode then Holodeck.playMode = s.playMode end
    if s.bossSizeM then KIND.boss.sizeM = s.bossSizeM end
    if s.legendOn == nil then s.legendOn = true end
    if s.pathOn == nil then s.pathOn = true end
    if s.autoArmInInstances == nil then s.autoArmInInstances = true end
    if s.recordStartMode == nil then s.recordStartMode = "boss" end
    if s.recordAutoStop == nil then s.recordAutoStop = true end
    if s.recordAutoSave == nil then s.recordAutoSave = false end
    if s.recordIntervalMs == nil then s.recordIntervalMs = 400 end
    if s.recordCaptureBosses == nil then s.recordCaptureBosses = true end
    if s.recordCaptureSelf == nil then s.recordCaptureSelf = false end
    if s.recordCaptureTeam == nil then s.recordCaptureTeam = false end
    if s.recordCaptureElites == nil then s.recordCaptureElites = true end
    if s.recordEliteTier == nil then s.recordEliteTier = 4 end
    -- Migrate: old "tier 0 = off" stacked with checkbox; if elites ON, force tier 4
    if tonumber(s.recordEliteTier) == 0 and s.recordCaptureElites ~= false then
        s.recordEliteTier = 4
    end
    if s.recordRequirePlant == nil then s.recordRequirePlant = false end
    if s.shareReceiveEnabled == nil then s.shareReceiveEnabled = true end
    if not s.saves then s.saves = {} end
    -- Backfill displayName on legacy rec_* saves so the panel is readable
    for name, data in pairs(s.saves) do
        if type(data) == "table" and (not data.displayName or data.displayName == "") then
            if data.meta and data.meta.zone then
                data.displayName = string.format("%s · %s · %.0fs",
                    tostring(data.meta.zone),
                    tostring(data.meta.target or "fight"),
                    tonumber(data.meta.duration) or 0)
            else
                data.displayName = tostring(name)
            end
        end
    end

    -- Export helpers for Holodeck_Record / Settings (loaded after this file)
    Holodeck.EnsureOriginMarker = EnsureOriginMarker
    Holodeck.RebuildPathGfx = RebuildPathGfx
    Holodeck.ApplyTimeline = ApplyTimeline
    Holodeck.RefreshUI = RefreshUI
    Holodeck.PreferPlayFight = PreferPlayFight
    Holodeck.SerializeStops = SerializeStops
    Holodeck.ApplySheetVisibility = ApplySheetVisibility

    SLASH_COMMANDS["/hd"] = OnSlash
    SLASH_COMMANDS["/holodeck"] = OnSlash

    EnsureLegend()
    EnsureSheet()
    if Holodeck.sheetTLW then Holodeck.sheetTLW:SetHidden(true) end
    UpdateLegend()
    UpdateSheet()

    pcall(function()
        EVENT_MANAGER:RegisterForEvent(Holodeck.name .. "_LayerPop", EVENT_ACTION_LAYER_POPPED, function()
            -- Always re-assert legend/sheet so OFF stays off after chat
            UpdateLegend()
            if Holodeck.savedVars and Holodeck.savedVars.sheetOn then
                ApplySheetVisibility()
                UpdateSheet()
            elseif Holodeck.sheetTLW then
                Holodeck.sheetTLW:SetHidden(true)
            end
        end)
    end)
    pcall(function()
        if SCENE_MANAGER and SCENE_MANAGER.RegisterCallback then
            SCENE_MANAGER:RegisterCallback("SceneStateChanged", function(scene, oldState, newState)
                if newState == SCENE_SHOWN or newState == SCENE_SHOWING then
                    if Holodeck.savedVars and Holodeck.savedVars.sheetOn then
                        zo_callLater(function()
                            ApplySheetVisibility()
                            UpdateSheet()
                        end, 10)
                    end
                end
            end)
        end
    end)

    -- Defer record + LAM until sibling files have loaded
    zo_callLater(function()
        if type(Holodeck.InitRecordSystem) == "function" then
            pcall(Holodeck.InitRecordSystem)
        end
        if type(Holodeck.ShareInit) == "function" then
            pcall(Holodeck.ShareInit)
        end
        if type(Holodeck.CreateSettingsMenu) == "function" then
            pcall(Holodeck.CreateSettingsMenu)
        end
        UpdateLegend()
    end, 50)

    local n = 0
    for _ in pairs(Holodeck.Fights) do n = n + 1 end
    dhd(string.format("v%s | packs=%d | lean record · /hd open last · /hdsettings", Holodeck.version, n))
end

EVENT_MANAGER:RegisterForEvent(Holodeck.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

_G.Holodeck = Holodeck
