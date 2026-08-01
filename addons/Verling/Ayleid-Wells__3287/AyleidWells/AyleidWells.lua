local LMP         = LibMapPins
local ADDON_NAME  = "AyleidWells"
local AW_ICO      = "AyleidWells/awpic.dds"
local AW_ICO_D    = "AyleidWells/awpic_d.dds"

local AW_LAYOUT  = {
    level   = 50,
    size    = 25,
    texture = AW_ICO,
}
local AW_TOOLTIP = {
    tooltip = ZO_MAP_TOOLTIP_MODE.INFORMATION,
    creator = function( pin )
        InformationTooltip:AddLine( "Ayleid Well" )
    end,
}
local AW_DATA    = {
    ["auridon/auridon_base"] = {                 -- +
        { x = 0.5017, y = 0.7417 },
        { x = 0.6870, y = 0.6318 },              -- 2
    },
    ["cyrodiil/ava_whole"] = {                   -- +
        { x = 0.1854, y = 0.4076 },
        { x = 0.2614, y = 0.6707 },
        { x = 0.3325, y = 0.7289 },
        { x = 0.3610, y = 0.3613 },
        { x = 0.3832, y = 0.5302 },
        { x = 0.3923, y = 0.6916 },
        { x = 0.4380, y = 0.2109 },
        { x = 0.4610, y = 0.2394 },
        { x = 0.4658, y = 0.7643 },
        { x = 0.5054, y = 0.7613 },
        { x = 0.6215, y = 0.7929 },
        { x = 0.6253, y = 0.5077 },
        { x = 0.6277, y = 0.4447 },
        { x = 0.6383, y = 0.6508 },
        { x = 0.6585, y = 0.6944 },
        { x = 0.7062, y = 0.5809 },              -- 18
    },
    ["bangkorai/bangkorai_base"] = {
        { x = 0.3090, y = 0.6139 },
    },
    ["glenumbra/betnihk_base"] = {               -- +
        { x = 0.3958, y = 0.2873 },              
    },
    ["glenumbra/glenumbra_base"] = {               
        { x = 0.2744, y = 0.6873 },              
    },
    ["glenumbra/silumm_base"] = {               
        { x = 0.3568, y = 0.7298 },              
    },
    ["malabaltor/blackvineruins_base"] = {
        { x = 0.5510, y = 0.2428 },
    },
    ["greenshade/caracdena_base"] = {
        { x = 0.6026, y = 0.6327 },
    },
    ["coldharbor/coldharbour_base"] = {          -- +
        { x = 0.3576, y = 0.5062 },        
        { x = 0.3742, y = 0.7132 },        
    },
    ["craglorn/craglorn_base"] = {               -- +
        { x = 0.7588, y = 0.5752 },
    },
    ["reapersmarch/fardirsfolly_base"] = {
        { x = 0.7348, y = 0.2899 },
    },
    ["shadowfen/gandranen_base"] = {             -- +
        { x = 0.7738, y = 0.6073 },
    },
    ["darkbrotherhood/goldcoast_base"] = {       -- +
        { x = 0.1682, y = 0.4225 },
        { x = 0.6144, y = 0.3740 },              -- 30
    },
    ["grahtwood/grahtwood_base"] = {             -- +
        { x = 0.4915, y = 0.2454 },
        { x = 0.6610, y = 0.3467 },
    },
    ["greenshade/greenshade_base"] = {           -- +
        { x = 0.3764, y = 0.4732 },
    },
    ["malabaltor/malabaltor_base"] = {           -- +
        { x = 0.5079, y = 0.6911 },
        { x = 0.5756, y = 0.7479 },              
    },
    ["bangkorai/nilataruins_base"] = {
        { x = 0.6504, y = 0.4597 },
    },
    ["stormhaven/norvulkruins_base"] = {
        { x = 0.6302, y = 0.6827 },
    },
    ["rivenspire/orcsfingerruins_base"] = {      -- +
        { x = 0.6410, y = 0.6908 },
    },
    ["reapersmarch/reapersmarch_base"] = {       -- +
        { x = 0.3969, y = 0.7216 },              -- 40 
    },
    ["bangkorai/rubblebutte_base"] = {
        { x = 0.6547, y = 0.4605 },
    },
    ["shadowfen/shadowfen_base"] = {             -- +
        { x = 0.4097, y = 0.2831 },
    },
    ["shadowfen/stormhold_base"] = {             -- +
        { x = 0.2232, y = 0.5629 },
    },
    ["blackwood/blackwood_base"] = {             -- +
        { x = 0.3351792693, y = 0.6328297853 },
        { x = 0.6207196712, y = 0.7159832715 },
        { x = 0.4226815402, y = 0.4672343432 },
        { x = 0.4413733482, y = 0.1940076649 },
    },
    ["blackwood/vunalk2_base"] = {
        { x = 0.7836887240, y = 0.2897340059 },  -- 48
    }
                }

EVENT_MANAGER:RegisterForEvent( ADDON_NAME, EVENT_ADD_ON_LOADED, function( _, addonName )
	if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent( ADDON_NAME, EVENT_ADD_ON_LOADED )
    local store = ZO_SavedVars:New( "AWSet", 1, nil, { showWells = true } )
    local pinId = LMP:AddPinType( ADDON_NAME, function( pinManager )
        local mapName = LMP:GetZoneAndSubzone( true )
        local pins    = AW_DATA[mapName]
---        CHAT_SYSTEM:AddMessage(mapName.. "==<map<zone==")
        if pins then
            for _, pinInfo in ipairs( pins ) do
                LMP:CreatePin( ADDON_NAME, pinInfo, pinInfo.x, pinInfo.y )
            end
        end
    end, nil, AW_LAYOUT, AW_TOOLTIP )
    LMP:AddPinFilter( pinId, "|t24:24:" .. AW_ICO .. "|t Ayleid Wells", false, store, "showWells" )
end )
