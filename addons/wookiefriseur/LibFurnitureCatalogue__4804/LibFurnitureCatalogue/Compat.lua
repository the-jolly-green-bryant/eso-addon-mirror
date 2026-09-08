-- Compatibility for other AddOns.
-- TODO: delete with next major FC update
-- documenting in case we have to use it a bit longer

local LFC = LibFurnitureCatalogue

local this = {}
LFC.Internal.Compat = this

local src = LFC.Internal.Constants.ItemSources

--- Old, coarse, source types
this.SOURCE_PARENT = {
  [src.DUNGEON] = src.DROP,
  [src.HARVEST] = src.DROP,
  [src.CHEST] = src.DROP,
  [src.QUEST] = src.DROP,
  [src.PICKPOCKET] = src.JUSTICE,
  [src.CONTAINER] = src.JUSTICE,
}

local SOURCE_PARENT = this.SOURCE_PARENT

--
-- Black magic bitmask technology to save some memory
--
-- Subtables have 64-byte overhead, and we would be putting that into most of the 8500+ records, which wastes memory.
--
-- Only the two values in SOURCE_PARENT above can ever be injected, so one integer is enough to represent them all:
--
-- Bit positions come from ItemSources, numbered in declaration order. Inserting a source in the middle renumbers everything below it.
-- This mask is built during the scan, don't store it
local function bitFor(source)
  return 2 ^ (source - 1)
end

---Is this source in `sources` only because compatibility put it there?
---@param mask integer|nil the row's compatSources
---@param source integer
---@return boolean injected
function this.IsInjected(mask, source)
  if not mask or mask == 0 then
    return false
  end
  local bit = bitFor(source)
  return mask % (bit + bit) >= bit
end
local isInjected = this.IsInjected

---Add source each fine-grained value was split from (mostly for tests)
---@param sources table<integer, boolean> mutated in place
---@param injected integer|nil mask of what earlier passes added here
---@return integer injected the mask including whatever this pass added
function this.CloseOverAncestors(sources, injected)
  injected = injected or 0
  for s in pairs(sources) do
    local parent = SOURCE_PARENT[s]
    -- two fine-grained sources can share a parent, so the mask has to be checked: sources[parent] is only written in the loop below
    if parent and not sources[parent] and not isInjected(injected, parent) then
      injected = injected + bitFor(parent)
    end
  end
  for _, parent in pairs(SOURCE_PARENT) do
    if isInjected(injected, parent) then
      sources[parent] = true
    end
  end
  return injected
end

---Mirror each fine-grained source's rows for AddOns reading data tables directly.. ha, they won't even notice!
---@param dataFile table [version][source][itemId]
---@param mirrorRegistry table bucket -> true, or a set of the item ids already scanned
function this.MirrorAncestorBuckets(dataFile, mirrorRegistry)
  for _, versionData in pairs(dataFile) do
    local pending = {}
    for source, items in pairs(versionData) do
      local parent = SOURCE_PARENT[source]
      if parent then
        local target = pending[parent] or {}
        pending[parent] = target
        for itemId, entry in pairs(items) do
          target[itemId] = entry
        end
      end
    end

    for parent, added in pairs(pending) do
      local existing = versionData[parent]
      local merged, covered = {}, true
      if existing then
        local prior = mirrorRegistry[existing]
        covered = {}
        for itemId, entry in pairs(existing) do
          merged[itemId] = entry
          if prior == true or (prior and prior[itemId]) then
            covered[itemId] = true
          end
        end
      end
      for itemId, entry in pairs(added) do
        merged[itemId] = entry
        if covered ~= true then
          covered[itemId] = true
        end
      end
      versionData[parent] = merged
      mirrorRegistry[merged] = covered
    end
  end
end
