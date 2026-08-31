-- ESO Adventurer Suite - Built-in Bug Catcher
-- Captures Lua errors without replacing ESO's global error handler. Errors are
-- deduplicated and stored in the Suite SavedVariables so they survive /reloadui.

ESOProgressionCoach = ESOProgressionCoach or {}
local EPC = ESOProgressionCoach

EPC.BugCatcher = EPC.BugCatcher or {}
local B = EPC.BugCatcher

local EARLY_MAX = 20
local TEXT_LIMIT = 6000
local DEFAULT_MAX = 40
local NOTICE_THROTTLE_MS = 1500

-- LibDebugLogger intentionally raises a pair of Time Sync marker errors so its
-- external log viewer can line up timestamps. They are diagnostics, not addon
-- failures, and should never consume Suite Bug Catcher slots or unread counts.
local LIBDEBUGLOGGER_TIME_SYNC_CODES = {
    [0x32BBA739] = true,
    [0xEA5D75AD] = true,
}

local function isIgnoredNoise(kind, text, errorCode)
    if tostring(kind or "LUA") ~= "LUA" then return false end

    local numericCode = tonumber(errorCode)
    if numericCode and LIBDEBUGLOGGER_TIME_SYNC_CODES[numericCode] then
        return true
    end

    text = tostring(text or "")
    if string.find(text, "user:/AddOns/LibDebugLogger/TimeSync.lua", 1, true)
        and string.find(text, "Time Sync B", 1, true) then
        return true
    end

    return false
end

local function nowMs()
    if type(GetFrameTimeMilliseconds) == "function" then return tonumber(GetFrameTimeMilliseconds()) or 0 end
    return 0
end

local function nowStamp()
    if type(GetTimeStamp) == "function" then return tonumber(GetTimeStamp()) or 0 end
    return 0
end

local function trimText(value)
    local text = tostring(value or "")
    if #text > TEXT_LIMIT then
        text = string.sub(text, 1, TEXT_LIMIT) .. "\n...[truncated by ESO Adventurer Suite Bug Catcher]"
    end
    return text
end

local function firstLine(text)
    text = tostring(text or "")
    return string.match(text, "([^\r\n]+)") or text
end

local function sourceFromError(text)
    text = tostring(text or "")
    local addon = string.match(text, "user:/AddOns/([^/]+)/")
    if addon and addon ~= "" then return addon end
    if string.find(text, "EsoUI/", 1, true) then return "ESO UI" end
    return "Unknown source"
end

B.pending = B.pending or {}
B.captureGuard = false
B.ready = B.ready == true

function B:StoreEarly(kind, text, errorCode)
    if isIgnoredNoise(kind, text, errorCode) then return end
    text = trimText(text)
    if text == "" then return end
    self.pending[#self.pending + 1] = { kind = tostring(kind or "LUA"), text = text, stamp = nowStamp(), errorCode = errorCode }
    while #self.pending > EARLY_MAX do table.remove(self.pending, 1) end
end

function B:Capture(kind, text, stamp, errorCode)
    if isIgnoredNoise(kind, text, errorCode) then return true end
    if self.captureGuard then return end
    self.captureGuard = true

    local ok = pcall(function()
        text = trimText(text)
        if text == "" then return end

        if not self.ready or not EPC.saved then
            self:StoreEarly(kind, text, errorCode)
            return
        end
        if EPC.saved.bugCatcherEnabled == false then return end

        EPC.saved.bugCatcherLog = EPC.saved.bugCatcherLog or {}
        local log = EPC.saved.bugCatcherLog
        local maxErrors = math.floor(tonumber(EPC.saved.bugCatcherMaxErrors) or DEFAULT_MAX)
        maxErrors = math.max(10, math.min(100, maxErrors))
        local capturedAt = tonumber(stamp) or nowStamp()
        local source = sourceFromError(text)

        local found
        for i = #log, 1, -1 do
            local entry = log[i]
            if type(entry) == "table" and entry.text == text and entry.kind == tostring(kind or "LUA") then
                found = entry
                break
            end
        end

        if found then
            found.count = (tonumber(found.count) or 1) + 1
            found.lastAt = capturedAt
            found.source = source
        else
            log[#log + 1] = {
                kind = tostring(kind or "LUA"),
                text = text,
                source = source,
                firstAt = capturedAt,
                lastAt = capturedAt,
                count = 1,
            }
            while #log > maxErrors do table.remove(log, 1) end
        end

        EPC.saved.bugCatcherUnread = (tonumber(EPC.saved.bugCatcherUnread) or 0) + 1
        self.sessionCaught = (tonumber(self.sessionCaught) or 0) + 1
        self.lastCaughtText = text

        if EPC.saved.bugCatcherNotifyChat ~= false then
            local now = nowMs()
            if not self.lastNoticeAt or (now - self.lastNoticeAt) >= NOTICE_THROTTLE_MS then
                self.lastNoticeAt = now
                if EPC.Print then
                    EPC:Print(string.format("Bug Catcher caught an error from %s. Type /easbugs last to view it.", tostring(source)))
                end
            end
        end
        self:MaybeSuppressPopup()
    end)

    self.captureGuard = false
    return ok
end

function B:MaybeSuppressPopup()
    if not EPC.saved or EPC.saved.bugCatcherSuppressPopup ~= true then return end
    if type(zo_callLater) == "function" and type(ZO_UIErrors_HideCurrent) == "function" then
        zo_callLater(function() pcall(ZO_UIErrors_HideCurrent) end, 0)
    elseif type(ZO_UIErrors_HideCurrent) == "function" then
        pcall(ZO_UIErrors_HideCurrent)
    end
end

function B:PruneIgnoredNoise()
    if not EPC.saved then return 0 end
    EPC.saved.bugCatcherLog = EPC.saved.bugCatcherLog or {}

    local log = EPC.saved.bugCatcherLog
    local removedOccurrences = 0
    for i = #log, 1, -1 do
        local entry = log[i]
        if type(entry) == "table" and isIgnoredNoise(entry.kind, entry.text, entry.errorCode) then
            removedOccurrences = removedOccurrences + (tonumber(entry.count) or 1)
            table.remove(log, i)
        end
    end

    if removedOccurrences > 0 then
        EPC.saved.bugCatcherUnread = math.max(0, (tonumber(EPC.saved.bugCatcherUnread) or 0) - removedOccurrences)
    end
    return removedOccurrences
end

function B:GetLog()
    if not EPC.saved then return {} end
    EPC.saved.bugCatcherLog = EPC.saved.bugCatcherLog or {}
    return EPC.saved.bugCatcherLog
end

function B:GetUniqueCount()
    return #self:GetLog()
end

function B:GetTotalOccurrences()
    local total = 0
    for _, entry in ipairs(self:GetLog()) do total = total + (tonumber(entry.count) or 1) end
    return total
end

function B:GetLastError()
    local log = self:GetLog()
    return log[#log]
end

function B:Clear()
    if EPC.saved then
        EPC.saved.bugCatcherLog = {}
        EPC.saved.bugCatcherUnread = 0
    end
    self.sessionCaught = 0
    self.lastCaughtText = nil
end

function B:PrintLast()
    local entry = self:GetLastError()
    if not entry then
        if EPC.Print then EPC:Print("Bug Catcher: no stored errors.") end
        return
    end
    if EPC.Print then
        EPC:Print(string.format("Bug Catcher last error [%s] %s (x%d):", tostring(entry.kind or "LUA"), tostring(entry.source or "Unknown"), tonumber(entry.count) or 1))
    end
    if type(d) == "function" then d(tostring(entry.text or ""))
    elseif EPC.Print then EPC:Print(tostring(entry.text or "")) end
    if EPC.saved then EPC.saved.bugCatcherUnread = 0 end
end

function B:PrintList()
    local log = self:GetLog()
    if #log == 0 then
        if EPC.Print then EPC:Print("Bug Catcher: no stored errors.") end
        return
    end
    if EPC.Print then EPC:Print(string.format("Bug Catcher: %d unique / %d total stored occurrences.", #log, self:GetTotalOccurrences())) end
    local first = math.max(1, #log - 4)
    for i = first, #log do
        local entry = log[i]
        local line = firstLine(entry.text)
        if #line > 150 then line = string.sub(line, 1, 147) .. "..." end
        if EPC.Print then EPC:Print(string.format("%d) [%s] %s x%d - %s", i, tostring(entry.kind or "LUA"), tostring(entry.source or "Unknown"), tonumber(entry.count) or 1, line)) end
    end
end

function B:GetStatusText()
    return string.format("Bug Catcher: %d unique errors, %d total occurrences, %d unread. Session: %d.",
        self:GetUniqueCount(), self:GetTotalOccurrences(), tonumber(EPC.saved and EPC.saved.bugCatcherUnread) or 0, tonumber(self.sessionCaught) or 0)
end

function B:TrimToLimit()
    local log = self:GetLog()
    local maxErrors = math.floor(tonumber(EPC.saved and EPC.saved.bugCatcherMaxErrors) or DEFAULT_MAX)
    maxErrors = math.max(10, math.min(100, maxErrors))
    while #log > maxErrors do table.remove(log, 1) end
end

local function addonStateLabel(state)
    local names = {
        "ADDON_STATE_ENABLED",
        "ADDON_STATE_DISABLED",
        "ADDON_STATE_MISSING",
        "ADDON_STATE_DEPENDENCIES_DISABLED",
        "ADDON_STATE_ERROR_STATE_UNABLE_TO_LOAD",
        "ADDON_STATE_VERSION_MISMATCH",
    }
    for _, globalName in ipairs(names) do
        local value = rawget(_G, globalName)
        if value ~= nil and state == value then
            return string.gsub(globalName, "^ADDON_STATE_", "")
        end
    end
    return tostring(state == nil and "UNKNOWN" or state)
end

local function addonStateLooksHealthy(state, enabled)
    local enabledState = rawget(_G, "ADDON_STATE_ENABLED")
    if enabledState ~= nil then return state == enabledState end
    -- If this client does not expose the enum, a successfully enabled addon is
    -- the best signal ESO gives us.
    return enabled == true
end

function B:RunScan()
    self:PruneIgnoredNoise()
    local log = self:GetLog()
    local grouped = {}
    local totalOccurrences = 0
    for _, entry in ipairs(log) do
        if type(entry) == "table" then
            local source = tostring(entry.source or "Unknown source")
            local count = math.max(1, tonumber(entry.count) or 1)
            totalOccurrences = totalOccurrences + count
            local g = grouped[source]
            if not g then
                g = { source = source, unique = 0, total = 0, latest = 0, sample = "" }
                grouped[source] = g
            end
            g.unique = g.unique + 1
            g.total = g.total + count
            g.latest = math.max(g.latest, tonumber(entry.lastAt) or tonumber(entry.firstAt) or 0)
            if g.sample == "" then g.sample = firstLine(entry.text) end
        end
    end

    local errorSources = {}
    for _, g in pairs(grouped) do errorSources[#errorSources + 1] = g end
    table.sort(errorSources, function(a,b)
        if a.total ~= b.total then return a.total > b.total end
        return a.latest > b.latest
    end)

    local loadWarnings = {}
    if type(GetNumAddOns) == "function" and type(GetAddOnInfo) == "function" then
        local okCount, numAddons = pcall(GetNumAddOns)
        numAddons = okCount and tonumber(numAddons) or 0
        if numAddons then
            for i = 1, numAddons do
                local ok, name, title, author, description, enabled, state, isOutOfDate, isLibrary = pcall(GetAddOnInfo, i)
                if ok then
                    name = tostring(name or title or ("Addon " .. tostring(i)))
                    local badState = enabled == true and not addonStateLooksHealthy(state, enabled)
                    if badState or isOutOfDate == true then
                        loadWarnings[#loadWarnings + 1] = {
                            name = name,
                            state = addonStateLabel(state),
                            outOfDate = isOutOfDate == true,
                            badState = badState,
                        }
                    end
                end
            end
        end
    end

    if EPC.Print then
        if #errorSources == 0 and #loadWarnings == 0 then
            EPC:Print("EAS Scan: no captured runtime errors or addon load warnings found.")
        else
            EPC:Print(string.format("EAS Scan: %d addon source(s) with captured errors, %d total occurrence(s), %d addon load warning(s).", #errorSources, totalOccurrences, #loadWarnings))
        end

        local maxSources = math.min(8, #errorSources)
        for i = 1, maxSources do
            local g = errorSources[i]
            local sample = tostring(g.sample or "")
            if #sample > 105 then sample = string.sub(sample, 1, 102) .. "..." end
            EPC:Print(string.format("ERROR %d) %s - %d unique / %d total - %s", i, g.source, g.unique, g.total, sample))
        end
        if #errorSources > maxSources then
            EPC:Print(string.format("...and %d more error source(s). Use /easbugs to list recent errors.", #errorSources - maxSources))
        end

        local maxWarnings = math.min(8, #loadWarnings)
        for i = 1, maxWarnings do
            local w = loadWarnings[i]
            local detail = w.badState and ("state=" .. tostring(w.state)) or "state=enabled"
            if w.outOfDate then detail = detail .. ", out-of-date" end
            EPC:Print(string.format("ADDON %d) %s - %s", i, w.name, detail))
        end
        if #loadWarnings > maxWarnings then
            EPC:Print(string.format("...and %d more addon load warning(s).", #loadWarnings - maxWarnings))
        end
        EPC:Print("EAS Scan is a runtime health scan: it reports errors ESO has actually raised and addon load-state warnings; ESO does not allow one addon to statically compile/check every other addon's source files.")
    end

    return #errorSources, totalOccurrences, #loadWarnings
end

function B:HandleSlash(text)
    local arg = string.lower(tostring(text or ""))
    arg = string.match(arg, "^%s*(.-)%s*$") or ""
    if arg == "clear" then
        self:Clear()
        if EPC.Print then EPC:Print("Bug Catcher log cleared.") end
    elseif arg == "last" or arg == "show" then
        self:PrintLast()
    elseif arg == "list" or arg == "" then
        self:PrintList()
    elseif arg == "status" then
        if EPC.Print then EPC:Print(self:GetStatusText()) end
    elseif arg == "scan" then
        self:RunScan()
    else
        if EPC.Print then EPC:Print("Bug Catcher commands: /easscan, /easbugs, /easbugs scan, /easbugs last, /easbugs clear, /easbugs status") end
    end
end

function B:Initialize()
    self.ready = true
    self.sessionCaught = 0
    if EPC.saved then
        EPC.saved.bugCatcherLog = EPC.saved.bugCatcherLog or {}
        if EPC.saved.bugCatcherMaxErrors == nil then EPC.saved.bugCatcherMaxErrors = DEFAULT_MAX end
        if EPC.saved.bugCatcherUnread == nil then EPC.saved.bugCatcherUnread = 0 end
        self:PruneIgnoredNoise()
        self:TrimToLimit()
    end

    local pending = self.pending or {}
    self.pending = {}
    for i = 1, #pending do
        local entry = pending[i]
        if type(entry) == "table" then self:Capture(entry.kind, entry.text, entry.stamp, entry.errorCode) end
    end

    SLASH_COMMANDS["/easbugs"] = function(text) self:HandleSlash(text) end
    SLASH_COMMANDS["/easscan"] = function() self:RunScan() end
end

-- Register at file-load time so errors thrown by Suite files loaded after this
-- one can be captured before EPC:Initialize() creates SavedVariables.
local prefix = (EPC.name or "ESOAdventurerSuite") .. "_BugCatcher"
if EVENT_LUA_ERROR ~= nil and EVENT_MANAGER then
    EVENT_MANAGER:RegisterForEvent(prefix .. "_Lua", EVENT_LUA_ERROR, function(_, errorText, errorCode)
        if B.ready and EPC.saved then B:Capture("LUA", errorText, nil, errorCode)
        else B:StoreEarly("LUA", errorText, errorCode) end
    end)
end
if EVENT_SCRIPT_ACCESS_VIOLATION ~= nil and EVENT_MANAGER then
    EVENT_MANAGER:RegisterForEvent(prefix .. "_Protected", EVENT_SCRIPT_ACCESS_VIOLATION, function(_, protectedFunctionName)
        local text = "Protected function access violation: " .. tostring(protectedFunctionName or "unknown")
        if B.ready and EPC.saved then B:Capture("ACCESS", text)
        else B:StoreEarly("ACCESS", text) end
    end)
end
if EVENT_LUA_LOW_MEMORY ~= nil and EVENT_MANAGER then
    EVENT_MANAGER:RegisterForEvent(prefix .. "_Memory", EVENT_LUA_LOW_MEMORY, function()
        local text = "ESO reported low Lua memory."
        if B.ready and EPC.saved then B:Capture("MEMORY", text)
        else B:StoreEarly("MEMORY", text) end
    end)
end
