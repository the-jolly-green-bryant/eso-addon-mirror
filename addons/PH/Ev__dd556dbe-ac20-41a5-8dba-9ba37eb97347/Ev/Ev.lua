-- Ev: Echoing Vigor (EV) + Radiating Regeneration (RR) tracker
-- - TOP lane = RR (BarTop), BOTTOM lane = EV (BarBottom)
-- - Per-skill Active colors (via SV/LAM)
-- - Toggles to enable/disable EV or RR tracking + master enable switch
-- - Debug toggle to print effect IDs on gained-duration
-- - HUD auto-hide + LAM-ready (position/scale/opacity/font)

Ev = Ev or {}
local EV = Ev

EV.name       = "Ev"
EV.version    = "2.0.2"
EV.varVersion = 1

-- =========================
-- Effect IDs + durations
-- =========================
-- Echoing Vigor
local EV_EFFECT_ID         = 61506
local EV_BASE_DURATION_MS  = 15000
EV.lastDurationMs          = EV_BASE_DURATION_MS

-- Radiating Regeneration (verify with debug if needed)
local RR_EFFECT_ID         = 40079
local RR_BASE_DURATION_MS  = 10000
EV.rrLastDurationMs        = RR_BASE_DURATION_MS

-- Ranges (meters)
local EV_RANGE_M            = 15
local RR_RANGE_M            = 28
local RANGE_MAX_VERTICAL_M  = 10  -- +/- vertical leeway

-- =========================
-- SavedVars defaults
-- =========================
local ACTIVE_EV_DEFAULT         = {0.00, 0.69, 0.00, 0.90}  -- green
local ACTIVE_RR_DEFAULT         = {0.00, 0.69, 0.00, 0.90}  -- green
local IN_RANGE_INACTIVE_COLOR   = {0.91, 0.22, 0.00, 0.90}  -- red
local OUT_RANGE_INACTIVE_COLOR  = {0.50, 0.50, 0.50, 0.80}  -- grey

local defaults = {
    enabled = true,             -- MASTER SWITCH

    offsetX = 500,
    offsetY = 500,
    scale   = 1.0,
    alpha   = 1.0,              -- 0..1

    labelFontFace    = "$(CHAT_FONT)",
    labelFontSize    = 14,
    labelFontOutline = "soft-shadow-thin",

    -- per-skill active colors (RGBA 0..1)
    activeEvColor = { ACTIVE_EV_DEFAULT[1], ACTIVE_EV_DEFAULT[2], ACTIVE_EV_DEFAULT[3], ACTIVE_EV_DEFAULT[4] },
    activeRrColor = { ACTIVE_RR_DEFAULT[1], ACTIVE_RR_DEFAULT[2], ACTIVE_RR_DEFAULT[3], ACTIVE_RR_DEFAULT[4] },

    -- tracking toggles
    trackEV = true,
    trackRR = true,

    -- debug toggle
    debugPrint = false,
}

local SV

-- =========================
-- Model: { accountName, unitId, evExpiresMs, rrExpiresMs }
-- =========================
EV.AT_NAME   = 1
EV.UNIT_ID   = 2
EV.EXPIRE_EV = 3
EV.EXPIRE_RR = 4

EV.members = {}
for i = 1, 12 do EV.members[i] = {"", 0, 0, 0} end

-- =========================
-- Frame
-- =========================
local FRAME_W, FRAME_H = 242, 180

-- =========================
-- Control name helpers (match XML)
-- =========================
local function RowBase(i)   return "EvFrameRow"..i end
local function RowLbl(i)    return RowBase(i).."Label" end
local function RowBarRR(i)  return RowBase(i).."BarTop" end     -- TOP lane = RR
local function RowBarEV(i)  return RowBase(i).."BarBottom" end  -- BOTTOM lane = EV

-- Safe frame accessor
local function GetFrame()
    if Ev._frame and Ev._frame.SetHidden then return Ev._frame end
    local f = _G["EvFrame"]
    if f and f.SetHidden then Ev._frame = f end
    return Ev._frame
end

-- =========================
-- Helpers
-- =========================
local function Clamp01(x) if x < 0 then return 0 elseif x > 1 then return 1 else return x end end

local function TagForIndex(i)
    if not IsUnitGrouped("player") and i == 1 then return "player" end
    return "group"..i
end

local function IsInRange(unitTag, meters)
    if not DoesUnitExist("player") or not DoesUnitExist(unitTag) then return false end
    if IsUnitDead("player") or IsUnitDead(unitTag) then return false end
    if not IsUnitInGroupSupportRange(unitTag) then return false end

    local zone1, x1, y1, z1 = GetUnitWorldPosition("player")
    local zone2, x2, y2, z2 = GetUnitWorldPosition(unitTag)
    if zone1 ~= zone2 then return false end
    if math.abs((y1 - y2) / 100) > RANGE_MAX_VERTICAL_M then return false end

    local dist = zo_sqrt((x1 - x2)^2 + (z1 - z2)^2) / 100
    return dist <= (meters or 15)
end

local function RGBA(c)
    local aScale = (EV.savedVars and EV.savedVars.alpha) or 1.0
    local r,g,b,a = 1,1,1,1
    if type(c) == "table" then r,g,b,a = c[1] or 1, c[2] or 1, c[3] or 1, c[4] or 1 end
    return r, g, b, Clamp01(a * aScale)
end

local function nameForUnitId(uid)
    if not uid or uid == 0 then return "" end
    for i=1,12 do
        if EV.members[i][EV.UNIT_ID] == uid then
            local at = EV.members[i][EV.AT_NAME] or ""
            if at ~= "" then return "@"..at end
        end
    end
    return ""
end

-- Build and apply label font
function Ev.buildLabelFontString()
    local face    = (EV.savedVars and EV.savedVars.labelFontFace) or defaults.labelFontFace
    local size    = (EV.savedVars and EV.savedVars.labelFontSize) or defaults.labelFontSize
    local outline = (EV.savedVars and EV.savedVars.labelFontOutline) or defaults.labelFontOutline
    if outline and outline ~= "" then
        return string.format("%s|%d|%s", face, size, outline)
    else
        return string.format("%s|%d", face, size)
    end
end

function Ev.applyLabelFontIfNeeded()
    local want = Ev.buildLabelFontString()
    if EV._labelFontApplied == want then return end
    for i=1,12 do
        local label = _G[RowLbl(i)]
        if label and label.SetFont then
            label:SetFont(want)
        end
    end
    EV._labelFontApplied = want
end

-- =========================
-- Names & unitId resolution
-- =========================
function EV.updatePlayerNames(resetIds)
    for i=1,12 do
        local tag = TagForIndex(i)
        if DoesUnitExist(tag) then
            local at = (GetUnitDisplayName(tag) or ""):gsub("@","")
            if EV.members[i][EV.AT_NAME] ~= at then
                EV.members[i][EV.AT_NAME] = at
                if resetIds then EV.members[i][EV.UNIT_ID] = 0 end
            end
        else
            EV.members[i][EV.AT_NAME]   = ""
            EV.members[i][EV.UNIT_ID]   = 0
            EV.members[i][EV.EXPIRE_EV] = 0
            EV.members[i][EV.EXPIRE_RR] = 0
        end
    end
end

local function TagToIndex(unitTag)
    if unitTag == "player" then return IsUnitGrouped("player") and 0 or 1 end
    local n = tonumber(unitTag and unitTag:match("^group(%d+)$"))
    if n and n >= 1 and n <= 12 then return n end
    return 0
end

-- Snag unitId from any effect so targetUnitId aligns with rows
function EV.OnEffectChanged(_, _, _, _, unitTag, _, _, _, _, _, _, _, _, unitName, unitId)
    local i = TagToIndex(unitTag)
    if i == 0 then return end
    if unitId and unitId ~= 0 and EV.members[i][EV.UNIT_ID] ~= unitId then
        EV.members[i][EV.UNIT_ID] = unitId
    end
end

-- =========================
-- EV -> expiry (ID-filtered)
-- =========================
function EV.OnEVCombatEvent(_, _, _, _, _, _, _, _, _, _, hitValue, _, _, _, _, targetUnitId)
    EV.lastDurationMs = (hitValue and hitValue > 0) and hitValue or EV.lastDurationMs
    for i=1,12 do
        if EV.members[i][EV.UNIT_ID] == targetUnitId and targetUnitId ~= 0 then
            EV.members[i][EV.EXPIRE_EV] = GetGameTimeMilliseconds() + (hitValue or EV_BASE_DURATION_MS)
            return
        end
    end
end

-- =========================
-- RR -> expiry (ID-filtered)
-- =========================
function EV.OnRRCombatEvent(_, _, _, _, _, _, _, _, _, _, hitValue, _, _, _, _, targetUnitId)
    EV.rrLastDurationMs = (hitValue and hitValue > 0) and hitValue or EV.rrLastDurationMs
    for i=1,12 do
        if EV.members[i][EV.UNIT_ID] == targetUnitId and targetUnitId ~= 0 then
            EV.members[i][EV.EXPIRE_RR] = GetGameTimeMilliseconds() + (hitValue or RR_BASE_DURATION_MS)
            return
        end
    end
end

-- =========================
-- Debug: print effect IDs (your casts only)
-- =========================
function EV.Debug_OnGainedDuration(_, _, _, abilityName, _, _, _, _, _, _, hitValue, _, _, _, _, targetUnitId, abilityId)
    if not hitValue or hitValue <= 0 then return end
    local tgt = nameForUnitId(targetUnitId)
    local an  = tostring(abilityName or "")
    if tgt ~= "" then
        d(string.format("[EvDBG] GAINED_DURATION id=%d name=%s dur=%dms -> %s", abilityId or -1, an, hitValue, tgt))
    else
        d(string.format("[EvDBG] GAINED_DURATION id=%d name=%s dur=%dms", abilityId or -1, an, hitValue))
    end
end

function Ev.applyDebugToggle()
    local key = EV.name.."DBG"
    EVENT_MANAGER:UnregisterForEvent(key, EVENT_COMBAT_EVENT)
    if not (SV and SV.enabled) then return end
    if SV.debugPrint then
        EVENT_MANAGER:RegisterForEvent(key, EVENT_COMBAT_EVENT, EV.Debug_OnGainedDuration)
        EVENT_MANAGER:AddFilterForEvent(key, EVENT_COMBAT_EVENT,
            REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED_DURATION,
            REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER
        )
    end
end

-- =========================
-- Toggle-driven event wiring (EV/RR)
-- =========================
function Ev.applyTrackingToggles()
    -- Always clear first
    EVENT_MANAGER:UnregisterForEvent(EV.name.."EV", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(EV.name.."RR", EVENT_COMBAT_EVENT)

    if not (SV and SV.enabled) then
        Ev.updateUi()
        return
    end

    -- EV
    if SV.trackEV then
        EVENT_MANAGER:RegisterForEvent(EV.name.."EV", EVENT_COMBAT_EVENT, EV.OnEVCombatEvent)
        EVENT_MANAGER:AddFilterForEvent(EV.name.."EV", EVENT_COMBAT_EVENT,
            REGISTER_FILTER_ABILITY_ID, EV_EFFECT_ID,
            REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED_DURATION,
            REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER
        )
    else
        for i=1,12 do EV.members[i][EV.EXPIRE_EV] = 0 end
    end

    -- RR
    if SV.trackRR then
        EVENT_MANAGER:RegisterForEvent(EV.name.."RR", EVENT_COMBAT_EVENT, EV.OnRRCombatEvent)
        EVENT_MANAGER:AddFilterForEvent(EV.name.."RR", EVENT_COMBAT_EVENT,
            REGISTER_FILTER_ABILITY_ID, RR_EFFECT_ID,
            REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED_DURATION,
            REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER
        )
    else
        for i=1,12 do EV.members[i][EV.EXPIRE_RR] = 0 end
    end

    Ev.updateUi()
end

-- =========================
-- Positioning / scaling
-- =========================
function Ev.clampOffsets()
    local s  = (SV.scale or 1)
    local fw = FRAME_W * s
    local fh = FRAME_H * s
    local sw = GuiRoot:GetWidth()
    local sh = GuiRoot:GetHeight()
    local x = math.min(math.max(0, SV.offsetX or 0), math.max(0, sw - fw))
    local y = math.min(math.max(0, SV.offsetY or 0), math.max(0, sh - fh))
    SV.offsetX, SV.offsetY = x, y
end

function Ev.savePos()
    local f = GetFrame()
    if not f then return end
    SV.offsetX = f:GetLeft()
    SV.offsetY = f:GetTop()
end

function Ev.adjustFrameLocation()
    local f = GetFrame()
    if not f then return end
    Ev.clampOffsets()
    f:ClearAnchors()
    f:SetScale(SV.scale or 1)
    f:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SV.offsetX, SV.offsetY)
end

-- =========================
-- One-time bar min/max (maps to BarTop/BarBottom)
-- =========================
local function SetupBarsOnce()
    for i=1,12 do
        local barEV = _G[RowBarEV(i)] -- bottom
        if barEV and not barEV._ev_minmax then
            barEV:SetMinMax(0, 1)
            barEV._ev_minmax = true
        end
        local barRR = _G[RowBarRR(i)] -- top
        if barRR and not barRR._ev_minmax then
            barRR:SetMinMax(0, 1)
            barRR._ev_minmax = true
        end
    end
end

-- =========================
-- Draw/update
-- =========================
function Ev.updateUi()
    local f = GetFrame(); if not f then return end
    if not (SV and SV.enabled) then
        f:SetHidden(true)
        return
    end

    SetupBarsOnce()
    Ev.applyLabelFontIfNeeded()

    local now = GetGameTimeMilliseconds()
    local anyShown = false

    local activeEvCol = (EV.savedVars and EV.savedVars.activeEvColor) or ACTIVE_EV_DEFAULT
    local activeRrCol = (EV.savedVars and EV.savedVars.activeRrColor) or ACTIVE_RR_DEFAULT
    local enableEV    = (EV.savedVars and EV.savedVars.trackEV) ~= false
    local enableRR    = (EV.savedVars and EV.savedVars.trackRR) ~= false

    for i=1,12 do
        local tag   = TagForIndex(i)
        local barEV = _G[RowBarEV(i)]  -- bottom lane
        local barRR = _G[RowBarRR(i)]  -- top lane
        local label = _G[RowLbl(i)]

        if DoesUnitExist(tag) and EV.members[i][EV.AT_NAME] ~= "" and (enableEV or enableRR) then
            local name = EV.members[i][EV.AT_NAME]

            -- Echoing Vigor (BOTTOM)
            if barEV then
                if enableEV then
                    local remEV = EV.members[i][EV.EXPIRE_EV] - now
                    if remEV > 0 then
                        barEV:SetColor(RGBA(activeEvCol))
                        local denom = (EV.lastDurationMs and EV.lastDurationMs > 0) and EV.lastDurationMs or EV_BASE_DURATION_MS
                        barEV:SetValue(Clamp01(remEV / denom))
                    else
                        if IsInRange(tag, EV_RANGE_M) then
                            barEV:SetColor(RGBA(IN_RANGE_INACTIVE_COLOR)); barEV:SetValue(1)
                        else
                            barEV:SetColor(RGBA(OUT_RANGE_INACTIVE_COLOR)); barEV:SetValue(0)
                        end
                    end
                    barEV:SetHidden(false)
                else
                    barEV:SetHidden(true)
                end
            end

            -- Radiating Regeneration (TOP)
            if barRR then
                if enableRR then
                    local remRR = EV.members[i][EV.EXPIRE_RR] - now
                    if remRR > 0 then
                        barRR:SetColor(RGBA(activeRrCol))
                        local denom = (EV.rrLastDurationMs and EV.rrLastDurationMs > 0) and EV.rrLastDurationMs or RR_BASE_DURATION_MS
                        barRR:SetValue(Clamp01(remRR / denom))
                    else
                        if IsInRange(tag, RR_RANGE_M) then
                            barRR:SetColor(RGBA(IN_RANGE_INACTIVE_COLOR)); barRR:SetValue(1)
                        else
                            barRR:SetColor(RGBA(OUT_RANGE_INACTIVE_COLOR)); barRR:SetValue(0)
                        end
                    end
                    barRR:SetHidden(false)
                else
                    barRR:SetHidden(true)
                end
            end

            if label then label:SetText(name); label:SetHidden(false) end
            anyShown = true
        else
            if barEV then barEV:SetHidden(true) end
            if barRR then barRR:SetHidden(true) end
            if label then label:SetHidden(true) end
        end
    end

    f:SetHidden(not anyShown)
end

-- =========================
-- HUD scene attachment
-- =========================
local function Ev_AttachToHudScenes()
    local f = _G["EvFrame"] or (Ev and Ev._frame)
    if not (f and f.SetHidden) then return end
    f:SetDrawTier(DT_LOW)
    f:SetDrawLayer(DL_BACKGROUND)
    f:SetDrawLevel(0)
    if Ev._hudFragment and HUD_SCENE:HasFragment(Ev._hudFragment) then return end
    local frag = ZO_HUDFadeSceneFragment:New(f)
    HUD_SCENE:AddFragment(frag)
    HUD_UI_SCENE:AddFragment(frag)
    Ev._hudFragment = frag
end

-- =========================
-- Master enable/disable wiring
-- =========================
function Ev.applyEnabledToggle()
    local key = EV.name

    -- Always clear handlers first
    EVENT_MANAGER:UnregisterForEvent(key.."EV",  EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(key.."RR",  EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(key.."DBG", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForUpdate(key.."Draw")

    if SV and SV.enabled then
        -- Re-wire per current settings
        Ev.applyTrackingToggles()
        Ev.applyDebugToggle()
        EVENT_MANAGER:RegisterForUpdate(key.."Draw", 100, Ev.updateUi)
        Ev.updateUi()
    else
        -- Hard off: hide frame + clear active timers
        local f = (Ev and Ev._frame) or _G["EvFrame"]
        if f and f.SetHidden then f:SetHidden(true) end
        for i=1,12 do
            EV.members[i][EV.EXPIRE_EV] = 0
            EV.members[i][EV.EXPIRE_RR] = 0
        end
    end
end

-- =========================
-- LAM hook (Ev.setupMenu provided by EvMenu.lua)
-- =========================
local function TryBuildMenu()
    if Ev._menuBuilt then return end
    if LibAddonMenu2 and Ev.setupMenu then
        Ev.setupMenu()
        Ev._menuBuilt = true
    end
end

-- =========================
-- Init
-- =========================
local function OnLoaded(_, addonName)
    if addonName ~= EV.name then return end
    EVENT_MANAGER:UnregisterForEvent(EV.name.."Load", EVENT_ADD_ON_LOADED)

    SV = ZO_SavedVars:NewAccountWide("EvSavedVars", EV.varVersion, nil, defaults)
    for k,v in pairs(defaults) do if SV[k] == nil then SV[k] = v end end
    if type(SV.activeEvColor) ~= "table" then SV.activeEvColor = { unpack(ACTIVE_EV_DEFAULT) } end
    if type(SV.activeRrColor) ~= "table" then SV.activeRrColor = { unpack(ACTIVE_RR_DEFAULT) } end
    if SV.trackEV == nil then SV.trackEV = true end
    if SV.trackRR == nil then SV.trackRR = true end
    if SV.debugPrint == nil then SV.debugPrint = false end
    if SV.enabled == nil then SV.enabled = true end

    EV.savedVars = SV

    Ev.adjustFrameLocation()
    zo_callLater(function() Ev.adjustFrameLocation() end, 50)
    zo_callLater(function() Ev.applyLabelFontIfNeeded() end, 60)
    zo_callLater(function() Ev_AttachToHudScenes() end, 80)
    TryBuildMenu()

    EVENT_MANAGER:RegisterForEvent(EV.name.."PA", EVENT_PLAYER_ACTIVATED, function()
        Ev.adjustFrameLocation()
        Ev.applyLabelFontIfNeeded()
        Ev_AttachToHudScenes()
        TryBuildMenu()
        EVENT_MANAGER:UnregisterForEvent(EV.name.."PA", EVENT_PLAYER_ACTIVATED)
    end)

    EVENT_MANAGER:RegisterForEvent(EV.name.."LAM", EVENT_ADD_ON_LOADED, function(_, name)
        if name == "LibAddonMenu-2.0" then TryBuildMenu() end
    end)

    EV.updatePlayerNames(true)
    EVENT_MANAGER:RegisterForUpdate(EV.name.."Names", 2000, function() EV.updatePlayerNames(false) end)

    -- UnitId mapping (broad; cheap)
    EVENT_MANAGER:RegisterForEvent(EV.name.."Eff", EVENT_EFFECT_CHANGED, EV.OnEffectChanged)

    -- Wire based on master enabled flag
    Ev.applyEnabledToggle()
end

EVENT_MANAGER:RegisterForEvent(EV.name.."Load", EVENT_ADD_ON_LOADED, OnLoaded)