local IFTTT = PairsWellWithCheese

local Triggers = IFTTT.Triggers
local TriggerCollectibles = Triggers.items.TriggerCollectibles
TriggerCollectibles.categories = {}
TriggerCollectibles.subcategories = {}
TriggerCollectibles.collectibles = {}
TriggerCollectibles.available = {}
TriggerCollectibles.previous = {}
TriggerCollectibles.changes = {}
TriggerCollectibles.selectedCategory = nil
TriggerCollectibles.selectedSubcategory = nil
TriggerCollectibles.selections = {}
TriggerCollectibles.selected = {}
TriggerCollectibles.activeLock = {}
TriggerCollectibles.categoryLock = {}
TriggerCollectibles.existingCooldown = 0
TriggerCollectibles.timeRemaining = {}
TriggerCollectibles.snapshot = {}
local EM = EVENT_MANAGER

local nonUsableCategories = {
  [1] = true, -- Stories
  [2] = true, -- Patrons
  [3] = true, -- Upgrade
  [5] = true, -- Housing
  [6] = true, -- Furnishings
  [7] = true, -- Fragments
  [10] = true, -- Tools
  [11] = true, -- Mounts
  [15] = true, -- Armor Styles
  [16] = true, -- Weapon Styles
  [19] = true, -- Houses
  [22] = true, -- Chapters
  [25] = true, -- House Banks
  [26] = true, -- Fragments
}

local nonUsableSubcategories = {
  [13] = { -- Customized Actions
    [3] = true, -- Recalling
  },
}

function TriggerCollectibles:GetCategoryNames()
    for categoryIndex = 1, GetNumCollectibleCategories() do
        local categoryName, numSubcategories, numCollectibles, unlockedCollectibles, totalCollectibles = GetCollectibleCategoryInfo(categoryIndex)
        if not nonUsableCategories[categoryIndex] and unlockedCollectibles > 0 then
          table.insert(self.categories, {name=categoryName, data=tostring(categoryIndex).."-"..tostring(numSubcategories).."_"..tostring(totalCollectibles).."-category"} )
        end
    end
    table.sort(self.categories, function(a, b)
        return a.name:lower() < b.name:lower()
    end)
    self.selectedCategory = self.categories[1]
    return self.categories
end

function TriggerCollectibles:GetSubcategoryNames()
    self.subcategories = {}
    if not self.selectedCategory.data then return end
    local parts = IFTTT.Split(self.selectedCategory.data, "-")
    local partsCat = IFTTT.Split(parts[2], "_")
    for subcategoryIndex = 1, tonumber(partsCat[1]) do
        local subcategoryName, numCollectibles, unlockedCollectibles, totalCollectibles = GetCollectibleSubCategoryInfo(parts[1], subcategoryIndex)
        if totalCollectibles > 0 and unlockedCollectibles > 0 and not ( nonUsableSubcategories[tonumber(parts[1])] and nonUsableSubcategories[tonumber(parts[1])][subcategoryIndex] ) then
          table.insert(self.subcategories, {name=subcategoryName, data=tostring(subcategoryIndex).."-"..tostring(totalCollectibles).."-subcategory"} )
        end
    end
    table.sort(self.subcategories, function(a, b)
        return a.name:lower() < b.name:lower()
    end)
    self.selectedSubcategory = self.subcategories[1]
    return self.subcategories
end

function TriggerCollectibles:GetCollectibles()
  self.collectibles = {}
  local parts = IFTTT.Split(self.selectedCategory.data, "-")
  local partsCat = IFTTT.Split(parts[2], "_")
  local subcategoryIndex
  local numCollectibles = tonumber(partsCat[2])
  if self.selectedSubcategory and self.selectedSubcategory.data then
    local subparts = IFTTT.Split(self.selectedSubcategory.data, "-")
    subcategoryIndex = tonumber(subparts[1])
    numCollectibles = tonumber(subparts[2])
  end
  for collectibleIndex = 1, numCollectibles do
    local id = GetCollectibleId(tonumber(parts[1]), subcategoryIndex, collectibleIndex)
    local category = GetCategoryInfoFromCollectibleId(id)
    local name, description, iconFile, _, unlocked, _, purchasable, active = GetCollectibleInfo(id)

    if unlocked then
      table.insert(self.collectibles, {
          data          = id.."-"..partsCat[1].."_"..category.."_"..tostring(subcategoryIndex).."-triggerCollectibles",
          name        = name
      })
    end
  end
  table.sort(self.collectibles, function(a, b)
      return a.name:lower() < b.name:lower()
  end)
  return self.collectibles
end

function TriggerCollectibles:Refresh()
  self.categories = self:GetCategoryNames()
  self.subcategories = self:GetSubcategoryNames()
  self.collectibles = self:GetCollectibles()
end

function TriggerCollectibles:removeCallbacks(links)
  EM:UnregisterForEvent(IFTTT.Name.."TriggerCollectibleCallback", EVENT_COLLECTIBLE_UPDATED)
end

function TriggerCollectibles:callbacks(links)
  EM:UnregisterForEvent(IFTTT.Name.."TriggerCollectibleCallback", EVENT_COLLECTIBLE_UPDATED)
  EM:RegisterForEvent(IFTTT.Name.."TriggerCollectibleCallback", EVENT_COLLECTIBLE_UPDATED, function(_, collectibleId) 
    local callbackTable = {}
    self.categoryLock = {}
    local slotKey = "placeholder"
    local toggleOn = false
    zo_callLater(function()
      for key, link in pairs(links) do
        local triggerparts = IFTTT.Split(link.trigger.data)
        local outcomeparts = IFTTT.Split(link.outcome.data)
        local categoryParts = IFTTT.Split(outcomeparts[2], "_")
        local desiredCollectibleId = tonumber(triggerparts[1])
        local type = IFTTT.toCapitalized(outcomeparts[3])
        link.trigger.active = link.trigger.active or {}
        toggleOn = IsCollectibleActive(desiredCollectibleId)
        local categoryType = GetCollectibleCategoryType(tonumber(outcomeparts[1]))
        if collectibleId == tonumber(desiredCollectibleId) then
          table.insert(callbackTable, { type = IFTTT.toCapitalized(outcomeparts[3]), link = link.outcome, categoryId = categoryType, categoryIdBackup = tonumber(categoryParts[1]), desiredCollectibleId = desiredCollectibleId})
        end
      end
      for k, obj in pairs(callbackTable) do
          zo_callLater(function()
            if toggleOn then
              local activeCollectible = GetActiveCollectibleByType(obj.categoryId, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
              if activeCollectible ~= obj.desiredCollectibleId then
                local categoryId = obj.categoryId
                IFTTT.Outcomes.items[obj.type].snapshot[categoryId] = activeCollectible
              end
            end
            IFTTT.Outcomes.items[obj.type]:DoOutcome({obj.link}, toggleOn, true)
          end, 500)
      end
    end, 1500)
  end)
end
