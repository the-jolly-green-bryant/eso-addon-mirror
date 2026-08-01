BSCCRHelper = BSCCRHelper or {}
local BSCCH = BSCCRHelper

BSCCH.Name = "BSCs-CloudrestFlareHelper"
BSCCH.Version = 1
BSCCH.SavedVar = "BSCCHSaved"

local UPDATE_INTERVAL = 100
local debug_mode = false

-- Flare every 20 seconds, execute Flare every 40 seconds
local nextFlare_seconds = 19
local lastCanalCall_time = 0
local isexecuteFlareTime = false
local Flare_range = 3

--106025		-- ZMaja Break Amulet 
--104452		-- Dark Canal

local Dark_canla_ID = 104452	   -- Dark Canal - Calling Shade of ZMaja
local execute_startID = 110426 -- Shade of Z'Maja start

local norm_flare = 103531 -- Normal Flare 
local exec_flare = 110431 -- Execute Flare (Mover)

local color_name = "|cd9dc09"
local color_countdown = "|cd9dc09"
local color_info_red = "|cFF0000"
local color_info_green = "|c33cc33"

local RFLARE_IDS = {
	[norm_flare] = true,
	[exec_flare] = true,
}
local RoaringFlare = { }

local defaultSV = {
	UI_LEFT = 250,
	UI_TOP  = 220,
	UI_LEFT_FLARE = 250,
	UI_TOP_FLARE  = 230,
	UI_LEFT_RESS = 250,
	UI_TOP_RESS  = 240,
	UI_BUFF_NAME_ENABLED = true,
	UI_BUFF_NAME_SIZE = 40,
	UI_FLAREON_ENABLED = true,
	UI_FLAREON_SIZE = 40,
	UI_FLARE_INFO_ENABLED = true,
	UI_FLARE_INFO_SIZE = 40,
	UI_NEXT_FLARE_ENABLED = true,
	UI_NEXT_FLARE_SIZE = 40,
	USE_DISPLAYNAME = false,
}

local function InitFlareIDs()
	BSCCRHelperUI:SetHidden(true)
	RoaringFlare = { }
	for abilityId in pairs(RFLARE_IDS) do
		RoaringFlare[abilityId] = { }
		RoaringFlare[abilityId].enabled = false
		RoaringFlare[abilityId].Name = ""
		RoaringFlare[abilityId].unitTag = ""
		RoaringFlare[abilityId].endTime = 0
		RoaringFlare[abilityId].itsMe = false
		RoaringFlare[abilityId].Role = LFG_ROLE_INVALID 
	end
end

local function GetDistance( unitTag1, unitTag2, useHeight )
	local zone1, x1, y1, z1 = GetUnitWorldPosition(unitTag1)
	local zone2, x2, y2, z2 = GetUnitWorldPosition(unitTag2)

	if (zone1 == 0 or zone1 ~= zone2) then
		return(-1)
	elseif (useHeight) then
		return(zo_sqrt((x1 - x2)^2 + (y1 - y2)^2 + (z1 - z2)^2) / 100)
	else
		return(zo_sqrt((x1 - x2)^2 + (z1 - z2)^2) / 100)
	end
end

local function FontCheck(size)
	local new_size = size
	
	if size > 54 then new_size = 54 end
	if size > 48 and size < 54 then new_size = 48 end
	if size > 40 and size < 48 then new_size = 40 end
	if size > 36 and size < 40 then new_size = 36 end
	if size > 34 and size < 36 then new_size = 34 end
	if size > 32 and size < 34 then new_size = 32 end
	if size > 30 and size < 32 then new_size = 30 end
	if size > 28 and size < 30 then new_size = 28 end
	if size > 26 and size < 28 then new_size = 26 end
		
	return new_size
end

-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- /////////////////////// UI Stufff                  ////////////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--/esoui/art/icons/death_recap_fire_aoe.dds
local function InitUI()

	-- BackFrame "border"
	--local UIFrame = BSCCRHelperUI:GetNamedChild("FrameMid")
	--UIFrame:SetDimensions(BSCAS.SV.UIMS_WIDTH, BSCAS.SV.UIMS_HIGHT)
	-------------------------------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------------------------------
	-- icon of the buff if enabled
	local UIIcon = BSCCRHelperUI:GetNamedChild("Icon")
	UIIcon:SetTexture(GetAbilityIcon(norm_flare))	
	--UIIcon:SetDimensions(BSCAS.SV.UI_HIGHT -4, BSCAS.SV.UI_HIGHT -4) -- 2 border
	-------------------------------------------------------------------------------------------------------------------------
	local UIbuffName = BSCCRHelperUI:GetNamedChild("buffName")
	UIbuffName:SetText(zo_strformat("<<1>> !", GetAbilityName(norm_flare)))
	--UIName:SetFont("$(MEDIUM_FONT)|$(KB_" .. BSCAS.FontCheck(math.floor(BSCAS.SV.UIMS_HIGHT / 2)) .. ")|soft-shadow-thin")	
	--UIName:SetDimensions(200, BSCAS.SV.UIMS_HIGHT -4)
	-------------------------------------------------------------------------------------------------------------------------
	-- FlareOnName text	
	local UIName = BSCCRHelperUI:GetNamedChild("FlareOnName")
	UIName:SetText(zo_strformat("<<1>>(Stay!) <<2>> TestDude(Switch!)", GetUnitName('player'), '< <> >'))
	--UIName:SetFont("$(MEDIUM_FONT)|$(KB_" .. BSCAS.FontCheck(math.floor(BSCAS.SV.UIMS_HIGHT / 2)) .. ")|soft-shadow-thin")	
	--UIName:SetDimensions(200, BSCAS.SV.UIMS_HIGHT -4)
	-------------------------------------------------------------------------------------------------------------------------
	-- Todo Text
	local UITodo = BSCCRHelperUI:GetNamedChild("info")
	UITodo:SetText(string.format("%.1fm", 0).." Stay! "..string.format("%.1fs", 0))
	--UITodo:SetFont("$(BOLD_FONT)|$(KB_" .. BSCAS.FontCheck(math.floor(BSCAS.SV.UIMS_HIGHT / 2)) .. ")|soft-shadow-thick")		
	--UITodo:SetDimensions(64, BSCAS.SV.UIMS_HIGHT -4) 	
		
	BSCCRHelperUINextFlare:GetNamedChild("NextFlare"):SetText(zo_strformat("<<1>> <<2>> <<3>>", "Next Flare: ", color_countdown, string.format("%.1fs", nextFlare_seconds)))
	
	BSCCRHelperRessUI:GetNamedChild("RessInfo"):SetText(zo_strformat("<<1>> <<2>>", color_info_red, "Don't Ress!!"))
end

function BSCCH.UpdateUISettings()	
	--
	if BSCCH.SV.UI_BUFF_NAME_ENABLED then
		BSCCRHelperUI:GetNamedChild("Icon"):SetHidden(false)
		BSCCRHelperUI:GetNamedChild("buffName"):SetHidden(false)
	else
		BSCCRHelperUI:GetNamedChild("Icon"):SetHidden(true)
		BSCCRHelperUI:GetNamedChild("buffName"):SetHidden(true)
	end
	BSCCRHelperUI:GetNamedChild("Icon"):SetDimensions(math.floor(BSCCH.SV.UI_BUFF_NAME_SIZE * 0.80), math.floor(BSCCH.SV.UI_BUFF_NAME_SIZE * 0.80))
	BSCCRHelperUI:GetNamedChild("buffName"):SetDimensions(math.floor(BSCCH.SV.UI_BUFF_NAME_SIZE * 4.8), math.floor(BSCCH.SV.UI_BUFF_NAME_SIZE * 0.80))
	BSCCRHelperUI:GetNamedChild("buffName"):SetFont("$(BOLD_FONT)|$(KB_" .. FontCheck(math.floor(BSCCH.SV.UI_BUFF_NAME_SIZE * 0.6)) .. ")|soft-shadow-thin")
	--
	if BSCCH.SV.UI_FLAREON_ENABLED then
		BSCCRHelperUI:GetNamedChild("FlareOnName"):SetHidden(false)
		BSCCRHelperUI:GetNamedChild("FrameMid"):SetHidden(false)
	else
		BSCCRHelperUI:GetNamedChild("FlareOnName"):SetHidden(true)
		BSCCRHelperUI:GetNamedChild("FrameMid"):SetHidden(true)
	end
	
	BSCCRHelperUI:GetNamedChild("FrameMid"):SetDimensions(math.floor(BSCCH.SV.UI_FLAREON_SIZE * 14.4), math.floor(BSCCH.SV.UI_FLAREON_SIZE * 0.80))	
	BSCCRHelperUI:GetNamedChild("FlareOnName"):SetDimensions(math.floor(BSCCH.SV.UI_FLAREON_SIZE * 14.4), math.floor(BSCCH.SV.UI_FLAREON_SIZE * 0.80))
	BSCCRHelperUI:GetNamedChild("FlareOnName"):SetFont("$(BOLD_FONT)|$(KB_" .. FontCheck(math.floor(BSCCH.SV.UI_FLAREON_SIZE * 0.6)) .. ")|soft-shadow-thick")
	--
	if BSCCH.SV.UI_FLARE_INFO_ENABLED then
		BSCCRHelperUI:GetNamedChild("info"):SetHidden(false)
	else
		BSCCRHelperUI:GetNamedChild("info"):SetHidden(true)
	end
	BSCCRHelperUI:GetNamedChild("info"):SetDimensions(math.floor(BSCCH.SV.UI_FLARE_INFO_SIZE * 4.8), math.floor(BSCCH.SV.UI_FLARE_INFO_SIZE * 0.80))
	BSCCRHelperUI:GetNamedChild("info"):SetFont("$(BOLD_FONT)|$(KB_" .. FontCheck(math.floor(BSCCH.SV.UI_FLARE_INFO_SIZE * 0.6)) .. ")|soft-shadow-thick")	
	--
	if not BSCCH.SV.UI_NEXT_FLARE_ENABLED then
		BSCCRHelperUINextFlare:SetHidden(true)
	end
	BSCCRHelperUINextFlare:GetNamedChild("Frame"):SetDimensions(math.floor(BSCCH.SV.UI_NEXT_FLARE_SIZE * 4.8), math.floor(BSCCH.SV.UI_NEXT_FLARE_SIZE * 0.80))	
	BSCCRHelperUINextFlare:GetNamedChild("NextFlare"):SetDimensions(math.floor(BSCCH.SV.UI_NEXT_FLARE_SIZE * 4.8), math.floor(BSCCH.SV.UI_NEXT_FLARE_SIZE * 0.80))	
	BSCCRHelperUINextFlare:GetNamedChild("NextFlare"):SetFont("$(BOLD_FONT)|$(KB_" .. FontCheck(math.floor(BSCCH.SV.UI_NEXT_FLARE_SIZE * 0.6)) .. ")|soft-shadow-thick")
	--
	
end

local function UpdateUI()
	--103531 -- Normal Flare
	--110431 -- Execute Flare
	
	local dist = 0
	local DURATION = 0		
	-- Both sides "execute"
	if RoaringFlare[norm_flare].enabled == true and RoaringFlare[exec_flare].enabled == true then		
		DURATION = RoaringFlare[norm_flare].endTime - (GetGameTimeMilliseconds()/1000)		
		dist = GetDistance(RoaringFlare[norm_flare].unitTag, RoaringFlare[exec_flare].unitTag, false)	
				
		local player1_info = "Stay!"
		local player2_info = "Stay!"
		local infotext = zo_strformat("<<1>> <<2>> <<3>>", color_info_green, "Stay! ", string.format("%.1fs", DURATION))
				
		if dist < Flare_range then
			
			player2_info = "Switch!"
			if RoaringFlare[exec_flare].Role == LFG_ROLE_HEAL then
				player1_info = "Switch!"
				player2_info = "Stay!"			
			end
			-- One Need to Move
			if RoaringFlare[norm_flare].itsMe == true then
				infotext = zo_strformat("<<1>> <<2>> <<3>>", color_info_green, player1_info, string.format("%.1fs", DURATION))			
			end	
			if RoaringFlare[exec_flare].itsMe == true then			
				infotext = zo_strformat("<<1>> <<2>> <<3>>", color_info_red, player2_info, string.format("%.1fs", DURATION))
			end
		end	
				
		BSCCRHelperUI:GetNamedChild("FlareOnName"):SetText(zo_strformat("<<1>>(<<2>>) <<3>> <<4>>(<<5>>)", RoaringFlare[norm_flare].Name, player1_info, '< <> >', RoaringFlare[exec_flare].Name, player2_info))
		BSCCRHelperUI:GetNamedChild("info"):SetText(infotext)	
		
		-- RoaringFlare[103531].Role
		-- LFG_ROLE_HEAL
	-- Both sides "normal mode"
	elseif RoaringFlare[norm_flare].enabled == true then		
		DURATION = RoaringFlare[norm_flare].endTime - (GetGameTimeMilliseconds()/1000)		
		BSCCRHelperUI:GetNamedChild("FlareOnName"):SetText(RoaringFlare[norm_flare].Name)		
		if RoaringFlare[norm_flare].itsMe == true then
			BSCCRHelperUI:GetNamedChild("info"):SetText(zo_strformat("<<1>> <<2>> <<3>>", color_info_green, "Stay! ", string.format("%.1fs", DURATION)))
		else
			dist = GetDistance('player', RoaringFlare[norm_flare].unitTag, false)
			if dist > Flare_range then
				BSCCRHelperUI:GetNamedChild("info"):SetText(zo_strformat("<<1>> <<2>> <<3>> <<4>>", string.format("%.1fm", dist), color_info_red, " Move! ", string.format("%.1fs", DURATION)))
			else
				BSCCRHelperUI:GetNamedChild("info"):SetText(zo_strformat("<<1>> <<2>> <<3>> <<4>>", string.format("%.1fm", dist), color_info_green, " Stay! ", string.format("%.1fs", DURATION)))
			end
		end	
	elseif RoaringFlare[exec_flare].enabled == true then		
		DURATION = RoaringFlare[exec_flare].endTime - (GetGameTimeMilliseconds()/1000)	
		BSCCRHelperUI:GetNamedChild("FlareOnName"):SetText(RoaringFlare[exec_flare].Name)
		if RoaringFlare[exec_flare].itsMe == true then			
			BSCCRHelperUI:GetNamedChild("info"):SetText(zo_strformat("<<1>> <<2>> <<3>>", color_info_green, "Stay! ", string.format("%.1fs", DURATION)))
		else
			dist = GetDistance('player', RoaringFlare[exec_flare].unitTag, false)			
			if dist > Flare_range then
				BSCCRHelperUI:GetNamedChild("info"):SetText(zo_strformat("<<1>> <<2>> <<3>> <<4>>", string.format("%.1fm", dist), color_info_red, " Move! ", string.format("%.1fs", DURATION)))
			else
				BSCCRHelperUI:GetNamedChild("info"):SetText(zo_strformat("<<1>> <<2>> <<3>> <<4>>", string.format("%.1fm", dist), color_info_green, " Stay! ", string.format("%.1fs", DURATION)))
			end
		end
	end
	
	if DURATION < 0 then		
		InitFlareIDs()
	end	
	--
	if BSCCH.SV.UI_NEXT_FLARE_ENABLED then
		local FLARE_DUR = nextFlare_seconds - (GetGameTimeMilliseconds()/1000)
		if FLARE_DUR > 0.0 then
			BSCCRHelperUINextFlare:GetNamedChild("NextFlare"):SetText(zo_strformat("<<1>> <<2>> <<3>>", "Next Flare: ", color_countdown, string.format("%.1fs", FLARE_DUR)))
		else
			BSCCRHelperUINextFlare:GetNamedChild("NextFlare"):SetText(zo_strformat("<<1>> <<2>> <<3>>", "Next Flare: ", color_info_red, "Now!"))
		end
	end
end

local function ToggleUI(oldState, newState)
	--if newState == SCENE_SHOWN then
	--	BSCCRHelperUI:SetHidden(false)
	--elseif newState == SCENE_HIDDEN then
	--	BSCCRHelperUI:SetHidden(true)
	--end
end
function BSCCH.OnMoveStop()
	BSCCH.SV.UI_LEFT = BSCCRHelperUI:GetLeft()
	BSCCH.SV.UI_TOP = BSCCRHelperUI:GetTop()
end

function BSCCH.OnMoveStopFlare()
	BSCCH.SV.UI_LEFT_FLARE = BSCCRHelperUINextFlare:GetLeft()
	BSCCH.SV.UI_TOP_FLARE = BSCCRHelperUINextFlare:GetTop()
end

function BSCCH.OnMoveStopRess()
	BSCCH.SV.UI_LEFT_RESS = BSCCRHelperRessUI:GetLeft()
	BSCCH.SV.UI_TOP_RESS = BSCCRHelperRessUI:GetTop()
end

local function RestorePosition()
	BSCCRHelperUI:ClearAnchors()
	BSCCRHelperUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BSCCH.SV.UI_LEFT, BSCCH.SV.UI_TOP)
	
	BSCCRHelperUINextFlare:ClearAnchors()
	BSCCRHelperUINextFlare:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BSCCH.SV.UI_LEFT_FLARE, BSCCH.SV.UI_TOP_FLARE)
	
	BSCCRHelperRessUI:ClearAnchors()
	BSCCRHelperRessUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BSCCH.SV.UI_LEFT_RESS, BSCCH.SV.UI_TOP_RESS)
end

-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
local function GetUnitTagFromName(unitName)	
	if zo_strformat("<<1>>", GetUnitName("player")) == zo_strformat("<<1>>", unitName) then
		return "player" 
	end
	
	for i = 1, GetGroupSize() do	
		local unitTag = GetGroupUnitTagByIndex(i)
		if unitTag then
			if zo_strformat("<<1>>", GetUnitName(unitTag)) == zo_strformat("<<1>>", unitName) then
				return unitTag 
			end
		end
	end
	
	return "player" 
end

local function RoringFlareFaded(abilityId)
	RoaringFlare[abilityId].enabled = false
	RoaringFlare[abilityId].Name = ""
	RoaringFlare[abilityId].unitTag = ""
	RoaringFlare[abilityId].endTime = 0	
	RoaringFlare[abilityId].itsMe = false
	RoaringFlare[abilityId].Role = LFG_ROLE_INVALID
	if not BSCCRHelperUI:IsHidden() then BSCCRHelperUI:SetHidden(true) end	
	if isexecuteFlareTime then
		nextFlare_seconds = (GetGameTimeMilliseconds()/1000)+39
	else
		nextFlare_seconds = (GetGameTimeMilliseconds()/1000)+19
	end
	if BSCCRHelperUINextFlare:IsHidden() and BSCCH.SV.UI_NEXT_FLARE_ENABLED then BSCCRHelperUINextFlare:SetHidden(false) end
end

local function RoringFlareGained(abilityId, itsMe, unitName, DisplayName, unitTag)
	RoaringFlare[abilityId].enabled = true		
	if itsMe == true then
		RoaringFlare[abilityId].Name = zo_strformat("<<1>> <<2>>", color_info_red, "On You!")
	else
		if BSCCH.SV.USE_DISPLAYNAME then 
			unitName = DisplayName
		end
		RoaringFlare[abilityId].Name = zo_strformat("<<1>> <<2>>", color_name, "On > "..unitName)
	end		
	RoaringFlare[abilityId].unitTag = unitTag
	RoaringFlare[abilityId].endTime = ((GetGameTimeMilliseconds() + 6500)/1000)
	RoaringFlare[abilityId].itsMe = itsMe
	RoaringFlare[abilityId].Role = GetGroupMemberSelectedRole(unitTag)		
	BSCCRHelperUI:SetHidden(false)	
end

-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- combat event try
local function OnCombatEvent(_, result, _, _, _, _, sourceName, _, targetName, _, hitValue, _, _, _, _, targetUnitId, abilityId, _)		
	if result == ACTION_RESULT_BEGIN then --ACTION_RESULT_EFFECT_GAINED then
		if debug_mode then 
			d(zo_strformat("GAINED ID[<<1>>] sourceName[<<2>>] TargetName[<<3>>] targetUnitId[<<4>>]", abilityId, sourceName, targetName, targetUnitId))			
		end
		
		if targetName == "" then
			targetName = LibUnitTracker:GetUnitNameByUnitId(targetUnitId)
		end
		local displayname = LibUnitTracker:GetDisplayNameByUnitId(targetUnitId)
		
		local itsMe = false
		if zo_strformat("<<1>>", GetUnitName("player")) == zo_strformat("<<1>>", targetName) then
			itsMe = true
		end	
		RoringFlareGained(abilityId, itsMe, targetName, displayname, GetUnitTagFromName(targetName))
	end	
	if result == ACTION_RESULT_EFFECT_FADED then 
		if debug_mode then 
			d(zo_strformat("FADED ID[<<1>>] SkillName[<<2>>] TargetName[<<3>>]", abilityId, GetAbilityName(abilityId), targetName))
		end
		RoringFlareFaded(abilityId)
	end	
end

-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
local function OnCombatEventExecute(_, result, _, _, _, _, _, _, targetName, _, hitValue, _, _, _, _, targetUnitId, abilityId, _)	
	if result == ACTION_RESULT_EFFECT_GAINED then
		if debug_mode then 
			d(zo_strformat("GAINED ID[<<1>>] SkillName[<<2>>] TargetName[<<3>>]", abilityId, GetAbilityName(abilityId), targetName))
		end
		isexecuteFlareTime = true
		--if lastCanalCall_time > 0 then
		--	nextFlare_seconds = lastCanalCall_time
		--else
		--	nextFlare_seconds = (GetGameTimeMilliseconds()/1000)+39
		--end
		--d("OnCombatEventExecute")
	end	
	if result == ACTION_RESULT_EFFECT_FADED then 
		if debug_mode then 
			d(zo_strformat("FADED ID[<<1>>] SkillName[<<2>>] TargetName[<<3>>]", abilityId, GetAbilityName(abilityId), targetName))
		end
		isexecuteFlareTime = false
		nextFlare_seconds = 0
	end	
end
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
local function OnCombatEventDarkCallZMaja(_, result, _, _, _, _, _, _, targetName, _, hitValue, _, _, _, _, targetUnitId, abilityId, _)	
	if result == ACTION_RESULT_BEGIN then
		--lastCanalCall_time = (GetGameTimeMilliseconds()/1000)+35
		d("OnCombatEventDarkCallZMaja")
	end	
end	
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- 102271 - Schatten der Gefallenen
local FallenSchadownID = 102271
local function OnTargedPlayerChanged()	
	local unitTag = 'reticleover'
	if not IsUnitPlayer(unitTag) then return end	
	if IsUnitDead(unitTag) then 
		local numberOfBuffs = GetNumBuffs(unitTag) 
		for i = 0, numberOfBuffs do 
			local _, _, _, _, _, _, _, _, _, _, _, abilityId, _, _ = GetUnitBuffInfo(unitTag, i) 
			if FallenSchadownID == abilityId then
				-- Enable UI
				--d("Dont Rez")				
				--BSCCRHelperRessUI:SetHidden(false)
			end
		end
	else
		if not BSCCRHelperRessUI:IsHidden() then
			--BSCCRHelperRessUI:SetHidden(true)
		end
	end
end

-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
local register_vcr = false
local function OnPlayerActivated()		
	--CHAT_ROUTER:AddSystemMessage(BSCCH.Name.." Now Enabled!")
	--
	InitFlareIDs()
	local zoneId = GetUnitWorldPosition("player") 	
	-- CloudRest
	if zoneId == 1051 then		
		register_vcr = true
		EVENT_MANAGER:RegisterForEvent(BSCCH.Name, EVENT_RETICLE_TARGET_PLAYER_CHANGED, OnTargedPlayerChanged)		
				
		local eventName = ""
		for abilityId in pairs(RFLARE_IDS) do
			eventName = BSCCH.Name..abilityId
			--
			EVENT_MANAGER:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, OnCombatEvent)
			EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId)	
		end			
		
		
		EVENT_MANAGER:RegisterForEvent(BSCCH.Name..execute_startID, EVENT_COMBAT_EVENT, OnCombatEventExecute)
		EVENT_MANAGER:AddFilterForEvent(BSCCH.Name..execute_startID, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, execute_startID)	
		
		--EVENT_MANAGER:RegisterForEvent(BSCCH.Name..Dark_canla_ID, EVENT_COMBAT_EVENT, OnCombatEventDarkCallZMaja)
		--EVENT_MANAGER:AddFilterForEvent(BSCCH.Name..Dark_canla_ID, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, Dark_canla_ID)	
		
		
		EVENT_MANAGER:RegisterForUpdate(BSCCH.Name..'_UpdateUI', UPDATE_INTERVAL, UpdateUI)	

	elseif register_vcr then
		register_vcr = false
		EVENT_MANAGER:UnregisterForEvent(BSCCH.Name, EVENT_RETICLE_TARGET_PLAYER_CHANGED)
		for abilityId in pairs(RFLARE_IDS) do
			local eventName = BSCCH.Name..abilityId
			--
			EVENT_MANAGER:UnregisterForEvent(eventName, EVENT_COMBAT_EVENT)
		end
		EVENT_MANAGER:UnregisterForEvent(BSCCH.Name..execute_startID, EVENT_COMBAT_EVENT)
		--EVENT_MANAGER:UnregisterForEvent(BSCCH.Name..Dark_canla_ID, EVENT_COMBAT_EVENT)
		
		
		EVENT_MANAGER:UnregisterForUpdate(BSCCH.Name..'_UpdateUI')
		
		BSCCRHelperUINextFlare:SetHidden(true)
	end
end


local function OnCombatState(_, inCombat)
	--local pstatus = zo_strformat("<<1>>[<<2>><<3>><<4>>]", "|cb3b6b7", (inCombat and color_info_red or color_info_green), (inCombat and 'Combat' or 'No Combat'), "|cb3b6b7")
	--CHAT_ROUTER:AddSystemMessage(zo_strformat("|cb3b6b7<<1>> <<2>>", "CombatStatus", pstatus))	
	if inCombat then
		
	else
		BSCCRHelperRessUI:SetHidden(true)
		BSCCRHelperUINextFlare:SetHidden(true)
		InitFlareIDs()
		isexecuteFlareTime = false
	end
end
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////// --- Init -- //////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
local function SlashCommand(text)
	local ftext = zo_strlower(text)
	if ftext == 'debug' then		
		if debug_mode then
			debug_mode = false
			d("Debug Mode (CloudrestHelper) Disabled!")
		else
			debug_mode = true
			d("Debug Mode (CloudrestHelper) Enabled!")
		end
	elseif ftext == 'move' then	
		if BSCCRHelperUI:IsHidden() then
			BSCCRHelperUI:SetHidden(false)
			BSCCRHelperUI:SetMovable(true)
		else
			BSCCRHelperUI:SetHidden(true)
			BSCCRHelperUI:SetMovable(false)
		end	
		
		if BSCCRHelperUINextFlare:IsHidden() then			
			BSCCRHelperUINextFlare:SetHidden(false)
			BSCCRHelperUINextFlare:SetMovable(true)
		else
			BSCCRHelperUINextFlare:SetHidden(true)
			BSCCRHelperUINextFlare:SetMovable(false)
		end
		
		--if BSCCRHelperRessUI:IsHidden() then			
		--	BSCCRHelperRessUI:SetHidden(false)
		--	BSCCRHelperRessUI:SetMovable(true)
		--else
		--	BSCCRHelperRessUI:SetHidden(true)
		--	BSCCRHelperRessUI:SetMovable(false)
		--end
				
	elseif ftext == 'test' then
		CombatAlertsData.cloudrest.flare = {
					[-1] = true,
					[-1] = true,
					execute = -1,
				}
	else
		d("Commands:")
		d("/bsccrh debug")
		d("/bsccrh move")
	end
end

function BSCCH.init(event, addonName)	
	if addonName ~= BSCCH.Name then
		return 
	end			
	EVENT_MANAGER:UnregisterForEvent(BSCCH.Name, 	EVENT_ADD_ON_LOADED)
	
	-- Get Saved Data	
	BSCCH.SV = ZO_SavedVars:NewCharacterNameSettings(BSCCH.SavedVar, BSCCH.Version, nil, defaultSV)
	
	BSCCH.InitMenu()
	
	BSCCRHelperRessUI:SetHidden(true)
	
	InitUI()
	BSCCH.UpdateUISettings()
	RestorePosition()
	
	isexecuteFlareTime = false
	
	SCENE_MANAGER:GetScene("hud"):RegisterCallback("StateChange", ToggleUI)
	SCENE_MANAGER:GetScene("hudui"):RegisterCallback("StateChange", ToggleUI)
		
	-- Command
	SLASH_COMMANDS['/bsccrh'] = SlashCommand		
	-- REWORKED / New
	EVENT_MANAGER:RegisterForEvent(BSCCH.Name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
	EVENT_MANAGER:RegisterForEvent(BSCCH.Name, EVENT_PLAYER_COMBAT_STATE, OnCombatState)		
end

EVENT_MANAGER:RegisterForEvent(BSCCH.Name, EVENT_ADD_ON_LOADED, BSCCH.init)