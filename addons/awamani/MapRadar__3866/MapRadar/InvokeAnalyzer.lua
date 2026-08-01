local dataForm = {}
local pinManager = ZO_WorldMap_GetPinManager()

local AnalyzerData = {
    pinCreateCount = 0,
    pinRemoveCount = 0,
    pinUpdateCount = 0,
    pinCorruptedCount = 0,
    pointerCreatinCount = 0,
    pointerRotateCount = 0
 }

local function CreateInvokeAnalyzerDataForm()

    dataForm = MapRadarCommon.DataForm:New("InvokeAnalyzerDataForm", MapRadarContainer)
    dataForm:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 100, 200)

    dataForm:AddStack(
        "Pins", function()
            return MapRadar.tablelength(pinManager:GetActiveObjects())
        end)
    dataForm:AddStack(
        "ActivePins", function()
            return MapRadar.tablelength(MapRadar.activePins)
        end)
    dataForm:AddStack(
        "Pin Create", function()
            return AnalyzerData.pinCreateCount
        end)
    dataForm:AddStack(
        "Pin Remove", function()
            return AnalyzerData.pinRemoveCount
        end)
    dataForm:AddStack(
        "Pin Update", function()
            return AnalyzerData.pinUpdateCount
        end)
    dataForm:AddStack(
        "Pin Corrupted", function()
            return AnalyzerData.pinCorruptedCount
        end)
end

local function MapRadar_InitInvokeAnalyzer()
    CreateInvokeAnalyzerDataForm()

    CALLBACK_MANAGER:RegisterCallback(
        "OnMapRadar_NewPin", function(radarPin)
            AnalyzerData.pinCreateCount = AnalyzerData.pinCreateCount + 1
        end)

    CALLBACK_MANAGER:RegisterCallback(
        "OnMapRadar_RemovePin", function(radarPin)
            AnalyzerData.pinRemoveCount = AnalyzerData.pinRemoveCount + 1
        end)

    CALLBACK_MANAGER:RegisterCallback(
        "OnMapRadar_UpdatePin", function(radarPin)
            AnalyzerData.pinUpdateCount = AnalyzerData.pinUpdateCount + 1
        end)

    CALLBACK_MANAGER:RegisterCallback(
        "MapRadar_CorruptedPin", function(radarPin)
            AnalyzerData.pinCorruptedCount = AnalyzerData.pinCorruptedCount + 1
        end)

    d("InvokeAnalyzer enabled")
end

local function EnableOrDisableAnalyzer()
    dataForm:SetHidden(not MapRadar.config.showAnalyzer)

    if MapRadar.config.showAnalyzer then
        EVENT_MANAGER:RegisterForUpdate(
            "MapRadar_AnalyzerReader", 1000, function()

                if not MapRadar.config.showAnalyzer then
                    return
                end

                dataForm:Update()

                -- Rest counters
                AnalyzerData.pinCreateCount = 0
                AnalyzerData.pinRemoveCount = 0
                AnalyzerData.pinUpdateCount = 0
                AnalyzerData.pinCorruptedCount = 0

                --[[
            local mapScrollHidden = MapRadar.getStrVal(ZO_WorldMapScroll:IsHidden())
            local navOverlayShowing = MapRadar.getStrVal(WORLD_MAP_AUTO_NAVIGATION_OVERLAY_FRAGMENT:IsShowing())
            local worldmapShowing = MapRadar.getStrVal(SCENE_MANAGER:IsShowing("worldMap"))
    
            MapRadar.debugDebounce("Scroll hidden: <<1>>,  NavOverlay: <<2>>,  WorldMap: <<3>>", mapScrollHidden, navOverlayShowing, worldmapShowing)
    --]]
            end)
    else
        EVENT_MANAGER:UnregisterForUpdate("MapRadar_AnalyzerReader")
    end
end

CALLBACK_MANAGER:RegisterCallback(
    "OnMapRadarInitializing", function()
        MapRadar_InitInvokeAnalyzer()
        EnableOrDisableAnalyzer()
    end)

CALLBACK_MANAGER:RegisterCallback(
    "OnMapRadarSlashCommand", function()

        if MapRadar.config.showAnalyzer and dataForm == nil then
            MapRadar_InitInvokeAnalyzer()
        end

        EnableOrDisableAnalyzer()
    end)
