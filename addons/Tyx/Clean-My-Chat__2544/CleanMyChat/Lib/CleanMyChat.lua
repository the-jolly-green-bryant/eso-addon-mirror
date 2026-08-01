--[[--------------------------------------------
    Project:    Clean My Chat
    Author:     Arne Rantzen (Tyx)
    Created:    2020-02-25
    Updated:    2020-03-03
    License:    GPL-3.0
--------------------------------------------]]--

CleanMyChat = {
    author = "@Tyx",
    name = "CleanMyChat",
    displayName = "Clean My Chat",
    version = "1.2.0",
    savedVersion = 1,
    channelNames = {
        [CHAT_CHANNEL_SAY] = GetString(SI_CHAT_CHANNEL_NAME_SAY),
        [CHAT_CHANNEL_YELL] = GetString(SI_CHAT_CHANNEL_NAME_YELL),
        [CHAT_CHANNEL_EMOTE] = GetString(SI_CHAT_CHANNEL_NAME_EMOTE),
        [CHAT_CHANNEL_WHISPER] = GetString(SI_CHAT_CHANNEL_NAME_WHISPER),
        [CHAT_CHANNEL_WHISPER_SENT] = "Whisper sent",
        -- Zone
        [CHAT_CHANNEL_ZONE] = GetString(SI_CHAT_CHANNEL_NAME_ZONE),
        [CHAT_CHANNEL_ZONE_LANGUAGE_1] = GetString(SI_CHAT_CHANNEL_NAME_ZONE_ENGLISH),
        [CHAT_CHANNEL_ZONE_LANGUAGE_2] = GetString(SI_CHAT_CHANNEL_NAME_ZONE_FRENCH),
        [CHAT_CHANNEL_ZONE_LANGUAGE_3] = GetString(SI_CHAT_CHANNEL_NAME_ZONE_GERMAN),
        [CHAT_CHANNEL_ZONE_LANGUAGE_4] = GetString(SI_CHAT_CHANNEL_NAME_ZONE_JAPANESE),
        -- Party
        [CHAT_CHANNEL_PARTY] = GetString(SI_CHAT_CHANNEL_NAME_PARTY),
        -- Guild - no generic names found
        [CHAT_CHANNEL_GUILD_1] = "Guild 1",
        [CHAT_CHANNEL_GUILD_2] = "Guild 2",
        [CHAT_CHANNEL_GUILD_3] = "Guild 3",
        [CHAT_CHANNEL_GUILD_4] = "Guild 4",
        [CHAT_CHANNEL_GUILD_5] = "Guild 5",
        -- Officer - no generic names found
        [CHAT_CHANNEL_OFFICER_1] = "Officer 1",
        [CHAT_CHANNEL_OFFICER_2] = "Officer 2",
        [CHAT_CHANNEL_OFFICER_3] = "Officer 3",
        [CHAT_CHANNEL_OFFICER_4] = "Officer 4",
        [CHAT_CHANNEL_OFFICER_5] = "Officer 5",

    },
    defaults = {
        debug = false,
        statistic = {
            cyrillic = 0,
            german = 0,
            french = 0,
            slavic = 0,
            nordic = 0,
            spanish = 0,
            custom = 0,
        },
        cleanCyrillic = false,
        cleanGerman = false,
        cleanFrench = false,
        cleanSlavic = false,
        cleanNordic = false,
        cleanSpanish = false,
        cleanCustom = false,
        customFilter = {},
        filterChannel = true,
        channel = {
            [CHAT_CHANNEL_SAY] = true,
            [CHAT_CHANNEL_YELL] = true,
            [CHAT_CHANNEL_EMOTE] = true,
            [CHAT_CHANNEL_WHISPER] = false,
            -- Zone
            [CHAT_CHANNEL_ZONE] = true,
            [CHAT_CHANNEL_ZONE_LANGUAGE_1] = false,
            [CHAT_CHANNEL_ZONE_LANGUAGE_2] = false,
            [CHAT_CHANNEL_ZONE_LANGUAGE_3] = false,
            [CHAT_CHANNEL_ZONE_LANGUAGE_4] = false,
            -- Party
            [CHAT_CHANNEL_PARTY] = false,
            -- Guild
            [CHAT_CHANNEL_GUILD_1] = false,
            [CHAT_CHANNEL_GUILD_2] = false,
            [CHAT_CHANNEL_GUILD_3] = false,
            [CHAT_CHANNEL_GUILD_4] = false,
            [CHAT_CHANNEL_GUILD_5] = false,
            -- Officer
            [CHAT_CHANNEL_OFFICER_1] = false,
            [CHAT_CHANNEL_OFFICER_2] = false,
            [CHAT_CHANNEL_OFFICER_3] = false,
            [CHAT_CHANNEL_OFFICER_4] = false,
            [CHAT_CHANNEL_OFFICER_5] = false,
        }
    },
}

local alphabet = {
    tooltip = {
        cyrillic = {
            "б", "г", "д", "ж", "з", "и", "й", "к", "л", "н", "У", "ф", "ц", "ч", "ш", "щ", "ъ", "ы", "э", "ю", "я"
        },
        german = {
            "ä", "ö", "ü", "ß"
        },
        french = {
            "à", "â", "é", "ê", "ë", "ï", "î", "ô", "œ", "ù", "û", "ÿ"
        },
        slavic = {
            "ł", "ą", "ć", "ś", "ę", "ż"
        },
        nordic = {
            "ø", "å"
        },
        spanish = {
            "á", "í", "ó", "ú", "ñ", "¿", "¡"
        }
    },
    --[[ not implemented for now
    regex = {
        cyrillic    = "[бгджзийклнУфцчшщъыэюя]",
        german      = "[äöüß]",
        french      = "[àâéêëïîôœùûÿ]",
        slavic      = "[łąćśęż]",
        nordic      = "[øå]",
        spanish     = "[áíóúñ¿¡]"
    }
    ]]--
}

local LAM = LibAddonMenu2
local Log

--- Debug output to the console
--- @param ... string variable parameters to be printed as a debug log
local function Debug(...)
    if Log then
        Log:Debug(...)
    else
        d(...)
    end
end

--- Output to the console
--- @param ... string variable parameters to be printed as a log
local function Print(...)
    if Log then
        Log:Info(...)
    else
        CHAT_SYSTEM:AddMessage(...)
    end
end

--- Warning output to the console
--- @param ... string variable parameters to be printed as a log
local function Warn(...)
    if Log then
        Log:Warn(...)
    else
        for i = 1, select("#", ...) do
            -- Print each warning parameter in orange
            CHAT_SYSTEM:AddMessage(zo_strformat("|cFF7900<<1>>|r", select(i, ...)))
        end
    end
end

--- Function to check a message for a pattern
--- @param message string text to be checked
--- @param characters table of characters as pattern
--- @return boolean if pattern was found in message
local function Check(message, characters)
    for _, letter in ipairs(characters) do
        if string.find(string.lower(message), string.lower(letter)) then return true end
    end
    return false
    -- Issue: string.find(string.lower("ö"), "[ж]") is not nil among others when testing
    -- return string.find(string.lower(message), pattern) ~= nil
end

--- Test if message contains letters known to be common in cyrillic languages
---@param message string to be filtered
function CleanMyChat.IsCyrillic(message)
    return Check(message, alphabet.tooltip.cyrillic)
end

--- Test if message contains letters known to be common in German
---@param message string to be filtered
function CleanMyChat.IsGerman(message)
    return Check(message, alphabet.tooltip.german)
end

--- Test if message contains letters known to be common in French
---@param message string to be filtered
function CleanMyChat.IsFrench(message)
    return Check(message, alphabet.tooltip.french)
end

--- Test if message contains letters known to be common in Slavic
--- since 1.1.0
---@param message string to be filtered
function CleanMyChat.IsSlavic(message)
    return Check(message, alphabet.tooltip.slavic)
end

--- Test if message contains letters known to be common in Nordic
------ since 1.2.0
---@param message string to be filtered
function CleanMyChat.IsNordic(message)
    return Check(message, alphabet.tooltip.nordic)
end

--- Test if message contains letters known to be common in Spanish
------ since 1.2.0
---@param message string to be filtered
function CleanMyChat.IsSpanish(message)
    return Check(message, alphabet.tooltip.spanish)
end

--- Test if message contains letters previous defined in the custom filter
---@param message string to be filtered
function CleanMyChat:IsCustom(message)
    return Check(message, self.saved.customFilter)
end

--- Will check a chat event formatter, if it should be removed based on the set filter
--- @param messageType number channel
--- @param fromName string name of the account it is send from
--- @param text string message
--- @param isFromCustomerService boolean if the message is from a customer service agent
--- @param fromDisplayName string name of the character it is send from
--- @return boolean if the message should be filtered out
function CleanMyChat:MessageNeedsToBeRemoved(messageType, fromName, text, isFromCustomerService, fromDisplayName)
    -- never filter messages from customer service
    if isFromCustomerService then return false end

    local shouldBeFiltered = self.saved.channel[messageType]

    if self.saved.debug then
        local channelName = self.channelNames[messageType] or "System or World"
        Debug(zo_strformat("Broadcast on channel <<1>>::<<2>>", messageType, channelName))
        if shouldBeFiltered then
            Debug("Set to be filtered")
        else
            Debug("Is not set to be filtered")
        end
    end

    if self.saved.filterChannel and not shouldBeFiltered then return false end

    local name = zo_strformat("<<1>>", fromName)
    local message = zo_strformat("<<1>>", text)
    local displayName = zo_strformat("<<1>>", fromDisplayName)

    local removeCyrillicMessage = self.saved.cleanCyrillic and self.IsCyrillic(message)
    local removeGermanMessage = self.saved.cleanGerman and self.IsGerman(message)
    local removeFrenchMessage = self.saved.cleanFrench and self.IsFrench(message)
    local removeSlavicMessage = self.saved.cleanSlavic and self.IsSlavic(message)
    local removeNordicMessage = self.saved.cleanNordic and self.IsNordic(message)
    local removeSpanishMessage = self.saved.cleanSpanish and self.IsSpanish(message)
    local removeCustomMessage = self.saved.cleanCustom and self:IsCustom(message)
    local removeMessage = removeCyrillicMessage or removeGermanMessage or removeFrenchMessage
            or removeSlavicMessage or removeNordicMessage or removeSpanishMessage
            or removeCustomMessage

    local found = {}
    if removeCyrillicMessage then
        self.saved.statistic.cyrillic = self.saved.statistic.cyrillic + 1
        table.insert(found, "Cyrillic")
    end
    if removeGermanMessage then
        self.saved.statistic.german = self.saved.statistic.german + 1
        table.insert(found, "German")
    end
    if removeFrenchMessage then
        self.saved.statistic.french = self.saved.statistic.french + 1
        table.insert(found, "French")
    end
    if removeSlavicMessage then
        self.saved.statistic.slavic = self.saved.statistic.slavic + 1
        table.insert(found, "Slavic")
    end
    if removeNordicMessage then
        self.saved.statistic.nordic = self.saved.statistic.nordic + 1
        table.insert(found, "Nordic")
    end
    if removeSpanishMessage then
        self.saved.statistic.spanish = self.saved.statistic.spanish + 1
        table.insert(found, "Spanish")
    end
    if removeCustomMessage then
        self.saved.statistic.custom = self.saved.statistic.custom + 1
        table.insert(found, "Custom")
    end

    if self.saved.debug then
        if removeMessage then
            Debug(tostring(message))
            Warn(zo_strformat(
                    "Found <<1>> characters in the message.\nIt will be removed if it was not from you.",
                    ZO_GenerateCommaSeparatedList(found)
                )
            )
        end
    end

    -- Don't filter your own message
    if removeMessage and (GetUnitName("player") == name or GetDisplayName() == displayName) then
        Warn(zo_strformat("You just wrote with filtered <<1>> characters.\n"
                .. "You might not see responses.\n"
                .."Maybe you want to unset the filter of the language you just used...\n"
                .. "Write /cmc to open the settings menu.",
                ZO_GenerateCommaSeparatedList(found)
        ))
        removeMessage = false
    end

    return removeMessage
end

--- Register filter for chat event
function CleanMyChat:RegisterEvent()
    if self.saved.debug then
        Debug("Register for chat event")
    end

    -- Disable the whisper flash because of insecure code error
    -- ZO_ChatSystem.OnFormattedChatMessage = nil

    -- alternative: CHAT_ROUTER.registeredEventHandlers
    local ZO_EventHandlers = CHAT_ROUTER:GetRegisteredMessageFormatters()

    ZO_PreHook(ZO_EventHandlers, EVENT_CHAT_MESSAGE_CHANNEL, function(...)
        return self:MessageNeedsToBeRemoved(...)
    end)
end

--- Register filter for pChat addon
function CleanMyChat:RegisterPChat()
    if self.saved.debug then
        Debug("Register for pChat")
    end
    -- Function intercepts pChat FormatMessage (3457) and mimics its spam detection (Hook code from Baertram@ESOUI)
    ZO_PreHook(pChat, "FormatMessage", function(...)
        return self:MessageNeedsToBeRemoved(...)
    end)
end

--- Create menu in LibAddonMenu2 settings if available
function CleanMyChat:RegisterSettings()
    local lang = GetCVar("Language.2")
    local link = zo_strformat("https://<<1>>.liberapay.com/Tyx/", lang)
    local panel = {
        type = "panel",
        name = self.name,
        displayName = self.displayName,
        author = zo_strformat("|c5175ea<<1>>|r", self.author),
        version = self.version,
        website = "https://www.esoui.com/downloads/info2544-CleanMyChat.html",
        feedback = "https://github.com/Tyxz/Clean-My-Chat/issues/new/choose",
        donation = link,
        --slashCommand = "/cmc",
        registerForRefresh = true,
        registerForDefaults = true,
        resetFunc = function()
            for k,v in pairs(self.defaults) do
                if type(v) == "table" then
                    for j, z in pairs(v) do
                        self.saved[k][j] = z
                    end
                else
                    self.saved[k] = v
                end
            end
        end,
    }

    if LAM then
        CLEAN_MY_CHAT_PANEL = LAM:RegisterAddonPanel(self.name, panel)

        local controls = setmetatable({}, {__index = table})
        for handler, name in pairs(self.channelNames) do
            if handler ~=CHAT_CHANNEL_WHISPER_SENT then
                controls:insert({
                    type = "checkbox",
                    name = name,
                    getFunc = function() return self.saved.channel[handler] end,
                    setFunc = function(value) self.saved.channel[handler] = value end
                })
            end
        end

        local data = {
            {
                type = "description",
                name = "Statistic",
                text = function()
                    local statistic = setmetatable({}, {__index = table})
                    for k,v in pairs(self.saved.statistic) do
                        if self.saved[zo_strformat("clean<<C:1>>", k)] then
                            statistic:insert(zo_strformat("<<1>> <<C:2>>", v, k))
                        end
                    end
                    local str = ""
                    if #statistic ~= 0 then
                        str = " messages blocked."
                    end
                    return zo_strformat("<<1>><<2>>", ZO_GenerateCommaSeparatedList(statistic), str)
                end
            },
            {
                type = "checkbox",
                name = "Clean Cyrillic",
                tooltip = ZO_GenerateCommaSeparatedList(alphabet.tooltip.cyrillic),
                getFunc = function() return self.saved.cleanCyrillic end,
                setFunc = function(value) self.saved.cleanCyrillic = value end
            },
            {
                type = "checkbox",
                name = "Clean French",
                tooltip = ZO_GenerateCommaSeparatedList(alphabet.tooltip.french),
                getFunc = function() return self.saved.cleanFrench end,
                setFunc = function(value) self.saved.cleanFrench = value end
            },
            {
                type = "checkbox",
                name = "Clean German",
                tooltip = ZO_GenerateCommaSeparatedList(alphabet.tooltip.german),
                getFunc = function() return self.saved.cleanGerman end,
                setFunc = function(value) self.saved.cleanGerman = value end
            },
            {
                type = "checkbox",
                name = "Clean Nordic",
                tooltip = ZO_GenerateCommaSeparatedList(alphabet.tooltip.nordic),
                getFunc = function() return self.saved.cleanNordic end,
                setFunc = function(value) self.saved.cleanNordic = value end
            },
            {
                type = "checkbox",
                name = "Clean Slavic",
                tooltip = ZO_GenerateCommaSeparatedList(alphabet.tooltip.slavic),
                getFunc = function() return self.saved.cleanSlavic end,
                setFunc = function(value) self.saved.cleanSlavic = value end
            },
            {
                type = "checkbox",
                name = "Clean Spanish",
                tooltip = ZO_GenerateCommaSeparatedList(alphabet.tooltip.spanish),
                getFunc = function() return self.saved.cleanSpanish end,
                setFunc = function(value) self.saved.cleanSpanish = value end
            },
            {
                type = "checkbox",
                name = "Clean Custom",
                tooltip = ZO_GenerateCommaSeparatedList(self.saved.customFilter),
                disabled = function() return self.saved.customFilter == {} end,
                getFunc = function() return self.saved.cleanCustom end,
                setFunc = function(value) self.saved.cleanCustom = value end,
                reference = "CLEAN_MY_CHAT_CHECKBOX_CLEAN_CUSTOM"
            },
            {
                type = "editbox",
                name = "Custom filter - one word or character separated with a ',' ",
                isMultiline = true,
                isExtraWide = true,
                getFunc = function() return table.concat(self.saved.customFilter, ", ") end,
                setFunc = function(value)
                    self.saved.customFilter = {}
                    local filter = string.gsub(value, "[ ,;\n\t]+", " ")
                    for i in string.gmatch(filter, "%S+") do
                        if i ~= "" then
                            table.insert(self.saved.customFilter, i)
                        end
                    end
                    LAM.util.RegisterForRefreshIfNeeded(CLEAN_MY_CHAT_CHECKBOX_CLEAN_CUSTOM)
                    CLEAN_MY_CHAT_PANEL:RefreshPanel()
                end
            },
            {
                type = "checkbox",
                name = "Filter channel",
                tooltip = "Filter only specific channels",
                getFunc = function() return self.saved.filterChannel end,
                setFunc = function(value) self.saved.filterChannel = value end
            },
            {
                type = "submenu",
                name = "Channels",
                controls = controls,
                disabled = function() return not self.saved.filterChannel end,
            },
            {
                type = "checkbox",
                name = "Debug",
                getFunc = function() return self.saved.debug end,
                setFunc = function(value)
                    local str
                    if value then
                        str = "enabled"
                    else
                        str = "disabled"
                    end
                    Debug(zo_strformat("Debug output <<1>>.",  str))
                    self.saved.debug = value
                end
            },
        }
        LAM:RegisterOptionControls(self.name, data)

        if LibFeedback then
            local buttons = setmetatable(
            {
                { panel.feedback, "Report an issue", false },
            }, {__index = table})
            local worldName = GetWorldName()
            if worldName == "EU Megaserver" then
                buttons:insert({ 0, "In-game Feedback", false })
                buttons:insert({ 5000, "Small donation", true })
                buttons:insert({ 50000, "Larger donation", true })
            end
            buttons:insert({ panel.donation, "Real donation", false })
            return LibFeedback:initializeFeedbackWindow(
                    self,
                    self.displayName,
                    CLEAN_MY_CHAT_PANEL,
                    self.author,
                    {12 , CLEAN_MY_CHAT_PANEL, 12 , -20, 20}, -- Anchor
                    buttons,
                    "If you found a bug, have a request or a suggestion, or simply wish to donate,\n"
                    .. "you are welcome to send me an email."
            )
        end
    end
end

--- Funtion to convert a table into a string
--- @param object any to be converted to string
--- @param[opt] tabs number of seperators befor the object
function CleanMyChat.TableToString(object, tabs)
    if not tabs then tabs = 0 end
    local out = ""
    local sep = "."
    if type(object) == 'table' then
        for k,v in pairs(object) do
            out = zo_strformat("<<1>><<2>> ", out, sep:rep(tabs))
            if k ~= "version" then
                if type(k) == "number" then
                    k = CleanMyChat.channelNames[k]
                end
                if type(v) == "table" and next(v) then
                    out = zo_strformat("<<1>><<2>>:\n<<3>>", out, k, CleanMyChat.TableToString(v, tabs + 1))
                elseif type(v) ~= "table" then
                    out = zo_strformat("<<1>><<2>>: <<3>>", out, k, CleanMyChat.TableToString(v))
                end
            end
        end
        return out
    elseif type(object) == "boolean" then
        if object then
            out = "true"
        else
            out = "false"
        end
    else
        out = tostring(object)
    end
    return zo_strformat("<<1>>\n", out)
end

--- Register slash commands
function CleanMyChat:RegisterCommands()
    SLASH_COMMANDS["/cmc"] = function(...)
        local command = string.lower(select(1, ...))
        if select("#", ...) == 1 and command == "" then
            if LAM then
                LAM:OpenToPanel(CLEAN_MY_CHAT_PANEL)
            else
                Print(CleanMyChat.TableToString(getmetatable(self.saved).__index))
            end
        else
            local str = "enabled"
            if command == "filter" then
                if next(self.saved.customFilter) then
                    Print(zo_strformat("Custom filter:\n\t<<1>>.",
                        ZO_GenerateCommaSeparatedList(self.saved.customFilter)))
                else
                    Print("No custom filter were found.")
                end
            elseif command == "channel" then
                self.saved.filterChannel = not self.saved.filterChannel
                if not self.saved.filterChannel then
                    str = "disabled"
                end
                Print(zo_strformat("Channel filter is <<1>>.", str))
            elseif command == "cyrillic" then
                self.saved.cleanCyrillic = not self.saved.cleanCyrillic
                if not self.saved.cleanCyrillic then
                    str = "disabled"
                end
                Print(zo_strformat("Cyrillic filter is <<1>>.", str))
            elseif command == "german" then
                self.saved.cleanGerman = not self.saved.cleanGerman
                if not self.saved.cleanGerman then
                    str = "disabled"
                end
                Print(zo_strformat("German filter is <<1>>.", str))
            elseif command == "french" then
                self.saved.cleanFrench = not self.saved.cleanFrench
                if not self.saved.cleanFrench then
                    str = "disabled"
                end
                Print(zo_strformat("French filter is <<1>>.", str))
            elseif command == "slavic" then
                self.saved.cleanSlavic = not self.saved.cleanSlavic
                if not self.saved.cleanSlavic then
                    str = "disabled"
                end
                Print(zo_strformat("Slavic filter is <<1>>.", str))
            elseif command == "nordic" then
                self.saved.cleanNordic = not self.saved.cleanNordic
                if not self.saved.cleanNordic then
                    str = "disabled"
                end
                Print(zo_strformat("Nordic filter is <<1>>.", str))
            elseif command == "spanish" then
                self.saved.cleanSpanish = not self.saved.cleanSpanish
                if not self.saved.cleanSpanish then
                    str = "disabled"
                end
                Print(zo_strformat("Spanish filter is <<1>>.", str))
            elseif command == "custom" then
                self.saved.cleanCustom = not self.saved.cleanCustom
                if not self.saved.cleanCustom then
                    str = "disabled"
                end
                Print(zo_strformat("Custom filter is <<1>>.", str))
            elseif command == "debug" then
                self.saved.debug = not self.saved.debug
                if not self.saved.debug then
                    str = "disabled"
                end
                Print(zo_strformat("Debug output is <<1>>.", str))
            end
        end
    end
end

--- Function to migrate saved variables without resetting them
function CleanMyChat:Migrate()
    -- Version is 1.0.0
    if not self.saved.lastVersion then
        self.saved.channel = {}
        for i, v in pairs(self.defaults.channel) do
            self.saved.channel[i] = v
        end
        self.saved.statistic = {}
        for k, v in pairs(self.defaults.statistic) do
            self.saved.statistic[k] = v
        end
        self.saved.lastVersion = {
            major = 1,
            minor = 0
        }
    end
    local currentVersion = self:GetVersion()
    local lastVersion = self.saved.lastVersion
    if lastVersion.major < currentVersion.major or lastVersion.minor < currentVersion.minor then
        if self.saved.debug then
            Debug(zo_strformat("Migrate from <<1>>.<<2>> to <<3>>",
                    lastVersion.major, lastVersion.minor, self.version))
        end
    end
    self.saved.lastVersion = currentVersion
end

--- Function to get the current version as a number table
--- @return table current version as numbers
function CleanMyChat:GetVersion()
    local major, minor, patch = string.match(self.version, "(%d+).(%d+).(%d+)")
    major, minor, patch = tonumber(major), tonumber(minor), tonumber(patch)
    return { major = major, minor = minor, patch = patch }
end

--- Initialize functions
--- @return table CleanMyChat instance
function CleanMyChat:Initialize()
    if LibDebugLogger then
        Log = LibDebugLogger(self.name)
    end

    local CMC = setmetatable ({}, self)
    local mt = getmetatable (CMC)
    mt.__index = self

    CMC.saved = ZO_SavedVars:NewAccountWide(CMC.name .. "_Settings", CMC.savedVersion, nil, CMC.defaults)

    CMC:Migrate()
    CMC:RegisterSettings()
    CMC:RegisterCommands()
    if pChat then
        CMC:RegisterPChat()
    else
        CMC:RegisterEvent()
    end

    return CMC
end

--Register Loaded Callback
EVENT_MANAGER:RegisterForEvent(
        CleanMyChat.name, EVENT_ADD_ON_LOADED,
        function(_, addOnName)
            if(addOnName ~= CleanMyChat.name) then return end
            CleanMyChat:Initialize()
        end
)
