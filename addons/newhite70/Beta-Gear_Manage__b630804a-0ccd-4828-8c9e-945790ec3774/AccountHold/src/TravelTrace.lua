-- AccountHold/src/TravelTrace.lua
--
-- Live travel tracing, to chat (BUGS.md QMQ-1).
--
-- WHY THIS EXISTS
-- ---------------
-- Two fixes for the Quartermaster Queue's destination lookup have shipped and
-- both were wrong, because the one fact that decides the answer -- what a
-- dungeon's fast-travel node is CALLED, and whether one exists -- is game data
-- that no amount of reading esoui source can reveal.
--
-- This module gets that fact the only way it can be got: by watching the player
-- travel. FastTravelToNode is unprotected (verified against esoui 12.0.7), so
-- it can be wrapped. When the player travels to a dungeon THROUGH THE MAP, by
-- hand, we log exactly which node the game used -- its index, its real name,
-- its POI type and its zone. That is ground truth, and it is precisely what the
-- matcher needs in order to stop guessing.
--
-- Two outputs, both to CHAT so a console player can read them without a log
-- file:
--   * every travel, as it happens (the wrap)
--   * a one-shot census of every dungeon-type node (the dump)
--
-- SAFETY. The wrap is the riskiest thing in this add-on: getting it wrong takes
-- away the player's ability to fast travel at all. So:
--   * the original is captured once and ALWAYS called, whatever the logger does
--   * every line of logging is inside pcall
--   * a failure in the logger cannot change the return value
--   * installing twice is a no-op, so a reload cannot chain wraps
--
-- OFF BY DEFAULT. Tracing is a diagnostic, not a feature. It is enabled from
-- the settings panel and persists in SavedVariables.
--
-- ESO runs Lua 5.1. Must LOAD under tests/zos_mock.lua with no ZO_* globals.

AccountHold = AccountHold or {}
AccountHold.TravelTrace = AccountHold.TravelTrace or {}

local Trace = AccountHold.TravelTrace

Trace._installed = false
Trace._original  = nil

-- ---------------------------------------------------------------------------
-- Enablement
-- ---------------------------------------------------------------------------

-- Tracing is OPT-IN.
--
-- It defaulted ON while QMQ-1 was unsolved, because the naming question could
-- not be answered any other way and the settings panel needs
-- LibHarvensAddonSettings to reach. QMQ-1 is now fixed and confirmed on
-- hardware, so the default returns to off -- otherwise every jump the player
-- makes prints a line forever.
--
-- The module stays: it is the only way to answer a node-naming question, and it
-- earned that by finding a bug two rounds of source reading missed.
function Trace.IsEnabled()
    local a = AccountHold
    local sv = a and a.sv
    local s = sv and sv.settings
    if type(s) ~= "table" then return false end
    return s.travelTrace == true
end

function Trace.SetEnabled(on)
    local a = AccountHold
    local sv = a and a.sv
    if type(sv) ~= "table" then return false end
    sv.settings = sv.settings or {}
    sv.settings.travelTrace = on and true or false
    return sv.settings.travelTrace
end

-- ---------------------------------------------------------------------------
-- Output
--
-- Straight to chat. The diagnostics ring buffer is the right home for a
-- post-hoc dump, but a trace is only useful if the player sees it AS IT
-- HAPPENS, next to the thing they just did.
-- ---------------------------------------------------------------------------

function Trace.Say(fmt, ...)
    local msg
    if select("#", ...) > 0 then
        local ok, s = pcall(string.format, tostring(fmt), ...)
        msg = (ok and type(s) == "string") and s or tostring(fmt)
    else
        msg = tostring(fmt)
    end
    msg = "|c66CCFF[QM travel]|r " .. msg

    if CHAT_ROUTER and CHAT_ROUTER.AddSystemMessage then
        if pcall(function() CHAT_ROUTER:AddSystemMessage(msg) end) then return end
    end
    local a = AccountHold
    if a and type(a.Log) == "function" then pcall(a.Log, a, "%s", msg) end
end

-- ---------------------------------------------------------------------------
-- Node description
-- ---------------------------------------------------------------------------

local function poiName(poiType)
    if poiType == nil then return "?" end
    if POI_TYPE_GROUP_DUNGEON ~= nil and poiType == POI_TYPE_GROUP_DUNGEON then return "GROUP_DUNGEON" end
    if POI_TYPE_PUBLIC_DUNGEON ~= nil and poiType == POI_TYPE_PUBLIC_DUNGEON then return "PUBLIC_DUNGEON" end
    if POI_TYPE_WAYSHRINE ~= nil and poiType == POI_TYPE_WAYSHRINE then return "WAYSHRINE" end
    if POI_TYPE_HOUSE ~= nil and poiType == POI_TYPE_HOUSE then return "HOUSE" end
    return tostring(poiType)
end

Trace._PoiName = poiName

-- Everything worth knowing about one node, as a single readable line.
function Trace.Describe(nodeIndex)
    if type(GetFastTravelNodeInfo) ~= "function" then
        return string.format("node %s (no API)", tostring(nodeIndex))
    end
    local ok, known, name, _x, _y, _icon, _glow, poiType = pcall(GetFastTravelNodeInfo, nodeIndex)
    if not ok then return string.format("node %s (read failed)", tostring(nodeIndex)) end

    local zoneId
    local T = AccountHold and AccountHold.Travel
    if type(T) == "table" and type(T._NodeZoneId) == "function" then
        local okZ, z = pcall(T._NodeZoneId, nodeIndex)
        if okZ then zoneId = z end
    end

    return string.format("node %s '%s' poi=%s known=%s zone=%s",
        tostring(nodeIndex), tostring(name), poiName(poiType),
        tostring(known and true or false), tostring(zoneId))
end

-- ---------------------------------------------------------------------------
-- The wrap
--
-- FastTravelToNode is only ONE of ESO's travel entry points, which the first
-- version of this module got wrong: travelling to a house logged nothing,
-- because houses do not go through the node network at all. Every path below is
-- unprotected (verified against esoui 12.0.7) and each is wrapped, so "log
-- every travel I make" means every travel.
--
-- Each entry is { globalName, describeArgs } where describeArgs turns the call
-- arguments into a readable line. describeArgs must never throw; it is called
-- inside the guarded logger.
-- ---------------------------------------------------------------------------

-- Resolve a houseId to its collectible name, which is what the player calls it.
local function houseName(houseId)
    local id = tonumber(houseId)
    if not id then return tostring(houseId) end
    if type(GetCollectibleIdForHouse) == "function" and type(GetCollectibleName) == "function" then
        local okId, collectibleId = pcall(GetCollectibleIdForHouse, id)
        if okId and collectibleId and collectibleId ~= 0 then
            local okName, name = pcall(GetCollectibleName, collectibleId)
            if okName and type(name) == "string" and name ~= "" then
                return string.format("%s (houseId %s)", name, tostring(id))
            end
        end
    end
    local zoneId
    if type(GetHouseFoundInZoneId) == "function" then
        local okZ, z = pcall(GetHouseFoundInZoneId, id)
        if okZ then zoneId = z end
    end
    return string.format("houseId %s zone %s", tostring(id), tostring(zoneId))
end

Trace._HouseName = houseName

Trace.TARGETS = {
    {
        name = "FastTravelToNode",
        describe = function(nodeIndex) return "wayshrine " .. Trace.Describe(nodeIndex) end,
    },
    {
        name = "RequestJumpToHouse",
        describe = function(houseId, jumpOutside)
            return string.format("house %s outside=%s", houseName(houseId), tostring(jumpOutside))
        end,
    },
    {
        name = "JumpToSpecificHouse",
        describe = function(displayName, houseId)
            return string.format("house %s of %s", houseName(houseId), tostring(displayName))
        end,
    },
    {
        name = "JumpToHouse",
        describe = function(displayName) return "primary house of " .. tostring(displayName) end,
    },
    {
        name = "JumpToGroupMember",
        describe = function(who) return "group member " .. tostring(who) end,
    },
    {
        name = "JumpToGroupLeader",
        describe = function() return "group leader" end,
    },
    {
        name = "JumpToFriend",
        describe = function(who) return "friend " .. tostring(who) end,
    },
    {
        name = "JumpToGuildMember",
        describe = function(who) return "guild member " .. tostring(who) end,
    },
    {
        name = "TravelToKeep",
        describe = function(keepId) return "keep " .. tostring(keepId) end,
    },
}

-- Install wrappers over every travel entry point. Idempotent.
--
-- This catches EVERY jump the player makes, including ones made by hand from
-- the world map or the collections house list -- which is the whole point.
-- Travelling to a dungeon manually prints that dungeon's real node name, and
-- that is the fact the matcher is missing.
function Trace.Install()
    if Trace._installed then return true end

    Trace._original = {}
    local wrapped = 0

    for _, target in ipairs(Trace.TARGETS) do
        local fnName  = target.name
        local describe = target.describe
        local original = _G[fnName]

        if type(original) == "function" then
            Trace._original[fnName] = original

            _G[fnName] = function(...)
                -- Logging must NEVER be able to stop the jump, so it is fully
                -- isolated and its result discarded.
                --
                -- `describe` is called with the varargs DIRECTLY rather than
                -- through a captured table, because `unpack` is a global in
                -- ESO's Lua 5.1 but moved to `table.unpack` in 5.2+, so a bare
                -- unpack() would work in game and fail in the harness. Passing
                -- ... straight to pcall sidesteps the incompatibility entirely.
                if Trace.IsEnabled() then
                    local okD, line = pcall(describe, ...)
                    pcall(function()
                        Trace.Say("TRAVEL -> %s", (okD and line) or fnName)
                    end)
                end
                return original(...)
            end
            wrapped = wrapped + 1
        end
    end

    Trace._installed = wrapped > 0
    return Trace._installed
end

-- Restore every original. Used by tests and by a clean teardown.
function Trace.Uninstall()
    if not Trace._installed then return end
    for fnName, original in pairs(Trace._original or {}) do
        _G[fnName] = original
    end
    Trace._installed = false
    Trace._original  = nil
end

-- ---------------------------------------------------------------------------
-- Census
--
-- The one-shot answer to "do dungeons even HAVE travel nodes, and what are they
-- called". Printed to chat in one go.
-- ---------------------------------------------------------------------------

function Trace.DumpDungeonNodes()
    local T = AccountHold and AccountHold.Travel
    if type(T) ~= "table" or type(T.DungeonNodes) ~= "function" then
        Trace.Say("Travel module unavailable.")
        return 0
    end

    local total = 0
    if type(GetNumFastTravelNodes) == "function" then
        local ok, n = pcall(GetNumFastTravelNodes)
        if ok and type(n) == "number" then total = n end
    end

    local ok, nodes = pcall(T.DungeonNodes, T)
    if not ok or type(nodes) ~= "table" then
        Trace.Say("Could not read the travel network.")
        return 0
    end

    Trace.Say("%d travel nodes, %d of them dungeon-type:", total, #nodes)
    if #nodes == 0 then
        Trace.Say("NONE. Dungeons are not fast-travel destinations on this client.")
        return 0
    end
    for i = 1, #nodes do
        local n = nodes[i]
        Trace.Say("  %s '%s' known=%s zone=%s",
            tostring(n.index), tostring(n.name), tostring(n.known), tostring(n.zone))
    end
    return #nodes
end

-- Print what the matcher does with one dungeon name, without travelling.
-- Lets the player point at the exact dungeon that failed.
function Trace.TestName(activityName)
    local T = AccountHold and AccountHold.Travel
    if type(T) ~= "table" then Trace.Say("Travel module unavailable.") return end

    Trace.Say("testing '%s'", tostring(activityName))
    local okLike, like = pcall(T.NodesLike, T, activityName)
    if okLike and type(like) == "table" and #like > 0 then
        for i = 1, #like do
            Trace.Say("  near match: %s", Trace.Describe(like[i].index))
        end
    else
        Trace.Say("  no node name starts like that")
    end

    local okFind, node, kind = pcall(T.FindNodeForActivity, T, { activityName = activityName })
    if okFind and type(node) == "number" then
        Trace.Say("  RESOLVES to %s (%s)", Trace.Describe(node), tostring(kind))
    else
        Trace.Say("  DOES NOT RESOLVE")
    end
end

function Trace:Initialize(addonRef)
    self.addon = addonRef
    Trace.Install()

    if not Trace.IsEnabled() then return true end

    -- Print the census once, shortly after the player is in the world.
    --
    -- The travel network is not populated at EVENT_ADD_ON_LOADED, so asking now
    -- would report zero and be worse than useless. Deferred to player
    -- activation, then delayed again so it lands after the login banner rather
    -- than underneath it.
    --
    -- This is what makes the diagnostic reachable on console: no settings
    -- panel, no keystrip, no slash command -- the player logs in and the answer
    -- is in chat. Fires once per session.
    if Trace._announced then return true end

    local function announce()
        if Trace._announced then return end
        Trace._announced = true
        pcall(function()
            Trace.Say("diagnostic build: listing dungeon travel nodes once.")
            Trace.DumpDungeonNodes()
            Trace.Say("travel logging is ON - jump anywhere to see the node used.")
        end)
    end

    local EM = EVENT_MANAGER
    local reg = (EM ~= nil) and EM.RegisterForEvent or nil
    if reg ~= nil and EVENT_PLAYER_ACTIVATED ~= nil then
        local name = ((addonRef and addonRef.name) or "AccountHold") .. "_TravelTraceCensus"
        pcall(function()
            EM:RegisterForEvent(name, EVENT_PLAYER_ACTIVATED, function()
                pcall(function() EM:UnregisterForEvent(name, EVENT_PLAYER_ACTIVATED) end)
                if type(zo_callLater) == "function" then
                    zo_callLater(announce, 8000)
                else
                    announce()
                end
            end)
        end)
    else
        announce()
    end

    return true
end

return Trace
