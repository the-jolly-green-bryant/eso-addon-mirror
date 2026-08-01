--[========================================================================[
    This is free and unencumbered software released into the public domain.

    Anyone is free to copy, modify, publish, use, compile, sell, or
    distribute this software, either in source code form or as a compiled
    binary, for any purpose, commercial or non-commercial, and by any
    means.

    In jurisdictions that recognize copyright laws, the author or authors
    of this software dedicate any and all copyright interest in the
    software to the public domain. We make this dedication for the benefit
    of the public at large and to the detriment of our heirs and
    successors. We intend this dedication to be an overt act of
    relinquishment in perpetuity of all present and future rights to this
    software under copyright law.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
    OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
    ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
    OTHER DEALINGS IN THE SOFTWARE.

    For more information, please refer to <http://unlicense.org/>
--]========================================================================]

local MAJOR, MINOR = "LibXPBonus", 0.01
LibXPBonus = LibXPBonus or {}
local lib = LibXPBonus

lib.name        = MAJOR
lib.version     = MINOR
--SavedVariables info
lib.svDataName  = "LibXPBonus_SV_Data"
lib.svVersion   = 0.01
--Debug chat output, if value is true. Set to true/false via chat command /script LibXPBonus.debug=true
lib.debug = false

------------------------------------------------------------------------
-- 	Local variables, global for the library
------------------------------------------------------------------------
--All bonus XP abilityIds
local XPBonusData    = {
	[63570] 	= true, 	-- erhöhter Erfahrungsgewinn
	[66776] 	= true, 	-- erhöhter Erfahrungsgewinn
	[77123] 	= true, 	-- Jubiläums-Erfahrungsbonus
	[85501] 	= true, 	-- erhöhter Erfahrungsgewinn
	[85502] 	= true, 	-- erhöhter Erfahrungsgewinn
	[85503] 	= true, 	-- erhöhter Erfahrungsgewinn
	[86755] 	= true, 	-- Feiertags-Erfahrungsbonus
	[91369] 	= true, 	-- erhöhter Erfahrungsgewinn der Narrenpastete
	[92232] 	= true, 	-- Pelinals Wildheit
	[99462] 	= true, 	-- erhöhter Erfahrungsgewinn
	[99463]		= true,		-- erhöhter Erfahrungsgewinn
	[118985] 	= true, 	-- Jubiläums-Erfahrungsbonus    
}

------------------------------------------------------------------------
-- 	Local helper functions
------------------------------------------------------------------------
--Get a millisecond time formatted to seconds
local function convertMSToSeconds(msValue)
-- Calculate time left of a food/drink buff
	return tostring(math.max(zo_roundToNearest(msValue-(GetGameTimeMilliseconds()/1000), 1), 0))
end

--Helper function to format the milliseconds to a time format
--MSValue: The milliseconds value (a Timestamp!)
--timeFormatString: os.date(timeFormatString, timeStamp) format string, see: https://www.lua.org/pil/22.1.html
--[[ timeFormatString can be a combination of:
%a	abbreviated weekday name (e.g., Wed)
%A	full weekday name (e.g., Wednesday)
%b	abbreviated month name (e.g., Sep)
%B	full month name (e.g., September)
%c	date and time (e.g., 09/16/98 23:48:10)
%d	day of the month (16) [01-31]
%H	hour, using a 24-hour clock (23) [00-23]
%I	hour, using a 12-hour clock (11) [01-12]
%M	minute (48) [00-59]
%m	month (09) [01-12]
%p	either "am" or "pm" (pm)
%S	second (10) [00-61]
%w	weekday (3) [0-6 = Sunday-Saturday]
%x	date (e.g., 09/16/98)
%X	time (e.g., 23:48:10)
%Y	full year (1998)
%y	two-digit year (98) [00-99]
%%	the character `%´
]]
--useStandardFormatParam: Use the standard format for the output? if isTimeLeft = true: Seconds; fals: 24h format "%H:%M:%S"
--isTimeLeft: is the current time in MSvalue the time left between abilityId timeStart and timeEnd?
local function formatMSWithTimeFormat(MSvalue, timeFormatString, useStandardFormatParam, isTimeLeft)
	isTimeLeft = isTimeLeft or false
	if MSvalue == nil or MSvalue <= 0 then return 0 end
	local timeFormatted = ""
	--Use standard time format
	if useStandardFormatParam == true then 
		--Use seconds formatting as standard for timeLeft
		if isTimeLeft then 
			return convertMSToSeconds(MSvalue)
		else
			--Format the startTime or endTime with standard format hh:mm:ss 24h
			timeFormatted = os.date("%H:%M:%S", MSvalue) --24h time format
		end
	--Use formated time String
	elseif not useStandardFormatParam and (timeFormatString ~= nil and timeFormatString ~= "") then
		--Format the time value with standard format hh:mm:ss 24h
		timeFormatted = os.date(timeFormatString, MSvalue) --24h time format
	
	--Don't use formatted time String and don't use Standard Format: Just keep the format as it is
	else
		timeFormatted = tostring(MSvalue)
	end
	return timeFormatted
end

--Get all player buffs active and return them in a table with key abilityId and value boolean, e.g. [12345] = true
local function getCurrentPlayerBuffs(onlyActiveXPBuffs, useFormattedTime, timeFormat)
	onlyActiveXPBuffs = onlyActiveXPBuffs or false 	--only return active XPBonus buffs from currently active player buffs
	useFormattedTime = useFormattedTime or false 			--format the time of startTime and endTime, returned in the table, with a specific timeFormat String parameter
	local useStandardFormat = false
	--Standard time format, if needed
	if useFormattedTime and (timeFormat == nil or timeFormat == "") then
		--Use seconds as format for the timeLeft value, and hh:mm:ss 24h format as standard for the startTime and endTime values
		useStandardFormat = true
	end
	--Get the current buffs on the player
	local numBuffsOnPlayer = GetNumBuffs("player")
	if numBuffsOnPlayer <= 0 then return end
	local currentPlayerBuffs
	local buffName, startTime, endTime, iconFile, buffSlot, stackCount, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff
    for buffIndex = 1, numBuffsOnPlayer do
        --** _Returns: _buffName_, _timeStarted_, _timeEnding_, _buffSlot_, _stackCount_, _iconFilename_, _buffType_, _effectType_, _abilityType_, _statusEffectType_, _abilityId_, _canClickOff_
        buffName, startTime, endTime, buffSlot, stackCount, iconFile, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff = GetUnitBuffInfo("player", buffIndex)
		if abilityId ~= nil then
			local goOn = true
			if onlyActiveXPBuffs == true then
				goOn = (XPBonusData[abilityId] == true) or false
			end
			if goOn == true then
				currentPlayerBuffs = currentPlayerBuffs or {}
				local timeLeftMS = endTime - startTime
				if timeLeftMS < 0 then timeLeftMS = 0 end
				currentPlayerBuffs[abilityId] = {
					["name"] 				= buffName,
					["startTime"] 			= startTime,
					["endTime"] 			= endTime,
					["timeLeft"]			= timeLeftMS,
					["startTimeFormatted"] 	= formatMSWithTimeFormat(startTime,		timeFormat,	useStandardFormat, false),
					["endTimeFormatted"] 	= formatMSWithTimeFormat(endTime, 		timeFormat, useStandardFormat, false),
					["timeLeftFormatted"]	= formatMSWithTimeFormat(timeLeftMS,	timeFormat, useStandardFormat, true),
					["buffSlot"] 			= buffSlot,
					["stackCount"] 			= stackCount,
					["iconFile"] 			= iconFile,
					["buffType"] 			= buffType,
					["effectType"] 			= effectType,
					["abilityType"] 		= abilityType,
					["statusEffectType"] 	= statusEffectType,
					["abilityId"]			= abilityId,
					["canClickOff"] 		= canClickOff,
				}
				if lib.debug then
					d("[LibXPBonus]BuffName: '"..tostring(buffName).."', AbilityId: " .. tostring(abilityId) .. ", Start/End time: " ..tostring(startTime) .. "(" .. tostring(currentPlayerBuffs[abilityId]["startTimeFormatted"]) .. ")/" ..tostring(endTime) .. "(" .. tostring(currentPlayerBuffs[abilityId]["endTimeFormatted"]) .. ")")
				end
			end
		end
    end
	return currentPlayerBuffs
end


--Check the current player's buffs for the abilityId given, or if no abilityId is given scan for all XPBonus abilityIds
--abilityId: 			NILABLE abilityId of an ability e.g. the XP buff
--currentPlayerBuffs: 	NILABLE Table with the current player buffs. If NIL it will be filled via function getCurrentPlayerBuffs(...)
--useFormattedTime: 	NILABLE Boolean Use a format String for OS.time function, specified in parameter timeFormat
--timeFormat:			NILABLE STring the time format for dunction OS.time
local function checkPlayerBuffsForXPBuff(abilityId, currentPlayerBuffs, useFormattedTime, timeFormat)
	if currentPlayerBuffs == nil then currentPlayerBuffs = getCurrentPlayerBuffs(true, useFormattedTime, timeFormat) end
	lib.currentPlayerBuffs = currentPlayerBuffs
	if currentPlayerBuffs == nil then return nil, abilityId end
	local isAbilityIdActiveInCurrentPlayerBuffs = false
	--Check with abilityId
	if abilityId ~= nil then 
		if abilityId > 0 then isAbilityIdActiveInCurrentPlayerBuffs = (currentPlayerBuffs[abilityId] ~= nil) or false end
	else
		--Check without abilityId -> Check ALL XPBonus abilityIds
		for abilityIdLoop, isXPBonusActive in pairs(XPBonusData) do
			if isXPBonusActive == true and currentPlayerBuffs[abilityIdLoop] ~= nil then
				return true, abilityIdLoop
			end
		end
	end
	return isAbilityIdActiveInCurrentPlayerBuffs, abilityId
end

------------------------------------------------------------------------
-- 	Global functions
------------------------------------------------------------------------


--Returns true if the player got an XP bonus currently ative
--> Returns:    boolean isXPBonusActive	
-->				NILABLE number abilityIdFound 	(the abilityId of the XPBuff found)
function lib.IsAnyXPBonusActive()
	local isAnyXPBonusActive, abilityIdFound = checkPlayerBuffsForXPBuff()
    return isAnyXPBonusActive, abilityIdFound
end

--Returns true if the player got the XP bonus currently ative, provided with parameter abilityId
--abilityId: 			AbilityId of an ability e.g. the XP buff
--> Returns:    boolean isXPBonusActive
function lib.IsXPBonusActive(abilityId)
	if abilityId == nil then return end
	abilityId = tonumber(abilityId)
	if abilityId <= 0 or not DoesAbilityExist(abilityId) then return end
	local isXPBonusActive = checkPlayerBuffsForXPBuff(abilityId)
	return isXPBonusActive
end

--Returns a table containing the current player buffs, with the info determined via API function GetUnitBuffInfo()
--> Returns:	table currentPlayerBuffsInfo
--[[
currentPlayerBuffsInfo[abilityId] = {
				["name"] 				= buffName,
				["startTime"] 			= startTime,
				["endTime"] 			= endTime,
				["buffSlot"] 			= buffSlot,
				["stackCount"] 			= stackCount,
				["iconFile"] 			= iconFile,
				["buffType"] 			= buffType,
				["effectType"] 			= effectType,
				["abilityType"] 		= abilityType,
				["statusEffectType"] 	= statusEffectType,
				["abilityId"]			= abilityId,
				["canClickOff"] 		= canClickOff,
			}
]]			
function lib.GetCurrentPlayerBuffs(formattedTime, timeFormat)
	return getCurrentPlayerBuffs(false, formattedTime, timeFormat)
end

--Returns a table of the active XP bonus buffs, with the info determined via API function GetUnitBuffInfo()
--> Returns:	table currentPlayerBuffsXPBonusInfo
--[[
currentPlayerBuffsXPBonusInfo[abilityId] = {
				["name"] 				= buffName,
				["startTime"] 			= startTime,
				["endTime"] 			= endTime,
				["buffSlot"] 			= buffSlot,
				["stackCount"] 			= stackCount,
				["iconFile"] 			= iconFile,
				["buffType"] 			= buffType,
				["effectType"] 			= effectType,
				["abilityType"] 		= abilityType,
				["statusEffectType"] 	= statusEffectType,
				["abilityId"]			= abilityId,
				["canClickOff"] 		= canClickOff,
			}
]]			
function lib.GetCurrentPlayerXPBonusBuffs(formattedTime, timeFormat)
	return getCurrentPlayerBuffs(true, formattedTime, timeFormat)
end

------------------------------------------------------------------------
--Addon loaded function
local function OnLibraryLoaded(event, name)
    --Only load lib if ingame
    if name:find("^ZO_") then return end
    EVENT_MANAGER:UnregisterForEvent(MAJOR, EVENT_ADD_ON_LOADED)
    
    lib.XPBonusData = XPBonusData
end

--Load the addon now
EVENT_MANAGER:UnregisterForEvent(MAJOR, EVENT_ADD_ON_LOADED)
EVENT_MANAGER:RegisterForEvent(MAJOR, EVENT_ADD_ON_LOADED, OnLibraryLoaded)