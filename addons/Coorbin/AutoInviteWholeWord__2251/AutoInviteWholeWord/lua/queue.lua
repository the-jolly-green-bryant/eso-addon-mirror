-- This file is part of AutoInvite
--
-- (C) 2016 Scott Yeskie (Sasky)
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

AutoInvite = AutoInvite or {}
local function b(v) if v then return "T" else return "F" end end
local function nn(val) if val == nil then return "NIL" else return val end end
local function dbg(msg) if AutoInvite.debug then d("|c999999" .. msg) end end
local function echo(msg) CHAT_SYSTEM.primaryContainer.currentBuffer:AddMessage("|CFFFF00" .. msg) end

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
AutoInvite.sentInvite = {}
-- sentInvite not array form, so maintain count
AutoInvite.sentInvites = 0

function AutoInvite:processQueue()
    local sentCount = AutoInvite.sentInvites
    local now = GetTimeStamp()
    for name, time in pairs(self.sentInvite) do
        if GetDiffBetweenTimeStamps(now, time) > 30 then
            AutoInvite.sentInvite[name] = nil
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

    AutoInvite.sentInvites = math.max(sentCount, 0)
end

function AutoInvite:IsPlayerInSameGroup(name)
    for i = 1, GetGroupSize() do
        local tag = GetGroupUnitTagByIndex(i)
        if GetUnitName(tag) == name then
            return true
        end
    end
    return false
end

function AutoInvite:IsInviteSent(name)
    return AutoInvite.sentInvite[name]
end

function AutoInvite:checkSentInvites()
    local now = GetTimeStamp()

    local members = {}
    for i = 1, GetGroupSize() do
        local tag = GetGroupUnitTagByIndex(i)
        members[GetUnitName(tag)] = true
    end

    for name, time in pairs(self.sentInvite) do
        if members[name] or GetDiffBetweenTimeStamps(now, time) < 15 then
            self.sentInvite[name] = nil
            AutoInvite.sentInvites = AutoInvite.sentInvites - 1
        end
    end
end

function AutoInvite:resetQueues()
    queue:reset()
end

function AutoInvite:IsInQueue(name)
    for i = queue.front, queue.back do
        if queue.vals[i] == name then
            return i
        end
    end
    return nil
end

function AutoInvite.__getQueue()
    return queue.vals
end

function AutoInvite:resetGroup()
    self:resetQueues()
    for i = 1, GetGroupSize() do
        local tag = GetGroupUnitTagByIndex(i)
        local name = GetUnitName(tag)
        queue:push(name)
    end

    GroupDisband()
    zo_callLater(function() AutoInvite:processQueue() end, 2000)
end

function AutoInvite:inviteGroup()
   --self:resetQueues()
   --for i=1,GetGroupSize() do
   --    local tag = GetGroupUnitTagByIndex(i)
   --    local name = GetUnitName(tag)
   --    queue:push(name)
   --    GroupDisband()
   --    GroupLeave() --for group leader bug
   --end

    zo_callLater(function() AutoInvite:processQueue() end, 2000)
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

function AutoInvite.inviteResponse(_, name, responseCode)
    dbg("Invite response: " .. name .. " : (" .. responseCode .. ") " .. nn(responseCodes[responseCode]))
    if AutoInvite.sentInvite[name] ~= nil then
        --TODO: Build in a retry invite for some options
        AutoInvite.sentInvite[name] = nil
        AutoInvite.sentInvites = math.max(AutoInvite.sentInvites - 1, 0)

        MINI_GROUP_LIST:updateSingle(name)
    end
end

--Interface to queue
function AutoInvite:invitePlayer(name)
    name = name:gsub("%^.+", "")
    if name ~= self.player then
        queue:push(name)
    end
end
