local strings = {
    RM_OP_HEADING1 = "Mount Options",
    RM_OP_HEADING2 = "Pet Options",
    RM_OP_HEADING3 = "Mounts",
    RM_OP_HEADING4 = "Pets",
    RM_OP_HEADING6 = "Skin Options",
    RM_OP_HEADING7 = "Skins",
    RM_OP_ACCOUNT = "Use account wide settings",
    RM_OP_MOUNTS_ENABLE = "Enable random mounts",
    RM_OP_MOUNTS_ENABLE_PVP = "Enable random mounts in pvp",
    RM_OP_MOUNTS_MULTI_GROUPED = "Prefer multi-rider while grouped",
    RM_OP_MOUNTS_MULTI_COMPANION = "Prefer multi-rider while companion out",
    RM_OP_ACTIVATE_ZONE = "Randomise on area change",
    RM_OP_ACTIVATE_DISMOUNT = "Randomise on dismounting",
    RM_OP_PETS_ENABLE = "Enable random pets",
    RM_OP_SKINS_ENABLE = "Enable random skins",
    RM_OP_DELAY = "Delay",
    RM_OP_DELAY_TT = "The delay between random mounts, pets, and skins",
    RM_OP_ALLOW_DEFAULT = "Allow default skin",
    RM_OP_PETS_UNSUMMON_PVP = "Unsummon in PVP zones",
    RM_OP_PETS_UNSUMMON_DUNGEON = "Unsummon in Dungeon zones",
    RM_OP_PETS_UNSUMMON_GROUP = "Unsummon while grouped"
}

if GetString(RM_OP_HEADING1):len() == 0 then
    for key, value in pairs(strings) do
        SafeAddVersion(key, 1)
        ZO_CreateStringId(key, value)
    end
end
