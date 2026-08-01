--[[------------------------------------------------------------------------------------------------
Title:          Friend Data Manager
Author:         Static_Recharge
Description:    Provides functions for searching the user's friends list for required zones.
------------------------------------------------------------------------------------------------]]--


--[[------------------------------------------------------------------------------------------------
Libraries and Aliases
------------------------------------------------------------------------------------------------]]--


--[[------------------------------------------------------------------------------------------------
FDM Class Initialization
FDM    - Object containing all functions, tables, variables,and constants.
  |-  Parent    - Reference to parent object.
------------------------------------------------------------------------------------------------]]--
local FDM = ZO_InitializingObject:Subclass()


--[[------------------------------------------------------------------------------------------------
FDM:Initialize(Parent)
Inputs:				Parent            - The parent object containing other required information.  
Outputs:			None
Description:	Initializes all of the variables and tables.
------------------------------------------------------------------------------------------------]]--
function FDM:Initialize(Parent)
  self.Parent = Parent
  self.PlayerOfflineStatus = PLAYER_STATUS_OFFLINE
end


--[[------------------------------------------------------------------------------------------------
FDM:GetFriendInZone(zoneID)
Inputs:				zoneID            - The zone ID to look for a friend in.  
Outputs:			displayName       - The display name of the friend found (nillable).
Description:	Returns the name of a friend in the zone in question or nil if none found.
------------------------------------------------------------------------------------------------]]--
function FDM:GetFriendInZone(zoneID)
  for friendIndex=1, GetNumFriends() do
    local displayName, _, status, _ = GetFriendInfo(friendIndex)
    local _, _, _, _, _, _, _, zoneId, _ = GetFriendCharacterInfo(friendIndex)
    if status ~= self.PlayerOfflineStatus then
      if zoneId == zoneID then
        return displayName
      end
    end
  end
  return nil
end


--[[------------------------------------------------------------------------------------------------
FDM:GetParent()
Inputs:				None
Outputs:			Parent          - The parent object of this object.
Description:	Returns the parent object of this object for reference to parent variables.
------------------------------------------------------------------------------------------------]]--
function FDM:GetParent()
  return self.Parent
end


--[[------------------------------------------------------------------------------------------------
StaticsRecruiterInitFriendDataManager(Parent)
Inputs:				Parent          - The parent object of the object to be created.
Outputs:			FDM             - The new object created.
Description:	Global function to create a new instance of this object.
------------------------------------------------------------------------------------------------]]--
function StaticsRecruiterInitFriendDataManager(Parent)
  return FDM:New(Parent)
end