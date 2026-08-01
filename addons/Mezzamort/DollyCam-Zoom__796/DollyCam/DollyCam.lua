local DollyCam = {}

ZO_CreateStringId("SI_BINDING_NAME_DOLLY_ZOOM_IN", "1stP Zoom In")
ZO_CreateStringId("SI_BINDING_NAME_DOLLY_ZOOM_OUT", "1stP Zoom Out")
ZO_CreateStringId("SI_BINDING_NAME_DOLLY_TZOOM_IN", "3rdP Zoom In")
ZO_CreateStringId("SI_BINDING_NAME_DOLLY_TZOOM_OUT", "3rdP Zoom Out")
ZO_CreateStringId("SI_BINDING_NAME_DOLLY_RESET", "Dolly Reset")
ZO_CreateStringId("SI_BINDING_NAME_DOLLY_SPEED", "Dolly Set Speed")
ZO_CreateStringId("SI_BINDING_NAME_DOLLY_DUMP","Dump Camera Settings")

function DollyCam:ZoomIn()
  EVENT_MANAGER:RegisterForUpdate("DollyIn", 10, function()
  	self.current1Zoom = self.current1Zoom - self.zoomIncrement
    if self.current1Zoom < 35 then self.current1Zoom = 35 return end
   	SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_FIRST_PERSON_FIELD_OF_VIEW, self.current1Zoom)
    end)
end
function DollyCam:ZoomOut()
 	EVENT_MANAGER:RegisterForUpdate("DollyOut", 10, function()
    self.current1Zoom = self.current1Zoom + self.zoomIncrement
 		if self.current1Zoom > 65 then self.current1Zoom = 65 return end
   	SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_FIRST_PERSON_FIELD_OF_VIEW, self.current1Zoom)
   end)
end
function DollyCam:TZoomIn()
  EVENT_MANAGER:RegisterForUpdate("DollyIn", 10, function()
  	self.current3Zoom = self.current3Zoom - self.zoomIncrement
    if self.current3Zoom < 35 then self.current3Zoom = 35 return end
   	SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_FIELD_OF_VIEW, self.current3Zoom)
    end)
end
function DollyCam:TZoomOut()
 	EVENT_MANAGER:RegisterForUpdate("DollyOut", 10, function()
    self.current3Zoom = self.current3Zoom + self.zoomIncrement
 		if self.current3Zoom > 65 then self.current3Zoom = 65 return end
   	SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_FIELD_OF_VIEW, self.current3Zoom)
   end)
end
function DollyCam:Reset()
 		self.current1Zoom = 50
   	self.current3Zoom = 55
   	SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_FIRST_PERSON_FIELD_OF_VIEW, self.current1Zoom)
    SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_FIELD_OF_VIEW, self.current3Zoom)
 end
function DollyCam:Speed()
    local minmax = ""
 		self.zoomIncrement = self.zoomIncrement + 0.10
    if(self.zoomIncrement > 0.75) then self.zoomIncrement = 0.015 end
    if(self.zoomIncrement <= 0.015) then minmax = " min" end
    if(self.zoomIncrement == 0.75) then minmax = " max" end
    d("Dollyzoom "..self.zoomIncrement..minmax)
end
function DollyCam:StopZoomIn()
	EVENT_MANAGER:UnregisterForUpdate("DollyIn")
end

function DollyCam:StopZoomOut()
	EVENT_MANAGER:UnregisterForUpdate("DollyOut")
end
function DollyCam:DumpSettings()
d("DISTANCE ".. GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE))
d("1P_FIELD_OF_VIEW "..GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_FIRST_PERSON_FIELD_OF_VIEW))
d("3P_FIELD_OF_VIEW "..GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_FIELD_OF_VIEW))
d("3P_HORIZONTAL_OFFSET "..GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_OFFSET))
d("3P_HORIZONTAL_POSITION_MULTIPLIER "..GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_POSITION_MULTIPLIER))
d("3P_VERTICAL_OFFSET "..GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_VERTICAL_OFFSET))
end
function DollyCam:Initialize(eventType, addonName)
self.current1Zoom = GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_FIRST_PERSON_FIELD_OF_VIEW)
self.current3Zoom = GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_FIELD_OF_VIEW)
self.zoomIncrement = 0.25
end
EVENT_MANAGER:RegisterForEvent( "DollyCam", EVENT_ADD_ON_LOADED, function(...) DollyCam:Initialize(...) end)

_G["DollyCam"] = DollyCam