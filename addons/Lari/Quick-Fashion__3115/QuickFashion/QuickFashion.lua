local QF = _G["QF"] -- references the Globals table

local WM = WINDOW_MANAGER

--------------------------------
-- UTILITY FUNCTIONS --
--------------------------------

function QF.ChatMessage(text)
  CHAT_SYSTEM:AddMessage(string.format("%s%s", QF.Constants.chatPrefix, text))
end

function QF.SetTopToolTip(control, text)
  control:SetHandler("onMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, text) end)
  control:SetHandler("OnMouseExit", function(self) ZO_Tooltips_HideTextTooltip() end)
end

function QF.SetToolTip(control, position, text)
  control:SetHandler("onMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, position, text) end)
  control:SetHandler("OnMouseExit", function(self) ZO_Tooltips_HideTextTooltip() end)
end

function QF.GetSlottedCollectibleIdByType(collectibleType)
  local controlSuffix = QF.CollectibleTable[collectibleType].controlSuffix
  local QF_SlottedControl = GetControl(string.format("QF_Slotted%s", controlSuffix))
  local slottedCollectibleId = QF_SlottedControl:GetId()
  return slottedCollectibleId
end

function QF.GetSlottedCustomizedActionIdByType(fxType)
  local controlSuffix = QF.CustomizedActionsTable[fxType].controlSuffix
  local QF_SlottedControl = GetControl(string.format("QF_Slotted%s", controlSuffix))
  local slottedCollectibleId = QF_SlottedControl:GetId()
  return slottedCollectibleId
end

function QF.GetPersonalityTooltip(collectibleId, collectibleName)
  local personalityEmotes = {GetCollectiblePersonalityOverridenEmoteSlashCommandNames(collectibleId)}
  local emoteString = ZO_GenerateCommaSeparatedList(personalityEmotes)
  local tooltip = string.format("%s\n|c9081ff%s|r", collectibleName, emoteString)
  return tooltip
end

function QF.ProfileHotkeyListToChat()
  for hotkey = 1, 10 do
    local profile = QF.SavedVars.ProfileHotkey[hotkey]
    if QF.SavedVars.Profiles[profile] ~= nil then
      QF.ChatMessage(string.format("[%i] - %s", hotkey, profile))
    end
  end
end

-----------------------------
-- POSITIONING AND TOGGLES --
-----------------------------

function QF_Toggle_Fashion_Panel()
  QF.ToggleQFPanel()
end

function QF_Toggle_Fav_Panel()
  QF.ToggleFavPanel()
end

function QF_Toggle_Profiles_Panel()
  QF.ToggleQProfilesPanel()
end

--------------------------------
-- POSITIONING AND TOGGLES --
--------------------------------

function QFashion_On_Move_Stop()
  QF.SavedVars.FashionPanelLeft = QF_Panel:GetLeft()
  QF.SavedVars.FashionPanelTop = QF_Panel:GetTop()
end

function QFavs_On_Move_Stop()
  QF.SavedVars.FavsPanelLeft = Fav_Panel:GetLeft()
  QF.SavedVars.FavsPanelTop = Fav_Panel:GetTop()
end

function QF_AO_On_Move_Stop()
  QF.SavedVars.AOPanelLeft = QF_AutoOutfitter:GetLeft()
  QF.SavedVars.AOPanelTop = QF_AutoOutfitter:GetTop()
end

function QF_CharacterProfiles_On_Move_Stop()
  QF.SavedVars.CharacterProfilesLeft = QF_CharacterProfilesTopControl:GetLeft()
  QF.SavedVars.CharacterProfilesTop = QF_CharacterProfilesTopControl:GetTop()
end

-- Toggle both panels together
local function ToggleWindow()
  if QF_Panel:IsHidden() or Fav_Panel:IsHidden() then
    QF_Panel:SetHidden(false)
    Fav_Panel:SetHidden(false)
    SetGameCameraUIMode(true)
  else
    QF_Panel:SetHidden(true)
    Fav_Panel:SetHidden(true)

    QF_RandomizeSettings:SetHidden(true)
    QF_AutoOutfitter:SetHidden(true)
  end
end

function QF_Toggle_Window()
  ToggleWindow()
end

local function RestorePosition()

  local function SetPosition(control, left, top)
    if left ~= nil and top ~= nil then
      control:ClearAnchors()
      control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    end
  end

  SetPosition(QF_Panel, QF.SavedVars.FashionPanelLeft, QF.SavedVars.FashionPanelTop)
  SetPosition(Fav_Panel, QF.SavedVars.FavsPanelLeft, QF.SavedVars.FavsPanelTop)
  SetPosition(QF_AutoOutfitter, QF.SavedVars.AOPanelLeft, QF.SavedVars.AOPanelTop)
  SetPosition(QF_CharacterProfilesTopControl, QF.SavedVars.CharacterProfilesLeft, QF.SavedVars.CharacterProfilesTop)

  Fav_Panel:SetHeight(QF.SavedVars.FavPanelHeight)
  Fav_Panel:SetWidth(QF.SavedVars.FavPanelWidth)
end

function QF.ResetPositions()
  QF_Panel:ClearAnchors()
  QF_Panel:SetAnchor(CENTER, GuiRoot, CENTER, -150, -100)

  Fav_Panel:ClearAnchors()
  Fav_Panel:SetAnchor(TOPLEFT, QF_Panel, TOPRIGHT, 14, 0)

  QF_AutoOutfitter:ClearAnchors()
  QF_AutoOutfitter:SetAnchor(TOPLEFT, QF_Panel, BOTTOMLEFT, 0, 15)

  QF.SavedVars.FashionPanelTop = nil
  QF.SavedVars.FashionPanelLeft = nil
  QF.SavedVars.FavsPanelTop = nil
  QF.SavedVars.FavsPanelLeft = nil
  QF.SavedVars.AOPanelTop = nil
  QF.SavedVars.AOPanelLeft = nil
end

local function ToggleTopLevelControl(control)
  control:ToggleHidden()
  if not control:IsHidden() then
    SetGameCameraUIMode(true)
  end
end

function QF.ToggleQFPanel()
  ToggleTopLevelControl(QF_Panel)
end

function QF.ToggleFavPanel()
  ToggleTopLevelControl(Fav_Panel)
end

function QF.ToggleQProfilesPanel()
  ToggleTopLevelControl(QF_AutoOutfitter)
end

-- Show hide addon if Collections scene is opened/closed
local function OnCollectionsSceneChange(oldState, newState)
  local showQFPanel   = QF.SavedVars.showQFPanelWithCollections
  local showFavsPanel = QF.SavedVars.showFavsPanelWithCollections
  local showAOPanel   = QF.SavedVars.showAOPanelWithCollections

  if (newState == SCENE_SHOWN) then
    QF_Panel:SetHidden(not showQFPanel)
    Fav_Panel:SetHidden(not showFavsPanel)
    QF_AutoOutfitter:SetHidden(not showAOPanel)
  elseif (newState == SCENE_HIDDEN) then
    QF_Panel:SetHidden(true)
    Fav_Panel:SetHidden(true)
    QF_AutoOutfitter:SetHidden(true)
    QF_RandomizeSettings:SetHidden(true)
  end
end

-- Callback for the Collections scene
local function DisplayWithCollectionsScene()
  local scene = SCENE_MANAGER:GetScene("collectionsBook")
  scene:RegisterCallback("StateChange", OnCollectionsSceneChange)
end

---------------------------
-- INITIALIZATION --
---------------------------

local function InitToolTips()
  -- QUICK FASHION PANEL
  QF.SetTopToolTip(QF_PanelToggleFavPanel, "Toggle Quick Favourites")
  QF.SetTopToolTip(QF_PanelCloseButton, "Close")
  QF.SetTopToolTip(QF_PanelToggleHelm, "Show/Hide your Helm")
  -- QF.SetTopToolTip(QF_PanelUnequipWeapons, "Unequip Weapons")

  QF.SetToolTip(QF_OutfitsDropdown, LEFT, "Outfit")
  QF.SetToolTip(QF_TitlesDropdown, LEFT, "Title")

  -- RANDOMIZER
  QF.SetTopToolTip(QF_Randomize, "|cFF3C4BR|r|cFFAB2Fa|r|cFFCC52n|r|cFFF430d|r|cA8FF52o|r|c01FF25m|r|c60FFD8i|r|c96ACFFz|r|c8E58FFe|r your look!" ..
                                 "\n\nLeft-click to Randomize!" ..
                                 "\nRight-click for settings")

  -- AUTO-OUTFITTER TOGGLE BUTTON
  QF.SetTopToolTip(QF_AutoOutfitter_Button, "Toggle Quick Profiles")

  -- PROFILES
  QF.SetTopToolTip(QF_ProfileHotkeysDropDown, "Assign a hotkey to equip the selected profile")
  QF.SetToolTip(QF_Save, BOTTOM, "|cFF0000This will overwrite the selected profile.|r")

  -- FAVOURITES PANEL
  QF.SetTopToolTip(Fav_PanelToggleQFPanel, "Toggle Quick Fashion")
  QF.SetTopToolTip(Fav_PanelCloseButton, "Close")
  QF.SetTopToolTip(Fav_PanelShowAll, "Show All Owned Collectibles")
  QF.SetTopToolTip(Fav_PanelShowFavs, "Show Favourites")
  QF.SetTopToolTip(Fav_PanelShowRecent, "Show Recently Equipped")

  -- AUTO-OUTFITTER PANEL
  QF.SetTopToolTip(QF_AutoOutfitterZonesButton, "Zones")
  QF.SetTopToolTip(QF_AutoOutfitterHousesButton, "Houses")
  QF.SetTopToolTip(QF_AutoOutfitterCloseButton, "Close")
  QF.SetTopToolTip(QF_AO_HouseSaveButton, "Save House")
end

local function InitLabels()
  Fav_PanelEmptyLabel:SetText("Click the button above to display all owned collectibles." ..
                              "\n\nTo automatically load all collectibles on startup, enable this option in the addon settings.")
end

-- Parse any parameters passed through commands
local function CommandParse(args)
  local options = {}
  local params = { string.match(args,"^(%S*)%s*(.-)$") }
  for i,v in pairs(params) do
    if (v ~= nil and v ~= "") then
      options[i] = string.lower(v)
    end
  end

  if #options == 0 then
    ToggleWindow()
  else
    local i = tonumber(options[1])
    if i ~= nil and i >= 1 and i <= 10 then
      QF_EQUIP_PROFILE_BY_HOTKEY(i)
    else
      QF.ChatMessage("Command not found.")
    end
  end
end

function QF.Debug()
  d("|c7B68EEQUICK|r |c9F00FFFASHION|r DEBUG INFO:")
  d("- Addon initialization time: |cFFFFFF" .. QF.Temp.timeForAddonInit)
  d("- Icons only initialization time: |cFFFFFF" .. QF.Temp.timeForIconInit)
  d("- Total icons initialized: |cFFFFFF" .. QF.Temp.totalIconsInitialized)
end

-- One time function to transfer Favourites table into a sorted table
-- Required for sorted Favourites panel, and possible for other things
local function MigrateFavsToSortedTable()
  local Favourites = QF.SavedVars.Favourites
  local FavouritesByType = QF.Defaults.FavouritesByType

  for i = 2, #Favourites do
    local collectibleId = Favourites[i]
    local collectibleType = GetCollectibleCategoryType(collectibleId)
    if QF.IsFavourite(collectibleId, collectibleType) == false then
      table.insert(FavouritesByType[collectibleType], collectibleId)
    end
  end

  for collectibleType, v in pairs(FavouritesByType) do
    table.sort(FavouritesByType[collectibleType])
  end

  QF.SavedVars.FavouritesByType = FavouritesByType
  QF.SavedVars.migratedFavsToSortedTable = true
end

-----------------------------------
-- EVENT FUNCTIONS --
-----------------------------------

local function OnNewCollectibleAdded(event, collectibleId)
  local collectibleType = GetCollectibleCategoryType(collectibleId)
  local collectibleList = QF.SavedVars.OwnedCollectibles[collectibleType]
  if collectibleList ~= nil then
    table.insert(collectibleList, collectibleId)
    table.sort(collectibleList)
    QF.SavedVars.OwnedCollectibles[collectibleType] = collectibleList

    QF.CreateCollectibleIcon(collectibleId, collectibleType)
    QF.CreateCollectibleGridByType(collectibleType)
  end
end

-- If the character equips a collectible, load that collectible into the collectible slot
local function OnCollectibleUpdated(event, collectibleId)
  local collectibleType = GetCollectibleCategoryType(collectibleId)
  local collectibleName = GetCollectibleName(collectibleId)

  if collectibleType == COLLECTIBLE_CATEGORY_TYPE_HAT then
    if IsCollectibleActive(QF.Constants.COLLECTIBLE_ID_HIDE_HELMET) == false then
      QF.SavedVars.lastSlottedHatId = GetActiveCollectibleByType(collectibleType)
    end
  end

  if collectibleType == COLLECTIBLE_CATEGORY_TYPE_PLAYER_FX_OVERRIDE then
    QF.OnCustomizedActionUpdated(collectibleId)
    return
  end

  for type, v in pairs(QF.CollectibleTable) do
    if type == collectibleType then
      local activeCollectibleId = GetActiveCollectibleByType(collectibleType)
      if activeCollectibleId ~= 0 then
        QF.CreateCollectibleIcon(activeCollectibleId, collectibleType)
        QF.AddToRecentlyEquipped(activeCollectibleId, collectibleType)
      end

      local function UpdateCheckIndicatorOnCollectibleUpdated(collectibleType, collectibleId, activeCollectibleId)
        if collectibleId ~= 0 then
          local collectibleControl = WM:GetControlByName(string.format("QF_Fav_ID_%i", collectibleId))
          -- Apparently companion collectibles (horse + costume) trigger the EVENT_COLLECTIBLE_UPDATED on each zone change.
          -- Hence a little return function for collectibles that are triggered because of companions.
          if collectibleControl == nil then
            return
          end
          local check = collectibleControl:GetNamedChild("Check")
          check:SetHidden(true)
        end
        if activeCollectibleId ~= 0 then
          local activeCollectibleControl = WM:GetControlByName(string.format("QF_Fav_ID_%i", activeCollectibleId))
          local check = activeCollectibleControl:GetNamedChild("Check")
          check:SetHidden(false)
        end
      end

      UpdateCheckIndicatorOnCollectibleUpdated(collectibleType, collectibleId, activeCollectibleId)
      QF.SetCollectibleSlot(collectibleType, activeCollectibleId)
      return
    end
  end
end

-----------------------------------
-- ON ADDON LOADED --
-----------------------------------

function QF.OnPlayerActivated(event, addonName)
  QF.OnZoneChanged()
end

function QF.OnAddOnLoaded(event, addonName)
  if addonName == QF.name then
    QF.Temp.timeBeforeAddonInit = GetGameTimeMilliseconds()

    EVENT_MANAGER:UnregisterForEvent(QF.name, EVENT_ADD_ON_LOADED)

    QF.SavedVars = ZO_SavedVars:NewCharacterIdSettings("QFSavedVariables", 1, nil, QF.Defaults)
    QF.CSSV = ZO_SavedVars:NewCharacterIdSettings("QFSavedVariables", 1, nil, QF.Defaults) -- Character-specific saved variables
    QF.AWSV = ZO_SavedVars:NewAccountWide("QFSavedVariables", 1, nil, QF.Defaults) -- Account-wide Saved Variables

    if QF.AWSV.accountWide == true then
      QF.SavedVars = ZO_SavedVars:NewAccountWide("QFSavedVariables", 1, nil, QF.Defaults)
    end

    QF.SavedVars.accountWide = QF.AWSV.accountWide
    QF.CSSV.accountWide = QF.AWSV.accountWide

    if not QF.SavedVars.migratedFavsToSortedTable then
      MigrateFavsToSortedTable()
    end

    SLASH_COMMANDS["/qf"] = CommandParse
    SLASH_COMMANDS["/qfavs"] = QF.ToggleFavPanel
    SLASH_COMMANDS["/qfashion"] = QF.ToggleQFPanel
    SLASH_COMMANDS["/qprofiles"] = QF.ToggleQProfilesPanel
    SLASH_COMMANDS["/qrand"] = QF.Randomize
    SLASH_COMMANDS["/qflist"] = QF.ProfileHotkeyListToChat

    SLASH_COMMANDS["/qfdebug"] = QF.Debug

    -- SLASH_COMMANDS["/qftest"] = function() d("Hello :)") end

    ZO_CreateStringId("SI_BINDING_NAME_QUICK_FASHION_TOGGLE_BOTH_PANELS", "Toggle Quick Fashion/Quick Favourites")
    ZO_CreateStringId("SI_BINDING_NAME_QUICK_FASHION_TOGGLE_PANEL", "Toggle Quick Fashion")
    ZO_CreateStringId("SI_BINDING_NAME_QUICK_FAVOURITES_TOGGLE_PANEL", "Toggle Quick Favourites")
    ZO_CreateStringId("SI_BINDING_NAME_QUICK_PROFILES_TOGGLE_PANEL", "Toggle Quick Profiles")
    ZO_CreateStringId("SI_BINDING_NAME_QF_RANDOMIZE_COLLECTIBLES", "|cFF3C4BR|r|cFFAB2Fa|r|cFFCC52n|r|cFFF430d|r|cA8FF52o|r|c01FF25m|r|c60FFD8i|r|c96ACFFz|r|c8E58FFe!|r")
    ZO_CreateStringId("SI_BINDING_NAME_QF_EQUIP_PROFILE_1", "Equip profile 1")
    ZO_CreateStringId("SI_BINDING_NAME_QF_EQUIP_PROFILE_2", "Equip profile 2")
    ZO_CreateStringId("SI_BINDING_NAME_QF_EQUIP_PROFILE_3", "Equip profile 3")
    ZO_CreateStringId("SI_BINDING_NAME_QF_EQUIP_PROFILE_4", "Equip profile 4")
    ZO_CreateStringId("SI_BINDING_NAME_QF_EQUIP_PROFILE_5", "Equip profile 5")
    ZO_CreateStringId("SI_BINDING_NAME_QF_EQUIP_PROFILE_6", "Equip profile 6")
    ZO_CreateStringId("SI_BINDING_NAME_QF_EQUIP_PROFILE_7", "Equip profile 7")
    ZO_CreateStringId("SI_BINDING_NAME_QF_EQUIP_PROFILE_8", "Equip profile 8")
    ZO_CreateStringId("SI_BINDING_NAME_QF_EQUIP_PROFILE_9", "Equip profile 9")
    ZO_CreateStringId("SI_BINDING_NAME_QF_EQUIP_PROFILE_10", "Equip profile 10")

    EVENT_MANAGER:RegisterForEvent(QF.name, EVENT_PLAYER_ACTIVATED, QF.OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(QF.name, EVENT_COLLECTIBLE_UPDATED, OnCollectibleUpdated)
    EVENT_MANAGER:RegisterForEvent(QF.name, EVENT_OUTFIT_EQUIP_RESPONSE, QF.OnOutfitUpdated)
    EVENT_MANAGER:RegisterForEvent(QF.name, EVENT_TITLE_UPDATE, QF.OnTitleUpdated)

    EVENT_MANAGER:RegisterForEvent(QF.name, EVENT_COLLECTIBLE_NOTIFICATION_NEW, OnNewCollectibleAdded)

    EVENT_MANAGER:RegisterForEvent(QF.name, EVENT_CRAFTING_STATION_INTERACT, QF.OnCraftingInteract)
    EVENT_MANAGER:RegisterForEvent(QF.name, EVENT_END_CRAFTING_STATION_INTERACT, QF.OnCraftingInteractEnd)
    EVENT_MANAGER:RegisterForEvent(QF.name, EVENT_PLAYER_SWIMMING, QF.PlayerSwimming)
    EVENT_MANAGER:RegisterForEvent(QF.name, EVENT_PLAYER_NOT_SWIMMING, QF.PlayerNotSwimming)

    EVENT_MANAGER:RegisterForEvent(QF.name, EVENT_ARMORY_BUILD_UPDATED, QF.ArmoryBuildUpdated)
    EVENT_MANAGER:RegisterForEvent(QF.name, EVENT_ARMORY_BUILD_RESTORE_RESPONSE, QF.ArmoryBuildEquipped)

    QF.InitRandomize()
    QF.InitFashionPanel()
    QF.InitAutoOutfitter()
    QF.InitProfiles()
    QF.InitFavourites()
    QF.InitArmory()

    RestorePosition()

    InitToolTips()
    InitLabels()
    DisplayWithCollectionsScene()

    QF.CreateSettingsMenu()

    QF.Temp.timeAfterAddonInit = GetGameTimeMilliseconds()
    QF.Temp.timeForAddonInit =  FormatTimeMilliseconds(QF.Temp.timeAfterAddonInit - QF.Temp.timeBeforeAddonInit, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_MILLISECONDS, TIME_FORMAT_DIRECTION_NONE)

    local CollectiblesByType = QF.SavedVars.OwnedCollectibles
    for collectibleType,_ in pairs(CollectiblesByType) do
      local parentControlName = string.format("QF_Favs_%sGrid", QF.CollectibleTable[collectibleType].controlSuffix)
      local parentControl = WM:GetControlByName(parentControlName)
      local size = parentControl:GetNumChildren()
      QF.Temp.totalIconsInitialized = (QF.Temp.totalIconsInitialized or 0) + size
    end
  end
end

EVENT_MANAGER:RegisterForEvent(QF.name, EVENT_ADD_ON_LOADED, QF.OnAddOnLoaded)
