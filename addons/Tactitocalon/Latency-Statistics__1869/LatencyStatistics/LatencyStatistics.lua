LatencyStatistics = LatencyStatistics or {}

local ADDON_NAME = "LatencyStatistics"
local ADDON_VERSION = 1

local UPDATE_INTERVAL = 250

local totalLatency = 0
local totalCount = 0
local highestLatency = 0
local lowestLatency = -1

local BUCKET_RANGES = { 25, 50, 75, 100, 125, 150, 175, 200, 225, 250, 275, 300, 325, 350, 375, 400, 425, 450, 475, 500, 1000, 2000, 5000, 10000, 100000 }
local bucketCounts = {}

function LatencyStatistics:Initialize()
	LatencyStatistics.Reset()
	SLASH_COMMANDS["/latencystats"] = LatencyStatistics.OnCommandLatencyStats
	
	EVENT_MANAGER:RegisterForUpdate("RegisterTest", UPDATE_INTERVAL, LatencyStatistics.OnUpdateInterval)
end
 
function LatencyStatistics.Reset()
	totalLatency = 0
	totalCount = 0
	highestLatency = 0
	lowestLatency = -1
	
	for i = 1, #BUCKET_RANGES do
		bucketCounts[i] = 0
	end
end 

function LatencyStatistics.OnUpdateInterval()
	local latency = GetLatency()
	totalCount = totalCount + 1
	totalLatency = totalLatency + latency
	if (latency > highestLatency) then highestLatency = latency end
	if (latency < lowestLatency or lowestLatency == -1) then lowestLatency = latency end
	
	for i = 1, #BUCKET_RANGES do
		if (latency < BUCKET_RANGES[i]) then
			if (i == 1 or latency >= BUCKET_RANGES[i - 1]) then
				bucketCounts[i] = bucketCounts[i] + 1
				break
			end
		end
	end
end
 
function LatencyStatistics.OnCommandLatencyStats(commandData)
	if (commandData == "reset") then
		LatencyStatistics.Reset()
		CHAT_SYSTEM:AddMessage("Latency statistics reset.")
		return
	end

	if (totalCount == 0) then 
		CHAT_SYSTEM:AddMessage("No latency statistics recorded yet.")
		return
	end
	
	local averageLatency = totalLatency / totalCount;
	
	CHAT_SYSTEM:AddMessage("Latency statistics for the last " .. zo_round((UPDATE_INTERVAL / 1000) * totalCount) .. " seconds:")
	CHAT_SYSTEM:AddMessage("Average latency: |cffffff" .. zo_round(averageLatency) .. "|r")
	CHAT_SYSTEM:AddMessage("Lowest recorded latency: |cffffff" .. (lowestLatency) .. "|r")
	CHAT_SYSTEM:AddMessage("Highest recorded latency: |cffffff" .. (highestLatency) .. "|r")
	
	for i = 1, #BUCKET_RANGES do
		local averageBucketPercentage = (bucketCounts[i] / totalCount) * 100
		
		local startMs = 0
		if (i ~= 1) then
			startMs = BUCKET_RANGES[i - 1]
		end
		
		local endMs = BUCKET_RANGES[i]
		
		if (bucketCounts[i] > 0) then
			CHAT_SYSTEM:AddMessage(startMs .. " - " .. endMs .. " ms: |cffffff" .. zo_round(averageBucketPercentage) .. "% (" .. zo_round((UPDATE_INTERVAL / 1000) * bucketCounts[i]) .. " seconds)|r")
		end
	end
end

function LatencyStatistics.OnAddOnLoaded(event, addonName)
	if (addonName == ADDON_NAME) then
		LatencyStatistics:Initialize()
		EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
	end
end
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, LatencyStatistics.OnAddOnLoaded)