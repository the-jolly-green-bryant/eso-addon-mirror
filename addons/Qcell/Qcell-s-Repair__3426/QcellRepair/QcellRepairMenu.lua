QR = QR or {}
local QR = QR
QR.Menu = {}

function QR.Menu.AddonMenu()
  local menuOptions = {
    type         = "panel",
    name         = "Qcell's Repair",
    displayName  = "|cFF4500Qcell's Repair|r",
    author       = QR.author,
    version      = QR.version,
    registerForRefresh  = true,
    registerForDefaults = true,
  }
  local dataTable = {
    {
      type = "description",
      text = "Simple light-weight repair addon, it only does two things. It won't crash on you.",
    },
    {
      type = "divider",
    },
    {
      type = "description",
      text = "1) You can type /qr or /qrepair to repair all your worn gear with Grand Repair Kits.",
    },
    {
      type = "description",
      text = "2) Auto-repairs everything you carry with gold when you interact with a merchant.",
    },
    {
      type = "description",
      text = "Bind to a key on [Controlls > Addon Keybinds].",
    },
    {
      type    = "button",
      name    = "REPAIR ALL",
      func = function() QR.RepairItemsWithKits() end,
    },
    {
      type = "divider",
    },
    {
      type    = "checkbox",
      name    = "Repair all at merchants",
      default = true,
      getFunc = function() return QR.savedVariables.merchantRepair end,
      setFunc = function( newValue ) QR.savedVariables.merchantRepair = newValue end,
    },
    {
      type = "divider",
    },
    {
      type = "header",
      name = "Repair Kit Saver",
      reference = "QcellRepairMenuKitSaver"
    },
    {
      type = "description",
      text = "Recommended: leave this OFF.",
    },
    {
      type    = "checkbox",
      name    = "Repair Kit saver: DO NOT repair below THRESHOLD",
      default = true,
      getFunc = function() return QR.savedVariables.repairKitSaver end,
      setFunc = function( newValue ) QR.savedVariables.repairKitSaver = newValue end,
    },
    {
      type    = "slider",
      name    = "Do not repair worn below this % durablity",
      min = 10,
      max = 100,
      step = 1,
      decimals = 0,
      tooltip = "100 means always repair, 10 only when really broken. Merchant interaction still always repairs everything.",
      default = QR.savedVariables.repairKitThreshold,
      disabled = function() return not QR.savedVariables.repairKitSaver end,
      getFunc = function() return QR.savedVariables.repairKitThreshold end,
      setFunc = function(newValue) QR.savedVariables.repairKitThreshold = newValue end,
    },
  }

  LAM = LibAddonMenu2
  LAM:RegisterAddonPanel(QR.name .. "Options", menuOptions)
  LAM:RegisterOptionControls(QR.name .. "Options", dataTable)
end
