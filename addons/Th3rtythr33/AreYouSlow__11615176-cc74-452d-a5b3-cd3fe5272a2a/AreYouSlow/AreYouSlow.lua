local ADDON_NAME = "AreYouSlow"

-- ESO has no native "current speed" query -- same conclusion reached while
-- building DoesThisThingGoAnyFaster (see this workspace's CLAUDE.md):
-- position sampling is the only available signal. GetUnitWorldPosition's
-- raw units have no fixed real-world conversion and the scale differs per
-- zone (confirmed via LibGPS3's source and ESOUI forum thread 9251), so
-- this reports speed in raw units/second rather than a real-world unit
-- like m/s -- there's no reliable way to convert without taking a LibGPS
-- dependency, which isn't warranted just to relabel the same number.
local POLL_MS = 200                   -- how often to sample position
local SMOOTHING_ALPHA = 0.3           -- EMA smoothing so the readout isn't jittery frame-to-frame
local MAX_PLAUSIBLE_DELTA_MS = 1000   -- ignore samples spanning a hitch/loading pause

local speedLabel
local lastZoneId, lastX, lastY, lastZ, lastTimeMs
local smoothedSpeed

local function UpdateSpeedLabel()
    local displaySpeed = smoothedSpeed or 0
    speedLabel:SetText(string.format("Speed: %d u/s", math.floor(displaySpeed * 1000 + 0.5)))
end

-- Tracks all movement (on foot, swimming, mounted, etc.) rather than being
-- gated to a particular state -- this addon's whole purpose is a live
-- speed readout, not a mount-specific tool like its sibling.
--
-- A raw position delta from one zoneId is not safely comparable to a delta
-- from a different zoneId (confirmed via ESOUI forum thread 9251 -- the
-- world-to-map scale/offset is measured per zone and isn't even linear
-- within some zones). Requiring zoneId to match before computing a delta,
-- combined with the reset in OnPlayerActivated below, keeps every delta
-- this addon computes within a single zone and a single unbroken polling
-- run.
local function OnPositionPoll()
    local zoneId, x, y, z = GetUnitWorldPosition("player")
    local nowMs = GetGameTimeMilliseconds()

    if lastTimeMs and zoneId == lastZoneId then
        local dtMs = nowMs - lastTimeMs
        if dtMs > 0 and dtMs <= MAX_PLAUSIBLE_DELTA_MS then
            local dx, dy, dz = x - lastX, y - lastY, z - lastZ
            local instSpeed = math.sqrt(dx * dx + dy * dy + dz * dz) / dtMs

            smoothedSpeed = smoothedSpeed and (smoothedSpeed + SMOOTHING_ALPHA * (instSpeed - smoothedSpeed)) or instSpeed
            UpdateSpeedLabel()
        end
    end

    lastZoneId, lastX, lastY, lastZ, lastTimeMs = zoneId, x, y, z, nowMs
end

-- EVENT_PLAYER_ACTIVATED fires after every loading screen (initial login,
-- /reloadui, wayshrine travel, zone transfer). Clearing lastTimeMs here
-- means the very next poll just re-baselines position instead of computing
-- a delta across whatever the player's position was doing during the load
-- screen -- the same guard the sibling addon uses via ResetTracking.
local function OnPlayerActivated()
    lastZoneId, lastX, lastY, lastZ, lastTimeMs = nil, nil, nil, nil, nil
end

-- Anchored to GuiRoot rather than any first-party ZOS element -- no
-- platform-specific control tree to worry about here (contrast the
-- sibling addon's mount stamina bar anchor, which does have to worry about
-- that).
local function CreateSpeedLabel()
    local control = WINDOW_MANAGER:CreateTopLevelWindow(ADDON_NAME .. "Display")
    control:SetDimensions(200, 24)
    control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 20, 20)

    local label = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
    label:SetAnchorFill(control)
    -- Confirmed present in esoui/fontdefs/gamepad/defaultfontdefs_gamepad.xml
    -- (not keyboard-only) at API version 101050 -- see this workspace's
    -- CLAUDE.md on why that check matters on console specifically.
    label:SetFont("ZoFontGamepadBold20")
    label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    label:SetVerticalAlignment(TEXT_ALIGN_TOP)
    label:SetColor(1, 1, 0.4, 1)
    label:SetText("Speed: -- u/s")

    return control, label
end

local function OnAddOnLoaded(_, addOnName)
    if addOnName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    local speedControl
    speedControl, speedLabel = CreateSpeedLabel()

    -- Hide whenever a menu (inventory, map, character sheet, crafting,
    -- etc.) is open. HUD_SCENE and HUD_UI_SCENE are ZOS's own "actually in
    -- the world, no blocking menu open" scenes (confirmed via
    -- esoui/ingame/scenes/hudscene.lua) -- wrapping the control in a
    -- ZO_SimpleSceneFragment and adding it to both is the same mechanism
    -- the game's own compass/action bar/equipment status HUD elements use
    -- (see HUD_FRAGMENT_GROUP in that same file), rather than tracking
    -- every individual menu-open event by hand. Neither global is
    -- keyboard/gamepad split, so this is safe on console too.
    local speedFragment = ZO_SimpleSceneFragment:New(speedControl)
    HUD_SCENE:AddFragment(speedFragment)
    HUD_UI_SCENE:AddFragment(speedFragment)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "Poll", POLL_MS, OnPositionPoll)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
