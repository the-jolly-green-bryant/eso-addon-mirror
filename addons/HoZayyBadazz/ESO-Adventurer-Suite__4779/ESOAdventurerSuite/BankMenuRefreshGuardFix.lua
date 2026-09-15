-- ESO Adventurer Suite
-- v0.29.660 - keep bank context menus open while the bank's 150 ms refresh loop runs.
-- BankGridUnifiedV2 refreshes continuously. Re-rendering the Suite bank while
-- ZO_Menu/LibCustomMenu is open causes the menu to disappear almost immediately.

local EPC = ESOProgressionCoach
if not EPC then return end
local U = EPC.BankGridUnifiedV2
if not U or type(U.Refresh) ~= "function" or U._easMenuRefreshGuard029660 then return end
U._easMenuRefreshGuard029660 = true

local function isVisible(control)
    if not control then return false end
    if type(control.IsHidden) == "function" then
        local ok, hidden = pcall(control.IsHidden, control)
        if ok then return hidden == false end
    end
    return false
end

local function contextMenuOpen()
    if isVisible(rawget(_G, "ZO_Menu")) then return true end
    if isVisible(rawget(_G, "LibCustomMenuSubmenu")) then return true end
    return false
end

local baseRefresh = U.Refresh
function U:Refresh(...)
    if contextMenuOpen() then
        return
    end
    return baseRefresh(self, ...)
end

EPC.bankMenuRefreshGuard029660 = true
