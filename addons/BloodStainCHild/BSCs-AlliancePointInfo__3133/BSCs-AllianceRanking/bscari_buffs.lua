BSCAllianceRanking = BSCAllianceRanking or {}
local BSCARI = BSCAllianceRanking

local KEEP_BONUSAP = 0
local BUFF_BONUSAP = 0
local RANK_BONUSAP = 0
local LOWPOP_BONUSAP = 0
local LOWSCORE_BONUSAP = 0

-- Buff ID's
local AP_BUFFLIST = { }
local function CreateList()
	AP_BUFFLIST = { }	
	AP_BUFFLIST[66282] = { buffendtime = -1, group = 0, percent = 20, isRankBonus = false, soundAlert = false, flagtick = -1, UIShown = false }		-- 20% NPC BOSS		
	AP_BUFFLIST[92232] = { buffendtime = -1, group = 1, percent = 100, isRankBonus = false, soundAlert = false, flagtick = -1, UIShown = false }	-- Pelinal's Ferocity 100%		
	-- Buff Food	
	AP_BUFFLIST[147687] = { buffendtime = -1, group = 2, percent = 50, isRankBonus = true, soundAlert = false, flagtick = -1, UIShown = false }	 	-- 50% scroll		147687	x
	AP_BUFFLIST[147733] = { buffendtime = -1, group = 2, percent = 100, isRankBonus = true, soundAlert = false, flagtick = -1, UIShown = false }	-- 100% scroll		147733	x
	AP_BUFFLIST[147734] = { buffendtime = -1, group = 2, percent = 150, isRankBonus = true, soundAlert = false, flagtick = -1, UIShown = false }	-- 150% scroll		147734	x	
	-- Krown Store
	AP_BUFFLIST[147466] = { buffendtime = -1, group = 2, percent = 50, isRankBonus = true, soundAlert = false, flagtick = -1, UIShown = false }		-- 50% Store		147466	x
	AP_BUFFLIST[137733] = { buffendtime = -1, group = 2, percent = 100, isRankBonus = true, soundAlert = false, flagtick = -1, UIShown = false }	-- 100% Store		137733	x
	AP_BUFFLIST[147467] = { buffendtime = -1, group = 2, percent = 150, isRankBonus = true, soundAlert = false, flagtick = -1, UIShown = false }	-- 150% Store		147467 	x
	-- -- -- Unknown?
	AP_BUFFLIST[147797] = { buffendtime = -1, group = 3, percent = 150, isRankBonus = false, soundAlert = false, flagtick = -1, UIShown = false }	-- 150% 				?	
end
-- UI
function BSCARI:OnMoveStop()
	BSCARI.SVA.SETTING[BSCARI.CurrentCharID].offsetX = BSCAllianceRankingBuffInfoUI:GetLeft()
	BSCARI.SVA.SETTING[BSCARI.CurrentCharID].offsetY = BSCAllianceRankingBuffInfoUI:GetTop()	
end
function BSCARI:RestorePosition()
	if BSCARI.SVA.SETTING[BSCARI.CurrentCharID].offsetX ~= 0 and BSCARI.SVA.SETTING[BSCARI.CurrentCharID].offsetY ~= 0 then
		BSCAllianceRankingBuffInfoUI:ClearAnchors()
		BSCAllianceRankingBuffInfoUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BSCARI.SVA.SETTING[BSCARI.CurrentCharID].offsetX, BSCARI.SVA.SETTING[BSCARI.CurrentCharID].offsetY)
	end
	BSCAllianceRankingBuffInfoUI:SetMovable(not BSCARI.SVA.SETTING[BSCARI.CurrentCharID].LOCK_UI)	
end
local function BPlaySound(str_sound)
	if not BSCARI.SVA.SETTING[BSCARI.CurrentCharID].PLAY_SOUND then return end
	PlaySound(str_sound)
end
local function UpdateUI()
	if BSCARI.ShouldShowBuffInfoUI and not BSCARI:ShouldShowBuffInfoUI() then
		if BSCARI.UpdateBuffInfoFragment then
			BSCARI:UpdateBuffInfoFragment()
		end
		return
	end

	local BUFF_BONUSAP = 0
	local BUFF_RANKAP = 0
	for abilityId, v in pairs(AP_BUFFLIST) do
		if v.buffendtime ~= -1 then
			if v.isRankBonus then
				BUFF_RANKAP = BUFF_RANKAP + v.percent
			else
				BUFF_BONUSAP = BUFF_BONUSAP + v.percent
			end
			local timediff = os.difftime(v.buffendtime, GetGameTimeSeconds()) -1
			local duration = ZO_FormatCountdownTimer(timediff)			
			if v.group == 0 then						
				BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_BOSS"):SetAlpha(1) 
				BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_BOSS_INFO"):SetText(zo_strformat("<<1>>", duration))
				BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_BOSS_PERCENT"):SetText(zo_strformat("<<1>>%", v.percent))
			elseif v.group == 1 then
			
			elseif v.group == 2 then
				BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_FOOD"):SetAlpha(1) 
				BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_FOOD_INFO"):SetText(zo_strformat("<<1>>", duration))
				BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_FOOD_PERCENT"):SetText(zo_strformat("<<1>>%", v.percent))
			else
				-- group 3
			end		
			if timediff > 10 and v.UIShown and not BSCAllianceRankingBuffInfoAlertUI:IsHidden() then
				BSCAllianceRankingBuffInfoAlertUI:SetHidden(true)
				AP_BUFFLIST[abilityId].flagtick = 5
				AP_BUFFLIST[abilityId].UIShown = false
			end
			if timediff <= 10 and BSCARI.SVA.SETTING[BSCARI.CurrentCharID].bAlertBuff then				
				BSCAllianceRankingBuffInfoAlertUI:GetNamedChild("BUFF_REMINDER_ALERT"):SetText(zo_strformat("Buff [<<1>>] Ending in <<2>> !!", GetAbilityName(abilityId), duration))
				BSCAllianceRankingBuffInfoAlertUI:SetHidden(false)
				AP_BUFFLIST[abilityId].UIShown = true
				if AP_BUFFLIST[abilityId].flagtick == timediff then
					AP_BUFFLIST[abilityId].flagtick = timediff -1
					BPlaySound(SOUNDS.COUNTDOWN_TICK)
				end
			end
			if timediff <= 0 then
				AP_BUFFLIST[abilityId].buffendtime = 0
			end
			if AP_BUFFLIST[abilityId].soundAlert and timediff == 60 then
				AP_BUFFLIST[abilityId].soundAlert = false
				BSCAllianceRankingBuffInfoAlertUI:GetNamedChild("BUFF_REMINDER_ALERT"):SetText(zo_strformat("Buff [<<1>>] Ending in <<2>> !!", GetAbilityName(abilityId), duration))
				BSCAllianceRankingBuffInfoAlertUI:SetHidden(false)
				zo_callLater(function() BSCAllianceRankingBuffInfoAlertUI:SetHidden(true) end, 4000)
				BPlaySound(SOUNDS.BATTLEGROUND_ONE_MINUTE_WARNING)
			end
		end
		if v.buffendtime == 0 then
			if v.group == 0 then							
				BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_BOSS"):SetAlpha(0.3) 
				BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_BOSS_INFO"):SetText(zo_strformat("<<1>>", 0))
				BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_BOSS_PERCENT"):SetText(zo_strformat("<<1>>%", 0))
			elseif v.group == 1 then
				
			elseif v.group == 2 then
				BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_FOOD"):SetAlpha(0.3) 
				BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_FOOD_INFO"):SetText(zo_strformat("<<1>>", 0))
				BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_FOOD_PERCENT"):SetText(zo_strformat("<<1>>%", 0))
			else
				-- group 3
			end
			AP_BUFFLIST[abilityId].buffendtime = -1
			AP_BUFFLIST[abilityId].flagtick = -1
			AP_BUFFLIST[abilityId].UIShown = false
			BSCAllianceRankingBuffInfoAlertUI:SetHidden(true)
			BPlaySound(SOUNDS.ANTIQUITIES_FANFARE_FAILURE)
		end
	end
	BSCAllianceRankingBuffInfoUI:GetNamedChild("lblHeader"):SetText(zo_strformat("AP Bonus Info (<<1>>%)", KEEP_BONUSAP + BUFF_BONUSAP + LOWPOP_BONUSAP + LOWSCORE_BONUSAP + RANK_BONUSAP + BUFF_RANKAP))
	BSCAllianceRankingBuffInfoUI:GetNamedChild("lblBottomKeep"):SetText(zo_strformat("Keeps Bonus: <<1>>%", KEEP_BONUSAP))
	BSCAllianceRankingBuffInfoUI:GetNamedChild("lblBottomBuff"):SetText(zo_strformat("Buff Bonus: <<1>>%", BUFF_BONUSAP + LOWSCORE_BONUSAP + LOWPOP_BONUSAP))
	BSCAllianceRankingBuffInfoUI:GetNamedChild("lblBottomRank"):SetText(zo_strformat("Rank Bonus: <<1>>%", RANK_BONUSAP + BUFF_RANKAP))
end

function BSCARI:RefreshBuffInfoNow()
	UpdateUI()
end

local function ToggleUI(oldState, newState)
	if BSCARI.UpdateBuffInfoFragment then
		BSCARI:UpdateBuffInfoFragment()
	end
end

local function CheckBuffs()
	for i = 1, GetNumBuffs('player')  do
		local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer = GetUnitBuffInfo('player', i)		
		if AP_BUFFLIST[abilityId] ~= nil then
			--d("Buff")
			AP_BUFFLIST[abilityId].buffendtime = timeEnding
			AP_BUFFLIST[abilityId].soundAlert = true
			if AP_BUFFLIST[abilityId].flagtick == -1 then			
				AP_BUFFLIST[abilityId].flagtick = 5
			end
		end		
	end	
end

-- Check Keep Bonus
local function GetEdgeKeepBonusScore(campaignId)
    return select(5, GetAvAKeepScore(campaignId, GetUnitAlliance("player")))
end

local function KeepsAPBonusInfo()
	local campaignID = GetCurrentCampaignId()
	if campaignID == 0 then
		campaignID = GetAssignedCampaignId()
	end

	local APBonusKeeps = 0	
	local allHomeKeepsHeld, enemyKeepsHeld, _, _, edgebonus = GetAvAKeepScore(campaignID, GetUnitAlliance("player"))
	if enemyKeepsHeld >= 10 then enemyKeepsHeld = 9 end
	-- Check Home Keeps
	local home_skillid = GetKeepScoreBonusAbilityId(1)
	if allHomeKeepsHeld == true then
		BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_KEEP_HOME"):SetTexture(GetAbilityIcon(home_skillid))
		BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_KEEP_HOME"):SetAlpha(1) 
		BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_KEEP_HOME_PERCENT"):SetText(zo_strformat("<<1>>%", 5))
		APBonusKeeps = APBonusKeeps + 5
	else
		BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_KEEP_HOME"):SetTexture(GetAbilityIcon(home_skillid))
		BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_KEEP_HOME"):SetAlpha(0.3) 
		BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_KEEP_HOME_PERCENT"):SetText(zo_strformat("<<1>>%", 0))
	end	
	-- Check Enemy Keeps
	local bonus_skillid = GetKeepScoreBonusAbilityId(2)
	if allHomeKeepsHeld and enemyKeepsHeld > 0 then
		local bonusapkeep = 6 + enemyKeepsHeld
		bonus_skillid = GetKeepScoreBonusAbilityId(enemyKeepsHeld+1)
		BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_KEEP"):SetTexture(GetAbilityIcon(bonus_skillid))
		BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_KEEP"):SetAlpha(1) 
		BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_KEEP_PERCENT"):SetText(zo_strformat("<<1>>%", bonusapkeep))
		APBonusKeeps = APBonusKeeps + bonusapkeep
	else -- 0%
		BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_KEEP"):SetTexture(GetAbilityIcon(bonus_skillid))
		BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_KEEP"):SetAlpha(0.3) 
		BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_KEEP_PERCENT"):SetText(zo_strformat("<<1>>%", 0))	
	end	
	-- Check Edge Keeps
	local egde_skillid = GetEdgeKeepBonusAbilityId(edgebonus)
	if edgebonus == 1 then -- 8%
		BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_KEEP_EDGE"):SetTexture(GetAbilityIcon(egde_skillid))
		BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_KEEP_EDGE"):SetAlpha(1) 
		BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_KEEP_EDGE_PERCENT"):SetText(zo_strformat("<<1>>%", 8))
		APBonusKeeps = APBonusKeeps + 8		
	elseif edgebonus == 2 then -- 16&
		BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_KEEP_EDGE"):SetTexture(GetAbilityIcon(egde_skillid))
		BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_KEEP_EDGE"):SetAlpha(1) 
		BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_KEEP_EDGE_PERCENT"):SetText(zo_strformat("<<1>>%", 16))
		APBonusKeeps = APBonusKeeps + 16		
	elseif edgebonus == 3 then -- 24%
		BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_KEEP_EDGE"):SetTexture(GetAbilityIcon(egde_skillid))
		BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_KEEP_EDGE"):SetAlpha(1) 
		BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_KEEP_EDGE_PERCENT"):SetText(zo_strformat("<<1>>%", 24))
		APBonusKeeps = APBonusKeeps + 24		
	else -- 0%
		BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_KEEP_EDGE"):SetTexture(GetAbilityIcon(GetEdgeKeepBonusAbilityId(1)))
		BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_KEEP_EDGE"):SetAlpha(0.3) 
		BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_KEEP_EDGE_PERCENT"):SetText(zo_strformat("<<1>>%", 0))		
	end
	KEEP_BONUSAP = APBonusKeeps
end

local function ResetEquipmentBonus()
	BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_ITEM"):SetAlpha(0.3)
	BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_ITEM_PERCENT"):SetText(zo_strformat("<<1>>%", 0))
	RANK_BONUSAP = 0
end

local function CheckEquipment()
	if not HasItemInSlot(BAG_WORN, EQUIP_SLOT_SHOULDERS) then
		ResetEquipmentBonus()
		return
	end

	local setId = select(6, GetItemLinkSetInfo(GetItemLink(BAG_WORN, EQUIP_SLOT_SHOULDERS)))
	if setId ~= 654 then
		ResetEquipmentBonus()
		return
	end

	local _, numCollections, categoryId = GetLoreCategoryInfo(1)
	local NKB = 0
	local NTB = 0
	for i = 1, numCollections do
		local _, _, numKnownBooks, totalBooks = GetLoreCollectionInfo(categoryId, i)
		NKB = NKB + (numKnownBooks or 0)
		NTB = NTB + (totalBooks or 0)
	end

	if NTB <= 0 then
		ResetEquipmentBonus()
		return
	end

	local percent = math.floor(((NKB * 100) / NTB) / 10)
	BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_ITEM"):SetAlpha(1)
	BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_ITEM_PERCENT"):SetText(zo_strformat("<<1>>%", percent))
	RANK_BONUSAP = percent
end

local function OnCombatEvent(_, result, _, _, _, _, _, _, targetName, _, hitValue, _, _, _, _, targetUnitId, abilityId, _)		
	if result == ACTION_RESULT_EFFECT_GAINED then -- 2240
		CheckBuffs()
	end	
	if result == ACTION_RESULT_EFFECT_FADED then -- 2250
		CheckBuffs()
	end
end

function BSCARI:CheckLowPoP()
	local campaignID = GetCurrentCampaignId()	
	local underdogLeaderAlliance = GetCampaignUnderdogLeaderAlliance(campaignID)
	local Alliance = GetUnitAlliance('player')
	local isUnderpop  = IsUnderpopBonusEnabled(campaignID, Alliance)
	local isUnderdog = underdogLeaderAlliance ~= 0 and underdogLeaderAlliance ~= Alliance
	if isUnderpop then
		LOWPOP_BONUSAP = 100
		BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_LOWPOP"):SetAlpha(1) 
		BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_LOWPOP_PERCENT"):SetText(zo_strformat("<<1>>%", 100))	
	else
		BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_LOWPOP"):SetAlpha(0.3) 
		BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_LOWPOP_PERCENT"):SetText(zo_strformat("<<1>>%", 0))	
		LOWPOP_BONUSAP = 0
	end
	if isUnderdog then
		LOWSCORE_BONUSAP = 100
		BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_SCORE"):SetAlpha(1) 
		BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_SCORE_PERCENT"):SetText(zo_strformat("<<1>>%", 100))
	else
		LOWSCORE_BONUSAP = 0
		BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_SCORE"):SetAlpha(0.3) 
		BSCAllianceRankingBuffInfoUI:GetNamedChild("BUFF_SCORE_PERCENT"):SetText(zo_strformat("<<1>>%", 0))
	end
end

-- INIT / Update
local bRegister = false
local function OnPlayerActivated()
	if BSCARI.UpdateBuffInfoFragment then
		BSCARI:UpdateBuffInfoFragment()
	end
	if IsInAvAZone() then
		BSCARI:RefreshBuffInfoVisibility()	
		KeepsAPBonusInfo()
		CheckBuffs()
		CheckEquipment()
		BSCARI:CheckLowPoP() -- /script 
		BSCARI:UpdateUISettingsBAR()
		-- No automatic campaign query here. Native campaign scenes manage their own requests.
	end
	
	if IsInAvAZone() and not bRegister then
		--d("bscari OnPlayerActivated")
		--if IsInCyrodiil() then 
		--if IsUnitPvPFlagged('player') then
		EVENT_MANAGER:RegisterForEvent(BSCARI.Name.."BUFF", EVENT_KEEP_ALLIANCE_OWNER_CHANGED, function() KeepsAPBonusInfo() end)
		EVENT_MANAGER:RegisterForEvent(BSCARI.Name.."BUFF", EVENT_OBJECTIVES_UPDATED, function() KeepsAPBonusInfo() end)
			
		for abilityId in pairs(AP_BUFFLIST) do
			local eventName = 'BSCARI_BUFF'..abilityId
			EVENT_MANAGER:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, OnCombatEvent)
			EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId)
			EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_UNIT_TAG, 'player')
		end
		-- ///////////////////////////////////////////// --- Equipment chekc -- //////////////////////////////////////////////
		-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		EVENT_MANAGER:RegisterForEvent(BSCARI.Name, EVENT_INVENTORY_FULL_UPDATE, function(...) CheckEquipment() end )
		EVENT_MANAGER:AddFilterForEvent(BSCARI.Name, EVENT_INVENTORY_FULL_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
		EVENT_MANAGER:AddFilterForEvent(BSCARI.Name, EVENT_INVENTORY_FULL_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)	
		-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		EVENT_MANAGER:RegisterForEvent(BSCARI.Name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(...) CheckEquipment() end )	
		EVENT_MANAGER:AddFilterForEvent(BSCARI.Name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
		EVENT_MANAGER:AddFilterForEvent(BSCARI.Name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)
		-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////		
		EVENT_MANAGER:RegisterForUpdate('BSCARI_BUFFUpdate', 500, UpdateUI)		
		bRegister = true
	elseif not IsInAvAZone() and bRegister then
		EVENT_MANAGER:UnregisterForEvent(BSCARI.Name.."BUFF", EVENT_KEEP_ALLIANCE_OWNER_CHANGED)
		EVENT_MANAGER:UnregisterForEvent(BSCARI.Name.."BUFF", EVENT_OBJECTIVES_UPDATED)			
		for abilityId in pairs(AP_BUFFLIST) do
			local eventName = 'BSCARI_BUFF'..abilityId
			EVENT_MANAGER:UnregisterForEvent(eventName, EVENT_COMBAT_EVENT)
		end
		EVENT_MANAGER:UnregisterForUpdate('BSCARI_BUFFUpdate')
		
		EVENT_MANAGER:UnregisterForEvent(BSCARI.Name, EVENT_INVENTORY_FULL_UPDATE)		
		EVENT_MANAGER:UnregisterForEvent(BSCARI.Name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)		
				
		zo_callLater(
			function() 
			if BSCARI.RemoveBuffInfoUIFragments then
				BSCARI:RemoveBuffInfoUIFragments()
			elseif BSCAllianceRankingBuffInfoUI then
				BSCAllianceRankingBuffInfoUI:SetHidden(true)
			end
			BSCAllianceRankingBuffInfoAlertUI:SetHidden(true)
			BSCARI:UpdateUISettingsBAR()
			end, 
		2000)
		
		bRegister = false
	end
end
function BSCARI:InitAbuffInfo()	
	CreateList()	
	BSCARI:RestorePosition()
	EVENT_MANAGER:RegisterForEvent(BSCARI.Name.."BUFF", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)		
	SCENE_MANAGER:GetScene("hud"):RegisterCallback("StateChange", ToggleUI)
	SCENE_MANAGER:GetScene("hudui"):RegisterCallback("StateChange", ToggleUI)
end