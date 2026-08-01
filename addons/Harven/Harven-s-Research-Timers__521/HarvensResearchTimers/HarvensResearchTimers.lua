local HarvensResearchTimers = {}
local HarvensResearchTimerBar = {}

ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_HARVENSRESEARCHTIMERS", "Toggle Harven's Research Timers")

local function CreateKey(craftingSkillType, researchLineIndex, traitIndex)
	return string.format("%i %i %i", craftingSkillType, researchLineIndex, traitIndex)
end

function HarvensResearchTimerBar:New()
	local ret = setmetatable({}, self)
	self.__index = self
	return ret
end

function HarvensResearchTimerBar:Destroy()
	self.bar:SetHandler("OnUpdate", nil)
	self.barsPool:ReleaseObject(self.barKey)
	local key
	if self.craftingSkillType then
		key = CreateKey(self.craftingSkillType, self.researchLineIndex, self.traitIndex)
	else
		key = "riding"
	end
	HarvensResearchTimers.timers[key] = nil
	HarvensResearchTimers.sv.completed[key] = nil
	for i = 1, #HarvensResearchTimers.timerKeys do
		if HarvensResearchTimers.timerKeys[i] == key then
			table.remove(HarvensResearchTimers.timerKeys, i)
			break
		end
	end
	HarvensResearchTimers:RearangeBars()
end

function HarvensResearchTimerBar:Initialize()
	self.barsPool = ZO_ControlPool:New("HarvensResearchTimer", HarvensResearchTimersContainer, "Bar")
end

function HarvensResearchTimerBar:Update(time)
	if time > self.timeout then
		self:Completed()
		return
	end

	if time > self.nextBarUpdate then
		local t = self.barValue + time - self.start
		self.progressBar:SetValue(t)
		self.nextBarUpdate = time + self.updateInterval
	end

	if time > self.nextTimeUpdate then
		self.remainig = self.timeout - time
		self.timeLeftLabel:SetText(ZO_FormatTime(self.remainig, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_TWELVE_HOUR))
		self.nextTimeUpdate = time + 1
	end
end

function HarvensResearchTimerBar:ForceUpdate(time)
	if self.completed then
		return
	end
	self.nextBarUpdate = 0
	self.nextTimeUpdate = 0
	self:Update(time)
end

function HarvensResearchTimerBar:CreateNewBar(craftingSkillType, researchLineIndex, traitIndex, count)
	self.bar, self.barKey = self.barsPool:AcquireObject()
	self.bar:ClearAnchors()
	self.bar:SetAnchor(TOP, HarvensResearchTimersContainer, TOP, 0, (count * HarvensResearchTimers.sv.spacing) + 30)
	HarvensResearchTimersContainer:SetHeight((count + 1) * 52)
	self.closeButton = self.bar:GetNamedChild("Close")
	self.closeButton:SetHidden(true)
	self.closeButton:SetHandler(
		"OnClicked",
		function()
			self:Destroy()
		end
	)

	self.timeLeftLabel = self.bar:GetNamedChild("TimeLeft")
	self.progressBar = self.bar:GetNamedChild("Bar")
	self.label = self.bar:GetNamedChild("Label")
	self.label:SetFont(HarvensResearchTimers.sv.font)
	self.label:SetColor(unpack(HarvensResearchTimers.sv.labelColor))
	self.timeLeftLabel:SetFont(HarvensResearchTimers.sv.timeFont)
	self.timeLeftLabel:SetColor(unpack(HarvensResearchTimers.sv.timeColor))
	self.progressBar:GetNamedChild("Gloss"):SetColor(unpack(HarvensResearchTimers.sv.barColor1))
	self.progressBar:SetColor(unpack(HarvensResearchTimers.sv.barColor2))

	if researchLineIndex then
		self.craftingSkillType = craftingSkillType
		self.researchLineIndex = researchLineIndex
		self.traitIndex = traitIndex

		local skillName = GetSkillLineInfo(GetCraftingSkillLineIndices(craftingSkillType))
		local name = GetSmithingResearchLineInfo(craftingSkillType, researchLineIndex)
		local traitName = GetString("SI_ITEMTRAITTYPE", GetSmithingResearchLineTraitInfo(craftingSkillType, researchLineIndex, traitIndex))
		self.duration, self.remainig = GetSmithingResearchLineTraitTimes(craftingSkillType, researchLineIndex, traitIndex)
		self.label:SetText(zo_strformat("<<Z:1>> - <<Z:2>> - <<Z:3>>", skillName, name, traitName))
	elseif craftingSkillType == "riding" then
		self.label:SetText(string.upper("Train Riding Skill in"))
		self.remainig, self.duration = GetTimeUntilCanBeTrained()
		self.duration = self.duration / 1000
		self.remainig = self.remainig / 1000
	end

	if not self.duration or not self.remainig then
		return
	end

	self.label:ClearAnchors()
	self.closeButton:ClearAnchors()
	if HarvensResearchTimers.sv.alignment == TOPRIGHT then
		self.closeButton:SetAnchor(RIGHT, self.bar, LEFT, -8)
		self.label:SetAnchor(BOTTOMRIGHT, self.progressBar, TOPRIGHT, 0, -4)
		self.progressBar:SetBarAlignment(BAR_ALIGNMENT_REVERSE)
		self.progressBar:GetNamedChild("Gloss"):SetBarAlignment(BAR_ALIGNMENT_REVERSE)
	else
		self.closeButton:SetAnchor(LEFT, self.bar, RIGHT, 8)
		self.label:SetAnchor(BOTTOMLEFT, self.progressBar, TOPLEFT, 0, -4)
		self.progressBar:SetBarAlignment(BAR_ALIGNMENT_NORMAL)
		self.progressBar:GetNamedChild("Gloss"):SetBarAlignment(BAR_ALIGNMENT_NORMAL)
	end

	local now = GetFrameTimeSeconds()
	self.progressBar:SetMinMax(0, self.duration)
	self.barValue = self.duration - self.remainig

	self.updateInterval = self.duration / 320
	self.nextBarUpdate = 0
	self.timeout = now + self.remainig
	self.nextTimeUpdate = 0
	self.start = now

	self.bar:SetHandler(
		"OnUpdate",
		function(control, time)
			self:Update(time)
		end
	)
end

function HarvensResearchTimerBar:Completed(canceled)
	self.bar:GetNamedChild("Close"):SetHidden(false)
	self.bar:SetHandler("OnUpdate", nil)
	self.progressBar:SetMinMax(0, 1)
	self.progressBar:SetValue(1)
	self.completed = true
	if self.craftingSkillType then
		if canceled ~= nil then
			self.timeLeftLabel:SetText("Canceled!")
		else
			self.timeLeftLabel:SetText(GetString(SI_ACHIEVEMENTS_TOOLTIP_COMPLETE) .. "!")
			local key = CreateKey(self.craftingSkillType, self.researchLineIndex, self.traitIndex)
			if not HarvensResearchTimers.sv.completed[key] then
				HarvensResearchTimers.sv.completed[key] = {craftingSkillType = self.craftingSkillType, researchLineIndex = self.researchLineIndex, traitIndex = self.traitIndex}
			end
		end
	else
		self.timeLeftLabel:SetText("NOW!")
	end
end

--Options menu
function HarvensResearchTimers:SetupOptions()
	local settings = LibHarvensAddonSettings:AddAddon("Harven's Research Timers")
	if not settings then
		return
	end

	settings.version ="2.0.0"

	local fontEdit = {
		type = LibHarvensAddonSettings.ST_EDIT,
		label = "Label Font",
		getFunction = function()
			return self.sv.font
		end,
		setFunction = function(value)
			self.sv.font = value
			self:ApplySettings()
		end
	}

	local timerFontEdit = {
		type = LibHarvensAddonSettings.ST_EDIT,
		label = "Time Font",
		getFunction = function()
			return self.sv.timeFont
		end,
		setFunction = function(value)
			self.sv.timeFont = value
			self:ApplySettings()
		end
	}

	local scaleSlider = {
		type = LibHarvensAddonSettings.ST_SLIDER,
		label = "Scale",
		min = 0.1,
		max = 4,
		step = 0.1,
		format = "%.1f",
		getFunction = function()
			return self.sv.scale
		end,
		setFunction = function(value)
			HarvensResearchTimersContainer:SetScale(value)
			self.sv.scale = value
		end
	}

	local showStable = {
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = "Show Stable Timers",
		getFunction = function()
			return self.sv.showStables
		end,
		setFunction = function(state)
			self.sv.showStables = state
			self:MountUpdate()
		end
	}

	local hideInCombat = {
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = "Hide While in Combat",
		getFunction = function()
			return self.sv.hideInCombat
		end,
		setFunction = function(state)
			self.sv.hideInCombat = state
			if not state and HarvensResearchTimersContainer:IsHidden() then
				HarvensResearchTimersContainer:SetHidden(false)
			end
		end
	}

	local fontColor = {
		type = LibHarvensAddonSettings.ST_COLOR,
		label = "Label Color",
		getFunction = function()
			return unpack(self.sv.labelColor)
		end,
		setFunction = function(...)
			self.sv.labelColor[1], self.sv.labelColor[2], self.sv.labelColor[3], self.sv.labelColor[4] = ...
			self:ApplySettings()
		end
	}

	local timeColor = {
		type = LibHarvensAddonSettings.ST_COLOR,
		label = "Time Color",
		getFunction = function()
			return unpack(self.sv.timeColor)
		end,
		setFunction = function(...)
			self.sv.timeColor[1], self.sv.timeColor[2], self.sv.timeColor[3], self.sv.timeColor[4] = ...
			self:ApplySettings()
		end
	}

	local backgroundColor = {
		type = LibHarvensAddonSettings.ST_COLOR,
		label = "Background Color 1",
		getFunction = function()
			return unpack(self.sv.barColor1)
		end,
		setFunction = function(...)
			self.sv.barColor1[1], self.sv.barColor1[2], self.sv.barColor1[3], self.sv.barColor1[4] = ...
			self:ApplySettings()
		end
	}

	local backgroundColor2 = {
		type = LibHarvensAddonSettings.ST_COLOR,
		label = "Background Color 2",
		getFunction = function()
			return unpack(self.sv.barColor2)
		end,
		setFunction = function(...)
			self.sv.barColor2[1], self.sv.barColor2[2], self.sv.barColor2[3], self.sv.barColor2[4] = ...
			self:ApplySettings()
		end
	}

	local spacingSlider = {
		type = LibHarvensAddonSettings.ST_SLIDER,
		label = "Spacing",
		min = 30,
		max = 100,
		step = 1,
		format = "%d",
		getFunction = function()
			return self.sv.spacing
		end,
		setFunction = function(value)
			self.sv.spacing = value
			self:RearangeBars()
		end
	}

	local alignment = {
		type = LibHarvensAddonSettings.ST_DROPDOWN,
		label = "Alignment",
		items = {
			{
				name = "Left",
				data = TOPLEFT
			},
			{
				name = "Right",
				data = TOPRIGHT
			}
		},
		getFunction = function()
			return self.alignments[self.sv.alignment]
		end,
		setFunction = function(dropdown, name, item)
			self.sv.alignment = item.data
			self:RearangeBars()
		end
	}

	local sorting = {
		type = LibHarvensAddonSettings.ST_DROPDOWN,
		label = "Sort by",
		items = {{name = "Time Left Ascending"}, {name = "Time Left Descending"}},
		tooltip = "Requires /reloadui",
		getFunction = function()
			if self.sv.sortAscending then
				return "Time Left Ascending"
			end
			return "Time Left Descending"
		end,
		setFunction = function(dropdown, name, item)
			if name == "Time Left Ascending" then
				self.sv.sortAscending = true
			else
				self.sv.sortAscending = false
			end
		end
	}

	settings:AddSettings({fontEdit, timerFontEdit, fontColor, timeColor, backgroundColor, backgroundColor2, scaleSlider, spacingSlider, showStable, hideInCombat, alignment, sorting})
end

function HarvensResearchTimers:ApplySettings()
	for i = 1, #self.timerKeys do
		local timer = self.timers[self.timerKeys[i]]
		timer.label:SetFont(self.sv.font)
		timer.label:SetColor(unpack(self.sv.labelColor))
		timer.timeLeftLabel:SetFont(self.sv.timeFont)
		timer.timeLeftLabel:SetColor(unpack(self.sv.timeColor))
		timer.progressBar:GetNamedChild("Gloss"):SetColor(unpack(self.sv.barColor1))
		timer.progressBar:SetColor(unpack(self.sv.barColor2))
	end
end

function HarvensResearchTimers:RearangeBars()
	if #self.timerKeys == 0 then
		HarvensResearchTimersContainer:SetHeight(1)
		return
	end

	local count = 0
	for i = 1, #self.timerKeys do
		local timer = self.timers[self.timerKeys[i]]
		timer.bar:ClearAnchors()
		timer.bar:SetAnchor(TOP, HarvensResearchTimersContainer, TOP, 0, (count * self.sv.spacing) + 30)
		HarvensResearchTimersContainer:SetHeight((count + 1) * self.sv.spacing)
		timer.label:ClearAnchors()
		timer.closeButton:ClearAnchors()
		if self.sv.alignment == TOPRIGHT then
			timer.closeButton:SetAnchor(RIGHT, timer.bar, LEFT, -8)
			timer.label:SetAnchor(BOTTOMRIGHT, timer.progressBar, TOPRIGHT, 0, -4)
			timer.progressBar:SetBarAlignment(BAR_ALIGNMENT_REVERSE)
			timer.progressBar:GetNamedChild("Gloss"):SetBarAlignment(BAR_ALIGNMENT_REVERSE)
		else
			timer.closeButton:SetAnchor(LEFT, timer.bar, RIGHT, 8)
			timer.label:SetAnchor(BOTTOMLEFT, timer.progressBar, TOPLEFT, 0, -4)
			timer.progressBar:SetBarAlignment(BAR_ALIGNMENT_NORMAL)
			timer.progressBar:GetNamedChild("Gloss"):SetBarAlignment(BAR_ALIGNMENT_NORMAL)
		end
		count = count + 1
	end
end

function HarvensResearchTimers:AddStableTimer()
	local bar = HarvensResearchTimerBar:New()
	local key = "riding"
	bar:CreateNewBar(key, nil, nil, #self.timerKeys)
	self.timers[key] = bar
	table.insert(self.timerKeys, key)
end

function HarvensResearchTimers:AddResearchTimer(craftingSkillType, researchLineIndex, traitIndex)
	local bar = HarvensResearchTimerBar:New()
	local key = CreateKey(craftingSkillType, researchLineIndex, traitIndex)
	bar:CreateNewBar(craftingSkillType, researchLineIndex, traitIndex, #self.timerKeys)
	self.timers[key] = bar
	table.insert(self.timerKeys, key)
end

function HarvensResearchTimers.ResearchCanceled(eventCode, craftingSkillType, researchLineIndex, traitIndex)
	local key = CreateKey(craftingSkillType, researchLineIndex, traitIndex)
	if not HarvensResearchTimers.timers[key] then
		HarvensResearchTimers:AddResearchTimer(craftingSkillType, researchLineIndex, traitIndex)
	end
	HarvensResearchTimers.timers[key]:Completed(true)
end

function HarvensResearchTimers.ResearchCompleted(eventCode, craftingSkillType, researchLineIndex, traitIndex)
	local key = CreateKey(craftingSkillType, researchLineIndex, traitIndex)
	if not HarvensResearchTimers.timers[key] then
		HarvensResearchTimers:AddResearchTimer(craftingSkillType, researchLineIndex, traitIndex)
	end
	HarvensResearchTimers.timers[key]:Completed()
end

function HarvensResearchTimers.ResearchStarted(eventCode, ...)
	HarvensResearchTimers:AddResearchTimer(...)
end

function HarvensResearchTimers:RecalculateTimers()
	local craftingSkillType, researchLineIndex, traitIndex

	local now = GetFrameTimeSeconds()
	for i = 1, #self.timerKeys do
		local timer = self.timers[self.timerKeys[i]]
		craftingSkillType = timer.craftingSkillType
		if craftingSkillType then
			researchLineIndex, traitIndex = timer.researchLineIndex, timer.traitIndex
			timer.duration, timer.remainig = GetSmithingResearchLineTraitTimes(craftingSkillType, researchLineIndex, traitIndex)
			timer.timeout = now + timer.remainig
			timer.barValue = timer.duration - timer.remainig
			timer.start = now
		end
	end
end

function HarvensResearchTimers.TimesUpdated(eventCode)
	HarvensResearchTimers:RecalculateTimers()
end

function HarvensResearchTimers:UpdateTimers(time)
	for i = 1, #self.timerKeys do
		self.timers[self.timerKeys[i]]:ForceUpdate(time)
	end
end

function HarvensResearchTimers:ShowTimers(inCombat)
	if not self.sv.hideInCombat then
		return
	end

	if not HarvensResearchTimers.sv.isHidden then
		HarvensResearchTimersContainer:SetHidden(inCombat)
		if not inCombat then
			self:UpdateTimers(GetFrameTimeSeconds())
		end
	end
end

function HarvensResearchTimersToggle()
	HarvensResearchTimers.sv.isHidden = not HarvensResearchTimers.sv.isHidden
	HarvensResearchTimersContainer:SetHidden(HarvensResearchTimers.sv.isHidden)
end

function HarvensResearchTimers:MountUpdate()
	if self.timers["riding"] then
		return
	end
	local time = GetTimeUntilCanBeTrained()
	if time and time > 0 then
		self:AddStableTimer()
	end
end

local function HarvensResearchTimersInitialize()
	EVENT_MANAGER:UnregisterForEvent("HarvensResearchTimersInitialize", EVENT_PLAYER_ACTIVATED)

	HarvensResearchTimerBar:Initialize()

	local defaults = {
		pos = {point = RIGHT, relPoint = RIGHT, x = 0, y = 0},
		completed = {},
		timeFont = "$(MEDIUM_FONT)|14|thick-outline",
		timeColor = {1, 1, 1, 1},
		font = "$(BOLD_FONT)|16|soft-shadow-thick",
		labelColor = {1, 1, 1, 1},
		barColor1 = {1, 1, 1, 1},
		barColor2 = {0.53, 1, 1, 1},
		scale = 1.0,
		spacing = 52,
		alignment = TOPRIGHT,
		showStables = true,
		hideInCombat = true
	}

	HarvensResearchTimers.alignments = {
		[TOPLEFT] = "Left",
		[TOPRIGHT] = "Right"
	}

	HarvensResearchTimers.sv = ZO_SavedVars:New("HarvensResearchTimers_SavedVariables", 1, nil, defaults)
	HarvensResearchTimers.timers = {}
	HarvensResearchTimers.timerKeys = {}

	HarvensResearchTimersContainer:SetAnchor(HarvensResearchTimers.sv.pos.point, GuiRoot, HarvensResearchTimers.sv.pos.relPoint, HarvensResearchTimers.sv.pos.x, HarvensResearchTimers.sv.pos.y)
	HarvensResearchTimersContainer:SetScale(HarvensResearchTimers.sv.scale)
	HarvensResearchTimersContainer:SetHandler(
		"OnMoveStop",
		function()
			local _, point, _, relPoint, x, y = HarvensResearchTimersContainer:GetAnchor(0)
			HarvensResearchTimers.sv.pos = nil
			HarvensResearchTimers.sv.pos = {point = point, relPoint = relPoint, x = x, y = y}
		end
	)

	local smithingTypes = {CRAFTING_TYPE_BLACKSMITHING, CRAFTING_TYPE_CLOTHIER, CRAFTING_TYPE_WOODWORKING, CRAFTING_TYPE_JEWELRYCRAFTING}

	local timers = {}
	for _, smithingType in pairs(smithingTypes) do
		for i = 1, GetNumSmithingResearchLines(smithingType) do
			local _, _, numTraits = GetSmithingResearchLineInfo(smithingType, i)
			for t = 1, numTraits do
				local dur, remainig = GetSmithingResearchLineTraitTimes(smithingType, i, t)
				if dur and remainig then
					timers[#timers + 1] = {remainig, smithingType, i, t}
				end
			end
		end
	end

	if HarvensResearchTimers.sv.sortAscending then
		table.sort(
			timers,
			function(t1, t2)
				return t1[1] < t2[1]
			end
		)
	else
		table.sort(
			timers,
			function(t1, t2)
				return t2[1] < t1[1]
			end
		)
	end
	for i = 1, #timers do
		HarvensResearchTimers:AddResearchTimer(select(2, unpack(timers[i])))
	end

	for k, v in pairs(HarvensResearchTimers.sv.completed) do
		HarvensResearchTimers.ResearchCompleted(nil, v.craftingSkillType, v.researchLineIndex, v.traitIndex)
	end

	if HarvensResearchTimers.sv.showStables then
		local time = GetTimeUntilCanBeTrained()
		if time and time > 0 then
			HarvensResearchTimers:AddStableTimer()
		end
	end

	HarvensResearchTimersContainer:RegisterForEvent(EVENT_SMITHING_TRAIT_RESEARCH_STARTED, HarvensResearchTimers.ResearchStarted)
	HarvensResearchTimersContainer:RegisterForEvent(EVENT_SMITHING_TRAIT_RESEARCH_COMPLETED, HarvensResearchTimers.ResearchCompleted)
	HarvensResearchTimersContainer:RegisterForEvent(EVENT_SMITHING_TRAIT_RESEARCH_TIMES_UPDATED, HarvensResearchTimers.TimesUpdated)
	HarvensResearchTimersContainer:RegisterForEvent(EVENT_SMITHING_TRAIT_RESEARCH_CANCELED, HarvensResearchTimers.ResearchCanceled)

	local fragment = ZO_SimpleSceneFragment:New(HarvensResearchTimersContainer)
	fragment:RegisterCallback(
		"StateChange",
		function(oldState, newState)
			if newState == SCENE_FRAGMENT_SHOWING then
				HarvensResearchTimers:UpdateTimers(GetFrameTimeSeconds())
			elseif newState == SCENE_FRAGMENT_SHOWN then
				HarvensResearchTimersContainer:SetHidden(HarvensResearchTimers.sv.isHidden)
			end
		end
	)
	local scene = SCENE_MANAGER:GetScene("hudui")
	scene:AddFragment(fragment)
	scene = SCENE_MANAGER:GetScene("hud")
	scene:AddFragment(fragment)

	HarvensResearchTimers:SetupOptions()

	--HarvensResearchTimersContainer:RegisterForEvent(EVENT_MOUNT_UPDATE, function(eventCode,...) HarvensResearchTimers:MountUpdate(...) end)
	--HarvensResearchTimersContainer:RegisterForEvent(EVENT_MOUNTS_FULL_UPDATE, function(eventCode,...) HarvensResearchTimers:MountUpdate(...) end)
	STABLE_MANAGER:RegisterCallback(
		"StableInteractEnd",
		function()
			HarvensResearchTimers:MountUpdate()
		end
	)
	HarvensResearchTimersContainer:RegisterForEvent(
		EVENT_PLAYER_COMBAT_STATE,
		function(eventCode, inCombat)
			HarvensResearchTimers:ShowTimers(inCombat)
		end
	)
end

EVENT_MANAGER:RegisterForEvent("HarvensResearchTimersInitialize", EVENT_PLAYER_ACTIVATED, HarvensResearchTimersInitialize)
