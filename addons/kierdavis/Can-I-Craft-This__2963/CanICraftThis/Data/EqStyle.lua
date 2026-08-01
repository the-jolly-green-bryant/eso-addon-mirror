CanICraftThis.EqStyle = {
  instances = {},
}

local collectibleNamePatternExceptions = {
  ["aldmeri dominion"] = "aldmeri",
  ["daggerfall covenant"] = "daggerfall",
  ["dwemer"] = "dwarven",
  ["ebonheart pact"] = "ebonheart",
}

function CanICraftThis.EqStyle:register(instance)
  CanICraftThis.assert(instance.id ~= nil, "instance.id ~= nil")
  CanICraftThis.assert(instance.name ~= nil, "instance.name ~= nil")
  CanICraftThis.assert(instance.material ~= nil, "instance.material ~= nil")
  instance.material = CanICraftThis.Material:sanitise(instance.material)
  instance.namePattern = CanICraftThis.literalPattern(instance.name)
  instance.writTextPattern = "style: " .. instance.namePattern
  instance.collectibleNamePattern = "^" .. (collectibleNamePatternExceptions[instance.namePattern] or instance.namePattern)
  table.insert(self.instances, instance)
end

function CanICraftThis.EqStyle:registerAll()
  local universalId = GetUniversalStyleId() -- i.e. mimic stone
  local id
  for id = 0, GetHighestItemStyleId() do
    if id ~= universalId then
      local name = GetItemStyleName(id)
      local material = GetItemLinkName(GetItemStyleMaterialLink(id))
      if name ~= nil and name ~= "" and material ~= nil and material ~= "" then
        self:register { id = id, name = name, material = material }
      end
    end
  end
end

CanICraftThis.EqStyle:registerAll()

function CanICraftThis.EqStyle:fromWritText(writText)
  local writText = string.lower(writText)
  local instance
  for _, instance in ipairs(self.instances) do
    if string.find(writText, instance.writTextPattern) then
      return instance
    end
  end
  CanICraftThis.reportUnexpected("writ text did not match any registered EqStyle: " .. writText)
  return nil
end
