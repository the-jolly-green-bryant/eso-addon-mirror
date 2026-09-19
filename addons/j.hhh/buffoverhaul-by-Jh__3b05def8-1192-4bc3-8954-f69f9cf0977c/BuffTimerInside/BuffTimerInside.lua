-- Buff Timer Inside
-- v0.2.0-console
-- Lightweight patch for ESO's built-in buff/debuff UI.
-- ESO continues to track effects, icons, sorting, duration text and cooldown timing.

local ADDON_NAME = "BuffTimerInside"

local function PatchAuraIcon(buffDebuffControl)
    if not buffDebuffControl then return end

    -- Keep the duration number inside the existing ESO icon.
    local duration = buffDebuffControl.duration or buffDebuffControl:GetNamedChild("Duration")
    local icon = buffDebuffControl.icon or buffDebuffControl:GetNamedChild("Icon")

    if duration and icon then
        duration:ClearAnchors()
        duration:SetAnchor(CENTER, icon, CENTER, 0, 0)
        duration:SetDimensions(icon:GetWidth(), icon:GetHeight())
        duration:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        duration:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        duration:SetFont("ZoFontGamepadBold20")
    end

    -- ESO already creates a ZO_DefaultCooldown control for each base-game
    -- buff/debuff icon. Enabling this flag lets the base UI drive its
    -- full-icon radial cooldown animation with the effect's own duration.
    buffDebuffControl.showCooldown = true

    -- Do not create another cooldown control. If ESO has already exposed
    -- the existing one, make sure it is allowed to be shown.
    local cooldown = buffDebuffControl.cooldown or buffDebuffControl:GetNamedChild("Cooldown")
    if cooldown then
        -- The base-game update code starts/stops the cooldown itself.
        -- We intentionally do not call StartCooldown here.
        cooldown:SetHidden(false)
    end
end

local function InstallHook()
    if not ZO_BuffDebuffStyleObject or not ZO_BuffDebuffStyleObject.SetupIcon then
        return false
    end

    ZO_PostHook(ZO_BuffDebuffStyleObject, "SetupIcon", function(_, buffDebuffControl)
        PatchAuraIcon(buffDebuffControl)
    end)

    return true
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    InstallHook()
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
