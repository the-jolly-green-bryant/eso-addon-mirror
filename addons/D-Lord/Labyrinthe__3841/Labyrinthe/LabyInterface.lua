FenetreLabyrinthe = {}
local wm = GetWindowManager()
local nombreLabyAffiche = 0


local function FermerFenetre()
    FenetreLabyrinthe.Fenetre:SetHidden(true)
	SetGameCameraUIMode(not FenetreLabyrinthe.Fenetre:IsHidden())
end

local function Voyage(proprio, nMaison)
    -- d("Et c'est parti !")
    if proprio == GetDisplayName() then
        RequestJumpToHouse(nMaison)
    else
        JumpToSpecificHouse(proprio, nMaison)
    end
end

local function LienMaison(numero)
    CHAT_SYSTEM.textEntry:SetText("|H1:housing:"..idmaison..":"..joueur.."|h|h")
end


local function ajouterMaison(proprio, nMaison, donneesMaison)

    --      Première liste de maison

    local dec = 110 + 35 * nombreLabyAffiche

    local nomTable = proprio..nMaison

    FenetreLabyrinthe.Corps[nomTable] = {}
    FenetreLabyrinthe.Corps[nomTable].Control = wm:CreateControl("ODDLabyControle"..nombreLabyAffiche, FenetreLabyrinthe.Control, CT_CONTROL)
    FenetreLabyrinthe.Corps[nomTable].Control:SetDimensions(1200, 30)
    FenetreLabyrinthe.Corps[nomTable].Control:SetAnchor(TOP, FenetreLabyrinthe.Control, TOP, 0, 0)
    
    FenetreLabyrinthe.Corps[nomTable].NomProprio = wm:CreateControl("ODDLabyTexteProprio"..nombreLabyAffiche, FenetreLabyrinthe.Corps[nomTable].Control, CT_LABEL)
    FenetreLabyrinthe.Corps[nomTable].NomProprio:SetAnchor(TOPLEFT, FenetreLabyrinthe.Corps[nomTable].Control, TOPLEFT, LabyODD.Langue.NomProprioDist, dec)
    FenetreLabyrinthe.Corps[nomTable].NomProprio:SetFont("$(BOLD_FONT)|$(KB_20)soft-shadow-thick")
    FenetreLabyrinthe.Corps[nomTable].NomProprio:SetColor(1, 1, 1)
    FenetreLabyrinthe.Corps[nomTable].NomProprio:SetText(proprio)

    -- FenetreLabyrinthe.Corps[nomTable].BoutonNomMaison = wm:CreateControlFromVirtual("ODDLabyBoutonMaison"..nombreLabyAffiche, FenetreLabyrinthe.Corps[nomTable].Control, "ZO_DefaultButton")
    -- FenetreLabyrinthe.Corps[nomTable].BoutonNomMaison:SetAnchor(TOPLEFT, FenetreLabyrinthe.Corps[nomTable].Control, TOPLEFT, LabyODD.Langue.NomMaisonDist, dec)
    -- FenetreLabyrinthe.Corps[nomTable].BoutonNomMaison:SetFont("$(BOLD_FONT)|$(KB_20)soft-shadow-thick")
    -- FenetreLabyrinthe.Corps[nomTable].BoutonNomMaison:SetText(LabyODD.MaisonNomId[nMaison])
    -- FenetreLabyrinthe.Corps[nomTable].BoutonNomMaison:SetHandler("OnClicked", function(self, button, ctrl, alt, shift, command) Voyage(proprio, nMaison) end)
    
    FenetreLabyrinthe.Corps[nomTable].BoutonHandler = wm:CreateControl("ODDLabyBoutonHandler"..nombreLabyAffiche, FenetreLabyrinthe.Corps[nomTable].Control, CT_CONTROL)
    FenetreLabyrinthe.Corps[nomTable].BoutonHandler:SetDimensions(300, 30)
    FenetreLabyrinthe.Corps[nomTable].BoutonHandler:SetAnchor(TOPLEFT, FenetreLabyrinthe.Corps[nomTable].Control, TOPLEFT, LabyODD.Langue.NomMaisonDist, dec)
    FenetreLabyrinthe.Corps[nomTable].BoutonHandler:SetMouseEnabled(true)
    if (donneesMaison.textes) then
        if donneesMaison.textes.Description ~= "" then
            FenetreLabyrinthe.Corps[nomTable].BoutonHandler:SetHandler("OnMouseEnter", function(control) ZO_Tooltips_ShowTextTooltip(control, BOTTOM, donneesMaison.textes.Description.."\n\n|cEFD807"..LabyODD.MaisonNomId[nMaison].."|r") end)
            FenetreLabyrinthe.Corps[nomTable].BoutonHandler:SetHandler("OnMouseExit", function(control) ZO_Tooltips_HideTextTooltip() end)
        else
            FenetreLabyrinthe.Corps[nomTable].BoutonHandler:SetHandler("OnMouseEnter", function(control) ZO_Tooltips_ShowTextTooltip(control, BOTTOM, "|cEFD807"..LabyODD.MaisonNomId[nMaison].."|r") end)
            FenetreLabyrinthe.Corps[nomTable].BoutonHandler:SetHandler("OnMouseExit", function(control) ZO_Tooltips_HideTextTooltip() end)
        end
    else
        FenetreLabyrinthe.Corps[nomTable].BoutonHandler:SetHandler("OnMouseEnter", function(control) ZO_Tooltips_ShowTextTooltip(control, BOTTOM, LabyODD.Langue.SansDescription) end)
        FenetreLabyrinthe.Corps[nomTable].BoutonHandler:SetHandler("OnMouseExit", function(control) ZO_Tooltips_HideTextTooltip() end)
    end
    FenetreLabyrinthe.Corps[nomTable].BoutonHandler:SetHandler("OnMouseUp", function(self)
                                                                                Voyage(proprio, nMaison)
                                                                                FermerFenetre()
                                                                            end)
    
    FenetreLabyrinthe.Corps[nomTable].BoutonTexte = wm:CreateControl("ODDLabyBBoutonTexte"..nombreLabyAffiche, FenetreLabyrinthe.Corps[nomTable].Control, CT_LABEL)
    FenetreLabyrinthe.Corps[nomTable].BoutonTexte:SetAnchor(TOPLEFT, FenetreLabyrinthe.Corps[nomTable].Control, TOPLEFT, LabyODD.Langue.NomMaisonDist, dec)
    FenetreLabyrinthe.Corps[nomTable].BoutonTexte:SetFont("$(BOLD_FONT)|$(KB_20)soft-shadow-thick")
    FenetreLabyrinthe.Corps[nomTable].BoutonTexte:SetColor(1, 1, 0.7)
    if (donneesMaison.textes and (donneesMaison.textes.Nom ~= nil and donneesMaison.textes.Nom ~= "")) then
        FenetreLabyrinthe.Corps[nomTable].BoutonTexte:SetText(donneesMaison.textes.Nom)
    else
        FenetreLabyrinthe.Corps[nomTable].BoutonTexte:SetText(LabyODD.MaisonNomId[nMaison])
    end

    
    if LabyODD.parametre["enregistrement"][proprio] == nil then
        LabyODD.parametre["enregistrement"][proprio] = {}
        -- d("check")
    end
    if LabyODD.parametre["enregistrement"][proprio][nMaison] == nil then
        LabyODD.parametre["enregistrement"][proprio][nMaison] = {}
        -- Nouvelle colonne avec les différents records : première date, meilleurs score, date meilleurs score
        LabyODD.parametre["enregistrement"][proprio][nMaison].Record = 0
        LabyODD.parametre["enregistrement"][proprio][nMaison].Premieredate = 0
        LabyODD.parametre["enregistrement"][proprio][nMaison].Meilleurdate = 0
    end


    if (donneesMaison["type"] == "interactions meubles multiples") then
        if LabyODD.parametre["enregistrement"][proprio][nMaison]["meuble"] == nil then
            local listeMeubles = LabyODD.listeLabyrinthe[proprio][nMaison]["meubles"]
            LabyODD.parametre["enregistrement"][proprio][nMaison].meuble = {}
            for i = 1, #listeMeubles do
                LabyODD.parametre["enregistrement"][proprio][nMaison].meuble[i] = 0
            end
        end

        FenetreLabyrinthe.Corps[nomTable].RecordHandler = wm:CreateControl("ODDLabyRecordHandler"..nombreLabyAffiche, FenetreLabyrinthe.Corps[nomTable].Control, CT_CONTROL)
        FenetreLabyrinthe.Corps[nomTable].RecordHandler:SetDimensions(180, 30)
        FenetreLabyrinthe.Corps[nomTable].RecordHandler:SetAnchor(TOPLEFT, FenetreLabyrinthe.Corps[nomTable].Control, TOPLEFT, LabyODD.Langue.MeilleurTempDist, dec)
        FenetreLabyrinthe.Corps[nomTable].RecordHandler:SetMouseEnabled(true)
        FenetreLabyrinthe.Corps[nomTable].RecordHandler:SetHandler("OnMouseEnter", function(control) ZO_Tooltips_ShowTextTooltip(control, LEFT, LabyODD.AffichageDetailsProgressionMeublesInteraction(proprio, nMaison)) end)
        FenetreLabyrinthe.Corps[nomTable].RecordHandler:SetHandler("OnMouseExit", function(control) ZO_Tooltips_HideTextTooltip() end)
    end



    FenetreLabyrinthe.Corps[nomTable].Record = wm:CreateControl("ODDLabyTexteRecord"..nombreLabyAffiche, FenetreLabyrinthe.Corps[nomTable].Control, CT_LABEL)
    FenetreLabyrinthe.Corps[nomTable].Record:SetAnchor(TOPLEFT, FenetreLabyrinthe.Corps[nomTable].Control, TOPLEFT, LabyODD.Langue.MeilleurTempDist, dec)
    FenetreLabyrinthe.Corps[nomTable].Record:SetFont("$(BOLD_FONT)|$(KB_20)soft-shadow-thick")
    FenetreLabyrinthe.Corps[nomTable].Record:SetColor(1, 1, 1)
    if (LabyODD.parametre["enregistrement"][proprio][nMaison].Record == 0) then
        FenetreLabyrinthe.Corps[nomTable].Record:SetText("-")
    else
        local tempsTotal = LabyODD.parametre["enregistrement"][proprio][nMaison].Record
        local texte = LabyODD.Temps(tempsTotal)
        FenetreLabyrinthe.Corps[nomTable].Record:SetText(texte)
    end

    FenetreLabyrinthe.Corps[nomTable].MeilleurDate = wm:CreateControl("ODDLabyTexteMeilleurDate"..nombreLabyAffiche, FenetreLabyrinthe.Corps[nomTable].Control, CT_LABEL)
    FenetreLabyrinthe.Corps[nomTable].MeilleurDate:SetAnchor(TOPLEFT, FenetreLabyrinthe.Corps[nomTable].Control, TOPLEFT, LabyODD.Langue.DateTempDist, dec)
    FenetreLabyrinthe.Corps[nomTable].MeilleurDate:SetFont("$(BOLD_FONT)|$(KB_20)soft-shadow-thick")
    FenetreLabyrinthe.Corps[nomTable].MeilleurDate:SetColor(1, 1, 1)
    if (LabyODD.parametre["enregistrement"][proprio][nMaison].Meilleurdate == 0) then
        FenetreLabyrinthe.Corps[nomTable].MeilleurDate:SetText("-")
    else
        FenetreLabyrinthe.Corps[nomTable].MeilleurDate:SetText(GetDateStringFromTimestamp(LabyODD.parametre["enregistrement"][proprio][nMaison].Meilleurdate))
    end

    FenetreLabyrinthe.Corps[nomTable].PremiereDate = wm:CreateControl("ODDLabyTextePremierDate"..nombreLabyAffiche, FenetreLabyrinthe.Corps[nomTable].Control, CT_LABEL)
    FenetreLabyrinthe.Corps[nomTable].PremiereDate:SetAnchor(TOPLEFT, FenetreLabyrinthe.Corps[nomTable].Control, TOPLEFT, LabyODD.Langue.DatePassageDist, dec)
    FenetreLabyrinthe.Corps[nomTable].PremiereDate:SetFont("$(BOLD_FONT)|$(KB_20)soft-shadow-thick")
    FenetreLabyrinthe.Corps[nomTable].PremiereDate:SetColor(1, 1, 1)
    if (LabyODD.parametre["enregistrement"][proprio][nMaison].Premieredate == 0) then
        FenetreLabyrinthe.Corps[nomTable].PremiereDate:SetText("-")
    else
        FenetreLabyrinthe.Corps[nomTable].PremiereDate:SetText(GetDateStringFromTimestamp(LabyODD.parametre["enregistrement"][proprio][nMaison].Premieredate))
    end

    FenetreLabyrinthe.Corps[nomTable].BoutonNomReset = wm:CreateControlFromVirtual("ODDLabyBoutonReset"..nombreLabyAffiche, FenetreLabyrinthe.Corps[nomTable].Control, "ZO_DefaultButton")
    FenetreLabyrinthe.Corps[nomTable].BoutonNomReset:SetAnchor(TOPLEFT, FenetreLabyrinthe.Corps[nomTable].Control, TOPLEFT, LabyODD.Langue.BoutonResetDist, dec)
    FenetreLabyrinthe.Corps[nomTable].BoutonNomReset:SetFont("$(BOLD_FONT)|$(KB_20)soft-shadow-thick")
    FenetreLabyrinthe.Corps[nomTable].BoutonNomReset:SetText(LabyODD.Langue.BoutonReset)
    FenetreLabyrinthe.Corps[nomTable].BoutonNomReset:SetHandler("OnClicked", function(self, button, ctrl, alt, shift, command)
                                                                                LabyODD.parametre["enregistrement"][proprio][nMaison]["Record"] = 0
                                                                                FenetreLabyrinthe.Corps[nomTable].Record:SetText("-")

                                                                                if (donneesMaison["type"] == "interactions meubles multiples") then
                                                                                    local listeMeubles = LabyODD.listeLabyrinthe[proprio][nMaison]["meubles"]
                                                                                    for i = 1, #listeMeubles do
                                                                                        LabyODD.parametre["enregistrement"][proprio][nMaison].meuble[i] = 0
                                                                                    end
                                                                                end
                                                                             end)

    FenetreLabyrinthe.Corps[nomTable].BoutonNomLien = wm:CreateControlFromVirtual("ODDLabyBoutonLien"..nombreLabyAffiche, FenetreLabyrinthe.Corps[nomTable].Control, "ZO_DefaultButton")
    FenetreLabyrinthe.Corps[nomTable].BoutonNomLien:SetAnchor(TOPLEFT, FenetreLabyrinthe.Corps[nomTable].Control, TOPLEFT, LabyODD.Langue.BoutonLienDist, dec)
    FenetreLabyrinthe.Corps[nomTable].BoutonNomLien:SetFont("$(BOLD_FONT)|$(KB_20)soft-shadow-thick")
    FenetreLabyrinthe.Corps[nomTable].BoutonNomLien:SetText(LabyODD.Langue.BoutonLien)
    FenetreLabyrinthe.Corps[nomTable].BoutonNomLien:SetHandler("OnClicked",  function(self, button, ctrl, alt, shift, command) 
                                                                                CHAT_SYSTEM.textEntry.editControl:InsertText("|H1:housing:"..nMaison..":"..proprio.."|h|h")
                                                                            end)
    FenetreLabyrinthe.Corps[nomTable].BoutonNomLien:SetDimensions(80, 30)

    nombreLabyAffiche = nombreLabyAffiche + 1
end


function LabyODD.FenetreLaby()
    if FenetreLabyrinthe.Fenetre ~= nil then
        if FenetreLabyrinthe.Fenetre:IsHidden() then
            FenetreLabyrinthe.Fenetre:SetHidden()
            SetGameCameraUIMode(not FenetreLabyrinthe.Fenetre:IsHidden())
        else
            FermerFenetre()
        end
        return
    end
    -- d("Création de la fenêtre")
    FenetreLabyrinthe.Fenetre = wm:CreateTopLevelWindow("MaFenetreALabyrinthe")
    FenetreLabyrinthe.Fenetre:SetDimensions(1200, 800)
    FenetreLabyrinthe.Fenetre:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    FenetreLabyrinthe.Fenetre:SetMovable(true)
    FenetreLabyrinthe.Fenetre:SetMouseEnabled(true)
    FenetreLabyrinthe.Fenetre:SetClampedToScreen(true)
    FenetreLabyrinthe.Fenetre:SetDrawLayer(3)
    FenetreLabyrinthe.Fenetre:SetDrawLevel(0)
    FenetreLabyrinthe.Fenetre:SetHidden(false)

    FenetreLabyrinthe.Control = wm:CreateControl("ODDLabyControl", FenetreLabyrinthe.Fenetre, CT_CONTROL)
    FenetreLabyrinthe.Control:SetDimensions(1200, 800)
    FenetreLabyrinthe.Control:SetAnchor(CENTER, FenetreLabyrinthe.Fenetre, CENTER, 0, 0)
    FenetreLabyrinthe.Control:SetDrawLayer(0)

    FenetreLabyrinthe.Fond = CreateControlFromVirtual("ODDLabyFond", FenetreLabyrinthe.Control, "ZO_SliderBackdrop")
    FenetreLabyrinthe.Fond:SetCenterColor(0.0, 0.0, 0.0, 1)
    FenetreLabyrinthe.Fond:SetEdgeColor(1.0, 1.0, 1.0, 0.7)

    FenetreLabyrinthe.Titre = wm:CreateControl("ODDLabyTete", FenetreLabyrinthe.Control, CT_LABEL)
    FenetreLabyrinthe.Titre:SetAnchor(TOP, FenetreLabyrinthe.Control, TOP, 0, 5)
    FenetreLabyrinthe.Titre:SetFont("$(BOLD_FONT)|$(KB_20)soft-shadow-thick")
    FenetreLabyrinthe.Titre:SetColor(1, 1, 1)
    FenetreLabyrinthe.Titre:SetText("ODD Labyrinthe")

    FenetreLabyrinthe.Fermer = wm:CreateControl("ODDLabyFenetreFermer", FenetreLabyrinthe.Control, CT_BUTTON)
    FenetreLabyrinthe.Fermer:SetAnchor(TOPRIGHT, FenetreLabyrinthe.Control, TOPRIGHT, -10, 5)
    FenetreLabyrinthe.Fermer:SetDimensions(20, 20)
    FenetreLabyrinthe.Fermer:SetNormalTexture("/esoui/art/buttons/decline_up.dds")
    FenetreLabyrinthe.Fermer:SetMouseOverTexture("/esoui/art/buttons/decline_over.dds")
    FenetreLabyrinthe.Fermer:SetHandler("OnClicked", FermerFenetre)

    FenetreLabyrinthe.Corps = {}

    --   Propriétaire       Nom maison (lien)       Meilleurs temps         Date meilleurs temps        Date premier passage
    --                      Nom maison (lien)       -                       -                           -
    --                      Nom maison (lien)       Meilleurs temps         Date meilleurs temps        Date premier passage
    --                      Nom maison (lien)       -                       -                           -
    --                      Nom maison (lien)       Meilleurs temps         Date meilleurs temps        Date premier passage
    --   Propriétaire       Nom maison (lien)       Meilleurs temps         Date meilleurs temps        Date premier passage
    --                      Nom maison (lien)       Meilleurs temps         Date meilleurs temps        Date premier passage

    --   Les titres

    -- d("Remplissage de la fenêtre")
    FenetreLabyrinthe.Corps["Proprio0"] = {}

    FenetreLabyrinthe.Corps["Proprio0"].Control = wm:CreateControl("ODDLabyControle", FenetreLabyrinthe.Control, CT_CONTROL)
    FenetreLabyrinthe.Corps["Proprio0"].Control:SetDimensions(1200, 30)
    FenetreLabyrinthe.Corps["Proprio0"].Control:SetAnchor(TOP, FenetreLabyrinthe.Control, TOP, 0, 0)

    FenetreLabyrinthe.Corps["Proprio0"].NomProprio = wm:CreateControl("ODDLabyTexteProprio", FenetreLabyrinthe.Corps["Proprio0"].Control, CT_LABEL)
    FenetreLabyrinthe.Corps["Proprio0"].NomProprio:SetAnchor(TOPLEFT, FenetreLabyrinthe.Corps["Proprio0"].Control, TOPLEFT, LabyODD.Langue.NomProprioDist, 55)
    FenetreLabyrinthe.Corps["Proprio0"].NomProprio:SetFont("$(BOLD_FONT)|$(KB_20)soft-shadow-thick")
    FenetreLabyrinthe.Corps["Proprio0"].NomProprio:SetColor(1, 1, 1)
    FenetreLabyrinthe.Corps["Proprio0"].NomProprio:SetText(LabyODD.Langue.NomProprio)

    FenetreLabyrinthe.Corps["Proprio0"].NomMaison = wm:CreateControl("ODDLabyTexteMaison", FenetreLabyrinthe.Corps["Proprio0"].Control, CT_LABEL)
    FenetreLabyrinthe.Corps["Proprio0"].NomMaison:SetAnchor(TOPLEFT, FenetreLabyrinthe.Corps["Proprio0"].Control, TOPLEFT, LabyODD.Langue.NomMaisonDist, 55)
    FenetreLabyrinthe.Corps["Proprio0"].NomMaison:SetFont("$(BOLD_FONT)|$(KB_20)soft-shadow-thick")
    FenetreLabyrinthe.Corps["Proprio0"].NomMaison:SetColor(1, 1, 1)
    FenetreLabyrinthe.Corps["Proprio0"].NomMaison:SetText(LabyODD.Langue.NomMaison)

    FenetreLabyrinthe.Corps["Proprio0"].Record = wm:CreateControl("ODDLabyTexteRecord", FenetreLabyrinthe.Corps["Proprio0"].Control, CT_LABEL)
    FenetreLabyrinthe.Corps["Proprio0"].Record:SetAnchor(TOPLEFT, FenetreLabyrinthe.Corps["Proprio0"].Control, TOPLEFT, LabyODD.Langue.MeilleurTempDist, 55)
    FenetreLabyrinthe.Corps["Proprio0"].Record:SetFont("$(BOLD_FONT)|$(KB_20)soft-shadow-thick")
    FenetreLabyrinthe.Corps["Proprio0"].Record:SetColor(1, 1, 1)
    FenetreLabyrinthe.Corps["Proprio0"].Record:SetText(LabyODD.Langue.MeilleurTemp)

    FenetreLabyrinthe.Corps["Proprio0"].Meilleurdate = wm:CreateControl("ODDLabyTexteMeilleurDate", FenetreLabyrinthe.Corps["Proprio0"].Control, CT_LABEL)
    FenetreLabyrinthe.Corps["Proprio0"].Meilleurdate:SetAnchor(TOPLEFT, FenetreLabyrinthe.Corps["Proprio0"].Control, TOPLEFT, LabyODD.Langue.DateTempDist, 55)
    FenetreLabyrinthe.Corps["Proprio0"].Meilleurdate:SetFont("$(BOLD_FONT)|$(KB_20)soft-shadow-thick")
    FenetreLabyrinthe.Corps["Proprio0"].Meilleurdate:SetColor(1, 1, 1)
    FenetreLabyrinthe.Corps["Proprio0"].Meilleurdate:SetText(LabyODD.Langue.DateTemp)

    FenetreLabyrinthe.Corps["Proprio0"].PremiereDate = wm:CreateControl("ODDLabyTextePremierDate", FenetreLabyrinthe.Corps["Proprio0"].Control, CT_LABEL)
    FenetreLabyrinthe.Corps["Proprio0"].PremiereDate:SetAnchor(TOPLEFT, FenetreLabyrinthe.Corps["Proprio0"].Control, TOPLEFT, LabyODD.Langue.DatePassageDist, 55)
    FenetreLabyrinthe.Corps["Proprio0"].PremiereDate:SetFont("$(BOLD_FONT)|$(KB_20)soft-shadow-thick")
    FenetreLabyrinthe.Corps["Proprio0"].PremiereDate:SetColor(1, 1, 1)
    FenetreLabyrinthe.Corps["Proprio0"].PremiereDate:SetText(LabyODD.Langue.DatePassage)

    -- d("Ajout des maisons")
    for proprio, maisons in pairs(LabyODD.listeLabyrinthe) do
        for nMaison, variables in pairs(maisons) do
            ajouterMaison(proprio, nMaison, variables)
        end
    end

    
end

SLASH_COMMANDS["/menulabyrinthe"] = LabyODD.FenetreLaby
