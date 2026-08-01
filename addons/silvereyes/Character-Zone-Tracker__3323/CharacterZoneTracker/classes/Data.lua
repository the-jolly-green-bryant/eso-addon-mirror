local addon = CharacterZoneTracker
local debug = false
local COMPLETION_TYPES = addon:GetCompletionTypes()
local save, trueCount, containsAnyUntrue

local Data = ZO_Object:Subclass()

function Data:New(...)
    return ZO_Object.New(self)
end

function Data:Initialize()
    
    self.initialized = true
    self.save = LibSavedVars:NewCharacterSettings(addon.name .. "Data", {})
                            :RemoveSettings(2, "backedUpV2", "backedUp")
                            :EnableDefaultsTrimming()
    self.esoui = {}
    
    self.esouiNames = {
        AreAllActivitiesComplete = "AreAllZoneStoryActivitiesCompleteForZoneCompletionType",
        CanActivitiesContinue = "CanZoneStoryContinueTrackingActivitiesForCompletionType",
        GetNumAssociatedAchievements = "GetNumAssociatedAchievementsForZoneCompletionType",
        GetNumCompletedActivities = "GetNumCompletedZoneActivitiesForZoneCompletionType",
        IsActivityComplete = "IsZoneStoryActivityComplete",
        GetAssociatedAchievementId = "GetAssociatedAchievementIdForZoneCompletionType",
        GetPOIMapInfo = "GetPOIMapInfo",
        GetPOIPinIcon = "GetPOIPinIcon",
    }
    
    for handlerName, methodName in pairs(self.esouiNames) do
        local method = _G[methodName]
        if method then
            self.esoui[methodName] = method
            _G[methodName] = self:Closure(handlerName)
        end
    end
end



---------------------------------------
--
--          Public Methods
-- 
---------------------------------------

--[[  ]]
function Data:Closure(functionName)
    return function(...)
        return self[functionName](self, ...)
    end
end

--[[  ]]
function Data:GetAssociatedAchievementId(completionZoneId, completionType, associatedAchievementIndex)
    return 0
end

--[[  ]]
function Data:AreAllActivitiesComplete(completionZoneId, completionType)
    if addon:IsCompletionTypeTracked(completionType) then
        return not containsAnyUntrue(self, completionZoneId, completionType)
    end
    return self.esoui.AreAllZoneStoryActivitiesCompleteForZoneCompletionType(completionZoneId, completionType)
end

--[[  ]]
function Data:CanActivitiesContinue(completionZoneId, completionType)
    if addon:IsCompletionTypeTracked(completionType) then
        return containsAnyUntrue(self, completionZoneId, completionType)
    end
    return self.esoui.CanZoneStoryContinueTrackingActivitiesForCompletionType(completionZoneId, completionType)
end

--[[  ]]
function Data:ClearMultiBossDelveBossKills(completionZoneId, completionType, activityIndex)
  
    if not self.save.delveBossKills then
        return
    end
    local completionZoneIndex = GetZoneIndex(completionZoneId)
    if completionZoneIndex == 0 then
        addon.Utility.Debug("Invalid completion zone id " .. tostring(completionZoneId) 
            .. ". Cannot clear multi boss delve boss kills.", debug)
        return
    end
    local objective = addon.ZoneGuideTracker:GetObjective(completionZoneIndex, completionType, activityIndex)
    if not objective then
        addon.Utility.Debug("No objective found for zone index " .. tostring(completionZoneIndex) 
            .. ", completionType: " .. tostring(completionType) .. ", activityIndex: " .. tostring(activityIndex) 
            .. ". Cannot clear multi boss delve boss kills.", debug)
        return
    end
    local delveZoneId = addon.SubzoneMap:FindBestSubzoneNameMatch(completionZoneId, objective.name)
    if not delveZoneId then
        addon.Utility.Debug("No subzone for completion zone id " .. tostring(completionZoneId) 
            .. " matches the activity name '" .. tostring(objective.name) 
            .. "'. Cannot clear multi boss delve boss kills.", debug)
        return
    end
    
    if not self.save.delveBossKills[delveZoneId] then
        addon.Utility.Debug("No boss kills to clear for zone id " .. tostring(delveZoneId) 
            .. ". Cannot clear multi boss delve boss kills.", debug)
        return
    end
    ZO_ClearTable(self.save.delveBossKills[delveZoneId])
    self.save.delveBossKills[delveZoneId] = nil
end

function Data:GetIsMultiBossDelveBossKilled(zoneId, bossIndex)
    return self.save.delveBossKills
           and self.save.delveBossKills[zoneId]
           and self.save.delveBossKills[zoneId][bossIndex]
           or false
end

--[[  ]]
function Data:GetNumAssociatedAchievements(completionZoneId, completionType)
    return 0
end

--[[  ]]
function Data:GetNumCompletedActivities(completionZoneId, completionType)
    if addon:IsCompletionTypeTracked(completionType) then
        return trueCount(self, completionZoneId, completionType)
    end
    return self.esoui.GetNumCompletedZoneActivitiesForZoneCompletionType(completionZoneId, completionType)
end

function Data:GetPOIMapInfo(zoneIndex, poiIndex)
  
    local xLoc, zLoc, poiPinType, icon, isShownInCurrentMap, linkedCollectibleIsLocked, isDiscovered, isNearby = self.esoui.GetPOIMapInfo(zoneIndex, poiIndex)
    
    local zoneId = GetZoneId(zoneIndex)
    if zoneId == 0 then
        return xLoc, zLoc, poiPinType, icon, isShownInCurrentMap, linkedCollectibleIsLocked, isDiscovered, isNearby
    end
    
    local completionZoneId = GetZoneStoryZoneIdForZoneId(zoneId)
    if completionZoneId == 0 then
        return xLoc, zLoc, poiPinType, icon, isShownInCurrentMap, linkedCollectibleIsLocked, isDiscovered, isNearby
    end
    
    local completionZoneIndex = GetZoneIndex(completionZoneId)
    if completionZoneIndex == 0 then
        return xLoc, zLoc, poiPinType, icon, isShownInCurrentMap, linkedCollectibleIsLocked, isDiscovered, isNearby
    end
  
    addon.ZoneGuideTracker:InitializeZone(completionZoneId)
    local poiObjective, completionType = addon.ZoneGuideTracker:GetPOIObjective(completionZoneIndex, nil, zoneIndex, poiIndex)
    
    if poiObjective and addon:IsCompletionTypeTracked(completionType) then
        local priorIcon = icon
        if self:IsActivityComplete(completionZoneId, completionType, poiObjective.activityIndex) then
            poiPinType = MAP_PIN_TYPE_POI_COMPLETE
            icon = icon:gsub("_incomplete", "_complete")
        else
            poiPinType = MAP_PIN_TYPE_POI_SEEN
            icon = icon:gsub("_complete", "_incomplete")
        end
    end
    return xLoc, zLoc, poiPinType, icon, isShownInCurrentMap, linkedCollectibleIsLocked, isDiscovered, isNearby 
end

function Data:GetPOIMapInfoOnAccount(zoneIndex, poiIndex)
    return self.esoui.GetPOIMapInfo(zoneIndex, poiIndex)
end

--[[  ]]
function Data:GetPOIPinIcon(poiId, checkNearby)
    local zoneIndex, poiIndex = GetPOIIndices(poiId)
    local _, _, poiPinType, icon = self:GetPOIMapInfo(zoneIndex, poiIndex)
    return icon, poiPinType
end

--[[  ]]
function Data:IsActivityComplete(completionZoneId, completionType, activityIndex)
    --addon.Utility.Debug("IsActivityComplete(completionZoneId: " .. tostring(completionZoneId) .. ", completionType: " .. tostring(completionType) .. ", activityIndex: " .. tostring(activityIndex) .. ")", debug)
    if addon:IsCompletionTypeTracked(completionType) then
        --addon.Utility.Debug("Returning " .. tostring(self.save[completionZoneId] and self.save[completionZoneId][completionType] and self.save[completionZoneId][completionType][activityIndex]), debug)
        return self.save[completionZoneId] and self.save[completionZoneId][completionType] and self.save[completionZoneId][completionType][activityIndex] or false
    end
    return self.esoui.IsZoneStoryActivityComplete(completionZoneId, completionType, activityIndex)
end

--[[  ]]
function Data:IsActivityCompletedOnAccount(completionZoneId, completionType, activityIndex)
    return self.esoui.IsZoneStoryActivityComplete(completionZoneId, completionType, activityIndex)
end

--[[  ]]
function Data:LoadBaseGameCompletion(completionZoneId, completionType, activityIndex)
    local baseGameActivityComplete = self.esoui.IsZoneStoryActivityComplete(completionZoneId, completionType, activityIndex)
    local changed = save(self, completionZoneId, completionType, activityIndex, baseGameActivityComplete)
    return changed, baseGameActivityComplete
end

function Data:LoadBaseGameCompletionForZone(completionZoneId)
    for completionType, _ in pairs(COMPLETION_TYPES) do
        for activityIndex = 1, GetNumZoneActivitiesForZoneCompletionType(completionZoneId, completionType) do
            -- Set the activity completion to be the same as account-wide
            local changed = addon.Data:LoadBaseGameCompletion(completionZoneId, completionType, activityIndex)
            -- If the completion changed, whether we are resetting or completing the activity, we don't need incomplete boss kill tracking information anymore
            if changed then
                self:ClearMultiBossDelveBossKills(completionZoneId, completionType, activityIndex)
            end
        end
    end
end

--[[  ]]
function Data:SetActivityComplete(completionZoneId, completionType, activityIndex, complete)
    addon.Utility.Debug("SetActivityComplete(completionZoneId: " .. tostring(completionZoneId) .. ", completionType: " .. tostring(completionType) .. ", activityIndex: " .. tostring(activityIndex) .. ", complete: " .. tostring(complete) .. ")", debug)
    if not addon:IsCompletionTypeTracked(completionType) then
        return
    end
    -- Set the activity completion
    local changed = save(self, completionZoneId, completionType, activityIndex, complete)
    -- If the completion changed, whether we are resetting or completing the activity, we don't need incomplete boss kill tracking information anymore
    if changed then
        self:ClearMultiBossDelveBossKills(completionZoneId, completionType, activityIndex)
    end
    return changed
end

function Data:SetMultiBossDelveBossKilled(zoneId, bossIndex)
    if not self.save.delveBossKills then
        self.save.delveBossKills = {}
    end
    if not self.save.delveBossKills[zoneId] then
        self.save.delveBossKills[zoneId] = {}
    end
    self.save.delveBossKills[zoneId][bossIndex] = true
end

---------------------------------------
--
--          Private Members
-- 
---------------------------------------

function containsAnyUntrue(self, completionZoneId, completionType)
    if self.save[completionZoneId] and self.save[completionZoneId][completionType] then
        for activityIndex = 1, GetNumZoneActivitiesForZoneCompletionType(completionZoneId, completionType) do
            if not self.save[completionZoneId] or not self.save[completionZoneId][completionType] or not self.save[completionZoneId][completionType][activityIndex] then
                return true
            end
        end
    end
    return false
end

function save(self, completionZoneId, completionType, activityIndex, complete)
    if not self.save[completionZoneId] then
        if complete then
            self.save[completionZoneId] = {}
        else
            return false
        end
    end
    if not self.save[completionZoneId][completionType] then
        if complete then
            self.save[completionZoneId][completionType] = {}
        else
            return false
        end
    end
    local success = (self.save[completionZoneId][completionType][activityIndex] == true and not complete)
                    or (not self.save[completionZoneId][completionType][activityIndex] and complete)
    self.save[completionZoneId][completionType][activityIndex] = complete or nil
    return success
end

function trueCount(self, completionZoneId, completionType)
    local count = 0
    for activityIndex = 1, GetNumZoneActivitiesForZoneCompletionType(completionZoneId, completionType) do
        if self.save[completionZoneId] and self.save[completionZoneId][completionType] and self.save[completionZoneId][completionType][activityIndex] then
            count = count + 1
        end
    end
    return count
end

-- Create singleton
addon.Data = Data:New()
