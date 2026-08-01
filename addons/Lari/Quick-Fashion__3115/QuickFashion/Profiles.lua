local QF = _G["QF"]

local WM = WINDOW_MANAGER

------------------------------
-- INITIALIZATION --
------------------------------

-- HOTKEYS --

-- If profile has a hotkey assigned to it, display that hotkey
local function SetHotkeyOnProfileSelect(profile)
  for i = 1, 10 do
    if profile == QF.SavedVars.ProfileHotkey[i] then
      QF.ProfileHotkeysDropDown:SetSelectedItem(i)
      return
    end
  end
  QF.ProfileHotkeysDropDown:SetSelectedItem("-")
end

-- PROFILES --

-- Click on profile button to show the saved collectibles per profile
local function OnProfileSelect(profile)
  for collectibleType, collectibleId in pairs(QF.SavedVars.Profiles[profile]) do
    if collectibleType ~= "outfit" and collectibleType ~= "title" and collectibleType ~= "actions" then
      QF.SetCollectibleSlot(collectibleType, collectibleId)
    end
  end
  QF.TitlesDropdown:SetSelectedItem(QF.SavedVars.Profiles[profile].title)
  QF.OutfitsDropdown:SetSelectedItem(QF.SavedVars.Profiles[profile].outfit)

  if QF.SavedVars.Profiles[profile].actions ~= nil then
    for fxType, collectibleId in pairs(QF.SavedVars.Profiles[profile].actions) do
      QF.SetCustomizedActionSlot(fxType, collectibleId)
    end
  end

  SetHotkeyOnProfileSelect(profile)
end

-- Loads profiles from SavedVars
local function UpdateProfilesList()
  QF.ProfilesDropDown:ClearItems()
  for i,v in pairs(QF.SavedVars.Profiles) do
    local itemEntry = QF.ProfilesDropDown:CreateItemEntry(i, function() OnProfileSelect(i) end)
    QF.ProfilesDropDown:AddItem(itemEntry)
  end

  QF.ZoneProfilesDropDown:ClearItems()
  for i,v in pairs(QF.SavedVars.Profiles) do
    local itemEntry = QF.ZoneProfilesDropDown:CreateItemEntry(i)
    QF.ZoneProfilesDropDown:AddItem(itemEntry)
  end

  QF.HouseProfilesDropDown:ClearItems()
  for i,v in pairs(QF.SavedVars.Profiles) do
    local itemEntry = QF.HouseProfilesDropDown:CreateItemEntry(i)
    QF.HouseProfilesDropDown:AddItem(itemEntry)
  end
  QF.HouseProfilesDropDown:SetSelectedItem("|c989898Select profile|r")

  QF.CharacterProfilesDropdown:ClearItems()
  for i,v in pairs(QF.SavedVars.Profiles) do
    local itemEntry = QF.CharacterProfilesDropdown:CreateItemEntry(i, function() EquipProfileByName(i)
                                                                                 UpdateProfileDropdowns(i) end)
    QF.CharacterProfilesDropdown:AddItem(itemEntry)
  end
end

-- Update all profile dropdowns
local function UpdateProfileDropdowns(profile)
  QF.ProfilesDropDown:SetSelectedItem(profile)
  QF.CharacterProfilesDropdown:SetSelectedItem(profile)
  SetHotkeyOnProfileSelect(profile)
end

-- Creates the profiles dropdown virtual
local function InitProfilesDropDownList()
  local profileBox = WM:CreateControlFromVirtual("QF_ProfilesDropDown", QF_PanelProfiles, "QF_DropdownTemplate")
  profileBox:ClearAnchors()
  profileBox:SetDimensions(275, 30)
  profileBox:SetAnchor(TOPLEFT, QF_PanelProfiles, TOPLEFT, -7, 40)
  QF.ProfilesDropDown = ZO_ComboBox_ObjectFromContainer(profileBox)

  QF.ProfilesDropDown:ClearItems()
  for i,v in pairs(QF.SavedVars.Profiles) do
    local itemEntry = QF.ProfilesDropDown:CreateItemEntry(i, function() OnProfileSelect(i) end)
    QF.ProfilesDropDown:AddItem(itemEntry)
  end
  QF.ProfilesDropDown:SetSelectedItem("|c989898Select profile|r")
end

-- HOTKEYS --

-- Assign a profile to a hotkey
local function SetProfileHotkey(i)
  local profileName = QF.ProfilesDropDown:GetSelectedItem()
  if profileName == nil or profileName == "" then
    QF.ChatMessage(string.format("No profile currently assigned to hotkey %i.", i))
    return
  end
  QF.SavedVars.ProfileHotkey[i] = profileName
  QF.ChatMessage(string.format("The profile |c9081ff%s|r was saved to hotkey %i.", profileName, i))
end

-- Assign functions to hotkey dropdown list
local function UpdateProfileHotkeysDropdown()
  QF.ProfileHotkeysDropDown:ClearItems()
  for i = 1, 10 do
    local itemEntry = QF.ProfileHotkeysDropDown:CreateItemEntry(i, function() SetProfileHotkey(i) end)
    QF.ProfileHotkeysDropDown:AddItem(itemEntry)
  end
end

-- Displays profile hotkeys dropdown on load
local function InitProfileHotkeysDropdown()
  local profileBox = WM:CreateControlFromVirtual("QF_ProfileHotkeysDropDown", QF_PanelProfiles, "QF_DropdownTemplate")
  profileBox:ClearAnchors()
  profileBox:SetDimensions(60, 30)
  profileBox:SetAnchor(TOPRIGHT, QF_PanelProfiles, TOPRIGHT, -5, 40)
  QF.ProfileHotkeysDropDown = ZO_ComboBox_ObjectFromContainer(profileBox)
  UpdateProfileHotkeysDropdown()
end

------------------------------
-- PROFILE MANAGEMENT --
------------------------------

-- This goes into the function below :pointyfinger:
local function EquipCollectibleFromProfile(collectibleType, collectibleId)
  if collectibleId == 0 then
    local activeCollectibleId = GetActiveCollectibleByType(collectibleType)
    if IsCollectibleActive(activeCollectibleId) == true then
      UseCollectible(activeCollectibleId)
    end
  elseif IsCollectibleActive(collectibleId) == false then
    UseCollectible(collectibleId)
  end
end

local function EquipProfileByName(profileName)
  if QF.SavedVars.Profiles[profileName] == nil then
    QF.ChatMessage(string.format("Profile |c9081ff%s|r not found.", profileName))
    return
  end

  if GetCurrentZoneHouseId() == 0 then
    for collectibleType, collectibleId in pairs(QF.SavedVars.Profiles[profileName]) do
      if collectibleType ~= "outfit" and collectibleType ~= "title" and collectibleType ~= "actions"  then
        EquipCollectibleFromProfile(collectibleType, collectibleId)
      end
    end
  else
    for collectibleType, collectibleId in pairs(QF.SavedVars.Profiles[profileName]) do
      if collectibleType ~= COLLECTIBLE_CATEGORY_TYPE_VANITY_PET
        and collectibleType ~= "outfit"
        and collectibleType ~= "title"
        and collectibleType ~= "actions" then
        EquipCollectibleFromProfile(collectibleType, collectibleId)
      end
    end
  end

  local function GetTitleIndexByName(titleName)
    local numTitles = GetNumTitles()
    for titleIndex = 1, numTitles do
      if GetTitle(titleIndex) == titleName then
        return titleIndex
      end
    end
  end

  local titleIndex = GetTitleIndexByName(QF.SavedVars.Profiles[profileName].title)
  SelectTitle(titleIndex)

  local function GetOutfitIndexByName(outfitName)
    local numOutfits = GetNumUnlockedOutfits()
    for outfitIndex = 1, numOutfits do
      if GetOutfitName(0, outfitIndex) == outfitName then
        return outfitIndex
      elseif "Outfit " .. outfitIndex == outfitName then
        return outfitIndex
      end
    end
  end

  local outfitIndex = GetOutfitIndexByName(QF.SavedVars.Profiles[profileName].outfit)
  if outfitIndex ~= nil then
    EquipOutfit(0, outfitIndex)
  else
    UnequipOutfit()
  end

  local activeCustomizedActions = QF.GetActiveCustomizedActions()

  local function EquipCustomizedActionFromProfile(fxType, collectibleId)
    if collectibleId == 0 then
      local activeCollectibleId = activeCustomizedActions[fxType]
      if IsCollectibleActive(activeCollectibleId) == true then
        UseCollectible(activeCollectibleId)
      end
    elseif IsCollectibleActive(collectibleId) == false then
      UseCollectible(collectibleId)
    end
  end

  for fxType, collectibleId in pairs(QF.SavedVars.Profiles[profileName].actions) do
    EquipCustomizedActionFromProfile(fxType, collectibleId)
  end
end

-- Equip the selected profile
local function EquipProfile()
  local profileName = QF.ProfilesDropDown:GetSelectedItem()
  -- local text = string.format("The profile |c9081ff%s|r was equipped.", profileName)
  if profileName == nil or profileName == "" then
    QF.ChatMessage("Please select a profile.")
    return
  end

  EquipProfileByName(profileName)
  UpdateProfileDropdowns(profileName)
end

--------------------------------------
-- PROFILE BUTTONS --
--------------------------------------

-- Toggle buttons depending on what is clicked
local function ToggleNewProfileButtons(state)
  QF_ProfilesDropDown:SetHidden(state)
  QF_ProfileHotkeysDropDown:SetHidden(state)
  QF_NewProfileEditBox:SetHidden(not state)
  QF_Delete:SetHidden(state)
  QF_Cancel:SetHidden(not state)

  if state == true then
    QF_Save:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_HideTextTooltip() end)
  else
    QF.SetToolTip(QF_Save, BOTTOM, "|cFF0000This will overwrite the selected profile.|r")
  end
end

-- Simple toggle to show the Editbox and Save/cancel buttons
local function NewProfile()
  ToggleNewProfileButtons(true)
  WM:SetFocusByName("QF_NewProfileEditBox")
end

-- Save a new profile
local function SaveProfile()
  local profileName
  if QF_NewProfileEditBox:IsHidden() == false then
    profileName = QF_NewProfileEditBox:GetText()
  else
    profileName = QF.ProfilesDropDown:GetSelectedItem()
  end

  if profileName == nil or profileName == "" or profileName == "|c989898Select profile|r" or profileName == "|c989898No profile|r" then
    QF.ChatMessage("Please enter a valid profile name!")
    return
  end

  local Profile = {}

  for collectibleType,_ in pairs(QF.CollectibleTable) do
    local slottedCollectibleId = QF.GetSlottedCollectibleIdByType(collectibleType)
    Profile[collectibleType] = slottedCollectibleId
  end
  Profile.title  = QF.TitlesDropdown:GetSelectedItem()
  Profile.outfit = QF.OutfitsDropdown:GetSelectedItem()

  local activeCustomizedActions = QF.GetActiveCustomizedActions()
  Profile.actions = activeCustomizedActions

  QF.SavedVars.Profiles[profileName] = Profile
  QF.ChatMessage(string.format("The profile |c9081ff%s|r was saved.", profileName))

  -- GYAH! Fix this logic later!
  if QF_NewProfileEditBox:IsHidden() == false then
    QF_NewProfileEditBox:Clear()
    ToggleNewProfileButtons(false)
  end

  UpdateProfilesList()
  UpdateProfileDropdowns(profile)
end

-- Delete the selected profile
local function DeleteProfile()
  local profileName = QF.ProfilesDropDown:GetSelectedItem()

  if profileName == nil or profileName == "" then
    QF.ChatMessage("Please select a profile to delete.")
    return
  end

  QF.SavedVars.Profiles[profileName] = nil
  QF.ChatMessage(string.format("The profile |c9081ff%s|r was deleted.", profileName))
  UpdateProfilesList()
  UpdateProfileHotkeysDropdown()
end

-- Cancel button to hide the Editbox
local function CancelNewProfile()
  ToggleNewProfileButtons(false)
end

-------------------------------
-- PROFILE HOTKEYS  --
-------------------------------

-- Equip a profile by a hotkey
local function EquipProfileByHotkey(i)
  profileName = QF.SavedVars.ProfileHotkey[i]
  if QF.SavedVars.Profiles[profileName] ~= nil then
    QF.ProfilesDropDown:SetSelectedItem(profileName)
    EquipProfile()
  else
    QF.ChatMessage(string.format("No profile currently assigned to hotkey %i.", i))
  end
end

function QF_EQUIP_PROFILE_BY_HOTKEY(i)
  EquipProfileByHotkey(i)
end

--------------------------------------------
-- ZOS_CHARACTER PROFILE DROPDOWN --
--------------------------------------------

local function InitCharacterProfilesDropdown()
  local control = WM:CreateControl("QF_CharacterProfilesTopControl", ZO_Character, CT_CONTROL)
  control:SetAnchor(TOPLEFT, ZO_Character, BOTTOMLEFT, 0, 30)
  control:SetResizeToFitDescendents(true)
  control:SetMovable(true)
  control:SetMouseEnabled(true)
  control:SetClampedToScreen(true)
  control:SetHandler("OnMoveStop", QF_CharacterProfiles_On_Move_Stop)

  --This broke the addon in U45. Can be fixed by taking "" out of ZO_SliderBackdrop, but not sure if it makes a difference?
  --[[ local backdrop = WM:CreateControl("QF_CharacterProfilesBackdrop", ZO_Character, "ZO_SliderBackdrop")
  backdrop:SetAnchor(TOPLEFT, QF_CharacterProfilesTopControl, TOPLEFT, -15, -15)
  backdrop:SetAnchor(BOTTOMRIGHT, QF_CharacterProfilesTopControl, BOTTOMRIGHT, 15, 15) ]]--

  local texture = WM:CreateControl("QF_CharacterProfilesDivider", QF_CharacterProfilesTopControl, CT_TEXTURE)
  texture:SetDimensions(256, 4)
  texture:SetAnchor(TOPLEFT, QF_CharacterProfilesBackground, TOPLEFT, 0, 0)
  texture:SetTexture("EsoUI/Art/CharacterWindow/characterWindow_leftSide_divider.dds")

  local label = WM:CreateControl("QF_CharacterProfilesLabel", QF_CharacterProfilesTopControl, CT_LABEL)
  label:SetDimensions(150, 30)
  label:SetAnchor(TOPLEFT, QF_CharacterProfilesDivider, BOTTOMLEFT, 10, 10)
  label:SetFont("$(BOLD_FONT)|$(KB_18)|soft-shadow-thick")
  label:SetText("PROFILE")

  local profileBox = WM:CreateControlFromVirtual("QF_CharacterProfilesDropdown", QF_CharacterProfilesTopControl, "QF_DropdownTemplate")
  profileBox:ClearAnchors()
  profileBox:SetDimensions(200, 30)
  profileBox:SetAnchor(TOPLEFT, QF_CharacterProfilesLabel, BOTTOMLEFT)

  QF.CharacterProfilesDropdown = ZO_ComboBox_ObjectFromContainer(profileBox)
  for profileName,_ in pairs(QF.SavedVars.Profiles) do
    local itemEntry = QF.CharacterProfilesDropdown:CreateItemEntry(profileName, function() EquipProfileByName(profileName)
                                                                                           UpdateProfileDropdowns(profileName) end)
    QF.CharacterProfilesDropdown:AddItem(itemEntry)
  end
  -- local itemEntry = QF.CharacterProfilesDropdown:CreateItemEntry("|c989898No profile|r")
  -- QF.CharacterProfilesDropdown:AddItem(itemEntry)
  QF.CharacterProfilesDropdown:SetSelectedItem("|c989898Select profile|r")
end

--------------------------------------------
-- AUTOOUTFITTER ZONE CHANGE FUNCTIONS --
--------------------------------------------

local function EquipProfileByZone(profile)
  if profile == nil or profile == "|c989898No profile|r" then
    local defaultProfile = QF.SavedVars.AutoOutfitter.ZoneCategories[1]
    if defaultProfile ~= nil and defaultProfile ~= "|c989898No profile|r" then
      profile = defaultProfile
    else
      return
    end
  end

  EquipProfileByName(profile)
  UpdateProfileDropdowns(profile)
end

function QF.OnZoneChanged()
  if IsUnitSwimming("player") == true then
    QF.PlayerSwimming()
    return
  end

  local houseId = GetCurrentZoneHouseId()
  local zoneId = GetZoneId(GetUnitZoneIndex("player"))
  local parentZoneId = GetParentZoneId(zoneId)
  local profile

  if houseId ~= 0 then
    local playerName = GetCurrentHouseOwner()
    if QF.SavedVars.AutoOutfitter.Houses[playerName] ~= nil then
      profile = QF.SavedVars.AutoOutfitter.Houses[playerName][houseId]
    end

    zo_callLater(function() EquipProfileByZone(profile) end, 200)
    return
  end

  if IsUnitInDungeon("player") and GetCurrentZoneDungeonDifficulty() ~= DUNGEON_DIFFICULTY_NONE then
    profile = QF.SavedVars.AutoOutfitter.ZoneCategories[2]
    EquipProfileByZone(profile)
    return
  end

  if IsInCyrodiil() == true or parentZoneId == 181 then
    profile = QF.SavedVars.AutoOutfitter.ZoneCategories[3]
    EquipProfileByZone(profile)
    return
  end

  if IsActiveWorldBattleground() then
    profile = QF.SavedVars.AutoOutfitter.ZoneCategories[4]
    EquipProfileByZone(profile)
    return
  end

  if IsInImperialCity() or parentZoneId == 584 then
    profile = QF.SavedVars.AutoOutfitter.ZoneCategories[5]
    EquipProfileByZone(profile)
    return
  end

  if IsInOutlawZone() then
    profile = QF.SavedVars.AutoOutfitter.ZoneCategories[6]
    EquipProfileByZone(profile)
    return
  end

  -- Exception for Artaeum and Apocrypha, whose parent zones are Summerset and Telvanni Peninsula
  if zoneId == 1027 or zoneId == 1413 then
    profile = QF.SavedVars.AutoOutfitter.OverlandZones[zoneId]
    EquipProfileByZone(profile)
    return
  end

  profile = QF.SavedVars.AutoOutfitter.OverlandZones[parentZoneId]
  EquipProfileByZone(profile)
end

-- CRAFTING INTERACTION --

-- Lookup table for crafts corresponding to QF.ZoneCategories in Startup.lua
local craftTable = {
  [CRAFTING_TYPE_CLOTHIER] = 8,
  [CRAFTING_TYPE_BLACKSMITHING] = 9,
  [CRAFTING_TYPE_WOODWORKING] = 10,
  [CRAFTING_TYPE_JEWELRYCRAFTING] = 11,
  [CRAFTING_TYPE_ALCHEMY] = 12,
  [CRAFTING_TYPE_ENCHANTING] = 13,
  [CRAFTING_TYPE_PROVISIONING] = 14,
}

function QF.OnCraftingInteract(event, craftSkill, sameStation)
  if craftSkill == 0 then return end -- Bosmer decon lady has a craftSkill of 0!

  local function EquipProfileByCraft(index)
    local profile = QF.SavedVars.AutoOutfitter.ZoneCategories[index]
    if profile == "|c989898No profile|r" then
      return
    end
    EquipProfileByZone(profile)
    return
  end

  EquipProfileByCraft(craftTable[craftSkill])
end

function QF.OnCraftingInteractEnd(event, craftSkill)
  local profile = QF.SavedVars.AutoOutfitter.ZoneCategories[craftTable[craftSkill]]
  if profile == "|c989898No profile|r" then
    return
  end

  QF.OnZoneChanged()
end

-- SWIMMING --

function QF.PlayerSwimming()
  local profile = QF.SavedVars.AutoOutfitter.ZoneCategories[7]
  if profile == "|c989898No profile|r" then
    return
  end
  EquipProfileByZone(profile)
end

function QF.PlayerNotSwimming()
  local profile = QF.SavedVars.AutoOutfitter.ZoneCategories[7]
  if profile == "|c989898No profile|r" then
    return
  end

  local function IsPlayerSwimming()
    if IsUnitSwimming("player") == false and IsUnitInAir("player") == false then
      QF.OnZoneChanged()
    end
  end

  -- Prevent unauthorized wardrobe changes if jumping while swimming
  local isUnitinAir = IsUnitInAir("player")
  if isUnitinAir == true then
    zo_callLater(IsPlayerSwimming, 2000)
    return
  end

  QF.OnZoneChanged()
end

--------------------------------
-- ARMORY --
--------------------------------

function QF.ArmoryBuildEquipped(event, result, buildIndex)
  local profileName = QF.SavedVars.Armory.Profiles[buildIndex]
  if profileName == nil or profileName == "" or profileName == "|c989898No profile|r" then
    return
  end
  -- Don't need this line because the game is already equipping collectibles via the armory build
  EquipProfileByName(profileName)
  UpdateProfileDropdowns(profileName)
end

----------------------------------
-- SHARE TO CHAT --
----------------------------------

local function ShareProfileInChat()
  local profileName = QF.ProfilesDropDown:GetSelectedItem()

  if profileName == nil or profileName == "" or profileName == "|c989898Select profile|r" then
    QF.ChatMessage("Please select a profile.")
    return
  end

  local profile = QF.SavedVars.Profiles[profileName]
  local mount, pet, costume, personality, hat, skin, polymorph, hairStyle, facialHair, majorAdornment, minorAdornment, headMarking, bodyMarking
  local list = {}

  if profile[4]  ~= 0 then costume        = GetCollectibleName(profile[4])  table.insert(list, costume) end
  if profile[10] ~= 0 then hat            = GetCollectibleName(profile[10]) table.insert(list, hat) end
  if profile[13] ~= 0 then hairStyle      = GetCollectibleName(profile[13]) table.insert(list, hairStyle) end
  if profile[14] ~= 0 then facialHair     = GetCollectibleName(profile[14]) table.insert(list, facialHair) end
  if profile[15] ~= 0 then majorAdornment = GetCollectibleName(profile[15]) table.insert(list, majorAdornment) end
  if profile[16] ~= 0 then minorAdornment = GetCollectibleName(profile[16]) table.insert(list, minorAdornment) end
  if profile[17] ~= 0 then headMarking    = GetCollectibleName(profile[17]) table.insert(list, headMarking) end
  if profile[18] ~= 0 then bodyMarking    = GetCollectibleName(profile[18]) table.insert(list, bodyMarking) end
  if profile[9]  ~= 0 then personality    = GetCollectibleName(profile[9])  table.insert(list, personality) end
  if profile[11] ~= 0 then skin           = GetCollectibleName(profile[11]) table.insert(list, skin) end
  if profile[12] ~= 0 then polymorph      = GetCollectibleName(profile[12]) table.insert(list, polymorph) end
  if profile[2]  ~= 0 then mount          = GetCollectibleName(profile[2])  table.insert(list, mount) end
  if profile[3]  ~= 0 then pet            = GetCollectibleName(profile[3])  table.insert(list, pet) end

  local chatMessage = string.format("[Quick Fashion] %s (profile by %s): %s", profileName, GetDisplayName(), ZO_GenerateCommaSeparatedList(list))
  CHAT_SYSTEM:StartTextEntry(chatMessage)
end

local function ShareOutfitInChat()
  local outfitIndex = GetEquippedOutfitIndex(0)
  local outfitName

  if outfitIndex ~= nil then
    outfitName = GetOutfitName(0, outfitIndex)
    if outfitName == "" then
      outfitName = string.format("Outfit %i", outfitIndex)
    end
  else
    QF.ChatMessage("Please select an outfit.")
    return
  end

  local list = {}
  for i = 0, 12 do
    collectibleId = GetOutfitSlotInfo(0, outfitIndex, i)
    if collectibleId ~= 0 then
      table.insert(list, GetCollectibleName(collectibleId))
    end
  end
  for i = 24, 29 do
    collectibleId = GetOutfitSlotInfo(0, outfitIndex, i)
    if collectibleId ~= 0 then
      table.insert(list, GetCollectibleName(collectibleId))
    end
  end

  local chatMessage = string.format("[Quick Fashion] %s (outfit by %s): %s", outfitName, GetDisplayName(), ZO_GenerateCommaSeparatedList(list))
  CHAT_SYSTEM:StartTextEntry(chatMessage)
end

local function ShareButtonClicked()
  ClearMenu()
  AddMenuItem("Share profile in chat", function() ShareProfileInChat() end)
  AddMenuItem("Share outfit in chat", function() ShareOutfitInChat() end)
  ShowMenu()
end

---------------------------------
-- FINAL INITIALIZATION --
---------------------------------

local function InitProfilesHandlers()
  -- PROFILES
  QF_Equip:SetHandler("OnClicked", function(self) EquipProfile() end)
  QF_New:SetHandler("OnClicked", function(self) NewProfile() end)
  QF_Save:SetHandler("OnClicked", function(self) SaveProfile() end)
  QF_Cancel:SetHandler("OnClicked", function(self) CancelNewProfile() end)
  QF_Delete:SetHandler("OnClicked", function(self) DeleteProfile() end)
  QF_Share:SetHandler("OnClicked", function(self) ShareButtonClicked() end)

  -- AUTO-OUTFITTER TOGGLE BUTTON
  QF_AutoOutfitter_Button:SetHandler("OnClicked", function(self) QF_AutoOutfitter:ToggleHidden() end)
end

function QF.InitProfiles()
  InitProfilesDropDownList()
  InitProfileHotkeysDropdown()

  InitCharacterProfilesDropdown()

  InitProfilesHandlers()
end
