local LMP = LibStub:GetLibrary("LibMapPins-1.0")
local ChestMaster9000 = ZO_Object:Subclass()

ChestMaster9000.updateInProgress = false

local Addon =
{
    Name = "ChestMaster9000",
    NameSpaced = "Chest Master 9000",
    Author = "CrazyDutchGuy",
}

Addon.Defaults =
{
	pinFilter = true,
	data = {},
}

local color = 
{
	[1] = ZO_ColorDef:New(0.8,0.5,0.2,0.8),
	[2] = ZO_ColorDef:New(0.7,0.7,0.7,0.8),
	[3] = ZO_ColorDef:New(1.0,0.8,0.0,0.8),
}

local pinLayout = 
{ 
	level = 40,		
	texture = "/esoui/art/icons/mapkey/mapkey_bank.dds",
	color = color[1],
	size = 16,	
}

local compassPinLayout = 
{
	maxDistance = 0.05,
	texture = "/esoui/art/icons/mapkey/mapkey_bank.dds",
}

local function mergeLocations()
	local mergeRange = 0.0100

	local newTable = {}

	for zone,zoneData in pairs(ChestMaster9000.SV["data"]) do
		newTable[zone] = {}

		for idx, loc in ipairs(zoneData) do
			local dupe = false

			for idx2, loc2 in ipairs(newTable[zone]) do
				if math.abs(loc[1]-loc2[1]) < mergeRange and math.abs(loc[2]-loc2[2]) < mergeRange then
					dupe = true
					loc2[1] = (loc[1] + loc2[1]) / 2
					loc2[2] = (loc[2] + loc2[2]) / 2
					newTable[zone][idx2] = loc2
					break;
				end
			end
			
			if not dupe then table.insert(newTable[zone],loc) end
 
		end
			
	end

	ChestMaster9000.SV["data"] = newTable
end


local function knownChestLocation(mapTexture,x,y)
	if not ChestMaster9000.SV["data"][mapTexture] then return false end

	local range = 0.0100
	for i,v in pairs(ChestMaster9000.SV["data"][mapTexture]) do
		if math.abs(v[1] - x) < range and math.abs(v[2] - y) < range then				
			v[1] = x
			v[2] = y
			v[3] = GetLockQuality()
			ChestMaster9000.SV["data"][mapTexture][i] = v
			return true
		end
	end
	return false
end

local function importHarvestMap()
	if Harvest_SavedVars then
		d("Starting import from Harvest Map")
		local data = Harvest_SavedVars["Default"][GetDisplayName()]["$AccountWide"]["nodes"]["data"]

		for zone,zonedata in pairs(data) do
			local longZoneName = "Art/maps/"..zone.."_0.dds"
			if not ChestMaster9000.SV["data"][longZoneName] then ChestMaster9000.SV["data"][longZoneName] = {} end
			
			if zonedata[6] then
				local updated = 0
				local added = 0
				for _,item in ipairs(zonedata[6]) do
					local v = type(item) == "string" and Harvest.Deserialize(item) or item
					if not knownChestLocation(longZoneName, v[1], v[2]) then
						table.insert(ChestMaster9000.SV["data"][longZoneName], {v[1],v[2]})
						added = added + 1
					else
						updated = updated + 1
					end
				end
				d("Found ".. #zonedata[6] .. " in zone " .. zone .. " new " .. added .. " upd " .. updated )
			end
		end
	else
		d("can't find HarvestMap Saved Vars") 
	end
end

local function processLockPick(...)
	SetMapToPlayerLocation()
	local x,y, _ = GetMapPlayerPosition("player")	
	x = tonumber(string.format("%.4f", x))
	y = tonumber(string.format("%.4f", y))
	local mapTexture = GetMapTileTexture()

	if not ChestMaster9000.SV["data"][mapTexture] then ChestMaster9000.SV["data"][mapTexture] = {} end

	if not knownChestLocation(mapTexture,x,y) then
		table.insert(ChestMaster9000.SV["data"][mapTexture], {x,y,GetLockQuality()})
	end

end

local function compassPinCallback(pinManager)
	local chestData = ChestMaster9000.SV["data"][GetMapTileTexture()]
	
	if not chestData then return end

	for _,chest in ipairs(chestData) do
            pinManager:CreatePin( Addon.Name.."CompassPin", chest, chest[1], chest[2])
	end
end

local function pinCallback(pinManager)
	local chestData = ChestMaster9000.SV["data"][GetMapTileTexture()]
	
	if not chestData then return end

	if ChestMaster9000.updateInProgress then return end

	ChestMaster9000.updateInProgres = true

	for _,chest in ipairs(chestData) do
		if chest[3] then
			pinLayout.tint = color[chest[3]]	
		else
			pinLayout.tint = color[1]
		end
                LMP:CreatePin( Addon.Name.."MapPin", chest, chest[1], chest[2],nil)
	end
	
	ChestMaster9000.updateInProgres = false
end

local function processSlashCommands(option)	
	local options = {}
	local searchResult = { string.match(option,"^(%S*)%s*(.-)$") }
	for i,v in pairs(searchResult) do
        	if (v ~= nil and v ~= "") then
			options[i] = string.lower(v)
        	end
	end
    	
	if options[1] == "consolidate" then
		mergeLocations()	
    		return
	elseif options[1] == "importharvestmap" then
		importHarvestMap()
		return
	end

end

function ChestMaster9000:EVENT_ADD_ON_LOADED(eventCode, addOnName, ...)
	if addOnName == Addon.Name then
		ChestMaster9000.SV = ZO_SavedVars:NewAccountWide("ChestMaster9000_SV", 1, nil, Addon.Defaults)
		
		EVENT_MANAGER:RegisterForEvent(Addon.Name, EVENT_BEGIN_LOCKPICK, function(...) processLockPick(...) end )

		EVENT_MANAGER:UnregisterForEvent(Addon.Name, EVENT_ADD_ON_LOADED)		

		LMP:AddPinType(Addon.Name.."MapPin", pinCallback, nil, pinLayout, nil)
        	LMP:AddPinFilter(Addon.Name.."MapPin", Addon.NameSpaced, false, ChestMaster9000.SV, "pinFilter")
	
		SLASH_COMMANDS["/chest9000"] = processSlashCommands
	end
end

EVENT_MANAGER:RegisterForEvent(Addon.Name, EVENT_ADD_ON_LOADED, function(...) ChestMaster9000:EVENT_ADD_ON_LOADED(...) end )		

