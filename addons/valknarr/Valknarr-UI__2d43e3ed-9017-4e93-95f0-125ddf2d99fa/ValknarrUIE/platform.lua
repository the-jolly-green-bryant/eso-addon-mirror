ValknarrUIEPlatform = ValknarrUIEPlatform or {}

local Platform = ValknarrUIEPlatform
local Log = ValknarrUIELog
local Safe = ValknarrUIESafe

local POINT_LABELS = {
    "TOPLEFT",
    "TOP",
    "TOPRIGHT",
    "LEFT",
    "CENTER",
    "RIGHT",
    "BOTTOMLEFT",
    "BOTTOM",
    "BOTTOMRIGHT",
}

local pointNames = nil

function Platform:IsConsoleOrGameCore()
    -- Fancy Action Bar+ / Writ Crafter / CrutchAlerts: Play Anywhere is not
    -- covered by IsConsoleUI() alone.
    local zo = Safe.Global("ZO_IsConsoleOrGameCoreUI")
    if zo ~= nil then
        return zo and true or false
    end
    local console = Safe.Global("IsConsoleUI")
    if console ~= nil then
        return console and true or false
    end
    return false
end

function Platform:IsGamepadPreferred()
    local preferred = Safe.Global("IsInGamepadPreferredMode")
    if preferred ~= nil then
        return preferred and true or false
    end
    return self:IsConsoleOrGameCore()
end

function Platform:ModeLabel()
    if self:IsConsoleOrGameCore() then
        return "CONSOLE"
    end
    if self:IsGamepadPreferred() then
        return "GAMEPAD"
    end
    return "PC"
end

function Platform:NeverMovable(control)
    if not control then
        return
    end
    if type(control.SetMovable) == "function" then
        pcall(control.SetMovable, control, false)
    end
end

function Platform:PointName(point)
    if pointNames == nil then
        pointNames = {}
        for index = 1, #POINT_LABELS do
            local label = POINT_LABELS[index]
            local value = _G[label]
            if type(value) == "number" then
                pointNames[value] = label
            end
        end
    end
    if point == nil then
        return "nil"
    end
    return pointNames[point] or tostring(point)
end

function Platform:Describe()
    return {
        mode = self:ModeLabel(),
        isConsoleOrGameCore = self:IsConsoleOrGameCore(),
        isConsoleUI = Safe.Global("IsConsoleUI"),
        zoIsConsoleOrGameCoreUI = Safe.Global("ZO_IsConsoleOrGameCoreUI"),
        isInGamepadPreferredMode = Safe.Global("IsInGamepadPreferredMode"),
        hasLibRadialMenu = type(_G.LibRadialMenu) == "table",
        hasActionBar = _G.ACTION_BAR ~= nil,
        hasKeybindStrip = KEYBIND_STRIP ~= nil,
        hasSceneManager = SCENE_MANAGER ~= nil,
        hasLeftStickX = type(_G.GetGamepadLeftStickX) == "function",
        hasRightStickX = type(_G.GetGamepadRightStickX) == "function",
        hasDirectionalInput = DIRECTIONAL_INPUT ~= nil,
    }
end

function Platform:SetPreferredFont(control, preferred)
    if not control or type(control.SetFont) ~= "function" then
        return false
    end
    if preferred and pcall(control.SetFont, control, preferred) then
        return true
    end
    return pcall(control.SetFont, control, "ZoFontGamepad34")
end

if Log then
    Log:Debug("Platform helper loaded")
end

return Platform
