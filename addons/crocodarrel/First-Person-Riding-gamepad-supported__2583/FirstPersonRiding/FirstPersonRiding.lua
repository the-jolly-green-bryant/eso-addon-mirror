IHR = {}
IHR.Name = "FirstPersonRiding"
IHR.Version = "2.8"

local DefaultZoomLimit  = 2
local Zoom1st  = 0
local ZoomStep = 1
local LoadedZoomDist = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE))

local origToggleGameCameraFirstPerson = ToggleGameCameraFirstPerson
ToggleGameCameraFirstPerson = function(...)
	local zoom = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE))
	if IsMounted() or zoom <= Zoom1st then
		if zoom <= Zoom1st then
			SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, LoadedZoomDist)
		else
			LoadedZoomDist = zoom
			SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, Zoom1st)
		end
	end
end

local origCameraZoomIn = CameraZoomIn
CameraZoomIn = function(...)
	local zoom = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE))
	if zoom > DefaultZoomLimit then
		origCameraZoomIn(...)
	else
		local NewZoomVal = zoom - ZoomStep
		if NewZoomVal < Zoom1st then
			NewZoomVal = Zoom1st
		end
		if NewZoomVal < zoom then
			SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, NewZoomVal)
			LoadedZoomDist = zoom
		end
	end
end

local origCameraZoomOut = CameraZoomOut
CameraZoomOut = function(...)
	local zoom = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE))
		if zoom >= DefaultZoomLimit then
			origCameraZoomOut(...)
		else
		local NewZoomVal = zoom + ZoomStep
		SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, NewZoomVal)
	end
end

GameCameraGamepadZoomDown = ToggleGameCameraFirstPerson
