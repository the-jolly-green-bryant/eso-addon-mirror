
local dernierMeubleValide = nil -- LabyODD.parametre.emplacement.dernierMeubleValide
local listeMeubles = nil


local function meubleDansListe(furnitureIdString)
    for i = 1, #listeMeubles do
        -- d(i)
        if (furnitureIdString == listeMeubles[i].id) then
            return i
        end
    end
    return 0
end


local function SommeTempsIntermediaire(listeTemps)
    local somme = 0
    for i = 1, #listeTemps do 
        if listeTemps[i] == 0 then
            return 0
        else 
            somme = somme + listeTemps[i]
        end
    end
    return somme
end


local function actionMeuble(event, furnitureId, nouvelEtat, ancienEtat, truc1, truc2)
    local furnitureIdString = Id64ToString(furnitureId)
    if dernierMeubleValide == furnitureId then return end
    -- d("Interaction avec le meuble "..furnitureIdString)
    -- Si différent du dernierMeubleValide
    -- Vérifier si le meuble touché est dans la liste puis si il est à distance.
    local numeroMeuble = meubleDansListe(furnitureIdString)
    if (numeroMeuble ~= 0) then
        local playerX, playerY, playerZ = GetPlayerWorldPositionInHouse()
        local furnitureX, furnitureY, furnitureZ = HousingEditorGetFurnitureWorldPosition(furnitureId)
        -- d(zo_distance3d( furnitureX, furnitureY, furnitureZ, playerX, playerY, playerZ ))
        local x = furnitureX - playerX
        local y = furnitureY - playerY
        local z = furnitureZ - playerZ
        local distance = math.sqrt(x*x+y*y+z*z)
        -- d("distance : "..distance)
        if (distance < 500) then
            -- Valider la trouvaille de ce meuble là.
            local heureFin = os.time()
            local tempsIntermediaire = heureFin - LabyODD.parametre.emplacement.heureDebut
            -- Vérifier l'existence/la nouveauté du meilleurs score
            if (0 == LabyODD.parametre["enregistrement"][LabyODD.parametre.emplacement.proprioMaisonActuelle][LabyODD.parametre.emplacement.numeroMaison].meuble[numeroMeuble]) then
                LabyODD.parametre["enregistrement"][LabyODD.parametre.emplacement.proprioMaisonActuelle][LabyODD.parametre.emplacement.numeroMaison].meuble[numeroMeuble] = tempsIntermediaire
            elseif (tempsIntermediaire < LabyODD.parametre["enregistrement"][LabyODD.parametre.emplacement.proprioMaisonActuelle][LabyODD.parametre.emplacement.numeroMaison].meuble[numeroMeuble]) then
                LabyODD.parametre["enregistrement"][LabyODD.parametre.emplacement.proprioMaisonActuelle][LabyODD.parametre.emplacement.numeroMaison].meuble[numeroMeuble] = tempsIntermediaire
            end
            -- notifier le joueur
            d(LabyODD.Langue.FelicitationMeublesObjectif)
            d(LabyODD.Temps(tempsIntermediaire))
            -- Si le meuble est valide, vérifier si tous les meubles ont été atteints
            local sommeTempsIntermediaire = SommeTempsIntermediaire(LabyODD.parametre["enregistrement"][LabyODD.parametre.emplacement.proprioMaisonActuelle][LabyODD.parametre.emplacement.numeroMaison].meuble)
            if (sommeTempsIntermediaire ~= 0) then
                local texte = LabyODD.Temps(sommeTempsIntermediaire)
                d(LabyODD.Langue.FelicitationMeublesFinal..texte)

                if (LabyODD.parametre["enregistrement"][LabyODD.parametre.emplacement.proprioMaisonActuelle][LabyODD.parametre.emplacement.numeroMaison].Record > sommeTempsIntermediaire or LabyODD.parametre["enregistrement"][LabyODD.parametre.emplacement.proprioMaisonActuelle][LabyODD.parametre.emplacement.numeroMaison].Record == 0) then
                    LabyODD.parametre["enregistrement"][LabyODD.parametre.emplacement.proprioMaisonActuelle][LabyODD.parametre.emplacement.numeroMaison].Record = sommeTempsIntermediaire
                    if FenetreLabyrinthe.Corps ~= nil then
                        FenetreLabyrinthe.Corps[LabyODD.parametre.emplacement.proprioMaisonActuelle..LabyODD.parametre.emplacement.numeroMaison].Record:SetText(texte)
                    end
                    if (LabyODD.parametre["enregistrement"][LabyODD.parametre.emplacement.proprioMaisonActuelle][LabyODD.parametre.emplacement.numeroMaison].Premieredate == 0) then
                        LabyODD.parametre["enregistrement"][LabyODD.parametre.emplacement.proprioMaisonActuelle][LabyODD.parametre.emplacement.numeroMaison].Premieredate = heureFin
                        if FenetreLabyrinthe.Corps ~= nil then
                            FenetreLabyrinthe.Corps[LabyODD.parametre.emplacement.proprioMaisonActuelle..LabyODD.parametre.emplacement.numeroMaison].PremiereDate:SetText(GetDateStringFromTimestamp(LabyODD.parametre["enregistrement"][LabyODD.parametre.emplacement.proprioMaisonActuelle][LabyODD.parametre.emplacement.numeroMaison].Premieredate))
                        end
                    else
                        LabyODD.parametre["enregistrement"][LabyODD.parametre.emplacement.proprioMaisonActuelle][LabyODD.parametre.emplacement.numeroMaison].Meilleurdate = heureFin
                        if FenetreLabyrinthe.Corps ~= nil then
                            FenetreLabyrinthe.Corps[LabyODD.parametre.emplacement.proprioMaisonActuelle..LabyODD.parametre.emplacement.numeroMaison].MeilleurDate:SetText(GetDateStringFromTimestamp(LabyODD.parametre["enregistrement"][LabyODD.parametre.emplacement.proprioMaisonActuelle][LabyODD.parametre.emplacement.numeroMaison].Meilleurdate))
                        end
                    end
                end

            end
            -- Réinitialiser le chronometre
            LabyODD.parametre.emplacement.heureDebut = heureFin
        end
        dernierMeubleValide = furnitureId
    end


    -- d(GetPlacedHousingFurnitureInfo(furnitureId))
    -- d(GetPlacedFurnitureLink(furnitureId, LINK_STYLE_BRACKETS))
    -- local playerX, playerY, playerZ = GetPlayerWorldPositionInHouse()
    -- local furnitureX, furnitureY, furnitureZ = HousingEditorGetFurnitureWorldPosition( furnitureId )
    -- -- d(zo_distance3d( furnitureX, furnitureY, furnitureZ, playerX, playerY, playerZ ))
    
    -- d("Position dans le monde : "..furnitureX .." "..furnitureY.." "..furnitureZ)
    
    -- local x = furnitureX - playerX
    -- local y = furnitureY - playerY
    -- local z = furnitureZ - playerZ
    -- d("distance : "..math.sqrt(x*x+y*y+z*z))
    
    -- local string = ""
    -- local args = unpack(...)
    -- for i = 1, args.n do
    --     string = string .. tostring(args[i]) .. "  :  "
    -- end
    -- d(string)
end


function LabyODD.finMeublesInteractionMultiples()
    EVENT_MANAGER:UnregisterForEvent(LabyODD.name, EVENT_HOUSING_FURNITURE_STATE_CHANGED)
end


function LabyODD.AffichageDetailsProgressionMeublesInteraction(proprio, maison)
    local texte = ""
    listeMeubles = LabyODD.listeLabyrinthe[proprio][maison]["meubles"]
    for i = 1, #listeMeubles do
        local temps = LabyODD.parametre["enregistrement"][proprio][maison].meuble[i]
        if (temps == 0) then
            texte = texte.."\nObjectif "..i.." : -"
        else
            texte = texte.."\nObjectif "..i.." : "..LabyODD.Temps(LabyODD.parametre["enregistrement"][proprio][maison].meuble[i])
        end
    end
    return texte
end

function LabyODD.InitialisationMeublesInteractionMultiples(proprio, maison, encours)
    
    if not encours then
        LabyODD.parametre.emplacement.proprioMaisonActuelle = proprio
        LabyODD.parametre.emplacement.numeroMaison = maison
        LabyODD.parametre.emplacement.heureDebut = os.time()
    end

    LabyODD.InitialisationFenetreChronometre()

    if (proprio == nil and maison ==nil) then
        EVENT_MANAGER:RegisterForEvent(LabyODD.name,
                                       EVENT_HOUSING_FURNITURE_STATE_CHANGED,
                                       actionMeuble)
        return
    end
    if (LabyODD.chronoEnCours == false) then
        LabyODD.chronoEnCours = true
        listeMeubles = LabyODD.listeLabyrinthe[proprio][maison]["meubles"]
        EVENT_MANAGER:RegisterForEvent(LabyODD.name,
                                       EVENT_HOUSING_FURNITURE_STATE_CHANGED,
                                       actionMeuble)
    end
end