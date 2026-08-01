local NeltharionsCamControl = NeltharionsCamControl

-- Constants
local ZOOM_MAX  = 10
local ZOOM_MIN  = 2
local ZOOM_FPV_MIN  = 0.5
local ZOOM_FPV  = 0
local ZOOM_STEP = 0.1

local lastZoom = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE))

local function IsZoomLimited()
    return (IsMounted() or IsWerewolf())
end


-- Overwrite original function
local origToggleGameCameraFirstPerson = ToggleGameCameraFirstPerson
ToggleGameCameraFirstPerson = function(...)
    local zoom = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE))
    local zoomAn = NeltharionsCamControl.savedVariables.zoomEnabled
    --d("toggle")
    if zoomAn == true then
      if (IsZoomLimited() or zoom <= ZOOM_FPV) then
        if zoom <= ZOOM_FPV then
            SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, lastZoom)
            --  d("zoom<FPV")
        else
            lastZoom = zoom
            SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, ZOOM_FPV)
          --  d("zoom= Zoom")
        end
      else  -- Zoom is not limited
        origToggleGameCameraFirstPerson(...)
      --  d("orig")
      end
    else
      origToggleGameCameraFirstPerson(...)
    end
    -- Remember new zoom
    NeltharionsCamControl.savedVariables.Zoom = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE))
end


-- Overwrite original function
local origCameraZoomIn = CameraZoomIn
CameraZoomIn = function(...)
    local zoom = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE))
    local zoomAn = NeltharionsCamControl.savedVariables.zoomEnabled
    if zoomAn == true then
      if (IsGameCameraSiegeControlled() or zoom > ZOOM_MIN) then
          origCameraZoomIn(...)
        --  d("zoom>zoommin")
      else  -- Within limited zoom range
        local newZoom = zoom - ZOOM_STEP
        --d("Zomm: "..newZoom)
        if newZoom < ZOOM_FPV_MIN then
            if NeltharionsCamControl.savedVariables.firstPersonEn == true then
              newZoom = ZOOM_FPV
              --d("Zzoom<FPV")
            else
              newZoom = ZOOM_FPV_MIN
              --d("Zoom FPV False")
            end

        end
        -- Only change setting if newZoom is different from current zoom
        if newZoom < zoom then
            SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, newZoom)
            -- Remember zoom for FPV toggle
            --d("zoomChange")
            lastZoom = zoom
        end
      end
    else
      origCameraZoomIn(...)
      --d("orig ZoomIn")
    end
    -- Remember new zoom
    NeltharionsCamControl.savedVariables.Zoom = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE))
end

-- Overwrite original function
local origCameraZoomOut = CameraZoomOut
CameraZoomOut = function(...)
    local zoom = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE))
    local zoomAn = NeltharionsCamControl.savedVariables.zoomEnabled
    if zoomAn == true then
      if (IsGameCameraSiegeControlled() or zoom >= ZOOM_MIN) then
        origCameraZoomOut(...)
      else  -- Within limited zoom range
        if zoom < ZOOM_FPV_MIN then
          zoom = 0.4
        end
        local newZoom = zoom + ZOOM_STEP
        SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, newZoom)
      end
    else
      origCameraZoomOut(...)
    end
    -- Remember new zoom
    NeltharionsCamControl.savedVariables.Zoom = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE))
end
