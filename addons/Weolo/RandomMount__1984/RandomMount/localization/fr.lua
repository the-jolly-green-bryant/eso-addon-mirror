-- @Origami: WARNING! Some of the new translations here are done via Google Translate. Sorry!
local strings = {
    RM_OP_HEADING1 = "Options pour les montures",
    RM_OP_HEADING2 = "Options pour animaux de compagnie",
    RM_OP_HEADING3 = "Montures",
    RM_OP_HEADING4 = "Animaux domestiques",
    RM_OP_HEADING6 = "Options pour les peau",
    RM_OP_HEADING7 = "Peaus",
    RM_OP_ACCOUNT = "Utiliser les paramètres du compte",
    RM_OP_MOUNTS_ENABLE = "Activer les montages aléatoires",
    RM_OP_MOUNTS_ENABLE_PVP = "Activer les montages aléatoires en pvp",
    RM_OP_MOUNTS_MULTI_GROUPED = "Préférez le multi-cavalier tout en étant groupé",
    RM_OP_MOUNTS_MULTI_COMPANION = "Préférez le multi-cavalier tout en étant accompagné",
    RM_OP_ACTIVATE_ZONE = "Randomiser sur zone de changement",
    RM_OP_ACTIVATE_DISMOUNT = "Randomiser sur dismount",
    RM_OP_PETS_ENABLE = "Activer les animaux aléatoires",
    RM_OP_SKINS_ENABLE = "Activer les peau aléatoires",
    RM_OP_DELAY = "Retard",
    RM_OP_DELAY_TT = "Le délai entre les montures aléatoires et les familiers et les peau",
    RM_OP_ALLOW_DEFAULT = "Autoriser l'habillage par défaut",
    RM_OP_PETS_UNSUMMON_PVP = "Désinvocation dans les zones pvp",
    RM_OP_PETS_UNSUMMON_DUNGEON = "Désinvocation dans les zones de donjon",
    RM_OP_PETS_UNSUMMON_GROUP = "Désinvocation en groupe"
}

if GetString(RM_OP_HEADING1):len() == 0 then
    for key, value in pairs(strings) do
        SafeAddVersion(key, 1)
        ZO_CreateStringId(key, value)
    end
end
