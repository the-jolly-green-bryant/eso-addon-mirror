ShissuLocalization = ShissuLocalization or {}

ShissuLocalization["ShissuTeleporter"] = {  
  TELE   =       "Teleport",
  RND   =        "Random",
  REFRESH  =     "Update",
  GRP =          "Group leader",
  HOUSE  =       "Main residence",
  LEGEND1  =     "Legend",
  LEGEND2  =     "Friend",
  LEGEND3 =      "Group players",

  TITLE =         "Teleporter",
  INFO =          "Info",
  DESC =          "Open the teleporter window with a key combination of your choice that you have specified in the |cff7d77CONTROLS|ceeeeee. " ..
                  "You can also find a zone teleporter on the world map in the right window.",

  DESC2 =         "Alternatively you can use the following chat commands:\n\n"..
                  "|cff7d77/teleport|ceeeeee "..
                  "or " ..
                  "|cff7d77/tele|ceeeeee - "  ..
                  "Show/hide teleporter window" .. 
                  "\n|cff7d77/rndteleport|ceeeeee - " ..
                  "or " ..
                  "|cff7d77/rndtele|ceeeeee - " ..
                  "Random teleport",

  DESC3 =         "Teleport to another ZONE every |cff7d77x|ceeeeee seconds and post your advertisement that you have selected below. You only have to confirm the chat advertisement in the chat window (ENTER).",
  TELE_ADVERT =   "Teleport advertising",
  TELEIN =        "Teleport in X seconds",
  ADVERTISING =   "Advertising",

  STANDARD =      "Standard teleport",
  STANDARD_SET =  "First set a default location in the settings. Thank you.",
  STANDARD_NOPOS ="Did not find a suitable player in the guilds for the teleport to: %1 %2.",
  STANDARD_DESC = "Always teleport to the zone defined here. \nPerform the teleport with |cff7d77/standardtele|cffffff or a key combination of your choice.",
}

ZO_CreateStringId("SI_BINDING_NAME_SSC_teleportToogle", "Teleporter")
ZO_CreateStringId("SI_BINDING_NAME_SSC_teleportStandard", "Standard teleport")