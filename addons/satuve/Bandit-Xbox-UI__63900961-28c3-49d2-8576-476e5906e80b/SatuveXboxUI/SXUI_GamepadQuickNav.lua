-- Satuve Xbox UI - Gamepad quick-menu focus navigation
-- LB from the right-side main menu -> left quick/category icon rail
-- RB from the left quick/category icon rail -> right-side main menu
--
-- This is intentionally limited to ESO's native MAIN_MENU_GAMEPAD so shoulder
-- buttons continue to work normally inside actual addon option controls.

SatuveXboxUI = SatuveXboxUI or {}
SatuveXboxUI.GamepadQuickNav = SatuveXboxUI.GamepadQuickNav or {}
local QuickNav = SatuveXboxUI.GamepadQuickNav

QuickNav.enabled = true
QuickNav.leftLatched = false
QuickNav.rightLatched = false
QuickNav.hooked = false

local function SafeKeyDown(keyCode)
    if type(IsKeyDown) ~= "function" or keyCode == nil then return false end
    local ok, result = pcall(IsKeyDown, keyCode)
    return ok and result == true
end

local function IsCurrentList(menu, list)
    if not menu or not list then return false end
    if type(menu.IsCurrentList) == "function" then
        local ok, result = pcall(menu.IsCurrentList, menu, list)
        if ok then return result == true end
    end
    return menu.currentList == list
end

local function SetCurrentList(menu, list)
    if not menu or not list or type(menu.SetCurrentList) ~= "function" then return false end
    local ok = pcall(menu.SetCurrentList, menu, list)
    if ok and rawget(_G, "SOUNDS") and SOUNDS.MENU_SUBCATEGORY_SELECTION then
        pcall(PlaySound, SOUNDS.MENU_SUBCATEGORY_SELECTION)
    end
    return ok
end

local function ProcessQuickNav(menu)
    if not QuickNav.enabled then return false end
    if type(IsInGamepadPreferredMode) == "function" and not IsInGamepadPreferredMode() then return false end
    if not menu then return false end

    -- ESO native gamepad main menu: categoryList = left icon rail,
    -- mainList = the text entries to its right.
    local categoryList = menu.categoryList
    local mainList = menu.mainList
    if not categoryList or not mainList then return false end

    local lb = SafeKeyDown(rawget(_G, "KEY_GAMEPAD_LEFT_SHOULDER"))
    local rb = SafeKeyDown(rawget(_G, "KEY_GAMEPAD_RIGHT_SHOULDER"))

    if not lb then QuickNav.leftLatched = false end
    if not rb then QuickNav.rightLatched = false end

    -- User requested: LB always means "move focus left" from the main list.
    if lb and not QuickNav.leftLatched and IsCurrentList(menu, mainList) then
        QuickNav.leftLatched = true
        QuickNav.rightLatched = false
        return SetCurrentList(menu, categoryList)
    end

    -- User requested: RB means "move focus right" from the quick/icon rail.
    if rb and not QuickNav.rightLatched and IsCurrentList(menu, categoryList) then
        QuickNav.rightLatched = true
        QuickNav.leftLatched = false
        return SetCurrentList(menu, mainList)
    end

    return false
end

function QuickNav.Install()
    if QuickNav.hooked then return true end
    local menu = rawget(_G, "MAIN_MENU_GAMEPAD")
    if not menu or type(menu.UpdateDirectionalInput) ~= "function" then return false end

    -- Pre-hook only consumes LB/RB when they perform the pane transfer.
    if type(ZO_PreHook) == "function" then
        ZO_PreHook(menu, "UpdateDirectionalInput", function(self)
            if ProcessQuickNav(self) then return true end
            return false
        end)
        -- Also poll the shoulder buttons directly. UpdateDirectionalInput is not
        -- guaranteed to be called by every ESO menu build for a shoulder-only
        -- press, while the lightweight update makes LB/RB transfer reliable.
        if EVENT_MANAGER and EVENT_MANAGER.RegisterForUpdate then
            EVENT_MANAGER:RegisterForUpdate("SXUI_GamepadQuickNavPoll", 20, function()
                ProcessQuickNav(rawget(_G, "MAIN_MENU_GAMEPAD"))
            end)
        end
        QuickNav.hooked = true
        return true
    end

    return false
end

local function TryInstall()
    if QuickNav.Install() then return end
    if type(zo_callLater) == "function" then
        zo_callLater(TryInstall, 1000)
    end
end

if EVENT_MANAGER and EVENT_ADD_ON_LOADED then
    EVENT_MANAGER:RegisterForEvent("SXUI_GamepadQuickNav", EVENT_ADD_ON_LOADED, function(_, addonName)
        if addonName ~= "SatuveXboxUI" then return end
        EVENT_MANAGER:UnregisterForEvent("SXUI_GamepadQuickNav", EVENT_ADD_ON_LOADED)
        TryInstall()
    end)
else
    TryInstall()
end
