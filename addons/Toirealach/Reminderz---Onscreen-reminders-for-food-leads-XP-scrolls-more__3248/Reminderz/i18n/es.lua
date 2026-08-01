Reminderz = Reminderz or {}

local localization = {

    LOADED_STR = "%s %s %s",
    WAS_LOADED = "cargado",
    NOT_LOADED = "no cargado",

    DAILY_RESET = "El reinicio diario está en %s",
    TURN_IN = "Envía misiones PvP, completa tus tareas y escribe.",
    RESET_IS_NOW = "El reinicio diario acaba de realizarse",
    NO_FOOD_1 = "¡No hay comida potenciadora activa!",
    NO_FOOD_2 = "¡Come algo!",
    FOOD_RUNNING_OUT = "%s se acabará en %s",
    NO_MAYHEM = "%s ha terminado. ¡Usa el pergamino otra vez!",
    LOW_BAG_SPACE = "¡Tu inventario está casi lleno!",
    NO_BAG_SPACE = "¡Tu inventario está lleno!",
    GEAR_MISSING = "¡Comprueba tu armadura y armas! ¡Falta algo!",
    ARMOR_MISSING = "¡Al menos una pieza de armadura no está equipada!",
    JEWELRY_MISSING = "¡Al menos una pieza de joyería no está equipada!",
    WEAPON_MISSING = "¡falta un arma!",
    MAIN_HAND = "Tu mano principal",
    OFF_HAND = "Tu mano libre",
    RESPALDO = "Copia de seguridad",
    IS_ENDING = "%s termina en %s",
    GO_FEED = "Estás en %s. ¡Alimentándote!",
    VAMP_TOO_HIGH = "Recordatorio de vampirismo: nivel actual > nivel deseado",
    NO_XP_SCROLL = "¡No hay ningún desplazamiento de XP activo!",
    XP_SCROLL_ENDING = "Tu pergamino de XP termina en %s",
    TELVAR_CAP_REACHED = "Llevas %d piedras Tel Var. ¡Deberías ponerlas en el banco!",
    RESERVE_TOO_HIGH = "Número de reserva Tel'Var demasiado alto. Depósito automático de todas las piedras Tel'Var transportadas.",
    TELVAR_DEPOSITED = "%d Tel Var Stones se depositan automáticamente en el banco.",
    WAR_TORTES_MISSING = "¡No hay ningún pastel de guerra activo!",
    WAR_TORTES_RUNNING_OUT = "Tu pastel de guerra termina en %s",
    ACHIEVEMENT_PROGRESS = "Progreso: (%s/%s)",
    ACHIEVEMENT_AWARDED = "¡Logro COMPLETADO!",
    NO_MUNDUS = "¡No tienes una Piedra Mundus activa!",
        
    WARNING_RELOADUI = "Advertencia: La interfaz de usuario se recargará automáticamente cuando se realicen cambios.",
   
    ACCTWIDE_NAME = "Usar configuración para toda la cuenta",
    ACCTWIDE_TOOLTIP = "Cuando esta función está desactivada, cada personaje tendrá sus propios recuerdos.",

    SIEMPRE = "Siempre",
    NUNCA = "Nunca",
    IN_PVP = "Sólo en PvP",

    REMIND_INTERVAL_NAME = "Intervalo entre recordatorios:",
    REMIND_INTERVAL_TOOLTIP = "Intervalo entre recordatorios",
    FIRST_REMINDER_NAME = "Tiempo restante hasta el primer recordatorio:",
    FIRST_REMINDER_TOOLTIP = "Tiempo restante hasta el primer recordatorio",
    REMIND_COLOR_NAME = "Color del texto del recordatorio:",
    REMIND_COLOR_TOOLTIP = "El color de estos recordatorios en el chat y en la pantalla",
    REMIND_OFF_IN_HOUSES_NAME = "No hay recordatorio mientras permaneces en casas:",
    REMIND_OFF_IN_HOUSES_TOOLTIP = "Establezca esta opción en ON si no desea este recordatorio mientras esté en una de sus casas.",
    REMIND_ONLY_IN_DUNGEONS_NAME = "Recordatorios PvE solo en mazmorras, bandas, etc.",
    REMIND_ONLY_IN_DUNGEONS_TOOLTIP = "Activa si solo quieres recordatorios PvE en mazmorras, bandas, etc.",
    
    HEADER_GENERAL = "General",
    NAME_CHATBOX = "Mostrar recordatorios en la ventana de chat también",
    TOOLTIP_CHATBOX = "Muestra recordatorios en la pestaña de chat principal y en la pantalla.",
    NAME_OFFLINE = "Recordatorio de susurro en modo fuera de línea",
    TOOLTIP_OFFLINE = "Si estableces tu estado de jugador en 'Sin conexión', se te recordará que la persona a la que estabas susurrando no puede responderte a menos que cambies tu estado.",
    NAME_SUPPRESS = "Suprimir mensaje 'Complemento cargado'",
    TOOLTIP_SUPPRESS = "Suprime el mensaje en la ventana de chat que indica que el complemento se cargó exitosamente.",
    NAME_DAILY_REWARD = "Recoge la recompensa diaria automáticamente",
    TOOLTIP_DAILY_REWARD = "Recoge automáticamente la recompensa de inicio de sesión diaria cuando esté disponible",
    NAME_FREE_BAG_SLOTS = "Recordatorio cuando haya espacios libres en el inventario en:",
    TOOLTIP_FREE_BAG_SLOTS = "Número de espacios de inventario libres, debajo de los cuales se le recordará el espacio de inventario bajo. Cero significa que el recordatorio de inventario está desactivado.",
    NAME_MISSING_GEAR = "RECORDATORIO DE ARMADURA O ARMAS FALTANTES",
    TOOLTIP_MISSING_GEAR = "Recuerda cuando todas las armaduras y armas no estén equipadas...",
    NAME_ACHIEVEMENTS = "Mostrar actualizaciones de logros",
    TOOLTIP_ACHIEVEMENTS = "Pon todas las actualizaciones del progreso de los logros en la ventana de chat",
    
    HEADER_FOOD = "Comida",
    NAME_REMIND_FOOD = "Activar recordatorio:",
    TOOLTIP_REMIND_FOOD = "Recuerda cuándo se acaba o cuándo se acabará la comida.",
   
    HEADER_LEADS = "Pistas Antiguos",
    NAME_REMIND_LEADS = "Recordar cuando una pista antigua vence en X días:",
    TOOLTIP_REMIND_LEADS = "Recordar cuando una pista antigua vence en X días. (0 = APAGADO)",
    LEADS_EXPIRING_FMT_MULTI = "¡Varias pistas de antigüedad",
    LEADS_EXPIRING_FMT_MULTI2 = "caducarán en %s!",
    LEADS_EXPIRING_DAYS = "días",
    LEADS_EXPIRING_HOURS = "horas",

    HEADER_VAMPIRE = "Nivel de vampirismo",
    NAME_REMIND_VAMPIRE = "Activar recordatorio:",
    TOOLTIP_REMIND_VAMPIRE = "Recuerda cuándo cambiará el nivel de vampirismo y después de que cambie.",
    NAME_REMIND_VAMP_IN_PVP = "Sólo en PvP:",
    TOOLTIP_REMIND_VAMP_IN_PVP = "Si está activado, los recordatorios solo aparecerán en PvP. Si está desactivado, los recordatorios también aparecerán en PvE..",
    
    HEADER_XP_SCROLLS = "Pergaminos XP y pociones",
    NAME_XP_SCROLLS = "Activar recordatorio:",
    TOOLTIP_XP_SCROLLS = "Recuerda cuándo se agota o cuándo se agotará el pergamino o la poción de XP.",
    
    HEADER_TELVAR = "Piedras Tel'Var",
    NAME_TELVAR = "Recuerda este número de Tel Var Stones:",
    TOOLTIP_TELVAR = "Recuerda si llevas más piedras Tel Var de la especificada.",
    NAME_TELVAR_AUTODEPOSIT = "Depositar piedras TelVar automáticamente:",
    TOOLTIP_TELVAR_AUTODEPOSIT = "Deposita automáticamente las piedras Tel Var que llevas cuando superan el número especificado y visitas a un banquero",
    NAME_TELVAR_RESERVE_AMT = "Conservar este número de Tel Var Stones:",
    TOOLTIP_TELVAR_RESERVE_AMT = "Cuando depositas piedras Tel Var automáticamente, conservas ese número contigo para obtener multiplicadores de bonificación.",
    
    HEADER_AP_SCROLLS = "Pergaminos AP y pasteles de guerra",
    NAME_AP_SCROLLS = "Activar recordatorio:",
    TOOLTIP_AP_SCROLLS = "Recuerda cuándo se agota o cuándo se agotará el pastel de guerra o el pergamino AP.",

}
    
if Reminderz.Localization and #localization == #Reminderz.Localization then
    ZO_ShallowTableCopy(localization, Reminderz.Localization)
end