local warningsChanged = ""
local original = ZO_ChatSystem_GetEventHandlers()[EVENT_CHAT_MESSAGE_CHANNEL]
local lastAddOnLoaded = ""
local storageChatEventListener = {}
local libChat2EventListener = nil

local libChat, libChatv = nil, nil

local function libGarfield_StoreChatEventListener(addOnName)
	local currentChatEvent = ZO_ChatSystem_GetEventHandlers()[EVENT_CHAT_MESSAGE_CHANNEL]
	local lName = lastAddOnLoaded
	local isLibChat = false
	if original ~= currentChatEvent then
		if lastAddOnLoaded == "" then
			xpcall(function ()
				currentChatEvent(0, nil, nil, nil, nil)
			end, function (error)
				local line = string.match(error, "^([^\n]+)\n")
				local name = string.match(line, "^user:/AddOns/(%w+)")
				if name ~= nil then
					lName = name
				end
				if (string.match(error, "/libChat2/")) then
					isLibChat = true
				end
			end)
		end

		if isLibChat then
			warningsChanged = warningsChanged .. "INFO : Compatibility mode enabled to keep `" .. lName .. "` & `libChat2 (02/2016)` enabled. Please use `libChat3`.\n"
		else
			warningsChanged = warningsChanged .. "WARNING : `" .. lName .. "` is outdated! Ask the author to use a chat library like `libChat3`."
		end

		table.insert(storageChatEventListener, currentChatEvent)
		ZO_ChatSystem_AddEventHandler(EVENT_CHAT_MESSAGE_CHANNEL, original)
	end

	lastAddOnLoaded = addOnName
end 

local function libGarfield_OnAddOnLoad(eventCode, addOnName)
	if LibStub then
		libChat, libChatv = LibStub('libChat-1.0', true)
	end
	libGarfield_StoreChatEventListener(addOnName)
end

local function libGarfield_OnPlayerActivated(eventCode, initial)
	-- https://github.com/esoui/esoui/blob/360dee5f494a444c2418a4e20fab8237e29f641b/
	-- Read: esoui/ingame/chatsystem/chathandlers.lua

	ZO_ChatSystem_AddEventHandler(EVENT_CHAT_MESSAGE_CHANNEL, function(messageType, fromName, text, isFromCustomerService, fromDisplayName)
		local message, saveTarget, _, _ -- = displayName, text
		
		if libChat and libChat.MessageChannelReceiver then -- libChat3
			message, saveTarget, _, _ = libChat:MessageChannelReceiver(messageType, fromName, text, isFromCustomerService, fromDisplayName)
		elseif libChat and libChat2EventListener then -- libChat2
			message, saveTarget, _, _ = libChat2EventListener(messageType, fromName, text, isFromCustomerService, fromDisplayName)
		else 
			message, saveTarget, _, _ = original(messageType, fromName, text, isFromCustomerService, fromDisplayName)
		end

		return message, saveTarget, displayName, text 
	end)

	EVENT_MANAGER:UnregisterForEvent("libGarfield", EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent("libGarfield", EVENT_ADD_ON_LOADED, libGarfield_OnAddOnLoad)
EVENT_MANAGER:RegisterForEvent("libGarfield", EVENT_PLAYER_ACTIVATED, libGarfield_OnPlayerActivated)
