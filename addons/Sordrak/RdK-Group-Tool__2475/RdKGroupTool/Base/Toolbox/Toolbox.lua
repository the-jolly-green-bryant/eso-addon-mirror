-- RdK Group Tool Toolbox
-- By @s0rdrak (PC / EU)

RdKGTool = RdKGTool or {}

RdKGTool.toolbox = RdKGTool.toolbox or {}
local RdKGToolTB = RdKGTool.toolbox

RdKGTool.menu = RdKGTool.menu or {}
local RdKGToolMenu = RdKGTool.menu


function RdKGToolTB.Initialize()
	RdKGToolTB.sm.Initialize()
	RdKGToolTB.recharger.Initialize()
	RdKGToolTB.kc.Initialize()
	RdKGToolTB.bft.Initialize()
	RdKGToolTB.siege.Initialize()
	RdKGToolTB.cl.Initialize()
	RdKGToolTB.cs.Initialize()
	RdKGToolTB.enhancements.Initialize()
	RdKGToolTB.respawner.Initialize()
	RdKGToolTB.camp.Initialize()
	RdKGToolTB.ra.Initialize()
	RdKGToolTB.sp.Initialize()
	RdKGToolTB.so.Initialize()
	RdKGToolTB.caj.Initialize()
	RdKGToolTB.am.Initialize()
	RdKGToolTB.pt.Initialize()
end

function RdKGToolTB.SlashCmd(param)
	if param ~= nil then

	end
end

function RdKGToolTB.GetMenu()
	local menu = {
		[1] = {
			type = "header",
			name = RdKGToolMenu.constants.TOOLBOX_HEADER,
			width = "full",
		}
	}
	RdKGToolMenu.AddMenuEntries(menu, RdKGToolTB.sm.GetMenu())
	RdKGToolMenu.AddMenuEntries(menu, RdKGToolTB.recharger.GetMenu())
	RdKGToolMenu.AddMenuEntries(menu, RdKGToolTB.kc.GetMenu())
	RdKGToolMenu.AddMenuEntries(menu, RdKGToolTB.bft.GetMenu())
	RdKGToolMenu.AddMenuEntries(menu, RdKGToolTB.siege.GetMenu()) --There is no menu
	RdKGToolMenu.AddMenuEntries(menu, RdKGToolTB.cl.GetMenu())
	RdKGToolMenu.AddMenuEntries(menu, RdKGToolTB.cs.GetMenu())
	RdKGToolMenu.AddMenuEntries(menu, RdKGToolTB.enhancements.GetMenu())
	RdKGToolMenu.AddMenuEntries(menu, RdKGToolTB.respawner.GetMenu())
	RdKGToolMenu.AddMenuEntries(menu, RdKGToolTB.camp.GetMenu())
	RdKGToolMenu.AddMenuEntries(menu, RdKGToolTB.ra.GetMenu())
	RdKGToolMenu.AddMenuEntries(menu, RdKGToolTB.sp.GetMenu())
	RdKGToolMenu.AddMenuEntries(menu, RdKGToolTB.so.GetMenu())
	RdKGToolMenu.AddMenuEntries(menu, RdKGToolTB.caj.GetMenu())
	RdKGToolMenu.AddMenuEntries(menu, RdKGToolTB.am.GetMenu())
	RdKGToolMenu.AddMenuEntries(menu, RdKGToolTB.pt.GetMenu())
	return menu
end

function RdKGToolTB.GetDefaults()
	local defaults = {}
	defaults.sm = RdKGToolTB.sm.GetDefaults()
	defaults.recharger = RdKGToolTB.recharger.GetDefaults()
	defaults.kc = RdKGToolTB.kc.GetDefaults()
	defaults.bft = RdKGToolTB.bft.GetDefaults()
	defaults.siege = RdKGToolTB.siege.GetDefaults()
	defaults.cl = RdKGToolTB.cl.GetDefaults()
	defaults.cs = RdKGToolTB.cs.GetDefaults()
	defaults.enhancements = RdKGToolTB.enhancements.GetDefaults()
	defaults.respawner = RdKGToolTB.respawner.GetDefaults()
	defaults.camp = RdKGToolTB.camp.GetDefaults()
	defaults.ra = RdKGToolTB.ra.GetDefaults()
	defaults.sp = RdKGToolTB.sp.GetDefaults()
	defaults.so = RdKGToolTB.so.GetDefaults()
	defaults.caj = RdKGToolTB.caj.GetDefaults()
	defaults.am = RdKGToolTB.am.GetDefaults()
	defaults.pt = RdKGToolTB.pt.GetDefaults()
	return defaults
end