ShissuLocalization = ShissuLocalization or {}

ShissuLocalization["ShissuTeleporter"] = {  
  TELE   =        "Teleport",
  RND   =         "Zufall",
  REFRESH  =      "Aktualisieren",
  GRP =           "Gruppenführer",
  HOUSE  =        "Hauptwohnsitz",
  LEGEND1  =      "Legende",
  LEGEND2  =      "Freunde",
  LEGEND3 =       "Gruppenmitspieler",

  TITLE =         "Teleporter",
  INFO =          "Info",
  DESC =          "Öffne das Teleporter-Fenster durch eine Tastenkombination deiner Wahl, die du in der |cff7d77STEUERUNG|ceeeeee festgelegt hast. " ..
                  "Einen Zonenteleporter findest du auch auf der Weltmap im rechten Fenster.",

  DESC2 =         "Alternativ stehen dir folgende Chatbefehle zur Verfügung:\n\n"..
                  "|cff7d77/teleport|ceeeeee "..
                  "oder " ..
                  "|cff7d77/tele|ceeeeee - "  ..
                  "Teleporter Fenster ein-/ausblenden" .. 
                  "\n|cff7d77/rndteleport|ceeeeee - " ..
                  "oder " ..
                  "|cff7d77/rndtele|ceeeeee - " ..
                  "Zufallsteleport durchführen",

  DESC3 =         "Teleportiere dich alle |cff7d77x|ceeeeee-Sekunden in eine andere ZONE und poste deine Werbung, die du unten ausgewählt hast. Du musst die Chat-Werbung im Chatfenster nur bestätigen (ENTER).",
  TELE_ADVERT =   "Teleport Werbung",
  TELEIN =        "Teleport in X-Sekunden",
  ADVERTISING =   "Werbung",

  STANDARD =      "Standard Teleport",
  STANDARD_SET =  "Lege zuerst in den Einstellungen einen Standardort fest. Danke.",
  STANDARD_NOPOS ="Keinen passenden Spieler in den Gilden für den Teleport nach: %1 %2 gefunden.",
  STANDARD_DESC = "Teleportiere dich immer zu der hier festgelegten Zone. \nFühre den Teleport mit |cff7d77/standardtele|cffffff oder einer Tastenkombination deiner Wahl durch.",
}

ZO_CreateStringId("SI_BINDING_NAME_SSC_teleportToogle", "Teleporter")
ZO_CreateStringId("SI_BINDING_NAME_SSC_teleportStandard", "Standard Teleport")