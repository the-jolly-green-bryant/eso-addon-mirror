DolgubonsGuildReorder = DolgubonsGuildReorder or {}

local hasAlreadyReordered = false

local reorderChat

if false then --pChat then


	local GeneralChatChannels = 
	{
		SI_CHANNEL_SWITCH_GUILD_1,
		SI_CHANNEL_SWITCH_GUILD_2,
		SI_CHANNEL_SWITCH_GUILD_3,
		SI_CHANNEL_SWITCH_GUILD_4,
		SI_CHANNEL_SWITCH_GUILD_5,
	}
	local OfficerChatChannels = 
	{
		SI_CHANNEL_SWITCH_OFFICER_1,
		SI_CHANNEL_SWITCH_OFFICER_2,
		SI_CHANNEL_SWITCH_OFFICER_3,
		SI_CHANNEL_SWITCH_OFFICER_4,
		SI_CHANNEL_SWITCH_OFFICER_5
	}

	-- Reorder the chat channels
	function reorderChat()
		local newGuildOrder = DolgubonsGuildReorder.savedVarsAccountWide.guildOrder
		local newChatStrings = 
		{
			general = {}, 
			officer = {},
		}
		for i = 1, 5 do
			newChatStrings.general[i] = {GeneralChatChannels[i], GetString(GeneralChatChannels[i])}
			newChatStrings.officer[i] = {OfficerChatChannels[i], GetString(OfficerChatChannels[i])}
		end


		for i = 1, 5 do
		    SafeAddString(newChatStrings.general[i][1], newChatStrings.general[newGuildOrder[i]][2], 100)
		    SafeAddString(newChatStrings.officer[i][1], newChatStrings.officer[newGuildOrder[i]][2], 100)
		end

	end

else

	local chats=
	{
		{'/o1','/officer1','/g1','/guild1'},
		{'/o2','/officer2','/g2','/guild2'},
		{'/o3','/officer3','/g3','/guild3'},
		{'/o4','/officer4','/g4','/guild4'},
		{'/o5','/officer5','/g5','/guild5'},
	}

	-- Reorder the chat channels
	function reorderChat()
		local newGuildOrder = DolgubonsGuildReorder.savedVarsAccountWide.guildOrder
		local generalTables = {}
		local officerTables = {}
		for i = 1, 5 do
			generalTables[i] = {CHAT_SYSTEM.switchLookup[chats[i][3]]}
			officerTables[i] = {CHAT_SYSTEM.switchLookup[chats[i][1]]}
		end


		for i = 1, 5 do
			CHAT_SYSTEM.switchLookup[chats[newGuildOrder[i]][1]] = officerTables[i][1]
			CHAT_SYSTEM.switchLookup[chats[newGuildOrder[i]][2]] = officerTables[i][1]
			CHAT_SYSTEM.switchLookup[chats[newGuildOrder[i]][3]] = generalTables[i][1]
			CHAT_SYSTEM.switchLookup[chats[newGuildOrder[i]][4]] = generalTables[i][1]
		end
	end
end

local hasReorderedDropdown = false

function reorderGuildSelectorDropdown()
	if not hasReorderedDropdown then
		local tempTable = {}
		for i = 1, GetNumGuilds() do
			tempTable[i] = GUILD_SELECTOR.comboBox.m_sortedItems[DolgubonsGuildReorder.keyOrder[i]]
		end
		for i = 1, #tempTable do
			local guildAlliance = GetGuildAlliance(tempTable[i].guildId)
			
			tempTable[i].name = zo_strformat(SI_GUILD_SELECTOR_FORMAT, GetAllianceSymbolIcon(guildAlliance), i, tempTable[i].selectedText)
			GUILD_SELECTOR.comboBox.m_sortedItems[i] =  tempTable[i]
		end
		hasReorderedDropdown = true
	end
end

-- Reorder the guild window 
local function reorderGuildWindow()

	local newGuildOrder = DolgubonsGuildReorder.savedVarsAccountWide.guildOrder

	-- Overwrite the original guild selector

	local originalSelector = GUILD_SELECTOR.SelectGuildByIndex
	GUILD_SELECTOR.SelectGuildByIndex =  function(self, guildId)
	d(DolgubonsGuildReorder.keyOrder[guildId])
		return originalSelector(self, DolgubonsGuildReorder.keyOrder[guildId])
	end
end


function DolgubonsGuildReorder.setupReorder()
	if hasAlreadyReordered then return end
	hasAlreadyReordered = true

	-- reorderGuildWindow()
	reorderChat()
	EVENT_MANAGER:RegisterForEvent("guildReorderDropdown", EVENT_PLAYER_ACTIVATED, reorderGuildSelectorDropdown)
end