-- -----------------------------------------------------------------------------
-- Lang/es.lua
-- -----------------------------------------------------------------------------
local strings = {
    SKILLBLOCKER_NJ_UNLOCK_ALL                         = "Desbloquear todo",
    SKILLBLOCKER_NJ_UNLOCKED                           = "Desbloqueado",
    SKILLBLOCKER_NJ_LOCKED                             = "Bloqueado",
    SKILLBLOCKER_NJ_LOCKED_COMBAT                      = "Bloqueado en combate",
    SKILLBLOCKER_NJ_LOCKED_ACTIVE                      = "Bloqueado mientras activo",
    SKILLBLOCKER_NJ_LOADED                             = "Cargado con éxito",
    SKILLBLOCKER_NJ_LOCKED_WEREWOLF                    = "Bloqueado en forma de hombre lobo",

    SKILLBLOCKER_NJ_BLOCK_SETTINGS                     = "Ajustes de bloqueo",
    SKILLBLOCKER_NJ_BLOCK_STACKS                       = "Bloquear si cargas <",
    SKILLBLOCKER_NJ_BLOCK_CRUX                         = "Bloquear si Crux <",
    SKILLBLOCKER_NJ_BLOCK_REVERSE                      = "Bloquear si Crux ≥",
    SKILLBLOCKER_NJ_BLOCK_PROC                         = "Bloquear hasta el <<1>> proc",
    SKILLBLOCKER_NJ_BLOCK_HP                           = "Bloquear si HP objetivo >",
    SKILLBLOCKER_NJ_BLOCK_ULTIMATE                     = "Bloquear si < <<1>> puntos",
    SKILLBLOCKER_NJ_BLOCK_DURATION                     = "Bloquear durante <<1>> seg.",
    SKILLBLOCKER_NJ_BLOCK_DEBUFF                       = "Bloquear hasta la <<1>> explosión",

    SKILLBLOCKER_NJ_GENERAL_SETTINGS                   = "Configuración general",
    SKILLBLOCKER_NJ_REMEMBER                           = "¿Recordar bloqueos?",
    SKILLBLOCKER_NJ_SHOW_ALERT                         = "Mostrar alerta",
    SKILLBLOCKER_NJ_ALERT_TOOLTIP                      = "Muestra una advertencia del sistema al intentar usar una habilidad bloqueada",

    SKILLBLOCKER_NJ_DOUBLE_CAST_BLOCK_SETTINGS         = "Protección de doble activación",
    SKILLBLOCKER_NJ_RESET_DOUBLE_CAST_LA               = "Reiniciar protección tras ataque ligero",
    SKILLBLOCKER_NJ_RESET_DOUBLE_CAST_LA_TOOLTIP       = "Si está activado, un ataque ligero elimina instantáneamente la protección de doble activación.",
    SKILLBLOCKER_NJ_DOUBLE_CAST_BLOCK_DURATION         = "Duración de la protección",
    SKILLBLOCKER_NJ_DOUBLE_CAST_BLOCK_DURATION_TOOLTIP = "Tiempo en segundos que la habilidad permanece inactiva tras su uso (0 = ∞).",

    SKILLBLOCKER_NJ_MENU_ACTIVE_BLOCKS_TITLE           = "Mi lista de habilidades bloqueadas:",
    SKILLBLOCKER_NJ_MAIN_BAR                           = "Barra principal:",
    SKILLBLOCKER_NJ_BACK_BAR                           = "Barra trasera:",

    SKILLBLOCKER_NJ_ACTION_ENABLE                      = "Activar",
    SKILLBLOCKER_NJ_ACTION_DISABLE                     = "Desactivar",

    SKILLBLOCKER_NJ_MENU_DOUBLE_CAST_TITLE             = "Bloqueo de doble uso",
    SKILLBLOCKER_NJ_MENU_STACK_TITLE                   = "Bloqueo por acumulaciones",
    SKILLBLOCKER_NJ_MENU_CRUX_TITLE                    = "Bloqueo por Crux",
    SKILLBLOCKER_NJ_MENU_PROC_TITLE                    = "Bloqueo por activación (Proc)",
    SKILLBLOCKER_NJ_MENU_DEBUFF_TITLE                  = "Bloqueo por «explosión» de habilidad",
    SKILLBLOCKER_NJ_MENU_ULTIMATE_TITLE                = "Bloqueo por puntos de definitiva",
    SKILLBLOCKER_NJ_MENU_DURATION_TITLE                = "Bloqueo por duración",
    SKILLBLOCKER_NJ_MENU_HP_TITLE                      = "Bloqueo por salud del objetivo",
    SKILLBLOCKER_NJ_MENU_CRIMINAL_TITLE                = "Bloquear «Acto criminal»",

    SKILLBLOCKER_NJ_DELETE_FROM_SLOT                   = "Eliminar del espacio",

    SI_BINDING_NAME_SKILLBLOCKER_NJ_UNLOCK_ALL         = "Desbloquear todas las habilidades",
    SI_BINDING_NAME_SKILLBLOCKER_NJ_TOGGLE_SLOT_1      = "Alternar bloqueo: Ranura 1",
    SI_BINDING_NAME_SKILLBLOCKER_NJ_TOGGLE_SLOT_2      = "Alternar bloqueo: Ranura 2",
    SI_BINDING_NAME_SKILLBLOCKER_NJ_TOGGLE_SLOT_3      = "Alternar bloqueo: Ranura 3",
    SI_BINDING_NAME_SKILLBLOCKER_NJ_TOGGLE_SLOT_4      = "Alternar bloqueo: Ranura 4",
    SI_BINDING_NAME_SKILLBLOCKER_NJ_TOGGLE_SLOT_5      = "Alternar bloqueo: Ranura 5",
    SI_BINDING_NAME_SKILLBLOCKER_NJ_TOGGLE_SLOT_6      = "Alternar bloqueo: Definitiva",
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end