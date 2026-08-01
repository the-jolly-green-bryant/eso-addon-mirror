local themeName = "AccurateWorldMap"


_G[ themeName ] = {
   name = themeName,
   displayName = "Accurate World Map",
   author = "|C7851A9Xiokro|r, |C42ffbdVylaera|r & |C8587FFThal-J|r(EU)",
   version = 2606160000,
   slashCommand = "/accurateworldmap",
   website = "https://github.com/sheumais/AccurateWorldMap",
   prefix = "AccurateWorldMap",
   dependencies = { LibMapThemer_Core },
   maps = { },
   renames = { },
   mapDescriptions = { },
   overrides = { },
   callbacks = { },
   options = {
      --fontName = "Univers67",
      --fontColor = { 1.0, 1.0, 1.0, 1.0, },
      --fontSize = 18,
      aurbisZoneNames = true,
      tamrielZoneNames = true,
      renames = true,
      mapDescriptions = true,
      storyIndexes = false,
      -- hoverFadeEffect = true,
      disablePoiGlow = false,
      showAllPois = false,
      pois = {
         majorSettlements = false,
         guildShrines = false,
      },
   },
   ["IsRenamesEnabled"] = function ( self )
      return self:GetOptions().renames
   end,
   ["IsMapDescriptionsEnabled"] = function ( self )
      return self:GetOptions().mapDescriptions
   end,
   ["IsStoryIndexesEnabled"] = function ( self )
      return self:GetOptions().storyIndexes
   end,
   zoneColors = { 0, 1, 0, 1 }
}

local theme = _G[ themeName ]
local prefix = theme.prefix
local maps = theme.maps
local renames = theme.renames
local mapDescriptions = theme.mapDescriptions
local overrides = theme.overrides
local callbacks = theme.callbacks

-- -- Fade at top of map when mousehovered --
-- local AWM_MouseOverGrungeTex = CreateControl( "AWM_MouseOverGrungeTex", ZO_WorldMap, CT_TEXTURE )
-- AWM_MouseOverGrungeTex:SetTexture( prefix.."/misc/gamepad_shadow.dds" )
-- AWM_MouseOverGrungeTex:SetAlpha( 0.45 ) -- or 0.65
-- AWM_MouseOverGrungeTex:SetDrawTier( 0 )
-- AWM_MouseOverGrungeTex:SetDrawLayer( 1 )
-- AWM_MouseOverGrungeTex:SetHidden( false )

-- callbacks[ "OnWorldMapChanged" ] = function ( self )
--    local mapWidth, mapHeight = ZO_WorldMapContainer:GetDimensions()
--    AWM_MouseOverGrungeTex:ClearAnchors()
--    AWM_MouseOverGrungeTex:SetAnchor( TOPLEFT, ZO_WorldMap, TOPLEFT, 0, 0 )
--    AWM_MouseOverGrungeTex:SetDimensions( mapWidth, mapHeight )
--    AWM_MouseOverGrungeTex:SetHidden( true )
-- end

-- overrides[ "GetMapMouseoverInfo" ] = function ( self, output, ... )
--    output = _G[ "LibMapThemer_Overrides" ][ "overrides" ][ "GetMapMouseoverInfo" ]( self, output, ... )
--    local visible = (self:GetOptions().hoverFadeEffect and output[1] and output[1] ~= '') --or AWM_MouseOverGrungeTex:GetText() ~= ''
--    AWM_MouseOverGrungeTex:SetHidden( not visible )
--    return output
-- end

local canRedrawMap = true
callbacks[ "OnWorldMapChanged" ] = function ( self )
   if canRedrawMap then
      local mapWidth, mapHeight = ZO_WorldMapContainer:GetDimensions()
      local mapDescPaddingAmount = mapWidth * 0.11
      ZO_WorldMapMouseOverDescription:SetFont("ZoFontGameLargeBold")
      ZO_WorldMapMouseOverDescription:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
      ZO_WorldMapMouseOverDescription:ClearAnchors()
      ZO_WorldMapMouseOverDescription:SetAnchor(TOPLEFT, ZO_WorldMapMouseoverName, BOTTOMLEFT, mapDescPaddingAmount, 2)
      ZO_WorldMapMouseOverDescription:SetAnchor(TOPRIGHT, ZO_WorldMapMouseoverName, BOTTOMRIGHT, -(mapDescPaddingAmount), 4)

      -- AWM_MouseOverGrungeTex:ClearAnchors()
      -- AWM_MouseOverGrungeTex:SetAnchor(TOPLEFT, ZO_WorldMap, TOPLEFT, 0, 0)
      -- AWM_MouseOverGrungeTex:SetDimensions(mapWidth, mapHeight)

      -- -- set up label description background
      -- if (IsInGamepadPreferredMode()) then
      --    AWM_MouseOverGrungeTex:SetTexture("AccurateWorldMap/misc/gamepad_shadow.dds")
      --    AWM_MouseOverGrungeTex:SetAlpha(0.65)
      -- else
      --    AWM_MouseOverGrungeTex:SetTexture("AccurateWorldMap/misc/pc_shadow.dds")
      --    AWM_MouseOverGrungeTex:SetAlpha(0.45)
      -- end

      -- AWM_MouseOverGrungeTex:SetDrawTier(DT_PARENT)
      -- AWM_MouseOverGrungeTex:SetDrawLayer(DL_OVERLAY)
      -- AWM_MouseOverGrungeTex:SetDrawLayer(DL_CONTROLS)
      -- AWM_MouseOverGrungeTex:SetHidden(true)

      -- hide edge overlay if not in gamepad
      ZO_WorldMapContainerRaggedEdge:SetHidden(not IsInGamepadPreferredMode())
      canRedrawMap = false
   end
end


overrides[ "GetFastTravelNodeInfo" ] = function ( self, output, nodeIndex )
   output[ 2 ] = self:GetRename( output[2] ) or output[2]
   if self:GetOptions().disablePoiGlow then output[6] = nil end
   local map = self:GetCurrentMap()
   if map and map:IsMapTamriel() then
      local poi = map:GetPoiById( nodeIndex ) -- can be nil
      if poi and poi:GetLocation() then
         local xN, yN = poi:GetLocation()
         if xN ~= nil and yN ~= nil then
            output[ 3 ], output[ 4 ] = xN, yN
         else
            output[ 3 ], output[ 4 ] = self:GetFixedGlobalCoordinates( self:GetGlobalCoordinates( nodeIndex ) )
         end
      else
         output[ 3 ], output[ 4 ] = self:GetFixedGlobalCoordinates( self:GetGlobalCoordinates( nodeIndex ) )
      end
      if output[7] == POI_TYPE_WAYSHRINE then
         if poi then
            output[8] = poi:IsEnabled()
         elseif GetFastTravelNodeMapPriority( nodeIndex ) == 0 then
            output[8] = false
         end
      end
      if poi then
         output[ 2 ] = poi:GetRename() or output[2]
      end
   end
   -- 1      2     3            4            5     6         7        8
   -- known, name, normalizedX, normalizedY, icon, glowIcon, poiType, isLocatedInCurrentMap
   return output
end

-- https://github.com/esoui/esoui/blob/990654b6b54471de5bcdc576b163895518882510/esoui/ingame/map/worldmap.lua#L2331
overrides[ "GetFastTravelNodeMapPriority" ] = function( self, output, nodeIndex )
   local map = self:GetCurrentMap()
   if map and map:IsMapTamriel() then
      local poi = map:GetPoiById( nodeIndex )
      if poi then
         local options = self:GetOptions()
         if (poi:IsMajorSettlement() and options and options.pois.majorSettlements)
         or (poi:IsGuildShrine() and options and options.pois.guildShrines) then
            output[1] = nil
         end
      end
   end
   return output
end

-- disable for now, can add settings functionality later 
-- https://github.com/esoui/esoui/blob/990654b6b54471de5bcdc576b163895518882510/esoui/ingame/map/worldmap.lua#L4576
overrides[ "GetMapBlobNameInfo" ] = function(self, output, blobIndex)
   output[1] = ""
   return output
end

-- quadratic equation fit to selected quest point data. it's still pretty innacurate but whatever.
-- I hoped that a bounding box -> bounding box transform would be better, but the terrain between the two maps is quite different
-- I should revisit this in future and try again.
local function TransformAurbisCoords(x, y)
    local newX = -0.181551 * x * x + 1.131831 * x - 0.003232
    local newY = 0.432271 * y * y + 0.472330 * y + 0.143525
    return newX, newY
end

overrides["WORLD_MAP_QUEST_BREADCRUMBS.AddQuestConditionPosition"] = function(self, output, _self, conditionData, positionData)
   local map = self:GetCurrentMap()
   if map and positionData and positionData.xLoc and positionData.yLoc then
      local isTamriel = map:IsMapTamriel()
      local isAurbis = map:IsMapAurbis()
      if isTamriel or isAurbis then
         local _, _, _, _, _, _, mapId = GetMapMouseoverInfo(positionData.xLoc, positionData.yLoc)
         if mapId then
            local x, y = self:GetFixedGlobalCoordinates(mapId, positionData.xLoc, positionData.yLoc)
            if isAurbis then
               local mapFromId = map:GetZoneById(mapId)
               if mapFromId and mapId ~= 27 then
                  local xN, yN, widthX, heightY = mapFromId:GetBounds()
                  positionData.xLoc, positionData.yLoc = xN + widthX / 2, yN + heightY / 2
               elseif mapId == 27 then
                  positionData.xLoc, positionData.yLoc = TransformAurbisCoords(x, y)
               end
            elseif x and y then
               positionData.xLoc, positionData.yLoc = x, y
            end
         end
      end
   end
   return output
end

overrides[ "GetMapPlayerPosition" ] = function( self, output, unitTag )
   local playerMapId = self:GetPlayerMapIdFromUnitTag( unitTag )
   local map = self:GetCurrentMap()

   if map and map:IsMapTamriel() then
      output[1], output[2] = self:GetFixedGlobalCoordinates( playerMapId, output[1], output[2] )
   end

   if playerMapId == 108 then -- show player in eyevea
      output[4] = true
   end

   if map and map:IsMapAurbis() then
      local _, _, _, _, _, _, mapId = GetMapMouseoverInfo(output[1], output[2])
      local mapFromId = map:GetZoneById(mapId)

      if mapFromId and mapId ~= 27 then
         local xN, yN, widthX, heightY = mapFromId:GetBounds()
         output[1], output[2] = xN + widthX / 2, yN + heightY / 2
         return output
      elseif mapId == 27 then
         local x, y = self:GetFixedGlobalCoordinates(mapId, output[1], output[2])
         output[1], output[2] = TransformAurbisCoords(x, y)
         return output
      end
   end

   -- 1            2            3          4
   -- normalizedX, normalizedY, direction, isShownInCurrentMap
   return output
end

-- Aurbis --
maps[ 439 ] = {
   zones = { },
   customMaxZoom = 6,
   tilePath = prefix.."/tiles/aurbis/Aurbis_",
   ["IsZoneNamesEnabled"] = function ( self )
      return self:GetOptions().aurbisZoneNames
   end
}

-- Tamriel --
maps[ 27 ] = {
   pois = { },
   zones = { },
   tilePath = prefix.."/tiles/tamriel/Tamriel_",
   ["IsZoneNamesEnabled"] = function ( self )
      return self:GetOptions().tamrielZoneNames
   end
}

-- Imperial City --
maps[ 660 ] = {
   zones = { },
   tileOverrides = {
      [1] = prefix.."/tiles/imperialcity/ImperialCity_1.dds",
   },
}

-- The Reach --
maps[ 1814 ] = {
   tileOverrides = {
      [9] = prefix.."/tiles/reach/reach_base_08.dds",
      [10] = prefix.."/tiles/reach/reach_base_09.dds",
      [14] = prefix.."/tiles/reach/reach_base_13.dds",
      [15] = prefix.."/tiles/reach/reach_base_14.dds",
   },
}

-- Daggerfall Covenant --
mapDescriptions[ 201 ]  = "The island of Stros M'Kai was one of the first regions settled by the Redguards when they sailed east from their lost homeland of Yokuda."
mapDescriptions[ 227 ]  = "Originally called Betony, this isle was conquered by the Seamount Orcs, who then renamed it to Betnikh."
mapDescriptions[ 1 ]    = "Glenumbra is the westernmost peninsula of High Rock and contains the city-states of Daggerfall and Camlorn."
mapDescriptions[ 12 ]   = "Stormhaven is the geographic center of High Rock, and also the home of the great trading city of Wayrest, capital of the Daggerfall Covenant."
mapDescriptions[ 10 ]   = "This northwestern region of High Rock contains some of the province's most dramatic terrain, including towering, flinty crags, windswept moors, and narrow canyons."
mapDescriptions[ 30 ]   = "The Alik'r may be rich in mineral resources, but its fierce creatures and harsh terrain are too daunting for most."
mapDescriptions[ 20 ]   = "This region takes its name from its most famous feature, the Bangkorai Pass, which has served as High Rock's defense against the wild raiders of Hammerfell for generations."

-- Ebonheart Pact --
mapDescriptions[ 74]    = "Bleakrock Isle may seem like a quaint fishing island but its strategic importance cannot be understated - sitting in the mouth of the Yorgrim River, \nit acts as a chokepoint for all vessels entering or leaving the port of Windhelm, and is a gateway east to Morrowind."
mapDescriptions[ 75 ]   = "This region is known as Bal Foyen, a wild expanse of marshland and volcanic landscapes, now being used to farm saltrice by the Dark Elves' former Argonian slaves."
mapDescriptions[ 7 ]    = "This ashy region of Morrowind known as Stonefalls was where the recent invading army from Akavir met its bloody end."
mapDescriptions[ 13 ]   = "The fertile valleys of Deshaan are home to lush fungal forests, deep kwama mines, and broad pastures where netches and guar graze."
mapDescriptions[ 26 ]   = "Shadowfen has had more contact with Tamrielic civilisation than most of Black Marsh, primarily due to the activities of the Dunmeri slavers who once operated here."
mapDescriptions[ 61 ]   = "Eastmarch is the first of Old Holds - the earliest regions of Skyrim settled by the Nords when they arrived from Atmora."
mapDescriptions[ 125 ]  = "The southeastern hold of Skyrim, The Rift is a temperate region northwest of the intersection between the Jerall Mountains and the Velothi Mountains - which house the gateway to Morrowind."

-- Aldmeri Dominion --
mapDescriptions[ 258 ]  = "This island off the southern coast of Elsweyr is named after the Khajiiti goddess of weather and the sky, who is usually represented as a great hawk."
mapDescriptions[ 143 ]  = "The second largest island of the Summerset Isles, Auridon has always served the High Elves as a buffer between their serene archipelago and the turmoil of Tamriel."
mapDescriptions[ 9 ]    = "This region is the southern heart of the Wood Elves' great forest, and home to more of the gigantic graht-oaks than any other part of Valenwood."
mapDescriptions[ 300 ]  = "Home to many tribal Bosmer, flowing rivers and fertile plains occupy this portion of Valenwood."
mapDescriptions[ 22 ]   = "This region is dotted with numerous smaller Bosmeri settlements, and bounded on the north by the the mouth of the Strid River, which empties into the Abecean Sea."
mapDescriptions[ 256 ]  = "Once known simply as Northern Valenwood, this region that borders Cyrodiil and Anequina has seen much bloody warfare."

-- Islands --
mapDescriptions[ 2143 ] = "This island, also known as Emeric's Retreat, is used as a getaway by High King Emeric for when he wants to escape the pressures of running the Daggerfall Covenant."
mapDescriptions[ 1864 ] = "The frozen island of Grayhome is home to an ornate castle, formerly occupied by the Gray Host."
mapDescriptions[ 415 ]  = "In the past, the lonesome island of Stirk has been claimed by Valenwood, the Gold Coast, Hammerfell, and even the Ayleids."
mapDescriptions[ 108 ]  = "Originally an island belonging to the Summerset Isles, Eyevea now serves as the home of the Mages Guild."

-- Misc --
mapDescriptions[ 439 ]  = "The Aurbis is all the cosmos as created by Anu and Padomay. It is known as the Wheel, with Mundus as the hub and the Eight Divines as the spokes."
mapDescriptions[ 27 ]   = "In the ancient tongues, the land called 'Tamriel' means 'Dawn's Beauty'."
mapDescriptions[ 255 ]  = "The dreadful Oblivion plane of Coldharbour is Molag Bal's realm of death, despair, and infinite cruelty."
mapDescriptions[ 16 ]   = "With the Empire's collapse, armies of the Dominion, Covenant, and Pact have all invaded the Heartlands of Cyrodiil, vying for the Imperial throne."

mapDescriptions[ 103 ]  = "Situated in the Druadach Mountains between The Reach and Bangkorai, the Earth Forge is home to a secret Dwemer ruin. Now though, it is maintained by the Fighters Guild."
mapDescriptions[ 1552 ] = "Norg-Tzel, which means 'forbidden place' in the Argonian tongue, has much the same climate and terrain as the region of Black Marsh known as Murkmire."
mapDescriptions[ 1997 ] = "This island is most renowned as the site of the Direnni Tower, formerly the Adamantine Tower, the oldest known structure in Tamriel."
renames[ 1737 ] = "Icereach"
mapDescriptions[ 1737 ] = "These frigid isles serves as the seat of power for the cruel Icereach Coven."
mapDescriptions[ 1325 ] = "The home of a powerful scrying device which also causes inclement weather."
mapDescriptions[ 2164 ] = "An untouched islet on the far fringes of the Systres Archipelago inhabited by birds and beasts."


-- Chapters
mapDescriptions[ 1060 ] = "This sprawling volcanic island dominates northern Morrowind, with the ever-smoldering peak of Red Mountain at its centre."
renames[ 1349 ] = "Summerset Isles"
mapDescriptions[ 1349 ] = "The land called Summerset is the birthplace of civilisation and magic as we know it in Tamriel."
mapDescriptions[ 1429 ] = "Home to the Psijic Order, this island was formerly part of the Summerset Isles, but disappeared from Nirn several centuries ago under mysterious circumstances."
renames[ 1555 ] = "Anequina"
mapDescriptions[ 1555 ] = "The region of Anequina derives its name from the dusty Ne-Quin-Al desert, which lies in its heart."
mapDescriptions[ 1684 ] = "This unassuming island off the southern coast of Elsweyr is known to house the ancient ruins of Fort Vashr - a former Dragonguard stronghold."
mapDescriptions[ 1719 ] = "This cold and unforgiving land consists of the holds of Haafingar, Karthald, and Hjaalmarch."
mapDescriptions[ 1782 ] = "A legendary and long-forgotten realm that extends beneath Skyrim - and perhaps beyond."
mapDescriptions[ 1887 ] = "Straddling the great Niben River and extending east into the bogs of the Argonian homeland, the region serves as the maritime gate to Cyrodiil."
mapDescriptions[ 2114 ] = "High Isle is the largest island in the Systres Archipelago, and serves as the center of politics and commerce for the region."
renames[ 2274 ] = "Central Highlands"
mapDescriptions[ 2274 ] = "This region is the traditional homeland of Morrowind's Great House Indoril. Many Dunmer pilgrims travel this land, to pay respect at the City of the Dead, Necrom."
mapDescriptions[ 2275 ] = "Hermaeus Mora's infinite realm is haunted by the ghosts of mortals forever searching for knowledge."
mapDescriptions[ 2427 ] = "West Weald encompasses three sub-regions: the Gold Road, the Colovian Highlands, and the emergent jungle Dawnwood."
mapDescriptions[ 2603 ] = "This isolated island was mostly unknown by mainlanders prior to the recent trouble with the revived Worm Cult. Now the Stirk Fellowship has opened the island to trade, diplomacy, and use as a staging ground."

-- DLC --
mapDescriptions[ 1126 ] = "Though occasionally crossed by caravans and Covenant troops going to and from Cyrodiil, this wild region of eastern Hammerfell is otherwise a no-man's-land."
mapDescriptions[ 667 ]  = "The Wrothgar Mountains have been home to northern Tamriel's Orcs since the beginning of recorded history."
mapDescriptions[ 994 ]  = "Prince Hew claimed this Hammerfell peninsula for his own, but when all of his ambitious endeavors ended in failure, the region acquired the nickname Hew's Bane."
mapDescriptions[ 1006 ] = "The Gold Coast has always served as Cyrodiil's gateway to the Abecean Sea, but with the Alliance War, the region has gone its own way."
mapDescriptions[ 1313 ] = "Clockwork City is the mysterious mechanical realm of Sotha Sil, one of the living gods of the Tribunal - its purpose is unknown."
mapDescriptions[ 1484 ] = "Legend holds that the region informally known as Murkmire once extended much further south before it sank beneath the waves."
renames[ 1654 ] = "Pellitine"
mapDescriptions[ 1654 ] = "The Quin'rawl peninsula, the southern-most tip of Elsweyr, has a complex history that stretches back into antiquity."
mapDescriptions[ 1814 ] = "The rocky highlands of the Reach contains savage predators, perilous Dwarven ruins, and hostile Reachmen clans."
mapDescriptions[ 2021 ] = "The princeless realm of Fargrave is known as 'The Celestial Palanquin' - a place where mortal and Daedra alike are free to do whatever they please."
mapDescriptions[ 2119 ] = "The Deadlands is Mehrunes Dagon's realm of unending destruction, fire and storm and disaster personified."
mapDescriptions[ 2212 ] = "Galen, currently controlled by House Monard, has been the home of the druids for thousands of years after their voluntary exile from High Rock."


local tamriel = maps[27]
local tamrielPois = tamriel.pois

tamrielPois[215] = { xN = 0.1525, yN = 0.5607, disabled = false, name = "Eyevea Wayshrine", majorSettlement = true } -- Eyevea Wayshrine
tamrielPois[221] = { xN = 0.36, yN = 0.27, disabled = false, name = "The Earth Forge Wayshrine", majorSettlement = true } -- The Earth Forge Wayshrine
tamrielPois[602] = { xN = 0.3202, yN = 0.5468, disabled = false, majorSettlement = true } -- Stirk Wayshrine

tamrielPois[210] = { disabled = true } -- harborage DC
tamrielPois[211] = { disabled = true } -- harborage
tamrielPois[212] = { disabled = true } -- harborage

tamrielPois[424] = { xN = 0.432, yN = 0.146 } -- Icereach Dungeon
tamrielPois[434] = { xN = 0.438, yN = 0.173 } -- Kyne's Aegis Trial
tamrielPois[521] = { xN = 0.077, yN = 0.567 } -- Graven Deep Dungeon
tamrielPois[520] = { xN = 0.054, yN = 0.568 } -- Earthen Root Enclave Dungeon
tamrielPois[488] = { xN = 0.025, yN = 0.547 } -- Dreadsail Reef Trial
tamrielPois[364] = { xN = 0.180, yN = 0.622 } -- Cloudrest Trial
tamrielPois[534] = { xN = 0.854, yN = 0.450 } -- Sanity's Edge Trial
tamrielPois[247] = { xN = 0.563, yN = 0.455 } -- White Gold Tower Dungeon
tamrielPois[236] = { xN = 0.563, yN = 0.448 } -- Imperial City Prison Dungeon

-------------------------------------------------------------------------------------------------------------------------------------------------
---- Daggerfall Covenant -------- Daggerfall Covenant -------- Daggerfall Covenant -------- Daggerfall Covenant -------- Daggerfall Covenant ----
-------------------------------------------------------------------------------------------------------------------------------------------------

-----------------
-- Stros M'kai --
-----------------
tamrielPois[138] = { majorSettlement = true, guildShrine = true, }  -- Port Hunding Wayshrine

-------------
-- Betnikh --
-------------
tamrielPois[181] = { majorSettlement = true, guildShrine = true }   -- Stonetooth Wayshrine

---------------
-- Glenumbra --
---------------
tamrielPois[1]   = { guildShrine = true, }                          -- Wyrd Tree Wayshrine
tamrielPois[2]   = { majorSettlement = true, }                      -- Aldcroft Wayshrine
tamrielPois[6]   = { guildShrine = true, }                          -- Lionguard Redoubt Wayshrine
tamrielPois[7]   = { majorSettlement = true, }                      -- Crosswyrch Wayshrine
tamrielPois[62]  = { majorSettlement = true, guildShrine = true }   -- Daggerfall Wayshrine

----------------
-- Stormhaven --
----------------
tamrielPois[14]  = { majorSettlement = true, guildShrine = true, }  -- Koeglin Village Wayshrine
tamrielPois[15]  = { majorSettlement = true, }                      -- Alcaire Castle Wayshrine
tamrielPois[16]  = { guildShrine = true, }                          -- Firebrand Keep Wayshrine
tamrielPois[22]  = { majorSettlement = true, }                      -- Wind Keep Wayshrine
tamrielPois[56]  = { majorSettlement = true, guildShrine = true, }  -- Wayrest Wayshrine

----------------
-- Rivenspire --
----------------
tamrielPois[9]   = { guildShrine = true }                           -- Oldgate Wayshrine
tamrielPois[10]  = { majorSettlement = true, }                      -- Crestshade Wayshrine
tamrielPois[55]  = { majorSettlement = true, guildShrine = true, }  -- Shornhelm Wayshrine
tamrielPois[82]  = { majorSettlement = true, }                      -- Northpoint Wayshrine
tamrielPois[84]  = { majorSettlement = true, guildShrine = true, }  -- Hoarfrost Downs Wayshrine

----------------
-- The Alik'r --
----------------
tamrielPois[42]  = { guildShrine = true, }                          -- Morwha's Bounty Wayshrine
tamrielPois[43]  = { majorSettlement = true, guildShrine = true, }  -- Sentinel Wayshrine
tamrielPois[44]  = { majorSettlement = true, guildShrine = true, }  -- Bergama Wayshrine
tamrielPois[46]  = { majorSettlement = true, }                      -- Satakalaam Wayshrine

---------------
-- Bangkorai --
---------------
tamrielPois[33]  = { majorSettlement = true, } -- Evermore Wayshrine
tamrielPois[36]  = { guildShrine = true, } -- Bangkorai Pass Wayshrine
tamrielPois[38]  = { majorSettlement = true, guildShrine = true, } -- Hallin's Stand Wayshrine
tamrielPois[204] = { guildShrine = true, } -- Eastern Evermore Wayshrine

------------------------------------------------------------------------------------------------------------------------------------------------------------
---- Aldmeri Dominion -------- Aldmeri Dominion -------- Aldmeri Dominion -------- Aldmeri Dominion -------- Aldmeri Dominion -------- Aldmeri Dominion ----
------------------------------------------------------------------------------------------------------------------------------------------------------------

-----------------------
-- Khenarthi's Roost --
-----------------------
tamrielPois[142] = { majorSettlement = true, } -- Mistral Wayshrine

-------------
-- Auridon --
-------------
tamrielPois[121] = { majorSettlement = true, guildShrine = true, }  -- Skywatch Wayshrine
tamrielPois[175] = { majorSettlement = true, guildShrine = true, }  -- Firsthold Wayshrine
tamrielPois[176] = { majorSettlement = true, }                      -- Mathiisen Wayshrine
tamrielPois[177] = { majorSettlement = true, guildShrine = true, }  -- Vulkhel Guard Wayshrine

---------------
-- Grahtwood --
---------------
tamrielPois[164] = { majorSettlement = true, }                      -- Gilvardale Wayshrine
tamrielPois[165] = { majorSettlement = true, }                      -- Haven Wayshrine
tamrielPois[166] = { majorSettlement = true, }                      -- Redfur Trading Post Wayshrine
tamrielPois[167] = { majorSettlement = true, guildShrine = true, }  -- Southpoint Wayshrine
tamrielPois[168] = { majorSettlement = true, guildShrine = true, }  -- Cormount Wayshrine
tamrielPois[214] = { majorSettlement = true, guildShrine = true, }  -- Elden Root Wayshrine

----------------
-- Greenshade --
----------------
tamrielPois[143] = { majorSettlement = true, guildShrine = true, }  -- Marbruk Wayshrine
tamrielPois[147] = { majorSettlement = true, guildShrine = true, }  -- Greenheart Wayshrine
tamrielPois[151] = { majorSettlement = true, guildShrine = true, }  -- Verrant Morass Wayshrine
tamrielPois[152] = { majorSettlement = true, }                      -- Woodhearth Wayshrine

-----------------
-- Malabal Tor --
-----------------
tamrielPois[100] = { majorSettlement = true, }                      -- Vulkwasten Wayshrine
tamrielPois[101] = { guildShrine = true, }                          -- Dra'bul Wayshrine
tamrielPois[102] = { majorSettlement = true, }                      -- Vely Harbour Wayshrine
tamrielPois[106] = { majorSettlement = true, guildShrine = true, } -- Baandari Trading Post Wayshrine    name = "Baandari Trading Post Wayshrine",
tamrielPois[107] = { majorSettlement = true, guildShrine = true, }  -- Valeguard Wayshrine

--------------------
-- Reaper's March --
--------------------
tamrielPois[158] = { majorSettlement = true, }                      -- Arenthia Wayshrine
tamrielPois[144] = { majorSettlement = true, guildShrine = true, }  -- Vinedusk Wayshrine
tamrielPois[159] = { majorSettlement = true, guildShrine = true, }  -- Dune Wayshrine
tamrielPois[162] = { majorSettlement = true, guildShrine = true, }  -- Rawl'kha Wayshrine
tamrielPois[163] = { majorSettlement = true, }                      -- S'ren-ja Wayshrine

------------------------------------------------------------------------------------------------------------------------------------------------
---- Ebonheart Pact -------- Ebonheart Pact -------- Ebonheart Pact -------- Ebonheart Pact -------- Ebonheart Pact -------- Ebonheart Pact ----
------------------------------------------------------------------------------------------------------------------------------------------------

--------------------
-- Bleakrock Isle --
--------------------
tamrielPois[172] = { majorSettlement = true, guildShrine = true } -- Bleakrock Isle Wayshrine

---------------
-- Bal Foyen --
---------------
tamrielPois[173] = { majorSettlement = true, guildShrine = true, } -- Dhalmora Wayshrine

----------------
-- Stonefalls --
----------------
tamrielPois[65] = { majorSettlement = true, guildShrine = true } -- Davon's Watch Wayshrine
tamrielPois[67] = { majorSettlement = true, guildShrine = true } -- Ebonheart Wayshrine
tamrielPois[76] = { majorSettlement = true, guildShrine = true } -- Kragenmoor Wayshrine

-------------
-- Deshaan --
-------------
tamrielPois[24] = { majorSettlement = true, }                    -- West Narsis Wayshrine
tamrielPois[25] = { guildShrine = true, }                        -- Muth Gnaar Hills Wayshrine
tamrielPois[28] = { majorSettlement = true, guildShrine = true } -- Mournhold Wayshrine
tamrielPois[29] = { guildShrine = true, }                        -- Tal'Deic Grounds Wayshrine
tamrielPois[79] = { majorSettlement = true, }                    -- Selfora Wayshrine

---------------
-- Shadowfen --
---------------
tamrielPois[48] = { majorSettlement = true, guildShrine = true, }   -- Stormhold Wayshrine
tamrielPois[50] = { majorSettlement = true, }                       -- Alten Corimont Wayshrine
tamrielPois[52] = { guildShrine = true, }                           -- Hissmir Wayshrine
tamrielPois[78] = { guildShrine = true, }                           -- Venomous Fens Wayshrine

---------------
-- Eastmarch --
---------------
tamrielPois[87] = { majorSettlement = true, guildShrine = true } -- Windhelm Wayshrine
tamrielPois[88] = { majorSettlement = true, }                    -- Fort Morvunskar Wayshrine
tamrielPois[90] = { guildShrine = true, }                        -- Voljar Meadery Wayshrine
tamrielPois[92] = { majorSettlement = true, guildShrine = true } -- Fort Amol Wayshrine

--------------
-- The Rift --
--------------
tamrielPois[114] = { majorSettlement = true, guildShrine = true }   -- Fallowstone Hall Wayshrine
tamrielPois[118] = { majorSettlement = true, guildShrine = true }   -- Nimalten Wayshrine
tamrielPois[116] = { majorSettlement = true, }                      -- Geirmund's Hall Wayshrine
tamrielPois[109] = { majorSettlement = true, guildShrine = true }   -- Riften Wayshrine
tamrielPois[110] = { guildShrine = true, }                          -- Skald's Retreat Wayshrine


------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- Craglorn -------- Craglorn -------- Craglorn -------- Craglorn -------- Craglorn -------- Craglorn -------- Craglorn -------- Craglorn -------- Craglorn ----
------------------------------------------------------------------------------------------------------------------------------------------------------------------

--------------
-- Craglorn --
--------------
tamrielPois[220] = { majorSettlement = true, guildShrine = true, }  -- Belkarth Wayshrine
tamrielPois[229] = { majorSettlement = true, }                      -- Elinhir Wayshrine
tamrielPois[233] = { majorSettlement = true, }                      -- Dragonstar Wayshrine
tamrielPois[270] = { groupArena = true, }                           -- Dragonstar Arena

----------------------------------------------------------------------------------------------------------------------------------------------------------
---- Cyrodiil PvP -------- Cyrodiil PvP -------- Cyrodiil PvP -------- Cyrodiil PvP -------- Cyrodiil PvP -------- Cyrodiil PvP -------- Cyrodiil PvP ----
----------------------------------------------------------------------------------------------------------------------------------------------------------
maps[16] = { pois = { }, }
local cyrodiil = maps[16]
local cyrodiilPois = cyrodiil.pois
--------------
-- Cyrodiil --
--------------
cyrodiilPois[201] = { name = "Western Elsweyr Gate Wayshrine",      majorSettlement = true, } -- Western Elsweyr Wayshrine
cyrodiilPois[200] = { name = "Eastern Elsweyr Gate Wayshrine",      majorSettlement = true, } -- Eastern Elsweyr Wayshrine
cyrodiilPois[202] = { name = "Northern Morrowind Gate Wayshrine",   majorSettlement = true, } -- Northern Morrowind Wayshrine
cyrodiilPois[203] = { name = "Southern Morrowind Gate Wayshrine",   majorSettlement = true, } -- Southern Morrowind Wayshrine
cyrodiilPois[170] = { name = "Northern Hammerfell Gate Wayshrine",  majorSettlement = true, } -- Northern Hammerfell Wayshrine
cyrodiilPois[199] = { name = "Southern Hammerfell Gate Wayshrine",  majorSettlement = true, } -- Southern Hammerfell Wayshrine
tamrielPois[200] = cyrodiilPois[200] tamrielPois[201] = cyrodiilPois[201]
tamrielPois[202] = cyrodiilPois[202] tamrielPois[203] = cyrodiilPois[203]
tamrielPois[170] = cyrodiilPois[170] tamrielPois[199] = cyrodiilPois[199]


----------------------------------------------------------------------------------------------------------------------------------------------------------
---- Orsinium DLC -------- Orsinium DLC -------- Orsinium DLC -------- Orsinium DLC -------- Orsinium DLC -------- Orsinium DLC -------- Orsinium DLC ----
----------------------------------------------------------------------------------------------------------------------------------------------------------

--------------
-- Wrothgar --
--------------
tamrielPois[250] = { soloArena = true, }                            -- Maelstrom Arena
tamrielPois[244] = { majorSettlement = true, guildShrine = true, }  -- Orsinium Wayshrine
tamrielPois[237] = { majorSettlement = true, guildShrine = true, }  -- Shatul Wayshrine

------------------------------------------------------------------------------------------------------------------------------------------------------
---- Thieves Guild DLC / Dark Brotherhood DLC -------- Thieves Guild DLC / Dark Brotherhood DLC -------- Thieves Guild DLC / Dark Brotherhood DLC ----
------------------------------------------------------------------------------------------------------------------------------------------------------

----------------
-- Hew's Bane --
----------------
tamrielPois[255] = { majorSettlement = true, guildShrine = true, } -- Abah's Landing Wayshrine

----------------
-- Gold Coast --
----------------
tamrielPois[251] = { majorSettlement = true, guildShrine = true, }  -- Anvil Wayshrine
tamrielPois[252] = { majorSettlement = true, }                      -- Kvatch Wayshrine

-----------------------------------------------------------------------------------------------------------------------------------------------------------------
---- Morrowind DLC -------- Morrowind DLC -------- Morrowind DLC -------- Morrowind DLC -------- Morrowind DLC -------- Morrowind DLC -------- Morrowind DLC ----
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

-----------------
-- Vvardenfell --
-----------------
tamrielPois[272] = { majorSettlement = true, }                      -- Seyda Neen Wayshrine
tamrielPois[273] = { majorSettlement = true, }                      -- Gnisis Wayshrine
tamrielPois[274] = { majorSettlement = true, }                      -- Ald'ruhn Wayshrine
tamrielPois[275] = { majorSettlement = true, guildShrine = true }   -- Balmora Wayshrine
tamrielPois[276] = { majorSettlement = true, }                      -- Suran Wayshrine
tamrielPois[277] = { majorSettlement = true, }                      -- Molag Mar Wayshrine
tamrielPois[278] = { majorSettlement = true, }                      -- Tel Branora Wayshrine
tamrielPois[280] = { majorSettlement = true, }                      -- Tel Mora Wayshrine
tamrielPois[281] = { majorSettlement = true, guildShrine = true }   -- Sadrith Mora Wayshrine
tamrielPois[284] = { majorSettlement = true, guildShrine = true }   -- Vivec City Wayshrine

-----------------------------------------------------------------------------------------------------------------------------------------------------------------
---- Summerset DLC -------- Summerset DLC -------- Summerset DLC -------- Summerset DLC -------- Summerset DLC -------- Summerset DLC -------- Summerset DLC ----
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------
-- Summerset --
---------------
tamrielPois[350] = { majorSettlement = true, guildShrine = true, }  -- Shimmerene Wayshrine
tamrielPois[354] = { majorSettlement = true, }                      -- Ebon Stadmont Wayshrine
tamrielPois[355] = { majorSettlement = true, guildShrine = true, }  -- Alinor Wayshrine
tamrielPois[356] = { majorSettlement = true, guildShrine = true, }  -- Lilandril Wayshrine
tamrielPois[365] = { majorSettlement = true, }                      -- Sunhold Wayshrine
tamrielPois[373] = { xN = 0.236, yN = 0.862, disabled = true, }     -- Grand Psijic Villa

--------------
-- Murkmire --
--------------
tamrielPois[374] = { majorSettlement = true, guildShrine = true, }  -- Lilmoth Wayshrine
tamrielPois[375] = { majorSettlement = true, }                      -- Bright-Throat Wayshrine
tamrielPois[376] = { majorSettlement = true, }                      -- Dead-Water Wayshrine
tamrielPois[378] = { groupArena = true, }                           -- Blackrose Prison

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- Elsweyr DLC -------- Elsweyr DLC -------- Elsweyr DLC -------- Elsweyr DLC -------- Elsweyr DLC -------- Elsweyr DLC -------- Elsweyr DLC -------- Elsweyr DLC ----
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------
-- Northern Elsweyr --
----------------------
tamrielPois[381] = { majorSettlement = true, }                      -- Riverhold Wayshrine Wayshrine
tamrielPois[382] = { majorSettlement = true, guildShrine = true, }  -- Rimmen Wayshrine
tamrielPois[383] = { majorSettlement = true, }                      -- The Stitches Wayshrine
tamrielPois[387] = { majorSettlement = true, }                      -- Hakoshae Wayshrine

----------------------
-- Southern Elsweyr --
----------------------
tamrielPois[402] = { majorSettlement = true, guildShrine = true, }  -- Senchal Wayshrine
tamrielPois[405] = { majorSettlement = true, }                      -- Black Heights Wayshrine

--------------
-- Tideholm --
--------------
tamrielPois[407] = { majorSettlement = true, }                      -- Dragonguard Sanctum Wayshrine

----------------------------------------------------------------------------------------------------------------------------------------------------------
---- Greymoor DLC -------- Greymoor DLC -------- Greymoor DLC -------- Greymoor DLC -------- Greymoor DLC -------- Greymoor DLC -------- Greymoor DLC ----
----------------------------------------------------------------------------------------------------------------------------------------------------------

--------------------
-- Western Skyrim --
--------------------
tamrielPois[421] = { majorSettlement = true, guildShrine = true }   -- Solitude Wayshrine
tamrielPois[416] = { majorSettlement = true, }                      -- Morthal Wayshrine
tamrielPois[417] = { majorSettlement = true, }                      -- Morkazgur Wayshrine
tamrielPois[418] = { majorSettlement = true, }                      -- Dragonbridge Wayshrine
tamrielPois[419] = { majorSettlement = true, }                      -- Southern Watch Wayshrine

---------------
-- The Reach --
---------------
tamrielPois[445] = { majorSettlement = true, }                      -- Karthwasten Wayshrine
tamrielPois[449] = { majorSettlement = true, guildShrine = true }   -- Markarth Wayshrine
tamrielPois[457] = { soloArena = true, }                            -- Vateshran Hollows

-----------------------------------------------------------------------------------------------------------------------------------------------------------------
---- Blackwood DLC -------- Blackwood DLC -------- Blackwood DLC -------- Blackwood DLC -------- Blackwood DLC -------- Blackwood DLC -------- Blackwood DLC ----
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------
-- Blackwood --
---------------
tamrielPois[483] = { majorSettlement = true, } -- Hutan-Tzel Wayshrine
tamrielPois[459] = { majorSettlement = true, } -- Gideon Wayshrine
tamrielPois[464] = { majorSettlement = true, } -- Stonewastes Wayshrine
tamrielPois[458] = { majorSettlement = true, guildShrine = true } -- Leyawiin Wayshrine

--------------------------------------------------------------------------------------------------------------------------------------------------------
---- High Isle DLC / Firesong DLC -------- High Isle DLC / Firesong DLC -------- High Isle DLC / Firesong DLC -------- High Isle DLC / Firesong DLC ----
--------------------------------------------------------------------------------------------------------------------------------------------------------

--------------------------
-- High Isle and Amenos --
--------------------------
tamrielPois[513] = { majorSettlement = true, guildShrine = true, } -- Gonfalon Square Wayshrine
tamrielPois[508] = { majorSettlement = true, } -- Amenos Station

------------------------
-- Galen and Y'ffelon --
------------------------
tamrielPois[529] = { majorSettlement = true, guildShrine = true, } -- Vastyr Wayshrine

----------------------------------------------------------------------------------------------------------------------------------------------------------------
---- Necrom DLC -------- Necrom DLC -------- Necrom DLC -------- Necrom DLC -------- Necrom DLC -------- Necrom DLC -------- Necrom DLC -------- Necrom DLC ----
----------------------------------------------------------------------------------------------------------------------------------------------------------------

------------------------
-- Telvanni Peninsula --
------------------------
tamrielPois[536] = { majorSettlement = true, guildShrine = true, }  -- Necrom Wayshrine
tamrielPois[538] = { majorSettlement = true, }                      -- Ald Isra Wayshrine
tamrielPois[554] = { majorSettlement = true, }                      -- Alavelis Wayshrine

------------------------------------------------------------------------------------------------------------------------------------------
---- Gold Road DLC -------- Gold Road DLC -------- Gold Road DLC -------- Gold Road DLC -------- Gold Road DLC -------- Gold Road DLC ----
------------------------------------------------------------------------------------------------------------------------------------------

----------------
-- West Weald --
----------------
tamrielPois[558] = { xN = 0.4625, yN = 0.5030, majorSettlement = true, guildShrine = true, }  -- Skingrad Wayshrine
tamrielPois[560] = { majorSettlement = true, }                      -- Vashabar Wayshrine
tamrielPois[561] = { majorSettlement = true, }                      -- Ontus Wayshrine
-- tamrielPois[562] = { majorSettlement = true, }                      -- Sutch Wayshrine
-- tamrielPois[578] = { majorSettlement = true, }                      -- Ostumir Wayshrine

------------------------------------------------------------------------------------------------------------------------------------
---- Solstice DLC -------- Solstice DLC -------- Solstice DLC -------- Solstice DLC -------- Solstice DLC -------- Solstice DLC ----
------------------------------------------------------------------------------------------------------------------------------------

--------------
-- Solstice --
--------------
tamrielPois[598] = { xN = 0.7015, yN = 0.8638, majorSettlement = true, guildShrine = true, }  -- Sunport Wayshrine
