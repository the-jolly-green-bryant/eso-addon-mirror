local themeName = "LibMapThemer_Overrides"
_G[themeName] = { overrides = { }, }
local theme = _G[themeName]
local overrides = theme.overrides



overrides[ "ZO_WorldMap_GetMapTitle" ] = function ( self, output )
   if self:IsRenamesEnabled() then 
      output[ 1 ] = self:GetRename( output[ 1 ] ) 
   end
   -- 1
   -- mapTitle
   return output
end



overrides[ "GetZoneNameByIndex" ] = function ( self, output, zoneIndex )
   if self:IsRenamesEnabled() then 
      output[ 1 ] = self:GetRename( output[ 1 ] ) 
   end
   -- 1
   -- zoneName
   return output
end



overrides[ "GetJournalQuestLocationInfo" ] = function ( self, output, questIndex )
   if self:IsRenamesEnabled() then 
      output[ 1 ] = self:GetRename( output[ 1 ] ) 
   end
   -- 1
   -- zoneName, objectiveName, zoneIndex, poiIndex
   return output
end



overrides[ "GetMapTileTexture" ] = function ( self, output, tileIndex )
   local map = self:GetCurrentMap()
   if map then output[1] = map:GetTileByIndex( tileIndex ) or output[1] end
   -- 1
   -- mapTileTexture
   return output
end



overrides[ "GetMapCustomMaxZoom" ] = function ( self, output )
   local map = self:GetCurrentMap()
   if map then output[1] = map:GetCustomMaxZoom() or output[1] end
   -- 1
   -- maxZoom
   return output
end



overrides[ "GetMapMouseoverInfo" ] = function ( self, output )
   local zone = self:GetSelectedZone()
   if zone then 
      output[ 1 ] = zone:GetZoneName()
      output[ 2 ] = zone:GetZoneBlob():GetTextureFileName()
      local x, y, width, height = zone:GetBounds()
      if x and y and width and height then 
         output[ 5 ], output[ 6 ] = x, y
         output[ 3 ], output[ 4 ] = width, height 
      end  
   else
      local map = self:GetCurrentMap()
      if map and not map:UseDefaultZones() then
         output[ 1 ] = ''
         output[ 2 ] = ''
         output[ 3 ], output[ 4 ] = 0, 0
         output[ 5 ], output[ 6 ] = 0, 0
      else
         if self:IsRenamesEnabled() then
            output[ 1 ] = self:GetRename( output[ 1 ] )
         end
      end
   end
   -- 1             2            3       4        5      6
   -- locationName, textureFile, widthN, heightN, locXN, locYN
   return output
end



overrides[ "GetMapPlayerWaypoint" ] = function( self, output )
   if self:IsWaypointPlaced() and self:GetCurrentMapId() == 27 then output[1], output[2] = nil, nil end
   -- 1   2
   -- xN, yN
   return output
end



overrides[ "GetMapPlayerPosition" ] = function( self, output, unitTag )
   local playerMapId = self:GetPlayerMapIdFromUnitTag( unitTag )
   local map = self:GetCurrentMap()
   if map and map:IsMapTamriel() then
      output[1], output[2] = self:GetFixedGlobalCoordinates( playerMapId, output[1], output[2] )
   end
   if playerMapId == 108 then output[4] = true end -- show player in eyeva
   -- 1            2            3          4
   -- normalizedX, normalizedY, direction, isShownInCurrentMap
   return output
end



local poi_group_house_owned   = "/esoui/art/icons/poi/poi_group_house_owned.dds"
local poi_group_house_unowned = "/esoui/art/icons/poi/poi_group_house_unowned.dds"
overrides[ "GetFastTravelNodeInfo" ] = function ( self, output, nodeIndex )
   local showAllPois = self:GetOptions().showAllPois
   local poiOptions = self:GetOptions().pois
   output[ 2 ] = self:GetRename( output[2] )
   if self:GetOptions().disablePoiGlow then output[6] = nil end
   local map = self:GetCurrentMap()
   if map and map:IsMapTamriel() then

      output[ 3 ], output[ 4 ] = self:GetFixedGlobalCoordinates( self:GetGlobalCoordinates( nodeIndex ) )
      local poi = map:GetPoiById( nodeIndex )
      if poiOptions then
         if not showAllPois then 
            output[8] = false 
         end
         if showAllPois and poi and poi:IsEnabled() then 
            output[8] = true
         end
         if not showAllPois and not output[8] then
            if output[7] == POI_TYPE_GROUP_DUNGEON and poiOptions.dungeons then
               output[8] = poiOptions.dungeons
            elseif output[7] == POI_TYPE_ACHIEVEMENT and poiOptions.trials then
               output[8] = poiOptions.trials
            elseif output[7] == POI_TYPE_HOUSE then
               if output[5] == poi_group_house_unowned and poiOptions.unownedHouses then 
                  output[8] = poiOptions.unownedHouses
                  --self:Print(output[2].." "..nodeIndex) 
               elseif output[5] == poi_group_house_owned and poiOptions.ownedHouses then 
                  output[8] = poiOptions.ownedHouses 
               end
            elseif poi then
               if output[7] == POI_TYPE_WAYSHRINE then
                  if poi:IsMajorSettlement() and poiOptions.majorSettlements then output[8] = poiOptions.majorSettlements
                  elseif poi:IsGuildShrine() and poiOptions.guildShrines then output[8] = poiOptions.guildShrines end
               elseif poi:IsGroupArena() and poiOptions.groupArenas then output[8] = poiOptions.groupArenas
               elseif poi:IsSoloArena() and poiOptions.soloArenas then output[8] = poiOptions.soloArenas end
            end
            if poi and not poi:IsEnabled() then
               output[8] = false
            end
         end
      end
   end
   -- 1      2     3            4            5     6         7        8
   -- known, name, normalizedX, normalizedY, icon, glowIcon, poiType, isLocatedInCurrentMap
   return output
end



overrides["GetUniversallyNormalizedMapInfo"] = function( self, output, zoneId ) 
   local map = self:GetMapById( 27 )
   --if not map then return output end
   if map then
      local zone = map:GetZoneById( zoneId )
      if zone then
         local x, y, width, height = zone:GetZoneBlob():GetNormalizedMapInfo()
         if x and y and width and height then 
            output[1], output[2], output[3], output[4] = x, y, width, height
         end
      end
   end
   -- 1                  2                  3                4
   -- normalizedOffsetX, normalizedOffsetY, normalizedWidth, normalizedHeight
   return output
end
