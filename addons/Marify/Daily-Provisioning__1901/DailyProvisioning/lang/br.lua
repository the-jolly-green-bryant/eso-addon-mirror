------------------------------------------------
-- Brazilian Portuguese localization for DailyProvisioning
------------------------------------------------

ZO_CreateStringId("DP_CRAFTING_QUEST",      "Ordens de Culinária")              -- [br.lang.csv] "52420949","0","5409","xxxxxxxx"
ZO_CreateStringId("DP_CRAFTING_MASTER",     "Um Banquete Magistral")            -- [br.lang.csv] "52420949","0","5977","xxxxxxxx"
ZO_CreateStringId("DP_CRAFTING_WITCH",      "Festival das Bruxas")              -- [br.lang.csv] "52420949","0","6427","xxxxxxxx"
ZO_CreateStringId("DP_CRAFTING_EVENT1",     "Uma Contribuição de Caridade")     -- [br.lang.csv] "52420949","0","6327","xxxxxxxx"
ZO_CreateStringId("DP_CRAFTING_EVENT1BOOK", "Escritura de Caridade Imperial")   -- [br.lang.csv] "242841733","0","167169","xxxxxxxx"

ZO_CreateStringId("DP_BULK_HEADER",         "Criação a granel")
ZO_CreateStringId("DP_BULK_FLG",            "Criar todos os itens solicitados de uma só vez")
ZO_CreateStringId("DP_BULK_FLG_TOOLTIP",    "É usado quando se deseja criar um grande número de itens solicitados.")
ZO_CreateStringId("DP_BULK_COUNT",          "Quantidade criada")
ZO_CreateStringId("DP_BULK_COUNT_TOOLTIP",  "Na verdade, será criado mais do que esta quantidade (Depende das habilidades do Chef/Chef de cozinha)")

ZO_CreateStringId("DP_CRAFT_WRIT",          "Escrita Artesanal Selada")
ZO_CreateStringId("DP_CRAFT_WRIT_MSG",      "Ao acessar a estação de alquimia, <<1>>")
ZO_CreateStringId("DP_CANCEL_WRIT",         "Cancelar Escrita Selada")
ZO_CreateStringId("DP_CANCEL_WRIT_MSG",     "Escrito Selado Cancelado")

ZO_CreateStringId("DP_OTHER_HEADER",        "Outros")
ZO_CreateStringId("DP_ACQUIRE_ITEM",        "Recuperar itens do banco")
ZO_CreateStringId("DP_DELAY",               "Tempo de atraso")
ZO_CreateStringId("DP_DELAY_TOOLTIP",       "Tempo de atraso para recuperar o item(seg)\nSe você não conseguir retirar bem o item, aumente-o.")
ZO_CreateStringId("DP_AUTO_EXIT",           "Saída automática")
ZO_CreateStringId("DP_AUTO_EXIT_TOOLTIP",   "Você deixará automaticamente a mesa de artesanato após completar o escrito diário.")
ZO_CreateStringId("DP_DONT_KNOW",           "Desativar a criação automática se uma receita for desconhecida")
ZO_CreateStringId("DP_DONT_KNOW_TOOLTIP",   "Se uma das receitas necessárias para completar a escrita for desconhecida para o seu personagem, então nenhum item será criado automaticamente.")
ZO_CreateStringId("DP_LOG",                 "Mostrar log")
ZO_CreateStringId("DP_DEBUG_LOG",           "Mostrar registro de depuração")

ZO_CreateStringId("DP_UNKNOWN_RECIPE",      " A receita [<<<1>>] é desconhecida. Nenhum item foi criado.")
ZO_CreateStringId("DP_MISMATCH_RECIPE",     " ... [Erro]O nome da receita não corresponde (<<1>>)")
ZO_CreateStringId("DP_NOTHING_RECIPE",      " ... Não tenho uma receita")
ZO_CreateStringId("DP_SHORT_OF",            " ... Falta de materiais (<<1>>)")




function DailyProvisioning:ConvertedItemNameForDisplay(itemName)
    return itemName
end

function DailyProvisioning:ConvertedItemNames(itemName)
    local list = {
        {" ",  " "},   -- code(0xA0) > space(0x20): HTML non-breaking space ?("0xC2 0xA0")
        {"%-",   " "},
        {"%^.*", ""},
        {"á",    "a"},
        {"ã",    "a"},
        {"ç",    "c"},
        {"ú",    "u"},
        {"í",    "i"},
        {"ê",    "e"},
        {"é",    "e"},
        {"ô",    "o"},
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
        {"ã",  "a"},
        {"ç",  "c"},
        {"ú",  "u"},
        {"í",  "i"},
        {"ê",  "e"},
        {"é",  "e"},
        {"ô",  "o"},
    }
    journalCondition = string.lower(journalCondition)
    for _, value in ipairs(list) do
        journalCondition = string.gsub(journalCondition, value[1], value[2])
    end


    local list2 = {
        -- Master Writ(Create from context menu)
        {".+:craft a%w* (.*)",              "Fabricar |c88AAFF[%1]|r"},
        {".+:fabrique u%w+ (.*)",           "Fabricar |c88AAFF[%1]|r"},
        {".+:fabricar u%w+ (.*)",           "Fabricar |c88AAFF[%1]|r"},

        -- Master Writ(in Journal)
        {"craft a%w* (.*)...%sprogress:",   "Fabricar |c88AAFF[%1]|r"},
        {"fabricar u%w+ (.*)• progresso:",  "Fabricar |c88AAFF[%1]|r"},

        -- Dayly
        {".*fabricar (.*):.*",              "Fabricar |c88AAFF[%1]|r"},
        {".*fabricar (.*)",                 "Fabricar |c88AAFF[%1]|r"},
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
        "Fabricar",
    }
    return list
end

function DailyProvisioning:isProvisioning(journalCondition)
    local list = {
        "Fabrique u%w+ .* com os seguintes traços",             -- [br_client.str] SI_MASTER_WRIT_QUEST_ALCHEMY_FORMAT_STRING = "Fabrique <<1{um/uma}>> <<1>> com os seguintes traços:<<2>><<3>><<4>>\n• Progresso"
        "Comerciantes de Ferraria vendem este Diagrama",        -- [br.lang.csv] "7949764","0","61966","xxxxxxxx","Comerciantes de Ferraria vendem este Diagrama"
        "Comerciantes de costura vendem este Padrao",           -- [br.lang.csv] "7949764","0","61968","xxxxxxxx","Comerciantes de costura vendem este Padrão"
        "Os comerciantes do Carpintaria vendem este Esquema",   -- [br.lang.csv] "7949764","0","61970","xxxxxxxx","Os comerciantes do Carpintaria vendem este Esquema"
        "Carpenters sell this Diagram",                         -- [br.lang.csv] "7949764","0","68075","xxxxxxxx","Carpenters sell this Diagram"
    }
    return not self:Contains(journalCondition, list)
end

