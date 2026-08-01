PAT = {
    name            = "PowerfulAssaultTracker",          
    author          = "Hyperioxes",
    color           = "DDFFEE",            
    menuName        = "PowerfulAssaultTracker",          
}

local currentScene

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

	PowerfulAssaultTrackerUI:SetHidden(false)

  elseif newState == SCENE_HIDDEN then

	PowerfulAssaultTrackerUI:SetHidden(true)

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

local function checkIfPaEquipped()
	local pa = 0
	_,_,_,pa = GetItemLinkSetInfo("|H1:item:117102:364:50:68343:370:50:0:0:0:0:0:0:0:0:1:24:0:1:0:8350:0|h|h",true)
	if pa>=3 then
		return true
	else
		return false
	end
end

function getPATargets()
	resultHolder = {}
	for i=1, 12 do
		distance = PAT_GetDistance("player","group"..i)

		if #resultHolder <= 6 and distance ~= -1 and distance <= 12 then
			resultHolder[i] = distance
		elseif distance ~= -1 and distance <= 12 then
			_,bigKey = findBiggestValueInTable(resultHolder)
			resultHolder[i] = distance
			resultHolder[bigKey] = nil
		end
	end
	return resultHolder
end


function GetPATime(unit)
	for i=1,GetNumBuffs(unit) do
		local _, _, timeEnding, _, stacks, _, _, _, _, _, abilityId, _, _ = GetUnitBuffInfo(unit,i)
        if abilityId == 61771 then
            return (timeEnding-GetGameTimeSeconds())
        end
    end
    return 0
end






function PAT_showUI()
	if PowerfulAssaultTrackerUI:IsHidden() then
		PowerfulAssaultTrackerUI:SetHidden(false)
	else
		PowerfulAssaultTrackerUI:SetHidden(true)
	end

end

function PAT_GetDistance(unit1,unit2)
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


-->>>>>>>>>>>>>>>>>>>>>>>>> INITIALIZE UI <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<--


function PATgenerateUI()

	PATWindowManager = GetWindowManager()

	local PowerfulAssaultTrackerUI = PATWindowManager:CreateTopLevelWindow("PowerfulAssaultTrackerUI")



	PowerfulAssaultTrackerUI:SetResizeToFitDescendents(true)
    PowerfulAssaultTrackerUI:SetMovable(true)
    PowerfulAssaultTrackerUI:SetMouseEnabled(true)
	PowerfulAssaultTrackerUI:SetHidden(true)


	PowerfulAssaultTrackerUI:SetHandler("OnMoveStop", function(control)
        PATsavedVars.xOffsetOwnStacks = PowerfulAssaultTrackerUI:GetLeft()
	    PATsavedVars.yOffsetOwnStacks  = PowerfulAssaultTrackerUI:GetTop()
    end)








		
		local SelfBuffsBackground = PATWindowManager:CreateControl("$(parent)PABackground", PowerfulAssaultTrackerUI, CT_BACKDROP)
		SelfBuffsBackground:SetEdgeColor(0,0,0)
		SelfBuffsBackground:SetCenterColor(0,0,0)
		SelfBuffsBackground:SetAnchor(TOPLEFT, PowerfulAssaultTrackerUI, TOPLEFT, 0, 0)
		SelfBuffsBackground:SetAlpha(1)
		SelfBuffsBackground:SetScale(1.0)
		SelfBuffsBackground:SetDrawLayer(0)
		SelfBuffsBackground:SetHidden(false)
		SelfBuffsBackground:SetDimensions(210,300)

		local AAAicon = PATWindowManager:CreateControl("$(parent)PAIconUP", PowerfulAssaultTrackerUI, CT_TEXTURE,4)
		AAAicon:SetDimensions(20, 20)
		AAAicon:SetAnchor(TOPLEFTLEFT,SelfBuffsBackground,TOPLEFT,5,5)
		AAAicon:SetTexture("/esoui/art/icons/ability_healer_019.dds")
		AAAicon:SetHidden(false)
		AAAicon:SetDrawLayer(2)

		local SelfBuffsText = PATWindowManager:CreateControl("$(parent)PAText",PowerfulAssaultTrackerUI,CT_LABEL)
		SelfBuffsText:SetFont("ZoFontGameSmall")
		SelfBuffsText:SetScale(1.0)
		SelfBuffsText:SetDrawLayer(1)
		SelfBuffsText:SetColor(255, 255, 255, 1)
		SelfBuffsText:SetText("Powerful Assault Tracker")				
		SelfBuffsText:SetAnchor(TOPCENTER, SelfBuffsBackground, TOPCENTER,32, 5)
		SelfBuffsText:SetDimensions(200, 20)
		SelfBuffsText:SetHorizontalAlignment(CENTER)
		SelfBuffsText:SetHidden(false)

		

		local gapBetweenElements = 20
		local additionalGap = 2

		for n=1, 12 do

				timer = PATWindowManager:CreateControl("$(parent)PADurationTimer"..n, PowerfulAssaultTrackerUI, CT_LABEL)			
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
			
				barOutline = PATWindowManager:CreateControl("$(parent)PAOutlineBar"..n, PowerfulAssaultTrackerUI, CT_TEXTURE)
				barOutline:SetDimensions(158, 22)
				barOutline:SetAnchor(TOPLEFT, SelfBuffsBackground, TOPLEFT, 26, (22*n)+7)
				barOutline:SetTexture("/esoui/art/ava/ava_resourcestatus_progbar_achieved_overlay.dds")
				barOutline:SetHidden(false)
				barOutline:SetDrawLayer(2)
			

				bar = PATWindowManager:CreateControl("$(parent)PADurationBar"..n, PowerfulAssaultTrackerUI, CT_STATUSBAR)	
				bar:SetScale(1.0)
				bar:SetAnchor(LEFT, barOutline, LEFT, 5,0)
				bar:SetDimensions(146, 20)
				bar:SetColor(0, 1, 0.1, 1)
				bar:SetHidden(false)		
				bar:SetDrawLayer(2)
				bar:SetTexture(PATsavedVars.barTexture)

				textInBar = PATWindowManager:CreateControl("$(parent)PATextInBar"..n, PowerfulAssaultTrackerUI, CT_LABEL)
				textInBar:SetFont("ZoFontGameSmall")
				textInBar:SetScale(1.0)
				textInBar:SetWrapMode(TEX_MODE_CLAMP)
				textInBar:SetDrawLayer(3)
				textInBar:SetColor(255,255,255, 1)
				textInBar:SetText("Group Member "..n)				
				textInBar:SetAnchor(TOPLEFT, SelfBuffsBackground, TOPLEFT, 36,(22*n)+9)
				textInBar:SetDimensions(200, 20)
				textInBar:SetHidden(false)

				icon = PATWindowManager:CreateControl("$(parent)PAIcon"..n, PowerfulAssaultTrackerUI, CT_TEXTURE,4)
				icon:SetDimensions(20, 20)
				icon:SetAnchor(TOPLEFTLEFT,SelfBuffsBackground,TOPLEFT,5,(22*n)+7)
				icon:SetTexture(roleIcons[1])
				icon:SetHidden(false)
				icon:SetDrawLayer(2)




				additionalGap = additionalGap + 2
				gapBetweenElements = gapBetweenElements + 20
		end







	
	PowerfulAssaultTrackerUI:ClearAnchors()
	PowerfulAssaultTrackerUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,PATsavedVars.xOffsetOwnStacks,PATsavedVars.yOffsetOwnStacks)	

end

-->>>>>>>>>>>>>>>>>>>>>>>>> INITIALIZE UI <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<--









-->>>>>>>>>>>>>>>>>>>>>>>>> UPDATE UI <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<--

local function UpdateDuration()
	local countMembers = 0
	local background = PowerfulAssaultTrackerUI:GetNamedChild("PABackground")

	for i=1, 12 do

		local searchBy = "group"..i
		if not IsUnitGrouped("player") then
			searchBy = "player"
		end
		local bar = PowerfulAssaultTrackerUI:GetNamedChild("PADurationBar"..i)
		local textInBar = PowerfulAssaultTrackerUI:GetNamedChild("PATextInBar"..i)
		local icon = PowerfulAssaultTrackerUI:GetNamedChild("PAIcon"..i)
		local timer = PowerfulAssaultTrackerUI:GetNamedChild("PADurationTimer"..i)
		local outlineBar = PowerfulAssaultTrackerUI:GetNamedChild("PAOutlineBar"..i)
		if (DoesUnitExist("group"..i) and (GetGroupMemberSelectedRole(searchBy) == 1 or (not PATsavedVars.trackOnlyDD))) or (i==1 and not IsUnitGrouped("player")) then
			bar:SetHidden(false)
			textInBar:SetHidden(false)
			icon:SetHidden(false)
			timer:SetHidden(false)
			if PAT_GetDistance("player","group"..i) <=10 and PAT_GetDistance("player","group"..i) ~= -1 then
				outlineBar:SetHidden(false)
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
		textInBar:SetText(GetUnitName(searchBy))
		timeRemaining = GetPATime(searchBy)
		timer:SetText(processTimer((math.floor(timeRemaining*10)/10)).."s")
		if timeRemaining <= 0 then
			bar:SetDimensions(146,20)
			bar:SetTextureCoords(0,1,0,1)
			bar:SetColor(0,1,0.1,0.2)
		else
			bar:SetDimensions(146*(timeRemaining/15),20)
			bar:SetTextureCoords(0,timeRemaining/15,0,1)
			bar:SetColor(0,1,0.1,1)
		end
		timer:SetAnchor(TOPLEFT, background, TOPLEFT, 5, (22*countMembers)+9)
		bar:SetAnchor(LEFT, outlineBar, LEFT, 5,0)
		textInBar:SetAnchor(TOPLEFT, background, TOPLEFT, 34, (22*countMembers)+9)
		icon:SetAnchor(TOPLEFT, background, TOPLEFT, 5, (22*countMembers)+7)
		outlineBar:SetAnchor(TOPLEFT, background, TOPLEFT, 26, (22*countMembers)+7)
	end
	background:SetDimensions(210,(countMembers*22)+30)








end

-->>>>>>>>>>>>>>>>>>>>>>>>> UPDATE UI <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<--




------------------- INITIALIZE --------------------------


function OnAddOnLoaded(event, addonName)
    if addonName ~= PAT.name then return end
    EVENT_MANAGER:UnregisterForEvent(PAT.name, EVENT_ADD_ON_LOADED)

	

	local default = {
		trackOnlyDD = false,
		onlyTrackWhenWearing = true,
		xOffsetOwnStacks = 200,
		yOffsetOwnStacks = 200,
		barTexture = "PowerfulAssaultTracker/icons/gradientProgressBar.dds",
		showOnlyInCombat = true,



	}
	PATsavedVars = ZO_SavedVars:NewAccountWide("PowerfulAssaultTrackerSavedVars",3, nil, default)
	PATgenerateUI()








	PAT_LoadSettings()
	PAT_combatSwitch()
	EVENT_MANAGER:RegisterForEvent(PAT.name, EVENT_PLAYER_COMBAT_STATE,PAT_combatSwitch)
	EVENT_MANAGER:RegisterForEvent(PAT.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE,PAT_combatSwitch)
	SCENE_MANAGER:GetScene("hud"):RegisterCallback("StateChange", getCurrentScene)
	SCENE_MANAGER:GetScene("hudui"):RegisterCallback("StateChange", getCurrentScene)



end

------------------- INITIALIZE --------------------------


------------------- COMBAT / OUT OF COMBAT SWITCHING ---------------------
function PAT_combatSwitch()
	if (IsUnitInCombat("player") or not PATsavedVars.showOnlyInCombat) and (checkIfPaEquipped() or not PATsavedVars.onlyTrackWhenWearing) then	
		SCENE_MANAGER:GetScene("hud"):RegisterCallback("StateChange", ToggleUI )
		SCENE_MANAGER:GetScene("hudui"):RegisterCallback("StateChange", ToggleUI)
		EVENT_MANAGER:RegisterForUpdate(PAT.name, 100,UpdateDuration)

		if currentScene == SCENE_SHOWN then
			PowerfulAssaultTrackerUI:SetHidden(false)
		end
		
	else
		SCENE_MANAGER:GetScene("hud"):UnregisterCallback("StateChange",ToggleUI)
		SCENE_MANAGER:GetScene("hudui"):UnregisterCallback("StateChange",ToggleUI)
		EVENT_MANAGER:UnregisterForUpdate(PAT.name, 100)
		
		PowerfulAssaultTrackerUI:SetHidden(true)
		
	end

end

EVENT_MANAGER:RegisterForEvent(PAT.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(PAT.name, EVENT_PLAYER_COMBAT_STATE,PAT_combatSwitch)

------------------- COMBAT / OUT OF COMBAT SWITCHING ---------------------



