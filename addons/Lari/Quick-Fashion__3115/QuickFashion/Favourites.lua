local QF = _G["QF"]

local WM = WINDOW_MANAGER

-------------------------------
-- HELPER FUNCTIONS --
-------------------------------

-- Check if collectible is in Favourites table by ID
function QF.IsFavourite(id, type)
  local FavouritesByType = QF.SavedVars.FavouritesByType
  for i,v in pairs(FavouritesByType[type]) do
    if (v == id) then
      return true
    end
  end
  return false
end

--------------------------------------------
-- ADDING/REMOVING FAVOURITES --
--------------------------------------------

-- Save a collectible to favourites/saved variables
function QF.AddToFavourites(FavouritesTableByType, id)
  if id ~= 0 and id ~= nil and id ~= "" then
    local collectibleName = GetCollectibleName(id)
    local collectibleType = GetCollectibleCategoryType(id)

    if QF.IsFavourite(id, collectibleType) == true then
      QF.ChatMessage(string.format("|c9081ff%s|r is already in your Favourites.", collectibleName))
      return
    end

    table.insert(FavouritesTableByType, id)
    table.sort(FavouritesTableByType)
    QF.SavedVars.FavouritesByType[collectibleType] = FavouritesTableByType
    QF.ChatMessage(string.format("|c9081ff%s|r was added to your Favourites.", collectibleName))

    local controlName = string.format("QF_Fav_ID_%i", id)
    local control = WM:GetControlByName(controlName)

    -- Check if collectible control exists and create a new one if not.
    if control == nil then
      QF.CreateCollectibleIcon(id, collectibleType)
    else
      local star = control:GetNamedChild("Star")
      star:SetHidden(false)
    end

    -- Check if newly favourited item is slotted and refresh the star indicator
    local slottedCollectibleId = QF.GetSlottedCollectibleIdByType(collectibleType)
    if slottedCollectibleId == id then
      local controlSuffix = QF.CollectibleTable[collectibleType].controlSuffix
      local QF_SlottedControl = GetControl(string.format("QF_Slotted%s", controlSuffix))
      local QF_SlottedControlStar = QF_SlottedControl:GetNamedChild("Star")
      QF_SlottedControlStar:SetHidden(false)
    end

    if QF.SavedVars.collectibleTab == "favs" then
      QF.CreateCollectibleGridByType(collectibleType)
    end
  else
    QF.ChatMessage("No collectible selected!")
  end
end

-- Remove a collectible from your favourites/saved variables
function QF.RemoveFromFavourites(FavouritesTableByType, id)
  local collectibleName = GetCollectibleName(id)
  local collectibleType = GetCollectibleCategoryType(id)

  for i = 1, #FavouritesTableByType do
    if id == FavouritesTableByType[i] then
      table.remove(FavouritesTableByType, i)
      QF.ChatMessage(string.format("|c9081ff%s|r was removed from your Favourites.", collectibleName))
    end
  end

  local controlName = string.format("QF_Fav_ID_%i", id)
  local control = WM:GetControlByName(controlName)
  local star = control:GetNamedChild("Star")
  star:SetHidden(true)

  if QF.SavedVars.collectibleTab == "favs" then
    QF.CreateCollectibleGridByType(collectibleType)
  end

  local slottedCollectibleId = QF.GetSlottedCollectibleIdByType(collectibleType)
  if slottedCollectibleId == id then
    local controlSuffix = QF.CollectibleTable[collectibleType].controlSuffix
    local QF_SlottedControl = GetControl(string.format("QF_Slotted%s", controlSuffix))
    local QF_SlottedControlStar = QF_SlottedControl:GetNamedChild("Star")
    QF_SlottedControlStar:SetHidden(true)
  end
end

function QF.AddAllCollectiblesToFavourites()
  local OwnedCollectibles = QF.SavedVars.OwnedCollectibles
  local FavouritesByType = QF.SavedVars.FavouritesByType
  for collectibleType,_ in pairs(OwnedCollectibles) do
    for _,collectibleId in ipairs(OwnedCollectibles[collectibleType]) do
      if QF.IsFavourite(collectibleId, collectibleType) == false then
        table.insert(FavouritesByType[collectibleType], collectibleId)

        local controlName = string.format("QF_Fav_ID_%i", collectibleId)
        local control = WM:GetControlByName(controlName)

        -- Check if collectible control exists and create a new one if not.
        if control == nil then
          QF.CreateCollectibleIcon(collectibleId, collectibleType)
        else
          local star = control:GetNamedChild("Star")
          star:SetHidden(false)
        end
      end
    end

    table.sort(FavouritesByType[collectibleType])
    QF.SavedVars.FavouritesByType[collectibleType] = FavouritesByType[collectibleType]

    if QF.SavedVars.collectibleTab == "favs" then
      QF.CreateCollectibleGridByType(collectibleType)
    end

    -- Check if newly favourited item is slotted and refresh the star indicator
    local slottedCollectibleId = QF.GetSlottedCollectibleIdByType(collectibleType)
    if slottedCollectibleId ~= 0 then
      local controlSuffix = QF.CollectibleTable[collectibleType].controlSuffix
      local QF_SlottedControl = GetControl(string.format("QF_Slotted%s", controlSuffix))
      local QF_SlottedControlStar = QF_SlottedControl:GetNamedChild("Star")
      QF_SlottedControlStar:SetHidden(false)
    end
  end
end

function QF.RemoveAllCollectiblesFromFavourites()
  local FavouritesByType = QF.SavedVars.FavouritesByType
  for collectibleType,_ in pairs(FavouritesByType) do
    while FavouritesByType[collectibleType][1] do
      local collectibleId = FavouritesByType[collectibleType][1]
      table.remove(FavouritesByType[collectibleType], 1)

      local controlName = string.format("QF_Fav_ID_%i", collectibleId)
      local control = WM:GetControlByName(controlName)
      local star = control:GetNamedChild("Star")
      star:SetHidden(true)
    end

    QF.SavedVars.FavouritesByType[collectibleType] = FavouritesByType[collectibleType]

    if QF.SavedVars.collectibleTab == "favs" then
      QF.CreateCollectibleGridByType(collectibleType)
    end

    local slottedCollectibleId = QF.GetSlottedCollectibleIdByType(collectibleType)
    if slottedCollectibleId ~= 0 then
      local controlSuffix = QF.CollectibleTable[collectibleType].controlSuffix
      local QF_SlottedControl = GetControl(string.format("QF_Slotted%s", controlSuffix))
      local QF_SlottedControlStar = QF_SlottedControl:GetNamedChild("Star")
      QF_SlottedControlStar:SetHidden(true)
    end
  end
end
