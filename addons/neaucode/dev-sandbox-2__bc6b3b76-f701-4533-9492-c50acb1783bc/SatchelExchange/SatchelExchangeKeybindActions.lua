-- SatchelExchangeKeybindActions.lua: Injects the toggle keybind into the gamepad
-- vendor buy screen. Hover the satchel, press Y/Triangle to buy one and arm the
-- auto-exchange; press again (while armed) to disarm it.

---@type LibConsoleLogger
local CL = LibConsoleLogger

local StoreUtils = SatchelExchange.StoreUtils
local KeybindUtils = SatchelExchange.KeybindUtils

local SatchelExchangeKeybindActions = {}

local function GetKeybindName()
    local StoreActions = SatchelExchange.StoreActions
    if StoreActions.IsRunning() or StoreActions.IsArmed() then
        return "Stop Auto-Exchange"
    end
    return "Auto-Exchange"
end

local function IsKeybindVisible()
    if not SatchelExchange.state.savedVars.enabled then
        return false
    end
    local StoreActions = SatchelExchange.StoreActions
    if StoreActions.IsRunning() or StoreActions.IsArmed() then
        return true
    end
    local entryData = StoreUtils.GetSelectedBuyEntry()
    return entryData ~= nil and entryData.entryType == STORE_ENTRY_TYPE_ITEM
end

local function OnKeybindPressed()
    local StoreActions = SatchelExchange.StoreActions
    if StoreActions.IsRunning() or StoreActions.IsArmed() then
        StoreActions.Stop("stopped by user")
    else
        StoreActions.Start()
    end
end

function SatchelExchangeKeybindActions.Initialize()
    local component = StoreUtils.GetBuyComponent()
    if not component or not component.keybindStripDescriptor then
        CL:Log("[SatchelExchange] ERROR: gamepad store buy component not available; keybind not installed")
        return
    end

    table.insert(component.keybindStripDescriptor, KeybindUtils.BuildToggleDescriptor({
        name = GetKeybindName,
        callback = OnKeybindPressed,
        visible = IsKeybindVisible,
    }))
end

SatchelExchange.KeybindActions = SatchelExchangeKeybindActions
