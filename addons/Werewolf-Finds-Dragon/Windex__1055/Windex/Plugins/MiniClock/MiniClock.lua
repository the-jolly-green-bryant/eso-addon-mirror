windexAddon.buildMenuOptions("MiniClock", "miniClock", "baseAddons")

function windexAddon.pluginLoadFunctions.miniClock()
  if not MiniClockW then return end

  MiniClockW:SetHidden(not windexAddonDB.isDisabled and windexAddonDB.miniClock)
end

windexAddon.pluginToggleFunctions.miniClock = windexAddon.pluginLoadFunctions.miniClock