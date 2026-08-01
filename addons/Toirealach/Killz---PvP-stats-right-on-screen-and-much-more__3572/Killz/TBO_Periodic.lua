-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- TBO_Periodic: A simple API for ESO's EVENT_MANAGER periodic Update 
--
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Version 1.2.0 by Teebow Ganx
-- Copyright (c) 2021 Trailing Zee Productions, LLC.
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -

local tboPeriodic = ZO_CallbackObject:Subclass()
TBO_Periodic = tboPeriodic

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

function TBO_Periodic:New(inPeriodicFunc, inPeriodSecs)
    	
    local tboPeriodicObj = ZO_Object.New(self)
    tboPeriodicObj.periodicFunc = inPeriodicFunc -- can be specified now or when :Start() is called
    tboPeriodicObj.periodInSecs = inPeriodSecs or 60 -- default to once per minute if not specified
    tboPeriodicObj.isRegistered = false

    local bigRandom = math.random(11111111, 99999999)
    local bigRandomStr = string.format("%d",bigRandom)
    tboPeriodicObj.identifier = "TBOP"..bigRandomStr
    -- d(string.format("TBO_Periodic(%s) created.", tboPeriodicObj.identifier))
    return tboPeriodicObj
end

function TBO_Periodic:Start(inPeriodicFunc, inPeriodSecs)

    if self.isRegistered == true then TBO_Periodic:Stop() end	

    self.periodicFunc = inPeriodicFunc or self.periodicFunc
    assert(self.periodicFunc ~= nil, "TBO_Periodic:New(): The 'periodicFunc' of the TBO_Periodic cannot be nil!")

    self.periodInSecs = inPeriodSecs or self.periodInSecs
    assert(self.periodInSecs > 0, "TBO_Periodic:Start(): The 'inPeriodSecs' parameter must be a positive integer!")

    self.periodicFunc()

    local updateMillisecs = self.periodInSecs * 1000
	EVENT_MANAGER:RegisterForUpdate(self.identifier, updateMillisecs, self.periodicFunc)
	self.isRegistered = true
end

function TBO_Periodic:Stop()
	if self.isRegistered == false then return end
	EVENT_MANAGER:UnregisterForUpdate(self.identifier)
	self.isRegistered = false
end

-- Sample Code on how to use this class
-- Create a periodic object anywhere in your code.
local samplePeriodic = TBO_Periodic:New()

-- This is the function that gets called periodically.
-- It can be anywhere in your code.
local function TBO_PeriodicSampleFunc() 

    local theString = string.format("TBO_Periodic(%s): Called with a period of %d seconds.", 
                                    samplePeriodic.identifier, samplePeriodic.periodInSecs)
    d(theString)
end

-- Stop & Start the periodic whenever you want.
-- When you Start it, pass in the function that 
-- you want called periodically and the interval 
-- in seconds at which it should be called.

function Test_TBO_Periodic()

    samplePeriodic:Stop() -- In case it's already running

    samplePeriodic = TBO_Periodic:New() -- create a new one to get a new ID.  Old one will be destroyed?

    local rndPeriod = math.random(10, 60) -- For testing let's just do a random interval between 10 * 60 seconds

    samplePeriodic:Start(TBO_PeriodicSampleFunc, rndPeriod)

    -- If you had previously called Start(func, interval) on the object with a function and an interval,
    -- You can simply call Start() with no paramaters anytime after that because it saves those start
    -- parameters in the object.
    --
    -- samplePeriodic:Start(TBO_PeriodicSampleFunc, 60)
    --
    -- samplePeriodic:Stop()
    -- samplePeriodic:Start()
    -- 
    -- The interval defaults to 60 seconds, so you never have to specify it if you never intend to use
    -- an interval other than 60 seconds.
    --
    -- samplePeriodic:Start(TBO_PeriodicSampleFunc)
    --
    -- samplePeriodic:Stop()
    -- samplePeriodic:Start()
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- TBO_Reminder: An API for periodic on screen reminders 
--
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

local tboReminder = ZO_CallbackObject:Subclass()
TBO_Reminder = tboReminder

function TBO_Reminder:New(inPrefix, inPeriodicFunc, inReminderIntervalInSecs, inFirstReminderInMinutes, inPeriodSecs)

    local tboReminderObj = ZO_Object.New(self)
    tboReminderObj.periodic = TBO_Periodic:New(inPeriodicFunc, inPeriodSecs)

    tboReminderObj.prefix = inPrefix -- Usually the addon name

    -- Reminder interval cannot be less than the periodic interval
    inReminderIntervalInSecs = inReminderIntervalInSecs or tboReminderObj.periodic.periodInSecs 
    assert(inReminderIntervalInSecs >= tboReminderObj.periodic.periodInSecs, "TBO_Reminder:New(): inReminderIntervalInSecs cannot be less than inPeriodSecs!")

    tboReminderObj.reminderIntervalInSecs = inReminderIntervalInSecs
    
    inFirstReminderInMinutes = inFirstReminderInMinutes or 5 -- Default to reminding five minutes before condition expires
    assert(inFirstReminderInMinutes > 0, "TBO_Reminder:New(): The 'inFirstReminderInMinutes' parameter must be a positive integer!")
    tboReminderObj.firstReminderInMinutes = inFirstReminderInMinutes

    tboReminderObj.lastRemindSecs = 0 -- game time of last reminder, must be updated manually when periodic func reminds

    tboReminderObj.announceTime = 3500
    tboReminderObj.announceSound = SOUNDS.JUSTICE_NOW_KOS
    
    tboReminderObj.tributeTracker = TBO_TributeGameTracker:New() -- Track the state of the tribute card game
    
    return tboReminderObj
end

function TBO_Reminder:Start(inPeriodicFunc, inReminderIntervalInSecs, inFirstReminderInMinutes, inPeriodSecs)
 
    if inReminderIntervalInSecs ~= nil then
        assert(inReminderIntervalInSecs > 0, "TBO_Reminder:New(): The 'inReminderIntervalInSecs' parameter must be a positive integer!")
        self.reminderIntervalInSecs = inReminderIntervalInSecs
    end
    
    if inFirstReminderInMinutes ~= nil then
        assert(inFirstReminderInMinutes > 0, "TBO_Reminder:New(): The 'inFirstReminderInMinutes' parameter must be a positive integer!")
      self.firstReminderInMinutes = inFirstReminderInMinutes
    end

    self.periodic:Start(inPeriodicFunc, inPeriodSecs)
end

function TBO_Reminder:Stop()
    self.periodic:Stop()
end

function TBO_Reminder:ShouldRemind()

    if self.tributeTracker.GameIsActive() then -- Don't remind when playing Tribute
        -- d("Reminderz: tributeTracker.GameIsActive == true, ShouldRemind == false")
        return false
    end 

    local nowSecs = GetGameTimeMilliseconds()/1000
	-- If already reminded less than reminder's minimum reminder interval then don't do it again so soon
	if (nowSecs - self.lastRemindSecs) < self.reminderIntervalInSecs  then return false end 
    return true
end

function TBO_Reminder:Remind(messageTitle, messageSubheading)

    if messageTitle == nil then return end
    CSAnnounce.System(messageTitle, messageSubheading, self.announceTime, self.announceSound)

    local chatStr = messageTitle
    -- Concatenate title & subheading for chat box
    if messageSubheading then chatStr = chatStr.." "..messageSubheading end

    -- Add prefix which is usually the addon name for chat window posts
    if self.prefix then chatStr = self.prefix..": "..chatStr end

    d(chatStr)

    self.lastRemindSecs = GetGameTimeMilliseconds()/1000
end

function TBO_Reminder:IsRunning()
    return self.periodic.isRegistered
end

function TBO_Reminder:FirstReminder()
    return self.firstReminderInMinutes
end

function TBO_Reminder:FirstReminderInSeconds()
    return self.firstReminderInMinutes*60
end

function TBO_Reminder:ReminderInterval()
    return self.reminderIntervalInSecs
end 

function TBO_Reminder:SetAnnounceTime(inAnnounceTime)
    self.announceTime = inAnnounceTime or 3500
end 

function TBO_Reminder:SetAnnounceSound(inAnnounceSound)
    self.announceSound = inAnnounceSound or SOUNDS.JUSTICE_NOW_KOS
end 
