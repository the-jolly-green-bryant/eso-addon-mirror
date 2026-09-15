-- ESO Adventurer Suite
-- v0.29.551 - Modern UI foreground ownership.
-- The Modern application is a menu-level surface, so persistent gameplay HUD
-- overlays must never draw over it. Keep the app at the highest Suite draw
-- level and suppress gameplay overlays only while the app is open.

local EPC = ESOProgressionCoach
if not EPC or not EPC.ModernAppUI then return end

local M = EPC.ModernAppUI

local function ForceModernForeground029551()
    local window = M.window
    if not window then return end

    if type(window.SetDrawTier) == "function" and rawget(_G, "DT_HIGH") ~= nil then
        pcall(window.SetDrawTier, window, DT_HIGH)
    end
    if type(window.SetDrawLayer) == "function" and rawget(_G, "DL_OVERLAY") ~= nil then
        pcall(window.SetDrawLayer, window, DL_OVERLAY)
    end
    if type(window.SetDrawLevel) == "function" then
        pcall(window.SetDrawLevel, window, 100000)
    end
end

-- Treat the Suite application like a real menu for persistent HUD visibility.
-- This keeps player/target/group frames, minimap, combat cards, timers, quest
-- trackers and similar HUD readouts behind/hidden while Modern UI is open.
if type(EPC.IsGameplayHudSuppressed) == "function" and not EPC._modernAppHudSuppression029551 then
    local baseSuppressed = EPC.IsGameplayHudSuppressed
    function EPC:IsGameplayHudSuppressed(...)
        if self.modernAppUiOpen029551 == true then return true end
        return baseSuppressed(self, ...)
    end
    EPC._modernAppHudSuppression029551 = true
end

if type(M.CreateShell) == "function" and not M._foregroundCreate029551 then
    local baseCreate = M.CreateShell
    function M:CreateShell(...)
        local result = baseCreate(self, ...)
        ForceModernForeground029551()
        return result
    end
    M._foregroundCreate029551 = true
end

if type(M.Show) == "function" and not M._foregroundShow029551 then
    local baseShow = M.Show
    function M:Show(...)
        EPC.modernAppUiOpen029551 = true
        local result = baseShow(self, ...)
        ForceModernForeground029551()
        if type(EPC.RefreshGameplayOverlays) == "function" then
            pcall(EPC.RefreshGameplayOverlays, EPC)
        end
        return result
    end
    M._foregroundShow029551 = true
end

if type(M.Hide) == "function" and not M._foregroundHide029551 then
    local baseHide = M.Hide
    function M:Hide(...)
        local result = baseHide(self, ...)
        EPC.modernAppUiOpen029551 = false
        if type(EPC.RefreshGameplayOverlays) == "function" then
            pcall(EPC.RefreshGameplayOverlays, EPC)
        end
        return result
    end
    M._foregroundHide029551 = true
end

-- SetTab/RefreshCurrent can repaint or lazily create content. Reassert the
-- top-level foreground level after those operations without changing child
-- ordering inside the Modern UI itself.
if type(M.SetTab) == "function" and not M._foregroundTab029551 then
    local baseSetTab = M.SetTab
    function M:SetTab(...)
        local result = baseSetTab(self, ...)
        ForceModernForeground029551()
        return result
    end
    M._foregroundTab029551 = true
end

if type(M.RefreshCurrent) == "function" and not M._foregroundRefresh029551 then
    local baseRefresh = M.RefreshCurrent
    function M:RefreshCurrent(...)
        local result = baseRefresh(self, ...)
        ForceModernForeground029551()
        return result
    end
    M._foregroundRefresh029551 = true
end

ForceModernForeground029551()
