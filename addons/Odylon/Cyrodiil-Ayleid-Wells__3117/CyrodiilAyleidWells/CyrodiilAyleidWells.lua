local LMP         = LibMapPins
local ADDON_NAME  = "CyrodiilAyleidWells"
local PIN_ICON    = "cyrodiilayleidwells/mappin.dds"
local PIN_LAYOUT  = {
    level   = 50,
    size    = 20,
    texture = PIN_ICON,
}
local PIN_TOOLTIP = {
    tooltip = ZO_MAP_TOOLTIP_MODE.INFORMATION,
    creator = function( pin )
        InformationTooltip:AddLine( "Ayleid Well" )
    end,
}
local PIN_DATA    = {
    ["cyrodiil/ava_whole"] = {
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
        { x = 0.7062, y = 0.5809 },
    }
}
EVENT_MANAGER:RegisterForEvent( ADDON_NAME, EVENT_ADD_ON_LOADED, function( _, addonName )
	if addonName ~= ADDON_NAME then return end
	EVENT_MANAGER:UnregisterForEvent( ADDON_NAME, EVENT_ADD_ON_LOADED )
    local store = ZO_SavedVars:New( "CAWStore", 1, nil, { showWells = true } )
    local pinId = LMP:AddPinType( ADDON_NAME, function( pinManager )
        local mapName = LMP:GetZoneAndSubzone( true )
        local pins    = PIN_DATA[mapName]
        if pins then
            for _, pinInfo in ipairs( pins ) do
                LMP:CreatePin( ADDON_NAME, pinInfo, pinInfo.x, pinInfo.y )
            end
        end
    end, nil, PIN_LAYOUT, PIN_TOOLTIP )
    LMP:AddPinFilter( pinId, "|t24:24:" .. PIN_ICON .. "|t Ayleid Wells", false, store, "showWells" )
    LMP:SetPinFilterHidden( ADDON_NAME, "battleground", true )
    LMP:SetPinFilterHidden( ADDON_NAME, "imperialPvP", true )
    LMP:SetPinFilterHidden( ADDON_NAME, "pve", true )
end )