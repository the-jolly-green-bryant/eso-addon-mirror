local LAM2 = LibAddonMenu2

local colorYellow       = "|cFFFF00"    -- yellow 
local colorRed          = "|cFF0000"    -- Red

--===================================--
--=====   Settings Menu   ===========--
--===================================--
function PvPRanks.CreateSettingsMenu()
    local panelData = {
        type = "panel",
        name = "PvPRanks",
        displayName = "|cFF0000 PvP Ranks and Veterancy",
        author = "Circonian, ForgottenLight, Sufia_Heolcyn",
        version = "3.01",
        slashCommand = "/pvpranks",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    local cntrlOptionsPanel = LAM2:RegisterAddonPanel("Circonians_PvPRanks_Options", panelData)
    
    local optionsData = {
        [1] = {
            type = "description",
            text = colorYellow.."If you wish to submit a bug report or feature request for this updated version, please do so on the current fork's project page."
        },
        [2] = {
            type = "colorpicker",
            name = "Rank Highlight Color", 
            tooltip = "Changes the highlight color for your current PvP rank in the list.",
            -- FIXED: LAM2 specifically expects named r, g, b, a keys for its default reset action
            default = {r = 1, g = 0, b = 0, a = 1}, 
            getFunc = function() 
                if PVP_RANKS and PVP_RANKS.sv then
                    return unpack(PVP_RANKS.sv["RANK_HIGHLIGHT_COLOR"]) 
                end
                return 1, 0, 0, 1
            end,
            setFunc = function(r,g,b,a) 
                if PVP_RANKS and PVP_RANKS.sv then
                    PVP_RANKS.sv["RANK_HIGHLIGHT_COLOR"] = {r,g,b,a} 
                    if type(PVP_RANKS.UpdateRankHighlightColor) == "function" then
                        PVP_RANKS:UpdateRankHighlightColor()
                    end
                end 
            end,
        },
        [3] = {
            type = "colorpicker",
            name = "Veterancy Tracker Color", 
            tooltip = "Changes the text color for the Veterancy tracker header.",
            -- FIXED: Added named r, g, b, a keys here as well
            default = {r = 1, g = 0.8, b = 0, a = 1}, 
            getFunc = function() 
                if PVP_RANKS and PVP_RANKS.sv then
                    return unpack(PVP_RANKS.sv["VET_TRACKER_COLOR"]) 
                end
                return 1, 0.8, 0, 1
            end,
            setFunc = function(r,g,b,a) 
                if PVP_RANKS and PVP_RANKS.sv then
                    PVP_RANKS.sv["VET_TRACKER_COLOR"] = {r,g,b,a} 
                    if PVP_RANKS.vetHeader then
                        PVP_RANKS.vetHeader:SetColor(r, g, b, a)
                    end
                end 
            end,
        },
    }
    LAM2:RegisterOptionControls("Circonians_PvPRanks_Options", optionsData)
end