ZonePug = {}
ZonePug.name = "ZonePug"

function ZonePug.OnInitialized(EventCode, addOnName)
	if (ZonePug.name ~= addOnName) then return end
	ZO_PreHook(CHAT_SYSTEM, "OnChatEvent", ZonePug.OnChatMessage)
end

function ZonePug.OnChatMessage(table, unknownvar, channel, charname, text, bool, accountname)
	if channel == CHAT_CHANNEL_ZONE then
		if GetCurrentMapZoneIndex() == 37 then
			-- df("%s has detected a zone message in Cyrodiil, let it display", ZonePug.name)
		else
			-- df("%s has detected a zone message NOT in Cyrodiil, analyzing it", ZonePug.name)
			if string.find(text, "[lL][%s.]?[fF][%s.]?[%d]?[%s.]?[mMgG]") or string.find(text, "[lL][%s.]?[fF][%s.]?[%d]?[%s.]?") or string.find(text, "[wW][%s.]?[bB][%s.]?[%d]?[%s.]?") or string.find(text, "[dD][aA][iI][lL][yY]") or string.find(text, "[dD][aA][iI][lL][iI][eE][sS]") or string.find(text, "[kK][eE][yY]") or string.find(text, "[kK][eE][yY][sS]") or string.find(text, "[pP][lL][eE][dD][gG][eE][sS]") or string.find(text, "[pP][lL][eE][dD][gG][eE]") or string.find(text, "[uU][nN][dD][aA][uU][nN][tT][eE][dD]") or string.find(text, "[%d]?[dD][oO][lL][mM][eE][nN]") then
			-- df("%s : one of the words from the list is detected, letting the message through", text)
			else
				-- df("%s has detected a zone message that does not use words on the list, blocking it", ZonePug.name)
				return true
			end
		end
	else 
		-- df("%s has detected a non zone message, do nothing", ZonePug.name)
	end
end

EVENT_MANAGER:RegisterForEvent(ZonePug.name, EVENT_ADD_ON_LOADED, ZonePug.OnInitialized)