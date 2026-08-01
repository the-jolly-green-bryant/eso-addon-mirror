--IMC.Version = '1.0.1' 

IMC = {}
IMC.name = 'ImmersiveMountCamera'
IMC.settings = {}
IMC.defaults = {
    thirdppovdist = 6
}

-- Set camera distance to 0 when mounting
local function MountInFirstPerson(eventCode, mounting)
    if mounting then 
        SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, 0)
    end
end
 
-- Set camera to first person POV between zone changes
local function OnZoneChange(eventID)
    if IsMounted() then
        SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, 0)
    else
        SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, 0)
    end
end

EVENT_MANAGER:RegisterForEvent(IMC.Name, EVENT_PLAYER_ACTIVATED, OnZoneChange)
EVENT_MANAGER:RegisterForEvent(IMC.Name, EVENT_MOUNTED_STATE_CHANGED, MountInFirstPerson)
 
-- ------------------------------------------------------------------
-- ------------------------------------------------------------------

function IMC.SetPpovDist()
    local ImcGetDistance = GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE)
    if tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE)) >= 2 then
        IMC.settings.thirdppovdist = ImcGetDistance
    end
end

-- Toggle 1st/3rd POV Camera
local origToggleGameCameraFirstPerson = ToggleGameCameraFirstPerson
ToggleGameCameraFirstPerson = function(...)
    if tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE)) >= 2 then
        SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, 0)
    else
        SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, IMC.settings.thirdppovdist)
    end
end

local origCameraZoomIn = CameraZoomIn
CameraZoomIn = function(...)
    origCameraZoomIn (...)
    if IsMounted and tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE)) <= 2 then
        SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, 0)
    end
end

function IMC.Initialize(eventCode, addOnName)
    if ( addOnName ~= IMC.name) then return end
    EVENT_MANAGER:UnregisterForEvent('ImmersiveMountCameraInitialize', EVENT_ADD_ON_LOADED)
    IMC.settings = ZO_SavedVars:New('ImmersiveMountCameraSavedVars', 1, nil, IMC.defaults)
    ZO_CreateStringId('SI_BINDING_NAME_SET_3RD_PPOV_DISTANCE', 'Set 3rd PPOV Distance')
end

EVENT_MANAGER:RegisterForEvent(IMC.name, EVENT_ADD_ON_LOADED, function(_event, _name) IMC.Initialize(_event, _name) end)