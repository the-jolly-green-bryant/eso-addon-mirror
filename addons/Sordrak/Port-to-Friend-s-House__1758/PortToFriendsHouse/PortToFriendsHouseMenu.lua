-- PortToFriendsHouseMenu
-- By @s0rdrak (PC / EU)

--local LAM = LibStub("LibAddonMenu-2.0")
local LAM = LibAddonMenu2

local PortToFriend = _G['PortToFriend']
local PortToFriendMenu = PortToFriend.menu

PortToFriendMenu.lam = {}
PortToFriendMenu.lam.panel = nil
PortToFriendMenu.lam.panelData = {}
PortToFriendMenu.lam.panelData.type = "panel"
PortToFriendMenu.lam.panelData.name = "|c4592FFPort to Friend's House|r"
PortToFriendMenu.lam.panelData.displayName = PortToFriend.constants.menu.DISPLAY_NAME
PortToFriendMenu.lam.panelData.author = PortToFriend.constants.menu.AUTHOR
PortToFriendMenu.lam.panelData.version = PortToFriend.constants.menu.VERSION
PortToFriendMenu.lam.panelData.registerForRefresh = true
PortToFriendMenu.lam.panelData.registerForDefaults = false

function PortToFriendMenu.Initialize(menuName, vars)
	PortToFriendMenu.lam.optionsData = PortToFriendMenu.CreateMenuFromVars(vars)
	PortToFriendMenu.lam.panel = LAM:RegisterAddonPanel(menuName, PortToFriendMenu.lam.panelData)
	LAM:RegisterOptionControls(menuName, PortToFriendMenu.lam.optionsData)
end

function PortToFriendMenu.GetAvailablePortModes()
	local modes = {}
	modes[1] = PortToFriend.constants.menu.PORT_MODE_NONE
	modes[2] = PortToFriend.constants.menu.PORT_MODE_CLICK
	modes[3] = PortToFriend.constants.menu.PORT_MODE_DEACTIVATE
	return modes
end

function PortToFriendMenu.GetSelectedPortMode()
	local modes = PortToFriendMenu.GetAvailablePortModes()
	return modes[PortToFriend.savedVars.port_mode]
end

function PortToFriendMenu.SetSelectedPortMode(value)
	local modes = PortToFriendMenu.GetAvailablePortModes()
	for i = 1, #modes do
		if modes[i] == value then
			PortToFriend.savedVars.port_mode = i
			break
		end
	end
end

function PortToFriendMenu.GetAvailableDefaultTabs()
	local tabs = {}
	tabs[PortToFriend.constants.TAB_HOUSE] = PortToFriend.constants.TAB_HOUSE_TITLE
	tabs[PortToFriend.constants.TAB_VC] = PortToFriend.constants.TAB_VC_TITLE
	tabs[PortToFriend.constants.TAB_MYHOUSES] = PortToFriend.constants.TAB_MYHOUSES_TITLE
	tabs[PortToFriend.constants.TAB_LIBRARY] = PortToFriend.constants.TAB_LIBRARY_TITLE
	return tabs
end

function PortToFriendMenu.GetSelectedDefaultTab()
	local tabs = PortToFriendMenu.GetAvailableDefaultTabs()
	return tabs[PortToFriend.savedVars.defaultTab]
end

function PortToFriendMenu.SetSelectedDefaultTab(value)
	local tabs = PortToFriendMenu.GetAvailableDefaultTabs()
	for i = 1, #tabs do
		if tabs[i] == value then
			PortToFriend.savedVars.defaultTab = i
			PortToFriend.TabSelected(i)
			break
		end
	end
end

function PortToFriendMenu.CreateMenuFromVars(vars)
	return { 
		[1] = {
			type = "header",
			name = PortToFriend.constants.menu.TITLE,
			width = "full"
		},
		[2] = {
			type = "description",
			title = nil,
			text = PortToFriend.constants.menu.DESCRIPTION,
			width = "full"
		},
		[3] = {
			type = "checkbox",
			name = PortToFriend.constants.menu.G1,
			getFunc = function() return PortToFriend.savedVars.vc_chatAllowed.g1 end,
			setFunc = function(value) PortToFriend.savedVars.vc_chatAllowed.g1 = value end 	
		},
		[4] = {
			type = "checkbox",
			name = PortToFriend.constants.menu.O1,
			getFunc = function() return PortToFriend.savedVars.vc_chatAllowed.o1 end,
			setFunc = function(value) PortToFriend.savedVars.vc_chatAllowed.o1 = value end 	
		},
		[5] = {
			type = "checkbox",
			name = PortToFriend.constants.menu.G2,
			getFunc = function() return PortToFriend.savedVars.vc_chatAllowed.g2 end,
			setFunc = function(value) PortToFriend.savedVars.vc_chatAllowed.g2 = value end 		
		},
		[6] = {
			type = "checkbox",
			name = PortToFriend.constants.menu.O2,
			getFunc = function() return PortToFriend.savedVars.vc_chatAllowed.o2 end,
			setFunc = function(value) PortToFriend.savedVars.vc_chatAllowed.o2 = value end 		
		},
		[7] = {
			type = "checkbox",
			name = PortToFriend.constants.menu.G3,
			getFunc = function() return PortToFriend.savedVars.vc_chatAllowed.g3 end,
			setFunc = function(value) PortToFriend.savedVars.vc_chatAllowed.g3 = value end 		
		},
		[8] = {
			type = "checkbox",
			name = PortToFriend.constants.menu.O3,
			getFunc = function() return PortToFriend.savedVars.vc_chatAllowed.o3 end,
			setFunc = function(value) PortToFriend.savedVars.vc_chatAllowed.o3 = value end 		
		},
		[9] = {
			type = "checkbox",
			name = PortToFriend.constants.menu.G4,
			getFunc = function() return PortToFriend.savedVars.vc_chatAllowed.g4 end,
			setFunc = function(value) PortToFriend.savedVars.vc_chatAllowed.g4 = value end 		
		},
		[10] = {
			type = "checkbox",
			name = PortToFriend.constants.menu.O4,
			getFunc = function() return PortToFriend.savedVars.vc_chatAllowed.o4 end,
			setFunc = function(value) PortToFriend.savedVars.vc_chatAllowed.o4 = value end 		
		},
		[11] = {
			type = "checkbox",
			name = PortToFriend.constants.menu.G5,
			getFunc = function() return PortToFriend.savedVars.vc_chatAllowed.g5 end,
			setFunc = function(value) PortToFriend.savedVars.vc_chatAllowed.g5 = value end 		
		},
		[12] = {
			type = "checkbox",
			name = PortToFriend.constants.menu.O5,
			getFunc = function() return PortToFriend.savedVars.vc_chatAllowed.o5 end,
			setFunc = function(value) PortToFriend.savedVars.vc_chatAllowed.o5 = value end 		
		},
		[13] = {
			type = "checkbox",
			name = PortToFriend.constants.menu.EMOTE,
			getFunc = function() return PortToFriend.savedVars.vc_chatAllowed.emote end,
			setFunc = function(value) PortToFriend.savedVars.vc_chatAllowed.emote = value end 		
		},
		[14] = {
			type = "checkbox",
			name = PortToFriend.constants.menu.SAY,
			getFunc = function() return PortToFriend.savedVars.vc_chatAllowed.say end,
			setFunc = function(value) PortToFriend.savedVars.vc_chatAllowed.say = value end 		
		},
		[15] = {
			type = "checkbox",
			name = PortToFriend.constants.menu.YELL,
			getFunc = function() return PortToFriend.savedVars.vc_chatAllowed.yell end,
			setFunc = function(value) PortToFriend.savedVars.vc_chatAllowed.yell = value end 		
		},
		[16] = {
			type = "checkbox",
			name = PortToFriend.constants.menu.GROUP,
			getFunc = function() return PortToFriend.savedVars.vc_chatAllowed.group end,
			setFunc = function(value) PortToFriend.savedVars.vc_chatAllowed.group = value end 		
		},
		[17] = {
			type = "checkbox",
			name = PortToFriend.constants.menu.TELL,
			getFunc = function() return PortToFriend.savedVars.vc_chatAllowed.tell end,
			setFunc = function(value) PortToFriend.savedVars.vc_chatAllowed.tell = value end 		
		},
		[18] = {
			type = "checkbox",
			name = PortToFriend.constants.menu.ZONE,
			getFunc = function() return PortToFriend.savedVars.vc_chatAllowed.zone end,
			setFunc = function(value) PortToFriend.savedVars.vc_chatAllowed.zone = value end 		
		},
		[19] = {
			type = "checkbox",
			name = PortToFriend.constants.menu.ENZONE,
			getFunc = function() return PortToFriend.savedVars.vc_chatAllowed.enzone end,
			setFunc = function(value) PortToFriend.savedVars.vc_chatAllowed.enzone = value end 		
		},
		[20] = {
			type = "checkbox",
			name = PortToFriend.constants.menu.FRZONE,
			getFunc = function() return PortToFriend.savedVars.vc_chatAllowed.frzone end,
			setFunc = function(value) PortToFriend.savedVars.vc_chatAllowed.frzone = value end 		
		},
		[21] = {
			type = "checkbox",
			name = PortToFriend.constants.menu.DEZONE,
			getFunc = function() return PortToFriend.savedVars.vc_chatAllowed.dezone end,
			setFunc = function(value) PortToFriend.savedVars.vc_chatAllowed.dezone = value end 		
		},
		[22] = {
			type = "checkbox",
			name = PortToFriend.constants.menu.JPZONE,
			getFunc = function() return PortToFriend.savedVars.vc_chatAllowed.jpzone end,
			setFunc = function(value) PortToFriend.savedVars.vc_chatAllowed.jpzone = value end 		
		},
		[23] = {
			type = "checkbox",
			name = PortToFriend.constants.menu.ALLOW_SELF,
			getFunc = function() return PortToFriend.savedVars.vc.allowSelf end,
			setFunc = function(value) PortToFriend.savedVars.vc.allowSelf = value end 		
		},
		[24] = {
			type = "dropdown",
			name = PortToFriend.constants.menu.PORT_MODE,
			choices = PortToFriendMenu.GetAvailablePortModes(),
			getFunc = PortToFriendMenu.GetSelectedPortMode,
			setFunc = PortToFriendMenu.SetSelectedPortMode,
			width = "full"
		},
		[25] = {
			type = "dropdown",
			name = PortToFriend.constants.menu.DEFAULT_TAB,
			choices = PortToFriendMenu.GetAvailableDefaultTabs(),
			getFunc = PortToFriendMenu.GetSelectedDefaultTab,
			setFunc = PortToFriendMenu.SetSelectedDefaultTab,
			width = "full"
		},
	}
end