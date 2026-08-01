DYN = DYN or {}
DYN.Zone = DYN.Zone or {}
local Zone = DYN.Zone

-- Constantes
local PIN_TYPE_OWNED = "DlcYesNoHaloOwned"
local PIN_TYPE_MISSING = "DlcYesNoHaloMissing"
local PIN_TYPE_BASE = "DlcYesNoHaloBase"
local TAMRIEL_MAP_INDEX = 1
local ALIGN_CENTER = 1 -- Fallback

-- Mettez cette ligne à 'true' pour formater tous les variables.
-- Par défaut à 'false', pour sécuriser les variables.
local ALLOW_EDIT_ACCESS = false

-- Variables locales
local editMode = false
local lockedMode = false 
local editorControls = {}
local btnCreate, btnErase, btnEdit, btnValidate, btnExport, btnBiz, btnLock, btnRescue, btnBasePlus
local wm = WINDOW_MANAGER
local cachedPins = { base = {}, owned = {}, missing = {} }
local isPinCacheDirty = true

function Zone.IsEditMode()
    return editMode
end

-- === Gestion des Données ===

local function GetZoneConfig(id)
    if DYN and DYN.SavedVars and DYN.SavedVars.zoneConfig and DYN.SavedVars.zoneConfig[id] then
        return DYN.SavedVars.zoneConfig[id]
    end
    return nil
end

local function SaveZoneConfig(id, x, y, size)
    if not DYN.SavedVars.zoneConfig then DYN.SavedVars.zoneConfig = {} end
    
    -- Récupération de la référence par défaut (DataHalos)
    local defaults = (DYN.Zone and DYN.Zone.DlcCoords and DYN.Zone.DlcCoords[id])
    
    if not DYN.SavedVars.zoneConfig[id] then DYN.SavedVars.zoneConfig[id] = {} end
    local entry = DYN.SavedVars.zoneConfig[id]
    
    -- Mise à jour des valeurs locales
    if x then entry.x = x end
    if y then entry.y = y end
    if size then entry.size = size end
    
    -- OPTIMISATION : Suppression des valeurs identiques à DataHalos
    if defaults then
        local defX, defY = defaults[1], defaults[2]
        local defSize = defaults[4] or 1.0
        local epsilon = 0.0001 -- Tolérance pour les nombres à virgule
        
        if entry.x and math.abs(entry.x - defX) < epsilon then entry.x = nil end
        if entry.y and math.abs(entry.y - defY) < epsilon then entry.y = nil end
        if entry.size and math.abs(entry.size - defSize) < epsilon then entry.size = nil end
    end
    
    -- Si l'entrée est vide (plus de surcharge), on la supprime totalement pour gagner de la place
    local isEmpty = true
    for k, v in pairs(entry) do
        if v ~= nil then isEmpty = false break end
    end
    
    if isEmpty then
        DYN.SavedVars.zoneConfig[id] = nil
    end
end

local function GetHaloName(id, isCustom)
    -- 1. Nom personnalisé (priorité la plus haute)
    if isCustom and DYN.SavedVars.customZones[id] and DYN.SavedVars.customZones[id].customName then
        return DYN.SavedVars.customZones[id].customName
    elseif not isCustom and DYN.SavedVars.zoneConfig[id] and DYN.SavedVars.zoneConfig[id].customName then
        return DYN.SavedVars.zoneConfig[id].customName
    end

    -- 2. Nom "en dur" dans DataHalos.lua (pour les zones de base ET les DLCs)
    if not isCustom then
        local coords = (DYN.Zone and DYN.Zone.DlcCoords) or {}
        if coords[id] and coords[id][3] then
            local nameData = coords[id][3]
            if type(nameData) == "table" then
                -- Gestion Multilingue
                local lang = (DYN.SavedVars and DYN.SavedVars.language) or "en"
                return nameData[lang] or nameData["en"] or "?"
            else
                return nameData -- Rétro-compatibilité (String simple)
            end
        end
    end

    -- 3. Nom via l'API du jeu (si aucun nom n'a été trouvé avant)
    local checkId = id
    if not isCustom then
        local conf = GetZoneConfig(id)
        if conf and conf.collectibleId then checkId = conf.collectibleId end
        if type(id) == "string" and DYN.Zone.DlcCoords[id] and DYN.Zone.DlcCoords[id][6] then checkId = DYN.Zone.DlcCoords[id][6] end
    elseif DYN.SavedVars.customZones[id] then
        checkId = DYN.SavedVars.customZones[id].collectibleId or 0
    end

    if type(checkId) == "number" and checkId > 0 and GetCollectibleInfo then
        local cName = GetCollectibleInfo(checkId)
        return cName or ("ID: " .. tostring(checkId))
    end
    
    return isCustom and "Nouvelle Zone" or "Zone Inconnue"
end

local function CheckIfPlayerHere(id, isCustom, playerZone)
    local zName = GetHaloName(id, isCustom)
    return (zName == playerZone)
end

-- === Mode Édition ===

local function EnableEditMode()
    local currentMapIndex = GetCurrentMapIndex() or 0
    local mapWidth, mapHeight = ZO_WorldMapContainer:GetDimensions()
    local coords = (DYN.Zone and DYN.Zone.DlcCoords) or {}
    local playerZoneName = GetUnitZone("player") -- Pour gérer le grossissement si on est sur place
    
    local drawnIds = {} -- SUIVI ANTI-DOUBLON POUR LE MODE ÉDITION
    
    -- 1. Standards (DLC & Base)
    for key, data in pairs(coords) do
        -- Récupération de l'ID réel (soit la clé, soit le 6ème paramètre si c'est un doublon spécial)
        local collectibleId = (type(key) == "number") and key or data[6]
        -- Si pas d'ID en param 6 pour une clé string, on utilise 0 (sécurité)
        if not collectibleId and type(key) == "string" then collectibleId = 0 end
        
        -- Support Multi-Cartes : data[5] est mapIndex. Défaut = 1 (Tamriel)
        local targetMap = data[5] or TAMRIEL_MAP_INDEX
        
        if currentMapIndex == targetMap then
            -- Sécurité : On ignore les clés non numériques (mauvais format dans DataHalos)
            -- MODIF: On accepte les nombres ET les cas spéciaux résolus ci-dessus
            if type(collectibleId) == "number" then
                -- On utilise la 'key' (unique) pour la config, pas le collectibleId (partagé)
                local conf = GetZoneConfig(key)
                if not (conf and conf.hidden) then
                local posX = (conf and conf.x) or data[1]
                local posY = (conf and conf.y) or data[2]
                local scale = (conf and conf.size) or data[4] or 1.0
                
                local owned = false
                if collectibleId < 0 then
                    owned = true
                else
                    local checkId = (conf and conf.collectibleId) or collectibleId
                    if type(checkId) == "number" and checkId > 0 and GetCollectibleInfo then
                        local _, _, _, _, isOwned = GetCollectibleInfo(checkId)
                        owned = isOwned
                    end
                end

                -- Choix de la texture : Base (Gratuit), Possédé (Vert), Manquant (Rouge)
                local texture
                if collectibleId < 0 then
                    texture = "DlcYesNo/Textures/zonefree.dds"
                else
                    texture = owned and "DlcYesNo/Textures/zoneok.dds" or "DlcYesNo/Textures/zoneoff.dds"
                end
                
                local baseSize = DYN.SavedVars.haloSize or 50
                local finalSize = baseSize * scale
                
                if CheckIfPlayerHere(key, false, playerZoneName) then finalSize = finalSize * 1.5 end

                -- On passe 'key' à CreateEditControl pour que l'éditeur sauvegarde sur la bonne entrée
                Zone.CreateEditControl(key, posX, posY, finalSize, texture, scale, baseSize, mapWidth, mapHeight, false)
                drawnIds[collectibleId] = true -- On note que cet ID de collection est déjà traité
                end
            end
        end
    end

    -- 2. Custom
    if DYN.SavedVars.customZones then
        for id, data in pairs(DYN.SavedVars.customZones) do
            local zoneMapIndex = data.mapIndex or TAMRIEL_MAP_INDEX
            if zoneMapIndex == currentMapIndex then
                local checkId = data.collectibleId or 0
                
                -- ANTI-DOUBLON : Si cet ID (ex: -1 pour Glénumbrie) est déjà affiché par la liste officielle, on ne l'affiche pas en double via Custom
                if not (checkId ~= 0 and drawnIds[checkId]) then
                    -- Choix de la texture (Support Zone de Base en mode Édition)
                    local texture
                    if checkId < 0 then
                        texture = "DlcYesNo/Textures/zonefree.dds"
                    else
                        texture = (data.type == "owned") and "DlcYesNo/Textures/zoneok.dds" or "DlcYesNo/Textures/zoneoff.dds"
                    end
                    
                    local baseSize = DYN.SavedVars.haloSize or 50
                    local scale = data.size or 1.0
                    local finalSize = baseSize * scale
                    
                    if CheckIfPlayerHere(id, true, playerZoneName) then finalSize = finalSize * 1.5 end
                    
                    Zone.CreateEditControl(id, data.x, data.y, finalSize, texture, scale, baseSize, mapWidth, mapHeight, true)
                end
            end
        end
    end

    if btnCreate then btnCreate:SetHidden(false) end
    if btnBasePlus then btnBasePlus:SetHidden(false) end
    if btnErase then btnErase:SetHidden(false) end
    if btnValidate then btnValidate:SetHidden(false) end
    if btnBiz then btnBiz:SetHidden(false) end
    if btnExport then btnExport:SetHidden(false) end
    if btnLock then btnLock:SetHidden(false) end
    if btnRescue then btnRescue:SetHidden(false) end
end

function Zone.UpdateEditPositions()
    local mapWidth, mapHeight = ZO_WorldMapContainer:GetDimensions()
    for id, ctrl in pairs(editorControls) do
        if not ctrl:IsHidden() and ctrl.normalizedX and ctrl.normalizedY then
            ctrl:ClearAnchors() -- IMPORTANT : Nettoie les anciennes positions pour éviter les déformations/miroirs
            ctrl:SetAnchor(CENTER, ZO_WorldMapContainer, TOPLEFT, ctrl.normalizedX * mapWidth, ctrl.normalizedY * mapHeight)
        end
    end
end

function Zone.CreateEditControl(id, posX, posY, finalSize, texture, scale, baseSize, mapWidth, mapHeight, isCustom)
    local ctrlName = "DYN_EditCtrl_v7_" .. tostring(id) 
    local ctrl = wm:GetControlByName(ctrlName)
    if not ctrl then
        ctrl = wm:CreateControl(ctrlName, ZO_WorldMapContainer, CT_CONTROL)
    end
    
    ctrl:SetDimensions(finalSize, finalSize)
    ctrl:SetHidden(false)
    -- Stockage des coordonnées normalisées pour la mise à jour lors du zoom
    ctrl.normalizedX = posX
    ctrl.normalizedY = posY
    ctrl:ClearAnchors()
    ctrl:SetAnchor(CENTER, ZO_WorldMapContainer, TOPLEFT, posX * mapWidth, posY * mapHeight)
    
    -- Fond
    local bg = ctrl:GetNamedChild("Bg")
    if not bg then bg = wm:CreateControl("$(parent)Bg", ctrl, CT_TEXTURE) end
    bg:SetTexture(texture)
    bg:SetAnchorFill()
    bg:SetAlpha(0.8)
    
    -- Bordure
    local border = ctrl:GetNamedChild("Border")
    if not border then border = wm:CreateControl("$(parent)Border", ctrl, CT_BACKDROP) end
    border:SetAnchorFill()
    border:SetEdgeColor(1, 1, 0, 1) -- Jaune
    border:SetCenterColor(0, 0, 0, 0)
    border:SetEdgeTexture("", 1, 1, 0)
    
    -- Bouton Supprimer (-)
    local closeBtn = ctrl:GetNamedChild("DelBtn")
    if not closeBtn then closeBtn = wm:CreateControl("$(parent)DelBtn", ctrl, CT_BUTTON) end
    closeBtn:SetDimensions(16, 16)
    closeBtn:SetAnchor(TOPRIGHT, ctrl, TOPRIGHT, 5, -5)
    closeBtn:SetNormalTexture("EsoUI/Art/Buttons/minus_up.dds")
    closeBtn:SetHandler("OnClicked", function()
        if isCustom then
            DYN.SavedVars.customZones[id] = nil
        else
            if not DYN.SavedVars.zoneConfig[id] then DYN.SavedVars.zoneConfig[id] = {} end
            DYN.SavedVars.zoneConfig[id].hidden = true
        end
        ctrl:SetHidden(true)
    end)

    -- Info Box (ID / Nom)
    local infoBg = ctrl:GetNamedChild("InfoBg")
    if not infoBg then
        infoBg = wm:CreateControl("$(parent)InfoBg", ctrl, CT_BACKDROP)
        infoBg:SetEdgeTexture("", 1, 1, 0)
    end
    infoBg:SetDimensions(140, 24)
    infoBg:SetAnchor(BOTTOM, ctrl, TOP, 0, -2)

    local idBox = infoBg:GetNamedChild("Input")
    if not idBox then
        idBox = wm:CreateControl("$(parent)Input", infoBg, CT_EDITBOX)
        idBox:SetAnchorFill()
        idBox:SetFont("ZoFontGameSmall")
        idBox:SetColor(1, 1, 1, 1)
        if idBox.SetHorizontalAlignment then idBox:SetHorizontalAlignment(ALIGN_CENTER) end
    end

    local function GetId()
        if isCustom then 
            return (DYN.SavedVars.customZones[id] and DYN.SavedVars.customZones[id].collectibleId) or 0
        else 
            local val = (DYN.SavedVars.zoneConfig[id] and DYN.SavedVars.zoneConfig[id].collectibleId)
            if val then return val end
            
            if type(id) == "number" then return id end
            -- Gestion des clés textuelles (Doublons) : On renvoie l'ID réel (param 6) ou 0
            if type(id) == "string" and DYN.Zone.DlcCoords[id] then return DYN.Zone.DlcCoords[id][6] or 0 end
            return 0 
        end
    end

    local function UpdateDisplay(forceId)
        local val = GetId()
        local hasId = (val and val ~= 0)
        
        if hasId then
            infoBg:SetCenterColor(0, 0, 0, 0.5)
            infoBg:SetEdgeColor(0.6, 0.6, 0.6, 0.8)
        else
            infoBg:SetCenterColor(0, 0, 0, 1)
            infoBg:SetEdgeColor(1, 0, 0, 1)
        end

        -- Correction : On affiche le Nom par défaut, même si l'ID est manquant (cadre rouge)
        if idBox:HasFocus() or forceId then
            if not hasId then idBox:SetText("") else idBox:SetText(tostring(val)) end
            idBox:SetTextType(TEXT_TYPE_NUMERIC)
        else
            idBox:SetTextType(TEXT_TYPE_ALL)
            idBox:SetText(GetHaloName(id, isCustom))
        end
    end

    idBox:SetHandler("OnTextChanged", function(self)
        if not self:HasFocus() then return end
        local val = tonumber(self:GetText()) or 0
        if isCustom and DYN.SavedVars.customZones[id] then
            DYN.SavedVars.customZones[id].collectibleId = val
        elseif not isCustom then
            if not DYN.SavedVars.zoneConfig[id] then DYN.SavedVars.zoneConfig[id] = {} end
            DYN.SavedVars.zoneConfig[id].collectibleId = val
        end
    end)

    idBox:SetHandler("OnFocusGained", function() UpdateDisplay(true) end)
    idBox:SetHandler("OnFocusLost", function() UpdateDisplay(false) end)
    UpdateDisplay(false)
    
    ctrl:SetMouseEnabled(true)
    ctrl:SetMovable(not lockedMode) -- Respecte le verrouillage (ne bouge pas si lockedMode est vrai)
    ctrl:SetClampedToScreen(false) -- Le halo doit suivre la carte et sortir de l'écran si on glisse la map
    
    ctrl:SetHandler("OnMoveStop", function(self)
        local cX, cY = self:GetCenter()
        local l, t = ZO_WorldMapContainer:GetLeft(), ZO_WorldMapContainer:GetTop()
        local w, h = ZO_WorldMapContainer:GetDimensions()
        local nX = (cX - l) / w
        local nY = (cY - t) / h
        self.normalizedX = nX
        self.normalizedY = nY
        if isCustom then
            if DYN.SavedVars.customZones[id] then
                DYN.SavedVars.customZones[id].x = nX
                DYN.SavedVars.customZones[id].y = nY
            end
        else SaveZoneConfig(id, nX, nY, nil) end
    end)
    
    ctrl:SetHandler("OnMouseWheel", function(self, delta)
        local nScale = scale + (delta * 0.1)
        if nScale < 0.5 then nScale = 0.5 end
        if nScale > 3.0 then nScale = 3.0 end
        scale = nScale
        self:SetDimensions(baseSize * scale, baseSize * scale)
        if isCustom then
            if DYN.SavedVars.customZones[id] then DYN.SavedVars.customZones[id].size = scale end
        else SaveZoneConfig(id, nil, nil, scale) end
    end)
    
    ctrl:SetHandler("OnMouseUp", function(self, button, upInside)
        if button == MOUSE_BUTTON_INDEX_RIGHT and upInside then
            ClearMenu()
            AddCustomMenuItem("Renommer", function()
                ZO_Dialogs_ShowDialog("DYN_RENAME_ZONE", {id=id, isCustom=isCustom, current=GetHaloName(id, isCustom)})
            end)
            AddCustomMenuItem("Changer ID", function()
                ZO_Dialogs_ShowDialog("DYN_CHANGE_ID", {id=id, isCustom=isCustom, current=GetId()})
            end)
            AddCustomMenuItem("Réinitialiser Position", function()
                if not isCustom then SaveZoneConfig(id, nil, nil, 1.0) end
                DisableEditMode() EnableEditMode()
            end)
            ShowMenu(self)
        end
    end)
    
    ctrl:SetHandler("OnMouseEnter", function(self)
        InitializeTooltip(InformationTooltip, self, RIGHT, 0, 0)
        InformationTooltip:AddLine("Édition Halo", "ZoFontHeader2")
        
        -- --- DEBUG INFO AJOUTÉE ---
        local cId = GetId()
        local rawName = ""
        if cId and type(cId) == "number" and cId > 0 and GetCollectibleInfo then
            rawName = GetCollectibleInfo(cId)
        end
        if not rawName or rawName == "" then rawName = "N/A" end
        rawName = zo_strformat("<<1>>", rawName)

        InformationTooltip:AddLine(string.format("ID Interne: |cFFFFFF%s|r", tostring(id)), "ZoFontGame")
        InformationTooltip:AddLine(string.format("Collectible ID: |cFFFFFF%s|r", tostring(cId)), "ZoFontGame")
        InformationTooltip:AddLine(string.format("Nom API: |cFFFF00%s|r", rawName), "ZoFontGame")
        -- --------------------------

        InformationTooltip:AddLine("----------------", "ZoFontGame")
        
        -- Indication d'état Verrouillé/Déverrouillé
        if lockedMode then
            InformationTooltip:AddLine("|cFF0000VERROUILLÉ (Cadenas)|r", "ZoFontGameBold")
            InformationTooltip:AddLine("Déverrouillez pour déplacer.", "ZoFontGame")
        else
            InformationTooltip:AddLine("|c00FF00Glisser: Déplacer|r", "ZoFontGame")
        end

        InformationTooltip:AddLine("Molette: Taille", "ZoFontGame")
        InformationTooltip:AddLine("Clic Droit: Menu/Renommer", "ZoFontGame")
        InformationTooltip:AddLine("Clic '-' : Supprimer", "|cFF0000")
    end)
    ctrl:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)

    editorControls[id] = ctrl
end

local function DisableEditMode()
    for id, ctrl in pairs(editorControls) do
        ctrl:SetHidden(true)
        ctrl:SetMouseEnabled(false) 
    end
    if btnCreate then btnCreate:SetHidden(true) end
    if btnBasePlus then btnBasePlus:SetHidden(true) end
    if btnErase then btnErase:SetHidden(true) end
    if btnValidate then btnValidate:SetHidden(true) end
    if btnBiz then btnBiz:SetHidden(true) end
    if btnExport then btnExport:SetHidden(true) end
    if btnLock then btnLock:SetHidden(true) end
    if btnRescue then btnRescue:SetHidden(true) end
end

-- === Affichage Normal ===

-- Reconstruit les listes de pins pour éviter les calculs à chaque frame d'affichage
local function RebuildPinCache()
    cachedPins = { base = {}, owned = {}, missing = {} }
    local currentMapIndex = GetCurrentMapIndex() or 0
    local coords = (DYN.Zone and DYN.Zone.DlcCoords) or {}
    local playerZoneName = GetUnitZone("player")

    local drawnIds = {} -- SUIVI : Pour éviter les doublons (Base vs Custom)

    for key, data in pairs(coords) do
        local collectibleId = (type(key) == "number") and key or data[6]
        if not collectibleId and type(key) == "string" then collectibleId = 0 end
        
        local targetMap = data[5] or TAMRIEL_MAP_INDEX
        
        if currentMapIndex == targetMap then
            if type(collectibleId) == "number" and data and data[1] and data[2] then
                -- Utiliser la clé unique pour la config
                local conf = GetZoneConfig(key)
                
                local owned = false
                local checkId = collectibleId
                if conf and conf.collectibleId then checkId = conf.collectibleId end
                
                if collectibleId < 0 then
                    owned = true
                elseif checkId > 0 and GetCollectibleInfo then
                    local _, _, _, _, isO = GetCollectibleInfo(checkId)
                    owned = isO
                end

                local isBase = (collectibleId < 0)

                -- Logique de tri des pins (Base / Owned / Missing)
                if isBase then
                    table.insert(cachedPins.base, {key, data, conf, true, true})
                elseif owned then
                    table.insert(cachedPins.owned, {key, data, conf, true, false})
                else
                    table.insert(cachedPins.missing, {key, data, conf, false, false})
                end
                    drawnIds[collectibleId] = true -- On note que cet ID a été dessiné
            end
        end
    end

    -- Les Zones Custom : Traitement de tous les modes (Base/Owned/Missing)
    if DYN.SavedVars.customZones then
        for id, data in pairs(DYN.SavedVars.customZones) do
            local zoneMapIndex = data.mapIndex or TAMRIEL_MAP_INDEX
            if zoneMapIndex == currentMapIndex then
                local checkId = data.collectibleId or 0
                local isBase = (checkId < 0) -- Si ID négatif, c'est une zone de base (Bleue)

                local owned = (data.type == "owned") or isBase -- Base est toujours Owned
                
                -- Vérification API si c'est un DLC positif
                local checkId = data.collectibleId or 0
                if checkId > 0 and GetCollectibleInfo then
                    local _, _, _, _, isO = GetCollectibleInfo(checkId)
                    if owned and not isO then owned = false end
                    if not owned and isO then owned = true end
                end
                
                -- Filtrage selon le mode d'affichage demandé
                -- ANTI-DOUBLON : Si c'est une zone de base (négative) et qu'elle a DÉJÀ été dessinée
                -- par la boucle précédente (DlcCoords), on ne l'affiche pas en double via Custom.
                local skip = (isBase and drawnIds[checkId])
                
                if not skip then
                    -- id, data, conf (data fait office de conf), owned, isBase, isCustom
                    if isBase then
                        table.insert(cachedPins.base, {id, data, data, owned, true, true})
                    elseif owned then
                        table.insert(cachedPins.owned, {id, data, data, owned, false, true})
                    else
                        table.insert(cachedPins.missing, {id, data, data, owned, false, true})
                    end
                end
            end
        end
    end
    isPinCacheDirty = false
end

local function MapPinLayout(pinManager, pinMode)
    if editMode then return end
    if isPinCacheDirty then RebuildPinCache() end

    local list
    local targetPinType

    if pinMode == "base" then
        list = cachedPins.base
        targetPinType = _G[PIN_TYPE_BASE]
    elseif pinMode == true then
        list = cachedPins.owned
        targetPinType = _G[PIN_TYPE_OWNED]
    else
        list = cachedPins.missing
        targetPinType = _G[PIN_TYPE_MISSING]
    end

    local playerZoneName = GetUnitZone("player")

    for _, p in ipairs(list) do
        local key, data, conf, owned, isBase, isCustom = unpack(p)
        
        if not (conf and conf.hidden) then
            local scale = (conf and conf.size) or data[4] or 1.0
            local x = (conf and conf.x) or data[1]
            local y = (conf and conf.y) or data[2]
            
            local isHere = CheckIfPlayerHere(key, isCustom, playerZoneName)
            
            -- Construction du Tag (Léger)
            local pinTag = {
                id = key, 
                isCustom = isCustom, 
                isHere = isHere, 
                scale = scale, 
                isOwned = owned, 
                isBase = isBase
            }
            
            pinManager:CreatePin(targetPinType, pinTag, x, y)
        end
    end
end

-- Créateur de Pin (Visuel, Animation, Taille) - Ne gère plus le texte
local function PinCreator(pin)
    -- Sécurité renforcée : On vérifie que 'pin' est un objet valide avec les méthodes requises
    if not pin or not pin.SetMouseEnabled or not pin.SetHandler then return end
    
    -- 1. CLIQUE ET AFFICHAGE (Le plus important !)
    -- On force le halo à être AU-DESSUS de la carte pour capter la souris
    if pin.SetDrawLayer then pin:SetDrawLayer(DL_CONTROLS) end -- Au niveau des contrôles (boutons), pas du fond de carte
    if pin.SetDrawTier then pin:SetDrawTier(DT_HIGH) end       -- Priorité haute
    
    -- 2. INTERACTION
    -- FORCE BRUTE (Méthode Mode Édition) : On définit nos propres gestionnaires.
    pin:SetMouseEnabled(true)
    
    pin:SetHandler("OnMouseEnter", function(self)
        -- Animation au survol (Agrandissement)
        local currentTag = self:GetPinTag()
        local baseScale = (currentTag and currentTag.scale) or 1.0
        if self.SetScale then self:SetScale(baseScale * 1.2) end
    end)
    pin:SetHandler("OnMouseExit", function(self)
        local currentTag = self:GetPinTag()
        local baseScale = (currentTag and currentTag.scale) or 1.0
        if self.SetScale then self:SetScale(baseScale) end
    end)
end

function Zone.RefreshMapPins()
    if editMode then return end
    
    -- Invalider le cache pour forcer un nouveau calcul des positions/états
    isPinCacheDirty = true
    
    local sv = DYN.SavedVars
    
    -- Vérification du Maître Interrupteur
    if not sv.showHalos then
        ZO_WorldMap_SetCustomPinEnabled(_G[PIN_TYPE_OWNED], false)
        ZO_WorldMap_SetCustomPinEnabled(_G[PIN_TYPE_MISSING], false)
        ZO_WorldMap_SetCustomPinEnabled(_G[PIN_TYPE_BASE], false)
        ZO_WorldMap_RefreshCustomPinsOfType(_G[PIN_TYPE_OWNED])
        ZO_WorldMap_RefreshCustomPinsOfType(_G[PIN_TYPE_MISSING])
        ZO_WorldMap_RefreshCustomPinsOfType(_G[PIN_TYPE_BASE])
        if DYN.UpdateMapBtns then DYN.UpdateMapBtns() end
        return
    end
    
    local opacity = sv.haloOpacity or 1
    
    if sv.showHaloOwned then
        ZO_WorldMap_SetCustomPinEnabled(_G[PIN_TYPE_OWNED], true)
        if ZO_MapPin.PIN_DATA[_G[PIN_TYPE_OWNED]] then
            local r, g, b = unpack(sv.colorOwned)
            ZO_MapPin.PIN_DATA[_G[PIN_TYPE_OWNED]].tint = ZO_ColorDef:New(r, g, b, opacity)
            ZO_MapPin.PIN_DATA[_G[PIN_TYPE_OWNED]].size = sv.haloSize or 50
        end
    else ZO_WorldMap_SetCustomPinEnabled(_G[PIN_TYPE_OWNED], false) end
    ZO_WorldMap_RefreshCustomPinsOfType(_G[PIN_TYPE_OWNED])
    
    -- Logique Séparée pour les Zones de Base
    if sv.showHaloBase then
        ZO_WorldMap_SetCustomPinEnabled(_G[PIN_TYPE_BASE], true)
        if ZO_MapPin.PIN_DATA[_G[PIN_TYPE_BASE]] then
            -- Applique la couleur définie dans colorBase
            local r, g, b = unpack(sv.colorBase or {1, 1, 1, 1})
            ZO_MapPin.PIN_DATA[_G[PIN_TYPE_BASE]].tint = ZO_ColorDef:New(r, g, b, opacity)
            ZO_MapPin.PIN_DATA[_G[PIN_TYPE_BASE]].size = sv.haloSize or 50
        end
    else ZO_WorldMap_SetCustomPinEnabled(_G[PIN_TYPE_BASE], false) end
    ZO_WorldMap_RefreshCustomPinsOfType(_G[PIN_TYPE_BASE])

    if sv.showHaloMissing then
        ZO_WorldMap_SetCustomPinEnabled(_G[PIN_TYPE_MISSING], true)
        if ZO_MapPin.PIN_DATA[_G[PIN_TYPE_MISSING]] then
            local r, g, b = unpack(sv.colorMissing)
            ZO_MapPin.PIN_DATA[_G[PIN_TYPE_MISSING]].tint = ZO_ColorDef:New(r, g, b, opacity)
            ZO_MapPin.PIN_DATA[_G[PIN_TYPE_MISSING]].size = sv.haloSize or 50
        end
    else ZO_WorldMap_SetCustomPinEnabled(_G[PIN_TYPE_MISSING], false) end
    ZO_WorldMap_RefreshCustomPinsOfType(_G[PIN_TYPE_MISSING])
    
    if DYN.UpdateMapBtns then DYN.UpdateMapBtns() end
end

function Zone.OnMapChanged()
    if editMode then DisableEditMode() EnableEditMode() end
    isPinCacheDirty = true -- La carte change, les coords relatives (mapIndex) peuvent changer
end

function Zone.CheckChanges()
    local changes = 0
    local customCount = 0
    local modCount = 0
    
    d("--- |cFFFF00[DlcYesNo]|r Vérification des changements ---")

    -- 1. Vérifier les modifications (ZoneConfig vs DataHalos)
    local baseCoords = (DYN.Zone and DYN.Zone.DlcCoords) or {}
    if DYN.SavedVars.zoneConfig then
        for id, conf in pairs(DYN.SavedVars.zoneConfig) do
            local base = baseCoords[id]
            if base then
                local isDiff = false
                -- On compare avec une petite tolérance pour les flottants
                if conf.x and math.abs(conf.x - base[1]) > 0.0001 then isDiff = true end
                if conf.y and math.abs(conf.y - base[2]) > 0.0001 then isDiff = true end
                if conf.size and math.abs(conf.size - (base[4] or 1.0)) > 0.001 then isDiff = true end
                
                if isDiff then
                    changes = changes + 1
                    modCount = modCount + 1
                end
            end
        end
    end

    -- 2. Vérifier les créations (CustomZones)
    if DYN.SavedVars.customZones then
        for _ in pairs(DYN.SavedVars.customZones) do
            changes = changes + 1
            customCount = customCount + 1
        end
    end

    if changes == 0 then
        d("|c00FF00Tout est synchronisé !|r Aucune différence avec DataHalos.lua.")
    else
        d(string.format("Il y a |cFF0000%d changements|r non durcis :", changes))
        if modCount > 0 then d(string.format("- %d modifications de zones existantes", modCount)) end
        if customCount > 0 then d(string.format("- %d nouvelles zones (Custom)", customCount)) end
        d("Faites |cFFFF00/dlcexport|r pour récupérer le code à jour.")
    end
end

function Zone.Initialize()
    local sv = DYN.SavedVars
    if not sv.zoneConfig then sv.zoneConfig = {} end
    if not sv.customZones then sv.customZones = {} end
    
    -- Initialisation des nouvelles variables si elles n'existent pas
    if sv.showHaloBase == nil then sv.showHaloBase = true end
    if sv.showHalos == nil then sv.showHalos = true end
    if not sv.colorBase then sv.colorBase = {0, 0.7, 1, 1} end -- Bleu par défaut

    -- Dialogues
    ESO_Dialogs["DYN_RENAME_ZONE"] = {
        title = { text = "Renommer Halo" },
        mainText = { text = "Entrez un nom personnalisé pour cette zone :" },
        editBox = { defaultText = "Nom de la zone...", textType = TEXT_TYPE_ALL },
        buttons = {
            { text = "Valider", callback = function(dialog)
                local text = ZO_Dialogs_GetEditBoxText(dialog)
                local id = dialog.data.id
                if dialog.data.isCustom then
                    if DYN.SavedVars.customZones[id] then DYN.SavedVars.customZones[id].customName = text end
                else
                    if not DYN.SavedVars.zoneConfig[id] then DYN.SavedVars.zoneConfig[id] = {} end
                    DYN.SavedVars.zoneConfig[id].customName = text
                end
                if editMode then DisableEditMode() EnableEditMode() end
            end },
            { text = "Annuler" }
        }
    }

    ESO_Dialogs["DYN_CHANGE_ID"] = {
        title = { text = "Changer ID (Collectible)" },
        mainText = { text = "Entrez l'ID du Collectible (ou 0 pour inconnu) :" },
        editBox = { defaultText = "0", textType = TEXT_TYPE_NUMERIC },
        setup = function(dialog, data)
            local edit = dialog:GetNamedChild("EditBox")
            if edit and data and data.current then
                edit:SetText(tostring(data.current))
                edit:SelectAll()
            end
        end,
        buttons = {
            { text = "Valider", callback = function(dialog)
                local text = ZO_Dialogs_GetEditBoxText(dialog)
                local val = tonumber(text) or 0
                local id = dialog.data.id
                if dialog.data.isCustom then
                    if DYN.SavedVars.customZones[id] then DYN.SavedVars.customZones[id].collectibleId = val end
                else
                    if not DYN.SavedVars.zoneConfig[id] then DYN.SavedVars.zoneConfig[id] = {} end
                    DYN.SavedVars.zoneConfig[id].collectibleId = val
                end
                if editMode then DisableEditMode() EnableEditMode() end
            end },
            { text = "Annuler" }
        }
    }

    ESO_Dialogs["DYN_RESET_DATA"] = {
        title = { text = "Nettoyer les SavedVariables" },
        mainText = { text = "|cFF0000ATTENTION :|r Vous allez effacer toutes les positions personnalisées enregistrées.\n\nFaites ceci UNIQUEMENT si vous avez déjà copié les données exportées dans votre fichier |cFFFF00data.lua|r (ou DataHalos.lua).\n\nL'interface va se recharger." },
        buttons = {
            { text = "Effacer et Recharger", callback = function()
                DYN.SavedVars.zoneConfig = {}
                DYN.SavedVars.customZones = {}
                DYN.SavedVars.exportData = nil
                ReloadUI()
            end },
            { text = "Annuler" }
        }
    }

    -- DIALOGUE CRÉATION MANUELLE (Fallback)
    ESO_Dialogs["DYN_CREATE_HALO_MANUAL"] = {
        title = { text = "ID Inconnu - Nom Manuel" },
        mainText = { text = "L'ID semble invalide ou inconnu.\nEntrez un nom pour forcer la création :" },
        editBox = { defaultText = "Nom de la zone...", textType = TEXT_TYPE_ALL },
        buttons = {
            { text = "Forcer la création", callback = function(dialog)
                local name = ZO_Dialogs_GetEditBoxText(dialog)
                local val = dialog.data.id or 0
                
                local id = "Custom_" .. GetTimeStamp()
                DYN.SavedVars.customZones[id] = {
                    x=0.5, y=0.5, type="owned", size=1.0, mapIndex=(GetCurrentMapIndex() or 0),
                    collectibleId=val, customName=name
                }
                d("|c00FF00[DlcYesNo]|r Halo manuel créé : " .. name)
                if editMode then DisableEditMode() EnableEditMode() end
            end },
            { text = "Annuler" }
        }
    }

    -- DIALOGUE CRÉATION INTELLIGENTE
    ESO_Dialogs["DYN_CREATE_HALO"] = {
        title = { text = "Créer un Halo (Intelligent)" },
        mainText = { text = "Entrez l'ID du Collectible (DLC/Zone) :\nLe nom et la couleur seront détectés automatiquement." },
        editBox = { defaultText = "", textType = TEXT_TYPE_NUMERIC },
        buttons = {
            { text = "Créer", callback = function(dialog)
                local text = ZO_Dialogs_GetEditBoxText(dialog)
                local val = tonumber(text)
                
                local isValid = false
                local name = ""
                local isOwned = false

                if val and val > 0 and GetCollectibleInfo then
                    -- 1. Vérification API
                    local cName, _, _, _, cOwned = GetCollectibleInfo(val)
                    if cName and cName ~= "" then isValid = true; name = cName; isOwned = cOwned end
                end
                    
                if isValid then
                        -- 2. Création Automatique
                        local id = "Custom_" .. GetTimeStamp()
                        local typeStr = isOwned and "owned" or "missing"
                        -- On formate le nom proprement
                        name = zo_strformat("<<1>>", name)
                        
                        DYN.SavedVars.customZones[id] = {
                            x=0.5, y=0.5, 
                            type=typeStr, 
                            size=1.0, 
                            mapIndex=(GetCurrentMapIndex() or 0),
                            collectibleId=val,
                            customName=name -- On stocke le vrai nom
                        }
                        
                        d("|c00FF00[DlcYesNo]|r Halo créé : " .. name .. " (" .. (isOwned and "Possédé" or "Manquant") .. ")")
                        if editMode then DisableEditMode() EnableEditMode() end
                else
                    -- ID non trouvé ou invalide : On propose la création manuelle
                    ZO_Dialogs_ShowDialog("DYN_CREATE_HALO_MANUAL", {id=(val or 0)})
                end
            end },
            { text = "Annuler" }
        }
    }

    -- Boutons Map
    local btnOwned = wm:CreateControl("DlcYesNoMapBtnOwned", ZO_WorldMap, CT_BUTTON)
    btnOwned:SetDimensions(50, 50)
    btnOwned:SetAnchor(TOPRIGHT, ZO_WorldMap, TOPRIGHT, -10, 10) 
    btnOwned:SetDrawTier(DT_HIGH) -- Force l'affichage au premier plan
    -- Correction : On utilise une texture enfant pour pouvoir changer sa couleur
    btnOwned.tex = wm:CreateControl("$(parent)Tex", btnOwned, CT_TEXTURE)
    btnOwned.tex:SetAnchorFill()
    btnOwned.tex:SetTexture("DlcYesNo/Textures/zoneok.dds")
    btnOwned:SetClickSound("Click")
    btnOwned:SetHandler("OnMouseEnter", function(self) InitializeTooltip(InformationTooltip, self, LEFT, -5, 0); InformationTooltip:AddLine("Zones Possédées (DLC)", "ZoFontHeader2"); end); btnOwned:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)
    btnOwned:SetHandler("OnClicked", function() sv.showHaloOwned = not sv.showHaloOwned; Zone.RefreshMapPins() end)
    
    -- Nouveau Bouton Base (Bleu) - Placé à gauche de Owned
    local btnBase = wm:CreateControl("DlcYesNoMapBtnBase", ZO_WorldMap, CT_BUTTON)
    btnBase:SetDimensions(50, 50)
    btnBase:SetAnchor(RIGHT, btnOwned, LEFT, -10, 0)
    btnBase:SetDrawTier(DT_HIGH) -- Force l'affichage au premier plan
    btnBase.tex = wm:CreateControl("$(parent)Tex", btnBase, CT_TEXTURE)
    btnBase.tex:SetAnchorFill()
    btnBase.tex:SetTexture("DlcYesNo/Textures/zonefree.dds")
    btnBase:SetClickSound("Click")
    btnBase:SetHandler("OnMouseEnter", function(self) InitializeTooltip(InformationTooltip, self, LEFT, -5, 0); InformationTooltip:AddLine("Zones de Base (Gratuites)", "ZoFontHeader2"); end); btnBase:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)
    btnBase:SetHandler("OnClicked", function() sv.showHaloBase = not sv.showHaloBase; Zone.RefreshMapPins() end)
    
    -- PETIT "+" pour ZONE FREE (Mode Édition uniquement)
    btnBasePlus = wm:CreateControl("DlcYesNoMapBtnBasePlus", ZO_WorldMap, CT_BUTTON)
    btnBasePlus:SetDimensions(20, 20)
    btnBasePlus:SetAnchor(TOP, btnBase, BOTTOM, 0, -5) -- Juste sous le bouton Base
    btnBasePlus:SetNormalTexture("EsoUI/Art/Buttons/plus_up.dds")
    btnBasePlus:SetClickSound("Click")
    btnBasePlus:SetHidden(true)
    btnBasePlus:SetHandler("OnClicked", function()
        -- Création d'une zone avec ID négatif (pour être considérée "Base")
        local id = "Custom_Base_" .. GetTimeStamp()
        local negId = -GetTimeStamp() -- ID Négatif unique
        DYN.SavedVars.customZones[id] = {
            x=0.5, y=0.5, type="owned", size=1.0, mapIndex=(GetCurrentMapIndex() or 0),
            collectibleId=negId, customName="Nouvelle Zone Base"
        }
        if editMode then DisableEditMode() EnableEditMode() end
    end)
    btnBasePlus:SetHandler("OnMouseEnter", function(self) InitializeTooltip(InformationTooltip, self, LEFT, -5, 0); InformationTooltip:AddLine("Ajouter Zone de Base", "ZoFontHeader2"); end); btnBasePlus:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)
    
    local btnMissing = wm:CreateControl("DlcYesNoMapBtnMissing", ZO_WorldMap, CT_BUTTON)
    btnMissing:SetDimensions(50, 50)
    btnMissing:SetAnchor(RIGHT, btnBase, LEFT, -10, 0) -- Décalé à gauche du bouton Base
    btnMissing:SetDrawTier(DT_HIGH) -- Force l'affichage au premier plan
    btnMissing.tex = wm:CreateControl("$(parent)Tex", btnMissing, CT_TEXTURE)
    btnMissing.tex:SetAnchorFill()
    btnMissing.tex:SetTexture("DlcYesNo/Textures/zoneoff.dds")
    btnMissing:SetClickSound("Click")
    btnMissing:SetHandler("OnMouseEnter", function(self) InitializeTooltip(InformationTooltip, self, LEFT, -5, 0); InformationTooltip:AddLine("Zones Manquantes", "ZoFontHeader2"); end); btnMissing:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)
    btnMissing:SetHandler("OnClicked", function() sv.showHaloMissing = not sv.showHaloMissing; Zone.RefreshMapPins() end)

    DYN.UpdateMapBtns = function()
        local hide = not sv.showHalos
        btnOwned:SetHidden(hide)
        btnBase:SetHidden(hide)
        btnMissing:SetHidden(hide)
        if btnEdit then btnEdit:SetHidden(hide) end
        
        if not hide then
            btnOwned:SetAlpha(sv.showHaloOwned and 1 or 0.4)
            if sv.colorOwned then btnOwned.tex:SetColor(unpack(sv.colorOwned)) end
            btnBase:SetAlpha(sv.showHaloBase and 1 or 0.4)
            if sv.colorBase then btnBase.tex:SetColor(unpack(sv.colorBase)) end
            btnMissing:SetAlpha(sv.showHaloMissing and 1 or 0.4)
            if sv.colorMissing then btnMissing.tex:SetColor(unpack(sv.colorMissing)) end
        end
    end
    DYN.UpdateMapBtns()

    -- BOUTON CRÉER (Remplace les petits +)
    btnCreate = wm:CreateControl("DlcYesNoMapBtnCreate", ZO_WorldMap, CT_BUTTON)
    btnCreate:SetDimensions(40, 40)
    -- On l'intègre dans la barre d'outils (à gauche du PromoTest)
    -- L'ancrage sera défini dans le bloc de réorganisation plus bas
    btnCreate:SetNormalTexture("EsoUI/Art/Buttons/plus_up.dds") -- Gros Plus
    btnCreate:SetPressedTexture("EsoUI/Art/Buttons/plus_down.dds")
    btnCreate:SetMouseOverTexture("EsoUI/Art/Buttons/plus_over.dds")
    btnCreate:SetClickSound("Click")
    btnCreate:SetHidden(true)
    
    btnCreate:SetHandler("OnClicked", function()
        ZO_Dialogs_ShowDialog("DYN_CREATE_HALO")
    end)
    btnCreate:SetHandler("OnMouseEnter", function(self) InitializeTooltip(InformationTooltip, self, LEFT, -5, 0); InformationTooltip:AddLine("Ajouter un Halo par ID", "ZoFontHeader2"); InformationTooltip:AddLine("Détection auto Nom & Couleur", "ZoFontGame"); end); btnCreate:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)
    
    -- Bouton Edit
    if ALLOW_EDIT_ACCESS then
    btnEdit = wm:CreateControl("DlcYesNoMapBtnEdit", ZO_WorldMap, CT_BUTTON) -- Plus de "local" ici
    btnEdit:SetDimensions(40, 40)
    btnEdit:SetAnchor(RIGHT, btnMissing, LEFT, -10, 0) -- Déplacé en haut à droite (plus visible)
    btnEdit:SetNormalTexture("DlcYesNo/Textures/map.dds")
    btnEdit:SetClickSound("Click")
    btnEdit:SetHandler("OnClicked", function()
        if not editMode then
            -- Activation : Direct sans PIN
            if btnEdit then btnEdit:SetNormalTexture("DlcYesNo/Textures/map1.dds") end
            if btnEdit then btnEdit:SetAlpha(1) end
            ZO_WorldMap_SetCustomPinEnabled(_G[PIN_TYPE_OWNED], false)
            ZO_WorldMap_SetCustomPinEnabled(_G[PIN_TYPE_MISSING], false)
            ZO_WorldMap_RefreshCustomPinsOfType(_G[PIN_TYPE_OWNED])
            ZO_WorldMap_RefreshCustomPinsOfType(_G[PIN_TYPE_MISSING])
            editMode = true
            EnableEditMode()
        else
            -- Désactivation : Direct
            editMode = false
            btnEdit:SetNormalTexture("DlcYesNo/Textures/map.dds")
            btnEdit:SetAlpha(1)
            DisableEditMode()
            Zone.RefreshMapPins()
        end
    end)
    end

    -- Bouton Valider (Coche verte - Bas Droite)
    btnValidate = wm:CreateControl("DlcYesNoMapBtnValidate", ZO_WorldMap, CT_BUTTON)
    btnValidate:SetDimensions(40, 40)
    btnValidate:SetAnchor(BOTTOMRIGHT, ZO_WorldMap, BOTTOMRIGHT, -20, -20)
    btnValidate:SetNormalTexture("EsoUI/Art/Buttons/accept_up.dds")
    btnValidate:SetMouseOverTexture("EsoUI/Art/Buttons/accept_over.dds")
    btnValidate:SetClickSound("Click")
    btnValidate:SetHidden(true)
    btnValidate:SetHandler("OnClicked", function()
        -- Action : Valider et Quitter (Sauvegarde automatique locale)
        editMode = false
        btnEdit:SetNormalTexture("DlcYesNo/Textures/map.dds")
        btnEdit:SetAlpha(1)
        DisableEditMode()
        Zone.RefreshMapPins()
        d("|c00FF00[DlcYesNo]|r Modifications enregistrées (SavedVars).")
    end)
    btnValidate:SetHandler("OnMouseEnter", function(self)
        InitializeTooltip(InformationTooltip, self, LEFT, -5, 0)
        InformationTooltip:AddLine("Terminer l'édition", "ZoFontHeader2")
        InformationTooltip:AddLine("Vos changements sont sauvegardés automatiquement", "ZoFontGame")
        InformationTooltip:AddLine("dans les variables de l'addon.", "ZoFontGame")
    end)
    btnValidate:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)

    -- Bouton Export (Générer le code)
    btnExport = wm:CreateControl("DlcYesNoMapBtnExport", ZO_WorldMap, CT_BUTTON)
    btnExport:SetDimensions(40, 40)
    -- On l'insère entre Validate et Erase
    btnExport:SetAnchor(RIGHT, btnValidate, LEFT, -10, 0)
    btnExport:SetNormalTexture("DlcYesNo/Textures/sauv.dds") -- Votre icône personnalisée
    btnExport:SetPressedTexture("DlcYesNo/Textures/sauv.dds")
    btnExport:SetMouseOverTexture("DlcYesNo/Textures/sauv.dds")
    btnExport:SetClickSound("Click")
    btnExport:SetHidden(true)
    
    btnExport:SetHandler("OnClicked", function()
        Zone.ExportLayout()
    end)
    btnExport:SetHandler("OnMouseEnter", function(self)
        InitializeTooltip(InformationTooltip, self, LEFT, -5, 0)
        InformationTooltip:AddLine("Exporter vers DataHalos.lua", "ZoFontHeader2")
        InformationTooltip:AddLine("Génère le code à copier-coller", "ZoFontGame")
        InformationTooltip:AddLine("si vous souhaitez durcir la configuration.", "ZoFontGame")
    end)
    btnExport:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)

    -- Bouton Erase (Nettoyage)
    btnErase = wm:CreateControl("DlcYesNoMapBtnErase", ZO_WorldMap, CT_BUTTON)
    btnErase:SetDimensions(40, 40)
    btnErase:SetAnchor(RIGHT, btnExport, LEFT, -10, 0) -- Modifié : À gauche du bouton Export
    btnErase:SetNormalTexture("DlcYesNo/Textures/erase.dds")
    btnErase:SetClickSound("Click")
    btnErase:SetHidden(true)
    btnErase:SetHandler("OnClicked", function()
        ZO_Dialogs_ShowDialog("DYN_RESET_DATA")
    end)

    -- Mise à jour de l'état du bouton : Actif uniquement si des données exportées existent
    local function UpdateEraseState()
        local hasExport = (DYN.SavedVars.exportData ~= nil)
        btnErase:SetEnabled(hasExport)
        btnErase:SetAlpha(hasExport and 1 or 0.3)
    end
    UpdateEraseState() -- État initial au chargement

    btnErase:SetHandler("OnMouseEnter", function(self)
        InitializeTooltip(InformationTooltip, self, LEFT, -5, 0)
        InformationTooltip:AddLine("Nettoyer les données", "ZoFontHeader2")
        if DYN.SavedVars.exportData == nil then
            InformationTooltip:AddLine("|cFF0000Action requise :|r Faites d'abord un export (/dlcexport).", "ZoFontGame")
        else
            InformationTooltip:AddLine("Réinitialise les SavedVariables (après export).", "ZoFontGame")
        end
    end)
    btnErase:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)

    -- Bouton Lock (Verrouillage - Cadenas)
    btnLock = wm:CreateControl("DlcYesNoMapBtnLock", ZO_WorldMap, CT_BUTTON)
    btnLock:SetDimensions(40, 40)
    -- On le place juste avant le bouton BIZ ou Erase. Ici on va le mettre à gauche de la future position de BIZ.
    -- Note: L'ancrage de BIZ sera modifié juste après pour se coller à Lock.
    -- Pour l'instant, on l'ancre temporairement, l'ordre visuel sera : Rescue -> Lock -> Biz -> Erase -> Validate
    btnLock:SetAnchor(TOPRIGHT, ZO_WorldMap, TOPRIGHT, -150, 10) -- Position temporaire neutre pour éviter le crash
    btnLock:SetNormalTexture("EsoUI/Art/Miscellaneous/unlocked_up.dds")
    btnLock:SetPressedTexture("EsoUI/Art/Miscellaneous/unlocked_down.dds")
    btnLock:SetMouseOverTexture("EsoUI/Art/Miscellaneous/unlocked_over.dds")
    btnLock:SetClickSound("Click")
    btnLock:SetHidden(true)

    btnLock:SetHandler("OnClicked", function()
        lockedMode = not lockedMode
        -- Changement d'icône
        local texture = lockedMode and "EsoUI/Art/Miscellaneous/locked_up.dds" or "EsoUI/Art/Miscellaneous/unlocked_up.dds"
        btnLock:SetNormalTexture(texture)
        
        -- Appliquer le verrouillage à tous les contrôles existants
        for _, ctrl in pairs(editorControls) do
            ctrl:SetMovable(not lockedMode)
        end
        PlaySound(lockedMode and SOUNDS.ALLIANCE_WAR_GATE_CLOSE or SOUNDS.ALLIANCE_WAR_GATE_OPEN)
    end)

    btnLock:SetHandler("OnMouseEnter", function(self)
        InitializeTooltip(InformationTooltip, self, LEFT, -5, 0)
        InformationTooltip:AddLine(lockedMode and "Déverrouiller les Halos" or "Verrouiller les Halos", "ZoFontHeader2")
        InformationTooltip:AddLine("Empêche le déplacement accidentel.", "ZoFontGame")
    end)
    btnLock:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)

    -- Bouton Rescue (Aimant - Rapatriement)
    btnRescue = wm:CreateControl("DlcYesNoMapBtnRescue", ZO_WorldMap, CT_BUTTON)
    btnRescue:SetDimensions(40, 40)
    btnRescue:SetAnchor(RIGHT, btnLock, LEFT, -10, 0) -- À gauche du cadenas
    btnRescue:SetNormalTexture("EsoUI/Art/Mounts/ridingskill_ready.dds") 
    btnRescue:SetClickSound("Click")
    btnRescue:SetHidden(true)

    btnRescue:SetHandler("OnClicked", function()
        local restored = 0
        local mapWidth, mapHeight = ZO_WorldMapContainer:GetDimensions()
        for id, ctrl in pairs(editorControls) do
            if not ctrl:IsHidden() and ctrl.normalizedX and ctrl.normalizedY then
                -- Si hors limites (avec marge)
                if ctrl.normalizedX < -0.1 or ctrl.normalizedX > 1.1 or ctrl.normalizedY < -0.1 or ctrl.normalizedY > 1.1 then
                    ctrl.normalizedX = 0.5
                    ctrl.normalizedY = 0.5
                    ctrl:ClearAnchors()
                    ctrl:SetAnchor(CENTER, ZO_WorldMapContainer, TOPLEFT, 0.5 * mapWidth, 0.5 * mapHeight)
                    if not DYN.SavedVars.zoneConfig[id] then DYN.SavedVars.zoneConfig[id] = {} end
                    DYN.SavedVars.zoneConfig[id].x = 0.5
                    DYN.SavedVars.zoneConfig[id].y = 0.5
                    restored = restored + 1
                end
            end
        end
        d("|c00FF00[DlcYesNo]|r " .. restored .. " halo(s) rapatrié(s).")
    end)
    btnRescue:SetHandler("OnMouseEnter", function(self) InitializeTooltip(InformationTooltip, self, LEFT, -5, 0); InformationTooltip:AddLine("Rapatrier les Halos perdus", "ZoFontHeader2"); end); btnRescue:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)

    -- Bouton BIZ (Lister les halos suspects)
    btnBiz = wm:CreateControl("DlcYesNoMapBtnBiz", ZO_WorldMap, CT_BUTTON)
    btnBiz:SetDimensions(40, 40)
    
    -- RE-ORGANISATION FINALE DES ANCRAGES (De droite à gauche)
    -- Validate (Fixe) <- Export <- Erase <- Biz <- Lock <- Rescue <- Create
    btnExport:ClearAnchors(); btnExport:SetAnchor(RIGHT, btnValidate, LEFT, -10, 0)
    btnErase:ClearAnchors(); btnErase:SetAnchor(RIGHT, btnExport, LEFT, -10, 0)
    btnBiz:ClearAnchors(); btnBiz:SetAnchor(RIGHT, btnErase, LEFT, -10, 0)
    btnLock:ClearAnchors(); btnLock:SetAnchor(RIGHT, btnBiz, LEFT, -10, 0)
    btnRescue:ClearAnchors(); btnRescue:SetAnchor(RIGHT, btnLock, LEFT, -10, 0)
    btnCreate:ClearAnchors(); btnCreate:SetAnchor(RIGHT, btnRescue, LEFT, -10, 0)

    btnBiz:SetNormalTexture("EsoUI/Art/Buttons/copy_up.dds") -- Icône "Liste"
    btnBiz:SetPressedTexture("EsoUI/Art/Buttons/copy_down.dds")
    btnBiz:SetMouseOverTexture("EsoUI/Art/Buttons/copy_over.dds")
    btnBiz:SetClickSound("Click")
    btnBiz:SetHidden(true)
    
    local bizLabel = wm:CreateControl("$(parent)Label", btnBiz, CT_LABEL)
    bizLabel:SetAnchor(CENTER, btnBiz, CENTER, 0, 0)
    bizLabel:SetFont("ZoFontGameSmall")
    bizLabel:SetText("BIZ")
    bizLabel:SetColor(1, 1, 0, 1) -- Texte Jaune
    
    btnBiz:SetHandler("OnClicked", function()
        d("--- |cFF0000[DlcYesNo]|r Analyse BIZ ---")
        local count = 0
        
        local function CheckAndPrint(id, isCustom)
            local name = GetHaloName(id, isCustom)
            local isSuspect = false
            
            -- Critères de bizarrerie
            if name == "" or name == "Zone Inconnue" or name == "Nouvelle Zone" or name == "N/A" then isSuspect = true end
            if string.find(name, "ID:") then isSuspect = true end
            
            if isSuspect then
                count = count + 1
                local typeStr = isCustom and "|c00FFFF[Custom]|r" or "|cFFFF00[Base]|r"
                d(string.format("%s ID:%s -> %s", typeStr, tostring(id), name))
            end
        end

        -- Vérification Zones de Base
        local coords = (DYN.Zone and DYN.Zone.DlcCoords) or {}
        for id, _ in pairs(coords) do CheckAndPrint(id, false) end
        
        -- Vérification Custom
        if DYN.SavedVars.customZones then
            for id, _ in pairs(DYN.SavedVars.customZones) do CheckAndPrint(id, true) end
        end
        
        if count == 0 then d("Rien de bizarre trouvé !") else d("Total: " .. count .. " halos suspects.") end
    end)

    SLASH_COMMANDS["/dlcexport"] = Zone.ExportLayout
    SLASH_COMMANDS["/dlccheck"] = Zone.CheckChanges

    local pinLayoutOwned = { level = 40, texture = "DlcYesNo/Textures/zoneok.dds", size = 50, tint = ZO_ColorDef:New(unpack(sv.colorOwned)) }
    local pinLayoutMissing = { level = 41, texture = "DlcYesNo/Textures/zoneoff.dds", size = 50, tint = ZO_ColorDef:New(unpack(sv.colorMissing)) }
    local pinLayoutBase = { level = 39, texture = "DlcYesNo/Textures/zonefree.dds", size = 50, tint = ZO_ColorDef:New(unpack(sv.colorBase or {1,1,1,1})) }
    -- On passe notre fonction PinTooltip dédiée pour que le jeu l'utilise nativement
    local tooltipCreator = { creator = PinCreator, tooltip = nil }

    ZO_WorldMap_AddCustomPin(PIN_TYPE_OWNED, function(pm) MapPinLayout(pm, true) end, nil, pinLayoutOwned, tooltipCreator)
    ZO_WorldMap_AddCustomPin(PIN_TYPE_MISSING, function(pm) MapPinLayout(pm, false) end, nil, pinLayoutMissing, tooltipCreator)
    ZO_WorldMap_AddCustomPin(PIN_TYPE_BASE, function(pm) MapPinLayout(pm, "base") end, nil, pinLayoutBase, tooltipCreator)

    -- Hook pour gérer le zoom en mode édition
    ZO_PreHookHandler(ZO_WorldMapContainer, "OnRectChanged", function()
        if editMode then Zone.UpdateEditPositions() end
    end)

    Zone.RefreshMapPins()
    CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", Zone.OnMapChanged)
end

function Zone.ExportLayout()
    local lines = {}
    table.insert(lines, "DYN = DYN or {}")
    table.insert(lines, "DYN.Zone = DYN.Zone or {}")
    table.insert(lines, "")
    table.insert(lines, "-- [[ FICHIER DataHalos.lua COMPLET ]]")
    table.insert(lines, "-- Remplacez TOUT le contenu de DataHalos.lua par ce bloc.")
    table.insert(lines, "DYN.Zone.DlcCoords = {")
    
    -- 1. Exporter les zones existantes (Base + Modifs)
    local usedIds = {} -- Pour détecter les doublons à l'export
    local coords = DYN.Zone.DlcCoords or {}
    for id, data in pairs(coords) do
        if type(id) == "number" then usedIds[id] = 1 end
        
        local conf = GetZoneConfig(id)
        -- Priorité : Config sauvegardée > Données actuelles
        local finalX = (conf and conf.x) or data[1]
        local finalY = (conf and conf.y) or data[2]
        local name = data[3]
        local finalSize = (conf and conf.size) or data[4] or 1.0
        local mapIdx = data[5] or 1 -- Récupération mapIndex
        local realId = data[6] -- Récupération ID réel si c'est un doublon spécial
        
        local nameStr = "nil"
        
        if type(name) == "table" then
            -- Si c'est un tableau de traductions, on le reconstruit proprement
            local parts = {}
            local langs = {"en", "fr", "de", "es", "ru"} -- Ordre de préférence pour l'affichage
            for _, l in ipairs(langs) do
                if name[l] then table.insert(parts, string.format('%s=%q', l, name[l])) end
            end
            -- Sécurité pour autres clés éventuelles
            for k, v in pairs(name) do
                local known = false; for _, l in ipairs(langs) do if l == k then known = true end end
                if not known then table.insert(parts, string.format('%s=%q', k, v)) end
            end
            nameStr = "{" .. table.concat(parts, ", ") .. "}"
        elseif type(name) == "string" then
            nameStr = string.format("%q", name)
        end
        
        -- Export intelligent : On n'ajoute mapIndex que si ce n'est pas Tamriel (1) pour garder la ligne courte
        local keyStr = (type(id) == "string") and string.format("[%q]", id) or string.format("[%d]", id)
        
        -- Construction de la table de données {x,y,name,size,map,realID}
        local dataParts = {
            string.format("%.10f", finalX),
            string.format("%.10f", finalY),
            nameStr
        }
        if math.abs(finalSize - 1.0) > 0.001 or mapIdx ~= 1 or realId then
            table.insert(dataParts, string.format("%.2f", finalSize))
        end
        if mapIdx ~= 1 then
            table.insert(dataParts, string.format("%d", mapIdx))
        end
        if realId then -- Si c'est un doublon spécial, on ajoute l'ID réel à la fin
            if #dataParts < 5 then table.insert(dataParts, "1") end -- MapIdx par défaut si manquant
            if #dataParts < 4 then table.insert(dataParts, "1.00") end -- Size par défaut si manquant
            table.insert(dataParts, string.format("%d", realId))
        end
        
        table.insert(lines, string.format("    %s = {%s},", keyStr, table.concat(dataParts, ", ")))
    end

    -- 2. Ajouter les nouvelles zones personnalisées (Custom)
    if DYN.SavedVars.customZones then
        for _, zData in pairs(DYN.SavedVars.customZones) do
            if zData.collectibleId and zData.collectibleId ~= 0 then
                local zId = zData.collectibleId
                local name = zData.customName or GetCollectibleInfo(zData.collectibleId) or "Zone"
                local size = zData.size or 1.0
                local nameStr = string.format("%q", name)
                local mapIdx = zData.mapIndex or 1
                
                -- Gestion intelligente des doublons pour l'export
                local keyStr, suffix
                if usedIds[zId] then
                    usedIds[zId] = usedIds[zId] + 1
                    keyStr = string.format("[\"Custom_%d_%d\"]", zId, usedIds[zId])
                    -- On ajoute l'ID en 6ème paramètre car la clé n'est pas l'ID
                    if mapIdx ~= 1 then
                        suffix = string.format(", %.2f, %d, %d}, -- Custom", size, mapIdx, zId)
                    else
                        suffix = string.format(", %.2f, 1, %d}, -- Custom", size, zId)
                    end
                else
                    usedIds[zId] = 1
                    keyStr = string.format("[%d]", zId)
                    if mapIdx ~= 1 then
                        suffix = string.format(", %.2f, %d}, -- Custom", size, mapIdx)
                    else
                        suffix = string.format(", %.2f}, -- Custom", size)
                    end
                end
                
                table.insert(lines, string.format("    %s = {%.10f, %.10f, %s%s", keyStr, zData.x, zData.y, nameStr, suffix))
            end
        end
    end
    
    table.insert(lines, "}")

    -- Sauvegarde dans les SavedVariables pour récupération facile
    DYN.SavedVars.exportData = table.concat(lines, "\n")
    
    d("|c00FF00[DlcYesNo]|r Données exportées !")
    d("1. Faites |cFFFF00/reload|r pour sauvegarder sur le disque.")
    d("2. Ouvrez |cFFFF00SavedVariables/DlcYesNo.lua|r")
    d("3. Remplacez TOUT le contenu de DataHalos.lua par 'exportData'")
    
    -- Réactiver le bouton Erase immédiatement après l'export
    if btnErase then
        btnErase:SetEnabled(true)
        btnErase:SetAlpha(1)
    end
end
