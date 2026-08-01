local strings = {
    SI_VOTANS_FILET_FISH_ALL = "Filetear Stack",
    SI_KEYBINDINGS_CATEGORY_FILET_FISH = "Filetear pescado",
    SI_BINDING_NAME_VOTANS_FISH_FILLET_ALL_STACKS = "Filetear todos los Stacks",
    SI_VOTANS_FILET_OPT_ALLSTACKS = "Mostrar \"Filetear todos los Stacks\"",
    SI_VOTANS_FILET_OPT_ALLSTACKS_TOOLTIP = "Si está habilitado, Votan's Fish Fillet procederá a filetear todos los stacks en su inventario después de que se complete el stack inicial.",
    SI_VOTANS_FILET_OPT_ALLSTACKS_ALWAYS = "Siempre filetear todos los stacks",
    SI_VOTANS_FILET_OPT_ALLSTACKS_ALWAYS_TOOLTIP = "Si está habilitado, Votan's Fish Fillet procederá a filetear todos los stacks en su inventario."
}

if GetString(RM_OP_HEADING1):len() == 0 then
    for key, value in pairs(strings) do
        SafeAddVersion(key, 1)
        ZO_CreateStringId(key, value)
    end
end
