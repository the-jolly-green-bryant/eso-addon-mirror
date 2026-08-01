local IFTTT = PairsWellWithCheese

local Outcomes = IFTTT.Outcomes
local Collectible = Outcomes.items.Collectible
Collectible.categories = {}
Collectible.subcategories = {}
Collectible.collectibles = {}
Collectible.available = {}
Collectible.previous = {}
Collectible.changes = {}
Collectible.selectedCategory = nil
Collectible.selectedSubcategory = nil
Collectible.selected = {}
Collectible.selections = {}
Collectible.snapshot = {}
DM = ZO_COLLECTIBLE_DATA_MANAGER

local nonUsableCategories = {
  [1] = true, -- Stories
  [2] = true, -- Patrons
  [3] = true, -- Upgrade
  [5] = true, -- Housing
  [6] = true, -- Furnishings
  [7] = true, -- Fragments
  [10] = true, -- Tools
  [11] = true, -- Mounts
  [13] = true, -- Customized Actions
  [15] = true, -- Armor Styles
  [16] = true, -- Weapon Styles
  [19] = true, -- Houses
  [22] = true, -- Chapters
  [25] = true, -- House Banks
  [26] = true, -- Fragments
}


function Collectible:GetCategoryNames()
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

function Collectible:GetSubcategoryNames()
    if not self.selectedCategory then return end
    self.subcategories = {}
    local parts = IFTTT.Split(self.selectedCategory.data, "-")
    local partsCat = IFTTT.Split(parts[2], "_")
    for subcategoryIndex = 1, tonumber(partsCat[1]) do
        local subcategoryName, numCollectibles, unlockedCollectibles = GetCollectibleSubCategoryInfo(parts[1], subcategoryIndex)
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

function Collectible:GetCollectibles()
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
          data          = id.."-"..partsCat[1].."_"..category.."_"..tostring(subcategoryIndex).."-collectible",
          name        = name
      })
    end
  end
  table.sort(self.collectibles, function(a, b)
      return a.name:lower() < b.name:lower()
  end)
  return self.collectibles
end

function Collectible:RefreshCategories()
  self.categories = self:GetCategoryNames()
  self.subcategories = self:GetSubcategoryNames()
  self.collectibles = self:GetCollectibles()
end

function Collectible:PollUsable(activeCollectible, desiredCollectibleId, toggleOn)
  local category, subcategory =  GetCategoryInfoFromCollectibleId(desiredCollectibleId)
  local isPolymorph = (category == 4 and subcategory == 11)
  -- Switch on or off desired
  if (toggleOn or activeCollectible == 0 or isPolymorph) and IsCollectibleUsable(desiredCollectibleId) and IsCollectibleValidForPlayer(desiredCollectibleId) and GetCollectibleCooldownAndDuration(desiredCollectibleId) == 0 then
    UseCollectible(desiredCollectibleId)
    -- Switch on case but did not succeed
    zo_callLater(function()
      if toggleOn and activeCollectible ~= 0 and IsCollectibleUsable(desiredCollectibleId) and not IsCollectibleActive(desiredCollectibleId) then
        zo_callLater(function()
          self:PollUsable(activeCollectible, desiredCollectibleId, toggleOn)
        end, 1000)
      -- Trying to toggle off desired collectible
      elseif not toggleOn and (activeCollectible == 0 or isPolymorph) and IsCollectibleActive(desiredCollectibleId) and IsCollectibleUsable(desiredCollectibleId) and GetCollectibleCooldownAndDuration(desiredCollectibleId) == 0 then
        zo_callLater(function()
          self:PollUsable(activeCollectible, desiredCollectibleId, toggleOn)
        end, 1000)
      end
    end, 1000)
  end
  -- Switch back to previous collectible
  if not toggleOn and activeCollectible ~= 0 and not IsCollectibleActive(activeCollectible) and IsCollectibleUsable(activeCollectible) and IsCollectibleValidForPlayer(activeCollectible) and GetCollectibleCooldownAndDuration(desiredCollectibleId) == 0 then
    UseCollectible(activeCollectible)
    zo_callLater(function()
      if not IsCollectibleActive(activeCollectible) and IsCollectibleUsable(activeCollectible) then
        zo_callLater(function()
          self:PollUsable(activeCollectible, desiredCollectibleId, toggleOn)
        end, 1500)
      end
    end, 1500)
  end
end

function Collectible:DoOutcome(outcome, toggleOn, categoryLock)
  for i = 1, #outcome do
    local outcomeparts = IFTTT.Split(outcome[i].data)
    local categoryparts = IFTTT.Split(outcomeparts[2], "_")
    local desiredCollectibleId = tonumber(outcomeparts[1])
    local categoryId = GetCollectibleCategoryType(desiredCollectibleId)
    if toggleOn then
      local activeCollectible = GetActiveCollectibleByType(categoryId, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
      if activeCollectible ~= desiredCollectibleId and not categoryLock then
        self.snapshot[categoryId] = activeCollectible
      end
    end
    self:PollUsable(self.snapshot[categoryId], desiredCollectibleId, toggleOn)
  end
end