--=====================================================================
-- DeadMarker2.lua — v1.2.3
--
-- Versioning (DM2 suite): human Version = M.m.p
--   AddOnVersion (manifest) = major*10000 + minor*100 + patch
--   1.2.3 → 10203
--
-- 1.2.3: never priority/callout/ping for local player (no "rez yourself")
-- 1.2.2: icon-only arrow (no caret dual); flip rotation so tip faces corpse
-- 1.2.1: arrow texture + screen overlay fix; callout vertical offset
-- 1.2.0 P0:
--   Priority Target resolver (role priority, then closest; skip PENDING/REZZING)
--   Arrow indicator toward Priority Target
--   Death ping (role-filtered sound + flash)
--   Rez callout: "Player, rez Target !!"
--   Settings regroup; pin highlight uses Priority Target
--   Hardening: safe control reuse, pcall UI paths, SV normalize, update announce
-- 1.1.28: corpse reposition for portal/mirror mechanics
--=====================================================================
local DeadMarker2 = DeadMarker2 or {}
DeadMarker2.name        = "DeadMarker2"
DeadMarker2.displayName = "DeadMarker2"
-- AddOnVersion (manifest only) = major*10000 + minor*100 + patch  →  1.2.3 = 10203
DeadMarker2.version     = "1.2.3"

-- ============================= Dependencies =============================
local LAM = (LibStub and LibStub("LibAddonMenu-2.0")) or _G["LibAddonMenu2"]

-- ============================= Constants ================================
local DEFAULT_ROLE_ICONS = {
    tank   = "/esoui/art/icons/poi/poi_groupboss_complete.dds",
    healer = "/esoui/art/icons/poi/poi_wayshrine_complete.dds",
    dps    = "/esoui/art/icons/quest_book_001.dds",
}

local TEST_TEXTURES = {
    ["/esoui/art/icons/poi/poi_delve_complete.dds"]          = "Delve Complete",
    ["/esoui/art/icons/poi/poi_groupboss_complete.dds"]      = "Group Boss",
    ["/esoui/art/icons/poi/poi_wayshrine_complete.dds"]      = "Wayshrine",
    ["/esoui/art/icons/poi/poi_publicdungeon_complete.dds"]  = "Public Dungeon",
    ["/esoui/art/icons/quest_book_001.dds"]                  = "Quest Book",
}
local DEFAULT_WS_TEXTURE = "/esoui/art/icons/poi/poi_groupboss_complete.dds"
local TEST_TEXTURE_LIST = {
    "/esoui/art/icons/poi/poi_groupboss_complete.dds",
    "/esoui/art/icons/poi/poi_delve_complete.dds",
    "/esoui/art/icons/quest_book_001.dds",
}

-- ============================= State ====================================
DeadMarker2.hudTop     = nil
DeadMarker2.fragment   = nil
DeadMarker2.hudIcon    = nil
DeadMarker2.deadUnits  = {}   -- unitTag -> {name, role, x,y,z, timeDeadStart, pinId, color, rezPending}
DeadMarker2.groupInfo  = {}   -- unitTag -> {name, role}
DeadMarker2.rezPanel   = nil
DeadMarker2._inSamplePanel = false
DeadMarker2._panelTickerRunning = false
DeadMarker2._panelTickerName    = DeadMarker2.name .. "_PanelTick"
DeadMarker2._pinTickerRunning   = false
DeadMarker2._pinTickerName      = DeadMarker2.name .. "_PinTick"
DeadMarker2._pinTickMs          = 50

DeadMarker2.wsPins    = {}
DeadMarker2.idseq     = 0
DeadMarker2.followCtl = nil
DeadMarker2.following = false

-- For sizing logic
DeadMarker2._stickyBaseWidth = 0      -- never shrink below longest base line seen while visible
DeadMarker2._lastAppliedFontSize = nil

-- For anchoring pins logic support 
DeadMarker2._posTickMs          = 250   -- how often to re-check corpse position (per unit)
DeadMarker2._posSnapThresholdCm = 300   -- snap if moved >= 3m (in cm/raw units)

-- Priority Target / combat UX state
DeadMarker2.priorityTag       = nil
DeadMarker2.screenUI          = nil   -- pure 2D overlay (arrow/callout); not world-space parent
DeadMarker2.arrowCtl          = nil
DeadMarker2.arrowLabel        = nil   -- text fallback if texture missing
DeadMarker2.calloutCtl        = nil
DeadMarker2._lastPingAt       = 0
DeadMarker2._lastCalloutTag   = nil
DeadMarker2._lastCalloutAt    = 0
DeadMarker2._pingFlashCtl     = nil
DeadMarker2._arrowTextureOk   = nil   -- nil=untested, true/false after probe

-- Packaged up-arrow first (reliable). ESO paths as fallbacks.
local ARROW_TEXTURES = {
    "DeadMarker2/textures/dm2arrow.dds",
    "/esoui/art/miscellaneous/right_arrow.dds",
    "/esoui/art/buttons/large_rightarrow_up.dds",
    "/esoui/art/buttons/right_if_up.dds",
    "/esoui/art/ladder/ladder_uparrow.dds",
}

-- Forward declarations (ESO console: locals must exist before nested callers bind)
local ensureHUDTop
local ensureScreenUI
local UpdateRezPanel

-- ============================= Saved Vars ===============================
local _defaults = {
    -- Global fallback (used only if role-specific & ESO fail)
    iconChoice        = DEFAULT_WS_TEXTURE,

    -- Per-role icons (preferred = your packaged textures)
    roleIcons = {
        tank   = "/DeadMarker2/textures/dm2tank.dds",
        healer = "/DeadMarker2/textures/dm2healer.dds",
        dps    = "/DeadMarker2/textures/dm2dps.dds",
    },
    useRoleIcons     = true,   -- when false, all pins use Global Fallback Icon

    -- Render & behavior
    yOffsetMeters     = 2.0,
    worldIconMeters   = 1.2,
    opacity           = 1.0,   -- pin opacity (icons)

    -- Rez Panel master toggle
    enableRezPanel    = true,

    -- Rez Panel layout/sizing
    panelOffsetX      = 60,    -- px from TOPLEFT of screen
    panelOffsetY      = 240,   -- px from TOPLEFT of screen
    panelOpacity      = 0.95,  -- backdrop fill & edge

    -- Sizing (no wrapping)
    maxPanelWidth     = 980,   -- hard cap; panel will not exceed this
    minPanelWidth     = 420,   -- floor so it never collapses too far
    panelPaddingX     = 28,    -- inner padding left/right
    panelPaddingY     = 16,    -- inner padding top/bottom
    minPanelFontSize  = 18,    -- auto-shrink lower bound

    showChatAlerts    = true,
    debugEnabled      = false,

    -- Priority (lower = higher)
    priorityTank      = 1,
    priorityHealer    = 2,
    priorityDPS       = 3,

    -- Visuals
    monochromeTint    = false,   -- OFF by default (neutral)
    panelFontSize     = 24,
    showTimers        = true,

    -- Highlight Priority Target (legacy key: highlightClosest)
    highlightClosest  = false,   -- when true, pulse/spin Priority Target pin

    -- Arrow indicator (toward Priority Target)
    enableArrow       = true,
    arrowSizePx       = 64,
    arrowOpacity      = 1.0,
    arrowReticleDist  = 100,     -- px from screen center along bearing

    -- Death ping
    enableDeathPing   = true,
    pingTank          = true,
    pingHealer        = true,
    pingDps           = false,
    pingFlash         = true,
    pingCooldownMs    = 1500,

    -- Rez callout: "Skye-Forge, rez TankBob1911 !!"
    enableRezCallout          = true,
    calloutTemplate           = "%player%, rez %target% !!",
    calloutCenter             = true,   -- center-screen banner
    calloutSelfChat           = false,  -- local d() only; never group chat by default
    calloutTankHealerOnly     = false,
    calloutOnPriorityChange   = true,
    calloutDurationMs         = 3500,
    calloutOffsetX            = 0,      -- px from horizontal center
    calloutOffsetY            = 280,    -- px from top of screen (raise/lower banner)

    -- Update announce bookkeeping (internal)
    lastAnnouncedVersion      = "",
}

-- Deep-merge defaults into a table (non-clobbering)
local function _deepmerge(dst, src)
    if type(dst) ~= "table" or type(src) ~= "table" then return end
    for k, v in pairs(src) do
        if type(v) == "table" then
            if type(dst[k]) ~= "table" then dst[k] = {} end
            _deepmerge(dst[k], v)
        elseif dst[k] == nil then
            dst[k] = v
        end
    end
end

-- Ensure critical SV shapes after load/merge (corrupt or partial SV safe)
local function _NormalizeSavedVars(sv)
    if type(sv) ~= "table" then return end
    if type(sv.roleIcons) ~= "table" then sv.roleIcons = {} end
    local ri = sv.roleIcons
    if type(ri.tank) ~= "string" or ri.tank == "" then
        ri.tank = _defaults.roleIcons.tank
    end
    if type(ri.healer) ~= "string" or ri.healer == "" then
        ri.healer = _defaults.roleIcons.healer
    end
    if type(ri.dps) ~= "string" or ri.dps == "" then
        ri.dps = _defaults.roleIcons.dps
    end
    if type(sv.calloutTemplate) ~= "string" or sv.calloutTemplate == "" then
        sv.calloutTemplate = _defaults.calloutTemplate
    end
    local function num(key, fallback, lo, hi)
        local n = tonumber(sv[key])
        if not n then n = fallback end
        if lo and n < lo then n = lo end
        if hi and n > hi then n = hi end
        sv[key] = n
    end
    num("priorityTank", 1, 1, 3)
    num("priorityHealer", 2, 1, 3)
    num("priorityDPS", 3, 1, 3)
    num("arrowSizePx", 64, 24, 160)
    num("arrowOpacity", 1.0, 0, 1)
    num("arrowReticleDist", 100, 20, 280)
    num("pingCooldownMs", 1500, 250, 10000)
    num("calloutDurationMs", 3500, 500, 15000)
    num("calloutOffsetX", 0, -800, 800)
    num("calloutOffsetY", 280, 0, 1200)
    num("opacity", 1.0, 0, 1)
    num("panelOpacity", 0.95, 0, 1)
    num("worldIconMeters", 1.2, 0.3, 4)
    num("yOffsetMeters", 2.0, 0, 12)
    num("panelFontSize", 24, 12, 40)
    num("minPanelFontSize", 18, 10, 32)
end

--DeadMarker2.savedVars = ZO_SavedVars:NewAccountWide("DeadMarker2Vars", 1, nil, _defaults, nil) or {}
--_deepmerge(DeadMarker2.savedVars, _defaults) -- protect against nil on new keys
DeadMarker2.savedVars = nil  -- init in EVENT_ADD_ON_LOADED

-- ============================= Utilities ================================
local function ddm(msg)
    local sv = DeadMarker2.savedVars
    if sv and sv.debugEnabled then
        local label = DeadMarker2.displayName or DeadMarker2.name or "DeadMarker2"
        d("|c69c0ff[" .. label .. "]|r " .. tostring(msg))
    end
end

-- Safe control / TLW creation: reuse existing named controls (reload-safe)
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
    DeadMarker2.idseq = (DeadMarker2.idseq or 0) + 1
    return string.format("%s_%d_%d", prefix, DeadMarker2.idseq, GetFrameTimeMilliseconds() or 0)
end

local function _UpdateDeadPinPosition(unitTag, data, now)
    if not unitTag or not data then return end
    local pin = data.pinId
    if not pin or pin:IsHidden() then return end
    if not (IsUnitDead and IsUnitDead(unitTag)) then return end

    if data._nextPosCheckAt and now < data._nextPosCheckAt then return end
    data._nextPosCheckAt = now + (DeadMarker2._posTickMs or 250)

    local _, x, y, z = GetUnitRawWorldPosition(unitTag)
    if not (x and y and z) then return end

    local ox, oy, oz = data.x, data.y, data.z
    local thresh = DeadMarker2._posSnapThresholdCm or 300
    if (not ox)
        or (math.abs(x-ox) >= thresh)
        or (math.abs(y-oy) >= thresh)
        or (math.abs(z-oz) >= thresh) then

        data.x, data.y, data.z = x, y, z
        WS_SetAtRaw(pin, x, y + (DeadMarker2.savedVars.yOffsetMeters or 2.0) * 100, z)

        if DeadMarker2.savedVars.debugEnabled then
            local name = data.name or GetUnitDisplayName(unitTag) or unitTag
            d(string.format("|c69c0ff[DeadMarker2]|r Pin repositioned for %s (corpse moved)", name))
        end
    end
end


-- Safe texture setter
local function _SetTextureSafe(ctrl, path, fallback)
    if not ctrl then return end
    local try = path or ""
    ctrl:SetTexture(try)
    local loaded = (ctrl.GetTextureFileName and ctrl:GetTextureFileName()) or ""
    if (not loaded or loaded == "" or (try ~= "" and not string.find(string.lower(loaded), string.lower(try), 1, true))) then
        local fb = fallback or DEFAULT_WS_TEXTURE
        ctrl:SetTexture(fb)
        return fb
    end
    return loaded
end

-- Normalize role label -> "tank"/"healer"/"dps"
local function normalizeRole(role)
    if type(role) == "number" then
        if role == LFG_ROLE_TANK then return "tank"
        elseif role == LFG_ROLE_HEAL then return "healer"
        elseif role == LFG_ROLE_DPS then return "dps"
        else return "dps" end
    end
    if type(role) == "string" then
        role = role:lower()
        if role == "heal" then return "healer" end
        if role == "tank" or role == "healer" or role == "dps" then return role end
    end
    return "dps"
end

-- Role texture chooser with layered fallback
local function _GetRoleTextureFor(role)
    role = normalizeRole(role)
    local sv = DeadMarker2.savedVars or {}
    local preferred = (sv.roleIcons and sv.roleIcons[role]) or nil
    if preferred and preferred ~= "" then return preferred end
    local eso = DEFAULT_ROLE_ICONS[role]
    if eso and eso ~= "" then return eso end
    return sv.iconChoice or DEFAULT_WS_TEXTURE
end

-- Master resolver that respects the toggle
local function _GetIconFor(role)
    local sv = DeadMarker2.savedVars or {}
    if not sv.useRoleIcons then
        return sv.iconChoice or DEFAULT_WS_TEXTURE
    end
    return _GetRoleTextureFor(role)
end

-- ====================== Fonts ==========================================
local function _fontRow(size)
    return string.format("EsoUI/Common/Fonts/univers57.otf|%d|soft-shadow-thin", size)
end

local function CreateFonts()
    if not DeadMarker2_TitleFont then DeadMarker2_TitleFont = CreateFont("DeadMarker2_TitleFont") end
    DeadMarker2_TitleFont:SetFont("EsoUI/Common/Fonts/univers67.otf|36|soft-shadow-thick")

    if not DeadMarker2_RowFont then DeadMarker2_RowFont = CreateFont("DeadMarker2_RowFont") end
    local size = DeadMarker2.savedVars.panelFontSize or 24
    DeadMarker2_RowFont:SetFont(_fontRow(size))

    if DeadMarker2.rezPanel and DeadMarker2.rezPanel.measure then
        DeadMarker2.rezPanel.measure:SetFont(_fontRow(size))
    end
    DeadMarker2._lastAppliedFontSize = size
    ddm("Fonts updated. Row size="..tostring(size))
end

local function SetRowFontSize(size)
    size = math.floor(size)
    if size == (DeadMarker2._lastAppliedFontSize or -1) then return end
    DeadMarker2_RowFont:SetFont(_fontRow(size))
    if DeadMarker2.rezPanel and DeadMarker2.rezPanel.measure then
        DeadMarker2.rezPanel.measure:SetFont(_fontRow(size))
    end
    DeadMarker2._lastAppliedFontSize = size
end

local function RefreshPanelFonts()
    CreateFonts()
    if DeadMarker2.rezPanel and DeadMarker2.rezPanel.label then
        DeadMarker2.rezPanel.label:SetFont("DeadMarker2_RowFont")
        if DeadMarker2.rezPanel.measure then DeadMarker2.rezPanel.measure:SetFont("DeadMarker2_RowFont") end
        UpdateRezPanel()
    end
end

-- ===================== Tint helper (monochrome vs state) ===============
local function _ApplyPinColor(pin, r, g, b, a, opts)
    if not pin then return end
    local sv    = DeadMarker2.savedVars or {}
    local force = opts and opts.force
    if pin.SetDesaturation then
        if sv.monochromeTint and not force then
            pin:SetDesaturation(1.0)
        else
            pin:SetDesaturation(0.0)
        end
    end
    pin:SetColor(r or 1, g or 1, b or 1, a or (sv.opacity or 1.0))
end

-- ===================== Orientation ticker ==============================
local function _Billboard(ctl)
    if not ctl or ctl:IsHidden() then return end
    local fx, fy, fz = GetCameraForward(SPACE_WORLD)
    if not fx or not fz then return end
    local yaw   = math.atan2(fx, fz) + math.pi
    local pitch = -math.asin(fy or 0)

    -- Allow optional roll (used for Priority Target highlight animation).
    local roll = ctl.dm2_roll or 0
    ctl:SetTransformRotation(pitch, yaw, roll)
end

-- ======================== Rez flags (early — Priority Target needs this) ==
local function GetRezFlags(unitTag)
    local isDead   = (IsUnitDead and IsUnitDead(unitTag)) or false
    local rezzing  = (IsUnitBeingResurrected and IsUnitBeingResurrected(unitTag)) or false
    local pending  = (DoesUnitHaveResurrectPending and DoesUnitHaveResurrectPending(unitTag)) or false
    return isDead, rezzing, pending
end

-- ======================== Priority Target ===============================
-- Role priority (lower number wins), then closest horizontal distance.
-- Eligible: tracked dead pin, not PENDING/REZZING, not local player
-- (never tell the player to rez themselves).
local function _RolePriorityValue(role, sv)
    role = normalizeRole(role)
    if role == "tank" then return sv.priorityTank or 1 end
    if role == "healer" then return sv.priorityHealer or 2 end
    return sv.priorityDPS or 3
end

local function _IsLocalPlayerUnit(unitTag)
    if not unitTag then return false end
    if unitTag == "player" then return true end
    if string.match(unitTag, "^sample_") then return false end
    if AreUnitsEqual then
        local ok, same = pcall(AreUnitsEqual, unitTag, "player")
        if ok and same then return true end
    end
    -- Name fallback (group tag for self after canonicalization)
    local a = (GetUnitDisplayName and GetUnitDisplayName(unitTag)) or (GetUnitName and GetUnitName(unitTag))
    local b = (GetUnitDisplayName and GetUnitDisplayName("player")) or (GetUnitName and GetUnitName("player"))
    if a and b and a ~= "" and a == b then return true end
    return false
end

local function _IsEligiblePriorityTarget(unitTag, data)
    if not unitTag or not data then return false end
    -- Never prioritize yourself for arrow / callout / highlight
    if _IsLocalPlayerUnit(unitTag) then return false end
    if not data.pinId or data.pinId:IsHidden() then return false end
    if data.rezPending then return false end
    if string.match(unitTag, "^sample_") then return true end
    local isDead, rezzing, pending = GetRezFlags(unitTag)
    if rezzing or pending then return false end
    if IsUnitDead and not isDead then return false end
    return true
end

-- Returns unitTag, data, distMeters (or nils)
local function ResolvePriorityTarget()
    local sv = DeadMarker2.savedVars
    if not sv then return nil, nil, nil end

    local _, px, _, pz = GetUnitRawWorldPosition("player")
    px, pz = px or 0, pz or 0

    local bestTag, bestData, bestPri, bestDist2 = nil, nil, nil, nil
    for unitTag, data in pairs(DeadMarker2.deadUnits) do
        if _IsEligiblePriorityTarget(unitTag, data) then
            local pri = _RolePriorityValue(data.role or "dps", sv)
            local dx = (data.x or 0) - px
            local dz = (data.z or 0) - pz
            local d2 = dx * dx + dz * dz
            if (not bestPri)
                or (pri < bestPri)
                or (pri == bestPri and d2 < bestDist2) then
                bestPri, bestDist2, bestTag, bestData = pri, d2, unitTag, data
            end
        end
    end

    local distM = bestDist2 and (math.sqrt(bestDist2) / 100) or nil
    DeadMarker2.priorityTag = bestTag
    return bestTag, bestData, distM
end

local function _NormalizeAngle(a)
    while a > math.pi do a = a - (2 * math.pi) end
    while a < -math.pi do a = a + (2 * math.pi) end
    return a
end

local function _LocalPlayerDisplayName()
    local n = (GetUnitDisplayName and GetUnitDisplayName("player")) or (GetUnitName and GetUnitName("player"))
    if n and n ~= "" then
        -- Strip leading @ from account-style names for callout readability when desired
        return n
    end
    return "Player"
end

local function _TargetDisplayName(unitTag, data)
    if data and data.name and data.name ~= "" then return data.name end
    if unitTag and not string.match(unitTag, "^sample_") then
        local n = (GetUnitDisplayName and GetUnitDisplayName(unitTag)) or (GetUnitName and GetUnitName(unitTag))
        if n and n ~= "" then return n end
    end
    return unitTag or "Unknown"
end

-- ======================== Death ping ====================================
local function _EnsurePingFlash()
    if DeadMarker2._pingFlashCtl then return DeadMarker2._pingFlashCtl end
    local ok, result = pcall(function()
        local parent = ensureHUDTop()
        if not parent then return nil end
        local flash = _SafeCreateControl("DeadMarker2_PingFlash", parent, CT_BACKDROP)
        if not flash then return nil end
        flash:ClearAnchors()
        flash:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)
        local w, h = parent:GetDimensions()
        if w and h then flash:SetDimensions(w, h) end
        flash:SetDrawLayer(DL_OVERLAY)
        flash:SetDrawTier(DT_HIGH)
        flash:SetDrawLevel(320000)
        if flash.SetCenterColor then flash:SetCenterColor(1, 0.15, 0.1, 0.22) end
        if flash.SetEdgeColor then flash:SetEdgeColor(0, 0, 0, 0) end
        flash:SetHidden(true)
        return flash
    end)
    if ok and result then
        DeadMarker2._pingFlashCtl = result
        return result
    end
    ddm("PingFlash create failed: " .. tostring(result))
    return nil
end

local function _PlayDeathPingSound()
    -- Prefer SOUNDS table when present; fall back to known string names.
    local ok = false
    if SOUNDS then
        local candidates = {
            SOUNDS.DUEL_BOUNDARY_WARNING,
            SOUNDS.QUEST_ABANDONED,
            SOUNDS.GENERAL_ALERT_ERROR,
            SOUNDS.BOOK_CLOSE,
        }
        for i = 1, #candidates do
            if candidates[i] then
                pcall(PlaySound, candidates[i])
                ok = true
                break
            end
        end
    end
    if not ok then
        pcall(PlaySound, "Duel_Boundary_Warning")
    end
end

-- role: normalized "tank"/"healer"/"dps"
local function MaybeDeathPing(role)
    local ok, err = pcall(function()
        local sv = DeadMarker2.savedVars
        if not sv or not sv.enableDeathPing then return end
        role = normalizeRole(role)
        if role == "tank" and not sv.pingTank then return end
        if role == "healer" and not sv.pingHealer then return end
        if role == "dps" and not sv.pingDps then return end

        local now = GetFrameTimeMilliseconds() or 0
        local cd = sv.pingCooldownMs or 1500
        if (now - (DeadMarker2._lastPingAt or 0)) < cd then return end
        DeadMarker2._lastPingAt = now

        _PlayDeathPingSound()

        if sv.pingFlash then
            local flash = _EnsurePingFlash()
            if flash then
                local parent = DeadMarker2.hudTop
                if parent then
                    local w, h = parent:GetDimensions()
                    if w and h then flash:SetDimensions(w, h) end
                end
                flash:SetHidden(false)
                zo_callLater(function()
                    if DeadMarker2._pingFlashCtl then
                        pcall(function() DeadMarker2._pingFlashCtl:SetHidden(true) end)
                    end
                end, 280)
            end
        end
    end)
    if not ok then ddm("MaybeDeathPing error: " .. tostring(err)) end
end

-- ======================== Rez callout ===================================
local function _ApplyCalloutLayout(lbl)
    if not lbl then return end
    local sv = DeadMarker2.savedVars or {}
    local parent = lbl:GetParent() or ensureScreenUI()
    if not parent then return end
    local ox = tonumber(sv.calloutOffsetX) or 0
    local oy = tonumber(sv.calloutOffsetY) or 280
    lbl:ClearAnchors()
    lbl:SetAnchor(TOP, parent, TOP, ox, oy)
end

local function _EnsureCalloutLabel()
    if DeadMarker2.calloutCtl then
        _ApplyCalloutLayout(DeadMarker2.calloutCtl)
        return DeadMarker2.calloutCtl
    end
    local ok, result = pcall(function()
        -- Pure 2D overlay (not the world-pin HUD parent)
        local parent = ensureScreenUI()
        if not parent then parent = ensureHUDTop() end
        if not parent then return nil end
        local lbl = _SafeCreateControl("DeadMarker2_Callout", parent, CT_LABEL)
        if not lbl then return nil end
        lbl:SetFont("EsoUI/Common/Fonts/univers67.otf|36|soft-shadow-thick")
        lbl:SetColor(1, 0.85, 0.35, 1)
        if TEXT_ALIGN_CENTER then
            lbl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        end
        lbl:SetDrawLayer(DL_OVERLAY)
        lbl:SetDrawTier(DT_HIGH)
        lbl:SetDrawLevel(325000)
        if lbl.SetMouseEnabled then lbl:SetMouseEnabled(false) end
        lbl:SetHidden(true)
        _ApplyCalloutLayout(lbl)
        return lbl
    end)
    if ok and result then
        DeadMarker2.calloutCtl = result
        return result
    end
    ddm("Callout label create failed: " .. tostring(result))
    return nil
end

local function _FormatCallout(playerName, targetName, sv)
    local tmpl = (sv and sv.calloutTemplate) or "%player%, rez %target% !!"
    local msg = tmpl
    msg = string.gsub(msg, "%%player%%", playerName or "Player")
    msg = string.gsub(msg, "%%target%%", targetName or "Unknown")
    return msg
end

local function FireRezCallout(unitTag, data, reason)
    local ok, err = pcall(function()
        local sv = DeadMarker2.savedVars
        if not sv or not sv.enableRezCallout then return end
        if not unitTag or not data then return end

        local role = normalizeRole(data.role or "dps")
        if sv.calloutTankHealerOnly and role == "dps" then return end

        local now = GetFrameTimeMilliseconds() or 0
        if unitTag == DeadMarker2._lastCalloutTag and reason ~= "force" then
            if (now - (DeadMarker2._lastCalloutAt or 0)) < 2000 then return end
        end

        local playerName = _LocalPlayerDisplayName()
        local targetName = _TargetDisplayName(unitTag, data)
        local msg = _FormatCallout(playerName, targetName, sv)

        DeadMarker2._lastCalloutTag = unitTag
        DeadMarker2._lastCalloutAt  = now

        if sv.calloutCenter then
            local lbl = _EnsureCalloutLabel()
            if lbl then
                _ApplyCalloutLayout(lbl)
                lbl:SetText(msg)
                lbl:SetHidden(false)
                local dur = sv.calloutDurationMs or 3500
                zo_callLater(function()
                    if DeadMarker2.calloutCtl and DeadMarker2._lastCalloutAt == now then
                        pcall(function() DeadMarker2.calloutCtl:SetHidden(true) end)
                    end
                end, dur)
            end
        end

        if sv.calloutSelfChat then
            d("|cFFD966[" .. (DeadMarker2.displayName or "DeadMarker2") .. "]|r " .. msg)
        end

        ddm("Callout (" .. tostring(reason or "?") .. "): " .. msg)
    end)
    if not ok then ddm("FireRezCallout error: " .. tostring(err)) end
end

local function MaybeRezCalloutForPriority(reason)
    local ok, err = pcall(function()
        local sv = DeadMarker2.savedVars
        if not sv or not sv.enableRezCallout then return end
        local tag, data = ResolvePriorityTarget()
        if not tag or not data then
            DeadMarker2._lastCalloutTag = nil
            return
        end

        local isNew = (tag ~= DeadMarker2._lastCalloutTag)
        if isNew then
            FireRezCallout(tag, data, reason or "new")
        elseif sv.calloutOnPriorityChange and reason == "priority_change" then
            FireRezCallout(tag, data, "priority_change")
        end
    end)
    if not ok then ddm("MaybeRezCallout error: " .. tostring(err)) end
end

-- ======================== Arrow indicator ===============================
-- Screen-space only (ensureScreenUI). Never parent under world-pin HUD.
local function _ProbeArrowTexture(ctl)
    if not ctl then return false end
    for i = 1, #ARROW_TEXTURES do
        local path = ARROW_TEXTURES[i]
        local ok = pcall(function() ctl:SetTexture(path) end)
        if ok then
            local loaded = ""
            if ctl.GetTextureFileName then
                loaded = tostring(ctl:GetTextureFileName() or "")
            end
            -- Accept if path sticks or any non-empty texture name returned
            if loaded ~= "" then
                DeadMarker2._arrowTextureOk = true
                ddm("Arrow texture: " .. loaded)
                return true
            end
        end
    end
    DeadMarker2._arrowTextureOk = false
    ddm("Arrow texture: none loaded — using label fallback")
    return false
end

local function _EnsureArrowLabel(parent)
    if DeadMarker2.arrowLabel then return DeadMarker2.arrowLabel end
    local lbl = _SafeCreateControl("DeadMarker2_ArrowLabel", parent, CT_LABEL)
    if not lbl then return nil end
    lbl:SetFont("EsoUI/Common/Fonts/univers67.otf|48|soft-shadow-thick")
    lbl:SetColor(1, 0.35, 0.25, 1)
    if TEXT_ALIGN_CENTER then lbl:SetHorizontalAlignment(TEXT_ALIGN_CENTER) end
    lbl:SetDrawLayer(DL_OVERLAY)
    lbl:SetDrawTier(DT_HIGH)
    lbl:SetDrawLevel(322010)
    lbl:SetText("^")
    lbl:SetHidden(true)
    DeadMarker2.arrowLabel = lbl
    return lbl
end

local function _EnsureArrow()
    if DeadMarker2.arrowCtl then return DeadMarker2.arrowCtl end
    local ok, result = pcall(function()
        local parent = ensureScreenUI()
        if not parent then parent = ensureHUDTop() end
        if not parent then return nil end

        local ctl = _SafeCreateControl("DeadMarker2_Arrow", parent, CT_TEXTURE)
        if not ctl then return nil end

        -- Force interface/screen space (never inherit world-space from pin parent)
        if SPACE_INTERFACE and ctl.SetSpace then
            pcall(function() ctl:SetSpace(SPACE_INTERFACE) end)
        elseif SPACE_SCREEN and ctl.SetSpace then
            pcall(function() ctl:SetSpace(SPACE_SCREEN) end)
        end

        ctl:SetDrawLayer(DL_OVERLAY)
        ctl:SetDrawTier(DT_HIGH)
        ctl:SetDrawLevel(322000)
        if TEX_BLEND_MODE_ALPHA and ctl.SetBlendMode then
            ctl:SetBlendMode(TEX_BLEND_MODE_ALPHA)
        end
        if ctl.SetMouseEnabled then ctl:SetMouseEnabled(false) end
        ctl:SetDimensions(64, 64)
        ctl:SetHidden(true)

        _ProbeArrowTexture(ctl)
        -- Always create label fallback (used when texture missing or as dual cue)
        _EnsureArrowLabel(parent)
        return ctl
    end)
    if ok and result then
        DeadMarker2.arrowCtl = result
        return result
    end
    ddm("Arrow create failed: " .. tostring(result))
    return nil
end

local function _HideArrow()
    if DeadMarker2.arrowCtl then
        pcall(function() DeadMarker2.arrowCtl:SetHidden(true) end)
    end
    if DeadMarker2.arrowLabel then
        pcall(function() DeadMarker2.arrowLabel:SetHidden(true) end)
    end
end

local function _UpdateArrowIndicator(nowMs)
    local ok, err = pcall(function()
        local sv = DeadMarker2.savedVars
        if not sv or not sv.enableArrow then
            _HideArrow()
            return
        end

        local tag, data, distM = ResolvePriorityTarget()
        if not tag or not data then
            _HideArrow()
            return
        end

        -- ESO: GetUnitRawWorldPosition → _, worldX, worldY, worldZ
        local _, px, _, pz = GetUnitRawWorldPosition("player")
        px, pz = px or 0, pz or 0
        local tx, tz = data.x or px, data.z or pz
        local dx, dz = tx - px, tz - pz

        local heading = (GetPlayerCameraHeading and GetPlayerCameraHeading()) or 0
        local absAngle = math.atan2(dx, dz)
        local rel = _NormalizeAngle(absAngle - heading)

        local parent = ensureScreenUI() or ensureHUDTop()
        if not parent then return end

        local arrow = _EnsureArrow()
        local size = tonumber(sv.arrowSizePx) or 64
        if size < 24 then size = 24 end
        local dist = tonumber(sv.arrowReticleDist) or 100
        -- Position on screen: bearing 0 = forward (up on screen)
        local ox = math.sin(rel) * dist
        local oy = -math.cos(rel) * dist

        local a = tonumber(sv.arrowOpacity) or 1.0
        if distM and distM > 15 then
            local t = (nowMs or GetFrameTimeMilliseconds() or 0) / 1000
            a = a * (0.78 + 0.22 * math.sin(t * 5.0))
        end
        if a < 0.15 then a = 0.15 elseif a > 1 then a = 1 end

        -- Texture arrow preferred (rotatable). Label only if texture failed to load.
        local texOk = (DeadMarker2._arrowTextureOk == true)
        if arrow and texOk then
            -- dm2arrow.dds: tip should face the corpse. Was 180° off with bare `rel`.
            local rot = rel + math.pi
            arrow:SetDimensions(size, size)
            arrow:ClearAnchors()
            arrow:SetAnchor(CENTER, parent, CENTER, ox, oy)
            if arrow.SetTextureRotation then
                pcall(function() arrow:SetTextureRotation(rot) end)
            end
            arrow:SetColor(1, 0.3, 0.25, a)
            if arrow.SetAlpha then arrow:SetAlpha(a) end
            arrow:SetHidden(false)
        elseif arrow then
            arrow:SetHidden(true)
        end

        local lbl = DeadMarker2.arrowLabel or _EnsureArrowLabel(parent)
        if lbl then
            if texOk then
                -- Icon is working — do not stack caret on top
                lbl:SetHidden(true)
            else
                -- Fallback only when texture missing
                local fontSize = math.max(32, math.floor(size * 0.9))
                lbl:SetFont(string.format("EsoUI/Common/Fonts/univers67.otf|%d|soft-shadow-thick", fontSize))
                local deg = rel * 180 / math.pi
                local glyph = "^"
                if deg > 45 and deg <= 135 then glyph = ">"
                elseif deg > 135 or deg <= -135 then glyph = "v"
                elseif deg > -135 and deg <= -45 then glyph = "<"
                end
                lbl:SetText(glyph)
                lbl:SetColor(1, 0.9, 0.2, a)
                lbl:ClearAnchors()
                lbl:SetAnchor(CENTER, parent, CENTER, ox, oy)
                lbl:SetHidden(false)
            end
        end
    end)
    if not ok then ddm("Arrow update error: " .. tostring(err)) end
end

-- ===================== Priority Target pin highlight ====================
-- Pulses + spins the Priority Target marker (role priority, then closest).
-- Legacy setting key: highlightClosest (UI: Highlight Priority Target).
local function _ApplyPriorityHighlight(nowMs)
    local sv = DeadMarker2.savedVars
    if not sv then return end

    local bestTag = nil
    if sv.highlightClosest then
        bestTag = select(1, ResolvePriorityTarget())
    end

    -- If disabled, restore pins to baseline visuals.
    if not sv.highlightClosest then
        for _, data in pairs(DeadMarker2.deadUnits) do
            if data and data.pinId and not data.pinId:IsHidden() then
                local pin = data.pinId
                pin.dm2_roll = 0
                if pin.SetTransformScale then pin:SetTransformScale(sv.worldIconMeters or 1.2) end
                if pin.SetAlpha then pin:SetAlpha(sv.opacity or 1.0) end
            end
        end
        return
    end

    local t = (nowMs or GetFrameTimeMilliseconds() or 0) / 1000
    local baseScale = sv.worldIconMeters or 1.2
    local baseAlpha = sv.opacity or 1.0

    for unitTag, data in pairs(DeadMarker2.deadUnits) do
        if data and data.pinId and not data.pinId:IsHidden() then
            local pin = data.pinId
            if unitTag == bestTag then
                local pulse = 1.0 + 0.18 * math.sin(t * 6.0)
                local alpha = baseAlpha * (0.72 + 0.28 * math.sin(t * 6.0 + 1.1))
                if alpha < 0 then alpha = 0 elseif alpha > 1 then alpha = 1 end

                if pin.SetTransformScale then pin:SetTransformScale(baseScale * pulse) end
                if pin.SetAlpha then pin:SetAlpha(alpha) end
                pin.dm2_roll = (t * 1.6) % (math.pi * 2)
            else
                if pin.SetTransformScale then pin:SetTransformScale(baseScale) end
                if pin.SetAlpha then pin:SetAlpha(baseAlpha) end
                pin.dm2_roll = 0
            end
        end
    end
end

local function _PinTick()
    if DeadMarker2.followCtl and DeadMarker2.following then
        local _, px, py, pz = GetUnitRawWorldPosition("player")
        if px and py and pz then
            WS_SetAtRaw(DeadMarker2.followCtl, px, py + (DeadMarker2.savedVars.yOffsetMeters or 2.0) * 100, pz)
            _Billboard(DeadMarker2.followCtl)
        end
    end

    local now = GetFrameTimeMilliseconds()
    for unitTag, data in pairs(DeadMarker2.deadUnits) do
        if data and data.pinId and not data.pinId:IsHidden() then
            _Billboard(data.pinId)
            _UpdateDeadPinPosition(unitTag, data, now)
        end
    end

    _ApplyPriorityHighlight(now)
    _UpdateArrowIndicator(now)
end

local function _StartPinTicker()
    if DeadMarker2._pinTickerRunning then return end
    EVENT_MANAGER:RegisterForUpdate(DeadMarker2._pinTickerName, DeadMarker2._pinTickMs, _PinTick)
    DeadMarker2._pinTickerRunning = true
end

local function _StopPinTicker()
    if not DeadMarker2._pinTickerRunning then return end
    EVENT_MANAGER:UnregisterForUpdate(DeadMarker2._pinTickerName)
    DeadMarker2._pinTickerRunning = false
end

-- ====================== Capability dump ================================
local function Caps()
    local function t(v) return type(v) == "function" and "yes" or "no" end
    ddm(string.format("CAPS: screenPos=%s worldToGui=%s guiToScreen=%s hasSPACE3D=%s",
        t(GetUnitScreenPosition), t(WorldPositionToGuiRender3DPosition),
        t(GuiRender3DPositionToScreenPosition), t(Set3DRenderSpaceToCurrentCamera)))
end

-- ======================= HUD TLW + fragment ============================
ensureHUDTop = function()
    local ok, result = pcall(function()
        if DeadMarker2.hudTop then
            local w, h = GuiRoot:GetDimensions()
            DeadMarker2.hudTop:ClearAnchors()
            DeadMarker2.hudTop:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 0, 0)
            if w and h then DeadMarker2.hudTop:SetDimensions(w, h) end
            return DeadMarker2.hudTop
        end

        local tlw = _SafeCreateTLW("DeadMarker2HUDTop")
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

        DeadMarker2.hudTop = tlw

        if not DeadMarker2.fragment then
            pcall(function()
                if ZO_SimpleSceneFragment and HUD_SCENE and HUD_UI_SCENE then
                    DeadMarker2.fragment = ZO_SimpleSceneFragment:New(tlw)
                    HUD_SCENE:AddFragment(DeadMarker2.fragment)
                    HUD_UI_SCENE:AddFragment(DeadMarker2.fragment)
                    ddm("HUD fragment added")
                end
            end)
        end
        return tlw
    end)
    if ok then return result end
    ddm("ensureHUDTop error: " .. tostring(result))
    return DeadMarker2.hudTop
end

-- Pure 2D overlay for arrow / callout (never hosts SPACE_WORLD pins)
ensureScreenUI = function()
    local ok, result = pcall(function()
        if DeadMarker2.screenUI then
            local w, h = GuiRoot:GetDimensions()
            DeadMarker2.screenUI:ClearAnchors()
            DeadMarker2.screenUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 0, 0)
            if w and h then DeadMarker2.screenUI:SetDimensions(w, h) end
            DeadMarker2.screenUI:SetHidden(false)
            return DeadMarker2.screenUI
        end

        local tlw = _SafeCreateTLW("DeadMarker2ScreenUI")
        if not tlw then return nil end
        tlw:SetMouseEnabled(false)
        tlw:SetMovable(false)
        tlw:SetClampedToScreen(true)
        tlw:SetDrawLayer(DL_OVERLAY)
        tlw:SetDrawTier(DT_HIGH)
        tlw:SetDrawLevel(310000)
        if tlw.SetTopmost then tlw:SetTopmost(true) end

        local w, h = GuiRoot:GetDimensions()
        tlw:ClearAnchors()
        tlw:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 0, 0)
        if w and h then tlw:SetDimensions(w, h) end
        tlw:SetAlpha(1)
        tlw:SetHidden(false)

        -- Keep visible in HUD + HUD UI scenes
        pcall(function()
            if ZO_SimpleSceneFragment and HUD_SCENE and HUD_UI_SCENE then
                local frag = ZO_SimpleSceneFragment:New(tlw)
                HUD_SCENE:AddFragment(frag)
                HUD_UI_SCENE:AddFragment(frag)
                DeadMarker2.screenUIFragment = frag
            end
        end)

        DeadMarker2.screenUI = tlw
        return tlw
    end)
    if ok then return result end
    ddm("ensureScreenUI error: " .. tostring(result))
    return DeadMarker2.screenUI
end

local function hideLater(ctl, ms)
    if ctl then zo_callLater(function() ctl:SetHidden(true) end, ms or 3000) end
end

local function ensureHudIcon()
    if DeadMarker2.hudIcon then return DeadMarker2.hudIcon end
    local ok, result = pcall(function()
        local parent = ensureHUDTop()
        if not parent then return nil end
        local c = _SafeCreateControl("DeadMarker2_HUDIcon", parent, CT_TEXTURE)
        if not c then return nil end
        c:ClearAnchors()
        c:SetAnchor(CENTER, parent, CENTER, 120, 0)
        c:SetDimensions(96, 96)
        c:SetDrawLayer(DL_OVERLAY); c:SetDrawTier(DT_HIGH); c:SetDrawLevel(310001)
        if TEX_BLEND_MODE_ALPHA and c.SetBlendMode then c:SetBlendMode(TEX_BLEND_MODE_ALPHA) end
        local sv = DeadMarker2.savedVars or {}
        _SetTextureSafe(c, sv.iconChoice or DEFAULT_WS_TEXTURE, DEFAULT_WS_TEXTURE)
        c:SetColor(1, 1, 1, sv.opacity or 1.0)
        c:SetHidden(false)
        return c
    end)
    if ok and result then
        DeadMarker2.hudIcon = result
        return result
    end
    ddm("HUDIcon create failed: " .. tostring(result))
    return nil
end

-- ======================== World-space helpers ==========================
local function WS_GetRenderOriginWorld()
    local sx, sy, sz = GuiRender3DPositionToWorldPosition(0, 0, 0)
    if not sx then return GetUnitRawWorldPosition("player") end
    return sx, sy, sz
end

function WS_SetAtRaw(ctl, x, y, z)
    if not ctl then return end
    local sx, sy, sz = WS_GetRenderOriginWorld()
    if not sx or not sy or not sz then
        ctl:ClearAnchors()
        ctl:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
        return
    end
    local dx = (x - sx) / 100
    local dy = (y - sy) / 100
    local dz = (z - sz) / 100
    ctl:SetTransformOffset(dx, dy, dz)
    local fx, _, fz = GetCameraForward(SPACE_WORLD)
    if fx and fz then
        local yaw = -math.atan2(fx, fz)
        ctl:SetTransformRotation(0, yaw, 0)
    end
    ctl:SetHidden(false)
end

local function WS_CreateTexture(unitTag, sizeM, texturePath, color, forceTint)
    local ok, result = pcall(function()
        local name   = uniqueName("DeadMarker2_WSIcon_" .. tostring(unitTag or "u"))
        local parent = ensureHUDTop()
        if not parent then return nil end
        local ctl = _SafeCreateControl(name, parent, CT_TEXTURE)
        if not ctl then return nil end
        ctl:SetHidden(true)
        if SPACE_WORLD and ctl.SetSpace then ctl:SetSpace(SPACE_WORLD) end
        if ctl.SetTransformNormalizedOriginPoint then
            ctl:SetTransformNormalizedOriginPoint(0.5, 0.5)
        end
        ctl:SetDrawLayer(DL_OVERLAY); ctl:SetDrawTier(DT_HIGH); ctl:SetDrawLevel(360000)

        local sv = DeadMarker2.savedVars or {}
        _SetTextureSafe(ctl, texturePath or (sv.iconChoice or DEFAULT_WS_TEXTURE), DEFAULT_WS_TEXTURE)

        local r, g, b = unpack(color or {1, 1, 1})
        _ApplyPinColor(ctl, r, g, b, sv.opacity or 1.0, { force = forceTint == true })
        ctl:SetAlpha(sv.opacity or 1.0)
        if ctl.SetScale then ctl:SetScale(1/100) end
        if ctl.SetTransformScale then
            ctl:SetTransformScale(sizeM or sv.worldIconMeters or 1.2)
        end
        ctl:SetDimensions(128, 128)
        DeadMarker2.wsPins[name] = ctl
        return ctl
    end)
    if ok then return result end
    ddm("WS_CreateTexture error: " .. tostring(result))
    return nil
end

-- ======================== Group + roles ================================
local function CacheUnitInfo(unitTag)
    if not unitTag or not DoesUnitExist(unitTag) then return end
    local name    = GetUnitDisplayName(unitTag) or GetUnitName(unitTag) or unitTag
    local rawRole = (GetGroupMemberSelectedRole and GetGroupMemberSelectedRole(unitTag)) or "dps"
    DeadMarker2.groupInfo[unitTag] = { name = name, role = normalizeRole(rawRole) }
end

local function RefreshGroupCache()
    DeadMarker2.groupInfo = {}
    if GetGroupSize() <= 1 then
        CacheUnitInfo("player")
        return
    end
    for i = 1, GetGroupSize() do
        local tag = GetGroupUnitTagByIndex(i)
        if tag and DoesUnitExist(tag) then CacheUnitInfo(tag) end
    end
    zo_callLater(function()
        for i = 1, GetGroupSize() do
            local tag = GetGroupUnitTagByIndex(i)
            if tag and DoesUnitExist(tag) and not DeadMarker2.groupInfo[tag] then
                CacheUnitInfo(tag)
            end
        end
    end, 500)
end

-- ======================== Panel creation & layout =======================
local function CreateRezPanel()
    if DeadMarker2.rezPanel then return DeadMarker2.rezPanel end
    local ok, result = pcall(function()
        local sv = DeadMarker2.savedVars or {}
        local panel = _SafeCreateTLW("DeadMarker2RezPanel")
        if not panel then return nil end
        panel:SetDimensions(520, 200)
        panel:SetMovable(true)
        panel:SetMouseEnabled(true)
        panel:SetClampedToScreen(true)
        panel:ClearAnchors()
        panel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.panelOffsetX or 60, sv.panelOffsetY or 240)
        panel:SetHidden(true)

        -- Fixed global names so reload / re-entry can reuse safely
        local back = _SafeCreateControl("DeadMarker2RezPanelBackdrop", panel, CT_BACKDROP)
        if back then
            back:SetAnchorFill()
            back:SetCenterColor(0, 0, 0, sv.panelOpacity or 0.95)
            back:SetEdgeColor(1, 1, 1, sv.panelOpacity or 0.95)
            if back.SetEdgeTexture then pcall(function() back:SetEdgeTexture(nil, 1, 1, 3) end) end
            back:SetDrawLayer(DL_OVERLAY); back:SetDrawTier(DT_HIGH); back:SetDrawLevel(340000)
        end

        local title = _SafeCreateControl("DeadMarker2RezPanelTitle", panel, CT_LABEL)
        if title then
            title:SetFont("DeadMarker2_TitleFont")
            title:ClearAnchors()
            title:SetAnchor(TOPLEFT, panel, TOPLEFT, 12, 8)
            title:SetText("Resurrection Targets (0)")
            title:SetDrawLayer(DL_OVERLAY); title:SetDrawTier(DT_HIGH); title:SetDrawLevel(340010)
        end

        local label = _SafeCreateControl("DeadMarker2RezPanelLabel", panel, CT_LABEL)
        if label then
            label:SetFont("DeadMarker2_RowFont")
            label:ClearAnchors()
            label:SetAnchor(TOPLEFT, panel, TOPLEFT, 12, 50)
            label:SetDimensions(492, 400)
            if TEXT_ALIGN_LEFT then label:SetHorizontalAlignment(TEXT_ALIGN_LEFT) end
            if TEXT_ALIGN_TOP then label:SetVerticalAlignment(TEXT_ALIGN_TOP) end
            if TEXT_WRAP_MODE_TRUNCATE then label:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE) end
            label:SetText("No dead units")
            label:SetDrawLayer(DL_OVERLAY); label:SetDrawTier(DT_HIGH); label:SetDrawLevel(340010)
        end

        local measure = _SafeCreateControl("DeadMarker2RezPanelMeasure", panel, CT_LABEL)
        if measure then
            measure:SetFont("DeadMarker2_RowFont")
            if TEXT_ALIGN_LEFT then measure:SetHorizontalAlignment(TEXT_ALIGN_LEFT) end
            if TEXT_ALIGN_TOP then measure:SetVerticalAlignment(TEXT_ALIGN_TOP) end
            if TEXT_WRAP_MODE_TRUNCATE then measure:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE) end
            measure:SetHidden(true)
        end

        local clearButton = _SafeCreateControl("DeadMarker2RezPanelClearButton", panel, CT_BUTTON)
        if clearButton then
            clearButton:ClearAnchors()
            clearButton:SetAnchor(BOTTOMRIGHT, panel, BOTTOMRIGHT, -10, -10)
            clearButton:SetText("Clear")
            clearButton:SetHandler("OnClicked", function()
                pcall(function() DeadMarker2.ClearAll() end)
            end)
        end

        -- Bail if core pieces missing (avoid half-built panel)
        if not title or not label then return nil end

        panel.title, panel.label, panel.measure, panel.clearButton, panel.backdrop =
            title, label, measure, clearButton, back
        return panel
    end)
    if ok and result then
        DeadMarker2.rezPanel = result
        return result
    end
    ddm("CreateRezPanel failed: " .. tostring(result))
    return nil
end

local function _ApplyPanelLayout()
    if not DeadMarker2.rezPanel then return end
    local sv = DeadMarker2.savedVars
    local panel = DeadMarker2.rezPanel
    local back  = panel.backdrop
    panel:ClearAnchors()
    panel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.panelOffsetX or 60, sv.panelOffsetY or 240)
    if back then
        local a = sv.panelOpacity or 0.95
        back:SetCenterColor(0, 0, 0, a)
        back:SetEdgeColor(1, 1, 1, a)
    end
end

-- --------- Text measuring (no wrap) & font autoscale -------------------
local function _EnsureMeasureLabel()
    if DeadMarker2.rezPanel and DeadMarker2.rezPanel.measure then
        return DeadMarker2.rezPanel.measure
    end
    if not DeadMarker2._measureLabel then
        local lbl = WINDOW_MANAGER:CreateControl("DeadMarker2_MeasureLabel", GuiRoot, CT_LABEL)
        lbl:SetHidden(true)
        lbl:SetFont("DeadMarker2_RowFont")
        lbl:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        lbl:SetVerticalAlignment(TEXT_ALIGN_TOP)
        lbl:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
        DeadMarker2._measureLabel = lbl
    end
    return DeadMarker2._measureLabel
end

local function _MeasureTextWidth(plain)
    local lbl = _EnsureMeasureLabel()
    lbl:SetText(plain or "")
    return math.ceil(lbl:GetTextWidth() or 0)
end

-- Compute required width for a list of 1-line strings under current font
local function _LongestWidth(lines, fallback)
    local longest = 0
    if lines and #lines > 0 then
        for _, s in ipairs(lines) do
            local w = _MeasureTextWidth(s or "")
            if w > longest then longest = w end
        end
    else
        longest = _MeasureTextWidth(fallback or "No dead units")
    end
    return longest
end

-- Autoscale font down (integer steps) until width fits max usable width or min font reached.
local function _AutoScaleFontToFit(maxUsableWidth, baseList, withStatusList)
    local sv = DeadMarker2.savedVars
    local size = sv.panelFontSize or 24
    local minS = sv.minPanelFontSize or 18

    -- try current size first
    SetRowFontSize(size)
    local needW = math.max(_LongestWidth(baseList), _LongestWidth(withStatusList))
    if needW <= maxUsableWidth then return size, needW end

    -- shrink until fits or min
    for s = size - 1, minS, -1 do
        SetRowFontSize(s)
        needW = math.max(_LongestWidth(baseList), _LongestWidth(withStatusList))
        if needW <= maxUsableWidth then return s, needW end
    end
    -- if still too large at min size, return min size (will clip to max width but lines are still single-line)
    return minS, math.max(_LongestWidth(baseList), _LongestWidth(withStatusList))
end

-- ======================== Panel tick / visuals ==========================
local function _IsValidUnitKey(unitTag)
    if not unitTag then return false end
    if unitTag == "player" then return true end
    if string.match(unitTag, "^group%d+$") then return true end
    if string.match(unitTag, "^sample_") then return true end
    return false
end

local function _ShouldPruneUnit(unitTag)
    if string.match(unitTag or "", "^sample_") then
        return not (DeadMarker2._inSamplePanel or DeadMarker2.forceShowPanel)
    end
    if not _IsValidUnitKey(unitTag) then return true end
    return not DoesUnitExist(unitTag)
end

local function _FindDeadUnitByName(name)
    if not name then return nil end
    for utag, data in pairs(DeadMarker2.deadUnits) do
        if data and data.name == name then return utag end
    end
    return nil
end

local function _AliveCleanup(unitTag)
    local e = DeadMarker2.deadUnits[unitTag]
    if not e then return end
    if e.pinId then
        e.pinId:SetHidden(true)
        DeadMarker2.wsPins[e.pinId:GetName()] = nil
    end
    DeadMarker2.deadUnits[unitTag] = nil
end

local function _RefreshPinVisual(unitTag, entry)
    if not entry or not entry.pinId then return end
    local sv  = DeadMarker2.savedVars
    local pin = entry.pinId

    local desired = _GetIconFor(entry.role or "dps")
    _SetTextureSafe(pin, desired, sv.iconChoice or DEFAULT_WS_TEXTURE)

    local isDead, rezzing, pending = GetRezFlags(unitTag)

    if rezzing then
        _ApplyPinColor(pin, 0, 0.65, 1, sv.opacity, { force = true })   -- REZZING -> BLUE
        entry.color = {0, 0.65, 1}
        entry.rezPending = true
    elseif pending then
        _ApplyPinColor(pin, 1, 1, 1, sv.opacity, { force = true })      -- PENDING -> WHITE
        entry.color = {1, 1, 1}
        entry.rezPending = true
    else
        if isDead then
            _ApplyPinColor(pin, 1, 0, 0, sv.opacity, { force = true })   -- DEAD -> RED
            entry.color = {1, 0, 0}
            entry.rezPending = false
        end
    end
end

local function _PanelTick()
    local sv = DeadMarker2.savedVars

    -- Clear alive/invalid
    for unitTag, _ in pairs(DeadMarker2.deadUnits) do
        if string.match(unitTag or "", "^sample_") then
            -- keep samples until timeout
        elseif _IsValidUnitKey(unitTag) then
            if IsUnitDead and IsUnitDead(unitTag) == false then
                _AliveCleanup(unitTag)
            end
        else
            _AliveCleanup(unitTag)
        end
    end

    -- Drive textures + state colors
    for unitTag, entry in pairs(DeadMarker2.deadUnits) do
        _RefreshPinVisual(unitTag, entry)
    end

    -- If rez state flipped, Priority Target may advance — optional re-callout
    pcall(function()
        local ptag = select(1, ResolvePriorityTarget())
        if ptag and ptag ~= DeadMarker2._lastCalloutTag and sv.calloutOnPriorityChange then
            MaybeRezCalloutForPriority("priority_change")
        elseif not ptag then
            DeadMarker2._lastCalloutTag = nil
        end
    end)

    pcall(UpdateRezPanel)

    local anyDead    = next(DeadMarker2.deadUnits) ~= nil
    local shouldShow = sv.enableRezPanel and (anyDead or DeadMarker2.forceShowPanel)
    if not shouldShow then
        EVENT_MANAGER:UnregisterForUpdate(DeadMarker2._panelTickerName)
        DeadMarker2._panelTickerRunning = false
    end
end

local function _MaybeStartPanelTicker()
    if DeadMarker2._panelTickerRunning then return end
    EVENT_MANAGER:RegisterForUpdate(DeadMarker2._panelTickerName, 1000, _PanelTick)
    DeadMarker2._panelTickerRunning = true
end

local function _MaybeStopPanelTicker()
    if not DeadMarker2._panelTickerRunning then return end
    EVENT_MANAGER:UnregisterForUpdate(DeadMarker2._panelTickerName)
    DeadMarker2._panelTickerRunning = false
end

-- ======================== UpdateRezPanel ================================
UpdateRezPanel = function()
    local sv = DeadMarker2.savedVars
    local panel = DeadMarker2.rezPanel or CreateRezPanel()
    if not panel then return end

    local title       = panel.title
    local label       = panel.label
    local measure     = panel.measure
    local clearButton = panel.clearButton

    -- Prune invalid
    for unitTag, data in pairs(DeadMarker2.deadUnits) do
        if _ShouldPruneUnit(unitTag) then
            if data and data.pinId then
                data.pinId:SetHidden(true)
                DeadMarker2.wsPins[data.pinId:GetName()] = nil
            end
            DeadMarker2.deadUnits[unitTag] = nil
        end
    end

    -- Build rows with name-based dedupe
    local rows, seen = {}, {}
    for unitTag, data in pairs(DeadMarker2.deadUnits) do
        if _IsValidUnitKey(unitTag) then
            local cache = DeadMarker2.groupInfo[unitTag] or {}
            local name  = cache.name or GetUnitDisplayName(unitTag) or GetUnitName(unitTag) or unitTag
            if not seen[name] then
                seen[name] = true
                local role  = normalizeRole(cache.role or data.role or "dps")
                local _, px, py, pz = GetUnitRawWorldPosition("player")
                local dx, dz = (data.x or 0) - (px or 0), (data.z or 0) - (pz or 0)
                local dist   = math.floor((math.sqrt(dx * dx + dz * dz)) / 100)
                local timeDead = data.timeDeadStart and math.floor((GetFrameTimeMilliseconds() - data.timeDeadStart) / 1000) or 0

                local _, rezzing, pending = GetRezFlags(unitTag)
                local basePlain = sv.showTimers
                    and string.format("%s: %s, Dist=%dm, Time=%ds", string.upper(role or "DPS"), name, dist or 0, timeDead or 0)
                    or  string.format("%s: %s, Dist=%dm", string.upper(role or "DPS"), name, dist or 0)

                local statusPlain = (rezzing and " REZZING") or (pending and " PENDING") or ""
                local statusRich  = (rezzing and " |c33AAFFREZZING|r") or (pending and " |cFFFFFFPENDING|r") or ""
                local rich = string.format("|c%s%s|r%s",
                    (role=="tank" and "FF5555") or (role=="healer" and "FFFF55") or "FFFFFF",
                    basePlain, statusRich)

                rows[#rows+1] = {
                    name=name, role=role,
                    basePlain=basePlain,
                    withStatusPlain=(basePlain .. statusPlain):gsub("%s+", " "):gsub("%s$", ""),
                    richLine=rich,
                }
            end
        end
    end

    table.sort(rows, function(a, b)
        local pa = (a.role == "tank" and sv.priorityTank) or (a.role == "healer" and sv.priorityHealer) or sv.priorityDPS
        local pb = (b.role == "tank" and sv.priorityTank) or (b.role == "healer" and sv.priorityHealer) or sv.priorityDPS
        if pa ~= pb then return pa < pb end
        return a.name < b.name
    end)

    local anyDead = (#rows > 0)
    if (not anyDead and not DeadMarker2.forceShowPanel) or not sv.enableRezPanel then
        panel:SetHidden(true)
        if title then title:SetText("Resurrection Targets (0)") end
        if label then
            label:SetText("No dead units")
            label:SetDimensions(300, 40)
        end
        if clearButton then clearButton:SetHidden(true) end
        DeadMarker2._stickyBaseWidth = 0 -- reset baseline when hidden
        SetRowFontSize(sv.panelFontSize or 24) -- restore default size next time
        _MaybeStopPanelTicker()
        return
    end

    -- Build plain lists for sizing & display lines
    local baseList, withStatusList, displayLines = {}, {}, {}
    for _, r in ipairs(rows) do
        baseList[#baseList+1]        = r.basePlain
        withStatusList[#withStatusList+1] = r.withStatusPlain
        displayLines[#displayLines+1] = r.richLine
    end

    -- 1) Try current font size; measure longest base + status widths
    local padX = sv.panelPaddingX or 28
    local padY = sv.panelPaddingY or 16
    local maxW = sv.maxPanelWidth or 980
    local minW = sv.minPanelWidth or 420
    local titleH = math.ceil((panel.title and panel.title:GetTextHeight()) or 34)

    -- ensure measuring label uses current font
    SetRowFontSize(DeadMarker2._lastAppliedFontSize or (sv.panelFontSize or 24))

    local baseW   = _LongestWidth(baseList, "No dead units")
    local statusW = _LongestWidth(withStatusList, "No dead units")

    -- Sticky baseline: panel should never shrink smaller than the longest base line seen while visible
    DeadMarker2._stickyBaseWidth = math.max(DeadMarker2._stickyBaseWidth or 0, baseW)

    local neededContentW = math.max(DeadMarker2._stickyBaseWidth, statusW)
    local naturalPanelW  = neededContentW + padX * 2

    -- 2) If natural width exceeds max, auto-shrink font until fits (no wrapping)
    local targetPanelW, finalFont = naturalPanelW, DeadMarker2._lastAppliedFontSize or (sv.panelFontSize or 24)
    if naturalPanelW > maxW then
        local maxUsable = maxW - padX * 2
        local chosen, recomputedNeed = _AutoScaleFontToFit(maxUsable, baseList, withStatusList)
        finalFont = chosen
        targetPanelW = math.min(maxW, recomputedNeed + padX * 2)
    else
        -- make sure we're using configured size if we previously shrank
        SetRowFontSize(sv.panelFontSize or 24)
        finalFont = sv.panelFontSize or 24
    end

    -- Clamp to minimum width in any case
    targetPanelW = math.max(minW, targetPanelW)

    -- 3) Apply width first, then set label text/height (no wrapping)
    local labelW = targetPanelW - padX * 2
    local lineH  = math.max(24, math.floor((finalFont) * 1.35))
    local labelH = lineH * math.max(#displayLines, 1)

    if title then
        title:ClearAnchors()
        title:SetAnchor(TOPLEFT, panel, TOPLEFT, padX, padY)
        title:SetText(string.format("Resurrection Targets (%d)", #rows))
    end

    label:SetFont("DeadMarker2_RowFont")
    label:ClearAnchors()
    label:SetAnchor(TOPLEFT, panel, TOPLEFT, padX, padY + titleH - 2)
    label:SetDimensions(labelW, labelH)
    label:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE) -- keep single-line rows; multiple rows via "\n"
    label:SetText(#displayLines > 0 and table.concat(displayLines, "\n") or "No dead units")

    local targetHeight = padY * 2 + titleH + labelH
    panel:SetDimensions(targetPanelW, targetHeight)
    if panel.backdrop then panel.backdrop:SetDimensions(targetPanelW, targetHeight) end

    if clearButton then clearButton:SetHidden(#rows == 0) end

    _ApplyPanelLayout()
    panel:SetHidden(false)
    _MaybeStartPanelTicker()
end

-- ======================== TrackDeath ====================================
local function _canonicalCompare(gtag)
    if not gtag or (DoesUnitExist and not DoesUnitExist(gtag)) then return false end
    if AreUnitsEqual then return AreUnitsEqual(gtag, "player") end
    local a = GetUnitDisplayName and GetUnitDisplayName(gtag) or GetUnitName(gtag)
    local b = GetUnitDisplayName and GetUnitDisplayName("player") or GetUnitName("player")
    return a ~= nil and b ~= nil and a == b
end

local function _CanonicalUnitTag(unitTag)
    if unitTag == "player" and GetGroupSize() > 1 then
        for i = 1, GetGroupSize() do
            local gtag = GetGroupUnitTagByIndex(i)
            if _canonicalCompare(gtag) then return gtag end
        end
    end
    return unitTag
end

local function TrackDeath(unitTag, isDead)
    local sv = DeadMarker2.savedVars

    unitTag = _CanonicalUnitTag(unitTag)
    if not unitTag or (not string.find(unitTag, "group") and unitTag ~= "player") then return end

    CacheUnitInfo(unitTag)
    local cache = DeadMarker2.groupInfo[unitTag] or {}
    local name  = cache.name or unitTag
    local role  = normalizeRole(cache.role or "dps")

    -- Name-based dedupe: if we already track this displayName under a different tag, use that key
    local existingKey = _FindDeadUnitByName(name)
    if existingKey and existingKey ~= unitTag then
        unitTag = existingKey
        cache = DeadMarker2.groupInfo[unitTag] or cache
    end

    -- Guard: chat "has died" only once per actual tracked death
    local alreadyTrackedDead = (DeadMarker2.deadUnits[unitTag] ~= nil)

    if isDead then
        local _, x, y, z = GetUnitRawWorldPosition(unitTag)
        if x and y and z then
            local colorDead = {1, 0, 0} -- RED
            local texPath   = _GetIconFor(role)

            if not DeadMarker2.deadUnits[unitTag] then
                -- FIRST time we see this unit as dead -> create pin + announce
                local pin = WS_CreateTexture(unitTag, sv.worldIconMeters or 1.2, texPath, colorDead, true)
                if pin then
                    _SetTextureSafe(pin, texPath, sv.iconChoice or DEFAULT_WS_TEXTURE)
                    WS_SetAtRaw(pin, x, y + (sv.yOffsetMeters or 2.0) * 100, z)

                    DeadMarker2.deadUnits[unitTag] = {
                        name = name, role = role,
                        x = x, y = y, z = z,
                        timeDeadStart = GetFrameTimeMilliseconds(),
                        pinId = pin, color = colorDead, rezPending = false
                    }

                    _StartPinTicker()

                    if sv.showChatAlerts and not alreadyTrackedDead then
                        d(string.format("[DeadMarker2] %s has died", name))
                    end

                    -- Ping + callout for others only (never "rez yourself")
                    if not alreadyTrackedDead and not _IsLocalPlayerUnit(unitTag) then
                        MaybeDeathPing(role)
                        MaybeRezCalloutForPriority("death")
                    elseif not alreadyTrackedDead then
                        -- Still refresh priority UI in case group mates are also down
                        pcall(function()
                            ResolvePriorityTarget()
                            _UpdateArrowIndicator(GetFrameTimeMilliseconds())
                        end)
                    end
                end
            else
                -- Already tracked as dead -> update coords/role/pin visuals, but DO NOT re-announce or reset timer
                local data = DeadMarker2.deadUnits[unitTag]
                data.name, data.role = name, role
                data.x, data.y, data.z = x, y, z
                data.color = colorDead
                data.rezPending = false
                -- keep original death start time
                data.timeDeadStart = data.timeDeadStart or GetFrameTimeMilliseconds()

                if data.pinId then
                    _SetTextureSafe(data.pinId, texPath, sv.iconChoice or DEFAULT_WS_TEXTURE)
                    WS_SetAtRaw(data.pinId, x, y + (sv.yOffsetMeters or 2.0) * 100, z)
                    _ApplyPinColor(data.pinId, colorDead[1], colorDead[2], colorDead[3], sv.opacity, { force = true })
                    _StartPinTicker()
                end
            end
        end

        UpdateRezPanel()
        _MaybeStartPanelTicker()
        return
    end

    -- REVIVED
    local entry = DeadMarker2.deadUnits[unitTag]
    if entry and entry.pinId then
        local pin = entry.pinId
        _ApplyPinColor(pin, 0, 0.65, 1, sv.opacity, { force = true })
        zo_callLater(function()
            if DeadMarker2.deadUnits[unitTag] then
                local p = DeadMarker2.deadUnits[unitTag].pinId
                if p then
                    p:SetHidden(true)
                    DeadMarker2.wsPins[p:GetName()] = nil
                end
                DeadMarker2.deadUnits[unitTag] = nil

                if sv.showChatAlerts then
                    d(string.format("[DeadMarker2] %s revived", name))
                end

                local hasPins = false
                for _, dta in pairs(DeadMarker2.deadUnits) do
                    if dta.pinId and not dta.pinId:IsHidden() then hasPins = true break end
                end
                if not hasPins and not DeadMarker2.following then
                    _StopPinTicker()
                end

                UpdateRezPanel()
                _MaybeStartPanelTicker()
            end
        end, 2000)
    else
        UpdateRezPanel()
        _MaybeStartPanelTicker()
    end
end

-- ======================== Resurrect request event =======================
local function OnResurrectRequest(_, unitTag)
    unitTag = _CanonicalUnitTag(unitTag)
    if DeadMarker2.deadUnits[unitTag] and DeadMarker2.deadUnits[unitTag].pinId then
        local pin = DeadMarker2.deadUnits[unitTag].pinId
        local sv  = DeadMarker2.savedVars
        DeadMarker2.deadUnits[unitTag].color = {1, 1, 1}
        DeadMarker2.deadUnits[unitTag].rezPending = true
        _ApplyPinColor(pin, 1, 1, 1, sv.opacity, { force = true }) -- PENDING -> white
        UpdateRezPanel() -- will expand if needed
        -- Priority Target may advance away from this corpse
        if sv and sv.calloutOnPriorityChange then
            MaybeRezCalloutForPriority("priority_change")
        end
    end
end

-- ======================== Sample panel ==================================
local function ShowSampleRezPanel()
    DeadMarker2.forceShowPanel  = true
    DeadMarker2._inSamplePanel  = true
    DeadMarker2._stickyBaseWidth = 0  -- fresh baseline for this session

    -- Hard reset samples to avoid name dedupe from prior run
    for unitTag, data in pairs(DeadMarker2.deadUnits) do
        if string.find(unitTag or "", "^sample_") then
            if data.pinId then data.pinId:SetHidden(true); DeadMarker2.wsPins[data.pinId:GetName()] = nil end
            DeadMarker2.deadUnits[unitTag] = nil
            DeadMarker2.groupInfo[unitTag] = nil
        end
    end

    local sv = DeadMarker2.savedVars
    local _, px, py, pz = GetUnitRawWorldPosition("player")
    px, py, pz = px or 0, py or 0, pz or 0
    local now = GetFrameTimeMilliseconds()

    local sampleUnits = {
        { unitTag = "sample_tank_"..now,   name = "TankPlayer",   role = "tank",   x = px + 100, y = py, z = pz + 100, timeDeadStart = now },
        { unitTag = "sample_healer_"..now, name = "HealerPlayer", role = "healer", x = px + 200, y = py, z = pz + 200, timeDeadStart = now - 5000 },
        { unitTag = "sample_dps_"..now,    name = "DPSPlayer",    role = "dps",    x = px + 300, y = py, z = pz + 300, timeDeadStart = now - 10000 },
    }

    -- Preview: leave all three eligible so Priority Target prefers tank (priority 1).
    -- Arrow / highlight / callout all use the same resolver.

    for _, unit in ipairs(sampleUnits) do
        DeadMarker2.groupInfo[unit.unitTag] = { name = unit.name, role = unit.role }
        local texPath = _GetIconFor(unit.role)
        local pin = WS_CreateTexture(unit.unitTag, sv.worldIconMeters or 1.2, texPath, {1, 0, 0}, true)
        if pin then
            _SetTextureSafe(pin, texPath, sv.iconChoice or DEFAULT_WS_TEXTURE)
            WS_SetAtRaw(pin, unit.x, unit.y + (sv.yOffsetMeters or 2.0) * 100, unit.z)
            unit.pinId = pin
        end
        DeadMarker2.deadUnits[unit.unitTag] = unit
    end

    -- Ensure billboard/highlight/arrow animation is visible during sample mode.
    _StartPinTicker()
    MaybeRezCalloutForPriority("sample")

    UpdateRezPanel()
    _MaybeStartPanelTicker()

    zo_callLater(function()
        for _, unit in ipairs(sampleUnits) do
            if unit.pinId then unit.pinId:SetHidden(true); DeadMarker2.wsPins[unit.pinId:GetName()] = nil end
            DeadMarker2.deadUnits[unit.unitTag] = nil
            DeadMarker2.groupInfo[unit.unitTag] = nil
        end
        DeadMarker2.forceShowPanel = false
        DeadMarker2._inSamplePanel = false
        UpdateRezPanel()
        _MaybeStartPanelTicker()

        -- If nothing else is showing, stop the pin ticker.
        local hasPins = false
        for _, dta in pairs(DeadMarker2.deadUnits) do
            if dta and dta.pinId and not dta.pinId:IsHidden() then hasPins = true break end
        end
        if not hasPins and not DeadMarker2.following then
            _StopPinTicker()
        end
    end, 10000)
end

-- ======================== SelfTest / commands ===========================
local function SelfTest()
    Caps()
    ensureHUDTop()
    local parent = DeadMarker2.hudTop
    local w, h = parent:GetDimensions()
    local flash = WINDOW_MANAGER:CreateControl(uniqueName("DeadMarker2_Flash"), parent, CT_BACKDROP)
    flash:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)
    flash:SetDimensions(w, h)
    flash:SetDrawLayer(DL_OVERLAY); flash:SetDrawTier(DT_HIGH); flash:SetDrawLevel(330000)
    flash:SetCenterColor(0, 0.7, 0, 0.23)
    flash:SetEdgeColor(0, 0, 0, 0)
    flash:SetHidden(false)
    hideLater(flash, 900)

    local _, px, py, pz = GetUnitRawWorldPosition("player")
    if px and py and pz then
        local head = GetPlayerCameraHeading() or 0
        local forward = 240
        local arc = {-0.35, 0.0, 0.35}
        for i = 1, 3 do
            local a = head + arc[i]
            local tx = px + math.sin(a) * forward
            local tz = pz + math.cos(a) * forward
            local tex = TEST_TEXTURE_LIST[i] or (DeadMarker2.savedVars.iconChoice or DEFAULT_WS_TEXTURE)
            local pin = WS_CreateTexture("test"..i, DeadMarker2.savedVars.worldIconMeters or 1.2, tex, {1, 1, 1})
            if pin then WS_SetAtRaw(pin, tx, py + (DeadMarker2.savedVars.yOffsetMeters or 2.0) * 100, tz) end
        end
    end
    local hudIcon = ensureHudIcon()
    if hudIcon then hideLater(hudIcon, 3500) end
end

local function CmdMarkPlayer()
    if DeadMarker2.followCtl then
        DeadMarker2.followCtl:SetHidden(true)
        DeadMarker2.wsPins[DeadMarker2.followCtl:GetName()] = nil
        DeadMarker2.followCtl = nil
        DeadMarker2.following = false
    end
    local _, px, py, pz = GetUnitRawWorldPosition("player")
    if not px or not py or not pz then return end
    local texture = _GetIconFor("dps") -- neutral marker
    local pin = WS_CreateTexture("player", DeadMarker2.savedVars.worldIconMeters or 1.2, texture, {1, 1, 1})
    if not pin then return end
    _SetTextureSafe(pin, texture, DeadMarker2.savedVars.iconChoice or DEFAULT_WS_TEXTURE)
    WS_SetAtRaw(pin, px, py + (DeadMarker2.savedVars.yOffsetMeters or 2.0) * 100, pz)
    DeadMarker2.followCtl = pin
    DeadMarker2.following = true
    _StartPinTicker()
end

function DeadMarker2.ClearAll()
    for unitTag, data in pairs(DeadMarker2.deadUnits) do
        if data.pinId then
            data.pinId:SetHidden(true)
            DeadMarker2.wsPins[data.pinId:GetName()] = nil
        end
        DeadMarker2.deadUnits[unitTag] = nil
    end
    if DeadMarker2.followCtl then
        DeadMarker2.followCtl:SetHidden(true)
        DeadMarker2.wsPins[DeadMarker2.followCtl:GetName()] = nil
        DeadMarker2.followCtl = nil
        DeadMarker2.following = false
    end
    for _, pin in pairs(DeadMarker2.wsPins) do
        if pin then pin:SetHidden(true) end
    end
    DeadMarker2.wsPins = {}
    if DeadMarker2.hudIcon then
        DeadMarker2.hudIcon:SetHidden(true)
        DeadMarker2.hudIcon = nil
    end
    _HideArrow()
    if DeadMarker2.calloutCtl then DeadMarker2.calloutCtl:SetHidden(true) end
    if DeadMarker2._pingFlashCtl then DeadMarker2._pingFlashCtl:SetHidden(true) end
    DeadMarker2.priorityTag = nil
    DeadMarker2._lastCalloutTag = nil
    DeadMarker2._arrowTextureOk = nil
    DeadMarker2.forceShowPanel = false
    DeadMarker2._stickyBaseWidth = 0
    SetRowFontSize(DeadMarker2.savedVars.panelFontSize or 24)
    UpdateRezPanel()
    _MaybeStopPanelTicker()
    _StopPinTicker()
end

-- ======================== Settings Menu ================================
local function CreateSettingsMenu()
    if not LAM then return end
    local sv = DeadMarker2.savedVars
    if type(sv) ~= "table" then return end
    if type(sv.roleIcons) ~= "table" then
        sv.roleIcons = {
            tank = _defaults.roleIcons.tank,
            healer = _defaults.roleIcons.healer,
            dps = _defaults.roleIcons.dps,
        }
    end

    local panelData = {
        type = "panel",
        name = DeadMarker2.displayName or "DeadMarker2",
        displayName = (DeadMarker2.displayName or "DeadMarker2") .. " Settings",
        author = "Skye-Forge",
        version = DeadMarker2.version,
        slashCommand = "/deadmarker2settings",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local choices, choicesValues = {}, {}
    for path, name in pairs(TEST_TEXTURES) do
        table.insert(choices, name)
        table.insert(choicesValues, path)
    end

    local ROLE_CHOICES = {
        tank = {
            {"Addon Tank (dm2tank.dds)",   "/DeadMarker2/textures/dm2tank.dds"},
            {"ESO Tank (default)",         DEFAULT_ROLE_ICONS.tank},
        },
        healer = {
            {"Addon Healer (dm2healer.dds)","/DeadMarker2/textures/dm2healer.dds"},
            {"ESO Healer (default)",        DEFAULT_ROLE_ICONS.healer},
        },
        dps = {
            {"Addon DPS (dm2dps.dds)",     "/DeadMarker2/textures/dm2dps.dds"},
            {"ESO DPS (default)",          DEFAULT_ROLE_ICONS.dps},
        },
    }

    local function roleChoices(role)
        local names, values = {}, {}
        for _, pair in ipairs(ROLE_CHOICES[role]) do
            table.insert(names,  pair[1]); table.insert(values, pair[2])
        end
        return names, values
    end

    local function refreshAllPinTextures()
        for _, e in pairs(DeadMarker2.deadUnits) do
            if e.pinId then
                local p = _GetIconFor(e.role or "dps")
                _SetTextureSafe(e.pinId, p, sv.iconChoice or DEFAULT_WS_TEXTURE)
            end
        end
        if DeadMarker2.followCtl then
            local p = _GetIconFor("dps")
            _SetTextureSafe(DeadMarker2.followCtl, p, sv.iconChoice or DEFAULT_WS_TEXTURE)
        end
    end

    local optionsData = {
        -- ========== GENERAL ==========
        { type = "header", name = "General" },
        {
            type = "description",
            text = "DeadMarker2 — always know who to rez next. Pairs with Hide Group.\n"
                .. "v1.2.3: no self rez callout. Report bugs — fixes within hours.",
        },
        {
            type = "checkbox",
            name = "Enable Rez Panel",
            tooltip = "Show the resurrection panel when group members die.",
            getFunc = function() return sv.enableRezPanel end,
            setFunc = function(value)
                sv.enableRezPanel = value
                UpdateRezPanel()
                if value then _MaybeStartPanelTicker() else _MaybeStopPanelTicker() end
            end,
            default = true,
        },
        {
            type = "checkbox",
            name = "Show Timers (Time=xxs)",
            tooltip = "Toggle seconds shown in the panel rows.",
            getFunc = function() return sv.showTimers end,
            setFunc = function(v) sv.showTimers = v; UpdateRezPanel() end,
            default = true,
            disabled = function() return not sv.enableRezPanel end,
        },
        {
            type = "checkbox",
            name = "Chat Death/Revive Alerts",
            tooltip = "Legacy chat lines when someone dies or revives.",
            getFunc = function() return sv.showChatAlerts end,
            setFunc = function(v) sv.showChatAlerts = v end,
            default = true,
        },

        -- ========== ICONS & MARKERS ==========
        { type = "header", name = "Icons & Markers" },
        {
            type = "dropdown",
            name = "Global Fallback Icon",
            tooltip = "Only used if both the role icon and ESO role icon fail.",
            choices = choices,
            choicesValues = choicesValues,
            getFunc = function() return sv.iconChoice or DEFAULT_WS_TEXTURE end,
            setFunc = function(value)
                sv.iconChoice = value
                refreshAllPinTextures()
                if DeadMarker2.hudIcon then
                    _SetTextureSafe(DeadMarker2.hudIcon, sv.iconChoice, DEFAULT_WS_TEXTURE)
                end
            end,
            default = DEFAULT_WS_TEXTURE,
        },
        {
            type = "checkbox",
            name = "Use Role-Based Icons",
            tooltip = "When OFF, all pins use the Global Fallback Icon. When ON, each role uses its selected icon.",
            getFunc = function() return sv.useRoleIcons end,
            setFunc = function(v)
                sv.useRoleIcons = v
                refreshAllPinTextures()
            end,
            default = true,
        },
        {
            type = "dropdown",
            name = "Tank Icon",
            tooltip = "Choose the icon used for Tank deaths.",
            choices = (function() local n,_=roleChoices("tank"); return n end)(),
            choicesValues = (function() local _,v=roleChoices("tank"); return v end)(),
            getFunc = function()
                return (sv.roleIcons and sv.roleIcons.tank) or _defaults.roleIcons.tank
            end,
            setFunc = function(val)
                if type(sv.roleIcons) ~= "table" then sv.roleIcons = {} end
                sv.roleIcons.tank = val
                refreshAllPinTextures()
            end,
            default = "/DeadMarker2/textures/dm2tank.dds",
            disabled = function() return not sv.useRoleIcons end,
        },
        {
            type = "dropdown",
            name = "Healer Icon",
            tooltip = "Choose the icon used for Healer deaths.",
            choices = (function() local n,_=roleChoices("healer"); return n end)(),
            choicesValues = (function() local _,v=roleChoices("healer"); return v end)(),
            getFunc = function()
                return (sv.roleIcons and sv.roleIcons.healer) or _defaults.roleIcons.healer
            end,
            setFunc = function(val)
                if type(sv.roleIcons) ~= "table" then sv.roleIcons = {} end
                sv.roleIcons.healer = val
                refreshAllPinTextures()
            end,
            default = "/DeadMarker2/textures/dm2healer.dds",
            disabled = function() return not sv.useRoleIcons end,
        },
        {
            type = "dropdown",
            name = "DPS Icon",
            tooltip = "Choose the icon used for DPS deaths.",
            choices = (function() local n,_=roleChoices("dps"); return n end)(),
            choicesValues = (function() local _,v=roleChoices("dps"); return v end)(),
            getFunc = function()
                return (sv.roleIcons and sv.roleIcons.dps) or _defaults.roleIcons.dps
            end,
            setFunc = function(val)
                if type(sv.roleIcons) ~= "table" then sv.roleIcons = {} end
                sv.roleIcons.dps = val
                refreshAllPinTextures()
            end,
            default = "/DeadMarker2/textures/dm2dps.dds",
            disabled = function() return not sv.useRoleIcons end,
        },
        {
            type = "slider",
            name = "Icon Size (meters)",
            tooltip = "Set the size of dead player markers in meters.",
            min = 0.6, max = 2.0, step = 0.1,
            getFunc = function() return sv.worldIconMeters end,
            setFunc = function(value)
                sv.worldIconMeters = value
                for _, data in pairs(DeadMarker2.deadUnits) do
                    if data.pinId then data.pinId:SetTransformScale(value) end
                end
                if DeadMarker2.followCtl then DeadMarker2.followCtl:SetTransformScale(value) end
            end,
            default = 1.2,
        },
        {
            type = "slider",
            name = "Lift Above Ground (m)",
            tooltip = "Set the height of markers above the ground in meters.",
            min = 0.4, max = 8.0, step = 0.1,
            getFunc = function() return sv.yOffsetMeters end,
            setFunc = function(value)
                sv.yOffsetMeters = value
                for _, data in pairs(DeadMarker2.deadUnits) do
                    if data.pinId and data.x and data.y and data.z then
                        WS_SetAtRaw(data.pinId, data.x, data.y + value * 100, data.z)
                    end
                end
                if DeadMarker2.followCtl then
                    local _, px, py, pz = GetUnitRawWorldPosition("player")
                    if px and py and pz then WS_SetAtRaw(DeadMarker2.followCtl, px, py + value * 100, pz) end
                end
            end,
            default = 2.0,
        },
        {
            type = "slider",
            name = "Pin Opacity",
            tooltip = "0 = transparent, 1 = opaque (affects world icons).",
            min = 0.0, max = 1.0, step = 0.1,
            getFunc = function() return sv.opacity end,
            setFunc = function(value)
                value = tonumber(value) or 1.0
                if value < 0 then value = 0 elseif value > 1 then value = 1 end
                sv.opacity = value
                for _, data in pairs(DeadMarker2.deadUnits) do
                    if data and data.pinId then
                        local c = data.color or {1, 1, 1}
                        data.pinId:SetColor(c[1], c[2], c[3], value)
                        data.pinId:SetAlpha(value)
                    end
                end
                if DeadMarker2.followCtl then
                    DeadMarker2.followCtl:SetColor(1, 1, 1, value)
                    DeadMarker2.followCtl:SetAlpha(value)
                end
                for _, pin in pairs(DeadMarker2.wsPins) do
                    if pin then pin:SetAlpha(value) end
                end
            end,
            default = 1.0,
        },
        {
            type = "checkbox",
            name = "Highlight Priority Target",
            tooltip = "Pulse/spin the Priority Target pin (role priority, then closest; skips PENDING/REZZING). Same target as arrow and callout.",
            getFunc = function() return sv.highlightClosest end,
            setFunc = function(v) sv.highlightClosest = v end,
            default = false,
        },

        -- ========== PRIORITY ==========
        { type = "header", name = "Priority Target" },
        {
            type = "description",
            text = "Priority Target = best role priority (lower number wins), then closest eligible corpse. Arrow, death ping filters, pin highlight, and rez callout all use this rule. PENDING/REZZING corpses are skipped.",
        },
        {
            type = "slider",
            name = "Tank Priority",
            tooltip = "Lower number = higher priority.",
            min = 1, max = 3, step = 1,
            getFunc = function() return sv.priorityTank end,
            setFunc = function(value) sv.priorityTank = value; UpdateRezPanel() end,
            default = 1,
        },
        {
            type = "slider",
            name = "Healer Priority",
            tooltip = "Lower number = higher priority.",
            min = 1, max = 3, step = 1,
            getFunc = function() return sv.priorityHealer end,
            setFunc = function(value) sv.priorityHealer = value; UpdateRezPanel() end,
            default = 2,
        },
        {
            type = "slider",
            name = "DPS Priority",
            tooltip = "Lower number = higher priority.",
            min = 1, max = 3, step = 1,
            getFunc = function() return sv.priorityDPS end,
            setFunc = function(value) sv.priorityDPS = value; UpdateRezPanel() end,
            default = 3,
        },

        -- ========== ARROW ==========
        { type = "header", name = "Arrow Indicator" },
        {
            type = "checkbox",
            name = "Enable Arrow",
            tooltip = "Show a reticle-orbit arrow pointing at the Priority Target.",
            getFunc = function() return sv.enableArrow end,
            setFunc = function(v)
                sv.enableArrow = v
                if not v then _HideArrow() end
            end,
            default = true,
        },
        {
            type = "slider",
            name = "Arrow Size (px)",
            tooltip = "On-screen arrow size in pixels.",
            min = 32, max = 160, step = 2,
            getFunc = function() return sv.arrowSizePx or 64 end,
            setFunc = function(v) sv.arrowSizePx = math.floor(tonumber(v) or 64) end,
            default = 64,
            disabled = function() return not sv.enableArrow end,
        },
        {
            type = "slider",
            name = "Arrow Opacity",
            tooltip = "Arrow transparency (0 = invisible, 1 = solid).",
            min = 0.2, max = 1.0, step = 0.05,
            getFunc = function() return sv.arrowOpacity or 1.0 end,
            setFunc = function(v) sv.arrowOpacity = tonumber(v) or 1.0 end,
            default = 1.0,
            disabled = function() return not sv.enableArrow end,
        },
        {
            type = "slider",
            name = "Arrow Distance from Reticle",
            tooltip = "How far the arrow sits from screen center along the bearing (px).",
            min = 40, max = 220, step = 5,
            getFunc = function() return sv.arrowReticleDist or 100 end,
            setFunc = function(v) sv.arrowReticleDist = math.floor(tonumber(v) or 100) end,
            default = 100,
            disabled = function() return not sv.enableArrow end,
        },
        {
            type = "button",
            name = "Test Arrow (3s)",
            tooltip = "Force-show arrow at reticle for 3 seconds (debug visibility).",
            func = function()
                pcall(function()
                    ensureScreenUI()
                    local arrow = _EnsureArrow()
                    local parent = DeadMarker2.screenUI or ensureHUDTop()
                    if not parent then return end
                    local size = (DeadMarker2.savedVars and DeadMarker2.savedVars.arrowSizePx) or 64
                    local dist = (DeadMarker2.savedVars and DeadMarker2.savedVars.arrowReticleDist) or 100
                    if arrow and DeadMarker2._arrowTextureOk == true then
                        arrow:SetDimensions(size, size)
                        arrow:ClearAnchors()
                        arrow:SetAnchor(CENTER, parent, CENTER, 0, -dist)
                        arrow:SetColor(1, 0.3, 0.25, 1)
                        if arrow.SetAlpha then arrow:SetAlpha(1) end
                        -- Tip toward top of screen (forward) after 180° fix
                        if arrow.SetTextureRotation then pcall(function() arrow:SetTextureRotation(math.pi) end) end
                        arrow:SetHidden(false)
                    end
                    local lbl = DeadMarker2.arrowLabel
                    if lbl then
                        if DeadMarker2._arrowTextureOk == true then
                            lbl:SetHidden(true)
                        else
                            lbl:SetText("^")
                            lbl:SetColor(1, 0.9, 0.2, 1)
                            lbl:ClearAnchors()
                            lbl:SetAnchor(CENTER, parent, CENTER, 0, -dist)
                            lbl:SetHidden(false)
                        end
                    end
                    d("|c69c0ff[DeadMarker2]|r Arrow test 3s. textureOk=" .. tostring(DeadMarker2._arrowTextureOk))
                    zo_callLater(function() _HideArrow() end, 3000)
                end)
            end,
            disabled = function() return not sv.enableArrow end,
        },

        -- ========== DEATH PING ==========
        { type = "header", name = "Death Ping" },
        {
            type = "checkbox",
            name = "Enable Death Ping",
            tooltip = "Play a short sound (and optional flash) when a filtered role dies.",
            getFunc = function() return sv.enableDeathPing end,
            setFunc = function(v) sv.enableDeathPing = v end,
            default = true,
        },
        {
            type = "checkbox",
            name = "Ping on Tank Death",
            getFunc = function() return sv.pingTank end,
            setFunc = function(v) sv.pingTank = v end,
            default = true,
            disabled = function() return not sv.enableDeathPing end,
        },
        {
            type = "checkbox",
            name = "Ping on Healer Death",
            getFunc = function() return sv.pingHealer end,
            setFunc = function(v) sv.pingHealer = v end,
            default = true,
            disabled = function() return not sv.enableDeathPing end,
        },
        {
            type = "checkbox",
            name = "Ping on DPS Death",
            getFunc = function() return sv.pingDps end,
            setFunc = function(v) sv.pingDps = v end,
            default = false,
            disabled = function() return not sv.enableDeathPing end,
        },
        {
            type = "checkbox",
            name = "Screen Flash on Ping",
            getFunc = function() return sv.pingFlash end,
            setFunc = function(v) sv.pingFlash = v end,
            default = true,
            disabled = function() return not sv.enableDeathPing end,
        },
        {
            type = "slider",
            name = "Ping Cooldown (ms)",
            tooltip = "Minimum time between pings during multi-death chaos.",
            min = 500, max = 5000, step = 100,
            getFunc = function() return sv.pingCooldownMs end,
            setFunc = function(v) sv.pingCooldownMs = math.floor(tonumber(v) or 1500) end,
            default = 1500,
            disabled = function() return not sv.enableDeathPing end,
        },

        -- ========== REZ CALLOUT ==========
        { type = "header", name = "Rez Callout" },
        {
            type = "description",
            text = "Example:  Skye-Forge, rez TankBob1911 !!\nUses Priority Target. Never posts to group chat by default.",
        },
        {
            type = "checkbox",
            name = "Enable Rez Callout",
            tooltip = "Show a personal directive naming you and the Priority Target.",
            getFunc = function() return sv.enableRezCallout end,
            setFunc = function(v)
                sv.enableRezCallout = v
                if not v and DeadMarker2.calloutCtl then DeadMarker2.calloutCtl:SetHidden(true) end
            end,
            default = true,
        },
        {
            type = "editbox",
            name = "Callout Template",
            tooltip = "Use %player% and %target% placeholders.",
            getFunc = function() return sv.calloutTemplate or "%player%, rez %target% !!" end,
            setFunc = function(v)
                v = tostring(v or "")
                if v == "" then v = "%player%, rez %target% !!" end
                sv.calloutTemplate = v
            end,
            isMultiline = false,
            default = "%player%, rez %target% !!",
            disabled = function() return not sv.enableRezCallout end,
        },
        {
            type = "checkbox",
            name = "Center-Screen Banner",
            tooltip = "Show the callout as a large on-screen label (recommended).",
            getFunc = function() return sv.calloutCenter end,
            setFunc = function(v) sv.calloutCenter = v end,
            default = true,
            disabled = function() return not sv.enableRezCallout end,
        },
        {
            type = "slider",
            name = "Callout Vertical Position",
            tooltip = "Pixels from the TOP of the screen. Increase to move the banner down; decrease to move it up.",
            min = 40, max = 900, step = 10,
            getFunc = function() return sv.calloutOffsetY or 280 end,
            setFunc = function(v)
                sv.calloutOffsetY = math.floor(tonumber(v) or 280)
                if DeadMarker2.calloutCtl then _ApplyCalloutLayout(DeadMarker2.calloutCtl) end
            end,
            default = 280,
            disabled = function() return not sv.enableRezCallout or not sv.calloutCenter end,
        },
        {
            type = "slider",
            name = "Callout Horizontal Offset",
            tooltip = "Pixels left/right of screen center (negative = left).",
            min = -600, max = 600, step = 10,
            getFunc = function() return sv.calloutOffsetX or 0 end,
            setFunc = function(v)
                sv.calloutOffsetX = math.floor(tonumber(v) or 0)
                if DeadMarker2.calloutCtl then _ApplyCalloutLayout(DeadMarker2.calloutCtl) end
            end,
            default = 0,
            disabled = function() return not sv.enableRezCallout or not sv.calloutCenter end,
        },
        {
            type = "button",
            name = "Preview Callout Position",
            tooltip = "Show a sample callout for 4 seconds so you can tune offsets.",
            func = function()
                pcall(function()
                    local lbl = _EnsureCalloutLabel()
                    if not lbl then return end
                    _ApplyCalloutLayout(lbl)
                    local me = _LocalPlayerDisplayName()
                    lbl:SetText(_FormatCallout(me, "TankBob1911", sv))
                    lbl:SetHidden(false)
                    zo_callLater(function()
                        if DeadMarker2.calloutCtl then DeadMarker2.calloutCtl:SetHidden(true) end
                    end, 4000)
                end)
            end,
            disabled = function() return not sv.enableRezCallout or not sv.calloutCenter end,
        },
        {
            type = "checkbox",
            name = "Also Log to Chat (self only)",
            tooltip = "Print the callout with d() locally. Does not send to group/raid chat.",
            getFunc = function() return sv.calloutSelfChat end,
            setFunc = function(v) sv.calloutSelfChat = v end,
            default = false,
            disabled = function() return not sv.enableRezCallout end,
        },
        {
            type = "checkbox",
            name = "Tank/Healer Callouts Only",
            tooltip = "When ON, do not call out DPS Priority Targets.",
            getFunc = function() return sv.calloutTankHealerOnly end,
            setFunc = function(v) sv.calloutTankHealerOnly = v end,
            default = false,
            disabled = function() return not sv.enableRezCallout end,
        },
        {
            type = "checkbox",
            name = "Re-callout on Priority Change",
            tooltip = "When the Priority Target changes mid-wipe (e.g. tank goes PENDING), announce the new target.",
            getFunc = function() return sv.calloutOnPriorityChange end,
            setFunc = function(v) sv.calloutOnPriorityChange = v end,
            default = true,
            disabled = function() return not sv.enableRezCallout end,
        },
        {
            type = "slider",
            name = "Callout Duration (ms)",
            tooltip = "How long the center banner stays visible.",
            min = 1500, max = 8000, step = 250,
            getFunc = function() return sv.calloutDurationMs end,
            setFunc = function(v) sv.calloutDurationMs = math.floor(tonumber(v) or 3500) end,
            default = 3500,
            disabled = function() return not sv.enableRezCallout end,
        },

        -- ========== PANEL LAYOUT ==========
        { type = "header", name = "Rez Panel Layout" },
        {
            type = "slider",
            name = "Panel X Offset",
            tooltip = "Pixels from the LEFT edge of the screen.",
            min = 0, max = 2000, step = 5,
            getFunc = function() return sv.panelOffsetX end,
            setFunc = function(v) sv.panelOffsetX = math.floor(tonumber(v) or 60); _ApplyPanelLayout(); UpdateRezPanel() end,
            default = 60,
            disabled = function() return not sv.enableRezPanel end,
        },
        {
            type = "slider",
            name = "Panel Y Offset",
            tooltip = "Pixels from the TOP edge of the screen.",
            min = 0, max = 1400, step = 5,
            getFunc = function() return sv.panelOffsetY end,
            setFunc = function(v) sv.panelOffsetY = math.floor(tonumber(v) or 240); _ApplyPanelLayout(); UpdateRezPanel() end,
            default = 240,
            disabled = function() return not sv.enableRezPanel end,
        },
        {
            type = "slider",
            name = "Panel Opacity",
            tooltip = "Backdrop fill & border opacity (0 = transparent, 1 = opaque).",
            min = 0.0, max = 1.0, step = 0.05,
            getFunc = function() return sv.panelOpacity end,
            setFunc = function(v) sv.panelOpacity = tonumber(v) or 0.95; _ApplyPanelLayout(); end,
            default = 0.95,
            disabled = function() return not sv.enableRezPanel end,
        },
        {
            type = "slider",
            name = "Max Panel Width",
            tooltip = "Clamp the maximum rez panel width (px). The panel will auto-shrink font to fit if needed.",
            min = 600, max = 1600, step = 10,
            getFunc = function() return sv.maxPanelWidth end,
            setFunc = function(v) sv.maxPanelWidth = math.floor(tonumber(v) or 980); UpdateRezPanel() end,
            default = 980,
            disabled = function() return not sv.enableRezPanel end,
        },
        {
            type = "slider",
            name = "Min Panel Font Size",
            tooltip = "Lower bound for auto-shrink when lines are too long.",
            min = 12, max = 24, step = 1,
            getFunc = function() return sv.minPanelFontSize end,
            setFunc = function(v) sv.minPanelFontSize = math.floor(tonumber(v) or 18); UpdateRezPanel() end,
            default = 18,
            disabled = function() return not sv.enableRezPanel end,
        },
        {
            type = "slider",
            name = "Panel Font Size",
            tooltip = "Preferred row font size; panel may auto-shrink if content exceeds max width.",
            min = 18, max = 32, step = 1,
            getFunc = function() return sv.panelFontSize end,
            setFunc = function(v) sv.panelFontSize = math.floor(tonumber(v) or 24); RefreshPanelFonts() end,
            default = 24,
            disabled = function() return not sv.enableRezPanel end,
        },

        -- ========== TOOLS ==========
        { type = "header", name = "Debug & Tools" },
        {
            type = "checkbox",
            name = "Debug Mode",
            tooltip = "Enable debug messages in chat.",
            getFunc = function() return sv.debugEnabled end,
            setFunc = function(value) sv.debugEnabled = value end,
            default = false,
        },
        {
            type = "button",
            name = "Show Sample Rez Panel",
            tooltip = "Display sample deaths for 10 seconds (tests panel, arrow, callout, highlight).",
            func = function() ShowSampleRezPanel() end,
        },
        {
            type = "button",
            name = "Refresh Role Textures Now",
            tooltip = "Re-apply per-role textures to all current pins.",
            func = function() refreshAllPinTextures(); ddm("Role textures refreshed.") end,
        },
    }

    local ok, err = pcall(function()
        LAM:RegisterAddonPanel("DeadMarker2SettingsPanel", panelData)
        LAM:RegisterOptionControls("DeadMarker2SettingsPanel", optionsData)
    end)
    if not ok then
        -- Always visible: settings failure should not be silent on update day
        d("|cFFAA55[DeadMarker2]|r Settings menu failed to register (addon still runs): " .. tostring(err))
    end
end

-- Short one-time chat note per version (SV-gated)
local function MaybeAnnounceVersion()
    local sv = DeadMarker2.savedVars
    if type(sv) ~= "table" then return end
    if sv.lastAnnouncedVersion == DeadMarker2.version then return end
    sv.lastAnnouncedVersion = DeadMarker2.version
    -- Keep tight — chat space / noise
    local label = DeadMarker2.displayName or "DeadMarker2"
    d(string.format(
        "|c69c0ff[%s]|r v%s — always know who to rez next. Priority arrow, death ping, rez callout. Pairs with Hide Group. Report bugs — fixes within hours. Thanks!",
        label, DeadMarker2.version
    ))
end

-- ======================== Commands & events =============================
local function cmd_dm(arg)
    arg = (arg or ""):lower()
    if arg == "selftest"    then pcall(SelfTest); return end
    if arg == "markplayer"  then pcall(CmdMarkPlayer); return end
    if arg == "clear"       then pcall(DeadMarker2.ClearAll); return end
    if arg == "caps"        then pcall(Caps); return end
    if arg == "sample"      then pcall(ShowSampleRezPanel); return end
    d("|c69c0ff[DeadMarker2]|r Commands: /dm selftest | markplayer | clear | caps | sample | /deadmarker2settings")
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= DeadMarker2.name then return end
    EVENT_MANAGER:UnregisterForEvent(DeadMarker2.name, EVENT_ADD_ON_LOADED)
    local ok, err = pcall(function()
        -- ===================== SAVED VARS (PS5-safe) =====================
        DeadMarker2.savedVars = ZO_SavedVars:NewAccountWide("DeadMarker2Vars", 1, nil, _defaults, nil)
        if not DeadMarker2.savedVars then
            d("|cFF5555[DeadMarker2]|r ERROR: SavedVars failed to initialize (nil). Settings will not persist.")
            return
        end
        _deepmerge(DeadMarker2.savedVars, _defaults)
        _NormalizeSavedVars(DeadMarker2.savedVars)

        -- ==================== INIT =========================
        pcall(CreateFonts)
        SLASH_COMMANDS["/dm"] = cmd_dm
        SLASH_COMMANDS["/deadmarker2"] = cmd_dm
        pcall(CreateSettingsMenu)

        -- Companion hooks (DeadMarker2_Metrics can optional-depend later)
        DeadMarker2.ResolvePriorityTarget = ResolvePriorityTarget
        DeadMarker2.GetPriorityTag = function() return DeadMarker2.priorityTag end

        -- ==================== EVENTS =========================
        EVENT_MANAGER:RegisterForEvent(DeadMarker2.name, EVENT_UNIT_DEATH_STATE_CHANGED, function(_, unitTag, isDead)
            local tok, terr = pcall(TrackDeath, unitTag, isDead)
            if not tok then ddm("TrackDeath error: " .. tostring(terr)) end
        end)

        EVENT_MANAGER:RegisterForEvent(DeadMarker2.name .. "_PlayerActivated", EVENT_PLAYER_ACTIVATED, function()
            pcall(RefreshGroupCache)
            pcall(UpdateRezPanel)
            pcall(_ApplyPanelLayout)
            pcall(_MaybeStartPanelTicker)
            pcall(MaybeAnnounceVersion)
        end)

        EVENT_MANAGER:RegisterForEvent(DeadMarker2.name .. "_GroupUpdate", EVENT_GROUP_UPDATE, function()
            pcall(RefreshGroupCache)
            pcall(UpdateRezPanel)
        end)

        EVENT_MANAGER:RegisterForEvent(DeadMarker2.name .. "_ResurrectRequest", EVENT_RESURRECT_REQUEST, function(_, unitTag)
            local tok, terr = pcall(OnResurrectRequest, _, unitTag)
            if not tok then ddm("OnResurrectRequest error: " .. tostring(terr)) end
        end)
    end)
    if not ok then
        d("|cFF5555[DeadMarker2]|r Init error: " .. tostring(err))
    else
        ddm("Loaded v" .. DeadMarker2.version)
    end
end

EVENT_MANAGER:RegisterForEvent(DeadMarker2.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
