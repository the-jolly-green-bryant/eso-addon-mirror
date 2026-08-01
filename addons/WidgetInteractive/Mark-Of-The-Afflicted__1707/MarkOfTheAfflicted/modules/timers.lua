-- Variables -------------------------------------------------------------------
MotA_Timers    = {}
MotA_Timer_Bar = {}

-- Initialize timers -----------------------------------------------------------
function MotA_Timers:Initialize(parent)
	MotA_Timer_Bar:Initialize()

	local uid = GetCurrentCharacterId()

	MotA_Timers.timers        = {}
	MotA_Timers.timerKeys     = {}
	MotA_Timers.parent        = parent

	MotA_BiteTimersContainer:SetAnchor(MotA_Timers.parent.savedVariables.timers.position.point, GuiRoot, MotA_Timers.parent.savedVariables.timers.position.relPoint, MotA_Timers.parent.savedVariables.timers.position.x, MotA_Timers.parent.savedVariables.timers.position.y)
	MotA_BiteTimersContainer:SetScale(MotA_Timers.parent.savedVariables.timers.scale)

	-- Lock the window if lock UI is enabled
	if MotA_Timers.parent.savedVariables.timers.lockUI then
		MotA_BiteTimersContainer:SetMovable(false)
	end

	MotA_BiteTimersContainer:SetHandler( "OnMoveStop", function()
		local _, point, _, relPoint, x, y = MotA_BiteTimersContainer:GetAnchor(0)
		MotA_Timers.parent.savedVariables.timers.position = nil
		MotA_Timers.parent.savedVariables.timers.position = { point = point, relPoint = relPoint, x=x, y=y }
	end )

	if MotA_Timers.parent.savedVariables.enable.timers then
		local isVampire, hasBloodRitual, vampireReadyTime = MotA_Helpers:IsVampire()
		local isWerewolf, hasBloodmoon, werewolfReadyTime = MotA_Helpers:IsWerewolf()

		if MotA_Timers.parent.savedTimers.timers[uid] then
			if not isVampire and not isWerewolf then
				MotA_Timers.parent.savedTimers.timers[uid] = nil
			end
		end

		if isVampire or isWerewolf then
			if isVampire then
				MotA_Timers.parent.savedTimers.timers[uid] = {
					char  = GetUnitName("player"),
					type  = "vampire",
					stage = MotA_Helpers:GetVampireStage(),
					time  = vampireReadyTime
				}
			elseif isWerewolf then
				MotA_Timers.parent.savedTimers.timers[uid] = {
					char  = GetUnitName("player"),
					type  = "werewolf",
					stage = nil,
					time  = werewolfReadyTime
				}
			end
		end

		local timers = MotA_Timers.parent.savedTimers.timers

		table.sort(timers, function(t1, t2)
			if t1[1] < t2[1] then
				return true
			end
			return false
		end)

		for k, v in pairs(timers) do
			if not MotA_Timers.parent.savedVariables.timers.showAll and k == uid then
				MotA_Timers:AddBiteTimer(v["type"], v["char"], v["time"], v["stage"])
			elseif MotA_Timers.parent.savedVariables.timers.showAll then
				MotA_Timers:AddBiteTimer(v["type"], v["char"], v["time"], v["stage"])
			end
		end

		MotA_BiteTimersContainer:RegisterForEvent(EVENT_PLAYER_COMBAT_STATE, function(eventCode, inCombat) MotA_Timers:ShowTimers(inCombat) end)
	end

	local fragment = ZO_SimpleSceneFragment:New(MotA_BiteTimersContainer)
	fragment:RegisterCallback("StateChange", function(oldState, newState)
		if newState == SCENE_FRAGMENT_SHOWING then
			MotA_Timers:UpdateTimers(GetGameTimeMilliseconds()/1000)
		end

		if newState == SCENE_FRAGMENT_SHOWN then
			MotA_BiteTimersContainer:SetHidden(MotA_Timers.parent.savedVariables.timers.isHidden)
		end
	end)

	local scene = SCENE_MANAGER:GetScene("hudui")

	scene:AddFragment(fragment)
	scene = SCENE_MANAGER:GetScene("hud")
	scene:AddFragment(fragment)
end

-- Initialize ------------------------------------------------------------------
function MotA_Timer_Bar:Initialize()
	self.barsPool = ZO_ControlPool:New("MotA_Timer", MotA_BiteTimersContainer, "Bar")
end

-- Add timer -------------------------------------------------------------------
function MotA_Timers:AddBiteTimer(biteType, charName, readyTime, vampireStage)
	local bar = MotA_Timer_Bar:New()
	local key = charName

	bar:CreateNewBar(biteType, charName, readyTime, vampireStage, #self.timerKeys)

	self.timers[key] = bar
	table.insert(self.timerKeys, key)
end

-- Create bar ------------------------------------------------------------------
function MotA_Timer_Bar:CreateNewBar(biteType, charName, readyTime, vampireStage, count)
	self.bar, self.barKey = self.barsPool:AcquireObject()
	self.bar:ClearAnchors()
	self.bar:SetAnchor(TOP, MotA_BiteTimersContainer, TOP, 0, (count*MotA_Timers.parent.savedVariables.timers.spacing)+30)
	MotA_BiteTimersContainer:SetHeight((count+1)*52)

	self.timeLeftLabel = self.bar:GetNamedChild("TimeLeft")
	self.progressBar   = self.bar:GetNamedChild("Bar")
	self.label         = self.bar:GetNamedChild("Label")
	self.label:SetFont(MotA_Fonts:GetTimerLabelFontString(MotA_Timers.parent))
	self.label:SetColor(unpack(MotA_Timers.parent.savedVariables.timers.labelColor))
	self.timeLeftLabel:SetFont(MotA_Fonts:GetTimerTimeFontString(MotA_Timers.parent))
	self.timeLeftLabel:SetColor(unpack(MotA_Timers.parent.savedVariables.timers.timeColor))

	self.biteType      = biteType
	self.uid           = GetCurrentCharacterId()
	self.charName      = charName
	self.timeRemaining = readyTime - GetTimeStamp()
	self.duration      = 604800
	self.vampireStage  = vampireStage

	if biteType == "vampire" then
		self.progressBar:GetNamedChild("Gloss"):SetColor(unpack(MotA_Timers.parent.savedVariables.timers.vaGlossColor))
		self.progressBar:SetColor(unpack(MotA_Timers.parent.savedVariables.timers.vaBackgroundColor))

		self.label:SetText(string.upper(zo_strformat("<<1>> - <<2>> <<3>>", charName, "Stage", vampireStage)))
	else
		self.progressBar:GetNamedChild("Gloss"):SetColor(unpack(MotA_Timers.parent.savedVariables.timers.wwGlossColor))
		self.progressBar:SetColor(unpack(MotA_Timers.parent.savedVariables.timers.wwBackgroundColor))

		self.label:SetText(string.upper(zo_strformat("<<1>>", charName)))
	end

	local now = GetGameTimeMilliseconds()/1000

	self.label:ClearAnchors()

	if MotA_Timers.parent.savedVariables.timers.labelAlignment == "right" then
		self.label:SetAnchor(BOTTOMRIGHT, self.progressBar, TOPRIGHT, 0, -4)
		self.progressBar:SetBarAlignment(BAR_ALIGNMENT_REVERSE)
		self.progressBar:GetNamedChild("Gloss"):SetBarAlignment(BAR_ALIGNMENT_REVERSE)
	else
		self.label:SetAnchor(BOTTOMLEFT, self.progressBar, TOPLEFT, 0, -4)
		self.progressBar:SetBarAlignment(BAR_ALIGNMENT_NORMAL)
		self.progressBar:GetNamedChild("Gloss"):SetBarAlignment(BAR_ALIGNMENT_NORMAL)
	end

	self.progressBar:SetMinMax(0, self.duration)

	if MotA_Timers.parent.savedVariables.timers.timerAction == "drain" then
		self.barValue = self.timeRemaining
	else
		self.barValue = self.duration-self.timeRemaining
	end

	self.updateInterval = self.duration/320
	self.nextBarUpdate  = 0
	self.timeout        = now + self.timeRemaining
	self.nextTimeUpdate = 0
	self.start          = now
	self.bar:SetHandler("OnUpdate", function(control, time) self:Update(time) end)
end

-- Setup new bar ---------------------------------------------------------------
function MotA_Timer_Bar:New()
	local ret    = setmetatable({}, self)
	self.__index = self

	return ret
end

-- Update timers ---------------------------------------------------------------
function MotA_Timers:UpdateTimers(time)
	for i=1, #self.timerKeys do
		self.timers[self.timerKeys[i]]:ForceUpdate(time)
	end
end

-- Show timers ------------------------------------------------------------------
function MotA_Timers:ShowTimers(inCombat)
	if not MotA_Timers.parent.savedVariables.timers.hideInCombat then
		return
	end

	if not MotA_Timers.parent.savedVariables.timers.isHidden then
		MotA_BiteTimersContainer:SetHidden(inCombat)

		if not inCombat then
			self:UpdateTimers(GetGameTimeMilliseconds()/1000)
		end
	end
end

-- Update bar ------------------------------------------------------------------
function MotA_Timer_Bar:Update(time)
	if time > self.timeout then
		self:Completed()
		return
	end

	local _, _, vampireReadyTime = MotA_Helpers:IsVampire()
	local _, _, werewolfReadyTime = MotA_Helpers:IsWerewolf()

	if self.biteType == "vampire" then
		self.vampireStage = MotA_Helpers:GetVampireStage()

		MotA_Timers.parent.savedTimers.timers[self.uid] = {
			char  = GetUnitName("player"),
			type  = "vampire",
			stage = self.vampireStage,
			time  = vampireReadyTime
		}
	else
		MotA_Timers.parent.savedTimers.timers[self.uid] = {
			char  = GetUnitName("player"),
			type  = "werewolf",
			stage = nil,
			time  = werewolfReadyTime
		}
	end

	if self.biteType == "vampire" then
		self.label:SetText(string.upper(zo_strformat("<<1>> - <<2>> <<3>>", self.charName, "Stage", self.vampireStage)))
	end

	if time > self.nextBarUpdate then
		local t = ""

		if MotA_Timers.parent.savedVariables.timers.timerAction == "drain" then
			t = self.timeRemaining
		else
			t = self.barValue + time - self.start
		end

		self.progressBar:SetValue(t)
		self.nextBarUpdate = time + self.updateInterval
	end

	if time > self.nextTimeUpdate then
		self.timeRemaining = self.timeout - time

		local timerPercent = math.floor(self.timeRemaining/self.duration*100)
		local timerLabel = ""

		timerLabel = ZO_FormatTime(self.timeRemaining, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_TWELVE_HOUR)

		self.timeLeftLabel:SetText(timerLabel)
		self.nextTimeUpdate = time + 1
	end
end

function MotA_Timer_Bar:ForceUpdate(time)
	if self.completed then
		return
	end

	self.nextBarUpdate  = 0
	self.nextTimeUpdate = 0
	self:Update(time)
end

-- Apply settings on save ------------------------------------------------------
function MotA_Timers:ApplySettings()
	for i=1, #self.timerKeys do
		self.timers[self.timerKeys[i]].label:SetFont(MotA_Fonts:GetTimerLabelFontString(MotA_Timers.parent))
		self.timers[self.timerKeys[i]].label:SetColor(unpack(MotA_Timers.parent.savedVariables.timers.labelColor))
		self.timers[self.timerKeys[i]].timeLeftLabel:SetFont(MotA_Fonts:GetTimerTimeFontString(MotA_Timers.parent))
		self.timers[self.timerKeys[i]].timeLeftLabel:SetColor(unpack(MotA_Timers.parent.savedVariables.timers.timeColor))

		if self.timers[self.timerKeys[i]].biteType == "vampire" then
			self.timers[self.timerKeys[i]].progressBar:GetNamedChild("Gloss"):SetColor(unpack(MotA_Timers.parent.savedVariables.timers.vaGlossColor))
			self.timers[self.timerKeys[i]].progressBar:SetColor(unpack(MotA_Timers.parent.savedVariables.timers.vaBackgroundColor))

			self.timers[self.timerKeys[i]].label:SetText(string.upper(zo_strformat("<<1>> - <<2>> <<3>>", self.timers[self.timerKeys[i]].charName, "Stage", self.timers[self.timerKeys[i]].vampireStage)))
		else
			self.timers[self.timerKeys[i]].progressBar:GetNamedChild("Gloss"):SetColor(unpack(MotA_Timers.parent.savedVariables.timers.wwGlossColor))
			self.timers[self.timerKeys[i]].progressBar:SetColor(unpack(MotA_Timers.parent.savedVariables.timers.wwBackgroundColor))

			self.timers[self.timerKeys[i]].label:SetText(string.upper(zo_strformat("<<1>>", self.timers[self.timerKeys[i]].charName)))
		end
	end

	-- Lock the window if lock UI is enabled
	if MotA_Timers.parent.savedVariables.timers.lockUI then
		MotA_BiteTimersContainer:SetMovable(false)
	else
		MotA_BiteTimersContainer:SetMovable(true)
	end
end

-- Rearrange bars --------------------------------------------------------------
function MotA_Timers:RearrangeBars()
	if #self.timerKeys == 0 then
		MotA_BiteTimersContainer:SetHeight(1)
		return
	end

	local count = 0

	for i=1, #self.timerKeys do
		self.timers[self.timerKeys[i]].bar:ClearAnchors()
		self.timers[self.timerKeys[i]].bar:SetAnchor(TOP, MotA_BiteTimersContainer, TOP, 0, (count*MotA_Timers.parent.savedVariables.timers.spacing)+30)

		MotA_BiteTimersContainer:SetHeight((count+1)*MotA_Timers.parent.savedVariables.timers.spacing)

		self.timers[self.timerKeys[i]].label:ClearAnchors()

		if MotA_Timers.parent.savedVariables.timers.labelAlignment == "right" then
			self.timers[self.timerKeys[i]].label:SetAnchor(BOTTOMRIGHT, self.timers[self.timerKeys[i]].progressBar, TOPRIGHT, 0, -4)
			self.timers[self.timerKeys[i]].progressBar:SetBarAlignment(BAR_ALIGNMENT_REVERSE)
			self.timers[self.timerKeys[i]].progressBar:GetNamedChild("Gloss"):SetBarAlignment(BAR_ALIGNMENT_REVERSE)
		else
			self.timers[self.timerKeys[i]].label:SetAnchor(BOTTOMLEFT, self.timers[self.timerKeys[i]].progressBar, TOPLEFT, 0, -4)
			self.timers[self.timerKeys[i]].progressBar:SetBarAlignment(BAR_ALIGNMENT_NORMAL)
			self.timers[self.timerKeys[i]].progressBar:GetNamedChild("Gloss"):SetBarAlignment(BAR_ALIGNMENT_NORMAL)
		end

		count = count + 1
	end
end

-- Complete --------------------------------------------------------------------
function MotA_Timer_Bar:Completed()
	local uid = GetCurrentCharacterId();

	self.bar:SetHandler("OnUpdate", nil)
	self.progressBar:SetMinMax(0, 1)

	if MotA_Timers.parent.savedVariables.timers.timerAction == "drain" then
		self.progressBar:SetValue(0)
	else
		self.progressBar:SetValue(1)
	end

	self.completed = true

	self.timeLeftLabel:SetText(GetString(MOTA_TIMERS_READY) .. "!")

	if MotA_Timers.parent.savedVariables.timers.notifications == "chat" then
		PlaySound(MotA_Timers.parent.savedVariables.timers.notificationSound)
		CHAT_SYSTEM:AddMessage(colorWidget .. "[Mark of the Afflicted] " .. colorYellow .. GetString(MOTA_TIMERS_READY) .. ": " .. self.charName)
	elseif MotA_Timers.parent.savedVariables.timers.notifications == "announcement" then
		CENTER_SCREEN_ANNOUNCE:AddMessage(0, CSA_EVENT_SMALL_TEXT, MotA_Timers.parent.savedVariables.timers.notificationSound, GetString(MOTA_TIMERS_READY) .. self.charName)
	end
end

-- Toggle timers ---------------------------------------------------------------
function MotA_Timers_Toggle()
	MotA_Timers.parent.savedVariables.timers.isHidden = not MotA_Timers.parent.savedVariables.timers.isHidden
	MotA_BiteTimersContainer:SetHidden(MotA_Timers.parent.savedVariables.timers.isHidden)
end
