local ADDON_NAME = "CasualClean"

local COMPANION_TAG = "companion"
local HIDE_FRAME_REASON = "CasualCleanHideCompanionFrame"

-- Same map-pin texture ZOS uses for an active companion on the world map
-- (MAP_PIN_TYPE_ACTIVE_COMPANION in esoui/ingame/map/mappin.lua) -- already
-- reused/recolored this way by other shipped addons (e.g. OdySupportIcons).
local MARKER_TEXTURE = "EsoUI/Art/MapPins/activeCompanion_pin.dds"
-- Gamepad button-prompt up-arrow glyph (scrolltemplates_gamepad.xml) -- a
-- plain single-color icon, safe to tint and rotate to any angle.
local ARROW_TEXTURE = "EsoUI/Art/Buttons/Gamepad/gp_upArrow.dds"
-- Plain "X" glyph from the gamepad dyeing UI (dyeing_common_gamepad.xml's
-- disabled-dye-slot overlay) -- tintable there via a color attribute, and
-- already reused by at least one published addon the same way. Left at
-- its natural white tint here (not recolored) so it reads clearly over
-- the marker's own red-on-death color rather than blending into it.
local DEATH_X_TEXTURE = "EsoUI/Art/Dye/Gamepad/gp_Disabled_X.dds"

local MARKER_SIZE = 32
local ARROW_SIZE = 20
local DEATH_X_SIZE = 40
local EDGE_MARGIN = 48 -- px kept clear of the true screen edge when clamped
local HEAD_OFFSET_Y = 150 -- raw world units added above the companion's feet-origin position
local POLL_MS = 33 -- ~30Hz; a smaller per-tick delta makes the same smoothing look smoother
local NEAR_CLIP = 1 -- forward depth below this is behind the camera
-- Same EMA smoothing pattern DoesThisThingGoAnyFaster/AreYouSlow already
-- use for their own per-poll noisy readings -- here it absorbs both
-- camera micro-motion (movement bob/sway) and companion animation
-- position noise, since it's applied to the camera-space values both
-- feed into, before the on-screen/off-screen branch reads them.
-- Raised from 0.35 (still visibly jittery) to 0.12 -- see Docs/CasualClean.md.
local SMOOTHING_ALPHA = 0.12
-- Hysteresis band around the on-screen/off-screen boundary: without this,
-- residual noise right at the exact edge can flip `onScreen` back and
-- forth every tick, which snaps the marker between two entirely different
-- coordinate systems (true projected position vs. edge-clamped position)
-- -- a much larger, more jarring jump than ordinary smoothing noise.
local ON_SCREEN_HYSTERESIS = 24 -- px

-- Health-based marker color: green at 100%, yellow at HEALTH_MID_PERCENT,
-- red at HEALTH_LOW_PERCENT and below. Between the two thresholds it's a
-- straight gradient; only one of R/G actually moves in each half (green
-- {0,1,0} -> yellow {1,1,0} only raises R, yellow -> red {1,0,0} only
-- lowers G), so no separate lerp helper is needed.
local HEALTH_MID_PERCENT = 0.6
local HEALTH_LOW_PERCENT = 0.01

local abs, atan2, sin, cos, min, huge = math.abs, math.atan2, math.sin, math.cos, math.min, math.huge

local marker, arrow, deathX, cameraHelper, hudWindow
local uiW, uiH
local smoothedDepth, smoothedRight, smoothedUp
local wasOnScreen = false

-- Dungeons, Trials, Battlegrounds, and Cyrodiil each have their own native
-- query rather than one unified "instance type" function -- ESO calls
-- Trials "Raids" internally (confirmed via ZO_Death_IsRaidReviveAllowed's
-- use of IsPlayerInRaid for the Trial life/revive system). All four are
-- live player-state queries (not tied to whatever map the player merely has
-- open), and all four are established idioms already used by widely-run
-- addons (LuiExtended, CombatMetrics, Baertram's tools, among others).
--
-- Cyrodiil and Battlegrounds always disable the addon (both are
-- inherently multiplayer PvP content). Dungeons and Trials only disable it
-- while actually grouped (IsUnitGrouped("player")) -- solo play in either
-- (e.g. soloing a normal dungeon, or a Trial undertaken alone) leaves the
-- addon running per explicit request.
local function IsInRestrictedContent()
    if IsActiveWorldBattleground() or IsInCyrodiil() then
        return true
    end
    return IsUnitGrouped("player") and (IsUnitInDungeon("player") or IsPlayerInRaid())
end

local function TryHideCompanionFrame()
    local frame = ZO_UnitFrames_GetUnitFrame(COMPANION_TAG)
    if frame then
        frame:SetHiddenForReason(HIDE_FRAME_REASON, true)
        return true
    end
    return false
end

-- ZOS creates the companion unit frame object in its own handler for the
-- same event we listen for; if ours runs first in the same tick,
-- GetUnitFrame can still be nil, so retry briefly rather than give up.
local function HideCompanionFrameWithRetry(attemptsLeft)
    if TryHideCompanionFrame() or attemptsLeft <= 0 then
        return
    end
    zo_callLater(function() HideCompanionFrameWithRetry(attemptsLeft - 1) end, 250)
end

local function ShowCompanionFrame()
    local frame = ZO_UnitFrames_GetUnitFrame(COMPANION_TAG)
    if frame then
        frame:SetHiddenForReason(HIDE_FRAME_REASON, false)
    end
end

local function HideMarkers()
    marker:SetHidden(true)
    arrow:SetHidden(true)
    deathX:SetHidden(true)
end

-- Returns r, g, b, isDead. isDead is reported separately from the color
-- (rather than folded into a single "red" case) because a dead companion
-- also needs the X overlay shown, not just a color change.
local function GetCompanionHealthColor()
    if IsUnitDead(COMPANION_TAG) then
        return 1, 0, 0, true
    end

    local current, _, effectiveMax = GetUnitPower(COMPANION_TAG, COMBAT_MECHANIC_FLAGS_HEALTH)
    local percent = (effectiveMax > 0) and (current / effectiveMax) or 0
    if percent > 1 then percent = 1 end

    if percent > HEALTH_MID_PERCENT then
        local r = (1 - percent) / (1 - HEALTH_MID_PERCENT)
        return r, 1, 0, false
    elseif percent > HEALTH_LOW_PERCENT then
        local g = (percent - HEALTH_LOW_PERCENT) / (HEALTH_MID_PERCENT - HEALTH_LOW_PERCENT)
        return 1, g, 0, false
    else
        return 1, 0, 0, false
    end
end

-- Shared by UpdateMarker and the /casualclean diagnostic command so both
-- always agree on how the companion's position maps to the screen.
local function ComputeProjection()
    local _, wx, wy, wz = GetUnitRawWorldPosition(COMPANION_TAG)
    wy = wy + HEAD_OFFSET_Y

    Set3DRenderSpaceToCurrentCamera(cameraHelper:GetName())
    local camX, camY, camZ = GuiRender3DPositionToWorldPosition(cameraHelper:Get3DRenderSpaceOrigin())
    local fx, fy, fz = cameraHelper:Get3DRenderSpaceForward()
    local rx, ry, rz = cameraHelper:Get3DRenderSpaceRight()
    local ux, uy, uz = cameraHelper:Get3DRenderSpaceUp()

    local dx, dy, dz = wx - camX, wy - camY, wz - camZ
    local rawDepth = fx * dx + fy * dy + fz * dz
    local rawRight = rx * dx + ry * dy + rz * dz
    local rawUp = ux * dx + uy * dy + uz * dz

    -- First sample after a reset (companion just appeared, polling just
    -- started) snaps straight to the raw value -- otherwise the marker
    -- would visibly glide in from wherever the stale smoothed state was.
    smoothedDepth = smoothedDepth and (smoothedDepth + SMOOTHING_ALPHA * (rawDepth - smoothedDepth)) or rawDepth
    smoothedRight = smoothedRight and (smoothedRight + SMOOTHING_ALPHA * (rawRight - smoothedRight)) or rawRight
    smoothedUp = smoothedUp and (smoothedUp + SMOOTHING_ALPHA * (rawUp - smoothedUp)) or rawUp
    local depth, right, up = smoothedDepth, smoothedRight, smoothedUp

    local onScreen, screenX, screenY = false, 0, 0
    if depth >= NEAR_CLIP then
        local frustumW, frustumH = GetWorldDimensionsOfViewFrustumAtDepth(depth)
        screenX = right * (uiW / frustumW)
        screenY = -up * (uiH / frustumH)
        -- Threshold shifts depending on the current state (hysteresis):
        -- once on-screen, it takes crossing past the boundary by
        -- ON_SCREEN_HYSTERESIS px to switch to off-screen, and vice versa,
        -- so noise sitting right at the edge can't flap the mode every tick.
        local marginX = wasOnScreen and (uiW / 2 + ON_SCREEN_HYSTERESIS) or (uiW / 2 - ON_SCREEN_HYSTERESIS)
        local marginY = wasOnScreen and (uiH / 2 + ON_SCREEN_HYSTERESIS) or (uiH / 2 - ON_SCREEN_HYSTERESIS)
        onScreen = abs(screenX) <= marginX and abs(screenY) <= marginY
    end
    wasOnScreen = onScreen

    return depth, right, up, onScreen, screenX, screenY, rawDepth, rawRight, rawUp
end

-- deathX always sits exactly on top of the marker's current position
-- (whichever branch placed it), regardless of on-screen vs. edge-clamped.
local function PositionDeathX(x, y, isDead)
    if not isDead then
        deathX:SetHidden(true)
        return
    end
    deathX:ClearAnchors()
    deathX:SetAnchor(CENTER, GuiRoot, CENTER, x, y)
    deathX:SetHidden(false)
end

local function UpdateMarker()
    if not DoesUnitExist(COMPANION_TAG) then
        HideMarkers()
        return
    end

    local r, g, b, isDead = GetCompanionHealthColor()
    marker:SetColor(r, g, b, 1)
    arrow:SetColor(r, g, b, 1)

    local depth, right, up, onScreen, screenX, screenY = ComputeProjection()

    if onScreen then
        marker:ClearAnchors()
        marker:SetAnchor(CENTER, GuiRoot, CENTER, screenX, screenY)
        marker:SetHidden(false)
        arrow:SetHidden(true)
        PositionDeathX(screenX, screenY, isDead)
        return
    end

    -- Off-screen (behind the camera, or simply outside the FOV cone):
    -- horizontal bearing relative to straight-ahead, valid in both cases.
    local theta = atan2(right, depth)
    local dirX, dirY = sin(theta), -cos(theta)
    local halfW, halfH = uiW / 2 - EDGE_MARGIN, uiH / 2 - EDGE_MARGIN
    local scaleX = (dirX ~= 0) and (halfW / abs(dirX)) or huge
    local scaleY = (dirY ~= 0) and (halfH / abs(dirY)) or huge
    local t = min(scaleX, scaleY)
    local edgeX, edgeY = dirX * t, dirY * t

    marker:ClearAnchors()
    marker:SetAnchor(CENTER, GuiRoot, CENTER, edgeX, edgeY)
    marker:SetHidden(false)
    PositionDeathX(edgeX, edgeY, isDead)

    arrow:ClearAnchors()
    arrow:SetAnchor(CENTER, GuiRoot, CENTER, edgeX + dirX * (MARKER_SIZE * 0.6), edgeY + dirY * (MARKER_SIZE * 0.6))
    arrow:SetTextureRotation(theta, 0.5, 0.5)
    arrow:SetHidden(false)
end

local function StartPolling()
    -- Discard any smoothed state from a previous polling session so the
    -- first sample snaps to the companion's actual current position
    -- instead of smoothing in from wherever tracking last left off.
    smoothedDepth, smoothedRight, smoothedUp = nil, nil, nil
    wasOnScreen = false
    EVENT_MANAGER:RegisterForUpdate("CasualCleanPoll", POLL_MS, UpdateMarker)
end

local function StopPolling()
    EVENT_MANAGER:UnregisterForUpdate("CasualCleanPoll")
    HideMarkers()
end

local function CreateControls()
    -- Dedicated top-level window rather than parenting marker/arrow
    -- directly to GuiRoot -- matching how the published addon Breadcrumbs
    -- (the source this whole positioning technique is based on) sets up
    -- its own equivalent marker controls. A bare GuiRoot child with no
    -- explicit draw layer/tier has no guaranteed place in the compositing
    -- order; on console there's no error surfaced if that leaves it
    -- rendered but never actually visible, so this isn't worth leaving to
    -- an unconfirmed default.
    hudWindow = WINDOW_MANAGER:CreateTopLevelWindow("CasualCleanWindow")
    hudWindow:SetAnchorFill(GuiRoot)
    hudWindow:SetMouseEnabled(false)
    hudWindow:SetMovable(false)
    hudWindow:SetDrawLayer(DL_BACKGROUND)
    hudWindow:SetDrawTier(DT_LOW)
    hudWindow:SetDrawLevel(0)

    -- Colors for marker/arrow are set dynamically every poll from the
    -- companion's current health (GetCompanionHealthColor), not fixed here.
    marker = WINDOW_MANAGER:CreateControl("CasualCleanMarker", hudWindow, CT_TEXTURE)
    marker:SetTexture(MARKER_TEXTURE)
    marker:SetDimensions(MARKER_SIZE, MARKER_SIZE)
    marker:SetDrawLevel(50)
    marker:SetHidden(true)

    arrow = WINDOW_MANAGER:CreateControl("CasualCleanArrow", hudWindow, CT_TEXTURE)
    arrow:SetTexture(ARROW_TEXTURE)
    arrow:SetDimensions(ARROW_SIZE, ARROW_SIZE)
    arrow:SetDrawLevel(50)
    arrow:SetHidden(true)

    -- Drawn above the marker (higher draw level, same parent/tier) so the
    -- X reads as an overlay on top of the pin rather than being obscured
    -- by it.
    deathX = WINDOW_MANAGER:CreateControl("CasualCleanDeathX", hudWindow, CT_TEXTURE)
    deathX:SetTexture(DEATH_X_TEXTURE)
    deathX:SetDimensions(DEATH_X_SIZE, DEATH_X_SIZE)
    deathX:SetDrawLevel(60)
    deathX:SetHidden(true)

    -- Camera-basis helper: not itself visible, only queried for its
    -- Get3DRenderSpace*() vectors -- but anchor-filled to GuiRoot to match
    -- Breadcrumbs' equivalent control exactly, in case that's load-bearing
    -- for Set3DRenderSpaceToCurrentCamera rather than incidental.
    cameraHelper = WINDOW_MANAGER:CreateControl("CasualCleanCameraHelper", GuiRoot, CT_CONTROL)
    cameraHelper:SetAnchorFill(GuiRoot)
    cameraHelper:Create3DRenderSpace()
    cameraHelper:SetHidden(true)

    -- Hidden automatically outside HUD/HUD_UI scenes (menus, dialogues,
    -- map) -- applied to the shared window so marker/arrow inherit it
    -- through the normal parent-hidden chain, rather than tracking two
    -- separate fragments that could fall out of sync with each other.
    local fragment = ZO_SimpleSceneFragment:New(hudWindow)
    HUD_SCENE:AddFragment(fragment)
    HUD_UI_SCENE:AddFragment(fragment)

    uiW, uiH = GuiRoot:GetDimensions()
end

-- Single source of truth for whether the addon should be doing anything at
-- all right now, re-run from every event that could change either half of
-- that answer (companion summoned/dismissed, or entering/leaving
-- restricted content). Re-checking here rather than trusting each event's
-- own "did I just enter a dungeon" framing keeps the two conditions
-- (companion active, content restricted) from drifting out of sync.
local function RefreshState()
    if IsInRestrictedContent() then
        StopPolling()
        ShowCompanionFrame()
        return
    end

    if DoesUnitExist(COMPANION_TAG) then
        HideCompanionFrameWithRetry(4)
        StartPolling()
    else
        StopPolling()
    end
end

local function OnAddOnLoaded(eventCode, addonName)
    if addonName ~= ADDON_NAME then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    CreateControls()

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ACTIVE_COMPANION_STATE_CHANGED, RefreshState)
    -- EVENT_ACTIVE_COMPANION_STATE_CHANGED doesn't fire retroactively for a
    -- companion already active before this addon loaded/reloaded, and
    -- restricted-content status can likewise change without either of
    -- those specific events -- EVENT_PLAYER_ACTIVATED (post-load-screen)
    -- and EVENT_ZONE_CHANGED (sub-zone transitions without a load screen)
    -- between them cover dungeon/trial/battleground/Cyrodiil entry and exit.
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, RefreshState)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ZONE_CHANGED, RefreshState)
    -- Since Dungeon/Trial restriction now depends on group status too, not
    -- just location, a group forming or breaking up mid-dungeon needs to
    -- re-evaluate state on its own -- neither event above fires for that.
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_GROUP_MEMBER_JOINED, RefreshState)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_GROUP_MEMBER_LEFT, RefreshState)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

local function LogProjectionSample(label)
    if not (hudWindow and DoesUnitExist(COMPANION_TAG)) then
        d("CasualClean: no companion active, nothing to sample")
        return
    end
    local depth, right, up, onScreen, screenX, screenY, rawDepth, rawRight, rawUp = ComputeProjection()
    d(string.format(
        "CasualClean %s: raw(d=%.0f r=%.0f u=%.0f) smoothed(d=%.0f r=%.0f u=%.0f) onScreen=%s x=%.0f y=%.0f",
        label, rawDepth, rawRight, rawUp, depth, right, up, tostring(onScreen), screenX, screenY
    ))
end

-- Console never surfaces Lua errors to the player, so "it's not working" /
-- "still jittery" reports otherwise come with nothing to go on. Jitter is
-- a pattern across several samples, not a single snapshot, so
-- "/casualclean [count]" (default 1, max 20) logs that many samples
-- ~200ms apart -- comparing raw vs. smoothed columns across them shows
-- both how noisy the raw signal actually is and whether smoothing is
-- visibly damping it.
SLASH_COMMANDS["/casualclean"] = function(args)
    d(string.format(
        "CasualClean: companion=%s restricted=%s windowHidden=%s markerHidden=%s",
        tostring(DoesUnitExist(COMPANION_TAG)),
        tostring(IsInRestrictedContent()),
        tostring(hudWindow and hudWindow:IsHidden()),
        tostring(marker and marker:IsHidden())
    ))

    if DoesUnitExist(COMPANION_TAG) then
        local r, g, b, isDead = GetCompanionHealthColor()
        d(string.format("CasualClean: dead=%s color=(%.2f, %.2f, %.2f)", tostring(isDead), r, g, b))
    end

    local count = tonumber(args) or 1
    if count < 1 then count = 1 end
    if count > 20 then count = 20 end
    for i = 1, count do
        zo_callLater(function() LogProjectionSample(i .. "/" .. count) end, (i - 1) * 200)
    end
end
