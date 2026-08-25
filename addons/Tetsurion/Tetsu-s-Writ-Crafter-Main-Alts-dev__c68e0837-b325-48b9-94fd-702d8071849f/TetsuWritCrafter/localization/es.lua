TetsuWritCrafter = TetsuWritCrafter or {}

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
    local L = TetsuWritCrafter.L
    L.TITLE                   = "|cFFD700Tetsu's|r Writ Crafter"
    L.ALTS_SECTION_LABEL      = "Personajes para encargos"
    L.ALTS_SECTION_TT         = "Activar o desactivar personajes para los encargos diarios."
    L.CHAR_ENABLED_TT         = "Habilitar fabricación diaria para <<1>>."
    
    L.KEYBIND_CRAFT_ALL       = "|c00FF00[R3]|r Fabricar para todos (<<1>> uds.)"
    L.CONFIRM_TITLE           = "Fabricación en masa"
    L.CONFIRM_PROMPT          = "¿Fabricar <<1>> objetos para todos los personajes activos?"
    
    L.PROGRESS_CRAFTING       = "Fabricando encargos diarios..."
    L.PROGRESS_BANK_DEPOSIT   = "Banco: Depositando objetos y recompensas..."
    L.PROGRESS_BANK_WITHDRAW  = "Banco: Retirando objetos de encargos..."
    L.PROGRESS_STATUS         = "Procesado: <<1>> de <<2>>"
    
    L.ERR_NOT_ENOUGH_BANK     = "¡No hay suficiente espacio en el banco! Requerido: <<1>>, Libre: <<2>>."
    L.ERR_BAG_FULL            = "¡Inventario lleno! Requerido: <<1>>, Libre: <<2>>."
    L.ERR_NOT_ENOUGH_MATS     = "¡No hay suficientes materiales!"
    
    L.SYNC_STATUS             = "Sincronizado: |c00FF00<<1>> de <<2>>|r. Inicios pendientes: |cFFFF00<<3>>|r"
    L.READY_BRIEFING          = "¡Listo! Patrón: |cFFD700<<1>>|r. Personajes secundarios en cola: |cFFD700<<2>>|r."
end