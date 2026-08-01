--[[------------------------------------------------------------------------------------------------
Title:          Mounts
Author:         Static_Recharge
Description:    Creates and handles the mount specific features for the add-on.
------------------------------------------------------------------------------------------------]]--


--[[------------------------------------------------------------------------------------------------
Libraries and Aliases
------------------------------------------------------------------------------------------------]]--
local LCM = LibCustomMenu
local EM = EVENT_MANAGER
local CDM = ZO_COLLECTIBLE_DATA_MANAGER


--[[------------------------------------------------------------------------------------------------
Static Values
------------------------------------------------------------------------------------------------]]--
local multiRiderSubCatID = 75


--[[------------------------------------------------------------------------------------------------
Mounts Class Initialization
Mounts    													              - Parent object containing all functions, tables, variables, constants and other data managers.
├─ :IsInitialized()                               - Returns true if the object has been successfully initialized.
├─ :PlayerIdle()															    - Checks if the player is idle and updates the timer accordingly.
├─ :MountPlayer()                									- Mounts the targetted player.
├─ :UpdateMountData()               							- Updates the mount lists.
├─ :OnGroupMemberJoined(eventCode, memberCharacterName, memberDisplayName, isLocalPlayer) 
│                                                 - Updates the mount to the multi mount.
├─ :OnGroupMemberLeft(eventCode, memberCharacterName, reason, isLocalPlayer, isLeader, memberDisplayName, actionRequiredVote)
│                                     						- Updates the mount to the solo mount.
├─ :OnPlayerActivated(eventCode, initial)					- Updates the mount if group status changed while player was offline.
├─ :MountContextMenu()														- Adds an entry to the Mount list context menu.
└─ :GetParent()                                   - Returns the parent object of this object for reference to parent variables.
------------------------------------------------------------------------------------------------]]--
local Mounts = {}


--[[------------------------------------------------------------------------------------------------
Mounts:Initialize(Parent)
Inputs:				Parent 					- The parent object containing other required information.  
Outputs:			None
Description:	Initializes all of the variables and tables.
------------------------------------------------------------------------------------------------]]--
function Mounts:Initialize(Parent)
  self.Parent = Parent
  self.eventSpace = "SSFMounts"
  local SV = Parent.SV
  
  -- Session variables
	self.SoloMount = {
		Keys = {},
		Values = {},
	}
	self.MultiMount = {
		Keys = {},
		Values = {},
	}
	self.currentMount = nil
	self:UpdateMountData()

  -- Context Menu
  self:MountContextMenu()

  -- Event Registrations
	EM:RegisterForEvent(self.eventSpace, EVENT_GROUP_MEMBER_JOINED, function(...) self:OnGroupMemberJoined(...) end)
	EM:RegisterForEvent(self.eventSpace, EVENT_GROUP_MEMBER_LEFT, function(...) self:OnGroupMemberLeft(...) end)
	EM:RegisterForEvent(self.eventSpace, EVENT_PLAYER_ACTIVATED, function(...) self:OnPlayerActivated(...) end)

  -- Keybindings associations
	ZO_CreateStringId("SI_BINDING_NAME_SSF_MOUNT_PLAYER", "Mount Group Member")

	self.initialized = true
end


--[[------------------------------------------------------------------------------------------------
Mounts:IsInitialized()
Inputs:				None
Outputs:			initialized                         - bool for object initialized state
Description:	Returns true if the object has been successfully initialized.
------------------------------------------------------------------------------------------------]]--
function Mounts:IsInitialized()
  return self.initialized
end


--[[------------------------------------------------------------------------------------------------
Mounts:MountPlayer()
Inputs:				None
Outputs:			None
Description:	Mounts the targetted player
------------------------------------------------------------------------------------------------]]--
function Mounts:MountPlayer()
	-- if not grouped then don't need to process anything
	if not IsUnitGrouped("player") then return end

	local Parent = self:GetParent()

	local function DistanceToUnit(unitID)
		local _, selfX, selfY, selfH = GetUnitWorldPosition("player")
		local _, targetX, targetY, targetH = GetUnitWorldPosition(unitID)
		local nDistance = zo_distance3D(targetX, targetY, targetH, selfX, selfY, selfH) / 100
		return nDistance
	end
	
	local GroupMultiMounts = {}
	local displayNamePref = nil
	local isMountable = false
	for iD = 1, GetGroupSize() do
		local playerID = GetGroupUnitTagByIndex(iD)
		local playerCharName = GetUnitName(playerID)
		local playerDisplayName = GetUnitDisplayName(playerID)
		local distance = DistanceToUnit(playerID)
		local mountedState, hasEnabledGroupMount, hasFreePassengerSlot = GetTargetMountedStateInfo(playerDisplayName)
		if mountedState == MOUNTED_STATE_MOUNT_RIDER and hasEnabledGroupMount and hasFreePassengerSlot then isMountable = true else isMountable = false end
		if not ZO_ShouldPreferUserId() then displayNamePref = playerCharName else displayNamePref = playerDisplayName end
		displayNamePref = zo_strformat("<<1>>", displayNamePref)--<< Strip genders
		if playerDisplayName ~= GetUnitDisplayName("player") and IsUnitOnline(playerID) and IsUnitInGroupSupportRange(playerID) and isMountable and distance < 5.0 then
			table.insert(GroupMultiMounts, {name = displayNamePref, distance = distance})
		end
	end
	if #GroupMultiMounts > 0 then
		table.sort(GroupMultiMounts, function(a, b) return a.distance < b.distance end)
		--dismount
		EnablePreviewMode(true)
		DisablePreviewMode()
		local name = GroupMultiMounts[1].name
		UseMountAsPassenger(name)
		if Parent.SV.multiMountNotify then
			Parent.Notifications:Notify(zo_strformat("Mounted <<1>> as a passenger.", name))
		end
	else
		if Parent.SV.multiMountNotify then
			Parent.Notifications:Notify(zo_strformat("No multi-mount within range."))
		end
	end
end


--[[------------------------------------------------------------------------------------------------
Mounts:UpdateMountData()
Inputs:				None
Outputs:			None
Description:	Updates the mount lists.
------------------------------------------------------------------------------------------------]]--
function Mounts:UpdateMountData()
  local Parent = self:GetParent()

	local function IsNotMountCategory(categoryData)
		return not categoryData:IsOutfitStylesCategory() and not categoryData:IsHousingCategory()
	end

	local function IsMount(collectibleData)
		return collectibleData:IsCategoryType(COLLECTIBLE_CATEGORY_TYPE_MOUNT)
	end

	local SoloMountCollectionData = {id = {}, name = {}}
	local MultiMountCollectionData = {id = {}, name = {}}

	--Iterate over the main categories and do not use outfits or houses
	for idx, categoryData in CDM:CategoryIterator({IsNotMountCategory}) do
		--Iterate over the sub-categories of the current main category and do not use outfits or houses
		for _, subCategoryData in categoryData:SubcategoryIterator({IsNotMountCategory}) do
			--Iterate over the sub-categorie's collectibles and only check for mounts collectible type
			for _, subCatCollectibleData in subCategoryData:CollectibleIterator({IsMount}) do
				--Check if the mount is owned/unlocked and not blocked
				if subCatCollectibleData:IsUnlocked() and not subCatCollectibleData:IsBlocked() then
					local id = subCatCollectibleData:GetId()
					local isActive = subCatCollectibleData:IsActive(GAMEPLAY_ACTOR_CATEGORY_PLAYER)
					local name = subCatCollectibleData:GetFormattedName()
					if isActive then
						self.currentMount = {
							id = id,
							name = name,
						}
					end
					if subCategoryData:GetId() == multiRiderSubCatID then
						table.insert(MultiMountCollectionData.id, id)
						table.insert(MultiMountCollectionData.name, name)
					else
						table.insert(SoloMountCollectionData.id, id)
						table.insert(SoloMountCollectionData.name, name)
					end
				end
			end
		end
	end

	-- add in virtual mount selections
	table.insert(SoloMountCollectionData.id, 1, 7) --offset id by 6, first collectible that's not a mount
	table.insert(SoloMountCollectionData.name, 1, "-- Random Favorite Mount")
	table.insert(SoloMountCollectionData.id, 2, 8)
	table.insert(SoloMountCollectionData.name, 2, "-- Random Mount")

	-- convert to paired lists and sort
	self.MultiMount = LibStatic:PairedListNew(MultiMountCollectionData.name, MultiMountCollectionData.id)
	self.SoloMount = LibStatic:PairedListNew(SoloMountCollectionData.name, SoloMountCollectionData.id)
	self.MultiMount:Sort()
	self.SoloMount:Sort()
end


--[[------------------------------------------------------------------------------------------------
Mounts:OnGroupMemberJoined(eventCode, memberCharacterName, memberDisplayName, isLocalPlayer)
Inputs:				eventCode 													- ZOS eventcode
							memberCharacterName 								- Character name of who joined
							memberDisplayName 									- Display name of who joined
							isLocalPlayer 											- True if the person who joined is the user
Outputs:			None
Description:	Updates the mount to the multi mount.
------------------------------------------------------------------------------------------------]]--
function Mounts:OnGroupMemberJoined(eventCode, memberCharacterName, memberDisplayName, isLocalPlayer)
  local Parent = self:GetParent()
	if isLocalPlayer and Parent.CH.multiMountEnable then
		UseCollectible(Parent.CH.multiMount, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
		Parent.Chat:Debug(zo_strformat("Set to multi mount: <<1>>", GetCollectibleLink(Parent.CH.multiMount)))
	end
end


--[[------------------------------------------------------------------------------------------------
Mounts:OnGroupMemberLeft(eventCode, memberCharacterName, reason, isLocalPlayer, isLeader, memberDisplayName, actionRequiredVote)
Inputs:				eventCode 													- ZOS eventcode
							memberCharacterName 								- Character name of who left
							reason 															- Reason code for the leave
							isLocalPlayer 											- True if the person who left is the user
							isLeader 														- True if it was the leader that left
							memberDisplayName 									- Display name of who left
							actionRequiredVote 									- True if it was a vote kick
Outputs:			None
Description:	Updates the mount to the solo mount.
------------------------------------------------------------------------------------------------]]--
function Mounts:OnGroupMemberLeft(eventCode, memberCharacterName, reason, isLocalPlayer, isLeader, memberDisplayName, actionRequiredVote)
  local Parent = self:GetParent()
	if isLocalPlayer and Parent.CH.multiMountEnable then
		if Parent.CH.soloMount == 7 or Parent.CH.soloMount == 8 then
			SetRandomMountType(Parent.CH.soloMount - 6, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
		else
			UseCollectible(Parent.CH.soloMount, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
			Parent.Chat:Debug(zo_strformat("Set to solo mount: <<1>>", GetCollectibleLink(Parent.CH.soloMount)))
		end
	end
end


--[[------------------------------------------------------------------------------------------------
Mounts:OnPlayerActivated(eventCode, initial)
Inputs:				eventCode 													- ZOS eventcode
							initial 														- true if this is the initial load
Outputs:			None
Description:	Updates the mount if group status changed while player was offline.
------------------------------------------------------------------------------------------------]]--
function Mounts:OnPlayerActivated(eventCode, initial)
  local Parent = self:GetParent()
	if initial and Parent.CH.multiMountEnable then
		if IsUnitGrouped("player") then
			UseCollectible(Parent.CH.multiMount, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
			Parent.Chat:Debug(zo_strformat("Set to multi mount: <<1>>", GetCollectibleLink(Parent.CH.multiMount)))
		else
			UseCollectible(Parent.CH.soloMount, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
			Parent.Chat:Debug(zo_strformat("Set to solo mount: <<1>>", GetCollectibleLink(Parent.CH.soloMount)))
		end
	end
	EM:UnregisterForEvent(self.eventSpace, EVENT_PLAYER_ACTIVATED)
end


--[[------------------------------------------------------------------------------------------------
SSF:MountContextMenu()
Inputs:			  None
Outputs:			None
Description:	Adds an entry to the Mount list context menu.
------------------------------------------------------------------------------------------------]]--
function Mounts:MountContextMenu()
  local Parent = self:GetParent()
	
	ZO_PreHook(ZO_CollectibleTile_Keyboard, "ShowMenu", function(self_)
		local data = self_.collectibleData
		if data:GetCategoryType() == COLLECTIBLE_CATEGORY_TYPE_MOUNT and Parent.CH.multiMountEnable then
			local ZO_ShowMenu = ShowMenu
			function ShowMenu(...)
				ShowMenu = ZO_ShowMenu
				AddCustomMenuItem("SSF Set Mount", function()
					local id = data:GetId()
					local index = self.SoloMount:GetChoiceByValue(id)
					if index then
						Parent.CH.soloMount = id
						return
					end
					index = self.MultiMount:GetChoiceByValue(id)
					if index then
						Parent.CH.multiMount = id
						return
					end
				end)
				return ShowMenu(...)
			end
		end
	end)

	ZO_PreHook(ZO_CollectibleImitationTile_Keyboard, 'ShowMenu', function(self_)
		local data = self_.imitationCollectibleData
		if data.randomMountType and Parent.CH.multiMountEnable then
			local ZO_ShowMenu = ShowMenu
			function ShowMenu(...)
				ShowMenu = ZO_ShowMenu
				AddCustomMenuItem("SSF Set Mount", function()
					Parent.CH.soloMount = data.randomMountType + 6 --offset id by 6, first collectible that's not a mount
				end)
				return ShowMenu(...)
			end
		end
	end)
end


--[[------------------------------------------------------------------------------------------------
Mounts:GetParent()
Inputs:				None
Outputs:			Parent          - The parent object of this object.
Description:	Returns the parent object of this object for reference to parent variables.
------------------------------------------------------------------------------------------------]]--
function Mounts:GetParent()
  return self.Parent
end


--[[------------------------------------------------------------------------------------------------
Global template assignment
------------------------------------------------------------------------------------------------]]--
StaticsSocialFeatures.Mounts = Mounts