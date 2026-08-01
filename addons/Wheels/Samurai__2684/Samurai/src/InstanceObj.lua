SAMURAI = SAMURAI or { }
local sam = SAMURAI
local EM = GetEventManager()

sam.Instance = ZO_Object:Subclass()


function sam.Instance:New(zoneID, startCombat, reset, onLoad, onUnload)
	local instance = ZO_Object.New(self)
	instance:Initialize(zoneID, startCombat, reset, onLoad, onUnload)
	return instance
end

function sam.Instance:Initialize(zoneID, startCombat, reset, onLoad, onUnload)
	self.zoneID = zoneID
	self.alerts = { }
	self.startCombat = StartCombat
	self.reset = reset
	self.onLoad = onLoad
	self.onUnload = onUnload
	self.loaded = false
end

function sam.Instance:getZoneID()
	return self.zoneID
end

function sam.Instance:getIsLoaded()
	return self.loaded
end

function sam.Instance:Reset()
      	if self.reset then self.reset() end
end

function sam.Instance:StartCombat()
      	if self.startCombat then self.startCombat() end
end

function sam.Instance:AddAlert(alertObj)
	table.insert(self.alerts, alertObj)
end

function sam.Instance:Register()
	if self.loaded then return end -- don't double load
	if self.onLoad then self.onLoad() end
	for k,v in pairs(self.alerts) do
		v:Register()
	end
	--EM:RegisterForEvent(sam.name.."CombatState"..tostring(self.zoneID), EVENT_PLAYER_COMBAT_STATE, function(e, inCombat)
	--	sam.debug("combat state changed to: %s", tostring(inCombat))
	--	if inCombat then
	--		if self.startCombat then
	--			sam.debug("firing startCombat handler")
	--			self.startCombat()
	--		end
	--	else
	--		if self.reset then
	--			sam.debug("firing reset handler")
	--			self.reset()
	--		end
	--	end
	--end)
	self.loaded = true
end

function sam.Instance:Unregister()
	if not self.loaded then return end -- only unregister if we have already registered for this instance
	sam.debug("unloading zone %d", self.zoneID)
	if self.onUnload then self.onUnload() end
	for k,v in pairs(self.alerts) do
		v:Unregister()
	end
	--EM:UnregisterForEvent(sam.name.."CombatState"..tostring(self.zoneID), EVENT_PLAYER_COMBAT_STATE)
	self.loaded = false
end

