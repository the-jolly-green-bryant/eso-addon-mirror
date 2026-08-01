local visible = false

local function OnCampaignQueuePositionChanged(_, _, _, position)
	CampaignQueueStatusIndicatorLabel:SetText(ZO_CommaDelimitNumber(position))
end

local function OnCampaignQueueStateChanged(_, _, _, state)
	visible = state == CAMPAIGN_QUEUE_REQUEST_STATE_WAITING
	CampaignQueueStatusIndicator:SetHidden(not visible)
end

local function OnPlayerActivated()
	CampaignQueueStatusIndicator:SetHidden(not visible)
end

EVENT_MANAGER:RegisterForEvent("CampaignQueueStatus", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
EVENT_MANAGER:RegisterForEvent("CampaignQueueStatus", EVENT_CAMPAIGN_QUEUE_POSITION_CHANGED, OnCampaignQueuePositionChanged)
EVENT_MANAGER:RegisterForEvent("CampaignQueueStatus", EVENT_CAMPAIGN_QUEUE_STATE_CHANGED, OnCampaignQueueStateChanged)