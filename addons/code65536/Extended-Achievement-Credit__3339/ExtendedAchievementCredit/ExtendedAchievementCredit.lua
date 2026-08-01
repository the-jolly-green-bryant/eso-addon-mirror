local LCCC = LibCodesCommonCode
local LMAA = LibMultiAccountAchievements
local LAA = LibAchievementsArchive


--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------

local OFFSET_TOP = 8
local OFFSET_INTERNAL = 4 -- Matches the offset in ExtendedAchievementCredit.xml
local CHAR_ID = GetCurrentCharacterId()
local UPDATE_THROTTLE = 500 -- 0.5s

ExtendedAchievementCredit = {
	name = "ExtendedAchievementCredit",

	defaults = {
		datesFirst = false,
		hideTimes = false,
		historical = 2,
		charSpecific = 3,
		chatUpdate = false,
	},
}
local EAC = ExtendedAchievementCredit

local function OnAddOnLoaded( eventCode, addonName )
	if (addonName ~= EAC.name) then return end

	EVENT_MANAGER:UnregisterForEvent(EAC.name, EVENT_ADD_ON_LOADED)

	EAC.vars = ZO_SavedVars:NewAccountWide("ExtendedAchievementCreditSavedVariables", 1, nil, EAC.defaults, nil, "$InstallationWide")

	EAC.pool = ZO_ControlPool:New("EAC_Extension")
	EAC.pool:SetCustomFactoryBehavior(function( control )
		control.elements = {
			header = control:GetNamedChild("Header"),
			names = control:GetNamedChild("Names"),
			namesEx = control:GetNamedChild("NamesEx"),
			dates = control:GetNamedChild("Dates"),
			servers = control:GetNamedChild("Servers"),
			accounts = control:GetNamedChild("Accounts"),
			links = control:GetNamedChild("Links"),
		}
	end)

	SecurePostHook(Achievement, "PerformExpandedLayout", EAC.PerformExpandedLayout)
	SecurePostHook(Achievement, "ReleaseSharedControls", EAC.ReleaseSharedControls)

	EAC.ToggleChat(EAC.vars.chatUpdate)

	LCCC.RunAfterInitialLoadscreen(EAC.RegisterSettingsPanel)
end

if (LMAA or LAA) then
	EVENT_MANAGER:RegisterForEvent(EAC.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
end


--------------------------------------------------------------------------------
-- Utility Functions
--------------------------------------------------------------------------------

local function GetHistoricalCharacterIds( )
	-- 1: Current character
	-- 2: Current account
	-- 3: All accounts and servers
	if (EAC.vars.historical == 1) then
		if (LAA.GetCharacterInformation(CHAR_ID)) then
			return { CHAR_ID }
		else
			return { }
		end
	else
		return LAA.GetValidCharacterIds(EAC.vars.historical == 2)
	end
end

local function GetMultiCharacters( )
	-- 1: Current server
	-- 2: Current account
	-- 3: All accounts and servers
	local server, account
	if (EAC.vars.charSpecific == 1) then
		server = true
	elseif (EAC.vars.charSpecific == 2) then
		account = true
	end
	return LMAA.GetCharacters(server, account)
end

local function HighlightText( text, shouldHighlight )
	if (shouldHighlight) then
		return string.format("|c%s%s|r", ZO_SECOND_SELECTED_TEXT:ToHex(), text)
	else
		return text
	end
end

local function DisambiguateNames( main, subset, nIdx, sIdx )
	local results = { }
	local count = { }
	for _, entry in ipairs(main) do
		local name = entry[nIdx]
		count[name] = 1 + (count[name] or 0)
	end
	for _, entry in ipairs(subset) do
		local name = entry[nIdx]
		table.insert(results, (count[name] == 1) and name or string.format("%s (%s)", name, entry[sIdx]))
	end
	return results
end

local function GetAchievementMaxTierId( achievementId )
	while true do
		local nextAchievementId = GetNextAchievementInLine(achievementId)
		if (nextAchievementId ~= 0 and nextAchievementId ~= achievementId) then
			achievementId = nextAchievementId
		else
			return achievementId
		end
	end
end

local function GetAchievementCombinedRequirements( achievementId )
	local totalRequired = 0
	for i = 1, GetAchievementNumCriteria(achievementId) do
		totalRequired = totalRequired + select(3, GetAchievementCriterion(achievementId, i))
	end
	return totalRequired
end

local function CompareTimestamps( a, b )
	return a.timestamp < b.timestamp
end

local function SetText( control, text )
	control:SetText(text)
	control:SetHidden(false)
end


--------------------------------------------------------------------------------
-- Overrides
--------------------------------------------------------------------------------

-- /esoui/ingame/achievements/keyboard/achievements.lua
-- Achievement:PerformExpandedLayout
function EAC.PerformExpandedLayout( self )
	local achievementId = GetAchievementMaxTierId(self.achievementId)

	-- Using calculations compatible with those found in Achievement:PerformExpandedLayout
	local footerPad = self.title:GetTop() - self.control:GetTop()
	local yOffset = self.control:GetHeight() - footerPad

	-- Control acquisition
	local sectionIndex = 1
	self.eacControls = self.eacControls or { }

	local InitializeSection = function( )
		-- Acquire control
		local control, key = self.eacControls[sectionIndex]
		if (not control) then
			control, key = EAC.pool:AcquireObject()
			control.key = key
			self.eacControls[sectionIndex] = control
		end
		sectionIndex = sectionIndex + 1

		-- Initialize control
		for _, element in pairs(control.elements) do
			element:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
			element:SetHidden(true)
		end
		control:SetParent(self.control)
		control:SetAnchor(TOPRIGHT, self.control, TOPRIGHT, 0, yOffset + OFFSET_TOP)
		control:SetAnchor(LEFT, self.description, LEFT, 0, 0, ANCHOR_CONSTRAINS_X)
		control:SetHidden(false)

		return control.elements
	end

	local dateFormat = EAC.vars.hideTimes and "%Y-%m-%d" or "%Y-%m-%d %H:%M"
	local isAwA = GetAchievementPersistenceLevel(achievementId) ~= ACHIEVEMENT_PERSISTENCE_CHARACTER

	local owners = LMAA and (isAwA and LMAA.GetAccounts() or GetMultiCharacters()) or { }
	local earned = { }
	local unearned = { }

	if (#owners > 0) then
		for _, owner in ipairs(owners) do
			local timestamp = LMAA.GetAchievementTimestamp(isAwA and owner or owner[1], achievementId)
			if (timestamp > 0) then
				owner.timestamp = timestamp
				table.insert(earned, owner)
			else
				table.insert(unearned, owner)
			end
		end
		table.sort(earned, CompareTimestamps)
	end


	----------------------------------------------------------------------------
	-- Earned
	----------------------------------------------------------------------------

	if (#earned > 0) then
		local elements = InitializeSection()

		SetText(elements.header, string.format("%s |c%s(%d)|r", GetString(SI_EAC_EARNED), ZO_DEFAULT_TEXT:ToHex(), #earned))
		local textHeight

		if (isAwA) then
			local names = { }
			local dates = { }
			local servers = { }

			for _, owner in ipairs(earned) do
				table.insert(names, owner[2])
				table.insert(dates, os.date(dateFormat, owner.timestamp))
				table.insert(servers, owner[1])
			end

			-- Handle the column swap option
			local namesControl, datesControl = elements.names, elements.dates
			if (EAC.vars.datesFirst) then
				namesControl, datesControl = elements.dates, elements.names
			end

			SetText(namesControl, table.concat(names, "\n"))
			SetText(datesControl, table.concat(dates, "\n"))
			if (#LMAA.GetServers() > 1) then
				SetText(elements.servers, table.concat(servers, "\n"))
			end

			textHeight = elements.names:GetTextHeight()
		else
			SetText(elements.namesEx, table.concat(DisambiguateNames(owners, earned, 4, 2), ", "))

			textHeight = elements.namesEx:GetTextHeight()
		end

		yOffset = yOffset + elements.header:GetTextHeight() + textHeight + OFFSET_TOP + OFFSET_INTERNAL
	end


	----------------------------------------------------------------------------
	-- Unearned
	----------------------------------------------------------------------------

	if (#unearned > 0) then
		local elements = InitializeSection()

		SetText(elements.header, string.format("%s |c%s(%d)|r", GetString(SI_EAC_UNEARNED), ZO_DEFAULT_TEXT:ToHex(), #unearned))
		local textHeight

		local req = GetAchievementCombinedRequirements(achievementId)
		if (isAwA and req > 1) then
			local totalCredit = 0
			local names = { }
			local dates = { }
			local servers = { }
			local links = { }

			for _, owner in pairs(unearned) do
				local credit = 0
				for i = 1, GetAchievementNumCriteria(achievementId) do
					credit = credit + select(2, LMAA.GetAchievementCriterion(owner, achievementId, i))
				end
				totalCredit = totalCredit + credit

				table.insert(names, owner[2])
				table.insert(dates, string.format("%d / %d", credit, req))
				table.insert(servers, owner[1])
				table.insert(links, LMAA.GetAchievementLink(owner, achievementId, LINK_STYLE_BRACKETS))
			end

			if (totalCredit > 0) then
				elements.dates:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

				SetText(elements.names, table.concat(names, "\n"))
				SetText(elements.dates, table.concat(dates, "\n"))
				if (#LMAA.GetServers() > 1) then
					SetText(elements.servers, table.concat(servers, "\n"))
				end
				SetText(elements.links, table.concat(links, "\n"))

				textHeight = elements.names:GetTextHeight()
			end
		end

		if (not textHeight) then
			SetText(elements.namesEx, table.concat(isAwA and DisambiguateNames(owners, unearned, 2, 1) or DisambiguateNames(owners, unearned, 4, 2), ", "))

			textHeight = elements.namesEx:GetTextHeight()
		end

		yOffset = yOffset + elements.header:GetTextHeight() + textHeight + OFFSET_TOP + OFFSET_INTERNAL
	end


	----------------------------------------------------------------------------
	-- Historical Credit
	----------------------------------------------------------------------------

	if (isAwA and LAA and EAC.vars.historical ~= 0 and achievementId <= LAA.ArchivedGetMaxAchievementId()) then
		local results = { }

		-- Find the characters that have completed this achievement
		for _, charId in ipairs(GetHistoricalCharacterIds()) do
			if (LAA.ArchivedIsAchievementComplete(charId, achievementId)) then
				local server, accountName, characterName = LAA.GetCharacterInformation(charId)
				table.insert(results, {
					name = characterName,
					timestamp = LAA.ArchivedGetAchievementTimestamp(charId, achievementId),
					server = server,
					account = accountName,
					highlight = charId == CHAR_ID,
				})
			end
		end
		table.sort(results, CompareTimestamps)

		-- Handle partial progress for the current character
		if (not LAA.ArchivedIsAchievementComplete(CHAR_ID, achievementId)) then
			local server, accountName, characterName = LAA.GetCharacterInformation(CHAR_ID)
			if (server) then
				-- For the purposes of our calculation, each criteria is normalized to weigh equally
				local completed = 0
				local required = LAA.ArchivedGetAchievementNumCriteria(achievementId)
				local totalRequired = 0

				for i = 1, required do
					local _, numCompleted, numRequired = LAA.ArchivedGetAchievementCriterion(CHAR_ID, achievementId, i)
					completed = completed + numCompleted / numRequired
					totalRequired = totalRequired + numRequired
				end

				if (completed > 0 and totalRequired > 1) then
					table.insert(results, {
						name = characterName,
						partial = completed / required,
						server = server,
						account = accountName,
						highlight = true,
					})
				end
			end
		end

		-- Add to the achievement UI
		if (#results > 0) then
			local elements = InitializeSection()

			SetText(elements.header, string.format("%s |c%s(%d)|r", GetString(SI_EAC_HISTORICAL), ZO_DEFAULT_TEXT:ToHex(), #results))

			local names = { }
			local dates = { }
			local servers = { }
			local accounts = { }

			for _, credit in ipairs(results) do
				table.insert(names, HighlightText(credit.name, credit.highlight))
				table.insert(dates, HighlightText(credit.timestamp and os.date(dateFormat, credit.timestamp) or string.format("%d%%", 100 * credit.partial), credit.highlight))
				table.insert(servers, credit.highlight and " " or credit.server)
				table.insert(accounts, credit.highlight and " " or credit.account)
			end

			-- Handle the column swap option
			local namesControl, datesControl = elements.names, elements.dates
			if (EAC.vars.datesFirst) then
				namesControl, datesControl = elements.dates, elements.names
			end

			SetText(namesControl, table.concat(names, "\n"))
			SetText(datesControl, table.concat(dates, "\n"))

			-- Show the server and account information only for the expanded scope
			if (EAC.vars.historical == 3) then
				SetText(elements.servers, table.concat(servers, "\n"))
				SetText(elements.accounts, table.concat(accounts, "\n"))
			end

			yOffset = yOffset + elements.header:GetTextHeight() + elements.names:GetTextHeight() + OFFSET_TOP + OFFSET_INTERNAL
		end
	end

	self.control:SetHeight(yOffset + footerPad)
end

-- /esoui/ingame/achievements/keyboard/achievements.lua
-- Achievement:ReleaseSharedControls
function EAC.ReleaseSharedControls( self )
	if (self.eacControls) then
		for _, control in ipairs(self.eacControls) do
			control:SetHidden(true)
			EAC.pool:ReleaseObject(control.key)
		end
		self.eacControls = nil
	end
end


--------------------------------------------------------------------------------
-- Chat
--------------------------------------------------------------------------------

local UpdateIndex = 0
local UpdateQueue = { }
local PreviousUpdates = { }

local function ProcessUpdateQueue( )
	local ids = { }
	for id in pairs(UpdateQueue) do
		table.insert(ids, id)
	end
	table.sort(ids, function(a, b) return UpdateQueue[a] < UpdateQueue[b] end)
	UpdateQueue = { }

	for _, id in ipairs(ids) do
		local req = GetAchievementCombinedRequirements(id)
		if (req > 1) then
			local credit = 0
			for i = 1, GetAchievementNumCriteria(id) do
				credit = credit + select(2, GetAchievementCriterion(id, i))
			end
			if (PreviousUpdates[id] ~= credit) then
				PreviousUpdates[id] = credit
				CHAT_ROUTER:AddSystemMessage(string.format("[%s] %s: %d / %d", GetString(SI_GROUPFINDERPLAYSTYLE8), zo_iconTextFormat(select(4, GetAchievementInfo(id)), 20, 20, GetAchievementLink(id, LINK_STYLE_DEFAULT), false), credit, req))
			end
		end
	end
end

local function OnAchievementUpdated( _, id )
	if (GetAchievementMaxTierId(id) ~= id) then return end
	UpdateIndex = UpdateIndex + 1
	UpdateQueue[id] = UpdateIndex

	EVENT_MANAGER:UnregisterForUpdate(EAC.name)
	EVENT_MANAGER:RegisterForUpdate(EAC.name, UPDATE_THROTTLE, function( )
		EVENT_MANAGER:UnregisterForUpdate(EAC.name)
		ProcessUpdateQueue()
	end)
end

local function OnAchievementAwarded( _, _, _, id )
	if (GetAchievementMaxTierId(id) ~= id) then return end
	UpdateQueue[id] = nil
	CHAT_ROUTER:AddSystemMessage(string.format("[%s] %s", GetString(SI_ACHIEVEMENT_AWARDED_CENTER_SCREEN), zo_iconTextFormat(select(4, GetAchievementInfo(id)), 20, 20, GetAchievementLink(id, LINK_STYLE_DEFAULT), false)))
end

function EAC.ToggleChat( enabled )
	if (enabled) then
		EVENT_MANAGER:RegisterForEvent(EAC.name, EVENT_ACHIEVEMENT_UPDATED, OnAchievementUpdated)
		EVENT_MANAGER:RegisterForEvent(EAC.name, EVENT_ACHIEVEMENT_AWARDED, OnAchievementAwarded)
	else
		EVENT_MANAGER:UnregisterForEvent(EAC.name, EVENT_ACHIEVEMENT_UPDATED)
		EVENT_MANAGER:UnregisterForEvent(EAC.name, EVENT_ACHIEVEMENT_AWARDED)
	end
end


--------------------------------------------------------------------------------
-- Settings
--------------------------------------------------------------------------------

function EAC.RegisterSettingsPanel( )
	local LAM = LibAddonMenu2

	if (LAM) then
		local panelId = "EACSettings"

		EAC.settingsPanel = LAM:RegisterAddonPanel(panelId, {
			type = "panel",
			name = GetString(SI_EAC_TITLE),
			version = LCCC.FormatVersion(LCCC.GetAddOnVersion(EAC.name)),
			author = "@code65536",
			website = "https://www.esoui.com/downloads/info3339.html",
			donation = "https://www.esoui.com/downloads/info3339.html#donate",
			registerForRefresh = true,
		})

		local hist = { }
		local histLabels = { }
		for i = 0, 3 do
			table.insert(hist, i)
			table.insert(histLabels, GetString("SI_EAC_HIST_MODE", i))
		end

		local charSp = { }
		local charSpLabels = { }
		for i = 1, 3 do
			table.insert(charSp, i)
			table.insert(charSpLabels, GetString("SI_EAC_CHAR_MODE", i))
		end

		LAM:RegisterOptionControls(panelId, {
			--------------------------------------------------------------------
			{
				type = "checkbox",
				name = SI_EAC_DATES_FIRST,
				getFunc = function() return EAC.vars.datesFirst end,
				setFunc = function(enabled) EAC.vars.datesFirst = enabled end,
			},
			--------------------
			{
				type = "checkbox",
				name = SI_EAC_HIDE_TIMES,
				getFunc = function() return EAC.vars.hideTimes end,
				setFunc = function(enabled) EAC.vars.hideTimes = enabled end,
			},
			--------------------
			{
				type = "dropdown",
				name = SI_EAC_HIST_MODES,
				choices = histLabels,
				choicesValues = hist,
				getFunc = function() return EAC.vars.historical end,
				setFunc = function(mode) EAC.vars.historical = mode end,
				disabled = function() return not LAA end,
			},
			--------------------
			{
				type = "dropdown",
				name = SI_EAC_CHAR_MODES,
				choices = charSpLabels,
				choicesValues = charSp,
				getFunc = function() return EAC.vars.charSpecific end,
				setFunc = function(mode) EAC.vars.charSpecific = mode end,
				disabled = function() return not LMAA end,
			},
			--------------------
			{
				type = "checkbox",
				name = SI_EAC_CHAT_UPDATE,
				getFunc = function() return EAC.vars.chatUpdate end,
				setFunc = function( enabled )
					EAC.vars.chatUpdate = enabled
					EAC.ToggleChat(enabled)
				end,
			},
		})
	end
end
