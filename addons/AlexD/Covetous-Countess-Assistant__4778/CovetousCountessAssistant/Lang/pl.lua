local strings = {
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_COUNTESS
        = "Śledź Chciwą Hrabinę",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_COUNTESS_TOOLTIP
        = "Oznacz skarby przydatne do polowań Chciwej Hrabiny.",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_CROW
        = "Śledź Skarbnika Danin",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_CROW_TOOLTIP
        = "Oznacz skarby przydatne do polowań Skarbnika Danin (Kruk).",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_SETTINGS
        = "Ustawienia",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_COUNTESS_ON
        = "Śledzenie Chciwej Hrabiny: WŁ",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_COUNTESS_OFF
        = "Śledzenie Chciwej Hrabiny: WYŁ",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_CROW_ON
        = "Śledzenie Skarbnika Danin: WŁ",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_CROW_OFF
        = "Śledzenie Skarbnika Danin: WYŁ",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_HIGHLIGHT_QUEST_ITEMS
        = "Podświetl pasujące przedmioty zadań",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_HIGHLIGHT_QUEST_ITEMS_TOOLTIP
        = "Koloruje ikony przedmiotów na zielono, gdy pasują do tagów aktywnego zadania.",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_HIGHLIGHT_ON
        = "Podświetlanie przedmiotów zadania: WŁ.",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_HIGHLIGHT_OFF
        = "Podświetlanie przedmiotów zadania: WYŁ.",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_AUTOSKIP_TIPBOARD
        = "Auto-pomijanie ofert Tablicy Wskazówek",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_AUTOSKIP_TIPBOARD_TOOLTIP
        = "Automatycznie zamyka oferty Tablicy Wskazówek, które nie dotyczą Chciwej Hrabiny.",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_AUTOSKIP_TIPBOARD_WARNING
        = "To automatycznie zamknie dialogi niezwiązane z Hrabiną.",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_AUTOSKIP_ON
        = "Auto-pomijanie Tablicy Wskazówek: WŁ",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_AUTOSKIP_OFF
        = "Auto-pomijanie Tablicy Wskazówek: WYŁ",
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
