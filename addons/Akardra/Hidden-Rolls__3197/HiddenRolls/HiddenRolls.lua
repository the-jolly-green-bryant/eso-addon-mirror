-----------------------------------------------------------------------------------------------
-- Hidden Rolls
-----------------------------------------------------------------------------------------------
--[[
-- Copyright (c) 2021 Akardra All rights reserved.
--
-- Permission is hereby granted, free of charge, to any person obtaining
-- a copy of this software and associated documentation (the "Software"),
-- to operate the Software for personal use only. Permission is NOT granted
-- to modify, merge, publish, distribute, sublicense, re-upload, and/or sell
-- copies of the Software. Additionally, licensed use of the Software
-- will be subject to the following:
--
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
-- HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
-- WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
-- OTHER DEALINGS IN THE SOFTWARE.
--
-----------------------------------------------------------------------------------------------
--
-- DISCLAIMER:
--
-- This Add-on is not created by, affiliated with or sponsored by ZeniMax
-- Media Inc. or its affiliates. The Elder Scrolls® and related logos are
-- registered trademarks or trademarks of ZeniMax Media Inc. in the United
-- States and/or other countries. All rights reserved.
--
-- You can read the full terms at:
-- https://account.elderscrollsonline.com/add-on-terms
-----------------------------------------------------------------------------------------------
--
-- HOW DOES IT WORK (brief summary)
--
-- This addon uses the Group Socket library to send- and listen for map pings with dice roll data.
-- Dice data is sent in sequences of pings due to the amount of data.
-- Data in each ping is added to a queue list and a seperate update listener goes through the queue to collect the data.
-- To avoid pinging faster than other players can process them, there is a delay between pings sent.
--]]


HiddenRollsAddon = {}
HiddenRollsAddon.name = "HiddenRolls"
HiddenRollsAddon.inCombat = false

local chat = LibChatMessage("HiddenRolls", "HR") -- long and short tag to identify which addon is printing the message

local ROLLTYPE_HIDDEN = 1                        -- IDs to identify different /roll chat commands with
local ROLLTYPE_VISIBLE = 2
local ROLLTYPE_PRIVATE = 3

local last_h_rolls = {}                             -- holds data about first hidden roll made (since last execution of /showroll)
last_h_rolls.num = 0
last_h_rolls.dice = 0
last_h_rolls.playerRolls = {}

local lastPing = {}                              -- holds data about content of previously received ping (pings are received twice for some reason)
local timestamp_ping = 0
local timestamp_update = 0
local pingsQueue = {}                            -- list of pings received to-be reviwed
local pq_curr_idx = 1                            -- current max-index of pingsQueue list
local pq_prev_idx = 1                            -- max-index of pingsQueue list after last update

local ADDON_NAME = HiddenRollsAddon.name
local GROUP_SOCKET_MESSAGE_TYPE = 17             -- ID used by addon for pings sent via. group socket library
local GROUP_SOCKET_MESSAGE_VERSION = 1
local GROUP_SOCKET = LibStub("LibGroupSocket")

local TIME_BETWEEN_PINGS = 400
local TIME_BETWEEN_UPDATES = 1000

local group_pings = {}                           -- list of group members to keep data from pings seperate if they arrive from multiple party members simultaniously

local nextPing = {}                              -- holds data about pings to-be-sent by the player, while waiting for sequential confirmation that previous pings were received
local sendingPings = false


-----------------------------------------------------------------------------------------------
-- Extra
-----------------------------------------------------------------------------------------------

-- Event listener function. Updates combat state
local function OnPlayerCombatState(event, inCombat)
	if inCombat ~= HiddenRollsAddon.inCombat then
		HiddenRollsAddon.inCombat = inCombat
	end
end

-- Provides index in group_pings of the sender of a ping
local function listContainsUnit(list, unitName)
	for index, value in ipairs(list) do
        if value.unitName == unitName then
            return index
        end
    end

	return false
end


-----------------------------------------------------------------------------------------------
-- Data Sharing
-----------------------------------------------------------------------------------------------

-- Sends the next ping in the sequence of pings containing the total information about a hidden roll
local function sendNextPing()
	local playerRolls = nextPing.playerRolls
	local loops = nextPing.loops
	local len = nextPing.len
	local c = nextPing.c
	local i = nextPing.i

	local data = {}

	if loops > 1 then
		data = {}
		GROUP_SOCKET:WriteUint8(data, 1, playerRolls[c + 1])
		GROUP_SOCKET:WriteUint8(data, 2, playerRolls[c + 2])
		GROUP_SOCKET:WriteUint8(data, 3, playerRolls[c + 3])
		GROUP_SOCKET:Send(GROUP_SOCKET_MESSAGE_TYPE, data)

		c = c + 3
	else
		processingLoopsSpillover = len - c

		if processingLoopsSpillover > 0 then
			data = {}
			for i=1, processingLoopsSpillover do
				GROUP_SOCKET:WriteUint8(data, i, playerRolls[c + 1])
				c = c + 1
			end

			GROUP_SOCKET:Send(GROUP_SOCKET_MESSAGE_TYPE, data)
		end

		sendingPings = false
	end

	nextPing.c = c
end

-- Sends initial ping in the sequence of pings containing the total information about a hidden roll
local function PingResultsToGroup(num, dice, playerRolls)
	if (not IsUnitGrouped("player")) then return end

	local data = {}
	local len = table.getn(playerRolls)

	local loops = math.floor(len / 3) + 1
	local pings = math.ceil(len / 3)

	timestamp_ping = GetGameTimeMilliseconds()
	sendingPings = true

	GROUP_SOCKET:WriteUint8(data, 1, num)
	GROUP_SOCKET:WriteUint8(data, 2, dice)
	GROUP_SOCKET:WriteUint8(data, 3, pings)
	GROUP_SOCKET:Send(GROUP_SOCKET_MESSAGE_TYPE, data)

	nextPing.playerRolls = playerRolls
	nextPing.loops = loops
	nextPing.len = len
	nextPing.c = 0
end

local function createGroupMember(unitName)
	gm = {}
	gm.unitName = unitName
	gm.processingPing = false
	gm.processingPingsLeft = 0
	gm.processingPingMsg = ""

	return gm
end

-- Sequentially looks through received via. pings. Builds hidden roll message from group members and posts it as a system message to the player.
local function updatePingsQueue()
	while (pq_curr_idx > pq_prev_idx) do
		
		local unitTag = pingsQueue[pq_prev_idx][1]
		local data    = pingsQueue[pq_prev_idx][2]
		local isSelf  = pingsQueue[pq_prev_idx][3]

		-- Ignore pings from self
		if isSelf then
			pq_prev_idx = pq_prev_idx + 1
			return
		end

		-- Checks latest ping isn't a copy'
		if lastPing == tostring(unitTag .. table.concat(data, ', ')) then
			pq_prev_idx = pq_prev_idx + 1
			return
		else
			lastPing = tostring(unitTag .. table.concat(data, ', '))
		end
		
		-- Tracks data received via. pings seperately for each group member
		local unitName = GetUnitName(unitTag)
		if not unitName then
			pq_prev_idx = pq_prev_idx + 1
			return
		end

		local gpIndex = listContainsUnit(group_pings, unitName)
		if not gpIndex then
			gpIndex = table.getn(group_pings) + 1
			group_pings[gpIndex] = createGroupMember(unitName)
		end

		local index
		
		if not isSelf and not group_pings[gpIndex].processingPing then

			-- Processes initial new set of pings from a group member
			group_pings[gpIndex].processingPing = true
			
			local num, index = GROUP_SOCKET:ReadUint8(data, 1)
			local dice, index = GROUP_SOCKET:ReadUint8(data, 2)
			local pings, index = GROUP_SOCKET:ReadUint8(data, 3)

			group_pings[gpIndex].processingPingsLeft = pings

			group_pings[gpIndex].processingPingMsg = tostring('(' .. unitName .. ') ' .. num .. 'd' .. dice .. ': ')
		elseif not isSelf then

			-- Processes subsequent pings from set of pings from a group member
			group_pings[gpIndex].processingPingsLeft = group_pings[gpIndex].processingPingsLeft - 1
			
			group_pings[gpIndex].processingPingMsg = tostring(group_pings[gpIndex].processingPingMsg .. tostring(table.concat(data, ', ')))

			if group_pings[gpIndex].processingPingsLeft == 0 then
				chat:Print(group_pings[gpIndex].processingPingMsg)

				group_pings[gpIndex].processingPing = false
				group_pings[gpIndex].processingPingsLeft = 0
				group_pings[gpIndex].processingPingMsg = ""
			else
				group_pings[gpIndex].processingPingMsg = tostring(group_pings[gpIndex].processingPingMsg .. ', ') -- posts system message once all hidden roll data is received
			end
		end
		
		pq_prev_idx = pq_prev_idx + 1
	end

	-- Resets list and indexes, to keep size from growing infinitely.
	-- CONSIDER REMOVING: Could cause issue if timing overlaps with ping event listener
	if pq_curr_idx == pq_prev_idx then
		pingsQueue = {}
		pq_curr_idx = 1
		pq_prev_idx = 1
	end
end

-- Checks whether next ping should be sent
local function checkForNextPing()
	if not sendingPings then return end

	local currentTime = GetGameTimeMilliseconds()

	if (currentTime >= timestamp_ping + TIME_BETWEEN_PINGS) then
		if nextPing.loops > 0 then
			sendNextPing()
			nextPing.loops = nextPing.loops - 1
		end
		timestamp_ping = GetGameTimeMilliseconds()
	end
end

-- Checks whether next update should occour
local function checkForNextUpdate()
	if pq_curr_idx == pq_prev_idx then return end
	
	local currentTime = GetGameTimeMilliseconds()

	if (currentTime >= timestamp_update + TIME_BETWEEN_UPDATES) then
		updatePingsQueue()
		timestamp_update = GetGameTimeMilliseconds()
	end
end

local function OnActivated(_, initial)
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED)
	
	-- Event listener function. Group Socket library function. Registers pings with encoded GROUP_SOCKET_MESSAGE_TYPE ID and logs them.
	GROUP_SOCKET:RegisterCallback(GROUP_SOCKET_MESSAGE_TYPE, function (unitTag, data, isSelf)
		if HiddenRollsAddon.inCombat == true then return end
		pingsQueue[pq_curr_idx]	= { unitTag, data, isSelf }
		pq_curr_idx = pq_curr_idx + 1
	end)

	EVENT_MANAGER:RegisterForUpdate(ADDON_NAME, TIME_BETWEEN_PINGS / 2, function ()
		if HiddenRollsAddon.inCombat == true then return end
		checkForNextPing()
		checkForNextUpdate()
	end)
end

-----------------------------------------------------------------------------------------------
-- Roll Functions
-----------------------------------------------------------------------------------------------

-- Sends data about hidden roll to every group members (triggers a system message on their end) and resets saved hidden roll data.
local function showRoll()
	if HiddenRollsAddon.inCombat == true then return end
	local currentTime = GetGameTimeMilliseconds()
	if (sendingPings or currentTime < timestamp_ping + (TIME_BETWEEN_PINGS * 2)) then return end

	PingResultsToGroup(last_h_rolls.num, last_h_rolls.dice, last_h_rolls.playerRolls)

	last_h_rolls.num = 0
	last_h_rolls.dice = 0
	last_h_rolls.playerRolls = {}
end

-- Calculates roll result(s) and saves data about hidden roll (only if there isn't currently saved data)
local function roll(num, dice, rollType)
	if HiddenRollsAddon.inCombat == true then return end

	local currentTime = GetGameTimeMilliseconds()
	if rollType ~= ROLLTYPE_PRIVATE and (sendingPings or currentTime < timestamp_ping + (TIME_BETWEEN_PINGS * 2)) then return end

	playerRolls = {}
		
	for i=1, num, 1 do
		playerRolls[i] = math.random(dice)
	end

	chat:Print(tostring(num .. 'd' .. dice .. ': ' .. table.concat(playerRolls, ', ')))
	
	if rollType == ROLLTYPE_PRIVATE then
		return
	elseif rollType == ROLLTYPE_VISIBLE then
		PingResultsToGroup(num, dice, playerRolls)
	elseif rollType == ROLLTYPE_HIDDEN and last_h_rolls.num == 0 then
		last_h_rolls.num = num
		last_h_rolls.dice = dice
		last_h_rolls.playerRolls = playerRolls
	end
end

-- Check validity of roll command
local function rollCheck(option, rollType)
	local opt = tostring(option)
	local num = 1
	local dice = 20

	-- Checks command formatting
	-- Acceptable formats: "XdY", "dY", "Y" (X is number of dice, Y is the dice max value)
	local token_pos = string.find(opt, 'd')

	if token_pos then
		local sub1 = tonumber(string.sub(opt, 0, token_pos-1))
		local sub2 = tonumber(string.sub(opt, token_pos+1, string.len(opt)))

		if string.sub(opt, 0, token_pos-1) == '' then sub1 = 1 end

		if not sub1 then return end
		if not sub2 then return end

		num = sub1
		dice = sub2
	elseif tonumber(opt) then
		dice = tonumber(opt)
	else
		return
	end

	local max_num = 10
	local max_dice = 100

	if rollType == ROLLTYPE_PRIVATE then
		max_num = 50
		max_dice = 10000
	end

	if num > max_num or dice > max_dice or num < 0 or dice < 2 then
		return
	else
		roll(num, dice, rollType)
	end
end


-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------

-- Event listener function. Triggers on EVENT_ADD_ON_LOADED event.
local function OnAddonLoaded(event, addonName)
	if addonName ~= HiddenRollsAddon.name then
		return
	end

	local handler, saveData = GROUP_SOCKET:RegisterHandler(GROUP_SOCKET_MESSAGE_TYPE, GROUP_SOCKET_MESSAGE_VERSION)
	handler = GROUP_SOCKET:GetHandler(GROUP_SOCKET_MESSAGE_TYPE)

	EVENT_MANAGER:UnregisterForEvent(HiddenRollsAddon.name, EVENT_ADD_ON_LOADED) -- stops event listener
end

SLASH_COMMANDS['/proll'] = function(option) rollCheck(option, ROLLTYPE_PRIVATE) end   -- Only displays results as system message to player
SLASH_COMMANDS['/vroll'] = function(option) rollCheck(option, ROLLTYPE_VISIBLE) end   -- Displays results to player and sends results to group members
SLASH_COMMANDS['/hroll'] = function(option) rollCheck(option, ROLLTYPE_HIDDEN)  end   -- Displays thresults to player and saves data about roll
SLASH_COMMANDS['/showroll'] = function() showRoll() end                               -- Sends results from saved /hroll to group members

EVENT_MANAGER:RegisterForEvent(HiddenRollsAddon.name, EVENT_PLAYER_COMBAT_STATE, OnPlayerCombatState)
EVENT_MANAGER:RegisterForEvent(HiddenRollsAddon.name, EVENT_PLAYER_ACTIVATED, OnActivated)
EVENT_MANAGER:RegisterForEvent(HiddenRollsAddon.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)