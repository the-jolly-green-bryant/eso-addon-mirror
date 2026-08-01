local YADE = {}
YADE = _G["YADE"]
YADE.Menu = {}

local panelData = {
  type = "panel",
  name = "YADE",
  displayName = "Yet Another Dice Emulator",
  author = "tridman",
  version = YADE.version,
  registerForRefresh = true,
  registerForDefaults = true,
}


local optionsTable = {
--[[
Main Section
]]--

  [1] = {
    type = "header",
    name = "Command settings",
  },
  
  [2] = {
        type = "editbox",
        name = "Emote dice command",
        tooltip = "Set the slash command for posting in Emote chat (currently unsupported)",
        getFunc = function() return YADE.savedVars.dicecommand end,
        setFunc = function(val) YADE.savedVars.dicecommand = val end,
        warning = "You have to reload the UI before changes take effect",
        default = "dice",
      },
  
  [3] = {
        type = "editbox",
        name = "Party dice command",
        tooltip = "Set the slash command for posting in Party chat (currently unsupported)",
        getFunc = function() return YADE.savedVars.pdicecommand end,
        setFunc = function(val) YADE.savedVars.pdicecommand = val end,
        warning = "You have to reload the UI before changes take effect",
        default = "pdice",
      },
  
  [4] = {
        type = "editbox",
        name = "Guild 1 dice command",
        tooltip = "Set the slash command for posting in Guild 1 chat (currently unsupported)",
        getFunc = function() return YADE.savedVars.g1dicecommand end,
        setFunc = function(val) YADE.savedVars.g1dicecommand = val end,
        warning = "You have to reload the UI before changes take effect",
        default = "g1dice",
      },
  
  [5] = {
        type = "editbox",
        name = "Guild 2 dice command",
        tooltip = "Set the slash command for posting in Guild 2 chat (currently unsupported)",
        getFunc = function() return YADE.savedVars.g2dicecommand end,
        setFunc = function(val) YADE.savedVars.g2dicecommand = val end,
        warning = "You have to reload the UI before changes take effect",
        default = "g2dice",
      },
  
  [6] = {
        type = "editbox",
        name = "Guild 3 dice command",
        tooltip = "Set the slash command for posting in Guild 3 chat (currently unsupported)",
        getFunc = function() return YADE.savedVars.g3dicecommand end,
        setFunc = function(val) YADE.savedVars.g3dicecommand = val end,
        warning = "You have to reload the UI before changes take effect",
        default = "g3dice",
      },
  
  [7] = {
        type = "editbox",
        name = "Guild 4 dice command",
        tooltip = "Set the slash command for posting in Guild 4 chat (currently unsupported)",
        getFunc = function() return YADE.savedVars.g4dicecommand end,
        setFunc = function(val) YADE.savedVars.g4dicecommand = val end,
        warning = "You have to reload the UI before changes take effect",
        default = "g4dice",
      },
  
  [8] = {
        type = "editbox",
        name = "Guild 5 dice command",
        tooltip = "Set the slash command for posting in Guild 5 chat (currently unsupported)",
        getFunc = function() return YADE.savedVars.g5dicecommand end,
        setFunc = function(val) YADE.savedVars.g5dicecommand = val end,
        warning = "You have to reload the UI before changes take effect",
        default = "g5dice",
      },
  
   
  [9] = {
        type = "editbox",
        name = "Local dice command",
        tooltip = "Set the slash command for posting in Local chat (currently unsupported)",
        getFunc = function() return YADE.savedVars.ldicecommand end,
        setFunc = function(val) YADE.savedVars.ldicecommand = val end,
        warning = "You have to reload the UI before changes take effect",
        default = "ldice",
      },
  
}

function YADE.Menu:CreateOptions()

  local LAM = LibStub("LibAddonMenu-2.0")
  LAM:RegisterAddonPanel(YADE.addonname .."_OptionsPanel", panelData)
  LAM:RegisterOptionControls(YADE.addonname .."_OptionsPanel", optionsTable)

end