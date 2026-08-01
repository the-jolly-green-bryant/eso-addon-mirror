local addon = SquirrelSlayer
local StatsUI = addon.Services.StatsUI or {}

local ROW_TYPE = 1
local ROW_HEIGHT = 28

local RefreshStatsList

local function OnSpotsUpdated()
    if not StatsUI.visible then return end
    RefreshStatsList()
end

--- Récupère les dépendances runtime utilisées par cette fenêtre.
local function GetDependencies()
    return {
        getSV = addon.State.GetSV,
        map = addon.Services.Map,
        getString = addon.GetString,
        rememberCurrentRegion = addon.Services.Map and addon.Services.Map.RememberCurrentRegion,
    }
end

--- Vérifie la disponibilité minimale des dépendances.
local function AreDependenciesReady(dependencies)
    return dependencies and dependencies.getSV and dependencies.map and dependencies.getString
end

--- Retourne une chaîne localisée avec fallback.
local function Localized(dependencies, key, fallbackText)
    if dependencies.getString then
        local localizedText = dependencies.getString(key)
        if localizedText and localizedText ~= "" then return localizedText end
    end
    return fallbackText
end

--- Retourne le nom affichable d'une région à partir de son identifiant.
local function ResolveRegionName(dependencies, savedVariables, regionKey)
    local parsedRegionId = dependencies.map.ParseRegionIdKey(regionKey)
    if parsedRegionId and parsedRegionId > 0 then
        local zoneName = GetZoneNameById and GetZoneNameById(parsedRegionId) or nil
        if zoneName and zoneName ~= "" then return zo_strformat("<<C:1>>", zoneName) end
    end
    return (savedVariables.regionNames and savedVariables.regionNames[regionKey]) or tostring(regionKey)
end

--- Résout une région canonique pour une mapKey, en remontant les sous-régions vers leur région parente.
local function ResolveRegionKeyForMap(dependencies, savedVariables, mapKey)
    local mapService = dependencies.map
    savedVariables.mapToRegion = savedVariables.mapToRegion or {}
    savedVariables.mapToZone = savedVariables.mapToZone or {}
    savedVariables.regionNames = savedVariables.regionNames or {}
    savedVariables.knownRegions = savedVariables.knownRegions or {}

    local mapToRegion = savedVariables.mapToRegion
    local mapToZone = savedVariables.mapToZone

    local function rememberRegion(regionKey, regionName)
        if not regionKey or regionKey == "" then return end
        savedVariables.mapToRegion[mapKey] = regionKey
        savedVariables.knownRegions[regionKey] = true
        if regionName and regionName ~= "" then
            savedVariables.regionNames[regionKey] = savedVariables.regionNames[regionKey] or regionName
        end
    end

    local mapId = mapService.ParseMapIdKey(mapKey)
    if mapId and mapId > 0 and SetMapToMapId and SetMapToMapId(mapId) then
        local mapZoneIndex = GetCurrentMapZoneIndex and GetCurrentMapZoneIndex() or 0
        local zoneId = (mapZoneIndex ~= 0 and GetZoneId and GetZoneId(mapZoneIndex)) or 0
        if zoneId > 0 then
            local regionId = mapService.SafeGetTopLevelRegionId(zoneId)
            if regionId and regionId > 0 then
                local regionKey = mapService.BuildRegionIdKey(regionId)
                local regionName = zo_strformat("<<C:1>>", GetZoneNameById(regionId))
                rememberRegion(regionKey, regionName)
                savedVariables.mapToZone[mapKey] = mapService.BuildZoneIdKey(zoneId)
                return regionKey
            end
        end
    end

    local zoneIdFromMap = mapService.ParseZoneIdKey(mapToZone[mapKey])
    if zoneIdFromMap and zoneIdFromMap > 0 then
        local regionId = mapService.SafeGetTopLevelRegionId(zoneIdFromMap)
        if regionId and regionId > 0 then
            local regionKey = mapService.BuildRegionIdKey(regionId)
            local regionName = zo_strformat("<<C:1>>", GetZoneNameById(regionId))
            rememberRegion(regionKey, regionName)
            return regionKey
        end
    end

    local regionKey = mapToRegion[mapKey]
    if mapService.ParseRegionIdKey(regionKey) then return regionKey end
    return regionKey or "regionId:0"
end

--- Construit les statistiques de kills par région.
local function BuildRegionStats(dependencies, savedVariables)
    local killsByRegion = {}
    local globalTotal = 0

    for mapKey, spotList in pairs(savedVariables.spots or {}) do
        local regionKey = ResolveRegionKeyForMap(dependencies, savedVariables, mapKey)

        local mapTotal = 0
        for _, spot in ipairs(spotList) do
            mapTotal = mapTotal + (spot.count or 1)
        end

        killsByRegion[regionKey] = (killsByRegion[regionKey] or 0) + mapTotal
        globalTotal = globalTotal + mapTotal
    end

    local regionRows = {}
    for regionKey, killCount in pairs(killsByRegion) do
        regionRows[#regionRows + 1] = {
            key = regionKey,
            name = ResolveRegionName(dependencies, savedVariables, regionKey),
            kills = killCount,
        }
    end
    if SetMapToPlayerLocation then SetMapToPlayerLocation() end
    return regionRows, globalTotal
end

--- Trie les lignes selon la préférence utilisateur.
local function SortStatsRows(rows, savedVariables)
    local sortMode = (savedVariables.statsUI and savedVariables.statsUI.sort) or "kills_desc"
    if sortMode == "name_asc" then
        table.sort(rows, function(leftRow, rightRow)
            if leftRow.name ~= rightRow.name then return leftRow.name < rightRow.name end
            return leftRow.kills > rightRow.kills
        end)
    else
        table.sort(rows, function(leftRow, rightRow)
            if leftRow.kills ~= rightRow.kills then return leftRow.kills > rightRow.kills end
            return leftRow.name < rightRow.name
        end)
    end
end

--- Remplit visuellement une ligne de la scroll list.
local function SetupRow(control, data)
    local rowData = (data and data.data) or data or {}
    control:GetNamedChild("Region"):SetText(tostring(rowData.name or ""))
    control:GetNamedChild("Kills"):SetText(tostring(rowData.kills or 0))
end

--- Rafraîchit toute la liste des statistiques (données + total).
RefreshStatsList = function()
    if not StatsUI.scrollList then return end

    local dependencies = GetDependencies()
    if not AreDependenciesReady(dependencies) then return end
    local savedVariables = dependencies.getSV()
    if not savedVariables then return end

    local regionRows, globalTotal = BuildRegionStats(dependencies, savedVariables)
    SortStatsRows(regionRows, savedVariables)

    local scrollDataList = ZO_ScrollList_GetDataList(StatsUI.scrollList)
    ZO_ClearNumericallyIndexedTable(scrollDataList)

    if #regionRows == 0 then
        scrollDataList[#scrollDataList + 1] = ZO_ScrollList_CreateDataEntry(ROW_TYPE, {
            name = Localized(dependencies, "stats_empty", "Aucune région à afficher."),
            kills = 0,
        })
    else
        for _, row in ipairs(regionRows) do
            scrollDataList[#scrollDataList + 1] = ZO_ScrollList_CreateDataEntry(ROW_TYPE, row)
        end
    end

    ZO_ScrollList_Commit(StatsUI.scrollList)
    StatsUI.totalValue:SetText(tostring(globalTotal or 0))
end

--- Gestion simple de visibilité : on masque la fenêtre par défaut.
local function EnsureSceneBinding(frame)
    frame:SetHidden(true)
end

--- Affiche ou masque la fenêtre de statistiques.
local function SetWindowVisible(isVisible)
    StatsUI.visible = isVisible == true
    if StatsUI.frame then StatsUI.frame:SetHidden(not StatsUI.visible) end
end

--- Bascule l'affichage de la fenêtre puis recharge les stats si visible.
local function ToggleStatsWindow()
    local dependencies = GetDependencies()
    if not AreDependenciesReady(dependencies) then return end

    if dependencies.rememberCurrentRegion then dependencies.rememberCurrentRegion() end
    if not StatsUI.frame then BindControls() end
    if not StatsUI.frame then return end

    local shouldShowWindow = not StatsUI.visible
    SetWindowVisible(shouldShowWindow)
    if shouldShowWindow then RefreshStatsList() end
end

--- Crée la scroll list et configure son type de ligne.
local function BuildScrollList(frame)
    local listContainer = frame:GetNamedChild("ListContainer")
    local scrollList = WINDOW_MANAGER:CreateControlFromVirtual("SquirrelSlayerStatsWindowScrollList", listContainer, "ZO_ScrollList")
    scrollList:SetAnchorFill(listContainer)

    ZO_ScrollList_AddDataType(scrollList, ROW_TYPE, "SquirrelSlayerStatsRow", ROW_HEIGHT, SetupRow)
    ZO_ScrollList_EnableHighlight(scrollList, "ZO_ThinListHighlight")
    StatsUI.scrollList = scrollList
end

--- Lie les contrôles XML, applique le style, et branche les handlers.
local function BindControls()
    local dependencies = GetDependencies()
    if not AreDependenciesReady(dependencies) then return end

    local savedVariables = dependencies.getSV()
    if not savedVariables then return end

    local frame = SquirrelSlayerStatsWindow
    if not frame then return end

    frame:SetDimensions(savedVariables.statsUI.w, savedVariables.statsUI.h)
    frame:ClearAnchors()
    frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, savedVariables.statsUI.x, savedVariables.statsUI.y)
    frame:SetDrawTier(DT_HIGH)
    frame:SetHandler("OnMoveStop", function()
        savedVariables.statsUI.x, savedVariables.statsUI.y = frame:GetLeft(), frame:GetTop()
        if RequestAddOnSavedVariablesSave then RequestAddOnSavedVariablesSave() end
    end)

    local backdrop = frame:GetNamedChild("Backdrop")
    local totalDivider = frame:GetNamedChild("TotalDivider")
    local titleLabel = frame:GetNamedChild("Title")
    local closeButton = frame:GetNamedChild("CloseButton")
    local sortNameButton = frame:GetNamedChild("SortNameButton")
    local sortKillsButton = frame:GetNamedChild("SortKillsButton")
    local regionHeader = frame:GetNamedChild("HeaderRegion")
    local killsHeader = frame:GetNamedChild("HeaderKills")
    local totalLabel = frame:GetNamedChild("TotalLabel")
    local totalValue = frame:GetNamedChild("TotalValue")

    if backdrop then
        backdrop:SetCenterColor(0.05, 0.05, 0.05, 0.72)
        backdrop:SetEdgeColor(1, 0.84, 0, 0.55)
    end

    if totalDivider then
        totalDivider:SetDrawLayer(DL_BACKGROUND)
        if totalDivider.SetEdgeTexture and totalDivider.SetCenterColor and totalDivider.SetEdgeColor then
            totalDivider:SetEdgeTexture(nil, 1, 1, 1)
            totalDivider:SetCenterColor(1, 1, 1, 0.0)
            totalDivider:SetEdgeColor(1, 1, 1, 0.55)
        elseif totalDivider.SetColor then
            totalDivider:SetColor(1, 1, 1, 0.55)
        end
    end

    EnsureSceneBinding(frame)
    if not StatsUI.scrollList then BuildScrollList(frame) end

    titleLabel:SetText(Localized(dependencies, "stats_title", "Statistiques par région"))
    closeButton:SetText(Localized(dependencies, "stats_close", "Fermer"))
    sortNameButton:SetText(Localized(dependencies, "stats_sort_name", "Trier : Région"))
    sortKillsButton:SetText(Localized(dependencies, "stats_sort_kills", "Trier : Kills"))
    regionHeader:SetText(Localized(dependencies, "stats_region", "Région"))
    killsHeader:SetText(Localized(dependencies, "stats_kills", "Kills"))
    totalLabel:SetText(Localized(dependencies, "stats_total", "Total"))

    closeButton:SetHandler("OnClicked", function() SetWindowVisible(false) end)
    sortNameButton:SetHandler("OnClicked", function() savedVariables.statsUI.sort = "name_asc"; RefreshStatsList() end)
    sortKillsButton:SetHandler("OnClicked", function() savedVariables.statsUI.sort = "kills_desc"; RefreshStatsList() end)

    StatsUI.frame = frame
    StatsUI.totalLabel = totalLabel
    StatsUI.totalValue = totalValue
    SetWindowVisible(false)
end

--- Point d'entrée d'initialisation de la fenêtre.
function StatsUI.Initialize()
    BindControls()
    if not StatsUI.eventsRegistered and addon.Services.Events and addon.Services.Events.On then
        addon.Services.Events.On(addon.Services.Events.Channels.SPOTS_UPDATED, OnSpotsUpdated)
        StatsUI.eventsRegistered = true
    end
end

--- Enregistre la commande slash d'ouverture / fermeture des statistiques.
function StatsUI.RegisterSlashCommand()
    SLASH_COMMANDS["/sqstats"] = ToggleStatsWindow
end

--- API publique pour les autres services (HUD/menu).
function StatsUI.ToggleWindow()
    ToggleStatsWindow()
end

StatsUI.RegisterSlashCommand()
addon.Services.StatsUI = StatsUI
