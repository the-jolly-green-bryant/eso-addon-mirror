ALTGF_BUFF_TRACKER = {
	NAME = "AltGroupFramesBuffTracker",
	SV_VER = 5,
	SETTINGS = {},
	ACCOUNT_SETTINGS = {},
	styleObject = nil,
	controlPool = nil,
	iconOverrides = {},
	handlerContexts = {},
	startTracking = nil,
	stopTracking = nil,
	initializeAddonMenu = nil,
}
local SETTINGS = ALTGF_BUFF_TRACKER.SETTINGS
local ACCOUNT_SETTINGS = ALTGF_BUFF_TRACKER.ACCOUNT_SETTINGS

ALTGF_BuffDebuffIcon_Keyboard_XY = 30
ALTGF_BuffDebuffIcon_Keyboard_Inner_XY = ALTGF_BuffDebuffIcon_Keyboard_XY - 4
ALTGF_BuffDebuffIcon_Gamepad_XY = 40
ALTGF_BuffDebuffIcon_Gamepad_Inner_XY = ALTGF_BuffDebuffIcon_Gamepad_XY - 4
ALTGF_BuffDebuffIcon_Offset = 3

local function anyBorderAssigned()
	for _, assignment in pairs(SETTINGS.TRACK) do
		if type(assignment) == "string" and assignment:sub(1, 6) == "border" then
			return true
		end
	end
	return false
end

local function countTracked()
	local num = 0
	for _, assignment in pairs(SETTINGS.TRACK) do
		if assignment == "icons" then
			num = num + 1
		end
	end
	return num
end

local function binarySearchInsertPos(order, ability, cmp)
	local pos = 1
	local beyond = #order + 1
	while pos < beyond do
		local candidate = math.floor((pos + beyond) / 2)
		if cmp(order[candidate], ability) then
			pos = candidate + 1
		else
			beyond = candidate
		end
	end
	return pos
end

local function applyInsideAnchorsToFrame(UnitFrame)
	local frameCtrl = UnitFrame:GetControl()
	local borderAreaH = -2
	if SETTINGS.INSIDE_FRAME and anyBorderAssigned() then
		local nBorders = (SETTINGS.STACK_BORDERS and SETTINGS.NUM_BORDERS > 0) and 1 or SETTINGS.NUM_BORDERS
		borderAreaH = nBorders * SETTINGS.BORDER_THICK
	end

	-- Border bars: stack borders downwards visually, but anchor upwards inside frame
	if UnitFrame.borderCooldowns then
		local prev = nil
		for i = 1, 3 do
			local n = SETTINGS.INSIDE_FRAME and 4 - i or i
			local b = UnitFrame.borderCooldowns[n]
			if n <= SETTINGS.NUM_BORDERS and b then
				b.control:ClearAnchors()
				if not SETTINGS.INSIDE_FRAME then
					b.control:SetAnchor(TOPLEFT, prev or frameCtrl, BOTTOMLEFT, 0, 0)
					b.control:SetAnchor(TOPRIGHT, prev or frameCtrl, BOTTOMRIGHT, 0, 0)
				elseif prev ~= nil then
					b.control:SetAnchor(BOTTOMLEFT, prev, TOPLEFT, 0, 0)
					b.control:SetAnchor(BOTTOMRIGHT, prev, TOPRIGHT, 0, 0)
				else
					b.control:SetAnchor(BOTTOMLEFT, frameCtrl, BOTTOMLEFT, 1, 1)
					b.control:SetAnchor(BOTTOMRIGHT, frameCtrl, BOTTOMRIGHT, -1, -1)
				end
				if not SETTINGS.STACK_BORDERS then
					prev = b.control
				end
			end
		end
	end

	if ALT_GROUP_FRAMES.SETTINGS.SINGLE_ROW_FRAME then
		if UnitFrame.levelControl then
			UnitFrame.levelControl:ClearAnchors()
			UnitFrame.levelControl:SetAnchor(RIGHT, frameCtrl, RIGHT, 0, -borderAreaH / 2)
		end
		if UnitFrame.iconControl then
			UnitFrame.iconControl:ClearAnchors()
			UnitFrame.iconControl:SetAnchor(LEFT, frameCtrl, LEFT, 5, -borderAreaH / 2)
		end
	else
		if UnitFrame.resourceNumbersControl then
			UnitFrame.resourceNumbersControl:ClearAnchors()
			UnitFrame.resourceNumbersControl:SetAnchor(BOTTOMRIGHT, frameCtrl, BOTTOMRIGHT, -4, -borderAreaH)
		end
		if UnitFrame.iconControl then
			UnitFrame.iconControl:ClearAnchors()
			UnitFrame.iconControl:SetAnchor(BOTTOMLEFT, frameCtrl, BOTTOMLEFT, 4, -borderAreaH)
		end
	end
end

local settingsOverride
local function applyStyleSettings()
	if settingsOverride ~= nil then
		ALT_GROUP_FRAMES:RemoveOverrideSettings(settingsOverride)
		settingsOverride = nil
	end

	local numTrack = countTracked()
	local hasBorder = anyBorderAssigned()

	if SETTINGS.ENABLED and (numTrack > 0 or hasBorder) then
		local baseHeight = ALT_GROUP_FRAMES.SETTINGS.UNIT_FRAME_HEIGHT
		settingsOverride = ALT_GROUP_FRAMES:OverrideSettings()

		local iconSize = IsInGamepadPreferredMode() and ALTGF_BuffDebuffIcon_Gamepad_XY
			or ALTGF_BuffDebuffIcon_Keyboard_XY
		local iconAreaW = numTrack > 0
				and (ALTGF_BuffDebuffIcon_Offset + numTrack * (iconSize + ALTGF_BuffDebuffIcon_Offset))
			or 0
		local borderH = hasBorder and (SETTINGS.NUM_BORDERS * SETTINGS.BORDER_THICK) or 0

		-- Icon row lives in the horizontal gap to the right of the frame
		if iconAreaW > 0 then
			settingsOverride.UNIT_FRAME_PAD_X = iconAreaW
		end

		-- Borders: enlarge the frame height (inside) or claim the vertical gap (outside)
		if borderH > 0 then
			if SETTINGS.INSIDE_FRAME then
				settingsOverride.UNIT_FRAME_HEIGHT = baseHeight + borderH
			else
				settingsOverride.UNIT_FRAME_PAD_Y = borderH
			end
		end
	end
end
-------------------------------------
--Custom Container Object--
-------------------------------------
local UnitBuffTrackerContainer = ZO_BuffDebuff_ContainerObject:Subclass()

function UnitBuffTrackerContainer:New(UnitFrame, rowKey, ...)
	local object = ZO_BuffDebuff_ContainerObject.New(self, ...)

	object.iconControlTemplate = "ALTGF_BuffDebuffIcon"
	object.unitFrame = UnitFrame
	object.rowKey = rowKey
	object.byAbilityId = {}
	object.sortedBuffs = {}

	return object
end

function UnitBuffTrackerContainer:SetIconControlTemplate(t)
	self.iconControlTemplate = t
end

function UnitBuffTrackerContainer:ShouldContextuallyShow()
	return SETTINGS.ENABLED
end

-- Same AddBuff/RemoveBuff interface as BorderBuffTrack.
-- data must contain all buff-data fields on create.
function UnitBuffTrackerContainer:AddBuff(abilityId, data)
	local entry = self.byAbilityId[abilityId]
	if not entry then
		self.byAbilityId[abilityId] = data
		entry = data
	else
		local pos = binarySearchInsertPos(self.sortedBuffs, entry, ALTGF_BUFF_TRACKER.styleObject.SortFunction)
		table.remove(self.sortedBuffs, pos)
		for key, value in pairs(data) do
			entry[key] = value
		end
	end
	local pos = binarySearchInsertPos(self.sortedBuffs, entry, ALTGF_BUFF_TRACKER.styleObject.SortFunction)
	table.insert(self.sortedBuffs, pos, entry)
	self:Update()
end

function UnitBuffTrackerContainer:RemoveBuff(abilityId)
	local entry = self.byAbilityId[abilityId]
	if not entry then
		return
	end
	local pos = binarySearchInsertPos(self.sortedBuffs, entry, ALTGF_BUFF_TRACKER.styleObject.SortFunction)
	table.remove(self.sortedBuffs, pos)
	self.byAbilityId[abilityId] = nil
	self:Update()
end

function UnitBuffTrackerContainer:CreateMetaPool(container, buffControlPool)
	local metaPool = ZO_MetaPool:New(buffControlPool)
	metaPool.container = container

	local function OnAcquired(control)
		control:ClearAnchors()

		if control.platformStyle ~= self.currentPlatformStyle then
			control.platformStyle = self.currentPlatformStyle
			ApplyTemplateToControl(control, ZO_GetPlatformTemplate(self.iconControlTemplate))
		end

		if not metaPool.firstControl then
			metaPool.firstControl = control
			control:SetAnchor(LEFT, container)
		else
			control:SetAnchor(LEFT, metaPool.lastControl, RIGHT, ALTGF_BuffDebuffIcon_Offset, 0)
		end

		metaPool.lastControl = control

		control:SetParent(container)
	end

	local function OnReset(control)
		control.blinkAnimation:Stop()

		control.cooldown:ResetCooldown()
		control.cooldown:SetHidden(true)
	end

	metaPool:SetCustomAcquireBehavior(OnAcquired)
	metaPool:SetCustomResetBehavior(OnReset)

	return metaPool
end

-------------------------------------
--Custom Style--
-------------------------------------
local UnitBuffTrackerStyle = ZO_BuffDebuffStyleObject:Subclass()

function UnitBuffTrackerStyle:New(...)
	return ZO_BuffDebuffStyleObject.New(self, ...)
end

function UnitBuffTrackerStyle:UpdateContainer(iconRow)
	if not iconRow:ShouldContextuallyShow() then
		return
	end

	local buffPool = iconRow:GetPools()

	for _, data in ipairs(iconRow.sortedBuffs) do
		local buffControl = buffPool:AcquireObject()
		buffControl.data = data
		self:SetupIcon(buffControl)
	end
end

function UnitBuffTrackerStyle:SetupIcon(control)
	ZO_BuffDebuffStyleObject.SetupIcon(self, control)
	local durationLabel = control:GetNamedChild("Duration")
	if durationLabel then
		durationLabel:SetFont("$(BOLD_FONT)|" .. SETTINGS.FONT_SIZE .. "|soft-shadow-thick")
	end
end

function UnitBuffTrackerStyle.SortFunction(buffData1, buffData2) -- NB function not method
	-- fixed positions
	return buffData1.abilityId < buffData2.abilityId
end

---------------------------------------
----Add/remove tracked abilities
---------------------------------------
local combatEventFilterTypes = {
	["_gained"] = ACTION_RESULT_EFFECT_GAINED,
	["_duration"] = ACTION_RESULT_EFFECT_GAINED_DURATION,
	["_faded"] = ACTION_RESULT_EFFECT_FADED,
}

local function pollSingleBuff(unitTag, targetAbilityId, complete)
	for i = 1, GetNumBuffs(unitTag) do
		local _, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, _, castByPlayer =
			GetUnitBuffInfo(unitTag, i)
		if abilityId == targetAbilityId then
			local data = {
				-- Actually dynamically needed
				timeStarted = timeStarted,
				timeEnding = timeEnding,
				duration = timeEnding - timeStarted,
				stackCount = stackCount,
				-- Not available or incorrect via event
				iconFilename = ALTGF_BUFF_TRACKER.iconOverrides[abilityId] or iconFilename,
				buffSlot = buffSlot,
				buffType = buffType,
				effectType = effectType,
				abilityType = abilityType,
				statusEffectType = statusEffectType,
			}
			if complete then
				-- What we usually skip
				data.abilityId = abilityId
				data.buffName = zo_strformat(SI_UNIT_NAME, GetAbilityName(abilityId))
				data.castByPlayer = castByPlayer
				data.permanent = IsAbilityPermanent(abilityId)
			end
			return data
		end
	end
	return nil
end

local function pollMultipleBuffs(unitTag, targetAbilities, complete)
	local matches = {}
	for i = 1, GetNumBuffs(unitTag) do
		local _, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, _, castByPlayer =
			GetUnitBuffInfo(unitTag, i)
		if targetAbilities[abilityId] ~= nil then
			matches[abilityId] = {
				iconFilename = ALTGF_BUFF_TRACKER.iconOverrides[abilityId] or iconFilename,
				timeStarted = timeStarted,
				timeEnding = timeEnding,
				duration = timeEnding - timeStarted,
				buffSlot = buffSlot,
				stackCount = stackCount,
				buffType = buffType,
				effectType = effectType,
				abilityType = abilityType,
				statusEffectType = statusEffectType,
			}
			if complete then
				matches[abilityId].abilityId = abilityId
				matches[abilityId].buffName = zo_strformat(SI_UNIT_NAME, GetAbilityName(abilityId))
				matches[abilityId].castByPlayer = castByPlayer
				matches[abilityId].permanent = IsAbilityPermanent(abilityId)
			end
		end
	end
	return matches
end

local function resolveTarget(ctx, abilityId, assignment)
	assignment = assignment or SETTINGS.TRACK[abilityId]
	if not assignment then
		return nil
	end
	if assignment:sub(1, 6) == "border" then
		local borderIdx = tonumber(assignment:sub(7))
		local border = ctx.borders and ctx.borders[borderIdx]
		if borderIdx and borderIdx <= SETTINGS.NUM_BORDERS and border then
			return border
		end
		return nil
	end
	return ctx.containers[assignment]
end

local function registerFrameAbility(ctx, unitTag, abilityId)
	for suffix, result in pairs(combatEventFilterTypes) do
		local name = "ALTGF_Buff_" .. unitTag .. suffix .. abilityId
		EVENT_MANAGER:RegisterForEvent(name, EVENT_COMBAT_EVENT, ctx.combatEvent)
		EVENT_MANAGER:AddFilterForEvent(name, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, result)
		EVENT_MANAGER:AddFilterForEvent(name, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId)
		EVENT_MANAGER:AddFilterForEvent(name, EVENT_COMBAT_EVENT, REGISTER_FILTER_UNIT_TAG, unitTag)
	end
	local name = "ALTGF_Buff_" .. unitTag .. "_effectchanged" .. abilityId
	EVENT_MANAGER:RegisterForEvent(name, EVENT_EFFECT_CHANGED, ctx.effectChanged)
	EVENT_MANAGER:AddFilterForEvent(name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, abilityId)
	EVENT_MANAGER:AddFilterForEvent(name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, unitTag)
end

local function unregisterFrameAbility(ctx, unitTag, abilityId)
	for suffix in pairs(combatEventFilterTypes) do
		EVENT_MANAGER:UnregisterForEvent("ALTGF_Buff_" .. unitTag .. suffix .. abilityId, EVENT_COMBAT_EVENT)
	end
	EVENT_MANAGER:UnregisterForEvent("ALTGF_Buff_" .. unitTag .. "_effectchanged" .. abilityId, EVENT_EFFECT_CHANGED)
end

ALTGF_BUFF_TRACKER.startTracking = function(abilityId, assignment)
	local previousAssignment = SETTINGS.TRACK[abilityId]
	if previousAssignment == assignment then
		return
	end
	SETTINGS.TRACK[abilityId] = assignment

	for unitTag, ctx in pairs(ALTGF_BUFF_TRACKER.handlerContexts) do
		if previousAssignment == nil then
			registerFrameAbility(ctx, unitTag, abilityId)
		elseif previousAssignment ~= assignment then
			local oldTarget = resolveTarget(ctx, abilityId, previousAssignment)
			if oldTarget then
				oldTarget:RemoveBuff(abilityId)
			end
		end

		local target = resolveTarget(ctx, abilityId, assignment)
		if target then
			local data = pollSingleBuff(unitTag, abilityId, true)
			if data then
				target:AddBuff(abilityId, data)
			end
		end
	end
end

ALTGF_BUFF_TRACKER.stopTracking = function(abilityId)
	if SETTINGS.TRACK[abilityId] == nil then
		return
	end

	for unitTag, ctx in pairs(ALTGF_BUFF_TRACKER.handlerContexts) do
		unregisterFrameAbility(ctx, unitTag, abilityId)
		local target = resolveTarget(ctx, abilityId)
		if target then
			target:RemoveBuff(abilityId)
		end
	end
	SETTINGS.TRACK[abilityId] = nil
end

-------------------------------------
--Track Ability with UnitFrame Border
-------------------------------------
local BorderBuffTrack = ZO_Object:Subclass()

function BorderBuffTrack:New(...)
	local obj = ZO_Object.New(self)
	obj:Initialize(...)
	return obj
end

function BorderBuffTrack:Initialize(UnitFrame, borderIndex, prevBorderControl)
	local ns = "BuffCooldown" .. UnitFrame:GetUnitTag() .. borderIndex
	self.borderKey = "border" .. borderIndex
	self.activeBuffs = {} -- [abilityId] = { startTime, endTime }

	self.control = CreateControlFromVirtual(ns, UnitFrame:GetControl(), "ALTGF_Cooldown")
	self.control:SetValue(0)
	self.control:SetHidden(true)
	self.control:SetDrawLayer(DL_OVERLAY) -- above all DL_CONTROLS content (bg, HP, shields …)
	self.control:SetDrawLevel(5)
	self.control:SetColor(unpack(SETTINGS.BORDER_COLORS[borderIndex]))
	self:SetThickness(SETTINGS.BORDER_THICK)

	-- Stack below the previous border if one exists; otherwise use XML default (below frame)
	if prevBorderControl then
		self.control:ClearAnchors()
		self.control:SetAnchor(TOPLEFT, prevBorderControl, BOTTOMLEFT, 0, 0)
		self.control:SetAnchor(TOPRIGHT, prevBorderControl, BOTTOMRIGHT, 0, 0)
	end

	local function OnAnimationTransitionUpdate(animation, progress)
		local newBarValue = zo_lerp(animation.initialValue, animation.endValue, progress)
		self.control:SetValue(newBarValue)
	end

	self.animation = ANIMATION_MANAGER:CreateTimelineFromVirtual("ALTGF_StatusBarGrowTemplate")
	local customAnimation = self.animation:GetFirstAnimation()
	customAnimation:SetUpdateFunction(OnAnimationTransitionUpdate)

	local function PlayAnim(duration, currentRemaining)
		self.control:SetMinMax(0, duration * 1000)
		customAnimation.initialValue = currentRemaining * 1000
		customAnimation.endValue = 0
		customAnimation:SetDuration(currentRemaining * 1000)
		self.control:SetHidden(false)
		self.animation:PlayFromStart()
	end

	-- Find and display the active buff with the longest remaining duration
	function self:UpdateDisplay()
		local now = GetFrameTimeSeconds()
		local bestEndTime = 0
		local bestStartTime = 0
		for _, info in pairs(self.activeBuffs) do
			if info.endTime > now and info.endTime > bestEndTime then
				bestEndTime = info.endTime
				bestStartTime = info.startTime
			end
		end
		if bestEndTime > 0 then
			PlayAnim(bestEndTime - bestStartTime, bestEndTime - now)
		else
			self:Reset()
		end
	end
end

function BorderBuffTrack:SetThickness(value)
	self.control:SetHeight(value)
end

function BorderBuffTrack:SetColor(...)
	self.control:SetColor(...)
end

function BorderBuffTrack:Reset()
	self.animation:Stop()
	self.control:SetValue(0)
	self.control:SetHidden(true)
end

-- Unified "target" interface (mirrors UnitBuffTrackerContainer:AddBuff/:RemoveBuff)
-- data only needs timeStarted/timeEnding here; borders don't track full buff data.
function BorderBuffTrack:AddBuff(abilityId, data)
	self.activeBuffs[abilityId] = { startTime = data.timeStarted, endTime = data.timeEnding }
	self:UpdateDisplay()
end

function BorderBuffTrack:RemoveBuff(abilityId)
	self.activeBuffs[abilityId] = nil
	self:UpdateDisplay()
end
-------------------------------------------------------------------------------------

-------------------------------------
--Init--
-------------------------------------

ALTGF_BUFF_TRACKER.Initialize =  function()
	if ALTGF_BUFF_TRACKER.styleObject then return end -- init canary

	ALTGF_BUFF_TRACKER.styleObject = UnitBuffTrackerStyle:New("ALTGF_BuffDebuffCenterOutStyle_Template")
	ALTGF_BUFF_TRACKER.controlPool = ZO_ControlPool:New("ALTGF_BuffDebuffIcon", nil, "FGBuff")

	-- Hook global RefreshView so our settings adjustments survive every data/style refresh.
	local altgfRefreshView = ALT_GROUP_FRAMES.RefreshView
	ALT_GROUP_FRAMES.RefreshView = function(self, recurse)
		altgfRefreshView(self, false)
		applyStyleSettings()
		if recurse then
			ALT_GROUP_FRAMES:ForEach(function(unitFrame)
				unitFrame:RefreshView()
				unitFrame:RefreshPosition()
			end)
		end
	end

	local function initFrame(UnitFrame)
		local unitTag = UnitFrame:GetUnitTag()
		local overridenUnitTag = unitTag == "player" and "customplayer" or unitTag
		if BUFF_DEBUFF.containerObjectsByUnitTag[overridenUnitTag] ~= nil then
			return
		end

		local frameCtrl = UnitFrame:GetControl()

		-- Hook RefreshView so our anchor adjustments survive every data/style refresh.
		-- We shadow the class method with an instance field on this specific UnitFrame.
		local classRefreshView = UnitFrame.RefreshView
		UnitFrame.RefreshView = function(self, ...)
			classRefreshView(self, ...)
			applyInsideAnchorsToFrame(self)
		end

		-- Create 3 borders, each stacked below the previous
		UnitFrame.borderCooldowns = {}
		local prevBorderCtrl = nil
		for i = 1, 3 do
			local border = BorderBuffTrack:New(UnitFrame, i, prevBorderCtrl)
			UnitFrame.borderCooldowns[i] = border
			prevBorderCtrl = border.control
		end

		-- Create the single icon row container
		local containerControl =
			CreateControlFromVirtual("AltGroupBuffDebuff" .. unitTag, frameCtrl, "ZO_BuffDebuffContainerTemplate")
		containerControl:ClearAnchors()
		containerControl:SetAnchor(RIGHT, UnitFrame:GetControl(), RIGHT, 0, 0)
		containerControl:SetDrawLayer(DL_OVERLAY)
		containerControl:SetDrawLevel(5)

		local containerIconRows = {
			icons = UnitBuffTrackerContainer:New(
				UnitFrame,
				"icons",
				containerControl,
				ALTGF_BUFF_TRACKER.controlPool,
				unitTag,
				EVENT_PLAYER_ACTIVATED
			),
		}
		containerIconRows.icons:SetStyleObject(ALTGF_BUFF_TRACKER.styleObject, true)
		BUFF_DEBUFF:AddContainerObject(overridenUnitTag, containerIconRows.icons)

		local handlerContext = { containers = containerIconRows, borders = UnitFrame.borderCooldowns, unitTag = unitTag }
		ALTGF_BUFF_TRACKER.handlerContexts[unitTag] = handlerContext

		local function unitMatches(unitId, unitName)
			if UnitFrame.unitId == nil then
				if zo_strformat(SI_UNIT_NAME, unitName) == zo_strformat(SI_UNIT_NAME, GetUnitName(unitTag)) then
					UnitFrame.unitId = unitId
					return true
				else
					return false
				end
			end
			return UnitFrame.unitId == unitId
		end

		local pendingPolls = {} -- [abilityId] = { target = iconRow | border, update = table | nil }

		local function delayedPoll()
			local queue = pendingPolls
			pendingPolls = {}
			local currentTime = GetFrameTimeSeconds()
			local updateInfo = pollMultipleBuffs(unitTag, queue)
			for abilityId, update in pairs(queue) do
				updateInfo[abilityId] = updateInfo[abilityId] or queue[abilityId].update
			end
			local changedRows = {}
			for abilityId, update in pairs(updateInfo) do
				local iconRow = queue[abilityId].target
				local entry = iconRow.byAbilityId and iconRow.byAbilityId[abilityId]
				if entry ~= nil then
					local pos = binarySearchInsertPos(iconRow.sortedBuffs, entry, ALTGF_BUFF_TRACKER.styleObject.SortFunction)
					table.remove(iconRow.sortedBuffs, pos)
					for key, value in pairs(update) do
						entry[key] = value
					end
					if currentTime < entry.timeEnding then
						local pos = binarySearchInsertPos(iconRow.sortedBuffs, entry, ALTGF_BUFF_TRACKER.styleObject.SortFunction)
						table.insert(iconRow.sortedBuffs, pos, entry)
					else
						iconRow.byAbilityId[abilityId] = nil
					end
					changedRows[iconRow.rowKey] = iconRow
				end
			end
			for _, iconRow in pairs(changedRows) do
				iconRow:Update()
			end
		end

		handlerContext.enqueuePoll = function(target, abilityId, update)
			local wasEmpty = next(pendingPolls) == nil
			pendingPolls[abilityId] = { target = target, update = update }
			if wasEmpty then zo_callLater(delayedPoll, 16) end
		end

		handlerContext.effectChanged = function(
			_, changeType, effectSlot, effectName, _, beginTime, endTime, stackCount,
			iconName,
			buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId
		)
			if not SETTINGS.ENABLED or not UnitFrame:IsActive() or not unitMatches(unitId, unitName) then
				return
			end

			local target = resolveTarget(handlerContext, abilityId)
			if not target then
				return
			end

			if changeType == EFFECT_RESULT_FADED then
				target:RemoveBuff(abilityId)
				return
			end

			if target.byAbilityId then
				if not target.byAbilityId[abilityId] then
					target:AddBuff(abilityId, {
						buffName = zo_strformat(SI_UNIT_NAME, GetAbilityName(abilityId)),
						timeStarted = beginTime,
						timeEnding = endTime,
						buffSlot = effectSlot,
						stackCount = stackCount,
						iconFilename = ALTGF_BUFF_TRACKER.iconOverrides[abilityId] or iconName,
						buffType = buffType,
						effectType = effectType,
						abilityType = abilityType,
						statusEffectType = statusEffectType,
						abilityId = abilityId,
						duration = endTime - beginTime,
						castByPlayer = nil,
						permanent = IsAbilityPermanent(abilityId),
					})
				end
				handlerContext.enqueuePoll(target, abilityId)
			else
				target:AddBuff(abilityId, { timeStarted = beginTime, timeEnding = endTime })
			end
		end

		-- Combat-event handler for the icon
		handlerContext.combatEvent = function(
			_, result, isError, _, abilityIcon, _, _, _, targetName, _, hitValue, _, _, _, _, targetUnitId, abilityId
		)
			if not SETTINGS.ENABLED or isError or not UnitFrame:IsActive() or not unitMatches(targetUnitId, targetName) then
				return
			end

			local target = resolveTarget(handlerContext, abilityId)
			if not target then
				return
			end

			if result == ACTION_RESULT_EFFECT_FADED then
				target:RemoveBuff(abilityId)
				return
			end

			-- ACTION_RESULT_EFFECT_GAINED or ACTION_RESULT_EFFECT_GAINED_DURATION
			local now = GetFrameTimeSeconds()
			local duration = hitValue / 1000

			local update = nil
			if target.byAbilityId then
				if not target.byAbilityId[abilityId] then
					target:AddBuff(abilityId, {
						buffName = zo_strformat(SI_UNIT_NAME, GetAbilityName(abilityId)),
						timeStarted = now,
						timeEnding = now + duration,
						buffSlot = 0,
						stackCount = 0,
						iconFilename = ALTGF_BUFF_TRACKER.iconOverrides[abilityId] or abilityIcon,
						buffType = 1,
						effectType = BUFF_EFFECT_TYPE_DEBUFF,
						abilityType = 0,
						statusEffectType = 0,
						abilityId = abilityId,
						duration = duration,
						castByPlayer = false,
						permanent = false,
					})
				end
				handlerContext.enqueuePoll(target, abilityId, update)
			elseif result == ACTION_RESULT_EFFECT_GAINED_DURATION then
				target:AddBuff(abilityId, { timeStarted = now, timeEnding = now + duration, duration = duration })
			end
		end

		if UnitFrame:IsActive() then
			for abilityId in pairs(SETTINGS.TRACK) do
				registerFrameAbility(handlerContext, unitTag, abilityId)
			end
		end

		-- Apply inside/outside anchors for this new frame immediately
		applyInsideAnchorsToFrame(UnitFrame)
	end

	local function resetFrame(UnitFrame)
		UnitFrame.unitId = nil
		local unitTag = UnitFrame:GetUnitTag()
		local ctx = ALTGF_BUFF_TRACKER.handlerContexts[unitTag]
		if not ctx or ctx.unitTag == unitTag then return end
		for abilityId, assignment in pairs(SETTINGS.TRACK) do
			registerFrameAbility(ctx, unitTag, abilityId)
			local target = resolveTarget(ctx, abilityId, assignment)
			if target then
				target:RemoveBuff(abilityId)
				if ctx.enqueuePoll then
					ctx.enqueuePoll(target, abilityId)
				end
			end
		end
	end

	local function activateFrame(UnitFrame)
		UnitFrame.unitId = nil
		local unitTag = UnitFrame:GetUnitTag()
		local ctx = ALTGF_BUFF_TRACKER.handlerContexts[unitTag]
		if not ctx then return end
		ctx.unitTag = unitTag
		for abilityId, assignment in pairs(SETTINGS.TRACK) do
			registerFrameAbility(ctx, unitTag, abilityId)
			local target = resolveTarget(ctx, abilityId, assignment)
			if target and ctx.enqueuePoll then
				target:RemoveBuff(abilityId)
				ctx.enqueuePoll(target, abilityId)
			end
		end
	end

	local function deactivateFrame(UnitFrame)
		UnitFrame.unitId = nil
		local unitTag = UnitFrame:GetUnitTag()
		local ctx = ALTGF_BUFF_TRACKER.handlerContexts[unitTag]
		if not ctx then return end
		ctx.unitTag = nil
		for abilityId, assignment in pairs(SETTINGS.TRACK) do
			unregisterFrameAbility(ctx, unitTag, abilityId)
			local target = resolveTarget(ctx, abilityId, assignment)
			if target then
				target:RemoveBuff(abilityId)
			end
		end
	end

	CALLBACK_MANAGER:RegisterCallback(ALT_GROUP_FRAMES.EVENT.UNIT_FRAME_CREATED, initFrame)
	CALLBACK_MANAGER:RegisterCallback(ALT_GROUP_FRAMES.EVENT.UNIT_FRAME_DATA_CHANGED, resetFrame)
	CALLBACK_MANAGER:RegisterCallback(ALT_GROUP_FRAMES.EVENT.UNIT_FRAME_ACTIVATED, activateFrame)
	CALLBACK_MANAGER:RegisterCallback(ALT_GROUP_FRAMES.EVENT.UNIT_FRAME_DEACTIVATED, deactivateFrame)
	ALT_GROUP_FRAMES:ForEach(initFrame)

	ZO_PlatformStyle:New(function()
		ALT_GROUP_FRAMES:RefreshView()
	end, 1, 2)
end

local function OnAddOnLoaded(_, addonName)
	if addonName == ALTGF_BUFF_TRACKER.NAME then
		EVENT_MANAGER:UnregisterForEvent(ALTGF_BUFF_TRACKER.NAME, EVENT_ADD_ON_LOADED)

		for _, buff in ipairs(ALTGF_BUFF_TRACKER.BUFFS) do
			if buff.iconAbilityId then
				ALTGF_BUFF_TRACKER.iconOverrides[buff.id] = GetAbilityIcon(buff.iconAbilityId)
			elseif buff.icon then
				ALTGF_BUFF_TRACKER.iconOverrides[buff.id] = buff.icon
			end
		end

		ALTGF_BUFF_TRACKER.SETTINGS = ZO_SavedVars:NewCharacterIdSettings("AltGroupFramesBuffTrackerSV", ALTGF_BUFF_TRACKER.SV_VER, nil, {
			ENABLED = true,
			INSIDE_FRAME = false,
			STACK_BORDERS = true,
			TRACK = {}, -- [abilityId] = "icons"|"border1"|"border2"|"border3"
			NUM_BORDERS = 1,
			BORDER_COLORS = {
				{ 0.2, 0.75, 0.15, 1 },
				{ 0.2, 0.55, 0.90, 1 },
				{ 0.9, 0.55, 0.15, 1 },
			},
			BORDER_THICK = 4,
			FONT_SIZE = 14,
		})
		ALTGF_BUFF_TRACKER.ACCOUNT_SETTINGS = ZO_SavedVars:NewAccountWide("AltGroupFramesBuffTrackerAccountSV", 1, nil, {
			CUSTOM_IDS = {},
		})

		SETTINGS = ALTGF_BUFF_TRACKER.SETTINGS
		ACCOUNT_SETTINGS = ALTGF_BUFF_TRACKER.ACCOUNT_SETTINGS

		ALTGF_BUFF_TRACKER.initializeAddonMenu()

		if SETTINGS.ENABLED then
			ALTGF_BUFF_TRACKER.Initialize()
		end
	end
end

EVENT_MANAGER:RegisterForEvent(ALTGF_BUFF_TRACKER.NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
