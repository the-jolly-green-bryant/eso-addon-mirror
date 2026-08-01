local util = AdvancedFilters.util
local function CraftedFilter(isCrafted)
  return function(slot, slotIndex)
    if util.prepareSlot ~= nil then
      if slotIndex ~= nil and type(slot) ~= "table" then
          slot = util.prepareSlot(slot, slotIndex)
      end
    end

    local itemLink = GetItemLink(slot.bagId, slot.slotIndex)
    if itemLink == nil then
      return false
    end

    return IsItemLinkCrafted(itemLink) == isCrafted
  end
end

local CraftedFilters = {
  {name = "Crafted", filterCallback = CraftedFilter(true)},
  {name = "NotCrafted", filterCallback = CraftedFilter(false)}
}

local deStrings = {
  ["Crafted"] = GetString(SI_ITEM_FORMAT_STR_CRAFTED),
  ["NotCrafted"] = "Nicht " .. GetString(SI_ITEM_FORMAT_STR_CRAFTED)
}
local enStrings = {
  ["Crafted"] = GetString(SI_ITEM_FORMAT_STR_CRAFTED),
  ["NotCrafted"] = "Not " .. GetString(SI_ITEM_FORMAT_STR_CRAFTED)
}
local frStrings = {
  ["Crafted"] = GetString(SI_ITEM_FORMAT_STR_CRAFTED),
  ["NotCrafted"] = "Non " .. GetString(SI_ITEM_FORMAT_STR_CRAFTED)
}
local jpStrings = {
  ["Crafted"] = GetString(SI_ITEM_FORMAT_STR_CRAFTED),
  ["NotCrafted"] = "されていません " .. GetString(SI_ITEM_FORMAT_STR_CRAFTED)
}
local ruStrings = {
  ["Crafted"] = GetString(SI_ITEM_FORMAT_STR_CRAFTED),
  ["NotCrafted"] = "Не " .. GetString(SI_ITEM_FORMAT_STR_CRAFTED)
}

local filterInformation = {
  callbackTable = CraftedFilters,
  filterType = ITEMFILTERTYPE_ALL,
  subfilters = {"All"},
  excludeFilterPanels = { LF_CRAFTBAG },
  excludeSubfilters = {
    "Crown",
    "Recipe",
    "Motif",
    "Writ",
    "Trophy",
    "Repair",
    "Container",
    "Trash",
    "Fence",
    "Trophy",
    "Tool",
    "Bait",
    "Siege",
    "SoulGem"
  },
  onlyGroups = {
    "Armor",
    "Weapons",
    "Jewelry",
    "Furnishings",
    "Consumables",
    "Miscellaneous",
    "Junk",
    -- Vanity includes tabards, which are technically crafted
    "Vanity"
  },
  deStrings = deStrings,
  enStrings = enStrings,
  frStrings = frStrings,
  jpStrings = jpStrings,
  ruStrings = ruStrings
}

AdvancedFilters_RegisterFilter(filterInformation)
