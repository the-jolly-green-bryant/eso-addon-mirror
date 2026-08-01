--[[
Author: Puddy
Filename: libChat.lua
Date: 2014-4-10
Version: 1.0.0
]]--

local MAJOR, MINOR = "libChat-1.0", 1
local libchat, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not libchat then 
	return
end

local funcName = nil
local funcText = nil
local funcFormat = nil

-- Listens for EVENT_CHAT_MESSAGE_CHANNEL event from ZO_ChatSystem
local function libChatReceiver(channelID, from, text)
	local message = ""
	
	-- Get channel information
	local ChanInfoArray = ZO_ChatSystem_GetChannelInfo()
	local info = ChanInfoArray[channelID]
	
	if not info or not info.format then
		return
	end

	-- Function to affect name
	if funcName then
		from = funcName(channelID, from, text)
		if not from then return end
	end
	
	-- Function to affect text message
	if funcText then
		text = funcText(channelID, from, text)
		if not text then return end
	end
	
	-- Function to format message
	if funcFormat then
		message = funcFormat(channelID, from, text)
		if not message then return end
	else
		-- No formatting addon, so do default stuff.
		
		-- Create channel link
		local channelLink
		if info.channelLinkable then
			local channelName = GetChannelName(info.id)
			channelLink = ZO_LinkHandler_CreateChannelLink(channelName)
		end
		
		-- Create player link
		local playerLink
		if info.playerLinkable and not from:find("%[") then
			playerLink = ZO_LinkHandler_CreatePlayerLink(from)
		else
			playerLink = from
		end
		
		-- Create default formatting
		if channelLink then
			message = zo_strformat(info.format, channelLink, playerLink, text)
		else
			message = zo_strformat(info.format, playerLink, text)
		end
	end
	
	return message, info.saveTarget
end

-- Register a function to be called to modify sender name
function libchat:registerName(func)
	if not funcName then
		funcName = func
	end
end

-- Register a function to be called to modify message text
function libchat:registerText(func)
	if not funcText then
		funcText = func
	end
end

-- Register a function to be called to format message
function libchat:registerFormat(func)
	if not funcFormat then
		funcFormat = func
	end
end

ZO_ChatSystem_AddEventHandler(EVENT_CHAT_MESSAGE_CHANNEL, libChatReceiver)
