TrialCC = {}
local TrialCC = TrialCC

TrialCC.name = "TrialCompletionCount"
TrialCC.version = "1.5"

TrialCC.accountWideDefaults = {
    accountWide = false,
}

TrialCC.defaults = {
    counts = {},
	started = {},
}

local ZONE_IDS = {
    HRC = 636,
    AA  = 638,
    SO  = 639,
    MOL = 725,
    HOF = 975,
    AS  = 1000,
    CR  = 1051,
    SS  = 1121,
    KA  = 1196,
    RG  = 1263,
	DSR = 1344,
	SE  = 1427,
	LC	= 1478,
	OC  = 1548,
}

local function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

function TrialCC.DoReport(args)
    -- Reset if parameter is given
    if args == "reset" then
        CHAT_ROUTER:AddSystemMessage("All recorded trial completions have been reset.")
        TrialCC.SV.counts = {}
        return
    end

    CHAT_ROUTER:AddSystemMessage(zo_strformat("=== Recorded Trial Runs for <<1>> ===", GetDisplayName()))

    -- Get a copy of the saved variables
    local counts = {}
    ZO_ShallowTableCopy(TrialCC.SV.counts, counts)
	local started = {}
	ZO_ShallowTableCopy(TrialCC.SV.started, started)
	
    -- Get the total number of all recorded runs
    local totalruns = 0

    for _, runs in pairs(TrialCC.SV.counts) do
        totalruns = totalruns + runs
    end
	
	local totalstarted = 0
	for _, runs in pairs(TrialCC.SV.started) do
        totalstarted = totalstarted + runs
    end
    
    -- Loop trough all records, order them and print them to chat.
    local i = 1
    local p = ""
    for k, v in spairs(counts, function(t, a, b) return t[b] < t[a] end) do
        if args == "p" then
            p = string.format(" - %.2f%%", (v / totalruns) * 100)
		elseif args == "s" then
			s = string.format(" (%s) ", started[k] or 0)
        end
        
        -- Index. Trialname: Runs (Started) - Percentage%
        CHAT_ROUTER:AddSystemMessage(zo_strformat("<<1>>. <<2>>: <<3>><<4>><<5>>", i, GetZoneNameById(k), v, s, p))
        
        i = i + 1
    end
	if args == "s" then
		totalstarted = string.format(" (%s)", totalstarted)
	else
		totalstarted = ""
	end
    CHAT_ROUTER:AddSystemMessage(zo_strformat("Total completed runs: <<1>><<2>>", totalruns, totalstarted))
end

local function OnTrialComplete(eventCode, trialName, score, totalTime)
    -- Loop trough all trial zones to get the one we're in
    for _, zoneId in pairs(ZONE_IDS) do
        if string.find(trialName, GetZoneNameById(zoneId)) then
            -- Increment completion counter
            if not TrialCC.SV.counts[zoneId] then TrialCC.SV.counts[zoneId] = 0 end
            TrialCC.SV.counts[zoneId] = TrialCC.SV.counts[zoneId] + 1
        end
    end
end

local function OnTrialBegin(eventCode, trialName, weekly)
	   for _, zoneId in pairs(ZONE_IDS) do
        if string.find(trialName, GetZoneNameById(zoneId)) then
            -- Increment started counter
            if not TrialCC.SV.started[zoneId] then
				TrialCC.SV.started[zoneId] = 0
			end
            TrialCC.SV.started[zoneId] = TrialCC.SV.started[zoneId] + 1
        end
    end
end

local function OnAddonLoaded(event, addonName)
    if addonName ~= TrialCC.name then return end
    EVENT_MANAGER:UnregisterForEvent(TrialCC.name, EVENT_ADD_ON_LOADED) 

    TrialCC.SV = ZO_SavedVars:NewAccountWide("TrialCCSavedVariables", 1.0, nil, TrialCC.defaults)
    
    SLASH_COMMANDS["/trialcompletioncount"] = TrialCC.DoReport
    
    EVENT_MANAGER:RegisterForEvent(TrialCC.name, EVENT_RAID_TRIAL_STARTED, OnTrialBegin)
	EVENT_MANAGER:RegisterForEvent(TrialCC.name, EVENT_RAID_TRIAL_COMPLETE, OnTrialComplete)
	
	-- Simple migration for 1.5 started tracking:
	for _, zoneId in pairs(ZONE_IDS) do
		if TrialCC.SV.counts[zoneId] ~= 0 then
			if not TrialCC.SV.started[zoneId] then
				-- Set started to equal completed, so you have at least a dataset that makes sense.
				TrialCC.SV.started[zoneId] = TrialCC.SV.counts[zoneId]
			end
		end
	end
end
EVENT_MANAGER:RegisterForEvent(TrialCC.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)