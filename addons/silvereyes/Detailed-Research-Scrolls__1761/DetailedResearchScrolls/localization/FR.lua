local strings = {
    ["SI_DETAILEDRESEARCHSCROLLS_WARNING"]              = "Moins de <<1>> durée de recherche avec <<2[/1 day/$d days]>> restant.",
    ["SI_DETAILEDRESEARCHSCROLLS_ALL_TRAITS"]           = "<<1>>/<<2>> lignes de recherche avec tous les traits",
    ["SI_DETAILEDRESEARCHSCROLLS_NO_RESEARCH"]          = "Aucune recherche active",
    ["SI_DETAILEDRESEARCHSCROLLS_RESEARCH_SLOT_UNUSED"] = "<<IN:1>> emplacement de recherche non commencé",
}

-- Overwrite English strings
for stringId, value in pairs(strings) do
    DETAILEDRESEARCHSCROLLS_STRINGS[stringId] = value
end