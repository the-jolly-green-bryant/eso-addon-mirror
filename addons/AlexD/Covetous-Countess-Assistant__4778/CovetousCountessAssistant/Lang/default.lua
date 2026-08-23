local strings = {
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_COUNTESS
        = "Track Covetous Countess",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_COUNTESS_TOOLTIP
        = "Highlight treasures needed for The Covetous Countess.",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_CROW
        = "Track Bursar of Tributes",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_CROW_TOOLTIP
        = "Highlight treasures needed for Bursar of Tributes (Crow).",
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
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_HIGHLIGHT_QUEST_ITEMS
        = "Highlight quest item matches",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_HIGHLIGHT_QUEST_ITEMS_TOOLTIP
        = "Color-code icons green when items match the active quest tags.",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_HIGHLIGHT_ON
        = "Quest item highlighting: ON",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_HIGHLIGHT_OFF
        = "Quest item highlighting: OFF",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_AUTOSKIP_TIPBOARD
        = "Auto-skip Tip Board offers",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_AUTOSKIP_TIPBOARD_TOOLTIP
        = "Automatically close Tip Board offers that are not The Covetous Countess.",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_AUTOSKIP_TIPBOARD_WARNING
        = "This will automatically close non-Countess dialogue.",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_AUTOSKIP_ON
        = "Tip Board auto-skip: ON",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_AUTOSKIP_OFF
        = "Tip Board auto-skip: OFF",
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(_G[stringId], 1)
end
