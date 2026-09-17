-- NagaMapCompletion 1.2.5
-- Zone Story tracker: panel, location colors, details, filters, favorites, map dots

local NMC = {}
NagaMapCompletion = NMC

local ADDON_NAME = "NagaMapCompletion"
local VERSION = "1.2.5"
local WM = WINDOW_MANAGER

---------------------------------------------------------------------------
-- Localization (auto PT/EN)
---------------------------------------------------------------------------
local function IsPortuguese()
    local lang = (GetCVar and GetCVar("language.2")) or "en"
    return lang == "pt" or lang == "br"
end

local L = {}
local function BuildL()
    if IsPortuguese() then
        L = {
            TITLE = "NAGA MAP COMPLETION",
            LOADED = "carregado",
            HOW = "Como usar:",
            CMD_PANEL = "abrir/fechar o painel",
            CMD_REFRESH = "atualizar progresso",
            CMD_DEBUG = "diagnóstico",
            CMD_HELP = "mostrar comandos",
            COLORS = "Cores:",
            COMPLETE = "100% completo",
            MID = "50–99%",
            LOW = "abaixo de 50%",
            AUTO = "Atualiza sozinho com Zone Story, quests, achievements e POIs.",
            SEARCH = "Buscar zona...",
            SORT_BEST = "Melhor",
            SORT_WORST = "Pior",
            SORT_AZ = "A–Z",
            FILTER_ALL = "Todas",
            FILTER_RED = "Vermelho",
            FILTER_ORANGE = "Laranja",
            FILTER_INC = "Incompletas",
            FILTER_FAV = "Favoritas",
            SUMMARY_ZONES = "Zonas",
            SUMMARY_DONE = "completas",
            SUMMARY_SHARDS = "skyshards faltando",
            SUMMARY_BOOKS = "livros faltando",
            CLICK_MAP = "Clique para abrir no mapa",
            FAV_ADD = "Favorita (clique no ★)",
            FAV_ON = "★ favorita",
            FAV_OFF = "☆",
            NO_DATA = "Sem dados de Zone Story",
            COLLECTED = "Coletado:",
            SHOWING_MAP = "Abrindo mapa de",
            NO_MAP = "Não foi possível abrir o mapa de",
            REFRESHED = "atualizado.",
            MARKERS = "Marcadores no mapa (só incompletas)",
            ACCOUNT = "Progresso da conta (personagens vistos)",
            CHAR = "Personagem",
        }
    else
        L = {
            TITLE = "NAGA MAP COMPLETION",
            LOADED = "loaded",
            HOW = "How to use:",
            CMD_PANEL = "open/close the progress panel",
            CMD_REFRESH = "force refresh progress",
            CMD_DEBUG = "diagnostics",
            CMD_HELP = "show commands",
            COLORS = "Colors:",
            COMPLETE = "100% complete",
            MID = "50–99%",
            LOW = "under 50%",
            AUTO = "Auto-updates on Zone Story progress, quests, achievements & POIs.",
            SEARCH = "Search zone...",
            SORT_BEST = "Best",
            SORT_WORST = "Worst",
            SORT_AZ = "A–Z",
            FILTER_ALL = "All",
            FILTER_RED = "Red",
            FILTER_ORANGE = "Orange",
            FILTER_INC = "Incomplete",
            FILTER_FAV = "Favorites",
            SUMMARY_ZONES = "Zones",
            SUMMARY_DONE = "complete",
            SUMMARY_SHARDS = "skyshards missing",
            SUMMARY_BOOKS = "books missing",
            CLICK_MAP = "Click to open this zone on the map",
            FAV_ADD = "Favorite (click ★)",
            FAV_ON = "★ favorite",
            FAV_OFF = "☆",
            NO_DATA = "No Zone Story data",
            COLLECTED = "Collected:",
            SHOWING_MAP = "Showing map for",
            NO_MAP = "Could not open map for",
            REFRESHED = "refreshed.",
            MARKERS = "Map markers (incomplete only)",
            ACCOUNT = "Account progress (seen characters)",
            CHAR = "Character",
        }
    end
end
BuildL()

---------------------------------------------------------------------------
-- Colors / types
---------------------------------------------------------------------------
NMC.pinColors = {
    complete = {0.20, 0.95, 0.30, 1},
    middle   = {1.00, 0.60, 0.10, 1},
    low      = {1.00, 0.25, 0.25, 1},
    unknown  = {0.75, 0.70, 0.55, 1},
}

NMC.completionTypes = {
    ZONE_COMPLETION_TYPE_PRIORITY_QUESTS,
    ZONE_COMPLETION_TYPE_WAYSHRINES,
    ZONE_COMPLETION_TYPE_DELVES,
    ZONE_COMPLETION_TYPE_GROUP_DELVES,
    ZONE_COMPLETION_TYPE_POINTS_OF_INTEREST,
    ZONE_COMPLETION_TYPE_STRIKING_LOCALES,
    ZONE_COMPLETION_TYPE_SET_STATIONS,
    ZONE_COMPLETION_TYPE_MUNDUS_STONES,
    ZONE_COMPLETION_TYPE_PUBLIC_DUNGEONS,
    ZONE_COMPLETION_TYPE_WORLD_EVENTS,
    ZONE_COMPLETION_TYPE_GROUP_BOSSES,
    ZONE_COMPLETION_TYPE_SKYSHARDS,
    ZONE_COMPLETION_TYPE_MAGES_GUILD_BOOKS,
}

NMC.zones = {}
NMC.nameLookup = {}
NMC.markers = {}
NMC.window = nil
NMC.statusLabel = nil
NMC.summaryLabel = nil
NMC.searchBox = nil
NMC.listRows = {}
NMC.scrollControl = nil
NMC.listControl = nil
NMC.mapCallbacksRegistered = false
NMC.locationsHooked = false
NMC.sv = nil

local MARKER_SIZE = 14
local DEFAULTS = {
    sortMode = "worst",      -- worst | best | az
    filterMode = "all",      -- all | red | orange | incomplete | fav
    search = "",
    favorites = {},          -- [zoneId] = true
    showMapMarkers = false,
    characters = {},         -- [charName] = { zones = { [zoneId] = percent }, updated = timestamp }
    -- Settings toggles
    enableLocationColors = true,
    enableLocationTooltips = true,
    enablePanel = true,
    enableChatMessages = true,
    enableAutoRefresh = true,
    enableFavorites = true,
    showToggleButton = false,
    toggleButtonX = 40,
    toggleButtonY = 200,
    toggleButtonSize = 48, -- altura 40–80; largura automática
}

local function Clamp(v, lo, hi)
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

local function NormalizeName(name)
    if not name then return "" end
    name = string.lower(name)
    name = name:gsub("|c%x%x%x%x%x%x", ""):gsub("|r", "")
    name = name:gsub("%s+", " ")
    local base = name:match("^([^%(]+)") or name
    base = base:gsub("%s+$", ""):gsub("^%s+", "")
    base = base:gsub("^the ", ""):gsub(" de ", " "):gsub(" do ", " "):gsub(" da ", " ")
    base = base:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
    return base
end

local function SafeName(zoneId)
    if not zoneId or zoneId == 0 or type(GetZoneNameById) ~= "function" then
        return "Zone " .. tostring(zoneId)
    end
    local name = GetZoneNameById(zoneId)
    if not name or name == "" then
        return "Zone " .. tostring(zoneId)
    end
    return zo_strformat(SI_ZONE_NAME, name)
end

local function GetColorKey(percent)
    if percent == nil then return "unknown" end
    if percent >= 100 then return "complete" end
    if percent >= 50 then return "middle" end
    return "low"
end

local function GetPanelColor(percent)
    local c = NMC.pinColors[GetColorKey(percent)]
    return {c[1], c[2], c[3], 0.95}
end

local function CharKey()
    local name = GetUnitName("player") or "Unknown"
    local server = GetWorldName and GetWorldName() or ""
    return name .. "@" .. server
end

---------------------------------------------------------------------------
-- Progress
---------------------------------------------------------------------------
local function CompletionTypeName(completionType)
    if type(GetString) == "function" then
        local ok, s = pcall(GetString, "SI_ZONECOMPLETIONTYPE", completionType)
        if ok and s and s ~= "" and not s:find("ZONECOMPLETION") then
            return s
        end
    end
    local names = {
        [ZONE_COMPLETION_TYPE_PRIORITY_QUESTS] = IsPortuguese() and "Missões prioritárias" or "Priority Quests",
        [ZONE_COMPLETION_TYPE_WAYSHRINES] = IsPortuguese() and "Santuários" or "Wayshrines",
        [ZONE_COMPLETION_TYPE_DELVES] = IsPortuguese() and "Explorações" or "Delves",
        [ZONE_COMPLETION_TYPE_GROUP_DELVES] = IsPortuguese() and "Explorações em grupo" or "Group Delves",
        [ZONE_COMPLETION_TYPE_POINTS_OF_INTEREST] = IsPortuguese() and "Pontos de interesse" or "Points of Interest",
        [ZONE_COMPLETION_TYPE_STRIKING_LOCALES] = IsPortuguese() and "Locais notáveis" or "Striking Locales",
        [ZONE_COMPLETION_TYPE_SET_STATIONS] = IsPortuguese() and "Estações de set" or "Set Stations",
        [ZONE_COMPLETION_TYPE_MUNDUS_STONES] = IsPortuguese() and "Pedras Mundus" or "Mundus Stones",
        [ZONE_COMPLETION_TYPE_PUBLIC_DUNGEONS] = IsPortuguese() and "Masmorras públicas" or "Public Dungeons",
        [ZONE_COMPLETION_TYPE_WORLD_EVENTS] = IsPortuguese() and "Eventos de mundo" or "World Events",
        [ZONE_COMPLETION_TYPE_GROUP_BOSSES] = IsPortuguese() and "Chefes de grupo" or "Group Bosses",
        [ZONE_COMPLETION_TYPE_SKYSHARDS] = "Skyshards",
        [ZONE_COMPLETION_TYPE_MAGES_GUILD_BOOKS] = IsPortuguese() and "Livros da Guilda dos Magos" or "Mages Guild Books",
    }
    return (completionType and names[completionType]) or "Activity"
end

local function ProgressColorCode(c, t)
    if not t or t <= 0 then return "|cBBBBBB" end
    if c >= t then return "|c22FF44" end
    if c > 0 then return "|cFF9900" end
    return "|cFF3333"
end

function NMC:GetZoneProgressDetails(zoneId)
    local details = {}
    local completed, total = 0, 0
    local storyComplete = false

    if type(IsZoneStoryComplete) == "function" then
        local ok, complete = pcall(IsZoneStoryComplete, zoneId)
        if ok and complete then storyComplete = true end
    end

    for _, completionType in ipairs(self.completionTypes) do
        if completionType ~= nil then
            local c, t, ok = nil, nil, false
            local getter = nil
            if ZO_ZoneStories_Manager and ZO_ZoneStories_Manager.GetActivityCompletionProgressValues then
                getter = ZO_ZoneStories_Manager.GetActivityCompletionProgressValues
            elseif ZONE_STORIES_MANAGER and ZONE_STORIES_MANAGER.GetActivityCompletionProgressValues then
                getter = ZONE_STORIES_MANAGER.GetActivityCompletionProgressValues
            end
            if getter then
                ok, c, t = pcall(getter, zoneId, completionType)
            end
            if not (ok and tonumber(c) and tonumber(t) and tonumber(t) > 0) then
                if type(GetNumCompletedZoneActivitiesForZoneCompletionType) == "function"
                   and type(GetNumZoneActivitiesForZoneCompletionType) == "function" then
                    local ok2, c2 = pcall(GetNumCompletedZoneActivitiesForZoneCompletionType, zoneId, completionType)
                    local ok3, t3 = pcall(GetNumZoneActivitiesForZoneCompletionType, zoneId, completionType)
                    if ok2 and ok3 and tonumber(c2) and tonumber(t3) and tonumber(t3) > 0 then
                        c, t, ok = c2, t3, true
                    end
                end
            end
            if ok and tonumber(c) and tonumber(t) and tonumber(t) > 0 then
                c = Clamp(tonumber(c), 0, tonumber(t))
                t = tonumber(t)
                completed = completed + c
                total = total + t
                table.insert(details, {
                    type = completionType,
                    name = CompletionTypeName(completionType),
                    completed = c,
                    total = t,
                })
            end
        end
    end

    local percent = nil
    if storyComplete then
        percent = 100
    elseif total > 0 then
        percent = Clamp((completed / total) * 100, 0, 100)
    end
    return percent, details, completed, total
end

function NMC:BuildZoneData()
    self.zones = {}
    self.nameLookup = {}
    if type(GetNextZoneStoryZoneId) ~= "function" then return 0 end

    local zoneId = GetNextZoneStoryZoneId()
    local count, safety = 0, 0

    while zoneId ~= nil and zoneId ~= 0 and safety < 500 do
        safety = safety + 1
        local name = SafeName(zoneId)
        local percent, details, done, tot = self:GetZoneProgressDetails(zoneId)

        local mapId, cx, cy = nil, nil, nil
        if type(GetMapIdByZoneId) == "function" then
            local ok, result = pcall(GetMapIdByZoneId, zoneId)
            if ok and result and result ~= 0 then mapId = result end
        end
        if mapId and type(GetUniversallyNormalizedMapInfo) == "function" then
            local ok, a, b, c, d = pcall(GetUniversallyNormalizedMapInfo, mapId)
            if ok and tonumber(a) and tonumber(b) and tonumber(c) and tonumber(d) then
                local ox, oz, ow, oh = tonumber(a), tonumber(b), tonumber(c), tonumber(d)
                if ow > 0 and oh > 0 then
                    cx, cy = ox + ow * 0.5, oz + oh * 0.5
                end
            end
        end

        local entry = {
            id = zoneId,
            name = name,
            percent = percent,
            mapId = mapId,
            cx = cx, cy = cy,
            details = details or {},
            completed = done or 0,
            total = tot or 0,
        }
        self.zones[zoneId] = entry

        if percent ~= nil then
            local function indexKey(k)
                if k and k ~= "" and not self.nameLookup[k] then
                    self.nameLookup[k] = entry
                end
            end
            indexKey(NormalizeName(name))
            local eng = name:match("%(([^%)]+)%)")
            if eng then indexKey(NormalizeName(eng)) end
        end

        count = count + 1
        local nextId = GetNextZoneStoryZoneId(zoneId)
        if nextId == zoneId then break end
        zoneId = nextId
    end

    return count
end

function NMC:SaveCharacterProgress()
    if not self.sv then return end
    local key = CharKey()
    local snap = {}
    for id, z in pairs(self.zones) do
        if z.percent ~= nil then
            snap[id] = z.percent
        end
    end
    self.sv.characters[key] = {
        name = GetUnitName("player") or key,
        updated = GetTimeStamp and GetTimeStamp() or 0,
        zones = snap,
    }
end

function NMC:LookupEntryForLocationName(locationName)
    if not locationName then return nil end
    local key = NormalizeName(locationName)
    if self.nameLookup[key] then return self.nameLookup[key] end
    local eng = locationName:match("%(([^%)]+)%)")
    if eng then
        local ek = NormalizeName(eng)
        if self.nameLookup[ek] then return self.nameLookup[ek] end
    end
    local lower = string.lower(locationName)
    for k, entry in pairs(self.nameLookup) do
        if #k >= 4 then
            if lower:find(k, 1, true) or k:find(key, 1, true) or key:find(k, 1, true) then
                return entry
            end
        end
    end
    return nil
end

function NMC:LookupPercentForLocationName(locationName)
    local e = self:LookupEntryForLocationName(locationName)
    return e and e.percent or nil
end

function NMC:IsFavorite(zoneId)
    return self.sv and self.sv.favorites and self.sv.favorites[zoneId] == true
end

function NMC:ToggleFavorite(zoneId)
    if not self.sv then return end
    if self.sv.enableFavorites == false then return end
    if self.sv.favorites[zoneId] then
        self.sv.favorites[zoneId] = nil
    else
        self.sv.favorites[zoneId] = true
    end
    self:RefreshPanel()
    self:RefreshMarkers()
end

function NMC:AddDetailsToTooltip(tooltip, entry)
    local percent = entry and entry.percent
    local detailsList = entry and entry.details
    local status
    if percent == nil then
        status = "|cBBBBBB" .. L.NO_DATA .. "|r"
    elseif percent >= 100 then
        status = string.format("|c22FF44● %d%% %s|r", math.floor(percent + 0.5), L.COMPLETE)
    elseif percent >= 50 then
        status = string.format("|cFF9900● %d%%|r", math.floor(percent + 0.5))
    else
        status = string.format("|cFF3333● %d%%|r", math.floor(percent + 0.5))
    end
    tooltip:AddLine("Zone Story: " .. status, "ZoFontGame")
    if detailsList and #detailsList > 0 then
        tooltip:AddLine(" ", "ZoFontGame")
        tooltip:AddLine("|cFFFFFF" .. L.COLLECTED .. "|r", "ZoFontGame")
        for _, d in ipairs(detailsList) do
            local col = ProgressColorCode(d.completed, d.total)
            tooltip:AddLine(string.format("%s%s: %d/%d|r", col, d.name, d.completed, d.total), "ZoFontGame")
        end
    end
end

---------------------------------------------------------------------------
-- Locations list colors + tooltips
---------------------------------------------------------------------------
-- Cor padrão do texto de Locais (pergaminho ESO)
local DEFAULT_LOCATION_RGBA = {0.898, 0.855, 0.714, 1}

local function ApplyLabelColor(label, percent, forceDefault)
    if not label then return end
    local r, g, b, a
    if forceDefault or percent == false then
        r, g, b, a = DEFAULT_LOCATION_RGBA[1], DEFAULT_LOCATION_RGBA[2], DEFAULT_LOCATION_RGBA[3], DEFAULT_LOCATION_RGBA[4]
        label.nmcPercent = nil
        label.nmcR, label.nmcG, label.nmcB, label.nmcA = nil, nil, nil, nil
        label.nmcColorsEnabled = false
    else
        local c = NMC.pinColors[GetColorKey(percent)]
        r, g, b, a = c[1], c[2], c[3], c[4]
        label.nmcPercent = percent
        label.nmcR, label.nmcG, label.nmcB, label.nmcA = r, g, b, a
        label.nmcColorsEnabled = true
    end
    if label.SetColor then label:SetColor(r, g, b, a) end
    if label.SetNormalFontColor then label:SetNormalFontColor(r, g, b, a) end
    if label.SetMouseOverFontColor then
        label:SetMouseOverFontColor(math.min(1, r + 0.12), math.min(1, g + 0.12), math.min(1, b + 0.12), a)
    end
    if label.SetPressedFontColor then label:SetPressedFontColor(r, g, b, a) end
    if label.SetDisabledFontColor then label:SetDisabledFontColor(r * 0.55, g * 0.55, b * 0.55, a) end
    if label.SetSelectedFontColor then label:SetSelectedFontColor(r, g, b, a) end
end

function NMC:ColorLocationControl(control, data)
    if not control or not data then return end
    local locationLabel = control:GetNamedChild("Location")
    if not locationLabel then return end

    local entry = self:LookupEntryForLocationName(data.locationName)
    local percent = entry and entry.percent or nil
    if percent == nil and locationLabel.GetText then
        entry = self:LookupEntryForLocationName(locationLabel:GetText())
        percent = entry and entry.percent
    end

    locationLabel.nmcLocationName = data.locationName
    locationLabel.nmcEntry = entry
    if locationLabel.SetFont then
        locationLabel:SetFont("ZoFontWinH4")
    end

    local colorsOn = not (self.sv and self.sv.enableLocationColors == false)
    if colorsOn then
        ApplyLabelColor(locationLabel, percent, false)
    else
        ApplyLabelColor(locationLabel, nil, true) -- volta à cor padrão
    end

    if not locationLabel.nmcHoverHooked then
        locationLabel.nmcHoverHooked = true
        local oldEnter = locationLabel:GetHandler("OnMouseEnter")
        local oldExit = locationLabel:GetHandler("OnMouseExit")
        locationLabel:SetHandler("OnMouseEnter", function(lbl, ...)
            if oldEnter then oldEnter(lbl, ...) end
            -- só reaplica cor NMC se cores estiverem ligadas
            if NMC.sv and NMC.sv.enableLocationColors ~= false and lbl.nmcColorsEnabled and lbl.nmcR then
                ApplyLabelColor(lbl, lbl.nmcPercent, false)
            elseif NMC.sv and NMC.sv.enableLocationColors == false then
                ApplyLabelColor(lbl, nil, true)
            end
            if NMC.sv and NMC.sv.enableLocationTooltips == false then return end
            local name = lbl.nmcLocationName or (lbl.GetText and lbl:GetText()) or "Zone"
            InitializeTooltip(InformationTooltip, lbl, RIGHT, -16, 0)
            InformationTooltip:AddLine(name, "ZoFontWinH3")
            NMC:AddDetailsToTooltip(InformationTooltip, lbl.nmcEntry or NMC:LookupEntryForLocationName(name))
        end)
        locationLabel:SetHandler("OnMouseExit", function(lbl, ...)
            ClearTooltip(InformationTooltip)
            if oldExit then oldExit(lbl, ...) end
            if NMC.sv and NMC.sv.enableLocationColors ~= false and lbl.nmcColorsEnabled and lbl.nmcR then
                ApplyLabelColor(lbl, lbl.nmcPercent, false)
            else
                ApplyLabelColor(lbl, nil, true)
            end
        end)
    end
end

function NMC:HookLocationsList()
    if self.locationsHooked then return end
    local function tryHook()
        if NMC.locationsHooked then return true end
        if not WORLD_MAP_LOCATIONS or not WORLD_MAP_LOCATIONS.SetupLocation then return false end
        local original = WORLD_MAP_LOCATIONS.SetupLocation
        WORLD_MAP_LOCATIONS.SetupLocation = function(self, control, data)
            original(self, control, data)
            NMC:ColorLocationControl(control, data)
            zo_callLater(function()
                if control and data then NMC:ColorLocationControl(control, data) end
            end, 10)
        end
        NMC.locationsHooked = true
        return true
    end
    if not tryHook() and WORLD_MAP_SCENE then
        WORLD_MAP_SCENE:RegisterCallback("StateChange", function(_, newState)
            if newState == SCENE_SHOWN then
                zo_callLater(function()
                    if tryHook() then NMC:RefreshLocationsColors() end
                end, 100)
            end
        end)
    end
end

function NMC:RefreshLocationsColors()
    if not WORLD_MAP_LOCATIONS or not WORLD_MAP_LOCATIONS.list then return end
    if type(ZO_ScrollList_RefreshVisible) == "function" then
        ZO_ScrollList_RefreshVisible(WORLD_MAP_LOCATIONS.list)
    end
    zo_callLater(function()
        if not WORLD_MAP_LOCATIONS or not WORLD_MAP_LOCATIONS.list then return end
        local list = WORLD_MAP_LOCATIONS.list
        local num = list:GetNumChildren() or 0
        for i = 1, num do
            local row = list:GetChild(i)
            if row then
                local data = ZO_ScrollList_GetData and ZO_ScrollList_GetData(row)
                if data then
                    NMC:ColorLocationControl(row, data)
                end
            end
        end
    end, 50)
end

---------------------------------------------------------------------------
-- Map markers (incomplete only)
---------------------------------------------------------------------------
function NMC:IsWorldMap()
    return type(GetMapType) == "function" and MAPTYPE_WORLD and GetMapType() == MAPTYPE_WORLD
end

-- Pins nativos (acompanham zoom/pan do mapa)
local PIN_MISSING = "NagaMapCompletion_MissingPOI"
local PIN_SKY = "NagaMapCompletion_MissingSky"
NMC.missingPinsRegistered = false
NMC.markers = NMC.markers or {}

function NMC:ClearMarkers()
    -- limpa controles legados (versões antigas)
    for _, c in ipairs(self.markers) do
        if c then
            c:SetHidden(true)
            c:ClearAnchors()
            if c.SetParent then c:SetParent(nil) end
        end
    end
    self.markers = {}
end

local function CollectMissingPOIs()
    local list = {}
    if type(GetCurrentMapZoneIndex) ~= "function" or type(GetNumPOIs) ~= "function" or type(GetPOIMapInfo) ~= "function" then
        return list
    end
    local zoneIndex = GetCurrentMapZoneIndex()
    if not zoneIndex or zoneIndex == 0 then return list end
    local num = GetNumPOIs(zoneIndex) or 0
    for i = 1, num do
        local ok, nX, nY, pinType, texture, isShown, isDiscovered = pcall(GetPOIMapInfo, zoneIndex, i)
        if not ok then
            ok, nX, nY = pcall(GetPOIMapInfo, zoneIndex, i)
            isShown, isDiscovered = true, false
        end
        nX, nY = tonumber(nX), tonumber(nY)
        if nX and nY then
            local discovered = isDiscovered
            if discovered == nil and type(IsPOIDiscovered) == "function" then
                local ok2, d = pcall(IsPOIDiscovered, zoneIndex, i)
                if ok2 then discovered = d end
            end
            local shown = isShown
            if shown == nil then shown = true end
            if shown and not discovered then
                local poiName = ""
                if type(GetPOIInfo) == "function" then
                    local ok3, name = pcall(GetPOIInfo, zoneIndex, i)
                    if ok3 and name then poiName = name end
                end
                local isSkyshard = false
                if type(GetPOISkyshardId) == "function" then
                    local ok4, sid = pcall(GetPOISkyshardId, zoneIndex, i)
                    if ok4 and sid and sid ~= 0 then isSkyshard = true end
                end
                table.insert(list, {
                    x = nX,
                    y = nY,
                    name = poiName,
                    skyshard = isSkyshard,
                    zoneIndex = zoneIndex,
                    poiIndex = i,
                })
            end
        end
    end
    return list
end

function NMC:RegisterMissingPins()
    if self.missingPinsRegistered then return end
    if type(ZO_WorldMap_AddCustomPin) ~= "function" then return end

    local function layout(size, r, g, b)
        return {
            level = 50,
            size = size or 28,
            insetX = 0,
            insetY = 0,
            texture = "EsoUI/Art/MapPins/UI_WorldMap_QuestPin_Assisted.dds",
            tint = (ZO_ColorDef and ZO_ColorDef:New(r, g, b, 1)) or nil,
        }
    end

    local function tooltipCreator()
        return {
            creator = function(pin)
                local pd = pin and (pin.GetPinData and pin:GetPinData() or pin.m_PinTag)
                if type(pd) ~= "table" then return end
                local tag = pd.skyshard and "Skyshard" or (IsPortuguese() and "Falta" or "Missing")
                InformationTooltip:AddLine(tag, "ZoFontWinH4")
                if pd.name and pd.name ~= "" then
                    InformationTooltip:AddLine(pd.name, "ZoFontGame")
                end
                InformationTooltip:AddLine(
                    IsPortuguese() and "Ainda não coletado/descoberto" or "Not yet collected/discovered",
                    "ZoFontGame"
                )
            end,
            tooltip = 1, -- InformationTooltip
        }
    end

    local function addCallbackMissing(pinManager)
        if not NMC.sv or not NMC.sv.showMissingPins then return end
        if NMC:IsWorldMap() then return end
        if type(GetMapType) == "function" and MAPTYPE_COSMIC and GetMapType() == MAPTYPE_COSMIC then return end
        for _, poi in ipairs(CollectMissingPOIs()) do
            if not poi.skyshard then
                pinManager:CreatePin(_G[PIN_MISSING], poi, poi.x, poi.y)
            end
        end
    end

    local function addCallbackSky(pinManager)
        if not NMC.sv or not NMC.sv.showMissingPins then return end
        if NMC:IsWorldMap() then return end
        if type(GetMapType) == "function" and MAPTYPE_COSMIC and GetMapType() == MAPTYPE_COSMIC then return end
        for _, poi in ipairs(CollectMissingPOIs()) do
            if poi.skyshard then
                pinManager:CreatePin(_G[PIN_SKY], poi, poi.x, poi.y)
            end
        end
    end

    ZO_WorldMap_AddCustomPin(
        PIN_MISSING,
        addCallbackMissing,
        nil,
        layout(26, 1.0, 0.25, 0.25),
        tooltipCreator()
    )
    ZO_WorldMap_AddCustomPin(
        PIN_SKY,
        addCallbackSky,
        nil,
        layout(26, 0.3, 0.75, 1.0),
        tooltipCreator()
    )

    if type(ZO_WorldMap_SetCustomPinEnabled) == "function" then
        ZO_WorldMap_SetCustomPinEnabled(_G[PIN_MISSING], true)
        ZO_WorldMap_SetCustomPinEnabled(_G[PIN_SKY], true)
    end

    self.missingPinsRegistered = true
end

function NMC:RefreshMarkers()
    -- Feature removida: não marca mais o que falta no mapa
    self:ClearMarkers()
    if self.missingPinsRegistered and type(ZO_WorldMap_SetCustomPinEnabled) == "function" then
        if _G[PIN_MISSING] then ZO_WorldMap_SetCustomPinEnabled(_G[PIN_MISSING], false) end
        if _G[PIN_SKY] then ZO_WorldMap_SetCustomPinEnabled(_G[PIN_SKY], false) end
    end
    if type(ZO_WorldMap_RefreshCustomPinsOfType) == "function" then
        if _G[PIN_MISSING] then ZO_WorldMap_RefreshCustomPinsOfType(_G[PIN_MISSING]) end
        if _G[PIN_SKY] then ZO_WorldMap_RefreshCustomPinsOfType(_G[PIN_SKY]) end
    end
end

function NMC:NavigateToZone(zone)
    if not zone then return end
    if self._navLock then return end
    self._navLock = true

    -- Fecha painel e espera o mouse soltar de verdade (evita click-through que fecha o mapa)
    self:HidePanel()
    ClearTooltip(InformationTooltip)

    local function applyMap()
        local changed = false
        if zone.mapId and type(SetMapToMapId) == "function" then
            local ok, result = pcall(SetMapToMapId, zone.mapId)
            if ok then
                if SET_MAP_RESULT_FAILED and result ~= SET_MAP_RESULT_FAILED then
                    changed = true
                elseif result == true or (type(result) == "number" and result ~= 0) then
                    changed = true
                end
            end
        end
        if not changed and zone.id then
            local mapIndex = nil
            if type(GetMapIndexByZoneId) == "function" then
                local ok, idx = pcall(GetMapIndexByZoneId, zone.id)
                if ok then mapIndex = idx end
            end
            if (not mapIndex or mapIndex == 0) and zone.mapId and type(GetMapIndexById) == "function" then
                local ok, idx = pcall(GetMapIndexById, zone.mapId)
                if ok then mapIndex = idx end
            end
            if mapIndex and mapIndex ~= 0 then
                if type(ZO_WorldMap_SetMapByIndex) == "function" then
                    pcall(ZO_WorldMap_SetMapByIndex, mapIndex)
                    changed = true
                elseif WORLD_MAP_MANAGER and WORLD_MAP_MANAGER.SetMapByIndex then
                    pcall(function() WORLD_MAP_MANAGER:SetMapByIndex(mapIndex) end)
                    changed = true
                end
            end
        end
        if CALLBACK_MANAGER then
            CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
        end
        if changed then
            d("|c55FF55NMC:|r " .. L.SHOWING_MAP .. " |cFFFFFF" .. (zone.name or "?") .. "|r")
        else
            d("|cFFAA00NMC:|r " .. L.NO_MAP .. " |cFFFFFF" .. (zone.name or "?") .. "|r")
        end
    end

    local function openMapThenGo()
        local alreadyOpen = false
        if type(ZO_WorldMap_IsWorldMapShowing) == "function" then
            alreadyOpen = ZO_WorldMap_IsWorldMapShowing() and true or false
        elseif WORLD_MAP_SCENE and WORLD_MAP_SCENE.IsShowing then
            alreadyOpen = WORLD_MAP_SCENE:IsShowing()
        end

        -- Nunca usar toggle: só Show se estiver fechado
        if not alreadyOpen then
            if SCENE_MANAGER and SCENE_MANAGER.Show then
                SCENE_MANAGER:Show("worldMap")
            elseif type(ZO_WorldMap_ShowWorldMap) == "function" then
                -- alguns clientes tratam isso como toggle — só chama se fechado
                ZO_WorldMap_ShowWorldMap()
            end
        end

        zo_callLater(function()
            applyMap()
            zo_callLater(function()
                NMC._navLock = false
            end, 300)
        end, 200)
    end

    -- 350ms: tempo suficiente para o botão esquerdo já ter sido solto
    zo_callLater(openMapThenGo, 350)
end

---------------------------------------------------------------------------
-- Panel UI
---------------------------------------------------------------------------
local function MakeBtn(parent, text, width, onClick)
    local b = WM:CreateControl(nil, parent, CT_BUTTON)
    b:SetFont("ZoFontGameSmall")
    b:SetText(text)
    b:SetDimensions(width, 22)
    b:SetMouseEnabled(true)
    b:SetHandler("OnClicked", onClick)
    local bg = WM:CreateControl(nil, b, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0.15, 0.15, 0.15, 0.9)
    bg:SetEdgeColor(0.5, 0.4, 0.2, 0.9)
    bg:SetDrawLevel(0)
    b:SetDrawLevel(1)
    return b
end


---------------------------------------------------------------------------
-- On-screen toggle button (open/close panel)
---------------------------------------------------------------------------
function NMC:GetPlayerStoryZoneEntry()
    local zoneId = nil
    if type(GetUnitWorldPosition) == "function" then
        local ok, a = pcall(GetUnitWorldPosition, "player")
        if ok and tonumber(a) then
            zoneId = tonumber(a)
        end
    end
    if not zoneId and type(GetZoneId) == "function" and type(GetUnitZoneIndex) == "function" then
        local ok, zidx = pcall(GetUnitZoneIndex, "player")
        if ok and zidx then
            local ok2, zid = pcall(GetZoneId, zidx)
            if ok2 then zoneId = zid end
        end
    end
    if not zoneId then return nil end

    if self.zones[zoneId] then
        return self.zones[zoneId]
    end
    if type(GetParentZoneId) == "function" then
        local ok, parent = pcall(GetParentZoneId, zoneId)
        if ok and parent and self.zones[parent] then
            return self.zones[parent]
        end
    end
    -- fallback: build just this zone if it is a story zone
    local percent, details = self:GetZoneProgressDetails(zoneId)
    if percent ~= nil then
        return {
            id = zoneId,
            name = SafeName(zoneId),
            percent = percent,
            details = details or {},
        }
    end
    if type(GetParentZoneId) == "function" then
        local ok, parent = pcall(GetParentZoneId, zoneId)
        if ok and parent and parent ~= 0 then
            percent, details = self:GetZoneProgressDetails(parent)
            if percent ~= nil then
                return {
                    id = parent,
                    name = SafeName(parent),
                    percent = percent,
                    details = details or {},
                }
            end
        end
    end
    return nil
end

function NMC:ApplyToggleButtonSize()
    if not self.toggleBtn or not self.sv then return end
    local h = tonumber(self.sv.toggleButtonSize) or 48
    h = Clamp(h, 36, 80)
    local w = math.floor(h * 4.2) -- retangular
    if w < 160 then w = 160 end
    if w > 340 then w = 340 end
    self.toggleBtn:SetDimensions(w, h)
    if self.toggleNameLabel then
        self.toggleNameLabel:SetDimensions(w - 70, h - 8)
        if h >= 56 then
            self.toggleNameLabel:SetFont("ZoFontWinH4")
        else
            self.toggleNameLabel:SetFont("ZoFontGame")
        end
    end
    if self.togglePctLabel then
        self.togglePctLabel:SetDimensions(58, h - 8)
        if h >= 56 then
            self.togglePctLabel:SetFont("ZoFontWinH3")
        else
            self.togglePctLabel:SetFont("ZoFontWinH4")
        end
    end
end

function NMC:RefreshToggleButtonProgress()
    if not self.toggleBtn or self.toggleBtn:IsHidden() then return end
    local entry = self:GetPlayerStoryZoneEntry()
    local percent = entry and entry.percent or nil
    local c = self.pinColors[GetColorKey(percent)]
    if self.toggleBg then
        self.toggleBg:SetEdgeColor(c[1], c[2], c[3], 0.95)
        self.toggleBg:SetCenterColor(0.04, 0.04, 0.04, 0.92)
    end
    if self.togglePctLabel then
        if percent ~= nil then
            self.togglePctLabel:SetText(string.format("%d%%", math.floor(percent + 0.5)))
            self.togglePctLabel:SetColor(c[1], c[2], c[3], 1)
        else
            self.togglePctLabel:SetText("--")
            self.togglePctLabel:SetColor(0.7, 0.7, 0.7, 1)
        end
    end
    if self.toggleNameLabel then
        if entry and entry.name then
            -- nome completo da zona/mapa
            self.toggleNameLabel:SetText(entry.name)
        else
            self.toggleNameLabel:SetText(IsPortuguese() and "Sem Zone Story" or "No Zone Story")
        end
        self.toggleNameLabel:SetColor(0.95, 0.95, 0.95, 1)
    end
    self.toggleEntry = entry
end

-- Cenas em que o botão deve ficar oculto (mapa, inventário, configs, etc.)
local NMC_HIDE_BUTTON_SCENES = {
    worldMap = true,
    gameMenuInGame = true,
    inventory = true,
    stats = true,
    skills = true,
    notifications = true,
    questJournal = true,
    loreLibrary = true,
    achievements = true,
    groupMenuKeyboard = true,
    friendsList = true,
    ignoreList = true,
    guildRoster = true,
    guildHome = true,
    mailInbox = true,
    mailSend = true,
    tradingHouse = true,
    bank = true,
    houseBank = true,
    store = true,
    fence_keyboard = true,
    interact = true,
    championPerksKeyboard = true,
    championPerks = true,
    collectionsBook = true,
    helpTutorials = true,
    helpCustomerSupport = true,
    keybinds = true,
    addons = true,
    market = true,
    crownCratesKeyboard = true,
    zo_gameMenu_addons = true,
}

function NMC:IsToggleButtonSceneBlocked()
    if not SCENE_MANAGER then return false end

    -- HUD base: mundo livre → botão ok
    if SCENE_MANAGER.IsShowingBaseScene and SCENE_MANAGER:IsShowingBaseScene() then
        -- ainda pode ter mapa fullscreen em alguns modos
        if WORLD_MAP_SCENE and WORLD_MAP_SCENE.IsShowing and WORLD_MAP_SCENE:IsShowing() then
            return true
        end
        return false
    end

    local scene = SCENE_MANAGER.GetCurrentScene and SCENE_MANAGER:GetCurrentScene()
    if scene and scene.GetName then
        local name = scene:GetName()
        if name and NMC_HIDE_BUTTON_SCENES[name] then
            return true
        end
        -- qualquer cena que não seja hud / hudui
        if name and name ~= "hud" and name ~= "hudui" then
            return true
        end
    end

    if WORLD_MAP_SCENE and WORLD_MAP_SCENE.IsShowing and WORLD_MAP_SCENE:IsShowing() then
        return true
    end

    return false
end

function NMC:UpdateToggleButton()
    local allow = self.sv and self.sv.showToggleButton and self.sv.enablePanel ~= false
    local blocked = self:IsToggleButtonSceneBlocked()

    if not allow or blocked then
        if self.toggleBtn then
            self.toggleBtn:SetHidden(true)
        end
        return
    end

    if not self.toggleBtn then
        self:CreateToggleButton()
    end
    if self.toggleBtn then
        self.toggleBtn:SetHidden(false)
        local x = self.sv.toggleButtonX or 40
        local y = self.sv.toggleButtonY or 200
        self.toggleBtn:ClearAnchors()
        self.toggleBtn:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
        self:ApplyToggleButtonSize()
        self:RefreshToggleButtonProgress()
    end
end

function NMC:CreateToggleButton()
    if self.toggleBtn then return end

    local btn = WM:CreateTopLevelWindow("NagaMapCompletionToggleBtn")
    self.toggleBtn = btn
    btn:SetDimensions(220, 48)
    btn:SetMouseEnabled(true)
    btn:SetMovable(true)
    btn:SetClampedToScreen(true)
    btn:SetDrawLayer(DL_OVERLAY)
    btn:SetDrawLevel(40)
    btn:SetHidden(true)

    local bg = WM:CreateControl(nil, btn, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0.04, 0.04, 0.04, 0.92)
    bg:SetEdgeColor(0.85, 0.65, 0.15, 0.95)
    bg:SetEdgeTexture("", 1, 1, 2)
    self.toggleBg = bg

    -- Nome completo à esquerda
    local name = WM:CreateControl(nil, btn, CT_LABEL)
    name:SetFont("ZoFontWinH4")
    name:SetText("NMC")
    name:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    name:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    name:SetAnchor(LEFT, btn, LEFT, 10, 0)
    name:SetDimensions(150, 40)
    name:SetColor(0.95, 0.95, 0.95, 1)
    name:SetMouseEnabled(false)
    self.toggleNameLabel = name

    -- % à direita
    local pct = WM:CreateControl(nil, btn, CT_LABEL)
    pct:SetFont("ZoFontWinH3")
    pct:SetText("--")
    pct:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    pct:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    pct:SetAnchor(RIGHT, btn, RIGHT, -10, 0)
    pct:SetDimensions(58, 40)
    pct:SetMouseEnabled(false)
    self.togglePctLabel = pct

    btn:SetHandler("OnMouseEnter", function()
        InitializeTooltip(InformationTooltip, btn, RIGHT, -8, 0)
        InformationTooltip:AddLine("Naga Map Completion", "ZoFontWinH3")
        local entry = NMC.toggleEntry or NMC:GetPlayerStoryZoneEntry()
        if entry then
            InformationTooltip:AddLine(entry.name or "?", "ZoFontGameHighlight")
            NMC:AddDetailsToTooltip(InformationTooltip, entry)
        else
            InformationTooltip:AddLine(IsPortuguese() and "Sem Zone Story nesta área" or "No Zone Story in this area", "ZoFontGame")
        end
        InformationTooltip:AddLine(" ", "ZoFontGame")
        if IsPortuguese() then
            InformationTooltip:AddLine("Clique: abrir/fechar painel", "ZoFontGame")
            InformationTooltip:AddLine("Arraste: mover botão", "ZoFontGame")
        else
            InformationTooltip:AddLine("Click: open/close panel", "ZoFontGame")
            InformationTooltip:AddLine("Drag: move button", "ZoFontGame")
        end
    end)
    btn:SetHandler("OnMouseExit", function()
        ClearTooltip(InformationTooltip)
    end)

    btn:SetHandler("OnMoveStop", function()
        if not NMC.sv then return end
        NMC.sv.toggleButtonX = btn:GetLeft()
        NMC.sv.toggleButtonY = btn:GetTop()
    end)

    local downX, downY = 0, 0
    btn:SetHandler("OnMouseDown", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            downX, downY = GetUIMousePosition()
        end
    end)
    btn:SetHandler("OnMouseUp", function(_, button, upInside)
        if button ~= MOUSE_BUTTON_INDEX_LEFT or not upInside then return end
        local x, y = GetUIMousePosition()
        if zo_abs(x - downX) > 6 or zo_abs(y - downY) > 6 then
            return
        end
        NMC:TogglePanel()
    end)
end

function NMC:CreatePanel()

    if self.window then return end

    local w = WM:CreateTopLevelWindow("NagaMapCompletionPanel")
    self.window = w
    w:SetDimensions(480, 720)
    w:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 24, 60)
    w:SetMouseEnabled(true)
    w:SetMovable(true)
    w:SetClampedToScreen(true)
    w:SetDrawLayer(DL_OVERLAY)
    w:SetDrawLevel(50)
    w:SetHidden(true)

    local bg = WM:CreateControl(nil, w, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0.02, 0.02, 0.02, 0.95)
    bg:SetEdgeColor(0.72, 0.48, 0.08, 0.95)

    local title = WM:CreateControl(nil, w, CT_LABEL)
    title:SetFont("ZoFontWinH1")
    title:SetText("|cFFFFFF" .. L.TITLE .. "|r")
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    title:SetAnchor(TOP, w, TOP, 0, 8)
    title:SetDimensions(440, 28)

    local close = WM:CreateControl(nil, w, CT_BUTTON)
    close:SetFont("ZoFontGameBold")
    close:SetText("|cFF5555X|r")
    close:SetDimensions(28, 28)
    close:SetAnchor(TOPRIGHT, w, TOPRIGHT, -6, 6)
    close:SetHandler("OnClicked", function() self:HidePanel() end)

    -- Summary
    local summary = WM:CreateControl(nil, w, CT_LABEL)
    summary:SetFont("ZoFontGameSmall")
    summary:SetAnchor(TOPLEFT, w, TOPLEFT, 14, 40)
    summary:SetDimensions(450, 36)
    self.summaryLabel = summary

    -- Search
    local searchBg = WM:CreateControl(nil, w, CT_BACKDROP)
    searchBg:SetDimensions(450, 26)
    searchBg:SetAnchor(TOPLEFT, w, TOPLEFT, 14, 78)
    searchBg:SetCenterColor(0.08, 0.08, 0.08, 1)
    searchBg:SetEdgeColor(0.4, 0.4, 0.4, 0.8)

    local search = WM:CreateControlFromVirtual("NagaMapCompletionSearch", searchBg, "ZO_DefaultEditForBackdrop")
    if not search then
        search = WM:CreateControl(nil, searchBg, CT_EDITBOX)
        search:SetAnchorFill()
        search:SetFont("ZoFontGame")
    else
        search:SetAnchor(TOPLEFT, searchBg, TOPLEFT, 6, 2)
        search:SetAnchor(BOTTOMRIGHT, searchBg, BOTTOMRIGHT, -6, -2)
    end
    search:SetMaxInputChars(60)
    search:SetText(self.sv and self.sv.search or "")
    search:SetHandler("OnTextChanged", function()
        local t = search:GetText() or ""
        if self.sv then self.sv.search = t end
        self:RefreshPanel()
    end)
    self.searchBox = search

    local searchHint = WM:CreateControl(nil, searchBg, CT_LABEL)
    searchHint:SetFont("ZoFontGameSmall")
    searchHint:SetText("|c666666" .. L.SEARCH .. "|r")
    searchHint:SetAnchor(LEFT, searchBg, LEFT, 8, 0)
    search:SetHandler("OnFocusGained", function() searchHint:SetHidden(true) end)
    search:SetHandler("OnFocusLost", function()
        if (search:GetText() or "") == "" then searchHint:SetHidden(false) end
    end)
    if (search:GetText() or "") ~= "" then searchHint:SetHidden(true) end

    -- Sort row
    local y = 112
    local sortLabel = WM:CreateControl(nil, w, CT_LABEL)
    sortLabel:SetFont("ZoFontGameSmall")
    sortLabel:SetText("|cAAAAAASort|r")
    sortLabel:SetAnchor(TOPLEFT, w, TOPLEFT, 14, y)

    local bx = 50
    local function sortBtn(label, mode)
        local b = MakeBtn(w, label, 70, function()
            if self.sv then self.sv.sortMode = mode end
            self:RefreshPanel()
        end)
        b:SetAnchor(TOPLEFT, w, TOPLEFT, bx, y - 2)
        bx = bx + 74
        return b
    end
    sortBtn(L.SORT_WORST, "worst")
    sortBtn(L.SORT_BEST, "best")
    sortBtn(L.SORT_AZ, "az")

    -- Filter row
    y = 140
    local filtLabel = WM:CreateControl(nil, w, CT_LABEL)
    filtLabel:SetFont("ZoFontGameSmall")
    filtLabel:SetText("|cAAAAAAFilter|r")
    filtLabel:SetAnchor(TOPLEFT, w, TOPLEFT, 14, y)

    bx = 50
    local function filtBtn(label, mode, width)
        local b = MakeBtn(w, label, width or 78, function()
            if self.sv then self.sv.filterMode = mode end
            self:RefreshPanel()
        end)
        b:SetAnchor(TOPLEFT, w, TOPLEFT, bx, y - 2)
        bx = bx + (width or 78) + 4
        return b
    end
    filtBtn(L.FILTER_ALL, "all", 58)
    filtBtn(L.FILTER_RED, "red", 70)
    filtBtn(L.FILTER_ORANGE, "orange", 70)
    filtBtn(L.FILTER_INC, "incomplete", 88)
    filtBtn(L.FILTER_FAV, "fav", 70)

    local status = WM:CreateControl(nil, w, CT_LABEL)
    status:SetFont("ZoFontGameSmall")
    status:SetAnchor(TOPLEFT, w, TOPLEFT, 14, 168)
    status:SetDimensions(450, 20)
    self.statusLabel = status

    local scroll = WINDOW_MANAGER:CreateControlFromVirtual("NagaMapCompletionScroll", w, "ZO_ScrollContainer")
    scroll:SetAnchor(TOPLEFT, w, TOPLEFT, 12, 190)
    scroll:SetAnchor(BOTTOMRIGHT, w, BOTTOMRIGHT, -8, -12)
    scroll:SetMouseEnabled(true)
    self.scrollControl = scroll

    local scrollChild = scroll:GetNamedChild("ScrollChild")
    if not scrollChild then
        scrollChild = WM:CreateControl(nil, scroll, CT_CONTROL)
        scrollChild:SetAnchor(TOPLEFT, scroll, TOPLEFT, 0, 0)
    end
    self.listControl = scrollChild
end

function NMC:ClearPanelRows()
    for _, row in ipairs(self.listRows) do
        if row then
            row:SetHidden(true)
            if row.SetParent then row:SetParent(nil) end
        end
    end
    self.listRows = {}
end

function NMC:FilteredSortedList()
    local list = {}
    local filter = (self.sv and self.sv.filterMode) or "all"
    local search = string.lower((self.sv and self.sv.search) or "")
    search = search:gsub("^%s+", ""):gsub("%s+$", "")

    for _, zone in pairs(self.zones) do
        if zone.percent ~= nil then
            local ok = true
            if filter == "red" then
                ok = zone.percent < 50
            elseif filter == "orange" then
                ok = zone.percent >= 50 and zone.percent < 100
            elseif filter == "incomplete" then
                ok = zone.percent < 100
            elseif filter == "fav" then
                ok = self:IsFavorite(zone.id)
            end
            if ok and search ~= "" then
                local n = string.lower(zone.name or "")
                if not n:find(search, 1, true) then ok = false end
            end
            if ok then table.insert(list, zone) end
        end
    end

    local mode = (self.sv and self.sv.sortMode) or "worst"
    table.sort(list, function(a, b)
        if mode == "best" then
            if (a.percent or -1) ~= (b.percent or -1) then
                return (a.percent or -1) > (b.percent or -1)
            end
        elseif mode == "az" then
            return (a.name or "") < (b.name or "")
        else -- worst
            if (a.percent or -1) ~= (b.percent or -1) then
                return (a.percent or -1) < (b.percent or -1)
            end
        end
        return (a.name or "") < (b.name or "")
    end)
    return list
end

function NMC:ComputeSummary()
    local complete, middle, low = 0, 0, 0
    local missShards, missBooks = 0, 0
    local totalZones = 0
    for _, z in pairs(self.zones) do
        if z.percent ~= nil then
            totalZones = totalZones + 1
            if z.percent >= 100 then complete = complete + 1
            elseif z.percent >= 50 then middle = middle + 1
            else low = low + 1 end
            if z.details then
                for _, d in ipairs(z.details) do
                    if d.type == ZONE_COMPLETION_TYPE_SKYSHARDS then
                        missShards = missShards + math.max(0, d.total - d.completed)
                    elseif d.type == ZONE_COMPLETION_TYPE_MAGES_GUILD_BOOKS then
                        missBooks = missBooks + math.max(0, d.total - d.completed)
                    end
                end
            end
        end
    end
    return totalZones, complete, middle, low, missShards, missBooks
end

function NMC:AddPanelRow(index, zone)
    local row = WM:CreateControl(nil, self.listControl, CT_CONTROL)
    row:SetDimensions(430, 30)
    row:SetAnchor(TOPLEFT, self.listControl, TOPLEFT, 0, (index - 1) * 32)
    row:SetMouseEnabled(true)

    local bg = WM:CreateControl(nil, row, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(1, 1, 1, 0)
    bg:SetEdgeColor(0, 0, 0, 0)
    bg:SetMouseEnabled(false)

    -- Estrela de favorito (textura + cor dourada / cinza — unicode ★ não renderiza em alguns clientes)
    local favBtn = WM:CreateControl(nil, row, CT_BUTTON)
    favBtn:SetDimensions(24, 24)
    favBtn:SetAnchor(LEFT, row, LEFT, 0, 0)
    favBtn:SetMouseEnabled(true)

    local favStar = WM:CreateControl(nil, favBtn, CT_TEXTURE)
    favStar:SetAnchorFill()
    favStar:SetTexture("EsoUI/Art/Campaign/overview_indexicon_bonus_up.dds")
    favStar:SetMouseEnabled(false)
    local function paintStar()
        if NMC:IsFavorite(zone.id) then
            favStar:SetColor(1.0, 0.82, 0.05, 1)   -- dourado
        else
            favStar:SetColor(0.45, 0.45, 0.45, 0.85) -- cinza
        end
    end
    paintStar()
    favBtn:SetHandler("OnClicked", function()
        row.nmcSkipNav = true
        NMC:ToggleFavorite(zone.id)
        paintStar()
        zo_callLater(function()
            if row then row.nmcSkipNav = false end
        end, 200)
    end)
    favBtn:SetHandler("OnMouseEnter", function()
        if NMC:IsFavorite(zone.id) then
            favStar:SetColor(1.0, 0.92, 0.3, 1)
        else
            favStar:SetColor(0.7, 0.7, 0.7, 1)
        end
    end)
    favBtn:SetHandler("OnMouseExit", function()
        paintStar()
    end)

    local c = GetPanelColor(zone.percent)
    local swatch = WM:CreateControl(nil, row, CT_BACKDROP)
    swatch:SetDimensions(14, 14)
    swatch:SetAnchor(LEFT, favBtn, RIGHT, 4, 0)
    swatch:SetCenterColor(c[1], c[2], c[3], c[4])
    swatch:SetEdgeColor(0.8, 0.8, 0.8, 0.5)
    swatch:SetMouseEnabled(false)

    local label = WM:CreateControl(nil, row, CT_LABEL)
    label:SetFont("ZoFontWinH4")
    label:SetAnchor(LEFT, swatch, RIGHT, 6, 0)
    label:SetDimensions(300, 28)
    label:SetText(zone.name)
    label:SetMouseEnabled(false)

    local pct = WM:CreateControl(nil, row, CT_LABEL)
    pct:SetFont("ZoFontWinH4")
    pct:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    pct:SetAnchor(RIGHT, row, RIGHT, -4, 0)
    pct:SetDimensions(55, 28)
    pct:SetText(zone.percent and string.format("%d%%", math.floor(zone.percent + 0.5)) or "N/A")
    pct:SetMouseEnabled(false)

    row:SetHandler("OnMouseEnter", function()
        bg:SetCenterColor(1, 1, 1, 0.08)
        InitializeTooltip(InformationTooltip, row, RIGHT, -10, 0)
        InformationTooltip:AddLine(zone.name, "ZoFontWinH3")
        NMC:AddDetailsToTooltip(InformationTooltip, zone)
        InformationTooltip:AddLine(" ", "ZoFontGame")
        InformationTooltip:AddLine("|cAAAAAA" .. L.CLICK_MAP .. "|r", "ZoFontGame")
        InformationTooltip:AddLine("|cAAAAAA" .. L.FAV_ADD .. "|r", "ZoFontGame")
    end)
    row:SetHandler("OnMouseExit", function()
        bg:SetCenterColor(1, 1, 1, 0)
        ClearTooltip(InformationTooltip)
    end)
    row:SetHandler("OnMouseUp", function(selfRow, button, upInside)
        if not upInside or button ~= MOUSE_BUTTON_INDEX_LEFT then return end
        if selfRow.nmcSkipNav then return end
        if selfRow.nmcClickLock or NMC._navLock then return end
        selfRow.nmcClickLock = true
        NMC:NavigateToZone(zone)
        zo_callLater(function()
            if selfRow then selfRow.nmcClickLock = false end
        end, 600)
    end)

    table.insert(self.listRows, row)
end

function NMC:RefreshPanel()
    if not self.window then self:CreatePanel() end
    self:ClearPanelRows()

    local list = self:FilteredSortedList()
    local totalZones, complete, middle, low, missShards, missBooks = self:ComputeSummary()

    if self.summaryLabel then
        self.summaryLabel:SetText(string.format(
            "|cFFFFFF%s:|r %d  |  |c22FF44● %d %s|r  |cFF9900● %d|r  |cFF2222● %d|r\n|cAAAAAA%s:|r %d  |  |cAAAAAA%s:|r %d",
            L.SUMMARY_ZONES, totalZones, complete, L.SUMMARY_DONE, middle, low,
            L.SUMMARY_SHARDS, missShards, L.SUMMARY_BOOKS, missBooks
        ))
    end

    if self.statusLabel then
        local filt = (self.sv and self.sv.filterMode) or "all"
        local sort = (self.sv and self.sv.sortMode) or "worst"
        self.statusLabel:SetText(string.format(
            "|c888888Showing %d  |  sort: %s  |  filter: %s|r",
            #list, sort, filt))
    end

    for i, zone in ipairs(list) do
        self:AddPanelRow(i, zone)
    end

    if self.listControl then
        local contentH = math.max(1, #list * 32)
        self.listControl:SetDimensions(430, contentH)
        if self.listControl.SetHeight then self.listControl:SetHeight(contentH) end
    end
    if self.scrollControl and self.scrollControl.ResetToTop then
        self.scrollControl:ResetToTop()
    end
end

function NMC:RefreshAll(forcePanel)
    self:BuildZoneData()
    if forcePanel or (self.window and not self.window:IsHidden()) then
        self:RefreshPanel()
    end
    self:HookLocationsList()
    self:RefreshLocationsColors()
    self:RefreshMarkers()
    self:RefreshToggleButtonProgress()
end

function NMC:ShowPanel()
    if not self.window then self:CreatePanel() end
    self.window:SetHidden(false)
    self:RefreshAll(true)
end

function NMC:HidePanel()
    if self.window then self.window:SetHidden(true) end
end

function NMC:TogglePanel()
    if self.sv and self.sv.enablePanel == false then
        d("|cFFAA00NMC:|r Panel disabled in settings.")
        return
    end
    if self.window and not self.window:IsHidden() then
        self:HidePanel()
    else
        self:ShowPanel()
    end
end

function NMC:Debug()
    d("|cFFAA00NagaMapCompletion V" .. VERSION .. "|r")
    d("Lang PT: " .. tostring(IsPortuguese()))
    d("Locations hooked: " .. tostring(self.locationsHooked))
    local count = self:BuildZoneData()
    d("Zone Stories: " .. tostring(count))
    local tz, c, m, l, sh, bk = self:ComputeSummary()
    d(string.format("Summary: zones=%d done=%d mid=%d low=%d shards_missing=%d books_missing=%d", tz, c, m, l, sh, bk))
end

---------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------
local pendingRefresh = false
local pendingSave = false

local function ScheduleRefresh(delayMs, doSave)
    if NMC.sv and NMC.sv.enableAutoRefresh == false then return end
    delayMs = delayMs or 400
    if pendingRefresh then return end
    pendingRefresh = true
    zo_callLater(function()
        pendingRefresh = false
        NMC:RefreshAll(true)
        NMC:RefreshToggleButtonProgress()
        if doSave then
            NMC:SaveCharacterProgress()
        end
    end, delayMs)
end

-- progresso de quest/zone story (sem salvar SV a cada vez — evita lag)
local function ScheduleProgressRefresh()
    ScheduleRefresh(400, false)
end

-- salvamento atrasado (boss morto / sair da área)
local function ScheduleDelayedSave(delayMs)
    if pendingSave then return end
    pendingSave = true
    zo_callLater(function()
        pendingSave = false
        NMC:RefreshAll(true)
        NMC:SaveCharacterProgress()
    end, delayMs or 60000)
end

local function CountTargetBosses()
    local n = 0
    for i = 1, 6 do
        local unit = "boss" .. i
        if type(DoesUnitExist) == "function" and DoesUnitExist(unit) then
            n = n + 1
        end
    end
    return n
end

local function RegisterEvents()
    if NMC.mapCallbacksRegistered then return end
    NMC.mapCallbacksRegistered = true

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "Activated", EVENT_PLAYER_ACTIVATED, function()
        ScheduleRefresh(1200)
        zo_callLater(function() NMC:UpdateToggleButton() end, 300)
    end)

    -- Oculta botão em mapa / inventário / configs / menus
    if SCENE_MANAGER and SCENE_MANAGER.RegisterCallback then
        SCENE_MANAGER:RegisterCallback("SceneStateChanged", function(scene, oldState, newState)
            NMC:UpdateToggleButton()
        end)
    end

    if EVENT_ZONE_CHANGED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "ZoneChanged", EVENT_ZONE_CHANGED, function()
            zo_callLater(function()
                NMC:RefreshToggleButtonProgress()
            end, 500)
        end)
    end

    if CALLBACK_MANAGER then
        CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", function()
            zo_callLater(function() NMC:RefreshMarkers() end, 100)
        end)
    end

    if WORLD_MAP_SCENE then
        WORLD_MAP_SCENE:RegisterCallback("StateChange", function(_, newState)
            NMC:UpdateToggleButton()
            if newState == SCENE_SHOWN then
                zo_callLater(function()
                    NMC:HookLocationsList()
                    NMC:RefreshLocationsColors()
                    NMC:RefreshMarkers()
                end, 150)
            elseif newState == SCENE_HIDDEN then
                NMC:ClearMarkers()
            end
        end)
    end

    local function OnProg() ScheduleProgressRefresh() end

    -- Zone Story (leve)
    local zsEvents = {
        "EVENT_TRACKED_ZONE_STORY_ACTIVITY_COMPLETED",
        "EVENT_ZONE_STORY_ACTIVITY_TRACKED",
        "EVENT_ZONE_STORY_ACTIVITY_UNTRACKED",
        "EVENT_ZONE_STORY_QUEST_ACTIVITY_TRACKED",
    }
    for _, name in ipairs(zsEvents) do
        local ev = _G[name]
        if ev then
            EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. name, ev, OnProg)
        end
    end

    -- Quests importantes (sem counter a cada tick de monstro)
    local questEvents = {
        "EVENT_QUEST_COMPLETE",
        "EVENT_QUEST_ADDED",
        "EVENT_QUEST_REMOVED",
        "EVENT_QUEST_ADVANCED",
    }
    for _, name in ipairs(questEvents) do
        local ev = _G[name]
        if ev then
            EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. name, ev, OnProg)
        end
    end

    -- Só achievement concluído (UPDATED dispara demais e laga)
    if EVENT_ACHIEVEMENT_AWARDED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "AchAwarded", EVENT_ACHIEVEMENT_AWARDED, OnProg)
    end

    -- POI / wayshrine descoberto
    if EVENT_POI_DISCOVERED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "POI", EVENT_POI_DISCOVERED, OnProg)
    end

    -- Salvar ao sair da zona / dungeon
    if EVENT_ZONE_CHANGED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "ZoneSave", EVENT_ZONE_CHANGED, function()
            ScheduleRefresh(800, true) -- refresh + save
        end)
    end

    -- Logout / desconectar
    if EVENT_PLAYER_DEACTIVATED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "Deactivated", EVENT_PLAYER_DEACTIVATED, function()
            NMC:SaveCharacterProgress()
        end)
    end

    -- Boss: quando a barra de boss some, agenda save 1 minuto depois
    local lastBossCount = 0
    local function OnBossesChanged()
        local n = CountTargetBosses()
        if lastBossCount > 0 and n == 0 then
            -- boss acabou de morrer / sumir → salva 60s depois
            ScheduleDelayedSave(60000)
        end
        lastBossCount = n
    end
    if EVENT_BOSSES_CHANGED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "Bosses", EVENT_BOSSES_CHANGED, OnBossesChanged)
    end
    -- fallback: fim de combate após ter tido boss
    if EVENT_PLAYER_COMBAT_STATE then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "Combat", EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
            if not inCombat and lastBossCount == 0 then
                -- não salva em todo fim de combate; só se ScheduleDelayedSave já foi pedido pelo boss
            end
        end)
    end
end

local function OnSlash(args)
    args = string.lower(zo_strtrim(args or ""))
    if args == "refresh" then
        NMC:RefreshAll(true)
        d("|c55FF55NagaMapCompletion " .. L.REFRESHED .. "|r")
    elseif args == "debug" then
        -- hidden diagnostic
        NMC:Debug()
    else
        NMC:TogglePanel()
    end
end


---------------------------------------------------------------------------
-- Settings panel (LibAddonMenu-2.0)
---------------------------------------------------------------------------
function NMC:RegisterSettings()
    local LAM = LibAddonMenu2 or LibStub and LibStub("LibAddonMenu-2.0", true)
    if not LAM then
        -- Sem LAM: ainda aparece aviso no /nmc help
        self.lamMissing = true
        return
    end

    local panelData = {
        type = "panel",
        name = "NagaMapCompletion",
        displayName = "|cE0B050Naga Map Completion|r",
        author = "N A G A",
        version = VERSION,
        website = "",
        slashCommand = "/nmcsettings",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local options = {
        {
            type = "header",
            name = IsPortuguese() and "Recursos" or "Features",
        },
        {
            type = "checkbox",
            name = IsPortuguese() and "Cores na lista Locais" or "Color Locations list",
            tooltip = IsPortuguese()
                and "Colore os nomes das zonas na aba Locais do mapa."
                or "Colors zone names in the map Locations list.",
            getFunc = function() return NMC.sv.enableLocationColors end,
            setFunc = function(v)
                NMC.sv.enableLocationColors = v
                NMC:RefreshLocationsColors()
                if WORLD_MAP_LOCATIONS and WORLD_MAP_LOCATIONS.list and ZO_ScrollList_RefreshVisible then
                    ZO_ScrollList_RefreshVisible(WORLD_MAP_LOCATIONS.list)
                end
            end,
            default = true,
        },
        {
            type = "checkbox",
            name = IsPortuguese() and "Tooltips de progresso em Locais" or "Progress tooltips on Locations",
            tooltip = IsPortuguese()
                and "Mostra % e itens coletados ao passar o mouse em Locais."
                or "Shows % and collected items when hovering Locations.",
            getFunc = function() return NMC.sv.enableLocationTooltips end,
            setFunc = function(v) NMC.sv.enableLocationTooltips = v end,
            default = true,
        },
        {
            type = "checkbox",
            name = IsPortuguese() and "Painel /nmc" or "/nmc panel",
            tooltip = IsPortuguese()
                and "Permite abrir o painel com /nmc."
                or "Allow opening the panel with /nmc.",
            getFunc = function() return NMC.sv.enablePanel end,
            setFunc = function(v)
                NMC.sv.enablePanel = v
                NMC:UpdateToggleButton()
            end,
            default = true,
        },
        {
            type = "checkbox",
            name = IsPortuguese() and "Botão na tela (abrir/fechar)" or "On-screen button (open/close)",
            tooltip = IsPortuguese()
                and "Mostra um botão arrastável na tela para abrir e fechar o painel NMC."
                or "Shows a draggable on-screen button to open and close the NMC panel.",
            getFunc = function() return NMC.sv.showToggleButton end,
            setFunc = function(v)
                NMC.sv.showToggleButton = v
                NMC:UpdateToggleButton()
            end,
            default = false,
            disabled = function() return NMC.sv.enablePanel == false end,
        },
        {
            type = "slider",
            name = IsPortuguese() and "Tamanho do botão" or "Button size",
            tooltip = IsPortuguese()
                and "Altura do botão retangular (36–80). A largura acompanha."
                or "Height of the rectangular button (36–80). Width scales with it.",
            min = 36,
            max = 80,
            step = 2,
            getFunc = function() return NMC.sv.toggleButtonSize or 48 end,
            setFunc = function(v)
                NMC.sv.toggleButtonSize = v
                NMC:ApplyToggleButtonSize()
                NMC:RefreshToggleButtonProgress()
            end,
            default = 48,
            disabled = function()
                return not NMC.sv.showToggleButton or NMC.sv.enablePanel == false
            end,
        },
        {
            type = "checkbox",
            name = IsPortuguese() and "Favoritos" or "Favorites",
            tooltip = IsPortuguese()
                and "Permite marcar zonas com estrela."
                or "Allow starring zones as favorites.",
            getFunc = function() return NMC.sv.enableFavorites end,
            setFunc = function(v) NMC.sv.enableFavorites = v end,
            default = true,
        },
        {
            type = "checkbox",
            name = IsPortuguese() and "Atualização automática" or "Auto refresh",
            tooltip = IsPortuguese()
                and "Atualiza ao completar Zone Story, quests, etc."
                or "Refresh on Zone Story, quests, achievements, etc.",
            getFunc = function() return NMC.sv.enableAutoRefresh end,
            setFunc = function(v) NMC.sv.enableAutoRefresh = v end,
            default = true,
        },
        {
            type = "checkbox",
            name = IsPortuguese() and "Mensagens no chat ao carregar" or "Chat messages on load",
            getFunc = function() return NMC.sv.enableChatMessages end,
            setFunc = function(v) NMC.sv.enableChatMessages = v end,
            default = true,
        },
        {
            type = "header",
            name = IsPortuguese() and "Comandos" or "Commands",
        },
        {
            type = "description",
            text = "|cFFFFFF/nmc|r — open/close panel\n|cFFFFFF/nmc refresh|r — refresh progress\n|cFFFFFF/nmcsettings|r — this menu",
        },
    }

    LAM:RegisterAddonPanel("NagaMapCompletionSettings", panelData)
    LAM:RegisterOptionControls("NagaMapCompletionSettings", options)
    self.lamRegistered = true
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    NMC.sv = ZO_SavedVars:NewAccountWide("NagaMapCompletionSV", 1, nil, DEFAULTS)
    NMC.sv.showMapMarkers = false
    NMC.sv.showMissingPins = false
    NMC:ClearMarkers()
    NMC:RefreshMarkers()
    BuildL()
    NMC:RegisterSettings()

    SLASH_COMMANDS["/nmc"] = OnSlash
    RegisterEvents()
    NMC:CreatePanel()
    NMC:UpdateToggleButton()
    zo_callLater(function()
        NMC:RefreshAll()
    end, 800)

    if NMC.sv.enableChatMessages ~= false then
        d("|cE0B050NagaMapCompletion v" .. VERSION .. "|r |cAAAAAA— N A G A|r")
        d("|cFFFFFF/nmc|r " .. L.CMD_PANEL .. "  |  |cFFFFFF/nmc refresh|r " .. L.CMD_REFRESH)
        d("|cAAAAAAESC → Addons → Naga Map Completion|r")
        if NMC.lamMissing then
            d("|cFF5555Requires LibAddonMenu-2.0 for settings.|r")
        end
    end
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
