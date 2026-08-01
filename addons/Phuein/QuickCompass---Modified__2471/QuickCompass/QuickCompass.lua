--[[
  * Author: Zen
  * Purpose: grabs crafting data (levels, traits, motifs) and skill line abilities plus other character data
  *          Guild MoTD updates are monitored and displayed when a change is detected
  *          Data can be uploaded to the Crimson Order website which will push the data into a database
  *          Characters can then be reviewed/displayed on a web page
  * Portions taken from Wykkyd's [ Mail Box ] - which unfortunately broke during a patch upgrade
  * Sponsored & Supported by: Mostly Harmless (mostly-harmless-guild.com)
  * Author: Wykkyd, aka Wykkyd Gaming (wykkyd.gaming@gmail.com) (mailbox handling)
  * Embedded: LibStub & libAddonMenu by Seerah.
  * Special Thanks To: Zenimax Online Studios & Bethesda for The Elder Scrolls Online
]]--
local crimsonTS3URL = "|c2dc50ets3server://216.127.64.148?port=18074|r"
local prideTS3URL = "|c2dc50epridesden.ts.nfoservers.com|r"
local guildTS3URL = ""
local guildName = ""
local coaoConstants = {
	High = 0,
	Medium = 500,
	Low = 1000
}
local coaoConstantNames = { "High", "Medium", "Low" }
local coaoCompassZones = { "All Zones", "Cyrodiil", "Groups" }

function call_later( delay ) zo_callLater( xoCOGlateEcho, delay ) end


local active = false
local message_of_the_day = ""
local guildID = 0
local guilds = {}
local motd_text_data = ""
local coZenStartup = true
local coFirstMessage = true
local compassState = false
local lastZone = ""
local inCombat = false

local curZone = ""
local startAP = 0
local lastAP = 0
local apBackup = 0
local forceAP = false
local mostRecentAP = 0
local cyrodillTimestamp = 0
local lastCyrodiilTimestamp = 0

local quickcompassTempzone = ""

local _addon = {}
_addon._v = {}
_addon._v.major		= 1
_addon._v.monthly 	= 0
_addon._v.daily 	= 1 --27
_addon._v.minor 	= 17 --1
_addon.Version 	= _addon._v.major
	..".".._addon._v.monthly
	..".".._addon._v.daily
	..".".._addon._v.minor
_addon.Name			= "QuickCompass"
_addon.MAJOR 		= _addon.Name..".".._addon._v.major
_addon.MINOR 		= string.format(".%02d%02d%03d", _addon._v.monthly, _addon._v.daily, _addon._v.minor)
_addon.DisplayName  = "Quick Compass"
_addon.Author 		= "Zen @ The Crimson Order"
_addon.SavedVariableVersion = 1
_addon.Player = "" -- will be set on load by LibWykkkydFactory
_addon.Settings = {} -- will be set on load by LibWykkkydFactory, if you pass in the final parameter: your global saved variable as a string
_addon.GlobalSettings = {} -- will be set on load by LibWykkkydFactory, if you pass in the final parameter: your global saved variable as a string
_addon.wykkydPreferred = nil

_addon.Sender = ""
_addon.EmailTitle = ""
_addon.InboxVisible = false
_addon.selectedMailID = nil
_addon.message_of_the_day = ""
_addon.motd_text_data = ""
_addon.ReturnedMail = {}


local deleteCallback = function(a,b,c,d,e,f,g,h,i)
	if _addon.selectedMailID ~= nil and _addon.selectedMailID ~= 0 then
		local _,_,_,_,_,_,_,_,numAttachments,attachedMoney,_,_,_ = GetMailItemInfo(_addon.selectedMailID)
		 if numAttachments == nil or numAttachments == 0 then
			if attachedMoney == nil or attachedMoney == 0 then
				DeleteMail( _addon.selectedMailID, true )
			end
		end
	end
end

_addon.LoadSavedVariables = function( self )
	if self.Settings.mailbot == nil then self.Settings.mailbot = true end
	if self.Settings.delete_confirm_byebye == nil then self.Settings.delete_confirm_byebye = true end
	if self.Settings.motd == nil then self.Settings.motd = true end
	if self.Settings.timestamp == nil then self.Settings.timestamp = true end
	if self.Settings.compass == nil then self.Settings.compass = true end
	if self.Settings.CompassX == nil then self.Settings.CompassX = COAOCompass:GetLeft() end
	if self.Settings.CompassY == nil then self.Settings.CompassY = COAOCompass:GetTop() end
	if self.Settings.Compass16 == nil then self.Settings.Compass16 = false end
	if self.Settings.CompassBound == nil then self.Settings.CompassBound = true end
	if self.Settings.CompassRate == nil then self.Settings.CompassRate = "High" end
	if self.Settings.CompassZones == nil then self.Settings.CompassZones = "All Zones" end
	if self.Settings.Advert == nil then self.Settings.Advert = "" end
	if self.Settings.PreventChatFade == nil then self.Settings.PreventChatFade = false end
	if self.Settings.APEarnedX == nil then self.Settings.APEarnedX = COAOAPE:GetLeft() end
	if self.Settings.APEarnedY == nil then self.Settings.APEarnedY = COAOAPE:GetTop() end
	if self.Settings.APEarnedShow == nil then self.Settings.APEarnedShow = true end
	if self.Settings.lastAP == nil then self.Settings.lastAP = GetAlliancePoints('player') end
	if self.Settings.APBackDrop == nil then self.Settings.APBackDrop = false end
	if self.Settings.CompassCombat == nil then self.Settings.CompassCombat = false end

	self:CompassRestorePos( self );
	self:APEarnedRestorePos( self )
end

_addon.CompassRestorePos = function( self )
	local left = self.Settings.CompassX
	local top = self.Settings.CompassY
	COAOCompass:ClearAnchors()
	COAOCompass:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, left, top )
end

_addon.APEarnedRestorePos = function( self )
	local left = self.Settings.APEarnedX
	local top = self.Settings.APEarnedY
	COAOAPE:ClearAnchors()
	COAOAPE:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, left, top )
end

function COAOCompassMoveStop()
	_addon.Settings.CompassX = COAOCompass:GetLeft()
	_addon.Settings.CompassY = COAOCompass:GetTop()
end

function COAOCompassUpdate()
	if _addon.Settings.compass then
		if GetPlayerCameraHeading() == nil then return "" end
		local dleft = ""
		local dright = ""
		local heading = GetPlayerCameraHeading() * 57.2957795
		local direction = _addon.getDirection( heading )
		if direction == "" then return end

		if _addon.Settings.CompassBound then
			if _addon.Settings.Compass16 then
				local r = heading-22.5
				if r < 0 then r = r+360 end
				local l = heading+22.5
				if l > 360 then l = l-360 end
				dleft = _addon.getDirection(  l )
				dright = _addon.getDirection( r )
			else
				local r = heading-45
				if r < 0 then r = r+360 end
				local l = heading+45
				if l > 360 then l = l-360 end
				dleft = _addon.getDirection( l )
				dright = _addon.getDirection( r )
			end
		end
		COAOCompassDisplayLeft:SetText(dleft)
		COAOCompassDisplayRight:SetText(dright)
		COAOCompassDisplayMain:SetText(direction)
	else
		_addon:OnUpdateCallback( "COAOCompass", nil )
	end
	if GetUnitZone("player") ~= lastZone then
		_addon.enableCompass()
	end

end

function COAOAPEarnedMoveStop()
	_addon.Settings.APEarnedX = COAOAPE:GetLeft()
	_addon.Settings.APEarnedY = COAOAPE:GetTop()
end

_addon.CompassChat = function()
	local x = COAOCompass:GetLeft()
	local y = COAOCompass:GetTop()

	d("Compass: "..x.."/"..y)
end

_addon.getDirection = function( heading )
	if _addon.Settings.Compass16 then
		return _addon.getDirection16( heading )
	else
		return _addon.getDirection8( heading )
	end
end

_addon.getDirection8 = function( heading )
	if(	(heading > 0 and heading < 22.50) or (heading > 337.50) )
		then return "N"
	elseif(	heading > 22.50 and heading < 67.50)
		then return "NW"
	elseif(	heading > 67.50 and heading < 112.50)
		then return "W"
	elseif(	heading > 112.50 and heading < 157.50)
		then return "SW"
	elseif(	heading > 157.50 and heading < 202.50)
		then return "S"
	elseif(	heading > 202.50 and heading < 247.50)
		then return "SE"
	elseif( heading > 247.50 and heading < 292.50)
		then return "E"
	elseif( heading > 292.50 and heading < 337.50)
		then return "NE"
	end
end

_addon.getDirection16 = function( heading )
	if(	(heading > 0 and heading < 11.25) or (heading > 348.75) )
		then return "N"
	elseif(	heading > 11.25 and heading < 33.75)
		then return "NNW"
	elseif(	heading > 33.75 and heading < 56.25)
		then return "NW"
	elseif(	heading > 56.25 and heading < 78.75)
		then return "WNW"
	elseif(	heading > 78.75 and heading < 101.25)
		then return "W"
	elseif(	heading > 101.25 and heading < 123.75)
		then return "WSW"
	elseif( heading > 123.75 and heading < 146.25)
		then return "SW"
	elseif( heading > 146.25 and heading < 168.75)
		then return "SSW"
	elseif(	heading > 168.75 and heading < 191.25)
		then return "S"
	elseif(	heading > 191.25 and heading < 213.75)
		then return "SSE"
	elseif(	heading > 213.75 and heading < 236.25)
		then return "SE"
	elseif(	heading > 236.25 and heading < 258.75)
		then return "ESE"
	elseif(	heading > 258.75 and heading < 281.25)
		then return "E"
	elseif( heading > 281.25 and heading < 303.75)
		then return "ENE"
	elseif( heading > 303.75 and heading < 326.25)
		then return "NE"
	elseif( heading > 326.25 and heading < 348.75)
		then return "NNE"
	end
end

_addon.LoadSettingsMenu = function( self )
	local panelData = self:MakeStandardSettingsPanel( "Zen @ The Crimson Order", "|cFF2222" )
	local optionsTable = {
		[1] = {
			type = "description",
			text = "Quick Compass displays a compass heading for the direction your camera is facing. Originally written ny TiddlyPlatypus and enhanced by Zen.",
		},
		[2] = { type = "submenu", name = "|cCAB222".."Compass".."|r",
			controls = {
				[1] = {
					type = "description",
					text = "Display a compass",
				},
				[2] = {
					type = "description",
					text = "|cFFFFFF".."Displays an 8 or 16 point direction indicator for better PvP alerts. Can be dragged to a new position|r",
				},
				[3] = {
					type = "checkbox",
					name = "Enable Compass",
					tooltip = "Enables a compass so you can give better info to groups",
					getFunc = function() return self:GetOrDefault( true, self.Settings[ "compass" ] ) end,
					setFunc = function( val ) _addon.Settings.compass = val; _addon.CompassSetDisplayMode() end,
				},
				[4] = {
					type = "checkbox",
					name = "16 Point Compass",
					tooltip = "Display a 16 point compass instead of 8",
					getFunc = function() return self:GetOrDefault( true, self.Settings[ "Compass16" ] ) end,
					setFunc = function( val ) self.Settings[ "Compass16" ] = val end,
				},
				[5] = {
					type = "checkbox",
					name = "Display Rotations",
					tooltip = "Also display the points to left and right",
					getFunc = function() return self:GetOrDefault( true, self.Settings[ "CompassBound" ] ) end,
					setFunc = function( val ) self.Settings[ "CompassBound" ] = val end,
				},
				[6] = {
					type = "dropdown",
					name = "Refresh Rate",
					tooltip = "Set the rate at which the compass refreshes",
					choices = coaoConstantNames,
					getFunc = function() return self:GetOrDefault( coaoConstantNames[0], self.Settings[ "CompassRate" ] ) end,
					setFunc = function( val ) self.Settings[ "CompassRate" ] = val; _addon.compassChangeSettings() end,
				},
				[7] = {
					type = "dropdown",
					name = "Display when in:",
					tooltip = "Display compass when in:",
					choices = coaoCompassZones,
					getFunc = function() return self:GetOrDefault( coaoConstantNames[0], self.Settings[ "CompassZones" ] ) end,
					setFunc = function( val ) self.Settings[ "CompassZones" ] = val; _addon.compassChangeSettings() end,
				},
				[8] = {
					type = "checkbox",
					name = "Show Alliance Points Earned",
					tooltip = "Displays the number of Alliance Points earned since entering Cyrodiil, taking into consideration AP spent",
					getFunc = function() return self:GetOrDefault( true, self.Settings[ "APEarnedShow" ] ) end,
					setFunc = function( val ) self.Settings[ "APEarnedShow" ] = val; _addon.APEarnedWindowToggle( val ) end,
				},
				[9] = {
					type = "checkbox",
					name = "Show AP Backdrop",
					tooltip = "Show AP Backdrop on Alliance Points Earned window",
					getFunc = function() return self:GetOrDefault( true, self.Settings[ "APBackDrop" ] ) end,
					setFunc = function( val )
									self.Settings[ "APBackDrop" ] = val
									if GetUnitZone('player') == "Cyrodiil" and self.Settings.APEarnedShow then
										local alpha = 0.0
										if _addon.Settings.APBackDrop == true then alpha = 1.0 end

										COAOAPEBG:SetAlpha( alpha )
									end
								end,
				},
				[10] = {
					type = "checkbox",
					name = "Only Show During Combat",
					tooltip = "Display compass during combat only.",
					getFunc = function() return self:GetOrDefault( true, self.Settings[ "CompassCombat" ] ) end,
					setFunc = function( val ) self.Settings[ "CompassCombat" ] = val; _addon.compassChangeSettings() end,
				},
			},
		},
		[3] = { type = "submenu", name = "|cFFFFFF".."Chat Commands".."|r",
			controls = {
				[1] = {
					type = "description",
					text = _addon.coAOHelpText()
				},
			},
		},
	}
	optionsTable = self:InjectAdvancedSettings( optionsTable, 1 )
	self.LAM:RegisterAddonPanel(_addon.Name.."_LAM", panelData)
	self.LAM:RegisterOptionControls(_addon.Name.."_LAM", optionsTable)
end

_addon.Initialize = function( self )
	self:RegisterEvent(EVENT_END_FAST_TRAVEL_INTERACTION, self.enableCompass)
	self:RegisterEvent(EVENT_ZONE_CHANGED, self.enableCompass)
	self:RegisterEvent(EVENT_ZONE_UPDATE, self.enableCompass)
	self:RegisterEvent(EVENT_PLAYER_COMBAT_STATE, self.CombatEvent)

	if self.Settings.APEarnedShow then
		-- forceAP = true
		-- self.DisplayAPEarnedWin3()
		-- self:OnUpdateCallback( "CrimsonOrderAOAPEarned", self.DisplayAPEarnedWin2, 5 )
	end

	self.enableCompass()
	zo_callLater( self.enableCompass, 10000 )
end

if QuickCompassData == nil then QuickCompassData = {} end
LWF4.REGISTER_FACTORY(
	_addon, false, true,
	function( self ) _addon:LoadSavedVariables( self ) end,
	function( self ) _addon:LoadSettingsMenu( self ) end,
	function( self ) _addon:Initialize( self ) end,
	"QuickCompassData", true
)

_addon.enableCompass = function()
	-- Only display if in combat.
	if _addon.Settings.CompassCombat and not inCombat then return end

	local newState = false
	local qzone = _addon.Settings.CompassZones

	_addon.APEarnedWindowToggle( _addon.Settings.APEarnedShow )

	if not _addon.Settings.compass then
		compassState = false
		return
	end

	local unitZone = GetUnitZone("player")
	if quickcompassTempzone ~= "" and unitZone ~= quickcompassTempzone then
		quickcompassTempzone = ""
	end

	if qzone == "All Zones" or (unitZone == qzone) or (qzone == "Groups" and IsUnitGrouped("player")) or (unitZone == quickcompassTempzone) then
		newState = true
	end
	if compassState then
		if not newState then
			EVENT_MANAGER:UnregisterForUpdate("COAOCompass")
			COAOCompassDisplayLeft:SetText("")
			COAOCompassDisplayRight:SetText("")
			COAOCompassDisplayMain:SetText("")
			-- d("Compass disabled")
		end
	else
		if newState then
			EVENT_MANAGER:RegisterForUpdate( "COAOCompass", coaoConstants[ _addon.Settings.CompassRate ], COAOCompassUpdate )
			-- d("Compass enabled")
		end
	end
	compassState = newState
	lastZone = unitZone
end

_addon.compassOn = function()
	_addon.Settings.compass = true
	_addon.enableCompass()
end

_addon.compassOff = function()
	_addon.Settings.compass = false
	compassState = false
	EVENT_MANAGER:UnregisterForUpdate("COAOCompass")
	COAOCompassDisplayLeft:SetText("")
	COAOCompassDisplayRight:SetText("")
	COAOCompassDisplayMain:SetText("")
	-- d("Compass disabled")
end

_addon.CompassSetDisplayMode = function()
	if _addon.Settings.compass then
		_addon.enableCompass()
	else
		_addon.compassOff()
	end
end

_addon.compassChangeSettings = function()
	if _addon.Settings.compass then
		_addon.compassOff()
		_addon.Settings.compass = true
		_addon.enableCompass()
	end
end

_addon.converthm = function(timesec)
	timesec = timesec%86400
	local nb_heure = math.floor(timesec/3600)
	local reste = timesec - (nb_heure*3600)
	local nb_minute = math.floor(reste/60)
	return string.format("%02d:%02d", nb_heure, nb_minute)
end

_addon.APEarnedWindowToggle = function( val )
	if val then
		_addon.DisplayAPEarnedWin3()
	else
		clearAPEarnedWindow()
	end

end

_addon.DisplayAPEarnedWin3 = function()
	local thisZone = GetUnitZone('player')
	local reset = false

	if thisZone == "Cyrodiil" and not (curZone == "Cyrodiil") then
		reset = true
	elseif curZone == "Cyrodiil" and not (thisZone == "Cyrodiil") then
		lastCyrodiilTimestamp = GetTimeStamp()
		EVENT_MANAGER:UnregisterForEvent( _addon.Name, EVENT_ALLIANCE_POINT_UPDATE )
		EVENT_MANAGER:UnregisterForUpdate( "COXCA" )
	end
	if reset then
		startAP = 0
		lastAP = 0
		apBackup = 0
		if thisZone == "Cyrodiil" then
			curZone = "Cyrodiil"
			cyrodillTimestamp = GetTimeStamp()
			lastCyrodiilTimestamp = cyrodillTimestamp

			-- force display of zero data
			local data = _addon.APEarnedText()
			local alpha = 0.0
			if _addon.Settings.APBackDrop == true then alpha = 1.0 end

			COAOAPEBG:SetAlpha( alpha )
			COAOAPEDisplayLeft:SetText( data[1] )
			COAOAPEDisplayCenter:SetText( data[2] )
			COAOAPEDisplayRight:SetText( data[3] )


			EVENT_MANAGER:RegisterForEvent( _addon.Name, EVENT_ALLIANCE_POINT_UPDATE  , _addon.updateAPEarned )
			EVENT_MANAGER:RegisterForUpdate( "COXCA", 5000, _addon.dummyAPEarned)
			-- need timer event for ap/hr updates
		end
	end
	if thisZone ~= "Cyrodiil" then
		COAOAPEBG:SetAlpha( 0.0 )
		COAOAPEDisplayLeft:SetText("")
		COAOAPEDisplayCenter:SetText("")
		COAOAPEDisplayRight:SetText("")
	end
	curZone = thisZone
end

_addon.APEarnedReset = function()
	lastAP = 0
	mostRecentAP = 0
	apBackup = 0
	cyrodillTimestamp = GetTimeStamp()
	lastCyrodiilTimestamp = cyrodillTimestamp
	local data = _addon.APEarnedText()
	COAOAPEDisplayLeft:SetText( data[1] )
	COAOAPEDisplayCenter:SetText( data[2] )
	COAOAPEDisplayRight:SetText( data[3] )
	if GetUnitZone('player') ~= "Cyrodiil" then
		zo_callLater( clearAPEarnedWindow, 5000 )
	end
end

_addon.DisplayAPEarnedWinTemp = function()
	local data = _addon.APEarnedText()
	COAOAPEDisplayLeft:SetText( data[1] )
	COAOAPEDisplayCenter:SetText( data[2] )
	COAOAPEDisplayRight:SetText( data[3] )
	zo_callLater( clearAPEarnedWindow, 5000 )
end

function clearAPEarnedWindow()
	COAOAPEDisplayLeft:SetText("")
	COAOAPEDisplayCenter:SetText("")
	COAOAPEDisplayRight:SetText("")
	if COAOAPEBG:GetAlpha() > 0 then
		COAOAPEBG:SetAlpha( 0.0 )
	end
end

_addon.updateAPEarned = function( evid, ap, bPlaySound, difference )
	lastCyrodiilTimestamp = GetTimeStamp()
	if difference < 5 then
		apBackup = apBackup + difference
		difference = 0
		if apBackup < 5 then
			return
		end
	end
	lastAP = lastAP + difference + apBackup
	mostRecentAP = difference + apBackup
	local data = _addon.APEarnedText()
	COAOAPEDisplayLeft:SetText( data[1] )
	COAOAPEDisplayCenter:SetText( data[2] )
	COAOAPEDisplayRight:SetText( data[3] )
	apBackup = 0
end

_addon.dummyAPEarned = function()
	lastCyrodiilTimestamp = GetTimeStamp()
	local data = _addon.APEarnedText()
	COAOAPEDisplayLeft:SetText( data[1] )
	COAOAPEDisplayCenter:SetText( data[2] )
	COAOAPEDisplayRight:SetText( data[3] )
end

_addon.APEarnedText = function()
	local avg = _addon.Settings.lastAP
	local timeInCyrodiil = ""

	if cyrodillTimestamp and lastCyrodiilTimestamp and lastAP then
		if lastCyrodiilTimestamp - cyrodillTimestamp > 3599 then
			local hrs = (lastCyrodiilTimestamp - cyrodillTimestamp)/3600
			avg = lastAP/hrs
		else
			avg = lastAP
		end
	end
	if cyrodillTimestamp and lastCyrodiilTimestamp then
		timeInCyrodiil = "  (".._addon.converthm(lastCyrodiilTimestamp - cyrodillTimestamp)..")"
	end
	local lap = "|cD6660CAP Earned:    |r|cffffff".._addon:comma_value(lastAP)
	local map = "\n|cD6660CMost Recent:    |r|cffffff".._addon:comma_value(mostRecentAP)
	local mvg = "\n|cD6660CAP/Hour:    |r|cffffff".._addon:comma_value(avg)
	local tot = "\n|cD6660CTotal AP:    |r|cffffff".._addon:comma_value( GetAlliancePoints('player') )

	local lapm = "|cD6660CAP Earned:"
	local mapm = "\n|cD6660CMost Recent:"
	local mvgm = "\n|cD6660CAP/Hour:"
	local totm = "\n|cD6660CTotal AP:"

	local lapi = _addon:comma_value(lastAP)
	local mapi = "\n".._addon:comma_value(mostRecentAP)
	local mvgi = "\n".._addon:comma_value(avg)
	local toti = "\n".._addon:comma_value( GetAlliancePoints('player') )

	return { lapm..mapm..mvgm..totm, timeInCyrodiil, lapi..mapi..mvgi..toti }
end

_addon.APEarnedChat = function()
	local data = "|cD6660CAP Earned: |r ".._addon.Settings.lastAP.."\n|cD6660CTotal AP:     |r|cffffff".._addon:comma_value(GetAlliancePoints('player'))
	d( data )
end

local b = function( bool )
	if bool then return "true" else return "false" end
end


_addon.Cover = function()
	d( XT.Chattime().."|cD6660CThe Crimson Order|r v".._addon.Version )
end

_addon.enableTempZone = function()
	quickcompassTempzone = GetUnitZone("player")
	_addon.enableCompass()
end

_addon.coAOHelpText = function()
	local text = "|c249382Quick Compass Slash Commands|r\n"..
				"|cD6660C/qc|r - |c2dc50eDisplay compass screen coordinates|r\n"..
				"|cD6660C/qcreset|r - |c2dc50eForce reconfiguration of the compass|r\n"..
				"|cD6660C/qchelp|r - |c2dc50eList Slash Commands|r\n"..
				"|cD6660C/qcon|r - |c2dc50eEnable Compass|r\n"..
				"|cD6660C/qcoff|r - |c2dc50eDisable Compass|r\n"..
				"|cD6660C/qcnow|r - |c2dc50eEnable Compass this zone|r\n"..
				"|cD6660C/qclastap|r - |c2dc50eChat AP stats|r\n"..
				"|cD6660C/qcflashap|r - |c2dc50eBriefly display AP stats window|r\n"..
				"|cD6660C/qcresetap|r - |c2dc50eReset stats in AP Earned window|r\n"..
				"|cD6660C/qcver|r - |c2dc50eQuick Compass version|r\n"
	return text
end

_addon.coAOHelp = function()
	d( _addon.coAOHelpText() )
end

-- Toggle the compass depending on combat state.
-- Use a delay, and recheck after the delay.
_addon.CombatEvent = function(eventId, engaged)
	-- Always track combat state.
	if engaged then
		inCombat = true
	else
		inCombat = false
	end

	-- Disabled.
	if not _addon.Settings.CompassCombat then return end

	if engaged then
		-- Already on.
		if compassState then return end

		_addon.compassOn()
	else
		-- Already off.
		if not compassState then return end

		zo_callLater(function()
			if not inCombat then
				_addon.compassOff()
			end
		end, 10000)
	end
end

SLASH_COMMANDS["/qcver"] = _addon.Cover
SLASH_COMMANDS["/qc"] = _addon.CompassChat
SLASH_COMMANDS["/qcreset"] = _addon.CompassSetDisplayMode
SLASH_COMMANDS["/qchelp"] = _addon.coAOHelp
SLASH_COMMANDS["/qcon"] = _addon.compassOn
SLASH_COMMANDS["/qcoff"] = _addon.compassOff
SLASH_COMMANDS["/qclastap"] = _addon.APEarnedChat
SLASH_COMMANDS["/qcflashap"] = _addon.DisplayAPEarnedWinTemp
SLASH_COMMANDS["/qcresetap"] = _addon.APEarnedReset
SLASH_COMMANDS["/qcnow"] = _addon.enableTempZone

QCDATA = _addon
