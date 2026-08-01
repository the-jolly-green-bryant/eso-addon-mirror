------------------------------------------------
-- Polish localization for DailyProvisioning
------------------------------------------------

ZO_CreateStringId("DP_CRAFTING_QUEST",      "Zlecenie na przyrządzenie")        -- [pl.lang.csv] "52420949","0","5409","xxxxxxxx"
ZO_CreateStringId("DP_CRAFTING_MASTER",     "Mistrzowska uczta")                -- [pl.lang.csv] "52420949","0","5977","xxxxxxxx"
ZO_CreateStringId("DP_CRAFTING_WITCH",      "Zlecenie Festiwalu Wiedźm")        -- [pl.lang.csv] "52420949","0","6427","xxxxxxxx"
ZO_CreateStringId("DP_CRAFTING_EVENT1",     "Datek charytatywny")               -- [pl.lang.csv] "52420949","0","6327","xxxxxxxx"
ZO_CreateStringId("DP_CRAFTING_EVENT1BOOK", "Cesarskie zlecenie charytatywne")  -- [pl.lang.csv] "242841733","0","167169","xxxxxxxx"

ZO_CreateStringId("DP_BULK_HEADER",         "Tworzenie masowe")
ZO_CreateStringId("DP_BULK_FLG",            "Utwórz wszystkie żądane elementy za jednym razem")
ZO_CreateStringId("DP_BULK_FLG_TOOLTIP",    "Jest on używany, gdy chcesz utworzyć dużą liczbę żądanych elementów.")
ZO_CreateStringId("DP_BULK_COUNT",          "Ilość utworzona")
ZO_CreateStringId("DP_BULK_COUNT_TOOLTIP",  "W rzeczywistości powstanie ich więcej niż ta ilość.(Zależy od umiejętności Szefa Kuchni/Piwowara)")

ZO_CreateStringId("DP_CRAFT_WRIT",          "Rzemiosło Zapieczętowane Pismo")
ZO_CreateStringId("DP_CRAFT_WRIT_MSG",      "Przy dostępie do stacji alchemicznej, <<1>>")
ZO_CreateStringId("DP_CANCEL_WRIT",         "Anulowanie zapieczętowanego pisma procesowego")
ZO_CreateStringId("DP_CANCEL_WRIT_MSG",     "Anulowane, zapieczętowane pismo procesowe")

ZO_CreateStringId("DP_OTHER_HEADER",        "Inne")
ZO_CreateStringId("DP_ACQUIRE_ITEM",        "Pobieranie pozycji z banku")
ZO_CreateStringId("DP_DELAY",               "Czas opóźnienia")
ZO_CreateStringId("DP_DELAY_TOOLTIP",       "Czas opóźnienia w pobraniu elementu (sek)\nJeśli nie możesz dobrze wyjąć przedmiotu, zwiększ go.")
ZO_CreateStringId("DP_AUTO_EXIT",           "Automatyczne wyjście")
ZO_CreateStringId("DP_AUTO_EXIT_TOOLTIP",   "Po wykonaniu dziennego pisma automatycznie opuścisz stół do craftingu.")
ZO_CreateStringId("DP_DONT_KNOW",           "Wyłączenie automatycznego tworzenia, jeśli receptura jest nieznana")
ZO_CreateStringId("DP_DONT_KNOW_TOOLTIP",   "Jeśli jeden z przepisów wymaganych do ukończenia pisma jest nieznany Twojej postaci, to żadne przedmioty nie zostaną automatycznie stworzone.")
ZO_CreateStringId("DP_LOG",                 "Pokaż dziennik")
ZO_CreateStringId("DP_DEBUG_LOG",           "Pokaż dziennik debugowania")

ZO_CreateStringId("DP_UNKNOWN_RECIPE",      " Przepis [<<1>>] jest nieznany. Nie zostały utworzone żadne pozycje.")
ZO_CreateStringId("DP_MISMATCH_RECIPE",     " ... [Błąd]Nazwa przepisu nie pasuje (<<1>>)")
ZO_CreateStringId("DP_NOTHING_RECIPE",      " ... Nie mam przepisu")
ZO_CreateStringId("DP_SHORT_OF",            " ... Brak materiałów (<<1>>)")




function DailyProvisioning:ConvertedItemNameForDisplay(itemName)
    return itemName
end

function DailyProvisioning:ConvertedItemNames(itemName)
    local list = {
        {"%-",   " "},
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
        {"\n",  ""},
        {"%-",  " "},

        -- Master Writ(Create from context menu)
        {"Użyj, .+:Wytwórz: (.*)",      "Wytwórz [%1]"},

        -- Master Writ(in Journal)
        {"Wytwórz:..(.*)... Postęp:",   "Wytwórz [%1]"},

        -- Dayly
        {"Wytwórz: (.*):",              "Wytwórz [%1]"},

    }
    local convertedCondition = journalCondition
    for _, value in ipairs(list) do
        convertedCondition = string.gsub(convertedCondition, value[1], value[2])
    end
    return convertedCondition
end

function DailyProvisioning:CraftingConditions()
    local list = {
        "Wytwórz ",
    }
    return list
end

function DailyProvisioning:isProvisioning(journalCondition)
    local list = {
        "z następującymi właściwościami",   -- [pl_client.str] SI_MASTER_WRIT_QUEST_ALCHEMY_FORMAT_STRING = "Wytwórz: <<1>> z następującymi właściwościami:<<2>><<3>><<4>>\n• Postęp"
        "Kowale sprzedają ten diagram",     -- [pl.lang.csv] "7949764","0","61966","xxxxxxxx","Kowale sprzedają ten diagram"
        "Sukiennicy sprzedają ten wzór",    -- [pl.lang.csv] "7949764","0","61968","xxxxxxxx","Sukiennicy sprzedają ten wzór"
        "Stolarze sprzedają ten plan",      -- [pl.lang.csv] "7949764","0","61970","xxxxxxxx","Stolarze sprzedają ten plan"
        "Stolarze sprzedają ten diagram",   -- [pl.lang.csv] "7949764","0","68075","xxxxxxxx","Stolarze sprzedają ten diagram"
    }
    return not self:Contains(journalCondition, list)
end

