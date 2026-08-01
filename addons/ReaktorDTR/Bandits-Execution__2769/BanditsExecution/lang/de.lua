local default = "Standard: "
local on, off = "Ein", "Aus"

local lang    = {
  ExecutionPanel                 = "Exekution",
  ExecutionThreshold             = "Exekution schwelle",
  ExecutionThresholdDesc         = "Setze auf Sie den gewünschten Prozentsatz für den Exekutieren Schwellenwert fest. \nSetzte die Grenze auf Null um diese Funktion zu deaktivieren.\n" .. default .. BUIE.Defaults.ExecutionThreshold,
  ExecutionIcon                  = "Exekution zeichen",
  ExecutionIconDesc              = "Zeigen Sie während der Exekution-Phase die Exekution zeichen unter der Zielzustandsleiste an.  \n" .. default .. (BUIE.Defaults.ExecutionIcon and on or off),
  ExecutionTargetHeader          = "Ziel Gesundheitsleiste",
  ExecutionChangeTargetColor     = "Balken wechseln",
  ExecutionChangeTargetColorDesc = "Ändern Sie die Farbe des Gesundheitsbalkens des Ziels während die Exekution-Phase. \n" .. default .. (BUIE.Defaults.ExecutionChangeTargetColor and on or off),
  ExecutionTargetColor           = "Balkenfarbe",
  ExecutionTargetColorDesc       = "Farbe des Gesundheitsbalkens des Ziels während die Exekution-Phase.\n" .. default .. BUI.TranslateColor(BUIE.Defaults.ExecutionTargetColor),
  ExecutionSoundHeader           = "Akustische Benachrichtigung",
  ExecutionSound                 = "Ton abspielen",
  ExecutionSoundDesc             = "Ton abspielen, wenn die Exekution-Phase beginnt.\n" .. default .. (BUIE.Defaults.ExecutionSound and on or off),
  ExecutionSoundType             = "Exekution sound",
  ExecutionSoundTypeDesc         = "Sound, der zu Beginn die Exekution-Phase abgespielt wird. \n" .. default .. BUIE.Defaults.ExecutionSoundType,
  ExecutionReset                 = "Zurücksetzen",
  ExecutionResetDesc             = "Auf die ursprünglichen Exekution Einstellungen zurücksetzen?",
}
BUI:JoinTables(BUI.Localization.de, lang)