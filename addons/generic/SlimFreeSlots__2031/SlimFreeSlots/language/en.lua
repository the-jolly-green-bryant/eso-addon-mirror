local strings = {
  SI_SFS_SETUP_SHOW_INVENTORYBOX = "Show Inventorybox",
  SI_SFS_SETUP_SHOW_ALERTS = "Show alerts on low inventory",
  SI_SFS_SETUP_COLORGOOD = "Plenty of space Color",
  SI_SFS_SETUP_COLORGOOD_DESC = "this is the color that will be used if free inventory slots are beyond the highest threshold",
  SI_SFS_SETUP_THRESHOLD1 = "Warning thresholds",
  SI_SFS_SETUP_THRESHOLD1_DESC = "when free inventory space reaches this number, alert can be shown and textcolor will change",
  SI_SFS_ALERT_FULL = "Inventory full",
  SI_SFS_ALERT_THRESHOLD_REACHED = "%d or less Inventory Slots left",
  SI_SFS_FREE_INV = "Free Slots:",
  SI_SFS_FREE_BANK = "Bank Slots:",
}

for stringId, stringValue in pairs(strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end