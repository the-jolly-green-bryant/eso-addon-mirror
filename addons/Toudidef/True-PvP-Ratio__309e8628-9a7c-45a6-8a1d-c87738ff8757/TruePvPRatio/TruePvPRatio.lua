TruePvPRatio = {
    name = "TruePvPRatio",
    version = "1.7",
    savedVars = nil,
    wasInPremadeGroup = false,
    uiCreated = false,
}

-- Textes de l'interface
ZO_CreateStringId("SI_BINDING_NAME_TRUE_PVP_RATIO_TOGGLE", "Toggle True PvP Ratio")
local L_GLOBAL_RATIO = "GLOBAL ACCOUNT RATIO: "
local L_ALLIANCE_KILLS = "ALLIANCE KILLS & DEATHS"
local L_TITLE = "TRUE PVP RATIO"

-- Couleurs officielles des alliances (Hex)
local ALLIANCE_COLORS = {
    [ALLIANCE_ALDMERI_DOMINION] = "fde617", -- Jaune
    [ALLIANCE_DAGGERFALL_COVENANT] = "1581fc", -- Bleu
    [ALLIANCE_EBONHEART_PACT] = "ad0000", -- Rouge
}

-- Mémoire anti-doublon pour les événements envoyés en double par le serveur
local recentEvents = {}

-- Calcul du ratio 
local function GetRatio(k, d)
    if d == 0 then return (k > 0) and k or 0 end
    return k / d
end

local function FormatRatio(k, d)
    return string.format("%.2f", GetRatio(k, d))
end

-- Création des données par défaut
local function GetDefaults()
    return {
        global = {
            kills = 0, deaths = 0, maxKillStreak = 0,
            alliances = {
                [ALLIANCE_ALDMERI_DOMINION] = {kills = 0, deaths = 0},
                [ALLIANCE_EBONHEART_PACT] = {kills = 0, deaths = 0},
                [ALLIANCE_DAGGERFALL_COVENANT] = {kills = 0, deaths = 0},
            }
        },
        characters = {}
    }
end

-- Nettoyage des personnages supprimés
local function CleanupDeletedCharacters()
    local validChars = {}
    for i = 1, GetNumCharacters() do
        local name = zo_strformat("<<1>>", GetCharacterInfo(i))
        validChars[name] = true
    end

    for cName, _ in pairs(TruePvPRatio.savedVars.characters) do
        if not validChars[cName] then
            TruePvPRatio.savedVars.characters[cName] = nil
        end
    end
end

-- Mise à jour du statut de groupe (Différencie BG Solo / BG Groupe)
local function UpdatePremadeGroupStatus()
    if not IsActiveWorldBattleground() then
        TruePvPRatio.wasInPremadeGroup = (GetGroupSize() > 1)
    end
end

-- Détection INFAILLIBLE de la zone PvP actuelle
local function GetCurrentPvPZone()
    if IsActiveWorldBattleground() then
        return "BG"
    end
    
    local zoneId = GetZoneId(GetUnitZoneIndex("player"))
    if zoneId == 181 then
        return "CYR" -- Cyrodiil
    elseif zoneId == 584 or zoneId == 643 then
        return "IC" -- Cité Impériale ou Égouts
    end
    
    return "CYR" -- Fallback par défaut
end

-- Ajouter un Kill
local function AddKill(zone, victimAlliance)
    local charName = zo_strformat("<<1>>", GetUnitName("player"))
    local sv = TruePvPRatio.savedVars
    local charData = sv.characters[charName]

    sv.global.kills = sv.global.kills + 1
    if sv.global.alliances[victimAlliance] then
        sv.global.alliances[victimAlliance].kills = sv.global.alliances[victimAlliance].kills + 1
    end

    charData.kills = charData.kills + 1
    if zone == "CYR" then
        charData.cyrodiil.kills = charData.cyrodiil.kills + 1
    elseif zone == "IC" then
        charData.ic.kills = charData.ic.kills + 1
    elseif zone == "BG" then
        if TruePvPRatio.wasInPremadeGroup then
            charData.bgGroup.kills = charData.bgGroup.kills + 1
        else
            charData.bgSolo.kills = charData.bgSolo.kills + 1
        end
    end

    -- Gestion du Killstreak
    charData.currentKillStreak = (charData.currentKillStreak or 0) + 1
    if charData.currentKillStreak > (charData.maxKillStreak or 0) then
        charData.maxKillStreak = charData.currentKillStreak
    end
    if charData.currentKillStreak > (sv.global.maxKillStreak or 0) then
        sv.global.maxKillStreak = charData.currentKillStreak
    end
end

-- Ajouter une Mort
local function AddDeath(zone, killerAlliance)
    local charName = zo_strformat("<<1>>", GetUnitName("player"))
    local sv = TruePvPRatio.savedVars
    local charData = sv.characters[charName]

    sv.global.deaths = sv.global.deaths + 1
    if sv.global.alliances[killerAlliance] then
        sv.global.alliances[killerAlliance].deaths = sv.global.alliances[killerAlliance].deaths + 1
    end

    charData.deaths = charData.deaths + 1
    if zone == "CYR" then
        charData.cyrodiil.deaths = charData.cyrodiil.deaths + 1
    elseif zone == "IC" then
        charData.ic.deaths = charData.ic.deaths + 1
    elseif zone == "BG" then
        if TruePvPRatio.wasInPremadeGroup then
            charData.bgGroup.deaths = charData.bgGroup.deaths + 1
        else
            charData.bgSolo.deaths = charData.bgSolo.deaths + 1
        end
    end

    charData.currentKillStreak = 0
end

-- Événement de Mort PvP
local function OnPvPKillFeedDeath(eventCode, killLocation, killerDisplayName, killerCharName, killerAlliance, killerRank, victimDisplayName, victimCharName, victimAlliance, victimRank)
    local myAccount = GetUnitDisplayName("player")
    local myCharName = zo_strformat("<<1>>", GetUnitName("player"))
    
    local killerFormatted = zo_strformat("<<1>>", killerCharName)
    local victimFormatted = zo_strformat("<<1>>", victimCharName)

    local isKiller = (killerDisplayName == myAccount and killerFormatted == myCharName)
    local isVictim = (victimDisplayName == myAccount and victimFormatted == myCharName)

    if not isKiller and not isVictim then return end

    local eventType = isKiller and "KILL" or "DEATH"
    local eventSignature = eventType .. "_" .. killerFormatted .. "_VS_" .. victimFormatted
    local currentTime = GetGameTimeMilliseconds()

    if recentEvents[eventSignature] and (currentTime - recentEvents[eventSignature]) < 2000 then
        return 
    end
    recentEvents[eventSignature] = currentTime

    local zone = GetCurrentPvPZone()

    if isKiller then
        AddKill(zone, victimAlliance)
    elseif isVictim then
        AddDeath(zone, killerAlliance)
    end
end

-- Événement de Fin de Champ de Bataille (Victoire / Défaite)
local function OnBattlegroundStateChanged(eventCode, previousState, currentState)
    -- Se déclenche quand le panneau final des scores apparaît
    if currentState == BATTLEGROUND_STATE_POSTGAME and previousState ~= BATTLEGROUND_STATE_POSTGAME then
        local myAlliance = GetUnitBattlegroundAlliance("player")
        if not myAlliance or myAlliance == 0 then return end
        
        local myScore = GetCurrentBattlegroundScore(myAlliance)
        local isWinner = true
        
        -- On compare notre score avec ceux des autres alliances
        local allBGAlliances = { BATTLEGROUND_ALLIANCE_FIRE_DRAKES, BATTLEGROUND_ALLIANCE_PIT_DAEMONS, BATTLEGROUND_ALLIANCE_STORM_LORDS }
        for _, bgAllianceId in ipairs(allBGAlliances) do
            if bgAllianceId ~= myAlliance then
                local otherScore = GetCurrentBattlegroundScore(bgAllianceId)
                if otherScore > myScore then
                    isWinner = false
                    break
                end
            end
        end
        
        local charName = zo_strformat("<<1>>", GetUnitName("player"))
        local sv = TruePvPRatio.savedVars
        local charData = sv.characters[charName]
        if not charData then return end
        
        if TruePvPRatio.wasInPremadeGroup then
            if isWinner then
                charData.bgGroup.wins = (charData.bgGroup.wins or 0) + 1
            else
                charData.bgGroup.losses = (charData.bgGroup.losses or 0) + 1
            end
        else
            if isWinner then
                charData.bgSolo.wins = (charData.bgSolo.wins or 0) + 1
            else
                charData.bgSolo.losses = (charData.bgSolo.losses or 0) + 1
            end
        end
    end
end

-- Création de l'interface Gamepad
function TruePvPRatio:BuildUI()
    if self.uiCreated then return end

    local tlw = WINDOW_MANAGER:CreateTopLevelWindow("TruePvPRatio_UI")
    tlw:SetDimensions(GuiRoot:GetWidth(), GuiRoot:GetHeight())
    tlw:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    tlw:SetHidden(true)
    self.uiWindow = tlw

    local bg = WINDOW_MANAGER:CreateControl("TruePvPRatio_UI_BG", tlw, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0, 0, 0, 0.9)
    bg:SetEdgeColor(0, 0, 0, 0)

    local title = WINDOW_MANAGER:CreateControl("TruePvPRatio_UI_Title", tlw, CT_LABEL)
    title:SetFont("ZoFontGamepad42")
    title:SetAnchor(TOP, tlw, TOP, 0, 80)
    title:SetText(L_TITLE)
    title:SetColor(1, 1, 1, 1)

    self.globalLabel = WINDOW_MANAGER:CreateControl("TruePvPRatio_UI_Global", tlw, CT_LABEL)
    self.globalLabel:SetFont("ZoFontGamepad34")
    self.globalLabel:SetAnchor(TOP, title, BOTTOM, 0, 20)
    self.globalLabel:SetColor(1, 0.8, 0, 1) 

    local allianceTitle = WINDOW_MANAGER:CreateControl("TruePvPRatio_UI_Alliances_Title", tlw, CT_LABEL)
    allianceTitle:SetFont("ZoFontGamepad34")
    allianceTitle:SetAnchor(TOPRIGHT, tlw, TOPRIGHT, -100, 250)
    allianceTitle:SetText(L_ALLIANCE_KILLS)
    
    self.adLabel = WINDOW_MANAGER:CreateControl("TruePvPRatio_UI_AD", tlw, CT_LABEL)
    self.adLabel:SetFont("ZoFontGamepad27")
    self.adLabel:SetAnchor(TOPRIGHT, allianceTitle, BOTTOMRIGHT, 0, 30)
    self.adLabel:SetColor(1, 1, 0, 1) 
    
    self.dcLabel = WINDOW_MANAGER:CreateControl("TruePvPRatio_UI_DC", tlw, CT_LABEL)
    self.dcLabel:SetFont("ZoFontGamepad27")
    self.dcLabel:SetAnchor(TOPRIGHT, self.adLabel, BOTTOMRIGHT, 0, 20)
    self.dcLabel:SetColor(0.2, 0.6, 1, 1) 
    
    self.epLabel = WINDOW_MANAGER:CreateControl("TruePvPRatio_UI_EP", tlw, CT_LABEL)
    self.epLabel:SetFont("ZoFontGamepad27")
    self.epLabel:SetAnchor(TOPRIGHT, self.dcLabel, BOTTOMRIGHT, 0, 20)
    self.epLabel:SetColor(1, 0.2, 0.2, 1) 

    self.charLabels = {}

    self.scene = ZO_Scene:New("truePvPRatioGamepad", SCENE_MANAGER)
    self.scene:AddFragment(ZO_FadeSceneFragment:New(tlw))
    
    local keybindStripDescriptor = {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        {
            name = GetString(SI_DIALOG_CLOSE),
            keybind = "UI_SHORTCUT_NEGATIVE", 
            callback = function() SCENE_MANAGER:Hide("truePvPRatioGamepad") end,
        },
    }

    self.scene:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_SHOWING then
            self:UpdateUI()
            KEYBIND_STRIP:AddKeybindButtonGroup(keybindStripDescriptor)
        elseif newState == SCENE_HIDDEN then
            KEYBIND_STRIP:RemoveKeybindButtonGroup(keybindStripDescriptor)
        end
    end)

    self.uiCreated = true
end

-- Remplissage des données
function TruePvPRatio:UpdateUI()
    local sv = self.savedVars

    self.globalLabel:SetText(L_GLOBAL_RATIO .. FormatRatio(sv.global.kills, sv.global.deaths) .. "  (K:"..sv.global.kills.." / D:"..sv.global.deaths..") | Max Streak: " .. (sv.global.maxKillStreak or 0))

    local ad = sv.global.alliances[ALLIANCE_ALDMERI_DOMINION]
    local dc = sv.global.alliances[ALLIANCE_DAGGERFALL_COVENANT]
    local ep = sv.global.alliances[ALLIANCE_EBONHEART_PACT]
    
    self.adLabel:SetText("Aldmeri Dominion : " .. ad.kills .. " Kills / " .. ad.deaths .. " Deaths")
    self.dcLabel:SetText("Daggerfall Covenant : " .. dc.kills .. " Kills / " .. dc.deaths .. " Deaths")
    self.epLabel:SetText("Ebonheart Pact : " .. ep.kills .. " Kills / " .. ep.deaths .. " Deaths")

    local sortedChars = {}
    for name, data in pairs(sv.characters) do
        table.insert(sortedChars, {name = name, data = data, ratio = GetRatio(data.kills, data.deaths)})
    end

    table.sort(sortedChars, function(a, b) 
        local isAVeteran = (a.data.kills >= 2000)
        local isBVeteran = (b.data.kills >= 2000)
        
        if isAVeteran ~= isBVeteran then
            return isAVeteran
        end
        return a.ratio > b.ratio
    end)

    for _, lbl in ipairs(self.charLabels) do
        lbl:SetHidden(true)
    end

    for i, charInfo in ipairs(sortedChars) do
        local lbl = self.charLabels[i]
        if not lbl then
            lbl = WINDOW_MANAGER:CreateControl("TruePvPRatio_UI_Char_"..i, self.uiWindow, CT_LABEL)
            lbl:SetFont("ZoFontGamepad27")
            lbl:SetAnchor(TOPLEFT, self.uiWindow, TOPLEFT, 80, 200 + (i * 45))
            table.insert(self.charLabels, lbl)
        end
        
        local d = charInfo.data

        local nameColor = "FFFFFF"
        if d.alliance and ALLIANCE_COLORS[d.alliance] then
            nameColor = ALLIANCE_COLORS[d.alliance]
        end

        local iconStr = ""
        if d.classId then
            local _, _, _, _, _, _, _, _, gamepadIcon = GetClassInfo(d.classId)
            if gamepadIcon and gamepadIcon ~= "" then
                iconStr = zo_iconFormat(gamepadIcon, 34, 34) .. " "
            end
        end

        -- Affichage avec tirets "-" au lieu de "|" et ajout des W/L pour les BG
        local text = string.format("%s|c%s%s|r |cAAAAAA(K: %d / D: %d | Ratio: %s | Max Streak: %d)|r - Cyr: %s - IC: %s - BG Solo: %s (%dW/%dL) - BG Grp: %s (%dW/%dL)", 
            iconStr,
            nameColor,
            charInfo.name,
            d.kills,
            d.deaths,
            FormatRatio(d.kills, d.deaths),
            d.maxKillStreak or 0,
            FormatRatio(d.cyrodiil.kills, d.cyrodiil.deaths),
            FormatRatio(d.ic.kills, d.ic.deaths),
            FormatRatio(d.bgSolo.kills, d.bgSolo.deaths),
            d.bgSolo.wins or 0,
            d.bgSolo.losses or 0,
            FormatRatio(d.bgGroup.kills, d.bgGroup.deaths),
            d.bgGroup.wins or 0,
            d.bgGroup.losses or 0
        )
        lbl:SetText(text)
        lbl:SetHidden(false)
    end
end

function TruePvPRatio:ToggleUI()
    if SCENE_MANAGER:IsShowing("truePvPRatioGamepad") then
        SCENE_MANAGER:Hide("truePvPRatioGamepad")
    else
        SCENE_MANAGER:Show("truePvPRatioGamepad")
    end
end

-- Raccourci Dynamique
local isCampaignSceneActive = false
local isRefreshingKeybind = false
local campaignKeybindBtn = {
    alignment = KEYBIND_STRIP_ALIGN_CENTER,
    name = L_TITLE,
    keybind = "UI_SHORTCUT_TERTIARY", 
    callback = function() TruePvPRatio:ToggleUI() end,
}

local function RefreshCampaignKeybind()
    if isCampaignSceneActive and not isRefreshingKeybind then
        isRefreshingKeybind = true
        KEYBIND_STRIP:RemoveKeybindButton(campaignKeybindBtn)
        KEYBIND_STRIP:AddKeybindButton(campaignKeybindBtn)
        isRefreshingKeybind = false
    end
end

local function RegisterCampaignMenuKeybind()
    SCENE_MANAGER:RegisterCallback("SceneStateChanged", function(scene, oldState, newState)
        local name = scene:GetName()
        if name and string.find(string.lower(name), "campaign") and string.find(string.lower(name), "gamepad") then
            if newState == SCENE_SHOWING then
                isCampaignSceneActive = true
                RefreshCampaignKeybind()
            elseif newState == SCENE_HIDDEN then
                isCampaignSceneActive = false
                KEYBIND_STRIP:RemoveKeybindButton(campaignKeybindBtn)
            end
        end
    end)
    SecurePostHook(KEYBIND_STRIP, "AddKeybindButtonGroup", RefreshCampaignKeybind)
end

-- Initialisation
function TruePvPRatio:Initialize()
    self.savedVars = ZO_SavedVars:NewAccountWide("TruePvPRatio_Data", 1, nil, GetDefaults())
    
    CleanupDeletedCharacters()

    -- Compatibilité des sauvegardes : Initialise les victoires/défaites s'ils n'existent pas
    if not self.savedVars.global.maxKillStreak then
        self.savedVars.global.maxKillStreak = 0
    end

    for cName, cData in pairs(self.savedVars.characters) do
        cData.maxKillStreak = cData.maxKillStreak or 0
        cData.currentKillStreak = cData.currentKillStreak or 0
        cData.bgSolo.wins = cData.bgSolo.wins or 0
        cData.bgSolo.losses = cData.bgSolo.losses or 0
        cData.bgGroup.wins = cData.bgGroup.wins or 0
        cData.bgGroup.losses = cData.bgGroup.losses or 0
    end

    local charName = zo_strformat("<<1>>", GetUnitName("player"))
    local currentClassId = GetUnitClassId("player")
    local currentAlliance = GetUnitAlliance("player")

    if not self.savedVars.characters[charName] then
        self.savedVars.characters[charName] = {
            kills = 0, deaths = 0, maxKillStreak = 0, currentKillStreak = 0,
            cyrodiil = {kills = 0, deaths = 0},
            ic = {kills = 0, deaths = 0},
            bgSolo = {kills = 0, deaths = 0, wins = 0, losses = 0},
            bgGroup = {kills = 0, deaths = 0, wins = 0, losses = 0},
            classId = currentClassId,
            alliance = currentAlliance,
        }
    else
        self.savedVars.characters[charName].classId = currentClassId
        self.savedVars.characters[charName].alliance = currentAlliance
    end

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PVP_KILL_FEED_DEATH, OnPvPKillFeedDeath)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_BATTLEGROUND_STATE_CHANGED, OnBattlegroundStateChanged)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GROUP_UPDATE, UpdatePremadeGroupStatus)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GROUP_MEMBER_JOINED, UpdatePremadeGroupStatus)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GROUP_MEMBER_LEFT, UpdatePremadeGroupStatus)
    
    self:BuildUI()
    RegisterCampaignMenuKeybind()
end

local function OnAddOnLoaded(eventCode, addonName)
    if addonName ~= TruePvPRatio.name then return end
    EVENT_MANAGER:UnregisterForEvent(TruePvPRatio.name, EVENT_ADD_ON_LOADED)
    TruePvPRatio:Initialize()
end

EVENT_MANAGER:RegisterForEvent(TruePvPRatio.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)