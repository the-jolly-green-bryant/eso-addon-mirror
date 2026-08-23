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
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_HIGHLIGHT_QUEST_ITEMS
        = "クエストアイテムの一致を強調表示",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_HIGHLIGHT_QUEST_ITEMS_TOOLTIP
        = "アクティブなクエストのタグと一致するアイテムのアイコンを緑色で表示します。",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_HIGHLIGHT_ON
        = "クエストアイテムの強調表示：オン",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_HIGHLIGHT_OFF
        = "クエストアイテムの強調表示：オフ",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_AUTOSKIP_TIPBOARD
        = "情報掲示板のオファーを自動スキップ",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_AUTOSKIP_TIPBOARD_TOOLTIP
        = "貪欲な伯爵夫人以外の情報掲示板のオファーを自動的に閉じます。",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_AUTOSKIP_TIPBOARD_WARNING
        = "伯爵夫人以外の会話が自動的に閉じられます。",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_AUTOSKIP_ON
        = "情報掲示板の自動スキップ：オン",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_AUTOSKIP_OFF
        = "情報掲示板の自動スキップ：オフ",
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
