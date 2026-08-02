-- AccountHold/src/core/Text.lua
--
-- FOUNDATION MODULE. The single localization accessor.
--
-- WHY THIS EXISTS
-- ---------------
-- `local function L(id, fallback)` is currently defined NINE times across ui/
-- and src/, in TWO materially different variants:
--
--   HARDENED (5 copies -- ArmoryScreen, DungeonFinder, DungeonFinderScene,
--   PrioritiesSetsBook, BuildCreator):
--       local ok, s = pcall(AccountHold.L, id, fallback)
--       if ok and type(s) == "string" and s ~= "" then return s end
--       return fallback
--
--   UNGUARDED (4 copies -- PrioritiesMenu, PrioritiesScreen, SetSources,
--   Travel):
--       return AccountHold.L(id, fallback)
--
-- The unguarded variant has two live defects. It propagates a throw from
-- AccountHold.L, and it returns whatever that call produced -- including nil or
-- "" -- where a caller expected a label. Both matter because PrioritiesMenu and
-- PrioritiesScreen hand these strings directly to base-game entry and keybind
-- callbacks, which ZOS invokes from its own loops. On console a throw there is
-- a hard "Error <code>" that ends the session, and a nil label can fail an
-- unguarded concat inside the base template.
--
-- This module is the hardened variant, once. It is the behaviour a caller
-- should already have been getting.
--
-- NON-GOAL: nothing existing is rewritten here. The nine copies stay until each
-- is migrated deliberately with its own test.
--
-- ESO runs Lua 5.1. Must LOAD under tests/zos_mock.lua with no ZO_* globals.

AccountHold = AccountHold or {}
AccountHold.Core = AccountHold.Core or {}
AccountHold.Core.Text = AccountHold.Core.Text or {}

local Text = AccountHold.Core.Text

-- Get(id, fallback) -> string
--
-- Always returns a STRING. Never throws. Falls back whenever the lookup fails,
-- returns a non-string, or returns the empty string.
--
-- `fallback` is itself coerced: a caller that passes nil still gets "" rather
-- than nil, because the overwhelmingly common consumer is a label that will be
-- concatenated or measured by the base game.
function Text.Get(id, fallback)
    if type(fallback) ~= "string" then fallback = "" end

    local fn = AccountHold and AccountHold.L
    if type(fn) == "function" then
        local ok, s = pcall(fn, id, fallback)
        if ok and type(s) == "string" and s ~= "" then return s end
    end
    return fallback
end

-- Format(id, fallback, ...) -> string
--
-- Localised string.format. The format string is resolved through Get(), then
-- applied under pcall -- a mismatched format specifier (a %d against a string,
-- or a translation carrying the wrong number of slots) would otherwise throw
-- from inside a base-game render callback.
--
-- On any failure returns the resolved format string unformatted, which is
-- always more useful to a player than an empty label.
function Text.Format(id, fallback, ...)
    local fmt = Text.Get(id, fallback)
    if select("#", ...) == 0 then return fmt end
    local ok, s = pcall(string.format, fmt, ...)
    if ok and type(s) == "string" then return s end
    return fmt
end

-- Bind(prefix) -> function(suffix, fallback, ...)
--
-- Convenience for a module whose string ids share a prefix, so call sites read
--     local S = Text.Bind("SI_ACCOUNTHOLD_QOL_")
--     S("CLEAR_NEW", "Clear new item notifications")
-- rather than repeating the prefix at every use. Purely ergonomic; identical
-- semantics to Get/Format.
function Text.Bind(prefix)
    if type(prefix) ~= "string" then prefix = "" end
    return function(suffix, fallback, ...)
        local id = prefix .. tostring(suffix)
        if select("#", ...) == 0 then
            return Text.Get(id, fallback)
        end
        return Text.Format(id, fallback, ...)
    end
end

return Text
