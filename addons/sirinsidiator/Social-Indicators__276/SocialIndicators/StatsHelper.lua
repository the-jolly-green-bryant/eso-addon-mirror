local RegisterForEvent = SocialIndicators.RegisterForEvent
local WrapFunction = SocialIndicators.WrapFunction
local function InitializeMailStats(saveData, db, resurrectionHelper)
	local ownPlayer = db:GetPlayer(GetDisplayName())

	-- mails sent
	local _, currentRecipient
	ZO_PreHook("SendMail", function(recipientName, subject, body)
		currentRecipient = recipientName
	end)
	ZO_PreHook("ReturnMail", function(mailId)
		_, currentRecipient = GetMailSender(mailId)
	end)

	RegisterForEvent(EVENT_MAIL_SEND_SUCCESS, function()
		if(not currentRecipient) then return end
		local player
		if(IsDecoratedDisplayName(currentRecipient)) then
			player = db:GetPlayer(currentRecipient)
		else
			local character = db:GetCharacter(currentRecipient)
			player = character:GetPlayer()
		end
		if(player) then
			player:IncrementMailsSent()
			player:Save()
			ownPlayer:IncrementMailsSent()
			ownPlayer:Save()
		end
		currentRecipient = nil
	end)

	-- mails received
	local countedMailId = saveData.countedMailId or {}
	saveData.countedMailId = countedMailId
	WrapFunction("ZO_MailInboxShared_PopulateMailData", function(originalPopulateMailData, dataTable, mailId)
		originalPopulateMailData(dataTable, mailId)
		local key = Id64ToString(mailId)
		if(not countedMailId[key]) then
			countedMailId[key] = true

			if(not dataTable.fromSystem and not dataTable.fromCS) then
				local player = db:GetPlayer(dataTable.senderDisplayName)
				player:IncrementMailsReceived()
				player:Save()
				ownPlayer:IncrementMailsReceived()
				ownPlayer:Save()
			end
		end
	end)
	RegisterForEvent(EVENT_MAIL_REMOVED, function(_, mailId)
		local key = Id64ToString(mailId)
		countedMailId[key] = nil
	end)
end

local function InitializeEconomyStats(db)
-- gold received / given
-- take mail attachment from player sent mail / sent mail with gold attachment
-- sold item in guild store / bought item from store
--> libGuildHistory - wraps guild history requests
-- for requestIndex in LGH:GetRequestsAfter(uniqueRequestId):FilterByBuyer(playerName) do
-- end
-- LGH:RegisterForUpdates(guildId, function(iterator) for requestIndex in iterator:FilterByBuyer(playerName) do end end)
-- transferred gold via trade window

end

local function InitializeAllianceWarStats(db)
-- kills - whenever we get last hit on a player
-- kill streak - number of kills on the same player without dying to him in between / number of overall kills without dying on ourself
-- assists - whenever we hit someone and he dies because of someone else (does not count towards streak)
-- deaths - whenever we die to someone's last hit
-- deathstreak - number of consecutive deaths w/o us killing the player inbetween / number of overall deaths without a kill on ourself
-- avenges/revenges - whenever we get one
end

local function InitializeResurrectionStats(db)
	local ownCharacter = db:GetCharacter(GetUnitName("player"))

	local LRES = LibStub("LibResurrection")

	LRES:RegisterCallback("TargetResurrectionAccepted", function(characterName, playerName)
		local character = db:GetCharacter(characterName)
		character:IncrementRevivesSent()
		character:Save()
		ownCharacter:IncrementRevivesSent()
		ownCharacter:Save()
	end)

	LRES:RegisterCallback("PlayerResurrectionAccepted", function(characterName, playerName)
		local character = db:GetCharacter(characterName)
		character:IncrementRevivesReceived()
		character:Save()
		ownCharacter:IncrementRevivesReceived()
		ownCharacter:Save()
	end)
end

local function Initialize(saveData, db, resurrectionHelper)
	InitializeMailStats(saveData, db)
	InitializeResurrectionStats(db, resurrectionHelper)
end

SocialIndicators.InitStatsHelper = Initialize
