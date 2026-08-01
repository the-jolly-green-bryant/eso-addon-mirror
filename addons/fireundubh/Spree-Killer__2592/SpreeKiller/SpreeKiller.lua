local SpreeKiller = {
	Name = 'SpreeKiller',
	Author = 'fireundubh',
	Version = '1.0.1',
	SettingsVersion = '0.1.1'
}

SpreeKiller.Default = {
	['AutoAcceptEnabled'] = true,
	['AutoCompleteEnabled'] = true,
	['AuridonSpree'] = true,
	['GoldCoastSpree'] = true,
	['GrahtwoodSpree'] = true,
	['GreenshadeSpree'] = true,
	['MalabalTorSpree'] = true,
	['ReapersMarchSpree'] = true,
}

local LAM = LibAddonMenu2

local LOGGER
if LibDebugLogger then
	LOGGER = LibDebugLogger.Create('SpreeKiller')
else
	local function noop() end
	LOGGER = setmetatable({}, { __index = function() return noop end })
end

-- little hack to get the current interactable name
local lastInteractableName
ZO_PreHook(FISHING_MANAGER, 'StartInteraction', function()
	local _, name = GetGameCameraInteractableActionInfo()
	lastInteractableName = name
end)

-- removes leading and trailing whitespace from a string
local function StrTrim(asString)
   return asString:match'^()%s*$' and '' or asString:match'^%s*(.*%S)'
end

-- check if trimmed string starts with substring, case insensitive
local function StrStartsWith(asHaystack, asNeedle)
	asHaystack = StrTrim(asHaystack):lower()
	asNeedle = asNeedle:lower()
	return asHaystack:find('^' .. asNeedle) ~= nil
end

-- check if quest name matches any spree contract name
local function IsSpreeContract(asQuestName)
	return asQuestName == GetString(SI_SPREE_KILLER_QUEST_AD)
		or asQuestName == GetString(SI_SPREE_KILLER_QUEST_GC)
		or asQuestName == GetString(SI_SPREE_KILLER_QUEST_GW)
		or asQuestName == GetString(SI_SPREE_KILLER_QUEST_GS)
		or asQuestName == GetString(SI_SPREE_KILLER_QUEST_MT)
		or asQuestName == GetString(SI_SPREE_KILLER_QUEST_RM)
end

-- check if any spree contract is in quest journal
local function IsSpreeContractInQuestJournal()
	for i = 1, MAX_JOURNAL_QUESTS do
		if IsValidQuestIndex(i) and IsSpreeContract(GetJournalQuestName(i)) then
			return true
		end
	end
	return false
end

-- check if the spree contract can be accepted
local function CanAcceptSpreeContract(asBodyText)
	if StrStartsWith(asBodyText, GetString(SI_SPREE_KILLER_TEXT_AD)) then
		return SpreeKiller.SavedVars.AuridonSpree
	end

	if StrStartsWith(asBodyText, GetString(SI_SPREE_KILLER_TEXT_GC)) then
		return SpreeKiller.SavedVars.GoldCoastSpree
	end

	if StrStartsWith(asBodyText, GetString(SI_SPREE_KILLER_TEXT_GW)) then
		return SpreeKiller.SavedVars.GrahtwoodSpree
	end

	if StrStartsWith(asBodyText, GetString(SI_SPREE_KILLER_TEXT_GS)) then
		return SpreeKiller.SavedVars.GreenshadeSpree
	end

	if StrStartsWith(asBodyText, GetString(SI_SPREE_KILLER_TEXT_MT)) then
		return SpreeKiller.SavedVars.MalabalTorSpree
	end

	if StrStartsWith(asBodyText, GetString(SI_SPREE_KILLER_TEXT_RM)) then
		return SpreeKiller.SavedVars.ReapersMarchSpree
	end
end

-- override the chatter option function, so only the Dark Brotherhood Spree Contracts can be started
local function OverwritePopulateChatterOption(interaction)
	local PopulateChatterOption = interaction.PopulateChatterOption

	interaction.PopulateChatterOption = function(self, index, fun, txt, type, ...)
		-- check if the last interactable name was a valid target
		if lastInteractableName ~= GetString(SI_SPREE_KILLER_NAME_NPC)
		and lastInteractableName ~= GetString(SI_SPREE_KILLER_NAME_BOOK)
		and GetZoneId(GetUnitZoneIndex('player')) ~= 826
		then
			return PopulateChatterOption(self, index, fun, txt, type, ...)
		end

		-- automatically complete quest
		if lastInteractableName == GetString(SI_SPREE_KILLER_NAME_NPC) and IsSpreeContractInQuestJournal() then
			-- handle option to disable auto complete
			if type == CHATTER_GOODBYE or not SpreeKiller.SavedVars.AutoCompleteEnabled then
				return PopulateChatterOption(self, index, fun, txt, type, ...)
			end

			-- select the "Complete Quest" option
			if type == CHATTER_COMPLETE_QUEST then
				CompleteQuest()
				return
			end

			-- select the "I completed" option
			if txt ~= nil and txt ~= '' then
				SelectChatterOption(index)
				return
			end

			return PopulateChatterOption(self, index, fun, txt, type, ...)
		end

		-- automatically accept quest
		if lastInteractableName == GetString(SI_SPREE_KILLER_NAME_BOOK) then
			-- handle option to disable auto accept
			if not SpreeKiller.SavedVars.AutoAcceptEnabled then
				return PopulateChatterOption(self, index, fun, txt, type, ...)
			end

			-- disable auto accept when all sprees are disabled
			if (not SpreeKiller.SavedVars.AuridonSpree
			and not SpreeKiller.SavedVars.GoldCoastSpree
			and not SpreeKiller.SavedVars.GrahtwoodSpree
			and not SpreeKiller.SavedVars.GreenshadeSpree
			and not SpreeKiller.SavedVars.MalabalTorSpree
			and not SpreeKiller.SavedVars.ReapersMarchSpree)
			then
				return PopulateChatterOption(self, index, fun, txt, type, ...)
			end

			local sTargetAreaBodyText = self.control:GetNamedChild('TargetAreaBodyText'):GetText()

			-- this guard should never run under normal circumstances
			if sTargetAreaBodyText == nil or sTargetAreaBodyText == '' then
				return PopulateChatterOption(self, index, fun, txt, type, ...)
			end

			-- strip double quotes from start and end of string
			local sUnquotedBodyText = string.sub(sTargetAreaBodyText, 2, string.len(sTargetAreaBodyText) - 1)

			-- check if the greeting page is open
			if StrStartsWith(sUnquotedBodyText, GetString(SI_SPREE_KILLER_TEXT_HELLO)) then
				-- close book if player already has a contract
				if IsSpreeContractInQuestJournal() then
					interaction:CloseChatter()
				end

				-- flip the page
				if type ~= CHATTER_GOODBYE then
					SelectChatterOption(index)
					return
				end
			else
				-- try to automatically accept the contract
				if CanAcceptSpreeContract(sUnquotedBodyText) then
					if type == CHATTER_GENERIC_ACCEPT then
						AcceptOfferedQuest()
						return
					end
				else
					-- automatically close the book
					interaction:CloseChatter()
					return
				end
			end
		end

		return PopulateChatterOption(self, index, fun, txt, type, ...)
	end
end

local function SettingsUpdate(setname, setval)
	SpreeKiller.SavedVars[setname] = setval
end

local panelData = {
	type = 'panel',
	name = 'Spree Killer',
	displayName = 'Spree Killer',
	author = SpreeKiller.Author,
	version = SpreeKiller.Version,
	slashCommand = '/spreekiller',
	registerForRefresh = true,
	registerForDefaults = true,
}

local spreeTooltip = GetString(SI_SPREE_KILLER_TOOLTIP_TEMPLATE)

local optionsTable = {
	{
		type    = 'checkbox',
		name    = GetString(SI_SPREE_KILLER_AUTO_ACCEPT),
		tooltip = GetString(SI_SPREE_KILLER_TOOLTIP_AUTO_ACCEPT),
		getFunc = function() return SpreeKiller.SavedVars.AutoAcceptEnabled end,
		setFunc = function(value) SettingsUpdate('AutoAcceptEnabled', value) end,
		default = true,
	},
	{
		type    = 'checkbox',
		name    = GetString(SI_SPREE_KILLER_AUTO_COMPLETE),
		tooltip = GetString(SI_SPREE_KILLER_TOOLTIP_AUTO_COMPLETE),
		getFunc = function() return SpreeKiller.SavedVars.AutoCompleteEnabled end,
		setFunc = function(value) SettingsUpdate('AutoCompleteEnabled', value) end,
		default = true,
	},
	{
		type    = 'checkbox',
		name    = GetString(SI_SPREE_KILLER_QUEST_AD),
		tooltip = string.format(spreeTooltip, GetString(SI_SPREE_KILLER_QUEST_AD)),
		getFunc = function() return SpreeKiller.SavedVars.AuridonSpree end,
		setFunc = function(value) SettingsUpdate('AuridonSpree', value) end,
		default = true,
	},
	{
		type    = 'checkbox',
		name    = GetString(SI_SPREE_KILLER_QUEST_GC),
		tooltip = string.format(spreeTooltip, GetString(SI_SPREE_KILLER_QUEST_GC)),
		getFunc = function() return SpreeKiller.SavedVars.GoldCoastSpree end,
		setFunc = function(value) SettingsUpdate('GoldCoastSpree', value) end,
		default = true,
	},
	{
		type    = 'checkbox',
		name    = GetString(SI_SPREE_KILLER_QUEST_GW),
		tooltip = string.format(spreeTooltip, GetString(SI_SPREE_KILLER_QUEST_GW)),
		getFunc = function() return SpreeKiller.SavedVars.GrahtwoodSpree end,
		setFunc = function(value) SettingsUpdate('GrahtwoodSpree', value) end,
		default = true,
	},
	{
		type    = 'checkbox',
		name    = GetString(SI_SPREE_KILLER_QUEST_GS),
		tooltip = string.format(spreeTooltip, GetString(SI_SPREE_KILLER_QUEST_GS)),
		getFunc = function() return SpreeKiller.SavedVars.GreenshadeSpree end,
		setFunc = function(value) SettingsUpdate('GreenshadeSpree', value) end,
		default = true,
	},
	{
		type    = 'checkbox',
		name    = GetString(SI_SPREE_KILLER_QUEST_MT),
		tooltip = string.format(spreeTooltip, GetString(SI_SPREE_KILLER_QUEST_MT)),
		getFunc = function() return SpreeKiller.SavedVars.MalabalTorSpree end,
		setFunc = function(value) SettingsUpdate('MalabalTorSpree', value) end,
		default = true,
	},
	{
		type    = 'checkbox',
		name    = GetString(SI_SPREE_KILLER_QUEST_RM),
		tooltip = string.format(spreeTooltip, GetString(SI_SPREE_KILLER_QUEST_RM)),
		getFunc = function() return SpreeKiller.SavedVars.ReapersMarchSpree end,
		setFunc = function(value) SettingsUpdate('ReapersMarchSpree', value) end,
		default = true,
	},
}

local function OnAddOnLoaded(event, addonName)
	if addonName == SpreeKiller.Name then
		SpreeKiller.SavedVars = ZO_SavedVars:NewAccountWide(
			'SpreeKillerVars',
			SpreeKiller.SettingsVersion,
			nil,
			SpreeKiller.Default
		)

		LAM:RegisterAddonPanel(SpreeKiller.Name, panelData)
		LAM:RegisterOptionControls(SpreeKiller.Name, optionsTable)

		EVENT_MANAGER:UnregisterForEvent(SpreeKiller.Name, EVENT_ADD_ON_LOADED)

		OverwritePopulateChatterOption(GAMEPAD_INTERACTION)
		OverwritePopulateChatterOption(INTERACTION) -- keyboard
	end
end

EVENT_MANAGER:RegisterForEvent(SpreeKiller.Name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
