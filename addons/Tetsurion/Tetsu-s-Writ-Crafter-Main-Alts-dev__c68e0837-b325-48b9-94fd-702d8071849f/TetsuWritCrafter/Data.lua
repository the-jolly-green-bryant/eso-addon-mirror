TetsuWritCrafter = TetsuWritCrafter or {}
local Data = {}
TetsuWritCrafter.Data = Data

local SECONDS_PER_DAY = 86400
local RESET_OFFSET = 6 * 3600 -- 06:00 UTC

function Data.GetTodayPatternIndex()
    local now = GetTimeStamp()
    local dayNumber = math.floor((now - RESET_OFFSET) / SECONDS_PER_DAY)
    return (dayNumber % 3) + 1
end

Data.Patterns = {
    [CRAFTING_TYPE_BLACKSMITHING] = {
        [1] = { 8, 9, 10 }, -- Cuirass, Sabatons, Gauntlets
        [2] = { 11, 3, 13 }, -- Helm, Sword, Pauldrons
        [3] = { 12, 1, 2 },  -- Greaves, Axe, Mace
    },
    [CRAFTING_TYPE_CLOTHING] = {
        [1] = { 1, 2, 4 },  -- Robe, Breeches, Epaulets
        [2] = { 7, 5, 6 },  -- Helmet, Bracers, Belt
        [3] = { 3, 7, 8 },  -- Shoes, Hat, Jack
    },
    [CRAFTING_TYPE_WOODWORKING] = {
        [1] = { 1, 2, 6 },  -- Bow, Shield, Resto Staff
        [2] = { 2, 1, 1 },  -- Shield, 2 Bows
        [3] = { 3, 4, 5 },  -- Inferno, Ice, Lightning Staff
    },
    [CRAFTING_TYPE_JEWELRYCRAFTING] = {
        [1] = { 1, 2 },     -- Ring, Necklace
        [2] = { 1, 1 },     -- 2 Rings
        [3] = { 2, 2 },     -- 2 Necklaces
    },
    [CRAFTING_TYPE_ENCHANTING] = {
        [1] = { 45837 },    -- Magicka Glyph (Makko)
        [2] = { 45839 },    -- Stamina Glyph (Deni)
        [3] = { 45838 },    -- Health Glyph (Oko)
    }
}

Data.EnchantingPotency = {
    [1] = 45831,  -- Jora
    [2] = 45832,  -- Porade
    [3] = 45833,  -- Jera
    [4] = 45834,  -- Jejora
    [5] = 45835,  -- Odra
    [6] = 45836,  -- Pojora
    [7] = 45844,  -- Rekura
    [8] = 45845,  -- Kura
    [9] = 64509,  -- Rejera
    [10] = 68342, -- Repora
}

function Data.FindItemInBags(itemId)
    for slotIndex = 0, GetBagSize(BAG_BACKPACK) do
        if GetItemId(BAG_BACKPACK, slotIndex) == itemId then
            local stack = GetSlotStackSize(BAG_BACKPACK, slotIndex)
            if stack > 0 then
                return BAG_BACKPACK, slotIndex
            end
        end
    end

    if HasCraftBagAccess() then
        local count = GetItemTotalCount(BAG_VIRTUAL, itemId)
        if count and count > 0 then
            return BAG_VIRTUAL, itemId
        end
    end

    return nil, nil
end

function Data.GetAvailableStyleIndex()
    for styleIndex = 1, 9 do
        local _, _, count = GetStyleMaterialInfo(styleIndex)
        if count and count > 0 then return styleIndex end
    end
    return 1
end