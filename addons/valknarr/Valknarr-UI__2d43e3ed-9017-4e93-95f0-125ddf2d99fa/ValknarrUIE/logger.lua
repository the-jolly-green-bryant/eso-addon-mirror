ValknarrUIELog = ValknarrUIELog or {}

local Log = ValknarrUIELog
local PREFIX = "[UIE] "
local MAX_HUD_LINES = 12

Log.enabled = false
Log.hudVisible = false
Log.hudLines = {}

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
    -- One chat destination. Writing CHAT_ROUTER + CHAT_SYSTEM +
    -- GAMEPAD_CHAT_SYSTEM + d() duplicated every /uiedit diag line on
    -- Play Anywhere. `d()` exists on console but does not show in the
    -- gamepad chat window; engine Logs/ is not addon output.
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

local function EnsureHud()
    if Log.hud or not WINDOW_MANAGER or not GuiRoot then
        return Log.hud
    end

    local backdrop = WINDOW_MANAGER:CreateControl("ValknarrUIELogHud", GuiRoot, CT_BACKDROP)
    backdrop:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 24, 24)
    backdrop:SetDimensions(720, 260)
    backdrop:SetCenterColor(0, 0, 0, 0.72)
    backdrop:SetEdgeColor(1, 0.75, 0.15, 0.95)
    backdrop:SetEdgeTexture(nil, 1, 1, 1, 0)
    backdrop:SetDrawLayer(DL_OVERLAY)
    backdrop:SetDrawTier(DT_HIGH)
    backdrop:SetHidden(true)

    local label = WINDOW_MANAGER:CreateControl("ValknarrUIELogHudText", backdrop, CT_LABEL)
    label:SetAnchor(TOPLEFT, backdrop, TOPLEFT, 12, 10)
    label:SetDimensions(696, 240)
    label:SetFont("ZoFontGamepad34")
    label:SetColor(1, 0.92, 0.55, 1)
    label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    label:SetVerticalAlignment(TEXT_ALIGN_TOP)
    if TEXT_WRAP_MODE_ELLIPSIS and type(label.SetWrapMode) == "function" then
        pcall(label.SetWrapMode, label, TEXT_WRAP_MODE_ELLIPSIS)
    end

    Log.hud = backdrop
    Log.hudLabel = label
    return backdrop
end

local function RefreshHud()
    local hud = EnsureHud()
    if not hud or not Log.hudLabel then
        return
    end
    local lines = { "Valknarr UI — verbose log" }
    for index = 1, #Log.hudLines do
        lines[#lines + 1] = Log.hudLines[index]
    end
    Log.hudLabel:SetText(table.concat(lines, "\n"))
    hud:SetHidden(not Log.enabled or not Log.hudVisible or #Log.hudLines == 0)
end

function Log:SetHudVisible(visible)
    self.hudVisible = visible and true or false
    RefreshHud()
end

function Log:SetEnabled(enabled, quiet)
    self.enabled = enabled and true or false
    if not self.enabled then
        self.hudVisible = false
        if self.hud then
            self.hud:SetHidden(true)
        end
        self.hudLines = {}
    end
    if not quiet then
        ChatPrint(self.enabled and "Debug logs ON" or "Debug logs OFF")
    end
    RefreshHud()
end

-- Saved setting showDebugLog: chat DBG/INFO spam + on-canvas log panel.
function Log:ApplyFromStore(quiet)
    local Store = ValknarrUIELayoutStore
    local on = false
    if Store and Store.GetSetting then
        on = Store:GetSetting("showDebugLog") and true or false
    end
    self:SetEnabled(on, quiet ~= false)
    self:SetHudVisible(on)
end

function Log:ClearHud()
    self.hudLines = {}
    RefreshHud()
end

function Log:Write(level, message)
    local text = tostring(message)
    local line = level .. " " .. text
    -- WARN always prints. INFO/DBG only when debug logs are enabled.
    if level == "WARN" or self.enabled then
        ChatPrint(line)
    end
    if not self.enabled then
        return
    end
    self.hudLines[#self.hudLines + 1] = Stamp(line)
    while #self.hudLines > MAX_HUD_LINES do
        table.remove(self.hudLines, 1)
    end
    RefreshHud()
end

function Log:Info(message)
    self:Write("INFO", message)
end

function Log:Warn(message)
    self:Write("WARN", message)
end

function Log:Debug(message)
    if self.enabled then
        self:Write("DBG", message)
    end
end

function Log:Always(message)
    ChatPrint(tostring(message))
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

-- Stable "key=value key=value" line for /uiedit diag and debug snapshots.
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

function Log:Dump(label, tbl)
    if not self.enabled then
        return
    end
    self:Debug(tostring(label) .. ":")
    if type(tbl) ~= "table" then
        self:Debug("  " .. self:FormatValue(tbl))
        return
    end
    for key, value in pairs(tbl) do
        self:Debug("  " .. tostring(key) .. "=" .. self:FormatValue(value))
    end
end

return Log
