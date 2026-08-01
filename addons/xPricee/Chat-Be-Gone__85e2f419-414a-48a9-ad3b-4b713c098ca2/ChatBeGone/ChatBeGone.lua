-- Chat Be Gone v1.1.4.3
-- Super lightweight ESO console-first chat cleanup add-on.
-- Safe scope: local UI chat suppression, timestamps/colors, and chat filtering only.
-- No chat-box movement, no chat-window layout changes, no protected UI scanning, no chat sending, no gameplay automation.

local ADDON_NAME = "ChatBeGone"
local DISPLAY_NAME = "Chat Be Gone"
local VERSION = "1.1.4.3"
local SAVED_VARS = "ChatBeGoneSavedVariables"
local SV_VERSION = 1

ChatBeGone = ChatBeGone or {}
local CBG = ChatBeGone

CBG.name = ADDON_NAME
CBG.displayName = DISPLAY_NAME
CBG.version = VERSION
CBG.hookInstalled = false
CBG.formatterInstalled = false
CBG.eventWatcherInstalled = false
CBG.guildRefreshEventsInstalled = false
CBG.lamRegistered = false
CBG.playerActivated = false
CBG.suppressedCount = 0
CBG.lastChatEvent = "None"
CBG.lastChatHook = "Not installed"
CBG.debugMode = false
CBG.guildNames = {}
CBG.guildIds = {}
CBG.lastSelfChannelType = nil
CBG.pendingMenuSection = nil
CBG.resetConfirm = nil
CBG.resetConfirmKeybinds = nil
CBG.lastDetectedInputChannel = nil
CBG.modalKeybindStackDepth = 0
CBG.settingsDirtyCount = 0
CBG._persistingSettings = false

local DEFAULT_COLORS = {
    whisperIn = "FF66FF",
    whisperOut = "FF99CC",
    guild = { "00FF66", "33CCFF", "FFD700", "CC66FF", "FF9966" },
    officer = { "66FFCC", "66CCFF", "FFFF66", "DD99FF", "FFCC99" },
}

local DEFAULTS = {
    enabled = true,
    filterEnabled = true,
    safeMode = false,
    timestampEnabled = false,
    filterGuildAds = false,
    filterPlusMessages = false,
    filterTradeMessages = false,
    suppressZoneChat = false,
    muteDurationZone = "Indefinite",
    muteUntilZone = 0,
    hideGuild = { false, false, false, false, false },
    hideOfficer = { false, false, false, false, false },
    muteDurationGuild = { "Indefinite", "Indefinite", "Indefinite", "Indefinite", "Indefinite" },
    muteDurationOfficer = { "Indefinite", "Indefinite", "Indefinite", "Indefinite", "Indefinite" },
    muteUntilGuild = { 0, 0, 0, 0, 0 },
    muteUntilOfficer = { 0, 0, 0, 0, 0 },
    colorsEnabled = true,
    colorWhisperIn = DEFAULT_COLORS.whisperIn,
    colorWhisperOut = DEFAULT_COLORS.whisperOut,
    colorGuild = { DEFAULT_COLORS.guild[1], DEFAULT_COLORS.guild[2], DEFAULT_COLORS.guild[3], DEFAULT_COLORS.guild[4], DEFAULT_COLORS.guild[5] },
    colorOfficer = { DEFAULT_COLORS.officer[1], DEFAULT_COLORS.officer[2], DEFAULT_COLORS.officer[3], DEFAULT_COLORS.officer[4], DEFAULT_COLORS.officer[5] },
    notifications = {
        master = true,
        muteStarted = true,
        muteExpired = true,
        timerStatus = true,
        filterStatus = true,
        reset = true,
        status = true,
    },
}

local MUTE_CHOICES = { "10 minutes", "30 minutes", "1 hour", "3 hours", "6 hours", "12 hours", "24 hours", "Indefinite" }
local MUTE_SECONDS = {
    ["10 minutes"] = 10 * 60,
    ["30 minutes"] = 30 * 60,
    ["1 hour"] = 60 * 60,
    ["3 hours"] = 3 * 60 * 60,
    ["6 hours"] = 6 * 60 * 60,
    ["12 hours"] = 12 * 60 * 60,
    ["24 hours"] = 24 * 60 * 60,
    ["Indefinite"] = 0,
}

local ZONE_CHANNEL_CONSTANT_NAMES = {
    "CHAT_CHANNEL_ZONE",
    "CHAT_CHANNEL_ZONE_LANGUAGE_1",
    "CHAT_CHANNEL_ZONE_LANGUAGE_2",
    "CHAT_CHANNEL_ZONE_LANGUAGE_3",
    "CHAT_CHANNEL_ZONE_ENGLISH",
    "CHAT_CHANNEL_ZONE_FRENCH",
    "CHAT_CHANNEL_ZONE_GERMAN",
    "CHAT_CHANNEL_ZONE_JAPANESE",
    "CHAT_CHANNEL_ZONE_RUSSIAN",
    "CHAT_CHANNEL_ZONE_SPANISH",
    "CHAT_CHANNEL_ZONE_CHINESE_S",
}

local function BoolText(value)
    return value and "ON" or "OFF"
end

local function StateText(value)
    return value and "|c00FF00ON|r" or "|cFF3333OFF|r"
end

local function FormatBoolOption(label, value)
    return tostring(label or "Option") .. ": " .. StateText(value)
end

local function ShouldNotify(category, force)
    if force then return true end
    local sv = CBG and CBG.sv
    if not sv or type(sv.notifications) ~= "table" then return true end
    if sv.notifications.master == false then return false end
    category = tostring(category or "status")
    if sv.notifications[category] == false then return false end
    return true
end

local function SafeD(message, category, force)
    if d and ShouldNotify(category, force) then
        d(string.format("|c00BFFF%s|r %s", DISPLAY_NAME, tostring(message)))
    end
end

local function RequestMenuRefresh()
    -- Every settings/UI change passes through here, so keep the SavedVariables snapshot current before refreshing labels.
    if CBG and type(CBG.PersistSettings) == "function" then
        CBG:PersistSettings("setting changed")
    end
    -- Best-effort live refresh for dynamic ON/OFF labels. Safe no-op if the active settings library does not expose refresh callbacks.
    if CALLBACK_MANAGER then
        pcall(function() CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", "ChatBeGoneOptions") end)
        pcall(function() CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", DISPLAY_NAME) end)
    end
    if LibAddonMenu2 and LibAddonMenu2.util and LibAddonMenu2.util.RequestRefreshIfNeeded then
        pcall(function() LibAddonMenu2.util.RequestRefreshIfNeeded("ChatBeGoneOptions") end)
    end
end

local function SetAndRefresh(setter)
    if type(setter) == "function" then setter() end
    RequestMenuRefresh()
end

local function CloneTable(source)
    local out = {}
    if type(source) ~= "table" then return out end
    for k, v in pairs(source) do
        if type(v) == "table" then out[k] = CloneTable(v) else out[k] = v end
    end
    return out
end

local function CloneDefaults()
    return CloneTable(DEFAULTS)
end

local function ClampNumber(value, minValue, maxValue, fallback)
    value = tonumber(value)
    if value == nil then return fallback end
    if value < minValue then return minValue end
    if value > maxValue then return maxValue end
    return value
end


local function SanitizeHex(hex, fallback)
    hex = tostring(hex or "")
    hex = string.upper(string.gsub(hex, "[^0-9A-Fa-f]", ""))
    if string.len(hex) == 6 then return hex end
    return fallback or "FFFFFF"
end

local function HexToRgb(hex)
    hex = SanitizeHex(hex, "FFFFFF")
    local r = tonumber(string.sub(hex, 1, 2), 16) or 255
    local g = tonumber(string.sub(hex, 3, 4), 16) or 255
    local b = tonumber(string.sub(hex, 5, 6), 16) or 255
    return r / 255, g / 255, b / 255, 1
end

local function RgbToHex(r, g, b)
    r = ClampNumber(math.floor((tonumber(r) or 1) * 255 + 0.5), 0, 255, 255)
    g = ClampNumber(math.floor((tonumber(g) or 1) * 255 + 0.5), 0, 255, 255)
    b = ClampNumber(math.floor((tonumber(b) or 1) * 255 + 0.5), 0, 255, 255)
    return string.format("%02X%02X%02X", r, g, b)
end

local function Colorize(text, hex)
    hex = SanitizeHex(hex, nil)
    if not hex then return tostring(text or "") end
    return "|c" .. hex .. tostring(text or "") .. "|r"
end

local function SetReadableFont(label, preferred, fallback)
    if not label or not label.SetFont then return end
    if preferred then
        local ok = pcall(function() label:SetFont(preferred) end)
        if ok then return end
    end
    if fallback then pcall(function() label:SetFont(fallback) end) end
end

local function PlainText(text)
    text = tostring(text or "")
    text = string.gsub(text, "|c%x%x%x%x%x%x", "")
    text = string.gsub(text, "|r", "")
    text = string.gsub(text, "|H.-|h(.-)|h", "%1")
    return text
end

local function LowerPlain(text)
    return string.lower(PlainText(text or ""))
end

local function Trim(text)
    text = tostring(text or "")
    text = string.gsub(text, "^%s+", "")
    text = string.gsub(text, "%s+$", "")
    return text
end

local function ShortenText(text, maxLen)
    text = tostring(text or "")
    maxLen = tonumber(maxLen) or 28
    if string.len(text) <= maxLen then return text end
    if maxLen <= 3 then return string.sub(text, 1, maxLen) end
    return string.sub(text, 1, maxLen - 3) .. "..."
end

local function GetClockText()
    local stamp = nil
    if GetTimeStamp then
        local ok, value = pcall(GetTimeStamp)
        if ok and value then stamp = value end
    end
    if stamp and os and os.date then
        local ok, value = pcall(function() return os.date("%I:%M%p", stamp) end)
        if ok and value then return string.gsub(value, "^0", "") end
    end
    if os and os.date then
        local ok, value = pcall(function() return os.date("%I:%M%p") end)
        if ok and value then return string.gsub(value, "^0", "") end
    end
    if GetTimeString then
        local ok, value = pcall(GetTimeString)
        if ok and value then return tostring(value) end
    end
    return "--:--"
end

local function GetNow()
    if GetTimeStamp then
        local ok, value = pcall(GetTimeStamp)
        if ok and tonumber(value) then return tonumber(value) end
    end
    if os and os.time then return os.time() end
    return 0
end

local function GetConstant(name)
    return _G and _G[name] or nil
end

local function GetGuildConstant(index)
    return GetConstant("CHAT_CHANNEL_GUILD_" .. tostring(index))
end

local function GetOfficerConstant(index)
    return GetConstant("CHAT_CHANNEL_OFFICER_" .. tostring(index))
end

local function IsZoneChannel(channelType)
    for _, constantName in ipairs(ZONE_CHANNEL_CONSTANT_NAMES) do
        local constant = GetConstant(constantName)
        if constant ~= nil and channelType == constant then return true end
    end
    return false
end

local function IsWhisperIncoming(channelType)
    return (GetConstant("CHAT_CHANNEL_WHISPER") ~= nil and channelType == GetConstant("CHAT_CHANNEL_WHISPER"))
        or (GetConstant("CHAT_CHANNEL_WHISPER_NPC") ~= nil and channelType == GetConstant("CHAT_CHANNEL_WHISPER_NPC"))
end

local function IsWhisperOutgoing(channelType)
    return (GetConstant("CHAT_CHANNEL_WHISPER_SENT") ~= nil and channelType == GetConstant("CHAT_CHANNEL_WHISPER_SENT"))
        or (GetConstant("CHAT_CHANNEL_WHISPER_INFORM") ~= nil and channelType == GetConstant("CHAT_CHANNEL_WHISPER_INFORM"))
end

local function IsLikelyChannelNumber(value)
    return type(value) == "number"
end

local function ExtractChatArgsFromRouter(eventKey, ...)
    if EVENT_CHAT_MESSAGE_CHANNEL ~= nil and eventKey ~= EVENT_CHAT_MESSAGE_CHANNEL then return nil end
    local a1, a2, a3, a4, a5, a6 = ...

    -- Modern chat router shape: FormatAndAddChatMessage(eventKey, eventCategory, channelType, fromName, text, ...)
    if IsLikelyChannelNumber(a2) and type(a3) == "string" then
        return a2, a3, a4, a1, a5, a6
    end

    -- Older/simple shape: FormatAndAddChatMessage(eventKey, channelType, fromName, text, ...)
    if IsLikelyChannelNumber(a1) and type(a2) == "string" then
        return a1, a2, a3, nil, a4, a5
    end

    return nil
end

local function ExtractChatArgsFromFormatter(...)
    local a1, a2, a3, a4, a5, a6 = ...
    if IsLikelyChannelNumber(a2) and type(a3) == "string" then
        return a2, a3, a4, a1, a5, a6
    end
    if IsLikelyChannelNumber(a1) and type(a2) == "string" then
        return a1, a2, a3, nil, a4, a5
    end
    return nil
end


local function UnpackTable(values)
    local unpackFn = unpack or (table and table.unpack)
    if unpackFn then return unpackFn(values) end
    return values[1], values[2], values[3], values[4], values[5], values[6], values[7], values[8]
end

local function CleanGuildName(name)
    if type(name) ~= "string" or name == "" then return nil end
    local out = name
    if zo_strformat then
        local ok, formatted = pcall(function() return zo_strformat("<<1>>", name) end)
        if ok and type(formatted) == "string" and formatted ~= "" then out = formatted end
    end
    out = Trim(PlainText(out))
    if out == "" then return nil end
    return out
end

local function EnsureArray(source, defaults)
    if type(source) ~= "table" then source = {} end
    for i = 1, #defaults do
        if source[i] == nil then source[i] = defaults[i] end
    end
    return source
end

local function NormalizeMuteChoice(value)
    value = tostring(value or "")
    for _, choice in ipairs(MUTE_CHOICES) do
        if value == choice then return choice end
    end
    return "Indefinite"
end

local function GetDurationSeconds(choice)
    choice = NormalizeMuteChoice(choice)
    return MUTE_SECONDS[choice] or 0
end

local function FormatRemaining(untilStamp)
    untilStamp = tonumber(untilStamp) or 0
    if untilStamp <= 0 then return "Indefinite" end
    local remaining = untilStamp - GetNow()
    if remaining <= 0 then return "Expired" end
    local hours = math.floor(remaining / 3600)
    local minutes = math.floor((remaining % 3600) / 60)
    if hours > 0 then
        if minutes > 0 then return string.format("%d hour%s %d minute%s", hours, hours == 1 and "" or "s", minutes, minutes == 1 and "" or "s") end
        return string.format("%d hour%s", hours, hours == 1 and "" or "s")
    end
    minutes = math.max(minutes, 1)
    return string.format("%d minute%s", minutes, minutes == 1 and "" or "s")
end

local function FormatClockAt(untilStamp)
    untilStamp = tonumber(untilStamp) or 0
    if untilStamp <= 0 then return "never" end
    if os and os.date then
        local ok, value = pcall(function() return os.date("%I:%M %p", untilStamp) end)
        if ok and value then return string.gsub(value, "^0", "") end
    end
    return "the scheduled time"
end

local function FormatMuteLine(label, untilStamp)
    untilStamp = tonumber(untilStamp) or 0
    if untilStamp > 0 then
        return string.format('"%s" is muted. Time left: %s. Unmutes at %s.', tostring(label), FormatRemaining(untilStamp), FormatClockAt(untilStamp))
    end
    return string.format('"%s" is muted indefinitely.', tostring(label))
end

local function IsSelfSender(fromName)
    local sender = LowerPlain(fromName or "")
    sender = string.gsub(sender, "^@", "")
    sender = Trim(sender)
    if sender == "" then return false end

    local candidates = {}
    if GetDisplayName then
        local ok, value = pcall(GetDisplayName)
        if ok and value then table.insert(candidates, value) end
    end
    if GetUnitDisplayName then
        local ok, value = pcall(function() return GetUnitDisplayName("player") end)
        if ok and value then table.insert(candidates, value) end
    end
    if GetUnitName then
        local ok, value = pcall(function() return GetUnitName("player") end)
        if ok and value then table.insert(candidates, value) end
    end

    for _, candidate in ipairs(candidates) do
        local clean = LowerPlain(candidate or "")
        clean = string.gsub(clean, "^@", "")
        clean = Trim(clean)
        if clean ~= "" and clean == sender then return true end
    end
    return false
end

function CBG:RefreshGuildNames()
    self.guildNames = self.guildNames or {}
    self.guildIds = self.guildIds or {}

    for i = 1, 5 do
        local guildId = nil
        local guildName = nil
        if GetGuildId then
            local ok, result = pcall(function() return GetGuildId(i) end)
            if ok then guildId = result end
        end
        if guildId ~= nil and guildId ~= 0 and GetGuildName then
            local ok, result = pcall(function() return GetGuildName(guildId) end)
            if ok then guildName = CleanGuildName(result) end
        end
        self.guildIds[i] = guildId
        self.guildNames[i] = guildName
    end
end

function CBG:GetJoinedGuildCount()
    if GetNumGuilds then
        local ok, result = pcall(GetNumGuilds)
        if ok and tonumber(result) then return tonumber(result) end
    end
    local count = 0
    for i = 1, 5 do
        if self.guildNames and self.guildNames[i] then count = count + 1 end
    end
    return count
end

function CBG:HasAnyGuildName()
    for i = 1, 5 do
        if self.guildNames and self.guildNames[i] then return true end
    end
    return false
end

function CBG:InstallGuildRefreshEvents()
    if self.guildRefreshEventsInstalled or not EVENT_MANAGER then return end
    local installed = false
    local function register(eventName, callbackName)
        local eventId = GetConstant(eventName)
        if eventId then
            EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. callbackName, eventId, function()
                CBG:RefreshGuildNames()
                CBG:RegisterLAM()
            end)
            installed = true
        end
    end
    register("EVENT_GUILD_SELF_JOINED_GUILD", "GuildJoined")
    register("EVENT_GUILD_SELF_LEFT_GUILD", "GuildLeft")
    register("EVENT_GUILD_DATA_LOADED", "GuildDataLoaded")
    self.guildRefreshEventsInstalled = installed
end

function CBG:GetGuildBaseName(index, officer)
    local guildName = self.guildNames and self.guildNames[index]
    if guildName and guildName ~= "" then
        return officer and (guildName .. " Officer") or guildName
    end
    return officer and ("Officer " .. tostring(index)) or ("Guild " .. tostring(index))
end

function CBG:GetGuildColor(index, officer)
    if not self.sv then return officer and DEFAULT_COLORS.officer[index] or DEFAULT_COLORS.guild[index] end
    if officer then return self.sv.colorOfficer[index] or DEFAULT_COLORS.officer[index] end
    return self.sv.colorGuild[index] or DEFAULT_COLORS.guild[index]
end

function CBG:GetGuildDisplayName(index, officer, maxLen)
    local text = self:GetGuildBaseName(index, officer)
    if maxLen then text = ShortenText(text, maxLen) end
    return Colorize(text, self:GetGuildColor(index, officer))
end

function CBG:GetPlainGuildLabel(index, officer)
    return self:GetGuildBaseName(index, officer)
end

local function GetChannelInfo(channelType)
    for i = 1, 5 do
        local guildConstant = GetGuildConstant(i)
        if guildConstant ~= nil and channelType == guildConstant then return "guild", i end
        local officerConstant = GetOfficerConstant(i)
        if officerConstant ~= nil and channelType == officerConstant then return "officer", i end
    end
    if IsZoneChannel(channelType) then return "zone", nil end
    return nil, nil
end

function CBG:GetChannelLabel(channelType)
    local kind, index = GetChannelInfo(channelType)
    if kind == "guild" then return self:GetGuildDisplayName(index, false, 26) end
    if kind == "officer" then return self:GetGuildDisplayName(index, true, 26) end
    if kind == "zone" then return "Zone" end
    if IsWhisperIncoming(channelType) then return "Whisper" end
    if IsWhisperOutgoing(channelType) then return "Whisper Out" end
    return tostring(channelType or "Chat")
end

local function EnsureSettingsTables()
    if not CBG.sv then return end
    local defaults = CloneDefaults()
    for key, value in pairs(defaults) do
        if CBG.sv[key] == nil then
            if type(value) == "table" then CBG.sv[key] = CloneTable(value) else CBG.sv[key] = value end
        end
    end
    CBG.sv.hideGuild = EnsureArray(CBG.sv.hideGuild, DEFAULTS.hideGuild)
    CBG.sv.hideOfficer = EnsureArray(CBG.sv.hideOfficer, DEFAULTS.hideOfficer)
    CBG.sv.muteDurationGuild = EnsureArray(CBG.sv.muteDurationGuild, DEFAULTS.muteDurationGuild)
    CBG.sv.muteDurationOfficer = EnsureArray(CBG.sv.muteDurationOfficer, DEFAULTS.muteDurationOfficer)
    CBG.sv.muteUntilGuild = EnsureArray(CBG.sv.muteUntilGuild, DEFAULTS.muteUntilGuild)
    CBG.sv.muteUntilOfficer = EnsureArray(CBG.sv.muteUntilOfficer, DEFAULTS.muteUntilOfficer)
    CBG.sv.colorGuild = EnsureArray(CBG.sv.colorGuild, DEFAULTS.colorGuild)
    CBG.sv.colorOfficer = EnsureArray(CBG.sv.colorOfficer, DEFAULTS.colorOfficer)
    if type(CBG.sv.notifications) ~= "table" then CBG.sv.notifications = CloneTable(DEFAULTS.notifications) end
    for k, v in pairs(DEFAULTS.notifications) do
        if CBG.sv.notifications[k] == nil then CBG.sv.notifications[k] = v end
    end
    -- v1.1.4.1 removes the local message-saving feature entirely; clear old local history/settings from this add-on only.
    CBG.sv.history = nil
    CBG.sv.savedMessages = nil
    CBG.sv.notifications.savedPanel = nil
    -- v1.1.4.2 removes type-to-unmute behavior and its notification category.
    CBG.sv.notifications.autoUnmute = nil
    CBG.sv.muteDurationZone = NormalizeMuteChoice(CBG.sv.muteDurationZone)
    CBG.sv.muteUntilZone = tonumber(CBG.sv.muteUntilZone) or 0
    CBG.sv.colorWhisperIn = SanitizeHex(CBG.sv.colorWhisperIn, DEFAULTS.colorWhisperIn)
    CBG.sv.colorWhisperOut = SanitizeHex(CBG.sv.colorWhisperOut, DEFAULTS.colorWhisperOut)
    for i = 1, 5 do
        CBG.sv.colorGuild[i] = SanitizeHex(CBG.sv.colorGuild[i], DEFAULTS.colorGuild[i])
        CBG.sv.colorOfficer[i] = SanitizeHex(CBG.sv.colorOfficer[i], DEFAULTS.colorOfficer[i])
        CBG.sv.muteDurationGuild[i] = NormalizeMuteChoice(CBG.sv.muteDurationGuild[i])
        CBG.sv.muteDurationOfficer[i] = NormalizeMuteChoice(CBG.sv.muteDurationOfficer[i])
        CBG.sv.muteUntilGuild[i] = tonumber(CBG.sv.muteUntilGuild[i]) or 0
        CBG.sv.muteUntilOfficer[i] = tonumber(CBG.sv.muteUntilOfficer[i]) or 0
    end
end

local PERSISTED_SETTING_KEYS = {
    "enabled",
    "filterEnabled",
    "safeMode",
    "timestampEnabled",
    "filterGuildAds",
    "filterPlusMessages",
    "filterTradeMessages",
    "suppressZoneChat",
    "muteDurationZone",
    "muteUntilZone",
    "hideGuild",
    "hideOfficer",
    "muteDurationGuild",
    "muteDurationOfficer",
    "muteUntilGuild",
    "muteUntilOfficer",
    "colorsEnabled",
    "colorWhisperIn",
    "colorWhisperOut",
    "colorGuild",
    "colorOfficer",
    "notifications",
}

local function BuildPersistedSettingsSnapshot()
    local snapshot = {}
    if not CBG.sv then return snapshot end
    for _, key in ipairs(PERSISTED_SETTING_KEYS) do
        local value = CBG.sv[key]
        if value ~= nil then
            snapshot[key] = (type(value) == "table") and CloneTable(value) or value
        end
    end
    return snapshot
end

function CBG:RestorePersistedSettings()
    if not self.sv then return end
    local persisted = self.sv._persistedSettings
    if type(persisted) ~= "table" or type(persisted.settings) ~= "table" then return end
    for _, key in ipairs(PERSISTED_SETTING_KEYS) do
        local value = persisted.settings[key]
        if value ~= nil then
            self.sv[key] = (type(value) == "table") and CloneTable(value) or value
        end
    end
end

function CBG:PersistSettings(reason)
    if not self.sv or self._persistingSettings then return end
    self._persistingSettings = true
    self.settingsDirtyCount = (tonumber(self.settingsDirtyCount) or 0) + 1
    local now = GetNow()
    self.sv.savedByVersion = VERSION
    self.sv.lastSavedAt = now
    self.sv.lastSavedReason = tostring(reason or "settings changed")
    self.sv._persistedSettings = {
        version = VERSION,
        savedAt = now,
        reason = self.sv.lastSavedReason,
        settings = BuildPersistedSettingsSnapshot(),
    }
    self._persistingSettings = false
end

function CBG:IsMuted(kind, index)
    if not self.sv then return false end
    if kind == "zone" then
        if not self.sv.suppressZoneChat then return false end
        local untilStamp = tonumber(self.sv.muteUntilZone) or 0
        if untilStamp > 0 and GetNow() >= untilStamp then
            self.sv.suppressZoneChat = false
            self.sv.muteUntilZone = 0
            SafeD('"Zone Chat" has been automatically unmuted.', "muteExpired")
            RequestMenuRefresh()
            return false
        end
        return true
    elseif kind == "guild" then
        if not self.sv.hideGuild[index] then return false end
        local untilStamp = tonumber(self.sv.muteUntilGuild[index]) or 0
        if untilStamp > 0 and GetNow() >= untilStamp then
            self.sv.hideGuild[index] = false
            self.sv.muteUntilGuild[index] = 0
            SafeD('"' .. self:GetPlainGuildLabel(index, false) .. '" has been automatically unmuted.', "muteExpired")
            RequestMenuRefresh()
            return false
        end
        return true
    elseif kind == "officer" then
        if not self.sv.hideOfficer[index] then return false end
        local untilStamp = tonumber(self.sv.muteUntilOfficer[index]) or 0
        if untilStamp > 0 and GetNow() >= untilStamp then
            self.sv.hideOfficer[index] = false
            self.sv.muteUntilOfficer[index] = 0
            SafeD('"' .. self:GetPlainGuildLabel(index, true) .. '" officer chat has been automatically unmuted.', "muteExpired")
            RequestMenuRefresh()
            return false
        end
        return true
    end
    return false
end

function CBG:GetMuteUntil(kind, index)
    if kind == "zone" then return tonumber(self.sv.muteUntilZone) or 0 end
    if kind == "guild" then return tonumber(self.sv.muteUntilGuild[index]) or 0 end
    if kind == "officer" then return tonumber(self.sv.muteUntilOfficer[index]) or 0 end
    return 0
end

function CBG:GetMuteLabel(kind, index)
    if kind == "zone" then return "Zone Chat" end
    if kind == "guild" then return self:GetPlainGuildLabel(index, false) end
    if kind == "officer" then return self:GetPlainGuildLabel(index, true) .. " officer chat" end
    return "Chat"
end

function CBG:SetZoneMuted(muted, quiet)
    if not self.sv then return end
    self.sv.suppressZoneChat = muted and true or false
    if muted then
        local seconds = GetDurationSeconds(self.sv.muteDurationZone)
        self.sv.muteUntilZone = (seconds > 0) and (GetNow() + seconds) or 0
    else
        self.sv.muteUntilZone = 0
    end
    if not quiet then
        if muted then
            SafeD(FormatMuteLine("Zone Chat", self.sv.muteUntilZone), "muteStarted")
        else
            SafeD('"Zone Chat" has been unmuted. Status: ' .. StateText(false), "filterStatus")
        end
    end
    RequestMenuRefresh()
end

function CBG:SetChannelMuted(kind, index, muted, quiet)
    if not self.sv then return end
    if kind == "zone" then self:SetZoneMuted(muted, quiet); return end
    local label = self:GetPlainGuildLabel(index, kind == "officer")
    local displayLabel = (kind == "officer") and (label .. " officer chat") or label
    if kind == "guild" then
        self.sv.hideGuild[index] = muted and true or false
        if muted then
            local seconds = GetDurationSeconds(self.sv.muteDurationGuild[index])
            self.sv.muteUntilGuild[index] = (seconds > 0) and (GetNow() + seconds) or 0
        else
            self.sv.muteUntilGuild[index] = 0
        end
    elseif kind == "officer" then
        self.sv.hideOfficer[index] = muted and true or false
        if muted then
            local seconds = GetDurationSeconds(self.sv.muteDurationOfficer[index])
            self.sv.muteUntilOfficer[index] = (seconds > 0) and (GetNow() + seconds) or 0
        else
            self.sv.muteUntilOfficer[index] = 0
        end
    end
    if not quiet then
        if muted then
            SafeD(FormatMuteLine(displayLabel, self:GetMuteUntil(kind, index)), "muteStarted")
        else
            SafeD('"' .. displayLabel .. '" has been unmuted. Status: ' .. StateText(false), "filterStatus")
        end
    end
    RequestMenuRefresh()
end

function CBG:RefreshMuteTimer(kind, index)
    if not self.sv then return end
    if kind == "zone" and self.sv.suppressZoneChat then
        self:SetZoneMuted(true, true)
        SafeD(FormatMuteLine("Zone Chat", self.sv.muteUntilZone), "timerStatus")
    elseif kind == "guild" and self.sv.hideGuild[index] then
        self:SetChannelMuted("guild", index, true, true)
        SafeD(FormatMuteLine(self:GetPlainGuildLabel(index, false), self.sv.muteUntilGuild[index]), "timerStatus")
    elseif kind == "officer" and self.sv.hideOfficer[index] then
        self:SetChannelMuted("officer", index, true, true)
        SafeD(FormatMuteLine(self:GetPlainGuildLabel(index, true) .. " officer chat", self.sv.muteUntilOfficer[index]), "timerStatus")
    end
end


function CBG:CheckExpiredMutes()
    if not self.sv then return end
    self:IsMuted("zone")
    for i = 1, 5 do
        self:IsMuted("guild", i)
        self:IsMuted("officer", i)
    end
end

function CBG:StartMuteTimerCheck()
    if not EVENT_MANAGER then return end
    EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "MuteTimers")
    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "MuteTimers", 60000, function()
        if CBG.sv then CBG:CheckExpiredMutes() end
    end)
end

function CBG:IsFilteredChannel(channelType)
    if not self.sv or not self.sv.filterEnabled then return false end
    local kind, index = GetChannelInfo(channelType)
    if kind == "zone" then return self:IsMuted("zone") end
    if kind == "guild" then return self:IsMuted("guild", index) end
    if kind == "officer" then return self:IsMuted("officer", index) end
    return false
end

function CBG:IsFilteredText(text)
    if not self.sv or not self.sv.filterEnabled then return false end
    local lower = LowerPlain(text or "")
    local trimmed = Trim(lower)
    if self.sv.filterPlusMessages and string.sub(trimmed, 1, 1) == "+" then return true end
    if self.sv.filterTradeMessages then
        if string.find(lower, "%f[%a]wts%f[%A]") or string.find(lower, "%f[%a]wtb%f[%A]") or string.find(lower, "%f[%a]wtt%f[%A]") then return true end
        if string.find(lower, "wts", 1, true) or string.find(lower, "wtb", 1, true) or string.find(lower, "wtt", 1, true) then return true end
    end
    if self.sv.filterGuildAds then
        local hasGuild = string.find(lower, "guild", 1, true) or string.find(lower, "trader", 1, true) or string.find(lower, "discord", 1, true)
        local hasRecruit = string.find(lower, "join", 1, true) or string.find(lower, "recruit", 1, true) or string.find(lower, "new player", 1, true) or string.find(lower, "active", 1, true) or string.find(lower, "raffle", 1, true)
        if hasGuild and hasRecruit then return true end
    end
    return false
end

function CBG:ShouldSuppressMessage(channelType, fromName, text)
    if not self.sv or not self.sv.enabled or self.sv.safeMode then return false end
    -- Muted chats stay muted until manually unmuted in Chat Be Gone or until their timer expires.
    if self:IsFilteredChannel(channelType) then return true end
    if self:IsFilteredText(text) then return true end
    return false
end

function CBG:GetChannelColor(channelType)
    if not self.sv or not self.sv.colorsEnabled then return nil end
    if IsWhisperIncoming(channelType) then return self.sv.colorWhisperIn end
    if IsWhisperOutgoing(channelType) then return self.sv.colorWhisperOut end
    local kind, index = GetChannelInfo(channelType)
    if kind == "guild" then return self.sv.colorGuild[index] end
    if kind == "officer" then return self.sv.colorOfficer[index] end
    return nil
end

function CBG:DecorateFormattedMessage(channelType, formattedText)
    if not self.sv or self.sv.safeMode or not self.sv.enabled then return formattedText end
    local out = formattedText
    if self.sv.colorsEnabled then
        local color = self:GetChannelColor(channelType)
        if color then out = Colorize(out, color) end
    end
    if self.sv.timestampEnabled then
        out = "|cA0A0A0[" .. GetClockText() .. "]|r " .. tostring(out or "")
    end
    return out
end

function CBG:InstallChatHook()
    if self.hookInstalled then return end
    if not CHAT_ROUTER or not EVENT_CHAT_MESSAGE_CHANNEL or not ZO_PreHook then
        self.lastChatHook = "Router unavailable"
        SafeD("Chat router hook unavailable. Filtering will activate once the router is ready.")
        return
    end
    local ok, err = pcall(function()
        ZO_PreHook(CHAT_ROUTER, "FormatAndAddChatMessage", function(_, eventKey, ...)
            if eventKey ~= EVENT_CHAT_MESSAGE_CHANNEL then return false end
            local channelType, fromName, text = ExtractChatArgsFromRouter(eventKey, ...)
            if channelType == nil then
                CBG.lastChatHook = "Saw chat event but could not parse args"
                return false
            end
            CBG.lastChatHook = "Parsed " .. tostring(CBG:GetChannelLabel(channelType))
            if IsSelfSender(fromName) then CBG.lastSelfChannelType = channelType; CBG.lastDetectedInputChannel = channelType end
            if CBG:ShouldSuppressMessage(channelType, fromName, text) then
                CBG.suppressedCount = (CBG.suppressedCount or 0) + 1
                return true
            end
            return false
        end)
    end)
    if ok then
        self.hookInstalled = true
        self.lastChatHook = "Installed"
    else
        self.lastChatHook = "Install failed: " .. tostring(err)
        SafeD("Chat filter hook failed. Use /cbg status and report the error.")
    end
end

function CBG:InstallFormatterWrapper()
    if self.formatterInstalled then return end
    if not CHAT_ROUTER or not EVENT_CHAT_MESSAGE_CHANNEL or not CHAT_ROUTER.GetRegisteredMessageFormatters or not CHAT_ROUTER.RegisterMessageFormatter then
        return
    end
    local ok, err = pcall(function()
        local formatters = CHAT_ROUTER:GetRegisteredMessageFormatters()
        local originalFormatter = formatters and formatters[EVENT_CHAT_MESSAGE_CHANNEL]
        if type(originalFormatter) ~= "function" then return end
        CHAT_ROUTER:RegisterMessageFormatter(EVENT_CHAT_MESSAGE_CHANNEL, function(...)
            local returns = { originalFormatter(...) }
            local channelType = ExtractChatArgsFromFormatter(...)
            if channelType ~= nil and returns[1] ~= nil then
                returns[1] = CBG:DecorateFormattedMessage(channelType, returns[1])
            end
            if channelType ~= nil and returns[5] ~= nil then
                returns[5] = CBG:DecorateFormattedMessage(channelType, returns[5])
            end
            return UnpackTable(returns)
        end)
    end)
    if ok then
        self.formatterInstalled = true
    else
        SafeD("Timestamp/color formatter wrapper failed: " .. tostring(err))
    end
end

function CBG:InstallChatEventWatcher()
    if self.eventWatcherInstalled or not EVENT_MANAGER or not EVENT_CHAT_MESSAGE_CHANNEL then return end
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "ChatWatch", EVENT_CHAT_MESSAGE_CHANNEL, function(_, ...)
        local channelType, fromName = ExtractChatArgsFromFormatter(...)
        if channelType ~= nil then
            CBG.lastChatEvent = "Event channel " .. tostring(CBG:GetChannelLabel(channelType))
            if IsSelfSender(fromName) then
                CBG.lastSelfChannelType = channelType
                CBG.lastDetectedInputChannel = channelType
            end
            if CBG.debugMode and CBG.sv and not CBG.sv.safeMode then
                SafeD("Saw chat event: " .. tostring(CBG:GetChannelLabel(channelType)) .. " from " .. tostring(fromName or ""))
            end
        end
    end)
    self.eventWatcherInstalled = true
end

local function RestoreMenuKeybinds()
    if KEYBIND_STRIP then
        -- Console settings can lose their Back footer if a temporary group is removed without a refresh.
        pcall(function() if KEYBIND_STRIP.UpdateKeybindButtonGroup then KEYBIND_STRIP:UpdateKeybindButtonGroup() end end)
        pcall(function() if KEYBIND_STRIP.UpdateCurrentKeybindButtonGroups then KEYBIND_STRIP:UpdateCurrentKeybindButtonGroups() end end)
    end
    RequestMenuRefresh()
end

function CBG:PushModalKeybinds()
    if KEYBIND_STRIP and KEYBIND_STRIP.PushKeybindGroupState then
        local ok = pcall(function() KEYBIND_STRIP:PushKeybindGroupState() end)
        if ok then
            self.modalKeybindStackDepth = (self.modalKeybindStackDepth or 0) + 1
            return true
        end
    end
    return false
end

function CBG:PopModalKeybinds()
    if KEYBIND_STRIP and KEYBIND_STRIP.PopKeybindGroupState and (self.modalKeybindStackDepth or 0) > 0 then
        pcall(function() KEYBIND_STRIP:PopKeybindGroupState() end)
        self.modalKeybindStackDepth = math.max(0, (self.modalKeybindStackDepth or 1) - 1)
    end
    RestoreMenuKeybinds()
end


function CBG:ResetAllSettings()
    if not self.sv then return end
    local defaults = CloneDefaults()
    for key in pairs(self.sv) do
        self.sv[key] = nil
    end
    for key, value in pairs(defaults) do
        self.sv[key] = (type(value) == "table") and CloneTable(value) or value
    end
    EnsureSettingsTables()
    self:PersistSettings("reset all settings")
    self:RefreshGuildNames()
    RequestMenuRefresh()
    SafeD("Settings Reset Successfully.", "reset", true)
end

function CBG:CloseResetConfirm()
    if self.resetConfirm then self.resetConfirm:SetHidden(true) end
    if KEYBIND_STRIP and self.resetConfirmKeybinds then pcall(function() KEYBIND_STRIP:RemoveKeybindButtonGroup(self.resetConfirmKeybinds) end) end
end

function CBG:ConfirmResetSettings()
    self:CloseResetConfirm()
    self:ResetAllSettings()
end

function CBG:ShowResetConfirm()
    if not WINDOW_MANAGER or not GuiRoot then
        SafeD("Type /cbg reset confirm to reset all settings.", "reset", true)
        return
    end
    if not self.resetConfirm then
        local panel = WINDOW_MANAGER:CreateTopLevelWindow("ChatBeGoneResetConfirm")
        panel:SetDimensions(760, 360)
        panel:ClearAnchors()
        panel:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
        panel:SetHidden(true)
        panel:SetMouseEnabled(true)
        if panel.SetDrawTier then panel:SetDrawTier(DT_HIGH) end

        local bg = WINDOW_MANAGER:CreateControl("ChatBeGoneResetConfirmBg", panel, CT_BACKDROP)
        bg:SetAnchorFill(panel)
        bg:SetCenterColor(0, 0, 0, 0.94)
        bg:SetEdgeColor(0, 0.8, 1, 1)
        bg:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 128, 16)
        bg:SetInsets(8, 8, -8, -8)

        local title = WINDOW_MANAGER:CreateControl("ChatBeGoneResetConfirmTitle", panel, CT_LABEL)
        title:SetAnchor(TOPLEFT, panel, TOPLEFT, 28, 24)
        title:SetAnchor(TOPRIGHT, panel, TOPRIGHT, -28, 24)
        title:SetFont("ZoFontWinH1")
        title:SetColor(1, 0.25, 0.25, 1)
        title:SetText("RESET ALL SETTINGS?")

        local body = WINDOW_MANAGER:CreateControl("ChatBeGoneResetConfirmBody", panel, CT_LABEL)
        body:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 22)
        body:SetAnchor(TOPRIGHT, title, BOTTOMRIGHT, 0, 22)
        body:SetFont("ZoFontGameLarge")
        body:SetColor(1, 1, 1, 1)
        body:SetText("This restores Chat Be Gone to default settings. Muted guilds, timers, filters, colors, timestamps, and notification settings will be reset.\n\nA = Confirm Reset\nB = Cancel")

        self.resetConfirm = panel
    end
    self.resetConfirm:SetHidden(false)
    if KEYBIND_STRIP then
        if not self.resetConfirmKeybinds then
            self.resetConfirmKeybinds = {
                alignment = KEYBIND_STRIP_ALIGN_LEFT,
                { name = "Confirm Reset", keybind = "UI_SHORTCUT_PRIMARY", callback = function() CBG:ConfirmResetSettings() end },
                { name = "Cancel", keybind = "UI_SHORTCUT_NEGATIVE", callback = function() CBG:CloseResetConfirm() end },
            }
        end
        pcall(function() KEYBIND_STRIP:AddKeybindButtonGroup(self.resetConfirmKeybinds) end)
    end
end

local function AddDescription(text)
    return { type = "description", text = text }
end

local function ToggleName(label, getter)
    return function()
        local ok, value = pcall(getter)
        return FormatBoolOption(label, ok and value)
    end
end

local function AddFooterDescriptions(options)
    table.insert(options, AddDescription("|c3399FFCreated By: xPricee|r"))
    table.insert(options, AddDescription("|c3399FFGuild: The Eternal Gods|r"))
    table.insert(options, AddDescription("|c3399FFDiscord: xprice.|r"))
end

function CBG:RegisterLAM()
    if self.lamRegistered then return end
    self:RefreshGuildNames()
    if not self.playerActivated and self:GetJoinedGuildCount() > 0 and not self:HasAnyGuildName() then return end
    local LAM = LibAddonMenu2
    if not LAM then return end
    self.lamRegistered = true

    local panelData = {
        type = "panel",
        name = DISPLAY_NAME,
        displayName = DISPLAY_NAME,
        author = "xPricee",
        version = VERSION,
        slashCommand = "/cbg",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local options = {
        AddDescription("|c00BFFFChat Be Gone|r is a lightweight local chat cleanup add-on. No chat-box movement, no resize sliders, no protected UI scanning, no chat sending, and no gameplay automation. To type in a muted chat, unmute it from this add-on first."),
        {
            type = "submenu",
            name = "Guild Chats",
            tooltip = "Open guild and officer chat visibility options. Guild names stay inside this section only.",
            controls = {
                AddDescription("Guild chat controls are listed here only. Zone Chat stays on the main menu. Each guild has guild chat, officer chat, mute timers, current time left, and color controls."),
            },
        },
        {
            type = "submenu",
            name = "|c3399FFZone Chat|r",
            tooltip = "Open Zone Chat mute and timer settings. Zone Chat stays on the main Chat Be Gone menu for quick access.",
            controls = {
                AddDescription("Locally suppresses Zone chat. Zone Chat can be muted for 10 minutes through 24 hours or indefinitely. To type in muted Zone Chat, unmute Zone Chat from this add-on first."),
                {
                    type = "checkbox",
                    name = ToggleName("Suppress Zone Chat", function() return CBG.sv.suppressZoneChat end),
                    tooltip = "Locally hides Zone chat and language-zone chat channels. To type in Zone Chat while muted, unmute Zone Chat from this add-on first.",
                    getFunc = function() return CBG.sv.suppressZoneChat end,
                    setFunc = function(value) CBG:SetZoneMuted(value); RequestMenuRefresh() end,
                    default = DEFAULTS.suppressZoneChat,
                },
                {
                    type = "dropdown",
                    name = "Zone Chat Timer",
                    tooltip = "Sets how long Zone Chat stays suppressed after you turn it on. Choose 10 minutes through 24 hours or Indefinite.",
                    choices = MUTE_CHOICES,
                    getFunc = function() return CBG.sv.muteDurationZone or "Indefinite" end,
                    setFunc = function(value) CBG.sv.muteDurationZone = NormalizeMuteChoice(value); CBG:RefreshMuteTimer("zone"); RequestMenuRefresh() end,
                    default = "Indefinite",
                },
                AddDescription(function() return "Current Zone Chat mute: " .. (CBG.sv.suppressZoneChat and FormatRemaining(CBG.sv.muteUntilZone) or StateText(false)) end),
            },
        },
        {
            type = "submenu",
            name = "Text Filters",
            tooltip = "Turns common spam filters on or off. These filters are local to your own chat display only.",
            controls = {
                AddDescription("General controls and text filters. These options are local to your own chat display only; they do not report, block, or affect other players."),
                {
                    type = "checkbox",
                    name = ToggleName("Enable Chat Be Gone", function() return CBG.sv.enabled end),
                    tooltip = "Master switch. Turns local chat filtering, timestamps, and color formatting on or off without deleting your settings.",
                    getFunc = function() return CBG.sv.enabled end,
                    setFunc = function(value) SetAndRefresh(function() CBG.sv.enabled = value end); SafeD("Chat Be Gone " .. StateText(value) .. ".", "filterStatus") end,
                    default = DEFAULTS.enabled,
                },
                {
                    type = "checkbox",
                    name = ToggleName("Safe Mode", function() return CBG.sv.safeMode end),
                    tooltip = "Disables all suppression and formatting while keeping your settings. Use this if another chat add-on conflicts.",
                    getFunc = function() return CBG.sv.safeMode end,
                    setFunc = function(value) SetAndRefresh(function() CBG.sv.safeMode = value end); SafeD("Safe Mode " .. StateText(value) .. ".", "filterStatus") end,
                    default = DEFAULTS.safeMode,
                },
                {
                    type = "checkbox",
                    name = ToggleName("Enable All Filters", function() return CBG.sv.filterEnabled end),
                    tooltip = "Master filter switch. Turn this off to temporarily allow all chat messages without changing individual filter choices.",
                    getFunc = function() return CBG.sv.filterEnabled end,
                    setFunc = function(value) SetAndRefresh(function() CBG.sv.filterEnabled = value end); SafeD("All filters " .. StateText(value) .. ".", "filterStatus") end,
                    default = DEFAULTS.filterEnabled,
                },
                {
                    type = "checkbox",
                    name = ToggleName("Filter Guild Ads", function() return CBG.sv.filterGuildAds end),
                    tooltip = "Hides common guild recruitment/ad messages such as join, recruit, active guild, raffle, trader, and Discord-style posts.",
                    getFunc = function() return CBG.sv.filterGuildAds end,
                    setFunc = function(value) SetAndRefresh(function() CBG.sv.filterGuildAds = value end); SafeD("Filter Guild Ads " .. StateText(value) .. ".", "filterStatus") end,
                    default = DEFAULTS.filterGuildAds,
                },
                {
                    type = "checkbox",
                    name = ToggleName("Filter +Messages", function() return CBG.sv.filterPlusMessages end),
                    tooltip = "Hides messages starting with +, such as +brp, +dolmen, +trial, or other quick sign-up spam.",
                    getFunc = function() return CBG.sv.filterPlusMessages end,
                    setFunc = function(value) SetAndRefresh(function() CBG.sv.filterPlusMessages = value end); SafeD("Filter +Messages " .. StateText(value) .. ".", "filterStatus") end,
                    default = DEFAULTS.filterPlusMessages,
                },
                {
                    type = "checkbox",
                    name = ToggleName("Filter WTS / WTB / WTT", function() return CBG.sv.filterTradeMessages end),
                    tooltip = "Hides trade spam messages containing WTS, WTB, or WTT. Useful when you want cleaner zone/guild chat.",
                    getFunc = function() return CBG.sv.filterTradeMessages end,
                    setFunc = function(value) SetAndRefresh(function() CBG.sv.filterTradeMessages = value end); SafeD("Filter WTS/WTB/WTT " .. StateText(value) .. ".", "filterStatus") end,
                    default = DEFAULTS.filterTradeMessages,
                },
            },
        },
        {
            type = "submenu",
            name = "Timestamps / Colors",
            tooltip = "Adds optional timestamps and lets you color whispers. Guild and officer colors live inside Guild Chats.",
            controls = {
                AddDescription("Timestamp and whisper color settings. Guild/officer color controls are inside each guild page under Guild Chats."),
                {
                    type = "checkbox",
                    name = ToggleName("Add Timestamp", function() return CBG.sv.timestampEnabled end),
                    tooltip = "Adds a small time stamp before chat messages handled through the chat formatter wrapper.",
                    getFunc = function() return CBG.sv.timestampEnabled end,
                    setFunc = function(value) SetAndRefresh(function() CBG.sv.timestampEnabled = value end); SafeD("Timestamps " .. StateText(value) .. ".", "filterStatus") end,
                    default = DEFAULTS.timestampEnabled,
                },
                {
                    type = "checkbox",
                    name = ToggleName("Enable Whisper/Guild Colors", function() return CBG.sv.colorsEnabled end),
                    tooltip = "Turns custom whisper, guild, and officer chat colors on or off.",
                    getFunc = function() return CBG.sv.colorsEnabled end,
                    setFunc = function(value) SetAndRefresh(function() CBG.sv.colorsEnabled = value end); SafeD("Chat colors " .. StateText(value) .. ".", "filterStatus") end,
                    default = DEFAULTS.colorsEnabled,
                },
                {
                    type = "colorpicker",
                    name = "Incoming Whisper Color",
                    tooltip = "Sets the color used for incoming whisper messages.",
                    getFunc = function() return HexToRgb(CBG.sv.colorWhisperIn) end,
                    setFunc = function(r, g, b) CBG.sv.colorWhisperIn = RgbToHex(r, g, b); RequestMenuRefresh() end,
                    default = { HexToRgb(DEFAULTS.colorWhisperIn) },
                },
                {
                    type = "colorpicker",
                    name = "Outgoing Whisper Color",
                    tooltip = "Sets the color used for outgoing whisper messages.",
                    getFunc = function() return HexToRgb(CBG.sv.colorWhisperOut) end,
                    setFunc = function(r, g, b) CBG.sv.colorWhisperOut = RgbToHex(r, g, b); RequestMenuRefresh() end,
                    default = { HexToRgb(DEFAULTS.colorWhisperOut) },
                },
                {
                    type = "button",
                    name = "Reset Whisper/Guild Colors",
                    tooltip = "Restores all whisper, guild, and officer colors to the Chat Be Gone defaults.",
                    func = function()
                        CBG.sv.colorWhisperIn = DEFAULTS.colorWhisperIn
                        CBG.sv.colorWhisperOut = DEFAULTS.colorWhisperOut
                        CBG.sv.colorGuild = CloneTable(DEFAULTS.colorGuild)
                        CBG.sv.colorOfficer = CloneTable(DEFAULTS.colorOfficer)
                        RequestMenuRefresh()
                        SafeD("Whisper/guild colors reset.", "filterStatus")
                    end,
                },
            },
        },
        {
            type = "submenu",
            name = "Add-on Notifications",
            tooltip = "Controls which Chat Be Gone local system messages appear in your chat box.",
            controls = {
                AddDescription("Turn off any Chat Be Gone notification type you do not want printed locally in your own chat box."),
            },
        },
        {
            type = "button",
            name = "|cFF3333Reset All Settings|r",
            tooltip = "Opens a confirmation popup before restoring Chat Be Gone to default settings.",
            warning = "This opens a confirmation popup before reset.",
            func = function() CBG:ShowResetConfirm() end,
        },
    }

    local guildSubmenu = nil
    local notificationSubmenu = nil
    for _, option in ipairs(options) do
        if option.name == "Guild Chats" then guildSubmenu = option end
        if option.name == "Add-on Notifications" then notificationSubmenu = option end
    end

    if guildSubmenu then
        guildSubmenu.controls = {
            AddDescription("Select a guild first. Each guild opens its own guild/officer chat settings, timers, time-left display, and color controls."),
        }
        for i = 1, 5 do
            local idx = i
            local guildControls = {
                AddDescription(function()
                    return CBG:GetGuildDisplayName(idx, false, 38) .. "\nSettings below affect this guild slot only. To type in a muted guild or officer chat, unmute that chat from Chat Be Gone first."
                end),
                {
                    type = "checkbox",
                    name = ToggleName("Remove Guild Popup / Chat", function() return CBG.sv.hideGuild[idx] end),
                    tooltip = "Locally suppresses " .. CBG:GetPlainGuildLabel(idx, false) .. " chat so it does not pop up in your chat box. To type in that guild chat, unmute it from Chat Be Gone first.",
                    getFunc = function() return CBG.sv.hideGuild[idx] end,
                    setFunc = function(value) CBG:SetChannelMuted("guild", idx, value); RequestMenuRefresh() end,
                    default = false,
                },
                {
                    type = "dropdown",
                    name = "Guild Chat Timer",
                    tooltip = "Sets how long " .. CBG:GetPlainGuildLabel(idx, false) .. " stays muted after you remove its popup/chat. Choose 10 minutes through 24 hours or Indefinite.",
                    choices = MUTE_CHOICES,
                    getFunc = function() return CBG.sv.muteDurationGuild[idx] or "Indefinite" end,
                    setFunc = function(value) CBG.sv.muteDurationGuild[idx] = NormalizeMuteChoice(value); CBG:RefreshMuteTimer("guild", idx); RequestMenuRefresh() end,
                    default = "Indefinite",
                },
                AddDescription(function() return "Current guild chat mute: " .. (CBG.sv.hideGuild[idx] and FormatRemaining(CBG.sv.muteUntilGuild[idx]) or StateText(false)) end),
                {
                    type = "checkbox",
                    name = ToggleName("Remove Officer Popup / Chat", function() return CBG.sv.hideOfficer[idx] end),
                    tooltip = "Locally suppresses " .. CBG:GetPlainGuildLabel(idx, true) .. " chat so it does not pop up in your chat box. To type in that officer chat, unmute it from Chat Be Gone first.",
                    getFunc = function() return CBG.sv.hideOfficer[idx] end,
                    setFunc = function(value) CBG:SetChannelMuted("officer", idx, value); RequestMenuRefresh() end,
                    default = false,
                },
                {
                    type = "dropdown",
                    name = "Officer Chat Timer",
                    tooltip = "Sets how long " .. CBG:GetPlainGuildLabel(idx, true) .. " stays muted after you remove its popup/chat. Choose 10 minutes through 24 hours or Indefinite.",
                    choices = MUTE_CHOICES,
                    getFunc = function() return CBG.sv.muteDurationOfficer[idx] or "Indefinite" end,
                    setFunc = function(value) CBG.sv.muteDurationOfficer[idx] = NormalizeMuteChoice(value); CBG:RefreshMuteTimer("officer", idx); RequestMenuRefresh() end,
                    default = "Indefinite",
                },
                AddDescription(function() return "Current officer chat mute: " .. (CBG.sv.hideOfficer[idx] and FormatRemaining(CBG.sv.muteUntilOfficer[idx]) or StateText(false)) end),
                {
                    type = "colorpicker",
                    name = "Guild Color",
                    tooltip = "Sets the display color for " .. CBG:GetPlainGuildLabel(idx, false) .. " messages and menu labels.",
                    getFunc = function() return HexToRgb(CBG.sv.colorGuild[idx]) end,
                    setFunc = function(r, g, b) CBG.sv.colorGuild[idx] = RgbToHex(r, g, b); RequestMenuRefresh() end,
                    default = { HexToRgb(DEFAULTS.colorGuild[idx]) },
                },
                {
                    type = "colorpicker",
                    name = "Officer Color",
                    tooltip = "Sets the display color for " .. CBG:GetPlainGuildLabel(idx, true) .. " messages and menu labels.",
                    getFunc = function() return HexToRgb(CBG.sv.colorOfficer[idx]) end,
                    setFunc = function(r, g, b) CBG.sv.colorOfficer[idx] = RgbToHex(r, g, b); RequestMenuRefresh() end,
                    default = { HexToRgb(DEFAULTS.colorOfficer[idx]) },
                },
            }
            table.insert(guildSubmenu.controls, {
                type = "submenu",
                name = CBG:GetGuildDisplayName(idx, false, 36),
                tooltip = "Open settings for " .. CBG:GetPlainGuildLabel(idx, false) .. ".",
                controls = guildControls,
            })
        end
    end

    if notificationSubmenu then
        local function addNotif(key, label, tooltip)
            table.insert(notificationSubmenu.controls, {
                type = "checkbox",
                name = ToggleName(label, function() return CBG.sv.notifications[key] end),
                tooltip = tooltip,
                getFunc = function() return CBG.sv.notifications[key] end,
                setFunc = function(value) CBG.sv.notifications[key] = value; RequestMenuRefresh() end,
                default = DEFAULTS.notifications[key],
            })
        end
        addNotif("master", "All Add-on Notifications", "Master switch for every Chat Be Gone local notification printed in your chat box.")
        addNotif("muteStarted", "Mute Started Notifications", "Shows a local message when guild, officer, or zone chat is muted, including time left and unmute time.")
        addNotif("timerStatus", "Timer Remaining Notifications", "Shows time-left messages when a mute timer is changed or checked.")
        addNotif("muteExpired", "Timer Expired Notifications", "Shows a local message when a mute timer ends and chat is automatically unmuted.")
        addNotif("filterStatus", "Filter Status Notifications", "Shows local messages when filter, timestamp, color, safe mode, or enabled toggles change.")
        addNotif("reset", "Reset Notifications", "Shows local reset confirmation/success messages.")
        addNotif("status", "Status / Help Notifications", "Shows local command output from /cbg status, /cbg guilds, /cbg help, and /mute fallbacks.")
    end

    AddFooterDescriptions(options)

    LAM:RegisterAddonPanel("ChatBeGoneOptions", panelData)
    LAM:RegisterOptionControls("ChatBeGoneOptions", options)

    if CALLBACK_MANAGER then
        pcall(function()
            CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function(panel)
                if panel == "ChatBeGoneOptions" or (type(panel) == "table" and panel.data and panel.data.name == DISPLAY_NAME) then
                    CBG:CloseResetConfirm()
                end
            end)
        end)
    end
end

local function ParseChannelToken(token)
    if not token then return nil, nil end
    token = string.lower(token)
    if token == "zone" or token == "z" then return "zone", nil end
    local kind = string.sub(token, 1, 1)
    local index = tonumber(string.sub(token, 2))
    if index == nil or index < 1 or index > 5 then return nil, nil end
    if kind == "g" then return "guild", index end
    if kind == "o" then return "officer", index end
    return nil, nil
end

function CBG:SetFilterToken(token, hidden)
    local kind, index = ParseChannelToken(token)
    if not kind then
        SafeD("Use g1-g5 for guild chat, o1-o5 for officer chat, or zone.")
        return
    end
    if kind == "zone" then
        self:SetZoneMuted(hidden)
        return
    end
    self:SetChannelMuted(kind, index, hidden)
end

function CBG:SetToggleCommand(field, label, state)
    if not self.sv then return end
    state = string.lower(tostring(state or ""))
    local enabled = (state == "on" or state == "enable" or state == "enabled" or state == "true" or state == "remove" or state == "hide")
    if state == "off" or state == "disable" or state == "disabled" or state == "false" or state == "show" then enabled = false end
    if field == "notifications.master" then
        self.sv.notifications.master = enabled
    else
        self.sv[field] = enabled
    end
    RequestMenuRefresh()
    SafeD(label .. " " .. StateText(enabled) .. ".", "filterStatus", field == "notifications.master")
end


function CBG:PrintGuilds()
    self:RefreshGuildNames()
    SafeD("Guild slots:")
    for i = 1, 5 do
        SafeD("G" .. tostring(i) .. ": " .. self:GetGuildDisplayName(i, false, 40) .. " | Officer: " .. self:GetGuildDisplayName(i, true, 40))
    end
end

function CBG:PrintStatus()
    self:CheckExpiredMutes()
    SafeD("Status: enabled=" .. StateText(self.sv.enabled) .. ", safeMode=" .. StateText(self.sv.safeMode) .. ", filters=" .. StateText(self.sv.filterEnabled) .. ", hook=" .. tostring(self.lastChatHook), "status", true)
    SafeD("Suppressed: " .. tostring(self.suppressedCount or 0) .. " | Last chat: " .. tostring(self.lastChatEvent or "None"), "status", true)
    SafeD("Settings saved by v" .. tostring(self.sv.savedByVersion or VERSION) .. " | changes this session=" .. tostring(self.settingsDirtyCount or 0), "status", true)
    SafeD("Text filters: Guild Ads=" .. StateText(self.sv.filterGuildAds) .. ", +Messages=" .. StateText(self.sv.filterPlusMessages) .. ", Trade=" .. StateText(self.sv.filterTradeMessages) .. ", Zone=" .. StateText(self.sv.suppressZoneChat), "status", true)
    if self.sv.suppressZoneChat then SafeD(FormatMuteLine("Zone Chat", self.sv.muteUntilZone), "status", true) end
    for i = 1, 5 do
        local g = self.sv.hideGuild[i] and FormatRemaining(self.sv.muteUntilGuild[i]) or "shown"
        local o = self.sv.hideOfficer[i] and FormatRemaining(self.sv.muteUntilOfficer[i]) or "shown"
        SafeD("G" .. tostring(i) .. " " .. self:GetGuildDisplayName(i, false, 24) .. ": " .. g .. " | O" .. tostring(i) .. ": " .. o, "status", true)
    end
end

function CBG:ShowHelp()
    SafeD("Commands: /cbg status, /cbg guilds, /cbg hide g1, /cbg show g1, /cbg zone on/off, /cbg reset", "status", true)
    SafeD("Filters: /cbg ads on/off, /cbg plus on/off, /cbg trade on/off, /cbg timestamp on/off, /cbg notify on/off, /mute, /mute g1, /mute zone", "status", true)
end

function CBG:ResolveChannelCandidate(value)
    local kind, index = GetChannelInfo(value)
    if kind then return kind, index, value end
    return nil, nil, nil
end

function CBG:GetCurrentChatContext()
    local function tryValue(value)
        local kind, index, channelType = self:ResolveChannelCandidate(value)
        if kind then
            self.lastDetectedInputChannel = channelType
            return kind, index
        end
        return nil, nil
    end

    local kind, index = tryValue(self.lastDetectedInputChannel)
    if kind then return kind, index end

    if CHAT_SYSTEM then
        local methods = {
            "GetCurrentChannel", "GetCurrentChannelType", "GetActiveChannel", "GetActiveChannelType",
            "GetSelectedChannel", "GetSelectedChannelType", "GetTargetChannel", "GetChannel"
        }
        for _, method in ipairs(methods) do
            if type(CHAT_SYSTEM[method]) == "function" then
                local ok, result = pcall(function() return CHAT_SYSTEM[method](CHAT_SYSTEM) end)
                kind, index = tryValue(ok and result or nil)
                if kind then return kind, index end
            end
        end

        local fields = {
            "currentChannel", "currentChannelType", "activeChannel", "activeChannelType",
            "selectedChannel", "selectedChannelType", "targetChannel", "channel", "channelType"
        }
        for _, field in ipairs(fields) do
            local ok, result = pcall(function() return CHAT_SYSTEM[field] end)
            kind, index = tryValue(ok and result or nil)
            if kind then return kind, index end
        end

        local objects = { "textEntry", "keyboardTextEntry", "gamepadTextEntry", "input", "inputControl", "textInput" }
        local objFields = { "channel", "channelType", "currentChannel", "selectedChannel", "targetChannel" }
        local objMethods = { "GetChannel", "GetChannelType", "GetCurrentChannel", "GetSelectedChannel", "GetTargetChannel" }
        for _, objName in ipairs(objects) do
            local okObj, obj = pcall(function() return CHAT_SYSTEM[objName] end)
            if okObj and obj ~= nil then
                for _, field in ipairs(objFields) do
                    local ok, result = pcall(function() return obj[field] end)
                    kind, index = tryValue(ok and result or nil)
                    if kind then return kind, index end
                end
                for _, method in ipairs(objMethods) do
                    local okMethod, fn = pcall(function() return obj[method] end)
                    if okMethod and type(fn) == "function" then
                        local ok, result = pcall(function() return fn(obj) end)
                        kind, index = tryValue(ok and result or nil)
                        if kind then return kind, index end
                    end
                end
            end
        end
    end

    kind, index = tryValue(self.lastSelfChannelType)
    if kind then return kind, index end
    return nil, nil
end

function CBG:OpenOptionsHint(kind, index)
    self.pendingMenuSection = { kind = kind, index = index }
    local target = "Guild Chats"
    if kind == "zone" then target = "Zone Chat options" end
    if kind == "guild" then target = self:GetPlainGuildLabel(index, false) .. " options" end
    if kind == "officer" then target = self:GetPlainGuildLabel(index, true) .. " options" end
    if LibAddonMenu2 and LibAddonMenu2.OpenToPanel then
        pcall(function() LibAddonMenu2:OpenToPanel("ChatBeGoneOptions") end)
    end
    SafeD("Opening " .. target .. ". If the exact page does not open automatically, go to Chat Be Gone > Guild Chats.", "status", true)
end

function CBG:MuteShortcut(text)
    text = Trim(text or "")
    if text ~= "" then
        local kind, index = ParseChannelToken(text)
        if kind then
            self:OpenOptionsHint(kind, index)
            return
        end
        self:SlashCommand(text)
        return
    end
    local kind, index = self:GetCurrentChatContext()
    if kind == "zone" then
        self:OpenOptionsHint("zone")
    elseif kind == "guild" or kind == "officer" then
        self:OpenOptionsHint(kind, index)
    else
        self:OpenOptionsHint(nil, nil)
        SafeD("Could not detect the selected chat channel. Opening Guild Chats instead. You can also use /mute zone, /mute g1-g5, or /mute o1-o5.", "status", true)
    end
end

function CBG:SlashCommand(text)
    text = Trim(text or "")
    if text == "" or text == "help" then self:ShowHelp(); return end
    local args = {}
    for part in string.gmatch(text, "%S+") do table.insert(args, part) end
    local cmd = string.lower(args[1] or "")
    local a2 = string.lower(args[2] or "")
    local a3 = string.lower(args[3] or "")

    if cmd == "status" then self:PrintStatus(); return end
    if cmd == "mute" then self:MuteShortcut(table.concat(args, " ", 2)); return end
    if cmd == "notify" or cmd == "notifications" then self:SetToggleCommand("notifications.master", "Add-on Notifications", a2); return end
    if cmd == "reset" and a2 == "confirm" then self:ResetAllSettings(); return end
    if cmd == "reset" then self:ShowResetConfirm(); return end
    if cmd == "saved" or cmd == "panel" or cmd == "clear" or cmd == "history" or cmd == "commands" or cmd == "commandlist" then
        SafeD("That section was removed. Use /cbg status, /cbg guilds, /cbg zone on/off, or /mute.", "status", true)
        return
    end
    if cmd == "guilds" then self:PrintGuilds(); return end
    if cmd == "debug" then self.debugMode = not self.debugMode; SafeD("Debug " .. BoolText(self.debugMode) .. "."); return end
    if cmd == "hide" or cmd == "remove" then self:SetFilterToken(a2, true); return end
    if cmd == "show" or cmd == "unhide" then self:SetFilterToken(a2, false); return end
    if cmd == "zone" then self:SetZoneMuted(a2 == "on" or a2 == "hide" or a2 == "remove" or a2 == "true"); return end
    if cmd == "ads" then self:SetToggleCommand("filterGuildAds", "Filter Guild Ads", a2); return end
    if cmd == "plus" then self:SetToggleCommand("filterPlusMessages", "Filter +Messages", a2); return end
    if cmd == "trade" then self:SetToggleCommand("filterTradeMessages", "Filter WTS/WTB/WTT", a2); return end
    if cmd == "timestamp" or cmd == "timestamps" then self:SetToggleCommand("timestampEnabled", "Timestamps", a2); return end
    if cmd == "safe" then self:SetToggleCommand("safeMode", "Safe Mode", a2); return end
    if cmd == "on" then self.sv.enabled = true; RequestMenuRefresh(); SafeD("Enabled."); return end
    if cmd == "off" then self.sv.enabled = false; RequestMenuRefresh(); SafeD("Disabled."); return end

    self:ShowHelp()
end

function CBG:Initialize()
    if ZO_SavedVars and ZO_SavedVars.NewAccountWide then
        self.sv = ZO_SavedVars:NewAccountWide(SAVED_VARS, SV_VERSION, nil, CloneDefaults())
    else
        ChatBeGoneSavedVariables = ChatBeGoneSavedVariables or CloneDefaults()
        self.sv = ChatBeGoneSavedVariables
    end
    EnsureSettingsTables()
    self:RestorePersistedSettings()
    EnsureSettingsTables()
    self:PersistSettings("loaded")
    self:RefreshGuildNames()
    self:RegisterLAM()
    self:InstallGuildRefreshEvents()
    self:InstallChatHook()
    self:InstallFormatterWrapper()
    self:InstallChatEventWatcher()
    self:StartMuteTimerCheck()

    SLASH_COMMANDS = SLASH_COMMANDS or {}
    SLASH_COMMANDS["/cbg"] = function(text) CBG:SlashCommand(text) end
    SLASH_COMMANDS["/chatbegone"] = function(text) CBG:SlashCommand(text) end
    SLASH_COMMANDS["/mute"] = function(text) CBG:MuteShortcut(text) end

    SafeD("loaded. Use /cbg status, /cbg guilds, or /mute.", "status", true)
end

local function OnPlayerActivated()
    CBG.playerActivated = true
    CBG:RefreshGuildNames()
    CBG:RegisterLAM()
    CBG:InstallChatHook()
    CBG:InstallFormatterWrapper()
    CBG:InstallChatEventWatcher()
    CBG:CheckExpiredMutes()
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    CBG:Initialize()
    if EVENT_MANAGER and EVENT_PLAYER_ACTIVATED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "Activated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    end
end

if EVENT_MANAGER then
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
end


function ChatBeGone_Status()
    CBG:PrintStatus()
end
