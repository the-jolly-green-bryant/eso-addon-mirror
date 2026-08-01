local ADDON_NAME = "CyrillicChatFilterRevived"
local ADDON_DISPLAY_NAME = "Cyrillic Chat Filter"

local SETTING_CHANNELS = 1
local SETTING_ACCOUNT_WIDE = 2

local DEFAULTS =
{
	[SETTING_CHANNELS] = { },
	[SETTING_ACCOUNT_WIDE] = true,
}

local CHANNEL_INFO = ZO_ChatSystem_GetChannelInfo()
for channelId, channelData in pairs(CHANNEL_INFO) do
	if channelData.playerLinkable then
		if not (not channelData.channelLinkable and channelData.supportCSIcon and channelData.switches == nil) then
			DEFAULTS[SETTING_CHANNELS][channelId] = true
		end
	end
end


local function OnAddOnLoaded(_, addOnName)
	if addOnName == ADDON_NAME then
		EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

		local zo_strfind, zo_strlower = zo_strfind, zo_strlower

		local savedVars = LibSavedVars:NewAccountWide("CyrillicChatFilterRevived_Account", DEFAULTS):AddCharacterSettingsToggle("CyrillicChatFilterRevived_Character")

		local LibDebugLogger = LibDebugLogger
		local logger = LibDebugLogger(ADDON_NAME)
		local subLogger = logger:Create("Hidden messages")

		local function IsChatChannelFiltered(channelId)
			return savedVars[SETTING_CHANNELS][channelId] == true
		end

		local CYRILLIC_CHARS = { "б", "г", "д", "ж", "з", "и", "й", "к", "л", "н", "п", "У", "Ф", "ц", "ч", "ш", "щ", "ъ", "ы", "э", "ю", "я", "Є" }
		local function DoesStringContainsCyrillicCharacter(str)
			str = zo_strlower(str)
			for _, character in ipairs(CYRILLIC_CHARS) do
				if zo_strfind(str, zo_strlower(character)) then
					return true, character
				end
			end
			return false, nil
		end

		local displayName = GetDisplayName()
		local function IsSelfMessage(fromDisplayName)
			return displayName == fromDisplayName
		end

		local function OnFormatAndAddChatMessage(self, eventKey, ...)
			if eventKey == EVENT_CHAT_MESSAGE_CHANNEL then
				local messageType, _, rawMessageText, _, fromDisplayName = select(1, ...)
				if IsChatChannelFiltered(messageType) and not IsSelfMessage(fromDisplayName) then
					local doesStringContainsCyrillicCharacter, matchedCharacter = DoesStringContainsCyrillicCharacter(rawMessageText)
					if doesStringContainsCyrillicCharacter then
						subLogger:Info("[%s] matchedCharacter: %s, message: %s", fromDisplayName, matchedCharacter, rawMessageText)
						return true
					end
				end
			end
			return false
		end
		ZO_PreHook(CHAT_ROUTER, "FormatAndAddChatMessage", OnFormatAndAddChatMessage)


		-- Settings
		-----------
		local LibHarvensAddonSettings = LibHarvensAddonSettings
		local settings = LibHarvensAddonSettings:AddAddon(ADDON_DISPLAY_NAME, { allowDefaults = true })

		settings:AddSetting {
			type = LibHarvensAddonSettings.ST_SECTION,
			label = GetString(SI_AUDIO_OPTIONS_GENERAL)
		}
		settings:AddSetting {
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = GetString(SI_LSV_ACCOUNT_WIDE),
			tooltip = GetString(SI_LSV_ACCOUNT_WIDE_TT),
			getFunction = function()
				savedVars:LoadAllSavedVars()
				return savedVars:GetAccountSavedVarsActive()
			end,
			setFunction = function(value)
				savedVars:LoadAllSavedVars()
				savedVars:SetAccountSavedVarsActive(value)
			end,
			default = savedVars.__dataSource.defaultToAccount,
		}
		settings:AddSetting {
			type = LibHarvensAddonSettings.ST_SECTION,
			label = GetString(SI_CHAT_OPTIONS_FILTERS),
		}
		settings:AddSetting {
			type = LibHarvensAddonSettings.ST_LABEL,
			label = GetString(SI_CYRILLIC_CHAT_FILTER_SETTINGS_DESC),
		}

		local sortedChannels = { }
		for channelId, _ in pairs(DEFAULTS[SETTING_CHANNELS]) do
			local channelData = CHANNEL_INFO[channelId]
			if channelData then
				local data =
				{
					channelId = channelId,
					name = channelData.name,
					dynamicName = channelData.dynamicName,
					switches = channelData.switches,
				}
				table.insert(sortedChannels, data)
			end
		end
		table.sort(sortedChannels, function(left, right)
			return left.channelId < right.channelId
		end)
		for _, channelData in ipairs(sortedChannels) do
			settings:AddSetting {
				type = LibHarvensAddonSettings.ST_CHECKBOX,
				label = channelData.dynamicName and channelData.switches or channelData.name or tostring(channelData.channelId),
				getFunction = function() return savedVars[SETTING_CHANNELS][channelData.channelId] end,
				setFunction = function(value) savedVars[SETTING_CHANNELS][channelData.channelId] = value end,
				default = DEFAULTS[SETTING_CHANNELS][channelData.channelId],
			}
		end
	end
end
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

--[[ maybe we can use this in the future
	local CYRILLIC_CHARS = { "Б", "б", "Г", "г", "Д", "д", "Ж", "ж", "З", "з", "И", "и", "Й", "й", "К", "к", "Л", "л", "Н", "н", "П", "п", "У", "Ф", "ф", "Ц", "ц", "Ч", "ч", "Ш", "ш", "Щ", "щ", "Ъ", "ъ", "Ы", "ы", "Э", "э", "Ю", "ю", "Я", "я", "Ђ", "ђ" ,"Ѓ" ,"ѓ", "Є", "є", "Љ", "љ", "Њ", "њ", "Ћ", "ћ", "Ќ", "ќ", "Ѝ", "ѝ", "Ў", "ў", "Џ", "џ" }

	local function UTF8Sub(s, i, j)
		i = utf8.offset(s, i)
		j = utf8.offset(s, j + 1) - 1
		return string.sub(s, i, j)
	end

	local function DoesStringContainsCyrillicCharacter(str)
		for i = 1, ZoUTF8StringLength(str) do
			if ZO_IsElementInNumericallyIndexedTable(CYRILLIC_CHARS, UTF8Sub(str:lower(), i, i)) then
				return true
			end
		end
	end
]]