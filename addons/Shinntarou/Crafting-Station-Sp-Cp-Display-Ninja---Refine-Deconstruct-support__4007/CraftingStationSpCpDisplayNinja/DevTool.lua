local ADDON = CraftingStationSpCpDisplayNinja

--------
-- in this file local use, private
--------

local outputWarningFlag = false
local initMessageDone = false
local cacheData = {}

--------
-- in this ADDON use, protected
--------

ADDON.IS_DEBUG = function()
	if ADDON.SaveDataGlobal.DebugMode ~= nil and ADDON.SaveDataGlobal.DebugMode == true then
		return true
	end
end

ADDON.SystemMessage = function(str, forceToOutput, delay)
	-- build message
	local message = false
	if (forceToOutput or ADDON.IS_DEBUG()) then
		message = ADDON.SHORT_NAME .. " " .. tostring(str)
	end
	if (not message) then
		return
	end

	if delay then
		delay = 1000
	else
		delay = 0
	end

	-- output to cacheTable if not inited yet
	if (not initMessageDone) then
		table.insert(cacheData, message)
		return
	end

	zo_callLater(
		function()
			-- warning if needed
			if (ADDON.IS_DEBUG()) then
				if (not outputWarningFlag) then
					d(ADDON.SHORT_NAME .. " " .. "!!! Now debug mode!!!")
					outputWarningFlag = true
				end
			end

			-- output cache if remains
			if (#cacheData > 0) then
				for key, cache in ipairs(cacheData) do
					d(cache)
				end
				cacheData = {}
			end

			-- output
			d(message)
		end,
		delay
	)
end

ADDON.d = function(str)
	return ADDON.SystemMessage(str, true)
end

ADDON.develop = function(str)
	return ADDON.SystemMessage(str, false)
end

ADDON.d_delay = function(str)
	return ADDON.SystemMessage(str, true, true)
end

ADDON.develop_delay = function(str)
	return ADDON.SystemMessage(str, false, true)
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

ADDON.var_keys = function(o)
	if type(o) == "table" then
		local s = ""
		for k, v in pairs(o) do
			if type(k) ~= "number" then
				k = '"' .. k .. '"'
			end
			s = s .. "[" .. k .. ":"
			if type(v) == "table" then
				s = s .. "(table)"
			else
				s = s .. tostring(v)
			end
			s = s .. "]"
		end
		return s
	else
		return "(not table)" .. tostring(o)
	end
end

ADDON.var_keys_dump = function(o)
	ADDON.d(ADDON.var_keys(o))
end
