local LogDebug = SocialIndicators.LogDebug
local GetRaceName = SocialIndicators.GetRaceName
local GetRaceIcon = SocialIndicators.GetRaceIcon
local EncodeData = SocialIndicators.EncodeData
local DecodeData = SocialIndicators.DecodeData

local CharacterData = ZO_Object:Subclass()
SocialIndicators.CharacterData = CharacterData

local CURRENT_VERSION = 1
local LAST_SEEN_TRESHOLD = 3600 * 6 -- every 6 hours we count them in the stats

local format = {
	[1] = {
		"integer", -- version
		"integer", -- lastSeen
		"integer", -- lastMet
		"integer", -- race
		"integer", -- gender
		"integer", -- classType
		"integer", -- alliance
		"integer", -- avaRank
		"integer", -- level
		"integer", -- timesSeen
		"integer", -- timesMet
		"integer", -- timesGrouped
		"integer", -- revivesReceived
		"integer", -- revivesSent
		"integer", -- avaKills
		"integer", -- avaAssists
		"integer", -- avaDeaths
		"integer", -- avaKillStreak
		"integer", -- avaDeathStreak
		"integer", -- avaAvenges
		"integer", -- avaRevenges
	},
	[4] = {
		"integer", -- version
		"integer", -- lastSeen
		"integer", -- lastMet
		"integer", -- race
		"integer", -- gender
		"integer", -- classType
		"integer", -- alliance
		"integer", -- avaRank
		"integer", -- level
		"integer", -- veteranRank -- TODO remove
		"integer", -- timesSeen
		"integer" -- timesMet
	}
}

local loadFunction = {}

local MAX_LEVEL = 50
loadFunction[1] = function(character, version, lastSeen, lastMet, race, gender, classType, alliance, avaRank, level, timesSeen, timesMet, timesGrouped, revivesReceived, revivesSent, avaKills, avaAssists, avaDeaths, avaKillStreak, avaDeathStreak, avaAvenges, avaRevenges)
	local baseTime = character.database.baseTime
	character.race = race
	character.gender = gender
	character.classType = classType
	character.alliance = alliance
	character.avaRank = avaRank
	if(level > MAX_LEVEL) then -- TODO convert and remove
		character.level = MAX_LEVEL
		character.veteranRank = level - MAX_LEVEL
	else
		character.level = level
		character.veteranRank = 0
	end
	character.lastSeen = (lastSeen ~= 0) and (lastSeen + baseTime) or 0
	character.lastMet = (lastMet ~= 0) and (lastMet + baseTime) or 0
	character.timesSeen = timesSeen
	character.timesMet = timesMet
	character.timesGrouped = timesGrouped
	character.revivesReceived = revivesReceived
	character.revivesSent = revivesSent
	character.avaKills = avaKills
	character.avaAssists = avaAssists
	character.avaDeaths = avaDeaths
	character.avaKillStreak = avaKillStreak
	character.avaDeathStreak = avaDeathStreak
	character.avaAvenges = avaAvenges
	character.avaRevenges = avaRevenges
end

loadFunction[4] = function(character, version, lastSeen, lastMet, race, gender, classType, alliance, avaRank, level, veteranRank, timesSeen, timesMet)
	local baseTime = character.database.baseTime
	character.race = race
	character.gender = gender
	character.classType = classType
	character.alliance = alliance
	character.avaRank = avaRank
	character.level = level
	character.veteranRank = veteranRank -- TODO remove
	character.lastSeen = (lastSeen ~= 0) and (lastSeen + baseTime) or 0
	character.lastMet = (lastMet ~= 0) and (lastMet + baseTime) or 0
	character.timesSeen = timesSeen
	character.timesMet = timesMet
end

function CharacterData:New(...)
	local object = ZO_Object.New(self)
	object:Initialize(...)
	return object
end

function CharacterData:Initialize(database, characterName, encodedString)
	self.database = database
	self.characterName = characterName
	self:Reset()
	if(encodedString) then
		self:Load(encodedString)
	end
end

function CharacterData:Reset()
	self.race = 0
	self.gender = 0
	self.classType = 0
	self.alliance = 0
	self.avaRank = 0
	self.level = 0
	self.veteranRank = 0 -- TODO: remove
	self.lastSeen = 0
	self.lastMet = 0
	-- general
	self.timesSeen = 0
	self.timesMet = 0
	self.timesGrouped = 0
	self.revivesReceived = 0
	self.revivesSent = 0
	-- ava
	self.avaKills = 0 -- you killed him (last hit)
	self.avaAssists = 0 -- you helped kill him (no last hit)
	self.avaDeaths = 0 -- he killed you (last hit)
	self.avaKillStreak = 0 -- how often did you kill him in a row
	self.avaDeathStreak = 0 -- how often did he kill you in a row
	self.avaAvenges = 0
	self.avaRevenges = 0
	-- not saved
	self.lastGrouped = 0
end

function CharacterData:IsValid()
	return (self.characterName and self.characterName ~= "")
end

function CharacterData:HasData()
	return (self.race ~= 0
		or self.gender ~= 0
		or self.classType ~= 0
		or self.alliance ~= 0
		or self.avaRank ~= 0
		or self.level ~= 0
		or self.lastSeen ~= 0
		or self.lastMet ~= 0
		or self.timesSeen ~= 0
		or self.timesMet ~= 0
		or self.timesGrouped ~= 0
		or self.revivesReceived ~= 0
		or self.revivesSent ~= 0
		or self.avaKills ~= 0
		or self.avaAssists ~= 0
		or self.avaDeaths ~= 0
		or self.avaKillStreak ~= 0
		or self.avaDeathStreak ~= 0
		or self.avaAvenges ~= 0
		or self.avaRevenges ~= 0)
end

function CharacterData:HasInteractionData()
	return (self.timesGrouped ~= 0
		or self.revivesReceived ~= 0
		or self.revivesSent ~= 0)
end

function CharacterData:HasAllianceWarData()
	return (self.avaKills ~= 0
		or self.avaAssists ~= 0
		or self.avaDeaths ~= 0
		or self.avaKillStreak ~= 0
		or self.avaDeathStreak ~= 0
		or self.avaAvenges ~= 0
		or self.avaRevenges ~= 0)
end

-- get character quality based on how much data we have. Returns 0 ... 3 where 3 is good quality
function CharacterData:GetDataQuality()
	local quality = 0
	if((self.lastSeen > 0 and self.timesSeen > 10)
		or (self.lastMet > 0 and self.timesMet > 0)
		or self.timesGrouped > 0) then quality = quality + 1 end

	if(self.race > 0 or self.classType > 0 or self.alliance > 0 or self.avaRank > 0 or self.level > 0) then quality = quality + 1 end

	if(self.revivesReceived > 0 or self.revivesSent > 0 or self:HasAllianceWarData()) then quality = quality + 1 end
	return quality
end

function CharacterData:Load(encodedString)
	local data, version = DecodeData(encodedString, format)

	if(loadFunction[version] and #data == #format[version]) then
		loadFunction[version](self, unpack(data))
	else
		LogDebug("Cannot load character, unknown version %s", tostring(version))
		self:Reset()
	end
end

function CharacterData:Save()
	if(not self:IsValid()) then LogDebug("Cannot save character, object not ready") return false end
	if(not self:HasData()) then LogDebug("character %s has no data, skip saving", self.characterName) return false end
	local baseTime = self.database.baseTime
	local data = {
		CURRENT_VERSION,
		(self.lastSeen ~= 0) and (self.lastSeen - baseTime) or 0,
		(self.lastMet ~= 0) and (self.lastMet - baseTime) or 0,
		self.race,
		self.gender,
		self.classType,
		self.alliance,
		self.avaRank,
		self.level,
		self.timesSeen,
		self.timesMet,
		self.timesGrouped,
		self.revivesReceived,
		self.revivesSent,
		self.avaKills,
		self.avaAssists,
		self.avaDeaths,
		self.avaKillStreak,
		self.avaDeathStreak,
		self.avaAvenges,
		self.avaRevenges,
	}
	local encodedString = EncodeData(ZO_ShallowTableCopy(data), format[CURRENT_VERSION])

	-- TODO remove
	local decodedData = DecodeData(encodedString, format)
	if(#data ~= #decodedData) then
		LogDebug("saving character failed, different field count (%d ~= %d)", #data, #decodedData)
		return false
	else
		for i=1, #data do
			if(data[i] ~= decodedData[i]) then
				LogDebug("saving character failed, field %d is different (%s) '%s' ~= (%s) '%s'", i, type(data[i]), tostring(data[i]), type(decodedData[i]), tostring(decodedData[i]))
				return false
			end
		end
	end

	self.database:UpdateCharacter(self.characterName, encodedString)
	return true
end

function CharacterData:SetCharacterName(characterName)
	self.characterName = characterName
end

function CharacterData:SetRace(race)
	self.race = race or 0
end

function CharacterData:GetRaceName()
	return GetRaceName(self.race, self.gender or GENDER_MALE)
end

function CharacterData:GetRaceIcon()
	return GetRaceIcon(self.race)
end

function CharacterData:HasValidRace()
	return self.race >= 1 and self.race <= 10
end

function CharacterData:SetGender(gender)
	self.gender = gender
end

function CharacterData:GetGenderName()
	return GetString("SI_GENDER", self.gender)
end

local GENDER_COLOR = {
	[GENDER_NEUTER] = ZO_ColorDef:New("FFFFFF"),
	[GENDER_FEMALE] = ZO_ColorDef:New("FFCCFF"),
	[GENDER_MALE] = ZO_ColorDef:New("CCFFFF"),
}

function CharacterData:GetGenderColor()
	return GENDER_COLOR[self.gender]
end

local GENDER_ICON = {
	[GENDER_FEMALE] = "EsoUI/Art/CharacterCreate/CharacterCreate_femaleIcon_up.dds",
	[GENDER_MALE] = "EsoUI/Art/CharacterCreate/CharacterCreate_maleIcon_up.dds",
}

function CharacterData:GetGenderIcon()
	return GENDER_ICON[self.gender]
end

function CharacterData:HasValidGender()
	return self.gender == GENDER_MALE or self.gender == GENDER_FEMALE
end

function CharacterData:SetClass(classType)
	self.classType = classType
end

function CharacterData:GetClassName()
	return zo_strformat(SI_CLASS_NAME, GetClassName(self.gender or GENDER_MALE, self.classType))
end

function CharacterData:GetClassIcon()
	return GetClassIcon(self.classType)
end

local CLASS_COLOR = {
	[1] = ZO_ColorDef:New("4ECE59"), -- Dragonknight
	[2] = ZO_ColorDef:New("42BECE"), -- Sorcerer
	[3] = ZO_ColorDef:New("B76738"), -- Nightblade
	[6] = ZO_ColorDef:New("D1D337"), -- Templar
}

function CharacterData:GetClassColor()
	return CLASS_COLOR[self.classType]
end

function CharacterData:HasValidClass()
	return CLASS_COLOR[self.classType] ~= nil
end

function CharacterData:SetAlliance(alliance)
	self.alliance = alliance
end

function CharacterData:GetAllianceName()
	return GetString("SI_ALLIANCE", self.alliance)
end

function CharacterData:GetAllianceTexture()
	return GetAllianceTexture(self.alliance)
end

function CharacterData:GetAllianceIcon()
	return GetAllianceSymbolIcon(self.alliance)
end

function CharacterData:GetAllianceColor()
	return GetAllianceColor(self.alliance)
end

local VALID_ALLIANCE = {
	[ALLIANCE_DAGGERFALL_COVENANT] = true,
	[ALLIANCE_ALDMERI_DOMINION] = true,
	[ALLIANCE_EBONHEART_PACT] = true,
}

function CharacterData:HasValidAlliance()
	return VALID_ALLIANCE[self.alliance]
end

function CharacterData:SetAvARank(avaRank)
	self.avaRank = avaRank
end

function CharacterData:GetAvARankName()
	return zo_strformat(SI_STAT_RANK_NAME_FORMAT, GetAvARankName(self.gender or GENDER_MALE, self.avaRank))
end

function CharacterData:GetAvARankIcon()
	return GetAvARankIcon(self.avaRank)
end

function CharacterData:HasValidAvARank()
	return self.avaRank > 0 and self.avaRank <= 50
end

function CharacterData:HasValidLevel()
	return self.level > 0
end

function CharacterData:UpdateLevel(level)
	self.level = level
end

function CharacterData:UpdateChampionPoints(championPoints)
    local player = self:GetPlayer()
    if(player) then
        player:UpdateChampionPoints(championPoints)
    end
end

function CharacterData:GetChampionPoints()
    local player = self:GetPlayer()
    return player and player.championPoints or 0
end

function CharacterData:IsChampion()
    local player = self:GetPlayer()
    if(player) then
        return self.level == MAX_LEVEL and player.championPoints > 0
    end
    return false
end

function CharacterData:IsGrouped()
    return IsPlayerInGroup(self.characterName)
end

function CharacterData:IsGroupLeader()
    return self:IsGrouped() and GetUnitName(GetGroupLeaderUnitTag()) == self.characterName
end

function CharacterData:UpdateZone(zoneName)
	self.zoneName = zoneName
end

function CharacterData:UpdateLastSeen()
	local now = GetTimeStamp()
	if(now - self.lastSeen > LAST_SEEN_TRESHOLD) then
		self.timesSeen = self.timesSeen + 1
	end
	self.lastSeen = now
	local player = self:GetPlayer()
	if(player) then
		player:UpdateLastSeen()
	end
end

function CharacterData:UpdateLastMet()
	local now = GetTimeStamp()
	if(now - self.lastMet > LAST_SEEN_TRESHOLD) then
		self.timesMet = self.timesMet + 1
	end
	self.lastMet = now
	local player = self:GetPlayer()
	if(player) then
		player:UpdateLastMet()
	end
	self:UpdateLastSeen()
end

function CharacterData:UpdateTimesGrouped()
	local now = GetTimeStamp()
	if(now - self.lastGrouped > LAST_SEEN_TRESHOLD) then
		self.timesGrouped = self.timesGrouped + 1
	end
	self.lastGrouped = now
end

function CharacterData:GetPlayer()
	return self.database:GetPlayerForCharacter(self.characterName)
end

function CharacterData:SetPlayer(displayName)
	self.database:SetPlayerCharacterLink(displayName, self.characterName)
end

function CharacterData:IncrementRevivesReceived()
	self.revivesReceived = self.revivesReceived + 1
end

function CharacterData:IncrementRevivesSent()
	self.revivesSent = self.revivesSent + 1
end
