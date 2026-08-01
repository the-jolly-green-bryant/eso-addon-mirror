local FenetreChronometreLaby = {}
local wm = GetWindowManager()

local function ActualiserChrono()
    if (LabyODD.chronoEnCours == false) then
        EVENT_MANAGER:UnregisterForUpdate(LabyODD.name.."Chronometre")
        return
    end
    local tempsTotal = os.time() - LabyODD.parametre.emplacement.heureDebut
    local texte = LabyODD.Temps(tempsTotal)
    FenetreChronometreLaby.Texte:SetText(texte)
end

function LabyODD.ChronoEstAffichee()
    return FenetreChronometreLaby.Fenetre ~= nil and not FenetreChronometreLaby.Fenetre:IsHidden()
end

function LabyODD.ChronoChangerTexte(texte)
    FenetreChronometreLaby.Texte:SetText(texte)
end

function LabyODD.DisparitionChronometre()
    if FenetreChronometreLaby.Fenetre ~= nil then
        FenetreChronometreLaby.Fenetre:SetHidden(true)
    end
end

function LabyODD.InitialisationFenetreChronometre()
    EVENT_MANAGER:RegisterForUpdate(LabyODD.name.."Chronometre",
                                    500,
                                    ActualiserChrono)

    -- LabyODD.parametre.emplacement.proprioMaisonActuelle = proprio
    -- LabyODD.parametre.emplacement.numeroMaison = maison
    -- LabyODD.parametre.emplacement.heureDebut = os.time()

    --d("Initialisation chronometre")

    if (FenetreChronometreLaby.Fenetre ~= nil) then
        FenetreChronometreLaby.Fenetre:SetHidden(false)
        return
    end

    FenetreChronometreLaby.Fenetre = wm:CreateTopLevelWindow("FenetreChronometreLaby")
    FenetreChronometreLaby.Fenetre:SetDimensions(150,30)
    FenetreChronometreLaby.Fenetre:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, LabyODD.parametre.coordonnees.Chronometre.x, LabyODD.parametre.coordonnees.Chronometre.y)
    FenetreChronometreLaby.Fenetre:SetMovable(true)
    FenetreChronometreLaby.Fenetre:SetMouseEnabled(true)
    FenetreChronometreLaby.Fenetre:SetHandler("OnMoveStop", function(control)
                                                                LabyODD.parametre.coordonnees.Chronometre.x = control:GetLeft()
                                                                LabyODD.parametre.coordonnees.Chronometre.y = control:GetTop()
                                                            end
                                                            )

    FenetreChronometreLaby.Fond = wm:CreateControl("ODDLabyChronoFond", FenetreChronometreLaby.Fenetre, CT_BACKDROP)
    FenetreChronometreLaby.Fond:SetEdgeColor(0.4, 0.4, 0.4)
    FenetreChronometreLaby.Fond:SetCenterColor(0.1, 0.1, 0.1)
    FenetreChronometreLaby.Fond:SetAnchor(CENTER, FenetreChronometreLaby.Fenetre, CENTER)
    FenetreChronometreLaby.Fond:SetDimensions(150, 30)
    FenetreChronometreLaby.Fond:SetAlpha(1)
    FenetreChronometreLaby.Fond:SetDrawLayer(0)

    FenetreChronometreLaby.Texte = wm:CreateControl("ODDLabyChronoTemps", FenetreChronometreLaby.Fenetre, CT_LABEL)
    FenetreChronometreLaby.Texte:SetColor(0.8, 0.8, 0.8, 1)
    FenetreChronometreLaby.Texte:SetFont("ZoFontAlert")
    FenetreChronometreLaby.Texte:SetScale(1)
    FenetreChronometreLaby.Texte:SetDrawLayer(1)
    FenetreChronometreLaby.Texte:SetText("Chrono en lancement")
    FenetreChronometreLaby.Texte:SetAnchor(CENTER, FenetreChronometreLaby.Fenetre, CENTER)
    FenetreChronometreLaby.Texte:SetDimensions(150, 30)
end