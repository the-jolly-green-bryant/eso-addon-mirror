
RTP.CurrentLocation = nil

RTP.InPortal = false
RTP.ChangedZone = false
RTP.LastPosition = nil
RTP.SetChangedZone = false
RTP.Porting = true
RTP.MapPinTypeId = nil

function RTP.InitializeLocations()
    RTP.GenerateCylinders()
    RTP.CreateMapPins()
    RTP.CreateCompassPins()
    RTP.OnZoneChanged()
    
    EVENT_MANAGER:RegisterForEvent(RTP.ADDON_NAME, EVENT_PLAYER_ACTIVATED, RTP.OnZoneChanged)
    EVENT_MANAGER:RegisterForEvent(RTP.ADDON_NAME, EVENT_PLAYER_DEACTIVATED, RTP.OnZoneChanging)
    EVENT_MANAGER:RegisterForEvent(RTP.ADDON_NAME, EVENT_HOUSING_POPULATION_CHANGED, RTP.OnPopulationChanged)
    EVENT_MANAGER:RegisterForUpdate(RTP.CONST.CHECK_PORTALS_ID, 250, RTP.CheckPortals)
end

function RTP.OnPopulationChanged()
    RTP.UpdateLocationUI()
end
function RTP.OnZoneChanging()
    RTP.Porting = true
end

function RTP.OnZoneChanged()
    if RTP.SetChangedZone then
        RTP.ChangedZone = true
    else
        RTP.SetChangedZone = true
    end
    
    RTP.SetCurrentLocation()
    
	for curLoc = 1, #RTP.Portals, 1 do
		for idx, portal in pairs(RTP.Portals[curLoc]) do
			COMPASS_PINS:RefreshPins(RTP.CONST.COMPASS_PIN_TYPE..curLoc.."_"..idx)
		end
	end
    LibMapPins:RefreshPins(RTP.CONST.MAP_PIN_TYPE)
    
    if RTP.CurrentLocation ~= nil and RTP.CurrentLocation.houseId < 500 then
        local town = RTP.Towns[RTP.CurrentLocation.townId]
        
        RTPZoneChangeIndicatorLabel:SetText(string.format(
                "You have entered %s in the town of %s", RTP.CurrentLocation.name, town.name))
        RTPZoneChangeIndicatorPopulationLabel:SetText(string.format(
                "( Current Population %i of %i)", GetCurrentHousePopulation(), GetCurrentHousePopulationCap()))
        RTPZoneChangeIndicator:SetAlpha(1)
        local animation, timeline = CreateSimpleAnimation(ANIMATION_ALPHA, RTPZoneChangeIndicator)
        
        animation:SetAlphaValues(RTPZoneChangeIndicator:GetAlpha(), 0)
        animation:SetDuration(1000)
        timeline:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT)
        zo_callLater(function() timeline:PlayFromStart() end, 8000)
    end
    
    RTP.Porting = false

    if IsPlayerInAvAWorld() or IsActiveWorldBattleground() then
        zo_callLater(function() RTPIndicator:SetHidden(true) end, 500)
    else
        zo_callLater(function() RTPIndicator:SetHidden(false) end, 500)
    end
end

function RTP.CreateCompassPins()
	for curLoc = 1, #RTP.Portals, 1 do
		for idx, portal in pairs(RTP.Portals[curLoc]) do
			COMPASS_PINS:AddCustomPin(RTP.CONST.COMPASS_PIN_TYPE..curLoc.."_"..idx,
				function(pinManager)
					if RTP.CurrentLocation == nil then return end
					if RTP.CurrentLocation.id ~= curLoc then return end
					if RTP.Portals[RTP.CurrentLocation.id] == nil then return end
					if portal.cx == nil then return end

					if portal.nameOverride ~= nil then
						pinManager:CreatePin(RTP.CONST.COMPASS_PIN_TYPE..curLoc.."_"..idx, portal, portal.cx, portal.cy, portal.nameOverride)
					elseif #(portal.destinations) > 0 then
						local name = RTP.Locations[portal.destinations[1]].name
						pinManager:CreatePin(RTP.CONST.COMPASS_PIN_TYPE..curLoc.."_"..idx, portal, portal.cx, portal.cy, name)
					end
				end,
				{ 
					FOV = 3.14,
					maxDistance = 0.11,
					texture = portal.icon, -- "/esoui/art/treeicons/collection_indexicon_housing_down.dds",
					sizeCallback =
					function(pin, angle, normalizedAngle, normalizedDistance)
						local newSize = math.max(48 - 48 * normalizedDistance, 16)
						pin:SetDimensions(newSize, newSize)
					end
				})
		end
	end

return -- TODO
    COMPASS_PINS:AddCustomPin(RTP.CONST.COMPASS_PIN_TYPE,
            function(pinManager)
                if RTP.CurrentLocation == nil then return end
				if RTP.Portals[RTP.CurrentLocation.id] == nil then return end
                
                for _, portal in pairs(RTP.Portals[RTP.CurrentLocation.id]) do
                    if portal.cx == nil then return end
                    
                    if portal.nameOverride ~= nil then
                        pinManager:CreatePin(RTP.CONST.COMPASS_PIN_TYPE, portal, portal.cx, portal.cy, portal.nameOverride)
                    elseif #(portal.destinations) > 0 then
						local name = RTP.Locations[portal.destinations[1]].name
						pinManager:CreatePin(RTP.CONST.COMPASS_PIN_TYPE, portal, portal.cx, portal.cy, name)
                    end
                end
            end,
            { 
                FOV = 3.14,
                maxDistance = 0.11,
                texture = "/esoui/art/treeicons/collection_indexicon_housing_down.dds",
                sizeCallback =
                function(pin, angle, normalizedAngle, normalizedDistance)
                    local newSize = math.max(48 - 48 * normalizedDistance, 16)
                    pin:SetDimensions(newSize, newSize)
                end
            })
end

function RTP.CreateMapPins()
    RTP.MapPinTypeId = LibMapPins:AddPinType(RTP.CONST.MAP_PIN_TYPE, 
            function(pinManager)
                LibMapPins:RemoveCustomPin(RTP.CONST.MAP_PIN_TYPE)
                
                if not LibMapPins:IsEnabled(RTP.CONST.MAP_PIN_TYPE) then return end
                
                if RTP.CurrentLocation == nil or RTP.Portals[RTP.CurrentLocation.id] == nil then
                    return
                end

                for _, portal in pairs(RTP.Portals[RTP.CurrentLocation.id]) do
                    if portal.cx == nil then return end
                    if RTP.HouseMaps[RTP.CurrentLocation.houseId] == nil then return end
                    if RTP.CurrentLocation.owner ~= GetCurrentHouseOwner() then return end
                    
                    local _, subzone = LibMapPins:GetZoneAndSubzone();
                    if RTP.HouseMaps[RTP.CurrentLocation.houseId].map ~= subzone then return end

                    local destinations = portal.destinations
					if #(destinations) > 0 or portal.nameOverride ~= nil then
						LibMapPins:CreatePin(RTP.CONST.MAP_PIN_TYPE, {portal = portal, destinations = destinations}, portal.cx, portal.cy)
					end
                end
            end, 
            nil,
            {
                level = 50,
                texture = function(pin)
					-- d(pin.m_PinTag.portal.icon)
					return pin.m_PinTag.portal.icon
				end,
                size = 30,
            },
            {
                creator = function(pin)
                    local _, pinTag = pin:GetPinTypeAndTag()
                    if pinTag.destinations == nil then return end
                    
                    if RTP.CurrentLocation.houseId >= 500 then
                        local destination = RTP.Locations[pinTag.destinations[1]]
                        local town = RTP.Towns[destination.townId]
                        
                        InformationTooltip:AddLine(town.name)
                        InformationTooltip:AddLine("("..destination.name..")")
                    else
                        if pinTag.portal.nameOverride ~= nil then
                            InformationTooltip:AddLine("|c00ffff"..pinTag.portal.nameOverride)
                        end
                        
                        for _,destinationId in pairs(pinTag.destinations) do
                            local destination = RTP.Locations[destinationId]
                            if destination.desc ~= nil then
                                InformationTooltip:AddLine(destination.name.." - "..destination.desc)
                            else
                                InformationTooltip:AddLine(destination.name)
                            end
                        end
                    end
                end,
                tooltip = ZO_MAP_TOOLTIP_MODE.INFORMATION,
            }
    )
    
    LibMapPins:SetClickHandlers(RTP.MapPinTypeId, {
        {
            callback    = function(pin) 
                local _,tag = pin:GetPinTypeAndTag()

                if GetTableLength(tag.destinations) == 1 then
                    RTP.UI.JumpToPortalLocationById(tag.destinations[1])
                else
                    RTP.UI.ShowSelectLocationDialog(tag.portal)
                end
            end,
        },
    })
    
    LibMapPins:AddPinFilter(RTP.MapPinTypeId, "Role-Play Town Portals", nil, nil, nil, nil)
end

function RTP.CheckPortals()
    if RTP.Porting then
        return
    end
    
    if RTP.CurrentLocation == nil then
        RTP.InPortal = false
        return
    end
    
    local locationId = RTP.CurrentLocation.id

    if RTP.Portals[locationId] == nil then
        RTP.InPortal = false
        return
    end

    local _, x, y, z = GetUnitRawWorldPosition("player")
    local position = {x = x, y = y, z = z}

    if RTP.UTIL.PositionsEqual(position, RTP.LastPosition) then
        return
    end

    RTP.LastPosition = position

    for key, value in pairs(RTP.Portals[locationId]) do
		
		if RTP.UTIL.PointWithinCylinder(position, value.cylinder) then
            if not RTP.InPortal then
                RTP.InPortal = true

                if RTP.ChangedZone then
                    RTP.ChangedZone = false
                else
                    if GetTableLength(value.destinations) == 1 and value.nameOverride == nil then
                        RTP.UI.ShowTravelConfirmation(value)
                    elseif GetTableLength(value.destinations) > 1 or value.nameOverride ~= nil then
                        RTP.UI.ShowSelectLocationDialog(value)
                    end
                end
            end
            
            return
        end
    end

    if RTP.InPortal then
        RTP.InPortal = false

        return
    end
    
    RTP.ChangedZone = false
end

function RTP.GenerateCylinders()
    for listKey, listValue in pairs(RTP.Portals) do
        if listValue ~= nil then
            for key, value in pairs(listValue) do
                local radius = 220
                local height = 120
                
                if value.radius ~= nil then
                    radius = value.radius
                end

                if value.height ~= nil then
                    height = value.height
                end
                value.cylinder = RTP.UTIL.GenerateCylinder({x = value.x, y = value.y, z = value.z}, radius, height)
            end
        end
    end
end

function RTP.SetCurrentLocation()
    local houseId = GetCurrentZoneHouseId()

    if houseId == 0 then
        local _, map = LibMapPins:GetZoneAndSubzone()

        for key, value in  pairs(RTP.HouseMaps) do
            if(value.id >= 500 and value.map == map) then
                houseId = value.id
            end
        end
    end
    
    if houseId ~= 0 then
        local owner = GetCurrentHouseOwner()
        
        if RTP.CurrentLocation ~= nil and RTP.CurrentLocation.houseId == houseId and RTP.CurrentLocation.owner == owner then
            return
        end
        
        for key, value in pairs(RTP.Locations) do
            if value.houseId == houseId and value.owner == owner then
                RTP.CurrentLocation = value
                RTP.UpdateLocationUI()
                return
            end
        end
    end
    
    RTP.CurrentLocation = nil
    RTP.UpdateLocationUI()
end

function RTP.UpdateLocationUI()
    local population = GetCurrentHousePopulation()
    local populationCap = GetCurrentHousePopulationCap()
    
    -- Clear out tooltip and indicator labels
    RTPIndicatorTownLabel:SetText("")
    RTPIndicatorLocationLabel:SetText("")
    RTPIndicatorPopulationLabel:SetText("")
    RTP.UI.IndicatorTooltip = "Role-Play Town Portals"
    
    -- Populate appropriate labels
    if RTP.CurrentLocation == nil or RTP.CurrentLocation.houseId >= 500 then
        if RTP.SavedVars.IndicatorMinimized then
            RTP.UI.IndicatorTooltip = "Role-Play Town Portals |cffffff\nLocation: |cFF9400Not in a Town"
        else
            RTPIndicatorTownLabel:SetText("|cFF9400Not in a Town")
        end
    else
        local town = RTP.Towns[RTP.CurrentLocation.townId]

        if RTP.SavedVars.IndicatorMinimized then
            RTP.UI.IndicatorTooltip = "Role-Play Town Portals |cffffff\nLocation: |c00ffff"
                    ..RTP.BuildLocationName(RTP.CurrentLocation).." in "..town.name.."|cffffff"
                    .."\nPopulation: |c00ffff"..population.." of "..populationCap
        else
            RTPIndicatorTownLabel:SetText(town.name)
            RTPIndicatorLocationLabel:SetText("-"..RTP.BuildLocationName(RTP.CurrentLocation))
            RTPIndicatorPopulationLabel:SetText(population.."/"..populationCap)
        end
    end
end

function RTP.BuildLocationName(location, portal)
    local name = location.name

    if portal ~= nil then
        if portal.nameOverride ~= nil then
            name = portal.nameOverride
        end
    end
    
    if location.desc ~= nil then
        name = name.." "..location.desc
    end
    
    return name
end 