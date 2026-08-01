--Name Space
PairsWellWithCheese = {}

local IFTTT = PairsWellWithCheese

--Basic Info
IFTTT.Name = "PairsWellWithCheese"

local EM = EVENT_MANAGER

IFTTT.Default = {
  links = {}

}

function IFTTT.DiffTables(old, new, path)
    if not old then return end
    if not new then return end
    path = path or ""
    local changes = {}

    -- Check for removed or changed keys
    for k, oldVal in pairs(old) do
        local newVal = new[k]
        local keyPath = path .. (path == "" and "" or ".") .. tostring(k)

        if newVal == nil then
            table.insert(changes, { type = "removed", path = keyPath, oldValue = oldVal })
        elseif type(oldVal) == "table" and type(newVal) == "table" then
            local nested = DiffTables(oldVal, newVal, keyPath)
            for _, change in ipairs(nested) do
                table.insert(changes, change)
            end
        elseif oldVal ~= newVal then
            table.insert(changes, { type = "changed", path = keyPath, oldValue = oldVal, newValue = newVal })
        end
    end

    -- Check for added keys
    for k, newVal in pairs(new) do
        if old[k] == nil then
            local keyPath = path .. (path == "" and "" or ".") .. tostring(k)
            table.insert(changes, { type = "added", path = keyPath, newValue = newVal })
        end
    end

    return changes
end

function IFTTT.Split(search, delim)
  if not search then
    d("IFTTT: Tried to split nil value")
    return
  end
  local parts = {}
  local start = 1
  delim = delim or "-"

  while true do
      local i, j = search:find(delim, start, true) -- true = plain match
      if not i then
          table.insert(parts, search:sub(start))
          break
      end

      table.insert(parts, search:sub(start, i - 1))
      start = j + 1
  end
  return parts
end

function IFTTT.toCapitalized(s)
  return s:sub(1,1):upper() .. s:sub(2)
end

function IFTTT.isValueInTable(table, element)
  for _, v in ipairs(table) do
    if element == v then
      return true
    end
  end
  return false
end
