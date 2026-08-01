--[[
  [ Copyright (c) 2014 User Froali from ESOUI.com
  [ All Rights Reserved. If you want to use arts of my AddOns for your own work, please contact me first!
  ]]

---Checks if var is numeric
function isnumeric(a)
  return (tonumber(a) ~= nil)
end

---Post Hook implementation given
-- @usage http://www.esoui.com/forums/showpost.php?p=2737&postcount=2
function TI.postHook(funcName, callback, subtable)
	if(not subtable) then
		local tmp = _G[funcName]
		_G[funcName] = function(...)
			tmp(...)
			callback()
		end
	else
		local tmp = _G[subtable][funcName]
		_G[subtable][funcName] = function(...)
			tmp(...)
			callback()
		end
	end
end

---Get Normalized (1..5) guildId
function TI:getNormalizedGuildId(guildId)
	for i = 1, GetNumGuilds() do
		if(GetGuildId(i) == guildId) then
			return i
		end
	end
	return 0
end

---Finds the Charname of an AccName by scanning the guildMemberList
-- If CharName is not found, the AccANme will be returned as a fallback
function TI:findCharNameOfAccName(guildId, AccName)
	local memberCount = GetNumGuildMembers(guildId)
	for i = 1, memberCount do
		local displayName = GetGuildMemberInfo(guildId, i)
		if(displayName == AccName) then
			local hasCharacter, characterName = GetGuildMemberCharacterInfo(guildId, i)
			if(characterName ~= nil and string.len(characterName) > 0 ) then
				return characterName
			end
		end
	end
	return AccName
end


---Clears the name from system info fragements (charname^x)
function TI:clearName(name)
	if(name ~= nil and string.len(name) > 0) then
		--local cleanName, _ = string.gsub(name, "(%w+)[%^]+.*", "%1")
		return zo_strformat(SI_UNIT_NAME, name)
	end
	return "";
end

---Returns if setting is "show" of given guildId
--@param guildId Id [1-5] of guild to check
--@param setting which setting to check. use "constants" defined in settings.lua
function TI:getShowStatus(guildId, setting)
	guildId = TI:getNormalizedGuildId(guildId)
	if(not guildId or guildId > GetNumGuilds() or guildId < 1 or not TI.GetGuildSettings()) then return false end
--	local func = TI.guildGetFuncs[guildId]
--	if(func == nil ) then return false end
--	if(not _G["TI"][func]()) then return false end --Don't show announcements at all for this guild
	
	if(setting == nil) then setting = TI.SETTINGS_ALL end
	
	if(setting == TI.SETTINGS_ALL) then
		return TI.GetGuildSetting(guildId);
	elseif(setting == TI.SETTINGS_STATUS) then
		return TI.GetGuildSetting(guildId) and TI.GetGuildStatusSetting(guildId);
	elseif(setting == TI.SETTINGS_LEVEL) then
		return TI.GetGuildSetting(guildId) and TI.GetGuildLevelSetting(guildId);
	elseif(setting == TI.SETTINGS_MEMBER) then
		return TI.GetGuildSetting(guildId) and TI.GetGuildMemberSetting(guildId);
	end
	
	return false
end

---Returns true if given AccountName is the player
function TI:isPlayerSelf(AccName)
	if(AccName == GetDisplayName()) then
		return true
	end
	return false
end

---Returns if player is flagged as offline
function TI:isPlayerOffline(AccName, guildId)
    for i=1, GetNumGuildMembers(guildId) do
        local displayName,_,_,playerStatus = GetGuildMemberInfo(guildId, i)
        if(displayName == AccName) then
            return playerStatus == PLAYER_STATUS_OFFLINE
        end
    end
end

---Converts Seconds to Timestring like "1d 2h"
function TI:secsToTime(time)
	local days = math.floor(time / 86400)
	local hours = math.floor(time / 3600) - (days * 24)
	local minutes = math.floor(time / 60) - (days * 1440) - (hours * 60)
	local seconds = time % 60
	if(days >= 1) then
		return ("%dd %dh"):format(days,hours)
	end
	if(hours >= 1) then
		return ("%dh %dm"):format(hours,minutes)
	end
	if(minutes >= 1) then
		return ("%dm"):format(minutes)
	end
	return ("%ds"):format(seconds)
end

---Splits string on a given separator
--@return table
function TI:splitString(separator, str)
-- 	local t = {}
-- 	if(separator == nil) then
-- 		t[1] = str
-- 		return t
-- 	end
-- 	
-- 	local pattern = "(%w+)" .. separator .. "(%w+)";
-- 	pattern = "[^" .. separator .. "]+"
-- 	local i = 1
-- 	for v in string.gmatch(str, pattern) do
-- 		t[i] = v
-- 		i = i +1
-- 	end
-- 	return t

   return { zo_strsplit(separator, str) }
end

---Creates the appropriate representation for Accname/charName according to the settings
function TI:createNameToDisplay(guildId, AccName, charName)
	--check if all necessary parameter are set
	if( (AccName == nil and charName == nil) or guildId == nil) then return "error getting name!" end
	local formatSetting = TI.GetNameFormatSettings()
	
	--format according to settings
	if(formatSetting == TI.SETTINGS_SHOW_ACC_AND_CHAR_NAME) then
		if( charName == nil or string.len(charName) < 1) then
			charName = TI:findCharNameOfAccName(guildId, AccName)
		end
		return  TI:clearName(charName) .. AccName
	elseif(formatSetting == TI.SETTINGS_SHOW_CHAR_NAME) then
		if( charName == nil or string.len(charName) < 1) then
			charName = TI:findCharNameOfAccName(guildId, AccName)
		end
		return TI:clearName(charName)
	elseif(formatSetting == TI.SETTINGS_SHOW_ACC_NAME) then
		return AccName
	end
	return AccName
end

function TI:formatZoneName(rawName)
	local zoneTokens = TI:splitString(",", rawName)
	local zonePrefix = ""
	if(zoneTokens[2] ~= nil and string.len(zoneTokens[2]) > 0) then
		zonePrefix = zoneTokens[2] .. " "
	end
	local zone = ""
	if(zoneTokens[1] ~= nil and string.len(zoneTokens[1]) > 0) then
		zone =  TI:clearName(zoneTokens[1])
	end
	zoneName = string.format("%s%s", zonePrefix, zone)
	return zoneName
end

--- Shows Announcements in the way defined in the settings
function TI:showAnnouncement(template, ...)
    local arg = {...}

    if (TI.GetDisplayType(TI.SETTINGS_DISPLAY_TYPE_CHAT) ) then
        local processedStrings = {}
        for _,value in pairs(arg) do
            table.insert(processedStrings, TI:ApplyChatColor(value.text, value.color))
        end

        local chatString = zo_strformat(template, unpack(processedStrings))
        if(TI.GetShowTimestamp()) then
            chatString = string.format("[%s] ",GetTimeString()) .. chatString
        end
        CHAT_SYSTEM:AddMessage(chatString)
    end

    if( TI.GetDisplayType(TI.SETTINGS_DISPLAY_TYPE_LABEL) ) then

        if(not TI.SCT:IsInitialized()) then
            TI.SCT:Initialize(TI.displayControl)
        end
        local processedStrings = {}
        local color = nil
        for _,value in pairs(arg) do

            if(TI.GetDisplayColorModeSettings()) then
                color = value.color
            end

            table.insert(processedStrings, TI:ApplyChatColor(value.text, color))
        end
        local text = zo_strformat(template, unpack(processedStrings))
        TI.SCT:AddLine(text)
    end
end

---Converts RGBA table to HexString
function TI:RGBToHex(rgba)
	local hexadecimal = ''
	local a = rgba[4] or 1
	local rgb = {rgba[1], rgba[2], rgba[3]}
	for key, value in pairs(rgb) do
		local hex = ''
		value = math.floor(value*a*255)
		while(value > 0)do
			local index = math.fmod(value, 16) + 1
			value = math.floor(value / 16)
			hex = string.sub('0123456789ABCDEF', index, index) .. hex	
		end
		 
		if(string.len(hex) == 0)then
			hex = '00'
		elseif(string.len(hex) == 1)then
			hex = '0' .. hex
		end
		 
		hexadecimal = hexadecimal .. hex
	end
	return hexadecimal
end

---Applys RGBA color table to text string for use in chat messages
-- @param text Text to colorize
-- @param rgba table {r,g,b,a} with color information
function TI:ApplyChatColor(text, rgba)
    if(rgba == nil) then return text end
	local string = ''
	local hexstring = TI:RGBToHex(rgba)
	string = "|c" .. hexstring .. text.. "|r"
	
	return string
end