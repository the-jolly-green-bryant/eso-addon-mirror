-- Message Module
-- Centralized messaging system with formatting, interpolation, and rate limiting
-- Dependencies: LibDebugLogger (optional)
-- Provides structured logging with custom formatters and placeholder support

local Addon = NMGuildHall
local Constants = Addon and Addon.Constants

local Message = {
    name = "NMGuildHall",
    colors = {
        INFO = "ea4e49",
        WARNING = "ffcc33",
        ERROR = "ff3333",
        DEBUG = "9aa0a6",
    },
    initialized = false,
    -- Formatter functions for common data types
    formatters = {},
    -- Rate limiting to prevent chat spam
    rateLimit = {
        maxMessages = 5,
        timeWindow = 1000, -- 1 second
        messageQueue = {},
        lastCleanup = 0
    },
    -- Cached tagged loggers for performance
    taggedLoggers = {},
    -- Default prefix icon (fallback before db is ready or if separated)
    prefixIcon = "NMGuildHall/Icons/new/misfit_logo.dds"
}

-- Initialize the message module
function Message:Initialize()
    if self.initialized then
        return
    end
    
    self._ldl = nil
    self._subLoggers = {}
    self.taggedLoggers = {}
    self.initialized = true
    
    -- Register default formatters
    self:RegisterDefaultFormatters()
    
    -- Try to get LibDebugLogger if available
    self:_EnsureDebugLogger()
    
    -- Initialize prefix icon from constants or default
    self:UpdatePrefixIcon()

    self:ApplySettings()
end

function Message:ApplySettings()
    if not (Addon and Addon.db) then
        return
    end

    self.rateLimit.maxMessages = tonumber(Addon.db.messageRateLimit) or 5
    self.rateLimit.timeWindow = tonumber(Addon.db.messageRateLimitWindow) or 1000
    self.rateLimit.messageQueue = {}
    self.rateLimit.lastCleanup = 0
end

-- Update the prefix icon used in chat messages
function Message:UpdatePrefixIcon(style, mono)
    -- If no arguments provided, try to read from Addon.db or use defaults
    if style == nil then
        style = (Addon and Addon.db and Addon.db.chatIconStyle) or "new"
    end
    if mono == nil then
        mono = (Addon and Addon.db and Addon.db.monochromeIcon) or false
    end

    local sets = Addon and Addon.Constants and Addon.Constants.CHAT_ICON and Addon.Constants.CHAT_ICON.SETS
    local textures = sets and sets[style]
    
    if textures then
        self.prefixIcon = mono and textures.MONO or textures.NORMAL
    else
        -- Absolute fallback
        self.prefixIcon = mono and "NMGuildHall/Icons/new/mono_misfit_logo.dds" or "NMGuildHall/Icons/new/misfit_logo.dds"
    end
end

-- Register default formatters for common types
function Message:RegisterDefaultFormatters()
    -- Number formatter with thousands separator
    self.formatters.number = function(value)
        local str = tostring(value)
        local formatted = str:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
        return formatted
    end
    
    -- Gold formatter (number with gold icon)
    self.formatters.gold = function(value)
        local icon = Constants and Constants.MEDIA and Constants.MEDIA.ICONS and Constants.MEDIA.ICONS.GOLD or ""
        return self.formatters.number(value) .. " " .. icon
    end
    
    -- Percentage formatter
    self.formatters.percent = function(value)
        return string.format("%.1f%%", tonumber(value) or 0)
    end
    
    -- Boolean formatter (Yes/No)
    self.formatters.bool = function(value)
        return value and "Yes" or "No"
    end
    
    -- Time formatter (seconds to readable format)
    self.formatters.time = function(seconds)
        seconds = tonumber(seconds) or 0
        if seconds < 60 then
            return string.format("%.0fs", seconds)
        elseif seconds < 3600 then
            return string.format("%.0fm %.0fs", math.floor(seconds / 60), seconds % 60)
        else
            return string.format("%.0fh %.0fm", math.floor(seconds / 3600), (seconds % 3600) / 60)
        end
    end
    
    -- Player name formatter (with @ symbol if needed)
    self.formatters.player = function(value)
        local str = tostring(value)
        if string.sub(str, 1, 1) ~= "@" then
            return "@" .. str
        end
        return str
    end
    
    -- Zone name formatter (with color)
    self.formatters.zone = function(value)
        local crimson = Constants and Constants.UI and Constants.UI.COLORS and Constants.UI.COLORS.CRIMSON_TEXT or ""
        return crimson .. tostring(value) .. "|r"
    end
    
    -- List formatter (comma-separated)
    self.formatters.list = function(value)
        if type(value) ~= "table" then
            return tostring(value)
        end
        return table.concat(value, ", ")
    end
    
    -- Count formatter (1 item vs 2 items)
    self.formatters.count = function(value, singular, plural)
        local num = tonumber(value) or 0
        local unit = num == 1 and (singular or "item") or (plural or singular .. "s" or "items")
        return self.formatters.number(num) .. " " .. unit
    end
end

-- Enhanced interpolation with formatter support
function Message:_Interpolate(text, placeholders)
    if not placeholders or type(placeholders) ~= "table" then
        return text
    end

    local out = text
    
    -- Handle enhanced format: {key:formatter} or {key:formatter:arg1:arg2}
    out = string.gsub(out, "{([%w_]+):([%w_]+)([^}]*)}", function(key, formatter, args)
        local value = placeholders[key]
        if value == nil then
            return "{" .. key .. ":" .. formatter .. args .. "}"
        end
        
        -- Parse additional arguments
        local formatterArgs = {}
        if args and args ~= "" then
            -- Remove leading colon
            args = string.gsub(args, "^:", "")
            for arg in string.gmatch(args, "([^:]+)") do
                table.insert(formatterArgs, arg)
            end
        end
        
        -- Apply formatter if it exists
        if self.formatters[formatter] then
            local success, result = pcall(self.formatters[formatter], value, unpack(formatterArgs))
            if success then
                return result
            else
                if Addon and Addon.Warn then
                    Addon:Warn(GetString(NMGH_ERR_API_CALL_FAILED), {error = tostring(result)})
                end
                return tostring(value)
            end
        end

        -- Unknown formatter: fall back to raw value instead of blanking the token.
        return tostring(value)
    end)
    
    -- Handle simple format: {key}
    out = string.gsub(out, "{([%w_]+)}", function(key)
        local value = placeholders[key]
        if value == nil then
            return "{" .. key .. "}"
        end
        return tostring(value)
    end)

    -- Handle numeric indexed format: <<1>>, <<2>>
    out = string.gsub(out, "<<(%d+)>>", function(index)
        local n = tonumber(index)
        local value = nil
        if n ~= nil then
            value = placeholders[n]
        end
        if value == nil then
            value = placeholders[index]
        end
        if value == nil then
            return "<<" .. index .. ">>"
        end
        return tostring(value)
    end)

    -- Handle conditional format: {?key:then:else} (if key is truthy, show 'then', else show 'else')
    -- Use non-greedy matching to handle nested colons properly
    out = string.gsub(out, "{%?([%w_]+):(.-):(.-)}", function(key, thenText, elseText)
        local value = placeholders[key]
        if value and value ~= false and value ~= 0 and value ~= "" then
            return thenText
        else
            return elseText
        end
    end)
    
    -- Handle plural format: {key|singular|plural|zero}
    out = string.gsub(out, "{([%w_]+)|([^|]*)|([^|]*)|([^}]*)}", function(key, singular, plural, zero)
        local value = placeholders[key]
        if value == nil then
            return "{" .. key .. "|" .. singular .. "|" .. plural .. "|" .. zero .. "}"
        end
        local num = tonumber(value) or 0
        if num == 0 and zero and zero ~= "" then
            return zero
        elseif num == 1 then
            return singular
        else
            return plural
        end
    end)
    
    -- Handle backward compatibility: {key|singular|plural}
    out = string.gsub(out, "{([%w_]+)|([^|]*)|([^}]*)}", function(key, singular, plural)
        local value = placeholders[key]
        if value == nil then
            return "{" .. key .. "|" .. singular .. "|" .. plural .. "}"
        end
        local num = tonumber(value) or 0
        return (num == 1) and singular or plural
    end)

    return out
end

-- Check if message should be rate limited
function Message:_IsRateLimited()
    local currentTime = GetGameTimeMilliseconds()
    local queue = self.rateLimit.messageQueue
    
    -- Clean up old messages
    if currentTime - self.rateLimit.lastCleanup > self.rateLimit.timeWindow then
        for i = #queue, 1, -1 do
            if currentTime - queue[i].time > self.rateLimit.timeWindow then
                table.remove(queue, i)
            end
        end
        self.rateLimit.lastCleanup = currentTime
    end
    
    -- Check if we've exceeded the limit
    return #queue >= self.rateLimit.maxMessages
end

-- Add message to rate limit queue
function Message:_AddToRateLimitQueue()
    table.insert(self.rateLimit.messageQueue, {
        time = GetGameTimeMilliseconds()
    })
end

-- Register a custom formatter
function Message:RegisterFormatter(name, handler)
    if not name or type(handler) ~= "function" then
        if Addon and Addon.Err then
            Addon:Err(GetString(NMGH_ERR_EVENT_HANDLER_NOT_FUNC))
        end
        return false
    end
    
    self.formatters[name] = handler
    return true
end

function Message:_EnsureDebugLogger()
    if self._ldl ~= nil then
        return
    end

    local ok, logger = pcall(function()
        if LibDebugLogger and type(LibDebugLogger) == "function" then
            return LibDebugLogger(self.name)
        end
        if LibDebugLogger and LibDebugLogger.Create then
            return LibDebugLogger:Create(self.name)
        end
        return nil
    end)

    if ok then
        self._ldl = logger
    else
        self._ldl = false
    end

    self._subLoggers = {}
end

function Message:_GetLogger(tag)
    self:_EnsureDebugLogger()
    if not self._ldl or self._ldl == false then
        return nil
    end

    if not tag or tag == "" then
        return self._ldl
    end

    local cached = self._subLoggers[tag]
    if cached ~= nil then
        return cached or nil
    end

    local ok, sub = pcall(function()
        if self._ldl.Create then
            return self._ldl:Create(tag)
        end
        return nil
    end)

    if ok and sub then
        self._subLoggers[tag] = sub
        return sub
    end

    self._subLoggers[tag] = false
    return nil
end

function Message:_ChatOut(chatMessage, level, plainMessage, tag)
    -- Apply rate limiting for non-error and non-debug messages
    -- EXCEPTION: "Campaign" debug tag is excluded to allow full lists
    if level ~= "ERROR" and level ~= "DEBUG" and tag ~= "Campaign" and self:_IsRateLimited() then
        return -- Skip message due to rate limiting
    end
    
    -- Add to rate limit queue (skip for debug/campaign to avoid polluting metrics)
    if level ~= "DEBUG" and tag ~= "Campaign" then
        self:_AddToRateLimitQueue()
    end
    
    local logger = self:_GetLogger(tag)
    if logger then
        local method = nil
        if level == "ERROR" then
            method = logger.Error
        elseif level == "WARNING" then
            method = logger.Warn
        elseif level == "DEBUG" then
            method = logger.Debug
        else
            method = logger.Info
        end

        if method then
            pcall(method, logger, tostring(plainMessage or ""))
        end
    end

    if CHAT_ROUTER and CHAT_ROUTER.AddSystemMessage then
        CHAT_ROUTER:AddSystemMessage(chatMessage)
    elseif CHAT_SYSTEM and CHAT_SYSTEM.AddMessage then
        CHAT_SYSTEM:AddMessage(chatMessage)
    else
        d(chatMessage)
    end
end

function Message:_Format(level, text, placeholders)
    local prefix = "[NMGuildHub] "
    local color = self.colors[level] or self.colors.INFO
    local msg = tostring(text)
    msg = self:_Interpolate(msg, placeholders)
    local icon = ""
    if level == "INFO" then
        icon = "|t24:24:" .. (self.prefixIcon or "NMGuildHall/Icons/new/misfit_logo.dds") .. "|t "
    elseif level == "ERROR" then
        icon = "|t24:24:esoui/art/miscellaneous/eso_icon_warning.dds|t "
    elseif level == "WARNING" then
        icon = "|t24:24:esoui/art/miscellaneous/new_icon.dds|t "
    elseif level == "DEBUG" then
        icon = "|t24:24:esoui/art/miscellaneous/help_icon.dds|t "
    end
    return string.format("%s|c%s%s%s|r", icon, color, prefix, msg)
end

function Message:_FormatPlain(text, placeholders)
    local msg = tostring(text)
    msg = self:_Interpolate(msg, placeholders)
    return msg
end

function Message:Info(text, placeholders, tag)
    local plain = self:_FormatPlain(text, placeholders)
    self:_ChatOut(self:_Format("INFO", plain), "INFO", plain, tag)
end

function Message:Warn(text, placeholders, tag)
    local plain = self:_FormatPlain(text, placeholders)
    self:_ChatOut(self:_Format("WARNING", plain), "WARNING", plain, tag)
end

function Message:Error(text, placeholders, tag)
    local plain = self:_FormatPlain(text, placeholders)
    self:_ChatOut(self:_Format("ERROR", plain), "ERROR", plain, tag)
end

function Message:Debug(text, placeholders, tag)
    local isDebugEnabled = false
    if Addon and Addon.IsDebugEnabled then
        -- Centralized gating (preferred)
        isDebugEnabled = Addon:IsDebugEnabled()
    else
        -- Safe fallback for early-init states
        isDebugEnabled = Addon and Addon.db and Addon.db.debug
    end
    
    if isDebugEnabled then
        local plain = self:_FormatPlain(text, placeholders)
        self:_ChatOut(self:_Format("DEBUG", plain), "DEBUG", plain, tag)
    end
end

function Message:For(tag)
    -- Check cache first
    if self.taggedLoggers[tag] then
        return self.taggedLoggers[tag]
    end
    
    -- Create new tagged logger
    local logger = {
        Info = function(_, text, placeholders) return Message:Info(text, placeholders, tag) end,
        Warn = function(_, text, placeholders) return Message:Warn(text, placeholders, tag) end,
        Error = function(_, text, placeholders) return Message:Error(text, placeholders, tag) end,
        Debug = function(_, text, placeholders) return Message:Debug(text, placeholders, tag) end,
    }
    
    -- Cache for future use
    self.taggedLoggers[tag] = logger
    return logger
end

NMGuildHall = NMGuildHall or {}
NMGuildHall.Message = Message

return Message
