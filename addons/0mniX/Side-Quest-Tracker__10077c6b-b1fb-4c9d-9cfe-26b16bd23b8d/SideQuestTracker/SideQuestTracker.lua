SideQuestTracker = SideQuestTracker or {}
local SQT = SideQuestTracker

SQT.name = "SideQuestTracker"
SQT.version = "0.8.0"

local LIB_NAME = "LibSideQuestPins"
local PIN_TYPE_STRING = "SQT_SIDEQUEST"
local TEX_QUEST = "EsoUI/Art/FloatingMarkers/quest_available_icon.dds"
local MAP_WATCH_UPDATE = "SQT_MapWatch"

SQT.LMP = nil
SQT.lastSourceKey = nil
SQT.lastResolved = nil
SQT.worldMapShown = false

local function normalizeZoneName(name)
    if not name or name == "" then return nil end
    name = zo_strlower(name)
    name = name:gsub("%s+", "")
    name = name:gsub("'", "")
    name = name:gsub("%-", "")
    return name
end

local function getTileZoneKey()
    if GetMapTileTexture then
        local ok, tex = pcall(GetMapTileTexture)
        if ok and type(tex) == "string" and tex ~= "" then
            tex = tex:lower()
            local key = tex:match("maps/([^/]+)/")
            if key and key ~= "" then
                return key
            end
        end
    end
    return nil
end

local function getCurrentMapId()
    if GetCurrentMapId then
        local ok, id = pcall(GetCurrentMapId)
        if ok and type(id) == "number" and id > 0 then return id end
    end
    if GetMapId then
        local ok, id = pcall(GetMapId)
        if ok and type(id) == "number" and id > 0 then return id end
    end
    return nil
end

local function gatherMapIdPins(lib, mapId)
    if not mapId or not lib or not lib.IterMapId then return nil end
    local out = {}
    for questId, x, y, si, st in lib:IterMapId(mapId) do
        out[#out + 1] = { questId = questId, x = x, y = y, si = si or 1, st = st or 1 }
    end
    if #out > 0 then return out end
    return nil
end

local function gatherZonePins(lib, zoneKey)
    if not zoneKey or zoneKey == "" or not lib or not lib.IterZone then return nil end
    local out = {}
    for questId, x, y, si, st in lib:IterZone(zoneKey) do
        out[#out + 1] = { questId = questId, x = x, y = y, si = si or 1, st = st or 1 }
    end
    if #out > 0 then return out end
    return nil
end

local function buildDisplayName(lib, questId, si, st)
    local name = (lib and lib.GetQuestName and lib:GetQuestName(questId)) or ("Quest " .. tostring(questId))
    if st and st > 1 then
        name = string.format("%s (%d/%d)", name, si or 1, st)
    end
    return name
end

local function resolveSource()
    local lib = _G[LIB_NAME]
    if not lib or not lib.data then return nil end

    if lib.BuildMapIdIndex and not lib._mapIdIndexBuilt then
        lib:BuildMapIdIndex()
    end

    local mapId = getCurrentMapId()
    local tileZoneKey = getTileZoneKey()
    local mapNameKey = normalizeZoneName(GetMapName and GetMapName() or nil)
    local playerZoneKey = normalizeZoneName(GetUnitZone and GetUnitZone("player") or nil)

    local pins = gatherMapIdPins(lib, mapId)
    if pins then
        return {
            key = "map:" .. tostring(mapId),
            mode = "mapId",
            mapId = mapId,
            zoneKey = tileZoneKey,
            pins = pins,
            lib = lib,
        }
    end

    local candidates = {
        tileZoneKey,
        playerZoneKey,
        mapNameKey,
    }

    local seen = {}
    for i = 1, #candidates do
        local key = candidates[i]
        if key and not seen[key] then
            seen[key] = true
            pins = gatherZonePins(lib, key)
            if pins then
                return {
                    key = "zone:" .. tostring(key),
                    mode = "zone",
                    mapId = mapId,
                    zoneKey = key,
                    pins = pins,
                    lib = lib,
                }
            end
        end
    end

    return {
        key = "none:" .. tostring(mapId or "nil") .. ":" .. tostring(tileZoneKey or playerZoneKey or mapNameKey or "nil"),
        mode = "none",
        mapId = mapId,
        zoneKey = tileZoneKey or playerZoneKey or mapNameKey,
        pins = {},
        lib = lib,
    }
end

local function addPins()
    local LMP = SQT.LMP
    if not LMP then return end

    local resolved = resolveSource()
    SQT.lastResolved = resolved
    if not resolved or not resolved.pins or #resolved.pins == 0 then return end

    for i = 1, #resolved.pins do
        local e = resolved.pins[i]
        if e.questId and e.x and e.y then
            LMP:CreatePin(PIN_TYPE_STRING, {
                questId = e.questId,
                displayName = buildDisplayName(resolved.lib, e.questId, e.si, e.st),
                x = e.x,
                y = e.y,
                startIndex = e.si,
                startTotal = e.st,
            }, e.x, e.y)
        end
    end

    SQT.lastSourceKey = resolved.key
end

local function pinTooltipCreator(pin)
    local _, tag = pin:GetPinTypeAndTag()
    InformationTooltip:SetOwner(pin:GetControl(), TOPLEFT, 0, 0)
    InformationTooltip:ClearLines()
    if tag and tag.displayName then
        InformationTooltip:AddLine(tag.displayName)
    else
        InformationTooltip:AddLine("Side Quest")
    end
    InformationTooltip:SetHidden(false)
end

local function refreshIfChanged()
    if not SQT.worldMapShown then return end
    local LMP = SQT.LMP
    if not LMP or not LMP.RefreshPins then return end

    local resolved = resolveSource()
    local newKey = resolved and resolved.key or nil
    if newKey ~= SQT.lastSourceKey then
        SQT.lastResolved = resolved
        LMP:RefreshPins(PIN_TYPE_STRING)
    end
end

local function setMapShown(shown)
    SQT.worldMapShown = shown and true or false
    EVENT_MANAGER:UnregisterForUpdate(MAP_WATCH_UPDATE)
    if shown then
        EVENT_MANAGER:RegisterForUpdate(MAP_WATCH_UPDATE, 250, refreshIfChanged)
        refreshIfChanged()
    end
end

local function hookMapScenes()
    if SQT.sceneHooked or not SCENE_MANAGER then return end

    local hooked = {}
    local function hookScene(scene)
        if not scene or hooked[scene] then return end
        hooked[scene] = true
        scene:RegisterCallback("StateChange", function(_, newState)
            if newState == SCENE_SHOWING or newState == SCENE_SHOWN then
                setMapShown(true)
            elseif newState == SCENE_HIDING or newState == SCENE_HIDDEN then
                setMapShown(false)
            end
        end)
    end

    hookScene(_G["WORLD_MAP_SCENE"])
    hookScene(_G["GAMEPAD_WORLD_MAP_SCENE"])

    local names = {"worldMap", "worldMapGamepad", "gamepad_worldMap", "worldMap_Gamepad", "gamepad_world_map"}
    for _, name in ipairs(names) do
        hookScene(SCENE_MANAGER:GetScene(name))
    end

    SQT.sceneHooked = true
end

function SQT:Initialize()
    local LMP = nil
    if LibStub then
        LMP = LibStub("LibMapPins-1.0")
    end
    if not LMP then
        LMP = _G["LibMapPins"]
    end
    if not LMP then return end
    self.LMP = LMP

    local layout = {
        level = 110,
        texture = TEX_QUEST,
        size = 28,
        gamepadCategory = "Side Quests",
        gamepadCategoryId = 1100,
        categoryId = 1100,
    }

    LMP:AddPinType(PIN_TYPE_STRING, addPins, nil, layout, pinTooltipCreator)
    if LMP.SetEnabled then
        LMP:SetEnabled(PIN_TYPE_STRING, true)
    end

    hookMapScenes()

    if LMP.RefreshPins then
        LMP:RefreshPins(PIN_TYPE_STRING)
    end
end

local function OnLoaded(event, addonName)
    if addonName ~= SQT.name then return end
    EVENT_MANAGER:UnregisterForEvent(SQT.name, EVENT_ADD_ON_LOADED)
    SQT:Initialize()
end

EVENT_MANAGER:RegisterForEvent(SQT.name, EVENT_ADD_ON_LOADED, OnLoaded)
