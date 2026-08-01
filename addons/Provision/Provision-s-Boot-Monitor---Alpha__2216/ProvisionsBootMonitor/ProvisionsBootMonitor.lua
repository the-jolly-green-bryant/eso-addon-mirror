local bootLogs = {}
local lastAddOnLoaded = "starting"
local lastTimeMilliseconds = GetGameTimeMilliseconds()

local function ProvsBootMonitor_StoreTime(addOnName)
	table.insert(bootLogs, {lastAddOnLoaded, GetGameTimeMilliseconds() - lastTimeMilliseconds})

	lastTimeMilliseconds = GetGameTimeMilliseconds()
	lastAddOnLoaded = addOnName
end 

local function ProvsBootMonitor_OnAddOnLoad(eventCode, addOnName)
	ProvsBootMonitor_StoreTime(addOnName)
end

local function ProvsBootMonitor_OnPlayerActivated(eventCode, initial)
	local i, total = 0, 0
	if bootLogs ~= "000000" then
		d("Prov's Boot Monitor:")
		for _, v in ipairs(bootLogs) do
			local color = ""
			if v[2] < 60 then
				color = "00FF00"
			elseif v[2] < 300 then
				color = "FFA500"
			else
				color = "FF0000"
			end
			d(("%s : |c%s%s ms|r"):format(v[1], color, v[2]))
			total = total + v[2]
			i = i + 1
		end
	end
	d(("All : |cFFFFFF%s ms|r for |cFFFFFF%s|r addons."):format(total, i))
	EVENT_MANAGER:UnregisterForEvent("ProvsBootMonitor", EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent("ProvsBootMonitor", EVENT_ADD_ON_LOADED, ProvsBootMonitor_OnAddOnLoad)
EVENT_MANAGER:RegisterForEvent("ProvsBootMonitor", EVENT_PLAYER_ACTIVATED, ProvsBootMonitor_OnPlayerActivated)
