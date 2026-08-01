HF = {}
HF.name = "HousingForge"
HF.displayName = "HousingForge"
HF.version = "1.4.0"
HF.savedVars = nil
HF.initialized = false
HF.DEBUG_ENABLED = false

HF.defaults = {
    savedVarsVersion = 2,
    layouts = {},
    marketplaceLayouts = {},
    blueprintGroups = {},
    settings = {
        showMissingMarkers = true,
        markerOpacity = 0.9,
        maxMarkers = 30,
        autoRecordBeforeCleanup = true,
        maxRecoverySnapshots = 5,
        housingRequestDelayMs = 350,
        exportEndpoint = "",
        exportFormat = "v2",
        applyMode = "cleanapply",
        miniMapFilter = "essentials",
        miniMapMaxPins = 90,
    },
    calibration = {
        markerFurnitureDataIds = {},
        rooms = {},
    },
    lastSelectedLayoutId = nil,
    exportQueue = nil,
    ownedIndex = nil,
    applyQueue = nil,
    blueprintRecovery = nil,
}

HF.ui = {
    isOpen = false,
    sceneInitialized = false,
    selectedLayoutIndex = 1,
    layoutSelectionInitialized = false,
    layoutViewMode = "local",
    screenMode = "layouts",
    layoutScrollOffset = 0,
    maxVisibleLayouts = 10,
    sortedLayouts = {},
    selectedMissingIndex = 1,
    missingScrollOffset = 0,
    maxVisibleMissing = 12,
    lastApplySummary = nil,
    selectedSettingIndex = 1,
    selectedActionIndex = 1,
}

HF.runtime = {
    missingItems = {},
    ownedItems = {},
    failedItems = {},
    failedLayoutHouseId = nil,
    failedLayoutName = nil,
    cleaning = false,
    exportQueue = nil,
    applyQueue = nil,
    ownedPreview = nil,
}

function HF.Debug(msg)
    if HF.DEBUG_ENABLED and d then
        d(msg)
    end
end

function HF.Chat(msg)
    if d then
        d("|cAAFFAA[HousingForge]|r " .. tostring(msg))
    end
end

function HF.FormatTimestamp(timestamp)
    if not timestamp or timestamp == 0 then return "Never" end
    local dateTable = os.date("*t", timestamp)
    return string.format("%02d/%02d/%02d %02d:%02d", dateTable.month, dateTable.day, dateTable.year % 100, dateTable.hour, dateTable.min)
end

function HF.TableCount(t)
    local count = 0
    if not t then return 0 end
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

function HF.GetCurrentHouseName()
    local locationName = GetPlayerLocationName and GetPlayerLocationName() or ""
    if locationName and locationName ~= "" then return locationName end
    local houseId = GetCurrentZoneHouseId and GetCurrentZoneHouseId() or 0
    return houseId ~= 0 and ("House " .. tostring(houseId)) or "Unknown House"
end

function HF.MakeLayoutId()
    local houseId = GetCurrentZoneHouseId and GetCurrentZoneHouseId() or 0
    local frameMs = GetFrameTimeMilliseconds and GetFrameTimeMilliseconds() or 0
    local baseId = string.format("local-%d-%d-%d", houseId, GetTimeStamp(), frameMs % 100000)
    local candidate = baseId
    local suffix = 1
    while HF.savedVars and HF.savedVars.layouts and HF.savedVars.layouts[candidate] do
        suffix = suffix + 1
        candidate = baseId .. "-" .. tostring(suffix)
    end
    return candidate
end

function HF.GetSafeLinkName(link, fallback)
    if link and link ~= "" and GetItemLinkName then
        local name = GetItemLinkName(link)
        if name and name ~= "" then
            return zo_strformat and zo_strformat(SI_TOOLTIP_ITEM_NAME, name) or name
        end
    end
    return fallback or "Unknown Furniture"
end
