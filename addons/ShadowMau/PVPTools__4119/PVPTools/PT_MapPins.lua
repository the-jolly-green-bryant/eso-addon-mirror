-- ***** Pawprint's PVP Tools - MapPins *****


--------------------------------------------------
-- Initialize our namespace
--------------------------------------------------
if not PVPTools then PVPTools = {} end
if not PVPTools.MapPins then PVPTools.MapPins = {} end
local PT = PVPTools
local MP = PVPTools.MapPins
local LMP = LibMapPins

--------------------------------------------------
-- MAP TOOLS
--------------------------------------------------
function MP.GetLocationInformation()
	local mapName = LMP:GetZoneAndSubzone(true)
	local x, y = GetMapPlayerPosition("player") --?
	
	-- From ScrySpy
	local x_pos, y_pos = GetMapPlayerPosition("player")
	local x_gps, y_gps = GPS:LocalToGlobal(x_pos, y_pos)
	local zone_id, worldX, worldY, worldZ = GetUnitWorldPosition("player")
end