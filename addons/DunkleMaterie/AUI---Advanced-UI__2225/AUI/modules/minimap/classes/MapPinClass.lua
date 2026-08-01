local currentQuestTasks = {}

RESET_ANIM_ALLOW_PLAY         = 1
RESET_ANIM_PREVENT_PLAY       = 2
RESET_ANIM_HIDE_CONTROL       = 3

AUI_MapPin = ZO_WorldMapPins:Subclass()

function AUI_MapPin:IsNormalizedPointInsideMapBounds(x, y)
    return (x > 0 and x < 1 and y > 0 and y < 1)
end

function AUI_MapPin:New()
	local pinBlobManager = AUI_PinBlobManager:New(AUI_MapContainer)

    local factory = function(pool) return AUI_Pin:New() end
    local reset =   function(pin)
                        pin:ClearData()

                        local pinControl = pin:GetControl()
                        pinControl:SetHidden(true)

                        pin:ResetAnimation(RESET_ANIM_HIDE_CONTROL)
                        pin:ResetScale()
						
                        if pin.pinBlobKey then
                            pinBlobManager:ReleaseObject(pin.pinBlobKey)
                            pin.pinBlobKey = nil
                            pin.pinBlob = nil
                        end						
                    end

    local mapPins = ZO_ObjectPool.New(self, factory, reset)

    mapPins.m_keyToPinMapping =
    {
        ["poi"] = {},
        ["loc"] = {},
        ["quest"] = {}, 
        ["objective"] = {},
        ["keep"] = {},
        ["pings"] = {},
        ["killLocation"] = {},
		["fastTravelKeep"] = {},
        ["fastTravelWayshrine"] = {},
        ["forwardCamp"] = {},
		["AvARespawn"] = {},
        ["group"] = {},
        ["restrictedLink"] = {},
    }

	mapPins.pinBlobManager = pinBlobManager
	mapPins.keepNetworkManager = AUI_KeepNetwork:New(AUI_MapContainer)	
	mapPins.customPins = {}
	
	mapPins.__index = ZO_WorldMapPins
	
    return mapPins
end

function AUI_MapPin:GetCurrentQuestTasks()
	return currentQuestTasks
end

function AUI_MapPin:AddTask(taskId, data)
    if taskId then
        currentQuestTasks[taskId] = data
    end
end

function AUI_MapPin:ClearPendingTasksForQuest(questIndex)
    for key, data in pairs(currentQuestTasks) do
        if(data[1] == questIndex) then
            currentQuestTasks[key] = nil
        end
    end
end

function AUI_MapPin:ClearPendingTasks()
    currentQuestTasks = {}
end

function AUI_MapPin:CreatePin(pinType, pinTag, xLoc, yLoc, radius)
    local pin, pinKey = self:AcquireObject()
	
	pin:SetData(pinType, pinTag, radius)
	pin:SetLocation(xLoc, yLoc)	
	
	local valid = false	
	
	if pin.ValidateAVAPinAllowed then
		valid = pin:ValidateAVAPinAllowed()
	elseif pin.ValidatePvPPinAllowed then
		valid = pin:ValidatePvPPinAllowed()
	end

	if valid then
		if(pin:IsPOI()) then
			self:MapPinLookupToPinKey("poi", pin:GetPOIZoneIndex(), pin:GetPOIIndex(), pinKey)
		elseif(pin:IsLocation()) then
			self:MapPinLookupToPinKey("loc", pin:GetLocationIndex(), pin:GetLocationIndex(), pinKey)
		elseif(pin:IsQuest()) then
			self:MapPinLookupToPinKey("quest", pin:GetQuestIndex(), pinTag, pinKey)
		elseif(pin:IsObjective()) then
			self:MapPinLookupToPinKey("objective", pin:GetObjectiveKeepId(), pinTag, pinKey)
		elseif(pin:IsKeepOrDistrict())  then
			self:MapPinLookupToPinKey("keep", pin:GetKeepId(), pin:IsUnderAttackPin(), pinKey)
		elseif(pin:IsMapPing())  then
			self:MapPinLookupToPinKey("pings", pinType, pinTag, pinKey)
		elseif(pin:IsKillLocation())  then
			self:MapPinLookupToPinKey("killLocation", pinType, pinTag, pinKey)
		elseif(pin:IsFastTravelKeep()) then
			self:MapPinLookupToPinKey("fastTravelKeep", pin:GetFastTravelKeepId(), pin:GetFastTravelKeepId(), pinKey)
		elseif(pin:IsFastTravelWayShrine()) then
			self:MapPinLookupToPinKey("fastTravelWayshrine", pinType, pinTag, pinKey)
		elseif(pin:IsForwardCamp()) then
			self:MapPinLookupToPinKey("forwardCamp", pinType, pinTag, pinKey)
		elseif(pin:IsAvARespawn()) then
			self:MapPinLookupToPinKey("AvARespawn", pinType, pinTag, pinKey)
		elseif(pin:IsGroup()) then
			self:MapPinLookupToPinKey("group", pinType, pinTag, pinKey)
		elseif(pin:IsRestrictedLink()) then
			self:MapPinLookupToPinKey("restrictedLink", pinType, pinTag, pinKey)
		else
			local customPinData = self.customPins[pinType]
			if customPinData then			
				valid = self:MapPinLookupToPinKey(customPinData.pinTypeString, pinType, pinTag, pinKey)
			end	
		end	
	end

	if not valid then
		self:ReleaseObject(pinKey)
	end

    return pin, pinKey
end

function AUI_MapPin:FindPin(lookupType, majorIndex, keyIndex)
    local lookupTable = self.m_keyToPinMapping[lookupType]
    local keys = lookupTable[majorIndex]
    if keys ~= nil then
        local pinKey = keys[keyIndex]
        if pinKey then
            return self:GetExistingObject(pinKey)
        end
    end
end

function AUI_MapPin:MapPinLookupToPinKey(lookupType, majorIndex, keyIndex, pinKey)
	if lookupType == nil or majorIndex == nil or keyIndex == nil or pinKey == nil then	
		return false
	end

    local lookupTable = self.m_keyToPinMapping[lookupType]

    if not lookupTable[majorIndex] then
        lookupTable[majorIndex] = {}
        lookupTable[majorIndex] = lookupTable[majorIndex]
    end

    lookupTable[majorIndex][keyIndex] = pinKey
	
	return true
end

function AUI_MapPin:RemovePins(lookupType, majorIndex, keyIndex)
    local lookupTable = self.m_keyToPinMapping[lookupType]

    if lookupTable and majorIndex then
        local keys = lookupTable[majorIndex]
        if keys then
            if keyIndex then
                local pinKey = keys[keyIndex]
                if pinKey then
                    self:ReleaseObject(pinKey)
                    keys[keyIndex] = nil
                end
            else
                for _, pinKey in pairs(keys) do
                    self:ReleaseObject(pinKey)
                end

                self.m_keyToPinMapping[lookupType][majorIndex] = {}
            end
        end
    elseif lookupTable then
        for _, keys in pairs(lookupTable) do
            for _, pinKey in pairs(keys) do
                self:ReleaseObject(pinKey)
            end
        end

        self.m_keyToPinMapping[lookupType] = {}
    end
end
