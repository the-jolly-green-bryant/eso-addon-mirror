-- Random Pet
-- Author: @HuahTu

-- Create the addon class object
local myScope = {}

-- Constants
myScope.NAME = "RandomPet"

-- Semi-global variables
myScope.debug = false

-- Typical CollectibleInfo
-- local name, desc, icon, lockedIcon, unlocked, purchasable, isActive, categoryType, hint = GetCollectibleInfo(collectibleID)

local function debugLog(message)
    if (not myScope.debug)
    then
        return
    end
    d("|c88FFFF[RandomPet]|r " .. tostring(message))
end

local function forceLog(message)
    d("|c88FFFF[RandomPet]|r " .. tostring(message))
end

local function onActivated(eventCode)
    EVENT_MANAGER:UnregisterForEvent(myScope.NAME, EVENT_PLAYER_ACTIVATED)
    debugLog("2026/7/26 08:46 TAIPEI")
end

EVENT_MANAGER:RegisterForEvent(myScope.NAME, EVENT_PLAYER_ACTIVATED, onActivated)

local function switchPet(collectibleID, retries)
    if(IsCollectibleActive(collectibleID))
    then
        -- debugLog("Switched pet with retries " .. retries)
        return
    end

    if(retries >= 5)
    then
        -- debugLog("Failed to switch pet after 5 retries!")
        return
    end

    UseCollectible(collectibleID, GAMEPLAY_ACTOR_CATEGORY_PLAYER)

    zo_callLater(
        function()
            switchPet(collectibleID, retries + 1)
        end, 1000)
end

local function randomSelectPet()
    local totalUnlockedPets = GetTotalUnlockedCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET)
    if(totalUnlockedPets <= 0)
    then
        return
    end

    local targetNdx = math.random(totalUnlockedPets)
    local count = 0

    local totalPets = GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET)
    for i = 1, totalPets do
        local collectibleID = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET, i)
        local _, _, _, _, unlocked = GetCollectibleInfo(collectibleID)
        if(unlocked)
        then
            count = count + 1
            if(count == targetNdx)
            then
                switchPet(collectibleID, 0)
                return
            end
        end
    end
    -- debugLog("Cannot find pet to switch!")
    -- debugLog("totalUnlockedPets: " .. totalUnlockedPets)
    -- debugLog("targetNdx: " .. targetNdx)
    -- debugLog("count: " .. count)
end

local function randomSelectFavoritPet()
    local totalUnlockedPets = GetTotalUnlockedCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET)
    if(totalUnlockedPets <= 0)
    then
        return
    end

    local favoritePets = {}
    local totalPets = GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET)
    local totalFavorites = 0
    for i = 1, totalPets do
        local collectibleID = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET, i)
        local collectibleData = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(collectibleID)
        if(collectibleData:IsFavorite())
        then
            totalFavorites = totalFavorites + 1
            favoritePets[totalFavorites] = collectibleID
        end
    end

    if(totalFavorites == 0)
    then
        return
    end

    local newPetID = favoritePets[math.random(totalFavorites)]
    switchPet(newPetID, 0)
end

local function onMount(eventCode, mounted)
    if not mounted
    then
        return
    end

    local randomMountType = GetRandomMountType(GAMEPLAY_ACTOR_CATEGORY_PLAYER)

    if(randomMountType == RANDOM_MOUNT_TYPE_FAVORITE)
    then
        randomSelectFavoritPet()
        return
    end

    if(randomMountType == RANDOM_MOUNT_TYPE_ANY)
    then
        randomSelectPet()
        return
    end
end

local function setupMountHooks()
    EVENT_MANAGER:RegisterForEvent(myScope.NAME, EVENT_MOUNTED_STATE_CHANGED, onMount)
end

local function onAddOnLoaded(eventCode, addOnName)
    if(addOnName ~= myScope.NAME)
    then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(myScope.NAME, EVENT_ADD_ON_LOADED)

    setupMountHooks()
end

EVENT_MANAGER:RegisterForEvent(myScope.NAME, EVENT_ADD_ON_LOADED, onAddOnLoaded)