local strings = {
    CMW_CRAFTING_MASTER = "^Majistral",
    CMW_BLACKSMITHING_WRIT = "Rubedita",
    CMW_CLOTHIER_WRIT1 = "Cuero Rubedo",
    CMW_CLOTHIER_WRIT2 = "Seda Ancestral",
    CMW_WOODWORKING = "Fresno Rubí",
    CMW_JEWELRYCRAFTING = "Platino",
    CMW_ST_BLACKSMITHING = "Taller de Herrería",
    CMW_ST_CLOTHIER = "Taller de Sastrería",
    CMW_ST_WOODWORKING = "Taller de Carpintería",
    CMW_ST_JEWELRY = "Mesa de Alquimia",
    CMW_ST_ALCHEMY = "Taller de Joyería",
    CMW_ST_PROVISIONING = "Mesa de Encantamientos",
    CMW_ST_ENCHANTING = "Fogón",
    CMW_DEBUG_LOG = "Mostrar registro de depuración",
    CMW_MOTIF = "(Diseño de artesanía <<1>>: <<3>> <<2>>)",
    CMW_MOTIF_RACIAL = "(Diseño de artesanía <<1>>: Estilo <<2>>)",
}

if GetString(RM_OP_HEADING1):len() == 0 then
    for key, value in pairs(strings) do
        SafeAddVersion(key, 1)
        ZO_CreateStringId(key, value)
    end
end