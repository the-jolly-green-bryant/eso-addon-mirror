local GPS, LZ, LMP = LibGPS3, LibZone, LibMapPing
local addonName, acronym = "LibMapThemer", "LMT" _G[ addonName ] = { }
local addon = _G[ addonName ]

local versionName, version = "v1.1.6", 2406030600

local chat = LibChatMessage and LibChatMessage( addonName, acronym )
chat = chat or {
   ["Print"] = function( self, msg ) d( msg ) end
}
--[[
   TODO : 
   - fix player markers and cyrodiil battle markers (dunno how to yet, may put on backburner)
   - fix some more bugs that i dont know about

   - wrap more zos controls 

   - add city names to labels
   - add more map widgets/gadgets
   - add debug menu for creating themes easier
   - add the ability to offset the labels
   - add more to the todo list
--]]

--------------------------------------------------------------------------------------------------------------------
--- Options/Current Theme ------ Options/Current Theme ------ Options/Current Theme ------ Options/Current Theme ---
--------------------------------------------------------------------------------------------------------------------

local options, defaults = nil, { _lmt_current_theme_ = '', }
local lmt_allThemes = { }

local function lmt_GetOptions( )
   if not options then
      options = ZO_SavedVars:NewAccountWide( addonName.."Vars", version, addonName, defaults ) 
   end
   return options
end

local function lmt_SetCurrentTheme( themeName ) lmt_GetOptions()._lmt_current_theme_ = themeName end

local function lmt_GetCurrentTheme( ) return lmt_allThemes[ lmt_GetOptions()._lmt_current_theme_ ] end

local function lmt_GetCurrentThemeName( ) return lmt_GetOptions()._lmt_current_theme_ end

----------------------------------------------------------------------------------------------------------------------------
--- Main Update Loop ------ Main Update Loop ------ Main Update Loop ------ Main Update Loop ------ Main Update Loop ------- 
----------------------------------------------------------------------------------------------------------------------------

local function lmt_OnPinCreate( )
   local theme = lmt_GetCurrentTheme()
   if theme then theme:Reset() end
end

local function lmt_OnPinUpdate( )
   local theme = lmt_GetCurrentTheme()
   if theme then
      local map = theme:GetCurrentMap()
      if map then map:Update() end
   end
end

local pinType = "LibMapThemerBlob"

local pinLayout =  { 
   level = 30, size = 32, insetX = 4, insetY = 4,
   texture = "", minAreaSize = 32, showsPinAndArea = true
}

-- TODO Optimize
ZO_WorldMap_AddCustomPin( pinType, lmt_OnPinCreate, lmt_OnPinUpdate, pinLayout )

SecurePostHook( ZO_WorldMap_GetPanAndZoom(), "SetCurrentNormalizedZoomInternal", lmt_OnPinUpdate )

ZO_WorldMap_SetCustomPinEnabled( _G[ pinType ], true )

------------------------------------------------------------------------------------------------------------------
--- Map Navigation ------ Map Navigation ------ Map Navigation ------ Map Navigation ------ Map Navigation ------- 
------------------------------------------------------------------------------------------------------------------
local selectedZone

local function lmt_NavigateToMap( mapId )
   if not mapId then return end
   SetMapToMapId( mapId )
   GPS:SetPlayerChoseCurrentMap()
   CALLBACK_MANAGER:FireCallbacks( "OnWorldMapChanged" )
   ZO_WorldMap_GetPanAndZoom():SetCurrentNormalizedZoom( 0 )
   return true -- return true to show it was successful
end

------------------------------------------------------------------------------------------------------------------
--- Mouse Input ------ Mouse Input ------ Mouse Input ------ Mouse Input ------ Mouse Input ------ Mouse Input ---
------------------------------------------------------------------------------------------------------------------

local function lmt_IsInGamepadMode( ) 
   return IsInGamepadPreferredMode() and not ZO_WorldMapCenterPoint:IsHidden()
end

local function lmt_GetMouseCoordinates( ) 
   if lmt_IsInGamepadMode() then return ZO_WorldMapScroll:GetCenter() end 
   return GetUIMousePosition()
end

local function lmt_GetNormalizeCoordinates( x, y, xN, yN, widthN, heightN )
   local normalizedMouseX = math.floor( ( ( ( x - xN ) / widthN ) * 10000 ) + 0.5 ) / 10000
   local normalizedMouseY = math.floor( ( ( ( y - yN ) / heightN ) * 10000 ) + 0.5 ) / 10000
   return normalizedMouseX, normalizedMouseY 
end

local function lmt_GetNormalizeMouse( xN, yN, widthN, heightN ) 
   local x, y = lmt_GetMouseCoordinates()
   return lmt_GetNormalizeCoordinates( x, y, xN, yN, widthN, heightN )
end

local function lmt_NormalizePreferredMousePositionToMap( )
   local left, top = ZO_WorldMapContainer:GetLeft(), ZO_WorldMapContainer:GetTop()
   local width, height = ZO_WorldMapContainer:GetDimensions()
   return lmt_GetNormalizeMouse( left, top, width, height )
end

------------------------------------------------------------------------------------------------------
--- Mouse Fix ------ Mouse Fix ------ Mouse Fix ------ Mouse Fix ------ Mouse Fix ------ Mouse Fix ---
------------------------------------------------------------------------------------------------------

CALLBACK_MANAGER:RegisterCallback( "OnWorldMapChanged", function ( ) selectedZone = nil end )

ZO_PreHook( "ProcessMapClick", function ( xN, yN )
   local theme = lmt_GetCurrentTheme()
   if theme then
      local map = theme:GetCurrentMap()
      if map then
         if lmt_IsInGamepadMode() and selectedZone then 
            lmt_NavigateToMap( selectedZone:GetZoneId() )
            return true 
         end
         if not map:UseDefaultZones() then
            return true
         end
      end
   end
end )
  
ZO_PreHook( "ZO_WorldMap_MouseUp", function ( self, mouseButton, upInside )
   local theme = lmt_GetCurrentTheme()
   if theme then
      local map = theme:GetCurrentMap()
      if map then
         local mapId = map:GetMapId()
         if mouseButton == MOUSE_BUTTON_INDEX_RIGHT and upInside then
            local parentMapId = map:GetParentMapId()
            if parentMapId then
               selectedZone = nil
               lmt_NavigateToMap( parentMapId )
               return true
            end
         end
      end
   end
end )

------------------------------------------------------------------------------------------------------------------------------------
--- Controller Fix ------ Controller Fix ------ Controller Fix ------ Controller Fix ------ Controller Fix ------ Controller Fix ---
------------------------------------------------------------------------------------------------------------------------------------

EVENT_MANAGER:RegisterForUpdate( "OnMapUpdate", 0, function ( self )
   if not lmt_IsInGamepadMode() or ZO_WorldMap:IsHidden() then return end   

   local theme = lmt_GetCurrentTheme()
   if not theme then return end

   local map = theme:GetCurrentMap()
   if not map then return end

   if not selectedZone then
      local zones = map:GetAllZones()
      for _, zone in pairs( zones ) do
         
         local zoneHitbox = zone:GetZoneBlob():GetZoneHitbox()

         if zoneHitbox then
            if zoneHitbox:IsPointInside( lmt_GetMouseCoordinates() ) then
               selectedZone = zone
               break
            end
         end
      end
   else
      if not selectedZone:GetZoneBlob():GetZoneHitbox():IsPointInside( lmt_GetMouseCoordinates() ) then
         selectedZone = nil
      end
   end
end )

------------------------------------------------------------------------------------------------------------------------
--- Compile Pois ------ Compile Pois ------ Compile Pois ------ Compile Pois ------ Compile Pois ------ Compile Pois ---
------------------------------------------------------------------------------------------------------------------------

local function CompilePoi( theme, map, poiId, poi )
   local compiled = { }

   compiled.GetPoiId = function ( ) return poiId end

   local poiXN, poiYN = poi.xN, poi.yN
   compiled.GetLocation = function ( ) return poiXN, poiYN end

   local poiEnabled, poiDisabled = poi.enabled, poi.disabled
   compiled.IsEnabled = function ( self ) return poiEnabled or not poiDisabled end

   local poiSoloArena, poiGroupArena = poi.soloArena, poi.groupArena
   compiled.IsSoloArena = function ( ) return poiSoloArena end
   compiled.IsGroupArena = function ( ) return poiGroupArena end

   local poiGuildShrine, poiMajorSettlement = poi.guildShrine, poi.majorSettlement
   compiled.IsGuildShrine = function ( ) return poiGuildShrine end
   compiled.IsMajorSettlement = function ( ) return poiMajorSettlement end

   return compiled
end

-------------------------------------------------------------------------------------------------------------------------------------------------
--- Compile Blob Children ------ Compile Blob Children ------ Compile Blob Children ------ Compile Blob Children ------ Compile Blob Children ---
-------------------------------------------------------------------------------------------------------------------------------------------------

local validFonts = { 
   "Univers57", "Univers67", 
   "FTN47", "FTN57", "FTN87",
   "ProseAntiquePSMT",
   "HandWritten_Bold",
   "TrajanPro-Regular",
}

local validFontSizes = {
   [27] = 26, [29] = 28, [31] = 30, [33] = 32, [35] = 34,
   [37] = 36, [38] = 36, [39] = 40, [41] = 40, [42] = 40,
   [43] = 40, [44] = 40, [45] = 48, [46] = 48, [47] = 48,
   [49] = 48, [50] = 54, [51] = 54, [52] = 54, [53] = 54, 
}

local function lmt_ClampFontSize( fontSize ) return validFontSizes[ fontSize ] or fontSize end

local oldMouseX, oldMouseY
local function CompileZoneHitbox( theme, zone, blob )
   local compiled = blob:GetNamedChild( "ZoneHitbox" )

   for _, point in pairs( zone:GetHitbox() ) do compiled:AddPoint( point.xN, point.yN ) end

   compiled:SetMouseEnabled( true )
   
   compiled.Update = function ( ) 
      --TODO add smth to be updated
   end

   compiled:SetHandler( "OnMouseEnter", function ( )
      if lmt_IsInGamepadMode() then return end
      selectedZone = zone
      ZO_WorldMapMouseoverName:SetText( selectedZone:GetZoneName() )
      if theme:IsMapDescriptionsEnabled() then
         ZO_WorldMapMouseOverDescription:SetText( selectedZone:GetZoneDescription() )
      end
      ZO_WorldMap_MouseEnter()
   end )

   compiled:SetHandler( "OnMouseExit", function ( )
      if lmt_IsInGamepadMode() then return end
      if selectedZone and selectedZone:GetZoneId() == zone:GetZoneId() then
         selectedZone = nil
         ZO_WorldMapMouseoverName:SetText( '' )
         ZO_WorldMapMouseOverDescription:SetText( '' )
      end
      ZO_WorldMap_MouseExit()
   end )

   compiled:SetHandler( "OnMouseDown", function ( _, button, ctrl, alt, shift )
      if lmt_IsInGamepadMode() then return end
      oldMouseX, oldMouseY = nil, nil
      if button == MOUSE_BUTTON_INDEX_LEFT then
         oldMouseX, oldMouseY = lmt_NormalizePreferredMousePositionToMap()
      end
      ZO_WorldMap_MouseDown( button, ctrl, alt, shift )
   end )

   compiled:SetHandler( "OnMouseUp", function ( _, button, upInside )
      if lmt_IsInGamepadMode() then return end
      ZO_WorldMap_MouseUp( nil, button, nil ) -- fixes something idrc
      if upInside and button == MOUSE_BUTTON_INDEX_LEFT then
         if oldMouseX and oldMouseY then
            local mouseX, mouseY = lmt_NormalizePreferredMousePositionToMap()
            if mouseX == oldMouseX and mouseY == oldMouseY then
               oldMouseX, oldMouseY = nil, nil
               if selectedZone and selectedZone:GetZoneId() == zone:GetZoneId() then
                  lmt_NavigateToMap( selectedZone:GetZoneId() )
                  return
               end
            end
         end
      end
      ZO_WorldMap_MouseUp( nil, button, upInside )
   end )

   return compiled
end

local function CompileZoneLabel( theme, zone, blob )
   local compiled = blob:GetNamedChild("ZoneLabel")

   compiled:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

   compiled.Update = function( self )
      self:SetText( zone:GetZoneName() )
      self:SetFont( zone:GetFontInfo() )
      self:SetColor( unpack( zone:GetFontColor()) )
      self:SetHidden( not zone:IsEnabled() or not zone:IsZoneNamesEnabled() )
      self:SetTransformRotationZ( zone:GetZoneLabelRotation() )
   end
   return compiled
end

local function CompileStoryLabel( theme, zone, blob, zoneLabel )
   local compiled = blob:GetNamedChild( "StoryLabel" )

   compiled:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
   compiled:SetAnchor( TOP, zoneLabel, BOTTOM, 0, -3 )

   local factionStory = zone:GetFactionAndStoryIndex()
   compiled.Update = function ( self )
      if factionStory then 
         self:SetText( zone:GetFactionAndStoryIndex() ) 
         self:SetFont( zone:GetFontInfo() )
         self:SetColor( unpack( zone:GetFontColor() ) )
         self:SetHidden( not zone:IsEnabled() or not zone:IsZoneNamesEnabled() or not zone:IsStoryIndexesEnabled() )
      end
   end   

   return compiled
end
 
------------------------------------------------------------------------------------------------------------------------
--- Compile Blob ------ Compile Blob ------ Compile Blob ------ Compile Blob ------ Compile Blob ------ Compile Blob ---
------------------------------------------------------------------------------------------------------------------------

local TAMRIEL_VERTICAL_OFFSET = -0.14000000059605 

local BlobManagerClass = ZO_ObjectPool:Subclass()

BlobManagerClass.New = function ( self, parent )
   return ZO_ObjectPool.New( self, function ( blobContainer )
      return ZO_ObjectPool_CreateNamedControl(
         "LibMapThemer_MapBlob", 
         "LibMapThemer_MapBlobTemplate",
         blobContainer, parent)
   end, ZO_ObjectPool_DefaultResetControl )
end

function BlobManagerClass:CreateBlob( theme, map, zone )
   local blobId = (theme:GetName().."-"..map:GetMapId().."-"..zone:GetZoneId())
   local blob = self:AcquireObject(blobId)
   blob.GetBlobId = function ( ) return blobId end
   blob:SetColor( 1, 0, 0, 0, 0 )
   blob:SetTexture( zone:GetTextureFile() )
   return blob
end

local _BM = BlobManagerClass:New( ZO_WorldMapContainer )

local function CompileBlob( theme, map, zone )
   local compiled = _BM:CreateBlob( theme, map, zone )

   compiled.GetBounds = function ( _, ... )
      local xN, yN, widthN, heightN = zone:GetBounds( ... )
      if not widthN or not heightN then
         local widthN, heightN = compiled:GetTextureFileDimensions()
         widthN, heightN = widthN / 4096, heightN / 4096
      end
      return xN, yN, widthN, heightN
   end 

   compiled.GetOffsets = function ( ) return zone:GetOffsets() end 

   compiled.GetOffsetBounds = function ( self, ... )
      local xN, yN, widthN, heightN = self:GetBounds( ... )
      local x, y, width, height = zone:GetOffsets()
      return xN + x, yN + y, widthN + width, heightN + height
   end 

   compiled.GetNormalizedBounds = function ( self, width, height )
      local xN, yN, widthN, heightN = self:GetBounds()
      return  xN * width, yN * height, widthN * width, heightN * height
   end

   compiled.GetUIBounds = function ( self )
      local width, height = ZO_WorldMapContainer:GetDimensions()
      local xN, yN, widthN, heightN = self:GetBounds()
      return xN * width, yN * height, widthN * width, heightN * height
   end

   compiled.GetNormalizedMapInfo = function ( self ) return self:GetOffsetBounds( TAMRIEL_VERTICAL_OFFSET ) end

   local zoneLabel = CompileZoneLabel( theme, zone, compiled )
   compiled.GetZoneLabel = function ( ) return zoneLabel end

   local storyLabel = CompileStoryLabel( theme, zone, compiled, zoneLabel )
   compiled.GetStoryLabel = function ( ) return storyLabel end

   local zoneHitbox = CompileZoneHitbox( theme, zone, compiled )
   compiled.GetZoneHitbox = function ( ) return zoneHitbox end

   compiled.Update = function ( self )
      local xN, yN, widthN, heightN = self:GetUIBounds()
      self:SetSimpleAnchorParent( xN, yN )
      self:SetDimensions( widthN, heightN )
      self:SetHidden( not zone:IsEnabled() )
      --self:SetColor( 1, unpack( { 1, 1, 1, 1 } ) )
      self:SetColor( 1, unpack( zone:GetZoneColor() ) )
      self:GetZoneLabel():Update()
      self:GetStoryLabel():Update()
      self:GetZoneHitbox():Update()
   end

   return compiled
end

--------------------------------------------------------------------------------------------------------------------------------
--- Theme/Map/Zone Functions ------ Theme/Map/Zone Functions ------ Theme/Map/Zone Functions ------ Theme/Map/Zone Functions ---
--------------------------------------------------------------------------------------------------------------------------------

local function CompileFunctions( theme, tbl , fns ) 
   for fnName, fn in pairs( fns ) do
      if type( fn ) == 'function' then
         tbl[ fnName ] = function( _, ... ) return fn( theme, ... ) end
      end
   end
end

------------------------------------------------------------------------------------------------------------------------
--- Compile Zone ------ Compile Zone ------ Compile Zone ------ Compile Zone ------ Compile Zone ------ Compile Zone ---
------------------------------------------------------------------------------------------------------------------------

local function CompileZone( theme, map, zoneId, zone ) 
   local compiled = { }
   --local enableRenames = zone.enableRenames
   --compiled.IsRenamesEnabled = function ( ) return enableRenames or ( not zone.disableRenames and map:IsRenamesEnabled() ) end

   --local enableMapDescriptions = zone.enableMapDescriptions
   --compiled.IsMapDescriptionsEnabled = function ( ) return enableMapDescriptions or ( not zone.disableMapDescriptions and map:IsMapDescriptionsEnabled() ) end

   local enableZoneNames = zone.enableZoneNames
   compiled.IsZoneNamesEnabled = function ( ) return enableZoneNames or ( not zone.disableZoneNames and map:IsZoneNamesEnabled() ) end

   local enableStoryIndexes = zone.enableStoryIndexes
   compiled.IsStoryIndexesEnabled = function ( ) return enableStoryIndexes or ( not zone.disableStoryIndexes and map:IsStoryIndexesEnabled() ) end
   
   compiled.GetZoneDescription = function ( ) return theme:GetMapDescription( zone.name ) or theme:GetMapDescription( GetMapNameById( zoneId ) ) end

   local zoneFontName = zone.fontName
   compiled.GetFontName = function ( ) return zoneFontName or map:GetFontName( ) end

   local zoneFontSize = lmt_ClampFontSize( zone.fontSize )
   compiled.GetFontSize = function ( ) return zoneFontSize or map:GetFontSize() end

   local zoneFontColor = zone.fontColor
   compiled.GetFontColor = function ( ) return zoneFontColor or map:GetFontColor() end

   local zoneColor = zone.zoneColor
   compiled.GetZoneColor = function ( ) return zoneColor or map:GetZoneColor() end

   CompileFunctions( theme, compiled, zone )

   compiled.GetTheme = function ( ) return theme end

   compiled.GetMap = function ( ) return map end

   compiled.GetMapId = function ( ) return map:GetMapId() end

   compiled.GetZoneId = function ( ) return zoneId end


   compiled.GetZoneName = function ( )
      local mapName = zone.name or GetMapNameById( zoneId )
      if theme:IsRenamesEnabled() then
         mapName = theme:GetRename( mapName )
      else
         -- Fix map clipping
         if mapName == "High Isle and Amenos" then
            return "High Isle & Amenos"
         elseif mapName == "Galen and Y'ffelon" then
            return "Galen & Y'ffelon"
         end
      end
      return mapName 
   end
   
   compiled.IsEnabled = function ( ) return map:IsEnabled( ) end

   local zoneTextureFile = zone.textureFile 
   compiled.GetTextureFile = function ( ) return zoneTextureFile end

   compiled.GetFontInfo = function ( self )
      return ( "EsoUI/Common/Fonts/"..self:GetFontName().. ".otf |"..self:GetFontSize().."|soft-shadow-thick" ) 
   end

   local zoneFaction, zoneStoryIndex = zone.faction, zone.storyIndex
   compiled.GetFaction = function ( ) return zoneFaction end
   compiled.GetStoryIndex = function ( ) return zoneStoryIndex end
   compiled.GetFactionAndStoryIndex = function ( ) 
      if zoneFaction and zoneStoryIndex then return zoneFaction..'#'..zoneStoryIndex end
   end

   local zoneHitBox = zone.hitbox or { }
   compiled.GetHitbox = function ( ) return zoneHitBox end

   local zoneBounds = zone.bounds or { xN = 0, yN = 0, widthN = 0, heightN = 0, }
   compiled.GetBounds = function ( _, verticalOffset )
      return zoneBounds.xN or 0, ( zoneBounds.yN or 0 ) + ( verticalOffset or 0 ), 
             zoneBounds.widthN or 0, zoneBounds.heightN or 0
   end

   local zoneOffsets = zone.offsets or { xN = 0, yN = 0, widthN = 0, heightN = 0, }
   compiled.GetOffsets = function ( )
      return zoneOffsets.xN or 0, zoneOffsets.yN or 0, 
             zoneOffsets.widthN or 0, zoneOffsets.heightN or 0
   end

   local zoneLabelRotation = zone.zoneLabelRotation or 0
   compiled.GetZoneLabelRotation = function ( ) return zoneLabelRotation end

   local zoneBlob = CompileBlob(theme, map, compiled)
   compiled.GetZoneBlob = function ( ) return zoneBlob end

   compiled.Update = function ( self )
      self:GetZoneBlob():Update()
   end

   return compiled
end

------------------------------------------------------------------------------------------------------------------
--- Compile Map ------ Compile Map ------ Compile Map ------ Compile Map ------ Compile Map ------ Compile Map ---
------------------------------------------------------------------------------------------------------------------

local function CompileMap( theme, mapId, map ) 
   local compiled = { }

   --local enableRenames = map.enableRenames
   --compiled.IsRenamesEnabled = function ( ) return enableRenames or ( not map.disableRenames and theme:IsRenamesEnabled() ) end

   --local enableMapDescriptions = map.enableMapDescriptions
   --compiled.IsMapDescriptionsEnabled = function ( ) return enableMapDescriptions or ( not map.disableMapDescriptions and theme:IsMapDescriptionsEnabled() ) end

   local enableZoneNames = map.enableZoneNames
   compiled.IsZoneNamesEnabled = function ( ) return enableZoneNames or (not map.disableZoneNames and theme:IsZoneNamesEnabled()) end

   local enableStoryIndexes = map.enableStoryIndexes
   compiled.IsStoryIndexesEnabled = function ( ) return enableStoryIndexes or (not map.disableStoryIndexes and theme:IsStoryIndexesEnabled()) end

   local fontName = map.fontName
   compiled.GetFontName = function ( ) return fontName or theme:GetFontName() end

   local fontSize = lmt_ClampFontSize( map.fontSize )
   compiled.GetFontSize = function ( ) return fontSize or theme:GetFontSize() end

   local fontColor = map.fontColor
   compiled.GetFontColor = function ( ) return fontColor or theme:GetFontColor() end

   local mapZoneColor = map.zoneColor
   compiled.GetZoneColor = function ( ) return mapZoneColor or theme:GetZoneColor() end

   local mapCustomMaxZoom = map.customMaxZoom
   compiled.GetCustomMaxZoom = function ( ) return mapCustomMaxZoom end

   CompileFunctions( theme, compiled, map )

   compiled.UseDefaultZones = function ( ) return not map.zones or map.useDefaultZones end 

   compiled.GetFontInfo = function ( self )
      return ( "EsoUI/Common/Fonts/"..self:GetFontName().. ".otf |"..self:GetFontSize().."|soft-shadow-thick" ) 
   end

   compiled.GetTheme = function ( ) return theme end
   
   compiled.GetMapId = function ( ) return mapId end

   local parentMapId = map.parentMapId 
   compiled.GetParentMapId = function ( ) return parentMapId end

   compiled.GetMapName = function ( )  
      local mapName = GetMapNameById( mapId )
      if theme:IsRenamesEnabled() then
         mapName = theme:GetRename( mapName )
      end
      return mapName 
   end

   compiled.GetMapDescription = function ( ) return theme:GetMapDescription( GetMapNameById( mapId ) ) end

   compiled.IsCurrentMapId = function ( ) return mapId == theme:GetCurrentMapId() end

   compiled.IsEnabled = function ( ) return theme:IsEnabled() and compiled:IsCurrentMapId() end
   
   compiled.IsMapAurbis = function ( ) return mapId == 439 end

   compiled.IsMapTamriel = function ( ) return mapId == 27 end

   local tilePath = map.tilePath
   local tileOverrides = map.tileOverrides or { }
   compiled.GetTileByIndex = function ( self, index ) 
      if not index then return end
      local tileTexture
      if tilePath then
         tileTexture = tilePath..index..'.dds'
      end
      return tileOverrides[ index ] or tileTexture
   end

   local mapPois = { }
   compiled.GetPoiById = function ( self, poiId ) return mapPois[poiId] end
   for poiId, poi in pairs( map.pois or { } ) do 
      mapPois[ poiId ] = CompilePoi( theme, compiled, poiId, poi )
   end

   local mapZones = { }
   compiled.GetZoneById = function ( self, zoneId ) return mapZones[zoneId] end
   for zoneId, zone in pairs( map.zones or { } ) do 
      local compiledZone = CompileZone( theme, compiled, zoneId, zone )
      mapZones[ zoneId ] = compiledZone
   end
   compiled.GetAllZones = function ( ) return mapZones end

   compiled.Update = function ( self ) 
      for _, zone in pairs( mapZones ) do zone:Update() end 
   end

   return compiled
end

------------------------------------------------------------------------------------------------------------------
--- Theme Utils ------ Theme Utils ------ Theme Utils ------ Theme Utils ------ Theme Utils ------ Theme Utils ---
------------------------------------------------------------------------------------------------------------------

local lmt_originalFunctions = { }

local function lmt_PostHookFunction( functionName )
   if not lmt_originalFunctions[ functionName ] then 

      lmt_originalFunctions[ functionName ] = _G[ functionName ]
      local _GFunction = lmt_originalFunctions[ functionName ]

      _G[ functionName ] = function ( ... )
         local output = { _GFunction( ... ) }
         local theme = lmt_GetCurrentTheme()
         if theme then
            local overrideFn = theme:GetOverrideFn( functionName )
            if overrideFn then
               local newOutput = overrideFn( theme, output, ... )
               if newOutput then return unpack( newOutput ) end
            end
         end
         return unpack( output )
      end

   end
end

local function lmt_GetZosFunction( functionName )
   return lmt_originalFunctions[ functionName ] or _G[ functionName ]
end

local function lmt_HookRegisterCallback( theme, callbackName, callbackFn, ... )
   CALLBACK_MANAGER:RegisterCallback( callbackName, function ( ... )
      if theme:IsEnabled() then
         return callbackFn( theme, ... )
      end
   end, ... )
end

-- TODO implement
local function lmt_HookRegisterForEvent( theme, eventCode, eventFn, ... )
   EVENT_MANAGER:RegisterForEvent( theme:GetName(), eventCode, function ( ... )
      if theme:IsEnabled() then
         return eventFn( theme, ... )
      end
   end, ... )
end

local function lmt_GetCurrentMapId() return GetCurrentMapId() end

local function lmt_IsWaypointPlaced() 
   return LMP:HasMapPing( MAP_PIN_TYPE_PLAYER_WAYPOINT, "waypoint" ) 
end

local function lmt_GetPlayerMapIdFromUnitTag( unitTag )
   local zoneId, _, _, _ = GetUnitRawWorldPosition( unitTag )
   local playerMapId = GetMapIdByZoneId( zoneId )
   return playerMapId
end
 
local function lmt_GetParentMapId( mapId )
   if not mapId then return end
   local parentID = LZ:GetGeographicalParentMapId( mapId )  
   if parentID then
      local theme = lmt_GetCurrentTheme()
      if not theme or parentID == 0 then return mapId end
      local map = theme:GetMapById( mapId )
      if map and map:GetParentMapId() then return mapId end
   end
   return parentID
end

local function lmt_GetGlobalCoordinates( nodeIndex )
   local zoneIndex, poiIndex = GetFastTravelNodePOIIndicies( nodeIndex )
   local parentId = lmt_GetParentMapId( GetMapIdByZoneId( GetZoneId( zoneIndex ) ) )
   local globalXN, globalYN = GetPOIMapInfo( zoneIndex, poiIndex )
   return parentId, globalXN, globalYN
end

local function lmt_GetFixedGlobalCoordinates( mapId, vanillaGlobalXN, vanillaGlobalYN  )
   local measurement = GPS:GetMapMeasurementByMapId( mapId )
   if not measurement or not mapId then return vanillaGlobalXN, vanillaGlobalYN end
   local nOffsetX, nOffsetY, nWidth, nHeight = lmt_GetZosFunction( "GetUniversallyNormalizedMapInfo" )( mapId )
   local vanillaLocalXN = ( vanillaGlobalXN - nOffsetX ) / nWidth
   local vanillaLocalYN = ( vanillaGlobalYN - ( nOffsetY - TAMRIEL_VERTICAL_OFFSET ) ) / nHeight 
   return measurement:ToGlobal( vanillaLocalXN, vanillaLocalYN )
end

------------------------------------------------------------------------------------------------------------------------------
--- Compile Theme ------ Compile Theme ------ Compile Theme ------ Compile Theme ------ Compile Theme ------ Compile Theme ---
------------------------------------------------------------------------------------------------------------------------------

local mapWidth, _ = ZO_WorldMapContainer:GetDimensions()
local enlargeConst = 1.5
local mapDescPaddingAmount = mapWidth * 0.11

local function CompileTheme( theme )
   if not theme or not theme.name or not theme.version then return { } end
   local compiled = { }
   
   local themeName = theme.name
   local themeVersion = theme.version
   local themeOptions = ZO_SavedVars:NewAccountWide( addonName.."Vars", themeVersion, themeName, theme.options ) 
   
   local enableRenames = theme.enableRenames
   compiled.IsRenamesEnabled = function ( self ) return enableRenames end

   local enableMapDescriptions = theme.enableMapDescriptions
   compiled.IsMapDescriptionsEnabled = function ( ) return enableMapDescriptions end

   local enableZoneNames = theme.enableZoneNames
   compiled.IsZoneNamesEnabled = function ( ) return enableZoneNames end

   local enableStoryIndexes = theme.enableStoryIndexes
   compiled.IsStoryIndexesEnabled = function ( ) return enableStoryIndexes end

   local themeFontName = "Univers67"
   compiled.GetFontName = function ( ) return themeFontName end

   local themeFontSize = 18
   compiled.GetFontSize = function ( ) return themeFontSize end

   local themeFontColor = { 1, 1, 1, 1 }
   compiled.GetFontColor = function ( ) return themeFontColor end

   compiled.GetValidFonts = function ( ) return validFonts end

   local themeZoneColor = { 0, 0, 0, 0 }
   compiled.GetZoneColor = function ( ) return themeZoneColor end

   --- Above this is anything that can be overridden, below is unchangable ---
   CompileFunctions( compiled, compiled, theme )

   compiled.GetFontInfo = function ( self )
      return ( "EsoUI/Common/Fonts/"..self:GetFontName().. ".otf |"..self:GetFontSize().."|soft-shadow-thick" ) 
   end

   compiled.GetName = function ( ) return themeName end

   compiled.GetVersion = function ( ) return themeVersion end

   compiled.GetOptions = function ( ) return themeOptions end

   compiled.GetCurrentOptions = function ( ) return addon:GetCurrentThemeOptions( ) end

   compiled.Print = function( self, ... ) chat:Print( ... ) end
   
   compiled.GetSelectedZone = function ( ) return selectedZone end

   compiled.GetCurrentMapId = function ( ) return lmt_GetCurrentMapId() end

   compiled.IsWaypointPlaced = function ( ) return lmt_IsWaypointPlaced() end

   compiled.ClampFontSize = function ( self, ... ) return lmt_ClampFontSize( ... ) end

   compiled.GetZosFunction = function ( self, ... ) return lmt_GetZosFunction( ... ) end
   
   compiled.GetGlobalCoordinates = function ( self, ... ) return lmt_GetGlobalCoordinates( ... ) end

   compiled.GetPlayerMapIdFromUnitTag = function ( self, ... ) return lmt_GetPlayerMapIdFromUnitTag( ... ) end

   compiled.GetFixedGlobalCoordinates = function ( self, ... ) return lmt_GetFixedGlobalCoordinates( ... ) end

   local themeDisplayName = theme.displayName
   compiled.GetDisplayName = function ( ) return themeDisplayName or themeName end

   local themeAuthor = theme.author
   compiled.GetAuthor = function ( ) return themeAuthor end

   local themePrefix = theme.prefix
   compiled.GetPrefix = function ( ) return themePrefix end

   local themeRenames = theme.renames or { }
   compiled.GetRename = function ( self, name ) 
      return themeRenames[ name ] or name
   end

   local themeMapDescriptions = theme.mapDescriptions or { }
   compiled.GetMapDescription = function ( self, name ) 
      return themeMapDescriptions[ name ] or nil
   end

   compiled.IsEnabled = function ( ) return lmt_GetOptions()._lmt_current_theme_ == themeName end

   compiled.Enable = function ( self ) 
      local oldTheme = lmt_GetCurrentTheme()
      if oldTheme then oldTheme:Disable() end
      lmt_SetCurrentTheme( themeName )
      self:Reset()
   end
 
   compiled.EnableIfAvailable = function ( self )
      if lmt_GetOptions()._lmt_current_theme_ == '' then
         self:Enable()
      end
   end 

   compiled.Disable = function ( self ) 
      if self:IsEnabled() then
         lmt_SetCurrentTheme( '' )
         self:Reset()
      end
   end

   local themeMaps = { }
   compiled.GetMapById = function ( self, mapId ) return themeMaps[ mapId ] end
   
   compiled.GetAllMaps = function ( ) return themeMaps end

   compiled.GetCurrentMap = function ( ) return themeMaps[ GetCurrentMapId() ] end 

   for mapId, map in pairs ( theme.maps or { } ) do themeMaps[ mapId ] = CompileMap( compiled, mapId, map ) end

   compiled.GetZoneFromMapById = function ( self, mapId, zoneId ) 
      local map = self:GetMapById( mapId )
      if map then
         local zone = map:GetZoneById( zoneId )
         return zone
      end
   end

   compiled.GetTotalMaps = function ( ) return #themeMaps end

   compiled.Update = function ( ) for _, map in pairs ( themeMaps ) do map:Update() end end

   compiled.Reset = function ( self )
      --ZO_WorldMapMouseOverDescription:SetHidden( true )
      --ZO_WorldMapMouseOverDescription:SetFont( "ZoFontGameLargeBold" )
      --ZO_WorldMapMouseOverDescription:SetWrapMode( TEXT_WRAP_MODE_ELLIPSIS )
      --ZO_WorldMapMouseOverDescription:ClearAnchors()
      --ZO_WorldMapMouseOverDescription:SetAnchor( TOPLEFT, ZO_WorldMapMouseoverName, BOTTOMLEFT, mapDescPaddingAmount, 2 )
      --ZO_WorldMapMouseOverDescription:SetAnchor( TOPRIGHT, ZO_WorldMapMouseoverName, BOTTOMRIGHT, -( mapDescPaddingAmount ), 4 )

      self:Update()

      GPS:ClearMapMeasurements() 
      GPS:CalculateMapMeasurement()
      
      -- DONT ENABLE crashes
      --self:FireCallbacks( "OnWorldMapChanged", nil )
      --self:FireCallbacks( "OnWorldMapShown", nil )
      --CALLBACK_MANAGER:FireCallbacks( "OnWorldMapShown", nil )
   end
   
   local fnOverrides = theme.overrides or { }
   for functionName, _ in pairs( fnOverrides ) do lmt_PostHookFunction( functionName ) end
   compiled.GetOverrideFn = function ( self, functionName ) return fnOverrides[ functionName ] end


   local fnCallbacks = theme.callbacks or { }
   for callbackName, callback in pairs( fnCallbacks ) do lmt_HookRegisterCallback( compiled, callbackName, callback ) end

   compiled.RegisterCallback = function ( self, eventCode, fn, ... ) lmt_HookRegisterCallback( self, eventCode, fn, ... ) end

   compiled.UnregisterCallback = function ( self, eventCode, ... ) CALLBACK_MANAGER:UnregisterCallback( self:GetName(), eventCode, ... ) end

   compiled.FireCallbacks = function ( self, callbackName, ...) CALLBACK_MANAGER:FireCallbacks( callbackName, ...) end

   local slashCommand = theme.slashCommand
   compiled.GetSlashCommand = function ( self ) return slashCommand end

   local website = theme.website
   compiled.GetWebsiteLink = function ( self ) return website end

   local feedback = theme.feedback
   compiled.GetFeedbackLink = function ( self ) return feedback end

   local dontation = theme.dontation
   compiled.GetDontationLink = function ( self ) return dontation end

   compiled.GetLAMPanelData = function ( self )
      local panelName = self:GetName().."_Settings"
      return panelName, {
         type = "panel",
         name = self:GetName(),
         displayName = self:GetDisplayName(),
         author = self:GetAuthor(),
         slashCommand = self:GetSlashCommand(),
         website = self:GetWebsiteLink(),
         feedback = self:GetFeedbackLink(),
         dontation = self:GetDontationLink(),
         registerForRefresh = true,
         registerForDefaults = true,
      }
   end

   return compiled
end

------------------------------------------------------------------------------------------------------------------------------
--- Compile Packs ------ Compile Packs ------ Compile Packs ------ Compile Packs ------ Compile Packs ------ Compile Packs ---
------------------------------------------------------------------------------------------------------------------------------
local forceReplaceList = {
   -- these are not merges but complete replacements, these can be seen as complete data structures
   -- removing these may/will result in a crash or breakage
   ["dependencies"] = true, ["patches"] = true, -- dont want accidental recurrsive loops/duplicates in the merge
   ["bounds"] = true, ["offsets"] = true,       -- dont want to merge bound info, can result in invalid bounds
   ["hitbox"] = true,                           -- hitboxes are a list of values that shouldn't be altered
                                                -- as they are order dependent
}

local function FullCopy( table, seen )
   seen = seen or { }
   if not table then return nil end
   if seen[ table ] then return seen[ table ] end
   local tableCopy
   if type( table ) == 'table' then
      tableCopy = { }
      seen[ table ] = tableCopy
      for key, value in next, table, nil do
         tableCopy[ FullCopy( key, seen ) ] = FullCopy( value, seen )
      end
      setmetatable( tableCopy, FullCopy( getmetatable( table ), seen ) )
   else tableCopy = table end
   return tableCopy 
end

local function Merge( original, merge )
   if type( original ) == 'table' and type( merge ) == 'table' then
      for key, value in pairs( merge ) do             
         if type( value ) == 'table' and type( original[ key ] or false ) == 'table' and not forceReplaceList[ key ] then 
            Merge( original[ key ], value ) 
         else
            -- we specifically dont want to mess with dependencies and patches
            if key ~= "dependencies" and key ~= "patches" then
               original[ key ] = value
            else 
               original[ key ] = { }
            end
         end
      end
   end
   return original
end

local function CopyAndMerge( original, merge )
   return Merge( original, FullCopy(merge) )
end

local function MergeThemes( themes )
   local merged = { }
   if type( themes ) == 'table' then 
      for _, theme in pairs( themes ) do
         if type( theme ) == 'table' then
            local dependencies = { }
            if type( theme.dependencies ) == 'table' then
               dependencies = MergeThemes( theme.dependencies ) or { }
            end
   
            local patches = { }
            if type( theme.patches ) == 'table' then
               patches = MergeThemes( theme.patches ) or { }
            end
   
            merged = Merge( merged, dependencies )
            merged = CopyAndMerge( merged, theme )
            merged = Merge( merged, patches )
         end
      end
   end
   return merged
end

------------------------------------------------------------------------------------------------------------------------
--- Create Theme ------ Create Theme ------ Create Theme ------ Create Theme ------ Create Theme ------ Create Theme ---
------------------------------------------------------------------------------------------------------------------------

function addon:CreateTheme( theme )
   -- return a saved theme instead of a new one
   local existingTheme = lmt_allThemes[ theme.name ]
   if existingTheme then return existingTheme end

   local themepack = MergeThemes( { theme } )
   local compiledTheme = CompileTheme( themepack )
   if compiledTheme and compiledTheme:GetName() then 
      lmt_allThemes[ compiledTheme:GetName() ] = compiledTheme
   end
   return compiledTheme
end

------------------------------------------------------------------------------------------------------------
--- Addon Info ------ Addon Info ------ Addon Info ------ Addon Info ------ Addon Info ------ Addon Info ---
------------------------------------------------------------------------------------------------------------

local title, author, description

local function LoadInfo()
   local numAddons = GetAddOnManager():GetNumAddOns()
   for i = 1, numAddons do 
      local n, t, a, d = GetAddOnManager():GetAddOnInfo(i)
      if n == addonName then
         title, author, description = t, a, d
         break 
      end
   end
end LoadInfo()

function addon:GetName() return addonName end

function addon:GetVersion() return version end

function addon:GetVersionName() return versionName end

function addon:GetTitle() return title end

function addon:GetAuthor() return author end

function addon:GetDescription() return description end

function addon:GetCurrentTheme() return lmt_GetCurrentTheme() end

function addon:GetCurrentThemeName( ) return lmt_GetCurrentThemeName( ) end

function addon:GetCurrentMap() return lmt_GetCurrentTheme():GetCurrentMap() end

function addon:GetMapById( mapId ) return lmt_GetCurrentTheme():GetMapById( mapId ) end

function addon:GetNormalizeMouse( x, y, w, h ) return lmt_GetNormalizeMouse( x, y, w, h ) end

function addon:Print( output ) return chat:Print( output ) end

function addon:GetCurrentThemeOptions( ) 
   local currentTheme = lmt_GetCurrentTheme( )
   if currentTheme then
      return currentTheme:GetOptions( )
   end
end

-------------------------------------------------------------------------------------------------------------------
--- Debug Functions ------ Debug Functions ------ Debug Functions ------ Debug Functions ------ Debug Functions ---
-------------------------------------------------------------------------------------------------------------------

local function PrintFunctions(table)
   if type( table ) == 'table' then 
      local entryText = '[Function List]\n'
      for entry, value in pairs(table) do
         if type( value ) == 'function' then
            entryText = entryText.."   "..entry.."()\n"
         end
      end
      chat:Print( entryText )
   end 
end


 
------------------------------------------------------------------------------------------------------------------------------------
--- Slash Commands ------ Slash Commands ------ Slash Commands ------ Slash Commands ------ Slash Commands ------ Slash Commands ---
------------------------------------------------------------------------------------------------------------------------------------


SLASH_COMMANDS[ "/get_current_mapid" ] = function ( ) chat:Print( "Current MapId: "..GetCurrentMapId( ) ) end

SLASH_COMMANDS[ "/get_current_map_name" ] = function ( ) chat:Print( GetMapNameById( GetCurrentMapId() ) ) end


SLASH_COMMANDS[ "/print_theme_functions" ] = function ( )
   local theme = lmt_GetCurrentTheme()
   if theme then PrintFunctions( theme ) end
end

SLASH_COMMANDS[ "/print_map_functions" ] = function ( )
   local theme = lmt_GetCurrentTheme()
   if not theme then return end
   local map = theme:GetCurrentMap() or theme:GetMapById( 27 )
   PrintFunctions( map )
end 

SLASH_COMMANDS[ "/lmt_current_theme" ] = function ( )
   chat:Print( lmt_GetCurrentThemeName( ) )
end 
