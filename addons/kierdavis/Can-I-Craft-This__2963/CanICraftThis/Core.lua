if CanICraftThis == nil then CanICraftThis = {} end

CanICraftThis.addonName = "CanICraftThis"
CanICraftThis.savedVarsName = CanICraftThis.addonName .. "Vars"
CanICraftThis.authorName = "@always.ada"

function CanICraftThis.reportInfo(message)
  d("[" .. CanICraftThis.addonName .. "] " .. message)
end

function CanICraftThis.reportUnexpected(message)
  error("Unexpected situation!\n" .. message .. "\nThis typically indicates a bug in the " .. CanICraftThis.addonName .. " add-on.")
end

function CanICraftThis.assert(condition, conditionString)
  if not condition then
    CanICraftThis.reportUnexpected("Assertion failed: " .. conditionString)
  end
end

function CanICraftThis.literalPattern(text)
  return string.gsub(string.lower(text), "([^a-zA-Z0-9 ])", "%%%1")
end

-- As of APIVersion 100034, ESO has a bug in its collectibles database (as
-- accessed via GetCollectibleInfo). Two collectible IDs (6117 and 6131) both
-- yield the same name "Honor Guard Jerkin", and no collectible ID yields the
-- name "Honor Guard Jack" despite multiple community wikis implying that it
-- should exist. I've reported this to the developers but it's unlikely I'll
-- get a notification if/when it is fixed.
CanICraftThis.isHonorGuardCollectibleBugPresent = (function()
  local name1 = GetCollectibleInfo(6117)
  local name2 = GetCollectibleInfo(6131)
  return name1 == name2
end)()
