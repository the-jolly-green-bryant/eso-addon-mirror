------------------------------------------------
-- French localization for DailyProvisioning
------------------------------------------------

ZO_CreateStringId("DP_CRAFTING_QUEST",      "Commande de cuisine")              -- [fr.lang.csv] "52420949","0","5409","xxxxxxxx"
ZO_CreateStringId("DP_CRAFTING_MASTER",     "Un festin magistral")              -- [fr.lang.csv] "52420949","0","5977","xxxxxxxx"
ZO_CreateStringId("DP_CRAFTING_WITCH",      "Festival des sorcières")           -- [fr.lang.csv] "52420949","0","6427","xxxxxxxx"
ZO_CreateStringId("DP_CRAFTING_EVENT1",     "Une contribution charitable")      -- [fr.lang.csv] "52420949","0","6327","xxxxxxxx"
ZO_CreateStringId("DP_CRAFTING_EVENT1BOOK", "commande caritative impériale")    -- [fr.lang.csv] "242841733","0","167169","xxxxxxxx"

ZO_CreateStringId("DP_BULK_HEADER",         "Création en bloc")
ZO_CreateStringId("DP_BULK_FLG",            "Créer tous les éléments demandés à la fois")
ZO_CreateStringId("DP_BULK_FLG_TOOLTIP",    "Utilisez-le lorsque vous souhaitez créer une grande quantité d'éléments demandés.")
ZO_CreateStringId("DP_BULK_COUNT",          "Quantité à créer")
ZO_CreateStringId("DP_BULK_COUNT_TOOLTIP",  "En fait, plus que cette quantité sera faite.(Dépend des compétences de Chef/Brasserie)")

ZO_CreateStringId("DP_CRAFT_WRIT",          "Artisanat Commande de maître")
ZO_CreateStringId("DP_CRAFT_WRIT_MSG",      "En accédant au Feu de cuisine, <<1>>")
ZO_CreateStringId("DP_CANCEL_WRIT",         "Annuler Commande de maître")
ZO_CreateStringId("DP_CANCEL_WRIT_MSG",     "Annulé Commande de maître")

ZO_CreateStringId("DP_OTHER_HEADER",        "Autre")
ZO_CreateStringId("DP_ACQUIRE_ITEM",        "Récupérer des articles de la banque")
ZO_CreateStringId("DP_DELAY",               "Temps de retard(secondes)")
ZO_CreateStringId("DP_DELAY_TOOLTIP",       "Délai de récupération de l'élément\nSi vous ne parvenez pas à bien sortir l'objet, augmentez-le.")
ZO_CreateStringId("DP_AUTO_EXIT",           "Sortie automatique de la fenêtre d'artisanat")
ZO_CreateStringId("DP_AUTO_EXIT_TOOLTIP",   "Sortie automatique de la fenêtre d'artisanat lorsque tout est terminé.")
ZO_CreateStringId("DP_DONT_KNOW",           "Désactiver la création automatique si vous ne connaissez pas la recette")
ZO_CreateStringId("DP_DONT_KNOW_TOOLTIP",   "Nous cuisinons deux recettes sur une demande quotidienne, mais si vous ne connaissez aucune recette, celle-ci ne sera pas créée automatiquement.")
ZO_CreateStringId("DP_LOG",                 "Afficher le journal")
ZO_CreateStringId("DP_DEBUG_LOG",           "Afficher le journal de débogage")

ZO_CreateStringId("DP_UNKNOWN_RECIPE",      " La recette [<<1>>] est inconnue. L'élément n'a pas été créé.")
ZO_CreateStringId("DP_MISMATCH_RECIPE",     " ... [Erreur]Le nom de la recette ne correspond pas (<<1>>)")
ZO_CreateStringId("DP_NOTHING_RECIPE",      " ... Ne pas avoir de Recette")
ZO_CreateStringId("DP_SHORT_OF",            " ... court de matériaux (<<1>>)")




function DailyProvisioning:ConvertedItemNameForDisplay(itemName)
    return itemName:gsub("(\^).*", ""):gsub("(\|).*", "")
end

function DailyProvisioning:ConvertedItemNames(itemName)

    local function Convert(inItemName)
        local inList = {
            {"(\^%a%a)$",   ""},
            {"(\^%a)$",     ""},
            {"(\^%a%a)\|",  ""},
            {"(\^%a)\|",    ""},
            {"⸗",           " "},   -- code(0xE2) > space(0x20)
            {" ",           " "},   -- NO-BREAK SPACE(U+00A0) to SPACE (U+0020)
            {"%-",          " "},
            {"é",           "e"},
            {"è",           "e"},
            {"ê",           "e"},
            {"â",           "a"},
            {"à",           "a"},
            {"ï",           "i"},
        }
        for _, value in ipairs(inList) do
            inItemName = string.gsub(inItemName, value[1], value[2])
        end
        return inItemName
    end


    local function Convert2(inItemName)
        local inList = {
        }
        for _, value in ipairs(inList) do
            inItemName = string.gsub(inItemName, value[1], value[2])
        end
        return inItemName
    end


    if string.match(itemName, "(\|)") then
        local itemName1 = Convert(itemName:gsub("(\|)[%a%s%p]*", ""))
        local itemName2 = Convert(itemName:gsub("[%a%s%p]*(\|)", ""))
        local list = {}

        local convertedItemName1 = Convert2(itemName1)
        if convertedItemName1 == itemName1 then
            list[#list + 1] = itemName1
        else
            list[#list + 1] = convertedItemName1
            list[#list + 1] = itemName1
        end

        local convertedItemName2 = Convert2(itemName2)
        if convertedItemName2 == itemName2 then
            list[#list + 1] = itemName2
        else
            list[#list + 1] = convertedItemName2
            list[#list + 1] = itemName2
        end

        return list
    else
        itemName = Convert(itemName)
        local convertedItemName = Convert2(itemName)
        if convertedItemName == itemName then
            return {itemName}
        else
            return {itemName, convertedItemName}
        end
    end
end

function DailyProvisioning:ConvertedJournalCondition(journalCondition)
    local list = {
        {"⸗",   " "},   -- code(0xE2) > space(0x20)
        {" ",   " "},   -- NO-BREAK SPACE(U+00A0) to SPACE (U+0020)
        {"%-",  " "},
        {"é",   "e"},
        {"è",   "e"},
        {"ê",   "e"},
        {"â",   "a"},
        {"à",   "a"},
        {"ï",   "i"},
    }
    journalCondition = string.lower(journalCondition)
    for _, value in ipairs(list) do
        journalCondition = string.gsub(journalCondition, value[1], value[2])
    end


    local list2 = {
        -- Master Writ
        {".*fabriquez un%w? (.*)...%sProgression :",    "Preparez |c88AAFF[%1]|r"},
        {".*fabriquez un%w? (.*)",                      "Preparez |c88AAFF[%1]|r"},
        {".*fabriquez des (.*)",                        "Preparez |c88AAFF[%1]|r"},

        -- Dayly
        {"preparez un%w? (.*) :.*",                     "Preparez |c88AAFF[%1]|r"},
        {"preparez un%w? (.*):.*",                      "Preparez |c88AAFF[%1]|r"},
        {"preparez des (.*):.*",                        "Preparez |c88AAFF[%1]|r"},
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
        "Preparez ",
    }
    return list
end

function DailyProvisioning:isProvisioning(journalCondition)
    local list = {
        "Fabriquez .* avec les traits suivants",            -- SI_MASTER_WRIT_QUEST_ALCHEMY_FORMAT_STRING
        "Les marchands de forge vendent ce .*",             -- [fr.lang.csv] "7949764","0","61966","xxxxxxxx"
        "Les marchands de couture vendent ce .*",           -- [fr.lang.csv] "7949764","0","61968","xxxxxxxx"
        "Les marchands de travail du bois vendent ce plan", -- [fr.lang.csv] "7949764","0","61970","xxxxxxxx"
        "Ce .* est vendu par des travailleurs du bois",     -- [fr.lang.csv] "7949764","0","68075","xxxxxxxx"
    }
    return not self:Contains(journalCondition, list)
end

