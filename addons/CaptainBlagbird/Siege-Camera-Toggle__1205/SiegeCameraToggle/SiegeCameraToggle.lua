--[[

Siege Camera Toggle
by CaptainBlagbird
https://github.com/CaptainBlagbird

--]]

-- Binding string
ZO_CreateStringId("SI_BINDING_NAME_SIEGECAMERATOGGLE", "Toggle Siege Camera")
SafeAddVersion("SI_BINDING_NAME_SIEGECAMERATOGGLE", 1)

-- Function for binding
function SiegeCameraToggle()
    local setting = GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_SIEGE_WEAPONRY)
    if setting == "1" then setting = "0" else setting = "1" end
    SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_SIEGE_WEAPONRY, setting, 1)
end