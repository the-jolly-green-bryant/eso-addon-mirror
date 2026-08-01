InventorySpaceWarning.Constants = {}
local constants = InventorySpaceWarning.Constants

-- BEGIN: Defaults for settings:
constants.spaceLimit = 10
constants.iconSize = 50

constants.iconsKeys = {
  "ESO",
  "Custom",
}
constants.iconsValues = {
  ESO = "/esoui/art/mainmenu/menubar_inventory_down.dds",
  Custom = "InventorySpaceWarning/res/sack-icon.dds",
}
constants.icon = constants.iconsKeys[1]
-- END

constants.settingPanelName = "InventorySpaceWarningSettingsPanel"