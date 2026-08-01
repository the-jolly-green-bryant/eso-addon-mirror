local ADDON = DefaultLanguageNinja

ADDON.IS_DEBUG = false
--ADDON.IS_DEBUG = true

--------
-- in this file local use, private
--------

local outputWarningFlag = false
local initMessageDone = false
local cacheData = {}

--------
-- in this ADDON use, protected
--------

ADDON.SystemMessage = function(str, forceToOutput)
	-- build message
	local message = false
	if (forceToOutput or ADDON.IS_DEBUG) then
		message = ADDON.SHORT_NAME .. " " .. tostring(str)
	end
	if (not message) then
		return
	end

	-- output to cacheTable if not inited yet
	if (not initMessageDone) then
		table.insert(cacheData, message)
		return
	end

	-- warning if needed
	if (ADDON.IS_DEBUG) then
		if (not outputWarningFlag) then
			d(ADDON.SHORT_NAME .. " " .. "!!! Now debug mode!!!")
			outputWarningFlag = true
		end
	end

	-- output cache if remains
	if (#cacheData > 0) then
		for key,cache in ipairs(cacheData) do
			d(cache)
		end
		cacheData = {}
	end

	-- output
	return d(message)
end

ADDON.d = function(str)
	return ADDON.SystemMessage(str, true)
end

ADDON.develop = function(str)
	return ADDON.SystemMessage(str, false)
end

ADDON.InitMessage = function()
	if (initMessageDone) then
		return
	end
	initMessageDone = true
	if (not ADDON.SaveData.ShowMessageOnInit) then
		return
	end
	ADDON.SystemMessage(ADDON.DISPLAY_NAME .. " v" .. ADDON.VERSION .. " by " .. ADDON.AUTHOR, true)
end
