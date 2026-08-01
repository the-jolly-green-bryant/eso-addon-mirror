LootSanitizer = {}

local this = LootSanitizer
this.name = "LootSanitizer"
this.version = "0.20.0"
this.author = "grin3671"

this.enabled = 1
this.stats =
{
  ["space"] = 0,
  ["price"] = 0,
}

local DEFAULT_SETTINGS =
{
  workMode = 0,
  chatMode = 1,
  playSound = true,
  burnEquipment = false,
  burnEquipmentPrice = 1, -- english word used in inventory: value
  burnSimpleClothes = false,
  burnCompanionItems = 0,
  burnRaceMaterial = 0,
  burnRaceMotif = 0,
  autoLearnRaceMotif = false,
  burnTraitMaterial = false,
  burnIngredient = false,
  burnLockpick = false,
  burnLockpickStackSaved = 3,
  burnBait = false,
  burnBaitStackSaved = 1,
  burnJunk = false,
  burnCommonGlyph = false,
  burnRunePotency = false,
  burnRuneEssence = false,
  saveRuneEssenceForDaily = true,
  maxBurnedStack = 10,
  maxBurnedPrice = 100,
  autoBindQuality = 0,
  -- junkNormalEquipment = false,
  junkNormalEquipmentQuality = 0,
  junkOrnateEquipment = false,
  junkMiddleRawAndMaterial = false,
  junkNotCraftedPotion = false,
  junkNotCraftedPoison = false,
  junkNotCraftedFood = false,
  junkNotCraftedDrink = false,
  junkPotionSolvent = false,
  junkPoisonSolvent = false,
  junkTrashItem = false,
  junkTreasureItem = false,
  junkRareFish = false,
  junkBait = false,
  junkMonsterTrophy = false,
  junkExcessRepairKit = false,
  junkExcessSoulgem = false,
  autoJunkSell = false,
  autoLearnJunkRecipes = false,
  displayAutoBurnAction = false,
  -- LibCustomMenu Values
  listOfJunk = {},
  listOfBurn = {}
}

local itemData = {
  ["trashRaceMaterial"] = {
    ["33150"]     = true, -- Flint (Argonian Style)
    ["33194"]     = true, -- Bone (Wood Elf Style)
    ["33251"]     = true, -- Molybdenum (Breton Style)
    ["33252"]     = true, -- Adamantite (High Elf Style)
    ["33253"]     = true, -- Obsidian (Dark Elf Style)
    ["33255"]     = true, -- Moonstone (Khajiit Style)
    ["33256"]     = true, -- Corundum (Nord Style)
    ["33257"]     = true, -- Manganese (Orc Style)
    ["33258"]     = true, -- Starmetal (Redguard Style)
  },
  ["trashRaceRareMaterial"] = {
    ["33254"]     = true, -- Nickel (Imperial style)
    ["46149"]     = true, -- Bronze (Barbaric Style)
    ["46150"]     = true, -- Argentum (Primal Style)
    ["46151"]     = true, -- Daedra Heart (Daedric Style)
    ["46152"]     = true, -- Palladium (Ancient Elf Style)
  },
  ["trashTraitMaterial"] = {
    ["810"]       = true, -- Jade / Weapon Trait / INFUSED
    ["813"]       = true, -- Turquoise / Weapon Trait / DEFENDING
    ["4486"]      = true, -- Ruby / Weapon Trait / PRECISE
    ["16291"]     = true, -- Citrine / Weapon Trait / DECISIVE
    ["23149"]     = true, -- Fire Opal / Weapon Trait / SHARPENED
    ["23165"]     = true, -- Carnelian / Weapon Trait / TRAINING
    ["23203"]     = true, -- Chysolite / Weapon Trait / POWERED
    ["23204"]     = true, -- Amethyst / Weapon Trait / CHARGED
    ["4442"]      = true, -- Emerald / Armor Trait / TRAINING
    ["4456"]      = true, -- Quartz / Armor Trait / STURDY
    ["23171"]     = true, -- Garnet / Armor Trait / INVIGORATING
    ["23173"]     = true, -- Sapphire / Armor Trait / DIVINES
    ["23219"]     = true, -- Diamond / Armor Trait / IMPENETRABLE
    ["23221"]     = true, -- Almandine / Armor Trait / WELL FITTED
    ["30219"]     = true, -- Bloodstone / Armor Trait / INFUSED
    ["30221"]     = true, -- Sardonyx / Armor Trait / REINFORCED
  },
  ["trashRaceMotif"] = {
    ["16424"]     = true, -- Crafting Motif 1: High Elf Style
    ["27245"]     = true, -- Crafting Motif 2: Dark Elf Style
    ["16428"]     = true, -- Crafting Motif 3: Wood Elf Style
    ["27244"]     = true, -- Crafting Motif 4: Nord Style
    ["16425"]     = true, -- Crafting Motif 5: Breton Style
    ["16427"]     = true, -- Crafting Motif 6: Redguard Style
    ["44698"]     = true, -- Crafting Motif 7: Khajiit Style
    ["16426"]     = true, -- Crafting Motif 8: Orc Style
    ["27246"]     = true, -- Crafting Motif 9: Argonian Style
  },
  ["trashRaceRareMotif"] = {
    ["51638"]     = true, -- Crafting Motif 11: Ancient Elf Style
    ["51565"]     = true, -- Crafting Motif 12: Barbaric Style
    ["51345"]     = true, -- Crafting Motif 13: Primal Style
    ["51688"]     = true, -- Crafting Motif 14: Daedric Style
  },
  ["trashEventItems"] = { -- not selling, for burn only // TODO: is it needed?
    ["jesterToys"] = {
      ["114945"]  = true, -- Cherry Blossom Twig
      ["114946"]  = true, -- Sparkwreath Dazzler
      ["114947"]  = true, -- Plume Dazzler
      ["114948"]  = true, -- Spiral Dazzler
      ["147300"]  = true, -- Revelry Pie
      ["120891"]  = true, -- Sparkly Hat Dazzler
    },
    ["jesterFood"] = {
      ["171322"]  = true, -- Sparkling Mudcrab Apple Cider
    },
  },
  ["trade"] = {
    ["3"] = { -- TradeskillType // CRAFTING_TYPE_ENCHANTING -- 3
      ["10"] = { -- Trade Skill Level // TODO: improve individual characters settings
        ["45831"] = true, -- Oko
        ["45832"] = true, -- Makko
        ["45833"] = true, -- Deni
      },
    },
  },
  ["whitelist"] = { -- this items will not affected by addon
    ["45838"]     = true, -- Rakeipa
    ["68342"]     = true, -- Hakeijo
    ["166045"]    = true, -- Indeko
  },
}


EVENT_MANAGER:RegisterForEvent(this.name, EVENT_ADD_ON_LOADED, function(event, addonName)
  if addonName ~= this.name then return end
  EVENT_MANAGER:UnregisterForEvent(this.name, EVENT_ADD_ON_LOADED)
  this:Initialize()
end)


function this:Initialize()
  -- Use SavedVars or Defaults as AddOn Settings
  self.settings = ZO_SavedVars:NewAccountWide(self.name .. "SavedVariables", 1, nil, DEFAULT_SETTINGS)

  if (LibAddonMenu2) then
    self:AddSettingsMenu(DEFAULT_SETTINGS)
  end

  if (LibCustomMenu) then
    self:AddContextMenu()
  end

  -- Do thing after getting new items in backpack
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, self.OnInventoryChanged)
  EVENT_MANAGER:AddFilterForEvent(self.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_IS_NEW_ITEM, true)
  EVENT_MANAGER:AddFilterForEvent(self.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK)
  EVENT_MANAGER:AddFilterForEvent(self.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)

  -- Turn off/on addon on open/close vendors store to prevent destoing buyed items
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_OPEN_STORE, self.f.OnStoreOpen) -- + EVENT_OPEN_FENCE
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CLOSE_STORE, self.f.TurnOn)
end


-- 
function LootSanitizer:addToList(list, itemLink)
  table.insert(list, itemLink)
end
function LootSanitizer:removeFromList(list, index)
  table.remove(list, index)
end
function LootSanitizer:writeList(list)
  if list == "" then
    d("Insert table name after chat command. Eg. junk or burn.")
  elseif list == "junk" then
    for index, value in ipairs(self.settings.listOfJunk) do
      d(zo_strformat("<<1>>. <<2>>", index, value))
    end
  elseif list == "burn" then
    for index, value in ipairs(self.settings.listOfBurn) do
      d(zo_strformat("<<1>>. <<2>>", index, value))
    end
  else
    d("Table with title '" .. tostring(list) .. "' not found.")
  end
end



function LootSanitizer:IsItemShouldBeDestroed(bagIndex, slotIndex, stackCountChange)
  local itemLink = GetItemLink(bagIndex, slotIndex)

  -- Don't do anything with Crown and Crafted items
  local isCrownCrate = IsItemFromCrownCrate(bagIndex, slotIndex)
  local isCrownStore = IsItemFromCrownStore(bagIndex, slotIndex)
  local isItemCrafted = IsItemLinkCrafted(itemLink) or GetItemCreatorName(bagIndex, slotIndex) ~= ""
  if isCrownCrate or isCrownStore or isItemCrafted then
    return false, "R1"
  end

  -- User Blacklist
  local isItemInBurnList = LootSanitizer.HasValue(LootSanitizer.settings.listOfBurn, itemLink)
  if isItemInBurnList then
    return true, "R100"
  end

  -- Get basic info
  local itemId = GetItemLinkItemId(itemLink)
  local strItemId = tostring(itemId)

  -- SIMPLE RULES
  if self.settings.burnRaceMaterial >= 1 and itemData["trashRaceMaterial"][strItemId] then
    return true, "R103"
  end

  if self.settings.burnRaceMaterial == 2 and itemData["trashRaceRareMaterial"][strItemId] then
    return true, "R104"
  end

  if self.settings.burnTraitMaterial and itemData["trashTraitMaterial"][strItemId] then
    return true, "R105"
  end

  if (self.settings.burnRaceMotif >= 1 and itemData["trashRaceMotif"][strItemId]) or (self.settings.burnRaceMotif == 2 and itemData["trashRaceRareMotif"][strItemId]) then
    -- Get additional info
    local isNewMotif = false
    if IsItemLinkBookPartOfCollection(itemLink) then
      if not IsItemLinkBookKnown(itemLink) then
        isNewMotif = true
      end
    end
    if self.settings.autoLearnRaceMotif and isNewMotif then
      if CallSecureProtected("UseItem", bagIndex, slotIndex) then
        EVENT_MANAGER:RegisterForEvent(self.name, EVENT_SHOW_BOOK, self.CloseMotifBook)
      end
    else
      return true, "R114"
    end
  end


  -- -- // TODO: add itemCache
  -- -- If an Item's check reaches this point, it's better to consider adding it to the itemCache
  -- -- Check if Item already in Cache and function can resolve faster
  -- if itemCache[strItemId] then
  --   local cacheAnswer = itemCache[strItemId]
  --   -- NOTE: Items that are used more frequently will remain in the cache longer.
  --   itemCache[strItemId]["usage"] = itemCache[strItemId]["usage"] + 1
  --   return cacheAnswer.bool, cacheAnswer.reason
  -- end


  -- Get additional info
  local itemIcon, itemQuantity, itemPrice, meetsUsageRequirement, locked, itemEquipType, itemStyle, quality, displayQuality = GetItemInfo(bagIndex, slotIndex)
  local itemTrait = GetItemTrait(bagIndex, slotIndex)
  local itemType, itemSpecialType = GetItemType(bagIndex, slotIndex)
  local itemRarity = displayQuality or quality

  -- RULES RELATED TO EQUIPMENT (include poisons!)
  if itemEquipType ~= EQUIP_TYPE_INVALID then
    local itemActorCategory = GetItemLinkActorCategory(itemLink)
    local armorType = GetItemArmorType(bagIndex, slotIndex)

    if self.settings.burnEquipment and itemActorCategory == GAMEPLAY_ACTOR_CATEGORY_PLAYER and itemPrice == 1 and itemRarity == 1 and itemTrait == 0 then
      return true, "R101"
    end

    if self.settings.burnCompanionItems >= 1 and itemActorCategory == GAMEPLAY_ACTOR_CATEGORY_COMPANION and itemRarity <= self.settings.burnCompanionItems then
      return true, "R102"
    end

    if self.settings.burnSimpleClothes and itemRarity == ITEM_DISPLAY_QUALITY_TRASH and itemType == ITEMTYPE_ARMOR and armorType == ARMORTYPE_NONE and (itemEquipType ~= EQUIP_TYPE_RING and itemEquipType ~= EQUIP_TYPE_NECK) then
      return true, "R115"
    end
  end

  -- RULES RELATED TO not EQUIPMENT (ixclude poisons!)
  if itemEquipType == EQUIP_TYPE_INVALID then
    -- Get additional info
    local itemTrade, _, _, itemEx2, _ = GetItemCraftingInfo(bagIndex, slotIndex)
    local itemReqSkillRank = GetItemLinkRequiredCraftingSkillRank(itemLink)


    if self.settings.burnIngredient and itemTrade == 5 and itemRarity == 1 and itemPrice == 1 then
      return true, "R106"
    end

    if self.settings.burnLockpick and itemId == 30357 and itemQuantity == 1 and GetItemLinkStacks(itemLink) >= 200 * self.settings.burnLockpickStackSaved then
      return true, "R107"
    end
  
    if self.settings.burnBait and itemType == 16 and itemSpecialType == 750 and GetItemLinkStacks(itemLink) >= 200 * self.settings.burnBaitStackSaved then
      return true, "R108"
    end

    if self.settings.burnCommonGlyph and (itemType == 20 or itemType == 21 or itemType == 26) and stackCountChange == 1 and IsItemLinkCrafted(itemLink) == false and itemRarity == 1 then
      return true, "R109"
    end
  
    if self.settings.burnRunePotency and itemType == 51 and stackCountChange <= self.settings.maxBurnedStack and itemEx2 ~= 10 then
      return true, "R110"
    end
  
    if self.settings.burnRuneEssence and itemType == 53 and stackCountChange <= self.settings.maxBurnedStack and itemData["whitelist"][strItemId] == nil then
      if self.settings.saveRuneEssenceForDaily and itemData["trade"]["3"]["10"][strItemId] then
        return false, "R111"
      end
      return true, "R112"
    end
  
    if self.settings.burnJunk and itemSpecialType == SPECIALIZED_ITEMTYPE_TRASH and itemPrice == 1 then
      return true, "R113"
    end
  end

  -- -- // TODO: add itemCache
  -- -- If an Item's check reaches this point, it's definitely? better to add it to the itemCache
  -- itemCache[strItemId] = {
  --   ["bool"] = false,
  --   ["reason"] = "R0",
  --   ["usage"] = 1
  -- }

  return false, "R0"
end


function LootSanitizer:IsItemShouldBeMarkedAsJunk(bagIndex, slotIndex, stackCountChange)
  local itemLink = GetItemLink(bagIndex, slotIndex)
  local itemId = GetItemLinkItemId(itemLink)

  -- Don't do anything with Crown and Crafted items
  local isCrownCrate = IsItemFromCrownCrate(bagIndex, slotIndex)
  local isCrownStore = IsItemFromCrownStore(bagIndex, slotIndex)
  local isItemCrafted = IsItemLinkCrafted(itemLink) or GetItemCreatorName(bagIndex, slotIndex) ~= ""
  if isCrownCrate or isCrownStore or isItemCrafted then
    return false, "R1"
  end

  -- User Blacklist
  local isItemInJunkList = self.HasValue(self.settings.listOfJunk, itemLink)
  if isItemInJunkList then
    return true, "R100"
  end

  -- Get additional info
  local itemIcon, itemQuantity, itemPrice, meetsUsageRequirement, locked, equipType, itemStyle, itemQuality, displayQuality = GetItemInfo(bagIndex, slotIndex)
  local itemTrait = GetItemTrait(bagIndex, slotIndex)
  local itemType, itemSpecialType = GetItemType(bagIndex, slotIndex)
  local itemTrade, _, _, itemEx2, _ = GetItemCraftingInfo(bagIndex, slotIndex)
  local itemReqSkillRank = GetItemLinkRequiredCraftingSkillRank(itemLink)
  local itemRarity = displayQuality or itemQuality

  -- Get Item users
  local isCompanionItem = GetItemActorCategory(bagIndex, slotIndex) == GAMEPLAY_ACTOR_CATEGORY_COMPANION
  local isPlayerEquip = false
  if isCompanionItem == false and ((equipType == EQUIP_TYPE_RING or equipType == EQUIP_TYPE_NECK) or (itemSpecialType == SPECIALIZED_ITEMTYPE_WEAPON or itemSpecialType == SPECIALIZED_ITEMTYPE_ARMOR)) then
    isPlayerEquip = true
  end

  -- Get additional traits info
  local isUnknownTrait = false
  local isInspirationTrait = false
  local traitType, traitDescription = GetItemLinkTraitInfo(itemLink)
  if traitType ~= ITEM_TRAIT_TYPE_NONE and traitDescription ~= "" then
    local traitInformation = GetItemTraitInformationFromItemLink(itemLink)
    isUnknownTrait = traitInformation == 1
    isInspirationTrait = traitInformation == 3
  end

  -- Not part of Sets
  local hasSet, setName, numBonuses, numNormalEquipped, maxEquipped, setId, numPerfectedEquipped = GetItemLinkSetInfo(itemLink)
  if self.settings.junkNormalEquipmentQuality and itemQuality <= self.settings.junkNormalEquipmentQuality and isPlayerEquip and hasSet == false then
    if not isUnknownTrait and not isInspirationTrait then
      return true, "R101"
    end
  end

  -- Items for selling
  if self.settings.junkOrnateEquipment and (itemTrait == 10 or itemTrait == 19 or itemTrait == 24) then
    return true, "R102"
  end

  -- Materials and raws for mid-level craft skills
  local function getTradeSkillData(table, bagIndex, slotIndex)
    local tradeSkillType, itemType, itemEx1, itemEx2, itemEx3 = GetItemCraftingInfo(bagIndex, slotIndex)
    local tradeSkillLineId = GetTradeskillLevelPassiveAbilityId(tradeSkillType)
    local tradeSkillLineName = GetAbilityName(tradeSkillLineId)
    local currentUpgradeLevel, maxUpgradeLevel
    if tradeSkillLineName ~= "" then
      local _rank_, _advised_, _active_, _discovered_= GetSkillLineDynamicInfo(skillType)
      local skillType, skillLineIndex, skillIndex, morphChoice, rank = GetSpecificSkillAbilityKeysByAbilityId(tradeSkillLineId)
      currentUpgradeLevel, maxUpgradeLevel = GetSkillAbilityUpgradeInfo(skillType, skillLineIndex, skillIndex)
    end

    table.name = tradeSkillLineName
    table.curRank = currentUpgradeLevel
    table.maxRank = maxUpgradeLevel
    table.materialReqRank = itemEx1
    table.materialReqLevel = itemEx2
  end

  local relTradeSkill = {}
  if itemTrade ~= CRAFTING_TYPE_INVALID then
    getTradeSkillData(relTradeSkill, bagIndex, slotIndex)
  end

  local isRawMaterial = itemType == 35 or itemType == 37 or itemType == 39 or itemType == 63
  local isMaterial = itemType == 36 or itemType == 38 or itemType == 40 or itemType == 64
  if self.settings.junkMiddleRawAndMaterial and (isRawMaterial or isMaterial) and relTradeSkill.maxRank and itemReqSkillRank > 1 and itemReqSkillRank < relTradeSkill.maxRank then
    return true, "R103"
  end

  -- Not crafted food
  if self.settings.junkNotCraftedFood and itemType == ITEMTYPE_FOOD and itemRarity < 3 then
    return true, "R104"
  end

  -- Not crafted drink
  if self.settings.junkNotCraftedDrink and itemType == ITEMTYPE_DRINK and itemRarity < 3 then
    return true, "R105"
  end

  -- Not crafted potion
  if self.settings.junkNotCraftedPotion and itemType == ITEMTYPE_POTION and itemRarity < 3 then
    return true, "R106"
  end

  -- Not crafted poison
  if self.settings.junkNotCraftedPoison and itemType == ITEMTYPE_POISON and itemRarity < 3 then
    return true, "R107"
  end

  -- Potion solvent of any level
  if self.settings.junkPotionSolvent and itemType == ITEMTYPE_POTION_BASE then
    return true, "R108"
  end

  -- Poison solvent of any level
  if self.settings.junkPoisonSolvent and itemType == ITEMTYPE_POISON_BASE then
    return true, "R109"
  end

  -- Trash items
  if self.settings.junkTrashItem and itemType == ITEMTYPE_TRASH then
    return true, "R110"
  end

  -- Treasure items
  if self.settings.junkTreasureItem and itemType == ITEMTYPE_TREASURE then
    return true, "R111"
  end

  -- Rare fish
  if self.settings.junkRareFish and itemSpecialType == SPECIALIZED_ITEMTYPE_COLLECTIBLE_RARE_FISH then
    return true, "R112"
  end

  -- Monster trophy
  if self.settings.junkMonsterTrophy and itemSpecialType == SPECIALIZED_ITEMTYPE_COLLECTIBLE_MONSTER_TROPHY then
    return true, "R113"
  end

  -- Baits
  if self.settings.junkBait and itemType == ITEMTYPE_LURE then
    return true, "R114"
  end

  -- Repair Kits
  if self.settings.junkExcessRepairKit and itemId == 44879 and GetItemLinkStacks(itemLink) >= 200 and GetSlotStackSize(bagIndex, slotIndex) == stackCountChange then
    return true, "R115"
  end

  -- Soul Gems
  if self.settings.junkExcessSoulgem and itemId == 33271 and GetItemLinkStacks(itemLink) >= 200 and GetSlotStackSize(bagIndex, slotIndex) == stackCountChange then
    return true, "R116"
  end

  return false, "R0"
end


function LootSanitizer:IsItemShouldBeBinded(bagIndex, slotIndex)
  local itemLink = GetItemLink(bagIndex, slotIndex)

  if IsItemLinkSetCollectionPiece(itemLink) then
    -- Get additional info
    local itemId = GetItemLinkItemId(itemLink)
    local _, _, _, _, _, _, _, quality, displayQuality = GetItemInfo(bagIndex, slotIndex)
    local itemRarity = displayQuality or quality

    if not IsItemSetCollectionPieceUnlocked(itemId) then
      if self.settings.autoBindQuality > 0 and itemRarity <= self.settings.autoBindQuality and not IsItemBoPAndTradeable(bagIndex, slotIndex) then
        return true, "R3" -- addon settings allow binding
      end
      return false, "R2" -- addon settings disallow binding
    end
    return false, "R1" -- already binded
  end
  return false, "R0" -- can't be binded
end


-- My First Function
function LootSanitizer.OnInventoryChanged(eventCode, bagIndex, slotIndex, isNewItem, itemSoundCategory, updateReason, stackCountChange)
  -- Don't do anything with Crown items
  if IsItemFromCrownCrate(bagIndex, slotIndex) or IsItemFromCrownStore(bagIndex, slotIndex) then
    do return end
  end

  if LootSanitizer.enabled == 0 then
    do return end
  end

  if LootSanitizer.settings.workMode == 0 then
    do return end
  elseif LootSanitizer.settings.workMode == 1 and GetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT) == "0" then
    do return end
  end

  -- Get Name for Chat Notifications
  local itemName = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemName(bagIndex, slotIndex))

  -- Get Additional Info for Burn Conditions
  local itemLink = GetItemLink(bagIndex, slotIndex)
  local _, _, itemPrice, _, _, itemEquipType, itemStyle, _, displayQuality = GetItemInfo(bagIndex, slotIndex)
  local itemType, itemSpecialType = GetItemType(bagIndex, slotIndex)

  -- Collection Status
  local isShouldBeBinded, bindReason = LootSanitizer:IsItemShouldBeBinded(bagIndex, slotIndex)
  if isShouldBeBinded then
    BindItem(bagIndex, slotIndex)
    LootSanitizer:Message(itemLink, "bind")
  end

  -- isItemTracked
  local isItemTracked = false
  if ESOMRL and ESOMRL.ISMRLTracking(itemLink) then
    isItemTracked = true
  end


  -- BURN
  local isJunk, junkReason = false, false
  local isBurn, burnReason = LootSanitizer:IsItemShouldBeDestroed(bagIndex, slotIndex, stackCountChange)
  if isBurn then
    -- if not IsShiftKeyDown() and not isItemTracked and (not isPlayerEquip and not isStyleMaterialTracked) then
    if not IsShiftKeyDown() and not isItemTracked then
      LootSanitizer:Message(itemLink)
      LootSanitizer:DestroyItem(bagIndex, slotIndex)
      LootSanitizer:UpdateStats(itemPrice * stackCountChange)
    end
  else
    -- JUNK
    isJunk, junkReason = LootSanitizer:IsItemShouldBeMarkedAsJunk(bagIndex, slotIndex, stackCountChange)
  end
  if LootSanitizer.settings.chatMode == 2 and isBurn then
    if IsShiftKeyDown() then
      d(zo_strformat(GetString(LOOTSANITIZER_MESSAGE_SHIFT_STOP_DESTROY), GetString(LOOTSANITIZER_NAME), itemName))
    elseif isItemTracked then
      d(zo_strformat(GetString(LOOTSANITIZER_MESSAGE_ADDON_STOP_DESTROY), GetString(LOOTSANITIZER_NAME), itemName))
    end
  end
  if LootSanitizer.settings.chatMode == 2 and burnReason ~= "R0" then
    d(zo_strformat("[<<1>>] Is <<2>> should be destored: <<3>>. Reason: <<4>>.", GetString(LOOTSANITIZER_NAME), itemName, tostring(isBurn), burnReason))
  end


  -- Auto Learn Junk Recipes
  if isJunk and LootSanitizer.settings.autoLearnJunkRecipes and itemType == ITEMTYPE_RECIPE and IsItemLinkRecipeKnown(itemLink) == false then
    if CallSecureProtected("UseItem", bagIndex, slotIndex) then
      d(zo_strformat(GetString(LOOTSANITIZER_MESSAGE_RECIPE_LEARN_SUCCESS), GetString(LOOTSANITIZER_NAME), itemName))
    else
      d(zo_strformat(GetString(LOOTSANITIZER_MESSAGE_RECIPE_LEARN_FAILURE), GetString(LOOTSANITIZER_NAME), itemName))
    end
  end

  -- JUNK
  if isJunk then
    LootSanitizer:SetItemJunk(bagIndex, slotIndex)
  end
  if LootSanitizer.settings.chatMode == 2 and junkReason ~= "R0" then
    d(zo_strformat("[<<4>>] Is <<1>> a junk? Answer: <<2>>. Reason: <<3>>.", itemName, tostring(isJunk), junkReason, GetString(LOOTSANITIZER_NAME)))
  end

end





function LootSanitizer:DestroyItem(bagIndex, slotIndex)
  DestroyItem(bagIndex, slotIndex)
  if self.settings.playSound then
    PlaySound(SOUNDS.INVENTORY_DESTROY_JUNK)
  end
end

function LootSanitizer:SetItemJunk(bagIndex, slotIndex)
  SetItemIsJunk(bagIndex, slotIndex, true)
  if self.settings.playSound then
    PlaySound(SOUNDS.INVENTORY_ITEM_UNJUNKED) -- SKILL_PURCHASED / BOOK_ACQUIRED / LOCKPICKING_BREAK
  end
end

function LootSanitizer:CloseMotifBook()
  local function callMeToo()
    d("Book should be closed: " ..  GetTimeString())
    EndInteraction(INTERACTION_BOOK)
  end
  d("Waiting for book interaction: " ..  GetTimeString())
  EVENT_MANAGER:UnregisterForEvent(LootSanitizer.name, EVENT_SHOW_BOOK)
  zo_callLater(callMeToo, 500)
end

-- Updating session stats
function LootSanitizer:UpdateStats(itemPrice, slotCount)
  slotCount = slotCount or 1
  self.stats.price = self.stats.price + itemPrice
  self.stats.space = self.stats.space + slotCount
end

-- Updating session stats
function LootSanitizer:ShowStats()
  CHAT_ROUTER:AddSystemMessage(zo_strformat("[<<1>>] В течение этой сессии аддон освободил <<2>> ячеек в сумке. Удалено предметов на сумму: <<3>>.", "LootSanitizer", LootSanitizer.stats.space, LootSanitizer.stats.price))
end


-- list of additional functions
this["f"] = {
  ["OnStoreOpen"] = function ()
    this.f.TurnOff() -- to prevent the destruction of purchased items
    if this.settings.autoJunkSell and HasAnyJunk(BAG_BACKPACK, true) then
      SellAllJunk()
    end
  end,
  ["TurnOff"] = function ()
    this.enabled = 0 -- prevent the destruction of purchased items
    this:DebugTime("Store Open")
  end,
  ["TurnOn"] = function ()
    this.enabled = 1
    this:DebugTime("Store Close")
  end,
  -- @entryType [string] -- "destroy" or "bind" or "smth else" from msgType
  -- @itemLink  [string] -- ESO's itemLink
  -- @entryInfo [object] -- additional info like count or value
  ["AddLogEntry"] = function(entryType, itemLink, entryInfo)
    local msgType = {
      ["delete"] = {
        ["string"] = GetString(LOOTSANITIZER_NAME),
        ["params"] = ""
      },
      ["bind"] = {},
      ["auto_sell"] = {},
      ["learn_success"] = {},
      ["learn_failure"] = {},
    }
  end,
}


function LootSanitizer:DebugTime(text)
  if self.settings.chatMode == 2 then
    local text = ": " .. text or ""
    local time = tostring(ZO_FormatClockTime())
    d(time .. text)
  end
end


function LootSanitizer:Message (text, type)
  local SanitizerTexts =
  {
    delete = "[" .. GetString(LOOTSANITIZER_NAME) .. "] " .. GetString(LOOTSANITIZER_ACTION),
    bind   = "[" .. GetString(LOOTSANITIZER_NAME) .. "] " .. GetString(LOOTSANITIZER_BINDACTION),
  }
  local textTypePrefix = "delete"
  if type then textTypePrefix = type end
  if LootSanitizer.settings.chatMode > 0 then
    CHAT_ROUTER:AddSystemMessage(string.format(SanitizerTexts[textTypePrefix] .. " " .. text .. "."))
  end
end


function this:AddContextMenu()
  local function AddItem(inventorySlot, slotActions)
    local valid = ZO_Inventory_GetBagAndIndex(inventorySlot)
    if not valid then return end

    local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
    local itemLink = GetItemLink(bagId, slotIndex)

    -- List of Junk
    local isInAccountJunkList, listJunkIndex = self.HasValue(self.settings.listOfJunk, itemLink);
    slotActions:AddCustomSlotAction(isInAccountJunkList and LOOTSANITIZER_LCMACTION_JUNK_OFF or LOOTSANITIZER_LCMACTION_JUNK_ON, function()
      if isInAccountJunkList == false then
        self:addToList(self.settings.listOfJunk, itemLink)
        self:SetItemJunk(bagId, slotIndex)
      else
        self:removeFromList(self.settings.listOfJunk, listJunkIndex)
      end
    end , "")

    -- List of Burn
    if self.settings.displayAutoBurnAction then
      local isInAccountBurnList, listBurnIndex = self.HasValue(self.settings.listOfBurn, itemLink);
      slotActions:AddCustomSlotAction(isInAccountBurnList and LOOTSANITIZER_LCMACTION_BURN_OFF or LOOTSANITIZER_LCMACTION_BURN_ON, function()
        if isInAccountBurnList == false then
          self:addToList(self.settings.listOfBurn, itemLink)
        else
          self:removeFromList(self.settings.listOfBurn, listBurnIndex)
        end
      end , "")
    end
  end

  LibCustomMenu:RegisterContextMenu(AddItem, LibCustomMenu.CATEGORY_LATE)
end


function LootSanitizer.HasValue (checkedTable, checkedValue)
  for index, value in ipairs(checkedTable) do
    if value == checkedValue then
      return true, index
    end
  end
  return false
end


function LootSanitizer:openSettingsWindow()
  if (self.settingsPanel) then
    LibAddonMenu2:OpenToPanel(self.settingsPanel)
  end
end


function LootSanitizer:test()
  local itemId = 33150
  d(tostring(itemData.trashRaceMaterial[tostring(itemId)]))
  d(ZO_Currency_FormatGamepad(CURT_MONEY, 3, ZO_CURRENCY_FORMAT_AMOUNT_ICON))

  local function ShowTextInputDialog(titleText, bodyText, callbackFunction)
    -- Создаем параметры диалогового окна
    local dialogName = "MyTextInputDialog"
    local dialog = ZO_Dialogs_FindDialog(dialogName)
    
    if not dialog then
        -- Функция для создания элементов управления диалогового окна
        local function CreateTextInputDialog()
            local dialog = ZO_KeyboardInputDialog:New("MyTextInputDialogDialog")
            
            -- Добавляем поле ввода текста
            local editControl = CreateControlFromVirtual("$(parent)Edit", dialog, "ZO_DefaultEditForBackdrop") -- 
            editControl:SetAnchor(TOP, dialog.text, BOTTOM, 0, 20)
            editControl:SetDimensions(300, 30)
            editControl:SetMaxInputChars(100)
            
            -- Настраиваем обработчик нажатия Enter
            editControl:SetHandler("OnEnter", function(self)
                local dialog = ZO_Dialogs_FindDialog("MyTextInputDialog")
                if dialog then
                    local submitButton = dialog.buttons[1].control
                    submitButton:Click()
                end
            end)
            
            dialog.edit = editControl
            dialog:SetHandler("OnEffectivelyShown", function(self)
                self.edit:TakeFocus()
            end)
            
            return dialog
        end
        -- Создаем новое диалоговое окно, если оно еще не существует
        ZO_Dialogs_RegisterCustomDialog(dialogName,
        {
            -- customControl = function() return CreateTextInputDialog() end,
            title =
            {
                text = titleText or "Input Text"
            },
            mainText = 
            {
                text = bodyText or "Please enter text:"
            },
            buttons =
            {
                {
                    -- control = GetButton("Submit"),
                    text = SI_DIALOG_CONFIRM,
                    keybind = "DIALOG_PRIMARY",
                    callback = function(dialog)
                        -- local editControl = dialog:GetNamedChild("Edit")
                        -- local text = editControl:GetText()
                        -- callbackFunction(text)
                    end
                },
                {
                    -- control = GetButton("Cancel"),
                    text = SI_DIALOG_CANCEL,
                    keybind = "DIALOG_NEGATIVE",
                    callback = function(dialog)
                        callbackFunction(nil)
                    end
                }
            }
        })
    end
    
    -- Показываем диалоговое окно
    ZO_Dialogs_ShowDialog(dialogName)
  end

  --
  ShowTextInputDialog("Enter your name", "Please enter your character name:", function(result)
      if result then
          d("You entered: " .. result)
      else
          d("Input was cancelled")
      end
  end)
end




this.RegisterChatCommand = function(command, callback, description)
  local LSC = LibSlashCommander
  if not LSC then
    SLASH_COMMANDS[command] = function(input) callback(input) end
  else
    LSC:Register(command, function(input) callback(input) end, description)
  end
end

this.RegisterChatCommand("/lstest", LootSanitizer.test, "lstest")


-- SLASH_COMMANDS["/lss"] = function()
--   LootSanitizer:openSettingsWindow()
-- end

SLASH_COMMANDS["/lootsanitizer"] = function()
  LootSanitizer:openSettingsWindow()
end

SLASH_COMMANDS["/lsstats"] = function()
  LootSanitizer:ShowStats()
end

SLASH_COMMANDS["/lslist"] = function(list)
  LootSanitizer:writeList(list)
end




-- LootSanitizer.linkHandlers =
-- {
--   lslink = function (data) if data then d("linkTypeData: " .. data) end end
-- }

-- function LootSanitizer:OnLinkClicked( rawLink, mouseButton, linkText, linkStyle, linkType, ... )
--   if (type(linkType) == "string" and LootSanitizer.linkHandlers[linkType]) then
--     LootSanitizer.linkHandlers[linkType](...)
--     return true -- link has been handled
--   end
-- end

-- function LootSanitizer:registerChatLinks()
--   -- register link type
--   LibChatMessage:RegisterCustomChatLink("lslink")
--   -- set handlers
--   LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_CLICKED_EVENT, self.OnLinkClicked, self)
--   LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, self.OnLinkClicked, self)
-- end
