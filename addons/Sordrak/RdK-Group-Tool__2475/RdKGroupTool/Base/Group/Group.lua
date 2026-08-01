-- RdK Group Tool Group
-- By @s0rdrak (PC / EU)

RdKGTool = RdKGTool or {}

RdKGTool.group = RdKGTool.group or {}

local RdKGToolGroup = RdKGTool.group
RdKGTool.menu = RdKGTool.menu or {}
local RdKGToolMenu = RdKGTool.menu


function RdKGToolGroup.Initialize()
	RdKGToolGroup.crown.Initialize()
	RdKGToolGroup.ai.Initialize()
	RdKGToolGroup.ftcv.Initialize()
	RdKGToolGroup.ftcw.Initialize()
	RdKGToolGroup.ftca.Initialize()
	RdKGToolGroup.ftcb.Initialize()
	RdKGToolGroup.dbo.Initialize()
	RdKGToolGroup.rt.Initialize()
	RdKGToolGroup.ro.Initialize()
	RdKGToolGroup.hdm.Initialize()
	RdKGToolGroup.po.Initialize()
	RdKGToolGroup.dt.Initialize()
	RdKGToolGroup.gb.Initialize()
	RdKGToolGroup.isdp.Initialize()
end

function RdKGToolGroup.SlashCmd(param)
	if param ~= nil then
		if param[1] == "ai" then
			table.remove(param,1)
			RdKGToolGroup.ai.SlashCmd(param)
		elseif param[1] == "hdm" then
			RdKGToolGroup.hdm.SlashCmd(param)
		end
	end
end

function RdKGToolGroup.GetDefaults()
	local defaults = {}
	defaults.crown = RdKGToolGroup.crown.GetDefaults()
	defaults.ai = RdKGToolGroup.ai.GetDefaults()
	defaults.ftcv = RdKGToolGroup.ftcv.GetDefaults()
	defaults.ftcw = RdKGToolGroup.ftcw.GetDefaults()
	defaults.ftca = RdKGToolGroup.ftca.GetDefaults()
	defaults.ftcb = RdKGToolGroup.ftcb.GetDefaults()
	defaults.dbo = RdKGToolGroup.dbo.GetDefaults()
	defaults.rt = RdKGToolGroup.rt.GetDefaults()
	defaults.ro = RdKGToolGroup.ro.GetDefaults()
	defaults.hdm = RdKGToolGroup.hdm.GetDefaults()
	defaults.po = RdKGToolGroup.po.GetDefaults()
	defaults.dt = RdKGToolGroup.dt.GetDefaults()
	defaults.gb = RdKGToolGroup.gb.GetDefaults()
	defaults.isdp = RdKGToolGroup.isdp.GetDefaults()
	return defaults
end

function RdKGToolGroup.GetMenu()
	local menu = {
		[1] = {
			type = "header",
			name = RdKGToolMenu.constants.GROUP_HEADER,
			width = "full",
		}
	}
	RdKGToolMenu.AddMenuEntries(menu, RdKGToolGroup.crown.GetMenu())
	RdKGToolMenu.AddMenuEntries(menu, RdKGToolGroup.ai.GetMenu())
	RdKGToolMenu.AddMenuEntries(menu, RdKGToolGroup.ftcv.GetMenu())
	RdKGToolMenu.AddMenuEntries(menu, RdKGToolGroup.ftcw.GetMenu())
	RdKGToolMenu.AddMenuEntries(menu, RdKGToolGroup.ftca.GetMenu())
	RdKGToolMenu.AddMenuEntries(menu, RdKGToolGroup.ftcb.GetMenu())
	RdKGToolMenu.AddMenuEntries(menu, RdKGToolGroup.dbo.GetMenu())
	RdKGToolMenu.AddMenuEntries(menu, RdKGToolGroup.rt.GetMenu())
	RdKGToolMenu.AddMenuEntries(menu, RdKGToolGroup.ro.GetMenu())
	RdKGToolMenu.AddMenuEntries(menu, RdKGToolGroup.hdm.GetMenu())
	RdKGToolMenu.AddMenuEntries(menu, RdKGToolGroup.po.GetMenu())
	RdKGToolMenu.AddMenuEntries(menu, RdKGToolGroup.dt.GetMenu())
	RdKGToolMenu.AddMenuEntries(menu, RdKGToolGroup.gb.GetMenu())
	RdKGToolMenu.AddMenuEntries(menu, RdKGToolGroup.isdp.GetMenu())
	return menu
end