windexAddon.buildMenuOptions("Fence Info", "fenceInfo", "baseAddons")

function windexAddon.pluginLoadFunctions.fenceInfo()
  if not FenceInfoIndicator then return end

  FenceInfoIndicator:SetHidden(not windexAddonDB.isDisabled and windexAddonDB.fenceInfo)
end

windexAddon.pluginToggleFunctions.fenceInfo = windexAddon.pluginLoadFunctions.fenceInfo