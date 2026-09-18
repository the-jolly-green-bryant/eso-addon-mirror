TamrielCalendar = TamrielCalendar or {}
local TC = TamrielCalendar

local fr = {
    days = {"Sandaas", "Morndaas", "Tirdaas", "Middaas", "Turdaas", "Fredaas", "Loredaas"},
    shortDays = {"Sa", "Mo", "Ti", "Mi", "Tu", "Fr", "Lo"},
    months = {"Étoile du matin", "Clair de ciel", "Premier semer", "Pluie de main", "Deuxième semer", "Mi-l'an", "Haut zénith", "Dernier semer", "Âtrefeu", "Soufflegivre", "Sommeil du soleil", "Étoile du soir"},
    realMonths = {"Janvier", "Février", "Mars", "Avril", "Mai", "Juin", "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"},
    signs = {"Le Rituel", "L'Amant", "Le Seigneur", "Le Mage", "L'Ombre", "Le Destrier", "L'Apprenti", "Le Guerrier", "La Dame", "La Tour", "L'Atronach", "Le Voleur", "Le Serpent"},
    moonPhases = {"Nouvelle lune", "Premier croissant", "Premier quartier", "Lune gibbeuse", "Pleine lune", "Lune décroissante", "Dernier quartier", "Dernier croissant"},
    yearSuffix = "2ème Ère",
    monthPrefix = "Mois de",
    signPrefix = "Signe:",
    stripFormat = "%s, %d %s %d | %s | %02d:%02d",
    titleHoliday = "Jour férié:",
    btnPrev = "Précédent",
    btnNext = "Suivant",
    hNames = {
        nl = "Nouvelle vie",
        hd = "Jour du Coeur",
        aj = "Jubilé ESO",
        jd = "Jour de la Farce",
        zz = "Jour de Zenithar",
        wf = "Festival des Sorcières"
    }
}

for k, v in pairs(fr) do
    TC.L[k] = v
end