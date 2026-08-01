QAddon = {}
QAddon.name = "PapaCrown"

local function OnPlayerActivated()
SetFloatingMarkerInfo(MAP_PIN_TYPE_GROUP_LEADER, 64, "EsoUI/Art/Compass/groupleader.dds")
end

EVENT_MANAGER:RegisterForEvent("PapaCrown", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)