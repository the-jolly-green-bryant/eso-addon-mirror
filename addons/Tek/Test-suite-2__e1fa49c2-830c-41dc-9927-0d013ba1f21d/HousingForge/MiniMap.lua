HF.MiniMap = {
    enabled = false,
    initialized = false,
    items = {},
    allItems = {},
    pins = {},
    filter = "essentials",
    bounds = nil,
    configured = false,
}

local UPDATE_NAME = "HousingForge_MiniMapUpdate"
local SCAN_UPDATE_NAME = "HousingForge_MiniMapScan"
local MAP_WIDTH = 230
local MAP_HEIGHT = 276
local SCAN_BATCH_SIZE = 35

local function NoOp()
end

local CATEGORY_COLORS = {
    crafting = { 0.2, 0.75, 1, 1 },
    set = { 0.75, 0.45, 1, 1 },
    mundus = { 1, 0.85, 0.2, 1 },
    services = { 0.35, 1, 0.45, 1 },
    storage = { 1, 0.55, 0.2, 1 },
    dummies = { 1, 0.25, 0.25, 1 },
    utilities = { 0.25, 1, 0.9, 1 },
}

local CATEGORY_LETTERS = {
    crafting = "C",
    set = "S",
    mundus = "M",
    services = "V",
    storage = "B",
    dummies = "D",
    utilities = "U",
}

local FILTER_ORDER = {
    "essentials",
    "crafting",
    "set",
    "mundus",
    "services",
    "storage",
    "dummies",
    "utilities",
}

local function Lower(value)
    if not value then return "" end
    return string.lower(tostring(value))
end

local function ContainsAny(name, terms)
    for _, term in ipairs(terms) do
        if string.find(name, term, 1, true) then return true end
    end
    return false
end

local function ClassifyItem(item)
    local name = Lower(item.itemName or item.name)

    if ContainsAny(name, {
        "the apprentice", "the atronach", "the lady", "the lord", "the lover",
        "the mage", "the ritual", "the serpent", "the shadow", "the steed",
        "the thief", "the tower", "the warrior",
    }) and not ContainsAny(name, { "painting", "tapestry", "banner", "statue" }) then
        return "mundus"
    end

    if ContainsAny(name, { "grand master crafting station", "attunable " }) then
        return "set"
    end

    if ContainsAny(name, {
        "blacksmithing station", "clothing station", "woodworking station",
        "jewelry crafting station", "alchemy station", "enchanting station",
        "provisioning station", "cooking fire",
    }) then
        return "crafting"
    end

    if ContainsAny(name, { "banker", "merchant", "fence assistant", "smuggler assistant", "deconstruction assistant" }) then
        return "services"
    end

    if ContainsAny(name, { "storage chest", "storage coffer" }) then
        return "storage"
    end

    if ContainsAny(name, { "target dummy", "trial dummy", "training dummy", "robust target", "precursor" }) then
        return "dummies"
    end

    if ContainsAny(name, {
        "aetherial well", "transmute station", "outfit station", "dye station",
        "armory station", "vampiric basin", "vampiric fountain",
    }) then
        return "utilities"
    end

    return nil
end

local function CaptureFurnitureEntry(furnitureId)
    local itemName, icon, furnitureDataId = GetPlacedHousingFurnitureInfo(furnitureId)
    local itemLink, collectibleLink = GetPlacedFurnitureLink(furnitureId, LINK_STYLE_DEFAULT)
    local worldX, worldY, worldZ = HousingEditorGetFurnitureWorldPosition(furnitureId)
    local itemId = 0
    if itemLink and itemLink ~= "" and GetItemLinkItemId then
        itemId = GetItemLinkItemId(itemLink) or 0
    end

    return {
        furnitureDataId = furnitureDataId or 0,
        itemName = HF.GetSafeLinkName(itemLink, itemName),
        icon = icon or "",
        itemLink = itemLink or "",
        collectibleLink = collectibleLink or "",
        itemId = itemId,
        worldX = worldX or 0,
        worldY = worldY or 0,
        worldZ = worldZ or 0,
    }
end

local function GetSelectedLayoutItems()
    if not HF.GetSelectedLayout then return nil end
    local layout = HF.GetSelectedLayout()
    if layout and type(layout.items) == "table" and #layout.items > 0 then
        return layout.items, layout.name or "Selected Layout"
    end
    return nil
end

local function ComputeBounds(items)
    local bounds = nil
    for _, item in ipairs(items or {}) do
        local x = tonumber(item.worldX)
        local z = tonumber(item.worldZ)
        if x and z then
            if not bounds then
                bounds = { minX = x, maxX = x, minZ = z, maxZ = z }
            else
                if x < bounds.minX then bounds.minX = x end
                if x > bounds.maxX then bounds.maxX = x end
                if z < bounds.minZ then bounds.minZ = z end
                if z > bounds.maxZ then bounds.maxZ = z end
            end
        end
    end

    if not bounds then return nil end
    local width = bounds.maxX - bounds.minX
    local depth = bounds.maxZ - bounds.minZ
    if width < 100 then
        bounds.minX = bounds.minX - 50
        bounds.maxX = bounds.maxX + 50
    end
    if depth < 100 then
        bounds.minZ = bounds.minZ - 50
        bounds.maxZ = bounds.maxZ + 50
    end
    return bounds
end

local function FilterEssentials(items, filter)
    local filtered = {}
    for _, item in ipairs(items or {}) do
        local category = item.hfCategory or ClassifyItem(item)
        if category then
            item.hfCategory = category
            if filter == "all" or filter == "essentials" or filter == category then
                table.insert(filtered, item)
            end
        end
    end
    return filtered
end

local function CreateLabel(name, parent, text, font)
    local label = WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL)
    label:SetFont(font or "ZoFontGameSmall")
    label:SetText(text or "")
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    return label
end

local function SaveWorldMapState()
    if HF.MiniMap.savedWorldMapState or not ZO_WorldMap then return end
    local left, top = ZO_WorldMap:GetLeft(), ZO_WorldMap:GetTop()
    local width, height = ZO_WorldMap:GetDimensions()
    HF.MiniMap.savedWorldMapState = {
        left = left,
        top = top,
        width = width,
        height = height,
        hidden = ZO_WorldMap:IsHidden(),
        drawLayer = ZO_WorldMap:GetDrawLayer(),
        drawLevel = ZO_WorldMap:GetDrawLevel(),
    }
end

local function RestoreWorldMapState()
    local state = HF.MiniMap.savedWorldMapState
    if not state or not ZO_WorldMap then return end
    ZO_WorldMap:ClearAnchors()
    ZO_WorldMap:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, state.left or 0, state.top or 0)
    ZO_WorldMap:SetDimensions(state.width or MAP_WIDTH, state.height or MAP_HEIGHT)
    if state.drawLayer then ZO_WorldMap:SetDrawLayer(state.drawLayer) end
    if state.drawLevel then ZO_WorldMap:SetDrawLevel(state.drawLevel) end
    ZO_WorldMap:SetHidden(state.hidden)
    HF.MiniMap.savedWorldMapState = nil
end

local function ConfigureNativeWorldMap()
    if not ZO_WorldMap or not ZO_WorldMapContainer then return false end
    SaveWorldMapState()
    if HF.MiniMap.configured then return true end

    local uiWidth, uiHeight = GuiRoot:GetDimensions()
    local oldUpdateMap = ZO_WorldMap_UpdateMap
    if oldUpdateMap then ZO_WorldMap_UpdateMap = NoOp end

    if ZO_WorldMap_OnResizeStart then
        pcall(ZO_WorldMap_OnResizeStart, ZO_WorldMap)
    end

    ZO_WorldMap:ClearAnchors()
    ZO_WorldMap:SetDimensionConstraints(128, 144, uiWidth, uiHeight)
    ZO_WorldMap:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 36, 92)
    ZO_WorldMap:SetDimensions(MAP_WIDTH, MAP_HEIGHT)
    ZO_WorldMap:SetHidden(false)
    ZO_WorldMap:SetDrawLayer(DL_BACKGROUND)
    ZO_WorldMap:SetDrawLevel(0)
    if ZO_WorldMapTitle then ZO_WorldMapTitle:SetHidden(true) end
    if ZO_WorldMapButtons then ZO_WorldMapButtons:SetHidden(true) end
    if ZO_WorldMapMapFrame then
        ZO_WorldMapMapFrame:SetHidden(false)
        ZO_WorldMapMapFrame:SetAlpha(1)
    end

    if ZO_WorldMap_OnResizeStop then
        pcall(ZO_WorldMap_OnResizeStop, ZO_WorldMap)
    end
    if oldUpdateMap then ZO_WorldMap_UpdateMap = oldUpdateMap end

    if SetMapToPlayerLocation then
        pcall(SetMapToPlayerLocation)
    end
    if ZO_WorldMap_UpdateMap then
        pcall(ZO_WorldMap_UpdateMap)
    end
    HF.MiniMap.configured = true
    return true
end

local function InitUI()
    if HF.MiniMap.initialized then return true end
    if not WINDOW_MANAGER or not GuiRoot or not ZO_WorldMapContainer then return false end

    local layer = WINDOW_MANAGER:CreateControl("HF_MiniMapMarkerLayer", ZO_WorldMapContainer, CT_CONTROL)
    layer:SetAnchorFill(ZO_WorldMapContainer)
    layer:SetMouseEnabled(false)
    layer:SetDrawTier(DT_HIGH)
    layer:SetDrawLayer(DL_OVERLAY)
    layer:SetDrawLevel(10000)
    layer:SetHidden(false)
    HF.MiniMap.canvas = layer

    local player = CreateLabel("HF_MiniMapPlayer", layer, "P", "ZoFontGameSmall")
    player:SetDimensions(18, 18)
    player:SetColor(1, 1, 1, 1)
    player:SetDrawLayer(DL_OVERLAY)
    player:SetDrawLevel(10001)
    player:SetHidden(true)
    HF.MiniMap.player = player

    HF.MiniMap.initialized = true
    return true
end

local function EnsurePin(index)
    if HF.MiniMap.pins[index] then return HF.MiniMap.pins[index] end
    local pin = CreateLabel("HF_MiniMapPin" .. tostring(index), HF.MiniMap.canvas, "", "ZoFontGameSmall")
    pin:SetDimensions(18, 18)
    pin:SetDrawLayer(DL_OVERLAY)
    pin:SetDrawLevel(10000 + index)
    pin:SetHidden(true)
    HF.MiniMap.pins[index] = pin
    return pin
end

local function ProjectToMap(x, z, bounds)
    if not bounds then return nil, nil end
    local width = bounds.maxX - bounds.minX
    local depth = bounds.maxZ - bounds.minZ
    if width <= 0 or depth <= 0 then return nil, nil end

    local nx = (x - bounds.minX) / width
    local nz = (z - bounds.minZ) / depth
    if nx < 0 then nx = 0 elseif nx > 1 then nx = 1 end
    if nz < 0 then nz = 0 elseif nz > 1 then nz = 1 end

    local width, height = MAP_WIDTH, MAP_HEIGHT
    if HF.MiniMap.canvas then
        width, height = HF.MiniMap.canvas:GetDimensions()
        if width <= 0 then width = MAP_WIDTH end
        if height <= 0 then height = MAP_HEIGHT end
    end

    return nx * width, nz * height
end

function HF.MiniMap.ScanCurrentHouse()
    if not GetCurrentZoneHouseId or GetCurrentZoneHouseId() == 0 then
        return false, "You must be inside a house."
    end

    local items = {}
    local furnitureId = nil
    while true do
        furnitureId = GetNextPlacedHousingFurnitureId(furnitureId)
        if not furnitureId then break end
        local ok, entry = pcall(CaptureFurnitureEntry, furnitureId)
        if ok and entry then table.insert(items, entry) end
    end

    HF.MiniMap.allItems = items
    HF.MiniMap.items = FilterEssentials(items, HF.MiniMap.filter)
    HF.MiniMap.bounds = ComputeBounds(items)
    HF.MiniMap.sourceName = HF.GetCurrentHouseName()
    return true
end

function HF.MiniMap.StartScanCurrentHouse()
    if not GetCurrentZoneHouseId or GetCurrentZoneHouseId() == 0 then
        return false, "You must be inside a house."
    end

    EVENT_MANAGER:UnregisterForUpdate(SCAN_UPDATE_NAME)
    HF.MiniMap.scanState = {
        furnitureId = nil,
        items = {},
        checked = 0,
    }

    EVENT_MANAGER:RegisterForUpdate(SCAN_UPDATE_NAME, 25, function()
        local state = HF.MiniMap.scanState
        if not state then
            EVENT_MANAGER:UnregisterForUpdate(SCAN_UPDATE_NAME)
            return
        end

        for _ = 1, SCAN_BATCH_SIZE do
            state.furnitureId = GetNextPlacedHousingFurnitureId(state.furnitureId)
            if not state.furnitureId then
                EVENT_MANAGER:UnregisterForUpdate(SCAN_UPDATE_NAME)
                HF.MiniMap.scanState = nil
                HF.MiniMap.allItems = state.items
                HF.MiniMap.items = FilterEssentials(state.items, HF.MiniMap.filter)
                HF.MiniMap.bounds = ComputeBounds(state.items)
                HF.MiniMap.sourceName = HF.GetCurrentHouseName()
                HF.MiniMap.Update()
                HF.Chat(string.format("Mini map ready: %d essential markers.", #HF.MiniMap.items))
                return
            end

            local ok, entry = pcall(CaptureFurnitureEntry, state.furnitureId)
            if ok and entry then table.insert(state.items, entry) end
            state.checked = state.checked + 1
        end
    end)

    return true
end

function HF.MiniMap.LoadSelectedLayout()
    local items, name = GetSelectedLayoutItems()
    if not items then return false, "No selected layout has items." end
    HF.MiniMap.allItems = items
    HF.MiniMap.items = FilterEssentials(items, HF.MiniMap.filter)
    HF.MiniMap.bounds = ComputeBounds(items)
    HF.MiniMap.sourceName = name
    return true
end

function HF.MiniMap.RefreshData()
    local ok, reason = HF.MiniMap.ScanCurrentHouse()
    if ok then return true end
    ok, reason = HF.MiniMap.LoadSelectedLayout()
    if ok then return true end
    return false, reason
end

function HF.MiniMap.Update()
    if not HF.MiniMap.enabled then return end
    if not InitUI() then return end
    if ZO_WorldMap_PanToPlayer then pcall(ZO_WorldMap_PanToPlayer) end

    local maxPins = HF.savedVars and HF.savedVars.settings and HF.savedVars.settings.miniMapMaxPins or 90
    local shown = 0
    for i, item in ipairs(HF.MiniMap.items or {}) do
        if i > maxPins then break end
        local pin = EnsurePin(i)
        local x, y = ProjectToMap(tonumber(item.worldX) or 0, tonumber(item.worldZ) or 0, HF.MiniMap.bounds)
        local category = item.hfCategory or ClassifyItem(item) or "utilities"
        local color = CATEGORY_COLORS[category] or CATEGORY_COLORS.utilities
        pin:ClearAnchors()
        pin:SetAnchor(CENTER, HF.MiniMap.canvas, TOPLEFT, x or 0, y or 0)
        pin:SetText(CATEGORY_LETTERS[category] or "?")
        pin:SetColor(color[1], color[2], color[3], color[4])
        pin:SetHidden(false)
        shown = shown + 1
    end

    for i = shown + 1, #HF.MiniMap.pins do
        HF.MiniMap.pins[i]:SetHidden(true)
    end

    local player = HF.MiniMap.player
    local _, playerX, _, playerZ = GetUnitRawWorldPosition("player")
    if player and playerX and playerZ and HF.MiniMap.bounds then
        local x, y = ProjectToMap(playerX, playerZ, HF.MiniMap.bounds)
        player:ClearAnchors()
        player:SetAnchor(CENTER, HF.MiniMap.canvas, TOPLEFT, x or 0, y or 0)
        player:SetHidden(false)
    elseif player then
        player:SetHidden(true)
    end

    if HF.MiniMap.canvas then HF.MiniMap.canvas:SetHidden(false) end
end

function HF.MiniMap.Enable()
    if not InitUI() then
        HF.Chat("Mini map UI could not initialize.")
        return
    end
    HF.MiniMap.enabled = true
    ConfigureNativeWorldMap()
    if HF.MiniMap.canvas then HF.MiniMap.canvas:SetHidden(false) end

    local ok, reason = HF.MiniMap.StartScanCurrentHouse()
    if not ok then
        ok, reason = HF.MiniMap.LoadSelectedLayout()
        if not ok then
            HF.Chat(reason or "Could not build mini map.")
            HF.MiniMap.Disable()
            return
        end
    else
        HF.MiniMap.allItems = {}
        HF.MiniMap.items = {}
        HF.MiniMap.bounds = nil
    end

    EVENT_MANAGER:RegisterForUpdate(UPDATE_NAME, 500, HF.MiniMap.Update)
    HF.MiniMap.Update()
    HF.Chat("Mini map enabled. Scanning essentials in batches.")
end

function HF.MiniMap.Disable()
    HF.MiniMap.enabled = false
    HF.MiniMap.configured = false
    EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME)
    EVENT_MANAGER:UnregisterForUpdate(SCAN_UPDATE_NAME)
    HF.MiniMap.scanState = nil
    if HF.MiniMap.canvas then HF.MiniMap.canvas:SetHidden(true) end
    RestoreWorldMapState()
    if ZO_WorldMapButtons then ZO_WorldMapButtons:SetHidden(false) end
    if ZO_WorldMapTitle then ZO_WorldMapTitle:SetHidden(false) end
    HF.Chat("Mini map hidden.")
end

function HF.MiniMap.SetFilter(filter)
    filter = Lower(filter)
    if filter == "" then filter = "essentials" end
    local valid = {
        essentials = true,
        all = true,
        crafting = true,
        set = true,
        mundus = true,
        services = true,
        storage = true,
        dummies = true,
        utilities = true,
    }
    if not valid[filter] then
        HF.Chat("Mini map filter: essentials, crafting, set, mundus, services, storage, dummies, utilities.")
        return
    end
    HF.MiniMap.filter = filter
    if HF.savedVars and HF.savedVars.settings then HF.savedVars.settings.miniMapFilter = filter end
    HF.MiniMap.items = FilterEssentials(HF.MiniMap.allItems, filter)
    HF.MiniMap.Update()
    HF.Chat("Mini map filter set to " .. filter .. ".")
    if HF.RefreshUI then HF.RefreshUI() end
    if KEYBIND_STRIP and HF.hiddenListScreen then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(HF.hiddenListScreen.keybindStripDescriptor)
    end
end

function HF.MiniMap.CycleFilter()
    local current = HF.MiniMap.filter or (HF.savedVars and HF.savedVars.settings and HF.savedVars.settings.miniMapFilter) or "essentials"
    local nextIndex = 1
    for i, filter in ipairs(FILTER_ORDER) do
        if filter == current then
            nextIndex = i + 1
            break
        end
    end
    if nextIndex > #FILTER_ORDER then nextIndex = 1 end
    HF.MiniMap.SetFilter(FILTER_ORDER[nextIndex])
end

function HF.MiniMap.Toggle()
    if HF.MiniMap.enabled then
        HF.MiniMap.Disable()
    else
        HF.MiniMap.Enable()
    end
    if HF.RefreshUI then HF.RefreshUI() end
    if KEYBIND_STRIP and HF.hiddenListScreen then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(HF.hiddenListScreen.keybindStripDescriptor)
    end
end

function HF.MiniMap.HandleCommand(args)
    local cmd = args and args:lower():match("^%s*(%S*)") or ""
    local rest = args and args:match("^%s*%S+%s*(.-)%s*$") or ""
    if cmd == "off" or cmd == "hide" then
        HF.MiniMap.Disable()
    elseif cmd == "on" or cmd == "show" or cmd == "" then
        if cmd == "" then
            HF.MiniMap.Toggle()
        else
            HF.MiniMap.Enable()
        end
    elseif cmd == "refresh" or cmd == "scan" then
        HF.MiniMap.RefreshData()
        if HF.MiniMap.enabled then HF.MiniMap.Update() end
        HF.Chat(string.format("Mini map refreshed: %d essential markers.", #HF.MiniMap.items))
    elseif cmd == "filter" then
        HF.MiniMap.SetFilter(rest)
    else
        HF.MiniMap.SetFilter(cmd)
    end
end
