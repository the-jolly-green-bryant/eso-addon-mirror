PinAutoResizer = {}
PinAutoResizer.name = "PinAutoResizer"

function PinAutoResizer.mainMap() -- update main map
    
    local mapType = GetMapType()
	local mapID = GetCurrentMapId()
    local mapZoneId = GetZoneId(GetCurrentMapZoneIndex())
	
	local gps = LibGPS3
	local scaleX, scaleY = 1,1
	if gps then 
	   local measurement = gps:GetCurrentMapMeasurement()
	   scaleX, scaleY = measurement:GetScale() 
	   if scaleX == nil then scaleX = 1 end
	end

	if mapType == MAPTYPE_COSMIC or mapZoneId == 181 or mapID == 660 then return end -- Disabled for The Aurbis map and any AVA zone except Lambent passage 

	local g_mapPanAndZoom = ZO_WorldMap_GetPanAndZoom()
	
	if not g_mapPanAndZoom:CanMapZoom() then return end
	
	local zoom = g_mapPanAndZoom.currentNormalizedZoom

	
    local pins = ZO_WorldMap_GetPinManager():GetActiveObjects()
	
	
	local minVal1 = 0 -- min zoom main map value 
	local maxVal1 = 1 -- max zoom main map value 
	local minVal2 = 30 -- min pin size we want for main map
	local maxVal2 = 45 -- max pin size we want for main map
	
	if mapType == MAPTYPE_WORLD then minVal2 = 20  -- for the Tamriel map the min pin size is 20
	elseif mapID == 900 then minVal2 = 25 -- for the imperial city sewers the min pin size is 25
	end 
	
	if scaleX ~= 1 then zoom = zoom - scaleX end -- we modify zoom size to make it (slightly) proportional to real map size
	
	
	local newsize = math.floor(((maxVal2 - minVal2 ) * (((zoom+1) - (minVal1+1)) / ((maxVal1+1) - (minVal1+1)))) + minVal2) -- +1 is to avoid 0
     
	--local pinsnumber = 0 
	for pinKey, pin in pairs(pins) do
		if pin ~= ZO_WorldMap_GetPinManager():GetPlayerPin() and pin:GetPinType() ~= MAP_PIN_TYPE_DRAGON_IDLE_HEALTHY and
			pin:GetPinType() ~= MAP_PIN_TYPE_DRAGON_IDLE_WEAK and pin:GetPinType() ~= MAP_PIN_TYPE_ACTIVE_COMPANION and pin.m_textureAnimTimeline == nil then   
		   local control = pin:GetControl()
		   control:SetDimensions(newsize, newsize)
		   --pinsnumber = pinsnumber + 1 
		end		   
	end

	--CHAT_SYSTEM:AddMessage("Main map zoom: "..zoom.." Main map pin size: ".. newsize.." mapID: "..mapID.." map size: "..scaleX.." pins number: "..pinsnumber)
end



function PinAutoResizer.dispatcher() -- chooses which one to update 

    if ZO_WorldMapScroll:IsHidden() then -- minimap mode
	     -- that feature was removed

    elseif WORLD_MAP_MANAGER:IsInMode(MAP_MODE_VOTANS_MINIMAP) then -- MiniMap by Votan (which is not a real minimap)
	     -- We do nothing because Votan's minimap already resizes pins according to zoom
	else -- main map mode 
	     PinAutoResizer.mainMap()
	end
    
end




local function OnAddonLoaded(event, addonName)

	if addonName == PinAutoResizer.name then
       CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", function() PinAutoResizer.dispatcher() end)
	   
	   local mapPanAndZoom = ZO_WorldMap_GetPanAndZoom()
       SecurePostHook(mapPanAndZoom , "SetCurrentNormalizedZoomInternal", function(selfMapPanAndZoom, normalizedZoom) 
	        if WORLD_MAP_MANAGER:IsInMode(MAP_MODE_VOTANS_MINIMAP) then -- MiniMap by Votan (which is not a real minimap)
	             -- We do nothing because Votan's minimap already resizes pins according to zoom
			else -- main map
	            PinAutoResizer.mainMap()
            end				
	   end)
	   
	   
	   	--update when world map is active
		WORLD_MAP_SCENE:RegisterCallback("StateChange",
			function(oldState, newState)
				if newState == SCENE_SHOWING and not WORLD_MAP_MANAGER:IsInMode(MAP_MODE_VOTANS_MINIMAP) then
                   zo_callLater(PinAutoResizer.mainMap,10) --100

				elseif newState == SCENE_HIDING then

				end
			end)
			
		--update when world map is active (gamepad)
		GAMEPAD_WORLD_MAP_SCENE:RegisterCallback("StateChange",
			function(oldState, newState)
				if newState == SCENE_SHOWING and not WORLD_MAP_MANAGER:IsInMode(MAP_MODE_VOTANS_MINIMAP) then
				    zo_callLater(PinAutoResizer.mainMap,10) 

				elseif newState == SCENE_HIDING then

				end
			end)
	   
	   
	   
	   
    end

end


EVENT_MANAGER:RegisterForEvent(PinAutoResizer.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
