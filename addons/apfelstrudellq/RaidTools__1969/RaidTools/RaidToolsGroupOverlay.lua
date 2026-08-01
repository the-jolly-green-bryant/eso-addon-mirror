RaidToolsModule_GroupOverlay = {}

ULTIMATE_LIST = {}
VOTE_LIST = {}

RaidTools.LGS = LibStub("LibGroupSocket")
local MESSAGE_TYPE_RAIDTOOLS = 30
RaidToolsGroupInfoHandler = false

local in_trial = false
function RaidToolsModule_GroupOverlay.Init()
	if RaidTools.storage.config.libgroupsocket then
		RaidToolsGroupInfoHandler = RaidTools.LGS:GetHandler(MESSAGE_TYPE_RAIDTOOLS)
	else
		RaidTools.Message('LibGroupSocket features are disabled!')
	end
	RaidToolsModule_GroupOverlay.BuildUltimateUI()
	RaidToolsModule_GroupOverlay.BuildVotingUI()
	
	if RaidToolsGroupInfoHandler then
		RaidToolsGroupInfoHandler:RegisterForRTGroupInfo(function (unitTag, is_max_magicka, is_max_stamina, is_value_assigning_dataset, update_type, value, isSelf)
			--RaidTools.DebugMessage(string.format('[%s] %s: [mag: %s stam: %s] - is_assigning: %s, value: %s', update_type, GetUnitName(unitTag), tostring(is_max_magicka), tostring(is_max_stamina), tostring(is_value_assigning_dataset), value))
			local player = RaidTools.GetGroupPlayer(GetUnitName(unitTag))
			player.attributes.is_magicka = is_max_magicka
			player.attributes.is_stamina = is_max_stamina
			if update_type == 'set' then
				if is_value_assigning_dataset then
					RaidTools.DebugMessage('[SET-UPDATE: '.. GetUnitName(unitTag) ..'] (setting/put_on) '..value)
					if not has_value(player.sets, value) then table.insert(player.sets, value) end
				else
					RaidTools.DebugMessage('[SET-UPDATE: '.. GetUnitName(unitTag) ..'] (remove/took_off) '..value)
					for i, _set_id in ipairs(player.sets) do
						if _set_id == value then 
							table.remove(player.sets, i)
						end
					end
				end
				
				GROUP_LIST:RefreshData()
			elseif update_type == 'ult' then
				if is_value_assigning_dataset then
					player.ultimate_cost = value
					RaidTools.DebugMessage('[ULTCOST-UPDATE: '.. GetUnitName(unitTag) ..'] '..value)
				else
					player.attributes.ultimate = value
					RaidTools.DebugMessage('[ULT-UPDATE: '.. GetUnitName(unitTag) ..'] '..value)
				end
			elseif update_type == 'dps' then
				player.dps = dps
				RaidTools.DebugMessage('[DPS-UPDATE: '.. GetUnitName(unitTag) ..'] '..value)
			elseif update_type == 'vote' then
				player.vote = value
				RaidTools.DebugMessage('[VOTE-UPDATE: '.. GetUnitName(unitTag) ..'] '..value)
				RaidToolsModule_GroupOverlay.UpdateVoteStatus()
			end
			player.data = true
		end)
	end
	EVENT_MANAGER:RegisterForUpdate('RaidToolsGUPUpdater', 250, RaidToolsModule_GroupOverlay.PeriodicUpdate)
end

function RaidToolsModule_GroupOverlay.OnTrialEntered()
	in_trial = true	
	if RaidTools.LBF:IsSoloRaid() then return end
	if RaidTools.storage.config.warhorn.active then
		local is_dd, is_heal, is_tank = GetGroupMemberRoles('player')
		if not RaidTools.storage.config.warhorn.only_as_key_role or (RaidTools.storage.config.warhorn.only_as_key_role and (is_heal or is_tank)) then
			ULTIMATE_LIST.fragment:SetHiddenForReason("HideRaidToolULTIMATE_LIST", false)
		end
	end
end

function RaidToolsModule_GroupOverlay.OnTrialExited()
	in_trial = false
	if RaidTools.storage.config.warhorn.active then
		ULTIMATE_LIST.fragment:SetHiddenForReason("HideRaidToolULTIMATE_LIST", true)
	end
end

local warhorn_duration = 30
local warhorn_active = false
local warhorn_cast = 0
local last_data = 0
local major_force_up = false
function RaidToolsModule_GroupOverlay.PeriodicUpdate()
	if not in_trial then return end
	local is_dd, is_heal, is_tank = GetGroupMemberRoles('player')
	if ((GetGameTimeMilliseconds() - last_data)/1000) > 1.200 then
		if (is_heal or is_tank) and not is_dd then
			last_data = GetGameTimeMilliseconds()
			if RaidToolsGroupInfoHandler then
				RaidToolsGroupInfoHandler:SendPeriodicUpdate()
			end
		end
	end

	local icon_str = '|t24:24:/esoui/art/icons/ability_ava_003_a.dds|t'
	local base_str = string.format('|L%s:%s:%s:%s:%s:%s|LWarHornStatus|L %s', LABEL_LINE_STYLE_SOLID, LABEL_LINE_ANCHOR_BOTTOM, LABEL_LINE_ORDER_UNDER, -2, 2, CLR.cancer.hex, icon_str)
	if not warhorn_active then
		ULTIMATE_LIST.label:SetText(string.format('%s %s', base_str, '|c'..CLR.health.hex..'Inactive!'))
	else
		local duration = warhorn_duration - ((GetGameTimeMilliseconds() - warhorn_cast)/1000)

		if major_force_up then -- MajorForceActive
			ULTIMATE_LIST.label:SetText(string.format('%s %s%.1fs', base_str, '|cFFD700', duration))
		elseif duration <= 10 then
			ULTIMATE_LIST.label:SetText(string.format('%s %s%.1fs', base_str, '|c'..CLR.health.hex, duration))
		else
			ULTIMATE_LIST.label:SetText(string.format('%s %.1fs', base_str, duration))
		end
	end
	RaidToolsModule_GroupOverlay.UpdateWarhornStatus()
end

function GROUP_LIST:RefreshData()
	RaidToolsModule_GroupOverlay.UpdateHeaders()
	--if not RaidTools.storage.modules.group_overlay then return end	
	if not GROUP_LIST.control:IsHidden() then
        ZO_SortFilterList.RefreshData(GROUP_LIST)
        if not next(ZO_GroupListList.activeControls) then return end
        for _, row in pairs(ZO_GroupListList.activeControls) do
			RaidToolsModule_GroupOverlay.DrawGroupRow(row)
		end
    end
end

function GROUP_LIST:ColorRow(control, data, mouseIsOver)
	--if not RaidTools.storage.modules.group_overlay then return end	
	if GROUP_LIST.automaticallyColorRows then
        for i = 1, control:GetNumChildren() do
            local child = control:GetChild(i)
            if string.match(child:GetName(), 'Class') then
            	child = child:GetChild(1) --  "Class"->"Icon"
            	child:SetColor(1, 1, 1, 1)
		        if RaidTools.IsPlayerInVeteranTrial() then
		        	local player = RaidTools.GetGroupPlayer(GetUnitName(data.unitTag))
		        	if player.data then
						if data.isDps and not data.isTank and not data.isHeal then
							if player.attributes.is_magicka then
								child:SetColor(0, 0, 255, 1)
							elseif player.attributes.is_stamina then
								child:SetColor(0, 128, 0, 1)
							end
						end
					end
				end
			else
	            if not child.nonRecolorable then
	                local childType = child:GetType()
	                local textColor, iconColor = GROUP_LIST:GetRowColors(data, mouseIsOver, child)
	                if(childType == CT_LABEL and textColor ~= nil) then
	                    child:SetColor(textColor:UnpackRGBA())
	                elseif(childType == CT_TEXTURE and iconColor ~= nil) then
	                	child:SetColor(iconColor:UnpackRGBA())
	                end
	            end
	        end
        end
    end
end

function RaidToolsModule_GroupOverlay.UpdateHeaders()
	if RaidTools.IsPlayerInVeteranTrial() then
		ZO_GroupListHeadersZone:SetText('Sets')
		ZO_GroupListHeadersLevel:SetText('')
		ZO_GroupListHeadersClass:SetText('')
	else
		ZO_GroupListHeadersZone:SetText('Location')
		ZO_GroupListHeadersLevel:SetText('Level')
		ZO_GroupListHeadersClass:SetText('Class')
	end
end
local LFDB = LibStub('LibFoodDrinkBuff')
local function PrepareTooltipStr(data)
	local str = ''
	if not data then return str end
	-- |t20:20:esoui/art/icons/store_esoplus_01.dds|t
	if RaidTools.GetESOPlusStatus(data.unitTag) then
		str = str .. '|t25:25:esoui/art/icons/store_esoplus_01.dds|t'
	end
	if IsUnitFriend(data.unitTag) then
		str = str .. '|c00FF00'
	elseif IsUnitIgnored(data.unitTag) then
		str = str .. '|c'..CLR.health.hex
	else 
		str = str..'|c'..CLR.white.hex
	end

	if RaidTools.storage.config.go_userid then
		str = str..data.characterName
	else
		str = str..data.displayName
	end
	str = str..'|r'
	local mundus = RaidTools.GetActiveMundus(data.unitTag)
	if not mundus or mundus == nil then
		str = str..' (|c'..CLR.nodata.hex..'No Mundus!|r)'
	else
		str = str..' ('..mundus..')'
	end

	local vamp = RaidTools.GetVampStage(data.unitTag)
	if vamp ~= nil then
		str = str..'\n|t20:20:'..GetAbilityIcon(39472)..'|t Vampirism Stage: '..vamp
	end

	local buffType, isDrink, abilityId, buffName, timeStarted, timeEnds, iconTexture = LFDB:GetFoodBuffInfos(data.unitTag)
	if buffType == 0 then
		str = str..'\n|c'..CLR.nodata.hex..'No Buff-Food!|r'
	else
		str = str..'\n|t24:24:'..iconTexture..'|t '..buffName
	end

	local current, max, effmax = GetUnitPower(data.unitTag, POWERTYPE_HEALTH)
	str = str..'\nMax HP: |c'..CLR.white.hex..''.. FormatIntegerWithDigitGrouping(effmax, '.', 3) ..'|r'

	local player = RaidTools.GetGroupPlayer(GetUnitName(data.unitTag))
	if player.data then
		local sets = '\nActive 5p sets:'
		for _, set_id in ipairs(player.sets) do
			if RaidTools.ItemizationBrowserDataAvailable() then
				sets = sets..'\n- '..RaidTools.GetSetName(set_id)
			elseif RaidTools.IsBuffSet(set_id) then	
				sets = sets..'\n- '..RaidTools.GetBuffSetName(set_id)
			end
		end
		str = str..sets
	end
	return str
end

function RaidToolsModule_GroupOverlay.DrawGroupRow(row)
	local unitTag = row.dataEntry.data.unitTag
	local name = row:GetNamedChild("CharacterName") -- DEFAULT_WIDTH: 205
	local zone = row:GetNamedChild("Zone") -- DEFAULT_WIDTH: 125
	local level = row:GetNamedChild("Level") -- DEFAULT_WIDTH: 75
	local level_icon = row:GetNamedChild("Champion")
	local class_icon = row:GetNamedChild("ClassIcon")
	if RaidTools.storage.config.go_userid then
		name:SetText(GetGroupIndexByUnitTag(unitTag)..'. '..row.dataEntry.data.displayName)
	else
		name:SetText(GetGroupIndexByUnitTag(unitTag)..'. '..row.dataEntry.data.characterName)
	end

	name:SetHandler("OnMouseEnter", function (self) 
		ZO_Tooltips_ShowTextTooltip(self, TOP, PrepareTooltipStr(row.dataEntry.data)) 
		ZO_GroupListRow_OnMouseEnter(row)
	end)
	name:SetHandler("OnMouseExit", function () 
		ZO_Tooltips_HideTextTooltip() 
		ZO_GroupListRow_OnMouseExit(row)
	end)

	zone:SetHandler("OnMouseEnter", function (self) 
		local sets = {}
		ZO_GroupListRowTooltipIfTruncatedLabel_OnMouseEnter(self)
		local player = RaidTools.GetGroupPlayer(GetUnitName(unitTag))
		if player.data then
			for _, set_id in ipairs(player.sets) do
				if RaidTools.IsBuffSet(set_id) then
					table.insert(sets, RaidTools.CreateItemLinkForBuffSet(set_id))
				end
			end
			if sets[1] then
				InitializeTooltip(RTTooltip, ZO_GroupMenu_Keyboard, TOPRIGHT, -50, 0, TOPLEFT)
				RTTooltip:SetLink(sets[1])
			end
			if sets[2] then
				InitializeTooltip(RTTooltip2, ZO_GroupMenu_Keyboard, TOPRIGHT, -500, 0, TOPLEFT)
				RTTooltip2:SetLink(sets[2])
			end
		end
	end)
	zone:SetHandler("OnMouseExit", function (self) 
		ZO_GroupListRowChild_OnMouseExit(self)
		ClearTooltip(RTTooltip)
		ClearTooltip(RTTooltip2)
	end)
	
	local player = RaidTools.GetGroupPlayer(GetUnitName(unitTag))
	local my_zone = FixName(GetUnitZone('player'))
	local player_zone = FixName(GetUnitZone(unitTag))
	zone:SetWidth(175)
	level:SetWidth(1)
	level_icon:SetHidden(true)
	
	if not RaidTools.IsPlayerInVeteranTrial() then
		zone:SetWidth(125)
		level:SetWidth(75)
		class_icon:SetColor(1, 1, 1, 1)
		if not IsUnitChampion(unitTag) then 
			level_icon:SetHidden(true) 
			level:SetText(GetUnitLevel(unitTag))
		else
			level_icon:SetHidden(false) 
			level:SetText(GetUnitChampionPoints(unitTag))
		end
		if not IsUnitOnline(unitTag) then zone:SetText('|c'.. CLR.health.hex ..'Offline|r') return end
		return
	end
	if not IsUnitOnline(unitTag) then zone:SetText('|c'.. CLR.health.hex ..'Offline|r') return end
	if not player.data then
		local sets = '|c'.. CLR.health.hex
		if string.match(my_zone, player_zone) == nil then sets = sets .. 'Not in trial ('.. player_zone ..') & ' end
		zone:SetText(sets ..'No data available|r')
		
	else
		local sets = ''
		if string.match(my_zone, player_zone) == nil then sets = sets .. '|c'.. CLR.health.hex ..'Not in trial! ('.. player_zone ..') ' else
			for _, set_id in ipairs(player.sets) do
				if RaidTools.IsBuffSet(set_id) then
					sets = sets .. RaidTools.CreateItemLinkForBuffSet(set_id)
				end
			end
		end
		if sets:len() == 0 then sets = 'No support set(s) equipped' end
		zone:SetText('')
		zone:SetText(sets)
	end
	if IsUnitOnline(unitTag) and zone:GetText() == '' then
		level:SetText('')
		zone:SetText('Loading screen...')
	end
end

local aggr_horn_abbility_ids = {
	[40224] = true,	-- I
	[46532] = true,	-- II
	[46535] = true,	-- III
	[46538] = true	-- IV
}

function RaidToolsModule_GroupOverlay.OnCombatEvent(_, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
	--d(string.format('result: %s, abilityName: %s, sourceName: %s, sourceType: %s, sourceUnitId: %s, abilityId: %s, targetUnitId: %s, targetName: %s', result, abilityName, sourceName, sourceType, sourceUnitId, abilityId,targetUnitId, targetName))
end

function RaidToolsModule_GroupOverlay.OnEffectChanged(_, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
	if not string.match(unitTag, 'group') then return end
	--d(string.format('changeType: %s, effectName: %s, unitTag: %s, stackCount: %s, buffType: %s, effectType: %s, abilityType: %s, statusEffectType: %s, unitName: %s, unitId: %s, abilityId: %s, sourceType: %s',
	--	changeType, effectName, unitTag, stackCount, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType
	--))
	if abilityId == 40225 then
		if changeType == EFFECT_RESULT_GAINED then
			major_force_up = true
		elseif changeType == EFFECT_RESULT_FADED then
			major_force_up = false
		end
	end
	if aggr_horn_abbility_ids[abilityId] then
		if changeType == EFFECT_RESULT_GAINED then
			warhorn_duration = (endTime-beginTime)
			warhorn_active = true
			warhorn_cast = GetGameTimeMilliseconds()
		elseif changeType == EFFECT_RESULT_FADED then
			warhorn_active = false
		elseif changeType == EFFECT_RESULT_UPDATED then
			warhorn_active = true
			warhorn_cast = GetGameTimeMilliseconds()
		end
	end
end

function RaidToolsModule_GroupOverlay.UpdateWarhornStatus()
	local entry = 1
	for i = 1, GROUP_SIZE_MAX do
		ULTIMATE_LIST.entries[i]:SetHidden(true) 
		ULTIMATE_LIST.entries[i].percentage:SetHidden(true) 
	end
	local ultis = {}
	for i = 1, GROUP_SIZE_MAX do
		local unitTag = 'group'..i
		if DoesUnitExist(unitTag) and IsUnitOnline(unitTag) then
			local is_dd, is_heal, is_tank = GetGroupMemberRoles(unitTag)
			if (is_heal or is_tank) then 
				local player = RaidTools.GetGroupPlayer(GetUnitName(unitTag))
				if not player.data then
					ultis[unitTag] = -1
				elseif player.attributes.ultimate == -1 then
					ultis[unitTag] = -2
				else
					ultis[unitTag] = math.floor((player.attributes.ultimate/player.ultimate_cost)*100)
				end
			end
		end
	end
	for unitTag, ult_percentage in spairs(ultis, function(t,a,b) return t[b] < t[a] end) do
		local display_name = GetUnitDisplayName(unitTag)
		local str = ''
		if ult_percentage == -1 then
			str = '|c'..CLR.health.hex..'No data|r'
		elseif ult_percentage == -2 then
			str = '|cFFA500Module inactive|r'
		else
			if ult_percentage >= 100 then
				str = string.format('|c%s%d|r%%', CLR.stam.hex, 100)
			else
				str = string.format('|c%s%d|r%%', CLR.white.hex, ult_percentage)
			end 
		end
		ULTIMATE_LIST.entries[entry]:SetText(string.format('%s', display_name))
		ULTIMATE_LIST.entries[entry]:SetHidden(false)
		ULTIMATE_LIST.entries[entry].percentage:SetText(string.format('%s', str))
		ULTIMATE_LIST.entries[entry].percentage:SetHidden(false)
		
		entry = entry + 1
	end
end

function RaidToolsModule_GroupOverlay.BuildUltimateUI()
	local function OnGUIMoveStop()
		RaidTools.storage.config.warhorn.x = ULTIMATE_LIST:GetLeft()
		RaidTools.storage.config.warhorn.y = ULTIMATE_LIST:GetTop()
	end
	ULTIMATE_LIST = RaidTools.WM:CreateTopLevelWindow("RaidToolsULTIMATE_LIST")
	ULTIMATE_LIST:SetDimensions(300, 200)
	ULTIMATE_LIST:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RaidTools.storage.config.warhorn.x, RaidTools.storage.config.warhorn.y)
	ULTIMATE_LIST:SetClampedToScreen(true)
	ULTIMATE_LIST:SetMouseEnabled(true)
	ULTIMATE_LIST:SetMovable(true)
	ULTIMATE_LIST:SetHidden(true)
	ULTIMATE_LIST:SetAlpha(1)
	ULTIMATE_LIST:SetHandler("OnMoveStop", OnGUIMoveStop)

	ULTIMATE_LIST.background = RaidTools.WM:CreateControl(nil, ULTIMATE_LIST, CT_BACKDROP)
	ULTIMATE_LIST.background:SetAnchorFill(ULTIMATE_LIST)
	ULTIMATE_LIST.background:SetEdgeTexture(nil, 1, 1, 1.0, 1.0)
	ULTIMATE_LIST.background:SetCenterColor(0.0, 0.0, 0.0, 0.0)
	ULTIMATE_LIST.background:SetEdgeColor(255, 255, 255, 0.0)

	ULTIMATE_LIST.label = RaidTools.WM:CreateControl(nil, ULTIMATE_LIST, CT_LABEL)
	ULTIMATE_LIST.label:SetDimensions(300, 10)
	ULTIMATE_LIST.label:SetAnchor(TOPLEFT, ULTIMATE_LIST, TOPLEFT, 5, 2)
	ULTIMATE_LIST.label:SetFont('ZoFontGame')
	local icon_str = '|t24:24:/esoui/art/icons/ability_ava_003_a.dds|t'
	local base_str = string.format('|L%s:%s:%s:%s:%s:%s|LWarHornStatus|L %s', LABEL_LINE_STYLE_SOLID, LABEL_LINE_ANCHOR_BOTTOM, LABEL_LINE_ORDER_UNDER, -2, 2, CLR.cancer.hex, icon_str)
	ULTIMATE_LIST.label:SetText(string.format('%s %s', base_str, ''))

	ULTIMATE_LIST.entries = {}
	local y = 26
	for i = 1, GROUP_SIZE_MAX do
		ULTIMATE_LIST.entries[i] = RaidTools.WM:CreateControl(nil, ULTIMATE_LIST, CT_LABEL)
		ULTIMATE_LIST.entries[i]:SetDimensions(300, 10)
		ULTIMATE_LIST.entries[i]:SetAnchor(TOPLEFT, ULTIMATE_LIST, TOPLEFT, 5, y)
		ULTIMATE_LIST.entries[i]:SetFont('ZoFontGame')
		ULTIMATE_LIST.entries[i]:SetHidden(true)

		ULTIMATE_LIST.entries[i].percentage = RaidTools.WM:CreateControl(nil, ULTIMATE_LIST, CT_LABEL)
		ULTIMATE_LIST.entries[i].percentage:SetDimensions(300, 10)
		ULTIMATE_LIST.entries[i].percentage:SetAnchor(TOPLEFT, ULTIMATE_LIST, TOPLEFT, 170, y)
		ULTIMATE_LIST.entries[i].percentage:SetFont('ZoFontGame')
		ULTIMATE_LIST.entries[i].percentage:SetHidden(true)

		ULTIMATE_LIST.entries[i]:SetText(string.format('@apfelstrudellq'))
		ULTIMATE_LIST.entries[i].percentage:SetText(string.format('0%%'))
		y = y + 20
	end

	ULTIMATE_LIST.fragment = ZO_HUDFadeSceneFragment:New(ULTIMATE_LIST)
	HUD_SCENE:AddFragment(ULTIMATE_LIST.fragment)
    HUD_UI_SCENE:AddFragment(ULTIMATE_LIST.fragment)

    ULTIMATE_LIST.fragment:SetHiddenForReason("HideRaidToolULTIMATE_LIST", true)
end

function RaidToolsModule_GroupOverlay.OnGroupElectionStarted(...)
	local etype, remaining, msg, target = GetGroupElectionInfo()
	--d('OnGroupElectionStarted', GetGroupElectionInfo())
	if etype ~= GROUP_ELECTION_TYPE_GENERIC_UNANIMOUS then return end
	if not RaidTools.storage.config.vote.active then return end

	if etype == GROUP_ELECTION_TYPE_KICK_MEMBER then
		etype = 'Kick vote'
	elseif etype == GROUP_ELECTION_TYPE_NEW_LEADER then
		etype = 'Leader change'
	elseif etype == GROUP_ELECTION_TYPE_GENERIC_UNANIMOUS then
		etype = 'Ready check'
	else
		etype = 'Vote'
	end

	local base_str = string.format('|L%s:%s:%s:%s:%s:%s|LVote:|L', LABEL_LINE_STYLE_SOLID, LABEL_LINE_ANCHOR_BOTTOM, LABEL_LINE_ORDER_UNDER, -2, 2, CLR.cancer.hex)
	VOTE_LIST.label:SetText(string.format('%s %s%s', base_str, '|c'..CLR.cancer.hex, etype))
	RaidToolsModule_GroupOverlay.UpdateVoteStatus()
	VOTE_LIST.fragment:SetHiddenForReason("HideRaidToolVOTE_LIST", false)
end

function RaidToolsModule_GroupOverlay.OnGroupElectionEnded(...)
	for i = 1, GROUP_SIZE_MAX do
		local unitTag = 'group'..i
		if DoesUnitExist(unitTag) and IsUnitOnline(unitTag) then
			local player = RaidTools.GetGroupPlayer(GetUnitName(unitTag))
			player.vote = -1
		end
	end
end

function RaidToolsModule_GroupOverlay.OnGroupElectionRequested(_, etype)
	RaidToolsModule_GroupOverlay.OnGroupElectionStarted()
end

function RaidToolsModule_GroupOverlay.OnGroupElectionResult(_, result, etype)
	RaidToolsModule_GroupOverlay.OnGroupElectionEnded()
	--d('OnGroupElectionResult', result, etype)
	if not RaidTools.storage.config.vote.active then return end
	local str = ''
	if result == GROUP_ELECTION_RESULT_ABANDONED then
		str = 'Vote abandoned'
	elseif result == GROUP_ELECTION_RESULT_ELECTION_LOST then
		str = 'Vote lost'
	elseif result == GROUP_ELECTION_RESULT_ELECTION_WON then
		str = 'Vote won'
	elseif result == GROUP_ELECTION_RESULT_IN_PROGRESS then
		str = 'Vote still in progress'
	end
	--RaidTools.BrandedMessage(string.format('%s', str))
	VOTE_LIST.fragment:SetHiddenForReason("HideRaidToolVOTE_LIST", true)
end

function RaidToolsModule_GroupOverlay.OnGroupElectionFailed(_, result, etype)
	RaidToolsModule_GroupOverlay.OnGroupElectionEnded()
	--d('OnGroupElectionFailed', result, etype)
	if not RaidTools.storage.config.vote.active then return end
	local str = ''
	if result == GROUP_ELECTION_FAILURE_SERVER_ERROR then
		str = 'Vote failed due to server error'
	elseif result == GROUP_ELECTION_FAILURE_TOO_FEW_MEMBERS then
		str = 'Vote failed due to a lack of group members'
	elseif result == GROUP_ELECTION_FAILURE_TOO_SOON then
		str = 'Vote failed due to a too recent voting'
	elseif result == GROUP_ELECTION_FAILURE_UNKNOWN_CHOICE then
		str = 'Vote failed due to an unknown choice'
	elseif result == GROUP_ELECTION_FAILURE_TARGET_NOT_FOUND then
		str = 'Vote failed due to a no longer existant member'
	elseif result == GROUP_ELECTION_FAILURE_SAME_INITIATOR_AND_TARGET then
		str = 'Vote failed because you cant target yourself'
	elseif result == GROUP_ELECTION_FAILURE_NOT_GROUPED then
		str = 'Vote failed because you are not in a group'
	elseif result == GROUP_ELECTION_FAILURE_NO_CURRENT_ELECTION then
		str = 'Vote failed because no election is going on'
	elseif result == GROUP_ELECTION_FAILURE_INITIATOR_NOT_FOUND then
		str = 'Vote failed because the origin was not found'
	elseif result == GROUP_ELECTION_FAILURE_IN_BATTLEGROUND then
		str = 'Vote failed because you are in a battlegrounds match'
	elseif result == GROUP_ELECTION_FAILURE_ANOTHER_IN_PROGRESS then
		str = 'Vote failed because another vote is happening'
	elseif result == GROUP_ELECTION_FAILURE_ALREADY_VOTED then
		str = 'Vote failed because you already voted'
	end
	--RaidTools.BrandedMessage(string.format('%s', str))
	VOTE_LIST.fragment:SetHiddenForReason("HideRaidToolVOTE_LIST", true)
end

function RaidToolsModule_GroupOverlay.UpdateVoteStatus()
	local entry = 1
	for i = 1, GROUP_SIZE_MAX do
		VOTE_LIST.entries[i]:SetHidden(true) 
		VOTE_LIST.entries[i].result:SetHidden(true) 
	end
	for i = 1, GROUP_SIZE_MAX do
		local unitTag = 'group'..i
		if DoesUnitExist(unitTag) and IsUnitOnline(unitTag) then
			local display_name = GetUnitDisplayName(unitTag)
			local player = RaidTools.GetGroupPlayer(GetUnitName(unitTag))
			local str = ''
			if not player or not player.data then
				str = '|c'..CLR.health.hex..'No data available|r'
			else
				if player.vote == -1 then
					str = 'Waiting on vote...'
				elseif player.vote == 0 then
					str = '|cFFA500Abstained|r'
				elseif player.vote == 2 then
					str = '|c'..CLR.stam.hex..'For|r'
				elseif player.vote == 1 then
					str = '|c'..CLR.health.hex..'Against|r'
				elseif player.vote == 3 then
					str = '|c'..CLR.soft.hex..'Vote origin|r'
				end
			end
			VOTE_LIST.entries[entry]:SetText(string.format('%s', display_name))
			VOTE_LIST.entries[entry]:SetHidden(false)
			VOTE_LIST.entries[entry].result:SetText(string.format('%s', str))
			VOTE_LIST.entries[entry].result:SetHidden(false)
			
			entry = entry + 1
		end
	end
end

function RaidToolsModule_GroupOverlay.BuildVotingUI()
	local function OnGUIMoveStop()
		RaidTools.storage.config.vote.x = VOTE_LIST:GetLeft()
		RaidTools.storage.config.vote.y = VOTE_LIST:GetTop()
	end
	VOTE_LIST = RaidTools.WM:CreateTopLevelWindow("RaidToolsVOTE_LIST")
	VOTE_LIST:SetDimensions(300, 200)
	VOTE_LIST:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RaidTools.storage.config.vote.x, RaidTools.storage.config.vote.y)
	VOTE_LIST:SetClampedToScreen(true)
	VOTE_LIST:SetMouseEnabled(true)
	VOTE_LIST:SetMovable(true)
	VOTE_LIST:SetHidden(true)
	VOTE_LIST:SetAlpha(1)
	VOTE_LIST:SetHandler("OnMoveStop", OnGUIMoveStop)

	VOTE_LIST.background = RaidTools.WM:CreateControl(nil, VOTE_LIST, CT_BACKDROP)
	VOTE_LIST.background:SetAnchorFill(VOTE_LIST)
	VOTE_LIST.background:SetEdgeTexture(nil, 1, 1, 1.0, 1.0)
	VOTE_LIST.background:SetCenterColor(0.0, 0.0, 0.0, 0.0)
	VOTE_LIST.background:SetEdgeColor(255, 255, 255, 0.0)

	VOTE_LIST.label = RaidTools.WM:CreateControl(nil, VOTE_LIST, CT_LABEL)
	VOTE_LIST.label:SetDimensions(300, 10)
	VOTE_LIST.label:SetAnchor(TOPLEFT, VOTE_LIST, TOPLEFT, 5, 2)
	VOTE_LIST.label:SetFont('ZoFontGame')
	local base_str = string.format('|L%s:%s:%s:%s:%s:%s|LVote:|L', LABEL_LINE_STYLE_SOLID, LABEL_LINE_ANCHOR_BOTTOM, LABEL_LINE_ORDER_UNDER, -2, 2, CLR.cancer.hex)
	VOTE_LIST.label:SetText(string.format('%s %s', base_str, 'None'))

	VOTE_LIST.entries = {}
	local y = 26
	for i = 1, GROUP_SIZE_MAX do
		VOTE_LIST.entries[i] = RaidTools.WM:CreateControl(nil, VOTE_LIST, CT_LABEL)
		VOTE_LIST.entries[i]:SetDimensions(300, 10)
		VOTE_LIST.entries[i]:SetAnchor(TOPLEFT, VOTE_LIST, TOPLEFT, 5, y)
		VOTE_LIST.entries[i]:SetFont('ZoFontGame')
		VOTE_LIST.entries[i]:SetHidden(true)

		VOTE_LIST.entries[i].result = RaidTools.WM:CreateControl(nil, VOTE_LIST, CT_LABEL)		
		VOTE_LIST.entries[i].result:SetDimensions(300, 10)
		VOTE_LIST.entries[i].result:SetAnchor(TOPLEFT, VOTE_LIST, TOPLEFT, 170, y)
		VOTE_LIST.entries[i].result:SetFont('ZoFontGame')
		VOTE_LIST.entries[i].result:SetHidden(true)

		VOTE_LIST.entries[i]:SetText(string.format('@apfelstrudellq'))
		VOTE_LIST.entries[i].result:SetText(string.format('Waiting on vote...'))
		y = y + 20
	end

	VOTE_LIST.fragment = ZO_HUDFadeSceneFragment:New(VOTE_LIST)
	HUD_SCENE:AddFragment(VOTE_LIST.fragment)
    HUD_UI_SCENE:AddFragment(VOTE_LIST.fragment)

    VOTE_LIST.fragment:SetHiddenForReason("HideRaidToolVOTE_LIST", true)
end
