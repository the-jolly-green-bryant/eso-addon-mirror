-----------------
---- Globals ----
-----------------
DebuffMe = DebuffMe or {}
local DebuffMe = DebuffMe

DebuffMe.name = "DebuffMe"
DebuffMe.version = "1.7.1"

DebuffMe.flag_immunity = false
DebuffMe.altarEndTime = 0
DebuffMe.CustomDataList = {
	name = {},
	id = {},
	abbreviation = {},
}
---------------------------
---- Variables Default ----
---------------------------
DebuffMe.Default = {
	OffsetX = 0,
	OffsetY = 0,
	Debuff_Show = {	[1] = 2,
					[2] = 4,
					[3] = 3,
					[4] = 5},
    AlwaysShowAlert = false,
	FontSize = 36,
	Spacing = 10,
	SlowMode = false,
	CustomDataList = {
		name = {},
		id = {},
		abbreviation = {},
	},
	thresholdHP = 1,
}

------------------
---- FONCTION ----
------------------
local function GetFormattedAbilityNameWithID(id)	--Fix to LUI extended conflict thank you Solinur and Wheels
	local name = DebuffMe.CustomAbilityNameWithID[id] or zo_strformat(SI_ABILITY_NAME, GetAbilityName(id))
	return name
end 

function DebuffMe.DoesDebuffEquals(ID1, ID2)
	if GetFormattedAbilityNameWithID(ID1) == GetFormattedAbilityNameWithID(ID2) then 
		return true
	else
		return false
	end
end

function DebuffMe.Calcul(index)
	local Debuff_Choice = DebuffMe.Debuff_Show[index]
	local currentTimeStamp = GetGameTimeMilliseconds() / 1000
	DebuffID = tonumber(DebuffMe.TransitionTable[Debuff_Choice])

    local Timer = 0
	DebuffMe.flag_immunity = false
	
	for i=1, GetNumBuffs("reticleover") do --check all debuffs
		local _, _, timeEnding, _, _, _, _, _, _, _, abilityId, _, castByPlayer = GetUnitBuffInfo("reticleover",i)		
		
		if Debuff_Choice == 2 then --if taunt
			if castByPlayer == true then
				if DebuffMe.DoesDebuffEquals(abilityId, DebuffID) then 
					Timer = timeEnding - currentTimeStamp
				end
			end
		else
			if DebuffMe.DoesDebuffEquals(abilityId, DebuffID) then
				if Timer <= timeEnding - currentTimeStamp then --ignore conflict when more than one player is applying the same debuff
					Timer = timeEnding - currentTimeStamp
				end
			end
		end
	end

	--------------------
	-- SPECIAL TIMERS --
	--------------------
		----------------
		-- IMMUNITIES --
		----------------
	if Timer <= 0 and Debuff_Choice == 2 then --check target taunt immunity 
		for i=1,GetNumBuffs("reticleover") do 
			local _, _, timeEnding, _, _, _, _, _, _, _, abilityId, _, _ = GetUnitBuffInfo("reticleover",i)
			if DebuffMe.DoesDebuffEquals(abilityId, 52788) then 
				Timer = timeEnding - currentTimeStamp
				DebuffMe.flag_immunity = true
			end
		end
	end
	if Timer <= 0 and Debuff_Choice == 6 then --check target offbalance immunity 
		for i=1,GetNumBuffs("reticleover") do 
			local _, _, timeEnding, _, _, _, _, _, _, _, abilityId, _, _ = GetUnitBuffInfo("reticleover",i)
			if DebuffMe.DoesDebuffEquals(abilityId, 134599) then 
				Timer = timeEnding - currentTimeStamp
				DebuffMe.flag_immunity = true
			end
		end
	end
	if Timer <= 0 and Debuff_Choice == 16 then --check target major vulnerability immunity
		for i=1,GetNumBuffs("reticleover") do 
			local _, _, timeEnding, _, _, _, _, _, _, _, abilityId, _, _ = GetUnitBuffInfo("reticleover",i)
			if DebuffMe.DoesDebuffEquals(abilityId, 132831) then
				Timer = timeEnding - currentTimeStamp
				DebuffMe.flag_immunity = true
			end
		end
	end
		-------------------
		-- VULNERABILITY --
		-------------------
	if Timer <= 4 and Debuff_Choice == 7 then --check minor vulnerability from shock
		for i=1,GetNumBuffs("reticleover") do 
			local _, _, timeEnding, _, _, _, _, _, _, _, abilityId, _, _ = GetUnitBuffInfo("reticleover",i)
			if DebuffMe.DoesDebuffEquals(abilityId, 68359) then 
				Timer = timeEnding - currentTimeStamp
			end
		end
	end
	if Timer <= 8 and Debuff_Choice == 7 then --check minor vulnerability from nb gap closer
		for i=1,GetNumBuffs("reticleover") do 
			local _, _, timeEnding, _, _, _, _, _, _, _, abilityId, _, _ = GetUnitBuffInfo("reticleover",i)
			if DebuffMe.DoesDebuffEquals(abilityId, 124806) then 
				if Timer <= timeEnding - currentTimeStamp then
					Timer = timeEnding - currentTimeStamp
				end
			end
		end
	end
	if Timer <= 4 and Debuff_Choice == 8 then --check minor main from chilled
		for i=1,GetNumBuffs("reticleover") do 
			local _, _, timeEnding, _, _, _, _, _, _, _, abilityId, _, _ = GetUnitBuffInfo("reticleover",i)
			if DebuffMe.DoesDebuffEquals(abilityId, 68368) then 
				Timer = timeEnding - currentTimeStamp
			end
		end
	end	
		---------------------
		-- MINOR LIFESTEAL --
		---------------------
	if Debuff_Choice == 10 and Timer <= DebuffMe.altarEndTime - currentTimeStamp then --check minor lifesteal from altar
		for i=1,GetNumBuffs("reticleover") do 
			local _, _, _, _, _, _, _, _, _, _, abilityId, _, _ = GetUnitBuffInfo("reticleover",i)
			if DebuffMe.DoesDebuffEquals(abilityId, 80020) then --altar
				Timer = DebuffMe.altarEndTime - currentTimeStamp
			end
		end
	end	

	---------------------
	-- CONVERT TO TEXT --
	---------------------
	local TimerTXT = ""

    if Timer <= 0 then 
        if index == 1 then --no abbreviation if main debuff
            TimerTXT = "0"
        else
            TimerTXT = DebuffMe.Abbreviation[Debuff_Choice] 
        end
    else
        if index == 1 then --no decimal point if main debuff
            TimerTXT = tostring(string.format("%.0f", Timer))
        else
			if DebuffMe.SlowMode == true then
				TimerTXT = tostring(string.format("%.0f", Timer))
			else
				TimerTXT = tostring(string.format("%.1f", Timer)) 
			end
        end
	end
    return TimerTXT
end

function DebuffMe.SetFontSize(label, size)
	local path = "EsoUI/Common/Fonts/univers67.otf"
    local outline = "soft-shadow-thick"
    label:SetFont(path .. "|" .. size .. "|" .. outline)
end

----------------
---- UPDATE ----
----------------
function DebuffMe.AltarTimer(_, changeType, _, _, _, _, endTime, _, _, _, _, _, _, _, _, abilityId, _)
	if changeType == COMBAT_UNIT_TYPE_PLAYER and abilityId == 39489 or 41967 or 41958 then
		local currentTimeStamp = endTime - GetGameTimeMilliseconds() / 1000
		if currentTimeStamp > 0 then
			DebuffMe.altarEndTime = endTime
		end
	end 
end

function DebuffMe.SetText(index, txt)
	if index == 1 then
		DebuffMeAlertMiddle:SetText(txt)
	elseif index == 2 then
		DebuffMeAlertLeft:SetText(txt)
	elseif index == 3 then
		DebuffMeAlertTop:SetText(txt)
	elseif index == 4 then
		DebuffMeAlertRight:SetText(txt)
	end
end

function DebuffMe.SetHidden(index, hide)
	if index == 1 then
		DebuffMeAlertMiddle:SetHidden(hide)
	elseif index == 2 then
		DebuffMeAlertLeft:SetHidden(hide)
	elseif index == 3 then
		DebuffMeAlertTop:SetHidden(hide)
	elseif index == 4 then
		DebuffMeAlertRight:SetHidden(hide)
	end
end

function DebuffMe.SetColor(index, immun)
	if index == 1 then
		if immun then 
			DebuffMeAlertMiddle:SetColor(unpack{1,0,0})
		else
			DebuffMeAlertMiddle:SetColor(unpack{1,1,1}) --FFFFFF
		end
	elseif index == 2 then
		if immun then 
			DebuffMeAlertLeft:SetColor(unpack{1,0,0})
		else
			DebuffMeAlertLeft:SetColor(unpack{0,(170/255),1}) --00AAFF
		end
	elseif index == 3 then
		if immun then 
			DebuffMeAlertTop:SetColor(unpack{1,0,0})
		else
			DebuffMeAlertTop:SetColor(unpack{(56/255),(195/255),0}) --38C300
		end
	elseif index == 4 then
		if immun then 
			DebuffMeAlertRight:SetColor(unpack{1,0,0})
		else
			DebuffMeAlertRight:SetColor(unpack{(236/255),(60/255),0}) --EC3C00
		end
	end
end

function DebuffMe.Update()
	local currentTargetHP, maxTargetHP, effmaxTargetHP = GetUnitPower("reticleover", POWERTYPE_HEALTH)
	local TXT = ""
	
	DebuffMeAlert:SetHidden(false)

	if maxTargetHP > DebuffMe.savedVariables.thresholdHP * 1000000 then --only if target got more than 1M hp
		for index = 1, #DebuffMe.Debuff_Show do
			if DebuffMe.Debuff_Show[index] ~= 1 then
				TXT = DebuffMe.Calcul(index)

				DebuffMe.SetText(index, TXT)
				DebuffMe.SetHidden(index, false)

				DebuffMe.SetColor(index, DebuffMe.flag_immunity)
			else 
				DebuffMe.SetHidden(index, true)
			end
		end
	else
		DebuffMeAlert:SetHidden(true)
	end
    
end

function DebuffMe.EventRegister()	

	EVENT_MANAGER:UnregisterForUpdate(DebuffMe.name .. "Update")

	if IsUnitInCombat("player") then
		if DebuffMe.SlowMode then
			EVENT_MANAGER:RegisterForUpdate(DebuffMe.name .. "Update", 333, DebuffMe.Update)
		else
			EVENT_MANAGER:RegisterForUpdate(DebuffMe.name .. "Update", 100, DebuffMe.Update)
		end
	else
        DebuffMeAlert:SetHidden(not DebuffMe.savedVariables.AlwaysShowAlert)
    end
end

--------------
---- INIT ----
--------------

function DebuffMe.InitUI()
	DebuffMeAlert:SetHidden(true)
	DebuffMeAlert:ClearAnchors()
	if (DebuffMe.savedVariables.OffsetX ~= 0) and (DebuffMe.savedVariables.OffsetY ~= 0) then 	--recover last position
		DebuffMeAlert:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, DebuffMe.savedVariables.OffsetX, DebuffMe.savedVariables.OffsetY)
	else																						--initial position (center)
		DebuffMeAlert:SetAnchor(CENTER, GuiRoot, CENTER, DebuffMe.savedVariables.OffsetX, DebuffMe.savedVariables.OffsetY)
	end
	
	DebuffMeAlertLeft:SetAnchor(CENTER, DebuffMeAlertMiddle, CENTER, -8*DebuffMe.savedVariables.Spacing, DebuffMe.savedVariables.Spacing)
	DebuffMeAlertTop:SetAnchor(CENTER, DebuffMeAlertMiddle, CENTER, 0, -6*DebuffMe.savedVariables.Spacing)
	DebuffMeAlertRight:SetAnchor(CENTER, DebuffMeAlertMiddle, CENTER, 8*DebuffMe.savedVariables.Spacing, DebuffMe.savedVariables.Spacing)

	DebuffMe.SetFontSize(DebuffMeAlertMiddle, (DebuffMe.savedVariables.FontSize * 0.9))
	DebuffMe.SetFontSize(DebuffMeAlertLeft, DebuffMe.savedVariables.FontSize)
	DebuffMe.SetFontSize(DebuffMeAlertTop, DebuffMe.savedVariables.FontSize)
	DebuffMe.SetFontSize(DebuffMeAlertRight, DebuffMe.savedVariables.FontSize)
end

function DebuffMe.GetSavedFor1_4()
	DebuffMe.Debuff_Show[1] = DebuffMe.savedVariables.Debuff_M
	DebuffMe.Debuff_Show[2] = DebuffMe.savedVariables.Debuff_L
	DebuffMe.Debuff_Show[3] = DebuffMe.savedVariables.Debuff_T
	DebuffMe.Debuff_Show[4] = DebuffMe.savedVariables.Debuff_R
	DebuffMe.savedVariables.Debuff_Show = DebuffMe.Debuff_Show
	
	DebuffMe.savedVariables.Debuff_M = nil
	DebuffMe.savedVariables.Debuff_L = nil 
	DebuffMe.savedVariables.Debuff_T = nil 
	DebuffMe.savedVariables.Debuff_R = nil 
end

function DebuffMe.AddCustomDataList()
	--remove from base table
	while #DebuffMe.DebuffList >= 23 do
		for i = 19, #DebuffMe.DebuffList do
			table.remove(DebuffMe.DebuffList, i)
			table.remove(DebuffMe.TransitionTable, i)
			table.remove(DebuffMe.Abbreviation, i)
			table.remove(DebuffMe.CustomAbilityNameWithID, DebuffMe.TransitionTable[i])
		end
	end

	for i = 1, #DebuffMe.CustomDataList.name do
		table.insert(	DebuffMe.DebuffList, DebuffMe.CustomDataList.name[i]) 			--name
		table.insert(	DebuffMe.TransitionTable, DebuffMe.CustomDataList.id[i]) 		--id
		table.insert(	DebuffMe.CustomAbilityNameWithID, DebuffMe.CustomDataList.id[i], 
						GetAbilityName(DebuffMe.CustomDataList.id[i])) 					--namewithid
		table.insert(	DebuffMe.Abbreviation, DebuffMe.CustomDataList.abbreviation[i])	--abbreviation
	end
	
	if RemoveDebuff_dropdown ~= nil then
		RemoveDebuff_dropdown:UpdateChoices()
	end
	if RightDebuff_dropdown ~= nil then
		RightDebuff_dropdown:UpdateChoices()
	end
	if LeftDebuff_dropdown ~= nil then
		LeftDebuff_dropdown:UpdateChoices()
	end
	if MainDebuff_dropdown ~= nil then
		MainDebuff_dropdown:UpdateChoices()
	end
	if TopDebuff_dropdown ~= nil then
		TopDebuff_dropdown:UpdateChoices()
	end
end

--function DebuffMe.Test()
	
--end

function DebuffMe:Initialize()
	--Saved Variables
	DebuffMe.savedVariables = ZO_SavedVars:New("DebuffMeVariables", 1, nil, DebuffMe.Default)

	--Custom table
	DebuffMe.CustomDataList = DebuffMe.savedVariables.CustomDataList
	DebuffMe.AddCustomDataList()

	--Settings
	DebuffMe.CreateSettingsWindow()
	
	--UI
	DebuffMe.InitUI()

	--Variables
	DebuffMe.Debuff_Show = DebuffMe.savedVariables.Debuff_Show
	DebuffMe.SlowMode = DebuffMe.savedVariables.SlowMode

	if DebuffMe.savedVariables.Debuff_M ~= nil and DebuffMe.savedVariables.Debuff_L ~= nil 
	and DebuffMe.savedVariables.Debuff_T ~= nil and DebuffMe.savedVariables.Debuff_R ~= nil then
		--get the previous values
		DebuffMe.GetSavedFor1_4()
	end
	
	--Events
	EVENT_MANAGER:RegisterForEvent(DebuffMe.name, EVENT_RETICLE_TARGET_CHANGED, DebuffMe.EventRegister)
	EVENT_MANAGER:RegisterForEvent(DebuffMe.name, EVENT_PLAYER_ACTIVATED, DebuffMe.EventRegister)
	EVENT_MANAGER:RegisterForEvent(DebuffMe.name, EVENT_PLAYER_COMBAT_STATE, DebuffMe.EventRegister)

	local altarID = {39489, 41967, 41958}
	for i = 1, #altarID do
		EVENT_MANAGER:RegisterForEvent(DebuffMe.name .. "Altar" .. i, EVENT_EFFECT_CHANGED, DebuffMe.AltarTimer)
		EVENT_MANAGER:AddFilterForEvent(DebuffMe.name .. "Altar" .. i, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, altarID[i])
	end	

	--Dev Part
	--SLASH_COMMANDS["/flotest"] = function() DebuffMe.Test() end

	EVENT_MANAGER:UnregisterForEvent(DebuffMe.name, EVENT_ADD_ON_LOADED)
end

function DebuffMe.SaveLoc()
	DebuffMe.savedVariables.OffsetX = DebuffMeAlert:GetLeft()
	DebuffMe.savedVariables.OffsetY = DebuffMeAlert:GetTop()
end	
 
function DebuffMe.OnAddOnLoaded(event, addonName)
	if addonName ~= DebuffMe.name then return end
		DebuffMe:Initialize()
end

EVENT_MANAGER:RegisterForEvent(DebuffMe.name, EVENT_ADD_ON_LOADED, DebuffMe.OnAddOnLoaded)