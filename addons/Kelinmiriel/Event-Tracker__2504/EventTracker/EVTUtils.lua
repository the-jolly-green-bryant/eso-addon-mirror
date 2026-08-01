-- EVTUtils.lua

-- EVT.AdvanceTime(HowFar)	for testing
-- EVT.FindCurrentTime()	Used instead of real current time, so testing can be done more easily
-- EVT.PrintDebug(string,override)	Prints string if debugging is on
-- EVT.DailyReset()		Returns daily reset time; does way too much now
-- EVT.ResetMsg()		Calls ShowVars("UI") (from poll setting)
-- EVT.ShowVars(call_from)	Also does way too much now


local TestRun = 0
-- 1.22 Separate this into two messages, one for between events, one for during
local UIMessageNone = ""
local UIMessageEvent = ""
local testmin = 0
local testhr = 0
local testday = 0

-- 1.67 auto xp buff
local XPbuffcooldown = GetTimeStamp()

-- 1.25 This function created for testing purposes so I can adjust the "current time"
--      to whatever I want it to be, instead of being forced to only do tests at
--      specific times of day to see if things will work correctly. Replace
--      Bindings.xml with special copy to call this.
function EVT.AdvanceTime(HowFar)
	if HowFar == "Day" then
		testday = testday + 1
		EVT.PrintDebug(string.format("|c00CCFFADDED ANOTHER DAY:|r %s %s",FormatAchievementLinkTimestamp(EVT.FindCurrentTime())))

	elseif HowFar == "Hour" then
		testhr = testhr + 1
		EVT.PrintDebug(string.format("|c00CCFFADDED ANOTHER HOUR:|r +%s days %s hr %s min.",testday,testhr,testmin))
		local PrevReset, Hrs, Mins, EvtDays, EvtHrs = EVT.DailyReset()

-- Get tickets if within 3 hours of reset
		if EVT.vars.T_ToDo[1] > 0 and Hrs < 3 then
			local NewTick = EVT.vars.T_Tickets[1]
			EVT.vars.Total_Tickets = EVT.vars.Total_Tickets - NewTick
			EVT.onCurrencyUpdate(EVENT_CURRENCY_UPDATE, CURT_EVENT_TICKETS, CURRENCY_LOCATION_ACCOUNT, EVT.vars.Total_Tickets+NewTick, EVT.vars.Total_Tickets, CURRENCY_CHANGE_REASON_LOOT)
			EVT.PrintDebug("|c32CD32TRADE BARS!")
		end
		EVT.SetUpPoll(PrevReset, Hrs, Mins, EvtDays, EvtHrs)

	elseif HowFar == "End" then
		testmin = 0
		local PrevReset, Hrs, Mins, EvtDays, EvtHrs = EVT.DailyReset()
		testmin = Mins - 2
		EVT.SetUpPoll(PrevReset, Hrs, Mins, EvtDays, EvtHrs)
		EVT.PrintDebug(string.format("|cFF6900END HOUR!|r +%s days %s hr %s min.",testday,testhr,testmin))
-- 1.83 Set to 5 minutes before event
	elseif HowFar == "Event" then
		local TimeLeft = GetTimeStamp()+EVT_EVENT_START -(60*5)  	-- Remove a lot of the stamp (Nov. 1, 2019 midnight GMT)
--CHAT_ROUTER:AddSystemMessage(string.format("TimeLeft %s",TimeLeft))
		testday = math.floor(TimeLeft/EVT_ONE_DAY)	-- Find days
		TimeLeft = TimeLeft%EVT_ONE_DAY		-- Remove all the days
		testhr = math.floor(TimeLeft/EVT_ONE_HOUR)	-- Find hours
		TimeLeft = TimeLeft%EVT_ONE_HOUR		-- Remove hours
		testmin = math.floor(TimeLeft/60)		-- Find minutes
		CHAT_ROUTER:AddSystemMessage(string.format("|c00CCFFCHANGED TIME:|r +%s days %s hr %s min.",testday,testhr,testmin))
		CHAT_ROUTER:AddSystemMessage(string.format("|c00CCFFCURRENT TEST TIME IS:|r %s %s",FormatAchievementLinkTimestamp(EVT.FindCurrentTime())))
	end
end


-- 1.25 This function created for testing purposes so I can adjust the "current time"
--      to whatever I want it to be, instead of being forced to only do tests at
--      specific times of day to see if things will work correctly. Replaces all
--      calls to GetTimeStamp.
function EVT.FindCurrentTime()
	return GetTimeStamp()+(testday*EVT_ONE_DAY)+(testhr*EVT_ONE_HOUR)+testmin*60
end


--- Prints out the given debug string if the user has set to have debug output shown
--  @param str  the string to print
-- (from TON)
-- 1.25 Disabled most debugging output; added time stamp and event name
function EVT.PrintDebug(str,Override)
	local date1, time1 = FormatAchievementLinkTimestamp(GetTimeStamp())
	local date2, time2 = FormatAchievementLinkTimestamp(EVT.FindCurrentTime())
	if EVT.vars.debug or Override ~= nil then
		if date1 == date2 and time1 == time2 then
			CHAT_ROUTER:AddSystemMessage(string.format("|c777777%s|r ",time1) .. EVT.vars.Current_Event .. " " .. str)
		else
			CHAT_ROUTER:AddSystemMessage(string.format("|c777777%s|r |cFFFFFF%s|r ",time1,time2) .. EVT.vars.Current_Event .. " " .. str)
		end
	end
end


-- Returns 5 parameters:
-- previous day's reset (to check if tickets are available again)
-- hour(s) and minutes until next reset
-- day(s) and hour(s) until end of this event, or start of next if between (minutes are same as until reset)
-- (modified from Dolgubon's Lazy Writ Crafter, "ResetWarning")
function EVT.DailyReset()
	local Now = EVT.FindCurrentTime()
	local date = {}
	local SecPerMin = 60
-- 1.33 Replaced by globals EVT_ONE_DAY and EVT_ONE_HOUR (Even though the other names are more appropriate here, not making more variables!)
--	local SecPerHour = 3600  -- SecPerMin * 60
--	local SecPerDay = 86400  -- SecPerHour * 24
	local till = {}          -- hours and minutes to return
	local TillEvent = {}     -- days and hours until end of event or start of next to return


-- 1.94 Deal with U37 reset change
	local whichserver = string.sub(GetWorldName(),1,2)
	local daily_reset_time = 3	-- GMT
	if whichserver == "PTS" then
		if ((GetTimeStamp()+GetTimeUntilNextDailyLoginRewardClaimS())%86400)/3600 < 5 then
			whichserver = "EU"
		else
			whichserver = "NA"
		end
	end
	if whichserver == "EU" then daily_reset_time = 3 else daily_reset_time = 10 end
-- 1.95	if GetAPIVersion == 101036 then daily_reset_time = 6 end

-- 1.94 End new code
--[[ Comments about the above formula, because I hate forgetting what I did or why:
Current time stamp + time until next daily reset, gives the time stamp of next daily reset
	For precision: Add 2 seconds : For some unknown reason, the previous is sometimes off by a couple seconds.
%86400 : (number of seconds in one day) Remove days
/3600 : (number of seconds in one hour) Convert to hours
	For precision: math.floor : Remove minutes and seconds
Decided I didn't need precision, because I'm using "<5".
Precise version returns 3 for EU; 10 for NA. This one is +/- .02 or so.
]]

	local TimeLeft = Now-1572566400                   -- Remove a lot of the stamp (Nov. 1, 2019 midnight GMT)
	TimeLeft = TimeLeft%EVT_ONE_DAY                   -- Remove all the days
	date["hour"] = math.floor(TimeLeft/EVT_ONE_HOUR)  -- Find current hour
	TimeLeft = TimeLeft%EVT_ONE_HOUR                  -- Remove hours
	date["minute"] = math.floor(TimeLeft/SecPerMin) -- Find current minutes
	TimeLeft = TimeLeft%SecPerMin                   -- Remaining seconds

-- 1.94 Changed constant 6 below (which was the old daily reset hour, in GMT) to the new "daily_reset_time" var
-- and constant "5" to "daily_reset_time-1" (-1 included at end)
	PreviousReset = Now + (daily_reset_time-date["hour"])*EVT_ONE_HOUR - (date["minute"]*SecPerMin) - TimeLeft
	if date["hour"]>(daily_reset_time-1) then 
		till["hour"] = daily_reset_time-date["hour"]+23
	else
		till["hour"] = daily_reset_time-date["hour"]-1
		PreviousReset = PreviousReset - EVT_ONE_DAY 
	end
	till["minute"] = 60-date["minute"]

-- 1.30 Noticed this hadn't been initialized, so done to hopefully avoid errors.
	EventDate = EVT_EVENT_END
-- 1.17 New. If event is Unknown, don't know end, shouldn't show.
	if EVT.vars.Current_Event == "Unknown" then
		EventDate = EVT_EVENT_END
-- If event is known and running (currently between start and end), use end date, and start it running if it's not.
-- 1.66 Allow unknown end date
	elseif Now >= EVT_EVENT_START and (Now < EVT_EVENT_END or EVT_EVENT_END == EVT_DATE_UNKNOWN) then

--[[*****************************************************
*****
*****   MUST BE CERTAIN THAT CURRENT EVENT is NOT!! "None" when called
*****   from StartNewEvent or Recursion could result!!!
*****
*********************************************************]]

		if EVT.vars.Current_Event == "None" then
			EVT.StartNewEvent()
		end
		EventDate = EVT_EVENT_END
-- If it's known but not running (not between start and end), use start date, and set it to "None".
	else
		EventDate = EVT_EVENT_START
		EVT.vars.Current_Event = "None"
-- 1.22 5 lines
--		TriggerEventEnd = true
-- 1.24 Only do this if more than 5 days before start of next event
		if (EventDate-Now)/EVT_ONE_DAY > 5 then
			EVT_HIDE_UI = true
			EVT.HideUI("Hide")
			if EVT_POLLING_ACTIVE ~= "None" then
				EVENT_MANAGER:UnregisterForUpdate(EVT.name)
				EVT_POLLING_ACTIVE = "None"
			end
		end
	end
-- Verify that date can never be before right now! And shouldn't ever show, hopefully.
	if EventDate < Now then
--		EVT.PrintDebug("|cFF0000Event start/end date before now!!|r " .. string.format("|c00CCFF%s %s|r",FormatAchievementLinkTimestamp(EVT_EVENT_END)))
		EventDate = Now + EVT_ONE_DAY*60
	end

	TillEvent["day"] = math.floor((EventDate-Now)/EVT_ONE_DAY)
	TimeLeft = EventDate-1572566400                      -- Remove a lot of the stamp
	TimeLeft = TimeLeft%EVT_ONE_DAY                        -- Remove all the days
	TillEvent["hour"] = math.floor(TimeLeft/EVT_ONE_HOUR)  -- Find hour that current event ends or next one starts (15 or 16)
--	EVT.PrintDebug(string.format("|c00CCFF%s %s",FormatAchievementLinkTimestamp(EVT.FindCurrentTime())))
--	EVT.PrintDebug(string.format("Event date: %s Current time: %s Difference: %s Dif/sec: %s",EventDate,Now,EventDate-Now,(EventDate-Now)/EVT_ONE_DAY))

-- 1.10 Changed to >= instead of > because it was showing "-1" hours remaining instead of 23
	if date["hour"] >= TillEvent["hour"] then
--		TillEvent["day"] = TillEvent["day"] - 1
		TillEvent["hour"] = TillEvent["hour"] - date["hour"] + 24
	else
		TillEvent["hour"] = TillEvent["hour"] - date["hour"]
	end

	if till["minute"] > 0 then
		TillEvent["hour"] = TillEvent["hour"] - 1
-- 1.11 Should check that hour not < 0
		if TillEvent["hour"] < 0 then
			TillEvent["day"] = TillEvent["day"] - 1
			TillEvent["hour"] = TillEvent["hour"] + 24
		end
	end

-- 1.11 Minutes = 60 looks funny. If it throws hours till event to 24, fix it.
--      If it throws hours till reset to 24, no "days" to compensate, so leave it be.
	if till["minute"] > 59 then
		TillEvent["hour"] = TillEvent["hour"] + 1
		till["hour"] = till["hour"] + 1
		till["minute"] = till["minute"] - 60
	end

	if TillEvent["hour"] > 23 then
		TillEvent["day"] = TillEvent["day"] + 1
		TillEvent["hour"] = TillEvent["hour"] - 24
	end

-- 1.25 Last day of event (after reset) set fake "reset" at end of event
--      to indicate end of when tickets can be gotten.
	if EventDate == EVT_EVENT_END and TillEvent["day"] < 1 and till["hour"] > TillEvent["hour"] then
		till["hour"] = TillEvent["hour"]
	end

	EVT.PrintDebug(string.format("Till start/end: %s days, %s hours. +%s hr %s min.",TillEvent["day"], TillEvent["hour"],testhr,testmin))

	if EVT_POLLING_ACTIVE == "None" then
		EVT.SetUpPoll(PreviousReset, till["hour"], till["minute"], TillEvent["day"], TillEvent["hour"])
	end

-- 1.66 BEWARE: Cover the case of unknown end date when needed, because returns from this function could be strange.
	return PreviousReset, till["hour"], till["minute"], TillEvent["day"], TillEvent["hour"]
end


-- 1.13 New
function EVT.ResetMsg()
--	EVT.PrintDebug("Timer hit")
	EVENT_MANAGER:UnregisterForUpdate(EVT.name)
-- 1.30 Set flag
	EVT_POLLING_ACTIVE = "None"
	EVT.ShowVars("UI")
end


-- 1.52 New function
-- 1.57 Changed parameters to add tomorrow; removed "math.abs"; use math.max
function EVT.MaxAvailable()
-- 1.60 Added error checking, sort of.
	if EVT_EVENT_END < EVT.FindCurrentTime() then
-- or EVT_EVENT_END == EVT_DATE_UNKNOWN then
		return 0, 0
	end

	local Today1 = 0
	local Today2 = 0
	local Today3 = 0
	if EVT_DLC_UNLOCKED[1] then Today1 = EVT.vars.T_ToDo[1]*EVT.vars.T_Tickets[1] end
	if EVT_DLC_UNLOCKED[2] then Today2 = EVT.vars.T_ToDo[2]*EVT.vars.T_Tickets[2] end
	if EVT_DLC_UNLOCKED[3] then Today3 = EVT.vars.T_ToDo[3]*EVT.vars.T_Tickets[3] end

	local MaxToday = math.max(Today1,Today2,Today3)

-- 1.60 Does tomorrow really exist? (Or will the event still be going on, more importantly.)
	local MaxTomorrow = 0
-- 1.76 MUST BE FIXED BEFORE NEXT EVENT!!
	do return MaxToday, MaxTomorrow end
--[[	if EVT_EVENT_END <= EVT.FindCurrentTime() + EVT_ONE_HOUR*9 then -- Ends of events are always 8 or 9 hours after reset, so if it's more than that, it's easy.
		local PrevReset, Hrs, Mins, EvtDays, EvtHrs = EVT.DailyReset()
-- 1.65 This has been wrong just before reset on last day. Fix it.
--		if PrevReset < EVT.FindCurrentTime() - EVT_ONE_HOUR*10 then -- If last reset was less than 10 hours ago, it's the last day. So no tomorrow.
		if EvtDays == 0 then
			return 0, 0
		end
	end
]]
	local Tomorrow1 = 0
	local Tomorrow2 = 0
	local Tomorrow3 = 0
	if EVT_DLC_UNLOCKED[1] then Tomorrow1 = EVT.vars.T_Tickets[1] end
	if EVT_DLC_UNLOCKED[2] then Tomorrow2 = EVT.vars.T_Tickets[2] end
	if EVT_DLC_UNLOCKED[3] then Tomorrow3 = EVT.vars.T_Tickets[3] end

	MaxTomorrow = math.max(Tomorrow1,Tomorrow2,Tomorrow3)

	EVT.PrintDebug(string.format("Max Today: %s; Max Tomorrow: %s",MaxToday,MaxTomorrow))
	return MaxToday, MaxTomorrow
end


-- 2.040 Gates of Oblivion: Special code added for two zones to get tickets from
-- Default test for 8659 Blackwood
-- If that's locked and event is "Oblivion", then check if tickets can be gotten from 9365 The Deadlands
-- 1.60 Moved this out as a separate function
-- collectibleNumber and collectibleName actually matter. collectibleType is only for my use, as far as I can tell.
function EVT.IsItUnlocked(collectibleType,collectibleNumber,collectibleName)
	if EVT.vars.Current_Event == "Oblivion" then
		collectibleType = "DLC"
		collectibleNumber = 8659
		collectibleName = "Blackwood"
	end

	local verifyName, _, _, _, Unlocked = GetCollectibleInfo(collectibleNumber) -- Will return true or false. If the user unlocked DLC through ESO+ without buying DLC it will return true.
	if collectibleName == verifyName then
		EVT.PrintDebug(string.format("Collectible #: %s %s %s. Unlocked: %s",collectibleNumber,collectibleName,collectibleType,tostring(Unlocked)))
	else
		EVT.PrintDebug(string.format("|cFF0000ERROR!!!|c IsItUnlocked function was called with incorrect collectible # for %s",collectibleName))
		EVT.PrintDebug(string.format("Collectible #: %s %s %s. Unlocked: %s",collectibleNumber,verifyName,collectibleType,tostring(Unlocked)))
	end

	if EVT.vars.Current_Event == "Oblivion" then
		if Unlocked then 
			EVT.PrintDebug("|c00CCFFGATES of OBLIVION event: BLACKWOOD UNLOCKED - no further testing.")
		else
			verifyName, _, _, _, Unlocked = GetCollectibleInfo(9365)
			if "The Deadlands" == verifyName then
				EVT.PrintDebug(string.format("|c00CCFFGATES of OBLIVION event: |cFF0000BLACKWOODS LOCKED. |cFFFFFFDEADLANDS: %s",tostring(Unlocked)))
			else
				EVT.PrintDebug("|cFF0000ERROR!!!|c IsItUnlocked function was called with incorrect collectible # for The Deadlands!")
			end
		end
	end

	return Unlocked
end


--- Displays tickets currently held and time of last ticket in chat when /evt
--  is typed in chat; also updates daily reset time and ticket availability
-- call_from options: "Signon", "/evt".
-- Currency event: "Loot" (got tickets), "Spent", "Init" (ticket info triggered without getting more or spending)
-- 1.13 "Crowns" (purchased tickets). (Only "/evt", "Signon", "Loot" are used as special cases so far.)
--      "Daily message" wasn't updating UI, so I just made it do a full "/evt".
-- 1.28 Added "UI": Can call for this from anywhere, to update UI with no chat output.
function EVT.ShowVars(call_from)

-- Update reset and ticket availability whenever messages are output so info is correct.
	local PrevReset, Hrs, Mins, EvtDays, EvtHrs = EVT.DailyReset()
	local date, time = FormatAchievementLinkTimestamp(PrevReset)
	local Ticket_str = tostring(EVT.vars.Total_Tickets)
	local MaxToday, MaxTomorrow = EVT.MaxAvailable()

--[[	EVT.PrintDebug("Poll: " .. EVT_POLLING_ACTIVE .. " Current Event: " .. EVT.vars.Current_Event)
	EVT.PrintDebug("Previous Reset: " .. string.format("|c00CCFF%s %s|r",date,time))
	EVT.PrintDebug("Trade Bar reset: " .. string.format("%s hours, %s minutes. Event end %s days, %s hours.",Hrs,Mins,EvtDays,EvtHrs))
	EVT.PrintDebug(string.format("Event End time/date code: %s",EVT_EVENT_END))
	EVT.PrintDebug("Event End: " .. string.format("|c00CCFF%s %s|r",FormatAchievementLinkTimestamp(EVT_EVENT_END)))
]]

--	CHAT_ROUTER:AddSystemMessage(string.format("%s %s %s |c00CCFFEvent End|r",EVT_EVENT_END,FormatAchievementLinkTimestamp(EVT_EVENT_END)))
--	CHAT_ROUTER:AddSystemMessage(string.format("%s %s %s |c00CCFFCurrent Time|r",EVT.FindCurrentTime(),FormatAchievementLinkTimestamp(EVT.FindCurrentTime())))
--	CHAT_ROUTER:AddSystemMessage(string.format("%s %s %s |c00CCFFTrade Bars Acquired|r",EVT.vars.T_Time[1],FormatAchievementLinkTimestamp(EVT.vars.T_Time[1])))
--	CHAT_ROUTER:AddSystemMessage(string.format("%s %s %s |c00CCFFPrevious Reset|r",PrevReset,FormatAchievementLinkTimestamp(PrevReset)))

	if (EVT.FindCurrentTime() < EVT_EVENT_END and EVT.vars.Current_Event ~= "None") then
		local IsReset = false
		if EVT.vars.T_Tickets[1] > 0 and EVT.vars.T_Time[1] < PrevReset then
			IsReset = true
			EVT.vars.T_ToDo[1] = 1
			EVT.PrintDebug("|cFFD700RESET: " .. EVT.vars.T_Types[1] .. " TRADE BAR(S) NOW AVAILABLE!|r")
		end
		if EVT.vars.T_Tickets[2] > 0 and EVT.vars.T_Time[2] < PrevReset then
			IsReset = true
			EVT.vars.T_ToDo[2] = 1
			EVT.PrintDebug("|cFFD700RESET: " .. EVT.vars.T_Types[2] .. " TRADE BAR(S) NOW AVAILABLE!|r")
		end
		if EVT.vars.T_Tickets[3] > 0 and EVT.vars.T_Time[3] < PrevReset then
			IsReset = true
			EVT.vars.T_ToDo[3] = 1
			EVT.PrintDebug("|cFFD700RESET: " .. EVT.vars.T_Types[3] .. " TRADE BAR(S) NOW AVAILABLE!|r")
		end

-- 1.57 Add notification at reset if new tickets will exceed cap.
-- 1.60 Messages changed.
-- 1.61 Removed Prev_Max_Total
		if IsReset then
			EVT.PrintDebug("|cFFD700RESET|r")

-- 1.65 Reset skulls for Witches
			if EVT.vars.Current_Event == "Witches" then EVT.vars.Skulls_Done = EVT_SKULLS_DONE end

-- 2.400			MaxToday, MaxTomorrow = EVT.MaxAvailable()
			if EVT.vars.Current_Event ~= "Unknown" and EVT.vars.Current_Event ~= "None" then
-- 2.400				EVT.Notification("|cFF0000** WARNING","|rSpend Event Tickets or you could lose some! |cFF0000**|r",SOUNDS.LEVEL_UP)
-- 2.400				EVT.Notification("|cFF0000** WARNING",string.format("|cFFD700You have %s tickets! |cFF0000**|r",EVT.vars.Total_Tickets),SOUNDS.CHAMPION_POINTS_COMMITTED)
-- 1.67 Quest tickets might have become available, so check for that.
-- 2.400 Don't know why this was limited to only when tickets were in danger of going over cap, but removed that.
				EVT.QuestTickets()
-- EVENTUPDATE

			end

		end
	end

-- 2.400 Removed warnings

-- 1.11 Added "Possible" variables for clarity and to reduce absurd line lengths in "if" statements
-- 1.54 New DLC LOCK; added All_Locked flag
	local Available1 = 0
	local Available2 = 0
	local Available3 = 0
	if EVT_DLC_UNLOCKED[1] then Available1 = EVT.vars.T_ToDo[1]*EVT.vars.T_Tickets[1] end
	if EVT_DLC_UNLOCKED[2] then Available2 = EVT.vars.T_ToDo[2]*EVT.vars.T_Tickets[2] end
	if EVT_DLC_UNLOCKED[3] then Available3 = EVT.vars.T_ToDo[3]*EVT.vars.T_Tickets[3] end
	local Possible1 = EVT.vars.T_ToDo[1] < 0 and EVT.vars.T_Tickets[1] > 0 and EVT_DLC_UNLOCKED[1]
	local Possible2 = EVT.vars.T_ToDo[2] < 0 and EVT.vars.T_Tickets[2] > 0 and EVT_DLC_UNLOCKED[2]
	local Possible3 = EVT.vars.T_ToDo[3] < 0 and EVT.vars.T_Tickets[3] > 0 and EVT_DLC_UNLOCKED[3]
	local All_Locked = not ((EVT_DLC_UNLOCKED[1] and EVT.vars.T_Tickets[1]>0) or (EVT_DLC_UNLOCKED[2] and EVT.vars.T_Tickets[2]>0) or (EVT_DLC_UNLOCKED[3] and EVT.vars.T_Tickets[3]>0))
	
--	local MysteryTicket = EVT.vars.T_Tickets["Unknown"]

---------------------------------------
-- PART 1 - How many tickets are there
---------------------------------------

-- 1.60 Added conditions for EVT_PLAN_AHEAD (only true during an event when the next one is paywall-locked, and it's still possible to get everything prepared ahead) and EVT_FRAGMENTS_DONE (defaults false)
-- 1.54 Added a check of "Max_Tick_Avail > 0" for players whose only remaining tickets for the day are locked to never get warnings.

--[[ 2.400 ****************** REMOVED CAP WARNINGS and "You have enough to buy something" comments

-- If more tickets are gotten before some are spent, they will be lost, so issue warning!
	if EVT.vars.Total_Tickets + MaxToday > 12 and MaxToday > 0 and EVT.vars.Current_Event ~= "None" and (not EVT_PLAN_AHEAD or not EVT_FRAGMENTS_DONE) then
		if call_from ~= "UI" then
			CHAT_ROUTER:AddSystemMessage(string.format("|cFF0000%s|r You have %s event %s!",EVT.lang["WARNING"],Ticket_str,EVT.lang["tickets"]))
		end
		UIMessageNone = string.format("|cFF0000%s |r|cFFFFFF%s %s|r",EVT.lang["WARNING"],Ticket_str,EVT.lang["Tickets"])
		if not EVT.vars.autoHide and call_from ~= "UI" then
			CHAT_ROUTER:AddSystemMessage("Go to the Impresario and buy something, or you may lose some!")
		end

-- 1.54 Added a check of "MaxTomorrow > 0" for players whose only remaining tickets for the day are locked to never get warnings.
-- 1.57 Changed statement below to use new MaxTomorrow instead:
--	elseif (EVT.vars.Total_Tickets + EVT.vars.T_Tickets[1] > 12 or EVT.vars.Total_Tickets + EVT.vars.T_Tickets[2] > 12 or EVT.vars.Total_Tickets + EVT.vars.T_Tickets[3] > 12) and Max_Tick_Avail > 0 and EVT.vars.Current_Event ~= "None" and EVT_EVENT_END-PrevReset > 18*60*60 then
	elseif EVT.vars.Total_Tickets + MaxTomorrow > 12 and MaxTomorrow > 0 and EVT.vars.Current_Event ~= "None" and EVT_EVENT_END-PrevReset > 18*60*60 and (not EVT_PLAN_AHEAD or not EVT_FRAGMENTS_DONE) then
		if call_from ~= "UI" then
-- 2.400			CHAT_ROUTER:AddSystemMessage(string.format("|cFF6900%s|r You have %s event %s!",EVT.lang["WARNING"],Ticket_str,EVT.lang["tickets"]))
		end
-- 2.400		UIMessageNone = string.format("|cFF6900%s |r|cFFFFFF%s %s!|r",EVT.lang["WARNING"],Ticket_str,EVT.lang["tickets"])
		if not EVT.vars.autoHide and call_from ~= "UI" then
-- 2.400			CHAT_ROUTER:AddSystemMessage("Go to the Impresario and buy something, or you may lose some after reset!")
		end

-- Enough to buy feather/berry, but not so many that it will go over cap if more are gotten.
-- Let player know purchase could be done, but not a warning that it must be.
-- (If tickets per day is 2 and ticket number is odd, or tickets per day is more than 2, this shouldn't ever hit.)
-- 1.46 Feathers and berries ended after 2020. Unstable Morpholith parts cost 5 tickets each, and the whole thing is too complicated to bother with.
	elseif EVT.vars.Total_Tickets > 9 and EVT.vars.Current_Event ~= "None" and (not EVT_PLAN_AHEAD or not EVT_FRAGMENTS_DONE) then
		if call_from ~= "UI" then
-- 1.46			CHAT_ROUTER:AddSystemMessage(string.format("|c32CD32[EVT]: FEATHER/BERRY AVAILABLE:|r You have %s event tickets.",Ticket_str))
			CHAT_ROUTER:AddSystemMessage(string.format("|c32CD32[EVT]: You have %s %s.|r",Ticket_str,EVT.lang["tickets"]))
		end
-- 1.13 User interface
		UIMessageNone = string.format("|c32CD32Trade Bars: %s|r",Ticket_str)
		if not EVT.vars.autoHide and call_from ~= "UI" then
			CHAT_ROUTER:AddSystemMessage("You can go to the Impresario and buy something.")
		end

************************************************ END REMOVED BLOCK
]]

-- Not enough tickets to buy feather/berry, and not enough to exceed cap.
-- 1.03 Was just "else"; but only show if there's an event, or user called for info.
	if EVT.vars.Current_Event ~= "None" or call_from == "/evt" then
-- 1.13 User interface
		UIMessageNone = string.format("|cFFFFFF%s: %s|r",EVT.lang["Tickets"],Ticket_str)
		if (not EVT.vars.autoHide) or call_from == "/evt" or call_from == "Loot" then
			CHAT_ROUTER:AddSystemMessage(string.format("You have %s %s.",Ticket_str,EVT.lang["tickets"]))
		end
-- 1.13 User interface - now there is an "else" because this should change even if excess chat messages are hidden
--      Ticket amount could change when not during an event if someone accepts a gift after event ends.
	else
		UIMessageNone = string.format("|cFFFFFF%s %s|r",EVT.lang["Tickets"],Ticket_str)
	end


---------------------------------------
-- PART 2 - How many still available today
---------------------------------------

-- No ticket info output if autohide is on (1.03 or there's no event,) unless user has called for info
-- 1.05 Switched to: No ticket info output if hide unless user has called for info, or if there's no event
-- 1.28 This part is chat only; UI processing is separate. So this first IF will skip all chat output for call_from="UI"
	if (EVT.vars.autoHide and call_from ~= "/evt") or EVT.vars.Current_Event == "None"  then

-- 1.07 Moved unknown options here (was just above "have gotten all" "else" final option)
	elseif EVT.vars.T_ToDo[1] < 0 and EVT.vars.T_ToDo[2] < 0 and EVT.vars.T_ToDo[3] < 0 then
--		CHAT_ROUTER:AddSystemMessage("Too soon after installation to know if tickets are available.")

-- 1.11 Was just MysteryTicket; changed so "all tickets gotten" message would show
	elseif (Available1 > 0 or Available2 > 0 or Available3 > 0 or Possible1 or Possible2 or Possible3) then
-- 1.08 This code kept because it could be useful if there's an event with two single tickets gotten from the same source, like they said New Life was going to be. Nicer output.
-- 1.08		if EVT.vars.Current_Event == "New Life" then
-- 1.08			if EVT.vars.T_ToDo[1] < 0 and EVT.vars.T_ToDo[2] < 0 then
-- 1.08				CHAT_ROUTER:AddSystemMessage("One or two possible tickets available from New Life quests")
-- 1.08			elseif EVT.vars.T_ToDo[1] < 0 or EVT.vars.T_ToDo[2] < 0 then
-- 1.08				if Available1 + Available2 > 0 then
-- 1.08					CHAT_ROUTER:AddSystemMessage("|c32CD32[EVT]: ONE TICKET AVAILABLE from a NEW LIFE QUEST;|r possibly a second also!")
-- 1.08				else
-- 1.08					CHAT_ROUTER:AddSystemMessage("One ticket from New Life may still be available today; you have gotten the other.")
-- 1.08				end
-- 1.08			elseif EVT.vars.T_ToDo[1] == 0 and EVT.vars.T_ToDo[2] == 1 then
-- 1.08				CHAT_ROUTER:AddSystemMessage("|c32CD32[EVT]: ONE TICKET AVAILABLE from a NEW LIFE QUEST;|r you have gotten the other.")
-- 1.08			elseif EVT.vars.T_ToDo[1] == 1 and EVT.vars.T_ToDo[2] == 1 then
-- 1.08				CHAT_ROUTER:AddSystemMessage("|c32CD32[EVT]: TWO TICKETS AVAILABLE from NEW LIFE QUESTS!|r (One ticket per quest)")
-- 1.08			end
-- 1.08		else
-- 1.08 ...but indents moved back out since it's not being used and might never be again.

-- 1.11 Many changes here to combine multiple "ticket available" lines
		if Available1 > 0 and Available2 > 0 and Available3 > 0 then
			CHAT_ROUTER:AddSystemMessage("|c32CD32[EVT]: ALL TRADE BARS AVAILABLE!|r")
		elseif Available1 > 0 and Available2 > 0 then
			CHAT_ROUTER:AddSystemMessage(string.format("|c32CD32[EVT]: %s %s AND %s %s TRADE BARS AVAILABLE!|r",Available1,EVT.vars.T_Types[1],Available2,EVT.vars.T_Types[2]))
		elseif Available1 > 0 and Available3 > 0 then
			CHAT_ROUTER:AddSystemMessage(string.format("|c32CD32[EVT]: %s %s AND %s %s TRADE BARS AVAILABLE!|r",Available1,EVT.vars.T_Types[1],Available3,EVT.vars.T_Types[3]))
		elseif Available2 > 0 and Available3 > 0 then
			CHAT_ROUTER:AddSystemMessage(string.format("|c32CD32[EVT]: %s %s AND %s %s TRADE BARS AVAILABLE!|r",Available2,EVT.vars.T_Types[2],Available3,EVT.vars.T_Types[3]))

		else
			if Available1 == 1 then
				CHAT_ROUTER:AddSystemMessage(string.format("|c32CD32[EVT]: %s %s TRADE BAR AVAILABLE!|r",Available1,EVT.vars.T_Types[1]))
			elseif Available1 > 0 then
				CHAT_ROUTER:AddSystemMessage(string.format("|c32CD32[EVT]: %s %s TRADE BARS AVAILABLE!|r",Available1,EVT.vars.T_Types[1]))
			end

			if Available2 == 1 then
				CHAT_ROUTER:AddSystemMessage(string.format("|c32CD32[EVT]: %s %s TRADE BAR AVAILABLE!|r",Available2,EVT.vars.T_Types[2]))
			elseif Available2 > 0 then
				CHAT_ROUTER:AddSystemMessage(string.format("|c32CD32[EVT]: %s %s TRADE BARS AVAILABLE!|r",Available2,EVT.vars.T_Types[2]))
			end

			if Available3 == 1 then
				CHAT_ROUTER:AddSystemMessage(string.format("|c32CD32[EVT]: %s %s TRADE BAR AVAILABLE!|r",Available3,EVT.vars.T_Types[3]))
			elseif Available3 > 0 then
				CHAT_ROUTER:AddSystemMessage(string.format("|c32CD32[EVT]: %s %s TRADE BARS AVAILABLE!|r",Available3,EVT.vars.T_Types[3]))
			end

		end

		if Possible1 then
			CHAT_ROUTER:AddSystemMessage(string.format("Possible %s trade bars available: %s",EVT.vars.T_Types[1],EVT.vars.T_Tickets[1]))
		end
		if Possible2 then
			CHAT_ROUTER:AddSystemMessage(string.format("Possible %s trade bars available: %s",EVT.vars.T_Types[2],EVT.vars.T_Tickets[2]))
		end
		if Possible3 then
			CHAT_ROUTER:AddSystemMessage(string.format("Possible %s trade bars available: %s",EVT.vars.T_Types[3],EVT.vars.T_Tickets[3]))
		end

-- 1.11 Copied this up because it wasn't showing
		if Hrs < 1 then
			CHAT_ROUTER:AddSystemMessage(string.format("|cFF6900You have %s minutes remaining to get them!|r",Mins))
		elseif Hrs < 2 then
			CHAT_ROUTER:AddSystemMessage(string.format("|cFF6900You have %s hour, %s minutes remaining to get them!|r",Hrs,Mins))
		elseif Hrs < 5 then
			CHAT_ROUTER:AddSystemMessage(string.format("|cFF6900You have %s hours, %s minutes remaining to get them!|r",Hrs,Mins))
		end

-- 1.08		end

-- 1.34 MysteryTicket removed
	elseif Available1 + Available2 + Available3 > 1 then
--		if MysteryTicket > 1 then
--			CHAT_ROUTER:AddSystemMessage(string.format("|c32CD32[EVT]: %s TICKETS AVAILABLE!|r",MysteryTicket))
		if Available1 > 0 then
			CHAT_ROUTER:AddSystemMessage(string.format("|c32CD32[EVT]: %s %s TRADE BARS AVAILABLE!|r",Available1,EVT.vars.T_Types[1]))
		elseif Available2 > 0 then
			CHAT_ROUTER:AddSystemMessage(string.format("|c32CD32[EVT]: %s %s TRADE BARS AVAILABLE!|r",Available2,EVT.vars.T_Types[2]))
		elseif Available3 > 0 then
			CHAT_ROUTER:AddSystemMessage(string.format("|c32CD32[EVT]: %s %s TRADE BARS AVAILABLE!|r",Available3,EVT.vars.T_Types[3]))
		else
			CHAT_ROUTER:AddSystemMessage(string.format("|c32CD32[EVT]: %s %s AND %s %s TRADE BARS AVAILABLE!|r",Available1,EVT.vars.T_Types[1],Available2,EVT.vars.T_Types[2]))
		end
		if Hrs < 1 then
			CHAT_ROUTER:AddSystemMessage(string.format("|cFF6900You have %s minutes remaining to get them!|r",Mins))
		elseif Hrs < 2 then
			CHAT_ROUTER:AddSystemMessage(string.format("|cFF6900You have %s hour, %s minutes remaining to get them!|r",Hrs,Mins))
		elseif Hrs < 5 then
			CHAT_ROUTER:AddSystemMessage(string.format("|cFF6900You have %s hours, %s minutes remaining to get them!|r",Hrs,Mins))
		end
	elseif Available1 + Available2 + Available3 == 1 then
--		if MysteryTicket == 1 then
--			CHAT_ROUTER:AddSystemMessage("|c32CD32[EVT]: ONE TRADE BAR AVAILABLE!|r")
		if Available1 == 1 then
			CHAT_ROUTER:AddSystemMessage(string.format("|c32CD32[EVT]: %s TRADE BAR AVAILABLE!|r",EVT.vars.T_Types[1]))
		elseif Available2 == 1 then
			CHAT_ROUTER:AddSystemMessage(string.format("|c32CD32[EVT]: %s TRADE BAR AVAILABLE!|r",EVT.vars.T_Types[2]))
		elseif Available3 == 1 then
			CHAT_ROUTER:AddSystemMessage(string.format("|c32CD32[EVT]: %s TRADE BAR AVAILABLE!|r",EVT.vars.T_Types[3]))
		end
		if Hrs < 1 then
			CHAT_ROUTER:AddSystemMessage(string.format("|cFF6900You have %s minutes remaining to get it!|r",Mins))
		elseif Hrs < 2 then
			CHAT_ROUTER:AddSystemMessage(string.format("|cFF6900You have %s hour, %s minutes remaining to get it!|r",Hrs,Mins))
		elseif Hrs < 5 then
			CHAT_ROUTER:AddSystemMessage(string.format("|cFF6900You have %s hours, %s minutes remaining to get it!|r",Hrs,Mins))
		end
--	elseif All_Locked then
--		CHAT_ROUTER:AddSystemMessage("You have no tickets available for this event. Sorry!")
-- 1.56 Lines above for 1.55 removed; changed below instead from just "else".
	elseif not All_Locked then
		CHAT_ROUTER:AddSystemMessage("You have already gotten all the trade bars available today.")
		if (EVT_EVENT_END-PrevReset) < (18*60*60) then
			CHAT_ROUTER:AddSystemMessage("|cFFD700You have finished this event!|r")
-- 1.16			return
		elseif Hrs < 1 then
			CHAT_ROUTER:AddSystemMessage("Trade bars will be available again in " .. string.format("%s minutes.",Mins))
		elseif Hrs < 2 then
			CHAT_ROUTER:AddSystemMessage("Trade bars will be available again in " .. string.format("%s hour, %s minutes.",Hrs,Mins))
		else
			CHAT_ROUTER:AddSystemMessage("Trade bars will be available again in " .. string.format("%s hours, %s minutes.",Hrs,Mins))
		end
	end

-- 1.19 UIMessage was defined here
-- 1.14 Add "tickets available" to UI
	if EVT.vars.Current_Event ~= "None" then
		UIMessageEvent = UIMessageNone .. "\n"
	end

	if Available1 + Available2 + Available3 > 0 and EVT.vars.Current_Event ~= "None" and Hrs < 5 then
		UIMessageEvent = UIMessageEvent .. string.format("|cFF6900%s:  %s|r",EVT.lang["Available"],Available1+Available2+Available3)
	elseif Available1 + Available2 + Available3 > 0 and EVT.vars.Current_Event ~= "None" then
		UIMessageEvent = UIMessageEvent .. string.format("%s:  %s",EVT.lang["Available"],Available1+Available2+Available3)
	end

---------------------------------------
-- PART 3 - Event end/Next start
---------------------------------------

-- 1.19 Make this a separate function so it can be called to refresh UI once per hour, so "hour" stays accurate.
	EVT.ShowNextInfo(call_from,PrevReset,EvtDays,EvtHrs,Mins,Available1,Available2,Available3)

-- This is for testing purposes - uncommenting it will allow looping through the test code at the beginning
--  TestRun = TestRun + 1

	if call_from == "Daily Reset" then
-- 1.22 Added function to set up polls
		EVT.SetUpPoll(PrevReset, Hrs, Mins, EvtDays, EvtHrs)
	end

end


---------------------------------------
-- ShowNextInfo - was end of ShowVars
---------------------------------------
-- 1.28 All chat output only occurs is call_from=="Signon", so no need to remove it for "UI"
function EVT.ShowNextInfo(call_from,PrevReset,EvtDays,EvtHrs,Mins,Available1,Available2,Available3)
	local TmpUIMessage = ""
-- 1.54 Added All_Locked
	local All_Locked = not ((EVT_DLC_UNLOCKED[1] and EVT.vars.T_Tickets[1]>0) or (EVT_DLC_UNLOCKED[2] and EVT.vars.T_Tickets[2]>0) or (EVT_DLC_UNLOCKED[3] and EVT.vars.T_Tickets[3]>0))

	if EVT.vars.Current_Event == "None" then
		TmpUIMessage = UIMessageNone
		if EVT_EVENT_START == EVT_DATE_UNKNOWN then
			TmpUIMessage = TmpUIMessage .. "\n\n"
		elseif EvtDays < 6 and EvtDays > 1 then
			TmpUIMessage = string.format("|c00CCFF%s:|r\n|cFFFFFF%s days %s hrs %s min|r\n",EVT.lang["Next Event"],EvtDays, EvtHrs,Mins) .. TmpUIMessage
			if call_from == "Signon" and not EVT.vars.autoHide and (EVT.FindCurrentTime() - EVT.vars.Message_Time > EVT_MESSAGE_DELAY) then
				CHAT_ROUTER:AddSystemMessage(string.format("The %s event starts in %s days, %s hrs, %s min.",EVT_NEXT_EVENT,EvtDays,EvtHrs,Mins))
			end
		elseif EvtDays < 2 and EvtDays > 0 then
			TmpUIMessage = string.format("|c00CCFF%s:|r\n|cFFFFFF1 day %s hrs %s min|r\n",EVT.lang["Next Event"],EvtHrs,Mins) .. TmpUIMessage
			if call_from == "Signon" and not EVT.vars.autoHide and (EVT.FindCurrentTime() - EVT.vars.Message_Time > EVT_MESSAGE_DELAY) then
				CHAT_ROUTER:AddSystemMessage(string.format("The %s event starts in %s day, %s hrs, %s min.",EVT_NEXT_EVENT,EvtDays,EvtHrs,Mins))
			end
		elseif EvtDays < 1 and EvtHrs < 1 then
			TmpUIMessage = string.format("|c00CCFF%s:|r\n|cFFFFFF%s minutes|r\n",EVT.lang["Next Event"],Mins) .. TmpUIMessage
			if call_from == "Signon" and not EVT.vars.autoHide and (EVT.FindCurrentTime() - EVT.vars.Message_Time > EVT_MESSAGE_DELAY) then
				CHAT_ROUTER:AddSystemMessage(string.format("The %s event starts in %s minutes!",EVT_NEXT_EVENT,Mins))
			end
		elseif EvtDays < 1 and EvtHrs < 2 then
			TmpUIMessage = string.format("|c00CCFF%s:|r\n|cFFFFFF1 hr %s minutes|r\n",EVT.lang["Next Event"],Mins) .. TmpUIMessage
			if call_from == "Signon" and not EVT.vars.autoHide and (EVT.FindCurrentTime() - EVT.vars.Message_Time > EVT_MESSAGE_DELAY) then
				CHAT_ROUTER:AddSystemMessage(string.format("The %s event starts in 1 hr %s minutes!",EVT_NEXT_EVENT,Mins))
			end
		elseif EvtDays < 1 then
			TmpUIMessage = string.format("|c00CCFF%s:|r\n|cFFFFFF%s hrs %s min|r\n",EVT.lang["Next Event"],EvtHrs,Mins) .. TmpUIMessage
			if call_from == "Signon" and not EVT.vars.autoHide and (EVT.FindCurrentTime() - EVT.vars.Message_Time > EVT_MESSAGE_DELAY) then
				CHAT_ROUTER:AddSystemMessage(string.format("The %s event starts in %s hrs, %s min!",EVT_NEXT_EVENT,EvtHrs,Mins))
			end
		elseif call_from == "/evt" then
			TmpUIMessage = TmpUIMessage .. "\n\n"
			if call_from == "Signon" and not EVT.vars.autoHide and (EVT.FindCurrentTime() - EVT.vars.Message_Time > EVT_MESSAGE_DELAY) then
				CHAT_ROUTER:AddSystemMessage(string.format("The %s event starts in %s days, %s hrs, %s min.",EVT_NEXT_EVENT,EvtDays,EvtHrs,Mins))
			end
		else
			TmpUIMessage = TmpUIMessage .. "\n\n"
		end
-- 1.66 Added Unknown end date, and also Unknown event
	elseif EVT.vars.Current_Event == "Unknown" then
		TmpUIMessage = UIMessageEvent .. "\n"
		if call_from == "Signon" and not EVT.vars.autoHide then
			CHAT_ROUTER:AddSystemMessage("|cFFFFFFEvent not recognized.|r |cFFD700Please update Event Tracker!|r")
		end
	elseif EVT_EVENT_END == EVT_DATE_UNKNOWN then
		TmpUIMessage = UIMessageEvent .. "\n"
		if call_from == "Signon" and not EVT.vars.autoHide then
			CHAT_ROUTER:AddSystemMessage("|cFFFFFFEnd date unknown.|r |cFFD700Please update Event Tracker!|r")
		end
	else
		TmpUIMessage = UIMessageEvent
		if EVT_EVENT_END == EVT_DATE_UNKNOWN then
			TmpUIMessage = TmpUIMessage .. "\n"
-- 1.54 If event is locked; ending soon (no red or orange warnings, or "event finished".)
		elseif All_Locked and (EVT_EVENT_END-PrevReset) < (36*60*60) then 
			if EvtDays > 1 then
				TmpUIMessage = string.format("|c00CCFF%s|r |cFFFFFF%s hrs %s min|r\n",EVT.lang["Event ends"],EvtHrs,Mins) .. TmpUIMessage
				if call_from == "Signon" and not EVT.vars.autoHide and (EVT.FindCurrentTime() - EVT.vars.Message_Time > EVT_MESSAGE_DELAY) then
					CHAT_ROUTER:AddSystemMessage(string.format("|cFFD700%s in %s day, %s hrs, %s min.|r",EVT.lang["Event ends"],EvtDays,EvtHrs,Mins))
				end
			elseif (Mins > 30) then
				TmpUIMessage = string.format("|c00CCFF%s|r |cFFFFFF%s days %s hrs|r\n",EVT.lang["Event ends"],EvtDays, EvtHrs+1) .. TmpUIMessage
				if call_from == "Signon" and not EVT.vars.autoHide and (EVT.FindCurrentTime() - EVT.vars.Message_Time > EVT_MESSAGE_DELAY) then
					CHAT_ROUTER:AddSystemMessage(string.format("|cFFD700%s in %s day, %s hrs, %s min.|r",EVT.lang["Event ends"],EvtDays,EvtHrs,Mins))
				end
			else
				TmpUIMessage = string.format("|c00CCFF%s|r |cFFFFFF%s days %s hrs|r\n",EVT.lang["Event ends"],EvtDays, EvtHrs) .. TmpUIMessage
				if call_from == "Signon" and not EVT.vars.autoHide and (EVT.FindCurrentTime() - EVT.vars.Message_Time > EVT_MESSAGE_DELAY) then
					CHAT_ROUTER:AddSystemMessage(string.format("|cFFD700%s in %s day, %s hrs, %s min.|r",EVT.lang["Event ends"],EvtDays,EvtHrs,Mins))
				end
			end
		elseif (EVT_EVENT_END-PrevReset) < (36*60*60) then
			if EvtDays > 0 then
				TmpUIMessage = string.format("|cFF6900%s|r |cFFFFFF1 day %s hrs|r\n",EVT.lang["EVENT ENDS"],EvtHrs) .. TmpUIMessage
				if call_from == "Signon" and not EVT.vars.autoHide and (EVT.FindCurrentTime() - EVT.vars.Message_Time > EVT_MESSAGE_DELAY) then
					CHAT_ROUTER:AddSystemMessage(string.format("|cFF6900%s in %s day, %s hrs, %s min.|r",EVT.lang["Event ends"],EvtDays,EvtHrs,Mins))
				end
			elseif EvtDays == 0 and EvtHrs < 1 then
				if Available1 == 0 and Available2 == 0 and Available3 == 0 then
					TmpUIMessage = TmpUIMessage .. string.format("|cFFFFFF%s in %s minutes\n%s.|r",EVT.lang["Event ends"],Mins,EVT.lang["Final trade bars finished"])
				else
					TmpUIMessage = string.format("|cFF0000%s|r |cFFFFFF%s MINUTES!|r\n",EVT.lang["EVENT ENDS"],Mins) .. TmpUIMessage
				end
				if call_from == "Signon" and not EVT.vars.autoHide and (EVT.FindCurrentTime() - EVT.vars.Message_Time > EVT_MESSAGE_DELAY) then
					if Available1 == 0 and Available2 == 0 and Available3 == 0 then
						CHAT_ROUTER:AddSystemMessage(string.format("|cFFFFFF%s in %s minutes. %s.|r",EVT.lang["Event ends"],Mins,EVT.lang["Final trade bars finished"]))
					else
						CHAT_ROUTER:AddSystemMessage(string.format("|cFF0000%s minutes remaining until %s!|r",Mins,EVT.lang["Event ends"]))
					end
				end
			elseif EvtHrs < 2 then
				if Available1 == 0 and Available2 == 0 and Available3 == 0 then
					TmpUIMessage = TmpUIMessage .. string.format("|cFFFFFF%s %s hr %s min\n%s.|r",EVT.lang["Event ends"],EvtHrs,Mins,EVT.lang["Final trade bars finished"])
				else
					TmpUIMessage = string.format("|cFF0000%s|r |cFFFFFF%s hr %s min|r\n",EVT.lang["EVENT ENDS"],EvtHrs,Mins) .. TmpUIMessage
				end
				if call_from == "Signon" and not EVT.vars.autoHide and (EVT.FindCurrentTime() - EVT.vars.Message_Time > EVT_MESSAGE_DELAY) then
					if Available1 == 0 and Available2 == 0 and Available3 == 0 then
						CHAT_ROUTER:AddSystemMessage(string.format("|cFFFFFF%s in %s hr, %s min. %s.|r",EVT.lang["Event ends"],EvtHrs,Mins,EVT.lang["Final trade bars finished"]))
					else
						CHAT_ROUTER:AddSystemMessage(string.format("|cFF0000%s hr, %s min remaining until %s!|r",EvtHrs,Mins,EVT.lang["Event ends"]))
					end
				end
			elseif (EVT_EVENT_END-PrevReset) < (18*60*60) then
				if Available1 == 0 and Available2 == 0 and Available3 == 0 then
					TmpUIMessage = TmpUIMessage .. string.format("|cFFFFFF%s %s hrs %s min\n%s.|r",EVT.lang["Event ends"],EvtHrs,Mins,EVT.lang["Final trade bars finished"])
				else
					TmpUIMessage = string.format("|cFF0000%s|r |cFFFFFF%s hrs %s min|r\n",EVT.lang["EVENT ENDS"],EvtHrs,Mins) .. TmpUIMessage
				end
				if call_from == "Signon" and not EVT.vars.autoHide and (EVT.FindCurrentTime() - EVT.vars.Message_Time > EVT_MESSAGE_DELAY) then
					if Available1 == 0 and Available2 == 0 and Available3 == 0 then
						CHAT_ROUTER:AddSystemMessage(string.format("|cFFFFFF%s in %s hrs, %s min. %s.|r",EVT.lang["Event ends"],EvtHrs,Mins,EVT.lang["Final trade bars finished"]))
					else
						CHAT_ROUTER:AddSystemMessage(string.format("|cFF0000%s hrs, %s min remaining until %s!|r",EvtHrs,Mins,EVT.lang["Event ends"]))
					end
				end
			else
				TmpUIMessage = string.format("|cFF6900%s|r |cFFFFFF%s hrs %s min|r\n",EVT.lang["EVENT ENDS"],EvtHrs,Mins) .. TmpUIMessage
				if call_from == "Signon" and not EVT.vars.autoHide and (EVT.FindCurrentTime() - EVT.vars.Message_Time > EVT_MESSAGE_DELAY) then
					CHAT_ROUTER:AddSystemMessage(string.format("|cFF6900%s hrs, %s min remaining until %s!|r",EvtHrs,Mins,EVT.lang["Event ends"]))
				end
			end
		elseif EvtDays < 6 then 
			if (Mins > 30) then
				TmpUIMessage = string.format("|c00CCFF%s|r |cFFFFFF%s days %s hrs|r\n",EVT.lang["Event ends"],EvtDays, EvtHrs+1) .. TmpUIMessage
				if call_from == "Signon" and not EVT.vars.autoHide and (EVT.FindCurrentTime() - EVT.vars.Message_Time > EVT_MESSAGE_DELAY) then
					CHAT_ROUTER:AddSystemMessage(string.format("|cFFD700%s in %s days, %s hrs.|r",EVT.lang["Event ends"],EvtDays,EvtHrs+1))
				end
			else
				TmpUIMessage = string.format("|c00CCFF%s|r |cFFFFFF%s days %s hrs|r\n",EVT.lang["Event ends"],EvtDays, EvtHrs) .. TmpUIMessage
				if call_from == "Signon" and not EVT.vars.autoHide and (EVT.FindCurrentTime() - EVT.vars.Message_Time > EVT_MESSAGE_DELAY) then
					CHAT_ROUTER:AddSystemMessage(string.format("|cFFD700%s in %s days, %s hrs.|r",EVT.lang["Event ends"],EvtDays,EvtHrs))
				end
			end
		else
			TmpUIMessage = TmpUIMessage .. "\n"
		end
	end

	EVT.vars.Message_Time = EVT.FindCurrentTime()
	EVT.label:SetText(TmpUIMessage)
end


-- 1.50 Moves everything in FUTURE[1] into current if it's time to; cycle the FUTURE stack down one.
-- "start_now" = true if called from SetUpPoll, or false if called from Initialize.
-- Initialize called StartEvent later when it's ready to, so don't do it immediately.
-- If this is called from SetUpPoll, it's a back-to-back event and StartEvent must be run NOW.
function EVT.NextEvent(start_now)
	if EVT.FindCurrentTime() > (EVT_EVENT_END-61) and EVT_FUTURE > 0 then
		EVT.PrintDebug("|cFF00CC*****************************************************|r")
		local ShowDate1, ShowTime1 = FormatAchievementLinkTimestamp(EVT_EVENT_START)
		EVT_EVENT_START = EVT_FUTURE_START[1]
		local ShowDate2, ShowTime2 = FormatAchievementLinkTimestamp(EVT_EVENT_START)
		EVT.PrintDebug(string.format("Start time changed from: %s %s to %s %s",ShowDate1, ShowTime1, ShowDate2, ShowTime2))

		ShowDate1, ShowTime1 = FormatAchievementLinkTimestamp(EVT_EVENT_END)
		EVT_EVENT_END   = EVT_FUTURE_END[1]
		ShowDate2, ShowTime2 = FormatAchievementLinkTimestamp(EVT_EVENT_END)
		EVT.PrintDebug(string.format("End time changed from: %s %s to %s %s",ShowDate1, ShowTime1, ShowDate2, ShowTime2))

		EVT_NEXT_EVENT  = EVT_FUTURE_EVENT[1]
		EVT_UPCOMING_INFO = EVT_FUTURE_NEXT[1]
		EVT_EVENT_INFO_BEGIN = EVT_FUTURE_BEGIN[1]
		EVT_EVENT_INFO_BOX = EVT_FUTURE_BOX[1]
		EVT_EVENT_DETAILS = EVT_FUTURE_DETAILS
		EVT.PrintDebug("|cFF00CC*****************************************************|r")

-- If event has been started already, name should match, do nothing.
-- If name doesn't match, set to "None". When event starts (or if it already has), this should force it to initialize.
		if EVT.vars.Current_Event ~= EVT_NEXT_EVENT then
			EVT.vars.Current_Event = "None"
			if start_now then EVT.StartNewEvent() end
		end

		if EVT_FUTURE > 1 then -- Cycle down one (not needed yet, because only one to start with)
		end
		EVT_FUTURE = EVT_FUTURE - 1
	end
end


-- 1.72 Removed from EVT.Auto_XP_Buff so it can return the information (for UpdateScrollBuff) without actually changing anything.
-- 1.981 Added extra parameter Try_Again so it can be killed if a pie, cake, scroll, or whatever has not been collected yet.
function EVT.Next_Buff_Time()
	local tempbuffcooldown = XPbuffcooldown
-- 1.86 Add Return_msg (from Refresh_XP_Buff, if called, or "not refreshed" if not)
	local Return_msg = "not refreshed"
	local Try_Again = true
-- 1.68 Make sure this never triggers if auto buff is off.
	if EVT.settings.XP_refresh >= 120 then
		tempbuffcooldown = EVT_EVENT_END
		EVT.PrintDebug(string.format("Auto buff |cFF0000OFF|r Refresh: %s Cooldown: %s",EVT.settings.XP_refresh,tempbuffcooldown))
	else
		EVT.PrintDebug(string.format("Auto buff |c32CD32ON|r Refresh: %s Cooldown: %s",EVT.settings.XP_refresh,tempbuffcooldown))

-- 1.67 Possible msg options: "Ok", "Not an XP event", "Auto-buff will not remove your old Pelinal Scroll buff", "Auto-buff will not remove your old double XP buff"
		local BuffEndTime, msg = EVT.XP_Buff_Time()
		if msg=="Ok" and BuffEndTime > EVT_EVENT_END then BuffEndTime = EVT_EVENT_END end -- If it's an XP event, don't let the buff run out at the end without refreshing it.

		if (BuffEndTime-EVT.FindCurrentTime()) <= EVT.settings.XP_refresh*60 and tempbuffcooldown <= EVT.FindCurrentTime() then
			Return_msg, Try_Again = EVT.Refresh_XP_Buff()
			BuffEndTime, msg = EVT.XP_Buff_Time()
			if msg=="Ok" and BuffEndTime > EVT_EVENT_END then BuffEndTime = EVT_EVENT_END end -- If it's an XP event, don't let the buff run out at the end without refreshing it.
		end

		if tempbuffcooldown < EVT.FindCurrentTime() + EVT.settings.XP_frequency*60 then -- Make sure that the cooldown setting is used for the minimum time between tries
			tempbuffcooldown = EVT.FindCurrentTime() + EVT.settings.XP_frequency*60 + 1
		end

		if BuffEndTime-EVT.settings.XP_refresh*60 > tempbuffcooldown then -- Use refresh setting for next refresh unless cooldown timer is less
			tempbuffcooldown = BuffEndTime-EVT.settings.XP_refresh*60
		end
		EVT.PrintDebug(string.format("Auto buff |c32CD32ON|r Refresh: %s Cooldown: %s",EVT.settings.XP_refresh,tempbuffcooldown))
	end
	return tempbuffcooldown, Return_msg, Try_Again
end


-- AUTOBUFF
-- 1.67 New function
-- XP_refresh and XP_frequency are in minutes, not seconds like other times, so convert.
--[[ XP_Buff_Time returns the next time to check for auto buff refreshing, after checking for current buff.
Does not take into account cooldown for retries, whether end of event happens before next try, whether auto-refresh setting is off.
Not XP event	EVT_DATE_UNKNOWN (far future)
  No event	EVT_EVENT_START (could be UNKNOWN)
  If event	EVT_EVENT_END (could be UNKNOWN)
XP event default	Current time (no buff)
  Same type buff	Buff end time minus refresh setting (default 60 min, so it will start trying to refresh with 60 min. left)
  Different buff	Buff end time: do not auto-buff over a different type of buff
Calling routine must check if auto-refresh is on (refresh setting>=120) if appropriate.
]]
--[[ Auto_XP_Buff returns XPbuffcooldown (not as a direct parameter, because of how "RegisterForUpdate" works):
If attempt is made to refresh buff, set next time based on cooldown: If it succeeded, next attempt will discover the buff is fine.
Also check if end of event happens before refresh/cooldown time. If it does, set the refresh sooner.
]]
function EVT.Auto_XP_Buff()
	local buff_fail = {
		["Jester's Festival"] = "NEED TO UNLOCK the Pie of Misrule",
		["New Life"] = "NEED TO UNLOCK Breda's Bottomless Mead Mug",
		["Witches"] = "NEED TO UNLOCK Witchmother's Whistle",
		["Anniversary"] = "NO CAKE",
		["Whitestrake's Mayhem"] = "SCROLL MISSING"
		}

-- 1.85 "RegisterForUpdate" was using "Refresh_XP_Buff" instead of "Auto_XP_Buff" - 2 fixes here
-- 1.80
	EVENT_MANAGER:UnregisterForUpdate("EVT_Refresh_XP_Buff")


-- 1.72 Removed most of this to a separate function that doesn't actually change anything; see above
	local XPbuffcooldown, Return_msg, Try_Again = EVT.Next_Buff_Time()

-- 1.981 Added Try_Again to stop excess messages when there's no cake, pie, scroll, etc.
	if not Try_Again then return end

-- 1.78 Re-wrote the whole thing
	if XPbuffcooldown < EVT.settings.XP_refresh then
		if Return_msg == "not refreshed" then Return_msg = EVT.Refresh_XP_Buff() end	-- 1.86 Only do this if it wasn't already done
-- 1.80
--		if XPbuffcooldown-EVT.FindCurrentTime() < Hrs*EVT_ONE_HOUR+Mins*60  then
-- 1.86 Added buff_fail and next "if", so if there's no thing available, then auto-refresh will stop trying and stop pestering for the rest of this session.
		if Return_msg ~= buff_fail[EVT.vars.Current_Event] then
			PollSecs = EVT.settings.XP_refresh
			EVT.PrintDebug(string.format("|cAD00FFAttempted to refresh buff. Next check: %s minutes",PollSecs/60))
			EVENT_MANAGER:RegisterForUpdate("EVT_Refresh_XP_Buff", PollSecs*1000, EVT.Auto_XP_Buff)
		end
	else
-- 1.80
		PollSecs = XPbuffcooldown-EVT.FindCurrentTime()
		EVT.PrintDebug(string.format("|cAD00FFBuff NOT refreshed. Next check in %s minutes",PollSecs/60))
		EVENT_MANAGER:RegisterForUpdate("EVT_Refresh_XP_Buff", PollSecs*1000, EVT.Auto_XP_Buff)
	end


end


-- AUTOBUFF
function EVT.Toggle_Auto_Buff(TurnOn)
-- 1.80 moved from below
	EVENT_MANAGER:UnregisterForUpdate("EVT_Refresh_XP_Buff")
	if TurnOn then
		EVT.Notification("|c32CD32** NOTICE","|rAutomatic event XP buff is now |c32CD32ON! **|r",SOUNDS.LEVEL_UP)
		EVT.Notification("|c32CD32** NOTICE","|rUse |cFFD700/xpbuff auto|r to turn it off. |c32CD32**|r",SOUNDS.CHAMPION_POINTS_COMMITTED)
		CHAT_ROUTER:AddSystemMessage("|cFFFFFFAutomatic XP Buff is now|r |c32CD32ON.|r")
		CHAT_ROUTER:AddSystemMessage("|cFFD700This applies to ALL of your accounts on this computer!|r")
		CHAT_ROUTER:AddSystemMessage("|cFFFFFFType|r |cFFD700/xpbuff auto|r |cFFFFFFto turn it off.|r")
		EVT.settings.XP_refresh = 60

		EVT.Refresh_XP_Buff()
-- 1.80
		PollSecs = EVT.settings.XP_refresh
		EVT.PrintDebug(string.format("|cAD00FFAttempted to refresh buff. Next check: %s minutes",PollSecs/60))
-- 1.85 "RegisterForUpdate" was using "Refresh_XP_Buff" instead of "Auto_XP_Buff"
		EVENT_MANAGER:RegisterForUpdate("EVT_Refresh_XP_Buff", PollSecs*1000, EVT.Auto_XP_Buff)
	else
		EVT.Notification("|cFF0000** NOTICE","|rAutomatic event XP buff is now |cFF0000OFF! **|r",SOUNDS.LEVEL_UP)
		EVT.Notification("|cFF0000** NOTICE","|rUse |cFFD700/xpbuff auto|r to turn it on. |cFF0000**|r",SOUNDS.CHAMPION_POINTS_COMMITTED)
		CHAT_ROUTER:AddSystemMessage("|cFFFFFFAutomatic XP Buff is now|r |cFF0000OFF.|r")
		CHAT_ROUTER:AddSystemMessage("|cFFFFFFType|r |cFFD700/xpbuff auto|r |cFFFFFFto turn it back on.|r")
		EVT.settings.XP_refresh = 200

--		XPbuffcooldown = EVT_DATE_UNKNOWN -- effectively, never
-- 1.80 moved "unregister" from here
	end
end


--[[ Called by /csb
function EVT.Show_Poll()
		local timeString = ZO_FormatTime(EVT_Poll_Time-EVT.FindCurrentTime(), TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_SECONDS)
		CHAT_ROUTER:AddSystemMessage(string.format("|cFF00CCPOLL:|r %s Time remaining: %s",EVT_POLLING_ACTIVE,timeString))
end
]]

function EVT.SetUpPoll(PrevReset, Hrs, Mins, EvtDays, EvtHrs)
	local PollHrs = 0
	local PollMins = 0
	local PollSecs = 0
-- 1.88 Added NextMin
	local NextMin = 60-(EVT.FindCurrentTime()-(math.floor(EVT.FindCurrentTime()/60)*60))
	if NextMin == 0 then NextMin = 60 end
	local NextHr = 5400-(EVT.FindCurrentTime()-(math.floor(EVT.FindCurrentTime()/3600)*3600))
	if NextHr == 0 then NextHr = 1800 end
	EVT.PrintDebug(string.format("Seconds until next minute: %s Minutes until next hour update: %s",NextMin, NextHr/60))

--local BuffEndTime, msg = EVT.XP_Buff_Time()
--local showdate,showtime = FormatAchievementLinkTimestamp(BuffEndTime)
--CHAT_ROUTER:AddSystemMessage(string.format("|cFFD700Buff End Time: %s, Message: %s",showtime,msg))

	EVT.PrintDebug("|cAD00FFSetUpPoll")
-- 1.30
	if EVT_POLLING_ACTIVE ~= "None" then
		EVENT_MANAGER:UnregisterForUpdate(EVT.name)
		EVT_POLLING_ACTIVE = "None"
	end

-- 1.83 No event currently running, and none starting any time soon: de-activate.
	if EVT.vars.Current_Event == "None" and EVT_EVENT_START == EVT_DATE_UNKNOWN then
		EVT.PrintDebug("POLL: DEACTIVATED")
		return

-- AUTOBUFF Removed from here
-- 1.67 Auto xp buff: XPbuffcooldown (next time to try buff) is initialized to current time, so this will run at least once. Sets cooldown.
-- Also, if time has passed (like if it's down to one minute UI refreshes), this'll just trigger it between them.
-- 1.77 Temporarily disable autobuffing; not needed for this event, and needs more testing.
--	if XPbuffcooldown <= EVT.FindCurrentTime() then EVT.Auto_XP_Buff() end

-- 1.07 Added poll to automatically trigger start of next event 10 seconds after it occurs.
	elseif EVT.FindCurrentTime() < EVT_EVENT_START and EVT.vars.Current_Event == "None" then
		EVT.PrintDebug(string.format("POLL: Minutes until next event: %s",(EVT_EVENT_START-EVT.FindCurrentTime())/60))
		if EvtDays+EvtHrs <= 0 and Mins < 2 then
			PollSecs = EVT_EVENT_START-EVT.FindCurrentTime()
			EVENT_MANAGER:RegisterForUpdate(EVT.name, PollSecs*1000, EVT.StartNewEvent)
			EVT_POLLING_ACTIVE = "Start New Event"
-- 1.67 Trigger autobuff to start right after event starts if autobuff setting is on (Polling will be called.)
-- 1.88 Remove autobuff from here			if EVT.settings.XP_refresh < 120 then XPbuffcooldown = EVT_EVENT_START end
-- 1.22 If UI is hidden, don't poll every minute
		elseif EVT_HIDE_UI then
			EVT_POLLING_ACTIVE = "None"
		else
			PollSecs = NextMin -- was 58, then 590
			EVENT_MANAGER:RegisterForUpdate(EVT.name, PollSecs*1000, EVT.UpdateUI)
			EVT_POLLING_ACTIVE = "Update UI"
		end

-- 1.22 Add poll to show minutes the last 24 hours before event ends
	elseif EVT_EVENT_END-EVT.FindCurrentTime() < EVT_ONE_DAY and EVT.vars.Current_Event ~= "None"  and not EVT_HIDE_UI then
		EVT.PrintDebug("Set up poll for final 24 hours of event to update UI once per minute")
		PollSecs = NextMin -- was 58, then 590
		EVENT_MANAGER:RegisterForUpdate(EVT.name, PollSecs*1000, EVT.UpdateUI)
		EVT_POLLING_ACTIVE = "Update UI"
-- 1.22 Add poll to show hours the last 5 days before event ends or next one starts, and check that UI shows if it should be
	elseif (EVT.vars.Current_Event ~= "None" and EVT_EVENT_END-EVT.FindCurrentTime() <= EVT_ONE_DAY*6) or (EVT.vars.Current_Event == "None" and EVT_EVENT_START-EVT.FindCurrentTime() < EVT_ONE_DAY*5) and not EVT_HIDE_UI then
		EVT.PrintDebug("Set up poll for 5 days before event end, or start of next, to update UI once per min")
		PollSecs = NextHr -- was 58, then 590, then NextMin
		EVENT_MANAGER:RegisterForUpdate(EVT.name, PollSecs*1000, EVT.UpdateUI)
		EVT_POLLING_ACTIVE = "Update UI"

-- 1.13 Added poll to automatically show tickets are available at reset.
	elseif EVT.vars.Current_Event ~= "None" then
-- AUTOBUFF Removed from here
-- 1.67 Add auto xp buff
--[[ 1.79 Missed THIS!
		if XPbuffcooldown-EVT.FindCurrentTime() < Hrs*EVT_ONE_HOUR+Mins*60  then
			EVT.PrintDebug(string.format("|cAD00FFSet poll up to refresh XP Buff! %s minutes",(XPbuffcooldown-EVT.FindCurrentTime())/60))
			PollSecs = XPbuffcooldown-EVT.FindCurrentTime()
			EVENT_MANAGER:RegisterForUpdate(EVT.name, PollSecs*1000, EVT.Auto_XP_Buff)
			EVT_POLLING_ACTIVE = "XP Buff"
		else
]]
-- EVT.PrintDebug(string.format("POLL: Starting timer: %s seconds",Hrs*EVT_ONE_HOUR+Mins*60))
			PollSecs = Hrs*EVT_ONE_HOUR+Mins*60
			EVENT_MANAGER:RegisterForUpdate(EVT.name, PollSecs*1000, EVT.ResetMsg)
			EVT_POLLING_ACTIVE = "Daily Reset"
-- 1.79		end
	end

-- 1.29 Added this to make sure reset poll overrides UI, especially near end of event
--	EVT.PrintDebug(string.format("POLL: Time until reset: %s hrs + %s mins = %s seconds",Hrs,Mins,Hrs*EVT_ONE_HOUR+Mins*60))
	if EVT_POLLING_ACTIVE == "Update UI" and Hrs*EVT_ONE_HOUR+Mins*60 <= PollSecs+60 and EVT.vars.Current_Event ~= "None" then
		EVT.PrintDebug(string.format("POLL: RESET OVERRIDE!! Starting timer: %s seconds",Hrs*EVT_ONE_HOUR+Mins*60))
		PollSecs = Hrs*EVT_ONE_HOUR+Mins*60	-- 1.94 Removed +10
		EVENT_MANAGER:UnregisterForUpdate(EVT.name)
-- 1.50 Checks if next event needs to be flipped over, and does it if necessary. "start_now" parameter is true for back-to-back events.
		EVT.NextEvent(true)
		EVENT_MANAGER:RegisterForUpdate(EVT.name, PollSecs*1000, EVT.ResetMsg)
		EVT_POLLING_ACTIVE = "Daily Reset"
		EVT.PrintDebug("DAILY RESET OVERRIDE!")
	end

	PollHrs = math.floor(PollSecs/EVT_ONE_HOUR)
	PollMins = math.floor((PollSecs-(PollHrs*EVT_ONE_HOUR))/60)
	PollSecs = PollSecs - PollHrs*EVT_ONE_HOUR - PollMins*60
	EVT.PrintDebug("POLL: " .. EVT_POLLING_ACTIVE .. string.format(" %s hrs %s mins %s secs",PollHrs,PollMins,PollSecs))
	EVT_Poll_Time = EVT.FindCurrentTime() + (PollHrs*60 + PollMins)*60 + PollSecs
end
