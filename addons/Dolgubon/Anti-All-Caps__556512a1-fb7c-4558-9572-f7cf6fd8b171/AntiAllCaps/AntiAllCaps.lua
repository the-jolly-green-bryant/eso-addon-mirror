AntiAllCaps = {}

--sword: abah, akaviri 3, ancient elf 3, aposlte, bloodforge, Celestial, Glass?, scalecaller, trinimac, xivkyn, anequina, Welkynar,
 
AntiAllCaps.name = "AntiAllCaps"
AntiAllCaps.defaults = {
	behaviour = "anti Caps",
	markMessages = true,
}
local zos_OriginalMessageHandler

local function calcNumCaps(chatMessage)
	local stringWithoutCaps = string.gsub(chatMessage, "%u","")
	local originalLength = chatMessage:len()
	local withoutCapsLength = stringWithoutCaps:len()
	if withoutCapsLength/originalLength > 0.6 then
	end
end
--|H1:guild:736071|hAnkle Biters|h
-- |H1:item:165296:362:50:0:0:0:0:0:0:0:0:0:0:0:1:107:0:1:0:10000:0|h|h
-- Link test string:
-- |H1:quest_item:6925|h|h|H1:item:164858:362:50:45873:370:50:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h|H1:guild:736071|hAnkle Biters|h|H1:book:3539|h|h|H1:collectible:81|h|h
function capsBlockHandler(messageType, fromName, text, isFromCustomerService, fromDisplayName)
	-- |t15:15:/esoui/art/tooltips/arrow_up.dds|t

	local originalText = text
	CHAT_ROUTER.registeredMessageFormatters["handler entered"] = true
	local behaviour = AntiAllCaps.settings.behaviour
	if behaviour == "all lower" or behaviour == "anti Caps" then
		local stringWithoutCaps = string.gsub(text, "%u","")
		local originalLength = text:len()
		local withoutCapsLength = stringWithoutCaps:len()
		if (withoutCapsLength/originalLength < 0.6 and text:len() > 10) or behaviour == "all lower" then
			text = text:lower()
			if AntiAllCaps.settings.markMessages and text~= originalText then
				text = "|t13:13:/esoui/art/tooltips/arrow_down.dds|t"..text
				text = text:gsub("|h1:", "|H1:")
			end
		end
	elseif behaviour == "all upper" then
		text = text:upper()
		if AntiAllCaps.settings.markMessages and text~= originalText then
			text = "|t13:13:/esoui/art/tooltips/arrow_up.dds|t"..text
			text = text:gsub("|H", "|h")
			text = text:gsub("|h1:ITEM:", "|H1:item:")
			text = text:gsub("|h1:GUILD:", "|H1:guild:")
			text = text:gsub("|h1:QUEST_ITEM:", "|H1:quest_item:")
			text = text:gsub("|h1:COLLECTIBLE:", "|H1:collectible:")
			text = text:gsub("|h1:BOOK:", "|H1:book:")

		end
	end
	return zos_OriginalMessageHandler(messageType, fromName, text, isFromCustomerService, fromDisplayName)
end

-- local originalRegistration = CHAT_ROUTER.RegisterMessageFormatter

-- ZO_ChatRouter.RegisterMessageFormatter = function(self, eventKey, handler)
-- d("Hook?")
-- 	if eventKey == EVENT_CHAT_MESSAGE_CHANNEL then
-- 		zos_OriginalMessageHandler = handler
-- 		d("found event")
-- 		return originalRegistration(self, eventKey, capsBlockHandler)
-- 	end
-- 	return originalRegistration(self, eventKey, handler)
-- end
--/esoui/art/tooltips/arrow_up.dds
--/esoui/art/tooltips/arrow_down.dds


function AntiAllCaps:Initialize()
	zo_callLater(function()
		zos_OriginalMessageHandler = CHAT_ROUTER.registeredMessageFormatters[EVENT_CHAT_MESSAGE_CHANNEL]
		CHAT_ROUTER.registeredMessageFormatters[EVENT_CHAT_MESSAGE_CHANNEL] = capsBlockHandler
		CHAT_ROUTER.registeredMessageFormatters["Check"] = true
		-- EVENT_MANAGER:RegisterForEvent("ChatRouter", eventCode, OnChatEvent)
		EVENT_MANAGER:UnregisterForEvent(AntiAllCaps.name, EVENT_PLAYER_ACTIVATED)
	end, 1000)
	AntiAllCaps.settings = ZO_SavedVars:NewAccountWide("AntiAllCapsSavedVars", AntiAllCaps.version, nil, AntiAllCaps.defaults)
	AntiAllCaps.initializeSettingsMenu()

end

 
function AntiAllCaps.OnAddOnLoaded(event, addonName)
	if addonName == AntiAllCaps.name then
		AntiAllCaps:Initialize()
	end
end
 
-- EVENT_MANAGER:RegisterForEvent(AntiAllCaps.name, EVENT_ADD_ON_LOADED, AntiAllCaps.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(AntiAllCaps.name, EVENT_PLAYER_ACTIVATED , AntiAllCaps.Initialize)



--[[

@Dolgubon could it be a sync problem, where you may have to wait for a mail to be completely sent before moving on to other tasks? (like guild bank, where nothing works till it's actually finished an action)

manavortex @manavortex Mar 13 10:14
afaik the mailbox has an internal table, and that doesn't automatically get rebuilt when you delete a mail.
It might be that that gets knocked over

Baertram @Baertram Mar 13 10:26
Postmaster is able to mass take items from mails + delete them. So maybe look into this code or ask the dev.

Michael Auerswald @flipswitchingmonkey Mar 13 14:25
@Dolgubon found it, but it's not fully implemented yet, unfortunately. It has some nice functions in it already, but alas, no list of bosses or way to track them (yet)


]]