ValknarrThemeLog = ValknarrThemeLog or {}

local Log = ValknarrThemeLog
local PREFIX = "[Theme] "

Log.enabled = false

local persistSink

local function FormatLogTime()
    if type(GetTimeString) == "function" then
        local ok, clock = pcall(GetTimeString)
        if ok and type(clock) == "string" and clock ~= "" then
            return clock
        end
    end
    if type(GetGameTimeMilliseconds) == "function" then
        local ok, ms = pcall(GetGameTimeMilliseconds)
        if ok and type(ms) == "number" then
            return string.format("%.3fs", ms / 1000)
        end
    end
    return nil
end

local function Stamp(message)
    local clock = FormatLogTime()
    if clock then
        return clock .. " " .. tostring(message)
    end
    return tostring(message)
end

function Log:SetPersistSink(fn)
    persistSink = type(fn) == "function" and fn or nil
end

local function Persist(text)
    if persistSink then
        pcall(persistSink, text)
    end
end

local function ChatPrint(message)
    local text = PREFIX .. Stamp(message)
    Persist(text)
    -- Same single destination as ValknarrUIE: gamepad chat, not d() / Logs/.
    if CHAT_ROUTER and type(CHAT_ROUTER.AddSystemMessage) == "function" then
        pcall(CHAT_ROUTER.AddSystemMessage, CHAT_ROUTER, text)
        return
    end
    if CHAT_SYSTEM and type(CHAT_SYSTEM.AddMessage) == "function" then
        pcall(CHAT_SYSTEM.AddMessage, CHAT_SYSTEM, text)
        return
    end
    local gamepad = _G.GAMEPAD_CHAT_SYSTEM
    if gamepad and type(gamepad.AddMessage) == "function" then
        pcall(gamepad.AddMessage, gamepad, text)
        return
    end
    if type(d) == "function" then
        d(text)
        return
    end
    if type(print) == "function" then
        print(text)
    end
end

function Log:SetEnabled(enabled, quiet)
    self.enabled = enabled and true or false
    if not quiet then
        ChatPrint(self.enabled and "Debug logs ON" or "Debug logs OFF")
    end
end

function Log:ApplyFromStore(quiet)
    local Store = ValknarrThemeStore
    local on = false
    if Store and Store.GetSetting then
        on = Store:GetSetting("showDebugLog") and true or false
    end
    self:SetEnabled(on, quiet ~= false)
end

function Log:Always(message)
    ChatPrint(tostring(message))
end

function Log:Info(message)
    if self.enabled then
        ChatPrint("INFO " .. tostring(message))
    end
end

function Log:Warn(message)
    ChatPrint("WARN " .. tostring(message))
end

function Log:Debug(message)
    if self.enabled then
        ChatPrint("DBG " .. tostring(message))
    end
end

function Log:FormatValue(value)
    local valueType = type(value)
    if value == nil then
        return "nil"
    end
    if valueType == "boolean" or valueType == "number" then
        return tostring(value)
    end
    if valueType == "string" then
        return string.format("%q", value)
    end
    if valueType == "table" then
        return "table"
    end
    if valueType == "userdata" then
        local ok, name = pcall(function()
            if type(value.GetName) == "function" then
                return value:GetName()
            end
        end)
        if ok and type(name) == "string" and name ~= "" then
            return "control:" .. name
        end
        return "userdata"
    end
    return valueType
end

function Log:FormatPairs(tbl)
    if type(tbl) ~= "table" then
        return self:FormatValue(tbl)
    end
    local keys = {}
    for key in pairs(tbl) do
        keys[#keys + 1] = key
    end
    table.sort(keys, function(a, b)
        return tostring(a) < tostring(b)
    end)
    local parts = {}
    for index = 1, #keys do
        local key = keys[index]
        parts[#parts + 1] = tostring(key) .. "=" .. self:FormatValue(tbl[key])
    end
    return table.concat(parts, " ")
end

function Log:ControlBits(control)
    if not control then
        return { present = false }
    end
    local name
    local hidden
    if type(control.GetName) == "function" then
        local ok, value = pcall(control.GetName, control)
        if ok then
            name = value
        end
    end
    if type(control.IsHidden) == "function" then
        local ok, value = pcall(control.IsHidden, control)
        if ok then
            hidden = value and true or false
        end
    end
    return { present = true, name = name, hidden = hidden }
end

return Log
