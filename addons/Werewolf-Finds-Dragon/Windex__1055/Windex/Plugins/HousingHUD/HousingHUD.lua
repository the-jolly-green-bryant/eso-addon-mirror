windexAddon.buildMenuOptions("Housing HUD", "housingHUD", "baseInterface")

function windexAddon.pluginLoadFunctions.housingHUD()
  if ZO_HousingHUDFragmentTopLevel then ZO_HousingHUDFragmentTopLevel:SetHidden(not windexAddonDB.isDisabled and windexAddonDB.housingHUD) end
end

windexAddon.pluginToggleFunctions.housingHUD = windexAddon.pluginLoadFunctions.housingHUD