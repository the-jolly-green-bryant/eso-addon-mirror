local KD = KyzderpsDerps
KD.Gamepad = {
    name = KD.name .. "Gamepad"
}
local GP = KD.Gamepad


---------------------------------------------------------------------
-- A "ratchet" for gamepad mode to avoid rapid switching between UIs
---------------------------------------------------------------------
local button
local function CreateButton()
    if (button) then return end
    button = WINDOW_MANAGER:CreateControl("KDDKeyboardUI", ZO_ChatWindow, CT_BUTTON)
    button:SetDimensions(24, 24)
    button:SetNormalTexture("/esoui/art/icons/icon_keys.dds")
    button:SetHandler("OnClicked", function()
        SetSetting(SETTING_TYPE_GAMEPAD, GAMEPAD_SETTING_INPUT_PREFERRED_MODE, INPUT_PREFERRED_MODE_AUTOMATIC)
    end)
    button:SetAnchor(RIGHT, ZO_ChatWindowOptions, LEFT, -40, 0)
    buttonCreated = true
end

local function OnGamepadChanged(_, gamepadPreferred)
    if (gamepadPreferred) then
        SetSetting(SETTING_TYPE_GAMEPAD, GAMEPAD_SETTING_INPUT_PREFERRED_MODE, INPUT_PREFERRED_MODE_ALWAYS_GAMEPAD)
        CreateButton()
        button:SetHidden(false)
    else
        if (button) then
            button:SetHidden(true)
        end
    end
end

local function OnUnload()
    SetSetting(SETTING_TYPE_GAMEPAD, GAMEPAD_SETTING_INPUT_PREFERRED_MODE, INPUT_PREFERRED_MODE_AUTOMATIC)
end


---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
function GP.Initialize()
    EVENT_MANAGER:UnregisterForEvent(GP.name .. "GamepadChanged", EVENT_GAMEPAD_PREFERRED_MODE_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(GP.name .. "GamepadUnload", EVENT_GUI_UNLOADING)
    if (KD.savedOptions.gamepad.ratchet) then
        SetSetting(SETTING_TYPE_GAMEPAD, GAMEPAD_SETTING_INPUT_PREFERRED_MODE, INPUT_PREFERRED_MODE_AUTOMATIC)
        EVENT_MANAGER:RegisterForEvent(GP.name .. "GamepadChanged", EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, OnGamepadChanged)
        EVENT_MANAGER:RegisterForEvent(GP.name .. "GamepadUnload", EVENT_GUI_UNLOADING, OnUnload)
    end
end

function GP.GetSettings()
    return {
        {
            type = "checkbox",
            name = "Gamepad mode \"ratchet\"",
            tooltip = "Intended to help avoid the UI spazzing between gamepad and keyboard when you hit both input types at once. This sets the basegame setting for \"Gamepad Mode\" to automatic, so you can use keyboard mode normally. When you start using your controller, Gamepad Mode will be set to always on, meaning keyboard inputs will no longer change it back to keyboard UI. To change back to automatic mode, you can click the  |t100%:100%:/esoui/art/icons/icon_keys.dds|t at the top of your chat window, or change it in the base game settings",
            default = false,
            getFunc = function() return KD.savedOptions.gamepad.ratchet end,
            setFunc = function(value)
                KD.savedOptions.gamepad.ratchet = value
                GP.Initialize()
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Modify vibrations",
            tooltip = "If you have controller vibrations enabled, this stops small rumbles from playing, like when spurring your mount, falling without fall damage, fishing \"nibbles\" before the bite, etc.\n\"Small\" is defined as vibrations shorter than 500 milliseconds, with vibration strength of <= 0.25 in both motors.\n\nAdditionally, this suppresses even smaller rumbles while lockpicking but increases the intensity of the more intense rumbles.\n\nAlso modifies the fishing bite to be shorter but more intense.",
            default = false,
            getFunc = function() return KD.savedOptions.gamepad.modifyVibes end,
            setFunc = function(value)
                KD.savedOptions.gamepad.modifyVibes = value
                KD.InitializeVibrations()
            end,
            width = "full",
        },
    }
end
