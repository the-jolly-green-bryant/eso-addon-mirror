-- ESO Adventurer Suite
-- Modern UI rounded shell + rounded controls visibility fix.
-- Keeps the shell/window hit area intact for dragging and resizing while
-- suppressing rectangular native backdrop art behind rounded DDS surfaces.

local EPC = ESOProgressionCoach
if not EPC or not EPC.ModernAppUI then return end

local M = EPC.ModernAppUI
local FALLBACK_NAME = "EAS_ModernShell02890_NativeFallback029116"

local function HideSquareShellFallback029476()
    local fallback = nil

    if M.shell and M.shell.nativeFallback029116 then
        fallback = M.shell.nativeFallback029116
    end

    if not fallback and _G then
        fallback = _G[FALLBACK_NAME]
    end

    if fallback then
        if fallback.SetHidden then fallback:SetHidden(true) end
        if fallback.SetAlpha then fallback:SetAlpha(0) end
        if fallback.SetCenterColor then fallback:SetCenterColor(0, 0, 0, 0) end
        if fallback.SetEdgeColor then fallback:SetEdgeColor(0, 0, 0, 0) end
        return true
    end

    return false
end

local function ClearRoundedBackdrop029478(bg)
    if not bg or not bg.roundTex02890 then return end

    -- Mark this surface like the shell so ModernAppUI's normal painter does not
    -- restore a rectangular native center behind the rounded DDS.
    bg._shellSurface02890 = true
    if bg.SetCenterColor then bg:SetCenterColor(0, 0, 0, 0) end
    if bg.SetEdgeColor then bg:SetEdgeColor(0, 0, 0, 0) end
end

local function MakeButtonRoundedOnly029478(button)
    if not button or not button.bg then return end
    ClearRoundedBackdrop029478(button.bg)

    if button._roundedHandlers029478 then return end
    button._roundedHandlers029478 = true

    -- The normal hover/exit handlers still choose the correct selected, hover,
    -- alliance-accent and disabled colors on the rounded texture. Clear only the
    -- rectangular CT_BACKDROP after those handlers run.
    if button.GetHandler and button.SetHandler then
        local oldEnter = button:GetHandler("OnMouseEnter")
        local oldExit = button:GetHandler("OnMouseExit")

        button:SetHandler("OnMouseEnter", function(control, ...)
            if oldEnter then oldEnter(control, ...) end
            if control then ClearRoundedBackdrop029478(control.bg) end
        end)

        button:SetHandler("OnMouseExit", function(control, ...)
            if oldExit then oldExit(control, ...) end
            if control then ClearRoundedBackdrop029478(control.bg) end
        end)
    end
end

local function WalkRoundedButtons029478(control)
    if not control then return end

    -- Every ModernAppUI button() creates a child background named *_BG and
    -- attaches it back to the CT_BUTTON as button.bg. This catches top tabs,
    -- side/rail tabs, page-mode tabs, PREV/NEXT controls and all action buttons
    -- without changing flat content cards or edit-box hosts.
    if control.bg and control.bg.roundTex02890 then
        MakeButtonRoundedOnly029478(control)
    end

    if control.GetNumChildren and control.GetChild then
        local okCount, count = pcall(control.GetNumChildren, control)
        count = okCount and tonumber(count) or 0
        for i = 1, count do
            local okChild, child = pcall(control.GetChild, control, i)
            if okChild and child then WalkRoundedButtons029478(child) end
        end
    end
end

local function ForceRoundedModernControls029478()
    for _, button in pairs(M.groupButtons or {}) do
        MakeButtonRoundedOnly029478(button)
    end
    if M.window then WalkRoundedButtons029478(M.window) end
end

if type(M.CreateShell) == "function" and not M._roundedShellFix029476 then
    local CreateShellBase029476 = M.CreateShell
    function M:CreateShell(...)
        local result = CreateShellBase029476(self, ...)
        HideSquareShellFallback029476()
        ForceRoundedModernControls029478()
        return result
    end
    M._roundedShellFix029476 = true
end

HideSquareShellFallback029476()
ForceRoundedModernControls029478()

if type(M.ApplyWindowAppearance029363) == "function" and not M._roundedAppearanceFix029476 then
    local ApplyAppearanceBase029476 = M.ApplyWindowAppearance029363
    function M:ApplyWindowAppearance029363(...)
        local result = ApplyAppearanceBase029476(self, ...)
        HideSquareShellFallback029476()
        ForceRoundedModernControls029478()
        return result
    end
    M._roundedAppearanceFix029476 = true
end

if type(M.UpdateTopNavigation) == "function" and not M._roundedTopTabsFix029477 then
    local UpdateTopNavigationBase029477 = M.UpdateTopNavigation
    function M:UpdateTopNavigation(...)
        local result = UpdateTopNavigationBase029477(self, ...)
        ForceRoundedModernControls029478()
        return result
    end
    M._roundedTopTabsFix029477 = true
end

-- SetTab is important because many inner page buttons/tabs are created lazily
-- or repainted when switching pages. Re-sweep after the page is active.
if type(M.SetTab) == "function" and not M._roundedInnerControlsFix029478 then
    local SetTabBase029478 = M.SetTab
    function M:SetTab(...)
        local result = SetTabBase029478(self, ...)
        ForceRoundedModernControls029478()
        return result
    end
    M._roundedInnerControlsFix029478 = true
end

if type(M.RefreshCurrent) == "function" and not M._roundedRefreshFix029478 then
    local RefreshCurrentBase029478 = M.RefreshCurrent
    function M:RefreshCurrent(...)
        local result = RefreshCurrentBase029478(self, ...)
        ForceRoundedModernControls029478()
        return result
    end
    M._roundedRefreshFix029478 = true
end

if type(M.Show) == "function" and not M._roundedShowFix029476 then
    local ShowBase029476 = M.Show
    function M:Show(...)
        local result = ShowBase029476(self, ...)
        HideSquareShellFallback029476()
        ForceRoundedModernControls029478()
        return result
    end
    M._roundedShowFix029476 = true
end
