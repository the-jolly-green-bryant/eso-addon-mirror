local mr = MapRadar
local zoneData = MapRadarZoneData
local getCurrentMapId = GetCurrentMapId

local speedometer = nil
local worldMap = ZO_WorldMap
local getMapPlayerPosition = GetMapPlayerPosition
local getUnitWorldPosition = GetUnitWorldPosition
local getUnitRawWorldPosition = GetUnitRawWorldPosition
local latestMapId = 0
local data = {}

local function getMeterCoefficient()
    local zData = zoneData[getCurrentMapId()]
    if zData ~= nil then
        return zData
    end

    return 0
end

local function CreateLabel(anchorPoint, anchor, targetAnchorPoint, text)
    local label, labelKey = labelPool:AcquireObject()
    label:SetFont("$(BOLD_FONT)|16|outline")
    label:SetColor(1, 1, 1, 1)
    label:SetAnchor(anchorPoint, anchor, targetAnchorPoint)

    if text ~= nil then
        label:SetText(text)
    end

    return label;
end

local function CreateSpeedometer()

    local speedPos = MapRadar.config.speedPosition
    speedometer = MapRadarCommon.CreateLabel("$(parent)speedLabel", MapRadarContainer, "")
    speedometer:SetAnchor(speedPos.point, GuiRoot, speedPos.relativePoint, speedPos.offsetX, speedPos.offsetY)
    speedometer:SetMouseEnabled(true)
    speedometer:SetMovable(true)

    speedometer:SetFont("$(BOLD_FONT)|28|outline")

    speedometer:SetHandler(
        "OnMoveStop", function()
            local _, point, _, relativePoint, offsetX, offsetY = speedometer:GetAnchor(0)
            MapRadar.config.speedPosition = {
                point = point,
                relativePoint = relativePoint,
                offsetX = offsetX,
                offsetY = offsetY
             }
        end)
end

local function MapRadar_InitSpeedometer()
    CreateSpeedometer()
end

local function EnableOrDisableSpeedometer()
    if (speedometer ~= nil and speedometer.SetHidden ~= nil) then
        speedometer:SetHidden(not MapRadar.config.showSpeedometer)
    end

    if MapRadar.config.showSpeedometer then
        EVENT_MANAGER:RegisterForUpdate(
            "MapRadar_Speedometer", 200, function()
                local zoneId, wx, wy, wz = getUnitRawWorldPosition("player");
                local mps = 0

                if (data.wx ~= nil and data.wy ~= nil and data.wz ~= nil) then
                    local distance = zo_distance3D(data.wx, data.wy, data.wz, wx, wy, wz) / 100
                    mps = distance * 5 -- Update triggers 5 times per second
                end

                data.wx = wx
                data.wy = wy
                data.wz = wz

                speedometer:SetText(zo_strformat("<<1>> m/s", mps))
            end)
    else
        EVENT_MANAGER:UnregisterForUpdate("MapRadar_Speedometer")
    end
end

local function MapRadar_ToggleSpeedometer()
    if MapRadar.config.showSpeedometer and speedometer == nil then
        MapRadar_InitSpeedometer()
    end

    EnableOrDisableSpeedometer()
end

CALLBACK_MANAGER:RegisterCallback(
    "OnMapRadarInitialized", function()
        MapRadar_ToggleSpeedometer()

    end)

CALLBACK_MANAGER:RegisterCallback("OnMapRadarSlashCommand", MapRadar_ToggleSpeedometer)
CALLBACK_MANAGER:RegisterCallback("MapRadar_Reset", MapRadar_ToggleSpeedometer)
