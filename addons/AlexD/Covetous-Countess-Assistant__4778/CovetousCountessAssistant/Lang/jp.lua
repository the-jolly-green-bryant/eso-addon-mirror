local strings = {
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_COUNTESS
        = "貪欲な伯爵夫人を追跡",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_COUNTESS_TOOLTIP
        = "貪欲な伯爵夫人の宝物狩りに使える宝物をマークする。",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_CROW
        = "貢物の会計係を追跡",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_CROW_TOOLTIP
        = "貢物の会計係（カラス）の宝物狩りに使える宝物をマークする。",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_SETTINGS
        = "設定",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_COUNTESS_ON
        = "貪欲な伯爵夫人の追跡：オン",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_COUNTESS_OFF
        = "貪欲な伯爵夫人の追跡：オフ",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_CROW_ON
        = "貢物の会計係の追跡：オン",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_CROW_OFF
        = "貢物の会計係の追跡：オフ",
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
