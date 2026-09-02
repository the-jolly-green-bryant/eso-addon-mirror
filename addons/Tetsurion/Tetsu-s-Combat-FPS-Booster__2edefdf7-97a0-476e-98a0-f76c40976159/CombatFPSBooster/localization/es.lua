CombatFPSBooster = CombatFPSBooster or {}
CombatFPSBooster.L = CombatFPSBooster.L or {}

local function IsSpanish()
    local lang = GetCVar("language.2")
    if not lang or lang == "" then lang = GetCVar("Language.lang") end
    if (not lang or lang == "") and GetLanguage then lang = GetLanguage() end
    if lang then
        lang = string.lower(lang)
        return lang == "es" or string.sub(lang, 1, 2) == "es"
    end
    return false
end

if IsSpanish() then
    CombatFPSBooster.L.TITLE          = "Tetsu's Combat FPS Booster"
    CombatFPSBooster.L.HIDE_INSTANCE   = "Ocultar HUD en toda la mazmorra"
    CombatFPSBooster.L.HIDE_INSTANCE_TT= "Si está activo: la brújula y el rastreador de misiones se ocultan durante toda la mazmorra de grupo, prueba, arena o Archivo Infinito. XP, botín y anuncios solo en combate. Las cuevas y mazmorras públicas se ignoran."

    CombatFPSBooster.L.WHOLE_WHERE       = "Dónde actúa el modo mazmorra completa"
    CombatFPSBooster.L.WHOLE_WHERE_TT    = "Dónde la brújula y el rastreador de misiones siguen ocultos entre combates si esas opciones están on. XP, oro, botín y CSA solo en combate. En Cyrodiil la brújula no se oculta."
    CombatFPSBooster.L.WHOLE_DUNGEON     = "Mazmorras y ensayos"
    CombatFPSBooster.L.WHOLE_DUNGEON_TT  = "Mazmorras de grupo y ensayos."
    CombatFPSBooster.L.WHOLE_ARENA       = "Arenas"
    CombatFPSBooster.L.WHOLE_ARENA_TT    = "Vorágine, Dragonstar, Vateshran, Rosaleda."
    CombatFPSBooster.L.WHOLE_ARCHIVE     = "Archivo Infinito"
    CombatFPSBooster.L.WHOLE_ARCHIVE_TT  = "Partidas del Archivo Infinito."
    CombatFPSBooster.L.WHOLE_BG          = "Campos de batalla"
    CombatFPSBooster.L.WHOLE_BG_TT       = "Partidas JcJ. Los presets de addons no cambian aquí."
    CombatFPSBooster.L.WHOLE_CYRO        = "Cyrodiil y Ciudad Imperial"
    CombatFPSBooster.L.WHOLE_CYRO_TT     = "Guerra de alianzas. La brújula se queda; solo el rastreador puede seguir oculto entre combates."
    CombatFPSBooster.L.PRESET_APPLY_PVP  = "Combat FPS Booster: no se puede aplicar un preset en Cyrodiil o en un campo de batalla."
    CombatFPSBooster.L.HIDE_COMPASS   = "Ocultar brújula en combate"
    CombatFPSBooster.L.HIDE_COMPASS_TT= "Oculta la brújula durante el combate para mejorar el rendimiento."
    CombatFPSBooster.L.HIDE_QUESTS    = "Ocultar misiones en combate"
    CombatFPSBooster.L.HIDE_QUESTS_TT = "Oculta el rastreador de misiones durante el combate."
    CombatFPSBooster.L.HIDE_ALERTS    = "Ocultar alertas en combate"
    CombatFPSBooster.L.HIDE_ALERTS_TT = "Oculta XP, oro y botín solo en combate. El modo toda la mazmorra no los deja ocultos entre peleas."
    CombatFPSBooster.L.FILTER_MASTER    = "En mazmorra solo los addons necesarios"
    CombatFPSBooster.L.FILTER_MASTER_TT = "Filtro por personaje. Al entrar en mazmorra de grupo, prueba, arena o Archivo Infinito se guarda la config actual, solo quedan los addons marcados y se recarga la IU. Al salir se restaura. Cuevas y mazmorras públicas se ignoran."
    CombatFPSBooster.L.FILTER_ITEM_TT   = "On = mantener el addon en mazmorra. Off = desactivarlo. Bloqueado hasta activar la opción de arriba."
    CombatFPSBooster.L.FILTER_EMPTY_WARN= "Combat FPS Booster: el filtro está activo, pero ningún addon está marcado. No se cambió nada."
    CombatFPSBooster.L.FILTER_APPLY     = "Combat FPS Booster: activando el preset de addons "
    CombatFPSBooster.L.FILTER_APPLY_TAIL = ", recargando la IU."
    CombatFPSBooster.L.FILTER_RESTORE   = "Combat FPS Booster: restaurando la configuración anterior de addons, recargando la IU."
    CombatFPSBooster.L.FILTER_NOAPI     = "Combat FPS Booster: no se pudo cambiar el estado de los addons. No habrá otra recarga."
    CombatFPSBooster.L.FILTER_SECTION   = "Addons en mazmorra"
    CombatFPSBooster.L.FILTER_SECTION_TT= "Qué addons instalados se quedan activos en mazmorra o prueba."
    CombatFPSBooster.L.PRESET_SELECT    = "Ajuste"
    CombatFPSBooster.L.PRESET_SELECT_TT = "Conjuntos guardados. Los ajustes son de toda la cuenta."
    CombatFPSBooster.L.PRESET_NAME      = "Nombre del ajuste"
    CombatFPSBooster.L.PRESET_NAME_TT   = "Nombre al guardar. El mismo nombre sobrescribe el ajuste."
    CombatFPSBooster.L.PRESET_SAVE      = "Guardar ajuste"
    CombatFPSBooster.L.PRESET_SAVE_BTN  = "Guardar"
    CombatFPSBooster.L.PRESET_SAVE_TT   = "Guarda las casillas actuales con este nombre."
    CombatFPSBooster.L.PRESET_DELETE    = "Borrar ajuste"
    CombatFPSBooster.L.PRESET_DELETE_BTN= "Borrar"
    CombatFPSBooster.L.PRESET_DELETE_TT = "Borra el ajuste elegido. El último no se puede borrar."
    CombatFPSBooster.L.PRESET_DIVIDER   = "──────── addons ────────"
    CombatFPSBooster.L.PRESET_SAVED     = "Combat FPS Booster: ajuste guardado: "
    CombatFPSBooster.L.PRESET_DELETED   = "Combat FPS Booster: ajuste borrado: "
    CombatFPSBooster.L.PRESET_LAST      = "Combat FPS Booster: el último ajuste no se puede borrar."
    CombatFPSBooster.L.PRESET_NOW       = "Combat FPS Booster: ajuste activo: "
    CombatFPSBooster.L.HIDE_CSA       = "Ocultar anuncios en combate"
    CombatFPSBooster.L.HIDE_CSA_TT    = "Oculta los anuncios grandes del centro solo en combate. Nunca en toda la mazmorra."

end
