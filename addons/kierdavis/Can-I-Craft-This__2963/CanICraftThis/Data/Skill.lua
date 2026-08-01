CanICraftThis.Skill = {
  instancesById = {},
}

function CanICraftThis.Skill:register(instance)
  CanICraftThis.assert(instance.id ~= nil, "instance.id ~= nil")
  CanICraftThis.assert(instance.name ~= nil, "instance.name ~= nil")
  CanICraftThis.assert(instance.writNamePattern ~= nil, "instance.writNamePattern ~= nil")
  if instance.equipmentInfo ~= nil then
    CanICraftThis.assert(instance.equipmentInfo.passiveAbilityId ~= nil, "instance.equipmentInfo.passiveAbilityId ~= nil")
    CanICraftThis.assert(instance.equipmentInfo.passiveAbilityName ~= nil, "instance.equipmentInfo.passiveAbilityName ~= nil")
    CanICraftThis.assert(instance.equipmentInfo.usesStyle ~= nil, "instance.equipmentInfo.usesStyle ~= nil")
  end
  self.instancesById[instance.id] = instance
end

function CanICraftThis.Skill:registerAll()
  self:register {
    id = CRAFTING_TYPE_ALCHEMY,
    name = "Alchemy",
    writNamePattern = "alchemy",
  }
  self:register {
    id = CRAFTING_TYPE_BLACKSMITHING,
    name = "Blacksmithing",
    writNamePattern = "blacksmithing",
    equipmentInfo = {
      passiveAbilityId = NON_COMBAT_BONUS_BLACKSMITHING_LEVEL,
      passiveAbilityName = "Metalworking",
      usesStyle = true,
    },
  }
  self:register {
    id = CRAFTING_TYPE_CLOTHIER,
    name = "Clothing",
    writNamePattern = "clothier",
    equipmentInfo = {
      passiveAbilityId = NON_COMBAT_BONUS_CLOTHIER_LEVEL,
      passiveAbilityName = "Tailoring",
      usesStyle = true,
    },
  }
  self:register {
    id = CRAFTING_TYPE_ENCHANTING,
    name = "Enchanting",
    writNamePattern = "enchanting",
  }
  self:register {
    id = CRAFTING_TYPE_JEWELRYCRAFTING,
    name = "Jewelry Crafting",
    writNamePattern = "jewelry crafter",
    equipmentInfo = {
      passiveAbilityId = NON_COMBAT_BONUS_JEWELRYCRAFTING_LEVEL,
      passiveAbilityName = "Engraver",
      usesStyle = false,
    },
  }
  self:register {
    id = CRAFTING_TYPE_PROVISIONING,
    name = "Provisioning",
    writNamePattern = "provisioning",
  }
  self:register {
    id = CRAFTING_TYPE_WOODWORKING,
    name = "Woodworking",
    writNamePattern = "woodworking",
    equipmentInfo = {
      passiveAbilityId = NON_COMBAT_BONUS_WOODWORKING_LEVEL,
      passiveAbilityName = "Woodworking",
      usesStyle = true,
    },
  }
end

CanICraftThis.Skill:registerAll()

function CanICraftThis.Skill:fromId(id)
  local instance = self.instancesById[id]
  CanICraftThis.assert(instance ~= nil, "instance ~= nil where id = " .. tostring(id))
  return instance
end

function CanICraftThis.Skill:tryFromWritName(writName)
  local writName = string.lower(writName)
  local instance
  for _, instance in pairs(self.instancesById) do
    if string.find(writName, instance.writNamePattern) then
      return instance
    end
  end
  return nil
end
