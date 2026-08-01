local DEG_ADDON = _G["DEG_CURRENT_ADDON"]

local function d(...)
  _G[DEG_ADDON.PACKAGE_NAME].plugins[DEG_ADDON.ADDON_NAME_SHORT]:d(...)
end

local function ts(...)
  return tostring(...)
end

local Obj = { }


--######  KEYBINBDS ###################################################

function Obj:pressKB1()
  d("Obj.pressKB1")
  if self.storeIsShowing then
    if  not self.isSelling then
      self:sellAll(true, false, false)
    end
  end
  
  if self.smithyIsShowing then
    if not self.isExtractingAll then
      self:extractAll(true, false)
    end
  end   
  
  if self.fencesIsShowing then
    if not self.isSellingStolen then
      self:sellAll(false, false, true)
    end
  end  
  
end

function Obj:pressKB2()
  d("Obj.pressKB2")
  if self.storeIsShowing then
    if  not self.isSelling then
      self:sellAll(false, true, false)
    end
  end
  
  if self.smithyIsShowing then
    if not self.isExtractingAll then
      self:extractAll(false, true)
    end
  end  
end

function Obj:pressKB3()
  d("Obj.pressKB3")  
  if self.smithyIsShowing then
    if not self.isExtractingAll then
      self:extractAll(false, false, true)
    end
  end  
end

Obj.storeIsShowing = false
Obj.smithyIsShowing = false
Obj.fencesIsShowing = false
Obj.isSellingOrnate = nil
Obj.isSellingTraitless = nil
Obj.isSellingStolen = nil

function Obj:sellAll(ornate, traitless, stolen)
  self.isSelling = true
  
  if ornate ~= nil then
    self.isSellingOrnate = ornate
  else
    ornate = self.isSellingOrnate
  end
  if traitless ~= nil then
    self.isSellingTraitless = traitless
  else
   traitless = self.isSellingTraitless
  end  
  if stolen ~= nil then
    self.isSellingStolen = stolen
  else
   stolen = self.isSellingStolen
  end  
  
  for slotId=0,GetBagSize(BAG_BACKPACK) do
    if ornate then
      if self:checkItemOrnate(BAG_BACKPACK, slotId) then
        --d("sell orante: "..GetItemLink(BAG_BACKPACK, slotId))
        SellInventoryItem(BAG_BACKPACK, slotId, 1)
        return      
      end
    end
    if traitless then
      if self:checkItemTraitless(BAG_BACKPACK, slotId) then
        --d("sell traitless: "..GetItemLink(BAG_BACKPACK, slotId))
        SellInventoryItem(BAG_BACKPACK, slotId, 1)
        return
      end
    end
    if stolen then
      if self:checkItemStolen(BAG_BACKPACK, slotId) then
        --d("sell stolen: "..GetItemLink(BAG_BACKPACK, slotId))
        SellInventoryItem(BAG_BACKPACK, slotId, 1)
        return
      end
    end
  end
  
  self.isSelling = false
  self.isSellingOrnate = nil
  self.isSellingTraitless = nil
  self.isSellingStolen = nil
  
  KEYBIND_STRIP:UpdateKeybindButtonGroup(self.storeButtonGroup) 
  KEYBIND_STRIP:UpdateKeybindButtonGroup(self.fencesButtonGroup)
  KEYBIND_STRIP:UpdateKeybindButtonGroup(STORE_WINDOW.keybindStripDescriptor)
end

function Obj:extractAll(intricate, traitless, ornate)
  self.isExtractingAll = true
  if intricate then
    self.isExtractingAllIntricate = true
  end
  if traitless then
    self.isExtractingAllTraitless = true
  end  
  if ornate then
    self.isExtractingAllOrnate = true
  end  
  
  local baglist = {BAG_BACKPACK, BAG_BANK, BAG_SUBSCRIBER_BANK}
  
  for i,bagId in pairs(baglist) do
    for slotId=0,GetBagSize(bagId) do
      if intricate then
        if self:checkItemIntricate(bagId, slotId) then
          if CanItemBeSmithingExtractedOrRefined(bagId, slotId, GetCraftingInteractionType()) then
            --d("decomp intricate: "..GetItemLink(bagId, slotId))
            ExtractOrRefineSmithingItem(bagId, slotId)
            return          
          end
        end
      end    
      if traitless then
        if self:checkItemTraitless(bagId, slotId) then
          if CanItemBeSmithingExtractedOrRefined(bagId, slotId, GetCraftingInteractionType()) then
            --d("decomp traitless: "..GetItemLink(bagId, slotId))
            ExtractOrRefineSmithingItem(bagId, slotId)
            return
          end
        end
      end      
      
      if ornate then
        if self:checkItemOrnate(bagId, slotId) then
          if CanItemBeSmithingExtractedOrRefined(bagId, slotId, GetCraftingInteractionType()) then
            ExtractOrRefineSmithingItem(bagId, slotId)
            return
          end
        end
      end      
    end  
  end    
   
  self.isExtractingAll = false 
  self.isExtractingAllIntricate = false
  self.isExtractingAllTraitless = false  
  self.isExtractingAllOrnate = false
  KEYBIND_STRIP:UpdateKeybindButtonGroup(SMITHING.keybindStripDescriptor)
end

function Obj:checkItemOrnate(bagId, slotId)
  local trait = GetItemTrait(bagId, slotId)   
  --d("bagid="..ts(bagId).." slotId="..ts(slotId).." trait="..ts(trait).. " item="..GetItemLink(bagId, slotId))
  if trait == ITEM_TRAIT_TYPE_ARMOR_ORNATE or trait == ITEM_TRAIT_TYPE_WEAPON_ORNATE or trait == ITEM_TRAIT_TYPE_JEWELRY_ORNATE then
    if not IsItemStolen(bagId, slotId) then return true end
  end
  return false
end

function Obj:checkItemIntricate(bagId, slotId, doSmithing)
  local trait = GetItemTrait(bagId, slotId)
  if trait == ITEM_TRAIT_TYPE_ARMOR_INTRICATE or trait == ITEM_TRAIT_TYPE_WEAPON_INTRICATE or treit == ITEM_TRAIT_TYPE_JEWELRY_INTRICATE then
    if not IsItemStolen(bagId, slotId) then 
      if doSmithing then
        return CanItemBeSmithingExtractedOrRefined(bagId, slotId, GetCraftingInteractionType())
      else
        return true
      end             
    end
  end
  return false
end

function Obj:getCrafingType(specializedItemTypeArmor, specializedItemTypeWeapon, specializedItemTypeEquip)
  local CRAFTING_TYPE = CRAFTING_TYPE_BLACKSMITHING
  
  if specializedItemTypeArmor == ARMORTYPE_HEAVY then
              
  elseif specializedItemTypeArmor == ARMORTYPE_MEDIUM then

    CRAFTING_TYPE = CRAFTING_TYPE_CLOTHIER
  elseif specializedItemTypeArmor == ARMORTYPE_LIGHT then
   
    CRAFTING_TYPE = CRAFTING_TYPE_CLOTHIER
  elseif specializedItemTypeWeapon == WEAPONTYPE_HAMMER or specializedItemTypeWeapon == WEAPONTYPE_SWORD or specializedItemTypeWeapon == WEAPONTYPE_DAGGER or specializedItemTypeWeapon == WEAPONTYPE_AXE then

  elseif specializedItemTypeWeapon == WEAPONTYPE_TWO_HANDED_AXE or specializedItemTypeWeapon == WEAPONTYPE_TWO_HANDED_HAMMER or specializedItemTypeWeapon == WEAPONTYPE_TWO_HANDED_SWORD then

  elseif specializedItemTypeWeapon == WEAPONTYPE_FIRE_STAFF or specializedItemTypeWeapon == WEAPONTYPE_FROST_STAFF or specializedItemTypeWeapon == WEAPONTYPE_LIGHTNING_STAFF then

    CRAFTING_TYPE = CRAFTING_TYPE_WOODWORKING    
  elseif specializedItemTypeWeapon == WEAPONTYPE_HEALING_STAFF then

    CRAFTING_TYPE = CRAFTING_TYPE_WOODWORKING
  elseif specializedItemTypeWeapon == WEAPONTYPE_BOW then
    
    CRAFTING_TYPE = CRAFTING_TYPE_WOODWORKING
  elseif specializedItemTypeWeapon == WEAPONTYPE_SHIELD then

    CRAFTING_TYPE = CRAFTING_TYPE_WOODWORKING
  elseif specializedItemTypeArmor == ARMORTYPE_NONE and specializedItemTypeEquip == EQUIP_TYPE_NECK then    
    CRAFTING_TYPE = CRAFTING_TYPE_JEWELRYCRAFTING
  elseif specializedItemTypeArmor == ARMORTYPE_NONE and specializedItemTypeEquip == EQUIP_TYPE_RING then
    CRAFTING_TYPE = CRAFTING_TYPE_JEWELRYCRAFTING
  else
    return nil
  end  
  
  return CRAFTING_TYPE
end

function Obj:checkItemTraitless(bagId, slotId, doSmithing, includeKnownAsTraitless)
  local itemLink = GetItemLink(bagId, slotId)
  local itemType, specializedItemType = GetItemType(bagId, slotId)
  local _, _, _, specializedItemTypeEquip = GetItemLinkInfo(itemLink)
  local specializedItemTypeArmor, specializedItemTypeWeapon = GetItemLinkArmorType(itemLink), GetItemLinkWeaponType(itemLink)
  local specializedItemType = specializedItemTypeArmor
  if specializedItemType == 0 then
    specializedItemType = specializedItemTypeWeapon
  end  
  
  if itemType == ITEMTYPE_ARMOR or itemType == ITEMTYPE_WEAPON then
    local trait = GetItemTrait(bagId, slotId)
    if trait == ITEM_TRAIT_TYPE_NONE then
      if not IsItemStolen(bagId, slotId) then
        if doSmithing then
          return CanItemBeSmithingExtractedOrRefined(bagId, slotId, GetCraftingInteractionType())
        else
          return true
        end      
      end
    else
      --item hat einen trait
      --aber bitte keine schmuckstücke        
      
      --for now really sell only traitless items
      --selling items with known or not wanted traits will be a seperate feature
      if includeKnownAsTraitless and false then
        local CRAFTING_TYPE = self:getCrafingType(specializedItemTypeArmor, specializedItemTypeWeapon, specializedItemTypeEquip)
        if not CRAFTING_TYPE then
          return false
        else            
          --möchte jemand den trait?
          --wenn ja, kennen alle den trait?
          if specializedItemType == specializedItemTypeWeapon then
            --waffenmodus              
            if self.Addon.vars.equiptTypeToResearchLineWeapons[specializedItemType][specializedItemTypeWeapon] then
            
              local numLine = self.Addon.vars.equiptTypeToResearchLineWeapons[specializedItemType][specializedItemTypeWeapon]
              
              if self.Addon:traitNeeded(CRAFTING_TYPE, numLine, trait) then
                return false
              else
                if not IsItemStolen(bagId, slotId) then
                  if doSmithing then
                    return CanItemBeSmithingExtractedOrRefined(bagId, slotId, GetCraftingInteractionType())
                  else
                    return true
                  end
                end
              end
            else
              --trait research unbekannt
              return false           
            end
  
          else
            --rüstungsmodus              
            if self.Addon.vars.equiptTypeToResearchLineArmor[specializedItemType][specializedItemTypeEquip] then
            
              local numLine = self.Addon.vars.equiptTypeToResearchLineArmor[specializedItemType][specializedItemTypeEquip]
              
              if self.Addon:traitNeeded(CRAFTING_TYPE, numLine, trait) then
                return false
              else
                if not IsItemStolen(bagId, slotId) then
                  if doSmithing then
                    return CanItemBeSmithingExtractedOrRefined(bagId, slotId, GetCraftingInteractionType())
                  else
                    return true
                  end      
                end
              end            
            else
              --trait research unbekannt
              return false          
            end
          end
        end
      else
        --item hat einen trait und es wird nicht auf traitAnforderungen geprüft
        return false
      end 
    end
  end
  return false
end

function Obj:checkItemStolen(bagId, slotId)
  if IsItemStolen(bagId, slotId) then
    local icon, stack, sellPrice, meetsUsageRequirement, locked, equipType, itemStyle, quality = GetItemInfo(bagId, slotId)
    if sellPrice then
      --slot.stackLaunderPrice or slot.stackSellPrice
      local itemType, specializedItemType = GetItemType(bagId, slotId)
                  
      if itemType == ITEMTYPE_TROPHY then      
      elseif itemType == ITEMTYPE_ARMOR or itemType == ITEMTYPE_WEAPON then      
      elseif itemType == ITEMTYPE_RECIPE then      
      elseif itemType == ITEMTYPE_RACIAL_STYLE_MOTIF then
      else
        return true
      end
    end
  end
  return false
end

--function Obj:getItemCraftingType(bagId, slotIndex)
--  local usedInCraftingType, itemType, extraInfo1, extraInfo2, extraInfo3 = GetItemCraftingInfo(bagId, slotIndex)
            --local itemType, specializedItemType = GetItemType(bagId, slotIndex) 
            --d("usedInCraftingType="..ts(usedInCraftingType)) 
            --d("itemType="..ts(itemType))
            --d("extraInfo1="..ts(extraInfo1))
            --d("extraInfo2="..ts(extraInfo2))
            --d("extraInfo3="..ts(extraInfo3))
--end

function Obj:hasOrnateItems(doBank, returnCountAndValue, craftingType)
  local baglist = {BAG_BACKPACK}
  if doBank then
    table.insert(baglist, BAG_BANK)
    table.insert(baglist, BAG_SUBSCRIBER_BANK) 
  end
    
  local countItems = 0
  local sellValue = 0
  
  for i,bagId in pairs(baglist) do
    for slotId=0,GetBagSize(bagId) do   
      if self:checkItemOrnate(bagId, slotId) then
        local icon, stack, sellPrice, meetsUsageRequirement, locked, equipType, itemStyle, quality = GetItemInfo(bagId, slotId)
        if not locked then
          if not craftingType then
            if returnCountAndValue then
              countItems = countItems + 1
              sellValue = sellValue + stack * sellPrice
            else
              return true  
            end        
          else
            if CanItemBeSmithingExtractedOrRefined(bagId, slotId, craftingType) then                   
              if returnCountAndValue then
                countItems = countItems + 1
                sellValue = sellValue + stack * sellPrice
              else
                return true  
              end
            end
          end
        end
      end
    end
  end
  
  if countItems > 0 then
    return true, countItems, sellValue
  else
    return false, countItems, sellValue
  end  
end

function Obj:hasIntricateItems(doBank, doSmithing, returnCountAndValue)
  local baglist = {BAG_BACKPACK}
  if doBank then
    table.insert(baglist, BAG_BANK)
    table.insert(baglist, BAG_SUBSCRIBER_BANK) 
  end
  
  local countItems = 0
  local sellValue = 0
    
  for i,bagId in pairs(baglist) do
    for slotId=0,GetBagSize(bagId) do
      if self:checkItemIntricate(bagId, slotId, doSmithing) then 
        local icon, stack, sellPrice, meetsUsageRequirement, locked, equipType, itemStyle, quality = GetItemInfo(bagId, slotId)
        if not locked then
          if returnCountAndValue then
            countItems = countItems + 1
            sellValue = sellValue + stack * sellPrice
          else
            return true  
          end        
        end      
      end
    end
  end
  
  if countItems > 0 then
    return true, countItems, sellValue, inpirationValue
  else
    return false, countItems, sellValue, inpirationValue
  end
end

function Obj:hasTraitlessItems(doBank, doSmithing, returnCountAndValue, includeKnownAsTraitless)
  local baglist = {BAG_BACKPACK}
  if doBank then
    table.insert(baglist, BAG_BANK)
    table.insert(baglist, BAG_SUBSCRIBER_BANK) 
  end
  
  local countItems = 0
  local sellValue = 0  
  
  for i,bagId in pairs(baglist) do
    for slotId=0,GetBagSize(bagId) do
      if self:checkItemTraitless(bagId, slotId, doSmithing, includeKnownAsTraitless) then
        local icon, stack, sellPrice, meetsUsageRequirement, locked, equipType, itemStyle, quality = GetItemInfo(bagId, slotId)
        if not locked then
          if returnCountAndValue then
            countItems = countItems + 1
            sellValue = sellValue + stack * sellPrice
          else
            return true  
          end        
        end
      end
    end
  end
  if countItems > 0 then
    return true, countItems, sellValue
  else
    return false, countItems, sellValue
  end
end

function Obj:hasKnownTraitItems(doBank, doSmithing, returnCountAndValue)
  if (returnCountAndValue) then return true, 1, 100 end
  return true
end

function Obj:hasStolenItems(returnCountAndValue)
  local baglist = {BAG_BACKPACK}

  local countItems = 0
  local sellValue = 0

  for i,bagId in pairs(baglist) do
    for slotId=0,GetBagSize(bagId) do
      if self:checkItemStolen(bagId, slotId) then
        local icon, stack, sellPrice, meetsUsageRequirement, locked, equipType, itemStyle, quality = GetItemInfo(bagId, slotId)
        if not locked then
          if returnCountAndValue then
            countItems = countItems + 1
            sellValue = sellValue + stack * sellPrice
          else
            return true  
          end        
        end
      end
    end
  end
  if countItems > 0 then
    return true, countItems, sellValue
  else
    return false, countItems, sellValue
  end
end

function Obj:isCrafting()
  return ZO_CraftingUtils_IsPerformingCraftProcess()
end

Obj.Addon = nil
Obj.storeButtonGroup = nil
Obj.smithingButtonGroup = nil
Obj.fencesButtonGroup = nil

Obj.isSelling = false
Obj.isExtractingAll = false
Obj.isExtractingAllIntricate = false
Obj.isExtractingAllTraitless = false
Obj.isExtractingAllOrnate = false

function Obj:getActiveStoreTab(doDebug)

--  GetName() = "ZO_StoreWindowMenuBarButton1"
--  GetName() = "ZO_StoreWindowMenuBarButton1Image" 
--  GetTextureFileName() = "EsoUI/Art/Vendor/vendor_tabIcon_sell_down.dds"

  for i = 1, ZO_StoreWindowMenuBar:GetNumChildren() do
    local theTempControl1 = ZO_StoreWindowMenuBar:GetChild(i)
    local theChild = theTempControl1:GetChild()
    if theChild and theChild:GetType() == CT_TEXTURE then      
      --EsoUI/Art/Vendor/vendor_tabIcon_buy_up.dds
      local split = {SplitString('_', theChild:GetTextureFileName())}
      if split[#split] == "down.dds" then
        if split[#split-1] == "buy" then if doDebug then d("ZO_MODE_STORE_BUY") end; return ZO_MODE_STORE_BUY end 
        if split[#split-1] == "sell" then if doDebug then d("ZO_MODE_STORE_SELL") end; return ZO_MODE_STORE_SELL end
      end
      if split[#split] == "over.dds" then
        if split[#split-1] == "buy" then if doDebug then d("ZO_MODE_STORE_BUY") end; return ZO_MODE_STORE_BUY end 
        if split[#split-1] == "sell" then if doDebug then d("ZO_MODE_STORE_SELL") end; return ZO_MODE_STORE_SELL end
      end
    end
  end
  if doDebug then 
    d("ZO_MODE_STORE_0")
  end
  return 0
end

function Obj:initializeStore()

  local sellIconUp = zo_iconFormat("EsoUI/Art/Vendor/vendor_tabIcon_sell_up.dds", 36, 36) 
  local sellIconDown = zo_iconFormat("EsoUI/Art/Vendor/vendor_tabIcon_sell_down.dds", 34, 34)
  local sellIconOver = zo_iconFormat("EsoUI/Art/Vendor/vendor_tabIcon_sell_over.dds", 34, 34)
  local goldIcon = zo_iconFormat("EsoUI/Art/currency/currency_gold.dds", 24, 24)
  local goldIcon2 = zo_iconFormat("EsoUI/Art/currency/currency_gold.dds", 12, 12)
  local traitIcon = zo_iconFormat("esoui/art/inventory/inventory_tabIcon_Craftbag_itemtrait_up.dds", 34, 34)

  self.storeButtonGroup = {
    {
      name = function()
        local hasItems, countItems, sellValue = self:hasOrnateItems(false, true)
        return zo_strformat("<<X:1>>"..GetString(SI_KB_DEG_IS_ORNATE).." (<<X:2>><<X:3>>)", sellIconUp, sellValue, goldIcon)
      end,--      GetString(SI_KB_DEG_SELL_ORNATE),
      keybind = "DEG_KB1",
      --keybind = "KB_DEG_STORE_SELLORNATE",
      callback = function()
        if self.isSelling then return end
        self.isSelling = true
        zo_callLater(function()
          self:sellAll(true, false)          
        end, 1)
      end,
      visible = function()
        d("DEG_INVENTORY_KB_ACTION1.visible")
        if not self.Addon.savedVariablesAccount.settings.sellOrnate then
          d("DEG_INVENTORY_KB_ACTION1.visible.false1") 
          return false 
        end
        
        if (GetInteractionType() == INTERACTION_VENDOR) then
          return self:hasOrnateItems(false)
        end
        
        --local activeTab = self:getActiveStoreTab()
        --if activeTab == ZO_MODE_STORE_SELL then 
          --return self:hasOrnateItems(false)
        --end 
        --if activeTab == ZO_MODE_STORE_BUY then
          --return self:hasOrnateItems(false)
        --end
        if not self.isDoingBuggyRefresh then
          self.isDoingBuggyRefresh = true
          zo_callLater(function()
            KEYBIND_STRIP:UpdateKeybindButtonGroup(STORE_WINDOW.keybindStripDescriptor)
            KEYBIND_STRIP:UpdateKeybindButtonGroup(self.storeButtonGroup)
            self.isDoingBuggyRefresh = false
          end, 1)
        end
        d("DEG_INVENTORY_KB_ACTION1.visible.false2")
        return false
      end,
      enabled = function()
        if not self.Addon.savedVariablesAccount.settings.sellOrnate then return false end
        if self.isSelling then return false end
        if (GetInteractionType() == INTERACTION_VENDOR) then
          return self:hasOrnateItems(false)
        end
        --local activeTab = self:getActiveStoreTab()
        --if activeTab == ZO_MODE_STORE_SELL then 
          --return self:hasOrnateItems(false)
        --end
        --if activeTab == ZO_MODE_STORE_BUY then
          --return self:hasOrnateItems(false)
        --end
        return false
      end,
      order = 10,
      alignment = KEYBIND_STRIP_ALIGN_CENTER,
    },
    {
      name = function()        
        local hasItems, countItems, sellValue = self:hasTraitlessItems(false, false, true)
        return zo_strformat("<<X:1>>"..GetString(SI_KB_DEG_HAS_NO).."<<X:2>>(<<X:3>><<X:4>>)", sellIconUp, traitIcon, sellValue, goldIcon)
        --return zo_strformat("<<X:1>><<X:2>>(<<X:3>><<X:4>>)", "Verkaufe ohne", traitIcon, sellValue, goldIcon)
      end,
      keybind = "DEG_KB2",
      callback = function()
        if self.isSelling then return end
        self.isSelling = true
        zo_callLater(function()
          self:sellAll(false, true)
        end, 1)      
      end,
      visible = function()
        if not self.Addon.savedVariablesAccount.settings.sellTraitless then return false end
        local activeTab = self:getActiveStoreTab()
        if activeTab == ZO_MODE_STORE_SELL then 
          return self:hasTraitlessItems(false, false)
        end 
        if activeTab == ZO_MODE_STORE_BUY then
          return self:hasTraitlessItems(false, false)
        end        
--        if not self.isDoingBuggyRefresh then
--          self.isDoingBuggyRefresh = true
--          zo_callLater(function()              
--            KEYBIND_STRIP:UpdateKeybindButtonGroup(STORE_WINDOW.keybindStripDescriptor)
--            self.isDoingBuggyRefresh = false        
--          end, 1)
--        end
        return false
      end,
      enabled = function()
        if not self.Addon.savedVariablesAccount.settings.sellTraitless then return false end
        if self.isSelling then return false end
        local activeTab = self:getActiveStoreTab()
        if activeTab == ZO_MODE_STORE_SELL then 
          return self:hasTraitlessItems(false, false)
        end
        if activeTab == ZO_MODE_STORE_BUY then
          return self:hasTraitlessItems(false, false)
        end
        return false
      end,
      order = 11,
      alignment = KEYBIND_STRIP_ALIGN_CENTER,
    },    
  }
  
    
  for k,v in pairs(self.storeButtonGroup) do
    if type(k)=='number' then      
      table.insert(STORE_WINDOW.keybindStripDescriptor, v)
    end
  end

  BACKPACK_STORE_LAYOUT_FRAGMENT:RegisterCallback("StateChange", function(oldState, newState)
      if newState == SCENE_SHOWING then
        --d("BACKPACK_STORE_LAYOUT_FRAGMENT SCENE_SHOWN")
        self.storeIsShowing = true
        self.isSelling = false
        self.isSellingOrnate = nil
        self.isSellingTraitless = nil
        self.isSellingStolen = nil
        
        if not KEYBIND_STRIP:HasKeybindButton(self.storeButtonGroup[1]) then
          KEYBIND_STRIP:AddKeybindButtonGroup(self.storeButtonGroup)
        end
        
        EVENT_MANAGER:RegisterForEvent(self.Addon.name..'Keybind', EVENT_SELL_RECEIPT, function(eventCode, itemName, itemQuantity, money)
          d("EVENT_SELL_RECEIPT")
          if self.isSelling then
            zo_callLater(function() self:sellAll() end, 200)
          end
          KEYBIND_STRIP:UpdateKeybindButtonGroup(self.storeButtonGroup)
        end)
      elseif newState == SCENE_HIDING then
        --d("BACKPACK_STORE_LAYOUT_FRAGMENT SCENE_HIDING")
        self.storeIsShowing = false
        self.isSelling = false
        self.isSellingOrnate = nil
        self.isSellingTraitless = nil
        self.isSellingStolen = nil        
        EVENT_MANAGER:UnregisterForEvent(self.Addon.name..'Keybind')
      end
  end)
end

function Obj:initializeSmithy()
  
  local deconstructIconUp = zo_iconFormat("EsoUI/Art/Crafting/enchantment_tabIcon_deconstruction_up.dds", 36, 36)
  local intricateIcon = zo_iconFormat("esoui/art/icons/crafting_inspiration_logo.dds", 32, 32)
  local inspirationIcon = zo_iconFormat("esoui/art/icons/crafting_inspiration_logo.dds", 32, 32)
  
            
  --zo_strformat("c|FF00FF<<1>>|r", zo_iconFormatInheritColor(path))    
  
  self.smithingButtonGroup = {
    {
      name = function()        
        local hasItems, countItems, sellValue = self:hasIntricateItems(true, true, true)
        return  zo_strformat("<<X:1>>"..GetString(SI_KB_DEG_IS_INTRICATE).."<<X:2>>(<<X:3>>)", deconstructIconUp, intricateIcon, countItems)
      end,
      keybind = "DEG_KB1",
      callback = function()
        if self:isCrafting() then return end
        self.isExtractingAll = true
        self.isExtractingAllIntricate = true
        zo_callLater(function()
          self:extractAll(true, false)
        end, 1)      
      end,
      visible = function()        
        if not self.Addon.savedVariablesAccount.settings.decompAll then return false end       
        if SMITHING:IsExtracting() then
          if SMITHING:IsDeconstructing() then
            return self:hasIntricateItems(true, true)
          else
            return self:hasIntricateItems(true, true)
          end        
        end
        return false                      
      end,
      enabled = function()
        if not self.Addon.savedVariablesAccount.settings.decompAll then return false end
        if self:isCrafting() then return false end
        if self.isExtractingAll then return false end
        return self:hasIntricateItems(true, true)
      end,
      order = 0,
    },
    {
      name = function()
          local traitIcon = zo_iconFormat("esoui/art/inventory/inventory_tabIcon_Craftbag_itemtrait_up.dds", 34, 34)
          local hasItems, countItems, sellValue = self:hasTraitlessItems(true, true, true, false)
          return zo_strformat("<<X:1>>"..GetString(SI_KB_DEG_HAS_NO).."<<X:2>>(<<X:3>>)", deconstructIconUp, traitIcon, countItems)        
      end,
      --name = GetString(SI_KB_DEG_DECOMP_TRAITLESS),
      keybind = "DEG_KB2",
      callback = function()
        if self:isCrafting() then return end
        self.isExtractingAll = true
        self.isExtractingAllTraitless = true
        zo_callLater(function()
          self:extractAll(false, true)
        end, 1)
      end,
      visible = function()
        if not self.Addon.savedVariablesAccount.settings.decompTraitless then return false end        
        if SMITHING:IsExtracting() then
          if SMITHING:IsDeconstructing() then
            return self:hasTraitlessItems(true, true, false, self.Addon.savedVariablesAccount.traitResearch)
          else
            return self:hasTraitlessItems(true, true, false, self.Addon.savedVariablesAccount.traitResearch)
          end
        end
        return false      
      end,
      enabled = function()
        if not self.Addon.savedVariablesAccount.settings.decompTraitless then return false end
        if self:isCrafting() then return false end
        if self.isExtractingAll then return false end
        return self:hasTraitlessItems(true, true, false, self.Addon.savedVariablesAccount.traitResearch)      
      end,
      order = 0,      
    },
    --###############   EXTRACT ALL ORNATE ##########################################
    {
      name = function()
          local ornateIcon = zo_iconFormat("EsoUI/Art/currency/currency_gold.dds", 24, 24)
          local hasItems, countItems, sellValue = self:hasOrnateItems(true, true, GetCraftingInteractionType())
          return zo_strformat("<<X:1>>"..GetString(SI_KB_DEG_HAS_ORNATE).."<<X:2>>(<<X:3>>)", deconstructIconUp, ornateIcon, countItems)        
      end,
      keybind = "DEG_KB3",
      callback = function()
        --d("GetCraftingInteractionType="..GetCraftingInteractionType());
        --schmied = 1      
        --schneider= 2
        --schreiner = 6
        --schmuck = 7        
        --d("CRAFTING_TYPE_BLACKSMITHING="..CRAFTING_TYPE_BLACKSMITHING)
        --d("CRAFTING_TYPE_CLOTHIER="..CRAFTING_TYPE_CLOTHIER)
        --d("CRAFTING_TYPE_WOODWORKING="..CRAFTING_TYPE_WOODWORKING)
        --d("CRAFTING_TYPE_JEWELRYCRAFTING="..CRAFTING_TYPE_JEWELRYCRAFTING)        
        if self:isCrafting() then return end
        self.isExtractingAll = true
        self.isExtractingAllOrnate = true
        zo_callLater(function()
          self:extractAll(false, false, true)
        end, 1)
      end,
      visible = function()
        if not self.Addon.savedVariablesAccount.settings.decompOrnate then return false end        
        if SMITHING:IsExtracting() then
          if SMITHING:IsDeconstructing() then
            return self:hasOrnateItems(true, false, GetCraftingInteractionType())
          else
            return self:hasOrnateItems(true, false, GetCraftingInteractionType())
          end
        end      
      end,
      enabled = function()
        if not self.Addon.savedVariablesAccount.settings.decompOrnate then return false end
        if self:isCrafting() then return false end
        if self.isExtractingAll then return false end
        return self:hasOrnateItems(true, true, GetCraftingInteractionType())      
      end,
      order = 0,      
    },    
  }

  for k,v in pairs(self.smithingButtonGroup) do
    table.insert(SMITHING.keybindStripDescriptor, v)
  end

  SMITHING_FRAGMENT:RegisterCallback("StateChange", function(oldState, newState)
    if newState == SCENE_SHOWING then
      self.smithyIsShowing = true
      self.isExtractingAll = false
      self.isExtractingAllIntricate = false
      self.isExtractingAllTraitless = false
      self.isExtractingAllOrnate = false
      self.isSelling = false              
    elseif newState == SCENE_HIDING then
      self.smithyIsShowing = false
      self.isExtractingAll = false
      self.isExtractingAllIntricate = false
      self.isExtractingAllTraitless = false
      self.isExtractingAllOrnate = false
      self.isSelling = false      
    end
  end)
    
  EVENT_MANAGER:RegisterForEvent(self.Addon.name.."KBS_SMITH", EVENT_CRAFT_COMPLETED, function(eventCode, craftSkill)
    if self.isExtractingAll then
      if self.isExtractingAllIntricate then
        zo_callLater(function() self:extractAll(true, false) end, 200)
      elseif self.isExtractingAllTraitless then
        zo_callLater(function() self:extractAll(false, true) end, 200)
      elseif self.isExtractingAllOrnate then
        zo_callLater(function() self:extractAll(false, false, true) end, 200)
      end      
    end
  end)
end

function Obj:initializeFences()

  local sellIconUp = zo_iconFormat("EsoUI/Art/Vendor/vendor_tabIcon_sell_up.dds", 36, 36) 
  local goldIcon = zo_iconFormat("EsoUI/Art/currency/currency_gold.dds", 24, 24)

  self.fencesButtonGroup = {
    {
      name = function()
        local hasItems, countItems, sellValue = self:hasStolenItems(true)
        return zo_strformat("<<X:1>>"..GetString(SI_KB_DEG_SELL_STOLEN).." (<<X:2>><<X:3>>)", sellIconUp, sellValue, goldIcon)
      end,
      keybind = "DEG_KB1",
      callback = function()
        if self.isSelling then return end
        self.isSelling = true
        zo_callLater(function()
          self:sellAll(false, false, true)
        end, 1)
      end,
      visible = function()
        d("fencesButtonGroup.visible")
        if not self.Addon.savedVariablesAccount.settings.sellStolen then return false end
        return self:hasStolenItems()
      end,
      enabled = function()
        if not self.Addon.savedVariablesAccount.settings.sellStolen then return false end
        if self.isSelling then return false end
        return self:hasStolenItems()
      end,
      order = -1,
    },
  }
    
  FENCE_SCENE:RegisterCallback("StateChange", function(oldState, newState)
      if newState == SCENE_SHOWN then
        self.fencesIsShowing = true
        self.isSelling = false
        self.isSellingOrnate = nil
        self.isSellingTraitless = nil
        self.isSellingStolen = nil        
        EVENT_MANAGER:RegisterForEvent(self.Addon.name..'Keybind', EVENT_SELL_RECEIPT, function(eventCode, itemName, itemQuantity, money)
          d("EVENT_SELL_RECEIPT")
          KEYBIND_STRIP:UpdateKeybindButtonGroup(self.fencesButtonGroup)
          if self.isSelling then
            zo_callLater(function() self:sellAll() end, 200)
          end
        end)        
        KEYBIND_STRIP:AddKeybindButtonGroup(self.fencesButtonGroup)
      elseif newState == SCENE_HIDING then
        self.fencesIsShowing = false
        self.isSelling = false
        self.isSellingOrnate = nil
        self.isSellingTraitless = nil
        self.isSellingStolen = nil        
        EVENT_MANAGER:UnregisterForEvent(self.Addon.name..'Keybind')
        KEYBIND_STRIP:RemoveKeybindButtonGroup(self.fencesButtonGroup)
      end
  end)
  
end

Obj.initialized = false

function Obj:initialize()
  if self.initialized then return end
  
  self.Addon = _G[DEG_ADDON.PACKAGE_NAME].plugins[DEG_ADDON.ADDON_NAME_SHORT]
  
  self:initializeStore()
  self:initializeSmithy()
  self:initializeFences()
  
  self.initialized = true
end

_G[_G["DEG_CURRENT_ADDON"].ADDON_NAME.."Keybind"] = Obj