--[[------------------------------------------------------------------------------------------------
Title:          House Data Manager
Author:         Static_Recharge
Description:    Keeps track of the user's owned houses and which zones they are in.
------------------------------------------------------------------------------------------------]]--


--[[------------------------------------------------------------------------------------------------
Libraries and Aliases
------------------------------------------------------------------------------------------------]]--
local CDM = ZO_COLLECTIBLE_DATA_MANAGER


--[[------------------------------------------------------------------------------------------------
HDM Class Initialization
HDM    - Object containing all functions, tables, variables,and constants.
  |-  Parent    - Reference to parent object.
  |-  Data      - Contains the gathered data for each house the player owns. Indexed the same as the 
                game client.
------------------------------------------------------------------------------------------------]]--
local HDM = ZO_InitializingObject:Subclass()


--[[------------------------------------------------------------------------------------------------
HDM:Initialize(Parent)
Inputs:				Parent 					- The parent object containing other required information.  
Outputs:			None
Description:	Initializes all of the variables and tables.
------------------------------------------------------------------------------------------------]]--
function HDM:Initialize(Parent)
  self.Parent = Parent
  self.Data = {}
  self:Update()
end


--[[------------------------------------------------------------------------------------------------
HDM:Update()
Inputs:				None
Outputs:			None
Description:	Updates the internal housing data.
------------------------------------------------------------------------------------------------]]--
function HDM:Update()
  local function IsHousingCat(categoryData)
    return categoryData:IsHousingCategory()
  end

  local function IsHouseCollectible(collectibleData)
    return collectibleData:IsCategoryType(COLLECTIBLE_CATEGORY_TYPE_HOUSE)
  end

	for i, categoryData in CDM:CategoryIterator({IsHousingCat}) do
		for j, subCategoryData in categoryData:SubcategoryIterator({IsHousingCat}) do
			for k, subCatCollectibleData in subCategoryData:CollectibleIterator({IsHouseCollectible}) do
				if subCatCollectibleData:IsUnlocked() and not subCatCollectibleData:IsBlocked() then
					local name, _, _, _, _, _, _, _, _ = GetCollectibleInfo(subCatCollectibleData:GetId())
					local houseID = subCatCollectibleData:GetReferenceId()
					local data = {
            name = name,
            houseID = houseID,
            zoneID = GetHouseFoundInZoneId(houseID),
					}
					table.insert(self.Data, data)
				end
			end
		end
	end
	--table.sort(self.Data, function(k1, k2) return k1.name < k2.name end)
end


--[[------------------------------------------------------------------------------------------------
HDM:GetHouseName(id)
Inputs:				id 					    - The ID of the house to get the name of.  
Outputs:			name            - The name of the house in question.
Description:	Returns the name of the house with the specified ID.
------------------------------------------------------------------------------------------------]]--
function HDM:GetHouseName(id)
  for i,v in ipairs(self.Data) do
    if v.houseID == id then
      return v.name
    end
  end
end


--[[------------------------------------------------------------------------------------------------
HDM:GetZoneID(id)
Inputs:				id 					    - The ID of the house to get the zone ID of.  
Outputs:			zoneID          - The zone ID of the house in question.
Description:	Returns the zone ID of the house with the specified ID.
------------------------------------------------------------------------------------------------]]--
function HDM:GetZoneID(id)
  local zoneID
  for i,v in ipairs(self.Data) do
    if v.houseID == id then
      return v.zoneID
    end
  end
end


--[[------------------------------------------------------------------------------------------------
HDM:GetHouseIDFromZoneID(id)
Inputs:				id 					    - The ID of the zone to get the house ID of.  
Outputs:			houseID         - The house ID of the zone in question.
Description:	Returns the house ID of the zone with the specified ID.
------------------------------------------------------------------------------------------------]]--
function HDM:GetHouseIDFromZoneID(id)
  local houseID
  for i,v in ipairs(self.Data) do
    if v.zoneID == id then
      return v.houseID
    end
  end
end


--[[------------------------------------------------------------------------------------------------
HDM:GetHouseNamesList()
Inputs:				None
Outputs:			Names       		- Table of house names in order of index.
Description:	Returns a table of house names for the purposes of creating drowpdown menus.
------------------------------------------------------------------------------------------------]]--
function HDM:GetHouseNamesList()
  local Names = {}
  for i,v in ipairs(self.Data) do
    table.insert(Names, v.name)
  end
  return Names
end


--[[------------------------------------------------------------------------------------------------
HDM:GetHouseIDList()
Inputs:				None
Outputs:			IDs       		  - Table of house IDs in order of index.
Description:	Returns a table of house IDs for the purposes of creating drowpdown menus.
------------------------------------------------------------------------------------------------]]--
function HDM:GetHouseIDList()
  local IDs = {}
  for i,v in ipairs(self.Data) do
    table.insert(IDs, v.houseID)
  end
  return IDs
end


--[[------------------------------------------------------------------------------------------------
HDM:GetParent()
Inputs:				None
Outputs:			Parent          - The parent object of this object.
Description:	Returns the parent object of this object for reference to parent variables.
------------------------------------------------------------------------------------------------]]--
function HDM:GetParent()
  return self.Parent
end


--[[------------------------------------------------------------------------------------------------
StaticsRecruiterInitHouseDataManager(Parent)
Inputs:				Parent          - The parent object of the object to be created.
Outputs:			FDM             - The new object created.
Description:	Global function to create a new instance of this object.
------------------------------------------------------------------------------------------------]]--
function StaticsRecruiterInitHouseDataManager(Parent)
  return HDM:New(Parent)
end