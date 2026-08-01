------------------------------------------------
-- Brazilian localization for DailyAlchemy
------------------------------------------------

ZO_CreateStringId("DA_CRAFTING_QUEST",      "Ordem de Alquimia")       
ZO_CreateStringId("DA_CRAFTING_MASTER",     "Uma mistura magistral") 
ZO_CreateStringId("DA_CRAFTING_WITCH",      "Festival de bruxas")   

ZO_CreateStringId("DA_BULK_HEADER",         "Criação em massa")
ZO_CreateStringId("DA_BULK_FLG",            "Crie todos os itens solicitados de uma vez")
ZO_CreateStringId("DA_BULK_FLG_TOOLTIP",    "Use-o quando quiser criar uma grande quantidade de itens solicitados.")
ZO_CreateStringId("DA_BULK_COUNT",          "Quantidade para criar	")
ZO_CreateStringId("DA_BULK_COUNT_TOOLTIP",  "Na verdade, mais do que essa quantia será feita. (Depende das habilidades de alquimia)")

ZO_CreateStringId("DA_CRAFT_WRIT",          "Construa Ordem Selada")
ZO_CreateStringId("DA_CRAFT_WRIT_MSG",      "Acessando a Estação de Alquimia, <<1>>")
ZO_CreateStringId("DA_CANCEL_WRIT",         "Cancelar Comando Mestre")
ZO_CreateStringId("DA_CANCEL_WRIT_MSG",     "Comando mestre cancelado")

ZO_CreateStringId("DA_PRIORITY_HEADER",     "Prioridade do reagente")
ZO_CreateStringId("DA_PRIORITY_BY",         "Prioridade do reagente a ser usado")
ZO_CreateStringId("DA_PRIORITY_BY_STOCK",   "Beaucoup d'inventaire")
ZO_CreateStringId("DA_PRIORITY_BY_MM",      "Reagente de baixo custo em [MasterMerchant]")
ZO_CreateStringId("DA_PRIORITY_BY_TTC",     "Reagente de baixo custo em [TamrielTradeCentre]")
ZO_CreateStringId("DA_PRIORITY_BY_ATT",     "Reagente de baixo custo em [ArkadiusTradeTools]")
ZO_CreateStringId("DA_PRIORITY_BY_MANUAL",  "Definir manualmente")
ZO_CreateStringId("DA_SHOW_PRICE_MANUAL",   "Mostrar preço[<<1>>]")
ZO_CreateStringId("DA_PRIORITY_CHANGED",    "O parâmetro de extensão [<<1>>] foi alterado porque <<2>> está desabilitado")

ZO_CreateStringId("DA_OTHER_HEADER",        "De outros")
ZO_CreateStringId("DA_ACQUIRE_ITEM",        "Colete itens do banco")
ZO_CreateStringId("DA_DELAY",               "Tempo de atraso (segundos)")
ZO_CreateStringId("DA_DELAY_TOOLTIP",       "Tempo de recuperação do item\nSe você não conseguir tirar o objeto bem, aumente-o.")
ZO_CreateStringId("DA_AUTO_EXIT",           "Saída automática da janela de crafting")
ZO_CreateStringId("DA_AUTO_EXIT_TOOLTIP",   "Saia automaticamente da janela de criação quando tudo estiver pronto.")
ZO_CreateStringId("DA_ITEM_LOCK",           "Não use objetos bloqueados")
ZO_CreateStringId("DA_LOG",                 "Ver log")
ZO_CreateStringId("DA_DEBUG_LOG",           "Ver o log de depuração")

ZO_CreateStringId("DA_NOTHING_ITEM",        "Nenhum item na mochila (<<1>>)")
ZO_CreateStringId("DA_SHORT_OF",            "... falta de materiais(<<1>>)")
ZO_CreateStringId("DA_MISMATCH_ITEM",       "... [Erro]Nome não corresponde (<<1>>)")

ZO_CreateStringId("DA_HEALTH",              "Restaura Saúde")                 -- Restore Health        
ZO_CreateStringId("DA_RVG_HEALTH",          "Devastar saúde")                  -- Ravage Health    
ZO_CreateStringId("DA_MAGICKA",             "Restaura Magicka")                 -- Restore Magicka 
ZO_CreateStringId("DA_RVG_MAGICKA",         "Devastar Magicka")                  -- Ravage Magicka  
ZO_CreateStringId("DA_STAMINA",             "Restaura Vigor")               -- Restore Stamina  
ZO_CreateStringId("DA_RVG_STAMINA",         "Devastar Vigor")                -- Ravage Stamina  
ZO_CreateStringId("DA_SPELL_RESIST",        "Aumenta a Resistência a Feitiços") -- Increase Spell Resist 
ZO_CreateStringId("DA_BREACH",              "Violação")                           -- Breach     
ZO_CreateStringId("DA_ARMOR",               "Aumentar armadura")                -- Increase Armor   
ZO_CreateStringId("DA_FRACTURE",            "Fratura")                         -- Fracture         
ZO_CreateStringId("DA_SPELL_POWER",         "Aumenta a Potência dos Feitiços")  -- Increase Spell Power 
ZO_CreateStringId("DA_COWARDICE",           "Covardia")                        -- Cowardice           
ZO_CreateStringId("DA_WEAPON_POWER",        "Aumenta a Potência das Armas")  -- Increase Weapon Power 
ZO_CreateStringId("DA_MAIM",                "Mutilação")                       -- Maim               
ZO_CreateStringId("DA_SPELL_CRIT",          "Crítico de Feitiços")                -- Spell Critical  
ZO_CreateStringId("DA_UNCERTAINTY",         "Incerteza")                      -- Uncertainty          
ZO_CreateStringId("DA_WEAPON_CRIT",         "Crítico de Armas")                 -- Weapon Critical    
ZO_CreateStringId("DA_ENERVATE",            "Exaustão")                  -- Enervation        
ZO_CreateStringId("DA_UNSTOP",              "Imparável")                       -- Unstoppable       
ZO_CreateStringId("DA_ENTRAPMENT",          "Captura")                          -- Entrapment        
ZO_CreateStringId("DA_DETECTION",           "Detecção")                     -- Detection           
ZO_CreateStringId("DA_INVISIBLE",           "Invisível")                        -- Invisible        
ZO_CreateStringId("DA_SPEED",               "Velocidade")                          -- Speed    
ZO_CreateStringId("DA_HINDRANCE",           "Obstáculo")                          -- Hindrance     
ZO_CreateStringId("DA_PROTECTION",          "Proteção")                       -- Protection          
ZO_CreateStringId("DA_VULNERABILITY",       "Vulnerabilidade")                    -- Vulnerability       
ZO_CreateStringId("DA_LGR_HEALTH",          "Prolongada de Saúde ")                -- Lingering Health    
ZO_CreateStringId("DA_GR_RVG_HEALTH",       "redução gradual de saúde")          --  RaGradualvage Health 
ZO_CreateStringId("DA_VITALITY",            "Vitalidade")                         -- Vitality
ZO_CreateStringId("DA_DEFILE",              "Profanação")                      -- Defile               
ZO_CreateStringId("DA_HEROISM",             "Heroismo")                         -- Heroism          
ZO_CreateStringId("DA_TIMIDITY",            "Timidez")                         -- Timidity          




function DailyAlchemy:AcquireConditions()
    local list = {
		"Fabri%s(.*)",
        "Fabricar%s(.*)",
		"Fabrique%s(.*)",
		"Adquirir%s(.*)",
		"Adqui%s(.*)",
		   
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
        {"panaceia ", "Panaceia "},   -- Some users have string.lower() disabled?
        {" saúde",  " Saúde"},    -- Some users have string.lower() disabled?
        {" vigor", " Vigor"},   -- Some users have string.lower() disabled?
    }

    local convertedItemName = itemName
    for _, value in ipairs(list) do
        convertedItemName = string.gsub(convertedItemName, value[1], value[2])
    end
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
        {"panaceia ",     "Panaceia "},   -- Some users have string.lower() disabled?
        {" saúde",      " Saúde"},    -- Some users have string.lower() disabled?
        {" vigor",     " Vigor"},   -- Some users have string.lower() disabled?

        {"(Fabricar.*)with.*Traits:%c•(.*)%c•(.*)%c•(.*)%c•.*",  "%1...%2, %3, %4"},
		{"(Fabrique.*)with.*Traits:%c•(.*)%c•(.*)%c•(.*)%c•.*",  "%1...%2, %3, %4"},
		{"(Fabricar um.*)with.*Traits:%c•(.*)%c•(.*)%c•(.*)%c•.*",  "%1...%2, %3, %4"},
		{"(Fabrique um.*)with.*Traits:%c•(.*)%c•(.*)%c•(.*)%c•.*",  "%1...%2, %3, %4"},
		{"(Fabricar uma.*)with.*Traits:%c•(.*)%c•(.*)%c•(.*)%c•.*",  "%1...%2, %3, %4"},
		{"(Fabrique uma.*)with.*Traits:%c•(.*)%c•(.*)%c•(.*)%c•.*",  "%1...%2, %3, %4"},
        {".*(Fabricar.*)with.*properties:(.*)",                  "%1...%2"},
		{".*(Fabrique.*)with.*properties:(.*)",                  "%1...%2"},
		{".*(Fabricar um.*)with.*properties:(.*)",                  "%1...%2"},
		{".*(Fabrique um.*)with.*properties:(.*)",                  "%1...%2"},
		{".*(Fabricar uma.*)with.*properties:(.*)",                  "%1...%2"},
		{".*(Fabrique uma.*)with.*properties:(.*)",                  "%1...%2"},
		{".*(Fabricar um.*)with.*properties:(.*)",                  "%1...%2"},
		{".*(Fabrique um.*)with.*properties:(.*)",                  "%1...%2"},
        {":.*",                                               ""}, 
    }

    local convertedCondition = journalCondition
    for _, value in ipairs(list) do
        convertedCondition = string.gsub(convertedCondition, value[1], value[2])
    end
    return convertedCondition
end

function DailyAlchemy:CraftingConditions()
    local list = {
        "Fabrique",
		"Fabricar",
        
    }
    return list
end

function DailyAlchemy:isPoison(conditionText)
    return string.match(conditionText, "Veneno")
end

function DailyAlchemy:isAlchemy(journalCondition)
    return string.match(journalCondition, "Fabri .* with the following .*raits")
end