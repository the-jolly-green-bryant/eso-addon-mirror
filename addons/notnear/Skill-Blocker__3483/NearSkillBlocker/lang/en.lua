
local strings = {
    SI_BINDING_NAME_NEARSB_suppressblock = 'Toggle block suppression',
    SI_BINDING_NAME_NEARSB_blockPvP      = 'Toggle PvP',

    NEARSB_registered               = 'Registered ',
    NEARSB_unregistered             = 'Unregistered ',
    NEARSB_un_reg_recast            = ' recast',
    NEARSB_un_reg_notInCombat       = ' when out of combat',
    NEARSB_un_reg_inCombat          = ' when in combat',
    NEARSB_un_reg_isBracing         = ' while bracing',
    NEARSB_un_reg_MaxCrux           = ' for max Crux',
    NEARSB_un_reg_NotMaxCrux        = ' for not max Crux',
    NEARSB_un_reg_stacks            = ' for stacks',

    NEARSB_suppressblock_enabled    = 'Enabled suppress block',
    NEARSB_suppressblock_disabled   = 'Disabled suppress block ',
    NEARSB_blockpvp_enabled         = 'Enabled block PvP',
    NEARSB_blockpvp_disabled        = 'Disabled block PvP ',


    NEARSB_LAM_supb_name            = 'Block suppression',
    NEARSB_LAM_supb_tooltip         = 'Suppresses ALL blocks in ALL zones\nON: Won\'t block any ability\n\nUseful when you need to spam an ability to lower resources',
    NEARSB_LAM_supbr_name           = 'Block suppression auto reset',
    NEARSB_LAM_supbr_tooltip        = 'Auto reset "'..GetString(NEARSB_LAM_supb_name)..'" to default (disabled) at addon loaded',

    NEARSB_LAM_bpvp_name            = 'Block on PvP zones',
    NEARSB_LAM_bpvp_tooltip         = 'Block ALL selected abilities in AvA and Battlegrounds'..'\n\n*overwrites "'..GetString(NEARSB_LAM_co_bpvp_name)..'"',

    NEARSB_LAM_cmdmsgt_name         = 'Type of alert',
    NEARSB_LAM_cmdmsgt_tooltip      = 'Set type of alert for keybind/slash command output',
    NEARSB_LAM_cmdmsgt_choices1     = 'Chat',
    NEARSB_LAM_cmdmsgt_choices2     = 'Alert',
    NEARSB_LAM_cmdmsgt_choices3     = 'No message',

    NEARSB_LAM_cmdmsgs_name         = 'Alert sounds',
    NEARSB_LAM_cmdmsgs_tooltip      = 'Whether to output or not sound for the "Alert" option (top right messages)',

    NEARSB_LAM_msg_name             = 'Registered/Unregistered messages',

    NEARSB_LAM_showE_name           = 'Invalid ability alert',
    NEARSB_LAM_showE_tooltip        = 'Show an alert when a suppressed ability is used, when disabled the ability will fail silently.',

    NEARSB_LAM_abHideTimers_name     = 'Hide ZOS Ability Bar timers',
    NEARSB_LAM_abHideTimers_tooltip  = 'Timers are needed for "Block recast", if you prefer using timers from addons this will hide the base game ones while keeping the recast functionality',

    NEARSB_LAM_recastThreshold_name     = 'Block recast threshold',
    NEARSB_LAM_recastThreshold_tooltip  = 'Define minimum time remaining (in seconds) for abilities to be blocked',

    NEARSB_LAM_skillsel_name        = 'Skill selector',
    NEARSB_LAM_classsel_name        = 'Class selector',
    NEARSB_LAM_cmd_text             =
     'Commands:' .. '\n\n' ..
     'Open this menu: \n"/skillblocker"' .. '\n\n' ..
     'Toggle block suppression: \n"/sb/suppressblock"' .. '\n\n'..
     'Toggle PvP block: \n"/sb/blockpvp"',
    NEARSB_LAM_reglist_name         = 'Currently registered',


    NEARSB_LAM_co_bcast_name            = 'Block cast',
    NEARSB_LAM_co_bcast_tooltip         = 'This setting is overwritten by other types of block',
    NEARSB_LAM_co_brecast_name          = 'Block recast',
    NEARSB_LAM_co_brecast_tooltip       = 'Prevents ability cast if it has an effect time remaining',
    NEARSB_LAM_co_brecast_warning       = 'This option relies on the game setting "'..GetString(SI_INTERFACE_OPTIONS_ACTION_BAR_TIMERS)..'" being ON! \n(under the setting panel: "'..GetString(SI_SETTINGSYSTEMPANEL9)..'")',
    NEARSB_LAM_co_bnotInCombat_name     = 'Block when out of combat',
    NEARSB_LAM_co_bnotInCombat_tooltip  = 'Can be paired with other types of block and has higher priority',
    NEARSB_LAM_co_binCombat_name        = 'Block when in combat',
    NEARSB_LAM_co_binCombat_tooltip     = 'Can be paired with other types of block and has higher priority',
    NEARSB_LAM_co_bisBracing_name       = 'Block while bracing',
    NEARSB_LAM_co_bisBracing_tooltip    = 'Can be paired with other types of block and has higher priority',
    NEARSB_LAM_co_bpvp_name             = 'Block in PvP',
    NEARSB_LAM_co_bpvp_tooltip          = 'This setting is overwritten by: "'..GetString(NEARSB_LAM_bpvp_name)..'"'..'\nDefines if your block choices should be considered on PvP zones or not.',
    NEARSB_LAM_co_bonMaxCrux_name       = 'Block when on max Crux',
    NEARSB_LAM_co_bonMaxCrux_tooltip    = 'Prevents ability cast if player has 3 stacks of Crux',
    NEARSB_LAM_co_bonNotMaxCrux_name    = 'Block when not on max Crux',
    NEARSB_LAM_co_bonNotMaxCrux_tooltip = 'Prevents ability cast if player doesn\'t have 3 stacks of Crux',
    NEARSB_LAM_co_sonStacksEqual_name       = 'Stacks',
    NEARSB_LAM_co_bonStacksEqual_name       = 'Block if not equal to X stacks',
    NEARSB_LAM_co_bonStacksEqual_tooltip    = 'Prevents ability cast if player doesn\'t have the exact defined amount of stacks.\nAvailable for "Bound Armaments" and "Venom Skull"',

    -- Custom ability names
    NEARSB_abilityName_78338            = zo_strformat("<<2>> <<C:1>>", GetAbilityName(61511), "Remove"), -- Guard
    NEARSB_abilityName_81415            = zo_strformat("<<2>> <<C:1>>", GetAbilityName(61536), "Remove"), -- Mystic Guard
    NEARSB_abilityName_81420            = zo_strformat("<<2>> <<C:1>>", GetAbilityName(61529), "Remove"), -- Stalwart Guard 
}


for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
