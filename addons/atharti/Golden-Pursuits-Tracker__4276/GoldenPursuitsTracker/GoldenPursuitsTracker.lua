GoldenPursuitsTracker = {
    Name = "GoldenPursuitsTracker"
}

function GoldenPursuitsTracker.OnActivityProgressUpdate(_, campaignKey, activityIndex, _, Progress)
    local _, ActivityName, _, Goal = GetPromotionalEventCampaignActivityInfo(campaignKey, activityIndex)
    
    if ActivityName and Goal then
        local IconGP = "|t20:20:EsoUI/Art/LFG/Gamepad/LFG_menuIcon_PromotionalEvents.dds|t "
        
        if Progress >= Goal then
            -- Task completed! Use custom yes.dds icon
            local CompletedMsg = "|cFFFFFF" .. IconGP .. ActivityName .. "|r |t20:20:GoldenPursuitsTracker/src/success.dds|t"
            CHAT_SYSTEM:AddMessage(CompletedMsg)
        else
            -- Task in progress
            local ProgressionMsg = "|cFFFFFF" .. IconGP .. ActivityName .. " (|r|cFFFF00" .. Progress .. "|r |cFFFFFF/ " .. Goal .. ")|r"
            CHAT_SYSTEM:AddMessage(ProgressionMsg)
        end
    end
end

function GoldenPursuitsTracker.Initialize()
    EVENT_MANAGER:RegisterForEvent(GoldenPursuitsTracker.Name, EVENT_PROMOTIONAL_EVENTS_ACTIVITY_PROGRESS_UPDATED, GoldenPursuitsTracker.OnActivityProgressUpdate)
end

function GoldenPursuitsTracker.OnAddOnLoaded(_, addonName)
    if addonName ~= GoldenPursuitsTracker.Name then return end
    
    EVENT_MANAGER:UnregisterForEvent(GoldenPursuitsTracker.Name, EVENT_ADD_ON_LOADED)
    GoldenPursuitsTracker.Initialize()
end

EVENT_MANAGER:RegisterForEvent(GoldenPursuitsTracker.Name, EVENT_ADD_ON_LOADED, GoldenPursuitsTracker.OnAddOnLoaded)