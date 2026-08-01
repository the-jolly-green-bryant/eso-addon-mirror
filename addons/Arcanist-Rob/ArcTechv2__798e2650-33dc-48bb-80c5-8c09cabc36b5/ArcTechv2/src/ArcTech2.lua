-- ArcTech2.lua

ArcTech2 = {}
ArcTech2.addon_name = "ArcTech2"
ArcTech2.initialised = false

local libNotification = LibNotification
local provider = libNotification and libNotification:CreateProvider()

local function Init()

    if ArcTech2.initialised then
        return
    end

    ArcTech2.initialised = true

    if not provider then
        d("Provider missing")
        return
    end

    local msg = {
        dataType = NOTIFICATIONS_ALERT_DATA,
        secsSinceRequest = ZO_NormalizeSecondsSince(0),

        note = "The event list for week commencing 25 May 2026 has been updated.",
        message = "Please visit the ArcTech addon Options for a full list of this weeks events.",
        heading = "LibNotifications",

        texture = "EsoUI/Art/Notifications/notificationIcon_guild.dds",

        shortDisplayText = "[Arcanists] New Event List",
        controlsOwnSounds = true,

        data = {},
    }

    provider.notifications = provider.notifications or {}

    table.insert(provider.notifications, msg)
    provider:UpdateNotifications()

    d("Notification inserted")
end

local function OnAddOnLoaded(event, addonName)

    if addonName ~= ArcTech2.addon_name then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(
        ArcTech2.addon_name,
        EVENT_ADD_ON_LOADED
    )

    Init()
end

EVENT_MANAGER:RegisterForEvent(
    ArcTech2.addon_name,
    EVENT_ADD_ON_LOADED,
    OnAddOnLoaded
)