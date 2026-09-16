-- NagaMapCompletion 0.8.1
-- Colors the native World Map "Locations" list by Zone Story progress:
--   GREEN  = 100%
--   ORANGE = 50–99%
--   RED    = under 50%
-- Panel: /nmc

local NMC = {}
NagaMapCompletion = NMC

local ADDON_NAME = "NagaMapCompletion"
local VERSION = "0.8.1"
local WM = WINDOW_MANAGER

NMC.pinColors = {
    complete = {0.20, 0.95, 0.30, 1},
    middle   = {1.00, 0.60, 0.10, 1},
    low      = {1.00, 0.25, 0.25, 1},
    unknown  = {0.75, 0.70, 0.55, 1}, -- default parchment-ish
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
NMC.nameLookup = {}  -- normalized name -> percent
NMC.window = nil
NMC.statusLabel = nil
NMC.listRows = {}
NMC.scrollControl = nil
NMC.listControl = nil
NMC.mapCallbacksRegistered = false
NMC.locationsHooked = false

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
    -- remove common connector words for fuzzy match
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

function NMC:GetZoneProgress(zoneId)
    if type(IsZoneStoryComplete) == "function" then
        local ok, complete = pcall(IsZoneStoryComplete, zoneId)
        if ok and complete then
            return 100
        end
    end

    local completed, total = 0, 0

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
            if ok and tonumber(c) and tonumber(t) and tonumber(t) > 0 then
                completed = completed + Clamp(tonumber(c), 0, tonumber(t))
                total = total + tonumber(t)
            elseif type(GetNumCompletedZoneActivitiesForZoneCompletionType) == "function"
               and type(GetNumZoneActivitiesForZoneCompletionType) == "function" then
                local ok2, c2 = pcall(GetNumCompletedZoneActivitiesForZoneCompletionType, zoneId, completionType)
                local ok3, t3 = pcall(GetNumZoneActivitiesForZoneCompletionType, zoneId, completionType)
                if ok2 and ok3 and tonumber(c2) and tonumber(t3) and tonumber(t3) > 0 then
                    completed = completed + Clamp(tonumber(c2), 0, tonumber(t3))
                    total = total + tonumber(t3)
                end
            end
        end
    end

    if total > 0 then
        return Clamp((completed / total) * 100, 0, 100)
    end
    return nil
end

function NMC:BuildZoneData()
    self.zones = {}
    self.nameLookup = {}

    if type(GetNextZoneStoryZoneId) ~= "function" then
        return 0
    end

    local zoneId = GetNextZoneStoryZoneId()
    local count, safety = 0, 0

    while zoneId ~= nil and zoneId ~= 0 and safety < 500 do
        safety = safety + 1
        local name = SafeName(zoneId)
        local percent = self:GetZoneProgress(zoneId)

        local mapId = nil
        if type(GetMapIdByZoneId) == "function" then
            local ok, result = pcall(GetMapIdByZoneId, zoneId)
            if ok and result and result ~= 0 then
                mapId = result
            end
        end

        self.zones[zoneId] = {
            id = zoneId,
            name = name,
            percent = percent,
            mapId = mapId,
        }

        if percent ~= nil then
            local key = NormalizeName(name)
            if key ~= "" then
                self.nameLookup[key] = percent
            end
            -- also index English part inside parentheses if different
            local eng = name:match("%(([^%)]+)%)")
            if eng then
                local ek = NormalizeName(eng)
                if ek ~= "" and not self.nameLookup[ek] then
                    self.nameLookup[ek] = percent
                end
            end
        end

        count = count + 1
        local nextId = GetNextZoneStoryZoneId(zoneId)
        if nextId == zoneId then break end
        zoneId = nextId
    end
    return count
end

function NMC:LookupPercentForLocationName(locationName)
    if not locationName then return nil end
    local key = NormalizeName(locationName)
    if self.nameLookup[key] then
        return self.nameLookup[key]
    end
    local eng = locationName:match("%(([^%)]+)%)")
    if eng then
        local ek = NormalizeName(eng)
        if self.nameLookup[ek] then return self.nameLookup[ek] end
    end
    -- fuzzy: any lookup key contained in the location name (or vice-versa)
    local lower = string.lower(locationName)
    for k, pct in pairs(self.nameLookup) do
        if #k >= 4 then
            if lower:find(k, 1, true) or k:find(key, 1, true) or key:find(k, 1, true) then
                return pct
            end
        end
    end
    return nil
end

---------------------------------------------------------------------------
-- Color native Locations list
---------------------------------------------------------------------------

local function ApplyLabelColor(label, percent)
    if not label then return end
    local key = GetColorKey(percent)
    local c = NMC.pinColors[key]
    local r, g, b, a = c[1], c[2], c[3], c[4]

    -- Guardar para reaplicar no hover
    label.nmcPercent = percent
    label.nmcR, label.nmcG, label.nmcB, label.nmcA = r, g, b, a

    if label.SetColor then
        label:SetColor(r, g, b, a)
    end
    -- ZO_SelectableLabel / button-style labels
    if label.SetNormalFontColor then
        label:SetNormalFontColor(r, g, b, a)
    end
    if label.SetMouseOverFontColor then
        label:SetMouseOverFontColor(math.min(1, r + 0.15), math.min(1, g + 0.15), math.min(1, b + 0.15), a)
    end
    if label.SetPressedFontColor then
        label:SetPressedFontColor(r, g, b, a)
    end
    if label.SetDisabledFontColor then
        label:SetDisabledFontColor(r * 0.55, g * 0.55, b * 0.55, a)
    end
    if label.SetSelectedFontColor then
        label:SetSelectedFontColor(r, g, b, a)
    end
end

local function StatusTextForPercent(percent)
    if percent == nil then
        return "|cBBBBBBNo Zone Story data|r"
    end
    local key = GetColorKey(percent)
    local pct = string.format("%d%%", math.floor(percent + 0.5))
    if key == "complete" then
        return "|c22FF44● " .. pct .. " complete|r"
    elseif key == "middle" then
        return "|cFF9900● " .. pct .. " in progress|r"
    else
        return "|cFF3333● " .. pct .. " low progress|r"
    end
end

function NMC:ColorLocationControl(control, data)
    if not control or not data then return end
    local locationLabel = control:GetNamedChild("Location")
    if not locationLabel then return end

    local percent = self:LookupPercentForLocationName(data.locationName)
    -- também tenta o texto já renderizado
    if percent == nil and locationLabel.GetText then
        percent = self:LookupPercentForLocationName(locationLabel:GetText())
    end

    locationLabel.nmcLocationName = data.locationName
    ApplyLabelColor(locationLabel, percent)

    -- Reaplica cor no hover / exit + tooltip com %
    if not locationLabel.nmcHoverHooked then
        locationLabel.nmcHoverHooked = true
        local oldEnter = locationLabel:GetHandler("OnMouseEnter")
        local oldExit = locationLabel:GetHandler("OnMouseExit")
        locationLabel:SetHandler("OnMouseEnter", function(lbl, ...)
            if oldEnter then oldEnter(lbl, ...) end
            if lbl.nmcR then
                ApplyLabelColor(lbl, lbl.nmcPercent)
            end
            local name = lbl.nmcLocationName or (lbl.GetText and lbl:GetText()) or "Zone"
            InitializeTooltip(InformationTooltip, lbl, RIGHT, -16, 0)
            InformationTooltip:AddLine(name, "ZoFontGameHighlight")
            InformationTooltip:AddLine("Zone Story: " .. StatusTextForPercent(lbl.nmcPercent), "ZoFontGame")
            if lbl.nmcPercent ~= nil then
                local key = GetColorKey(lbl.nmcPercent)
                if key == "complete" then
                    InformationTooltip:AddLine("|c22FF44Green = 100% complete|r", "ZoFontGame")
                elseif key == "middle" then
                    InformationTooltip:AddLine("|cFF9900Orange = 50–99%|r", "ZoFontGame")
                else
                    InformationTooltip:AddLine("|cFF3333Red = under 50%|r", "ZoFontGame")
                end
            end
        end)
        locationLabel:SetHandler("OnMouseExit", function(lbl, ...)
            ClearTooltip(InformationTooltip)
            if oldExit then oldExit(lbl, ...) end
            if lbl.nmcR then
                ApplyLabelColor(lbl, lbl.nmcPercent)
            end
        end)
    end
end

function NMC:HookLocationsList()
    if self.locationsHooked then return end

    local function tryHook()
        if NMC.locationsHooked then return true end
        if not WORLD_MAP_LOCATIONS or not WORLD_MAP_LOCATIONS.SetupLocation then
            return false
        end

        local original = WORLD_MAP_LOCATIONS.SetupLocation
        WORLD_MAP_LOCATIONS.SetupLocation = function(self, control, data)
            original(self, control, data)
            -- depois do SetSelected/SetEnabled do jogo
            NMC:ColorLocationControl(control, data)
            -- mais um frame depois (alguns estados de label aplicam cor tarde)
            zo_callLater(function()
                if control and data then
                    NMC:ColorLocationControl(control, data)
                end
            end, 10)
        end

        NMC.locationsHooked = true
        return true
    end

    if not tryHook() then
        if WORLD_MAP_SCENE then
            WORLD_MAP_SCENE:RegisterCallback("StateChange", function(_, newState)
                if newState == SCENE_SHOWN then
                    zo_callLater(function()
                        if tryHook() then
                            NMC:RefreshLocationsColors()
                        end
                    end, 100)
                end
            end)
        end
    end
end

function NMC:RefreshLocationsColors()
    if not WORLD_MAP_LOCATIONS or not WORLD_MAP_LOCATIONS.list then return end
    if type(ZO_ScrollList_RefreshVisible) == "function" then
        ZO_ScrollList_RefreshVisible(WORLD_MAP_LOCATIONS.list)
    end
    -- força recolor em todas as rows visíveis
    zo_callLater(function()
        if not WORLD_MAP_LOCATIONS or not WORLD_MAP_LOCATIONS.list then return end
        local list = WORLD_MAP_LOCATIONS.list
        local num = list:GetNumChildren() or 0
        for i = 1, num do
            local row = list:GetChild(i)
            if row then
                local data = nil
                if ZO_ScrollList_GetData then
                    data = ZO_ScrollList_GetData(row)
                end
                if data then
                    NMC:ColorLocationControl(row, data)
                else
                    -- fallback: colorir pelo texto
                    local locationLabel = row:GetNamedChild("Location")
                    if locationLabel and locationLabel.GetText then
                        local percent = NMC:LookupPercentForLocationName(locationLabel:GetText())
                        ApplyLabelColor(locationLabel, percent)
                    end
                end
            end
        end
    end, 50)
end

---------------------------------------------------------------------------
-- Panel
---------------------------------------------------------------------------

function NMC:CreatePanel()
    if self.window then return end

    local w = WM:CreateTopLevelWindow("NagaMapCompletionPanel")
    self.window = w
    w:SetDimensions(460, 680)
    w:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 24, 80)
    w:SetMouseEnabled(true)
    w:SetMovable(true)
    w:SetClampedToScreen(true)
    w:SetDrawLayer(DL_OVERLAY)
    w:SetDrawLevel(50)
    w:SetHidden(true)

    local bg = WM:CreateControl(nil, w, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0.02, 0.02, 0.02, 0.94)
    bg:SetEdgeColor(0.72, 0.48, 0.08, 0.95)

    local title = WM:CreateControl(nil, w, CT_LABEL)
    title:SetFont("ZoFontWinH1")
    title:SetText("|cFFFFFFNAGA MAP COMPLETION|r")
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    title:SetAnchor(TOP, w, TOP, 0, 12)
    title:SetDimensions(420, 34)

    local sub = WM:CreateControl(nil, w, CT_LABEL)
    sub:SetFont("ZoFontGame")
    sub:SetText("|c22FF44● 100%|r    |cFF9900● 50–99%|r    |cFF2222● <50%|r    |c888888(scroll)|r")
    sub:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    sub:SetAnchor(TOP, title, BOTTOM, 0, 2)
    sub:SetDimensions(420, 22)

    local close = WM:CreateControl(nil, w, CT_BUTTON)
    close:SetFont("ZoFontGameBold")
    close:SetText("|cFF5555X|r")
    close:SetDimensions(30, 30)
    close:SetAnchor(TOPRIGHT, w, TOPRIGHT, -7, 7)
    close:SetHandler("OnClicked", function() self:HidePanel() end)

    local status = WM:CreateControl(nil, w, CT_LABEL)
    status:SetFont("ZoFontGame")
    status:SetAnchor(TOPLEFT, w, TOPLEFT, 16, 68)
    status:SetDimensions(420, 24)
    self.statusLabel = status

    local scroll = WINDOW_MANAGER:CreateControlFromVirtual("NagaMapCompletionScroll", w, "ZO_ScrollContainer")
    scroll:SetAnchor(TOPLEFT, w, TOPLEFT, 12, 96)
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

function NMC:NavigateToZone(zone)
    if not zone then return end

    -- Abre o mapa-mundi
    if type(ZO_WorldMap_ShowWorldMap) == "function" then
        ZO_WorldMap_ShowWorldMap()
    elseif SCENE_MANAGER and SCENE_MANAGER.Show then
        SCENE_MANAGER:Show("worldMap")
    end

    local function go()
        local changed = false

        -- 1) Preferir SetMapToMapId (API moderna)
        if zone.mapId and type(SetMapToMapId) == "function" then
            local ok, result = pcall(SetMapToMapId, zone.mapId)
            if ok and result and SET_MAP_RESULT_FAILED and result ~= SET_MAP_RESULT_FAILED then
                changed = true
            elseif ok and result == true then
                changed = true
            elseif ok and type(result) == "number" and result ~= 0 then
                changed = true
            end
        end

        -- 2) Fallback: índice do mapa via GetMapIndexByZoneId / GetMapIndexById
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
            d("|c55FF55NMC:|r Showing map for |cFFFFFF" .. (zone.name or "?") .. "|r")
        else
            d("|cFFAA00NMC:|r Could not open map for |cFFFFFF" .. (zone.name or "?") .. "|r (no map id)")
        end
    end

    -- pequeno delay para o mapa abrir antes de trocar
    zo_callLater(go, 100)
end

function NMC:AddPanelRow(index, zone)
    local row = WM:CreateControl(nil, self.listControl, CT_CONTROL)
    row:SetDimensions(410, 26)
    row:SetAnchor(TOPLEFT, self.listControl, TOPLEFT, 0, (index - 1) * 27)
    row:SetMouseEnabled(true)

    -- highlight ao passar o mouse
    local bg = WM:CreateControl(nil, row, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(1, 1, 1, 0)
    bg:SetEdgeColor(0, 0, 0, 0)
    bg:SetMouseEnabled(false)

    local c = GetPanelColor(zone.percent)
    local swatch = WM:CreateControl(nil, row, CT_BACKDROP)
    swatch:SetDimensions(16, 16)
    swatch:SetAnchor(LEFT, row, LEFT, 2, 0)
    swatch:SetCenterColor(c[1], c[2], c[3], c[4])
    swatch:SetEdgeColor(0.8, 0.8, 0.8, 0.55)
    swatch:SetMouseEnabled(false)

    local label = WM:CreateControl(nil, row, CT_LABEL)
    label:SetFont("ZoFontGame")
    label:SetAnchor(LEFT, swatch, RIGHT, 8, 0)
    label:SetDimensions(300, 24)
    label:SetText(zone.name)
    label:SetMouseEnabled(false)

    local pct = WM:CreateControl(nil, row, CT_LABEL)
    pct:SetFont("ZoFontGameBold")
    pct:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    pct:SetAnchor(RIGHT, row, RIGHT, -8, 0)
    pct:SetDimensions(55, 24)
    pct:SetText(zone.percent and string.format("%d%%", math.floor(zone.percent + 0.5)) or "N/A")
    pct:SetMouseEnabled(false)

    row:SetHandler("OnMouseEnter", function()
        bg:SetCenterColor(1, 1, 1, 0.08)
        InitializeTooltip(InformationTooltip, row, RIGHT, -10, 0)
        InformationTooltip:AddLine(zone.name, "ZoFontGameHighlight")
        local p = zone.percent and string.format("%d%%", math.floor(zone.percent + 0.5)) or "N/A"
        InformationTooltip:AddLine("Zone Story: " .. p, "ZoFontGame")
        InformationTooltip:AddLine("|cAAAAAAClick to open this zone on the map|r", "ZoFontGame")
    end)
    row:SetHandler("OnMouseExit", function()
        bg:SetCenterColor(1, 1, 1, 0)
        ClearTooltip(InformationTooltip)
    end)
    row:SetHandler("OnMouseUp", function(_, button, upInside)
        if upInside and button == MOUSE_BUTTON_INDEX_LEFT then
            NMC:NavigateToZone(zone)
        end
    end)

    table.insert(self.listRows, row)
end

function NMC:RefreshPanel()
    if not self.window then self:CreatePanel() end
    self:ClearPanelRows()

    local list = {}
    for _, zone in pairs(self.zones) do
        if zone.percent ~= nil then
            table.insert(list, zone)
        end
    end
    table.sort(list, function(a, b)
        if (a.percent or -1) ~= (b.percent or -1) then
            return (a.percent or -1) > (b.percent or -1)
        end
        return a.name < b.name
    end)

    local complete, middle, low = 0, 0, 0
    for _, zone in ipairs(list) do
        if zone.percent >= 100 then complete = complete + 1
        elseif zone.percent >= 50 then middle = middle + 1
        else low = low + 1 end
    end

    if self.statusLabel then
        self.statusLabel:SetText(string.format(
            "Zones: %d  |  |c22FF44● %d|r  |  |cFF9900● %d|r  |  |cFF2222● %d|r",
            #list, complete, middle, low))
    end

    for i, zone in ipairs(list) do
        self:AddPanelRow(i, zone)
    end

    if self.listControl then
        local contentH = math.max(1, #list * 27)
        self.listControl:SetDimensions(410, contentH)
        if self.listControl.SetHeight then
            self.listControl:SetHeight(contentH)
        end
    end
    if self.scrollControl and self.scrollControl.ResetToTop then
        self.scrollControl:ResetToTop()
    end
end

function NMC:RefreshAll()
    self:BuildZoneData()
    self:RefreshPanel()
    self:HookLocationsList()
    self:RefreshLocationsColors()
end

function NMC:ShowPanel()
    if not self.window then self:CreatePanel() end
    self.window:SetHidden(false)
    self:RefreshAll()
end

function NMC:HidePanel()
    if self.window then self.window:SetHidden(true) end
end

function NMC:TogglePanel()
    if self.window and not self.window:IsHidden() then
        self:HidePanel()
    else
        self:ShowPanel()
    end
end

function NMC:Debug()
    d("|cFFAA00NagaMapCompletion V" .. VERSION .. "|r")
    d("API: " .. tostring(GetAPIVersion and GetAPIVersion() or "?"))
    d("Locations hooked: " .. tostring(self.locationsHooked))
    local count = self:BuildZoneData()
    d("Zone Stories: " .. tostring(count))
    d("Name lookup entries: " .. tostring((function()
        local n = 0
        for _ in pairs(self.nameLookup) do n = n + 1 end
        return n
    end)()))
    local shown = 0
    for _, z in pairs(self.zones) do
        if z.percent ~= nil and shown < 12 then
            d(string.format("  %s  %.0f%%", z.name, z.percent or -1))
            shown = shown + 1
        end
    end
end

---------------------------------------------------------------------------
-- Events / Slash
---------------------------------------------------------------------------

local pendingRefresh = false
local function ScheduleRefresh(delayMs)
    if pendingRefresh then return end
    pendingRefresh = true
    zo_callLater(function()
        pendingRefresh = false
        NMC:RefreshAll()
    end, delayMs or 800)
end

local function RegisterEvents()
    if NMC.mapCallbacksRegistered then return end
    NMC.mapCallbacksRegistered = true

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "Activated", EVENT_PLAYER_ACTIVATED, function()
        ScheduleRefresh(1200)
    end)

    if WORLD_MAP_SCENE then
        WORLD_MAP_SCENE:RegisterCallback("StateChange", function(_, newState)
            if newState == SCENE_SHOWN then
                zo_callLater(function()
                    NMC:HookLocationsList()
                    NMC:RefreshLocationsColors()
                end, 150)
            end
        end)
    end

    local function OnZoneStoryProgress()
        ScheduleRefresh(600)
    end

    if EVENT_TRACKED_ZONE_STORY_ACTIVITY_COMPLETED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "ZSComplete", EVENT_TRACKED_ZONE_STORY_ACTIVITY_COMPLETED, OnZoneStoryProgress)
    end
    if EVENT_ZONE_STORY_ACTIVITY_TRACKED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "ZSTracked", EVENT_ZONE_STORY_ACTIVITY_TRACKED, OnZoneStoryProgress)
    end
    if EVENT_ZONE_STORY_ACTIVITY_UNTRACKED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "ZSUntracked", EVENT_ZONE_STORY_ACTIVITY_UNTRACKED, OnZoneStoryProgress)
    end
    if EVENT_ZONE_STORY_ACTIVITY_TRACKING_INIT then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "ZSInit", EVENT_ZONE_STORY_ACTIVITY_TRACKING_INIT, OnZoneStoryProgress)
    end
    if EVENT_QUEST_COMPLETE then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "QuestComplete", EVENT_QUEST_COMPLETE, OnZoneStoryProgress)
    end
    if EVENT_ACHIEVEMENT_UPDATED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "AchUpdated", EVENT_ACHIEVEMENT_UPDATED, OnZoneStoryProgress)
    end
    if EVENT_ACHIEVEMENT_AWARDED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "AchAwarded", EVENT_ACHIEVEMENT_AWARDED, OnZoneStoryProgress)
    end
    if EVENT_POI_DISCOVERED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "POI", EVENT_POI_DISCOVERED, OnZoneStoryProgress)
    end
    if EVENT_DISCOVERY_EXPERIENCE then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "Discovery", EVENT_DISCOVERY_EXPERIENCE, OnZoneStoryProgress)
    end
end

local function OnSlash(args)
    args = string.lower(zo_strtrim(args or ""))
    if args == "debug" then
        NMC:Debug()
    elseif args == "refresh" then
        NMC:RefreshAll()
        d("|c55FF55NagaMapCompletion refreshed.|r")
    elseif args == "help" then
        d("|cFFAA00NagaMapCompletion commands:|r")
        d("|cFFFFFF/nmc|r — open/close the progress panel")
        d("|cFFFFFF/nmc refresh|r — force refresh progress + location colors")
        d("|cFFFFFF/nmc debug|r — print diagnostic info")
        d("|cFFFFFF/nmc help|r — show this help")
        d("|cAAAAAAClick a zone in the panel to open its map.|r")
    else
        NMC:TogglePanel()
    end
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    SLASH_COMMANDS["/nmc"] = OnSlash
    RegisterEvents()
    NMC:CreatePanel()
    zo_callLater(function()
        NMC:RefreshAll()
    end, 800)

    d("|cFFAA00========================================|r")
    d("|cFFAA00  NagaMapCompletion v" .. VERSION .. " loaded|r")
    d("|cFFAA00========================================|r")
    d("|cFFFFFFHow to use:|r")
    d("  |cFFFFFF/nmc|r — open/close the progress panel")
    d("  |cFFFFFF/nmc refresh|r — force refresh")
    d("  |cFFFFFF/nmc debug|r — diagnostics")
    d("  |cFFFFFF/nmc help|r — show commands")
    d("|cAAAAAAClick a zone in /nmc panel to open its map.|r")
    d("|cAAAAAAMap Locations list colors:|r |c22FF44● 100%|r  |cFF9900● 50–99%|r  |cFF2222● <50%|r")
    d("|c55FF55Auto-updates on Zone Story progress, quests, achievements & POIs.|r")
    d("|cFFAA00========================================|r")
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
