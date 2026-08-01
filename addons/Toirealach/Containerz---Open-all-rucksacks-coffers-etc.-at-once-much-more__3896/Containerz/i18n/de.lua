Containerz = Containerz or {}

local localization = {

    LOADED_STR = "%s %s %s",
    WAS_LOADED = "geladen",
    NOT_LOADED = "nicht geladen",
     
    OPEN_ALL_CONTAINERZ = "Alle Container öffnen",
    STOP_OPENING_CONTAINERZ = "Container nicht mehr öffnen",
    WILL_OPEN = "Wird einen öffnen %s",
    WONT_OPEN = "Wird keinen öffnen %s",

    TRANSMUTES_NAME = "Überschreiten Sie nicht das Transmutationskristalllimit",
    TRANSMUTES_TOOLTIP = "Wenn die Möglichkeit besteht, dass Sie mit einer Transmutationsgeode das Limit von 1000 Transmutationskristallen überschreiten, öffnen Sie diese Geode nicht automatisch",
    GLADIATORS_NAME = "Öffnen Sie nur einen Arena-Gladiatorenrucksack pro Tag",
    GLADIATORS_TOOLTIP = "Nur einmal pro Tag, wenn Sie einen Arena-Gladiatorenrucksack öffnen, erhalten Sie einen Arena-Gladiatorenbeweis, öffnen Sie also nur automatisch pro Tag",
    SIEGEMASTERS_NAME = "Öffnen Sie nur eine Belagerungsmeistertruhe pro Tag",
    SIEGEMASTERS_TOOLTIP = "Nur einmal pro Tag, wenn Sie einen Arena-Gladiatorenrucksack öffnen, erhalten Sie einen Arena-Gladiatorenbeweis, öffnen Sie also nur automatisch pro Tag, In der Truhe des Belagerungsmeisters erhältst du ein Verdienst für die Belagerung von Cyrodiil, also öffne nur automatisch eine pro Tag",
    SCROLLKEEPERS_NAME = "Öffne nur einen Schriftrollenbewahrer-Rucksack pro Tag",
    SCROLLKEEPERS_TOOLTIP = "Nur einmal pro Tag, wenn du einen Schriftrollenbewahrer-Rucksack öffnest, erhältst du Schriftstücke, also öffne nur automatisch einen pro Tag",
    
    GLADIATORS_VERIFY = "Haben Sie heute schon einen Gladiatorenrucksack geöffnet?\nWenn Sie sich nicht erinnern, sagen Sie einfach 'Ja'.",
    SIEGEMASTERS_VERIFY = "Haben Sie heute schon eine Belagerungsmeistertruhe geöffnet?\nWenn Sie sich nicht erinnern, sagen Sie einfach 'Ja'.",
}

if Containerz.Localization and #localization == #Containerz.Localization then
    ZO_ShallowTableCopy(localization, Containerz.Localization)
end