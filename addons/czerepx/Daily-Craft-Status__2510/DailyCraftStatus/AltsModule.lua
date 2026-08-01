local _addon = _G["DailyCraftStatus"]

local _module = {
	trackHirelings = true,
	trackAvA = true,
	trackCraftingSkills = true,
	initialized = false
}

local craftingData = {
	{NON_COMBAT_BONUS_BLACKSMITHING_LEVEL, NON_COMBAT_BONUS_BLACKSMITHING_HIRELING_LEVEL, "esoui/art/icons/mapkey/mapkey_smithy.dds" },
	{NON_COMBAT_BONUS_CLOTHIER_LEVEL, NON_COMBAT_BONUS_CLOTHIER_HIRELING_LEVEL, "esoui/art/icons/mapkey/mapkey_clothier.dds" },
	{NON_COMBAT_BONUS_WOODWORKING_LEVEL, NON_COMBAT_BONUS_WOODWORKING_HIRELING_LEVEL, "esoui/art/icons/mapkey/mapkey_woodworker.dds" },
	{NON_COMBAT_BONUS_ENCHANTING_LEVEL, NON_COMBAT_BONUS_ENCHANTING_HIRELING_LEVEL, "esoui/art/icons/mapkey/mapkey_enchanter.dds" }, 
	{NON_COMBAT_BONUS_PROVISIONING_LEVEL, NON_COMBAT_BONUS_PROVISIONING_HIRELING_LEVEL, "esoui/art/icons/mapkey/mapkey_inn.dds" },
	{NON_COMBAT_BONUS_JEWELRYCRAFTING_LEVEL, 0, "esoui/art/icons/mapkey/mapkey_jewelrycrafting.dds" },
	{NON_COMBAT_BONUS_ALCHEMY_LEVEL, 0, "esoui/art/icons/mapkey/mapkey_alchemist.dds" }, 
	}	

local allianceData = { 
	[ALLIANCE_ALDMERI_DOMINION] = {
		"esoui/art/guild/guildbanner_icon_aldmeri.dds",
		"esoui/art/mappins/ava_largekeep_aldmeri.dds",
		"esoui/art/mappins/ava_borderkeep_pin_aldmeri.dds",
		}, 
	[ALLIANCE_EBONHEART_PACT] = {
		"esoui/art/guild/guildbanner_icon_ebonheart.dds",
		"esoui/art/mappins/ava_largekeep_ebonheart.dds", 
		"esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds",
		},
	[ALLIANCE_DAGGERFALL_COVENANT] = {
		"esoui/art/guild/guildbanner_icon_daggerfall.dds",
		"esoui/art/mappins/ava_largekeep_daggerfall.dds",
		"esoui/art/mappins/ava_borderkeep_pin_daggerfall.dds",
		},
	}

-- esoui/art/miscellaneous/new_icon.dds (exclamation mark)
-- esoui/art/miscellaneous/timer_32.dds (hourglass)

--  campaign data is not available unless it's your home/assigned/active campaign, so save it

local function DCS_updateCampaignScores(id)
	local vars = DailyCraftStatusVars
	if not vars then return end

	local underdogLeaderAlliance = GetCampaignUnderdogLeaderAlliance(id)
	local scores = {}
	local totKeeps = 0
	local maxScore = 0
	scores.timeStamp = GetTimeStamp()
	scores.timeToReset = GetTimeStamp() + GetSecondsUntilCampaignEnd(id)
	for i,_ in pairs(allianceData) do
		local score = GetCampaignAllianceScore(id, i)
		if score > maxScore then 
			maxScore = score
			scores.leaderId = i
		end	
		local keeps = GetTotalCampaignHoldings(id, HOLDINGTYPE_KEEP, i)
		local resources = GetTotalCampaignHoldings(id, HOLDINGTYPE_RESOURCE, i)
		local outposts = GetTotalCampaignHoldings(id, HOLDINGTYPE_OUTPOST, i)
		local defensiveScrolls = GetTotalCampaignHoldings(id, HOLDINGTYPE_DEFENSIVE_ARTIFACT, i)
		local offensiveScrolls = GetTotalCampaignHoldings(id, HOLDINGTYPE_OFFENSIVE_ARTIFACT, i)
		local potentialScore = GetCampaignAlliancePotentialScore(id, i)
		local isUnderpop = IsUnderpopBonusEnabled(id, i)

		local hasAllNativeKeeps, numEnemyKeeps, numNativeKeeps, totalNativeKeeps, numEdgeKeepBonusesActive = GetAvAKeepScore(id,i)
		local m = 0
		if hasAllNativeKeeps then m = m + 5 end
		if numEdgeKeepBonusesActive > 0 then m = m + 8 * numEdgeKeepBonusesActive end
		if numEnemyKeeps > 0 then m = m + 7 + (numEnemyKeeps-1) end

		scores[i] = {
			alliance = i,
			score = score,
			keeps = keeps,
			resources = resources,
			outposts = outposts,
			offensiveScrolls = offensiveScrolls,
			defensiveScrolls = defensiveScrolls,
			scrolls = defensiveScrolls + offensiveScrolls,
			potentialScore = potentialScore,
			isUnderdog = underdogLeaderAlliance ~= 0 and underdogLeaderAlliance ~= i,
			isUnderpop = isUnderpop,
			apBonus = m,
		}
		totKeeps = totKeeps + keeps
	end	
	if totKeeps > 0 then
		if not vars.campaignScores then vars.campaignScores = {} end
		local serverName = GetWorldName()
		if not vars.campaignScores[serverName] then vars.campaignScores[serverName] = {} end
		vars.campaignScores[serverName][id] = scores
	end	
end

local function DCS_getCampaignScores(campaignId)
	local scores
	local vars = DailyCraftStatusVars
	if vars then
		if vars.campaignScores then
			local serverName = GetWorldName()
			if vars.campaignScores[serverName] then
				scores = vars.campaignScores[serverName][campaignId]
			end
		end	
	end
	return scores or {}
end

local function DCS_findBestCampaignScores(allianceId)
	local scores
	local vars = DailyCraftStatusVars

	local function campaignEval(s)
		local eval = s[allianceId].keeps + s[allianceId].apBonus
		if s[allianceId].isUnderpop then eval = eval + 100 end
		if s[allianceId].isUnderdog then eval = eval + 100 end
		return eval
	end

	if vars then
		if vars.campaignScores then
			local serverName = GetWorldName()
			if vars.campaignScores[serverName] then
				for id,s in pairs(vars.campaignScores[serverName]) do
					local tdiff = (GetTimeStamp() - s.timeStamp) / 60
					if tdiff < 30 then
						if not scores then 
							scores = s
							scores.id = id
						else
							if campaignEval(s) > campaignEval(scores) then 
								scores = s
								scores.id = id
							end	
						end
					end	
				end
			end
		end	
	end
	return scores or {}
end

local function DCS_formatAllianceScores(allianceId,characterId)
	local avaInfo = ""
	local vars = DailyCraftStatusVars

	local charAvA = {}
	if characterId then
		local charSettings = _addon.accountSettings[characterId] or {}
		charAvA = charSettings.AvAStatus or {}
	end	
	
	if vars then
		if vars.campaignScores then
			local serverName = GetWorldName()
			if vars.campaignScores[serverName] then
				for id,campaignScores in pairs(vars.campaignScores[serverName]) do
					if not charAvA.allowedCampaigns or charAvA.allowedCampaigns[id] then
						if not campaignScores.timeToReset or campaignScores.timeToReset > GetTimeStamp() then
							if avaInfo~="" then avaInfo = avaInfo .. "\n" end
							if campaignScores.timeStamp then
								local tdiff = (GetTimeStamp() - campaignScores.timeStamp) / 60
								local icon = "|t20:20:esoui/art/miscellaneous/timer_32.dds|t"
								if tdiff > 60 then 
									avaInfo = avaInfo .. string.format("?? %s%dh ",icon,tdiff / 60)
								elseif tdiff > 5 then 
									avaInfo = avaInfo .. string.format("? %s%dm ",icon,tdiff)
								end
							end
							avaInfo = avaInfo .. GetCampaignName(id)
							avaInfo = avaInfo .. "\n"
							local scores = campaignScores[allianceId]
							local icon1 = allianceData[allianceId][2] or ""
							local icon2 = "esoui/art/currency/alliancepoints.dds"
							avaInfo = avaInfo .. string.format("  |t24:24:%s|t%d    |t16:16:%s|t%d%%    %d+%d",
							  icon1,(scores.keeps or 0),icon2,(scores.apBonus or 0),scores.score,scores.potentialScore)

							if scores.isUnderpop then	
								avaInfo = avaInfo .. " |t24:24:esoui/art/campaign/campaignbrowser_hipop.dds|t"
							end
							if scores.isUnderdog then	
								avaInfo = avaInfo .. " |t24:24:esoui/art/ava/overview_icon_underdog_score.dds|t"  
							end
							if campaignScores.leaderId==allianceId then 
								avaInfo = avaInfo .. " (*)"
							end
						end	
					end
				end
			end
		end	
	end
	return avaInfo
end

local function DCS_formatCampaignScores()
	local avaInfo = ""
	local vars = DailyCraftStatusVars
	if vars then
		if vars.campaignScores then
			local serverName = GetWorldName()
			if vars.campaignScores[serverName] then

				--for campaignId,campaignScores in pairs(vars.campaignScores[serverName]) do

				for i = 1, GetNumSelectionCampaigns() do
					local campaignId = GetSelectionCampaignId(i)
					local campaignScores = vars.campaignScores[serverName][campaignId]
					if campaignScores then
						if not campaignScores.timeToReset or campaignScores.timeToReset > GetTimeStamp() then
							if avaInfo~="" then avaInfo = avaInfo .. "\n" end
							if campaignScores.timeStamp then
								local tdiff = (GetTimeStamp() - campaignScores.timeStamp) / 60
								local icon = "|t20:20:esoui/art/miscellaneous/timer_32.dds|t"
								if tdiff > 60 then 
									avaInfo = avaInfo .. string.format("?? %s%dh ",icon,tdiff / 60)
								elseif tdiff > 5 then 
									avaInfo = avaInfo .. string.format("? %s%dm ",icon,tdiff)
								end
							end
							avaInfo = avaInfo .. GetCampaignName(campaignId)
							for allianceId,_ in pairs(allianceData) do
								if avaInfo~="" then avaInfo = avaInfo .. "\n" end
								local scores = campaignScores[allianceId]
								local icon1 = allianceData[allianceId][2] or ""
								local icon2 = "esoui/art/currency/alliancepoints.dds"
								avaInfo = avaInfo .. string.format("|t24:24:%s|t%d    |t16:16:%s|t%d%%    %d+%d",
								  icon1,(scores.keeps or 0),icon2,(scores.apBonus or 0),scores.score,scores.potentialScore)

								if scores.isUnderpop then	
									avaInfo = avaInfo .. " |t20:20:esoui/art/campaign/campaignbrowser_hipop.dds|t"
								end
								if scores.isUnderdog then	
									--esoui/art/campaign/overview_indexicon_scoring_down.dds
									avaInfo = avaInfo .. " |t20:20:esoui/art/ava/overview_icon_underdog_score.dds|t" 
								end
								if campaignScores.leaderId==allianceId then 
									avaInfo = avaInfo .. " (*)"
								end
							end	
						end	
					end
				end
			end
		end	
	end
	return avaInfo
end

local function DCS_updateRandomRewardTime(fromActDonef)
	local cs = _addon.characterSettings

--since Update 37 there is actually no cooldown anymore	

	local nextRewardTime = GetTimeStamp() + GetLFGCooldownTimeRemainingSeconds(LFG_COOLDOWN_DUNGEON_REWARD_GRANTED)
	if cs.randomRewardTime==nil then
		cs.randomRewardTime = nextRewardTime
	else
		if cs.randomRewardTime < nextRewardTime then
			cs.randomRewardTime = nextRewardTime
		end	
	end
end

function _module.saveStatus()
	local cs = _addon.characterSettings

	if cs.dailyFirstLogin==nil then
		cs.dailyFirstLogin = GetTimeStamp()
	else
		local tdiff = _addon.lastDailyReset() - cs.dailyFirstLogin
		if tdiff > 0 then cs.dailyFirstLogin = GetTimeStamp() end	
	end

	DCS_updateRandomRewardTime()

	-- last12hFirstLogin stores earliest login in last 12h slot
	-- obsolete since Update 37
	if cs.last12hFirstLogin==nil then
		cs.last12hFirstLogin = GetTimeStamp()
	else
		local tdiff = GetTimeStamp() - cs.last12hFirstLogin
		if tdiff > 12*3600 then cs.last12hFirstLogin = GetTimeStamp() end	
	end
	if cs.last24hFirstLogin==nil then
		cs.last24hFirstLogin = GetTimeStamp()
	else
		local tdiff = GetTimeStamp() - cs.last24hFirstLogin
		if tdiff > 24*3600 then cs.last24hFirstLogin = GetTimeStamp() end	
	end


	if _module.trackCraftingSkills then
		local ts = {}
		for i = 1, 7 do
			ts[i] = GetNonCombatBonus(craftingData[i][1])
		end	
		cs.craftingSkills = ts
	end	

	if _module.trackHirelings then
		local hs = {}
		for i = 1, 5 do
			hs[i] = GetNonCombatBonus(craftingData[i][2])
		end	
		cs.hirelingLevels = hs
	end	

	if _module.trackAvA then 
		local ava = cs.AvAStatus or {}
		local campaignId = GetAssignedCampaignId()
		if ava.campaignId~=campaignId then ava = {} end	
		if ava.campaignEndTime then
			if GetTimeStamp() > ava.campaignEndTime then ava = {} end
		end	
		ava.campaignId = campaignId
		ava.freeReassigns = GetNumFreeAnytimeCampaignReassigns()
		if campaignId then
			local secsToEnd = GetSecondsUntilCampaignEnd(campaignId) 
			if secsToEnd > 0 then
				ava.campaignEndTime = GetTimeStamp() + GetSecondsUntilCampaignEnd(campaignId) 
			end	
			local rt = { GetPlayerCampaignRewardTierInfo(campaignId) }
			-- do not assign results if info returned is invalid...
			if (rt[1] and rt[1]>0) or (rt[3] and rt[3]>1) then
				ava.rewardTierInfo = rt
			end
			DCS_updateCampaignScores(campaignId)
			if IsInCampaign() then
				local activeId = GetCurrentCampaignId()
				if activeId and activeId~=campaignId then DCS_updateCampaignScores(activeId) end;
			end	
		end	
		
		local allianceId = GetUnitAlliance("player")
		ava.allowedCampaigns = {} 
		for i = 1, GetNumSelectionCampaigns() do
			local id = GetSelectionCampaignId(i)
			local lockedTo = GetSelectionCampaignCurrentAllianceLock(i)
			if lockedTo==0 or lockedTo==allianceId then
				if DoesPlayerMeetCampaignRequirements(id) then
					ava.allowedCampaigns[id] = true
				end	
			end	
		end
		
		cs.AvAStatus = ava
	end	
end

local function DCS_canTrainAltRiding(characterId)
	local charSettings = _addon.accountSettings[characterId]
	if charSettings then
		rs = charSettings.ridingStats
		if rs then
			if (rs.s1==rs.max1 and rs.s2==rs.max2 and rs.s3==rs.max3) then return false,0 end
			if rs.timeToTrain ~= nil then
				if rs.timeToTrain < GetTimeStamp() then return true end
				local tdiff = rs.timeToTrain - GetTimeStamp()
				return false,tdiff
			end	
		end
	end
	return nil,nil
end

local function DCS_canStartAltDailyWrits(characterId)
	local charSettings = _addon.accountSettings[characterId]
	if charSettings then
		local lastCraft = charSettings.lastCraftAdded
		if lastCraft==nil then return true end
		if lastCraft > _addon.lastDailyReset() then return false end	
	end
	return true
end

local function DCS_timeToRandomReward(characterId)
	local charSettings = _addon.accountSettings[characterId] or {}
	if charSettings.randomRewardTime==nil then return nil end
	local tdiff = 0
	if charSettings.randomRewardTime then tdiff = charSettings.randomRewardTime - GetTimeStamp() end
	if tdiff<0 then tdiff = 0 end
	return tdiff
end

local function DCS_timeToAltHirelings(characterId)
	local charSettings = _addon.accountSettings[characterId]
	local found12h,found24h
	local tdiff,tdiff12,tdiff24
	local h12 = {}
	local h24 = {}

-- Update 37 has unified most reset timers
-- hireling mail now resets daily and is not based on character login time anymore
-- 12h mail is now "double quantity" hireling
-- 24h mail is now "regular quantity" hireling

	if charSettings then
		local hs = charSettings.hirelingLevels or {}
		for i,hlev in pairs(hs) do
			if hlev==3 then h12[#h12+1] = i end
			if hlev>0 and hlev<3 then h24[#h24+1] = i end
		end
		found12h = #h12 > 0
		found24h = #h24 > 0

                if charSettings.dailyFirstLogin then
			local tcycle = 24 * 3600
			tdiff = charSettings.dailyFirstLogin - _addon.lastDailyReset()
			if  tdiff<0 then 
				tdiff = 0 
			else
				tdiff = tcycle - (GetTimeStamp() - _addon.lastDailyReset())
			end

			if found12h then tdiff12 = tdiff end	
			if found24h then tdiff24 = tdiff end
		end	
	end 
	return tdiff12, tdiff24, h12, h24
end

local function DCS_formatAvAInfo(characterId,allianceId)
	local avaInfo = ""
	local ava = {}
	local charSettings = _addon.accountSettings[characterId] or {}
	local ava = charSettings.AvAStatus or {} 
	local grayColor = ZO_ColorDef:New("606060")
	
	local function appendScores(campaignId,scores,rewardf)
		avaInfo = avaInfo .. string.sub(GetCampaignName(campaignId),1,3)
	
		local keepsHeld = scores[allianceId].keeps or 0
		if keepsHeld > 0 then
			avaInfo = avaInfo .. string.format(" %d",keepsHeld) 
		end
		if rewardf then avaInfo = grayColor:Colorize(avaInfo) end
		if scores[allianceId].apBonus and scores[allianceId].apBonus >= 10 then
			avaInfo = avaInfo .. string.format(" |c00B000%d%%|r",(scores[allianceId].apBonus or 0))
		end	
		if scores[allianceId].isUnderpop then			
			avaInfo = avaInfo .. " |t20:20:esoui/art/campaign/campaignbrowser_hipop.dds|t"
		end
		if scores[allianceId].isUnderdog then	
			avaInfo = avaInfo .. " |t20:20:esoui/art/ava/overview_icon_underdog_score.dds|t"
		end
		if scores.leaderId==allianceId then	
			avaInfo = avaInfo .. "*"
		end
		if scores.timeStamp then
			local tdiff = (GetTimeStamp() - scores.timeStamp) / 60
			if tdiff > 60 then 
				avaInfo = avaInfo .. " ??"
			elseif tdiff > 5 then 
				avaInfo = avaInfo .. " ?"
			end
		end
	end

	if ava.campaignId then
		local scores = DCS_getCampaignScores(ava.campaignId)
		if not scores[allianceId] then scores[allianceId] = {} end

		local filler = "|t16:16:blank.dds|t"
		local medal = "|t16:16:esoui/art/ava/ava_medal.dds|t"
		local rewardf = false
		local progressf = false

		avaInfo = filler
		if ava.rewardTierInfo then
			if ava.rewardTierInfo[1] then
				if ava.rewardTierInfo[1] > 0 then
					avaInfo = medal
					avaInfo = avaInfo .. ava.rewardTierInfo[1]
					rewardf = true
				end	
			end
			if ava.rewardTierInfo[1]==0 and ava.rewardTierInfo[3]==1 then --data not available yet
				avaInfo = avaInfo .. "-"
			else	
				if ava.rewardTierInfo[1] and ava.rewardTierInfo[1]==0 then
					if ava.rewardTierInfo[2] and ava.rewardTierInfo[2] > 0 then
						avaInfo = avaInfo .. "+"
						progressf = true
					end	
				end	
			end	
		end
		avaInfo = avaInfo .. "  "
		--avaInfo = avaInfo .. string.format(" |t24:24:%s|t",(allianceData[allianceId][3] or "")) 

		appendScores(ava.campaignId,scores,rewardf)

		if not rewardf and not progressf then
			if ava.freeReassigns and ava.freeReassigns>0 then
				scores = DCS_findBestCampaignScores(allianceId)
				if scores.id and scores.id~=ava.campaignId then
					avaInfo = avaInfo .. " -> "
					appendScores(scores.id,scores)
				end	
			end	
		end	
		
	end
	--if avaInfo=="" then avaInfo = "?" end
	return avaInfo
end

local function DCS_formatCraftingSkillInfo(characterId, fromHirelings)
	local charSettings = _addon.accountSettings[characterId] or {}
	if charSettings.craftingSkills==nil then return "" end
	local s = ""
	
	local skills = {}
	if fromHirelings then
		skills = fromHirelings
	else
		for i=1, #craftingData do skills[i] = i end
	end
	
	for i=1, #skills do
		if skills[i]~=nil then
			local skillLev = ""
			if charSettings.craftingSkills then
				skillLev = charSettings.craftingSkills[skills[i]] or ""
			end	
			s = s .. string.format("|t24:24:%s|t%s ",craftingData[skills[i]][3],skillLev)
		end	
	end
	return s
end

local function DCS_formatRidingInfo(characterId)
	local charSettings = _addon.accountSettings[characterId] or {}
	local rs = charSettings.ridingStats
	local s = ""
	if rs then
		s = s .. string.format("|t20:20:esoui/art/mounts/ridingskill_capacity.dds|t%d/%d  ",rs.s1,rs.max1)
		s = s .. string.format("|t20:20:esoui/art/mounts/ridingskill_stamina.dds|t%d/%d  ",rs.s2,rs.max2)
		s = s .. string.format("|t20:20:esoui/art/mounts/ridingskill_speed.dds|t%d/%d  ",rs.s3,rs.max3)
	end
	
	return s
end

local C_BLANKS = "                    "

local function DCS_setCustomStatus(control,text)
	local row = control:GetParent()
	if row.data and control.data then
		if row.data.characterId then 
			--if not _addon.accountSettings[row.data.characterId] then _addon.accountSettings[row.data.characterId] = {} end
			local charSettings = _addon.accountSettings[row.data.characterId]
			if charSettings then			
				--if not control.data.orgText then control.data.orgText = control:GetText() end
				control:SetText(text)
				if not charSettings.statusText then charSettings.statusText = {} end
				if text==control.data.orgText then
					charSettings.statusText[control.data.shortName] = nil
				else	
					charSettings.statusText[control.data.shortName] = text
				end
			end	
		end
	end	
end

local function labelRightClicked(control,button)
	if button~=MOUSE_BUTTON_INDEX_RIGHT then return end
	if control:GetText()==C_BLANKS then
		DCS_setCustomStatus(control,control.data.orgText)
	else	
		DCS_setCustomStatus(control,C_BLANKS)
	end	
end

local function labelDblClicked(control,button)
	if button==MOUSE_BUTTON_INDEX_RIGHT then return end
	local editBox = control.editBox
	editBox.control = control
	local text = control:GetText()
	if text==control.data.orgText then
		editBox:SetText("")
	else
		editBox:SetText(text)
	end
	editBox.setVisible(true)
	editBox:TakeFocus()
	editBox:SelectAll()
end

local function customStatusConfirmed(editBox)
	if not editBox.control then return end
	local text = editBox:GetText()
	if text=="" then
		DCS_setCustomStatus(editBox.control,editBox.control.data.orgText)
	else
		DCS_setCustomStatus(editBox.control,text)
	end
	editBox.setVisible(false)
	editBox.control = nil
end

local function customStatusCancelled(editBox)
	editBox.setVisible(false)
	editBox.control = nil
end

local function formatTime(secs)
	local s = ""
	local dh = math.floor(secs / 3600)
	local dm = math.floor((secs - dh*3600) / 60)
	s = string.format(" %dh%02d",dh,dm)
	if dh >=8 then	
		s = "|c282828" .. s
	elseif dh >= 1 then 
		s = "|c808080" .. s
	end	
	return s
end	

function _module.showStatus()

	--force update for current character
	_addon.saveCharStatus()
	
	--local accSettings = _addon.accountSettings
	
	local statusWnd = DailyCraftStatusAltsWindow

	statusWnd:GetNamedChild("Title"):SetText(_addon._translate("Alts Status"))

	local editBox = statusWnd:GetNamedChild("EditBox")
	editBox.bg = statusWnd:GetNamedChild("EditBoxBG")
	editBox.setVisible = function(show) editBox:SetHidden(not show); editBox.bg:SetHidden(not show) end
	editBox:SetHandler("OnEnter", function(...) customStatusConfirmed(...) end)
	editBox:SetHandler("OnEscape", function(...) customStatusCancelled(...) end)
	editBox:SetHandler("OnFocusLost", function(...) customStatusCancelled(...) end)
	editBox:SetMaxInputChars(40)
	

	local list = WINDOW_MANAGER:GetControlByName("DailyCraftStatusAltsWindowList")
	list:SetHidden(false)
	for i = 1, list:GetNumChildren() do
		list:GetChild(i):SetHidden(true)
	end

	local dkGrayColor = ZO_ColorDef:New("282828")
	local isz = 24 
	local row, label
	
	local function setLabelText(name,text,tooltip,align,clickable)
		label = row:GetNamedChild(name)
		label:SetText(text)
		label.data = {shortName=name,orgText=text,tooltipText=tooltip}
		if row.data and (clickable or clickable==nil) then
			if row.data.characterId then 
				local charSettings = _addon.accountSettings[row.data.characterId] 
				if charSettings then
					if charSettings.statusText then
						if charSettings.statusText[name] then
							label:SetText(charSettings.statusText[name])
						end	
					end
					label.editBox = editBox
					label:SetHandler("OnMouseUp",function (...) labelRightClicked(...) end)
					label:SetHandler("OnMouseDoubleClick",function (...) labelDblClicked(...) end)
				end	
			end	
		end
		if tooltip then 
			label:SetHandler("OnMouseEnter",function (...) _addon.showTooltip(...) end)
			label:SetHandler("OnMouseExit", function () ZO_Tooltips_HideTextTooltip() end)
		end
		if align~=nil then label:SetHorizontalAlignment(align) end
		label:SetHidden(false)
	end	
	
	row = WINDOW_MANAGER:GetControlByName("DailyCraftStatusAltsWindowHeader")
	if not row then
		row = CreateControlFromVirtual("DailyCraftStatusAltsWindowHeader", list, "DailyCraftStatusAltRowTemplate")
	end
	setLabelText("Status2","|c808080|t16:16:esoui/art/icons/mapkey/mapkey_stables.dds:inheritcolor|t|r")
	if _module.trackHirelings then
		setLabelText("Status3","|c808080|t16:16:esoui/art/chatwindow/chat_mail_up.dds:inheritcolor|t|r2x","",TEXT_ALIGN_CENTER)
		setLabelText("Status4","|c808080|t16:16:esoui/art/chatwindow/chat_mail_up.dds:inheritcolor|t|r1x","",TEXT_ALIGN_CENTER)
	end	
	setLabelText("Status5","|cA02EF7|t20:20:esoui/art/lfg/lfg_indexicon_dungeon_down.dds:inheritcolor|t|r")
	if _module.trackAvA then
		local as = ""
		for aId,aData in pairs(allianceData) do
			as = as .. string.format("|t32:32:%s|t",aData[3])
		end	
		setLabelText("ExtraInfo",as,DCS_formatCampaignScores())
		
		--setLabelText("ExtraInfo","|t24:24:esoui/art/mappins/ava_largekeep_neutral.dds|t",DCS_formatCampaignScores())
	end	
	setLabelText("CustomText","|t22:22:esoui/art/contacts/social_note_up.dds:inheritcolor|t|r")
	row:SetAnchor(TOPLEFT, list, TOPLEFT, 2, 20)
	row:GetNamedChild("Divider"):SetHidden(false)
	row:SetHidden(false)
	
	local lastrow = 0
	local mintdiff12 = 0
	local mintdiff24 = 0
	
	for i = 1, GetNumCharacters() do
		row = WINDOW_MANAGER:GetControlByName("DailyCraftStatusAltsWindowRow" .. i)
		if not row then
			row = CreateControlFromVirtual("DailyCraftStatusAltsWindowRow" .. i, list, "DailyCraftStatusAltRowTemplate")
		end
		for j = 1, row:GetNumChildren() do
			row:GetChild(j):SetHidden(true)
		end
		lastrow = i

		local charName, _, _, _, _, allianceId, characterId = GetCharacterInfo(i)
		--strip the grammar markup
		charName = zo_strformat("<<1>>", charName)
		row.data = { characterId = characterId }
		
		if characterId == GetCurrentCharacterId() then
			charName = "|c808080"..charName
		end	
		setLabelText("Name",charName,nil,nil,false)

		local icon = allianceData[allianceId][1] or ""
		setLabelText("Alliance","|t16:16:" .. icon .. "|t",nil,nil,false)

		local sItem = ""
		local sTooltip = ""

		sItem = string.format("|t%d:%d:%s:inheritColor|t",isz,isz,"esoui/art/compass/repeatablequest_icon_assisted.dds")
		if not DCS_canStartAltDailyWrits(characterId) then
			sItem = dkGrayColor:Colorize(sItem)
		end	
		setLabelText("Status1",sItem,DCS_formatCraftingSkillInfo(characterId))

		local canTrain, tdiff = DCS_canTrainAltRiding(characterId)
		if canTrain==nil or (not canTrain and tdiff==0) then
			sItem = ""
		else	
			sItem = string.format("|t%d:%d:%s:inheritColor|t",isz-4,isz-4,"esoui/art/icons/mapkey/mapkey_stables.dds")
			if not canTrain then
				sItem = dkGrayColor:Colorize(sItem)

				local s = ""
				if tdiff~=nil and tdiff > 0  then
					s = formatTime(tdiff)
				end	
				--sItem = sItem .. s
				sItem = s
			end
		end	
		setLabelText("Status2",sItem,DCS_formatRidingInfo(characterId))
	
		if _module.trackHirelings then
			local tdiff12, tdiff24, h12, h24 = DCS_timeToAltHirelings(characterId)
			sItem = ""
			if tdiff12~=nil then
				sItem = string.format("|t%d:%d:%s:inheritColor|t",isz,isz,"esoui/art/chatwindow/chat_mail_up.dds")
				if tdiff12 > 0 then
					sItem = dkGrayColor:Colorize(sItem)
				end	
			end	
			setLabelText("Status3",sItem,DCS_formatCraftingSkillInfo(characterId,h12))

			sItem = ""
			if tdiff24~=nil then
				sItem = string.format("|t%d:%d:%s:inheritColor|t",isz,isz,"esoui/art/chatwindow/chat_mail_up.dds")
				if tdiff24 > 0 then
					sItem = dkGrayColor:Colorize(sItem)
				end	
			end	
			setLabelText("Status4",sItem,DCS_formatCraftingSkillInfo(characterId,h24))
		end
		

		sItem = string.format("|t%d:%d:%s:inheritColor|t",isz,isz,"esoui/art/lfg/lfg_indexicon_dungeon_up.dds")
		sTooltip = ""
		local tdiffrand = DCS_timeToRandomReward(characterId)
		if tdiffrand==nil then
			sItem = ""
		else
			if tdiffrand > 0 then	
				sItem = formatTime(tdiffrand)
				sTooltip = "@ "..os.date("%H:%M",GetTimeStamp()+tdiffrand)
				--sItem = dkGrayColor:Colorize(sItem)
			end	
		end	
		setLabelText("Status5",sItem,sTooltip)
		
		
		if _module.trackAvA then
			sItem = ""
			sItem,tooltip = DCS_formatAvAInfo(characterId,allianceId)
			setLabelText("ExtraInfo",sItem,DCS_formatAllianceScores(allianceId,characterId))
		end	

		setLabelText("CustomText","-")

		row:SetAnchor(TOPLEFT, list, TOPLEFT, 2, 20 + i * 20)
		row:GetNamedChild("Divider"):SetHidden(false)
		row:SetHidden(false)
	end

--obsolete since Update 37, reset time is fixed now

	if false and mintdiff12~=0 then
		row = WINDOW_MANAGER:GetControlByName("DailyCraftStatusAltsWindowRowFooter")
		if not row then
			row = CreateControlFromVirtual("DailyCraftStatusAltsWindowRowFooter", list, "DailyCraftStatusAltRowTemplate")
		end
		setLabelText("Status3",string.format("(%s)", os.date("%H:%M",GetTimeStamp()+mintdiff12)))
	
		lastrow = lastrow + 1
		row:SetAnchor(TOPLEFT, list, TOPLEFT, 2, 20 + lastrow * 20)
		row:SetHidden(false)
	end	

	local h = 20 + lastrow * 20
	list:SetHeight(h)
	DailyCraftStatusAltsWindowList:SetHeight(h+32)
	DailyCraftStatusAltsWindow:SetHeight(h+52)
	DailyCraftStatusAltsWindowBG:SetHeight(h+52)
	DailyCraftStatusAltsWindow:SetHidden(false)
end


function _module.initialize()
	if _module.initialized then return end
	if _module.trackAvA then
		RegisterForAssignedCampaignData()
		QueryCampaignLeaderboardData()
		QueryCampaignSelectionData()
	end	
	
	EVENT_MANAGER:RegisterForEvent(_addon.name, EVENT_ACTIVITY_FINDER_ACTIVITY_COMPLETE, function(...) DCS_updateRandomRewardTime(true) end, false )
	
	--EVENT_MANAGER:RegisterForEvent(_addon.name, EVENT_LOGOUT_DEFERRED, function(_,quitRequested) if (quitRequested) then _module.saveStatus() end end, false )

	_module.initialized = true
end	

_addon.altsModule = _module