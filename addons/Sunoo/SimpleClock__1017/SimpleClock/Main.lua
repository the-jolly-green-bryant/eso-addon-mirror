-- Load libraries
LAM = LibStub:GetLibrary('LibAddonMenu-1.0-to-2.0')
LMP = LibStub:GetLibrary('LibMediaProvider-1.0')

---
-- Main namespace for the addon.
--
-- @class  table
--
-- @field  events    Contains event handler functions named after the events
--                   they respond to.
-- @field  sv        Saved variables get stored here once they're loaded.
-- @field  buffer    Event buffer table.
-- @field  config    Reusable config data for scripts.
-- @field  defaults  Default SavedVariables settings.
--
sc = { events = {},	sv = {}, buffer = {}, config = {}, defaults = {} }

---
-- Main config settings.
--
-- @class  table
--
-- @field  name    Name of the addon, mostly for generating controls.
-- @field  svName  Name to use for saving/loading SavedVariables.
--
sc.config = {
	name   = 'SimpleClock',
	svName = 'SimpleClock_SavedVariables'
}

---
-- Basic event buffering, from http://wiki.esoui.com/Event_%26_Update_Buffering
--
-- @param  key      Unique string for the buffer name to start or check.
-- @param  seconds  Number of seconds to hold up the buffer for.
--
-- @return  bufferReady  Boolean indicating whether or not it's ok to proceed.
--
function sc:bufferReached(key, seconds)

	if sc.buffer[key] == nil then
		sc.buffer[key] = {}
	end

	sc.buffer[key].buffer = seconds or 1
	sc.buffer[key].now = GetFrameTimeSeconds()

	if sc.buffer[key].last == nil then
		sc.buffer[key].last = sc.buffer[key].now
	end

	sc.buffer[key].diff = sc.buffer[key].now - sc.buffer[key].last
	sc.buffer[key].eval = sc.buffer[key].diff >= sc.buffer[key].buffer

	if sc.buffer[key].eval then
		sc.buffer[key].last = sc.buffer[key].now
	end

	return sc.buffer[key].eval

end

---
-- Updates the saved variables for the clock's position.
--
function sc:savePositions()

	local x, y   = sc.ui.clock:GetCenter()
	local half   = sc.ui.clock:GetWidth() / 2
	local posMap = { Left = x - half, Right = x + half, Center = x }

	sc.sv.offset.x = posMap[sc.sv.align]
	sc.sv.offset.y = y

end

---
-- Gets a formatted string representing the current time, based on the user's
-- saved settings.
--
-- @return  The formatted time as a human-readable string.
--
function sc:getTimeString()

	local seconds   = GetSecondsSinceMidnight()
	local style     = TIME_FORMAT_STYLE_CLOCK_TIME
	local precision = self:getTimePrecision()
	local direction = TIME_FORMAT_DIRECTION_NONE

	local formatted = FormatTimeSeconds(seconds, style, precision, direction)

	-- Don't need any further formatting if we're showing 24hr time
	if self.sv.use24Hour then
		return formatted
	end

	-- Remove the AM/PM indicators
	if self.sv.hideMeridiem then
		return formatted:gsub('%a%.', '')
	end

	-- Convert AM/PM to lowercase
	if self.sv.lowercaseMeridiem then
		formatted = formatted:lower();
	end

	-- Strip out dots from AM/PM
	if self.sv.noDotsMeridiem then
		formatted = formatted:gsub('%.', '')
	end

	return formatted

end

---
-- Gets the constant representing the time format precision to use.
--
-- @return  Integer representing which time precision to use.
--
function sc:getTimePrecision()

	if self.sv.use24Hour then
		return TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR
	else
		return TIME_FORMAT_PRECISION_TWELVE_HOUR
	end

end

---
-- Loads settings from saved variables.
--
function sc:loadSavedVariables()
	sc.sv = ZO_SavedVars:NewAccountWide(sc.config.svName, 1, sc.config.name, sc.defaults)
end
