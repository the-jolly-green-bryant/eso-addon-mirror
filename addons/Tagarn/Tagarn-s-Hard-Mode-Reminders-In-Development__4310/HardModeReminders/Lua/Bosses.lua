-- Copyright (c) 2025 by Tagarn

-- This add-on may be copied, shared, and used as-is while playing Elder
-- Scrolls Online, provided this notice is left intact. However, this
-- add-on, in part or in full, may not be used in the creation of other
-- add-ons without the express written consent of Tagarn.

-- The Elder Scrolls Online add-on provided by Tagarn ("we," "us," or "our")
-- is for entertainment purposes only. UNDER NO CIRCUMSTANCE SHALL WE HAVE ANY
-- LIABILITY TO YOU FOR ANY LOSS OR DAMAGE OF ANY KIND INCURRED AS A RESULT OF
-- THE USE OF OUR ADD-ON. YOUR USE OF OUR ADD-ON IS SOLELY AT YOUR OWN RISK.


HardModeRemindersBosses = {}
local EM = EVENT_MANAGER

local HMRBs = HardModeRemindersBosses
local HMRB = HardModeRemindersBoss

HardModeReminders = HardModeReminders or {}
local HMR = HardModeReminders
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

function HMRBs:New(zoneId, isNewZone, s, UpdateCallback, bossZoneIdIndex )
	local o = {}
	setmetatable(o, self)
	self.__index = self

	o:Initialize(zoneId, isNewZone, s, UpdateCallback, bossZoneIdIndex)
	return o
end

function HMRBs:Initialize(zoneId, isNewZone, s, UpdateCallback, zoneBosses)
	self.zoneId = zoneId
	self.s = s
	self.nextBossNumber = 1
	self.maxBossNumber = 0
	self.previousBossDefeated = 0
	self.currentBoss = nil
	self.UpdateCallback = UpdateCallback
	self.isInCombat = IsUnitInCombat("player")
	self.noMoreHmBossesAvailable = false
	self.bossMonitoring = false

	self.combatBoss = nil
	self.previousBoss = nil

	tdf("**** BOSS INIT: %s ****", tostring(isNewZone))

	-- The case where we're saving a HM dungeon/trial data while we're temporarily in another non-HM zone
	if (zoneId ~= s.zoneId) then
		-- d("********** NOT IN SAVED ZONE")
		return
	end

	if (isNewZone == true) then
		self:InitializeBosses(zoneBosses)
	end

	self:LoadBosses()


	self:FindNextBoss()

	local zoneId  =  GetUnitRawWorldPosition("player")
	if (self.zoneId == zoneId) then
		self.s.lastTime = GetGameTimeSeconds()
	end


	self:CheckForCurrentBoss()
end

-- Used when there is no current boss data saved in the saved variables
function HMRBs:InitializeBosses(zoneBosses)
	self.s.bosses = {}
	self.s.bossNameIndex = {}
	assert(self)
	assert(self.zoneId)
	assert(zoneBosses)
	for _, boss in ipairs(zoneBosses) do
		assert(boss)
		local boss_c = ZO_DeepTableCopy(boss)
		assert(boss_c)
		boss_c.wasSkipped = false
		boss_c.isPresent = false
		boss_c.inArea = false
		boss_c.isDead = false
		boss_c.isHm = false
		boss_c.hmAvailable = true --LATER: change if non-HM bosses are added to the data

		boss_c.isInCombat = false
		self.s.bosses[boss_c.bossNumber] = boss_c

		self.s.bossNameIndex[boss_c.name] = boss_c

		tdf("Initialized %s", boss_c.name)
	end

	table.sort(self.s.bosses, function (k1, k2) return k1.bossNumber < k2.bossNumber end)
end

function HMRBs:LoadBosses()
	self.bosses = {}
	for _, boss in ipairs(self.s.bosses) do
		table.insert(self.bosses, HMRB:New(boss, self, self.UpdateCallback))
		if (boss.bossNumber) and (boss.bossNumber > self.maxBossNumber) then
			self.maxBossNumber = boss.bossNumber
		end
	end
end

function HMRBs:Reactivate()

	self:CheckForCurrentBoss()
end

function HMRBs:EnteringCombat()
	self.isInCombat = true
	if (self.currentBoss) then
		self.combatBoss = self.currentBoss
		self.currentBoss:PlayerIsInCombat() -- also sets the boss.inCombat flag
	end

	if (self.bossMonitoring == true) then
		self:StopBossMonitoring()
	end

	self:UpdateUi()
end

function HMRBs:CombatEndedInWipe(boss)
	-- Scroll-like HMs always reset to normal veteran after a wipe
	if (self.currentBoss) and (self.currentBoss.hmType == 1) then
		self.currentBoss:GroupWiped()
		-- self.currentBoss:SetIsHm(false)
		
	end
	if (self.combatBoss) then
		-- self.combatBoss:PlayerExitedCombat(true)
		self.combatBoss:GroupWiped()
		-- if (self.combatBoss.hmType == 1) then
		-- 	self.combatBoss:SetIsHm(false)
		-- end
		-- self.combatBoss:IsInCombat() -- to reset it
	elseif (self.currentBoss) then
		self.currentBoss:PlayerExitedCombat(true)
	end
	self:CheckForCurrentBoss()

	self:StartBossMonitoring()
end

local monitorStartTime = 0
local monitorEndTime = 0
function HMRBs:StartBossMonitoring()
	td(">>> HMRBs:StartBossMonitoring()")
	if (self.bossMonitoring == true) then
		return
	end

	self.bossMonitoring = true
	monitorStartTime = GetGameTimeSeconds()
	monitorEndTime = monitorStartTime + 30 -- stop monitoring after 30 seconds
	EM:RegisterForUpdate(HMR.name .. "BossWipeMonitoring", 500, function() self:PostBossCombatCheck() end)
end

function HMRBs:StopBossMonitoring()
	td(">>> HMRBs:StopBossMonitoring()")
	EM:UnregisterForUpdate(HMR.name .. "BossWipeMonitoring")
	self.bossMonitoring = false
end

function HMRBs:PostBossCombatCheck()
	td(">>> HMRBs:PostBossCombatCheck()")

	if (self.bossMonitoring == true) then
		if (GetGameTimeSeconds() > monitorEndTime) then
			td("----Stopping monitoring due to timeout")
			self:StopBossMonitoring()
			return
		end
	end

	-- The case when the zone was reset before this check triggered
	--LATER: ideally stop the delayed callback when zone resets or player teleports
	if (self == nil) or (self.s == nil) or (self.s.zoneId == nil) then
		return
	end

	-- The player may have ported out before this triggers
	if (GetUnitRawWorldPosition("player") ~= self.s.zoneId) then
		return
	end

	if (self.previousBoss) then
		td("Found previous")
		local present = self.previousBoss:RevivePreCheck()
		if (present == true) then
			td("Boss is present")
			if (self.nextBoss) then
				self.nextBoss:Shutdown()
				self.nextBoss = nil
			end
			self.currentBoss = self.previousBoss
			self.nextBossNumber = self.currentBoss:GetBossNumber()
			self.noMoreHmBossesAvailable = false
			self.currentBoss:Revive()
			self:UpdateUi()
			self:StopBossMonitoring()
		else
			td("BOSS IS NOT PRESENT")
			td("%s %s", tostring(self.previousBoss.unitTag), tostring(self.previousBoss.isDead))
		end
	else
		td("NO PREVIOUS")
	end
end

function HMRBs:CombatEnded()
	td(">>> HMRBs:CombatEnded()")
	self.isInCombat = false

	if (self.combatBoss) then
		self.combatBoss:PlayerExitedCombat(false)
		if (self.combatBoss:WasInCombat() == true) then
			if (self.combatBoss:IsHm() == false) then
				self:BossDefeatedWithoutHm(self.combatBoss:GetBossNumber())
			end
			-- double-check that the boss is dead after a few seconds
			self.previousBoss = self.combatBoss
			td("**** self.previousBoss: ", type(self.previousBoss))
			zo_callLater(function()
				self:PostBossCombatCheck()
			end, 15000)
			self.combatBoss:SetDefeated()
			self.combatBoss:Shutdown()
			self.combatBoss = nil
			self.currentBoss:Shutdown() -- just in case this differed. It shouldn't
			self.currentBoss = nil
			td("**** self.previousBoss: ", type(self.previousBoss))
			self:FindNextBoss()
		else
			self.currentBoss:UpdateBoss()
		end

		self.combatBoss = nil
		self:UpdateUi()
	else
		if (self.currentBoss) then
			self.currentBoss:PlayerExitedCombat(false)
		end
	end
end

function HMRBs:BossDefeatedWithoutHm(bossNumber)
	self.noMoreHmBossesAvailable = true
	for _, boss in ipairs(self.bosses) do
		if (boss:GetBossNumber() >= bossNumber ) then
			boss:SetHmAvailable(false)
		end
	end
end

function HMRBs:ScrollWasRead()
	-- d("******* ScrollWasRead")
	if (self.currentBoss) then
		self.currentBoss:ScrollWasRead()
	end

	self:UpdateUi()
end

function HMRBs:OnPlayerActivated(eventCode, initial)
	td(">>> Bosses:OnPlayerActivated()")
	local zoneId =  GetUnitRawWorldPosition("player")
	if (self.zoneId == zoneId) then
		self.s.lastTime = GetGameTimeSeconds()
	end
	if (self.currentBoss) then
		self.currentBoss:UpdateBoss()
	end
	if (self.nextBoss) then
		self.nextBoss:UpdateBoss()
	end
end

function HMRBs:OnPlayerDeactivated(eventCode, initial)
	td(">> Bosses:OnPlayerDectivated()")
	local zoneId  =  GetUnitRawWorldPosition("player")
	if (self.zoneId == zoneId) then
		self.s.lastTime = GetGameTimeSeconds()
	end

	if (self.currentBoss) then
		self.currentBoss:SoftShutdown()
	end

	if (self.nextBoss) then
		self.nextBoss:Shutdown()
	end
end

function HMRBs:DifficultyChanged(bossName, isHm)
	if (isHm == nil) then
		return
	end

	for _, boss in ipairs(self.bosses) do
		if (boss:BannerInteraction(bossName, isHm) == true) then
			break
		end
	end

	-- -- check currentBoss and nextBoss first
	-- if (self.currentBoss) then
	-- 	if (self.currentBoss:NameCheck(bossName) == true) then
	-- 		-- Requires a slight delay, as the boss's health as not changed at this point
	-- 		zo_callLater(function()
	-- 			self.currentBoss:UpdateBoss()
	-- 			self:UpdateUi()
	-- 			end, 250)
	-- 		return
	-- 	end
	-- elseif(self.nextBoss) then
	-- 	if (self.nextBoss:NameCheck(bossName) == true) then
	-- 		self.nextBoss:SetIsHm(isHm)
	-- 		self:UpdateUi()
	-- 		return
	-- 	end
	-- end

	-- -- check other bosses. (This case shouldn't happen, except maybe Sunspire first two bosses?)
	-- for _, lboss in ipairs(self.bosses) do
	-- 	if (lboss:NameCheck(bossName) == true) then
	-- 		lboss:SetIsHm(isHm)
	-- 		self:UpdateUi()
	-- 		return
	-- 	end
	-- end
end


--@return HardModeRemindersBoss
function HMRBs:GetBossByBossNumber(bossNumber)
	local boss = nil

	-- try currentBoss first, since it is probably the one we are looking for
	if (self.currentBoss) and (self.currentBoss:GetBossNumber() == bossNumber) then
		boss = self.currentBoss
	else
		if (self.bosses == nil) then
			td("---------- self.bosses == nil in GetBossByBossNumber")
		end
		for _, lboss in ipairs(self.bosses) do
			if (lboss:GetBossNumber() == bossNumber) then
				boss = lboss
				break
			end
		end
	end

	return boss
end

--@return HardModeRemindersBoss
function HMRBs:GetBossByBossName(bossName)
	local boss = nil

	-- try currentBoss first, since it is probably the one we are looking for
	if (self.currentBoss) and (self.currentBoss:GetName() == bossName) then
		boss = self.currentBoss
	else
		if (self.bosses == nil) then
			return nil
		end
		for _, lboss in ipairs(self.bosses) do
			if (lboss:GetName() == bossName) then
				boss = lboss
				break
			end
		end
	end

	return boss
end

function HMRBs:GetNumberOfBosses()
	return #self.bosses
end

function HMRBs:DumpBosses()
	if (self.currentBoss ~= nil) then
		df("Current boss: %s", self.currentBoss:GetName())  --leave
	end
	if (self.nextBoss ~= nil) then
		df("Next boss: %s", self.nextBoss:GetName())  --leave
	else
		d("No next boss")  --leave
	end

	for _, lboss in ipairs(self.bosses) do
		lboss:Dump()
	end
end

function HMRBs:FindNextBoss()
	td(">> FindNextBoss")
	if (self.nextBossNumber == 0) or (self.noMoreHmBossesAvailable == true) then
		td("FindNextBoss: Returning as there are no new HM bosses")
		return
	end

	local boss = self:GetBossByBossNumber(self.nextBossNumber)
	if (boss) then
		if (boss:IsDead() == true) or (boss:WasSkipped() == true) then
			self.nextBossNumber = self.nextBossNumber + 1
			if (self.nextBossNumber <= self.maxBossNumber) then
				self:FindNextBoss()
				return
			else
				self.nextBossNumber = self.maxBossNumber
				boss = nil
			end
		end
		if (self.nextBoss) and (boss) and (self.nextBoss.name ~= boss.name) then
			self.nextBoss:Shutdown()
		end
		self.nextBoss = boss
		if (self.nextBoss) then
			self.nextBoss:SetIsNextBoss(true)
			self.nextBoss:UpdateBoss()
		end
	else
		if (self.nextBoss) then
			self.nextBoss:Shutdown()
			self.nextBoss = nil
		end
	end

	if (self.nextBoss) then
		self.nextBoss:UpdateBoss()
	end

	self:UpdateUi()
end

function HMRBs:Shutdown()
	if (self.bosses) then
		-- stop any polling
		for _, boss in pairs(self.bosses) do
			boss:Shutdown()
			boss = nil
		end
	end

	self.bosses = nil

	local zoneId  = GetUnitRawWorldPosition("player")
	if (self.zoneId == zoneId) then
		self.s.lastTime = GetGameTimeSeconds()
	end
end

-- If the player entered the dungeon/trial after the first boss died, update the bosses
--LATER: remove?
function HMRBs:UpdateBosses(bossNumber)
	for i = 1, bossNumber - 1 do
		if (self.bosses[i]:IsDead() == false) then
			self.bosses[i]:SetWasSkipped(true)
		end
	end
end

-- Handle this here, rather than in boss objects, to cut down on the number of checks being done, once a boss is found
-- Maybe allow them to all watch for this until one is found, and that boss handles them all until it is no longer present?
function HMRBs:OnBossesChanged(eventId, forceReset)
	-- td(">> OnBossesChanged")

	if (self.currentBoss) and (self.currentBoss:WasInCombat() == true) then
		return
	end

	self:CheckForCurrentBoss()
	self:UpdateUi()
end

function HMRBs:OnPowerUpdate(eventId, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
	-- tdf(">> OnPowerUpdate")

	-- Don't monitor the boss during combat. We only need the outcome of the fight
	if (self.currentBoss) and (self.currentBoss:WasInCombat() == true) then
		-- Turn off the "NOT HARD MODE" warning
		if (HMR.warningIsShown == true) and (HMR.stoppingWarningAnimation == false) and (self.currentBoss:IsHm() == false) then
			HMR.HideWarningDelayed()
		end
		return
	end

	self:CheckForCurrentBoss()

	if (self.currentBoss) and (unitTag ~= self.currentBoss:GetUnitTag()) then
		return
	end

	self:UpdateUi()
end

function HMRBs:UpdateHmAvailability()
	--LATER: should this code check if something is wrong, and this boss was flagged as not available, but in fact was?
	if (self.currentBoss:IsDead() == true) then
		if (self.currentBoss:IsHm() == false) then
			self.noMoreHmBossesAvailable = true
			for i = self.nextBossNumber, self.maxBossNumber do
				local boss = self:GetBossByBossNumber(i)
				if (boss) then
					boss:SetHmAvailable(false)
				end
			end
		end
	end
end

function HMRBs:SkipCheck(currentBossNumber)
	for _, boss in pairs(self.bosses) do
		if (boss:GetBossNumber() < currentBossNumber) and (boss:GetIsDead() == false) then
			boss:SetWasSkipped(true)
		end
	end
end

function HMRBs:CheckForABoss()
	td("CheckForABoss()")
	local boss = nil
	for i = 1, MAX_BOSSES do
		if (i == 1) then 
			td("Looking for boss")
		end
		if (DoesUnitExist(HMR.bossUnitTags[i])) then
			td("Exists")
			local unitTag = HMR.bossUnitTags[i]

			boss = self:GetBossByBossName(GetUnitName(unitTag))
			if (boss) and (boss:IsCorrectBoss() == true) then
				tdf("Boss found %s. IsDead: %s", boss:GetName(), tostring(boss:IsDead()))
				self:SkipCheck(boss:GetBossNumber())
				self.nextBossNumber = boss:GetBossNumber()
				if (boss:IsDead() == false) then
					boss:SetUnitTag(unitTag)
					break
				else
					boss = nil
					break
				end
			elseif (boss) and (boss:IsCorrectBoss() == false) then
				td("Check found wrong boss")
			else
				td("Existed, but no boss found")
			end

			boss = nil
		end
		
	end

	if (boss == nil) then
		td("No boss found")
	end
	
	return boss
end

function HMRBs:CheckForCurrentBoss()
	td("CheckForCurrentBoss()")
	if (self.currentBoss) then
		self.currentBoss:UpdateBoss()
		if (self.currentBoss:IsPresent() == true) then
			if (self.currentBoss:IsInCombat() == true) then
				-- self:StopBossMonitoring() -- boss could enter combat while player is already fighting
				self.combatBoss = self.currentBoss
			end
			if (self.currentBoss:IsDead() == false) then
				return
			end
		else
			self.currentBoss:Shutdown()
			self.currentBoss = nil
		end
	end

	local boss = self:CheckForABoss()

	if (boss) then
		if (self.nextBoss) then
			if (self.nextBoss == boss) then
				self.nextBoss:SoftShutdown()
			else
				self.nextBoss:Shutdown()
			end

			self.nextBoss = nil
		end
		boss:UpdateBoss()

		self.currentBoss = boss

		self:UpdateUi()
		return
	else
		if (self.nextBoss == nil) then
			self:FindNextBoss()
		end
		return
	end
end

-- For taking care of things that need to be done when the zone was exited
function HMRBs:InADifferentZone()
	for _, boss in pairs(self.bosses) do
		boss:StopLocationPolling()
		boss:SetInArena(false)
		boss:BannerReset()
	end
end

--@return HardModeRemindersBoss
function HMRBs:GetCombatBoss()
	return self.combatBoss
end

--@return HardModeRemindersBoss
function HMRBs:GetCurrentBoss()
	return self.currentBoss
end

--@return HardModeRemindersBoss
function HMRBs:GetNextBoss()
	return self.nextBoss
end

function HMRBs:CurrentBossIsAlive()
	td("**CurrentBossIsAlive()")
	if (self.currentBoss) then
		self.currentBoss:UpdateBoss()
		td("--- updating boss")
	else
		td("--- self.currentBoss == nil) in CurrentBossIsAlive()")
	end
end

function HMRBs:UpdateUi()
	self.UpdateCallback(self.currentBoss, self.nextBoss)
end


function HMRBs:FixIt()
	if (self.currentBoss) then
		self.currentBoss:Shutdown()
		self.currentBoss = nil
	end

	if (self.nextBoss) then
		self.nextBoss:Shutdown()
		self.nextBoss = nil
	end

	local boss = self:GetBossByBossNumber(1)
	if (boss) then
		boss:SetIsDead(true)
		boss:SetIsHm(true)
	end

	boss = self:GetBossByBossNumber(2)
	if (boss) then
		boss:SetIsDead(true)
		boss:SetIsHm(true)
	end

	self:CheckForCurrentBoss()

end

function HMRBs:FixIt2()

	local boss = self:GetBossByBossNumber(3)
	if (boss) then
		boss.inArkasisTrashCombat = true
		boss:PlayerExitedCombat(false)
	end

end
-- 	if (self.currentBoss) then
-- 		self.currentBoss:Shutdown()
-- 		self.currentBoss = nil
-- 	end

-- 	if (self.nextBoss) then
-- 		self.nextBoss:Shutdown()
-- 		self.nextBoss = nil
-- 	end

-- 	-- Ensure Shard is set to dead and killed in HM
-- 	local boss = self:GetBossByBossNumber(2)
-- 	if (boss) then
-- 		if (boss:IsDead() ~= true) then
-- 			df("***** %s IsDead() is: %s", boss:GetName(), tostring(boss:IsDead()))
-- 		end
-- 		if (boss:IsHm() ~= true) then
-- 			df("***** %s IsHm() is: %s", boss:GetName(), tostring(boss:IsHm()))
-- 		end
-- 		boss:SetIsDead(true)
-- 		boss:SetIsHm(true)
-- 	end

-- 	-- set Xoryn as next boss
-- 	boss = self:GetBossByBossNumber(3)
-- 	if (boss) then
-- 		self.nextBoss = boss
-- 		self.nextBoss:SetIsNextBoss(true)
-- 		self.nextBoss:UpdateBoss()
-- 	end


-- 	self:UpdateUi()
-- end