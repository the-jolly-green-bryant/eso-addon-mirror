--- InkTracker AddOn by lastguest

InkTracker = {}

InkTracker.Name = "InkTracker"
InkTracker.DisplayName = "Luminous Ink Tracker"
InkTracker.AddonVersion = "1.0.0"
InkTracker.AddonVersionInt = 1000
InkTracker.VariableVersion = 1
InkTracker.INK_ITEMID = 204881
InkTracker.INK_ICON = "/esoui/art/icons/item_grimoire_ink.dds"
InkTracker.INK_LINK = "|H0:item:204881:370:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
InkTracker.PlayNotificationSound = true
InkTracker.NotificationSound = "Enchanting_PotencyRune_Removed"

function InkTracker:Echo(msg)
    CHAT_SYSTEM:AddMessage("[|c2080D0" .. InkTracker.DisplayName .. "|r] " .. msg)
end

function InkTracker:AnnounceDrop(quantity)
    local text = "|c2080D0Luminous Ink|r"
    local lifespan = 2500

    if quantity > 1 then
        text = quantity .."x |c2080D0Luminous Ink|r"
    end

    -- 5 = CSA_EVENT_RAID_COMPLETE_TEXT
    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(5)
    messageParams:SetText(text)

    if InkTracker.PlayNotificationSound then
        messageParams:SetSound(InkTracker.NotificationSound)
    else
        messageParams:SetSound(nil)
    end

    messageParams:SetLifespanMS(lifespan)
    messageParams:SetIconData(InkTracker.INK_ICON)
    messageParams:MarkSuppressIconFrame()

    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
end

function InkTracker.EventLootReceived(_, _, itemLink, quantity, _, _, self, _, _, itemId)
    if self == false then return end
    if itemId == InkTracker.INK_ITEMID then
        InkTracker:AnnounceDrop(quantity)
    end
end

function InkTracker.OnAddOnLoaded(_, addonName)
    if addonName ~= InkTracker.Name then return end
    EVENT_MANAGER:UnregisterForEvent(InkTracker.Name, EVENT_ADD_ON_LOADED)
    EVENT_MANAGER:RegisterForEvent(InkTracker.Name, EVENT_LOOT_RECEIVED, InkTracker.EventLootReceived)
end

EVENT_MANAGER:RegisterForEvent(InkTracker.Name, EVENT_ADD_ON_LOADED, InkTracker.OnAddOnLoaded)
