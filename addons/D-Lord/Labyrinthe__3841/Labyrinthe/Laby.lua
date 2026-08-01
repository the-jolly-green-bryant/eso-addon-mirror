-- Add on pour traquer les réussites des parcours dans les maisons de type labyrinthe.

-- /*
-- Fait :
--     Chronomètre :
--         A l'entrée dans les maisons répértoriées
--         Réinitialisable (avec un retour à l'entrée)
--     Atteindre une zone :
--         Fin du chrono
--         Affichage à l'écran
--         Mémoire si meilleurs temps

--          Ajouter un fond d'écran par maison


-- A mettre en place : 
--     Atteindre une zone :
--     Interaction avec un meuble (Aïe, Aïe, Aïe) :
--         «succès» intermédiaire, classement intermédiaire ?
--     Liste des maisons :
--         Avec accès au clic
--         Rangement pas catégorie / tri par maison/propriétaire/architecte ...
--         ascenceurs ?
--     Exporter message discord ? / succès
--     Ajouter mémoire long terme (variable sauvegardée)
--        Affichage des meilleurs temps ?
--        Enregistrement meilleurs temps et date de passage
--        Enregistrement première date de passage
--     Reinitialiser son temps pour une maison
--     Trier les maison par difficulté
--     Mettre des surnoms aux maisons
--     Pouvoir créer les liens des maisons.
-- */


local wm = GetWindowManager()
local demandeReinitialiser = false
LabyODD.chronoEnCours = false


local function lancementTypeChronometre(proprio, maison, encours)
    
    local typeLaby = LabyODD.listeLabyrinthe[proprio][maison]["type"]
    -- Switch sur les différents types de labyrinthe
    
    if (typeLaby == "zone d'arrivée") then
        df(zo_strformat(LabyODD.Langue.BienvenueArrive, proprio, LabyODD.listeLabyrinthe[proprio][maison]["type"]))
        LabyODD.InitialisationZoneArriveeUnique(proprio, maison, encours)
    elseif (typeLaby == "interactions meubles multiples") then
        df(zo_strformat(LabyODD.Langue.BienvenueInteractionMeuble, proprio, LabyODD.listeLabyrinthe[proprio][maison]["type"]))
        LabyODD.InitialisationMeublesInteractionMultiples(proprio, maison, encours)
        -- d("Les labyrinthe de type interaction avec des meubles est en cours d'implémentation.")
    elseif (typeLaby == "zones d'arrivées multiples") then
        df(zo_strformat(LabyODD.Langue.BienvenueInteractionMeuble, proprio, LabyODD.listeLabyrinthe[proprio][maison]["type"]))
        LabyODD.zoneArriveeMultiple()
    else
        -- Pas encore développé
        df(zo_strformat(LabyODD.Langue.BienvenueNonImple, proprio, LabyODD.listeLabyrinthe[proprio][maison]["type"]))
        d("Le type de cette maison n'est pas encore prévu")
    end

end


local function arretTypeChronometre(proprio, maison)
    local typeLaby = LabyODD.listeLabyrinthe[proprio][maison]["type"]
    -- Switch sur les différents types de labyrinthe

    if (typeLaby == "zone d'arrivée") then
        -- d("Fin du chrono sur les zone d'arrivé")
        LabyODD.finZoneArriveeUnique()
    elseif (typeLaby == "interactions meubles multiples") then
        -- d("Fin du chrono sur les multiples interraction avec des meubles")
        LabyODD.finMeublesInteractionMultiples()
    elseif (typeLaby == "zones d'arrivées multiples") then
        -- d("Fin du chrono et de recherche sur une maison ayant de multiples chemin")
        LabyODD.finZoneCheminMultiple()
    elseif (typeLaby == "points de passage") then
        -- d("Fin du chrono sur les diverses points de passage")
        LabyODD.finPointsPassage()
    else
        -- Pas encore développé
        -- df(zo_strformat(LabyODD.Langue.BienvenueNonImple, proprio, LabyODD.listeLabyrinthe[proprio][maison]["type"]))
        d("Le type de cette maison n'est pas encore prévu")
    end
end


local function arriveDansUneMaison(event, initial)
    if (LabyODD.parametre["enregistrement"] == nil) then
        LabyODD.parametre = ZO_SavedVars:NewAccountWide("LabyrintheSavedVariables", 1, nil, LabyODD.default)
    end

    local proprio = GetCurrentHouseOwner()

    -- Pas de proprio, on termine le chrono et on nettoie l'écran
    if (proprio == "") then
        -- d("Sortie de maison")
        -- Sortie de toute maison. Il faut arreter le chrono s'il tourne
        if (LabyODD.chronoEnCours) then
            -- d("Fin du chronomètre")
            LabyODD.chronoEnCours = false
            arretTypeChronometre(LabyODD.parametre.emplacement.proprioMaisonActuelle, LabyODD.parametre.emplacement.numeroMaison)
        end
        -- Il faut effacer le chrono s'il est affiché
        if LabyODD.ChronoEstAffichee() then
            LabyODD.DisparitionChronometre()
        end
        LabyODD.parametre.emplacement.proprioMaisonActuelle = ""
        LabyODD.parametre.emplacement.numeroMaison = 0
        -- d("Et non, je ne suis pas dans une maison.")
    else
        -- Présent dans une maison
        -- d("Arrive dans une maison")
        maison = GetCurrentZoneHouseId()
        -- d(proprio)
        if (    (proprio == LabyODD.parametre.emplacement.proprioMaisonActuelle)
            and ( maison == LabyODD.parametre.emplacement.numeroMaison)) then
                -- On reste dans la même maison
                -- si le chrono n'est pas lancé, on verifie si il faut le lancer.
                if (LabyODD.chronoEnCours == false) then
                    lancementTypeChronometre(proprio, maison, true)
                end
        elseif (LabyODD.listeLabyrinthe[proprio]
            and LabyODD.listeLabyrinthe[proprio][maison]) then
            -- Nouvelle maison, vérification et création des variables sauvegardées pour le proprio/maison
            if LabyODD.parametre["enregistrement"][proprio] == nil then
                LabyODD.parametre["enregistrement"][proprio] = {}
            end
            if LabyODD.parametre["enregistrement"][proprio][maison] == nil then
                LabyODD.parametre["enregistrement"][proprio][maison] = {}
                LabyODD.parametre["enregistrement"][proprio][maison].Record = 0
                LabyODD.parametre["enregistrement"][proprio][maison].Premieredate = 0
                LabyODD.parametre["enregistrement"][proprio][maison].Meilleurdate = 0
            end

            if (LabyODD.listeLabyrinthe[proprio][maison]["type"] == "interactions meubles multiples") then
                local listeMeubles = LabyODD.listeLabyrinthe[proprio][maison]["meubles"]
                if LabyODD.parametre["enregistrement"][proprio][maison].meuble == nil then
                    LabyODD.parametre["enregistrement"][proprio][maison].meuble = {}
                    for i = 1, #listeMeubles do
                        LabyODD.parametre["enregistrement"][proprio][maison].meuble[i] = 0
                    end
                end
            end

            -- Nouvelle maison, il faut maintenant lancer les bonnes fonctions 
            -- le chrono doit être lancé depuis les fichiers des type de laby

            lancementTypeChronometre(proprio, maison, false)

        else
            if (LabyODD.chronoEnCours) then
                -- d("Fin du chronomètre")
                arretTypeChronometre(LabyODD.parametre.emplacement.proprioMaisonActuelle, LabyODD.parametre.emplacement.numeroMaison)
                LabyODD.chronoEnCours = false
            end
            LabyODD.parametre.emplacement.proprioMaisonActuelle = ""
            LabyODD.parametre.emplacement.numeroMaison = 0
            if LabyODD.ChronoEstAffichee() then
                LabyODD.DisparitionChronometre()
            end
        end

        -- d("Je suis dans une maison, et pas n'importe laquelle, je suis dans la maison de " .. GetCurrentHouseOwner())
        -- d("Dans sa maison " .. GetCurrentZoneHouseId()..", pour plus de précision, il faudra attendre.")
    end
end

function LabyODD.RetourALaPorte()
    if LabyODD.chronoEnCours and not IsUnitDeadOrReincarnating("player") then
        LabyODD.parametre.emplacement.heureDebut = os.time()
    end
    HousingEditorJumpToSafeLocation()
end

function LabyODD.ReinitialiserScore()
    if demandeReinitialiser then

        for proprio, maisons in pairs(LabyODD.listeLabyrinthe) do
            for nMaison, variables in pairs(maisons) do

                local nomTable = proprio..nMaison
                
                LabyODD.parametre["enregistrement"][proprio][nMaison]["Premieredate"] = 0
                LabyODD.parametre["enregistrement"][proprio][nMaison]["Record"] = 0
                LabyODD.parametre["enregistrement"][proprio][nMaison]["Meilleurdate"] = 0

                if FenetreLabyrinthe.Corps ~= nil then
                    FenetreLabyrinthe.Corps[nomTable].PremiereDate:SetText("-")
                    FenetreLabyrinthe.Corps[nomTable].Record:SetText("-")
                    FenetreLabyrinthe.Corps[nomTable].MeilleurDate:SetText("-")
                end

                if (variables["type"] == "interactions meubles multiples") then
                    local listeMeubles = LabyODD.listeLabyrinthe[proprio][nMaison]["meubles"]
                    for i = 1, #listeMeubles do
                        LabyODD.parametre["enregistrement"][proprio][nMaison].meuble[i] = 0
                    end
                end

            end
        end

        d("Les scores ont été réinitialisé.")

    else
        d("Attention, refaire cette commande réinitialisera tous vos scores.")
        demandeReinitialiser = true
    end
end

SLASH_COMMANDS["/reinitialisechrono"] = LabyODD.RetourALaPorte

SLASH_COMMANDS["/resetscorelabyrinthe"] = LabyODD.ReinitialiserScore

-- table.insert(ODD.slashCommand, {"/reinitialiseChrono", retourALaPorte})

--     Retourner à l'entrée de la maison // Fait
--     Interaction avec un meuble (lequel ?) // A faire
--                id64:nilable furnitureId = HousingEditorGetSelectedFurnitureId() 
--                number worldX, number worldY, number worldZ =  HousingEditorGetFurnitureWorldPosition(id64 furnitureId)  
--     Le chrono (ou enregistrer l'heure et faire une différence) // A faire
--          Module os en C

--          HousingEditorJumpToSafeLocation() 
-- */


-- number worldX, worldY, worldZ = 74868, 16049, 32434
-- number worldX, worldY, worldZ = 73862, 16044, 3218
-- number worldX, worldY, worldZ = 74311, 16137, 32331



-- Chateau de Coeurébène, Paart
-- number worldX, worldY, worldZ = 74868, 16049, 32434

-- number worldX, worldY, worldZ = 73862, 16044, 32187

-- number worldX, worldY, worldZ = 74311, 16137, 32331


EVENT_MANAGER:RegisterForEvent(LabyODD.name.."labyplayer", EVENT_PLAYER_ACTIVATED, arriveDansUneMaison)
