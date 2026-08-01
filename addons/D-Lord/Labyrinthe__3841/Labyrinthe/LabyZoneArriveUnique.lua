local pi2 = math.pi*2

local function inclus(xz, y, point)
    local somme = 0
    if (y.bas <= point.y and point.y <= y.haut) then
        -- d("Angles : ")
        for i = 2, #xz do
            local p1, p2, p3 = xz[i-1], point, xz[i]
            local a = math.sqrt(math.pow(p1.x-p2.x, 2) + math.pow(p1.z-p2.z, 2))
            local b = math.sqrt(math.pow(p3.x-p2.x, 2) + math.pow(p3.z-p2.z, 2))
            local c = math.sqrt(math.pow(p1.x-p3.x, 2) + math.pow(p1.z-p3.z, 2))
            local cosangle = (a*a+b*b-c*c)/(2*a*b)
            local angle = math.acos(cosangle)
            -- d("Cosangle : ".. cosangle.." Angle : "..angle)
            somme = somme + angle
            -- Merci Schwintz
        end
        local p1, p2, p3 = xz[#xz], point, xz[1]
        local a = math.sqrt(math.pow(p1.x-p2.x, 2) + math.pow(p1.z-p2.z, 2))
        local b = math.sqrt(math.pow(p3.x-p2.x, 2) + math.pow(p3.z-p2.z, 2))
        local c = math.sqrt(math.pow(p1.x-p3.x, 2) + math.pow(p1.z-p3.z, 2))
        local cosangle = (a*a+b*b-c*c)/(2*a*b)
        local angle = math.acos(cosangle)
        -- d("Cosangle : ".. cosangle.." Angle : "..angle)
        somme = somme + angle
        -- d(somme)
        if (somme == pi2) then
            return true
        end
    end
    return false
end

function LabyODD.finZoneArriveeUnique()
    EVENT_MANAGER:UnregisterForUpdate(LabyODD.name.."zoneArriveeUnique")
end

local function zoneArriveeUnique(points)
    -- d("Ça tourne")
    if (LabyODD.chronoEnCours == false) then return end
    local x, y, z, _ = GetPlayerWorldPositionInHouse()
    point = {x = x, y = y, z = z}

    if (inclus(points.xz, points.y, point)) then
        local fin = os.time()
        local tempsTotal = fin - LabyODD.parametre.emplacement.heureDebut
        local texte = LabyODD.Temps(tempsTotal)
        d(LabyODD.Langue.FelicitationZoneArrive)
        -- d(tempsTotal.."s")
        d(texte)
        LabyODD.chronoEnCours = false

        LabyODD.finZoneArriveeUnique()

        -- numeroMaison = GetCurrentZoneHouseId()

        if (LabyODD.parametre["enregistrement"][LabyODD.parametre.emplacement.proprioMaisonActuelle][LabyODD.parametre.emplacement.numeroMaison].Record > tempsTotal or LabyODD.parametre["enregistrement"][LabyODD.parametre.emplacement.proprioMaisonActuelle][LabyODD.parametre.emplacement.numeroMaison].Record == 0) then
            LabyODD.parametre["enregistrement"][LabyODD.parametre.emplacement.proprioMaisonActuelle][LabyODD.parametre.emplacement.numeroMaison].Record = tempsTotal
            if FenetreLabyrinthe.Corps ~= nil then
                FenetreLabyrinthe.Corps[LabyODD.parametre.emplacement.proprioMaisonActuelle..LabyODD.parametre.emplacement.numeroMaison].Record:SetText(texte)
            end
            if (LabyODD.parametre["enregistrement"][LabyODD.parametre.emplacement.proprioMaisonActuelle][LabyODD.parametre.emplacement.numeroMaison].Premieredate == 0) then
                LabyODD.parametre["enregistrement"][LabyODD.parametre.emplacement.proprioMaisonActuelle][LabyODD.parametre.emplacement.numeroMaison].Premieredate = fin
                if FenetreLabyrinthe.Corps ~= nil then
                    FenetreLabyrinthe.Corps[LabyODD.parametre.emplacement.proprioMaisonActuelle..LabyODD.parametre.emplacement.numeroMaison].PremiereDate:SetText(GetDateStringFromTimestamp(LabyODD.parametre["enregistrement"][LabyODD.parametre.emplacement.proprioMaisonActuelle][LabyODD.parametre.emplacement.numeroMaison].Premieredate))
                end
            else
                LabyODD.parametre["enregistrement"][LabyODD.parametre.emplacement.proprioMaisonActuelle][LabyODD.parametre.emplacement.numeroMaison].Meilleurdate = fin
                if FenetreLabyrinthe.Corps ~= nil then
                    FenetreLabyrinthe.Corps[LabyODD.parametre.emplacement.proprioMaisonActuelle..LabyODD.parametre.emplacement.numeroMaison].MeilleurDate:SetText(GetDateStringFromTimestamp(LabyODD.parametre["enregistrement"][LabyODD.parametre.emplacement.proprioMaisonActuelle][LabyODD.parametre.emplacement.numeroMaison].Meilleurdate))
                end
            end
        end
    end
end

function LabyODD.InitialisationZoneArriveeUnique(proprio, maison, encours)

    if not encours then
        LabyODD.parametre.emplacement.proprioMaisonActuelle = proprio
        LabyODD.parametre.emplacement.numeroMaison = maison
        LabyODD.parametre.emplacement.heureDebut = os.time()
    end
    
    LabyODD.InitialisationFenetreChronometre()

    if (LabyODD.chronoEnCours == false) then
        LabyODD.chronoEnCours = true
        EVENT_MANAGER:RegisterForUpdate(LabyODD.name.."zoneArriveeUnique",
                                        500,
                                        function() zoneArriveeUnique(LabyODD.listeLabyrinthe[proprio][maison]["points"]) end)
    end
end