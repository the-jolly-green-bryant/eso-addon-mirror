-- AccountHold/src/core/Safe.lua
--
-- FOUNDATION MODULE. Safe access to the game's globals, and safe invocation of
-- anything the base game will call back into.
--
-- WHY THIS EXISTS
-- ---------------
-- Two failure classes have each cost this add-on a shipped bug, and both are
-- structural rather than incidental -- they recur every time a new surface is
-- written, because every surface hand-rolls its own guards:
--
--   1. THE USERDATA GATE. ESO engine globals (SCENE_MANAGER, KEYBIND_STRIP,
--      EVENT_MANAGER, WINDOW_MANAGER, SHARED_INVENTORY, ...) are USERDATA, not
--      tables (globalvars.lua:2-4). A guard written as
--          if type(SCENE_MANAGER) == "table" then
--      is FALSE on real hardware, so the branch never runs -- while every mock
--      test passes, because the mock uses plain tables. This shipped: the
--      Priorities screen's keybinds silently never registered on console.
--      There are currently 11 independent hand-rolled copies of this accessor
--      across ui/ and src/ (gtable, gobj, gfn, isControl, method, gvalue,
--      gobject) with at least three DIFFERENT behaviours.
--
--   2. THE UNGUARDED CALLBACK. ZOS invokes our name/visible/enabled/callback
--      closures from inside its own update loops, outside any pcall we own. On
--      console there is no Lua error window, so a throw there is a hard
--      "Error <code>" that ends the game session. There are ~496 hand-written
--      pcall( sites across ui/, with no shared convention for what happens on
--      failure.
--
-- This module is the ONE place either problem is solved. It is deliberately
-- tiny, has no dependencies, and is safe to load first.
--
-- NON-GOAL: this module does not wrap or replace any existing code. Existing
-- surfaces keep their own helpers until they are migrated deliberately, one at
-- a time, each with its own test. Nothing here changes shipped behaviour.
--
-- ESO runs Lua 5.1: no goto, no bitwise operators, no integer division. This
-- file must LOAD under tests/zos_mock.lua with none of the ZO_* globals present.

AccountHold = AccountHold or {}
AccountHold.Core = AccountHold.Core or {}
AccountHold.Core.Safe = AccountHold.Core.Safe or {}

local Safe = AccountHold.Core.Safe

-- ---------------------------------------------------------------------------
-- Global access
-- ---------------------------------------------------------------------------

-- Obj(name) -> the global `name`, whatever its Lua type, or nil if absent.
--
-- This is the correct accessor for an ENGINE object. It deliberately does NOT
-- type-test: userdata, table and function are all legitimate. Use Method() to
-- establish that the thing can actually do what you need.
--
-- Reads through _G explicitly and under pcall, because a hostile or partially
-- initialised environment can make even a plain global read throw.
function Safe.Obj(name)
    if type(name) ~= "string" then return nil end
    local ok, v = pcall(function() return _G[name] end)
    if ok then return v end
    return nil
end

-- Table(name) -> the global `name` ONLY if it is a real Lua table.
--
-- Correct for OUR OWN plain-Lua data and for base-game plain tables such as
-- ESO_Dialogs (globalvars.lua:7). WRONG for engine objects -- reach for Obj().
-- Kept separate and named so the choice is explicit at every call site rather
-- than implied by a bare type() test.
function Safe.Table(name)
    local v = Safe.Obj(name)
    if type(v) == "table" then return v end
    return nil
end

-- Fn(name) -> the global `name` ONLY if it is callable.
function Safe.Fn(name)
    local v = Safe.Obj(name)
    if type(v) == "function" then return v end
    return nil
end

-- Method(obj, name) -> obj's method `name` as a plain function, or nil.
--
-- THE key primitive. Works for tables AND userdata, which is exactly what the
-- type(x) == "table" gate got wrong. Indexing userdata can itself throw if the
-- object has a hostile or absent __index, so the read is pcall'd.
--
-- Returns the raw function; call it with the object as first argument:
--     local add = Safe.Method(KEYBIND_STRIP, "AddKeybindButtonGroup")
--     if add then Safe.Call(add, KEYBIND_STRIP, descriptor) end
-- or use Invoke() below, which does both.
function Safe.Method(obj, name)
    if obj == nil or type(name) ~= "string" then return nil end
    local ok, fn = pcall(function() return obj[name] end)
    if ok and type(fn) == "function" then return fn end
    return nil
end

-- Has(obj, name) -> true when obj can perform `name`. The readable form of the
-- guard that should have been written instead of type(x) == "table".
function Safe.Has(obj, name)
    return Safe.Method(obj, name) ~= nil
end

-- Invoke(obj, name, ...) -> ok, result
--
-- Method lookup + guarded call in one step, for the extremely common
-- "call this method on an engine singleton if it exists" shape.
function Safe.Invoke(obj, name, ...)
    local fn = Safe.Method(obj, name)
    if fn == nil then return false, nil end
    return Safe.Call(fn, obj, ...)
end

-- ---------------------------------------------------------------------------
-- Guarded invocation
-- ---------------------------------------------------------------------------

-- The diagnostics sink. Assigned by Log.lua at load time so this module keeps
-- zero dependencies and stays loadable on its own (including in a bare test).
Safe._reporter = nil

function Safe.SetReporter(fn)
    if type(fn) == "function" or fn == nil then Safe._reporter = fn end
end

local function report(context, err)
    local r = Safe._reporter
    if type(r) ~= "function" then return end
    pcall(r, context, err)
end

-- Call(fn, ...) -> ok, result
--
-- pcall with a single, consistent failure policy: never propagate, always
-- report. Returns only the FIRST result: multi-return is rare here and letting
-- it through silently has hidden bugs before.
function Safe.Call(fn, ...)
    if type(fn) ~= "function" then return false, nil end
    local ok, res = pcall(fn, ...)
    if not ok then
        report("Safe.Call", res)
        return false, nil
    end
    return true, res
end

-- Wrap(fn, default, context) -> a function that can never throw.
--
-- THE tool for anything handed to the base game. ZOS calls our closures from
-- its own loops; a throw there is a hard console error. A wrapped closure
-- degrades to `default` instead -- a button hides, a label renders empty, an
-- action does nothing -- and the failure lands in diagnostics.
--
-- Non-functions pass through untouched, so a descriptor field that is a plain
-- string or nil can be wrapped unconditionally by the caller.
function Safe.Wrap(fn, default, context)
    if type(fn) ~= "function" then return fn end
    return function(...)
        local ok, res = pcall(fn, ...)
        if ok then return res end
        report(context or "Safe.Wrap", res)
        return default
    end
end

-- Harden(descriptor) -> descriptor (mutated IN PLACE, idempotent)
--
-- Wraps the four closures the keybind strip and gamepad entry templates invoke.
-- In place and reference-stable because KEYBIND_STRIP removes a group by table
-- IDENTITY -- handing back a copy would leak the original and make teardown
-- impossible. Idempotent via a weak-keyed set so a descriptor pushed and popped
-- repeatedly is not re-wrapped each time.
Safe._hardened = setmetatable({}, { __mode = "k" })

function Safe.Harden(descriptor, context)
    if type(descriptor) ~= "table" then return descriptor end
    if Safe._hardened[descriptor] then return descriptor end

    for i = 1, #descriptor do
        local btn = descriptor[i]
        if type(btn) == "table" then
            btn.name     = Safe.Wrap(btn.name,     "",    context)
            btn.visible  = Safe.Wrap(btn.visible,  false, context)
            btn.enabled  = Safe.Wrap(btn.enabled,  true,  context)
            btn.callback = Safe.Wrap(btn.callback, nil,   context)
        end
    end

    Safe._hardened[descriptor] = true
    return descriptor
end

-- ---------------------------------------------------------------------------
-- Bounded iteration
--
-- Every loop over a game-provided iterator in this add-on is bounded. A hung
-- console session cannot be recovered without a hard restart, so "this iterator
-- will surely terminate" is not a risk worth taking. Centralised here so new
-- code inherits the discipline instead of re-deriving it.
-- ---------------------------------------------------------------------------

Safe.DEFAULT_LIMIT = 5000

-- Iterate(nextFn, visit, limit) -> count
--
-- Walks `nextFn(prev)` until it returns nil, stopping on a REPEATED id or at
-- `limit`. A repeat is the real-world failure: GetNextItemSetCollectionId can
-- cycle, and an unbounded walk over it hangs the client.
function Safe.Iterate(nextFn, visit, limit)
    if type(nextFn) ~= "function" then return 0 end
    limit = (type(limit) == "number" and limit > 0) and limit or Safe.DEFAULT_LIMIT

    local seen, count, guard = {}, 0, 0
    local ok, id = Safe.Call(nextFn, nil)
    if not ok then return 0 end

    while id ~= nil do
        guard = guard + 1
        if guard > limit or seen[id] then break end
        seen[id] = true
        count = count + 1
        if type(visit) == "function" then
            Safe.Call(visit, id)
        end
        local okNext, nextId = Safe.Call(nextFn, id)
        if not okNext then break end
        id = nextId
    end
    return count
end

return Safe
