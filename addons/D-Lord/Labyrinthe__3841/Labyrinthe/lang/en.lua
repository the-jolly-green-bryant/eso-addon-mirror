LabyODD.MaisonId = {}
LabyODD.MaisonNom = {}
LabyODD.MaisonIdNom = {}
LabyODD.MaisonNomId = {}

local data = ZO_COLLECTIBLE_DATA_MANAGER:GetAllCollectibleDataObjects() 
local compteur = 1
for i = 1, #data do 
    if data[i]:IsHouse() == true then 
        LabyODD.MaisonId[compteur] = data[i]:GetReferenceId()
        LabyODD.MaisonNom[compteur] = data[i]:GetFormattedName()
        LabyODD.MaisonIdNom[LabyODD.MaisonNom[compteur]] = data[i]:GetReferenceId()
        LabyODD.MaisonNomId[LabyODD.MaisonId[compteur]] = data[i]:GetFormattedName()
        compteur = compteur + 1
    end
end

LabyODD.Langue.NomProprio = "Owner"
LabyODD.Langue.NomProprioDist = 5
LabyODD.Langue.NomMaison = "House"
LabyODD.Langue.NomMaisonDist = 180
LabyODD.Langue.MeilleurTemp = "Best time"
LabyODD.Langue.MeilleurTempDist = 500
LabyODD.Langue.DateTemp = "Best date"
LabyODD.Langue.DateTempDist = 680
LabyODD.Langue.DatePassage = "First date"
LabyODD.Langue.DatePassageDist = 850
LabyODD.Langue.BoutonReset = "Reset Score"
LabyODD.Langue.BoutonResetDist = 988
LabyODD.Langue.BoutonLien = "Lien"
LabyODD.Langue.BoutonLienDist = 1110

LabyODD.Langue.PasChrono = "Start the stopwatch before you come in!"
LabyODD.Langue.FelicitationZoneArrive = "Congratulations, time to do the house:"
LabyODD.Langue.FelicitationMeublesObjectif = "Congratulations, time taken to reach goal :"
LabyODD.Langue.FelicitationMeublesFinal = "Congratulations on achieving all objectives!\nTotal time taken :"

LabyODD.Langue.BienvenueArrive = "Arrived in <<1>>'s house, arrival zone type."
LabyODD.Langue.BienvenueInteractionMeuble = "Arrived at <<1>>'s house, type interaction with furniture."
LabyODD.Langue.BienvenueNonImple = "Arrived at the house of <<1>>, of a type not yet implemented."

LabyODD.Langue.SansDescription = "No description yet. Good Luck"

LabyODD.Langue["@Paarthurnax996"][38]["Nom"] = "macabre procession"
LabyODD.Langue["@Paarthurnax996"][38]["Description"] = "Help \"Cass-os\" in his quest to find his tomb."

LabyODD.Langue["@Paarthurnax996"][38]["Nom"] = "Joker Land"
LabyODD.Langue["@Paarthurnax996"][38]["Description"] = "Visit the jouse of craziness and find the treasure of the jester"

LabyODD.Langue["@Paarthurnax996"][38]["Nom"] = "Vampire Manor"
LabyODD.Langue["@Paarthurnax996"][38]["Description"] = "Lose yourself in a powerful vampire's maze."

LabyODD.Langue["@Paarthurnax996"][47]["Nom"] = "The Tower"
LabyODD.Langue["@Paarthurnax996"][47]["Description"] = "Infernal tower maze"

LabyODD.Langue["@Paarthurnax996"][48]["Nom"] = "Ysgramor refuge"
LabyODD.Langue["@Paarthurnax996"][48]["Description"] = "Find the Ysgramor treasur, good luck."

LabyODD.Langue["@Paarthurnax996"][55]["Nom"] = "I-S-S Elysium"
LabyODD.Langue["@Paarthurnax996"][55]["Description"] = "I-S-S is lost in the galaxy, found the star map to bring him back to port"

LabyODD.Langue["@Paarthurnax996"][70]["Nom"] = "Khunzar's ordeal"
LabyODD.Langue["@Paarthurnax996"][70]["Description"] = "Find the 3 meridian orbs and open the tomb of Khunzar"

LabyODD.Langue["@Paarthurnax996"][90]["Nom"] = "Dagon's jails"
LabyODD.Langue["@Paarthurnax996"][90]["Description"] = "Rot in dagon's jails, or find this treasure"


ZO_CreateStringId("SI_BINDING_NAME_OUVRIR_FENETRE_LABYRINTHE", "Open list window")
ZO_CreateStringId("SI_BINDING_NAME_REINITIALISER_LABYRINTHE", "Reset stopwatch and return to door")
