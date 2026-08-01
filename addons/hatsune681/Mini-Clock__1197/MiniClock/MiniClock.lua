--
-- Local Time by hatsune681
--
-- This very simple on screen clock was based on alfpog's SimpleClock v 0.0.1
-- http://wiki.esoui.com, wowwiki for cooling down OnUpdate (gained many fps)
-- many routines recoded

--
-- Everything in a namespace
--
MiniClock = {
	-- constants
	ModuleName = "MiniClock",
	ClockFormats = {
		[ "World Map" ] = { font = "ZoFontWinH3", colour = { GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_NORMAL) } },
		[ "Performance Meter" ] = { font = "ZoFontWinT2", colour = {1,1,1,1} } 
	},
	ClockStyles = { "World Map", "Performance Meter" },
	Clock24h = TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR,

	-- variables
	defaults = {
		offsetX   = 20,
		offsetY   = 18,
		clkStyle  = "Performance Meter"
	},
	currentFrameTime = GetFrameTimeSeconds(),
	vars = { }
}
--
-- Gets a formatted string representing the current time.
-- now (2019-10) follows the format used by clock shown on map
--
function MiniClock:getTimeString()
	-- ZO_FormatClockTime
	-- instead of local t, s = ZO_FormatClockTime()
	-- one day maybe better for in game time ...
	local localTimeSinceMidnight = GetSecondsSinceMidnight()
	--local t, s = ZO_FormatTime(localTimeSinceMidnight, TIME_FORMAT_STYLE_CLOCK_TIME, TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR)
	local t, s = ZO_FormatTime(localTimeSinceMidnight, TIME_FORMAT_STYLE_CLOCK_TIME, Clock24h)
	return t
-- function GetLocalTimeOfDay() : int hours, int minutes, int seconds
-- function GetGlobalTimeOfDay() : int hours, int minutes, int seconds

end

--
-- Updates the local time clock.
--
function MiniClock.updateWidget()
	local newFrameTime = GetFrameTimeSeconds()
	lCol = MiniClock.ClockFormats[MiniClock.vars.clkStyle].colour
	if newFrameTime >= (MiniClock.currentFrameTime + 1.0) then
		MiniClock.currentFrameTime = newFrameTime
		MiniClockL:SetText(MiniClock:getTimeString())
	end
end

--
-- Updates the saved variables for the clock's position.
--
function MiniClock:saveWidgetPosition()
	local x, y = MiniClockW:GetCenter()
	MiniClock.vars.offsetX = x
	MiniClock.vars.offsetY = y
end

--
-- Changes Clock Style
-- 
function MiniClock:setStyle(aStyle)
	MiniClockL:SetFont(MiniClock.ClockFormats[aStyle].font)
	local r = MiniClock.ClockFormats[aStyle].colour[1]
	local g = MiniClock.ClockFormats[aStyle].colour[2]
	local b = MiniClock.ClockFormats[aStyle].colour[3]
	local a = MiniClock.ClockFormats[aStyle].colour[4]
	
	MiniClockL:SetColor(r,g,b,a)
	if (GetCVar("Language.2") == "en") then
		Clock24h = TIME_FORMAT_PRECISION_TWELVE_HOUR
	else
		Clock24h = TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR
	end
end

--
-- Setup Options ine libAddonMenu
--
function MiniClock:setupOptions()

	local panelData = {
		type = "panel",
		-- author = "See website"
		version = "Current 😁", --
		name = "MiniClock",
		registerForDefaults = true,
	}
	
	local optionsTable = {
		[1] = {
			type = "dropdown",
			name = "Clock format",
			choices = { "World Map", "Performance Meter" },
			getFunc = function() return MiniClock.vars.clkStyle end,
			setFunc = function(aValue)
				MiniClock.vars.clkStyle = aValue
				MiniClock:setStyle(aValue)
			end
		}
	}

	local LAM = LibAddonMenu2
	LAM:RegisterAddonPanel("MiniClockOptions", panelData)
	LAM:RegisterOptionControls("MiniClockOptions", optionsTable)
end

--
-- Loads settings from saved variables.
--
function MiniClock:init()
	MiniClock.vars = ZO_SavedVars:NewCharacterIdSettings("MiniClock_SavedVariables", 2, nil, MiniClock.defaults)
	local x = MiniClock.vars.offsetX
	local y = MiniClock.vars.offsetY
	MiniClock:setStyle(MiniClock.vars.clkStyle)
	MiniClock:setupOptions()

	-- hooks for World Map
	local oldOnShow = ZO_WorldMap_OnShow
	function ZO_WorldMap_OnShow()
--		if ZO_WorldMap_GetMode() < 7 then
			MiniClockW:SetHidden(true)
--		end
		oldOnShow(self)
	end

	local oldOnHide = ZO_WorldMap_OnHide
	function ZO_WorldMap_OnHide()
--		if ZO_WorldMap_GetMode() < 7 then
			MiniClockW:SetHidden(false)
--		end
		oldOnHide(self)
	end

--  Suggested by WfD Temp Account
    	EVENT_MANAGER:RegisterForUpdate("MiniClockUpdate", 200, MiniClock.updateWidget)
--
	MiniClockW:SetAnchor(CENTER, GuiRoot, TOPLEFT, x, y)
end

--
-- Handler for EVENT_ADD_ON_LOADED event
--
local function OnLoad(eventCode, name)
	if (name == MiniClock.ModuleName) then
		EVENT_MANAGER:UnregisterForEvent(MiniClock.ModuleName, eventCode)
		MiniClock:init()
	end
end

--
-- Registering events
--
EVENT_MANAGER:RegisterForEvent(MiniClock.ModuleName, EVENT_ADD_ON_LOADED, OnLoad)
