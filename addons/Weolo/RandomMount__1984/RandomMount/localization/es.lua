-- @Origami: WARNING! Some of the new translations here are done via Google Translate. Sorry!
local strings = {
    RM_OP_HEADING1 = "Opciones de Montaje",
    RM_OP_HEADING2 = "Opciones de Mascotas",
    RM_OP_HEADING3 = "Monturas",
    RM_OP_HEADING4 = "Mascotas",
    RM_OP_HEADING6 = "Opciones de Piel",
    RM_OP_HEADING7 = "Piels",
    RM_OP_ACCOUNT = "Usar la configuración de toda la cuenta",
    RM_OP_MOUNTS_ENABLE = "Habilitar montajes aleatorios",
    RM_OP_MOUNTS_ENABLE_PVP = "Habilitar monturas aleatorias en pvp",
    RM_OP_MOUNTS_MULTI_GROUPED = "Prefiere multi-piloto mientras está agrupado",
    RM_OP_MOUNTS_MULTI_COMPANION = "Prefiere varios pasajeros mientras el acompañante está fuera",
    RM_OP_ACTIVATE_ZONE = "Aleatorizar en el cambio de área",
    RM_OP_ACTIVATE_DISMOUNT = "Aleatorizar al desmontar",
    RM_OP_PETS_ENABLE = "Habilitar mascotas aleatorias",
    RM_OP_SKINS_ENABLE = "Habilitar piel aleatorias",
    RM_OP_DELAY = "Demora",
    RM_OP_DELAY_TT = "La demora entre monturas aleatorias y mascotas y piel",
    RM_OP_ALLOW_DEFAULT = "Permitir máscara predeterminada",
    RM_OP_PETS_UNSUMMON_PVP = "Anular invocación en zonas pvp",
    RM_OP_PETS_UNSUMMON_DUNGEON = "Anular invocación en zonas de mazmorras",
    RM_OP_PETS_UNSUMMON_GROUP = "Anular la invocación mientras está agrupado"
}

if GetString(RM_OP_HEADING1):len() == 0 then
    for key, value in pairs(strings) do
        SafeAddVersion(key, 1)
        ZO_CreateStringId(key, value)
    end
end
