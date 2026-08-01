local TTCC_WRITFIELD_ONE = 10
local TTCC_WRITFIELD_TWO = 11
local TTCC_WRITFIELD_THREE = 12
local TTCC_WRITFIELD_FOUR = 13
local TTCC_WRITFIELD_FIVE = 14
local TTCC_WRITFIELD_SIX = 15
local TTCC_EFFECT_REWARD_FIELD = 24

local TTCC_WRIT_ITEMTYPE_POTION = 199
local TTCC_WRIT_ITEMTYPE_POISON = 239

local TTCC_WRIT_ITEMTYPE_JEWELRY_NECK = 18
local TTCC_WRIT_ITEMTYPE_JEWELRY_RING = 24

-- |H1:item:71059:6:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h
-- |H1:item:156735:4:1:0:0:0:117956:0:0:0:0:0:0:0:0:0:0:0:0:0:10000|h|h
-- |H1:item:156733:4:1:0:0:0:117926:0:0:0:0:0:0:0:0:0:0:0:0:0:10000|h|h
-- /script d(TTCCompanion:GetVoucherCountByItemLink("|H1:item:121533:6:1:0:0:0:40:190:5:38:17:46:0:0:0:0:0:0:0:0:686400|h|h"))
-- |H1:item:153482:4:1:0:0:0:87690:0:0:0:0:0:0:0:0:0:0:0:0:0:20000|h|h witches writ
-- |H1:item:153482:4:1:0:0:0:87691:0:0:0:0:0:0:0:0:0:0:0:0:0:10000|h|h witches writ
-- |H1:item:153482:4:1:0:0:0:87686:0:0:0:0:0:0:0:0:0:0:0:0:0:10000|h|h witches writ
function TTCCompanion:GetVoucherCountByItemLink(itemLink)
  local data = TTCCompanion:GetPotionEffectWritRewardField(itemLink)
  local itemType, _ = GetItemLinkItemType(itemLink)
  if itemType == ITEMTYPE_MASTER_WRIT then
    local quotient, remainder = math.modf(data / 10000)
    local voucherCount = quotient + math.floor(0.5 + remainder)
    return voucherCount
  end
  return 0
end

-- /script d({TTCCompanion:GetWritFields("|H1:item:121533:6:1:0:0:0:40:190:5:38:17:46:0:0:0:0:0:0:0:0:686400|h|h")})
function TTCCompanion:GetWritFields(itemLink)
  local data = { ZO_LinkHandler_ParseLink(itemLink) }
  local field1 = tonumber(data[TTCC_WRITFIELD_ONE])
  local field2 = tonumber(data[TTCC_WRITFIELD_TWO])
  local field3 = tonumber(data[TTCC_WRITFIELD_THREE])
  local field4 = tonumber(data[TTCC_WRITFIELD_FOUR])
  local field5 = tonumber(data[TTCC_WRITFIELD_FIVE])
  local field6 = tonumber(data[TTCC_WRITFIELD_SIX])
  return field1, field2, field3, field4, field5, field6
end

-- /script d(TTCCompanion:GetPotionEffectWritRewardField("|H1:item:121533:6:1:0:0:0:40:190:5:38:17:46:0:0:0:0:0:0:0:0:686400|h|h"))
function TTCCompanion:GetPotionEffectWritRewardField(itemLink)
  local data = { ZO_LinkHandler_ParseLink(itemLink) }
  local field24 = tonumber(data[TTCC_EFFECT_REWARD_FIELD])
  return field24
end

-- /script d(TTCCompanion:IsItemLinkAlchemyItem("|H1:item:119696:5:1:0:0:0:199:2:11:21:0:0:0:0:0:0:0:0:0:0:50000|h|h"))
function TTCCompanion:IsItemLinkAlchemyItem(itemLink)
  local data = TTCCompanion:GetWritFields(itemLink)
  if (data == TTCC_WRIT_ITEMTYPE_POTION) or (data == TTCC_WRIT_ITEMTYPE_POISON) then
    return true
  end
  return false
end

function TTCCompanion:IsItemLinkEnchantingItem(itemLink)
  local requiredItemLink = TTCCompanion:GetMasterWritRequiredItemLink(itemLink)
  local itemType, _ = GetItemLinkItemType(requiredItemLink)
  if itemType == ITEMTYPE_GLYPH_ARMOR or itemType == ITEMTYPE_GLYPH_JEWELRY or itemType == ITEMTYPE_GLYPH_WEAPON then
    return true
  end
  return false
end

-- /script d(TTCCompanion:IsItemLinkProvisioningItem("|H1:item:167170:5:1:0:0:0:33825:0:0:0:0:0:0:0:0:0:0:0:0:0:10000|h|h"))
function TTCCompanion:IsItemLinkProvisioningItem(itemLink)
  local requiredItemLink = TTCCompanion:GetMasterWritRequiredItemLink(itemLink)
  local itemType, _ = GetItemLinkItemType(requiredItemLink)
  if itemType == ITEMTYPE_DRINK or itemType == ITEMTYPE_FOOD then
    return true
  end
  return false
end

-- /script d(TTCCompanion:IsItemLinkWeaponArmorItem("|H1:item:119682:5:1:0:0:0:65:192:4:325:12:104:0:0:0:0:0:0:0:0:72000|h|h"))
function TTCCompanion:IsItemLinkWeaponArmorItem(itemLink)
  local data = TTCCompanion:GetWritFields(itemLink)
  if TTCCompanion.blacksmithClothierWoodworkingItemType[data] then
    return true
  end
  return false
end

-- /script d(TTCCompanion:IsItemLinkJewelryItem("|H1:item:153737:5:1:0:0:0:18:255:4:177:21:0:0:0:0:0:0:0:0:0:1837500|h|h"))
function TTCCompanion:IsItemLinkJewelryItem(itemLink)
  local data = TTCCompanion:GetWritFields(itemLink)
  if data == TTCC_WRIT_ITEMTYPE_JEWELRY_NECK or data == TTCC_WRIT_ITEMTYPE_JEWELRY_RING then
    return true
  end
  return false
end

-- /script d(TTCCompanion:IsItemLinkFurnitureItem("|H1:item:156735:4:1:0:0:0:117954:0:0:0:0:0:0:0:0:0:0:0:0:0:10000|h|h"))
function TTCCompanion:IsItemLinkFurnitureItem(itemLink)
  local requiredItemLink = TTCCompanion:GetMasterWritRequiredItemLink(itemLink)
  local itemType, _ = GetItemLinkItemType(requiredItemLink)
  if itemType == ITEMTYPE_FURNISHING then
    return true
  end
  return false
end

-- /script d(TTCCompanion:IsItemLinkNewLifeFestivalWrit("|H1:item:121532:6:1:0:0:0:29:194:5:48:25:98:0:0:0:0:0:0:0:0:1248000|h|h"))
function TTCCompanion:IsItemLinkNewLifeFestivalWrit(itemLink)
  local itemType, _ = GetItemLinkItemType(itemLink)
  local requiredItemLink = nil
  local requiredItemLinkId = nil
  if itemType == ITEMTYPE_MASTER_WRIT then
    requiredItemLink = TTCCompanion:GetMasterWritRequiredItemLink(itemLink)
    if TTCCompanion:IsItemLinkFurnitureItem(itemLink) or TTCCompanion:IsItemLinkProvisioningItem(itemLink) then
      requiredItemLinkId = GetItemLinkItemId(requiredItemLink)
      if TTCCompanion.winterWritsRequiredQty[requiredItemLinkId] then
        return true
      end
    end
  end
  return false
end

-- /script d(TTCCompanion:GetItemLinkRequiredItemId("|H1:item:156735:4:1:0:0:0:117954:0:0:0:0:0:0:0:0:0:0:0:0:0:10000|h|h"))
-- only gets the itemId and returns a fake itemLink, nothing else
function TTCCompanion:GetMasterWritRequiredItemLink(itemLink)
  local itemId = TTCCompanion:GetWritFields(itemLink)
  return string.format('|H1:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h', itemId)
end

-- /script d(TTCCompanion:GetMasterWritFurnatureItemLink("|H1:item:156731:4:1:0:0:0:117940:0:0:0:0:0:0:0:0:0:0:0:0:0:10000|h|h"))
function TTCCompanion:GetMasterWritFurnatureItemLink(itemLink)
  if TTCCompanion:IsItemLinkFurnitureItem(itemLink) then
    return TTCCompanion:GetMasterWritRequiredItemLink(itemLink)
  end
  return nil
end

function TTCCompanion:GetTradeSkillInformation(itemLink)
  local TTCC_TRADESKILL_ALCHEMY = 77
  local TTCC_TRADESKILL_PROVISIONING = 76

  local ITEMTYPE_TO_ABILITYINDEX = {
    [ITEMTYPE_POISON] = 4,
    [ITEMTYPE_POTION] = 4,
    [ITEMTYPE_FOOD] = 5,
    [ITEMTYPE_DRINK] = 6,
  }
  local SPECIALIZED_ITEMTYPE_TO_ABILITYINDEX = {
    [SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD] = 5,
    [SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK] = 6,
  }
  local itemType, specializedItemType = GetItemLinkItemType(itemLink)
  local skillAbilityIndex = ITEMTYPE_TO_ABILITYINDEX[itemType]
  if (itemType == ITEMTYPE_RECIPE and (specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD or specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK)) then
    skillAbilityIndex = SPECIALIZED_ITEMTYPE_TO_ABILITYINDEX[specializedItemType]
  end
  local craftingType = TTCC_TRADESKILL_PROVISIONING
  if itemType == ITEMTYPE_POTION or itemType == ITEMTYPE_POISON then
    craftingType = TTCC_TRADESKILL_ALCHEMY
  end

  local numSkillLines = GetNumSkillLines(SKILL_TYPE_TRADESKILL)
  for sl = 1, numSkillLines do
    local skillLineId = GetSkillLineId(SKILL_TYPE_TRADESKILL, sl)
    if skillLineId == craftingType then
      local numAbilities = GetNumSkillAbilities(SKILL_TYPE_TRADESKILL, sl)
      for ab = 1, numAbilities do
        if ab == skillAbilityIndex then
          local _, _, _, _, _, purchased, _, rank = GetSkillAbilityInfo(SKILL_TYPE_TRADESKILL, sl, ab)
          return purchased, rank
        end
      end
    end --
  end
  return false, 0
end

function TTCCompanion:GetSkillLineProvisioningAlchemyRank(itemLink)
  local multiplier = 1 -- you can't divide by 0
  local purchaced, skillRank = TTCCompanion:GetTradeSkillInformation(itemLink)
  local itemType, specializedItemType = GetItemLinkItemType(itemLink)
  if purchaced then
    if itemType == ITEMTYPE_POTION or itemType == ITEMTYPE_FOOD or itemType == ITEMTYPE_DRINK or (itemType == ITEMTYPE_RECIPE and (specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD or specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK)) then
      multiplier = skillRank + 1
    elseif itemType == ITEMTYPE_POISON then
      multiplier = (skillRank + 1) * 4
    end
  end
  if not purchaced and itemType == ITEMTYPE_POISON then
    multiplier = 4
  end
  return multiplier
end

-- /script d(TTCCompanion:MaterialCostPrice("|H1:item:156731:4:1:0:0:0:117940:0:0:0:0:0:0:0:0:0:0:0:0:0:10000|h|h"))
function TTCCompanion:MaterialCostPrice(itemLink)
  if not TTCCompanion:IsItemLinkNewLifeFestivalWrit(itemLink) then
    return nil
  end

  local cost = 0
  local numIngredients = 0
  local winterWritsRequiredQty = nil
  local flavorText = GetItemLinkFlavorText(itemLink)
  --[[Use GetMasterWritRequiredItemLink() for now to cover food or Furnature
  instead of GetMasterWritFurnatureItemLink() ]]--
  local newLifeFestivalItemLink = TTCCompanion:GetMasterWritRequiredItemLink(itemLink)
  if not newLifeFestivalItemLink then
    return nil
  end

  numIngredients = TTCCompanion.GetItemLinkRecipeNumIngredients(newLifeFestivalItemLink)
  if ((numIngredients or 0) == 0) then
    -- Try to clean up item link by moving it to level 1
    newLifeFestivalItemLink = newLifeFestivalItemLink:gsub(":0", ":1", 1)
    numIngredients = TTCCompanion.GetItemLinkRecipeNumIngredients(newLifeFestivalItemLink)
  end

  if ((numIngredients or 0) > 0) then
    for i = 1, numIngredients do
      local ingredientItemLink, numRequired = TTCCompanion.GetItemLinkRecipeIngredientInfo(newLifeFestivalItemLink, i)
      if ingredientItemLink then
        local ttcPrice = TTCCompanion:GetTamrielTradeCentrePriceToUse(itemLink) or 0
        cost = cost + (ttcPrice * numRequired)
      end
    end

    if TTCCompanion:IsItemLinkProvisioningItem(itemLink) then
      local multiplier = TTCCompanion:GetSkillLineProvisioningAlchemyRank(newLifeFestivalItemLink)
      cost = cost / multiplier
    end

    local qtyRequired = TTCCompanion:GetWinterWritRequiredQty(itemLink)
    if qtyRequired then
      return cost * qtyRequired
    else
      return cost
    end
  else
    return nil
  end
end

-- /script d(TTCCompanion:MaterialCostPriceTip("|H1:item:156731:4:1:0:0:0:117940:0:0:0:0:0:0:0:0:0:0:0:0:0:10000|h|h"))
function TTCCompanion:MaterialCostPriceTip(itemLink, writCost)
  local cost = TTCCompanion:MaterialCostPrice(itemLink)
  local costTipString = ""
  local writCostTipString = ""
  local totalCostTipString = ""
  local materialTooltipString = ""
  local totalCost = 0
  if cost and not writCost then
    costTipString = TTCCompanion.LocalizedNumber(cost) .. TTCCompanion.coinIcon
    materialTooltipString = string.format(GetString(TTCC_MATCOST_PRICE_TIP), costTipString)
  elseif cost and writCost then
    totalCost = cost + writCost
    costTipString = TTCCompanion.LocalizedNumber(cost) .. TTCCompanion.coinIcon
    writCostTipString = TTCCompanion.LocalizedNumber(writCost) .. TTCCompanion.coinIcon
    totalCostTipString = TTCCompanion.LocalizedNumber(totalCost) .. TTCCompanion.coinIcon
    materialTooltipString = string.format(GetString(TTCC_MATCOST_PLUS_WRITCOST_TIP), costTipString, writCostTipString, totalCostTipString)
  end
  local qtyRequired = TTCCompanion:GetWinterWritRequiredQty(itemLink)
  if materialTooltipString ~= "" and not qtyRequired then
    materialTooltipString = materialTooltipString .. "\n(qty not in database)"
  end
  if materialTooltipString ~= "" then
    return materialTooltipString
  else
    return nil
  end
end

-- /script d(TTCCompanion:GetWinterWritRequiredQty("|H1:item:156731:4:1:0:0:0:117940:0:0:0:0:0:0:0:0:0:0:0:0:0:10000|h|h"))
-- /script d(TTCCompanion:GetWritFields("|H1:item:156731:4:1:0:0:0:117940:0:0:0:0:0:0:0:0:0:0:0:0:0:10000|h|h"))
-- /script d(TTCCompanion.winterWritsRequiredQty[118034])
function TTCCompanion:GetWinterWritRequiredQty(itemLink)
  local itemId = TTCCompanion:GetWritFields(itemLink)
  if TTCCompanion.winterWritsRequiredQty[itemId] ~= nil and TTCCompanion.winterWritsRequiredQty[itemId] > 0 then
    return TTCCompanion.winterWritsRequiredQty[itemId]
  end
  return nil
end

--[[
DWC - Deep Winter Charity Writs
NLC - New Life Charity Writs
ICW - Imperial Charity Writs
]]--

-- Deep Winter Charity Writs
TTCCompanion.winterWritsRequiredQty = {
  [117954] = 12, -- Rough Crate, Bolted - DWC (x12),
  [117926] = 12, -- Rough Stretcher, Military - DWC (x12),
  [117956] = 12, -- Rough Box, Boarded - DWC (x12),
  [117942] = 12, -- Rough Knife, Butcher - DWC (x12),
  [115153] = 1, -- Breton Bed, Bunk - DWC, NLC (x1)
  [118036] = 1, -- Common Candle, Set - DWC, NLC (x1)
  [118012] = 1, -- Common Washtub, Empty - DWC, NLC (x1)
  [118048] = 1, -- Common Table, Slanted - DWC (x1), NLC (x1), ICW (x1)
  [117991] = 1, -- Stool, Carved - DWC, NLC (x1)
  [118007] = 1, -- Common Basket, Tall - DWC, NLC (x1)
  [118034] = 1, -- Common Platter, Serving - DWC, NLC (x1)
  [120410] = 3, -- Rough Cup, Empty - DWC (x3), NLC (x12), ICW (x3)
  [117943] = 3, -- Rough Bowl, Common - DWC (x3), NLC (x12), ICW (x3)
  [117929] = 12, -- Rough Crate, Reinforced - DWC (x12),
  [117960] = 12, -- Rough Container, Cargo - DWC (x12),
  [117940] = 12, -- Rough Hatchet, Practical - DWC (x12),
  [117963] = 12, -- Rough Bedroll, Basic - NLC (x12), ICW (x3)
  [33819] = 12, -- Chicken Breast ICW (x12)
  [33813] = 12, -- Roast Corn ICW (x12)
  [33825] = 12, -- Grape Preserves ICW (x12)
}
TTCCompanion.blacksmithClothierWoodworkingItemType = {
  [17] = true, -- Helmet
  [18] = true, -- Neck
  [19] = true, -- Chest
  [20] = true, -- Shoulder
  [21] = true, -- Belt
  [22] = true, -- Legs
  [23] = true, -- Feet
  [24] = true, -- Ring
  [25] = true, -- Gloves
  [26] = true, -- Helmet, Light
  [27] = true, -- Neck, Light
  [28] = true, -- Chest, Light
  [29] = true, -- Shoulder, Light
  [30] = true, -- Belt, Light
  [31] = true, -- Legs, Light
  [32] = true, -- Feet, Light
  [33] = true, -- Ring, Light
  [34] = true, -- Gloves, Light
  [35] = true, -- Helmet, Medium
  [36] = true, -- Neck, Medium
  [37] = true, -- Chest, Medium
  [38] = true, -- Shoulder, Medium
  [39] = true, -- Belt, Medium
  [40] = true, -- Legs, Medium
  [41] = true, -- Feet, Medium
  [42] = true, -- Ring, Medium
  [43] = true, -- Gloves, Medium
  [44] = true, -- Helmet, Heavy
  [45] = true, -- Neck, Heavy
  [46] = true, -- Chest, Heavy
  [47] = true, -- Shoulder, Heavy
  [48] = true, -- Belt, Heavy
  [49] = true, -- Greaves, Heavy
  [50] = true, -- Feet, Heavy
  [51] = true, -- Ring, Heavy
  [52] = true, -- Gloves, Heavy
  [53] = true, -- 1H Axe
  [56] = true, -- 1H Mace
  [59] = true, -- 1H Sword
  [62] = true, -- Dagger
  [65] = true, -- Shield
  [66] = true, -- Rune/Off-Hand
  [67] = true, -- 2H Sword
  [68] = true, -- 2H Axe
  [69] = true, -- 2H Maul
  [70] = true, -- Bow
  [71] = true, -- Restoration Staff
  [72] = true, -- Inferno Staff
  [73] = true, -- Frost Staff
  [74] = true, -- Lightning Staff
  [75] = true, -- Chest, Medium
  [76] = true, -- Bread
  [77] = true, -- Meat
  [78] = true, -- Stew
  [80] = true, -- Wine
  [81] = true, -- Spirits
  [82] = true, -- Beer
}
-- provisioning writ, purple, |H1:item:119693:5:1:0:0:0:71059:0:0:0:0:0:0:0:0:0:0:0:0:0:400000|h|h
-- enchanting writ, yellow, |H1:item:121528:6:1:0:0:0:45869:225:5:0:0:0:0:0:0:0:0:0:0:0:66000|h|h
-- alchemy writ, purple, |H1:item:119696:5:1:0:0:0:199:2:11:21:0:0:0:0:0:0:0:0:0:0:50000|h|h
-- cloth writ, yellow, |H1:item:121533:6:1:0:0:0:37:190:5:224:15:82:0:0:0:0:0:0:0:0:787200|h|h
-- blacksmith writ, yellow,  |H1:item:121529:6:1:0:0:0:46:188:5:51:11:117:0:0:0:0:0:0:0:0:1037400|h|h
-- woodowrking writ, purple,  |H1:item:119681:5:1:0:0:0:71:192:4:539:26:62:0:0:0:0:0:0:0:0:576000|h|h
-- jewelry writ, purple, |H1:item:153737:5:1:0:0:0:18:255:4:177:21:0:0:0:0:0:0:0:0:0:1837500|h|h
-- winter writ, blue, |H1:item:156735:4:1:0:0:0:117954:0:0:0:0:0:0:0:0:0:0:0:0:0:10000|h|h
--[[
    ,   writ1            = tonumber(x[10])
    ,   writ2            = tonumber(x[11])
    ,   writ3            = tonumber(x[12])
    ,   writ4            = tonumber(x[13])
    ,   writ5            = tonumber(x[14])
    ,   writ6            = tonumber(x[15])
    -- provisioning
    recipe      = fields.writ1
-- enchanting
        local glyph_id    = fields.writ1
    local level_num   = fields.writ2
    local quality_num = fields.writ3
-- jewelry
-- alchemy
        local solvent_id  = fields.writ1
    -- blacksmith/clothier/woodworking
    local item_num      = fields.writ1
    local material_num  = fields.writ2
    local quality_num   = fields.writ3
    local set_num       = fields.writ4
    local trait_num     = fields.writ5
    local motif_num     = fields.writ6
]]--