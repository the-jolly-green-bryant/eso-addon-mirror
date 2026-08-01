-----------------------------------------------------------
-- DarkScrollsUI - DS_DamageFlash.lua
-- Damage flash effect: blood-border overlay + camera shake
-- when the player takes damage. Integrated from BordaDeDano
-- (original concept by its author – credit preserved here).
-- All state is stored inside the DarkScrollsUI table to
-- avoid polluting the global _G namespace (ESOUI rule).
--
-- Hits are classified as LIGHT or HEAVY based on the
-- percentage of max HP lost in a single strike, controlled
-- by the "damageFlashHeavyThreshold" saved variable.
-- Each class has its own shake intensity, overlay opacity,
-- and duration setting.
-----------------------------------------------------------

DarkScrollsUI = DarkScrollsUI or {}

-----------------------------------------------------------
-- CONFIGURATION CONSTANTS (local – not global)
-----------------------------------------------------------
local HEAVY_THRESHOLD       = 0.10
local LIGHT_SHAKE_INTENSITY = 0.03
local LIGHT_ALPHA_PEAK      = 0.35
local LIGHT_DURATION        = 150
local HEAVY_SHAKE_INTENSITY = 0.09
local HEAVY_ALPHA_PEAK      = 0.70
local HEAVY_DURATION        = 350
local LIGHT_ZOOM_DISTANCE   = 0.4   -- extra distance units pushed outward (light)
local LIGHT_ZOOM_RETURN     = 600   -- ms to ease back to original distance (light)
local HEAVY_ZOOM_DISTANCE   = 1.0   -- extra distance for heavy hit
local HEAVY_ZOOM_RETURN     = 1000  -- ms to ease back for heavy hit

local IMAGE_PATH = "DarkScrollsUI/Images/blood.dds"

-- Camera setting shortcuts (local aliases – ESOUI rule)
local CAM_SET  = SETTING_TYPE_CAMERA
local CAM_H    = CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_OFFSET
local CAM_V    = CAMERA_SETTING_THIRD_PERSON_VERTICAL_OFFSET
local CAM_DIST = CAMERA_SETTING_THIRD_PERSON_DISTANCE

-- Internal state (kept inside the addon table, not globals)
DarkScrollsUI.damageFlash = {
    control      = nil,   -- CT_TEXTURE overlay control
    lastHealth   = 0,
    maxHealth    = 0,     -- tracked so we can compute hit %
    isShaking    = false,
    originalH    = nil,
    originalV    = nil,
    -- Zoom-out state
    originalDist = nil,   -- camera distance before zoom-out
    isZooming    = false,
}

-----------------------------------------------------------
-- HELPERS
-----------------------------------------------------------
local function IsFlashEnabled()
    return DarkScrollsUI.SavedVariables
        and DarkScrollsUI.SavedVariables.damageFlashEnabled
end

-- Returns a table with the resolved settings for the given
-- hit class ("light" or "heavy"), merging SavedVariables
-- with the fallback constants.
local function GetHitSettings(hitClass)
    local sv = DarkScrollsUI.SavedVariables or {}
    if hitClass == "heavy" then
        return {
            intensity    = sv.damageFlashHeavyShakeIntensity or HEAVY_SHAKE_INTENSITY,
            alphaPeak    = sv.damageFlashHeavyAlphaPeak      or HEAVY_ALPHA_PEAK,
            duration     = sv.damageFlashHeavyDuration       or HEAVY_DURATION,
            zoomDistance = sv.damageFlashHeavyZoomDistance   or HEAVY_ZOOM_DISTANCE,
            zoomReturn   = sv.damageFlashHeavyZoomReturn     or HEAVY_ZOOM_RETURN,
        }
    else
        return {
            intensity    = sv.damageFlashLightShakeIntensity or LIGHT_SHAKE_INTENSITY,
            alphaPeak    = sv.damageFlashLightAlphaPeak      or LIGHT_ALPHA_PEAK,
            duration     = sv.damageFlashLightDuration       or LIGHT_DURATION,
            zoomDistance = sv.damageFlashLightZoomDistance   or LIGHT_ZOOM_DISTANCE,
            zoomReturn   = sv.damageFlashLightZoomReturn     or LIGHT_ZOOM_RETURN,
        }
    end
end

-- Classifies a hit as "light" or "heavy" based on the
-- percentage of max HP that was lost in the hit.
local function ClassifyHit(damageTaken)
    local df        = DarkScrollsUI.damageFlash
    local sv        = DarkScrollsUI.SavedVariables or {}
    local threshold = sv.damageFlashHeavyThreshold or HEAVY_THRESHOLD
    local maxHp     = df.maxHealth
    if maxHp and maxHp > 0 and (damageTaken / maxHp) >= threshold then
        return "heavy"
    end
    return "light"
end

-----------------------------------------------------------
-- CAMERA SHAKE (real camera, suppressed while menus are open)
-----------------------------------------------------------
local function ApplyCameraShakeReal(settings)
    local df        = DarkScrollsUI.damageFlash
    local intensity = settings.intensity
    local duration  = settings.duration

    -- Ensure we have the true original settings captured if not already stored.
    -- We use originalH as a flag to know if we have a valid baseline to restore to.
    if df.originalH == nil then
        df.originalH = tonumber(GetSetting(CAM_SET, CAM_H)) or 0
        df.originalV = tonumber(GetSetting(CAM_SET, CAM_V)) or 0
    end

    df.isShaking = true

    local startTime = GetGameTimeMilliseconds()
    local updateKey = DarkScrollsUI.AddonNameIdentifier .. "_ShakeLoop"

    EVENT_MANAGER:UnregisterForUpdate(updateKey)
    EVENT_MANAGER:RegisterForUpdate(updateKey, 20, function()
        local now = GetGameTimeMilliseconds()
        if now - startTime > duration then
            EVENT_MANAGER:UnregisterForUpdate(updateKey)
            if df.originalH ~= nil then
                SetSetting(CAM_SET, CAM_H, tostring(df.originalH))
                SetSetting(CAM_SET, CAM_V, tostring(df.originalV))
                df.originalH = nil -- Clear so next hit captures fresh settings
                df.originalV = nil
            end
            df.isShaking = false
        else
            local randH = df.originalH + (math.random(-100, 100) / 100 * intensity)
            local randV = df.originalV + (math.random(-100, 100) / 100 * intensity)
            SetSetting(CAM_SET, CAM_H, tostring(randH))
            SetSetting(CAM_SET, CAM_V, tostring(randV))
        end
    end)
end

-----------------------------------------------------------
-- UI SHAKE (overlay displacement – works even with menus open)
-----------------------------------------------------------
local UI_SHAKE_PIXELS = 40   -- max pixel offset at intensity 1.0

local function ApplyCameraShakeUI(settings)
    local df      = DarkScrollsUI.damageFlash
    local control = df.control
    if not control then return end

    local intensity = settings.intensity
    local duration  = settings.duration
    local maxPx     = UI_SHAKE_PIXELS * intensity

    -- If transitioning from a Real shake to UI shake, restore camera first
    if df.originalH ~= nil then
        SetSetting(CAM_SET, CAM_H, tostring(df.originalH))
        SetSetting(CAM_SET, CAM_V, tostring(df.originalV))
        df.originalH = nil
        df.originalV = nil
    end

    local startTime = GetGameTimeMilliseconds()
    local updateKey = DarkScrollsUI.AddonNameIdentifier .. "_ShakeLoop"

    df.isShaking = true
    EVENT_MANAGER:UnregisterForUpdate(updateKey)
    EVENT_MANAGER:RegisterForUpdate(updateKey, 20, function()
        local now = GetGameTimeMilliseconds()
        if now - startTime > duration then
            -- Restore overlay to full-screen fill
            control:ClearAnchors()
            control:SetAnchorFill()
            EVENT_MANAGER:UnregisterForUpdate(updateKey)
            df.isShaking = false
        else
            local ox  = math.random(-100, 100) / 100 * maxPx
            local oy  = math.random(-100, 100) / 100 * maxPx
            local pad = math.abs(maxPx) + 4
            control:ClearAnchors()
            control:SetAnchor(TOPLEFT,     GuiRoot, TOPLEFT,     -pad + ox, -pad + oy)
            control:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT,  pad + ox,  pad + oy)
        end
    end)
end

-----------------------------------------------------------
-- SHAKE DISPATCHER
-----------------------------------------------------------
local function ApplyCameraShake(settings)
    if DarkScrollsUI.isSettingsMenuOpen then
        ApplyCameraShakeUI(settings)
    else
        ApplyCameraShakeReal(settings)
    end
end

-----------------------------------------------------------
-- ZOOM OUT  (instant push + progressive ease back)
-- Uses CAMERA_SETTING_THIRD_PERSON_DISTANCE.
-- Suppressed while menus are open for the same reason as
-- the real camera shake (SetSetting is blocked by the game).
-----------------------------------------------------------
local function ApplyZoomOut(settings)
    local df   = DarkScrollsUI.damageFlash
    local dist = settings.zoomDistance
    local ret  = settings.zoomReturn   -- ms

    if dist <= 0 or DarkScrollsUI.isSettingsMenuOpen then return end

    local zoomKey = DarkScrollsUI.AddonNameIdentifier .. "_ZoomLoop"
    EVENT_MANAGER:UnregisterForUpdate(zoomKey)

    -- Capture the baseline only once per zoom sequence so overlapping
    -- hits don't push the camera ever further out.
    if not df.isZooming then
        df.originalDist = tonumber(GetSetting(CAM_SET, CAM_DIST)) or 0
        df.isZooming    = true
    end

    local origin  = df.originalDist
    local peak    = origin + dist
    SetSetting(CAM_SET, CAM_DIST, tostring(peak))

    local startTime = GetGameTimeMilliseconds()
    EVENT_MANAGER:RegisterForUpdate(zoomKey, 16, function()
        local elapsed  = GetGameTimeMilliseconds() - startTime
        local progress = math.min(1.0, elapsed / ret)
        -- Ease-out cubic: fast at start, slows near the end
        local ease     = 1 - (1 - progress) ^ 3
        local cur      = peak - (peak - origin) * ease
        SetSetting(CAM_SET, CAM_DIST, tostring(cur))
        if progress >= 1.0 then
            SetSetting(CAM_SET, CAM_DIST, tostring(origin))
            EVENT_MANAGER:UnregisterForUpdate(zoomKey)
            df.originalDist = nil
            df.isZooming    = false
        end
    end)
end

-----------------------------------------------------------
-- BLOOD BORDER FLASH
-----------------------------------------------------------
local function ApplyFlashOverlay(settings)
    local df        = DarkScrollsUI.damageFlash
    local alphaPeak = settings.alphaPeak
    local duration  = settings.duration
    -- Scale fade step so the total fade time matches duration.
    -- Each tick fires every 10 ms, so: steps = duration / 10
    local fadeStep  = alphaPeak / (duration / 10)

    local control = df.control
    if not control then return end

    local fadeKey = DarkScrollsUI.AddonNameIdentifier .. "_FlashFade"
    EVENT_MANAGER:UnregisterForUpdate(fadeKey)

    local alpha = alphaPeak
    control:SetAlpha(alpha)

    EVENT_MANAGER:RegisterForUpdate(fadeKey, 10, function()
        alpha = alpha - fadeStep
        if alpha <= 0 then
            control:SetAlpha(0)
            EVENT_MANAGER:UnregisterForUpdate(fadeKey)
        else
            control:SetAlpha(alpha)
        end
    end)
end

-----------------------------------------------------------
-- TRIGGER  (shake + flash for a given hit class)
-----------------------------------------------------------
local function TriggerDamageEffect(hitClass)
    if not IsFlashEnabled() then return end
    local settings = GetHitSettings(hitClass or "light")
    ApplyCameraShake(settings)
    ApplyFlashOverlay(settings)
    ApplyZoomOut(settings)
end

-----------------------------------------------------------
-- HEALTH MONITOR
-----------------------------------------------------------
local function OnPowerUpdate(_, unitTag, _, powerType, curHealth, _, maxHealth)
    if unitTag ~= "player" then return end
    local df = DarkScrollsUI.damageFlash

    -- Keep maxHealth in sync so ClassifyHit() has a valid denominator.
    if maxHealth and maxHealth > 0 then
        df.maxHealth = maxHealth
    end

    -- Ignore the event if lastHealth was never properly seeded
    -- (value 0 means the addon loaded before the first valid HP read).
    if df.lastHealth == 0 then
        df.lastHealth = curHealth
        return
    end

    -- Only trigger on an actual health loss, never on heals or
    -- on the death transition (curHealth reaching 0).
    if curHealth > 0 and curHealth < df.lastHealth then
        local damageTaken = df.lastHealth - curHealth
        local hitClass    = ClassifyHit(damageTaken)
        TriggerDamageEffect(hitClass)
    end

    df.lastHealth = curHealth
end

-----------------------------------------------------------
-- OVERLAY CONTROL CREATION
-----------------------------------------------------------
function DarkScrollsUI.CreateDamageFlashOverlay()
    local df = DarkScrollsUI.damageFlash
    if df.control then return end  -- already created

    local wm   = WINDOW_MANAGER
    local root = wm:CreateTopLevelWindow(DarkScrollsUI.AddonNameIdentifier .. "_FlashRoot")
    root:SetAnchorFill()
    root:SetDrawLayer(DL_OVERLAY)
    root:SetDrawTier(DT_TOP)
    root:SetMouseEnabled(false)

    local tex = wm:CreateControl(DarkScrollsUI.AddonNameIdentifier .. "_FlashRect", root, CT_TEXTURE)
    tex:SetAnchorFill()
    tex:SetTexture(IMAGE_PATH)
    tex:SetAlpha(0)

    df.control = tex
end

-----------------------------------------------------------
-- INIT  (called from DS_Init.lua after SavedVariables load)
-----------------------------------------------------------
function DarkScrollsUI.InitDamageFlash()
    DarkScrollsUI.CreateDamageFlashOverlay()

    local df = DarkScrollsUI.damageFlash

    -- Seed both health values. GetUnitPower returns (current, _, _, max).
    local hp, _, _, maxHp = GetUnitPower("player", POWERTYPE_HEALTH)
    df.lastHealth = hp    or 0
    df.maxHealth  = maxHp or 0

    local evKey = DarkScrollsUI.AddonNameIdentifier .. "_DmgFlash"
    EVENT_MANAGER:UnregisterForEvent(evKey, EVENT_POWER_UPDATE)
    EVENT_MANAGER:RegisterForEvent(evKey, EVENT_POWER_UPDATE, OnPowerUpdate)
    EVENT_MANAGER:AddFilterForEvent(evKey, EVENT_POWER_UPDATE,
        REGISTER_FILTER_POWER_TYPE, POWERTYPE_HEALTH)
    EVENT_MANAGER:AddFilterForEvent(evKey, EVENT_POWER_UPDATE,
        REGISTER_FILTER_UNIT_TAG, "player")
end

-----------------------------------------------------------
-- PUBLIC TEST FUNCTIONS  (called from DS_Menu.lua buttons)
-----------------------------------------------------------
function DarkScrollsUI.TestDamageFlashEffect()
    -- Legacy generic test kept for slash-command compatibility.
    DarkScrollsUI.DisplayProfileSystemMessage(
        "|c00aaff[DarkScrollsUI]|r Testing damage flash (light hit)...")
    TriggerDamageEffect("light")
end

function DarkScrollsUI.TestDamageFlashLightEffect()
    DarkScrollsUI.DisplayProfileSystemMessage(
        "|c00aaff[DarkScrollsUI]|r Testing light hit flash effect...")
    TriggerDamageEffect("light")
end

function DarkScrollsUI.TestDamageFlashHeavyEffect()
    DarkScrollsUI.DisplayProfileSystemMessage(
        "|c00aaff[DarkScrollsUI]|r Testing heavy hit flash effect...")
    TriggerDamageEffect("heavy")
end
