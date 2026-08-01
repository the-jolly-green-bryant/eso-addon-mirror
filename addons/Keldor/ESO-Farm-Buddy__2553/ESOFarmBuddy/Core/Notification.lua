--- ESO Farm-Buddy AddOn written by Keldor

ESOFarmBuddyNotification = {}


function ESOFarmBuddyNotification:CenterScreenMessage(itemLink, goal, icon)

    local msg = string.format(GetString(ESOFB_GOAL_NOTIFICATION_TEXT), goal, itemLink)
    local lifespan = 3500

    -- 5 = CSA_EVENT_RAID_COMPLETE_TEXT
    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(5)
    messageParams:SetText(msg)

    if ESOFarmBuddy.SV.Settings.PlayGoalNotificationSound == true then
        messageParams:SetSound(ESOFarmBuddy.SV.Settings.GoalNotificationSound)
    else
        messageParams:SetSound(nil)
    end

    messageParams:SetLifespanMS(lifespan)
    messageParams:SetIconData(icon)
    messageParams:MarkSuppressIconFrame()

    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
end