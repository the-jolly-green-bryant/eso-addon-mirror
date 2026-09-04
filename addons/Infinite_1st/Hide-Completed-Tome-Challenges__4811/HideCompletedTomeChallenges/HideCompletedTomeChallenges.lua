local ADDON_NAME = "HideCompletedTomeChallenges"

local function GetActivityData(entryData)
    if not entryData then
        return nil
    end
    if type(entryData.GetDataSource) == "function" then
        return entryData:GetDataSource()
    end
    return entryData.data
end

local function IsEntryCompleted(entryData)
    local activityData = GetActivityData(entryData)
    if not activityData then
        return false
    end
    if type(activityData.GetNumTimesClaimed) ~= "function" or type(activityData.GetTotalNumTimesClaimable) ~= "function" then
        return false
    end
    local numTimesClaimed = activityData:GetNumTimesClaimed()
    local totalNumTimesClaimable = activityData:GetTotalNumTimesClaimable()
    if not (totalNumTimesClaimable and totalNumTimesClaimable > 0) then
        return false
    end
    return numTimesClaimed and numTimesClaimed >= totalNumTimesClaimable
end

local function FilterActivityEntries(activityEntries)
    local filtered = {}
    for _, entryData in ipairs(activityEntries) do
        if not IsEntryCompleted(entryData) then
            table.insert(filtered, entryData)
        end
    end
    return filtered
end

local function HookRefreshList()
    if not ZO_TimedActivities_Shared or not ZO_TimedActivities_Shared.RefreshList then
        return false
    end

    local originalRefreshList = ZO_TimedActivities_Shared.RefreshList

    ZO_TimedActivities_Shared.RefreshList = function(self, ...)
        local currentActivityType, activityEntries = originalRefreshList(self, ...)
        if activityEntries then
            activityEntries = FilterActivityEntries(activityEntries)
        end
        return currentActivityType, activityEntries
    end

    return true
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    HookRefreshList()
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
