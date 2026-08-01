local strings = {
    ["SI_DETAILEDRESEARCHSCROLLS_WARNING"]              = "Weniger als <<1>> Analyse Zeitraum mit <<2[/1 Tag/$d Tagen]>> übrig.",
    ["SI_DETAILEDRESEARCHSCROLLS_ALL_TRAITS"]           = "<<1>>/<<2>> Fertigkeitslinien komplett analysiert.",
    ["SI_DETAILEDRESEARCHSCROLLS_NO_RESEARCH"]          = "Keine aktive Analyse.",
    ["SI_DETAILEDRESEARCHSCROLLS_RESEARCH_SLOT_UNUSED"] = "<<IN:1>> Analyseplatz ist nicht belegt.",
}

-- Overwrite English strings
for stringId, value in pairs(strings) do
    DETAILEDRESEARCHSCROLLS_STRINGS[stringId] = value
end