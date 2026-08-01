MapRadarHarvestPin = setmetatable(
    {}, {
        __index = MapRadarPinBase
     })
-- ========================================================================================
-- ctor
function MapRadarHarvestPin:New(key, x, y, pinTypeId, texturePath)
    local pin = MapRadarPinBase:New(key, x, y)
    setmetatable(
        pin, {
            __index = self
         })

    pin.pinTypeId = pinTypeId

    pin.texturePath = texturePath
    pin.texture:SetTexture(texturePath)

    local tint = Harvest.settings.defaultSettings.pinLayouts[pinTypeId].tint
    pin.texture:SetColor(tint.r, tint.g, tint.b, 1)

    -- pin:ApplyTexture()

    return pin
end

-- ========================================================================================
-- MapRadarHarvestPin handling methods

-- function MapRadarHarvestPin:UpdatePin(playerX, playerY, heading)
--     local dx = self.x - playerX
--     local dy = self.y - playerY

--     local coefficient, isCalibrated = getMeterCoefficient()

--     self.distance = math.sqrt(dx ^ 2 + dy ^ 2) / coefficient

--     -- Set visibility (hidden or transparency) and if not visible then stop processing further 
--     if not self:SetVisibility(isCalibrated) then
--         return
--     end

--     local radarDistance = math.min(MapRadar.maxRadarDistance, self.distance)

--     -- recalculate coordinates to apply rotation
--     local angle = math.atan2(-dx, -dy) - heading
--     dx = radarDistance * -math.sin(angle)
--     dy = radarDistance * -math.cos(angle)

--     -- Show distance (or other test data) near pin on radar
--     if self.label ~= nil then
--         local text = ""

--         if MapRadar.modeSettings.showDistance then
--             text = zo_strformat("<<1>>", self.distance)
--         end

--         self.label:SetText(text)
--     end

--     -- Resize pin 
--     self:SetPinDimensions()

--     -- Reposition pin
--     self.texture:ClearAnchors()
--     self.texture:SetAnchor(CENTER, MapRadar.playerPinTexture, CENTER, dx, dy)

--     CALLBACK_MANAGER:FireCallbacks("OnMapRadar_UpdatePin", self)
-- end
