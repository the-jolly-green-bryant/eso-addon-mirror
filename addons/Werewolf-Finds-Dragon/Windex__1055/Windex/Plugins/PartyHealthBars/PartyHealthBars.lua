windexAddon.buildMenuOptions("Party Health Bars", "partyHealthBars",       "baseInterface")
windexAddon.buildMenuOptions("Party Health Bars", "partyHealthBarsCombat", "combatInterface")

function windexAddon.pluginLoadFunctions.partyHealthBars()
  if ZO_UnitFramesGroups then ZO_UnitFramesGroups:SetHidden(not windexAddonDB.isDisabled and windexAddonDB.partyHealthBars) end
end

function windexAddon.pluginCombatFunctions.partyHealthBars()
  if not windexAddonDB.partyHealthBars or not windexAddonDB.partyHealthBarsCombat or windexAddonDB.isDisabled then return end

  if ZO_UnitFramesGroups then ZO_UnitFramesGroups:SetHidden(not windexAddon.inCombat) end
end

windexAddon.pluginToggleFunctions.partyHealthBars = windexAddon.pluginLoadFunctions.partyHealthBars