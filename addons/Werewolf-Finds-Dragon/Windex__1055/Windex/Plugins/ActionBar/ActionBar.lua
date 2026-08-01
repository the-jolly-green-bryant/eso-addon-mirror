windexAddon.buildMenuOptions("Action Bar", "actionBar",       "baseInterface")
windexAddon.buildMenuOptions("Action Bar", "actionBarCombat", "combatInterface")

function windexAddon.pluginCombatFunctions.actionBar()
  if not windexAddonDB.actionBar or not windexAddonDB.actionBarCombat then return end

  if ZO_ActionBar1 then ZO_ActionBar1:SetHidden(not windexAddon.inCombat) end
end

function windexAddon.pluginReticleFunctions.actionBar()
  if ZO_Skills:IsHidden() == false or not windexAddonDB.actionBar or windexAddon.inCombat then return end

  if ZO_ActionBar1 then ZO_ActionBar1:SetHidden(not windexAddonDB.isDisabled) end
end 