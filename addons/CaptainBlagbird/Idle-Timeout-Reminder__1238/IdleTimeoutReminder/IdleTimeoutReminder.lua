--[[

Idle Timeout Reminder
by CaptainBlagbird
https://github.com/CaptainBlagbird

--]]

-- Libraries
local LN = LibStub:GetLibrary("LibNotifications")
LN_provider = LN:CreateProvider()
-- Addon info
local AddonName = "IdleTimeoutReminder"
-- Local variables
local isTimerRunning = false
-- Handle config
if type(IdleTimeoutReminder) ~= "table" then IdleTimeoutReminder = {} end
local DATA_UPDATE_DELAY_MS = 1000 * (IdleTimeoutReminder.CYCLE_TIME_S or 20)
local NOTIFICATION_TIME_MS = 60000 * (IdleTimeoutReminder.NOTIFICATION_TIME_M or 14)
if DATA_UPDATE_DELAY_MS > NOTIFICATION_TIME_MS then NOTIFICATION_TIME_MS = 60000 + DATA_UPDATE_DELAY_MS end
local MESSAGE = IdleTimeoutReminder.MESSAGE or ""


-- Function to remove all custom notifications of this add-on
local function removeNotifications()
    LN_provider.notifications = {}
    LN_provider:UpdateNotifications()
end
-- Function to add custom notification
local function addNotification()
    -- Custom notification info
    local msg = {
            dataType                = NOTIFICATIONS_ALERT_DATA,
            secsSinceRequest        = ZO_NormalizeSecondsSince(0),
            -- note                 = "note",
            message                 = MESSAGE,
            heading                 = "Idle Timeout Reminder",
            texture                 = "EsoUI/Art/MainMenu/menuBar_notifications_down.dds",
            shortDisplayText        = "Idle Timeout Reminder",
            controlsOwnSounds       = false,
            keyboardAcceptCallback  = removeNotifications,
            keybaordDeclineCallback = removeNotifications,
            gamepadAcceptCallback   = removeNotifications,
            gamepadDeclineCallback  = removeNotifications,
        }
    LN_provider.notifications[1] = msg
    LN_provider:UpdateNotifications()
end

-- Function to check and handle player idle state
local x_old, y_old, h_old = GetMapPlayerPosition("player")
local function IdleCheck()
    local function IsPlayerIdle()
        -- Check if in combat
        if IsUnitInCombat("player") then return false end
        -- Compareing current plosition and heading with data of last run
        local x_new, y_new, h_new = GetMapPlayerPosition("player")
        if x_old == x_new and y_old == y_new and h_old == h_new then
            return true
        else
            x_old, y_old, h_old = x_new, y_new, h_new
            return false
        end
    end
    
    if not IsPlayerIdle() then
        EVENT_MANAGER:UnregisterForUpdate(AddonName)
        isTimerRunning = false
    elseif not isTimerRunning then
        EVENT_MANAGER:RegisterForUpdate(AddonName, NOTIFICATION_TIME_MS - DATA_UPDATE_DELAY_MS, addNotification)
        isTimerRunning = true
    end
end
EVENT_MANAGER:RegisterForUpdate(AddonName.."_CheckIdle", DATA_UPDATE_DELAY_MS, IdleCheck)