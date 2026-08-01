JoGroup = JoGroup or {}
local Jo = JoGroup
local evm = GetEventManager()
local wim = GetWindowManager()
local anm = GetAnimationManager()
local sf = 1/GetSetting(SETTING_TYPE_UI, UI_SETTING_CUSTOM_SCALE)

Jo.name = "JoGroup"
Jo.version = 1.91
Jo.varsVersion = 1.3
Jo.unit = {}
Jo.delayedRebuildCounter = 0
Jo.unlocked = false

-------------------------------------------------------------------------------------------------
--  Update units  --
-------------------------------------------------------------------------------------------------
function Jo.UpdateUnits(event)
	if event == EVENT_GROUP_UPDATE then
		Jo.ReAnchor()
	end

	for i = 1, GROUP_SIZE_MAX do
		local unitTag = "group"..i
		local unit = Jo.unit[unitTag]
		local frame = Jo.frame[unitTag]
		local compactMode = Jo.savedVars.compactMode

		if DoesUnitExist(unitTag) and IsUnitGrouped("player") then
			-- In case of index change
			if unit.index ~= GetGroupIndexByUnitTag(unitTag) then
				local powerValue, powerMax, powerEffectiveMax = GetUnitPower(unitTag, POWERTYPE_HEALTH)
				frame.bar:SetMinMax(0, powerMax)
				frame.bar:SetValue(powerValue)
				frame.shield:SetWidth(0)
				frame.shieldBar:SetHidden(true)
				frame.shieldGloss:SetHidden(true)
				Jo.GetShield(unitTag)

				unit.index = GetGroupIndexByUnitTag(unitTag)
				Jo.ReAnchor()
			end

			-- Update unitslist
			unit.index = GetGroupIndexByUnitTag(unitTag)
			unit.accountName = GetUnitDisplayName(unitTag)
			unit.characterName = GetUnitName(unitTag)

			unit.class = GetUnitClassId(unitTag)
			unit.className = zo_strformat(SI_CLASS_NAME, GetUnitClass(unitTag))
			unit.level = GetUnitChampionPoints(unitTag) > 0 and zo_iconTextFormat("esoui/art/champion/champion_icon_32.dds", Jo.champIconSize, Jo.champIconSize, GetUnitChampionPoints(unitTag)) or GetUnitLevel(unitTag)
			unit.isLeader = IsUnitGroupLeader(unitTag)

			-- Name
			if compactMode then
				if ZO_ShouldPreferUserId() then
					unit.name = zo_strformat("<<1>>", unit.accountName)
				else
					unit.name = zo_strformat("<<1>>", unit.characterName)
				end
			else -- Normal size
				if ZO_ShouldPreferUserId() then
					unit.name = zo_strformat(SI_PLAYER_PRIMARY_AND_SECONDARY_NAME_FORMAT, unit.accountName, unit.characterName)
				else
					unit.name = zo_strformat("<<2>><<1>>", unit.accountName, unit.characterName)
				end
				if not Jo.savedVars.show.acctName then				
					unit.name = zo_strformat("<<1>>", unit.characterName)
				end					
			end
			frame.name:SetText(unit.name)

			-- Class
			if unit.class == 1 then
				unit.classIcon = zo_iconFormat("esoui/art/icons/class/class_dragonknight.dds", Jo.classIconSize, Jo.classIconSize)

			elseif unit.class == 2 then
				unit.classIcon = zo_iconFormat("esoui/art/icons/class/class_sorcerer.dds", Jo.classIconSize, Jo.classIconSize)

			elseif unit.class == 3 then
				unit.classIcon = zo_iconFormat("esoui/art/icons/class/class_nightblade.dds", Jo.classIconSize, Jo.classIconSize)
				
			elseif unit.class == 6 then
				unit.classIcon = zo_iconFormat("esoui/art/icons/class/class_templar.dds", Jo.classIconSize, Jo.classIconSize)
				
			elseif unit.class == 4 then
				unit.classIcon = zo_iconFormat("esoui/art/icons/class/class_warden.dds", Jo.classIconSize, Jo.classIconSize)
			
			elseif unit.class == 5 then
				unit.classIcon = zo_iconFormat("esoui/art/icons/class/class_necromancer.dds", Jo.classIconSize, Jo.classIconSize)
			end

			-- Update unit
			Jo.UpdateUnit(event, unitTag)

			-- Show populated frame
			frame:SetHidden(false)
		else
			-- Not in group
			frame:SetHidden(not Jo.unlocked)
			unit = {}

			-- Create previews
			if i==1 then
				if Jo.savedVars.colours.customColour then
					frame.bar:SetColor(unpack(Jo.savedVars.colours.customTankColour))
				else
					ZO_StatusBar_SetGradientColor(frame.bar, Jo.barColour[Jo.savedVars.colours.tankColour])
				end
			elseif i==2 then
				if Jo.savedVars.colours.customColour then
					frame.bar:SetColor(unpack(Jo.savedVars.colours.customHealerColour))
				else
					ZO_StatusBar_SetGradientColor(frame.bar, Jo.barColour[Jo.savedVars.colours.healerColour])
				end
			else
				if Jo.savedVars.colours.customColour then
					frame.bar:SetColor(unpack(Jo.savedVars.colours.customDpsColour))
				else
					ZO_StatusBar_SetGradientColor(frame.bar, Jo.barColour[Jo.savedVars.colours.dpsColour])
				end
			end
		end
	end
end

-------------------------------------------------------------------------------------------------
--  Update unit  --
-------------------------------------------------------------------------------------------------
function Jo.UpdateUnit(event, unitTag)
	if not DoesUnitExist(unitTag) then return end
	if not ZO_Group_IsGroupUnitTag(unitTag) then return end
	if Jo.unit[unitTag] == nil then return end
	local unit = Jo.unit[unitTag]
	local frame = Jo.frame[unitTag]

	-- Leader
	if unit.isLeader then
		if IsGroupUsingVeteranDifficulty() and Jo.savedVars.show.diffIndicator then
			frame.name:SetText(zo_iconTextFormatNoSpace("esoui/art/lfg/gamepad/lfg_activityicon_veterandungeon.dds", Jo.leaderIconSize+(3*sf), Jo.leaderIconSize+(3*sf), unit.name))
		else
			frame.name:SetText(zo_iconTextFormatNoSpace("esoui/art/unitframes/gamepad/gp_group_leader.dds", Jo.leaderIconSize, Jo.leaderIconSize, unit.name))
		end
		frame.name:SetInheritAlpha(false)
	else
		frame.name:SetText(unit.name)
		frame.name:SetInheritAlpha(true)
	end

	-- Class & level
	if unit.level ~= 0 and not IsUnitDead(unitTag) then
		frame.class:SetText(unit.classIcon..unit.level)
	else
		frame.class:SetText(unit.classIcon)
	end

	-- Support range
	if not IsUnitInGroupSupportRange(unitTag) then
		frame:SetAlpha(Jo.savedVars.opacity.oorAlpha)
	else
		frame:SetAlpha(1)
	end

	-- Tooltips
	frame:SetHandler("OnMouseEnter", function(self)
		InitializeTooltip(InformationTooltip, self, TOP, 0, 0)

		local name = unit.name
		if ZO_ShouldPreferUserId() then
			name = zo_strformat(SI_PLAYER_PRIMARY_AND_SECONDARY_NAME_FORMAT, unit.accountName, unit.characterName)
		else
			name = zo_strformat("<<2>><<1>>", unit.accountName, unit.characterName)
		end

		SetTooltipText(InformationTooltip, unit.index..". "..name)
		ZO_Tooltip_AddDivider(InformationTooltip)

		if IsUnitOnline(unitTag) then
			InformationTooltip:AddLine(unit.classIcon..unit.className.."  "..unit.level)
			InformationTooltip:AddLine(zo_iconTextFormat("esoui/art/icons/alchemy/crafting_alchemy_trait_restorehealth.dds", "70%", "70%", unit.healthTip))
			InformationTooltip:AddLine(zo_iconTextFormatNoSpace("esoui/art/compass/ava_outpost_neutral.dds", "110%", "110%", zo_strformat(SI_ZONE_NAME, GetUnitZone(unitTag))))

			if unit.buffEndTime > GetFrameTimeSeconds() then
				local timeLeft = ZO_FormatTime(unit.buffEndTime-GetFrameTimeSeconds(), TIME_FORMAT_STYLE_CLOCK_TIME, TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR)
				InformationTooltip:AddLine(zo_iconTextFormatNoSpace("esoui/art/icons/mapkey/mapkey_farm.dds", "100%", "100%", timeLeft.." - "..unit.buffName))
			end
		else
			local timeOffline = ZO_FormatTime(GetFrameTimeSeconds()-unit.offline, TIME_FORMAT_STYLE_CLOCK_TIME, TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR)
			InformationTooltip:AddLine(timeOffline.." - "..GetString(SI_PLAYERSTATUS4))
		end
	end)
	frame:SetHandler("OnMouseExit", function(self) ClearTooltip(InformationTooltip) end)

	-- Context menus
	frame:SetHandler("OnMouseUp", function(self, button, upInside)
		if button == MOUSE_BUTTON_INDEX_RIGHT and upInside then
			ClearMenu()

			local isYou = AreUnitsEqual(unitTag, "player")
			local modificationRequiresVoting = DoesGroupModificationRequireVote()

			if isYou then
				AddMenuItem(GetString(SI_GROUP_LIST_MENU_LEAVE_GROUP), function() GroupLeave() end)

			elseif IsUnitOnline(unitTag) then
				AddMenuItem(GetString(SI_SOCIAL_LIST_PANEL_WHISPER), function() StartChatInput("", CHAT_CHANNEL_WHISPER, unit.accountName) end)
				AddMenuItem(GetString(SI_SOCIAL_MENU_JUMP_TO_PLAYER), function() JumpToGroupMember(unit.accountName) end)
			end

			if IsUnitGroupLeader("player") then
				if isYou then
					if not modificationRequiresVoting then
						AddMenuItem(GetString(SI_GROUP_LIST_MENU_DISBAND_GROUP), function() ZO_Dialogs_ShowDialog("GROUP_DISBAND_DIALOG") end)
					end
				else
					if IsUnitOnline(unitTag) then
						AddMenuItem(GetString(SI_GROUP_LIST_MENU_PROMOTE_TO_LEADER), function() GroupPromote(unitTag) end)
					end
					if not modificationRequiresVoting then
						AddMenuItem(GetString(SI_GROUP_LIST_MENU_KICK_FROM_GROUP), function() GroupKick(unitTag) end)
					end
				end
			end

			if modificationRequiresVoting and not isYou then
				AddMenuItem(GetString(SI_GROUP_LIST_MENU_VOTE_KICK_FROM_GROUP), function() BeginGroupElection(GROUP_ELECTION_TYPE_KICK_MEMBER, ZO_GROUP_ELECTION_DESCRIPTORS.NONE, unitTag) end)
			end

			-- I Summon Thee!
			--if IST then
				--d("IST loaded") -- debug
				--AddMenuItem("Summon player", function() IST.SummonPlayer(unit.characterName, unit.accountName) end)
			--end

			--[[ Mark player
			if unit.mark > 0 then
				AddMenuItem(GetString(SI_JOGROUP_UNMARK), function() Jo.MarkPlayer(unitTag, false) end)
			else
				AddMenuItem(GetString(SI_JOGROUP_MARK), function() Jo.MarkPlayer(unitTag, true, 1) end)
			end
]]
			ShowMenu(self)
		end
	end)

	-- Offline
	if not IsUnitOnline(unitTag) then
		if unit.offline == 0 then
			unit.offline = GetFrameTimeSeconds()
		end
		unit.shield = 0
		unit.regen = 0
		frame.info:SetText(GetString(SI_PLAYERSTATUS4))
		frame.statusBar:SetHidden(true)
		frame.hidden:SetWidth(0)
		frame.shield:SetWidth(0)
		frame.bar:SetHeight(Jo.innerBarHeight)
		frame.gloss:SetHeight(frame.bar:GetHeight())
		frame.bgColor:SetCenterColor(0, 0, 0, 0)
		return
	end
	unit.offline = 0

	-- Roles
	if GetGroupMemberAssignedRole(unitTag) > 0 then
		unit.role = GetGroupMemberAssignedRole(unitTag)
	else
		local isDps, isHealer, isTank = GetGroupMemberRoles(unitTag)
		if isTank then unit.role = 2
		elseif isHealer then unit.role = 4
		else unit.role = 1 end
	end

	if unit.role == 2 then
		if Jo.savedVars.colours.customColour then
			frame.bar:SetColor(unpack(Jo.savedVars.colours.customTankColour))
		else
			ZO_StatusBar_SetGradientColor(frame.bar, Jo.barColour[Jo.savedVars.colours.tankColour])
		end
	elseif unit.role == 4 then
		if Jo.savedVars.colours.customColour then
			frame.bar:SetColor(unpack(Jo.savedVars.colours.customHealerColour))
		else
			ZO_StatusBar_SetGradientColor(frame.bar, Jo.barColour[Jo.savedVars.colours.healerColour])
		end
	else
		if Jo.savedVars.colours.customColour then
			frame.bar:SetColor(unpack(Jo.savedVars.colours.customDpsColour))
		else
			ZO_StatusBar_SetGradientColor(frame.bar, Jo.barColour[Jo.savedVars.colours.dpsColour])
		end
	end

	if event == EVENT_GROUP_MEMBER_ROLES_CHANGED or event == EVENT_UNIT_CREATED or event == EVENT_UNIT_DESTROYED then
		if Jo.savedVars.ordening.sort == "role" then
			Jo.ReAnchor()
		end
	end

	-- Buffs
	Jo.UpdateBuffs(unitTag)

	-- Shield
	local shieldValue, shieldMax = GetUnitAttributeVisualizerEffectInfo(unitTag, ATTRIBUTE_VISUAL_POWER_SHIELDING)
	if value ~= nil then
		Jo.SetShield(event, unitTag, shieldValue, shieldMax)
	end

	-- Power
	local powerValue, powerMax, powerEffectiveMax = GetUnitPower(unitTag, POWERTYPE_HEALTH)
	Jo.UpdatePower(event, unitTag, nil, nil, powerValue, powerMax, powerEffectiveMax)
end

-------------------------------------------------------------------------------------------------
--  Mark player  --
-------------------------------------------------------------------------------------------------
--[[
function Jo.MarkPlayer(unitTag, isMarked, markType)
	if not DoesUnitExist(unitTag) then return end
	if not ZO_Group_IsGroupUnitTag(unitTag) then return end
	if Jo.unit[unitTag] == nil then return end
	local unit = Jo.unit[unitTag]
	local frame = Jo.frame[unitTag]

	if isMarked then
		unit.mark = markType
	else
		unit.mark = 0
	end

	if unit.mark == 1 then
		frame.bgColor:SetEdgeColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_POWER_START, POWERTYPE_MAGICKA))
	else
		frame.bgColor:SetEdgeColor(0, 0, 0, 0)
	end
end
]]
-------------------------------------------------------------------------------------------------
--  Visuals  --
-------------------------------------------------------------------------------------------------
function Jo.VisualAdded(event, unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue)
	if not DoesUnitExist(unitTag) then return end
	if not ZO_Group_IsGroupUnitTag(unitTag) then return end
	if Jo.unit[unitTag] == nil then return end

	if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
		Jo.SetShield(event, unitTag, value, maxValue)
	end
	if unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER then
		Jo.unit[unitTag].regen = value
		Jo.SetRegen(event, unitTag, statType, 1)
	end
end

function Jo.VisualUpdated(event, unitTag, unitAttributeVisual, statType, attributeType, powerType, oldValue, newValue, oldMaxValue, newMaxValue)
	if not DoesUnitExist(unitTag) then return end
	if not ZO_Group_IsGroupUnitTag(unitTag) then return end
	if Jo.unit[unitTag] == nil then return end

	if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
		Jo.SetShield(event, unitTag, newValue, newMaxValue)
	end
end

function Jo.VisualRemoved(event, unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue)
	if not DoesUnitExist(unitTag) then return end
	if not ZO_Group_IsGroupUnitTag(unitTag) then return end
	if Jo.unit[unitTag] == nil then return end

	if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
		Jo.SetShield(event, unitTag, 0)
	end
	if unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER then
		Jo.unit[unitTag].regen = 0
	end
end

-- Regen
function Jo.SetRegen(event, unitTag, statType, walker)
	if not Jo.savedVars.show.regen then return end
	if not DoesUnitExist(unitTag) then return end
	if not ZO_Group_IsGroupUnitTag(unitTag) then return end
	if Jo.unit[unitTag] == nil then return end
	local unit = Jo.unit[unitTag]
	local frame = Jo.frame[unitTag]

	if statType == STAT_HEALTH_REGEN_COMBAT then
		local regen = unit.regen or 0
		if regen > 0 then
			local forward = unit.regen > 0
			local bar = frame.bar
			local width = bar:GetWidth() --* 0.95
			local offsetX = width - Jo.arrowSize

			if walker > Jo.maxArrows then
				walker = 1
			end

			local arrow = frame.arrow[walker]

			arrow:SetDimensions(Jo.arrowSize, Jo.arrowSize)
			arrow:SetAnchor(RIGHT, bar, RIGHT, -offsetX, 1)
			arrow.animation:GetFirstAnimation():SetTranslateDeltas(offsetX - 3, 0)

			arrow:SetHidden(false)

			if forward then
				arrow:SetTextureCoords(1, 0, 0, 1)
				arrow.animation:PlayFromStart()
			else
				arrow:SetTextureCoords(0, 1, 0, 1)
				arrow.animation:PlayFromEnd()
			end
			zo_callLater(function() Jo.SetRegen(event, unitTag, statType, walker) end, 750) -- (1000 == 1sec)
			walker = walker+1
		end
	end
end

-- Shield
function Jo.GetShield(unitTag)
	if not DoesUnitExist(unitTag) then return end
	if not ZO_Group_IsGroupUnitTag(unitTag) then return end
	if Jo.unit[unitTag] == nil then return end
	local unit = Jo.unit[unitTag]
	local frame = Jo.frame[unitTag]

	local value, maxValue = GetUnitAttributeVisualizerEffectInfo(unitTag, ATTRIBUTE_VISUAL_POWER_SHIELDING)
	if value ~= nil then
		Jo.SetShield(nil, unitTag, value, maxValue)
	end
end

function Jo.SetShield(event, unitTag, value, maxValue)
	if not DoesUnitExist(unitTag) then return end
	if not ZO_Group_IsGroupUnitTag(unitTag) then return end
	if Jo.unit[unitTag] == nil then return end
	local unit = Jo.unit[unitTag]
	local frame = Jo.frame[unitTag]
	local powerValue, powerMax, powerEffectiveMax = GetUnitPower(unitTag, POWERTYPE_HEALTH)

	if event == EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED then
		frame.bar:SetMinMax(0, powerMax)
	end

	if value and value > 0 then
		frame.shield:SetWidth(Jo.indicatorSize)
		unit.shield = value
		local shield = value

		if event == EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED then
			local newMax = powerMax+shield
			local maxWidth = frame.bar:GetWidth()
			local offsetX = (powerValue*maxWidth)/newMax
			frame.shieldBar:ClearAnchors()
			frame.shieldBar:SetAnchor(TOPLEFT, frame.statusBar, TOPLEFT, (2*sf)+offsetX, (2*sf))
			frame.shieldBar:SetWidth(maxWidth-offsetX)
			frame.shieldBar:SetMinMax(0, (newMax-powerValue))
			frame.shieldBar:SetValue(shield)
		end
	else
		frame.shield:SetWidth(0)
		unit.shield = 0
	end

	Jo.UpdatePower(event, unitTag, nil, nil, powerValue, powerMax, powerEffectiveMax)
end

-------------------------------------------------------------------------------------------------
--  Power  --
-------------------------------------------------------------------------------------------------
function Jo.UpdatePower(event, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
	if not DoesUnitExist(unitTag) then return end
	if not ZO_Group_IsGroupUnitTag(unitTag) then return end
	if Jo.unit[unitTag] == nil then return end
	local unit = Jo.unit[unitTag]
	local frame = Jo.frame[unitTag]
	local shield = unit.shield and unit.shield or 0

	if IsUnitDead(unitTag) then return Jo.UpdateDeath(nil, unitTag, true) end

	frame.dead:SetHidden(true)
	frame.statusBar:SetHidden(false)

	if powerValue and powerValue > 0 then
		local health = zo_round(powerValue/1000).."k"
		if Jo.savedVars.show.fullNumberHealth then
		    if powerValue > 999 then
				health = (powerValue - powerValue % 1000) / 1000 .. "," .. string.format("%03d",powerValue%1000)
			else
				health = powerValue
			end
		end
		local tipHealth = powerValue
		local maxHealth = zo_round(powerEffectiveMax/1000).."k"		
		if Jo.savedVars.show.fullNumberHealth then
			maxHealth = (powerEffectiveMax - powerEffectiveMax % 1000) / 1000 .. "," .. string.format("%03d",powerEffectiveMax%1000)
		end
		local tipMax = powerEffectiveMax
		local percentage = " ("..zo_round((powerValue/powerEffectiveMax)*100).."%)"
		local values = health.." / "..maxHealth
		local tipValues = tipHealth.." / "..tipMax
		if shield > 0 then
			values = values.." ["..zo_round(shield/1000).."k]"
			tipValues = tipValues.." ["..shield.."]"
		end
		values = values..percentage
		tipValues = tipValues..percentage

		if Jo.savedVars.show.healthValues then
			frame.info:SetText(values)
		else
			frame.info:SetText("")
		end
		unit.healthTip = tipValues
	else
		frame.info:SetText("")
		unit.healthTip = ""
	end

	if shield > 0 then
		local newMax = powerMax+shield
		local maxWidth = frame.bar:GetWidth()
		local offsetX = (powerValue*maxWidth)/newMax

		frame.shieldBar:SetDimensions((maxWidth-offsetX), frame.bar:GetHeight())
		frame.shieldGloss:SetDimensions(frame.shieldBar:GetDimensions())
		frame.shieldBar:SetHidden(false)
		frame.shieldGloss:SetHidden(false)
		ZO_StatusBar_SmoothTransition(frame.bar, powerValue, newMax)
		ZO_StatusBar_SmoothTransition(frame.shieldBar, shield, (newMax-powerValue))
	else
		frame.shield:SetWidth(0)
		frame.shieldBar:SetHidden(true)
		frame.shieldGloss:SetHidden(true)
		ZO_StatusBar_SmoothTransition(frame.bar, powerValue, powerMax)
	end
end

-------------------------------------------------------------------------------------------------
--  Stealth  --
-------------------------------------------------------------------------------------------------
function Jo.UpdateStealth(event, unitTag, stealthState)
	if not DoesUnitExist(unitTag) then return end
	if not ZO_Group_IsGroupUnitTag(unitTag) then return end
	if Jo.unit[unitTag] == nil then return end
	local unit = Jo.unit[unitTag]
	local frame = Jo.frame[unitTag]

	if stealthState == DISGUISE_STATE_NONE and stealthState == STEALTH_STATE_NONE then
		frame.hidden:SetWidth(0)
	else
		frame.hidden:SetWidth(Jo.indicatorSize)
	end
end

-------------------------------------------------------------------------------------------------
--  Support range  --
-------------------------------------------------------------------------------------------------
function Jo.UpdateSupportRange(event, unitTag, status)
	if not DoesUnitExist(unitTag) then return end
	if not ZO_Group_IsGroupUnitTag(unitTag) then return end
	if Jo.unit[unitTag] == nil then return end
	local unit = Jo.unit[unitTag]
	local frame = Jo.frame[unitTag]

	if not status then
		frame:SetAlpha(Jo.savedVars.opacity.oorAlpha)
	else
		frame:SetAlpha(1)
	end
end

-------------------------------------------------------------------------------------------------
--  Death  --
-------------------------------------------------------------------------------------------------
function Jo.UpdateDeath(event, unitTag, isDead)
	if not DoesUnitExist(unitTag) then return end
	if not ZO_Group_IsGroupUnitTag(unitTag) then return end
	if Jo.unit[unitTag] == nil then return end
	local unit = Jo.unit[unitTag]
	local frame = Jo.frame[unitTag]

	if isDead then
		unit.shield = 0
		unit.regen = 0
		frame.class:SetText(unit.classIcon)
		frame.shield:SetWidth(0)
		frame.hidden:SetWidth(0)
		frame.dead:SetHidden(false)
		frame.statusBar:SetHidden(true)
		frame.info:SetText("")
		frame.bar:SetHeight(Jo.innerBarHeight)
		frame.gloss:SetHeight(frame.bar:GetHeight())
		--frame.bgColor:SetCenterColor(0, 0, 0, 0)
	else
		frame.class:SetText(unit.classIcon..unit.level)
		frame.dead:SetHidden(true)
		frame.statusBar:SetHidden(false)
	end
	Jo.CheckRes(unitTag)
end

-- Resurrection
function Jo.CheckRes(unitTag)
  evm:UnregisterForUpdate(Jo.name.."CheckRes"..unitTag)

  if not DoesUnitExist(unitTag) then return end
	if not ZO_Group_IsGroupUnitTag(unitTag) then return end
	if Jo.unit[unitTag] == nil then return end
	local unit = Jo.unit[unitTag]
	local frame = Jo.frame[unitTag]

	if IsUnitDead(unitTag) then
		if IsUnitBeingResurrected(unitTag) then
			frame.class:SetText(unit.classIcon..unit.level)
			frame.dead:SetHidden(true)
			frame.statusBar:SetHidden(true)
			frame.info:SetText(GetString(SI_JOGROUP_BEINGRESSED))

		elseif DoesUnitHaveResurrectPending(unitTag) then
			frame.class:SetText(unit.classIcon..unit.level)
			frame.dead:SetHidden(true)
			frame.statusBar:SetHidden(true)
			frame.info:SetText(GetString(SI_JOGROUP_RESPENDING))
		else
			frame.class:SetText(unit.classIcon)
			frame.dead:SetHidden(false)
			frame.statusBar:SetHidden(true)
			frame.info:SetText("")
		end
		evm:RegisterForUpdate(Jo.name.."CheckRes"..unitTag, 500, function() Jo.CheckRes(unitTag) end)

	elseif IsUnitReincarnating(unitTag) then
		frame.class:SetText(unit.classIcon..unit.level)
		frame.dead:SetHidden(true)
		frame.statusBar:SetHidden(true)
		frame.info:SetText(GetString(SI_JOGROUP_REINCARNATING))

		evm:RegisterForUpdate(Jo.name.."CheckRes"..unitTag, 500, function() Jo.CheckRes(unitTag) end)
	else
		frame.class:SetText(unit.classIcon..unit.level)
		frame.dead:SetHidden(true)
		frame.statusBar:SetHidden(false)

		local powerValue, powerMax, powerEffectiveMax = GetUnitPower(unitTag, POWERTYPE_HEALTH)
		Jo.UpdatePower(nil, unitTag, nil, nil, powerValue, powerMax, powerEffectiveMax)
	end
end

-------------------------------------------------------------------------------------------------
--  Buffs  --
-------------------------------------------------------------------------------------------------
function Jo.UpdateBuffs(unitTag)
	if not DoesUnitExist(unitTag) then return end
	if not ZO_Group_IsGroupUnitTag(unitTag) then return end
	if Jo.unit[unitTag] == nil then return end
	local unit = Jo.unit[unitTag]
	local frame = Jo.frame[unitTag]
	local numBuffs = GetNumBuffs(unitTag)

	unit.buffName = ""
	unit.buffEndTime = 0

	frame.bgColor:SetCenterColor(0, 0, 0, 0)

	if numBuffs > 0 then
		for i = 1, numBuffs do
			local buffName, startTime, endTime, _, stackCount, iconFile, buffType, effectType, abilityType, statusEffectType, abilityId = GetUnitBuffInfo(unitTag, i)

			-- Food
			if Jo.isFoodBuff[abilityId] then
				unit.buffName = zo_strformat(SI_ABILITY_TOOLTIP_NAME, buffName)
				unit.buffEndTime = endTime
				if Jo.savedVars.show.foodBuffs then frame.food:SetWidth(Jo.indicatorSize) end
			end

			-- War Horn
			if Jo.savedVars.show.warHorn then
				if Jo.isHorny[abilityId] then
					frame.bgColor:SetCenterColor(unpack(Jo.savedVars.colours.warHorn))
					frame.bgColor:SetAlpha(0.5)
				end
			end			
			
			if Jo.savedVars.show.crShade then
				if Jo.hasCRShade[abilityId] then
					frame.bgColor:SetCenterColor(unpack(Jo.savedVars.colours.crShade))
					frame.bgColor:SetAlpha(0.5)
				end
			end
		end
	end

	if unit.buffEndTime < GetFrameTimeSeconds() then
		unit.buffName = ""
		unit.buffEndTime = 0
		frame.food:SetWidth(0)
	end
end

-------------------------------------------------------------------------------------------------
--  Create  --
-------------------------------------------------------------------------------------------------
function Jo.CreateUnits()
	for i = 1, GROUP_SIZE_MAX do
		Jo.unit["group"..i] = {
			index = 0,
			accountName = "",
			characterName = "",
			name = "",
			offline = 0,
			level = "",
			isLeader = false,
			role = nil,
			class = 6,
			classIcon = "",
			className = "",
			healthTip = "",
			shield = 0,
			hidden = false,
			buffName = "",
			buffEndTime = 0,
			regen = 0,
			mark = 0,
		}
	end

	Jo.CustomizeUnits()

	Jo.fragment = ZO_SimpleSceneFragment:New(Jo.container)
	HUD_SCENE:AddFragment(Jo.fragment)
	HUD_UI_SCENE:AddFragment(Jo.fragment)
	SIEGE_BAR_SCENE:AddFragment(Jo.fragment)
	SIEGE_BAR_UI_SCENE:AddFragment(Jo.fragment)

	zo_callLater(Jo.RegisterEvents, 2000) -- (1000 == 1sec)
end

-------------------------------------------------------------------------------------------------
--  Customize  --
-------------------------------------------------------------------------------------------------
function Jo.CustomizeUnits()
	ZO_UnitFramesGroups:SetHidden(not Jo.savedVars.show.defaultFrames)

	sf = 1/GetSetting(SETTING_TYPE_UI, UI_SETTING_CUSTOM_SCALE)

	local unitsPerColumn = Jo.savedVars.ordening.unitsPerColumn
	local padding = Jo.savedVars.ordening.padding
	local frameWidth = Jo.savedVars.frameWidth
	local s = "|"
	local fontFam = "$("..Jo.savedVars.text.fontFam..")"
	local fontSize = Jo.savedVars.text.fontSize*sf
	local fontThin = "soft-shadow-thin"
	local fontThick = "soft-shadow-thick"
	local compactMode = Jo.savedVars.compactMode
	local bgAlpha = Jo.savedVars.opacity.bgAlpha
	local glossAlpha = Jo.savedVars.opacity.glossAlpha

	for i = 1, GROUP_SIZE_MAX do
		local unitTag = "group"..i
		local frame = Jo.frame[unitTag]

		frame.name:SetFont(fontFam..s..fontSize..s..fontThin)
		frame.class:SetFont(fontFam..s..(fontSize-sf)..s..fontThin)
		frame.info:SetFont(fontFam..s..(fontSize-sf)..s..fontThick)

		Jo.indicatorSize = fontSize+(2*sf)
		Jo.leaderIconSize = fontSize+(2*sf)
		Jo.classIconSize = fontSize+(4*sf)
		Jo.champIconSize = fontSize-(1*sf)
		Jo.arrowSize = fontSize+(3*sf)

		if compactMode then
			Jo.statusBarHeight = fontSize+(12*sf)
			Jo.deadIconSize = (3*sf) + Jo.statusBarHeight + (8*sf)
			Jo.frameHeight = (3*sf) + Jo.statusBarHeight + fontSize + (6*sf)

			frame.class:SetHidden(true)
			frame.class:ClearAnchors()
			frame.class:SetAnchor(TOPLEFT, frame.statusBar, TOPLEFT, -(2*sf), -(4*sf))
		else
			-- Normal size
			Jo.statusBarHeight = fontSize+(8*sf)
			Jo.deadIconSize = (3*sf) + Jo.statusBarHeight + fontSize-(2*sf) + (6*sf)
			Jo.frameHeight = (3*sf) + Jo.statusBarHeight + 2*fontSize + (6*sf)

			frame.class:SetHidden(false)
			frame.class:ClearAnchors()
			frame.class:SetAnchor(BOTTOMLEFT, frame.statusBar, TOPLEFT, -(2*sf), -(4*sf))
		end
		Jo.innerBarHeight = Jo.statusBarHeight-(4*sf)

		frame.name:SetDimensions(frameWidth-(6*sf), fontSize)
		frame.class:SetDimensions(frame.name:GetDimensions())
		frame.shield:SetHeight(Jo.indicatorSize)
		frame.hidden:SetHeight(Jo.indicatorSize)
		frame.food:SetHeight(Jo.indicatorSize)
		frame.dead:SetDimensions(Jo.deadIconSize, Jo.deadIconSize)

		frame.statusBar:SetDimensions(frameWidth-(4*sf), Jo.statusBarHeight)
		frame.bar:SetDimensions(frame.statusBar:GetWidth()-(4*sf), Jo.innerBarHeight)
		frame.gloss:SetDimensions(frame.bar:GetDimensions())
		frame.shieldBar:SetDimensions(frame.bar:GetDimensions())
		frame.shieldGloss:SetDimensions(frame.shieldBar:GetDimensions())
		frame.shieldBar:SetColor(unpack(Jo.savedVars.colours.shield))

		frame.bg:SetAlpha(bgAlpha)
		frame.barBg:SetEdgeTexture(nil, 1, 1, (2*sf))
		frame.gloss:SetAlpha(glossAlpha)
		frame.shieldGloss:SetAlpha(glossAlpha)

		frame:SetDimensions(frameWidth, Jo.frameHeight)
		frame.bg:SetDimensions(frame:GetWidth()+(5*sf), frame:GetHeight()+(20*sf))

		if not IsUnitGrouped("player") then
			if Jo.savedVars.show.healthValues then
				frame.info:SetText("18k / 18k (100%)")
			else
				frame.info:SetText("")
			end
		end
	end

	local maxWidth = (frameWidth * (GROUP_SIZE_MAX/unitsPerColumn)) + ((padding*sf) * (unitsPerColumn-1))
	local maxHeight = (Jo.frameHeight * unitsPerColumn) + ((padding*sf) * (unitsPerColumn-1))
	Jo.container:SetDimensions(maxWidth, maxHeight)

	Jo.UpdateUnits()
	Jo.ReAnchor()
end

-------------------------------------------------------------------------------------------------
--  Anchors  --
-------------------------------------------------------------------------------------------------
function Jo.ReAnchor()
	for i = 1, GROUP_SIZE_MAX do
		Jo.frame["group"..i]:ClearAnchors()
	end

	local sort = Jo.savedVars.ordening.sort
	local directionX = Jo.savedVars.ordening.directionX
	local directionY = Jo.savedVars.ordening.directionY
	local unitsPerColumn = Jo.savedVars.ordening.unitsPerColumn
	local anchorUnit = TOPLEFT
	local anchorTargetAnchor = BOTTOMLEFT
	local anchorTargetAnchorNewCol = TOPRIGHT
	local anchorOffsetX = Jo.savedVars.ordening.padding*sf
	local anchorOffsetY = anchorOffsetX

	if directionX == "right" and directionY == "up" then
		anchorUnit = BOTTOMLEFT
		anchorTargetAnchor = TOPLEFT
		anchorTargetAnchorNewCol = BOTTOMRIGHT
		anchorOffsetY = -anchorOffsetY
	end

	if directionX == "left" and directionY == "down" then
		anchorUnit = TOPRIGHT
		anchorTargetAnchor = BOTTOMRIGHT
		anchorTargetAnchorNewCol = TOPLEFT
		anchorOffsetX = -anchorOffsetX
	end

	if directionX == "left" and directionY == "up" then
		anchorUnit = BOTTOMRIGHT
		anchorTargetAnchor = TOPRIGHT
		anchorTargetAnchorNewCol = BOTTOMLEFT
		anchorOffsetX = -anchorOffsetX
		anchorOffsetY = -anchorOffsetY
	end

	if IsUnitGrouped("player") then
		if sort == "role" then
			-- Sort by role
			local sortIndex = 0
			local sortList = {}

			for i = 1, GROUP_SIZE_MAX do
				local unitTag = "group"..i
				local unit = Jo.unit[unitTag]
				if DoesUnitExist(unitTag) and unit.role == 2 then
					sortIndex = sortIndex + 1
					sortList[sortIndex] = unitTag
				end
			end

			for i = 1, GROUP_SIZE_MAX do
				local unitTag = "group"..i
				local unit = Jo.unit[unitTag]
				if DoesUnitExist(unitTag) and unit.role == 4 then
					sortIndex = sortIndex + 1
					sortList[sortIndex] = unitTag
				end
			end

			for i = 1, GROUP_SIZE_MAX do
				local unitTag = "group"..i
				local unit = Jo.unit[unitTag]
				if DoesUnitExist(unitTag) and unit.role ~= 2 and unit.role ~= 4 then
					sortIndex = sortIndex + 1
					sortList[sortIndex] = unitTag
				end
			end

			Jo.frame[sortList[1]]:SetAnchor(anchorUnit, Jo.container, anchorUnit)

			for i = 1, GROUP_SIZE_MAX do
				local unitTag = sortList[i]
				local frame = Jo.frame[unitTag]

				if i > 1 then
					if DoesUnitExist(unitTag) then
						if math.fmod((i-1), unitsPerColumn) == 0 then
							frame:SetAnchor(anchorUnit, Jo.frame[sortList[i-unitsPerColumn]], anchorTargetAnchorNewCol, anchorOffsetX, 0)
						else
							frame:SetAnchor(anchorUnit, Jo.frame[sortList[i-1]], anchorTargetAnchor, 0, anchorOffsetY)
						end
					end
				end
			end
		else
			-- Sort by index
			local firstFrameSet = false

			for i = 1, GROUP_SIZE_MAX do
				local unitTag = GetGroupUnitTagByIndex(i)
				local frame = Jo.frame[unitTag]

				if not firstFrameSet then
					if DoesUnitExist(unitTag) then
						frame:SetAnchor(anchorUnit, Jo.container, anchorUnit)
						firstFrameSet = true
					end
				else
					if i > 1 then
						if DoesUnitExist(unitTag) then
							if math.fmod((i-1), unitsPerColumn) == 0 then
								frame:SetAnchor(anchorUnit, Jo.frame[GetGroupUnitTagByIndex(i-unitsPerColumn)], anchorTargetAnchorNewCol, anchorOffsetX, 0)
							else
								frame:SetAnchor(anchorUnit, Jo.frame[GetGroupUnitTagByIndex(i-1)], anchorTargetAnchor, 0, anchorOffsetY)
							end
						end
					end
				end
			end
		end
	else
		-- Not in group
		Jo.frame["group"..1]:SetAnchor(anchorUnit, Jo.container, anchorUnit)

		for i = 1, GROUP_SIZE_MAX do
			local unitTag = "group"..i
			local frame = Jo.frame[unitTag]

			if i > 1 then
				if math.fmod((i-1), unitsPerColumn) == 0 then
					frame:SetAnchor(anchorUnit, Jo.frame["group"..(i-unitsPerColumn)], anchorTargetAnchorNewCol, anchorOffsetX, 0)
				else
					frame:SetAnchor(anchorUnit, Jo.frame["group"..(i-1)], anchorTargetAnchor, 0, anchorOffsetY)
				end
			end
		end
	end
end

-------------------------------------------------------------------------------------------------
--  Unlock  --
-------------------------------------------------------------------------------------------------
function Jo.Unlock(unlock)
	Jo.unlocked = unlock

	for i = 1, GROUP_SIZE_MAX do
		Jo.frame["group"..i]:SetMouseEnabled(not unlock)
		if not IsUnitGrouped("player") then
			Jo.frame["group"..i]:SetHidden(not unlock)
		end
	end
	Jo.container:SetMouseEnabled(unlock)
	Jo.container:SetMovable(unlock)

	if unlock then
		Jo.container:SetHidden(not unlock)
		d(GetString(SI_JOGROUP_UNLOCKED))
	else
		d(GetString(SI_JOGROUP_LOCKED))
		Jo.UpdateUnits()
	end
	Jo.container.backdrop:SetHidden(not unlock)
end

function Jo.SaveLoc()
	Jo.savedVars.position.offsetX = zo_round(Jo.container:GetLeft())
	Jo.savedVars.position.offsetY = zo_round(Jo.container:GetTop())

	Jo.container:ClearAnchors()
	Jo.container:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, Jo.savedVars.position.offsetX, Jo.savedVars.position.offsetY)
end

-------------------------------------------------------------------------------------------------
--  Initialize  --
-------------------------------------------------------------------------------------------------
function Jo.OnAddOnLoaded(event, addonName)
	if addonName ~= Jo.name then return end

	JoGroup:Initialize()
end

function JoGroup:Initialize()
	Jo.savedVars = ZO_SavedVars:NewAccountWide("JoGroupVars", Jo.varsVersion, nil, Jo.defaults)

	Jo.CreateControls()
	Jo.CreateSettingsWindow()
	Jo.CreateUnits()

	Jo.container:ClearAnchors()
	Jo.container:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, Jo.savedVars.position.offsetX, Jo.savedVars.position.offsetY)
	Jo.container:SetHandler("OnMoveStop", Jo.SaveLoc)

	evm:UnregisterForEvent(Jo.name, EVENT_ADD_ON_LOADED)
end

-------------------------------------------------------------------------------------------------
--  Refresh  --
-------------------------------------------------------------------------------------------------
function Jo.DelayedRefreshData(event)
	Jo.delayedRebuildCounter = Jo.delayedRebuildCounter - 1
	if Jo.delayedRebuildCounter == 0 then
		Jo.UpdateUnits(event)
	end
end

function Jo.RegisterDelayedRefresh(event)
	Jo.delayedRebuildCounter = Jo.delayedRebuildCounter + 1
	zo_callLater(function() Jo.DelayedRefreshData(event) end, 50)
end

function Jo.Refresh(event)
	if IsUnitGrouped("player") then
		Jo.RegisterDelayedRefresh(event)
	end
end

-------------------------------------------------------------------------------------------------
--  Register Events --
-------------------------------------------------------------------------------------------------
evm:RegisterForEvent(Jo.name, EVENT_ADD_ON_LOADED, Jo.OnAddOnLoaded)

function Jo.RegisterEvents()
	evm:RegisterForEvent(Jo.name, EVENT_UNIT_CREATED, Jo.RegisterDelayedRefresh)
	evm:RegisterForEvent(Jo.name, EVENT_UNIT_DESTROYED, Jo.RegisterDelayedRefresh)
	evm:RegisterForEvent(Jo.name, EVENT_LEVEL_UPDATE, Jo.UpdateUnits)
	evm:RegisterForEvent(Jo.name, EVENT_CHAMPION_POINT_UPDATE, Jo.UpdateUnits)
	evm:RegisterForEvent(Jo.name, EVENT_ZONE_UPDATE, Jo.UpdateUnits)
	evm:RegisterForEvent(Jo.name, EVENT_GROUP_MEMBER_ROLES_CHANGED, Jo.RegisterDelayedRefresh)
	evm:RegisterForEvent(Jo.name, EVENT_GROUP_MEMBER_CONNECTED_STATUS, Jo.UpdateUnits)
	evm:RegisterForEvent(Jo.name, EVENT_LEADER_UPDATE, Jo.LeaderUpdated)
	evm:RegisterForEvent(Jo.name, EVENT_GROUP_UPDATE, Jo.RegisterDelayedRefresh)
	evm:RegisterForEvent(Jo.name, EVENT_PLAYER_ACTIVATED, Jo.RegisterDelayedRefresh)
	evm:RegisterForEvent(Jo.name, EVENT_GROUP_MEMBER_ACCOUNT_NAME_UPDATED, Jo.UpdateUnits)
	evm:RegisterForEvent(Jo.name, EVENT_DIFFICULTY_LEVEL_CHANGED, Jo.UpdateUnits)
	evm:RegisterForEvent(Jo.name, EVENT_GROUP_VETERAN_DIFFICULTY_CHANGED, Jo.UpdateUnits)

	evm:RegisterForEvent(Jo.name, EVENT_POWER_UPDATE, Jo.UpdatePower)
	evm:RegisterForEvent(Jo.name, EVENT_GROUP_SUPPORT_RANGE_UPDATE, Jo.UpdateSupportRange)
	evm:RegisterForEvent(Jo.name, EVENT_UNIT_DEATH_STATE_CHANGED, Jo.UpdateDeath)
	evm:RegisterForEvent(Jo.name, EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, Jo.VisualAdded)
	evm:RegisterForEvent(Jo.name, EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, Jo.VisualUpdated)
	evm:RegisterForEvent(Jo.name, EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, Jo.VisualRemoved)
	evm:RegisterForEvent(Jo.name, EVENT_STEALTH_STATE_CHANGED, Jo.UpdateStealth)
	evm:RegisterForEvent(Jo.name, EVENT_DISGUISE_STATE_CHANGED, Jo.UpdateStealth)

	evm:RegisterForEvent(Jo.name, EVENT_GROUP_INVITE_RECEIVED, Jo.NotifyInvited)
	evm:RegisterForEvent(Jo.name, EVENT_GROUP_MEMBER_JOINED, Jo.NotifyUnitJoined)
	evm:RegisterForEvent(Jo.name, EVENT_GROUP_MEMBER_LEFT, Jo.NotifyUnitLeft)

	evm:AddFilterForEvent(EVENT_UNIT_CREATED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
	evm:AddFilterForEvent(EVENT_UNIT_DESTROYED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
	evm:AddFilterForEvent(EVENT_LEVEL_UPDATE, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
	evm:AddFilterForEvent(EVENT_CHAMPION_POINT_UPDATE, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
	evm:AddFilterForEvent(EVENT_ZONE_UPDATE, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")

	evm:AddFilterForEvent(EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
	evm:AddFilterForEvent(EVENT_UNIT_DEATH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
	evm:AddFilterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
	evm:AddFilterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
	evm:AddFilterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
	evm:AddFilterForEvent(EVENT_STEALTH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
	evm:AddFilterForEvent(EVENT_DISGUISE_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")

	evm:RegisterForUpdate(Jo.name, 4000, Jo.Refresh) -- (1000 == 1sec)

	evm:RegisterForEvent(Jo.name, EVENT_INTERFACE_SETTING_CHANGED, Jo.CustomizeUnits)
end
