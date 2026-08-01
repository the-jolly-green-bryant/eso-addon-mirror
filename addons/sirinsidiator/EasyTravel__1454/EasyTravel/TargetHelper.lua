local ET = EasyTravel
local internal = ET.internal

local PlayerList = ET.class.PlayerList

local JUMP_TO = {
    [PlayerList.TYPE_GROUP] = JumpToGroupMember,
    [PlayerList.TYPE_FRIEND] = JumpToFriend,
    [PlayerList.TYPE_GUILD] = JumpToGuildMember,
    [PlayerList.TYPE_LEADER] = JumpToGroupLeader,
    [PlayerList.TYPE_HOUSE] = RequestJumpToHouse,
}

local TargetHelper = ZO_InitializingObject:Subclass()
ET.class.TargetHelper = TargetHelper

function TargetHelper:Initialize(playerList)
    self.playerList = playerList
    self.hasAttemptedJumpTo = {}
end

function TargetHelper:ClearJumpAttempts()
    ZO_ClearTable(self.hasAttemptedJumpTo)
end

local function JumpTo(type, name)
    EndInteraction(INTERACTION_FAST_TRAVEL_KEEP)
    EndInteraction(INTERACTION_FAST_TRAVEL)
    JUMP_TO[type](name)
end

function TargetHelper:JumpToNextTargetInZone(zone)
    local targets = self.playerList:GetSortedPlayersInZone(zone)
    for i = 1, #targets do
        local target = targets[i]
        if(not self.hasAttemptedJumpTo[target.displayName]) then
            self.hasAttemptedJumpTo[target.displayName] = true
            JumpTo(target.type, target.displayName)
            return true
        end
    end
    return false
end

function TargetHelper:JumpToPlayer(player)
    JumpTo(player.type, player.displayName)
end

function TargetHelper:JumpToGroupLeader()
    JumpTo(PlayerList.TYPE_LEADER)
end

function TargetHelper:JumpToHouse(houseId)
    JumpTo(PlayerList.TYPE_HOUSE, houseId)
end
