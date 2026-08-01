local omr = OneMorRockgrove


function omr.activateBahsei()
	-- bahsei good or bad cone
	EVENT_MANAGER:RegisterForEvent("OMR Bahsei Cone CW", EVENT_COMBAT_EVENT, omr.onBahseiCone)
	EVENT_MANAGER:AddFilterForEvent("OMR Bahsei Cone CW", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 153517)
	EVENT_MANAGER:AddFilterForEvent("OMR Bahsei Cone CW", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
	EVENT_MANAGER:RegisterForEvent("OMR Bahsei Cone CCW", EVENT_COMBAT_EVENT, omr.onBahseiCone)
	EVENT_MANAGER:AddFilterForEvent("OMR Bahsei Cone CCW", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 153518)
	EVENT_MANAGER:AddFilterForEvent("OMR Bahsei Cone CCW", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)

	if omr.vars.bahseiPortalIcon then
		EVENT_MANAGER:RegisterForEvent("OMR Bahsei Beam", EVENT_COMBAT_EVENT, omr.healedByBeam)
		EVENT_MANAGER:AddFilterForEvent("OMR Bahsei Beam", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 153627)
		EVENT_MANAGER:AddFilterForEvent("OMR Bahsei Beam", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
	end


	if omr.vars.bahseiPortalSegments and Breadcrumbs then
		EVENT_MANAGER:RegisterForEvent("OMR Portal Breadcrumbs", EVENT_COMBAT_EVENT, omr.hitByPortal)
		EVENT_MANAGER:AddFilterForEvent("OMR Portal Breadcrumbs", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 153423)
		EVENT_MANAGER:AddFilterForEvent("OMR Portal Breadcrumbs", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
	end

	-- The rest is for bahsei cones so just exit if not enabled.
	if not omr.vars.goodConePrediction then return end

	-- correlate userIds to unitTags
	EVENT_MANAGER:RegisterForEvent("OMR ID Identification", EVENT_EFFECT_CHANGED, omr.idIdentification)
	EVENT_MANAGER:AddFilterForEvent("OMR ID Identification", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, 'group')

	-- bahsei light attack (for identifying who is (probably) tank)
	EVENT_MANAGER:RegisterForEvent("OMR Bahsei LA Carve", EVENT_COMBAT_EVENT, omr.onBahseiLightAttack)
	EVENT_MANAGER:AddFilterForEvent("OMR Bahsei LA Carve", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 150047)
	EVENT_MANAGER:RegisterForEvent("OMR Bahsei LA Slice", EVENT_COMBAT_EVENT, omr.onBahseiLightAttack)
	EVENT_MANAGER:AddFilterForEvent("OMR Bahsei LA Slice", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 150048)



	local current, max = GetUnitPower('boss1',COMBAT_MECHANIC_FLAGS_HEALTH)
	if (current/max) < 0.95 then -- fight hasnt actually just started, instead the player just got pulled in or left portal
		--d("Loading old vars since it looks like its not a wipe.")
		omr.oldConeId = omr.oldvars.oldConeId
		omr.probTankUnitTag = omr.oldvars.probTankUnitTag
	else
		omr.oldvars = {
			["oldConeId"] = nil,
			["probTankUnitTag"] = "",
		}
	end

	if omr.probTankUnitTag == "" then
		-- make the assumption that the tank with the lowest health is bahsei tank before getting concrete evidence from who gets attacked
		local lowestHealth = 1000000
		for i=1,12 do
			local unitTag = "group"..i
			if (GetGroupMemberSelectedRole(unitTag) == LFG_ROLE_TANK) then
				local _, max = GetUnitPower(unitTag, COMBAT_MECHANIC_FLAGS_HEALTH)
				if max < lowestHealth then
					omr.probTankUnitTag = unitTag
				end
			end
		end
	end
end


omr.probTankUnitTag = ""

omr.oldvars = {
	["oldConeId"] = nil,
	["probTankUnitTag"] = "",
}

function omr.deactivateBahsei()
	EVENT_MANAGER:UnregisterForEvent("OMR Bahsei Cone CW", EVENT_COMBAT_EVENT)
	EVENT_MANAGER:UnregisterForEvent("OMR Bahsei Cone CCW", EVENT_COMBAT_EVENT)
	EVENT_MANAGER:UnregisterForEvent("OMR Bahsei LA Carve", EVENT_COMBAT_EVENT)
	EVENT_MANAGER:UnregisterForEvent("OMR Bahsei LA Slice", EVENT_COMBAT_EVENT)
	EVENT_MANAGER:UnregisterForEvent("OMR ID Identification", EVENT_EFFECT_CHANGED)
	EVENT_MANAGER:UnregisterForEvent("OMR Bahsei Beam", EVENT_COMBAT_EVENT)
	EVENT_MANAGER:UnregisterForEvent("OMR Portal Breadcrumbs", EVENT_COMBAT_EVENT)

	if not (omr.probTankUnitTag == "") then omr.oldvars.probTankUnitTag = omr.probTankUnitTag end
	if not (omr.oldConeId == nil) then omr.oldvars.oldConeId = omr.oldConeId end
	
	
	--d(omr.probTankUnitTag)
	--d(omr.oldvars.probTankUnitTag)

	omr.oldConeId = nil
	omr.probTankUnitTag = ""
	omr.idLookup = {}
end

omr.bossRegistry[2] = omr.activateBahsei





-- bahsei room corners
-- 103118, 42650, 96430
-- 96677, 42650, 102867


omr.bahseiCorners = {
	{103118, 42650, 96430},
	{103118, 42650, 102867},
	{96677, 42650, 102867},
	{96677, 42650, 96430}
}

omr.bahseiCenter = {
	(omr.bahseiCorners[1][1]+omr.bahseiCorners[3][1])/2,
	(omr.bahseiCorners[1][3]+omr.bahseiCorners[3][3])/2
}

omr.idLookup = {}




function omr.onBahseiLightAttack(_, result, _, abilityName, _, _, sourceName, _, targetName, _, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId, _)
	-- abilityId = light attack (carve or slice) 150047 and 150048
	local unitTag = omr.idLookup[targetUnitId]
	if not unitTag then return end
	omr.probTankUnitTag = unitTag
	--d("Light attack: "..GetUnitDisplayName(unitTag).." was hit by "..tostring(sourceName).."'s "..tostring(abilityName).." (which is a light attack prob)")
end


function omr.idIdentification(_, _, _, effectName, unitTag, _, _, _, _, _, _, _, _, unitName, unitId, abilityId, _)
	omr.idLookup[unitId] = unitTag
	--d("ID Identification: "..unitTag.." has a id of "..unitId.." since they had "..effectName.." ("..abilityId..") on them")
end





-- tanks position will always be ahead of a portion of the group's position (hopefully), so identify if tank is clockwise or counterclockwise
-- from group. Then using that, assume that cone is spawning ahead of group and if its going in the same direction as tank then its good cone,
-- opposite is bad cone


-- ids from qcells
-- cw = 153517
-- ccw = 153518
omr.oldConeId = nil

function omr.onBahseiCone(_, result, _, abilityName, _, _, sourceName, _, targetName, _, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId)
	if omr.oldConeId == nil then
		omr.oldConeId = abilityId
		if omr.vars.initialConeIndicator then
			if abilityId == 153517 then
				omr.sendCSA("|c00FF00"..omr.vars.bahseiInitialCW.."|r", "|cB0B0B0(probably)|r", SOUNDS.BATTLEGROUND_NEARING_VICTORY)
				if omr.vars.bahseiInitialGroundArrows then omr.createInitialGroundMarkers(omr.vars.bahseiInitialCW) end
			else
				omr.sendCSA("|cFF0000"..omr.vars.bahseiInitialCCW.."|r", "|cB0B0B0(probably)|r", SOUNDS.TELVAR_MULTIPLIERMAX)
				if omr.vars.bahseiInitialGroundArrows then omr.createInitialGroundMarkers(omr.vars.bahseiInitialCCW) end
			end
		end
		return
	end

	if not omr.vars.goodConePrediction then return end

	-- get group position and normalize with origin at center of bahsei's arena
	local groupPositions = {}
	local bx = omr.bahseiCenter[1]
	local bz = omr.bahseiCenter[2]
	for i=1, 12 do
		local unitTag = "group"..i
		if (GetGroupMemberSelectedRole(unitTag) == LFG_ROLE_DPS) then
			local world, x, y, z = GetUnitRawWorldPosition(unitTag)
			if world == 1263 then
				groupPositions[#groupPositions+1] = {x-bx,z-bz}
			end
		end
	end

	local avgx, avgz = omr.distanceWeightedMean(groupPositions) -- calc xbar and zbar with dwm on dps locations. DWM should take care of outliers
	local groupTheta = math.atan2(avgz,avgx)
	--d("Group Theta = ".. groupTheta)
	-- Calc Group and Tank theta in respect to the center of bahsei's arena. 
	local world, tx, ty, tz = GetUnitRawWorldPosition(omr.probTankUnitTag)
	local tankTheta = math.atan2((tz-bz),(tx-bx))
	--d("Tank ("..GetUnitDisplayName(omr.probTankUnitTag)..") Theta = ".. tankTheta)


	local deltaTheta = tankTheta-groupTheta
	deltaTheta = (deltaTheta + math.pi) % (2*math.pi) - math.pi -- normalize it

	--d("Delta Theta is "..deltaTheta)


	-- based on the rotation which the tank is oriented relative to the group, identify which direction would be a good cone
	-- negative pi is west coming from the north, and positive pi is west coming from the south.
	local goodCone = 0
	if deltaTheta < 0 then
		goodCone = 153518 -- good cone is ccw
	else
		goodCone = 153517 -- good cone is cw
	end


	if goodCone == abilityId then
		omr.goodCone()
	else
		omr.badCone()
	end
	omr.oldConeId = abilityId

end













-- TELVAR_MULTIPLIERMAX on bad
-- BATTLEGROUND_NEARING_VICTORY on good

function omr.goodCone()
	omr.sendCSA("|c00FF00GOOD CONE|r", "|cB0B0B0(probably)|r", SOUNDS.BATTLEGROUND_NEARING_VICTORY)
	omr.border("OMR Bahsei Good Cone", 1000, 0x00FF001A, true)
end

function omr.badCone()
	omr.sendCSA("|cFF0000BAD CONE|r", "|cB0B0B0(probably)|r", SOUNDS.TELVAR_MULTIPLIERMAX)
	omr.border("OMR Bahsei Bad Cone", 1000, 0xFF00001A, true)
end


omr.bahseiCornersLabelled = {
	["Boring Corner"] = {103118, 42650, 96430},
	["Portal"] = {103118, 42650, 102867},
	["Entrance"] = {96677, 42650, 102867},
	["Banner"] = {96677, 42650, 96430}
}



omr.bahseiInitialGroundMarkers = {}

-- create spaced markers between player position and the corner specified
function omr.createInitialGroundMarkers(corner)
	local zone, startX, startY, startZ = GetUnitRawWorldPosition("player")
	local cornerPosition = omr.bahseiCornersLabelled[corner]
	if cornerPosition == nil then return end
	local endX = cornerPosition[1]
	local endY = cornerPosition[2]
	local endZ = cornerPosition[3]
	--SetPlayerWaypointByWorldLocation(endX,endY,endZ) -- to verify corners are the correct ones
	local delZ = endZ-startZ
	local delX = endX-startX
	local distance = math.sqrt(delX^2+delZ^2)

	local currentX = 0
	local currentZ = 0
	local currentY = endY-25
	local out = ""

	for r=0,distance,200 do
		currentX = startX + (r*delX)/distance
		currentZ = startZ + (r*delZ)/distance
		local p = {
			pos = {currentX,currentY,currentZ},
			color = 0xff00ff, -- /script d(string.format("%x", LibCodesCommonCode.RGBAToInt32(0,1,0,1)))
			texture = "world-pointer-down",
			disableDepthBuffers = true,
			playerFacing = true,
			size = 30,
		}
		local marker = omr.worldIcons:PlaceTexture(p)
		--local marker = OSI.CreatePositionIcon(currentX, currentY, currentZ, "OdySupportIcons/icons/squares/marker_lightblue.dds", 100)
		omr.bahseiInitialGroundMarkers[#omr.bahseiInitialGroundMarkers+1] = marker

	end

	if omr.vars.breadcrumbsBahseiInitialLine and Breadcrumbs then
		Breadcrumbs.RefreshLines()
		Breadcrumbs.AddLineToPool(startX, startY+5, startZ, endX, startY+5, endZ, {1,0,1})
	end

	EVENT_MANAGER:RegisterForUpdate("OMR Initial Bahsei Directions", 5000, omr.destroyInitialGroundMarkers)
end

function omr.destroyInitialGroundMarkers()
	EVENT_MANAGER:UnregisterForUpdate("OMR Initial Bahsei Directions")
	for i,v in pairs(omr.bahseiInitialGroundMarkers) do
		omr.worldIcons:RemoveElement(v)
		--OSI.DiscardPositionIcon(v)
	end
	omr.bahseiInitialGroundMarkers = {}
	if Breadcrumbs then
		Breadcrumbs.RefreshLines()
	end
end














omr.lastHealTick = 0
omr.downstairsMarker = {}
function omr.healedByBeam()
	local time = os.rawclock()
	if time < omr.lastHealTick + 500 then return end
	

	local groupPositions = {}
	for i=1, 12 do
		local unitTag = "group"..i
		if (GetGroupMemberSelectedRole(unitTag) == LFG_ROLE_DPS) then
			local world, x, y, z = GetUnitRawWorldPosition(unitTag)
			if world == 1263 then
				groupPositions[#groupPositions+1] = {x,z}
			end
		end
	end
	local avgx, avgz = omr.distanceWeightedMean(groupPositions) -- calc xbar and zbar with dwm on dps locations. DWM should take care of outliers

	local world, px, py, pz = GetUnitRawWorldPosition('player')

	if omr.vars.breadcrumbsBahseiPortalLine and Breadcrumbs then
		Breadcrumbs.RefreshLines()
		Breadcrumbs.AddLineToPool(px, py, pz, avgx, py, avgz, {1,0,1})
	end

	-- create marker here

	if omr.lastHealTick == 0 then
		EVENT_MANAGER:RegisterForUpdate("OMR Bahsei Stop Beam", 1000, omr.revertHealByBeam)
	else
		--OSI.DiscardPositionIcon(omr.downstairsMarker)
		omr.worldIcons:RemoveElement(omr.downstairsMarker)
	end

	local p = {
		pos = {avgx,py,avgz},
		color = 0xffffffff,
		texture = "world-pointer-down",
		disableDepthBuffers = true,
		playerFacing = true,
		size = 200,
		elevation = 100,
	}
	omr.downstairsMarker = omr.worldIcons:PlaceTexture(p)
	--omr.downstairsMarker = OSI.CreatePositionIcon(avgx, py, avgz, "OdySupportIcons/icons/arrow.dds", 200)
	omr.lastHealTick = time
end


function omr.revertHealByBeam()
	local time = os.rawclock()
	if time < omr.lastHealTick + 5000 then return end
	--OSI.DiscardPositionIcon(omr.downstairsMarker)
	omr.worldIcons:RemoveElement(omr.downstairsMarker)
	if Breadcrumbs then
		Breadcrumbs.RefreshLines()
	end

	EVENT_MANAGER:UnregisterForUpdate("OMR Bahsei Stop Beam")
	omr.lastHealTick = 0
end





-- first 12 create the numbers. last 15 create the lines (3 lines, 5 segments each)
local portalLines = {
	{99847, 43600, 102867, 99947, 43600, 102867, {0, 1, 0}},
	{99847, 43475, 102867, 99947, 43475, 102867, {0, 1, 0}},
	{99847, 43350, 102867, 99947, 43350, 102867, {0, 1, 0}},
	{99847, 43600, 102867, 99847, 43350, 102867, {0, 1, 0}},
	{99947, 43600, 96430, 99847, 43600, 96430, {0, 1, 0}},
	{99947, 43600, 96430, 99947, 43475, 96430, {0, 1, 0}},
	{99847, 43475, 96430, 99947, 43475, 96430, {0, 1, 0}},
	{99847, 43475, 96430, 99847, 43350, 96430, {0, 1, 0}},
	{99847, 43350, 96430, 99947, 43350, 96430, {0, 1, 0}},
	{96636, 43350, 99576, 96636, 43600, 99576, {0, 1, 0}},
	{96636, 43550, 99626, 96636, 43600, 99576, {0, 1, 0}},
	{96636, 43350, 99526, 96636, 43350, 99626, {0, 1, 0}},
	{99897, 42760, 99648, 99387, 42760, 100158, {0.5, 0, 1}},
	{99387, 42760, 100158, 98877, 42760, 100669, {0.5, 0, 1}},
	{98877, 42760, 100669, 98367, 42760, 101179, {0.5, 0, 1}},
	{98367, 42760, 101179, 97857, 42760, 101689, {0.5, 0, 1}},
	{97857, 42760, 101689, 97347, 42760, 102200, {0.5, 0, 1}},
	{99897, 42760, 99648, 99391, 42760, 99138, {0.5, 0, 1}},
	{99391, 42760, 99138, 98885, 42760, 98627, {0.5, 0, 1}},
	{98885, 42760, 98627, 98379, 42760, 98117, {0.5, 0, 1}},
	{98379, 42760, 98117, 97873, 42760, 97607, {0.5, 0, 1}},
	{97873, 42760, 97607, 97368, 42760, 97097, {0.5, 0, 1}},
	{99897, 42760, 99648, 100405, 42760, 99648, {0.5, 0, 1}},
	{100405, 42760, 99648, 100913, 42760, 99648, {0.5, 0, 1}},
	{100913, 42760, 99648, 101421, 42760, 99648, {0.5, 0, 1}},
	{101421, 42760, 99648, 101929, 42760, 99648, {0.5, 0, 1}},
	{101929, 42760, 99648, 102437, 42760, 99648, {0.5, 0, 1}},
}

omr.lastMarrowTick = 0
function omr.hitByPortal()
	local time = os.rawclock()
	if omr.lastMarrowTick == 0 then
		-- create downstairs markers
		Breadcrumbs.RefreshLines()
		for i,v in pairs(portalLines) do
			Breadcrumbs.AddLineToPool(unpack(v))
		end
	end
	EVENT_MANAGER:RegisterForUpdate("OMR Bahsei Disable Portal Breadcrumbs", 1000, omr.revertHitByPortal)
	omr.lastMarrowTick = time
end

function omr.revertHitByPortal()
	local time = os.rawclock()
	if time < omr.lastMarrowTick + 5000 then return end
	Breadcrumbs.RefreshLines()

	EVENT_MANAGER:UnregisterForUpdate("OMR Bahsei Disable Portal Breadcrumbs")
	omr.lastMarrowTick = 0
end

--153423
--EVENT_MANAGER:RegisterForEvent("OMR Portal Breadcrumbs", EVENT_COMBAT_EVENT, omr.healedByBeam)
--EVENT_MANAGER:AddFilterForEvent("OMR Bahsei Beam", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 153423)
--EVENT_MANAGER:AddFilterForEvent("OMR Bahsei Beam", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)







