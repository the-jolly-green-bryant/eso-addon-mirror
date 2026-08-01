windexAddon.buildMenuOptions("Smart Bags", "smartBags", "baseAddons")

function windexAddon.pluginLoadFunctions.smartBags()
  if not SmartBagsUI then return end

  if not windexAddon.noSmartBagsToggle then
    SmartBagsUI:SetHidden(windexAddonDB.smartBags and not windexAddonDB.isDisabled)
  end
end

windexAddon.pluginToggleFunctions.smartBags = windexAddon.pluginLoadFunctions.smartBags