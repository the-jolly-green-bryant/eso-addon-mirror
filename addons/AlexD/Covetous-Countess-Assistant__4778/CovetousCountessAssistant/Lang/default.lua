local strings = {
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_COUNTESS
        = "Track Covetous Countess",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_COUNTESS_TOOLTIP
        = "Mark treasures usable for Covetous Countess hunts.",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_CROW
        = "Track Bursar of Tributes",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_CROW_TOOLTIP
        = "Mark treasures usable for Bursar of Tributes (Crow) hunts.",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_SETTINGS
        = "Settings",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_COUNTESS_ON
        = "Covetous Countess tracking: ON",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_COUNTESS_OFF
        = "Covetous Countess tracking: OFF",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_CROW_ON
        = "Bursar of Tributes tracking: ON",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_CROW_OFF
        = "Bursar of Tributes tracking: OFF",
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(_G[stringId], 1)
end
