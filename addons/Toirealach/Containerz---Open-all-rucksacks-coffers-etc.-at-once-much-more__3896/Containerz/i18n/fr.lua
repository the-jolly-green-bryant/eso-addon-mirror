Containerz = Containerz or {}

local localization = {

    LOADED_STR = "%s %s %s",
    WAS_LOADED = "chargé",
    NOT_LOADED = "non chargé",
    
    OPEN_ALL_CONTAINERZ = "Ouvrir tous les conteneurs",
    STOP_OPENING_CONTAINERZ = "Arrêter l'ouverture des conteneurs",
    WILL_OPEN = " OUVRIRA un %s",
    WONT_OPEN = " N'ouvrira PAS un %s",
   
    TRANSMUTES_NAME = "Ne dépassez pas la limite des cristaux de transmutation",
    TRANSMUTES_TOOLTIP = "S'il y a une chance qu'une géode de transmutation vous fasse dépasser la limite de 1000 cristaux de transmutation, n'ouvrez pas automatiquement cette géode",
    GLADIATORS_NAME = "Ouvrez un seul sac à dos de Gladiateur d'arène par jour",
    GLADIATORS_TOOLTIP = "Une seule fois par jour, lorsque vous ouvrez un sac à dos de Gladiateur d'arène, vous obtiendrez une épreuve de Gladiateur d'arène, donc elle ne s'ouvre automatiquement que par jour",
    SIEGEMASTERS_NAME = "Ouvrez un seul coffre de maître de siège par jour",
    SIEGEMASTERS_TOOLTIP = "Une seule fois par jour, lorsque vous ouvrez un coffre de maître de siège, vous obtiendrez un siège du mérite de Cyrodiil, donc n'en ouvrez automatiquement qu'un par jour",
    SCROLLKEEPERS_NAME = "N'ouvrez qu'un seul sac à dos de Gardien de Parchemin par jour",
    SCROLLKEEPERS_TOOLTIP = "Une seule fois par jour, lorsque vous ouvrez un sac à dos de Gardien de Parchemins, vous recevrez des parchemins, vous n'en ouvrirez donc automatiquement qu'un par jour",

    GLADIATORS_VERIFY = "Avez-vous ouvert un sac à dos Gladiator aujourd'hui ?\nSi vous ne vous en souvenez pas, dites simplement 'Oui'.",
    SIEGEMASTERS_VERIFY = "Avez-vous ouvert un coffre de maître de siège aujourd'hui ?\nSi vous ne vous en souvenez pas, dites simplement 'Oui'.",
}

if Containerz.Localization and #localization == #Containerz.Localization then
    ZO_ShallowTableCopy(localization, Containerz.Localization)
end