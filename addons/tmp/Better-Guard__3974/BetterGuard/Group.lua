BetterGuardAddon = BetterGuardAddon or {}
local BG = BetterGuardAddon

BG.groupMembers = {}

local function GenerateGroupList()
    BG.groupMembers = {}
    local groupSize = GetGroupSize()
    if groupSize == 0 then return end
    for i = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(i)
        if unitTag then
            BG.groupMembers[GetRawUnitName(unitTag)] = unitTag
        end
    end
end

BG.GenerateGroupList = GenerateGroupList