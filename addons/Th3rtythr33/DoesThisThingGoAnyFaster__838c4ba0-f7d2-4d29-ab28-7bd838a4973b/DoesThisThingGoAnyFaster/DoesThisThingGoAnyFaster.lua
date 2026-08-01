local ADDON_NAME = "DoesThisThingGoAnyFaster"

-- ESO has no direct "is sprinting" query or raw speed function, and the
-- obvious alternative -- watching stamina-cost combat events
-- (ACTION_RESULT_SPRINTING) -- doesn't work here: the "War Mount" Champion
-- Point passive removes mount stamina drain entirely while out of combat,
-- so no cost event ever fires in exactly the situation this addon is for.
-- Confirmed there's no better native signal either: no IsUnitSprinting-style
-- query exists, ZOS's own UI has no live "sprinting" hook to piggyback on,
-- and the sprint keybind (both keyboard and gamepad) dispatches straight
-- from raw input into a private engine function with no public event
-- anywhere in the chain -- not even a keypress event exists for this.
-- Position sampling is genuinely the only signal available.
--
-- Earlier versions tried to detect sprint automatically via an adaptive
-- EMA "cruise speed" baseline and a fixed ratio threshold (e.g. "1.13x
-- baseline = sprinting"). That approach went through three rounds of bugs
-- (acceleration-ramp false triggers, baseline convergence lag, and finally
-- discovering the real sprint/cruise ratio isn't even consistent between
-- characters -- it depends on each character's own speed bonuses, not just
-- the zone) before concluding a universal ratio can't work for "any player
-- on any character," which is what this addon is meant to support.
--
-- Current approach: explicit per-zone calibration, auto-triggered rather
-- than requiring the player to type /speedcal. The moment the player
-- mounts in a zone with no stored ceiling yet, calibration ARMS (chat
-- message shown) but doesn't start ticking yet -- it stays paused until
-- the player actually starts moving, so the full window is spent riding
-- rather than partly wasted while stationary. Once moving, the highest
-- smoothed speed seen over CALIBRATION_DURATION_MS is stored (in
-- SavedVariables, per character) as "the ceiling of normal riding" for
-- that zone. From then on in that zone, any reading above the stored
-- ceiling is treated as sprinting. This is simpler and more robust than
-- the old adaptive-ratio approach: it needs no convergence period (the
-- measurement is complete and exact the moment calibration ends), and it's
-- automatically correct for both the current zone's raw-unit scale AND
-- this specific character's speed bonuses, since both were live when the
-- measurement was taken. /speedcal is still available too, as a manual
-- override to force a fresh recalibration of the current zone (e.g. after
-- a build change shifts the character's own speed bonuses enough that the
-- old ceiling stops being accurate) -- it arms the same way, still paused
-- until movement starts, rather than starting the clock immediately.
local POLL_MS = 200                    -- how often to sample position
local FAST_ALPHA = 0.3                  -- smoothing for the displayed/compared speed
local MAX_PLAUSIBLE_DELTA_MS = 1000     -- ignore samples spanning a hitch/loading pause
local CALIBRATION_DURATION_MS = 8000    -- how long /speedcal watches before locking in a ceiling

local isMounted = false
local sprintActive = false
local mountStaminaIndicator
local mountStaminaBar
local mountStaminaOriginalGradient  -- snapshotted once at load; nil if that wasn't possible (see SnapshotMountStaminaGradient)
local savedVars

local lastZoneId, lastX, lastY, lastZ, lastTimeMs
local fastSpeed

local calibrating = false       -- 8s window actively running (timer + peak-tracking)
local calibrationArmed = false  -- waiting for the player to start moving before the timer begins
local calibrationEndMs = 0
local calibrationPeakSpeed = 0

-- Small secondary indicator anchored to the game's own mount stamina bar,
-- so there's something to glance at right where the player's eyes already
-- are while riding. Only ever visible while actually sprinting -- silent
-- otherwise, since it's meant to augment a HUD element the player's
-- already watching, not add noise to it.
--
-- Alongside the text, the bar's own fill color also switches to gold while
-- sprinting. ZOS colors these bars via SetGradientColors (a start/end RGBA
-- pair), set once at initial setup rather than refreshed per-frame or tied
-- to the current stamina value (confirmed via ZO_PlayerAttributeBar:
-- RefreshColor in the live source, called exactly once, at construction)
-- -- so our own SetGradientColors call won't get fought or overwritten by
-- the game re-asserting its own color on some later tick.
local function ApplyMountStaminaBarColor(sprinting)
    if not mountStaminaBar then
        return
    end

    if sprinting then
        mountStaminaBar:SetGradientColors(1, 0.82, 0.15, 1, 0.95, 0.6, 0.05, 1)
    elseif mountStaminaOriginalGradient then
        local g = mountStaminaOriginalGradient
        mountStaminaBar:SetGradientColors(g[1], g[2], g[3], g[4], g[5], g[6], g[7], g[8])
    else
        -- No verified snapshot to restore (see SnapshotMountStaminaGradient) --
        -- clearing is a best-effort fallback, not confirmed to look right.
        mountStaminaBar:ClearGradientColors()
    end
end

local function UpdateMountStaminaIndicator()
    local sprinting = isMounted and sprintActive
    mountStaminaIndicator:SetHidden(not sprinting)
    ApplyMountStaminaBarColor(sprinting)
end

local function ResetTracking()
    lastZoneId, lastX, lastY, lastZ, lastTimeMs = nil, nil, nil, nil, nil
    fastSpeed = nil
    sprintActive = false
    -- Clears a pending arm-but-never-moved attempt on every mount/dismount
    -- so it can't dangle across an unrelated later mount in a different
    -- zone and wrongly suppress that zone's own arm check. Deliberately
    -- doesn't touch `calibrating` -- an already-*running* window keeps
    -- running through a dismount, same as before this change.
    calibrationArmed = false
end

-- Arms calibration -- fires automatically on mount (see OnMountedStateChanged)
-- or manually via /speedcal; either way it doesn't start the 8s window
-- immediately. It stays paused (calibrationArmed) until OnPositionPoll
-- sees actual movement, so the whole window is spent riding rather than
-- partly wasted while stationary. Only measures the non-sprint ceiling --
-- the player is explicitly asked not to sprint, so there's nothing to
-- measure on the sprint side here; detection afterward is purely "did the
-- reading exceed the measured ceiling."
local function ArmCalibration(isAutomatic)
    if not IsMounted() then
        d("DoesThisThingGoAnyFaster: mount up first, then run /speedcal again.")
        return
    end

    if calibrating or calibrationArmed then
        return
    end

    if isAutomatic then
        d("DoesThisThingGoAnyFaster: no calibration data for this zone -- ride without sprinting for at least " ..
            (CALIBRATION_DURATION_MS / 1000) .. " seconds to calibrate. Calibration begins automatically as soon as you start moving.")
    else
        d("DoesThisThingGoAnyFaster: ride without sprinting for at least " .. (CALIBRATION_DURATION_MS / 1000) ..
            " seconds to calibrate. Calibration begins as soon as you start moving.")
    end

    calibrationArmed = true
end

local function FinishCalibration(zoneId)
    calibrating = false

    if calibrationPeakSpeed <= 0 then
        d("DoesThisThingGoAnyFaster: calibration failed -- no movement detected. Make sure you're mounted and moving, then try /speedcal again.")
        return
    end

    savedVars.thresholds[zoneId] = calibrationPeakSpeed
    local zoneName = GetPlayerActiveZoneName()
    d(string.format("DoesThisThingGoAnyFaster: calibration complete for %s. Non-sprint ceiling: %du/s -- anything faster than that now counts as sprinting here. Run /speedcal to calibrate again.",
        zoneName, math.floor(calibrationPeakSpeed * 1000 + 0.5)))
end

local function OnPositionPoll()
    local zoneId, x, y, z = GetUnitWorldPosition("player")
    local nowMs = GetGameTimeMilliseconds()

    if lastTimeMs and zoneId == lastZoneId then
        local dtMs = nowMs - lastTimeMs
        if dtMs > 0 and dtMs <= MAX_PLAUSIBLE_DELTA_MS then
            local dx, dy, dz = x - lastX, y - lastY, z - lastZ
            local instSpeed = math.sqrt(dx * dx + dy * dy + dz * dz) / dtMs

            fastSpeed = fastSpeed and (fastSpeed + FAST_ALPHA * (instSpeed - fastSpeed)) or instSpeed

            if calibrating then
                calibrationPeakSpeed = math.max(calibrationPeakSpeed, fastSpeed)
                if nowMs >= calibrationEndMs then
                    FinishCalibration(zoneId)
                end
            elseif calibrationArmed and fastSpeed > 0 then
                -- Movement just started -- actually begin the window now,
                -- rather than back when it armed, so it's not spent partly
                -- stationary.
                calibrationArmed = false
                calibrating = true
                calibrationPeakSpeed = fastSpeed
                calibrationEndMs = nowMs + CALIBRATION_DURATION_MS
            end

            local ceiling = savedVars.thresholds[zoneId]
            sprintActive = ceiling ~= nil and fastSpeed > ceiling

            UpdateMountStaminaIndicator()
        end
    end

    lastZoneId, lastX, lastY, lastZ, lastTimeMs = zoneId, x, y, z, nowMs
end

local function OnMountedStateChanged(_, mounted)
    isMounted = mounted
    ResetTracking()

    if mounted then
        EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "Poll", POLL_MS, OnPositionPoll)
    else
        EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "Poll")
    end

    -- Auto-calibration trigger: arm it right at the mount moment if the
    -- zone the player is standing in has no ceiling yet. Reads position
    -- directly rather than waiting on OnPositionPoll, since this should
    -- fire as soon as the player mounts, not after the next poll happens
    -- to land.
    if mounted then
        local zoneId = GetUnitWorldPosition("player")
        if savedVars.thresholds[zoneId] == nil then
            ArmCalibration(true)
        end
    end

    UpdateMountStaminaIndicator()
end

local function OnPlayerActivated()
    OnMountedStateChanged(nil, IsMounted())
end

-- ZOS colors these bars purely via SetGradientColors -- there's no getter
-- to read it back later, and the lookup table RefreshColor itself uses
-- (ZO_POWER_BAR_GRADIENT_COLORS) isn't defined anywhere in the shipped Lua
-- source (repo-wide search came up empty), meaning it's presumably a
-- native global rather than an addon-visible one -- unconfirmed either
-- way without a live client. Wrapped in pcall so a wrong guess here can't
-- throw and take down anything else in OnAddOnLoaded; on any failure this
-- just returns nil and ApplyMountStaminaBarColor falls back to
-- ClearGradientColors() instead of a verified restore.
local function SnapshotMountStaminaGradient()
    local success, result = pcall(function()
        local gradient = ZO_POWER_BAR_GRADIENT_COLORS[COMBAT_MECHANIC_FLAGS_MOUNT_STAMINA]
        local r, g, b, a = gradient[1]:UnpackRGBA()
        local r2, g2, b2, a2 = gradient[2]:UnpackRGBA()
        return { r, g, b, a, r2, g2, b2, a2 }
    end)
    if success then
        return result
    end
    return nil
end

-- Anchored to ZOS's own mount stamina bar (ZO_PlayerAttribute's "MountStamina"
-- named child -- confirmed via the live esoui source: a single, unified
-- control tree for both keyboard and gamepad, just with a different visual
-- template applied per platform, not a separate copy per mode). This is a
-- first-party UI element, not a documented addon-facing API, so it's worth
-- knowing this is a little more fragile than anchoring to GuiRoot -- if ZOS
-- ever restructures the player attribute bars, this anchor could break. That
-- said, health/magicka/stamina bars are about as stable a piece of UI as ESO
-- has, essentially unchanged since launch, so this is a low-risk bet, not a
-- reckless one. The bar itself is only 12px tall (ZO_PlayerAttributeContainerSmall),
-- hence the small font and hidden-unless-sprinting text instead of a
-- persistent readout -- there's no room for that here, and it would clash
-- visually with a HUD element the player didn't ask to have decorated.
local function CreateMountStaminaIndicator()
    local anchorTarget = ZO_PlayerAttribute:GetNamedChild("MountStamina")
    mountStaminaBar = anchorTarget:GetNamedChild("Bar")
    mountStaminaOriginalGradient = SnapshotMountStaminaGradient()

    local control = WINDOW_MANAGER:CreateTopLevelWindow(ADDON_NAME .. "MountStaminaIndicator")
    control:SetDimensions(120, 16)
    control:SetAnchor(CENTER, anchorTarget, CENTER, 0, 0)
    control:SetHidden(true)

    local label = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
    label:SetAnchorFill(control)
    label:SetFont("ZoFontGamepadBold18")
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetColor(0.4, 1, 0.4, 1)
    label:SetText("WEEEE!")

    return control
end

local function OnAddOnLoaded(_, addOnName)
    if addOnName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    -- Per-character, per-zone calibration data. Must be created here (in
    -- EVENT_ADD_ON_LOADED) for the saved file to persist correctly.
    savedVars = ZO_SavedVars:New("DoesThisThingGoAnyFasterSaved", 1, nil, { thresholds = {} })

    mountStaminaIndicator = CreateMountStaminaIndicator()

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_MOUNTED_STATE_CHANGED, OnMountedStateChanged)

    SLASH_COMMANDS["/speedcal"] = function() ArmCalibration(false) end
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
