--this creates a menu for the addon.
--IIfA = IIfA		-- necessary for initial load of the lua script, so it know

local LAM = LibAddonMenu2
local deleteHouse, restoreHouse, deleteChar, selectedGuildBankToDelete, copyChar = nil, nil, nil, nil, nil

local function getGuildBanks()
  local guildBanks = {}
  local serverData = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType]

  if serverData.guildBankInfo then
    for guildName, guildData in pairs(serverData.guildBankInfo) do
      table.insert(guildBanks, guildName)
    end
  end

  return guildBanks
end

local function getGuildBankName(guildNum)
  if guildNum > GetNumGuilds() then return end
  local id = GetGuildId(guildNum)
  return GetGuildName(id)
end

function IIfA:CopyCharacterFrameSettings(characterInfoToCopy)
  if characterInfoToCopy then
    local serverData = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType]
    local characterId = serverData.CharNameToId[characterInfoToCopy]
    local characterData = IIFA_DATABASE[IIfA.currentAccount].characters[characterId]

    if characterData then
      IIFA_DATABASE[IIfA.currentAccount].characters[IIfA.currentCharacterId] = characterData
    end
  end
end

-----------------------------
--- menu helper functions ---
-----------------------------
local function WipeDatabase()
  IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType].DBv3 = {}
  IIfA:ScanCurrentCharacterAndBank()
  IIfA:RefreshInventoryScroll()
end

local function GetGuildBankCollectionSetting(guildNum)
  local guildName = getGuildBankName(guildNum)
  if not guildName then return false end
  local serverData = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType]
  return serverData.guildBankInfo[guildName].bCollectData
end

local function SetGuildBankCollectionSetting(guildNum, newSetting)
  local guildName = getGuildBankName(guildNum)
  if not guildName then return end
  local serverData = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType]
  serverData.guildBankInfo[guildName].bCollectData = newSetting
end

local function SetItemCountPositionSetting(value)
  IIfA:StatusAlert("[IIfA]:ItemCountOnRight[" .. tostring(value) .. "]")
  IIFA_DATABASE[IIfA.currentAccount].settings.showItemCountOnRight = value
  IIfA:SetItemCountPosition()
end

local function SetShowItemStatsSetting(value)
  IIfA:StatusAlert("[IIfA]:ItemStats[" .. tostring(value) .. "]")
  IIFA_DATABASE[IIfA.currentAccount].settings.showItemStats = value
  IIFA_GUI_ListHolder_Counts:SetHidden(not value)
end

local function SetDefaultInventoryFrameView(value)
  IIfA:StatusAlert("[IIfA]:DefaultInventoryFrameView[" .. value .. "]")
  IIFA_DATABASE[IIfA.currentAccount].characters[IIfA.currentCharacterId].defaultInventoryFrameView = value
  ZO_ComboBox_ObjectFromContainer(IIFA_GUI_Header_Dropdown_Main):SetSelectedItem(value)
  IIfA:SetInventoryListFilter(value)
end

local function SetFilterSetNameOnlySetting(value)
  IIFA_DATABASE[IIfA.currentAccount].settings.bFilterOnSetName = value
  IIfA.bFilterOnSetName = value
end

local function SetEnableSearchMenuSetting(value)
  IIFA_DATABASE[IIfA.currentAccount].settings.bAddContextMenuEntrySearchInIIfA = value
  IIfA.bAddContextMenuEntrySearchInIIfA = value
end

local function SetEnableMissingMotifsMenuSetting(value)
  IIFA_DATABASE[IIfA.currentAccount].settings.bAddContextMenuEntryMissingMotifsInIIfA = value
  IIfA.bAddContextMenuEntryMissingMotifsInIIfA = value
end

local function SetHideCloseButtonSetting(value)
  IIFA_DATABASE[IIfA.currentAccount].settings.hideCloseButton = value
  IIfA:StatusAlert("[IIfA]:hideCloseButton[" .. tostring(value) .. "]")
  IIFA_GUI_Header_Hide:SetHidden(value)
end

local function SetCollectGuildBankData(value)
  IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType].bCollectGuildBankData = value
  IIfA.trackedBags[BAG_GUILDBANK] = value
end

local function SetCompanionEquipIgnored(value)
  -- Update the account-wide settings for `ignoreCompanionEquipment`
  IIFA_DATABASE[IIfA.currentAccount].settings.ignoreCompanionEquipment = value

  -- Update tracked bags for companion equipment based on the new value
  IIfA.trackedBags[BAG_COMPANION_WORN] = not value
  if value then
    -- If ignoring companion equipment, clear its associated data
    IIfA:ClearLocationData(BAG_COMPANION_WORN)
    IIfA:ClearBagSlotInfoByBagId(BAG_COMPANION_WORN)
  end
end

local function RestoreHouseTracking()
  if restoreHouse then
    IIfA:SetTrackingForHouse(restoreHouse, true)
    IIfA:RescanHouse()
  end
end

local function GetBagSpaceWarnColor()
  local color = IIFA_DATABASE[IIfA.currentAccount].settings.BagSpaceWarn
  return color.r, color.g, color.b -- Already stored as floats (0.0 to 1.0)
end

local function SetBagSpaceWarnColor(r, g, b)
  local settings = IIFA_DATABASE[IIfA.currentAccount].settings
  settings.BagSpaceWarn.r = r
  settings.BagSpaceWarn.g = g
  settings.BagSpaceWarn.b = b

  IIfA.CharBagFrame.ColorWarn = IIfA:GetColorHexFromTable(settings.BagSpaceWarn)

  IIfA.CharBagFrame:RepaintSpaceUsed()
end

local function GetBagSpaceWarnDefaultColor()
  local color = IIfA.defaults_account.BagSpaceWarn
  local r = color.r
  local g = color.g
  local b = color.b
  return { r = r, g = g, b = b }
end

local function GetBagSpaceAlertColor()
  local color = IIFA_DATABASE[IIfA.currentAccount].settings.BagSpaceAlert
  return color.r, color.g, color.b -- Already stored as floats (0.0 to 1.0)
end

local function SetBagSpaceAlertColor(r, g, b)
  local settings = IIFA_DATABASE[IIfA.currentAccount].settings
  settings.BagSpaceAlert.r = r
  settings.BagSpaceAlert.g = g
  settings.BagSpaceAlert.b = b

  IIfA.CharBagFrame.ColorAlert = IIfA:GetColorHexFromTable(settings.BagSpaceAlert)

  IIfA.CharBagFrame:RepaintSpaceUsed()
end

local function GetBagSpaceAlertDefaultColor()
  local color = IIfA.defaults_account.BagSpaceAlert
  local r = color.r
  local g = color.g
  local b = color.b
  return { r = r, g = g, b = b }
end

local function GetBagSpaceFullColor()
  local color = IIFA_DATABASE[IIfA.currentAccount].settings.BagSpaceFull
  return color.r, color.g, color.b -- Already stored as floats (0.0 to 1.0)
end

local function SetBagSpaceFullColor(r, g, b)
  local settings = IIFA_DATABASE[IIfA.currentAccount].settings
  settings.BagSpaceFull.r = r
  settings.BagSpaceFull.g = g
  settings.BagSpaceFull.b = b

  IIfA.CharBagFrame.ColorFull = IIfA:GetColorHexFromTable(settings.BagSpaceFull)

  IIfA.CharBagFrame:RepaintSpaceUsed()
end

local function GetBagSpaceFullDefaultColor()
  local color = IIfA.defaults_account.BagSpaceFull
  local r = color.r
  local g = color.g
  local b = color.b
  return { r = r, g = g, b = b }
end

local function SetCharacterTooltipColor(r, g, b)
  IIfA.colorHandlerToon:SetRGB(r, g, b)
  IIFA_DATABASE[IIfA.currentAccount].settings.TextColorsToon = IIfA.colorHandlerToon:ToHex()
end

local function GetCharacterTooltipDefaultColor()
  local r, g, b, a = ZO_ColorDef.HexToFloats(IIfA.defaults_account.TextColorsToon)
  return { r = r, g = g, b = b }
end

local function SetCompanionTooltipColor(r, g, b)
  IIfA.colorHandlerCompanion:SetRGB(r, g, b)
  IIFA_DATABASE[IIfA.currentAccount].settings.TextColorsCompanion = IIfA.colorHandlerCompanion:ToHex()
end

local function GetCompanionTooltipDefaultColor()
  local r, g, b, a = ZO_ColorDef.HexToFloats(IIfA.defaults_account.TextColorsCompanion)
  return { r = r, g = g, b = b }
end

local function SetBankTooltipColor(r, g, b)
  IIfA.colorHandlerBank:SetRGBA(r, g, b)
  IIFA_DATABASE[IIfA.currentAccount].settings.TextColorsBank = IIfA.colorHandlerBank:ToHex()
end

local function GetBankTooltipDefaultColor()
  local r, g, b, a = ZO_ColorDef.HexToFloats(IIfA.defaults_account.TextColorsBank)
  return { r = r, g = g, b = b }
end

local function SetGuildBankTooltipColor(r, g, b)
  IIfA.colorHandlerGBank:SetRGBA(r, g, b)
  IIFA_DATABASE[IIfA.currentAccount].settings.TextColorsGBank = IIfA.colorHandlerGBank:ToHex()
end

local function GetGuildBankTooltipDefaultColor()
  local r, g, b, a = ZO_ColorDef.HexToFloats(IIfA.defaults_account.TextColorsGBank)
  return { r = r, g = g, b = b }
end

local function SetHouseChestTooltipColor(r, g, b)
  IIfA.colorHandlerHouseChest:SetRGBA(r, g, b)
  IIFA_DATABASE[IIfA.currentAccount].settings.TextColorsHouseChest = IIfA.colorHandlerHouseChest:ToHex()
end

local function GetHouseChestTooltipDefaultColor()
  local r, g, b, a = ZO_ColorDef.HexToFloats(IIfA.defaults_account.TextColorsHouseChest)
  return { r = r, g = g, b = b }
end

local function SetHouseContentsTooltipColor(r, g, b)
  IIfA.colorHandlerHouse:SetRGBA(r, g, b)
  IIFA_DATABASE[IIfA.currentAccount].settings.TextColorsHouse = IIfA.colorHandlerHouse:ToHex()
end

local function GetHouseContentsTooltipDefaultColor()
  local r, g, b, a = ZO_ColorDef.HexToFloats(IIfA.defaults_account.TextColorsHouse)
  return { r = r, g = g, b = b } -- Always returns a table with `r`, `g`, `b`, `a` keys
end

local function SetCraftBagTooltipColor(r, g, b)
  IIfA.colorHandlerCraftBag:SetRGBA(r, g, b)
  IIFA_DATABASE[IIfA.currentAccount].settings.TextColorsCraftBag = IIfA.colorHandlerCraftBag:ToHex()
end

local function GetCraftBagTooltipDefaultColor()
  local r, g, b, a = ZO_ColorDef.HexToFloats(IIfA.defaults_account.TextColorsCraftBag)
  return { r = r, g = g, b = b } -- Always returns a table with `r`, `g`, `b`, `a` keys
end

local function SetTooltipFontFace(value)
  IIfA:StatusAlert("[IIfA]:TooltipFontFaceChanged[" .. value .. "]")
  IIFA_DATABASE[IIfA.currentAccount].settings.TooltipFontFace = value
  IIfA:SetTooltipFont()
end

local function SetTooltipFontSize(value)
  IIfA:StatusAlert("[IIfA]:TooltipFontSizeChanged[" .. value .. "]")
  IIFA_DATABASE[IIfA.currentAccount].settings.TooltipFontSize = value
  IIfA:SetTooltipFont()
end

local function SetTooltipFontEffect(value)
  IIFA_DATABASE[IIfA.currentAccount].settings.TooltipFontEffect = value
  IIfA:StatusAlert("[IIfA]:TooltipFontEffectChanged[" .. value .. "]")
  IIfA:SetTooltipFont()
end

-----------------------------
---       menu setup      ---
-----------------------------
function IIfA:CreateOptionsMenu()
  local function SetRestoreHouse(choice)
    restoreHouse = choice
  end
  local function SetDeleteHouse(choice)
    deleteHouse = choice
  end
  local function SetDeleteChar(choice)
    deleteChar = choice
  end
  local function SetSelectedGuildBankToDelete(choice)
    selectedGuildBankToDelete = choice
  end
  local function SetCopyChar(choice)
    copyChar = choice
  end
  local optionsData = {}
  local manageCollectedDataIndex = #optionsData + 1
  optionsData[manageCollectedDataIndex] = {
    type = "submenu",
    name = GetString(IIFA_MANAGE_DATA_SUBMENU),
    tooltip = GetString(IIFA_MANAGE_DATA_SUBMENU_TT),
    controls = {}
  }
  local manageCollectedDataControls = optionsData[manageCollectedDataIndex].controls
  manageCollectedDataControls[#manageCollectedDataControls + 1] = {
    type = "header",
    name = GetString(IIFA_WIPE_DATABASE_HEADER),
  }
  manageCollectedDataControls[#manageCollectedDataControls + 1] = {
    type = "description",
    text = GetString(IIFA_WIPE_DATABASE_DESC),
  }
  manageCollectedDataControls[#manageCollectedDataControls + 1] = {
    type = "button",
    name = GetString(IIFA_WIPE_DATABASE_BUTTON),
    tooltip = GetString(IIFA_WIPE_DATABASE_BUTTON_TT),
    func = function() WipeDatabase() end,
  }
  manageCollectedDataControls[#manageCollectedDataControls + 1] = {
    type = "header",
    name = GetString(IIFA_IGNORE_OPTIONS_HEADER),
  }
  manageCollectedDataControls[#manageCollectedDataControls + 1] = {
    type = "description",
    text = GetString(IIFA_IGNORE_OPTIONS_DESC),
  }
  manageCollectedDataControls[#manageCollectedDataControls + 1] = {
    type = "checkbox",
    name = GetString(IIFA_DATA_IGNORE_BACKPACK),
    tooltip = GetString(IIFA_DATA_IGNORE_BACKPACK_TT),
    getFunc = function() return IIfA:IsCharacterInventoryIgnored() end,
    setFunc = function(value) IIfA:IgnoreCharacterInventory(value) end,
  }
  manageCollectedDataControls[#manageCollectedDataControls + 1] = {
    type = "checkbox",
    name = GetString(IIFA_DATA_IGNORE_EQUIPMENT),
    tooltip = GetString(IIFA_DATA_IGNORE_EQUIPMENT_TT),
    getFunc = function() return IIfA:IsCharacterEquipIgnored() end,
    setFunc = function(value) IIfA:IgnoreCharacterEquip(value) end,
  }
  manageCollectedDataControls[#manageCollectedDataControls + 1] = {
    type = "checkbox",
    name = GetString(IIFA_DATA_IGNORE_COMPANION_EQUIPMENT),
    tooltip = GetString(IIFA_DATA_IGNORE_COMPANION_EQUIPMENT_TT),
    getFunc = function() return IIFA_DATABASE[IIfA.currentAccount].settings.ignoreCompanionEquipment end,
    setFunc = function(value) SetCompanionEquipIgnored(value) end,
    default = IIfA.defaults_server.ignoreCompanionEquipment,
  }
  manageCollectedDataControls[#manageCollectedDataControls + 1] = {
    type = "header",
    name = GetString(IIFA_DELETE_CHAR_DATA_HEADER),
  }
  manageCollectedDataControls[#manageCollectedDataControls + 1] = {
    type = "description",
    text = GetString(IIFA_DELETE_CHAR_DATA_DESC),
  }
  manageCollectedDataControls[#manageCollectedDataControls + 1] = {
    type = "dropdown",
    name = GetString(IIFA_DATA_DELETE_CHARACTER_DROPDOWN),
    choices = IIfA:GetCharacterList(),
    scrollable = true,
    getFunc = function() return end,
    setFunc = function(choice) SetDeleteChar(choice) end,
  }
  manageCollectedDataControls[#manageCollectedDataControls + 1] = {
    type = "button",
    name = GetString(IIFA_DATA_DELETE_CHARACTER),
    tooltip = GetString(IIFA_DATA_DELETE_CHARACTER_TT),
    func = function() IIfA:DeleteCharacterData(deleteChar) end,
  }
  manageCollectedDataControls[#manageCollectedDataControls + 1] = {
    type = "header",
    name = GetString(IIFA_GUILDBANK_DELETE_HEADER),
  }
  manageCollectedDataControls[#manageCollectedDataControls + 1] = {
    type = "description",
    text = GetString(IIFA_GUILDBANK_DELETE_DESC),
  }
  manageCollectedDataControls[#manageCollectedDataControls + 1] = {
    type = "dropdown",
    name = GetString(IIFA_DATA_GUILDBANK_TO_DELETE),
    choices = getGuildBanks(),
    getFunc = function() return end,
    setFunc = function(choice) SetSelectedGuildBankToDelete(choice) end,
  }
  manageCollectedDataControls[#manageCollectedDataControls + 1] = {
    type = "button",
    name = GetString(IIFA_DATA_GUILDBANK_DELETE),
    tooltip = GetString(IIFA_DATA_GUILDBANK_DELETE_TT),
    func = function() IIfA:DeleteGuildData(selectedGuildBankToDelete) end,
  }

  local guildBankOptions = #optionsData + 1
  optionsData[guildBankOptions] = {
    type = "submenu",
    name = GetString(IIFA_DATA_GUILDBANK_OPTIONS),
    tooltip = GetString(IIFA_DATA_GUILDBANK_OPTIONS_TT),
    controls = {}
  }

  local housingOptionsIndex = #optionsData + 1
  optionsData[housingOptionsIndex] = {
    type = "submenu",
    name = GetString(IIFA_HOUSES_SUBMENU_TITLE),
    controls = {}
  }
  local housingControls = optionsData[housingOptionsIndex].controls
  housingControls[#housingControls + 1] = {
    type = "header",
    name = GetString(IIFA_FURNITURE_COLLECTION_HEADER),
  }
  housingControls[#housingControls + 1] = {
    type = "description",
    text = GetString(IIFA_HOUSING_COLLECTION_DESC),
  }
  housingControls[#housingControls + 1] = {
    type = "checkbox",
    name = GetString(IIFA_DATA_COLLECT_OPTIONS),
    tooltip = GetString(IIFA_DATA_COLLECT_OPTIONS_TT),
    getFunc = function() return IIfA:GetHouseTracking() end,
    setFunc = function(value) IIfA:SetHouseTracking(value) end,
    default = IIfA.defaults_account.b_collectHouses,
  }
  housingControls[#housingControls + 1] = {
    type = "header",
    name = GetString(IIFA_FURNITURE_COLLECTION_IGNORE_HEADER),
  }
  housingControls[#housingControls + 1] = {
    type = "description",
    text = GetString(IIFA_DATA_IGNORE_HOUSES_DESC),
  }
  housingControls[#housingControls + 1] = {
    type = "dropdown",
    name = GetString(IIFA_DATA_HOUSES_TO_DELETE_DROPDOWN),
    choices = IIfA:GetTrackedHouseNames(),
    scrollable = true,
    getFunc = function() return end,
    setFunc = function(choice) SetDeleteHouse(choice) end,
  }
  housingControls[#housingControls + 1] = {
    type = "button",
    name = GetString(IIFA_DATA_HOUSES_DELETE),
    tooltip = GetString(IIFA_DATA_HOUSES_DELETE_TT),
    func = function() IIfA:SetTrackingForHouse(deleteHouse, false) end,
  }
  housingControls[#housingControls + 1] = {
    type = "header",
    name = GetString(IIFA_DATA_HOUSES_UNIGNORE_HEADER),
  }
  housingControls[#housingControls + 1] = {
    type = "description",
    text = GetString(IIFA_DATA_HOUSES_UNIGNORE_DESC),
  }
  housingControls[#housingControls + 1] = {
    type = "dropdown",
    name = GetString(IIFA_DATA_HOUSES_UNIGNORE_DROPDOWN),
    choices = IIfA:GetIgnoredHouseNames(),
    scrollable = true,
    getFunc = function() return end,
    setFunc = function(choice) SetRestoreHouse(choice) end,
  }
  housingControls[#housingControls + 1] = {
    type = "button",
    name = GetString(IIFA_DATA_HOUSES_UNIGNORE_BUTTON),
    tooltip = GetString(IIFA_DATA_HOUSES_UNIGNORE_BUTTON_TT),
    func = function() RestoreHouseTracking() end,
  }

  local packHighlightIndex = #optionsData + 1
  optionsData[packHighlightIndex] = {
    type = "submenu",
    name = GetString(IIFA_HIGHLIT_PACK_SIZE_DESC),
    tooltip = GetString(IIFA_HIGHLIT_PACK_SIZE_TT),
    controls = {}
  }
  local packHighlightControls = optionsData[packHighlightIndex].controls
  packHighlightControls[#packHighlightControls + 1] = {
    type = "slider",
    name = GetString(IIFA_USED_SPACE_THRESHOLD),
    tooltip = GetString(IIFA_USED_SPACE_THRESHOLD_TT),
    getFunc = function() return IIFA_DATABASE[IIfA.currentAccount].settings.BagSpaceWarn.threshold end,
    setFunc = function(value) IIFA_DATABASE[IIfA.currentAccount].settings.BagSpaceWarn.threshold = value end,
    min = 1,
    max = 100,
    step = 1,
    clampInput = true,
    decimals = 0,
    default = IIfA.defaults_account.BagSpaceWarn.threshold,
  }
  packHighlightControls[#packHighlightControls + 1] = {
    type = "colorpicker",
    name = GetString(IIFA_USED_SPACE_COLOR),
    tooltip = GetString(IIFA_USED_SPACE_COLOR_TT),
    getFunc = function() return GetBagSpaceWarnColor() end,
    setFunc = function(r, g, b) SetBagSpaceWarnColor(r, g, b) end,
    default = GetBagSpaceWarnDefaultColor(),
  }
  packHighlightControls[#packHighlightControls + 1] = {
    type = "slider",
    name = GetString(IIFA_ALERT_SPACE_THRESHOLD),
    tooltip = GetString(IIFA_ALERT_SPACE_THRESHOLD_TT),
    getFunc = function() return IIFA_DATABASE[IIfA.currentAccount].settings.BagSpaceAlert.threshold end,
    setFunc = function(choice) IIFA_DATABASE[IIfA.currentAccount].settings.BagSpaceAlert.threshold = choice end,
    min = 1,
    max = 100,
    step = 1,
    clampInput = true,
    decimals = 0,
    default = IIfA.defaults_account.BagSpaceAlert.threshold,
  }
  packHighlightControls[#packHighlightControls + 1] = {
    type = "colorpicker",
    name = GetString(IIFA_ALERT_SPACE_COLOR),
    tooltip = GetString(IIFA_ALERT_SPACE_COLOR_TT),
    getFunc = function() return GetBagSpaceAlertColor() end,
    setFunc = function(r, g, b) SetBagSpaceAlertColor(r, g, b) end,
    default = GetBagSpaceAlertDefaultColor(),
  }
  packHighlightControls[#packHighlightControls + 1] = {
    type = "colorpicker",
    name = GetString(IIFA_USED_SPACE_FULL_COLOR),
    tooltip = GetString(IIFA_USED_SPACE_FULL_COLOR_TT),
    getFunc = function() return GetBagSpaceFullColor() end,
    setFunc = function(r, g, b) SetBagSpaceFullColor(r, g, b) end,
    default = GetBagSpaceFullDefaultColor(),
  }

  local sceneOptionsIndex = #optionsData + 1
  optionsData[sceneOptionsIndex] = {
    type = "submenu",
    name = GetString(IIFA_MANAGE_SCENE_CONTROLS),
    tooltip = GetString(IIFA_MANAGE_SCENE_CONTROLS_TT),
    controls = {}
  }
  local sceneControls = optionsData[sceneOptionsIndex].controls
  sceneControls[#sceneControls + 1] = {
    type = "header",
    name = GetString(IIFA_COPY_CHARACTER_HEADER),
  }
  sceneControls[#sceneControls + 1] = {
    type = "description",
    text = GetString(IIFA_COPY_CHARACTER_DESC),
  }
  sceneControls[#sceneControls + 1] = {
    type = "dropdown",
    name = GetString(IIFA_COPY_CHARACTER_DROPDOWN),
    choices = IIfA:GetCharacterList(),
    scrollable = true,
    getFunc = function() return end,
    setFunc = function(choice) SetCopyChar(choice) end,
  }
  sceneControls[#sceneControls + 1] = {
    type = "button",
    name = GetString(IIFA_COPY_CHARACTER_BUTTON),
    tooltip = GetString(IIFA_COPY_CHARACTER_BUTTON_TT),
    func = function() IIfA:CopyCharacterFrameSettings(copyChar) end,
  }
  sceneControls[#sceneControls + 1] = {
    type = "header",
    name = GetString(IIFA_KEYBOARD_SCENE_TOGGLES),
  }
  sceneControls[#sceneControls + 1] = {
    type = "checkbox",
    name = GetString(IIFA_SCENE_TOGGLE_INVENTORY),
    tooltip = GetString(IIFA_SCENE_TOGGLE_INVENTORY_TT),
    getFunc = function() return IIfA:GetSceneVisible("inventory") end,
    setFunc = function(value) IIfA:SetSceneVisible("inventory", value) end,
    default = not IIfA.defaults_character.frameSettings.inventory.hidden,
  }
  sceneControls[#sceneControls + 1] = {
    type = "checkbox",
    name = GetString(IIFA_SCENE_TOGGLE_BANK),
    tooltip = GetString(IIFA_SCENE_TOGGLE_BANK_TT),
    getFunc = function() return IIfA:GetSceneVisible("bank") end,
    setFunc = function(value) IIfA:SetSceneVisible("bank", value) end,
    default = not IIfA.defaults_character.frameSettings.bank.hidden,
  }
  sceneControls[#sceneControls + 1] = {
    type = "checkbox",
    name = GetString(IIFA_SCENE_TOGGLE_GUILDBANK),
    tooltip = GetString(IIFA_SCENE_TOGGLE_GUILDBANK_TT),
    getFunc = function() return IIfA:GetSceneVisible("guildBank") end,
    setFunc = function(value) IIfA:SetSceneVisible("guildBank", value) end,
    default = not IIfA.defaults_character.frameSettings.guildBank.hidden,
  }
  sceneControls[#sceneControls + 1] = {
    type = "checkbox",
    name = GetString(IIFA_SCENE_TOGGLE_GUILDSTORE),
    tooltip = GetString(IIFA_SCENE_TOGGLE_GUILDSTORE_TT),
    getFunc = function() return IIfA:GetSceneVisible("tradinghouse") end,
    setFunc = function(value) IIfA:SetSceneVisible("tradinghouse", value) end,
    default = not IIfA.defaults_character.frameSettings.tradinghouse.hidden,
  }
  sceneControls[#sceneControls + 1] = {
    type = "checkbox",
    name = GetString(IIFA_SCENE_TOGGLE_CRAFTING),
    tooltip = GetString(IIFA_SCENE_TOGGLE_CRAFTING_TT),
    getFunc = function() return IIfA:GetSceneVisible("smithing") end,
    setFunc = function(value) IIfA:SetSceneVisible("smithing", value) end,
    default = not IIfA.defaults_character.frameSettings.smithing.hidden,
  }
  sceneControls[#sceneControls + 1] = {
    type = "checkbox",
    name = GetString(IIFA_SCENE_TOGGLE_ALCHEMY),
    tooltip = GetString(IIFA_SCENE_TOGGLE_ALCHEMY_TT),
    getFunc = function() return IIfA:GetSceneVisible("alchemy") end,
    setFunc = function(value) IIfA:SetSceneVisible("alchemy", value) end,
    default = not IIfA.defaults_character.frameSettings.alchemy.hidden,
  }
  sceneControls[#sceneControls + 1] = {
    type = "checkbox",
    name = GetString(IIFA_SCENE_TOGGLE_VENDOR),
    tooltip = GetString(IIFA_SCENE_TOGGLE_VENDOR_TT),
    getFunc = function() return IIfA:GetSceneVisible("store") end,
    setFunc = function(value) IIfA:SetSceneVisible("store", value) end,
    default = not IIfA.defaults_character.frameSettings.store.hidden,
  }
  sceneControls[#sceneControls + 1] = {
    type = "checkbox",
    name = GetString(IIFA_SCENE_TOGGLE_STABLES),
    tooltip = GetString(IIFA_SCENE_TOGGLE_STABLES_TT),
    getFunc = function() return IIfA:GetSceneVisible("stables") end,
    setFunc = function(value) IIfA:SetSceneVisible("stables", value) end,
    default = not IIfA.defaults_character.frameSettings.stables.hidden,
  }
  sceneControls[#sceneControls + 1] = {
    type = "checkbox",
    name = GetString(IIFA_SCENE_TOGGLE_TRADING),
    tooltip = GetString(IIFA_SCENE_TOGGLE_TRADING_TT),
    getFunc = function() return IIfA:GetSceneVisible("trade") end,
    setFunc = function(value) IIfA:SetSceneVisible("trade", value) end,
    default = not IIfA.defaults_character.frameSettings.trade.hidden,
  }
  sceneControls[#sceneControls + 1] = {
    type = "header",
    name = GetString(IIFA_GAMEPAD_SCENE_TOGGLES),
  }
  sceneControls[#sceneControls + 1] = {
    type = "checkbox",
    name = GetString(IIFA_GAMEPAD_SCENE_TOGGLE_INVENTORY),
    tooltip = GetString(IIFA_GAMEPAD_SCENE_TOGGLE_INVENTORY_TT),
    getFunc = function() return IIfA:GetSceneVisible("gamepad_inventory_root") end,
    setFunc = function(value) IIfA:SetSceneVisible("gamepad_inventory_root", value) end,
    default = not IIfA.defaults_character.frameSettings.gamepad_inventory_root.hidden,
  }
  sceneControls[#sceneControls + 1] = {
    type = "checkbox",
    name = GetString(IIFA_GAMEPAD_SCENE_TOGGLE_BANK),
    tooltip = GetString(IIFA_GAMEPAD_SCENE_TOGGLE_BANK_TT),
    getFunc = function() return IIfA:GetSceneVisible("gamepad_banking") end,
    setFunc = function(value) IIfA:SetSceneVisible("gamepad_banking", value) end,
    default = not IIfA.defaults_character.frameSettings.gamepad_banking.hidden,
  }
  sceneControls[#sceneControls + 1] = {
    type = "checkbox",
    name = GetString(IIFA_GAMEPAD_SCENE_TOGGLE_VENDOR),
    tooltip = GetString(IIFA_GAMEPAD_SCENE_TOGGLE_VENDOR_TT),
    getFunc = function() return IIfA:GetSceneVisible("gamepad_store") end,
    setFunc = function(value) IIfA:SetSceneVisible("gamepad_store", value) end,
    default = not IIfA.defaults_character.frameSettings.gamepad_store.hidden,
  }  -- options data end

  local tooltipOptionsIndex = #optionsData + 1
  optionsData[tooltipOptionsIndex] = {
    type = "submenu",
    name = GetString(IIFA_MANAGE_TOOLTIPS),
    tooltip = GetString(IIFA_MANAGE_TOOLTIPS_TT),
    controls = {}
  }
  local tooltipControls = optionsData[tooltipOptionsIndex].controls
  local showTooltipChoices = { GetString(IIFA_MANAGE_TOOLTIP_SHOW_ALWAYS), GetString(IIFA_MANAGE_TOOLTIP_SHOW_IIFA), GetString(IIFA_MANAGE_TOOLTIP_SHOW_NEVER) }
  tooltipControls[#tooltipControls + 1] = {
    type = "dropdown",
    name = GetString(IIFA_MANAGE_TOOLTIP_SHOW),
    tooltip = GetString(IIFA_MANAGE_TOOLTIP_SHOW_TT),
    choices = showTooltipChoices,
    getFunc = function() return IIFA_DATABASE[IIfA.currentAccount].settings.showToolTipWhen end,
    setFunc = function(value) IIFA_DATABASE[IIfA.currentAccount].settings.showToolTipWhen = value end,
    default = IIfA.defaults_account.showToolTipWhen,
  }
  tooltipControls[#tooltipControls + 1] = {
    type = "checkbox",
    name = GetString(IIFA_SHOW_SEPARATE_FRAME),
    tooltip = GetString(IIFA_SHOW_SEPARATE_FRAME_TT),
    getFunc = function() return IIFA_DATABASE[IIfA.currentAccount].settings.bInSeparateFrame end,
    setFunc = function(value) IIFA_DATABASE[IIfA.currentAccount].settings.bInSeparateFrame = value end,
    default = IIfA.defaults_account.bInSeparateFrame,
  }
  tooltipControls[#tooltipControls + 1] = {
    type = "checkbox",
    name = GetString(IIFA_SHOW_STYLE_INFO),
    tooltip = GetString(IIFA_SHOW_STYLE_INFO_TT),
    getFunc = function() return IIFA_DATABASE[IIfA.currentAccount].settings.showStyleInfo end,
    setFunc = function(value) IIFA_DATABASE[IIfA.currentAccount].settings.showStyleInfo = value end,
    default = IIfA.defaults_account.showStyleInfo,
  }
  tooltipControls[#tooltipControls + 1] = {
    type = "checkbox",
    name = GetString(IIFA_ALWAYS_STYLE_MAT),
    tooltip = GetString(IIFA_ALWAYS_STYLE_MAT_TT),
    getFunc = function() return IIFA_DATABASE[IIfA.currentAccount].settings.alwaysUseStyleMaterial end,
    setFunc = function(value) IIFA_DATABASE[IIfA.currentAccount].settings.alwaysUseStyleMaterial = value end,
    disabled = function() return not IIFA_DATABASE[IIfA.currentAccount].settings.showStyleInfo end,
    default = IIfA.defaults_account.alwaysUseStyleMaterial,
  }
  tooltipControls[#tooltipControls + 1] = {
    type = "colorpicker",
    name = GetString(IIFA_TOOLTIP_COLOR_CHARACTERS),
    tooltip = GetString(IIFA_TOOLTIP_COLOR_CHARACTERS_TT),
    getFunc = function() return IIfA.colorHandlerToon:UnpackRGB() end,
    setFunc = function(r, g, b) SetCharacterTooltipColor(r, g, b) end,
    default = GetCharacterTooltipDefaultColor,
  }
  tooltipControls[#tooltipControls + 1] = {
    type = "colorpicker",
    name = GetString(IIFA_TOOLTIP_COLOR_COMPANIONS),
    tooltip = GetString(IIFA_TOOLTIP_COLOR_COMPANIONS_TT),
    getFunc = function() return IIfA.colorHandlerCompanion:UnpackRGBA() end,
    setFunc = function(r, g, b) SetCompanionTooltipColor(r, g, b) end,
    default = GetCompanionTooltipDefaultColor,
  }
  tooltipControls[#tooltipControls + 1] = {
    type = "colorpicker",
    name = GetString(IIFA_TOOLTIP_COLOR_BANKS),
    tooltip = GetString(IIFA_TOOLTIP_COLOR_BANKS_TT),
    getFunc = function() return IIfA.colorHandlerBank:UnpackRGBA() end,
    setFunc = function(r, g, b) SetBankTooltipColor(r, g, b) end,
    default = GetBankTooltipDefaultColor,
  }
  tooltipControls[#tooltipControls + 1] = {
    type = "colorpicker",
    name = GetString(IIFA_TOOLTIP_COLOR_GUILDBANKS),
    tooltip = GetString(IIFA_TOOLTIP_COLOR_GUILDBANKS_TT),
    getFunc = function() return IIfA.colorHandlerGBank:UnpackRGBA() end,
    setFunc = function(r, g, b) SetGuildBankTooltipColor(r, g, b) end,
    default = GetGuildBankTooltipDefaultColor,
  }
  tooltipControls[#tooltipControls + 1] = {
    type = "colorpicker",
    name = GetString(IIFA_TOOLTIP_COLOR_HOUSECHESTS),
    tooltip = GetString(IIFA_TOOLTIP_COLOR_HOUSECHESTS_TT),
    getFunc = function() return IIfA.colorHandlerHouseChest:UnpackRGBA() end,
    setFunc = function(r, g, b) SetHouseChestTooltipColor(r, g, b) end,
    default = GetHouseChestTooltipDefaultColor,
  }
  tooltipControls[#tooltipControls + 1] = {
    type = "colorpicker",
    name = GetString(IIFA_TOOLTIP_COLOR_HOUSE_CONTENTS),
    tooltip = GetString(IIFA_TOOLTIP_COLOR_HOUSE_CONTENTS_TT),
    getFunc = function() return IIfA.colorHandlerHouse:UnpackRGBA() end,
    setFunc = function(r, g, b) SetHouseContentsTooltipColor(r, g, b) end,
    default = GetHouseContentsTooltipDefaultColor,
  }
  tooltipControls[#tooltipControls + 1] = {
    type = "colorpicker",
    name = GetString(IIFA_TOOLTIP_COLOR_CRAFT_BAG),
    tooltip = GetString(IIFA_TOOLTIP_COLOR_CRAFT_BAG_TT),
    getFunc = function() return IIfA.colorHandlerCraftBag:UnpackRGBA() end,
    setFunc = function(r, g, b) SetCraftBagTooltipColor(r, g, b) end,
    default = GetCraftBagTooltipDefaultColor,
  }
  tooltipControls[#tooltipControls + 1] = {
    type = "dropdown",
    name = GetString(IIFA_TOOLTIP_FONT_CUSTOM),
    tooltip = GetString(IIFA_TOOLTIP_FONT_CUSTOM_TT),
    choices = IIfA.fontListChoices,
    scrollable = true,
    getFunc = function() return IIFA_DATABASE[IIfA.currentAccount].settings.TooltipFontFace or IIfA.defaults_account.TooltipFontFace end,
    setFunc = function(value) SetTooltipFontFace(value) end,
    default = IIfA.defaults_account.TooltipFontFace, -- Corrected reference
  }
  tooltipControls[#tooltipControls + 1] = {
    type = "slider",
    name = GetString(IIFA_TOOLTIP_FONT_SIZE),
    tooltip = GetString(IIFA_TOOLTIP_FONT_SIZE_TT),
    min = 5,
    max = 40,
    step = 1,
    getFunc = function() return IIFA_DATABASE[IIfA.currentAccount].settings.TooltipFontSize or IIfA.defaults_account.TooltipFontSize end,
    setFunc = function(value) SetTooltipFontSize(value) end,
    default = IIfA.defaults_account.TooltipFontSize, -- Corrected reference
  }
  tooltipControls[#tooltipControls + 1] = {
    type = "dropdown",
    name = GetString(IIFA_TOOLTIP_FONT_EFFECT),
    tooltip = GetString(IIFA_TOOLTIP_FONT_EFFECT_TT),
    choices = IIfA.fontStyleChoices,
    getFunc = function() return IIFA_DATABASE[IIfA.currentAccount].settings.TooltipFontEffect or IIfA.defaults_account.TooltipFontEffect end,
    setFunc = function(value) SetTooltipFontEffect(value) end,
    default = IIfA.defaults_account.TooltipFontEffect, -- Corrected reference
  }

  optionsData[#optionsData + 1] = {
    type = "header",
    name = GetString(IIFA_WINDOW_SETTINGS_HEADER),
  }
  optionsData[#optionsData + 1] = {
    type = "checkbox",
    name = GetString(IIFA_SHOW_ITEM_COUNT_RIGHT),
    tooltip = GetString(IIFA_SHOW_ITEM_COUNT_RIGHT_TT),
    getFunc = function() return IIFA_DATABASE[IIfA.currentAccount].settings.showItemCountOnRight end,
    setFunc = function(value) SetItemCountPositionSetting(value) end,
    default = IIfA.defaults_account.showItemCountOnRight,
  }
  optionsData[#optionsData + 1] = {
    type = "checkbox",
    name = GetString(IIFA_SHOW_STATS_BELOW_LIST),
    tooltip = GetString(IIFA_SHOW_STATS_BELOW_LIST_TT),
    getFunc = function() return IIFA_DATABASE[IIfA.currentAccount].settings.showItemStats end,
    setFunc = function(value) SetShowItemStatsSetting(value) end,
    default = IIfA.defaults_account.showItemStats,
  }
  optionsData[#optionsData + 1] = {
    type = "dropdown",
    name = GetString(IIFA_DEFAULT_INVENTORY_FRAME_VIEW),
    tooltip = GetString(IIFA_DEFAULT_INVENTORY_FRAME_VIEW_TT),
    choices = IIfA.dropdownLocNames,
    scrollable = true,
    getFunc = function() return IIFA_DATABASE[IIfA.currentAccount].characters[IIfA.currentCharacterId].defaultInventoryFrameView end,
    setFunc = function(value) SetDefaultInventoryFrameView(value) end,
    default = IIfA.defaults_character.defaultInventoryFrameView,
  }
  optionsData[#optionsData + 1] = {
    type = "checkbox",
    name = GetString(IIFA_FOCUS_STATS_SEARCHBOX),
    tooltip = GetString(IIFA_FOCUS_STATS_SEARCHBOX_TT),
    getFunc = function() return IIFA_DATABASE[IIfA.currentAccount].settings.dontFocusSearch end,
    setFunc = function(value) IIFA_DATABASE[IIfA.currentAccount].settings.dontFocusSearch = not value end,
    default = not IIfA.defaults_account.dontFocusSearch,
  }
  optionsData[#optionsData + 1] = {
    type = "checkbox",
    name = GetString(IIFA_FILTER_INCLUDE_SETNAME),
    tooltip = GetString(IIFA_FILTER_INCLUDE_SETNAME_TT),
    getFunc = function() return IIFA_DATABASE[IIfA.currentAccount].settings.bFilterOnSetNameToo end,
    setFunc = function(value) IIFA_DATABASE[IIfA.currentAccount].settings.bFilterOnSetNameToo = value end,
    default = IIfA.defaults_account.bFilterOnSetNameToo,
  }
  optionsData[#optionsData + 1] = {
    type = "checkbox",
    name = GetString(IIFA_FILTER_SETNAME_ONLY),
    tooltip = GetString(IIFA_FILTER_SETNAME_ONLY_TT),
    getFunc = function() return IIFA_DATABASE[IIfA.currentAccount].settings.bFilterOnSetName end,
    setFunc = function(value) SetFilterSetNameOnlySetting(value) end,
    disabled = function() return not IIFA_DATABASE[IIfA.currentAccount].settings.bFilterOnSetNameToo end,
    default = IIfA.defaults_account.bFilterOnSetName,
  }
  optionsData[#optionsData + 1] = {
    type = "checkbox",
    name = GetString(IIFA_ENABLE_SEARCH_IIFA_MENU),
    tooltip = GetString(IIFA_ENABLE_SEARCH_IIFA_MENU_TT),
    getFunc = function() return IIFA_DATABASE[IIfA.currentAccount].settings.bAddContextMenuEntrySearchInIIfA end,
    setFunc = function(value) SetEnableSearchMenuSetting(value) end,
    requiresReload = true,
    default = IIfA.defaults_account.bAddContextMenuEntrySearchInIIfA,
  }
  optionsData[#optionsData + 1] = {
    type = "checkbox",
    name = GetString(IIFA_ENABLE_MISSING_MOTIF_IIFA_MENU),
    tooltip = GetString(IIFA_ENABLE_MISSING_MOTIF_IIFA_MENU_TT),
    getFunc = function() return IIFA_DATABASE[IIfA.currentAccount].settings.bAddContextMenuEntryMissingMotifsInIIfA end,
    setFunc = function(value) SetEnableMissingMotifsMenuSetting(value) end,
    default = IIfA.defaults_account.bAddContextMenuEntryMissingMotifsInIIfA,
  }
  optionsData[#optionsData + 1] = {
    type = "checkbox",
    name = GetString(IIFA_HIDE_CLOSE_BUTTON),
    tooltip = GetString(IIFA_HIDE_CLOSE_BUTTON_TT),
    getFunc = function() return IIFA_DATABASE[IIfA.currentAccount].settings.hideCloseButton or false end,
    setFunc = function(value) SetHideCloseButtonSetting(value) end,
    default = IIfA.defaults_account.hideCloseButton,
  }

  if FCOIS then
    optionsData[#optionsData + 1] = --Other addons
    {
      type = "header",
      name = GetString(IIFA_OTHER_ADDONS_HEADER),
    }
    optionsData[#optionsData + 1] = {
      type = "submenu",
      name = GetString(IIFA_FCOITEMSAVER_MENU_MANAGE_SETTINGS),
      tooltip = GetString(IIFA_FCOITEMSAVER_MENU_MANAGE_SETTINGS_TT),
      controls = {
        {
          type = "checkbox",
          name = GetString(IIFA_FCOITEMSAVER_MENU_SHOW_MARKERS),
          tooltip = GetString(IIFA_FCOITEMSAVER_MENU_SHOW_MARKERS_TT),
          getFunc = function() return IIFA_DATABASE[IIfA.currentAccount].settings.FCOISshowMarkerIcons end,
          setFunc = function(value) IIFA_DATABASE[IIfA.currentAccount].settings.FCOISshowMarkerIcons = value end,
          default = IIfA.defaults_account.FCOISshowMarkerIcons,
        },
      },
    }
  end

  optionsData[#optionsData + 1] = {
    type = "header",
    name = GetString(IIFA_MISC_HEADER),
  }
  optionsData[#optionsData + 1] = {
    type = "slider",
    name = GetString(IIFA_REFRESH_DELAY_NAME),
    tooltip = GetString(IIFA_REFRESH_DELAY_TT),
    min = 250,
    max = 3000,
    step = 250,
    getFunc = function() return IIFA_DATABASE[IIfA.currentAccount].settings.refreshDelay or IIfA.defaults_account.refreshDelay end,
    setFunc = function(value) IIFA_DATABASE[IIfA.currentAccount].settings.refreshDelay = value end,
    default = IIfA.defaults_account.refreshDelay, -- Corrected reference
  }

  optionsData[#optionsData + 1] = {
    type = "header",
    name = GetString(IIFA_DEBUGGING_HEADER),
  }
  optionsData[#optionsData + 1] = {
    type = "checkbox",
    name = GetString(IIFA_DEBUGGING_NAME),
    tooltip = GetString(IIFA_DEBUGGING_TT),
    getFunc = function() return IIFA_DATABASE[IIfA.currentAccount].settings.bDebug end,
    setFunc = function(value) IIFA_DATABASE[IIfA.currentAccount].settings.bDebug = value end,
    default = IIfA.defaults_account.bDebug,
  }

  -- run through list of options, find one with empty controls, add in the submenu for guild banks options
  for index, data in ipairs(optionsData) do
    if index == guildBankOptions then
      data.controls[1] = {
        type = "checkbox",
        name = GetString(IIFA_DATA_GUILDBANK_COLLECT_DATA),
        tooltip = GetString(IIFA_DATA_GUILDBANK_COLLECT_DATA_TT),
        warning = GetString(IIFA_DATA_GUILDBANK_COLLECT_DATA_WARN),
        getFunc = function() return IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType].bCollectGuildBankData end,
        setFunc = function(value) SetCollectGuildBankData(value) end,
        default = IIfA.defaults_server[IIfA.currentServerType].bCollectGuildBankData,
      }
      for i = 1, GetNumGuilds() do
        local id = GetGuildId(i)
        local guildName = GetGuildName(id)
        data.controls[i + 1] = {
          type = "checkbox",
          name = string.format(GetString(IIFA_DATA_COLLECT_DATA_FOR), guildName),
          tooltip = GetString(IIFA_DATA_COLLECT_GUILDBANKS_DATA_TT),
          warning = GetString(IIFA_DATA_COLLECT_GUILDBANKS_DATA_WARN),
          getFunc = function() return GetGuildBankCollectionSetting(i) end,
          setFunc = function(value) SetGuildBankCollectionSetting(i, value) end,
          disabled = function() return not IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType].bCollectGuildBankData end,
          default = false, -- Defaults to false for new guild banks
        }
      end
    end
  end
  LAM:RegisterOptionControls("IIfA_OptionsPanel", optionsData)
end

function IIfA:CreateSettingsWindow()
  local panelData = {
    type = "panel",
    name = IIfA.name,
    displayName = IIfA.displayName,
    author = IIfA.authors,
    version = IIfA.version,
    slashCommand = "/iifa", --(optional) will register a keybind to open to this panel
    registerForRefresh = true, --boolean (optional) (will refresh all options controls when a setting is changed and when the panel is shown)
    registerForDefaults = true  --boolean (optional) (will set all options controls back to default values)
  }
  LAM:RegisterAddonPanel("IIfA_OptionsPanel", panelData)
end

function IIfA:LibAddonInit()
  IIfA:SetFontListChoices()
  self:CreateSettingsWindow()
  self:CreateOptionsMenu()
end
