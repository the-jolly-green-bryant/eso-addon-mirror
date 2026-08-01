local strings = {
   --tooltips
   DCS_KNOWN                = "killed",

   DCS_MOREINFO1            = "Town",
   DCS_MOREINFO2            = "Solo dungeon",
   DCS_MOREINFO3            = "Public dungeon",
   DCS_MOREINFO4            = "Cave",

   --settings menu header
   DCS_TITLE                = "Dungeon Champions",

   --appearance
   DCS_MAPPINS_HEADER       = "Map Pins",
   
   DCS_PIN_TEXTURE          = "Select map pin icons",
   DCS_PIN_TEXTURE_DESC     = "Select map pin icons.",
   
   DCS_KNOWN_COL            = "Color for killed champions",
   DCS_KNOWN_COL_TIP        = "Select the pin color for already killed champions.",
   
   DCS_UNKNOWN_COL          = "Color for not yet killed champions",
   DCS_UNKNOWN_COL_TIP      = "Select the pin color for not yet killed champions.",
   
   DCS_PIN_SIZE             = "Pin size",
   DCS_PIN_SIZE_DESC        = "Set the size of the map pins.",
   
   DCS_PIN_LAYER            = "Pin layer",
   DCS_PIN_LAYER_DESC       = "Set the layer of the map pins",
   
   DCS_BOSS_TEXTURE_1       = "Normal Ingame Icons",
   DCS_BOSS_TEXTURE_2       = "Colored Icons",

   --compass
   DCS_COMPASS_HEADER       = "Compass Pins",
 
   DCS_COMPASS_KNOWN        = "Show killed Champions on the compass",
   DCS_COMPASS_KNOWN_DESC   = "Show/hide icons for killed Champions on the compass.",

   DCS_COMPASS_UNKNOWN      = "Show not yet killed Champions on the compass",
   DCS_COMPASS_UNKNOWN_DESC = "Show/hide icons for not yet killed Champions on the compass.",

   DCS_COMPASS_DIST         = "Max pin distance",
   DCS_COMPASS_DIST_DESC    = "The maximum distance for pins to appear on the compass.",

   --filters
   DCS_UNKNOWN              = "Show not yet killed Champions",
   DCS_UNKNOWN_DESC         = "Show/hide icons for not yet killed Champions on the map.",
   DCS_COLLECTED            = "Show killed Champions",
   DCS_COLLECTED_DESC       = "Show/hide icons for already killed Champions on the map.",

   --worldmap filters
   DCS_FILTER_UNKNOWN       = "Not yet killed Champions",
   DCS_FILTER_COLLECTED     = "Killed Champions",
}

for stringId, stringValue in pairs(strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end
