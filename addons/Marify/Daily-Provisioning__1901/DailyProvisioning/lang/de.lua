------------------------------------------------
-- German localization for DailyProvisioning
------------------------------------------------

ZO_CreateStringId("DP_CRAFTING_QUEST",      "Versorgerschrieb")                   -- [de.lang.csv] "52420949","0","5409","xxxxxxxx"
ZO_CreateStringId("DP_CRAFTING_MASTER",     "Ein meisterhaftes Mahl")             -- [de.lang.csv] "52420949","0","5977","xxxxxxxx"
ZO_CreateStringId("DP_CRAFTING_WITCH",      "Hexenfestschrieb")                   -- [de.lang.csv] "52420949","0","6427","xxxxxxxx"
ZO_CreateStringId("DP_CRAFTING_EVENT1",     "Eine wohltätige Unternehmung")       -- [de.lang.csv] "52420949","0","6327","xxxxxxxx"
ZO_CreateStringId("DP_CRAFTING_EVENT1BOOK", "kaiserlicher Wohltätigkeitsschrieb") -- [de.lang.csv] "242841733","0","167169","xxxxxxxx"

ZO_CreateStringId("DP_BULK_HEADER",         "Massenerstellung")
ZO_CreateStringId("DP_BULK_FLG",            "Créer de nombreux médicaments et poisons")
ZO_CreateStringId("DP_BULK_FLG_TOOLTIP",    "Es wird verwendet, wenn Sie eine große Anzahl angeforderter Elemente erstellen möchten.")
ZO_CreateStringId("DP_BULK_COUNT",          "Zu erstellende Menge")
ZO_CreateStringId("DP_BULK_COUNT_TOOLTIP",  "In der Tat wird es mehr als diese Menge erstellt werden.(Hängt von Kochkunst/Braukunst-Fähigkeiten ab)")

ZO_CreateStringId("DP_CRAFT_WRIT",          "Craft Versiegelter Meisterschrieb")
ZO_CreateStringId("DP_CRAFT_WRIT_MSG",      "Beim Zugriff auf den Feuerstelle, <<1>>")
ZO_CreateStringId("DP_CANCEL_WRIT",         "Versiegelter Meisterschrieb abbrechen")
ZO_CreateStringId("DP_CANCEL_WRIT_MSG",     "Stornierte Versiegelter Meisterschrieb")

ZO_CreateStringId("DP_OTHER_HEADER",        "Andere")
ZO_CreateStringId("DP_ACQUIRE_ITEM",        "Gegenstände von der Bank abholen")
ZO_CreateStringId("DP_DELAY",               "Verzögerungszeit(Sekunden)")
ZO_CreateStringId("DP_DELAY_TOOLTIP",       "Verzögerungszeit zum Abrufen des Elements\nWenn Sie den Gegenstand nicht gut herausnehmen können, erhöhen Sie ihn.")
ZO_CreateStringId("DP_AUTO_EXIT",           "Automatischer Austritt aus dem Crafting-Fenster")
ZO_CreateStringId("DP_AUTO_EXIT_TOOLTIP",   "Automatischer Austritt aus dem Crafting-Fenster, wenn alles abgeschlossen ist.")
ZO_CreateStringId("DP_DONT_KNOW",           "Deaktivieren Autocrafting,wenn Rezept nicht kennen")
ZO_CreateStringId("DP_DONT_KNOW_TOOLTIP",   "Wir kochen zwei Rezepte auf eine tägliche Anfrage, aber wenn Sie kein Rezept kennen, wird es nicht automatisch erstellt.")
ZO_CreateStringId("DP_LOG",                 "Protokoll anzeigen")
ZO_CreateStringId("DP_DEBUG_LOG",           "Debug-Protokoll anzeigen")

ZO_CreateStringId("DP_UNKNOWN_RECIPE",      " Rezept [<<1>>] ist unbekannt. Der Artikel wurde nicht erstellt.")
ZO_CreateStringId("DP_MISMATCH_RECIPE",     " ... [Fehler]Rezeptname stimmt nicht überein (<<1>>)")
ZO_CreateStringId("DP_NOTHING_RECIPE",      " ... Keinen Rezept haben")
ZO_CreateStringId("DP_SHORT_OF",            " ... Mangel an Materialien (<<1>>)")




function DailyProvisioning:ConvertedItemNameForDisplay(itemName)
    return itemName:gsub("(\^).*", ""):gsub("(\|).*", "")
end

function DailyProvisioning:ConvertedItemNames(itemName)

    local list = {
        {"%-",   " "},
        {"%^.*", ""},
        {"ﻻ",    " "}, -- A piece of BOM ? (239)
        {"Ä",    "A"}, -- Replace Umlaut
        {"ä",    "a"}, -- Replace Umlaut
        {"ö",    "o"}, -- Replace Umlaut
        {"ü",    "u"}, -- Replace Umlaut
    }

    local convertedItemName = itemName
    for _, value in ipairs(list) do
        convertedItemName = string.gsub(convertedItemName, value[1], value[2])
    end


    local convertedItemName2 = convertedItemName
    local list2 = {
        {"atherischer Tee",          "Atherischen Tee"},
        {"bretonische Fleischwurst", "Bretonische Fleischwurst"},
        {"eltherischer Fusel",       "eltherischen Fusel"},
        {"heiliger Strohsack",       "Heiligen Strohsack"},
        {"klarer Syrahwein",         "Klaren Syrahwein"},
        {"knuspriger Spinnenspieß",  "knusprigen Spinnenspieß"},
    }
    for _, value in ipairs(list2) do
        convertedItemName2 = string.gsub(convertedItemName2, value[1], value[2])
    end

    if convertedItemName == convertedItemName2 then
        return {convertedItemName}
    else
        return {convertedItemName, convertedItemName2}
    end
end

function DailyProvisioning:ConvertedJournalCondition(journalCondition)

    local list = {
        {"Ä",       "A"},   -- Replace Umlaut
        {"ä",       "a"},   -- Replace Umlaut
        {"ö",       "o"},   -- Replace Umlaut
        {"ü",       "u"},   -- Replace Umlaut
        {"\n",      ""},
        {" ",       " "},   -- code(0xA0) > space(0x20): HTML non-breaking space ?("0xC2 0xA0")
        {"%-",      " "},
    }
    journalCondition = string.lower(journalCondition)
    for _, value in ipairs(list) do
        journalCondition = string.gsub(journalCondition, value[1], value[2])
    end


    local list2 = {
        -- Master Writ
        {".*stellt e%w* (.*) her.",         "Stellt |c88AAFF[%1]|r"},
        {".*stellt (.*) her.",              "Stellt |c88AAFF[%1]|r"},

        -- Dayly
        {".*stellt einige (.*) her%s?:.*",  "Stellt |c88AAFF[%1]|r"},
        {".*stellt etwas (.*) her%s?:.*",   "Stellt |c88AAFF[%1]|r"},
        {".*stellt eine (.*) her%s?:.*",    "Stellt |c88AAFF[%1]|r"},
        {".*stellt ein (.*) her%s?:.*",     "Stellt |c88AAFF[%1]|r"},
        {".*stellt (.*) her:",              "Stellt |c88AAFF[%1]|r"},
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
        "Stellt ",
    }
    return list
end

function DailyProvisioning:isProvisioning(journalCondition)
    local list = {
        "Stellt .* mit bestimmten Eigenschaften her",   -- SI_MASTER_WRIT_QUEST_ALCHEMY_FORMAT_STRING
        "Schmiedehändler verkaufen diese .*",           -- [de.lang.csv] "7949764","0","61966","xxxxxxxx"
        "Schneiderhändler verkaufen diese .*",          -- [de.lang.csv] "7949764","0","61968","xxxxxxxx"
        "Schreinerhändler verkaufen diese .*",          -- [de.lang.csv] "7949764","0","61970","xxxxxxxx"
        "Schreiner verkaufen diese .*",                 -- [de.lang.csv] "7949764","0","68075","xxxxxxxx"
    }
    return not self:Contains(journalCondition, list)
end
