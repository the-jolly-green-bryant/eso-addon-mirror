--- Endeavor Chat Tracker
--- written by Keldor
---

----
--- Initialize global Variables
----
EndeavorChatTracker = {}
EndeavorChatTracker.Name = "EndeavorChatTracker"


----
--- Event Functions
----
function EndeavorChatTracker.OnTimedActivityProgressUpdate(_, index, _, currentProgress)

	local name = GetTimedActivityName(index)
	local maxProgress = GetTimedActivityMaxProgress(index)

	CHAT_SYSTEM:AddMessage(name .. " (|c00C000" .. currentProgress .. " / " .. maxProgress .. "|r)")
end

function EndeavorChatTracker.OnPromotionalEventsActivityProgressUpdate(_, campaignKey, activityIndex, _, newProgress)

    local _, name, _, completionThreshold = GetPromotionalEventCampaignActivityInfo(campaignKey, activityIndex)

	CHAT_SYSTEM:AddMessage("[" .. GetString(SI_PROMOTIONAL_EVENT_TRACKER_HEADER) .. "] " .. name .. " (|c00C000" .. newProgress .. " / " .. completionThreshold .. "|r)")
end




----
--- OnAddOnLoaded
----
function EndeavorChatTracker.OnAddOnLoaded(_, addonName)

	if addonName ~= EndeavorChatTracker.Name then return end

	EVENT_MANAGER:UnregisterForEvent(EndeavorChatTracker.Name, EVENT_ADD_ON_LOADED)
	EVENT_MANAGER:RegisterForEvent(EndeavorChatTracker.Name, EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED, EndeavorChatTracker.OnTimedActivityProgressUpdate)
	EVENT_MANAGER:RegisterForEvent(EndeavorChatTracker.Name, EVENT_PROMOTIONAL_EVENTS_ACTIVITY_PROGRESS_UPDATED, EndeavorChatTracker.OnPromotionalEventsActivityProgressUpdate)
end


----
--- AddOn init
----
EVENT_MANAGER:RegisterForEvent(EndeavorChatTracker.Name, EVENT_ADD_ON_LOADED, EndeavorChatTracker.OnAddOnLoaded)
