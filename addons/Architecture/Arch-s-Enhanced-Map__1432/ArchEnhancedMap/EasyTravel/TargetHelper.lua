local TYPE_GROUP = 1
local TYPE_FRIEND = 2
local TYPE_GUILD = 3
local JUMP_TO = {
    [TYPE_GROUP] = JumpToGroupMember,
    [TYPE_FRIEND] = JumpToFriend,
    [TYPE_GUILD] = JumpToGuildMember,
}

local TargetHelper = ZO_Object:Subclass()

function TargetHelper:New(...)
    local obj = ZO_Object.New(self)
    obj:Initialize(...)
    return obj
end

function TargetHelper:Initialize()
    self.displayName = GetDisplayName()
    self.alliance = GetUnitAlliance("player")
    self.jumpTargets = {}
    self.collected = {}
    self.hasAttemptedJumpTo = {}
end

function TargetHelper:HasNotCollected(displayName)
    return not self.collected[displayName]
end

function TargetHelper:IsInTargetZone(zoneName)
    return zoneName == self.targetZone
end

function TargetHelper:AddTarget(name, level, cp, type)
    self.jumpTargets[#self.jumpTargets + 1] = {name = name, level = level, cp = cp, type = type}
    self.collected[name] = true
end

function TargetHelper:CollectGroupMembers()
    for i = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(i)
        local displayName = GetUnitDisplayName(unitTag)
        if(self:HasNotCollected(displayName) and IsUnitOnline(unitTag) and self:IsInTargetZone(GetUnitZone(unitTag))) then
            self:AddTarget(displayName, GetUnitLevel(unitTag), GetUnitChampionPoints(unitTag), TYPE_GROUP)
        end
    end
end

function TargetHelper:CollectFriends()
    for i = 1, GetNumFriends() do
        local displayName, _, status = GetFriendInfo(i)
        local hasChar, _, zoneName, _, alliance, level, cp = GetFriendCharacterInfo(i)
        if(hasChar and self:HasNotCollected(displayName) and status ~= PLAYER_STATUS_OFFLINE and self:IsInTargetZone(zoneName)) then
            self:AddTarget(displayName, level, cp, TYPE_FRIEND)
        end
    end
end

function TargetHelper:CollectGuildMembers()
    for g = 1, GetNumGuilds() do
        local guildId = GetGuildId(g)
        for i = 1, GetNumGuildMembers(guildId) do
            local displayName, _, _, status = GetGuildMemberInfo(guildId, i)
            local hasChar, _, zoneName, _, alliance, level, cp = GetGuildMemberCharacterInfo(guildId, i)
            if(hasChar and self:HasNotCollected(displayName) and status ~= PLAYER_STATUS_OFFLINE and self:IsInTargetZone(zoneName)) then
                self:AddTarget(displayName, level, cp, TYPE_GUILD)
            end
        end
    end
end

function TargetHelper:ClearTargets()
    ZO_ClearNumericallyIndexedTable(self.jumpTargets)
    ZO_ClearTable(self.collected)
    self.collected[self.displayName] = true -- prevent adding ourself as target
end

function TargetHelper.ByTypeCpAndLevel(a, b)
    if(a.type == b.type) then
        if(a.cp > 0 or b.cp > 0) then
            return b.cp < a.cp
        else
            return b.level < a.level
        end
    end
    return a.type < b.type
end

function TargetHelper:RebuildTargetList()
    self:ClearTargets()
    self:CollectGroupMembers()
    self:CollectFriends()
    self:CollectGuildMembers()
    table.sort(self.jumpTargets, self.ByTypeCpAndLevel)
end

function TargetHelper:ClearJumpAttempts()
    ZO_ClearTable(self.hasAttemptedJumpTo)
end

function TargetHelper:SetTargetZone(zoneName)
    self.targetZone = zoneName
    self:ClearJumpAttempts()
end

function TargetHelper:JumpToNextTarget()
    for i = 1, #self.jumpTargets do
        local target = self.jumpTargets[i]
        if(not self.hasAttemptedJumpTo[target.name]) then
            self.hasAttemptedJumpTo[target.name] = true
            JUMP_TO[target.type](target.name)
            return true
        end
    end
    return false
end

EasyTravel_AEM.TargetHelper = TargetHelper:New()
