Volette.travel.autoChoice = GetString(VOLETTE_TRAVEL_AUTO)
local wayshrineHouseIds = {
    [1] = 68,  -- Sugar Bowl Suite (Northern Elsweyr)
    [2] = 1,  -- Mara's Kiss (Auridon)
    [3] = 69,  -- Jode's Embrace (Northern Elsweyr)
    [4] = 78,  -- Proudspire Manor (Western Skyrim)
    [5] = 63,  -- Enchanted Snow Globe (Eastmarch)
    [7] = 17,  -- Ravenhurst (Rivenspire)
    [8] = 37,  -- Serenity Falls Estate (Reaper's March)
    [8] = 13,  -- Snugpod (Grahtwood)
    [9] = 19,  -- Kragenhome (Stonefalls)
    [6] = 2,  -- The Rosy Lion (Glenumbra)
    [10] = 3,  -- The Ebony Flask Inn Room (Stonefalls)
}
local wayshrineHouseMapping = {[Volette.travel.autoChoice] = "auto"}

Volette.travel.wayshrineHouses = {[1] = Volette.travel.autoChoice}

for i, houseId in pairs(wayshrineHouseIds) do
    local collectibleId = GetCollectibleIdForHouse(houseId)
    wayshrineHouseMapping[GetCollectibleName(collectibleId)] = houseId
    Volette.travel.wayshrineHouses[i+1] = GetCollectibleName(collectibleId)
end

function Volette.travel.GoToHouse(userID)
    if userID == nil or userID == "" then
        d(Volette.GetText(VOLETTE_HQ_OWNER_MISSING))
    elseif GetDisplayName() == userID then
        RequestJumpToHouse(GetHousingPrimaryHouse(), false)
    else
        JumpToHouse(userID)
    end
end

function Volette.travel.GetHouseId()
    local houseId
    local collectibleId
    if Volette.travel.savedVariables.wayshrineHouse ~= Volette.travel.autoChoice  then
        houseId = wayshrineHouseMapping[Volette.travel.savedVariables.wayshrineHouse]
        collectibleId = GetCollectibleIdForHouse(houseId)
        if IsCollectibleUnlocked(collectibleId) then
            return houseId
        end
        local houseName = GetCollectibleName(collectibleId)
        d(Volette.GetText(VOLETTE_TRAVEL_SEARCHING_ANOTHER_WAYSHRINE, houseName))
    end
    for i = 1, #wayshrineHouseIds do
        houseId = wayshrineHouseIds[i]
        collectibleId = GetCollectibleIdForHouse(houseId)
        if IsCollectibleUnlocked(collectibleId) then
            return houseId
        end
    end
    return nil
end

function Volette.travel.GoToWayshrine()
    local houseId = Volette.travel.GetHouseId()
    if houseId ~= nil then
        local collectibleId = GetCollectibleIdForHouse(houseId)
        local houseName = GetCollectibleName(collectibleId)
        d(Volette.GetText(VOLETTE_TRAVEL_WAYSHRINE_PORTING, houseName))
        RequestJumpToHouse(houseId, true)
    else
        local collectibleId = GetCollectibleIdForHouse(wayshrineHouseIds[1])
        local houseName = GetCollectibleName(collectibleId)
        d(Volette.GetText(VOLETTE_TRAVEL_WAYSHRINE_RECOMMENDATION, houseName))
    end
end

function Volette.travel.SetWayshrineHouse(value)
    Volette.travel.savedVariables.wayshrineHouse = value
    return value
end
