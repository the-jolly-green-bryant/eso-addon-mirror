------------------------------------------------
-- Japanese localization for DailyProvisioning
------------------------------------------------

ZO_CreateStringId("DP_CRAFTING_QUEST",      "Encargo de cocina")                    -- [es.lang.csv] "52420949","0","5409","xxxxxxxx"
ZO_CreateStringId("DP_CRAFTING_MASTER",     "Un festín magistral")                  -- [es.lang.csv] "52420949","0","5977","xxxxxxxx"
ZO_CreateStringId("DP_CRAFTING_WITCH",      "Encargo del Festival de las Brujas")   -- [es.lang.csv] "52420949","0","6427","xxxxxxxx"
ZO_CreateStringId("DP_CRAFTING_EVENT1",     "Una contribución caritativa")          -- [es.lang.csv] "52420949","0","6327","xxxxxxxx"
ZO_CreateStringId("DP_CRAFTING_EVENT1BOOK", "encargo caritativo imperial")          -- [es.lang.csv] "242841733","0","167169","xxxxxxxx"

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
        {"%-",   " "},
        {"%^.*", ""},
        {" ",    " "},   -- code(0xA0) > space(0x20): HTML non-breaking space ?("0xC2 0xA0")
        {"á",    "a"},
        {"é",    "e"},
        {"ñ",    "n"},
        {"ó",    "o"},
    }
    local itemName = string.lower(itemName)
    for _, value in ipairs(list) do
        itemName = string.gsub(itemName, value[1], value[2])
    end
    return {itemName}
end

function DailyProvisioning:ConvertedJournalCondition(journalCondition)
    local list = {
        {"\n", ""},
        {" ",  " "},   -- code(0xA0) > space(0x20): HTML non-breaking space ?("0xC2 0xA0")
        {"%-", " "},
        {"á",  "a"},
        {"é",  "e"},
        {"ñ",  "n"},
        {"ó",  "o"},
    }
    journalCondition = string.lower(journalCondition)
    for _, value in ipairs(list) do
        journalCondition = string.gsub(journalCondition, value[1], value[2])
    end


    local list2 = {
        -- Master Writ(Create from context menu)
        {".*fabrica un%w* (.*)\.",            "Fabrica |c88AAFF[%1]|r"},

        -- Dayly
        {".*prepara un%w* (.*)\.：.*",        "Prepara |c88AAFF[%1]|r"},
        {".*prepara un%w* (.*)\..*",          "Prepara |c88AAFF[%1]|r"},
        {".*prepara (.*)\.：.*",              "Prepara |c88AAFF[%1]|r"},
        {".*prepara (.*)\.:.*",               "Prepara |c88AAFF[%1]|r"},
        {".*prepara (.*)\..*",                "Prepara |c88AAFF[%1]|r"},
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
        "Prepara ",
        "Fabrica ",
    }
    return list
end

function DailyProvisioning:isProvisioning(journalCondition)
    local list = {
        "Fabrica .* con los siguientes rasgos:.*",  -- SI_MASTER_WRIT_QUEST_ALCHEMY_FORMAT_STRING
        "Los herreros venden este diagrama.*",      -- [es.lang.csv] "7949764","0","61966","xxxxxxxx"
        "Los sastres venden este diseño.*",         -- [es.lang.csv] "7949764","0","61968","xxxxxxxx"
        "Los carpinteros venden este plano.*",      -- [es.lang.csv] "7949764","0","61970","xxxxxxxx"
        "Los carpinteros venden este diagrama.*",   -- [es.lang.csv] "7949764","0","68075","xxxxxxxx"
    }
    return not self:Contains(journalCondition, list)
end

