--[[
Copyright 2018 Sean McNamara <smcnam@gmail.com>.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

]]

local LAM = LibStub("LibAddonMenu-2.0")
local gas_name = "GuildActivity"
local gas_savedVarsName = "GuildActivityDB"
local gas_guildIndexes = {}
local gas_guildNames = {}
local gas_defaultVars = {
	guildsToLog = {},
	notify = false,
	frequency = 5,
	onlines = {},
}
local gas_ticking = false
local gas_myTimerName = nil
local gas_ldTimer_ver = 0.3
local gas_timers = {}

local function gas_yo()
	-- d("Yo-ing")
	GetAddOnManager():RequestAddOnSavedVariablesPrioritySave(gas_savedVarsName)
end

local function gas_add(name, millisecs, callback, maxevents)
	if (name==nil) then name="tempTimerLD"..GetGameTimeMilliseconds() end
	if (gas_timers[name]== nil) then gas_timers[name]={} end
	gas_timers[name].lastevent=GetGameTimeMilliseconds()
	gas_timers[name].millisecs=millisecs
	gas_timers[name].count=0
	gas_timers[name].callback=callback
	gas_timers[name].maxevents=maxevents
	gas_timers[name].params=nil
	return name
end

local function gas_rem(timerName)
	gas_timers[timerName] = nil
end

local function gas_setTimer(freq, funk)
	if gas_myTimerName ~= nil then
		-- d("Removing old timer " .. tostring(gas_myTimerName))
		gas_rem(gas_myTimerName)
	end
	-- d("Adding timer " .. (freq * 60000))
	gas_myTimerName = gas_add(nil, freq * 60000, funk, -1)
end

local gas_panelData = {
		type = "panel",
		name = gas_name,
		displayName = gas_name,
		author = "@Coorbin",
		version = "1.0",
		slashCommand = "/gasset",
		registerForRefresh = false,
		registerForDefaults = false,
		website = "https://github.com/allquixotic/ESOGuildActivityAddon",
}

local gas_optionsData = {
		{
			type = "header",
			name = "Guild Activity Stats Options",
		},
		{
			type = "dropdown",
			name = "Frequency",
			choices = { "1 minute", "5 minutes", "10 minutes", "30 minutes", "60 minutes", },
			choicesValues = { 1, 5, 10, 30, 60, },
			getFunc = function() return gas_savedVariables.frequency end,
			setFunc = function(var) 
				gas_savedVariables.frequency = var 
				gas_setTimer(gas_savedVariables.frequency, gas_doitAll)
				gas_yo()
				-- d("Frequency setter called " .. tostring(var))
			end,
			width = "half",
			disabled = function() return false end,
			tooltip = "The frequency with which the online member statistics will be gathered.",
			default = 5,
		},
		{
			type = "checkbox",
			name = "Notify in chat when saved",
			getFunc = function() return gas_savedVariables.notify end,
			setFunc = function(var) 
				gas_savedVariables.notify = var 
				gas_yo()
				-- d("Notify setter called " .. tostring(var))
			end,
			default = true,
		},
}

local function gas_updateGuildInfo()
	local numGuilds = GetNumGuilds()
	for i = 1, numGuilds do
		local gid = GetGuildName(GetGuildId(i))
		gas_guildIndexes[gid] = i
		gas_guildNames[i] = gid
		table.insert(gas_optionsData, {
			type = "checkbox",
			name = "Log " .. gid,
			getFunc = function() 
				-- d(tostring((gas_savedVariables.guildsToLog ~= nil and gas_savedVariables.guildsToLog[gid] == true)) .. " for " .. gid)
				return gas_savedVariables.guildsToLog ~= nil and gas_savedVariables.guildsToLog[gid] == true 
			end,
			setFunc = function(var) 
				gas_savedVariables.guildsToLog[gid] = var
				-- d("guildsToLog setter called " .. tostring(gas_savedVariables.guildsToLog))
				gas_yo()
			end,
			tooltip = "Do you want to log " .. gid .. " to the saved variables?",
			default = false,
		})
	end
end

local function gas_addWithData(name, millisecs, callback, maxevents,data)
	if gas_timers == nil then
		gas_timers={}
	end
	if (gas_timers[name]== nil) then gas_timers[name]={} end
	gas_timers[name].lastevent=GetGameTimeMilliseconds()
	gas_timers[name].millisecs=millisecs
	gas_timers[name].count=0
	gas_timers[name].callback=callback
	gas_timers[name].maxevents=maxevents
	gas_timers[name].params=data
end

local function gas_exists(name)
	if (gas_timers[name]== nil) then 
		return false
	else
		return true
	end
end

function gas_tick()
	if(gas_ticking == true) then
		for name,tmr in pairs(gas_timers) do
			-- d("tick: "..name)
			if gas_timers[name].maxevents~=-2 then -- not disabled
				if gas_timers[name].lastevent+gas_timers[name].millisecs<GetGameTimeMilliseconds() then
					if gas_timers[name].maxevents>0 then -- only track count if is not infinite
						gas_timers[name].count=gas_timers[name].count+1
					end
					if gas_timers[name].maxevents>0 and gas_timers[name].count>=gas_timers[name].maxevents then
						gas_timers[name].maxevents=-2 -- Disable
					end
					gas_timers[name].lastevent=GetGameTimeMilliseconds()
					if (gas_timers[name].params~=nil) then
						gas_timers[name].callback(name,gas_timers[name].params)
					else
						gas_timers[name].callback(name)
					end
				end
			end
		end
		zo_callLater(gas_tick, 5000) -- run again in 5000 ms
	end
end

local function gas_start()
	if(gas_ticking == nil or gas_ticking == false) then
		gas_ticking = true
		gas_tick()
	end
end

local function gas_clearGuildStats()
	gas_savedVariables.onlines = {}
end

local function gas_doit(guildIndex)
	local numGuilds = GetNumGuilds()
	local n = GetNumGuildMembers(GetGuildId(guildIndex))
	local i = 1
	local ts = GetTimeStamp()
	local gid = gas_guildNames[guildIndex]
	local theData = nil
	if gas_savedVariables.onlines == nil then
		gas_savedVariables.onlines = {}
	end
	if gas_savedVariables.onlines[ts] == nil then gas_savedVariables.onlines[ts] = {} end
	if gas_savedVariables.onlines[ts][gid] == nil then gas_savedVariables.onlines[ts][gid] = {} end
	--d("In gas_doit: guildIndex= " .. guildIndex .. ", n=" .. n .. ", ts=" .. ts .. ", gid=" .. gid)
	for i=1,n do
		local name,note,rankIndex,playerStatus,secsSinceLogoff = GetGuildMemberInfo(GetGuildId(guildIndex),i)
		--d("GuildMemberInfo: " .. name .. ", " .. note .. ", " .. rankIndex .. ", " .. playerStatus .. ", " .. secsSinceLogoff)
		if gas_savedVariables.onlines[ts][gid][name] == nil then gas_savedVariables.onlines[ts][gid][name] = {} end
		gas_savedVariables.onlines[ts][gid][name].rank = rankIndex
		gas_savedVariables.onlines[ts][gid][name].secsSinceLogoff = secsSinceLogoff
	end
end

function gas_doitAll(_)
	-- d("Doing it all")
	local atLeastOne = false
	local numGuilds = GetNumGuilds()
	for i = 1, numGuilds do
		local gid = gas_guildNames[i]
		if gas_savedVariables.guildsToLog ~= nil and gas_savedVariables.guildsToLog[gid] == true then
			--d("In gas_doitAll: numGuilds=" .. numGuilds .. ", gid=" .. gid .. ", gas_guildIndexes[gid]=" .. gas_guildIndexes[gid])
			gas_doit(gas_guildIndexes[gid])
			atLeastOne = true
		end
	end
	if atLeastOne == true then
		gas_yo()
		if gas_savedVariables.notify == true then
			d("Saved Guild Activity Stats.")
		end
	end
end

local function gas_initTimers()
	if gas_timers == nil then
		gas_timers={}
	end
	gas_start();
end

local function gas_OnAddOnLoaded(event, addonName)
	if addonName == gas_name then
		-- d("-------------------")
		-- d("In gas_OnAddOnLoaded")
		gas_initTimers()
		gas_savedVariables = ZO_SavedVars:NewAccountWide(gas_savedVarsName, 15, nil, gas_defaultVars)
		SLASH_COMMANDS["/gasclear"] = gas_clearGuildStats
		gas_updateGuildInfo()
		LAM:RegisterAddonPanel(addonName, gas_panelData)
		LAM:RegisterOptionControls(addonName, gas_optionsData)	
		gas_doitAll()
		gas_yo()
		gas_setTimer(gas_savedVariables.frequency, gas_doitAll)
		-- d("At end of gas_OnAddOnLoaded, gas_savedVariables = ")
		-- d(gas_savedVariables)
		-- d("-------------------")
		EVENT_MANAGER:UnregisterForEvent(gas_name, EVENT_ADD_ON_LOADED)
	end
end

EVENT_MANAGER:RegisterForEvent(gas_name, EVENT_ADD_ON_LOADED, gas_OnAddOnLoaded)
