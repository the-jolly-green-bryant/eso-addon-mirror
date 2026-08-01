windexAddon.buildMenuOptions("Target Health Bars", "targetHealthBars",       "baseInterface")
windexAddon.buildMenuOptions("Target Health Bars", "targetHealthBarsCombat", "combatInterface")

function windexAddon.pluginLoadFunctions.targetHealthBars()
  if windexAddon.inCombat then return end

  if UNIT_FRAMES then UNIT_FRAMES:SetFrameHiddenForReason("reticleover", "combatstate", (not windexAddonDB.isDisabled and windexAddonDB.targetHealthBars)) end
end

function windexAddon.pluginCombatFunctions.targetHealthBars()
  if not windexAddonDB.targetHealthBars or not windexAddonDB.targetHealthBarsCombat or windexAddonDB.isDisabled then return end

  if UNIT_FRAMES then UNIT_FRAMES:SetFrameHiddenForReason("reticleover", "combatstate", not windexAddon.inCombat) end
end

windexAddon.pluginToggleFunctions.targetHealthBars = windexAddon.pluginLoadFunctions.targetHealthBars