GroupReformer = {}
GroupReformer.name = "GroupReformer"

GroupReformer.settings = {}

GroupReformer.settings.defaults = {
	autoAcceptGuildmates = false,
	autoAcceptFriends = false,
}

-- Initialize local variables
local loc = {}

loc.playerName = GetUnitName("player")
loc.reformOnDisband = false
loc.savedGroupMembers = {}


function GroupReformer.OnAddOnLoaded(event, addonName)
	if (addonName == GroupReformer.name) then
		GroupReformer:Initialize()
	end
end

EVENT_MANAGER:RegisterForEvent(GroupReformer.name, EVENT_ADD_ON_LOADED, GroupReformer.OnAddOnLoaded)

function GroupReformer:Initialize()

	GroupReformer.InitializeSettings()

	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GROUP_MEMBER_LEFT, self.OnGroupMemberLeft)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GROUP_INVITE_RECEIVED, self.OnGroupInviteReceived)
end

function GroupReformer.InitializeSettings()
	
	-- Button on the group menu
	ZO_CreateStringId("SI_BINDING_NAME_REFORM_GROUP", "Reform Group")

	GroupReformer.groupMenuDescriptor = { 
		alignment = KEYBIND_STRIP_ALIGN_CENTER,
		[1] = {
			name = GetString(SI_BINDING_NAME_REFORM_GROUP),
			keybind = "REFORM_GROUP", 
			control = self,
			callback = function(descriptor) GroupReformer.disbandToReformGroup() end, 
			visible = function(descriptor) return GroupReformer.playerCanReformGroup() end,
		},
	}

	-- Save/load the saved settings
	GroupReformer.settings = ZO_SavedVars:New("SV_GroupReformer_Settings", 1, nil, GroupReformer.settings.defaults)

	-- Settings in the Add-On Area
	local LAM = LibStub("LibAddonMenu-2.0")
	local panelData = {
		type = "panel",
		name = "GroupReformer",
		displayName = ZO_HIGHLIGHT_TEXT:Colorize("Group Reformer"),
		author = "MikeX of Guild UMBRA",
		version = "1.1",
	}
	LAM:RegisterAddonPanel("GroupReformer_Panel", panelData)
	local optionsData = {
		[1] = {
			type = "checkbox",
			name = "Party Invite Auto Accept (Guild)",
			tooltip = "Turn ON to allow Group Reformer to automatically accept invites from guildmates - turn OFF to disable",
			getFunc = function() return GroupReformer.settings.autoAcceptGuildmates end,
			setFunc = function(value) GroupReformer.settings.autoAcceptGuildmates = value end,
			width = "full",
		},
		[2] = {
			type = "checkbox",
			name = "Party Invite Auto Accept (Friends)",
			tooltip = "Turn ON to allow Group Reformer to automatically accept invites from friends - turn OFF to disable",
			getFunc = function() return GroupReformer.settings.autoAcceptFriends end,
			setFunc = function(value) GroupReformer.settings.autoAcceptFriends = value end,
			width = "full",
		},
	}
	LAM:RegisterOptionControls("GroupReformer_Panel", optionsData)
end

function GroupReformer:OnGroupInviteReceived(inviterName)
	
	if (IsPlayerInGroup("player")) then
		return
	end

	-- Check friends list
	if (GroupReformer.settings.autoAcceptFriends) then
		for i = 1, GetNumFriends(), 1 do
			local hasCharacter, characterName, zoneName, classType, alliance, level, veteranRank = GetFriendCharacterInfo(i)
			characterName = string.sub(characterName, 1, -4)
			if (characterName == inviterName) then
				AcceptGroupInvite()
			end
		end
	end

	-- Check guild lists
	if (GroupReformer.settings.autoAcceptGuildmates) then
		for i = 1, GetNumGuilds(), 1 do
			for j = 1, GetNumGuildMembers(GetGuildId(i)), 1 do
				local hasCharacter, characterName, zoneName, classType, alliance, level, veteranRank = GetGuildMemberCharacterInfo(GetGuildId(i),j)
				characterName = string.sub(characterName, 1, -4)
				if (characterName == inviterName) then
					AcceptGroupInvite()
				end
			end
		end
	end
end

function GroupReformer.onGroupListSceneStateChange(oldState, newState)

	if (newState == SCENE_SHOWING) then

		-- The user is looking at the group menu. Save the group automatically to prepare for reform.
		GroupReformer.saveGroup()

		-- If the player can reform the group, make sure the reform button is there
		if (GroupReformer.playerCanReformGroup()) then

			if not KEYBIND_STRIP:HasKeybindButtonGroup(GroupReformer.groupMenuDescriptor) then

				if not KEYBIND_STRIP.middleButtons then
					KEYBIND_STRIP:AddKeybindButtonGroup(GroupReformer.groupMenuDescriptor)
				end
			end
		end
	elseif (newState == SCENE_HIDDEN) then

		-- The user is not looking at the group menu. Make sure the keybind is not there.
		if KEYBIND_STRIP:HasKeybindButtonGroup(GroupReformer.groupMenuDescriptor) then
			KEYBIND_STRIP:RemoveKeybindButtonGroup(GroupReformer.groupMenuDescriptor) 
		end
	end
end

function GroupReformer:OnGroupMemberLeft(event, reason, memberName, wasLocalPlayer)
	
	-- A group member left. Check if the player is no longer in a group.
	if (GetGroupSize() <= 1) then

		-- The player is no longer in a group. Check to see if they initiated the group reform.
		if (loc.reformOnDisband) then

			GroupReformer.reformGroup()

			-- We reformed group. We don't want to attempt a reform again until the user initiates a reform.
			loc.reformOnDisband = false
		end
	end
end

function GroupReformer.saveGroup()
	
	local groupSize = GetGroupSize()
	local characterName

	-- Don't save the group if we don't have one.
	if (groupSize <= 1) then
		return
	end

	--Initialize the member list
	groupMembers = {}

	-- Find all the members
	for i=1, groupSize, 1 do
		
		characterName = GetUnitName(GetGroupUnitTagByIndex(i))
		
		if (characterName ~= loc.playerName) then
			table.insert(groupMembers, characterName)
		end
	end

	-- Save them
	if (#groupMembers > 0) then
		loc.savedGroupMembers = groupMembers
	end
end

function GroupReformer.disbandGroup()

	-- If the player can disband the group, disband it
	if (GetGroupSize() > 1 and GetUnitName(GetGroupLeaderUnitTag()) == GetUnitName("player")) then
		GroupDisband()
	-- If the player can break the group by leaving it, leave the group
	elseif (GetGroupSize() == 2) then
		GroupLeave()
	else
		d(">> Error: You can not disband the group.")
		return
	end
end

function GroupReformer.reformGroup()

	local memberCounter = 0

	-- Don't reform if we don't have any saved members
	if (#groupMembers <= 0 and #loc.savedGroupMembers <= 0) then
		d(">> Error: No players saved to reinvite.")
		return
	end

	-- If we have saved group members, use those
	if (#groupMembers <= 0) then

		if (#loc.savedGroupMembers > 0) then
			groupMembers = loc.savedGroupMembers
		end
	end


	-- Cycle through array and invite the old members
	for i=1, #groupMembers, 1 do
		-- If we have a saved member and it is not the player, invite them
		if (groupMembers[i] ~= nil and groupMembers[i] ~= "" and groupMembers[i] ~= loc.playerName) then

			memberCounter = memberCounter + 1

			GroupInviteByName(groupMembers[i])
		end
	end
end

function GroupReformer.disbandToReformGroup()

	-- Check the scene to make sure we're in the party menu to ensure no one accientally hits the button during normal play
	if SCENE_MANAGER and SCENE_MANAGER:GetCurrentScene() then
		if SCENE_MANAGER:GetCurrentScene():GetName() ~= "groupList" then
			return false
		end
	end

	-- The user wants to reform the group. Set the reformOnDisband so OnGroupMemberLeft() knows to attempt a reform
	loc.reformOnDisband = true

	-- Disband the group. This will trigger OnGroupMemberLeft().
	GroupReformer.disbandGroup()
end

function GroupReformer.playerCanReformGroup()

	-- If there is no group, the player obviously can't reform it.
	if (GetGroupSize() <= 1) then
		return false
	end

	-- If the player is the leader of the group or the group size is 2, the player can attempt a regroup
	return (GetUnitName(GetGroupLeaderUnitTag()) == GetUnitName("player") or GetGroupSize() == 2)

end

-- RegisterCallback for groupList restacking
-- This declaration has to be set AFTER GroupReformer.onGroupListSceneStateChange declaration
GroupReformer.groupListScene = SCENE_MANAGER:GetScene("groupList")
GroupReformer.groupListScene:RegisterCallback("StateChange", GroupReformer.onGroupListSceneStateChange)