CanICraftThis.DLC = {
  instancesByName = {},
}

function CanICraftThis.DLC:register(instance)
  CanICraftThis.assert(instance.collectibleId ~= nil, "instance.collectibleId ~= nil")
  CanICraftThis.assert(instance.name ~= nil, "instance.name ~= nil")
  self.instancesByName[instance.name] = instance
end

function CanICraftThis.DLC:registerAll()
  local categoryIndex
  for categoryIndex = 1, GetNumCollectibleCategories() do
    local categoryName, numSubCategories = GetCollectibleCategoryInfo(categoryIndex)
    if categoryName == "Stories" then
      local subCategoryIndex
      for subCategoryIndex = 1, numSubCategories do
        local subCategoryName, numCollectibles = GetCollectibleSubCategoryInfo(categoryIndex, subCategoryIndex)
        if subCategoryName ~= "Dungeon DLC" then
          local collectibleIndex
          for collectibleIndex = 1, numCollectibles do
            local collectibleId = GetCollectibleId(categoryIndex, subCategoryIndex, collectibleIndex)
            local collectibleName = GetCollectibleInfo(collectibleId)
            self:register { collectibleId = collectibleId, name = collectibleName }
          end
        end
      end
    end
  end
end

CanICraftThis.DLC:registerAll()

function CanICraftThis.DLC:tryFromName(name)
  return self.instancesByName[name]
end
