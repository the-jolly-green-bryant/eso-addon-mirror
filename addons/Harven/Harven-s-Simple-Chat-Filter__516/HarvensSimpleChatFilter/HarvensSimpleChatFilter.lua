HarvensSimpleChatFilter = {}

function HarvensSimpleChatFilter:IsSpamMessage(eventType, ...)
	if eventType ~= EVENT_CHAT_MESSAGE_CHANNEL then 
		return false
	end
	
	local messageType, fromName, text = ...
	if messageType ~= CHAT_CHANNEL_SAY 
	and messageType ~= CHAT_CHANNEL_YELL 
	and messageType ~= CHAT_CHANNEL_ZONE 
	and messageType ~= CHAT_CHANNEL_ZONE_LANGUAGE_1
	and messageType ~= CHAT_CHANNEL_ZONE_LANGUAGE_2
	and messageType ~= CHAT_CHANNEL_ZONE_LANGUAGE_3 
	and messageType ~= CHAT_CHANNEL_GUILD_1 
	and messageType ~= CHAT_CHANNEL_GUILD_2 
	and messageType ~= CHAT_CHANNEL_GUILD_3 
	and messageType ~= CHAT_CHANNEL_GUILD_4 
	and messageType ~= CHAT_CHANNEL_GUILD_5 then
		return false
	end
	
	fromName = zo_strformat("<<1>>", fromName)
	
	if GetUnitName("player") == fromName or GetDisplayName() == fromName then
		return false
	end
	
	local now = GetTimeStamp()
	if now - self.lastClear > 120 then
		for k,v in pairs(self.lastChats) do
			if now - v.time > 300 then
				self.lastChats[k] = nil
			end
		end
		self.lastClear = now
	end
	
	if not self.lastChats[fromName] then
		self.lastChats[fromName] = { time = now, message = text }
		return false
	elseif self.lastChats[fromName].message == text then
		self.lastChats[fromName].time = now
		self.filteredCount = self.filteredCount + 1
		return true
	else
		self.lastChats[fromName] = nil
		self.lastChats[fromName] = { time = now, message = text }
		return false
	end
end

function HarvensSimpleChatFilter.OnChatEvent(control, ...)
	if HarvensSimpleChatFilter:IsSpamMessage(...) then
		return
	end
	
	HarvensSimpleChatFilter.OnChatEventOrg(control, ...)
end

function HarvensSimpleChatFilter:Initialize()
	self.lastChats = {}
	self.lastClear = GetTimeStamp()
	self.filteredCount = 0
	
	self.OnChatEventOrg = CHAT_SYSTEM.OnChatEvent
	CHAT_SYSTEM.OnChatEvent = HarvensSimpleChatFilter.OnChatEvent
	
	SLASH_COMMANDS["/filteredcount"] = function()
		local pattern = "<<1>> <<1[message/messages]>> filtered out."
		CHAT_SYSTEM:AddMessage(zo_strformat(pattern, self.filteredCount))
	end
end

local function HarvensSimpleChatFilterAddonLoaded(eventType, addonName)
	if addonName ~= "HarvensSimpleChatFilter" then return end
	
	HarvensSimpleChatFilter:Initialize()
end

EVENT_MANAGER:RegisterForEvent("HarvensSimpleChatFilterInitialize", EVENT_ADD_ON_LOADED, HarvensSimpleChatFilterAddonLoaded)