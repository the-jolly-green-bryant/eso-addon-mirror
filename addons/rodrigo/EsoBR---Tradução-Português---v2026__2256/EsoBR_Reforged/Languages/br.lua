-----------------------------------------------------------------------------------
-- EsoBR Reforged — PT-BR language file for Dolgubon's Lazy Writ Crafter
-- Loaded via Languages/$(language).lua in the EsoBR Reforged manifest.
-- Follows the same interface as the native DolgubonsLazyWritCreator language files.
-----------------------------------------------------------------------------------

WritCreater = WritCreater or {}

function WritCreater.langWritNames()
    return {
        ["G"]                           = "Orde",
        [CRAFTING_TYPE_ENCHANTING]      = "Encantamento",
        [CRAFTING_TYPE_BLACKSMITHING]   = "Ferraria",
        [CRAFTING_TYPE_CLOTHIER]        = "Alfaiataria",
        [CRAFTING_TYPE_PROVISIONING]    = "Culin",
        [CRAFTING_TYPE_WOODWORKING]     = "Marcenaria",
        [CRAFTING_TYPE_ALCHEMY]         = "Alquimia",
        [CRAFTING_TYPE_JEWELRYCRAFTING] = "Joalheria",
    }
end

function WritCreater.surveyNames()
    return {
        ["G"]                           = "Orde",
        [CRAFTING_TYPE_ENCHANTING]      = "Encantamento",
        [CRAFTING_TYPE_BLACKSMITHING]   = "Ferraria",
        [CRAFTING_TYPE_CLOTHIER]        = "Alfaiataria",
        [CRAFTING_TYPE_PROVISIONING]    = "Culin",
        [CRAFTING_TYPE_WOODWORKING]     = "Marcenaria",
        [CRAFTING_TYPE_ALCHEMY]         = "Alquimia",
        [CRAFTING_TYPE_JEWELRYCRAFTING] = "Joalheria",
    }
end

function WritCreater.langCraftKernels()
    return {
        [CRAFTING_TYPE_ENCHANTING]      = "Encantamento",
        [CRAFTING_TYPE_BLACKSMITHING]   = "Ferraria",
        [CRAFTING_TYPE_CLOTHIER]        = "Alfaiataria",
        [CRAFTING_TYPE_PROVISIONING]    = "Culin",
        [CRAFTING_TYPE_WOODWORKING]     = "Marcenaria",
        [CRAFTING_TYPE_ALCHEMY]         = "Alquimia",
        [CRAFTING_TYPE_JEWELRYCRAFTING] = "Joalheria",
    }
end

function WritCreater.writCompleteStrings()
    return {
        ["place"]       = "Coloque as mercadorias",
        ["sign"]        = "Assine o Manifesto.",
        ["masterPlace"] = "Eu terminei o",
        ["masterSign"]  = "<Conclua o trabalho.>",
        ["masterStart"] = "<Retire a Ordem do Quadro.>",
        ["Rolis Hlaalu"] = "Rolis Hlaalu",
        ["Deliver"]     = "Entregue",
        ["Acquire"]     = "adquir",
    }
end

function WritCreater.langMasterWritNames()
    return {
        ["M"]                         = "magistral",
        ["M1"]                        = "mestre",
        [CRAFTING_TYPE_ALCHEMY]       = "mistura",
        [CRAFTING_TYPE_ENCHANTING]    = "Glifo",
        [CRAFTING_TYPE_PROVISIONING]  = "celebração",
        ["plate"]                     = "proteção",
        ["tailoring"]                 = "alfaiataria",
        ["leatherwear"]               = "roupa de couro",
        ["weapon"]                    = "arma",
        ["shield"]                    = "escudo",
    }
end

function WritCreater.masterWritQuality()
    return {{"epico", 4}, {"lendario", 5}}
end

function WritCreater.langEssenceNames()
    return {[1] = "Oko", [2] = "Deni", [3] = "Makko"}
end

function WritCreater.langPotencyNames()
    return {
        [1]  = "Jora",   [2]  = "Porade", [3]  = "Jera",   [4]  = "Jejora",
        [5]  = "Odra",   [6]  = "Pojora", [7]  = "Edora",  [8]  = "Jaera",
        [9]  = "Pora",   [10] = "Denara", [11] = "Rera",   [12] = "Derado",
        [13] = "Rekura", [14] = "Kura",   [15] = "Rejera", [16] = "Repora",
    }
end

function WritCreater.langStationNames()
    return {
        ["Estação de Ferraria"]    = 1,
        ["Estação de Alfaiataria"] = 2,
        ["Mesa de Encantamentos"]  = 3,
        ["Estação de Alquimia"]    = 4,
        ["Fogueira"]               = 5,
        ["Estação de Marcenaria"]  = 6,
        ["Estação de Joalheria"]   = 7,
    }
end

function WritCreater.langWritRewardBoxes()
    return {
        [1] = "Recipiente de alquimista",
        [2] = "Cofre do encantador",
        [3] = "Pacote de culinária",
        [4] = "Caixa de ferreiro",
        [5] = "Sacola de alfaiate",
        [6] = "Estojo de marceneiro",
        [7] = "Cofre de joalheria",
        [8] = "Remessa",
    }
end

function WritCreater.getTaString() return "ta" end

function WritCreater.bankExceptions(condition)
    condition = string.gsub(condition, ":", " ")
    return condition
end

function WritCreater.questExceptions(condition)
    return condition
end

function WritCreater.enchantExceptions(condition)
    condition = string.lower(condition)
    condition = string.gsub(condition, "entregue", "delivery")
    return condition
end

function WritCreater.languageInfo()
    return {
        [CRAFTING_TYPE_CLOTHIER] = {
            ["pieces"] = {
                [1]  = "Tunica",      [2]  = "Gibão",       [3]  = "Sapatos",
                [4]  = "Luvas",       [5]  = "Chapeu",      [6]  = "Calções",
                [7]  = "Palas",       [8]  = "Faixa",       [9]  = "Brigantina",
                [10] = "Botas",       [11] = "Braçadeiras", [12] = "Capacete",
                [13] = "Guardas",     [14] = "Ombreiras",   [15] = "Cinto",
            },
            ["match"] = {
                [1]  = "Artesanal",       [2]  = "Linho",          [3]  = "Algodao",
                [4]  = "Sedaracna",       [5]  = "Fio de Ebano",   [6]  = "Kresh",
                [7]  = "Fio Ferroso",     [8]  = "Fio de Prata",   [9]  = "Sombrafiada",
                [10] = "Ancestor",        [11] = "Couro Cru",      [12] = "Pele",
                [13] = "Couro",           [14] = "Couro-Completo", [15] = "Couro Impio",
                [16] = "Brigandina",      [17] = "Pele de Ferro",  [18] = "Pele Soberba",
                [19] = "Umbrapele",       [20] = "Couro Rubedita",
            },
        },
        [CRAFTING_TYPE_BLACKSMITHING] = {
            ["pieces"] = {
                [1]  = "Machado",            [2]  = "Maça",         [3]  = "Espada",
                [4]  = "Machado de Batalha", [5]  = "Malho",        [6]  = "Montante",
                [7]  = "Adaga",              [8]  = "Couraça",      [9]  = "Escarpes",
                [10] = "Manoplas",           [11] = "Elmo",         [12] = "Grevas",
                [13] = "Espaldas",           [14] = "Cinturão",
            },
            ["match"] = {
                [1]  = "Ferro",    [2]  = "Aço",          [3]  = "Oricalco",
                [4]  = "Anões",    [5]  = "Ebano",        [6]  = "Calcinio",
                [7]  = "Galatita", [8]  = "Mercurio",     [9]  = "Aço do Vacuo",
                [10] = "Rubedita",
            },
        },
        [CRAFTING_TYPE_WOODWORKING] = {
            ["pieces"] = {
                [1] = "Arco",   [2] = "Escudo", [3] = "Infernal",
                [4] = "Gelo",   [5] = "Raio",   [6] = "Restauração",
            },
            ["match"] = {
                [1]  = "Bordo",   [2]  = "Carvalho",       [3]  = "Faia",
                [4]  = "Nogueira",[5]  = "Teixo",          [6]  = "Betula",
                [7]  = "Freixo",  [8]  = "Mogno",          [9]  = "Madeira da Noite",
                [10] = "Freixo Rubi",
            },
        },
        [CRAFTING_TYPE_JEWELRYCRAFTING] = {
            ["pieces"] = {[1] = "anel", [2] = "colar"},
            ["match"]  = {
                [1] = "Peltre", [2] = "Cobre", [3] = "Prata",
                [4] = "Electrum", [5] = "Platina",
            },
        },
        [CRAFTING_TYPE_ENCHANTING] = {
            ["pieces"] = {
                {"Resistencia Infecciosa",  45841, 2}, {"Infeccioso",           45841, 1},
                {"Absorver Vigor",           45833, 2}, {"Absorver Magicka",     45832, 2},
                {"Absorcao de Saude",        45831, 2}, {"Resistência ao Gelo",  45839, 2},
                {"Gelo",                     45839, 1}, {"Custo de Vigor",       45836, 2},
                {"Recuperacao de Vigor",     45836, 1}, {"Robustez",             45842, 1},
                {"Esmagador",                45842, 2}, {"Investida",            68342, 2},
                {"Defesa",                   68342, 1}, {"Blindagem",            45849, 2},
                {"Contra-ataque",            45849, 1}, {"Resistência ao Venenoso", 45837, 2},
                {"Dano Venenoso",            45837, 1}, {"Dano Magico",          45848, 2},
                {"magica",                   45848, 1}, {"Recuperacao de Magicka", 45835, 1},
                {"Custo de Feiticos",        45835, 2}, {"Resistencia ao Eletrico", 45840, 2},
                {"Dano Eletrico",            45840, 1}, {"Recuperacao de Saude", 45834, 1},
                {"Redução de Saude",         45834, 2}, {"Enfraquecer",          45843, 2},
                {"Arma",                     45843, 1}, {"Alquimista",           45846, 1},
                {"Aceleracao",               45846, 2}, {"Resistencia ao igneo", 45838, 2},
                {"Dano igneo",               45838, 1}, {"Reducao de Dano Fisico", 45847, 2},
                {"Aumento de Dano Fisico",   45847, 1}, {"vigor",                45833, 1},
                {"saude",                    45831, 1}, {"magica",               45832, 1},
            },
            ["match"] = {
                {"insignificante", 45855}, {"inferior",  45856}, {"pequeno",   45857},
                {"leve",           45806}, {"menor",     45807}, {"reduzido",  45808},
                {"moderado",       45809}, {"medio",     45810}, {"forte",     45811},
                {"maior",          45812}, {"maioral",   45813}, {"grandioso", 45814},
                {"esplendido",     45815}, {"monumental",45816},
                {"Verdadeiramente Glorioso", {68341, 68340}},
                {"soberbo",        {64509, 64508}},
            },
            ["quality"] = {
                {"normal",   45850}, {"fino",    45851}, {"superior", 45852},
                {"epico",    45853}, {"lendario",45854}, {"", 45850},
            },
        },
    }
end

-- ── Strings ──────────────────────────────────────────────────────────────────

WritCreater.strings = WritCreater.strings or {}

WritCreater.strings["runeReq"] = function(essence, potency, taStack, essenceStack, potencyStack)
    return zo_strformat(
        "|c2dff00São necessários 1/<<3>> |rTa|c2dff00, 1/<<4>> |cffcc66<<1>>|c2dff00 e 1/<<5>> |c0066ff<<2>>|r",
        essence, potency, taStack, essenceStack, potencyStack)
end

WritCreater.strings["runeMissing"] = function(ta, essence, potency)
    local missing = {}
    if not ta["bag"] then
        missing[#missing + 1] = "|r" .. ZO_CachedStrFormat("<<C:1>>", "Ta") .. "|cf60000"
    end
    if not essence["bag"] then
        missing[#missing + 1] = "|cffcc66" .. ZO_CachedStrFormat("<<C:1>>", essence["slot"]) .. "|cf60000"
    end
    if not potency["bag"] then
        missing[#missing + 1] = "|c0066ff" .. ZO_CachedStrFormat("<<C:1>>", potency["slot"]) .. "|r"
    end
    local text = ""
    for i = 1, #missing do
        if i == 1 then
            text = "|cff3333Glifo não pode ser criado.\nSem " .. ZO_CachedStrFormat("<<C:1>>", missing[i])
        else
            text = text .. " ou " .. ZO_CachedStrFormat("<<C:1>>", missing[i])
        end
    end
    return text
end

WritCreater.strings["notEnoughSkill"]   = "Você não tem pontos de habilidade suficientes nessa profissão para criar esse item."
WritCreater.strings["smithingMissing"]  = "\n|cf60000Materiais insuficientes|r"
WritCreater.strings["craftAnyway"]      = "Criar mesmo assim"
WritCreater.strings["smithingEnough"]   = "\n|c2dff00Você tem materiais suficientes"
WritCreater.strings["craft"]            = "|c00ff00Criar|r"

WritCreater.strings["smithingReqM"]  = function(amount, type, more)
    return zo_strformat("A construção vai usar <<1>> <<2>>\n(|cf60000Você precisa de <<3>>|r)", amount, type, more)
end
WritCreater.strings["smithingReqM2"] = function(amount, type, more)
    return zo_strformat("\n<<1>> <<2>> (|cf60000Você precisa de <<3>>|r)", amount, type, more)
end
WritCreater.strings["smithingReq"] = function(amount, type, current)
    return zo_strformat(
        "A construção vai usar <<1>> <<2>>\n(Você possui |c2dff00<<3>>|r)",
        amount, type,
        zo_strformat(SI_NUMBER_FORMAT,
            ZO_AbbreviateNumber(current,
                NUMBER_ABBREVIATION_PRECISION_TENTHS,
                USE_LOWERCASE_NUMBER_SUFFIXES)))
end
WritCreater.strings["smithingReq2"] = function(amount, type, current)
    return zo_strformat("\n<<1>> <<2>> (|c2dff00<<3>>|r)", amount, type, current)
end

WritCreater.strings["crafting"]         = "|cffff00Fabricando...|r"
WritCreater.strings["craftIncomplete"]  = "|cf60000A fabricação não pôde ser concluída.\nVocê precisa de mais materiais.|r"
WritCreater.strings["moreStyle"]        = "|cf60000Você não tem nenhuma das pedras de estilo selecionadas|r"
WritCreater.strings["moreStyleSettings"]    = "|cf60000Você não tem materiais de estilo disponíveis.\nProvavelmente você precisa ativar mais estilos de criação nas configurações.|r"
WritCreater.strings["moreStyleKnowledge"]   = "|cf60000Você não tem materiais de estilo disponíveis.\nTalvez você precise aprender mais estilos de criação|r"
WritCreater.strings["dailyreset"]       = function(till) d(till["hour"] .. " horas e " .. till["minute"] .. " minutos até o reinício diário") end
WritCreater.strings["complete"]         = "|c00FF00A Ordem está completa|r"
WritCreater.strings["craftingstopped"]  = "Fabricação interrompida. Verifique se o addon está criando o item correto."
WritCreater.strings["lootReceived"]     = "<<1>> recebido (Você tem <<2>>)"
WritCreater.strings["lootReceivedM"]    = "<<1>> recebido"
WritCreater.strings["countSurveys"]     = "Você tem <<1>> levantamentos"
WritCreater.strings["countVouchers"]    = "Você tem <<1>> vouchers de ordens pendentes"
WritCreater.strings["surveys"]          = "Levantamentos de Criação"
WritCreater.strings["sealedWrits"]      = "Ordens Seladas"
WritCreater.strings["missingLibraries"] = "O Dolgubon's Lazy Writ Crafter requer as seguintes bibliotecas. Instale ou ative: "
WritCreater.strings["fullBag"]          = "Seu inventário está cheio. Por favor, esvazie o inventário."
WritCreater.strings["masterWritSave"]   = "O Dolgubon's Lazy Writ Crafter impediu que você aceitasse uma Ordem Mestre por engano. Vá às configurações para desativar."
WritCreater.strings["resetWarningMessageText"] = "As quests diárias de criação serão reiniciadas em <<1>> hora e <<2>> minuto\nVocê pode ajustar ou desativar este aviso nas configurações"
WritCreater.strings["resetWarningExampleText"] = "O aviso ficará assim"
WritCreater.strings["withdrawItem"]     = function(amount, link, remaining) return "Dolgubon's Lazy Writ Crafter retirou " .. amount .. " " .. link .. ". (Ainda " .. remaining .. " no banco)" end
WritCreater.strings["writBufferNotification"]   = "O Buffer de Quests do Lazy Writ Crafter™ está impedindo você de aceitar esta quest"
WritCreater.strings["welcomeMessage"]           = "Obrigado por instalar o Dolgubon's Lazy Writ Crafter! Confira as configurações para personalizar o comportamento do addon"
WritCreater.strings["transmuteLooted"]          = "<<1>> Pedra de Transmutação recebida (Você tem <<2>>)"
WritCreater.strings["transmuteLimitHit"]        = "Saquear essas pedras de transmutação te colocaria acima do máximo, então <<1>> pedras de transmutação não foram saqueadas"
WritCreater.strings["transmuteLimitApproach"]   = "Você está se aproximando do limite de pedras de transmutação. Se uma caixa te colocar acima do limite, o Writ Crafter não saqueará as pedras."
WritCreater.strings["statsWitsDone"]            = "Ordens concluídas: <<1>> nos últimos <<2>> dias"
WritCreater.strings["provisioningUnknownRecipe"] = "Você não conhece a receita para <<1>>"
WritCreater.strings["provisioningCraft"]        = "Writ Crafter fabricará <<1>>"
WritCreater.strings["pressToCraft"]             = "\nPressione |t32:32:<<1>>|t para fabricar"
WritCreater.strings["lowInventory"]             = "\nVocê tem apenas <<1>> espaços livres e pode não ter espaço suficiente"
WritCreater.strings["masterWritQueueCleared"]   = "Fila de fabricação de Ordens Mestres limpa"
WritCreater.strings["multiplierCraftPrediction"] = "Fabricando <<2>> itens para <<1[nenhum ciclo/$d ciclo/$d ciclos]>> de Ordens"
WritCreater.strings["alchemyNoCombo"]           = "Não foi possível encontrar uma combinação de reagentes conhecidos suficientemente barata. Tente obter outros tipos de itens de alquimia"
WritCreater.strings["alchemyLowPassive"]        = "Você selecionou fabricar uma pilha completa, mas não tem as passivas de multiplicação de fabricação ativas"
WritCreater.strings["alchemyCraftReqs"]         = "A fabricação usará <<t:4>> <<t:1>>, <<t:4>> <<t:2>> e <<t:4>> <<t:3>>"
WritCreater.strings["alchemyMasterReqs"]        = "<<t:1>>: Fabricando uma <<t:2>> usando <<t:3>>, <<t:4>> e <<t:5>>"
WritCreater.strings["depositGold"]              = "Writ Crafter: Depositando <<1>> de ouro"
WritCreater.strings["depositItemMissing"]       = "Writ Crafter: Não foi possível encontrar <<t:1>> para depositar. O item pode ter sido destruído ou movido"
WritCreater.strings["depositItem"]              = "Writ Crafter: Depositando <<t:1>>"
WritCreater.strings["keybindStripBlurb"]        = "Fabricar itens da Ordem"
WritCreater.strings["goldenPursuitCraft"]       = "Fabricar itens de set para perseguições douradas inacabadas?\n(Pode não ser possível. Apenas Machado/Arco/Anel/Túnica, usa ferro)"
WritCreater.strings["fullInventory"]            = "Seu inventário está cheio"
WritCreater.strings["deconstructSuccess"]       = "Writ Crafter: Desconstruiu <<1>>"
WritCreater.strings["lootingMarkJunk"]          = "Writ Crafter: Marcou <<1>> como lixo"
WritCreater.strings["lootingDestroyItem"]       = "Writ Crafter: Destruiu <<1>> porque você configurou isso nas opções"
WritCreater.strings["lootingDeconItem"]         = "Writ Crafter: <<1>> enfileirado para desconstrução"
WritCreater.strings["lootingDeposit"]           = "Writ Crafter: <<1>> itens enfileirados para depósito no banco"
WritCreater.strings["mailComplete"]             = "Writ Crafter: Saqueamento de correio concluído"
WritCreater.strings["mailNumLoot"]              = "Writ Crafter: <<1>> correios de assistente encontrados"
WritCreater.strings["masterRecipeUnknown"]      = "<<t:1>>: Não pode ser enfileirado — você não conhece a receita para <<t:2>>"
WritCreater.strings["masterEnchantCraft"]       = "<<t:1>>: Fabricando <<t:2>>"
WritCreater.strings["masterRecipeCraft"]        = "<<t:1>>: Fabricando <<t:3>>x<<t:2>>"
WritCreater.strings["masterRecipeError"]        = "<<1>>: Não foi possível enfileirar para a Ordem. Você pode não conhecer a receita necessária"
WritCreater.strings["masterQueueNotFound"]      = "Não foi possível determinar quantos itens fabricar. Tente aceitar a Ordem."
WritCreater.strings["masterQueueBlurb"]         = "Fabricar Ordem"
WritCreater.strings["masterQueueSummary"]       = "Writ Crafter enfileirou <<1>> Ordens seladas"
WritCreater.strings["abandonQuestBanItem"]      = "Writ Crafter abandonou a <<1>> porque ela requer <<2>>, que está bloqueado nas configurações"
WritCreater.strings["masterStopAcceptNoCraftSkill"] = "O Lazy Writ Crafter™ impediu você de aceitar esta Ordem porque você não pode fabricá-la"
WritCreater.strings["stealingProtection"]       = "O Lazy Writ Crafter™ salvou você de roubar enquanto fazia Ordens!"
WritCreater.strings["junkSold"]                 = "Writ Crafter: Vendeu todos os itens de lixo"
WritCreater.strings["boxLootRemaining"]         = "<<1>>/<<2>> caixas restantes"
WritCreater.strings["potion"]                   = "poção"
WritCreater.strings["poison"]                   = "veneno"
WritCreater.strings["includesStorage"]          = function(type) local a = {"Levantamentos", "Ordens Mestres"} return zo_strformat("Contar <<1>> nos seus baús de armazenamento", a[type]) end

WritCreater.strings["newMasterWritSmithToCraft"] = function(link, trait, style, quality, writName, usedMimicStone)
    if usedMimicStone then
        return zo_strformat(
            "<<t:5>>: Fabricando um CP150 <<t:1>> com o traço <<t:2>> e estilo <<t:3>> em qualidade <<t:4>> com pedra imitadora",
            link, trait, style, quality, writName)
    else
        return zo_strformat(
            "<<t:5>>: Fabricando um CP150 <<t:1>> com o traço <<t:2>> e estilo <<t:3>> em qualidade <<t:4>>",
            link, trait, style, quality, writName)
    end
end

-- ── Option Strings ────────────────────────────────────────────────────────────

WritCreater.optionStrings = WritCreater.optionStrings or {}

WritCreater.optionStrings["nowEditing"]                     = "Você está editando as configurações de %s"
WritCreater.optionStrings["accountWide"]                    = "Conta Inteira"
WritCreater.optionStrings["characterSpecific"]              = "Específico do Personagem"
WritCreater.optionStrings["useCharacterSettings"]           = "Usar Configurações do Personagem"
WritCreater.optionStrings["useCharacterSettingsTooltip"]    = "Salva configurações específicas para este personagem, não para toda a conta."
WritCreater.optionStrings["style tooltip"]                  = function(styleName) return zo_strformat("Permitir o estilo <<1>> para ser usado na criação", styleName) end
WritCreater.optionStrings["show craft window"]              = "Mostrar Janela do Writ Crafter"
WritCreater.optionStrings["show craft window tooltip"]      = "Mostrar a janela do Writ Crafter enquanto estiver em uma estação de criação"
WritCreater.optionStrings["autocraft"]                      = "Fabricação Automática"
WritCreater.optionStrings["autocraft tooltip"]              = "Se ativado, o Writ Crafter começará a fabricar automaticamente ao entrar em uma estação de criação."
WritCreater.optionStrings["blackmithing"]                   = "Ferraria"
WritCreater.optionStrings["blacksmithing tooltip"]          = "Desativar o addon para Ferraria"
WritCreater.optionStrings["clothing"]                       = "Alfaiataria"
WritCreater.optionStrings["clothing tooltip"]               = "Desativar o addon para Alfaiataria"
WritCreater.optionStrings["enchanting"]                     = "Encantamento"
WritCreater.optionStrings["enchanting tooltip"]             = "Desativar o addon para Encantamento"
WritCreater.optionStrings["alchemy"]                        = "Alquimia"
WritCreater.optionStrings["alchemy tooltip"]                = "Desativar o addon para Alquimia"
WritCreater.optionStrings["provisioning"]                   = "Culinária"
WritCreater.optionStrings["provisioning tooltip"]           = "Desativar o addon para Culinária"
WritCreater.optionStrings["woodworking"]                    = "Marcenaria"
WritCreater.optionStrings["woodworking tooltip"]            = "Desativar o addon para Marcenaria"
WritCreater.optionStrings["jewelry crafting"]               = "Joalheria"
WritCreater.optionStrings["jewelry crafting tooltip"]       = "Desativar o addon para Joalheria"
WritCreater.optionStrings["style stone menu"]               = "Material de Estilo"
WritCreater.optionStrings["style stone menu tooltip"]       = "Escolha qual material de estilo usar."
WritCreater.optionStrings["exit when done"]                 = "Fechar Janela de Criação"
WritCreater.optionStrings["exit when done tooltip"]         = "Fechar a janela de criação depois que todas as tarefas forem concluídas"
WritCreater.optionStrings["automatic complete"]             = "Diálogo de Quest Automático"
WritCreater.optionStrings["automatic complete tooltip"]     = "Aceitar e concluir quests automaticamente ao chegar ao local necessário"
WritCreater.optionStrings["new container"]                  = "Manter Status de Novo"
WritCreater.optionStrings["new container tooltip"]          = "Manter o status de novo para contêineres de recompensa de Ordens"
WritCreater.optionStrings["master"]                         = "Ordens Mestres"
WritCreater.optionStrings["master tooltip"]                 = "Ativar/desativar a fabricação automática de Ordens Mestres"
WritCreater.optionStrings["right click to craft"]           = "Clique Direito para Fabricar"
WritCreater.optionStrings["right click to craft tooltip"]   = "Se ativado, o addon fabricará Ordens Mestres após ativá-las com clique direito"
WritCreater.optionStrings["crafting submenu"]               = "Profissões para Trabalhar"
WritCreater.optionStrings["crafting submenu tooltip"]       = "Ativar/desativar profissões específicas"
WritCreater.optionStrings["timesavers submenu"]             = "Economizadores de Tempo"
WritCreater.optionStrings["timesavers submenu tooltip"]     = "Vários pequenos economizadores de tempo"
WritCreater.optionStrings["loot container"]                 = "Saquear Contêineres de Recompensa"
WritCreater.optionStrings["loot container tooltip"]         = "Saquear automaticamente os contêineres de recompensa de Ordens ao recebê-los"
WritCreater.optionStrings["master writ saver"]              = "Bloquear Ordens Mestres"
WritCreater.optionStrings["master writ saver tooltip"]      = "Bloqueia a possibilidade de aceitar Ordens Mestres"
WritCreater.optionStrings["loot output"]                    = "Aviso de Recompensa Valiosa"
WritCreater.optionStrings["loot output tooltip"]            = "Exibir mensagem ao receber itens valiosos de uma Ordem"
WritCreater.optionStrings["writ grabbing"]                  = "Retirar Itens"
WritCreater.optionStrings["writ grabbing tooltip"]          = "Retira itens necessários para Ordens do banco (ex: Nirnwurz, Ta, etc.)"
WritCreater.optionStrings["autoloot behaviour"]             = "Comportamento de Saque Automático"
WritCreater.optionStrings["autoloot behaviour tooltip"]     = "Quando o addon deve saquear contêineres"
WritCreater.optionStrings["autoloot behaviour choices"]     = {"Copiar configuração do jogo", "Saquear automaticamente", "Nunca saquear"}
WritCreater.optionStrings["hide when done"]                 = "Ocultar Janela Após Concluir"
WritCreater.optionStrings["hide when done tooltip"]         = "Ocultar automaticamente a janela do Writ Crafter após fabricar os itens"
WritCreater.optionStrings["reticleColour"]                  = "Alterar Cor da Mira"
WritCreater.optionStrings["reticleColourTooltip"]           = "Altera a cor da mira se houver uma Ordem incompleta ou concluída na estação"
WritCreater.optionStrings["autoCloseBank"]                  = "Diálogo de Banco Automático"
WritCreater.optionStrings["autoCloseBankTooltip"]           = "Abrir e fechar automaticamente o diálogo do banco se itens precisarem ser retirados"
WritCreater.optionStrings["despawnBanker"]                  = "Dispensar Assistente (Retiradas)"
WritCreater.optionStrings["despawnBankerTooltip"]           = "Sair e dispensar o assistente automaticamente após retirar itens"
WritCreater.optionStrings["despawnBankerDeposit"]           = "Sair e Dispensar Assistente (Depósitos)"
WritCreater.optionStrings["despawnBankerDepositTooltip"]    = "Dispensar o assistente automaticamente após depositar itens"
WritCreater.optionStrings["hireling behaviour"]             = "Ações de Correio do Assistente"
WritCreater.optionStrings["hireling behaviour tooltip"]     = "O que fazer com os correios do assistente"
WritCreater.optionStrings["hireling behaviour choices"]     = {"Nada", "Saquear e Deletar", "Apenas Saquear"}
WritCreater.optionStrings["alchemyChoices"]                 = {"Desativado", "Todos os recursos", "Pular AutoFabricação"}
WritCreater.optionStrings["craftMultiplierConsumables"]     = "Multiplicador de Fabricação (alquimia e culinária)"
WritCreater.optionStrings["craftMultiplierConsumablesTooltip"] = "Uma fabricação simples realiza uma ação, podendo ser multiplicada pelas passivas. Pilha completa fabrica 100 do item, se você tiver as passivas."
WritCreater.optionStrings["craftMultiplierConsumablesChoices"] = {"Fabricação simples", "Pilha completa"}
WritCreater.optionStrings["scan for unopened"]              = "Abrir contêineres ao entrar"
WritCreater.optionStrings["scan for unopened tooltip"]      = "Ao entrar no jogo, verificar o inventário por contêineres de Ordens não abertos e tentar abri-los"
WritCreater.optionStrings["smart style slot save"]          = "Menor quantidade primeiro"
WritCreater.optionStrings["smart style slot save tooltip"]  = "Tentará minimizar os espaços usados (sem ESO+) usando primeiro as pedras de estilo em menor quantidade"
WritCreater.optionStrings["abandon quest for item"]         = "Ordens com 'entregar <<1>>'"
WritCreater.optionStrings["abandon quest for item tooltip"] = "Se DESATIVADO, abandonará Ordens que exigem entregar <<1>>. Quests que exigem fabricar um item com <<1>> nunca serão abandonadas"
WritCreater.optionStrings["skin"]                           = "Aparência do Writ Crafter"
WritCreater.optionStrings["skinTooltip"]                    = "A aparência da interface do Writ Crafter"
WritCreater.optionStrings["skinOptions"]                    = {"Padrão", "Queijo", "Cabra", "Fabuloso"}
WritCreater.optionStrings["goatSkin"]                       = "Cabra"
WritCreater.optionStrings["cheeseSkin"]                     = "Queijo"
WritCreater.optionStrings["fabulousSkin"]                   = "Fabuloso"
WritCreater.optionStrings["defaultSkin"]                    = "Padrão"
WritCreater.optionStrings["showStatusBar"]                  = "Mostrar Barra de Status"
WritCreater.optionStrings["showStatusBarTooltip"]           = "Mostrar ou ocultar a barra de status de Ordens"
WritCreater.optionStrings["statusBarIcons"]                 = "Usar Ícones"
WritCreater.optionStrings["statusBarIconsTooltip"]          = "Mostra ícones de fabricação em vez de letras para cada tipo de Ordem"
WritCreater.optionStrings["transparentStatusBar"]           = "Barra de Status Transparente"
WritCreater.optionStrings["transparentStatusBarTooltip"]    = "Tornar a barra de status transparente"
WritCreater.optionStrings["statusBarInventory"]             = "Rastreador de Inventário"
WritCreater.optionStrings["statusBarInventoryTooltip"]      = "Adicionar um rastreador de inventário à barra de status"
WritCreater.optionStrings["statusBarHorizontal"]            = "Posição Horizontal"
WritCreater.optionStrings["statusBarHorizontalTooltip"]     = "Posição horizontal da barra de status"
WritCreater.optionStrings["statusBarVertical"]              = "Posição Vertical"
WritCreater.optionStrings["statusBarVerticalTooltip"]       = "Posição vertical da barra de status"
WritCreater.optionStrings["incompleteColour"]               = "Cor de quest incompleta"
WritCreater.optionStrings["completeColour"]                 = "Cor de quest completa"
WritCreater.optionStrings["smartMultiplier"]                = "Multiplicador Inteligente"
WritCreater.optionStrings["smartMultiplierTooltip"]         = "Se ativado, o Writ Crafter fabricará itens para o ciclo completo de 3 dias. Também considera itens que você já tem."
WritCreater.optionStrings["craftHousePort"]                 = "Ir para casa de fabricação"
WritCreater.optionStrings["craftHousePortTooltip"]          = "Teletransportar para uma casa de fabricação disponível publicamente"
WritCreater.optionStrings["craftHousePortButton"]           = "Ir"
WritCreater.optionStrings["reportBug"]                      = "Reportar um bug"
WritCreater.optionStrings["reportBugTooltip"]               = "Abrir uma discussão para reportar bugs da versão console do Writ Crafter"
WritCreater.optionStrings["openUrlButtonText"]              = "Abrir URL"
WritCreater.optionStrings["donate"]                         = "Doar"
WritCreater.optionStrings["donateTooltip"]                  = "Doe para o Dolgubon no Paypal"
WritCreater.optionStrings["writStats"]                      = "Estatísticas de Ordens"
WritCreater.optionStrings["writStatsTooltip"]               = "Ver estatísticas históricas de recompensas de Ordens feitas com o addon instalado"
WritCreater.optionStrings["writStatsButton"]                = "Abrir janela"
WritCreater.optionStrings["queueWrits"]                     = "Enfileirar todas as Ordens seladas"
WritCreater.optionStrings["queueWritsTooltip"]              = "Enfileirar todas as Ordens seladas no seu inventário"
WritCreater.optionStrings["queueWritsButton"]               = "Enfileirar"
WritCreater.optionStrings["mainSettings"]                   = "Configurações Principais"
WritCreater.optionStrings["keepItemWritFormat"]             = "Manter <<1>>"
WritCreater.optionStrings["npcStyleStoneReminder"]          = "Lembrete: Pedras de estilo de raça base podem ser compradas de qualquer NPC de fabricação por 15 de ouro cada"
WritCreater.optionStrings["voucherCount"]                   = "Contar Vouchers de Ordens não obtidos"
WritCreater.optionStrings["voucherCountTooltip"]            = "Exibe o total de vouchers de todas as Ordens Mestres seladas no inventário e banco"
WritCreater.optionStrings["surveyCount"]                    = "Contar pesquisas"
WritCreater.optionStrings["surveyCountTooltip"]             = "Exibe um resumo do número de pesquisas no inventário e banco"
WritCreater.optionStrings["mimicStoneUse"]                  = "Pedras imitadoras para Ordens Mestres"
WritCreater.optionStrings["mimicStoneUseTooltip"]           = "Define o uso de pedras imitadoras para Ordens Mestres. Limpa a fila atual.\nNunca usadas para Ordens diárias. (Compre por 15 de ouro cada dos NPCs)"
WritCreater.optionStrings["mimicStoneUseChoices"]           = {"Não usar", "Sempre usar", "Usar se sem pedras de estilo", "Usar se preço > 1k", "Usar se preço > 3k"}
WritCreater.optionStrings["masterWritQueueCleared"]         = "Fila de fabricação de Ordens Mestres limpa"
WritCreater.optionStrings["onomatopoeia"]                   = "Onomatopeias de Fabricação"
WritCreater.optionStrings["onomatopoeiaTooltip"]            = "Ativa as onomatopeias de fabricação do LWC April Fools"
WritCreater.optionStrings["currencyReward"]                 = "Ouro da Quest"
WritCreater.optionStrings["currencyRewardTooltip"]          = "O que fazer com o ouro das recompensas de Ordens"
WritCreater.optionStrings["goldMatReward"]                  = "Materiais dourados (sem ESO+)"
WritCreater.optionStrings["goldMatRewardTooltip"]           = "O que fazer com materiais dourados das recompensas. Ignorado para assinantes ESO+"
WritCreater.optionStrings["dailyResetWarnTime"]             = "Minutos antes do reinício"
WritCreater.optionStrings["dailyResetWarnTimeTooltip"]      = "Quantos minutos antes do reinício diário o aviso deve aparecer"
WritCreater.optionStrings["dailyResetWarnType"]             = "Aviso de Reinício Diário"
WritCreater.optionStrings["dailyResetWarnTypeTooltip"]      = "Que tipo de aviso exibir quando o reinício diário estiver próximo"
WritCreater.optionStrings["dailyResetWarnTypeChoices"]      = {"Nenhum", "Tipo 1", "Tipo 2", "Tipo 3", "Tipo 4", "Todos"}
WritCreater.optionStrings["stealingProtection"]             = "Proteção contra Roubo"
WritCreater.optionStrings["stealingProtectionTooltip"]      = "Impede que você roube enquanto tiver Ordens ativas no diário"
WritCreater.optionStrings["status bar submenu"]             = "Barra de Status"
WritCreater.optionStrings["status bar submenu tooltip"]     = "Opções para a barra de status de Ordens"
WritCreater.optionStrings["writRewards submenu"]            = "Configurações de Recompensas"
WritCreater.optionStrings["writRewards submenu tooltip"]    = "O que fazer com as recompensas de Ordens"
WritCreater.optionStrings["rewardChoices"]                  = {"Nada", "Guardar no Banco", "Marcar como Lixo", "Destruir", "Descontruir"}
WritCreater.optionStrings["surveyReward"]                   = "Recompensas de Levantamento"
WritCreater.optionStrings["surveyRewardTooltip"]            = "Como lidar com recompensas de levantamento"
WritCreater.optionStrings["soulGemReward"]                  = "Gemas de Alma Vazias"
WritCreater.optionStrings["soulGemTooltip"]                 = "Como lidar com gemas de alma vazias"
WritCreater.optionStrings["recipeReward"]                   = "Receitas"
WritCreater.optionStrings["recipeRewardTooltip"]            = "Como lidar com receitas"
WritCreater.optionStrings["ornateReward"]                   = "Equipamento Ornamentado"
WritCreater.optionStrings["ornateRewardTooltip"]            = "Como lidar com equipamento ornamentado"
WritCreater.optionStrings["repairReward"]                   = "Kits de Reparo"
WritCreater.optionStrings["repairRewardTooltip"]            = "Como lidar com kits de reparo recebidos"
WritCreater.optionStrings["sameForALlCrafts"]               = "Mesma regra para todas as profissões"
WritCreater.optionStrings["sameForALlCraftsTooltip"]        = "Aplica a regra deste tipo de recompensa a todas as profissões"
WritCreater.optionStrings["questBuffer"]                    = "Buffer de Quest para Criação Diária"
WritCreater.optionStrings["questBufferTooltip"]             = "Mantém um buffer de quest para que todas as quests diárias de criação possam ser aceitas"

-- ── Hireling mail subjects ────────────────────────────────────────────────────

WritCreater.hirelingMailSubjects = WritCreater.hirelingMailSubjects or {}

WritCreater.hirelingMailSubjects["Matéria-Prima de Ferreiro"]   = true
WritCreater.hirelingMailSubjects["Matéria-Prima de Costura"]    = true
WritCreater.hirelingMailSubjects["Matéria-Prima de Encantador"] = true
WritCreater.hirelingMailSubjects["Matéria-Prima de Marceneiro"] = true
WritCreater.hirelingMailSubjects["Matéria-Prima de Culinária"]  = true

-- ── Identity ──────────────────────────────────────────────────────────────────

WritCreater.lang = "br"
WritCreater.langIsMasterWritSupported = true
