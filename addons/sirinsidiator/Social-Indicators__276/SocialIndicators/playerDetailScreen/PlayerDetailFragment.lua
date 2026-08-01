local PlayerDetailFragment = ZO_Object:Subclass()
SocialIndicators.PlayerDetailFragment = PlayerDetailFragment

local COLUMN_LEFT = 1
local COLUMN_RIGHT = 2
local COLUMN_BOTH = 3

local SECTION_PLAYER = 1
local SECTION_CHARACTER = 2

local NOTE_ICON_SIZE = 20
local ICON_SIZE = 24

function PlayerDetailFragment:New(db)
	local index = ZO_Object.New(self)
	index:Initialize(db)
	return index
end

function PlayerDetailFragment:SetName(type, name)
	local data = self.sectionData[type]
	data.nameControl:SetText(name)
end

function PlayerDetailFragment:AddSection(type, title)
	local data = self.sectionData[type]
	local section, key = self.sectionPool:AcquireObject()
	section:SetParent(data.parent)
	section:SetAnchor(TOPLEFT, data.lastSection, BOTTOMLEFT)
	section.text:SetText(title)
	section:SetHidden(false)
	data.lastSection = section
	data.activeKeys[#data.activeKeys + 1] = key
	return section
end

function PlayerDetailFragment:ClearSections(type)
	local data = self.sectionData[type]
	if(data) then
		data.lastSection = data.nameControl
		local keys = data.activeKeys
		for i = #keys, 1, -1 do
			self.sectionPool:ReleaseObject(keys[i])
			keys[i] = nil
		end
	end
end

local function CreateSectionData(parent)
	local nameControl = parent:GetNamedChild("Name")
	return {
		parent = parent,
		nameControl = nameControl,
		lastSection = nameControl,
		activeKeys = {},
	}
end

function PlayerDetailFragment:Initialize(db)
	self.db = db
	self.control = SocialIndicatorsPlayerDetailScreen
	self.sectionData = {}
	self.sectionData[SECTION_PLAYER] = CreateSectionData(self.control:GetNamedChild("PlayerDetails"))
	self.sectionData[SECTION_CHARACTER] = CreateSectionData(self.control:GetNamedChild("CharacterDetails"))
	self.fragment = ZO_FadeSceneFragment:New(self.control, nil, 0)

	local function SetNote(entry, note)
		local noteIcon = entry.noteIcon
		noteIcon:SetHidden(note == "")
		entry.note = note
	end

	local function EntryFactory(pool)
		local control = CreateControlFromVirtual("$(parent)Entry", self.control, "SocialIndicatorsPlayerDetailEntry", pool:GetNextControlId())
		control.SetNote = SetNote
		return control
	end

	local function EntryResetFunction(control)
		control:SetHidden(true)
		control:SetNote("")
		control:SetParent(self.control)
		control:ClearAnchors()
		control:SetWidth(275)
		control.value:ClearAnchors()
		control.value:SetAnchor(RIGHT)
	end

	self.entryPool = ZO_ObjectPool:New(EntryFactory, EntryResetFunction)

	local function AddEntry(section, label, value, column)
		local entry, key = section.entryPool:AcquireObject()
		entry:SetParent(section)
		entry.label:SetText(label)
		entry.value:SetText(value)
		if(column == COLUMN_RIGHT) then
			entry:SetAnchor(TOPRIGHT, section.lastEntryRight, BOTTOMRIGHT)
			section.lastEntryRight = entry
		elseif(column == COLUMN_LEFT) then
			entry:SetAnchor(TOPLEFT, section.lastEntryLeft, BOTTOMLEFT)
			section.lastEntryLeft = entry
		else -- COLUMN_BOTH
			local anchorTarget = section.lastEntryLeft
			if(anchorTarget ~= section.lastEntryRight) then
				local _, _, _, leftY = anchorTarget:GetScreenRect()
				local _, _, _, rightY = section.lastEntryRight:GetScreenRect()
				if(leftY < rightY) then anchorTarget = section.lastEntryRight end
			end
			entry:SetWidth(600)
			entry:SetAnchor(TOPLEFT, anchorTarget, BOTTOMLEFT)
			entry.value:ClearAnchors()
			entry.value:SetAnchor(LEFT, nil, nil, 300)
			section.lastEntryLeft = entry
			section.lastEntryRight = entry
		end
		entry:SetHidden(false)
		section.activeKeys[#section.activeKeys + 1] = key
		return entry
	end

	local function ClearEntries(section)
		local pool = section.entryPool
		local keys = section.activeKeys
		for i = #keys, 1, -1 do
			pool:ReleaseObject(keys[i])
			keys[i] = nil
		end
		local divider = section:GetNamedChild("Divider")
		section.lastEntryLeft = divider
		section.lastEntryRight = divider
	end

	local function SectionFactory(pool)
		local control = CreateControlFromVirtual("$(parent)Section", self.control, "SocialIndicatorsPlayerDetailSection", pool:GetNextControlId())

		control.entryPool = self.entryPool
		control.activeKeys = {}
		control.AddEntry = AddEntry
		control.ClearEntries = ClearEntries
		control:ClearEntries()

		control.text = control:GetNamedChild("DividerText")
		return control
	end

	local function SectionResetFunction(control)
		control:SetHidden(true)
		control:SetParent(self.control)
		control:ClearEntries()
		control:ClearAnchors()
	end

	self.sectionPool = ZO_ObjectPool:New(SectionFactory, SectionResetFunction)
end

function PlayerDetailFragment:SetPlayer(player)
	self.currentPlayer = player
	self:UpdatePlayer()
end

function PlayerDetailFragment:SetCharacter(character)
	self.currentCharacter = character
	self:UpdateCharacter()
end

local function FormatTimeStampAsTimeAgo(timestamp)
	return ZO_FormatDurationAgo(GetTimeStamp() - timestamp)
end

local function FormatTimeStampAsDateTime(timestamp)
	return ""
end

function PlayerDetailFragment:UpdatePlayer()
	if(not self.fragment:IsShowing()) then return end
	local player = self.currentPlayer
	assert(player ~= nil)

	self:SetName(SECTION_PLAYER, player.displayName)
	self:ClearSections(SECTION_PLAYER)

	local general = self:AddSection(SECTION_PLAYER, "General")
	general:AddEntry("Times Seen", player.timesSeen, COLUMN_LEFT)
	general:AddEntry("Last Seen", FormatTimeStampAsTimeAgo(player.lastSeen), COLUMN_RIGHT)

	local lastMet = player.lastMet
	if(lastMet > 0) then
		general:AddEntry("Times Met", player.timesMet, COLUMN_LEFT)
		general:AddEntry("Last Met", FormatTimeStampAsTimeAgo(lastMet), COLUMN_RIGHT)
	end

	if(player:HasEconomicData()) then
		local economy = self:AddSection(SECTION_PLAYER, "Economy")
		economy:AddEntry("Mails Received", player.mailsReceived, COLUMN_LEFT)
		economy:AddEntry("Mails Sent", player.mailsSent, COLUMN_RIGHT)

		-- TODO: implement data collection
		--	economy:AddEntry("GoldReceived", player.goldReceived, COLUMN_LEFT)
		--	economy:AddEntry("GoldGiven", player.goldGiven, COLUMN_LEFT)

		--	economy:AddEntry("Sales", player.sales, COLUMN_RIGHT)
		--	economy:AddEntry("Purchases", player.purchases, COLUMN_RIGHT)
		--	economy:AddEntry("Trades", player.trades, COLUMN_RIGHT)
	end

	if(player:HasSocialData()) then
		local social = self:AddSection(SECTION_PLAYER, "Social")
		if(player:IsFriend()) then
			social:AddEntry("Is friends with you.", "", COLUMN_BOTH)
		end

		for i = 1, GetNumGuilds() do
			local guildId = GetGuildId(i)
			local entry, guildName, guildRank, guildNote
			if(player:IsGuildMate(guildId)) then
				guildName = GetGuildName(guildId)
				guildRank = zo_iconTextFormat(player:GetGuildRankIcon(guildId), NOTE_ICON_SIZE, NOTE_ICON_SIZE, player:GetGuildRankName(guildId))
				guildNote = player:GetGuildNote(guildId)
				entry = social:AddEntry(guildName, guildRank, COLUMN_BOTH)
				entry:SetNote(guildNote)
			end
		end
	end
end

function PlayerDetailFragment:UpdateCharacter()
	if(not self.fragment:IsShowing()) then return end
	local character = self.currentCharacter
	assert(character ~= nil)

	self:SetName(SECTION_CHARACTER, character.characterName)
	self:ClearSections(SECTION_CHARACTER)

	local general = self:AddSection(SECTION_CHARACTER, "General")

	if(character:HasValidRace()) then
		general:AddEntry("Race", zo_iconTextFormat(character:GetRaceIcon(), ICON_SIZE, ICON_SIZE, character:GetRaceName()), COLUMN_LEFT)
	end

	if(character:HasValidClass()) then
		general:AddEntry("Class", string.format("%s%s", character:GetClassColor():Colorize(zo_iconFormatInheritColor(character:GetClassIcon(), ICON_SIZE, ICON_SIZE)), character:GetClassName()), COLUMN_LEFT)
	end

	if(character:HasValidLevel()) then
		local levelText = character.level
		if character:IsChampion() then -- TODO: show level and champion points
			levelText = zo_iconTextFormat(GetChampionPointsIcon(), ICON_SIZE, ICON_SIZE, character:GetChampionPoints())
		end
		general:AddEntry("Level", levelText, COLUMN_LEFT)
	end

	if(character:HasValidGender()) then
		general:AddEntry("Gender", string.format("%s%s", character:GetGenderColor():Colorize(zo_iconFormatInheritColor(character:GetGenderIcon(), ICON_SIZE, ICON_SIZE)), character:GetGenderName()), COLUMN_RIGHT)
	end

	if(character:HasValidAlliance()) then
		general:AddEntry("Alliance", string.format("%s%s", character:GetAllianceColor():Colorize(zo_iconFormatInheritColor(character:GetAllianceIcon(), ICON_SIZE, ICON_SIZE)), character:GetAllianceName()), COLUMN_RIGHT)
	end

	if(character:HasValidAvARank()) then
		general:AddEntry("AvA Rank", string.format("%s%s", character:GetAllianceColor():Colorize(zo_iconFormatInheritColor(character:GetAvARankIcon(), ICON_SIZE, ICON_SIZE)), character:GetAvARankName()), COLUMN_RIGHT)
	end

	general:AddEntry("Times Seen", character.timesSeen, COLUMN_LEFT)
	general:AddEntry("Last Seen", FormatTimeStampAsTimeAgo(character.lastSeen), COLUMN_RIGHT)

	local lastMet = character.lastMet
	if(lastMet > 0) then
		general:AddEntry("Times Met", character.timesMet, COLUMN_LEFT)
		general:AddEntry("Last Met", FormatTimeStampAsTimeAgo(lastMet), COLUMN_RIGHT)
	end

	if(character:HasInteractionData()) then
		local interactions = self:AddSection(SECTION_CHARACTER, "Interactions")
		interactions:AddEntry("Revives Received", character.revivesReceived, COLUMN_LEFT)
		interactions:AddEntry("Revives Sent", character.revivesSent, COLUMN_LEFT)
		interactions:AddEntry("Times Grouped", character.timesGrouped, COLUMN_RIGHT)
	end

	if(character:HasAllianceWarData()) then
		local allianceWar = self:AddSection(SECTION_CHARACTER, "Alliance War")

		local kills = character.avaKills
		if(character.avaKillStreak > 0) then
			kills = string.format("%d (%d)", kills, character.avaKillStreak)
		end
		allianceWar:AddEntry("Kills", kills, COLUMN_LEFT)
		allianceWar:AddEntry("Assist", character.avaAssists, COLUMN_LEFT)

		local deaths = character.avaDeaths
		if(character.avaDeathStreak > 0) then
			kills = string.format("%d (%d)", deaths, character.avaDeathStreak)
		end
		allianceWar:AddEntry("Deaths", deaths, COLUMN_LEFT)

		allianceWar:AddEntry("Avenges", character.avaAvenges, COLUMN_RIGHT)
		allianceWar:AddEntry("Revenges", character.avaRevenges, COLUMN_RIGHT)
	end
end
