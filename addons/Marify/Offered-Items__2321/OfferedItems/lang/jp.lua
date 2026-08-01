------------------------------------------------
-- Japanese localization for OfferedItems
------------------------------------------------

ZO_CreateStringId("OI_CHECK_LISTING",       "ギルド商人の[リスト登録]タブで、あなたの出品リストを確認してください。")
ZO_CreateStringId("OI_TOGGLE",              "出品リストをトグル表示")
ZO_CreateStringId("OI_GUILD_NAME",          "出品中|c<<1>>@<<2>>|r　　")
ZO_CreateStringId("OI_IN_SALE",             "出品中　　")
ZO_CreateStringId("OI_LISTING",             "出品リスト")
ZO_CreateStringId("OI_HIDE_NO_TRADER",      "ギルド商人がいないギルドは表示しない")
ZO_CreateStringId("OI_SOLD_NOTIFICATION",   "売却を通知")
ZO_CreateStringId("OI_OPEN_STORE",          "ストアで開く")
ZO_CreateStringId("OI_MARK",                "マーク")
ZO_CreateStringId("OI_SHOW_MARK",           "インベントリのリストにマークを表示")
ZO_CreateStringId("OI_CHOICE_MARK",         "アイコンを選択")
ZO_CreateStringId("OI_SIZE",                "サイズ")
ZO_CreateStringId("OI_VERTICAL_POS",        "タテ位置")
ZO_CreateStringId("OI_HORIZONTAL_POS",      "ヨコ位置")
ZO_CreateStringId("OI_LOG",                 "ログを表示")
ZO_CreateStringId("OI_DEBUG_LOG",           "デバッグログを表示")




function OfferedItems:GetStoreNPC()
    return {
        "ロリス・フラール",             -- [jp.lang.csv] "8290981","0","74874","xxxxxxx","ロリス・フラール^M"
        "ファウスティナ・キュリオ",     -- [jp.lang.csv] "8290981","0","82482","xxxxxxx","ファウスティナ・キュリオ^F"
    }
end

