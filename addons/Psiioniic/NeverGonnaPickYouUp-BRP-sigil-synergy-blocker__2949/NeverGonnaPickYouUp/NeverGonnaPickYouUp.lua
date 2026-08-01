NeverGonnaPickYouUp = NeverGonnaPickYouUp or {}
local NGP = NeverGonnaPickYouUp

NGP.name = "NeverGonnaPickYouUp"
NGP.version = "0.0.3"
NGP.distanceSquared = 250000
NGP.siaSupressed = false

function NGP.GetCurrentMapName()
	return GetMapTileTexture():gsub("Art/maps/",""):gsub("_0.dds", ""):gsub(".dds", ""):lower()
end

function NGP.CheckPositionLoop()
	local zoneId, worldX, worldY, worldZ = GetUnitWorldPosition("player")
	if NGP.IsInSigilRange(worldX,worldY,worldZ) then
		 SHARED_INFORMATION_AREA:SetSupressed(true)
		 if not NGP.siaSupressed then
			NGP.siaSupressed = true
			--d("SHARED_INFORMATION_AREA:SetSupressed(true)")
		end
	else
		 SHARED_INFORMATION_AREA:SetSupressed(false)
		 if NGP.siaSupressed then
			NGP.siaSupressed = false
			--d("SHARED_INFORMATION_AREA:SetSupressed(false)")
		end
	end
end

local function ActionSlotsActiveHotbarUpdated(didActiveHotbarChange, shouldUpdateAbilityAssignments, activeHotbarCategory)
	if didChange then SYNERGY:OnSynergyAbilityChanged() end
end

local function OnPlayerActivated()
	if NGP.IsInBrp() then
		d(NGP.name.." sigil blocker activated! version: "..NGP.version)
		EVENT_MANAGER:RegisterForUpdate(NGP.name.."CheckPositionLoop", 100, NGP.CheckPositionLoop)
	else
		EVENT_MANAGER:UnregisterForUpdate(NGP.name.."CheckPositionLoop")
		if NGP.siaSupressed then
			NGP.siaSupressed = false
			SHARED_INFORMATION_AREA:SetSupressed(false)
		end
	end
end

function NGP.IsInBrp()
	local mapName = NGP.GetCurrentMapName()
	return string.sub(mapName,1, 31) == "murkmire/ui_map_blackroseprison"
end

function NGP.IsInSigilRange(worldX,worldY,worldZ)
	-- stage 1
	if (worldX-105503)*(worldX-105503)+(worldZ-68472)*(worldZ-68472) < NGP.distanceSquared then return true end
	if (worldX-103545)*(worldX-103545)+(worldZ-70273)*(worldZ-70273) < NGP.distanceSquared then return true end
	if (worldX-102270)*(worldX-102270)+(worldZ-68460)*(worldZ-68460) < NGP.distanceSquared then return true end
	if (worldX-103481)*(worldX-103481)+(worldZ-66399)*(worldZ-66399) < NGP.distanceSquared then return true end
	
	-- stage 2: def / end / res / heal
	if (worldX-90617)*(worldX-90617)+(worldZ-64648)*(worldZ-64648) < NGP.distanceSquared then return true end
	if (worldX-90680)*(worldX-90680)+(worldZ-61385)*(worldZ-61385) < NGP.distanceSquared then return true end
	if (worldX-88579)*(worldX-88579)+(worldZ-63419)*(worldZ-63419) < NGP.distanceSquared then return true end
	if (worldX-92464)*(worldX-92464)+(worldZ-63413)*(worldZ-63413) < NGP.distanceSquared then return true end
	
	-- stage 3: def / end / res / heal
	if (worldX-95695)*(worldX-95695)+(worldZ-49335)*(worldZ-49335) < NGP.distanceSquared then return true end
	if (worldX-98946)*(worldX-98946)+(worldZ-49484)*(worldZ-49484) < NGP.distanceSquared then return true end
	if (worldX-96982)*(worldX-96982)+(worldZ-47314)*(worldZ-47314) < NGP.distanceSquared then return true end
	if (worldX-96895)*(worldX-96895)+(worldZ-51214)*(worldZ-51214) < NGP.distanceSquared then return true end
	
	-- stage 4: def / end / res / heal
	if (worldX-108492)*(worldX-108492)+(worldZ-39068)*(worldZ-39068) < NGP.distanceSquared then return true end
	if (worldX-108615)*(worldX-108615)+(worldZ-35803)*(worldZ-35803) < NGP.distanceSquared then return true end
	if (worldX-106488)*(worldX-106488)+(worldZ-37808)*(worldZ-37808) < NGP.distanceSquared then return true end
	if (worldX-110357)*(worldX-110357)+(worldZ-37835)*(worldZ-37835) < NGP.distanceSquared then return true end
	
	-- boss
	if (worldX-95937)*(worldX-95937)+(worldZ-29143)*(worldZ-29143) < NGP.distanceSquared then return true end
	if (worldX-96564)*(worldX-96564)+(worldZ-29130)*(worldZ-29130) < NGP.distanceSquared then return true end
	if (worldX-96665)*(worldX-96665)+(worldZ-32326)*(worldZ-32326) < NGP.distanceSquared then return true end
	if (worldX-96026)*(worldX-96026)+(worldZ-32322)*(worldZ-32322) < NGP.distanceSquared then return true end
	
	return false
end

function NGP.Init()
	local defaultOnSynergyAbilityChanged = SYNERGY.OnSynergyAbilityChanged
	function SYNERGY:OnSynergyAbilityChanged()
		if NGP.IsInBrp() then
			local zoneId, worldX, worldY, worldZ = GetUnitWorldPosition("player")
			local inSigilRange = NGP.IsInSigilRange(worldX,worldY,worldZ)
			
			if inSigilRange then
				--d("in sigil range! "..tostring(worldX).."/"..tostring(worldZ))
				return
			--else
			--	d("NOT in sigil range! "..tostring(worldX).."/"..tostring(worldZ))
			end
		end
		defaultOnSynergyAbilityChanged(self)
	end
	EVENT_MANAGER:RegisterForEvent(NGP.name.."OnPlayerActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
	EVENT_MANAGER:RegisterForEvent(NGP.name.."OnPlayerAlive", EVENT_PLAYER_ALIVE, OnPlayerActivated)
	
end

NGP.Init()
