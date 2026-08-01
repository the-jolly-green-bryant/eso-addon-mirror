------------------------------------------------
-- Japanese localization for DailyProvisioning
------------------------------------------------

ZO_CreateStringId("DP_CRAFTING_QUEST",      "厨师委托")         -- [zh.lang.csv] "52420949","0","5409","xxxxxxxx"
ZO_CreateStringId("DP_CRAFTING_MASTER",     "令人垂涎的盛宴")   -- [zh.lang.csv] "52420949","0","5977","xxxxxxxx"
ZO_CreateStringId("DP_CRAFTING_WITCH",      "女巫集会委托")     -- [zh.lang.csv] "52420949","0","6427","xxxxxxxx"
ZO_CreateStringId("DP_CRAFTING_EVENT1",     "慈善捐赠")         -- [zh.lang.csv] "52420949","0","6327","xxxxxxxx"
ZO_CreateStringId("DP_CRAFTING_EVENT1BOOK", "帝都慈善委托")     -- [zh.lang.csv] "242841733","0","167169","xxxxxxxx"

ZO_CreateStringId("DP_BULK_HEADER",         "批量创建")
ZO_CreateStringId("DP_BULK_FLG",            "创建一批请购单")
ZO_CreateStringId("DP_BULK_FLG_TOOLTIP",    "例如，当你想创建大量要求的项目时，就会用到这个方法。")
ZO_CreateStringId("DP_BULK_COUNT",          "创建数量")
ZO_CreateStringId("DP_BULK_COUNT_TOOLTIP",  "在实践中，创造出来的东西比这个数量多。 (取决于炼金术技能）。")

ZO_CreateStringId("DP_CRAFT_WRIT",          "创建一个委托")
ZO_CreateStringId("DP_CRAFT_WRIT_MSG",      "在访问炼金术表时 <<1>>")
ZO_CreateStringId("DP_CANCEL_WRIT",         "取消创建一个请求")
ZO_CreateStringId("DP_CANCEL_WRIT_MSG",     "取消了该委员会的设立。")

ZO_CreateStringId("DP_OTHER_HEADER",        "其他")
ZO_CreateStringId("DP_ACQUIRE_ITEM",        "从银行中取出物品")
ZO_CreateStringId("DP_DELAY",               "延迟时间")
ZO_CreateStringId("DP_DELAY_TOOLTIP",       "检索项目时的延迟时间\n如果项目不能成功检索，请增加这个时间。")
ZO_CreateStringId("DP_AUTO_EXIT",           "自动退出生产菜单")
ZO_CreateStringId("DP_AUTO_EXIT_TOOLTIP",   "自动创建完成后，从生产菜单中退出。")
ZO_CreateStringId("DP_DONT_KNOW",           "如果任何配方不为人所知，它们就不会被自动创建。")
ZO_CreateStringId("DP_DONT_KNOW_TOOLTIP",   "每天烹饪两个不同的食谱，但如果它不知道其中一个食谱，则不会自动创建一个食谱。")
ZO_CreateStringId("DP_LOG",                 "查看日志")
ZO_CreateStringId("DP_DEBUG_LOG",           "查看调试日志")

ZO_CreateStringId("DP_UNKNOWN_RECIPE",      "[<<1>>]由于他们没有菜谱，所以没有制作这道菜。")
ZO_CreateStringId("DP_MISMATCH_RECIPE",     " ... [Error]配方名称不匹配 (<<1>>)")
ZO_CreateStringId("DP_NOTHING_RECIPE",      " ... 我没有菜谱")
ZO_CreateStringId("DP_SHORT_OF",            " ... 材料不充分 (<<1>>)")




function DailyProvisioning:ConvertedItemNameForDisplay(itemName)
    return itemName
end

function DailyProvisioning:ConvertedItemNames(itemName)
    local list = {
        {"%-",  " "},
        {"%^.*", ""},
    }

    local convertedItemName = itemName
    for _, value in ipairs(list) do
        convertedItemName = string.gsub(convertedItemName, value[1], value[2])
    end
    return {convertedItemName}
end

function DailyProvisioning:ConvertedJournalCondition(journalCondition)

    local list = {
        {"\n", ""},
        {" ",  " "},   -- code(0xA0) > space(0x20): HTML non-breaking space ?("0xC2 0xA0")
        {"%-", " "},
    }
    for _, value in ipairs(list) do
        journalCondition = string.gsub(journalCondition, value[1], value[2])
    end


    local list2 = {
        -- Master Writ(Create from context menu)
        {".*制作一个(.*)",  "制作 |c88AAFF[%1]|r"},

        -- Dayly
        {"制作(.*):.*",     "制作 |c88AAFF[%1]|r"},
        {"制作(.*)：.*",    "制作 |c88AAFF[%1]|r"},
        {"制作(.*)",        "制作 |c88AAFF[%1]|r"},
    }
    for _, value in ipairs(list2) do
        if string.match(journalCondition, value[1]) then
            return string.gsub(journalCondition, value[1], value[2])
        end
    end
    return journalCondition
end

function DailyProvisioning:CraftingConditions()
    local list = {
        "制作",
    }
    return list
end

function DailyProvisioning:isProvisioning(journalCondition)
    local list = {
        "制作一个.*，具有以下属性：.*进度", -- SI_MASTER_WRIT_QUEST_ALCHEMY_FORMAT_STRING
        "铁匠商人会出售这份图纸.*",         -- [zh.lang.csv] "7949764","0","61966","xxxxxxxx"
        "制衣匠商人会出售这个图样.*",       -- [zh.lang.csv] "7949764","0","61968","xxxxxxxx"
        "地毯商人会出售这个蓝图.*",         -- [zh.lang.csv] "7949764","0","61970","xxxxxxxx"
        "木匠会出售这个图纸.*",             -- [zh.lang.csv] "7949764","0","68075","xxxxxxxx"
    }
    return not self:Contains(journalCondition, list)
end

