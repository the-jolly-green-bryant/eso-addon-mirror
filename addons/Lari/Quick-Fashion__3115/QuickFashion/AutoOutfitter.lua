-- AUTO-OUTFITTER --
-- OR --
-- QUICK PROFILES --

local QF = _G["QF"]

local WM = WINDOW_MANAGER

---------------------------------
-- INFO TOOLTIP --
---------------------------------

local function InitAutoOutfitterInfoTooltip()
  local infoTooltip = "Select a profile and (left) click on the save button to assign it to a zone or house. Right click the save button to remove it." ..
                      "\n\nThis profile will be equipped automatically when you change zones or port to the specified house." ..
                      "\n\nIf a default profile is assigned, this profile will be equipped when porting to any zone that does not have a designated profile."
  QF_AutoOutfitterInfoButton:SetHandler("onMouseEnter", function(self) InitializeTooltip(InformationTooltip, QF_AutoOutfitter, TOPRIGHT, -8, -8, TOPLEFT)
                                                         SetTooltipText(InformationTooltip, infoTooltip) end)
  QF_AutoOutfitterInfoButton:SetHandler("OnMouseExit", function(self) ClearTooltip(InformationTooltip) end)
end

local function SetOnMouseoverHandlersForLabel(labelControl, bgControl)
  labelControl:SetHandler("OnMouseEnter", function(self) bgControl:SetHidden(false)
                                                         if self:WasTruncated() then ZO_Tooltips_ShowTextTooltip(self, TOP, self:GetText()) end end)
  labelControl:SetHandler("OnMouseExit",  function(self) bgControl:SetHidden(true)
                                                         ZO_Tooltips_HideTextTooltip() end)
end

function QF.SetOnMouseoverHandlersForButton(buttonControl, bgControl, tooltipText)
  buttonControl:SetHandler("OnMouseEnter", function(self) bgControl:SetHidden(false)
                                                          if tooltipText ~= nil then ZO_Tooltips_ShowTextTooltip(self, TOP, tooltipText) end end)
  buttonControl:SetHandler("OnMouseExit",  function(self) bgControl:SetHidden(true)
                                                          ZO_Tooltips_HideTextTooltip() end)
end

---------------------------------
-- EDIT BUTTONS --
---------------------------------

local function OnZoneEditButtonClicked(mouseButton, id, profile, vars)
  if mouseButton == MOUSE_BUTTON_INDEX_LEFT then
    local profileName = QF.ZoneProfilesDropDown:GetSelectedItem()
    if profileName ~= nil and profileName ~= "" then
      vars[id] = profileName
      profile:SetText(profileName)
    else
      QF.ChatMessage("Please select a profile.")
    end
  elseif mouseButton == MOUSE_BUTTON_INDEX_RIGHT then
    vars[id] = "|c989898No profile|r"
    profile:SetText("|c989898No profile|r")
  end
end

local function OnHouseEditButtonClicked(mouseButton, index, playerName, houseId)
  local profile = WM:GetControlByName(string.format("QF_AO_House_%iProfile", index))

  if mouseButton == MOUSE_BUTTON_INDEX_LEFT then
    local profileName = QF.HouseProfilesDropDown:GetSelectedItem()
    if profileName ~= nil and profileName ~= "|c989898Select profile|r" then
      local list = QF.SavedVars.AutoOutfitter.Houses[playerName] or {}
      list[houseId] = profileName
      QF.SavedVars.AutoOutfitter.Houses[playerName] = list
      profile:SetText(profileName)
    else
      QF.ChatMessage("Please select a profile.")
    end
  elseif mouseButton == MOUSE_BUTTON_INDEX_RIGHT then
    local list = QF.SavedVars.AutoOutfitter.Houses[playerName] or {}
    list[houseId] = "|c989898No profile|r"
    QF.SavedVars.AutoOutfitter.Houses[playerName] = list
    profile:SetText("|c989898No profile|r")
  end
end

---------------------------------
-- ZONES UI INITIALIZATION --
---------------------------------

local function InitZoneProfilesDropdown()
  local profileBox = WM:CreateControlFromVirtual("QF_AO_ZoneProfilesDropdown", QF_AO_ZoneSettingTopBar, "QF_DropdownTemplate")
  profileBox:ClearAnchors()
  profileBox:SetDimensions(220, 30)
  profileBox:SetAnchor(LEFT, QF_AO_ZoneSettingTopBarHeader, RIGHT, 8, 0)
  QF.ZoneProfilesDropDown = ZO_ComboBox_ObjectFromContainer(profileBox)
  for i,v in pairs(QF.SavedVars.Profiles) do
    local itemEntry = QF.ZoneProfilesDropDown:CreateItemEntry(i)
    QF.ZoneProfilesDropDown:AddItem(itemEntry)
  end
end

-- Create profile selectors for zone categories
local function InitZoneCategories()
  local parentControl = WM:GetControlByName("QF_AO_CategoriesScrollChild")
  parentControl:SetResizeToFitDescendents(true)
  local emptyControl = WM:CreateControl("QF_AO_Category_Empty", parentControl)
  emptyControl:SetAnchor(TOPLEFT, parentControl, TOPLEFT, 0, -2)

  local list = QF.ZoneCategories
  for i = 1, #list do
    -- Last child control to use for anchoring
    local relativeControl = parentControl:GetChild(parentControl:GetNumChildren())

    local control = WM:CreateControlFromVirtual(string.format("QF_AO_Category_%i", i), parentControl, "QF_AO_ZoneTemplate")
    control:SetAnchor(TOPLEFT, relativeControl, BOTTOMLEFT, 0, 3)

    local label = WM:GetControlByName(string.format("QF_AO_Category_%iName", i))
    local profile = WM:GetControlByName(string.format("QF_AO_Category_%iProfile", i))
    local editButton = WM:GetControlByName(string.format("QF_AO_Category_%iEdit", i))
    local bg = WM:GetControlByName(string.format("QF_AO_Category_%iBG", i))

    label:SetText(list[i])

    if QF.SavedVars.AutoOutfitter.ZoneCategories[i] ~= nil then
      profile:SetText(QF.SavedVars.AutoOutfitter.ZoneCategories[i])
    else
      profile:SetText("|c989898No profile|r")
    end

    SetOnMouseoverHandlersForLabel(label, bg)
    SetOnMouseoverHandlersForLabel(profile, bg)

    local editButtonTooltip = "Left-click: Set profile \nRight-click: Remove profile"
    QF.SetOnMouseoverHandlersForButton(editButton, bg, editButtonTooltip)

    editButton:SetHandler("OnClicked", function(self, mouseButton) OnZoneEditButtonClicked(mouseButton, i, profile, QF.SavedVars.AutoOutfitter.ZoneCategories) end)
  end
end

-- Create profile selectors for overland zones
local function InitOverlandZones()
  local parentControl = WM:GetControlByName("QF_AO_ZonesScrollChild")
  parentControl:SetResizeToFitDescendents(true)
  local emptyControl = WM:CreateControl("QF_AO_Zone_Empty", parentControl)
  emptyControl:SetAnchor(TOPLEFT, parentControl, TOPLEFT, 0, -2)

  -- Sort zones alphabetically
  local list = QF.OverlandZones
  for i = 1, #list do
    list[i].zoneName = GetZoneNameById(list[i].zoneId)
  end
  table.sort(list, function(a,b) return a.zoneName < b.zoneName end)

  for i = 1, #list do
    -- Last child control to use for anchoring
    local zoneId = list[i].zoneId
    local zoneName = list[i].zoneName
    local relativeControl = parentControl:GetChild(parentControl:GetNumChildren())

    local control = WM:CreateControlFromVirtual(string.format("QF_AO_Zone_%i", zoneId), parentControl, "QF_AO_ZoneTemplate")
    control:SetAnchor(TOPLEFT, relativeControl, BOTTOMLEFT, 0, 3)

    local label = WM:GetControlByName(string.format("QF_AO_Zone_%iName", zoneId))
    local profile = WM:GetControlByName(string.format("QF_AO_Zone_%iProfile", zoneId))
    local editButton = WM:GetControlByName(string.format("QF_AO_Zone_%iEdit", zoneId))
    local bg = WM:GetControlByName(string.format("QF_AO_Zone_%iBG", zoneId))

    label:SetText(zoneName)

    if QF.SavedVars.AutoOutfitter.OverlandZones[zoneId] ~= nil then
      profile:SetText(QF.SavedVars.AutoOutfitter.OverlandZones[zoneId])
    else
      profile:SetText("|c989898No profile|r")
    end

    SetOnMouseoverHandlersForLabel(label, bg)
    SetOnMouseoverHandlersForLabel(profile, bg)

    local editButtonTooltip = "Left-click: Set profile \nRight-click: Remove profile"
    QF.SetOnMouseoverHandlersForButton(editButton, bg, editButtonTooltip)

    editButton:SetHandler("OnClicked", function(self, mouseButton) OnZoneEditButtonClicked(mouseButton, zoneId, profile, QF.SavedVars.AutoOutfitter.OverlandZones) end)
  end
end

----------------------------------
-- HOUSES UI INITIALIZATION --
----------------------------------

local function InitHouseListDropdown()
  local profileBox = WM:CreateControlFromVirtual("QF_AO_HousesDropdown", QF_AO_HouseSettingTopBar, "QF_DropdownTemplate")
  profileBox:ClearAnchors()
  profileBox:SetDimensions(200, 30)
  profileBox:SetAnchor(TOPLEFT, QF_AO_HouseSettingTopBar, TOPLEFT, 208, 0)
  QF.HouseListDropdown = ZO_ComboBox_ObjectFromContainer(profileBox)

  for i, v in pairs(QF.HouseData) do
    local houseName = GetCollectibleName(v.collectibleId)
    local itemEntry = QF.HouseListDropdown:CreateItemEntry(houseName)
    QF.HouseListDropdown:AddItem(itemEntry)
  end
  QF.HouseListDropdown:SetSelectedItem("|c989898Select house|r")
end

local function InitHouseProfilesDropdown()
  local profileBox = WM:CreateControlFromVirtual("QF_AO_HouseProfilesDropdown", QF_AO_HouseSettingTopBar, "QF_DropdownTemplate")
  profileBox:ClearAnchors()
  profileBox:SetDimensions(150, 30)
  profileBox:SetAnchor(TOPRIGHT, QF_AO_HouseSettingTopBar, TOPRIGHT, -35, 0)
  QF.HouseProfilesDropDown = ZO_ComboBox_ObjectFromContainer(profileBox)
  for i,v in pairs(QF.SavedVars.Profiles) do
    local itemEntry = QF.HouseProfilesDropDown:CreateItemEntry(i)
    QF.HouseProfilesDropDown:AddItem(itemEntry)
  end
  QF.HouseProfilesDropDown:SetSelectedItem("|c989898Select profile|r")
end

local function InitHouseProfilesList()
  local parentControl = WM:GetControlByName("QF_AO_HousesScrollChild")
  parentControl:SetResizeToFitDescendents(true)
  local emptyControl = WM:CreateControl("QF_AO_House_Empty", parentControl)
  emptyControl:SetAnchor(TOPLEFT, parentControl, TOPLEFT, 0, -2)

  QF.UpdateHouseProfileList()
end

--------------------------------
-- HOUSE FUNCTIONS --
--------------------------------

local function GetHouseIdFromName(houseName)
  for houseId, v in pairs(QF.HouseData) do
    local name = GetCollectibleName(v.collectibleId)
    if name == houseName then
      return houseId
    end
  end
end

local function AddHouseEntry()
  local playerName = QF_AO_HouseEditBox_UserId:GetText()
  local houseName = QF.HouseListDropdown:GetSelectedItem()
  local profileName = QF.HouseProfilesDropDown:GetSelectedItem()

  if playerName == nil or playerName == "" then
    playerName = GetDisplayName()
  end

  if houseName == "|c989898Select house|r" then
    QF.ChatMessage("Please select a house.")
    return
  end

  if profileName == "|c989898Select profile|r" then
    profileName = "|c989898No profile|r"
  end

  local houseId = GetHouseIdFromName(houseName)
  local list = QF.SavedVars.AutoOutfitter.Houses[playerName] or {}
  list[houseId] = profileName

  QF.SavedVars.AutoOutfitter.Houses[playerName] = list
  QF.UpdateHouseProfileList()
end

local function RemoveHouseEntry(playerName, houseId)
  local list = QF.SavedVars.AutoOutfitter.Houses[playerName] or {}
  list[houseId] = nil
  QF.SavedVars.AutoOutfitter.Houses[playerName] = list
  QF.UpdateHouseProfileList()
end

local function PortToHouse(playerName, houseId)
  if playerName == GetDisplayName() then
    RequestJumpToHouse(houseId)
  else
    JumpToSpecificHouse(playerName, houseId)
  end
end

local function CreateSortedHouseList()
  local houseTable = {}
  local i = 1
  for name,_ in pairs(QF.SavedVars.AutoOutfitter.Houses) do
    houseTable[i] = {
      name = name,
      list = {},
    }
    local j = 1
    for houseId, profile in pairs(QF.SavedVars.AutoOutfitter.Houses[name]) do
      houseTable[i].list[j] = {
        houseId = houseId,
        houseName = GetCollectibleName(QF.HouseData[houseId].collectibleId),
        profile = profile,
      }
      j = j + 1
    end
    table.sort(houseTable[i].list, function(a,b) return a.houseName < b.houseName end)
    i = i + 1
  end
  table.sort(houseTable, function(a,b) return a.name < b.name end)
  return houseTable
end

function QF.UpdateHouseProfileList()
  local parentControl = WM:GetControlByName("QF_AO_HousesScrollChild")

  -- Hide all controls in the beginning and show them as they are filled in.
  -- Mainly to "remove" extra controls if the corresponding entries are deleted.
  for i = 1, parentControl:GetNumChildren() do
    parentControl:GetChild(i):SetHidden(true)
  end

  local houseTable = CreateSortedHouseList()
  local playerName, houseName, profileName
  local index = 1

  for i,_ in ipairs(houseTable) do
    playerName = houseTable[i].name
    for j,_ in ipairs(houseTable[i].list) do
      houseId = houseTable[i].list[j].houseId
      houseName = houseTable[i].list[j].houseName
      profileName = houseTable[i].list[j].profile

      local control = WM:GetControlByName(string.format("QF_AO_House_%i", index))
      if control == nil then
        local relativeControl = parentControl:GetChild(parentControl:GetNumChildren())
        control = WM:CreateControlFromVirtual(string.format("QF_AO_House_%i", index), parentControl, "QF_AO_HouseTemplate")
        control:SetAnchor(TOPLEFT, relativeControl, BOTTOMLEFT, 0, 3)
      end
      control:SetHidden(false)

      local player = WM:GetControlByName(string.format("QF_AO_House_%iPlayer", index))
      local house = WM:GetControlByName(string.format("QF_AO_House_%iHouse", index))
      local profile = WM:GetControlByName(string.format("QF_AO_House_%iProfile", index))
      local editButton = WM:GetControlByName(string.format("QF_AO_House_%iEdit", index))
      local portButton = WM:GetControlByName(string.format("QF_AO_House_%iPortButton", index))
      local removeButton = WM:GetControlByName(string.format("QF_AO_House_%iRemoveButton", index))
      local bg = WM:GetControlByName(string.format("QF_AO_House_%iBG", index))

      player:SetText(playerName)
      house:SetText(houseName)
      house:SetId(houseId)
      profile:SetText(profileName)
      profile:SetId(index)

      SetOnMouseoverHandlersForLabel(player, bg)
      SetOnMouseoverHandlersForLabel(house, bg)
      SetOnMouseoverHandlersForLabel(profile, bg)

      local editButtonTooltip = "Left-click: Set profile \nRight-click: Remove profile"
      QF.SetOnMouseoverHandlersForButton(editButton, bg, editButtonTooltip)
      QF.SetOnMouseoverHandlersForButton(portButton, bg)
      QF.SetOnMouseoverHandlersForButton(removeButton, bg)

      editButton:SetHandler("OnClicked", function(self, mouseButton) OnHouseEditButtonClicked(mouseButton, profile:GetId(), player:GetText(), house:GetId()) end)
      portButton:SetHandler("OnClicked", function(self) PortToHouse(player:GetText(), house:GetId()) end)
      removeButton:SetHandler("OnClicked", function(self) RemoveHouseEntry(player:GetText(), house:GetId()) end)

      index = index + 1
    end
  end
end

---------------------------------
-- ZONE CHANGE FUNCTIONS --
---------------------------------

-- Following functions moved to Profiles.lua to make them local
-- function EquipProfileByZone(profile)
-- function QF.OnZoneChanged()

---------------------------------
-- UI TOGGLES --
---------------------------------

local function ToggleAutoOutfitterTabs(state)
  QF.SavedVars.AutoOutfitter.tab = state
  QF_AutoOutfitterFilter:SetText(state)

  if state == "ZONES" then
    QF_AutoOutfitterFilter:SetText("ZONES")
    QF_AutoOutfitterZonesButton:SetState(BSTATE_PRESSED, false)
    QF_AutoOutfitterHousesButton:SetState(BSTATE_NORMAL, false)
    QF_AO_Zones_Container:SetHidden(false)
    QF_AO_Houses_Container:SetHidden(true)
  elseif state == "HOUSES" then
    QF_AutoOutfitterZonesButton:SetState(BSTATE_NORMAL, false)
    QF_AutoOutfitterHousesButton:SetState(BSTATE_PRESSED, false)
    QF_AO_Zones_Container:SetHidden(true)
    QF_AO_Houses_Container:SetHidden(false)
  end
end

------------------------------------------
-- HELPER FUNCTIONS --
------------------------------------------

local function InitAutoOutfitterHandlers()
  -- AUTO OUTFITTER PANEl
  QF_AutoOutfitterCloseButton:SetHandler("OnClicked", function(self) QF_AutoOutfitter:ToggleHidden() end)
  QF_AutoOutfitterZonesButton:SetHandler("OnClicked", function(self) ToggleAutoOutfitterTabs("ZONES") end)
  QF_AutoOutfitterHousesButton:SetHandler("OnClicked", function(self) ToggleAutoOutfitterTabs("HOUSES") end)
  QF_AO_HouseSaveButton:SetHandler("OnClicked", function() AddHouseEntry() end)
end

--------------------------------------
-- FINAL INITIALIZATION --
--------------------------------------

function QF.InitAutoOutfitter()
  InitAutoOutfitterInfoTooltip()
  InitZoneCategories()
  InitOverlandZones()
  InitZoneProfilesDropdown()

  InitHouseListDropdown()
  InitHouseProfilesDropdown()
  InitHouseProfilesList()

  InitAutoOutfitterHandlers()

  ToggleAutoOutfitterTabs(QF.SavedVars.AutoOutfitter.tab)
end
