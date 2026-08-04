-- CharacterMarkdown - API Layer - Collectibles
-- Abstraction for DLC, mounts, pets, costumes, and housing

local CM = CharacterMarkdown
CM.api = CM.api or {}
CM.api.collectibles = {}

local api = CM.api.collectibles

local function CleanCollectibleName(name)
    if not name or type(name) ~= "string" then
        return name or "Unknown"
    end
    return name:gsub("%^%w+$", "")
end

-- =====================================================
-- CACHING
-- =====================================================

local _collectibleCache = {} -- Cache by categoryType

-- =====================================================
-- GRANULAR GETTERS
-- =====================================================

function api.CheckDLCAccess(zoneId)
    -- DLC Check logic using CanJumpToPlayerInZone as proxy for "Do I have access?"
    -- CanJumpToPlayerInZone(zoneId) returns (canJump: bool, result: JumpToPlayerResult)
    -- pcall returns (success, canJump, result)
    local success, canJump, result = pcall(CanJumpToPlayerInZone, zoneId)

    local isLocked = false
    if success and result == JUMP_TO_PLAYER_RESULT_ZONE_COLLECTIBLE_LOCKED then
        isLocked = true
    end

    return not isLocked
end

function api.IsESOPlus()
    return CM.SafeCall(IsESOPlusSubscriber) or false
end

function api.GetUnlockedCollectibles(categoryType)
    -- Return cached if available
    if _collectibleCache[categoryType] then
        return _collectibleCache[categoryType]
    end

    local total = CM.SafeCall(GetTotalCollectiblesByCategoryType, categoryType) or 0
    local unlocked = {}
    local count = 0

    for i = 1, total do
        local id = CM.SafeCall(GetCollectibleIdFromType, categoryType, i)
        if id then
            local isUnlocked = CM.SafeCall(IsCollectibleUnlocked, id)
            if isUnlocked then
                local name = CleanCollectibleName(CM.SafeCall(GetCollectibleName, id))
                local nickname = CM.SafeCall(GetCollectibleNickname, id)
                if nickname then
                    nickname = CleanCollectibleName(nickname)
                end

                table.insert(unlocked, {
                    id = id,
                    name = name or "Unknown",
                    fullName = name or "Unknown",
                    nickname = nickname,
                })
                count = count + 1
            end
        end
    end

    local result = {
        total = total,
        count = count,
        list = unlocked,
    }

    -- Cache the result
    _collectibleCache[categoryType] = result
    return result
end

function api.ClearCache()
    _collectibleCache = {}
end

function api.GetHousingInfo()
    -- GetHousingPrimaryHouse returns a houseId (housing namespace), not a collectible ID.
    local primaryHouseId = CM.SafeCall(GetHousingPrimaryHouse)
    local primaryCollectibleId = nil
    local primaryName = nil
    local furnitureCount = nil
    local isListed = nil

    -- To get all houses, we iterate the HOUSE category collectible
    local houses = api.GetUnlockedCollectibles(COLLECTIBLE_CATEGORY_TYPE_HOUSE)

    if primaryHouseId and primaryHouseId > 0 then
        if GetCollectibleIdForHouse then
            primaryCollectibleId = CM.SafeCall(GetCollectibleIdForHouse, primaryHouseId)
        end

        if primaryCollectibleId and primaryCollectibleId > 0 then
            primaryName = CleanCollectibleName(CM.SafeCall(GetCollectibleName, primaryCollectibleId))
            -- Prefer display name from owned house list when collectible name is empty
            if (not primaryName or primaryName == "") and houses and houses.list then
                for _, house in ipairs(houses.list) do
                    if house.id == primaryCollectibleId and house.name and house.name ~= "" then
                        primaryName = house.name
                        break
                    end
                end
            end
        end

        -- Last resort: omit name rather than labeling with a wrong collectible (e.g. a pet)
        if primaryName == "" then
            primaryName = nil
        end

        if GetHouseFurnitureCount then
            furnitureCount = CM.SafeCall(GetHouseFurnitureCount, primaryHouseId)
        end
        if IsHouseListed then
            isListed = CM.SafeCall(IsHouseListed, primaryHouseId)
        end
    end

    local toursStatus = nil
    if GetHouseToursStatus then
        toursStatus = CM.SafeCall(GetHouseToursStatus)
    end

    return {
        primary = {
            houseId = primaryHouseId,
            id = primaryHouseId, -- alias for callers that still read .id
            collectibleId = primaryCollectibleId,
            name = primaryName,
            furnitureCount = furnitureCount,
            isListedOnTours = isListed,
        },
        owned = houses,
        houseToursStatus = toursStatus,
    }
end

-- Composition functions moved to collector level
