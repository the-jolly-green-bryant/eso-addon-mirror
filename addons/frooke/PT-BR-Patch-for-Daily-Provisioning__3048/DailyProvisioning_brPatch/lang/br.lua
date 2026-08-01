------------------------------------------------
-- Brazilian localization for DailyProvisioning
------------------------------------------------

ZO_CreateStringId("DP_CRAFTING_QUEST",      "Ordens de Culinária")             -- [en.lang.csv] "52420949","0","5409","xxxxxxxx"
ZO_CreateStringId("DP_CRAFTING_MASTER",     "Uma festa magistral")            -- [en.lang.csv] "52420949","0","5977","xxxxxxxx"
ZO_CreateStringId("DP_CRAFTING_EVENT1",     "Uma contribuição de caridade")    -- [en.lang.csv] "52420949","0","6327","xxxxxxxx"
ZO_CreateStringId("DP_CRAFTING_WITCH",      "Ordem do Festival das Bruxas")        -- [en.lang.csv] "52420949","0","6427","xxxxxxxx"

ZO_CreateStringId("DP_CRAFTING_EVENT1BOOK", "Ordem Imperial de Caridade")        -- [en.lang.csv] "242841733","0","167169","xxxxxxxx"

ZO_CreateStringId("DP_BULK_HEADER",         "Criação em massa")
ZO_CreateStringId("DP_BULK_FLG",            "Crie todos os itens solicitados de uma vez")
ZO_CreateStringId("DP_BULK_FLG_TOOLTIP",    "É usado quando você deseja criar um grande número de itens solicitados.")
ZO_CreateStringId("DP_BULK_COUNT",          "Quantidade criada")
ZO_CreateStringId("DP_BULK_COUNT_TOOLTIP",  "Na verdade, será criado mais do que esta quantidade. (Depende das habilidades do Chef/Cervejeiro)")

ZO_CreateStringId("DP_CRAFT_WRIT",          "Construa Ordem Selada")
ZO_CreateStringId("DP_CRAFT_WRIT_MSG",      "Acessando a Estação de Culinária, <<1>>")
ZO_CreateStringId("DP_CANCEL_WRIT",         "Cancelar Comando Mestre")
ZO_CreateStringId("DP_CANCEL_WRIT_MSG",     "Comando mestre cancelado")

ZO_CreateStringId("DP_OTHER_HEADER",        "De outros")
ZO_CreateStringId("DP_ACQUIRE_ITEM",        "Recuperar itens do banco")
ZO_CreateStringId("DP_DELAY",               "Tempo de atraso")
ZO_CreateStringId("DP_DELAY_TOOLTIP",       "Tempo de atraso para recuperar o item (seg). Se você não pode tirar o item \ndireito, aumente-o.")
ZO_CreateStringId("DP_AUTO_EXIT",           "Saída automática da janela de crafting")
ZO_CreateStringId("DP_AUTO_EXIT_TOOLTIP",   "Saia automaticamente da janela de criação quando tudo estiver pronto.")
ZO_CreateStringId("DP_DONT_KNOW",           "Desative a criação automática se uma receita for desconhecida")
ZO_CreateStringId("DP_DONT_KNOW_TOOLTIP",   "Se uma das receitas necessárias para completar a escrita for desconhecida para o seu personagem, nenhum item será criado automaticamente.")
ZO_CreateStringId("DP_LOG",                 "Ver log")
ZO_CreateStringId("DP_DEBUG_LOG",           "Ver o log de depuração")

ZO_CreateStringId("DP_UNKNOWN_RECIPE",      " Receitas [<<1>>] é desconhecida. Nenhum item foi criado.")
ZO_CreateStringId("DP_MISMATCH_RECIPE",     " ... [Erro]Receita não corresponde (<<1>>)")
ZO_CreateStringId("DP_NOTHING_RECIPE",      " ... Não tem uma receita")
ZO_CreateStringId("DP_SHORT_OF",            " ... Falta de materiais (<<1>>)")



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
        {".+:Fabrique um%w* (.*)",              "Fabrique [%1]"},

        -- Master Writ(in Journal)
        {"Fabrique um%w* (.*)...%sProgresso:",   "Fabrique [%1]"},

        -- Dayly
        {"Fabrique (.*):",                     "Fabrique [%1]"},
		{"Fabrique (.*):",                     "Fabrique [%1]"},
    }

    local convertedCondition = journalCondition
    for _, value in ipairs(list) do
        convertedCondition = string.gsub(convertedCondition, value[1], value[2])
    end
    return convertedCondition
end

function DailyProvisioning:CraftingConditions()
    local list = {
        "Fabricar ",
		"Criar ",
		"Produzir ",
		"Preparar ",
		"Fabrique",
		"Produza",
    }
    return list
end

function DailyProvisioning:isProvisioning(journalCondition)
    local list = {
        "Fabrique .* com os seguintes traços: *",  -- SI_MASTER_WRIT_QUEST_ALCHEMY_FORMAT_STRING
        "Os comerciantes de ferreiro vendem isto .*",    -- [en.lang.csv] "7949764","0","61966","xxxxxxxx"
        "Comerciantes de Alfaiataria vendem isso .*",      -- [en.lang.csv] "7949764","0","61968","xxxxxxxx"
        "Comerciantes de Marcenaria vendem isto .*",     -- [en.lang.csv] "7949764","0","61970","xxxxxxxx"
        "Marceneiros vendem isso .*",              -- [en.lang.csv] "7949764","0","68075","xxxxxxxx"
    }
    return not self:Contains(journalCondition, list)
end

