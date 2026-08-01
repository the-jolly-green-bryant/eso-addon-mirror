local mapCoordinateData = {}
local mapCoordinateDataMatrix = {}
local dataForm = nil
local worldMap = ZO_WorldMap
local getMapPlayerPosition = GetMapPlayerPosition
local getUnitWorldPosition = GetUnitWorldPosition
local getUnitRawWorldPosition = GetUnitRawWorldPosition
local getCurrentMapId = GetCurrentMapId
local latestMapId = 0
local ScaleData = {
    px = 0,
    py = 0
}

local function isSkippedMap(mapId)
    if
        mapId == 27 or mapId == 439 -- Tamriel
     then -- The Aurubis
        return true
    end

    return false
end

local function checkMapIdUpdated(mapId)
    if latestMapId ~= mapId then
        local isCalibrated =
            MapRadarAutoscaled[mapId] ~= nil or MapRadarZoneData[mapId] ~= nil or
            MapRadar.accountData.worldScaleData[mapId] ~= nil
        dataForm:SetColor(1, 1, isCalibrated and 1 or 0, 1)

        if dataForm.autoscaleLabel then
            local isAutoscaled = MapRadarAutoscaled[mapId] ~= nil
            local isInSavedVars = MapRadar.accountData.worldScaleData[mapId] ~= nil
            local showLabel = isAutoscaled or not isInSavedVars
            dataForm.autoscaleLabel:SetHidden(not showLabel)
            dataForm.autoscaleLabel:SetColor(1, 1, isAutoscaled and 1 or 0, 1)
        end

        if (mapCoordinateData[mapId] == nil) then
            mapCoordinateData[mapId] = {
                name = worldMap.zoneName,
                positions = {},
                count = 0
            }
            mapCoordinateDataMatrix[mapId] = {}
        end
    end

    latestMapId = mapId
end

local function calcAndSaveDistances()
    for index, mapData in pairs(mapCoordinateData) do
        local distanceData = {
            mapDistance = 0,
            worldDistance = 0
        }

        -- Iterate and compare all positions and find longest one
        for posIndex, mapPos in pairs(mapData.positions) do
            for posIndex2, mapPos2 in pairs(mapData.positions) do
                local mapDistance = zo_distance(mapPos.mapX, mapPos.mapY, mapPos2.mapX, mapPos2.mapY)
                local worldDistance = zo_distance(mapPos.worldX, mapPos.worldY, mapPos2.worldX, mapPos2.worldY) / 100

                if (worldDistance > distanceData.worldDistance) then
                    distanceData.mapDistance = mapDistance
                    distanceData.worldDistance = worldDistance
                end
            end
        end

        -- If distance is calculated then calculate 1 meter coefficient
        if (distanceData.mapDistance > 0) then
            local map1meterCoefficient = distanceData.mapDistance / distanceData.worldDistance
            MapRadar.accountData.worldScaleData[index] = map1meterCoefficient
        end

        -- Cleaning position table data
        for i, pos in pairs(mapData.positions) do
            mapData.positions[i] = nil
        end
        mapCoordinateData[index] = nil
    end

    -- Clear counter data from UI
    dataForm.counterList:Clear()

    latestMapId = 0
    checkMapIdUpdated(getCurrentMapId())
end

local function selfData()
    local playerX, playerY, heading, isShownInCurrentMap = getMapPlayerPosition("player")
    if not isShownInCurrentMap then
        return
    end

    local zoneId, wx, wy, wz = getUnitWorldPosition("player")
    local zoneId, rwx, rwy, rwz = getUnitRawWorldPosition("player")

    ScaleData.px = playerX
    ScaleData.py = playerY

    ScaleData.wx = wx
    ScaleData.wy = wy
    ScaleData.wz = wz

    ScaleData.rwx = rwx -- Longitude
    ScaleData.rwy = rwy -- Elevation
    ScaleData.rwz = rwz -- Latitude
end

local function CreateCalibrationDataForm()
    dataForm = MapRadarCommon.DataForm:New("WorldCalibrateDataForm", MapRadarContainer)
    dataForm:SetAnchor(LEFT, GuiRoot, LEFT, 150, 150)

    dataForm:AddLabel(
        "MapId",
        function()
            local mapId = getCurrentMapId()
            checkMapIdUpdated(mapId)
            return mapId
        end
    )

    dataForm:AddLabel(
        "Active zone",
        function()
            return GetPlayerActiveZoneName()
        end
    )

    dataForm:AddLabel(
        "Zone",
        function()
            return worldMap.zoneName
        end
    )
    dataForm:AddLabel(
        "Rel PX",
        function()
            return ScaleData.px
        end
    )
    dataForm:AddLabel(
        "Rel PY",
        function()
            return ScaleData.py
        end
    )

    dataForm:AddLabel(
        "World (X/Z/Y)",
        function()
            return zo_strformat("<<1>>  <<2>>  <<3>>", ScaleData.wx, ScaleData.wz, ScaleData.wy)
        end
    )

    dataForm:AddLabel(
        "Raw World (X/Z/Y)",
        function()
            return zo_strformat("<<1>>  <<2>>  <<3>>", ScaleData.rwx, ScaleData.rwz, ScaleData.rwy)
        end
    )

    dataForm:AddLabel(
        "AUTOSCALE",
        function()
            return "AUTOSCALE"
        end
    )
    local autoscaleIndex = table.maxn(dataForm.labels)
    dataForm.autoscaleLabel = dataForm.labels[autoscaleIndex].control
    dataForm.autoscaleLabel:SetColor(1, 1, 0, 1)
    dataForm.autoscaleLabel:SetHidden(true)

    local btnSave = CreateControlFromVirtual("$(parent)btnSave", dataForm, "SavingEditBoxSaveButton")
    btnSave:SetDimensions(40, 40)
    btnSave:SetAnchor(TOPLEFT, dataForm, BOTTOMLEFT, 0, 10)
    btnSave:SetHandler(
        "OnClicked",
        function()
            calcAndSaveDistances()
        end
    )

    -- Counter list
    dataForm.counterList = MapRadarCommon.CounterList:New("WorldCalibrateCounterList", MapRadarContainer)
    dataForm.counterList:SetAnchor(TOP, GuiRoot, TOP, 550, 0)
end

local function MapRadar_InitScaleCalibrator()
    CreateCalibrationDataForm()
end

local function EnableOrDisableCalibrator()
    if (dataForm ~= nil and dataForm.SetHidden ~= nil) then
        dataForm:SetHidden(not MapRadar.config.showCalibrate)
    end

    if MapRadar.config.showCalibrate then
        EVENT_MANAGER:RegisterForUpdate(
            "MapRadar_WorldCalibrationData",
            100,
            function()
                selfData()
                dataForm:Update()
            end
        )

        latestMapId = 0
        checkMapIdUpdated(getCurrentMapId())
    else
        EVENT_MANAGER:UnregisterForUpdate("MapRadar_CalibrationData")
    end

    if MapRadar.config.showCalibrate then
        EVENT_MANAGER:RegisterForUpdate(
            "MapRadar_SaveMapCoordinates",
            1000,
            function()
                local mapId = getCurrentMapId()

                local mapX, mapY, heading, isShownInCurrentMap = getMapPlayerPosition("player")
                if not isShownInCurrentMap or isSkippedMap(mapId) then
                    return
                end

                checkMapIdUpdated(mapId)

                if MapRadarZoneData[mapId] == nil and MapRadar.accountData.mapNameData[mapId] == nil then
                    -- Need to save map name
                    MapRadar.accountData.mapNameData[mapId] = worldMap.zoneName
                end

                if MapRadarAutoscaled[mapId] ~= nil or MapRadar.accountData.worldScaleData[mapId] ~= nil then
                    return -- do not gather position data for world scaled maps
                end

                local _, wx, _, wz = getUnitRawWorldPosition("player")
                -- local _, rwx, _, rwz = getUnitRawWorldPosition("player");

                -- Ensures that map positions are only saved in matrix by 10meters
                local xIndex = zo_floor(wx / 1000)
                local yIndex = zo_floor(wz / 1000)

                local mapMatrix = mapCoordinateDataMatrix[mapId]

                if (mapMatrix[xIndex] == nil) then
                    mapMatrix[xIndex] = {}
                end

                if (mapMatrix[xIndex][yIndex] == nil) then
                    mapMatrix[xIndex][yIndex] = true

                    table.insert(
                        mapCoordinateData[mapId].positions,
                        {
                            mapX = mapX,
                            mapY = mapY,
                            worldX = wx,
                            worldY = wz -- Z parameter is instead of Y because Y is elevation
                        }
                    )

                    -- Increase record counter for statistics
                    mapCoordinateData[mapId].count = mapCoordinateData[mapId].count + 1

                    local name = zo_strformat("<<1>> (<<2>>)", worldMap.zoneName, mapId)
                    dataForm.counterList:AddOrUpdateCounter(mapId, name, mapCoordinateData[mapId].count)
                end
            end
        )
    else
        EVENT_MANAGER:UnregisterForUpdate("MapRadar_SaveMapCoordinates")
    end
end

CALLBACK_MANAGER:RegisterCallback(
    "OnMapRadarInitialized",
    function()
        if MapRadar.accountData.worldScaleData == nil then
            MapRadar.accountData.worldScaleData = {}
        end

        if MapRadar.accountData.mapNameData == nil then
            MapRadar.accountData.mapNameData = {}
        end

        if MapRadar.config.showCalibrate then
            MapRadar_InitScaleCalibrator()
        end

        EnableOrDisableCalibrator()
    end
)

CALLBACK_MANAGER:RegisterCallback(
    "OnMapRadarSlashCommand",
    function(args)
        if (args == "reset") then
            dataForm.counterList:Clear()
        end

        if MapRadar.config.showCalibrate and dataForm == nil then
            MapRadar_InitScaleCalibrator()
        end

        EnableOrDisableCalibrator()
    end
)
