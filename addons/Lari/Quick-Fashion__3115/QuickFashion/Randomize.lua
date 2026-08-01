local QF = _G["QF"]

local WM = WINDOW_MANAGER

---------------------------
-- RANDOMIZE FUNCTION --
---------------------------

function QF.Randomize()
  local randomizeTable = QF.RandomizeTableDropdown:GetSelectedItem()
  local CollectibleList = QF.SavedVars.OwnedCollectibles
  if randomizeTable == "Favourites" then
    CollectibleList = QF.SavedVars.FavouritesByType
  end

  -- Randomize each collectible by type
  for collectibleType,_ in pairs(QF.CollectibleTable) do
    if QF.SavedVars.RandomizeSetting[tostring(collectibleType)] == true then
      local list = CollectibleList[collectibleType]

      local function GetRandomCollectibleByType(list)
        if list ~= nil and #list > 0 then
          local index = math.random(#list)
          local collectibleId = list[index]
          if IsCollectibleBlocked(collectibleId) then
            -- Prevent game from hanging by trying to equip pets in houses
            if collectibleType == 3 and GetCurrentZoneHouseId ~= 0 then
              return
            end
            table.remove(list, index)
            GetRandomCollectibleByType(list)
          elseif collectibleId == GetActiveCollectibleByType(collectibleType) then
            if #list > 1 then
              GetRandomCollectibleByType(list)
            end
          else
            UseCollectible(collectibleId)
            return
          end
        end
      end

      GetRandomCollectibleByType(list)
    end
  end

  -- Randomize title
  if QF.SavedVars.RandomizeSetting["Title"] == true then
    local titleIndex = math.random(GetNumTitles())
    SelectTitle(titleIndex)
  end

  -- Randomize outfit
  if QF.SavedVars.RandomizeSetting["Outfit"] == true then
    local outfitIndex = math.random(GetNumUnlockedOutfits())
    EquipOutfit(0, outfitIndex)
  end
end

function QF.OnRandomizeSettingClicked(control, checked)
  local controlName = control:GetParent():GetName()
  local type = string.sub(controlName, 14)
  QF.SavedVars.RandomizeSetting[type] = checked
end

local function OnRandomizeButtonClicked(mouseButton)
  if mouseButton == MOUSE_BUTTON_INDEX_LEFT then
    QF.Randomize()
  elseif mouseButton == MOUSE_BUTTON_INDEX_RIGHT then
    QF_RandomizeSettings:ToggleHidden()
  end
end

---------------------------
-- INITIALIZATION --
---------------------------

-- Creates collectible type controls
local function CreateRandomizeOption(collectibleType, offsetX, offsetY)
  -- local controlName = string.format("QF_Randomize_%s", QF.CollectibleTable[collectibleType].controlSuffix)
  local controlName = string.format("QF_Randomize_%i", collectibleType)
  local control = WM:CreateControlFromVirtual(controlName, QF_RandomizeSettings, "QF_CheckboxTemplate")

  local label = WM:GetControlByName(controlName, "Label")
  label:SetText(QF.CollectibleTable[collectibleType].name:gsub("^%l", string.upper))

  local checkbox = WM:GetControlByName(controlName, "Checkbox")

  control:ClearAnchors()
  control:SetAnchor(TOPLEFT, QF_RandomizeSettingsContainer, TOPLEFT, offsetX, offsetY)
end

-- Creates Title and Outfit controls
local function CreateRandomizeOptionByName(name, offsetX, offsetY)
  local controlName = string.format("QF_Randomize_%s", name)
  local control = WM:CreateControlFromVirtual(controlName, QF_RandomizeSettings, "QF_CheckboxTemplate")

  local label = WM:GetControlByName(controlName, "Label")
  label:SetText(name)

  local checkbox = WM:GetControlByName(controlName, "Checkbox")

  control:ClearAnchors()
  control:SetAnchor(TOPLEFT, QF_RandomizeSettingsContainer, TOPLEFT, offsetX, offsetY)
end

local function InitRandomizeTableDropdown()
  local profileBox = WM:CreateControlFromVirtual("QF_RandomizeSettingsDropdown", QF_RandomizeSettings, "QF_DropdownTemplate")
  profileBox:ClearAnchors()
  profileBox:SetDimensions(170, 30)
  profileBox:SetAnchor(LEFT, QF_RandomizeSettingsDropdownLabel, RIGHT, 8, 0)
  QF.RandomizeTableDropdown = ZO_ComboBox_ObjectFromContainer(profileBox)
  QF.RandomizeTableDropdown:AddItem(QF.RandomizeTableDropdown:CreateItemEntry("All Collectibles", function() QF.SavedVars.randomizeTable = "All Collectibles" end))
  QF.RandomizeTableDropdown:AddItem(QF.RandomizeTableDropdown:CreateItemEntry("Favourites", function() QF.SavedVars.randomizeTable = "Favourites" end))
  QF.RandomizeTableDropdown:SetSelectedItem(QF.SavedVars.randomizeTable)
end

-- Create checkboxes and labels for each setting
local function InitRandomizeSettings()
  QF_RandomizeSettingsTitle:SetText("|cFF3C4BR|r|cFFAB2Fa|r|cFFCC52n|r|cFFF430d|r|cA8FF52o|r|c01FF25m|r|c60FFD8i|r|c96ACFFz|r|c8E58FFe!|r |c7B68EESettings|r")
  QF_RandomizeSettingsCaption:SetText("Collectible types to randomize:")

  CreateRandomizeOption(10, 0, 0) -- HAT
  CreateRandomizeOption(4, 0, 20) -- COSTUME
  CreateRandomizeOption(13, 0, 40) -- HAIR STYLE
  CreateRandomizeOption(14, 0, 60) -- FACIAL HAIR
  CreateRandomizeOption(15, 0, 80) -- MAJOR ADORNMENT
  CreateRandomizeOption(16, 0, 100) -- MINOR ADORNMENT

  CreateRandomizeOption(17, 145, 0) -- HEAD MARKING
  CreateRandomizeOption(18, 145, 20) -- BODY MARKING
  CreateRandomizeOption(11, 145, 40) -- SKIN
  CreateRandomizeOption(9, 145, 60) -- PERSONALITY
  CreateRandomizeOption(2, 145, 80) -- MOUNT
  CreateRandomizeOption(3, 145, 100) -- PET

  CreateRandomizeOptionByName("Title", 0, 130)
  CreateRandomizeOptionByName("Outfit", 0, 150)

  CreateRandomizeOption(12, 145, 130) -- POLYMORPH
end

-- Set checked state to default or SavedVars
local function InitRandomizeSettingCheckboxes()
  for type, checked in pairs(QF.SavedVars.RandomizeSetting) do
    local checkbox = WM:GetControlByName(string.format("QF_Randomize_%sCheckbox", type))
    ZO_CheckButton_SetCheckState(checkbox, checked)
  end
end

local function InitRandomizeHandlers()
  -- RANDOMIZE
  QF_Randomize:SetHandler("OnClicked", function(self, mouseButton) OnRandomizeButtonClicked(mouseButton) end)
  QF_RandomizeSettingsCloseButton:SetHandler("OnClicked", function(self) QF_RandomizeSettings:ToggleHidden() end)
end

-- Initialize Randomize panel
function QF.InitRandomize()
  InitRandomizeTableDropdown()
  InitRandomizeSettings()
  InitRandomizeSettingCheckboxes()

  InitRandomizeHandlers()
end

function QF_Randomize_Collectibles()
  QF.Randomize()
end
