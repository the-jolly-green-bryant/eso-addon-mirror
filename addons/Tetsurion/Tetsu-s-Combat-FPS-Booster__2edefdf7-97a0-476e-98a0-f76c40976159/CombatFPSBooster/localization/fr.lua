CombatFPSBooster = CombatFPSBooster or {}
CombatFPSBooster.L = CombatFPSBooster.L or {}

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
    CombatFPSBooster.L.TITLE          = "Tetsu's Combat FPS Booster"
    CombatFPSBooster.L.HIDE_INSTANCE   = "Masquer l'ATH pendant tout le donjon"
    CombatFPSBooster.L.HIDE_INSTANCE_TT= "Si activé : le compas et le suivi de quêtes restent masqués pendant tout le donjon de groupe, l'épreuve, l'arène ou les Archives infinies. XP, butin et annonces seulement en combat. Les antres et donjons publics sont ignorés."

    CombatFPSBooster.L.WHOLE_WHERE       = "Où s’applique le mode donjon entier"
    CombatFPSBooster.L.WHOLE_WHERE_TT    = "Où la boussole et le suivi de quêtes restent cachés entre les combats si ces options sont activées. XP, or, butin et CSA uniquement en combat. En Cyrodiil, la boussole reste visible."
    CombatFPSBooster.L.WHOLE_DUNGEON     = "Donjons et épreuves"
    CombatFPSBooster.L.WHOLE_DUNGEON_TT  = "Donjons de groupe et épreuves."
    CombatFPSBooster.L.WHOLE_ARENA       = "Arènes"
    CombatFPSBooster.L.WHOLE_ARENA_TT    = "Maelström, Dragonstar, Vateshran, Prison de la Rose noire."
    CombatFPSBooster.L.WHOLE_ARCHIVE     = "Archive infinie"
    CombatFPSBooster.L.WHOLE_ARCHIVE_TT  = "Sessions d'Archive infinie."
    CombatFPSBooster.L.WHOLE_BG          = "Champs de bataille"
    CombatFPSBooster.L.WHOLE_BG_TT       = "Matchs JCJ. Les préréglages d'addons ne changent pas ici."
    CombatFPSBooster.L.WHOLE_CYRO        = "Cyrodiil et Cité impériale"
    CombatFPSBooster.L.WHOLE_CYRO_TT     = "Guerre d'alliances. La boussole reste ; seul le suivi de quêtes peut rester caché entre les combats."
    CombatFPSBooster.L.PRESET_APPLY_PVP  = "Combat FPS Booster : impossible d'appliquer un préréglage en Cyrodiil ou sur un champ de bataille."
    CombatFPSBooster.L.HIDE_COMPASS   = "Masquer le compas en combat"
    CombatFPSBooster.L.HIDE_COMPASS_TT= "Masque complètement le compas pendant le combat."
    CombatFPSBooster.L.HIDE_QUESTS    = "Masquer les quêtes en combat"
    CombatFPSBooster.L.HIDE_QUESTS_TT = "Masque le suivi des quêtes pendant le combat."
    CombatFPSBooster.L.HIDE_ALERTS    = "Masquer les alertes en combat"
    CombatFPSBooster.L.HIDE_ALERTS_TT = "Masque XP, or et butin uniquement en combat. Le mode tout le donjon ne les garde pas masqués entre les combats."
    CombatFPSBooster.L.FILTER_MASTER    = "Dans le donjon, seulement les addons utiles"
    CombatFPSBooster.L.FILTER_MASTER_TT = "Filtre par personnage. En entrant dans un donjon de groupe, une épreuve, une arène ou les Archives infinies, la config actuelle est sauvée, seuls les addons cochés restent actifs, l'IU se recharge. En sortant, l'ancienne config revient. Antres et donjons publics ignorés."
    CombatFPSBooster.L.FILTER_ITEM_TT   = "On = garder l'addon dans le donjon. Off = le désactiver. Verrouillé tant que l'option ci-dessus est off."
    CombatFPSBooster.L.FILTER_EMPTY_WARN= "Combat FPS Booster : le filtre est actif, mais aucun addon n'est coché. Rien n'a été modifié."
    CombatFPSBooster.L.FILTER_APPLY     = "Combat FPS Booster : activation du préréglage "
    CombatFPSBooster.L.FILTER_APPLY_TAIL = ", rechargement de l'IU."
    CombatFPSBooster.L.FILTER_RESTORE   = "Combat FPS Booster : restauration des addons précédents, rechargement de l'IU."
    CombatFPSBooster.L.FILTER_NOAPI     = "Combat FPS Booster : impossible de changer l'état des addons. Pas de nouveau rechargement."
    CombatFPSBooster.L.FILTER_SECTION   = "Addons en donjon"
    CombatFPSBooster.L.FILTER_SECTION_TT= "Quels addons installés resteront actifs en donjon ou épreuve."
    CombatFPSBooster.L.PRESET_SELECT    = "Préréglage"
    CombatFPSBooster.L.PRESET_SELECT_TT = "Jeux d'addons enregistrés. Les préréglages sont communs au compte."
    CombatFPSBooster.L.PRESET_NAME      = "Nom du préréglage"
    CombatFPSBooster.L.PRESET_NAME_TT   = "Nom sous lequel enregistrer. Le même nom écrase le préréglage."
    CombatFPSBooster.L.PRESET_SAVE      = "Enregistrer le préréglage"
    CombatFPSBooster.L.PRESET_SAVE_BTN  = "Enregistrer"
    CombatFPSBooster.L.PRESET_SAVE_TT   = "Enregistre les cases actuelles sous ce nom."
    CombatFPSBooster.L.PRESET_DELETE    = "Supprimer le préréglage"
    CombatFPSBooster.L.PRESET_DELETE_BTN= "Supprimer"
    CombatFPSBooster.L.PRESET_DELETE_TT = "Supprime le préréglage choisi. Le dernier ne peut pas être supprimé."
    CombatFPSBooster.L.PRESET_DIVIDER   = "──────── addons ────────"
    CombatFPSBooster.L.PRESET_SAVED     = "Combat FPS Booster : préréglage enregistré : "
    CombatFPSBooster.L.PRESET_DELETED   = "Combat FPS Booster : préréglage supprimé : "
    CombatFPSBooster.L.PRESET_LAST      = "Combat FPS Booster : le dernier préréglage ne peut pas être supprimé."
    CombatFPSBooster.L.PRESET_NOW       = "Combat FPS Booster : préréglage actif : "
    CombatFPSBooster.L.HIDE_CSA       = "Masquer les annonces en combat"
    CombatFPSBooster.L.HIDE_CSA_TT    = "Masque les grandes annonces au centre uniquement en combat. Jamais pour tout le donjon."

end
