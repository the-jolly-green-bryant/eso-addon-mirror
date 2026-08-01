local MPBS = {
    name = "MrPancakesBiteSites",
    version = "1.0",
    author = "@TheMrPancake"
}

local LAM = LibAddonMenu2
local LMP = LibMapPins

local addonName = MPBS.name
local PIN = "MrPancakesBiteSitesPIN"

local pinTextures = {
    [1] = "MrPancakesBiteSites/Icons/fangs_white.dds", -- made by me
    [2] = "MrPancakesBiteSites/Icons/fangs_black.dds", -- made by me
    [3] = "esoui/art/armory/buildicons/buildicon_44.dds",
    [4] = "esoui/art/icons/poi/poi_camp_complete.dds",
    [5] = "esoui/art/icons/poi/poi_camp_incomplete.dds"
}

local pinColor
local savedVariables
local x,y
local defaults = {
    pin = {
        enabled = true,
        type = "MrPancakesBiteSites/Icons/fangs_white.dds",
        size = 25,
        level = 60,
        hex = "ffffff",
        range = 10,
        hide_at_stage_4 = true,
        hide_at_stage_3 = false
    }
}

biteSiteData = {

    ["cyrodiil"] = {
        ["ava_whole"] = {
            [1] = { -- imperial camp
                [1] = 0.239,
                [2] = 0.237,
                [3] = 1
            },
            [2] = { -- house
                [1] = 0.242,
                [2] = 0.396,
                [3] = 2
            },
            [3] = { -- imperial camp
                [1] = .270,
                [2] = .135,
                [3] = 1
            },
            [4] = { -- imperial camp
                [1] = .316,
                [2] = .199,
                [3] = 1  
            },
            [5] = { -- imperial camp
                [1] = .424,
                [2] = .156,
                [3] = 1 
            },
            [6] = { -- imperial camp 
                [1] = .411,
                [2] = .104,
                [3] = 1
            },
            [7] = { -- imperial camp
                [1] = .582,
                [2] = .198,
                [3] = 1
            },
            [8] = { -- house {.789,.273,140},
                [1] = .789,
                [2] = .273,
                [3] = 2
            },
            [9] = { -- imperial camp {.786,.29,140},
                [1] = .786,
                [2] = .290,
                [3] = 1
            },
            [10] = { -- imperial camp {.682,.287,140},
                [1] = .682,
                [2] = .287,
                [3] = 1
            },
            [11] = { -- imperial camp {.649,.374,2778},
                [1] = .649,
                [2] = .374,
                [3] = 1
            },
            [12] = { -- imperial camp {.619,.408,2778},
                [1] = .619,
                [2] = .408,
                [3] = 1
            },
            [13] = { -- imperial camp {.573,.441,2778},
                [1] = .573,
                [2] = .441,
                [3] = 1
            },
            [14] = { -- imperial camp {.599,.356,2778},
                [1] = .599,
                [2] = .356,
                [3] = 1
            },
            [15] = { -- imperial camp {.61,.48,140},
                [1] = .610,
                [2] = .480,
                [3] = 1
            },
            [16] = { -- black dagger camp {.639,.535,140},
                [1] = .639,
                [2] = .535,
                [3] = 1
            },
            [17] = { -- imperial camp {.721,.456,2778},
                [1] = .721,
                [2] = .456,
                [3] = 1
            },
            [18] = { -- imperial camp {.716,.417,2778},
                [1] = .716,
                [2] = .417,
                [3] = 1
            },
            [19] = { -- imperial camp {.786,.396,2778},
                [1] = .786,
                [2] = .396,
                [3] = 1
            },
            [20] = { -- imperial camp {.814,.5,140},
                [1] = .814,
                [2] = .500,
                [3] = 1
            },
            [21] = { -- imperial camp {.852,.446,2778},
                [1] = .852,
                [2] = .446,
                [3] = 1
            },
            [22] = { -- imperial camp {.768,.64,140},
                [1] = .768,
                [2] = .64,
                [3] = 1
            },
            [23] = { -- house {.715,.668,140},
                [1] = .715,
                [2] = .668,
                [3] = 2
            },
            [24] = { -- imperial camp {.703,.708,2778},
                [1] = .703,
                [2] = .708,
                [3] = 1
            },
            [25] = { -- clearwater dock {.515,.822,2778},
                [1] = .515,
                [2] = .822,
                [3] = 3
            },
            [26] = { -- imperial camp {.495,.801,140},
                [1] = .495,
                [2] = .801,
                [3] = 1
            },
            [27] = { -- lowland camp {.481,.797,140},
                [1] = .481,
                [2] = .797,
                [3] = 1
            },
            [28] = { -- imperial camp {.38,.74,140},
                [1] = .380,
                [2] = .740,
                [3] = 1
            },
            [29] = { -- imperial camp {.328,.799,2778},
                [1] = .328,
                [2] = .799,
                [3] = 1
            },
            [30] = { -- nornalhorst ruins {.317,.71,140},
                [1] = .317,
                [2] = .799,
                [3] = 0
            },
            [31] = { -- imperial camp {.277,.667,2778},
                [1] = .277,
                [2] = .667,
                [3] = 1
            },
            [32] = { -- gray viper camp {.461,.614,140},
                [1] = .461,
                [2] = .614,
                [3] = 1
            },
            [33] = { -- imperial camp {.255,.602,2778},
                [1] = .255,
                [2] = .602,
                [3] = 1
            },
            [34] = { -- imperial camp {.263,.527,2778},
                [1] = .263,
                [2] = .527,
                [3] = 1
            },
            [35] = { -- imperial camp {.29,.443,2778},
                [1] = .290,
                [2] = .443,
                [3] = 1
            },
            [36] = { -- imperial camp {.236,.308,140},
                [1] = .236,
                [2] = .308,
                [3] = 1
            },
            [37] = { -- imperial camp {.32,.345,140},
                [1] = .320,
                [2] = .345,
                [3] = 1
            },
            [38] = { -- black dagger camp {.463,.318,140}, 
                [1] = .463,
                [2] = .318,
                [3] = 1
            },
            [39] = { -- imperial camp {.527,.255,140},
                [1] = .527,
                [2] = .255,
                [3] = 1
            },
            [40] = { -- tundra ravagers {.54,.174,2778},
                [1] = .54,
                [2] = .174,
                [3] = 1
            },
            [41] = { -- imperial camp {.489,.317,140},
                [1] = .489,
                [2] = .317,
                [3] = 1
            },
            [42] = { -- imperial camp {.434,.341,140},
                [1] = .434,
                [2] = .341,
                [3] = 1
            },
            [43] = { -- imperial camp {.389,.404,140},
                [1] = .389,
                [2] = .404,
                [3] = 1
            },
            [44] = { -- imperial camp {.403,.485,2778},
                [1] = .403,
                [2] = .485,
                [3] = 1
            },
            [45] = { -- imperial camp {.442,.526,140},
                [1] = .442,
                [2] = .526,
                [3] = 1
            },
            [46] = { --homestead camp {.479,.537,140},
                [1] = .479,
                [2] = .537,
                [3] = 1
            },
            [47] = { -- imperial camp {.506,.581,2778},
                [1] = .506,
                [2] = .581,
                [3] = 1
            },
            [48] = { -- sardavar ruins {.529,.577,140},
                [1] = .529,
                [2] = .577,
                [3] = 0
            },
            [49] = { -- imperial camp {.612,.564,68},
                [1] = .612,
                [2] = .564,
                [3] = 1
            },
            [50] = { -- river watch lighthouse {.582,.661,68},
                [1] = .582,
                [2] = .661,
                [3] = 1
            },
            [51] = { -- imperial camp {.405,.612,2778},
                [1] = .407,
                [2] = .612,
                [3] = 1
            },
            [52] = { -- imperial camp/shadowed path camp {.363,.695,68},
                [1] = .363,
                [2] = .695,
                [3] = 1
            },
            [53] = { -- imperial camp {.365,.639,2778},
                [1] = .365,
                [2] = .639,
                [3] = 1
            },
            [54] = { -- imperial camp {.344,.573,68},
                [1] = .344,
                [2] = .573,
                [3] = 1
            },
            [55] = { -- shadowed path camp {.317,.562,0},
                [1] = .317,
                [2] = .562,
                [3] = 1
            },
            [56] = { -- black dagger village {.172,.476,140},
                [1] = .172,
                [2] = .476,
                [3] = 1
            },
            [57] = { -- imperial camp {.195,.447,140},
                [1] = .195,
                [2] = .447,
                [3] = 1
            },
            [58] = { -- imperial camp within a mountain {.206,.432,68},
                [1] = .206,
                [2] = .432,
                [3] = 1
            },
            [59] = { -- black dagger camp {.145,.401,140},
                [1] = .145,
                [2] = .401,
                [3] = 1
            },
            [60] = { -- black dagger house {.128,.385,140},
                [1] = .128,
                [2] = .385,
                [3] = 2
            },
            [61] = { -- imperial camp {.116,.342,140},
                [1] = .116,
                [2] = .342,
                [3] = 1
            },
            [62] = { -- bloodborne camp {.159,.244,68},
                [1] = .159,
                [2] = .244,
                [3] = 1
            },
            [63] = { -- imperial camp {.174,.234,140},
                [1] = .174,
                [2] = .234,
                [3] = 1
            },
            [64] = { -- imperial camp {.72,.582,140},
                [1] = .720,
                [2] = .582,
                [3] = 1
            },
            [65] = { -- bloodborn camp {.358,.225,68}, 
                [1] = .358,
                [2] = .225,
                [3] = 1
            },
            [66] = { -- hearteater camp {.388,.205,0},
                [1] = .388,
                [2] = .205,
                [3] = 1
            },
            [67] = { -- imperial camp {.589,.226,140},
                [1] = .589,
                [2] = .226,
                [3] = 1
            },
            [68] = { -- black dagger camp {.288,.494,140},
                [1] = .288,
                [2] = .494,
                [3] = 1
            },
            [69] = { -- imperial camp {.445,.233,140},
                [1] = .445,
                [2] = .233,
                [3] = 1
            },
            [70] = { -- tower {.195,.309,140},
                [1] = .195,
                [2] = .309,
                [3] = 2
            },
            [71] = { -- imperial camp {.432,.167,140},
                [1] = .432,
                [2] = .167,
                [3] = 1
            },
            [72] = { -- imperial camp {.427,.665,140},
                [1] = .427,
                [2] = .665,
                [3] = 1
            },
            [73] = { -- clearwater npcs {.308,.618,140},
                [1] = .308,
                [2] = .618,
                [3] = 1
            },
            [74] = { -- imperial camp {.541,.243,140},
                [1] = .541,
                [2] = .243,
                [3] = 1
            },
            [75] = { -- imperial camp {.709,.123,140},
                [1] = .709,
                [2] = .123,
                [3] = 1
            },
            [76] = { -- imperial camp {.147,.367,0},
                [1] = .147,
                [2] = .367,
                [3] = 1
            },
            [77] = { -- imperial camp {.569,.69,0},
                [1] = .569,
                [2] = .69,
                [3] = 1
            },
            [78] = { -- imperial camp {.668,.496,0},
                [1] = .668,
                [2] = .496,
                [3] = 1
            },
            [79] = { -- imperial camp {.476,.743,68},
                [1] = .476,
                [2] = .743,
                [3] = 1
            },
            [80] = { -- imperial camp {.846,.244,0},
                [1] = .846,
                [2] = .244,
                [3] = 1
            },
            [81] = { -- imperial camp {.584,.621,68},
                [1] = .584,
                [2] = .621,
                [3] = 1
            },
            [82] = { -- imperial camp {.442,.673,68},
                [1] = .442,
                [2] = .673,
                [3] = 1
            },
            [83] = { -- black dagger camp {.758,.347,56},
                [1] = .758,
                [2] = .347,
                [3] = 1
            }
        }
    }
}

local function CreateSettingsMenu()
    local panelData = {
        type = "panel",
        name = "MrPancake's Bite Sites", -- sidebar name
        displayName = "|cFE3F3FMRPANCAKE'S BITE SITES|r", -- top name
        author = MPBS.author,
        version = MPBS.version,
        registerForRefresh = true,
        registerForDefaults = true
    }

    LAM:RegisterAddonPanel(MPBS.name, panelData)
    local optionsTable = {
        { type = "checkbox", name = "Enable Addon", tooltip = "Visibility toggle.", getFunc = function() return savedVariables.pin.enabled end, setFunc = function(value) savedVariables.pin.enabled = value LMP:SetEnabled(PIN, value) end, default = defaults.pin.enabled },
        { type = "divider"},
        { type = "iconpicker", name = "Pin Icon", tooltip = "Map pin icon selector.", maxColumns = 7, choices = pinTextures, visibleRows = 2, getFunc = function() return savedVariables.pin.type end, setFunc = function(value) savedVariables.pin.type = value LMP:SetLayoutKey(PIN, "texture", value) LMP:RefreshPins(PIN) end, default = defaults.pin.type },
        { type = "colorpicker", name = "Pin Colour", tooltip = "Map pin tint colour. Affects the white parts of the icon.", getFunc = function() return pinColor:UnpackRGBA() end, setFunc = function(...) pinColor:SetRGBA(...) savedVariables.pin.hex = pinColor:ToHex() LMP:RefreshPins() end, default = ZO_SELECTED_TEXT},
        { type = "divider"},
        { type = "slider", name = "Pin Size", tooltip = "Map pin display size.", min = 20, max = 70, step = 1, getFunc = function() return savedVariables.pin.size end, setFunc = function(value) savedVariables.pin.size = value LMP:SetLayoutKey(PIN, "size", value) LMP:RefreshPins(PIN) end, default = defaults.pin.size },
        { type = "slider", name = "Pin Level", tooltip = "Map pin display level.", min = 10, max = 150, step = 5, getFunc = function() return savedVariables.pin.level end, setFunc = function(value) savedVariables.pin.level = value LMP:SetLayoutKey(PIN, "level", value) LMP:RefreshPins(PIN) end, default = defaults.pin.level },
        { type = "slider", name = "Pin Display Range", tooltip = "Display range of map pins. Higher values show more pins exponentially.", min = 5, max = 100, step = 1, getFunc = function() return savedVariables.pin.range end, setFunc = function(value) savedVariables.pin.range = value LMP:SetLayoutKey(PIN, "range", value) LMP:RefreshPins(PIN) end, default = defaults.pin.range },
        { type = "divider"},
        { type = "checkbox", name = "Hide Pins at Stage 3", tooltip = "Hides pins when you are at stage 3 vampirism.", getFunc = function() return savedVariables.pin.hide_at_stage_3 end, setFunc = function(value) savedVariables.pin.hide_at_stage_3 = value LMP:RefreshPins(PIN) end, default = defaults.pin.hide_at_stage_3 },
        { type = "checkbox", name = "Hide Pins at Stage 4", tooltip = "Hides pins when you are at stage 4 vampirism.", getFunc = function() return savedVariables.pin.hide_at_stage_4 end, setFunc = function(value) savedVariables.pin.hide_at_stage_4 = value LMP:RefreshPins(PIN) end, default = defaults.pin.hide_at_stage_4 },
    }
    LAM:RegisterOptionControls(MPBS.name, optionsTable)
end

local function GetLocalData(zone, subzone)
    if type(zone) == "string" and type(subzone) == "string" and biteSiteData[zone] and biteSiteData[zone][subzone] then
        return biteSiteData[zone][subzone]
    end
end

local function PinCallback()
    if not LMP:IsEnabled(PIN) or (GetMapType() > MAPTYPE_ZONE) then return end
    if not IsPlayerActivated() then return end

    local zone, subzone = LMP:GetZoneAndSubzone()
    local data = GetLocalData(zone, subzone)

    x,y = GetMapPlayerPosition("player")
    local biteSiteRange = savedVariables.pin.range / 100.0

    local numBuffs = GetNumBuffs("player")
    local IS_STAGE_4 = false
    local IS_STAGE_3 = false

    if numBuffs > 0 then
        for i = 1, numBuffs do
            local _, _, _, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo('player', i)
            if abilityId == 135402 then -- stage 4 vampirism id
                IS_STAGE_4 = true
            end
            if abilityId == 135400 then -- stage 3 vampirism id
                IS_STAGE_3 = true
            end
        end
    end

    if IS_STAGE_4 and savedVariables.pin.hide_at_stage_4 then return end
    if IS_STAGE_3 and savedVariables.pin.hide_at_stage_3 then return end

    if data ~= nil then
        for _, pinData in ipairs(data) do
            if ((pinData[1] - x)^2  +  (pinData[2] - y)^2)  <  (biteSiteRange^2) then -- circular shape
                LMP:CreatePin(PIN, pinData, pinData[1], pinData[2])
            end
        end
    end
end

local function RegisterEvents()
    WORLD_MAP_SCENE:UnregisterCallback("StateChange")
	WORLD_MAP_SCENE:RegisterCallback("StateChange", function(oldState, newState) 
        if newState==SCENE_SHOWING then -- successfully runs whenever opening map 
            x,y = GetMapPlayerPosition("player")
            LMP:RefreshPins(PIN)
        end
    end)
end

local function Init(event, name)
    if name ~= addonName then return end
    savedVariables = ZO_SavedVars:NewCharacterNameSettings("MrPancakesBiteSites_SavedVariables", 1, nil, defaults)

    pinColor = ZO_ColorDef:New(savedVariables.pin.hex)
    local layout = {
        level = savedVariables.pin.level,
        texture = savedVariables.pin.type,
        size = savedVariables.pin.size,
        tint = pinColor
    }
    LMP:AddPinType(PIN, PinCallback, nil, layout, nil)
    CreateSettingsMenu()
    RegisterEvents()

    EVENT_MANAGER:UnregisterForEvent(addonName, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(addonName, EVENT_ADD_ON_LOADED, Init)
