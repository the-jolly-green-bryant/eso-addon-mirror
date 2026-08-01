local QF = _G["QF"]

------------------------------------------------
-- ALL OWNED CUSTOMIZED ACTIONS --
------------------------------------------------

-- Get a list of all owned customized actions
function QF.GetOwnedCustomizedActions()
  local collectibleList = {}
  local ownedActionsTable = {}

  local function IsNotSelectedCategory(categoryData)
    return not categoryData:IsOutfitStylesCategory() and not categoryData:IsHousingCategory()
  end

  local function IsCollectibleType(collectibleData)
    return collectibleData:IsCategoryType(COLLECTIBLE_CATEGORY_TYPE_PLAYER_FX_OVERRIDE)
  end

  --Iterate over the main categories and do not use outfits or houses
  for idx, categoryData in ZO_COLLECTIBLE_DATA_MANAGER:CategoryIterator({IsNotSelectedCategory}) do
    --Iterate over the sub-categories of the current main category and do not use outfits or houses
    for _, subCategoryData in categoryData:SubcategoryIterator({IsNotSelectedCategory}) do
      --Iterate over the sub-categorie's collectibles and only check for mounts collectible type
      for _, subCatCollectibleData in subCategoryData:CollectibleIterator({IsCollectibleType}) do
        --Check if the collectible is owned/unlocked
        if subCatCollectibleData:IsUnlocked() then
          if not subCatCollectibleData:IsBlocked() then
            collectibleList[subCatCollectibleData:GetId()] = subCatCollectibleData:GetFormattedName()
          end
        end
      end
    end
  end

  for id, name in pairs(collectibleList) do
    table.insert(ownedActionsTable, id)
  end
  table.sort(ownedActionsTable)
  -- d(ownedActionsTable)
  QF.SavedVars.OwnedCustomizedActions = ownedActionsTable
end

-------------------------------------------------
-- INIT ICONS IN FASHION PANEL --
-------------------------------------------------

local function CreateCustomizedActionMenu(fxType)
  local activeCustomizedActions = QF.GetActiveCustomizedActions()
  local activeCollectibleId = activeCustomizedActions[fxType]
  local slottedCollectibleId = QF.GetSlottedCustomizedActionIdByType(fxType)

  ClearMenu()
  -- 1. Equip or unequip slotted collectible
  if slottedCollectibleId == 0 then
    AddMenuItem("Load active customized action", function() QF.SetCustomizedActionSlot(fxType, activeCollectibleId) end )
  elseif slottedCollectibleId == activeCollectibleId then
    AddMenuItem("Unequip", function() QF.ToggleCollectible(slottedCollectibleId) end )
  else
    AddMenuItem("Equip", function() QF.ToggleCollectible(slottedCollectibleId) end )
    -- 2. Load active collectible if slotted collectible is different from the active collectible
    AddMenuItem("Load active customized action", function() QF.SetCustomizedActionSlot(fxType, activeCollectibleId) end )
  end
  if slottedCollectibleId ~= 0 then
    -- 3. Link in chat
    AddMenuItem("Link in chat", function() ZO_LinkHandler_InsertLink(GetCollectibleLink(slottedCollectibleId, LINK_STYLE_BRACKETS)) end)
    -- 4. Add or remove from favourites
  end
  ShowMenu()
end

function QF.CustomizedActionButtonClicked(mouseButton, fxType)
  if mouseButton == MOUSE_BUTTON_INDEX_LEFT then
    local slottedCollectibleId = QF.GetSlottedCustomizedActionIdByType(fxType)
    if slottedCollectibleId ~= 0 then
      QF.ToggleCollectible(slottedCollectibleId)
    end
  elseif mouseButton == MOUSE_BUTTON_INDEX_RIGHT then
    CreateCustomizedActionMenu(fxType)
  end
end

local function InitCustomizedActionSlots()
  for fxType,_ in pairs(QF.CustomizedActionsTable) do
    local controlName = "QF_Slotted" .. QF.CustomizedActionsTable[fxType].controlSuffix
    local offsetX = QF.CustomizedActionsTable[fxType].collectibleSlot.offsetX
    local offsetY = QF.CustomizedActionsTable[fxType].collectibleSlot.offsetY
    local texture = QF.CustomizedActionsTable[fxType].texture
    -- local tooltip = QF.CustomizedActionsTable[fxType].name:gsub("^%l", string.upper) .. " (not set)"
    QF.CreateCollectibleSlot(controlName, QF_PanelActions, offsetX, offsetY, texture, tooltip, fxType)
  end
end

------------------------------------------------
-- LOAD ALL ACTIVE CUSTOMIZED ACTIONS --
------------------------------------------------

function QF.GetActiveCustomizedActions()
  local ownedActionsTable = QF.SavedVars.OwnedCustomizedActions
  local activeCustomizedActions = {
    [0] = 0,
    [1] = 0,
    [2] = 0,
    [3] = 0,
    [5] = 0,
  }

  for _,collectibleId in ipairs(ownedActionsTable) do
    if IsCollectibleActive(collectibleId) then
      local fxType = GetCollectiblePlayerFxWhileHarvestingType(collectibleId)
      if fxType == nil then
        fxType = 0
      end
      activeCustomizedActions[fxType] = collectibleId
    end
  end
  return activeCustomizedActions
end

--Get active customized actions
function QF.LoadAllActiveCustomizedActionSlots()
  local activeCustomizedActions = QF.GetActiveCustomizedActions()
  for fxType, collectibleId in pairs(activeCustomizedActions) do
    QF.SetCustomizedActionSlot(fxType, collectibleId)
  end
end

function QF.ClearAllActiveCustomizedActionSlots()
  local emptyCustomizedActions = {
    [0] = 0,
    [1] = 0,
    [2] = 0,
    [3] = 0,
    [5] = 0,
  }

  for fxType, collectibleId in pairs(emptyCustomizedActions) do
    QF.SetCustomizedActionSlot(fxType, collectibleId)
  end
end

-- Set customized action by collectibleId in the customized action slot in Fashion panel
function QF.SetCustomizedActionSlot(fxType, collectibleId)
  -- Get predefined controls for different collectible types
  local controlSuffix = QF.CustomizedActionsTable[fxType].controlSuffix
  local QF_SlottedControl = GetControl(string.format("QF_Slotted%s", controlSuffix))
  local QF_SlottedControlButton = QF_SlottedControl:GetNamedChild("Button")
  local QF_SlottedControlCheck = QF_SlottedControl:GetNamedChild("Check")
  local QF_SlottedControlStar = QF_SlottedControl:GetNamedChild("Star")

  -- Currently not adding functionality to favourite customized actions, so stars hidden by default
  QF_SlottedControlStar:SetHidden(true)

  local collectibleName, texture

  -- Retreive collectible data from the collectible ID
  if collectibleId ~= 0 then
    collectibleName = GetCollectibleName(collectibleId)
    texture = GetCollectibleIcon(collectibleId)
    QF_SlottedControl:SetId(collectibleId)
    QF_SlottedControlButton:SetAlpha(1)
  else
    collectibleName = QF.CustomizedActionsTable[fxType].header .. " (not set)"
    texture = QF.CustomizedActionsTable[fxType].texture
    QF_SlottedControl:SetId(0)
    QF_SlottedControlButton:SetAlpha(0.3)
  end

  QF_SlottedControlButton:SetNormalTexture(texture)
  QF_SlottedControlCheck:SetHidden(not IsCollectibleActive(collectibleId))

  local tooltip = collectibleName

  QF_SlottedControlButton:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, tooltip)
                                                                    self:GetParent():GetNamedChild("Highlight"):SetHidden(false) end)
  QF_SlottedControlButton:SetHandler("OnMouseExit",  function(self) ZO_Tooltips_HideTextTooltip()
                                                                    self:GetParent():GetNamedChild("Highlight"):SetHidden(true) end)
end

-----------------------------------------------
-- ON COLLECTIBLE/CUSTOMIZED ACTION UPDATED --
------------------------------------------------

-- Redirected from OnCollectibleUpdated EVENT function
function QF.OnCustomizedActionUpdated(collectibleId)
  local fxType = GetCollectiblePlayerFxWhileHarvestingType(collectibleId)
  if fxType == nil then
    fxType = 0
  end

  local activeCustomizedActions = QF.GetActiveCustomizedActions()
  local activeCollectibleId = activeCustomizedActions[fxType]
  QF.SetCustomizedActionSlot(fxType, activeCollectibleId)
end

------------------------------------------------
-- FINAL INITIALIZATION --
------------------------------------------------

-- This function is inited under QF.InitFashionPanel() 
function QF.InitCustomizedActionPanel()
  InitCustomizedActionSlots()
  QF.GetOwnedCustomizedActions()
end
