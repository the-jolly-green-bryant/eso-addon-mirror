AUI.WorldMap = {}

local allowRefreshMinimap = true

local function AUI_WorldMap_GetCurrentMapIndex()
	return tonumber(GetMapType() .. GetMapContentType())
end

local function AUI_WorldMap_SetZoom(zoomMin, zoomMax)
	ZO_WorldMap_SetCustomZoomLevels(zoomMin, zoomMax)
	
	zo_callLater(function() ZO_WorldMap_ClearCustomZoomLevels() end, 50)
end

local function SetData(_self, _pinType, _pinTag)
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.WorldMap.SetData")
	end
	--/DebugMessage--

	local pinData = nil
	
	if _self:IsQuest() then
		local questType = GetJournalQuestType(_pinTag[1])
		local questRepeatType = GetJournalQuestRepeatType(_pinTag[1]) 				
		local AUI_pinType = AUI.Minimap.Pin.GetQuestPinType(_pinType, questType, questRepeatType)
		pinData = ZO_MapPin.PIN_DATA[AUI_pinType]
	elseif _self:IsGroup() then
		local AUI_pinType = nil
		
		if _self.m_PinTag and _self.m_PinTag.groupTag then
		   AUI_pinType = AUI.Minimap.Pin.GetGroupStatePinType(_self.m_PinTag.groupTag)	
		   pinData = ZO_MapPin.PIN_DATA[AUI_pinType]	
		elseif _self.m_PinTag then 
	       AUI_pinType = AUI.Minimap.Pin.GetGroupStatePinType(_self.m_PinTag)
		   pinData = ZO_MapPin.PIN_DATA[AUI_pinType]
		end
	elseif ZO_MapPin.PIN_DATA[pinType] and ZO_MapPin.PIN_DATA[_pinType] then
		local AUI_pinType = _pinType
		pinData = ZO_MapPin.PIN_DATA[AUI_pinType]
	end		
	
	if pinData then
		local pinControl = _self.m_Control
			
		local overlayControl = GetControl(pinControl, "Background")
		local highlightControl = GetControl(pinControl, "Highlight")
		local overlayTexture, pulseTexture, glowTexture = AUI.Minimap.Pin.GetPinTextureData(_self, pinData.texture)
		
		if overlayTexture ~= "" then	
			overlayControl:SetTexture(overlayTexture)
		end		

		if radius and radius > 0 then
			if not _self:IsKeepOrDistrict() then
				if not _self.pinBlob then
					local pinManager = AUI.Minimap.Pin.GetPinManager()
					_self.pinBlob, _self.pinBlobKey = pinManager.pinBlobManager:AcquireObject()
					_self.pinBlob:SetHidden(false)
				end
			end		
		
			local singlePinData = ZO_MapPin.PIN_DATA[_self.m_PinType]
			pinControl:GetNamedChild("Background"):SetHidden(not singlePinData.showsPinAndArea)
		else
			pinControl:GetNamedChild("Background"):SetHidden(false)
		end	
					
		if pinData.tint then
			local tint = AUI.Minimap.Pin.GetPinTextureColor(_self, pinData.tint)
			if tint then
				overlayControl:SetColor(tint:UnpackRGBA())
				
				if _self.pinBlob then
					_self.pinBlob:SetColor(tint:UnpackRGBA())
				end				
			end
		else
			overlayControl:SetColor(1, 1, 1, 1)
			
			if _self.pinBlob then
				_self.pinBlob:SetColor(1, 1, 1, 1)
			end					
		end	

		if pinData.grayscale then
			local grayscale = pinData.grayscale		
			overlayControl:SetDesaturation((type(grayscale) == "function" and grayscale(_self) or grayscale) and 1 or 0)
		else
			overlayControl:SetDesaturation(0)
		end				
					 
		if pulseTexture then
			_self:ResetAnimation(RESET_ANIM_ALLOW_PLAY, LONG_LOOP_COUNT, pulseTexture, overlayTexture, AUI_Pin.DoFinalFadeInAfterPing)
		elseif glowTexture then
			highlightControl:SetHidden(false)
			highlightControl:SetAlpha(1)				
			highlightControl:SetTexture(glowTexture)
			highlightControl:ClearAnchors()
			highlightControl:SetAnchor(TOPLEFT, control, TOPLEFT, -5, -5)
			highlightControl:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT, 5, 5)					
		else
			highlightControl:SetHidden(true)
		end
		
		local pinLevel = pinData.level
		
		if type(pinLevel) == "function" then
			pinLevel = pinLevel(self)
		end

		overlayControl:SetDrawLevel(pinLevel)
		highlightControl:SetDrawLevel(pinLevel - 1)		
	end
end

local function SetLocation(_self, _xLoc, _yLoc, _radius)
	if _self.pinBlob and _self:IsQuest() then
		local questType = GetJournalQuestType(_self.m_PinTag[1])
		local questRepeatType = GetJournalQuestRepeatType(_self.m_PinTag[1]) 				
		local AUI_pinType = AUI.Minimap.Pin.GetQuestPinType(_self.m_PinType, questType, questRepeatType)
		local pinData = ZO_MapPin.PIN_DATA[AUI_pinType]
			
		if pinData.tint then
			local tint = AUI.Minimap.Pin.GetPinTextureColor(_self, pinData.tint)
			if tint then
				_self.pinBlob:SetColor(tint:UnpackRGBA())
			end
		end			
	end
end

function AUI.WorldMap.Init()
	AUI.PostHook(ZO_MapPin, "SetData", SetData)
	AUI.PostHook(ZO_MapPin, "SetLocation", SetLocation)
	
     CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", function(wasNavigateIn)
		if AUI.Minimap.IsLoaded() then
			local keepFastTravelInteraction = GetKeepFastTravelInteraction() 
			if allowRefreshMinimap and keepFastTravelInteraction ~= nil then
				allowRefreshMinimap = false
			else
				allowRefreshMinimap = true
			end	
		
			if wasNavigateIn == nil then
				if allowRefreshMinimap then
					AUI.Minimap.Map.Refresh()
				end
				AUI.Minimap.Pin.UpdateCustomPins()
			end
		end
    end)
		
	WORLD_MAP_SCENE:RegisterCallback("StateChange", 
	function(oldState, newState)
		if AUI.Minimap.IsLoaded() then
			if newState == SCENE_SHOWING then	
				if AUI.Settings.Minimap.worldmap_zoom_out then
					zo_callLater(function()
						AUI_WorldMap_SetZoom(1, 1)								
					end, 10)
				end			
			end
		end													
	end)
	
	GAMEPAD_WORLD_MAP_SCENE:RegisterCallback("StateChange", 
	function(oldState, newState)
		if AUI.Minimap.IsLoaded() then
			if newState == SCENE_SHOWING then	
				if AUI.Settings.Minimap.worldmap_zoom_out then
					zo_callLater(function()
						AUI_WorldMap_SetZoom(1, 1)								
					end, 10)
				end					
			end
		end													
	end)
end