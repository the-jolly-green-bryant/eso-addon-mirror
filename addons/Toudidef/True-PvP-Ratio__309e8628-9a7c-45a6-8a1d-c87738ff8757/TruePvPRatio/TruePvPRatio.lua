TruePvPRatio = {
    name = "TruePvPRatio",
    version = "2.7",
    savedVars = nil,
    uiCreated = false,
    wasInPremadeGroup = false,
}

-- Textes de l'interface
ZO_CreateStringId("SI_BINDING_NAME_TRUE_PVP_RATIO_TOGGLE", "Toggle True PvP Ratio")
local L_GLOBAL_RATIO = "GLOBAL ACCOUNT RATIO: "
local L_TITLE = "TRUE PVP RATIO"

-- Couleurs officielles des alliances (Hex)
local ALLIANCE_COLORS = {
    [ALLIANCE_ALDMERI_DOMINION] = "d4aa15", -- Jaune
    [ALLIANCE_DAGGERFALL_COVENANT] = "135da8", -- Bleu
    [ALLIANCE_EBONHEART_PACT] = "a62828", -- Rouge
}

-- Couleurs et Suffixes des Classes
local CLASS_STYLES = {
    [1]   = { text = "DK",    color = "9c0000" }, -- Rouge sang léger foncé
    [2]   = { text = "SORC",  color = "5d38a6" }, -- Mauve foncé
    [3]   = { text = "NB",    color = "404040" }, -- Gris foncé
    [4]   = { text = "WARD",  color = "00c997" }, -- Turquoise
    [5]   = { text = "NECRO", color = "9cffe8" }, -- Turquoise pâle
    [6]   = { text = "TEMP",  color = "ffdc40" }, -- Jaune vif
    [117] = { text = "ARC",   color = "33FF00" }, -- Vert flash
}

local recentEvents = {}

local function GetRatio(k, d)
    if d == 0 then return (k > 0) and k or 0 end
    return k / d
end

local function FormatRatio(k, d)
    return string.format("%.2f", GetRatio(k, d))
end

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

local function UpdatePremadeGroupStatus()
    if not IsActiveWorldBattleground() then
        TruePvPRatio.wasInPremadeGroup = (GetGroupSize() > 1)
    end
end

-- CORRECTION DU BUG DES DUELS : On renvoie "OTHER" au lieu de "CYR" si on n'est pas en zone PvP.
local function GetCurrentPvPZone()
    if IsActiveWorldBattleground() then
        return "BG"
    end
    
    local zoneId = GetZoneId(GetUnitZoneIndex("player"))
    if zoneId == 181 then
        return "CYR"
    elseif zoneId == 584 or zoneId == 643 then
        return "IC"
    end
    
    return "OTHER"
end

local function AddKill(zone, enemyAlliance)
    local charName = zo_strformat("<<1>>", GetUnitName("player"))
    local sv = TruePvPRatio.savedVars
    local charData = sv and sv.characters and sv.characters[charName]
    if not charData then return end

    sv.global.kills = sv.global.kills + 1
    
    -- On ajoute aux compteurs d'Alliances UNIQUEMENT en monde ouvert pour éviter le bug des BG
    if zone == "CYR" or zone == "IC" then
        if sv.global.alliances[enemyAlliance] then
            sv.global.alliances[enemyAlliance].kills = sv.global.alliances[enemyAlliance].kills + 1
        end
    end

    -- Stats Globales Personnage + Streak
    charData.kills = charData.kills + 1
    charData.currentKillStreak = (charData.currentKillStreak or 0) + 1
    if charData.currentKillStreak > (charData.maxKillStreak or 0) then charData.maxKillStreak = charData.currentKillStreak end
    if charData.currentKillStreak > (sv.global.maxKillStreak or 0) then sv.global.maxKillStreak = charData.currentKillStreak end

    -- Stats par modes (Plus de streak ici)
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
end

local function AddDeath(zone, enemyAlliance)
    local charName = zo_strformat("<<1>>", GetUnitName("player"))
    local sv = TruePvPRatio.savedVars
    local charData = sv and sv.characters and sv.characters[charName]
    if not charData then return end

    sv.global.deaths = sv.global.deaths + 1
    
    -- Alliances
    if zone == "CYR" or zone == "IC" then
        if sv.global.alliances[enemyAlliance] then
            sv.global.alliances[enemyAlliance].deaths = sv.global.alliances[enemyAlliance].deaths + 1
        end
    end

    -- Stats Globales Personnage + Réinitialisation Streak
    charData.deaths = charData.deaths + 1
    charData.currentKillStreak = 0

    -- Stats par modes
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
end

local function OnPvPKillFeedDeath(eventCode, killLocation, killerDisplayName, killerCharName, killerAlliance, killerRank, victimDisplayName, victimCharName, victimAlliance, victimRank)
    local zone = GetCurrentPvPZone()
    
    -- Si la zone est "OTHER" (ex: Un duel en ville), on ignore complètement l'événement !
    if zone == "OTHER" then return end

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

    if isKiller then
        AddKill(zone, victimAlliance)
    elseif isVictim then
        AddDeath(zone, killerAlliance)
    end
end

function TruePvPRatio:BuildUI()
    if self.uiCreated then return end

    local tlw = WINDOW_MANAGER:CreateTopLevelWindow("TruePvPRatio_UI")
    tlw:SetDimensions(GuiRoot:GetWidth(), GuiRoot:GetHeight())
    tlw:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    tlw:SetHidden(true)
    self.uiWindow = tlw

    local bg = WINDOW_MANAGER:CreateControl("TruePvPRatio_UI_BG", tlw, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0, 0, 0, 0.95)
    bg:SetEdgeColor(0, 0, 0, 0)

    -- Titre Principal
    local title = WINDOW_MANAGER:CreateControl("TruePvPRatio_UI_Title", tlw, CT_LABEL)
    title:SetFont("ZoFontGamepad42")
    title:SetAnchor(TOP, tlw, TOP, 0, 40)
    title:SetText(L_TITLE)
    title:SetColor(1, 1, 1, 1)

    -- Stats Globales (Haut Gauche)
    self.globalLabel = WINDOW_MANAGER:CreateControl("TruePvPRatio_UI_Global", tlw, CT_LABEL)
    self.globalLabel:SetFont("ZoFontGamepad34")
    self.globalLabel:SetAnchor(TOPLEFT, tlw, TOPLEFT, 40, 90)
    self.globalLabel:SetColor(1, 0.8, 0, 1) -- #FFCC00 (Or)

    -- Tableau des Alliances (Haut Droite)
    local rightPanelX = -60
    local startY = 40
    
    local allianceTitle = WINDOW_MANAGER:CreateControl("TruePvPRatio_UI_Alliances_Title", tlw, CT_LABEL)
    allianceTitle:SetFont("ZoFontGamepad34")
    allianceTitle:SetAnchor(TOPRIGHT, tlw, TOPRIGHT, rightPanelX, startY)
    allianceTitle:SetText("Cyrodiil & IC\nKills/Deaths")
    allianceTitle:SetColor(0.7, 0.7, 0.7, 1)
    
    self.adLabel = WINDOW_MANAGER:CreateControl("TruePvPRatio_UI_AD", tlw, CT_LABEL)
    self.adLabel:SetFont("ZoFontGamepad27")
    self.adLabel:SetAnchor(TOPRIGHT, allianceTitle, BOTTOMRIGHT, 0, 15)
    self.adLabel:SetColor(0.83, 0.67, 0.08, 1) 
    
    self.dcLabel = WINDOW_MANAGER:CreateControl("TruePvPRatio_UI_DC", tlw, CT_LABEL)
    self.dcLabel:SetFont("ZoFontGamepad27")
    self.dcLabel:SetAnchor(TOPRIGHT, self.adLabel, BOTTOMRIGHT, 0, 10)
    self.dcLabel:SetColor(0.07, 0.36, 0.66, 1) 
    
    self.epLabel = WINDOW_MANAGER:CreateControl("TruePvPRatio_UI_EP", tlw, CT_LABEL)
    self.epLabel:SetFont("ZoFontGamepad27")
    self.epLabel:SetAnchor(TOPRIGHT, self.dcLabel, BOTTOMRIGHT, 0, 10)
    self.epLabel:SetColor(0.65, 0.16, 0.16, 1) 

    -- En-têtes du Tableau
    local function CreateHeader(name, text, offsetX, width, align)
        local lbl = WINDOW_MANAGER:CreateControl(name, tlw, CT_LABEL)
        lbl:SetFont("ZoFontGamepad27")
        lbl:SetColor(0.5, 0.5, 0.5, 1)
        lbl:SetAnchor(BOTTOMLEFT, tlw, TOPLEFT, offsetX, 310)
        lbl:SetDimensions(width, 60)
        lbl:SetHorizontalAlignment(align)
        lbl:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
        lbl:SetText(text)
        return lbl
    end

    CreateHeader("TruePvPRatio_H1", "Characters", 40, 240, TEXT_ALIGN_LEFT)
    CreateHeader("TruePvPRatio_H2", "Global", 280, 220, TEXT_ALIGN_CENTER)
    CreateHeader("TruePvPRatio_H3", "Cyrodiil", 500, 220, TEXT_ALIGN_CENTER)
    CreateHeader("TruePvPRatio_H4", "Imperial City", 720, 220, TEXT_ALIGN_CENTER)
    CreateHeader("TruePvPRatio_H5", "BG (Solo)", 940, 220, TEXT_ALIGN_CENTER)
    CreateHeader("TruePvPRatio_H6", "BG (Grp)", 1160, 220, TEXT_ALIGN_CENTER)

    -- ZONE DE DEFILEMENT (SCROLL)
    self.scrollContainer = WINDOW_MANAGER:CreateControl("TruePvPRatio_UI_Scroll", tlw, CT_SCROLL)
    self.scrollContainer:SetAnchor(TOPLEFT, tlw, TOPLEFT, 0, 330)
    self.scrollContainer:SetAnchor(BOTTOMRIGHT, tlw, BOTTOMRIGHT, 0, -20)
    self.scrollContainer:SetMouseEnabled(true)
    
    self.scrollChild = WINDOW_MANAGER:CreateControl("TruePvPRatio_UI_ScrollChild", self.scrollContainer, CT_CONTROL)
    self.scrollChild:SetAnchor(TOPLEFT)
    self.scrollChild:SetWidth(GuiRoot:GetWidth())

    tlw:SetHandler("OnUpdate", function()
        if not tlw:IsHidden() and IsInGamepadPreferredMode() then
            local y = DIRECTIONAL_INPUT:GetY(ZO_DI_RIGHT_STICK)
            if y ~= 0 then
                local delta = GetFrameDeltaSeconds()
                local currentScroll = self.scrollContainer:GetVerticalScroll()
                local speed = 1200 * delta
                local newScroll = currentScroll - (y * speed)
                
                local maxScroll = math.max(0, self.scrollChild:GetHeight() - self.scrollContainer:GetHeight())
                if newScroll < 0 then newScroll = 0 end
                if newScroll > maxScroll then newScroll = maxScroll end
                
                self.scrollContainer:SetVerticalScroll(newScroll)
            end
        end
    end)

    self.scrollContainer:SetHandler("OnMouseWheel", function(_, delta)
        local currentScroll = self.scrollContainer:GetVerticalScroll()
        local newScroll = currentScroll - (delta * 60)
        local maxScroll = math.max(0, self.scrollChild:GetHeight() - self.scrollContainer:GetHeight())
        if newScroll < 0 then newScroll = 0 end
        if newScroll > maxScroll then newScroll = maxScroll end
        self.scrollContainer:SetVerticalScroll(newScroll)
    end)

    self.charRows = {}

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

function TruePvPRatio:UpdateUI()
    local sv = self.savedVars

    self.globalLabel:SetText(L_GLOBAL_RATIO .. FormatRatio(sv.global.kills, sv.global.deaths) .. "  (K "..sv.global.kills.." / D "..sv.global.deaths..") | Streak  " .. (sv.global.maxKillStreak or 0))

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

    for _, row in ipairs(self.charRows) do
        row.name:SetHidden(true)
        row.global:SetHidden(true)
        row.cyr:SetHidden(true)
        row.ic:SetHidden(true)
        row.bgSolo:SetHidden(true)
        row.bgGrp:SetHidden(true)
    end

    local numDisplayed = 0

    for i, charInfo in ipairs(sortedChars) do
        if i > 20 then break end 
        numDisplayed = numDisplayed + 1

        local row = self.charRows[i]
        local yOffset = (i - 1) * 75

        if not row then
            row = {}
            row.name = WINDOW_MANAGER:CreateControl("TruePvPRatio_Row_"..i.."_Name", self.scrollChild, CT_LABEL)
            row.name:SetFont("ZoFontGamepad27")
            row.name:SetAnchor(TOPLEFT, self.scrollChild, TOPLEFT, 40, yOffset + 5)
            row.name:SetDimensions(240, 75)
            row.name:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
            row.name:SetVerticalAlignment(TEXT_ALIGN_CENTER)
            
            local function CreateStatCell(idx, x)
                local lbl = WINDOW_MANAGER:CreateControl("TruePvPRatio_Row_"..i.."_C"..idx, self.scrollChild, CT_LABEL)
                lbl:SetFont("ZoFontGamepad27")
                lbl:SetAnchor(TOPLEFT, self.scrollChild, TOPLEFT, x, yOffset)
                lbl:SetDimensions(220, 75)
                lbl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
                lbl:SetVerticalAlignment(TEXT_ALIGN_CENTER)
                return lbl
            end
            
            row.global = CreateStatCell(2, 280)
            row.cyr = CreateStatCell(3, 500)
            row.ic = CreateStatCell(4, 720)
            row.bgSolo = CreateStatCell(5, 940)
            row.bgGrp = CreateStatCell(6, 1160)
            
            table.insert(self.charRows, row)
        end
        
        local d = charInfo.data

        local nameColor = "FFFFFF"
        if d.alliance and ALLIANCE_COLORS[d.alliance] then
            nameColor = ALLIANCE_COLORS[d.alliance]
        end

        local classPrefix = ""
        if d.classId and CLASS_STYLES[d.classId] then
            local cStyle = CLASS_STYLES[d.classId]
            classPrefix = string.format("|c%s[%s]|r\n", cStyle.color, cStyle.text)
        end

        row.name:SetText(classPrefix .. "|c" .. nameColor .. charInfo.name .. "|r")

        -- Fonction pour la case "Global" avec les couleurs dorées et la streak
        local function FormatGlobalCell(k, deaths, streak)
            return string.format("|cFFCC00K %d / D %d|r\n|cFFCC00Ratio %s | Streak %d|r", k, deaths, FormatRatio(k, deaths), streak or 0)
        end

        -- Fonction pour les modes spécifiques (Blanc et Gris, sans streak)
        local function FormatModeCell(k, deaths)
            return string.format("|cFFFFFFK %d / D %d|r\n|cAAAAAARatio %s|r", k, deaths, FormatRatio(k, deaths))
        end

        row.global:SetText(FormatGlobalCell(d.kills, d.deaths, d.maxKillStreak))
        row.cyr:SetText(FormatModeCell(d.cyrodiil.kills, d.cyrodiil.deaths))
        row.ic:SetText(FormatModeCell(d.ic.kills, d.ic.deaths))
        row.bgSolo:SetText(FormatModeCell(d.bgSolo.kills, d.bgSolo.deaths))
        row.bgGrp:SetText(FormatModeCell(d.bgGroup.kills, d.bgGroup.deaths))

        row.name:SetHidden(false)
        row.global:SetHidden(false)
        row.cyr:SetHidden(false)
        row.ic:SetHidden(false)
        row.bgSolo:SetHidden(false)
        row.bgGrp:SetHidden(false)
    end

    self.scrollChild:SetHeight(numDisplayed * 75)
end

function TruePvPRatio:ToggleUI()
    if SCENE_MANAGER:IsShowing("truePvPRatioGamepad") then
        SCENE_MANAGER:Hide("truePvPRatioGamepad")
    else
        SCENE_MANAGER:Show("truePvPRatioGamepad")
    end
end

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

function TruePvPRatio:Initialize()
    self.savedVars = ZO_SavedVars:NewAccountWide("TruePvPRatio_Data", 1, nil, GetDefaults())
    
    CleanupDeletedCharacters()

    if not self.savedVars.global.maxKillStreak then
        self.savedVars.global.maxKillStreak = 0
    end

    -- Initialisation des tableaux si manquants (Les streaks spécifiques ne sont plus utilisées mais on initialise pour éviter les erreurs)
    for cName, cData in pairs(self.savedVars.characters) do
        cData.maxKillStreak = cData.maxKillStreak or 0
        cData.currentKillStreak = cData.currentKillStreak or 0
        
        if not cData.cyrodiil then cData.cyrodiil = {kills = 0, deaths = 0} end
        if not cData.ic then cData.ic = {kills = 0, deaths = 0} end
        if not cData.bgSolo then cData.bgSolo = {kills = 0, deaths = 0} end
        if not cData.bgGroup then cData.bgGroup = {kills = 0, deaths = 0} end
    end

    local charName = zo_strformat("<<1>>", GetUnitName("player"))
    local currentClassId = GetUnitClassId("player")
    local currentAlliance = GetUnitAlliance("player")

    if not self.savedVars.characters[charName] then
        self.savedVars.characters[charName] = {
            kills = 0, deaths = 0, maxKillStreak = 0, currentKillStreak = 0,
            cyrodiil = {kills = 0, deaths = 0},
            ic = {kills = 0, deaths = 0},
            bgSolo = {kills = 0, deaths = 0},
            bgGroup = {kills = 0, deaths = 0},
            classId = currentClassId,
            alliance = currentAlliance,
        }
    else
        self.savedVars.characters[charName].classId = currentClassId
        self.savedVars.characters[charName].alliance = currentAlliance
    end

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PVP_KILL_FEED_DEATH, OnPvPKillFeedDeath)
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