-- Campaign Module
-- Handles campaign queue logic and debug functionality
-- Dependencies: Message, EventManager
-- Data Dependencies: None

local Addon = NMGuildHall
local Constants = Addon and Addon.Constants

local Campaign = {
    initialized = false,
    queueLabel = nil,
    currentQueuePosition = nil,
    currentQueueCampaignId = nil,
    currentQueueIsGroup = false,
    queueUpdateName = nil,
    queueUpdateRunning = false
}

local UpdateQueueStatusLabel -- forward declaration (used by update loop)

function Campaign:NormalizeQueueWaitSeconds(seconds)
    local s = tonumber(seconds) or 0
    if s > 0 and s < 60 then
        s = 60
    end
    return s
end

function Campaign:FormatQueueWaitShort(seconds)
    local s = self:NormalizeQueueWaitSeconds(seconds)
    if s <= 0 then
        return ""
    end
    if Addon and Addon.FormatShortTime then
        return Addon.FormatShortTime(s)
    end
    return tostring(s)
end

function Campaign:GetQueueTimeSuffix(seconds)
    local short = self:FormatQueueWaitShort(seconds)
    if short == "" then
        return ""
    end
    return ", " .. short
end

function Campaign:FormatSelectionQueueInfo(queueSeconds)
    local short = self:FormatQueueWaitShort(queueSeconds)
    if short == "" then
        return ""
    end
    local prefix = GetString(NMGH_UI_CAMPAIGN_QUEUE_PREFIX)
    local iconTag = "|t16:16:EsoUI/Art/Campaign/campaignbrowser_queued.dds|t"
    return iconTag .. " " .. prefix .. string.format("%4s", short)
end

-- Shared formatter so UI footer + queue widget stay consistent.
function Campaign:BuildQueueStatusText(options)
    options = options or {}
    local includeIcon = options.includeIcon ~= false
    local includePrefixIcon = options.includePrefixIcon == true

    if not (self.currentQueueCampaignId and self.currentQueuePosition and self.currentQueuePosition > 0) then
        return nil
    end

    local iconTag = ""
    if includeIcon then
        iconTag = "|t18:18:EsoUI/Art/Campaign/campaignbrowser_queued.dds|t "
    elseif includePrefixIcon then
        iconTag = "|t16:16:EsoUI/Art/Campaign/campaignbrowser_queued.dds|t "
    end

    local waitSeconds = 0
    if GetCampaignQueueWaitTime then
        waitSeconds = GetCampaignQueueWaitTime(self.currentQueueCampaignId, self.currentQueueIsGroup) or 0
    elseif GetCampaignQueueWaitTimeSeconds then
        waitSeconds = GetCampaignQueueWaitTimeSeconds(self.currentQueueCampaignId, self.currentQueueIsGroup) or 0
    end
    local timeSuffix = self:GetQueueTimeSuffix(waitSeconds)

    local campaignName = GetCampaignName and GetCampaignName(self.currentQueueCampaignId) or ""
    if campaignName and campaignName ~= "" then
        local str = GetString(NMGH_CAMPAIGN_QUEUE_STATUS_NAME)
        if Addon and Addon.Message and Addon.Message._FormatPlain then
            str = Addon.Message:_FormatPlain(str, {name = campaignName, pos = self.currentQueuePosition, time = timeSuffix})
        else
            str = string.gsub(str, "{name}", campaignName)
            str = string.gsub(str, "{pos}", tostring(self.currentQueuePosition))
            str = string.gsub(str, "{time}", timeSuffix)
        end
        return iconTag .. str
    end

    local str = GetString(NMGH_CAMPAIGN_QUEUE_STATUS_GENERIC)
    if Addon and Addon.Message and Addon.Message._FormatPlain then
        str = Addon.Message:_FormatPlain(str, {pos = self.currentQueuePosition, time = timeSuffix})
    else
        str = string.gsub(str, "{pos}", tostring(self.currentQueuePosition))
        str = string.gsub(str, "{time}", timeSuffix)
    end
    return iconTag .. str
end

local function EnsureQueueUpdateName()
    if Campaign.queueUpdateName then
        return
    end
    local addonName = (Addon and Addon.name) or "NMGuildHall"
    Campaign.queueUpdateName = addonName .. "_CampaignQueueStatusUpdate"
end

local function StopQueueUpdate()
    if not Campaign.queueUpdateRunning then
        return
    end
    EnsureQueueUpdateName()
    if EVENT_MANAGER and EVENT_MANAGER.UnregisterForUpdate then
        EVENT_MANAGER:UnregisterForUpdate(Campaign.queueUpdateName)
    end
    Campaign.queueUpdateRunning = false
end

local function StartQueueUpdate()
    EnsureQueueUpdateName()
    if Campaign.queueUpdateRunning then
        return
    end
    if EVENT_MANAGER and EVENT_MANAGER.RegisterForUpdate then
        EVENT_MANAGER:RegisterForUpdate(Campaign.queueUpdateName, 1000, function()
            -- Keep label in sync while queued, including ETA countdown if available.
            -- This is cheap (single label setText) and avoids relying on infrequent events.
            if Campaign.currentQueueCampaignId and Campaign.currentQueuePosition and Campaign.currentQueuePosition > 0 then
                UpdateQueueStatusLabel(Campaign)
                if Addon and Addon.QueueWidget and Addon.QueueWidget.RefreshFromCampaign then
                    Addon.QueueWidget:RefreshFromCampaign(Campaign)
                end
            else
                StopQueueUpdate()
            end
        end)
        Campaign.queueUpdateRunning = true
    end
end

function Campaign:ShowQueueDialog(campaignData)
    local UI = Addon.UI
    if not UI then return end

    local campaignName = campaignData.name or "Campaign"
    local title = GetString(NMGH_QUEUE_CAMPAIGN_TITLE)
    
    -- Format confirmation body with campaign name
    local confirmBody = GetString(NMGH_QUEUE_CAMPAIGN_CONFIRM)
    if Addon and Addon.Message and Addon.Message._FormatPlain then
        confirmBody = Addon.Message:_FormatPlain(confirmBody, {campaign = "|cffffff" .. campaignName .. "|r"})
    else
        confirmBody = string.gsub(confirmBody, "{campaign}", "|cffffff" .. campaignName .. "|r")
    end

    local typeBody = GetString(NMGH_QUEUE_CAMPAIGN_TYPE)
    local body = string.format("%s %s", confirmBody, typeBody)
    local isGrouped = IsUnitGrouped("player")

    UI:ShowDialog(title, body, {
        {
            text = GetString(NMGH_BUTTON_QUEUE_GROUP),
            callback = function()
                QueueForCampaign(campaignData.id, CAMPAIGN_QUEUE_GROUP)
            end,
            color = isGrouped and {0.8, 0.2, 0.3, 1} or {0.4, 0.4, 0.4, 1},
            enabled = isGrouped
        },
        {
            text = GetString(NMGH_BUTTON_QUEUE_SOLO),
            callback = function()
                QueueForCampaign(campaignData.id, CAMPAIGN_QUEUE_INDIVIDUAL)
            end
        }
    }, {
        closeMainWindowOnDismiss = true
    })
end

-- We'll keep the table structure for future expansion
UpdateQueueStatusLabel = function(self)
    local label = self.queueLabel
    if not label then
        return
    end

    if self.currentQueueCampaignId and self.currentQueuePosition and self.currentQueuePosition > 0 then
        local text = self:BuildQueueStatusText({ includeIcon = true })
        label:SetText(text)
        label:SetHidden(false)
        if Addon and Addon.QueueWidget and Addon.QueueWidget.RefreshFromCampaign then
            Addon.QueueWidget:RefreshFromCampaign(self)
        end
    else
        label:SetHidden(true)
        if Addon and Addon.QueueWidget and Addon.QueueWidget.SetActive then
            Addon.QueueWidget:SetActive(false)
        end
        StopQueueUpdate()
    end
end

local function OnCampaignQueuePositionChanged(eventCode, campaignId, isGroup, position)
    Campaign.currentQueueCampaignId = campaignId
    Campaign.currentQueueIsGroup = isGroup
    Campaign.currentQueuePosition = position
    UpdateQueueStatusLabel(Campaign)
    if Addon and Addon.QueueWidget and Addon.QueueWidget.RefreshFromCampaign then
        Addon.QueueWidget:RefreshFromCampaign(Campaign)
    end
    if Campaign.currentQueueCampaignId and Campaign.currentQueuePosition and Campaign.currentQueuePosition > 0 then
        StartQueueUpdate()
    end
end

local function OnCampaignQueueStateChanged(eventCode, campaignId, isGroup, state)
    if state == CAMPAIGN_QUEUE_REQUEST_STATE_WAITING then
        Campaign.currentQueueCampaignId = campaignId
        Campaign.currentQueueIsGroup = isGroup
        if GetCampaignQueuePosition then
            Campaign.currentQueuePosition = GetCampaignQueuePosition(campaignId, isGroup)
        end
        StartQueueUpdate()
    else
        Campaign.currentQueueCampaignId = nil
        Campaign.currentQueueIsGroup = false
        Campaign.currentQueuePosition = nil
        StopQueueUpdate()
    end
    UpdateQueueStatusLabel(Campaign)
    if Addon and Addon.QueueWidget and Addon.QueueWidget.RefreshFromCampaign then
        Addon.QueueWidget:RefreshFromCampaign(Campaign)
    end
end

function Campaign:Initialize()
    if self.initialized then
        return
    end

    if Addon and Addon.EventManager and EVENT_CAMPAIGN_QUEUE_POSITION_CHANGED and EVENT_CAMPAIGN_QUEUE_STATE_CHANGED then
        Addon.EventManager:RegisterEvent(EVENT_CAMPAIGN_QUEUE_POSITION_CHANGED, OnCampaignQueuePositionChanged, "NMGuildHall_Campaign")
        Addon.EventManager:RegisterEvent(EVENT_CAMPAIGN_QUEUE_STATE_CHANGED, OnCampaignQueueStateChanged, "NMGuildHall_Campaign")
    elseif EVENT_MANAGER and EVENT_CAMPAIGN_QUEUE_POSITION_CHANGED and EVENT_CAMPAIGN_QUEUE_STATE_CHANGED then
        local owner = (Addon and Addon.name) or "NMGuildHall"
        EVENT_MANAGER:RegisterForEvent(owner .. "_CampaignQueuePosition", EVENT_CAMPAIGN_QUEUE_POSITION_CHANGED, OnCampaignQueuePositionChanged)
        EVENT_MANAGER:RegisterForEvent(owner .. "_CampaignQueueState", EVENT_CAMPAIGN_QUEUE_STATE_CHANGED, OnCampaignQueueStateChanged)
    end

    self.initialized = true
    
    if Addon and Addon.Message then
        Addon.Message:For("Campaign"):Debug(GetString(NMGH_DEBUG_CAMPAIGN_INIT))
    end
end

function Campaign:Cleanup()
    EnsureQueueUpdateName()
    if EVENT_MANAGER and EVENT_MANAGER.UnregisterForUpdate and self.queueUpdateName then
        EVENT_MANAGER:UnregisterForUpdate(self.queueUpdateName)
    end
    self.queueUpdateRunning = false
    StopQueueUpdate()

    if Addon and Addon.EventManager and Addon.EventManager.UnregisterEventsByOwner then
        Addon.EventManager:UnregisterEventsByOwner("NMGuildHall_Campaign")
    elseif EVENT_MANAGER then
        local owner = (Addon and Addon.name) or "NMGuildHall"
        EVENT_MANAGER:UnregisterForEvent(owner .. "_CampaignQueuePosition", EVENT_CAMPAIGN_QUEUE_POSITION_CHANGED)
        EVENT_MANAGER:UnregisterForEvent(owner .. "_CampaignQueueState", EVENT_CAMPAIGN_QUEUE_STATE_CHANGED)
    end

    if self.queueLabel and self.queueLabel.SetHidden then
        self.queueLabel:SetHidden(true)
    end
    self.queueLabel = nil
    self.currentQueueCampaignId = nil
    self.currentQueuePosition = nil
    self.currentQueueIsGroup = false
    self.initialized = false
end

function Campaign:AttachQueueLabel(label)
    self.queueLabel = label
    UpdateQueueStatusLabel(self)
    if self.currentQueueCampaignId and self.currentQueuePosition and self.currentQueuePosition > 0 then
        StartQueueUpdate()
    end
end

function Campaign:DebugListCampaigns()
    if not Addon or not Addon.Message then return end
    if Addon.IsDebugEnabled and not Addon:IsDebugEnabled() then
        return
    end
    
    local message = Addon.Message:For("Campaign")
    
    -- Standard ESO Campaign Categories
    -- We only switch once to ensure we have a good base view
    if QueryCampaignSelectionData then
        QueryCampaignSelectionData()
    end

    local numCampaigns = GetNumSelectionCampaigns()
    if not numCampaigns or numCampaigns == 0 then
        message:Debug(GetString(NMGH_DEBUG_CAMPAIGN_NO_SELECTION))
        return
    end

    message:Debug(Addon.Message:_FormatPlain(GetString(NMGH_DEBUG_CAMPAIGN_LIST_HEADER), {count = numCampaigns}))
    
    for i = 1, numCampaigns do
        local campaignId = GetSelectionCampaignId(i)
        local name = GetCampaignName(campaignId)

        message:Debug(string.format(
            "|cCCCCCC#%d |cFFFFFF%s (|c888888%d)",
            i,
            name,
            campaignId
        ))
    end

    local currentId = GetCurrentCampaignId()
    if currentId and currentId > 0 then
        message:Debug(Addon.Message:_FormatPlain(GetString(NMGH_DEBUG_CAMPAIGN_CURRENTLY_IN), {name = GetCampaignName(currentId), id = currentId}))
    end
end

NMGuildHall = NMGuildHall or {}
NMGuildHall.Campaign = Campaign

return Campaign
