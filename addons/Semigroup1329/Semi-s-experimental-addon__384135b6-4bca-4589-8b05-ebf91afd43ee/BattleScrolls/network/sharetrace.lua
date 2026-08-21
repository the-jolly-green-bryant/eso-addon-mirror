-----------------------------------------------------------
-- ShareTrace
-- Always-on diagnostic event ring for the browser-share pipeline. The Xbox
-- browser-exit input leak can only be diagnosed on the console itself,
-- where logs are unreachable - so the share stepper renders this ring on
-- screen (ui/journal/share_stepper.lua) and everything share-adjacent
-- records into it: transport transitions, keybind presses and leak-guard
-- verdicts, focus changes, suspend gaps, scene teardowns.
-----------------------------------------------------------

if not SemisPlaygroundCheckAccess() then
    return
end

BattleScrolls = BattleScrolls or {}

---@class ShareTraceEntry
---@field gameMs number Game-time ms when recorded
---@field wallS number Wall-clock s when recorded
---@field text string

---@class BattleScrollsShareTrace
local shareTrace = {}
BattleScrolls.shareTrace = shareTrace

local MAX_ENTRIES = 80
---@type ShareTraceEntry[]
local ring = {}
local writeIdx = 0
local total = 0

---@param text string
function shareTrace.record(text)
    writeIdx = (writeIdx % MAX_ENTRIES) + 1
    total = total + 1
    ring[writeIdx] = {
        gameMs = GetGameTimeMilliseconds(),
        wallS = GetTimeStamp(),
        text = text,
    }
end

---Chronological snapshot (oldest first).
---@return ShareTraceEntry[]
function shareTrace.list()
    local out = {}
    local count = math.min(total, MAX_ENTRIES)
    for i = count - 1, 0, -1 do
        local idx = ((writeIdx - 1 - i) % MAX_ENTRIES) + 1
        out[#out + 1] = ring[idx]
    end
    return out
end

function shareTrace.clear()
    ring = {}
    writeIdx = 0
    total = 0
end
