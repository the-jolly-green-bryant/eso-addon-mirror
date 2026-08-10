--[[
    Nemesis - Scrim mode
    Shares your build (bars, class, CP, worn sets) with groupmates who also run
    Nemesis, via the official group data broadcast channel (U45+, 8 x uint32).

    Protocol (data1 identifies the message):
      MAGIC+1: front bar   [magic, s1..s5, ult, classId*10000 + cp]
      MAGIC+2: back bar    [magic, s1..s5, ult, 0]
      MAGIC+3: worn sets   [magic, setId x7]

    NOTE: the game allows only ONE addon per session to claim the broadcast
    channel. If another addon claimed it first, scrim mode disables itself.
]]

Nemesis = Nemesis or {}
local N = Nemesis
N.Scrim = {}
local Scrim = N.Scrim

local EM = EVENT_MANAGER
local SV

local MAGIC = 1313100544 -- "NMS" tag; + message type
local MSG_FRONT, MSG_BACK, MSG_SETS = MAGIC + 1, MAGIC + 2, MAGIC + 3

local authKey = nil
local builds = {}     -- displayName -> { front, back, sets, classId, cp, at }
local pending = {}
local pumping = false
local sendQueued = false

-- Own build ----------------------------------------------------------------------

local function GetOwnBars()
    local front, back = {}, {}
    for slot = 3, 8 do
        front[#front + 1] = GetSlotBoundId(slot, HOTBAR_CATEGORY_PRIMARY) or 0
        back[#back + 1] = GetSlotBoundId(slot, HOTBAR_CATEGORY_BACKUP) or 0
    end
    return front, back
end

local function GetOwnSets()
    local counts = {}
    for slotIndex = 0, 16 do
        local link = GetItemLink(BAG_WORN, slotIndex, LINK_STYLE_DEFAULT)
        if link and link ~= "" then
            local hasSet, _, _, numNormal, _, setId, numPerfected = GetItemLinkSetInfo(link)
            if hasSet and setId and setId > 0 then
                counts[setId] = (numNormal or 0) + (numPerfected or 0)
            end
        end
    end
    local list = {}
    for setId, count in pairs(counts) do
        if count >= 2 then list[#list + 1] = { id = setId, count = count } end
    end
    table.sort(list, function(a, b) return a.count > b.count end)
    local out = {}
    for i = 1, zo_min(7, #list) do out[i] = list[i].id end
    return out
end

-- Sending ------------------------------------------------------------------------

local function PumpQueue()
    if #pending == 0 then
        pumping = false
        return
    end
    pumping = true
    local cooldown = GetGroupAddOnDataBroadcastCooldownRemainingMS()
    if cooldown > 0 then
        zo_callLater(PumpQueue, cooldown + 150)
        return
    end
    local msg = table.remove(pending, 1)
    local result = BroadcastAddOnDataToGroup(authKey, unpack(msg))
    if result == GROUP_ADD_ON_DATA_BROADCAST_RESULT_ON_COOLDOWN then
        table.insert(pending, 1, msg)
    elseif result == GROUP_ADD_ON_DATA_BROADCAST_RESULT_INVALID_GROUP then
        pending = {} -- not in a group anymore, drop everything
    end
    zo_callLater(PumpQueue, 1200)
end

local function SendBuild()
    if not authKey or not IsUnitGrouped("player") then return end
    local front, back = GetOwnBars()
    local classId = GetUnitClassId("player") or 0
    local cp = zo_min(GetUnitChampionPoints("player") or 0, 9999)
    local sets = GetOwnSets()

    pending = {}
    pending[1] = { MSG_FRONT, front[1], front[2], front[3], front[4], front[5], front[6], classId * 10000 + cp }
    pending[2] = { MSG_BACK, back[1], back[2], back[3], back[4], back[5], back[6], 0 }
    local setsMsg = { MSG_SETS }
    for i = 1, 7 do setsMsg[i + 1] = sets[i] or 0 end
    pending[3] = setsMsg

    if not pumping then PumpQueue() end
end

-- Debounced send (bar swaps fire lots of updates).
local function QueueSend(delayMs)
    if sendQueued then return end
    sendQueued = true
    zo_callLater(function()
        sendQueued = false
        SendBuild()
    end, delayMs or 3000)
end

-- Receiving ----------------------------------------------------------------------

local function OnDataReceived(_, senderUnitTag, data1, data2, data3, data4, data5, data6, data7, data8)
    local displayName = GetUnitDisplayName(senderUnitTag)
    if not displayName or displayName == "" or displayName == GetDisplayName() then return end

    if data1 ~= MSG_FRONT and data1 ~= MSG_BACK and data1 ~= MSG_SETS then return end

    local build = builds[displayName]
    if not build then
        build = { front = {}, back = {}, sets = {} }
        builds[displayName] = build
    end
    build.at = GetTimeStamp()

    if data1 == MSG_FRONT then
        build.front = { data2, data3, data4, data5, data6, data7 }
        local packed = data8 or 0
        build.classId = zo_floor(packed / 10000)
        build.cp = packed % 10000
    elseif data1 == MSG_BACK then
        build.back = { data2, data3, data4, data5, data6, data7 }
    elseif data1 == MSG_SETS then
        build.sets = {}
        for _, setId in ipairs({ data2, data3, data4, data5, data6, data7, data8 }) do
            if setId and setId > 0 then build.sets[#build.sets + 1] = setId end
        end
    end
end

function Scrim.GetBuildFor(displayName)
    return displayName and builds[displayName] or nil
end

-- Init ---------------------------------------------------------------------------

function Scrim.Init(savedVars)
    SV = savedVars
    if not SV.scrim then return end

    local key, ownerName = RegisterForGroupAddOnDataBroadcastAuthKey(N.name)
    if not key then
        N.Msg(string.format("Scrim link disabled: broadcast channel already claimed by '%s'.", ownerName or "?"))
        return
    end
    authKey = key

    EM:RegisterForEvent(N.name .. "ScrimRecv", EVENT_GROUP_ADD_ON_DATA_RECEIVED, OnDataReceived)

    EM:RegisterForEvent(N.name .. "ScrimActivated", EVENT_PLAYER_ACTIVATED, function()
        if IsUnitGrouped("player") then QueueSend(4000) end
    end)
    EM:RegisterForEvent(N.name .. "ScrimJoin", EVENT_GROUP_MEMBER_JOINED, function()
        QueueSend(5000)
    end)
    EM:RegisterForEvent(N.name .. "ScrimBars", EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, function()
        if IsUnitGrouped("player") then QueueSend(10000) end
    end)
    EM:RegisterForEvent(N.name .. "ScrimDuel", EVENT_DUEL_INVITE_ACCEPTED, function()
        if IsUnitGrouped("player") then QueueSend(500) end
    end)
end
