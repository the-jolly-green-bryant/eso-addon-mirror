local default = "Default: "
local on, off = "Enabled", "Disabled"

local lang    = {
  ExecutionPanel                 = "Execution",
  ExecutionThreshold             = "Execution threshold",
  ExecutionThresholdDesc         = "Set your desired execution threshold health percentage. \nSetting to zero will disable alerts.\n" .. default .. BUIE.Defaults.ExecutionThreshold,
  ExecutionIcon                  = "Execution icon",
  ExecutionIconDesc              = "Display execution icon under target health bar during execution phase. \n" .. default .. (BUIE.Defaults.ExecutionIcon and on or off),
  ExecutionTargetHeader          = "Target Health Bar",
  ExecutionChangeTargetColor     = "Change bar",
  ExecutionChangeTargetColorDesc = "Change target's health bar color during execution phase. \n" .. default .. (BUIE.Defaults.ExecutionChangeTargetColor and on or off),
  ExecutionTargetColor           = "Bar color",
  ExecutionTargetColorDesc       = "Target's health bar color during execution phase.\n" .. default .. BUI.TranslateColor(BUIE.Defaults.ExecutionTargetColor),
  ExecutionSoundHeader           = "Sound Notification",
  ExecutionSound                 = "Play sound",
  ExecutionSoundDesc             = "Play sound when execution phase starts.\n" .. default .. (BUIE.Defaults.ExecutionSound and on or off),
  ExecutionSoundType             = "Execution sound",
  ExecutionSoundTypeDesc         = "Sound that will play when execution phase started. \n" .. default .. BUIE.Defaults.ExecutionSoundType,
  ExecutionReset                 = "Reset",
  ExecutionResetDesc             = "Reset to original execution settings?",
}
BUI:JoinTables(BUI.Localization.en, lang)