------------------------------------------------
-- Korean localization for DailyProvisioning
------------------------------------------------
if EsoKR and EsoKR:isKorean() then
    ZO_CreateStringId("DP_CRAFTING_QUEST",      EsoKR:E("요리사 의뢰서"))
    ZO_CreateStringId("DP_CRAFTING_MASTER",     EsoKR:E("거장의 성찬"))

    ZO_CreateStringId("DP_BULK_HEADER",         EsoKR:E("대량 생산"))
    ZO_CreateStringId("DP_BULK_FLG",            "Create all the requested items at once")
    ZO_CreateStringId("DP_BULK_FLG_TOOLTIP",    "It is used when you want to create a large number of requested items.")
    ZO_CreateStringId("DP_BULK_COUNT",          "Created quantity")
    ZO_CreateStringId("DP_BULK_COUNT_TOOLTIP",  "In fact it will be created more than this quantity.(Depends on Chef/Brewer skills)")

    ZO_CreateStringId("DP_CRAFT_WRIT",          "Craft Sealed Writ")
    ZO_CreateStringId("DP_CRAFT_WRIT_MSG",      "When accessing the Cooking fire, <<1>>")
    ZO_CreateStringId("DP_CANCEL_WRIT",         "Cancel Sealed Writ")
    ZO_CreateStringId("DP_CANCEL_WRIT_MSG",     "Canceled Sealed Writ")

    ZO_CreateStringId("DP_OTHER_HEADER",        EsoKR:E("기타"))
    ZO_CreateStringId("DP_ACQUIRE_ITEM",        EsoKR:E("은행에서 재료 회수"))
    ZO_CreateStringId("DA_AUTO_EXIT",           EsoKR:E("자동 종료"))
    ZO_CreateStringId("DA_AUTO_EXIT_TOOLTIP",   EsoKR:E("일일 의뢰 완료 후 자동으로 제작대 떠나기"))
    ZO_CreateStringId("DP_DONT_KNOW",           "Disable automatic creation if a recipe is unknown")
    ZO_CreateStringId("DP_DONT_KNOW_TOOLTIP",   "If one of the recipes required to complete the writ is unknown to your character then no items will be created automatically.")
    ZO_CreateStringId("DA_LOG",                 EsoKR:E("로그 보기"))
    ZO_CreateStringId("DA_DEBUG_LOG",           EsoKR:E("개발용 로그 보기"))

    ZO_CreateStringId("DP_UNKNOWN_RECIPE",      " Recipe [<<1>>] is unknown. No items were created.")
    ZO_CreateStringId("DP_MISMATCH_RECIPE",     " ... [Error]Recipe name does not match (<<1>>)")
    ZO_CreateStringId("DP_NOTHING_RECIPE",      " ... Don't have a Recipe")
    ZO_CreateStringId("DP_SHORT_OF",            " ... Short of Materials (<<1>>)")

    local list = { {"(\-)", ""}, {"%([a-zA-Z%- ]+%)", ""} }
    function DailyProvisioning:ConvertedItemNameForDisplay(itemName)
        return itemName
    end

    function DailyProvisioning:ConvertedItemNames(itemName)
        local convertedItemName = EsoKR:removeIndex(itemName)
        for _, value in ipairs(list) do convertedItemName = string.gsub(convertedItemName, value[1], value[2]) end
        return {convertedItemName}
    end

    function DailyProvisioning:ConvertedJournalCondition(journalCondition)
        local convertedItemName = EsoKR:removeIndex(journalCondition)
        for _, value in ipairs(list) do convertedItemName = string.gsub(convertedItemName, value[1], value[2]) end
        return convertedItemName
    end

    function DailyProvisioning:ConvertedMasterWritText(txt)
        return string.gsub(txt, ".*:\n(.*)", "%1")
    end


    function DailyProvisioning:CraftingConditions()
        return { EsoKR:E("제작"), }
    end

end