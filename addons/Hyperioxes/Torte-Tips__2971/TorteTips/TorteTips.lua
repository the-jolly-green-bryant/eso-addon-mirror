TT = {
    name            = "TorteTips",          
    author          = "Hyperioxes",
    color           = "DDFFEE",            
    menuName        = "TorteTips",          
}

local function isZonePvP()
	if IsPlayerInAvAWorld() or IsActiveWorldBattleground() then return true end
	return false
end


local function InitializeUI()
	local WM = GetWindowManager()
	local TorteTipsUI = WM:CreateTopLevelWindow("TorteTipsUI")
	TorteTipsUI:SetResizeToFitDescendents(true)
    TorteTipsUI:SetMovable(true)
    TorteTipsUI:SetMouseEnabled(true)
	TorteTipsUI:SetHidden(true)
	local Rwidth, Rheight = GuiRoot:GetDimensions()

	--[[TorteTipsUI:SetHandler("OnMoveStop", function(control)
        TTsavedVars.xOffset = TorteTipsUI:GetLeft()
	    TTsavedVars.yOffset  = TorteTipsUI:GetTop()
    end)]]

	local TorteText = WM:CreateControl("$(parent)TorteText", TorteTipsUI, CT_LABEL)
	TorteText:SetFont("ZoFontCallout2")
	TorteText:SetScale(1.0)
	TorteText:SetWrapMode(TEX_MODE_CLAMP)
	TorteText:SetColor(255,255,255, 1)
	TorteText:SetText("Torte expires in 0:00")				
	TorteText:SetAnchor(TOPLEFT, TorteTipsUI, TOPLEFT,0,0)
	TorteText:SetDimensions(450, 100)
	TorteText:SetHorizontalAlignment(1)
	TorteText:SetVerticalAlignment(1)
	TorteText:SetHidden(false)

	local TorteIcon = WM:CreateControl("$(parent)TorteIcon",TorteTipsUI,  CT_TEXTURE, 4)
	TorteIcon:SetDimensions(128,128)
	TorteIcon:SetAnchor(RIGHT,TorteText,LEFT,0,0)
	TorteIcon:SetTexture("esoui/art/icons/ava_skill_boost_food_002.dds")
	TorteIcon:SetHidden(false)
	TorteIcon:SetDrawLayer(1)

	TorteTipsUI:ClearAnchors()
	TorteTipsUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,(Rwidth/2)-161,Rheight/5.24)
end


local function GetUnitInfo(ability,target)
	for _,v in pairs(ability) do
		for i=1, GetNumBuffs(target) do
			_, _, timeEnding, _, stacks, _, _, _, _, _, abilityId, _, _ = GetUnitBuffInfo(target, i)
			if abilityId == v then

				return (timeEnding-GetGameTimeSeconds()),stacks,true,abilityId
			end
		end
	end
	return 0,0,false,0
end




local function SendAlert(time,staysFor)
	if isZonePvP() then
		TorteTipsUI:SetHidden(false)
		PlaySound(SOUNDS.DUEL_START)
		local text = TorteTipsUI:GetNamedChild("TorteText")
		local minutes = math.floor(time/60)
		local seconds = math.floor(time%60)
		if seconds<10 then
			seconds = "0"..seconds
		end
		if time ~= 0 then
			text:SetText("Torte expires in "..minutes..":"..seconds)
		else
			text:SetText("Torte has expired")
		end
		EVENT_MANAGER:RegisterForUpdate("RegisterForHide", staysFor,function()
			TorteTipsUI:SetHidden(true)
			EVENT_MANAGER:UnregisterForUpdate("RegisterForHide", staysFor)
		end)
	end
end

local function UpdateEveryMinute()
	local remainingTime = GetUnitInfo({147687,147733,147734},"player")
	if remainingTime < 300 then
		SendAlert(remainingTime,5000)
	end

end




function OnAddOnLoaded(event, addonName)
    if addonName ~= TT.name then return end
    EVENT_MANAGER:UnregisterForEvent(TT.name, EVENT_ADD_ON_LOADED)

	

	local default = {
		

		



	}
	TTsavedVars = ZO_SavedVars:NewAccountWide("TorteTipsSV",1, nil, default)



	InitializeUI()
	local remainingTime = GetUnitInfo({147687,147733,147734},"player")
	if remainingTime < 300 then -- on startup, if torte buff is shorter than 5 minutes
		zo_callLater(function () SendAlert(remainingTime,10000) end, 5000) -- when game loads in wait 5 seconds then show alert for 10 seconds
	end
	if remainingTime ~= 0 then -- if torte is active
		EVENT_MANAGER:RegisterForUpdate("TTUpdate", 60000,UpdateEveryMinute) -- check torte's duration every minute
	end

	-- 50% TORTE
	EVENT_MANAGER:RegisterForEvent("TorteEffect",EVENT_EFFECT_CHANGED, function(_,_,_,_,_,_,expireTime) -- event that gets called when torte starts or expires
	if expireTime==0 then -- if torte expires
		SendAlert(0,30000) -- show alert for 30 seconds
		EVENT_MANAGER:UnregisterForUpdate("TTUpdate", 60000) -- stop checking torte every minute
	else -- if torte starts
		TorteTipsUI:SetHidden(true)
		EVENT_MANAGER:RegisterForUpdate("TTUpdate", 60000,UpdateEveryMinute) -- start checking torte every minute
	end
	end)
	EVENT_MANAGER:AddFilterForEvent("TorteEffect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID,147687)
	EVENT_MANAGER:AddFilterForEvent("TorteEffect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE ,1)


	-- 100% TORTE
	EVENT_MANAGER:RegisterForEvent("TorteEffect2",EVENT_EFFECT_CHANGED, function(_,_,_,_,_,_,expireTime) -- event that gets called when torte starts or expires
	if expireTime==0 then -- if torte expires
		SendAlert(0,30000) -- show alert for 30 seconds
		EVENT_MANAGER:UnregisterForUpdate("TTUpdate", 60000) -- stop checking torte every minute
	else -- if torte starts
		TorteTipsUI:SetHidden(true)
		EVENT_MANAGER:RegisterForUpdate("TTUpdate", 60000,UpdateEveryMinute) -- start checking torte every minute
	end
	end)
	EVENT_MANAGER:AddFilterForEvent("TorteEffect2", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID,147733)
	EVENT_MANAGER:AddFilterForEvent("TorteEffect2", EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE ,1)




	-- 150% TORTE
	EVENT_MANAGER:RegisterForEvent("TorteEffect3",EVENT_EFFECT_CHANGED, function(_,_,_,_,_,_,expireTime) -- event that gets called when torte starts or expires
	if expireTime==0 then -- if torte expires
		SendAlert(0,30000) -- show alert for 30 seconds
		EVENT_MANAGER:UnregisterForUpdate("TTUpdate", 60000) -- stop checking torte every minute
	else -- if torte starts
		TorteTipsUI:SetHidden(true)
		EVENT_MANAGER:RegisterForUpdate("TTUpdate", 60000,UpdateEveryMinute) -- start checking torte every minute
	end
	end)
	EVENT_MANAGER:AddFilterForEvent("TorteEffect3", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID,147734)
	EVENT_MANAGER:AddFilterForEvent("TorteEffect3", EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE ,1)





end
EVENT_MANAGER:RegisterForEvent(TT.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", function() -- on map change
	local remainingTime = GetUnitInfo({147687,147733,147734},"player")
	remainingTime = 450
	if remainingTime < 600 then -- if torte buff is shorter than 10 minutes
		zo_callLater(function () SendAlert(remainingTime,15000) end, 5000) -- when game loads in wait 5 seconds then show alert for 10 seconds
	end
end)