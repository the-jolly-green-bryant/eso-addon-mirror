CanICraftThis.StyleCollectibleCache = {
  version = 3,
}

function CanICraftThis.StyleCollectibleCache:open()
  local data = ZO_SavedVars:NewAccountWide(CanICraftThis.savedVarsName, self.version, "styleCollectibleCache", {}, GetWorldName())
  CanICraftThis.assert(data ~= nil, "data ~= nil")
  local instance = { data = data }
  setmetatable(instance, { __index = self })
  return instance
end

local nameExceptions = {
  ["daedric skirt"] = "daedric breeches",
}

local function detectStyle(collectibleName)
  local style
  for _, style in pairs(CanICraftThis.EqStyle.instances) do
    if string.find(collectibleName, style.collectibleNamePattern) then
      return style
    end
  end
end

local function makeRecipeDetectorForSubCategory(subCategoryName)
  local patternMap = {}
  for _, recipe in pairs(CanICraftThis.EqRecipe.instancesByName) do
    if recipe.styleCollectibleSubCategory == subCategoryName then
      if patternMap[recipe.styleCollectibleNamePattern] == nil then
        patternMap[recipe.styleCollectibleNamePattern] = {}
      end
      table.insert(patternMap[recipe.styleCollectibleNamePattern], recipe)
    end
  end
  if #patternMap == 1 then
    -- There is only one recipe name pattern that can possibly appear in this subcategory.
    local _, recipeSet = pairs(patternMap)()
    return function(_) return recipeSet end
  else
    -- Multiple recipes could appear in this subcategory, so we must pattern-match the collectible name.
    return function(collectibleName)
      local pattern, recipeSet
      for pattern, recipeSet in pairs(patternMap) do
        if string.find(collectibleName, pattern) then
          return recipeSet
        end
      end
    end
  end
end

local function makeKey(style, recipe)
  return style.id * 100 + recipe.id
end

function CanICraftThis.StyleCollectibleCache:populate()
  local data = self.data
  local categoryIndex
  for categoryIndex = 1, GetNumCollectibleCategories() do
    local categoryName, numSubCategories = GetCollectibleCategoryInfo(categoryIndex)
    if categoryName == "Weapon Styles" or categoryName == "Armor Styles" then
      local subCategoryIndex
      for subCategoryIndex = 1, numSubCategories do
        local subCategoryName, numCollectibles = GetCollectibleSubCategoryInfo(categoryIndex, subCategoryIndex)
        local detectRecipes = makeRecipeDetectorForSubCategory(subCategoryName)
        local collectibleIndex
        for collectibleIndex = 1, numCollectibles do
          local collectibleId = GetCollectibleId(categoryIndex, subCategoryIndex, collectibleIndex)
          local collectibleName = GetCollectibleInfo(collectibleId)
          local collectibleName = string.gsub(string.lower(collectibleName), "%s*%d+$", "")
          local collectibleName = nameExceptions[collectibleName] or collectibleName
          local style = detectStyle(collectibleName)
          local recipes = detectRecipes(collectibleName)
          if style ~= nil and recipes ~= nil then
            local recipe
            for _, recipe in ipairs(recipes) do
              self.data[makeKey(style, recipe)] = collectibleId
            end
          end
        end
      end
    end
  end
end

function CanICraftThis.StyleCollectibleCache:populateIfNeeded()
  if #self.data == 0 then
    self:populate()
  end
end

function CanICraftThis.StyleCollectibleCache:verify()
  local data = self.data
  local style
  for _, style in pairs(CanICraftThis.EqStyle.instances) do
    local recipe
    for _, recipe in pairs(CanICraftThis.EqRecipe.instancesByName) do
      if recipe.skill.equipmentInfo.usesStyle then
        if data[makeKey(style, recipe)] == nil then
          if style.name == "Outlaw" and recipe.name == "Robe" then
            -- Ignore; this style is a special case and does not have a Robe page.
            -- https://en.uesp.net/wiki/Online:Outlaw_Style#Notes
          elseif CanICraftThis.isHonorGuardCollectibleBugPresent and style.name == "Honor Guard" and recipe.name == "Jack" then
            -- Ignore; due to a bug in ESO's collectible database,
            -- no collectible ID yields the name "Honor Guard Jack".
          else
            CanICraftThis.reportUnexpected("Failed to find a collectible ID for the " .. style.name .. " " .. recipe.name .. " style.")
          end
        end
      end
    end
  end
end

function CanICraftThis.StyleCollectibleCache:getCollectibleId(style, recipe)
  return self.data[makeKey(style, recipe)]
end
