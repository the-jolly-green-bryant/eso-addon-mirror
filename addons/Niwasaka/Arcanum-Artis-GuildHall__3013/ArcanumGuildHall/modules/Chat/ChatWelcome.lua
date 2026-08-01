local ArcanumGuildHall = _G["ArcanumGuildHall"]

local res = ArcanumGuildHallMediaRes

local function GetTimeBasedGreeting()
    local hour = tonumber(os.date("%H"))

    if hour >= 5 and hour < 12 then
        return ArcanumGuildHall.GetDefaultLocaleString("CHAT_WELCOME_MESSAGE_MORNING")
    elseif hour >= 12 and hour < 17 then
        return ArcanumGuildHall.GetDefaultLocaleString("CHAT_WELCOME_MESSAGE_MIDDAY")
    else
        return ArcanumGuildHall.GetDefaultLocaleString("CHAT_WELCOME_MESSAGE_EVENING")
    end
end

function ArcanumGuildHall:ShowWelcomeText()
    if self.welcomeTextRegistered then
        return
    end
    self.welcomeTextRegistered = true

    local eventName = self.name .. "_WelcomeText"

    local function ShowGreeting()
        local accountName = GetDisplayName()
        local greeting = GetTimeBasedGreeting()

        local message = string.format(
                ArcanumGuildHall.GetDefaultLocaleString("CHAT_WELCOME_MESSAGE"),
                res.IconAA,
                res.Ccolor1,
                greeting,
                accountName
        )

        CHAT_ROUTER:AddSystemMessage(message)
    end

    EVENT_MANAGER:RegisterForEvent(eventName, EVENT_PLAYER_ACTIVATED, function()
        ShowGreeting()
        EVENT_MANAGER:UnregisterForEvent(eventName, EVENT_PLAYER_ACTIVATED)
    end)
end