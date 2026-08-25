TetsuWritCrafter = TetsuWritCrafter or {}

local function IsGerman()
    local lang = GetCVar("language.2")
    if not lang or lang == "" then lang = GetCVar("Language.lang") end
    if (not lang or lang == "") and GetLanguage then lang = GetLanguage() end
    if lang then
        lang = string.lower(lang)
        return lang == "de" or string.sub(lang, 1, 2) == "de"
    end
    return false
end

if IsGerman() then
    local L = TetsuWritCrafter.L
    L.TITLE                   = "|cFFD700Tetsu's|r Writ Crafter"
    L.ALTS_SECTION_LABEL      = "Charaktere für Handwerksschriebe"
    L.ALTS_SECTION_TT         = "Charaktere für die täglichen Handwerksschriebe aktivieren oder deaktivieren."
    L.CHAR_ENABLED_TT         = "Tägliche Schriebe für <<1>> herstellen."
    
    L.KEYBIND_CRAFT_ALL       = "|c00FF00[R3]|r Für alle herstellen (<<1>> Stk.)"
    L.CONFIRM_TITLE           = "Massenherstellung von Schrieben"
    L.CONFIRM_PROMPT          = "<<1>> Gegenstände für alle aktiven Charaktere herstellen?"
    
    L.PROGRESS_CRAFTING       = "Gegenstände werden hergestellt..."
    L.PROGRESS_BANK_DEPOSIT   = "Bank: Gegenstände & Belohnungen einlagern..."
    L.PROGRESS_BANK_WITHDRAW  = "Bank: Schrieb-Gegenstände entnehmen..."
    L.PROGRESS_STATUS         = "Verarbeitet: <<1>> von <<2>>"
    
    L.ERR_NOT_ENOUGH_BANK     = "Nicht genug freie Bankplätze! Benötigt: <<1>>, Frei: <<2>>."
    L.ERR_BAG_FULL            = "Nicht genug Platz im Inventar! Benötigt: <<1>>, Frei: <<2>>."
    L.ERR_NOT_ENOUGH_MATS     = "Nicht genug Handwerksmaterialien vorhanden!"
    
    L.SYNC_STATUS             = "Synchronisiert: |c00FF00<<1>> von <<2>>|r. Erforderliche Logins: |cFFFF00<<3>>|r"
    L.READY_BRIEFING          = "Bereit! Muster: |cFFD700<<1>>|r. Aktive Twinks in Warteschlange: |cFFD700<<2>>|r."
end