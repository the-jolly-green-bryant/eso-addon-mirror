--[[

Unlimited Camera Zoom
by CaptainBlagbird
https://github.com/CaptainBlagbird

--]]

-- Addon info
UnlimitedCameraZoom = {}
UnlimitedCameraZoom.name = "UnlimitedCameraZoom"

-- Constants
local ZOOM_MAX  = 10
local ZOOM_MIN  = 2
local ZOOM_FPV  = 0
local ZOOM_STEP = 0.5

-- Local variables
local savedVars = {}
local lastZoom = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE))


local function IsZoomLimited()
    return (IsMounted() or IsWerewolf())
end

-- Overwrite original function
local origToggleGameCameraFirstPerson = ToggleGameCameraFirstPerson
ToggleGameCameraFirstPerson = function(...)
    local zoom = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE))
    if IsZoomLimited() or zoom <= ZOOM_FPV then
        if zoom <= ZOOM_FPV then
            SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, lastZoom)
        else
            lastZoom = zoom
            SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, ZOOM_FPV)
        end
    else  -- Zoom is not limited
        origToggleGameCameraFirstPerson(...)
    end
    -- Remember new zoom
    savedVars.zoom = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE))
end

-- Overwrite original function
local origCameraZoomIn = CameraZoomIn
CameraZoomIn = function(...)
    local zoom = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE))
    if IsGameCameraSiegeControlled() or zoom > ZOOM_MIN then
        origCameraZoomIn(...)
    else  -- Within limited zoom range
        local newZoom = zoom - ZOOM_STEP
        if newZoom < ZOOM_FPV then
            newZoom = ZOOM_FPV
        end
        -- Only change setting if newZoom is different from current zoom
        if newZoom < zoom then
            SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, newZoom)
            -- Remember zoom for FPV toggle
            lastZoom = zoom
        end
    end
    -- Remember new zoom
    savedVars.zoom = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE))
end

-- Overwrite original function
local origCameraZoomOut = CameraZoomOut
CameraZoomOut = function(...)
    local zoom = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE))
    if IsGameCameraSiegeControlled() or zoom >= ZOOM_MIN then
        origCameraZoomOut(...)
    else  -- Within limited zoom range
        local newZoom = zoom + ZOOM_STEP
        SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, newZoom)
    end
    -- Remember new zoom
    savedVars.zoom = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE))
end

-- Event handler function for EVENT_PLAYER_ACTIVATED
local function OnPlayerActivated(event)
    SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, savedVars.zoom)
end

-- Event handler function for EVENT_PLAYER_ACTIVATED (only the first time)
local function OnInit(event)
    -- Set up Saved Variables
    savedVars = ZO_SavedVars:New(UnlimitedCameraZoom.name.."_SavedVariables", 1, nil, {["zoom"]=lastZoom})
    
    EVENT_MANAGER:UnregisterForEvent(UnlimitedCameraZoom.name, EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:RegisterForEvent(UnlimitedCameraZoom.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end
EVENT_MANAGER:RegisterForEvent(UnlimitedCameraZoom.name, EVENT_PLAYER_ACTIVATED, OnInit)