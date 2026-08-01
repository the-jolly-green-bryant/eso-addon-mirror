-- =============================================================================
-- Guild Stacker — UI Initialization
-- Sets up the progress bar for both keyboard and gamepad windows.
-- =============================================================================

local function InitProgressBar(control)
    control:SetDrawLayer(DL_OVERLAY)

    local bar = control:GetNamedChild("Bar")
    if not bar then return end

    ZO_StatusBar_SetGradientColor(bar, ZO_XP_BAR_GRADIENT_COLORS)
    ZO_StatusBar_SmoothTransition(bar, 0, 100, FORCE_VALUE)

    local pct = control:GetNamedChild("Percent")
    if pct then
        pct:SetText(" 0%")
    end
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= "GuildStacker" then return end
    EVENT_MANAGER:UnregisterForEvent("GuildStacker_UI", EVENT_ADD_ON_LOADED)

    if GS_Window then
        InitProgressBar(GS_Window)
    end
    if GS_WindowGP then
        InitProgressBar(GS_WindowGP)
    end
end

EVENT_MANAGER:RegisterForEvent("GuildStacker_UI", EVENT_ADD_ON_LOADED, OnAddonLoaded)
