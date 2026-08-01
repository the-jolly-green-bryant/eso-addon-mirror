----------------------------------------------------------------------
--IIfA.lua
--v0.8 - Original Author: Vicster0
-- v1.x and 2.x - rewrites by ManaVortex & AssemblerManiac
-- v3.x - new features mainly by ManaVortex
--[[
	Collects inventory data for all characters on a single account including the shared bank and makes this information available
	on tooltips across the entire account providing the playerwith useful insight into their account wide inventory.
DISCLAIMER
	This Add-on is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its affiliates. The Elder Scrolls® and related
	logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. All rights reserved."
]]
-- text searches in non-EN languages improved by Baertram 2019-10-13
----------------------------------------------------------------------
local LMP = LibMediaProvider

local IIFA_COLOR_DEFAULT = ZO_ColorDef:New("3399FF")

-- --------------------------------------------------------------
--	External functions
-- --------------------------------------------------------------

-- 7-26-16 AM - global func, not part of IIfA class, used in IIfA_OnLoad
local function IIfA_SlashCommands(cmd)

  if (cmd == IIfA.EMPTY_STRING) then
    d("[IIfA]: Please find the majority of options in the addon settings section of the menu under Inventory Insight.")
    d(" ")
    d("[IIfA]: Usage - ")
    d("    /IIfA [options]")
    d("  ")
    d("    Options")
    d("        debug - Enables debug functionality for the IIfA addon.")
    d("        run - Runs the IIfA data collector.")
    d("        color - Opens the color picker dialog to set tooltip text color.")
    d("        toggle - Show/Hide IIfA")
    return
  end

  if (cmd == "debug") then
    if (IIFA_DATABASE[IIfA.currentAccount].settings.bDebug) then
      d("[IIfA]: Debug [Off]")
      IIFA_DATABASE[IIfA.currentAccount].settings.bDebug = false
    else
      d("[IIfA]: Debug [On]")
      IIFA_DATABASE[IIfA.currentAccount].settings.bDebug = true
    end
    return
  end

  if (cmd == "run") then
    d("[IIfA]: Running collector...")
    IIfA:CollectAllUseAsync()
    return
  end

  if (cmd == "color") then
    local in2ColorPickerOnMouseUp = _in2OptionsColorPicker:GetHandler("OnMouseUp")
    in2ColorPickerOnMouseUp(_in2OptionsColorPicker, nil, true)
    return
  end

  if cmd == "toggle" then
    IIfA:ToggleInventoryFrame()
  end
end

function IIfA:DebugOut(output, ...)
  local displayName = IIfA.currentAccount
  local accountSettings = IIFA_DATABASE[displayName].settings

  -- Return if any condition fails
  if not accountSettings or not next(accountSettings) or not accountSettings.bDebug then return end

  -- Proceed with the debug output if all conditions are met
  IIfA:dm("Debug", "DebugOut: " .. output, ...)
end

function IIfA:StatusAlert(message)
  local displayName = IIfA.currentAccount
  local accountSettings = IIFA_DATABASE[displayName].settings

  if accountSettings and accountSettings.bDebug then
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, IIfA.defaultAlertSound, message)
  end
end

function IIfA:isItemKey(itemKey)
  return type(itemKey) == "string" and itemKey:match("^%d+$") ~= nil and #itemKey < 10
end

function IIfA:isItemLink(itemLink)
  return type(itemLink) == "string" and itemLink:match(":item:") ~= nil
end

function IIfA:isCollectibleLink(itemLink)
  return type(itemLink) == "string" and itemLink:match(":collectible:") ~= nil
end

function IIfA:GetCollectibleLinkItemId(collectibleLink)
  local link = { ZO_LinkHandler_ParseLink(collectibleLink) }
  return tonumber(select(4, unpack(link)))
end

function IIfA:SetupTextColorHandlers()
  local settings = IIFA_DATABASE[IIfA.currentAccount].settings

  -- Assign color handlers based on saved settings
  self.colorHandlerToon = ZO_ColorDef:New(settings.TextColorsToon)
  self.colorHandlerCompanion = ZO_ColorDef:New(settings.TextColorsCompanion)
  self.colorHandlerBank = ZO_ColorDef:New(settings.TextColorsBank)
  self.colorHandlerGBank = ZO_ColorDef:New(settings.TextColorsGBank)
  self.colorHandlerHouse = ZO_ColorDef:New(settings.TextColorsHouse)
  self.colorHandlerHouseChest = ZO_ColorDef:New(settings.TextColorsHouseChest)
  self.colorHandlerCraftBag = ZO_ColorDef:New(settings.TextColorsCraftBag)
end

--Check if the clientLanguage is using gender specific string suffix like ^mx or ^f which need to be replaced
--by zo_strformat functions
function IIfA:CheckIfClientLanguageUsesGenderStrings(clientLanguage)
  clientLanguage = clientLanguage or GetCVar("language.2")
  if not clientLanguage then return false end
  local clientLanguagesWithGenderSpecificStringsSuffix = {
    ["de"] = true,
    ["fr"] = true,
  }
  local retVar = clientLanguagesWithGenderSpecificStringsSuffix[clientLanguage] or false
  IIfA.clientLanguageUsesGenderString = retVar
  return retVar
end

local IIfA_FONT_STYLE_NORMAL = 1
local IIfA_FONT_STYLE_OUTLINE = 2
local IIfA_FONT_STYLE_OUTLINE_THICK = 3
local IIfA_FONT_STYLE_SHADOW = 4
local IIfA_FONT_STYLE_SOFT_SHADOW_THICK = 5
local IIfA_FONT_STYLE_SOFT_SHADOW_THIN = 6

local StyleList = {
  [IIfA_FONT_STYLE_NORMAL] = "Normal",
  [IIfA_FONT_STYLE_OUTLINE] = "Outline",
  [IIfA_FONT_STYLE_OUTLINE_THICK] = "Thin-Outline",
  [IIfA_FONT_STYLE_SHADOW] = "Shadow",
  [IIfA_FONT_STYLE_SOFT_SHADOW_THICK] = "Soft-Shadow-Thick",
  [IIfA_FONT_STYLE_SOFT_SHADOW_THIN] = "Soft-Shadow-Thin",
}

function IIfA:CreateFontStyleChoices()
  for styleConstant, styleString in pairs(StyleList) do
    IIfA.fontStyleChoices[styleConstant] = styleString
    IIfA.fontStyleValues[styleConstant] = styleConstant
  end
end

function IIfA:SetFontListChoices()
  IIfA.fontListChoices = LMP:List(LMP.MediaType.FONT)
end

function IIfA:GetColorHexFromTable(colorTable)
  local r, g, b = ZO_ColorDef.FloatsToRGBA(colorTable.r, colorTable.g, colorTable.b, 1)
  return ZO_ColorDef.RGBAToHex(r, g, b, 255)
end

-- Constants
local IIFA_DEFAULT_FORMAT = 1
local IIFA_MEGASERVER_FORMAT = 2

local function DetectProfile()
  local displayName = GetDisplayName()
  local worldName = GetWorldName()

  -- Check for [GetWorldName()] first
  if IIfA_Data and IIfA_Data[worldName] and IIfA_Data[worldName][displayName] then
    if IIfA_Data[worldName][displayName]["$AccountWide"] then
      return IIFA_MEGASERVER_FORMAT
    end
  end

  -- Fallback to "Default"
  if IIfA_Data and IIfA_Data["Default"] and IIfA_Data["Default"][displayName] then
    if IIfA_Data["Default"][displayName]["$AccountWide"] then
      return IIFA_DEFAULT_FORMAT
    end
  end

  -- No valid profile found
  IIfA:dm("Debug", "[DetectProfile] No valid profile found.")
  return nil
end

local function GetSettingsAndDataLocations()
  local profileFormat = DetectProfile()
  local displayName = GetDisplayName()
  local worldName = GetWorldName()

  -- Determine dataLocation
  local dataLocation
  if profileFormat and profileFormat == IIFA_DEFAULT_FORMAT then
    local baseLocation = IIfA_Data["Default"][displayName]["$AccountWide"]
    if baseLocation and baseLocation["Data"] then
      dataLocation = IIfA_Data["Default"][displayName]["$AccountWide"]["Data"]
    else
      IIfA:dm("Debug", "[GetSettingsAndDataLocations] Default format found but no Data present.")
      return nil, nil -- No valid data location
    end
  elseif profileFormat and profileFormat == IIFA_MEGASERVER_FORMAT then
    local baseLocation = IIfA_Data[worldName][displayName]["$AccountWide"]
    if baseLocation and baseLocation["Data"] then
      dataLocation = IIfA_Data[worldName][displayName]["$AccountWide"]["Data"]
    else
      IIfA:dm("Debug", "[GetSettingsAndDataLocations] Megaserver format found but no Data present.")
      return nil, nil -- No valid data location
    end
  else
    IIfA:dm("Debug", "[GetSettingsAndDataLocations] Unable to determine valid data profile for Default or worldName.")
    return nil, nil -- No valid data location
  end

  -- Determine settingsLocation
  local settingsLocation
  local globalSettings = dataLocation and dataLocation.saveSettingsGlobally
  if globalSettings then
    settingsLocation = dataLocation
  elseif not globalSettings then
    local topLevelLocation = IIfA_Settings and IIfA_Settings["Default"] and IIfA_Settings["Default"][displayName]
    if topLevelLocation and topLevelLocation[GetCurrentCharacterId()] then
      settingsLocation = IIfA_Settings["Default"][displayName][GetCurrentCharacterId()]
    else
      settingsLocation = IIfA_Settings["Default"][displayName]
    end
  else
    IIfA:dm("Debug", "[GetSettingsAndDataLocations] Data field present but unable to determine global or non global settings profile.")
    return nil, nil -- No valid data location
  end

  return settingsLocation, dataLocation
end

-- Helper function to safely access nested tables
local function GetNestedTable(root, ...)
  local tbl = root
  for _, key in ipairs({ ... }) do
    tbl = tbl[key]
    if not tbl then return {} end -- Return an empty table if any key is missing
  end
  return tbl
end

function IIfA:MigrateLegacyValues()
  if IIfA.data.legacyMigrationComplete then
    IIfA:dm("Debug", "MigrateLegacyValues skipped, already executed previously..")
    return
  end

  -- Safely access the settings and data tables
  local settingsData, locationData = GetSettingsAndDataLocations()

  if settingsData == nil then
    IIfA:dm("Debug", "Settings or Account based information was nil migration of Legacy Values not possible.")
    return
  end

  IIfA:dm("Info", "MigrateLegacyValues Starting...")

  -- Convert in2ToggleGuildBankDataCollection to bCollectGuildBankData
  if settingsData.in2ToggleGuildBankDataCollection ~= nil then
    settingsData.bCollectGuildBankData = settingsData.in2ToggleGuildBankDataCollection
    settingsData.in2ToggleGuildBankDataCollection = nil
  end

  -- Clean up legacy text color settings
  if settingsData.in2TextColors ~= nil then
    settingsData.TextColorsToon = settingsData.TextColorsToon or ZO_ColorDef:New(settingsData.in2TextColors):ToHex()
    settingsData.TextColorsCompanion = settingsData.TextColorsCompanion or ZO_ColorDef:New(settingsData.in2TextColors):ToHex()
    settingsData.TextColorsBank = settingsData.TextColorsBank or ZO_ColorDef:New(settingsData.in2TextColors):ToHex()
    settingsData.TextColorsGBank = settingsData.TextColorsGBank or ZO_ColorDef:New(settingsData.in2TextColors):ToHex()
    settingsData.TextColorsHouse = settingsData.TextColorsHouse or ZO_ColorDef:New(settingsData.in2TextColors):ToHex()
    settingsData.TextColorsHouseChest = settingsData.TextColorsHouseChest or ZO_ColorDef:New(settingsData.in2TextColors):ToHex()
    settingsData.TextColorsCraftBag = settingsData.TextColorsCraftBag or ZO_ColorDef:New(settingsData.in2TextColors):ToHex()

    -- Remove the legacy key
    settingsData.in2TextColors = nil
  end

  -- Process DBv2 to convert names to IDs
  if settingsData.DBv2 ~= nil then
    IIfA:ConvertNameToId(settingsData.DBv2)
    settingsData.DBv2 = nil -- Clean up after conversion
  end

  -- Clean up legacy accountCharacters key
  if settingsData.accountCharacters ~= nil then
    settingsData.accountCharacters = nil
  end

  -- Move DBv3 to the world-specific structure
  local worldName = GetWorldName():gsub(" Megaserver", IIfA.EMPTY_STRING)
  IIfA.data[worldName] = IIfA.data[worldName] or {}
  if IIfA.data.DBv3 ~= nil then
    if IIfA.data[worldName].DBv3 == nil then
      IIfA.data[worldName].DBv3 = IIfA.data.DBv3
    end
    IIfA.data.DBv3 = nil
  end

  -- Convert InventoryListFilter from "All Account Owned" to "All Storage"
  if IIfA.InventoryListFilter == "All Account Owned" then
    IIfA.InventoryListFilter = GetString(IIFA_LOCATION_NAME_ALL_STORAGE)
  end

  -- Example for handling character-specific settings (from settingsData)
  if settingsData.bFilterOnSetName == nil then
    settingsData.bFilterOnSetName = false
  end

  -- Mark migration as completed
  IIfA.data.legacyMigrationComplete = true
end

function IIfA:ConvertCompanionToServerFormat()
  IIfA:dm("Debug", "ConvertCompanionToServerFormat Starting...")

  -- Exit early if IIfA_Companion does not exist
  if not IIfA_Companion or not IIfA_Companion["Default"] then
    IIfA:dm("Debug", "IIfA_Companion does not exist or is already empty. Exiting early.")
    return
  end

  local displayName = GetDisplayName()
  local currentAccount = IIfA.currentAccount
  local currentServerType = IIfA.currentServerType

  -- Access the companion data table directly using GetDisplayName()
  local companionData = IIfA_Companion["Default"][displayName] and IIfA_Companion["Default"][displayName]["$AccountWide"]

  if not companionData then
    IIfA:dm("Debug", "No companion data found for the current account. Exiting early.")
    return
  end

  -- Access the server-specific data in IIFA_DATABASE
  local serverData = IIFA_DATABASE[currentAccount].servers[currentServerType]

  -- Ensure CharIdToName and CharNameToId tables exist in the serverData
  serverData.CompanionIdToName = serverData.CompanionIdToName or {}
  serverData.CompanionNameToId = serverData.CompanionNameToId or {}

  -- Migrate data from the old companion table to the server-specific format
  for id, name in pairs(companionData.CharIdToName or {}) do
    serverData.CompanionIdToName[id] = name
  end

  for name, id in pairs(companionData.CharNameToId or {}) do
    serverData.CompanionNameToId[name] = id
  end

  -- Cleanup old companion data for the current account
  companionData.CharIdToName = nil
  companionData.CharNameToId = nil

  -- Helper function to check if an account in IIfA_Companion is safe to delete
  local function IsAccountSafeToDelete(accountData)
    local accountWideData = accountData["$AccountWide"]
    return accountWideData and not accountWideData.CharNameToId and not accountWideData.CharIdToName
  end

  -- Check all accounts under "Default" in IIfA_Companion
  local accountsToDelete = {}
  for accountName, accountData in pairs(IIfA_Companion["Default"]) do
    if IsAccountSafeToDelete(accountData) then
      table.insert(accountsToDelete, accountName)
    end
  end

  -- Delete accounts that are safe to delete
  for _, accountName in ipairs(accountsToDelete) do
    IIfA_Companion["Default"][accountName] = nil
  end

  -- Check if IIfA_Companion["Default"] is now empty
  if next(IIfA_Companion["Default"]) == nil then
    -- Safe to remove IIfA_Companion completely
    IIfA_Companion = nil
    IIfA:dm("Debug", "IIfA_Companion has been completely cleared and removed.")
  else
    IIfA:dm("Debug", "IIfA_Companion still contains accounts with data.")
  end

  IIFA_DATABASE[IIfA.currentAccount].settings.companionMigrationCompleted = IIFA_DATABASE[IIfA.currentAccount].settings.companionMigrationCompleted or true
end

function IIfA:MigrateFrameSettings()
  local settingsData, locationData = GetSettingsAndDataLocations()
  local hasSettingsData = settingsData and settingsData["frameSettings"]
  if not settingsData then
    IIfA:dm("Debug", "[MigrateFrameSettings] Migration not possible no data found for the current account. Exiting early.")
    return
  end

  if not hasSettingsData then
    IIfA:dm("Debug", "[MigrateFrameSettings] Migration not possible, settingsData present but no remaining frameSettings. Exiting early.")
    return
  end

  IIfA:dm("Info", "MigrateFrameSettings Starting...")

  -- Migrate settingsData to IIFA_DATABASE using defaults_character if settingsData is valid
  for key, _ in pairs(IIfA.defaults_character) do
    IIfA:dm("Debug", "[key] <<1>>", key)
    if key ~= "frameSettings" and settingsData and settingsData[key] ~= nil then
      IIfA:dm("Debug", "Copy non frameSettings value.")
      IIFA_DATABASE[IIfA.currentAccount].characters[IIfA.currentCharacterId][key] = settingsData[key]
      settingsData[key] = nil
    elseif key == "frameSettings" then
      for frameKey, frameDefault in pairs(IIfA.defaults_character["frameSettings"]) do
        if settingsData and settingsData[key] and settingsData[key][frameKey] ~= nil then
          IIfA:dm("Debug", "Copy frameSettings value from settingsData.")
          IIFA_DATABASE[IIfA.currentAccount].characters[IIfA.currentCharacterId][key][frameKey] = settingsData[key][frameKey]
          settingsData[key][frameKey] = nil
        end
      end
    end
  end

  if settingsData and settingsData["frameSettings"] then settingsData["frameSettings"] = nil end

  IIfA:dm("Debug", "MigrateFrameSettings Completed")
end

function IIfA:MigrateToAccountAndServerSpecificFormat()
  local settingsData, locationData = GetSettingsAndDataLocations()
  if not settingsData then
    IIfA:dm("Debug", "Migration not possible no data found for the current account. Exiting early.")
    return
  end

  IIfA:dm("Info", "MigrateToAccountAndServerSpecificFormat Starting...")

  -- Assign NA and EU specific DBv3 tables
  local naData = locationData.NA.DBv3
  local euData = locationData.EU.DBv3

  -- Migrate defaults_account
  for key, _ in pairs(IIfA.defaults_account) do
    if settingsData and settingsData[key] ~= nil then
      IIFA_DATABASE[IIfA.currentAccount].settings[key] = settingsData[key]
      settingsData[key] = nil
    end
  end

  -- Migrate defaults_server specific keys
  local serverSpecificKeys = { "collectHouseData", "bCollectGuildBankData", "ignoredCharEquipment", "ignoredCharInventories", "houseChestSpace", "assets" }
  for _, key in ipairs(serverSpecificKeys) do
    if settingsData and settingsData[key] ~= nil then
      IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType][key] = settingsData[key]
      settingsData[key] = nil
    end
  end

  -- Copy NA and EU DBv3 data to the new database structure
  if naData then
    IIFA_DATABASE[IIfA.currentAccount].servers.NA.DBv3 = naData
    locationData.NA.DBv3 = nil
  end
  if euData then
    IIFA_DATABASE[IIfA.currentAccount].servers.EU.DBv3 = euData
    locationData.EU.DBv3 = nil
  end

  -- Delete specific keys no longer used or needed
  local specificKeysToDelete = { "defaultInventoryFrameView", "EU", "EU-guildBanks", "in2AgedGuildBankDataWarning", "in2DefaultInventoryFrameView", "NA", "NA-guildBanks", "DBv3", "ShowToolTipWhen" }
  for _, key in ipairs(specificKeysToDelete) do
    if settingsData and settingsData[key] ~= nil then
      settingsData[key] = nil
    end
    if locationData and locationData[key] ~= nil then
      locationData[key] = nil
    end
  end

  -- Mark migration as complete
  IIFA_DATABASE[IIfA.currentAccount].settings.newFormatMigrationCompleted = true

  IIfA:dm("Debug", "MigrateToAccountAndServerSpecificFormat Completed")
end

function IIfA:InitializeDatabase()
  -- Default Account-Wide Settings
  local defaults_account = {
    bDebug = false,
    showItemCountOnRight = true,
    showItemStats = false,
    b_collectHouses = false,
    ignoreCompanionEquipment = false,
    BagSpaceWarn = {
      ["threshold"] = 85,
      ["r"] = 0.9019607902,
      ["g"] = 0.5098039508,
      ["b"] = 0,
    },
    BagSpaceAlert = {
      ["threshold"] = 95,
      ["r"] = 1,
      ["g"] = 1,
      ["b"] = 0,
    },
    BagSpaceFull = {
      ["r"] = 255,
      ["g"] = 0,
      ["b"] = 0,
    },
    in2TooltipsFont = "ZoFontGame",
    TooltipFontFace = "ProseAntique",
    TooltipFontSize = 18,
    TooltipFontEffect = "Normal",
    showToolTipWhen = "Always",
    dontFocusSearch = false,
    bAddContextMenuEntrySearchInIIfA = true,
    bAddContextMenuEntryMissingMotifsInIIfA = true,
    bInSeparateFrame = true,
    showStyleInfo = true,
    alwaysUseStyleMaterial = false,
    bFilterOnSetNameToo = false,
    bFilterOnSetName = false,
    hideCloseButton = false,
    FCOISshowMarkerIcons = false,
    lastLang = GetCVar("language.2"),
    refreshDelay = 250,
    -- newFormatMigrationCompleted = false, -- Tracks if MigrateLegacyValues has run
    -- Text colors for various contexts
    TextColorsToon = IIFA_COLOR_DEFAULT:ToHex(),
    TextColorsCompanion = IIFA_COLOR_DEFAULT:ToHex(),
    TextColorsBank = IIFA_COLOR_DEFAULT:ToHex(),
    TextColorsGBank = IIFA_COLOR_DEFAULT:ToHex(),
    TextColorsHouse = IIFA_COLOR_DEFAULT:ToHex(),
    TextColorsHouseChest = IIFA_COLOR_DEFAULT:ToHex(),
    TextColorsCraftBag = IIFA_COLOR_DEFAULT:ToHex(),
  }
  IIfA.defaults_account = defaults_account

  -- Default Server-Specific Settings
  local defaults_server = {
    NA = {
      collectHouseData = {}, -- server specific
      HouseNameToId = {}, -- server specific
      HouseIdToName = {}, -- server specific
      ignoredCharEquipment = {}, -- server specific
      ignoredCharInventories = {}, -- server specific
      bCollectGuildBankData = false, -- server specific
      DBv3 = {}, -- server specific
      guildBankInfo = {}, -- server specific
      GuildIdToName = {}, -- server specific
      GuildNameToId = {}, -- server specific
      houseChestSpace = {}, -- server specific
      assets = {}, -- server specific
      CompanionIdToName = {}, -- server specific
      CompanionNameToId = {}, -- server specific
      CharIdToName = {}, -- server specific
      CharNameToId = {}, -- server specific
    },
    EU = {
      collectHouseData = {}, -- server specific
      HouseNameToId = {}, -- server specific
      HouseIdToName = {}, -- server specific
      ignoredCharEquipment = {}, -- server specific
      ignoredCharInventories = {}, -- server specific
      bCollectGuildBankData = false, -- server specific
      DBv3 = {}, -- server specific
      guildBankInfo = {}, -- server specific
      GuildIdToName = {}, -- server specific
      GuildNameToId = {}, -- server specific
      houseChestSpace = {}, -- server specific
      assets = {}, -- server specific
      CompanionIdToName = {}, -- server specific
      CompanionNameToId = {}, -- server specific
      CharIdToName = {}, -- server specific
      CharNameToId = {}, -- server specific
    },
  }
  IIfA.defaults_server = defaults_server

  -- Default Character-Specific Settings
  local valDocked, valLocked, valMinimized = true, false, false
  local valGamepadDocked, valGamepadLocked = false, true
  local valLastX, valLastY, valHeight, valWidth = 435, 300, 750, 420
  local valGamepadLastX, valGamepadLastY = 1010, 175

  local defaults_character = {
    frameSettings = {
      ["bank"] = { hidden = false, docked = valDocked, locked = valLocked, minimized = valMinimized, lastX = valLastX, lastY = valLastY, height = valHeight, width = valWidth },
      ["guildBank"] = { hidden = false, docked = valDocked, locked = valLocked, minimized = valMinimized, lastX = valLastX, lastY = valLastY, height = valHeight, width = valWidth },
      ["tradinghouse"] = { hidden = false, docked = valDocked, locked = valLocked, minimized = valMinimized, lastX = valLastX, lastY = valLastY, height = valHeight, width = valWidth },
      ["smithing"] = { hidden = false, docked = valDocked, locked = valLocked, minimized = valMinimized, lastX = valLastX, lastY = valLastY, height = valHeight, width = valWidth },
      ["store"] = { hidden = false, docked = valDocked, locked = valLocked, minimized = valMinimized, lastX = valLastX, lastY = valLastY, height = valHeight, width = valWidth },
      ["stables"] = { hidden = false, docked = valDocked, locked = valLocked, minimized = valMinimized, lastX = valLastX, lastY = valLastY, height = valHeight, width = valWidth },
      ["trade"] = { hidden = false, docked = valDocked, locked = valLocked, minimized = valMinimized, lastX = valLastX, lastY = valLastY, height = valHeight, width = valWidth },
      ["inventory"] = { hidden = false, docked = valDocked, locked = valLocked, minimized = valMinimized, lastX = valLastX, lastY = valLastY, height = valHeight, width = valWidth },
      ["hud"] = { hidden = true, docked = false, locked = valLocked, minimized = valMinimized, lastX = valLastX, lastY = valLastY, height = valHeight, width = valWidth },
      ["alchemy"] = { hidden = false, docked = valDocked, locked = valLocked, minimized = valMinimized, lastX = valLastX, lastY = valLastY, height = valHeight, width = valWidth },
      ["gamepad_inventory_root"] = { hidden = false, docked = valGamepadDocked, locked = valGamepadLocked, minimized = valMinimized, lastX = valGamepadLastX, lastY = valGamepadLastY, height = valHeight, width = valWidth },
      ["gamepad_banking"] = { hidden = false, docked = valGamepadDocked, locked = valGamepadLocked, minimized = valMinimized, lastX = valGamepadLastX, lastY = valGamepadLastY, height = valHeight, width = valWidth },
      ["gamepad_store"] = { hidden = false, docked = valGamepadDocked, locked = valGamepadLocked, minimized = valMinimized, lastX = valGamepadLastX, lastY = valGamepadLastY, height = valHeight, width = valWidth },
    },
    defaultInventoryFrameView = IIFA_LOCATION_KEY_ALL,
  }
  IIfA.defaults_character = defaults_character

  local defaults_assets = {
    ["wv"] = 0,
    ["gold"] = 0,
    ["tv"] = 0,
    ["spaceMax"] = 0,
    ["ap"] = 0,
    ["spaceUsed"] = 0,
  }

  -- Root Database Structure
  local displayName = GetDisplayName()
  local currentCharacterId = GetCurrentCharacterId()
  local worldName = GetWorldName():gsub(" Megaserver", IIfA.EMPTY_STRING)

  -- Initialize IIfA_Database
  IIFA_DATABASE = IIFA_DATABASE or {}
  IIFA_DATABASE[displayName] = IIFA_DATABASE[displayName] or {
    settings = defaults_account, -- Account-wide settings
    characters = {}, -- Character-specific settings
    servers = defaults_server, -- Server-specific data
  }

  -- Ensure the current character has its own settings
  IIFA_DATABASE[displayName].characters[currentCharacterId] = IIFA_DATABASE[displayName].characters[currentCharacterId] or defaults_character
  IIFA_DATABASE[displayName].servers[worldName].assets[currentCharacterId] = IIFA_DATABASE[displayName].servers[worldName].assets[currentCharacterId] or defaults_assets

  local settingsSavedVariables = IIFA_DATABASE[displayName].settings
  local characterSavedVariables = IIFA_DATABASE[displayName].characters[currentCharacterId]
  local serverSavedVariables = IIFA_DATABASE[displayName].servers

  -- Remove keys from saved variables not in defaults
  local skipRequiredMigrationData = { legacyMigrationComplete = true, newFormatMigrationCompleted = true }
  IIfA:dm("Debug", "Adding - Removing Vars ")
  for key in pairs(settingsSavedVariables) do
    if defaults_account[key] == nil and not skipRequiredMigrationData[key] then
      IIfA:dm("Warn", "[<<1>>] Removed ", key)
      settingsSavedVariables[key] = nil -- Remove unexpected key
    end
  end

  for key in pairs(characterSavedVariables) do
    if key ~= "frameSettings" and defaults_character[key] == nil then
      IIfA:dm("Warn", "[<<1>>] Removed ", key)
      characterSavedVariables[key] = nil -- Remove unexpected key
    elseif key == "frameSettings" then
      IIfA:dm("Debug", "Removing unused frameSettings...")
      for frameKey, frameDefault in pairs(characterSavedVariables[key]) do
        if defaults_character[key][frameKey] == nil then
          IIfA:dm("Warn", "[<<1>>] Removed from [<<2>>]", frameKey, key)
          characterSavedVariables[key][frameKey] = nil
        end
      end
    end
  end

  for region, serverData in pairs(serverSavedVariables) do
    if defaults_server[region] then
      for key in pairs(serverData) do
        if defaults_server[region][key] == nil then
          IIfA:dm("Warn", "[<<1>>] Removed from [<<2>>]", key, region)
          serverData[key] = nil -- Remove the entire table or scalar value
        end
      end
    end
  end

  -- Add missing keys from defaults to saved variables
  for key, defaultVal in pairs(defaults_account) do
    if settingsSavedVariables[key] == nil then
      IIfA:dm("Warn", "[<<1>>] Added ", key)
      settingsSavedVariables[key] = defaultVal -- Add missing default
    end
  end

  for key, defaultVal in pairs(defaults_character) do
    characterSavedVariables[key] = characterSavedVariables[key] or {}
    if key ~= "frameSettings" then
      if characterSavedVariables[key] == nil then
        IIfA:dm("Warn", "[<<1>>] Added ", key)
        characterSavedVariables[key] = defaultVal -- Add missing default
      end
    elseif key == "frameSettings" then
      IIfA:dm("Debug", "Adding frameSettings...")
      for frameKey, frameDefault in pairs(defaults_character[key]) do
        if characterSavedVariables[key][frameKey] == nil then
          IIfA:dm("Warn", "[<<1>>] Added to [<<2>>]", frameKey, key)
          characterSavedVariables[key][frameKey] = frameDefault -- Add missing default
        end
      end
    end
  end

  for region, serverData in pairs(defaults_server) do
    serverSavedVariables[region] = serverSavedVariables[region] or {}
    for key, defaultVal in pairs(serverData) do
      if serverSavedVariables[region][key] == nil then
        IIfA:dm("Warn", "[<<1>>] Added to [<<2>>]", key, region)
        serverSavedVariables[region][key] = defaultVal -- Add missing default
      end
    end
  end

end

function IIfA:GetInventoryDB()
  return IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType].DBv3
end

-- Get pointer to current settings based on user pref (global or per char)
function IIfA:GetSettings()
  return IIFA_DATABASE[IIfA.currentAccount].settings
end

function IIfA:CleanupOldCharacterSettings()
  IIfA:dm("Debug", "[CleanupOldCharacterSettings]")

  local settingsData = IIfA_Settings and IIfA_Settings["Default"] and IIfA_Settings["Default"][IIfA.currentAccount]
  if not settingsData then
    IIfA:dm("Debug", "Migration not possible no data found for the current account. Exiting early.")
    return
  end

  if settingsData and settingsData[IIfA.currentCharacterId] then
    -- Log the removal for debugging purposes
    IIfA:dm("Debug", "[CleanupOldCharacterSettings] Removing old settings for characterId: <<1>>", IIfA.currentCharacterId)

    -- Remove the old settings
    settingsData[IIfA.currentCharacterId] = nil
  else
    -- Log that there were no old settings to remove
    IIfA:dm("Debug", "[CleanupOldCharacterSettings] No old settings found for characterId: <<1>>", IIfA.currentCharacterId)
  end
end

local function IsCompanionDataNonEmpty()
  IIfA:dm("Debug", "IsCompanionDataNonEmpty...")
  -- Safely check the presence of each level
  local hasData = IIfA_Companion and IIfA_Companion["Default"] and next(IIfA_Companion["Default"])

  if not hasData then return false end

  -- Iterate through accounts in "Default" to check for meaningful data
  for _, accountData in pairs(IIfA_Companion["Default"]) do
    if accountData["$AccountWide"] and (accountData["$AccountWide"].CharNameToId or accountData["$AccountWide"].CharIdToName) then
      return true -- Found companion data
    end
  end

  return false -- No meaningful data
end

local function IsDBv3NonEmpty()
  local format = DetectProfile()
  local serverType = GetWorldName():gsub(" Megaserver", IIfA.EMPTY_STRING)
  local worldName = GetWorldName()

  local hasData, dbv3Table = false, nil

  if format and format == IIFA_DEFAULT_FORMAT then
    -- Check for Default Format
    if IIfA_Data and IIfA_Data["Default"] and IIfA_Data["Default"][IIfA.currentAccount] and
      IIfA_Data["Default"][IIfA.currentAccount]["$AccountWide"] and
      IIfA_Data["Default"][IIfA.currentAccount]["$AccountWide"]["Data"] then

      local accountData = IIfA_Data["Default"][IIfA.currentAccount]["$AccountWide"]["Data"]
      if accountData[serverType] and accountData[serverType]["DBv3"] then
        dbv3Table = accountData[serverType]["DBv3"]
        hasData = true
      end
    end

  elseif format and format == IIFA_MEGASERVER_FORMAT then
    -- Check for Megaserver Format
    if IIfA_Data and IIfA_Data[worldName] and IIfA_Data[worldName][IIfA.currentAccount] and
      IIfA_Data[worldName][IIfA.currentAccount]["$AccountWide"] and
      IIfA_Data[worldName][IIfA.currentAccount]["$AccountWide"]["Data"] then

      local accountData = IIfA_Data[worldName][IIfA.currentAccount]["$AccountWide"]["Data"]
      if accountData[serverType] and accountData[serverType]["DBv3"] then
        dbv3Table = accountData[serverType]["DBv3"]
        hasData = true
      end
    end
  else
    -- If format is unrecognized, consider DBv3 empty
    IIfA:dm("Debug", "[IsDBv3NonEmpty] format is unrecognized...")
    return false
  end

  -- Return true if DBv3 has any keys, false otherwise
  return hasData and dbv3Table and next(dbv3Table) ~= nil
end

local function IIfA_onLoad(eventCode, addOnName)
  if (addOnName ~= "IIfA") then
    return
  end
  IIfA:dm("Debug", "[IIfA_onLoad] Starting...")

  local valDocked = true
  local valLocked = false
  local valMinimized = false

  IIfA.minWidth = 435
  IIfA.maxWidth = 500
  IIfA.minHeight = 390
  IIfA.maxHeight = 1400

  local valLastX = IIfA.minWidth
  local valLastY = 300
  local valHeight = 750
  local valWidth = 420

  local lang = GetCVar("language.2")
  IIfA.clientLanguage = lang
  IIfA:CheckIfClientLanguageUsesGenderStrings(lang)

  -- initializing default values
  local defaults = {
    saveSettingsGlobally = true,
    bDebug = false,
    showItemCountOnRight = true,
    showItemStats = false,
    b_collectHouses = false,
    collectHouseData = {}, -- server specific
    ignoredCharEquipment = {}, -- server specific
    ignoredCharInventories = {}, -- server specific
    ignoreCompanionEquipment = false, -- server specific
    frameSettings = {
      ["bank"] = { hidden = false, docked = valDocked, locked = valLocked, minimized = valMinimized, lastX = valLastX, lastY = valLastY, height = valHeight, width = valWidth },
      ["guildBank"] = { hidden = false, docked = valDocked, locked = valLocked, minimized = valMinimized, lastX = valLastX, lastY = valLastY, height = valHeight, width = valWidth },
      ["tradinghouse"] = { hidden = false, docked = valDocked, locked = valLocked, minimized = valMinimized, lastX = valLastX, lastY = valLastY, height = valHeight, width = valWidth },
      ["smithing"] = { hidden = false, docked = valDocked, locked = valLocked, minimized = valMinimized, lastX = valLastX, lastY = valLastY, height = valHeight, width = valWidth },
      ["store"] = { hidden = false, docked = valDocked, locked = valLocked, minimized = valMinimized, lastX = valLastX, lastY = valLastY, height = valHeight, width = valWidth },
      ["stables"] = { hidden = false, docked = valDocked, locked = valLocked, minimized = valMinimized, lastX = valLastX, lastY = valLastY, height = valHeight, width = valWidth },
      ["trade"] = { hidden = false, docked = valDocked, locked = valLocked, minimized = valMinimized, lastX = valLastX, lastY = valLastY, height = valHeight, width = valWidth },
      ["inventory"] = { hidden = false, docked = valDocked, locked = valLocked, minimized = valMinimized, lastX = valLastX, lastY = valLastY, height = valHeight, width = valWidth },
      ["hud"] = { hidden = true, docked = false, locked = valLocked, minimized = valMinimized, lastX = valLastX, lastY = valLastY, height = valHeight, width = valWidth },
      ["alchemy"] = { hidden = false, docked = valDocked, locked = valLocked, minimized = valMinimized, lastX = valLastX, lastY = valLastY, height = valHeight, width = valWidth }
    },
    BagSpaceWarn = {
      ["threshold"] = 85,
      ["r"] = 230 / 255,
      ["g"] = 130 / 255,
      ["b"] = 0,
    },
    BagSpaceAlert = {
      ["threshold"] = 95,
      ["r"] = 1,
      ["g"] = 1,
      ["b"] = 0,
    },
    BagSpaceFull = {
      ["r"] = 255,
      ["g"] = 0,
      ["b"] = 0,
    },
    bCollectGuildBankData = false, -- server specific
    in2DefaultInventoryFrameView = GetString(IIFA_LOCATION_NAME_ALL),
    in2AgedGuildBankDataWarning = true,
    in2TooltipsFont = "ZoFontGame",
    TooltipFontFace = "ProseAntique",
    TooltipFontSize = 18,
    TooltipFontEffect = "Normal",
    showToolTipWhen = "Always",
    DBv3 = {},
    dontFocusSearch = false,
    bAddContextMenuEntrySearchInIIfA = true,
    bInSeparateFrame = true,
    showStyleInfo = true,
    bFilterOnSetNameToo = false,
    bFilterOnSetName = false,
    hideCloseButton = false,
    FCOISshowMarkerIcons = false,
    -- Added for reference
    lastLang = GetCVar("language.2"),
    houseChestSpace = {}, -- server specific
    NA = {
      ["DBv3"] = {},
    },
    ["NA-guildBanks"] = { },
    EU = {
      ["DBv3"] = {},
    },
    ["EU-guildBanks"] = { },
    assets = {}, -- server specific
    legacyMigrationComplete = false,
  }

  local defaultsCompanion = { -- server specific
    CharIdToName = { }, -- num, name
    CharNameToId = { }, -- name, num
  }

  -- prevent resizing by user to be larger than this
  IIFA_GUI:SetDimensionConstraints(IIfA.minWidth, IIfA.minHeight, IIfA.maxWidth, IIfA.maxHeight)

  -- Grab a couple static values that shouldn't change while it's running
  IIfA.HeaderHeight = IIFA_GUI_Header:GetHeight()
  IIfA.SearchHeight = IIFA_GUI_Search:GetHeight()

  IIFA_GUI_ListHolder.rowHeight = 52  -- trying to find optimal size for this, set it in one spot for easier adjusting
  IIFA_GUI_ListHolder:SetDrawLayer(DL_BACKGROUND)  -- keep the scrollable dropdown ABOVE this one
  -- (otherwise scrollable dropdown is shown like it's above the list, but the mouse events end up going through to the list)

  IIfA.currentCompanionId = IIfA:GetCurrentCompanionHashId() -- assign here to prevent errors in Init.lua

  IIfA.filterGroup = GetString(IIFA_LOCATION_NAME_ALL)
  IIfA.filterTypes = nil

  -- grabs data from backpack, and worn items when we first open the inventory
  -- ZO_PreHook(PLAYER_INVENTORY, "ApplyBackpackLayout", IIfA.OnFirstInventoryOpen)
  ZO_PreHook(BACKPACK_GUILD_BANK_LAYOUT_FRAGMENT, "ApplyBackpackLayout", IIfA.CollectGuildBank)

  -- ZO_PreHook(SHARED_INVENTORY, "GetOrCreateBagCache", function(self, bagId)
  -- d("SHARED_INVENTORY: GetOrCreateBagCache: " .. tostring(bagId))
  -- end)
  -- ZO_PreHook(SHARED_INVENTORY, "PerformFullUpdateOnBagCache", function(self, bagId)
  -- d("SHARED_INVENTORY: PerformFullUpdateOnBagCache: " .. tostring(bagId))
  -- end)

  -- http://esodata.uesp.net/100016/src/libraries/utility/zo_savedvars.lua.html#67

  --[[We use the same default values is because function IIfA:GetSettings()
  will return either IIfA.settings or IIfA.data. Some places will reference
  IIfA.settings or IIfA.data directly which IIfA.data is intended to be global. However,
  how are you going to allocate different values to both when someone may toggle
  the settings so that they are not AccountWide. When that happens will the settings
  have a nil value?

  Also this seems problamatic because once you change from account wide to
  character specific, there is no copy routine and some code will still reference IIfA.data
  directly.
  ]]--
  IIfA:InitializeDatabase()

  if IsCompanionDataNonEmpty() then
    IIfA.companion = ZO_SavedVars:NewAccountWide("IIfA_Companion", 1, nil, defaultsCompanion)
    IIfA:ConvertCompanionToServerFormat()
  else
    IIfA:dm("Debug", "IIfA_Companion does not exist or was already cleared.")
  end
  if IsDBv3NonEmpty() then
    IIfA.settings = ZO_SavedVars:NewCharacterIdSettings("IIfA_Settings", 1, nil, defaults)
    if DetectProfile() == IIFA_DEFAULT_FORMAT then
      IIfA.data = ZO_SavedVars:NewAccountWide("IIfA_Data", 1, "Data", defaults)
    elseif DetectProfile() == IIFA_MEGASERVER_FORMAT then
      IIfA.data = ZO_SavedVars:NewAccountWide("IIfA_Data", 1, "Data", defaults, GetWorldName())
    end
    IIfA:MigrateLegacyValues()
    IIfA:MigrateToAccountAndServerSpecificFormat()
  else
    IIfA:dm("Debug", "[IsDBv3NonEmpty] Failed because of invalid or insufficient data.")
  end
  IIfA:MigrateFrameSettings()
  IIfA:CleanupOldCharacterSettings()

  --[[
  SecurePostHook(ZO_SharedInventoryManager, "CreateOrUpdateSlotData", function(sharedInventoryPointer, existingSlotData, bagId, slotIndex, isNewItem)
    local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS)
    if itemLink then
      IIfA:dm("Debug", "[CreateOrUpdateSlotData] : <<1>>, <<2>> : <<3>>", bagId, slotIndex, GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS))
    end
  end)
  ]]--

  IIfA:CreateFontStyleChoices()
  IIfA:SetTooltipFont()
  IIfA:CreateTooltips()
  IIfA:RebuildHouseMenuDropdowns()
  IIfA:SetupCharLookups()
  IIfA:SetupGuildBanks()
  IIfA:SetupTextColorHandlers()

  -- Convert saved data names into the proper language for this session if needed
  if IIFA_DATABASE[IIfA.currentAccount].settings.lastLang ~= lang then
    IIfA:RenameItems()
    IIFA_DATABASE[IIfA.currentAccount].settings.lastLang = lang
  end

  IIFA_GUI_Header_Filter_Button0:SetState(BSTATE_PRESSED)
  IIfA.LastFilterControl = IIFA_GUI_Header_Filter_Button0

  IIfA.GUI_SearchBox = IIFA_GUI_SearchBackdropBox

  SLASH_COMMANDS["/ii"] = IIfA_SlashCommands
  -- IIfA:CreateSettingsWindow(IIfA.settings, default)

  IIFA_GUI_ListHolder_Counts:SetHidden(not IIFA_DATABASE[IIfA.currentAccount].settings.showItemStats)

  IIfA.CharCurrencyFrame:Initialize()
  IIfA.CharBagFrame:Initialize()

  IIfA:SetupBackpack()  -- setup the inventory frame

  if not IIFA_DATABASE[IIfA.currentAccount].characters[IIfA.currentCharacterId].frameSettings.hud.hidden then
    IIfA:ProcessSceneChange("hud", "showing", "shown")
  end

  IIFA_GUI_Header_Hide:SetHidden(IIFA_DATABASE[IIfA.currentAccount].settings.hideCloseButton)

  IIfA:RegisterForEvents()
  IIfA:RegisterForSceneChanges() -- register for callbacks on scene statechanges using user preferences or defaults

  IIfA.trackedBags[BAG_WORN] = not IIfA:IsCharacterEquipIgnored()
  IIfA.trackedBags[BAG_COMPANION_WORN] = IIfA:IsCompanionEquipIgnored()
  IIfA.trackedBags[BAG_BACKPACK] = not IIfA:IsCharacterInventoryIgnored()

  IIfA.bAddContextMenuEntrySearchInIIfA = IIFA_DATABASE[IIfA.currentAccount].settings.bAddContextMenuEntrySearchInIIfA
  IIfA.bAddContextMenuEntryMissingMotifsInIIfA = IIFA_DATABASE[IIfA.currentAccount].settings.bAddContextMenuEntryMissingMotifsInIIfA

  IIfA:CollectAllUseAsync()
end

EVENT_MANAGER:RegisterForEvent("IIfALoaded", EVENT_ADD_ON_LOADED, IIfA_onLoad)

function IIfA:SetupGuildBanks()
  local serverData = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType]
  serverData.guildBankInfo = serverData.guildBankInfo or {}
  serverData.GuildIdToName = serverData.GuildIdToName or {}
  serverData.GuildNameToId = serverData.GuildNameToId or {}

  for index = 1, GetNumGuilds() do
    local guildId = GetGuildId(index)
    local guildName = GetGuildName(guildId)
    if not serverData.guildBankInfo[guildName] then
      serverData.guildBankInfo[guildName] = {
        bCollectData = false,
        items = 0,
      }
    end
    serverData.GuildIdToName[guildId] = guildName
    serverData.GuildNameToId[guildName] = guildId
  end

  for guildName, guildData in pairs(serverData.guildBankInfo) do
    if guildName == IIfA.EMPTY_STRING then
      serverData.guildBankInfo[guildName] = nil
      IIfA:dm("Warn", "Removed empty guildName entry from guildBankInfo.")
    end
  end
end

function IIfA:ScanCurrentCharacterAndBank()
  IIfA:dm("Debug", "[ScanCurrentCharacterAndBank] Starting...")
  IIfA:ScanBank()
  IIfA:ScanCurrentCharacter()
  --	zo_callLater(function()
  --		IIfA:MakeBSI()
  --	end, 5000)
end

function IIfA:MakeBSI()
  local bagSlotInfo = {}

  -- Access DBv3 from IIFA_DATABASE
  local DBv3 = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType].DBv3

  -- Iterate over all items in DBv3
  for itemKey, itemData in pairs(DBv3) do
    if itemData.locations then
      -- Iterate over all locations for the item
      for location, locationData in pairs(itemData.locations) do
        local isBackpackOrWornForPlayer = ((locationData.bagID == BAG_BACKPACK or locationData.bagID == BAG_WORN) and location == IIfA.currentCharacterId)
        local isCompanionEquippedBag = ((locationData.bagID == BAG_COMPANION_WORN) and location == IIfA.currentCompanionId)
        local isNonBackpackOrWornBag = (locationData.bagID ~= BAG_BACKPACK and locationData.bagID ~= BAG_WORN and locationData.bagID ~= BAG_COMPANION_WORN)

        if locationData.bagID and locationData.bagSlot then
          if isBackpackOrWornForPlayer or isCompanionEquippedBag or isNonBackpackOrWornBag then
            local bagID = locationData.bagID

            -- Handle the special case for guild bank (use location name instead of bagID)
            if bagID == BAG_GUILDBANK then
              bagID = location or "Unknown Guild Bank"
            end

            -- Ensure the bagSlotInfo table for this bagID exists
            bagSlotInfo[bagID] = bagSlotInfo[bagID] or {}

            -- Handle the case where bagSlot might be a scalar (not a table)
            -- Iterate over the bagSlots (in case bagSlot is a table)
            for slotIndex, itemCount in pairs(locationData.bagSlot) do
              -- Assign either the itemLink or itemKey to the correct slot
              bagSlotInfo[bagID][slotIndex] = itemKey  -- Storing the itemKey here
              -- You can store the itemLink as well if needed: bagSlotInfo[bagID][slotIndex] = itemLink
            end
          end
        end
      end
    end
  end

  -- Store the constructed bagSlotInfo table
  IIfA.BagSlotInfo = bagSlotInfo
end

--[[
for reference

GetCurrentCharacterId()
Returns: string id

GetNumCharacters()
Returns: integer numCharacters

GetCharacterInfo(luaindex index)
Returns: string name,
		[Gender|#Gender] gender,
		integer level,
		integer classId,
		integer raceId,
		[Alliance|#Alliance] alliance,
		string id,
		integer locationId
__________________
	--]]

function IIfA:UpdateCompanionCharLookups()
  if not HasActiveCompanion() then
    return
  end

  -- Get current companion data
  local currentCompanionName = IIfA:GetCurrentCompanionName()
  local companionNameHash = IIfA:GetCurrentCompanionHashId()

  -- Access the companion data tables in the new structure
  local serverData = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType]
  serverData.CompanionIdToName = serverData.CompanionIdToName or {}
  serverData.CompanionNameToId = serverData.CompanionNameToId or {}

  -- Update the lookups in the new structure
  serverData.CompanionIdToName[companionNameHash] = currentCompanionName
  serverData.CompanionNameToId[currentCompanionName] = companionNameHash
end

function IIfA:SetupCharLookups()
  local serverData = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType]
  serverData.CharIdToName = serverData.CharIdToName or {}
  serverData.CharNameToId = serverData.CharNameToId or {}

  for i = 1, GetNumCharacters() do
    local charName, _, _, _, _, _, charId, _ = GetCharacterInfo(i)
    charName = ZO_CachedStrFormat(SI_UNIT_NAME, charName)

    serverData.CharIdToName[charId] = charName
    serverData.CharNameToId[charName] = charId
  end

  IIfA:UpdateCompanionCharLookups()
end

function IIfA:ConvertNameToId()
  -- run list of dbv2 items, change names to ids
  -- ignore attributes, and anything that's in guild bank list
  -- remaining items are character names (or should be)
  -- if found in CharNameToId, convert it, otherwise erase whole entry (since it's an orphan)
  -- do same for settings
  local tbl = IIfA.data.DBv2
  if tbl == nil or tbl == {} then return end
  for itemLink, DBItem in pairs(IIfA.data.DBv2) do
    for itemDetailName, itemInfo in pairs(DBItem) do
      local bagID = itemInfo.locationType
      if bagID ~= nil then
        if bagID == BAG_BACKPACK or bagID == BAG_WORN then
          if IIfA.CharNameToId[itemDetailName] ~= nil then
            --					d("Swapping name to # -- " .. itemLink .. ", " )
            DBItem[IIfA.CharNameToId[itemDetailName]] = DBItem[itemDetailName]
            DBItem[itemDetailName] = nil
          end
        end
      end
    end
  end
end

-- used for testing - wipes all craft bag data
function IIfA:clearvbag()
  -- Access DBv3 from IIFA_DATABASE
  local DBv3 = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType].DBv3

  for itemLink, DBItem in pairs(DBv3) do
    for locationName, locData in pairs(DBItem.locations) do
      if locData.bagID == BAG_VIRTUAL then
        DBItem.locations[locationName] = nil
      end
    end
  end
end
