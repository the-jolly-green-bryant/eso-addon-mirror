NowTalking = {}
 
NowTalking.name = "NowTalking"

local LAM = LibStub('LibAddonMenu-2.0')
local SV = nil

-- Shamelessly stolen from pChat
local function getCol(string)
	local r=tonumber(string.sub(string, 3, 4), 16)
	local g=tonumber(string.sub(string, 5, 6), 16)
	local b=tonumber(string.sub(string, 7, 8), 16)
	
	-- In case of malformed strings
	r = r or 255
	g = g or 255
	b = b or 255
	
	return r/255, g/255, b/255, 1
end

local function d2h(n)
    local str = "0123456789abcdef"
    local l = string.sub(str, math.floor(n/16)+1, math.floor(n/16)+1)
    local r = string.sub(str, n%16 + 1, n%16 + 1)
    return l..r
end

local function setCol(r, g, b)
    r = math.floor(255*r)
    g = math.floor(255*g)
    b = math.floor(255*b)
    return "|c"..d2h(r)..d2h(g)..d2h(b)
end
 
function NowTalking:Initialize()
    local defaults = { ["colour"] = "|c417dc1" }

    SV = ZO_SavedVars:NewAccountWide('NowTalking_SavedVariables', 1, nil, defaults)

	local panelData = {
		type = "panel",
		name = "NowTalking",
		displayName = "NowTalking",
		author = "@nooblybear",
		version = "1.0.3",
		slashCommand = "/nowt",
		registerForRefresh = true,
		registerForDefaults = true,
	}

    local optionsTable = {
        [1] = {
            type = "colorpicker",
            name = "Alert colour",
            tooltip = "Colour of zone change alert.", 
            getFunc = function() return getCol(SV.colour) end,
            setFunc = function(r, g, b) SV.colour = setCol(r, g, b) end,
            default = getCol(defaults.colour)
        }
    }
	
	LAM:RegisterAddonPanel("NowTalkingOptions", panelData)
	LAM:RegisterOptionControls("NowTalkingOptions", optionsTable)

    EVENT_MANAGER:RegisterForEvent(NowTalking.name, EVENT_PLAYER_ACTIVATED, NowTalking.OnPlayerActivated)
end

function NowTalking.OnPlayerActivated(...)
    CHAT_SYSTEM:AddMessage(SV.colour .. "[Now talking in " .. GetUnitZone("player") .. " zone chat.]")
end
 
function NowTalking.OnAddOnLoaded(event, addonName)
    if addonName == NowTalking.name then
        NowTalking:Initialize()
    end
end
 
EVENT_MANAGER:RegisterForEvent(NowTalking.name, EVENT_ADD_ON_LOADED, NowTalking.OnAddOnLoaded)
