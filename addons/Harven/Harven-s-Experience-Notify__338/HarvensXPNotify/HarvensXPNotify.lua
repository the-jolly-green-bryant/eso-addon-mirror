HarvenXPNotify = ZO_Object:Subclass()

function HarvenXPNotify:New()
	HarvenXPNotify:Initialize()
	return HarvenXPNotify
end

local function setTimelineDelay(timeline, delay)
	for i = 1, timeline:GetNumAnimations() do
		timeline:SetAnimationOffset(timeline:GetAnimation(i), delay)
	end
end

local function setTimelineDuration(timeline, duration)
	for i = 1, timeline:GetNumAnimations() do
		timeline:GetAnimation(i):SetDuration(duration)
	end
end

function HarvenXPNotify:SetupOptions()
	local settings = LibHarvensAddonSettings:AddAddon("Harven's Experience Notify")
	if not settings then
		return
	end
	local slider

	local autoCloseStatsWindow = {
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = "Auto Close Stats Window",
		tooltip = "Automatically close the stats window after defined amount of time",
		getFunction = function()
			return self.sv.autoClose
		end,
		setFunction = function(state)
			self.sv.autoClose = state
			slider:SetEnabled(state)
		end
	}

	local autoCloseWaitTime = {
		type = LibHarvensAddonSettings.ST_SLIDER,
		label = "Auto Close Wait Time",
		min = 2,
		max = 30,
		step = 1,
		getFunction = function()
			return self.sv.autoCloseTime
		end,
		unit = "s",
		format = "%d",
		setFunction = function(value)
			self.sv.autoCloseTime = value
		end
	}

	local showOverallExperienceGain = {
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = "Show Overall Experience Gain",
		getFunction = function()
			return self.sv.showXp
		end,
		setFunction = function(state)
			self.sv.showXp = state
		end
	}

	local showTradeskillsExperienceGain = {
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = "Show Tradeskills Experience Gain",
		getFunction = function()
			return self.sv.showTradeskills
		end,
		setFunction = function(state)
			self.sv.showTradeskills = state
		end
	}

	local showSkillsExperienceGain = {
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = "Show Skills Experience Gain",
		getFunction = function()
			return self.sv.showSkills
		end,
		setFunction = function(state)
			self.sv.showSkills = state
			self:ResetAggregatedSkills()
		end
	}

	local showAbilitiesExperienceGain = {
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = "Show Abilities Experience Gain",
		getFunction = function()
			return self.sv.showAbilities
		end,
		setFunction = function(state)
			self.sv.showAbilities = state
			self:ResetAggregatedAbilities()
		end
	}

	local autoResetStatsatClose = {
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = "Auto Reset Stats at Close",
		getFunction = function()
			return self.sv.resetOnClose
		end,
		setFunction = function(state)
			self.sv.resetOnClose = state
		end
	}

	local autoHideStatsinCombat = {
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = "Auto Hide Stats in Combat",
		getFunction = function()
			return self.sv.closeInCombat
		end,
		setFunction = function(state)
			self.sv.closeInCombat = state
		end
	}

	local useColorsinStatsWindow = {
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = "Use Colors in Stats Window",
		getFunction = function()
			return self.sv.useColors
		end,
		setFunction = function(state)
			self.sv.useColors = state
		end
	}

	local statsWindowScale = {
		type = LibHarvensAddonSettings.ST_SLIDER,
		label = "Stats Window Scale",
		min = 0.3,
		max = 3,
		setp = 0.1,
		getFunction = function()
			return self.sv.scale
		end,
		format = "%.1f",
		setFunction = function(value)
			HarvensXPStatusWindow:SetScale(value)
			self.sv.scale = value
		end
	}

	local statsWindowBackgroundAlpha = {
		type = LibHarvensAddonSettings.ST_SLIDER,
		label = "Stats Window Background Alpha",
		min = 0,
		max = 1,
		setp = 0.1,
		getFunction = function()
			return self.sv.alpha
		end,
		format = "%.1f",
		setFunction = function(value)
			HarvensXPStatusWindowBg:SetAlpha(value)
			HarvensXPStatusWindowClose:SetAlpha(value)
			HarvensXPStatusWindowTitle:SetAlpha(value)
			HarvensXPStatusWindowDivider:SetAlpha(value)
			self.sv.alpha = value
		end
	}

	local logToChatWindow = {
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = "Log To Chat Window",
		getFunction = function()
			return self.sv.logToChatWindow
		end,
		setFunction = function(state)
			self.sv.logToChatWindow = state
		end
	}

	local textScrollSpeed = {
		type = LibHarvensAddonSettings.ST_SLIDER,
		label = "Text Scroll Speed",
		min = 0.1,
		max = 2,
		step = 0.1,
		getFunction = function()
			return 2.1 - self.sv.scrollSpeed
		end,
		format = "%.1f",
		setFunction = function(value)
			self.sv.scrollSpeed = 2.1 - value
		end
	}

	settings:AddSetting(autoCloseStatsWindow)
	slider = settings:AddSetting(autoCloseWaitTime)
	settings:AddSettings(
		{
			logToChatWindow,
			showOverallExperienceGain,
			showTradeskillsExperienceGain,
			showSkillsExperienceGain,
			showAbilitiesExperienceGain,
			autoResetStatsatClose,
			autoHideStatsinCombat,
			useColorsinStatsWindow,
			statsWindowScale,
			statsWindowBackgroundAlpha,
			textScrollSpeed
		}
	)
end

function HarvenXPNotify:ResetAggregatedSkills()
	for k in pairs(self.skillsAggregateXP) do
		self.skillsAggregateXP[k].gain = 0
	end
end

function HarvenXPNotify:ResetAggregatedAbilities()
	for k in pairs(self.abilitiesAgregateXP) do
		self.abilitiesAgregateXP[k].gain = 0
	end
end

function HarvenXPNotify:ResetAggregatedStats()
	self:ResetAggregatedSkills()
	self:ResetAggregatedAbilities()
end

function HarvenXPNotify:ResetStatsWindowContent(resetStats)
	if resetStats then
		self:ResetAggregatedStats()
	end
	self.labelPool:ReleaseAllObjects()
	if not self.sv.resetOnClose then
		HarvensXPStatusWindowReset:ClearAnchors()
		HarvensXPStatusWindowReset:SetAnchor(TOPLEFT, nil, TOPLEFT, 15, 50)
	end
end

function HarvenXPNotify:CloseStatusWindow()
	EVENT_MANAGER:UnregisterForUpdate("HarvensXPStatusCountdown")
	HarvensXPStatusWindow:SetHidden(true)
	-- HarvensXPStatusWindow:SetAlpha(1)
	self:ResetStatsWindowContent(self.sv.resetOnClose)
end

HarvenXPNotify.colorForSkill = {
	[SKILL_TYPE_CLASS] = {0, 1, 0},
	[SKILL_TYPE_ARMOR] = {1, 0, 1},
	[SKILL_TYPE_WEAPON] = {0, 0, 1},
	[SKILL_TYPE_RACIAL] = {1, 1, 1},
	[SKILL_TYPE_AVA] = {1, 0, 0},
	[SKILL_TYPE_GUILD] = {0.5, 0.5, 0},
	[SKILL_TYPE_WORLD] = {0.5, 1, 0.5},
	[SKILL_TYPE_CHAMPION] = {1, 0.5, 0}
}

function HarvenXPNotify:OutputToChat(text, r, g, b)
	if self.sv.logToChatWindow then
		--CHAT_ROUTER:FormatAndAddChatMessage("AddSystemMessage", string.format("|c%.2x%.2x%.2x%s|r", math.floor(r * 255), math.floor(g * 255), math.floor(b * 255), text))
		CHAT_ROUTER:FormatAndAddChatMessage(EVENT_BROADCAST, string.format("|c%.2x%.2x%.2x%s|r", math.floor(r * 255), math.floor(g * 255), math.floor(b * 255), text))
	end
end

function HarvenXPNotify:UpdateStatsWindow()
	local lastControl = nil
	local lastColorLight = false

	if self.sv.showSkills then
		for _, v in pairs(self.skillsAggregateXP) do
			if v.gain > 0 and v.skillType ~= SKILL_TYPE_TRADESKILL then
				local control, ckey = self.labelPool:AcquireObject()
				local perc = (v.currentXP - v.lastRankXP) / (v.nextRankXP - v.lastRankXP) * 100
				local gainPerc = v.gain / (v.nextRankXP - v.lastRankXP) * 100
				local text = string.format("+%d XP (%.1f/%.1f%%) in %s", v.gain, gainPerc, perc, zo_strformat("<<t:1>>", v.name))
				if not self.sv.useColors then
					control:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, lastColorLight and INTERFACE_TEXT_COLOR_NORMAL or INTERFACE_TEXT_COLOR_SELECTED))
					lastColorLight = not lastColorLight
				elseif self.colorForSkill[v.skillType] then
					control:SetColor(unpack(self.colorForSkill[v.skillType]), 1)
				else
					control:SetColor(0.5, 0.5, 0.5, 1)
				end
				control:SetText(text)
				control:ClearAnchors()
				if lastControl then
					control:SetAnchor(TOPLEFT, lastControl, TOPLEFT, 0, 24)
				else
					control:SetAnchor(TOPLEFT, nil, TOPLEFT, 15, 50)
				end
				lastControl = control
				control:SetHidden(false)
				self:OutputToChat(text, control:GetColor())
			end
		end
	end

	if self.sv.showAbilities then
		for _, v in pairs(self.abilitiesAgregateXP) do
			if v.gain > 0 then
				local control, ckey = self.labelPool:AcquireObject()
				local perc = (v.currentXP - v.lastRankXP) / (v.nextRankXP - v.lastRankXP) * 100
				local gainPerc = v.gain / (v.nextRankXP - v.lastRankXP) * 100
				local text = string.format("+%d XP (%.1f/%.1f%%) in %s", v.gain, gainPerc, perc, zo_strformat("<<t:1>>", v.morphName))
				if not self.sv.useColors then
					control:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, lastColorLight and INTERFACE_TEXT_COLOR_NORMAL or INTERFACE_TEXT_COLOR_SELECTED))
					lastColorLight = not lastColorLight
				else
					control:SetColor(1, 0.58, 0, 1)
				end
				control:SetText(text)
				control:ClearAnchors()
				if lastControl then
					control:SetAnchor(TOPLEFT, lastControl, TOPLEFT, 0, 24)
				else
					control:SetAnchor(TOPLEFT, nil, TOPLEFT, 15, 50)
				end
				lastControl = control
				control:SetHidden(false)
				self:OutputToChat(text, control:GetColor())
			end
		end
	end

	if self.sv.resetOnClose and not HarvensXPStatusWindowReset:IsHidden() then
		HarvensXPStatusWindowReset:SetHidden(true)
	elseif not self.sv.resetOnClose then
		if HarvensXPStatusWindowReset:IsHidden() then
			HarvensXPStatusWindowReset:SetHidden(false)
		end
		HarvensXPStatusWindowReset:ClearAnchors()
		if lastControl == nil then
			HarvensXPStatusWindowReset:SetAnchor(TOPLEFT, nil, TOPLEFT, 15, 50)
		else
			HarvensXPStatusWindowReset:SetAnchor(TOPLEFT, lastControl, BOTTOMLEFT, 0, 12)
		end
	end
end

local function StatusWindowCountdown(...)
	HarvenXPNotify:StatusWindowCountdown(...)
end

function HarvenXPNotify:StatusWindowCountdown()
	self.countdown = self.countdown - 1
	if self.countdown == 1 then
		self.statsWindowTimeline:PlayFromStart()
	elseif self.countdown == 0 then
		self:CloseStatusWindow()
	end
end

function HarvenXPNotify:ShowStatusWindow()
	HarvensXPStatusWindow:SetAlpha(1)
	HarvensXPStatusWindow:SetHidden(self.sv.logToChatWindow)
	EVENT_MANAGER:UnregisterForUpdate("HarvensXPStatusAggregateWait")
	self.isUpdateRegistered = false
	self.showStatusWindowLater = false
	self.countdown = self.sv.autoCloseTime
	if self.sv.autoClose then
		EVENT_MANAGER:UnregisterForUpdate("HarvensXPStatusCountdown")
		EVENT_MANAGER:RegisterForUpdate("HarvensXPStatusCountdown", 1000, StatusWindowCountdown)
	end

	self:UpdateStatsWindow()
end

local function ShowStatusWindow(...)
	HarvenXPNotify:ShowStatusWindow(...)
end

function HarvenXPNotify:TryShowStatusWindow()
	if not IsUnitInCombat("player") then
		if HarvensXPStatusWindow:IsHidden() then
			if self.isUpdateRegistered then
				EVENT_MANAGER:UnregisterForUpdate("HarvensXPStatusAggregateWait")
			else
				self.isUpdateRegistered = true
			end
			EVENT_MANAGER:RegisterForUpdate("HarvensXPStatusAggregateWait", 1000, ShowStatusWindow)
		else
			self:ResetStatsWindowContent(false)
			self:UpdateStatsWindow()
			self.countdown = self.sv.autoCloseTime
			if self.sv.autoClose or self.sv.logToChatWindow then
				EVENT_MANAGER:UnregisterForUpdate("HarvensXPStatusCountdown")
				EVENT_MANAGER:RegisterForUpdate("HarvensXPStatusCountdown", 1000, StatusWindowCountdown)
			end
		end
	else
		self.showStatusWindowLater = true
	end
end

function HarvenXPNotify:OnCombatState(eventCode, inCombat)
	if inCombat and not HarvensXPStatusWindow:IsHidden() and self.sv.closeInCombat then
		self:CloseStatusWindow()
	elseif not inCombat and self.showStatusWindowLater then
		self:TryShowStatusWindow()
	end
end

function HarvenXPNotify:OnExperienceGain()
	if IsChampionSystemUnlocked() then
		local curXp = GetPlayerChampionXP()
		local aggregate = self.skillsAggregateXP[-1]
		aggregate.nextRankXP = GetNumChampionXPInChampionPoint(GetPlayerChampionPointsEarned())
		if curXp < aggregate.currentXP then
			aggregate.gain = aggregate.gain + aggregate.nextRankXP - aggregate.currentXP + curXp
		else
			aggregate.gain = aggregate.gain + curXp - aggregate.currentXP
		end
		aggregate.currentXP = curXp
		self:TryShowStatusWindow()
	end
end

function HarvenXPNotify:OnExperienceUpdate(eventCode, tag, exp, maxExp, reason, ...)
	if exp == 0 or maxExp == 0 then
		return
	end
	if tag ~= "player" and tag ~= "tradeskill" then
		return
	end

	local now = GetFrameTimeMilliseconds()
	local gain = 0
	local perc = "0"
	local gainPerc = "0"
	local skillIndex = reason

	if tag == "player" then
		gain = exp - self.currentXp
		self.currentXp = exp
		if reason == PROGRESS_REASON_NONE then
			return
		end
		if not self.sv.showXp then
			return
		end
	else
		local key = SKILL_TYPE_TRADESKILL .. " " .. reason
		gain = exp - self.skillsAggregateXP[key].currentXP
		self.skillsAggregateXP[key].currentXP = exp
		reason = GetSkillLineInfo(SKILL_TYPE_TRADESKILL, reason)
	end

	if gain <= 0 then
		return
	end

	if maxExp > 0 then
		if tag == "player" then
			perc = string.format("%.1f", exp / maxExp * 100)
		else
			local lastRank = GetSkillLineXPInfo(SKILL_TYPE_TRADESKILL, skillIndex)
			maxExp = maxExp - lastRank
			exp = exp - lastRank
			if maxExp > 0 then
				perc = string.format("%.1f", exp / maxExp * 100)
			end
		end
		gainPerc = string.format("%.1f", gain / maxExp * 100)
	end

	local control, ckey = self.controlPool:AcquireObject()

	control.hPoolKey = ckey
	control:ClearAnchors()
	if tag == "player" then
		control:GetNamedChild("Text"):SetColor(0, 1, 1, 1)
		control:GetNamedChild("Text"):SetText(string.format("+%d XP (%.1f/%.1f%%) %s", gain, gainPerc, perc, ((self.reasons[reason] ~= nil) and self.reasons[reason] or self.reasons[PROGRESS_REASON_OTHER])))
		control:SetAnchor(CENTER, GuiRoot, CENTER, -control:GetNamedChild("Text"):GetTextWidth() / 2, 0)
	else
		control:GetNamedChild("Text"):SetColor(1, 1, 0, 1)
		control:GetNamedChild("Text"):SetText(string.format("+%d XP (%.1f/%.1f%%) in %s", gain, gainPerc, perc, zo_strformat("<<t:1>>", reason)))
		control:SetAnchor(TOPLEFT, GuiRoot, nil, 0, 0)
	end
	control:SetAlpha(0)
	control:SetHidden(false)

	local timeline, tkey = self.timelinePool:AcquireObject()

	local offset = self.baseOffset * self.sv.scrollSpeed

	local diff = now - self.lastNotify
	if diff < 0 then
		diff = 0 - diff
		setTimelineDelay(timeline, diff + offset)
		self.lastNotify = self.lastNotify + offset
	elseif diff < offset then
		setTimelineDelay(timeline, offset - diff)
		self.lastNotify = self.lastNotify + offset - diff
	else
		self.lastNotify = now
		setTimelineDelay(timeline, 0)
	end

	setTimelineDuration(timeline, self.baseDuration * self.sv.scrollSpeed)

	timeline.hPoolKey = tkey

	if tag == "player" then
		local x = -control:GetNamedChild("Text"):GetTextWidth() / 2
		timeline:GetAnimation(2):SetTranslateOffsets(x, -100, x, -400)
	else
		timeline:GetAnimation(2):SetTranslateOffsets(70, 80, 70, 480)
	end
	timeline:ApplyAllAnimationsToControl(control)
	timeline:SetHandler(
		"OnStop",
		function(timeline)
			self.controlPool:ReleaseObject(timeline:GetFirstAnimation():GetAnimatedControl().hPoolKey)
			self.timelinePool:ReleaseObject(timeline.hPoolKey)
		end
	)
	timeline:PlayFromStart()
end

function HarvenXPNotify:OnSkillExperienceUpdate(eventCode, skillType, skillIndex, unknown, rank, XPBefore, currentXP)
	if XPBefore == currentXP or currentXP == 0 then
		return
	end

	local name, _, discovered = GetSkillLineInfo(skillType, skillIndex)
	if not discovered then
		return
	end

	local lastRankXP, nextRankXP = GetSkillLineXPInfo(skillType, skillIndex)
	local key = skillType .. " " .. skillIndex

	if skillType == SKILL_TYPE_TRADESKILL then
		if self.sv.showTradeskills then
			if not self.skillsAggregateXP[key] then
				self.skillsAggregateXP[key] = {currentXP = 0}
			end
			self:OnExperienceUpdate(eventCode, "tradeskill", currentXP, nextRankXP, skillIndex)
		end
		return
	end

	if not self.skillsAggregateXP[key] then
		self.skillsAggregateXP[key] = {gain = 0, currentXP = 0, skillType = skillType, name}
	end

	local gain = currentXP - self.skillsAggregateXP[key].currentXP
	self.skillsAggregateXP[key].currentXP = currentXP

	if gain > 0 and self.sv.showSkills then
		self.skillsAggregateXP[key].gain = self.skillsAggregateXP[key].gain + gain
		GetSkillLineXPInfo(skillType, skillIndex)
		self.skillsAggregateXP[key].lastRankXP = lastRankXP
		self.skillsAggregateXP[key].nextRankXP = nextRankXP
		self:TryShowStatusWindow()
	end
end

function HarvenXPNotify:OnAbitilyExperienceUpdate(eventCode, pIndex, lastRankXP, nextRankXP, currentXP, atmorph)
	if not nextRankXP or nextRankXP <= 0 then
		return
	end

	local name, rank, morph = GetAbilityProgressionInfo(pIndex)

	if not self.abilitiesAgregateXP[name] then
		self.abilitiesAgregateXP[name] = {gain = 0, currentXP = 0}
	end
	local gain = currentXP - self.abilitiesAgregateXP[name].currentXP
	self.abilitiesAgregateXP[name].currentXP = currentXP
	self.abilitiesAgregateXP[name].morphName = GetAbilityProgressionAbilityInfo(pIndex, rank, morph)

	if gain > 0 and self.sv.showAbilities then
		self.abilitiesAgregateXP[name].gain = self.abilitiesAgregateXP[name].gain + gain
		self.abilitiesAgregateXP[name].lastRankXP = lastRankXP
		self.abilitiesAgregateXP[name].nextRankXP = nextRankXP
		self:TryShowStatusWindow()
	end
end

function HarvenXPNotify:OnSkillLineAdded(eventCode, skillType, skillIndex)
	self.skillsAggregateXP[skillType .. " " .. skillIndex] = {gain = 0, name = GetSkillLineInfo(i, j), skillType = skillType, currentXP = 0}
end

function HarvenXPNotify:OnChampionUnlocked()
	self.skillsAggregateXP[-1].currentXP = GetPlayerChampionXP()
	self.skillsAggregateXP[-1].nextRankXP = GetNumChampionXPInChampionPoint(GetPlayerChampionPointsEarned())
end

local function ResetAggregatedStats(...)
	HarvenXPNotify:ResetStatsWindowContent(true)
end

local function CloseStatusWindow(...)
	HarvenXPNotify:CloseStatusWindow(...)
end

local function OnAbitilyExperienceUpdate(...)
	HarvenXPNotify:OnAbitilyExperienceUpdate(...)
end

local function OnCombatState(...)
	HarvenXPNotify:OnCombatState(...)
end

local function OnSkillExperienceUpdate(...)
	HarvenXPNotify:OnSkillExperienceUpdate(...)
end

local function OnExperienceUpdate(...)
	HarvenXPNotify:OnExperienceUpdate(...)
end

local function OnExperienceGain(...)
	HarvenXPNotify:OnExperienceGain(...)
end

local function OnSkillLineAdded(...)
	HarvenXPNotify:OnSkillLineAdded(...)
end

local function OnChampionUnlocked(...)
	HarvenXPNotify:OnChampionUnlocked(...)
end

function HarvenXPNotify:Initialize()
	self.currentXp = GetUnitXP("player")
	self.controlPool = ZO_ControlPool:New("HarvensXPNotify")
	self.labelPool = ZO_ControlPool:New("HarvensXPStatusWindowText", HarvensXPStatusWindow, "Text")
	self.timelinePool = ZO_AnimationPool:New("HarvensXPNotifyAnimation")
	self.statsWindowTimeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("HarvensXPStatusWindowAnimation", HarvensXPStatusWindow)
	self.statsWindowTimeline.control = HarvensXPStatusWindow
	local function OnStatsAnimationStop(timeline, completed)
		timeline.control:SetHidden(timeline.control:GetAlpha() == 0)
	end

	self.statsWindowTimeline:SetHandler("OnStop", OnStatsAnimationStop)

	self.lastNotify = 0
	self.skillsAggregateXP = {}
	self.abilitiesAgregateXP = {}
	self.isUpdateRegistered = false
	self.baseDuration = 3000
	self.baseOffset = 500

	local defaults = {
		showXp = true,
		showTradeskills = true,
		showSkills = true,
		showAbilities = true,
		autoClose = true,
		autoCloseTime = 15,
		resetOnClose = true,
		closeInCombat = true,
		point = RIGHT,
		x = 0,
		y = 0,
		relPoint = RIGHT,
		scale = 1,
		alpha = 1,
		useColors = true,
		scrollSpeed = 1.0,
		logToChatWindow = false
	}

	self.sv = ZO_SavedVars:New("HarvenXPNotify_SavedVariables", 1, nil, defaults)

	self.reasons = {
		[PROGRESS_REASON_ACHIEVEMENT] = "Achievement",
		[PROGRESS_REASON_ACTION] = "Action",
		[PROGRESS_REASON_ALLIANCE_POINTS] = "Alliance Points",
		[PROGRESS_REASON_AVA] = "AVA",
		[PROGRESS_REASON_BATTLEGROUND] = "Battleground",
		[PROGRESS_REASON_BOOK_COLLECTION_COMPLETE] = "Book Collection Completed",
		[PROGRESS_REASON_BOSS_KILL] = "Boss Killed",
		[PROGRESS_REASON_COLLECT_BOOK] = "Book Collected",
		[PROGRESS_REASON_COMMAND] = "Command",
		[PROGRESS_REASON_COMPLETE_POI] = "POI Completed",
		[PROGRESS_REASON_DARK_ANCHOR_CLOSED] = "Dark Anchor Closed",
		[PROGRESS_REASON_DARK_FISSURE_CLOSED] = "Dark Fissure Closed",
		[PROGRESS_REASON_DISCOVER_POI] = "Location Discovered",
		[PROGRESS_REASON_DRAGON_KILL] = "Dragon Killed",
		[PROGRESS_REASON_DUNGEON_CHALLENGE] = "Dungeon Challenge",
		[PROGRESS_REASON_EVENT] = "World Event",
		[PROGRESS_REASON_FINESSE] = "Finesse",
		[PROGRESS_REASON_GRANT_REPUTATION] = "Reputation Granted",
		[PROGRESS_REASON_GUILD_REP] = "Guild Reputation",
		[PROGRESS_REASON_JUSTICE_SKILL_EVENT] = "Justice Skill Event",
		[PROGRESS_REASON_KEEP_REWARD] = "Keep Reward",
		[PROGRESS_REASON_KILL] = "Kill",
		[PROGRESS_REASON_LFG_REWARD] = "LFG Reward",
		[PROGRESS_REASON_LOCK_PICK] = "Lock Picked",
		[PROGRESS_REASON_MEDAL] = "Medal",
		[PROGRESS_REASON_NONE] = "NONE",
		[PROGRESS_REASON_OTHER] = "Other Reason",
		[PROGRESS_REASON_OVERLAND_BOSS_KILL] = "Boss Killed",
		[PROGRESS_REASON_PVP_EMPEROR] = "PVP Emperor",
		[PROGRESS_REASON_QUEST] = "Quest",
		[PROGRESS_REASON_REWARD] = "Reward",
		[PROGRESS_REASON_SCRIPTED_EVENT] = "World Event",
		[PROGRESS_REASON_SKILL_BOOK] = "Skill Book",
		[PROGRESS_REASON_TRADESKILL] = "Tradeskill",
		[PROGRESS_REASON_TRADESKILL_ACHIEVEMENT] = "Tradeskill Achievement",
		[PROGRESS_REASON_TRADESKILL_CONSUME] = "Tradeskill Consume",
		[PROGRESS_REASON_TRADESKILL_HARVEST] = "Tradeskill Harvest",
		[PROGRESS_REASON_TRADESKILL_QUEST] = "Tradeskill Quest",
		[PROGRESS_REASON_TRADESKILL_RECIPE] = "Tradeskill Recipe",
		[PROGRESS_REASON_TRADESKILL_TRAIT] = "Tradeskill Trait",
		[PROGRESS_REASON_WORLD_EVENT_COMPLETED] = "World Event"
	}

	for i = 1, GetNumSkillTypes() do
		for j = 1, GetNumSkillLines(i) do
			local key = i .. " " .. j
			self.skillsAggregateXP[key] = {gain = 0, name = GetSkillLineInfo(i, j), skillType = i}
			_, _, self.skillsAggregateXP[key].currentXP = GetSkillLineXPInfo(i, j)
			for k = 1, GetNumSkillAbilities(i, j) do
				local _, _, _, _, _, _, pIndex = GetSkillAbilityInfo(i, j, k)
				if pIndex then
					local _, nextRankXP, currentXP = GetAbilityProgressionXPInfo(pIndex)
					if nextRankXP and nextRankXP > 0 then
						local name = GetAbilityProgressionInfo(pIndex)
						self.abilitiesAgregateXP[name] = {gain = 0, currentXP = currentXP}
					end
				end
			end
		end
	end

	--champion:
	self.skillsAggregateXP[-1] = {gain = 0, name = GetString(SI_EXPERIENCE_CHAMPION_LABEL), skillType = SKILL_TYPE_CHAMPION, lastRankXP = 0}
	if IsChampionSystemUnlocked() then
		self.skillsAggregateXP[-1].currentXP = GetPlayerChampionXP()
		self.skillsAggregateXP[-1].nextRankXP = GetNumChampionXPInChampionPoint(GetPlayerChampionPointsEarned())
	end

	local function OnMoveStop(control)
		_, self.sv.point, _, self.sv.relPoint, self.sv.x, self.sv.y = control:GetAnchor(0)
	end

	HarvensXPStatusWindow:SetHandler("OnMoveStop", OnMoveStop)
	HarvensXPStatusWindow:ClearAnchors()
	HarvensXPStatusWindow:SetAnchor(self.sv.point, nil, self.sv.relPoint, self.sv.x, self.sv.y)
	HarvensXPStatusWindow:SetScale(self.sv.scale)
	HarvensXPStatusWindowBg:SetAlpha(self.sv.alpha)
	HarvensXPStatusWindowClose:SetAlpha(self.sv.alpha)
	HarvensXPStatusWindowTitle:SetAlpha(self.sv.alpha)
	HarvensXPStatusWindowDivider:SetAlpha(self.sv.alpha)
	HarvensXPStatusWindowReset:SetHandler("OnMouseDown", ResetAggregatedStats)
	HarvensXPStatusWindowClose:SetHandler("OnMouseDown", CloseStatusWindow)
	self:SetupOptions()

	EVENT_MANAGER:RegisterForEvent("HarvensXPNotifySkillXPGain", EVENT_SKILL_XP_UPDATE, OnSkillExperienceUpdate)
	EVENT_MANAGER:RegisterForEvent("HarvensXPNotifyOnCombatState", EVENT_PLAYER_COMBAT_STATE, OnCombatState)
	EVENT_MANAGER:RegisterForEvent("HarvensXPNotifyAbilityProgression", EVENT_ABILITY_PROGRESSION_XP_UPDATE, OnAbitilyExperienceUpdate)
	EVENT_MANAGER:RegisterForEvent("HarvensXPNotifySkillLineAdded", EVENT_SKILL_LINE_ADDED, OnSkillLineAdded)
	EVENT_MANAGER:RegisterForEvent("HarvensXPNotifyChampionUnlocked", EVENT_CHAMPION_SYSTEM_UNLOCKED, OnChampionUnlocked)

	EVENT_MANAGER:RegisterForEvent("HarvensXPNotifyXPUpdate", EVENT_EXPERIENCE_UPDATE, OnExperienceUpdate)
	EVENT_MANAGER:AddFilterForEvent("HarvensXPNotifyXPUpdate", EVENT_EXPERIENCE_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")
	EVENT_MANAGER:RegisterForEvent("HarvensXPNotifyXPGain", EVENT_EXPERIENCE_GAIN, OnExperienceGain)
end

local function Harven_XPNotifyAddonLoad(code, name)
	if name ~= "HarvensXPNotify" then
		return
	end
	EVENT_MANAGER:UnregisterForEvent("HarvensXPNotifyOnLoaded", EVENT_ADD_ON_LOADED)

	Harven_XPNotifyAddon = HarvenXPNotify:New()
end

EVENT_MANAGER:RegisterForEvent("HarvensXPNotifyOnLoaded", EVENT_ADD_ON_LOADED, Harven_XPNotifyAddonLoad)
