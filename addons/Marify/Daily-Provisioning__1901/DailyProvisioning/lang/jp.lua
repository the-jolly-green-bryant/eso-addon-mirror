------------------------------------------------
-- Japanese localization for DailyProvisioning
------------------------------------------------

ZO_CreateStringId("DP_CRAFTING_QUEST",      "調理師の依頼")     -- [jp.lang.csv] "52420949","0","5409","xxxxxxxx"
ZO_CreateStringId("DP_CRAFTING_MASTER",     "優れた料理")       -- [jp.lang.csv] "52420949","0","5977","xxxxxxxx"
ZO_CreateStringId("DP_CRAFTING_WITCH",      "魔女祭りの依頼")   -- [jp.lang.csv] "52420949","0","6427","xxxxxxxx"
ZO_CreateStringId("DP_CRAFTING_EVENT1",     "慈善への貢献")     -- [jp.lang.csv] "52420949","0","6327","xxxxxxxx"
ZO_CreateStringId("DP_CRAFTING_EVENT1BOOK", "帝国慈善依頼")     -- [jp.lang.csv] "242841733","0","167169","xxxxxxxx"

ZO_CreateStringId("DP_BULK_HEADER",         "一括作成")
ZO_CreateStringId("DP_BULK_FLG",            "依頼品を一括作成する")
ZO_CreateStringId("DP_BULK_FLG_TOOLTIP",    "依頼品を大量に作成しておきたい場合などに使用します。")
ZO_CreateStringId("DP_BULK_COUNT",          "作成数量")
ZO_CreateStringId("DP_BULK_COUNT_TOOLTIP",  "実際にはこの数量より多く作成されます。(シェフ/醸造家スキルに依存)")

ZO_CreateStringId("DP_CRAFT_WRIT",          "依頼品を作成する")
ZO_CreateStringId("DP_CRAFT_WRIT_MSG",      "調理用の火にアクセス時、<<1>>")
ZO_CreateStringId("DP_CANCEL_WRIT",         "依頼品の作成をキャンセル")
ZO_CreateStringId("DP_CANCEL_WRIT_MSG",     "依頼品の作成をキャンセルしました")

ZO_CreateStringId("DP_OTHER_HEADER",        "その他")
ZO_CreateStringId("DP_ACQUIRE_ITEM",        "銀行からアイテムを取り出す")
ZO_CreateStringId("DP_DELAY",               "遅延時間(秒)")
ZO_CreateStringId("DP_DELAY_TOOLTIP",       "アイテムを取り出す時の遅延時間\nアイテムをうまく取り出せない場合は増やして下さい。")
ZO_CreateStringId("DP_AUTO_EXIT",           "生産メニューを自動退出する")
ZO_CreateStringId("DP_AUTO_EXIT_TOOLTIP",   "自動作成が終わると生産メニューから退出します")
ZO_CreateStringId("DP_DONT_KNOW",           "いずれかのレシピを知らない場合は自動作成しない")
ZO_CreateStringId("DP_DONT_KNOW_TOOLTIP",   "デイリーでは2種類のレシピを調理しますが、いずれかのレシピを知らない場合は自動作成しません。")
ZO_CreateStringId("DP_LOG",                 "ログを表示")
ZO_CreateStringId("DP_DEBUG_LOG",           "デバッグログを表示")

ZO_CreateStringId("DP_UNKNOWN_RECIPE",      "[<<1>>] のレシピを持っていないので、料理を作成しませんでした。")
ZO_CreateStringId("DP_MISMATCH_RECIPE",     " ... [エラー]レシピ名が一致しません (<<1>>)")
ZO_CreateStringId("DP_NOTHING_RECIPE",      " ... レシピを持っていません")
ZO_CreateStringId("DP_SHORT_OF",            " ... 材料が不足しています (<<1>>)")




function DailyProvisioning:ConvertedItemNameForDisplay(itemName)
    return itemName
end

function DailyProvisioning:ConvertedItemNames(itemName)
    return {itemName}
end

function DailyProvisioning:ConvertedJournalCondition(journalCondition)

    local list = {
        {"\n",              ""},

        -- Master Writ
        {".+:(.*)を作成する",       "|c88AAFF[%1]|r |cFFFFFFを作成する|r"},
        {"%s?(.*)を作成する.*:",    "|c88AAFF[%1]|r |cFFFFFFを作成する|r"},

        -- Dayly
        {"(.*)を生産する[:：]",     "|c88AAFF[%1]|r を作成する"},
    }

    local convertedCondition = journalCondition
    for _, value in ipairs(list) do
        convertedCondition = string.gsub(convertedCondition, value[1], value[2])
    end
    return convertedCondition
end

function DailyProvisioning:CraftingConditions()
    local list = {
        "を作成する",
    }
    return list
end

function DailyProvisioning:isProvisioning(journalCondition)
    local list = {
        "次の特性の.*",                 -- SI_MASTER_WRIT_QUEST_ALCHEMY_FORMAT_STRING
        "鍛冶商人がこの.*を売っている", -- [jp.lang.csv] "7949764","0","61966","xxxxxxxx"
        "仕立商人がこの.*を売っている", -- [jp.lang.csv] "7949764","0","61968","xxxxxxxx"
        "木工商人がこの.*を売っている", -- [jp.lang.csv] "7949764","0","61970","xxxxxxxx"
        "木工師がこの.*を売っている",   -- [jp.lang.csv] "7949764","0","68075","xxxxxxxx"
    }
    return not self:Contains(journalCondition, list)
end

