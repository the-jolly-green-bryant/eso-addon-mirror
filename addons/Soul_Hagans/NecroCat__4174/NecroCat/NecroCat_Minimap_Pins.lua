NecroCat = NecroCat or {}
NecroCat.Minimap = NecroCat.Minimap or {}
NecroCat.Minimap.Pins = {}

local minimap = NecroCat.Minimap
local pins = minimap.Pins

local g_pinPool = {}
local g_activePins = {}
local g_pinIndex = 0
local g_groupPins = {}
local g_campPins = {}
local g_savedForwardCamps = {}
local g_savedQuestPins = {}
local g_savedLibMapPins = {}
local g_currentPinZoneId = 0
local g_bgObjectivePins = {}
local g_activeMapPing = nil

local g_currentPinMapTile = ""
local g_isPlayerActivated = false

local function ClearOldZonePins()
    local currentZone = GetCurrentZoneId and GetCurrentZoneId() or 0
    local currentMapTile = GetMapTileTexture and GetMapTileTexture(1) or ""

    if g_currentPinZoneId ~= currentZone or (currentMapTile ~= "" and g_currentPinMapTile ~= currentMapTile) then
        g_currentPinZoneId = currentZone
        g_currentPinMapTile = currentMapTile
        g_savedQuestPins = {}
        g_savedLibMapPins = {}
        g_savedForwardCamps = {}
    end
end

-- =========================================================================
-- 1. ПУЛ ОБЪЕКТОВ
-- =========================================================================
local function AcquirePin()
    g_pinIndex = g_pinIndex + 1
    local pin = g_pinPool[g_pinIndex]
    
    if not pin then
        pin = CreateControl("NecroCat_MapPin_" .. g_pinIndex, NecroCat_MapContainer, CT_TEXTURE)
        pin:SetDimensions(20, 20)
        pin:SetDrawTier(DT_MEDIUM)
        pin:SetDrawLayer(DL_OVERLAY)
        pin:SetDrawLevel(2)
        pin:SetMouseEnabled(true)
        
        pin:SetHandler("OnMouseEnter", function(self)
            if self.pinTooltipCreator then
                InitializeTooltip(InformationTooltip, self, TOP, 0, -5)
                pcall(self.pinTooltipCreator, self)
            elseif self.pinText and self.pinText ~= "" then
                InitializeTooltip(InformationTooltip, self, TOP, 0, -5)
                SetTooltipText(InformationTooltip, self.pinText)
            end
        end)
        
        pin:SetHandler("OnMouseExit", function(self)
            ClearTooltip(InformationTooltip)
        end)
        
        table.insert(g_pinPool, pin)
    end
    
    pin:SetHidden(false)
    table.insert(g_activePins, pin)
    return pin
end

function pins.Reset()
    ClearOldZonePins()
    for _, pin in ipairs(g_activePins) do
        pin:SetHidden(true)
        pin:ClearAnchors()
        pin:SetColor(1, 1, 1, 1)
        pin.pinText = nil
        pin.pinTooltipCreator = nil
        pin.normX = nil
        pin.normY = nil
        pin.m_PinType = nil
        pin.m_PinTag = nil
        pin.isQuestPin = nil
        if pin.dome then
            pin.dome:SetHidden(true)
        end
    end
    for _, pin in pairs(g_bgObjectivePins) do
        pin:SetHidden(true)
    end
    for _, pin in pairs(g_groupPins) do
        pin:SetHidden(true)
    end
    ZO_ClearTable(g_activePins)
    ZO_ClearTable(g_savedLibMapPins)
    g_pinIndex = 0
end

-- =========================================================================
-- 2. СОЗДАНИЕ И МАСШТАБИРОВАНИЕ МЕТОК
-- =========================================================================
function pins.CreatePin(iconTexture, normX, normY, text, size, tooltipCreator, pinType, pinTag, tint)
    if not normX or not normY or normX <= 0 or normY <= 0 or normX >= 1 or normY >= 1 then return end
    
    if type(iconTexture) == "table" then
        iconTexture = iconTexture.texture or iconTexture.icon or iconTexture[1]
    end
    if not iconTexture or type(iconTexture) ~= "string" or iconTexture == "" then return end

    -- Защита от наложения: если в этой точке уже есть значок триала/святилища, не дублируем его
    for _, activePin in ipairs(g_activePins) do
        if activePin.normX and activePin.normY then
            if math.abs(activePin.normX - normX) < 0.001 and math.abs(activePin.normY - normY) < 0.001 then
                return activePin
            end
        end
    end

    local pin = AcquirePin()
    
    local userBaseSize = (minimap.settings and minimap.settings.pinSize) or 20
    local rawSize = size or 20
    local finalPinSize

    if string.find(tostring(iconTexture), "areaPin") then
        finalPinSize = rawSize
    else
        local baseSize = rawSize
        finalPinSize = zo_round(baseSize * (userBaseSize / 20))
    end
    
    pin:SetDimensions(finalPinSize, finalPinSize)
    pin:SetTexture(iconTexture)
    pin.pinText = text
    pin.pinTooltipCreator = tooltipCreator
    pin.normX = normX
    pin.normY = normY
    pin.m_PinType = pinType
    pin.m_PinTag = pinTag

    if tint then
        if type(tint) == "table" and tint.UnpackRGBA then
            pin:SetColor(tint:UnpackRGBA())
        elseif type(tint) == "table" and tint.r and tint.g and tint.b then
            pin:SetColor(tint.r, tint.g, tint.b, tint.a or 1)
        elseif type(tint) == "table" and tint[1] and tint[2] and tint[3] then
            pin:SetColor(tint[1], tint[2], tint[3], tint[4] or 1)
        else
            pin:SetColor(1, 1, 1, 1)
        end
    else
        pin:SetColor(1, 1, 1, 1)
    end

    local containerSize = NecroCat_MapContainer:GetWidth()
    local posX = normX * containerSize
    local posY = normY * containerSize

    pin:ClearAnchors()
    pin:SetAnchor(CENTER, NecroCat_MapContainer, TOPLEFT, posX, posY)
    return pin
end

function pins.UpdateRotation(playerX, playerY, cosHeading, sinHeading, containerSize)
    for _, pin in ipairs(g_activePins) do
        if pin.normX and pin.normY then
            local ix = (pin.normX * containerSize) - playerX
            local iy = (pin.normY * containerSize) - playerY
            
            local rx = (cosHeading * ix) - (sinHeading * iy)
            local ry = (sinHeading * ix) + (cosHeading * iy)
            
            pin:ClearAnchors()
            pin:SetAnchor(CENTER, NecroCat_MapContainer, CENTER, rx, ry)
        end
    end
end

-- Функция отображения боевого пинга (Shift + ЛКМ)
function pins.ShowMapPing(normX, normY)
    if not normX or not normY or normX <= 0 or normY <= 0 then return end

    if not NecroCat_Minimap_MapPingCtrl then
        local p = CreateControl("NecroCat_Minimap_MapPingCtrl", NecroCat_MapContainer, CT_TEXTURE)
        p:SetTexture("EsoUI/Art/MapPins/UI_Worldmap_pin_customDestination.dds") -- Яркий контрастный ромб
        p:SetDimensions(30, 30)
        p:SetColor(1, 0.05, 0.05, 1) -- Насыщенный ярко-красный цвет
        p:SetDrawTier(DT_HIGH)
        p:SetDrawLayer(DL_OVERLAY)
        p:SetDrawLevel(35)
        NecroCat_Minimap_MapPingCtrl = p
    end

    g_activeMapPing = {
        x = normX,
        y = normY,
        endTime = GetFrameTimeSeconds() + 6.0,
    }
    NecroCat_Minimap_MapPingCtrl:SetHidden(false)
end

-- =========================================================================
-- 3. СТАТИЧЕСКИЕ ИГРОВЫЕ МЕТКИ
-- =========================================================================

-- Дорожные святилища
function pins.RefreshWayshrines()
    if IsInAvAZone and IsInAvAZone() then return end

    local numNodes = GetNumFastTravelNodes()
    for nodeIndex = 1, numNodes do
        local known, name, normX, normY, icon, _, _, isLocatedInCurrentMap = GetFastTravelNodeInfo(nodeIndex)
        if known and isLocatedInCurrentMap and normX > 0 and normY > 0 then
            pins.CreatePin(icon, normX, normY, name, 24)
        end
    end
end

-- Городские сервисы (Банки, Станки, Конюшни)
function pins.RefreshLocations()
    if GetMapContentType() == MAP_CONTENT_DUNGEON or GetCurrentZoneHouseId() ~= 0 then return end

    local numLocations = GetNumMapLocations and GetNumMapLocations() or 0
    for i = 1, numLocations do
        if IsMapLocationVisible(i) then
            local icon, normX, normY = GetMapLocationIcon(i)
            if icon and icon ~= "" and normX > 0 and normY > 0 then
                local name = GetMapLocationTooltipHeader(i)
                pins.CreatePin(icon, normX, normY, name, 20)
            end
        end
    end
end

-- Точки интереса (POI)
function pins.RefreshPOIs()
    -- В подземельях и домах уличные боссы и пещеры не нужны
    if GetMapContentType() == MAP_CONTENT_DUNGEON or GetCurrentZoneHouseId() ~= 0 then 
        return 
    end

    local zoneIndex = GetCurrentMapZoneIndex()
    if not zoneIndex or zoneIndex > 100000 then return end

    local numPOIs = GetNumPOIs(zoneIndex)
    for i = 1, numPOIs do
        local xLoc, zLoc, poiPinType, icon, isShownInCurrentMap = GetPOIMapInfo(zoneIndex, i)
        local poiType = GetPOIType(zoneIndex, i)
        local isDuplicate = (poiType == POI_TYPE_WAYSHRINE or poiType == POI_TYPE_HOUSE)

        if (not icon or icon == "") and poiPinType and ZO_MapPin and ZO_MapPin.PIN_DATA and ZO_MapPin.PIN_DATA[poiPinType] then
            local layout = ZO_MapPin.PIN_DATA[poiPinType]
            local tex = layout.texture
            if type(tex) == "function" then
                local ok, res = pcall(tex, { m_PinType = poiPinType })
                if ok and type(res) == "string" then icon = res end
            elseif type(tex) == "string" then
                icon = tex
            end
        end

        if not isDuplicate and icon and icon ~= "" and xLoc > 0 and zLoc > 0 and xLoc < 1 and zLoc < 1 then
            local poiName = GetPOIInfo(zoneIndex, i)
            pins.CreatePin(icon, xLoc, zLoc, poiName, 22, nil, poiPinType)
        end
    end
end

-- Осколки небес
function pins.RefreshSkyshards()
    if GetCurrentZoneHouseId() ~= 0 then return end

    local lmp = LibMapPins
    local showUncollected = false
    local showCollected = false

    if lmp and lmp.IsEnabled then
        -- Проверяем все числовые фильтры MapPins по их иконкам
        for pinType, _ in pairs(lmp.filters or {}) do
            local layout = ZO_MapPin and ZO_MapPin.PIN_DATA and ZO_MapPin.PIN_DATA[pinType]
            local icon = layout and (layout.texture or layout[1])
            local iconStr = type(icon) == "string" and string.lower(icon) or ""
            local pinTypeStr = string.lower(tostring(pinType))

            if string.find(pinTypeStr, "sky") or string.find(iconStr, "skyshard") then
                if lmp:IsEnabled(pinType) then
                    if string.find(iconStr, "complete") then
                        showCollected = true
                    else
                        showUncollected = true
                    end
                end
            end
        end
    else
        -- Если аддона MapPins нет вообще — показываем по умолчанию
        showUncollected = true
    end

    -- Если фильтры выключены — мгновенно выходим и ничего не рисуем!
    if not showUncollected and not showCollected then
        return
    end

    local zoneIndex = GetCurrentMapZoneIndex()
    if not zoneIndex or zoneIndex > 100000 then return end

    local zoneId = GetZoneId(zoneIndex)
    if not zoneId or zoneId == 0 then
        zoneId = GetCurrentZoneId()
    end
    if not zoneId or zoneId == 0 or not GetNumSkyshardsInZone then return end

    local numSkyshards = GetNumSkyshardsInZone(zoneId)
    if not numSkyshards or numSkyshards == 0 then return end

    for i = 1, numSkyshards do
        local skyshardId = GetZoneSkyshardId(zoneId, i)
        if skyshardId and skyshardId > 0 then
            local normX, normY, isShownInCurrentMap = GetNormalizedPositionForSkyshardId(skyshardId)
            if normX and normY and normX > 0 and normY > 0 and normX < 1 and normY < 1 then
                local status = GetSkyshardDiscoveryStatus(skyshardId)
                local isAcquired = (status == SKYSHARD_DISCOVERY_STATUS_ACQUIRED)

                if isAcquired and showCollected then
                    pins.CreatePin("EsoUI/Art/Icons/MapKey/mapkey_skyshard_complete.dds", normX, normY, "|c00ff00Собранный небесный осколок|r", 18)
                elseif not isAcquired and showUncollected then
                    pins.CreatePin("EsoUI/Art/Icons/MapKey/mapkey_skyshard_seen.dds", normX, normY, "|c66f2ffНебесный осколок|r", 20)
                end
            end
        end
    end
end

-- Спутник
function pins.RefreshCompanion()
    if HasActiveCompanion and HasActiveCompanion() then
        local x, y, _, isInCurrentMap = GetMapPlayerPosition("companion")
        if isInCurrentMap and x > 0 and y > 0 then
            local companionName = GetCompanionName(GetActiveCompanionDefId())
            pins.CreatePin("EsoUI/Art/MapPins/UI-WorldMapCompanionPip.dds", x, y, companionName, 20)
        end
    end
end

-- Метка игрока
function pins.RefreshWaypoints()
    -- 1. Личная синяя метка назначения (F)
    local wpX, wpY = GetMapPlayerWaypoint()
    if wpX and wpY and wpX > 0 and wpY > 0 and wpX < 1 and wpY < 1 then
        local p = pins.CreatePin("EsoUI/Art/MapPins/UI_Worldmap_pin_customDestination.dds", wpX, wpY, "|c00ffffМетка назначения (F)|r", 28)
        if p then
            p:SetDrawTier(DT_HIGH)
            p:SetDrawLayer(DL_OVERLAY)
            p:SetDrawLevel(25)
        end
    end

    -- 2. Точка сбора лидера (Rally Point)
    local rallyX, rallyY = GetMapRallyPoint()
    if rallyX and rallyY and rallyX > 0 and rallyY > 0 and rallyX < 1 and rallyY < 1 then
        local p = pins.CreatePin("EsoUI/Art/MapPins/MapRallyPoint.dds", rallyX, rallyY, "|cff3333Точка сбора лидера (Rally)|r", 30)
        if p then
            p:SetDrawTier(DT_HIGH)
            p:SetDrawLayer(DL_OVERLAY)
            p:SetDrawLevel(25)
        end
    end

    -- 3. Боевой пинг группы (Shift + ЛКМ)
    local pingIcon = "EsoUI/Art/MapPins/MapPing.dds"
    if IsUnitGrouped and IsUnitGrouped("player") then
        local groupSize = GetGroupSize and GetGroupSize() or 0
        for i = 1, groupSize do
            local unitTag = GetGroupUnitTagByIndex(i)
            if DoesUnitExist(unitTag) then
                local px, py = GetMapPing(unitTag)
                if px and py and px > 0 and py > 0 and px < 1 and py < 1 then
                    local isLeader = IsUnitGroupLeader(unitTag)
                    local name = GetUnitName(unitTag)
                    local text = isLeader and ("|cff3333Пинг лидера (" .. name .. ")|r") or ("|cffff00Пинг: " .. name .. "|r")
                    local p = pins.CreatePin(pingIcon, px, py, text, 30)
                    if p then
                        p:SetDrawTier(DT_HIGH)
                        p:SetDrawLayer(DL_OVERLAY)
                        p:SetDrawLevel(25)
                    end
                end
            end
        end
    else
        local px, py = GetMapPing("player")
        if px and py and px > 0 and py > 0 and px < 1 and py < 1 then
            local p = pins.CreatePin(pingIcon, px, py, "|cff3333Пинг на карте|r", 30)
            if p then
                p:SetDrawTier(DT_HIGH)
                p:SetDrawLayer(DL_OVERLAY)
                p:SetDrawLevel(25)
            end
        end
    end
end

-- Осадные палатки
function pins.RefreshCyrodiil()
    local isAvA = (IsInAvAZone and IsInAvAZone()) or (GetMapContentType() == MAP_CONTENT_AVA)
    if not isAvA then return end

    local bgContext = BGQUERY_LOCAL
    local numKeeps = GetNumKeeps and GetNumKeeps() or 0

    -- 1. Замки и Ресурсы
    for i = 1, numKeeps do
        local keepId = GetKeepKeysByIndex(i)
        if keepId and keepId > 0 then
            local keepName = GetKeepName(keepId)
            local isVault = keepName and (string.find(keepName, "Хранилище") or string.find(keepName, "Vault"))
            local hasArtifact = GetKeepHasArtifact and GetKeepHasArtifact(keepId)

            if not isVault or hasArtifact then
                local pinType, normX, normY = GetHistoricalKeepPinInfo(keepId, bgContext, 100.0)
                if not pinType or pinType == MAP_PIN_TYPE_INVALID then
                    pinType, normX, normY = GetKeepPinInfo(keepId, bgContext)
                end

                if pinType and pinType ~= MAP_PIN_TYPE_INVALID and normX and normY and normX > 0 and normY > 0 and normX < 1 and normY < 1 then
                    local layout = ZO_MapPin and ZO_MapPin.PIN_DATA and ZO_MapPin.PIN_DATA[pinType]
                    local icon = layout and layout.texture
                    if type(icon) == "function" then
                        local ok, res = pcall(icon, { m_PinType = pinType, keepId = keepId })
                        if ok and type(res) == "string" then icon = res else icon = nil end
                    end

                    if icon and icon ~= "" then
                        local keepType = GetKeepType and GetKeepType(keepId)
                        local size = 28
                        if keepType == KEEP_TYPE_RESOURCE then
                            size = 24
                        end

                        local keepAlliance = GetKeepAlliance(keepId, bgContext)
                        if not keepAlliance or keepAlliance == ALLIANCE_NONE then
                            keepAlliance = (GetHistoricalKeepAlliance and GetHistoricalKeepAlliance(keepId, 100.0)) or ALLIANCE_NONE
                        end
                        local allianceTint = (keepAlliance and keepAlliance ~= ALLIANCE_NONE) and GetAllianceColor(keepAlliance) or nil

                        pins.CreatePin(icon, normX, normY, keepName, size, nil, pinType, nil, allianceTint)
                    end
                end
            end
        end
    end

    -- 2. Осадные палатки (НОВЫЙ БЛОК)
    local numForwardCamps = GetNumForwardCamps and GetNumForwardCamps(BGQUERY_LOCAL) or 0
    local playerAlliance = GetUnitAlliance("player")
    local campTint = GetAllianceColor(playerAlliance)

    for i = 1, numForwardCamps do
        local pinType, normX, normY = GetForwardCampPinInfo(BGQUERY_LOCAL, i)
        if pinType and normX and normY and normX > 0 and normY > 0 and normX < 1 and normY < 1 then
            local layout = ZO_MapPin and ZO_MapPin.PIN_DATA and ZO_MapPin.PIN_DATA[pinType]
            local campIcon = layout and layout.texture
            if type(campIcon) == "function" then
                local ok, res = pcall(campIcon, { m_PinType = pinType })
                if ok and type(res) == "string" then campIcon = res else campIcon = nil end
            end

            if campIcon and campIcon ~= "" then
                pins.CreatePin(campIcon, normX, normY, "Полевой лагерь (Палатка)", 32, nil, pinType, nil, campTint)
            end
        end
    end
end

-- Поля Сражений
function pins.RefreshBattleground()
    local isBG = (IsPlayerInBattleground and IsPlayerInBattleground()) 
        or (IsActiveWorldBattleground and IsActiveWorldBattleground()) 
        or (GetMapContentType() == MAP_CONTENT_BATTLEGROUND)
    if not isBG then return end

    local numObjectives = GetNumObjectives and GetNumObjectives() or 0
    if numObjectives == 0 then return end

    for i = 1, numObjectives do
        local keepId, objectiveId, bgContext = GetObjectiveIdsForIndex(i)
        
        if keepId and objectiveId and bgContext then
            local isEnabled = IsObjectiveEnabled(keepId, objectiveId, bgContext)
            local isVisible = IsObjectiveObjectVisible(keepId, objectiveId, bgContext)
            
            if isEnabled and isVisible and IsLocalBattlegroundContext(bgContext) then
                -- 1. Места предполагаемого появления и точки спавна (Spawn locations)
                local spawnPinType, spawnX, spawnY = GetObjectiveSpawnPinInfo(keepId, objectiveId, bgContext)
                if spawnPinType and spawnPinType ~= MAP_PIN_TYPE_INVALID and spawnX and spawnY and spawnX > 0 and spawnY > 0 and spawnX < 1 and spawnY < 1 then
                    local layout = ZO_MapPin and ZO_MapPin.PIN_DATA and ZO_MapPin.PIN_DATA[spawnPinType]
                    local icon = layout and layout.texture
                    if type(icon) == "function" then
                        local ok, res = pcall(icon, { m_PinType = spawnPinType })
                        if ok and type(res) == "string" then icon = res else icon = nil end
                    end
                    if icon and icon ~= "" then
                        local tint = layout and layout.tint
                        if type(tint) == "function" then
                            local ok, res = pcall(tint, { m_PinType = spawnPinType })
                            if ok then tint = res else tint = nil end
                        end
                        pins.CreatePin(icon, spawnX, spawnY, "Точка появления", 20, nil, spawnPinType, nil, tint)
                    end
                end

                -- 2. Базы и точки возврата реликвий (Return locations)
                local returnPinType, returnX, returnY = GetObjectiveReturnPinInfo(keepId, objectiveId, bgContext)
                if returnPinType and returnPinType ~= MAP_PIN_TYPE_INVALID and returnX and returnY and returnX > 0 and returnY > 0 and returnX < 1 and returnY < 1 then
                    local layout = ZO_MapPin and ZO_MapPin.PIN_DATA and ZO_MapPin.PIN_DATA[returnPinType]
                    local icon = layout and layout.texture
                    if type(icon) == "function" then
                        local ok, res = pcall(icon, { m_PinType = returnPinType })
                        if ok and type(res) == "string" then icon = res else icon = nil end
                    end
                    if icon and icon ~= "" then
                        local tint = layout and layout.tint
                        if type(tint) == "function" then
                            local ok, res = pcall(tint, { m_PinType = returnPinType })
                            if ok then tint = res else tint = nil end
                        end
                        pins.CreatePin(icon, returnX, returnY, "База реликвии", 22, nil, returnPinType, nil, tint)
                    end
                end
            end
        end
    end
end

-- =========================================================================
-- 4. ЖИВОЙ ТРЕКЕР ГРУППЫ
-- =========================================================================
local function GetGroupMemberIcon(unitTag, isLeader)
    -- 1. Высший приоритет — персональный значок OSI (если назначен)
    local osi = OSI or OdySupportIcons
    if osi then
        local displayName = GetUnitDisplayName(unitTag)
        local rawCharName = GetUnitName(unitTag)
        local cleanCharName = rawCharName and zo_strformat("<<1>>", rawCharName)

        local keys = {}
        if displayName and displayName ~= "" then
            table.insert(keys, displayName)
            table.insert(keys, string.lower(displayName))
        end
        if cleanCharName and cleanCharName ~= "" then
            table.insert(keys, cleanCharName)
            table.insert(keys, string.lower(cleanCharName))
        end

        local tablesToCheck = { osi.special, osi.users, osi.custom, osi.rlicons }
        for _, t in ipairs(tablesToCheck) do
            if type(t) == "table" then
                for _, key in ipairs(keys) do
                    local val = t[key]
                    if val then
                        if type(val) == "string" and val ~= "" then return val
                        elseif type(val) == "table" and (val.icon or val.texture) then return val.icon or val.texture end
                    end
                end
            end
        end
    end

    -- 2. Если значка OSI нет, а игрок — лидер группы: рисуем корону
    if isLeader then
        return "EsoUI/Art/Compass/groupLeader.dds"
    end

    -- 3. Стандартная точка сопартийца
    return "EsoUI/Art/MapPins/UI-WorldMapGroupPip.dds"
end

function pins.UpdateGroupPinsRealtime()
    if not NecroCat_Minimap_MainWindow or NecroCat_Minimap_MainWindow:IsHidden() then return end

    local containerSize = NecroCat_MapContainer:GetWidth()
    local cfg = minimap.settings
    local doesRotate = cfg and cfg.rotate

    local playerX, playerY = 0, 0
    local pNormX, pNormY = GetMapPlayerPosition("player")
    if pNormX and pNormY then
        playerX = containerSize * pNormX
        playerY = containerSize * pNormY
    end
    local heading = GetPlayerCameraHeading() or 0
    local cosH = math.cos(heading)
    local sinH = math.sin(heading)

    -- 1. Сопартийцы (с крупной короной у лидера)
    if IsUnitGrouped("player") then
        for _, pin in pairs(g_groupPins) do
            pin:SetHidden(true)
        end

        local groupSize = GetGroupSize()
        for i = 1, groupSize do
            local unitTag = GetGroupUnitTagByIndex(i)
            if DoesUnitExist(unitTag) and not AreUnitsEqual("player", unitTag) then
                local x, y, _, isInCurrentMap = GetMapPlayerPosition(unitTag)
                local pin = g_groupPins[unitTag]
                if not pin then
                    pin = CreateControl("NecroCat_GroupPin_" .. unitTag, NecroCat_MapContainer, CT_TEXTURE)
                    pin:SetDrawTier(DT_HIGH)
                    pin:SetDrawLayer(DL_OVERLAY)
                    pin:SetDrawLevel(5)
                    pin:SetMouseEnabled(true)
                    pin:SetHandler("OnMouseEnter", function(self)
                        if self.pinText then
                            InitializeTooltip(InformationTooltip, self, TOP, 0, -5)
                            SetTooltipText(InformationTooltip, self.pinText)
                        end
                    end)
                    pin:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)
                    g_groupPins[unitTag] = pin
                end

                if isInCurrentMap and x > 0 and y > 0 then
                    pin:SetHidden(false)
                    local isLeader = IsUnitGroupLeader(unitTag)
                    pin:SetTexture(GetGroupMemberIcon(unitTag, isLeader))
                    pin.pinText = isLeader and ("|cffd700Лидер группы: " .. GetUnitName(unitTag) .. "|r") or GetUnitName(unitTag)
                    
                    local baseSize = (cfg and cfg.pinSize or 20)
                    local pinSize = isLeader and (baseSize + 6) or (baseSize + 2)
                    local drawLevel = isLeader and 12 or 5

                    pin:SetDimensions(pinSize, pinSize)
                    pin:SetDrawLevel(drawLevel)
                    pin:ClearAnchors()
                    if doesRotate then
                        local ix = (x * containerSize) - playerX
                        local iy = (y * containerSize) - playerY
                        pin:SetAnchor(CENTER, NecroCat_MapContainer, CENTER, (cosH * ix) - (sinH * iy), (sinH * ix) + (cosH * iy))
                    else
                        pin:SetAnchor(CENTER, NecroCat_MapContainer, TOPLEFT, x * containerSize, y * containerSize)
                    end
                else
                    pin:SetHidden(true)
                end
            else
                if g_groupPins[unitTag] then g_groupPins[unitTag]:SetHidden(true) end
            end
        end
    else
        for _, pin in pairs(g_groupPins) do pin:SetHidden(true) end
    end

    -- 2. Живое перемещение Реликвий, Флагов БГ, Древних Свитков и Молота Волендранга
    local isBG = (GetMapContentType() == MAP_CONTENT_BATTLEGROUND) or (IsPlayerInBattleground and IsPlayerInBattleground())
    local isAvA = (IsInAvAZone and IsInAvAZone()) or (GetMapContentType() == MAP_CONTENT_AVA)

    if isBG or isAvA then
        local numObjectives = GetNumObjectives and GetNumObjectives() or 0
        for i = 1, numObjectives do
            local keepId, objectiveId, bgContext = GetObjectiveIdsForIndex(i)
            local pin = g_bgObjectivePins[i]
            
            local isValidContext = isAvA or (bgContext and IsLocalBattlegroundContext(bgContext))
            if keepId and objectiveId and bgContext and isValidContext and IsObjectiveEnabled(keepId, objectiveId, bgContext) and IsObjectiveObjectVisible(keepId, objectiveId, bgContext) then
                local pinType, curX, curY = GetObjectivePinInfo(keepId, objectiveId, bgContext)
                
                -- В Сиродиле живой трекер следит только за Свитками и Молотом, глуша флаги крепостей (128..220)
                if isAvA and (type(pinType) == "number" and pinType >= 128 and pinType <= 220) then
                    pinType = MAP_PIN_TYPE_INVALID
                end

                if pinType and pinType ~= MAP_PIN_TYPE_INVALID and curX and curY and curX > 0 and curY > 0 and curX < 1 and curY < 1 then
                    if not pin then
                        pin = CreateControl("NecroCat_BGObjPin_" .. i, NecroCat_MapContainer, CT_TEXTURE)
                        pin:SetDrawTier(DT_HIGH)
                        pin:SetDrawLayer(DL_OVERLAY)
                        pin:SetDrawLevel(30)
                        g_bgObjectivePins[i] = pin
                    end

                    local layout = ZO_MapPin and ZO_MapPin.PIN_DATA and ZO_MapPin.PIN_DATA[pinType]
                    local icon = layout and layout.texture
                    if type(icon) == "function" then
                        local ok, res = pcall(icon, { m_PinType = pinType, keepId = keepId, objectiveId = objectiveId })
                        if ok and type(res) == "string" then icon = res else icon = nil end
                    end

                    if icon and icon ~= "" then
                        pin:SetTexture(icon)
                        local tint = layout and layout.tint
                        if type(tint) == "function" then
                            local ok, res = pcall(tint, { m_PinType = pinType, keepId = keepId, objectiveId = objectiveId })
                            if ok then tint = res else tint = nil end
                        end

                        if tint and type(tint) == "table" and tint.UnpackRGBA then
                            pin:SetColor(tint:UnpackRGBA())
                        elseif tint and type(tint) == "table" and tint.r then
                            pin:SetColor(tint.r, tint.g, tint.b, tint.a or 1)
                        else
                            pin:SetColor(1, 1, 1, 1)
                        end

                        local size = isAvA and 32 or 38
                        pin:SetDimensions(size, size)
                        pin:ClearAnchors()

                        if doesRotate then
                            local ix = (curX * containerSize) - playerX
                            local iy = (curY * containerSize) - playerY
                            pin:SetAnchor(CENTER, NecroCat_MapContainer, CENTER, (cosH * ix) - (sinH * iy), (sinH * ix) + (cosH * iy))
                        else
                            pin:SetAnchor(CENTER, NecroCat_MapContainer, TOPLEFT, curX * containerSize, curY * containerSize)
                        end
                        pin:SetHidden(false)
                    else
                        if pin then pin:SetHidden(true) end
                    end
                else
                    if pin then pin:SetHidden(true) end
                end
            else
                if pin then pin:SetHidden(true) end
            end
        end
    else
        for _, p in pairs(g_bgObjectivePins) do p:SetHidden(true) end
    end

    -- 3. Живое отображение статического пинга (Shift + ЛКМ)
    if NecroCat_Minimap_MapPingCtrl and g_activeMapPing then
        local now = GetFrameTimeSeconds()
        if now < g_activeMapPing.endTime then
            local px = g_activeMapPing.x * containerSize
            local py = g_activeMapPing.y * containerSize

            NecroCat_Minimap_MapPingCtrl:SetDimensions(32, 32)
            NecroCat_Minimap_MapPingCtrl:SetAlpha(1.0)

            NecroCat_Minimap_MapPingCtrl:ClearAnchors()
            if doesRotate then
                local ix = px - playerX
                local iy = py - playerY
                NecroCat_Minimap_MapPingCtrl:SetAnchor(CENTER, NecroCat_MapContainer, CENTER, (cosH * ix) - (sinH * iy), (sinH * ix) + (cosH * iy))
            else
                NecroCat_Minimap_MapPingCtrl:SetAnchor(CENTER, NecroCat_MapContainer, TOPLEFT, px, py)
            end
            NecroCat_Minimap_MapPingCtrl:SetHidden(false)
        else
            NecroCat_Minimap_MapPingCtrl:SetHidden(true)
            g_activeMapPing = nil
        end
    end
end

-- =========================================================================
-- 5. МОДУЛЬ КВЕСТОВ
-- =========================================================================
local function ClearQuestPins()
    for i = #g_activePins, 1, -1 do
        local pin = g_activePins[i]
        if pin and pin.isQuestPin then
            pin:SetHidden(true)
            pin:ClearAnchors()
            pin.isQuestPin = nil
            table.remove(g_activePins, i)
        end
    end
end

function pins.RefreshQuests()
    ClearQuestPins()

    local pinManager = ZO_WorldMap_GetPinManager and ZO_WorldMap_GetPinManager()
    if not pinManager or not pinManager.m_Active then return end

    local count = 0
    for _, mapPin in pairs(pinManager.m_Active) do
        if type(mapPin) == "table" and mapPin.IsQuest and mapPin:IsQuest() then
            count = count + 1
            local x, y = mapPin:GetNormalizedPosition()
            if not x or not y then
                x = mapPin.normalizedX
                y = mapPin.normalizedY
            end

            if x and y and x > 0 and y > 0 and x < 1 and y < 1 then
                local icon = mapPin.GetQuestIcon and mapPin:GetQuestIcon()
                if not icon or icon == "" then
                    if mapPin.IsAssisted and mapPin:IsAssisted() then
                        icon = "EsoUI/Art/Compass/quest_assisted_icon.dds"
                    else
                        icon = "EsoUI/Art/Compass/quest_icon.dds"
                    end
                end

                local questName = ""
                local qIndex = mapPin.GetQuestIndex and mapPin:GetQuestIndex()
                if qIndex and qIndex > 0 then
                    questName = GetJournalQuestName(qIndex)
                end

                local p = pins.CreatePin(icon, x, y, questName ~= "" and ("|cffff66" .. questName .. "|r") or nil, 24, nil, mapPin:GetPinType())
                if p then
                    p.isQuestPin = true
                    p:SetDrawTier(DT_HIGH)
                    p:SetDrawLayer(DL_OVERLAY)
                    p:SetDrawLevel(22)
                end
            end
        end
    end

    -- САМОДИАГНОСТИКА: если в журнале есть квесты, а карта спит — будим и сразу дорисовываем!
    local numJournalQuests = GetNumJournalQuests and GetNumJournalQuests() or 0
    if count == 0 and numJournalQuests > 0 and not pins.isWakingUp and g_isPlayerActivated then
        pins.isWakingUp = true
        if ZO_WorldMap_RefreshQuestPins then
            pcall(ZO_WorldMap_RefreshQuestPins)
        end
        zo_callLater(function()
            pins.isWakingUp = nil
            if pins.RefreshQuests then
                pins.RefreshQuests()
            end
        end, 200)
    end
end

EVENT_MANAGER:RegisterForEvent("NecroCat_Minimap_QuestZone", EVENT_ZONE_CHANGED, function()
    ClearOldZonePins()
end)

EVENT_MANAGER:RegisterForEvent("NecroCat_Minimap_PinTeleport", EVENT_PLAYER_ACTIVATED, function()
    g_isPlayerActivated = true
    ClearOldZonePins()
end)

function pins.RefreshSavedLibMapPins()
    local lmp = LibMapPins
    local currentMapTile = GetMapTileTexture and GetMapTileTexture(1) or ""
    if currentMapTile == "" then return end

    for _, pData in pairs(g_savedLibMapPins) do
        if pData.mapTile == currentMapTile then
            local isEnabled = true
            if pData.pinType and lmp and lmp.IsEnabled then
                if lmp:IsEnabled(pData.pinType) == false then
                    isEnabled = false
                end
            end
            if isEnabled then
                pins.CreatePin(pData.icon, pData.x, pData.y, pData.text, pData.size, pData.tooltip, pData.pinType, pData.pinTag, pData.tint)
            end
        end
    end
end

local function OnQuestStateChanged()
    if not g_isPlayerActivated then return end
    EVENT_MANAGER:UnregisterForUpdate("NecroCat_Minimap_QuestDebounce")
    EVENT_MANAGER:RegisterForUpdate("NecroCat_Minimap_QuestDebounce", 150, function()
        EVENT_MANAGER:UnregisterForUpdate("NecroCat_Minimap_QuestDebounce")
        if pins.RefreshQuests then
            pins.RefreshQuests()
        end
    end)
end

if WORLD_MAP_QUEST_BREADCRUMBS then
    WORLD_MAP_QUEST_BREADCRUMBS:RegisterCallback("QuestAvailable", OnQuestStateChanged)
    WORLD_MAP_QUEST_BREADCRUMBS:RegisterCallback("QuestRemoved", OnQuestStateChanged)
end

if FOCUSED_QUEST_TRACKER then
    FOCUSED_QUEST_TRACKER:RegisterCallback("QuestTrackerAssistStateChanged", OnQuestStateChanged)
end

EVENT_MANAGER:RegisterForEvent("NecroCat_Minimap_QuestAdv", EVENT_QUEST_ADVANCED, OnQuestStateChanged)
EVENT_MANAGER:RegisterForEvent("NecroCat_Minimap_QuestCond", EVENT_QUEST_CONDITION_COUNTER_CHANGED, OnQuestStateChanged)
EVENT_MANAGER:RegisterForEvent("NecroCat_Minimap_QuestComp", EVENT_QUEST_COMPLETE, OnQuestStateChanged)
EVENT_MANAGER:RegisterForEvent("NecroCat_Minimap_QuestRem", EVENT_QUEST_REMOVED, OnQuestStateChanged)
EVENT_MANAGER:RegisterForEvent("NecroCat_Minimap_QuestAdd", EVENT_QUEST_ADDED, OnQuestStateChanged)

function pins.RefreshLibMapPins()
    if GetCurrentZoneHouseId() ~= 0 then return end

    local lmp = LibMapPins
    if not lmp or not lmp.filters then return end

    for pinType, _ in pairs(lmp.filters) do
        if lmp.IsEnabled and lmp:IsEnabled(pinType) then
            pcall(function()
                if lmp.RefreshPins then lmp:RefreshPins(pinType) end
            end)
        end
    end
end

-- Полная перерисовка ВСЕХ статических меток миникарты
function pins.RefreshAll()
    pins.Reset()
    if pins.RefreshWayshrines then pins.RefreshWayshrines() end
    if pins.RefreshLocations then pins.RefreshLocations() end
    if pins.RefreshPOIs then pins.RefreshPOIs() end
    if pins.RefreshSkyshards then pins.RefreshSkyshards() end
    if pins.RefreshQuests then pins.RefreshQuests() end
    if pins.RefreshLibMapPins then pins.RefreshLibMapPins() end
    if pins.RefreshSavedLibMapPins then pins.RefreshSavedLibMapPins() end
    if pins.RefreshWaypoints then pins.RefreshWaypoints() end
    if pins.RefreshCompanion then pins.RefreshCompanion() end
    if pins.RefreshBattleground then pins.RefreshBattleground() end
    if pins.RefreshCyrodiil then pins.RefreshCyrodiil() end
end

-- =========================================================================
-- 6. ЕДИНЫЙ УМНЫЙ ПЕРЕХВАТЧИК МЕТОК (LibMapPins)
-- =========================================================================
local function HandleCustomPinCreation(pinType, pinTag, xLoc, yLoc)
    if not (minimap.settings and minimap.settings.enabled) then return end
    if not xLoc or not yLoc or xLoc <= 0 or yLoc <= 0 or xLoc >= 1 or yLoc >= 1 then return end

    -- Пока открыта большая карта — миникарта вообще не должна перехватывать чужие метки!
    if WORLD_MAP_SCENE and WORLD_MAP_SCENE:IsShowing() then return end

    -- Если просматривается чужая карта — игнорируем чужие метки
    if DoesCurrentMapMatchMapForPlayerLocation and not DoesCurrentMapMatchMapForPlayerLocation() then
        return
    end

    -- В инстансах (Архив, Данжи, Триалы, Дома) глушим внешние уличные метки QuestMap и уличные POI
    local isInstance = (GetMapContentType and GetMapContentType() == MAP_CONTENT_DUNGEON)
        or (GetCurrentZoneHouseId and GetCurrentZoneHouseId() ~= 0)
        or (IsUnitInDungeon and IsUnitInDungeon("player"))

    if isInstance then
        local pinStr = string.lower(tostring(pinType))
        if string.find(pinStr, "questmap") or string.find(pinStr, "poi") or pinType == 262 then
            return
        end
    end

    -- 1. Пропускаем стандартные квесты игры (их на 100% рисует RefreshQuests)
    if ZO_MapPin and ZO_MapPin.IsQuestPinType and ZO_MapPin.IsQuestPinType(pinType) then
        return
    end

    -- 2. Строго проверяем галочку в фильтрах карты игрока для LibMapPins
    local lmp = LibMapPins
    if lmp and lmp.IsEnabled and pinType and lmp:IsEnabled(pinType) == false then
        return
    end

    -- 3. В подземельях и домах не пускаем уличные метки и скампов
    local currentZone = GetCurrentZoneId and GetCurrentZoneId() or 0
    local isDungeonOrHouse = (GetMapContentType() == MAP_CONTENT_DUNGEON or GetCurrentZoneHouseId() ~= 0)
    local isIC = (currentZone == 584 or currentZone == 643 or (IsInImperialCity and IsInImperialCity()) or (IsInImperialCitySewers and IsInImperialCitySewers()))

    if (pinType == 306 or pinType == 307 or (type(pinType) == "string" and string.find(pinType, "Scamp"))) and not isIC then
        return
    end

    if isDungeonOrHouse and (pinType == 262 or (type(pinType) == "string" and (string.find(pinType, "POI") or string.find(pinType, "Battlefield")))) then
        return
    end

    if pinType and (pinType == MAP_PIN_TYPE_FORWARD_CAMP_ALDMERI_DOMINION or pinType == MAP_PIN_TYPE_FORWARD_CAMP_EBONHEART_PACT or pinType == MAP_PIN_TYPE_FORWARD_CAMP_DAGGERFALL_COVENANT) then
        return
    end

    -- 4. Получаем данные значка и рисуем (LibMapPins)
    local layout = nil
    if lmp and lmp.GetLayoutData then layout = lmp:GetLayoutData(pinType) end
    if not layout and ZO_MapPin and ZO_MapPin.PIN_DATA then layout = ZO_MapPin.PIN_DATA[pinType] end

    if layout then
        local icon = layout.texture or layout[1]
        if type(icon) == "function" then
            local ok, res = pcall(icon, { m_PinType = pinType, m_PinTag = pinTag })
            if ok and type(res) == "string" then icon = res else icon = nil end
        end

        if icon and icon ~= "" then
            local size = 18
            local tooltipCreator = layout.tooltip
            local tint = layout.tint
            if type(tint) == "function" then
                local ok, res = pcall(tint, { m_PinType = pinType, m_PinTag = pinTag })
                if ok then tint = res else tint = nil end
            end

            local currentMapTile = GetMapTileTexture and GetMapTileTexture(1) or ""
            local pinKey = string.format("%s:%.4f:%.4f:%s", currentMapTile, xLoc, yLoc, tostring(pinType))
            g_savedLibMapPins[pinKey] = {
                mapTile = currentMapTile,
                icon = icon,
                x = xLoc,
                y = yLoc,
                size = size,
                tooltip = tooltipCreator,
                pinType = pinType,
                pinTag = pinTag,
                tint = tint
            }

            pins.CreatePin(icon, xLoc, yLoc, nil, size, tooltipCreator, pinType, pinTag, tint)
        end
    end
end

-- Включаем умные перехватчики для QuestMap (LibMapPins) и MapPins (PinManager)
local pinManager = ZO_WorldMap_GetPinManager and ZO_WorldMap_GetPinManager()
if pinManager then
    ZO_PostHook(pinManager, "CreatePin", function(self, pinType, pinTag, xLoc, yLoc)
        HandleCustomPinCreation(pinType, pinTag, xLoc, yLoc)
    end)
end

if LibMapPins then
    ZO_PostHook(LibMapPins, "CreatePin", function(self, pinType, pinTag, xLoc, yLoc)
        HandleCustomPinCreation(pinType, pinTag, xLoc, yLoc)
    end)
end


EVENT_MANAGER:RegisterForUpdate("NecroCat_Minimap_GroupUpdate", 100, pins.UpdateGroupPinsRealtime)

-- Перехват личного клика Shift + ЛКМ
ZO_PreHook("PingMap", function(pinType, mapType, x, y)
    if x and y and x > 0 and y > 0 and pins.ShowMapPing then
        pins.ShowMapPing(x, y)
    end
end)

-- Перехват пинга от согруппников по сети
EVENT_MANAGER:RegisterForEvent("NecroCat_Minimap_MapPing", EVENT_MAP_PING, function(eventCode, pingEventType, pingType, pingTag, offsetX, offsetY)
    if offsetX and offsetY and offsetX > 0 and offsetY > 0 and pins.ShowMapPing then
        pins.ShowMapPing(offsetX, offsetY)
    end
end)

EVENT_MANAGER:RegisterForEvent("NecroCat_Minimap_KeepAttack", EVENT_KEEP_UNDER_ATTACK_CHANGED, function()
    if pins.RefreshCyrodiil then pins.RefreshCyrodiil() end
end)

EVENT_MANAGER:RegisterForEvent("NecroCat_Minimap_KeepOwner", EVENT_KEEP_ALLIANCE_OWNER_CHANGED, function()
    if pins.RefreshCyrodiil then pins.RefreshCyrodiil() end
end)

EVENT_MANAGER:RegisterForEvent("NecroCat_Minimap_ForwardCamps", EVENT_FORWARD_CAMPS_UPDATED, function()
    if pins.RefreshCyrodiil then pins.RefreshCyrodiil() end
end)

EVENT_MANAGER:RegisterForEvent("NecroCat_Minimap_BGObjectives", EVENT_OBJECTIVES_UPDATED, function()
    if pins.RefreshBattleground then pins.RefreshBattleground() end
end)

EVENT_MANAGER:RegisterForEvent("NecroCat_Minimap_BGControl", EVENT_OBJECTIVE_CONTROL_STATE, function()
    if pins.RefreshBattleground then pins.RefreshBattleground() end
end)

local function OnGroupCompositionChanged()
    for _, pin in pairs(g_groupPins) do
        pin:SetHidden(true)
    end
    if pins.UpdateGroupPinsRealtime then
        pins.UpdateGroupPinsRealtime()
    end
end

EVENT_MANAGER:RegisterForEvent("NecroCat_Minimap_GroupLeft", EVENT_GROUP_MEMBER_LEFT, OnGroupCompositionChanged)
EVENT_MANAGER:RegisterForEvent("NecroCat_Minimap_GroupDisband", EVENT_GROUP_DISBANDED, OnGroupCompositionChanged)