local zoMapPin = ZO_MapPin
local pinManager = ZO_WorldMap_GetPinManager()

MapRadarPin = setmetatable(
    {}, {
        __index = MapRadarPinBase
     })

-- ========================================================================================
-- helper methods

local function customPinName(pinType)
    local customPin = pinManager.customPins[pinType]
    if (customPin ~= nil) then
        return customPin.pinTypeString
    end

    return nil
end

local function IsCustomPin(pinType)
    if MapRadar.modeSettings.showQuests and (customPinName(pinType) == "QuestMap_uncompleted" or customPinName(pinType) == "QuestMap_zonestory") -- Quest map
    or customPinName(pinType) == "pinType_Treasure_Maps" -- from "Map Pins" by Hoft
    or MapRadar.modeSettings.showMapPinsChests and customPinName(pinType) == "pinType_Treasure_Chests" -- from "Map Pins" by Hoft
    or customPinName(pinType) == "LostTreasure_SurveyReportPin" -- Survey from LostTreasure
    or customPinName(pinType) == "LostTreasure_TreasureMapPin" -- Treasure from LostTreasure
    or MapRadar.modeSettings.showSkyshards and (customPinName(pinType) == "pinType_Skyshards" -- Map Pins addon
    or customPinName(pinType) == "SkySMapPin_unknown" -- SkyShards addon
    ) then
        return true
    end

    return false
end

local function IsValidPOI(pin)
    local pinType = pin:GetPinType()
    local pinData = zoMapPin.PIN_DATA[pinType]
    local texturePath = MapRadar.value(pinData.texture, pin)

    if texturePath ~= nil then
        if texturePath:find("poi_wayshrine") and MapRadar.modeSettings.showWayshrines -- Wayshrine
        or texturePath:find("poi_dungeon") and MapRadar.modeSettings.showDungeons --
        or texturePath:find("poi_groupinstance") and MapRadar.modeSettings.showDungeons --
        or (texturePath:find("poi_delve") or texturePath:find("poi_groupdelve")) and MapRadar.modeSettings.showDelves --
        or texturePath:find("poi_portal") and MapRadar.modeSettings.showPortals -- dolmen but also other portals :/
        or texturePath:find("poi_groupboss") and MapRadar.modeSettings.showWorldBosses -- 
        or texturePath:find("LoreBooks") and MapRadar.modeSettings.showLoreBooks -- Show pins from LoreBooks addon
        then
            return true
        end
    end

    return false
end

local function IsValidForPointer(pin)
    local pinType = pin:GetPinType()
    if zoMapPin.ASSISTED_PIN_TYPES[pinType] then
        return true;
    end

    return false;
end

-- ========================================================================================
-- MapRadarPin handling methods
function MapRadarPin:SetPinDimensions()
    local pinType = self.pin:GetPinType()
    local pinData = zoMapPin.PIN_DATA[pinType]

    if (pinData ~= nil and pinData.size ~= nil) then
        self.size = pinData.size
    else
        self.size = MapRadar.pinSize
    end

    MapRadarPinBase.SetPinDimensions(self, self.size)
end

function MapRadarPin:ApplyTexture()
    local texture = "EsoUI/Art/MapPins/UI_Worldmap_pin_customDestination.dds" -- unknown pin

    -- Just in case check
    if self.animationTimeline then
        self.animationTimeline:Stop()
    end

    local pinData = zoMapPin.PIN_DATA[self.pin:GetPinType()]

    if (pinData ~= nil and pinData.texture ~= nil) then
        texture = MapRadar.value(pinData.texture, self.pin)

        if MapRadar.value(pinData.isAnimated, self.pin) then
            self.animation, self.animationTimeline = CreateSimpleAnimation(ANIMATION_TEXTURE, self.texture)
            self.animation:SetImageData(pinData.framesWide, pinData.framesHigh)
            self.animation:SetFramerate(pinData.framesPerSecond)

            -- returns texture to default state 
            self.animation:SetHandler(
                "OnStop", function()
                    self.texture:SetTextureCoords(0, 1, 0, 1)
                end)

            self.animationTimeline:SetPlaybackType(ANIMATION_PLAYBACK_LOOP, LOOP_INDEFINITELY)
            self.animationTimeline:PlayFromStart()
        end
    end

    self.texture:SetTexture(texture)
    self.texturePath = texture
end

function MapRadarPin:ApplyTint()
    local pinType = self.pin:GetPinType()
    local pinData = zoMapPin.PIN_DATA[pinType]

    if (pinData ~= nil and pinData.tint ~= nil) then
        self.texture:SetColor(MapRadar.value(pinData.tint, self.pin):UnpackRGBA())
        return
    end

    self.texture:SetColor(1, 1, 1, 1)
end

function MapRadarPin:CheckIntegrity()
    local pinType = self.pin:GetPinType()
    if pinType == nil then
        return false
    end

    -- If pin type changed then not valid
    if self.pinType ~= pinType then
        return false
    end

    local pinData = zoMapPin.PIN_DATA[self.pin:GetPinType()]
    if pinData == nil then
        return false
    end

    -- If there is no texture pin is not valid
    if pinData.texture == nil then
        return false
    end

    -- Check if texture changed
    local texture = MapRadar.value(pinData.texture, self.pin)
    if texture ~= self.texturePath then
        return false
    end

    return true
end

function MapRadarPin:UpdatePin(playerX, playerY, heading, hasPlayerMoved)
    local pinType = self.pin:GetPinType()

    if pinType == nil then
        -- Somehow pin gets corrupted (maybe because of pin reload on map change) and will be filtered out later
        return
    end

    local pinX = self.pin.normalizedX
    local pinY = self.pin.normalizedY

    -- TODO: perhaps move that to separate method with checking also texture, tint or something else?
    if not hasPlayerMoved and self.x == pinX and self.y == pinY then
        return -- If nothing changed then skip update. 
    end

    self.x = pinX
    self.y = pinY

    -- Set hasPlayerMoved to true so that base method update moving targets when you are not moving
    MapRadarPinBase.UpdatePin(self, playerX, playerY, heading, true)

    -- TODO: extract to separate method
    -- Show distance (or other test data) near pin on radar
    if self.label ~= nil then
        local text = ""

        if MapRadar.modeSettings.showDistance then
            text = zo_strformat("<<1>>", self.distance)
        end

        if MapRadar.showPinLoc then
            text = zo_strformat("<<1>>   <<2>>", ZO_LocalizeDecimalNumber(self.pin.normalizedX), ZO_LocalizeDecimalNumber(self.pin.normalizedY))
        end

        if MapRadar.showPinNames then
            local name = MR_PinTypeNames[pinType] or customPinName(pinType)
            text = zo_strformat("<<1>> <<2>>", pinType, name)
        end

        if MapRadar.showPinParams then
            local pinData = zoMapPin.PIN_DATA[pinType]
            if pinData ~= nil then
                local animatedStr = MapRadar.value(pinData.isAnimated, self.pin) and "[A]" or "[N]"
                local texturePath = MapRadar.value(pinData.texture, self.pin)
                -- later add more
                text = zo_strformat("<<1>> <<2>>", animatedStr, texturePath)
            end
        end

        self.label:SetText(text)
    end

end

function MapRadarPin:IsValidPin(pin)
    local pinType = pin:GetPinType()

    if pinType == nil then
        return false
    end

    if pinType == MAP_PIN_TYPE_PLAYER -- or pinType == MAP_PIN_TYPE_DRAGON_IDLE_HEALTHY or pinType == MAP_PIN_TYPE_DRAGON_IDLE_WEAK 
    or pin:IsCompanion() then
        return false
    end

    -- MAP_PIN_TYPW_SKYSHARD_SEEN

    -- zoneStoryQuest_icon_door
    -- quest_icon_door
    -- repeatableQuest_icon_door
    -- zoneStoryQuest_icon_door_assisted

    if (pin:IsQuest() or pinType == MAP_PIN_TYPE_TRACKED_QUEST_OFFER_ZONE_STORY) and MapRadar.modeSettings.showQuests -- or pin:IsObjective() -- or pin:IsAvAObjective()
    or pinType == MAP_PIN_TYPE_TRACKED_ANTIQUITY_DIG_SITE -- Antiquity
    or pinType == MAP_PIN_TYPE_PLAYER_WAYPOINT -- Player map waypoint
    or pin:IsUnit() and MapRadar.modeSettings.showGroup -- Player/Group/Companion units
    or pin:IsWorldEventPOIPin() -- Active Dolmens
    -- or pin:IsAssisted() -- or pin:IsMapPing()
    -- or pin:IsKillLocation()
    or pin:IsWorldEventUnitPin() -- Dragons and whatnot
    -- or pin:IsZoneStory() or pin:IsSuggestion() -- or pin:IsAreaPin()
    -- or pin:IsFastTravelWayShrine() -- Somehow some houses are in this category "MAP_PIN_TYPE_FAST_TRAVEL_WAYSHRINE" (Some addon shitting?)
    or IsCustomPin(pinType) -- Custom pins from other addons. Maybe valid POI method can handle it?
    or IsValidPOI(pin) -- Filters POIs by texture
    then
        return true
    end

    return MapRadar.showAllPins
end

-- ========================================================================================
-- ctor
function MapRadarPin:New(pin, key)

    local pinX = pin.normalizedX or 0
    local pinY = pin.normalizedY or 0
    local showPointer = IsValidForPointer(pin)

    local radarPin = MapRadarPinBase:New(key, pinX, pinY, showPointer)

    setmetatable(radarPin, self)
    self.__index = self

    radarPin.pin = pin
    radarPin.pinType = pin:GetPinType()

    radarPin.showAlways = pin:IsQuest() or pin:IsUnit() or pin:IsWorldEventPOIPin()

    radarPin:ApplyTexture()
    radarPin:ApplyTint()

    return radarPin
end
