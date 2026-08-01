(function()
    
    return function(Addon)
        if type(Addon) ~= "table" then
            return
        end
    
        local Log = Addon.Log or {}
        local addonName = type(Addon.Name) == "string" and Addon.Name ~= "" and Addon.Name or "Addon"
        local MAX_DUMP_DEPTH = 6
        local LEVELS = {
            TRACE = 10,
            DEBUG = 20,
            INFO = 30,
            WARN = 40,
            ERROR = 50,
        }
        local LEVEL_NAMES = {
            [LEVELS.TRACE] = "TRACE",
            [LEVELS.DEBUG] = "DEBUG",
            [LEVELS.INFO] = "INFO",
            [LEVELS.WARN] = "WARN",
            [LEVELS.ERROR] = "ERROR",
        }
    
        local function normalizeColor(value)
            if type(value) ~= "string" then
                return nil
            end
    
            local color = string.upper(string.gsub(value, "^#", ""))
    
            if string.match(color, "^%x%x%x%x%x%x$") then
                return color
            end
    
            return nil
        end
    
        local function deriveColor(name)
            local hash = 0
    
            for index = 1, string.len(name) do
                hash = (hash * 131 + string.byte(name, index)) % 16777216
            end
    
            local red = 96 + (hash % 160)
            local green = 96 + (math.floor(hash / 256) % 160)
            local blue = 96 + (math.floor(hash / 65536) % 160)
    
            return string.format("%02X%02X%02X", red, green, blue)
        end
    
        local function resolveLevel(level)
            if type(level) == "number" then
                return level
            end
    
            if type(level) == "string" then
                return LEVELS[string.upper(level)]
            end
    
            return nil
        end
    
        local currentLevel = resolveLevel(Log.Level or Addon.LogLevel) or LEVELS.INFO
        local color = normalizeColor(Addon.LogColor) or deriveColor(addonName)
        local prefix = string.format("|c%s[%s]|r", color, addonName)
    
        local function quoteString(value)
            local escaped = string.gsub(value, "\\", "\\\\")
            escaped = string.gsub(escaped, "\n", "\\n")
            escaped = string.gsub(escaped, "\r", "\\r")
            escaped = string.gsub(escaped, "\t", "\\t")
            escaped = string.gsub(escaped, "\"", "\\\"")
            return "\"" .. escaped .. "\""
        end
    
        local function formatKey(key)
            if type(key) == "string" and string.match(key, "^[%a_][%w_]*$") then
                return key
            end
    
            if type(key) == "string" then
                return "[" .. quoteString(key) .. "]"
            end
    
            return "[" .. tostring(key) .. "]"
        end
    
        local function formatScalar(value)
            if type(value) == "string" then
                return quoteString(value)
            end
    
            return tostring(value)
        end
    
        local function formatMessageScalar(value)
            return tostring(value)
        end
    
        local function sortedKeys(source)
            local keys = {}
    
            for key in pairs(source) do
                keys[#keys + 1] = key
            end
    
            table.sort(keys, function(left, right)
                local leftLabel = type(left) .. ":" .. tostring(left)
                local rightLabel = type(right) .. ":" .. tostring(right)
                return leftLabel < rightLabel
            end)
    
            return keys
        end
    
        local function dumpValue(value, depth, seen)
            if type(value) ~= "table" then
                return { formatScalar(value) }
            end
    
            if seen[value] then
                return { "{ <circular> }" }
            end
    
            if depth >= MAX_DUMP_DEPTH then
                return { "{ <max-depth> }" }
            end
    
            seen[value] = true
    
            local lines = { "{" }
            local keys = sortedKeys(value)
    
            for _, key in ipairs(keys) do
                local childLines = dumpValue(value[key], depth + 1, seen)
                lines[#lines + 1] = "  " .. formatKey(key) .. " = " .. childLines[1]
    
                for lineIndex = 2, #childLines do
                    lines[#lines + 1] = "  " .. childLines[lineIndex]
                end
            end
    
            lines[#lines + 1] = "}"
            seen[value] = nil
    
            return lines
        end
    
        local function collectLines(...)
            local count = select("#", ...)
            local lines = {}
            local scalars = {}
    
            if count == 0 then
                return { "" }
            end
    
            for index = 1, count do
                local value = select(index, ...)
    
                if type(value) == "table" then
                    if #scalars > 0 then
                        lines[#lines + 1] = table.concat(scalars, " ")
                        scalars = {}
                    end
    
                    local dumpLines = dumpValue(value, 0, {})
    
                    for _, line in ipairs(dumpLines) do
                        lines[#lines + 1] = line
                    end
                else
                    scalars[#scalars + 1] = formatMessageScalar(value)
                end
            end
    
            if #scalars > 0 then
                lines[#lines + 1] = table.concat(scalars, " ")
            end
    
            return lines
        end
    
        local function writeLine(message)
            if Addon.LogUseChatSystem == true and CHAT_SYSTEM and type(CHAT_SYSTEM.AddMessage) == "function" then
                CHAT_SYSTEM:AddMessage(message)
                return
            end
    
            if type(d) == "function" then
                d(message)
            end
        end
    
        local function write(levelName, levelValue, ...)
            if levelValue < currentLevel then
                return
            end
    
            local lines = collectLines(...)
    
            for _, line in ipairs(lines) do
                if line == "" then
                    writeLine(prefix .. " " .. levelName)
                else
                    writeLine(prefix .. " " .. levelName .. " " .. line)
                end
            end
        end
    
        function Log.SetLevel(level)
            local resolved = resolveLevel(level)
    
            if not resolved then
                return false
            end
    
            currentLevel = resolved
            Log.Level = resolved
            Log.LevelName = LEVEL_NAMES[resolved] or tostring(resolved)
    
            return true
        end
    
        function Log.Trace(...)
            write("TRACE", LEVELS.TRACE, ...)
        end
    
        function Log.Debug(...)
            write("DEBUG", LEVELS.DEBUG, ...)
        end
    
        function Log.Info(...)
            write("INFO", LEVELS.INFO, ...)
        end
    
        function Log.Warn(...)
            write("WARN", LEVELS.WARN, ...)
        end
    
        function Log.Error(...)
            write("ERROR", LEVELS.ERROR, ...)
        end
    
        Log.Level = currentLevel
        Log.LevelName = LEVEL_NAMES[currentLevel] or tostring(currentLevel)
        Addon.Log = Log
    end
    
end)()(_G["TheSynapticRegistry"])
