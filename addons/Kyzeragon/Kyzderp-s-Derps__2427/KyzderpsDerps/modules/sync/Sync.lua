KyzderpsDerps = KyzderpsDerps or {}

KyzderpsDerps.Sync = KyzderpsDerps.Sync or {}
local Sync = KyzderpsDerps.Sync


---------------------------------------------------------------------
local function AttemptCollectible(id)
    if (not IsCollectibleUsable(id)) then return end
    if (IsUnitInCombat("player") and KyzderpsDerps.savedOptions.sync.mementos.ignoreInCombat) then KyzderpsDerps:dbg("ignoring sync because in combat") return end
    UseCollectible(id)
end


---------------------------------------------------------------------
-- Wave?
---------------------------------------------------------------------
-- TODO: how to know who has kyzderps? don't really want to use data sharing. could potentially listen for combat events but ehh
local function GetSelfIndexInWave()
    if (GetGroupSize() < 2) then return end

    local points = {}
    local avgX = 0
    local avgZ = 0
    for i = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(i)
        if (IsUnitOnline(unitTag)) then
            local _, x, y, z = GetUnitRawWorldPosition(unitTag)
            table.insert(points, {unitTag = unitTag, x = x, z = z})
            avgX = avgX + x
            avgZ = avgZ + z
        end
    end
    avgX = avgX / #points
    avgZ = avgZ / #points

    -- There could be a mismatch between index, probably, so sort by name
    table.sort(points, function(a, b) return GetUnitDisplayName(a.unitTag) < GetUnitDisplayName(b.unitTag) end)

    -- idk just making up an algorithm that should be reasonable enough
    -- Find farthest point from the average, it will be the start
    local farthestIndex
    local farthestDist = 0
    for i, point in ipairs(points) do
        local dist = math.pow(point.x - avgX, 2) + math.pow(point.z - avgZ, 2)
        if (dist > farthestDist) then
            farthestDist = dist
            farthestIndex = i
        end
    end

    -- Now order the rest
    local order = {}
    local currPoint = table.remove(points, farthestIndex)
    table.insert(order, GetUnitDisplayName(currPoint.unitTag))
    while (#points > 0) do
        -- Find the closest point to current
        local closestIndex
        local closestDist = math.huge
        for i, point in ipairs(points) do
            local dist = math.pow(point.x - currPoint.x, 2) + math.pow(point.z - currPoint.z, 2)
            if (dist < closestDist) then
                closestDist = dist
                closestIndex = i
            end
            KyzderpsDerps:dbg(string.format("%s <--> %s: %f", GetUnitDisplayName(currPoint.unitTag), GetUnitDisplayName(point.unitTag), dist))
        end

        currPoint = table.remove(points, closestIndex)
        KyzderpsDerps:dbg(GetUnitDisplayName(currPoint.unitTag))
        table.insert(order, GetUnitDisplayName(currPoint.unitTag))
    end

    -- d(order)

    -- Find the index of yourself
    for i, name in ipairs(order) do
        if (name == GetUnitDisplayName("player")) then
            return i
        end
    end
end

-- Returns true if handled
local function HandleWave(fromName, text)
    -- KDD wave |H1:collectible:10235|h|h 200
    local id, interval
    for first, second in string.gmatch(text, "^KDD wave |H1:collectible:(%d+)|h|h (%d+)$") do
        id = tonumber(first)
        interval = zo_clamp(tonumber(second), 0, 5000)
    end

    if (not id or not interval) then return false end

    local index = GetSelfIndexInWave()
    if (not index) then
        KyzderpsDerps:msg("Not enough players for wave, or couldn't find index!")
        return true
    end

    zo_callLater(function()
        AttemptCollectible(id)
    end, interval * (index - 1))

    return true
end


---------------------------------------------------------------------
-- Memento syncing for totally not nefarious purposes
---------------------------------------------------------------------
local function HandleCommand(argString)
    if (string.len(argString) < 1) then
        KyzderpsDerps:msg("Usage: /kddsync <searchterm>\nExample: /kddsync cadwell's surprise")
        return
    end

    local search = string.lower(argString)
    for i = 1, GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO) do
        local id = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO, i)
        if (string.find(string.lower(GetCollectibleName(id)), search, 1, true)) then
            StartChatInput(string.format("KDD %s", GetCollectibleLink(id, LINK_STYLE_BRACKETS)), CHAT_CHANNEL_PARTY)
            return
        end
    end
end

local function HandleCommandWave(argString)
    if (string.len(argString) < 1) then
        KyzderpsDerps:msg("Usage: /kddsyncwave <searchterm>\nExample: /kddsyncwave cadwell's surprise")
        return
    end

    local search = string.lower(argString)
    for i = 1, GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO) do
        local id = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO, i)
        if (string.find(string.lower(GetCollectibleName(id)), search, 1, true)) then
            StartChatInput(string.format("KDD wave %s 300", GetCollectibleLink(id, LINK_STYLE_BRACKETS)), CHAT_CHANNEL_PARTY)
            return
        end
    end
end


---------------------------------------------------------------------
-- Chat parsing: "KDD |H1:collectible:10235|h|h" "KDD 10235"
---------------------------------------------------------------------
-- EVENT_CHAT_MESSAGE_CHANNEL (*[ChannelType|#ChannelType]* _channelType_, *string* _fromName_, *string* _text_, *bool* _isCustomerService_, *string* _fromDisplayName_)
local function OnChatMessage(_, channelType, fromName, text)
    if (channelType ~= CHAT_CHANNEL_PARTY) then return end

    if (HandleWave(fromName, text)) then return end

    -- |H1:collectible:10235|h|h
    local id
    for collectibleId in string.gmatch(text, "^KDD |H1:collectible:(%d+)|h|h$") do
        id = tonumber(collectibleId)
    end
    if (not id) then
        for collectibleId in string.gmatch(text, "^KDD (%d+)$") do
            id = tonumber(collectibleId)
        end
    end

    if (not IsCollectibleUnlocked(id)) then return end

    -- Randomized delay
    local delay = KyzderpsDerps.savedOptions.sync.mementos.delay
    if (KyzderpsDerps.savedOptions.sync.mementos.random) then
        delay = math.random(0, delay)
        KyzderpsDerps:dbg(string.format("waiting %dms", delay))
    end

    if (delay == 0) then
        AttemptCollectible(id)
    else
        zo_callLater(function()
            AttemptCollectible(id)
        end, delay)
    end
end


---------------------------------------------------------------------
-- Initialize
---------------------------------------------------------------------
function Sync.Initialize()
    KyzderpsDerps:dbg("    Initializing Sync module...")

    SLASH_COMMANDS["/kddsync"] = HandleCommand
    SLASH_COMMANDS["/kddsyncwave"] = HandleCommandWave

    EVENT_MANAGER:UnregisterForEvent(KyzderpsDerps.name .. "SyncChatMessage", EVENT_CHAT_MESSAGE_CHANNEL)
    if (KyzderpsDerps.savedOptions.sync.mementos.party) then
        EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "SyncChatMessage", EVENT_CHAT_MESSAGE_CHANNEL, OnChatMessage)
    end
end