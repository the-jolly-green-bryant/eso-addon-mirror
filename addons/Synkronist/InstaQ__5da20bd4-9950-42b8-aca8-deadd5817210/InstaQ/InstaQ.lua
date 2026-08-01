-- Initialize the addon table
InstaQ = {}
InstaQ.name = "InstaQ"
InstaQ.version = "2.10"

-- Function to queue for Ravenwatch
function InstaQ:QueueForRavenwatch()
    local ravenwatchId = 103 -- Fallback ID
    if GetNumCampaigns then
        for i = 1, GetNumCampaigns() do
            local campaignId = GetCampaignId(i)
            local campaignName = GetCampaignName(campaignId)
            if campaignName:lower():find("ravenwatch") then
                ravenwatchId = campaignId
                d("InstaQ: Found Ravenwatch ID: " .. ravenwatchId)
                break
            end
        end
    else
        d("InstaQ: ID: " .. ravenwatchId)
    end
    if ravenwatchId then
        QueueForCampaign(ravenwatchId, QUEUE_INDIVIDUAL)
        d("InstaQ: (ID: " .. ravenwatchId .. ")")
    else
        d("InstaQ: Error - Invalid Ravenwatch ID")
    end
end

-- Auto-accept transport when prompted
function InstaQ:OnCampaignQueueStateChanged(eventCode, campaignId, isGroup, state)
    if state == CAMPAIGN_QUEUE_REQUEST_STATE_CONFIRMING then
        ConfirmCampaignEntry(campaignId, isGroup, true)
        d("InstaQ: Auto-Accepted ID: " .. campaignId)
    end
end

-- Trigger on quickslot selection change
function InstaQ:OnActiveQuickslotChanged(eventCode, slotIndex)
    d("slot: " .. (slotIndex or "nil"))
    -- Trigger when quickslot 4 is selected
    if slotIndex == 4 then
        d("InstaQ: Quickslot 4 selected. Queuing for Ravenwatch.")
        InstaQ:QueueForRavenwatch() -- Use InstaQ directly
    end
end

-- Initialize addon
function InstaQ:Initialize()
    -- Register events
    EVENT_MANAGER:RegisterForEvent(self.name .. "_QueueState", EVENT_CAMPAIGN_QUEUE_STATE_CHANGED, function(...) InstaQ:OnCampaignQueueStateChanged(...) end)
    d("InstaQ: Registered EVENT_CAMPAIGN_QUEUE_STATE_CHANGED")
    EVENT_MANAGER:RegisterForEvent(self.name .. "_QuickslotChange", EVENT_ACTIVE_QUICKSLOT_CHANGED, function(...) InstaQ:OnActiveQuickslotChanged(...) end)
    d("InstaQ: Registered EVENT_ACTIVE_QUICKSLOT_CHANGED")

    -- Startup message
    d("InstaQ v" .. self.version .. " loaded. Cycle to quickslot 4 (D-pad) to queue for Ravenwatch.")
end

-- Handle addon loading
function InstaQ:OnAddOnLoaded(eventCode, addonName)
    if addonName == self.name then
        self:Initialize()
    end
end

-- Register addon load event
EVENT_MANAGER:RegisterForEvent(InstaQ.name, EVENT_ADD_ON_LOADED, function(...) InstaQ:OnAddOnLoaded(...) end)
