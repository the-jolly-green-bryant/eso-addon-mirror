-- Core/Nvk3UT_Diagnostics.lua
-- Centralized logging / diagnostics for Nvk3UT.
-- Loads before Core, so it cannot assume that the global addon table exists
-- at file scope. All access to Nvk3UT therefore happens via guarded helpers.
--
-- TODO: Once the refactor introduces a finalized Core bootstrap, make sure
-- Core/Nvk3UT_Core.lua calls Nvk3UT_Diagnostics.AttachToRoot(Nvk3UT) during
-- OnAddonLoaded so the Diagnostics module is reachable via Nvk3UT.Diagnostics.

Nvk3UT_Diagnostics = Nvk3UT_Diagnostics or {}

local Diagnostics = Nvk3UT_Diagnostics

local function readSavedDebugFlag()
    local root = rawget(_G, "Nvk3UT")
    if type(root) ~= "table" then
        return nil
    end

    local sv = rawget(root, "sv") or rawget(root, "SV")
    if type(sv) ~= "table" then
        return nil
    end

    local flag = sv.debug
    if flag == nil then
        flag = sv.debugEnabled
    end

    if flag == nil then
        return nil
    end

    return flag == true
end

local initialDebug = Diagnostics.debugEnabled
if type(initialDebug) ~= "boolean" then
    local saved = readSavedDebugFlag()
    if type(saved) == "boolean" then
        initialDebug = saved
    else
        initialDebug = false
    end
end

Diagnostics.debugEnabled = initialDebug == true

local isAttachedToRoot = false

local function ensureRoot()
    if isAttachedToRoot then
        return
    end

    local root = rawget(_G, "Nvk3UT")
    if type(root) == "table" then
        root.Diagnostics = root.Diagnostics or Diagnostics
        isAttachedToRoot = true
    end
end

function Diagnostics.AttachToRoot(root)
    if type(root) ~= "table" then
        return
    end

    root.Diagnostics = root.Diagnostics or Diagnostics
    isAttachedToRoot = true
end

local function _fmt(fmt, ...)
    if fmt == nil then
        return ""
    end

    return string.format(tostring(fmt), ...)
end

local function _print(level, msg)
    local output = string.format("[%s] %s", level, msg)

    if d then
        d(output)
    else
        print(output)
    end
end

local LOCAL_COALESCE_WINDOW_MS = 700
local DEFAULT_COALESCE_WINDOW_MS = 500

local coalesceBuckets = {}

function Diagnostics.SetDebugEnabled(enabled)
    Diagnostics.debugEnabled = enabled == true
end

function Diagnostics:IsDebugEnabled()
    local enabled = self.debugEnabled
    if type(enabled) ~= "boolean" then
        local saved = readSavedDebugFlag()
        if type(saved) == "boolean" then
            enabled = saved
            self.debugEnabled = enabled
        else
            enabled = false
            self.debugEnabled = enabled
        end
    end

    return enabled == true
end

function Diagnostics:DebugIfEnabled(tag, fmt, ...)
    if not self:IsDebugEnabled() then
        return
    end

    local debugFn = self.Debug
    if type(debugFn) ~= "function" then
        return
    end

    if fmt == nil then
        return debugFn(tag, ...)
    end

    return debugFn(fmt, ...)
end

function Diagnostics.SyncFromSavedVariables(sv)
    if type(sv) ~= "table" then
        return
    end

    if sv.debug ~= nil then
        Diagnostics.SetDebugEnabled(sv.debug)
    elseif sv.debugEnabled ~= nil then
        Diagnostics.SetDebugEnabled(sv.debugEnabled)
    end

    -- TODO: wire additional diagnostics verbosity flags once SavedVariables schema is finalized.
end

function Diagnostics.Debug(fmt, ...)
    if not Diagnostics:IsDebugEnabled() then
        return
    end

    ensureRoot()
    _print("Nvk3UT DEBUG", _fmt(fmt, ...))
end

local function buildCoalescedMessage(makeLineFn, count, lastArgs)
    if type(makeLineFn) ~= "function" then
        return nil, "makeLineFn missing"
    end

    local ok, line = pcall(makeLineFn, count, lastArgs)
    if ok then
        return line
    end

    return nil, line
end

function Diagnostics:DebugCoalesced(key, windowMs, makeLineFn, lastArgsTable)
    if not self:IsDebugEnabled() then
        return
    end

    if type(key) ~= "string" or key == "" then
        return
    end

    local bucket = coalesceBuckets[key]
    if not bucket then
        bucket = {
            count = 0,
        }
        coalesceBuckets[key] = bucket
    end

    bucket.count = (bucket.count or 0) + 1
    bucket.lastArgs = lastArgsTable

    if bucket.timerActive then
        return
    end

    bucket.timerActive = true

    local delay = tonumber(windowMs) or DEFAULT_COALESCE_WINDOW_MS
    if delay < 0 then
        delay = DEFAULT_COALESCE_WINDOW_MS
    end

    local function flush()
        local count = bucket.count or 0
        local args = bucket.lastArgs

        coalesceBuckets[key] = nil

        bucket.timerActive = nil
        bucket.count = 0
        bucket.lastArgs = nil

        if not Diagnostics:IsDebugEnabled() then
            return
        end

        local line, err = buildCoalescedMessage(makeLineFn, count, args)
        if not line or line == "" then
            if err and Diagnostics:IsDebugEnabled() then
                Diagnostics.Debug("DebugCoalesced build failed for %s: %s", tostring(key), tostring(err))
            end
            return
        end

        Diagnostics.Debug(line)
    end

    if type(zo_callLater) == "function" and delay > 0 then
        zo_callLater(function()
            flush()
        end, delay)
    else
        flush()
    end
end

local function toNumberOrZero(value)
    return tonumber(value) or 0
end

local function toStringOrNone(value)
    if value == nil then
        return "nil"
    end
    return tostring(value)
end

function Diagnostics.Debug_AchStagePending(id, stageId, index)
    Diagnostics:DebugCoalesced("ach_stage_pending", LOCAL_COALESCE_WINDOW_MS, function(count, last)
        last = last or {}
        return string.format(
            "Achievement stage pending: collapsed %d updates (last id=%d stage=%d index=%d)",
            toNumberOrZero(count),
            toNumberOrZero(last.id),
            toNumberOrZero(last.stageId),
            toNumberOrZero(last.index)
        )
    end, {
        id = tonumber(id),
        stageId = tonumber(stageId),
        index = tonumber(index),
    })
end

function Diagnostics.Debug_Todo_ListOpenForTop(topIndex, count, phase)
    Diagnostics:DebugCoalesced("todo_listopenfortop", LOCAL_COALESCE_WINDOW_MS, function(total, last)
        last = last or {}
        return string.format(
            "[TodoData] ListOpenForTop: collapsed %d calls (last phase=%s top=%d count=%d)",
            toNumberOrZero(total),
            toStringOrNone(last.phase),
            toNumberOrZero(last.top),
            toNumberOrZero(last.count)
        )
    end, {
        top = tonumber(topIndex),
        count = tonumber(count),
        phase = phase,
    })
end

function Diagnostics.Warn(fmt, ...)
    ensureRoot()
    _print("Nvk3UT WARN", _fmt(fmt, ...))
end

function Diagnostics.Error(fmt, ...)
    ensureRoot()
    _print("Nvk3UT ERROR", _fmt(fmt, ...))
end

function Diagnostics.SelfTest()
    ensureRoot()
    _print("Nvk3UT DEBUG", _fmt("SelfTest: ZO_Achievements available = %s", tostring(ZO_Achievements ~= nil)))
    _print("Nvk3UT DEBUG", _fmt("SelfTest: categoryTree available = %s", tostring(ZO_Achievements and ZO_Achievements.categoryTree ~= nil)))
    _print("Nvk3UT DEBUG", _fmt("SelfTest: LibAddonMenu2 available = %s", tostring(LibAddonMenu2 ~= nil)))
end

function Diagnostics.SystemTest()
    ensureRoot()

    local ach = SYSTEMS and SYSTEMS.GetObject and SYSTEMS:GetObject("achievements")
    _print("Nvk3UT DEBUG", _fmt("SystemTest: SYSTEMS achievements available = %s", tostring(ach ~= nil)))

    if ach then
        _print("Nvk3UT DEBUG", _fmt("SystemTest: ach.categoryTree available = %s", tostring(ach.categoryTree ~= nil)))
        _print("Nvk3UT DEBUG", _fmt("SystemTest: ach.control available = %s", tostring(ach.control ~= nil)))
    end
end

-- Backward compatibility -------------------------------------------------------
if type(Nvk3UT) == "table" then
    Nvk3UT.Diagnostics = Nvk3UT.Diagnostics or Diagnostics
end

if Debug == nil then
    function Debug(fmt, ...)
        return Diagnostics.Debug(fmt, ...)
    end
end

if LogError == nil then
    function LogError(fmt, ...)
        return Diagnostics.Error(fmt, ...)
    end
end

return Diagnostics
