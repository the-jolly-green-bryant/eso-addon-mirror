local QF = _G["QF"]

local WM = WINDOW_MANAGER

local allCollectiblesInitialized = false

-----------------------------------------
-- INITIALIZATION --
-----------------------------------------

function QF.InitAllCollectibleIcons()
  local CollectiblesByType = QF.SavedVars.OwnedCollectibles
  for collectibleType,_ in pairs(CollectiblesByType) do
    local size = #CollectiblesByType[collectibleType]
    for i = 1, size do
      local collectibleId = CollectiblesByType[collectibleType][i]
      QF.CreateCollectibleIcon(collectibleId, collectibleType)
    end
  end
  allCollectiblesInitialized = true
  return allCollectiblesInitialized
end

local function GetOwnedCollectiblesByType(collectibleType)
  local collectibleList = {}
  local ownedCollectiblesTable = {}

  local function IsNotSelectedCategory(categoryData)
    return not categoryData:IsOutfitStylesCategory() and not categoryData:IsHousingCategory()
  end

  local function IsCollectibleType(collectibleData)
    return collectibleData:IsCategoryType(collectibleType)
  end

  --Iterate over the main categories and do not use outfits or houses
  for idx, categoryData in ZO_COLLECTIBLE_DATA_MANAGER:CategoryIterator({IsNotSelectedCategory}) do
    --Iterate over the sub-categories of the current main category and do not use outfits or houses
    for _, subCategoryData in categoryData:SubcategoryIterator({IsNotSelectedCategory}) do
      --Iterate over the sub-categorie's collectibles and only check for mounts collectible type
      for _, subCatCollectibleData in subCategoryData:CollectibleIterator({IsCollectibleType}) do
        --Check if the mount is owned/unlocked
        if subCatCollectibleData:IsUnlocked() then
          if collectibleType == COLLECTIBLE_CATEGORY_TYPE_VANITY_PET then
            collectibleList[subCatCollectibleData:GetId()] = subCatCollectibleData:GetFormattedName()
          elseif not subCatCollectibleData:IsBlocked() then
            collectibleList[subCatCollectibleData:GetId()] = subCatCollectibleData:GetFormattedName()
          end
        end
      end
    end
  end

  for id, name in pairs(collectibleList) do
    table.insert(ownedCollectiblesTable, id)
  end
  table.sort(ownedCollectiblesTable)
  QF.SavedVars.OwnedCollectibles[collectibleType] = ownedCollectiblesTable
end

local function OnInitAllIconsButtonClicked()
  local timeBefore = GetGameTimeMilliseconds()
  QF.InitAllCollectibleIcons()
  local timeAfter = GetGameTimeMilliseconds()
  local timeForIconInit = FormatTimeMilliseconds(timeAfter - timeBefore, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_MILLISECONDS, TIME_FORMAT_DIRECTION_NONE)
  QF.ToggleAllCollectibles("all")
  QF.ChatMessage("All collectibles loaded. Time taken: |cFFFFFF" .. timeForIconInit)
end

function QF.InitAllOwnedCollectibles()
  for collectibleType,_ in pairs(QF.CollectibleTable) do
    GetOwnedCollectiblesByType(collectibleType)
  end

  QF_InitAllIcons:SetHandler("OnClicked", function(self) OnInitAllIconsButtonClicked() end)
end

---------------------------------------------
-- TOGGLE BETWEEN ALL, FAVS, AND RECENT --
---------------------------------------------

function QF.ToggleAllCollectibles(state)
  QF.SavedVars.collectibleTab = state
  if state == "all" then
    Fav_PanelShowAll:SetState(BSTATE_PRESSED, false)
    Fav_PanelShowFavs:SetState(BSTATE_NORMAL, false)
    Fav_PanelShowRecent:SetState(BSTATE_NORMAL, false)
  elseif state == "favs" then
    Fav_PanelShowAll:SetState(BSTATE_NORMAL, false)
    Fav_PanelShowFavs:SetState(BSTATE_PRESSED, false)
    Fav_PanelShowRecent:SetState(BSTATE_NORMAL, false)
  elseif state == "recent" then
    Fav_PanelShowAll:SetState(BSTATE_NORMAL, false)
    Fav_PanelShowFavs:SetState(BSTATE_NORMAL, false)
    Fav_PanelShowRecent:SetState(BSTATE_PRESSED, false)
  end

  if state == "all" and QF.SavedVars.initAllCollectibleIcons == false and allCollectiblesInitialized == false then
    Fav_PanelEmpty:SetHidden(false)
    Fav_PanelContainer:SetHidden(true)
  else
    Fav_PanelEmpty:SetHidden(true)
    Fav_PanelContainer:SetHidden(false)
    QF.InitCollectibleCategoryItems()
    QF.FilterByIcons()
  end
end
