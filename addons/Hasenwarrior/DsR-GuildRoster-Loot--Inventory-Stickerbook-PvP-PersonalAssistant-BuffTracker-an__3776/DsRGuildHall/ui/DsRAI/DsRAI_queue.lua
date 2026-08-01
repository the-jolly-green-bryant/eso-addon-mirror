DsRAutoINV = DsRAutoINV or {}
local function b(v) if v then return "T" else return "F" end end
local function nn(val) if val == nil then return "NIL" else return val end end
local function dbg(msg) if DsRAutoINV.debug then d("|c999999" .. msg) end end
local function echo(msg) CHAT_ROUTER:AddSystemMessage("|CFFFF00" .. msg) end

-- FIFO invite queue
local queue = {
    vals = {},
    front = 1,
    back = 1,
}

function queue:size()
    return queue.back - queue.front
end

function queue:push(val)
    local back = self.back
    self.vals[back] = val
    self.back = back + 1
    MINI_GROUP_LIST:updateSingle(val)
end

function queue:pop()
    if self:size() == 0 then
        return nil
    end
    local front = self.front
    local retval = self.vals[front]
    self.vals[front] = nil
    self.front = front + 1
    return retval
end

function queue:reset()
    self.vals = {}
    self.front = 1
    self.back = 1
end

-- Key: name / Value: timestamp
DsRAutoINV.sentInvite = {}
-- sentInvite not array form, so maintain count
DsRAutoINV.sentInvites = 0

function DsRAutoINV:processQueue()
    local sentCount = DsRAutoINV.sentInvites
    local now = GetTimeStamp()
    for name, time in pairs(self.sentInvite) do
        if GetDiffBetweenTimeStamps(now, time) > 30 then
            DsRAutoINV.sentInvite[name] = nil
            sentCount = sentCount - 1
        end
    end

    local effectiveCount = GetGroupSize() + sentCount
    local numInvites = math.min(queue:size(), self.cfg.maxSize - effectiveCount)
    for _ = 1, numInvites do
        local name = queue:pop()
        sentCount = sentCount + 1
        self.sentInvite[name] = now
        if self.player ~= name then
            GroupInviteByName(name)
        end
        MINI_GROUP_LIST:updateSingle(name)
    end

    DsRAutoINV.sentInvites = math.max(sentCount, 0)
end

function DsRAutoINV:IsPlayerInSameGroup(name)
    for i = 1, GetGroupSize() do
        local tag = GetGroupUnitTagByIndex(i)
        if GetUnitName(tag) == name then
            return true
        end
    end
    return false
end

function DsRAutoINV:IsInviteSent(name)
    return DsRAutoINV.sentInvite[name]
end

function DsRAutoINV:checkSentInvites()
    local now = GetTimeStamp()

    local members = {}
    for i = 1, GetGroupSize() do
        local tag = GetGroupUnitTagByIndex(i)
        members[GetUnitName(tag)] = true
    end

    for name, time in pairs(self.sentInvite) do
        if members[name] or GetDiffBetweenTimeStamps(now, time) < 15 then
            self.sentInvite[name] = nil
            DsRAutoINV.sentInvites = DsRAutoINV.sentInvites - 1
        end
    end
end

function DsRAutoINV:resetQueues()
    queue:reset()
end

function DsRAutoINV:IsInQueue(name)
    for i = queue.front, queue.back do
        if queue.vals[i] == name then
            return i
        end
    end
    return nil
end

function DsRAutoINV.__getQueue()
    return queue.vals
end

local responseCodes = {
    [GROUP_INVITE_RESPONSE_ACCEPTED] = "accept",
    [GROUP_INVITE_RESPONSE_ALREADY_GROUPED] = "inGroup",
    [GROUP_INVITE_RESPONSE_CONSIDERING_OTHER] = "hasInv",
    [GROUP_INVITE_RESPONSE_DECLINED] = "decline",
    [GROUP_INVITE_RESPONSE_GROUP_FULL] = "full",
    [GROUP_INVITE_RESPONSE_IGNORED] = "ignored",
    [GROUP_INVITE_RESPONSE_INVITED] = "invited?",
    [GROUP_INVITE_RESPONSE_ONLY_LEADER_CAN_INVITE] = "notLead",
    [GROUP_INVITE_RESPONSE_OTHER_ALLIANCE] = "otherAlly",
    [GROUP_INVITE_RESPONSE_PLAYER_NOT_FOUND] = "noPlayer",
    [GROUP_INVITE_RESPONSE_SELF_INVITE] = "self",
}

function DsRAutoINV.inviteResponse(_, name, responseCode)
    dbg("Invite response: " .. name .. " : (" .. responseCode .. ") " .. nn(responseCodes[responseCode]))
    if DsRAutoINV.sentInvite[name] ~= nil then
        --TODO: Build in a retry invite for some options
        DsRAutoINV.sentInvite[name] = nil
        DsRAutoINV.sentInvites = math.max(DsRAutoINV.sentInvites - 1, 0)

        MINI_GROUP_LIST:updateSingle(name)
    end
end

--Interface to queue
function DsRAutoINV:invitePlayer(name)
    name = name:gsub("%^.+", "")
    if name ~= self.player then
        queue:push(name)
    end
end
