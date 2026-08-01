LH = LH or {}
LH.name = "Llothis"
LH.version = "1.0"
LH.tracker = ZO_SimpleSceneFragment:New(LlothisTracker)

LH.enabled = false
LH.dormant = false
LH.counter = -1

function LH.onZoneChange(_, _, show)

	local zone, x, y, z = GetUnitWorldPosition("player")
	
	if zone == 1000 or show then
		HUD_SCENE:AddFragment(LH.tracker)
		HUD_UI_SCENE:AddFragment(LH.tracker)
		LlothisTracker:SetHidden(false)
		
		EVENT_MANAGER:RegisterForEvent(LH.name, EVENT_COMBAT_EVENT, LH.OnCombatEvent)
		EVENT_MANAGER:RegisterForEvent(LH.name, EVENT_EFFECT_CHANGED, LH.EffectChanged)
		EVENT_MANAGER:RegisterForEvent(LH.name, EVENT_PLAYER_COMBAT_STATE, LH.OnCombatChange)

		LH.enabled = false
		LH.counter = -1
		LH.SetText("~", "E6FC44", false)
	else
		LlothisTracker:SetHidden(true)
		HUD_SCENE:RemoveFragment(LH.tracker)
		HUD_UI_SCENE:RemoveFragment(LH.tracker)
		
		EVENT_MANAGER:UnregisterForEvent(LH.name, EVENT_COMBAT_EVENT)
		EVENT_MANAGER:UnregisterForEvent(LH.name, EVENT_EFFECT_CHANGED)
		EVENT_MANAGER:UnregisterForEvent(LH.name, EVENT_PLAYER_COMBAT_STATE)
		EVENT_MANAGER:UnregisterForUpdate(LH.name .. "_loop", 1000, LH.Loop)
	end
end

function LH.OnCombatEvent(_, result, _, _, _, _, _, _, _, _, _, _, _, _, _, _, abilityId)
	if abilityId == 95585 then -- Oppressive Bolts
		if result == 2200 or result == 2250 then
			LH.counter = 12
			if LH.enabled == false then
				EVENT_MANAGER:RegisterForUpdate(LH.name .. "_loop", 1000, LH.Loop)
				LH.enabled = true
			end
		end
	end
end

function LH.EffectChanged(_, changeType, _, _, _, beginTime, endTime, _, _, _, _, _, _, unitName, _, abilityId, _)
	if abilityId == 99990 then -- Dormant
		if unitName:find("Llothis") == nil then return end
		if changeType == EFFECT_RESULT_GAINED then
			LH.dormant = true
			LH.counter = (endTime - beginTime - 2)
			EVENT_MANAGER:UnregisterForUpdate(LH.name .. "_loop", 1000, LH.Loop)
			EVENT_MANAGER:RegisterForUpdate(LH.name .. "_loop", 1000, LH.Loop)
		elseif changeType == EFFECT_RESULT_FADED then
			LH.dormant = false
		end
	end
end

function LH.OnCombatChange(_, inCombat)
	if inCombat == false and LH.IsWipe() == true then
		EVENT_MANAGER:UnregisterForUpdate(LH.name .. "_loop", 1000, LH.Loop)
		LH.enabled = false
		LH.counter = -1
		LH.SetText("~", "E6FC44", false)
	end
end

function LH.Loop()
	if LH.counter > 0 then
		local color
		if LH.dormant == true then
			color = "44AFFC" -- blue
		elseif LH.counter > 3 then
			color = "17FF76" -- green
		else
			color = "FFFF64" -- yellow
		end
		LH.SetText(tostring(LH.counter), color, false)
		LH.counter = LH.counter - 1
	else
		local text = "SOON"
		if LH.dormant == true then text = "INTERRUPT" end
		LH.SetText(text, "F45042", true)
	end
end

function LH.SetText(content, color, isText)
	local size = isText and "35" or "65"
	LlothisTrackerCounter:SetFont("EsoUI/Common/Fonts/univers67.otf|" .. size .. "|soft-shadow-thick")
	LlothisTrackerCounter:SetText("|c" .. color .. content .. "|r")
end

function LH.GetAngle(targetUnitTag)

	local _, playerX, playerY, playerZ = GetUnitWorldPosition("player")
	local _, targetX, targetY, targetZ = GetUnitWorldPosition(targetUnitTag)

	local distance = math.sqrt((targetX - playerX)*(targetX - playerX) + (targetZ - playerZ)*(targetZ - playerZ))

	--d("Distance: " .. distance)

	local playerAngle = GetPlayerCameraHeading()

	local targetTranslatedX = targetX - playerX
	local targetTranslatedZ = targetZ - playerZ

	local newVectorZ = distance * math.cos(playerAngle)
	local newVectorX = distance * math.sin(playerAngle)

	--d("Llothis New: " .. targetTranslatedX .. "/" .. targetTranslatedZ .. "\n")
	--d("New Vector: " .. newVectorX  .. "/" .. newVectorZ .. "\n")

	local angle = math.acos((targetTranslatedX * newVectorX + targetTranslatedZ * newVectorZ) / (distance*distance))

	local angleToDegree = angle / math.pi * 180

	--d("Angle to Llothis: " .. angleToDegree)
	
	return angle
end

function LH.IsWipe()
	if IsUnitGrouped("player") == true then
		for i = 1, GetGroupSize() do
			local player = GetGroupUnitTagByIndex(i)
			if IsUnitDead(player) == true then
				return false
			end
		end
		return true
	else
		if IsUnitDead("player") == true then
			return true
		else
			return false
		end
	end
end

function LH.OnAddOnLoaded(_, addonName)
	if addonName ~= LH.name then return end
	
	LH.initializeSettingsMenu()
	
	if LH.savedVariables.trackerLeft ~= nil and LH.savedVariables.trackerTop ~= nil then
		LlothisTracker:ClearAnchors()
		LlothisTracker:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, LH.savedVariables.trackerLeft, LH.savedVariables.trackerTop)
	end
	
	if LH.savedVariables.lockui == true then
		LlothisTracker:SetMovable(false)
	end	
	
	EVENT_MANAGER:RegisterForEvent(LH.name, EVENT_PLAYER_ACTIVATED, LH.onZoneChange)
end

EVENT_MANAGER:RegisterForEvent(LH.name, EVENT_ADD_ON_LOADED, LH.OnAddOnLoaded)