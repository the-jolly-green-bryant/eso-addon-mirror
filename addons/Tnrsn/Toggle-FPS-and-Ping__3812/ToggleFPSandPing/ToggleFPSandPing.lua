ToggleFPSandPing = {}

ToggleFPSandPing.name = "ToggleFPSandPing"

function ToggleFPSandPing.IsFirstLaunch()
    ToggleFPSandPing.savedVariables = ZO_SavedVars:NewCharacterIdSettings("ToggleFPSnPing", 1, nil, {})
    local firstLaunch = ToggleFPSandPing.savedVariables.firstLaunch
    
    if firstLaunch == nil then
        d("Thanks for downloading Toggle FPS & Latency Add On! For first-time setup, please assign a key via: ESC > Controls > AddOn Keybinds > FPS and Ping Toggle.")
        firstLaunch = 0
        ToggleFPSandPing.savedVariables.firstLaunch = firstLaunch
    end
end

function ToggleFPSandPing.Toggle()
    -- Toggles FPS and ping by checking if the latency setting is on or off.
    if (GetSetting(SETTING_TYPE_UI, UI_SETTING_SHOW_LATENCY) == "0") 
    then
        SetSetting(SETTING_TYPE_UI, UI_SETTING_SHOW_LATENCY, "1")
        SetSetting(SETTING_TYPE_UI, UI_SETTING_SHOW_FRAMERATE, "1")
    else
        SetSetting(SETTING_TYPE_UI, UI_SETTING_SHOW_LATENCY, "0")
        SetSetting(SETTING_TYPE_UI, UI_SETTING_SHOW_FRAMERATE, "0")
    end
end

ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_BUTTON", "Toggle FPS and Ping")
EVENT_MANAGER:RegisterForEvent(ToggleFPSandPing.name, EVENT_PLAYER_ACTIVATED, ToggleFPSandPing.IsFirstLaunch)
