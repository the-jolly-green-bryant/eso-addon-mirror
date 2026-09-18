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

-- ---------------------------------------------------------------------------------------
-- Staying under the game's warning
--
-- The client warns when the add-on pool runs low -- "Low Add-On memory: 77 MB/100 MB", the
-- SI_LOW_ADDON_MEMORY_WARNING dialog with Disable add-ons / Reload UI -- and disables add-ons
-- outright if it is exhausted. Nothing in the client's Lua raises that dialog: it comes from
-- the engine, and an add-on cannot stop it being shown. What an add-on can do is keep the usage
-- down, since memory waiting to be collected counts towards the pool like anything else. So the
-- usage is watched, and collected before the warning's level is reached.
--
-- Only memory nothing uses any more can be given back. If the add-ons really are using that
-- much, the warning comes anyway -- so rather than stall the game over and over for nothing, a
-- collection that fails to get back under the level backs the next attempt off.
-- ---------------------------------------------------------------------------------------

local WATCH_NAME = addon.name .. "_Watch"
local WATCH_INTERVAL_MS = 10000
local RETRY_MS = 60000
local BACKOFF_MS = 300000
local nextWatchMs = 0

-- How much of the add-on memory limit is in use, as a percentage.
function addon:PoolPercent()
	local usage, capacity = self.ReadPoolMB(), self.ReadPoolCapacityMB()
	if not usage or not capacity then
		return nil
	end
	return usage / capacity * 100
end

function addon:PercentLabel(percent)
	percent = tonumber(percent) or 0
	if percent <= 0 then
		return GetString(SI_PBSLMM_AUTO_OFF)
	end
	return string.format(GetString(SI_PBSLMM_PERCENT), percent)
end

local function OnWatch()
	local limit = tonumber(addon.sv.collectAbove) or 0
	local percent = addon:PoolPercent()
	if limit <= 0 or not percent or percent < limit then
		return
	end
	local now = addon.NowMs()
	if now < nextWatchMs then
		return
	end
	if InCombat() and not addon.sv.collectInCombat then
		return
	end
	addon:CollectNow(false)
	local after = addon:PoolPercent()
	nextWatchMs = now + ((after and after >= limit) and BACKOFF_MS or RETRY_MS)
end

function addon:ApplyWatch()
	EVENT_MANAGER:UnregisterForUpdate(WATCH_NAME)
	if (tonumber(self.sv.collectAbove) or 0) > 0 then
		EVENT_MANAGER:RegisterForUpdate(WATCH_NAME, WATCH_INTERVAL_MS, OnWatch)
	end
end

function addon:SetCollectAbove(percent)
	self.sv.collectAbove = percent
	nextWatchMs = 0
	self:ApplyWatch()
	if self.RefreshWindow then
		self:RefreshWindow()
	end
end

-- The game also raises a notification of its own when the pool runs low. Clearing it is the
-- same call the client's own notification row makes when it is declined
-- (ZO_ConsoleAddonsMemoryLimitProvider:Decline in notifications_common.lua). It has nothing to
-- do with the engine's warning dialog, which stays.
local NOTICE_NAME = addon.name .. "_MemoryNotice"

local function OnMemoryLimitReached()
	if not addon.sv.clearWarning then
		return
	end
	addon:CollectNow(false)
	if type(ClearWarnConsoleAddOnMemoryLimit) == "function" then
		addon.lastWarningCleared = pcall(ClearWarnConsoleAddOnMemoryLimit)
	end
end

function addon:ApplyWarningHandler()
	EVENT_MANAGER:UnregisterForEvent(NOTICE_NAME, EVENT_CONSOLE_ADD_ONS_MEMORY_LIMIT_REACHED)
	if self.sv.clearWarning and EVENT_CONSOLE_ADD_ONS_MEMORY_LIMIT_REACHED then
		EVENT_MANAGER:RegisterForEvent(NOTICE_NAME, EVENT_CONSOLE_ADD_ONS_MEMORY_LIMIT_REACHED, OnMemoryLimitReached)
	end
end

function addon:SetClearWarning(value)
	self.sv.clearWarning = value
	self:ApplyWarningHandler()
end
