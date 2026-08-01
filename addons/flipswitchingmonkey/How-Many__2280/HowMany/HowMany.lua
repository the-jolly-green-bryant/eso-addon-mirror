local LAM = LibStub("LibAddonMenu-2.0")

HowMany = {}
HowMany.name = "HowMany"
HowMany.qualityLabels = {
  [1] = "Normal",
  [2] = "|c2DC50EUncommon|r",
  [3] = "|c3A92FFRare|r",
  [4] = "|cA02EF7Epic|r"
}
local itemTypesTable = {
  [1] = { name="ITEMTYPE_ARMOR", val=ITEMTYPE_ARMOR },
  [2] = { name="ITEMTYPE_ARMOR_BOOSTER", val=ITEMTYPE_ARMOR_BOOSTER },
  [3] = { name="ITEMTYPE_ARMOR_TRAIT", val=ITEMTYPE_ARMOR_TRAIT },
  [4] = { name="ITEMTYPE_AVA_REPAIR", val=ITEMTYPE_AVA_REPAIR },
  [5] = { name="ITEMTYPE_BLACKSMITHING_BOOSTER", val=ITEMTYPE_BLACKSMITHING_BOOSTER },
  [6] = { name="ITEMTYPE_BLACKSMITHING_MATERIAL", val=ITEMTYPE_BLACKSMITHING_MATERIAL },
  [7] = { name="ITEMTYPE_BLACKSMITHING_RAW_MATERIAL", val=ITEMTYPE_BLACKSMITHING_RAW_MATERIAL },
  [8] = { name="ITEMTYPE_CLOTHIER_BOOSTER", val=ITEMTYPE_CLOTHIER_BOOSTER },
  [9] = { name="ITEMTYPE_CLOTHIER_MATERIAL", val=ITEMTYPE_CLOTHIER_MATERIAL },
  [10] = { name="ITEMTYPE_CLOTHIER_RAW_MATERIAL", val=ITEMTYPE_CLOTHIER_RAW_MATERIAL },
  [11] = { name="ITEMTYPE_COLLECTIBLE", val=ITEMTYPE_COLLECTIBLE },
  [12] = { name="ITEMTYPE_CONTAINER", val=ITEMTYPE_CONTAINER },
  [13] = { name="ITEMTYPE_COSTUME", val=ITEMTYPE_COSTUME },
  [14] = { name="ITEMTYPE_CROWN_ITEM", val=ITEMTYPE_CROWN_ITEM },
  [15] = { name="ITEMTYPE_CROWN_REPAIR", val=ITEMTYPE_CROWN_REPAIR },
  [16] = { name="ITEMTYPE_DISGUISE", val=ITEMTYPE_DISGUISE },
  [17] = { name="ITEMTYPE_DRINK", val=ITEMTYPE_DRINK },
  [18] = { name="ITEMTYPE_DYE_STAMP", val=ITEMTYPE_DYE_STAMP },
  [19] = { name="ITEMTYPE_ENCHANTING_RUNE_ASPECT", val=ITEMTYPE_ENCHANTING_RUNE_ASPECT },
  [20] = { name="ITEMTYPE_ENCHANTING_RUNE_ESSENCE", val=ITEMTYPE_ENCHANTING_RUNE_ESSENCE },
  [21] = { name="ITEMTYPE_ENCHANTING_RUNE_POTENCY", val=ITEMTYPE_ENCHANTING_RUNE_POTENCY },
  [22] = { name="ITEMTYPE_ENCHANTMENT_BOOSTER", val=ITEMTYPE_ENCHANTMENT_BOOSTER },
  [23] = { name="ITEMTYPE_FISH", val=ITEMTYPE_FISH },
  [24] = { name="ITEMTYPE_FLAVORING", val=ITEMTYPE_FLAVORING },
  [25] = { name="ITEMTYPE_FOOD", val=ITEMTYPE_FOOD },
  [26] = { name="ITEMTYPE_FURNISHING", val=ITEMTYPE_FURNISHING },
  [27] = { name="ITEMTYPE_FURNISHING_MATERIAL", val=ITEMTYPE_FURNISHING_MATERIAL },
  [28] = { name="ITEMTYPE_GLYPH_ARMOR", val=ITEMTYPE_GLYPH_ARMOR },
  [29] = { name="ITEMTYPE_GLYPH_JEWELRY", val=ITEMTYPE_GLYPH_JEWELRY },
  [30] = { name="ITEMTYPE_GLYPH_WEAPON", val=ITEMTYPE_GLYPH_WEAPON },
  [31] = { name="ITEMTYPE_INGREDIENT", val=ITEMTYPE_INGREDIENT },
  [32] = { name="ITEMTYPE_JEWELRYCRAFTING_BOOSTER", val=ITEMTYPE_JEWELRYCRAFTING_BOOSTER },
  [33] = { name="ITEMTYPE_JEWELRYCRAFTING_MATERIAL", val=ITEMTYPE_JEWELRYCRAFTING_MATERIAL },
  [34] = { name="ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER", val=ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER },
  [35] = { name="ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL", val=ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL },
  [36] = { name="ITEMTYPE_JEWELRY_RAW_TRAIT", val=ITEMTYPE_JEWELRY_RAW_TRAIT },
  [37] = { name="ITEMTYPE_JEWELRY_TRAIT", val=ITEMTYPE_JEWELRY_TRAIT },
  [38] = { name="ITEMTYPE_LOCKPICK", val=ITEMTYPE_LOCKPICK },
  [39] = { name="ITEMTYPE_LURE", val=ITEMTYPE_LURE },
  [40] = { name="ITEMTYPE_MASTER_WRIT", val=ITEMTYPE_MASTER_WRIT },
  [41] = { name="ITEMTYPE_MOUNT", val=ITEMTYPE_MOUNT },
  [42] = { name="ITEMTYPE_POISON", val=ITEMTYPE_POISON },
  [43] = { name="ITEMTYPE_POISON_BASE", val=ITEMTYPE_POISON_BASE },
  [44] = { name="ITEMTYPE_POTION", val=ITEMTYPE_POTION },
  [45] = { name="ITEMTYPE_POTION_BASE", val=ITEMTYPE_POTION_BASE },
  [46] = { name="ITEMTYPE_RACIAL_STYLE_MOTIF", val=ITEMTYPE_RACIAL_STYLE_MOTIF },
  [47] = { name="ITEMTYPE_RAW_MATERIAL", val=ITEMTYPE_RAW_MATERIAL },
  [48] = { name="ITEMTYPE_REAGENT", val=ITEMTYPE_REAGENT },
  [49] = { name="ITEMTYPE_RECIPE", val=ITEMTYPE_RECIPE },
  [50] = { name="ITEMTYPE_SIEGE", val=ITEMTYPE_SIEGE },
  [51] = { name="ITEMTYPE_SOUL_GEM", val=ITEMTYPE_SOUL_GEM },
  [52] = { name="ITEMTYPE_SPELLCRAFTING_TABLET", val=ITEMTYPE_SPELLCRAFTING_TABLET },
  [53] = { name="ITEMTYPE_SPICE", val=ITEMTYPE_SPICE },
  [54] = { name="ITEMTYPE_STYLE_MATERIAL", val=ITEMTYPE_STYLE_MATERIAL },
  [55] = { name="ITEMTYPE_TABARD", val=ITEMTYPE_TABARD },
  [56] = { name="ITEMTYPE_TOOL", val=ITEMTYPE_TOOL },
  [57] = { name="ITEMTYPE_TRASH", val=ITEMTYPE_TRASH },
  [58] = { name="ITEMTYPE_TREASURE", val=ITEMTYPE_TREASURE },
  [59] = { name="ITEMTYPE_TROPHY", val=ITEMTYPE_TROPHY },
  [60] = { name="ITEMTYPE_WEAPON", val=ITEMTYPE_WEAPON },
  [61] = { name="ITEMTYPE_WEAPON_BOOSTER", val=ITEMTYPE_WEAPON_BOOSTER },
  [62] = { name="ITEMTYPE_WEAPON_TRAIT", val=ITEMTYPE_WEAPON_TRAIT },
  [63] = { name="ITEMTYPE_WOODWORKING_BOOSTER", val=ITEMTYPE_WOODWORKING_BOOSTER },
  [64] = { name="ITEMTYPE_WOODWORKING_MATERIAL", val=ITEMTYPE_WOODWORKING_MATERIAL },
  [65] = { name="ITEMTYPE_WOODWORKING_RAW_MATERIAL", val=ITEMTYPE_WOODWORKING_RAW_MATERIAL },
}

local panelData = {
  type = "panel",
  name = "How Many",
  displayName = "How Many - Settings",
  author = "flipswitchingmonkey",
  version = "1.0",
  slashCommand = "/howmanysettings",	--(optional) will register a keybind to open to this panel
  registerForRefresh = true,	--boolean (optional) (will refresh all options controls when a setting is changed and when the panel is shown)
  registerForDefaults = true,	--boolean (optional) (will set all options controls back to default values)
}

local optionsTable = {
  -- [1] = {
  --     type = "header",
  --     name = "My Header",
  --     width = "full",	--or "half" (optional)
  -- },
  [1] = {
      type = "description",
      --title = "My Title",	--(optional)
      title = nil,	--(optional)
      text = "This addon lists your current loot and how many of each item you already own. It can also list your group members' loot (limited by quality)",
      width = "full",	--or "half" (optional)
  },
  [2] = {
    type = "checkbox",
    name = "Enable",
    tooltip = "Enable/Disable How Many",
    getFunc = function() return HowMany.savedVariables.enabled end,
    setFunc = function(value) HowMany.Enable(value) end,
    width = "half",
    -- warning = "Will need to reload the UI.",	--(optional)
  },
  [3] = {
    type = "description",
    --title = "My Title",	--(optional)
    title = nil,	--(optional)
    text = "",
    width = "half",	--or "half" (optional)
  },
  [4] = {
    type = "checkbox",
    name = "Use Master Merchant",
    tooltip = "Look up Master Merchant avg price if available",
    getFunc = function() return HowMany.savedVariables.useMasterMerchant end,
    setFunc = function(value) HowMany.UseMasterMerchant(value) end,
    width = "half",
  },
  [5] = {
    type = "checkbox",
    name = "Use Arkadius Trade Tools",
    tooltip = "Look up Arkadius Trade Tools avg price if available",
    getFunc = function() return HowMany.savedVariables.useArkadiusTradeTools end,
    setFunc = function(value) HowMany.UseArkadiusTradeTools(value) end,
    width = "half",
  },
  [6] = {
    type = "checkbox",
    name = "Show Group Loot",
    tooltip = "Show group loot as well as own",
    getFunc = function() return HowMany.savedVariables.group end,
    setFunc = function(value) HowMany.ShowGroupLoot(value) end,
    width = "half",
  },
  [7] = {
      type = "dropdown",
      name = "Filter Group Loot",
      tooltip = "Only show group loot of this quality or better.",
      choices = {"Normal", "|c2DC50EUncommon|r", "|c3A92FFRare|r", "|cA02EF7Epic|r"},
      getFunc = function() return HowMany.qualityLabels[HowMany.savedVariables.minGroupItemQuality] end,
      setFunc = function(var) HowMany.SetMinGroupItemQualityByLabel(var) end,
      width = "half",
  },
  -- [6] = {
  --   type = "submenu",
  --   name = "Filter Item Types",
  --   tooltip = "Enable/Disable the reporting of certain item types",
  --   controls = {
  [8] = {
      type = "header",
      name = "Filter Items Types",
      reference = "FilterHeader",
      width = "full",
  },
  [9] = {
      type = "button",
      name = "Enable all",
      tooltip = "Enables all item types.",
      func = function() HowMany.SetFilters(true) end,
      width = "half",
  },
  [10] = {
      type = "button",
      name = "Disable all",
      tooltip = "Disables all item types.",
      func = function() HowMany.SetFilters(false) end,
      width = "half",
  },
    --       },
    -- },
}


function HowMany:Initialize()
  -- SET UP SAVED VARIABLES FOR OFFLINE STORAGE
  local defaults = {
    enabled = true,
    group = false,
    minGroupItemQuality = 3,
    filter = {},
    useMasterMerchant = true,
    useArkadiusTradeTools = true,
  }
  for key, value in ipairs(itemTypesTable) do
    defaults["filter"][value["val"]] = true
  end
  self.savedVariables = ZO_SavedVars:NewAccountWide("HowManySavedVariables", 1, nil, defaults)

  -- REGISTER SLASH COMMANDS
  SLASH_COMMANDS["/howmany"] = HowMany.ManageEvent
    
  -- FILL ITEM TYPES
  for key, value in ipairs(itemTypesTable) do
    local label = string.gsub(string.gsub(value["name"], "ITEMTYPE_",""), "_", " ")
    -- table.insert(optionsTable[6]["controls"], {
    table.insert(optionsTable, {
      type = "checkbox",
      name = label,
      getFunc = function() return HowMany.savedVariables["filter"][value["val"]] end,
      setFunc = function(state) HowMany.savedVariables["filter"][value["val"]]=state end,
      width = "full"
    })
  end

  -- table.insert(optionsTable[6]["controls"], {type = "checkbox", name = "TEST", getFunc = function() return true end, setFunc = function(state) d(state) end, width = "full"})
  -- SETUP ADDON SETTINGS PANEL
  LAM:RegisterAddonPanel("HowManyOptions", panelData)
  LAM:RegisterOptionControls("HowManyOptions", optionsTable)

  -- REGISTER EVENTS
  if HowMany.savedVariables.enabled == true then
    EVENT_MANAGER:RegisterForEvent(HowMany.name,EVENT_LOOT_RECEIVED,HowMany.OnLootReceived)
    d("HowMany Initialized")
  end
end

function HowMany.ManageEvent(param)
  if param == "on" then 
    HowMany.Enable(true)
  elseif param == "off" then
    HowMany.Enable(false)
  elseif param == "showgroup" then
    HowMany.ShowGroupLoot(true)
  elseif param == "hidegroup" then
    HowMany.ShowGroupLoot(false)
  elseif param == "showGroupQualityAll" then
    HowMany.savedVariables.enabled = true
    HowMany.savedVariables.group = true
    HowMany.savedVariables.minGroupItemQuality = 1
    CHAT_SYSTEM:AddMessage("Show items of all qualities.")
  elseif param == "showGroupQualityUncommon" then
    HowMany.savedVariables.enabled = true
    HowMany.savedVariables.minGroupItemQuality = 2
    HowMany.savedVariables.group = true
    CHAT_SYSTEM:AddMessage("Show items (looted by group members) of at least uncommon rarity (green).")
  elseif param == "showGroupQualityRare" then
    HowMany.savedVariables.enabled = true
    HowMany.savedVariables.group = true
    HowMany.savedVariables.minGroupItemQuality = 3
    CHAT_SYSTEM:AddMessage("Show items (looted by group members) of at least rare quality (blue).")
  elseif param == "showGroupQualityEpic" then
    HowMany.savedVariables.enabled = true
    HowMany.savedVariables.group = true
    HowMany.savedVariables.minGroupItemQuality = 4
    CHAT_SYSTEM:AddMessage("Show items (looted by group members) of at least epic quality (purple).")
  else
    CHAT_SYSTEM:AddMessage("Valid commands are:\n/howmany on\n/howmany off\n/howmany showgroup\n/howmany hidegroup\n/howmany showGroupQualityAll\n/howmany showGroupQualityUncommon\n/howmany showGroupQualityRare\n/howmany showGroupQualityEpic")
  end
end

function HowMany.Enable(state)
  HowMany.savedVariables.enabled = state
  if state == true then -- enable
    if HowMany.savedVariables.enabled == false then
      EVENT_MANAGER:RegisterForEvent(HowMany.name,EVENT_LOOT_RECEIVED,HowMany.OnLootReceived)
      CHAT_SYSTEM:AddMessage("HowMany enabled")
    else
      CHAT_SYSTEM:AddMessage("HowMany is on")
    end
  else
    if HowMany.savedVariables.enabled == true then
      EVENT_MANAGER:UnregisterForEvent(HowMany.name, EVENT_LOOT_RECEIVED)
      CHAT_SYSTEM:AddMessage("HowMany disabled")
    else
      CHAT_SYSTEM:AddMessage("HowMany is off")
    end
  end
end

function HowMany.ShowGroupLoot(state)
  HowMany.savedVariables.group = state
  if state == true then
    -- HowMany.savedVariables.enabled = true
    CHAT_SYSTEM:AddMessage("HowMany will show loot from group members.")
  else
    -- HowMany.savedVariables.enabled = true
    CHAT_SYSTEM:AddMessage("HowMany will hide loot from group members.")
  end
end

function HowMany.UseMasterMerchant(state)
  HowMany.savedVariables.useMasterMerchant = state
  if state == true then
    CHAT_SYSTEM:AddMessage("HowMany will look up Master Merchant prices for loot.")
  else
    CHAT_SYSTEM:AddMessage("HowMany will not use Master Merchant.")
  end
end

function HowMany.UseArkadiusTradeTools(state)
  HowMany.savedVariables.useArkadiusTradeTools = state
  if state == true then
    CHAT_SYSTEM:AddMessage("HowMany will look up Arkadius Trade Tools prices for loot.")
  else
    CHAT_SYSTEM:AddMessage("HowMany will not use Arkadius Trade Tools.")
  end
end

function HowMany.SetMinGroupItemQualityByLabel(var)
  for key, value in pairs(HowMany.qualityLabels) do
    if var == value then
      HowMany.ShowGroupLoot(true)
      HowMany.savedVariables.minGroupItemQuality = key
    end
  end
end

function HowMany.SetFilters(state)
  for key, value in pairs(HowMany.savedVariables["filter"]) do
    HowMany.savedVariables["filter"][key] = state
  end
end


function HowMany.ArkadiusLookup(itemLink)
  -- if (not self:IsItemLink(itemLink)) then
  --     return 0
  -- end
  
  if ArkadiusTradeTools.Modules.Sales == nil then
    return 0
  end
  
  local itemSales = ArkadiusTradeTools.Modules.Sales:GetItemSalesInformation(itemLink, 0)
  -- d(itemSales)
  local averagePrice = 0
  local quantity = 0

  for _, sale in pairs(itemSales[itemLink]) do
      averagePrice = averagePrice + sale.price
      quantity = quantity + sale.quantity
  end

  if (quantity > 0) then
      averagePrice = math.attRound(averagePrice / quantity, 2)
  else
      averagePrice = 0
  end

  return averagePrice, quantity
end

function HowMany.OnLootReceived(eventCode, lootedBy, itemLink, quantity, itemSound, lootType, isStolen)
  local playerName = GetUniqueNameForCharacter(GetUnitName('player'))
  local looterName = GetUniqueNameForCharacter(lootedBy)
  local isSelf = (playerName == looterName)
  if HowMany.savedVariables.group == false then
    if isSelf == false then return end
  end

  local itemType = GetItemLinkItemType(itemLink)
  -- if there's a filter entry and it is set to false, ignore this item
  if HowMany.savedVariables["filter"][itemType] ~= nil and HowMany.savedVariables["filter"][itemType] == false then return end

  local s = ""
  local itemQuality = GetItemLinkQuality(itemLink)
  local traitType = GetString("SI_ITEMTRAITTYPE", GetItemLinkTraitInfo(itemLink))
  local hasSet, setName, numBonuses, numEquipped, maxEquipped, setId = GetItemLinkSetInfo(itemLink, false)
  local setDisplayName = "";
  if hasSet == true then setDisplayName = " (|c66a0ffSet: " .. setName .. "|r)" end
  local traitName = "";
  if traitType ~= 'No Trait' then traitName = ' (' .. traitType .. ')' end
  if quantity > 0 then
    if isSelf == true or HowMany.savedVariables.group == false then
      inventoryCount, bankCount, craftBagCount = GetItemLinkStacks(itemLink)
      local iCount = ""
      local bCount = ""
      local cCount = ""
      if inventoryCount > 0 then iCount = zo_strformat("Bags: <<1>> ",inventoryCount) end
      if bankCount > 0 then bCount = zo_strformat("Bank: <<1>> ",bankCount) end
      if craftBagCount > 0 then cCount = zo_strformat("CraftingBag: <<1>> ",craftBagCount) end
      -- have to split string formatting because zo_strformat only supports a max of 6 parameters... -.-
      local invString = zo_strformat("<<1>><<2>><<3>>", iCount, bCount, cCount)
      s = zo_strformat("Looted: <<1>>x <<2>><<4>><<5>> - <<3>>", quantity, itemLink, invString, traitName, setDisplayName)
    elseif itemQuality ~= nil and itemQuality >= HowMany.savedVariables.minGroupItemQuality then
      s = zo_strformat("<<3>> looted: <<1>>x <<2>><<4>><<5>>", quantity, itemLink, lootedBy, traitName, setDisplayName)
    end
    local priceInfo = nil
    if HowMany.savedVariables.useMasterMerchant == true and MasterMerchant ~= nil and s ~= "" then
      local mmStats = MasterMerchant.itemStats(MasterMerchant,itemLink)
      if mmStats.avgPrice == nil or mmStats.numSales == nil then
        priceInfo = zo_strformat(" - |cedba12MM (no data)|r")
      else
        priceInfo = zo_strformat(" - |cedba12MM Avg: <<1>> |t16:16:EsoUI/Art/currency/currency_gold.dds|t|r |c379b09(<<2>> sales)|r", mmStats.avgPrice, mmStats.numSales)
      end
    end
    if HowMany.savedVariables.useArkadiusTradeTools == true and ArkadiusTradeTools ~= nil and s ~= "" then
      local avgPrice, numSales = HowMany.ArkadiusLookup(itemLink)
      if avgPrice == 0 then
        priceInfo = zo_strformat(" - |cedba12ATT (no data)|r")
      else
        priceInfo = zo_strformat(" - |cedba12ATT Avg: <<1>> |t16:16:EsoUI/Art/currency/currency_gold.dds|t|r |c379b09(<<2>> sales)|r", avgPrice, numSales)
      end
    end
    if priceInfo ~= nil then
      s = zo_strformat("<<1>> <<2>>", s, priceInfo)
    end
    CHAT_SYSTEM:AddMessage(s)
  end
end

function HowMany.OnAddOnLoaded(event, addonName)
  d(addonName)
  if addonName == HowMany.name then
    HowMany:Initialize()
    EVENT_MANAGER:UnregisterForEvent(HowMany.name,EVENT_ADD_ON_LOADED)
  end  
end

EVENT_MANAGER:RegisterForEvent(HowMany.name,EVENT_ADD_ON_LOADED,HowMany.OnAddOnLoaded)
