-- First, we create a namespace for our addon by declaring a top-level table that will hold everything else.
GBMule = {}

-- This isn't strictly necessary, but we'll use this string later when registering events.
-- Better to define it in a single place rather than retyping the same string.
GBMule.name = "GBMule"
GBMule.version = "0.1.1"
GBMule.url = "https://www.esoui.com/downloads/info3271-GuildBankMule.html"
local settings
local defaultSettings = {
  blacksmith = true,
  woodworking = true,
  clothing = true,
  alchemy = true,
  enchanting = true,
  provisioning = true,
  jewelry = true,
  trait = true,
  style = true,
  furnishing = true,
  debugging = false
}
local debugging = false
local DumpsterIdx = {}
local Dumpster = {}

local ready = false
local waitStarted = false
local startingRoomba = false

local function dd(msg)
  d("[" .. GBMule.name .. "]: " .. msg)
end

local function ddd(msg)
  if debugging then
    dd(msg)
  end
end

local function InitializeMenu()
  settings = LibSavedVars:NewAccountWide(GBMule.name .. "_Account", defaultSettings)
  settings:AddCharacterSettingsToggle(GBMule.name .. "_Characters")
  settings:MigrateFromAccountWide( { name = GBMule.name .. "_Account" } )
  if LSV_Data.EnableDefaultsTrimming then
    settings:EnableDefaultsTrimming()
  end
  debugging = settings.debugging
  local LAM = LibAddonMenu2
  local panelName = "Guild Bank Mule"
  local panelData = {
    type = "panel",
    name = "Guild Bank Mule",
    author = "@Xorzoo",
    version = GBMule.version,
    website = GBMule.url,
    registerForRefresh = true,
    registerForDefaults = true
  }
  LAM:RegisterAddonPanel(panelName, panelData)
  local optionsData = {
    -- Account-wide settings
    settings:GetLibAddonMenuAccountCheckbox(),
    {
      type = "header",
      name = "Options",
      width = "full",	--or "half" (optional)
    },
    {
      type = "checkbox",
      name = "Max Level Materials",
      tooltip = "Include CP160 Materials",
      getFunc = function() return settings.max_mat end,
      setFunc = function(value) settings.max_mat = value end,
      width = "full",
      default = false
    },
    {
      type = "checkbox",
      name = "Valuable",
      tooltip = "Include Gold Materials, Nirnhoned, Jewelry Plating, Hakeijo Indeko",
      getFunc = function() return settings.valuable end,
      setFunc = function(value) settings.valuable = value end,
      width = "full",
      default = false
    },
    {
      type = "submenu",
      name = "Crafting",
      controls = {
        {
          type = "checkbox",
          name = "Blacksmith",
          getFunc = function() return settings.blacksmith end,
          setFunc = function(value) settings.blacksmith = value end,
          default = true
        },
        {
          type = "checkbox",
          name = "Woodworkding",
          getFunc = function() return settings.woodworking end,
          setFunc = function(value) settings.woodworking = value end,
          default = true
        },
        {
          type = "checkbox",
          name = "Clothing",
          getFunc = function() return settings.clothing end,
          setFunc = function(value) settings.clothing = value end,
          default = true
        }
      }
    },
    {
      type = "submenu",
      name = "Consumable",
      controls = {
        {
          type = "checkbox",
          name = "Alchemy",
          getFunc = function() return settings.alchemy end,
          setFunc = function(value) settings.alchemy = value end,
          default = true
        },
        {
          type = "checkbox",
          name = "Enchanting",
          getFunc = function() return settings.enchanting end,
          setFunc = function(value) settings.enchanting = value end,
          default = true
        },
        {
          type = "checkbox",
          name = "Provisioning",
          getFunc = function() return settings.provisioning end,
          setFunc = function(value) settings.provisioning = value end,
          default = true
        }
      }
    },
    {
      type = "submenu",
      name = "Other",
      controls = {
        {
          type = "checkbox",
          name = "Jewelry",
          getFunc = function() return settings.jewelry end,
          setFunc = function(value) settings.jewelry = value end,
          default = true
        },
        {
          type = "checkbox",
          name = "Trait",
          getFunc = function() return settings.trait end,
          setFunc = function(value) settings.trait = value end,
          default = true
        },
        {
          type = "checkbox",
          name = "Style",
          getFunc = function() return settings.style end,
          setFunc = function(value) settings.style = value end,
          default = true
        },
        {
          type = "checkbox",
          name = "Furnishing",
          getFunc = function() return settings.furnishing end,
          setFunc = function(value) settings.furnishing = value end,
          default = true
        }
      }
    },
    {
      type = "checkbox",
      name = "Debugging",
      getFunc = function() return settings.debugging end,
      setFunc = function(value)
        settings.debugging = value
        debugging = value
      end,
      default = false
    },
  }
  LAM:RegisterOptionControls(panelName, optionsData)
end

local function toDumpOrNotToDump(slotIndex)
  if IsItemJunk(BAG_BACKPACK, slotIndex) then
    return false
  end
  if GetItemBindType(BAG_BACKPACK, slotIndex) ~= BIND_TYPE_NONE then
    return false
  end
  local itemLink = GetItemLink(BAG_BACKPACK, slotIndex)
  if IsItemLinkStolen(itemLink) then
    return false
  end
  local itemType, specializedItemType = GetItemLinkItemType(itemLink)
  local icon, stack, sellPrice, meetsUsageRequirements, locked, equipType, itemStyle, functionalQuality, displayQuality = GetItemInfo(BAG_BACKPACK, slotIndex)
  local guildName, color, linkType, itemId = ZO_LinkHandler_ParseLink(itemLink)
  local level = GetItemLevel(BAG_BACKPACK, slotIndex)

  -- [blacksmith] --
  if (itemType == ITEMTYPE_BLACKSMITHING_MATERIAL and settings.blacksmith) then
    if (settings.max_mat or itemId ~= "64489") then
      ddd("ITEMTYPE_BLACKSMITHING_MATERIAL")
      return true
    end
  elseif (itemType == ITEMTYPE_BLACKSMITHING_RAW_MATERIAL and settings.blacksmith) then
    if (settings.max_mat or itemId ~= "71198") then
      ddd("ITEMTYPE_BLACKSMITHING_RAW_MATERIAL")
      return true
    end
  elseif (itemType == ITEMTYPE_BLACKSMITHING_BOOSTER and settings.blacksmith) then
    if itemId ~= "54173" then -- Tempering Alloy
      ddd("ITEMTYPE_BLACKSMITHING_BOOSTER")
      return true
    elseif settings.valuable then
      ddd("ITEMTYPE_BLACKSMITHING_BOOSTER")
      dd("Valuable")
      return true
    end
  -- [clothing] --
  elseif (itemType == ITEMTYPE_CLOTHIER_MATERIAL and settings.clothing) then
    if (settings.max_mat) then
      ddd("ITEMTYPE_CLOTHIER_MATERIAL")
      return true
    elseif (itemId ~= "64504" and itemId ~= "64506") then
      ddd("ITEMTYPE_CLOTHIER_MATERIAL")
      return true
    end
  elseif (itemType == ITEMTYPE_CLOTHIER_RAW_MATERIAL and settings.clothing) then
    if (settings.max_mat) then
      ddd("ITEMTYPE_CLOTHIER_RAW_MATERIAL")
      return true
    elseif (itemId ~= "71200" and itemId ~= "71239") then
      ddd("ITEMTYPE_CLOTHIER_RAW_MATERIAL")
      return true
    end
  elseif (itemType == ITEMTYPE_CLOTHIER_BOOSTER and settings.clothing) then
    if itemId ~= "54177" then -- Dreugh Wax
      ddd("ITEMTYPE_CLOTHIER_BOOSTER")
      return true
    elseif settings.valuable then
      ddd("ITEMTYPE_CLOTHIER_BOOSTER")
      dd("Valuable")
      return true
    end
  -- [woodworking] --
  elseif (itemType == ITEMTYPE_WOODWORKING_MATERIAL and settings.woodworking) then
    if (settings.max_mat or itemId ~= "64502") then
      ddd("ITEMTYPE_WOODWORKING_MATERIAL")
      return true
    end
  elseif (itemType == ITEMTYPE_WOODWORKING_RAW_MATERIAL and settings.woodworking) then
    if (settings.max_mat or itemId ~= "71199") then
      ddd("ITEMTYPE_WOODWORKING_RAW_MATERIAL")
      return true
    end
  elseif (itemType == ITEMTYPE_WOODWORKING_BOOSTER and settings.woodworking) then
    if itemId ~= "54181" then -- Rosin
      ddd("ITEMTYPE_WOODWORKING_BOOSTER")
      return true
    elseif settings.valuable then
      ddd("ITEMTYPE_WOODWORKING_BOOSTER")
      dd("Valuable")
      return true
    end
  -- [jewelry] --
  elseif (itemType == ITEMTYPE_JEWELRYCRAFTING_MATERIAL and settings.jewelry) then
    if (settings.max_mat or itemId ~= "135146") then
      ddd("ITEMTYPE_JEWELRYCRAFTING_MATERIAL")
      return true
    end
  elseif (itemType == ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL and settings.jewelry) then
    if (settings.max_mat or itemId ~= "135145") then
      ddd("ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL")
      return true
    end
  elseif (itemType == ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER or itemType == ITEMTYPE_JEWELRYCRAFTING_BOOSTER) and settings.jewelry then
    if settings.valuable then -- Plating
      ddd("ITEMTYPE_JEWELRYCRAFTING_RAW/BOOSTER")
      dd("Valuable")
      return true
    end
  -- [style] --
  elseif (itemType == ITEMTYPE_RAW_MATERIAL or itemType == ITEMTYPE_STYLE_MATERIAL) and settings.style then
      ddd("ITEMTYPE_RAW/STYLE_MATERIAL")
      return true
  -- [trait] --
  elseif (itemType == ITEMTYPE_ARMOR_TRAIT or itemType == ITEMTYPE_WEAPON_TRAIT) and settings.trait then
      if itemId ~= "56862" and itemId ~= "56863" then -- Nirnhoned
        ddd("ITEMTYPE_ARMOR/WEAPON_TRAIT")
        return true
      elseif settings.valuable then
        ddd("ITEMTYPE_ARMOR/WEAPON_TRAIT")
        dd("Valuable")
        return true
      end
  -- [jewel trait] --
  elseif (itemType == ITEMTYPE_JEWELRY_TRAIT or itemType == ITEMTYPE_JEWELRY_RAW_TRAIT) and settings.trait then
      dd("ITEMTYPE_JEWELRY/RAW_TRAIT")
      return true
  -- [alchemy] --
  elseif itemType == ITEMTYPE_REAGENT or itemType == ITEMTYPE_SOLVENT or itemType == ITEMTYPE_POTION_BASE or itemType == ITEMTYPE_POISON_BASE then
    if settings.alchemy then
      ddd("ITEMTYPE_REAGENT/SOLVENT/POTION_BASE/POISON_BASE")
      return true
    end
  -- [provisioning] --
  elseif itemType == ITEMTYPE_INGREDIENT and settings.provisioning then
    ddd("ITEMTYPE_INGREDIENT")
    return true
  -- [enchanting] --
  elseif (itemType == ITEMTYPE_ENCHANTING_RUNE_ASPECT
    or itemType == ITEMTYPE_ENCHANTING_RUNE_ESSENCE
    or itemType == ITEMTYPE_ENCHANTING_RUNE_POTENCY) and settings.enchanting then
      ddd("itemId: " .. itemId)
      if itemId ~= "68342" and itemId ~= "166045" then -- Hakeijo Indeko
        ddd("ITEMTYPE_ENCHANTING_RUNE_*")
        return true
      elseif settings.valuable then
        ddd("ITEMTYPE_ENCHANTING_RUNE_*")
        dd("Valuable")
        return true
      end
  elseif (specializedItemType == SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_ALCHEMY
    or specializedItemType == SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_CLOTHIER
    or specializedItemType == SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_PROVISIONING
    or specializedItemType == SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_WOODWORKING
    or specializedItemType == SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_ENCHANTING
    or specializedItemType == SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_JEWELRYCRAFTING
    or specializedItemType == SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_BLACKSMITHING) and settings.furnishing then
      ddd("SPECIALIZED_ITEMTYPE_FURNISHING_*")
      return true
  else
    --d("itemType" .. itemType)
    return false
  end
end

local function printInDumpster(idx)
  local obj = Dumpster[idx]
  if not obj then
    return
  end
  local itemLink = GetItemLink(BAG_BACKPACK, obj.slotIndex)
  return (itemLink .. " * " .. obj.stack)
end

local function scanStuff()
  -- We only need to store slots with items
  local bagToScan = SHARED_INVENTORY:GenerateFullSlotData(nil, BAG_BACKPACK)
  -- always clear result since options can change
  Dumpster = {}
  DumpsterIdx = {}
  dd("Scanning BAG_BACKPACK: " .. #bagToScan .. " item(s)")
  dd("----------")
  for index, slot in pairs(bagToScan) do
    if toDumpOrNotToDump(slot.slotIndex) then
      table.insert(DumpsterIdx, slot.slotIndex)
      Dumpster[slot.slotIndex] = {["name"] = slot.name, ["stack"] = GetSlotStackSize(BAG_BACKPACK, slot.slotIndex), ["slotIndex"] = slot.slotIndex}
      dd(printInDumpster(slot.slotIndex))
      dd("----------")
    end
  end
  dd(#DumpsterIdx .. " item(s) will be deposited in guild bank")
end

local function startRoomba()
  if not Roomba then
    ddd("No Roomba")
    return
  end
  if Roomba.WorkInProgress() then
    dd("Roomba started")
	startingRoomba = false
  else
    dd("Starting Roomba...")
	Roomba.RestackGuildbank()
    zo_callLater(startRoomba, 500)
  end
end

local function continueTransfer()
  if not Roomba then
    ddd("No Roomba")
  end
  if Roomba and not Roomba.WorkInProgress() then
    ddd("Roomba not in progress")
  end
  if Roomba and Roomba.WorkInProgress() then
    ddd("Waiting for Roomba...")
    zo_callLater(continueTransfer, 500)
    return
  end
  waitStarted = false
  dd("Done: " .. printInDumpster(DumpsterIdx[1]) .. " (" .. #DumpsterIdx .. " left)")
  Dumpster[DumpsterIdx[1]] = nil
  table.remove(DumpsterIdx, 1)
  if #DumpsterIdx > 0 then
    TransferToGuildBank(BAG_BACKPACK, DumpsterIdx[1])
  else
    EVENT_MANAGER:UnregisterForEvent(GBMule.name, EVENT_GUILD_BANK_ITEM_ADDED)
    EVENT_MANAGER:RegisterForEvent(GBMule.name, EVENT_GUILD_BANK_TRANSFER_ERROR)
    dd("All Done")
  end
end

local function OnGuildBankTransferError(_, errorCode)
  -- not related
  if #DumpsterIdx == 0 then
    return
  end
  if not Dumpster[DumpsterIdx[1]] then
    return
  end
  if not ready then
    return
  end
  ddd("OnGuildBankTransferError")
  if errorCode == GUILD_BANK_SUCCESS then
    ddd("GUILD_BANK_SUCCESS")
    return
  elseif errorCode == GUILD_BANK_UNAVAILABLE or errorCode == GUILD_BANK_NO_SPACE_LEFT then
    if errorCode == GUILD_BANK_UNAVAILABLE then
      dd("GUILD_BANK_UNAVAILABLE ")
    end
    if errorCode == GUILD_BANK_NO_SPACE_LEFT then
      dd("GUILD_BANK_NO_SPACE_LEFT ")
    end
    -- dd("No Space Left?")
--     EVENT_MANAGER:UnregisterForEvent(GBMule.name, EVENT_GUILD_BANK_ITEM_ADDED)
--     EVENT_MANAGER:RegisterForEvent(GBMule.name, EVENT_GUILD_BANK_TRANSFER_ERROR)
    if Roomba then
      dd("Roomba Restacking...")
      startingRoomba = true
	    startRoomba()
      --- zo_callLater(Roomba.RestackGuildbank, 500)
      --- Roomba.RestackGuildbank()
      return
    end
  elseif errorCode == GUILD_BANK_ITEM_NOT_FOUND then
    ddd("GUILD_BANK_ITEM_NOT_FOUND")
  elseif errorCode == GUILD_BANK_TRANSFER_PENDING then
    ddd("GUILD_BANK_TRANSFER_PENDING")
  elseif errorCode == GUILD_BANK_CANT_BE_STORED then
    ddd("GUILD_BANK_CANT_BE_STORED")
  elseif errorCode == GUILD_BANK_NO_DEPOSIT_PERMISSION then
    dd("No Deposit Permssion")
    EVENT_MANAGER:UnregisterForEvent(GBMule.name, EVENT_GUILD_BANK_ITEM_ADDED)
    EVENT_MANAGER:RegisterForEvent(GBMule.name, EVENT_GUILD_BANK_TRANSFER_ERROR)
    return
  else
    --https://wiki.esoui.com/Globals
    ddd("errorCode: " .. errorCode)
  end
  continueTransfer()
end

local function OnGuildBankItemAdded(eventCode, slotIndex, updatedByLocalPlayer)
  if not ready then
    return
  end
  if #DumpsterIdx == 0 then
    return
  end
  if not updatedByLocalPlayer then
    return
  end
  if Roomba and Roomba.WorkInProgress() then
    --- ddd("Roomba running...")
    if not waitStarted then
      waitStarted = true
      continueTransfer()
    end
    return
  end
  continueTransfer()
end

local function Initialize()
    InitializeMenu()
end

-- CMD
local function cmdHandler()
  if ready then
    dd("Guild Bank Ready")
    if Roomba and Roomba.WorkInProgress() then
      dd("Roomba Work In Progress, Please Wait...")
      return
    end
    scanStuff()
    EVENT_MANAGER:RegisterForEvent(GBMule.name, EVENT_GUILD_BANK_ITEM_ADDED, OnGuildBankItemAdded)
    EVENT_MANAGER:RegisterForEvent(GBMule.name, EVENT_GUILD_BANK_TRANSFER_ERROR, OnGuildBankTransferError)
    if #DumpsterIdx > 0 then
      local first = DumpsterIdx[1]
      TransferToGuildBank(BAG_BACKPACK, first)
    else
      ddd("Nothing to Dump")
    end
  else
    dd("Guild Bank Not Open or Not Ready")
  end
end

local function printDumpsterSize()
    dd("Dumpster Size: " .. #DumpsterIdx)
end

-- Then we create an event handler function which will be called when the "addon loaded" event
-- occurs. We'll use this to initialize our addon after all of its resources are fully loaded.
function GBMule.OnAddOnLoaded(event, addonName)
  -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
  if addonName == GBMule.name then
      Initialize()
      EVENT_MANAGER:UnregisterForEvent(GBMule.name, EVENT_ADD_ON_LOADED)
  end
end

local function OnCloseGuildBank()
  ready = false
  EVENT_MANAGER:UnregisterForEvent(GBMule.name, EVENT_GUILD_BANK_ITEM_ADDED)
  EVENT_MANAGER:RegisterForEvent(GBMule.name, EVENT_GUILD_BANK_TRANSFER_ERROR)
end

local function OnGuildBankReallyReady()
  ready = true
end

local function OnGuildBankReady()
  -- Guild bank is evented to be ready, but wait a short while before processing. (multiple readys for big banks ~3/4)
  zo_callLater(function() OnGuildBankReallyReady() end, 200)
end

-- Finally, we'll register our event handler function to be called when the proper event occurs.
EVENT_MANAGER:RegisterForEvent(GBMule.name, EVENT_ADD_ON_LOADED, GBMule.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(GBMule.name, EVENT_GUILD_BANK_ITEMS_READY, OnGuildBankReady)

EVENT_MANAGER:RegisterForEvent(GBMule.name, EVENT_CLOSE_GUILD_BANK, OnCloseGuildBank)

--SLASH COMMAND REGISTRATION
-- simply add our slash command to the list, and tell it which function to run
SLASH_COMMANDS["/gbm.size"] = printDumpsterSize
SLASH_COMMANDS["/gbm.scan"] = scanStuff
SLASH_COMMANDS["/gbm"] = cmdHandler
