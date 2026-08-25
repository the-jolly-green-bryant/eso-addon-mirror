TetsuWritCrafter = TetsuWritCrafter or {}

local function IsFrench()
    local lang = GetCVar("language.2")
    if not lang or lang == "" then lang = GetCVar("Language.lang") end
    if (not lang or lang == "") and GetLanguage then lang = GetLanguage() end
    if lang then
        lang = string.lower(lang)
        return lang == "fr" or string.sub(lang, 1, 2) == "fr"
    end
    return false
end

if IsFrench() then
    local L = TetsuWritCrafter.L
    L.TITLE                   = "|cFFD700Tetsu's|r Writ Crafter"
    L.ALTS_SECTION_LABEL      = "Personnages pour les commandes"
    L.ALTS_SECTION_TT         = "Activer ou désactiver les personnages pour l'artisanat quotidien."
    L.CHAR_ENABLED_TT         = "Activer la fabrication pour <<1>>."
    
    L.KEYBIND_CRAFT_ALL       = "|c00FF00[R3]|r Tout fabriquer (<<1>> pcs)"
    L.CONFIRM_TITLE           = "Fabrication en masse"
    L.CONFIRM_PROMPT          = "Fabriquer <<1>> objets pour tous les personnages actifs ?"
    
    L.PROGRESS_CRAFTING       = "Fabrication des commandes en cours..."
    L.PROGRESS_BANK_DEPOSIT   = "Banque : Dépôt des objets et récompenses..."
    L.PROGRESS_BANK_WITHDRAW  = "Banque : Retrait des objets de commande..."
    L.PROGRESS_STATUS         = "Traité : <<1>> sur <<2>>"
    
    L.ERR_NOT_ENOUGH_BANK     = "Pas assez d'espace en banque ! Requis : <<1>>, Libre : <<2>>."
    L.ERR_BAG_FULL            = "Inventaire plein ! Requis : <<1>>, Libre : <<2>>."
    L.ERR_NOT_ENOUGH_MATS     = "Pas assez de matériaux !"
    
    L.SYNC_STATUS             = "Synchronisé : |c00FF00<<1>> sur <<2>>|r. Connexion requise sur : |cFFFF00<<3>>|r"
    L.READY_BRIEFING          = "Prêt ! Modèle : |cFFD700<<1>>|r. Personnages actifs : |cFFD700<<2>>|r."
end