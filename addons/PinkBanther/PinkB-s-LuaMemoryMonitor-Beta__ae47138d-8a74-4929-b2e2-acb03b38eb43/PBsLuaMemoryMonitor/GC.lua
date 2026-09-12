-- PB's LuaMemoryMonitor -- freeing memory
--
-- Lua returns the memory of data nothing uses any more only when its collector gets round to
-- it; until then that memory counts in the add-on memory like anything else (the window's
-- "Other" row). A full collection -- collectgarbage("collect"), which the client lets add-ons
-- run (0.1.1 probe) -- returns all of it at once, at the price of a stall while it runs: 74 ms
-- on a PS5 with 109 MB of heap. So it is off unless asked for, and on a timer it waits for
-- combat to end unless told not to.

local addon = PBS_LUA_MEMORY_MONITOR
if not addon then
	return
end

local UPDATE_NAME = addon.name .. "_Collect"
local COMBAT_NAME = addon.name .. "_CollectAfterCombat"

local function InCombat()
	return type(IsUnitInCombat) == "function" and IsUnitInCombat("player") == true
end

-- Runs a full collection and keeps the readings either side of it for the window.
function addon:CollectNow(report)
	local result = { heapBefore = self.ReadKB(), poolBefore = self.ReadPoolMB() }
	local startMs = self.NowMs()
	local ok, problem = pcall(collectgarbage, "collect")
	result.ms = math.floor(self.NowMs() - startMs)
	result.heapAfter, result.poolAfter = self.ReadKB(), self.ReadPoolMB()
	result.ok = ok
	if not ok then
		result.problem = tostring(problem)
	end
	self.lastCollect = result

	if report then
		if ok then
			self.Say(string.format(GetString(SI_PBSLMM_COLLECT_DONE), result.ms,
				self.FormatMB(result.heapBefore and result.heapBefore / 1024),
				self.FormatMB(result.heapAfter and result.heapAfter / 1024),
				self.FormatMB(result.poolBefore), self.FormatMB(result.poolAfter)))
		else
			self.Say(string.format(GetString(SI_PBSLMM_COLLECT_FAILED), result.problem))
		end
	end
	if self.RefreshWindow then
		self:RefreshWindow()
	end
	return result
end

local function StopWaitingForCombat()
	EVENT_MANAGER:UnregisterForEvent(COMBAT_NAME, EVENT_PLAYER_COMBAT_STATE)
end

local function OnCombatState(_, inCombat)
	if not inCombat then
		StopWaitingForCombat()
		addon:CollectNow(false)
	end
end

-- A run that falls in combat waits for combat to end rather than being skipped: with a long
-- interval, a skipped run could be skipped again and again in a combat-heavy session.
local function OnTimer()
	if InCombat() and not addon.sv.collectInCombat then
		EVENT_MANAGER:RegisterForEvent(COMBAT_NAME, EVENT_PLAYER_COMBAT_STATE, OnCombatState)
		return
	end
	addon:CollectNow(false)
end

function addon:ApplyCollectTimer()
	EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME)
	StopWaitingForCombat()
	local seconds = tonumber(self.sv.collectEvery) or 0
	if seconds > 0 then
		EVENT_MANAGER:RegisterForUpdate(UPDATE_NAME, seconds * 1000, OnTimer)
	end
end

function addon:SetCollectEvery(seconds)
	self.sv.collectEvery = seconds
	self:ApplyCollectTimer()
	if self.RefreshWindow then
		self:RefreshWindow()
	end
end
