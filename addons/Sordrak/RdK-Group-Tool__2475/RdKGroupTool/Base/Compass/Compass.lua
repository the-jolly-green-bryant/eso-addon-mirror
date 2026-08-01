-- RdK Group Tool Compass
-- By @s0rdrak (PC / EU)

RdKGTool = RdKGTool or {}

RdKGTool.compass = RdKGTool.compass or {}

local RdKGToolCompass = RdKGTool.compass

RdKGTool.menu = RdKGTool.menu or {}
local RdKGToolMenu = RdKGTool.menu


function RdKGToolCompass.Initialize()
	RdKGToolCompass.yacs.Initialize()
	RdKGToolCompass.sc.Initialize()
end

function RdKGToolCompass.SlashCmd(param)

end

function RdKGToolCompass.GetMenu()
	local menu = {
		[1] = {
			type = "header",
			name = RdKGToolMenu.constants.COMPASS_HEADER,
			width = "full",
		},
	}
	RdKGToolMenu.AddMenuEntries(menu, RdKGToolCompass.yacs.GetMenu())
	RdKGToolMenu.AddMenuEntries(menu, RdKGToolCompass.sc.GetMenu())
	return menu
end

function RdKGToolCompass.GetDefaults()
	local defaults = {}
	defaults.yacs = RdKGToolCompass.yacs.GetDefaults()
	defaults.sc = RdKGToolCompass.sc.GetDefaults()
	return defaults
end