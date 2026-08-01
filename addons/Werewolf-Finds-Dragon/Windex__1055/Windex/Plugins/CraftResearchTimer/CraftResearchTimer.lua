windexAddon.buildMenuOptions("Craft Research Timer", "craftResearchTimer", "baseAddons")

function windexAddon.pluginLoadFunctions.craftResearchTimer()
  if not CRT_CRAFT_TLW then return end

  CRT_GRID_TLW:SetHidden(not windexAddonDB.isDisabled and windexAddonDB.craftResearchTimer)
end

windexAddon.pluginToggleFunctions.craftResearchTimer = windexAddon.pluginLoadFunctions.craftResearchTimer