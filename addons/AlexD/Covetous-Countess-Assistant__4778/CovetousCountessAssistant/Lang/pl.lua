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
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
