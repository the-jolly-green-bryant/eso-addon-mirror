if PZ == nil then PZ = {} end
local PetZone = PZ

--Return the zonedata
function PetZone.GetZoneData(zone, subzone)
    local zoneData = PetZone.ZoneData
    local zoneGiven     = zone ~= nil and type(zone) == "string" and zone ~= ""
    local subZoneGiven  = subzone ~= nil and subzone ~= "" and subzone ~= "zoneId" and subzone ~= PZ_NONE_ENTRIES and subzone ~= PZ_ALL_ENTRIES
    local subZoneNotOrALLGiven = subzone == nil or (subzone ~= nil and subzone == PZ_ALL_ENTRIES)
--d("[PetZone.GetZoneData] zone: " .. tostring(zone) .. ", subZone: " ..tostring(subzone))
    if zoneGiven and subZoneGiven then
        if zoneData[zone] and zoneData[zone][subzone] then
            return zoneData[zone][subzone]
        end
    elseif zoneGiven and (subZoneGiven or subZoneNotOrALLGiven) then
        if zoneData[zone] then
            return zoneData[zone]
        end
    end
    local settings = PetZone.settingsVars.settings
        local zoneIndex = GetCurrentMapZoneIndex()
        local zoneId, parentZoneId
        if zoneIndex ~= nil then
            zoneId = GetZoneId(zoneIndex)
            if zoneId ~= nil then parentZoneId = GetParentZoneId(zoneId) end
        end
    --Return nil if nothing relevant was found
    return nil
end

--Map the zone and subzone to a "better explanatory name" as zone "Darkbrotherhood" e.g. should be "Goldcoast"
function PetZone.MapZoneAndSubZoneNames(zone, subzone)
    --Zone or subzone are given?
    if zone == nil or zone == "" then return zone, subzone end
    local zones = PetZone.ZoneData
    if zones == nil then return zone, subzone end
    local subZones = zones[zone]
    if subZones == nil then return zone, subzone end
    local mappedSubZoneName = ""
    if subzone ~= nil then
        local mappedSubZoneNameTmp = subZones[subzone] or ""
        --The subzone value is a true/false-> No mapping name is given
        if type(mappedSubZoneNameTmp) == "boolean" then
            --Reset the mapped subzone name to empty string so the subzone name will be used
            mappedSubZoneName = ""
            --The subzone value is a String-> A mapping name is given
        elseif type(mappedSubZoneNameTmp) == "string" and mappedSubZoneNameTmp ~= "" then
            --Use mapping name
            mappedSubZoneName = mappedSubZoneNameTmp
        end
    end
    local mappedZoneName = subZones[PZ_ZONE_MAPPING_STRING] or ""
    if mappedZoneName == "" then mappedZoneName = zone end
    if mappedSubZoneName == "" then mappedSubZoneName = subzone end
    --Check if a mapped zonename exists
    return mappedZoneName, mappedSubZoneName
end

--Get the zone and subZone string from libMapPins
function PetZone.CullZoneAndSubzoneNames()
    --Single function code taken from library libMapPins, original authors: Garkin, Ayantir, Fyrakin, Sensi
    --> All credits go to them!
    -- Returns zone and subzone derived from map texture. Format: zone, subZone
--	local zone, subzone =  select(3,(GetMapTileTexture()):lower():find("maps/([%w%-]+)/([%w%-]+_[%w%-]+)"))
	local zone, subzone = select(3,(GetMapTileTexture()):lower():find("maps/([%w%-]+)/(.+)_[^_]+$"))
    		-- same as above, but in Regex for Notepad++:  (^\w+\/[\w\-?]+)_\w+$
			-- Art\/maps\/(\w+)\/(.+)_\w+\.dds$
	return zone, subzone
end

function PetZone.GetZoneAndSubzone()
	local zone, subzone = PetZone.CullZoneAndSubzoneNames()
	for zoneName, subNames in pairs(PetZone.IdByName) do
		if PZ.tableContains(subNames, subzone, true) then
			zone = zoneName
			--d("Better zone! " ..tostring(zone))
			break
		end
	end
	return zone, subzone
end