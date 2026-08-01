--[[
Title:   Event Registration and Handling
Version: 1.1.0
Author:  @Skotharr-do [PC/EU]
--]]

local function IsValidChatChannel(channelType)
	return channelType ~= CHAT_CHANNEL_SYSTEM and
		   channelType ~= CHAT_CHANNEL_WHISPER_SENT and
		   channelType ~= CHAT_CHANNEL_MONSTER_EMOTE and
		   channelType ~= CHAT_CHANNEL_MONSTER_SAY and
		   channelType ~= CHAT_CHANNEL_MONSTER_WHISPER and
		   channelType ~= CHAT_CHANNEL_MONSTER_YELL
end

local function RequestCharacterName(rawNameHandle, channelType)
	-- messages from @Someone (guild / whispers)
	if IsDecoratedDisplayName(rawNameHandle) then
		-- Guild / Officer chat
		if channelType >= CHAT_CHANNEL_GUILD_1 and channelType <= CHAT_CHANNEL_OFFICER_5 then
			-- get guild ID based on channel id
			local guildId = GetGuildId((channelType - CHAT_CHANNEL_GUILD_1) % 5 + 1) -- 5 guilds, offset of 1
			local guildMemberIndex = GetGuildMemberIndexFromDisplayName(guildId, rawNameHandle)
			-- void first return parameter and use second as raw handle
			local void, guildMemberRawNameHandle = GetGuildMemberCharacterInfo(guildId, guildMemberIndex)
			return zo_strformat(SI_UNIT_NAME, guildMemberRawNameHandle)

		-- Wispers with @, we can't guess character name for those
		else
			return nil
		end

	-- Zone, Party, Whispers with character name
	else
		return zo_strformat(SI_UNIT_NAME, rawNameHandle)
	end
end

local function FindKeywordAtBeginning(message)
	if message:find(IC.Keywords.Default.STRING) == 1 then
		return IC.Keywords.Default
	end
	if message:find(IC.Keywords.Alternative.STRING) == 1 then
		return IC.Keywords.Alternative
	end
	return nil
end

local function UpdateWindowsVisibility()
	IC.ReticleWindow.UpdateVisibilityAndContent()
	IC.EditWindow.UpdateVisibility()
end

local function OnSLASH_COMMAND(message)
	local trimmedMessage = zo_strtrim(message)
	local spaceStartIndex, spaceEndIndex = trimmedMessage:find('%s+')
	local parameter = nil
	local command
	-- if parameter exists
	if spaceStartIndex ~= nil then
		command = trimmedMessage:sub(1, spaceStartIndex - 1)
		parameter = trimmedMessage:sub(spaceEndIndex + 1)
	else
		command = trimmedMessage
	end

	IC.ExecuteCommand(trimmedMessage, command, parameter)
end

local function OnChatMessage(event, channelType, rawNameHandle, message, isCustomerService, accountName)
	if not IsValidChatChannel(channelType) then
		return
	end

	local keyword = FindKeywordAtBeginning(message)
	if keyword == nil then
		return
	end

	local characterName = RequestCharacterName(rawNameHandle, channelType)
	if characterName == nil then
		CHAT_SYSTEM:AddMessage(zo_strformat(GetString(SI_INCHARACTER_CHAT_GET_CHARACTER_NAME_FAILED), accountName))
		return
	end

	IC.AccountWide.WriteCharacter(accountName, characterName, zo_strtrim(message:sub(keyword.CHARACTER_COUNT + 1)))
	if IC.Utility.IsCurrentCharacter(characterName) then
		IC.EditWindow.UpdateTitle()
	end
	IC.ReticleWindow.UpdateVisibilityAndContent(characterName)
end

local function OnReticleTargetChanged(event)
	IC.ReticleWindow.UpdateVisibilityAndContent()
end

local function OnReticleHiddenUpdate(event, hidden)
	IC.UI.reticleHidden = hidden
	IC.ReticleWindow.UpdateVisibilityAndContent()
end

local function OnPlayerActivated(event, initial)
	IC.ReticleWindow.UpdateVisibilityAndContent()
end

local function OnOverlayMenuToggle(oldState, newState)
	if newState == SCENE_HIDDEN and SCENE_MANAGER:GetNextScene():GetName() ~= 'hudui' then
		IC.UI.menuVisible = true
		UpdateWindowsVisibility()
	elseif newState == SCENE_SHOWING then
		IC.UI.menuVisible = false
		UpdateWindowsVisibility()
	end
end

local function OnOutfitRenamed(event, response, index)
	if response == SET_OUTFIT_NAME_RESULT_SUCCESS and IC.EditWindow.IsOpen() then
		IC.EditWindow.ChangeOutfitDropDownEntryName(index, GetOutfitName(index))
	end
end

local function OnOutfitEquipped(event, response)
	if response == EQUIP_OUTFIT_RESULT_SUCCESS then
		local outfitIndex = GetEquippedOutfitIndex()
		if outfitIndex == nil then
			outfitIndex = 0
		end
		local description = IC.CharacterWide.FindDescriptionByOutfitIndex(outfitIndex)
		if description ~= nil then
			IC.EditWindow.SelectDescriptionDropDownEntry(description.name, true)
		end
	end
end

function IC.RegisterForEvents()
	-- event when slash command is being used
	SLASH_COMMANDS[IC.Addon.SLASH_COMMAND] = OnSLASH_COMMAND
	-- event when any chat message arrives
	EVENT_MANAGER:RegisterForEvent(IC.Addon.NAME, EVENT_CHAT_MESSAGE_CHANNEL, OnChatMessage)
	-- event when reticle changes content; not being fired when the target moves away on its own!
	EVENT_MANAGER:RegisterForEvent(IC.Addon.NAME, EVENT_RETICLE_TARGET_CHANGED, OnReticleTargetChanged)
	-- event when reticle focus is being toggled by player or menus
	EVENT_MANAGER:RegisterForEvent(IC.Addon.NAME, EVENT_RETICLE_HIDDEN_UPDATE, OnReticleHiddenUpdate)
	-- event when player loaded (after teleporting, entering houses, logging in, etc)
	EVENT_MANAGER:RegisterForEvent(IC.Addon.NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
	-- event when overlay menu is being toggled
	SCENE_MANAGER:GetScene('hud'):RegisterCallback('StateChange', OnOverlayMenuToggle)
	-- event when outfit name changed
	EVENT_MANAGER:RegisterForEvent(IC.Addon.NAME, EVENT_OUTFIT_RENAME_RESPONSE, OnOutfitRenamed)
	-- event when outfit was equipped
	EVENT_MANAGER:RegisterForEvent(IC.Addon.NAME, EVENT_OUTFIT_EQUIP_RESPONSE, OnOutfitEquipped)
end