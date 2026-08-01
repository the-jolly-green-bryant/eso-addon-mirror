CyroQuestManager = CyroQuestManager or {}
local CQM = CyroQuestManager

CQM.Keeps = {
	"alessia",
	"black boot",
	"bloodmayne",
	"brindle",
	"faregyl",
	"roebeck",
	"aleswell",
	"ash",
	"dragonclaw",
	"glademist",
	"rayles",
	"warden",
	"arrius",
	"blue road",
	"chalman",
	"drakelowe",
	"farragut",
	"kingscrest",
}

CQM.KeepsShortHand = {
	["al"] = 1,
	["bb"] = 2,
	["bm"] = 3,
	["blood"] = 3,
	["brin"] = 4,
	["fg"] = 5,
	["fare"] = 5,
	["rb"] = 6,
	["roe"] = 6,
	["aw"] = 7,
	["dc"] = 9,
	["dragon"] = 9,
	["gm"] = 10,
	["glade"] = 10,
	["ray"] = 11,
	["war"] = 12,
	["ar"] = 13,
	["br"] = 14,
	["chal"] = 15,
	["cm"] = 15,
	["dl"] = 16,
	["drake"] = 16,
	["far"] = 17,
	["kc"] = 18,
	["king"] = 18,
}

function CQM.isValidKeep(keepName)
	for i = 1, 18 do
		if keepName == CQM.Keeps[i] then
			return true
		end
	end
	return false
end

function CQM.checkMessageForKeepName(message)
	--Check keep in name
	for i = 1, 18 do
		if string.find(message, CQM.Keeps[i]) then
			return i
		end
	end

	--Check for shorthand
	for short, keep in pairs(CQM.KeepsShortHand) do
		if message == short then
			return keep
		end
	end
	return -1
end

function CQM.checkForScroll(message)
	if string.find(message, "scroll") or message == "s" then
		return true
	end
	return false
end

function CQM.receivedChatMessage(eventCode, channelType, fromName, text, isCustomerService, fromDisplayName)
	if fromName == nil or fromName == "" then
		return
	end

	--Only active within Group Chat AND while in Cyrodiil
	if channelType == CHAT_CHANNEL_PARTY and CQM.isInCyrodiil() then

		--Share all quests request
		if string.lower(text) == "q" or string.lower(text) == "quest" or string.lower(text) == "quests" then
			CQM.SharePvPQuests(true)
		end

		local keepId = CQM.checkMessageForKeepName(string.lower(text))
		if keepId ~= -1 then
			CQM.shareKeepRelatedQuests(CQM.Keeps[keepId])
		end

		if CQM.checkForScroll(string.lower(text)) then
			CQM.shareScrollQuests()
		end

		--if CQM.isValidKeep(string.lower(text)) then
		--	CQM.shareKeepRelatedQuests(text)
		--end
	end
end