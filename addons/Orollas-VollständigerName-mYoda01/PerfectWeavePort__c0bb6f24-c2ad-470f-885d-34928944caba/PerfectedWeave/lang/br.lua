-- =============================================================================
-- === PerfectedWeave Language File: Brazilian Portuguese (br.lua)              ===
-- =============================================================================
--[[
    AddOn Name:         PerfectedWeave
    File:               lang/br.lua
    Description:        Brazilian Portuguese localization using ZO_CreateStringId
    Version:            1.2.0
    Author:             Orollas, VollständigerName, mYoda01
--]]
-- =============================================================================

-- =============================================================================
-- == PANEL & AUTHOR INFORMATION ===============================================
-- =============================================================================

ZO_CreateStringId("PW_MENU_PANEL_NAME", "|c6D6D6DOp|r|c8A8A8Atim|r|cA7A7A7al |r|cC4C4C4Wea|r|c6D6D6Dve|r")
ZO_CreateStringId("PW_MENU_AUTHORS", "|cEE82EEO|r|cDD74ECr|r|cCD65EAo|r|cBC57E8l|r|cAB48E6l|r|c9B3AE4a|r|c8A2BE2s|r & |cFFD700Vo|r|cF7D418l|r|cF3D324l|r|cEFD130s|r|cEBD03Ctä|r|cE3CD54n|r|cE0CC60d|r|cDCCA6Ci|r|cD8C978g|r|cD4C784e|r|cD0C690r|r|cCCC49CNa|r|cC4C1B4me|r")
ZO_CreateStringId("PW_MENU_WEBSITE", "https://github.com/VollstaendigerName")

-- =============================================================================
-- == INFORMATION SECTION ======================================================
-- =============================================================================

ZO_CreateStringId("PW_MENU_INFO_HEADER", "Informações & LEIAME")
ZO_CreateStringId("PW_MENU_INFO_TEXT", "Recarga global (GCD) é 1000ms. PerfectedWeave gerencia a fila de habilidades baseado no modo selecionado. Personalize o comportamento com as configurações.")
ZO_CreateStringId("PW_MENU_MODE_HEADER", "Mecânicas principais")
ZO_CreateStringId("PW_MENU_CONDITIONS_HEADER", "Regras de ativação")
ZO_CreateStringId("PW_MENU_ADVANCED_HEADER", "Controles avançados")
ZO_CreateStringId("PW_MENU_PERFORMANCE_HEADER", "Configurações de desempenho")
ZO_CreateStringId("PW_MENU_MODE_ACTIVE", "Addon ativo")
ZO_CreateStringId("PW_MENU_MODE_INACTIVE", "Addon inativo")
ZO_CreateStringId("PW_MENU_DISABLED_TOOLTIP", "Esta opção está desativada")
ZO_CreateStringId("PW_MENU_LATENCY_WARNING", "Aviso: Alta latência pode causar atrasos!")

ZO_CreateStringId("PW_MENU_DISCLAIMER_LABEL", "|cFF0000Aviso|r") 
ZO_CreateStringId("PW_MENU_DISCLAIMER_TOOLTIP", "|cFF0000Aviso legal:|r Este addon não é afiliado à ZeniMax Media Inc. The Elder Scrolls® é marca registrada da ZeniMax Media Inc. Todos os direitos reservados.")

-- =============================================================================
-- == CORE SETTINGS ============================================================
-- =============================================================================

ZO_CreateStringId("PW_MENU_SETTINGS_HEADER", "Configurações principais")
ZO_CreateStringId("PW_MENU_MODE_LABEL", "Modo de operação")
ZO_CreateStringId("PW_MENU_MODE_TOOLTIP", "|c00FF00Sequencial:|r Permite usar habilidades apenas após um ataque leve.\n|cFF0000Rígido:|r Bloqueio total. Sem fila durante GCD.\n|cFFFF00Inteligente:|r Fila permitida apenas sem Ataque Leve.\n|c00FFFFNenhum:|r Desativado.")
ZO_CreateStringId("PW_MENU_MODE_CHOICE_COND", "Sequencial")
ZO_CreateStringId("PW_MENU_MODE_CHOICE_HARD", "Rígido")
ZO_CreateStringId("PW_MENU_MODE_CHOICE_SOFT", "Inteligente")
ZO_CreateStringId("PW_MENU_MODE_CHOICE_NONE", "Nenhum")
ZO_CreateStringId("PW_MENU_COMBAT_LABEL", "Ativo apenas em combate")
ZO_CreateStringId("PW_MENU_COMBAT_TOOLTIP", "Gerencia fila apenas durante combate.")
ZO_CreateStringId("PW_MENU_ENEMYTARGET_LABEL", "Requer alvo inimigo")
ZO_CreateStringId("PW_MENU_ENEMYTARGET_TOOLTIP", "Requer um alvo inimigo selecionado.")
ZO_CreateStringId("PW_MENU_BLOCKING_LABEL", "Ignorar durante bloqueio")
ZO_CreateStringId("PW_MENU_BLOCKING_TOOLTIP", "Desativa controles durante bloqueio.")
ZO_CreateStringId("PW_MENU_GROUNDAOE_LABEL", "Bloquear duplo lançamento de AoE")
ZO_CreateStringId("PW_MENU_GROUNDAOE_TOOLTIP", "Previne lançamentos acidentais duplos.")
ZO_CreateStringId("PW_MENU_DISABLE_TANK", "Desativar como Tank")
ZO_CreateStringId("PW_MENU_DISABLE_TANK_TOOLTIP", "Desativa automaticamente no papel de Tank")
ZO_CreateStringId("PW_MENU_DISABLE_HEAL", "Desativar como Healer")
ZO_CreateStringId("PW_MENU_DISABLE_HEAL_TOOLTIP", "Desativa automaticamente no papel de Healer")

ZO_CreateStringId("PW_MENU_DISABLE_FEATURES_ON_BACKBAR", "Desativar funções na segunda barra")
ZO_CreateStringId("PW_MENU_DISABLE_FEATURES_ON_BACKBAR_TOOLTIP", "Desativa a maioria das funções do addon na segunda barra de armas.")
ZO_CreateStringId("PW_MENU_DISABLE_WEAVE_ASSIST_ON_BACKBAR", "Desativar assistente de weaving na segunda barra")
ZO_CreateStringId("PW_MENU_DISABLE_WEAVE_ASSIST_ON_BACKBAR_TOOLTIP", "Desativa o assistente de weaving (gerenciamento de GCD) na segunda barra de armas.")

ZO_CreateStringId("PW_MENU_DEACTIVATE_IN_PVP_HEADER", "Desativação no PvP")
ZO_CreateStringId("PW_MENU_DISABLE_FEATURES_IN_PVP", "Desativar funções no PvP")
ZO_CreateStringId("PW_MENU_DISABLE_FEATURES_IN_PVP_TOOLTIP", "Desativa a maioria das funções do addon em áreas PvP")
ZO_CreateStringId("PW_MENU_DISABLE_WEAVE_ASSIST_IN_PVP", "Desativar assistente de tecelagem no PvP")
ZO_CreateStringId("PW_MENU_DISABLE_WEAVE_ASSIST_IN_PVP_TOOLTIP", "Desativa o assistente de tecelagem (gerenciamento de GCD) em áreas PvP")

-- =============================================================================
-- == BLOCK ID SETTINGS ========================================================
-- =============================================================================

ZO_CreateStringId("PW_MENU_BLOCKED_HEADER", "Habilidades bloqueadas")
ZO_CreateStringId("PW_MENU_BLOCKED_ADD_LABEL", "Bloquear novo ID")
ZO_CreateStringId("PW_MENU_BLOCKED_ADD_TOOLTIP", "Insira ID da habilidade (ex. 134160)")
ZO_CreateStringId("PW_MENU_BLOCKED_LIST_LABEL", "IDs atualmente bloqueados")
ZO_CreateStringId("PW_MENU_BLOCKED_LIST_TOOLTIP", "Clique para remover")

-- =============================================================================
-- == ADVANCED SETTINGS ========================================================
-- =============================================================================
ZO_CreateStringId("PW_MENU_CHANNEL_NORMAL", "Buffer instantâneo (ms)")
ZO_CreateStringId("PW_MENU_CHANNEL_NORMAL_TOOLTIP", "Margem de segurança para habilidades instantâneas (0-100ms)")
ZO_CreateStringId("PW_MENU_CHANNEL_CHANNELED", "Buffer canalizado (ms)")
ZO_CreateStringId("PW_MENU_CHANNEL_CHANNELED_TOOLTIP", "Buffer para habilidades canalizadas (0-400ms)")
ZO_CreateStringId("PW_MENU_GCD_SLOT", "Slot de detecção GCD")
ZO_CreateStringId("PW_MENU_GCD_SLOT_TOOLTIP", "Slot da barra para detecção GCD (1-8)")
ZO_CreateStringId("PW_MENU_MIN_GCD", "Limite mínimo GCD (ms)")
ZO_CreateStringId("PW_MENU_MIN_GCD_TOOLTIP", "Duração mínima GCD para detecção (0-20ms)")
ZO_CreateStringId("PW_MENU_RESET_TIME_LABEL", "Tempo de redefinição (segundos)")
ZO_CreateStringId("PW_MENU_RESET_TIME_TOOLTIP", "Redefine o rastreamento após não lançar nada por esse número de segundos.")
ZO_CreateStringId("PW_MENU_AUTO_GCD_SLOT_LABEL", "Slot de rastreamento GCD automático")
ZO_CreateStringId("PW_MENU_AUTO_GCD_SLOT_TOOLTIP", "Seleciona automaticamente o melhor slot de rastreamento GCD dos slots 3-8")
ZO_CreateStringId("PW_MENU_QUEUE_TIME", "Tempo base de fila (ms)")
ZO_CreateStringId("PW_MENU_QUEUE_TIME_TOOLTIP", "Janela de fila padrão (100-2000ms)")
ZO_CreateStringId("PW_MENU_RESETONBARSWAP_LABEL", "Resetar ao trocar arma")
ZO_CreateStringId("PW_MENU_RESETONBARSWAP_TOOLTIP", "Reseta GCD ao trocar de arma")
ZO_CreateStringId("PW_MENU_RESETONDODGE_LABEL", "Resetar ao esquivar")
ZO_CreateStringId("PW_MENU_RESETONDODGE_TOOLTIP", "Reseta GCD ao esquivar")
ZO_CreateStringId("PW_MENU_AUTO_EQUIP_WEAPONS_LABEL", "Desembainhar automaticamente")
ZO_CreateStringId("PW_MENU_AUTO_EQUIP_WEAPONS_TOOLTIP", "Desembainhar armas automaticamente em combate")
ZO_CreateStringId("PW_MENU_RESET_SETTINGS_LABEL", "Redefinir tudo")
ZO_CreateStringId("PW_MENU_RESET_SETTINGS_TOOLTIP", "Redefinir todas as configurações para os valores padrão")

-- =============================================================================
-- == LATENCY COMPENSATION =====================================================
-- =============================================================================

ZO_CreateStringId("PW_MENU_LATENCY_HEADER", "Compensação de latência")
ZO_CreateStringId("PW_MENU_AUTOLATENCY_LABEL", "Ajuste automático")
ZO_CreateStringId("PW_MENU_AUTOLATENCY_TOOLTIP", "Ajusta automaticamente conforme latência. Recomendado para conexões estáveis.")
ZO_CreateStringId("PW_MENU_MANUALLATENCY_LABEL", "Latência manual (ms)")
ZO_CreateStringId("PW_MENU_MANUALLATENCY_TOOLTIP", "Valor fixo para conexões instáveis (0-200ms).")

-- =============================================================================
-- == (SUB)CLASS SETTINGS ======================================================
-- =============================================================================

ZO_CreateStringId("PW_MENU_SUBCLASS_HEADER", "Configurações de classe e guilda")
ZO_CreateStringId("PW_MENU_SUBCLASS_GRIMFOCUS", "Foco Sombrio")

ZO_CreateStringId("PW_MENU_GRIMFOCUS_STACKS", "Stacks necessários")
ZO_CreateStringId("PW_MENU_GRIMFOCUS_STACKS_TOOLTIP", "Número de stacks para ativação (recomendado: 10)")

ZO_CreateStringId("PW_MENU_GRIMFOCUS_ALL_MORPHS", "Bloquear todos os morphs")
ZO_CreateStringId("PW_MENU_GRIMFOCUS_ALL_MORPHS_TOOLTIP", "|cFF5555• Foco Incansável:|r Sempre bloqueado\n|cFFFF00• Foco Sombrio e Determinação Impiedosa:|r Usável apenas com 10 stacks\n|cAAAAAADesativar:|r Comportamento padrão")

ZO_CreateStringId("PW_MENU_GRIMFOCUS_GRIMFOCUSSTACKS_TOOGLE", "Ativar stacks personalizados")
ZO_CreateStringId("PW_MENU_GRIMFOCUS_GRIMFOCUSSTACKS_TOOGLE_TOOLTIP", "|cFFD700Ativado:|r Usa configuração de stacks \n|cAAAAAADesativado:|r Bloqueia sempre até 10 stacks\n")

-- == BLOCK GUILDS SETTINGS ===================================================
ZO_CreateStringId("PW_MENU_SUBCLASS_GUILDS", "Guildas")
ZO_CreateStringId("PW_MENU_HUNTER_ALL_MORPHS", "Bloquear Habilidades de Caçador da Guilda dos Guerreiros")
ZO_CreateStringId("PW_MENU_HUNTER_ALL_MORPHS_TOOLTIP", "Bloqueia todos os morphs das habilidades de caçador da Guilda dos Guerreiros (Caçador Perito, Caçador Camuflado & Caçador do Mal)")
ZO_CreateStringId("PW_MENU_LIGHT_ALL_MORPHS", "Bloquear Habilidades de Luz da Guilda dos Magos")
ZO_CreateStringId("PW_MENU_LIGHT_ALL_MORPHS_TOOLTIP", "Bloqueia todos os morphs das habilidades de luz (Luz Mágica, Luz Interior & Luz Mágica Radiante)")

ZO_CreateStringId("PW_MENU_DEACTIVATEHUNTERLIGHTINPVP_ALL_MORPHS", "Desativar em PvP")
ZO_CreateStringId("PW_MENU_DEACTIVATEHUNTERLIGHTINPVP_ALL_MORPHS_TOOLTIP", "Desativa bloqueio de habilidades Caçador/Luz em PvP")

-- == BLOCK MOLTEN WHIP SETTINGS ===============================================

ZO_CreateStringId("PW_MENU_SUBCLASS_MOLTENWHIP", "Chicote Derretido")
ZO_CreateStringId("PW_MENU_MOLTENWHIP_BLOCK", "Bloquear habilidade Chicote Derretido")
ZO_CreateStringId("PW_MENU_MOLTENWHIP_BLOCK_TOOLTIP", "Bloqueia a habilidade Chicote Derretido para evitar perder as três cargas")

-- == BLOCK FATECARVER SETTINGS ================================================
ZO_CreateStringId("PW_MENU_SUBCLASS_FATECARVER", "Arcanist Fatecarver")
ZO_CreateStringId("PW_MENU_FATECARVER_ALL_MORPHS", "Bloquear lançamento Fatecarver")
ZO_CreateStringId("PW_MENU_FATECARVER_ALL_MORPHS_TOOLTIP", "Bloqueia lançamento até condições serem atendidas.")
ZO_CreateStringId("PW_MENU_CRUX_STACKS", "Stacks Crux necessários")
ZO_CreateStringId("PW_MENU_CRUX_STACKS_TOOLTIP", "Stacks Crux mínimos para lançar (recomendado: 3)")
ZO_CreateStringId("PW_MENU_CHECK_HP_FOR_BEAM", "Limite de HP (%)")
ZO_CreateStringId("PW_MENU_CHECK_HP_FOR_BEAM_TOOLTIP", "Desativa o bloqueio do Fatecarver quando HP estiver abaixo deste valor")
ZO_CreateStringId("PW_MENU_CHECK_HP_FOR_BEAM_TOOGLE", "Verificar HP para Fatecarver")
ZO_CreateStringId("PW_MENU_CHECK_HP_FOR_BEAM_TOOGLE_TOOLTIP", "Desativa o bloqueio do Fatecarver quando sua saúde está baixa")

ZO_CreateStringId("PW_MENU_CHECK_STAMINA_FOR_BEAM", "Limite de Vigor (%)")
ZO_CreateStringId("PW_MENU_CHECK_STAMINA_FOR_BEAM_TOOLTIP", "Desativa o bloqueio do Fatecarver quando o Vigor está baixo")
ZO_CreateStringId("PW_MENU_CHECK_STAMINA_FOR_BEAM_TOOGLE", "Ativar verificação de Vigor para Fatecarver")
ZO_CreateStringId("PW_MENU_CHECK_STAMINA_FOR_BEAM_TOOGLE_TOOLTIP", "Desativa o bloqueio do Fatecarver quando seu vigor está baixo")

-- == BLOCK CEPHALIARCH'S FLAIL SETTINGS =======================================    
ZO_CreateStringId("PW_MENU_SUBCLASS_CEPHALIARCHSFLAIL", "Mangual do Cefaliarca")
ZO_CreateStringId("PW_MENU_CEPHALIARCHSFLAIL", "Bloquear Mangual do Cefaliarca")
ZO_CreateStringId("PW_MENU_CEPHALIARCHSFLAIL_TOOLTIP", "Bloqueia o Mangual do Cefaliarca quando você tem 3 acúmulos de Crux")

-- == BLOCK TENTACULAR DREAD SETTINGS ==========================================
ZO_CreateStringId("PW_MENU_SUBCLASS_TENTACULAR", "Tentacular Dread")
ZO_CreateStringId("PW_MENU_TENTACULAR", "Bloquear Tentacular Dread")
ZO_CreateStringId("PW_MENU_TENTACULAR_TOOLTIP", "Bloqueia a habilidade Tentacular Dread até que condições sejam atendidas.")

-- == Execute Check Settings ==========================================
ZO_CreateStringId("PW_MENU_EXECUTE_HEADER", "Verificação de Execução")
ZO_CreateStringId("PW_MENU_EXECUTE_ENABLE", "Ativar verificação de execução")
ZO_CreateStringId("PW_MENU_EXECUTE_ENABLE_TOOLTIP", "Ativa ou desativa a função de verificação de execução")
ZO_CreateStringId("PW_MENU_EXECUTE_THRESHOLD", "Limite de Execução (%)")
ZO_CreateStringId("PW_MENU_EXECUTE_THRESHOLD_TOOLTIP", "Porcentagem de saúde do alvo abaixo da qual as magias de execução são permitidas")
ZO_CreateStringId("PW_MENU_EXECUTE_SPELLS_HEADER", "Magias de Execução")

-- == Grouped Execute Spells ==========================================
ZO_CreateStringId("PW_MENU_EXECUTE_SPELL_RADIANTMORPHS", "Destruição Radiante, Glória Radiante, Opressão Radiante")
ZO_CreateStringId("PW_MENU_EXECUTE_SPELL_RADIANTMORPHS_TOOLTIP", "Bloqueia os morphs de Destruição Radiante até que o alvo esteja no alcance de execução")

ZO_CreateStringId("PW_MENU_EXECUTE_SPELL_ASSASSINSBLADEMORPHS", "Lâmina do Assassino, Empalar, Lâmina do Assassino")
ZO_CreateStringId("PW_MENU_EXECUTE_SPELL_ASSASSINSBLADEMORPHS_TOOLTIP", "Bloqueia os morphs de Lâmina do Assassino até que o alvo esteja no alcance de execução")

ZO_CreateStringId("PW_MENU_EXECUTE_SPELL_MAGESFURYMORPHS", "Ira dos Magos, Fúria dos Magos, Fúria Infinita")
ZO_CreateStringId("PW_MENU_EXECUTE_SPELL_MAGESFURYMORPHS_TOOLTIP", "Bloqueia os morphs de Fúria dos Magos até que o alvo esteja no alcance de execução")

ZO_CreateStringId("PW_MENU_EXECUTE_SPELL_REVERSESLASHMORPHS", "Golpe Reverso, Corte Reverso, Carrasco")
ZO_CreateStringId("PW_MENU_EXECUTE_SPELL_REVERSESLASHMORPHS_TOOLTIP", "Bloqueia os morphs de Golpe Reverso até que o alvo esteja no alcance de execução")

-- == Work in progress ================================================
ZO_CreateStringId("PW_WIP", "WIP")

-- =============================================================================
-- == WEAPON SETTINGS ==========================================================
-- =============================================================================

ZO_CreateStringId("PW_MENU_DEACTIVATE_ON_WEAPON_HEADER", "Desativar por tipo de arma")

ZO_CreateStringId("PW_MENU_DISABLE_WEAVE_ASSIST_ON_WEAPON", "Desativar assistente de weaving no tipo de arma")
ZO_CreateStringId("PW_MENU_DISABLE_WEAVE_ASSIST_ON_WEAPON_TOOLTIP", "Desativa apenas o assistente de weaving (gerenciamento GCD) para tipos de arma selecionados")

ZO_CreateStringId("PW_MENU_DISABLE_FEATURES_ON_WEAPON", "Desativar funções no tipo de arma")
ZO_CreateStringId("PW_MENU_DISABLE_FEATURES_ON_WEAPON_TOOLTIP", "Desativa a maioria das funções do addon para tipos de arma selecionados")

-- Armas de uma mão
ZO_CreateStringId("PW_MENU_DEACTIVATE_ON_WEAPON_AXE", "Machado")
ZO_CreateStringId("PW_MENU_DEACTIVATE_ON_WEAPON_AXE_TOOLTIP", "Desativar quando machado estiver equipado")

ZO_CreateStringId("PW_MENU_DEACTIVATE_ON_WEAPON_HAMMER", "Martelo")
ZO_CreateStringId("PW_MENU_DEACTIVATE_ON_WEAPON_HAMMER_TOOLTIP", "Desativar quando martelo estiver equipado")

ZO_CreateStringId("PW_MENU_DEACTIVATE_ON_WEAPON_SWORD", "Espada")
ZO_CreateStringId("PW_MENU_DEACTIVATE_ON_WEAPON_SWORD_TOOLTIP", "Desativar quando espada estiver equipado")

ZO_CreateStringId("PW_MENU_DEACTIVATE_ON_WEAPON_DAGGER", "Adaga")
ZO_CreateStringId("PW_MENU_DEACTIVATE_ON_WEAPON_DAGGER_TOOLTIP", "Desativar quando adaga estiver equipado")

-- Armas de duas mãos
ZO_CreateStringId("PW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_SWORD", "Espada de duas mãos")
ZO_CreateStringId("PW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_SWORD_TOOLTIP", "Desativar quando espada de duas mãos estiver equipada")

ZO_CreateStringId("PW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_AXE", "Machado de duas mãos")
ZO_CreateStringId("PW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_AXE_TOOLTIP", "Desativar quando machado de duas mãos estiver equipado")

ZO_CreateStringId("PW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_HAMMER", "Martelo de duas mãos")
ZO_CreateStringId("PW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_HAMMER_TOOLTIP", "Desativar quando martelo de duas mãos estiver equipado")

ZO_CreateStringId("PW_MENU_DEACTIVATE_ON_WEAPON_BOW", "Arco")
ZO_CreateStringId("PW_MENU_DEACTIVATE_ON_WEAPON_BOW_TOOLTIP", "Desativar quando arco estiver equipado")

-- Cajados
ZO_CreateStringId("PW_MENU_DEACTIVATE_ON_WEAPON_FIRE_STAFF", "Cajado de fogo")
ZO_CreateStringId("PW_MENU_DEACTIVATE_ON_WEAPON_FIRE_STAFF_TOOLTIP", "Desativar quando cajado de fogo estiver equipado")

ZO_CreateStringId("PW_MENU_DEACTIVATE_ON_WEAPON_FROST_STAFF", "Cajado de gelo")
ZO_CreateStringId("PW_MENU_DEACTIVATE_ON_WEAPON_FROST_STAFF_TOOLTIP", "Desativar quando cajado de gelo estiver equipado")

ZO_CreateStringId("PW_MENU_DEACTIVATE_ON_WEAPON_LIGHTNING_STAFF", "Cajado de relâmpago")
ZO_CreateStringId("PW_MENU_DEACTIVATE_ON_WEAPON_LIGHTNING_STAFF_TOOLTIP", "Desativar quando cajado de relâmpago estiver equipado")

ZO_CreateStringId("PW_MENU_DEACTIVATE_ON_WEAPON_HEALING_STAFF", "Cajado de cura")
ZO_CreateStringId("PW_MENU_DEACTIVATE_ON_WEAPON_HEALING_STAFF_TOOLTIP", "Desativar quando cajado de cura estiver equipado")

-- Outras armas
ZO_CreateStringId("PW_MENU_DEACTIVATE_ON_WEAPON_SHIELD", "Escudo")
ZO_CreateStringId("PW_MENU_DEACTIVATE_ON_WEAPON_SHIELD_TOOLTIP", "Desativar quando escudo estiver equipado")

ZO_CreateStringId("PW_MENU_DEACTIVATE_ON_WEAPON_RUNE", "Runa")
ZO_CreateStringId("PW_MENU_DEACTIVATE_ON_WEAPON_RUNE_TOOLTIP", "Desativar quando runa estiver equipada")

ZO_CreateStringId("PW_MENU_DEACTIVATE_ON_WEAPON_NONE", "Sem arma")
ZO_CreateStringId("PW_MENU_DEACTIVATE_ON_WEAPON_NONE_TOOLTIP", "Desativar quando nenhuma arma estiver equipada")

ZO_CreateStringId("PW_MENU_DEACTIVATE_ON_WEAPON_RESERVED", "Arma reservada")
ZO_CreateStringId("PW_MENU_DEACTIVATE_ON_WEAPON_RESERVED_TOOLTIP", "Desativar quando tipo de arma reservado estiver equipado")

-- =============================================================================
-- == CUSTOM BLOCK LIST SETTINGS ===============================================
-- =============================================================================

ZO_CreateStringId("PW_MENU_CONFIGURABLEBLOCK_HEADER", "Lista de Bloqueio Personalizada")
ZO_CreateStringId("PW_MENU_CUSTOMBLOCK_DESC", "Adicione IDs de habilidades para bloqueá-las. Você também pode adicionar feitiços clicando com o botão direito no slot da barra de ação (requer recarregamento)")
ZO_CreateStringId("PW_MENU_CUSTOMBLOCK_SPELLID_LABEL", "ID da Habilidade")
ZO_CreateStringId("PW_MENU_CUSTOMBLOCK_SPELLID_TOOLTIP", "Insira o ID numérico da habilidade (ex.: 185805)")
ZO_CreateStringId("PW_MENU_CUSTOMBLOCK_ADD_BUTTON", "Adicionar à Lista de Bloqueio")
ZO_CreateStringId("PW_MENU_CUSTOMBLOCK_LIST_HEADER", "Habilidades Bloqueadas:")
ZO_CreateStringId("PW_MENU_USE_CUSTOM_BLOCK_LIST", "Ativar Lista de Bloqueio Personalizada")
ZO_CreateStringId("PW_MENU_USE_CUSTOM_BLOCK_LIST_TOOLTIP", "Ativa ou desativa a funcionalidade da lista de bloqueio personalizada")
ZO_CreateStringId("PW_MENU_CUSTOMBLOCK_SV_DESC", "Verifique seu arquivo SavedVariables:\n customBlockList = {\n   [AbilityID] = false/true\n }")
ZO_CreateStringId("PW_MENU_USE_CUSTOM_BLOCK_LIST_HEALTH_CHECK", "Ativar Verificação de Saúde para Lista de Bloqueio")
ZO_CreateStringId("PW_MENU_USE_CUSTOM_BLOCK_LIST_HEALTH_CHECK_TOOLTIP", "Quando ativado, os feitiços na lista de bloqueio só serão bloqueados se sua saúde estiver acima do limite.")
ZO_CreateStringId("PW_MENU_CUSTOM_BLOCK_LIST_HEALTH_PERCENT", "Limite de Saúde para Lista de Bloqueio (%)")
ZO_CreateStringId("PW_MENU_CUSTOM_BLOCK_LIST_HEALTH_PERCENT_TOOLTIP", "Feitiços da lista de bloqueio só são bloqueados quando sua saúde está acima desta porcentagem.")


-- =============================================================================
-- == CUSTOM RECAST BLOCK LIST SETTINGS ========================================
-- =============================================================================

ZO_CreateStringId("PW_MENU_CONFIGURABLERECASTBLOCK_HEADER", "Lista de Bloqueio de Relançamento Personalizada")
ZO_CreateStringId("PW_MENU_CUSTOMRECASTBLOCK_DESC", "Adicione IDs de habilidades para bloqueá-las de serem relançadas até que o tempo de efeito restante esteja abaixo do limite. Você também pode adicionar feitiços clicando com o botão direito no slot da barra de ação (requer recarregamento).")
ZO_CreateStringId("PW_MENU_CUSTOMRECASTBLOCK_SPELLID_LABEL", "ID da Habilidade")
ZO_CreateStringId("PW_MENU_CUSTOMRECASTBLOCK_SPELLID_TOOLTIP", "Insira o ID numérico da habilidade (ex.: 185805)")
ZO_CreateStringId("PW_MENU_CUSTOMRECASTBLOCK_ADD_BUTTON", "Adicionar à Lista de Bloqueio de Relançamento")
ZO_CreateStringId("PW_MENU_CUSTOMRECASTBLOCK_LIST_HEADER", "Habilidades Bloqueadas para Relançamento:")
ZO_CreateStringId("PW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST", "Ativar Lista de Bloqueio de Relançamento Personalizada")
ZO_CreateStringId("PW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST_TOOLTIP", "Ativa ou desativa a funcionalidade da lista de bloqueio de relançamento personalizada")
ZO_CreateStringId("PW_MENU_RECAST_BLOCK_TIME", "Tempo de Bloqueio de Relançamento (s)")
ZO_CreateStringId("PW_MENU_RECAST_BLOCK_TIME_TOOLTIP", "Tempo em segundos abaixo do qual uma habilidade na lista de bloqueio de relançamento pode ser lançada novamente (1.0 = 1 segundo)")
ZO_CreateStringId("PW_MENU_CUSTOMRECASTBLOCK_SV_DESC", "Verifique seu arquivo SavedVariables:\n customRecastBlockList = {\n   [AbilityID] = false/true\n }")
ZO_CreateStringId("PW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST_HEALTH_CHECK", "Ativar Verificação de Saúde para Lista de Bloqueio de Relançamento")
ZO_CreateStringId("PW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST_HEALTH_CHECK_TOOLTIP", "Quando ativado, os feitiços na lista de bloqueio de relançamento só serão bloqueados se sua saúde estiver acima do limite.")
ZO_CreateStringId("PW_MENU_CUSTOM_RECAST_BLOCK_LIST_HEALTH_PERCENT", "Limite de Saúde para Lista de Bloqueio de Relançamento (%)")
ZO_CreateStringId("PW_MENU_CUSTOM_RECAST_BLOCK_LIST_HEALTH_PERCENT_TOOLTIP", "Feitiços da lista de bloqueio de relançamento só são bloqueados quando sua saúde está acima desta porcentagem.")


-- =============================================================================

ZO_CreateStringId("PW_MENU_RELOAD_DIALOG_MAIN_TEXT", "ID da habilidade foi adicionada. Se você não quiser adicionar mais habilidades, por favor recarregue a interface para que as mudanças sejam exibidas")
ZO_CreateStringId("PW_MENU_RELOAD_DIALOG_BUTTON_YES", "Recarregar Interface")
ZO_CreateStringId("PW_MENU_RELOAD_DIALOG_BUTTON_LATER", "Adicionar mais")

ZO_CreateStringId("PW_MENU_DIALOG_BUTTON_OK", "OK")
ZO_CreateStringId("PW_MENU_INVALID_ID_DIALOG_MAIN_TEXT", "Erro: Por favor insira um ID de habilidade válido")
ZO_CreateStringId("PW_MENU_ID_NOT_EXIST_DIALOG_MAIN_TEXT", "ID da habilidade não existe")
ZO_CreateStringId("PW_MENU_ID_IS_IN_SV_DIALOG_MAIN_TEXT", "ID da habilidade já está na lista de bloqueio")

-- =============================================================================
-- == KEYBINDINGS LOCALIZATION =================================================
-- =============================================================================

ZO_CreateStringId("SI_KEYBINDINGS_CATEGORY_PERFECTEDWEAVE", "|c6D6D6DOpti|r|c8A8A8AmalWea|r|cC4C4C4ve|r")
ZO_CreateStringId("SI_BINDING_NAME_PERFECTEDWEAVE_TOGGLE_MODE", "Alternar Modo (Rígido/Inteligente/Desativado)")
ZO_CreateStringId("SI_BINDING_NAME_PERFECTEDWEAVE_TOGGLE_CUSTOM_BLOCK_LIST", "Alternar Lista de Bloqueio Personalizada")
ZO_CreateStringId("SI_BINDING_NAME_PERFECTEDWEAVE_TOGGLE_CUSTOM_RECAST_BLOCK_LIST", "Alternar Lista de Bloqueio de Relançamento Personalizada")
ZO_CreateStringId("SI_BINDING_NAME_PERFECTEDWEAVE_TOGGLE_BACKBAR_FEATURES", "Alternar Desativação de Recursos da Barra Secundária")
ZO_CreateStringId("SI_BINDING_NAME_PERFECTEDWEAVE_TOGGLE_BACKBAR_WEAVE_ASSIST", "Alternar Desativação do Assistente de Tecelagem na Barra Secundária")
ZO_CreateStringId("SI_BINDING_NAME_PERFECTEDWEAVE_TOGGLE_EXECUTE_CHECK", "Alternar Verificação de Execução")
-- =============================================================================
-- === END OF BRAZILIAN PORTUGUESE LOCALIZATION ===============================
-- =============================================================================