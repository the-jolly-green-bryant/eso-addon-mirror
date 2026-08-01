-- ==================================================================================================== --
-- # Immersive Interactions
-- # 
-- # It's an addon for ESO. I'm not going to put a fancy license or disclaimer. Go crazy with it.
-- ==================================================================================================== --

do
	local debugTable = {
		["all"]			= DEBUG_ALL,
		["interact"]	= DEBUG_INTERACT,
		["tat"]			= DEBUG_TAT,
		["tab"]			= DEBUG_TAB,
		["opt"]			= DEBUG_OPT,
		["alt"]			= DEBUG_ALT,
		["validate"]	= DEBUG_VALIDATE,
		["settings"]	= DEBUG_SETTINGS,
		["guid"]		= DEBUG_GUI,
		["other"]		= DEBUG_OTHER,
	}

	function ImmersiveFunctions.Debug(debugType)
		local imd = ImmersiveData.debugInfo
		-- if debugging turned off, return false always
		if not imd.DEBUG then return false end
		-- if debuging turned on, and debug all turned on, return true always
		if imd.DEBUG_ALL then return true end

		if not debugType then return true end -- consider nil to be query if debug is enabled

		-- find the dbug type in the table, then if it exists, return the value
		local dbug = debugTable[debugType]
		if dbug then
			return ImmersiveData[dbug]
		end

		return false
	end
end
