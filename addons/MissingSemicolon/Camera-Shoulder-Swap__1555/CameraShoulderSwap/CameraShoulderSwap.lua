local ADDON_NAME = "CameraShoulderSwap"

local function OnAddOnLoaded(_, addonName)
    if addonName == ADDON_NAME then
        SLASH_COMMANDS["/camerashoulderswap"] = function (extra)
            swapShoulder()
        end
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    end
end

function swapShoulder()
    local currentPosition = GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_POSITION_MULTIPLIER)
    SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_POSITION_MULTIPLIER, currentPosition * -1)

    local currentOffset = GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_OFFSET)
    SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_OFFSET, currentOffset * -1)

    -- When going out of third person and back tricks
    -- the camera to go to the position it was set to go to.
    ToggleGameCameraFirstPerson()
    ToggleGameCameraFirstPerson()
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
ZO_CreateStringId("SI_BINDING_NAME_SWAP_SHOULDER", "Camera Shoulder Swap")
