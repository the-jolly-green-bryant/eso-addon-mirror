--[[------------------------------------------------------------------------------------------------
Zone Data Manager
------------------------------------------------------------------------------------------------]]--
local ZDM = ZO_InitializingObject:Subclass()


--[[------------------------------------------------------------------------------------------------
ZDM:Initialize(Parent)
Inputs:				Parent 					- The parent object containing other required information.  
Outputs:			None
Description:	Initializes all of the variables and tables.
------------------------------------------------------------------------------------------------]]--
function ZDM:Initialize(Parent)
  self.Parent = Parent
  self.Data = {
    -- [index] = {zoneID} -- Zone Name
    -- Aldmeri Dominion
      [1] = {zoneID = 537},   -- Khenarthi's Roost
      [2] = {zoneID = 381},   -- Auridon
      [3] = {zoneID = 383},   -- Grahtwood
      [4] = {zoneID = 108},   -- Greenshade
      [5] = {zoneID = 58},    -- Malabal Tor
      [6] = {zoneID = 382},   -- Reaper's March
    -- Daggerfall Covenant
      [7] = {zoneID = 534},   -- Stros M'Kai
      [8] = {zoneID = 535},   -- Betnikh
      [9] = {zoneID = 3},     -- Glenumbra
      [10] = {zoneID = 19},   -- Stormhaven
      [11] = {zoneID = 20},   -- Rivenspire
      [12] = {zoneID = 104},  -- Alik'r Desert
      [13] = {zoneID = 92},   -- Bangkorai
    -- Ebonheart Pact
      [14] = {zoneID = 280},  -- Bleakrock Isle
      [15] = {zoneID = 281},  -- Bal Foyen
      [16] = {zoneID = 41},   -- Stonefalls
      [17] = {zoneID = 57},   -- Deshaan
      [18] = {zoneID = 117},  -- Shadowfen
      [19] = {zoneID = 101},  -- Eastmarch
      [20] = {zoneID = 103},  -- The Rift
    -- DLC/Other
      [21] = {zoneID = 347},  -- Coldharbour
      [22] = {zoneID = 888},  -- Craglorn
      [23] = {zoneID = 684},  -- Wrothgar
      [24] = {zoneID = 816},  -- Hew's Bane
      [25] = {zoneID = 823},  -- Gold Coast
      [26] = {zoneID = 849},  -- Vvardenfell
      [27] = {zoneID = 980},  -- Clockwork City
      [28] = {zoneID = 1011}, -- Summerset
      [29] = {zoneID = 726},  -- Murkmire
      [30] = {zoneID = 1086}, -- Northern Elseweyr
      [31] = {zoneID = 1133}, -- Southern Elsweyr
      [32] = {zoneID = 1160}, -- Western Skyrim
      [33] = {zoneID = 1161}, -- Blackreach: Greymoor
      [34] = {zoneID = 1207}, -- The Reach
      [35] = {zoneID = 1208}, -- Blackreach: Arkthzand
      [36] = {zoneID = 1261}, -- Blackwood
      [37] = {zoneID = 1282}, -- Fargrave
      [38] = {zoneID = 1286}, -- The Deadlands
      [39] = {zoneID = 1318}, -- High Isle
      [40] = {zoneID = 1383}, -- Galen
      [41] = {zoneID = 1414}, -- Telvanni Peninsula
      [42] = {zoneID = 1413}, -- Apocrypha
      [43] = {zoneID = 1443}, -- West Weald
      [44] = {zoneID = 1502}, -- Solstice
      [45] = {zoneID = 1559}, -- Night Market
  }

  self:Update()
end


--[[------------------------------------------------------------------------------------------------
ZDM:Update()
Inputs:				None
Outputs:			None
Description:	Updates the internal zone data.
------------------------------------------------------------------------------------------------]]--
function ZDM:Update()
	for i,v in ipairs(self.Data) do
		v.name = GetZoneNameById(v.zoneID)
    v.zoneIndex = GetZoneIndex(v.zoneID)
    v.numPOIs = GetNumPOIs(v.zoneIndex)
    v.Wayshrines = {}
  end
  for i=1, GetNumFastTravelNodes() do
    if HasCompletedFastTravelNodePOI(i) then
      local zoneIndex, _ =  GetFastTravelNodePOIIndicies(i)
      local zoneID = GetZoneId(zoneIndex)
      for j,k in ipairs(self.Data) do
        if k.zoneID == zoneID then
          table.insert(k.Wayshrines, i)
        end
      end
    end
  end
	table.sort(self.Data, function(k1, k2) return k1.name < k2.name end)
end


--[[------------------------------------------------------------------------------------------------
ZDM:GetWayshrineInZone(zoneID)
Inputs:				zoneID            - The zone ID to look for a wayshrine in.  
Outputs:			Wayshrine         - The wayshrine index found (nillable).
Description:	Returns the index of a wayshrine found that the player knows in the specified zone or
              nil.
------------------------------------------------------------------------------------------------]]--
function ZDM:GetWayshrineInZone(zoneID)
	for i,v in ipairs(self.Data) do
		if zoneID == v.zoneID then
      return v.Wayshrines[1]
    end
	end
  return nil
end


--[[------------------------------------------------------------------------------------------------
ZDM:GetZoneName(id)
Inputs:				id 					    - The ID of the zone to get the name of.  
Outputs:			name            - The name of the zone in question.
Description:	Returns the name of the zone with the specified ID.
------------------------------------------------------------------------------------------------]]--
function ZDM:GetZoneName(id)
  for i,v in pairs(self.Data) do
		if id == v.zoneID then
      return v.name
    end
	end
end


--[[------------------------------------------------------------------------------------------------
ZDM:GetPlayerZoneID()
Inputs:				None
Outputs:			zoneID          - The current zone ID of the player.
Description:	Returns the current zone ID of the player.
------------------------------------------------------------------------------------------------]]--
function ZDM:GetPlayerZoneID()
  return GetZoneId(GetUnitZoneIndex("player"))
end


--[[------------------------------------------------------------------------------------------------
ZDM:DoesPlayerLocationMatch(destination)
Inputs:				destination     - The location to check against the player location.
Outputs:			match           - True if the destination matches the player location.
Description:	Returns the current zone ID of the player.
------------------------------------------------------------------------------------------------]]--
function ZDM:DoesPlayerLocationMatch(destination)
  local match = false
  if self:GetPlayerZoneID() == destination then match = true end
  return match
end


--[[------------------------------------------------------------------------------------------------
ZDM:GetParent()
Inputs:				None
Outputs:			Parent          - The parent object of this object.
Description:	Returns the parent object of this object for reference to parent variables.
------------------------------------------------------------------------------------------------]]--
function ZDM:GetParent()
  return self.Parent
end


--[[------------------------------------------------------------------------------------------------
StaticsRecruiterInitZoneDataManager(Parent)
Inputs:				Parent          - The parent object of the object to be created.
Outputs:			FDM             - The new object created.
Description:	Global function to create a new instance of this object.
------------------------------------------------------------------------------------------------]]--
function StaticsRecruiterInitZoneDataManager(Parent)
   return ZDM:New(Parent)
end