local ADDON_NAME = "HelloTamriel"
local ADDON_VERSION = "5"

HelloTamriel = HelloTamriel or {}
local HT = HelloTamriel

HT.defaults = {
    useCharacter = false,
    toggle = true,
    welcomeMessage = GetString(HELLOTAMRIEL_HELLO),
    zoneWelcomeEnabled = true,
    zoneWelcomeMessage = GetString(HELLOTAMRIEL_ZONE_WELCOME),
    autoFillGreetingEnabled = false,
    autoFillGreetingMessage = GetString(HELLOTAMRIEL_GUILD_GREETING_EXAMPLE),
    autoFillGreetingIntervalMinutes = 1200,
    autoFillGreetingLastUsed = 0,
    autoFillGuildIndex = 1,
    guildRecruiterMode = false,
    guildRecruiterMessage = GetString(HELLOTAMRIEL_RECRUITER_EXAMPLE),
    guildCustomSelectedGuild = 1,
    guildCustom1Enabled = false,
    guildCustom2Enabled = false,
    guildCustom3Enabled = false,
    guildCustomMessage1 = GetString(HELLOTAMRIEL_CUSTOM1_EXAMPLE),
    guildCustomMessage2 = GetString(HELLOTAMRIEL_CUSTOM2_EXAMPLE),
    guildCustomMessage3 = GetString(HELLOTAMRIEL_CUSTOM3_EXAMPLE),
}

local accountSavedVars
local characterSavedVars
local settings

local lastZone = nil
local isFirstActivation = true
local recruiterModeEnabled = false

local function GetGuildChatCommand(guildIndex)
    return string.format("/guild%d ", guildIndex)
end

local function FormatMessage(template)
    local name = GetUnitName("player")
    local zone = GetZoneNameByIndex(GetUnitZoneIndex("player"))
    local msg = template
    msg = msg:gsub("{name}", name or "")
    msg = msg:gsub("{zone}", zone or "")
    return msg
end

local function UpdateSettingsTable()
    if accountSavedVars.useCharacter then
        settings = characterSavedVars
    else
        settings = accountSavedVars
    end
end

local function ShouldAutoFillGreeting()
    if not settings.autoFillGreetingEnabled then return false end
    local now = GetTimeStamp()
    local intervalMinutes = tonumber(settings.autoFillGreetingIntervalMinutes) or 1200
    local lastUsed = tonumber(settings.autoFillGreetingLastUsed) or 0
    return (now - lastUsed) >= (intervalMinutes * 60)
end

local function SetAutoFillLastUsed()
    settings.autoFillGreetingLastUsed = GetTimeStamp()
end

function HT.SetRecruiterMode(enabled)
    settings.guildRecruiterMode = enabled
    recruiterModeEnabled = enabled
    if enabled then
        d("[HelloTamriel] " .. GetString(HELLOTAMRIEL_RECRUITER_ENABLED))
    else
        d("[HelloTamriel] " .. GetString(HELLOTAMRIEL_RECRUITER_DISABLED))
    end
end

function HT.ToggleRecruiterMode()
    HT.SetRecruiterMode(not (settings.guildRecruiterMode or false))
end

function HT.ToggleCustomMessage(idx)
    local prop = "guildCustom" .. idx .. "Enabled"
    settings[prop] = not settings[prop]
    d("[HelloTamriel] " .. string.format(
        GetString("HELLOTAMRIEL_CUSTOM" .. idx .. "_STATUS"),
        (settings[prop] and GetString(HELLOTAMRIEL_ENABLED) or GetString(HELLOTAMRIEL_DISABLED))
    ))
end

function HT.RegisterSlashCommands()
    SLASH_COMMANDS["/guildrecruiter"] = function() HT.ToggleRecruiterMode() end
    SLASH_COMMANDS["/guildcustom1"] = function() HT.ToggleCustomMessage(1) end
    SLASH_COMMANDS["/guildcustom2"] = function() HT.ToggleCustomMessage(2) end
    SLASH_COMMANDS["/guildcustom3"] = function() HT.ToggleCustomMessage(3) end
end

local function OnPlayerActivated(eventCode)
    local currentZone = GetZoneNameByIndex(GetUnitZoneIndex("player"))

    if (recruiterModeEnabled or settings.guildRecruiterMode) then
        if lastZone and currentZone ~= lastZone then
            StartChatInput(
                (settings.guildRecruiterMessage or HT.defaults.guildRecruiterMessage),
                CHAT_CHANNEL_ZONE
            )
        end
    end

    if isFirstActivation then
        if settings.autoFillGreetingEnabled and ShouldAutoFillGreeting() then
            local guildIndex = settings.autoFillGuildIndex or 1
            if GetGuildName(GetGuildId(guildIndex)) ~= "" then
                local chatCmd = GetGuildChatCommand(guildIndex)
                StartChatInput(chatCmd .. (settings.autoFillGreetingMessage or ""))
                SetAutoFillLastUsed()
            end
        end

        if settings.toggle then
            d(FormatMessage(settings.welcomeMessage))
        end
        isFirstActivation = false
    elseif settings.toggle and settings.zoneWelcomeEnabled and lastZone and currentZone ~= lastZone then
        d(FormatMessage(settings.zoneWelcomeMessage))
    end
    lastZone = currentZone
end

function HT.RegisterChatInputPreHook()
    local preventEndlessLoop = false
    ZO_PreHook("StartChatInput", function(text, channel, target, ...)
        if (settings.guildCustom1Enabled or settings.guildCustom2Enabled or settings.guildCustom3Enabled)
            and (text == nil or text == "")
            and channel == CHAT_CHANNEL_WHISPER and target and target ~= "" then

            local selectedGuildIdx = settings.guildCustomSelectedGuild or 1
            local guildId = GetGuildId(selectedGuildIdx)
            local found = false
            for i = 1, GetNumGuildMembers(guildId) do
                local displayName = GetGuildMemberInfo(guildId, i)
                if displayName and (displayName:lower() == target:lower() or displayName:lower() == ("@"..target):lower()) then
                    found = true
                    break
                end
            end

            if found then
                local msg = ""
                if settings.guildCustom1Enabled then
                    msg = msg .. (settings.guildCustomMessage1 or "") .. " "
                end
                if settings.guildCustom2Enabled then
                    msg = msg .. (settings.guildCustomMessage2 or "") .. " "
                end
                if settings.guildCustom3Enabled then
                    msg = msg .. (settings.guildCustomMessage3 or "") .. " "
                end
                msg = msg:match("^%s*(.-)%s*$")
                preventEndlessLoop = true
                StartChatInput(msg, channel, target, ...)
                preventEndlessLoop = false
                return true
            end
        end
        preventEndlessLoop = false
        return false
    end)
end

function HT.CreateSettingsMenu()
    local LAM2 = LibAddonMenu2
    local panelData = {
        type = "panel",
        name = "Hello Tamriel! - Guild Chat Assistant",
        displayName = "Hello Tamriel! - Guild Chat Assistant",
        author = "Dharan-Empire, and GitHub Copilot",
        version = ADDON_VERSION,
        registerForRefresh = true,
        registerForDefaults = true,
    }
    local optionsTable = {
        {
            type = "checkbox",
            name = GetString(HELLOTAMRIEL_USE_CHARACTER),
            tooltip = GetString(HELLOTAMRIEL_USE_CHARACTER_TIP),
            getFunc = function() return accountSavedVars.useCharacter end,
            setFunc = function(value)
                accountSavedVars.useCharacter = value
                UpdateSettingsTable()
            end,
            default = HT.defaults.useCharacter,
            requiresReload = true,
        },
        {
            type = "checkbox",
            name = GetString(HELLOTAMRIEL_ENABLE_GREETING),
            tooltip = GetString(HELLOTAMRIEL_ENABLE_GREETING_TIP),
            getFunc = function() return settings.toggle end,
            setFunc = function(value) settings.toggle = value end,
            default = HT.defaults.toggle,
        },
        {
            type = "editbox",
            name = GetString(HELLOTAMRIEL_WELCOME_MSG),
            tooltip = GetString(HELLOTAMRIEL_WELCOME_MSG_TIP),
            getFunc = function() return settings.welcomeMessage end,
            setFunc = function(value) settings.welcomeMessage = value end,
            default = HT.defaults.welcomeMessage,
            width = "full",
        },
        {
            type = "checkbox",
            name = GetString(HELLOTAMRIEL_ENABLE_ZONE_WELCOME),
            tooltip = GetString(HELLOTAMRIEL_ENABLE_ZONE_WELCOME_TIP),
            getFunc = function() return settings.zoneWelcomeEnabled end,
            setFunc = function(value) settings.zoneWelcomeEnabled = value end,
            default = HT.defaults.zoneWelcomeEnabled,
        },
        {
            type = "editbox",
            name = GetString(HELLOTAMRIEL_ZONE_WELCOME_MSG),
            tooltip = GetString(HELLOTAMRIEL_ZONE_WELCOME_MSG_TIP),
            getFunc = function() return settings.zoneWelcomeMessage end,
            setFunc = function(value) settings.zoneWelcomeMessage = value end,
            default = HT.defaults.zoneWelcomeMessage,
            width = "full",
            disabled = function() return not settings.zoneWelcomeEnabled end,
        },
        {
            type = "header",
            name = GetString(HELLOTAMRIEL_AUTO_FILL_GREETING),
        },
        {
            type = "checkbox",
            name = GetString(HELLOTAMRIEL_ENABLE_AUTO_FILL_GREETING),
            tooltip = GetString(HELLOTAMRIEL_ENABLE_AUTO_FILL_GREETING_TIP),
            getFunc = function() return settings.autoFillGreetingEnabled end,
            setFunc = function(value) settings.autoFillGreetingEnabled = value end,
            default = HT.defaults.autoFillGreetingEnabled,
        },
        {
            type = "editbox",
            name = GetString(HELLOTAMRIEL_AUTO_FILL_GREETING_MSG),
            tooltip = GetString(HELLOTAMRIEL_AUTO_FILL_GREETING_MSG_TIP),
            getFunc = function() return settings.autoFillGreetingMessage end,
            setFunc = function(value) settings.autoFillGreetingMessage = value end,
            default = HT.defaults.autoFillGreetingMessage,
            width = "full",
            disabled = function() return not settings.autoFillGreetingEnabled end,
        },
        {
            type = "slider",
            name = GetString(HELLOTAMRIEL_AUTO_FILL_MINUTES),
            tooltip = GetString(HELLOTAMRIEL_AUTO_FILL_MINUTES_TIP),
            min = 1,
            max = 10080,
            step = 1,
            getFunc = function() return settings.autoFillGreetingIntervalMinutes end,
            setFunc = function(value) settings.autoFillGreetingIntervalMinutes = value end,
            default = HT.defaults.autoFillGreetingIntervalMinutes,
            disabled = function() return not settings.autoFillGreetingEnabled end,
        },
        {
            type = "dropdown",
            name = GetString(HELLOTAMRIEL_SELECT_GUILD_AUTO_FILL),
            tooltip = GetString(HELLOTAMRIEL_SELECT_GUILD_AUTO_FILL_TIP),
            choices = (function()
                local choices = {}
                for i = 1, 5 do
                    local guildName = GetGuildName(GetGuildId(i))
                    table.insert(choices, guildName ~= "" and guildName or (GetString(HELLOTAMRIEL_GUILD_SLOT) .. " " .. i))
                end
                return choices
            end)(),
            getFunc = function()
                local idx = settings.autoFillGuildIndex or 1
                local guildName = GetGuildName(GetGuildId(idx))
                return guildName ~= "" and guildName or (GetString(HELLOTAMRIEL_GUILD_SLOT) .. " " .. idx)
            end,
            setFunc = function(selected)
                for i = 1, 5 do
                    local guildName = GetGuildName(GetGuildId(i))
                    local slotName = guildName ~= "" and guildName or (GetString(HELLOTAMRIEL_GUILD_SLOT) .. " " .. i)
                    if slotName == selected then
                        settings.autoFillGuildIndex = i
                        break
                    end
                end
            end,
            default = (function()
                local guildName = GetGuildName(GetGuildId(HT.defaults.autoFillGuildIndex))
                return guildName ~= "" and guildName or (GetString(HELLOTAMRIEL_GUILD_SLOT) .. " " .. HT.defaults.autoFillGuildIndex)
            end)(),
            disabled = function() return not settings.autoFillGreetingEnabled end,
            width = "full",
        },
        {
            type = "header",
            name = GetString(HELLOTAMRIEL_GUILD_RECRUITER),
        },
        {
            type = "checkbox",
            name = GetString(HELLOTAMRIEL_ENABLE_RECRUITER),
            tooltip = GetString(HELLOTAMRIEL_ENABLE_RECRUITER_TIP),
            getFunc = function() return settings.guildRecruiterMode end,
            setFunc = function(val) HT.SetRecruiterMode(val) end,
            default = HT.defaults.guildRecruiterMode,
            width = "full",
        },
        {
            type = "editbox",
            name = GetString(HELLOTAMRIEL_RECRUITER_MSG),
            tooltip = GetString(HELLOTAMRIEL_RECRUITER_MSG_TIP),
            getFunc = function() return settings.guildRecruiterMessage end,
            setFunc = function(val) settings.guildRecruiterMessage = val end,
            default = HT.defaults.guildRecruiterMessage,
            width = "full",
            disabled = function() return not settings.guildRecruiterMode end,
        },
        {
            type = "header",
            name = GetString(HELLOTAMRIEL_CUSTOM_GUILD_MESSAGES),
        },
        {
            type = "dropdown",
            name = GetString(HELLOTAMRIEL_SELECT_GUILD_CUSTOM),
            tooltip = GetString(HELLOTAMRIEL_SELECT_GUILD_CUSTOM_TIP),
            choices = (function()
                local choices = {}
                for i = 1, 5 do
                    local guildName = GetGuildName(GetGuildId(i))
                    table.insert(choices, guildName ~= "" and guildName or (GetString(HELLOTAMRIEL_GUILD_SLOT) .. " " .. i))
                end
                return choices
            end)(),
            getFunc = function()
                local idx = settings.guildCustomSelectedGuild or 1
                local guildName = GetGuildName(GetGuildId(idx))
                return guildName ~= "" and guildName or (GetString(HELLOTAMRIEL_GUILD_SLOT) .. " " .. idx)
            end,
            setFunc = function(selected)
                for i = 1, 5 do
                    local guildName = GetGuildName(GetGuildId(i))
                    local slotName = guildName ~= "" and guildName or (GetString(HELLOTAMRIEL_GUILD_SLOT) .. " " .. i)
                    if slotName == selected then
                        settings.guildCustomSelectedGuild = i
                        break
                    end
                end
            end,
            default = (function()
                local guildName = GetGuildName(GetGuildId(HT.defaults.guildCustomSelectedGuild))
                return guildName ~= "" and guildName or (GetString(HELLOTAMRIEL_GUILD_SLOT) .. " " .. HT.defaults.guildCustomSelectedGuild)
            end)(),
            width = "full",
        },
        {
            type = "checkbox",
            name = GetString(HELLOTAMRIEL_ENABLE_CUSTOM1),
            tooltip = GetString(HELLOTAMRIEL_ENABLE_CUSTOM1_TIP),
            getFunc = function() return settings.guildCustom1Enabled end,
            setFunc = function(val) settings.guildCustom1Enabled = val end,
            default = HT.defaults.guildCustom1Enabled,
            width = "full",
        },
        {
            type = "editbox",
            name = GetString(HELLOTAMRIEL_CUSTOM1_MSG),
            tooltip = GetString(HELLOTAMRIEL_CUSTOM1_MSG_TIP),
            getFunc = function() return settings.guildCustomMessage1 end,
            setFunc = function(val) settings.guildCustomMessage1 = val end,
            default = HT.defaults.guildCustomMessage1,
            width = "full",
            disabled = function() return not settings.guildCustom1Enabled end,
        },
        {
            type = "checkbox",
            name = GetString(HELLOTAMRIEL_ENABLE_CUSTOM2),
            tooltip = GetString(HELLOTAMRIEL_ENABLE_CUSTOM2_TIP),
            getFunc = function() return settings.guildCustom2Enabled end,
            setFunc = function(val) settings.guildCustom2Enabled = val end,
            default = HT.defaults.guildCustom2Enabled,
            width = "full",
        },
        {
            type = "editbox",
            name = GetString(HELLOTAMRIEL_CUSTOM2_MSG),
            tooltip = GetString(HELLOTAMRIEL_CUSTOM2_MSG_TIP),
            getFunc = function() return settings.guildCustomMessage2 end,
            setFunc = function(val) settings.guildCustomMessage2 = val end,
            default = HT.defaults.guildCustomMessage2,
            width = "full",
            disabled = function() return not settings.guildCustom2Enabled end,
        },
        {
            type = "checkbox",
            name = GetString(HELLOTAMRIEL_ENABLE_CUSTOM3),
            tooltip = GetString(HELLOTAMRIEL_ENABLE_CUSTOM3_TIP),
            getFunc = function() return settings.guildCustom3Enabled end,
            setFunc = function(val) settings.guildCustom3Enabled = val end,
            default = HT.defaults.guildCustom3Enabled,
            width = "full",
        },
        {
            type = "editbox",
            name = GetString(HELLOTAMRIEL_CUSTOM3_MSG),
            tooltip = GetString(HELLOTAMRIEL_CUSTOM3_MSG_TIP),
            getFunc = function() return settings.guildCustomMessage3 end,
            setFunc = function(val) settings.guildCustomMessage3 = val end,
            default = HT.defaults.guildCustomMessage3,
            width = "full",
            disabled = function() return not settings.guildCustom3Enabled end,
        },
    }
    LAM2:RegisterAddonPanel(ADDON_NAME.."Panel", panelData)
    LAM2:RegisterOptionControls(ADDON_NAME.."Panel", optionsTable)
end

local function OnAddOnLoaded(event, addonName)
    if addonName ~= ADDON_NAME then return end
    accountSavedVars   = ZO_SavedVars:NewAccountWide("HelloTamrielSettings", 1, nil, HT.defaults)
    characterSavedVars = ZO_SavedVars:New("HelloTamrielSettings", 1, nil, HT.defaults)
    UpdateSettingsTable()
    recruiterModeEnabled = settings.guildRecruiterMode or false
    HT.CreateSettingsMenu()
    HT.RegisterSlashCommands()
    HT.RegisterChatInputPreHook()
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)