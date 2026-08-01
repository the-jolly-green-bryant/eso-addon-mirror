DVDInventoryWatcher = {}
local watcher = DVDInventoryWatcher

function watcher.onSlotAdded(bag, sid, fn)
  local function cb(bagId, slotId, itemData)
    if bagId == bag and Id64ToString(itemData.uniqueId) == sid then
      SHARED_INVENTORY:UnregisterCallback("SlotAdded", cb)
      fn(slotId)
    end
  end
  SHARED_INVENTORY:RegisterCallback("SlotAdded", cb)
end

function watcher.onSlotUpdated(bag, sid, fn)
  local function cb(bagId, slotId, itemData)
    if bagId == bag and Id64ToString(itemData.uniqueId) == sid then
      SHARED_INVENTORY:UnregisterCallback("SlotUpdated", cb)
      fn(slotId)
    end
  end
  SHARED_INVENTORY:RegisterCallback("SlotUpdated", cb)
end