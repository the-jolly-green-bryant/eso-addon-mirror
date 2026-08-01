--[[
	Currently auto complete doesn't show chat channels (/zone, /group, /guild1, etc.), because
	SlashCommandAutoComplete:GetAutoCompletionResults() from "esoui/ingame/slashcommands/slashcommandautocomplete.lua"
	traverses ZO_ChatSystem_GetChannelSwitchLookupTable() using ipairs(), but that table contains non-numeric keys that break the loop.
	Check g_switchLookup from "esoui/ingame/chatsystem/chatdata.lua" for more info about this table.
]]

-- Only show auto complete for guilds we are in.
local validGuilds = {}
for i = 1, GetNumGuilds() do
	validGuilds[i + CHAT_CHANNEL_GUILD_1 - 1]	= true
	validGuilds[i + CHAT_CHANNEL_OFFICER_1 - 1]	= true
end

local f = SlashCommandAutoComplete.GetAutoCompletionResults
SlashCommandAutoComplete.GetAutoCompletionResults = function(self, text)
    if #text < 3 then
        return
    end
    local startChar = text:sub(1, 1)
    if startChar ~= "/" and startChar ~= "]" then
        return
    end
    if text:find(" ", 1, true) then
        return
    end

    if next(self.possibleMatches) == nil then
        for command in pairs(SLASH_COMMANDS) do
            if #command > 0 then
                self.possibleMatches[command:lower()] = command
            end
        end

        if BRACKET_COMMANDS then
            for command in pairs(BRACKET_COMMANDS) do
                if #command > 0 then
                    self.possibleMatches[command:lower()] = command
                end
            end
        end

        self:AddCommandsToPossibleResults(ZO_REGIONCOMMANDS)
        self:AddCommandsToPossibleResults(ZO_CLIENTCOMMANDS)

		-- Here is the fix:
		local switchLookup = ZO_ChatSystem_GetChannelSwitchLookupTable()
		local channels = ZO_ChatSystem_GetChannelInfo()
		for id in pairs(channels) do -- channels have gaps
			local switch = switchLookup[id]
			if switch and #switch > 2 and (id < CHAT_CHANNEL_GUILD_1 or id > CHAT_CHANNEL_OFFICER_5 or validGuilds[id]) then
				self.possibleMatches[switch:lower()] = switch
			end
		end
		--[[ shorter alternative, but requires more checks, because "switchLookup" has more values than "channels"
		for k, v in pairs(switchLookup) do
			if type(k) == 'number' and type(v) == 'string' and #v > 2 and (k < CHAT_CHANNEL_GUILD_1 or k > CHAT_CHANNEL_OFFICER_5 or validGuilds[k]) then
				self.possibleMatches[v:lower()] = v
			end
		end
		]]
    end

    local results = GetTopMatchesByLevenshteinSubStringScore(self.possibleMatches, text, 2, self.maxResults)
    if results then
        return unpack(results)
    end
    return nil
end