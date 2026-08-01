CanICraftThis.Material = {}

function CanICraftThis.Material:sanitise(name)
  -- GetSmithingPatternMaterialItemInfo sometimes returns material names with
  -- "^ns" appended to the end. I don't know what this is, and I don't care.
  name = string.gsub(name, "%^.*", "")
  return string.gsub(name, "%w+", function(word)
    return string.upper(string.sub(word, 1, 1)) .. string.lower(string.sub(word, 2))
  end)
end

local eqMains = {
  ["Rubedite Ingot"] = "craft an? rubedite",
  ["Ancestor Silk"] = "craft an? ancestor silk",
  ["Rubedo Leather"] = "craft an? rubedo leather",
  ["Sanded Ruby Ash"] = "craft an? ruby ash",
  ["Platinum Ounce"] = "craft an? platinum",
}

function CanICraftThis.Material:isEqMain(name)
  return eqMains[self:sanitise(name)] ~= nil
end

function CanICraftThis.Material:eqMainFromWritText(writText)
  local writText = string.lower(writText)
  local material, writTextPattern
  for material, writTextPattern in pairs(eqMains) do
    if string.find(writText, writTextPattern) then
      return material
    end
  end
  CanICraftThis.reportUnexpected("writ text did not match any registered main Material: " .. writText)
  return nil
end
