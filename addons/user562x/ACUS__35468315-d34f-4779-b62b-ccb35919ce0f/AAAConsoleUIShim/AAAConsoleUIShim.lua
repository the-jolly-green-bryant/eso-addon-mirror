-----
-- Console UI shim
-----

if CONSOLE_UI_SHIM then
    return
end

local originalIsConsoleUI = IsConsoleUI

local function IsGamepadOnlyClient()
    if type(originalIsConsoleUI) ~= "function" then
        return false
    end
    if originalIsConsoleUI() then
        return false
    end
    if type(IsGamepadUISupported) ~= "function" or type(IsKeyboardUISupported) ~= "function" then
        return false
    end
    return IsGamepadUISupported() and not IsKeyboardUISupported()
end

CONSOLE_UI_SHIM = {
    applied = false,
    original = originalIsConsoleUI,
}

if IsGamepadOnlyClient() then
    CONSOLE_UI_SHIM.applied = true
    IsConsoleUI = function()
        return true
    end
end
