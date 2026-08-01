--[[
	Addon: Taos Group Tools
	Author: TProg Taonnor
	Created by @Taonnor
]]--

--[[
	Local variables
]]--
local _logger = nil

local _settingsHandler = TGT_SettingsHandler

local _panel = nil
local _options = nil
local _lamPanel = nil
local _trackedBuffs = TRACKED_BUFFS
local _abitilyChoises = nil
local _mainMenuName = "TaosGroupToolsSettingsMainMenu"

--[[
	Table SettingsWindow
]]--
TGT_SettingsWindow = {}
TGT_SettingsWindow.__index = TGT_SettingsWindow

--[[
	===============
    PRIVATE METHODS
    ===============
]]--

--[[
	Creates global options
]]--
local function CreateOptions()
    -- GetOptions methods get options and adds them directly to the table
    _options = {}
    TGT_GlobalOptions.GetOptions(_options)
    TGT_GroupUltimateOptions.GetOptions(_options)
    TGT_GroupLeaderOptions.GetOptions(_options)
    TGT_GroupInviteOptions.GetOptions(_options)
    TGT_GroupDpsHpsOptions.GetOptions(_options)
    TGT_GroupFramesOptions.GetOptions(_options)
    TGT_GroupDetoOptions.GetOptions(_options)
    TGT_GroupPurgeOptions.GetOptions(_options)
    TGT_GroupSpeedOptions.GetOptions(_options)
    TGT_GroupEarthgoreOptions.GetOptions(_options)
end

--[[
	Creates settings panel
]]--
local function CreatePanel(major, minor, patch)
    _panel = {
		type = "panel",
		name = "Taos Group Tools",
		author = "TProg Taonnor",
		version = major .. "." .. minor .. "." .. patch,
		slashCommand = "/taosGroupTools",
        registerForRefresh = true,
		registerForDefaults = true
	}
end

--[[
	==============
    PUBLIC METHODS
    ==============
]]--

--[[
	GetBuffTrackerChoises Gets buff tracker choises
]]--
function TGT_SettingsWindow.GetBuffTrackerChoises()
    if (_abitilyChoises == nil) then
        local abitilyChoises = {}

        for index, ability in ipairs(_trackedBuffs) do
            abitilyChoises[index] = zo_strformat(SI_ABILITY_TOOLTIP_NAME, GetAbilityName(ability.IconId))
        end

        _abitilyChoises = abitilyChoises
    end

    return _abitilyChoises
end

--[[
	GetBuffIndex Gets buff index on base of buff AbilityId
]]--
function TGT_SettingsWindow.GetBuffIndex(id)
    for index, ability in ipairs(_trackedBuffs) do
        if (id == ability.IconId) then
            return index
        end
    end

    return -1
end

--[[
	GetBuffId Gets buff AbilityId on base of index
]]--
function TGT_SettingsWindow.GetBuffId(index)
    if (_trackedBuffs[index] ~= nil) then
        return _trackedBuffs[index].IconId
    end

    return -1
end

--[[
	Creates new color picker and returns it
]]--
function TGT_SettingsWindow.GetNewColorpicker(part, value, labelText, labelTooltip, disabledMethod)
    return {   
        type        = "colorpicker", 
        name        = labelText,
        tooltip     = labelTooltip,
        getFunc = 
            function() 
                local color = _settingsHandler.SavedVariables.ModuleColors[part][value]
                return color.R, color.G, color.B, color.A
            end, 
        setFunc = 
            function(r,g,b,a)
                _settingsHandler.SavedVariables.ModuleColors[part][value] = { R = r, G = g, B = b, A = a }
                _settingsHandler.OnColorSettingsChanged(part)
            end, 
        default     = 
        { 
            r = TGT_DEFAULTS.ModuleColors[part][value].R, 
            g = TGT_DEFAULTS.ModuleColors[part][value].G, 
            b = TGT_DEFAULTS.ModuleColors[part][value].B, 
            a = TGT_DEFAULTS.ModuleColors[part][value].A
        },
        disabled = disabledMethod,
    }
end

--[[
	Initialize creates settings window
]]--
function TGT_SettingsWindow.Initialize(major, minor, patch)
    _logger = TGT_LOGGER

    -- Workaround: To avoid "Too many anchors processed" error; Thank you ZOS for stealing hours of my life!
    zo_callLater(function()
        CreatePanel(major, minor, patch)
        CreateOptions()
    
	    local LAM = LibStub("LibAddonMenu-2.0")
	    _lamPanel = LAM:RegisterAddonPanel(_mainMenuName, _panel)
        TGT_GroupLeaderOptions.SetLamPanel(_lamPanel)

	    LAM:RegisterOptionControls(_mainMenuName, _options)
     end, 1000)

    _logger:logTrace("TGT_SettingsWindow -> Initialized")
end