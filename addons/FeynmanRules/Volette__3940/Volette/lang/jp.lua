local localizationStrings = {
    VOLETTE_YES = "はい",
    VOLETTE_NO = "いいえ",

    VOLETTE_REQUIRES_RELOADUI = "UIを再読み込みする必要があります。",
    VOLETTE_RELOADUI_DIALOG_TITLE = "UIを再読み込み",
    VOLETTE_RELOADUI_DIALOG_DESCRIPTION = "変更は次回UIを再読み込みしたときに適用されます。今すぐ再読み込みしますか？",

    VOLETTE_CONFIRM_DIALOG_TITLE = "確認",
    VOLETTE_CONFIRM_DIALOG_DESCRIPTION = "この操作を確認しますか？",

    VOLETTE_HQ_OWNER_CRAFT = "クラフトHQの所有者",
    VOLETTE_HQ_OWNER_PARSE = "トレーニングHQの所有者",
    VOLETTE_HQ_OWNER_MISSING = "設定でHQの所有者を選択する必要があります。",

    VOLETTE_CONTACTS_ENABLE = "連絡先メニューを有効にする",
    VOLETTE_CONTACTS_ENABLE_TOOLTIP = "フレンドリストの横に追加の連絡先メニューを表示するには、有効にしてください",
    VOLETTE_CONTACTS_ADDED = "<<1>> が連絡先に追加されました。",
    VOLETTE_CONTACTS_REMOVED = "<<1>> が連絡先から削除されました。",
    VOLETTE_CONTACTS_EXISTS = "<<1>> は既に連絡先にあります。",
    VOLETTE_CONTACTS_WAS_INVITED = "<<1>> が招待されました。",
    VOLETTE_CONTACTS_WHISPER_BUTTON_TOOLTIP = "ささやく",
    VOLETTE_CONTACTS_INVITE_BUTTON_TOOLTIP = "招待する",
    VOLETTE_CONTACTS_REMOVE_BUTTON_TOOLTIP = "リストから削除",
    VOLETTE_CONTACTS_PIN_BUTTON_TOOLTIP = "ピン留め",
    VOLETTE_CONTACTS_UNPIN_BUTTON_TOOLTIP = "ピンを外す",

    VOLETTE_TRAVEL_WAYSHRINE_CHOICE = "祠堂の近くの家を選択",
    VOLETTE_TRAVEL_WAYSHRINE_CHOICE_TOOLTIP = "コマンド |cffcc00/v-wayshrine|r を使用すると、この家の外にテレポートを試みます。この家を所有していない場合は、別の家が使用されます。",
    VOLETTE_TRAVEL_AUTO = "自動",
    VOLETTE_TRAVEL_WAYSHRINE_RECOMMENDATION = "対応する家を所有している必要があります。\"<<1>>\"が推奨されます。",
    VOLETTE_TRAVEL_WAYSHRINE_PORTING = "\"<<1>>\"の外に転送中。",
    VOLETTE_TRAVEL_SEARCHING_ANOTHER_WAYSHRINE = "「<<1>>」を所有している必要があります。別の家を探しています...",

    VOLETTE_SAVINGS_SUBMENU_TITLE = "貯蓄",
    VOLETTE_SAVINGS_SUBMENU_DESCRIPTION = "富をサブキャラに持たせたままにしないでください！通貨が貯まり始めたら、自動的に銀行に預けましょう。",
    VOLETTE_SAVINGS_ENABLE = "|c66a3ff有効化|r",
    VOLETTE_SAVINGS_MINIMUM_AMOUNT = "最低金額",
    VOLETTE_SAVINGS_MAXIMUM_AMOUNT = "最高金額",
    VOLETTE_SAVINGS_MINIMUM_AMOUNT_TOOLTIP = "キャラクターのバッグには常にこの金額が保持されます。",
    VOLETTE_SAVINGS_MAXIMUM_AMOUNT_TOOLTIP = "キャラクターのバッグにはこの金額以上が保持されません。",
    VOLETTE_SAVINGS_ENABLE_FOR_DESCRIPTION = "以下のキャラクターに対して有効化する：",
    VOLETTE_SAVINGS_DEPOSIT = "預金: <<1>>",
    VOLETTE_SAVINGS_WITHDRAWAL = "引き出し: <<1>>",
    VOLETTE_SAVINGS_NOT_ENOUGH_CURRENCIES = "銀行に<<1>>が見つかりませんでした。",

    SI_BINDING_NAME_VOLETTE_KEYBIND_PORT_TO_HOME = "メインの住居にテレポートする",
    SI_BINDING_NAME_VOLETTE_KEYBIND_PORT_TO_HQ_CRAFT = "クラフト本部にテレポートする",
    SI_BINDING_NAME_VOLETTE_KEYBIND_PORT_TO_HQ_PARSE = "トレーニング本部にテレポートする",
    SI_BINDING_NAME_VOLETTE_KEYBIND_PORT_TO_WAYSHRINE = "祠にテレポートする",

}


for stringId, stringValue in pairs(localizationStrings) do
    SafeAddString(_G[stringId], stringValue, 5)
end
