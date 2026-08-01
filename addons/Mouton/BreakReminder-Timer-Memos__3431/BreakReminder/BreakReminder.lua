BreakReminder = {
    name = "BreakReminder",
    options = {
        type = "panel",
        name = "BreakReminder",
        registerForRefresh = true,
        author = "|c0cccc0@mouton|r",
        recipient = "@mouton",
        version = "1.3.1",
        website = "https://www.esoui.com/downloads/info3431-BreakReminderTimerampMemos.html",
        max_reminders = 10
    },
    command = "/break",
    localSettings = {},
    accountSettings = {},
    defaultSettings = {
        useAccountWide = true,
        notificationColour = { 1, 1, 1, 1 },
        notificationDuration = 10, -- seconds
        notificationDelay = 90,    -- minutes
        nextNotification = 0,
        notificationDuringFights = false,
        variableVersion = 1,
        reminders = {}
    }
}

local BR = BreakReminder
local timerCallback = nil
local reminderCallbacks = {}

BR.Events = {}
BR.CallbackManager = {}
BR.CallbackManager.callbacks = {}

local function uuid()
    local template = 'xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function(c)
        local v = (c == 'x') and zo_random(0, 0xf) or zo_random(8, 0xb)
        return string.format('%x', v)
    end)
end

local function len(table)
    local i = 0
    for _ in pairs(table) do
        i = i + 1
    end
    return i
end

function BR.Events:AddEvent(eventName)
    BR.CallbackManager.callbacks[eventName] = {}
end

BR.Events:AddEvent("BREAK_REMINDER_TIMER")
BR.Events:AddEvent("BREAK_REMINDER_REMINDER")

function BR.CallbackManager:HasCallback(event)
    for _, callback in pairs(self.callbacks[event]) do
        return true
    end
    return false;
end

function BR.CallbackManager:RegisterCallback(event, callback)
    assert(callback)
    assert(event)
    table.insert(self.callbacks[event], callback)
end

function BR.CallbackManager:UnregisterCallback(event, callback)
    for index, entry in pairs(self.callbacks[event]) do
        if entry == callback then
            self.callbacks[event][index] = nil
            return true
        end
    end
    return false
end

function BR.CallbackManager:FireCallbacks(event, ...)
    for _, callback in pairs(self.callbacks[event]) do
        callback(event, ...)
    end
end

-- Custom reminder
function BR.TriggerReminder(event, message)
    local settings = BR.GetSettings()

    if settings.notificationDuringFights or not IsUnitInCombat("player") then
        local textColor = ZO_ColorDef:New(unpack(settings.notificationColour))
        local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT,
            SOUNDS.BLACKSMITH_CREATE_TOOLTIP_GLOW)
        messageParams:SetText(textColor:Colorize(zo_strformat(BREAKREMINDER_DIALOG_TITLE)),
            textColor:Colorize(zo_strformat(message ~= "" and message or BREAKREMINDER_NOTIF_UNKNOWN)))
        -- messageParams:SetIconData(icon, COLLECTIBLE_EMERGENCY_BACKGROUND)
        messageParams:SetLifespanMS(settings.notificationDuration * 1000)
        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        CHAT_SYSTEM:Maximize()
        CHAT_SYSTEM:AddMessage(zo_strformat(BREAKREMINDER_DIALOG_TITLE) .. ': ' .. zo_strformat(message ~= "" and message or BREAKREMINDER_NOTIF_UNKNOWN))
    else
        -- Try again later if player is in a fight
        zo_callLater(function () BR.TriggerReminder(event, message) end, 10000);
    end
end

-- Reccurent timer for a break
function BR.TriggerTimer(event)
    local settings = BR.GetSettings()

    if settings.notificationDuringFights or not IsUnitInCombat("player") then
        local textColor = ZO_ColorDef:New(unpack(settings.notificationColour))
        local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT,
            SOUNDS.BLACKSMITH_CREATE_TOOLTIP_GLOW)
        messageParams:SetText(textColor:Colorize(zo_strformat(BREAKREMINDER_BREAK_TITLE)),
            textColor:Colorize(zo_strformat(BREAKREMINDER_BREAK_TEXT)))
        -- messageParams:SetIconData(icon, COLLECTIBLE_EMERGENCY_BACKGROUND)
        messageParams:SetLifespanMS(settings.notificationDuration * 1000)
        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        CHAT_SYSTEM:Maximize()
        CHAT_SYSTEM:AddMessage(zo_strformat(BREAKREMINDER_BREAK_TITLE) .. ': ' .. zo_strformat(BREAKREMINDER_BREAK_TEXT) )

        BR.StartTimer()
    else
        -- Try again later if player is in a fight
        zo_callLater(function () BR.TriggerTimer(event) end, 10000);
    end
end

-- Start the recurring timer for a break
function BR.StartTimer()
    local settings = BR.GetSettings()
    -- No notification ongoing. Initialize a new notification
    if settings.nextNotification <= BR.GetTime() then
        settings.nextNotification = BR.GetDelay() + BR.GetTime()
        CHAT_SYSTEM:AddMessage(zo_strformat(BREAKREMINDER_BREAK_START, settings.notificationDelay))
        timerCallback = zo_callLater(function()
            timerCallback = nil
            BR.CallbackManager:FireCallbacks("BREAK_REMINDER_TIMER")
        end, BR.GetDelay() * 1000)
        -- Game / UI was reloaded during within the delay ?
    elseif not timerCallback then
        CHAT_SYSTEM:AddMessage(zo_strformat(BREAKREMINDER_BREAK_START,
            math.ceil((settings.nextNotification - BR.GetTime()) / 60)))
        timerCallback = zo_callLater(function()
            timerCallback = nil
            BR.CallbackManager:FireCallbacks("BREAK_REMINDER_TIMER")
        end, (settings.nextNotification - BR.GetTime()) * 1000)
    else
        d('Timer for Break Reminder already started');
        -- BR.ResetTimer()
    end
end

-- Reset timer to the user settings value
function BR.ResetTimer()
    local settings = BR.GetSettings()

    if timerCallback then
        zo_removeCallLater(timerCallback)
        timerCallback = nil
    end
    settings.nextNotification = 0
    BR.StartTimer()
end

-- Set up all custom reminders and callbacks
function BR.SetupReminders()
    local settings = BR.GetSettings()

    for k, c in pairs(reminderCallbacks) do
        zo_removeCallLater(c)
        reminderCallbacks[k] = nil
    end

    for k, r in pairs(settings.reminders) do
        if r.remember then
            -- Reminder is passed but still there?
            if r.nextNotification <= BR.GetTime() then
                BR.TriggerReminder(r.note)
                settings.reminders[k] = nil
            else
                if r.remember then
                    BR.AddReminderCallback(r)
                end
            end
        else
            settings.reminders[k] = nil
        end
    end
end

function BR.AddReminderCallback(reminder)
    local settings = BR.GetSettings()
    CHAT_SYSTEM:AddMessage(zo_strformat(BREAKREMINDER_NOTIF_IN, math.ceil((reminder.nextNotification - BR.GetTime()) / 60), reminder.note ~= "" and reminder.note or "(???)"))
    reminderCallbacks[reminder.id] = zo_callLater(function()
        BR.CallbackManager:FireCallbacks("BREAK_REMINDER_REMINDER", reminder.note)
        BR.RemoveReminder(reminder)
        BR.RefreshSettings()
    end, (reminder.nextNotification - BR.GetTime()) * 1000)
end

function BR.GetTime()
    return os.time(os.date("!*t"))
end

function BR.GetDelay()
    local settings = BR.GetSettings()
    return settings.notificationDelay * 60
end

function BR.RemoveReminder(reminder)
    if reminder and reminder.id then
        local settings = BR.GetSettings()
        settings.reminders[reminder.id] = nil
        if reminderCallbacks[reminder.id] then
            zo_removeCallLater(reminderCallbacks[reminder.id])
            reminderCallbacks[reminder.id] = nil
        end

        BR.RefreshSettings()
    end
end

function BR.AddReminder(delay, note, remember)
    local settings = BR.GetSettings()
    if len(settings.reminders) < BR.options.max_reminders then
        local settings = BR.GetSettings()
        math.randomseed(os.time())
        local reminder = { id = uuid(), note = note, delay = delay, nextNotification = BR.GetTime() + delay * 60, remember = remember }
        settings.reminders[reminder.id] = reminder
        BR.AddReminderCallback(reminder)
        BR.RefreshSettings()
        -- CHAT_SYSTEM:AddMessage(zo_strformat(BREAKREMINDER_NOTIF_REMINDER_ADDED))
    else
        CHAT_SYSTEM:AddMessage(zo_strformat(BREAKREMINDER_NOTIF_TOO_MUCH))
    end
end

function BR.GetLabel(reminder)
    if reminder and reminder.nextNotification then
        return zo_strformat(BREAKREMINDER_DIALOG_IN, math.ceil((reminder.nextNotification - BR.GetTime()) / 60))
    end
    return ""
end

function BR.SlashCommand(commandArgs)
    local options = {}

    for w in commandArgs:gmatch("%S+") do
        options[#options + 1] = string.gsub(string.lower(w), '+', ' ')
    end

    if options[1] == "remind" or options[1] == nil then BR.dialogs_show("BREAKREMINDER_EDIT_TIMER") end
end

-- Initialize
function BR.OnAddOnLoaded(event, addonName)
    if addonName ~= BR.name then return end

    BreakReminder:Initialize()
end

function BreakReminder:Initialize()
    BR.accountSettings = ZO_SavedVars:NewAccountWide(BR.name .. "Variables", BR.defaultSettings.variableVersion, nil,
        BR.defaultSettings)
    BR.localSettings = ZO_SavedVars:NewCharacterIdSettings(BR.name .. "Variables", BR.defaultSettings.variableVersion,
        nil, BR.defaultSettings)

    BR:CreateAddonMenu()

    EVENT_MANAGER:UnregisterForEvent(BR.name, EVENT_ADD_ON_LOADED)

    BR.CallbackManager:RegisterCallback("BREAK_REMINDER_TIMER", BR.TriggerTimer)
    BR.CallbackManager:RegisterCallback("BREAK_REMINDER_REMINDER", BR.TriggerReminder)


    SLASH_COMMANDS[BR.command] = BR.SlashCommand
    zo_callLater(BR.StartTimer, 2000)
    zo_callLater(BR.SetupReminders, 2000)
end

EVENT_MANAGER:RegisterForEvent(BR.name, EVENT_ADD_ON_LOADED, BR.OnAddOnLoaded)
