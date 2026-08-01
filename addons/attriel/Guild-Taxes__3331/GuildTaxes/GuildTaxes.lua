GuildTaxes = {}

GuildTaxes.name = "GuildTaxes"
GuildTaxes.version = "1.0.12"

local LSC = LibSlashCommander
local em = GetEventManager()

function GuildTaxes:count(input)
	local imps = {}
	-- Break up the input
	-- This is lua's "split" function
	string.gsub(input..' ', '(.-) ', function (a) table.insert(imps, a) end)
    local listener = LibHistoire:CreateGuildHistoryListener(GetGuildId(tonumber(imps[1])), GUILD_HISTORY_STORE)
    d(GetGuildName(GetGuildId(tonumber(imps[1]))))

    local endTime = os.time() - (tonumber(os.date("%S"))) - (tonumber(os.date("%M"))*60) - (tonumber(os.date("%H"))*3600)
    local startTime = endTime - (86400*tonumber(imps[2]))
    listener:SetTimeFrame(startTime, endTime)
    local lastDate = "20210901";
    local collected = {}
    listener:SetNextEventCallback(function(eventType, eventId, eventTime, param1, param2, param3, param4, param5, param6)
	if (eventType == GUILD_EVENT_ITEM_SOLD) then
		-- param6 is tax
		if (collected[param1] == nil) then
			collected[param1] = 0
		end
		collected[param1] = collected[param1] + param6
	end
    end)
    listener:SetIterationCompletedCallback(function()
	    -- This is for an attempt at a consolidated view across multiple days
	    local values = {}
	    for k,v in pairs(collected) do
		    table.insert(values, {k, v})
	    end
	    table.sort(values, function (a, b) return a[2] < b[2] end);
	    for _, p in ipairs(values) do 
		   d(p[1] .. ' ' .. p[2])
	    end
	    collected = {}
	    d("DONE")
    end)
    listener:Start()
end

function GuildTaxes:Initialize()

	LSC:Register("/taxes", function(input) GuildTaxes:count(input) end , "/taxes 1 2 -- Check bank deposits for guild1, across days2 (/taxes 1 1 for guild 1, 1 day)");
end

function GuildTaxes.OnAddOnLoaded(event, addonName) 
	if addonName == GuildTaxes.name then
		em:UnregisterForEvent(GuildTaxes.name, EVENT_ADD_ON_LOADED);
		GuildTaxes:Initialize();
	end
end


em:RegisterForEvent(GuildTaxes.name, EVENT_ADD_ON_LOADED, GuildTaxes.OnAddOnLoaded)

