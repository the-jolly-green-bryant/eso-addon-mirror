local QF = _G["QF"]

local WM = WINDOW_MANAGER

local StripCounter = 0

---------------------------
-- ICONS INITIALIZATION --
---------------------------

-- Create collectible menu
local function CreateCollectibleMenu(collectibleType)
  local FavouritesByType = QF.SavedVars.FavouritesByType
  local activeCollectibleId = GetActiveCollectibleByType(collectibleType)
  local slottedCollectibleId = QF.GetSlottedCollectibleIdByType(collectibleType)

  ClearMenu()
  -- 1. Equip or unequip slotted collectible
  if slottedCollectibleId == 0 then
    AddMenuItem("Load active " .. QF.CollectibleTable[collectibleType].name, function() QF.SetCollectibleSlot(collectibleType, activeCollectibleId) end )
  elseif slottedCollectibleId == activeCollectibleId then
    AddMenuItem("Unequip", function() QF.ToggleCollectible(slottedCollectibleId) end )
  else
    AddMenuItem("Equip", function() QF.ToggleCollectible(slottedCollectibleId) end )
    -- 2. Load active collectible if slotted collectible is different from the active collectible
    AddMenuItem("Load active " .. QF.CollectibleTable[collectibleType].name, function() QF.SetCollectibleSlot(collectibleType, activeCollectibleId) end )
  end
  if slottedCollectibleId ~= 0 then
    -- 3. Link in chat
    AddMenuItem("Link in chat", function() ZO_LinkHandler_InsertLink(GetCollectibleLink(slottedCollectibleId, LINK_STYLE_BRACKETS)) end)
    -- 4. Add or remove from favourites
    if QF.IsFavourite(slottedCollectibleId, collectibleType) == true then
      AddMenuItem("Remove from Favourites", function() QF.RemoveFromFavourites(FavouritesByType[collectibleType], slottedCollectibleId) end )
    else
      AddMenuItem("|t25:25:esoui/art/tutorial/ava_rankicon_general.dds|tSave to Favourites", function() QF.AddToFavourites(FavouritesByType[collectibleType], slottedCollectibleId) end )
    end
  end
  ShowMenu()
end

-- Left click  -> Loads currently equipped collectible
-- Right click -> Shows the collectible menu
local function CollectibleButtonClicked(mouseButton, collectibleType)
  if mouseButton == MOUSE_BUTTON_INDEX_LEFT then
    local slottedCollectibleId = QF.GetSlottedCollectibleIdByType(collectibleType)
    if slottedCollectibleId ~= 0 then
      QF.ToggleCollectible(slottedCollectibleId)
    end
  elseif mouseButton == MOUSE_BUTTON_INDEX_RIGHT then
    CreateCollectibleMenu(collectibleType)
  end
end

function QF.CreateCollectibleSlot(controlName, parent, offsetX, offsetY, texture, tooltip, collectibleType)
  local control = WM:CreateControlFromVirtual(controlName, parent, "QF_CollectibleIconTemplate")
  local button = WM:GetControlByName(controlName, "Button")

  control:ClearAnchors()
  control:SetAnchor(TOPLEFT, parent, TOPLEFT, offsetX, offsetY)
  button:SetNormalTexture(texture)

  -- Different handlers depending on whether cosmetic collectibles or customized actions are selected
  if parent == QF_PanelCurrent then
    button:SetHandler("OnClicked", function(self, mouseButton) CollectibleButtonClicked(mouseButton, collectibleType) end)
  elseif parent == QF_PanelActions then
    button:SetHandler("OnClicked", function(self, mouseButton) QF.CustomizedActionButtonClicked(mouseButton, collectibleType) end)
  end
  QF.SetTopToolTip(button, tooltip)
end

local function InitCollectibleSlots()
  for collectibleType,_ in pairs(QF.CollectibleTable) do
    local controlName = "QF_Slotted" .. QF.CollectibleTable[collectibleType].controlSuffix
    local offsetX = QF.CollectibleTable[collectibleType].collectibleSlot.offsetX
    local offsetY = QF.CollectibleTable[collectibleType].collectibleSlot.offsetY
    local texture = QF.CollectibleTable[collectibleType].texture
    local tooltip = QF.CollectibleTable[collectibleType].name:gsub("^%l", string.upper) .. "(not set)"
    QF.CreateCollectibleSlot(controlName, QF_PanelCurrent, offsetX, offsetY, texture, tooltip, collectibleType)
  end
end

-------------------------------------
-- LOAD EQUIPPED COLLECTIBLE SLOTS --
-------------------------------------

-- Set the collectible by collectibleId in the collectible slot
function QF.SetCollectibleSlot(collectibleType, collectibleId)

  -- Get predefined controls for different collectible types
  local controlSuffix = QF.CollectibleTable[collectibleType].controlSuffix
  local QF_SlottedControl = GetControl(string.format("QF_Slotted%s", controlSuffix))
  local QF_SlottedControlButton = QF_SlottedControl:GetNamedChild("Button")
  local QF_SlottedControlCheck = QF_SlottedControl:GetNamedChild("Check")
  local QF_SlottedControlStar = QF_SlottedControl:GetNamedChild("Star")

  local collectibleName, texture

  -- Retreive collectible data from the collectible ID
  if collectibleId ~= 0 then
    collectibleName = GetCollectibleName(collectibleId)
    texture = GetCollectibleIcon(collectibleId)
    QF_SlottedControl:SetId(collectibleId)
    QF_SlottedControlButton:SetAlpha(1)
    QF_SlottedControlStar:SetHidden(not QF.IsFavourite(collectibleId, collectibleType))
  else
    collectibleName = QF.CollectibleTable[collectibleType].name:gsub("^%l", string.upper) .. " (not set)"
    texture = QF.CollectibleTable[collectibleType].texture
    QF_SlottedControl:SetId(0)
    QF_SlottedControlButton:SetAlpha(0.3)
    QF_SlottedControlStar:SetHidden(true)
  end

  QF_SlottedControlButton:SetNormalTexture(texture)
  QF_SlottedControlCheck:SetHidden(not IsCollectibleActive(collectibleId))

  local tooltip = collectibleName
  if collectibleType == COLLECTIBLE_CATEGORY_TYPE_PERSONALITY and collectibleId ~= 0 then
    tooltip = QF.GetPersonalityTooltip(collectibleId, collectibleName)
  end

  QF_SlottedControlButton:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, tooltip)
                                                                    self:GetParent():GetNamedChild("Highlight"):SetHidden(false) end)
  QF_SlottedControlButton:SetHandler("OnMouseExit",  function(self) ZO_Tooltips_HideTextTooltip()
                                                                    self:GetParent():GetNamedChild("Highlight"):SetHidden(true) end)
end

-- Clears any slotted collectibles from the collectible slot
local function ClearCollectibleSlot(collectibleType)

  -- Get predefined controls for different collectible types
  local controlSuffix = QF.CollectibleTable[collectibleType].controlSuffix
  local QF_SlottedControl = GetControl("QF_Slotted" .. controlSuffix)
  local QF_SlottedControlButton = QF_SlottedControl:GetNamedChild("Button")
  local QF_SlottedControlCheck = QF_SlottedControl:GetNamedChild("Check")
  local QF_SlottedControlStar = QF_SlottedControl:GetNamedChild("Star")

  local collectibleName = QF.CollectibleTable[collectibleType].name:gsub("^%l", string.upper) .. " (not set)"
  local texture = QF.CollectibleTable[collectibleType].texture -- "esoui/art/treeicons/gamepad/gp_collectionicon_costumes.dds"
  QF_SlottedControl:SetId(0)
  QF_SlottedControlButton:SetAlpha(0.3)
  QF_SlottedControlButton:SetNormalTexture(texture)
  QF_SlottedControlCheck:SetHidden(true)
  QF_SlottedControlStar:SetHidden(true)
  QF.SetTopToolTip(QF_SlottedControlButton, collectibleName)
end

-- Toggle selected collectible on/off
function QF.ToggleCollectible(collectibleId)
  if GetCurrentZoneHouseId() ~= 0 then
    local collectibleCategory = GetCollectibleCategoryType(collectibleId)
    if collectibleCategory == COLLECTIBLE_CATEGORY_TYPE_VANITY_PET then
      QF.ChatMessage("This non-combat pet cannot be activated in this zone.")
      return
    end
  end
  UseCollectible(collectibleId)
end

local function LoadAllActiveSlots()
  for collectibleType, v in pairs(QF.CollectibleTable) do
    local activeCollectibleId = GetActiveCollectibleByType(collectibleType)
    QF.SetCollectibleSlot(collectibleType, activeCollectibleId)
  end

  QF.LoadAllActiveCustomizedActionSlots()
end

local function ClearAllActiveSlots()
  for collectibleType, v in pairs(QF.CollectibleTable) do
    ClearCollectibleSlot(collectibleType)
  end

  QF.ClearAllActiveCustomizedActionSlots()

  -- Clear any previously selected profiles
  QF.ProfilesDropDown:SetSelectedItem("|c989898No profile|r")
end

--------------------------------
-- OUTFITS --
--------------------------------

local function SetCurrentOutfit()
  local currentOutfitIndex = GetEquippedOutfitIndex(0)
  local currentOutfitName

  if currentOutfitIndex ~= nil then
    currentOutfitName = GetOutfitName(0, currentOutfitIndex)
    if currentOutfitName == "" then
      currentOutfitName = string.format("Outfit %i", currentOutfitIndex)
    end
  else
    currentOutfitName = "No Outfit"
  end
  QF.OutfitsDropdown:SetSelectedItem(currentOutfitName)
end

local function UpdateOutfitsDropdown()
  QF.OutfitsDropdown:ClearItems()
  local numOutfits = GetNumUnlockedOutfits()

  local itemEntry = QF.OutfitsDropdown:CreateItemEntry("No Outfit", function() UnequipOutfit() end)
  QF.OutfitsDropdown:AddItem(itemEntry)

  for outfitIndex = 1, numOutfits do
    local outfitName = GetOutfitName(0, outfitIndex)
    if outfitName == "" then
      outfitName = string.format("Outfit %i", outfitIndex)
    end
    local itemEntry = QF.OutfitsDropdown:CreateItemEntry(outfitName, function() EquipOutfit(0, outfitIndex) end)
    QF.OutfitsDropdown:AddItem(itemEntry)
  end

  SetCurrentOutfit()
end

local function InitOutfitsDropdown()
  local profileBox = WM:CreateControlFromVirtual("QF_OutfitsDropdown", QF_Panel, "QF_DropdownTemplate")
  profileBox:ClearAnchors()
  profileBox:SetDimensions(206, 30)
  profileBox:SetAnchor(TOPLEFT, QF_SlottedSkin, BOTTOMLEFT, -8, 48)
  QF.OutfitsDropdown = ZO_ComboBox_ObjectFromContainer(profileBox)
  QF.OutfitsDropdown:SetSortsItems(false)
  UpdateOutfitsDropdown()
end

function QF.OnOutfitUpdated(event)
  SetCurrentOutfit()
end

------------------------------
-- TITLES --
------------------------------

local function SetCurrentTitle()
  currentTitleIndex = GetCurrentTitleIndex()
  currentTitleName = GetTitle(currentTitleIndex)
  if currentTitleIndex == nil then
    QF.TitlesDropdown:SetSelectedItem("No Title")
  else
    QF.TitlesDropdown:SetSelectedItem(currentTitleName)
  end
end

local function UpdateTitlesDropdown()
  QF.TitlesDropdown:ClearItems()

  local numTitles = GetNumTitles()
  local itemEntry = QF.TitlesDropdown:CreateItemEntry("No Title", function() SelectTitle(nil) end)
  QF.TitlesDropdown:AddItem(itemEntry)

  local titlesList = {}
  local data

  for i = 1, numTitles do
    data = {
      titleIndex = i,
      titleName = GetTitle(i),
    }
    table.insert(titlesList, data)
  end
  table.sort(titlesList, function(a,b) return a.titleName < b.titleName end)

  for i = 1, numTitles do
    local itemEntry = QF.TitlesDropdown:CreateItemEntry(titlesList[i].titleName, function() SelectTitle(titlesList[i].titleIndex) end)
    QF.TitlesDropdown:AddItem(itemEntry)
  end

  SetCurrentTitle()
end

local function InitTitlesDropdown()
  local profileBox = WM:CreateControlFromVirtual("QF_TitlesDropdown", QF_Panel, "QF_DropdownTemplate")
  profileBox:ClearAnchors()
  profileBox:SetDimensions(206, 30)
  profileBox:SetAnchor(TOPLEFT, QF_SlottedSkin, BOTTOMLEFT, -8, 13)
  profileBox:SetDrawTier(DT_HIGH)
  QF.TitlesDropdown = ZO_ComboBox_ObjectFromContainer(profileBox)
  QF.TitlesDropdown:SetSortsItems(false)
  UpdateTitlesDropdown()
end

function QF.OnTitleUpdated(event)
  SetCurrentTitle()
end

------------------------------
-- TOGGLE HELMET --
------------------------------

local function ToggleHelmet()
  if IsCollectibleActive(QF.Constants.COLLECTIBLE_ID_HIDE_HELMET) then
    if QF.SavedVars.lastSlottedHatId == nil or QF.SavedVars.lastSlottedHatId == 0 then
      UseCollectible(QF.Constants.COLLECTIBLE_ID_HIDE_HELMET)
    else
      UseCollectible(QF.SavedVars.lastSlottedHatId)
    end
    SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_POLYMORPH_HELM, 0)
  else
    UseCollectible(QF.Constants.COLLECTIBLE_ID_HIDE_HELMET) -- "Hide helm" collectible
    SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_POLYMORPH_HELM, 1)
  end
end

------------------------------
-- UNEQUIP WEAPONS --
------------------------------

--[[local function UnequipWeapons()

  local function Unequip(equipSlot)
    local _, slotHasItem = GetEquippedItemInfo(equipSlot)
    if slotHasItem == true then
      UnequipItem(equipSlot)
    end
    local _, slotHasItem = GetEquippedItemInfo(equipSlot)
    if slotHasItem == false then
      return
    end
    zo_callLater(function() Unequip(equipSlot) end, 50)
  end

  Unequip(EQUIP_SLOT_MAIN_HAND)
  Unequip(EQUIP_SLOT_OFF_HAND)
  Unequip(EQUIP_SLOT_BACKUP_MAIN)
  Unequip(EQUIP_SLOT_BACKUP_OFF)
end --]]

------------------------------
-- SILHOUETTE --
------------------------------

-- Displays character silhouette based on player race and gender
local function InitCharacterSilhouette()
  local race = GetUnitRace("player")
  local gender = GetUnitGender("player")
  if race == "Argonian" then
    if gender == 1 then   -- female
      QF_Silhouette:SetNormalTexture("esoui/art/characterwindow/silhouette_argonian_female.dds")
    else
      QF_Silhouette:SetNormalTexture("esoui/art/characterwindow/silhouette_argonian_male.dds")
    end
  elseif race == "Khajiit" then
    if gender == 1 then
      QF_Silhouette:SetNormalTexture("esoui/art/characterwindow/silhouette_khajiit_female.dds")
    else
      QF_Silhouette:SetNormalTexture("esoui/art/characterwindow/silhouette_khajiit_male.dds")
    end
  else
    if gender == 1 then
      QF_Silhouette:SetNormalTexture("esoui/art/characterwindow/silhouette_human_female.dds")
    else
      QF_Silhouette:SetNormalTexture("esoui/art/characterwindow/silhouette_human_male.dds")
    end
  end
end

-- Strip!
local function Strip()
  StripCounter = StripCounter + 1
  local stripTable = {
    [1] = "Wardrobe Malfunction!",
    [2] = "Indecent Exposure!",
    [3] = "Pants gone missing!",
    [4] = "Bright Moons!",
    [5] = "Now you're just doing this on purpose.",
    [6] = "Down to the bare essentials!",
    [7] = "Birthday suit shenanigans!",
    [8] = "At least put some shoes on!",
    [9] = "Unauthorized Undressing!",
    [10] = "Have you no modesty?",
    [15] = "Someone's going to have to pick up all those clothes...",
    [20] = "Seriously, stop it!",
    [30] = "Well, how about a little dance then?",
    [40] = "Perhaps you should visit the Ebony Flask.",
    [50] = "Now go kill some daedra!",
    [75] = "So this is just how you do things, eh?",
    [100] = "You have GOT to be one of those Unattired Dancing people...",
  }

  local function Unequip(i)
    local _, slotHasItem = GetEquippedItemInfo(QF.EquipSlots[i])
    if slotHasItem == true then
      UnequipItem(QF.EquipSlots[i])
    end
    local _, slotHasItem = GetEquippedItemInfo(QF.EquipSlots[i])
    if slotHasItem == false then
      i = i + 1
      if i > 12 then
        return
      end
    end
    zo_callLater(function() Unequip(i) end, 50)
  end
  local i = 1
  Unequip(i)

  local slottedCostumeId = GetActiveCollectibleByType(4)
  if slottedCostumeId ~= 0 then
    UseCollectible(slottedCostumeId)
  end

  local slottedHatId = GetActiveCollectibleByType(10)
  if slottedHatId ~= 0 then
    UseCollectible(slottedHatId)
  end

  UnequipOutfit()
  if stripTable[StripCounter] ~= nil then
    d(stripTable[StripCounter])
  end
  return StripCounter
end

--------------------------------
-- FINAL INITIALIZATION --
--------------------------------

local function InitFashionPanelHandlers()
  -- QUICK FASHION PANEL
  QF_PanelToggleFavPanel:SetHandler("OnClicked", function(self) QF.ToggleFavPanel() end)
  QF_PanelCloseButton:SetHandler("OnClicked", function(self) QF.ToggleQFPanel() end)
  QF_PanelLoadAll:SetHandler("OnClicked", function(self) LoadAllActiveSlots()
                                                         SetCurrentOutfit()
                                                         SetCurrentTitle() end)
  QF_PanelClearAll:SetHandler("OnClicked", function(self) ClearAllActiveSlots() end)
  QF_PanelToggleHelm:SetHandler("OnClicked", function(self) ToggleHelmet() end)
  -- QF_PanelUnequipWeapons:SetHandler("OnClicked", function(self) UnequipWeapons() end)
  QF_Silhouette:SetHandler("OnClicked", function(self) Strip() end)
end

function QF.InitFashionPanel()
  InitCollectibleSlots()
  InitCharacterSilhouette()
  InitOutfitsDropdown()
  InitTitlesDropdown()

  InitFashionPanelHandlers()

  QF.InitCustomizedActionPanel()

  LoadAllActiveSlots()
end
