BUIE         = {
  name      = "BanditsUserInterfaceExtended",
  Vars      = {},
  Menu      = {},
  Execution = {},

}
BUI.Extended = BUIE

local function Initialize ()
  BUIE.Vars.Initialize()
  BUIE.Menu.Initialize()
  BUIE.Execution.Initialize()
end

CALLBACK_MANAGER:RegisterCallback("BUI_Ready", Initialize)