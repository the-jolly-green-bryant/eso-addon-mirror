--[[
* ins:Mobs2Level2
* by iNSTANT  / ins@ESOUI
* 20140630-20160601 versions by mra4nii 
]]--


local insM2L = insM2L -- our global variable
local M2LSettings = nil
local txt = nil
-- a local variable for all the tradeskills.. this way we get them localized
local crafts = {
    [1] = {GetSkillLineXPInfo(8,1)},		-- alchemy
    [2] = {GetSkillLineXPInfo(8,2)}, 		-- blacksmith
    [3] = {GetSkillLineXPInfo(8,3)}, 		-- clothier
    [4] = {GetSkillLineXPInfo(8,4)}, 		-- enchanting
    [5] = {GetSkillLineXPInfo(8,5)}, 		-- jewelcrafting
    [6] = {GetSkillLineXPInfo(8,6)}, 		-- provisioning
    [7] = {GetSkillLineXPInfo(8,7)},		-- woodworking
}

--------------------------------------------------------------------
--  Displayer function
--  input: what to output (a string)
--  Purpose: Display the pretty output and replace some codes.
--------------------------------------------------------------------
local function Displayer(output)
	local output = output

--  time to add colours
	output = string.gsub(output,"<cG>","|c00FF00") -- green (cG)
	output = string.gsub(output,"<cR>","|cFF0000") -- Red  (cR)
	output = string.gsub(output,"<cY>","|cFFFF00") -- yellow (cY)
	output = string.gsub(output,"<cT>","|c00FFFF") -- teal (cT)
	output = string.gsub(output,"<cW>","|cFFFFFF") -- white (cW)
		
	if ( insM2L.SV.timestamp ) then
		output = "|c8F8F8F[" .. GetTimeString() .. "]|r " .. output
	end

--	insM2L.tab:AddMessage(output)
	d(output)

end

--------------------------------------------------------------------
--  Prepare function
--  input: reason, gainXp, toGo(xp), kills(togo), skillname
--  Purpose: Prepare output to screen based on input and localization
--------------------------------------------------------------------
local function Prepare(what, gainXP, toGo, kills, skill)

	if ( insM2L.SV.debg ) then
		Displayer("Prepare what=" .. what.. " gainXp=" .. gainXP .. " toGo=" .. toGo .. " kills=" .. kills .. " skill=" .. skill)
	end

	local output

	if ( ( what == 1 ) and ( insM2L.SV.output ) ) then 
		output = insM2L.SV.custXPmsg 
	elseif ( ( what == 2 ) and ( insM2L.SV.output ) ) then 
		output = insM2L.SV.custSkillmsg 
	elseif ( ( what == 3 ) and ( insM2L.SV.output ) ) then 
		output = insM2L.SV.custQuestmsg
	elseif ( ( what == 4 ) and ( insM2L.SV.output ) ) then 
		output = insM2L.SV.custEventmsg
	else
		output = txt["xppredefined"]
	end
		
	output = string.gsub(output,"<1>",gainXP)
		
	if ( toGo ~= nil ) then output = string.gsub(output,"<2>",toGo) end
	if ( kills ~= nil ) then output = string.gsub(output,"<3>",kills) end
	if ( skill ~= nil ) then output = string.gsub(output,"<4>",skill) end
	if ( what == 1 ) then output = string.gsub(output,"<999>",txt["base"][1]) end -- kills
	if ( what == 2 ) then output = string.gsub(output,"<999>",txt["base"][2]) end -- crafting
	if ( what == 3 ) then output = string.gsub(output,"<999>",txt["base"][3]) end -- quest
	if ( what == 4 ) then output = string.gsub(output,"<999>",txt["base"][4]) end -- event

	output = output .. " "
	Displayer(output)
end

--------------------------------------------------------------------
--  SkillXP function
--  input: eventCode, skillType, skillIndex, reason, rank, previousXP, currentXP
--  Purpose: Calculate progression in crafting skills lines
--------------------------------------------------------------------
local function SkillXP(eventCode, skillType, skillIndex, reason, rank, previousXP, currentXP)
	if ( insM2L.SV.debg ) then
		Displayer("SKILL. eventCode=" .. eventCode .. " skillType=" .. skillType .. " skillIndex=" .. skillIndex .. " reason=" .. reason .. " rank=" .. rank .. " previousXP=" .. previousXP .. " currentXP=" .. currentXP)
	end
	
	if ( ( not insM2L.SV.craft ) or ( eventCode ~= EVENT_SKILL_XP_UPDATE ) or ( skillType ~= 8 ) ) then
		return
	end

	local gainXP = currentXP - previousXP												-- get the amount of receive xp
	if ( gainXP == 0 ) then return end													-- if the xp we gained is 0 we exit.
	
	local SkillName	= GetSkillLineInfo(8,skillIndex)
	local lastRankXp, nextRankXP  = GetSkillLineXPInfo(8,skillIndex)
	local cLevelXP = nextRankXP - lastRankXp											-- This is the XP for the entire level
	local cCurXP = currentXP - lastRankXp												-- this is the current XP in the current level
	local toGo = cLevelXP - cCurXP														-- xp to go in the current level
	local kills = math.ceil(toGo/gainXP)												-- how many iterations at current reward for levelup

    Prepare(2,gainXP,toGo,kills,SkillName)												-- Prepare our output
end

--------------------------------------------------------------------
--  GeneralXP function
--  input: eventCode, unitTag, currentExp, maxExp, reason
--  Purpose: Calculate progression in character leveling
--------------------------------------------------------------------
local function GeneralXP(eventCode, unitTag, currentExp, maxExp, reason)
	if ( insM2L.SV.debg ) then
		Displayer("XP. eventCode=" .. eventCode .. " unitTag=" .. unitTag .. " currentExp=" .. currentExp .. " maxExp=" .. maxExp .. " reason=" .. reason)
	end

	if ( ( unitTag ~= 'player' ) or ( eventCode ~= EVENT_EXPERIENCE_UPDATE ) or ( reason < 0 ) or ( reason == PROGRESS_REASON_FINESSE ) ) then
		return
	end

-- detection of god mode	
	if ( GetPlayerChampionPointsEarned() == 3600 ) then return end
	
-- some manipulations with data when lvl-up detected
	if ( currentExp > maxExp ) then
		maxExp = GetUnitXPMax('player')
	end
-- if cp, we use different dates
	insM2L.playerInfo.veteran = IsUnitChampion('player')
	insM2L.playerInfo.champion = IsChampionSystemUnlocked()
	if ( insM2L.playerInfo.veteran and insM2L.playerInfo.champion) then
		if ( insM2L.SV.debg ) then
			Displayer("CP. eventCode=" .. eventCode .. " unitTag=" .. unitTag .. " currentExp=" .. GetPlayerChampionXP() .. " maxExp=" .. GetNumChampionXPInChampionPoint(GetPlayerChampionPointsEarned()) .. " reason=" .. reason)
		end
		currentExp = GetPlayerChampionXP()
		maxExp = GetNumChampionXPInChampionPoint(GetPlayerChampionPointsEarned())
	end
	
	local oldXP	= insM2L.playerInfo.xp
	local oldmaxExp = insM2L.playerInfo.maxxp
-- getting gainXP
	local gainXP = currentExp - oldXP
	if ( gainXP == 0 ) then return end
-- happens on new cp or on new vet lvl
	if ( gainXP < 0 ) then gainXP = oldmaxExp - oldXP + currentExp end
-- save new data
	insM2L.playerInfo.xp = currentExp
	insM2L.playerInfo.maxxp = maxExp
-- lvl-up detected(non vet)	
	if ( ( maxExp ~= oldmaxExp ) and ( not insM2L.playerInfo.veteran ) ) then	
				insM2L.playerInfo.xp = currentExp - oldmaxExp
	end	

	local toGo 	= insM2L.playerInfo.maxxp - insM2L.playerInfo.xp					-- how many iterations to lvl-up
	local kills = math.ceil(toGo/gainXP)											-- xp to go in the current level

	if ( ( reason == PROGRESS_REASON_KILL ) and insM2L.SV.kill ) then Prepare(1,gainXP,toGo,kills,nil) return end											-- 1 Kills
	if ( ( reason == PROGRESS_REASON_QUEST ) and insM2L.SV.quest ) then Prepare(3,gainXP,toGo,kills,nil) return end											-- 3 Quests
	if ( ( reason ~= PROGRESS_REASON_KILL ) and ( reason ~= PROGRESS_REASON_QUEST ) and insM2L.SV.event ) then Prepare(4,gainXP,toGo,kills,nil) return end	-- 4 Events(all other XP gain)

end

--------------------------------------------------------------------
--  insM2L.Intro function
--  input: Nothing
--  Purpose: Inform the user the addon has loaded
--------------------------------------------------------------------
local function Intro()

-- validate saved chat tab ID, then set to 
	if ( not M2LSettings:SetOutputTab(insM2L.SV.tab) ) then
		insM2L.SV.tab = insM2L.defaults.tab
		M2LSettings:SetOutputTab(insM2L.SV.tab)
	end

--  initialize character information. 
	insM2L.playerInfo = {
		["name"] = GetUnitName('player'),
		["xp"] = GetUnitXP('player'),
		["maxxp"] = GetUnitXPMax('player'),
		['veteran'] = IsUnitChampion('player'),
		['champion'] = IsChampionSystemUnlocked(),
	}
 
--  check and initiliaze CP lvl progression
	if ( insM2L.playerInfo.veteran and insM2L.playerInfo.champion ) then
		insM2L.playerInfo.xp = GetPlayerChampionXP()
		insM2L.playerInfo.maxxp = GetNumChampionXPInChampionPoint(GetPlayerChampionPointsEarned())
	end
	
	Displayer(txt["phrases"].INTRO) -- Display localized loadup message.
	Displayer("<cW>Enlightened Pool: <cG>" .. GetEnlightenedPool() .. "<cY>XP")
	EVENT_MANAGER:UnregisterForEvent("insM2L",EVENT_PLAYER_ACTIVATED)
end

--------------------------------------------------------------------
--  insM2L.Initialize function
--  input: eventCode, addOnName
--  Purpose: Initialize settings, register for XP gain events
--------------------------------------------------------------------
local function Initialize(eventCode, addOnName)
	if ( addOnName ~= insM2L.name ) then return end

	M2LSettings = insM2L.insM2LSettings:New()

--  setup the language with the above function
	txt = insM2L.strings[M2LSettings:GetLang()]

-- We register for events we want to track.
	EVENT_MANAGER:RegisterForEvent("insM2L",EVENT_PLAYER_ACTIVATED,Intro)
	EVENT_MANAGER:RegisterForEvent("insM2LXP",EVENT_EXPERIENCE_UPDATE,GeneralXP)
	EVENT_MANAGER:RegisterForEvent("insM2LSXP",EVENT_SKILL_XP_UPDATE,SkillXP) -- 8,skillId,lastlevelXP,nextlevelXP,currentXP

-- We unregister for the event as the addon is loaded.
	EVENT_MANAGER:UnregisterForEvent("insM2L",EVENT_ADD_ON_LOADED)
end

-- We register an event to initialize the addon, and another to spam a message on load.
EVENT_MANAGER:RegisterForEvent("insM2L",EVENT_ADD_ON_LOADED,Initialize)