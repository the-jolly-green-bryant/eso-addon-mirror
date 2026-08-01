CC_HELPER = CC_HELPER or {}

CC_MEMENTO_COLLECTIBLE_TYPE   = COLLECTIBLE_CATEGORY_TYPE_MEMENTO
CC_ASSISTANT_COLLECTIBLE_TYPE = COLLECTIBLE_CATEGORY_TYPE_ASSISTANT
CC_COMPANION_COLLECTIBLE_TYPE = 27
CC_TOOL_COLLECTIBLE_TYPE      = 2

local function GetCollectiblesByType (collectibleType)

    -- Filter for housing and outfit
    local function IsNotHouseOutfit(collData)
      return not collData:IsOutfitStylesCategory() and not collData:IsHousingCategory()
    end
  
    -- Check if is the correct type
    local function IsCollectibleType(collData)
      return collData:IsCategoryType(collectibleType)
    end
  
    local collectibleList = {}
    local ownedCollectiblesTable = {}
  
    -- Loop through all catagories that are not house or outfit
    for _, categoryData in ZO_COLLECTIBLE_DATA_MANAGER:CategoryIterator({ IsNotHouseOutfit }) do
  
      for _, collectibleData in categoryData:CollectibleIterator({ IsCollectibleType }) do
        
        -- Only show if they own, duh
        if collectibleData:IsUnlocked() then
          collectibleList[collectibleData:GetId()] = collectibleData:GetFormattedName()
        end
      end
    end
  
    -- We only need the id
    for id, _ in pairs(collectibleList) do
      table.insert(ownedCollectiblesTable, id)
    end
  
    -- Sort in assending order
    table.sort(ownedCollectiblesTable)
  
    -- Return list of collectible ids
    return ownedCollectiblesTable
end

local function GetSubCollectiblesByType(collectibleType)

    -- Filter for housing and outfit
    local function IsNotHouseOutfit(collectibleData)
      return not collectibleData:IsOutfitStylesCategory() and not collectibleData:IsHousingCategory()
    end
  
    -- Check if is the correct type
    local function IsCollectibleType(collectibleData)
      return collectibleData:IsCategoryType(collectibleType)
    end
  
    local collectibleList = {}
    local ownedCollectiblesTable = {}
  
    -- Loop through all catagories that are not house or outfit
    for _, categoryData in ZO_COLLECTIBLE_DATA_MANAGER:CategoryIterator({ IsNotHouseOutfit }) do
  
      -- The same as before
      for _, subCategoryData in categoryData:SubcategoryIterator({ IsNotHouseOutfit }) do
        -- Now loop through the collectibles we do want
        for _, subCatCollectibleData in subCategoryData:CollectibleIterator({ IsCollectibleType }) do
  
          -- Only show if they own, duh
          if subCatCollectibleData:IsUnlocked() then
            collectibleList[subCatCollectibleData:GetId()] = subCatCollectibleData:GetFormattedName()
          end
        end
      end
    end
  
    -- We only need the id
    for id, _ in pairs(collectibleList) do
      table.insert(ownedCollectiblesTable, id)
    end
  
    -- Sort in assending order
    table.sort(ownedCollectiblesTable)
  
    -- Return list of collectible ids
    return ownedCollectiblesTable
end

--[[
    Return a list of allie collectibles

    Gets both assistants and companions
]]
function CC_HELPER:GetAllieCollectibles()

    local assistantList = GetSubCollectiblesByType(CC_ASSISTANT_COLLECTIBLE_TYPE)
    local companionList = GetSubCollectiblesByType(CC_COMPANION_COLLECTIBLE_TYPE)

    for _, v in ipairs(companionList) do
        table.insert(assistantList, v)
    end

    return assistantList
end

--[[
    Return a list of tool collectibles
]]
function CC_HELPER:GetToolCollectibles()
    local mementoList = GetCollectiblesByType(CC_MEMENTO_COLLECTIBLE_TYPE)
    local result = {}
    for i = 1, #mementoList do
        local collectibleId = mementoList[i]
        local collectibleData = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(collectibleId)

        if collectibleData:GetSpecializedCategoryType() == CC_TOOL_COLLECTIBLE_TYPE then
            table.insert(result, collectibleId)
        end

    end

    return result
end

--[[
    Return a list of memento collectibles
]]
function CC_HELPER:GetMementoCollectibles()
    local mementoList = GetCollectiblesByType(CC_MEMENTO_COLLECTIBLE_TYPE)
    local result = {}

    for i = 1, #mementoList do
        local collectibleId = mementoList[i]
        local collectibleData = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(collectibleId)

        if collectibleData:GetSpecializedCategoryType() ~= CC_TOOL_COLLECTIBLE_TYPE then
            table.insert(result, collectibleId)
        end
    end

    return result
end

function CC_HELPER:GetSubCollectibleByType(type)
    return GetSubCollectiblesByType(type)
end

function CC_HELPER:GetCollectibleByType(type)
    return GetCollectiblesByType(type)
end