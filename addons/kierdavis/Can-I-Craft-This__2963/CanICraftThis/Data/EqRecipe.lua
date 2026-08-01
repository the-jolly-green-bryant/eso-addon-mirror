CanICraftThis.EqRecipe = {
  instancesByName = {},
}

function CanICraftThis.EqRecipe:register(instance)
  CanICraftThis.assert(instance.id ~= nil, "instance.id ~= nil")
  CanICraftThis.assert(instance.name ~= nil, "instance.name ~= nil")
  CanICraftThis.assert(instance.traitCategoryId ~= nil, "instance.traitCategoryId ~= nil")
  CanICraftThis.assert(instance.skill ~= nil, "instance.skill ~= nil")
  CanICraftThis.assert(instance.researchLineIndex ~= nil, "instance.researchLineIndex ~= nil")
  CanICraftThis.assert(instance.numTraits ~= nil, "instance.numTraits ~= nil")
  instance.namePattern = CanICraftThis.literalPattern(instance.name)
  instance.writTextPattern = "craft an? [^;]+ " .. instance.namePattern .. "%A"
  if instance.skill.equipmentInfo.usesStyle then
    CanICraftThis.assert(instance.styleCollectibleSubCategory ~= nil, "instance.styleCollectibleSubCategory ~= nil")
    instance.styleCollectibleNamePattern = (instance.styleCollectibleNamePattern or instance.namePattern) .. "$"
  else
    CanICraftThis.assert(instance.styleCollectibleSubCategory == nil, "instance.styleCollectibleSubCategory == nil")
    CanICraftThis.assert(instance.styleCollectibleNamePattern == nil, "instance.styleCollectibleNamePattern == nil")
  end
  self.instancesByName[instance.name] = instance
end

function CanICraftThis.EqRecipe:registerAll()
  local argsByResearchLineName = {}
  local skill
  for _, skill in pairs(CanICraftThis.Skill.instancesById) do
    if skill.equipmentInfo then
      local researchLineIndex
      for researchLineIndex = 1, GetNumSmithingResearchLines(skill.id) do
        local researchLineName, _, numTraits = GetSmithingResearchLineInfo(skill.id, researchLineIndex)
        argsByResearchLineName[researchLineName] = {
          skill = skill,
          researchLineIndex = researchLineIndex,
          numTraits = numTraits,
        }
      end
    end
  end
  local function register(args)
    args.researchLineName = args.researchLineName or args.name
    local argsFromResearchLine = argsByResearchLineName[args.researchLineName]
    if argsFromResearchLine == nil and args.traitCategoryId == ITEM_TRAIT_TYPE_CATEGORY_JEWELRY then
      -- Jewelry crafting DLC (Summerset) not enabled. Don't register this recipe.
      return
    end
    for key, value in pairs(argsFromResearchLine) do
      args[key] = value
    end
    self:register(args)
  end
  register {
    id = 1,
    name = "Axe",
    traitCategoryId = ITEM_TRAIT_TYPE_CATEGORY_WEAPON,
    styleCollectibleSubCategory = "One-Handed",
  }
  register {
    id = 2,
    name = "Mace",
    traitCategoryId = ITEM_TRAIT_TYPE_CATEGORY_WEAPON,
    styleCollectibleSubCategory = "One-Handed",
  }
  register {
    id = 3,
    name = "Sword",
    traitCategoryId = ITEM_TRAIT_TYPE_CATEGORY_WEAPON,
    styleCollectibleSubCategory = "One-Handed",
  }
  register {
    id = 4,
    name = "Battle Axe",
    traitCategoryId = ITEM_TRAIT_TYPE_CATEGORY_WEAPON,
    styleCollectibleSubCategory = "Two-Handed",
  }
  register {
    id = 5,
    name = "Maul",
    traitCategoryId = ITEM_TRAIT_TYPE_CATEGORY_WEAPON,
    styleCollectibleSubCategory = "Two-Handed",
  }
  register {
    id = 6,
    name = "Greatsword",
    traitCategoryId = ITEM_TRAIT_TYPE_CATEGORY_WEAPON,
    styleCollectibleSubCategory = "Two-Handed",
  }
  register {
    id = 7,
    name = "Dagger",
    traitCategoryId = ITEM_TRAIT_TYPE_CATEGORY_WEAPON,
    styleCollectibleSubCategory = "One-Handed",
  }
  register {
    id = 8,
    name = "Cuirass",
    traitCategoryId = ITEM_TRAIT_TYPE_CATEGORY_ARMOR,
    styleCollectibleSubCategory = "Chest",
  }
  register {
    id = 9,
    name = "Sabatons",
    traitCategoryId = ITEM_TRAIT_TYPE_CATEGORY_ARMOR,
    styleCollectibleSubCategory = "Feet",
  }
  register {
    id = 10,
    name = "Gauntlets",
    traitCategoryId = ITEM_TRAIT_TYPE_CATEGORY_ARMOR,
    styleCollectibleSubCategory = "Hands",
  }
  register {
    id = 11,
    name = "Helm",
    traitCategoryId = ITEM_TRAIT_TYPE_CATEGORY_ARMOR,
    styleCollectibleSubCategory = "Head",
  }
  register {
    id = 12,
    name = "Greaves",
    traitCategoryId = ITEM_TRAIT_TYPE_CATEGORY_ARMOR,
    styleCollectibleSubCategory = "Legs",
  }
  register {
    id = 13,
    name = "Pauldron",
    traitCategoryId = ITEM_TRAIT_TYPE_CATEGORY_ARMOR,
    styleCollectibleSubCategory = "Shoulders",
    styleCollectibleNamePattern = "pauldrons?",
  }
  register {
    id = 14,
    name = "Girdle",
    traitCategoryId = ITEM_TRAIT_TYPE_CATEGORY_ARMOR,
    styleCollectibleSubCategory = "Waist",
  }
  register {
    id = 15,
    name = "Robe",
    traitCategoryId = ITEM_TRAIT_TYPE_CATEGORY_ARMOR,
    researchLineName = "Robe & Jerkin",
    styleCollectibleSubCategory = "Chest",
  }
  register {
    id = 16,
    name = "Jerkin",
    traitCategoryId = ITEM_TRAIT_TYPE_CATEGORY_ARMOR,
    researchLineName = "Robe & Jerkin",
    styleCollectibleSubCategory = "Chest",
  }
  register {
    id = 17,
    name = "Shoes",
    traitCategoryId = ITEM_TRAIT_TYPE_CATEGORY_ARMOR,
    styleCollectibleSubCategory = "Feet",
  }
  register {
    id = 18,
    name = "Gloves",
    traitCategoryId = ITEM_TRAIT_TYPE_CATEGORY_ARMOR,
    styleCollectibleSubCategory = "Hands",
  }
  register {
    id = 19,
    name = "Hat",
    traitCategoryId = ITEM_TRAIT_TYPE_CATEGORY_ARMOR,
    styleCollectibleSubCategory = "Head",
  }
  register {
    id = 20,
    name = "Breeches",
    traitCategoryId = ITEM_TRAIT_TYPE_CATEGORY_ARMOR,
    styleCollectibleSubCategory = "Legs",
  }
  register {
    id = 21,
    name = "Epaulets",
    traitCategoryId = ITEM_TRAIT_TYPE_CATEGORY_ARMOR,
    styleCollectibleSubCategory = "Shoulders",
  }
  register {
    id = 22,
    name = "Sash",
    traitCategoryId = ITEM_TRAIT_TYPE_CATEGORY_ARMOR,
    styleCollectibleSubCategory = "Waist",
  }
  register {
    id = 23,
    name = "Jack",
    traitCategoryId = ITEM_TRAIT_TYPE_CATEGORY_ARMOR,
    styleCollectibleSubCategory = "Chest",
  }
  register {
    id = 24,
    name = "Boots",
    traitCategoryId = ITEM_TRAIT_TYPE_CATEGORY_ARMOR,
    styleCollectibleSubCategory = "Feet",
  }
  register {
    id = 25,
    name = "Bracers",
    traitCategoryId = ITEM_TRAIT_TYPE_CATEGORY_ARMOR,
    styleCollectibleSubCategory = "Hands",
  }
  register {
    id = 26,
    name = "Helmet",
    traitCategoryId = ITEM_TRAIT_TYPE_CATEGORY_ARMOR,
    styleCollectibleSubCategory = "Head",
  }
  register {
    id = 27,
    name = "Guards",
    traitCategoryId = ITEM_TRAIT_TYPE_CATEGORY_ARMOR,
    styleCollectibleSubCategory = "Legs",
  }
  register {
    id = 28,
    name = "Arm Cops",
    traitCategoryId = ITEM_TRAIT_TYPE_CATEGORY_ARMOR,
    styleCollectibleSubCategory = "Shoulders",
  }
  register {
    id = 29,
    name = "Belt",
    traitCategoryId = ITEM_TRAIT_TYPE_CATEGORY_ARMOR,
    styleCollectibleSubCategory = "Waist",
  }
  register {
    id = 30,
    name = "Bow",
    traitCategoryId = ITEM_TRAIT_TYPE_CATEGORY_WEAPON,
    styleCollectibleSubCategory = "Bow",
  }
  register {
    id = 31,
    name = "Inferno Staff",
    traitCategoryId = ITEM_TRAIT_TYPE_CATEGORY_WEAPON,
    styleCollectibleSubCategory = "Staff",
    styleCollectibleNamePattern = "staff",
  }
  register {
    id = 32,
    name = "Ice Staff",
    traitCategoryId = ITEM_TRAIT_TYPE_CATEGORY_WEAPON,
    styleCollectibleSubCategory = "Staff",
    styleCollectibleNamePattern = "staff",
  }
  register {
    id = 33,
    name = "Lightning Staff",
    traitCategoryId = ITEM_TRAIT_TYPE_CATEGORY_WEAPON,
    styleCollectibleSubCategory = "Staff",
    styleCollectibleNamePattern = "staff",
  }
  register {
    id = 34,
    name = "Restoration Staff",
    traitCategoryId = ITEM_TRAIT_TYPE_CATEGORY_WEAPON,
    styleCollectibleSubCategory = "Staff",
    styleCollectibleNamePattern = "staff",
  }
  register {
    id = 35,
    name = "Shield",
    traitCategoryId = ITEM_TRAIT_TYPE_CATEGORY_ARMOR,
    styleCollectibleSubCategory = "Shield",
  }
  register {
    id = 36,
    name = "Necklace",
    traitCategoryId = ITEM_TRAIT_TYPE_CATEGORY_JEWELRY,
  }
  register {
    id = 37,
    name = "Ring",
    traitCategoryId = ITEM_TRAIT_TYPE_CATEGORY_JEWELRY,
  }
end

CanICraftThis.EqRecipe:registerAll()

function CanICraftThis.EqRecipe:fromName(name)
  local instance = self.instancesByName[name]
  CanICraftThis.assert(instance ~= nil, "instance ~= nil where name = '" .. name .. "'")
  return instance
end

function CanICraftThis.EqRecipe:fromWritText(writText)
  local writText = string.lower(writText)
  local instance
  for _, instance in pairs(self.instancesByName) do
    if string.find(writText, instance.writTextPattern) then
      return instance
    end
  end
  CanICraftThis.reportUnexpected("writ text did not match any registered EqRecipe: " .. writText)
  return nil
end
