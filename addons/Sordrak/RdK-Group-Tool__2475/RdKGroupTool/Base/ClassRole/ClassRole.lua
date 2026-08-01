-- RdK Group Tool Class Role
-- By @s0rdrak (PC / EU)

RdKGTool = RdKGTool or {}
RdKGTool.classRole = RdKGTool.classRole or {}
local RdKGToolCR = RdKGTool.classRole
RdKGTool.menu = RdKGTool.menu or {}
local RdKGToolMenu = RdKGTool.menu

function RdKGToolCR.Initialize()
	RdKGToolCR.bg.tpHeal.Initialize()
end

function RdKGToolCR.GetMenu()
	local menu = {
		[1] = {
			type = "header",
			name = RdKGToolMenu.constants.CR_HEADER,
			width = "full",
		}
	}
	RdKGToolMenu.AddMenuEntries(menu, RdKGToolCR.bg.tpHeal.GetMenu())
	return menu
end

function RdKGToolCR.GetDefaults()
	local defaults = {}
	defaults.bg = {}
	defaults.bg.tpHeal = RdKGToolCR.bg.tpHeal.GetDefaults()
	return defaults
end