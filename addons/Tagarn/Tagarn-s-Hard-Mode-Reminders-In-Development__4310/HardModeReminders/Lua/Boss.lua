-- Copyright (c) 2025 by Tagarn

-- This add-on may be copied, shared, and used as-is while playing Elder
-- Scrolls Online, provided this notice is left intact. However, this
-- add-on, in part or in full, may not be used in the creation of other
-- add-ons without the express written consent of Tagarn.

-- The Elder Scrolls Online add-on provided by Tagarn ("we," "us," or "our")
-- is for entertainment purposes only. UNDER NO CIRCUMSTANCE SHALL WE HAVE ANY
-- LIABILITY TO YOU FOR ANY LOSS OR DAMAGE OF ANY KIND INCURRED AS A RESULT OF
-- THE USE OF OUR ADD-ON. YOUR USE OF OUR ADD-ON IS SOLELY AT YOUR OWN RISK.


HardModeRemindersBoss = {}

local HMRB = HardModeRemindersBoss
local HMR = HardModeReminders
local EM = EVENT_MANAGER


local hmr = GetString(HMR_ABBREV_GREEN)

-- Testing
-- Used to selectively output some messages
local function td(...)
	if (HMR.debugActive == true) and (HMR.debugVerbose == true) then
		d(...)  --leave
	end
end

local function tdf(...)
	if (HMR.debugActive == true) and (HMR.debugVerbose == true) then
		df(...)  --leave
	end
end

HMRB.arenaDetect = {
	[HMR.C.arenaDetect.presence] = function(self) self:DetectArenaByPresence() end,
	[HMR.C.arenaDetect.mapId] = function(self) self:DetectArenaByMapId() end,
	[HMR.C.arenaDetect.coordinates] = function(self) self:DetectArenaByCoordinates() end,
	[HMR.C.arenaDetect.arkasis] = function(self) self:DetectArenaForArkasis() end,
	[HMR.C.arenaDetect.stonekeeper] = function(self) self:DetectArenaForStonekeeper() end,
	[HMR.C.arenaDetect.theKnot] = function(self) self:DetectArenaByTheKnot() end,
	[HMR.C.arenaDetect.coordsAtBoss] = function() return false end,
}

HMRB.hmDetect = {
	[HMR.C.hmDetect.maxHealth] = function(self) self:DetectHmByHealth() end,
	[HMR.C.hmDetect.maarselok] = function(self) self:DetectHmMaarselok() end,
	[HMR.C.hmDetect.stonekeeper] = function(self) self:DetectHmStonekeeper() end,
	[HMR.C.hmDetect.theKnot] = function(self) self:DetectHmTheKnot() end,
	[HMR.C.hmDetect.none] = function(self) self:DetectHmNone() end,
}

function HMRB:New(...)
	local o = {}
	setmetatable(o, self)
	self.__index = self

	o:Initialize(...)
	return o
end

function HMRB:Initialize(boss, parent, UpdateCallback)
	self.sBoss = boss
	self.parent = parent
	self.isNextBoss = false
	self.previousBoss = nil
	self.unitTag = nil
	self.previousUnitTag = nil
	self.justReceivedUnitTag = false
	self.UpdateCallback = UpdateCallback
	self.name = boss.name
	self.isPresent = false
	self.inCombat = false
	self.bossNumber = boss.bossNumber
	self.isPolling = false
	self.isWatchingMapId = false
	self.lastMapId = 0
	self.inArena = false
	self.maxHp = 0
	self.startHp = 0
	self.locationAndHealth = false
	self.justReset = false -- flags if boss was just reset. For Maarselok functionality
	self.inBossTrashCombat = false -- flags if the player is in combat with the Arkasis trash (Stone Garden)
	--LATER: Would be useful to persist self.arkasisTrashComplete
	self.bossTrashComplete = false -- flags if the player is done with the Arkasis trash (Stone Garden)
	self.inPreBossTransform = false
	self.preBossTransformComplete = false
	self.preBossState = 0
	self.scanningForSkeevaton = false

	if (self.sBoss.bannerWasSeen == nil) then
		self.sBoss.bannerWasSeen = false
	end

	tdf("Object created: %s", self.sBoss.name)
end

local function InRange(rStart, rEnd, value)
	if ( rStart < value ) and (value < rEnd) then
		return true
	end
	if ( rEnd < value ) and (value < rStart) then
		return true
	end

	return false
end

-- Check status of this boss
function HMRB:UpdateBoss()
	td("**HMRB:UpdateBoss()")
	if (self.unitTag == nil) then
		-- LATER: wrap all of this in a isDead check?

		local detectFunction = self.arenaDetect[self:GetArenaDetectionMethod()]

		if (detectFunction) then
			detectFunction(self)
		else
			tdf("**** error. Arena detection method not available for %s", self.name)
		end
		self:IsPresent()
		if (self:IsDead() == false) then
			self:StartLocationPolling() -- only starts if needed
		end
	else
		self.isNextBoss = false
		self:IsPresent()

		local detectFunction = self.hmDetect[self:GetHmDetectionMethod()]
		if (detectFunction) then
			td(">>>>>>>>>>>>>>>>>>>>>>>>>>>> should be detecting")
			detectFunction(self)
		else
			tdf("**** error. HM detection method not available for %s", self.name)
		end
	end
end

--REMOVE
function HMRB:Startup()
	if (self:GetHmDetectionMethod() == HMR.C.arenaDetect.coordinates) then
		self:StartLocationPolling()
	end
	if (self:GetHmDetectionMethod() == HMR.C.arenaDetect.mapId) then
		self:StartWatchingMapId()
	end
end

-- Stops other arena detect methods. For when nextBoss becomes currentBoss
function HMRB:SoftShutdown()
	self.isNextBoss = false
	self:StopLocationPolling()
	self:StopWatchingMapId()
end

function HMRB:Shutdown()
	self.isNextBoss = false
	-- d("Boss shutdown")
	HMRB:SoftShutdown()
	self.inArena = false
	self.unitTag = nil
	-- Unregister for any registered events
end

function HMRB:NameCheck(name)
	if (self.sBoss.name == name) or ((self.sBoss.alias) and (self.sBoss.alias == name)) then
		return true
	else
		return false
	end
end

--TODO: the first three "detect arena" methods should simply return true if the boss is present
function HMRB:DetectArenaByPresence()
	td(">>>> HMRB:DetectArenaByPresence() ")

	-- if the boss is present and alive, we're in the arena
	self.inArena = (self:IsPresent() == true) and (self:IsDead() == false)
	return self.inArena
end

function HMRB:DetectArenaByMapId()
	td(">>>> HMRB:DetectArenaByMapId() not implemented")

	--TODO do this by mapId first, but keep other as a backup for data issues
	-- if the boss is present and alive, we're in the arena
	if (self:IsPresent() == true) then
		self:StopWatchingMapId()
		if (self:IsDead() == false) then
			self.inArena = true
		else
			self.inArena = false
		end
	else
		self:StartWatchingMapId()
		self:OnCurrentSubzoneListChanged(1)
	end

	return self.inArena
end

function HMRB:DetectArenaByCoordinates()
	td(">>>> HMRB:DetectByCoordinates()")

	-- if the boss is present and alive, we're in the arena
	if (self:IsPresent() == true) then
		self.inArena = true
		self:StopLocationPolling()
		td("------------------Call stop polling")
	end

	-- otherwise, poll for the region
	if (self:IsPresent() == false) then
		self.inArena = false
		self:StartLocationPolling()
		td("------------------Call start polling")
	end

	return self.inArena
end

function HMRB:DetectArenaForStonekeeper()
	if (self:IsPresent() == true) and (self.preBossState == HMR.C.fv.complete) then
		self.inArena = true
	else
		self.inArena = false
	end

	return self.inArena
end

function HMRB:DetectArenaByTheKnot()
	if (self.isNextBoss) then
		self.inArena = true
	else
		self.inArena = false
	end

	return self.inArena
end

function HMRB:DetectArenaForArkasis()
	td(">>>> HMRB:DetectArenaForArkasis()")
	--LATER change to state method used for Stonekeeper
	if (self.bossTrashComplete == true) and (GetCurrentMapId() == self.sBoss.mapId) then
		self.inArena = true
	else
		self.inArena = false
	end

	return self.inArena
end

function HMRB:DisplayUiForBoss()
	tdf(">>>> HMRB:DisplayUiForBoss(). trashcomplete: %s", tostring(self.bossTrashComplete))

	if (self:GetArenaDetectionMethod() == HMR.C.arenaDetect.arkasis) then
		if (self.bossTrashComplete == true) and (GetCurrentMapId() == self.sBoss.mapId) then
			return true
		else
			return false
		end
	end

	if (self:GetArenaDetectionMethod() == HMR.C.arenaDetect.stonekeeper) then
		td("(self:GetArenaDetectionMethod() == HMR.C.arenaDetect.stonekeeper) ")
		if (self.preBossState == HMR.C.fv.complete) and (self:IsPresent() == true) then
			return true
		else
			return false
		end
	end

	return true
end

function HMRB:DetectHmNone()
	return self:IsPresent()
end

function HMRB:DetectHmByHealth()
	td("*************** HMRB:DetectHmByHealth()")
	-- Testing: Don't change HM based on health if ignoring boss health
	if (HMR.debugActive == true) and (HMR.debugIgnoreBossHealth == true) then
		return
	end

	if (self:HasHm() == false) or (self.unitTag == nil) then
		return false
	end

	local original = self:IsHm()
	local currentHp, maxHp, _ = GetUnitPower(self.unitTag, POWERTYPE_HEALTH)
	if (IsUnitInCombat(self.unitTag) == false) then
		self.inCombat = false
		self.startHp = currentHp
	else
		self.inCombat = true
	end

	self.maxHp = maxHp

	if (currentHp == 0) then
		self:SetIsDead()
	end

	if (self.sBoss.bannerWasSeen == true) then
		td("Leaving DetectHmByHealth due to banner")
		return true
	end

	td("Processing DetectHmByHealth")

	if (self.maxHp == self:GetHmHp()) then
		td("-------------- Set HM true")
		self:SetIsHm(true)
	else
		tdf("-------------- Set HM false. %d  %d", self.maxHp, self:GetHmHp())
		self:SetIsHm(false)
	end

	if (self:IsHm() ~= original) then
		self.UpdateCallback(self, nil)
	end
end

function HMRB:DetectHmMaarselok()
	td(">>>> HMRB:DetectHmMaarselok()")

	if (self.unitTag == nil) then
		return
	end

	if (IsUnitInCombat(self.unitTag) == true) then
		return
	end

	local currentHp = GetUnitPower(self.unitTag, POWERTYPE_HEALTH)
	if (currentHp == self.sBoss.hmStartHealth) then
		self:SetIsHm(true)
	-- the only time it would go from HM to normal veteran is on reset
	elseif (self.justReset == true) then
		self.justReset = false
		self:SetIsHm(false)
	end
end

function HMRB:DetectHmStonekeeper()
	td(">>>> HMRB:DetectHmSymphonyOfBlades() not implemented")
end


function HMRB:DetectHmTheKnot()
	td(">>>> HMRB:DetectHmTheKnot() not implemented")
end

function HMRB:ScrollWasRead()
	td("Scroll was read")
	self.sBoss.bannerWasSeen = true
	self:SetIsHm(true)
end

function HMRB:BannerInteraction(name, bannerState)
	if (self.sBoss.name ~= name) then
		tdf("Banner - not a match for boss %s. Banner name: %s", self.sBoss.name, name)
		return false
	end

	td("Banner")

	if (bannerState ~= self:IsHm()) then
		self.sBoss.bannerWasSeen = true
		self:SetIsHm(bannerState)
		self:UpdateUi()
	end

	return true
end

function HMRB:BannerReset()
	td("*** BANNER RESET ***")
	self.sBoss.bannerWasSeen = false
end

-- Check if this is the correct "version" of a given boss name. These cases are flagged with HMR.C.hmDetect.coordsAndHealth
function HMRB:IsCorrectBoss()
	if (self:GetArenaDetectionMethod() ~= HMR.C.arenaDetect.coordsAtBoss) then
		return true
	end

	local zoneId, x, y, z = GetUnitWorldPosition("player")
	if (self.sBoss.coord == nil) then
		tdf("***** boss.coord == nil in IsCorrectBoss() for %s", self:GetName())
		return false
	end

	if (InRange(self.sBoss.coord.xm, self.sBoss.coord.xM, x)) and (InRange(self.sBoss.coord.zm, self.sBoss.coord.zM, z)) then
		return true
	else
		return false
	end
end

function HMRB:RevivePreCheck()
	local result = false

	if (self.previousUnitTag) and (DoesUnitExist(self.previousUnitTag) == true) and (IsUnitDead(self.previousUnitTag) == false) then
		result = true
	end

	return result
end

-- the boss isn't actually dead
function HMRB:Revive()
	self:SetUnitTag(self.previousUnitTag)
	if (self:IsPresent() == true) then
		self:SetIsDead(false)
		self:SetInArena(true)
		self:UpdateBoss()
	end
end


function HMRB:GetName()
	return self.sBoss.name
end

function HMRB:GetUnitTag()
	return self.unitTag
end

function HMRB:GetBossNumber()
	return self.sBoss.bossNumber
end

function HMRB:GetArenaDetectionMethod()
	return self.sBoss.arenaDetectionMethod
end

function HMRB:GetHmDetectionMethod()
	return self.sBoss.hmDetectionMethod
end

function HMRB:InArena()
	return self.inArena
end

function HMRB:SetInArena(inArena)
	tdf("Setting inArena to %s", tostring(inArena))
	self.inArena = inArena
end

function HMRB:SetIsNextBoss(isNextBoss)
	self.isNextBoss = isNextBoss
end

function HMRB:IsNextBoss()
	return self.isNextBoss
end

function HMRB:SetUnitTag(unitTag)
	if (unitTag) and (self.unitTag ~= unitTag) then
		self:SoftShutdown()
		self.inArena = true
	end
	self.unitTag = unitTag
	self.previousUnitTag = unitTag

	self:SetIsDead()
end

-- For Maarselok code
function HMRB:SetJustReset()
	self.justReset = true
end


function HMRB:HasHm()
	if (self.sBoss == nil) then
		tdf("(self.sBoss == nil) for boss: %s", tostring(self.name))
	end
	if (self.sBoss.bossNumber) and (self.sBoss.bossNumber > 0) then
		return true
	else
		return false
	end
end

function HMRB:IsHmAvailable()
	return self.sBoss.hmAvailable
end

function HMRB:SetHmAvailable(available)
	self.sBoss.hmAvailable = available
end

function HMRB:WasSkipped()
	return self.sBoss.wasSkipped
end

function HMRB:SetWasSkipped(skipped)
	self.sBoss.wasSkipped = skipped
end

function HMRB:GetHmHp()
	return self.sBoss.hmMaxHealth
end

function HMRB:IsHm()
	return self.sBoss.isHm
end

--TODO: change this so there is a separate call from the center announcement, which triggers the normal HM detection method if the boss is present
function HMRB:SetIsHm(hm)
	if (self.sBoss) and (self.sBoss.isHm ~= hm) then
		self.sBoss.isHm = hm
		tdf("*@*@*@ HM is now %s", tostring(hm))
		self.UpdateCallback(self, nil)
	end
end

function HMRB:SetDefeated()
	self.unitTag = nil
	self.sBoss.isDead = true
	self.sBoss.isInCombat = false
	self.isPresent = false
	self.inArena = false
	self:Shutdown()
end

function HMRB:IsDead()
	self:SetIsDead()
	return self.sBoss.isDead
end

--LATER: remove redundant
function HMRB:CheckIfDead()
	if (self.unitTag == nil) then
		self:SetIsDead(true)
		return self.sBoss.isDead
	end

	self:SetIsDead()
	return self.sBoss.isDead
end

function HMRB:SetIsDead(isDead)
	local original = self.sBoss.isDead
	if (isDead ~= nil) then
		self.sBoss.isDead = isDead
		tdf("Flagged boss as dead by parameter: %s", tostring(self.sBoss.isDead))
	elseif (self.unitTag) then
		if (DoesUnitExist(self.unitTag)) then
			self.sBoss.isDead = IsUnitDead(self.unitTag)
			tdf("Flagged boss as dead by IsUnitDead(): %s", tostring(self.sBoss.isDead))
		end
	end
end

--LATER: clean up the message of dead checks
function HMRB:GetIsDead()
	return self.sBoss.isDead
end

function HMRB:GroupWiped()
	if (self.hmType == 1) then
		td("Scroll - resetting HM to false")
		self:SetIsHm(false)
	end
	self:PlayerExitedCombat(true)
	self:IsInCombat() -- to reset it
end


function HMRB:WasInCombat()
	return self.sBoss.isInCombat
end

function HMRB:PlayerIsInCombat()
	self:IsInCombat()
	
	if (self:GetArenaDetectionMethod() == HMR.C.arenaDetect.stonekeeper) then
		if (self:IsPresent() == true) then
			if (self.preBossState ~= HMR.C.fv.complete) then
				self.preBossState = HMR.C.fv.inTrashCombat
				if (self.scanningForSkeevaton == true) then
					self:StopSkeevatonWatch()
				end
			end
		end
	end

	if (self:GetArenaDetectionMethod() == HMR.C.arenaDetect.arkasis) then
		if (GetCurrentMapId() == self.sBoss.mapId) and (self.bossTrashComplete == false) then
			self.inBossTrashCombat = true
		end
	end
end

function HMRB:PlayerExitedCombat(wiped)
	if (self:GetArenaDetectionMethod() == HMR.C.arenaDetect.stonekeeper) and (self:IsPresent() == true) then
		if (self.preBossState == HMR.C.fv.skeevaton) then
			self.preBossState = HMR.C.fv.complete
			self:UpdateUi()
		end
		if (self.preBossState ~= HMR.C.fv.complete) then
			if (wiped == true) and (self.preBossState ~= HMR.C.fv.inTrashCombat) then
				self.preBossState = HMR.C.fv.start
			else
				self.preBossState = HMR.C.fv.trashCombatComplete
				self:StartSkeevatonWatch()
			end
		end
	end

	if (self:GetArenaDetectionMethod() == HMR.C.arenaDetect.arkasis) and (GetCurrentMapId() == self.sBoss.mapId) then
		if (self.inBossTrashCombat == true) and (wiped == false) then
			self.bossTrashComplete = true
			self:UpdateUi()
		end

		self.inBossTrashCombat = false
	end
end

function HMRB:IsInCombat()
	local previousInCombat = self.sBoss.isInCombat

	if (self.unitTag) then
		self.sBoss.isInCombat = IsUnitInCombat(self.unitTag)
	else
		self.sBoss.isInCombat = false
	end


	-- If the boss has HM health then the banner/scroll must have been seen
	if (self.sBoss.isInCombat == true) and (previousInCombat == false ) and (self.sBoss.bannerWasSeen == false) then
		if (self:GetHmDetectionMethod() == HMR.C.hmDetect.maxHealth) then
			self:UpdateBoss()
			if (self:IsHm() == true) then
				self.sBoss.bannerWasSeen = true
				td("**** Banner seen by health on combat start")
			end
		end
	end

	return self.sBoss.isInCombat
end

function HMRB:IsPresent()
	if (self.unitTag) then
		if (DoesUnitExist(self.unitTag) == true) and (self:IsDead() == false) then
			self.isPresent = true
		else
			self.isPresent = false
		end
	else
		self.isPresent = false
	end

	return self.isPresent
end

function HMRB:UpdateUi()
	if (self.unitTag == true) then
		self.UpdateCallback(self, nil)
	else
		self.UpdateCallback(nil, self)
	end

end

function HMRB:DetectByLocation()
	local zoneId, x, y, z = GetUnitWorldPosition("player")
	if (self.sBoss.coord == nil) then
		tdf("***** boss.coord == nil in DetectByLocation() for %s", self:GetName())
		return
	end

	if (InRange(self.sBoss.coord.xm, self.sBoss.coord.xM, x)) and (InRange(self.sBoss.coord.zm, self.sBoss.coord.zM, z)) then
		if (self.inArena ~= true) then
			td("In area")
			self.inArena = true
			self.UpdateCallback(nil, self)
		end
	else
		if (self.inArena ~= false) then
			td("Out of area")
			self.inArena = false
			self.UpdateCallback(nil, self)
		end
	end
end

function HMRB:StartLocationPolling()
	self.inBossArea = false
	if (self:GetArenaDetectionMethod() == HMR.C.arenaDetect.coordinates) then
		EM:RegisterForUpdate(HMR.name .. self.name .. "LocationPolling", 100, function() self:DetectByLocation() end)
		self.isPolling = true
		td("Start polling")
	end
end

function HMRB:StopLocationPolling()
	if (self.isPolling == true) then
		EM:UnregisterForUpdate(HMR.name .. self.name .. "LocationPolling")
		self.isPolling = false
		td("Stop polling")
	end
end

function HMRB:ShowLocationPolling()
	if (self.isPolling == true) then
		df(hmr .. "Polling ranges:  x: %d,%d y: %d,%d z: %d,%d", self.sBoss.coord.xm, self.sBoss.coord.xM, self.sBoss.coord.ym, self.sBoss.coord.yM, self.sBoss.coord.zm, self.sBoss.coord.zM)  --Leave
	else
		d(hmr .. "Not polling for location")  --Leave
	end
end

function HMRB:IsPolling()
	return self.isPolling
end

function HMRB:StartWatchingMapId()
	if (self:GetArenaDetectionMethod() == HMR.C.arenaDetect.mapId) then
		self.isWatchingMapId = true
		EM:RegisterForEvent(HMR.name .. self.name .. "OnEventCurrentSubzoneListChanged", EVENT_CURRENT_SUBZONE_LIST_CHANGED, function(...) self:OnCurrentSubzoneListChanged() end)
	end

end

function HMRB:StopWatchingMapId()
	if (self.isWatchingMapId == true) then
		EM:UnregisterForEvent(HMR.name .. self.name .. "OnEventCurrentSubzoneListChanged", EVENT_CURRENT_SUBZONE_LIST_CHANGED)
		self.isWatchingMapId = false
	end
end

function HMRB:IsWatchingMapId()
	return self.isWatchingMapId
end

function HMRB:OnCurrentSubzoneListChanged(eventCode)
	if (self.lastMapId ~= GetCurrentMapId()) then
		self.lastMapId = GetCurrentMapId()
		if (self.lastMapId == self.sBoss.mapId) then
			td("******** MAP ID MATCH")
			self.inArena = true
		else
			if (self.inArena == true) then
				td("******* Left matching map ID")
				self.inArena = false
			end
		end
	end
end

function HMRB:StartSkeevatonWatch()
	local instance = self
	EM:RegisterForEvent(HMR.name .. "OnSkeevatonWatch", EVENT_EFFECT_CHANGED, function(...) instance:OnSkeevatonWatch(...) end)
	EM:AddFilterForEvent(HMR.name .. "OnSkeevatonWatch", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
	self.scanningForSkeevaton = true
end

function HMRB:StopSkeevatonWatch()
	EM:UnregisterForEvent(HMR.name .. "OnSkeevatonWatch", EVENT_EFFECT_CHANGED)
	self.scanningForSkeevaton = false
end


local skeevatonText = nil
function HMRB:OnSkeevatonWatch(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
	if (skeevatonText == nil) then
		skeevatonText = GetString(HMR_GRANT_SKEEVATON)
	end

	if (changeType == EFFECT_RESULT_GAINED) and (zo_strlower(effectName):find(skeevatonText, 1, true)) then
			self.preBossState = HMR.C.fv.skeevaton
			self:StopSkeevatonWatch()
	end
end



function HMRB:Dump()
	df(hmr .. "%d) %s. wasSkipped: %s. isNext: %s. inArena: %s. isDead: %s. isHm: %s. isPolling: %s. isHmAvailable: %s. inCombat: %s. bannerSeen: %s. unitTag: %s", self.sBoss.bossNumber, self.sBoss.name, tostring(self.sBoss.wasSkipped), tostring(self.isNextBoss), tostring(self.inArena), tostring(self.sBoss.isDead), tostring(self.sBoss.isHm), tostring(self.isPolling), tostring(self.sBoss.hmAvailable), tostring(self.inCombat), tostring(self.sBoss.bannerWasSeen), tostring(self.unitTag))  --leave
end

