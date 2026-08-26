TetsuDailyWritPrecrafter = TetsuDailyWritPrecrafter or {}
local L = TetsuDailyWritPrecrafter.L
if not L then return end

L.TITLE                   = "|cFFD700Tetsu's|r Daily Writ Precrafter"

L.OPTIONS_SECTION_LABEL   = "Automatización"
L.OPTIONS_SECTION_TT      = "Opciones de automatización seguras para mando."
L.AUTO_QUEST_LABEL        = "Aceptar y entregar encargos de artesanía automáticamente"
L.AUTO_QUEST_TT           = "Coger encargos del tablón y entregarlos en las cajas automáticamente."
L.AUTO_BOX_LABEL          = "Abrir cajas de recompensa automáticamente"
L.AUTO_BOX_TT             = "Abrir los contenedores de encargos diarios en cuanto aparezcan en la mochila."

L.PRECRAFT_SECTION_LABEL  = "Precraft (este personaje)"
L.PRECRAFT_SECTION_TT     = "Los ajustes se guardan por personaje."
L.PRECRAFT_ENABLED_LABEL  = "Precraft para el futuro"
L.PRECRAFT_ENABLED_TT     = "Si está activado, R3 fabrica objetos para varios días según la rotación diaria. Si está desactivado, R3 solo fabrica lo que pide el encargo activo."
L.PRECRAFT_DAYS_LABEL     = "Días por delante"
L.PRECRAFT_DAYS_TT        = "Cuántos días precraftear (incluido hoy). Deslizador 1–10."

L.KEYBIND_PRECRAFT        = "|c00FF00[R3]|r Precraft <<1>> días (<<2>> uds.)"
L.KEYBIND_QUEST_CRAFT     = "|c00FF00[R3]|r Fabricar encargo activo (<<1>> uds.)"
L.KEYBIND_NOTHING         = "|c888888[R3]|r Nada que fabricar"

L.CONFIRM_TITLE_PRECRAFT  = "Precraft de encargos diarios"
L.CONFIRM_PROMPT_PRECRAFT = "¿Fabricar objetos para <<1>> días? (<<2>> objetos)"
L.CONFIRM_TITLE_QUEST     = "Fabricar encargo activo"
L.CONFIRM_PROMPT_QUEST    = "¿Fabricar los objetos del encargo activo? (<<1>> uds.)"

L.PROGRESS_CRAFTING       = "Fabricando..."
L.PROGRESS_STATUS         = "Procesado: <<1>> de <<2>>"

L.ERR_BAG_FULL            = "No hay espacio suficiente en la mochila (hacen falta ~<<1>> ranuras libres)."
L.ERR_NO_STYLE            = "No se encontró material de estilo conocido en la mochila o en la bolsa de artesanía."
L.ERR_MISSING_RUNES       = "Faltan runas de encantamiento (potencia / esencia / Ta)."
L.ERR_CANNOT_CRAFT        = "No se puede fabricar <<1>> (faltan materiales, estilo o habilidad)."
L.ERR_CRAFT_FAILED        = "Fallo al fabricar (<<1>>/<<2>>). Omitido."
L.ERR_NOT_AT_STATION      = "No estás en una estación de artesanía."
L.ERR_PROV_SKIP_UNKNOWN   = "Omitido (receta desconocida): <<1>>"
L.ERR_NOTHING_TO_CRAFT    = "Nada que fabricar."
L.ERR_NO_ACTIVE_WRIT      = "No hay un encargo de artesanía activo para esta estación."

L.PRECHECK_HEADER         = "|cFF6666[Tetsu's Daily Writ Precrafter]|r Materiales insuficientes. Fabricación cancelada:"
L.PRECHECK_JOBS           = "Trabajos en cola: |cFFFFFF<<1>>|r"
L.PRECHECK_LINE           = "  - |cFFD700<<1>>|r: necesita |cFFFFFF<<2>>|r, tiene |cFFFFFF<<3>>|r (|cFF6666-<<4>>|r)"
L.PRECHECK_ABORT          = "Añade los materiales que faltan y pulsa R3 de nuevo."
L.PRECHECK_OK             = "Comprobación de materiales OK. Fabricando |c00FF00<<1>>|r objetos..."

L.USING_QUEST_DATA        = "Usando datos del encargo activo."
L.USING_PREDICTED         = "Modo precraft: rotación diaria para <<1>> días."
L.CRAFT_DONE              = "Listo. Fabricados: |c00FF00<<1>>|r, omitidos: |cFFFF00<<2>>|r."
L.PATTERN_TODAY           = "Patrón de hoy: |cFFD700<<1>>|r"
