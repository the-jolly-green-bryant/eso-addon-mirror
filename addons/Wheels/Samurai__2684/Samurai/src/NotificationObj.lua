SAMURAI = SAMURAI or { }
local sam = SAMURAI
local EM = GetEventManager()
local strformat = string.format

local timedAttackListMaster = { }
-- will be filled with sublists with the format:
-- { "attack name: ", "color", { table of attack timers } }
-- innermost table will be updated with times
-- attack table with be added or removed on registration


local function formatTimedAttackList()
	local countdownList = {}
	local countdownListFormatted = {}
	local t = GetGameTimeMilliseconds()

	for _, subList in pairs(timedAttackListMaster) do
		local countdownSubList = { }	
		local formattedSubList = { }
		local subListString = ""
		for key, value in pairs(subList[3]) do
			if value[1] > t then
				table.insert(countdownSubList, value[1] - t)
			else
				table.remove(subList[3], key)
			end
		end

		if #countdownSubList > 0 then
			table.sort(countdownSubList)
			for _, value in ipairs(countdownSubList) do
				local color = value < 1000 and "FF0000" or subList[2]
				local format = "|c"..color.."%0.1f|r"
				table.insert(formattedSubList, strformat(format, value/1000))
			end
			subListString = subList[1] .. table.concat(formattedSubList, " / ")
			table.insert(countdownListFormatted, subListString)
		end
	end
	if #countdownListFormatted > 0 then
		return table.concat(countdownListFormatted, "\n")
	else
		return nil
	end
end

local function timedAttackCounter()
	local text = formatTimedAttackList()
	if not text or text == "" then
		EM:UnregisterForUpdate(sam.name.."TimedAttackCountdown")
		sam.UI.timedAlert:SetHidden(true)
		for _,subList in pairs(timedAttackListMaster) do
			for k in pairs(subList[3]) do
				subList[3][k] = nil
			end
		end
	else
		sam.UI.timedAlert:SetText(text)
	end
end

-- this could probably be consolidated into the handlers, and would require no loops
local function removeCancelledAttack(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
	-- debug stuff
	--local r = ""
	--if result == ACTION_RESULT_DIED then
	--	r = "DIED"
	--elseif result == ACTION_RESULT_DIED_XP then
	--	r = "DIED_XP"
	--elseif result == ACTION_RESULT_INTERRUPT then
	--	r = "INTERRUPT"
	--elseif result == ACTION_RESULT_STUNNED then
	--	r = "STUNNED"
	--end
	--sam.debug("result: %s, sourceID: %d, targetID: %d", r, sourceUnitId, targetUnitId)
	local t = GetGameTimeMilliseconds()
	for k,v in pairs(timedAttackListMaster) do
		if v[3][sourceUnitId] or v[3][targetUnitId] then
			sam.debug("attempting to remove attack where source ID name is %s (%d), target ID name is %s (%d)", sam.LUNITS.GetNameForUnitId(sourceUnitId), sourceUnitId, sam.LUNITS.GetNameForUnitId(targetUnitId), targetUnitId)
		end
		if v[3][sourceUnitId] then sam.debug("source ID found") end
		if v[3][targetUnitId] then sam.debug("target ID found") end
		v[3][targetUnitId] = nil
	end
end

function sam.onStartupNotificationSetup()
	EM:RegisterForEvent(sam.name.."UnitDied", EVENT_COMBAT_EVENT, removeCancelledAttack) -- not sure this actually works yet
	EM:AddFilterForEvent(sam.name.."UnitDied", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_DIED)
	EM:RegisterForEvent(sam.name.."UnitDiedXP", EVENT_COMBAT_EVENT, removeCancelledAttack)
	EM:AddFilterForEvent(sam.name.."UnitDiedXP", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_DIED_XP)
	EM:RegisterForEvent(sam.name.."UnitInterrupt", EVENT_COMBAT_EVENT, removeCancelledAttack)
	EM:AddFilterForEvent(sam.name.."UnitInterrupt", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_INTERRUPT)
	EM:RegisterForEvent(sam.name.."UnitStunned", EVENT_COMBAT_EVENT, removeCancelledAttack)
	EM:AddFilterForEvent(sam.name.."UnitStunned", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_STUNNED)
end

local function clearMasterTable(e, inCombat)
	if inCombat then return end
	local count = 0
	for k,v in pairs(timedAttackListMaster) do
		--timedAttackListMaster[k][3] = { }
		count = count + #timedAttackListMaster[k][3]
	end
	if count > 0 then
		sam.debug("|cFF0000ALERT:|r %d attacks still in master list", count)
	end
end

sam.EM:RegisterForEvent(sam.name.."clearTable", EVENT_PLAYER_COMBAT_STATE, clearMasterTable)

function sam.masterPrint()
	for k,v in pairs(timedAttackListMaster) do
		sam.debug("%s: %s", tostring(k), tostring(v))
	end
end

-- NOTIFICATION OBJECT PARENT
sam.Notification = ZO_Object:Subclass()

function sam.Notification:New()
	local noti = ZO_Object.New(self)
	noti:Initialize()
	return noti
end

function sam.Notification:InitializeParent(name, color, event, result, IDs, text)
	self.name = name
	self.color = color
	self.event = event
	self.IDs = IDs
	self.text = text
	self.result = result
end


-- TIMED ALERT OBJECT
sam.TimerNotification = sam.Notification:Subclass()

function sam.TimerNotification:New(name, color, text, event, result, IDs, targetPlayer)
	local timer = ZO_Object.New(self)
	timer:Initialize(name, color, text, event, result, IDs, targetPlayer)
	return timer
end

function sam.TimerNotification:Initialize(name, color, text, event, result, IDs, targetPlayer)
	self:InitializeParent(name, color, event, result, IDs, text)
	self.targetPlayer = targetPlayer
end

function sam.TimerNotification:Handler(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
	if sam.savedVars.notis[self.name] ~= nil and not sam.savedVars.notis[self.name] then
		sam.debug("skipping %s", self.name)
		return
	end
	if (self.targetPlayer and targetType ~= COMBAT_UNIT_TYPE_PLAYER) or hitValue < 400 then return end -- testing more aggressive filtering, might have to make configurable
	sam.debug("handler fired for %s, result is %d, targetPlayer is %s", self.name, result, tostring(self.targetPlayer))

	if result == self.result then
		if sourceUnitId == 0 then sourceUnitId = targetUnitId end
		sam.debug("adding attack where source ID name is %s (%d), target ID name is %s (%d)", sam.LUNITS.GetNameForUnitId(sourceUnitId), sourceUnitId, sam.LUNITS.GetNameForUnitId(targetUnitId), targetUnitId)
		timedAttackListMaster[self.name][3][sourceUnitId] = {GetGameTimeMilliseconds() + hitValue, targetUnitId}
		timedAttackCounter()
		sam.UI.timedAlert:SetHidden(false)
		PlaySound(SOUNDS.CHAMPION_POINTS_COMMITTED)

		EM:UnregisterForUpdate(sam.name.."TimedAttackCountdown")
		EM:RegisterForUpdate(sam.name.."TimedAttackCountdown", 100, timedAttackCounter)
	end
end

function sam.TimerNotification:Register()
	sam.debug("registering timed alert with name: %s", self.name)
	local function wrapper(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
		self:Handler(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
	end
	timedAttackListMaster[self.name] = {self.text..": ", self.color, {} }
	for k,v in pairs(self.IDs) do
		sam.EM:RegisterForEvent(sam.name..self.name..tostring(v), self.event, wrapper)
		sam.EM:AddFilterForEvent(sam.name..self.name..tostring(v), self.event, REGISTER_FILTER_ABILITY_ID, v)
	end
end

function sam.TimerNotification:Unregister()
	sam.debug("unregistering timed alert with name: %s", self.name)
	EM:UnregisterForUpdate(sam.name.."TimedAttackCountdown")
	timedAttackListMaster[self.name] = nil
	for k,v in pairs(self.IDs) do
		sam.EM:UnregisterForEvent(sam.name..self.name..tostring(v), self.event)
	end
	for k,v in pairs(sam.UI.activeAlerts) do
		v:SetHidden(true)
	end
	sam.UI.timedAlert:SetHidden(true)
	for k in pairs(timedAttackListMaster) do
		timedAttackListMaster[k][3] = { }
	end
end


-- ACTIVE ALERT OBJECT
sam.ActiveNotification = sam.Notification:Subclass()

-- for now, we will pass the appropriate handler function as a parameter for anything complex
function sam.ActiveNotification:New(customRegister, customUnregister, name, color, event, result, IDs, text, duration, targetPlayer)
	local alert = ZO_Object.New(self)
	alert:Initialize(customRegister, customUnregister, name, color, event, result, IDs, text, duration, targetPlayer)
	return alert
end

function sam.ActiveNotification:Initialize(customRegister, customUnregister, name, color, event, result, IDs, text, duration, targetPlayer)
	self:InitializeParent(name, color, event, result, IDs, text)
	self.duration = duration
	self.targetPlayer = targetPlayer -- true if we are only listening to direct player attacks
	self.customRegister = customRegister -- for handling more complex alerts...
	self.customUnregister = customUnregister -- we just (un)register custom external handlers

	self.currentFrame = -1
	self.displaying = false
	self.alertCounter = 0
end

function sam.ActiveNotification:Handler(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
	--if not sam.savedVars.notis[self.name] then
	if sam.savedVars.notis[self.name] ~= nil and not sam.savedVars.notis[self.name] then
		sam.debug("skipping %s", self.name)
		return
	end
	if self.targetPlayer and targetType ~= COMBAT_UNIT_TYPE_PLAYER then return end
	sam.debug("firing active handler for %s, result is %d", self.name, result)
	if result == self.result then
		self.alertCounter = self.alertCounter + 1
		if not self.displaying then -- don't double display a noti in case of fast-firing events
			self.currentFrame = sam.UI.getAvailableNotificationFrame()
			self.displaying = true
			local alertText = string.format("|c%s%s|r", self.color, self.text)
			sam.UI.displayAlert(self.currentFrame, alertText)
		end
		PlaySound(SOUNDS.CHAMPION_POINTS_COMMITTED)

		zo_callLater(function()
			self.alertCounter = self.alertCounter - 1
			if self.alertCounter <= 0 then
				self.alertCounter = 0
				sam.UI.hideAlert(self.currentFrame)
				self.displaying = false
				self.currentFrame = -1
			end
		end, self.duration)
	end
end

function sam.ActiveNotification:Register()
	sam.debug("registering active alert with name: %s", tostring(self.name))
	if self.customRegister then
		self.customRegister()
	else
		local function wrapper(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
			self:Handler(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
		end
		for k,v in pairs(self.IDs) do
			sam.EM:RegisterForEvent(sam.name..self.name..tostring(v), self.event, wrapper)
			sam.EM:AddFilterForEvent(sam.name..self.name..tostring(v), self.event, REGISTER_FILTER_ABILITY_ID, v)
		end
	end
end

function sam.ActiveNotification:Unregister()
	sam.debug("unregistering active alert with name: %s", tostring(self.name))
	if self.customUnregister then
		self.customUnregister()
	end
	EM:UnregisterForUpdate(sam.name.."TimedAttackCountdown")
	if self.IDs then
	 	for k,v in pairs(self.IDs) do
	 		sam.EM:UnregisterForEvent(sam.name..self.name..tostring(v), self.event)
	 	end
	end
	for k,v in pairs(sam.UI.activeAlerts) do
		v:SetHidden(true)
	end
	sam.UI.timedAlert:SetHidden(true)
	for k in pairs(timedAttackListMaster) do
		timedAttackListMaster[k][3] = { }
	end
	self.displaying = false
	self.currentFrame = -1
	self.alertCounter = 0
end

