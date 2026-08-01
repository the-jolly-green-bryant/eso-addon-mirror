RRT = {
    name            = "RadiatingRegenTracker",
    author          = "branddi",
    color           = "DDFFEE",            
    menuName        = "RadiatingRegenTracker",
}

local currentScene
local manuallyShowUi = false

local function getCurrentScene(_,newState)
	currentScene = newState
end

local roleIcons = {
	[0] = "/esoui/art/contacts/gamepad/gp_social_status_offline.dds",
	[1] = "/esoui/art/lfg/gamepad/lfg_roleicon_dps.dds",
	[2] = "/esoui/art/lfg/gamepad/lfg_roleicon_tank.dds",
	[4] = "/esoui/art/lfg/gamepad/lfg_roleicon_healer.dds",
}
	

local function processTimer(time)
	if time%1 == 0 then
		return time..".0"
	end
	return time
end

local function ToggleUI(_, newState)
  if newState == SCENE_SHOWN then

	if RRTsavedVars.onlyTrackWhenWearing then
		RadiatingRegenTrackerUI:SetHidden(true)
	else
		RadiatingRegenTrackerUI:SetHidden(IsReticleHidden())
	end

  elseif newState == SCENE_HIDDEN then

	RadiatingRegenTrackerUI:SetHidden(true)


  end
end

local function findBiggestValueInTable(table)
	local biggestValue=0
	local keyOfBiggest=0
	for k,v in pairs(table) do
		if v>biggestValue then
			biggestValue = v
			keyOfBiggest = k
		end
	end
	return biggestValue,keyOfBiggest
end


local function IsRadiatingRegenAbility(abilityId)
    return (abilityId == 40079)
end

local function isRadiatingRegenSkillSlotted()
    local hasRR = false
    for hotbarSlot = 2, 7 do
        if IsRadiatingRegenAbility(GetSlotBoundId(hotbarSlot, HOTBAR_CATEGORY_PRIMARY)) then
            hasRR = true
        end
        if IsRadiatingRegenAbility(GetSlotBoundId(hotbarSlot, HOTBAR_CATEGORY_BACKUP)) then
            hasRR = true
        end
    end
    return hasRR
end



local function getRRTargets()
	resultHolder = {}
	for i=1, 12 do
		distance = RRT_GetDistance("player","group"..i)

		if #resultHolder <= 6 and distance ~= -1 and distance <= 28 then
			resultHolder[i] = distance
		elseif distance ~= -1 and distance <=28 then
			_,bigKey = findBiggestValueInTable(resultHolder)
			resultHolder[i] = distance
			resultHolder[bigKey] = nil
		end
	end
	return resultHolder
end


local function GetRRTime(unit)
	for i=1,GetNumBuffs(unit) do
		local _, _, timeEnding, _, stacks, _, _, _, _, _, abilityId, _, _ = GetUnitBuffInfo(unit,i)
        if abilityId == 40079 then
            return (timeEnding-GetGameTimeSeconds())
        end
    end
    return 0
end






function RRT_showUI()
    manuallyShowUi = true
	if RadiatingRegenTrackerUI:IsHidden() then
		--RadiatingRegenTrackerUI:SetHidden(false)

		if RRTsavedVars.onlyTrackWhenWearing then
			RadiatingRegenTrackerUI:SetHidden(true)
		else
			RadiatingRegenTrackerUI:SetHidden(false)
		end
	else
		RadiatingRegenTrackerUI:SetHidden(true)
	end

end

local function RRT_GetDistance(unit1,unit2)
	if not DoesUnitExist(unit1) or not DoesUnitExist(unit2) then
		return -1
	end
	local zone1, x1, y1, z1 = GetUnitWorldPosition(unit1)
	local zone2, x2, y2, z2 = GetUnitWorldPosition(unit2)
	if zone1~=zone2 then
		return -1
	else
		return(zo_sqrt((x1 - x2)^2 + (z1 - z2)^2) / 100)
	end
end






------------------ FUNCTIONS -------------------

local function RRT_hideUI()
    if manuallyShowUi then
            RadiatingRegenTrackerUI:SetHidden(false)
	else
        if RRTsavedVars.onlyTrackWhenWearing then
            RadiatingRegenTrackerUI:SetHidden(true)
        else
            if isRadiatingRegenSkillSlotted() then
                RadiatingRegenTrackerUI:SetHidden(IsReticleHidden())
            else
                RadiatingRegenTrackerUI:SetHidden(true)
            end
        end
	end
end

-->>>>>>>>>>>>>>>>>>>>>>>>> INITIALIZE UI <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<--


local function RRTgenerateUI()

	RRTWindowManager = GetWindowManager()

	local RadiatingRegenTrackerUI = RRTWindowManager:CreateTopLevelWindow("RadiatingRegenTrackerUI")



	RadiatingRegenTrackerUI:SetResizeToFitDescendents(true)
    RadiatingRegenTrackerUI:SetMovable(true)
    RadiatingRegenTrackerUI:SetMouseEnabled(true)
	RadiatingRegenTrackerUI:SetHidden(true)



	RadiatingRegenTrackerUI:SetHandler("OnMoveStop", function(control)
        RRTsavedVars.xOffsetOwnStacks = RadiatingRegenTrackerUI:GetLeft()
	    RRTsavedVars.yOffsetOwnStacks  = RadiatingRegenTrackerUI:GetTop()
    end)


		
		local SelfBuffsBackground = RRTWindowManager:CreateControl("$(parent)RRBackground", RadiatingRegenTrackerUI, CT_BACKDROP)
		SelfBuffsBackground:SetEdgeColor(0,0,0)
		SelfBuffsBackground:SetCenterColor(0,0,0)
		SelfBuffsBackground:SetAnchor(TOPLEFT, RadiatingRegenTrackerUI, TOPLEFT, 0, 0)
		SelfBuffsBackground:SetAlpha(1)
		SelfBuffsBackground:SetScale(1.0)
		SelfBuffsBackground:SetDrawLayer(0)
		SelfBuffsBackground:SetHidden(false)
		SelfBuffsBackground:SetDimensions(210,300)

		local AAAicon = RRTWindowManager:CreateControl("$(parent)RRIconUP", RadiatingRegenTrackerUI, CT_TEXTURE,4)
		AAAicon:SetDimensions(20, 20)
		AAAicon:SetAnchor(TOPLEFTLEFT,SelfBuffsBackground,TOPLEFT,5,5)
		AAAicon:SetTexture("/esoui/art/icons/ability_restorationstaff_002a.dds")

		AAAicon:SetHidden(false)
		AAAicon:SetDrawLayer(2)

		local SelfBuffsText = RRTWindowManager:CreateControl("$(parent)RRText",RadiatingRegenTrackerUI,CT_LABEL)
		SelfBuffsText:SetFont("ZoFontGameSmall")
		SelfBuffsText:SetScale(1.0)
		SelfBuffsText:SetDrawLayer(1)
		SelfBuffsText:SetColor(255, 255, 255, 1)
		SelfBuffsText:SetText("Radiating Regen Tracker")
		SelfBuffsText:SetAnchor(TOPCENTER, SelfBuffsBackground, TOPCENTER,32, 5)
		SelfBuffsText:SetDimensions(200, 20)
		SelfBuffsText:SetHorizontalAlignment(CENTER)
		SelfBuffsText:SetHidden(false)

		

		local gapBetweenElements = 20
		local additionalGap = 2

		for n=1, 12 do

				timer = RRTWindowManager:CreateControl("$(parent)RRDurationTimer"..n, RadiatingRegenTrackerUI, CT_LABEL)
				timer:SetFont("ZoFontGameSmall")
				timer:SetScale(1.0)
				timer:SetWrapMode(TEX_MODE_CLAMP)
				timer:SetDrawLayer(2)
				timer:SetColor(255,255,255, 1)
				timer:SetText("0.0s")				
				timer:SetAnchor(TOPLEFT, SelfBuffsBackground, TOPLEFT, 5, (22*n)+9)
				timer:SetDimensions(200, 20)
				timer:SetHorizontalAlignment(LEFT)
				timer:SetHidden(false)
			
				barOutline = RRTWindowManager:CreateControl("$(parent)RROutlineBar"..n, RadiatingRegenTrackerUI, CT_TEXTURE)
				barOutline:SetDimensions(158, 22)
				barOutline:SetAnchor(TOPLEFT, SelfBuffsBackground, TOPLEFT, 26, (22*n)+7)
				barOutline:SetTexture("/esoui/art/ava/ava_resourcestatus_progbar_achieved_overlay.dds")
				barOutline:SetHidden(false)
				barOutline:SetDrawLayer(2)
			

				bar = RRTWindowManager:CreateControl("$(parent)RRDurationBar"..n, RadiatingRegenTrackerUI, CT_STATUSBAR)
				bar:SetScale(1.0)
				bar:SetAnchor(LEFT, barOutline, LEFT, 5,0)
				bar:SetDimensions(152, 20)
				bar:SetColor(0, 1, 0.1, 1)
				bar:SetHidden(false)		
				bar:SetDrawLayer(2)
				bar:SetTexture(RRTsavedVars.barTexture)

				textInBar = RRTWindowManager:CreateControl("$(parent)RRTextInBar"..n, RadiatingRegenTrackerUI, CT_LABEL)
				textInBar:SetFont("ZoFontGameSmall")
				textInBar:SetScale(1.0)
				textInBar:SetWrapMode(TEX_MODE_CLAMP)
				textInBar:SetDrawLayer(3)
				textInBar:SetColor(255,255,255, 1)
				textInBar:SetText("Group Member "..n)				
				textInBar:SetAnchor(TOPLEFT, SelfBuffsBackground, TOPLEFT, 36,(22*n)+9)
				textInBar:SetDimensions(200, 20)
				textInBar:SetHidden(false)

				icon = RRTWindowManager:CreateControl("$(parent)RRIcon"..n, RadiatingRegenTrackerUI, CT_TEXTURE,4)
				icon:SetDimensions(20, 20)
				icon:SetAnchor(TOPLEFTLEFT,SelfBuffsBackground,TOPLEFT,5,(22*n)+7)
				icon:SetTexture(roleIcons[1])
				icon:SetHidden(false)
				icon:SetDrawLayer(2)




				additionalGap = additionalGap + 2
				gapBetweenElements = gapBetweenElements + 20
		end







	
	RadiatingRegenTrackerUI:ClearAnchors()
	RadiatingRegenTrackerUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,RRTsavedVars.xOffsetOwnStacks,RRTsavedVars.yOffsetOwnStacks)

end

-->>>>>>>>>>>>>>>>>>>>>>>>> INITIALIZE UI <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<--









-->>>>>>>>>>>>>>>>>>>>>>>>> UPDATE UI <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<--

local function UpdateDuration()
	local countMembers = 0
	local background = RadiatingRegenTrackerUI:GetNamedChild("RRBackground")
    local playersThatNeedAndAreEligableForRR = 0

	for i=1, 12 do

		local searchBy = "group"..i
		if not IsUnitGrouped("player") then
			searchBy = "player"
		end
		local bar = RadiatingRegenTrackerUI:GetNamedChild("RRDurationBar"..i)
		local textInBar = RadiatingRegenTrackerUI:GetNamedChild("RRTextInBar"..i)
		local icon = RadiatingRegenTrackerUI:GetNamedChild("RRIcon"..i)
		local timer = RadiatingRegenTrackerUI:GetNamedChild("RRDurationTimer"..i)
		local outlineBar = RadiatingRegenTrackerUI:GetNamedChild("RROutlineBar"..i)


		local inRange = False
		local needsRR = False

		if (DoesUnitExist("group"..i) and (GetGroupMemberSelectedRole(searchBy) == 1 or (not RRTsavedVars.trackOnlyDD))) or (i==1 and not IsUnitGrouped("player")) then
			bar:SetHidden(false)
			textInBar:SetHidden(false)
			icon:SetHidden(false)
			timer:SetHidden(false)
			if RRT_GetDistance("player","group"..i) <=28 and RRT_GetDistance("player","group"..i) ~= -1  and IsUnitDead("group"..i)==false then
				outlineBar:SetHidden(false)
				inRange=true
			else
				outlineBar:SetHidden(true)
			end
			countMembers = countMembers + 1
		else
			bar:SetHidden(true)
			textInBar:SetHidden(true)
			icon:SetHidden(true)
			timer:SetHidden(true)
			outlineBar:SetHidden(true)
		end
		icon:SetTexture(roleIcons[GetGroupMemberSelectedRole(searchBy)])
		textInBar:SetText(GetUnitDisplayName(searchBy)) -- @Name for everyone

		timeRemaining = GetRRTime(searchBy)
		timer:SetText(processTimer((math.floor(timeRemaining*10)/10)).."s")
		if timeRemaining <= 0 then
			bar:SetDimensions(152,20)
			bar:SetTextureCoords(0,1,0,1)
			bar:SetColor(0,1,0.1,0.2)


            needsRR = true


            icon:SetColor(1,1,1,1) -- White RR is needed

		else
			bar:SetDimensions(152*(timeRemaining/10),20)
			bar:SetTextureCoords(0,timeRemaining/10,0,1)
            bar:SetColor(0,1,0.1,1)

			icon:SetColor(0,1,0,1) -- Green RR is applied already

		end
		timer:SetAnchor(TOPLEFT, background, TOPLEFT, 5, (22*countMembers)+9)
		bar:SetAnchor(LEFT, outlineBar, LEFT, 5,0)
		textInBar:SetAnchor(TOPLEFT, background, TOPLEFT, 34, (22*countMembers)+9)
		icon:SetAnchor(TOPLEFT, background, TOPLEFT, 5, (22*countMembers)+7)
		outlineBar:SetAnchor(TOPLEFT, background, TOPLEFT, 26, (22*countMembers)+7)

		if needsRR and inRange then
		    playersThatNeedAndAreEligableForRR=playersThatNeedAndAreEligableForRR+1
		end
	end

	if (not (RRTsavedVars.disableInTrials and countMembers >= 8)) or countMembers <= 4 then -- 4 is for 4man, 12 is for trials

	    if playersThatNeedAndAreEligableForRR>=1 then
	        if IsUnitInCombat("player") then
                background:SetCenterColor(1,0.1,0.1) -- auto display red when RR is needed to be casted
            else
                background:SetCenterColor(0,0,0)
            end
	    else
	        background:SetCenterColor(0,0,0)
	    end
	else
	    RadiatingRegenTrackerUI:SetHidden(true)

	    background:SetCenterColor(0,0,0)
	end

	background:SetDimensions(210,(countMembers*22)+30)








end

-->>>>>>>>>>>>>>>>>>>>>>>>> UPDATE UI <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<--




------------------- INITIALIZE --------------------------


function OnAddOnLoaded(event, addonName)
    if addonName ~= RRT.name then return end
    EVENT_MANAGER:UnregisterForEvent(RRT.name, EVENT_ADD_ON_LOADED)

	

	local default = {
		trackOnlyDD = false,
		onlyTrackWhenWearing = false,
		xOffsetOwnStacks = 200,
		yOffsetOwnStacks = 200,
		barTexture = "RadiatingRegenTracker/icons/gradientProgressBar.dds",
		showOnlyInCombat = true,
		disableInTrials = true,


	}
	RRTsavedVars = ZO_SavedVars:NewAccountWide("RadiatingRegenTrackerSavedVars",3, nil, default)
	RRTgenerateUI()
	UpdateDuration()








	RRT_LoadSettings()
	RRT_combatSwitch()
	EVENT_MANAGER:RegisterForEvent(RRT.name, EVENT_PLAYER_COMBAT_STATE,RRT_combatSwitch)
	EVENT_MANAGER:RegisterForEvent(RRT.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE,RRT_combatSwitch)


	EVENT_MANAGER:RegisterForEvent(RRT.name.."Hide", EVENT_RETICLE_HIDDEN_UPDATE, RRT_hideUI)

	SCENE_MANAGER:GetScene("hud"):RegisterCallback("StateChange", getCurrentScene)
	SCENE_MANAGER:GetScene("hudui"):RegisterCallback("StateChange", getCurrentScene)


end

------------------- INITIALIZE --------------------------


------------------- COMBAT / OUT OF COMBAT SWITCHING ---------------------
function RRT_combatSwitch()
    manuallyShowUi=false
	if (IsUnitInCombat("player") or not RRTsavedVars.showOnlyInCombat) and (not RRTsavedVars.onlyTrackWhenWearing) then
		SCENE_MANAGER:GetScene("hud"):RegisterCallback("StateChange", ToggleUI )
		SCENE_MANAGER:GetScene("hudui"):RegisterCallback("StateChange", ToggleUI)
		EVENT_MANAGER:RegisterForUpdate(RRT.name, 100,UpdateDuration)

		if currentScene == SCENE_SHOWN then

			if RRTsavedVars.onlyTrackWhenWearing then

					RadiatingRegenTrackerUI:SetHidden(true)
			else
				if isRadiatingRegenSkillSlotted() then
        		    RadiatingRegenTrackerUI:SetHidden(IsReticleHidden())
		        else
		            RadiatingRegenTrackerUI:SetHidden(true)
		        end
				--RadiatingRegenTrackerUI:SetHidden(IsReticleHidden())
			end
		end
		
	else
		SCENE_MANAGER:GetScene("hud"):UnregisterCallback("StateChange",ToggleUI)
		SCENE_MANAGER:GetScene("hudui"):UnregisterCallback("StateChange",ToggleUI)
		EVENT_MANAGER:UnregisterForUpdate(RRT.name, 100)
		
		RadiatingRegenTrackerUI:SetHidden(true)

		
	end

end

EVENT_MANAGER:RegisterForEvent(RRT.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)


------------------- COMBAT / OUT OF COMBAT SWITCHING ---------------------



