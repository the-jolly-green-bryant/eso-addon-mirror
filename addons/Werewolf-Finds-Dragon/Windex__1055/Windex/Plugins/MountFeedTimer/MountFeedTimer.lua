windexAddon.buildMenuOptions("Mount Feed Timer", "mountFeedTimer", "baseAddons")

function windexAddon.pluginLoadFunctions.mountFeedTimer()
  if not MFT_WD then return end

  MFT_WD:SetHidden(not windexAddonDB.isDisabled and windexAddonDB.mountFeedTimer)
end

windexAddon.pluginToggleFunctions.mountFeedTimer = windexAddon.pluginLoadFunctions.mountFeedTimer