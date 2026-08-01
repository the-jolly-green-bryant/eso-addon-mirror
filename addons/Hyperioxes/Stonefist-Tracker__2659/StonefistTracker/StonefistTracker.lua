SFTracker = {
    name            = "StonefistTracker",          
    author          = "Hyperioxes",
    color           = "DDFFEE",            
    menuName        = "StonefistTracker",          
}

local colorChange = 1


function generateUI()

	local WM = GetWindowManager()
	local STUI = WM:CreateTopLevelWindow("STUI")

    STUI:SetResizeToFitDescendents(true)
    STUI:SetMovable(true)
    STUI:SetMouseEnabled(true)
	STUI:SetHidden(true)
	

    STUI:SetHandler("OnMoveStop", function(control)
        savedVars.xOffset = STUI:GetLeft()
	    savedVars.yOffset  = STUI:GetTop()
    end)

	
	local StackCountBG = WM:CreateControl("$(parent)StackCountBG", STUI, CT_BACKDROP)
	StackCountBG:SetEdgeColor(0.4,0.4,0.4, 0)
	StackCountBG:SetCenterColor(0, 0, 0)
	StackCountBG:SetAnchor(TOPLEFT, STUI, TOPLEFT, 0, -64)
	StackCountBG:SetAlpha(0.8)
	StackCountBG:SetScale(1.0)
	StackCountBG:SetDrawLayer(0)

	StackCountBG:SetDimensions(savedVars.width +10, 60)
	StackCountBG:SetHidden(false)

	for i=0, 2 do
		circle = WM:CreateControl("$(parent)CircleOutline"..i,STUI,  CT_TEXTURE, 4)
		circle:SetDimensions(30, 30)
		circle:SetAnchor(BOTTOMLEFT,StackCountBG,BOTTOMLEFT,((savedVars.width+10)/3*i)+20,-5)
		circle:SetTexture([[/esoui/art/skillsadvisor/circle_passiveabilityframe_doubleframe.dds]])
		circle:SetHidden(false)
		circle:SetDrawLayer(1)
	end

	for i=0, 2 do
		circle = WM:CreateControl("$(parent)CircleInner"..i,STUI,  CT_TEXTURE, 4)
		circle:SetDimensions(30, 30)
		circle:SetAnchor(BOTTOMLEFT,StackCountBG,BOTTOMLEFT,((savedVars.width+10)/3*i)+20,-5)
		circle:SetTexture([[/art/fx/texture/flaresoftcircle.dds]])
		circle:SetColor(0,255,0,1)
		circle:SetHidden(false)
		circle:SetDrawLayer(2)
		circle:SetHidden(true)
	end

	stackTimerBar = WM:CreateControl("$(parent)StackTimerBar", STUI, CT_STATUSBAR)	
	stackTimerBar:SetScale(1.0)
	stackTimerBar:SetAnchor(TOPLEFT, StackCountBG, TOPLEFT, 5, 5)
	stackTimerBar:SetDimensions(math.floor(savedVars.width * ( 1 - 0.2)),10)
	stackTimerBar:SetColor(255, 0, 255, 1)
	stackTimerBar:SetHidden(false)		
	stackTimerBar:SetDrawLayer(1)

	stackTimerText = WM:CreateControl("$(parent)StackTimerText", STUI, CT_LABEL)			
	stackTimerText:SetFont("ZoFontGameSmall")
	stackTimerText:SetScale(1.0)
	stackTimerText:SetWrapMode(TEX_MODE_CLAMP)
	stackTimerText:SetDrawLayer(2)
	stackTimerText:SetColor(255,255,255, 1)
	stackTimerText:SetText("0.0s")				
	stackTimerText:SetAnchor(TOPLEFT, StackCountBG, TOPLEFT, 5, 0)
	stackTimerText:SetDimensions(savedVars.width, savedVars.height/2)
	stackTimerText:SetHorizontalAlignment(LEFT)
	stackTimerText:SetHidden(false)

	local STUIBackgroundTop = WM:CreateControl("$(parent)TOP", STUI, CT_BACKDROP)
	STUIBackgroundTop:SetEdgeColor(0.4,0.4,0.4, 0)
	STUIBackgroundTop:SetCenterColor(0, 0, 0)
	STUIBackgroundTop:SetAnchor(TOPLEFT, STUI, TOPLEFT, 0, 0)
	STUIBackgroundTop:SetAlpha(0.8)
	STUIBackgroundTop:SetScale(1.0)
	STUIBackgroundTop:SetDrawLayer(0)
	
	STUIBackgroundTop:SetDimensions(savedVars.width +10, 20)
	STUIBackgroundTop:SetHidden(false)
	
	local TopText = WM:CreateControl("$(parent)TOP_TEXT", STUI, CT_LABEL)
	TopText:SetFont("ZoFontGameSmall")
	TopText:SetScale(1.0)

	TopText:SetDrawLayer(1)
	TopText:SetColor(255, 255, 255, 1)
	TopText:SetText("Stonefist Tracker")				 
	TopText:SetAnchor(CENTER, STUIBackgroundTop,CENTER, 50, 0)
	TopText:SetDimensions(savedVars.width, 20)
    TopText:SetHorizontalAlignment(CENTER)
	TopText:SetHidden(false)

	
    
		

    
	local gapBetweenBosses = 24
	

	for i = 1, MAX_BOSSES do

        STUIBackground = WM:CreateControl("$(parent)Background"..i, STUI, CT_BACKDROP)
		STUIBackground:SetEdgeColor(0,0,0, 0.2)
		STUIBackground:SetCenterColor(0, 0, 0)
		STUIBackground:SetAnchor(TOPLEFT, STUI, TOPLEFT, 0, gapBetweenBosses)
		STUIBackground:SetAlpha(0.8)
		STUIBackground:SetScale(1.0)
		STUIBackground:SetDrawLayer(0)
		STUIBackground:SetDimensions(savedVars.width + 10, savedVars.height)
		STUIBackground:SetHidden(false)



		

        gapBetweenBosses=gapBetweenBosses+40

        STUIText = WM:CreateControl("$(parent)Text"..i,STUI,CT_LABEL)
        STUIText:SetFont("ZoFontGameSmall")
	    STUIText:SetScale(1.0)
	    STUIText:SetWrapMode(TEX_MODE_CLAMP)
	    STUIText:SetDrawLayer(1)
	    STUIText:SetColor(255, 255, 255, 1)
	    STUIText:SetText("Boss name")				
	    STUIText:SetAnchor(TOPCENTER, STUIBackground, TOPCENTER, 45, 0)
	    STUIText:SetDimensions(savedVars.width, 20)
	    STUIText:SetHorizontalAlignment(CENTER)
	    STUIText:SetHidden(false)
		
	


		local gapBetweenElements = 20


			timer = WM:CreateControl("$(parent)DurationTimer"..i, STUI, CT_LABEL)			
			timer:SetFont("ZoFontGameSmall")
			timer:SetScale(1.0)
			timer:SetWrapMode(TEX_MODE_CLAMP)
			timer:SetDrawLayer(2)
			timer:SetColor(255,255,255, 1)
			timer:SetText("0.0s")				
			timer:SetAnchor(TOPLEFT, STUIBackground, TOPLEFT, 5, gapBetweenElements)
			timer:SetDimensions(savedVars.width, savedVars.height/2)
			timer:SetHorizontalAlignment(LEFT)
			timer:SetHidden(false)
			

			bar = WM:CreateControl("$(parent)DurationBar"..i, STUI, CT_STATUSBAR)	
			bar:SetScale(1.0)
			bar:SetAnchor(TOPLEFT, STUIBackground, TOPLEFT, 5, gapBetweenElements-2)
			bar:SetDimensions(math.floor(savedVars.width * ( 1 - 0.2)), savedVars.height/2)
			bar:SetColor(255, 0, 0, 0.50)
			bar:SetHidden(false)		
			bar:SetDrawLayer(1)

			

			arrow = WM:CreateControl("$(parent)Arrow"..i,STUI,  CT_TEXTURE, 4)
			arrow:SetDimensions(25, 25)
			arrow:SetAnchor(RIGHT,STUIBackground,RIGHT,30,0)
			arrow:SetTexture([[/esoui/art/unitattributevisualizer/attributebar_arrow.dds]])
			arrow:SetHidden(true)


			
			gapBetweenElements = gapBetweenElements + savedVars.height/2


	end

    STUI:ClearAnchors()
	STUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,savedVars.xOffset,savedVars.yOffset)	

end



SLASH_COMMANDS["/stonefisttracker"] = function()
    STUI:SetHidden(false)
end











local function GetBossInfo(number)
    for i=1, GetNumBuffs("boss"..number) do
        local _, _, timeEnding, _, stacks, _, _, _, _, _, abilityId, _, _ = GetUnitBuffInfo("boss"..number, i)
        if abilityId == 134336 then

            return (timeEnding-GetGameTimeSeconds()),GetUnitName("boss"..number),stacks
        end
    end
    return 0,GetUnitName("boss"..number),0
end


local function GetPlayerStacks()
	for i=1,GetNumBuffs("player") do
		local _, _, timeEnding, _, stacks, _, _, _, _, _, abilityId, _, _ = GetUnitBuffInfo("player",i)
        if abilityId == 31816 then
			
            return (timeEnding-GetGameTimeSeconds()),stacks
        end
    end
    return 0,0
end



function UpdateDuration()


	local ownStacksTimerBar = STUI:GetNamedChild("StackTimerBar")
	local ownStacksTimerText = STUI:GetNamedChild("StackTimerText")
	local circle1 = STUI:GetNamedChild("CircleInner0")
	local circle2 = STUI:GetNamedChild("CircleInner1")
	local circle3 = STUI:GetNamedChild("CircleInner2")
	for i=1,MAX_BOSSES do
		local background = STUI:GetNamedChild("Background"..i)
		local durationTimer = STUI:GetNamedChild("DurationTimer"..i)
		local bossname = STUI:GetNamedChild("Text"..i)
		local bossbar = STUI:GetNamedChild("DurationBar"..i)
		local arrow = STUI:GetNamedChild("Arrow"..i)
		
		if DoesUnitExist("boss"..i) then
			background:SetHidden(false)
			durationTimer:SetHidden(false)
			bossname:SetHidden(false)
			bossbar:SetHidden(false)
		else
			background:SetHidden(true)
			durationTimer:SetHidden(true)
			bossname:SetHidden(true)
			bossbar:SetHidden(true)
		end
		if GetUnitName("boss"..i) == GetUnitName("reticleover") and DoesUnitExist("boss"..i) then
			arrow:SetHidden(false)
		else
			arrow:SetHidden(true)
		end

		

		local remainingTime,bossName,stacks = GetBossInfo(i)
		local ownRemainingTime,ownStacks = GetPlayerStacks()



		durationTimer:SetText((math.floor(remainingTime*10)/10).."s")
		bossname:SetText(bossName)
		ownStacksTimerText:SetText((math.floor(ownRemainingTime*10)/10).."s")

		if ownRemainingTime ~= 0 then
			ownStacksTimerBar:SetColor(255,0,255,1)
			ownStacksTimerBar:SetDimensions(math.floor(savedVars.width * ( 1 - 0.2))*(ownRemainingTime/12),10)
		else
			ownStacksTimerBar:SetColor(255,0,255,0.1)
			ownStacksTimerBar:SetDimensions(math.floor(savedVars.width * ( 1 - 0.2)),10)

		end

		if ownStacks == 3 then
			circle3:SetHidden(false)
		else
			circle3:SetHidden(true)
		end

		if ownStacks >= 2 then
			circle2:SetHidden(false)
		else
			circle2:SetHidden(true)
		end

		if ownStacks >= 1 then
			circle1:SetHidden(false)
		else
			circle1:SetHidden(true)
		end


		if remainingTime ~= 0 then
			bossbar:SetDimensions(math.floor(savedVars.width * ( 1 - 0.2))*(remainingTime/6),savedVars.height/2)
		
			if stacks == 3 then
				bossbar:SetColor(0, 255, 0)

			elseif stacks == 2 then
				bossbar:SetColor(255, 255, 0)

			else
				bossbar:SetColor(255, 0, 0)

			end
		end



		colorChange = colorChange+1

		if colorChange > 30 then
			colorChange = 0
		end
		if remainingTime == 0 then
			if colorChange<15 then
				bossbar:SetColor(255,0,0,0.6)
			end
			if colorChange>15 then
				bossbar:SetColor(255,0,0,0.4)
			end
			bossbar:SetDimensions(math.floor(savedVars.width * ( 1 - 0.2)),savedVars.height/2)
		end
	end
end






function OnAddOnLoaded(event, addonName)
    if addonName ~= SFTracker.name then return end
    EVENT_MANAGER:UnregisterForEvent(SFTracker.name, EVENT_ADD_ON_LOADED)
    


	local default = {
		xOffset = 200,
		yOffset = 200,
		width=200,
		height=40,

	}
	savedVars = ZO_SavedVars:NewAccountWide("StonefistTrackerSV", 1, nil, default)
	generateUI()

   -- SFTracker.LoadSettings() -- add settings later


end

EVENT_MANAGER:RegisterForEvent(SFTracker.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
--EVENT_MANAGER:RegisterForEvent(SFTracker.name, EVENT_PLAYER_COMBAT_STATE, function() --to do later: add option to only register for update in combat
	--if IsUnitInCombat("player") then
			--EVENT_MANAGER:RegisterForUpdate(SFTracker.name, 500, function() UpdateDuration() end)
		--	STUI:SetHidden(false)
	--	else
			--EVENT_MANAGER:UnregisterForUpdate(SFTracker.name, 500)
		--	STUI:SetHidden(true)
	--	end
--end)
EVENT_MANAGER:RegisterForUpdate(SFTracker.name, 50, UpdateDuration )
