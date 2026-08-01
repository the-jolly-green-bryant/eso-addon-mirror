local LogDebug = SocialIndicators.LogDebug
local GetFinalGuildRankTextureCropped = SocialIndicators.GetFinalGuildRankTextureCropped
local EncodeData = SocialIndicators.EncodeData
local DecodeData = SocialIndicators.DecodeData

local PlayerData = ZO_Object:Subclass()
SocialIndicators.PlayerData = PlayerData

local CURRENT_VERSION = 1
local LAST_SEEN_TRESHOLD = 3600 * 6 -- every 6 hours we count them in the stats

local format = {
	[1] = {
		"integer", -- version
		"integer", -- lastSeen
		"integer", -- lastMet
		"integer", -- timesSeen
		"integer", -- timesMet
		"integer", -- mailsReceived
		"integer", -- mailsSent
		"integer", -- sales
		"integer", -- purchases
		"integer", -- trades
		"integer", -- goldReceived
		"integer", -- goldGiven
	},
	[3] = {
		"integer", -- version
		"integer", -- lastSeen
		"integer", -- lastMet
		"integer", -- timesSeen
		"integer" -- timesMet
	}
}

local loadFunction = {}
loadFunction[1] = function(player, version, lastSeen, lastMet, timesSeen, timesMet, mailsReceived, mailsSent, sales, purchases, trades, goldReceived, goldGiven)
	local baseTime = player.database.baseTime
	player.lastSeen = (lastSeen ~= 0) and (lastSeen + baseTime) or 0
	player.lastMet = (lastMet ~= 0) and (lastMet + baseTime) or 0
	player.timesSeen = timesSeen
	player.timesMet = timesMet
	player.mailsReceived = mailsReceived
	player.mailsSent = mailsSent
	player.sales = sales
	player.purchases = purchases
	player.trades = trades
	player.goldReceived = goldReceived
	player.goldGiven = goldGiven
end
loadFunction[3] = function(player, version, lastSeen, lastMet, timesSeen, timesMet)
	local baseTime = player.database.baseTime
	player.lastSeen = (lastSeen ~= 0) and (lastSeen + baseTime) or 0
	player.lastMet = (lastMet ~= 0) and (lastMet + baseTime) or 0
	player.timesSeen = timesSeen
	player.timesMet = timesMet
end

function PlayerData:New(...)
	local object = ZO_Object.New(self)
	object:Initialize(...)
	return object
end

function PlayerData:Initialize(database, displayName, encodedString)
	self.database = database
	self.displayName = displayName
	self:Reset()
	if(encodedString) then
		self:Load(encodedString)
	end
end

function PlayerData:Reset()
	self.lastSeen = 0
	self.lastMet = 0
	-- general
	self.championPoints = 0
	self.timesSeen = 0
	self.timesMet = 0
	self.mailsReceived = 0
	self.mailsSent = 0
	-- economic
	self.sales = 0 -- guild store
	self.purchases = 0 -- guild store
	self.trades = 0 -- direct
	self.goldReceived = 0
	self.goldGiven = 0

	self.friendNote = nil
	self.guildNote = {}
	self.guildRank = {}
end

function PlayerData:IsValid()
	return (self.displayName and self.displayName ~= "")
end

function PlayerData:HasData()
	return (self.lastSeen ~= 0
		or self.lastMet ~= 0
		or self.championPoints ~= 0
		or self.timesSeen ~= 0
		or self.timesMet ~= 0
		or self.mailsReceived ~= 0
		or self.mailsSent ~= 0
		or self.sales ~= 0
		or self.purchases ~= 0
		or self.trades ~= 0
		or self.goldReceived ~= 0
		or self.goldGiven ~= 0)
end

function PlayerData:HasEconomicData()
	return (self.mailsReceived ~= 0
		or self.mailsSent ~= 0
		or self.sales ~= 0
		or self.purchases ~= 0
		or self.trades ~= 0
		or self.goldReceived ~= 0
		or self.goldGiven ~= 0)
end

function PlayerData:HasSocialData()
	return self:IsFriend() or self:IsGuildMate()
end

-- get player quality based on how much data we have. Returns 0 ... 3 where 3 is good quality
function PlayerData:GetDataQuality()
	local quality = 0
	if(self.lastSeen > 0 and self.timesSeen > 10) then quality = quality + 1 end
	if(self.lastMet > 0 and self.timesMet > 0) then quality = quality + 1 end
	if(self:HasEconomicData()) then quality = quality + 1 end
	return quality
end

function PlayerData:Load(encodedString)
	local data, version = DecodeData(encodedString, format)
	if(loadFunction[version] and #data == #format[version]) then
		loadFunction[version](self, unpack(data))
	else
		LogDebug("Cannot load player %s, unknown version %s", tostring(self.displayName), tostring(version))
		self:Reset()
	end
end

function PlayerData:Save()
	if(not self:IsValid()) then LogDebug("Cannot save player, object not valid") return false end
	if(not self:HasData()) then LogDebug("player %s has no data, skip saving", self.displayName) return false end
	local baseTime = self.database.baseTime
	local data = {
		CURRENT_VERSION,
		(self.lastSeen ~= 0) and (self.lastSeen - baseTime) or 0,
		(self.lastMet ~= 0) and (self.lastMet - baseTime) or 0,
		self.timesSeen,
		self.timesMet,
		self.mailsReceived,
		self.mailsSent,
		self.sales,
		self.purchases,
		self.trades,
		self.goldReceived,
		self.goldGiven,

	}
	local encodedString = EncodeData(ZO_ShallowTableCopy(data), format[CURRENT_VERSION])

	-- TODO: remove
	local decodedData = DecodeData(encodedString, format)
	if(#data ~= #decodedData) then
		d("saving player failed, different field count")
		return false
	else
		for i=1, #data do
			if(data[i] ~= decodedData[i]) then
				df("saving player failed, field %d is different (%s) '%s' ~= (%s) '%s'", i, type(data[i]), tostring(data[i]), type(decodedData[i]), tostring(decodedData[i]))
				return false
			end
		end
	end

	self.database:UpdatePlayer(self.displayName, encodedString)
	return true
end

function PlayerData:SetDisplayName(displayName)
	self.displayName = displayName
end

function PlayerData:UpdateFriendNote(friendNote)
	self.friendNote = friendNote
end

function PlayerData:IsFriend()
	return IsFriend(self.displayName)
end

function PlayerData:IsIgnored()
	return IsIgnored(self.displayName)
end

function PlayerData:GetFriendNote()
	return self.friendNote
end

function PlayerData:UpdateGuildNote(guildId, note)
	self.guildNote[guildId] = note
end

function PlayerData:GetGuildNote(guildId)
	return self.guildNote[guildId]
end

function PlayerData:UpdateGuildRank(guildId, rankIndex)
	self.guildRank[guildId] = rankIndex
end

function PlayerData:GetGuildRankIcon(guildId)
	local rankIndex = self.guildRank[guildId]
	if(rankIndex) then
		return GetFinalGuildRankTextureCropped(guildId, rankIndex)
	end
	return nil
end

function PlayerData:GetGuildRankName(guildId)
	local rankIndex = self.guildRank[guildId]
	if(rankIndex) then
		return GetFinalGuildRankName(guildId, rankIndex)
	end
	return nil
end

function PlayerData:IsGuildMate(guildId)
	if(guildId ~= nil) then
		return self.guildRank[guildId] ~= nil
	else
		return NonContiguousCount(self.guildRank) > 0
	end
end

function PlayerData:UpdateStatus(playerStatus, secsSinceLogoff)
	self.playerStatus = playerStatus
	self.logOffTime = GetTimeStamp() - secsSinceLogoff
	self:UpdateLastSeen()
end

function PlayerData:GetStatusString()
	return GetString("SI_PLAYERSTATUS", self.playerStatus)
end

function PlayerData:GetStatusIcon()
	return GetPlayerStatusIcon(self.playerStatus) or GetPlayerStatusIcon(PLAYER_STATUS_OFFLINE)
end

function PlayerData:GetTimeSinceLogoff()
	return GetTimeStamp() - self.logOffTime
end

function PlayerData:UpdateLastSeen()
	local now = GetTimeStamp()
	if(now - self.lastSeen > LAST_SEEN_TRESHOLD) then
		self.timesSeen = self.timesSeen + 1
	end
	self.lastSeen = now
end

function PlayerData:UpdateLastMet()
	local now = GetTimeStamp()
	if(now - self.lastMet > LAST_SEEN_TRESHOLD) then
		self.timesMet = self.timesMet + 1
	end
	self.lastMet = now
end

function PlayerData:GetTimeSinceLastSeen()
	return GetTimeStamp() - self.lastSeen
end

function PlayerData:IncrementMailsReceived()
	self.mailsReceived = self.mailsReceived + 1
end

function PlayerData:IncrementMailsSent()
	self.mailsSent = self.mailsSent + 1
end

function PlayerData:AddGoldReceived(amount)
	assert(amount > 0)
	self.goldReceived = self.goldReceived + amount
end

function PlayerData:AddGoldGiven(amount)
	assert(amount > 0)
	self.goldGiven = self.goldGiven + amount
end

function PlayerData:UpdateChampionPoints(championPoints)
    self.championPoints = championPoints
end
