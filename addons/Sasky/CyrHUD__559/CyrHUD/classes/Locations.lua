-- This file is part of CyrHUD
--
-- (C) 2014 Scott Yeskie (Sasky)
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

CyrHUD = CyrHUD or {}

local shortenLocationName = function(str)
    return str:gsub(",..$", ""):gsub("%^.d$", "")
	--EN
	    :gsub(" Wayshrine", "")
		:gsub("District", "")
        :gsub("Castle ","")
        :gsub("[fF]ort ","")
        :gsub("Keep ","")
        :gsub("Lumber ","")
		:gsub("Scroll Temple of ", "")
end


function CyrHUD.PopulateLocations(zoneIndex, currentMapId)

    CyrHUD.locations = CyrHUD.locations or {} 
	
	if CyrHUD.locations[currentMapId] then
	   return
	end 
	
    CyrHUD.locations[currentMapId] = CyrHUD.locations[currentMapId] or {}

    local index = 1 

    -- Keeps, Towns, Resources
	for keepId = 1, 200 do 
		local pinType, normalizedX, normalizedY = GetKeepPinInfo(keepId, BGQUERY_LOCAL)
		local keepName = GetKeepName(keepId)
		
		if normalizedX ~= 0 and  normalizedY ~= 0 and keepName and keepName ~= "" then
            keepName = LocalizeString('<<1>>', keepName)
			keepName = shortenLocationName(keepName)
         	CyrHUD.locations[currentMapId][index] = { x = normalizedX, y = normalizedY , name = keepName:gsub("%^.+", "")}
			index = index + 1
		end
	end
	
	-- POIs
	for poiIndex = 1, GetNumPOIs(zoneIndex) do
        local normalizedX, normalizedY, poiType, icon, isShownInCurrentMap = GetPOIMapInfo(zoneIndex, poiIndex)
        local poiName = GetPOIInfo(zoneIndex, poiIndex)
 		if normalizedX ~= 0 and  normalizedY ~= 0 and poiName and poiName ~= "" then
		    poiName = LocalizeString('<<1>>', poiName)
			poiName = shortenLocationName(poiName)
            CyrHUD.locations[currentMapId][index] = { x = normalizedX, y = normalizedY , name = poiName:gsub("%^.+", "")}
            index = index + 1 
		end
  	end
end



function CyrHUD.GetClosestLocationName(fromX, fromY) 
    if not IsPlayerInAvAWorld() then
	   return ""
	end

    if fromX == fromY and fromX == 0 then
	    return ""
    end	
	
	local currentMapId = GetCurrentMapId()
    local zoneIndex = GetCurrentMapZoneIndex()
	
    CyrHUD.PopulateLocations(zoneIndex, currentMapId)
	
	local closestLocationName = ""
	local closestDistanceSq = math.huge

	-- 05/07/2026 performance improvement:
	-- This is called once per second for every active MovingObjective (e.g. an
	-- Elder Scroll or Volendrung carrier) and scans every tracked location on the
	-- current map (up to ~200+ keeps/POIs). The old code called math.sqrt() and
	-- the `^2` power operator (both notably more expensive than a plain multiply)
	-- for every single location just to compare which one was closest. Since
	-- square root is monotonic, comparing squared distances gives the exact same
	-- "closest" result without ever needing sqrt(), and replacing `^2` with a
	-- direct multiply avoids the pow() call too.
	for i, v in pairs(CyrHUD.locations[currentMapId]) do

	    local name =  v.name
	    local dx = v.x - fromX
	    local dy = v.y - fromY
	    local distanceSq = dx*dx + dy*dy
        if distanceSq < closestDistanceSq then
		   closestDistanceSq = distanceSq
		   closestLocationName = name
        end		
	end

	return closestLocationName
end
