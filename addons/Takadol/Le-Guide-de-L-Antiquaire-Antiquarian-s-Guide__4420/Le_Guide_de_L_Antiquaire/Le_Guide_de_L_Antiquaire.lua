Le_Guide_de_L_Antiquaire = Le_Guide_de_L_Antiquaire or {}
local MyAddon = Le_Guide_de_L_Antiquaire
MyAddon.name = "Le_Guide_de_L_Antiquaire"

-- ==========================================================
-- GESTION DE LA LANGUE 
-- ==========================================================
MyAddon.L = {} -- Notre table de traduction actuelle
local LangTables = {} -- Contiendra toutes les tables de langue

-- La fonction de traduction principale
function _G.LGA_L(key)
    return MyAddon.L[key] or key
end

-- Fonction utilitaire pour les noms de zones spéciales
local function GetSpecialZoneName(zoneId)
    if zoneId == MyAddon.ZONEID_ALLZONES then return LGA_L("ZONE_ANYWHERE") end
    if zoneId == MyAddon.ZONEID_BGS then return LGA_L("ZONE_BGS") end
    if zoneId == MyAddon.ZONEID_ARTAEUM_SUMMERSET then return LGA_L("ZONE_ARTAEUM_SUMMERSET") end
    if zoneId == MyAddon.ZONEID_EASTMARCH_RIFT then return LGA_L("ZONE_EASTMARCH_RIFT") end
    if zoneId == MyAddon.ZONEID_CYRODIIL_IMPERIALCITY then return LGA_L("ZONE_CYRODIIL_IMPERIALCITY") end
    if zoneId == MyAddon.ZONEID_THEREACH_WSKYRIM then return LGA_L("ZONE_THEREACH_WSKYRIM") end
    if zoneId == MyAddon.ZONEID_GALEN_HIGHISLE then return LGA_L("ZONE_GALEN_HIGHISLE") end
    if zoneId == MyAddon.ZONEID_UNKNOWN then return LGA_L("ZONE_UNKNOWN") end
    -- Fallback si l'ID est standard
    return GetZoneNameById(zoneId)
end

function MyAddon:ChangeLanguage(langCode)
    if LangTables[langCode] then
        MyAddon.savedVars.language = langCode
        MyAddon.L = LangTables[langCode]
        MyAddon.AntiquityHints = MyAddon.AllHints[langCode] or MyAddon.AllHints["fr"] or {}

        -- On reconstruit les données pour mettre à jour les textes des pistes (mapText)
        MyAddon.BuildLeadData()
        
        -- On met à jour tous les textes de l'interface et on rafraîchit la liste
        if mainWin then
            -- On met à jour le drapeau du bouton de langue
            if langBtn then
                langBtn:SetNormalTexture("Le_Guide_de_L_Antiquaire/Textures/Trad.dds")
            end                                 
            -- Réinitialisation de la recherche (Demande utilisateur)
            if MyAddon.savedVars.searchTerms then
                for k in pairs(MyAddon.savedVars.searchTerms) do
                    MyAddon.savedVars.searchTerms[k] = ""
                end
            end
            if searchBox then
                searchBox:SetText(LGA_L("SEARCH_PLACEHOLDER"))
            end

            MyAddon:UpdateUITexts()

            -- Petit timer pour laisser l'interface respirer avant l'actualisation
            zo_callLater(function() RefreshList() end, 200)
        end
    end
end

-- ==========================================================
-- MODULE D'INTERACTION INJECTABLE
-- ==========================================================
local AntiquityModule = {}

function AntiquityModule:Sonder(antiquityId)
    if not antiquityId or antiquityId <= 0 then return end
    if _G["ScryForAntiquity"] then _G["ScryForAntiquity"](antiquityId) end
end

function AntiquityModule:AfficherCarte(antiquityId)
    if not antiquityId or antiquityId <= 0 then return end
    if _G["WORLD_MAP_MANAGER"] then
        _G["WORLD_MAP_MANAGER"]:ShowAntiquityOnMap(antiquityId)
    elseif _G["ShowMapAntiquity"] then
        _G["ShowMapAntiquity"](antiquityId)
    end
end

function AntiquityModule:AfficherZoneCarte(zoneId)
    if not zoneId or zoneId <= 0 or zoneId >= 101010 then return end -- Sécurité pour les zones spéciales
    
    if _G["SCENE_MANAGER"] then _G["SCENE_MANAGER"]:Show("worldMap") end
    
    local GetMapIndexByZoneId = _G["GetMapIndexByZoneId"]
    local ZO_WorldMap_SetMapByIndex = _G["ZO_WorldMap_SetMapByIndex"]
    
    if GetMapIndexByZoneId and ZO_WorldMap_SetMapByIndex then
        local mapIndex = GetMapIndexByZoneId(zoneId)
        if mapIndex then ZO_WorldMap_SetMapByIndex(mapIndex) end
    end
end

-- ==========================================================
-- MODULE OEIL DE L'ANTIQUAIRE AUTOMATIQUE
-- ==========================================================
MyAddon.AutoEye = {}
local AE = MyAddon.AutoEye

AE.previousSlot = nil
AE.eyeSlot = nil
AE.isDigging = false

function AE:FindEye()
    self.eyeSlot = 0
    for i = 1, 8, 1 do
        if GetSlotItemLink(i, HOTBAR_CATEGORY_QUICKSLOT_WHEEL) == "|H0:collectible:8006|h|h" then
            self.eyeSlot = i
        end
    end
end

function AE:SlotEye()
    if self.eyeSlot and self.eyeSlot ~= 0 and GetSlotItemLink(GetCurrentQuickslot(), HOTBAR_CATEGORY_QUICKSLOT_WHEEL) ~= "|H0:collectible:8006|h|h" then
        self.previousSlot = GetCurrentQuickslot()
        SetCurrentQuickslot(self.eyeSlot)
    end
end

function AE:UnslotEye()
    if self.previousSlot and GetSlotItemLink(GetCurrentQuickslot(), HOTBAR_CATEGORY_QUICKSLOT_WHEEL) == "|H0:collectible:8006|h|h" then
        SetCurrentQuickslot(self.previousSlot)
        self.previousSlot = nil -- Clear it after use
    end
end

function AE:MainLoop()
    if not MyAddon.savedVars.autoEyeEnabled then
        self:UnslotEye() -- Make sure to unslot if disabled
        return
    end

    if not IsCollectibleBlocked(8006) then
        self:SlotEye()
        if not self.isDigging and GetCollectibleCooldownAndDuration(8006) == 0 and (not IsPlayerMoving() or MyAddon.savedVars.autoEyeIgnoreMovement) then
            UseCollectible(8006)
        end
    else
        self:UnslotEye()
    end
end

function AE:OnPlayerActivated()
    if GetMapContentType() ~= MAP_CONTENT_AVA and GetMapContentType() ~= MAP_CONTENT_BATTLEGROUND and GetMapContentType() ~= MAP_CONTENT_DUNGEON then
        EVENT_MANAGER:RegisterForUpdate(MyAddon.name.."AutoEyeTickUpdate", 1000, function() self:MainLoop() end)
    else
        EVENT_MANAGER:UnregisterForUpdate(MyAddon.name.."AutoEyeTickUpdate")
    end
end

-- Déclaration des globales locales pour éviter les avertissements et optimiser
local GetWindowManager = _G["GetWindowManager"]
local GetNextAntiquityId = _G["GetNextAntiquityId"]
local GetAntiquityRewardId = _G["GetAntiquityRewardId"]
local REWARDS_MANAGER = _G["REWARDS_MANAGER"]
local GetAchievementRewardItem = _G["GetAchievementRewardItem"]
local DoesAntiquityNeedCombination = _G["DoesAntiquityNeedCombination"]
local DoesAntiquityHaveLead = _G["DoesAntiquityHaveLead"]
local GetAntiquityLeadTimeRemainingSeconds = _G["GetAntiquityLeadTimeRemainingSeconds"]
local GetAchievementInfo = _G["GetAchievementInfo"]
local GetAntiquityName = _G["GetAntiquityName"]
local GetAntiquitySetId = _G["GetAntiquitySetId"]
local GetItemLinkInfo = _G["GetItemLinkInfo"]
local GetAntiquitySetName = _G["GetAntiquitySetName"]
local GetZoneId = _G["GetZoneId"]
local GetItemLinkEquipType = _G["GetItemLinkEquipType"]
local EQUIP_TYPE_NONE = _G["EQUIP_TYPE_NONE"]
local GetUnitZoneIndex = _G["GetUnitZoneIndex"]
local InitializeTooltip = _G["InitializeTooltip"]
local GetCollectibleName = _G["GetCollectibleName"]
local GetCollectibleIcon = _G["GetCollectibleIcon"]
local GetItemLinkItemSetCollectionPieceInfo = _G["GetItemLinkItemSetCollectionPieceInfo"]
local IsItemSetCollectionPieceUnlocked = _G["IsItemSetCollectionPieceUnlocked"]
local ItemTooltip = _G["ItemTooltip"]
local InformationTooltip = _G["InformationTooltip"]
local ClearTooltip = _G["ClearTooltip"]
local GuiRoot = _G["GuiRoot"]
local ZO_SavedVars = _G["ZO_SavedVars"]
local SLASH_COMMANDS = _G["SLASH_COMMANDS"]
local EVENT_MANAGER = _G["EVENT_MANAGER"]
local EVENT_ADD_ON_LOADED = _G["EVENT_ADD_ON_LOADED"]
local zo_callLater = _G["zo_callLater"]
local zo_strformat = _G["zo_strformat"]
local pcall = _G["pcall"]
local pairs = _G["pairs"]
local ipairs = _G["ipairs"]
local d = _G["d"]
local string = _G["string"]
local table = _G["table"]
local GetZoneNameById = _G["GetZoneNameById"]
local math = _G["math"]
local ZO_SimpleSceneFragment = _G["ZO_SimpleSceneFragment"]
local SCENE_MANAGER = _G["SCENE_MANAGER"]
local SCENE_SHOWING = _G["SCENE_SHOWING"]
local SCENE_HIDDEN = _G["SCENE_HIDDEN"]
local GetItemQualityColor = _G["GetItemQualityColor"]
local GetItemLinkQuality = _G["GetItemLinkQuality"]
local GetAntiquitySetQuality = _G["GetAntiquitySetQuality"]
local GetAntiquityQuality = _G["GetAntiquityQuality"]
local GetAntiquityDifficulty = _G["GetAntiquityDifficulty"]
local GetAntiquityZoneId = _G["GetAntiquityZoneId"]
local GetNumAntiquitiesRecovered = _G["GetNumAntiquitiesRecovered"]
local GetAntiquityScryFailureReason = _G["GetAntiquityScryFailureReason"]
local SCRY_FAILURE_REASON_NONE = _G["SCRY_FAILURE_REASON_NONE"]
local SCRY_FAILURE_REASON_INCORRECT_ZONE = _G["SCRY_FAILURE_REASON_INCORRECT_ZONE"]
local SCRY_FAILURE_REASON_NOT_ENOUGH_SKILL = _G["SCRY_FAILURE_REASON_NOT_ENOUGH_SKILL"]
local SCRY_FAILURE_REASON_META_ANTIQUTY_NOT_COMPLETE = _G["SCRY_FAILURE_REASON_META_ANTIQUTY_NOT_COMPLETE"]
-- Constantes UI
local CT_BUTTON = _G["CT_BUTTON"]
local CT_LABEL = _G["CT_LABEL"]
local CT_TEXTURE = _G["CT_TEXTURE"]
local CT_CONTROL = _G["CT_CONTROL"]
local CT_BACKDROP = _G["CT_BACKDROP"]
local CT_EDITBOX = _G["CT_EDITBOX"]
local TOP = _G["TOP"]
local TOPLEFT = _G["TOPLEFT"]
local TOPRIGHT = _G["TOPRIGHT"]
local BOTTOM = _G["BOTTOM"]
local BOTTOMLEFT = _G["BOTTOMLEFT"]
local BOTTOMRIGHT = _G["BOTTOMRIGHT"]
local LEFT = _G["LEFT"]
local RIGHT = _G["RIGHT"]
local CENTER = _G["CENTER"]
local DT_LOW = _G["DT_LOW"]
local DT_HIGH = _G["DT_HIGH"]
local DL_OVERLAY = _G["DL_OVERLAY"]
local DL_CONTROLS = _G["DL_CONTROLS"]
local DL_BACKGROUND = _G["DL_BACKGROUND"]
local DT_MEDIUM = _G["DT_MEDIUM"]
local MODIFY_TEXT_TYPE_NONE = _G["MODIFY_TEXT_TYPE_NONE"]
local TEXT_ALIGN_LEFT = _G["TEXT_ALIGN_LEFT"]
local TEXT_ALIGN_CENTER = _G["TEXT_ALIGN_CENTER"]
local MOUSE_BUTTON_INDEX_LEFT = _G["MOUSE_BUTTON_INDEX_LEFT"]
local OPACITIES = {1.0, 0.75, 0.5, 0.25, 0.0}

local wm = GetWindowManager()
local mainWin, listArea, titleLabel, searchBox, bg
local opacityControl, opacLabel
local btnAll, btnItems, btnFragments, btnFav, lockBtn, langBtn, refreshBtn, closeBtn, closeAllBtn
local itemButtons = {}
local buttonPool = {}
local btnFilterAll, btnFilterAcquired, btnFilterUnacquired, alarmBtn, settingsBtn, refreshAlarmBtn, resetFiltersBtn
local btnFragFilterAll, btnFragFilterLeads, btnFragFilterAcquired, btnFragFilterUnacquired
local configArea, regionDropdown, typeDropdown, qualityDropdown
local itemCountLabel
local noteView, noteBtn, noteEdit, noteTabsContainer, deleteNoteBtn
local currentTab = "all"
local isMinimized = false
local RefreshList
local isViewingNotes = false
local alarmSettingsPopup, alarmDisplayPopup
local PopulateRegionDropdown, PopulateTypeDropdown, PopulateQualityDropdown, UpdateLockVisuals, minimizedBar, UpdateTitle
local OnFragmentClicked -- Déclaration anticipée pour accès dans le popup d'alarme
-- Fonction centralisée pour gérer la visibilité des filtres
-- Constante pour les clés de réglages d'apparence (Déplacé ici pour être visible partout)
local APPEARANCE_KEYS = {
    "mainWinFrameStyle", "popupFrameStyle", "mainWinFrameColor", "popupFrameColor",
    "mainWinBgColor", "popupBgColor", "mainWinFont", "mainWinFontSize", "popupFont", "popupFontSize",
    "alarmPopupFrameStyle", "alarmPopupFrameColor", "alarmPopupBgColor", "alarmPopupFont", "alarmPopupFontSize"
}

local function UpdateFilterVisibilityForTab(tabName)
    local showItemFilters = (tabName == "items")
    local showFragFilters = (tabName == "fragments")

    -- Filtres de l'onglet "Obj.Myth"
    if btnFilterAll then btnFilterAll:SetHidden(not showItemFilters) end
    if btnFilterAcquired then btnFilterAcquired:SetHidden(not showItemFilters) end
    if btnFilterUnacquired then btnFilterUnacquired:SetHidden(not showItemFilters) end

    -- Filtres de l'onglet "PISTES"
    if btnFragFilterAll then btnFragFilterAll:SetHidden(not showFragFilters) end
    if btnFragFilterLeads then btnFragFilterLeads:SetHidden(not showFragFilters) end
    if btnFragFilterAcquired then btnFragFilterAcquired:SetHidden(not showFragFilters) end
    if btnFragFilterUnacquired then btnFragFilterUnacquired:SetHidden(not showFragFilters) end
    if regionDropdown then regionDropdown:SetHidden(not showFragFilters) end
    if typeDropdown then typeDropdown:SetHidden(not showFragFilters) end
    if qualityDropdown then qualityDropdown:SetHidden(not showFragFilters) end

    -- Visibilité du bouton d'alarme
    local showAlarmBtn = (tabName == "fragments")
    if alarmBtn then alarmBtn:SetHidden(not showAlarmBtn) end
    if settingsBtn then settingsBtn:SetHidden(not showAlarmBtn) end
    if refreshAlarmBtn then refreshAlarmBtn:SetHidden(not showAlarmBtn) end
    if resetFiltersBtn then resetFiltersBtn:SetHidden(not showAlarmBtn) end
end

-- Fonction globale (attachée à l'addon) pour gérer le clic sur un favori
function MyAddon.HandleFavoriteClick(key, optionalStarControl)
    local sv = MyAddon.savedVars
    if not sv.favorites then sv.favorites = {} end

    local isNowFavorite = not sv.favorites[key]
    sv.favorites[key] = isNowFavorite

    if optionalStarControl then
        local tex = isNowFavorite and "Le_Guide_de_L_Antiquaire/Textures/favoris.dds" or "Le_Guide_de_L_Antiquaire/Textures/non-favoris.dds"
        optionalStarControl:SetNormalTexture(tex)
    end

    if currentTab == "fav" and not isNowFavorite then
        RefreshList()
    else
        if itemButtons and itemButtons[key] then
            local btn = itemButtons[key]
            local star = btn:GetNamedChild("Star")
            local tex = isNowFavorite and "Le_Guide_de_L_Antiquaire/Textures/favoris.dds" or "Le_Guide_de_L_Antiquaire/Textures/non-favoris.dds"
            if star then star:SetNormalTexture(tex) end
        else
            RefreshList() -- Fallback si itemButtons est nil
        end
    end
end

-- NOUVEAU: Données chargées dynamiquement
MyAddon.MythicItems = {}
MyAddon.AllLeads = {}
MyAddon.expandedMythics = {}
local function GetLeadTimer(antiquityId)
    local id = tonumber(antiquityId)
    if not id or id <= 0 then return "" end
    
    if DoesAntiquityHaveLead and DoesAntiquityHaveLead(id) and GetAntiquityLeadTimeRemainingSeconds then
        local remaining = GetAntiquityLeadTimeRemainingSeconds(id)
        if remaining and remaining > 0 then
            if remaining > 100000000 then remaining = remaining / 1000 end
            local days = math.floor(remaining / 86400)
            local hours = math.floor((remaining % 86400) / 3600)
            local timeParts = {}
            if days > 0 then table.insert(timeParts, days .. LGA_L("DAY_SHORT")) end
            if hours > 0 then table.insert(timeParts, hours .. LGA_L("HOUR_SHORT")) end
            if #timeParts == 0 then
                local minutes = math.floor(remaining / 60)
                if minutes > 0 then table.insert(timeParts, minutes .. LGA_L("MINUTE_SHORT")) end
            end
            if #timeParts > 0 then return " (" .. table.concat(timeParts, " ") .. ")" end
        end
    end
    return ""
end

local function GetFragmentStatus(antiquityId)
    local id = tonumber(antiquityId) -- Convertit en nombre si c'est une chaîne (ex: "335")
    -- Sécurité : On vérifie si c'est bien un nombre
    if not id or id <= 0 then 
        return "|c888888[ID MANQUANT (" .. tostring(antiquityId) .. ")]|r" 
    end

    -- 1. Fragment acquis (Prêt à être combiné)
    -- CORRECTION : On vérifie si le fragment a été récupéré (creusé) au moins une fois
    if GetNumAntiquitiesRecovered and GetNumAntiquitiesRecovered(id) > 0 then
        return "|c00FF00[ACQUIS]|r"
    elseif DoesAntiquityNeedCombination and DoesAntiquityNeedCombination(id) then
        return "|c00FF00[ACQUIS]|r"
    end

    -- 2. Piste possédée (avec temps restant)
    if DoesAntiquityHaveLead and DoesAntiquityHaveLead(id) then
        local txt = "|cFFF000[PISTE POSSÉDÉE]|r"
        
        -- Ajout du temps restant (ex: 25j)
        if GetAntiquityLeadTimeRemainingSeconds then
            local remaining = GetAntiquityLeadTimeRemainingSeconds(id)
            if remaining and remaining > 0 then
                -- Correction : Si la valeur est énorme (> 100 millions), c'est des millisecondes
                if remaining > 100000000 then 
                    remaining = remaining / 1000 
                end

                local days = math.floor(remaining / 86400)
                local hours = math.floor((remaining % 86400) / 3600)
                
                local timeParts = {}
                if days > 0 then
                    table.insert(timeParts, days .. LGA_L("DAY_SHORT"))
                end
                if hours > 0 then
                    table.insert(timeParts, hours .. LGA_L("HOUR_SHORT"))
                end

                -- Si moins d'une heure, on affiche les minutes
                if #timeParts == 0 then
                    local minutes = math.floor(remaining / 60)
                    if minutes > 0 then table.insert(timeParts, minutes .. LGA_L("MINUTE_SHORT")) end
                end

                if #timeParts > 0 then
                    txt = txt .. " (" .. table.concat(timeParts, " ") .. ")"
                end
            end
        end
        return txt
    end

    return "|cFF0000[NON TROUVÉ]|r"
end

local function GetMythicStatus(achId)
    -- Sécurité : On vérifie si achId est bien un NOMBRE et supérieur à 0
    if not achId or type(achId) ~= "number" or achId <= 0 then 
        return "|c888888INCONNU|r" 
    end

    -- Tentative sécurisée de récupération du succès
    local _, _, _, _, completed = GetAchievementInfo(achId)
    
    if completed then
        return "|c00FF00ACQUIS|r"
    else
        return "|cFF0000NON ACQUIS|r"
    end
end

	-- Gestionnaire d'accents
-- OPTIMISATION : Table définie une seule fois à l'extérieur de la fonction
local ACCENT_REPLACEMENTS = {
    ["à"]="a", ["á"]="a", ["â"]="a", ["ã"]="a", ["ä"]="a", ["å"]="a",
    ["è"]="e", ["é"]="e", ["ê"]="e", ["ë"]="e",
    ["ì"]="i", ["í"]="i", ["î"]="i", ["ï"]="i",
    ["ò"]="o", ["ó"]="o", ["ô"]="o", ["õ"]="o", ["ö"]="o",
    ["ù"]="u", ["ú"]="u", ["û"]="u", ["ü"]="u",
    ["ý"]="y", ["ÿ"]="y", ["ç"]="c", ["ñ"]="n"
}
local function CleanText(str)
    if not str then return "" end
    local clean = str:lower()
    for accent, simple in pairs(ACCENT_REPLACEMENTS) do clean = clean:gsub(accent, simple) end
    return clean
end

-- Fonction de formatage du temps localisée
function MyAddon:FormatTime(remaining)
    if not remaining or remaining <= 0 then return "" end

    local days = math.floor(remaining / 86400)
    local hours = math.floor((remaining % 86400) / 3600)
    local mins = math.floor((remaining % 3600) / 60)

    if days > 0 then
        return string.format("%d%s %d%s", days, LGA_L("DAY_SHORT"), hours, LGA_L("HOUR_SHORT"))
    elseif hours > 0 then
        return string.format("%d%s %d%s", hours, LGA_L("HOUR_SHORT"), mins, LGA_L("MINUTE_SHORT"))
    elseif mins > 0 then
        return string.format("%d%s", mins, LGA_L("MINUTE_SHORT"))
    else
        -- Moins d'une minute
        return string.format("< 1%s", LGA_L("MINUTE_SHORT"))
    end
end
	--Gestionnaire de déplacement droite/gauche popup
    local function InitializeSmartTooltip(tooltip, hoverControl)
    local screenWidth = GuiRoot:GetWidth()
    local winCenterX = mainWin:GetLeft() + (mainWin:GetWidth() / 2)
    
    -- On calcule la position verticale du contrôle survolé par rapport à la fenêtre
    local _, hoverCenterY = hoverControl:GetCenter()
    local hoverTop = hoverCenterY - (hoverControl:GetHeight() / 2)
    local winTop = mainWin:GetTop()
    local offsetY = hoverTop - winTop
    
    if winCenterX < (screenWidth / 2) then
        -- Fenêtre à gauche -> Tooltip à droite de la FENETRE
        InitializeTooltip(tooltip, mainWin, TOPLEFT, 1, offsetY, TOPRIGHT)
    else
        -- Fenêtre à droite -> Tooltip à gauche de la FENETRE
        InitializeTooltip(tooltip, mainWin, TOPRIGHT, -1, offsetY, TOPLEFT)
    end
end

-- Fragment de scène personnalisé pour gérer la visibilité
local MyAddonFragment = ZO_SimpleSceneFragment:Subclass()
function MyAddonFragment:New(...)
    return ZO_SimpleSceneFragment.New(self, ...)
end
function MyAddonFragment:Show()
    -- On ne montre la fenêtre que si notre variable de sauvegarde l'autorise
    if MyAddon.savedVars.isVisible or MyAddon.forceShowMainWin then
        self.control:SetHidden(false)
    end
end
function MyAddonFragment:OnSceneHidden()
    if not MyAddon.forceShowMainWin then
        self.control:SetHidden(true)
    end
end

-- Fragment de scène pour le popup d'alarme
local AlarmPopupFragment = ZO_SimpleSceneFragment:Subclass()
function AlarmPopupFragment:New(control)
    return ZO_SimpleSceneFragment.New(self, control)
end
function AlarmPopupFragment:Show()
    -- Ne réaffiche le popup que s'il n'a pas été fermé par l'utilisateur ou un timer
    if (self.control.data and not self.control.data.isUserHidden) or MyAddon.forceShowAlarmPopup then
        self.control:SetHidden(false)
    end
end
function AlarmPopupFragment:OnSceneHidden()
    if not MyAddon.forceShowAlarmPopup then
        self.control:SetHidden(true)
    end
end

-- Fragment de scène pour les popups (Gestion visibilité scène)
local PopupFragment = ZO_SimpleSceneFragment:Subclass()
function PopupFragment:New(control)
    return ZO_SimpleSceneFragment.New(self, control)
end
function PopupFragment:Show()
    if (self.control.data and self.control.data.shouldBeVisible) or (MyAddon.forceShowActionPopup and self.control.data.isPreview) then
        self.control:SetHidden(false)
    end
end
function PopupFragment:OnSceneHidden()
    if not (MyAddon.forceShowActionPopup and self.control.data.isPreview) then
        self.control:SetHidden(true)
    end
end

-- Fragment de scène pour la fenêtre d'exportation
local ExportWindowFragment = ZO_SimpleSceneFragment:Subclass()
function ExportWindowFragment:New(...)
    return ZO_SimpleSceneFragment.New(self, ...)
end

function ExportWindowFragment:Show()
    -- Ne réaffiche la fenêtre que si elle a été ouverte manuellement
    if self.control.isOpenedManually then
        self.control:SetHidden(false)
    end
end

local function GetStatusIcon(entry)
    local status_not_found = "Le_Guide_de_L_Antiquaire/Textures/status_not_found.dds"
    local status_has_lead = "Le_Guide_de_L_Antiquaire/Textures/status_has_lead.dds"
    local status_acquired = "Le_Guide_de_L_Antiquaire/Textures/status_acquired.dds"
    local status_new = "Le_Guide_de_L_Antiquaire/Textures/New.dds"

    if entry.type == "fragment" then
        local fragId = tonumber(entry.fragData.antiquityId)
        if not fragId or fragId <= 0 then return status_not_found end

        if DoesAntiquityHaveLead and DoesAntiquityHaveLead(fragId) then
            if MyAddon.savedVars.recentLeads then
                for _, recentId in ipairs(MyAddon.savedVars.recentLeads) do
                    if recentId == fragId then
                        return status_new
                    end
                end
            end
            return status_has_lead
        end
        if DoesAntiquityNeedCombination and DoesAntiquityNeedCombination(fragId) then
            return status_acquired
        end
        if GetNumAntiquitiesRecovered and GetNumAntiquitiesRecovered(fragId) > 0 then
            return status_acquired
        end
        return status_not_found
    
    elseif entry.type == "item" then
        local data = entry.data
        -- Check achievement
        if data.achId and tonumber(data.achId) and tonumber(data.achId) > 0 then
            local _, _, _, _, completed = GetAchievementInfo(data.achId)
            
            if completed then return status_acquired end
        end

        -- Check stickerbook
        if data.itemLink and data.itemLink ~= "" then
            local success, pieceId = pcall(GetItemLinkItemSetCollectionPieceInfo, data.itemLink)
            if success and pieceId and pieceId > 0 and IsItemSetCollectionPieceUnlocked(pieceId) then
                return status_acquired
            end
        end

        -- Check fragments
        if data.fragments and #data.fragments > 0 then
            local numFragmentsAcquired = 0
            for _, frag in ipairs(data.fragments) do
                local fragId = tonumber(frag.antiquityId)
                if fragId and fragId > 0 then
                    if DoesAntiquityNeedCombination and DoesAntiquityNeedCombination(fragId) then
                        numFragmentsAcquired = numFragmentsAcquired + 1
                    end
                end
            end

            if numFragmentsAcquired == #data.fragments then return status_acquired end
        end

        return status_not_found
    end
    return status_not_found -- Default fallback
end

local function IsItemAcquired(data)
    -- Check achievement
    if data.achId and tonumber(data.achId) and tonumber(data.achId) > 0 then
        local _, _, _, _, completed = GetAchievementInfo(data.achId)
        if completed then return true end
    end

    -- Check stickerbook
    if data.itemLink and data.itemLink ~= "" then
        local success, pieceId = pcall(GetItemLinkItemSetCollectionPieceInfo, data.itemLink)
        if success and pieceId and pieceId > 0 and IsItemSetCollectionPieceUnlocked(pieceId) then
            return true
        end
    end

    -- Check fragments
    if data.fragments and #data.fragments > 0 then
        local numFragmentsAcquired = 0
        for _, frag in ipairs(data.fragments) do
            local fragId = tonumber(frag.antiquityId)
            if fragId and fragId > 0 then
                if DoesAntiquityNeedCombination and DoesAntiquityNeedCombination(fragId) then
                    numFragmentsAcquired = numFragmentsAcquired + 1
                end
            end
        end
        if numFragmentsAcquired == #data.fragments then return true end
    end
    return false
end

function MyAddon.BuildLeadData()
    -- Vider les anciennes données
    MyAddon.MythicItems = {}
    MyAddon.AllLeads = {}
	
    local i = GetNextAntiquityId()
    while i do
        local setId = GetAntiquitySetId(i)
        local hint = MyAddon.AntiquityHints and MyAddon.AntiquityHints[i] or {}
        local rewardId = GetAntiquityRewardId(i)
        
        -- Correction de la zone si nécessaire
        local digZoneId = GetAntiquityZoneId(i)
        local zoneId = digZoneId
        if MyAddon.FindScryDifferentZones and MyAddon.FindScryDifferentZones[i] then
            zoneId = MyAddon.FindScryDifferentZones[i]
        end
        
        -- Détermination du Type (Exhaustif)
        local typeName = LGA_L("TYPE_OTHER")
        if rewardId > 0 then
            typeName = zo_strformat("<<1>>", REWARDS_MANAGER:GetRewardContextualTypeString(rewardId))
        end
        -- Si le type est vide ou générique pour un Set, on essaie d'être plus précis
        if (typeName == "" or typeName == "Piste") and setId > 0 then
            typeName = LGA_L("TYPE_SET_MYTHIC")
        end
        
        local leadData = {
            antiquityId = i,
            name = zo_strformat("<<1>>", GetAntiquityName(i) or "Piste inconnue"),
            quality = GetAntiquityQuality(i),
            typeName = typeName, -- On stocke le type textuel
            difficulty = GetAntiquityDifficulty(i),
            zoneId = zoneId,
            digZoneId = digZoneId,
            setName = setId > 0 and zo_strformat("<<1>>", GetAntiquitySetName(setId)) or "",
            setId = setId,
            mapText = hint.mapText,
            image = hint.image,
            image2 = hint.image2,
        }
        table.insert(MyAddon.AllLeads, leadData)

        -- MODIFICATION : On prend TOUS les sets, pas seulement ceux dans Datafr.lua
        if setId > 0 then
            if not MyAddon.MythicItems[setId] then
                -- On vérifie si on a des données manuelles pour ce set
                local itemInfo = MyAddon.SetToItemInfoMap[setId] or {}
                local achId = MyAddon.SetToAchIdMap[setId] or 0
                
                -- Si pas de nom manuel, on utilise le nom du set fourni par le jeu
                local finalName = leadData.setName
                if finalName == "" then finalName = leadData.name end

                MyAddon.MythicItems[setId] = {
                    name = finalName,
                    antId = setId,
                    achId = achId,
                    itemLink = itemInfo.itemLink or "", -- Peut être vide pour les meubles/cosmétiques
                    itemId = itemInfo.itemId or 0,
                    fragments = {}
                }
            end
            table.insert(MyAddon.MythicItems[setId].fragments, leadData)
        end

        i = GetNextAntiquityId(i)
    end
end

function MyAddon.SearchForIds(searchTerm)
    if not searchTerm or searchTerm == "" then
        d("|cFF0000Erreur:|r Usage: /mythsearch <nom de l'objet>")
        return
    end
    
    d("|cFFFF00--- RECHERCHE D'ID POUR : |cFFFFFF" .. searchTerm .. "|r ---|r")
    local found = false
    local searchTermLower = string.lower(searchTerm)
    
    -- Recherche dans les Succès
    for i = 1, 6000 do
        local achName = GetAchievementInfo(i)
        if achName and achName ~= "" and string.find(string.lower(achName), searchTermLower) then
            d("SUCCÈS (|cachId|r): |c00FF00" .. i .. "|r (" .. achName .. ")")
            found = true
        end
    end

    -- Recherche dans les Antiquités
    for i = 1, 2000 do
        local antName = GetAntiquityName(i)
        if antName and antName ~= "" and string.find(string.lower(antName), searchTermLower) then
            local setId = GetAntiquitySetId(i)
            if setId and setId > 0 then
                d("TROUVÉ: |c00FFFF" .. antName .. "|r  ->  ID Fragment: |c00FF00" .. i .. "|r  |  Set ID (antId): |cFFA500" .. setId .. "|r")
                found = true
            end
        end
    end

    if not found then
        d("|cFFA500Aucun résultat pour '" .. searchTerm .. "'. Essayez un mot plus court (ex: 'chasse' au lieu de 'anneau de la chasse sauvage').|r")
    end
end

-- Helper pour savoir si un set est un équipement (Armure/Bijou)
local function IsItemGear(data)
    if not data.itemLink or data.itemLink == "" then return false end
    local equipType = GetItemLinkEquipType(data.itemLink)
    return equipType ~= EQUIP_TYPE_NONE
end

-- Fonction de recherche intelligente pour trouver les infos manquantes (Link/Collectible)
function MyAddon.GetResolvedItemData(data)
    -- Si on a déjà cherché, on retourne le résultat en cache
    if MyAddon.ResolvedCache and MyAddon.ResolvedCache[data.antId] then return MyAddon.ResolvedCache[data.antId] end
    
    local res = {}
    local nameLower = CleanText(data.name)
    
    -- 1. Recherche dans les Collections (Montures, Emotes, etc.)
    -- On parcourt les IDs de collection (c'est rapide, max ~12000)
    for id = 1, 15000 do -- On augmente la plage de recherche
        local cName = GetCollectibleName(id)
        if cName and cName ~= "" and CleanText(cName) == nameLower then
            res.collectibleId = id
            res.icon = GetCollectibleIcon(id)
            break
        end
    end

    -- 2. Si pas trouvé, recherche dans les Succès (Récompense d'item)
    if not res.collectibleId then
        for id = 1, 10000 do -- On augmente la plage de recherche
            local aName = GetAchievementInfo(id)
            if aName and aName ~= "" and CleanText(aName) == nameLower then
                local hasReward, rewardLink = GetAchievementRewardItem(id)
                if hasReward and rewardLink then
                    res.itemLink = rewardLink
                    res.icon = GetItemLinkInfo(rewardLink)
                    break
                end
            end
        end
    end

    -- On met en cache le résultat (même si vide) pour ne pas re-chercher
    if not MyAddon.ResolvedCache then MyAddon.ResolvedCache = {} end
    MyAddon.ResolvedCache[data.antId] = res
    return res
end

-- Fonction pour remplir l'infobulle riche des fragments (Images + Texte)
local function FillFragmentTooltip(tooltip, frag, parentName)
    -- Utilisation de la fonction native du jeu pour afficher l'infobulle de la piste
    -- Cela récupère automatiquement le nom, la description, la zone, la difficulté, etc.
    tooltip:SetAntiquityLead(frag.antiquityId)
    
    -- Ajout du statut personnalisé en bas (Acquis / Piste possédée / Non trouvé)
    local status = GetFragmentStatus(frag.antiquityId)
    if status and status ~= "" then
        tooltip:AddVerticalPadding(10)
        tooltip:AddLine(LGA_L("STATUS_LABEL") .. status, "ZoFontGameBold", 1, 1, 1, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
    end
end

local function ClearFragmentTooltip(tooltip)
    ClearTooltip(tooltip)
    if tooltip:GetNamedChild("CustomImage1") then tooltip:GetNamedChild("CustomImage1"):SetHidden(true) end
    if tooltip:GetNamedChild("CustomImage2") then tooltip:GetNamedChild("CustomImage2"):SetHidden(true) end
end

-- Popup d'action pour les pistes
local actionPopupPool = {}
local MAX_POPUPS = 5

function MyAddon.StopPopupTimer(popup)
    if popup and popup.data.timerId then
        zo_removeCallLater(popup.data.timerId)
        popup.data.timerId = nil
    end
end

function MyAddon.SavePopup(popup)
    if not MyAddon.savedVars then return end
    if not MyAddon.savedVars.popupPositions then MyAddon.savedVars.popupPositions = {} end
    
    local index = popup.data.index
    local antId = nil
    -- Modification : On sauvegarde l'ID si la fenêtre est censée être visible (pour le ReloadUI)
    -- et non pas seulement si elle est actuellement affichée (car elle est cachée lors du déchargement)
    if popup.data.shouldBeVisible then antId = popup.data.antId end
	
    MyAddon.savedVars.popupPositions[index] = {
        left = popup:GetLeft(),
        top = popup:GetTop(),
        isFixed = popup.data.isFixed,
        antId = antId,
        opIndex = popup.data.opIndex or 1
    }
end
    --Gestion popup
function MyAddon.CreateSingleActionPopup(index)
    local popup = wm:CreateTopLevelWindow("Le_Guide_de_L_Antiquaire_ActionPopup" .. index)
    popup:SetDimensions(300, 140) -- Largeur augmentée pour éviter le chevauchement
    popup:SetHidden(true)
    popup:SetDrawTier(DT_LOW)
    popup:SetDrawLayer(DL_BACKGROUND)
    popup:SetDrawLevel(5)
    popup:SetClampedToScreen(true)
    popup:SetMouseEnabled(true)
    popup:SetMovable(true) -- Par défaut déplaçable
    

    -- Nettoyage à la fermeture
    popup:SetHandler("OnEffectivelyHidden", function() 
        MyAddon.StopPopupTimer(popup)
        MyAddon.SavePopup(popup)		
    end)
    popup:SetHandler("OnMoveStop", function()
        MyAddon.SavePopup(popup)	
    end)
    
    local bg = wm:CreateControl("$(parent)Bg", popup, CT_BACKDROP)
    bg:SetAnchorFill(popup)
    local c = (MyAddon.savedVars and MyAddon.savedVars.popupBgColor) or {r=0, g=0, b=0}
    bg:SetCenterColor(c.r, c.g, c.b, 0.9)
    -- La couleur et la texture de la bordure sont maintenant gérées par UpdateFrameStyles
    bg:SetEdgeTexture("", 1, 1, 0)

    -- 1. Boutons de contrôle (Créés après le fond pour être visibles)
    local closeBtn = wm:CreateControl("$(parent)Close", popup, CT_BUTTON) 
    closeBtn:SetDimensions(20, 20)
    closeBtn:SetAnchor(TOPRIGHT, popup, TOPRIGHT, -5, 5)
    closeBtn:SetNormalTexture("EsoUI/art/buttons/decline_up.dds")
    closeBtn:SetHandler("OnClicked", function() 
        MyAddon.StopPopupTimer(popup)
        popup.data.shouldBeVisible = false
        popup:SetHidden(true) 
    end)

    -- Bouton Move/Fixe (M/F) - Pour l'ancrage
    local moveBtn = wm:CreateControl("$(parent)Move", popup, CT_BUTTON)
    moveBtn:SetDimensions(25, 22)
    moveBtn:SetAnchor(TOPRIGHT, closeBtn, TOPLEFT, -5, 0)
    moveBtn:SetFont(MyAddon:GetFontString("popup"))
    moveBtn:SetText(LGA_L("BTN_MOVE_LABEL")) -- M par défaut
    moveBtn:SetNormalFontColor(0.2, 1, 0.2, 1) -- Vert

    -- Logique Move/Fixe
    moveBtn:SetHandler("OnClicked", function()
        popup.data.isFixed = not popup.data.isFixed
        popup:SetMovable(not popup.data.isFixed)
        
        if popup.data.isFixed then -- On fixe la fenêtre
            moveBtn:SetText(LGA_L("BTN_FIXED_LABEL")) -- F
            moveBtn:SetNormalFontColor(1, 0.2, 0.2, 1) -- Rouge
        else
            moveBtn:SetText(LGA_L("BTN_MOVE_LABEL")) -- M
            moveBtn:SetNormalFontColor(0.2, 1, 0.2, 1) -- Vert
        end
        if MyAddon.SavePopup then MyAddon.SavePopup(popup) end
    end)
    
    -- Bouton Opacité
    local opacityBtn = wm:CreateControl("$(parent)Opacity", popup, CT_BUTTON)
    opacityBtn:SetDimensions(45, 20)
    opacityBtn:SetAnchor(TOPLEFT, popup, TOPLEFT, 5, 5)
    opacityBtn:SetFont(MyAddon:GetFontString("popup"))
    opacityBtn:SetText("100%")
    opacityBtn:SetHandler("OnClicked", function()
        popup.data.opIndex = (popup.data.opIndex % #OPACITIES) + 1
        local newAlpha = OPACITIES[popup.data.opIndex]
        bg:SetAlpha(newAlpha)
        opacityBtn:SetText(string.format("%d%%", newAlpha * 100))
        MyAddon.SavePopup(popup)
    end)

    local title = wm:CreateControl("$(parent)Title", popup, CT_LABEL)
    -- On baisse le titre pour éviter la croix et on centre bien
    title:SetAnchor(TOPLEFT, popup, TOPLEFT, 10, 25)
    title:SetAnchor(TOPRIGHT, popup, TOPRIGHT, -10, 25)
    title:SetFont(MyAddon:GetFontString("popup"))
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    title:SetMaxLineCount(2)
    title:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    
    -- Label Zone (Cliquable)
    local zoneBtn = wm:CreateControl("$(parent)ZoneBtn", popup, CT_BUTTON)
    zoneBtn:SetHeight(20)
    zoneBtn:SetFont(MyAddon:GetFontString("popup"))

    -- Label Source Zone (Cliquable)
    local sourceZoneBtn = wm:CreateControl("$(parent)SourceZoneBtn", popup, CT_BUTTON)
    sourceZoneBtn:SetHeight(20)
    sourceZoneBtn:SetFont(MyAddon:GetFontString("popup"))
    
    -- Label Timer
    local timerLabel = wm:CreateControl("$(parent)TimerLabel", popup, CT_LABEL)
    timerLabel:SetFont(MyAddon:GetFontString("popup"))
    timerLabel:SetColor(1, 0.8, 0, 1) -- Jaune/Or
    timerLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    -- Label pour le texte de la carte (Indice)
    local hintLabel = wm:CreateControl("$(parent)Hint", popup, CT_LABEL)
    hintLabel:SetWidth(280)
    hintLabel:SetFont(MyAddon:GetFontString("popup"))
    hintLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    hintLabel:SetColor(0.9, 0.9, 0.9, 1)
    
    -- Fond pour le bouton Sonder (pour la bordure)
    local btnScryBg = wm:CreateControl("$(parent)BtnScryBg", popup, CT_BACKDROP)
    btnScryBg:SetDimensions(70, 25)
    btnScryBg:SetAnchor(TOP, title, BOTTOM, -60, 15)
    btnScryBg:SetCenterColor(0, 0, 0, 0) -- Fond transparent
    btnScryBg:SetEdgeColor(0.4, 0.4, 0.4, 1)
    btnScryBg:SetEdgeTexture("", 1, 1, 1)

    -- Bouton Sonder (placé par-dessus son fond pour garantir le clic)
    local btnScry = wm:CreateControl("$(parent)BtnScry", popup, CT_BUTTON)
    btnScry:SetAnchorFill(btnScryBg)
    btnScry:SetText(LGA_L("Sonder"))
    btnScry:SetFont(MyAddon:GetFontString("popup"))

    -- Fond pour le bouton Carte
    local btnMapBg = wm:CreateControl("$(parent)BtnMapBg", popup, CT_BACKDROP)
    btnMapBg:SetDimensions(70, 25)
    btnMapBg:SetAnchor(TOP, title, BOTTOM, 80, 15)
    btnMapBg:SetCenterColor(0, 0, 0, 0) -- Fond transparent
    btnMapBg:SetEdgeColor(0.4, 0.4, 0.4, 1)
    btnMapBg:SetEdgeTexture("", 1, 1, 1)

    -- Bouton Carte (placé par-dessus son fond)
    local btnMap = wm:CreateControl("$(parent)BtnMap", popup, CT_BUTTON)
    btnMap:SetAnchorFill(btnMapBg)
    btnMap:SetText(LGA_L("Carte"))
    btnMap:SetFont(MyAddon:GetFontString("popup"))

    -- Fond pour le bouton Source (NOUVEAU)
    local btnSourceBg = wm:CreateControl("$(parent)BtnSourceBg", popup, CT_BACKDROP)
    btnSourceBg:SetDimensions(70, 25)
    btnSourceBg:SetCenterColor(0, 0, 0, 0) -- Fond transparent
    btnSourceBg:SetEdgeColor(0.4, 0.4, 0.4, 1)
    btnSourceBg:SetEdgeTexture("", 1, 1, 1)
    btnSourceBg:SetHidden(true) -- Caché par défaut

    -- Bouton Source (NOUVEAU)
    local btnSource = wm:CreateControl("$(parent)BtnSource", popup, CT_BUTTON)
    btnSource:SetAnchorFill(btnSourceBg)
    btnSource:SetText(LGA_L("SOURCE_BTN"))
    btnSource:SetFont(MyAddon:GetFontString("popup"))
    btnSource:SetHidden(true) -- Caché par défaut

    -- Fond pour le bouton Auto-Oeil (NOUVEAU)
    local btnAutoEyeBg = wm:CreateControl("$(parent)BtnAutoEyeBg", popup, CT_BACKDROP)
    btnAutoEyeBg:SetDimensions(25, 25)
    btnAutoEyeBg:SetCenterColor(0, 0, 0, 0) -- Fond transparent
    btnAutoEyeBg:SetEdgeColor(0.4, 0.4, 0.4, 1)
    btnAutoEyeBg:SetEdgeTexture("", 1, 1, 1)
    btnAutoEyeBg:SetHidden(true) -- Caché par défaut

    -- Bouton Auto-Oeil (NOUVEAU)
    local btnAutoEye = wm:CreateControl("$(parent)BtnAutoEye", popup, CT_BUTTON)
    btnAutoEye:SetAnchorFill(btnAutoEyeBg)
    btnAutoEye:SetHidden(true) -- Caché par défaut


    local infoLabel = wm:CreateControl("$(parent)Info", popup, CT_LABEL)
    infoLabel:SetAnchor(TOP, title, BOTTOM, 0, 50) -- Ancré au centre sous les boutons
    infoLabel:SetWidth(280)
    infoLabel:SetFont(MyAddon:GetFontString("popup"))
    infoLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    infoLabel:SetColor(1, 0, 0, 1)
    
    local btnSkill = wm:CreateControl("$(parent)BtnSkill", popup, CT_BUTTON)
    btnSkill:SetDimensions(280, 25)
    btnSkill:SetAnchor(TOP, infoLabel, BOTTOM, 0, 5)
    btnSkill:SetText(LGA_L("GO_TO_CIRCLE_BTN"))
    btnSkill:SetFont(MyAddon:GetFontString("popup"))
    btnSkill:SetHidden(true)
    local btnSkillBg = wm:CreateControl("$(parent)Bg", btnSkill, CT_BACKDROP)
    btnSkillBg:SetAnchorFill(btnSkill)
    btnSkillBg:SetCenterColor(0.2, 0.2, 0.2, 1)
    btnSkillBg:SetEdgeColor(0.4, 0.4, 0.4, 1)
    btnSkillBg:SetEdgeTexture("", 1, 1, 1)
    btnSkillBg:SetDrawLayer(DL_BACKGROUND)
    btnSkillBg:SetMouseEnabled(false)

    popup.data = { 
        title = title, hintLabel = hintLabel, btnScry = btnScry, btnMap = btnMap, infoLabel = infoLabel, 
        btnSource = btnSource, btnSourceBg = btnSourceBg,
        btnAutoEye = btnAutoEye, btnAutoEyeBg = btnAutoEyeBg, btnSkill = btnSkill, btnScryBg = btnScryBg, btnMapBg = btnMapBg, zoneBtn = zoneBtn, sourceZoneBtn = sourceZoneBtn, timerLabel = timerLabel,
        isFixed = false, moveBtn = moveBtn,
        shownTime = 0, antId = nil, index = index,
        shouldBeVisible = false,
        opIndex = 1, isPreview = false
    }

    -- Gestion des scènes pour que le popup disparaisse avec l'interface (Inventaire, Carte, etc.)
    local fragment = PopupFragment:New(popup)
    SCENE_MANAGER:GetScene("hud"):AddFragment(fragment)
    SCENE_MANAGER:GetScene("hudui"):AddFragment(fragment)

    return popup
end

function MyAddon.ShowItemPopup(control, entry, forceIndex)
    -- 1. Gestion du Pool de Popups (Max 5)
    local visibleCount = 0
    for _, p in ipairs(actionPopupPool) do
        if not p:IsHidden() then visibleCount = visibleCount + 1 end
    end

    -- Vérification si un popup pour cet item est déjà ouvert
    local antIdToCheck = tonumber(entry.fragData.antiquityId)
    for _, p in ipairs(actionPopupPool) do
        if not p:IsHidden() and p.data.antId == antIdToCheck then
            -- Si un popup est déjà ouvert pour cette piste, on le ferme.
            MyAddon.StopPopupTimer(p)
            p.data.shouldBeVisible = false
            p:SetHidden(true)
            return -- On arrête l'exécution ici.
        end
    end

    -- Limite de 5
    if not forceIndex and visibleCount >= MAX_POPUPS then
        ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, LGA_L("MAX_POPUPS_REACHED"))
        return
    end

    -- Trouver un popup libre
    local actionPopup
    if forceIndex then
        actionPopup = actionPopupPool[forceIndex]
    else
        for _, p in ipairs(actionPopupPool) do
            if p:IsHidden() then actionPopup = p; break end
        end
    end
    
    if not actionPopup then return end -- Sécurité

    -- 4. Vérification des données d'entrée (Entry)
    if not entry or not entry.fragData then return end

    local data = entry.fragData
    -- 5. Vérification de l'ID Antiquité
    if not data.antiquityId then return end
    local antId = tonumber(data.antiquityId)
    if not antId or antId <= 0 then return end
    actionPopup.data.antId = antId

    -- 6. Vérification de la fenêtre principale (Ancrage)
    if not mainWin then return end

    -- GESTION DE LA POSITION ET DE L'ÉTAT (Sauvegardés ou Défaut)
    local index = actionPopup.data.index
    local savedPos = MyAddon.savedVars.popupPositions and MyAddon.savedVars.popupPositions[index]
    local bg = actionPopup:GetNamedChild("Bg")
    local opacityBtn = actionPopup:GetNamedChild("Opacity")

    if savedPos then
        actionPopup.data.isFixed = savedPos.isFixed
        actionPopup:SetMovable(not savedPos.isFixed)
        actionPopup.data.opIndex = savedPos.opIndex or 1

        -- Restauration visuelle du bouton
        if actionPopup.data.moveBtn then
            if savedPos.isFixed then
                actionPopup.data.moveBtn:SetText(LGA_L("BTN_FIXED_LABEL"))
                actionPopup.data.moveBtn:SetNormalFontColor(1, 0.2, 0.2, 1)
            else
                actionPopup.data.moveBtn:SetText(LGA_L("BTN_MOVE_LABEL"))
                actionPopup.data.moveBtn:SetNormalFontColor(0.2, 1, 0.2, 1)
            end
        end
        
        actionPopup:ClearAnchors()
        actionPopup:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, savedPos.left, savedPos.top)
    else
        -- Comportement par défaut (Centré)
        actionPopup.data.isFixed = false
        actionPopup.data.opIndex = 1
        actionPopup:SetMovable(true)        
        if actionPopup.data.moveBtn then 
            actionPopup.data.moveBtn:SetText(LGA_L("BTN_MOVE_LABEL"))
            actionPopup.data.moveBtn:SetNormalFontColor(0.2, 1, 0.2, 1)
        end

        actionPopup:ClearAnchors()
        actionPopup:SetAnchor(CENTER, mainWin, CENTER, 0, 0)
    end

    -- Application de l'opacité (commun aux deux cas)
    local alpha = OPACITIES[actionPopup.data.opIndex]
    if bg then bg:SetAlpha(alpha) end
    if opacityBtn then opacityBtn:SetText(string.format("%d%%", alpha * 100)) end

    -- NOUVEAU: Mise à jour des polices du popup à chaque affichage
    local popupFontString = MyAddon:GetFontString("popup")
    local d = actionPopup.data
    d.title:SetFont(popupFontString)
    d.zoneBtn:SetFont(popupFontString)
    d.sourceZoneBtn:SetFont(popupFontString)
    d.timerLabel:SetFont(popupFontString)
    d.hintLabel:SetFont(popupFontString)
    d.btnScry:SetFont(popupFontString)
    d.btnMap:SetFont(popupFontString)
    d.btnSource:SetFont(popupFontString)
    d.infoLabel:SetFont(popupFontString)
    d.btnSkill:SetFont(popupFontString)
    d.moveBtn:SetFont(popupFontString)
    actionPopup:GetNamedChild("Opacity"):SetFont(popupFontString)

    actionPopup.data.shouldBeVisible = true
    actionPopup:SetHidden(false)
    actionPopup:BringWindowToTop()
    
    -- Définition sécurisée du titre et de sa couleur pour éviter tout crash
    local titleLabel = actionPopup.data.title
    if not titleLabel then return end -- Sécurité supplémentaire

    local name = data.name or "Piste inconnue"
    local quality = data.quality or 0

    if quality == 5 then -- Qualité Mythique (Orange)
        titleLabel:SetText("|cFF5500" .. name .. "|r")
    else
        local qualityIndex = quality + 1
        if qualityIndex > 5 then qualityIndex = 5 end -- On s'assure de ne pas dépasser l'index 5 (Légendaire)
        local color = GetItemQualityColor(qualityIndex)
        if color and color.Colorize then
            titleLabel:SetText(color:Colorize(name))
        else
            titleLabel:SetText(name) -- Fallback si la couleur est invalide ou n'a pas la méthode Colorize
        end
    end
    
    -- --- RESTAURATION FONCTIONNELLE ET HAUTEUR DYNAMIQUE ---
    
    -- Fonction locale pour sécuriser les appels API (évite le crash si une fonction n'existe pas)
    local function SafeCall(funcName, ...)
        local f = _G[funcName]
        if type(f) ~= "function" then return nil end
        local ok, res = pcall(f, ...)
        if ok then return res end
        return nil
    end

    -- Fonction locale pour afficher l'infobulle du popup (Dessus ou Dessous)
    local function ShowPopupTooltip(control, title, text)
        local centerY = control:GetTop() + control:GetHeight() / 2
        local screenHeight = GuiRoot:GetHeight()
        
        if centerY < screenHeight / 2 then
            -- Bouton dans la moitié haute, infobulle EN DESSOUS
            InitializeTooltip(InformationTooltip, control, TOP, 0, 5, BOTTOM)
        else
            -- Bouton dans la moitié basse, infobulle AU-DESSUS
            InitializeTooltip(InformationTooltip, control, BOTTOM, 0, -5, TOP)
        end
        
        InformationTooltip:AddLine(title, "ZoFontWinH2")
        InformationTooltip:AddLine(text, "ZoFontGame")
    end

    -- Récupération des contrôles
    local btnScry = actionPopup.data.btnScry
    local btnScryBg = actionPopup.data.btnScryBg
    local btnMap = actionPopup.data.btnMap
    local btnMapBg = actionPopup.data.btnMapBg
    local btnSource = actionPopup.data.btnSource -- NOUVEAU
    local btnSourceBg = actionPopup.data.btnSourceBg -- NOUVEAU
    local btnAutoEye = actionPopup.data.btnAutoEye -- NOUVEAU
    local btnAutoEyeBg = actionPopup.data.btnAutoEyeBg -- NOUVEAU
    local infoLabel = actionPopup.data.infoLabel
    local hintLabel = actionPopup.data.hintLabel
    local btnSkill = actionPopup.data.btnSkill
    local zoneBtn = actionPopup.data.zoneBtn
    local sourceZoneBtn = actionPopup.data.sourceZoneBtn
    local timerLabel = actionPopup.data.timerLabel

    if not btnScry or not btnMap or not infoLabel then return end

    -- Réinitialisation de la visibilité
    btnScry:SetHidden(false); btnScryBg:SetHidden(false)
    btnMap:SetHidden(false); btnMapBg:SetHidden(false)
    btnSource:SetHidden(true); btnSourceBg:SetHidden(true)
    btnAutoEye:SetHidden(true); btnAutoEyeBg:SetHidden(true)
    btnSkill:SetHidden(true) -- Caché par défaut

    -- Logique Métier (Sécurisée)
    local findZoneId = data.zoneId
    local digZoneId = GetAntiquityZoneId(antId)
    
    local hasLead = SafeCall("DoesAntiquityHaveLead", antId)
    local isRecovered = false
    local recoveredCount = SafeCall("GetNumAntiquitiesRecovered", antId)
    if type(recoveredCount) == "number" and recoveredCount > 0 then isRecovered = true
    elseif SafeCall("DoesAntiquityNeedCombination", antId) then isRecovered = true end

    -- Le bouton est cliquable si on a la piste et qu'elle n'est pas déjà récupérée
    local isScryButtonClickable = hasLead and not isRecovered
    btnScry:SetEnabled(isScryButtonClickable)

    -- Logique du texte d'information et du style du bouton
    local reason = ""
    local canScryNow = false

    if isScryButtonClickable then
        -- On utilise la fonction API la plus fiable pour déterminer l'état
        local failureReason = SafeCall("GetAntiquityScryFailureReason", antId)

        if failureReason == SCRY_FAILURE_REASON_NONE then
            canScryNow = true
        else
            -- On construit le message d'erreur basé sur la raison
            if failureReason == SCRY_FAILURE_REASON_INCORRECT_ZONE then
                local antZoneId = SafeCall("GetAntiquityZoneId", antId)
                local zoneName = antZoneId and SafeCall("GetZoneNameById", antZoneId)
                if zoneName then zoneName = zo_strformat("<<C:1>>", zoneName) else zoneName = "une autre zone" end
                reason = LGA_L("REASON_WRONG_ZONE") .. zoneName
            elseif failureReason == SCRY_FAILURE_REASON_NOT_ENOUGH_SKILL then
                reason = LGA_L("REASON_NO_SKILL")
            elseif failureReason == SCRY_FAILURE_REASON_META_ANTIQUTY_NOT_COMPLETE then
                reason = LGA_L("REASON_META_MISSING")
            else
                reason = LGA_L("REASON_GENERIC") -- Raison générique
            end
        end
    elseif isRecovered then
        reason = LGA_L("REASON_RECOVERED")
    elseif not hasLead then
        reason = LGA_L("REASON_NO_LEAD")
    end

    -- Mise à jour du style du bouton en fonction de l'état
    btnScry:SetText(LGA_L("Sonder"))
    if canScryNow then
        btnScry:SetNormalFontColor(1, 1, 1, 1); btnScryBg:SetEdgeColor(0.4, 0.4, 0.4, 1) -- Blanc / Normal
    elseif isScryButtonClickable then
        btnScry:SetNormalFontColor(1, 0.6, 0, 1); btnScryBg:SetEdgeColor(0.6, 0.4, 0, 1) -- Orange / Avertissement
    else
        btnScry:SetText(LGA_L("SCRY_UNAVAILABLE")); btnScry:SetNormalFontColor(0.5, 0.5, 0.5, 1); btnScryBg:SetEdgeColor(0.2, 0.2, 0.2, 1) -- Gris / Désactivé
    end

    -- Handlers (Actions)
	btnScry:SetHandler("OnClicked", function()
        if SafeCall("GetAntiquityScryFailureReason", antId) == SCRY_FAILURE_REASON_INCORRECT_ZONE then
        end

        if AntiquityModule and AntiquityModule.Sonder then
            AntiquityModule:Sonder(antId)
        end end)
    btnScry:SetHandler("OnMouseEnter", function(self)
        ShowPopupTooltip(self, LGA_L("SCRY_TOOLTIP_TITLE"), LGA_L("SCRY_TOOLTIP_TEXT"))
    end)
    btnScry:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)

    btnMap:SetHandler("OnClicked", function()
        if AntiquityModule and AntiquityModule.AfficherCarte then AntiquityModule:AfficherCarte(antId) end end)
    btnMap:SetHandler("OnMouseEnter", function(self)
        ShowPopupTooltip(self, LGA_L("MAP_TOOLTIP_TITLE"), LGA_L("MAP_TOOLTIP_TEXT"))
    end)
    btnMap:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)

    infoLabel:SetText(reason)
    infoLabel:SetHidden(reason == "")

    -- NOUVEAU: Gestion du bouton Auto-Oeil
    btnAutoEye:SetHidden(not isScryButtonClickable)
    btnAutoEyeBg:SetHidden(not isScryButtonClickable)

    if isScryButtonClickable then
        local function updateAutoEyeVisual()
            local texture = MyAddon.savedVars.autoEyeEnabled and "Le_Guide_de_L_Antiquaire/Textures/status_has_lead.dds" or "Le_Guide_de_L_Antiquaire/Textures/status_has_lead_No.dds"
            btnAutoEye:SetNormalTexture(texture)
        end
        updateAutoEyeVisual()

        btnAutoEye:SetHandler("OnClicked", function()
            MyAddon.savedVars.autoEyeEnabled = not MyAddon.savedVars.autoEyeEnabled
            updateAutoEyeVisual()
            if MyAddon.SettingsPanel then CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", MyAddon.SettingsPanel) end
        end)
        btnAutoEye:SetHandler("OnMouseEnter", function(self)
            ShowPopupTooltip(self, LGA_L("EYE_TOOLTIP_TITLE"), LGA_L("EYE_TOOLTIP_TEXT"))
        end)
        btnAutoEye:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)
    end
    -- NOUVEAU: Logique pour le bouton Source
    local showSourceButton = (findZoneId and digZoneId and findZoneId > 0 and digZoneId > 0 and findZoneId ~= digZoneId and findZoneId < 101010)
    
    btnSource:SetHidden(not showSourceButton)
    btnSourceBg:SetHidden(not showSourceButton)

    if showSourceButton then
        btnSource:SetHandler("OnClicked", function()
            if AntiquityModule and AntiquityModule.AfficherZoneCarte then
                AntiquityModule:AfficherZoneCarte(findZoneId)
            end
        end)
        btnSource:SetHandler("OnMouseEnter", function(self)
            ShowPopupTooltip(self, LGA_L("SOURCE_TOOLTIP_TITLE"), LGA_L("SOURCE_TOOLTIP_TEXT"))
        end)
        btnSource:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)
    end

    -- CALCUL DE LA HAUTEUR DYNAMIQUE (Extensible)
	--Récupération des infos du datafr.lua
    -- On récupère le texte de mapText en priorité depuis les hints chargés (langue actuelle)
    local mapText = ""
    if MyAddon.AntiquityHints and MyAddon.AntiquityHints[antId] and MyAddon.AntiquityHints[antId].mapText then
        mapText = MyAddon.AntiquityHints[antId].mapText
    elseif data.mapText then
        mapText = data.mapText
    end
    
	local itemInfos = MyAddon.SetToItemInfoMap and MyAddon.SetToItemInfoMap[data.setId]
    -- Correction pour afficher la zone de fouille et non la zone de découverte
    local zoneId = GetAntiquityZoneId(antId)
    -- --- RESTAURATION DE L'ANCIENNE MISE EN PAGE ---
    local currentY = 25 + actionPopup.data.title:GetHeight() + 10  -- Padding haut (augmenté pour la croix) + Titre
    local lastElement = actionPopup.data.title
    
    -- AJOUT TIMER (Mise à jour auto)
    local function UpdateTimer()
        local remaining = GetAntiquityLeadTimeRemainingSeconds(antId)
        if remaining and remaining > 0 and remaining < 2592000000 then -- < 30 jours (approx) pour éviter l'infini
            local timeStr = MyAddon:FormatTime(remaining)
            timerLabel:SetText(LGA_L("EXPIRE_IN") .. timeStr)
            timerLabel:SetHidden(false)
            return true
        else
            timerLabel:SetHidden(true)
            return false
        end
    end

    actionPopup.data.UpdateTimer = UpdateTimer -- Sauvegarde pour mise à jour langue

    if UpdateTimer() then
        timerLabel:ClearAnchors()
        timerLabel:SetAnchor(TOP, lastElement, BOTTOM, 0, 0)
        lastElement = timerLabel
        currentY = currentY + timerLabel:GetTextHeight() + 5
        -- Actualisation toutes les minutes (60000ms)
        EVENT_MANAGER:RegisterForUpdate("LGA_PopupTimer" .. actionPopup.data.index, 60000, UpdateTimer)
    else
        EVENT_MANAGER:UnregisterForUpdate("LGA_PopupTimer" .. actionPopup.data.index)
		timerLabel:SetHidden(true)
    end

    -- Positionnement des boutons sous le titre
    local buttonsBottomElement = btnScryBg

    -- On réduit la taille des boutons texte
    btnSourceBg:SetDimensions(70, 25)
    btnMapBg:SetDimensions(70, 25)
    btnScryBg:SetDimensions(70, 25)
    btnAutoEyeBg:SetDimensions(25, 25) -- Bouton icône

    -- Ancrage relatif
    btnScryBg:ClearAnchors()
    btnMapBg:ClearAnchors()
    btnSourceBg:ClearAnchors()
    btnAutoEyeBg:ClearAnchors()

    local textXOffset = 0

    if showSourceButton then
        -- Disposition à 4 boutons, centrée sur l'espace entre Map et Scry
        btnMapBg:SetAnchor(TOP, lastElement, BOTTOM, -15, 10)
        btnSourceBg:SetAnchor(RIGHT, btnMapBg, LEFT, -5, 0)
        btnScryBg:SetAnchor(LEFT, btnMapBg, RIGHT, 5, 0)
        btnAutoEyeBg:SetAnchor(LEFT, btnScryBg, RIGHT, 5, 0)
        textXOffset = -55
    else
        -- Disposition à 3 boutons, centrée sur le bouton Sonder
        btnScryBg:SetAnchor(TOP, lastElement, BOTTOM, 30, 10)
        btnMapBg:SetAnchor(RIGHT, btnScryBg, LEFT, -5, 0)
        btnAutoEyeBg:SetAnchor(LEFT, btnScryBg, RIGHT, 5, 0)
        textXOffset = -25
    end
    lastElement = btnScryBg -- L'élément de référence est maintenant le bas des boutons
    currentY = currentY + 35 -- Hauteur boutons + marge
    
    -- Affichage du MapText (Indice) - Maintenant sous les boutons
    if mapText ~= "" then
        hintLabel:SetHidden(false)
        hintLabel:SetText(mapText)
        hintLabel:ClearAnchors()
        hintLabel:SetAnchor(TOP, lastElement, BOTTOM, textXOffset, 10) -- Ancré sous les boutons
        lastElement = hintLabel
        textXOffset = 0
        currentY = currentY + hintLabel:GetTextHeight() + 10
    else
        hintLabel:SetHidden(true)
    end

    -- AJOUT SOURCE ZONE (Cliquable)
    if showSourceButton and findZoneId and findZoneId > 0 and sourceZoneBtn then
        local sourceZoneName = GetSpecialZoneName(findZoneId)
        sourceZoneBtn:SetHidden(false)
        sourceZoneBtn:SetText("|c88FFFF" .. LGA_L("SOURCE_BTN") .. ": " .. zo_strformat("<<C:1>>", sourceZoneName) .. "|r")
        sourceZoneBtn:SetWidth(280)
        sourceZoneBtn:ClearAnchors()
        sourceZoneBtn:SetAnchor(TOP, lastElement, BOTTOM, textXOffset, 5)
        sourceZoneBtn:SetHandler("OnClicked", function() 
            if AntiquityModule and AntiquityModule.AfficherZoneCarte then AntiquityModule:AfficherZoneCarte(findZoneId) end 
        end)
        lastElement = sourceZoneBtn
        textXOffset = 0
        currentY = currentY + 20 + 5
    elseif sourceZoneBtn then
        sourceZoneBtn:SetHidden(true)
    end

    -- AJOUT ZONE (Cliquable)
    if zoneId and zoneId > 0 then
        local zoneName = GetSpecialZoneName(zoneId)
        zoneBtn:SetHidden(false)
        zoneBtn:SetText("|c4488FF" .. zo_strformat("<<C:1>>", zoneName) .. "|r") -- Bleu clair
        zoneBtn:SetWidth(280)
        zoneBtn:ClearAnchors()
        -- Ancrage sous l'élément précédent (indice ou boutons)
        zoneBtn:SetAnchor(TOP, lastElement, BOTTOM, textXOffset, 5)
        zoneBtn:SetHandler("OnClicked", function() 
            if AntiquityModule and AntiquityModule.AfficherCarte then AntiquityModule:AfficherCarte(antId) end 
        end)
        lastElement = zoneBtn
        textXOffset = 0
        currentY = currentY + 20 + 5
    else
        zoneBtn:SetHidden(true)
    end

    -- Ajout hauteur Info Label si visible
    if reason ~= "" then
        infoLabel:ClearAnchors()
        -- Ancrage sous l'élément précédent (zone, indice ou boutons)
        infoLabel:SetAnchor(TOP, lastElement, BOTTOM, textXOffset, 5)
        lastElement = infoLabel
        textXOffset = 0
        currentY = currentY + infoLabel:GetTextHeight() + 10
    end
    
    -- Gestion du lien (Item Link) pour éviter le crash "Duplicate Name"
    local linkLabel = actionPopup:GetNamedChild("linkLabel")
    if not linkLabel then
        linkLabel = wm:CreateControl("$(parent)linkLabel", actionPopup, CT_LABEL)
        linkLabel:SetFont("ZoFontGame")
        linkLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        linkLabel:SetWidth(280)
    end

    if itemInfos and itemInfos.itemLink then
        linkLabel:SetHidden(false)
        linkLabel:SetText(itemInfos.itemLink)
        linkLabel:ClearAnchors()
        linkLabel:SetAnchor(TOP, lastElement, BOTTOM, textXOffset, 10)
        lastElement = linkLabel
        textXOffset = 0
        currentY = currentY + linkLabel:GetHeight() + 10
    else
        linkLabel:SetHidden(true)
    end

    currentY = currentY + 10 -- Marge finale
    actionPopup:SetHeight(math.min(currentY, 450))
    if MyAddon.SavePopup then MyAddon.SavePopup(actionPopup) end	
end

-- ==========================================================
-- SYSTÈME D'ALARME D'EXPIRATION
-- ==========================================================

function MyAddon:SaveAlarmPopupState()
    if not alarmDisplayPopup or not MyAddon.savedVars then return end
    MyAddon.savedVars.alarmDisplayPopupPosition = { left = alarmDisplayPopup:GetLeft(), top = alarmDisplayPopup:GetTop() }
    MyAddon.savedVars.alarmPopupIsFixed = alarmDisplayPopup.data.isFixed
    MyAddon.savedVars.alarmPopupOpacityIndex = alarmDisplayPopup.data.opIndex
end

function MyAddon:CreateAlarmDisplayPopup()
    alarmDisplayPopup = wm:CreateTopLevelWindow("Le_Guide_de_L_Antiquaire_AlarmDisplayPopup")
    alarmDisplayPopup:SetDimensions(450, 200)
    alarmDisplayPopup:SetHidden(true)
    alarmDisplayPopup:SetClampedToScreen(true)
    alarmDisplayPopup:SetMouseEnabled(true)
    alarmDisplayPopup:SetDrawTier(DT_HIGH)

    local bg = wm:CreateControl(nil, alarmDisplayPopup, CT_BACKDROP)
    bg:SetAnchorFill(alarmDisplayPopup)
    local c = (MyAddon.savedVars and MyAddon.savedVars.alarmPopupBgColor) or {r=0, g=0, b=0}
    bg:SetCenterColor(c.r, c.g, c.b, 0.9)

    local title = wm:CreateControl("$(parent)Title", alarmDisplayPopup, CT_LABEL)
    title:SetAnchor(TOP, alarmDisplayPopup, TOP, 0, 10)
    title:SetFont(MyAddon:GetFontString("alarm"))
    title:SetText(LGA_L("ALARM_POPUP_TITLE"))
    title:SetColor(1, 0.2, 0.2, 1)

    local closeBtn = wm:CreateControl(nil, alarmDisplayPopup, CT_BUTTON)
    closeBtn:SetDimensions(25, 25)
    closeBtn:SetAnchor(TOPRIGHT, alarmDisplayPopup, TOPRIGHT, -5, 5)
    closeBtn:SetNormalTexture("EsoUI/art/buttons/decline_up.dds")
    closeBtn:SetHandler("OnClicked", function() 
        alarmDisplayPopup:SetHidden(true) 
        alarmDisplayPopup.data.isUserHidden = true
    end)

    -- Bouton Move/Fixe (M/F)
    local moveBtn = wm:CreateControl("$(parent)Move", alarmDisplayPopup, CT_BUTTON)
    moveBtn:SetDimensions(25, 22)
    moveBtn:SetAnchor(TOPRIGHT, closeBtn, TOPLEFT, -5, 0)
    moveBtn:SetFont(MyAddon:GetFontString("alarm"))

    -- Bouton Opacité
    local opacityBtn = wm:CreateControl("$(parent)Opacity", alarmDisplayPopup, CT_BUTTON)
    opacityBtn:SetDimensions(45, 20)
    opacityBtn:SetAnchor(TOPLEFT, alarmDisplayPopup, TOPLEFT, 5, 5)
    opacityBtn:SetFont(MyAddon:GetFontString("alarm"))

    local scroll = wm:CreateControlFromVirtual("$(parent)Scroll", alarmDisplayPopup, "ZO_ScrollContainer")
    scroll:SetAnchor(TOPLEFT, alarmDisplayPopup, TOPLEFT, 10, 40)
    scroll:SetAnchor(BOTTOMRIGHT, alarmDisplayPopup, BOTTOMRIGHT, -10, -10)

    alarmDisplayPopup.scroll = scroll
    alarmDisplayPopup.buttonPool = {} -- Pool de boutons pour le recyclage

    alarmDisplayPopup:SetHandler("OnMoveStop", function(self)
        MyAddon:SaveAlarmPopupState()
    end)

    alarmDisplayPopup.data = {
        bg = bg,
        moveBtn = moveBtn,
        opacityBtn = opacityBtn,
        isFixed = false,
        opIndex = 1,
        isUserHidden = true, -- On commence caché par défaut
    }

    -- Handlers for new buttons
    moveBtn:SetHandler("OnClicked", function()
        alarmDisplayPopup.data.isFixed = not alarmDisplayPopup.data.isFixed
        alarmDisplayPopup:SetMovable(not alarmDisplayPopup.data.isFixed)
        
        if alarmDisplayPopup.data.isFixed then
            moveBtn:SetText(LGA_L("BTN_FIXED_LABEL"))
            moveBtn:SetNormalFontColor(1, 0.2, 0.2, 1)
        else
            moveBtn:SetText(LGA_L("BTN_MOVE_LABEL"))
            moveBtn:SetNormalFontColor(0.2, 1, 0.2, 1)
        end
        MyAddon:SaveAlarmPopupState()
    end)

    opacityBtn:SetHandler("OnClicked", function()
        alarmDisplayPopup.data.opIndex = (alarmDisplayPopup.data.opIndex % #OPACITIES) + 1
        local newAlpha = OPACITIES[alarmDisplayPopup.data.opIndex]
        bg:SetAlpha(newAlpha)
        opacityBtn:SetText(string.format("%d%%", newAlpha * 100))
        MyAddon:SaveAlarmPopupState()
    end)

    -- Gestion de la scène pour cacher le popup avec l'inventaire, la carte, etc.
    local fragment = AlarmPopupFragment:New(alarmDisplayPopup)
    SCENE_MANAGER:GetScene("hud"):AddFragment(fragment)
    SCENE_MANAGER:GetScene("hudui"):AddFragment(fragment)

    -- Restore state
    local sv = MyAddon.savedVars
    local pos = sv.alarmDisplayPopupPosition
    if pos and pos.left and pos.top then
        alarmDisplayPopup:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, pos.left, pos.top)
    else
        alarmDisplayPopup:SetAnchor(CENTER, GuiRoot, CENTER)
    end

    alarmDisplayPopup.data.isFixed = sv.alarmPopupIsFixed or false
    alarmDisplayPopup:SetMovable(not alarmDisplayPopup.data.isFixed)
    if alarmDisplayPopup.data.isFixed then
        moveBtn:SetText(LGA_L("BTN_FIXED_LABEL"))
        moveBtn:SetNormalFontColor(1, 0.2, 0.2, 1)
    else
        moveBtn:SetText(LGA_L("BTN_MOVE_LABEL"))
        moveBtn:SetNormalFontColor(0.2, 1, 0.2, 1)
    end

    alarmDisplayPopup.data.opIndex = sv.alarmPopupOpacityIndex or 1
    local alpha = OPACITIES[alarmDisplayPopup.data.opIndex]
    bg:SetAlpha(alpha)
    opacityBtn:SetText(string.format("%d%%", alpha * 100))
end

function MyAddon:ShowAlarmDisplayPopup(leads, isPreview)
    if not alarmDisplayPopup then MyAddon:CreateAlarmDisplayPopup() end

    local scrollChild = alarmDisplayPopup.scroll:GetNamedChild("ScrollChild")
    -- On cache tous les labels existants avant de les réutiliser
    for _, button in ipairs(alarmDisplayPopup.buttonPool) do
        button:SetHidden(true)
    end
    
    if not isPreview and (not leads or #leads == 0) then
        alarmDisplayPopup:SetHidden(true)
        alarmDisplayPopup.data.isUserHidden = true
        return
    end

    if isPreview then
        leads = {
            { antiquityId = 147, quality = 3 }, -- Épique
            { antiquityId = 144, quality = 2 }, -- Supérieur
            { antiquityId = 141, quality = 1 }, -- Raffiné
        }
    end

    local yOffset = 5
    for i, lead in ipairs(leads) do
        local leadName
        if isPreview then
            leadName = LGA_L("PREVIEW_ALARM_LEAD") .. " " .. i
        else
            leadName = zo_strformat("<<C:1>>", GetAntiquityName(lead.antiquityId))
        end
        local zoneName = zo_strformat("<<C:1>>", GetZoneNameById(GetAntiquityZoneId(lead.antiquityId)))
        -- Pour l'aperçu, on met des temps arbitraires
        local remaining = isPreview and (4 - i) * 86400 + (i * 3600) or GetAntiquityLeadTimeRemainingSeconds(lead.antiquityId)
        local formattedTime = MyAddon:FormatTime(remaining)

        local leadNameColored = leadName
        local q = lead.quality or 0
        if q == 5 then -- Mythique (Orange)
            leadNameColored = "|cFF5500" .. leadName .. "|r"
        else
            -- Mapping: 1->2 (Vert), 2->3 (Bleu), 3->4 (Violet), 4->5 (Or)
            local itemQ = q + 1
            if itemQ > 5 then itemQ = 5 end
            local color = GetItemQualityColor(itemQ)
            if color and color.Colorize then leadNameColored = color:Colorize(leadName) end
        end
        local line = leadNameColored .. " (" .. zoneName .. ") - " .. formattedTime

        -- On récupère un label du pool ou on en crée un nouveau
        local button = alarmDisplayPopup.buttonPool[i]
        if not button then
            button = wm:CreateControl(nil, scrollChild, CT_BUTTON)
            button:SetFont(MyAddon:GetFontString("alarm"))
            button:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
            button:SetDimensions(420, 20)
            alarmDisplayPopup.buttonPool[i] = button
        end

        button.lgaData = { fragData = lead }
        if not isPreview then
            button:SetHandler("OnClicked", OnFragmentClicked)
        else
            -- Pas d'action pour l'aperçu
            button:SetHandler("OnClicked", nil)
        end

        button:SetHidden(false)
        button:ClearAnchors()
        button:SetAnchor(TOPLEFT, scrollChild, TOPLEFT, 0, yOffset)
        button:SetText(line)
        yOffset = yOffset + 22 -- Hauteur du bouton + petite marge
    end

    scrollChild:SetHeight(yOffset + 5)
    alarmDisplayPopup:SetHidden(false)
    alarmDisplayPopup.data.isUserHidden = false
    alarmDisplayPopup:BringWindowToTop()

    -- Auto-close timer
    if MyAddon.alarmCloseTimer then
        zo_removeCallLater(MyAddon.alarmCloseTimer)
        MyAddon.alarmCloseTimer = nil
    end

    local durationMinutes = MyAddon.savedVars.alarmPopupDisappearTime
    if durationMinutes > 0 then
        MyAddon.alarmCloseTimer = zo_callLater(function()
            alarmDisplayPopup:SetHidden(true)
            alarmDisplayPopup.data.isUserHidden = true
        end, durationMinutes * 60 * 1000)
    end
end

function MyAddon:CheckForExpiringLeads(isManualTrigger)
    -- Si ce n'est pas un déclenchement manuel, on vérifie si l'alarme est active
    if not isManualTrigger and not MyAddon.savedVars.isAlarmActive then return end

    local expiringLeads = {}
    local thresholdDays = MyAddon.savedVars.alarmThresholdDays or 0
    local thresholdHours = MyAddon.savedVars.alarmThresholdHours or 0
    local thresholdMinutes = MyAddon.savedVars.alarmThresholdMinutes or 0
    local thresholdSeconds = (thresholdDays * 86400) + (thresholdHours * 3600) + (thresholdMinutes * 60)
    
    for _, lead in ipairs(MyAddon.AllLeads) do
        if DoesAntiquityHaveLead(lead.antiquityId) then
            local remaining = GetAntiquityLeadTimeRemainingSeconds(lead.antiquityId)
            if remaining > 0 and remaining <= thresholdSeconds then
                table.insert(expiringLeads, lead)
            end
        end
    end

    if #expiringLeads > 0 then
        table.sort(expiringLeads, function(a, b)
            return GetAntiquityLeadTimeRemainingSeconds(a.antiquityId) < GetAntiquityLeadTimeRemainingSeconds(b.antiquityId)
        end)
        MyAddon:ShowAlarmDisplayPopup(expiringLeads)
    elseif isManualTrigger then
        -- S'il s'agit d'un déclenchement manuel et qu'aucune piste n'expire, on ferme le popup s'il est ouvert
        MyAddon:ShowAlarmDisplayPopup({})
    end
end

-- NOUVEAU: Fonctions de mise à jour de l'apparence

function MyAddon:GetFontString(fontType)
    local fontName, fontSize
    if fontType == "popup" then
        fontName = MyAddon.savedVars.popupFont or "ZoFontGameBold"
        fontSize = MyAddon.savedVars.popupFontSize or 16
    elseif fontType == "alarm" then
        fontName = MyAddon.savedVars.alarmPopupFont or "ZoFontGameBold"
        fontSize = MyAddon.savedVars.alarmPopupFontSize or 20
    else -- "main"
        fontName = MyAddon.savedVars.mainWinFont or "ZoFontGameBold"
        fontSize = MyAddon.savedVars.mainWinFontSize or 16
    end
    return string.format("%s|%d|soft-shadow-thin", fontName, fontSize)
end

function MyAddon:UpdateUIFonts()
    if not mainWin then return end
    local mainFontString = MyAddon:GetFontString("main")

    -- Éléments statiques de la fenêtre principale
    if titleLabel then titleLabel:SetFont(mainFontString) end
    if btnAll then btnAll:SetFont(mainFontString) end
    if btnItems then btnItems:SetFont(mainFontString) end
    if btnFragments then btnFragments:SetFont(mainFontString) end
    if noteBtn then noteBtn:SetFont(mainFontString) end
    if btnFilterAll then btnFilterAll:SetFont(mainFontString) end
    if btnFilterAcquired then btnFilterAcquired:SetFont(mainFontString) end
    if btnFilterUnacquired then btnFilterUnacquired:SetFont(mainFontString) end
    if btnFragFilterAll then btnFragFilterAll:SetFont(mainFontString) end
    if btnFragFilterLeads then btnFragFilterLeads:SetFont(mainFontString) end
    if btnFragFilterAcquired then btnFragFilterAcquired:SetFont(mainFontString) end
    if btnFragFilterUnacquired then btnFragFilterUnacquired:SetFont(mainFontString) end
    if opacLabel then opacLabel:SetFont(MyAddon:GetFontString("main")) end
    if lockBtn then lockBtn:SetFont(MyAddon:GetFontString("main")) end
    if settingsBtn then settingsBtn:SetFont(MyAddon:GetFontString("main")) end

    -- Mise à jour des Popups d'action (si ouverts)
    local popupFontString = MyAddon:GetFontString("popup")
    for _, popup in ipairs(actionPopupPool) do
        if popup.data then
            local d = popup.data
            if d.title then d.title:SetFont(popupFontString) end
            if d.zoneBtn then d.zoneBtn:SetFont(popupFontString) end
            if d.sourceZoneBtn then d.sourceZoneBtn:SetFont(popupFontString) end
            if d.timerLabel then d.timerLabel:SetFont(popupFontString) end
            if d.hintLabel then d.hintLabel:SetFont(popupFontString) end
            if d.btnScry then d.btnScry:SetFont(popupFontString) end
            if d.btnMap then d.btnMap:SetFont(popupFontString) end
            if d.btnSource then d.btnSource:SetFont(popupFontString) end
            if d.infoLabel then d.infoLabel:SetFont(popupFontString) end
            if d.btnSkill then d.btnSkill:SetFont(popupFontString) end
            if d.moveBtn then d.moveBtn:SetFont(popupFontString) end
            local opBtn = popup:GetNamedChild("Opacity")
            if opBtn then opBtn:SetFont(popupFontString) end
        end
    end

    -- Mise à jour du Popup d'alarme
    if alarmDisplayPopup and alarmDisplayPopup.data then
        local alarmFontString = MyAddon:GetFontString("alarm")
        local title = alarmDisplayPopup:GetNamedChild("Title")
        if title then title:SetFont(alarmFontString) end
        if alarmDisplayPopup.data.moveBtn then alarmDisplayPopup.data.moveBtn:SetFont(alarmFontString) end
        if alarmDisplayPopup.data.opacityBtn then alarmDisplayPopup.data.opacityBtn:SetFont(alarmFontString) end
        if alarmDisplayPopup.buttonPool then
            for _, btn in ipairs(alarmDisplayPopup.buttonPool) do
                btn:SetFont(alarmFontString)
            end
        end
    end

    -- La liste se mettra à jour via RefreshList
    RefreshList()
end

function MyAddon.UpdateBackgroundStyle()
    if not mainWin then return end
    local bg = mainWin:GetNamedChild("VraiFondNoir")
    if not bg then return end

    -- Utilise une couleur uniquement
    bg:SetCenterTexture("") -- Enlève la texture au cas où
    local c = MyAddon.savedVars.mainWinBgColor or {r=0, g=0, b=0}
    bg:SetCenterColor(c.r, c.g, c.b, 1) -- L'alpha est géré par le slider d'opacité global
end

function MyAddon.UpdatePopupBackgroundStyle()
    local c = MyAddon.savedVars.popupBgColor or {r=0, g=0, b=0}
    -- Action Popups
    for _, popup in ipairs(actionPopupPool) do
        local bg = popup:GetNamedChild("Bg")
        if bg then
            local _, _, _, a = bg:GetCenterColor()
            bg:SetCenterColor(c.r, c.g, c.b, a)
        end
    end
    -- Alarm Popup
    if alarmDisplayPopup and alarmDisplayPopup.data and alarmDisplayPopup.data.bg then
        local cAlarm = MyAddon.savedVars.alarmPopupBgColor or {r=0, g=0, b=0}
        local bg = alarmDisplayPopup.data.bg
        local _, _, _, a = bg:GetCenterColor()
        bg:SetCenterColor(cAlarm.r, cAlarm.g, cAlarm.b, a)
    end
end

-- Fonction de mise à jour des cadres (Bordures)
function MyAddon.UpdateFrameStyles()
    local styles = {
        ["Aucun"] = { tex = "", width = 128, size = 0 },
        ["Standard"] = { tex = "EsoUI/Art/Tooltips/UI-Border.dds", width = 128, size = 16 },
        ["Moyen"] = { tex = "EsoUI/Art/Tooltips/UI-Border.dds", width = 128, size = 8 },
        ["Fin"] = { tex = "EsoUI/Art/Tooltips/UI-Border.dds", width = 128, size = 4 },
        ["Orné"] = { tex = "EsoUI/Art/Miscellaneous/Gamepad/gp_toolTip_border_16.dds", width = 128, size = 16 },
    }

    -- 1. Fenêtre Principale
    if mainWin then
        local bg = mainWin:GetNamedChild("VraiFondNoir")
        if bg then
            local c = MyAddon.savedVars.mainWinFrameColor or {r=1,g=1,b=1,a=1}
            local s = styles[MyAddon.savedVars.mainWinFrameStyle] or styles["Aucun"]
            bg:SetEdgeTexture(s.tex, s.width, s.width, s.size)
            bg:SetEdgeColor(c.r, c.g, c.b, c.a)
        end
    end

    -- 2. Popups d'action
    local sPop = styles[MyAddon.savedVars.popupFrameStyle] or styles["Aucun"]
    local cPop = MyAddon.savedVars.popupFrameColor or {r=1,g=1,b=1,a=1}
    for _, popup in ipairs(actionPopupPool) do
        local bg = popup:GetNamedChild("Bg")
        if bg then
            bg:SetEdgeTexture(sPop.tex, sPop.width, sPop.width, sPop.size)
            bg:SetEdgeColor(cPop.r, cPop.g, cPop.b, cPop.a)
        end
    end
    
    -- 3. Popup d'alarme
    if alarmDisplayPopup and alarmDisplayPopup.data and alarmDisplayPopup.data.bg then
        local sAlarm = styles[MyAddon.savedVars.alarmPopupFrameStyle] or styles["Aucun"]
        local cAlarm = MyAddon.savedVars.alarmPopupFrameColor or {r=1, g=0.2, b=0.2, a=1}
        alarmDisplayPopup.data.bg:SetEdgeTexture(sAlarm.tex, sAlarm.width, sAlarm.width, sAlarm.size)
        alarmDisplayPopup.data.bg:SetEdgeColor(cAlarm.r, cAlarm.g, cAlarm.b, cAlarm.a)
    end
end

-- ==========================================================
-- IMPORT / EXPORT DES RÉGLAGES D'APPARENCE
-- ==========================================================

function MyAddon:SerializeAppearance()
    local parts = {}
    for _, key in ipairs(APPEARANCE_KEYS) do
        local value = MyAddon.savedVars[key]
        local valueStr = "nil"
        if type(value) == "string" then
            valueStr = value
        elseif type(value) == "number" then
            valueStr = tostring(value)
        elseif type(value) == "boolean" then
            valueStr = tostring(value)
        elseif type(value) == "table" then -- pour les couleurs
            local c = value or {r=1,g=1,b=1,a=1}
            valueStr = string.format("%.3f,%.3f,%.3f,%.3f", c.r, c.g, c.b, c.a or 1)
        end
        table.insert(parts, key .. "=" .. valueStr)
    end
    return table.concat(parts, "|")
end

function MyAddon:DeserializeAppearance(str)
    if not str or str == "" then return false end
    local success = true
    local tempSettings = {}

    for part in string.gmatch(str, "([^|]+)") do
        local key, valueStr = string.match(part, "([^=]+)=(.*)")
        if key and valueStr then
            local isKnownKey = false
            for _, knownKey in ipairs(APPEARANCE_KEYS) do
                if key == knownKey then isKnownKey = true; break; end
            end

            if isKnownKey then
                if valueStr == "true" then
                    tempSettings[key] = true
                elseif valueStr == "false" then
                    tempSettings[key] = false
                elseif tonumber(valueStr) then
                    tempSettings[key] = tonumber(valueStr)
                elseif string.find(valueStr, ",") then -- C'est une couleur
                    local r, g, b, a = string.match(valueStr, "([^,]+),([^,]+),([^,]+),([^,]+)")
                    if r and g and b then
                        tempSettings[key] = { r = tonumber(r), g = tonumber(g), b = tonumber(b), a = tonumber(a) or 1 }
                    else
                        success = false; break
                    end
                else -- C'est une chaîne de caractères
                    tempSettings[key] = valueStr
                end
            end
        end
    end
    
    if success and next(tempSettings) then
        for key, value in pairs(tempSettings) do
            MyAddon.savedVars[key] = value
        end
        -- Rafraîchir l'interface
        MyAddon.UpdateFrameStyles()
        MyAddon.UpdateBackgroundStyle()
        MyAddon:UpdateUIFonts()
        if MyAddon.SettingsPanel then CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", MyAddon.SettingsPanel) end
        ZO_Alert(UI_ALERT_CATEGORY_SUCCESS, nil, LGA_L("IMPORT_SUCCESS"))
    else
        ZO_Alert(UI_ALERT_CATEGORY_ERROR, nil, LGA_L("IMPORT_ERROR"))
    end
end

function MyAddon:CreateExportWindow()
    local frame = wm:CreateTopLevelWindow("LGA_ExportFrame")
    frame:SetDimensions(500, 400)
    frame:SetAnchor(CENTER, GuiRoot, CENTER)
    frame:SetHidden(true)
    frame:SetClampedToScreen(true)
    frame:SetMouseEnabled(true)
    frame:SetMovable(true)
    frame:SetDrawTier(DT_HIGH) -- On s'assure que la fenêtre est au-dessus des réglages
    frame.isOpenedManually = false -- NOUVEAU: Drapeau pour gérer la visibilité

    local bg = wm:CreateControl("$(parent)Bg", frame, CT_BACKDROP)
    bg:SetAnchorFill(frame)
    bg:SetCenterColor(0, 0, 0, 0.9)
    bg:SetEdgeColor(0.6, 0.6, 0.6, 1)
    bg:SetEdgeTexture("", 1, 1, 1)

    local title = wm:CreateControl("$(parent)Title", frame, CT_LABEL)
    title:SetAnchor(TOP, frame, TOP, 0, 10)
    title:SetFont("ZoFontWinH2")
    title:SetText(LGA_L("EXPORT_TITLE"))

    local closeBtn = wm:CreateControl("$(parent)Close", frame, CT_BUTTON)
    closeBtn:SetDimensions(25, 25)
    closeBtn:SetAnchor(TOPRIGHT, frame, TOPRIGHT, -5, 5)
    closeBtn:SetNormalTexture("EsoUI/art/buttons/decline_up.dds")
    closeBtn:SetHandler("OnClicked", function() 
        frame:SetHidden(true) 
        frame.isOpenedManually = false -- NOUVEAU: On réinitialise le drapeau
    end)

    local instruction = wm:CreateControl("$(parent)Instruction", frame, CT_LABEL)
    instruction:SetAnchor(TOP, title, BOTTOM, 0, 10)
    instruction:SetFont("ZoFontGame")
    instruction:SetText(LGA_L("EXPORT_INSTRUCTION"))

    local editBackdrop = wm:CreateControl("$(parent)EditBg", frame, CT_BACKDROP)
    editBackdrop:SetAnchor(TOPLEFT, frame, TOPLEFT, 20, 80)
    editBackdrop:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, -20, -20)
    editBackdrop:SetCenterColor(0.1, 0.1, 0.1, 0.8)
    editBackdrop:SetEdgeColor(0.3, 0.3, 0.3, 1)
    editBackdrop:SetEdgeTexture("", 1, 1, 1)

    local editBox = wm:CreateControl("$(parent)Edit", editBackdrop, CT_EDITBOX)
    editBox:SetAnchorFill(editBackdrop)
    editBox:SetFont("ZoFontGame")
    editBox:SetMultiLine(true)
    editBox:SetMaxInputChars(2048)
    editBox:SetEditEnabled(true)
    editBox:SetMouseEnabled(true)
    editBox:SetHandler("OnFocusGained", function(self) self:SelectAll() end)

    frame.editBox = editBox
    MyAddon.ExportFrame = frame
    
    local fragment = ExportWindowFragment:New(frame) -- NOUVEAU: Utilisation du fragment personnalisé
    SCENE_MANAGER:GetScene("hud"):AddFragment(fragment)
    SCENE_MANAGER:GetScene("hudui"):AddFragment(fragment)
    SCENE_MANAGER:GetScene("gameMenuInGame"):AddFragment(fragment) -- Autorise l'affichage dans le menu Echap/Réglages
end

function MyAddon:ShowExportPopup()
    if not MyAddon.ExportFrame then MyAddon:CreateExportWindow() end
    local exportString = MyAddon:SerializeAppearance()
    
    -- On ne force le mode curseur (hudui) que si on est en jeu sans interface (hud)
    -- Cela permet de garder les réglages ouverts si on vient de là
    if SCENE_MANAGER:IsShowing("hud") then SCENE_MANAGER:Show("hudui") end
    
    MyAddon.ExportFrame.isOpenedManually = true -- NOUVEAU: On active le drapeau
    MyAddon.ExportFrame.editBox:SetText(exportString)
    MyAddon.ExportFrame:SetHidden(false)
    MyAddon.ExportFrame:BringWindowToTop()
    MyAddon.ExportFrame.editBox:TakeFocus()
end

function MyAddon:CreateSettingsPanel()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelData = {
        type = "panel",
        name = MyAddon.name,
        author = "Takadol",
        slashCommand = "/lgasettings",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    MyAddon.SettingsPanel = LAM:RegisterAddonPanel(MyAddon.name .. "_Settings", panelData)

    MyAddon.SettingsPanel:SetHandler("OnHidden", function()
        if MyAddon.forceShowMainWin then
            MyAddon.forceShowMainWin = false
            if mainWin then mainWin:SetHidden(true) end
        end
        if MyAddon.forceShowActionPopup then
            MyAddon.forceShowActionPopup = false
            if actionPopupPool and actionPopupPool[1] then
                actionPopupPool[1]:SetHidden(true)
                actionPopupPool[1].data.isPreview = false
            end
        end
        if MyAddon.forceShowAlarmPopup then
            MyAddon.forceShowAlarmPopup = false
            if alarmDisplayPopup then alarmDisplayPopup:SetHidden(true) end
        end
    end)

    local options = {
        {
            type = "header",
            name = LGA_L("ALARM_SETTINGS_TITLE"),
        },
        {
            type = "checkbox",
            name = LGA_L("ALARM_ENABLE"),
            tooltip = LGA_L("ALARM_ENABLE_TOOLTIP"),
            getFunc = function() return MyAddon.savedVars.isAlarmActive or false end,
            setFunc = function(value) 
                MyAddon.savedVars.isAlarmActive = value
                if alarmBtn then MyAddon:UpdateAlarmButtonVisuals() end
            end,
        },
        {
            type = "slider",
            name = LGA_L("ALARM_THRESHOLD_DAYS"),
            tooltip = LGA_L("ALARM_THRESHOLD_DAYS_TOOLTIP"),
            min = 0,
            max = 60,
            step = 1,
            getFunc = function() return MyAddon.savedVars.alarmThresholdDays or 7 end,
            setFunc = function(value) MyAddon.savedVars.alarmThresholdDays = value end,
            width = "half",
            default = 7,
        },
        {
            type = "slider",
            name = LGA_L("ALARM_THRESHOLD_HOURS"),
            min = 0,
            max = 23,
            step = 1,
            getFunc = function() return MyAddon.savedVars.alarmThresholdHours or 0 end,
            setFunc = function(value) MyAddon.savedVars.alarmThresholdHours = value end,
            width = "half",
            default = 0,
        },
        {
            type = "slider",
            name = LGA_L("ALARM_THRESHOLD_MINUTES"),
            min = 0,
            max = 59,
            step = 1,
            getFunc = function() return MyAddon.savedVars.alarmThresholdMinutes or 0 end,
            setFunc = function(value) MyAddon.savedVars.alarmThresholdMinutes = value end,
            width = "full",
            default = 0,
        },
        {
            type = "slider",
            name = LGA_L("ALARM_POPUP_DURATION"),
            tooltip = LGA_L("ALARM_POPUP_DURATION_TOOLTIP"),
            min = 0,
            max = 59,
            step = 1,
            getFunc = function() return MyAddon.savedVars.alarmPopupDisappearTime or 0 end,
            setFunc = function(value) MyAddon.savedVars.alarmPopupDisappearTime = value end,
            displayFormat = function(value)
                if value == 0 then return LGA_L("ALARM_DURATION_NEVER") end
                return value .. " min"
            end,
            default = 0,
        },
        {
            type = "button",
            name = LGA_L("ALARM_TEST_BUTTON"),
            tooltip = LGA_L("ALARM_TEST_BUTTON_TOOLTIP"),
            func = function() 
                MyAddon.forceShowAlarmPopup = true
                MyAddon:ShowAlarmDisplayPopup(nil, true)
                if alarmDisplayPopup then alarmDisplayPopup:BringWindowToTop() end
            end,
            width = "half",
        },
        {
            type = "button",
            name = LGA_L("ALARM_REFRESH_BUTTON"),
            tooltip = LGA_L("ALARM_REFRESH_BUTTON_TOOLTIP"),
            func = function() if MyAddon.CheckForExpiringLeads then MyAddon:CheckForExpiringLeads(true) end end,
            disabled = function() return (alarmDisplayPopup and not alarmDisplayPopup:IsHidden()) or false end,
            width = "half",
        },
        {
            type = "header",
            name = LGA_L("PREVIEW_HEADER"),
        },
        {
            type = "button",
            name = LGA_L("PREVIEW_MAIN_WINDOW_BTN"),
            tooltip = LGA_L("PREVIEW_MAIN_WINDOW_TOOLTIP"),
            func = function()
                MyAddon.forceShowMainWin = not MyAddon.forceShowMainWin
                mainWin:SetHidden(not MyAddon.forceShowMainWin)
                if MyAddon.forceShowMainWin then mainWin:BringWindowToTop() end
            end,
            width = "full",
        },
        {
            type = "button",
            name = LGA_L("PREVIEW_ACTION_POPUP_BTN"),
            tooltip = LGA_L("PREVIEW_ACTION_POPUP_TOOLTIP"),
            func = function()
                MyAddon.forceShowActionPopup = not MyAddon.forceShowActionPopup
                local previewPopup = actionPopupPool[1]
                if MyAddon.forceShowActionPopup then
                    previewPopup.data.isPreview = true
                    local dummyEntry = {
                        fragData = {
                            antiquityId = 141, -- Piste de départ
                            name = LGA_L("PREVIEW_POPUP_TITLE"),
                            quality = 4, -- Légendaire
                            zoneId = 3, -- Glenumbra
                            digZoneId = 3,
                            mapText = LGA_L("PREVIEW_POPUP_HINT"),
                        }
                    }
                    MyAddon.ShowItemPopup(nil, dummyEntry, 1)
                    previewPopup:BringWindowToTop()
                else
                    previewPopup.data.isPreview = false
                    previewPopup:SetHidden(true)
                end
            end,
            width = "full",
        },
        {
            type = "button",
            name = LGA_L("PREVIEW_ALARM_POPUP_BTN"),
            tooltip = LGA_L("PREVIEW_ALARM_POPUP_TOOLTIP"),
            func = function()
                MyAddon.forceShowAlarmPopup = not MyAddon.forceShowAlarmPopup
                MyAddon:ShowAlarmDisplayPopup(nil, MyAddon.forceShowAlarmPopup)
                if MyAddon.forceShowAlarmPopup and alarmDisplayPopup then alarmDisplayPopup:BringWindowToTop() end
            end,
            width = "full",
        },
        {
            type = "header",
            name = "APPARENCE",
        },
        {
            type = "dropdown",
            name = "Cadre Fenêtre Principale",
            tooltip = "Choisit le style de bordure pour la fenêtre principale.",
            choices = {"Standard", "Moyen", "Fin", "Orné"},
            getFunc = function() return MyAddon.savedVars.mainWinFrameStyle or "Fin" end,
            setFunc = function(value) 
                MyAddon.savedVars.mainWinFrameStyle = value
                MyAddon.UpdateFrameStyles()
                if MyAddon.SettingsPanel then CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", MyAddon.SettingsPanel) end
            end,
            default = "Fin",
        },
        {
            type = "dropdown",
            name = "Cadre Popups",
            tooltip = "Choisit le style de bordure pour les fenêtres contextuelles (Popups).",
            choices = {"Standard", "Moyen", "Fin", "Orné"},
            getFunc = function() return MyAddon.savedVars.popupFrameStyle or "Fin" end,
            setFunc = function(value) 
                MyAddon.savedVars.popupFrameStyle = value
                MyAddon.UpdateFrameStyles()
                if MyAddon.SettingsPanel then CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", MyAddon.SettingsPanel) end
            end,
            default = "Fin",
        },
        {
            type = "header",
            name = "APPARENCE FENÊTRE PRINCIPALE",
        },
        {
            type = "colorpicker",
            name = "Couleur Cadre Principal",
            tooltip = "Choisit la couleur de la bordure de la fenêtre principale.",
            getFunc = function() 
                local c = MyAddon.savedVars.mainWinFrameColor or {r=0, g=0, b=0, a=1}
                return c.r, c.g, c.b, c.a or 1
            end,
            setFunc = function(r, g, b, a) 
                MyAddon.savedVars.mainWinFrameColor = {r=r, g=g, b=b, a=a}
                MyAddon.UpdateFrameStyles()
            end,
            disabled = function() return (MyAddon.savedVars.mainWinFrameStyle or "Aucun") == "Aucun" end,
            default = {r=0, g=0, b=0, a=1},
        },
        {
            type = "colorpicker",
            name = "Couleur Fond Principal",
            tooltip = "Choisit la couleur de fond de la fenêtre principale (si aucune image n'est utilisée).",
            getFunc = function() 
                local c = MyAddon.savedVars.mainWinBgColor or {r=0, g=0, b=0}
                return c.r, c.g, c.b 
            end,
            setFunc = function(r, g, b) 
                MyAddon.savedVars.mainWinBgColor = {r=r, g=g, b=b}
                MyAddon.UpdateBackgroundStyle()
            end,
            default = {r=0, g=0, b=0},
        },
        {
            type = "dropdown",
            name = "Police Fenêtre Principale",
            choices = {"ZoFontGameBold", "ZoFontGame", "ZoFontGameSmall", "ZoFontWinH1", "ZoFontWinH2", "ZoFontWinH3", "ZoFontKeybind", "ZoFontChat"},
            getFunc = function() return MyAddon.savedVars.mainWinFont or "ZoFontGameBold" end,
            setFunc = function(value) MyAddon.savedVars.mainWinFont = value; MyAddon:UpdateUIFonts() end,
            width = "half",
            default = "ZoFontGameBold",
        },
        {
            type = "slider",
            name = "Taille Police Principale",
            min = 12, max = 30, step = 1,
            getFunc = function() return MyAddon.savedVars.mainWinFontSize or 16 end,
            setFunc = function(value) MyAddon.savedVars.mainWinFontSize = value; MyAddon:UpdateUIFonts() end,
            width = "half",
            default = 16,
        },
        {
            type = "header",
            name = "APPARENCE POPUPS",
        },
        {
            type = "colorpicker",
            name = "Couleur Cadre Popups",
            tooltip = "Choisit la couleur de la bordure des popups.",
            getFunc = function() 
                local c = MyAddon.savedVars.popupFrameColor or {r=1, g=1, b=1, a=1}
                return c.r, c.g, c.b, c.a or 1
            end,
            setFunc = function(r, g, b, a) 
                MyAddon.savedVars.popupFrameColor = {r=r, g=g, b=b, a=a}
                MyAddon.UpdateFrameStyles()
            end,
            disabled = function() return (MyAddon.savedVars.popupFrameStyle or "Aucun") == "Aucun" end,
            default = {r=0, g=0, b=0, a=1},
        },
        {
            type = "colorpicker",
            name = "Couleur Fond Popups",
            tooltip = "Choisit la couleur de fond des popups.",
            getFunc = function() 
                local c = MyAddon.savedVars.popupBgColor or {r=0, g=0, b=0}
                return c.r, c.g, c.b 
            end,
            setFunc = function(r, g, b) 
                MyAddon.savedVars.popupBgColor = {r=r, g=g, b=b}
                MyAddon.UpdatePopupBackgroundStyle()
            end,
            default = {r=0, g=0, b=0},
        },
        {
            type = "dropdown",
            name = "Police Popups",
            choices = {"ZoFontGameBold", "ZoFontGame", "ZoFontGameSmall", "ZoFontWinH1", "ZoFontWinH2", "ZoFontWinH3", "ZoFontKeybind", "ZoFontChat"},
            getFunc = function() return MyAddon.savedVars.popupFont or "ZoFontGameBold" end,
            setFunc = function(value) MyAddon.savedVars.popupFont = value; MyAddon:UpdateUIFonts() end,
            width = "half",
            default = "ZoFontGameBold",
        },
        {
            type = "slider",
            name = "Taille Police Popups",
            min = 12, max = 24, step = 1,
            getFunc = function() return MyAddon.savedVars.popupFontSize or 16 end,
            setFunc = function(value) MyAddon.savedVars.popupFontSize = value; MyAddon:UpdateUIFonts() end,
            width = "half",
            default = 16,
        },
        {
            type = "header",
            name = "APPARENCE POPUP ALARME",
        },
        {
            type = "dropdown",
            name = "Cadre Alarme",
            choices = {"Standard", "Moyen", "Fin", "Orné"},
            getFunc = function() return MyAddon.savedVars.alarmPopupFrameStyle or "Fin" end,
            setFunc = function(value) 
                MyAddon.savedVars.alarmPopupFrameStyle = value
                MyAddon.UpdateFrameStyles()
                if MyAddon.SettingsPanel then CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", MyAddon.SettingsPanel) end
            end,
            default = "Fin",
        },
        {
            type = "colorpicker",
            name = "Couleur Cadre Alarme",
            getFunc = function() 
                local c = MyAddon.savedVars.alarmPopupFrameColor or {r=0, g=0, b=0, a=1}
                return c.r, c.g, c.b, c.a or 1
            end,
            setFunc = function(r, g, b, a) 
                MyAddon.savedVars.alarmPopupFrameColor = {r=r, g=g, b=b, a=a}
                MyAddon.UpdateFrameStyles()
            end,
            disabled = function() return (MyAddon.savedVars.alarmPopupFrameStyle or "Aucun") == "Aucun" end,
            default = {r=0, g=0, b=0, a=1},
        },
        {
            type = "colorpicker",
            name = "Couleur Fond Alarme",
            getFunc = function() 
                local c = MyAddon.savedVars.alarmPopupBgColor or {r=0, g=0, b=0}
                return c.r, c.g, c.b 
            end,
            setFunc = function(r, g, b) 
                MyAddon.savedVars.alarmPopupBgColor = {r=r, g=g, b=b}
                MyAddon.UpdatePopupBackgroundStyle()
            end,
            default = {r=0, g=0, b=0},
        },
        {
            type = "dropdown",
            name = "Police Alarme",
            choices = {"ZoFontGameBold", "ZoFontGame", "ZoFontGameSmall", "ZoFontWinH1", "ZoFontWinH2", "ZoFontWinH3", "ZoFontKeybind", "ZoFontChat"},
            getFunc = function() return MyAddon.savedVars.alarmPopupFont or "ZoFontGameBold" end,
            setFunc = function(value) MyAddon.savedVars.alarmPopupFont = value; MyAddon:UpdateUIFonts() end,
            width = "half",
            default = "ZoFontGameBold",
        },
        {
            type = "slider",
            name = "Taille Police Alarme",
            min = 12, max = 30, step = 1,
            getFunc = function() return MyAddon.savedVars.alarmPopupFontSize or 20 end,
            setFunc = function(value) MyAddon.savedVars.alarmPopupFontSize = value; MyAddon:UpdateUIFonts() end,
            width = "half",
            default = 20,
        },
        {
            type = "header",
            name = "RÉINITIALISATION DE L'APPARENCE",
        },
        {
            type = "button",
            name = "Réinit. Couleurs (Principale)",
            tooltip = "Rétablit les couleurs de cadre et de fond par défaut pour la fenêtre principale.",
            func = function()
                MyAddon.savedVars.mainWinFrameColor = {r=0, g=0, b=0, a=1}
                MyAddon.savedVars.mainWinBgColor = {r=0, g=0, b=0}
                MyAddon.UpdateFrameStyles()
                MyAddon.UpdateBackgroundStyle()
            end,
            width = "half",
        },
        {
            type = "button",
            name = "Réinit. Couleurs (Popups)",
            tooltip = "Rétablit la couleur de cadre et de fond par défaut pour les popups.",
            func = function()
                MyAddon.savedVars.popupFrameColor = {r=0, g=0, b=0, a=1}
                MyAddon.savedVars.popupBgColor = {r=0, g=0, b=0}
                MyAddon.UpdateFrameStyles()
                MyAddon.UpdatePopupBackgroundStyle()
            end,
            width = "half",
        },
        {
            type = "button",
            name = "Réinit. Police (Principale)",
            tooltip = "Rétablit la police et la taille par défaut pour la fenêtre principale.",
            func = function()
                MyAddon.savedVars.mainWinFont = "ZoFontGameBold"
                MyAddon.savedVars.mainWinFontSize = 18
                MyAddon:UpdateUIFonts()
            end,
            width = "half",
        },
        {
            type = "button",
            name = "Réinit. Police (Popups)",
            tooltip = "Rétablit la police et la taille par défaut pour les popups.",
            func = function()
                MyAddon.savedVars.popupFont = "ZoFontGameBold"
                MyAddon.savedVars.popupFontSize = 18
                MyAddon:UpdateUIFonts()
            end,
            width = "half",
        },
        {
            type = "button",
            name = "Réinit. Apparence (Alarme)",
            tooltip = "Rétablit les réglages d'apparence par défaut pour le popup d'alarme.",
            func = function()
                MyAddon.savedVars.alarmPopupFrameStyle = "Fin"
                MyAddon.savedVars.alarmPopupFrameColor = {r=0, g=0, b=0, a=1}
                MyAddon.savedVars.alarmPopupBgColor = {r=0, g=0, b=0}
                MyAddon.savedVars.alarmPopupFont = "ZoFontGameBold"
                MyAddon.savedVars.alarmPopupFontSize = 20
                MyAddon.UpdateFrameStyles()
                MyAddon.UpdatePopupBackgroundStyle()
                MyAddon:UpdateUIFonts()
                if MyAddon.SettingsPanel then CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", MyAddon.SettingsPanel) end
            end,
            width = "full",
        },
        {
            type = "header",
            name = LGA_L("AUTO_EYE_SETTINGS_HEADER"),
        },
        {
            type = "checkbox",
            name = LGA_L("AUTO_EYE_ENABLE"),
            tooltip = LGA_L("AUTO_EYE_ENABLE_TOOLTIP"),
            getFunc = function() return MyAddon.savedVars.autoEyeEnabled end,
            setFunc = function(newValue) MyAddon.savedVars.autoEyeEnabled = newValue end,
            default = true,
        },
        {
            type = "checkbox",
            name = LGA_L("AUTO_EYE_IGNORE_MOVEMENT"),
            tooltip = LGA_L("AUTO_EYE_IGNORE_MOVEMENT_TOOLTIP"),
            disabled = function() return not MyAddon.savedVars.autoEyeEnabled end,
            getFunc = function() return MyAddon.savedVars.autoEyeIgnoreMovement end,
            setFunc = function(newValue) MyAddon.savedVars.autoEyeIgnoreMovement = newValue end,
            default = false,
        },
        {
            type = "header",
            name = "Importer / Exporter les Réglages",
        },
        {
            type = "button",
            name = "Exporter les réglages d'apparence",
            tooltip = "Copie les réglages d'apparence actuels dans une chaîne de texte à partager.",
            func = function() MyAddon:ShowExportPopup() end,
            width = "full",
        },
        {
            type = "editbox",
            name = "Importer les réglages d'apparence",
            tooltip = "Collez une chaîne de réglages ici, puis cliquez sur le bouton Importer.",
            getFunc = function() return MyAddon.importString or "" end,
            setFunc = function(text) MyAddon.importString = text end,
            isMultiline = false,
            width = "half",
            reference = "LGA_Import_EditBox",
        },
        {
            type = "button",
            name = "Effacer",
            tooltip = "Efface le texte de la zone d'importation.",
            func = function() 
                MyAddon.importString = ""
                if LGA_Import_EditBox then
                    local edit = LGA_Import_EditBox.edit or LGA_Import_EditBox:GetNamedChild("Edit")
                    if edit then edit:SetText("") end
                end
            end,
            width = "half",
        },
        {
            type = "button",
            name = "Importer",
            tooltip = "Applique les réglages de la chaîne de caractères collée ci-dessus.",
            func = function() MyAddon:DeserializeAppearance(MyAddon.importString) end,
            width = "full",
        },
        {
            type = "header",
            name = LGA_L("SETTINGS_SCOPE_HEADER"),
        },
        {
            type = "checkbox",
            name = LGA_L("SETTINGS_SCOPE_CHECKBOX"),
            tooltip = LGA_L("SETTINGS_SCOPE_TOOLTIP_CHECKBOX"),
            getFunc = function() return MyAddon.accountVars.savePerCharacter or false end,
            setFunc = function(value) MyAddon.accountVars.savePerCharacter = value end,
            requiresReload = true,
            warning = LGA_L("RELOAD_REQUIRED_DESC"),
            default = false,
        },
        {
            type = "header",
            name = "ZONE DE DANGER",
        },
        {
            type = "button",
            name = "|cFF0000RÉINITIALISATION USINE|r",
            tooltip = "Remet TOUS les réglages de l'addon à zéro (comme une nouvelle installation) et recharge l'interface.",
            func = function()
                -- On remet les variables par défaut
                if MyAddon.defaults then
                    for k, v in pairs(MyAddon.defaults) do
                        MyAddon.savedVars[k] = v
                    end
                end
                ReloadUI()
            end,
            width = "full",
            warning = "Attention : Ceci effacera vos favoris, notes et réglages !",
        },
    }

    LAM:RegisterOptionControls(MyAddon.name .. "_Settings", options)
end

-- ==========================================================
-- HANDLERS OPTIMISÉS (Définis une seule fois)
-- ==========================================================

local function OnItemMouseEnter(btn)
    local entry = btn.lgaData
    if not entry then return end
    
    InitializeSmartTooltip(ItemTooltip, btn)
    if entry.data.itemLink and entry.data.itemLink ~= "" then
        local interactiveLink = entry.data.itemLink:gsub("|H0:", "|H1:")
        pcall(function() ItemTooltip:SetLink(interactiveLink) end)
    else
        -- TENTATIVE DE RÉSOLUTION INTELLIGENTE
        local resolved = MyAddon.GetResolvedItemData(entry.data)
        if resolved.itemLink then
                pcall(function() ItemTooltip:SetLink(resolved.itemLink) end)
        elseif resolved.collectibleId then
                ItemTooltip:SetCollectible(resolved.collectibleId)
        else
            -- FALLBACK FINAL
            ItemTooltip:AddLine(entry.data.name, "ZoFontWinH2")
            ItemTooltip:AddLine(LGA_L("COLLECTION_TO_ASSEMBLE"), "ZoFontGameBold", 1, 0.8, 0)
            ItemTooltip:AddVerticalPadding(5)
            if entry.data.fragments then
                local numFound = 0
                for _, f in ipairs(entry.data.fragments) do
                    if DoesAntiquityNeedCombination(f.antiquityId) then numFound = numFound + 1 end
                end
                local total = #entry.data.fragments
                local color = (numFound == total) and "|c00FF00" or "|cFFFFFF"
                ItemTooltip:AddLine(LGA_L("PROGRESSION_LABEL") .. color .. numFound .. " / " .. total .. "|r" .. LGA_L("FRAGMENTS_LABEL"), "ZoFontGame")
            end
        end
    end
end

local function OnItemMouseExit()
    ClearTooltip(ItemTooltip)
end

OnFragmentClicked = function(btn)
    local entry = btn.lgaData
    if entry then MyAddon.ShowItemPopup(btn, entry) end
end

local function OnFragmentMouseEnter(btn)
    local entry = btn.lgaData
    if not entry then return end
    
    InitializeSmartTooltip(InformationTooltip, btn)
    -- Utilisation unifiée de FillFragmentTooltip pour tous les types de fragments
    FillFragmentTooltip(InformationTooltip, entry.fragData, entry.fragData.setName or "")
end

local function OnFragmentMouseExit()
    ClearFragmentTooltip(InformationTooltip)
    ClearTooltip(InformationTooltip)
end

local function OnExpandClicked(btn)
    -- Le bouton expand est un enfant du bouton principal (RowX)
    local parentBtn = btn:GetParent()
    local entry = parentBtn.lgaData
    if entry then
        if not MyAddon.savedVars.expandedItems then MyAddon.savedVars.expandedItems = {} end
        MyAddon.savedVars.expandedItems[entry.key] = not MyAddon.savedVars.expandedItems[entry.key]
        RefreshList()
    end
end

local function OnStarMouseDown(btn, mouseButton)
    if mouseButton == MOUSE_BUTTON_INDEX_LEFT then 
        local parentBtn = btn:GetParent()
        local entry = parentBtn.lgaData
        if entry then
            MyAddon.HandleFavoriteClick(entry.key) 
            return true 
        end
    end
end

local function OnPinClicked(btn)
    local parentBtn = btn:GetParent()
    local entry = parentBtn.lgaData
    if entry then
        if MyAddon.savedVars.pinnedItem == entry.key then
            MyAddon.savedVars.pinnedItem = nil
        else
            MyAddon.savedVars.pinnedItem = entry.key
        end
        RefreshList()
    end
end

-- ==========================================================

-- 2. LOGIQUE D'AFFICHAGE
RefreshList = function()
    -- Initialisation
    if not MyAddon.savedVars or not listArea then return end -- Sécurité anti-crash

    if not MyAddon.savedVars.searchTerms then
        MyAddon.savedVars.searchTerms = { items = "", fragments = "", fav = "" }
    end
    local searchTerm = MyAddon.savedVars.searchTerms[currentTab] or ""
    local filter = CleanText(searchTerm)
    local scrollChild = listArea:GetNamedChild("ScrollChild")
    if not scrollChild then return end -- Sécurité pour éviter les erreurs si la liste n'est pas prête
    for _, btn in ipairs(buttonPool) do
        btn:SetHidden(true)
    end
    local displayList = {}

    -- Logique pour l'onglet "Obj.Myth"
    if currentTab == "items" then
        local parents = {}
        for id, data in pairs(MyAddon.MythicItems) do
            -- MODIFICATION : On ne montre que les équipements (Gear) dans cet onglet
            local isGear = IsItemGear(data)
            local itemNameMatch = filter == "" or string.find(CleanText(data.name), filter, 1, true)
            if isGear and itemNameMatch then
                local isAcquired = IsItemAcquired(data)
                local showItem = false
                if MyAddon.savedVars.itemFilterState == "all" then showItem = true
                elseif MyAddon.savedVars.itemFilterState == "acquired" and isAcquired then showItem = true
                elseif MyAddon.savedVars.itemFilterState == "unacquired" and not isAcquired then showItem = true
                end
                if showItem then
                    local itemIsFav = (MyAddon.savedVars.favorites and MyAddon.savedVars.favorites[id] == true)
                    table.insert(parents, { key = id, name = data.name, type = "item", isFav = itemIsFav, data = data })
                end
            end
        end
        
        -- On trie les parents par nom
        table.sort(parents, function(a, b) return a.name < b.name end)
        
        -- On construit la liste finale avec les enfants si déroulé
        for _, p in ipairs(parents) do
            table.insert(displayList, p)
            if MyAddon.savedVars.expandedItems and MyAddon.savedVars.expandedItems[p.key] and p.data.fragments then
                for i, frag in ipairs(p.data.fragments) do
                    local fKey = "frag_" .. p.key .. "_" .. i
                    local fName = frag.name
                    if not fName or fName == "" then fName = "Piste " .. frag.antiquityId end
                    local fragIsFav = (MyAddon.savedVars.favorites and MyAddon.savedVars.favorites[fKey] == true)
                    table.insert(displayList, { key = fKey, name = fName, type = "child_fragment", data = p.data, fragData = frag, isFav = fragIsFav, parentId = p.key })
                end
            end
        end
    -- Logique pour l'onglet "PISTES"
    elseif currentTab == "fragments" then
        local topLevelEntries = {}
        local filterState = MyAddon.savedVars.fragmentFilterState
 
        -- LES PISTES INDIVIDUELLES ET FRAGMENTS
        for _, frag in ipairs(MyAddon.AllLeads) do
            local fName = frag.name
            if not fName or fName == "" then fName = "Piste " .. frag.antiquityId end
            
            local nameMatch = filter == "" or string.find(CleanText(fName), filter, 1, true)
            
            local zoneMatch = true
            local filterZoneId = MyAddon.savedVars.regionFilter
            if filterZoneId and filterZoneId ~= 0 then
                if filterZoneId == -1 then
                    local currentZoneId = GetZoneId(GetUnitZoneIndex("player"))
                    if frag.zoneId ~= currentZoneId and frag.digZoneId ~= currentZoneId then zoneMatch = false end
                elseif frag.zoneId ~= filterZoneId and frag.digZoneId ~= filterZoneId then
                    zoneMatch = false
                end
            end

            local typeMatch = true
            local filterType = MyAddon.savedVars.typeFilter
            -- Si filterType est une chaine non vide et différente de notre valeur pour "tous"
            if filterType and filterType ~= "" and filterType ~= "__ALL_TYPES__" then
                if frag.typeName ~= filterType then typeMatch = false end
            end

            local qualityMatch = true
            local filterQuality = MyAddon.savedVars.qualityFilter
            local inclusive = MyAddon.savedVars.qualityInclusive
            if filterQuality and filterQuality ~= 0 then
                if inclusive then
                    -- Recherche inclusive : on accepte si la qualité est inférieure ou égale à la sélection
                    if frag.quality > filterQuality then qualityMatch = false end
                else
                    if filterQuality == 5 then
                        -- Filtre Mythique : On accepte la piste si elle est Mythique OU si son Set parent est Mythique
                        local isMythic = (frag.quality == 5)
                        if not isMythic and frag.setId > 0 then
                            if GetAntiquitySetQuality(frag.setId) == 5 then isMythic = true end
                        end
                        if not isMythic then qualityMatch = false end
                    else
                        if frag.quality ~= filterQuality then qualityMatch = false end
                    end
                end
            end

            if nameMatch and zoneMatch and typeMatch and qualityMatch then
                local fragId = tonumber(frag.antiquityId)
                local isAcquired = false
                local hasLead = false
                local timeRemaining = 0
                if fragId and fragId > 0 then
                    isAcquired = DoesAntiquityNeedCombination and DoesAntiquityNeedCombination(fragId)
                    if not isAcquired and GetNumAntiquitiesRecovered and GetNumAntiquitiesRecovered(fragId) > 0 then
                        isAcquired = true
                    end
                    hasLead = DoesAntiquityHaveLead and DoesAntiquityHaveLead(fragId)
                    if hasLead and GetAntiquityLeadTimeRemainingSeconds then
                        timeRemaining = GetAntiquityLeadTimeRemainingSeconds(fragId)
                        if timeRemaining < 0 then timeRemaining = 0 end
                    end
                end

                local showFragment = false
                if filterState == "all" then showFragment = true
                elseif MyAddon.savedVars.fragmentFilterState == "leads" and hasLead then showFragment = true -- Nouveau filtre "Pistes"
                elseif MyAddon.savedVars.fragmentFilterState == "acquired" and isAcquired then showFragment = true
                elseif MyAddon.savedVars.fragmentFilterState == "unacquired" and not isAcquired and not hasLead then showFragment = true
                end

                if showFragment then
                    -- On décide si on affiche cette piste comme une ligne simple
                    local showAsSingle = true -- Toutes les pistes/fragments sont affichés comme des lignes simples

                    if showAsSingle then
                        local fKey = (frag.setId > 0) and ("frag_single_" .. frag.antiquityId) or ("lead_" .. frag.antiquityId)
                        local parentData = (frag.setId > 0) and MyAddon.MythicItems[frag.setId] or nil
                        local fragIsFav = (MyAddon.savedVars.favorites and MyAddon.savedVars.favorites[fKey] == true)
                        table.insert(topLevelEntries, { key = fKey, name = fName, type = "fragment", data = parentData, fragData = frag, isFav = fragIsFav, timeRemaining = timeRemaining })
                    end
                end
            end
        end
        
        -- Tri global
        table.sort(topLevelEntries, function(a, b)
            -- Si on est sur le filtre "Pistes" (leads), on trie par temps restant
            if MyAddon.savedVars.fragmentFilterState == "leads" then
                -- On traite 0 (pas de timer/infini) comme très grand pour qu'ils soient à la fin
                local timeA = (a.timeRemaining and a.timeRemaining > 0) and a.timeRemaining or 9999999999
                local timeB = (b.timeRemaining and b.timeRemaining > 0) and b.timeRemaining or 9999999999
                
                if timeA ~= timeB then
                    return timeA < timeB -- Du plus court au plus long
                end
            end
            -- Sinon (ou si temps égal), tri alphabétique
            return a.name < b.name 
        end)
        
        -- Construction de la liste finale avec expansion
        for _, entry in ipairs(topLevelEntries) do
            table.insert(displayList, entry)
            -- Si c'est un Set Non-Gear et qu'il est ouvert, on ajoute ses enfants
            if entry.type == "item" and MyAddon.savedVars.expandedItems and MyAddon.savedVars.expandedItems[entry.key] and entry.data.fragments then
                for i, frag in ipairs(entry.data.fragments) do
                    local fKey = "frag_" .. entry.key .. "_" .. i
                    local fName = frag.name
                    if not fName or fName == "" then fName = "Piste " .. frag.antiquityId end
                    local fragIsFav = (MyAddon.savedVars.favorites and MyAddon.savedVars.favorites[fKey] == true)
                    table.insert(displayList, { key = fKey, name = fName, type = "child_fragment", data = entry.data, fragData = frag, isFav = fragIsFav, parentId = entry.key })
                end
            end
        end
    -- Logique pour l'onglet "FAVORIS"
    elseif currentTab == "fav" then
        -- Objets (Sets) favoris
        local favItems = {}
        for id, data in pairs(MyAddon.MythicItems) do
            local itemIsFav = (MyAddon.savedVars.favorites and MyAddon.savedVars.favorites[id] == true)
            local itemNameMatch = filter == "" or string.find(CleanText(data.name), filter, 1, true)
            if itemIsFav and itemNameMatch then
                table.insert(favItems, { key = id, name = data.name, type = "item", isFav = true, data = data })
            end
        end
        
        -- Tri des objets favoris
        table.sort(favItems, function(a, b) return a.name < b.name end)
        
        -- Ajout des objets à la liste (avec gestion de l'ouverture +)
        for _, p in ipairs(favItems) do
            table.insert(displayList, p)
            if MyAddon.savedVars.expandedItems and MyAddon.savedVars.expandedItems[p.key] and p.data.fragments then
                for i, frag in ipairs(p.data.fragments) do
                    local fKey = "frag_" .. p.key .. "_" .. i
                    local fName = frag.name
                    if not fName or fName == "" then fName = "Piste " .. frag.antiquityId end
                    local fragIsFav = (MyAddon.savedVars.favorites and MyAddon.savedVars.favorites[fKey] == true)
                    table.insert(displayList, { key = fKey, name = fName, type = "child_fragment", data = p.data, fragData = frag, isFav = fragIsFav, parentId = p.key })
                end
            end
        end

        -- Fragments (toutes pistes) favoris
        local favFrags = {}
        for _, frag in ipairs(MyAddon.AllLeads) do
            local fKey
            if frag.setId > 0 then
                local parentData = MyAddon.MythicItems[frag.setId]
                local fragIndex = 0
                if parentData and parentData.fragments then
                    for idx, pFrag in ipairs(parentData.fragments) do
                        if pFrag.antiquityId == frag.antiquityId then fragIndex = idx; break; end
                    end
                end
                fKey = "frag_" .. frag.setId .. "_" .. fragIndex
            else
                fKey = "lead_" .. frag.antiquityId
            end

            local fragIsFav = (MyAddon.savedVars.favorites and MyAddon.savedVars.favorites[fKey] == true)
            local fName = frag.name
            if not fName or fName == "" then fName = "Piste " .. frag.antiquityId end
            local fragNameMatch = filter == "" or string.find(CleanText(fName), filter, 1, true)

            if fragIsFav and fragNameMatch then
                local parentData = (frag.setId > 0) and MyAddon.MythicItems[frag.setId] or nil
                table.insert(favFrags, { key = fKey, name = fName, type = "fragment", data = parentData, fragData = frag, isFav = true })
            end
        end
        
        -- Tri des fragments favoris et ajout à la suite
        table.sort(favFrags, function(a, b) return a.name < b.name end)
        for _, f in ipairs(favFrags) do
            table.insert(displayList, f)
        end
    end

    -- Tri et affichage
    -- Le tri est maintenant géré à l'intérieur de chaque bloc logique

    -- OPTIMISATION : Chargement progressif et Recyclage des boutons
    local refreshTaskName = MyAddon.name .. "_RefreshList"
    EVENT_MANAGER:UnregisterForUpdate(refreshTaskName)

    -- On cache tous les boutons existants pour les réutiliser
    for _, btn in ipairs(buttonPool) do
        btn:SetHidden(true)
    end
    itemButtons = {} -- On vide la map des boutons actifs

    -- On définit la hauteur totale immédiatement pour la barre de défilement
    scrollChild:SetHeight(#displayList * 35)

    if itemCountLabel then
        itemCountLabel:SetText(tostring(#displayList))
    end

    local currentIndex = 1
    local totalItems = #displayList

    local function UpdateBatch()
        local startTime = GetGameTimeMilliseconds()
        -- On traite par paquets de 15ms max pour ne pas geler le jeu
        while currentIndex <= totalItems do
            if (GetGameTimeMilliseconds() - startTime) > 15 then return end -- Pause si trop long

            local index = currentIndex
            local entry = displayList[index]

            -- Récupération ou Création d'un bouton générique (Row X)
            local btn = buttonPool[index]
            if not btn then
                btn = wm:CreateControl("$(parent)Row"..index, scrollChild, CT_BUTTON)
                btn:SetMouseEnabled(true)
                btn:SetDrawTier(DT_LOW)
                btn:SetDrawLayer(DL_CONTROLS)
            btn:SetDimensions(400, 30)
            
            local expandBtn = wm:CreateControl("$(parent)Expand", btn, CT_BUTTON)
            expandBtn:SetDimensions(20, 20)
            expandBtn:SetAnchor(LEFT, btn, LEFT, 0, 0)
            
            local statusIcon = wm:CreateControl("$(parent)StatusIcon", btn, CT_TEXTURE)
            statusIcon:SetDimensions(20, 20)
            statusIcon:SetAnchor(LEFT, expandBtn, RIGHT, 0, 0)

            local star = wm:CreateControl("$(parent)Star", btn, CT_BUTTON)
            star:SetDimensions(20, 20)
            star:SetAnchor(RIGHT, btn, RIGHT, -10, 0)
            star:SetMouseEnabled(true)      -- Permet au losange de recevoir vos clics
			star:SetDrawLayer(DL_OVERLAY)   -- Force l'icône à être au-dessus du reste pour être visible

            local btnLabel = wm:CreateControl("$(parent)Name", btn, CT_LABEL)
            btnLabel:SetDrawLayer(DL_OVERLAY)
            btnLabel:SetAnchor(LEFT, statusIcon, RIGHT, 10, 0)
            btnLabel:SetAnchor(RIGHT, star, LEFT, -5, 0)
            btnLabel:SetHeight(30)
            btnLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
            btnLabel:SetFont(MyAddon:GetFontString("main"))

            table.insert(buttonPool, btn)
        end

            itemButtons[entry.key] = btn
            btn.lgaData = entry -- OPTIMISATION : On attache les données au contrôle
            btn:SetHidden(false)
            btn:ClearAnchors()
            btn:SetAnchor(TOP, scrollChild, TOP, 0, (index - 1) * 35)
            
            -- On applique les handlers optimisés (définis une seule fois)
            if entry.type == "item" then
                btn:SetHandler("OnClicked", nil)
                btn:SetHandler("OnMouseEnter", OnItemMouseEnter)
                btn:SetHandler("OnMouseExit", OnItemMouseExit)
            
            elseif entry.type == "child_fragment" then
                btn:SetHandler("OnClicked", OnFragmentClicked)
                btn:SetHandler("OnMouseEnter", OnFragmentMouseEnter)
                btn:SetHandler("OnMouseExit", OnFragmentMouseExit)

            elseif entry.type == "fragment" then
                btn:SetHandler("OnClicked", OnFragmentClicked)
                btn:SetHandler("OnMouseEnter", OnFragmentMouseEnter)
                btn:SetHandler("OnMouseExit", OnFragmentMouseExit)
            end

            local expandBtn = btn:GetNamedChild("Expand")
            local statusIcon = btn:GetNamedChild("StatusIcon")
            local btnLabel = btn:GetNamedChild("Name")
            
            if entry.type == "item" then
                expandBtn:SetHidden(false)
                local isExpanded = MyAddon.savedVars.expandedItems and MyAddon.savedVars.expandedItems[entry.key]
                expandBtn:SetNormalTexture(isExpanded and "EsoUI/Art/Buttons/minus_up.dds" or "EsoUI/Art/Buttons/plus_up.dds")
                expandBtn:SetHandler("OnClicked", OnExpandClicked)
                statusIcon:SetAnchor(LEFT, btn, LEFT, 25, 0) -- Décalé après le bouton +
            elseif entry.type == "child_fragment" then
                expandBtn:SetHidden(true)
                statusIcon:SetAnchor(LEFT, btn, LEFT, 45, 0) -- Indentation pour les enfants
            else
                -- Cas normal (autres onglets)
                expandBtn:SetHidden(true)
                statusIcon:SetAnchor(LEFT, btn, LEFT, 5, 0)
            end
            
            local star = btn:GetNamedChild("Star")
            if star then
                local tex = entry.isFav and "Le_Guide_de_L_Antiquaire/Textures/favoris.dds" or "Le_Guide_de_L_Antiquaire/Textures/non-favoris.dds"
                star:SetHandler("OnMouseDown", OnStarMouseDown)
                star:SetNormalTexture(tex)
            end
            
            local pinBtn = btn:GetNamedChild("Pin") or wm:CreateControl("$(parent)Pin", btn, CT_BUTTON)
            pinBtn:SetDimensions(20, 20)
            
            if currentTab == "fav" then
                pinBtn:SetHidden(false)
                pinBtn:ClearAnchors()
                pinBtn:SetAnchor(RIGHT, star, LEFT, -5, 0)
                
                local isPinned = (MyAddon.savedVars.pinnedItem == entry.key)
                local pinTex = isPinned and "EsoUI/Art/Buttons/checkbox_checked.dds" or "EsoUI/Art/Buttons/checkbox_unchecked.dds"
                pinBtn:SetNormalTexture(pinTex)
                
                pinBtn:SetHandler("OnClicked", OnPinClicked)
                
                pinBtn:SetHandler("OnMouseEnter", function(self)
                    InitializeSmartTooltip(InformationTooltip, self)
                    InformationTooltip:AddLine(LGA_L("PIN_TOOLTIP_TITLE"), "ZoFontWinH2")
                    InformationTooltip:AddLine(LGA_L("PIN_TOOLTIP_TEXT"), "ZoFontGame")
                end)
                pinBtn:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)
                
                if btnLabel then
                    btnLabel:ClearAnchors()
                    btnLabel:SetAnchor(LEFT, btn:GetNamedChild("StatusIcon"), RIGHT, 10, 0)
                    btnLabel:SetAnchor(RIGHT, pinBtn, LEFT, -5, 0)
                end
            else
                pinBtn:SetHidden(true)
                if btnLabel then
                    btnLabel:ClearAnchors()
                    btnLabel:SetAnchor(LEFT, btn:GetNamedChild("StatusIcon"), RIGHT, 10, 0)
                    btnLabel:SetAnchor(RIGHT, star, LEFT, -5, 0)
                end
            end
            
            if entry.type == "item" then
                local color = "|cFFFFFF"
                -- Priorité à la qualité du Set d'Antiquité pour forcer l'Orange sur les Mythiques
                if entry.data.antId and entry.data.antId > 0 then
                    local q = GetAntiquitySetQuality(entry.data.antId)
                    if q == 5 then -- 5 = Ultimate (Mythique)
                        color = "|cFF5500"
                    else
                        color = "|c" .. GetItemQualityColor(q + 1):ToHex()
                    end
                elseif entry.data.itemLink and entry.data.itemLink ~= "" then
                    local q = GetItemLinkQuality(entry.data.itemLink)
                    color = "|c" .. GetItemQualityColor(q):ToHex()
                end
                btnLabel:SetText(color .. entry.name .. "|r")
            else
                local timer = GetLeadTimer(entry.fragData.antiquityId)
                local q = entry.fragData.quality or 0
                local color = "|c" .. GetItemQualityColor(q + 1):ToHex()
                local prefix = (entry.type == "child_fragment") and "  • " or ""
                btnLabel:SetText(color .. prefix .. entry.name .. "|r" .. (timer ~= "" and (" |cFFF000" .. timer .. "|r") or ""))
            end

            if statusIcon then
                local success, iconPath = pcall(GetStatusIcon, entry)
                if success then
                    statusIcon:SetTexture(iconPath)
                else
                    statusIcon:SetTexture("Le_Guide_de_L_Antiquaire/Textures/status_not_found.dds")
                end
            end
            
            currentIndex = currentIndex + 1
        end
        
        -- Fin du traitement
        if currentIndex > totalItems then
            EVENT_MANAGER:UnregisterForUpdate(refreshTaskName)
        end
    end
    
    -- Lancement de la boucle progressive
    EVENT_MANAGER:RegisterForUpdate(refreshTaskName, 0, UpdateBatch)
end

function MyAddon:UpdateUITexts()
    if not mainWin then return end -- Sécurité

    if UpdateTitle then UpdateTitle() end

    -- Onglets de navigation
    btnAll:SetText(LGA_L("Obj.Myth"))
    btnItems:SetText(LGA_L("PISTES"))
    btnFragments:SetText(LGA_L("FAVORIS"))
    noteBtn:SetText(LGA_L("NOTES"))

    -- Barre de recherche
    if searchBox and (not MyAddon.savedVars.searchTerms[currentTab] or MyAddon.savedVars.searchTerms[currentTab] == "") then
        searchBox:SetText(LGA_L("SEARCH_PLACEHOLDER"))
    end
    
    -- Filtres Items
    btnFilterAll:SetText(LGA_L("Tous"))
    btnFilterAcquired:SetText(LGA_L("Possédé"))
    btnFilterUnacquired:SetText(LGA_L("Non possédé"))

    -- Filtres Pistes
    btnFragFilterAll:SetText(LGA_L("Tous"))
    btnFragFilterLeads:SetText(LGA_L("À creuser"))
    btnFragFilterAcquired:SetText(LGA_L("Possédé"))
    btnFragFilterUnacquired:SetText(LGA_L("Non possédé"))
    
    -- Re-population des menus déroulants pour mettre à jour leurs textes
    if PopulateRegionDropdown then PopulateRegionDropdown() end
    if PopulateTypeDropdown then PopulateTypeDropdown() end
    if PopulateQualityDropdown then PopulateQualityDropdown() end
    
    -- Bas de la fenêtre
    opacLabel:SetText(LGA_L("Opacité :"))
    UpdateLockVisuals()

    -- Mise à jour des textes des Popups d'action
    for _, popup in ipairs(actionPopupPool) do
        if popup and popup.data then
            -- 1. Boutons statiques
            popup.data.btnMap:SetText(LGA_L("Carte"))
            popup.data.btnSource:SetText(LGA_L("SOURCE_BTN"))
            popup.data.btnSkill:SetText(LGA_L("GO_TO_CIRCLE_BTN"))
            
            -- 2. Bouton Move/Fixed
            if popup.data.moveBtn then
                if popup.data.isFixed then
                    popup.data.moveBtn:SetText(LGA_L("BTN_FIXED_LABEL"))
                else
                    popup.data.moveBtn:SetText(LGA_L("BTN_MOVE_LABEL"))
                end
            end

            -- 3. Textes dynamiques (Indice, Raison, Bouton Sonder)
            if popup.data.antId then
                local antId = popup.data.antId
                
                -- A. Mise à jour de l'indice (MapText)
                local mapText = ""
                if MyAddon.AntiquityHints and MyAddon.AntiquityHints[antId] and MyAddon.AntiquityHints[antId].mapText then
                    mapText = MyAddon.AntiquityHints[antId].mapText
                end
                if mapText ~= "" then
                    popup.data.hintLabel:SetText(mapText)
                    popup.data.hintLabel:SetHidden(false)
                else
                    popup.data.hintLabel:SetHidden(true)
                end

                -- B. Mise à jour du statut (Raison et Bouton Sonder)
                local function SafeCall(funcName, ...)
                    local f = _G[funcName]
                    if type(f) ~= "function" then return nil end
                    local ok, res = pcall(f, ...)
                    if ok then return res end
                    return nil
                end

                local hasLead = SafeCall("DoesAntiquityHaveLead", antId)
                local isRecovered = false
                local recoveredCount = SafeCall("GetNumAntiquitiesRecovered", antId)
                if type(recoveredCount) == "number" and recoveredCount > 0 then isRecovered = true
                elseif SafeCall("DoesAntiquityNeedCombination", antId) then isRecovered = true end

                local isScryButtonClickable = hasLead and not isRecovered
                local reason = ""
                local canScryNow = false

                if isScryButtonClickable then
                    local failureReason = SafeCall("GetAntiquityScryFailureReason", antId)
                    if failureReason == SCRY_FAILURE_REASON_NONE then
                        canScryNow = true
                    else
                        if failureReason == SCRY_FAILURE_REASON_INCORRECT_ZONE then
                            local antZoneId = SafeCall("GetAntiquityZoneId", antId)
                            local zoneName = antZoneId and SafeCall("GetZoneNameById", antZoneId)
                            if zoneName then zoneName = zo_strformat("<<C:1>>", zoneName) else zoneName = "une autre zone" end
                            reason = LGA_L("REASON_WRONG_ZONE") .. zoneName
                        elseif failureReason == SCRY_FAILURE_REASON_NOT_ENOUGH_SKILL then
                            reason = LGA_L("REASON_NO_SKILL")
                        elseif failureReason == SCRY_FAILURE_REASON_META_ANTIQUTY_NOT_COMPLETE then
                            reason = LGA_L("REASON_META_MISSING")
                        else
                            reason = LGA_L("REASON_GENERIC")
                        end
                    end
                elseif isRecovered then
                    reason = LGA_L("REASON_RECOVERED")
                elseif not hasLead then
                    reason = LGA_L("REASON_NO_LEAD")
                end

                popup.data.infoLabel:SetText(reason)
                popup.data.infoLabel:SetHidden(reason == "")

                if canScryNow or isScryButtonClickable then
                    popup.data.btnScry:SetText(LGA_L("Sonder"))
                else
                    popup.data.btnScry:SetText(LGA_L("SCRY_UNAVAILABLE"))
                end
            else
                popup.data.btnScry:SetText(LGA_L("Sonder"))
            end

            -- Mise à jour du Timer si actif
            if popup.data.UpdateTimer then popup.data.UpdateTimer() end
        end
    end
    
    -- Barre minimisée
    local minLabel = minimizedBar and minimizedBar:GetNamedChild("Label")
    if minLabel then minLabel:SetText(LGA_L("Le Guide de L'Antiquaire")) end

    -- Bouton Valider dans le popup de langue
    local valBtn = _G["Le_Guide_de_L_Antiquaire_LangPopupValidateBtn"]
    if valBtn then valBtn:SetText(LGA_L("VALIDATE_BTN")) end

    -- Mise à jour du popup d'alarme
    if alarmDisplayPopup then
        local alarmTitle = alarmDisplayPopup:GetNamedChild("Title")
        if alarmTitle then
            alarmTitle:SetText(LGA_L("ALARM_POPUP_TITLE"))
        end
        local alarmMoveBtn = alarmDisplayPopup:GetNamedChild("Move")
        if alarmMoveBtn and alarmDisplayPopup.data then
            if alarmDisplayPopup.data.isFixed then
                alarmMoveBtn:SetText(LGA_L("BTN_FIXED_LABEL"))
            else
                alarmMoveBtn:SetText(LGA_L("BTN_MOVE_LABEL"))
            end
        end

        if not alarmDisplayPopup:IsHidden() then
            MyAddon:CheckForExpiringLeads(true)
        end
    end

    -- Signature
    local signature = _G["Le_Guide_de_L_Antiquaire_Signature"]
    if signature then signature:SetText(LGA_L("SIGNATURE")) end
end

function MyAddon:UpdateNoteView()
    local sv = MyAddon.savedVars
    if not noteTabsContainer then return end
    local scrollChild = noteTabsContainer:GetNamedChild("ScrollChild")
    if not scrollChild then return end -- Correction du NIL : on s'assure que le contrôle est prêt
    
    -- On s'assure que la sélection est valide
    if sv.currentNoteIndex and (sv.currentNoteIndex < 1 or sv.currentNoteIndex > 14) then
        sv.currentNoteIndex = nil
    end

    -- Création / Mise à jour des 15 boutons fixes (Slots)
    for i = 1, 14 do
        local noteTabBtn = scrollChild:GetNamedChild("NoteTab"..i) or wm:CreateControl("$(parent)NoteTab"..i, scrollChild, CT_BUTTON)
        noteTabBtn:SetHidden(false)
        noteTabBtn:SetDimensions(100, 25)
        noteTabBtn:ClearAnchors()
        noteTabBtn:SetAnchor(TOPLEFT, scrollChild, TOPLEFT, 0, (i-1) * 30)
        noteTabBtn:SetFont("ZoFontGameBold") -- Ajout de la police pour voir le texte
        
        -- Ajout d'un fond pour voir les boutons (les "slots")
        local btnBg = noteTabBtn:GetNamedChild("BG") or wm:CreateControl("$(parent)BG", noteTabBtn, CT_BACKDROP)
        btnBg:SetAnchorFill(noteTabBtn)
        btnBg:SetEdgeTexture("", 1, 1, 1)
        btnBg:SetDrawLayer(DL_BACKGROUND)
		
        local note = sv.userNotes[i]
        local hasContent = note and note.content and note.content ~= ""
        
        if hasContent then
            -- SLOT OCCUPÉ : On affiche le début du texte
            local title = note.content:sub(1, 10):gsub("\n", " ")
            if title:gsub("%s", "") == "" then title = tostring(i) end
            noteTabBtn:SetText(title)
        else
            -- SLOT VIDE : On affiche le numéro
            noteTabBtn:SetText(tostring(i))
        end

        -- Gestion des couleurs
        if i == sv.currentNoteIndex then
            noteTabBtn:SetNormalFontColor(1, 0.9, 0, 1) -- Sélectionné (Jaune)
		    btnBg:SetCenterColor(0.4, 0.4, 0, 0.5)      -- Fond Jaune sombre
            btnBg:SetEdgeColor(1, 0.9, 0, 1)	
        elseif hasContent then
            noteTabBtn:SetNormalFontColor(1, 1, 1, 1) -- Plein (Blanc)
			btnBg:SetCenterColor(0.2, 0.2, 0.2, 0.5)  -- Fond Gris moyen
            btnBg:SetEdgeColor(0.6, 0.6, 0.6, 1)
        else
            noteTabBtn:SetNormalFontColor(0.5, 0.5, 0.5, 1) -- Vide (Gris)
			btnBg:SetCenterColor(0.1, 0.1, 0.1, 0.3)        -- Fond Gris foncé
            btnBg:SetEdgeColor(0.3, 0.3, 0.3, 0.5)
        end

        noteTabBtn:SetHandler("OnClicked", function()
            sv.currentNoteIndex = i
            -- Si la note n'existe pas encore, on l'initialise vide pour pouvoir écrire
            if not sv.userNotes[i] then sv.userNotes[i] = { content = "" } end
            MyAddon:UpdateNoteView()
            noteEdit:TakeFocus()
        end)
    end
    scrollChild:SetHeight(10 * 30)

    -- Mise à jour de la zone d'édition
    if sv.currentNoteIndex then
        noteEdit:SetEditEnabled(true)
        local content = ""
        if sv.userNotes[sv.currentNoteIndex] then
            content = sv.userNotes[sv.currentNoteIndex].content or ""
        end
        -- On évite de reset le texte si c'est le même (pour ne pas perdre le curseur)
        if noteEdit:GetText() ~= content then
            noteEdit:SetText(content)
        end
        deleteNoteBtn:SetEnabled(true)
    else
        noteEdit:SetText("")
        noteEdit:SetEditEnabled(false)
        deleteNoteBtn:SetEnabled(false)
    end
end

-- 3. INTERFACE (UI)
function MyAddon:CreateUI()
    local sv = MyAddon.savedVars
    mainWin = wm:CreateTopLevelWindow("Le_Guide_de_L_Antiquaire_Main")
    mainWin:SetHidden(true) -- Important : On cache la fenêtre à la création pour que le Fragment gère la visibilité
    
    -- Z-Order : On met la fenêtre en arrière-plan (DT_LOW) pour que le Loot et autres fenêtres passent devant
    mainWin:SetDrawTier(DT_LOW) -- Correction : DT_LOW pour être sous les popups de loot (DT_HIGH)
    mainWin:SetDrawLayer(DL_BACKGROUND)
	mainWin:SetDrawLevel(1)
    
    -- GESTION DES SCÈNES (Pour cacher l'addon quand on ouvre l'inventaire, la carte, etc.)
    local fragment = MyAddonFragment:New(mainWin)
    SCENE_MANAGER:GetScene("hud"):AddFragment(fragment)
    SCENE_MANAGER:GetScene("hudui"):AddFragment(fragment)

    -- Restauration de l'onglet sauvegardé
    if sv.lastTab then currentTab = sv.lastTab end
    
    mainWin:SetDimensions(440, 600)
    mainWin:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.x, sv.y)
    mainWin:SetMovable(not sv.isLocked)
    mainWin:SetMouseEnabled(true)

    -- CORRECTION MAJEURE : CRÉATION DU FOND EN PREMIER
    -- Le fond doit être créé AVANT les boutons pour ne pas les recouvrir
    bg = mainWin:GetNamedChild("VraiFondNoir")
    if not bg then
        bg = wm:CreateControl("$(parent)VraiFondNoir", mainWin, CT_BACKDROP)
    end
    
    bg:SetAnchorFill(mainWin)
    -- L'apparence est entièrement gérée par UpdateFrameStyles et UpdateBackgroundStyle
    -- pour éviter les conflits au chargement. On initialise juste le fond.
    bg:SetCenterColor(0, 0, 0, 1)
    bg:SetDrawLayer(DL_BACKGROUND)
    
    local initialAlpha = (MyAddon.savedVars and MyAddon.savedVars.bgAlpha) or 1.0
    bg:SetAlpha(initialAlpha)
    -- FIN CORRECTION FOND

	-- mainWin:SetDrawTier(DT_HIGH) -- Remplacez DT_LOW par DT_HIGH si présent
	--bg:SetMouseEnabled(false)    -- Le fond ne doit pas intercepter les clics
    --listArea:SetMouseEnabled(false) -- Seuls les boutons à l'intérieur doivent être actifs
	
    -- Gestion du déplacement avec "Magnétisme" (Snapping)
    mainWin:SetHandler("OnMoveStop", function(self)
        local left = self:GetLeft()
        local top = self:GetTop()
        local w, h = self:GetDimensions()
        local screenW, screenH = GuiRoot:GetDimensions()
        local snap = 20 -- Distance en pixels pour l'effet aimant

        if left < snap then left = 0 end -- Aimant Gauche
        if (left + w) > (screenW - snap) then left = screenW - w end -- Aimant Droite
        if top < snap then top = 0 end -- Aimant Haut
        
        -- Gestion Verticale (Bas de l'écran)
        if isMinimized then
            -- Mode Réduit : Magnétisme simple en bas
            if (top + h) > (screenH - snap) then top = screenH - h end
        else
            -- Mode Agrandi : Redimensionnement dynamique
            local maxH = 600
            local minH = 300 -- 50% de la hauteur max
        
            -- Si on touche le bas
            if (top + maxH) > screenH then
                local availableH = screenH - top
                if availableH < minH then
                    -- On bloque à 300px du bas (ne peut pas aller plus bas)
                    top = screenH - minH
                    self:SetHeight(minH)
                else
                    -- On réduit la hauteur pour tenir
                    self:SetHeight(availableH)
                end
            else
                self:SetHeight(maxH)
            end
            
            -- Si on bouge la fenêtre manuellement, on oublie le décalage automatique
            sv.shiftY = 0
        end

        self:ClearAnchors()
        self:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
        sv.x, sv.y = left, top
    end)
	
	local mainBody = wm:CreateControl("$(parent)Body", mainWin, CT_CONTROL)
    mainBody:SetAnchor(TOPLEFT, mainWin, TOPLEFT, 30, 40) -- Commence sous la bande
    mainBody:SetAnchor(BOTTOMRIGHT, mainWin, BOTTOMRIGHT, 0, 0)

-- 1. FONCTION DE MISE À JOUR VISUELLE (Logique récupérée du secours)
    UpdateLockVisuals = function()
        if not lockBtn then return end
        if sv.isLocked then
            lockBtn:SetText(LGA_L("BTN_FIXED_LABEL")) -- F
            lockBtn:SetNormalFontColor(1, 0.2, 0.2, 1) -- Rouge
        else
            lockBtn:SetText(LGA_L("BTN_MOVE_LABEL")) -- M
            lockBtn:SetNormalFontColor(0.2, 1, 0.2, 1) -- Vert
        end
        mainWin:SetMovable(not sv.isLocked)
    end
    
    -- 4. INITIALISATION AU CHARGEMENT
    UpdateLockVisuals()
    
    -- On utilise un petit délai (0ms) pour laisser le temps au jeu de créer l'objet
    zo_callLater(function() UpdateLockVisuals() end, 1)

    -- Boutons en haut à droite
    closeBtn = wm:CreateControl("$(parent)CloseBtn", mainWin, CT_BUTTON)
    closeBtn:SetDimensions(25, 25)
    closeBtn:SetAnchor(TOPRIGHT, mainWin, TOPRIGHT, -5, 2)
    closeBtn:SetNormalTexture("EsoUI/art/buttons/decline_up.dds")
    closeBtn:SetMouseOverTexture("EsoUI/art/buttons/decline_over.dds")
    closeBtn:SetHandler("OnClicked", function()
        MyAddon.savedVars.isVisible = false
        mainWin:SetHidden(true)
    end)

    local minBtn = wm:CreateControl("$(parent)MinBtn", mainWin, CT_BUTTON)
    minBtn:SetDimensions(25, 25)
    minBtn:SetAnchor(TOPRIGHT, closeBtn, TOPLEFT, -2, 0)
    minBtn:SetNormalTexture("EsoUI/art/buttons/minus_up.dds")
    minBtn:SetMouseOverTexture("EsoUI/art/buttons/minus_over.dds")

    -- Le bandeau (caché par défaut)
    minimizedBar = wm:CreateControl("Le_Guide_de_L_Antiquaire_MinBar", GuiRoot, CT_BACKDROP)
    minimizedBar:SetDimensions(300, 35)
    minimizedBar:SetHidden(true)
    minimizedBar:SetCenterColor(0, 0, 0, 0.8)
    minimizedBar:SetEdgeColor(0.5, 0.5, 0.2, 1)
    minimizedBar:SetEdgeTexture("", 8, 1, 1)
    minimizedBar:SetMovable(true)
    minimizedBar:SetMouseEnabled(true)
    
    -- Texte sur le bandeau
    local minLabel = wm:CreateControl("$(parent)Label", minimizedBar, CT_LABEL)
    minLabel:SetFont("ZoFontGameBold")
    minLabel:SetText(LGA_L("Le Guide de L'Antiquaire"))
    minLabel:SetAnchor(LEFT, minimizedBar, LEFT, 10, 0)

    -- Bouton pour ré-ouvrir
    local restoreBtn = wm:CreateControl("$(parent)Restore", minimizedBar, CT_BUTTON)
    restoreBtn:SetDimensions(25, 25)
    restoreBtn:SetAnchor(RIGHT, minimizedBar, RIGHT, 10, 0)
    restoreBtn:SetNormalTexture("EsoUI/art/buttons/plus_up.dds")

-- Fonction rendue globale pour le raccourci clavier (LGA_TOGGLE_MINIMIZE)
function MyAddon.ToggleMinimize()
    isMinimized = not isMinimized
    sv.isMinimized = isMinimized -- Sauvegarde de l'état
    local sig = _G["Le_Guide_de_L_Antiquaire_Signature"]
    
    local left = mainWin:GetLeft()
    local top = mainWin:GetTop()
    local screenW, screenH = GuiRoot:GetDimensions()
    
    mainWin:ClearAnchors()
    
    -- Création/Récupération de l'icône pour le mode réduit
    local minIcon = mainWin:GetNamedChild("MinIcon") or wm:CreateControl("$(parent)MinIcon", mainWin, CT_TEXTURE)
    
    if isMinimized then
        -- DÉTERMINATION DE L'ITEM À AFFICHER
        local targetData = nil
        local targetIcon = nil
        local isFragment = false
        
        if sv.pinnedItem then
            if type(sv.pinnedItem) == "number" then
                targetData = MyAddon.MythicItems[sv.pinnedItem]
                if targetData then targetIcon = GetItemLinkInfo(targetData.itemLink) end
            elseif type(sv.pinnedItem) == "string" then
                local pId, fIdx = string.match(sv.pinnedItem, "frag_(%d+)_(%d+)")
                if pId and fIdx then
                    pId = tonumber(pId)
                    fIdx = tonumber(fIdx)
                    local parent = MyAddon.MythicItems[pId]
                    if parent and parent.fragments and parent.fragments[fIdx] then
                        targetData = parent.fragments[fIdx]
                        targetData.parentName = parent.name
                        targetIcon = GetItemLinkInfo(parent.itemLink)
                        isFragment = true
                    end
                else
                    -- Cas 2: Piste seule ou Fragment affiché seul (ex: lead_123 ou frag_single_123)
                    local antId = string.match(sv.pinnedItem, "lead_(%d+)")
                    if not antId then antId = string.match(sv.pinnedItem, "frag_single_(%d+)") end
                    
                    if antId then
                        antId = tonumber(antId)
                        -- On cherche dans AllLeads
                        for _, lead in ipairs(MyAddon.AllLeads) do
                            if lead.antiquityId == antId then
                                targetData = lead
                                isFragment = true
                                
                                -- Si aucune icône n'est trouvée (ou si elle est vide), on utilise l'icône par défaut demandée
                                if not targetIcon or targetIcon == "" then
                                    targetIcon = "Le_Guide_de_L_Antiquaire/Textures/Coeur.dds"
                                end
                                break
                            end
                        end
                    end
                end
            end
        end

        -- MODE RÉDUIT
        -- On annule le décalage éventuel pour remettre la barre à sa place d'origine
        local shift = sv.shiftY or 0
        local newY = top + shift
        
        -- On nettoie la variable
        sv.shiftY = 0
        
        mainWin:SetHeight(40)
        mainWin:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, newY)

        -- On cache tout massivement
        if listArea then listArea:SetHidden(true) end       
        if btnAll then btnAll:SetHidden(true) end
        if noteView then noteView:SetHidden(true) end
        if noteBtn then noteBtn:SetHidden(true) end
        if btnItems then btnItems:SetHidden(true) end
        if btnFragments then btnFragments:SetHidden(true) end
        if btnFilterAll then btnFilterAll:SetHidden(true) end
        if btnFilterAcquired then btnFilterAcquired:SetHidden(true) end
        if btnFilterUnacquired then btnFilterUnacquired:SetHidden(true) end
        if btnFragFilterAll then btnFragFilterAll:SetHidden(true) end
		if btnFragFilterLeads then btnFragFilterLeads:SetHidden(true) end
        if btnFragFilterAcquired then btnFragFilterAcquired:SetHidden(true) end
        if btnFragFilterUnacquired then btnFragFilterUnacquired:SetHidden(true) end
        if regionDropdown then regionDropdown:SetHidden(true) end
        if typeDropdown then typeDropdown:SetHidden(true) end
        if qualityDropdown then qualityDropdown:SetHidden(true) end
        if resetFiltersBtn then resetFiltersBtn:SetHidden(true) end
        if configArea then configArea:SetHidden(true) end
        if opacityControl then opacityControl:SetHidden(true) end
        if opacLabel then opacLabel:SetHidden(true) end
        if sig then sig:SetHidden(true) end
        if langBtn then langBtn:SetHidden(true) end
        if refreshBtn then refreshBtn:SetHidden(true) end
        if closeBtn then closeBtn:SetHidden(true) end
        if lockBtn then lockBtn:SetHidden(true) end
        if closeAllBtn then closeAllBtn:SetHidden(true) end
        if searchBox and searchBox:GetParent() then searchBox:GetParent():SetHidden(true) end

        if targetData then
            minIcon:SetHidden(false)
            minIcon:SetTexture(targetIcon or "/EsoUI/art/icons/inventory_gear_dummy.dds")
            minIcon:SetDimensions(30, 30)
            minIcon:ClearAnchors()
            minIcon:SetAnchor(LEFT, mainWin, LEFT, 5, 0)
            minIcon:SetMouseEnabled(true)
            minIcon:SetDrawLayer(DL_OVERLAY)
            minIcon:SetDrawLevel(2) -- On s'assure qu'elle est bien au-dessus pour l'interaction
            
            minIcon:SetHandler("OnMouseEnter", function(self)
                -- Affichage du tooltip à l'extérieur de la fenêtre réduite (Barre)
                local win = self:GetParent()
                local screenWidth = GuiRoot:GetWidth()
                local centerX = win:GetCenter()
                
                -- Choix du tooltip selon le type (InformationTooltip pour les images, ItemTooltip pour les items)
                local tooltip = isFragment and InformationTooltip or ItemTooltip
                
                if centerX < (screenWidth / 2) then
                    InitializeTooltip(tooltip, win, LEFT, 1, 0, RIGHT) -- Affiche à droite de la barre
                else
                    InitializeTooltip(tooltip, win, RIGHT, -1, 0, LEFT) -- Affiche à gauche de la barre
                end
                
                if isFragment then
                    FillFragmentTooltip(tooltip, targetData, targetData.parentName)
                else
                    if targetData.itemLink then
                        local interactiveLink = targetData.itemLink:gsub("|H0:", "|H1:")
                        pcall(function() tooltip:SetLink(interactiveLink) end)
                    end
                end
            end)
            minIcon:SetHandler("OnMouseExit", function() 
                ClearFragmentTooltip(InformationTooltip)
                ClearTooltip(ItemTooltip)
            end)
            
            titleLabel:ClearAnchors()
            titleLabel:SetAnchor(CENTER, mainWin, CENTER, 15, 0) -- On décale un peu le titre
        else
            minIcon:SetHidden(true)
            titleLabel:ClearAnchors()
            titleLabel:SetAnchor(CENTER, mainWin, CENTER, 0, 0)
        end
        
        titleLabel:SetText("|cBB9334" .. LGA_L("Le Guide de L'Antiquaire") .. "|r")
        minBtn:SetNormalTexture("EsoUI/art/buttons/plus_up.dds")
    else
        minIcon:SetHidden(true) -- On cache l'icône quand on agrandit
        -- MODE AGRANDI (OUVERTURE)
        local maxH = 600
        local minH = 300
        
        -- On regarde la place en dessous
        local spaceBelow = screenH - top
        local targetH = maxH
        local shiftY = 0
        
        if spaceBelow >= maxH then
            -- Cas 1: Large place en bas -> 600px
            targetH = maxH
        elseif spaceBelow >= minH then
            -- Cas 2: Place moyenne -> On remplit vers le bas (ex: 400px)
            targetH = spaceBelow
        else
            -- Cas 3: Pas assez de place en bas (< 300px) -> On doit compléter vers le HAUT
            -- "sans dépasser les 300px" -> On vise exactement 300px
            local neededUp = minH - spaceBelow
            
            -- On vérifie qu'on a la place en haut (pour ne pas sortir de l'écran)
            if top >= neededUp then
                shiftY = neededUp
                targetH = minH
            else
                -- Cas extrême (écran minuscule) : on prend tout ce qu'on peut
                shiftY = top
                targetH = spaceBelow + shiftY
            end
        end
        
        sv.shiftY = shiftY -- On mémorise le décalage pour le retour
        
        mainWin:SetHeight(targetH)
        mainWin:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top - shiftY)

        if opacityControl then opacityControl:SetHidden(false) end
        if opacLabel then opacLabel:SetHidden(false) end
        if sig then sig:SetHidden(false) end
        if langBtn then langBtn:SetHidden(false) end
        if refreshBtn then refreshBtn:SetHidden(false) end
        if closeBtn then closeBtn:SetHidden(false) end
        if lockBtn then lockBtn:SetHidden(false) end
        if closeAllBtn then closeAllBtn:SetHidden(false) end

        -- Gestion des pages
        if isViewingNotes then
            -- Affichage Page Notes
            if noteView then noteView:SetHidden(false) end
            if listArea then listArea:SetHidden(true) end
            if searchBox and searchBox:GetParent() then searchBox:GetParent():SetHidden(true) end

            -- Show tabs
            if btnAll then btnAll:SetHidden(false) end
            if btnItems then btnItems:SetHidden(false) end
            if btnFragments then btnFragments:SetHidden(false) end
            if noteBtn then noteBtn:SetHidden(false) end

            titleLabel:SetText(LGA_L("TITLE_NOTES"))
        else
            -- Affichage Page 1
            if noteView then noteView:SetHidden(true) end
            if listArea then listArea:SetHidden(false) end
            if searchBox and searchBox:GetParent() then searchBox:GetParent():SetHidden(false) end
            
            -- On réaffiche les onglets en mode liste
            if btnAll then btnAll:SetHidden(false) end
            if btnItems then btnItems:SetHidden(false) end
            if btnFragments then btnFragments:SetHidden(false) end
            if noteBtn then noteBtn:SetHidden(false) end
            
            if currentTab == "items" then
                if btnFilterAll then btnFilterAll:SetHidden(false) end
				if btnFragFilterLeads then btnFragFilterLeads:SetHidden(true) end
                if btnFilterAcquired then btnFilterAcquired:SetHidden(false) end
                if btnFilterUnacquired then btnFilterUnacquired:SetHidden(false) end
            elseif currentTab == "fragments" then
                if btnFragFilterAll then btnFragFilterAll:SetHidden(false) end
				if btnFragFilterLeads then btnFragFilterLeads:SetHidden(false) end
                if btnFragFilterAcquired then btnFragFilterAcquired:SetHidden(false) end
                if btnFragFilterUnacquired then btnFragFilterUnacquired:SetHidden(false) end
                if regionDropdown then regionDropdown:SetHidden(false) end
                if typeDropdown then typeDropdown:SetHidden(false) end
                if qualityDropdown then qualityDropdown:SetHidden(false) end
                if resetFiltersBtn then resetFiltersBtn:SetHidden(false) end
            elseif currentTab == "config" then
                if configArea then configArea:SetHidden(false) end
            end
            
            if currentTab == "fav" then
                titleLabel:SetText(LGA_L("TITLE_FAVORITES"))
            elseif currentTab == "items" then
                titleLabel:SetText(LGA_L("TITLE_MYTHICS"))
            elseif currentTab == "fragments" then
                titleLabel:SetText(LGA_L("TITLE_ALL_LEADS"))
            end
            RefreshList()
        end
        
        titleLabel:ClearAnchors()
        titleLabel:SetAnchor(TOP, mainWin, TOP, 0, 45)
        minBtn:SetNormalTexture("EsoUI/art/buttons/minus_up.dds")
    end
end

minBtn:SetHandler("OnClicked", MyAddon.ToggleMinimize)
    restoreBtn:SetHandler("OnClicked", MyAddon.ToggleMinimize)
	
    -- 2. FONCTION DE MISE À JOUR
    local function UpdateAlpha(delta)
        local sv = MyAddon.savedVars
        local currentAlpha = sv.bgAlpha or 1
        local newAlpha = math.max(0, math.min(1, currentAlpha + delta))
        
        sv.bgAlpha = newAlpha
        
        -- On applique l'alpha sur le Backdrop
        local backgroundControl = mainWin:GetNamedChild("VraiFondNoir")
        if backgroundControl then
            backgroundControl:SetAlpha(newAlpha)
        end

        if opacLabel then 
            local opacValueLabel = opacityControl and opacityControl:GetNamedChild("ValueLabel")
            if opacValueLabel then
                opacValueLabel:SetText(string.format("%d%%", math.floor(newAlpha * 100)))
            end
        end
    end
	
	function MyAddon.CloseAllPopups()
    for _, popup in ipairs(actionPopupPool) do
        if popup.data then popup.data.shouldBeVisible = false end
        if not popup:IsHidden() then
            popup:SetHidden(true)
        end
    end
end

    -- 3. INTERFACE (BOUTONS)
    opacityControl = mainWin:GetNamedChild("OpacGroup")
    opacityControl = opacityControl or wm:CreateControl("$(parent)OpacGroup", mainWin, CT_CONTROL)
    opacityControl:SetDimensions(200, 35)
    opacityControl:SetAnchor(BOTTOMLEFT, mainWin, BOTTOMLEFT, 10, 0)

    opacLabel = opacityControl:GetNamedChild("Label")
    opacLabel = opacLabel or wm:CreateControl("$(parent)Label", opacityControl, CT_LABEL)
    opacLabel:SetFont("ZoFontGameBold")
    opacLabel:SetText(LGA_L("Opacité :"))
    opacLabel:SetAnchor(LEFT, opacityControl, LEFT, 0, 0)

    local btnM = opacityControl:GetNamedChild("Minus")
    btnM = btnM or wm:CreateControl("$(parent)Minus", opacityControl, CT_BUTTON)
    btnM:SetText("-")
    btnM:SetDimensions(10, 25)
    btnM:SetAnchor(LEFT, opacLabel, RIGHT, 5, 0)
    btnM:SetFont("ZoFontGameBold")
    btnM:SetNormalFontColor(1, 0, 0, 1)
    btnM:SetHandler("OnClicked", function() UpdateAlpha(-0.1) end)

    local opacValueLabel = opacityControl:GetNamedChild("ValueLabel") or wm:CreateControl("$(parent)ValueLabel", opacityControl, CT_LABEL)
    opacValueLabel:SetFont("ZoFontGameBold")
    opacValueLabel:SetText(string.format("%d%%", initialAlpha * 100))
    opacValueLabel:SetAnchor(LEFT, btnM, RIGHT, 2, 0)
    opacValueLabel:SetWidth(40)
    opacValueLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    local btnP = opacityControl:GetNamedChild("Plus")
    btnP = btnP or wm:CreateControl("$(parent)Plus", opacityControl, CT_BUTTON)
    btnP:SetText("+")
    btnP:SetDimensions(10, 25)
    btnP:SetAnchor(LEFT, opacValueLabel, RIGHT, 5, 0)
    btnP:SetFont("ZoFontGameBold")
    btnP:SetNormalFontColor(0, 1, 0, 1)
    btnP:SetHandler("OnClicked", function() UpdateAlpha(0.1) end)

    -- Titre et Bouton Retour
    titleLabel = wm:CreateControl("$(parent)Title", mainWin, CT_LABEL)
    titleLabel:SetFont("ZoFontWinH2")
    titleLabel:SetAnchor(TOP, mainWin, TOP, 0, 45)

    -- Bouton TOUS
    btnAll = wm:CreateControl("$(parent)BtnAll", mainWin, CT_BUTTON)
    btnAll:SetText(LGA_L("Obj.Myth"))
    btnAll:SetDimensions(60, 25)
    btnAll:SetAnchor(TOPLEFT, mainWin, TOPLEFT, 70, 15)
    btnAll:SetFont("ZoFontGameBold")

    -- Bouton ITEMS
    btnItems = wm:CreateControl("$(parent)BtnItems", mainWin, CT_BUTTON)
    btnItems:SetText(LGA_L("PISTES"))
    btnItems:SetDimensions(70, 25)
    btnItems:SetAnchor(LEFT, btnAll, RIGHT, 5, 0)
    btnItems:SetFont("ZoFontGameBold")

    -- Bouton FRAGMENTS
    btnFragments = wm:CreateControl("$(parent)BtnFragments", mainWin, CT_BUTTON)
    btnFragments:SetText(LGA_L("FAVORIS"))
    btnFragments:SetDimensions(75, 25)
    btnFragments:SetAnchor(LEFT, btnItems, RIGHT, 5, 0)
    btnFragments:SetFont("ZoFontGameBold")
    
    -- Bouton FAVORIS
    btnFav = wm:CreateControl("$(parent)BtnFav", mainWin, CT_BUTTON)
    btnFav:SetText(LGA_L("FAVORIS"))
    btnFav:SetDimensions(75, 25)
    btnFav:SetAnchor(LEFT, btnFragments, RIGHT, 5, 0)
    btnFav:SetFont("ZoFontGameBold")
	
    -- BOUTON PRISE DE NOTE (transformé en onglet principal)
    noteBtn = wm:CreateControl("$(parent)NoteBtn", mainWin, CT_BUTTON)
    noteBtn:SetText(LGA_L("NOTES"))
    noteBtn:SetDimensions(70, 25)
    noteBtn:SetAnchor(LEFT, btnFragments, RIGHT, 5, 0)
    noteBtn:SetFont("ZoFontGameBold")

    -- Fonction pour mettre à jour le titre (avec couleur)
    local TITLE_COLOR = "|cBB9334"
    UpdateTitle = function()
        if not titleLabel then return end
        local titleText = ""
        if currentTab == "items" then
            titleText = TITLE_COLOR .. LGA_L("TITLE_MYTHICS") .. "|r"
        elseif currentTab == "fragments" then
            titleText = TITLE_COLOR .. LGA_L("TITLE_ALL_LEADS") .. "|r"
        elseif currentTab == "fav" then
            titleText = TITLE_COLOR .. LGA_L("TITLE_FAVORITES") .. "|r"
        elseif currentTab == "notes" then
            titleText = TITLE_COLOR .. LGA_L("TITLE_NOTES") .. "|r"
        end
        titleLabel:SetText(titleText)
    end

	-- Fonction pour mettre à jour les couleurs
    local function UpdateTabColors()
        -- Reset all to grey
        btnAll:SetNormalFontColor(0.5, 0.5, 0.5, 1) -- Obj.Myth
        btnItems:SetNormalFontColor(0.5, 0.5, 0.5, 1) -- PISTES
        btnFragments:SetNormalFontColor(0.5, 0.5, 0.5, 1) -- FAVORIS
        noteBtn:SetNormalFontColor(0.5, 0.5, 0.5, 1) -- NOTES

        if currentTab == "items" then
            btnAll:SetNormalFontColor(1, 0.9, 0, 1) -- "Obj.Myth" est maintenant l'ancien "items"
        elseif currentTab == "fragments" then
            btnItems:SetNormalFontColor(1, 0.9, 0, 1)
        elseif currentTab == "fav" then
            btnFragments:SetNormalFontColor(1, 0.9, 0, 1)
        elseif currentTab == "notes" then
            noteBtn:SetNormalFontColor(1, 0.9, 0, 1)
        end
    end

    -- Fonction générique pour changer d'onglet
    local function SwitchTab(tabName)
        currentTab = tabName
        MyAddon.savedVars.lastTab = tabName
        UpdateTabColors()
        UpdateTitle()

        -- Cache les filtres des autres onglets
        UpdateFilterVisibilityForTab(tabName)

        if tabName == "notes" then
            isViewingNotes = true
            listArea:SetHidden(true)
            noteView:SetHidden(false)
            if searchBox and searchBox:GetParent() then searchBox:GetParent():SetHidden(true) end
            MyAddon:UpdateNoteView()
        else
            isViewingNotes = false
            noteView:SetHidden(true)
            listArea:SetHidden(false)
            if searchBox and searchBox:GetParent() then searchBox:GetParent():SetHidden(false) end
            
            -- Met à jour le texte de la barre de recherche
            if not MyAddon.savedVars.searchTerms then
                MyAddon.savedVars.searchTerms = { all = "", items = "", fragments = "", fav = "" }
            end
            local searchTerm = MyAddon.savedVars.searchTerms[tabName] or ""
            if searchTerm == "" then
                searchBox:SetText(LGA_L("SEARCH_PLACEHOLDER"))
            else
                searchBox:SetText(searchTerm)
            end
            
            RefreshList()
        end
    end

    -- Handlers
    btnAll:SetHandler("OnClicked", function() SwitchTab("items") end)
    btnItems:SetHandler("OnClicked", function() SwitchTab("fragments") end)
    btnFragments:SetHandler("OnClicked", function() SwitchTab("fav") end)
    btnFav:SetHidden(true) -- On cache l'ancien bouton favoris
    noteBtn:SetHandler("OnClicked", function() SwitchTab("notes") end)
    
    -- Appliquer la couleur initiale
    UpdateTabColors()

    -- Barre de Recherche
    local sBack = wm:CreateControl("Le_Guide_de_L_Antiquaire_SearchBG", mainWin, CT_BACKDROP)
    sBack:SetDimensions(220, 30) 
    sBack:SetAnchor(TOP, mainWin, TOP, 0, 90)
    sBack:SetCenterColor(0, 0, 0, 0.5)
    sBack:SetEdgeColor(1, 1, 1, 0.3)
    sBack:SetEdgeTexture("", 8, 1, 1)

    searchBox = wm:CreateControl("Le_Guide_de_L_Antiquaire_Box", sBack, CT_EDITBOX)
    -- On ajoute une marge de 5 pixels à gauche pour décoller le texte du bord
    searchBox:SetAnchor(TOPLEFT, sBack, TOPLEFT, 5, 0)
    searchBox:SetAnchor(BOTTOMRIGHT, sBack, BOTTOMRIGHT, 0, 0)
    searchBox:SetFont("ZoFontGameBold")
    searchBox:SetEditEnabled(true)
    searchBox:SetMouseEnabled(true)
    -- On empêche le fond de bloquer le clic
    sBack:SetMouseEnabled(false)

    -- Compteur d'éléments
    itemCountLabel = wm:CreateControl("$(parent)ItemCount", sBack, CT_LABEL)
    itemCountLabel:SetAnchor(RIGHT, sBack, LEFT, -10, 0)
    itemCountLabel:SetFont("ZoFontGameBold")
    itemCountLabel:SetColor(1, 1, 1, 1)
    itemCountLabel:SetMouseEnabled(true)
    itemCountLabel:SetHandler("OnMouseEnter", function(self)
        InitializeTooltip(InformationTooltip, self, BOTTOM)
        InformationTooltip:AddLine(LGA_L("ITEM_COUNT_TOOLTIP"), "ZoFontGame")
    end)
    itemCountLabel:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)
	
    -- Bouton Effacer (X)
    local btnClear = wm:CreateControl("$(parent)BtnClear", sBack, CT_BUTTON)
    btnClear:SetDimensions(25, 25)
    btnClear:SetAnchor(CENTER_Y, sBack, CENTER_Y, 0, 0)
    btnClear:SetAnchor(LEFT, sBack, RIGHT, 5, 0)
    btnClear:SetNormalTexture("EsoUI/art/buttons/cancel_up.dds")
    btnClear:SetMouseOverTexture("EsoUI/art/buttons/cancel_over.dds")
    btnClear:SetHandler("OnClicked", function()
        MyAddon.savedVars.searchTerms[currentTab] = ""
        searchBox:SetText(LGA_L("SEARCH_PLACEHOLDER"))
        RefreshList()
    end)

    -- Bouton d'alarme
    alarmBtn = wm:CreateControl("Le_Guide_de_L_Antiquaire_AlarmBtn", sBack, CT_BUTTON)
    alarmBtn:SetDimensions(20, 25)
    alarmBtn:SetAnchor(LEFT, btnClear, RIGHT, 2, 0)
    ---alarmBtn:SetAnchor(CENTER_Y, btnClear, CENTER_Y, 0, 0)
    alarmBtn:SetHidden(true) -- Caché par défaut, visible via SwitchTab

    function MyAddon:UpdateAlarmButtonVisuals()
        local texture = MyAddon.savedVars.isAlarmActive and "Le_Guide_de_L_Antiquaire/Textures/AlarmON.dds" or "Le_Guide_de_L_Antiquaire/Textures/AlarmOFF.dds"
        alarmBtn:SetNormalTexture(texture)
    end

    alarmBtn:SetHandler("OnClicked", function()
        MyAddon.savedVars.isAlarmActive = not MyAddon.savedVars.isAlarmActive
        MyAddon:UpdateAlarmButtonVisuals()
    end)
    
    alarmBtn:SetHandler("OnMouseEnter", function(self)
        InitializeTooltip(InformationTooltip, self, BOTTOM)
        InformationTooltip:AddLine(LGA_L("ALARM_BUTTON_TOOLTIP_TITLE"))
        local text = MyAddon.savedVars.isAlarmActive and LGA_L("ALARM_BUTTON_TOOLTIP_TEXT_ON") or LGA_L("ALARM_BUTTON_TOOLTIP_TEXT_OFF")
        InformationTooltip:AddLine(text, "ZoFontGame")
    end)
    alarmBtn:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)

    -- Bouton Réglages Alarme (R)
    settingsBtn = wm:CreateControl("Le_Guide_de_L_Antiquaire_SettingsBtn", sBack, CT_BUTTON)
    settingsBtn:SetDimensions(20, 20)
    settingsBtn:SetAnchor(LEFT, alarmBtn, RIGHT, 2, 0)
    settingsBtn:SetHidden(true) -- Géré par UpdateFilterVisibilityForTab
    settingsBtn:SetText("R")
    settingsBtn:SetFont("ZoFontGameBold")
    settingsBtn:SetNormalFontColor(1, 0.9, 0, 1) -- Yellow

    settingsBtn:SetHandler("OnClicked", function()
        if LibAddonMenu2 and MyAddon.SettingsPanel then
            LibAddonMenu2:OpenToPanel(MyAddon.SettingsPanel)
        end
	end)
    settingsBtn:SetHandler("OnMouseEnter", function(self)
        -- Utilisation d'un appel protégé (pcall) pour intercepter toute erreur potentielle
        -- et empêcher le plantage de l'addon si le tooltip n'est pas prêt.
        pcall(function()
            InitializeTooltip(InformationTooltip, self, BOTTOM)
            if InformationTooltip then
                local title = LGA_L and LGA_L("ALARM_SETTINGS_BUTTON_TOOLTIP_TITLE") or "Settings"
                local text = LGA_L and LGA_L("ALARM_SETTINGS_BUTTON_TOOLTIP_TEXT") or "Click to open"
                
                InformationTooltip:AddLine(title)
                InformationTooltip:AddLine(text, "ZoFontGame")
            end
        end)
    end)
    settingsBtn:SetHandler("OnMouseExit", function() 
        pcall(function() ClearTooltip(InformationTooltip) end)
    end)

    -- Bouton Actualiser Alarme (Actu.dds)
    refreshAlarmBtn = wm:CreateControl("Le_Guide_de_L_Antiquaire_RefreshAlarmBtn", sBack, CT_BUTTON)
    refreshAlarmBtn:SetDimensions(25, 25)
    refreshAlarmBtn:SetAnchor(LEFT, settingsBtn, RIGHT, 2, 0)
    refreshAlarmBtn:SetHidden(true)
    refreshAlarmBtn:SetNormalTexture("Le_Guide_de_L_Antiquaire/Textures/Actu.dds")

    refreshAlarmBtn:SetHandler("OnClicked", function()
        MyAddon:CheckForExpiringLeads(true) -- true = déclenchement manuel
    end)

    refreshAlarmBtn:SetHandler("OnMouseEnter", function(self)
        InitializeTooltip(InformationTooltip, self, BOTTOM)
        InformationTooltip:AddLine(LGA_L("ALARM_REFRESH_BUTTON_TOOLTIP_TITLE"))
        InformationTooltip:AddLine(LGA_L("ALARM_REFRESH_BUTTON_TOOLTIP_TEXT"), "ZoFontGame")
    end)
    refreshAlarmBtn:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)

    -- Initialisation du texte de la barre de recherche au chargement
    if not sv.searchTerms then sv.searchTerms = { all = "", items = "", fragments = "", fav = "" } end
    local initialSearchTerm = sv.searchTerms[currentTab] or ""
    if initialSearchTerm == "" then
        searchBox:SetText(LGA_L("SEARCH_PLACEHOLDER"))
    else
        searchBox:SetText(initialSearchTerm)
    end

    searchBox:SetHandler("OnMouseDown", function(self) 
        if self:GetText() == LGA_L("SEARCH_PLACEHOLDER") then self:SetText("") end
        self:TakeFocus() 
    end)
    searchBox:SetHandler("OnTextChanged", function(self)
        local text = self:GetText()

        if text == LGA_L("SEARCH_PLACEHOLDER") then text = "" end
        
        if not MyAddon.savedVars.searchTerms then
            MyAddon.savedVars.searchTerms = { all = "", items = "", fragments = "", fav = "" }
        end
        MyAddon.savedVars.searchTerms[currentTab] = text
        RefreshList()
    end)
    searchBox:SetHandler("OnFocusLost", function(self)
        if MyAddon.savedVars.searchTerms[currentTab] == "" then
            self:SetText(LGA_L("SEARCH_PLACEHOLDER"))
        end
    end)

    -- Filtres pour l'onglet ITEMS
    btnFilterAll = wm:CreateControl("$(parent)BtnFilterAll", mainWin, CT_BUTTON)
    btnFilterAll:SetText(LGA_L("Tous"))
    btnFilterAll:SetDimensions(60, 20)
    btnFilterAll:SetAnchor(TOP, mainWin, TOP, -105, 125)
    btnFilterAll:SetFont("ZoFontGameBold")
    btnFilterAll:SetHidden(true)

    btnFilterAcquired = wm:CreateControl("$(parent)BtnFilterAcquired", mainWin, CT_BUTTON)
    btnFilterAcquired:SetText(LGA_L("Possédé"))
    btnFilterAcquired:SetDimensions(80, 20)
    btnFilterAcquired:SetAnchor(LEFT, btnFilterAll, RIGHT, 5, 0)
    btnFilterAcquired:SetFont("ZoFontGameBold")
    btnFilterAcquired:SetHidden(true)

    btnFilterUnacquired = wm:CreateControl("$(parent)BtnFilterUnacquired", mainWin, CT_BUTTON)
    btnFilterUnacquired:SetText(LGA_L("Non possédé"))
    btnFilterUnacquired:SetDimensions(100, 20)
    btnFilterUnacquired:SetAnchor(LEFT, btnFilterAcquired, RIGHT, 5, 0)
    btnFilterUnacquired:SetFont("ZoFontGameBold")
    btnFilterUnacquired:SetHidden(true)

    local function UpdateFilterButtonsState()
        btnFilterAll:SetNormalFontColor(0.5, 0.5, 0.5, 1)
        btnFilterAcquired:SetNormalFontColor(0.5, 0.5, 0.5, 1)
        btnFilterUnacquired:SetNormalFontColor(0.5, 0.5, 0.5, 1)

        if sv.itemFilterState == "all" then
            btnFilterAll:SetNormalFontColor(1, 1, 1, 1)
        elseif sv.itemFilterState == "acquired" then
            btnFilterAcquired:SetNormalFontColor(0, 1, 0, 1)
        elseif sv.itemFilterState == "unacquired" then
            btnFilterUnacquired:SetNormalFontColor(1, 0, 0, 1)
        end
    end
    UpdateFilterButtonsState()

    btnFilterAll:SetHandler("OnClicked", function()
        sv.itemFilterState = "all"
        UpdateFilterButtonsState()
        RefreshList()
    end)
    btnFilterAcquired:SetHandler("OnClicked", function()
        sv.itemFilterState = "acquired"
        UpdateFilterButtonsState()
        RefreshList()
    end)
    btnFilterUnacquired:SetHandler("OnClicked", function()
        sv.itemFilterState = "unacquired"
        UpdateFilterButtonsState()
        RefreshList()
    end)

    -- Filtres pour l'onglet FRAGMENTS
    btnFragFilterAll = wm:CreateControl("$(parent)BtnFragFilterAll", mainWin, CT_BUTTON)
    btnFragFilterAll:SetText(LGA_L("Tous"))
    btnFragFilterAll:SetDimensions(60, 20)
    btnFragFilterAll:SetAnchor(TOP, mainWin, TOP, -140, 125)
    btnFragFilterAll:SetFont("ZoFontGameBold")
    btnFragFilterAll:SetHidden(true)

    -- Bouton "À creuser"
    btnFragFilterLeads = wm:CreateControl("$(parent)BtnFragFilterLeads", mainWin, CT_BUTTON)
    btnFragFilterLeads:SetText(LGA_L("À creuser"))
    btnFragFilterLeads:SetDimensions(80, 20)
    btnFragFilterLeads:SetAnchor(LEFT, btnFragFilterAll, RIGHT, 5, 0)
    btnFragFilterLeads:SetFont("ZoFontGameBold")
    btnFragFilterLeads:SetHidden(true)

    -- MENU DÉROULANT DES ZONES
    regionDropdown = wm:CreateControlFromVirtual("$(parent)RegionDropdown", mainWin, "ZO_ComboBox")
    regionDropdown:SetDimensions(120, 24)
    regionDropdown:SetAnchor(TOPLEFT, btnFragFilterAll, BOTTOMLEFT, -15, 10) -- En dessous des filtres
    regionDropdown:SetHidden(true)
    regionDropdown:SetDrawTier(DT_HIGH) -- On force l'affichage au-dessus

    local m_comboBox = regionDropdown.m_comboBox
    m_comboBox:SetSortsItems(false) 
    m_comboBox:SetFont("ZoFontGameSmall")

    local function OnRegionSelected(comboBox, entryText, entry)
        MyAddon.savedVars.regionFilter = entry.zoneId
        RefreshList()
    end

    PopulateRegionDropdown = function()
        m_comboBox:ClearItems()
        local savedZoneId = MyAddon.savedVars.regionFilter
        local entryToSelect = nil
        
        -- Option "Toutes les zones"
        local allEntry = m_comboBox:CreateItemEntry(LGA_L("ALL_ZONES"), OnRegionSelected)
        allEntry.zoneId = 0 
        m_comboBox:AddItem(allEntry)
        if savedZoneId == 0 then entryToSelect = allEntry end
        
        -- Option "Zone actuelle"
        local currentEntry = m_comboBox:CreateItemEntry(LGA_L("CURRENT_ZONE"), OnRegionSelected)
        currentEntry.zoneId = -1
        m_comboBox:AddItem(currentEntry)
        if savedZoneId == -1 then entryToSelect = currentEntry end

        -- Collecte dynamique des zones depuis toutes les pistes (AllLeads)
        local zones = {}
        for _, lead in ipairs(MyAddon.AllLeads) do
            -- On exclut ZONEID_ALLZONES (101010) pour éviter le doublon avec le filtre "Toutes les zones" (0)
            if lead.zoneId and lead.zoneId > 0 and lead.zoneId ~= MyAddon.ZONEID_ALLZONES and not zones[lead.zoneId] then
                zones[lead.zoneId] = GetSpecialZoneName(lead.zoneId)
            end
            if lead.digZoneId and lead.digZoneId > 0 and lead.digZoneId ~= MyAddon.ZONEID_ALLZONES and not zones[lead.digZoneId] then
                zones[lead.digZoneId] = GetSpecialZoneName(lead.digZoneId)
            end
        end
        
        -- Tri et ajout
        local sortedZones = {}
        for id, name in pairs(zones) do table.insert(sortedZones, {id = id, name = CleanText(name), realName = name}) end
        table.sort(sortedZones, function(a,b) return a.name < b.name end)

        for _, z in ipairs(sortedZones) do
            -- Ajout de couleur pour faire joli
            local entry = m_comboBox:CreateItemEntry("|cCCCCCC" .. zo_strformat("<<1>>", z.realName) .. "|r", OnRegionSelected)
            entry.zoneId = z.id
            m_comboBox:AddItem(entry)
            if savedZoneId == z.id then entryToSelect = entry end
        end
        
        -- Sélectionne l'entrée sauvegardée ou la première par défaut
        if entryToSelect then
            m_comboBox:SelectItem(entryToSelect, true)
        else
            m_comboBox:SelectItemByIndex(1, true)
        end
    end
    PopulateRegionDropdown()

    -- MENU DÉROULANT TYPE (Mythique / Autre)
    typeDropdown = wm:CreateControlFromVirtual("$(parent)TypeDropdown", mainWin, "ZO_ComboBox")
    typeDropdown:SetDimensions(120, 24)
    typeDropdown:SetAnchor(LEFT, regionDropdown, RIGHT, 5, 0)
    typeDropdown:SetHidden(true)
    typeDropdown:SetDrawTier(DT_HIGH)

    local t_comboBox = typeDropdown.m_comboBox
    t_comboBox:SetSortsItems(false)
    t_comboBox:SetFont("ZoFontGameSmall")

    local OnTypeSelected = function(comboBox, entryText, entry)
        MyAddon.savedVars.typeFilter = entry.typeName
        RefreshList()
    end

    PopulateTypeDropdown = function()
        t_comboBox:ClearItems()
        local savedType = MyAddon.savedVars.typeFilter
        local entryToSelect = nil

        local typeAll = t_comboBox:CreateItemEntry(LGA_L("ALL_TYPES"), OnTypeSelected)
        typeAll.typeName = "__ALL_TYPES__"
        t_comboBox:AddItem(typeAll)
        if savedType == "__ALL_TYPES__" then entryToSelect = typeAll end

        -- Collecte dynamique des types depuis toutes les pistes
        local types = {}
        for _, lead in ipairs(MyAddon.AllLeads) do
            if lead.typeName and lead.typeName ~= "" and not types[lead.typeName] then
                types[lead.typeName] = true
            end
        end

        local sortedTypes = {}
        for tName in pairs(types) do table.insert(sortedTypes, tName) end
        table.sort(sortedTypes)

        for _, tName in ipairs(sortedTypes) do
            -- Ajout de couleur pour faire joli
            local entry = t_comboBox:CreateItemEntry("|cCCCCCC" .. tName .. "|r", OnTypeSelected)
            entry.typeName = tName
            t_comboBox:AddItem(entry)
            if savedType == tName then entryToSelect = entry end
        end
        
        if entryToSelect then
            t_comboBox:SelectItem(entryToSelect, true)
        else
            t_comboBox:SelectItemByIndex(1, true)
        end
    end
    PopulateTypeDropdown()

    -- MENU DÉROULANT QUALITÉ
    qualityDropdown = wm:CreateControlFromVirtual("$(parent)QualityDropdown", mainWin, "ZO_ComboBox")
    qualityDropdown:SetDimensions(120, 24)
    qualityDropdown:SetAnchor(LEFT, typeDropdown, RIGHT, 5, 0)
    qualityDropdown:SetHidden(true)
    qualityDropdown:SetDrawTier(DT_HIGH)

    local q_comboBox = qualityDropdown.m_comboBox
    q_comboBox:SetSortsItems(false)
    q_comboBox:SetFont("ZoFontGameSmall")

    local OnQualitySelected = function(comboBox, entryText, entry)
        MyAddon.savedVars.qualityFilter = entry.qualityId
        RefreshList()
    end

    PopulateQualityDropdown = function()
        q_comboBox:ClearItems()
        local savedQualityId = MyAddon.savedVars.qualityFilter
        local entryToSelect = nil

        local qAll = q_comboBox:CreateItemEntry(LGA_L("ALL_QUALITIES"), OnQualitySelected)
        qAll.qualityId = 0
        q_comboBox:AddItem(qAll)
        if savedQualityId == 0 then entryToSelect = qAll end

        -- Option Inclusive (Intégrée)
        local isChecked = MyAddon.savedVars.qualityInclusive
        local checkColor = isChecked and "|c00FF00" or "|cFF0000"
        local checkIcon = isChecked and "[x]" or "[ ]"
        local incText = checkColor .. checkIcon .. "|r " .. LGA_L("QUALITY_INCLUSIVE_TOOLTIP_TITLE")
        
        local incEntry = q_comboBox:CreateItemEntry(incText, function() 
            MyAddon.savedVars.qualityInclusive = not MyAddon.savedVars.qualityInclusive
            RefreshList()
            PopulateQualityDropdown() -- On rafraîchit le menu pour mettre à jour la coche
        end)
        
        -- Ajout de l'infobulle pour l'option inclusive
        incEntry.OnMouseEnter = function(self)
            -- 'self' est le contrôle de la ligne dans le menu déroulant
            InitializeTooltip(InformationTooltip, self, RIGHT)
            InformationTooltip:AddLine(LGA_L("QUALITY_INCLUSIVE_TOOLTIP_TITLE"), "ZoFontWinH2")
            InformationTooltip:AddLine(LGA_L("QUALITY_INCLUSIVE_TOOLTIP_TEXT"), "ZoFontGame")
        end
        incEntry.OnMouseExit = function() ClearTooltip(InformationTooltip) end
        
        q_comboBox:AddItem(incEntry)

        -- Scan dynamique des qualités présentes dans la base de données
        local foundQualities = {}
        for _, lead in ipairs(MyAddon.AllLeads) do
            if lead.quality and lead.quality > 0 then
                foundQualities[lead.quality] = true
            end
            -- On vérifie aussi la qualité du set parent (pour détecter les Mythiques dont les pistes sont seulement "Or")
            if lead.setId and lead.setId > 0 then
                local setQ = GetAntiquitySetQuality(lead.setId)
                if setQ == 5 then foundQualities[5] = true end
            end
        end

        -- Mapping : ID Qualité Antiquité -> Nom & Couleur
        local qualityMap = {
            [1] = {key="QUALITY_GREEN", color=GetItemQualityColor(2)},
            [2] = {key="QUALITY_BLUE", color=GetItemQualityColor(3)},
            [3] = {key="QUALITY_EPIC", color=GetItemQualityColor(4)},
            [4] = {key="QUALITY_LEGENDARY", color=GetItemQualityColor(5)},
            [5] = {key="QUALITY_MYTHIC", colorHex="FF5500"}
        }

        -- Tri des IDs trouvés pour l'affichage
        local sortedQ = {}
        for qId in pairs(foundQualities) do table.insert(sortedQ, qId) end
        table.sort(sortedQ)

        for _, qId in ipairs(sortedQ) do
            local info = qualityMap[qId]
            if info then
                local colorHex = info.colorHex or info.color:ToHex()
                local entry = q_comboBox:CreateItemEntry("|c" .. colorHex .. LGA_L(info.key) .. "|r", OnQualitySelected)
                entry.qualityId = qId
                q_comboBox:AddItem(entry)
                if savedQualityId == qId then entryToSelect = entry end
            end
        end

        if entryToSelect then
            q_comboBox:SelectItem(entryToSelect, true)
        else
            q_comboBox:SelectItemByIndex(1, true)
        end
    end
    PopulateQualityDropdown()

    -- Bouton Réinitialiser Filtres
    resetFiltersBtn = wm:CreateControl("Le_Guide_de_L_Antiquaire_ResetFiltersBtn", mainWin, CT_BUTTON)
    resetFiltersBtn:SetDimensions(25, 25)
    resetFiltersBtn:SetAnchor(LEFT, qualityDropdown, RIGHT, 5, 0)
    resetFiltersBtn:SetHidden(true) -- Géré par UpdateFilterVisibilityForTab
    resetFiltersBtn:SetNormalTexture("Le_Guide_de_L_Antiquaire/Textures/Reset.dds")
    resetFiltersBtn:SetMouseOverTexture("Le_Guide_de_L_Antiquaire/Textures/Reset.dds")

    resetFiltersBtn:SetHandler("OnClicked", function()
        -- Reset saved variables
        MyAddon.savedVars.regionFilter = 0
        MyAddon.savedVars.typeFilter = "__ALL_TYPES__"
        MyAddon.savedVars.qualityFilter = 0
        MyAddon.savedVars.qualityInclusive = false
        MyAddon.savedVars.searchTerms.fragments = ""

        -- Update UI controls
        PopulateRegionDropdown()
        PopulateTypeDropdown()
        PopulateQualityDropdown()
        searchBox:SetText(LGA_L("SEARCH_PLACEHOLDER"))

        -- Refresh the list
        RefreshList()
    end)
    resetFiltersBtn:SetHandler("OnMouseEnter", function(self)
        InitializeTooltip(InformationTooltip, self, BOTTOM)
        InformationTooltip:AddLine(LGA_L("RESET_FILTERS_TOOLTIP_TITLE"), "ZoFontWinH2")
        InformationTooltip:AddLine(LGA_L("RESET_FILTERS_TOOLTIP_TEXT"), "ZoFontGame")
    end)
    resetFiltersBtn:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)

    btnFragFilterAcquired = wm:CreateControl("$(parent)BtnFragFilterAcquired", mainWin, CT_BUTTON)
    btnFragFilterAcquired:SetText(LGA_L("Possédé"))
    btnFragFilterAcquired:SetDimensions(80, 20)
    btnFragFilterAcquired:SetAnchor(LEFT, btnFragFilterLeads, RIGHT, 5, 0) -- Ancré après "À creuser"
    btnFragFilterAcquired:SetFont("ZoFontGameBold")
    btnFragFilterAcquired:SetHidden(true)

    btnFragFilterUnacquired = wm:CreateControl("$(parent)BtnFragFilterUnacquired", mainWin, CT_BUTTON)
    btnFragFilterUnacquired:SetText(LGA_L("Non possédé"))
    btnFragFilterUnacquired:SetDimensions(100, 20)
    btnFragFilterUnacquired:SetAnchor(LEFT, btnFragFilterAcquired, RIGHT, 5, 0)
    btnFragFilterUnacquired:SetFont("ZoFontGameBold")
    btnFragFilterUnacquired:SetHidden(true)

    local function UpdateFragFilterButtonsState()
        btnFragFilterAll:SetNormalFontColor(0.5, 0.5, 0.5, 1)
        btnFragFilterLeads:SetNormalFontColor(0.5, 0.5, 0.5, 1)
        btnFragFilterAcquired:SetNormalFontColor(0.5, 0.5, 0.5, 1)
        btnFragFilterUnacquired:SetNormalFontColor(0.5, 0.5, 0.5, 1)

        if sv.fragmentFilterState == "all" then
            btnFragFilterAll:SetNormalFontColor(1, 1, 1, 1)
        elseif sv.fragmentFilterState == "leads" then
            btnFragFilterLeads:SetNormalFontColor(1, 0.9, 0, 1) -- Jaune pour les pistes actives
        elseif sv.fragmentFilterState == "acquired" then
            btnFragFilterAcquired:SetNormalFontColor(0, 1, 0, 1)
        elseif sv.fragmentFilterState == "unacquired" then
            btnFragFilterUnacquired:SetNormalFontColor(1, 0, 0, 1)
        end
    end
    UpdateFragFilterButtonsState()

    btnFragFilterAll:SetHandler("OnMouseUp", function(self, button, upInside)
        if upInside and button == MOUSE_BUTTON_INDEX_LEFT then
            sv.fragmentFilterState = "all"
            UpdateFragFilterButtonsState()
            RefreshList()
            PlaySound(SOUNDS.DEFAULT_CLICK)
        end
    end)
    btnFragFilterLeads:SetHandler("OnMouseUp", function(self, button, upInside)
        if upInside and button == MOUSE_BUTTON_INDEX_LEFT then
            sv.fragmentFilterState = "leads"
            UpdateFragFilterButtonsState()
            RefreshList()
            PlaySound(SOUNDS.DEFAULT_CLICK)
        end
    end)
    btnFragFilterAcquired:SetHandler("OnMouseUp", function(self, button, upInside)
        if upInside and button == MOUSE_BUTTON_INDEX_LEFT then
            sv.fragmentFilterState = "acquired"
            UpdateFragFilterButtonsState()
            RefreshList()
            PlaySound(SOUNDS.DEFAULT_CLICK)
        end
    end)
    btnFragFilterUnacquired:SetHandler("OnMouseUp", function(self, button, upInside)
        if upInside and button == MOUSE_BUTTON_INDEX_LEFT then
            sv.fragmentFilterState = "unacquired"
            UpdateFragFilterButtonsState()
            RefreshList()
            PlaySound(SOUNDS.DEFAULT_CLICK)
        end
    end)

    noteView = mainWin:GetNamedChild("NoteView") or wm:CreateControl("$(parent)NoteView", mainWin, CT_CONTROL)
	noteView:ClearAnchors()
    noteView:SetAnchor(TOPLEFT, mainWin, TOPLEFT, -140, 90)
    noteView:SetAnchor(BOTTOMRIGHT, mainWin, BOTTOMRIGHT, -140, -50)
    noteView:SetHidden(true)

    noteTabsContainer = noteView:GetNamedChild("NoteTabs") or wm:CreateControlFromVirtual("$(parent)NoteTabs", noteView, "ZO_ScrollContainer")
    noteTabsContainer:SetAnchor(TOPLEFT, noteView, TOPLEFT, 2, 0) -- Collé au bord gauche
    noteTabsContainer:SetAnchor(BOTTOM, noteView, BOTTOM, 0, -40)
    noteTabsContainer:SetWidth(120) -- Largeur augmentée pour afficher les boutons en entier

    -- Suppression du fond (cadre) qui gênait la visibilité
    if noteTabsContainer:GetNamedChild("Bg") then noteTabsContainer:GetNamedChild("Bg"):SetHidden(true) end

    noteEdit = noteView:GetNamedChild("Edit") or wm:CreateControl("$(parent)Edit", noteView, CT_EDITBOX)
    noteEdit:SetAnchor(TOPLEFT, noteTabsContainer, TOPRIGHT, 2, 0)
    noteEdit:SetAnchor(BOTTOMRIGHT, noteView, BOTTOMRIGHT, 120, 0)
    noteEdit:SetFont("ZoFontGame")
    noteEdit:SetMultiLine(true)
    noteEdit:SetMaxInputChars(3000)
    noteEdit:SetEditEnabled(true)
    noteEdit:SetMouseEnabled(true) -- Permet de cliquer dans la zone pour prendre le focus

    local noteEditBg = noteEdit:GetNamedChild("Bg") or wm:CreateControl("$(parent)Bg", noteEdit, CT_BACKDROP)
    noteEditBg:SetAnchorFill(noteEdit)
    noteEditBg:SetCenterColor(0, 0, 0, 0.5)

    noteEdit:SetHandler("OnTextChanged", function(self)
        if sv.currentNoteIndex then
            -- Création à la volée si nécessaire
            if not sv.userNotes[sv.currentNoteIndex] then
                sv.userNotes[sv.currentNoteIndex] = { content = "" }
            end
            
            local text = self:GetText()
            sv.userNotes[sv.currentNoteIndex].content = text
            
            -- Mise à jour immédiate du titre du bouton (10 premiers caractères)
            local scrollChild = noteTabsContainer:GetNamedChild("ScrollChild")
            if scrollChild then
                local btn = scrollChild:GetNamedChild("NoteTab"..sv.currentNoteIndex)
                if btn then
                    local title = text:sub(1, 10):gsub("\n", " ")
                    if title:gsub("%s", "") == "" then title = tostring(sv.currentNoteIndex) end
                    btn:SetText(title)
                    -- Le bouton reste jaune car il est sélectionné
                end
            end
        end
    end)

    deleteNoteBtn = noteView:GetNamedChild("DeleteNoteBtn") or wm:CreateControl("$(parent)DeleteNoteBtn", noteView, CT_BUTTON)
    deleteNoteBtn:SetDimensions(30, 30)
    deleteNoteBtn:ClearAnchors()
    deleteNoteBtn:SetAnchor(TOP, noteTabsContainer, BOTTOM, -10, 5) -- Centré sous la liste (-10, 5)
    deleteNoteBtn:SetText("X")
    deleteNoteBtn:SetFont("ZoFontGameBold")
    deleteNoteBtn:SetNormalFontColor(1, 0.2, 0.2, 1)
    deleteNoteBtn:SetHandler("OnClicked", function()
        if sv.currentNoteIndex then
            sv.userNotes[sv.currentNoteIndex] = nil -- On vide l'emplacement
            -- On ne change pas l'index, on reste sur le slot (qui devient vide)
            MyAddon:UpdateNoteView()
        end
    end)

    -- Bouton de Langue
    langBtn = wm:CreateControl("$(parent)LangBtn", mainWin, CT_BUTTON)
    langBtn:SetDimensions(25, 25)
    langBtn:SetAnchor(BOTTOMRIGHT, mainWin, BOTTOMRIGHT, -180, -3)
    langBtn:SetText("")
    local currentLang = MyAddon.savedVars.language or "fr"
    langBtn:SetNormalTexture("Le_Guide_de_L_Antiquaire/Textures/Trad.dds")

    -- Popup pour les langues
    local langPopup = wm:CreateTopLevelWindow("Le_Guide_de_L_Antiquaire_LangPopup")
    langPopup:SetDimensions(200, 90)
    langPopup:SetHidden(true)
    langPopup:SetDrawTier(DT_MEDIUM)
    langPopup:SetDrawLayer(DL_BACKGROUND)
    langPopup:SetClampedToScreen(true)
    local langPopupBg = wm:CreateControl("$(parent)Bg", langPopup, CT_BACKDROP)
    langPopupBg:SetAnchorFill(langPopup)
    langPopupBg:SetCenterColor(0, 0, 0, 0.9)
    langPopupBg:SetEdgeColor(0.6, 0.6, 0.6, 1)

    local languages = {"fr", "en", "de", "es", "ru"}
    local langNames = {
        fr = "Français",
        en = "English",
        de = "Deutsch",
        es = "Español",
        ru = "Русский",
    }
    local flagSize, padding = 32, 5
    langPopup:SetWidth((#languages * flagSize) + ((#languages + 1) * padding))
    
    local flagButtons = {}
    for i, langCode in ipairs(languages) do
        local flagBtn = wm:CreateControl("$(parent)Flag_" .. langCode, langPopup, CT_BUTTON)
        flagBtn:SetDimensions(flagSize, flagSize)
        flagBtn:SetAnchor(TOPLEFT, langPopup, TOPLEFT, padding + (i-1) * (flagSize + padding), 10)
        flagBtn:SetNormalTexture("Le_Guide_de_L_Antiquaire/Textures/" .. langCode .. ".dds")
        flagButtons[langCode] = flagBtn
        flagBtn:SetHandler("OnClicked", function() 
            MyAddon:ChangeLanguage(langCode)
            -- Mise à jour visuelle (Highlight / Dim)
            for code, btn in pairs(flagButtons) do
                btn:SetAlpha(code == langCode and 1 or 0.3)
            end
        end)
        flagBtn:SetHandler("OnMouseEnter", function(self)
            InitializeTooltip(InformationTooltip, self, TOP)
            InformationTooltip:AddLine(langNames[langCode] or langCode)
        end)
        flagBtn:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)
    end

    -- Bouton Valider (Remplace Refresh)
    local validateBtn = wm:CreateControl("$(parent)ValidateBtn", langPopup, CT_BUTTON)
    validateBtn:SetDimensions(120, 25)
    validateBtn:SetAnchor(TOP, langPopup, TOP, 0, 50)
    validateBtn:SetFont("ZoFontGameBold")
    validateBtn:SetText(LGA_L("VALIDATE_BTN"))
    
    local valBg = wm:CreateControl("$(parent)Bg", validateBtn, CT_BACKDROP)
    valBg:SetAnchorFill(validateBtn)
    valBg:SetCenterColor(0.2, 0.2, 0.2, 1)
    valBg:SetEdgeColor(0.4, 0.4, 0.4, 1)
    valBg:SetEdgeTexture("", 1, 1, 1)
    valBg:SetDrawLayer(DL_BACKGROUND)
    valBg:SetMouseEnabled(false)

    validateBtn:SetHandler("OnClicked", function()
        -- Action de l'ancien bouton Refresh
        if MyAddon.savedVars.searchTerms and MyAddon.savedVars.searchTerms[currentTab] then
            MyAddon.savedVars.searchTerms[currentTab] = ""
        end
        if searchBox then
            searchBox:SetText(LGA_L("SEARCH_PLACEHOLDER"))
        end
        MyAddon:UpdateUITexts()
        RefreshList()
        langPopup:SetHidden(true)
    end)

    langBtn:SetHandler("OnClicked", function(self)
        langPopup:ClearAnchors()
        langPopup:SetAnchor(BOTTOM, self, TOP, 0, -5)
        langPopup:SetHidden(not langPopup:IsHidden())
        
        -- Initialisation de l'état visuel à l'ouverture
        if not langPopup:IsHidden() then
            local current = MyAddon.savedVars.language or "fr"
            for code, btn in pairs(flagButtons) do
                btn:SetAlpha(code == current and 1 or 0.3)
            end
        end
    end)
    langBtn:SetHandler("OnMouseEnter", function(self)
        InitializeTooltip(InformationTooltip, self, TOP)
        InformationTooltip:AddLine(LGA_L("LANG_BUTTON"), "ZoFontGame")
    end)
    langBtn:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)

    -- Bouton de verrouillage (Lock)
    lockBtn = wm:CreateControl("$(parent)LockBtn", mainWin, CT_BUTTON)
    lockBtn:SetDimensions(25, 25)
    lockBtn:SetAnchor(BOTTOMRIGHT, mainWin, BOTTOMRIGHT, -58, -3)
    lockBtn:SetFont("ZoFontGameBold")
    lockBtn:SetMouseEnabled(true)
    lockBtn:SetHandler("OnClicked", function()
        sv.isLocked = not sv.isLocked
        UpdateLockVisuals()
    end)	
    lockBtn:SetHandler("OnMouseEnter", function(self)
        InitializeTooltip(InformationTooltip, self, TOP)
        InformationTooltip:AddLine(LGA_L("LOCK_WINDOW_TOOLTIP_TITLE"), "ZoFontWinH2")
        InformationTooltip:AddLine(LGA_L("LOCK_WINDOW_TOOLTIP_TEXT"), "ZoFontGame")
    end)
    lockBtn:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)

    -- Bouton Tout Fermer (Popups)
    closeAllBtn = wm:CreateControl("$(parent)CloseAllBtn", mainWin, CT_BUTTON)
    closeAllBtn:SetDimensions(25, 25)
    closeAllBtn:SetAnchor(RIGHT, lockBtn, LEFT, -5, 0) -- À gauche du cadenas
    closeAllBtn:SetNormalTexture("EsoUI/art/buttons/cancel_up.dds")
    closeAllBtn:SetMouseOverTexture("EsoUI/art/buttons/cancel_over.dds")
    closeAllBtn:SetHandler("OnClicked", function() MyAddon.CloseAllPopups() end)
    closeAllBtn:SetHandler("OnMouseEnter", function(self)
        InitializeTooltip(InformationTooltip, self, TOP)
        InformationTooltip:AddLine(LGA_L("CLOSE_ALL_POPUPS"), "ZoFontGame")
    end)
    closeAllBtn:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)
	
    -- Zones de défilement
    listArea = wm:CreateControlFromVirtual("$(parent)List", mainWin, "ZO_ScrollContainer")
    listArea:SetAnchor(TOPLEFT, mainWin, TOPLEFT, 10, 190)
    listArea:SetAnchor(BOTTOMRIGHT, mainWin, BOTTOMRIGHT, -10, -40)
    
	-- Ajout de la signature en bas à droite
    local signature = wm:CreateControl("Le_Guide_de_L_Antiquaire_Signature", mainWin, CT_LABEL)
    signature:SetFont("$(CHAT_FONT)|10|soft-shadow-thin")
    signature:SetText(LGA_L("SIGNATURE"))
    signature:SetColor(0.6, 0.6, 0.6, 0.8) -- Gris léger pour rester discret
    signature:SetAnchor(BOTTOMRIGHT, mainWin, BOTTOMRIGHT, -10, -5)

    -- Gestion de la visibilité initiale des filtres selon l'onglet courant
    UpdateFilterVisibilityForTab(currentTab)

    -- On applique les titres initiaux
    SwitchTab(currentTab)

    -- Restauration de l'état réduit si nécessaire
    if sv.isMinimized then
        MyAddon.ToggleMinimize()
    end
    
    -- Affichage initial si nécessaire
    if sv.isVisible then
        mainWin:SetHidden(false)
    end
end

-- ==========================================================
-- GESTION DES RACCOURCIS CLAVIER (BINDINGS)
-- ==========================================================

function MyAddon.ToggleWindow()
    if not mainWin then return end
    MyAddon.savedVars.isVisible = not MyAddon.savedVars.isVisible
    mainWin:SetHidden(not MyAddon.savedVars.isVisible)
    if MyAddon.savedVars.isVisible then mainWin:BringWindowToTop() end
end

function MyAddon.UseEye()
    -- ID 8006 = Oeil de l'Antiquaire
    -- On tente de l'utiliser directement (Fonctionne pour les Outils)
    if IsCollectibleUnlocked(8006) and not IsCollectibleBlocked(8006) then
        UseCollectible(8006)
    end
end

function MyAddon.RefreshAlarm()
    MyAddon:CheckForExpiringLeads(true)
end

function MyAddon.ToggleAlarmActive()
    MyAddon.savedVars.isAlarmActive = not MyAddon.savedVars.isAlarmActive
    if alarmBtn then MyAddon:UpdateAlarmButtonVisuals() end
    local state = MyAddon.savedVars.isAlarmActive and "|c00FF00ON|r" or "|cFF0000OFF|r"
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, LGA_L("ALARM_SETTINGS_TITLE") .. ": " .. state)
end

function MyAddon.ToggleAlarmWindow()
    if not alarmDisplayPopup then return end
    if alarmDisplayPopup:IsHidden() then
        MyAddon:CheckForExpiringLeads(true) -- Ouvre et met à jour si des pistes existent
    else
        alarmDisplayPopup:SetHidden(true)
        alarmDisplayPopup.data.isUserHidden = true
    end
end

function MyAddon.OnAddOnLoaded(event, addonName)
    if addonName ~= MyAddon.name then return end
    MyAddon.defaults = { x=100, y=100, bgAlpha=0.9, isLocked = false, favorites = {}, pinnedItem = nil, lastTab = "items", isMinimized = false, shiftY = 0, isVisible = true, searchTerms = { all = "", items = "", fragments = "", fav = "" }, itemFilterState = "all", fragmentFilterState = "all", userNotes = {}, currentNoteIndex = nil, language = "fr", popupPositions = {}, isAlarmActive = false, alarmThresholdDays = 7, alarmThresholdHours = 0, alarmThresholdMinutes = 0, alarmPopupDisappearTime = 0, alarmDisplayPopupPosition = { left = 400, top = 400 }, alarmPopupIsFixed = false, alarmPopupOpacityIndex = 1, savePerCharacter = false, mainWinFrameStyle = "Fin", popupFrameStyle = "Fin", mainWinFrameColor = {r=0, g=0, b=0, a=1}, popupFrameColor = {r=0, g=0, b=0, a=1}, mainWinBgColor = {r=0, g=0, b=0}, popupBgColor = {r=0, g=0, b=0}, mainWinFont = "ZoFontGameBold", mainWinFontSize = 16, popupFont = "ZoFontGameBold", popupFontSize = 16, alarmPopupFrameStyle = "Fin", alarmPopupFrameColor = {r=1, g=0.2, b=0.2, a=1}, alarmPopupBgColor = {r=0, g=0, b=0}, alarmPopupFont = "ZoFontGameBold", alarmPopupFontSize = 20, autoEyeEnabled = true, autoEyeIgnoreMovement = false, qualityInclusive = false, recentLeads = {} }
    
    -- Toujours charger les variables de compte pour vérifier la préférence
    MyAddon.accountVars = ZO_SavedVars:NewAccountWide("Le_Guide_de_L_Antiquaire_SV", 1, nil, MyAddon.defaults)
    
    if MyAddon.accountVars.savePerCharacter then
        MyAddon.characterVars = ZO_SavedVars:NewCharacterIdSettings("Le_Guide_de_L_Antiquaire_SV", 1, nil, MyAddon.defaults)
        MyAddon.savedVars = MyAddon.characterVars
    else
        MyAddon.savedVars = MyAddon.accountVars
    end

    MyAddon.forceShowMainWin = false
    MyAddon.forceShowActionPopup = false
    MyAddon.forceShowAlarmPopup = false

    MyAddon.importString = "" -- Initialisation de la variable temporaire pour l'import

    -- S'assure que isVisible existe pour les anciens utilisateurs (Migration)
    if MyAddon.savedVars.isVisible == nil then MyAddon.savedVars.isVisible = true end

    -- Initialisation du système de langue
    LangTables = {
        fr = Le_Guide_de_L_Antiquaire_FR,
        en = Le_Guide_de_L_Antiquaire_EN,
        de = Le_Guide_de_L_Antiquaire_DE,
        es = Le_Guide_de_L_Antiquaire_ES,
        ru = Le_Guide_de_L_Antiquaire_RU,
    }
    -- On charge la langue sauvegardée ou le français par défaut
    local lang = MyAddon.savedVars.language or "fr"
    MyAddon.L = LangTables[lang] or LangTables["fr"]
    
    -- Initialisation sécurisée des indices
    if not MyAddon.AllHints then MyAddon.AllHints = {} end
    MyAddon.AntiquityHints = MyAddon.AllHints[lang] or MyAddon.AllHints["fr"] or {}

    -- Enregistrement des noms de raccourcis pour le menu Commandes
    ZO_CreateStringId("SI_BINDING_NAME_LGA_TOGGLE_WINDOW", LGA_L("BINDING_TOGGLE_WINDOW"))
    ZO_CreateStringId("SI_BINDING_NAME_LGA_USE_EYE", LGA_L("BINDING_USE_EYE"))
    ZO_CreateStringId("SI_BINDING_NAME_LGA_REFRESH_ALARM", LGA_L("BINDING_REFRESH_ALARM"))
    ZO_CreateStringId("SI_BINDING_NAME_LGA_TOGGLE_MINIMIZE", LGA_L("BINDING_TOGGLE_MINIMIZE"))
    ZO_CreateStringId("SI_BINDING_NAME_LGA_CLOSE_ALL_POPUPS", LGA_L("BINDING_CLOSE_ALL_POPUPS"))
    ZO_CreateStringId("SI_BINDING_NAME_LGA_TOGGLE_ALARM_ACTIVE", LGA_L("BINDING_TOGGLE_ALARM_ACTIVE"))
    ZO_CreateStringId("SI_BINDING_NAME_LGA_TOGGLE_ALARM_WINDOW", LGA_L("BINDING_TOGGLE_ALARM_WINDOW"))
    
    -- Migration de l'ancien système de notes (string) vers le nouveau (table)
    if type(MyAddon.savedVars.userNotes) == "string" then
        local oldContent = MyAddon.savedVars.userNotes
        MyAddon.savedVars.userNotes = {}
        if oldContent and oldContent ~= "" then
            table.insert(MyAddon.savedVars.userNotes, { name = "Note importée", content = oldContent })
            MyAddon.savedVars.currentNoteIndex = 1
        end
    end

    if MyAddon.savedVars.itemFilterState == nil then MyAddon.savedVars.itemFilterState = "all" end
    if MyAddon.savedVars.fragmentFilterState == nil then MyAddon.savedVars.fragmentFilterState = "all" end
    if MyAddon.savedVars.favorites == nil then MyAddon.savedVars.favorites = {} end
    if MyAddon.savedVars.regionFilter == nil then MyAddon.savedVars.regionFilter = 0 end
    if MyAddon.savedVars.typeFilter == nil then MyAddon.savedVars.typeFilter = "__ALL_TYPES__" end
    if MyAddon.savedVars.qualityFilter == nil then MyAddon.savedVars.qualityFilter = 0 end
    if MyAddon.savedVars.qualityInclusive == nil then MyAddon.savedVars.qualityInclusive = false end
    if MyAddon.savedVars.recentLeads == nil then MyAddon.savedVars.recentLeads = {} end
    if MyAddon.savedVars.expandedItems == nil then MyAddon.savedVars.expandedItems = {} end
    -- Migration : si l'ancien état était "Tous Types", on le passe à notre nouvelle clé
    if MyAddon.savedVars.typeFilter == "Tous Types" then MyAddon.savedVars.typeFilter = "__ALL_TYPES__" end

    MyAddon.BuildLeadData()
    MyAddon:CreateSettingsPanel()

    -- Création du pool de popups
    for i = 1, MAX_POPUPS do
        table.insert(actionPopupPool, MyAddon.CreateSingleActionPopup(i))
    end

    -- Initialisation du module Auto-Oeil
    function AE:Init()
        local eventName = MyAddon.name .. "_AE"
        EVENT_MANAGER:RegisterForEvent(eventName, EVENT_ACTIVE_QUICKSLOT_CHANGED, function(...) AE:UpdateSlots(...) end)
        EVENT_MANAGER:RegisterForEvent(eventName, EVENT_HOTBAR_SLOT_UPDATED, function(...) AE:OnHotbarUpdate(...) end)
        EVENT_MANAGER:RegisterForEvent(eventName, EVENT_PLAYER_ACTIVATED, function(...) AE:OnPlayerActivated(...) end)
        EVENT_MANAGER:RegisterForEvent(eventName, EVENT_ANTIQUITY_DIGGING_READY_TO_PLAY, function(...) AE:OnDiggingStart(...) end)
        EVENT_MANAGER:RegisterForEvent(eventName, EVENT_ANTIQUITY_DIGGING_EXIT_RESPONSE, function(...) AE:OnDiggingEnd(...) end)
        AE:UpdateSlots() 
        AE:OnPlayerActivated() -- Vérification initiale 
    end

    function AE:UpdateSlots()
        AE:FindEye()
        if GetCurrentQuickslot() ~= AE.eyeSlot then
            AE.previousSlot = GetCurrentQuickslot()
        end
    end

    function AE:OnHotbarUpdate()
        local backupSlot = AE.eyeSlot
        AE:UpdateSlots()
        if AE.eyeSlot == AE.previousSlot then
            AE.previousSlot = backupSlot
        end
    end
    AE.OnDiggingStart = function() AE.isDigging = true end
    AE.OnDiggingEnd = function() AE.isDigging = false end
    -- Création des popups uniques
    MyAddon:CreateAlarmDisplayPopup()

    -- Enregistrement des événements pour l'alarme
    EVENT_MANAGER:RegisterForEvent(MyAddon.name, EVENT_PLAYER_ACTIVATED, function()
        -- Délai pour laisser les autres addons se charger
        zo_callLater(function() MyAddon:CheckForExpiringLeads() end, 10000)
    end)
    EVENT_MANAGER:RegisterForUpdate(MyAddon.name .. "_AlarmCheck", 15 * 60 * 1000, function() MyAddon:CheckForExpiringLeads() end)

    -- Événements pour une alarme réactive
    local function RefreshAlarmAndList()
        -- On vérifie si l'alarme est active OU si le popup est déjà affiché
        if (MyAddon.savedVars and MyAddon.savedVars.isAlarmActive) or (alarmDisplayPopup and not alarmDisplayPopup:IsHidden()) then
            -- On utilise un petit délai pour s'assurer que les données du jeu sont à jour après l'événement
            zo_callLater(function() MyAddon:CheckForExpiringLeads(true) end, 500)
        end
        -- On rafraîchit aussi la liste principale si elle est visible pour mettre à jour les statuts
        if mainWin and not mainWin:IsHidden() and not isViewingNotes then
            zo_callLater(RefreshList, 500)
        end
    end

    local function HandleLeadDiscovered(eventId, antiquityId)
        if not antiquityId then return end
        if not MyAddon.savedVars.recentLeads then MyAddon.savedVars.recentLeads = {} end

        -- Remove if exists to move to front
        for i = #MyAddon.savedVars.recentLeads, 1, -1 do
            if MyAddon.savedVars.recentLeads[i] == antiquityId then
                table.remove(MyAddon.savedVars.recentLeads, i)
                break
            end
        end

        table.insert(MyAddon.savedVars.recentLeads, 1, antiquityId)

        while #MyAddon.savedVars.recentLeads > 5 do
            table.remove(MyAddon.savedVars.recentLeads)
        end
        RefreshAlarmAndList()
    end
    EVENT_MANAGER:RegisterForEvent(MyAddon.name, EVENT_ANTIQUITY_LEAD_DISCOVERED, HandleLeadDiscovered)
    EVENT_MANAGER:RegisterForEvent(MyAddon.name, EVENT_ANTIQUITY_LEAD_EXPIRED, RefreshAlarmAndList)
    EVENT_MANAGER:RegisterForEvent(MyAddon.name, EVENT_ANTIQUITY_SCRYING_COMPLETED, RefreshAlarmAndList)
    EVENT_MANAGER:RegisterForEvent(MyAddon.name, EVENT_ANTIQUITY_COMPLETED, RefreshAlarmAndList)
    EVENT_MANAGER:RegisterForEvent(MyAddon.name, EVENT_ANTIQUITY_DIGGING_EXIT_RESPONSE, RefreshAlarmAndList)

    MyAddon.AutoEye:Init()
    MyAddon:CreateUI()
    MyAddon.UpdateBackgroundStyle() 
    
    -- Restauration des popups ouverts lors de la session précédente
    if MyAddon.savedVars.popupPositions then
        for i, pos in pairs(MyAddon.savedVars.popupPositions) do
            if pos.antId then
                local leadData = nil
                for _, lead in ipairs(MyAddon.AllLeads) do
                    if lead.antiquityId == pos.antId then
                        leadData = lead
                        break
                    end
                end
                if leadData then
                    MyAddon.ShowItemPopup(nil, { fragData = leadData }, i)
                end
            end
        end
    end
	
    SLASH_COMMANDS["/mythique"] = function() 
        MyAddon.savedVars.isVisible = not MyAddon.savedVars.isVisible
        mainWin:SetHidden(not MyAddon.savedVars.isVisible)
    end
    SLASH_COMMANDS["/mythsearch"] = function(args) MyAddon.SearchForIds(args) end
    SLASH_COMMANDS["/mythdebug"] = function()
		zo_callLater(function()
			d("--- DEBUG MYTHIQUE ---")
			d("GetAntiquityLeadStatus: " .. type(_G["GetAntiquityLeadStatus"]))
			d("GetAntiquityInfo: " .. type(_G["GetAntiquityInfo"]))
		end, 100)
    end

    -- On force un rafraîchissement après un court délai pour s'assurer que tout est chargé
    zo_callLater(function()
        if mainWin and not mainWin:IsHidden() and not isViewingNotes then
            RefreshList()
        end
        MyAddon.UpdateFrameStyles() -- Appliquer les styles de bordure au chargement
        MyAddon.UpdatePopupBackgroundStyle() -- Appliquer les styles de fond popup
        MyAddon:UpdateAlarmButtonVisuals()
    end, 500)
end

EVENT_MANAGER:RegisterForEvent(MyAddon.name, EVENT_ADD_ON_LOADED, MyAddon.OnAddOnLoaded)