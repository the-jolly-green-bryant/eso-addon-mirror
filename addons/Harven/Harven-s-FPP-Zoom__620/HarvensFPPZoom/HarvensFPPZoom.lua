local HarvensFPPZoom = {}

ZO_CreateStringId("SI_BINDING_NAME_FPP_ZOOM_IN", "Harven's FPP Camera Zoom")

function HarvensFPPZoom:StartZooming()
	if self.currentFPPZoom == 0 then
		self.defaultFPPZoom = GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_FIRST_PERSON_FIELD_OF_VIEW)
	end
	
	if self.currentTPPZoom == 0 then
		self.defaultTPPZoom = GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_FIELD_OF_VIEW)
	end
	
	if self.currentFPPZoom ~= 0 or self.currentTPPZoom ~= 0 then
	
		if self.currentFPPZoom ~= 0 then
			SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_FIRST_PERSON_FIELD_OF_VIEW, self.defaultFPPZoom)
			self.currentFPPZoom = 0
		end
		
		if self.currentTPPZoom ~= 0 then
			SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_FIELD_OF_VIEW, self.defaultTPPZoom)
			self.currentTPPZoom = 0
		end
		
		return
	end
	
	self.currentFPPZoom = self.defaultFPPZoom
	self.currentTPPZoom = self.defaultTPPZoom
	
	EVENT_MANAGER:RegisterForUpdate("HarvensFPPZoomIn", 10, function()
		self.currentFPPZoom = self.currentFPPZoom - 1
		self.currentTPPZoom = self.currentTPPZoom - 1
		if self.currentFPPZoom < 35 and self.currentTPPZoom < 35 then
			EVENT_MANAGER:UnregisterForUpdate("HarvensFPPZoomIn")
			return
		end
		SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_FIRST_PERSON_FIELD_OF_VIEW, self.currentFPPZoom)
		SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_FIELD_OF_VIEW, self.currentTPPZoom)
	end)
end

function HarvensFPPZoom:StopZooming()
	EVENT_MANAGER:UnregisterForUpdate("HarvensFPPZoomIn")
end

function HarvensFPPZoom:Initialize(eventType, addonName)
	self.defaultFPPZoom = 0
	self.defaultTPPZoom = 0
	self.currentFPPZoom = self.defaultFPPZoom
	self.currentTPPZoom = self.defaultTPPZoom
end

EVENT_MANAGER:RegisterForEvent( "HarvensFPPZoom", EVENT_ADD_ON_LOADED, function(...) HarvensFPPZoom:Initialize(...) end)

_G["HarvensFPPZoom"] = HarvensFPPZoom
