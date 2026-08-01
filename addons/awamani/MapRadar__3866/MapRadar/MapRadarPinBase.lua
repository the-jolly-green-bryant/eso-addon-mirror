local getCurrentMapId = GetCurrentMapId
local zoneData = MapRadarZoneData
local getMapType = GetMapType

MapRadarPinBase = {}

-- ========================================================================================
-- helper methods

local function getMeterCoefficient()

    local mapId = getCurrentMapId()

    local worldCalibratedData = MapRadar.accountData.worldScaleData[mapId]
    if worldCalibratedData ~= nil then
        return worldCalibratedData, true
    end

    local zData = zoneData[mapId]
    if zData ~= nil then
        -- MapRadar.debugDebounce("Get zone unit1: <<1>>", MapRadar.getStrVal(zData))
        return zData, true
    end

    if getMapType() == MAPTYPE_SUBZONE then
        -- Default sub-zone coefficient
        return 0.00145, false
    end

    if getMapType() == MAPTYPE_ZONE then
        -- Default main zone coefficient
        return 0.0003, false
    end

    -- Default for any other smaller map (very imprecise as they usually are between 0.001 and 0.009)
    return 0.005, false
end

-- ========================================================================================
-- MapRadarPinBase handling methods
function MapRadarPinBase:SetHidden(flag)
    self.texture:SetHidden(flag)
    if self.label ~= nil then
        self.label:SetHidden(flag)
    end
    if self.pointer ~= nil then
        self.pointer:SetHidden(flag)
    end
end

function MapRadarPinBase:SetVisibility(isCalibrated)
    -- Most pin types they should be visible only in certain range
    if not self.showAlways and self.distance > MapRadar.modeSettings.maxDistance then
        -- d(zo_strformat("Pin is not visible: <<1>>  <<2>> > <<3>>", self.key, self.distance, MapRadar.modeSettings.maxDistance))
        self:SetHidden(true)
        return false
    end

    self:SetHidden(false)

    local minAlpha = MapRadar.modeSettings.minAlpha / 100
    local maxAlpha = MapRadar.modeSettings.maxAlpha / 100

    local alpha = maxAlpha
    if self.distance > MapRadar.maxRadarDistance then
        alpha = math.max(minAlpha, maxAlpha - (self.distance - MapRadar.maxRadarDistance) / MapRadar.maxRadarDistance)
    end

    self.texture:SetAlpha(alpha)

    if self.pointer ~= nil then
        self.pointer:SetAlpha(alpha)
    end

    if self.label ~= nil then
        self.label:SetColor(1, 1, isCalibrated and 1 or 0, alpha)
    end
    return true
end

function MapRadarPinBase:SetPinDimensions(pinSize)
    -- MapRadar.pinSize changes on switching between modes, so need to reassign it while other different approach is found.
    -- Maybe this is not needed at all if every mode apply own scaling?
    self.size = pinSize or MapRadar.pinSize
    local minScale = MapRadar.modeSettings.minScale / 100
    local maxScale = MapRadar.modeSettings.maxScale / 100

    local distanceScale = math.max(minScale, maxScale - self.distance / MapRadar.maxRadarDistance / 2)

    self.scaledSize = self.size * distanceScale
    self.texture:SetDimensions(self.scaledSize, self.scaledSize)
end

function MapRadarPinBase:ApplyTexture()
    local texture = "EsoUI/Art/MapPins/UI_Worldmap_pin_customDestination.dds" -- unknown pin

    -- Just in case check
    if self.animationTimeline then
        self.animationTimeline:Stop()
    end

    self.texture:SetTexture(texture)
    self.texturePath = texture
end

function MapRadarPinBase:ApplyTint()
    self.texture:SetColor(1, 1, 1, 1)
end

function MapRadarPinBase:UpdatePin(playerX, playerY, heading, hasPlayerMoved)

    if not hasPlayerMoved then
        return -- If nothing changed then skip update. 
    end

    local dx = self.x - playerX
    local dy = self.y - playerY

    local coefficient, isCalibrated = getMeterCoefficient()

    self.distance = math.sqrt(dx ^ 2 + dy ^ 2) / coefficient

    -- Set visibility (hidden or transparency) and if not visible then stop processing further 
    if not self:SetVisibility(isCalibrated) then
        return
    end

    local radarDistance = math.min(MapRadar.maxRadarDistance, self.distance)

    -- recalculate coordinates to apply rotation
    local angle = math.atan2(-dx, -dy) - heading
    dx = radarDistance * -math.sin(angle)
    dy = radarDistance * -math.cos(angle)

    -- Resize pin 
    self:SetPinDimensions()

    -- Reposition pin
    self.texture:ClearAnchors()
    self.texture:SetAnchor(CENTER, MapRadar.playerPinTexture, CENTER, dx, dy)

    -- Pointer points only for quests (not affected by range)
    if self.pointer ~= nil then
        self.pointer:SetHidden(not MapRadar.modeSettings.showPointers)

        if MapRadar.modeSettings.showPointers then
            self.pointer:SetTextureRotation(angle, 0.5, 1)
            if radarDistance < 64 then
                self.pointer:SetDimensions(8, radarDistance)
            end
        end
    end

    -- Show distance near pin
    if self.label ~= nil and MapRadar.modeSettings.showDistance then
        self.label:SetText(zo_strformat("<<1>>", self.distance))
    end

    CALLBACK_MANAGER:FireCallbacks("OnMapRadar_UpdatePin", self)
end

-- ========================================================================================
-- ctor
function MapRadarPinBase:New(key, x, y, showPointer)
    local radarPin = {}
    setmetatable(radarPin, self)
    self.__index = self

    local texture, textureKey = MapRadar.pinPool:AcquireObject()

    radarPin.texture = texture
    radarPin.textureKey = textureKey

    radarPin.key = key

    radarPin.x = x
    radarPin.y = y

    radarPin:ApplyTexture()
    radarPin:ApplyTint()

    local label, labelKey = MapRadar.pinLabelPool:AcquireObject()
    label:SetAnchor(BOTTOMLEFT, radarPin.texture, BOTTOMRIGHT)
    radarPin.label = label
    radarPin.labelKey = labelKey

    if showPointer then
        local pointerTexture, pointerKey = MapRadar.pointerPool:AcquireObject()
        pointerTexture:SetTexture("MapRadar/textures/pointer.dds")
        pointerTexture:SetAnchor(BOTTOM, MapRadar.playerPinTexture, CENTER)
        pointerTexture:SetAlpha(0.5)
        pointerTexture:SetDimensions(8, 64)
        pointerTexture:SetHidden(true)
        radarPin.pointer = pointerTexture
        radarPin.pointerKey = pointerKey
    end

    CALLBACK_MANAGER:FireCallbacks("OnMapRadar_NewPin", radarPin)

    return radarPin
end

-- ========================================================================================
-- deconstruct
function MapRadarPinBase:Dispose()

    CALLBACK_MANAGER:FireCallbacks("OnMapRadar_RemovePin", self)

    if self.animationTimeline then
        self.animationTimeline:Stop()
        self.animationTimeline = nil
        self.animation = nil
    end

    self.texture:ClearAnchors()
    MapRadar.pinPool:ReleaseObject(self.textureKey)
    self.textureKey = nil
    self.texture = nil

    if self.pointer ~= nil then
        self.pointer:ClearAnchors()
        MapRadar.pointerPool:ReleaseObject(self.pointerKey)
        self.pointerKey = nil
        self.pointer = nil
    end

    if self.label ~= nil then
        self.label:SetText("")
        MapRadar.pinLabelPool:ReleaseObject(self.labelKey)
        self.labelKey = nil
        self.label = nil
    end

    self.pin = nil
    self.distance = nil
    self.size = nil
    self.scaledSize = nil
end
