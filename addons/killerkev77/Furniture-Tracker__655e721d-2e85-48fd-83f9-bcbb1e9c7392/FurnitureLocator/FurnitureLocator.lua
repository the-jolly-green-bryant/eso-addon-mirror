--[[
Furniture Locator - Main

For now, this just wires up a debug command so we can verify the data
layer (FurnitureLocator_Data.lua) is correct before building the
gamepad-navigable list UI on top of it. No UI yet.
]]

local ADDON_PACKAGE_NAME = "FurnitureLocator"

-- Prints one page of the owned-furniture list, startIndex..startIndex+count-1.
-- Kept separate from the "how many total" summary so large collections
-- (600+ items) never get dumped to chat in one unthrottled burst -- that's
-- almost certainly what crashed the UI last time, not the data itself.
local function DebugPrintPage(startIndex, count)
  local items = FurnitureLocator.GetAllOwnedItems()
  local endIndex = math.min(startIndex + count - 1, #items)

  d(string.format("=== Furniture Locator: items %d-%d of %d ===", startIndex, endIndex, #items))
  for i = startIndex, endIndex do
    local item = items[i]
    if item == nil then
      break
    end
    local locStrs = {}
    for _, loc in ipairs(item.locations) do
      table.insert(locStrs, string.format("%d in %s", loc.count, loc.name))
    end
    d(string.format(
      "[%d] %s | icon=%s | %s",
      item.itemId,
      tostring(item.name),
      tostring(item.icon),
      table.concat(locStrs, ", ")
    ))
  end

  if endIndex < #items then
    d(string.format("... %d more. Use /flist %d to see the next page.", #items - endIndex, endIndex + 1))
  end
end

-- /flist            -> just the total count, no per-item spam
-- /flist <start>     -> 10 items starting at that index
local function DebugCommand(args)
  local items = FurnitureLocator.GetAllOwnedItems()
  local startIndex = tonumber(args)

  if startIndex == nil then
    d(string.format("Furniture Locator: %d owned items total. Use /flist 1 to page through them.", #items))
    return
  end

  DebugPrintPage(startIndex, 10)
end

local function OnAddOnLoaded(_, addOnName)
  if addOnName ~= ADDON_PACKAGE_NAME then
    return
  end
  EVENT_MANAGER:UnregisterForEvent("FurnitureLocatorMain", EVENT_ADD_ON_LOADED)

  SLASH_COMMANDS["/flist"] = DebugCommand

  d("Furniture Locator loaded. Type /flist to dump your full owned furniture list to chat.")
end

EVENT_MANAGER:RegisterForEvent("FurnitureLocatorMain", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
