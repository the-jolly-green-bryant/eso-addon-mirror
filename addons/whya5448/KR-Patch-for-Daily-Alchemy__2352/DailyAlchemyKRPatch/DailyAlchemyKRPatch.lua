------------------------------------------------
-- Korean localization for DailyAlchemy
------------------------------------------------
if EsoKR and EsoKR:isKorean() then
    ZO_CreateStringId("DA_CRAFTING_QUEST",      EsoKR:E("연금술사 의뢰서"))
    ZO_CreateStringId("DA_CRAFTING_MASTER",     EsoKR:E("거장의 혼합물"))

    ZO_CreateStringId("DA_BULK_HEADER",         EsoKR:E("대량 생산"))
    ZO_CreateStringId("DA_BULK_FLG",            "Create all the requested items at once")
    ZO_CreateStringId("DA_BULK_FLG_TOOLTIP",    "It is used when you want to create a large number of requested items.")
    ZO_CreateStringId("DA_BULK_COUNT",          "Created quantity")
    ZO_CreateStringId("DA_BULK_COUNT_TOOLTIP",  "In fact it will be created more than this quantity.(Depends on alchemy skills)")

    ZO_CreateStringId("DA_CRAFT_WRIT",          "Craft Sealed Writ")
    ZO_CreateStringId("DA_CRAFT_WRIT_MSG",      "When accessing the alchemy station, <<1>>")
    ZO_CreateStringId("DA_CANCEL_WRIT",         "Cancel Sealed Writ")
    ZO_CreateStringId("DA_CANCEL_WRIT_MSG",     "Canceled Sealed Writ")

    ZO_CreateStringId("DA_PRIORITY_HEADER",     EsoKR:E("시약 우선순위"))
    ZO_CreateStringId("DA_PRIORITY_BY",         EsoKR:E("사용할 시약 순위"))
    ZO_CreateStringId("DA_PRIORITY_BY_STOCK",   EsoKR:E("많은 수 부터"))
    ZO_CreateStringId("DA_PRIORITY_BY_MM",      "Low price reagent at [MasterMerchant]")
    ZO_CreateStringId("DA_PRIORITY_BY_TTC",     "Low price reagent at [TamrielTradeCentre]")
    ZO_CreateStringId("DA_PRIORITY_BY_ATT",     "Low price reagent at [ArkadiusTradeTools]")
    ZO_CreateStringId("DA_PRIORITY_BY_MANUAL",  EsoKR:E("수동 지정"))
    ZO_CreateStringId("DA_SHOW_PRICE_MANUAL",   "Show price[<<1>>]")
    ZO_CreateStringId("DA_PRIORITY_CHANGED",    "The add-on setting [<<1>>] has been changed because the <<2>> is turned off")

    ZO_CreateStringId("DA_OTHER_HEADER",        EsoKR:E("기타"))
    ZO_CreateStringId("DA_ACQUIRE_ITEM",        EsoKR:E("은행에서 재료 회수"))
    ZO_CreateStringId("DA_AUTO_EXIT",           EsoKR:E("자동 종료"))
    ZO_CreateStringId("DA_AUTO_EXIT_TOOLTIP",   EsoKR:E("일일 의뢰 완료 후 자동으로 제작대 떠나기"))
    ZO_CreateStringId("DA_ITEM_LOCK",           "Do not use locked items")
    ZO_CreateStringId("DA_LOG",                 EsoKR:E("로그 보기"))
    ZO_CreateStringId("DA_DEBUG_LOG",           EsoKR:E("개발용 로그 보기"))

    ZO_CreateStringId("DA_NOTHING_ITEM",        "No items in the backpack (<<1>>)")
    ZO_CreateStringId("DA_SHORT_OF",            "... Short of Materials(<<1>>)")
    ZO_CreateStringId("DA_MISMATCH_ITEM",       "... [Error]Name does not match (<<1>>)")

    ZO_CreateStringId("DA_DETECTION",           EsoKR:E("탐지"))
    ZO_CreateStringId("DA_ARMOR",               EsoKR:E("방어"))
    ZO_CreateStringId("DA_SPELL_POWER",         EsoKR:E("주문 위력 증가"))
    ZO_CreateStringId("DA_SPELL_RESIST",        EsoKR:E("마법 저항력 증가"))
    ZO_CreateStringId("DA_WEAPON_POWER",        EsoKR:E("무기 위력 증가"))
    ZO_CreateStringId("DA_INVISIBLE",           EsoKR:E("투명화"))
    ZO_CreateStringId("DA_FRACTURE",            EsoKR:E("균열"))
    ZO_CreateStringId("DA_UNCERTAINTY",         EsoKR:E("불확실"))
    ZO_CreateStringId("DA_COWARDICE",           EsoKR:E("비겁"))
    ZO_CreateStringId("DA_BREACH",              EsoKR:E("돌파"))
    ZO_CreateStringId("DA_ENERVATE",            EsoKR:E("쇠약"))
    ZO_CreateStringId("DA_MAIM",                EsoKR:E("불구"))
    ZO_CreateStringId("DA_RVG_HEALTH",          EsoKR:E("체력 파괴"))
    ZO_CreateStringId("DA_RVG_MAGICKA",         EsoKR:E("매지카 파괴"))
    ZO_CreateStringId("DA_RVG_STAMINA",         EsoKR:E("스태미나 파괴"))
    ZO_CreateStringId("DA_HINDRANCE",           EsoKR:E("방해"))
    ZO_CreateStringId("DA_HEALTH",              EsoKR:E("체력 회복"))
    ZO_CreateStringId("DA_MAGICKA",             EsoKR:E("매지카 회복"))
    ZO_CreateStringId("DA_STAMINA",             EsoKR:E("스태미나 회복"))
    ZO_CreateStringId("DA_SPEED",               EsoKR:E("속도"))
    ZO_CreateStringId("DA_SPELL_CRIT",          EsoKR:E("마법 치명타"))
    ZO_CreateStringId("DA_ENTRAPMENT",          EsoKR:E("덫"))
    ZO_CreateStringId("DA_UNSTOP",              EsoKR:E("저지 불가"))
    ZO_CreateStringId("DA_WEAPON_CRIT",         EsoKR:E("무기 치명타"))
    ZO_CreateStringId("DA_VULNERABILITY",       EsoKR:E("취약"))
    ZO_CreateStringId("DA_DEFILE",              EsoKR:E("부패"))
    ZO_CreateStringId("DA_GR_RVG_HEALTH",       EsoKR:E("지속 체력 파괴"))
    ZO_CreateStringId("DA_LGR_HEALTH",          EsoKR:E("지속 체력 회복"))
    ZO_CreateStringId("DA_VITALITY",            EsoKR:E("활력"))
    ZO_CreateStringId("DA_PROTECTION",          EsoKR:E("보호"))

    function DailyAlchemy:AcquireConditions()
        local list = {
            "Acquire%s(.*)",
        }
        return list
    end

    function DailyAlchemy:ConvertedItemNames(itemName)
        local list = {
            {"(\-)",     "(\-)"},
            {" IX$",     " Ⅸ"},
            {" VIII$",   " Ⅷ"},
            {" VII$",    " Ⅶ"},
            {" VI$",     " Ⅵ"},
            {" IV$",     " Ⅳ"},
            {" V$",      " Ⅴ"},
            {" III$",    " Ⅲ"},
            {" II$",     " Ⅱ"},
            {" I$",      " Ⅰ"},
            {"panacea ", "Panacea "},   -- Some users have string.lower() disabled?
            {" health",  " Health"},    -- Some users have string.lower() disabled?
            {" stamina", " Stamina"},   -- Some users have string.lower() disabled?
        }

        local convertedItemName = EsoKR:removeIndex(itemName)
        for _, value in ipairs(list) do convertedItemName = string.gsub(convertedItemName, value[1], value[2]) end

        return {convertedItemName}
    end

    function DailyAlchemy:ConvertedJournalCondition(journalCondition)
        local list = {
            {" IX([:%s])",   " Ⅸ%1"},
            {" VIII([:%s])", " Ⅷ%1"},
            {" VII([:%s])",  " Ⅶ%1"},
            {" VI([:%s])",   " Ⅵ%1"},
            {" IV([:%s])",   " Ⅳ%1"},
            {" V([:%s])",    " Ⅴ%1"},
            {" III([:%s])",  " Ⅲ%1"},
            {" II([:%s])",   " Ⅱ%1"},
            {" I([:%s])",    " Ⅰ%1"},
            {"panacea ",     "Panacea "},   -- Some users have string.lower() disabled?
            {" health",      " Health"},    -- Some users have string.lower() disabled?
            {" stamina",     " Stamina"},   -- Some users have string.lower() disabled?

            {EsoKR:E("(특성을 가진.*).*제작:%c•(.*)%c•(.*)%c•(.*)%c•.*"),  "%1...%2, %3, %4"},
            {".*(Craft.*)with.*properties:(.*)",                  "%1...%2"},
            {":.*",                                               ""},
        }

        local convertedCondition = EsoKR:removeIndex(journalCondition)
        for _, value in ipairs(list) do convertedCondition = string.gsub(convertedCondition, value[1], value[2]) end
        return convertedCondition
    end

    function DailyAlchemy:ConvertedMasterWritText(txt) return string.gsub(txt, ".*:\n(.*) with.*: (.*)", "%1 [%2]") end

    function DailyAlchemy:CraftingConditions()
        local list = { EsoKR:E("제작"), EsoKR:E("다음 특성을 가진"), }
        return list
    end

    function DailyAlchemy:isPoison(conditionText) return string.match(conditionText, EsoKR:E("독")) end
end
