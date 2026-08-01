--[[
-------------------------------------------------------------------------------
-- LibRecipe
-------------------------------------------------------------------------------
-- Author: Sharlikran
-- Created: 2024-07-14
--
-- This file is part of the LibRecipe library and is licensed under the BSD 3-Clause License.
-- See the LICENSE file included with this distribution for full terms.
-------------------------------------------------------------------------------
]]
local libName, libVersion = "LibRecipe", 112
LibRecipe.libName = libName
LibRecipe.libVersion = libVersion

local function GetRequiredLevel(itemLink, itemType)
  return itemType ~= ITEMTYPE_RECIPE and GetItemLinkRequiredLevel(itemLink) or 1
end

local function GetVirtualIndex(itemLink)
  local itemType = GetItemLinkItemType(itemLink)
  local itemId = GetItemLinkItemId(itemLink)
  local requiredLevel = GetRequiredLevel(itemLink, itemType)
  local requiredChampionPoints = GetItemLinkRequiredChampionPoints(itemLink) / 10
  local quality = GetItemLinkDisplayQuality(itemLink)
  local index = itemId .. ":" .. requiredLevel .. ":" .. requiredChampionPoints .. ":" .. quality
  return index
end

local function IsItemLinkCraftedGlyph(itemLink)
  local itemType = GetItemLinkItemType(itemLink)
  local isCrafted = IsItemLinkCrafted(itemLink)
  local isGlyph = itemType == ITEMTYPE_GLYPH_ARMOR or itemType == ITEMTYPE_GLYPH_JEWELRY or itemType == ITEMTYPE_GLYPH_WEAPON
  if isCrafted and isGlyph then
    return true
  end
  return false
end

local function IsItemLinkCraftedPotion(itemLink)
  local itemType = GetItemLinkItemType(itemLink)
  local isCrafted = IsItemLinkCrafted(itemLink)
  local isPotion = itemType == ITEMTYPE_POTION or itemType == ITEMTYPE_POISON
  if isCrafted and isPotion then
    return true
  end
  return false
end

local function GetNumberOfPotionIngredients(itemLink)
  local effect1, effect2, effect3, effect4 = LibAlchemy:GetEffectsFromItemLink(itemLink)
  local bestIngredients = LibAlchemy:getBestCombination({ LibAlchemy.effectsByWritID[effect1], LibAlchemy.effectsByWritID[effect2], LibAlchemy.effectsByWritID[effect3], LibAlchemy.effectsByWritID[effect4] }) or {}
  local numberOfIngredients = #bestIngredients
  return numberOfIngredients
end

--[[
GetItemLinkRequiredLevel("|H1:item:30357:175:1:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h")
GetItemLinkRequiredChampionPoints("|H1:item:30357:175:1:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h")
GetItemLinkDisplayQuality("|H1:item:30357:175:1:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h")
1
0
1
]]--
function LibRecipe:GetSolventItemLink(itemLink)
  if not IsItemLinkCraftedPotion(itemLink) then return end
  local itemType, _ = GetItemLinkItemType(itemLink)
  local solventIndex = GetItemLinkRequiredLevel(itemLink) + GetItemLinkRequiredChampionPoints(itemLink)

  local solventItemLink = {
    [ITEMTYPE_POTION] = {
      [3] = "|H1:item:883:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
      [10] = "|H1:item:1187:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
      [20] = "|H1:item:4570:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
      [30] = "|H1:item:23265:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
      [40] = "|H1:item:23266:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
      [60] = "|H1:item:23267:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
      [100] = "|H1:item:23268:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
      [150] = "|H1:item:64500:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
      [200] = "|H1:item:64501:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
    },
    [ITEMTYPE_POISON] = {
      [3] = "|H1:item:75357:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
      [10] = "|H1:item:75358:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
      [20] = "|H1:item:75359:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
      [30] = "|H1:item:75360:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
      [40] = "|H1:item:75361:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
      [60] = "|H1:item:75362:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
      [100] = "|H1:item:75363:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
      [150] = "|H1:item:75364:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
      [200] = "|H1:item:75365:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
    },
  }
  return solventItemLink[itemType][solventIndex]
end

function LibRecipe:GetItemLinkFromItemId(itemId)
  return string.format("|H1:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", itemId)
end

function LibRecipe:GetRecipeItemLink(itemLink)
  if IsItemLinkCraftedGlyph(itemLink) or IsItemLinkCraftedPotion(itemLink) then
    return itemLink
  end
  local itemId = GetItemLinkItemId(itemLink)
  local identifiedItemLink = LibRecipe:GetItemLinkFromItemId(itemId)

  -- Use the metatable to resolve the mapped recipe link
  local recipeLink = LibRecipe.recipeData[identifiedItemLink]
  if not recipeLink then return end

  -- Return the resolved recipe link with updated quality
  return recipeLink
end

function LibRecipe:GetNumIngredients(itemLink)
  itemLink = LibRecipe:GetRecipeItemLink(itemLink)
  if IsItemLinkCraftedGlyph(itemLink) then
    local virtualIndex = GetVirtualIndex(itemLink)
    if LibRecipe.virtualRecipe[virtualIndex] then
      return #LibRecipe.virtualRecipe[virtualIndex]
    end
    return 0
  end
  if IsItemLinkCraftedPotion(itemLink) then
    return GetNumberOfPotionIngredients(itemLink)
  end
  local itemType = GetItemLinkItemType(itemLink)
  if not itemLink or itemType ~= ITEMTYPE_RECIPE then return 0 end
  return GetItemLinkRecipeNumIngredients(itemLink)
end

function LibRecipe:GetIngredientInfoByIndex(itemLink, index)
  itemLink = LibRecipe:GetRecipeItemLink(itemLink)
  if IsItemLinkCraftedGlyph(itemLink) then
    local virtualIndex = GetVirtualIndex(itemLink)
    if LibRecipe.virtualRecipe[virtualIndex] then
      local ingredientItemLink = LibRecipe.virtualRecipe[virtualIndex][index].item
      local displayQuality = GetItemLinkDisplayQuality(ingredientItemLink)
      local ingredientName = GetItemLinkName(ingredientItemLink)
      local amountRequired = LibRecipe.virtualRecipe[virtualIndex][index].required
      return ingredientItemLink, ingredientName, displayQuality, amountRequired
    end
    return nil, nil, nil, nil
  end
  if IsItemLinkCraftedPotion(itemLink) then
    local effect1, effect2, effect3, effect4 = LibAlchemy:GetEffectsFromItemLink(itemLink)
    local bestIngredients = LibAlchemy:getBestCombination({ LibAlchemy.effectsByWritID[effect1], LibAlchemy.effectsByWritID[effect2], LibAlchemy.effectsByWritID[effect3], LibAlchemy.effectsByWritID[effect4] }) or {}
    if bestIngredients[index] then
      local itemId = bestIngredients[index]
      local ingredientItemLink = LibRecipe:GetItemLinkFromItemId(itemId)
      local ingredientName = GetItemLinkName(ingredientItemLink)
      local displayQuality = GetItemLinkDisplayQuality(ingredientItemLink)
      local amountRequired = 1 -- always one alchemy material per potion
      return ingredientItemLink, ingredientName, displayQuality, amountRequired
    end
    return nil, nil, nil, nil
  end
  local ingredientItemLink = GetItemLinkRecipeIngredientItemLink(itemLink, index, LINK_STYLE_DEFAULT)
  if ingredientItemLink == '' then return nil, nil, nil, nil end
  local displayQuality = GetItemLinkDisplayQuality(ingredientItemLink)
  local ingredientName, amountInInventoryAndBank, amountRequired = GetItemLinkRecipeIngredientInfo(itemLink, index)
  return ingredientItemLink, ingredientName, displayQuality, amountRequired
end

function LibRecipe:GetRecipeIngredients(itemLink)
  local numIngredients = LibRecipe:GetNumIngredients(itemLink)
  local ingredients = {}

  for index = 1, numIngredients do
    local ingredientItemLink, ingredientName, displayQuality, amountRequired = LibRecipe:GetIngredientInfoByIndex(itemLink, index)
    if ingredientItemLink and amountRequired then
      table.insert(ingredients, { link = ingredientItemLink, name = ingredientName, quality = displayQuality, quantity = amountRequired })
    end
  end

  return ingredients
end

-- 1 == positive potency 2 == negative potency
-- 1 == Additive, 2 == Subtractive
local effectIds = {
  [43573] = { 45831, 2 },
  [26580] = { 45831, 1 },
  [45868] = { 45832, 2 },
  [26582] = { 45832, 1 },
  [45867] = { 45833, 2 },
  [26588] = { 45833, 1 },
  [26581] = { 45834, 1 },
  [45869] = { 45834, 2 },
  [26583] = { 45835, 1 },
  [45870] = { 45835, 2 },
  [26589] = { 45836, 1 },
  [45871] = { 45836, 2 },
  [26586] = { 45837, 2 },
  [26587] = { 45837, 1 },
  [26848] = { 45838, 1 },
  [26849] = { 45838, 2 },
  [5365] = { 45839, 1 },
  [5364] = { 45839, 2 },
  [43570] = { 45840, 2 },
  [26844] = { 45840, 1 },
  [26841] = { 45841, 1 },
  [26847] = { 45841, 2 },
  [26845] = { 45842, 2 },
  [5366] = { 45842, 1 },
  [54484] = { 45843, 1 },
  [26591] = { 45843, 2 },
  [45874] = { 45846, 1 },
  [45875] = { 45846, 2 },
  [45885] = { 45847, 2 },
  [45883] = { 45847, 1 },
  [45886] = { 45848, 2 },
  [45884] = { 45848, 1 },
  [45873] = { 45849, 2 },
  [45872] = { 45849, 1 },
  [166046] = { 166045, 2 },
  [166047] = { 166045, 1 },
  [68344] = { 68342, 2 },
  [68343] = { 68342, 1 },
}

local potencyIds = {
  [5] = { 45855, 45817 },
  [10] = { 45856, 45818 },
  [15] = { 45857, 45819 },
  [20] = { 45806, 45820 },
  [25] = { 45807, 45821 },
  [30] = { 45808, 45822 },
  [35] = { 45809, 45823 },
  [40] = { 45810, 45824 },
  [45] = { 45811, 45825 },
  [51] = { 45812, 45826 },
  [53] = { 45813, 45827 },
  [55] = { 45814, 45828 },
  [57] = { 45815, 45829 },
  [63] = { 45816, 45830 },
  [65] = { 64509, 64508 },
  [66] = { 68341, 68340 },
}

-- aspect rune ID numbers
local qualityIds = {
  [1] = 45850,
  [2] = 45851,
  [3] = 45852,
  [4] = 45853,
  [5] = 45854,
}

local function splitItem(t, index)
  local itemId, itemLevel, itemCPLevel, itemQuality = zo_strmatch(index, "(%d+):(%d+):(%d+):(%d+)")
  itemId = tonumber(itemId)
  itemLevel = tonumber(itemLevel)
  itemCPLevel = tonumber(itemCPLevel)
  itemQuality = tonumber(itemQuality)
  local combinedLvl = itemLevel + itemCPLevel
  local essence = effectIds[itemId]
  if not essence then return end
  if not potencyIds[combinedLvl] then return end
  local potency = potencyIds[combinedLvl][essence[2]]
  local quality = qualityIds[itemQuality]
  if not potency or not quality or not essence then return end
  return {
    { ["item"] = LibRecipe:GetItemLinkFromItemId(potency), ["required"] = 1 },
    { ["item"] = LibRecipe:GetItemLinkFromItemId(essence[1]), ["required"] = 1 },
    { ["item"] = LibRecipe:GetItemLinkFromItemId(quality), ["required"] = 1 }
  }
end

LibRecipe.virtualRecipe = {}
setmetatable(LibRecipe.virtualRecipe, { ["__index"] = splitItem })

-- |H1:item:33837:3:1:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h Baked Apples
-- |H1:item:45889:3:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h Recipe: Baked Apples
-- |H1:item:26588:370:50:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h Crafted Glyph
-- |H1:item:126359:3:1:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h Crafted Furnishing
-- |H1:item:181513:5:1:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h Crafted Furnishing
-- |H1:item:54340:30:3:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:196608|h|h sip of magika
-- |H1:item:54339:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:8454917|h|h essence of health
-- |H1:item:30145:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:724739|h|h essence of spell power
-- |H1:item:44714:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:856325|h|h essence of weapon power

-- /script d(IsItemLinkCrafted("|H1:item:181513:5:1:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"))
-- /script d(LibRecipe:GetItemLinkFromItemId(26588))
-- /script d(LibRecipe:GetNumIngredients("|H1:item:126359:3:1:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"))
-- /script d(LibRecipe:GetNumIngredients("|H1:item:30146:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:1114373|h|h"))
-- /script d(LibRecipe:GetRecipeItemLink("|H1:item:126359:3:1:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"))
-- /script d(LibRecipe:GetIngredientInfoByIndex("|H1:item:126359:3:1:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h", 1))
-- GetItemLinkInventoryCount(*string* _itemLink_, *[InventoryCountBagOption|#InventoryCountBagOption]* _countType_)
-- /script d(GetItemLinkInventoryCount("|H0:item:114893:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", INVENTORY_COUNT_BAG_OPTION_BACKPACK))
-- /script d(GetItemLinkInventoryCount("|H0:item:114893:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", INVENTORY_COUNT_BAG_OPTION_BANK))
-- /script d(GetItemLinkInventoryCount("|H0:item:114893:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", INVENTORY_COUNT_BAG_OPTION_BACKPACK_AND_BANK_AND_CRAFT_BAG))
-- /script d({LibAlchemy:GetEffectsFromItemLink("|H1:item:54339:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:8454917|h|h")})
-- GetItemLinkRecipeIngredientItemLink will only work with a Recipe
-- /script d(GetItemLinkRecipeIngredientItemLink("|H1:item:45889:3:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", 1, LINK_STYLE_DEFAULT))
-- /script d(GetItemLinkRecipeNumIngredients("|H1:item:45889:3:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|"))

local MAX_ITEM_LINK = 230000

local function indexRecipes(t, index)
  local itemId = GetItemLinkItemId(index)
  local offset = LibRecipe_SavedVariables.recipeData[itemId]
  if offset == nil then
    return nil
  end
  local recipeId = itemId + offset

  if recipeId then
    -- Item is in the list!
    return LibRecipe:GetItemLinkFromItemId(recipeId)
  end
  return nil
end

local recipeMetatable = {
  ["__index"] = indexRecipes,
}
LibRecipe.recipeData = {}

local task = LibAsync:Create("LibRecipe_ProcessRecipes")
function LibRecipe:ProcessRecipes()
  LibRecipe_SavedVariables = LibRecipe_SavedVariables or {}
  LibRecipe_SavedVariables.recipeData = LibRecipe_SavedVariables.recipeData or {}

  -- Check if the loop needs to run
  local currentApiVersion = GetAPIVersion()
  if LibRecipe_SavedVariables.lastApiVersion and LibRecipe_SavedVariables.lastApiVersion == currentApiVersion then
    -- API version matches, directly set the metatable
    setmetatable(LibRecipe.recipeData, recipeMetatable)
    -- d("Recipes already processed for this API version.")
    return
  end

  -- Ensure LibAsync is available
  local async = LibAsync
  if not async then
    return -- Exit if LibAsync is not loaded
  end

  task:For(1, MAX_ITEM_LINK):Do(function(recNumber)
    local itemLink = string.format("|H1:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", recNumber)
    local itemType = GetItemLinkItemType(itemLink)

    if itemType == ITEMTYPE_RECIPE then
      local resultLink = GetItemLinkRecipeResultItemLink(itemLink)
      if resultLink ~= "" then
        local itemId = GetItemLinkItemId(itemLink)
        local resultItemId = GetItemLinkItemId(resultLink)
        LibRecipe_SavedVariables.recipeData[resultItemId] = itemId - resultItemId
      end
    end
  end):Then(function()
    -- Update the API version and set the metatable after processing
    LibRecipe_SavedVariables.lastApiVersion = currentApiVersion
    setmetatable(LibRecipe.recipeData, recipeMetatable)
    -- d("Recipes processed and metatable set successfully.")
  end)
end

function LibRecipe.Slash(allArgs)
  local args = ""
  local argNum = 0
  for w in zo_strgmatch(allArgs, "%w+") do
    argNum = argNum + 1
    if argNum == 1 then args = w end
  end
  args = zo_strlower(args)

  if args == "rescan" then
    LibRecipe_SavedVariables.lastApiVersion = GetAPIVersion() - 1
    ReloadUI()
  end
end

local function OnLoad(eventCode, addOnName)
  if addOnName ~= LibRecipe.libName then return end

  LibRecipe:ProcessRecipes()

  SLASH_COMMANDS['/librecipe'] = LibRecipe.Slash

  EVENT_MANAGER:UnregisterForEvent(LibRecipe.libName, EVENT_ADD_ON_LOADED)
end
EVENT_MANAGER:RegisterForEvent(LibRecipe.libName, EVENT_ADD_ON_LOADED, OnLoad)

