--Cool7's DeathReport

DeathReport = {
	version				= "2.1",
    author				= "Cool7",
    name				= "DeathReport",
    displayName			= "Death Report",
    website				= "https://www.esoui.com/downloads/info2002-DeathReport.html",
	savedVarsName		= "DeathReport_SavedVariables",
    savedVarsVersion	= 1.0, --Changing this will reset all SavedVariables!
}

DeathReport.defaultSettings = {
	shortreport = true,
	longreport = true,
	reportHistory = {{},{},{},{},{},{},{},{},{},{},},
	reportHistoryTitle = {"","","","","","","","","","",},
	reportHistoryTime  = {"","","","","","","","","","",},
	reportLapHistory  = {{},{},{},{},{},{},{},{},{},{},},
	reportLapHistoryTitle = {"","","","","","","","","","",},
	reportLapHistoryTime  = {"","","","","","","","","","",},
	reportIndex = 1,
	reportLapIndex = 1,
	isRaid = false,
	raidName = "",
	racetime = "",
	laptime = "",
	lapLocations = {},
	raceLocations = {},
	deathlistlap = {},
	deathlistrace = {},
	resetTrialAuto = true,
	autoResetRace = 18000,
	autoResetLap = 10800,
	ignoreCharName = false,
	autoPrefix = false,
}

local raid_score_time = ""
local totalHistoryReports = 10
local extraTitle = ""
	
local LAM = LibStub('LibAddonMenu-2.0')
local function DR_BuildAddonMenu()

	local panelData = {
		type 				= 'panel',
		name 				= DeathReport.displayName,
		displayName 		= DeathReport.displayName,
		author 				= DeathReport.author,
		version 			= DeathReport.version,
		registerForRefresh 	= true,
		registerForDefaults = true,
        website 			= DeathReport.website,
	}
	
	LAM:RegisterAddonPanel(DeathReport.name .. "_LAM", panelData)

	local optionsTable =
    {	-- BEGIN OF OPTIONS TABLE

--Description of the addon
		{
			type = "description",
			text = "Make reports of your groups's death counter.",
		},
		--Always use accountwide settings
	
		{
        	type = "header",
        	name = "General Options",
        },
	
		{
			type = "checkbox",
			name = "Enable short report to chat",
			tooltip = "Short version report use character name only, send to chat line with 350 chars limit",
			getFunc = function() return DeathReport.savedVariables.shortreport end,
			setFunc = function(state) DeathReport.savedVariables.shortreport = state end,
			-- default = true,
		},
		{
			type = "checkbox",
			name = "Enable long report to popup window",
			tooltip = "Longer version report use format of character name@account name, present in popup window without chars limit",
			getFunc = function() return DeathReport.savedVariables.longreport end,
			setFunc = function(state) DeathReport.savedVariables.longreport = state end,
			-- default = true,
		},
		{
			type = "description",
			text = "NOTE: If both above options set to OFF, no report will be generated.",
		},
		{
			type = "checkbox",
			name = "Ignore character name",
			warning = "Report will be reset when this option changes.", 
			tooltip = "When enabled, addon will use @name only, death from different character will be combined.",
			getFunc = function() return DeathReport.savedVariables.ignoreCharName end,
			setFunc = function(state)
				if state ~= DeathReport.savedVariables.ignoreCharName then
					DeathReport.savedVariables.ignoreCharName = state
					DeathReport.ResetRace("auto")
				end
			end,
			default = false,
		},
		{
			type = "checkbox",
			name = "Auto prefix for player's role",
			warning = "Tank will have (T) as prefix, healer will have (H) as prefix.", 
			tooltip = "When enabled, addon will use @name only, death from different character will be combined.",
			getFunc = function() return DeathReport.savedVariables.autoPrefix end,
			setFunc = function(state)
				if state ~= DeathReport.savedVariables.autoPrefix then
					DeathReport.savedVariables.autoPrefix = state
					DeathReport.ResetRace("auto")
				end
			end,
			default = false,
		},
		{
        	type = "header",
        	name = "Death Report Auto Reset",
        },
		{
			type = "checkbox",
			name = "Auto death report of vet Trial's.",
			tooltip = "Only work with veteran trial, normal trial cannot be tracked",
			getFunc = function() return DeathReport.savedVariables.resetTrialAuto end,
			setFunc = function(state) DeathReport.savedVariables.resetTrialAuto = state end,
		},
		{
			type = "slider",
			name = "Auto reset interim report after (s)",
			tooltip = "Report will be reset after defined seconds without death event, including offline period, default 3hr",
			min = 60,
			max = 86400,
			step = 1,
			getFunc = function() return DeathReport.savedVariables.autoResetLap end,
			setFunc = function(value)
				TimerReminder.savedVariables.reminderTimer  = value
			end,
			default = 10800
		},
		{
			type = "slider",
			name = "Auto reset total report after (s)",
			tooltip = "Report will be reset after defined seconds without death event, including offline period. default 5hr",
			min = 60,
			max = 86400,
			step = 1,
			getFunc = function() return DeathReport.savedVariables.autoResetRace end,
			setFunc = function(value)
				TimerReminder.savedVariables.reminderTimer  = value
			end,
			default = 18000
		},

	} -- END OF OPTIONS TABLE
	
	LAM:RegisterOptionControls(DeathReport.name .. "_LAM", optionsTable)

end



--------------------------------
--begin own functions
--------------------------------

function DeathReport.OnFocusLost()
	DeathReportWindow:SetAlpha(0)
	DeathReportWindow:SetMouseEnabled(false)
	DeathReportWindow:SetHidden(true)
end

function DeathReport.Prefix(arg1)
	local options = {}
	--local searchResult = { string.match(arg1,"^(%S*)%s*(.-)$") }
	local searchResult = { string.match(arg1,"^([^/,]*),*(.-)$") }
	for i,v in pairs(searchResult) do
		if (v ~= nil and v ~= "") then
			options[i] = v
		end
    end
	
	--we add to prefixlist
	if(options[2]~=nil) then
		prefixlist[tostring(options[1])]=tostring(options[2])
		DeathReport.savedVariables.prefixlist=prefixlist
	--or we remove
	else
		prefixlist[tostring(options[1])]=nil
	end

end

function DeathReport.ResetPrefix()
	--remove all prefixes from all players
	for k,v in pairs (prefixlist) do
		prefixlist[k] = nil
	end
	DeathReport.savedVariables.prefixlist=prefixlist
	d("All prefixes are reset.")
end

function DeathReport.getPlayerName(unitTag)
	local isDps
	local isHealer
	local isTank
	local prefix
	isDps, isHealer, isTank = GetGroupMemberRoles(unitTag)
	prefix=""
	if DeathReport.savedVariables.autoPrefix  then
		if isHealer then
			prefix = prefix .. "H"
		end
		if isTank then
			prefix = prefix .. "T"
		end
		if prefix ~= "" then
			prefix = "(" .. prefix .. ")"
		end
	end
	if DeathReport.savedVariables.ignoreCharName then
		return prefix .. GetUnitDisplayName(unitTag)
	else
		return prefix .. GetUnitName(unitTag) .. GetUnitDisplayName(unitTag)
	end
end


function DeathReport.getEventTitle(locationlist)
	local title
	
	if DeathReport.savedVariables.isRaid then
		-- Raid will use raid name
		title = DeathReport.savedVariables.raidName .. extraTitle
	else
		--other will use location names
		
		-- sort list
		local listloc = {}
		for key,value in pairs(locationlist) do 
			table.insert(listloc, {key,value})
		end
		table.sort(listloc, function(a,b) return a[1]>b[1] end)
		title = ""
		for dummy, keyvalue in pairs(listloc) do
			title = title .. "/" .. keyvalue[1]
		end
		title = string.sub(title,2)
		if string.len(title) < 3 then
		-- too short, use current location
			title = GetPlayerLocationName()
		end
	end
	return title

end


function DeathReport.deathUpdate(eventCode,unitTag,isDead)
	-- when a player dies

	if isDead and "group" == string.sub(unitTag, 0, 5) then 
		-- reset lap after 3 hours no death, reset race after 5 hours no death
		if GetTimeStamp() - DeathReport.savedVariables.lastevent > 18000 then 
			DeathReport.ResetRace("auto")
		elseif GetTimeStamp() - DeathReport.savedVariables.lastevent > 10800 then
			DeathReport.ResetLap("auto")
		end
		DeathReport.savedVariables.lastevent = GetTimeStamp()
		
		local playerName=DeathReport.getPlayerName(unitTag)

		--update death location
		DeathReport.savedVariables.lapLocations[GetUnitZone(unitTag)] = true
		DeathReport.savedVariables.raceLocations[GetUnitZone(unitTag)] = true
			
		--UPDATE LAP
		--find out if player died before
		local tempnr=DeathReport.savedVariables.deathlistlap[playerName]
		if tempnr==nil then 
			DeathReport.savedVariables.deathlistlap[playerName]=1
		else 
			DeathReport.savedVariables.deathlistlap[playerName]=tempnr+1
		end
		
		--UPDATE RACE
		--find out if player died before
		-- duplicate
		-- local playerName=string.sub(GetUnitName(unitTag),1,8) .. GetUnitDisplayName(unitTag)
		local tempnr=DeathReport.savedVariables.deathlistrace[playerName]
		if tempnr==nil then 
			DeathReport.savedVariables.deathlistrace[playerName]=1
		else 
			DeathReport.savedVariables.deathlistrace[playerName]=tempnr+1
		end
	end
end

function DeathReport.ResetLap(saveHistory)
	--reset the playerlist
	DeathReport.savedVariables.lastevent = GetTimeStamp()
	if tostring(saveHistory):lower() == "no" or ((next(DeathReport.savedVariables.lapLocations) == nil) and tostring(saveHistory):lower() == "auto") then
			-- do not save history when parameter is "no" or
			-- when parameter is "auto" and have empty death list
	else
		DeathReport.PopulateFullTeam(DeathReport.savedVariables.deathlistlap)
		DeathReport.savedVariables.reportLapHistory[DeathReport.savedVariables.reportLapIndex] = DeathReport.savedVariables.deathlistlap
		DeathReport.savedVariables.reportLapHistoryTime[DeathReport.savedVariables.reportLapIndex] = DeathReport.savedVariables.laptime
		DeathReport.savedVariables.reportLapHistoryTitle[DeathReport.savedVariables.reportLapIndex] = DeathReport.getEventTitle(DeathReport.savedVariables.lapLocations)
		DeathReport.savedVariables.reportLapIndex = (DeathReport.savedVariables.reportLapIndex % totalHistoryReports) + 1
	end
	DeathReport.savedVariables.deathlistlap = {}
	DeathReport.savedVariables.lapLocations = {}
	DeathReport.savedVariables.laptime = GetDateStringFromTimestamp(GetTimeStamp()) .. " " .. GetTimeString()
	d("DeathReport Reset Interim Death Counter")
end

function DeathReport.ResetRace(saveHistory)
	--reset the playerlist
	DeathReport.ResetLap(saveHistory)
	DeathReport.savedVariables.lastevent = GetTimeStamp()
	--d(DeathReport.savedVariables.isRaid)
	--d(DeathReport.savedVariables.deathlistrace)
	--d(next(DeathReport.savedVariables.deathlistrace))
	if tostring(saveHistory):lower() == "no" or ((next(DeathReport.savedVariables.raceLocations) == nil) and tostring(saveHistory):lower() == "auto") then
			-- do not save history when parameter is "no" or
			-- when parameter is "auto" and have empty death list
	else
		-- save history
		DeathReport.PopulateFullTeam(DeathReport.savedVariables.deathlistrace)
		DeathReport.savedVariables.reportHistory[DeathReport.savedVariables.reportIndex] = DeathReport.savedVariables.deathlistrace
		DeathReport.savedVariables.reportHistoryTime[DeathReport.savedVariables.reportIndex] = DeathReport.savedVariables.racetime
		DeathReport.savedVariables.reportHistoryTitle[DeathReport.savedVariables.reportIndex] = DeathReport.getEventTitle(DeathReport.savedVariables.raceLocations) .. raid_score_time
		DeathReport.savedVariables.reportIndex = (DeathReport.savedVariables.reportIndex % totalHistoryReports) + 1
	end
	DeathReport.savedVariables.racetime = GetDateStringFromTimestamp(GetTimeStamp()) .. " " .. GetTimeString()
	DeathReport.savedVariables.isRaid = false
	DeathReport.savedVariables.deathlistrace = {}	
	DeathReport.savedVariables.raceLocations = {}
	d("DeathReport Reset Total Death Counter")
end

function DeathReport.PopulateFullTeam(deathlist)
	for i=1,GetGroupSize() do
		playerName = DeathReport.getPlayerName(GetGroupUnitTagByIndex(i))
		if IsUnitOnline(GetGroupUnitTagByIndex(i))==true and deathlist[playerName]==nil then 
			-- zerodeathlist[playerName]=0
			deathlist[playerName]=0
			DeathReport.savedVariables.lastevent = GetTimeStamp()
		end
	end
end
function DeathReport.GenerateSortedReport(textprefix, deathlist, history, addtionalinfo)
	local outputString=addtionalinfo .. textprefix
	local outputStringS=textprefix
	-- Only do this for non-history records
	if history == false and GetGroupSize()>1 then
		DeathReport.PopulateFullTeam(deathlist)
	end

	local listreport = {}
	for key,value in pairs(deathlist) do 
		table.insert(listreport, {key,value})
	end
	-- for key,value in pairs(zerodeathlist) do 
		-- table.insert(listreport, {key,value})
	-- end
	table.sort(listreport, function(a,b) return a[2]>b[2] end)

	for index, keyvalue in pairs(listreport) do 
		--print player
		if(firsty==1) then
			outputString=outputString .. "| "
			outputStringS=outputStringS .. "| "
		else 
			firsty=1
		end
		if(prefixlist[keyvalue[1]]~=nill) then
			outputString=outputString .. tostring(prefixlist[keyvalue[1]]) .. " "
			outputStringS=outputStringS .. tostring(prefixlist[keyvalue[1]]) .. " "
		end
		outputString=outputString .. tostring(keyvalue[1]) .. ": " .. tostring(keyvalue[2]) .. " " 

		if DeathReport.savedVariables.ignoreCharName then
		-- since character's name is ignored, shortversion will be same as long version.
			outputStringS=outputString
		else
		-- short version only print out character name instead of full character@account name. Mainly due to chat 350 char limitation	
			outputStringS=outputStringS .. (SplitString("@",keyvalue[1])) .. ": " .. tostring(keyvalue[2]) .. " " 
		end
	end
	
	return outputStringS, outputString
end

function DeathReport.PrintReport(shortreport, longreport)
	if DeathReport.savedVariables.shortreport then
		--steal from solinur
		-- Determine appropriate channel
		--350chars max
		local channel = IsUnitGrouped('player') and "/p " or "/say "
		CHAT_SYSTEM.textEntry:SetText( channel .. shortreport )
		CHAT_SYSTEM:Maximize()
		CHAT_SYSTEM.textEntry:Open()
		CHAT_SYSTEM.textEntry:FadeIn()
	end

	if DeathReport.savedVariables.longreport then
		-- Enable report window
		DeathReportWindowText:SetText(longreport)
		DeathReportWindowText:SelectAll()
		DeathReportWindow:SetAlpha(1)
		DeathReportWindow:SetMouseEnabled(true)
		DeathReportWindow:SetHidden(false)
		DeathReportWindowText:TakeFocus() 
	end

end


function DeathReport.PrintLap(arg)
	arg = tostring(arg)
	if arg:lower() == "list" or arg:lower() == "history" then
		--history mode
		local historystring 
		historystring = ""
		local realindex
		for i=9,0,-1 do
			realindex = ((i + DeathReport.savedVariables.reportLapIndex - 1) % totalHistoryReports) + 1
			if string.len(tostring(DeathReport.savedVariables.reportHistoryTime[realindex])) > 10 then
				short, long = DeathReport.GenerateSortedReport("Interim Death Count: ", DeathReport.savedVariables.reportLapHistory[realindex], true, "")
				historystring = historystring .. DeathReport.savedVariables.reportLapHistoryTitle[realindex] .. " " .. DeathReport.savedVariables.reportLapHistoryTime[realindex] .. "\r\n"  .. long .. "\r\n"
			end
			DeathReportWindowText:SetText(historystring)
			DeathReportWindowText:SelectAll()
			DeathReportWindow:SetAlpha(1)
			DeathReportWindow:SetMouseEnabled(true)
			DeathReportWindow:SetHidden(false)
			DeathReportWindowText:TakeFocus() 			
		end
	else
		DeathReport.PrintReport(DeathReport.GenerateSortedReport("Interim Death Count: ", DeathReport.savedVariables.deathlistlap, false, DeathReport.getEventTitle(DeathReport.savedVariables.lapLocations) .. " " .. DeathReport.savedVariables.laptime .. "\r\n" ))
	end

end

function DeathReport.PrintRace(arg)
	arg = tostring(arg)
	if arg:lower() == "list" or arg:lower() == "history" then
		--history mode
		local historystring 
		historystring = ""
		local realindex
		for i=9,0,-1 do
			realindex = ((i + DeathReport.savedVariables.reportIndex - 1) % totalHistoryReports) + 1
			if string.len(tostring(DeathReport.savedVariables.reportHistoryTime[realindex])) > 10 then
				short, long = DeathReport.GenerateSortedReport("Total Death Count: ", DeathReport.savedVariables.reportHistory[realindex], true, "")
				historystring = historystring .. DeathReport.savedVariables.reportHistoryTitle[realindex] .. " " .. DeathReport.savedVariables.reportHistoryTime[realindex] .. "\r\n"  .. long .. "\r\n*****************\r\n"
			end
			DeathReportWindowText:SetText(historystring)
			DeathReportWindowText:SelectAll()
			DeathReportWindow:SetAlpha(1)
			DeathReportWindow:SetMouseEnabled(true)
			DeathReportWindow:SetHidden(false)
			DeathReportWindowText:TakeFocus() 			
		end
	else
		DeathReport.PrintReport(DeathReport.GenerateSortedReport("Total Death Count: ", DeathReport.savedVariables.deathlistrace, false, DeathReport.getEventTitle(DeathReport.savedVariables.raceLocations) .. " " .. DeathReport.savedVariables.racetime .. "\r\n"))
	end
end

function DeathReport.OnTrial_Started(event, trialName, weekly)
	if DeathReport.savedVariables.resetTrialAuto then
		DeathReport.ResetRace("auto")
		DeathReport.savedVariables.isRaid = true
		DeathReport.savedVariables.raidName = trialName
	end
end

function DeathReport.OnTrial_Complete(event, trialName, score, totalTime)
	-- number eventCode, string trialName, number score, number totalTime)
	-- Raid completed: Sanctum Ophidia, 95805, 4786234
	if DeathReport.savedVariables.resetTrialAuto then
		raid_score_time = " - Score:" .. tostring(score) .. " - Duration:" .. FormatTimeSeconds(math.floor(totalTime/1000), TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL,  TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_DESCENDING) .. " -"
		-- we want to save history here
		DeathReport.ResetRace()
		raid_score_time = ""
	end
end


--------------------------------
--initialization
--------------------------------
 
-- Next we create a function that will initialize our addon
function DeathReport.Initialize()

	ZO_CreateStringId("SI_BINDING_NAME_DEATH_REPORT_PRINT_TOTAL", "Total Report")
	ZO_CreateStringId("SI_BINDING_NAME_DEATH_REPORT_PRINT_INTERIM", "Interim Report")
	ZO_CreateStringId("SI_BINDING_NAME_DEATH_REPORT_PRINT_TOTAL_HISTORY", "Total Report(History)")
	ZO_CreateStringId("SI_BINDING_NAME_DEATH_REPORT_PRINT_INTERIM_HISTORY", "Interim Report(History)")
	ZO_CreateStringId("SI_BINDING_NAME_DEATH_REPORT_RESET_TOTAL", "Reset all data")
	ZO_CreateStringId("SI_BINDING_NAME_DEATH_REPORT_RESET_INTERIM", "Reset interim data")

	EVENT_MANAGER:RegisterForEvent(DeathReport.name, EVENT_UNIT_DEATH_STATE_CHANGED, DeathReport.deathUpdate)

	--load saved variables 
	--namely prefixes for counter
	DeathReport.savedVariables = ZO_SavedVars:NewAccountWide(DeathReport.savedVarsName, DeathReport.savedVarsVersion, nil, DeathReport.defaultSettings, nil)

	--GetGameTimeMilliseconds
	
	-- if(DeathReport.savedVariables.prefixlist~=nil) then
		-- prefixlist=DeathReport.savedVariables.prefixlist
	-- else 
		-- prefixlist={}
	-- end
	prefixlist=DeathReport.savedVariables.prefixlist and DeathReport.savedVariables.prefixlist or {} 
	DeathReport.savedVariables.lastevent=DeathReport.savedVariables.lastevent and DeathReport.savedVariables.lastevent or 0
	
	DeathReport.savedVariables.deathlistlap=DeathReport.savedVariables.deathlistlap and DeathReport.savedVariables.deathlistlap or {} 
	DeathReport.savedVariables.deathlistrace=DeathReport.savedVariables.deathlistrace and DeathReport.savedVariables.deathlistrace or {} 
	
	if GetTimeStamp() - DeathReport.savedVariables.lastevent > 18000 then
		-- Reset report after 5 hours since last update
		DeathReport.ResetRace()
	elseif  GetTimeStamp() - DeathReport.savedVariables.lastevent > 10800 then
		DeathReport.ResetLap("auto")
	end
	
	DR_BuildAddonMenu()
	
	--begin slash commands
	--------------------------------
	SLASH_COMMANDS["/resetint"] = DeathReport.ResetLap
	SLASH_COMMANDS["/resettot"] = DeathReport.ResetRace
	SLASH_COMMANDS["/printint"] = DeathReport.PrintLap
	SLASH_COMMANDS["/printtot"] = DeathReport.PrintRace
	--prefix with 1 argument removes prefix of player arg1 
	--prefix with 2 arguments adds/overwrites prefix arg2 to player arg1
	SLASH_COMMANDS["/prefix"] = DeathReport.Prefix
	SLASH_COMMANDS["/resetprefix"] = DeathReport.ResetPrefix
	--------------------------------
	--end slash commands
	--------------------------------
	EVENT_MANAGER:RegisterForEvent(DeathReport.name, EVENT_RAID_TRIAL_STARTED, DeathReport.OnTrial_Started)
	EVENT_MANAGER:RegisterForEvent(DeathReport.name, EVENT_RAID_TRIAL_COMPLETE, DeathReport.OnTrial_Complete)
end
-- Then we create an event handler function which will be called when the "addon loaded" event
-- occurs. We'll use this to initialize our addon after all of its resources are fully loaded.
function DeathReport.OnAddOnLoaded(event, addonName)
  -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
	if addonName == DeathReport.name then
		DeathReport.Initialize()
	end
end
 
-- Finally, we'll register our event handler function to be called when the proper event occurs.
EVENT_MANAGER:RegisterForEvent(DeathReport.name, EVENT_ADD_ON_LOADED, DeathReport.OnAddOnLoaded)