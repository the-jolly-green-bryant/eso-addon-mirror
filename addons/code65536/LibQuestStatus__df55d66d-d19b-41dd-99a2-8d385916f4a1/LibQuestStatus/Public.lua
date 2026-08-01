local LCCC = LibCodesCommonCode
local Internal = LibQuestStatusInternal
local Public = LibQuestStatus


--------------------------------------------------------------------------------
-- Constants
--------------------------------------------------------------------------------

-- Callback events
Public.EVENT_QUEST_STATUS_UPDATED = 1


--------------------------------------------------------------------------------
-- Base-Game Analogues
--------------------------------------------------------------------------------

local REPEATABLE_OVERRIDES = {
	[5087] = QUEST_REPEAT_WEEKLY, -- Hel Ra Citadel
	[5102] = QUEST_REPEAT_WEEKLY, -- Aetherian Archive
	[5352] = QUEST_REPEAT_WEEKLY, -- Maw of Lorkhaj
	[5743] = QUEST_REPEAT_WEEKLY, -- Sanctum Ophidia
	[5894] = QUEST_REPEAT_WEEKLY, -- Halls of Fabrication
	[6090] = QUEST_REPEAT_WEEKLY, -- Asylum Sanctorium
	[6192] = QUEST_REPEAT_WEEKLY, -- Cloudrest
	[6353] = QUEST_REPEAT_WEEKLY, -- Sunspire
	[6503] = QUEST_REPEAT_WEEKLY, -- Kyne's Aegis
	[6654] = QUEST_REPEAT_WEEKLY, -- Rockgrove
	[6783] = QUEST_REPEAT_WEEKLY, -- Dreadsail Reef
	[7031] = QUEST_REPEAT_WEEKLY, -- Sanity's Edge
	[7212] = QUEST_REPEAT_WEEKLY, -- Lucent Citadel
	[7306] = QUEST_REPEAT_WEEKLY, -- Ossein Cage
}

function Public.GetQuestRepeatableType( questId )
	return REPEATABLE_OVERRIDES[questId] or GetQuestRepeatableType(questId)
end

function Public.HasQuestOnCharacter( questId, server, charId )
	server = server or Internal.server
	charId = charId or Internal.charId
	if (server == Internal.server and charId == Internal.charId) then
		-- Return the result directly from the API
		return HasQuest(questId)
	else
		local active = Internal.GetActiveQuests(server, charId)
		return active[questId or 0] ~= nil
	end
end

function Public.HasCompletedQuestOnCharacter( questId, server, charId )
	server = server or Internal.server
	charId = charId or Internal.charId
	if (server == Internal.server and charId == Internal.charId) then
		-- Return the result directly from the API
		return HasCompletedQuest(questId)
	else
		return Internal.ReadQuestCompletion(server, charId, questId)
	end
end


--------------------------------------------------------------------------------
-- General
--------------------------------------------------------------------------------

function Public.GetActiveQuestsForCharacter( server, charId )
	server = server or Internal.server
	charId = charId or Internal.charId
	if (server == Internal.server and charId == Internal.charId) then
		-- Return the result directly from the API
		local results = { }
		for i = 1, GetNumJournalQuests() do
			results[GetJournalQuestId(i)] = {
				conditionType = select(8, GetJournalQuestConditionInfo(i, 1, 1)),
				completed = GetJournalQuestIsComplete(i),
			}
		end
		return results
	else
		return Internal.GetActiveQuests(server, charId)
	end
end

function Public.IsRepeatableQuestOnCooldownForCharacter( questId, server, charId )
	server = server or Internal.server
	charId = charId or Internal.charId
	return Internal.IsQuestOnCooldown(server, charId, questId)
end

function Public.GetServerAndCharacterList( alwaysIncludeCurrentCharacter )
	local results = { }
	for _, server in ipairs(LCCC.GetSortedKeys(Internal.data, Internal.server)) do
		local characters = LCCC.GetSortedKeys(Internal.data[server], Internal.charId, LCCC.CompareCharIds)
		if (#characters > 0) then
			for i, charId in ipairs(characters) do
				local data = Internal.data[server][charId]
				characters[i] = {
					charId = charId,
					account = data.account,
					name = data.name,
					timestamp = data.timestamp,
				}
			end
			table.insert(results, { server = server, characters = characters })
		end
	end
	if (alwaysIncludeCurrentCharacter) then
		local currentCharacter = {
			charId = Internal.charId,
			account = Internal.userId,
			name = Internal.charName,
			timestamp = GetTimeStamp(),
		}
		if (not results[1] or results[1].server ~= Internal.server) then
			table.insert(results, 1, { server = Internal.server, characters = { currentCharacter } })
		elseif (results[1].characters[1].charId ~= Internal.charId) then
			table.insert(results[1].characters, 1, currentCharacter)
		end
	end
	return results
end

Public.IsDataAvailableForCharacter = Internal.DoesCharacterExist

Public.GetMaxQuestId = Internal.GetMaxQuestId


--------------------------------------------------------------------------------
-- Callbacks
--------------------------------------------------------------------------------

Internal.callbacks = {
	[Public.EVENT_QUEST_STATUS_UPDATED] = { },
}

function Public.RegisterForCallback( name, eventCode, callback )
	if (type(name) == "string" and type(eventCode) == "number" and type(callback) == "function" and Internal.callbacks[eventCode]) then
		Internal.callbacks[eventCode][name] = callback
		return true
	end
	return false
end

function Public.UnregisterForCallback( name, eventCode )
	if (type(name) == "string" and type(eventCode) == "number" and Internal.callbacks[eventCode]) then
		Internal.callbacks[eventCode][name] = nil
		return true
	end
	return false
end

function Internal.FireCallbacks( eventCode, ... )
	for _, callback in pairs(Internal.callbacks[eventCode]) do
		callback(eventCode, ...)
	end
end
