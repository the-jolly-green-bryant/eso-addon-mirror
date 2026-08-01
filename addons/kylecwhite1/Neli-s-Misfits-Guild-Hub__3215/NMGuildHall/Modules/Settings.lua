-- Settings Module
-- LibAddonMenu2 integration for addon configuration
-- Dependencies: LibAddonMenu2 (required), Message
-- Provides settings UI, import/export, profiles, and migration
local LAM2 = LibAddonMenu2
local Addon = NMGuildHall

-- Settings Module
local Settings = {
    initialized = false,
    panel = nil
}

-- Settings profiles/presets
local SETTINGS_PROFILES = {
    ["Performance"] = {
        nameStringKey = "NMGH_SETTINGS_PROFILE_PERFORMANCE",
        description = GetString(NMGH_SETTINGS_PROFILE_PERFORMANCE_DESC),
        settings = {
            zoneCacheDurationSeconds = 15,
            zoneCacheRefreshCooldownSeconds = 2,
            messageRateLimit = 10,
            messageRateLimitWindow = 500,
            maxGuildMembersToCheck = 50,
        }
    },
    ["Accuracy"] = {
        nameStringKey = "NMGH_SETTINGS_PROFILE_ACCURACY",
        description = GetString(NMGH_SETTINGS_PROFILE_ACCURACY_DESC),
        settings = {
            zoneCacheDurationSeconds = 60,
            zoneCacheRefreshCooldownSeconds = 1,
            messageRateLimit = 5,
            messageRateLimitWindow = 1000,
            maxGuildMembersToCheck = 200,
        }
    },
    ["Balanced"] = {
        nameStringKey = "NMGH_SETTINGS_PROFILE_BALANCED",
        description = GetString(NMGH_SETTINGS_PROFILE_BALANCED_DESC),
        settings = {
            zoneCacheDurationSeconds = 30,
            zoneCacheRefreshCooldownSeconds = 5,
            messageRateLimit = 5,
            messageRateLimitWindow = 1000,
            maxGuildMembersToCheck = 100,
        }
    }
}

-- Helper function to validate and clamp slider values
local function ValidateSliderValue(value, min, max, default)
    local numValue = tonumber(value)
    if not numValue then
        return default
    end
    return math.max(min, math.min(max, numValue))
end

-- Helper function to safely get slider value with validation
local function SafeGetSliderValue(dbValue, defaultValue, min, max)
    return ValidateSliderValue(dbValue, min, max, defaultValue)
end
local function SafeGetString(stringId)
    local success, result = pcall(GetString, stringId)
    return success and result or tostring(stringId)
end
local function SettingsLogger()
    if Addon and Addon.Message and Addon.Message.For then
        return Addon.Message:For("Settings")
    end
    return nil
end

local function DeepCopy(value)
    if type(value) ~= "table" then
        return value
    end

    local copy = {}
    for key, nestedValue in pairs(value) do
        copy[key] = DeepCopy(nestedValue)
    end
    return copy
end

local function GetSeasonalDefaults()
    local defaults = Addon and Addon.defaults and Addon.defaults.seasonal
    if type(defaults) == "table" then
        return defaults
    end
    return {
        enabled = true,
        ownUi = true,
        chatMessages = true,
        nativeGuildUi = true,
        keepOwnership = true,
        traderUi = true,
        eventOverrides = {
            misfitsBirthday = {
                enabled = false,
                timezone = "America/New_York",
                start = { year = 0, month = 0, day = 0, hour = 0, min = 0, sec = 0 },
                ["end"] = { year = 0, month = 0, day = 0, hour = 23, min = 59, sec = 59 },
            },
        },
    }
end

local function NormalizeSeasonalOverrideBoundary(value, defaultHour, defaultMinute, defaultSecond)
    local normalized = {
        year = 0,
        month = 0,
        day = 0,
        hour = defaultHour or 0,
        min = defaultMinute or 0,
        sec = defaultSecond or 0,
    }

    if type(value) ~= "table" then
        return normalized
    end

    local year = tonumber(value.year)
    if year and year >= 0 then
        normalized.year = math.floor(year)
    end

    local month = tonumber(value.month)
    if month and month >= 0 then
        normalized.month = math.floor(month)
    end

    local day = tonumber(value.day)
    if day and day >= 0 then
        normalized.day = math.floor(day)
    end

    local hour = tonumber(value.hour)
    if hour then
        normalized.hour = math.max(0, math.min(23, math.floor(hour)))
    end

    local minute = tonumber(value.min)
    if minute then
        normalized.min = math.max(0, math.min(59, math.floor(minute)))
    end

    local second = tonumber(value.sec)
    if second then
        normalized.sec = math.max(0, math.min(59, math.floor(second)))
    end

    return normalized
end

local function NormalizeSeasonalEventOverride(value, defaultValue)
    local normalized = {
        enabled = false,
        timezone = "America/New_York",
        start = NormalizeSeasonalOverrideBoundary(nil, 0, 0, 0),
        ["end"] = NormalizeSeasonalOverrideBoundary(nil, 23, 59, 59),
    }

    if type(defaultValue) == "table" then
        if type(defaultValue.enabled) == "boolean" then
            normalized.enabled = defaultValue.enabled
        end
        if defaultValue.timezone == "UTC" or defaultValue.timezone == "America/New_York" then
            normalized.timezone = defaultValue.timezone
        end
        normalized.start = NormalizeSeasonalOverrideBoundary(defaultValue.start, 0, 0, 0)
        normalized["end"] = NormalizeSeasonalOverrideBoundary(defaultValue["end"], 23, 59, 59)
    end

    if type(value) == "table" then
        if type(value.enabled) == "boolean" then
            normalized.enabled = value.enabled
        end
        if value.timezone == "UTC" or value.timezone == "America/New_York" then
            normalized.timezone = value.timezone
        end
        normalized.start = NormalizeSeasonalOverrideBoundary(value.start, normalized.start.hour, normalized.start.min, normalized.start.sec)
        normalized["end"] = NormalizeSeasonalOverrideBoundary(value["end"], normalized["end"].hour, normalized["end"].min, normalized["end"].sec)
    end

    return normalized
end

local function NormalizeSeasonalEventOverrides(value, defaults)
    local normalized = {}
    local defaultTable = type(defaults) == "table" and defaults or {}

    for eventKey, defaultValue in pairs(defaultTable) do
        local overrideValue = type(value) == "table" and value[eventKey] or nil
        normalized[eventKey] = NormalizeSeasonalEventOverride(overrideValue, defaultValue)
    end

    return normalized
end

local function NormalizeSeasonalConfig(value, legacyEnabled)
    local defaults = GetSeasonalDefaults()
    local normalized = {
        enabled = defaults.enabled ~= false,
        ownUi = defaults.ownUi ~= false,
        chatMessages = defaults.chatMessages ~= false,
        nativeGuildUi = defaults.nativeGuildUi ~= false,
        keepOwnership = defaults.keepOwnership ~= false,
        traderUi = defaults.traderUi ~= false,
        eventOverrides = NormalizeSeasonalEventOverrides(nil, defaults.eventOverrides),
    }

    if type(value) == "table" then
        if type(value.guildNamePatch) == "boolean" then
            normalized.nativeGuildUi = value.guildNamePatch
            normalized.keepOwnership = value.guildNamePatch
            normalized.traderUi = value.guildNamePatch
        end
        for key in pairs(normalized) do
            if key ~= "eventOverrides" and type(value[key]) == "boolean" then
                normalized[key] = value[key]
            end
        end
        if type(value.eventOverrides) == "table" or type(defaults.eventOverrides) == "table" then
            normalized.eventOverrides = NormalizeSeasonalEventOverrides(value.eventOverrides, defaults.eventOverrides)
        end
    end

    if type(legacyEnabled) == "boolean" then
        normalized.enabled = legacyEnabled
    end

    return normalized
end

local function EnsureSeasonalConfig()
    if not (Addon and type(Addon.db) == "table") then
        return NormalizeSeasonalConfig(nil, nil)
    end

    local legacyEnabled = nil
    if type(Addon.db.seasonalEnabled) == "boolean" then
        legacyEnabled = Addon.db.seasonalEnabled
    end

    Addon.db.seasonal = NormalizeSeasonalConfig(Addon.db.seasonal, legacyEnabled)
    Addon.db.seasonalEnabled = nil
    return Addon.db.seasonal
end

local function GetMisfitsBirthdayOverride()
    local seasonal = EnsureSeasonalConfig()
    seasonal.eventOverrides = seasonal.eventOverrides or {}
    seasonal.eventOverrides.misfitsBirthday = seasonal.eventOverrides.misfitsBirthday or {
        enabled = false,
        timezone = "America/New_York",
        start = { year = 0, month = 0, day = 0, hour = 0, min = 0, sec = 0 },
        ["end"] = { year = 0, month = 0, day = 0, hour = 23, min = 59, sec = 59 },
    }
    return seasonal.eventOverrides.misfitsBirthday
end

local function FormatOverrideDate(boundary)
    boundary = boundary or {}
    local year = tonumber(boundary.year) or 0
    local month = tonumber(boundary.month) or 0
    local day = tonumber(boundary.day) or 0
    if year <= 0 or month <= 0 or day <= 0 then
        return ""
    end
    return string.format("%04d-%02d-%02d", year, month, day)
end

local function FormatOverrideTime(boundary)
    boundary = boundary or {}
    local hour = tonumber(boundary.hour) or 0
    local minute = tonumber(boundary.min) or 0
    local second = tonumber(boundary.sec) or 0
    return string.format("%02d:%02d:%02d", hour, minute, second)
end

local function IsLeapYear(year)
    return year % 4 == 0 and (year % 100 ~= 0 or year % 400 == 0)
end

local function GetDaysInMonth(year, month)
    local monthDays = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
    if month == 2 and year and IsLeapYear(year) then
        return 29
    end
    return monthDays[month]
end

local function ParseOverrideDate(value, boundary)
    if type(value) ~= "string" then
        return false
    end

    local year, month, day = value:match("^%s*(%d%d%d%d)%-(%d%d)%-(%d%d)%s*$")
    year = tonumber(year)
    month = tonumber(month)
    day = tonumber(day)
    if not (year and month and day) then
        return false
    end
    local daysInMonth = GetDaysInMonth(year, month)
    if month < 1 or month > 12 or day < 1 or not daysInMonth or day > daysInMonth then
        return false
    end

    boundary.year = year
    boundary.month = month
    boundary.day = day
    return true
end

local function ParseOverrideTime(value, boundary)
    if type(value) ~= "string" then
        return false
    end

    local hour, minute, second = value:match("^%s*(%d%d)%:(%d%d)%:(%d%d)%s*$")
    hour = tonumber(hour)
    minute = tonumber(minute)
    second = tonumber(second)
    if not (hour and minute and second) then
        return false
    end
    if hour < 0 or hour > 23 or minute < 0 or minute > 59 or second < 0 or second > 59 then
        return false
    end

    boundary.hour = hour
    boundary.min = minute
    boundary.sec = second
    return true
end

local function ApplySeasonalSettings()
    if Addon and Addon.Seasonal and type(Addon.Seasonal.Apply) == "function" then
        pcall(Addon.Seasonal.Apply, Addon.Seasonal)
    end
end

local function ApplyHeaderIconState()
    if not (Addon and Addon.UI and Addon.UI.window and WINDOW_MANAGER) then
        return
    end

    local titleIcon = WINDOW_MANAGER:GetControlByName("NMGuildHall_HeaderIcon")
    if not titleIcon then
        return
    end

    local style = (Addon.db and Addon.db.chatIconStyle) or (Addon.defaults and Addon.defaults.chatIconStyle) or "new"
    local mono = Addon.db and Addon.db.monochromeIcon or false
    local textures = nil
    if Addon.Constants and Addon.Constants.CHAT_ICON then
        local sets = Addon.Constants.CHAT_ICON.SETS
        if sets and sets[style] then
            textures = sets[style]
        else
            textures = Addon.Constants.CHAT_ICON.TEXTURES
        end
    end

    if textures then
        titleIcon:SetTexture(mono and textures.MONO or textures.NORMAL)
    end
end

local function ApplyChatIconRuntimeState(reason)
    local chatIcon = Addon and Addon.ChatIcon
    local db = Addon and Addon.db
    local defaults = Addon and Addon.defaults
    if not (chatIcon and chatIcon.window and db) then
        return
    end

    if reason == "reset" or reason == "import" then
        if type(db.chatIconX) == "number" and type(db.chatIconY) == "number" then
            chatIcon.window:ClearAnchors()
            chatIcon.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, db.chatIconX, db.chatIconY)
        elseif chatIcon.ResetPosition then
            pcall(chatIcon.ResetPosition, chatIcon)
        end
    end

    pcall(chatIcon.SetTexture, chatIcon, db.monochromeIcon or false)
    pcall(chatIcon.SetSize, chatIcon, tonumber(db.chatIconSize) or (defaults and defaults.chatIconSize) or 36)
    pcall(chatIcon.SetLocked, chatIcon, db.chatIconLocked or false)
    pcall(chatIcon.SetVisible, chatIcon, db.showChatIcon ~= false)
end

local function ApplyQueueWidgetRuntimeState(reason)
    local queueWidget = Addon and Addon.QueueWidget
    local db = Addon and Addon.db
    local defaults = Addon and Addon.defaults
    if not (queueWidget and queueWidget.window and db) then
        return
    end

    if reason == "reset" or reason == "import" then
        if type(db.queueWidgetX) == "number" and type(db.queueWidgetY) == "number" then
            queueWidget.window:ClearAnchors()
            queueWidget.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, db.queueWidgetX, db.queueWidgetY)
        elseif queueWidget.ResetPosition then
            pcall(queueWidget.ResetPosition, queueWidget)
        end
    end

    pcall(queueWidget.SetScale, queueWidget, tonumber(db.queueWidgetScale) or (defaults and defaults.queueWidgetScale) or 1.0)
    pcall(queueWidget.SetLocked, queueWidget, db.queueWidgetLocked ~= false)
    pcall(queueWidget.Refresh, queueWidget)
    if queueWidget._UpdatePulseState then
        pcall(queueWidget._UpdatePulseState, queueWidget)
    end
end

local function ApplyUiRuntimeState(reason)
    local ui = Addon and Addon.UI
    local db = Addon and Addon.db
    if not (ui and db) then
        return
    end

    if reason == "reset" then
        db.windowPositionSaved = nil
        if ui.window and ui.ResetPosition then
            pcall(ui.ResetPosition, ui)
        end
    end

    if ui.window then
        ApplyHeaderIconState()
        if ui.RefreshContent then
            pcall(ui.RefreshContent, ui)
        end
        if ui.Refresh then
            pcall(ui.Refresh, ui)
        end
    end
end

local function ParseExportedSettings(settingsString)
    if type(settingsString) ~= "string" then
        return nil
    end

    local i = 1
    local len = #settingsString

    local function skipWs()
        while i <= len do
            local c = settingsString:sub(i, i)
            if c == " " or c == "\t" or c == "\n" or c == "\r" then
                i = i + 1
            else
                break
            end
        end
    end

    local function parseQuotedString()
        local quote = settingsString:sub(i, i)
        if quote ~= "\"" and quote ~= "'" then
            return nil
        end
        i = i + 1
        local out = {}
        while i <= len do
            local c = settingsString:sub(i, i)
            if c == quote then
                i = i + 1
                return table.concat(out)
            end
            if c == "\\" then
                local n = settingsString:sub(i + 1, i + 1)
                if n == "n" then
                    out[#out + 1] = "\n"
                    i = i + 2
                elseif n == "r" then
                    out[#out + 1] = "\r"
                    i = i + 2
                elseif n == "t" then
                    out[#out + 1] = "\t"
                    i = i + 2
                elseif n == "\"" then
                    out[#out + 1] = "\""
                    i = i + 2
                elseif n == "'" then
                    out[#out + 1] = "'"
                    i = i + 2
                elseif n == "\\" then
                    out[#out + 1] = "\\"
                    i = i + 2
                elseif n and n:match("%d") then
                    local digits = settingsString:sub(i + 1, math.min(i + 3, len)):match("^(%d%d?%d?)")
                    if digits and digits ~= "" then
                        local byte = tonumber(digits)
                        if byte then
                            out[#out + 1] = string.char(byte)
                            i = i + 1 + #digits
                        else
                            return nil
                        end
                    else
                        return nil
                    end
                else
                    out[#out + 1] = n or ""
                    i = i + 2
                end
            else
                out[#out + 1] = c
                i = i + 1
            end
        end
        return nil
    end

    local parseValue

    local function parseTable()
        skipWs()
        if settingsString:sub(i, i) ~= "{" then
            return nil
        end
        i = i + 1

        local result = {}

        while i <= len do
            skipWs()
            local c = settingsString:sub(i, i)
            if c == "}" then
                i = i + 1
                return result
            end

            if c ~= "[" then
                return nil
            end
            i = i + 1

            skipWs()
            local key = parseQuotedString()
            if key == nil then
                return nil
            end

            skipWs()
            if settingsString:sub(i, i) ~= "]" then
                return nil
            end
            i = i + 1

            skipWs()
            if settingsString:sub(i, i) ~= "=" then
                return nil
            end
            i = i + 1

            local value = parseValue()
            result[key] = value

            skipWs()
            local delimiter = settingsString:sub(i, i)
            if delimiter == "," then
                i = i + 1
            elseif delimiter == "}" then
                i = i + 1
                return result
            else
                return nil
            end
        end

        return nil
    end

    function parseValue()
        skipWs()
        local c = settingsString:sub(i, i)
        if c == "\"" or c == "'" then
            return parseQuotedString()
        end
        if c == "{" then
            return parseTable()
        end

        local word = settingsString:sub(i):match("^(%a+)")
        if word == "true" then
            i = i + 4
            return true
        elseif word == "false" then
            i = i + 5
            return false
        elseif word == "nil" then
            i = i + 3
            return nil
        end

        local numToken = settingsString:sub(i):match("^%-?%d+%.?%d*")
        if numToken and numToken ~= "" then
            local n = tonumber(numToken)
            if n ~= nil then
                i = i + #numToken
                return n
            end
        end

        return nil
    end

    local result = parseTable()
    if result == nil then
        return nil
    end

    skipWs()
    if i <= len then
        return nil
    end

    return result
end

-- Import settings from string
function Settings:ImportSettings(settingsString)
    local log = SettingsLogger()
    if not settingsString or type(settingsString) ~= "string" then
        if log then
            log:Error(GetString(NMGH_ERR_INVALID_SETTINGS_STR))
        end
        return false
    end
    
    local success, importedSettings = pcall(function()
        -- Safe Lua table parser for settings
        -- Basic validation to prevent code injection
        if not settingsString or type(settingsString) ~= "string" then
            return nil
        end

        return ParseExportedSettings(settingsString)
    end)
    if not success or type(importedSettings) ~= "table" then
        if log then
            log:Error(GetString(NMGH_ERR_SETTINGS_PARSE_FAILED))
        end
        return false
    end
    
    -- Validate and apply imported settings
    for key, value in pairs(importedSettings) do
        if key == "seasonalEnabled" and type(value) == "boolean" then
            local seasonal = EnsureSeasonalConfig()
            seasonal.enabled = value
        elseif Addon.defaults[key] ~= nil then
            -- Apply validation based on setting type
            if key == "zoneCacheDurationSeconds" then
                Addon.db[key] = ValidateSliderValue(value, 5, 120, Addon.defaults[key])
            elseif key == "zoneCacheRefreshCooldownSeconds" then
                Addon.db[key] = ValidateSliderValue(value, 0, 10, Addon.defaults[key])
            elseif key == "messageRateLimit" then
                Addon.db[key] = ValidateSliderValue(value, 1, 20, Addon.defaults[key])
            elseif key == "messageRateLimitWindow" then
                Addon.db[key] = ValidateSliderValue(value, 100, 5000, Addon.defaults[key])
            elseif key == "maxGuildMembersToCheck" then
                Addon.db[key] = ValidateSliderValue(value, 10, 500, Addon.defaults[key])
            elseif key == "chatIconSize" then
                Addon.db[key] = ValidateSliderValue(value, 16, 128, Addon.defaults[key])
                -- Update icon size if icon exists
                if Addon.ChatIcon then
                    Addon.ChatIcon:SetSize(Addon.db[key])
                end
            elseif key == "zoneCacheRebuildMode" then
                if value == "stale_async" or value == "force" then
                    Addon.db[key] = value
                end
            elseif key == "seasonal" then
                Addon.db.seasonal = NormalizeSeasonalConfig(value, nil)
            elseif type(Addon.defaults[key]) == type(value) then
                if type(value) == "table" then
                    Addon.db[key] = DeepCopy(value)
                else
                    Addon.db[key] = value
                end
            end
        end
    end

    self:ApplyRuntimeState("import")
    
    if log then
        log:Info(GetString(NMGH_MSG_SETTINGS_IMPORTED))
    end
    return true
end

-- Export settings to string
function Settings:ExportSettings()
    local log = SettingsLogger()
    local exportData = {}
    
    if not Addon or type(Addon.db) ~= "table" or type(Addon.defaults) ~= "table" then
        if log then
            log:Error(GetString(NMGH_ERR_SETTINGS_EXPORT_FAILED))
        end
        return nil
    end

    -- NOTE: ZO_SavedVars can be a proxy table that doesn't enumerate with `pairs()`.
    -- Iterate defaults and read values from the saved vars instead.
    for key, defaultValue in pairs(Addon.defaults) do
        if key ~= "windowX" and key ~= "windowY" then
            local value = Addon.db[key]
            if value == nil then
                value = defaultValue
            end
            exportData[key] = value
        end
    end
    
    local success, result = pcall(function()
        local function serializeValue(value)
            local valueType = type(value)
            if valueType == "number" or valueType == "boolean" then
                return tostring(value)
            elseif valueType == "string" then
                return string.format("%q", value)
            elseif valueType == "table" then
                local parts = {}
                local keys = {}
                for key in pairs(value) do
                    keys[#keys + 1] = key
                end
                table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
                for _, key in ipairs(keys) do
                    parts[#parts + 1] = string.format('[%q] = %s', tostring(key), serializeValue(value[key]))
                end
                return "{" .. table.concat(parts, ",") .. "}"
            end
            return "nil"
        end

        -- Simple Lua table serializer for export
        local parts = {}
        local keys = {}
        for key in pairs(exportData) do
            keys[#keys + 1] = key
        end
        table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
        for _, key in ipairs(keys) do
            local value = exportData[key]
            table.insert(parts, string.format('[%q] = %s', tostring(key), serializeValue(value)))
        end
        
        return "{" .. table.concat(parts, ",") .. "}"
    end)
    if success then
        return result
    else
        if log then
            log:Error(GetString(NMGH_ERR_SETTINGS_EXPORT_FAILED))
        end
        return nil
    end
end

-- Apply settings profile
function Settings:ApplyProfile(profileName)
    local log = SettingsLogger()
    local profile = SETTINGS_PROFILES[profileName]
    if not profile then
        if log then
            log:Error(GetString(NMGH_ERR_UNKNOWN_PROFILE), {name = tostring(profileName)})
        end
        return false
    end

    -- Persist selection so the dropdown reflects the last applied profile
    if Addon and Addon.db then
        Addon.db.appliedProfile = profileName
    end

    -- Apply profile settings
    for key, value in pairs(profile.settings) do
        if Addon.defaults[key] ~= nil then
            if type(value) == "table" then
                Addon.db[key] = DeepCopy(value)
            else
                Addon.db[key] = value
            end
        end
    end
    
    self:ApplyRuntimeState("profile")
    
    if log then
        local fallbackProfileId = rawget(_G, "NMGH_SETTINGS_PROFILE_BALANCED")
        local profileId = profile.nameStringKey and rawget(_G, profile.nameStringKey) or fallbackProfileId
        local profileDisplayName = profileId and SafeGetString(profileId) or "Balanced"
        log:Info(GetString(NMGH_MSG_PROFILE_APPLIED), {name = profileDisplayName})
    end
    return true
end

-- Settings migration for version updates
function Settings:MigrateSettings()
    if not Addon.db then return end
    
    local currentVersion = Addon.db.settingsVersion or 1
    
    -- Migration from version 1 to 2
    if currentVersion < 2 then
        -- Add new settings with defaults
        if Addon.db.messageRateLimit == nil then
            Addon.db.messageRateLimit = Addon.defaults.messageRateLimit
        end
        if Addon.db.messageRateLimitWindow == nil then
            Addon.db.messageRateLimitWindow = Addon.defaults.messageRateLimitWindow
        end
        if Addon.db.maxGuildMembersToCheck == nil then
            Addon.db.maxGuildMembersToCheck = Addon.defaults.maxGuildMembersToCheck
        end
    end
    
    -- Migration from version 2 to 3 (example for future)
    if currentVersion < 3 then
        if Addon.db.zoneCacheRebuildMode == nil then
            Addon.db.zoneCacheRebuildMode = Addon.defaults.zoneCacheRebuildMode
        end
        if Addon.db.dynamicGuildScanScaling == nil then
            Addon.db.dynamicGuildScanScaling = Addon.defaults.dynamicGuildScanScaling
        end
        if Addon.db.chatIconStyle == nil then
            Addon.db.chatIconStyle = Addon.defaults.chatIconStyle
        end
    end

    if currentVersion < 4 then
        Addon.db.seasonal = NormalizeSeasonalConfig(Addon.db.seasonal, Addon.db.seasonalEnabled)
        Addon.db.seasonalEnabled = nil
    end

    if currentVersion < 5 then
        Addon.db.seasonal = NormalizeSeasonalConfig(Addon.db.seasonal, Addon.db.seasonalEnabled)
        Addon.db.seasonalEnabled = nil
    end

    if currentVersion < 6 then
        Addon.db.seasonal = NormalizeSeasonalConfig(Addon.db.seasonal, Addon.db.seasonalEnabled)
        Addon.db.seasonalEnabled = nil
    end
    
    -- Update to current version
    Addon.db.settingsVersion = 6

    if Addon.db.appliedProfile == nil then
        Addon.db.appliedProfile = Addon.defaults.appliedProfile or "Balanced"
    end

    EnsureSeasonalConfig()
    
    if Addon.Message then
        Addon.Message:For("Settings"):Debug(GetString(NMGH_DEBUG_SETTINGS_MIGRATED), {version = Addon.db.settingsVersion})
    end
end

function Settings:InitializeMenu()
    local log = SettingsLogger()
    -- Check for LibAddonMenu2 dependency
    if not LAM2 then
        if log then
            log:Warn(GetString(NMGH_WARN_LAM2_NOT_FOUND))
        end
        return
    end
    
    -- Initialize localized options after localization is loaded
    local leaveOption = {
        SafeGetString(NMGH_SETTINGS_CHOICE_OFF),
        SafeGetString(NMGH_SETTINGS_CHOICE_NM_ONLY),
        SafeGetString(NMGH_SETTINGS_CHOICE_ALL_GUILDS)
    }
    local leaveOptionLookup = {
        [SafeGetString(NMGH_SETTINGS_CHOICE_OFF)] = 0,
        [SafeGetString(NMGH_SETTINGS_CHOICE_NM_ONLY)] = 1,
        [SafeGetString(NMGH_SETTINGS_CHOICE_ALL_GUILDS)] = 2
    }

    local zoneCacheModeOptions = {
        SafeGetString(NMGH_SETTINGS_ZONE_CACHE_MODE_STALE_ASYNC),
        SafeGetString(NMGH_SETTINGS_ZONE_CACHE_MODE_FORCE_REBUILD)
    }
    local zoneCacheModeLookup = {
        [SafeGetString(NMGH_SETTINGS_ZONE_CACHE_MODE_STALE_ASYNC)] = "stale_async",
        [SafeGetString(NMGH_SETTINGS_ZONE_CACHE_MODE_FORCE_REBUILD)] = "force"
    }
    local zoneCacheModeReverseLookup = {
        stale_async = SafeGetString(NMGH_SETTINGS_ZONE_CACHE_MODE_STALE_ASYNC),
        force = SafeGetString(NMGH_SETTINGS_ZONE_CACHE_MODE_FORCE_REBUILD)
    }
    local profileNameByLabel = {
        [SafeGetString(NMGH_SETTINGS_PROFILE_PERFORMANCE)] = "Performance",
        [SafeGetString(NMGH_SETTINGS_PROFILE_ACCURACY)] = "Accuracy",
        [SafeGetString(NMGH_SETTINGS_PROFILE_BALANCED)] = "Balanced"
    }
    local profileLabelByName = {
        Performance = SafeGetString(NMGH_SETTINGS_PROFILE_PERFORMANCE),
        Accuracy = SafeGetString(NMGH_SETTINGS_PROFILE_ACCURACY),
        Balanced = SafeGetString(NMGH_SETTINGS_PROFILE_BALANCED),
    }
    local seasonalTimezoneChoices = {
        "America/New_York",
        "UTC",
    }
    local seasonalDefaults = GetSeasonalDefaults()
    local panelData = {
        type = "panel",
        name = Addon.name,
        displayName = Addon.displayName,
        author = "SassyKyle",
        version = Addon.version,
        slashCommand = (Addon.Constants and Addon.Constants.SLASH and Addon.Constants.SLASH.ALT) or "/misfit",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsTable = {
        {
            type = "header",
            name = SafeGetString(NMGH_SETTINGS_HEADER_GENERAL),
            width = "full",
        },
        {
            type = "checkbox",
            name = SafeGetString(NMGH_SETTINGS_HIDE_GOLDEN_PURSUITS),
            tooltip = SafeGetString(NMGH_SETTINGS_TOOLTIP_HIDE_GOLDEN_PURSUITS),
            getFunc = function()
                return Addon.db.hideGoldenPursuits
            end,
            setFunc = function(enabled)
                Addon.db.hideGoldenPursuits = enabled
                if Addon.UpdateGoldenPursuitsVisibility then
                    Addon:UpdateGoldenPursuitsVisibility()
                end
            end,
            default = Addon.defaults.hideGoldenPursuits,
            width = "full",
        },
        {
            type = "checkbox",
            name = SafeGetString(NMGH_SETTINGS_CHAT_ICON),
            getFunc = function()
                return Addon.db.showChatIcon
            end,
            setFunc = function(show)
                Addon.db.showChatIcon = show
                if Addon.ChatIcon then
                    Addon.ChatIcon:SetVisible(show)
                end
            end,
            default = Addon.defaults.showChatIcon,
            width = "full",
        },
        {
            type = "checkbox",
            name = SafeGetString(NMGH_SETTINGS_MONOCHROME_ICON),
            getFunc = function()
                return Addon.db.monochromeIcon
            end,
            setFunc = function(monochrome)
                Addon.db.monochromeIcon = monochrome
                if Addon.ChatIcon then
                    Addon.ChatIcon:SetTexture(monochrome)
                end
                if Addon.Message then
                    Addon.Message:UpdatePrefixIcon(nil, monochrome)
                end
            end,
            disabled = function()
                return not Addon.db.showChatIcon
            end,
            width = "full",
        },
        {
            type = "header",
            name = SafeGetString(NMGH_SETTINGS_ICON_HEADER),
            width = "full",
        },
        {
            type = "dropdown",
            name = SafeGetString(NMGH_SETTINGS_ICON_STYLE),
            tooltip = SafeGetString(NMGH_SETTINGS_TOOLTIP_ICON_STYLE),
            choices = {"New", "Legacy"},
            getFunc = function()
                local style = Addon.db.chatIconStyle or Addon.defaults.chatIconStyle or "new"
                return style == "legacy" and "Legacy" or "New"
            end,
            setFunc = function(value)
                local style = (value == "Legacy") and "legacy" or "new"
                Addon.db.chatIconStyle = style
                local mono = Addon.db.monochromeIcon or false
                if Addon.ChatIcon then
                    Addon.ChatIcon:SetTexture(mono)
                end
                if Addon.Message then
                    Addon.Message:UpdatePrefixIcon(style, mono)
                end
            end,
            default = "New",
            width = "full",
            disabled = function()
                return not Addon.db.showChatIcon
            end,
        },
        {
            type = "slider",
            name = SafeGetString(NMGH_SETTINGS_CHAT_ICON_SIZE),
            tooltip = SafeGetString(NMGH_SETTINGS_TOOLTIP_CHAT_ICON_SIZE),
            min = 16,
            max = 128,
            step = 2,
            getFunc = function()
                return SafeGetSliderValue(Addon.db.chatIconSize, Addon.defaults.chatIconSize, 16, 128)
            end,
            setFunc = function(value)
                Addon.db.chatIconSize = ValidateSliderValue(value, 16, 128, Addon.defaults.chatIconSize)
                -- Update icon size if icon exists
                if Addon.ChatIcon then
                    Addon.ChatIcon:SetSize(value)
                end
            end,
            default = Addon.defaults.chatIconSize,
            width = "full",
            getValueDisplayFunc = function(value)
                return string.format("%d %s", value, SafeGetString(NMGH_SETTINGS_UNIT_PIXELS))
            end,
            disabled = function()
                return not Addon.db.showChatIcon
            end,
        },
        {
            type = "checkbox",
            name = SafeGetString(NMGH_SETTINGS_UNLOCK_CHAT_ICON_POSITION),
            tooltip = SafeGetString(NMGH_SETTINGS_TOOLTIP_UNLOCK_CHAT_ICON_POSITION),
            getFunc = function()
                return not Addon.db.chatIconLocked
            end,
            setFunc = function(unlocked)
                Addon.db.chatIconLocked = not unlocked
                if Addon.ChatIcon then
                    Addon.ChatIcon:SetLocked(not unlocked)
                end
            end,
            default = not Addon.defaults.chatIconLocked,
            disabled = function()
                return not Addon.db.showChatIcon
            end,
            width = "full",
        },
        {
            type = "button",
            name = SafeGetString(NMGH_SETTINGS_RESET_CHAT_ICON_POSITION),
            tooltip = SafeGetString(NMGH_SETTINGS_TOOLTIP_RESET_CHAT_ICON_POSITION),
            func = function()
                if Addon.ChatIcon then
                    Addon.ChatIcon:ResetPosition()
                end
            end,
            disabled = function()
                return not Addon.db.showChatIcon
            end,
            width = "full",
        },
        {
            type = "header",
            name = SafeGetString(NMGH_SETTINGS_HEADER_SEASONAL),
            width = "full",
        },
        {
            type = "checkbox",
            name = SafeGetString(NMGH_SETTINGS_SEASONAL_ENABLED),
            tooltip = SafeGetString(NMGH_SETTINGS_TOOLTIP_SEASONAL_ENABLED),
            getFunc = function()
                return EnsureSeasonalConfig().enabled
            end,
            setFunc = function(enabled)
                EnsureSeasonalConfig().enabled = enabled == true
                ApplySeasonalSettings()
            end,
            default = seasonalDefaults.enabled ~= false,
            width = "full",
        },
        {
            type = "checkbox",
            name = SafeGetString(NMGH_SETTINGS_SEASONAL_OWN_UI),
            tooltip = SafeGetString(NMGH_SETTINGS_TOOLTIP_SEASONAL_OWN_UI),
            getFunc = function()
                return EnsureSeasonalConfig().ownUi
            end,
            setFunc = function(enabled)
                EnsureSeasonalConfig().ownUi = enabled == true
                ApplySeasonalSettings()
            end,
            default = seasonalDefaults.ownUi ~= false,
            disabled = function()
                return not EnsureSeasonalConfig().enabled
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = SafeGetString(NMGH_SETTINGS_SEASONAL_CHAT_MESSAGES),
            tooltip = SafeGetString(NMGH_SETTINGS_TOOLTIP_SEASONAL_CHAT_MESSAGES),
            getFunc = function()
                return EnsureSeasonalConfig().chatMessages
            end,
            setFunc = function(enabled)
                EnsureSeasonalConfig().chatMessages = enabled == true
                ApplySeasonalSettings()
            end,
            default = seasonalDefaults.chatMessages ~= false,
            disabled = function()
                return not EnsureSeasonalConfig().enabled
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = SafeGetString(NMGH_SETTINGS_SEASONAL_NATIVE_GUILD_UI),
            tooltip = SafeGetString(NMGH_SETTINGS_TOOLTIP_SEASONAL_NATIVE_GUILD_UI),
            getFunc = function()
                return EnsureSeasonalConfig().nativeGuildUi
            end,
            setFunc = function(enabled)
                EnsureSeasonalConfig().nativeGuildUi = enabled == true
                ApplySeasonalSettings()
            end,
            default = seasonalDefaults.nativeGuildUi ~= false,
            disabled = function()
                return not EnsureSeasonalConfig().enabled
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = SafeGetString(NMGH_SETTINGS_SEASONAL_KEEP_OWNERSHIP),
            tooltip = SafeGetString(NMGH_SETTINGS_TOOLTIP_SEASONAL_KEEP_OWNERSHIP),
            getFunc = function()
                return EnsureSeasonalConfig().keepOwnership
            end,
            setFunc = function(enabled)
                EnsureSeasonalConfig().keepOwnership = enabled == true
                ApplySeasonalSettings()
            end,
            default = seasonalDefaults.keepOwnership ~= false,
            disabled = function()
                return not EnsureSeasonalConfig().enabled
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = SafeGetString(NMGH_SETTINGS_SEASONAL_TRADER_UI),
            tooltip = SafeGetString(NMGH_SETTINGS_TOOLTIP_SEASONAL_TRADER_UI),
            getFunc = function()
                return EnsureSeasonalConfig().traderUi
            end,
            setFunc = function(enabled)
                EnsureSeasonalConfig().traderUi = enabled == true
                ApplySeasonalSettings()
            end,
            default = seasonalDefaults.traderUi ~= false,
            disabled = function()
                return not EnsureSeasonalConfig().enabled
            end,
            width = "full",
        },
        {
            type = "header",
            name = SafeGetString(NMGH_SETTINGS_HEADER_SEASONAL_OVERRIDE),
            width = "full",
        },
        {
            type = "checkbox",
            name = SafeGetString(NMGH_SETTINGS_SEASONAL_OVERRIDE_ENABLED),
            tooltip = SafeGetString(NMGH_SETTINGS_TOOLTIP_SEASONAL_OVERRIDE_ENABLED),
            getFunc = function()
                return GetMisfitsBirthdayOverride().enabled == true
            end,
            setFunc = function(enabled)
                GetMisfitsBirthdayOverride().enabled = enabled == true
                ApplySeasonalSettings()
            end,
            default = false,
            disabled = function()
                return not EnsureSeasonalConfig().enabled
            end,
            width = "full",
        },
        {
            type = "dropdown",
            name = SafeGetString(NMGH_SETTINGS_SEASONAL_OVERRIDE_TIMEZONE),
            tooltip = SafeGetString(NMGH_SETTINGS_TOOLTIP_SEASONAL_OVERRIDE_TIMEZONE),
            choices = seasonalTimezoneChoices,
            getFunc = function()
                return GetMisfitsBirthdayOverride().timezone or "America/New_York"
            end,
            setFunc = function(value)
                local override = GetMisfitsBirthdayOverride()
                if value == "UTC" or value == "America/New_York" then
                    override.timezone = value
                    ApplySeasonalSettings()
                end
            end,
            default = "America/New_York",
            disabled = function()
                return not EnsureSeasonalConfig().enabled or not GetMisfitsBirthdayOverride().enabled
            end,
            width = "full",
        },
        {
            type = "editbox",
            name = SafeGetString(NMGH_SETTINGS_SEASONAL_OVERRIDE_START_DATE),
            tooltip = SafeGetString(NMGH_SETTINGS_TOOLTIP_SEASONAL_OVERRIDE_START_DATE),
            getFunc = function()
                return FormatOverrideDate(GetMisfitsBirthdayOverride().start)
            end,
            setFunc = function(value)
                local override = GetMisfitsBirthdayOverride()
                if ParseOverrideDate(value, override.start) then
                    ApplySeasonalSettings()
                end
            end,
            default = "",
            isMultiline = false,
            disabled = function()
                return not EnsureSeasonalConfig().enabled or not GetMisfitsBirthdayOverride().enabled
            end,
            width = "full",
        },
        {
            type = "editbox",
            name = SafeGetString(NMGH_SETTINGS_SEASONAL_OVERRIDE_START_TIME),
            tooltip = SafeGetString(NMGH_SETTINGS_TOOLTIP_SEASONAL_OVERRIDE_START_TIME),
            getFunc = function()
                return FormatOverrideTime(GetMisfitsBirthdayOverride().start)
            end,
            setFunc = function(value)
                local override = GetMisfitsBirthdayOverride()
                if ParseOverrideTime(value, override.start) then
                    ApplySeasonalSettings()
                end
            end,
            default = "00:00:00",
            isMultiline = false,
            disabled = function()
                return not EnsureSeasonalConfig().enabled or not GetMisfitsBirthdayOverride().enabled
            end,
            width = "full",
        },
        {
            type = "editbox",
            name = SafeGetString(NMGH_SETTINGS_SEASONAL_OVERRIDE_END_DATE),
            tooltip = SafeGetString(NMGH_SETTINGS_TOOLTIP_SEASONAL_OVERRIDE_END_DATE),
            getFunc = function()
                return FormatOverrideDate(GetMisfitsBirthdayOverride()["end"])
            end,
            setFunc = function(value)
                local override = GetMisfitsBirthdayOverride()
                if ParseOverrideDate(value, override["end"]) then
                    ApplySeasonalSettings()
                end
            end,
            default = "",
            isMultiline = false,
            disabled = function()
                return not EnsureSeasonalConfig().enabled or not GetMisfitsBirthdayOverride().enabled
            end,
            width = "full",
        },
        {
            type = "editbox",
            name = SafeGetString(NMGH_SETTINGS_SEASONAL_OVERRIDE_END_TIME),
            tooltip = SafeGetString(NMGH_SETTINGS_TOOLTIP_SEASONAL_OVERRIDE_END_TIME),
            getFunc = function()
                return FormatOverrideTime(GetMisfitsBirthdayOverride()["end"])
            end,
            setFunc = function(value)
                local override = GetMisfitsBirthdayOverride()
                if ParseOverrideTime(value, override["end"]) then
                    ApplySeasonalSettings()
                end
            end,
            default = "23:59:59",
            isMultiline = false,
            disabled = function()
                return not EnsureSeasonalConfig().enabled or not GetMisfitsBirthdayOverride().enabled
            end,
            width = "full",
        },
        {
            type = "header",
            name = SafeGetString(NMGH_SETTINGS_HEADER_TELEPORT),
            width = "full",
        },
        {
            type = "dropdown",
            name = SafeGetString(NMGH_SETTINGS_NO_GUILD_LEAVE),
            tooltip = SafeGetString(NMGH_SETTINGS_TOOLTIP_NO_GUILD_LEAVE),
            choices = leaveOption,
            getFunc = function()
                return leaveOption[Addon.db.noGuildLeave + 1]
            end,
            setFunc = function(value)
                local mode = leaveOptionLookup[value]
                Addon.db.noGuildLeave = mode
                if Addon.CheckNoGuildLeave then
                    Addon:CheckNoGuildLeave()
                end
                
                -- Provide feedback message when changing settings
                if mode ~= 0 then
                    if log then
                        log:Info(GetString(NMGH_MSG_GUILD_LEAVE_PROTECT_ENABLED))
                    end
                else
                    if log then
                        log:Info(GetString(NMGH_MSG_GUILD_LEAVE_PROTECT_DISABLED))
                    end
                end
            end,
            default = leaveOption[Addon.defaults.noGuildLeave + 1],
        },
        {
            type = "slider",
            name = SafeGetString(NMGH_SETTINGS_ZONE_CACHE_DURATION),
            tooltip = SafeGetString(NMGH_SETTINGS_TOOLTIP_ZONE_CACHE_DURATION),
            min = 5,
            max = 120,
            step = 5,
            getFunc = function()
                return SafeGetSliderValue(Addon.db.zoneCacheDurationSeconds, Addon.defaults.zoneCacheDurationSeconds, 5, 120)
            end,
            setFunc = function(value)
                Addon.db.zoneCacheDurationSeconds = ValidateSliderValue(value, 5, 120, Addon.defaults.zoneCacheDurationSeconds)
            end,
            default = Addon.defaults.zoneCacheDurationSeconds,
            width = "full",
            getValueDisplayFunc = function(value)
                return string.format("%d seconds", value)
            end,
        },
        {
            type = "slider",
            name = SafeGetString(NMGH_SETTINGS_ZONE_CACHE_REFRESH_COOLDOWN),
            tooltip = SafeGetString(NMGH_SETTINGS_TOOLTIP_ZONE_CACHE_REFRESH_COOLDOWN),
            min = 0,
            max = 30,
            step = 1,
            getFunc = function()
                return SafeGetSliderValue(Addon.db.zoneCacheRefreshCooldownSeconds, Addon.defaults.zoneCacheRefreshCooldownSeconds, 0, 30)
            end,
            setFunc = function(value)
                Addon.db.zoneCacheRefreshCooldownSeconds = ValidateSliderValue(value, 0, 30, Addon.defaults.zoneCacheRefreshCooldownSeconds)
            end,
            default = Addon.defaults.zoneCacheRefreshCooldownSeconds,
            width = "full",
            getValueDisplayFunc = function(value)
                return string.format("%d seconds", value)
            end,
        },
        {
            type = "slider",
            name = SafeGetString(NMGH_SETTINGS_MAX_GUILD_MEMBERS),
            tooltip = SafeGetString(NMGH_SETTINGS_TOOLTIP_MAX_GUILD_MEMBERS),
            min = 10,
            max = 500,
            step = 10,
            getFunc = function()
                return SafeGetSliderValue(Addon.db.maxGuildMembersToCheck, Addon.defaults.maxGuildMembersToCheck, 10, 500)
            end,
            setFunc = function(value)
                Addon.db.maxGuildMembersToCheck = ValidateSliderValue(value, 10, 500, Addon.defaults.maxGuildMembersToCheck)
                if Addon.modulesLoaded and Addon.modulesLoaded.teleport and Addon.Teleport and Addon.Teleport.RefreshZoneCache and type(Addon.Teleport.RefreshZoneCache) == "function" then
                    pcall(Addon.Teleport.RefreshZoneCache, Addon.Teleport)
                end
            end,
            default = Addon.defaults.maxGuildMembersToCheck,
            width = "full",
            getValueDisplayFunc = function(value)
                return string.format("%d members", value)
            end,
        },
        {
            type = "checkbox",
            name = SafeGetString(NMGH_SETTINGS_DYNAMIC_GUILD_SCAN),
            tooltip = SafeGetString(NMGH_SETTINGS_TOOLTIP_DYNAMIC_GUILD_SCAN),
            getFunc = function()
                return Addon.db.dynamicGuildScanScaling ~= false
            end,
            setFunc = function(enabled)
                Addon.db.dynamicGuildScanScaling = enabled and true or false
                if Addon.modulesLoaded and Addon.modulesLoaded.teleport and Addon.Teleport and Addon.Teleport.RefreshZoneCache and type(Addon.Teleport.RefreshZoneCache) == "function" then
                    pcall(Addon.Teleport.RefreshZoneCache, Addon.Teleport)
                end
            end,
            default = Addon.defaults.dynamicGuildScanScaling,
            width = "full",
        },
        {
            type = "dropdown",
            name = SafeGetString(NMGH_SETTINGS_ZONE_CACHE_REBUILD_MODE),
            tooltip = SafeGetString(NMGH_SETTINGS_TOOLTIP_ZONE_CACHE_REBUILD_MODE),
            choices = zoneCacheModeOptions,
            getFunc = function()
                local mode = Addon.db.zoneCacheRebuildMode or Addon.defaults.zoneCacheRebuildMode
                return zoneCacheModeReverseLookup[mode] or zoneCacheModeOptions[1]
            end,
            setFunc = function(value)
                Addon.db.zoneCacheRebuildMode = zoneCacheModeLookup[value] or Addon.defaults.zoneCacheRebuildMode
                if Addon.modulesLoaded and Addon.modulesLoaded.teleport and Addon.Teleport and Addon.Teleport.RefreshZoneCache and type(Addon.Teleport.RefreshZoneCache) == "function" then
                    pcall(Addon.Teleport.RefreshZoneCache, Addon.Teleport)
                end
            end,
            default = zoneCacheModeReverseLookup[Addon.defaults.zoneCacheRebuildMode] or zoneCacheModeOptions[1],
            width = "full",
        },
        {
            type = "header",
            name = SafeGetString(NMGH_SETTINGS_HEADER_PROFILES),
            width = "full",
        },
        {
            type = "dropdown",
            name = SafeGetString(NMGH_SETTINGS_APPLY_PROFILE),
            tooltip = SafeGetString(NMGH_SETTINGS_TOOLTIP_APPLY_PROFILE),
            choices = {
                SafeGetString(NMGH_SETTINGS_PROFILE_PERFORMANCE),
                SafeGetString(NMGH_SETTINGS_PROFILE_ACCURACY),
                SafeGetString(NMGH_SETTINGS_PROFILE_BALANCED)
            },
            getFunc = function()
                local applied = Addon and Addon.db and Addon.db.appliedProfile
                return profileLabelByName[applied] or SafeGetString(NMGH_SETTINGS_PROFILE_BALANCED)
            end,
            setFunc = function(value)
                self:ApplyProfile(profileNameByLabel[value])
            end,
            width = "full",
        },
        {
            type = "header",
            name = SafeGetString(NMGH_SETTINGS_HEADER_IMPORT_EXPORT),
            width = "full",
        },
        {
            type = "button",
            name = SafeGetString(NMGH_SETTINGS_EXPORT),
            tooltip = SafeGetString(NMGH_SETTINGS_TOOLTIP_EXPORT),
            func = function()
                local exported = self:ExportSettings()
                if exported then
                    if Addon and Addon.UI and Addon.UI.ShowExportModal then
                        Addon.UI:ShowExportModal(exported)
                    else
                        if log then
                            log:Info(GetString(NMGH_MSG_SETTINGS_EXPORTED_FEEDBACK))
                            log:Info(exported)
                        end
                    end
                end
            end,
            width = "half",
        },
        {
            type = "button",
            name = SafeGetString(NMGH_SETTINGS_IMPORT),
            tooltip = SafeGetString(NMGH_SETTINGS_TOOLTIP_IMPORT),
            func = function()
                if Addon and Addon.UI and Addon.UI.ShowImportModal then
                    Addon.UI:ShowImportModal()
                else
                    if log then
                        log:Info(GetString(NMGH_MSG_SETTINGS_IMPORT_HELP))
                    end
                end
            end,
            width = "half",
        },
        {
            type = "header",
            name = SafeGetString(NMGH_SETTINGS_HEADER_QUEUE_WIDGET),
            width = "full",
        },
        {
            type = "checkbox",
            name = SafeGetString(NMGH_SETTINGS_QUEUE_WIDGET_ENABLED),
            tooltip = SafeGetString(NMGH_SETTINGS_TOOLTIP_QUEUE_WIDGET_ENABLED),
            getFunc = function()
                return Addon.db.queueWidgetEnabled ~= false
            end,
            setFunc = function(enabled)
                Addon.db.queueWidgetEnabled = enabled == true
                if Addon.QueueWidget and Addon.QueueWidget.Refresh then
                    Addon.QueueWidget:Refresh()
                end
            end,
            default = Addon.defaults.queueWidgetEnabled,
            width = "full",
        },
        {
            type = "checkbox",
            name = SafeGetString(NMGH_SETTINGS_UNLOCK_QUEUE_WIDGET_POSITION),
            tooltip = SafeGetString(NMGH_SETTINGS_TOOLTIP_UNLOCK_QUEUE_WIDGET_POSITION),
            getFunc = function()
                return Addon.db.queueWidgetLocked == false
            end,
            setFunc = function(unlocked)
                Addon.db.queueWidgetLocked = not (unlocked == true)
                if Addon.QueueWidget and Addon.QueueWidget.SetLocked then
                    Addon.QueueWidget:SetLocked(Addon.db.queueWidgetLocked)
                end
            end,
            default = Addon.defaults.queueWidgetLocked == false,
            width = "full",
        },
        {
            type = "slider",
            name = SafeGetString(NMGH_SETTINGS_QUEUE_WIDGET_SCALE),
            tooltip = SafeGetString(NMGH_SETTINGS_TOOLTIP_QUEUE_WIDGET_SCALE),
            min = 0.7,
            max = 1.6,
            step = 0.05,
            getFunc = function()
                return tonumber(Addon.db.queueWidgetScale) or 1.0
            end,
            setFunc = function(value)
                Addon.db.queueWidgetScale = value
                if Addon.QueueWidget and Addon.QueueWidget.SetScale then
                    Addon.QueueWidget:SetScale(value)
                end
            end,
            default = Addon.defaults.queueWidgetScale or 1.0,
            width = "full",
        },
        {
            type = "button",
            name = SafeGetString(NMGH_SETTINGS_RESET_QUEUE_WIDGET_POSITION),
            tooltip = SafeGetString(NMGH_SETTINGS_TOOLTIP_RESET_QUEUE_WIDGET_POSITION),
            func = function()
                if Addon.QueueWidget and Addon.QueueWidget.ResetPosition then
                    Addon.QueueWidget:ResetPosition()
                end
            end,
            width = "half",
        },
        {
            type = "header",
            name = SafeGetString(NMGH_SETTINGS_HEADER_ADVANCED),
            width = "full",
        },
        {
            type = "checkbox",
            name = SafeGetString(NMGH_SETTINGS_DEBUG_LOGGING),
            tooltip = SafeGetString(NMGH_SETTINGS_TOOLTIP_DEBUG_LOGGING),
            getFunc = function()
                return Addon.db.debug
            end,
            setFunc = function(enabled)
                Addon.db.debug = enabled
            end,
            default = Addon.defaults.debug,
            width = "full",
        },
        {
            type = "button",
            name = SafeGetString(NMGH_SETTINGS_RESET_TO_DEFAULTS),
            tooltip = SafeGetString(NMGH_SETTINGS_TOOLTIP_RESET_TO_DEFAULTS),
            func = function()
                self:ResetToDefaults()
                if log then
                    log:Info(GetString(NMGH_MSG_SETTINGS_RESET_DONE))
                end
            end,
            width = "half",
            warning = SafeGetString(NMGH_SETTINGS_WARNING_RESET_TO_DEFAULTS),
        },
    }

    -- Convert the long flat list into collapsible sections (LAM2 submenu) using headers as section markers.
    local function ConvertHeadersToSubmenus(flat)
        local out = {}
        local current = nil
        for _, opt in ipairs(flat) do
            if type(opt) == "table" and opt.type == "header" then
                if current then
                    out[#out + 1] = current
                end
                current = { type = "submenu", name = opt.name or "", controls = {} }
            else
                if not current then
                    current = { type = "submenu", name = Addon.displayName or Addon.name, controls = {} }
                end
                current.controls[#current.controls + 1] = opt
            end
        end
        if current then
            out[#out + 1] = current
        end
        return out
    end

    optionsTable = ConvertHeadersToSubmenus(optionsTable)

    self.panel = LAM2:RegisterAddonPanel(Addon.name .. "Options", panelData)
    Addon.panel = self.panel
    LAM2:RegisterOptionControls(Addon.name .. "Options", optionsTable)
end

-- Reset all settings to defaults
function Settings:ResetToDefaults()
    local log = SettingsLogger()
    if not Addon.db or not Addon.defaults then
        if log then
            log:Error(GetString(NMGH_ERR_SETTINGS_RESET_FAILED))
        end
        return
    end
    
    -- Copy all default values to current settings
    for key, value in pairs(Addon.defaults) do
        Addon.db[key] = DeepCopy(value)
    end
    
    self:ApplyRuntimeState("reset")
end

function Settings:ApplyRuntimeState(reason)
    if not (Addon and Addon.db) then
        return
    end

    EnsureSeasonalConfig()

    if reason == "reset" then
        Addon.db.windowPositionSaved = nil
    end

    ApplyChatIconRuntimeState(reason)
    ApplyQueueWidgetRuntimeState(reason)

    if Addon.Message then
        Addon.Message:ApplySettings()
        Addon.Message:UpdatePrefixIcon()
    end

    if Addon.UpdateGoldenPursuitsVisibility then
        pcall(Addon.UpdateGoldenPursuitsVisibility, Addon)
    end

    ApplySeasonalSettings()
    ApplyUiRuntimeState(reason)

    if Addon.modulesLoaded and Addon.modulesLoaded.teleport and Addon.Teleport and Addon.Teleport.RefreshZoneCache then
        Addon.Teleport:RefreshZoneCache()
    end
end

-- Initialize Settings Module
function Settings:Initialize()
    if self.initialized then return end
    
    self:MigrateSettings()
    
    -- Update Message prefix icon now that db is ready
    if Addon.Message then
        Addon.Message:ApplySettings()
        Addon.Message:UpdatePrefixIcon()
    end

    self:InitializeMenu()
    
    self.initialized = true
end

-- Export module
Addon.Settings = Settings

return Settings
