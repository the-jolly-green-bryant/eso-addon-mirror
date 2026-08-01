LibAkaUtils = LibAkaUtils or {}

local CHAT_EVENT = "EVENT_ENTER_TEXT_IN_CHAT"
local CHAT_EVENT_2 = "EVENT_CHAT_MESSAGE_CHANNEL_LAU"

function LibAkaUtils.TextureMessage(size, texture)
	return "|t"..size..":"..size..":"..texture.."|t"
end

function LibAkaUtils.ColorMessage(text,color)
	return "|c"..color..text.."|r"
end

function LibAkaUtils.addToChat(value)
	LibAkaUtils.setChat(LibAkaUtils.getChat()..value)
end

function LibAkaUtils.getChat()
	return LibAkaUtils.GetEditControl():GetText()
end

function LibAkaUtils.GetEditControl()
	return CHAT_SYSTEM:GetEditControl()
end

function LibAkaUtils.GetCursorPos()
	return LibAkaUtils.GetEditControl():GetCursorPosition()
end

function LibAkaUtils.setChat(value)
	CHAT_SYSTEM:StartTextEntry(value)
end

function LibAkaUtils.addChatMessageReceivedListener(name, callback)
	LibAkaUtils.AddListener(CHAT_EVENT_2, name, callback)
	EVENT_MANAGER:UnregisterForEvent(CHAT_EVENT_2)
	EVENT_MANAGER:RegisterForEvent(CHAT_EVENT_2, EVENT_CHAT_MESSAGE_CHANNEL, function(eid, channel, from, message)
		LibAkaUtils.FireEvent(CHAT_EVENT_2, eid, channel, from, message)
	end)
end

function LibAkaUtils.removeChatMessageReceivedListener(name)
	LibAkaUtils.RemoveListener(CHAT_EVENT_2, name)
	if LibAkaUtils.GetNumEventListeners(CHAT_EVENT_2) == 0 then
		EVENT_MANAGER:UnregisterForEvent(CHAT_EVENT_2)
	end
end

function LibAkaUtils.setChatAndCallbackWhenSent(value, name, callback)
	LibAkaUtils.setChat(value)
	if callback == nil then return end
	if name == nil then return end
	LibAkaUtils.chatMessageCallback = callback
	LibAkaUtils.chatMessageCallbackName = name
	LibAkaUtils.chatMessageCallbackCheckValue = value
	LibAkaUtils.addChatMessageReceivedListener(name, LibAkaUtils.ChatMessageCallback)
end

function LibAkaUtils.ChatMessageCallback(_, _, from, message)
	if LibAkaUtils.chatMessageCallback == nil then return end
	if LibAkaUtils.chatMessageCallbackName == nil then return end
	if LibAkaUtils.chatMessageCallbackCheckValue == nil then return end
	if message == LibAkaUtils.chatMessageCallbackCheckValue then
		LibAkaUtils.chatMessageCallback()
		LibAkaUtils.removeChatMessageReceivedListener(LibAkaUtils.chatMessageCallbackName)
		LibAkaUtils.chatMessageCallback = nil
		LibAkaUtils.chatMessageCallbackName = nil
		LibAkaUtils.chatMessageCallbackCheckValue = nil
	end
end

function LibAkaUtils.addChat(value)
	if value == nil then return end
	CHAT_SYSTEM.primaryContainer.currentBuffer:AddMessage(value)
end

function LibAkaUtils.addChatColored(value, color)
	LibAkaUtils.addChat(LibAkaUtils.ColorMessage(value,color))
end

function LibAkaUtils.HandleText(_, message)
	LibAkaUtils.FireEvent(CHAT_EVENT, message)
end

function LibAkaUtils.SetupChatListener()
	if LibAkaUtils.listening == true then return end
	LibAkaUtils.listening = true
	ZO_PreHook(CHAT_SYSTEM, "OnTextEntryChanged", LibAkaUtils.HandleText)
end

function LibAkaUtils.AddChatListener(name, func)
	LibAkaUtils.AddListener(CHAT_EVENT, name, func)
	LibAkaUtils.SetupChatListener()
end