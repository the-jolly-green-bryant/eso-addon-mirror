-- RdK Group Tool Group Menu
-- By @s0rdrak (PC / EU)

RdKGTool = RdKGTool or {}
RdKGTool.util = RdKGTool.util or {}

local RdKGToolUtil = RdKGTool.util
RdKGToolUtil.groupMenu = RdKGToolUtil.groupMenu or {}
local RdKGToolGMenu = RdKGToolUtil.groupMenu
RdKGToolUtil.group = RdKGToolUtil.group or {}
local RdKGToolGroup = RdKGToolUtil.group
RdKGTool.group = RdKGTool.group or {}
RdKGTool.group.gb = RdKGTool.group.gb or {}
local RdKGToolGBeam = RdKGTool.group.gb
RdKGTool.toolbox = RdKGTool.toolbox or {}
local RdKGToolTB = RdKGTool.toolbox
RdKGToolTB.ra = RdKGToolTB.ra or {}
local RdKGToolRa = RdKGToolTB.ra

RdKGToolGMenu.callbackName = RdKGTool.addonName .. "GroupMenu"

RdKGToolGMenu.constants = RdKGToolGMenu.constants or {}

RdKGToolGMenu.config = {}

RdKGToolGMenu.state = {}
RdKGToolGMenu.state.initialized = false

function RdKGToolGMenu.Initialize()
	RdKGTool.profile.AddProfileChangeListener(RdKGToolGMenu.callbackName, RdKGToolGMenu.OnProfileChanged)
	RdKGToolGMenu.state.initialized = true
	RdKGToolGMenu.AdjustGroupMenu()
end

function RdKGToolGMenu.GetDefaults()
	local defaults = {}
	
	return defaults
end

function RdKGToolGMenu.BgAddCrown(charName, displayName)
	RdKGToolGroup.SetBgCrown(charName, displayName)
	RdKGToolGMenu.SetRole(charName, displayName, nil)
end

function RdKGToolGMenu.BgRemoveCrown(charName, displayName)
	RdKGToolGroup.RemoveBgCrown(charName, displayName)
end

function RdKGToolGMenu.SetRole(charName, displayName, role)
	RdKGToolGroup.SetRole(charName, displayName, role)
	if charName == GetUnitName("player") and displayName == GetUnitDisplayName("player") then
		RdKGToolRa.SendRole()
	else
		RdKGToolRa.SetPlayerRole(charName, displayName, role)
	end
end

function RdKGToolGMenu.CreateRoleSubEntry(player, role, description)
	local entry = {}
	if player.role == role then
		entry.label = string.format("%s %s", RdKGToolGMenu.constants.ROLE_SUBMENU_REMOVE, description)
		entry.callback = function() RdKGToolGMenu.SetRole(player.charName, player.displayName, nil) end
	else
		entry.label = string.format("%s %s", RdKGToolGMenu.constants.ROLE_SUBMENU_SET, description)
		entry.callback = function() RdKGToolGMenu.SetRole(player.charName, player.displayName, role) end
	end
	return entry
end

function RdKGToolGMenu.CreateRoleSubEntries(player)
	local entries = {}
	if player ~= nil then
		table.insert(entries, RdKGToolGMenu.CreateRoleSubEntry(player, RdKGToolGroup.constants.roles.ROLE_RAPID, RdKGToolGMenu.constants.ROLE_SUBMENU_RAPID))
		table.insert(entries, RdKGToolGMenu.CreateRoleSubEntry(player, RdKGToolGroup.constants.roles.ROLE_PURGE, RdKGToolGMenu.constants.ROLE_SUBMENU_PURGE))
		table.insert(entries, RdKGToolGMenu.CreateRoleSubEntry(player, RdKGToolGroup.constants.roles.ROLE_HEAL, RdKGToolGMenu.constants.ROLE_SUBMENU_HEAL))
		table.insert(entries, RdKGToolGMenu.CreateRoleSubEntry(player, RdKGToolGroup.constants.roles.ROLE_DD, RdKGToolGMenu.constants.ROLE_SUBMENU_DD))
		table.insert(entries, RdKGToolGMenu.CreateRoleSubEntry(player, RdKGToolGroup.constants.roles.ROLE_SYNERGY, RdKGToolGMenu.constants.ROLE_SUBMENU_SYNERGY))
		table.insert(entries, RdKGToolGMenu.CreateRoleSubEntry(player, RdKGToolGroup.constants.roles.ROLE_CC, RdKGToolGMenu.constants.ROLE_SUBMENU_CC))
		table.insert(entries, RdKGToolGMenu.CreateRoleSubEntry(player, RdKGToolGroup.constants.roles.ROLE_SUPPORT, RdKGToolGMenu.constants.ROLE_SUBMENU_SUPPORT))
		table.insert(entries, RdKGToolGMenu.CreateRoleSubEntry(player, RdKGToolGroup.constants.roles.ROLE_PLACEHOLDER, RdKGToolGMenu.constants.ROLE_SUBMENU_PLACEHOLDER))
		table.insert(entries, RdKGToolGMenu.CreateRoleSubEntry(player, RdKGToolGroup.constants.roles.ROLE_APPLICANT, RdKGToolGMenu.constants.ROLE_SUBMENU_APPLICANT))
	end
	return entries
end

function RdKGToolGMenu.AdjustGroupMenu()
	local groupMenu = GROUP_LIST.GroupListRow_OnMouseUp
	GROUP_LIST.GroupListRow_OnMouseUp = function(selfControl, control, button, upInside)
		groupMenu(selfControl, control, button, upInside)
		if(button == MOUSE_BUTTON_INDEX_RIGHT and upInside) then
			local data = ZO_ScrollList_GetData(control)
			if data ~= nil then
				--[[
				data.isPlayer
				data.characterName
				data.displayName
				data.unitTag
				data.online]]
				if data.online == true then
					local players = RdKGToolGroup.GetGroupInformation()
					if players ~= nil then
						for i = 1, #players do
							if players[i].unitTag == data.unitTag then
								if IsActiveWorldBattleground() then
									if players[i].isLeader == true then
										AddCustomMenuItem(RdKGToolGMenu.constants.BG_LEADER_REMOVE_CROWN, function() RdKGToolGMenu.BgRemoveCrown(players[i].charName, players[i].displayName) end )
									else
										AddCustomMenuItem(RdKGToolGMenu.constants.BG_LEADER_ADD_CROWN, function() RdKGToolGMenu.BgAddCrown(players[i].charName, players[i].displayName) end )
										--if players[i].isLeader == false then
											--if RdKGToolGBeam.GetEnabled() == true then
												AddCustomSubMenuItem(RdKGToolGMenu.constants.ROLE_MENU_ENTRY, RdKGToolGMenu.CreateRoleSubEntries(players[i]))
											--end
										--end
									end
								else
									--if players[i].isLeader == false then
										--if RdKGToolGBeam.GetEnabled() == true then
											AddCustomSubMenuItem(RdKGToolGMenu.constants.ROLE_MENU_ENTRY, RdKGToolGMenu.CreateRoleSubEntries(players[i]))
										--end
									--end
								end
							end
						end
					end
					if ZO_Menu_GetNumMenuItems() > 0 then 
						ShowMenu() 
					end
				end
			end
		end
	end
end

--callbacks
function RdKGToolGMenu.OnProfileChanged(currentProfile)
	if currentProfile ~= nil then
		RdKGToolGMenu.gmVars = currentProfile.util.groupMenu
	end
end