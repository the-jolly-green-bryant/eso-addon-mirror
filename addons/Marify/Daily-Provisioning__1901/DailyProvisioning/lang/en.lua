------------------------------------------------
-- English localization for DailyProvisioning
------------------------------------------------

ZO_CreateStringId("DP_CRAFTING_QUEST",      "Provisioner Writ")             -- [en.lang.csv] "52420949","0","5409","xxxxxxxx"
ZO_CreateStringId("DP_CRAFTING_MASTER",     "A Masterful Feast")            -- [en.lang.csv] "52420949","0","5977","xxxxxxxx"
ZO_CreateStringId("DP_CRAFTING_WITCH",      "Witches Festival Writ")        -- [en.lang.csv] "52420949","0","6427","xxxxxxxx"
ZO_CreateStringId("DP_CRAFTING_EVENT1",     "A Charitable Contribution")    -- [en.lang.csv] "52420949","0","6327","xxxxxxxx"
ZO_CreateStringId("DP_CRAFTING_EVENT1BOOK", "Imperial Charity Writ")        -- [en.lang.csv] "242841733","0","167169","xxxxxxxx"

ZO_CreateStringId("DP_BULK_HEADER",         "Bulk Creation")
ZO_CreateStringId("DP_BULK_FLG",            "Create all the requested items at once")
ZO_CreateStringId("DP_BULK_FLG_TOOLTIP",    "It is used when you want to create a large number of requested items.")
ZO_CreateStringId("DP_BULK_COUNT",          "Created quantity")
ZO_CreateStringId("DP_BULK_COUNT_TOOLTIP",  "In fact it will be created more than this quantity.(Depends on Chef/Brewer skills)")

ZO_CreateStringId("DP_CRAFT_WRIT",          "Craft Sealed Writ")
ZO_CreateStringId("DP_CRAFT_WRIT_MSG",      "When accessing the Cooking fire, <<1>>")
ZO_CreateStringId("DP_CANCEL_WRIT",         "Cancel Sealed Writ")
ZO_CreateStringId("DP_CANCEL_WRIT_MSG",     "Canceled Sealed Writ")

ZO_CreateStringId("DP_OTHER_HEADER",        "Other")
ZO_CreateStringId("DP_ACQUIRE_ITEM",        "Retrieve items from bank")
ZO_CreateStringId("DP_DELAY",               "Delay time")
ZO_CreateStringId("DP_DELAY_TOOLTIP",       "Delay time to retrieve item(sec)\nIf you cannot take out the item well, increase it.")
ZO_CreateStringId("DP_AUTO_EXIT",           "Auto exit")
ZO_CreateStringId("DP_AUTO_EXIT_TOOLTIP",   "You will automatically leave the crafting table after completing the daily writ.")
ZO_CreateStringId("DP_DONT_KNOW",           "Disable automatic creation if a recipe is unknown")
ZO_CreateStringId("DP_DONT_KNOW_TOOLTIP",   "If one of the recipes required to complete the writ is unknown to your character then no items will be created automatically.")
ZO_CreateStringId("DP_LOG",                 "Show log")
ZO_CreateStringId("DP_DEBUG_LOG",           "Show debug log")

ZO_CreateStringId("DP_UNKNOWN_RECIPE",      " Recipe [<<1>>] is unknown. No items were created.")
ZO_CreateStringId("DP_MISMATCH_RECIPE",     " ... [Error]Recipe name does not match (<<1>>)")
ZO_CreateStringId("DP_NOTHING_RECIPE",      " ... Don't have a Recipe")
ZO_CreateStringId("DP_SHORT_OF",            " ... Short of Materials (<<1>>)")




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

        -- Master Writ(Create from context menu)
        {".+:Craft a%w* (.*)",              "Craft |c88AAFF[%1]|r"},
        {".+:Craft (.*)",                   "Craft |c88AAFF[%1]|r"},

        -- Master Writ(in Journal)
        {"Craft a%w* (.*)...%sProgress:",   "Craft |c88AAFF[%1]|r"},

        -- Dayly
        {".*Craft (.*):.*",                 "Craft |c88AAFF[%1]|r"},
    }

    local convertedCondition = journalCondition
    for _, value in ipairs(list) do
        convertedCondition = string.gsub(convertedCondition, value[1], value[2])
    end
    return convertedCondition
end

function DailyProvisioning:CraftingConditions()
    local list = {
        "Craft ",
    }
    return list
end

function DailyProvisioning:isProvisioning(journalCondition)
    local list = {
        "Craft .* with the following .*raits",  -- SI_MASTER_WRIT_QUEST_ALCHEMY_FORMAT_STRING
        "Blacksmith Merchants sell this .*",    -- [en.lang.csv] "7949764","0","61966","xxxxxxxx"
        "Clothier Merchants sell this .*",      -- [en.lang.csv] "7949764","0","61968","xxxxxxxx"
        "Carpenter Merchants sell this .*",     -- [en.lang.csv] "7949764","0","61970","xxxxxxxx"
        "Carpenters sell this .*",              -- [en.lang.csv] "7949764","0","68075","xxxxxxxx"
    }
    return not self:Contains(journalCondition, list)
end

