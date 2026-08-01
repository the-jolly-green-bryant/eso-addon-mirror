local NAME = "AddonLoadMonitor"

local Results = { }

local prevName = "[Start]"
local prevTime = GetGameTimeMilliseconds()

local function Stopwatch( _, name )
	local currentTime = GetGameTimeMilliseconds()
	table.insert(Results, string.format("%4d  %s", currentTime - prevTime, prevName))
	prevName = name
	prevTime = currentTime
end

EVENT_MANAGER:RegisterForEvent(NAME, EVENT_ADD_ON_LOADED, Stopwatch)

EVENT_MANAGER:RegisterForEvent(NAME, EVENT_PLAYER_ACTIVATED, function( )
	EVENT_MANAGER:UnregisterForEvent(NAME, EVENT_PLAYER_ACTIVATED)
	Stopwatch()
	LoadMonitorResults = Results
	d("/script d(LoadMonitorResults) to see addon load performance results")
end)
