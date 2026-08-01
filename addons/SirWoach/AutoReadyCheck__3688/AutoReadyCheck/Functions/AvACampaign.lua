AutoReadyCheck = AutoReadyCheck or {}

local function UnregisterQueueStateChange()
    EVENT_MANAGER:UnregisterForEvent(
        AutoReadyCheck.name,
        EVENT_CAMPAIGN_QUEUE_STATE_CHANGED
    )
end

local function HandleQueueStateChange(_eventCode, campaignId, isGroup, state)
    if state ~= CAMPAIGN_QUEUE_REQUEST_STATE_CONFIRMING then return end
    
    ConfirmCampaignEntry(campaignId, isGroup, true)
end

local function RegisterQueueStateChange()
    EVENT_MANAGER:RegisterForEvent(AutoReadyCheck.name, EVENT_CAMPAIGN_QUEUE_STATE_CHANGED, HandleQueueStateChange)
end

function AutoReadyCheck.GetAvA()
    return AutoReadyCheck.settings.groupEnabled
end

function AutoReadyCheck.SetAvA(val)
    AutoReadyCheck.settings.groupEnabled = val

    -- If Enabled
    if val then
        RegisterQueueStateChange()
    else
        UnregisterQueueStateChange()
    end

    return AutoReadyCheck.SendToggleMessage(val, SI_QUESTTYPE7)
end

function AutoReadyCheck:InitAvACampaign()
    if not self.GetAvA() then return end

    RegisterQueueStateChange()
end