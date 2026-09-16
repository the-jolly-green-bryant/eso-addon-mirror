NecroCat = NecroCat or {}
NecroCat.Minimap = {}

local minimap = NecroCat.Minimap

local defaultSettings = {
    hideZoneAnnounce = true,
    enabled = true,
    locked = false,
    rotate = false,
    previewInMenu = false,
    width = 250,
    height = 250,
    point = TOPRIGHT,
    relativePoint = TOPRIGHT,
    offsetX = -30,
    offsetY = 80,
    pinSize = 20,
    playerPinSize = 32,
    opacity = 1.0,
    zoom = {
        zone = 2.0,
        subzone = 4.5,
        dungeon = 3.5,
        house = 3.0,
        cyrodiil = 3.5,
        cyrodiil_subzone = 5.0,
        imperial_city = 5.0,
        imperial_sewers = 4.0,
        battleground = 3.5,
    },
}

local g_sceneFragment = nil
local g_TextureTiles = {}
local g_tileCountX = 0
local g_tileCountY = 0
local g_containerSize = 1000

local g_lastX = -1
local g_lastY = -1
local g_lastHeading = -1
local g_headingCos = 1
local g_headingSin = 0
local g_lastRefreshTime = 0
local g_currentMapTexture = ""

local function ReleaseAllTiles()
    for _, tile in ipairs(g_TextureTiles) do
        tile:SetHidden(true)
    end
end

local function GetTile(i)
    local tile = g_TextureTiles[i]
    if not tile then
        tile = CreateControlFromVirtual("NecroCat_MapContainer_Tile", NecroCat_MapContainer, "NecroCat_MapTile", i)
        g_TextureTiles[i] = tile
    end
    tile:SetHidden(false)
    return tile
end

function minimap.GetCurrentZoneType()
    if GetCurrentZoneHouseId() ~= 0 then return "house" end
    
    -- Проверка Полей Сражений (БГ)
    local isBG = (IsPlayerInBattleground and IsPlayerInBattleground()) 
        or (IsActiveWorldBattleground and IsActiveWorldBattleground()) 
        or (GetMapContentType() == MAP_CONTENT_BATTLEGROUND)
    if isBG then return "battleground" end

    -- Проверка Имперского Города: Районы (ID 584) и Канализация (ID 643)
    local zoneId = GetUnitWorldPosition("player")
    if zoneId == 643 or (IsInImperialCitySewers and IsInImperialCitySewers()) then
        return "imperial_sewers"
    end
    if zoneId == 584 or (IsInImperialCity and IsInImperialCity()) then
        return "imperial_city"
    end

    if GetMapContentType() == MAP_CONTENT_DUNGEON then return "dungeon" end

    -- Проверка Сиродила
    local isAvA = (IsInAvAZone and IsInAvAZone()) or (GetMapContentType() == MAP_CONTENT_AVA)
    if isAvA then
        if GetMapType() == MAPTYPE_SUBZONE then
            return "cyrodiil_subzone"
        else
            return "cyrodiil"
        end
    end

    if GetMapType() == MAPTYPE_SUBZONE then return "subzone" end
    return "zone"
end

local function GetCurrentZoom()
    local cfg = minimap.settings or defaultSettings
    local zoneType = minimap.GetCurrentZoneType()
    if type(cfg.zoom) ~= "table" then
        cfg.zoom = { zone = 2.0, subzone = 4.5, dungeon = 3.5, house = 3.0, cyrodiil = 3.5, cyrodiil_subzone = 5.0, imperial_city = 5.0, imperial_sewers = 4.0, battleground = 3.5 }
    end
    local zoomVal = cfg.zoom[zoneType] or (defaultSettings.zoom and defaultSettings.zoom[zoneType]) or 3.0
    return zo_clamp(zoomVal, 1.0, 12.0), zoneType
end

local function GetTileAnchor(iX, iY, tileWidth, tileHeight, playerX, playerY, doesRotate)
    local offsetX, offsetY = 0, 0
    if doesRotate and playerX and playerY then
        local x = ((iX - 0.5) * tileWidth) - playerX
        local y = ((iY - 0.5) * tileHeight) - playerY
        offsetX = (g_headingCos * x) - (g_headingSin * y)
        offsetY = (g_headingSin * x) + (g_headingCos * y)
    else
        offsetX = ((iX - 0.5) * tileWidth) - (g_containerSize / 2)
        offsetY = ((iY - 0.5) * tileHeight) - (g_containerSize / 2)
    end
    return CENTER, NecroCat_MapContainer, CENTER, offsetX, offsetY
end

local function UpdateTilesOnRotate(playerX, playerY, heading)
    local tileWidth = g_containerSize / g_tileCountX
    local tileHeight = g_containerSize / g_tileCountY
    local i = 1
    
    for iY = 1, g_tileCountX do
        for iX = 1, g_tileCountY do
            local tile = GetTile(i)
            tile:SetTextureRotation(-heading, 0.5, 0.5)
            tile:ClearAnchors()
            tile:SetAnchor(GetTileAnchor(iX, iY, tileWidth, tileHeight, playerX, playerY, true))
            i = i + 1
        end
    end
end

function minimap.RefreshMap(force)
    local now = GetGameTimeMilliseconds()
    if not force and (now - g_lastRefreshTime < 80) then return end
    g_lastRefreshTime = now

    local numX, numY = GetMapNumTiles()
    if not numX or not numY or numX == 0 or numY == 0 then return end

    g_currentMapTexture = GetMapTileTexture(1) or ""

    g_tileCountX = numX
    g_tileCountY = numY

    ReleaseAllTiles()

    local cfg = minimap.settings or defaultSettings
    local winW = cfg.width or 250
    local winH = cfg.height or 250
    local baseSize = zo_max(winW, winH)

    local rotationMultiplier = cfg.rotate and 1.42 or 1.0
    local zoom, _ = GetCurrentZoom()
    g_containerSize = baseSize * zoom * rotationMultiplier

    NecroCat_MapContainer:SetDimensions(g_containerSize, g_containerSize)

    local tileWidth = g_containerSize / g_tileCountX
    local tileHeight = g_containerSize / g_tileCountY

    local i = 1
    for iY = 1, g_tileCountX do
        for iX = 1, g_tileCountY do
            local tile = GetTile(i)
            tile:SetDimensions(tileWidth, tileHeight)
            tile:ClearAnchors()
            tile:SetAnchor(GetTileAnchor(iX, iY, tileWidth, tileHeight))
            tile:SetTexture(GetMapTileTexture(i))
            tile:SetTextureRotation(0)
            i = i + 1
        end
    end

    minimap.UpdatePlayerPosition(true)

    if minimap.Pins and minimap.Pins.RefreshAll then
        minimap.Pins.RefreshAll()
    end
end

function minimap.UpdatePlayerPosition(forceUpdate)
    if WORLD_MAP_SCENE and WORLD_MAP_SCENE:IsShowing() then return end

    local normX, normY = GetMapPlayerPosition("player")
    if not normX or not normY or (normX == 0 and normY == 0) then return end

    local heading = GetPlayerCameraHeading() or 0
    local cfg = minimap.settings or defaultSettings
    local doesRotate = cfg.rotate

    if not forceUpdate and normX == g_lastX and normY == g_lastY and heading == g_lastHeading then
        return
    end

    g_lastX = normX
    g_lastY = normY
    g_lastHeading = heading

    local playerX = g_containerSize * normX
    local playerY = g_containerSize * normY

    if doesRotate then
        g_headingCos = math.cos(heading)
        g_headingSin = math.sin(heading)

        NecroCat_MapContainer:ClearAnchors()
        NecroCat_MapContainer:SetAnchor(CENTER, NecroCat_Minimap_MainWindow_Map_Scroll, CENTER, 0, 0)

        UpdateTilesOnRotate(playerX, playerY, heading)

        if NecroCat_Minimap_MainWindow_Map_PlayerPin then
            NecroCat_Minimap_MainWindow_Map_PlayerPin:ClearAnchors()
            NecroCat_Minimap_MainWindow_Map_PlayerPin:SetAnchor(CENTER, NecroCat_Minimap_MainWindow_Map_Scroll, CENTER, 0, 0)
            NecroCat_Minimap_MainWindow_Map_PlayerPin:SetTextureRotation(0)
        end
        
        if minimap.Pins and minimap.Pins.UpdateRotation then
            minimap.Pins.UpdateRotation(playerX, playerY, g_headingCos, g_headingSin, g_containerSize)
        end
    else
        local winW = cfg.width or 250
        local winH = cfg.height or 250
        local halfW = winW / 2
        local halfH = winH / 2

        local offsetX = zo_clamp(playerX, halfW, g_containerSize - halfW)
        local offsetY = zo_clamp(playerY, halfH, g_containerSize - halfH)

        NecroCat_MapContainer:ClearAnchors()
        NecroCat_MapContainer:SetAnchor(TOPLEFT, nil, CENTER, -offsetX, -offsetY)

        if NecroCat_Minimap_MainWindow_Map_PlayerPin then
            local pinScreenX = playerX - offsetX
            local pinScreenY = playerY - offsetY
            NecroCat_Minimap_MainWindow_Map_PlayerPin:ClearAnchors()
            NecroCat_Minimap_MainWindow_Map_PlayerPin:SetAnchor(CENTER, NecroCat_Minimap_MainWindow_Map_Scroll, CENTER, pinScreenX, pinScreenY)
            NecroCat_Minimap_MainWindow_Map_PlayerPin:SetTextureRotation(heading, 0.5, 0.5)
        end
    end

    -- 1. Чистое название локации сверху
    local locName = GetUnitZone("player")
    if not locName or locName == "" then
        locName = GetZoneNameById(GetCurrentZoneId())
    end
    if not locName or locName == "" then
        locName = GetPlayerLocationName()
    end
    if not locName or locName == "" then
        locName = GetMapName and GetMapName() or ""
    end
    NecroCat_Location_Name:SetText(locName and zo_strformat("<<C:1>>", locName) or "")

    -- 3. Отдельный индикатор Ветеранки в правом нижнем углу
    local isDungeon = (GetMapContentType() == MAP_CONTENT_DUNGEON) 
        or (IsPlayerInGroupDungeon and IsPlayerInGroupDungeon()) 
        or (IsPlayerInRaid and IsPlayerInRaid())

    if isDungeon and GetCurrentZoneDungeonDifficulty and GetCurrentZoneDungeonDifficulty() == DUNGEON_DIFFICULTY_VETERAN then
        NecroCat_Difficulty:SetText("|cff5555[ВЕТ]|r")
    else
        NecroCat_Difficulty:SetText("")
    end
end

local function OnUpdate()
    if NecroCat_Minimap_MainWindow:IsHidden() then 
        return 
    end

    local mapResult = SetMapToPlayerLocation()
    local currentTile = GetMapTileTexture(1)

    if mapResult == SET_MAP_RESULT_MAP_CHANGED or (currentTile and currentTile ~= "" and currentTile ~= g_currentMapTexture) then
        minimap.RefreshMap(true)
        CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
    else
        minimap.UpdatePlayerPosition(false)
    end
end

local function OnMouseDown(_eventCode, _button)
    if _button == MOUSE_BUTTON_INDEX_LEFT and not (minimap.settings and minimap.settings.locked) then
        NecroCat_Minimap_MainWindow:SetMovable(true)
        NecroCat_Minimap_MainWindow:StartMoving()
    end
end

local function OnMouseUp(_eventCode, _button)
    if _button == MOUSE_BUTTON_INDEX_LEFT then
        NecroCat_Minimap_MainWindow:SetMovable(false)
        if minimap.settings and not minimap.settings.locked then
            minimap.settings.left = NecroCat_Minimap_MainWindow:GetLeft()
            minimap.settings.top = NecroCat_Minimap_MainWindow:GetTop()
        end
    end
end

local function OnMouseWheel(self, delta)
    if not minimap.settings then return end
    local currentZoom, zoneType = GetCurrentZoom()
    if delta > 0 then
        currentZoom = zo_min(currentZoom + 0.4, 12.0)
    else
        currentZoom = zo_max(currentZoom - 0.4, 1.0)
    end
    minimap.settings.zoom = minimap.settings.zoom or {}
    minimap.settings.zoom[zoneType] = currentZoom
    minimap.RefreshMap()
end

function minimap.ApplyLayout()
    local cfg = minimap.settings or defaultSettings
    NecroCat_Minimap_MainWindow:ClearAnchors()
    
    if cfg.left and cfg.top then
        NecroCat_Minimap_MainWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, cfg.left, cfg.top)
    else
        NecroCat_Minimap_MainWindow:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -30, 80)
    end

    -- Гарантированно выводим всплывающий лут, золото и опыт ПОВЕРХ миникарты
    if ZO_LootHistoryControl_Keyboard then
        ZO_LootHistoryControl_Keyboard:SetDrawTier(DT_MEDIUM)
        ZO_LootHistoryControl_Keyboard:SetDrawLayer(DL_OVERLAY)
    end
    if ZO_LootHistoryControl_Gamepad then
        ZO_LootHistoryControl_Gamepad:SetDrawTier(DT_MEDIUM)
        ZO_LootHistoryControl_Gamepad:SetDrawLayer(DL_OVERLAY)
    end
    
    local width = cfg.width or 250
    local height = cfg.height or 250
    NecroCat_Minimap_MainWindow:SetDimensions(width, height)
    NecroCat_Minimap_MainWindow_Map:SetDimensions(width, height)
    
    local opacity = cfg.opacity or 1.0
    NecroCat_Minimap_MainWindow:SetAlpha(opacity)

    local arrowSize = cfg.playerPinSize or 32
    if NecroCat_Minimap_MainWindow_Map_PlayerPin then
        NecroCat_Minimap_MainWindow_Map_PlayerPin:SetDimensions(arrowSize, arrowSize)
    end
end

local function SetupSceneFragments()
    if not g_sceneFragment then
        g_sceneFragment = ZO_SimpleSceneFragment:New(NecroCat_Minimap_MainWindow)
    end

    local gameMenuScene = SCENE_MANAGER:GetScene("gameMenuInGame")

    if minimap.settings and minimap.settings.enabled then
        HUD_SCENE:AddFragment(g_sceneFragment)
        HUD_UI_SCENE:AddFragment(g_sceneFragment)
        SIEGE_BAR_SCENE:AddFragment(g_sceneFragment)
        if SIEGE_BAR_UI_SCENE then
            SIEGE_BAR_UI_SCENE:AddFragment(g_sceneFragment)
        end

        -- Отображаем карту в меню Esc ТОЛЬКО если включен переключатель предпросмотра
        if gameMenuScene then
            if minimap.settings.previewInMenu then
                gameMenuScene:AddFragment(g_sceneFragment)
            else
                gameMenuScene:RemoveFragment(g_sceneFragment)
            end
        end
    else
        HUD_SCENE:RemoveFragment(g_sceneFragment)
        HUD_UI_SCENE:RemoveFragment(g_sceneFragment)
        SIEGE_BAR_SCENE:RemoveFragment(g_sceneFragment)
        if SIEGE_BAR_UI_SCENE then
            SIEGE_BAR_UI_SCENE:RemoveFragment(g_sceneFragment)
        end
        if gameMenuScene then
            gameMenuScene:RemoveFragment(g_sceneFragment)
        end
        NecroCat_Minimap_MainWindow:SetHidden(true)
    end
end

function minimap.StartEngine()
    if not minimap.settings or not minimap.settings.enabled then return end
    
    SetupSceneFragments()
    if g_sceneFragment then
        g_sceneFragment:Refresh()
    end
    
    minimap.RefreshMap()
    EVENT_MANAGER:RegisterForUpdate("NecroCat_Minimap_Update", 20, OnUpdate)
end

local function OnAddOnLoaded(eventCode, addOnName)
    if addOnName ~= "NecroCat" then return end
    EVENT_MANAGER:UnregisterForEvent("NecroCat_Minimap_Loaded", EVENT_ADD_ON_LOADED)

    local sv = NecroCat.savedVars or (NC and NC.savedVars)
    if sv then
        sv.minimap = sv.minimap or {}
        for k, v in pairs(defaultSettings) do
            if sv.minimap[k] == nil then
                sv.minimap[k] = v
            end
        end
        minimap.settings = sv.minimap
    else
        minimap.settings = defaultSettings
    end

    NecroCat_Minimap_MainWindow:SetHandler("OnMouseDown", OnMouseDown)
    NecroCat_Minimap_MainWindow:SetHandler("OnMouseUp", OnMouseUp)
    NecroCat_Minimap_MainWindow:SetHandler("OnMouseWheel", OnMouseWheel)

    minimap.ApplyLayout()
    SetupSceneFragments()

    if minimap.settings.enabled then
        minimap.StartEngine()
    else
        NecroCat_Minimap_MainWindow:SetHidden(true)
    end
end

EVENT_MANAGER:RegisterForEvent("NecroCat_Minimap_Loaded", EVENT_ADD_ON_LOADED, OnAddOnLoaded)

CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", function(wasNavigateIn)
    if minimap.settings and minimap.settings.enabled then
        if wasNavigateIn == nil then
            minimap.RefreshMap(true)						
        end				
    end
end)

if WORLD_MAP_SCENE then
    WORLD_MAP_SCENE:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_HIDDEN and minimap.settings and minimap.settings.enabled then
            zo_callLater(function()
                SetMapToPlayerLocation()
                g_lastRefreshTime = 0
                minimap.ApplyLayout()
                minimap.RefreshMap()
            end, 100)
        end
    end)
end

if GAMEPAD_WORLD_MAP_SCENE then
    GAMEPAD_WORLD_MAP_SCENE:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_HIDDEN and minimap.settings and minimap.settings.enabled then
            zo_callLater(function()
                SetMapToPlayerLocation()
                minimap.RefreshMap()
            end, 80)
        end
    end)
end

EVENT_MANAGER:RegisterForEvent("NecroCat_Minimap_Activated", EVENT_PLAYER_ACTIVATED, function()
    if WORLD_MAP_QUEST_BREADCRUMBS and WORLD_MAP_QUEST_BREADCRUMBS.RefreshAllQuests then
        WORLD_MAP_QUEST_BREADCRUMBS:RefreshAllQuests()
    end
    if minimap.settings and minimap.settings.enabled then
        minimap.RefreshMap()
    end
end)

EVENT_MANAGER:RegisterForEvent("NecroCat_Minimap_ZoneChanged", EVENT_ZONE_CHANGED, function()
    if WORLD_MAP_QUEST_BREADCRUMBS and WORLD_MAP_QUEST_BREADCRUMBS.RefreshAllQuests then
        WORLD_MAP_QUEST_BREADCRUMBS:RefreshAllQuests()
    end
    if minimap.settings and minimap.settings.enabled then
        minimap.RefreshMap()
    end
end)

-- =========================================================================
-- МЕНЮ НАСТРОЕК ДЛЯ LibAddonMenu (встраивается в меню NecroCat)
-- =========================================================================
function minimap.GetMenuOptions()
    return {
        type = "submenu",
        name = "|c66f2ffМиникарта|r",
        tooltip = "Настройки встроенной миникарты",
        controls = {
            {
                type = "checkbox",
                name = "Включить миникарту",
                tooltip = "Показывать окно миникарты на экране",
                getFunc = function() return minimap.settings and minimap.settings.enabled end,
                setFunc = function(val)
                    if minimap.settings then
                        minimap.settings.enabled = val
                        SetupSceneFragments()
                        if val then
                            minimap.StartEngine()
                        else
                            EVENT_MANAGER:UnregisterForUpdate("NecroCat_Minimap_Update")
                            NecroCat_Minimap_MainWindow:SetHidden(true)
                        end
                    end
                end,
                default = defaultSettings.enabled,
            },
            {
                type = "checkbox",
                name = "Заблокировать окно от перемещения",
                tooltip = "Запрещает случайное перетаскивание карты мышкой во время игры",
                getFunc = function() return minimap.settings and minimap.settings.locked end,
                setFunc = function(val)
                    if minimap.settings then
                        minimap.settings.locked = val
                    end
                end,
                default = defaultSettings.locked,
                disabled = function() return not (minimap.settings and minimap.settings.enabled) end,
            },
            {
                type = "checkbox",
                name = "Режим предпросмотра (в меню)",
                tooltip = "Временно показывает миникарту прямо в окне настроек, пока вы калибруете ползунки ширины, высоты и прозрачности",
                getFunc = function() return minimap.settings and minimap.settings.previewInMenu end,
                setFunc = function(val)
                    if minimap.settings then
                        minimap.settings.previewInMenu = val
                        SetupSceneFragments()
                        if val then
                            minimap.ApplyLayout()
                            minimap.RefreshMap()
                        end
                    end
                end,
                default = false,
                disabled = function() return not (minimap.settings and minimap.settings.enabled) end,
            },
            {
                type = "checkbox",
                name = "Вращать карту (Режим компаса)",
                tooltip = "Стрелочка всегда смотрит вперед, а карта плавно вращается вокруг игрока",
                getFunc = function() return minimap.settings and minimap.settings.rotate end,
                setFunc = function(val)
                    if minimap.settings then
                        minimap.settings.rotate = val
                        minimap.RefreshMap()
                    end
                end,
                default = defaultSettings.rotate,
                disabled = function() return not (minimap.settings and minimap.settings.enabled) end,
            },
            {
                type = "checkbox",
                name = "Скрывать всплывающие названия районов",
                tooltip = "Убирает огромные стандартные надписи названий локаций и районов посреди экрана",
                getFunc = function() return minimap.settings and minimap.settings.hideZoneAnnounce end,
                setFunc = function(val)
                    if minimap.settings then minimap.settings.hideZoneAnnounce = val end
                end,
                default = true,
                disabled = function() return not (minimap.settings and minimap.settings.enabled) end,
            },
			{
                type = "slider",
                name = "Размер стрелочки игрока",
                min = 16,
                max = 48,
                step = 2,
                getFunc = function() return (minimap.settings and minimap.settings.playerPinSize) or 32 end,
                setFunc = function(val)
                    if minimap.settings then
                        minimap.settings.playerPinSize = val
                        if NecroCat_Minimap_MainWindow_Map_PlayerPin then
                            NecroCat_Minimap_MainWindow_Map_PlayerPin:SetDimensions(val, val)
                        end
                    end
                end,
                default = 32,
                disabled = function() return not (minimap.settings and minimap.settings.enabled) end,
            },
            {
                type = "slider",
                name = "Размер значков на карте",
                min = 14,
                max = 36,
                step = 2,
                getFunc = function() return (minimap.settings and minimap.settings.pinSize) or 20 end,
                setFunc = function(val)
                    if minimap.settings then
                        minimap.settings.pinSize = val
                        minimap.RefreshMap()
                    end
                end,
                default = 20,
                disabled = function() return not (minimap.settings and minimap.settings.enabled) end,
            },
            {
                type = "slider",
                name = "Ширина окна",
                min = 150,
                max = 500,
                step = 10,
                getFunc = function() return (minimap.settings and minimap.settings.width) or 250 end,
                setFunc = function(val)
                    if minimap.settings then
                        minimap.settings.width = val
                        minimap.ApplyLayout()
                        minimap.RefreshMap()
                    end
                end,
                default = 250,
                disabled = function() return not (minimap.settings and minimap.settings.enabled) end,
            },
            {
                type = "slider",
                name = "Высота окна",
                min = 150,
                max = 500,
                step = 10,
                getFunc = function() return (minimap.settings and minimap.settings.height) or 250 end,
                setFunc = function(val)
                    if minimap.settings then
                        minimap.settings.height = val
                        minimap.ApplyLayout()
                        minimap.RefreshMap()
                    end
                end,
                default = 250,
                disabled = function() return not (minimap.settings and minimap.settings.enabled) end,
            },
            {
                type = "slider",
                name = "Прозрачность окна (%)",
                min = 20,
                max = 100,
                step = 5,
                getFunc = function() return zo_round(((minimap.settings and minimap.settings.opacity) or 1.0) * 100) end,
                setFunc = function(val)
                    if minimap.settings then
                        minimap.settings.opacity = val / 100
                        NecroCat_Minimap_MainWindow:SetAlpha(minimap.settings.opacity)
                    end
                end,
                default = 100,
                disabled = function() return not (minimap.settings and minimap.settings.enabled) end,
            },
        },
    }
end

SLASH_COMMANDS["/ncmap"] = function()
    minimap.Toggle()
end

SLASH_COMMANDS["/ncrotate"] = function()
    if not minimap.settings then return end
    minimap.settings.rotate = not minimap.settings.rotate
    minimap.RefreshMap()
    if minimap.settings.rotate then
        d("|c66f2ff[NecroCat]|r Вращение карты: |c00ff00Включено (Режим компаса)|r")
    else
        d("|c66f2ff[NecroCat]|r Вращение карты: |cff0000Выключено (Север сверху)|r")
    end
end

-- =========================================================================
-- ГЛУШИМ НАЗВАНИЯ РАЙОНОВ И ЗОН (Баннеры по центру и Алерты в углу экрана)
-- =========================================================================
local function ShouldBlockLocationAlert(message)
    if not (minimap.settings and minimap.settings.enabled and minimap.settings.hideZoneAnnounce) then
        return false
    end
    if message and type(message) == "string" and message ~= "" then
        local locName = GetPlayerLocationName()
        if locName and locName ~= "" and string.find(message, locName, 1, true) then
            return true
        end
    end
    return false
end

ZO_PreHook("ZO_Alert", function(category, soundId, message)
    if ShouldBlockLocationAlert(message) then return true end
end)

ZO_PreHook("ZO_AlertNoSuppression", function(category, soundId, message)
    if ShouldBlockLocationAlert(message) then return true end
end)

if CENTER_SCREEN_ANNOUNCE then
    local function ShouldBlockCSA(category)
        if not (minimap.settings and minimap.settings.enabled and minimap.settings.hideZoneAnnounce) then
            return false
        end
        return category == CSA_CATEGORY_ZONE_DISPLAY 
            or category == CSA_CATEGORY_SUBZONE_DISPLAY 
            or category == CSA_CATEGORY_LARGE_TEXT 
            or category == CSA_CATEGORY_MAJOR_TEXT
    end

    ZO_PreHook(CENTER_SCREEN_ANNOUNCE, "AddMessage", function(self, eventId, category, ...)
        if ShouldBlockCSA(category) then return true end
    end)

    ZO_PreHook(CENTER_SCREEN_ANNOUNCE, "AddMessageWithParams", function(self, messageParams)
        if messageParams then
            local category = messageParams.GetCategory and messageParams:GetCategory() or messageParams.category
            if ShouldBlockCSA(category) then return true end
        end
    end)
end