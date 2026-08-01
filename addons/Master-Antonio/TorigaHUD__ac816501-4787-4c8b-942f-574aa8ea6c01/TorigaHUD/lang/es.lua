-- Spanish Localization Strings for TorigaHUD
local strings = {
    BINDING_NAME_TORIGAHUD_TOGGLE_DRAG = "Bloquear/Desbloquear posición del HUD",
    
    TORIGAHUD_SETTINGS_DISPLAY_NAME = "Ajustes de |cFFD700TorigaHUD|r",
    TORIGAHUD_SETTINGS_GENERAL_HEADER = "Ajustes generales",
    TORIGAHUD_SETTINGS_HIDE_OOC = "Ocultar fuera de combate",
    TORIGAHUD_SETTINGS_HIDE_OOC_TT = "Si está activo, oculta las barras de recursos cuando estás fuera de combate y no tienes un objetivo activo.",
    TORIGAHUD_SETTINGS_SHOW_SHIELDS = "Mostrar escudo protector",
    TORIGAHUD_SETTINGS_SHOW_SHIELDS_TT = "Si está activado, muestra una barra azul semitransparente sobre la salud para indicar escudos activos.",
    TORIGAHUD_SETTINGS_LERP_SPEED = "Velocidad de animación de barras",
    TORIGAHUD_SETTINGS_LERP_SPEED_TT = "Ajusta la velocidad con la que se deslizan las barras de recursos. (1.00 = actualizaciones instantáneas, sin animación)",
    TORIGAHUD_SETTINGS_SEGMENT_SIZE = "Valor por segmento (Salud/Recursos)",
    TORIGAHUD_SETTINGS_SEGMENT_SIZE_TT = "Ajusta cuántos puntos de recurso representa cada bloque (Salud, Magia, Aguante, Objetivo). Ej. 2000 significa que cada bloque son 2000 puntos.",
    TORIGAHUD_SETTINGS_SCALE = "Escala del HUD (Tamaño)",
    TORIGAHUD_SETTINGS_SCALE_TT = "Ajusta el tamaño global de todos los elementos del HUD.",
    TORIGAHUD_SETTINGS_PRESETS_HEADER = "Ajustes preestablecidos y posición",
    TORIGAHUD_SETTINGS_PRESET = "Diseño preestablecido",
    TORIGAHUD_SETTINGS_PRESET_TT = "Selecciona un diseño preestablecido para reorganizar el HUD al instante.",
    TORIGAHUD_SETTINGS_PRESET_DEFAULT = "Por defecto",
    TORIGAHUD_SETTINGS_PRESET_VERTICAL = "Enfoque de combate (Vertical)",
    TORIGAHUD_SETTINGS_PRESET_HORIZONTAL = "Enfoque de combate (Horizontal)",
    TORIGAHUD_SETTINGS_PRESET_MINIMALIST = "Minimalista (Compacto)",
    TORIGAHUD_SETTINGS_UNLOCK = "Desbloquear posición del HUD",
    TORIGAHUD_SETTINGS_UNLOCK_TT = "Activa esta opción para desbloquear los marcos. Esto cerrará el menú de opciones y mostrará un diálogo para posicionar los elementos con el ratón.",
    TORIGAHUD_SETTINGS_RESET = "Restablecer posiciones por defecto",
    TORIGAHUD_SETTINGS_RESET_TT = "Restablece todas las barras del HUD a sus posiciones originales.",
    
    TORIGAHUD_DRAG_XP = "PE",
    TORIGAHUD_DRAG_TARGET = "OBJETIVO",
    
    TORIGAHUD_DIALOG_TITLE = "ARRASTRA LAS BARRAS A DONDE QUIERAS",
    TORIGAHUD_DIALOG_APPLY = "APLICAR",
    TORIGAHUD_DIALOG_CANCEL = "CANCELAR",
    
    TORIGAHUD_TEXT_HEALTH = "SALUD",
    TORIGAHUD_TEXT_LEVEL = "NIVEL",
    TORIGAHUD_TEXT_XP = "EXPERIENCIA",
    TORIGAHUD_TEXT_MAGICKA = "MAGIA",
    TORIGAHUD_TEXT_STAMINA = "AGUANTE",
    TORIGAHUD_TEXT_TARGET_TEST = "OBJETIVO DE PRUEBA",
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId("SI_" .. stringId, stringValue)
end
