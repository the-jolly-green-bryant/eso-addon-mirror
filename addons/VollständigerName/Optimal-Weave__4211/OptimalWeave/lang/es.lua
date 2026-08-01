-- =============================================================================
-- === OptimalWeave Language File: Spanish (es.lua)                          ===
-- =============================================================================
--[[
    AddOn Name:         OptimalWeave
    File:               lang/es.lua
    Description:        Spanish localization using ZO_CreateStringId
    Version:            1.17.0
    Author:             Orollas & VollständigerName
--]]
-- =============================================================================

-- =============================================================================
-- == PANEL & AUTHOR INFORMATION ===============================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_PANEL_NAME", "|c6D6D6DOp|r|c8A8A8Atim|r|cA7A7A7al |r|cC4C4C4Wea|r|c6D6D6Dve|r")
ZO_CreateStringId("OW_MENU_AUTHORS", "|cEE82EEO|r|cDD74ECr|r|cCD65EAo|r|cBC57E8l|r|cAB48E6l|r|c9B3AE4a|r|c8A2BE2s|r & |cFFD700Vo|r|cF7D418l|r|cF3D324l|r|cEFD130s|r|cEBD03Ctä|r|cE3CD54n|r|cE0CC60d|r|cDCCA6Ci|r|cD8C978g|r|cD4C784e|r|cD0C690r|r|cCCC49CNa|r|cC4C1B4me|r")
ZO_CreateStringId("OW_MENU_WEBSITE", "https://github.com/VollstaendigerName")

-- =============================================================================
-- == INFORMATION SECTION ======================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_INFO_HEADER", "Información & LÉAME")
ZO_CreateStringId("OW_MENU_INFO_TEXT", "El tiempo de reutilización global (GCD) es de 1000 ms. OptimalWeave gestiona la cola de habilidades según el modo seleccionado para optimizar el weaving. Usa los ajustes para personalizar su comportamiento.")
ZO_CreateStringId("OW_MENU_MODE_HEADER", "Mecánicas Principales")
ZO_CreateStringId("OW_MENU_CONDITIONS_HEADER", "Reglas de Activación")
ZO_CreateStringId("OW_MENU_ADVANCED_HEADER", "Controles Avanzados")
ZO_CreateStringId("OW_MENU_PERFORMANCE_HEADER", "Ajustes de Rendimiento")
ZO_CreateStringId("OW_MENU_MODE_ACTIVE", "Addon activo")
ZO_CreateStringId("OW_MENU_MODE_INACTIVE", "Addon inactivo")
ZO_CreateStringId("OW_MENU_DISABLED_TOOLTIP", "Esta opción está desactivada actualmente")
ZO_CreateStringId("OW_MENU_LATENCY_WARNING", "¡Advertencia: Alta latencia puede causar retrasos!")

ZO_CreateStringId("OW_MENU_DISCLAIMER_LABEL", "|cFF0000Aviso|r") 
ZO_CreateStringId("OW_MENU_DISCLAIMER_TOOLTIP",  "|cFF0000Descargo de responsabilidad:|r Este complemento no está creado, afiliado ni respaldado por ZeniMax Media Inc. The Elder Scrolls® y los logotipos relacionados son marcas registradas de ZeniMax Media Inc. en EE. UU. y/o otros países. Todos los derechos reservados.")

-- =============================================================================
-- == CORE SETTINGS ============================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_SETTINGS_HEADER", "Ajustes Principales")
ZO_CreateStringId("OW_MENU_MODE_LABEL", "Modo de Operación")
ZO_CreateStringId("OW_MENU_MODE_TOOLTIP", "|c00FF00Secuencial:|r Permite usar habilidades solo después de realizar un ataque ligero.\n|cFF0000Estricto:|r Bloqueo total. Sin cola durante GCD.\n|cFFFF00Inteligente:|r Cola permitida solo sin ataque ligero pendiente.\n|c00FFFFNinguno:|r Desactivado.")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_COND", "Secuencial")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_HARD", "Estricto")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_SOFT", "Inteligente")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_NONE", "Ninguno")
ZO_CreateStringId("OW_MENU_COMBAT_LABEL", "Activo Solo en Combate")
ZO_CreateStringId("OW_MENU_COMBAT_TOOLTIP", "Gestiona la cola solo durante combates.")
ZO_CreateStringId("OW_MENU_ENEMYTARGET_LABEL", "Requiere Objetivo Enemigo")
ZO_CreateStringId("OW_MENU_ENEMYTARGET_TOOLTIP", "Funciona solo con objetivos enemigos.")
ZO_CreateStringId("OW_MENU_BLOCKING_LABEL", "Ignorar al Bloquear")
ZO_CreateStringId("OW_MENU_BLOCKING_TOOLTIP", "Desactiva controles durante bloqueos.")
ZO_CreateStringId("OW_MENU_GROUNDAOE_LABEL", "Bloquear Doble Lanzamiento en Área")
ZO_CreateStringId("OW_MENU_GROUNDAOE_TOOLTIP", "Previene lanzamientos accidentales dobles.")
ZO_CreateStringId("OW_MENU_DISABLE_TANK", "Desactivar como Tanque")
ZO_CreateStringId("OW_MENU_DISABLE_TANK_TOOLTIP", "Desactiva automáticamente en rol de Tanque")
ZO_CreateStringId("OW_MENU_DISABLE_HEAL", "Desactivar como Sanador")
ZO_CreateStringId("OW_MENU_DISABLE_HEAL_TOOLTIP", "Desactiva automáticamente en rol de Sanador")

ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_BACKBAR", "Desactivar funciones en la barra secundaria")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_BACKBAR_TOOLTIP", "Desactiva la mayoría de las funciones del addon en la barra secundaria.")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_BACKBAR", "Desactivar asistente de weaving en la barra secundaria")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_BACKBAR_TOOLTIP", "Desactiva el asistente de weaving (gestión GCD) en la barra secundaria.")

ZO_CreateStringId("OW_MENU_DEACTIVATE_IN_PVP_HEADER", "Desactivación en PvP")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_IN_PVP", "Desactivar funciones en PvP")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_IN_PVP_TOOLTIP", "Desactiva la mayoría de las funciones del addon en áreas PvP")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_IN_PVP", "Desactivar asistente de tejido en PvP")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_IN_PVP_TOOLTIP", "Desactiva el asistente de tejido (gestión de GCD) en áreas PvP")

-- =============================================================================
-- == BLOCK ID SETTINGS ========================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_BLOCKED_HEADER", "Habilidades Bloqueadas")
ZO_CreateStringId("OW_MENU_BLOCKED_ADD_LABEL", "Bloquear Nueva ID")
ZO_CreateStringId("OW_MENU_BLOCKED_ADD_TOOLTIP", "Ingresa un ID de habilidad (ej. 134160)")
ZO_CreateStringId("OW_MENU_BLOCKED_LIST_LABEL", "IDs Bloqueadas Actualmente")
ZO_CreateStringId("OW_MENU_BLOCKED_LIST_TOOLTIP", "Clic para eliminar")

-- =============================================================================
-- == ADVANCED SETTINGS ========================================================
-- =============================================================================
ZO_CreateStringId("OW_MENU_CHANNEL_NORMAL", "Margen Instantáneo (ms)")
ZO_CreateStringId("OW_MENU_CHANNEL_NORMAL_TOOLTIP", "Margen de seguridad para habilidades instantáneas (0-100 ms)")
ZO_CreateStringId("OW_MENU_CHANNEL_CHANNELED", "Margen Canalizado (ms)")
ZO_CreateStringId("OW_MENU_CHANNEL_CHANNELED_TOOLTIP", "Margen para habilidades canalizadas (0-400 ms)")
ZO_CreateStringId("OW_MENU_GCD_SLOT", "Slot de Seguimiento GCD")
ZO_CreateStringId("OW_MENU_GCD_SLOT_TOOLTIP", "Slot de la barra para detectar GCD (1-8)")
ZO_CreateStringId("OW_MENU_RESET_TIME_LABEL", "Tiempo de reinicio (segundos)")
ZO_CreateStringId("OW_MENU_RESET_TIME_TOOLTIP", "Reinicia el seguimiento después de no lanzar nada durante esta cantidad de segundos.")
ZO_CreateStringId("OW_MENU_AUTO_GCD_SLOT_LABEL", "Ranura de seguimiento GCD automática")
ZO_CreateStringId("OW_MENU_AUTO_GCD_SLOT_TOOLTIP", "Selecciona automáticamente la mejor ranura de seguimiento GCD de las ranuras 3-8")
ZO_CreateStringId("OW_MENU_MIN_GCD", "Umbral Mínimo GCD (ms)")
ZO_CreateStringId("OW_MENU_MIN_GCD_TOOLTIP", "Duración mínima del GCD para detectar (0-20 ms)")
ZO_CreateStringId("OW_MENU_QUEUE_TIME", "Tiempo Base de Cola (ms)")
ZO_CreateStringId("OW_MENU_QUEUE_TIME_TOOLTIP", "Ventana predeterminada de cola (100-2000 ms)")
ZO_CreateStringId("OW_MENU_RESETONBARSWAP_LABEL", "Reiniciar al cambiar de arma")
ZO_CreateStringId("OW_MENU_RESETONBARSWAP_TOOLTIP", "Reinicia el GCD al cambiar de arma")
ZO_CreateStringId("OW_MENU_RESETONDODGE_LABEL", "Reiniciar al esquivar")
ZO_CreateStringId("OW_MENU_RESETONDODGE_TOOLTIP", "Reinicia el GCD al realizar una esquivada")
ZO_CreateStringId("OW_MENU_AUTO_EQUIP_WEAPONS_LABEL", "Desenvainar automáticamente")
ZO_CreateStringId("OW_MENU_AUTO_EQUIP_WEAPONS_TOOLTIP", "Desenvainar armas automáticamente en combate")
ZO_CreateStringId("OW_MENU_RESET_SETTINGS_LABEL", "Restablecer todo")
ZO_CreateStringId("OW_MENU_RESET_SETTINGS_TOOLTIP", "Restablecer toda la configuración a los valores predeterminados")

-- =============================================================================
-- == LATENCY COMPENSATION =====================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_LATENCY_HEADER", "Compensación de Latencia")
ZO_CreateStringId("OW_MENU_AUTOLATENCY_LABEL", "Ajuste Automático")
ZO_CreateStringId("OW_MENU_AUTOLATENCY_TOOLTIP", "Ajusta automáticamente según la latencia. Recomendado para conexiones estables.")
ZO_CreateStringId("OW_MENU_MANUALLATENCY_LABEL", "Latencia Manual (ms)")
ZO_CreateStringId("OW_MENU_MANUALLATENCY_TOOLTIP", "Valor fijo para conexiones inestables (0-200 ms).")

-- =============================================================================
-- == (SUB)CLASS SETTINGS ======================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_SUBCLASS_HEADER", "Configuraciones específicas de clase y gremio")

ZO_CreateStringId("OW_MENU_SUBCLASS_GRIMFOCUS", "Enfoque Sombrío")

ZO_CreateStringId("OW_MENU_GRIMFOCUS_STACKS", "Stacks necesarios")
ZO_CreateStringId("OW_MENU_GRIMFOCUS_STACKS_TOOLTIP", "Número de stacks requeridos antes de que se active el Enfoque Sombrío (Recomendado: 10)")

ZO_CreateStringId("OW_MENU_GRIMFOCUS_ALL_MORPHS", "Bloquear todos los morphs de Enfoque Sombrío")
ZO_CreateStringId("OW_MENU_GRIMFOCUS_ALL_MORPHS_TOOLTIP", "|cFF5555• Enfoque Incansable:|r Siempre bloqueado\n|cFFFF00• Enfoque Sombrío y Determinación Despiadada:|r Sólo se puede usar a 10 stacks\n|cAAAAAADesactivar:|r Comportamiento predeterminado para todos los morphs")

ZO_CreateStringId("OW_MENU_GRIMFOCUS_GRIMFOCUSSTACKS_TOOGLE", "Activar stacks personalizados")
ZO_CreateStringId("OW_MENU_GRIMFOCUS_GRIMFOCUSSTACKS_TOOGLE_TOOLTIP", "|cFFD700Activado:|r Usa la configuración de stacks \n|cAAAAAADesactivado:|r Bloquea siempre el Enfoque Sombrío y la Determinación Despiadada hasta 10 stacks, y bloquea siempre el Enfoque Incansable\n")

-- == BLOCK GUILDS SETTINGS ===================================================
ZO_CreateStringId("OW_MENU_SUBCLASS_GUILDS", "Gremios")
ZO_CreateStringId("OW_MENU_HUNTER_ALL_MORPHS", "Bloquear habilidades de cazador del Gremio de Guerreros")
ZO_CreateStringId("OW_MENU_HUNTER_ALL_MORPHS_TOOLTIP", "Bloquea todos los morphs de habilidades de cazador del Gremio de Guerreros (Cazador experto, Cazador camuflado & Cazador del mal)")
ZO_CreateStringId("OW_MENU_LIGHT_ALL_MORPHS", "Bloquear habilidades de luz del Gremio de Magos")
ZO_CreateStringId("OW_MENU_LIGHT_ALL_MORPHS_TOOLTIP", "Bloquea todos los morphs de habilidades de luz (Luz mágica, Luz interior & Luz mágica radiante)")

ZO_CreateStringId("OW_MENU_DEACTIVATEHUNTERLIGHTINPVP_ALL_MORPHS", "Desactivar en PvP")
ZO_CreateStringId("OW_MENU_DEACTIVATEHUNTERLIGHTINPVP_ALL_MORPHS_TOOLTIP", "Desactiva el bloqueo de habilidades de Cazador/Luz en áreas PvP")

-- == BLOCK MOLTEN WHIP SETTINGS ===============================================
ZO_CreateStringId("OW_MENU_SUBCLASS_MOLTENWHIP", "Latigazo Fulminante")
ZO_CreateStringId("OW_MENU_MOLTENWHIP_BLOCK", "Bloquear habilidad Latigazo Fulminante")
ZO_CreateStringId("OW_MENU_MOLTENWHIP_BLOCK_TOOLTIP", "Bloquea la habilidad Latigazo Fulminante para evitar perder las tres acumulaciones")

-- == BLOCK FATECARVER SETTINGS ================================================
ZO_CreateStringId("OW_MENU_SUBCLASS_FATECARVER", "Arcanist Fatecarver")
ZO_CreateStringId("OW_MENU_FATECARVER_ALL_MORPHS", "Bloquear Fatecarver")
ZO_CreateStringId("OW_MENU_FATECARVER_ALL_MORPHS_TOOLTIP", "Evita lanzar Fatecarver hasta cumplir condiciones.")
ZO_CreateStringId("OW_MENU_CRUX_STACKS", "Stacks de Crux requeridos")
ZO_CreateStringId("OW_MENU_CRUX_STACKS_TOOLTIP", "Stacks de Crux mínimos para lanzar Fatecarver (Recomendado: 3)")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM", "Umbral de HP (%)")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM_TOOLTIP", "Desactiva el bloqueo de Fatecarver cuando HP está por debajo de este valor")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM_TOOGLE", "Activar verificación de HP para Fatecarver")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM_TOOGLE_TOOLTIP", "Desactiva el bloqueo de Fatecarver cuando tu salud es baja")

ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM", "Umbral de Aguante (%)")
ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM_TOOLTIP", "Desactiva el bloqueo de Fatecarver cuando el Aguante es bajo")
ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM_TOOGLE", "Activar verificación de Aguante para Fatecarver")
ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM_TOOGLE_TOOLTIP", "Desactiva el bloqueo de Fatecarver cuando tu aguante es bajo")

-- == BLOCK CEPHALIARCH'S FLAIL SETTINGS =======================================
ZO_CreateStringId("OW_MENU_SUBCLASS_CEPHALIARCHSFLAIL", "Flagelo del Cefaliarca")
ZO_CreateStringId("OW_MENU_CEPHALIARCHSFLAIL", "Bloquear Flagelo del Cefaliarca")
ZO_CreateStringId("OW_MENU_CEPHALIARCHSFLAIL_TOOLTIP", "Bloquea el Flagelo del Cefaliarca cuando tienes 3 acumulaciones de Crux")

-- == BLOCK TENTACULAR DREAD SETTINGS ==========================================
ZO_CreateStringId("OW_MENU_SUBCLASS_TENTACULAR", "Pavor tentacular")
ZO_CreateStringId("OW_MENU_TENTACULAR", "Bloquear Pavor tentacular")
ZO_CreateStringId("OW_MENU_TENTACULAR_TOOLTIP", "Bloque la habilidad Pavor tentacular hasta que se cumplan las condiciones.")

-- == Execute Check Settings ==========================================
ZO_CreateStringId("OW_MENU_EXECUTE_HEADER", "Verificación de Ejecución")
ZO_CreateStringId("OW_MENU_EXECUTE_ENABLE", "Activar verificación de ejecución")
ZO_CreateStringId("OW_MENU_EXECUTE_ENABLE_TOOLTIP", "Activa o desactiva la función de verificación de ejecución")
ZO_CreateStringId("OW_MENU_EXECUTE_THRESHOLD", "Umbral de Ejecución (%)")
ZO_CreateStringId("OW_MENU_EXECUTE_THRESHOLD_TOOLTIP", "Porcentaje de salud del objetivo por debajo del cual se permiten hechizos de ejecución")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELLS_HEADER", "Hechizos de Ejecución")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_MAGESFURYMORPHS", "Ira de los magos, Furia de los magos, Furia interminable")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_MAGESFURYMORPHS_TOOLTIP", "Bloquea los morphs de Furia de los magos hasta que el objetivo esté en rango de ejecución")

ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_REVERSESLASHMORPHS", "Tajo inverso, Corte inverso, Verdugo")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_REVERSESLASHMORPHS_TOOLTIP", "Bloquea los morphs de Tajo inverso hasta que el objetivo esté en rango de ejecución")

-- == Grouped Execute Spells ==========================================
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_RADIANTMORPHS", "Destrucción Radiante, Gloria Radiante, Opresión Radiante")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_RADIANTMORPHS_TOOLTIP", "Bloquea los morphs de Destrucción Radiante hasta que el objetivo esté en rango de ejecución")

ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_ASSASSINSBLADEMORPHS", "Hoja del Asesino, Empalar, Hoja del Asesino")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_ASSASSINSBLADEMORPHS_TOOLTIP", "Bloquea los morphs de Hoja del Asesino hasta que el objetivo esté en rango de ejecución")

-- == Work in progress ================================================
ZO_CreateStringId("OW_WIP", "WIP")

-- =============================================================================
-- == WEAPON SETTINGS ==========================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HEADER", "Desactivar según tipo de arma")

ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_WEAPON", "Desactivar asistente de weaving en tipo de arma")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_WEAPON_TOOLTIP", "Desactiva solo el asistente de weaving (gestión GCD) para tipos de arma seleccionados")

ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_WEAPON", "Desactivar funciones en tipo de arma")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_WEAPON_TOOLTIP", "Desactiva la mayoría de funciones del addon para tipos de arma seleccionados")

-- Armas de una mano
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_AXE", "Hacha")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_AXE_TOOLTIP", "Desactivar cuando se equipe un hacha")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HAMMER", "Martillo")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HAMMER_TOOLTIP", "Desactivar cuando se equipe un martillo")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SWORD", "Espada")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SWORD_TOOLTIP", "Desactivar cuando se equipe una espada")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_DAGGER", "Daga")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_DAGGER_TOOLTIP", "Desactivar cuando se equipe una daga")

-- Armas de dos manos
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_SWORD", "Espada de dos manos")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_SWORD_TOOLTIP", "Desactivar cuando se equipe una espada de dos manos")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_AXE", "Hacha de dos manos")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_AXE_TOOLTIP", "Desactivar cuando se equipe un hacha de dos manos")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_HAMMER", "Martillo de dos manos")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_HAMMER_TOOLTIP", "Desactivar cuando se equipe un martillo de dos manos")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_BOW", "Arco")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_BOW_TOOLTIP", "Desactivar cuando se equipe un arco")

-- Bastones
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FIRE_STAFF", "Bastón de fuego")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FIRE_STAFF_TOOLTIP", "Desactivar cuando se equipe un bastón de fuego")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FROST_STAFF", "Bastón de escarcha")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FROST_STAFF_TOOLTIP", "Desactivar cuando se equipe un bastón de escarcha")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_LIGHTNING_STAFF", "Bastón de rayo")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_LIGHTNING_STAFF_TOOLTIP", "Desactivar cuando se equipe un bastón de rayo")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HEALING_STAFF", "Bastón de curación")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HEALING_STAFF_TOOLTIP", "Desactivar cuando se equipe un bastón de curación")

-- Otras armas
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SHIELD", "Escudo")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SHIELD_TOOLTIP", "Desactivar cuando se equipe un escudo")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RUNE", "Runa")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RUNE_TOOLTIP", "Desactivar cuando se equipe una runa")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_NONE", "Sin arma")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_NONE_TOOLTIP", "Desactivar cuando no se equipe arma")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RESERVED", "Arma reservada")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RESERVED_TOOLTIP", "Desactivar cuando se equipe un tipo de arma reservado")

-- =============================================================================
-- == CUSTOM BLOCK LIST SETTINGS ===============================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_BLOCKLIST_HEADER", "Listas de bloqueo personalizadas")
ZO_CreateStringId("OW_MENU_CONFIGURABLEBLOCK_HEADER", "Lista de Bloqueo Personalizada")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_DESC", "Añade IDs de hechizos para bloquearlos. También puedes añadir hechizos haciendo clic derecho en la ranura de la barra de acción (requiere recarga)")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_SPELLID_LABEL", "ID de Hechizo")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_SPELLID_TOOLTIP", "Introduce el ID numérico del hechizo (ej. 185805)")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_ADD_BUTTON", "Añadir a la Lista de Bloqueo")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_LIST_HEADER", "Hechizos Bloqueados:")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST", "Activar Lista de Bloqueo Personalizada")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_TOOLTIP", "Activa o desactiva la funcionalidad de la lista de bloqueo personalizada")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_SV_DESC", "Revisa tu archivo SavedVariables:\n customBlockList = {\n   [SpellID] = false/true\n }")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_HEALTH_CHECK", "Activar verificación de salud para la lista de bloqueo")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_HEALTH_CHECK_TOOLTIP", "Cuando está activado, los hechizos en la lista de bloqueo solo se bloquearán si tu salud está por encima del umbral.")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_HEALTH_PERCENT", "Umbral de salud para la lista de bloqueo (%)")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_HEALTH_PERCENT_TOOLTIP", "Los hechizos de la lista de bloqueo solo se bloquean cuando tu salud está por encima de este porcentaje.")

-- =============================================================================
-- == CUSTOM RECAST BLOCK LIST SETTINGS ========================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_CONFIGURABLERECASTBLOCK_HEADER", "Lista de Bloqueo de Relanzamiento Personalizada")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_DESC", "Añade IDs de hechizos para bloquear su relanzamiento hasta que el tiempo restante del efecto esté por debajo del umbral. También puedes añadir hechizos haciendo clic derecho en la ranura de la barra de acción (requiere recarga).")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_SPELLID_LABEL", "ID de Hechizo")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_SPELLID_TOOLTIP", "Introduce el ID numérico del hechizo (ej. 185805)")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_ADD_BUTTON", "Añadir a la Lista de Bloqueo de Relanzamiento")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_LIST_HEADER", "Hechizos Bloqueados para Relanzamiento:")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST", "Activar Lista de Bloqueo de Relanzamiento Personalizada")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST_TOOLTIP", "Activa o desactiva la funcionalidad de la lista de bloqueo de relanzamiento personalizada")
ZO_CreateStringId("OW_MENU_RECAST_BLOCK_TIME", "Tiempo de Bloqueo de Relanzamiento (s)")
ZO_CreateStringId("OW_MENU_RECAST_BLOCK_TIME_TOOLTIP", "Tiempo en segundos por debajo del cual un hechizo en la lista de bloqueo de relanzamiento puede ser lanzado de nuevo (1.0 = 1 segundo)")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_SV_DESC", "Revisa tu archivo SavedVariables:\n customRecastBlockList = {\n   [SpellID] = false/true\n }")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST_HEALTH_CHECK", "Activar verificación de salud para la lista de bloqueo de relanzamiento")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST_HEALTH_CHECK_TOOLTIP", "Cuando está activado, los hechizos en la lista de bloqueo de relanzamiento solo se bloquearán si tu salud está por encima del umbral.")
ZO_CreateStringId("OW_MENU_CUSTOM_RECAST_BLOCK_LIST_HEALTH_PERCENT", "Umbral de salud para la lista de bloqueo de relanzamiento (%)")
ZO_CreateStringId("OW_MENU_CUSTOM_RECAST_BLOCK_LIST_HEALTH_PERCENT_TOOLTIP", "Los hechizos de la lista de bloqueo de relanzamiento solo se bloquean cuando tu salud está por encima de este porcentaje.")

-- =============================================================================

ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_MAIN_TEXT", "El ID del hechizo ha sido añadido/eliminado. Si no quieres añadir o eliminar más hechizos, por favor recarga la interfaz para que los cambios se muestren.")
ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_BUTTON_YES", "Recargar interfaz")
ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_BUTTON_LATER", "Más tarde")

ZO_CreateStringId("OW_MENU_DIALOG_BUTTON_OK", "OK")
ZO_CreateStringId("OW_MENU_INVALID_ID_DIALOG_MAIN_TEXT", "Error: Por favor introduce un ID de hechizo válido")
ZO_CreateStringId("OW_MENU_ID_NOT_EXIST_DIALOG_MAIN_TEXT", "El ID del hechizo no existe")
ZO_CreateStringId("OW_MENU_ID_IS_IN_SV_DIALOG_MAIN_TEXT", "El ID del hechizo ya está en la lista de bloqueo")

-- =============================================================================
-- == RESOURCE-BASED BLOCK LIST SETTINGS =======================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_CONFIGURABLEBLOCK_RESOURCE_HEADER", "Lista de bloqueo basada en recursos")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_RESOURCE_DESC", "Añade IDs de hechizos para bloquearlos cuando tu recurso principal (Magia o Aguante) esté por debajo del umbral. También puedes añadir hechizos haciendo clic derecho en la ranura de la barra de acción (requiere recarga).")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RESOURCE_BLOCK_LIST", "Activar lista de bloqueo basada en recursos")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RESOURCE_BLOCK_LIST_TOOLTIP", "Activa o desactiva la funcionalidad de la lista de bloqueo basada en recursos")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_RESOURCE_CHECK", "Activar verificación de recursos")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_RESOURCE_CHECK_TOOLTIP", "Cuando está activado, los hechizos en la lista de bloqueo de recursos solo se bloquearán si tu recurso principal (Magia o Aguante) está por encima del umbral.")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_RESOURCE_PERCENT", "Umbral de recurso (%)")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_RESOURCE_PERCENT_TOOLTIP", "Los hechizos de la lista de bloqueo de recursos solo se bloquean cuando tu recurso principal (Magia o Aguante) está por encima de este porcentaje.")
ZO_CreateStringId("OW_MENU_RESOURCE_BLOCK_SPELL", "Hechizo: ")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_CHECK", "Verificación de Magia")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_CHECK_TOOLTIP", "Activar el bloqueo basado en Magia para este hechizo")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_BLOCK_MODE", "Bloquear cuando la Magia esté por debajo del umbral")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_BLOCK_MODE_TOOLTIP", "Bloquear hechizo cuando la Magia esté por debajo del umbral (desmarcar para permitir solo cuando esté por debajo)")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_THRESHOLD", "Umbral de Magia (%)")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_THRESHOLD_TOOLTIP", "Umbral de porcentaje de Magia")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_CHECK", "Verificación de Aguante")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_CHECK_TOOLTIP", "Activar el bloqueo basado en Aguante para este hechizo")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_BLOCK_MODE", "Bloquear cuando el Aguante esté por debajo del umbral")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_BLOCK_MODE_TOOLTIP", "Bloquear hechizo cuando el Aguante esté por debajo del umbral (desmarcar para permitir solo cuando esté por debajo)")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_THRESHOLD", "Umbral de Aguante (%)")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_THRESHOLD_TOOLTIP", "Umbral de porcentaje de Aguante")

-- =============================================================================
-- == KEYBINDINGS LOCALIZATION =================================================
-- =============================================================================

ZO_CreateStringId("SI_KEYBINDINGS_CATEGORY_OPTIMALWEAVE", "|c6D6D6DOpti|r|c8A8A8AmalWea|r|cC4C4C4ve|r")

ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_MODE", "Alternar Modo (Estricto/Inteligente/Desactivado)")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_CUSTOM_BLOCK_LIST", "Alternar Lista de Bloqueo Personalizada")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_CUSTOM_RECAST_BLOCK_LIST", "Alternar Lista de Bloqueo de Relanzamiento Personalizada")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_BACKBAR_FEATURES", "Alternar Desactivación de Funciones de la Barra Secundaria")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_BACKBAR_WEAVE_ASSIST", "Alternar Desactivación del Asistente de Tejido en la Barra Secundaria")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_EXECUTE_CHECK", "Alternar Verificación de Ejecución")

-- =============================================================================
-- == REMOVE BUTTON ============================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_REMOVE_BUTTON", "Eliminar")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_REMOVE_TOOLTIP", "Eliminar este hechizo de la lista de bloqueo (/reloadui requerido)")

-- =============================================================================
-- == SETTIINGS MODE ===========================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_MODE_SELECTION_LABEL", "Modo de configuración")
ZO_CreateStringId("OW_MENU_MODE_SELECTION_TOOLTIP", "Elige si la configuración se comparte entre todos los personajes de esta cuenta (Toda la cuenta) o se guarda por separado para cada personaje (Por personaje).")
ZO_CreateStringId("OW_MENU_MODE_ACCOUNTWIDE", "Toda la cuenta")
ZO_CreateStringId("OW_MENU_MODE_PERCHARACTER", "Por personaje")
ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_SETTINGS_MAIN_TEXT", "El modo de configuración ha cambiado. ¿Recargar la interfaz para aplicar los cambios?")

-- =============================================================================
-- == IN COMBAT MENU BLOCKING ==================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_BLOCK_LAST_MENU", "Bloquear último menú en combate")
ZO_CreateStringId("OW_MENU_BLOCK_LAST_MENU_TOOLTIP", "Evita abrir el último menú (ALT) mientras estás en combate.")
ZO_CreateStringId("OW_MENU_BLOCK_CHAR_MENU", "Bloquear menú de personaje en combate")
ZO_CreateStringId("OW_MENU_BLOCK_CHAR_MENU_TOOLTIP", "Evita abrir el menú de personaje (C) mientras estás en combate.")

-- =============================================================================
-- == GCD DISPLAY ==============================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_SHOW_GCD_LABEL", "Mostrar tiempo de reutilización global (GCD)")
ZO_CreateStringId("OW_MENU_SHOW_GCD_TOOLTIP", "Muestra el indicador GCD (proporcionado por ZOS) sobre la barra de acciones.")

-- =============================================================================
-- == BLOCKLIST COMBAT ONLY ====================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_BLOCKLISTS_COMBAT_ONLY_LABEL", "Listas de bloqueo solo en combate")
ZO_CreateStringId("OW_MENU_BLOCKLISTS_COMBAT_ONLY_TOOLTIP", "Todas las listas de bloqueo personalizadas solo están activas mientras estás en combate. Fuera del combate, todas las listas de bloqueo están desactivadas.")

-- =============================================================================
-- === END OF SPANISH LOCALIZATION =============================================
-- =============================================================================