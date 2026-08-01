local EZReport = _G['EZReport']
local L = EZReport:GetLanguage()


------------------------------------------------------------------------------------------------------------------------------------
-- Global Utility functions
------------------------------------------------------------------------------------------------------------------------------------
function EZReport.TColor(color, text) -- Wraps the color tags with the passed color around the given text.
	-- color:		String, hex format color string, for example "ffffff".
	-- text:		The text to format with the given color.

	-- Example: PF.TColor("ff0000", "This is red.")
	-- Returns: "|cff0000This is red.|r"

	local cText = "|c"..tostring(color)..tostring(text).."|r"
	return cText
end

function EZReport.Round(number, decimals) -- Round number to decimals number of places.
	-- number:		The number to round.
	-- decimals:	The number of decimals to round to. 0 = Nearest integer.
	--
	-- Example: PF.Round(42.185, 2) = 42.19
	-- NOTE: Value of decimals must be a whole number >= 0.

	local tDec = math.floor(decimals)
	return tonumber(string.format("%." .. (tDec or 0) .. "f", number))
end

function EZReport.RGB2Hex(rgb) -- Gets hex color format string from LibAddonMenu { r=r, g=g, b=b, a=a } colopicker or { [1]=r, [2]=g, [3]=b, [4]=a } saved variable table.
	-- Works opposite to the above, used for the SetFunc in LibAddonMenu color picker to save the chosen color to a hex variable for use in addons.
	--	setFunc = function(r, g, b, a)
	--		local color = { r=r, g=g, b=b, a=a }
	--		Addon.ASV.textColor = PF.RGB2Hex(color)
	--	end,

	-- account for different format input
	local r = (rgb['r']) and rgb['r'] or rgb[1]
	local g = (rgb['g']) and rgb['g'] or rgb[2]
	local b = (rgb['b']) and rgb['b'] or rgb[3]

	local cstring = ""
	local function cProc(val)
		local colornum = val * 255
		local hexstr = "0123456789abcdef"
		local s = ""
		while colornum > 0 do
			local mod = math.fmod(colornum, 16)
			s = string.sub(hexstr, mod+1, mod+1) .. s
			colornum = math.floor(colornum / 16)
		end
		if #s == 1 then s = "0" .. s end
		if s == "" then s = "00" end
		return s
	end
	cstring = cProc(r)..cProc(g)..cProc(b)
	return cstring
end

function EZReport.GetDateTime(t12, dUSA, sepH, nCap) -- Generates a custom formatted time/date string (with options).
	-- t12:		Int, 1 or nil if you want 12 hour format time return, 2 for 24 hour 'military' time.
	-- dUSA:	Int, 1 or nil for USA format date MM-DD-YYYY, 2 for DD-MM-YYYY.
	-- sepH:	Int, 1 or nil for '/' date separator, 2 for '-'.
	-- nCap:	Int, 1 or nil for lower case 'am/pm' in time string, 2 to capitalize.

	-- Example 1:	local datestamp, timestamp = PF.GetDateTime():
	-- Returns: datestamp = 3/12/2019 (string), timestamp = 2:46pm (string)

	-- Example 2:	local datestamp, timestamp = PF.GetDateTime(2, 2, 2):
	-- Returns: datestamp = 12-03-2019 (string), timestamp = 14:46 (string)

	-- OPTIONAL: Declare additional variables for day, month, year return.
	-- Example: local datestamp, timestamp, day, month, year = PF.GetDateTime():
	-- Returns: datestamp = 03/12/2019 (string), timestamp = 2:46pm (string), day = 12 (number), month = 3 (number), year = 2019 (number)

-- Default values:
	t12 = (t12 == nil) and 1 or t12
	dUSA = (dUSA == nil) and 1 or dUSA
	sepH = (sepH == nil) and 1 or sepH
	nCap = (nCap == nil) and 1 or nCap

	local datestamp = ''
	local timestamp = ''
	local hour = ''
	local day = os.date("%d")
	local month = os.date("%m")
	local year = os.date("%Y")
	local dateSep = (sepH == 1) and '\/' or '-'

	if dUSA == 1 then
		datestamp = month..dateSep..day..dateSep..year
	else
		datestamp = day..dateSep..month..dateSep..year
	end

	if t12 == 1 then
		hour = string.format("%u", os.date("%H"))
		local thour = (tonumber(hour) == 0) and tostring(12) or ((tonumber(hour) <= 12) and hour or tostring(tonumber(hour) - 11))
		local AM = (nCap == 1) and 'am' or 'AM'
		local PM = (nCap == 1) and 'pm' or 'PM'
		local ampm = (tonumber(hour) < 12) and AM or PM
		timestamp = thour..":"..os.date("%M")..ampm
	else
		hour = os.date("%H")
		timestamp = hour..":"..os.date("%M")
	end

	return datestamp, timestamp, tonumber(day), tonumber(month), tonumber(year)
end


------------------------------------------------------------------------------------------------------------------------------------
-- Modifies database without requiring complete saved variable reset.
------------------------------------------------------------------------------------------------------------------------------------
function EZReport.DBMaintenance()
--	local version = EZReport.ASV.sVars.version
--	if version > 0 and version < 1.16 then -- update db to include location data

--	elseif version == 0 then
		EZReport.ASV.sVars.version = 1.05

------------------------------------------------------------------------------------------------------------------------------------
-- Loop for future updates.
------------------------------------------------------------------------------------------------------------------------------------

--	end
end
