local LTF = LibTextFormat

function LTF:ListFilters()
  return self:GetVar("filters")
end

function LTF:RegisterFilter(name, fn)
  local filters = self:ListFilters() or {}
  filters[name] = fn
  self:SaveToVars("filters", filters)
end

function LTF:RegisterFiltersBulk(object, version, selectiveOverrides)
  version = version or self.defaultVersion
  for key, filter in pairs(object[version]) do
    self:RegisterFilter(key, filter)
  end
  for ver, overridden in pairs(selectiveOverrides) do
   if object[ver] ~= nil then
    self:RegisterFilter(overridden, object[ver])
   end
  end
end

function LTF:GetFilter(filterName)
  return self:GetVarByValue("filters", filterName)
end
