IHR = {}
IHR.Name = "ImmersiveHorseRiding"
IHR.Version = "3.0"

local ZoomMinimi  = 2
local Zoom1st  = 0
local ZoomAskel = 1
local savedVars = {}
local viimeZoom = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE))
local function IsZoomLimited()
return IsMounted()
end
local function GetGamepadType()
return 1
end

local origToggleGameCameraFirstPerson = ToggleGameCameraFirstPerson
ToggleGameCameraFirstPerson = function(...)
	local zoom = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE))
		if IsZoomLimited() or zoom <= Zoom1st then
		if zoom <= Zoom1st then
		SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, viimeZoom)
	else
		viimeZoom = zoom
		SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, Zoom1st)
end
	else
		origToggleGameCameraFirstPerson(...)
end
end

local origCameraZoomIn = CameraZoomIn
CameraZoomIn = function(...)
	local zoom = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE))
		if zoom > ZoomMinimi then
		origCameraZoomIn(...)
	else
	local uusiZoom = zoom - ZoomAskel
		if uusiZoom < Zoom1st then
		uusiZoom = Zoom1st
end
	if uusiZoom < zoom then
		SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, uusiZoom)
	viimeZoom = zoom
end
end
savedVars.zoom = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE))
end

local origCameraZoomOut = CameraZoomOut
CameraZoomOut = function(...)
	local zoom = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE))
		if zoom >= ZoomMinimi then
		origCameraZoomOut(...)
	else
	local uusiZoom = zoom + ZoomAskel
		SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, uusiZoom)
end
savedVars.zoom = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE))
end