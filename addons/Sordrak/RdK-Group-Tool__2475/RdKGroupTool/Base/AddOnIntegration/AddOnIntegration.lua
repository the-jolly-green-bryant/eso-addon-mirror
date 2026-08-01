-- RdK AddOn Integration
-- By @s0rdrak (PC / EU)

RdKGTool = RdKGTool or {}

RdKGTool.addOnIntegration = RdKGTool.addOnIntegration or {}

local RdKGToolAOI = RdKGTool.addOnIntegration
RdKGTool.menu = RdKGTool.menu or {}
local RdKGToolMenu = RdKGTool.menu


function RdKGToolAOI.Initialize()
	--Not running Miats PvP Alerts AddOn Integration anymore as it did not really
	--fix the bug causing frame drops. Therefore, this module isn't active in any way anymore.
	--RdKGToolAOI.mpa.Initialize()
end

function RdKGToolAOI.SlashCmd(param)
	if param ~= nil then

	end
end

function RdKGToolAOI.GetMenu()
	local menu = {
		--Not active currently
		--[1] = {
		--	type = "header",
		--	name = RdKGToolMenu.constants.ADDON_INTEGRATION_HEADER,
		--	width = "full",
		--}
	}
	--RdKGToolMenu.AddMenuEntries(menu, RdKGToolAOI.mpa.GetMenu())
	return menu
end

function RdKGToolAOI.GetDefaults()
	local defaults = {}
	--defaults.mpa = RdKGToolAOI.mpa.GetDefaults()
	return defaults
end
