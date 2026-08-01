LabyODD = {}
LabyODD.name = "LabyrintheparD"
LabyODD.version = 0.6
-- LabyODD.texte = ...
LabyODD.parametre = {}
LabyODD.default = {}
LabyODD.default["enregistrement"] = 
{
    ["@Paarthurnax996"] = {
        [90] = {
            ["Record"] =  0,
            ["Premieredate"] = 0,
            ["Meilleurdate"] = 0
        }
    }
}
LabyODD.default["coordonnees"] = 
{
    ["Chronometre"] = {
        ["x"] = 30,
        ["y"] = 30
    }
}
LabyODD.default["emplacement"] = 
{
    ["proprioMaisonActuelle"] = "",
    ["numeroMaison"] = 0,
    ["heureDebut"] = 0,
}
-- Fonctionnement des variables sauvegardées
-- De la même forme que la liste Labyrinthe, mais avec les dates et temps, et donnée voulue pour chaque labytinthe.