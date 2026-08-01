-- Initialize the addon table
QAutoConfirm = {}
QAutoConfirm.name = "QAutoConfirm"
QAutoConfirm.version = "1.0"

-- Handle campaign queue state change (Cyrodiil, Imperial City)
function QAutoConfirm:OnCampaignQueueStateChanged(eventCode, campaignId, isGroup, state)
    -- Debug: Log event details
    local campaignName = GetCampaignName(campaignId) or "Unknown Campaign"
    
    -- Auto-accept transport prompt
    if state == CAMPAIGN_QUEUE_REQUEST_STATE_CONFIRMING then
        ConfirmCampaignEntry(campaignId, isGroup, true)
        d("Auto-accepted " .. campaignName)
    end
end

-- Initialize addon
function QAutoConfirm:Initialize()
    -- Register events
    EVENT_MANAGER:RegisterForEvent(self.name .. "_CampaignQueueState", EVENT_CAMPAIGN_QUEUE_STATE_CHANGED, function(...) self:OnCampaignQueueStateChanged(...) end)
    EVENT_MANAGER:RegisterForEvent(self.name .. "_ActivityQueueResult", EVENT_ACTIVITY_QUEUE_RESULT, function(...) self:OnActivityQueueResult(...) end)
    EVENT_MANAGER:RegisterForEvent(self.name .. "_GroupFinderQueueState", EVENT_GROUP_FINDER_QUEUE_STATE_CHANGED, function(...) self:OnGroupFinderQueueStateChanged(...) end)
    
    -- Startup message
    d("QAutoConfirm v" .. self.version .. " loaded.")
end

-- Handle addon loading
function QAutoConfirm:OnAddOnLoaded(eventCode, addonName)
    if addonName == self.name then
        self:Initialize()
    end
end

-- Register addon load event
EVENT_MANAGER:RegisterForEvent(QAutoConfirm.name, EVENT_ADD_ON_LOADED, function(...) QAutoConfirm:OnAddOnLoaded(...) end)
