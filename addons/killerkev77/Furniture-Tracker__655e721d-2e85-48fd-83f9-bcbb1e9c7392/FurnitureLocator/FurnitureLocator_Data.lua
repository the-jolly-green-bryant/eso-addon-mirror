--[[
Furniture Locator - Data Layer

Builds a full list of every furniture item you own, account-wide, with
name, icon, and current location(s) -- for a browsable UI to read from.

CONFIRMED patterns, ported directly from Furniture Finder's
FurnitureFinder_Ownership.lua (already live/working in that addon):
  - Bag/bank/vault scanning via direct slot iteration + IsItemPlaceableFurniture
  - Placed-in-house scanning via GetNextPlacedHousingFurnitureId, seeded
    with nil (NOT 0) and exiting on nil (NOT 0) -- this was the actual bug
    in the earlier standalone test, not a timing/editor-mode issue.
  - GetPlacedFurnitureLink(furnitureId, LINK_STYLE_BRACKETS) for the link,
    NOT GetPlacedHousingFurnitureItemLink (not a real function -- earlier
    test bug).

NOT YET CONFIRMED -- new territory for this addon, Furniture Finder never
needed it since it only augments the game's own tooltip:
  - Item name/icon resolution (GetItemLinkName / GetItemLinkIcon below).
    Wrapped in pcall so a wrong function name/signature shows up as a
    clear error in /flist output rather than a silent failure or a hard
    crash on load.
]]

FurnitureLocator = {}
local this = FurnitureLocator
this.name = "FurnitureLocator" -- unique key for EVENT_MANAGER registrations

-- Must match the manifest's package name exactly (see the note in
-- FurnitureFinder_Ownership.lua about EVENT_ADD_ON_LOADED firing per
-- ADDON, not per file -- same rule applies here).
local ADDON_PACKAGE_NAME = "FurnitureLocator"

-- Caps how many CATEGORY ERROR lines get printed in one session -- if the
-- function names turn out to be wrong, every item would otherwise print
-- one, and a 600-item house already proved that floods/crashes the UI.
local categoryErrorsPrinted = 0
local MAX_CATEGORY_ERRORS_PRINTED = 3

local function PrintCategoryErrorOnce(message)
  if categoryErrorsPrinted < MAX_CATEGORY_ERRORS_PRINTED then
    categoryErrorsPrinted = categoryErrorsPrinted + 1
    d(message)
    if categoryErrorsPrinted == MAX_CATEGORY_ERRORS_PRINTED then
      d("(suppressing further CATEGORY ERROR lines this session)")
    end
  end
end

function this.Initialize()
  this.settings = ZO_SavedVars:NewAccountWide("FurnitureLocatorData", 3, nil, {
    bags = {},     -- [itemId] = count (current character's backpack)
    bank = {},     -- [itemId] = count (current character's bank)
    vault = {},    -- [itemId] = count (account-wide furnishing vault)
    houses = {},   -- [houseId] = { name = "...", items = { [itemId] = count }, lastScanned = timestamp }
    itemInfo = {}, -- [itemId] = { name = "...", icon = "..." }
  })

  EVENT_MANAGER:RegisterForEvent(this.name, EVENT_OPEN_BANK, this.ScanBankAndVault)
  EVENT_MANAGER:RegisterForEvent(this.name, EVENT_CLOSE_BANK, this.ScanBankAndVault)
  EVENT_MANAGER:RegisterForEvent(this.name, EVENT_PLAYER_ACTIVATED, this.ScanCurrentHouseIfOwner)
  EVENT_MANAGER:RegisterForEvent(this.name, EVENT_HOUSING_FURNITURE_PLACED, this.ScanCurrentHouseIfOwner)
  EVENT_MANAGER:RegisterForEvent(this.name, EVENT_HOUSING_FURNITURE_REMOVED, this.ScanCurrentHouseIfOwner)
  EVENT_MANAGER:RegisterForEvent(this.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, this.OnInventoryUpdate)

  -- catch items already in the backpack when the addon loads mid-session
  this.ScanBag(BAG_BACKPACK, "bags")
end

function this.OnInventoryUpdate(_, bagId)
  if bagId == BAG_BACKPACK then
    this.ScanBag(BAG_BACKPACK, "bags")
  end
end

-- Records name/icon/category for an item the first time we see it, so the
-- UI doesn't need to re-resolve item links every render. Name/icon were
-- confirmed working via /flist output. Category is new: confirmed chain is
-- GetItemLinkFurnitureDataId(link) -> GetFurnitureDataInfo(furnitureDataId)
-- -> GetFurnitureCategoryInfo(categoryId), sourced directly from the base
-- game's own housing furniture browser (itemtooltips.lua +
-- furnitureclasses_shared.lua), not guessed.
function this.CacheItemInfo(itemId, link)
  if this.settings.itemInfo[itemId] ~= nil then
    return -- already cached
  end

  local ok, name = pcall(GetItemLinkName, link)
  if not ok then
    d(string.format("ITEMINFO ERROR (name) for item %d: %s", itemId, tostring(name)))
    name = nil
  end

  local okIcon, icon = pcall(GetItemLinkIcon, link)
  if not okIcon then
    d(string.format("ITEMINFO ERROR (icon) for item %d: %s", itemId, tostring(icon)))
    icon = nil
  end

  local category = nil
  local theme = nil
  local okFurnId, furnitureDataId = pcall(GetItemLinkFurnitureDataId, link)
  if not okFurnId then
    PrintCategoryErrorOnce(string.format("CATEGORY ERROR (furnitureDataId) for item %d: %s", itemId, tostring(furnitureDataId)))
  elseif furnitureDataId ~= nil and furnitureDataId ~= 0 then
    local okDataInfo, categoryId, subcategoryId, furnitureTheme = pcall(GetFurnitureDataInfo, furnitureDataId)
    if not okDataInfo then
      PrintCategoryErrorOnce(string.format("CATEGORY ERROR (GetFurnitureDataInfo) for item %d: %s", itemId, tostring(categoryId)))
    else
      if categoryId ~= nil and categoryId ~= 0 then
        local okCatInfo, categoryName = pcall(GetFurnitureCategoryInfo, categoryId)
        if not okCatInfo then
          PrintCategoryErrorOnce(string.format("CATEGORY ERROR (GetFurnitureCategoryInfo) for item %d: %s", itemId, tostring(categoryName)))
        elseif categoryName ~= nil and categoryName ~= "" then
          category = categoryName
        end
      end

      -- Style/theme: same GetFurnitureDataInfo call, third return value.
      -- Confirmed via base game source (ZO_HousingSettingsTheme_SetupDropdown)
      -- that GetString("SI_FURNITURETHEMETYPE", furnitureTheme) resolves it
      -- to a readable name (High Elf, Breton, Nord, etc.).
      if furnitureTheme ~= nil then
        local okThemeInfo, themeName = pcall(GetString, "SI_FURNITURETHEMETYPE", furnitureTheme)
        if not okThemeInfo then
          PrintCategoryErrorOnce(string.format("CATEGORY ERROR (theme GetString) for item %d: %s", itemId, tostring(themeName)))
        elseif themeName ~= nil and themeName ~= "" then
          theme = themeName
        end
      end
    end
  end

  this.settings.itemInfo[itemId] = { name = name, icon = icon, category = category, theme = theme }
end

-- Generic bag scanner. destKey is "bags" or "bank" -- which table in
-- settings to write counts into. Confirmed pattern (IsItemPlaceableFurniture,
-- direct bag/slot iteration) reused from Furniture Finder's vault scan.
function this.ScanBag(bagId, destKey)
  local numSlots = GetBagSize(bagId)
  if numSlots == nil then
    return
  end

  local counts = {}
  for slotIndex = 0, numSlots - 1 do
    if IsItemPlaceableFurniture(bagId, slotIndex) then
      local itemId = GetItemId(bagId, slotIndex)
      local stackSize = GetSlotStackSize(bagId, slotIndex)
      if itemId ~= nil and itemId ~= 0 then
        counts[itemId] = (counts[itemId] or 0) + stackSize
        local link = GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS)
        this.CacheItemInfo(itemId, link)
      end
    end
  end

  this.settings[destKey] = counts
end

function this.ScanBankAndVault()
  this.ScanBag(BAG_BANK, "bank")
  this.ScanBag(BAG_FURNITURE_VAULT, "vault")
end

-- Confirmed working pattern, ported directly from Furniture Finder's
-- FurnitureFinder_Ownership.lua (ScanCurrentHouseIfOwner). This fixes the
-- two bugs found in the earlier standalone test:
--   1. GetPlacedFurnitureLink (not GetPlacedHousingFurnitureItemLink)
--   2. loop seeded with nil, exits on nil (not seeded/exited on 0)
function this.ScanCurrentHouseIfOwner()
  if not IsOwnerOfCurrentHouse() then
    return
  end

  local houseId = GetCurrentZoneHouseId()
  if houseId == nil or houseId == 0 then
    return -- not actually in a house
  end

  local collectibleId = GetCollectibleIdForHouse(houseId)
  local houseName = GetCollectibleName(collectibleId)
  local nickname = GetCollectibleNickname(collectibleId)
  if nickname ~= nil and nickname ~= "" then
    houseName = string.format("%s (%s)", houseName, nickname)
  end

  local counts = {}
  local furnitureId = nil
  repeat
    furnitureId = GetNextPlacedHousingFurnitureId(furnitureId)
    if furnitureId ~= nil then
      local link = GetPlacedFurnitureLink(furnitureId, LINK_STYLE_BRACKETS)
      local itemId = link ~= nil and link ~= "" and GetItemLinkItemId(link) or nil
      if itemId ~= nil and itemId ~= 0 then
        counts[itemId] = (counts[itemId] or 0) + 1
        this.CacheItemInfo(itemId, link)
      end
    end
  until furnitureId == nil

  this.settings.houses[houseId] = {
    name = houseName,
    items = counts,
    lastScanned = GetTimeStamp(),
  }
end

-- Assembles the full owned-furniture list for the UI: one entry per
-- itemId, with name/icon and a breakdown of every place it currently
-- is (or was last seen, for houses -- stale until you revisit).
function this.GetAllOwnedItems()
  local itemIds = {}

  local function collect(sourceTable)
    for itemId, _ in pairs(sourceTable) do
      itemIds[itemId] = true
    end
  end

  collect(this.settings.bags)
  collect(this.settings.bank)
  collect(this.settings.vault)
  for _, house in pairs(this.settings.houses) do
    collect(house.items)
  end

  local results = {}
  for itemId, _ in pairs(itemIds) do
    local info = this.settings.itemInfo[itemId] or {}
    local locations = {}

    local bagCount = this.settings.bags[itemId]
    if bagCount ~= nil and bagCount > 0 then
      table.insert(locations, { type = "Bags", name = "Bags", count = bagCount })
    end

    local bankCount = this.settings.bank[itemId]
    if bankCount ~= nil and bankCount > 0 then
      table.insert(locations, { type = "Bank", name = "Bank", count = bankCount })
    end

    local vaultCount = this.settings.vault[itemId]
    if vaultCount ~= nil and vaultCount > 0 then
      table.insert(locations, { type = "Vault", name = "Furnishing Vault", count = vaultCount })
    end

    for houseId, house in pairs(this.settings.houses) do
      local count = house.items[itemId]
      if count ~= nil and count > 0 then
        table.insert(locations, {
          type = "House",
          name = house.name,
          count = count,
          houseId = houseId,
          lastScanned = house.lastScanned,
        })
      end
    end

    table.insert(results, {
      itemId = itemId,
      name = info.name or ("Item " .. tostring(itemId)),
      icon = info.icon,
      category = info.category or "Uncategorized",
      theme = info.theme or "Unstyled",
      locations = locations,
    })
  end

  -- alphabetical by name, so the list is stable and browsable
  table.sort(results, function(a, b)
    return tostring(a.name) < tostring(b.name)
  end)

  return results
end

local function OnAddOnLoaded(_, addOnName)
  if addOnName ~= ADDON_PACKAGE_NAME then
    return
  end
  this.Initialize()
  EVENT_MANAGER:UnregisterForEvent(this.name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(this.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
