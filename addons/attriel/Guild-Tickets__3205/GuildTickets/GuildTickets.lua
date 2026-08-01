GuildTickets = {}

GuildTickets.name = "GuildTickets"
GuildTickets.version = "1.0.12"

local LSC = LibSlashCommander
local em = GetEventManager()

function GuildTickets:count(input)
	local imps = {}
	-- Break up the input
	-- This is lua's "split" function
	string.gsub(input..' ', '(.-) ', function (a) table.insert(imps, a) end)
    local listener = LibHistoire:CreateGuildHistoryListener(GetGuildId(tonumber(imps[1])), GUILD_HISTORY_BANK)
    d(GetGuildName(GetGuildId(tonumber(imps[1]))))

    local endTime = os.time() - (tonumber(os.date("%S"))) - (tonumber(os.date("%M"))*60) - (tonumber(os.date("%H"))*3600)
    local startTime = endTime - (86400*tonumber(imps[2]))
    listener:SetTimeFrame(startTime, endTime)
    local lastDate = "20210901";
    local collected = {}
    listener:SetNextEventCallback(function(eventType, eventId, eventTime, param1, param2, param3, param4, param5, param6)
	if (eventType == GUILD_EVENT_BANKGOLD_ADDED) then
		if (param2 % tonumber(imps[3])) == 0 then
			local newDate = os.date("%Y%m%d", eventTime)
			if (lastDate ~= newDate) then
				lastDate = newDate
				d(lastDate)
			end
			local tix = param2 / tonumber(imps[3]);
			d(param1 .. ' ' .. tix)
			if (collected[param1] == nil) then
				collected[param1] = {}
			end
			table.insert(collected[param1], {lastDate, param2})
		end
	end
    end)
    listener:SetIterationCompletedCallback(function()
	    d("DONE")
	    -- This is for an attempt at a consolidated view across multiple days
	    -- d(dump(collected))
    end)
    listener:Start()
end

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function GuildTickets:Initialize()

	LSC:Register("/tickets", function(input) GuildTickets:count(input) end , "/tickets 1 2 3 -- Check bank deposits for guild1, across days2, that are a multiple of 3 (/tickets 1 1 1000 for guild 1, 1 day, 1000)");
end

function GuildTickets.OnAddOnLoaded(event, addonName) 
	if addonName == GuildTickets.name then
		em:UnregisterForEvent(GuildTickets.name, EVENT_ADD_ON_LOADED);
		GuildTickets:Initialize();
	end
end


em:RegisterForEvent(GuildTickets.name, EVENT_ADD_ON_LOADED, GuildTickets.OnAddOnLoaded)

