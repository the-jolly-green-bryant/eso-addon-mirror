local isInit = false
local pinManager = nil
local playerPin
local imperialCityMapIndex = GetImperialCityMapIndex()
local ObjectiveContinuous = {}

local mapsWithoutQuestPins =
{
    [MAPTYPE_WORLD] = true,
    [MAPTYPE_COSMIC] = true,
}

local function AUI_MapPin_AddQuestTask(questIndex)
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI_MapPin_AddQuestTask")
	end
	--/DebugMessage--	

    if(ZO_WorldMap_IsPinGroupShown(MAP_FILTER_QUESTS)) then
        local assisted = GetTrackedIsAssisted(TRACK_TYPE_QUEST, questIndex)

        if(GetJournalQuestIsComplete(questIndex)) then
            local taskId = RequestJournalQuestConditionAssistance(questIndex, QUEST_MAIN_STEP_INDEX, 1, false)
            local tag = AUI_Pin.CreateQuestPinTag(questIndex, QUEST_MAIN_STEP_INDEX, 1)
            pinManager:AddTask(taskId, tag)
        else
            for stepIndex = QUEST_MAIN_STEP_INDEX, GetJournalQuestNumSteps(questIndex) do
                for conditionIndex = 1, GetJournalQuestNumConditions(questIndex, stepIndex) do
                    local _, _, isFailCondition, isComplete = GetJournalQuestConditionValues(questIndex, stepIndex, conditionIndex)
                    if(not (isFailCondition or isComplete)) then
                        local taskId = RequestJournalQuestConditionAssistance(questIndex, stepIndex, conditionIndex, assisted)
                        local tag = AUI_Pin.CreateQuestPinTag(questIndex, stepIndex, conditionIndex)
                        pinManager:AddTask(taskId, tag)
                    end
                end
            end
        end
    end
end	

local function AUI_MapPin_RefreshSingleQuestPin(questIndex)
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI_MapPin_RefreshSingleQuestPin")
	end
	--/DebugMessage--	

    pinManager:RemovePins("quest", questIndex)
    pinManager:ClearPendingTasksForQuest(questIndex)
    AUI_MapPin_AddQuestTask(questIndex)
end

local function AUI_MapPin_RefreshQuestPins()
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI_MapPin_RefreshQuestPins")
	end
	--/DebugMessage--	

    pinManager:RemovePins("quest")
	pinManager:ClearPendingTasks()
	
    if mapsWithoutQuestPins[GetMapType()] ~= nil then 
		return 
	end

	for i = 1, MAX_JOURNAL_QUESTS do
		local questIndex = i
		AUI_MapPin_AddQuestTask(questIndex)
	end
end

local function AUI_MapPin_AddQuestPin(taskId, pinType, xLoc, yLoc, areaRadius, insideCurrentMapWorld, isBreadcrumb)	
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI_MapPin_AddQuestPin")
	end
	--/DebugMessage--	

	if taskId and pinType then
		local currentQuestTasks = pinManager:GetCurrentQuestTasks()
		local pinTag = currentQuestTasks[taskId]
		if pinTag and insideCurrentMapWorld and pinManager:IsNormalizedPointInsideMapBounds(xLoc, yLoc) then	
			local questIndex = pinTag[1]
			if questIndex then	
				pinTag.isBreadcrumb = isBreadcrumb
				local questType = GetJournalQuestType(questIndex)
				local questRepeatType = GetJournalQuestRepeatType(questIndex)	

				local questPinType = AUI.Minimap.Pin.GetQuestPinType(pinType, questType, questRepeatType)

				pinManager:CreatePin(questPinType, pinTag, xLoc, yLoc, areaRadius)
			end	
			currentQuestTasks[taskId] = nil
		end
	end
end

local function AUI_MapPin_RefreshObjectives()
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI_MapPin_RefreshObjectives")
	end
	--/DebugMessage--	

    pinManager:RemovePins("objective")
    ZO_ClearNumericallyIndexedTable(ObjectiveContinuous)

    local mapFilterType = GetMapFilterType()
    if mapFilterType ~= MAP_FILTER_TYPE_AVA_CYRODIIL and mapFilterType ~= MAP_FILTER_TYPE_BATTLEGROUND then
        return
    end
    local numObjectives = GetNumObjectives()

    local worldMapAvAPinsShown = ZO_WorldMap_IsPinGroupShown(MAP_FILTER_AVA_OBJECTIVES)

    for i = 1, numObjectives do
        local keepId, objectiveId, bgContext = GetObjectiveIdsForIndex(i)
        if ZO_WorldMap_IsObjectiveShown(keepId, objectiveId, bgContext) and IsLocalBattlegroundContext(bgContext) then
            --spawn locations
            local spawnPinType, spawnX, spawnY = GetObjectiveSpawnPinInfo(keepId, objectiveId, bgContext)
            if spawnPinType ~= MAP_PIN_TYPE_INVALID then
                if worldMapAvAPinsShown then
                    if pinManager:IsNormalizedPointInsideMapBounds(spawnX, spawnY) then
                        local spawnTag = AUI_Pin.CreateObjectivePinTag(keepId, objectiveId, bgContext)
                        pinManager:CreatePin(spawnPinType, spawnTag, spawnX, spawnY)
                    end
                end
            end

            --return locations
            local returnPinType, returnX, returnY, returnContinuousUpdate = GetObjectiveReturnPinInfo(keepId, objectiveId, bgContext)
            if returnPinType ~= MAP_PIN_TYPE_INVALID then
                local returnTag = AUI_Pin.CreateObjectivePinTag(keepId, objectiveId, bgContext)
                local returnPin = pinManager:CreatePin(returnPinType, returnTag, returnX, returnY)

                if returnContinuousUpdate then
                    table.insert(ObjectiveContinuous, returnPin)
                end
            end

            -- current locations
            local pinType, currentX, currentY, continuousUpdate = GetObjectivePinInfo(keepId, objectiveId, bgContext)
            if pinType ~= MAP_PIN_TYPE_INVALID then
                if worldMapAvAPinsShown then
                    if pinManager:IsNormalizedPointInsideMapBounds(currentX, currentY) then
                        local objectiveTag = AUI_Pin.CreateObjectivePinTag(keepId, objectiveId, bgContext)
                        local objectivePin = pinManager:CreatePin(pinType, objectiveTag, currentX, currentY)

                        if objectivePin then
                            local auraPinType = GetObjectiveAuraPinInfo(keepId, objectiveId, bgContext)
                            local auraPin
                            if auraPinType ~= MAP_PIN_TYPE_INVALID then
                                local auraTag = AUI_Pin.CreateObjectivePinTag(keepId, objectiveId, bgContext)
                                auraPin = pinManager:CreatePin(auraPinType, auraTag, currentX, currentY)
                                objectivePin:AddScaleChild(auraPin)
                            end

                            if continuousUpdate then
                                table.insert(ObjectiveContinuous, objectivePin)
                                if auraPin then
                                    table.insert(ObjectiveContinuous, auraPin)
                                end
                            end						
                        end
                    end
                end
            end
        end
    end
end

local function AUI_MapPin_RefreshKillLocations()
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI_MapPin_RefreshKillLocations")
	end
	--/DebugMessage--	

    pinManager:RemovePins("killLocation")
    RemoveMapPinsInRange(MAP_PIN_TYPE_TRI_BATTLE_SMALL, MAP_PIN_TYPE_EBONHEART_VS_DAGGERFALL_LARGE)

	if(ZO_WorldMap_IsPinGroupShown(MAP_FILTER_KILL_LOCATIONS)) then	
		for i = 1, GetNumKillLocations() do
			local pinType, normalizedX, normalizedY = GetKillLocationPinInfo(i)
			if(pinType ~= MAP_PIN_TYPE_INVALID) then
				if(pinManager:IsNormalizedPointInsideMapBounds(normalizedX, normalizedY)) then
					pinManager:CreatePin(pinType, i, normalizedX, normalizedY)
				end
			end
		end
	end
end

local function AUI_MapPin_RefreshForwardCamps()
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI_MapPin_RefreshForwardCamps")
	end
	--/DebugMessage--	

    pinManager:RemovePins("forwardCamp")

    if(GetMapContentType() ~= MAP_CONTENT_AVA) then
        return
    end
	
	if(not ZO_WorldMap_IsPinGroupShown(MAP_FILTER_AVA_GRAVEYARDS)) then return end

    for i = 1, GetNumForwardCamps(BGQUERY_LOCAL) do
        local pinType, normalizedX, normalizedY, normalizedRadius = GetForwardCampPinInfo(BGQUERY_LOCAL, i)
        if(pinManager:IsNormalizedPointInsideMapBounds(normalizedX, normalizedY)) then
            if(not ZO_WorldMap_IsPinGroupShown(MAP_FILTER_AVA_GRAVEYARD_AREAS)) then
                normalizedRadius = 0
            end		
		
            pinManager:CreatePin(pinType, AUI_Pin.CreateForwardCampPinTag(i), normalizedX, normalizedY, normalizedRadius)
        end
    end
end

local function AUI_MapPin_RefreshWayshrines()
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI_MapPin_RefreshWayshrines")
	end
	--/DebugMessage--	

	pinManager:RemovePins("fastTravelWayshrine")

	if not ZO_WorldMap_IsPinGroupShown(MAP_FILTER_WAYSHRINES) then return end

	for nodeIndex = 1, GetNumFastTravelNodes() do
		local known, name, normalizedX, normalizedY, icon, glowIcon, poiType, isLocatedInCurrentMap, linkedCollectibleIsLocked = GetFastTravelNodeInfo(nodeIndex)	

		if known and isLocatedInCurrentMap and pinManager:IsNormalizedPointInsideMapBounds(normalizedX, normalizedY) then		
			local tag = AUI_Pin.CreateTravelNetworkPinTag(nodeIndex, icon, glowIcon, linkedCollectibleIsLocked)

			local pinType = MAP_PIN_TYPE_FAST_TRAVEL_WAYSHRINE

			pinManager:CreatePin(pinType, tag, normalizedX, normalizedY)
		end
	end
end

local function AUI_MapPin_RefreshImperialCity()
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI_MapPin_RefreshImperialCity")
	end
	--/DebugMessage--

    pinManager:RemovePins("imperialCity")
	
	if GetMapFilterType() == MAP_FILTER_TYPE_AVA_CYRODIIL and ZO_WorldMap_IsPinGroupShown(MAP_FILTER_IMPERIAL_CITY_ENTRANCES) then
        local hasAccess = DoesAllianceHaveImperialCityAccess(GetCurrentCampaignId(), GetUnitAlliance("player"))
        local icPinType = hasAccess and MAP_PIN_TYPE_IMPERIAL_CITY_OPEN or MAP_PIN_TYPE_IMPERIAL_CITY_CLOSED
        local collectibleId = GetImperialCityCollectibleId()
        local linkedCollectibleIsLocked = not IsCollectibleUnlocked(collectibleId)
        for _, coords in ipairs(AUI_IC_PIN_POSITIONS) do
            local tag = AUI_Pin.CreateImperialCityPinTag(BGQUERY_LOCAL, linkedCollectibleIsLocked)
			pinManager:CreatePin(icPinType, tag, coords[1], coords[2])
        end
    end
end

local function AddKeep(keepId)
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AddKeep")
	end
	--/DebugMessage--

    local historyPercent = 1.0
    local pinType, locX, locY = GetHistoricalKeepPinInfo(keepId, BGQUERY_LOCAL, historyPercent)
    if pinType ~= MAP_PIN_TYPE_INVALID then
        local keepUnderAttack = GetHistoricalKeepUnderAttack(keepId, BGQUERY_LOCAL, historyPercent)
		local keepUnderAttackPinType = ZO_WorldMap_GetUnderAttackPinForKeepPin(pinType)
        if pinManager:IsNormalizedPointInsideMapBounds(locX, locY) then
            local keepType = GetKeepType(keepId)
            if ZO_WorldMap_IsPinGroupShown(MAP_FILTER_RESOURCE_KEEPS or keepType ~= KEEPTYPE_RESOURCE) then
				if keepType == KEEPTYPE_IMPERIAL_CITY_DISTRICT and GetCurrentMapIndex() ~= imperialCityMapIndex then
					return
				end				
			
				local underAttackPin = true
				local notUnderAttackPin = false
				local existingKeepPin = pinManager:FindPin("keep", keepId, notUnderAttackPin)
					
				if not existingKeepPin then
					local tag = AUI_Pin.CreateKeepPinTag(keepId, BGQUERY_LOCAL, notUnderAttackPin)
					pinManager:CreatePin(pinType, tag, locX, locY)

					if keepUnderAttack then
						tag = AUI_Pin.CreateKeepPinTag(keepId, BGQUERY_LOCAL, underAttackPin)
						pinManager:CreatePin(keepUnderAttackPinType, tag, locX, locY)
					end
				end 
            end
        end
    end
end

local function AUI_MapPin_RefreshKeeps(keepId)
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI_MapPin_RefreshKeeps")
	end
	--/DebugMessage--

    pinManager:RemovePins("keep", keepId)

	if GetMapContentType() == MAP_CONTENT_AVA then
		if keepId then
			AddKeep(keepId)
		else	
			local numKeeps = GetNumKeeps()
			for i = 1, numKeeps do
				local keepId, bgContext = GetKeepKeysByIndex(i)
				if IsLocalBattlegroundContext(bgContext) then
					AddKeep(keepId)
				end
			end
		end
	end
end

local function CreateSinglePOIPin(zoneIndex, poiIndex)
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("CreateSinglePOIPin")
	end
	--/DebugMessage--

    local xLoc, zLoc, iconType, icon, isShownInCurrentMap = GetPOIMapInfo(zoneIndex, poiIndex)

	if isShownInCurrentMap then
		if not ZO_MapPin.PIN_DATA[iconType] and AUI.Settings.Minimap.previewUnknownPins then
			iconType = AUI_MINIMAP_PIN_TYPE_POI_UNKNOWN
			icon = ZO_MapPin.PIN_DATA[iconType].texture
		end	
	
		if ZO_MapPin.PIN_DATA[iconType] then
			local tag = AUI_Pin.CreatePOIPinTag(zoneIndex, poiIndex, icon)
			pinManager:CreatePin(iconType, tag, xLoc, zLoc)
		end
	end
end

local function RefreshSinglePOI(zoneIndex, poiIndex)
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("RefreshSinglePOI")
	end
	--/DebugMessage--

    pinManager:RemovePins("poi", zoneIndex, poiIndex)

    if(ZO_WorldMap_IsPinGroupShown(MAP_FILTER_OBJECTIVES)) then
        CreateSinglePOIPin(zoneIndex, poiIndex)
    end
end

local function AUI_MapPin_RefreshAllPOIs()
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI_MapPin_RefreshAllPOIs")
	end
	--/DebugMessage--

    pinManager:RemovePins("poi")
	
	if(ZO_WorldMap_IsPinGroupShown(MAP_FILTER_OBJECTIVES)) then
		local zoneIndex = GetCurrentMapZoneIndex()
		for i = 1, GetNumPOIs(zoneIndex) do
			CreateSinglePOIPin(zoneIndex, i)
		end
	end
end

local function AUI_MapPin_IsGroupPinAllowed(_unitTag)
	return _unitTag and AUI.Unit.IsGroupUnitTag(_unitTag) and IsUnitGrouped(_unitTag) and IsUnitOnline(_unitTag) and DoesUnitExist(_unitTag) and not AreUnitsEqual("player", _unitTag)
end

local function AUI_MapPin_AddGroupPin(_unitTag)	
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI_MapPin_AddGroupPin")
	end
	--/DebugMessage--

	local pinType = AUI.Minimap.Pin.GetGroupStatePinType(_unitTag)	
	local x, y = GetMapPlayerPosition(_unitTag)	
	local pin, _ = pinManager:CreatePin(pinType, _unitTag, x, y)
	local tagData = _unitTag
	
	if IsUnitWorldMapPositionBreadcrumbed(_unitTag) then
		tagData = 
		{
			groupTag = groupTag,
			isBreadcrumb = true
		}
	end	
	
	pin:SetData(pinType, tagData)
	pin:SetLocation(x, y)		
end

local function AUI_MapPin_RefreshGroupPins()
	pinManager:RemovePins("group")

    if ZO_WorldMap_IsPinGroupShown(MAP_FILTER_GROUP_MEMBERS) then
		local groupSize = GetGroupSize()
		
		for i = 1, groupSize do
			local unitTag = GetGroupUnitTagByIndex(i)
			if AUI_MapPin_IsGroupPinAllowed(unitTag) then
				AUI_MapPin_AddGroupPin(unitTag)			
			end
		end
    end
end

local function AUI_MapPin_RefreshLocations()
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI_MapPin_RefreshLocations")
	end
	--/DebugMessage--

    pinManager:RemovePins("loc")

    for i = 1, GetNumMapLocations() do
		if(IsMapLocationVisible(i)) then    
			local icon, x, y = GetMapLocationIcon(i)
    
			if(icon ~= "" and pinManager:IsNormalizedPointInsideMapBounds(x, y)) then
				local tag = AUI_Pin.CreateLocationPinTag(i, icon)
				pinManager:CreatePin(MAP_PIN_TYPE_LOCATION, tag, x, y)
			end
		end
    end
end

local EVENT_HANDLERS =
{
	[EVENT_POI_UPDATED] = function(eventCode, zoneIndex, poiIndex)
		RefreshSinglePOI(zoneIndex, poiIndex)
		AUI_MapPin_RefreshLocations()
	end,
	[EVENT_COLLECTIBLE_UPDATED] = function(eventCode, collectibleId)
		AUI_MapPin_RefreshAllPOIs()
		AUI_MapPin_RefreshWayshrines()
		if collectibleId == GetImperialCityCollectibleId() and cyrodiilMapIndex == GetCurrentMapIndex() then
			AUI_MapPin_RefreshImperialCity()
		end		
	end,			
	[EVENT_OBJECTIVES_UPDATED] = AUI_MapPin_RefreshObjectives,
	[EVENT_OBJECTIVE_CONTROL_STATE] = AUI_MapPin_RefreshObjectives,
	[EVENT_KILL_LOCATIONS_UPDATED] = AUI_MapPin_RefreshKillLocations,
	[EVENT_FAST_TRAVEL_NETWORK_UPDATED] = AUI_MapPin_RefreshWayshrines,
	[EVENT_FAST_TRAVEL_KEEP_NETWORK_UPDATED] = function() if pinManager.keepNetworkManager then pinManager.keepNetworkManager:RefreshLinks() end end,
}

function AUI.Minimap.Pin.GetPinManager()
	return pinManager
end

function AUI.Minimap.Pin.Init()
	if isInit == false then	
		playerPin = pinManager:CreatePin(MAP_PIN_TYPE_PLAYER, "player")	
	
		AUI.Minimap.Pin.SetPinData()	

		for event, handler in pairs(EVENT_HANDLERS) do
			EVENT_MANAGER:RegisterForEvent("AUI_MapPin", event, handler)
		end

		isInit = true
	end
end

function AUI.Minimap.Pin.GetPinTextureData(self, textureData)
	if not AUI.Minimap.IsLoaded() then
		return
	end

	if(textureData ~= nil) then
		if(type(textureData) == "string") then
			return textureData
		elseif(type(textureData) == "function") then
			return textureData(self)
		end
	end
	
	return
end

function AUI.Minimap.Pin.GetPinTextureColor(self, textureColor)
	if type(textureColor) == "function" then
		return textureColor(self)
	end
	
	return textureColor
end

function AUI.Minimap.Pin.RefreshPlayer()
	if not AUI.Minimap.IsLoaded() then
		return
	end

	playerPin:SetData(MAP_PIN_TYPE_PLAYER, "player")
	playerPin:UpdateSize()
end

function AUI.Minimap.Pin.RefreshPins()
	if not AUI.Minimap.IsLoaded() then
		return
	end
	
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Minimap.Pin.RefreshPins")
	end
	--/DebugMessage--	
	
	AUI.Minimap.Pin.RefreshPlayer()
	AUI_MapPin_RefreshAllPOIs()
	AUI_MapPin_RefreshKillLocations()
	AUI_MapPin_RefreshWayshrines()
	AUI_MapPin_RefreshQuestPins()		
	AUI_MapPin_RefreshLocations()
	AUI_MapPin_RefreshGroupPins()
	AUI_MapPin_RefreshForwardCamps()
	AUI_MapPin_RefreshObjectives()
	AUI_MapPin_RefreshKeeps()
	AUI_MapPin_RefreshImperialCity()
	pinManager.keepNetworkManager:RefreshLinks()
end

function AUI.Minimap.Pin.RemovePins()
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Minimap.Pin.RemovePins")
	end
	--/DebugMessage--	

	pinManager:RemovePins("poi")
	pinManager:RemovePins("loc")
	pinManager:RemovePins("quest")
	pinManager:RemovePins("ava")
	pinManager:RemovePins("keep")
	pinManager:RemovePins("imperialCity")
	pinManager:RemovePins("killLocation")
	pinManager:RemovePins("fastTravelWayshrine")
	pinManager:RemovePins("forwardCamp")
	pinManager:RemovePins("group")
	pinManager:RemovePins("restrictedLink")
	pinManager:RemovePins("custom")
end

function AUI.Minimap.Pin.UpdatePinLocations()
	if not AUI.Minimap.IsLoaded() then
		return
	end

	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Minimap.Pin.UpdatePinLocations")
	end
	--/DebugMessage--		
	
	for lookupType, lookupTable in pairs(pinManager.m_keyToPinMapping) do
		for majorIndex, keys in pairs(lookupTable) do
			for keyIndex, pinKey in pairs(keys) do
				local pin = pinManager:GetExistingObject(pinKey) 
				if pin then
					pin:UpdateLocation()
				end
			end
		end
	end	
end

function AUI.Minimap.Pin.UpdatePins()
	if not AUI.Minimap.IsLoaded() then
		return
	end

	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Minimap.Pin.UpdatePins")
	end
	--/DebugMessage--		
	
	for lookupType, lookupTable in pairs(pinManager.m_keyToPinMapping) do
		for majorIndex, keys in pairs(lookupTable) do
			for keyIndex, pinKey in pairs(keys) do
				local pin = pinManager:GetExistingObject(pinKey) 		
				if pin then
					pin:UpdateLocation()
					pin:UpdateSize()
				end
			end
		end
	end	

	AUI_MapPin_RefreshKeeps()
	pinManager.keepNetworkManager:RefreshLinks()
end

function AUI.Minimap.Pin.UpdateCustomPins()
	if not AUI.Minimap.IsLoaded() then
		return
	end
	
	for lookupType, lookupTable in pairs(pinManager.m_keyToPinMapping) do
		for majorIndex, keys in pairs(lookupTable) do
			if pinManager.customPins[majorIndex] then
				for keyIndex, pinKey in pairs(keys) do
					local pin = pinManager:GetExistingObject(pinKey) 		
					if pin then
						pin:UpdateLocation()
						pin:UpdateSize()
					end
				end
			end
		end
	end			
end

function AUI.Minimap.Pin.GetPlayerPin()
	if not AUI.Minimap.IsLoaded() then
		return nil
	end

    return playerPin
end

function AUI.Minimap.Pin.UpdateMovingPins()
	if not AUI.Minimap.IsLoaded() or not pinManager then
		return
	end

	AUI_MapPin_RefreshGroupPins()
	
	for i = 1, #ObjectiveContinuous do
		local pinKey = ObjectiveContinuous[i]
		local pin = pinManager:GetExistingObject(pinKey)
		if pin then
			local pinType, currentX, currentY = GetAvAObjectivePinInfo(pin:GetAvAObjectiveKeepId(), pin:GetAvAObjectiveObjectiveId(), pin:GetBattlegroundContext())
			pin:SetLocation(currentX, currentY)
		end
	end	
end

pinManager = AUI_MapPin:New()

function AUI.Minimap.Pin.RefreshGroupPins()
	if not AUI.Minimap.IsLoaded() then
		return
	end

	AUI_MapPin_RefreshGroupPins()
end

function AUI.Minimap.Pin.RefreshQuestPins()
	if not AUI.Minimap.IsLoaded() then
		return
	end

	AUI_MapPin_RefreshQuestPins()
end

function AUI.Minimap.Pin.RefreshSingleQuestPin(journalIndex)
	if not AUI.Minimap.IsLoaded() then
		return
	end

	AUI_MapPin_RefreshSingleQuestPin(journalIndex)
end

function AUI.Minimap.Pin.AddQuestPin(taskId, pinType, xLoc, yLoc, areaRadius, insideCurrentMapWorld, isBreadcrumb)
	if not AUI.Minimap.IsLoaded() then
		return
	end
	
	AUI_MapPin_AddQuestPin(taskId, pinType, xLoc, yLoc, areaRadius, insideCurrentMapWorld, isBreadcrumb)	
end

function AUI.Minimap.Pin.RefreshKeep(keepId, bgContext)
	if not AUI.Minimap.IsLoaded() or not IsLocalBattlegroundContext(bgContext) then
		return
	end	
	
	AUI_MapPin_RefreshKeeps(keepId)
end

--removed functions ----------------------------------------------------------------------------------------------------------------------------------
function AUI.Minimap.Pin.AddCustomPinType() end
function AUI.Minimap.Pin.CreateCustomPin() end
function AUI.Minimap.Pin.RefreshCustomPinsByType() end
function AUI.Minimap.Pin.RemoveCustomPinsByType() end
function AUI.Minimap.Pin.RemoveCustomPins() end
------------------------------------------------------------------------------------------------------------------------------------------------------

local function IsPinAllowed(self, pinType)
	if ZO_MapPin.MAP_PING_PIN_TYPES[pinType] or self.customPins[pinType] and self:IsCustomPinEnabled(pinType) then
		return true
	end
	
	return false
end

local function ZO_WM_AddCustomPin(self, pinType, pinTypeAddCallback, pinTypeOnResizeCallback, pinLayoutData, pinTooltipCreator)
	local pinTypeId = _G[pinType]
	
	if pinTypeId then
		pinManager.m_keyToPinMapping[pinType] = {}
		pinManager.customPins[pinTypeId] = self.customPins[pinTypeId]
	end
end

local function ZO_WM_CreatePin(self, pinType, pinTag, locX, locY, areaRadius)
	if AUI.Minimap.IsLoaded() then
		if IsPinAllowed(self, pinType) then
			pinManager:CreatePin(pinType, pinTag, locX, locY, areaRadius)	
		end
	end
end

local function ZO_WM_RemovePins(self, lookupType, majorIndex, keyIndex)
	if AUI.Minimap.IsLoaded() then
		local pinTypeId = _G[lookupType]
		if self.customPins[pinTypeId] or lookupType == "pings" then
			pinManager:RemovePins(lookupType, pinTypeId, keyIndex)
		end
	end
end

AUI.PostHook(ZO_WorldMapPins, "AddCustomPin", ZO_WM_AddCustomPin)
AUI.PreHook(ZO_WorldMapPins, "CreatePin", ZO_WM_CreatePin)
AUI.PostHook(ZO_WorldMapPins, "RemovePins", ZO_WM_RemovePins)
