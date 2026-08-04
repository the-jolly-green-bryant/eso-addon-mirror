local IFTTT = PairsWellWithCheese

local Triggers = IFTTT.Triggers
local TriggerMounts = Triggers.items.TriggerMounts
TriggerMounts.categories = {}
TriggerMounts.subcategories = {}
TriggerMounts.collectibles = {}
TriggerMounts.available = {}
TriggerMounts.previous = {}
TriggerMounts.changes = {}
TriggerMounts.selectedSubcategory = nil
TriggerMounts.selections = {}
TriggerMounts.selected = {}
TriggerMounts.activeLock = {}
TriggerMounts.categoryLock = {}
TriggerMounts.existingCooldown = 0
TriggerMounts.timeRemaining = {}
TriggerMounts.snapshot = {}
local EM = EVENT_MANAGER

local mountCategory = 11

function TriggerMounts:GetSubcategoryNames()
    local categoryName, numSubcategories = GetCollectibleCategoryInfo(mountCategory)
    for subcategoryIndex = 1, numSubcategories do
        local subcategoryName, numCollectibles, unlockedCollectibles = GetCollectibleSubCategoryInfo(mountCategory, subcategoryIndex)
        if unlockedCollectibles > 0 then
          table.insert(self.subcategories, {name=subcategoryName, data=tostring(subcategoryIndex).."-"..tostring(numCollectibles).."-subcategory"} )
        end
    end
    table.sort(self.subcategories, function(a, b)
        return a.name:lower() < b.name:lower()
    end)
    self.selectedSubcategory = self.subcategories[1]
    return self.subcategories
end

function TriggerMounts:GetCollectibles()
  if not self.selectedSubcategory.data then return end
  self.collectibles = {}
  local subparts = IFTTT.Split(self.selectedSubcategory.data, "-")
  for collectibleIndex = 1, tonumber(subparts[2]) do
    local id = GetCollectibleId(mountCategory, subparts[1], collectibleIndex)
    local category = GetCollectibleCategoryType(id)
    local name, description, iconFile, _, unlocked, _, purchasable, active = GetCollectibleInfo(id)
    if unlocked then
        table.insert(self.collectibles, {
            data          = id.."-"..mountCategory.."_"..category.."_"..subparts[1].."-triggerMounts",
            name        = name
        })
    end
  end
  table.sort(self.collectibles, function(a, b)
      return a.name:lower() < b.name:lower()
  end)
  return self.collectibles
end

function TriggerMounts:Refresh()
  self.subcategories = self:GetSubcategoryNames()
  self.collectibles = self:GetCollectibles()
end

function TriggerMounts:removeCallbacks(links)
  EM:UnregisterForEvent(IFTTT.Name.."TriggerMountCallback", EVENT_MOUNTED_STATE_CHANGED)
end

function TriggerMounts:callbacks(links)
  EM:UnregisterForEvent(IFTTT.Name.."TriggerMountCallback", EVENT_MOUNTED_STATE_CHANGED)
  EM:RegisterForEvent(IFTTT.Name.."TriggerMountCallback", EVENT_MOUNTED_STATE_CHANGED, function(_, mounted) 
    local callbackTable = {}
    local slotKey = "placeholder"
    for key, link in pairs(links) do
      local triggerparts = IFTTT.Split(link.trigger.data)
      local outcomeparts = IFTTT.Split(link.outcome.data)
      local desiredCollectibleId = tonumber(triggerparts[1])
      local categoryParts = IFTTT.Split(outcomeparts[2], "_")
      local category = tonumber(categoryParts[1])
      link.trigger.active = link.trigger.active or {}
      slotKey = triggerparts[1].."-"..triggerparts[2].."-"..outcomeparts[1]
      if IsCollectibleActive(desiredCollectibleId) then
        table.insert(callbackTable,{ type = IFTTT.toCapitalized(outcomeparts[3]), link = link.outcome})
      end
    end
    for k, obj in ipairs(callbackTable) do -- obj is only getting one
      zo_callLater(function()
        IFTTT.Outcomes.items[obj.type]:DoOutcome({obj.link}, mounted, false)
      end, 1000)
    end
  end)
end
