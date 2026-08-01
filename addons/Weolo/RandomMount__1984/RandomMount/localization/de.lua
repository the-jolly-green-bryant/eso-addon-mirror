-- @Origami: WARNING! Some of the new translations here are done via Google Translate. Sorry!
local strings = {
    RM_OP_HEADING1 = "Optionen für Reittiere",
    RM_OP_HEADING2 = "Optionen für Haustiere",
    RM_OP_HEADING3 = "Reittiere",
    RM_OP_HEADING4 = "Haustiere",
    RM_OP_HEADING6 = "Optionen für Haut",
    RM_OP_HEADING7 = "Haut",
    RM_OP_ACCOUNT = "Verwenden Sie kontoweite Einstellungen",
    RM_OP_MOUNTS_ENABLE = "Zufällige Reittiere aktivieren",
    RM_OP_MOUNTS_ENABLE_PVP = "Zufällige Reittiere im PvP aktivieren",
    RM_OP_MOUNTS_MULTI_GROUPED = "Bevorzugen Sie mehrere Fahrer, während Sie gruppiert sind",
    RM_OP_MOUNTS_MULTI_COMPANION = "Bevorzugen Sie Multi-Rider, während Sie in Begleitung unterwegs sind",
    RM_OP_ACTIVATE_ZONE = "Randomisierung bei Flächenänderung",
    RM_OP_ACTIVATE_DISMOUNT = "Randomisierung beim Absteigen",
    RM_OP_PETS_ENABLE = "Zufällige Haustiere aktivieren",
    RM_OP_SKINS_ENABLE = "Zufällige Haut aktivieren",
    RM_OP_DELAY = "Verzögerung",
    RM_OP_DELAY_TT = "Die Verzögerung zwischen zufälligen Reittieren, Haustieren, und Haut",
    RM_OP_ALLOW_DEFAULT = "Standard-Skin zulassen",
    RM_OP_PETS_UNSUMMON_PVP = "in PvP-Zonen nicht beschworen",
    RM_OP_PETS_UNSUMMON_DUNGEON = "in Dungeonzonen nicht beschworen",
    RM_OP_PETS_UNSUMMON_GROUP = "Nicht beschworen, während gruppiert"
}

if GetString(RM_OP_HEADING1):len() == 0 then
    for key, value in pairs(strings) do
        SafeAddVersion(key, 1)
        ZO_CreateStringId(key, value)
    end
end
