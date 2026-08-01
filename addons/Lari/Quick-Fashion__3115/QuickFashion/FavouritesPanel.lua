local QF = _G["QF"]

local WM = WINDOW_MANAGER

-------------------------------
-- HELPER FUNCTIONS --
-------------------------------

-- Set opacity of each filter icon
local function GetFilterAlpha(collectibleType)
  local alpha
  if QF.SavedVars.FilterStates[collectibleType] == true then
    alpha = 1
  else
    alpha = 0.4
  end
  return alpha
end

-----------------------------------------------
-- INITIALIZATION --
-----------------------------------------------

-- Create all containers for collectible categories
local function InitCollectibleCategoryContainers()
  -- Creates a parent container that functions as the scroll box.
  local boxControl = WM:CreateControl("Fav_PanelContainerBox", Fav_PanelContainerScrollChild)
  boxControl:SetResizeToFitDescendents(true)
  boxControl:SetDimensionConstraints(200, 100, 500, 0)
  boxControl:SetAnchor(TOPLEFT, Fav_PanelList, TOPLEFT, 0, 0)

  local parentControl = WM:GetControlByName("Fav_PanelContainerBox")

  -- Empty control provides the first anchor point.
  -- All subsequent controls are anchored to the control above it to allow for variable heights.
  local emptyControl = WM:CreateControl("Fav_PanelContainer_Empty", Fav_PanelContainerBox)
  emptyControl:SetAnchor(TOPLEFT, Fav_PanelContainerBox, TOPLEFT, 0, -5)

  -- Create individual category controls
  for _,collectibleType in ipairs(QF.Defaults.categoryLoadOrder) do
    -- Get bottom-most control to serve as an anchor
    local relativeControl = parentControl:GetChild(parentControl:GetNumChildren())

    local controlName = string.format("QF_Favs_%s", QF.CollectibleTable[collectibleType].controlSuffix)
    local control = WM:CreateControlFromVirtual(controlName, Fav_PanelContainerBox, "QF_FavContainerTemplate")
    local title = WM:GetControlByName(controlName, "Title")
    local bullet = WM:GetControlByName(controlName, "Bullet")
    title:SetText(QF.CollectibleTable[collectibleType].header)
    bullet:SetTexture(QF.CollectibleTable[collectibleType].bulletTexture)

    control:ClearAnchors()
    control:SetAnchor(TOPLEFT, relativeControl, BOTTOMLEFT, 0, 10)
  end
end

-- Initially creates the icons for all Favourites from SVs
local function InitFavIcons()
  local FavouritesByType = QF.SavedVars.FavouritesByType
  for collectibleType,_ in pairs(FavouritesByType) do
    if FavouritesByType[collectibleType] ~= nil then
      local size = #FavouritesByType[collectibleType]
      for i = 1, size do
        local collectibleId = FavouritesByType[collectibleType][i]
        QF.CreateCollectibleIcon(collectibleId, collectibleType)
      end
    end
  end
end

-- Creates the favs list for a given category
function QF.InitCollectibleCategoryItems()
  for collectibleType,_ in pairs(QF.CollectibleTable) do
    QF.CreateCollectibleGridByType(collectibleType)
  end
end

-------------------------------
-- FILTERS --
-------------------------------

-- Function to handle filtering multiple collectible types at the same time
local function ToggleFilterIcons(collectibleType)
  local FilterStates = QF.SavedVars.FilterStates
  -- Filter/display ALL
  if collectibleType == 0 then
    for type, state in pairs(FilterStates) do
      -- Disable all other filter settings
      FilterStates[type] = false
    end
    -- Set "ALL" filter to true
    FilterStates[0] = true
  else
    -- Toggle filter for a specific collectible type
    FilterStates[collectibleType] = not FilterStates[collectibleType]
    -- If the filter is toggled off, check if any other collectible filter is active.
    for type, state in pairs(FilterStates) do
      -- If any collectible filter is active, then do nothing.
      if FilterStates[type] == true then
        FilterStates[0] = false
        QF.SavedVars.FilterStates = FilterStates
        return
      end
    end
    -- If no collectible filters are active, default to ALL collectibles shown.
    FilterStates[0] = true
    QF.SavedVars.FilterStates = FilterStates
  end
end

-- Initializes ALL filter icons
local function InitFilterIcons()
  local parentControl = WM:GetControlByName("QF_Filter_Icons")
  -- CREATE FILTER ICON CONTROLS
  for _,collectibleType in ipairs(QF.Defaults.categoryLoadOrder) do
    local controlName = string.format("QF_Filter_%s", QF.CollectibleTable[collectibleType].controlSuffix)
    local control = WM:CreateControlFromVirtual(controlName, parentControl, "QF_FilterIconTemplate")

    local offsetX = QF.CollectibleTable[collectibleType].filterIcon.offsetX
    local offsetY = QF.CollectibleTable[collectibleType].filterIcon.offsetY
    local tooltip = QF.CollectibleTable[collectibleType].name:gsub("^%l", string.upper)

    control:SetNormalTexture(QF.CollectibleTable[collectibleType].texture)
    control:SetAlpha(GetFilterAlpha(collectibleType))

    control:ClearAnchors()
    control:SetAnchor(TOPLEFT, parentControl, TOPLEFT, offsetX, offsetY)

    control:SetHandler("OnMouseEnter", function(self) self:SetHeight(28)
                                                      self:SetWidth(28)
                                                      self:SetAlpha(1)
                                                      ZO_Tooltips_ShowTextTooltip(self, TOP, tooltip) end)
    control:SetHandler("OnMouseExit", function(self) self:SetHeight(25)
                                                     self:SetWidth(25)
                                                     self:SetAlpha(GetFilterAlpha(collectibleType))
                                                     ZO_Tooltips_HideTextTooltip() end)
    control:SetHandler("OnClicked", function(self) ToggleFilterIcons(collectibleType)
                                                   QF.FilterByIcons() end)
  end

  -- "DISPLAY ALL" FILTER SETTINGS
  local filterAllControl = WM:GetControlByName("QF_Filter_All")
  filterAllControl:SetAlpha(GetFilterAlpha(0))

  filterAllControl:SetHandler("OnMouseEnter", function(self) self:SetHeight(38)
                                                             self:SetWidth(38)
                                                             self:SetAlpha(1)
                                                             ZO_Tooltips_ShowTextTooltip(self, TOP, "All") end)
  filterAllControl:SetHandler("OnMouseExit", function(self) self:SetHeight(35)
                                                            self:SetWidth(35)
                                                            self:SetAlpha(GetFilterAlpha(0))
                                                            ZO_Tooltips_HideTextTooltip() end)
  filterAllControl:SetHandler("OnClicked", function(self) ToggleFilterIcons(0)
                                                          QF.FilterByIcons() end)
end

---------------------------------
-- COLLECTIBLE ICONS --
---------------------------------

-- Create a menu for favourited collectibles
local function CreateCollectibleIconMenu(collectibleId)
  local FavouritesByType = QF.SavedVars.FavouritesByType
  local collectibleType = GetCollectibleCategoryType(collectibleId)
  local activeCollectibleId = GetActiveCollectibleByType(collectibleType)
  ClearMenu()

  -- 1. Equip/unequip
  if collectibleId == activeCollectibleId then
    AddMenuItem("Unequip", function() QF.ToggleCollectible(collectibleId) end )
  else
    AddMenuItem("Equip", function() QF.ToggleCollectible(collectibleId) end )
  end

  -- 2. Link in chat
  AddMenuItem("Link in chat", function() ZO_LinkHandler_InsertLink(GetCollectibleLink(collectibleId, LINK_STYLE_BRACKETS)) end)

  -- 3. Add or remove from favourites
  if QF.IsFavourite(collectibleId, collectibleType) == true then
    AddMenuItem("Remove from Favourites", function() QF.RemoveFromFavourites(FavouritesByType[collectibleType], collectibleId) end )
  else
    AddMenuItem("|t25:25:esoui/art/tutorial/ava_rankicon_general.dds|tSave to Favourites", function() QF.AddToFavourites(FavouritesByType[collectibleType], collectibleId) end )
  end
  ShowMenu()
end

-- Toggles collectibles when fav icon is clicked
local function CollectibleIconClicked(mouseButton, collectibleId)
  if mouseButton == MOUSE_BUTTON_INDEX_LEFT then
    QF.ToggleCollectible(collectibleId)
  elseif mouseButton == MOUSE_BUTTON_INDEX_RIGHT then
    CreateCollectibleIconMenu(collectibleId)
  end
end

-- Creates single collectible icons
function QF.CreateCollectibleIcon(collectibleId, collectibleType)
  local controlName = string.format("QF_Fav_ID_%i", collectibleId)
  if WM:GetControlByName(controlName) ~= nil then return end

  local collectibleName = GetCollectibleName(collectibleId)
  local collectibleIcon = GetCollectibleIcon(collectibleId)
  -- local collectibleType = GetCollectibleCategoryType(collectibleId)

  local parentControlName = string.format("QF_Favs_%sGrid", QF.CollectibleTable[collectibleType].controlSuffix)
  local parentControl = WM:GetControlByName(parentControlName)

  local control = WM:CreateControlFromVirtual(controlName, parentControl, "QF_CollectibleIconTemplate")

  local button = WM:GetControlByName(controlName, "Button")
  local check = WM:GetControlByName(controlName, "Check")
  local star = WM:GetControlByName(controlName, "Star")

  button:SetNormalTexture(collectibleIcon)
  check:SetHidden(not IsCollectibleActive(collectibleId))
  star:SetHidden(not QF.IsFavourite(collectibleId, collectibleType))

  local tooltip = collectibleName
  if collectibleType == COLLECTIBLE_CATEGORY_TYPE_PERSONALITY and collectibleId ~= 0 then
    tooltip = QF.GetPersonalityTooltip(collectibleId, collectibleName)
  end

  button:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, tooltip)
                                                   self:GetParent():GetNamedChild("Highlight"):SetHidden(false) end)
  button:SetHandler("OnMouseExit",  function(self) ZO_Tooltips_HideTextTooltip()
                                                   self:GetParent():GetNamedChild("Highlight"):SetHidden(true) end)
  button:SetHandler("OnClicked", function(self, mouseButton) CollectibleIconClicked(mouseButton, collectibleId) end)
end

----------------------------------
-- COLLECTIBLES GRID --
----------------------------------

-- Create an alphabetically sorted table of collectibles from the given category filter
local function BuildCollectibleData(collectibleType)
  local CollectibleData = {}

  local CollectibleList
  if QF.SavedVars.collectibleTab == "all" then
    CollectibleList = QF.SavedVars.OwnedCollectibles
  elseif QF.SavedVars.collectibleTab == "favs" then
    CollectibleList = QF.SavedVars.FavouritesByType
  elseif QF.SavedVars.collectibleTab == "recent" then
    CollectibleList = QF.SavedVars.RecentCollectibles
  end
  if CollectibleList[collectibleType] ~= nil then
    local size = #CollectibleList[collectibleType]

    for i = 1, size do
      local data = {
        collectibleId   = CollectibleList[collectibleType][i],
        collectibleName = GetCollectibleName(CollectibleList[collectibleType][i]),
      }
      table.insert(CollectibleData, data)
    end
  end

  -- Sort the table by collectible name
  if QF.SavedVars.collectibleTab ~= "recent" then
    table.sort(CollectibleData, function(a,b) return a.collectibleName < b.collectibleName end)
  end
  return CollectibleData
end

-- Hides all favourite controls of a given type
-- Used to redraw grids upon adding/removing favs, or resizing
local function HideCollectiblesByType(collectibleType)
  local parentControlName = string.format("QF_Favs_%sGrid", QF.CollectibleTable[collectibleType].controlSuffix)
  local parentControl = WM:GetControlByName(parentControlName)

  for i = 1, parentControl:GetNumChildren() do
    parentControl:GetChild(i):SetHidden(true)
    parentControl:GetChild(i):ClearAnchors()
  end
end

-- Create a grid from the given collectibles
function QF.CreateCollectibleGridByType(collectibleType)
  HideCollectiblesByType(collectibleType)

  local CollectibleData = BuildCollectibleData(collectibleType)

  local parentControlName = string.format("QF_Favs_%sGrid", QF.CollectibleTable[collectibleType].controlSuffix)
  local parentControl = WM:GetControlByName(parentControlName)
  local emptyControlName = string.format("QF_Favs_%sEmpty", QF.CollectibleTable[collectibleType].controlSuffix)
  local emptyControl = WM:GetControlByName(emptyControlName)

  local width = Fav_PanelContainer:GetWidth()
  local numColumns = math.floor(width/70)

  if CollectibleData ~= nil then
    local size = #CollectibleData

    if size > 0 then
      local j = 0

      for i = 1, size do
        local collectibleId = CollectibleData[i].collectibleId

        local controlName = string.format("QF_Fav_ID_%i", collectibleId)
        local control = WM:GetControlByName(controlName)

        if control ~= nil then
          control:SetHidden(false)
          control:SetAnchor(TOPLEFT, parentControl, TOPLEFT, 10 + ((j % numColumns) * 70), 10 + (math.floor(j / numColumns)) * 70) -- creates grid

          j = j + 1
        end
      end
      emptyControl:SetHidden(true)
    else
      emptyControl:SetHidden(false)
    end
  end
end

-- Redraw favourites grids upon resizing
function QF_Favs_On_Resize_Stop()
  QF.SavedVars.FavPanelHeight = Fav_Panel:GetHeight()
  QF.SavedVars.FavPanelWidth = Fav_Panel:GetWidth()

  for collectibleType,_ in pairs(QF.CollectibleTable) do
    QF.CreateCollectibleGridByType(collectibleType)
  end
end

-- Hides all favourites of a given category
-- Used in filtering collectibles by type
local function HideCollectibleCategory(collectibleType)
  local controlName = string.format("QF_Favs_%s", QF.CollectibleTable[collectibleType].controlSuffix)
  local control = WM:GetControlByName(controlName)
  control:SetParent(Fav_Panel)
  control:ClearAnchors()
  control:SetHidden(true)
end

-- Show all favourites of a given category
-- Used in filtering collectibles by type
local function ShowCollectibleCategory(collectibleType)
  local controlName = string.format("QF_Favs_%s", QF.CollectibleTable[collectibleType].controlSuffix)
  local control = WM:GetControlByName(controlName)

  local parentControl = WM:GetControlByName("Fav_PanelContainerBox")
  local relativeControl = parentControl:GetChild(parentControl:GetNumChildren())

  control:SetParent(parentControl)
  control:SetHidden(false)
  control:SetAnchor(TOPLEFT, relativeControl, BOTTOMLEFT, 0, 10)
end

---------------------------------------------
-- FILTER ICONS BY COLLECTIBLE TYPE --
---------------------------------------------

-- Update filter icon alpha depending on selected filters
local function UpdateFiltersAlpha()
  QF_Filter_All:SetAlpha(GetFilterAlpha(0))
  for collectibleType,_ in pairs(QF.CollectibleTable) do
    local controlName = string.format("QF_Filter_%s", QF.CollectibleTable[collectibleType].controlSuffix)
    local control = WM:GetControlByName(controlName)
    control:SetAlpha(GetFilterAlpha(collectibleType))
  end
end

-- Filters collectible categories depending on the icons selected
function QF.FilterByIcons()
  local FilterStates = QF.SavedVars.FilterStates

  for collectibleType,_ in pairs(QF.CollectibleTable) do
    HideCollectibleCategory(collectibleType)
  end

  if FilterStates[0] == true then
    for _,type in ipairs(QF.Defaults.categoryLoadOrder) do
      ShowCollectibleCategory(type)
    end
  else
    for _,type in ipairs(QF.Defaults.categoryLoadOrder) do
      if FilterStates[type] == true then
        ShowCollectibleCategory(type)
      end
    end
  end
  UpdateFiltersAlpha()
end

---------------------------
-- FINAL INIT --
---------------------------

local function InitFavouritesPanelHandlers()
  -- QUICK FAVOURITES PANEL
  Fav_PanelToggleQFPanel:SetHandler("OnClicked", function(self) QF.ToggleQFPanel() end)
  Fav_PanelCloseButton:SetHandler("OnClicked", function(self) QF.ToggleFavPanel() end)

  Fav_PanelShowAll:SetHandler("OnClicked", function(self) QF.ToggleAllCollectibles("all") end)
  Fav_PanelShowFavs:SetHandler("OnClicked", function(self) QF.ToggleAllCollectibles("favs") end)
  Fav_PanelShowRecent:SetHandler("OnClicked", function(self) QF.ToggleAllCollectibles("recent") end)
end

-- FAVOURITES --
function QF.InitFavourites()
  InitCollectibleCategoryContainers()
  QF.InitAllOwnedCollectibles()

  QF.Temp.timeBeforeIconInit = GetGameTimeMilliseconds()
  if QF.SavedVars.initAllCollectibleIcons == true then
    QF.InitAllCollectibleIcons()
  else
    InitFavIcons()
    QF.InitRecentlyEquippedIcons()
  end
  QF.Temp.timeAfterIconInit = GetGameTimeMilliseconds()
  QF.Temp.timeForIconInit =  FormatTimeMilliseconds(QF.Temp.timeAfterIconInit - QF.Temp.timeBeforeIconInit, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_MILLISECONDS, TIME_FORMAT_DIRECTION_NONE)

  InitFilterIcons()
  QF.ToggleAllCollectibles(QF.SavedVars.collectibleTab)

  InitFavouritesPanelHandlers()
end

---------------------------
-- END --
---------------------------
