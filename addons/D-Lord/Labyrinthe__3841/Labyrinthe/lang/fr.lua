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

LabyODD.Langue = {
    ["NomProprio"] = "Propriétaire",
    ["NomProprioDist"] = 5,
    ["NomMaison"] = "Maison",
    ["NomMaisonDist"] = 180,
    ["MeilleurTemp"] = "Meilleur temps",
    ["MeilleurTempDist"] = 500,
    ["DateTemp"] = "Meilleur date",
    ["DateTempDist"] = 680,
    ["DatePassage"] = "Premier passage",
    ["DatePassageDist"] = 850,
    ["BoutonReset"] = "Reset Score",
    ["BoutonResetDist"] = 988,
    ["BoutonLien"] = "Lien",
    ["BoutonLienDist"] = 1110,


    ["PasChrono"] = "Lance le chrono avant de venir !",
    ["FelicitationZoneArrive"] = "Félicitations, temps pour faire la maison :",
    ["FelicitationMeublesObjectif"] = "Félicitations, temps mis pour atteindre l'objectif :",
    ["FelicitationMeublesFinal"] = "Félicitation pour avoir atteint tous les objectifs !\nTemps total mis : ",

    ["BienvenueArrive"] = "Arrivée dans la maison de <<1>>, de type «zone d'arrivée».",
    ["BienvenueInteractionMeuble"] = "Arrivée dans la maison de <<1>>, de type «interaction avec les meubles».",
    ["BienvenueNonImple"] = "Arrivée dans la maison de <<1>>, d'un type non encore implémenté.",

    ["SansDescription"] = "Sans description, bonne chance"
}

LabyODD.Langue["@Paarthurnax996"] = {
        [37] = {
            ["Nom"] = "Procession Macabre",
            ["Description"] = "Aide Cass-os dans sa quête pour trouver sa tombe."
        },
        [38] = {
            ["Nom"] = "Joker Land",
            ["Description"] = "Visite la maison de la folie et trouve le trésor du bouffon."
        },
        [39] = {
            ["Nom"] = "Manoir du vampire",
            ["Description"] = "Perdez-vous dans le labyrinthe d'un puissant vampire."
        },
        [47] = {
            ["Nom"] = "La Tour",
            ["Description"] = "Labyrinthe de la tour infernale"
        },
        [48] = {
            ["Nom"] = "Le refuge d'Ysgramor",
            ["Description"] = "Trouve le trésor d'Ysgramor, bonne chance."
        },
        [55] = {
            ["Nom"] = "I-S-S Elysium",
            ["Description"] = "I-S-S Elysium est perdu dans l'espace. Trouve la carte stellaire qui le ramènera à bon port."
        },
        [70] = {
            ["Nom"] = "L'épreuve de Khunzar",
            ["Description"] = "Trouvez les orbes de méridia"
        },
        [90] = {
            ["Nom"] = "Les geôles de Dagon",
            ["Description"] = "Moisie au fond de la prison de Dagon, ou trouve son trésor."
        }
}

ZO_CreateStringId("SI_BINDING_NAME_OUVRIR_FENETRE_LABYRINTHE", "Ouvrir la fenêtre récapitulative des labyrinthes")
ZO_CreateStringId("SI_BINDING_NAME_REINITIALISER_LABYRINTHE", "Réinitialiser Chronomètre et retour à la porte")
