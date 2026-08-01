function UnDeadGroupMod.setVet()
    local isVet = IsUnitUsingVeteranDifficulty("player")
    SetVeteranDifficulty(not isVet)
end

function UnDeadGroupMod.setRole()
    local isRole = GetSelectedLFGRole()
    if isRole == ROLE.DPS then
        UpdateSelectedLFGRole(ROLE.TANK)
    elseif isRole == ROLE.TANK then
        UpdateSelectedLFGRole(ROLE.HEALER)
    elseif isRole == ROLE.HEALER then
        UpdateSelectedLFGRole(ROLE.DPS)
    elseif isRole == ROLE.INVALID then
        UpdateSelectedLFGRole(ROLE.DPS)
    end
end

-- Generic friend action
local function friendAction(idx, action)
    local friendName = UnDeadGroupMod.SavedVariables.Friends[idx]
    if friendName and friendName ~= "" then
        action(friendName)
    end
end

-- House actions
function UnDeadGroupMod.MyHouse()
    local houseId = GetHousingPrimaryHouse()
    RequestJumpToHouse(houseId, false)
end

function UnDeadGroupMod.House(idx)
    friendAction(idx, JumpToHouse)
end

-- Invite actions
function UnDeadGroupMod.Invite(idx)
    friendAction(idx, GroupInviteByName)
end

-- Jump actions
function UnDeadGroupMod.Jump(idx)
    friendAction(idx, JumpToFriend)
end

function UnDeadGroupMod.gotoSettings(option)
    local LAM = LibAddonMenu2
    LAM:OpenToPanel(UnDeadGroupModSettingsPanel)
end

function UnDeadGroupMod.ReadyCheck(option)
    local inGroup = IsUnitGrouped("player")
    if inGroup then
        ---@diagnostic disable-next-line: param-type-mismatch
        local started = BeginGroupElection(2, "Hey, You Ready??", "", 1)
        if started then
            ELECTION.ACTIVE = true
            ELECTION.COUNTER = 0
        end
    end
end

function UnDeadGroupMod.DungeonQueue()
    local sv = UnDeadGroupMod.SavedVariables
    AddActivityFinderSetSearchEntry(sv.selectedQ)
    d(QUEUE_NAMES[sv.selectedQ] or "Unknown Queue")
    RequestGroupFinderSearch()
    --StartGroupFinderSearch()
end
