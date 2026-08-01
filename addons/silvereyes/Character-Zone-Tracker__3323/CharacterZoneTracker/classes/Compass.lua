--[[ 
    ===================================
          World Map Integration
    ===================================
  ]]
  
local addon = CharacterZoneTracker
local debug = false

-- Singleton class
local Compass = ZO_Object:Subclass()

function Compass:New()
    return ZO_Object.New(self)
end

function Compass:Initialize()
    
    self.esoui = {}
    
    self.esouiNames = {
        GetCenterOveredPinInfo = "GetCenterOveredPinInfo",
        GetCenterOveredPinType = "GetCenterOveredPinType",
    }
    
    for handlerName, methodName in pairs(self.esouiNames) do
        local method = COMPASS.container[methodName]
        if method then
            self.esoui[methodName] = method
            COMPASS.container[methodName] = self:Closure(handlerName)
        end
    end
end




---------------------------------------
--
--          Public Methods
-- 
---------------------------------------

--[[  ]]
function Compass:Closure(functionName)
    return function(...)
        return self[functionName](self, ...)
    end
end

--[[  ]]
function Compass:GetCenterOveredPinInfo(control, centerOveredPinIndex)
    local description, pinType, distanceFromPlayerCM, drawLayer, drawLevel, suppressed = self.esoui.GetCenterOveredPinInfo(control, centerOveredPinIndex)
    
    local zoneId, completionZoneId, zoneIndex, completionZoneIndex = addon.Utility.GetZoneIdsAndIndexes(GetCurrentMapZoneIndex())
    if completionZoneIndex == 0 then
        return description, pinType, distanceFromPlayerCM, drawLayer, drawLevel, suppressed
    end
    
    local objective, completionType = addon.ZoneGuideTracker:GetObjectiveByName(completionZoneIndex, nil, description)
    if objective then
        local complete = addon.Data:IsActivityComplete(GetZoneId(objective.poiZoneIndex), completionType, objective.activityIndex)
        pinType = complete and MAP_PIN_TYPE_POI_COMPLETE or MAP_PIN_TYPE_POI_SEEN
    end
    return description, pinType, distanceFromPlayerCM, drawLayer, drawLevel, suppressed
end

--[[  ]]
function Compass:GetCenterOveredPinType(control, centerOveredPinIndex)
    return select(2, self:GetCenterOveredPinInfo(control, centerOveredPinIndex))
end


---------------------------------------
--
--          Private Methods
-- 
---------------------------------------



-- Create singleton
addon.Compass = Compass:New()