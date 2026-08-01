--[[------------------------------------------------------------------------------------------------
Title:          Guild Data Manager
Author:         Static_Recharge
Description:    Keeps track of the user's guild information.
------------------------------------------------------------------------------------------------]]--


--[[------------------------------------------------------------------------------------------------
Libraries and Aliases
------------------------------------------------------------------------------------------------]]--


--[[------------------------------------------------------------------------------------------------
GDM Class Initialization
GDM    - Object containing all functions, tables, variables,and constants.
  |-  Parent    - Reference to parent object.
  |-  Data      - Contains the gathered data for each guild. Indexed the same as the game client.
------------------------------------------------------------------------------------------------]]--
local GDM = ZO_InitializingObject:Subclass()


--[[------------------------------------------------------------------------------------------------
GDM:Initialize(Parent)
Inputs:				Parent 					- The parent object containing other required information.  
Outputs:			None
Description:	Initializes all of the variables and tables.
------------------------------------------------------------------------------------------------]]--
function GDM:Initialize(Parent)
  self.Parent = Parent
  self.PlayerOfflineStatus = PLAYER_STATUS_OFFLINE
  self.Data = {}
	self:Update()
end


--[[------------------------------------------------------------------------------------------------
GDM:Update()
Inputs:				None
Outputs:			None
Description:	Updates the internal guild data.
------------------------------------------------------------------------------------------------]]--
function GDM:Update()
	self.Data = {}
	for i = 1, 5 do
		local id = GetGuildId(i)
		if id ~= 0 then
			self.Data[i] = {
				guildID = id,
				name = GetGuildName(id),
			}
			-- Create new savedvar entry if none exists.
			if not self:GetParent().SavedVars.Guilds[id] then
				self:GetParent().SavedVars.Guilds[id] = {}
			end
		end
	end
end


--[[------------------------------------------------------------------------------------------------
GDM:GetGuildMemberInZone(zoneID)
Inputs:				zoneID            - The zone ID to look for a guild member in.  
Outputs:			displayName       - The display name of the guild member found (nillable).
Description:	Returns the name of a guild member in the zone in question or nil if none found.
------------------------------------------------------------------------------------------------]]--
function GDM:GetGuildMemberInZone(zoneID)
  for i,v in ipairs(self.Data) do
		for memberIndex=1, GetNumGuildMembers(v.guildID) do
			local displayName, _, _, status, _ = GetGuildMemberInfo(v.guildID, memberIndex)
			local _, _, _, _, _, _, _, zoneId, _ = GetGuildMemberCharacterInfo(v.guildID, memberIndex)
			if status ~= self.PlayerOfflineStatus then
				if zoneId == zoneID and displayName ~= GetDisplayName() then
					return displayName
				end
			end
		end
	end
	return nil
end


--[[------------------------------------------------------------------------------------------------
GDM:GetGuildNamesList()
Inputs:				None
Outputs:			Names       		- Table of guild names in order of index.
Description:	Returns a table of guild names for the purposes of creating drowpdown menus.
------------------------------------------------------------------------------------------------]]--
function GDM:GetGuildNamesList()
	local Names = {}
	for i,v in ipairs(self.Data) do
		table.insert(Names, v.name)
	end
	return Names
end


--[[------------------------------------------------------------------------------------------------
GDM:GetGuildIDList()
Inputs:				None
Outputs:			IDs       			- Table of guild IDs in order of index.
Description:	Returns a table of guild IDs for the purposes of creating drowpdown menus.
------------------------------------------------------------------------------------------------]]--
function GDM:GetGuildIDList()
	local IDs = {}
	for i,v in ipairs(self.Data) do
		table.insert(IDs, v.guildID)
	end
	return IDs
end


--[[------------------------------------------------------------------------------------------------
GDM:GetParent()
Inputs:				None
Outputs:			Parent          - The parent object of this object.
Description:	Returns the parent object of this object for reference to parent variables.
------------------------------------------------------------------------------------------------]]--
function GDM:GetParent()
  return self.Parent
end


--[[------------------------------------------------------------------------------------------------
StaticsRecruiterInitGuildDataManager(Parent)
Inputs:				Parent          - The parent object of the object to be created.
Outputs:			FDM             - The new object created.
Description:	Global function to create a new instance of this object.
------------------------------------------------------------------------------------------------]]--
function StaticsRecruiterInitGuildDataManager(Parent)
  return GDM:New(Parent)
end