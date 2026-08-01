local MIN_PIN_SIZE = 18
local MIN_PIN_SCALE = 0.6
local MAX_PIN_SCALE = 1
local DEFAULT_PIN_SIZE = 18
local LONG_LOOP_COUNT = 24
local pinId = 0
local cyrodilMapIndex = GetCyrodiilMapIndex()
local imperialCityMapIndex = GetImperialCityMapIndex()

AUI_Pin = ZO_MapPin:Subclass()

function AUI_Pin:New()
    local pin = ZO_Object.New(self)

    local control = CreateControlFromVirtual("AUI_MapPin", AUI_MapContainer, "AUI_MapPin", pinId)
    control.m_Pin = pin
	pin.m_Control = control
	
    ZO_AlphaAnimation:New(GetControl(control, "Highlight"))
    pin:ResetAnimation(RESET_ANIM_HIDE_CONTROL)
	
	pin.__index = ZO_MapPin
	
    pinId = pinId + 1
    return pin
end

function AUI_Pin:GetPinAnchor()
	local point = CENTER
	local relToControl = AUI_MapContainer
	local rpoint = TOPLEFT
	
	local offsetX = self.normalizedX * AUI.MapData.mapContainerSize
	local offsetY = self.normalizedY * AUI.MapData.mapContainerSize	
	
	if AUI.Settings.Minimap.rotate then
		point = CENTER
		relToControl = AUI_Minimap_Map_Scroll
		rpoint = CENTER		
	
		local x = (offsetX - (AUI.MapData.mapContainerSize * AUI.MapData.playerX))
		local y = (offsetY - (AUI.MapData.mapContainerSize * AUI.MapData.playerY))
			
		offsetX = (math.cos(-AUI.MapData.heading) * x) - (math.sin(-AUI.MapData.heading) * y)
		offsetY = (math.sin(-AUI.MapData.heading) * x) + (math.cos(-AUI.MapData.heading) * y)			
	end
	
	return point, relToControl, rpoint, offsetX, offsetY
end

function AUI_Pin:UpdateLocation()
    local pinControl = self:GetControl()
    if self.normalizedX and self.normalizedY then
		local point, relToControl, rpoint, offsetX, offsetY = self:GetPinAnchor()
		
        pinControl:ClearAnchors()
		pinControl:SetAnchor(point, relToControl, rpoint, offsetX, offsetY)	

        if self.pinBlob then
            self.pinBlob:ClearAnchors()
			self.pinBlob:SetAnchor(point, relToControl, rpoint, offsetX, offsetY)
        end
    end
end

function AUI_Pin:SetLocation(xLoc, yLoc)
	local valid = (xLoc and yLoc)
	
    local control = self:GetControl()
    control:SetHidden(not valid)

    self.normalizedX = xLoc
    self.normalizedY = yLoc

	self:UpdateLocation()
	self:UpdateSize()
end

function AUI_Pin:SetData(pinType, pinTag, radius)
	self.m_PinType = pinType
	self.m_PinTag = pinTag
	self.radius = radius
	
	local control = self.m_Control
		
	local pinData = ZO_MapPin.PIN_DATA[pinType]
	if pinData then
		local overlayControl = GetControl(control, "Background")
		local highlightControl = GetControl(control, "Highlight")
		local overlayTexture, pulseTexture, glowTexture = AUI.Minimap.Pin.GetPinTextureData(self, pinData.texture)
		
		if overlayTexture ~= "" then	
			overlayControl:SetTexture(overlayTexture)
		end		

		if radius and radius > 0 then
			if not self:IsKeepOrDistrict() then
				if not self.pinBlob then
					local pinManager = AUI.Minimap.Pin.GetPinManager()
					self.pinBlob, self.pinBlobKey = pinManager.pinBlobManager:AcquireObject()
					self.pinBlob:SetHidden(false)
				end
			end		
		
			local singlePinData = ZO_MapPin.PIN_DATA[self.m_PinType]
			control:GetNamedChild("Background"):SetHidden(not singlePinData.showsPinAndArea)
		else
			control:GetNamedChild("Background"):SetHidden(false)
		end				
				
		if pinData.tint then
			local tint = AUI.Minimap.Pin.GetPinTextureColor(self, pinData.tint)
			if tint and tint.UnpackRGBA then
				overlayControl:SetColor(tint:UnpackRGBA())
				
				if self.pinBlob then
					self.pinBlob:SetColor(tint:UnpackRGBA())
				end
			else
				overlayControl:SetColor(1, 1, 1, 1)
				
				if self.pinBlob then
					self.pinBlob:SetColor(1, 1, 1, 1)
				end				
			end		
		else
			overlayControl:SetColor(1, 1, 1, 1)
			
			if self.pinBlob then
				self.pinBlob:SetColor(1, 1, 1, 1)
			end				
		end				
		
		if pinData.grayscale then
			local grayscale = pinData.grayscale		
			overlayControl:SetDesaturation((type(grayscale) == "function" and grayscale(self) or grayscale) and 1 or 0)
		else
			overlayControl:SetDesaturation(0)
		end				
		 
		if pulseTexture then
			self:ResetAnimation(RESET_ANIM_ALLOW_PLAY, LONG_LOOP_COUNT, pulseTexture, overlayTexture, AUI_Pin.DoFinalFadeInAfterPing)
		elseif glowTexture then
			self:ResetAnimation(RESET_ANIM_HIDE_CONTROL)
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

		if pinData.isAnimated then
			self:PlayTextureAnimation(LOOP_INDEFINITELY)
		end			
	end	
end

function AUI_Pin:UpdateAreaPinTexture()
    local pinDiameter = self.radius * 2 * AUI.MapData.mapContainerSize
    local lastPinBlobTexture = self.pinBlobTexture
	
    if pinDiameter > 48 then
        if self:IsAssisted() then
            self.pinBlobTexture = "EsoUI/Art/MapPins/map_assistedAreaPin.dds"
        else
            self.pinBlobTexture = "EsoUI/Art/MapPins/map_areaPin.dds"
        end
    else
        if self:IsAssisted() then
            self.pinBlobTexture = "EsoUI/Art/MapPins/map_assistedAreaPin_32.dds"
        else
            self.pinBlobTexture = "EsoUI/Art/MapPins/map_areaPin_32.dds"
        end
    end

    if self.pinBlobTexture and lastPinBlobTexture ~= self.pinBlobTexture then
        self.pinBlob:SetTexture(self.pinBlobTexture)
    end
end

function AUI_Pin:UpdateSize()
	local singlePinData = ZO_MapPin.PIN_DATA[self.m_PinType]
	if singlePinData ~= nil then
		local control = self.m_Control
		local hasNonZeroRadius = self.radius and self.radius > 0
		local baseSize = singlePinData.size or DEFAULT_PIN_SIZE

		if hasNonZeroRadius then
			local pinDiameter = self.radius * 2 * AUI.MapData.mapContainerSize

			if singlePinData.minAreaSize and pinDiameter < singlePinData.minAreaSize then
				pinDiameter = singlePinData.minAreaSize
			end

			self:UpdateAreaPinTexture()

			if self.pinBlob then
				self.pinBlob:SetDimensions(pinDiameter, pinDiameter)
				control:SetDimensions(pinDiameter, pinDiameter)
				control:SetHitInsets(0, 0, 0, 0)
			else
				control:SetDimensions(pinDiameter, pinDiameter)
				local highlightControl = control:GetNamedChild("Highlight")
				highlightControl:ClearAnchors()
				highlightControl:SetAnchorFill(control)
			end
		end

		if not hasNonZeroRadius or singlePinData.showsPinAndArea then
			local minSize = singlePinData.minSize or MIN_PIN_SIZE
			local scale = zo_clamp(AUI.Minimap.GetCurrentZoomValue(), MIN_PIN_SCALE, MAX_PIN_SCALE)
			local size = zo_max((baseSize * scale) / GetUIGlobalScale(), minSize)

			if self.m_PinType == MAP_PIN_TYPE_PLAYER then
				size = size * AUI.Settings.Minimap.player_pin_size
			elseif self:IsGroupLeader() then	
				size = size * AUI.Settings.Minimap.groupLeader_pin_size
			elseif self:IsGroup() then	
				size = size * AUI.Settings.Minimap.group_pin_size					
			else
				size = size * AUI.Settings.Minimap.pin_size
			end
			
			control:SetDimensions(size, size)

			local insetX = singlePinData.insetX or 0
			local insetY = singlePinData.insetY or 0
			insetX = insetX * (size / baseSize)
			insetY = insetY * (size / baseSize)

			control:SetHitInsets(insetX, insetY, -insetX, -insetY)
		end
	end
end

function AUI_Pin:GetQuestIcon()
	if self.m_PinTag and self.m_PinTag.isBreadcrumb then
		return AUI_MINIMAP_BREADCRUMB_QUEST_PIN_TEXTURES[self:GetPinType()]
	else	
		return AUI_MINIMAP_QUEST_PIN_TEXTURES[self:GetPinType()]
	end
end

local groupPinTextures =
{
	[MAP_PIN_TYPE_GROUP_LEADER] 	= "EsoUI/Art/Compass/groupLeader.dds",
	[MAP_PIN_TYPE_GROUP]       		= "EsoUI/Art/MapPins/UI-WorldMapGroupPip.dds",
}

local breadcrumbGroupPinTextures =
{
	[MAP_PIN_TYPE_GROUP_LEADER]  	= "EsoUI/Art/Compass/groupLeader_door.dds",
	[MAP_PIN_TYPE_GROUP]         	= "EsoUI/Art/Compass/groupMember_door.dds",
}

function AUI_Pin:GetGroupIcon()
	if self.m_PinTag and self.m_PinTag.isBreadcrumb then
		return breadcrumbGroupPinTextures[self:GetPinType()]
	else
		return groupPinTextures[self:GetPinType()]
	end
end

function AUI_Pin:IsGroup()
    return ZO_MapPin.GROUP_PIN_TYPES[self.m_PinType]
end

function AUI_Pin:IsGroupLeader()
    return ZO_MapPin.GROUP_LEADER_PIN_TYPES[self.m_PinType]
end