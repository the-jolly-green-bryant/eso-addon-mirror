local SADESD = ScreenAntiDimmer or {}

SADESD.name = "ScreenAntiDimmer"
SADESD.version = "1.0"


local MIN_HIST = 1
local MAX_HIST = 30
local STEP_HIST = 1

local function setSPV(v)
    if(v == true) then
        SetCVar("EnergySustainabilityMeasuresEnabled", "0")       
    else
        SetCVar("EnergySustainabilityMeasuresEnabled", "1")   
    end
 end

local function initializeAddon()
    
    local LAM = LibAddonMenu2
    local panelName = "ScreenAntiDimmerOptions"

    local panelData = {
        type = "panel",
        name = "Screen anti dimmer (energy safe disabler)",
        author = "@Marvell0usChester",
     }

     local optionsData = {
        {
            type = "checkbox",
            name = SADESD_ENERGY_SUSTAINABILITY_MEASURES_ENABLED,
            tooltip = SADESD_ENERGY_SUSTAINABILITY_MEASURES_ENABLED_TT,
            getFunc = function() return GetCVar("EnergySustainabilityMeasuresEnabled") end,
			setFunc = function(value) setSPV(value) end,
        },
        {
            type = "checkbox",
            name = SADESD_SKIPLOGOS,
            tooltip = SADESD_SKIPLOGOS_TT,
            getFunc = function() return GetCVar("SkipPregameVideos") == "1" end,
            setFunc = function(value) SetCVar("SkipPregameVideos", value and "1" or "0") end,
        },
        {
			type = "slider",
            name = GUILD_HISTIRY_CACHE_MAX_NUMBER_OF_DAYS,
			tooltip = GUILD_HISTIRY_CACHE_MAX_NUMBER_OF_DAYS_TT,
			min = MIN_HIST,
			max = MAX_HIST,
			step = STEP_HIST,
            warning = GUILD_HISTIRY_CACHE_MAX_NUMBER_OF_DAYS_WARN,
			getFunc = function() return GetCVar("GuildHistoryCacheMaxNumberOfDays_trader") end,
			setFunc = function(value) SetCVar("GuildHistoryCacheMaxNumberOfDays_trader", value) end,
		}
     }
     local panel = LAM:RegisterAddonPanel(panelName, panelData)
     LAM:RegisterOptionControls(panelName, optionsData)

end



function SADESD.OnLoad(event, addonName)
    if addonName ~= SADESD.name then return end
    EVENT_MANAGER:UnregisterForEvent(SADESD.name, EVENT_ADD_ON_LOADED, SADESD.OnLoad)
    initializeAddon()
  end

EVENT_MANAGER:RegisterForEvent(SADESD.name, EVENT_ADD_ON_LOADED, SADESD.OnLoad)