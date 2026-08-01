CanICraftThis.CraftingStationCache = {
  version = 4,
}

function CanICraftThis.CraftingStationCache:open()
  local data = ZO_SavedVars:NewAccountWide(CanICraftThis.savedVarsName, self.version, "craftingStationCache", {}, GetWorldName())
  CanICraftThis.assert(data ~= nil, "data ~= nil")
  if data.requiredPassiveAbility == nil then
    data.requiredPassiveAbility = {}
  end
  if data.requiredQuantity == nil then
    data.requiredQuantity = {}
  end
  local instance = { data = data }
  setmetatable(instance, { __index = self })
  return instance
end

local recipeNameExceptions = {
  ["Shirt"] = "Jerkin",
}

function CanICraftThis.CraftingStationCache:updateFromCurrentCraftingStation()
  local skillId = GetCraftingInteractionType()
  local skill = CanICraftThis.Skill:fromId(skillId)
  if not skill.equipmentInfo then return end
  local recipeIndex
  for recipeIndex = 1, GetNumSmithingPatterns() do
    local recipeName, _, _, numMaterials, numTraitsRequired = GetSmithingPatternInfo(recipeIndex)
    if numTraitsRequired == 0 then
      recipeName = recipeNameExceptions[recipeName] or recipeName
      local recipe = CanICraftThis.EqRecipe:fromName(recipeName)
      local requiredQuantityForMainMaterial = {}
      local materialIndex
      for materialIndex = 1, numMaterials do
        local material, _, requiredQuantity, _, _, _, _, _, _, requiredPassiveAbility = GetSmithingPatternMaterialItemInfo(recipeIndex, materialIndex)
        local material = CanICraftThis.Material:sanitise(material)
        if CanICraftThis.Material:isEqMain(material) then
          local prevRequiredPassiveAbility = self.data.requiredPassiveAbility[material]
          if prevRequiredPassiveAbility ~= nil and prevRequiredPassiveAbility ~= requiredPassiveAbility then
            CanICraftThis.reportUnexpected(
              "multiple values of requiredPassiveAbility for same material " .. material .. ": " ..
              tostring(prevRequiredPassiveAbility) .. ", " .. tostring(requiredPassiveAbility)
            )
          end
          self.data.requiredPassiveAbility[material] = requiredPassiveAbility
          local prevRequiredQuantity = requiredQuantityForMainMaterial[material]
          if prevRequiredQuantity == nil or requiredQuantity < prevRequiredQuantity then
            requiredQuantityForMainMaterial[material] = requiredQuantity
          end
        end
      end
      self.data.requiredQuantity[recipe.id] = requiredQuantityForMainMaterial
    else
      -- This is a set-specific recipe (e.g. "Adept Rider's Ring").
      -- Generic recipes (e.g. "Ring") will also be listed, so we can simply skip this.
    end
  end
end

function CanICraftThis.CraftingStationCache:installHook()
  EVENT_MANAGER:RegisterForEvent(CanICraftThis.addonName, EVENT_CRAFTING_STATION_INTERACT, function()
    self:updateFromCurrentCraftingStation()
  end)
end

function CanICraftThis.CraftingStationCache:getRequiredPassiveAbility(mainMaterial)
  return self.data.requiredPassiveAbility[mainMaterial]
end

function CanICraftThis.CraftingStationCache:getRequiredMainMaterialQuantity(mainMaterial, recipe)
  local a = self.data.requiredQuantity[recipe.id]
  if a ~= nil then
    return a[mainMaterial]
  end
end
