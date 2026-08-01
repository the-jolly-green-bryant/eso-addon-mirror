-- AccountHold/src/core/Log.lua
--
-- FOUNDATION MODULE. Per-module diagnostics, and the sink that lets Safe.lua
-- report failures without depending on anything.
--
-- WHY THIS EXISTS
-- ---------------
-- Six modules define their own `warn` / `info` / `diag` local, each re-deriving
-- the same "is there an addon ref, does it have :Diagnostic, prefix the tag"
-- dance, with inconsistent tags and inconsistent guarding. There are 28
-- :Diagnostic( call sites spread unevenly -- BankActionPanel has 3, InventoryTab
-- has 4, and ArmoryScreen (2904 lines) has NONE, so its 58 pcall sites fail
-- completely silently.
--
-- That silence is the real cost. This add-on's recurring failure mode is a
-- surface that does not appear, with no way to tell whether it was gated off,
-- failed to install, or threw. A uniform logger makes "it did not appear" always
-- answerable from the in-game diagnostics buffer.
--
-- HOW IT FITS
-- -----------
-- Log.For("tag") returns a small logger bound to that tag. Log also installs
-- itself as Safe's reporter, so every Safe.Call / Safe.Wrap failure anywhere in
-- the add-on lands in diagnostics automatically, with no call-site work.
--
-- Loads AFTER src/core/Safe.lua (it calls Safe.SetReporter). Both are inert
-- until something uses them.
--
-- ESO runs Lua 5.1. Must LOAD under tests/zos_mock.lua with no ZO_* globals.

AccountHold = AccountHold or {}
AccountHold.Core = AccountHold.Core or {}
AccountHold.Core.Log = AccountHold.Core.Log or {}

local Log = AccountHold.Core.Log

-- Ring buffer of last-resort records, used when the add-on's own Diagnostic
-- sink is not available yet -- which is precisely the load-order window where
-- install failures happen and are currently invisible. Bounded so it can never
-- grow without limit in a long session.
Log.MAX_FALLBACK = 100
Log._fallback = {}

local function remember(level, tag, msg)
    local buf = Log._fallback
    buf[#buf + 1] = { level = level, tag = tag, msg = msg }
    -- Cheap bounded trim: drop the oldest half when the cap is hit, so this is
    -- amortised O(1) rather than a shift on every write.
    if #buf > Log.MAX_FALLBACK then
        local keep, half = {}, math.floor(Log.MAX_FALLBACK / 2)
        for i = #buf - half + 1, #buf do keep[#keep + 1] = buf[i] end
        Log._fallback = keep
    end
end

-- Drain the fallback buffer. Tests assert against this; a future settings
-- action could surface it in game.
function Log.Recent()
    local out = {}
    for i = 1, #Log._fallback do out[i] = Log._fallback[i] end
    return out
end

function Log.Clear()
    Log._fallback = {}
end

-- Emit one record. Never throws, whatever the addon sink does.
local function emit(level, tag, fmt, ...)
    local msg
    if select("#", ...) > 0 then
        local ok, s = pcall(string.format, tostring(fmt), ...)
        msg = (ok and type(s) == "string") and s or tostring(fmt)
    else
        msg = tostring(fmt)
    end

    local line = "[" .. tostring(tag) .. "] " .. msg

    local a = AccountHold
    local d = a and a.Diagnostic
    if type(d) == "function" then
        local ok = pcall(d, a, level, "%s", line)
        if ok then return end
    end

    -- No sink yet (or it threw): keep the record so the failure is still
    -- answerable rather than lost.
    remember(level, tag, msg)
end

-- For(tag) -> logger
--
-- logger:Warn(fmt, ...)  logger:Info(fmt, ...)  logger:Error(fmt, ...)
--
-- The tag is the module identity, e.g. "qol/clearall". Matches the existing
-- convention in PrioritiesSetsBook ("[priorities/setsbook]").
function Log.For(tag)
    tag = (type(tag) == "string" and tag ~= "") and tag or "accounthold"
    return {
        tag = tag,
        Warn  = function(_, fmt, ...) emit("warn",  tag, fmt, ...) end,
        Info  = function(_, fmt, ...) emit("info",  tag, fmt, ...) end,
        Error = function(_, fmt, ...) emit("error", tag, fmt, ...) end,
    }
end

-- ---------------------------------------------------------------------------
-- Wire Safe's failure reporting into diagnostics.
--
-- This is the payoff: after this line, EVERY Safe.Call / Safe.Wrap failure
-- anywhere in the add-on is recorded, with no work at the call site. Compare
-- the status quo, where 496 hand-written pcall sites mostly discard the error.
-- ---------------------------------------------------------------------------
do
    local core = AccountHold.Core
    local Safe = core and core.Safe
    if type(Safe) == "table" and type(Safe.SetReporter) == "function" then
        Safe.SetReporter(function(context, err)
            emit("error", "safe", "%s: %s", tostring(context), tostring(err))
        end)
    end
end

return Log
