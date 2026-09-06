local SpecificLorebookPins = SpecificLorebookPins or {}
local SLP = SpecificLorebookPins

SLP.name = "SpecificLorebookPins"
SLP.pinType = "SpecificLorebookPins_Pin"

SLP.default = {
    iconTexture = "/esoui/art/mappins/hostile_pin.dds",
    enabled = true,
    pinSize = 32, -- Default pin size
}

SLP.pinLayout = {
    level = 200,
    size = 32,
    texture = "/esoui/art/mappins/hostile_pin.dds",
}

-- Localize globals for maximum performance
local GetCurrentMapId = GetCurrentMapId
local GetLoreBookIndicesFromBookId = GetLoreBookIndicesFromBookId
local GetLoreBookInfo = GetLoreBookInfo
local LibMapPins = LibMapPins
local pcall = pcall
local tostring = tostring

-- Raw coordinate data
SLP.BookCoordinates = {
    [1964] = { x = 0.703722, y = 0.489982, mapId = 1555 }, -- Mysterious Akavir (Northern Elsweyr)
    [5393] = { x = 0.527092, y = 0.235371, mapId = 1555 },
    [5663] = { x = 0.504685, y = 0.172594, mapId = 1555 },
    [5430] = { x = 0.504748, y = 0.173166, mapId = 1555 },
    [5601] = { x = 0.515992, y = 0.155714, mapId = 1555 },
    [5463] = { x = 0.732817, y = 0.477276, mapId = 1555 },
    [5607] = { x = 0.745565, y = 0.476732, mapId = 1555 },
    [5630] = { x = 0.725323, y = 0.409086, mapId = 1555 },
    [5595] = { x = 0.729336, y = 0.401586, mapId = 1555 },
    [5626] = { x = 0.729455, y = 0.403154, mapId = 1555 },
    [5592] = { x = 0.703824, y = 0.378798, mapId = 1555 },
    [5620] = { x = 0.685825, y = 0.410151, mapId = 1555 },
    [5621] = { x = 0.685825, y = 0.410151, mapId = 1555 },
    [5622] = { x = 0.685825, y = 0.410151, mapId = 1555 },
    [5623] = { x = 0.685825, y = 0.410151, mapId = 1555 },
    [5632] = { x = 0.793625, y = 0.331822, mapId = 1555 },
    [5670] = { x = 0.326115, y = 0.629208, mapId = 1576 },
    [5435] = { x = 0.483760, y = 0.521511, mapId = 1576 },
    [5399] = { x = 0.500470, y = 0.518079, mapId = 1576 },
    [2561] = { x = 0.449399, y = 0.402047, mapId = 1576 },
    [5608] = { x = 0.461003, y = 0.337678, mapId = 1576 },
    [5506] = { x = 0.362621, y = 0.508593, mapId = 1591 },
    [5618] = { x = 0.508372, y = 0.590220, mapId = 1591 },
    [5662] = { x = 0.592246, y = 0.551701, mapId = 1591 },
    [5426] = { x = 0.527757, y = 0.234786, mapId = 1555 },
    [5612] = { x = 0.495489, y = 0.284687, mapId = 1555 },
    [5633] = { x = 0.683470, y = 0.292477, mapId = 1595 },
    [5478] = { x = 0.397663, y = 0.288662, mapId = 1555 },
    [5598] = { x = 0.429563, y = 0.349440, mapId = 1555 },
    [5380] = { x = 0.524265, y = 0.365564, mapId = 1555 },
    [5425] = { x = 0.526081, y = 0.364222, mapId = 1555 },
    [2095] = { x = 0.515362, y = 0.402140, mapId = 1555 },
    [5593] = { x = 0.634273, y = 0.361647, mapId = 1555 },
    [5610] = { x = 0.536126, y = 0.483603, mapId = 1663 },
    [5603] = { x = 0.442338, y = 0.593536, mapId = 1663 },
    [5624] = { x = 0.163338, y = 0.722038, mapId = 1555 },
    [5611] = { x = 0.140581, y = 0.744353, mapId = 1555 },
    [5600] = { x = 0.597951, y = 0.688647, mapId = 1555 },
    [5636] = { x = 0.619634, y = 0.421086, mapId = 1608 },
    [5604] = { x = 0.233063, y = 0.580242, mapId = 1555 },
    [5589] = { x = 0.661429, y = 0.606857, mapId = 1626 },
    [5596] = { x = 0.415833, y = 0.681737, mapId = 1555 },
    [5609] = { x = 0.398502, y = 0.669980, mapId = 1555 },
    [5599] = { x = 0.405878, y = 0.636346, mapId = 1555 },
    [5594] = { x = 0.486468, y = 0.560137, mapId = 1555 },
    [5605] = { x = 0.539119, y = 0.496425, mapId = 1555 },
    [6680] = { x = 0.152182, y = 0.379917, mapId = 1887 },
    [6599] = { x = 0.200514, y = 0.360611, mapId = 1887 },
    [6501] = { x = 0.200514, y = 0.360611, mapId = 1887 },
    [6744] = { x = 0.288144, y = 0.287886, mapId = 1887 },
    [6525] = { x = 0.453054, y = 0.280020, mapId = 1887 },
    [6703] = { x = 0.495724, y = 0.254401, mapId = 1887 },
    [6685] = { x = 0.589939, y = 0.277009, mapId = 1887 },
    [6527] = { x = 0.621130, y = 0.265307, mapId = 1887 },
    [6510] = { x = 0.618903, y = 0.288190, mapId = 1887 },
    [6704] = { x = 0.672452, y = 0.281419, mapId = 1887 },
    [6681] = { x = 0.571261, y = 0.371472, mapId = 1887 },
    [6687] = { x = 0.646823, y = 0.423377, mapId = 1887 },
    [6702] = { x = 0.674723, y = 0.414453, mapId = 1887 },
    [6739] = { x = 0.732614, y = 0.388840, mapId = 1887 },
    [6678] = { x = 0.540459, y = 0.454181, mapId = 1887 },
    [6584] = { x = 0.539175, y = 0.460165, mapId = 1887 },
    [6679] = { x = 0.640344, y = 0.641992, mapId = 1887 },
    [6731] = { x = 0.594972, y = 0.670835, mapId = 1887 },
    [6583] = { x = 0.705187, y = 0.783722, mapId = 1887 },
    [6619] = { x = 0.634263, y = 0.851212, mapId = 1887 },
    [6700] = { x = 0.633988, y = 0.814785, mapId = 1887 },
    [6581] = { x = 0.637692, y = 0.798354, mapId = 1887 },
    [6582] = { x = 0.484026, y = 0.482462, mapId = 1887 },
    [6747] = { x = 0.431712, y = 0.405576, mapId = 1887 },
    [6684] = { x = 0.361126, y = 0.448363, mapId = 1887 },
    [6585] = { x = 0.177345, y = 0.414021, mapId = 1887 },
    [6746] = { x = 0.199163, y = 0.437141, mapId = 1887 },
    [6528] = { x = 0.183815, y = 0.464224, mapId = 1887 },
    [6532] = { x = 0.169842, y = 0.472810, mapId = 1887 },
    [6725] = { x = 0.208920, y = 0.504534, mapId = 1887 },
    [6675] = { x = 0.235049, y = 0.638921, mapId = 1887 },
    [2805] = { x = 0.372253, y = 0.713632, mapId = 1887 },
    [6509] = { x = 0.374215, y = 0.609844, mapId = 1887 },
    [6706] = { x = 0.368705, y = 0.603517, mapId = 1887 },
    [6692] = { x = 0.503281, y = 0.161338, mapId = 1887 },
    [3255] = { x = 0.677258, y = 0.251429, mapId = 1887 },
    [6734] = { x = 0.559569, y = 0.355475, mapId = 1887 },
    [6733] = { x = 0.192627, y = 0.491687, mapId = 1887 },
    [6580] = { x = 0.344675, y = 0.542213, mapId = 2018 },
    [6753] = { x = 0.357896, y = 0.528409, mapId = 2018 },
    [6531] = { x = 0.647697, y = 0.427349, mapId = 2018 },
    [6750] = { x = 0.291367, y = 0.368374, mapId = 1940 },
    [6529] = { x = 0.402647, y = 0.455640, mapId = 1940 },
    [6696] = { x = 0.231896, y = 0.463927, mapId = 1940 },
    [798]  = { x = 0.180146, y = 0.577597, mapId = 1940 },
    [815]  = { x = 0.161728, y = 0.580239, mapId = 1940 },
    [6108] = { x = 0.230594, y = 0.603844, mapId = 1940 },
    [6598] = { x = 0.265921, y = 0.694162, mapId = 1940 },
    [6735] = { x = 0.719510, y = 0.408330, mapId = 1940 },
    [6600] = { x = 0.849141, y = 0.691114, mapId = 1940 },
    [6530] = { x = 0.882857, y = 0.661951, mapId = 1940 },
    [6686] = { x = 0.644157, y = 0.867743, mapId = 1940 },
}

-- Automatic indexing table
SLP.MapIndex = {}

local function BuildMapIndex()
    for bookId, coords in pairs(SLP.BookCoordinates) do
        local mId = coords.mapId
        if mId then
            SLP.MapIndex[mId] = SLP.MapIndex[mId] or {}
            SLP.MapIndex[mId][bookId] = coords
        end
    end
end

-- Layout callback function
local function PinLayoutCallback()
    if not LibMapPins then return end

    if LibMapPins.RemovePins then
        LibMapPins:RemovePins(SLP.pinType)
    end

    if not SLP.db.enabled then return end

    local currentMapId = GetCurrentMapId()
    local mapBooks = SLP.MapIndex[currentMapId]
    if not mapBooks then return end

    -- Apply current saved settings to the layout dynamically
    SLP.pinLayout.texture = SLP.db.iconTexture
    SLP.pinLayout.size = SLP.db.pinSize

    for bookId, coords in pairs(mapBooks) do
        if coords.x > 0 and coords.y > 0 then
            local isCollected = false
            local success, cat, col, idx = pcall(GetLoreBookIndicesFromBookId, bookId)
            if success and cat and col and idx then
                local _, _, known = GetLoreBookInfo(cat, col, idx)
                if known then
                    isCollected = true
                end
            end

            if not isCollected then
                LibMapPins:CreatePin(SLP.pinType, tostring(bookId), coords.x, coords.y)
            end
        end
    end
end

-- Setup LibAddonMenu Panel
local function CreateSettingsPanel()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelData = {
        type = "panel",
        name = "Specific Lorebook Pins",
        displayName = "|c00FF00Specific Lorebook Pins|r",
        author = "You",
        version = "1.2",
        registerForRefresh = true,
    }

    LAM:RegisterAddonPanel("SpecificLorebookPinsOptions", panelData)

    local optionsData = {
        {
            type = "header",
            name = "General Settings",
        },
        {
            type = "checkbox",
            name = "Enable All Pins",
            tooltip = "Globally show or hide all custom lorebook pins.",
            getFunc = function() return SLP.db.enabled end,
            setFunc = function(value)
                SLP.db.enabled = value
                LibMapPins:RefreshPins(SLP.pinType)
            end,
        },
        {
            type = "dropdown",
            name = "Pin Icon",
            tooltip = "Choose the icon style displayed on your map.",
            choices = { 
                "Hostile Pin (Red Dot)", 
                "lorelibrary_scroll", 
                "POI Pin (Eye)" 
            },
            choicesValues = { 
                "/esoui/art/mappins/hostile_pin.dds", 
                "/esoui/art/lorelibrary/lorelibrary_scroll.dds", 
                "/esoui/art/mappins/poi_complete.dds" 
            },
            getFunc = function() return SLP.db.iconTexture end,
            setFunc = function(value)
                SLP.db.iconTexture = value
                LibMapPins:RefreshPins(SLP.pinType)
            end,
        },
        {
            type = "slider",
            name = "Pin Size",
            tooltip = "Adjust the size of the lorebook pins on the map.",
            min = 16,
            max = 64,
            step = 2,
            getFunc = function() return SLP.db.pinSize end,
            setFunc = function(value)
                SLP.db.pinSize = value
                LibMapPins:RefreshPins(SLP.pinType)
            end,
        },
    }

    LAM:RegisterOptionControls("SpecificLorebookPinsOptions", optionsData)
end

-- AddOn Initialization
function SLP.Initialize(event, addonName)
    if addonName ~= SLP.name then return end
    EVENT_MANAGER:UnregisterForEvent(SLP.name, EVENT_ADD_ON_LOADED)

    SLP.db = ZO_SavedVars:NewAccountWide("SLP_SavedVariables", 1, nil, SLP.default)

    BuildMapIndex()

    if LibMapPins then
        LibMapPins:AddPinType(SLP.pinType, PinLayoutCallback, nil, SLP.pinLayout)
        LibMapPins:SetEnabled(SLP.pinType, true)
        
        EVENT_MANAGER:RegisterForEvent(SLP.name, EVENT_LORE_BOOK_LEARNED, function()
            LibMapPins:RefreshPins(SLP.pinType)
        end)
        
        CreateSettingsPanel()
    end
end

EVENT_MANAGER:RegisterForEvent(SLP.name, EVENT_ADD_ON_LOADED, SLP.Initialize)