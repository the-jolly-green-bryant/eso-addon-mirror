-------------------------------------------------------------------------------
-- Roll Call
-------------------------------------------------------------------------------
--[[
-- Copyright (c) 2015-2020 James A. Keene (Phinix) All rights reserved.
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
-------------------------------------------------------------------------------
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
--]]

local RC = _G['RollCallAddon']
local L = RC:GetLanguage()
RC.Version = "1.07"

local Defaults = { rollDefault = 8, noCombat = true, chatMode = false }
local rollAction = {}
local diceW = {}
local diceB = {}
local coinS = {}
local names = {}

local x
local y
local maxValue
local playerPos
local playerRoll

------------------------------------------------------------------------------------------------------------------------------------
-- Main addon functions.
------------------------------------------------------------------------------------------------------------------------------------
local function PingResultsToGroup()
	if tonumber(playerRoll) < 10 then
		x = '0.00' .. playerRoll .. '44'
	elseif tonumber(playerRoll) < 100 then
		x = '0.0' .. playerRoll .. '44'
	elseif tonumber(playerRoll) == 1000 then
		x = '0.000' .. '44'
	else
		x = '0.' .. playerRoll .. '44'
	end

	if tonumber(playerPos) < 10 then
		y = y .. '0' .. playerPos .. '44'
	else
		y = y .. playerPos .. '44'
	end

	PingMap(MAP_PIN_TYPE_PING, MAP_TYPE_LOCATION_CENTERED, x, y)
end

local function GetGroupNames(option)
	names = {}
	if GetGroupSize() > 0 then
		for i = 1, GetGroupSize(), 1 do
			local unit = 'group' .. i
			table.insert(names, #names + 1, GetUnitName(unit))
		end
	else
		table.insert(names, #names + 1, tostring(GetUnitName('player')))
	end
	if option == 1 then
		for k, v in pairs(names) do
			if v == tostring(GetUnitName('player')) then
				playerPos = k
			end
		end
	end
end

local function toss(option)
	GetGroupNames(1)
	if tostring(option) == '?' then
		d(L.RollCallTossQ1)
		d(L.RollCallTossQ2)
		d(L.RollCallTossQ3)
		return
	elseif tonumber(option) == 2 then
		maxValue = 2
		y = '0.1'
	else
		maxValue = 2
		y = '0.1'
	end
	playerRoll = math.random(1, maxValue)
	local iconString = '  ' .. coinS[playerRoll].icon
	local coinS
	if playerRoll == 1 then coinS = L.RollCallToss1 else coinS = L.RollCallToss2 end
	if RC.SV.chatMode == true then
		CHAT_SYSTEM:StartTextEntry(tostring(names[playerPos]) .. L.RollCallToss3 .. coinS)
	else
		d(tostring(names[playerPos]) .. L.RollCallToss3 .. coinS .. iconString)
		if GetGroupSize() > 0 then PingResultsToGroup() end
	end
end

local function rollStandard()
	if RC.SV.chatMode == true then
		CHAT_SYSTEM:StartTextEntry(L.RollCallRoll1 .. playerRoll .. L.RollCallRoll2 .. maxValue .. L.RollCallRoll3 .. tostring(names[playerPos]))
	else
		d(L.RollCallRoll1 .. playerRoll .. L.RollCallRoll2 .. maxValue .. L.RollCallRoll3 .. tostring(names[playerPos]))
		if GetGroupSize() > 0 then PingResultsToGroup() end
	end
end

local function rollWooden(iconString, dnumber)
	if dnumber == 1 then
		if RC.SV.chatMode == true then
			CHAT_SYSTEM:StartTextEntry(tostring(names[playerPos]) .. L.RollCallRoll5 .. playerRoll .. '.')
		else
			d(tostring(names[playerPos]) .. L.RollCallRoll5 .. playerRoll .. iconString)
			if GetGroupSize() > 0 then PingResultsToGroup() end
		end
	else
		if RC.SV.chatMode == true then
			CHAT_SYSTEM:StartTextEntry(tostring(names[playerPos]) .. L.RollCallRoll4 .. tostring(dnumber) .. L.RollCallRoll6 .. playerRoll .. '.')
		else
			d(tostring(names[playerPos]) .. L.RollCallRoll4 .. tostring(dnumber) .. L.RollCallRoll6 .. playerRoll .. iconString)
			if GetGroupSize() > 0 then PingResultsToGroup() end
		end
	end
end

local function roll(option)
	GetGroupNames(1)
	local iconString = ' '
	if tonumber(option) == 100 then
		maxValue = 100
		y = '0.0'
	elseif tonumber(option) == 6 then
		maxValue = 6
		y = '0.2'
	elseif tonumber(option) == 10 then
		maxValue = 10
		y = '0.3'
	elseif tonumber(option) == 12 then
		maxValue = 12
		y = '0.4'
	elseif tonumber(option) == 18 then
		maxValue = 18
		y = '0.5'
	elseif tonumber(option) == 20 then
		maxValue = 20
		y = '0.9'
	elseif tonumber(option) == 24 then
		maxValue = 24
		y = '0.6'
	elseif tonumber(option) == 50 then
		maxValue = 50
		y = '0.7'
	elseif tonumber(option) == 1000 then
		maxValue = 1000
		y = '0.8'
	end
	if maxValue == 6 then
		playerRoll = math.random(maxValue)
		local counting = 0
		while counting ~= playerRoll do
			counting = math.random(6)
		end
		iconString = '.  ' .. diceW[counting].icon
		rollWooden(iconString, 1) return
	elseif maxValue == 12 then
		playerRoll = math.random(2, maxValue)
		local counting = 0
		local tempa = 0
		local tempb = 0
		while counting ~= playerRoll do
			tempa = math.random(6)
			tempb = math.random(6)
			if tempa ~= 0 and tempb ~= 0 and tempa + tempb == playerRoll then
				counting = tempa + tempb
			end
		end
		iconString = '.  ' .. diceW[tempa].icon .. ' ' .. diceB[tempb].icon
		rollWooden(iconString, 2) return
	elseif maxValue == 18 then
		playerRoll = math.random(3, maxValue)
		local counting = 0
		local tempa = 0
		local tempb = 0
		local tempc = 0
		while counting ~= playerRoll do
			tempa = math.random(6)
			tempb = math.random(6)
			tempc = math.random(6)
			if tempa ~= 0 and tempb ~= 0 and tempc ~= 0 and tempa + tempb + tempc == playerRoll then
				counting = tempa + tempb + tempc
			end
		end
		iconString = '.  ' .. diceW[tempa].icon .. ' ' .. diceB[tempb].icon .. ' ' .. diceW[tempc].icon
		rollWooden(iconString, 3) return
	elseif maxValue == 24 then
		playerRoll = math.random(4, maxValue)
		local counting = 0
		local tempa = 0
		local tempb = 0
		local tempc = 0
		local tempd = 0
		while counting ~= playerRoll do
			tempa = math.random(6)
			tempb = math.random(6)
			tempc = math.random(6)
			tempd = math.random(6)
			if tempa ~= 0 and tempb ~= 0 and tempc ~= 0 and tempd ~= 0 and tempa + tempb + tempc + tempd == playerRoll then
				counting = tempa + tempb + tempc + tempd
			end
		end
		iconString = '.  ' .. diceW[tempa].icon .. ' ' .. diceB[tempb].icon .. ' ' .. diceW[tempc].icon .. ' ' .. diceB[tempd].icon
		rollWooden(iconString, 4) return
	else
		playerRoll = math.random(maxValue)
		rollStandard() return
	end
end

local function rollCheck(option)
	local rollDefault = RC.SV.rollDefault
	local opt = tonumber(option)
	if tostring(option) == '?' then
		d(L.RollCallRollQ1)
		d(L.RollCallRollQ2)
		d(L.RollCallRollQ3)
		d(L.RollCallRollQ4)
		return
	elseif opt == 6 then roll(6)
	elseif opt == 10 then roll(10)
	elseif opt == 12 then roll(12)
	elseif opt == 18 then roll(18)
	elseif opt == 20 then roll(20)
	elseif opt == 24 then roll(24)
	elseif opt == 50 then roll(50)
	elseif opt == 100 then roll(100)
	elseif opt == 1000 then roll(1000)
	else
		if rollDefault == 1 then roll(6)
		elseif rollDefault == 2 then roll(12)
		elseif rollDefault == 3 then roll(18)
		elseif rollDefault == 4 then roll(24)
		elseif rollDefault == 5 then roll(10)
		elseif rollDefault == 6 then roll(20)
		elseif rollDefault == 7 then roll(50)
		elseif rollDefault == 8 then roll(100)
		elseif rollDefault == 9 then roll(1000) end
	end
end

------------------------------------------------------------------------------------------------------------------------------------
-- Handles the posting of results to group.
------------------------------------------------------------------------------------------------------------------------------------
local function OnPingReceived(eventCode, pingEventType, pingType, pingTag, offsetX, offsetY, isOwner)

	if IsUnitInCombat('player') and RC.SV.noCombat then return end

	local rollNumber = tonumber(string.sub(tostring(offsetX), 3, 5))
	local rollMode = tonumber(string.sub(tostring(offsetY), 3, 3))
	local pingPos = tonumber(string.sub(tostring(offsetY), 4, 5))
	if pingPos ~= nil and rollNumber ~= nil and rollMode ~= nil then
		if pingPos <= GetGroupSize() and not isOwner then
			GetGroupNames(0)
			local iconString
			local rollMax = 0
			local counting = 0
			local tempa = 0
			local tempb = 0
			local tempc = 0
			local tempd = 0
			if rollMode == 1 then
				rollMax = 2
				iconString = ' ' .. coinS[rollNumber].icon
				local coinS
				if rollNumber == 1 then coinS = L.RollCallToss1 else coinS = L.RollCallToss2 end
				d(tostring(names[pingPos]) .. L.RollCallToss3 .. coinS .. iconString)
			elseif rollMode == 2 then
				rollMax = 6
				while counting ~= rollNumber do
					counting = math.random(6)
				end
				iconString = ' ' .. diceW[counting].icon		
				d(tostring(names[pingPos]) .. L.RollCallRoll5 .. rollNumber .. iconString)
			elseif rollMode == 3 then
				rollMax = 10
				d(L.RollCallRoll1 .. rollNumber .. L.RollCallRoll2 .. rollMax .. L.RollCallRoll3 .. tostring(names[pingPos]))
			elseif rollMode == 4 then
				rollMax = 12
				while counting ~= rollNumber do
					tempa = math.random(6)
					tempb = math.random(6)
					if tempa ~= 0 and tempb ~= 0 and tempa + tempb == rollNumber then
						counting = tempa + tempb
					end
				end
				iconString = ' ' .. diceW[tempa].icon .. ' ' .. diceB[tempb].icon
				d(tostring(names[pingPos]) .. L.RollCallRoll4 .. '2' .. L.RollCallRoll6 .. rollNumber .. iconString)
			elseif rollMode == 5 then
				rollMax = 18
				while counting ~= rollNumber do
					tempa = math.random(6)
					tempb = math.random(6)
					tempc = math.random(6)
					if tempa ~= 0 and tempb ~= 0 and tempc ~= 0 and tempa + tempb + tempc == rollNumber then
						counting = tempa + tempb + tempc
					end
				end
				iconString = ' ' .. diceW[tempa].icon .. ' ' .. diceB[tempb].icon .. ' ' .. diceW[tempc].icon
				d(tostring(names[pingPos]) .. L.RollCallRoll4 .. '3' .. L.RollCallRoll6 .. rollNumber .. iconString)
			elseif rollMode == 6 then
				rollMax = 24
				while counting ~= rollNumber do
					tempa = math.random(6)
					tempb = math.random(6)
					tempc = math.random(6)
					tempd = math.random(6)
					if tempa ~= 0 and tempb ~= 0 and tempc ~= 0 and tempd ~= 0 and tempa + tempb + tempc + tempd == rollNumber then
						counting = tempa + tempb + tempc + tempd
					end
				end
				iconString = ' ' .. diceW[tempa].icon .. ' ' .. diceB[tempb].icon .. ' ' .. diceW[tempc].icon .. ' ' .. diceB[tempd].icon
				d(tostring(names[pingPos]) .. L.RollCallRoll4 .. '4' .. L.RollCallRoll6 .. rollNumber .. iconString)
			elseif rollMode == 7 then
				rollMax = 50
				d(L.RollCallRoll1 .. rollNumber .. L.RollCallRoll2 .. rollMax .. L.RollCallRoll3 .. tostring(names[pingPos]))
			elseif rollMode == 8 then
				rollMax = 1000
				if rollNumber == 0 then rollNumber = 1000 end
				d(L.RollCallRoll1 .. rollNumber .. L.RollCallRoll2 .. rollMax .. L.RollCallRoll3 .. tostring(names[pingPos]))
			elseif rollMode == 9 then
				rollMax = 20
				d(L.RollCallRoll1 .. rollNumber .. L.RollCallRoll2 .. rollMax .. L.RollCallRoll3 .. tostring(names[pingPos]))
			elseif rollMode == 0 then
				rollMax = 100
				d(L.RollCallRoll1 .. rollNumber .. L.RollCallRoll2 .. rollMax .. L.RollCallRoll3 .. tostring(names[pingPos]))
			end
		end
	end
end

------------------------------------------------------------------------------------------------------------------------------------
-- Set up the options panel in Addon Settings.
------------------------------------------------------------------------------------------------------------------------------------
local function CreateSettingsWindow(addonName)
	local panelData = {
		type					= 'panel',
		name					= 'RollCall',
		displayName				= ZO_HIGHLIGHT_TEXT:Colorize('Roll Call'),
		author					= '|c66ccffPhinix|r',
		version					= RC.Version,
		registerForRefresh		= true,
		registerForDefaults		= true,
	}

	local optionsData = {
	{
		type = 'header',
		name = ZO_HIGHLIGHT_TEXT:Colorize(L.RollCallCharOpt),
	},
	{
		type			= 'dropdown',
		name			= L.RollCallRollO,
		tooltip			= L.RollCallRollOD,
		choices			= rollAction,
		getFunc			= function() return rollAction[RC.SV.rollDefault] end,
		setFunc			= function(selected)
							for k, v in ipairs(rollAction) do
								if v == selected then
									RC.SV.rollDefault = k
									break
								end
							end
						end,
		default			= rollAction[Defaults.rollDefault],
	},
	{
		type			= 'checkbox',
		name			= L.RollCallDC,
		tooltip			= L.RollCallDCD,
		getFunc			= function() return RC.SV.noCombat end,
		setFunc			= function(value)
							RC.SV.noCombat = value
						end,
		default			= Defaults.noCombat
	},
	{
		type			= 'checkbox',
		name			= L.RollCallCM,
		tooltip			= L.RollCallCMD,
		getFunc			= function() return RC.SV.chatMode end,
		setFunc			= function(value)
							RC.SV.chatMode = value
						end,
		default			= Defaults.chatMode
	}
	}

	local LAM = LibAddonMenu2
    LAM:RegisterAddonPanel('RollCall_Panel', panelData)
	LAM:RegisterOptionControls('RollCall_Panel', optionsData)
end

------------------------------------------------------------------------------------------------------------------------------------
-- Initialization functions.
------------------------------------------------------------------------------------------------------------------------------------
local function AddonInit()
	local fontString = tonumber(GetChatFontSize()) + 2
	fontString = fontString .. ':' .. fontString
	diceW[1] = {icon = '|t' .. fontString .. ':/RollCall/textures/d1w.dds|t'}
	diceW[2] = {icon = '|t' .. fontString .. ':/RollCall/textures/d2w.dds|t'}
	diceW[3] = {icon = '|t' .. fontString .. ':/RollCall/textures/d3w.dds|t'}
	diceW[4] = {icon = '|t' .. fontString .. ':/RollCall/textures/d4w.dds|t'}
	diceW[5] = {icon = '|t' .. fontString .. ':/RollCall/textures/d5w.dds|t'}
	diceW[6] = {icon = '|t' .. fontString .. ':/RollCall/textures/d6w.dds|t'}
	diceB[1] = {icon = '|t' .. fontString .. ':/RollCall/textures/d1b.dds|t'}
	diceB[2] = {icon = '|t' .. fontString .. ':/RollCall/textures/d2b.dds|t'}
	diceB[3] = {icon = '|t' .. fontString .. ':/RollCall/textures/d3b.dds|t'}
	diceB[4] = {icon = '|t' .. fontString .. ':/RollCall/textures/d4b.dds|t'}
	diceB[5] = {icon = '|t' .. fontString .. ':/RollCall/textures/d5b.dds|t'}
	diceB[6] = {icon = '|t' .. fontString .. ':/RollCall/textures/d6b.dds|t'}
	coinS[1] = {icon = '|t' .. fontString .. ':/RollCall/textures/cs1.dds|t'}
	coinS[2] = {icon = '|t' .. fontString .. ':/RollCall/textures/cs2.dds|t'}
	rollAction[1] = L.RollCallOpt1
	rollAction[2] = L.RollCallOpt2
	rollAction[3] = L.RollCallOpt3
	rollAction[4] = L.RollCallOpt4
	rollAction[5] = L.RollCallOpt5
	rollAction[6] = L.RollCallOpt6
	rollAction[7] = L.RollCallOpt7
	rollAction[8] = L.RollCallOpt8
	rollAction[9] = L.RollCallOpt9
end

local function OnAddonLoaded(event, addonName)
	if addonName ~= 'RollCall' then return end
	EVENT_MANAGER:UnregisterForEvent('RollCall', EVENT_ADD_ON_LOADED)
	RC.SV = ZO_SavedVars:New('RollCall', 1, nil, Defaults)
	CreateSettingsWindow(addonName)
	AddonInit()
end

SLASH_COMMANDS['/roll'] = function(option) rollCheck(option) end
SLASH_COMMANDS['/toss'] = function(option) toss(option) end
EVENT_MANAGER:RegisterForEvent('RollCall', EVENT_MAP_PING, OnPingReceived)
EVENT_MANAGER:RegisterForEvent('RollCall', EVENT_ADD_ON_LOADED, OnAddonLoaded)
