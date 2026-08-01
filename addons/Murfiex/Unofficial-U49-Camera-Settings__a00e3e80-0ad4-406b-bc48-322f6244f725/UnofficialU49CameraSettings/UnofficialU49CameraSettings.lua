local ADDON_NAME = "UnofficialU49CameraSettings"

local function AddGamepadCameraSettings()
    local cameraPanel = GAMEPAD_SETTINGS_DATA[SETTING_PANEL_CAMERA]
    if not cameraPanel then return end

    for _, entry in ipairs(cameraPanel) do
        if entry.settingId == CAMERA_SETTING_THIRD_PERSON_VERTICAL_OFFSET then
            return
        end
    end

    -- Third Person Vertical Offset
    cameraPanel[#cameraPanel + 1] = {
        controlType = OPTIONS_SLIDER,
        system = SETTING_TYPE_CAMERA,
        settingId = CAMERA_SETTING_THIRD_PERSON_VERTICAL_OFFSET,
        panel = SETTING_PANEL_CAMERA,
        text = SI_INTERFACE_OPTIONS_CAMERA_THIRD_PERSON_VERTICAL_OFFSET,
        tooltipText = SI_INTERFACE_OPTIONS_CAMERA_THIRD_PERSON_VERTICAL_OFFSET_TOOLTIP,
        minValue = -0.3,
        maxValue = 0.5,
        valueFormat = "%.2f",
        showValue = true,
        defaultMarker = 0,
        showValueMin = -60,
        showValueMax = 100,
    }

    -- Siege Weaponry Camera
    cameraPanel[#cameraPanel + 1] = {
        controlType = OPTIONS_FINITE_LIST,
        system = SETTING_TYPE_CAMERA,
        settingId = CAMERA_SETTING_THIRD_PERSON_SIEGE_WEAPONRY,
        panel = SETTING_PANEL_CAMERA,
        text = SI_INTERFACE_OPTIONS_CAMERA_THIRD_PERSON_SIEGE_WEAPONRY,
        tooltipText = SI_INTERFACE_OPTIONS_CAMERA_THIRD_PERSON_SIEGE_WEAPONRY_TOOLTIP,
        valid = {
            SIEGE_CAMERA_CHOICE_FREE,
            SIEGE_CAMERA_CHOICE_CONSTRAINED,
        },
        valueStringPrefix = "SI_SIEGECAMERACHOICE",
    }
end

local function OnAddonLoaded(event, name)
    if name ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)

