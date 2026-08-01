local Timer = {}
DQT.Timer = Timer

-- unique identifier for a quest timer
-- must keep existing enum values to not corrupt saved data
local TIMER_TYPE = {
	DUNGEON = 0,
	BATTLEGROUNDS = 1,
	MOUNT = 2
}

Timer.TIMER_TYPE = TIMER_TYPE

function Timer:init()
	self.questTimers = DQT.SV:getForChar(GetCurrentCharacterId()).questTimers
	
	self:resetDungeonTimer()
	self:resetBattlegroundsTimer()
	self:resetMountTraining()
	
	EVENT_MANAGER:RegisterForEvent(DQT.Main.name, EVENT_ACTIVITY_FINDER_ACTIVITY_COMPLETE, Timer.onActivityFinderActivityComplete)
	EVENT_MANAGER:RegisterForEvent(DQT.Main.name, EVENT_BATTLEGROUND_STATE_CHANGED, Timer.onBattlegroundStateChanged)
	EVENT_MANAGER:RegisterForEvent(DQT.Main.name, EVENT_RIDING_SKILL_IMPROVEMENT, Timer.onRidingSkillImprovement)
end

--[[
	@param timerType (TIMER_TYPE)
	@param cooldown (integer) : timer length, in seconds
--]]
function Timer:resetTimer(timerType, cooldown)
	self.questTimers[timerType] = DQT.Utils:getCurrentTime() + cooldown
end

function Timer:resetDungeonTimer()
	self:resetTimer(TIMER_TYPE.DUNGEON, GetLFGCooldownTimeRemainingSeconds(LFG_COOLDOWN_DUNGEON_REWARD_GRANTED))
end

function Timer:resetBattlegroundsTimer()
	self:resetTimer(TIMER_TYPE.BATTLEGROUNDS, GetLFGCooldownTimeRemainingSeconds(LFG_COOLDOWN_BATTLEGROUND_REWARD_GRANTED))
end

function Timer:resetMountTraining()
	if STABLE_MANAGER:IsRidingSkillMaxedOut() then
		self.questTimers[TIMER_TYPE.MOUNT] = "na"
	else
		Timer:resetTimer(TIMER_TYPE.MOUNT, GetTimeUntilCanBeTrained() / 1000)
	end
end

function Timer.onRidingSkillImprovement(eventCode, ridingSkillType, previous, current, source)
	if source == RIDING_TRAIN_SOURCE_STABLES then
		Timer:resetMountTraining()
	end
end

--[[
There seems to be a slight delay between when EVENT_ACTIVITY_FINDER_ACTIVITY_COMPLETE fires,
and when GetLFGCooldownTimeRemainingSeconds is actually updated. I have not found a reliable
way to determine if the activity complete was a random dungeon or not, so that we could update
the timer manually. Instead, we try again with a slight delay.

By the time EVENT_ACTIVITY_FINDER_ACTIVITY_COMPLETE fires, GetCurrentLFGActivityId() returns
only the id for this specific dungeon, instead of the id for a random dungeon. Storing the
activity id from when we queued is not reliable because that info could be lost in a disconnect.
--]]
function Timer.onActivityFinderActivityComplete(eventCode)
	if ZO_IsActivityTypeDungeon(GetActivityType(GetCurrentLFGActivityId())) then
		Timer:resetDungeonTimer()
		
		-- a 1 second delay works for me, but we throw in a few more (with exponential growth) to be safe
		local delays = {1, 4, 16}
		for _, delay in ipairs(delays) do
			zo_callLater(function() Timer:resetDungeonTimer() end, 1000 * delay)
		end
	end
end

function Timer.onBattlegroundStateChanged(eventCode, previousState, currentState)
	--[[
	We check for BATTLEGROUND_STATE_POSTGAME instead of
	BATTLEGROUND_STATE_FINISHED because this never seems to get called
	with BATTLEGROUND_STATE_FINISHED
	--]]
	if currentState == BATTLEGROUND_STATE_POSTGAME then
		-- GetLFGCooldownTimeRemainingSeconds is probably not updated yet, but we try anyway
		Timer:resetBattlegroundsTimer()
		
		-- try to reset timer again after they leave the battleground
		EVENT_MANAGER:RegisterForEvent(DQT.Main.Name, EVENT_PLAYER_ACTIVATED, Timer.onBattlegroundLeft)
	end
end

function Timer.onBattlegroundLeft(eventCode, initial)
	EVENT_MANAGER:UnregisterForEvent(DQT.Main.Name, EVENT_PLAYER_ACTIVATED)
	Timer:resetBattlegroundsTimer()
end

--[[
	@param timeRemaining time remaining in seconds (or nil if unknown, "na" if not applicable)
	@return formatted string for display in gui
--]]
function Timer.formatTimeRemaining(timeRemaining)
	if timeRemaining == nil then
		return "?"
	elseif timeRemaining == 0 then
		-- color text green if timer is up
		return "|c0099000:00|r"
	elseif timeRemaining == "na" then
		return "-"
	else
		local hoursRemaining = math.floor(timeRemaining / 3600)
		local minutesRemaining = math.floor((timeRemaining - hoursRemaining * 3600) / 60)
		return string.format("%d:%.2d", hoursRemaining, minutesRemaining)
	end
end

-------- Timer --------
-- boilerplate for class definition
local TimerQuest = ZO_Object.MultiSubclass(DQT.Quest.Quest)
Timer.TimerQuest = TimerQuest

function TimerQuest:new(...)
	local object = ZO_Object.New(self)
	object:initTimerQuest(...)
	return object
end

--[[
	This type of "quest" is on a timer based on the last time you completed it.
	
	@param name (string) display name for quest
	@param timerType unique TIMER_TYPE identifier
--]]
function TimerQuest:initTimerQuest(name, timerType)
	self:init(name)
	self._type = timerType
end

-- get time remaining, in seconds, or nil if unknown, or "na" if not applicable
function TimerQuest:getTimeRemaining(characterId)
	local resetTime = DQT.SV:getForChar(characterId).questTimers[self._type]
	
	if resetTime == nil then
		return nil
	elseif resetTime == "na" then
		return "na"
	end
	
	return math.max(os.difftime(resetTime, DQT.Utils:getCurrentTime()), 0)
end

-- equality operator overload
function TimerQuest.eq(left, right)
	return left._type == right._type
end

-------- Timer Section --------

-- boilerplate for class definition
local TimerSection = ZO_Object:Subclass()
Timer.TimerSection = TimerSection

function TimerSection:new(...)
	local object = ZO_Object.New(self)
	object:init(...)
	return object
end

--[[
	A timer quest section represents a category of timer quests to group together
	
	@param name (string) a unique section name
	@param quests (list) TimerQuest objects
--]]
function TimerSection:init(name, quests)
	self._name = name
	self._quests = quests
end

function TimerSection:getName()
	return self._name
end

function TimerSection:getQuests()
	return self._quests
end

-- equality operator overload
function TimerSection.eq(left, right)
	return left._name == right._name
end

-- class type
function TimerSection.type()
	return "TimerSection"
end