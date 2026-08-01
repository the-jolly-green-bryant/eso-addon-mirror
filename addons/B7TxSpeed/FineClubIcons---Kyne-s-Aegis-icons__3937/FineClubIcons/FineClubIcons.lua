-- Global definitions
FineClubIcons = FineClubIcons or {
    name = "FineClubIcons",
	author = "|c00fffe@B7TxSpeed|r",
	version = "1.0.1",
}
local EM = EVENT_MANAGER
local KA_ID = 1196

function FineClubIcons.debug(msg)
    if (FineClubIcons.savedVariables.debug) then
        d("|c88FFFF[FineClubIcons]|r " .. tostring(msg))
    end
end

local function InitSavedVariables()
    local defaults = {
        debug = false,
        kynesaegis = {
            showFalgravn1stFloorIcons = true,
            showFalgravn2ndFloorIcons = true,
            showFalgravnLightningPos = true,
            falgravnIconsSize = 150,
        },
	}
	FineClubIcons.savedVariables = ZO_SavedVars:NewAccountWide("FineClubIconsSavedVariables", 1, nil, defaults, GetWorldName())
end

function FineClubIcons.OnPlayerActivated()
    local zoneId = GetZoneId(GetUnitZoneIndex("player"))

    if (FineClubIcons.zoneId == KA_ID) then
        FineClubIcons.UnregisterKynesAegis()
    end

    if (zoneId == KA_ID) then
        FineClubIcons.RegisterKynesAegis()
    end

    FineClubIcons.zoneId = zoneId
end

local function Init(_, addon)
	if addon ~= FineClubIcons.name then return end
    
    EM:UnregisterForEvent(FineClubIcons.name.."Init", EVENT_ADD_ON_LOADED)
    
    InitSavedVariables()
	EM:RegisterForEvent(FineClubIcons.name .. "OnPlayerActivated", EVENT_PLAYER_ACTIVATED, FineClubIcons.OnPlayerActivated)
    FineClubIcons.loadMenu()
end

EM:RegisterForEvent(FineClubIcons.name.."Init", EVENT_ADD_ON_LOADED, Init)
