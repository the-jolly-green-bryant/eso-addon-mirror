YT = {
    name            = "YandirTracker",          
    author          = "Hyperioxes",
    color           = "DDFFEE",            
    menuName        = "YandirTracker",          
}


local yandirStacks = 0
local currentlyPreviewing = false
local currentScene


local function ToggleUI(_, newState)
  if newState == SCENE_SHOWN then

	YandirTrackerUI:SetHidden(false)

  elseif newState == SCENE_HIDDEN then

	YandirTrackerUI:SetHidden(true)

  end
end

local function getCurrentScene(_,newState)
	currentScene = newState
end




local function GetPlayerStacks(searchedID)
	for i=1,GetNumBuffs("player") do
		local _, _, timeEnding, _, stacks, _, _, _, _, _, abilityId, _, _ = GetUnitBuffInfo("player",i)
        if abilityId == searchedID then
			
            return (timeEnding-GetGameTimeSeconds()),stacks
        end
    end
    return 0,0
end


local function checkIfYandirEquipped()
	local itemSet = "|H0:item:162118:362:50:0:0:0:0:0:0:0:0:0:0:0:2048:102:0:0:0:10000:0|h|h"
	local numOfItems = 0
	local perfectedNumOfItems= 0
	local setName, maxEquipped
	_, setName, _, numOfItems, maxEquipped,_,perfectedNumOfItems = GetItemLinkSetInfo(itemSet, true) --This function instantly gets number of pieces worn but it ignores offbar
	numOfItems = numOfItems + perfectedNumOfItems

	--Check other bar's gear and add them if the set matches
	local additonalBarToCheck = { EQUIP_SLOT_BACKUP_MAIN, EQUIP_SLOT_BACKUP_OFF } --By default check backbar
	if GetActiveWeaponPairInfo() == ACTIVE_WEAPON_PAIR_BACKUP then
		--If currently on backbar, check frontbar instead
		additonalBarToCheck = { EQUIP_SLOT_MAIN_HAND, EQUIP_SLOT_OFF_HAND }
	end
	for _, v in pairs(additonalBarToCheck) do
		local currentlyCheckedItemSetName
		local incrementBy = 1
		_, currentlyCheckedItemSetName = GetItemLinkSetInfo(GetItemLink(BAG_WORN, v), true)
		if GetItemEquipType(BAG_WORN, additonalBarToCheck[1]) == EQUIP_TYPE_TWO_HAND then
			incrementBy = 2
		end --If item is a two-handed weapon count it twice
		if currentlyCheckedItemSetName == setName then
			numOfItems = numOfItems + incrementBy
		end
	end
	if numOfItems >= maxEquipped then
		return true
	end
end

local function checkIfNonpYandirEquipped()
	local itemSet = "|H1:item:162658:364:50:0:0:0:18:0:0:0:0:0:0:0:2049:102:0:1:0:1067:0|h|h"
	local numOfItems = 0
	local perfectedNumOfItems= 0
	local setName, maxEquipped
	_, setName, _, numOfItems, maxEquipped,_,perfectedNumOfItems = GetItemLinkSetInfo(itemSet, true) --This function instantly gets number of pieces worn but it ignores offbar
	numOfItems = numOfItems + perfectedNumOfItems

	--Check other bar's gear and add them if the set matches
	local additonalBarToCheck = { EQUIP_SLOT_BACKUP_MAIN, EQUIP_SLOT_BACKUP_OFF } --By default check backbar
	if GetActiveWeaponPairInfo() == ACTIVE_WEAPON_PAIR_BACKUP then
		--If currently on backbar, check frontbar instead
		additonalBarToCheck = { EQUIP_SLOT_MAIN_HAND, EQUIP_SLOT_OFF_HAND }
	end
	for _, v in pairs(additonalBarToCheck) do
		local currentlyCheckedItemSetName
		local incrementBy = 1
		_, currentlyCheckedItemSetName = GetItemLinkSetInfo(GetItemLink(BAG_WORN, v), true)
		if GetItemEquipType(BAG_WORN, additonalBarToCheck[1]) == EQUIP_TYPE_TWO_HAND then
			incrementBy = 2
		end --If item is a two-handed weapon count it twice
		if currentlyCheckedItemSetName == setName then
			numOfItems = numOfItems + incrementBy
		end
	end
	if numOfItems >= maxEquipped then
		return true
	end
end





function YT_showUI()
	if YandirTrackerUI:IsHidden() then
		currentlyPreviewing = true
		YandirTrackerUI:SetHidden(false)
		for i=0,9 do
            local circle = YandirTrackerUI:GetNamedChild("CircleInner"..i)
            circle:SetHidden(false)
        end
		local timerBar = YandirTrackerUI:GetNamedChild("StackTimerBar")
		timerBar:SetHidden(false)
		timerBar:SetDimensions(175,10)
	else
		currentlyPreviewing = false
		YandirTrackerUI:SetHidden(true)
	end

end



------------------ FUNCTIONS -------------------


-->>>>>>>>>>>>>>>>>>>>>>>>> INITIALIZE UI <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<--


local function generateUI()

	WM = GetWindowManager()

	local YandirTrackerUI = WM:CreateTopLevelWindow("YandirTrackerUI")



	YandirTrackerUI:SetResizeToFitDescendents(true)
    YandirTrackerUI:SetMovable(true)
    YandirTrackerUI:SetMouseEnabled(true)
	YandirTrackerUI:SetHidden(true)


	YandirTrackerUI:SetHandler("OnMoveStop", function(control)
        YTsavedVars.xOffsetOwnStacks = YandirTrackerUI:GetLeft()
	    YTsavedVars.yOffsetOwnStacks  = YandirTrackerUI:GetTop()
    end)








		
			local StackCountBG = WM:CreateControl("$(parent)StackCountBG", YandirTrackerUI, CT_TEXTURE)
			StackCountBG:SetColor(YTsavedVars.backgroundColor[1],YTsavedVars.backgroundColor[2],YTsavedVars.backgroundColor[3],YTsavedVars.backgroundColor[4])
			StackCountBG:SetAnchor(TOPLEFT, YandirTrackerUI, TOPLEFT, 0, 0)
			StackCountBG:SetDrawLayer(0)
			StackCountBG:SetDimensions(280, 100)
			StackCountBG:SetHidden(false)

			x = 0
			height = -45
			for i=0, 9 do
				local circle = WM:CreateControl("$(parent)CircleBackground"..i,YandirTrackerUI,  CT_TEXTURE, 4)
				circle:SetDimensions(30, 30)
				circle:SetAnchor(BOTTOMLEFT,StackCountBG,BOTTOMLEFT,10+(40*x),height)
				circle:SetTexture([[/esoui/art/dye/gamepad/dye_circle.dds]])
				circle:SetHidden(false)
				circle:SetDrawLayer(1)
				circle:SetColor(0,0,0,1)
				

				local circleOutline = WM:CreateControl("$(parent)CircleOutline"..i,YandirTrackerUI,  CT_TEXTURE, 4)
				circleOutline:SetDimensions(30, 30)
				circleOutline:SetAnchor(BOTTOMLEFT,StackCountBG,BOTTOMLEFT,10+(40*x),height)
				circleOutline:SetTexture([[/esoui/art/skillsadvisor/circle_passiveabilityframe_doubleframe.dds]])
				circleOutline:SetHidden(false)
				circleOutline:SetDrawLayer(3)



				local circleInner = WM:CreateControl("$(parent)CircleInner"..i,YandirTrackerUI,  CT_TEXTURE, 4)
				circleInner:SetDimensions(30, 30)
				circleInner:SetAnchor(BOTTOMLEFT,StackCountBG,BOTTOMLEFT,10+(40*x),height)
				circleInner:SetTexture([[/art/fx/texture/flaresoftcircle.dds]])
				circleInner:SetHidden(false)
				circleInner:SetDrawLayer(2)
				circleInner:SetColor(YTsavedVars.orbColor[1],YTsavedVars.orbColor[2],YTsavedVars.orbColor[3],YTsavedVars.orbColor[4])
				x=x+1
				if i==4 then
					x=0
					height = -10
				end
			end

			local stackTimerBarOutline = WM:CreateControl("$(parent)StackTimerBarTexture", YandirTrackerUI, CT_TEXTURE)
			stackTimerBarOutline:SetDimensions(4+175,12)
			stackTimerBarOutline:SetAnchor(TOPCENTER,StackCountBG,TOPCENTER,10,5)
			stackTimerBarOutline:SetTexture("/esoui/art/ava/ava_resourcestatus_progbar_achieved_overlay.dds")
			stackTimerBarOutline:SetHidden(false)
			stackTimerBarOutline:SetDrawLayer(2)

			local stackTimerBarBackground = WM:CreateControl("$(parent)stackTimerBarBackground", YandirTrackerUI, CT_STATUSBAR)	
			stackTimerBarBackground:SetScale(1.0)
			stackTimerBarBackground:SetAnchor(LEFT, stackTimerBarOutline, LEFT, 0, 0)
			stackTimerBarBackground:SetDimensions(175,10)
			stackTimerBarBackground:SetColor(0,0,0,1)
			stackTimerBarBackground:SetHidden(false)		
			stackTimerBarBackground:SetDrawLayer(1)

			local stackTimerBar = WM:CreateControl("$(parent)StackTimerBar", YandirTrackerUI, CT_STATUSBAR)	
			stackTimerBar:SetScale(1.0)
			stackTimerBar:SetAnchor(LEFT, stackTimerBarOutline, LEFT,0, 0)
			stackTimerBar:SetDimensions(175,10)
			stackTimerBar:SetColor(YTsavedVars.barColor[1],YTsavedVars.barColor[2],YTsavedVars.barColor[3],YTsavedVars.barColor[4])
			stackTimerBar:SetHidden(false)		
			stackTimerBar:SetDrawLayer(2)

	

			local stackTimerText = WM:CreateControl("$(parent)StackTimerText", YandirTrackerUI, CT_LABEL)			
			stackTimerText:SetFont("ZoFontGameSmall")
			stackTimerText:SetScale(1.0)
			stackTimerText:SetWrapMode(TEX_MODE_CLAMP)
			stackTimerText:SetDrawLayer(3)
			stackTimerText:SetColor(255,255,255, 1)
			stackTimerText:SetText("0.0s")				
			stackTimerText:SetAnchor(TOPLEFT, StackCountBG, TOPLEFT, 178, 2)
			stackTimerText:SetDimensions(40, 40)
			stackTimerText:SetHorizontalAlignment(LEFT)
			stackTimerText:SetHidden(false)

			local bonusText = WM:CreateControl("$(parent)bonusText", YandirTrackerUI, CT_LABEL)			
			bonusText:SetFont("ZoFontWindowTitle")
			bonusText:SetScale(1.0)
			bonusText:SetWrapMode(TEX_MODE_CLAMP)
			bonusText:SetDrawLayer(3)
			bonusText:SetColor(YTsavedVars.weaponDamageColor[1],YTsavedVars.weaponDamageColor[2],YTsavedVars.weaponDamageColor[3],YTsavedVars.weaponDamageColor[4])
			bonusText:SetText("WD")				
			bonusText:SetAnchor(BOTTOMLEFT, StackCountBG, BOTTOMLEFT, 220, 30)
			bonusText:SetDimensions(80, 80)
			bonusText:SetHorizontalAlignment(RIGHT)
			bonusText:SetHidden(false)







	
	YandirTrackerUI:ClearAnchors()
	YandirTrackerUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,YTsavedVars.xOffsetOwnStacks,YTsavedVars.yOffsetOwnStacks)	

end

-->>>>>>>>>>>>>>>>>>>>>>>>> INITIALIZE UI <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<--









-->>>>>>>>>>>>>>>>>>>>>>>>> UPDATE UI <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<--

local function UpdateDuration()








			if not currentlyPreviewing then

				local ownStacksTimerBar = YandirTrackerUI:GetNamedChild("StackTimerBar")
				local ownStacksTimerText = YandirTrackerUI:GetNamedChild("StackTimerText")
				for i=0, 9 do
					_G["circle"..i] = YandirTrackerUI:GetNamedChild("CircleInner"..i)
				end
				local yandirBonus = YandirTrackerUI:GetNamedChild("bonusText")
				local ownRemainingTime, ownStacks = GetPlayerStacks(135950) -- endurance non perfected
				local isMight = false
				if ownStacks == 0 then
					ownRemainingTime, ownStacks = GetPlayerStacks(135951) -- might non perfected
					isMight = true
				end
				if ownRemainingTime < 0 then
					ownRemainingTime = 0
				end
				ownStacksTimerText:SetText((math.floor(ownRemainingTime*10)/10).."s")
				if isMight then
					ownStacksTimerBar:SetDimensions(175*(ownRemainingTime/15),10)
					if yandirStacks == 0 then
						yandirStacks = 1
					end
					yandirBonus:SetText(63*yandirStacks)
				else
					ownStacksTimerBar:SetDimensions(175*(ownRemainingTime/5),10)
					yandirBonus:SetText(41*ownStacks)
					yandirStacks=ownStacks
				end
				if ownRemainingTime == 0 then
					yandirBonus:SetText(0)
				end

				for i=0,9 do
					if ownStacks > i then
						_G["circle"..i]:SetHidden(false)
					else
						_G["circle"..i]:SetHidden(true)
					end
				end
			end



















end

-->>>>>>>>>>>>>>>>>>>>>>>>> UPDATE UI <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<--




------------------- INITIALIZE --------------------------


function OnAddOnLoaded(event, addonName)
    if addonName ~= YT.name then return end
    EVENT_MANAGER:UnregisterForEvent(YT.name, EVENT_ADD_ON_LOADED)

	

	local default = {
		

		xOffsetOwnStacks = 200,
		yOffsetOwnStacks = 200,
		orbColor = {1,1,1,1},
		barColor = {1,1,1,1},
		weaponDamageColor = {1,1,1,1},
		backgroundColor = {0,0,0,1},
		onlyTrackWhenWearing = true,
		showOnlyInCombat = true,



	}
	YTsavedVars = ZO_SavedVars:NewAccountWide("YandirTrackerSV",3, nil, default)
	generateUI()








	YT_LoadSettings()
	YT_UISwitch()
	EVENT_MANAGER:RegisterForEvent(YT.name, EVENT_PLAYER_COMBAT_STATE,YT_UISwitch)
	EVENT_MANAGER:RegisterForEvent(YT.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE,YT_UISwitch)
	SCENE_MANAGER:GetScene("hud"):RegisterCallback("StateChange", getCurrentScene)
	SCENE_MANAGER:GetScene("hudui"):RegisterCallback("StateChange", getCurrentScene)



end

------------------- INITIALIZE --------------------------


------------------- COMBAT / OUT OF COMBAT SWITCHING ---------------------
function YT_UISwitch()
	if (IsUnitInCombat("player") or not YTsavedVars.showOnlyInCombat) and (checkIfYandirEquipped() or checkIfNonpYandirEquipped() or not YTsavedVars.onlyTrackWhenWearing) then	
		SCENE_MANAGER:GetScene("hud"):RegisterCallback("StateChange", ToggleUI )
		SCENE_MANAGER:GetScene("hudui"):RegisterCallback("StateChange", ToggleUI)
		EVENT_MANAGER:RegisterForUpdate(YT.name, 100,UpdateDuration)

		if currentScene == SCENE_SHOWN then
			YandirTrackerUI:SetHidden(false)
		end
	else
		SCENE_MANAGER:GetScene("hud"):UnregisterCallback("StateChange",ToggleUI)
		SCENE_MANAGER:GetScene("hudui"):UnregisterCallback("StateChange",ToggleUI)
		EVENT_MANAGER:UnregisterForUpdate(YT.name, 100)
		
		YandirTrackerUI:SetHidden(true)
		
	end
end
EVENT_MANAGER:RegisterForEvent(YT.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
------------------- COMBAT / OUT OF COMBAT SWITCHING ---------------------



