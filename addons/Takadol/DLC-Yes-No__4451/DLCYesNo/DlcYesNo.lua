-- DlcYesNo - Addon simple pour vérifier la possession des DLC
-- Inspiré par la structure de MapPins

local AddonName = "DlcYesNo"
DYN = DYN or {} -- Addon Namespace
DYN.L = {} -- Language table

local DlcWindow -- Référence à la fenêtre
local DlcIcon -- Référence à l'icône
local savedVars -- Variables sauvegardées
local ShowDlcStatus -- Déclaration anticipée
local isCollapsed = false -- État réduit ou non
local dlcDataCache = nil -- Cache pour les données DLC
local isCacheDirty = true -- Marqueur pour savoir si on doit recalculer

--[[ GESTION DE LA LANGUE ]]--
local function LoadLanguage(lang)
    if DYN_L and DYN_L[lang] then
        DYN.L = DYN_L[lang]
    else -- Fallback sur l'anglais si la langue n'est pas trouvée
        DYN.L = DYN_L['en']
    end
    isCacheDirty = true -- La langue a changé, on invalide le cache
    -- Enregistrement du nom du raccourci pour le menu commandes
    ZO_CreateStringId("SI_BINDING_NAME_DYN_TOGGLE_WINDOW", DYN.L["SI_DYN_BINDING_TOGGLE"] or "Toggle Window")
    ZO_CreateStringId("SI_BINDING_NAME_DYN_TOGGLE_COLLAPSE", DYN.L["SI_DYN_BINDING_COLLAPSE"] or "Collapse/Expand")
    ZO_CreateStringId("SI_BINDING_NAME_DYN_TOGGLE_COMBAT_MODE", DYN.L["SI_DYN_BINDING_COMBAT"] or "Combat Mode")
    ZO_CreateStringId("SI_BINDING_NAME_DYN_TOGGLE_SCENE_MODE", DYN.L["SI_DYN_BINDING_SCENE"] or "Scene Mode")
    ZO_CreateStringId("SI_BINDING_NAME_DYN_TOGGLE_HALO_OWNED", DYN.L["SI_DYN_BINDING_HALO_OWNED"] or "Toggle Owned Halos")
    ZO_CreateStringId("SI_BINDING_NAME_DYN_TOGGLE_HALO_MISSING", DYN.L["SI_DYN_BINDING_HALO_MISSING"] or "Toggle Missing Halos")
end

local function T(key)
    return DYN.L[key] or key
end

-- Fonction robuste pour ouvrir la boutique
local function JumpToStore(collectibleId, name)
    -- 1. D'abord essayer de trouver l'ID précis du produit (Le plus fiable pour les achats)
    -- Cela permet d'ouvrir la page exacte du pack de jeu, sans confusion avec les éclats célestes
    if GetMarketProductForCollectible then
        local productId = GetMarketProductForCollectible(collectibleId)
        if productId and productId > 0 then
            ShowMarketProduct(productId)
            return
        end
    end

    -- 2. Recherche textuelle (Plus fiable que OpenMarketToCollectible qui pointe parfois vers les Éclats)
    if ShowMarketAndSearch then
        local searchString = zo_strformat("<<1>>", name)
        ShowMarketAndSearch(searchString, MARKET_OPEN_OPERATION_COLLECTIBLE_SEARCH)
        return
    end
    
    -- 3. Fallback : utiliser la fonction native de navigation (Si la recherche n'est pas dispo)
    if OpenMarketToCollectible then
        OpenMarketToCollectible(collectibleId)
        return
    end
    
    d("|cFF0000[DlcYesNo]|r Erreur : Impossible d'accéder à l'API de la boutique.") -- Pas besoin de traduire, message d'erreur technique
end

-- Fonction pour cacher la fenêtre (utilisée par le module de combat)
local function HideWindowForCombat()
    if DlcWindow and not DlcWindow:IsHidden() then
        DlcWindow:SetHidden(true)
        return true -- C'était visible et maintenant caché
    end
    return false -- Ce n'était pas visible ou n'existait pas
end

-- Fonction pour créer la fenêtre si elle n'existe pas
local function CreateDlcWindow()
    local wm = WINDOW_MANAGER
    
    -- Création de la fenêtre principale
    DlcWindow = wm:CreateControl("DlcYesNoWindow", GuiRoot, CT_TOPLEVELCONTROL)
    DlcWindow:SetDimensions(savedVars.width, savedVars.height)
    DlcWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, savedVars.winLeft, savedVars.winTop)
    DlcWindow:SetClampedToScreen(true)
    DlcWindow:SetMouseEnabled(true)
    DlcWindow:SetDrawTier(DT_HIGH) -- Force la fenêtre au-dessus de la carte
    DlcWindow:SetDrawLayer(DL_CONTROLS) -- Couche standard (laisse DL_OVERLAY aux tooltips)
    DlcWindow:SetMovable(true)
    DlcWindow:SetResizeHandleSize(10) -- Permet de redimensionner la fenêtre
    DlcWindow:SetDimensionConstraints(300, 55, -1, -1) -- Taille minimum (Largeur, Hauteur)
    DlcWindow:SetHidden(true)
    
    -- Sauvegarde de la position et de la taille
    DlcWindow:SetHandler("OnMoveStop", function(self)
        savedVars.winLeft = self:GetLeft()
        savedVars.winTop = self:GetTop()
    end)
    DlcWindow:SetHandler("OnResizeStop", function(self)
        if not isCollapsed then
            savedVars.width = self:GetWidth()
            savedVars.height = self:GetHeight()
        end
        ShowDlcStatus() -- Recalcule les colonnes
    end)

    -- Fond noir semi-transparent
    local bg = wm:CreateControl("$(parent)Bg", DlcWindow, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0, 0, 0, savedVars.opacity)
    bg:SetEdgeColor(1, 1, 1, 0.5)
    bg:SetEdgeTexture("", 2, 1, 0)
    DlcWindow.bg = bg -- Référence pour l'opacité

    -- Bouton de fermeture (X)
    local closeBtn = wm:CreateControl("$(parent)Close", DlcWindow, CT_BUTTON)
    closeBtn:SetDimensions(25, 25)
    closeBtn:SetAnchor(TOPRIGHT, DlcWindow, TOPRIGHT, -10, 10)
    closeBtn:SetNormalTexture("EsoUI/Art/Buttons/closebutton_up.dds")
    closeBtn:SetPressedTexture("EsoUI/Art/Buttons/closebutton_down.dds")
    closeBtn:SetMouseOverTexture("EsoUI/Art/Buttons/closebutton_mouseover.dds")
    closeBtn:SetHandler("OnClicked", function() 
        DlcWindow:SetHidden(true) 
        savedVars.windowOpen = false 
    end)

    -- Titre
    local title = wm:CreateControl("$(parent)Title", DlcWindow, CT_LABEL)
    title:SetAnchor(TOP, DlcWindow, TOP, 0, 5)
    title:SetFont("ZoFontWinH2")

    -- Compteur Global
    DlcWindow.counter = wm:CreateControl("$(parent)Counter", DlcWindow, CT_LABEL)
    DlcWindow.counter:SetAnchor(TOP, title, BOTTOM, 0, 1)
    DlcWindow.counter:SetFont("ZoFontWinH4")
    DlcWindow.counter:SetColor(1, 1, 1, 1)

    -- Bouton Tout Réduire / Agrandir
    local collapseBtn = wm:CreateControl("$(parent)Collapse", DlcWindow, CT_BUTTON)
    collapseBtn:SetDimensions(25, 25)
    collapseBtn:SetAnchor(RIGHT, closeBtn, LEFT, -5, 0)
    collapseBtn:SetNormalTexture("EsoUI/Art/Buttons/minus_up.dds")
    collapseBtn:SetPressedTexture("EsoUI/Art/Buttons/minus_down.dds")
    collapseBtn:SetMouseOverTexture("EsoUI/Art/Buttons/minus_over.dds")
    collapseBtn:SetHandler("OnClicked", function(self)
        isCollapsed = not isCollapsed
        local tex = isCollapsed and "EsoUI/Art/Buttons/plus_up.dds" or "EsoUI/Art/Buttons/minus_up.dds"
        self:SetNormalTexture(tex)
        ShowDlcStatus()
    end)
    DlcWindow.collapseBtn = collapseBtn -- Référence pour le raccourci

    -- Bouton Langue
    local langBtn = wm:CreateControl("$(parent)Lang", DlcWindow, CT_BUTTON)
    langBtn:SetDimensions(25, 25)
    langBtn:SetAnchor(RIGHT, collapseBtn, LEFT, -5, 0)
    langBtn:SetNormalTexture("DLCYesNo/Textures/Trad.dds")
    langBtn:SetPressedTexture("DLCYesNo/Textures/Trad.dds")
    langBtn:SetMouseOverTexture("DLCYesNo/Textures/Trad.dds")

    -- Popup de sélection de langue
    local langPopup = wm:CreateControl("$(parent)LangPopup", DlcWindow, CT_BACKDROP)
    langPopup:SetDimensions(200, 50)
    langPopup:SetAnchor(TOP, langBtn, BOTTOM, 0, 5)
    langPopup:SetCenterColor(0, 0, 0, 0.8)
    langPopup:SetHidden(true)

    langBtn:SetHandler("OnClicked", function() langPopup:SetHidden(not langPopup:IsHidden()) end)

    local langCodes = {"fr", "en", "de", "es", "ru"}
    local langIcons = {"Fr", "En", "De", "Es", "Ru"}
    local lastLangButton = nil

    for i, code in ipairs(langCodes) do
        local btn = wm:CreateControl("$(parent)Btn" .. code, langPopup, CT_BUTTON)
        btn:SetDimensions(32, 32)
        if lastLangButton then
            btn:SetAnchor(LEFT, lastLangButton, RIGHT, 5, 0)
        else
            btn:SetAnchor(LEFT, langPopup, LEFT, 10, 0)
        end
        btn:SetNormalTexture("DLCYesNo/Textures/" .. langIcons[i] .. ".dds")
        btn:SetHandler("OnClicked", function()
            savedVars.language = code
            LoadLanguage(code)
            langPopup:SetHidden(true)
            ShowDlcStatus() -- Rafraîchir toute la fenêtre
        end)
        btn:SetHandler("OnMouseEnter", function(self) InitializeTooltip(InformationTooltip, self, BOTTOM, 0, 0) InformationTooltip:AddLine(T("SI_DYN_LANG_" .. string.upper(code))) end)
        btn:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)
        lastLangButton = btn
    end

    -- Bouton Combat (Fermeture auto)
    local combatBtn = wm:CreateControl("$(parent)Combat", DlcWindow, CT_BUTTON)
    combatBtn:SetDimensions(25, 25)
    combatBtn:SetAnchor(RIGHT, langBtn, LEFT, -5, 0)
    combatBtn:SetNormalTexture("EsoUI/Art/LFG/LFG_dps_up.dds")
    combatBtn:SetPressedTexture("EsoUI/Art/LFG/LFG_dps_down.dds")
    combatBtn:SetMouseOverTexture("EsoUI/Art/LFG/LFG_dps_over.dds")

    local function UpdateCombatButton()
        if savedVars.closeOnCombat then
            combatBtn:SetAlpha(1) -- Actif (Visible)
        else
            combatBtn:SetAlpha(0.3) -- Inactif (Grisé)
        end
    end

    combatBtn:SetHandler("OnClicked", function()
        savedVars.closeOnCombat = not savedVars.closeOnCombat
        UpdateCombatButton()
        -- Rafraîchir l'infobulle immédiatement si la souris est dessus
        if MouseIsOver(combatBtn) then combatBtn:GetHandler("OnMouseEnter")(combatBtn) end
    end)
    combatBtn:SetHandler("OnMouseEnter", function(self) InitializeTooltip(InformationTooltip, self, BOTTOM, 0, 0) InformationTooltip:AddLine(T("SI_DYN_TOOLTIP_COMBAT") .. (savedVars.closeOnCombat and " |c00FF00(ON)|r" or " |cFF0000(OFF)|r")) end)
    combatBtn:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)
    UpdateCombatButton()
    
    DlcWindow.combatBtn = combatBtn -- Référence pour le raccourci
    DlcWindow.UpdateCombatButton = UpdateCombatButton -- Fonction pour mise à jour visuelle

    -- Bouton Scènes (Fermeture auto Inventaire/Carte)
    local sceneBtn = wm:CreateControl("$(parent)Scene", DlcWindow, CT_BUTTON)
    sceneBtn:SetDimensions(25, 25)
    sceneBtn:SetAnchor(RIGHT, combatBtn, LEFT, -5, 0)
    sceneBtn:SetNormalTexture("EsoUI/Art/MainMenu/menuBar_inventory_up.dds")
    sceneBtn:SetPressedTexture("EsoUI/Art/MainMenu/menuBar_inventory_down.dds")
    sceneBtn:SetMouseOverTexture("EsoUI/Art/MainMenu/menuBar_inventory_over.dds")

    local function UpdateSceneButton()
        if savedVars.closeOnScenes then sceneBtn:SetAlpha(1) else sceneBtn:SetAlpha(0.3) end
    end

    sceneBtn:SetHandler("OnClicked", function()
        savedVars.closeOnScenes = not savedVars.closeOnScenes
        UpdateSceneButton()
        -- Force la mise à jour immédiate du tooltip si la souris est dessus
        if MouseIsOver(sceneBtn) then sceneBtn:GetHandler("OnMouseEnter")(sceneBtn) end
    end)
    sceneBtn:SetHandler("OnMouseEnter", function(self) InitializeTooltip(InformationTooltip, self, BOTTOM, 0, 0) InformationTooltip:AddLine(T("SI_DYN_TOOLTIP_SCENE") .. (savedVars.closeOnScenes and " |c00FF00(ON)|r" or " |cFF0000(OFF)|r")) end)
    sceneBtn:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)
    UpdateSceneButton()
    DlcWindow.sceneBtn = sceneBtn
    DlcWindow.UpdateSceneButton = UpdateSceneButton -- Fonction pour mise à jour visuelle (Raccourci)

    -- Tooltips pour les boutons du haut
    collapseBtn:SetHandler("OnMouseEnter", function(self) InitializeTooltip(InformationTooltip, self, BOTTOM, 0, 0) InformationTooltip:AddLine(T("SI_DYN_TOOLTIP_COLLAPSE")) end)
    collapseBtn:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)
    langBtn:SetHandler("OnMouseEnter", function(self) InitializeTooltip(InformationTooltip, self, BOTTOM, 0, 0) InformationTooltip:AddLine(T("SI_DYN_TOOLTIP_TRANSLATE")) end)
    langBtn:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)

    -- Contrôle d'opacité (-) XX% (+)
    local opMinus = wm:CreateControl("$(parent)OpMinus", DlcWindow, CT_BUTTON)
    opMinus:SetDimensions(25, 25)
    opMinus:SetAnchor(TOPLEFT, DlcWindow, TOPLEFT, 10, 15)
    opMinus:SetNormalTexture("EsoUI/Art/Buttons/minus_up.dds")
    opMinus:SetPressedTexture("EsoUI/Art/Buttons/minus_down.dds")
    opMinus:SetMouseOverTexture("EsoUI/Art/Buttons/minus_over.dds")

    local opLabel = wm:CreateControl("$(parent)OpLabel", DlcWindow, CT_LABEL)
    opLabel:SetAnchor(LEFT, opMinus, RIGHT, 5, 0)
    opLabel:SetFont("ZoFontGameSmall")
    
    local opPlus = wm:CreateControl("$(parent)OpPlus", DlcWindow, CT_BUTTON)
    opPlus:SetDimensions(25, 25)
    opPlus:SetAnchor(LEFT, opLabel, RIGHT, 5, 0)
    opPlus:SetNormalTexture("EsoUI/Art/Buttons/plus_up.dds")
    opPlus:SetPressedTexture("EsoUI/Art/Buttons/plus_down.dds")
    opPlus:SetMouseOverTexture("EsoUI/Art/Buttons/plus_over.dds")

    DlcWindow.opMinus = opMinus
    DlcWindow.opLabel = opLabel
    DlcWindow.opPlus = opPlus

    local function UpdateOpacity()
        if savedVars.opacity > 1 then savedVars.opacity = 1 end
        if savedVars.opacity < 0.2 then savedVars.opacity = 0.2 end
        DlcWindow.bg:SetCenterColor(0, 0, 0, savedVars.opacity)
        opLabel:SetText(string.format("%d%%", zo_round(savedVars.opacity * 100)))
    end

    opMinus:SetHandler("OnClicked", function() savedVars.opacity = savedVars.opacity - 0.1; UpdateOpacity() end)
    opPlus:SetHandler("OnClicked", function() savedVars.opacity = savedVars.opacity + 0.1; UpdateOpacity() end)
    opMinus:SetHandler("OnMouseEnter", function(self) InitializeTooltip(InformationTooltip, self, BOTTOM, 0, 0); InformationTooltip:AddLine("Diminuer l'opacité de la fenêtre") end)
    opMinus:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)
    opPlus:SetHandler("OnMouseEnter", function(self) InitializeTooltip(InformationTooltip, self, BOTTOM, 0, 0); InformationTooltip:AddLine("Augmenter l'opacité de la fenêtre") end)
    opPlus:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)
    UpdateOpacity() -- Init

    -- Contrôles des Halos (Opacité et Taille) - Placés à droite du contrôle d'opacité de la fenêtre
    local haloOpPlus = wm:CreateControl("$(parent)HaloOpPlus", DlcWindow, CT_BUTTON)
    haloOpPlus:SetDimensions(25, 25)
    haloOpPlus:SetNormalTexture("EsoUI/Art/Buttons/plus_up.dds")
    haloOpPlus:SetPressedTexture("EsoUI/Art/Buttons/plus_down.dds")
    haloOpPlus:SetMouseOverTexture("EsoUI/Art/Buttons/plus_over.dds")
    haloOpPlus:SetHidden(true)

    local haloOpLabel = wm:CreateControl("$(parent)HaloOpLabel", DlcWindow, CT_LABEL)
    haloOpLabel:SetFont("ZoFontGameSmall")
    haloOpLabel:SetHidden(true)

    local haloOpMinus = wm:CreateControl("$(parent)HaloOpMinus", DlcWindow, CT_BUTTON)
    haloOpMinus:SetDimensions(25, 25)
    haloOpMinus:SetNormalTexture("EsoUI/Art/Buttons/minus_up.dds")
    haloOpMinus:SetPressedTexture("EsoUI/Art/Buttons/minus_down.dds")
    haloOpMinus:SetMouseOverTexture("EsoUI/Art/Buttons/minus_over.dds")
    haloOpMinus:SetHidden(true)

    DlcWindow.haloOpMinus = haloOpMinus
    DlcWindow.haloOpLabel = haloOpLabel
    DlcWindow.haloOpPlus = haloOpPlus

    -- Ancrage Opacité Halo (de gauche à droite)
    haloOpMinus:SetAnchor(LEFT, opPlus, RIGHT, 20, 0)
    haloOpLabel:SetAnchor(LEFT, haloOpMinus, RIGHT, 5, 0)
    haloOpPlus:SetAnchor(LEFT, haloOpLabel, RIGHT, 5, 0)

    local function UpdateHaloOpacity()
        if not savedVars.haloOpacity then savedVars.haloOpacity = 1 end
        if savedVars.haloOpacity > 1 then savedVars.haloOpacity = 1 end
        if savedVars.haloOpacity < 0.1 then savedVars.haloOpacity = 0.1 end
        haloOpLabel:SetText(string.format("%d%%", zo_round(savedVars.haloOpacity * 100)))
        if DYN.Zone and DYN.Zone.RefreshMapPins then DYN.Zone.RefreshMapPins() end
    end

    haloOpMinus:SetHandler("OnClicked", function() savedVars.haloOpacity = savedVars.haloOpacity - 0.1; UpdateHaloOpacity() end)
    haloOpPlus:SetHandler("OnClicked", function() savedVars.haloOpacity = savedVars.haloOpacity + 0.1; UpdateHaloOpacity() end)
    haloOpMinus:SetHandler("OnMouseEnter", function(self) InitializeTooltip(InformationTooltip, self, BOTTOM, 0, 0); InformationTooltip:AddLine("Diminuer l'opacité des halos") end)
    haloOpMinus:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)
    haloOpPlus:SetHandler("OnMouseEnter", function(self) InitializeTooltip(InformationTooltip, self, BOTTOM, 0, 0); InformationTooltip:AddLine("Augmenter l'opacité des halos") end)
    haloOpPlus:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)
    UpdateHaloOpacity()

    -- Contrôle Taille Halo (-) XX (+)
    local haloMinus = wm:CreateControl("$(parent)HaloMinus", DlcWindow, CT_BUTTON)
    haloMinus:SetDimensions(25, 25)
    haloMinus:SetNormalTexture("EsoUI/Art/Buttons/minus_up.dds")
    haloMinus:SetPressedTexture("EsoUI/Art/Buttons/minus_down.dds")
    haloMinus:SetMouseOverTexture("EsoUI/Art/Buttons/minus_over.dds")
    haloMinus:SetHidden(true)

    local haloLabel = wm:CreateControl("$(parent)HaloLabel", DlcWindow, CT_LABEL)
    haloLabel:SetFont("ZoFontGameSmall")
    haloLabel:SetHidden(true)
    
    local haloPlus = wm:CreateControl("$(parent)HaloPlus", DlcWindow, CT_BUTTON)
    haloPlus:SetDimensions(25, 25)
    haloPlus:SetNormalTexture("EsoUI/Art/Buttons/plus_up.dds")
    haloPlus:SetPressedTexture("EsoUI/Art/Buttons/plus_down.dds")
    haloPlus:SetMouseOverTexture("EsoUI/Art/Buttons/plus_over.dds")
    haloPlus:SetHidden(true)

    DlcWindow.haloMinus = haloMinus
    DlcWindow.haloLabel = haloLabel
    DlcWindow.haloPlus = haloPlus

    -- Ancrage Taille Halo (En dessous de l'opacité)
    haloMinus:SetAnchor(TOPLEFT, haloOpMinus, BOTTOMLEFT, 0, 5)
    haloLabel:SetAnchor(LEFT, haloMinus, RIGHT, 5, 0)
    haloPlus:SetAnchor(LEFT, haloLabel, RIGHT, 5, 0)

    local function UpdateHaloSize()
        if not savedVars.haloSize then savedVars.haloSize = 50 end
        if savedVars.haloSize > 100 then savedVars.haloSize = 100 end
        if savedVars.haloSize < 20 then savedVars.haloSize = 20 end
        haloLabel:SetText(string.format("%d", savedVars.haloSize))
        if DYN.Zone and DYN.Zone.RefreshMapPins then DYN.Zone.RefreshMapPins() end
    end

    haloMinus:SetHandler("OnClicked", function() savedVars.haloSize = savedVars.haloSize - 5; UpdateHaloSize() end)
    haloPlus:SetHandler("OnClicked", function() savedVars.haloSize = savedVars.haloSize + 5; UpdateHaloSize() end)
    
    haloMinus:SetHandler("OnMouseEnter", function(self) InitializeTooltip(InformationTooltip, self, BOTTOM, 0, 0); InformationTooltip:AddLine("Diminuer la taille des halos") end)
    haloMinus:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)
    haloPlus:SetHandler("OnMouseEnter", function(self) InitializeTooltip(InformationTooltip, self, BOTTOM, 0, 0); InformationTooltip:AddLine("Augmenter la taille des halos") end)
    haloPlus:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)
    UpdateHaloSize()
    
    -- Gestion intelligente de la visibilité (Carte + Non réduit)
    DlcWindow.UpdateHaloVisibility = function()
        local isMapOpen = SCENE_MANAGER:IsShowing("worldMap")
        local visible = isMapOpen and not isCollapsed
        haloMinus:SetHidden(not visible)
        haloLabel:SetHidden(not visible)
        haloPlus:SetHidden(not visible)
        haloOpMinus:SetHidden(not visible)
        haloOpLabel:SetHidden(not visible)
        haloOpPlus:SetHidden(not visible)
    end
    
    SCENE_MANAGER:RegisterCallback("SceneStateChanged", function(scene, oldState, newState)
        if scene:GetName() == "worldMap" then DlcWindow.UpdateHaloVisibility() end
        if scene:GetName() == "worldMap" and newState == SCENE_SHOWING then
            DlcWindow:BringWindowToTop() -- Force la fenêtre au-dessus de la carte à l'ouverture
        end
    end)
    DlcWindow:SetHandler("OnEffectivelyShown", DlcWindow.UpdateHaloVisibility)

    -- Zone de défilement (Scroll) via le template officiel
    local scroll = wm:CreateControlFromVirtual("$(parent)Scroll", DlcWindow, "ZO_ScrollContainer")
    scroll:SetAnchor(TOPLEFT, DlcWindow, TOPLEFT, 20, 80)
    scroll:SetAnchor(BOTTOMRIGHT, DlcWindow, BOTTOMRIGHT, -20, -20)
    DlcWindow.scroll = scroll

    -- Conteneur pour la liste (Récupéré du template standard)
    DlcWindow.container = scroll:GetNamedChild("ScrollChild")
    
    DlcWindow.rows = {} -- Stockage des lignes pour réutilisation
    DlcWindow.headers = {} -- Stockage des titres de section    
end

-- Reconstruit le cache des données DLC (Optimisation CPU)
local function RebuildDlcData()
    if not isCacheDirty and dlcDataCache then return end

    local groups = {}
    local totalDLC = 0
    local ownedDLC = 0

    -- Localisation des fonctions pour performance dans la boucle
    local GetNumCollectibleCategories = GetNumCollectibleCategories
    local GetCollectibleCategoryInfo = GetCollectibleCategoryInfo
    local GetCollectibleSubCategoryInfo = GetCollectibleSubCategoryInfo
    local GetCollectibleId = GetCollectibleId
    local GetCollectibleInfo = GetCollectibleInfo
    local strFind = string.find
    local strLower = string.lower
    local tableInsert = table.insert

    for i = 1, GetNumCollectibleCategories() do
        local _, numSubCats = GetCollectibleCategoryInfo(i)
        for j = 1, numSubCats do
            local subName, numCols = GetCollectibleSubCategoryInfo(i, j)
            if numCols > 0 then
                local firstId = GetCollectibleId(i, j, 1)
                local _, _, _, _, _, _, _, categoryType = GetCollectibleInfo(firstId)
                
                if categoryType == COLLECTIBLE_CATEGORY_TYPE_DLC or categoryType == COLLECTIBLE_CATEGORY_TYPE_CHAPTER then
                    local groupKey = "ZONES"
                    if categoryType == COLLECTIBLE_CATEGORY_TYPE_CHAPTER then
                        groupKey = "CHAPTERS"
                    else
                        local n = strLower(subName)
                        if strFind(n, "dungeon") or strFind(n, "donjon") or strFind(n, "verlies") or strFind(n, "mazmorra") or strFind(n, "подземелье") then
                            groupKey = "DUNGEONS"
                        end
                    end
                    
                    if not groups[groupKey] then groups[groupKey] = {} end
                    
                    for k = 1, numCols do
                        local id = GetCollectibleId(i, j, k)
                        local name, desc, icon, _, owned = GetCollectibleInfo(id)
                        
                        if name and name ~= "" then
                            totalDLC = totalDLC + 1
                            if owned then ownedDLC = ownedDLC + 1 end
                            tableInsert(groups[groupKey], {
                                name = name, 
                                owned = owned, 
                                desc = desc,
                                id = id
                            })
                        end
                    end
                end
            end
        end
    end

    dlcDataCache = {
        groups = groups,
        total = totalDLC,
        owned = ownedDLC
    }
    isCacheDirty = false
end

-- Fonction principale pour afficher le statut des DLC
ShowDlcStatus = function()
    if not DlcWindow then CreateDlcWindow() end
    
    -- 1. Ajustement de la taille de la fenêtre (Réduit ou Normal) AVANT de calculer les colonnes
    -- Cela permet aux calculs de largeur (GetWidth) de se baser sur la bonne dimension
    if isCollapsed then
        DlcWindow:SetDimensions(550, 55) -- Taille fine et étroite
        DlcWindow.scroll:SetHidden(true)
        DlcWindow.opMinus:SetHidden(true)
        DlcWindow.opLabel:SetHidden(true)
        DlcWindow.opPlus:SetHidden(true)
    else
        DlcWindow:SetDimensions(savedVars.width, savedVars.height)
        DlcWindow.scroll:SetHidden(false)
        DlcWindow.opMinus:SetHidden(false)
        DlcWindow.opLabel:SetHidden(false)
        DlcWindow.opPlus:SetHidden(false)
    end
    
    -- Mise à jour visibilité boutons Halo (dépend de isCollapsed et de la carte)
    if DlcWindow.UpdateHaloVisibility then DlcWindow.UpdateHaloVisibility() end

    -- Mettre à jour les textes fixes
    DlcWindow:GetNamedChild("Title"):SetText(zo_strformat("|cFFFF00<<1>>|r", T("SI_DYN_WINDOW_TITLE")))

    -- Cacher toutes les lignes existantes avant de rafraîchir
    for _, row in pairs(DlcWindow.rows) do row:SetHidden(true) end
    for _, header in pairs(DlcWindow.headers) do header:SetHidden(true) end

    -- 1. Mise à jour des données (si nécessaire uniquement)
    RebuildDlcData()
    local data = dlcDataCache
    local groups = data.groups

    -- Mise à jour du compteur
    if DlcWindow.counter then
        DlcWindow.counter:SetText(zo_strformat("<<1>>|c00FF00<<2>>|r / <<3>>", T("SI_DYN_ACQUIRED_COUNTER"), data.owned, data.total))
    end

    -- 2. Séparation des groupes en deux colonnes (gauche/droite)
    -- On utilise les clés fixes pour répartir
    local leftGroupKeys = {}
    local rightGroupKeys = {}
    
    if groups["CHAPTERS"] then table.insert(leftGroupKeys, "CHAPTERS") end
    if groups["ZONES"] then table.insert(leftGroupKeys, "ZONES") end
    
    if groups["DUNGEONS"] then table.insert(rightGroupKeys, "DUNGEONS") end

    -- Tri de la colonne de gauche (Chapitres en premier)
    -- Déjà géré par l'ordre d'insertion manuel ci-dessus

    local wm = WINDOW_MANAGER
    local containerWidth = DlcWindow.scroll:GetWidth()
    DlcWindow.container:SetWidth(containerWidth)
    local colWidth = containerWidth / 2 -- Largeur dynamique selon la fenêtre
    local rowHeight = 20
    local maxColHeight = 0
    
    local rowCount = 0
    local headerCount = 0

    -- Fonction pour dessiner une colonne
    local function RenderColumn(groupKeys, colIndex)
        local y = 0
        for _, key in ipairs(groupKeys) do
            local list = groups[key]
            table.sort(list, function(a,b) return a.name < b.name end)

            -- Création/Affichage du Header
            headerCount = headerCount + 1
            local header = DlcWindow.headers[headerCount]
            if not header then
                header = wm:CreateControl("$(parent)Header" .. headerCount, DlcWindow.container, CT_LABEL)
                header:SetFont("ZoFontWinH4")
                header:SetColor(1, 1, 0, 1) -- Jaune
                DlcWindow.headers[headerCount] = header
            end
            
            header:ClearAnchors()
            header:SetAnchor(TOPLEFT, DlcWindow.container, TOPLEFT, colIndex * colWidth, y)
            header:SetDimensions(colWidth - 5, 25)
            header:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
            -- Ajout du nombre d'éléments dans le titre
            -- Traduction dynamique du titre ici
            local titleText = T("SI_DYN_GROUP_" .. key)
            header:SetText(zo_strformat("<<1>> (|cFFFFFF<<2>>|r)", titleText, #list))
            header:SetHidden(false)
            y = y + 25

            -- Si réduit, on n'affiche pas les lignes
            if not isCollapsed then
                for _, data in ipairs(list) do
                    rowCount = rowCount + 1
                    local row = DlcWindow.rows[rowCount]
                    if not row then
                        row = wm:CreateControl("$(parent)Row" .. rowCount, DlcWindow.container, CT_LABEL)
                        row:SetFont("ZoFontGame")
                        row:SetMouseEnabled(true)
                        DlcWindow.rows[rowCount] = row
                    end
                    
                    row:ClearAnchors()
                    row:SetAnchor(TOPLEFT, DlcWindow.container, TOPLEFT, colIndex * colWidth, y)
                    row:SetDimensions(colWidth - 5, rowHeight)
                    row:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
                    row:SetHidden(false)
                    
                    -- Couleur et Texte
                    local color = data.owned and "|c00FF00" or "|cFF0000"
                    local statusIcon = data.owned and "[Y]" or "[N]"
                    
                    row:SetText(zo_strformat("<<1>> <<2>>  <<3>>|r", color, statusIcon, data.name))
                    
                    -- Interaction : Clic pour Boutique
                    row:SetHandler("OnMouseUp", function(self, button)
                        if button == MOUSE_BUTTON_INDEX_LEFT then
                            JumpToStore(data.id, data.name)
                        end
                    end)
    
                    -- Tooltip
                    row:SetHandler("OnMouseEnter", function(self)
                        row:SetColor(0.8, 0.8, 1, 1) -- Surbrillance
                        InitializeTooltip(InformationTooltip, self, RIGHT, -5, 0, LEFT)
                        InformationTooltip:AddLine(data.name, "ZoFontHeader2")
                        InformationTooltip:AddLine(zo_strformat("|cFFFF00<<1>>|r", T("SI_DYN_TOOLTIP_JUMP_TO_STORE")), "ZoFontGameSmall")
                        InformationTooltip:AddLine(data.desc, "ZoFontGame", 0.8, 0.8, 0.8)
                        
                        -- Affichage des IDs si le Mode Édition est actif (pour DataHalos.lua)
                        if DYN.Zone and DYN.Zone.IsEditMode and DYN.Zone.IsEditMode() then
                            InformationTooltip:AddLine(string.format("Collectible ID: |cFFFFFF%d|r", data.id), "ZoFontGameSmall", 0.5, 0.5, 0.5)
                        end
                    end)
                    row:SetHandler("OnMouseExit", function(self)
                        row:SetColor(1, 1, 1, 1)
                        ClearTooltip(InformationTooltip)
                    end)
                    
                    y = y + rowHeight
                end
            end
            y = y + 10 -- Espace après le groupe
        end
        if y > maxColHeight then maxColHeight = y end
    end

    -- 3. Dessiner les deux colonnes
    if not isCollapsed then
        RenderColumn(leftGroupKeys, 0)
        RenderColumn(rightGroupKeys, 1)
    end

    -- Mise à jour de la hauteur du conteneur (pour le scroll)
    DlcWindow.container:SetHeight(maxColHeight)
    
    -- Afficher la fenêtre
    DlcWindow:SetHidden(false)
    savedVars.windowOpen = true
end

-- Création de la petite icône
local function CreateIcon()
    local wm = WINDOW_MANAGER
    local icon = wm:CreateControl("DlcYesNoIcon", GuiRoot, CT_TOPLEVELCONTROL)
    DlcIcon = icon
    icon:SetDimensions(50, 50)
    icon:SetClampedToScreen(true)
    icon:SetMouseEnabled(true)
    icon:SetMovable(false) -- On gère le mouvement manuellement
    icon:SetHidden(false)

    -- Position sauvegardée
    icon:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, savedVars.iconLeft, savedVars.iconTop)

    -- Texture
    local tex = wm:CreateControl("$(parent)Tex", icon, CT_TEXTURE)
    tex:SetAnchorFill()
    tex:SetTexture("DLCYesNo/Textures/DLC.dds")

    local isDragging = false

    -- Gestion du Shift+Clic pour déplacer
    icon:SetHandler("OnMouseDown", function(self, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and IsShiftKeyDown() then
            self:SetMovable(true)
            self:StartMoving()
            isDragging = true
        end
    end)

    -- Fin du clic ou du déplacement
    icon:SetHandler("OnMouseUp", function(self, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            if isDragging then
                -- Fin du déplacement
                self:StopMovingOrResizing()
                self:SetMovable(false)
                isDragging = false
                savedVars.iconLeft = self:GetLeft()
                savedVars.iconTop = self:GetTop()
            else
                -- Clic simple : Ouvrir/Fermer la fenêtre
                if DlcWindow and not DlcWindow:IsHidden() then
                    DlcWindow:SetHidden(true)
                else
                    ShowDlcStatus()
                end
            end
        end
    end)
end

-- Fonction globale pour le raccourci clavier (Toggle)
function DYN.ToggleWindow()
    if DlcWindow and not DlcWindow:IsHidden() then
        DlcWindow:SetHidden(true)
        savedVars.windowOpen = false
    else
        ShowDlcStatus()
    end
end

-- Fonction pour basculer la réduction (Raccourci)
function DYN.ToggleCollapse()
    if DlcWindow and not DlcWindow:IsHidden() then
        isCollapsed = not isCollapsed
        if DlcWindow.collapseBtn then
            local tex = isCollapsed and "EsoUI/Art/Buttons/plus_up.dds" or "EsoUI/Art/Buttons/minus_up.dds"
            DlcWindow.collapseBtn:SetNormalTexture(tex)
        end
        ShowDlcStatus()
    end
end

-- Fonction pour basculer le mode combat (Raccourci)
function DYN.ToggleCombatMode()
    savedVars.closeOnCombat = not savedVars.closeOnCombat
    if DlcWindow and DlcWindow.UpdateCombatButton then DlcWindow.UpdateCombatButton() end
end

-- Fonction pour basculer la fermeture auto Menus (Raccourci)
function DYN.ToggleSceneMode()
    savedVars.closeOnScenes = not savedVars.closeOnScenes
    if DlcWindow and DlcWindow.UpdateSceneButton then DlcWindow.UpdateSceneButton() end
end

-- Fonctions manquantes pour les raccourcis Halos
function DYN.ToggleHaloOwned()
    savedVars.showHaloOwned = not savedVars.showHaloOwned
    if DYN.Zone and DYN.Zone.RefreshMapPins then DYN.Zone.RefreshMapPins() end
    d("|cFFFF00[DlcYesNo]|r Halos (Possédés) : " .. (savedVars.showHaloOwned and "|c00FF00ON|r" or "|cFF0000OFF|r"))
end

function DYN.ToggleHaloMissing()
    savedVars.showHaloMissing = not savedVars.showHaloMissing
    if DYN.Zone and DYN.Zone.RefreshMapPins then DYN.Zone.RefreshMapPins() end
    d("|cFFFF00[DlcYesNo]|r Halos (Manquants) : " .. (savedVars.showHaloMissing and "|c00FF00ON|r" or "|cFF0000OFF|r"))
end

-- Initialisation de l'addon
local function OnAddOnLoaded(event, addonName)
    if addonName ~= AddonName then return end
    EVENT_MANAGER:UnregisterForEvent(AddonName, EVENT_ADD_ON_LOADED)
    
    -- Initialisation des variables sauvegardées (Coordonnées par défaut)
    local defaults = { 
        winLeft = 100, winTop = 100, 
        width = 550, height = 750, 
        opacity = 0.9,
        iconLeft = 200, 
        iconTop = 100,
        language = GetCVar("language.2") or "en",
        closeOnCombat = false,
        closeOnScenes = true,
        haloOpacity = 1, -- Opacité par défaut (100%)
        colorOwned = {0, 1, 0, 1}, -- Vert par défaut (si pas déjà défini)
        colorMissing = {1, 0, 0, 1}, -- Rouge par défaut
        colorBase = {0, 0.7, 1, 1}, -- Bleu Ciel pour les zones de base
        showHalos = true, -- Maître interrupteur (Oui d'origine)
        showHaloOwned = true,
        showHaloMissing = true,
        showHaloBase = true, -- Afficher les zones de base par défaut
        windowOpen = false,
    }
    
    -- GESTION DOUBLE SAUVEGARDE (Compte / Perso)
    DYN.AccVars = ZO_SavedVars:NewAccountWide("DlcYesNo_Vars", 1, nil, defaults)
    DYN.CharVars = ZO_SavedVars:New("DlcYesNo_Vars", 1, nil, defaults)
    
    -- Si la variable de choix n'existe pas, on met par défaut sur "Compte"
    if DYN.CharVars.useAccountWide == nil then DYN.CharVars.useAccountWide = true end
    
    -- Sélection des variables actives
    if DYN.CharVars.useAccountWide then
        savedVars = DYN.AccVars
    else
        savedVars = DYN.CharVars
    end
    DYN.SavedVars = savedVars -- Assure l'accès global pour Zone.lua

    -- CHARGEMENT DE LA LANGUE (Avant le menu pour les traductions)
    LoadLanguage(savedVars.language)

    -- MENU DE RÉGLAGES (LibAddonMenu)
    if LibAddonMenu2 then
        local panelData = {
            type = "panel",
            name = "DLC Yes No",
            displayName = "|cFFFF00DLC Yes No|r",
            author = "Takadol",
            version = "2.4",
            registerForRefresh = true,
        }
        
        local optionsTable = {
            {
                type = "header",
                name = T("SI_DYN_SETTINGS_HEADER_DATA"),
            },
            {
                type = "checkbox",
                name = T("SI_DYN_SETTINGS_USE_ACCOUNT"),
                tooltip = T("SI_DYN_SETTINGS_USE_ACCOUNT_TP"),
                getFunc = function() return DYN.CharVars.useAccountWide end,
                setFunc = function(value) 
                    DYN.CharVars.useAccountWide = value
                    ReloadUI()
                end,
                warning = T("SI_DYN_SETTINGS_RELOAD_WARN"),
            },
            {
                type = "button",
                name = T("SI_DYN_SETTINGS_RESET"),
                tooltip = T("SI_DYN_SETTINGS_RESET_TP"),
                func = function()
                    -- On réinitialise la table active avec les défauts
                    for k,v in pairs(defaults) do 
                        if type(v) == "table" then savedVars[k] = ZO_DeepTableCopy(v) else savedVars[k] = v end
                    end
                    -- On vide les tables spécifiques
                    savedVars.customZones = {}
                    savedVars.zoneConfig = {}
                    savedVars.exportData = nil
                    ReloadUI()
                end,
                warning = T("SI_DYN_SETTINGS_RESET_WARN"),
            },
            {
                type = "button",
                name = T("SI_DYN_SETTINGS_RESET_POSITIONS"),
                tooltip = T("SI_DYN_SETTINGS_RESET_POSITIONS_TP"),
                func = function()
                    savedVars.winLeft = 100; savedVars.winTop = 100
                    savedVars.iconLeft = 200; savedVars.iconTop = 100
                    if DlcWindow then
                        DlcWindow:ClearAnchors()
                        DlcWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 100, 100)
                    end
                    if DlcIcon then
                        DlcIcon:ClearAnchors()
                        DlcIcon:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 200, 100)
                    end
                end,
            },
            {
                type = "header",
                name = T("SI_DYN_SETTINGS_MAP_HEADER"),
            },
            {
                type = "checkbox",
                name = T("SI_DYN_SETTINGS_ENABLE_HALOS"),
                tooltip = T("SI_DYN_SETTINGS_SHOW_HALO_TP"),
                getFunc = function() return savedVars.showHalos end,
                setFunc = function(value) 
                    savedVars.showHalos = value
                    if DYN.Zone and DYN.Zone.RefreshMapPins then DYN.Zone.RefreshMapPins() end
                end,
                default = true,
            },
            {
                type = "slider",
                name = T("SI_DYN_SETTINGS_HALO_OPACITY"),
                min = 10, max = 100, step = 5,
                getFunc = function() return (savedVars.haloOpacity or 1) * 100 end,
                setFunc = function(value) 
                    savedVars.haloOpacity = value / 100
                    if DlcWindow and DlcWindow.haloOpLabel then DlcWindow.haloOpLabel:SetText(string.format("%d%%", value)) end
                    if DYN.Zone and DYN.Zone.RefreshMapPins then DYN.Zone.RefreshMapPins() end
                end,
                disabled = function() return not savedVars.showHalos end,
                default = 100,
            },
            {
                type = "slider",
                name = T("SI_DYN_SETTINGS_HALO_SIZE"),
                min = 20, max = 100, step = 5,
                getFunc = function() return savedVars.haloSize or 50 end,
                setFunc = function(value) 
                    savedVars.haloSize = value
                    if DlcWindow and DlcWindow.haloLabel then DlcWindow.haloLabel:SetText(string.format("%d", value)) end
                    if DYN.Zone and DYN.Zone.RefreshMapPins then DYN.Zone.RefreshMapPins() end
                end,
                disabled = function() return not savedVars.showHalos end,
                default = 50,
            },
            {
                type = "checkbox",
                name = T("SI_DYN_SETTINGS_SHOW_HALO_BASE"),
                tooltip = T("SI_DYN_SETTINGS_SHOW_HALO_BASE_TP"),
                getFunc = function() return savedVars.showHaloBase end,
                setFunc = function(value) 
                    savedVars.showHaloBase = value
                    if DYN.Zone and DYN.Zone.RefreshMapPins then DYN.Zone.RefreshMapPins() end
                end,
                disabled = function() return not savedVars.showHalos end, -- Grisé si halos désactivés
                default = true,
            },
            {
                type = "colorpicker",
                name = T("SI_DYN_SETTINGS_COLOR_BASE"),
                getFunc = function() return unpack(savedVars.colorBase) end,
                setFunc = function(r,g,b,a) savedVars.colorBase = {r,g,b,a}; if DYN.Zone and DYN.Zone.RefreshMapPins then DYN.Zone.RefreshMapPins() end end,
                disabled = function() return not (savedVars.showHalos and savedVars.showHaloBase) end,
            },
            {
                type = "checkbox",
                name = T("SI_DYN_SETTINGS_SHOW_HALO_OWNED"),
                tooltip = T("SI_DYN_SETTINGS_SHOW_HALO_OWNED_TP"),
                getFunc = function() return savedVars.showHaloOwned end,
                setFunc = function(value) savedVars.showHaloOwned = value; if DYN.Zone and DYN.Zone.RefreshMapPins then DYN.Zone.RefreshMapPins() end end,
                disabled = function() return not savedVars.showHalos end,
                default = true,
            },
            {
                type = "colorpicker",
                name = T("SI_DYN_SETTINGS_COLOR_OWNED"),
                getFunc = function() return unpack(savedVars.colorOwned) end,
                setFunc = function(r,g,b,a) savedVars.colorOwned = {r,g,b,a}; if DYN.Zone and DYN.Zone.RefreshMapPins then DYN.Zone.RefreshMapPins() end end,
                disabled = function() return not (savedVars.showHalos and savedVars.showHaloOwned) end,
            },
            {
                type = "checkbox",
                name = T("SI_DYN_SETTINGS_SHOW_HALO_MISSING"),
                tooltip = T("SI_DYN_SETTINGS_SHOW_HALO_MISSING_TP"),
                getFunc = function() return savedVars.showHaloMissing end,
                setFunc = function(value) savedVars.showHaloMissing = value; if DYN.Zone and DYN.Zone.RefreshMapPins then DYN.Zone.RefreshMapPins() end end,
                disabled = function() return not savedVars.showHalos end,
                default = true,
            },
            {
                type = "colorpicker",
                name = T("SI_DYN_SETTINGS_COLOR_MISSING"),
                getFunc = function() return unpack(savedVars.colorMissing) end,
                setFunc = function(r,g,b,a) savedVars.colorMissing = {r,g,b,a}; if DYN.Zone and DYN.Zone.RefreshMapPins then DYN.Zone.RefreshMapPins() end end,
                disabled = function() return not (savedVars.showHalos and savedVars.showHaloMissing) end,
            },
        }
        
        LibAddonMenu2:RegisterAddonPanel("DlcYesNoOptions", panelData)
        LibAddonMenu2:RegisterOptionControls("DlcYesNoOptions", optionsTable)
    end

    -- Enregistrement de la commande slash
    SLASH_COMMANDS["/dlcyesno"] = ShowDlcStatus

    -- Auto-Mise à jour à l'achat d'un DLC
    EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_COLLECTIBLE_UPDATED, function()
        isCacheDirty = true -- Invalide le cache
        if DlcWindow and not DlcWindow:IsHidden() then
            ShowDlcStatus()
        end
    end)

    -- Gestion du combat via le module externe
    DYN.Combat:Initialize(savedVars, ShowDlcStatus, HideWindowForCombat)
    
    -- Gestion Visibilité Stricte (HUD + Carte uniquement)
    local allowedScenes = { hud=true, hudui=true }
    local wasHiddenByScene = false

    SCENE_MANAGER:RegisterCallback("SceneStateChanged", function(scene, oldState, newState)
        if newState == SCENE_SHOWING then
            local sceneName = scene:GetName()
            
            local isAllowed = allowedScenes[sceneName]
            -- La carte est autorisée uniquement si l'option est active
            if sceneName == "worldMap" and savedVars.closeOnScenes then isAllowed = true end
            
            if isAllowed then
                -- On arrive sur une scène autorisée (Jeu ou Carte)
                if DlcIcon and DlcIcon:IsHidden() then DlcIcon:SetHidden(false) end

                if wasHiddenByScene then
                    if DlcWindow and DlcWindow:IsHidden() and savedVars.windowOpen then
                        DlcWindow:SetHidden(false)
                    end
                    wasHiddenByScene = false -- Reset
                end
            else
                -- On arrive sur une scène interdite (Menu, Inventaire, etc.)
                if DlcIcon and not DlcIcon:IsHidden() then DlcIcon:SetHidden(true) end

                if DlcWindow and not DlcWindow:IsHidden() then
                    DlcWindow:SetHidden(true)
                    wasHiddenByScene = true
                end
            end
        end
    end)

    -- Initialisation du module Zone (Halos sur la carte)
    if DYN.Zone and DYN.Zone.Initialize then
        DYN.Zone.Initialize()
    end

    -- Création de l'icône au démarrage
    CreateIcon()

    -- Restauration de l'état de la fenêtre
    if savedVars.windowOpen then
        ShowDlcStatus()
    end

    d(T("SI_DYN_LOAD_MESSAGE"))
end

EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
