windexAddon.buildMenuOptions("Weapon Charge Alert", "weaponChargeAlert", "baseAddons")

function windexAddon.pluginLoadFunctions.weaponChargeAlert()
  if not WeaponChargeAlert_Window then return end

  windexAddon.weaponChargeAlertDefault = windexAddon.weaponChargeAlertDefault or (WeaponChargeAlertSettings and WeaponChargeAlertSettings:GetAlpha() or 1)

  WeaponChargeAlert_Window:SetAlpha((not windexAddonDB.isDisabled and windexAddonDB.weaponChargeAlert) and 0 or windexAddon.weaponChargeAlertDefault)
end

windexAddon.pluginToggleFunctions.weaponChargeAlert = windexAddon.pluginLoadFunctions.weaponChargeAlert
windexAddon.pluginFocusFunctions.weaponChargeAlert  = windexAddon.pluginLoadFunctions.weaponChargeAlert