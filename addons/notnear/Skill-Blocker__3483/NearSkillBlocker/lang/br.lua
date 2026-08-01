
local strings = {
    SI_BINDING_NAME_NEARSB_suppressblock = 'Alternar supressão de bloqueio',
    SI_BINDING_NAME_NEARSB_blockPvP      = 'Alternar PvP',

    NEARSB_registered               = 'Registrado ',
    NEARSB_unregistered             = 'Desregistrado ',
    -- NEARSB_un_reg_recast            = ' recast', -- manter o original
    NEARSB_un_reg_notInCombat       = ' quando fora de combate',
    NEARSB_un_reg_MaxCrux           = ' quando em Crux máximo',
    NEARSB_un_reg_NotMaxCrux        = ' quando não em Crux máximo',

    NEARSB_suppressblock_enabled    = 'Supressão de bloqueio ativado',
    NEARSB_suppressblock_disabled   = 'Supressão de bloqueio desativado',
    NEARSB_blockpvp_enabled         = 'Bloqueio em PvP ativado',
    NEARSB_blockpvp_disabled        = 'Bloqueio em PvP desativado',


    NEARSB_LAM_supb_name            = 'Supressão de bloqueio',
    NEARSB_LAM_supb_tooltip         = 'Suprime TODOS os bloqueios em TODAS as zonas\nATIVADO: Não bloqueará nenhuma habilidade\n\nÚtil quando você precisa spammar uma habilidade para reduzir recursos',
    NEARSB_LAM_supbr_name           = 'Redefinação automática da supressão	de bloqueio',
    NEARSB_LAM_supbr_tooltip        = 'Automaticamente redefine "Alternar supressão de bloqueio" para o padrão (desativado) ao carregar o addon',

    NEARSB_LAM_bpvp_name            = 'Bloqueio em zonas de PvP',
    NEARSB_LAM_bpvp_tooltip         = 'Bloqueia TODAS as habilidades selecionadas em Guerra das Alianças e Campos de Batalha'..'\n\n*sobrescreve "Bloquear em PvP"',

    NEARSB_LAM_cmdmsgt_name         = 'Tipo de alerta',
    NEARSB_LAM_cmdmsgt_tooltip      = 'Definir o tipo de alerta das teclas de atalho/comandos de chat',
    NEARSB_LAM_cmdmsgt_choices1     = 'Chat',
    NEARSB_LAM_cmdmsgt_choices2     = 'Alerta',
    NEARSB_LAM_cmdmsgt_choices3     = 'Sem mensagem',

    NEARSB_LAM_cmdmsgs_name         = 'Som para o alerta',
    NEARSB_LAM_cmdmsgs_tooltip      = 'Se deve ou não reproduzir som para a opção "Alerta" (mensagens no canto superior direito)',

    NEARSB_LAM_msg_name             = 'Mensagens de registrado/desregistrado',

    NEARSB_LAM_showE_name           = 'Alerta de habilidade inválida',
    NEARSB_LAM_showE_tooltip        = 'Mostrar um alerta quando uma habilidade suprimida for usada, quando desativado, a habilidade falhará silenciosamente.',


    NEARSB_LAM_skillsel_name        = 'Seletor de habilidades',
    NEARSB_LAM_classsel_name        = 'Seletor de classes',
    NEARSB_LAM_cmd_text             =
     'Comandos:' .. '\n\n' ..
     'Abrir este menu: \n"/skillblocker"' .. '\n\n' ..
     'Alternar supressão de bloqueio: \n"/sb/suppressblock"' .. '\n\n'..
     'Alternar bloqueio em PvP: \n"/sb/blockpvp"',
    NEARSB_LAM_reglist_name         = 'Atualmente registrado',


    NEARSB_LAM_co_bcast_name            = 'Bloquear cast',
    NEARSB_LAM_co_bcast_tooltip         = 'Essa configuração é sobrescrita por outros tipos de bloqueio',
    NEARSB_LAM_co_brecast_name          = 'Bloquear recast',
    NEARSB_LAM_co_brecast_warning       = 'Esta opção depende da configuração do jogo "'..GetString(SI_INTERFACE_OPTIONS_ACTION_BAR_TIMERS)..'" estar ATIVADA! \n(no painel de configuração: "'..GetString(SI_SETTINGSYSTEMPANEL9)..'")',
    NEARSB_LAM_co_bnotInCombat_name     = 'Bloquear quando fora de combate',
    NEARSB_LAM_co_bnotInCombat_tooltip  = 'Pode ser combinado com outros tipos de bloqueio',
    NEARSB_LAM_co_bpvp_name             = 'Bloquear em PvP',
    NEARSB_LAM_co_bpvp_tooltip          = 'Essa configuração é sobrescrita por: "Alternar bloqueio em zonas de PvP"'..'\nDefine se suas escolhas de bloqueio devem ser considerados em zonas PvP ou não.',
    NEARSB_LAM_co_bonMaxCrux_name       = 'Bloquear quando em Crux máximo',
    NEARSB_LAM_co_bonMaxCrux_tooltip    = 'Previne uso da habilidade se o player tiver 3 stacks de Crux',
    NEARSB_LAM_co_bonNotMaxCrux_name    = 'Bloquear quando não em Crux máximo',
    NEARSB_LAM_co_bonNotMaxCrux_tooltip = 'Previne uso da habilidade se o player não tiver 3 stacks de Crux',
}


for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2) --Add a new version 2 of the stringIds, in client language
end
