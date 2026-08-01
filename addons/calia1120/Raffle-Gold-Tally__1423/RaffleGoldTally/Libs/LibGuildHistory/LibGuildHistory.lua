---------------------------------------------------------------------------------
-- LibGuildHistory
---------------------------------------------------------------------------------
-- Copyright (c) 2014 Matthew Miller (Mattmillus) and D. Deome (Deome),
-- 				continued by Amy Watts (Calia1120)
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of 
-- this software and associated documentation files (the "Software"), to deal in 
-- the Software without restriction, including without limitation the rights to 
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
-- of the Software, and to permit persons to whom the Software is furnished to do 
-- so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all 
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS 
-- FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR 
-- COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER 
-- IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN 
-- CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--
---------------------------------------------------------------------------------

local ADDON_VERSION = "6"

local LibGuildHistory = LibStub:NewLibrary("LibGuildHistory", ADDON_VERSION)
if not LibGuildHistory then return end

LibGuildHistory.Debug = false

--Variables
local GuildIndex = nil
local Category = nil
local FirstRequest = nil

local CompletionRoutines =
{
	[GUILD_HISTORY_GENERAL]			= {},
	[GUILD_HISTORY_BANK]			= {},
	[GUILD_HISTORY_STORE]			= {},
	[GUILD_HISTORY_COMBAT]			= {}, --unused
	[GUILD_HISTORY_ALLIANCE_WAR]	= {},
}

--Local Functions
local function Debug(str)
	if (LibGuildHistory.Debug) then d(str) end
end

local function RequestPage()
	local GuildId = GetGuildId(GuildIndex)
	
	local pageAvailable

	if (FirstRequest) then
		pageAvailable = RequestGuildHistoryCategoryNewest(GuildId, Category)
		--Debug("Requested first page in guild " .. GuildId .. " category " .. Category)
	else
		pageAvailable = RequestGuildHistoryCategoryOlder(GuildId, Category)
		--Debug("Requested next page in guild " .. GuildId .. " category " .. Category)
	end

	if (pageAvailable) then
		--Debug("Waiting for page in guild " .. GuildId .. " category " .. Category)
	else
		Debug("Page is not available, advancing")
		
		for _, func in pairs(CompletionRoutines[Category]) do func(GuildId) end
		
		if (GuildIndex < GetNumGuilds()) then
			GuildIndex = GuildIndex + 1
			FirstRequest = true
			RequestPage()
		else
			CompletionRoutines[Category] = {}
			
			for category, routines in pairs(CompletionRoutines) do
				if (#routines > 0) then
					GuildIndex = 1
					Category = category
					FirstRequest = true
					RequestPage()
					return
				end
			end
			
			EVENT_MANAGER:UnregisterForEvent("LibGuildHistory", EVENT_GUILD_HISTORY_RESPONSE_RECEIVED)
			GuildIndex = nil
			Category = nil
		end	
	end
end

local function onGuildHistoryResponseReceived(eventCode, guildId, category)
	--Debug("History response received for guild " .. guildId .. " category " .. category)
	
	if (guildId == GetGuildId(GuildIndex) and category == Category) then
		if (FirstRequest) then
			FirstRequest = false
			RequestPage()
		else
			zo_callLater(RequestPage, 2000)
		end
	else
		--d("Warning: Another addon is interfering with LibGuildHistory")
	end
end

local function InitLibrary()
	--hide the guild history tab whenever we are updating
	MAIN_MENU_KEYBOARD.sceneGroupInfo.guildsSceneGroup.menuBarIconData[5].visible = function() return GuildIndex == nil end
end

--Library Functions
function LibGuildHistory:RequestHistory(category, completionRoutine)
	table.insert(CompletionRoutines[category], completionRoutine)
	
	if (not GuildIndex) then
		EVENT_MANAGER:RegisterForEvent("LibGuildHistory", EVENT_GUILD_HISTORY_RESPONSE_RECEIVED, onGuildHistoryResponseReceived)
		GuildIndex = 1
		Category = category
		FirstRequest = true
		RequestPage()
	end
end

InitLibrary()