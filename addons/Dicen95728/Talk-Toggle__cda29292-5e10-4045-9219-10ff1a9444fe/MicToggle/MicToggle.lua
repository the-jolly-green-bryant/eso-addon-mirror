-- Mic Toggle v1.2
-- Mute/unmute yourself in voice chat.
--  * /mic                -> toggle
--  * /mic bind <button>  -> bind a controller/keyboard button to the toggle
--  * /mic unbind         -> remove the binding
--  * /mic binds          -> list available button names + current binding
-- Optional LibAddonMenu panel offers the same as a dropdown.
-- "Mute" = stop transmitting (game's own null-channel trick): you stay in the
-- channel and still hear everyone - you just stop sending.

local ADDON_NAME = "MicToggle"
local savedChannel = nil

ZO_CreateStringId("SI_BINDING_NAME_MICTOGGLE_TOGGLE", "Toggle Voice Mic")

-- ---------------------------------------------------------------------------
-- Bindable button catalog: name -> keycode global. Built at runtime; entries
-- whose keycode constant doesn't exist in this client are skipped silently.
-- ---------------------------------------------------------------------------
local CANDIDATES = {
    -- gamepad
    { name = "dpadup",     global = "KEY_GAMEPAD_DPAD_UP" },
    { name = "dpaddown",   global = "KEY_GAMEPAD_DPAD_DOWN" },
    { name = "dpadleft",   global = "KEY_GAMEPAD_DPAD_LEFT" },
    { name = "dpadright",  global = "KEY_GAMEPAD_DPAD_RIGHT" },
    { name = "lstick",     global = "KEY_GAMEPAD_LEFT_STICK" },
    { name = "rstick",     global = "KEY_GAMEPAD_RIGHT_STICK" },
    { name = "back",       global = "KEY_GAMEPAD_BACK" },
    { name = "start",      global = "KEY_GAMEPAD_START" },
    -- keyboard (PC testing / USB keyboard)
    { name = "p",   global = "KEY_P"   },
    { name = "f9",  global = "KEY_F9"  },
    { name = "f10", global = "KEY_F10" },
    { name = "f11", global = "KEY_F11" },
    { name = "v",   global = "KEY_V"   },
}

local function AvailableButtons()
    local out = {}
    for _, c in ipairs(CANDIDATES) do
        local code = _G[c.global]
        if type(code) == "number" then
            out[#out + 1] = { name = c.name, code = code }
        end
    end
    return out
end

local function FindButton(name)
    name = zo_strlower(name or "")
    for _, b in ipairs(AvailableButtons()) do
        if b.name == name then return b end
    end
    return nil
end

-- ---------------------------------------------------------------------------
-- Binding plumbing
-- ---------------------------------------------------------------------------
local function GetToggleActionIndices()
    if not GetActionIndicesFromName then return nil end
    local layer, category, action = GetActionIndicesFromName("MICTOGGLE_TOGGLE")
    if layer and category and action then return layer, category, action end
    return nil
end

local function CurrentBindingText()
    local layer, category, action = GetToggleActionIndices()
    if not layer then return "unknown" end
    local key = GetActionBindingInfo and select(1, GetActionBindingInfo(layer, category, action, 1))
    if key and key ~= 0 and GetKeyName then
        return GetKeyName(key) or ("keycode " .. key)
    end
    return "none"
end

local function BindToggleTo(button)
    local layer, category, action = GetToggleActionIndices()
    if not layer then
        d("[Mic Toggle] Couldn't locate the toggle action - binding unavailable on this client.")
        return false
    end
    local ok = false
    if CallSecureProtected then
        ok = CallSecureProtected("BindKeyToAction", layer, category, action, 1, button.code, 0, 0, 0, 0)
    end
    if ok then
        d(string.format("[Mic Toggle] Bound to %s. If the game already uses that button, the game's own action may win - pick another if it misbehaves.", button.name))
    else
        d("[Mic Toggle] Binding was blocked (try again out of combat). You can always use /mic instead.")
    end
    return ok
end

local function UnbindToggle()
    local layer, category, action = GetToggleActionIndices()
    if not layer then return end
    local ok = false
    if CallSecureProtected and UnbindAllKeysFromAction then
        ok = CallSecureProtected("UnbindAllKeysFromAction", layer, category, action)
    end
    d(ok and "[Mic Toggle] Unbound." or "[Mic Toggle] Unbind was blocked (try out of combat).")
end

-- ---------------------------------------------------------------------------
-- The toggle itself
-- ---------------------------------------------------------------------------
local function Announce(text)
    if CENTER_SCREEN_ANNOUNCE and CSA_CATEGORY_SMALL_TEXT then
        local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT)
        params:SetText(text)
        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
    else
        d("[Mic Toggle] " .. text)
    end
end

function MicToggle_Toggle()
    local mgr = VOICE_CHAT_MANAGER
    if not mgr then
        d("[Mic Toggle] Voice chat isn't available here.")
        return
    end

    if mgr:HasActiveTransmitChannel() then
        savedChannel = mgr:GetActiveChannel()
        mgr:StopTransmitting()
        Announce("Mic OFF")
    else
        local target = savedChannel or mgr:GetActiveChannel() or mgr.desiredActiveChannel
        if target then
            mgr:TransmitChannel(target)
            Announce("Mic ON")
        else
            Announce("No voice channel to restore - pick one in the Voice Chat menu")
        end
    end
end

-- ---------------------------------------------------------------------------
-- Slash commands (always available; console-safe)
-- ---------------------------------------------------------------------------
local function RegisterSlash()
    SLASH_COMMANDS["/mic"] = function(args)
        args = zo_strtrim(args or "")
        if args == "" then
            MicToggle_Toggle()
            return
        end
        local cmd, rest = args:match("^(%S+)%s*(.*)$")
        cmd = zo_strlower(cmd)

        if cmd == "bind" then
            local button = FindButton(rest)
            if button then
                BindToggleTo(button)
            else
                d("[Mic Toggle] Unknown button '" .. tostring(rest) .. "'. Use /mic binds to list options.")
            end
        elseif cmd == "unbind" then
            UnbindToggle()
        elseif cmd == "binds" then
            local names = {}
            for _, b in ipairs(AvailableButtons()) do names[#names + 1] = b.name end
            d("[Mic Toggle] Current binding: " .. CurrentBindingText())
            d("[Mic Toggle] Available: " .. table.concat(names, ", "))
            d("[Mic Toggle] Usage: /mic bind dpaddown")
        else
            d("[Mic Toggle] /mic | /mic bind <button> | /mic unbind | /mic binds")
        end
    end
end

-- ---------------------------------------------------------------------------
-- Optional LAM settings panel
-- ---------------------------------------------------------------------------
local pendingChoice = nil
local panelBuilt = false
local function BuildSettingsPanel()
    local LAM = LibAddonMenu2
    if not LAM then return end
    panelBuilt = true

    local choices = {}
    for _, b in ipairs(AvailableButtons()) do choices[#choices + 1] = b.name end

    LAM:RegisterAddonPanel("MicTogglePanel", {
        type = "panel", name = "Mic Toggle",
        author = "@Dicen95728", version = "1.4", registerForRefresh = true,
    })
    LAM:RegisterOptionControls("MicTogglePanel", {
        {
            type = "description",
            text = function() return "Current binding: " .. CurrentBindingText() end,
        },
        {
            type = "dropdown", name = "Button for the toggle",
            choices = choices,
            getFunc = function() return pendingChoice or choices[1] end,
            setFunc = function(v) pendingChoice = v end,
        },
        {
            type = "button", name = "Bind selected button",
            func = function()
                local b = FindButton(pendingChoice or choices[1])
                if b then BindToggleTo(b) end
            end,
        },
        {
            type = "button", name = "Unbind",
            func = UnbindToggle,
        },
        {
            type = "description",
            text = "You can always toggle with the /mic chat command.",
        },
    })
end

-- ---------------------------------------------------------------------------
-- Mouse & keyboard support: auto-bind P into the action's SECOND binding slot
-- (slot 1 stays whatever controller button the player chose). Only fills the
-- slot if it's empty, so a custom slot-2 choice is never overwritten.
-- ---------------------------------------------------------------------------
local function EnsureKeyboardBind()
    local layer, category, action = GetToggleActionIndices()
    if not layer then return end
    if type(KEY_P) ~= "number" then return end

    local slot2Key = GetActionBindingInfo and select(1, GetActionBindingInfo(layer, category, action, 2))
    if slot2Key and slot2Key ~= 0 then return end   -- already customized

    if CallSecureProtected then
        local ok = CallSecureProtected("BindKeyToAction", layer, category, action, 2, KEY_P, 0, 0, 0, 0)
        if ok then
            d("[Mic Toggle] P key bound for mouse & keyboard players (controller binding unaffected).")
        end
    end
end

-- ---------------------------------------------------------------------------
-- Player-menu entry ("Mic Toggle" in the main scroll-down list) + its dialog
-- ---------------------------------------------------------------------------
local function ButtonCatalogNames()
    local names = {}
    for _, b in ipairs(AvailableButtons()) do names[#names + 1] = b.name end
    return names
end

local bindCycleIndex = 0
local function RegisterMenuDialog()
    ESO_Dialogs["MICTOGGLE_MENU"] = {
        canQueue = true,
        gamepadInfo = { dialogType = GAMEPAD_DIALOGS.PARAMETRIC },
        setup = function(dialog) dialog:setupFunc() end,
        title = { text = "Mic Toggle" },
        mainText = { text = "Mute keeps you in the channel - you still hear everyone." },
        parametricList = {
            {
                template = "ZO_GamepadMenuEntryTemplate",
                templateData = {
                    text = "Toggle Mic Now",
                    setup = ZO_SharedGamepadEntry_OnSetup,
                    callback = function() MicToggle_Toggle() end,
                },
            },
            {
                template = "ZO_GamepadMenuEntryTemplate",
                templateData = {
                    text = "Bind Next Button (cycles: see chat)",
                    setup = ZO_SharedGamepadEntry_OnSetup,
                    callback = function()
                        local buttons = AvailableButtons()
                        if #buttons == 0 then d("[Mic Toggle] No bindable buttons on this client.") return end
                        bindCycleIndex = (bindCycleIndex % #buttons) + 1
                        BindToggleTo(buttons[bindCycleIndex])
                    end,
                },
            },
            {
                template = "ZO_GamepadMenuEntryTemplate",
                templateData = {
                    text = "Unbind",
                    setup = ZO_SharedGamepadEntry_OnSetup,
                    callback = function() UnbindToggle() end,
                },
            },
            {
                template = "ZO_GamepadMenuEntryTemplate",
                templateData = {
                    text = "Show Current Binding",
                    setup = ZO_SharedGamepadEntry_OnSetup,
                    callback = function() d("[Mic Toggle] Current binding: " .. CurrentBindingText()) end,
                },
            },
        },
        buttons = {
            {
                keybind = "DIALOG_PRIMARY",
                text = SI_GAMEPAD_SELECT_OPTION,
                callback = function(dialog)
                    local targetData = dialog.entryList and dialog.entryList:GetTargetData()
                    if targetData and targetData.callback then targetData.callback() end
                end,
            },
            {
                keybind = "DIALOG_NEGATIVE",
                text = SI_DIALOG_CLOSE,
            },
        },
    }
end

local function InstallMainMenuEntry()
    if not ZO_MENU_ENTRIES or not ZO_GamepadEntryData then
        d("[Mic Toggle] Player menu integration unavailable on this client - use /mic instead.")
        return
    end

    local entry = ZO_GamepadEntryData:New("Mic Toggle",
        "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_communications.dds")
    entry:SetIconTintOnSelection(true)
    entry:SetIconDisabledTintOnSelection(true)
    entry.id = 990001
    entry.data = {
        name = "Mic Toggle",
        icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_communications.dds",
        activatedCallback = function()
            ZO_Dialogs_ShowGamepadDialog("MICTOGGLE_MENU")
        end,
    }

    -- insert just before Options; append if we can't find it
    local insertAt = #ZO_MENU_ENTRIES + 1
    for i, e in ipairs(ZO_MENU_ENTRIES) do
        if e.data and e.data.scene == "gamepad_options_root" then
            insertAt = i
            break
        end
    end
    table.insert(ZO_MENU_ENTRIES, insertAt, entry)
end

-- ---------------------------------------------------------------------------
-- Init
-- ---------------------------------------------------------------------------
local function OnAddOnLoaded(_, addOnName)
    if addOnName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    RegisterSlash()
    BuildSettingsPanel()
    RegisterMenuDialog()
    InstallMainMenuEntry()

    -- Fallback: if LibAddonMenu loaded after us, build the panel once the
    -- player is in the world instead of silently having no settings menu.
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, function()
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED)
        if not panelBuilt then BuildSettingsPanel() end
        zo_callLater(EnsureKeyboardBind, 2000)
    end)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
